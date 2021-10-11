{******************************************************}
{                                                      }
{    Copyright © 2005, Naumenko Anton Aka Antonn.      }
{                     v 1.1                            }
{                   20.10.2005                         }
{                                                      }
{******************************************************}
unit _scanline;

interface

uses
  Windows,Classes,Graphics;

const
  Pixels = MaxInt div SizeOf(TRGBTriple);

type
  PRGBArray = ^TRGBArray;
  TRGBArray = array[0..Pixels-1] of TRGBTriple;

  procedure CopyTransparentBrush(_B_in,_B_out:Tbitmap; _x,_y:integer; trColor:Tcolor); //копирование битмапа с прозрачным цветом
  procedure CopyTransparentBitmap(_B_in,_B_out:Tbitmap; _x,_y:integer; trColor:Tcolor; _transparent:integer); //копирование битмапа с прозрачностью и прозрачным цветом
  procedure CopyTransparentMask(_B_in,_B_out,_B_mask:Tbitmap; _x,_y:integer; trColor:Tcolor);  //копирование битмапа с использованием маски того же размера
  procedure CopyRotateTransparentBrush(_B_in, _B_out: TBitmap; _x,_y,centerX,centerY:integer; trColor:Tcolor; _angle: Double); //вращение битмапа, прозрачный цвет
  procedure CopyRotateTransparentBrushTr(_B_in,_B_out: TBitmap; _x,_y,centerX,centerY:integer; trColor:Tcolor; _transparent:integer; _angle: Double); //вращение битмапа с прозрачным наложением, прозрачный цвет

  procedure DrawTransparentText(_B_out:Tbitmap; _x,_y:integer; font:Tfont; _transparent:integer; _text:string); //рисование прозрачного текста
  procedure DrawTransparentTextRotate(_B_out:Tbitmap; _x,_y:integer; font:Tfont; _transparent:integer; _text:string; _angle:double); //текст под углом(rad), можно с прозрачностью
  procedure Draw_Gradient(Canvas:Tcanvas; _R:Trect; const Color_start,Color_end:Tcolor; _vertical:boolean); //рисование градиента, вертикальный или горизонтальный

  procedure PreparePalitBitmap2colors(_B_out:Tbitmap; trColorStart,trColorEnd:Tcolor); //палитра битмапа м/у 2мя цветами, например черно-зеленая, сине-красная
  procedure PreparePalitBitmapInvert(_B_out:Tbitmap); // инвертирование цвета
  procedure PrepareBitmapBright(_B_out:Tbitmap; _level:real); //яркость, как +, так и -
  procedure PrepareBitmapBW(_B_out:Tbitmap);  //конвертирование битмапа в черно-белый формат
  procedure PrepareBitmapTVmask(_B_out:Tbitmap; _pixel_y,_pixel_dark:integer); //наложение линий, характерных для цифровых видеокамер:)
  procedure PrepareBitmapChanal(_B_out:Tbitmap; _R_persent,_G_persent,_B_persent:integer); //корректировка каналов (RGB) в процентах для каждого отдельно, как +, так и -
  procedure PrepareBitmapBluuum(_B_out:Tbitmap; _persent:integer); //размывание битмапа, оч. тормознутая:)
  procedure PrepareBitmap2colorWithPorog(_B_out:Tbitmap; color1,color2:Tcolor; _persent_level:integer); //двухцветное преобразование, задается уровнем
  procedure PrepareBitmapBWPersent(_B_out:Tbitmap; _persent:integer); //"черно-белость" в процентах
  procedure PrepareBitmapSerpia(_B_out:Tbitmap); //серпия

 // procedure _TextOut(Canvas:Tcanvas; _x,_y:integer; _Width:integer; _text:string; _toback:boolean); //рисует текст(строку), вытягивая по заданой ширине за счет пробелов
 // procedure _TextOutCol(Canvas:Tcanvas; _x,_y:integer; _Width:integer; _text:string); //рисует текст, выводя в колонку с заданой шириной и растягивая по ширине за счет пробелов

implementation

{
Насчет форматирования - кому не нравится, идут лесом:)
}

