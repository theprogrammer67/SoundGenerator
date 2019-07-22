program Generator;

uses
  Forms,
  GeneratorUnit in 'GeneratorUnit.pas' {Form1},
  uGenerator in 'uGenerator.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Генератор сигнала';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
