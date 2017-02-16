program KbdT3Help;

uses
  Forms,
  //Dialogs, Windows, Messages,
  MainUnit in 'MainUnit.pas' {MainForm};

{$R *.res}

begin
  if not ClosePrevInstance() then
  begin
    Application.ShowMainForm := false;
    Application.Initialize;
    Application.CreateForm(TMainForm, MainForm);
    Application.Run;
  end;
end.