procedure CopyTransparentBitmap(_B_in,_B_out:Tbitmap; _x,_y:integer; trColor:Tcolor; _transparent:integer);
var x, y, x_cor,y_cor,x_corS,y_corS: Integer; RowOut,RowIn: PRGBArray;
    _r,_b,_g:integer; rc1, bc1, gc1:byte;
begin
 if (_x)>_B_out.Width-1 then exit; if (_x+_B_out.Width)<0 then exit;
 if (_y)>_B_out.Height-1 then exit; if (_y+_B_out.Height)<0 then exit;
  _B_in.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  _B_out.PixelFormat:=pf24bit;//убрать, если изначально этот формат
  if _x<0 then x_corS:=abs(_x) else x_corS:=0;
  if _y<0 then y_corS:=abs(_y) else y_corS:=0;
  if (_x+_B_in.Width)>_B_out.Width then x_cor:=_x+_B_in.Width-_B_out.Width else x_cor:=0;
  if (_y+_B_in.Height)>_B_out.Height then y_cor:=_y+_B_in.Height-_B_out.Height else y_cor:=0;
  rc1:=GetRValue(trColor); gc1:=GetGValue(trColor); bc1:=GetBValue(trColor);
  for y:=y_corS to _B_in.Height-1-y_cor do begin
     RowOut:= _B_out.ScanLine[y+_y];
     RowIn:= _B_in.ScanLine[y];
    for x:=x_corS to _B_in.Width-1-x_cor do
     if not((RowIn[x].rgbtRed=rc1)and(RowIn[x].rgbtGreen=gc1)and(RowIn[x].rgbtBlue=bc1)) then begin
          _r:= trunc(RowOut[x+_x].rgbtRed+(((RowIn[x].rgbtRed-RowOut[x+_x].rgbtRed)/100)*_transparent));
         if _r>255 then _r:=255; if _r<0 then _r:=0;
          _g:= trunc(RowOut[x+_x].rgbtGreen+(((RowIn[x].rgbtGreen-RowOut[x+_x].rgbtGreen)/100)*_transparent));
         if _g>255 then _g:=255; if _g<0 then _g:=0;
          _b:= trunc(RowOut[x+_x].rgbtBlue+(((RowIn[x].rgbtBlue-RowOut[x+_x].rgbtBlue)/100)*_transparent));
         if _b>255 then _b:=255; if _b<0 then _b:=0;
          RowOut[x+_x].rgbtRed:=_r;
          RowOut[x+_x].rgbtGreen:=_g;
          RowOut[x+_x].rgbtBlue:=_b;
    end;
  end
end;

procedure DrawTransparentText(_B_out:Tbitmap; _x,_y:integer; font:Tfont; _transparent:integer; _text:string);
var _F_out:Tbitmap;
begin
 _F_out:=Tbitmap.Create;
 try
 _F_out.PixelFormat:=pf24bit;
 _F_out.Canvas.Font:=font;
 _F_out.Width:=_F_out.Canvas.TextWidth(_text);
 _F_out.Height:=_F_out.Canvas.TextHeight(_text);
 if (_F_out.Width+_x)>_B_out.Width then _F_out.Width:=_B_out.Width-_x;
 if (_F_out.Height+_y)>_B_out.Height then _F_out.Height:=_B_out.Height-_y;
 _F_out.Canvas.Brush.Color:=font.Color+1;
 _F_out.Canvas.TextOut(0,0,_text);
   CopyTransparentBitmap(_F_out,_B_out, _x,_y,font.Color+1, _transparent);
 finally
 _F_out.Free;
 end;
end;

procedure PreparePalitBitmap2colors(_B_out:Tbitmap; trColorStart,trColorEnd:Tcolor);
var x, y: Integer; RowOut: PRGBArray;
    _r,_b,_g,rc1, bc1, gc1,rc2, bc2, gc2:integer;
