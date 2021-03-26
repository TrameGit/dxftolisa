{
DXF to LISA(MECWAY)  Convert DXF 3DFACE to LISA file.
Copyright (C) 2021  Paulo C. Ormonde

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
}
unit lisadxf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  ComCtrls, StdCtrls, ExtCtrls, clisa;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    lbs: TLabeledEdit;
    lpro: TLabel;
    lpro2: TLabel;
    nof: TLabel;
    non: TLabel;
    opendxf: TOpenDialog;
    pbconvread: TProgressBar;
    pbconvwrite: TProgressBar;
    rdx: TRadioButton;
    rdy: TRadioButton;
    rdz: TRadioButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lbsChange(Sender: TObject);
    procedure lbsKeyPress(Sender: TObject; var Key: char);
    procedure rdxChange(Sender: TObject);
    procedure rdyChange(Sender: TObject);
    procedure rdzChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  sf:= strToFloat(lbs.text);
  lbs.Text:=FormatFloat ('0.00',sf);
  nof.Caption:='0';
  non.Caption:='0';
  pbconvread.Position:=0;
  pbconvwrite.Position:=0;

  readdxf(opendxf,pbconvread);

  ion(pbconvread);

  if filedxf <> ' ' then begin

  lisafile:=filedxf + '.liml';
  salvarlisa(pbconvwrite);
  nof.Caption:=IntTostr(nfaces);
  non.Caption:=IntTostr(nnodes);
  end else begin
   showmessage('Invalid file.');
  end;
  showmessage('The file was converted with success!');



end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
    DecimalSeparator:='.';
    wp:=0;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;



procedure TForm1.lbsChange(Sender: TObject);
begin
  lbs.Text:=number(lbs.Text);
end;



procedure TForm1.lbsKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then begin
    sf:= strToFloat(lbs.text);
  lbs.Text:=FormatFloat ('0.00',sf);
  end;
end;

procedure TForm1.rdxChange(Sender: TObject);
begin
  wp:=1;
end;

procedure TForm1.rdyChange(Sender: TObject);
begin
  wp:=2;
end;

procedure TForm1.rdzChange(Sender: TObject);
begin
  wp:=0;
end;



end.

