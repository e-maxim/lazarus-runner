unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}
{$R .\images.rc}

{ TForm1 }

procedure TForm1.FormShow(Sender: TObject);
begin
  Image1.Picture.LoadFromResourceName(HINSTANCE, 'TESTICON');
end;

end.