begin
  _B_out.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  rc1:=GetRValue(trColorStart); gc1:=GetGValue(trColorStart); bc1:=GetBValue(trColorStart);
  rc2:=GetRValue(trColorEnd); gc2:=GetGValue(trColorEnd); bc2:=GetBValue(trColorEnd);
  for y:=0 to _B_out.Height-1 do begin
     RowOut:= _B_out.ScanLine[y];
    for x:=0 to _B_out.Width-1 do begin
          _r:=trunc(rc1+(RowOut[x].rgbtRed/255)*(rc2-rc1));
         if _r>255 then _r:=255; if _r<0 then _r:=0;
          _g:=trunc(gc1+(RowOut[x].rgbtGreen/255)*(gc2-gc1));
         if _g>255 then _g:=255; if _g<0 then _g:=0;
          _b:=trunc(bc1+(RowOut[x].rgbtBlue/255)*(bc2-bc1));
         if _b>255 then _b:=255; if _b<0 then _b:=0;
          RowOut[x].rgbtRed:=_r;
          RowOut[x].rgbtGreen:=_g;
          RowOut[x].rgbtBlue:=_b;
    end;
  end
end;

procedure PreparePalitBitmapInvert(_B_out:Tbitmap);
var x, y: Integer; RowOut: PRGBArray;
begin
  _B_out.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  for y:=0 to _B_out.Height-1 do begin
     RowOut:= _B_out.ScanLine[y];
    for x:=0 to _B_out.Width-1 do begin
          RowOut[x].rgbtRed:=(255-RowOut[x].rgbtRed);
          RowOut[x].rgbtGreen:=255-RowOut[x].rgbtGreen;
          RowOut[x].rgbtBlue:=(255-RowOut[x].rgbtBlue);
    end;
  end
end;

procedure PrepareBitmapBright(_B_out:Tbitmap; _level:real); 
var x, y: Integer; RowOut: PRGBArray;
    _r,_b,_g:integer;
begin
  _B_out.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  for y:=0 to _B_out.Height-1 do begin
     RowOut:= _B_out.ScanLine[y];
    for x:=0 to _B_out.Width-1 do begin
          _r:=trunc(RowOut[x].rgbtRed+(RowOut[x].rgbtRed/100)*_level);
         if _r>255 then _r:=255; if _r<0 then _r:=0;
          _g:=trunc(RowOut[x].rgbtGreen+(RowOut[x].rgbtGreen/100)*_level);
         if _g>255 then _g:=255; if _g<0 then _g:=0;
          _b:=trunc(RowOut[x].rgbtBlue+(RowOut[x].rgbtBlue/100)*_level);
         if _b>255 then _b:=255; if _b<0 then _b:=0;
          RowOut[x].rgbtRed:=_r;
          RowOut[x].rgbtGreen:=_g;
          RowOut[x].rgbtBlue:=_b;
    end;
  end
end;

procedure PrepareBitmapBW(_B_out:Tbitmap); //ну нету тут веса цветов!..
var x, y: Integer; RowOut: PRGBArray;
    _s:integer;
begin
  _B_out.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  for y:=0 to _B_out.Height-1 do begin
     RowOut:= _B_out.ScanLine[y];
    for x:=0 to _B_out.Width-1 do begin
          _s:=trunc((RowOut[x].rgbtRed+RowOut[x].rgbtGreen+RowOut[x].rgbtBlue)/3);
         if _s>255 then _s:=255; if _s<0 then _s:=0;
          RowOut[x].rgbtRed:=_s;
          RowOut[x].rgbtGreen:=_s;
          RowOut[x].rgbtBlue:=_s;
    end;
  end
end;

procedure PrepareBitmapTVmask(_B_out:Tbitmap; _pixel_y,_pixel_dark:integer);
var x, y: Integer; RowOut: PRGBArray;
    _r,_b,_g:integer;
begin
  _B_out.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  for y:=0 to _B_out.Height-1 do begin
     RowOut:= _B_out.ScanLine[y];
    for x:=0 to _B_out.Width-1 do begin 
    if trunc((y div _pixel_y)/2)<>((y div _pixel_y)/2) then  begin
          _r:=RowOut[x].rgbtRed;
          _g:=RowOut[x].rgbtGreen;
          _b:=RowOut[x].rgbtBlue;
    end else begin
          _r:=trunc(RowOut[x].rgbtRed-(RowOut[x].rgbtRed/100)*_pixel_dark);
         if _r>255 then _r:=255; if _r<0 then _r:=0;
          _g:=trunc(RowOut[x].rgbtGreen-(RowOut[x].rgbtGreen/100)*_pixel_dark);
         if _g>255 then _g:=255; if _g<0 then _g:=0;
          _b:=trunc(RowOut[x].rgbtBlue-(RowOut[x].rgbtBlue/100)*_pixel_dark);
         if _b>255 then _b:=255; if _b<0 then _b:=0;
    end;
          RowOut[x].rgbtRed:=_r;
          RowOut[x].rgbtGreen:=_g;
          RowOut[x].rgbtBlue:=_b;
    end;
  end
