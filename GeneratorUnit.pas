unit GeneratorUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs,
  StdCtrls, mmsystem, ExtCtrls, Spin, Vcl.Graphics, Vcl.ComCtrls;

type
  TServiceThread = class(TThread)
  public
    procedure Execute; override;
  end;

  TForm1 = class(TForm)
    btnPlay: TButton;
    btnStop: TButton;
    GroupBox1: TGroupBox;
    seLfreq: TSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    seLLev: TSpinEdit;
    GroupBox2: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    seRfreq: TSpinEdit;
    seRLev: TSpinEdit;
    rgL: TRadioGroup;
    rgR: TRadioGroup;
    pnlWawe: TPanel;
    pbWave: TPaintBox;
    btn1: TButton;
    btn2: TButton;
    statStatus: TStatusBar;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure cbLtypChange(Sender: TObject);
    procedure cbRTypChange(Sender: TObject);
    procedure seLfreqChange(Sender: TObject);
    procedure seRfreqChange(Sender: TObject);
    procedure seLLevChange(Sender: TObject);
    procedure seRLevChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pbWaveMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbWaveMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure pbWaveMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbWavePaint(Sender: TObject);
  private
    FEditingWaveForm: Boolean;
  private
    function CheckPixel(X, Y: Integer; ABmp: TBitmap): Boolean;
    procedure ScanBitmap(ABmp: TBitmap);
    procedure LineToWaveForm;
    procedure WaveFormToLine;
  public
    { Public declarations }

  end;

const
  BlockSize = 1024 * 32;
  // ������ ������ ������ -- � ������-�� min ������� ������ ��� ����
  WaveFormLenght = 512;
  PenColor = clNavy;

var
  Form1: TForm1;
  ServiceThread: TServiceThread;

implementation

{$R *.DFM}

var
  Freq: array [0 .. 1] of LongInt;
  Typ: array [0 .. 1] of LongInt;
  Lev: array [0 .. 1] of LongInt;
  tPred: array [0 .. 1] of Double;
  WaveForm: array [0 .. WaveFormLenght - 1] of SmallInt;
  WaveBmp: array [0 .. MAXWORD - 1, 0 .. WaveFormLenght - 1] of Byte;

procedure Mix(Buffer, First, Second: PAnsiChar; Count: LongInt); assembler;
{ ��������� ��������� ��� ������� ������ First � Second � �������� }
{ ��������� � Buffer. �������� �������� ����� ������ WORD }
{ Count -- ����� �������� � ����� �������, �.�. Buffer ����� ����� }
{ 2*Count ��������� }

{ EAX - Buffer }
{ EDX - First }
{ ECX - Second }
{ Count -- � ����� }
asm
  PUSH    EBX
  PUSH    ESI
  PUSH    EDI
  MOV     EDI,EAX     // Buffer ������� � EDI -- ��������� ������� ���������
  MOV     ESI,ECX     // Second ������� � ESI -- ��������� ������� ���������
  MOV     ECX,Count   // Count ������� � ECX
  XCHG    ESI,EDX     // ����� ��������� -- ������ First
@@Loop:
  MOVSW              // ��������� ����� �� First/Second � Buffer � ��������� ��������
  XCHG    ESI,EDX    // ����� ���������
  LOOP    @@Loop     // ��������� ECX � �������� ������� ������ ECX = 0

  POP     EDI
  POP     ESI
  POP     EBX
end;

procedure TForm1.btnPlayClick(Sender: TObject);
var
  WOutCaps: TWAVEOUTCAPS;
