{Copyright (C) 2004 Christian Speckner

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by 
the Free Software Foundation; either version 2 of the License, or 
(at your option) any later version.

This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License (file "LICENSE") for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software Foundation,
Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA}

{------------unit 'graphcore'-------------

acts as a wrapper for SDL and provides the basic classes for video hardware access
as well es some helper functions

------------------------------------------}

unit graphcore;

interface

uses SDL, SDL_Video, SDL_Types, Strings, AmoebaDebug;

Type

TRGBData = record
  R,G,B: Uint8;
end;

TRGBAData = record
  R,G,B,A: Uint8;
end;

TPixels = array[0..0] of uInt16;
TSurfaceFlags = (HW_Surface, SW_Surface, Async_Blit, CC_Blit, Alpha_Blit);
TSurfaceFlagSet = set of TSurfaceFlags;

{The following is ugly, but necessary to avoid a circular dependence between Fonts und GraphCore
('necessary' in this context means I couldn't think of anything prettier to avoid this). This means:
A prototype of TFont is defined here which only contains the methods necessary for TSDL_Surface as
abstracts; implemetation is done in Fonts}

TSDL_Surface = class;

TFont_Proto = class

public
  
   function RenderText_Shaded(text: PChar; fg, bg: SDL_Color): TSDL_Surface; virtual; abstract; overload;
   function RenderText_Shaded(text: String; fg, bg: SDL_Color): TSDL_Surface; virtual; abstract; overload;
   
end;


TSDL_Surface = class

protected

  NeedsLock: Boolean;
  pixels: ^TPixels;
  PFlags: TSurfaceFlagSet;
  PSurface: PSDL_Surface;
  PInstantUpdate: Boolean;

  procedure PPutRGBPixel(x,y: Uint16; Color: TRGBData);
  procedure PPutRGBAPixel(x,y: Uint16; Color: TRGBAData);
  procedure PPutRAWPixel(x,y: Uint16; Color: Uint32);
  procedure SetRAWPixel(x, y: Uint16; Color: Uint32); inline;

  procedure GrabFlags;

  function PGetRGBPixel(x,y: Uint16): TRGBData;
  function PGetRGBAPixel(x,y: Uint16): TRGBAData;
  function PGetRAWPixel(x,y: Uint16): Uint32;


public

  property surface: PSDL_Surface read PSurface;
  property RGBPixels[x,y: Uint16]: TRGBData read PGetRGBPixel write PPutRGBPixel;
  property RGBAPixels[x,y: Uint16]: TRGBAData read PGetRGBAPixel write PPutRGBAPixel;
  property RAWPixels[x,y: Uint16]: Uint32 read PGetRAWPixel write PPutRawPixel;
  property Flags: TSurfaceFlagSet read PFlags;
  property InstantUpdate: Boolean read PInstantUpdate write PInstantUpdate;

  procedure BlitFrom(s: TSDL_Surface; o: PSDL_Rect; x,y: Sint16);
  procedure Convert2DisplayFormat;
  procedure SetColorKey(key: Uint32);
  procedure ClearColorKey;
  procedure UpdateScreen; overload;
  procedure UpdateScreen(x, y, w, h: Uint16); overload;
  procedure Clear; overload;
  procedure Clear(r, g, b: Uint8); overload;
  procedure PrintText_Shaded(data: String; x, y: Uint16; fr, fg, fb, br, bg, bb: Uint8; font: TFont_proto);
  procedure FillRect(x, y, w, h: Uint16; r, g, b: Uint8);
  procedure Line(x1, y1, x2, y2: Uint16; r, g, b: Uint8);
  function SpawnSurface(w, h: Uint16; flags: TSurfaceFlagSet): TSDL_Surface; overload;
  function SpawnSurface(flags: TSurfaceFlagSet): TSDL_Surface; overload;
  function MapRGB(R,G,B: Uint8): Uint32;

  constructor CreateFromSurface(s: PSDL_Surface);
  destructor Destroy; override;

end;

function AsSDL_Rect(x,y: Sint16; w,h: Uint16): SDL_Rect;
function RGB(R, G, B: Uint16): TRGBData;
function SDL_RGB(r, g, b: Uint8): SDL_Color;


implementation

uses fonts;


{--------------misc helper functions-------------}

function SDL_RGB(r, g, b: Uint8): SDL_Color;
begin
  result.r := r;
  result.g := g;
  result.b := b;
end;

function AsSDL_Rect(x,y: Sint16; w,h: Uint16): SDL_Rect;
begin
  result.x := x; result.y := y; result.w := w; result.h := h;
end;

function RGB(R, G, B: Uint16): TRGBData;
var
  t: TRGBData;
begin
  t.R := R; t.B := B; t.G := G;
  result := t;
end;

{------------implementation of TSDL_Surface---------------}

procedure TSDL_Surface.PPutRGBPixel(x,y: Uint16; Color: TRGBData);
var
  Index16: ^Uint16;
  Index32: ^Uint32;
  Index8: ^Uint8;
  RGB_Value: Uint32;
begin
  if NeedsLock then SDL_LockSurface(PSurface);
  case surface.format.BytesPerPixel of
    2: begin
      Index16 := PSurface.pixels + y*PSurface.pitch + x*2;
      Index16^ := SDL_MapRGB(PSurface.format,Color.R,Color.G,Color.B);
     end;
    4: begin
      Index32 := PSurface.pixels + y*PSurface.pitch + x*4;
      Index32^ := SDL_MapRGB(PSurface.format,Color.R,Color.G,Color.B);
     end;
    3: begin
      Index16 := PSurface.pixels + y*PSurface.pitch + x*3;
      RGB_Value := SDL_MapRGB(PSurface.format,Color.R,Color.G,Color.B);
      Index16^ := RGB_Value;
      Index8 := Pointer(Index16) + 2;
      Index8^ := RGB_Value SHR 16;
     end;
    end;
  if NeedsLock then SDL_UnlockSurface(PSurface);
  if PInstantUpdate then
    if SW_Surface in PFlags then SDL_UpdateRect(PSurface,x,y,1,1);
end;

procedure TSDL_Surface.PPutRGBAPixel(x,y: Uint16; Color: TRGBAData);
begin
end;

function TSDL_Surface.PGetRGBPixel(x,y: Uint16): TRGBData;
begin
end;

function TSDL_Surface.PGetRGBAPixel(x,y: Uint16): TRGBAData;
begin
end;

procedure TSDL_Surface.Clear; overload;
begin
  SDL_FillRect(PSurface, NIL, SDL_MapRGB(PSurface^.format,0,0,0));
  if PInstantUpdate then
    if SW_Surface in PFlags then SDL_UpdateRect(PSurface,0,0,0,0);
end;

procedure TSDL_Surface.Clear(r, g, b: Uint8); overload;
begin
  SDL_FillRect(PSurface, NIL, SDL_MapRGB(PSurface^.format, r, g, b));
  if PInstantUpdate then
    if SW_Surface in PFlags then SDL_UpdateRect(PSurface,0,0,0,0);
end;

constructor TSDL_Surface.CreateFromSurface(s: PSDL_Surface);
begin
  inherited Create;
  PSurface := s;
  GrabFlags;
  PInstantUpdate := false;
end;

procedure TSDL_Surface.GrabFlags;
begin
  if (PSurface.flags AND SDL_HWSURFACE) <> 0 then PFlags := [HW_Surface]
    else PFlags := [SW_Surface];
  if (PSurface.flags and SDL_ASYNCBLIT) <> 0 then PFlags := PFlags + [Async_Blit];
  if (PSurface.flags and SDL_SRCCOLORKEY) <> 0 then PFlags := PFlags + [CC_Blit];
  if (PSurface.flags and SDL_SRCALPHA) <> 0 then PFlags := PFlags + [Alpha_Blit];
  NeedsLock := SDL_MUSTLOCK(PSurface);
  Pixels := PSurface.pixels;
end;

function TSDL_Surface.PGetRAWPixel(x,y: Uint16): UInt32;
var
  Index16: ^Uint16;
  Index32: ^Uint32;
begin
  if NeedsLock then SDL_LockSurface(PSurface);
  case PSurface.format.BytesPerPixel of
    2: begin
      Index16 := PSurface.pixels + y*PSurface.pitch + x*2;
      result := Index16^;
     end;
    4: begin
      Index32 := PSurface.pixels + y*PSurface.pitch + x*4;
      result := Index32^;
     end;
    3: begin
      Index32 := PSurface.pixels + y*PSurface.pitch + x*3;
      result := Index32^ AND $FFFFFF;
     end;
    end;
  if NeedsLock then SDL_UnlockSurface(PSurface);
end;

procedure TSDL_Surface.SetRAWPixel(x, y: Uint16; Color: Uint32); inline;
var
  Index16: ^Uint16;
  Index32: ^Uint32;
  Index8: ^Uint8;
begin
  case PSurface.format.BytesPerPixel of
    2: begin
      Index16 := PSurface.pixels + y*PSurface.pitch + x*2;
      Index16^ := Color;
     end;
    4: begin
      Index32 := PSurface.pixels + y*PSurface.pitch + x*4;
      Index32^ := Color;
     end;
    3: begin
      Index16 := PSurface.pixels + y*PSurface.pitch + x*3;
      Index16^ := Color;
      Index8 := Pointer(Index16) + 2;
      Index8^ := Color SHR 16;
     end;
   end;
end;

procedure TSDL_Surface.PPutRawPixel(x,y: Uint16; Color: Uint32);
begin
  if NeedsLock then SDL_LockSurface(PSurface);  
  SetRAWPixel(x, y, Color);
  if NeedsLock then SDL_UnlockSurface(PSurface);
  if PInstantUpdate then
    if SW_Surface in PFlags then SDL_UpdateRect(PSurface,x,y,x,y);
end;

function TSDL_Surface.MapRGB(R,G,B: Uint8): Uint32;
begin
  result := SDL_MapRGB(PSurface.format, R,G,B);
end;

procedure TSDL_Surface.BlitFrom(s: TSDL_Surface; o: PSDL_Rect; x,y: Sint16);
var
  d: SDL_Rect;
begin
  d := AsSDL_Rect(x,y,0,0);
  SDL_BlitSurface(s.Surface, o, PSurface, @d);
  if PInstantUpdate then
    if SW_Surface in PFlags then begin
      if o = NIL then SDL_UpdateRect(PSurface,x,y,s.Surface.w, s.Surface.h)
        else SDL_UpdateRect(PSurface,x,y,o.w,o.h);
    end;
end;

procedure TSDL_Surface.Convert2DisplayFormat;
var
  s: PSDL_Surface;
begin
  s := SDL_DisplayFormat(PSurface);
  SDL_FreeSurface(PSurface);
  PSurface := s;
  GrabFlags;
end;

procedure TSDL_Surface.SetColorKey(key: Uint32);
begin
  SDL_SetColorKey(PSurface, SDL_SRCCOLORKEY OR SDL_RLEACCEL, key);
end;

procedure TSDL_Surface.ClearColorKey;
begin
  SDL_SetColorKey(PSurface, 0, 0);
end;

procedure TSDL_Surface.UpdateScreen;
begin
  if SW_Surface in PFlags then SDL_UpdateRect(PSurface, 0, 0, 0, 0);
end;

procedure TSDL_Surface.PrintText_Shaded(data: String; x,y: Uint16; fr, fg, fb, br, bg, bb: Uint8; font: TFont_proto);
var
  tmpSurface: TSDL_Surface;
begin
  tmpSurface := font.RenderText_Shaded(data, SDL_RGB(fr, fg, fb), SDL_RGB(br, bg, bb));
  BlitFrom(tmpSurface, NIL, x ,y);
  tmpSurface.Destroy;
end;

procedure TSDL_Surface.FillRect(x, y, w, h: Uint16; r, g, b: Uint8);
var
  rect: SDL_Rect;
begin
  rect := AsSDL_Rect(x ,y ,w, h);
  SDL_FillRect(PSurface, @rect, MapRGB(r, g, b));
  if PInstantUpdate then
    if SW_Surface in PFlags then SDL_UpdateRect(PSurface, x, y, w, h);
end;

function TSDL_Surface.SpawnSurface(w, h: Uint16; flags: TSurfaceFlagSet): TSDL_Surface; overload;
var
  f: Uint32;
begin
  f := 0;
  if HW_Surface in flags then f := f or SDL_HWSURFACE;
  if SW_Surface in flags then f := f or SDL_SWSURFACE;
  if Async_Blit in flags then f := f or SDL_ASYNCBLIT;
  if CC_Blit in flags then f := f or SDL_SRCCOLORKEY;
  if Alpha_Blit in flags then f := f or SDL_SRCALPHA;
  result := TSDL_Surface.CreateFromSurface( SDL_CreateRGBSurface(f, w, h, PSurface^.format.BitsPerPixel,
    PSurface^.format.Rmask, PSurface^.format.Gmask, PSurface^.format.Bmask, PSurface^.format.Amask));
end;

function TSDL_Surface.SpawnSurface(flags: TSurfaceFlagSet): TSDL_Surface; overload;
var
  f: Uint32;
begin
  f := 0;
  if HW_Surface in flags then f := f or SDL_HWSURFACE;
  if SW_Surface in flags then f := f or SDL_SWSURFACE;
  if Async_Blit in flags then f := f or SDL_ASYNCBLIT;
  if CC_Blit in flags then f := f or SDL_SRCCOLORKEY;
  if Alpha_Blit in flags then f := f or SDL_SRCALPHA;
  result := TSDL_Surface.CreateFromSurface( SDL_CreateRGBSurface(f, PSurface^.w, PSurface^.h, 
    PSurface^.format.BitsPerPixel, PSurface^.format.Rmask, PSurface^.format.Gmask, PSurface^.format.Bmask, PSurface^.format.Amask));
end;


procedure TSDL_Surface.Line(x1, y1, x2, y2: Uint16; r, g, b: Uint8);
var
  i, dy, dx, md: Integer;
  col: Uint32;
begin
  dy := abs(y1 - y2);
  dx := abs(x1 - x2);
  col := MapRGB(r, g, b);
  if NeedsLock then SDL_LockSurface(PSurface);
  if dx > dy then begin
    if x1 > x2 then begin
      i := x2; x2 := x1; x1 := i;
      i := y2; y2 := y1; y1 := i;
    end;
    md := dx div 2;
    if y2 < y1 then begin 
      for i := x1 to x2 do     
        SetRAWPixel(i, y1 - ( (i - x1) * dy + md) div dx, col);
      if NeedsLock then SDL_Unlocksurface(Psurface);
      if PInstantUpdate then
        if SW_Surface in PFlags then SDL_UpdateRect(PSurface, x1, y2, dx, dy);
    end else begin
      for i := x1 to x2 do
        SetRAWPixel(i, y1 + ( (i - x1) * dy + md) div dx, col);
      if NeedsLock then SDL_Unlocksurface(Psurface);
      if PInstantUpdate then
        if SW_Surface in PFlags then SDL_UpdateRect(PSurface, x1, y1, dx, dy);
    end;
  end else if dy > 0 then begin
    if y1 > y2 then begin
      i := y2; y2 := y1; y1 := i;
      i := x2; x2 := x1; x1 := i;
    end;
    md := dy div 2;
    if x2 < x1 then begin
      for i := y1 to y2 do
        SetRAWPixel(x1 - ( (i - y1) * dx + md) div dy, i, col);
      if NeedsLock then SDL_UnlockSurface(PSurface);
      if PInstantUpdate then
	if SW_Surface in PFlags then SDL_UpdateRect(Psurface, x2, y1, dx, dy);
    end else begin
      for i := y1 to y2 do
        SetRAWPixel(x1 + ( (i - y1) * dx + md) div dy, i, col);
      if NeedsLock then SDL_UnlockSurface(PSurface);
      if PInstantUpdate then
	if SW_Surface in PFlags then SDL_UpdateRect(Psurface, x1, y1, dx, dy);
    end;
  end else begin
    if NeedsLock then SDL_UnlockSurface(Psurface);
    PPutRawPixel(x1, y1, col);
  end;
end;

procedure TSDL_Surface.UpdateScreen(x, y, w, h: Uint16); overload;
begin
  if SW_Surface in PFlags then SDL_UpdateRect(PSurface, x, y, w, h);
end;

Destructor TSDL_Surface.Destroy;
begin
  SDL_FreeSurface(PSurface);
  inherited Destroy;
end;

{--------------end of TSDL_Surface---------------}


initialization

finalization

end.