end;

procedure CopyTransparentMask(_B_in,_B_out,_B_mask:Tbitmap; _x,_y:integer; trColor:Tcolor);
var x, y: Integer; RowOut,RowIn,RowMask: PRGBArray;
    _r,_b,_g:integer; rc1, bc1, gc1:byte;
begin
 if (_x+_B_in.Width)>_B_out.Width then exit; if _x<0 then exit;
 if (_y+_B_in.Height)>_B_out.Height then exit; if _y<0 then exit;
  _B_in.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  _B_out.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  _B_mask.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  rc1:=GetRValue(trColor); gc1:=GetGValue(trColor); bc1:=GetBValue(trColor);
  for y:=0 to _B_in.Height-1 do begin
     RowOut:= _B_out.ScanLine[y+_y];
     RowIn:= _B_in.ScanLine[y];
     RowMask:= _B_mask.ScanLine[y];
    for x:=0 to _B_in.Width-1 do 
     if not((RowIn[x].rgbtRed=rc1)and(RowIn[x].rgbtGreen=gc1)and(RowIn[x].rgbtBlue=bc1)) then begin
          _r:= trunc(RowOut[x+_x].rgbtRed+((((RowIn[x].rgbtRed)-RowOut[x+_x].rgbtRed)/100)*(RowMask[x].rgbtRed*100/255)));
         if _r>255 then _r:=255; if _r<0 then _r:=0;
          _g:= trunc(RowOut[x+_x].rgbtGreen+(((RowIn[x].rgbtGreen-RowOut[x+_x].rgbtGreen)/100)*(RowMask[x].rgbtGreen*100/255)));
         if _g>255 then _g:=255; if _g<0 then _g:=0;
          _b:= trunc(RowOut[x+_x].rgbtBlue+(((RowIn[x].rgbtBlue-RowOut[x+_x].rgbtBlue)/100)*(RowMask[x].rgbtBlue*100/255)));
         if _b>255 then _b:=255; if _b<0 then _b:=0;
          RowOut[x+_x].rgbtRed:=_r;
          RowOut[x+_x].rgbtGreen:=_g;
          RowOut[x+_x].rgbtBlue:=_b;
    end;
  end
end;

procedure Draw_Gradient(canvas:Tcanvas; _R:Trect; const Color_start,Color_end:Tcolor; _vertical:boolean );
var _F_shadow_Bitmap:Tbitmap; x, y,  b: Integer; Row1: PRGBArray;
rc1, rc2, gc1, gc2, bc1, bc2:integer;
begin
_F_shadow_Bitmap:=Tbitmap.Create;
try
 _F_shadow_Bitmap.PixelFormat:=pf24bit;
 if _vertical then begin
 _F_shadow_Bitmap.Width:=1;
 _F_shadow_Bitmap.Height:=_R.Bottom-_R.Top;
   end else begin
 _F_shadow_Bitmap.Width:=_R.Right-_R.Left;
 _F_shadow_Bitmap.Height:=1;
 end;
  rc1 := GetRValue(Color_start); gc1 := GetGValue(Color_start); bc1 := GetBValue(Color_start);
  rc2 := GetRValue(Color_end); gc2 := GetGValue(Color_end); bc2 := GetBValue(Color_end);
