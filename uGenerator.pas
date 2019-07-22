unit uGenerator;

interface

uses Winapi.Windows;

const
  WAVE_LENGHT = 512;
  DEF_DISCRFREQ = 44100;

type
  TWaveBuf = array [0 .. WAVE_LENGHT - 1] of Double;

  TGenerator = class
  private
    FFrequency: Double;
    FDiscrFreq: Double;
    FPosition: Double;
  public
    WaveBuf: TWaveBuf;
  public
    constructor Create;
    destructor Destroy; override;
    function GetNextValue: Double;
    procedure Reset;
    procedure Assign(ASource: TGenerator);
  public
    property Frequency: Double read FFrequency write FFrequency;
    property DiscrFreq: Double read FDiscrFreq write FDiscrFreq;
//    property Position: Double read FPosition write FPosition;
  end;

implementation

{ TGenerator }

procedure TGenerator.Assign(ASource: TGenerator);
begin
  FFrequency := ASource.Frequency;
  FDiscrFreq := ASource.DiscrFreq;
  MoveMemory(@WaveBuf[0], @ASource.WaveBuf[0], SizeOf(TWaveBuf));
end;

constructor TGenerator.Create;
begin
  Reset;
  ZeroMemory(@WaveBuf[0], SizeOf(TWaveBuf));
  FDiscrFreq := DEF_DISCRFREQ;
end;

destructor TGenerator.Destroy;
begin

  inherited;
end;

function TGenerator.GetNextValue: Double;
begin
  Result := WaveBuf[Trunc(FPosition * WAVE_LENGHT)];
  FPosition := Frac(FFrequency / FDiscrFreq + FPosition); // дробная часть
end;

procedure TGenerator.Reset;
begin
  FPosition := 0;
end;

end.
