program sc;

uses
  Forms,
  main in 'main.pas' {mainform};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tmainform, mainform);
  Application.Run;
end.