if not(_vertical) then  b:=_F_shadow_Bitmap.Width else b:=_F_shadow_Bitmap.Height;
  for Y := 0 to _F_shadow_Bitmap.Height - 1 do begin
     Row1:= _F_shadow_Bitmap.ScanLine[y];
    for x := 0 to _F_shadow_Bitmap.Width -1 do begin
       case _vertical of
        false: begin
          Row1[x].rgbtRed:=round( rc1 +(rc2-rc1)*( (x+1)/b ));
          Row1[x].rgbtGreen:=round(gc1+ (gc2-gc1)*( (x+1)/b ));
          Row1[x].rgbtBlue:=round( bc1+(bc2-bc1)*( (x+1)/b ));end;
        true: begin
          Row1[x].rgbtRed:=round( rc1 +(rc2-rc1)*( (y+1)/b ));
          Row1[x].rgbtGreen:=round(gc1+ (gc2-gc1)*( (y+1)/b ));
          Row1[x].rgbtBlue:=round( bc1+(bc2-bc1)*( (y+1)/b ));end;
       end;
    end;
  end;
 canvas.CopyRect(_r,_F_shadow_Bitmap.Canvas,_F_shadow_Bitmap.Canvas.ClipRect);
finally
_F_shadow_Bitmap.Free;
end;
end;

procedure PrepareBitmapChanal(_B_out:Tbitmap; _R_persent,_G_persent,_B_persent:integer);
var x, y: Integer; RowOut: PRGBArray;
    _r,_b,_g:integer;
begin
  _B_out.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  for y:=0 to _B_out.Height-1 do begin
     RowOut:= _B_out.ScanLine[y];
    for x:=0 to _B_out.Width-1 do begin
          _r:=trunc(RowOut[x].rgbtRed-(RowOut[x].rgbtRed/100)*_R_persent);
         if _r>255 then _r:=255; if _r<0 then _r:=0;
          _g:=trunc(RowOut[x].rgbtGreen-(RowOut[x].rgbtGreen/100)*_G_persent);
         if _g>255 then _g:=255; if _g<0 then _g:=0;
          _b:=trunc(RowOut[x].rgbtBlue-(RowOut[x].rgbtBlue/100)*_B_persent);
         if _b>255 then _b:=255; if _b<0 then _b:=0;
          RowOut[x].rgbtRed:=_r;
          RowOut[x].rgbtGreen:=_g;
          RowOut[x].rgbtBlue:=_b;
    end;
  end
end;

procedure PrepareBitmapBluuum(_B_out:Tbitmap; _persent:integer);
var x, y,xi,yi: Integer; RowOut,RowMask: PRGBArray;
    _r,_b,_g:integer;  _F_out:TBitmap;
begin
  _F_out:=Tbitmap.Create;
 try
  _B_out.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  _F_out.PixelFormat:=pf24bit;
  _F_out.Width:=_B_out.Width;
  _F_out.Height:=_B_out.Height;
  BitBlt(_F_out.Canvas.Handle,0,0,_F_out.Width,_F_out.Height,_B_out.Canvas.Handle,0,0,SRCCOPY);

  for y:=_persent to _B_out.Height-1-_persent do begin
     RowOut:= _B_out.ScanLine[y];
    for x:=_persent to _B_out.Width-1-_persent do begin
         _r:=0; _g:=0; _b:=0;
         for yi:=-_persent to _persent do begin
          RowMask:= _F_out.ScanLine[yi+y];
          for xi:=-_persent to _persent do begin
          _r:=_r+RowMask[xi+x].rgbtRed;
          _g:=_g+RowMask[xi+x].rgbtGreen;
          _b:=_b+RowMask[xi+x].rgbtBlue;
         end; end;

         _r:=trunc(_r/sqr(_persent*2+1));
         _g:=trunc(_g/sqr(_persent*2+1));
         _b:=trunc(_b/sqr(_persent*2+1));

        if _r>255 then _r:=255; if _r<0 then _r:=0;
        if _g>255 then _g:=255; if _g<0 then _g:=0;
        if _b>255 then _b:=255; if _b<0 then _b:=0;

          RowOut[x].rgbtRed:=_r;
          RowOut[x].rgbtGreen:=_g;
          RowOut[x].rgbtBlue:=_b;
    end;
  end
 finally
  _F_out.free;
 end;
end;

procedure PrepareBitmap2colorWithPorog(_B_out:Tbitmap; color1,color2:Tcolor; _persent_level:integer);
var x, y: Integer; RowOut: PRGBArray;
   rc1, bc1, gc1,rc2, bc2, gc2:integer;
