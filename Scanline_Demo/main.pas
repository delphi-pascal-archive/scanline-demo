unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,_scanline, StdCtrls, ExtCtrls, ComCtrls;

type
  Tmainform = class(TForm)
    Image1: TImage;
    Button1: TButton;
    Image2: TImage;
    Image3: TImage;
    Timer1: TTimer;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    GroupBox1: TGroupBox;
    TrackBar2: TTrackBar;
    Edit1: TEdit;
    Label1: TLabel;
    CheckBox6: TCheckBox;
    ComboBox1: TComboBox;
    ColorBox1: TColorBox;
    GroupBox2: TGroupBox;
    TrackBar1: TTrackBar;
    CheckBox5: TCheckBox;
    Button2: TButton;
    Image4: TImage;
    Button3: TButton;
    GroupBox3: TGroupBox;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    TrackBar5: TTrackBar;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    Button7: TButton;
    GroupBox4: TGroupBox;
    TrackBar6: TTrackBar;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ColorBox1Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
    procedure CheckBox6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  mainform: Tmainform;

implementation

{$R *.dfm}

procedure Tmainform.Button1Click(Sender: TObject);
begin
 CopyTransparentBrush( Image1.Picture.Bitmap,Image2.Picture.Bitmap,10,20,clblack );
 Image2.Repaint;
end;

procedure Tmainform.Timer1Timer(Sender: TObject);
begin
 image3.Picture.Bitmap.Canvas.CopyRect(rect(0,0,image3.Width,image3.Height),Image2.Picture.Bitmap.Canvas,rect(0,0,image3.Width,image3.Height));

 if CheckBox3.Checked then
 PrepareBitmapBW(image3.Picture.Bitmap);

 if CheckBox1.Checked then
 PreparePalitBitmap2colors(image3.Picture.Bitmap,cllime,clblack);

 if CheckBox8.Checked then
  PrepareBitmapBluuum(image3.Picture.Bitmap,1);

 if CheckBox2.Checked then
  PreparePalitBitmapInvert(image3.Picture.Bitmap);

 if CheckBox7.Checked then
  PrepareBitmapChanal(Image3.Picture.Bitmap,TrackBar3.Position-100,TrackBar4.Position-100,TrackBar5.Position-100);

 if CheckBox5.Checked then
 PrepareBitmapBright(image3.Picture.Bitmap,TrackBar1.Position-100);

 if CheckBox4.Checked then
 PrepareBitmapTVmask(image3.Picture.Bitmap,1,100);

 if CheckBox6.Checked then
 DrawTransparentText(Image3.Picture.Bitmap,10,50,label1.Font,TrackBar2.Position,Edit1.Text);

 if CheckBox9.Checked then
 PrepareBitmapBWPersent(Image3.Picture.Bitmap,TrackBar6.Position);

 if CheckBox10.Checked then
 PrepareBitmapSerpia(Image3.Picture.Bitmap);

 image3.Repaint;
end;

procedure Tmainform.ColorBox1Change(Sender: TObject);
begin
label1.Font.Color:=ColorBox1.Selected;
Timer1Timer(nil);
end;

procedure Tmainform.ComboBox1Change(Sender: TObject);
begin
label1.Font.Size:=ComboBox1.ItemIndex*2+6;
Timer1Timer(nil);
end;

procedure Tmainform.Button2Click(Sender: TObject);
begin
CopyTransparentMask( Image1.Picture.Bitmap,Image2.Picture.Bitmap,Image4.Picture.Bitmap,128,20,clblack);
Image2.Repaint;
end;

procedure Tmainform.Button3Click(Sender: TObject);
begin
Draw_Gradient(Image3.Picture.Bitmap.Canvas,Image2.Picture.Bitmap.Canvas.ClipRect,clgreen,clblack,false);
end;

procedure Tmainform.TrackBar1Change(Sender: TObject);
begin
Timer1Timer(nil);
end;

procedure Tmainform.FormCreate(Sender: TObject);
begin
 image3.Picture.Bitmap.Width:=image2.Width;
 image3.Picture.Bitmap.Height:=image2.Height;
 image3.Picture.Bitmap.Canvas.CopyRect(rect(0,0,image3.Width,image3.Height),Image2.Picture.Bitmap.Canvas,rect(0,0,image3.Width,image3.Height));
end;

procedure Tmainform.TrackBar2Change(Sender: TObject);
begin
 Timer1Timer(nil);
end;

procedure Tmainform.Edit1Change(Sender: TObject);
begin
 Timer1Timer(nil);
end;

procedure Tmainform.CheckBox4Click(Sender: TObject);
begin
 Timer1Timer(nil);
end;

procedure Tmainform.CheckBox3Click(Sender: TObject);
begin
 Timer1Timer(nil);
end;

procedure Tmainform.CheckBox2Click(Sender: TObject);
begin
 Timer1Timer(nil);
end;

procedure Tmainform.CheckBox1Click(Sender: TObject);
begin
 Timer1Timer(nil);
end;

procedure Tmainform.CheckBox5Click(Sender: TObject);
begin
 Timer1Timer(nil);
end;
          
procedure Tmainform.CheckBox6Click(Sender: TObject);
begin
 Timer1Timer(nil);
end;

procedure Tmainform.Button7Click(Sender: TObject);
begin
 DrawTransparentTextRotate(Image2.Picture.Bitmap,50,50,label1.Font,100,'Test',pi/8);
 Image2.Repaint;
end;

end.