begin
  // �������� ������� ���������� ������
  FillChar(WOutCaps, SizeOf(TWAVEOUTCAPS), #0);
  if MMSYSERR_NOERROR <> WaveOutGetDevCaps(0, @WOutCaps, SizeOf(TWAVEOUTCAPS))
  then
  begin
    ShowMessage('������ ���������������');
    exit;
  end;
  // ���������� ���������� �������
  Freq[0] := seLfreq.Value;
  Freq[1] := seRfreq.Value;
  Typ[0] := rgL.ItemIndex;
  Typ[1] := rgR.ItemIndex;
  Lev[0] := seLLev.Value;
  Lev[1] := seRLev.Value;
  tPred[0] := 0;
  tPred[1] := 0;
  // ������ ������ ������ �� ����������
  ServiceThread := TServiceThread.Create(False);
end;

procedure Generator(buf: PAnsiChar; Typ, Freq, Lev, Size: LongInt;
  var tPred: Double);
var
  I: LongInt;
  OmegaC, t: Double;
begin
  case Typ of
    0: // ������
      begin
        for I := 0 to Size - 2 do
        begin
          PSmallInt(buf)^ := 0;
          Inc(PSmallInt(buf));
        end;
        tPred := 0;
      end;
    1: // �����
      begin
        OmegaC := 2 * PI * Freq;
        for I := 0 to Size div 2 do
        begin
          t := I / 44100 + tPred;
          PSmallInt(buf)^ := Round(Lev * sin(OmegaC * t));
          Inc(PSmallInt(buf));
        end;
        tPred := t;
      end;
    2: // ������
      begin
        OmegaC := 2 * PI * Freq;
        for I := 0 to Size div 2 do
        begin
          t := I / 44100 + tPred;
          if sin(OmegaC * t) >= 0 then
            PSmallInt(buf)^ := Lev
          else
            PSmallInt(buf)^ := -Lev;
          Inc(PSmallInt(buf));
        end;
        tPred := t;
      end;
  end;
end;

procedure TServiceThread.Execute;
var
  I: Integer;
  hEvent: THandle;
  wfx: TWAVEFORMATEX;
  hwo: HWAVEOUT;
  si: TSYSTEMINFO;
  wh: array [0 .. 1] of TWAVEHDR;
  buf: array [0 .. 1] of PAnsiChar;
  CnlBuf: array [0 .. 1] of PAnsiChar;
begin

  // ���������� ��������� �������
  FillChar(wfx, SizeOf(TWAVEFORMATEX), #0);
  with wfx do
  begin
    wFormatTag := WAVE_FORMAT_PCM; // ������������ PCM ������
    nChannels := 2; // ��� ������������
    nSamplesPerSec := 44100; // ������� ������������� 44,1 ���
    wBitsPerSample := 16; // ������� 16 ���
    nBlockAlign := wBitsPerSample div 8 * nChannels;
    // ����� ���� � ������ ��� ������������ -- 4 �����
    nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
    // ����� ���� � ��������� ��������� ��� �������������
    cbSize := 0; // �� ������������
  end;

  // �������� ����������
  hEvent := CreateEvent(nil, False, False, nil);
  if WaveOutOpen(@hwo, 0, @wfx, hEvent, 0, CALLBACK_EVENT) <> MMSYSERR_NOERROR
  then
  begin
    CloseHandle(hEvent);
    exit;
  end;

  // ��������� ������ ��� ������, ������������� ��� �������� ������ Windows
  GetSystemInfo(si);
  buf[0] := VirtualAlloc(nil, (BlockSize * 4 + si.dwPageSize - 1)
    div si.dwPageSize * si.dwPageSize, MEM_RESERVE or MEM_COMMIT,
    PAGE_READWRITE);
  buf[1] := PAnsiChar(LongInt(buf[0]) + BlockSize);
  // �������� ������ ��� ����������� ��� ������ �����
  CnlBuf[0] := PAnsiChar(LongInt(buf[1]) + BlockSize);
  CnlBuf[1] := PAnsiChar(LongInt(CnlBuf[0]) + BlockSize div 2);

  // ���������� 2-� ������� ������
  for I := 0 to 1 do
  begin
    FillChar(wh[I], SizeOf(TWAVEHDR), #0);
    wh[I].lpData := buf[I]; // ��������� �� �����
    wh[I].dwBufferLength := BlockSize; // ����� ������
    waveOutPrepareHeader(hwo, @wh[I], SizeOf(TWAVEHDR));
    // ���������� ������� ���������
  end;

  // ��������� ������� �������
  Generator(CnlBuf[0], Typ[0], Freq[0], Lev[0], BlockSize div 2, tPred[0]);
  Generator(CnlBuf[1], Typ[1], Freq[1], Lev[1], BlockSize div 2, tPred[1]);
  // ���������� ������� ������� � ������ ����� ������
  Mix(buf[0], CnlBuf[0], CnlBuf[1], BlockSize div 2);
  I := 0;
  while not Terminated do
  begin
    // �������� ���������� ������ �������� ��� ������������
    waveOutWrite(hwo, @wh[I], SizeOf(WAVEHDR));
    WaitForSingleObject(hEvent, INFINITE);
    I := I xor 1;
    // ��������� ������� �������
    Generator(CnlBuf[0], Typ[0], Freq[0], Lev[0], BlockSize div 2, tPred[0]);
    Generator(CnlBuf[1], Typ[1], Freq[1], Lev[1], BlockSize div 2, tPred[1]);
    // ���������� ������� ������� � ��������� ����� ������
    Mix(buf[I], CnlBuf[0], CnlBuf[1], BlockSize div 2);
    // �������� ����� ������������ � ������������ ����������� ������

  end;

  // ���������� ������ � ����������������
  waveOutReset(hwo);
  waveOutUnprepareHeader(hwo, @wh[0], SizeOf(WAVEHDR));
  waveOutUnprepareHeader(hwo, @wh[1], SizeOf(WAVEHDR));
  // ������������ ������
  VirtualFree(buf[0], 0, MEM_RELEASE);
  WaveOutClose(hwo);
  CloseHandle(hEvent);
end;

procedure TForm1.btn1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to WaveFormLenght - 1 do
    if I < WaveFormLenght div 2 then
      WaveForm[I] := 16384
    else
      WaveForm[I] := -16384;

  WaveFormToLine;
end;

procedure TForm1.btn2Click(Sender: TObject);
begin
  pbWave.Repaint;
  WaveFormToLine;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  rgL.ItemIndex := 1;
  rgR.ItemIndex := 1;
end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
  ServiceThread.Terminate;
end;

procedure TForm1.cbLtypChange(Sender: TObject);
begin
  Typ[0] := rgL.ItemIndex;
end;

procedure TForm1.cbRTypChange(Sender: TObject);
begin
  Typ[1] := rgR.ItemIndex;
end;

function TForm1.CheckPixel(X, Y: Integer; ABmp: TBitmap): Boolean;
var
  LMask, LByte: Byte;
begin
  LByte := PByte(Integer(@WaveBmp[Y]) + (X div 8))^;
  LMask := $80 shr (X mod 8);
  Result := (LByte and LMask) = 0;
end;

procedure TForm1.seLfreqChange(Sender: TObject);
begin
  Freq[0] := seLfreq.Value;
end;

procedure TForm1.seRfreqChange(Sender: TObject);
begin
  Freq[1] := seRfreq.Value;
end;

procedure TForm1.seLLevChange(Sender: TObject);
begin
  Lev[0] := seLLev.Value;
end;

procedure TForm1.seRLevChange(Sender: TObject);
begin
  Lev[1] := seRLev.Value;
end;

procedure TForm1.WaveFormToLine;
var
  Xcanv, Ycanv, Xwave, Ywave, CanvasLength, CanvasHeight: Integer;
begin
  CanvasLength := pbWave.Width;
  CanvasHeight := pbWave.Height;
  pbWave.Canvas.MoveTo(0, pbWave.Height div 2); // �������� �����
  for Xcanv := 0 to CanvasLength - 1 do
  begin
    Xwave := Round((WaveFormLenght / CanvasLength) * Xcanv);
    Ywave := WaveForm[Xwave];
    Ycanv := Ywave + MAXSHORT; // �������� �����
    Ycanv := Round((CanvasHeight / MAXWORD) * Ycanv); // �������������
    Ycanv := CanvasHeight - Ycanv; // �����������
    pbWave.Canvas.Pen.Color := clRed;
    pbWave.Canvas.Pen.Width := 1;
    pbWave.Canvas.LineTo(Xcanv, Ycanv);
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  ServiceThread.Free;
end;

procedure TForm1.LineToWaveForm;
var
  Xcanv, Ycanv, Xwave, Ywave, CanvasLength, CanvasHeight: Integer;
  LBmpOrigin, LBmpWave: TBitmap;
begin
  LBmpOrigin := TBitmap.Create;
  LBmpWave := TBitmap.Create;
  try
    LBmpOrigin.PixelFormat := pf1bit;
    LBmpWave.PixelFormat := pf1bit;
    LBmpOrigin.SetSize(pbWave.Width, pbWave.Height);
    LBmpWave.SetSize(WaveFormLenght, MAXWORD);

    BitBlt(LBmpOrigin.Canvas.Handle, 0, 0, LBmpOrigin.Width, LBmpOrigin.Height,
      pbWave.Canvas.Handle, 0, 0, SRCCOPY);
    LBmpWave.Canvas.StretchDraw(Rect(0, 0, LBmpWave.Width, LBmpWave.Height),
      LBmpOrigin);
    // Bitmap2.SaveToFile('D:\Temp\tmp.bmp');

    ScanBitmap(LBmpWave);

    Ywave := 0;
    for Xwave := 0 to WaveFormLenght - 1 do
    begin
      WaveForm[Xwave] := Ywave;
      for Ycanv := 0 to MAXWORD - 1 do
      begin
        if CheckPixel(Xwave, Ycanv, LBmpWave) then
        begin
          Ywave := MAXWORD - Ycanv; // �����������
          Ywave := Ywave - MAXSHORT; // �������� ����
          WaveForm[Xwave] := Ywave;
          Break;
        end;
      end;
    end;
  finally
    FreeAndNil(LBmpWave);
    FreeAndNil(LBmpOrigin);
  end;

  exit;

  CanvasLength := pbWave.Width;
  CanvasHeight := pbWave.Height;
  Ywave := 0;
  for Xwave := 0 to WaveFormLenght - 1 do
  begin
    statStatus.Panels[0].Text := IntToStr(Xwave);
    statStatus.Repaint;

    Xcanv := Round((CanvasLength / WaveFormLenght) * Xwave);
    WaveForm[Xwave] := Ywave;
    for Ycanv := 0 to pbWave.Height - 1 do
    begin
      if pbWave.Canvas.Pixels[Xcanv, Ycanv] = PenColor then
      begin
        Ywave := pbWave.Height - Ycanv; // �����������
        Ywave := Round((MAXWORD / CanvasHeight) * Ywave); // �������������
        Ywave := Ywave - MAXSHORT; // �������� ����
        WaveForm[Xwave] := Ywave;
        Break;
      end;
    end;
  end;
end;

procedure TForm1.pbWaveMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FEditingWaveForm := True;
  pbWave.Invalidate;
  Application.ProcessMessages;
  with pbWave.Canvas do
  begin
    Pen.Color := PenColor;
    Pen.Width := 1;
    MoveTo(0, Y);
  end;
end;

procedure TForm1.pbWaveMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if ssLeft in Shift then
  begin
    if X >= pbWave.Canvas.PenPos.X then
      pbWave.Canvas.LineTo(X, Y);
  end;
end;

procedure TForm1.pbWaveMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  pbWave.Canvas.LineTo(pbWave.Width, Y);
  Screen.Cursor := crHourGlass;
  try
    LineToWaveForm;
    pbWave.Repaint;
    WaveFormToLine;
  finally
    Screen.Cursor := crDefault;
  end;
  FEditingWaveForm := False;
end;

procedure TForm1.pbWavePaint(Sender: TObject);
begin
  if not FEditingWaveForm then
    WaveFormToLine;
end;

procedure TForm1.ScanBitmap(ABmp: TBitmap);
var
  LRow, LSize: Integer;
begin
  LSize := ABmp.Width div 8;
  for LRow := 0 to Length(WaveBmp) - 1 do
    CopyMemory(@(WaveBmp[LRow, 0]), ABmp.ScanLine[LRow], LSize);
end;

end.