begin
  _B_out.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  rc1:=GetRValue(color1); gc1:=GetGValue(color1); bc1:=GetBValue(color1);
  rc2:=GetRValue(color2); gc2:=GetGValue(color2); bc2:=GetBValue(color2);
  for y:=0 to _B_out.Height-1 do begin
     RowOut:= _B_out.ScanLine[y];
    for x:=0 to _B_out.Width-1 do begin
       if ((RowOut[x].rgbtRed+RowOut[x].rgbtGreen+RowOut[x].rgbtBlue)/3)>(_persent_level*255/100) then begin
          RowOut[x].rgbtRed:=rc1;
          RowOut[x].rgbtGreen:=gc1;
          RowOut[x].rgbtBlue:=bc1; end else begin
          RowOut[x].rgbtRed:=rc2;
          RowOut[x].rgbtGreen:=gc2;
          RowOut[x].rgbtBlue:=bc2;
       end;
    end;
  end
end;

procedure CopyTransparentBrush(_B_in,_B_out:Tbitmap; _x,_y:integer; trColor:Tcolor);
var x, y, x_cor,y_cor,x_corS,y_corS: Integer; RowOut,RowIn: PRGBArray;
    rc1, bc1, gc1:byte;
begin
 if (_x)>_B_out.Width-1 then exit; if (_x+_B_out.Width)<0 then exit;
 if (_y)>_B_out.Height-1 then exit; if (_y+_B_out.Height)<0 then exit;
  _B_in.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  _B_out.PixelFormat:=pf24bit;  //убрать, если изначально этот формат
  if _x<0 then x_corS:=abs(_x) else x_corS:=0;
  if _y<0 then y_corS:=abs(_y) else y_corS:=0;
  if (_x+_B_in.Width)>_B_out.Width then x_cor:=_x+_B_in.Width-_B_out.Width else x_cor:=0;
  if (_y+_B_in.Height)>_B_out.Height then y_cor:=_y+_B_in.Height-_B_out.Height else y_cor:=0;
  rc1:=GetRValue(trColor); gc1:=GetGValue(trColor); bc1:=GetBValue(trColor);
  for y:=y_corS to _B_in.Height-1-y_cor do begin
     RowOut:= _B_out.ScanLine[y+_y];
     RowIn:= _B_in.ScanLine[y];
    for x:=x_corS to _B_in.Width-1-x_cor do
     if not((RowIn[x].rgbtRed=rc1)and(RowIn[x].rgbtGreen=gc1)and(RowIn[x].rgbtBlue=bc1)) then begin
          RowOut[x+_x]:=RowIn[x];
    end;
  end
end;

procedure CopyRotateTransparentBrush(_B_in,_B_out: TBitmap; _x,_y,centerX,centerY:integer; trColor:Tcolor; _angle: Double);
var cosRadians,_Rad,sinRadians : Double;
  x,y,x_cor,y_cor,x_corS,y_corS,inXOut,inXPr,inXRotated,inYOut,inYPr,inYRotated: Integer;
  RowOut, RowIn: PRGBArray;
  rc1, bc1, gc1:byte;
begin
  if (_x)>_B_out.Width-1 then exit; if (_x+_B_out.Width)<0 then exit;
  if (_y)>_B_out.Height-1 then exit; if (_y+_B_out.Height)<0 then exit;
  _B_in.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  _B_out.PixelFormat:=pf24bit;  //убрать, если изначально этот формат
  _Rad:=_angle; sinRadians:=Sin(_Rad); cosRadians:=Cos(_Rad);
  if _x<0 then x_corS:=abs(_x) else x_corS:=0;
  if _y<0 then y_corS:=abs(_y) else y_corS:=0;
  if (_x+_B_in.Width)>_B_out.Width then x_cor:=_x+_B_in.Width-_B_out.Width else x_cor:=0;
  if (_y+_B_in.Height)>_B_out.Height then y_cor:=_y+_B_in.Height-_B_out.Height else y_cor:=0;
  rc1:=GetRValue(trColor); gc1:=GetGValue(trColor); bc1:=GetBValue(trColor);
  for x:=_B_in.Height-1-y_cor downto y_corS do begin
    RowIn:=_B_out.Scanline[x+_y]; inXPr:=2*(x-centerY)+1;
    for y:=_B_in.Width-1-x_cor downto x_corS do begin
      inYPr:=2*(y-centerX)+1;
      inYRotated:=Round(inYPr*CosRadians-inXPr*sinRadians); inXRotated:=Round(inYPr*sinRadians+inXPr*cosRadians);
      inYOut:=(inYRotated-1) div 2 + centerX; inXOut:=(inXRotated-1) div 2 + centerY;
      if (inYOut>=0)and(inYOut<=_B_in.Width-1) and
      (inXOut>=0)and(inXOut<=_B_in.Height-1) then begin
        RowOut:=_B_in.Scanline[inXOut];
     if not((RowOut[inYOut].rgbtRed=rc1)and(RowOut[inYOut].rgbtGreen=gc1)and(RowOut[inYOut].rgbtBlue=bc1)) then
        RowIn[y+_x] := RowOut[inYOut];
      end;
    end;
  end;
end;

procedure CopyRotateTransparentBrushTr(_B_in,_B_out: TBitmap; _x,_y,centerX,centerY:integer; trColor:Tcolor; _transparent:integer; _angle: Double);
var cosRadians,_Rad,sinRadians : Double;
  x,y,x_cor,y_cor,x_corS,y_corS,inXOut,inXPr,inXRotated,inYOut,inYPr,inYRotated: Integer;
  RowOut, RowIn: PRGBArray;
  rc1, bc1, gc1:byte; _r,_b,_g:integer;
begin
  if (_x)>_B_out.Width-1 then exit; if (_x+_B_out.Width)<0 then exit;
  if (_y)>_B_out.Height-1 then exit; if (_y+_B_out.Height)<0 then exit;
  _B_in.PixelFormat:=pf24bit; //убрать, если изначально этот формат
  _B_out.PixelFormat:=pf24bit;  //убрать, если изначально этот формат
  _Rad:=_angle; sinRadians:=Sin(_Rad); cosRadians:=Cos(_Rad);
  if _x<0 then x_corS:=abs(_x) else x_corS:=0;
  if _y<0 then y_corS:=abs(_y) else y_corS:=0;
  if (_x+_B_in.Width)>_B_out.Width then x_cor:=_x+_B_in.Width-_B_out.Width else x_cor:=0;
  if (_y+_B_in.Height)>_B_out.Height then y_cor:=_y+_B_in.Height-_B_out.Height else y_cor:=0;
  rc1:=GetRValue(trColor); gc1:=GetGValue(trColor); bc1:=GetBValue(trColor);
  for x:=_B_in.Height-1-y_cor downto y_corS do begin
    RowIn:=_B_out.Scanline[x+_y]; inXPr:=2*(x-centerY)+1;
    for y:=_B_in.Width-1-x_cor downto x_corS do begin
      inYPr:=2*(y-centerX)+1;
      inYRotated:=Round(inYPr*CosRadians-inXPr*sinRadians); inXRotated:=Round(inYPr*sinRadians+inXPr*cosRadians);
      inYOut:=(inYRotated-1) div 2 + centerX; inXOut:=(inXRotated-1) div 2 + centerY;
      if (inYOut>=0)and(inYOut<=_B_in.Width-1) and
      (inXOut>=0)and(inXOut<=_B_in.Height-1) then begin
        RowOut:=_B_in.Scanline[inXOut];
     if not((RowOut[inYOut].rgbtRed=rc1)and(RowOut[inYOut].rgbtGreen=gc1)and(RowOut[inYOut].rgbtBlue=bc1)) then begin
        _r:= trunc(RowIn[y+_x].rgbtRed+(((RowOut[inYOut].rgbtRed-RowIn[y+_x].rgbtRed)/100)*_transparent));
         if _r>255 then _r:=255 else if _r<0 then _r:=0;
         _g:= trunc(RowIn[y+_x].rgbtGreen+(((RowOut[inYOut].rgbtGreen-RowIn[y+_x].rgbtGreen)/100)*_transparent));
         if _g>255 then _g:=255 else if _g<0 then _g:=0;
         _b:= trunc(RowIn[y+_x].rgbtBlue+(((RowOut[inYOut].rgbtBlue-RowIn[y+_x].rgbtBlue)/100)*_transparent));
         if _b>255 then _b:=255 else if _b<0 then _b:=0;
        RowIn[y+_x].rgbtRed:=_r;
        RowIn[y+_x].rgbtGreen:=_g;
        RowIn[y+_x].rgbtBlue:=_b;
        end;
      end;
    end;
  end;
end;

procedure DrawTransparentTextRotate(_B_out:Tbitmap; _x,_y:integer; font:Tfont; _transparent:integer; _text:string; _angle:double);
var _F_out:Tbitmap;
begin
 _F_out:=Tbitmap.Create;
 try
 _F_out.Canvas.Font:=font;
 _F_out.PixelFormat:=pf24bit;
 _F_out.Width:=_F_out.Canvas.TextWidth(_text)+trunc(_F_out.Canvas.TextWidth(_text)*0.2);
 _F_out.Height:=_F_out.Width;
 _F_out.Canvas.Brush.Color:=font.Color+1;
 _F_out.Canvas.FillRect(rect(0,0,_F_out.Width,_F_out.Height));
 _F_out.Canvas.TextOut((_F_out.Width-_F_out.Canvas.TextWidth(_text)) div 2,(_F_out.Height-_F_out.Canvas.TextHeight(_text)) div 2,_text);
 if _transparent=100 then  //оптимизейшн:)
  CopyRotateTransparentBrush(_F_out,_B_out,_x,_y,_F_out.Width div 2,_F_out.Height div 2,font.Color+1,_angle) else
  CopyRotateTransparentBrushTr(_F_out,_B_out,_x,_y,_F_out.Width div 2,_F_out.Height div 2,font.Color+1,_transparent,_angle);
 finally
 _F_out.Free;
 end;
end;

procedure PrepareBitmapBWPersent(_B_out:Tbitmap; _persent:integer);
var x, y: Integer; RowOut: PRGBArray;
    _r,_b,_g,_summ:integer;
begin
  _B_out.PixelFormat:=pf24bit;
  for y:=0 to _B_out.Height-1 do begin
     RowOut:= _B_out.ScanLine[y];
    for x:=0 to _B_out.Width-1 do begin
         _summ:=trunc((RowOut[x].rgbtRed+RowOut[x].rgbtGreen+RowOut[x].rgbtBlue)/3);
          _r:=RowOut[x].rgbtRed-round((RowOut[x].rgbtRed-_summ)*_persent/100);
         if _r>255 then _r:=255; if _r<0 then _r:=0;
          _g:=RowOut[x].rgbtGreen-round((RowOut[x].rgbtGreen-_summ)*_persent/100);
         if _g>255 then _g:=255; if _g<0 then _g:=0;
          _b:=RowOut[x].rgbtBlue-round((RowOut[x].rgbtBlue-_summ)*_persent/100);
         if _b>255 then _b:=255; if _b<0 then _b:=0;
          RowOut[x].rgbtRed:=_r;
          RowOut[x].rgbtGreen:=_g;
          RowOut[x].rgbtBlue:=_b;
    end;
  end
end;

procedure PrepareBitmapSerpia(_B_out:Tbitmap);
var x, y: Integer; RowOut: PRGBArray;
    _r,_b,_g:integer;
begin
  _B_out.PixelFormat:=pf24bit;
  for y:=0 to _B_out.Height-1 do begin
     RowOut:= _B_out.ScanLine[y];
    for x:=0 to _B_out.Width-1 do begin
          _r:=trunc( RowOut[x].rgbtRed*0.393+RowOut[x].rgbtGreen*0.769+RowOut[x].rgbtBlue*0.189);
         if _r>255 then _r:=255; if _r<0 then _r:=0;
          _g:=trunc( RowOut[x].rgbtRed*0.349+RowOut[x].rgbtGreen*0.686+RowOut[x].rgbtBlue*0.168);
         if _g>255 then _g:=255; if _g<0 then _g:=0;
          _b:=trunc( RowOut[x].rgbtRed*0.272+RowOut[x].rgbtGreen*0.534+RowOut[x].rgbtBlue*0.131);
         if _b>255 then _b:=255; if _b<0 then _b:=0;
          RowOut[x].rgbtRed:=_r;
          RowOut[x].rgbtGreen:=_g;
          RowOut[x].rgbtBlue:=_b;
    end;
  end
end;

end.
