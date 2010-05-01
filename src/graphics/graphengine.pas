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

unit graphengine;

{Define this if you get  crashes using the SDL dga video driver}
{_$LINKLIB c}

interface

uses graphcore, SDL, SDL_Video, SDL_Types, amoebadebug, exceptions;

type

TVideoFlags = (Fullscreen, Doublebuf, Hardware, Anydepth, Async);
TVideoFlagSet = set of TVideoFlags;

TSprite = class

protected

  PSurface: TSDL_Surface;
  PArea: SDL_Rect;
  PPArea: PSDL_Rect;
  Px, Py: Uint16;
  
public

  property Surface: TSDL_Surface read PSurface write PSurface;
  property Area: PSDL_Rect read PPArea;
  property x: Uint16 read Px write Px;
  property y: Uint16 read Py write Py;
  
  procedure SetBlitArea(ax, ay, w, h: Uint16);
  
  constructor Create; overload;
  constructor Create(ax, ay: Uint16); overload;
  destructor DestroyAll;
  
end;


TGraphicsEngine = class

protected

  PSurface: TSDL_Surface;
  PFlags: TVideoFlagSet;
  SpriteQueue: array[0..99] of TSprite;
  SpritePointer: Byte;
  UseShadow: Boolean;
  ShadowSurface: TSDL_Surface;
  PColor: TRGBData;
  
  procedure GetFlags;

public

  property Surface: TSDL_Surface read PSurface;
  property Flags: TVideoFlagSet read PFlags;
  property Color: TRGBData read PColor write PColor;
  
  function InitVMode(w,h: Uint16; depth: Uint8; Flags: TVideoFlagSet): Boolean;
  procedure PushSprite(Sprite: TSprite);
  procedure Render;
  
  destructor Destroy; override;

end;

implementation

procedure TSprite.SetBlitArea(ax, ay, w, h: Uint16);
begin
  PArea.x := ax; PArea.y := ay;
  PArea.w := w; PArea.h := h;
  if (w = 0) and (h = 0) then PPArea := nil else PPArea := @PArea;
end;

constructor TSprite.Create; overload;
begin
  inherited Create;
  PPArea := nil;
end;

constructor TSprite.Create(ax, ay: Uint16); overload;
begin
  inherited Create;
  x := ax; y := ay;
  PPArea := nil;
end;

destructor TSprite.DestroyAll;
begin
  PSurface.Destroy;
  inherited Destroy;
end;

procedure TGraphicsEngine.GetFlags;
begin
  PFlags := [];
  if (PSurface.surface.flags AND SDL_HWSURFACE) <> 0 then PFlags := PFlags + [Hardware];
  if (PSurface.surface.flags AND SDL_FULLSCREEN) <> 0 then PFlags := PFlags + [Fullscreen];
  if (PSurface.surface.flags AND SDL_DOUBLEBUF) <> 0 then PFlags := PFlags + [Doublebuf];
  if (PSurface.surface.flags AND SDL_ASYNCBLIT) <> 0 then PFlags := PFlags + [Async];
end;

function TGraphicsEngine.InitVMode(w,h: Uint16; depth: Uint8; Flags: TVideoFlagSet): Boolean;
var
  s: PSDL_Surface;
  SDL_Flags: UInt32;
begin
  SDL_Flags := 0;
  if Fullscreen in Flags then SDL_Flags := SDL_Flags OR SDL_FULLSCREEN;
  if Doublebuf in Flags then SDL_Flags := SDL_Flags OR SDL_DOUBLEBUF;
  if Hardware in Flags then SDL_Flags := SDL_Flags OR SDL_HWSURFACE;
  if Anydepth in Flags then SDL_Flags := SDL_Flags OR SDL_ANYFORMAT;
  if Async in Flags then SDL_FLags := SDL_Flags or SDL_ASYNCBLIT;
  s := SDL_SetVideoMode(w, h, depth, SDL_Flags);
  if s = NIL then begin
    result := false;
    DebugOut('Failed to init Video!');
    exit;
  end else begin
    PSurface := TSDL_Surface.CreateFromSurface(s);
    GetFlags;
    result := true;
  end;
  if (Doublebuf in self.Flags) then DebugOut('Allocated a doublebuffered surface...');
  if (not (Doublebuf in self.Flags)) and (Hardware in self.Flags) then begin
    DebugOut('Allocated surface is a hardware surface without doublebuffering; using shadow surface...');
    ShadowSurface := PSurface.SpawnSurface([Async_Blit]);
    ShadowSurface.Convert2DisplayFormat;
    UseShadow := true;
  end else begin
    UseShadow := false;
    if not (Hardware in self.Flags) then DebugOut('Allocated a software surface...');
  end;
  SpritePointer := 0;
end;

procedure TGraphicsEngine.PushSprite(Sprite: TSprite);
begin
  if SpritePointer = 100 then raise EGraphEngineOverflow.Create('Fatal: Sprite queue overflow occured!');
  SpriteQueue[SpritePointer] := Sprite;
  Inc(SpritePointer);
end;

procedure TGraphicsEngine.Render;
var
  i: Byte;
  s: TSDL_Surface;
begin
  if SpritePointer = 0 then begin
    DebugOut('Render called on empty sprite queue!');
    exit;
  end;
  if UseShadow then s := ShadowSurface else s:= PSurface;
  s.Clear(PColor.r, PColor.g, PColor.b);
  for i := 0 to SpritePointer - 1 do
    s.BlitFrom(SpriteQueue[i].Surface, SpriteQueue[i].Area, SpriteQueue[i].x, SpriteQueue[i].y);
  if UseShadow then PSurface.BlitFrom(s, NIL, 0, 0) else SDL_Flip(PSurface.Surface);
end;

destructor TGraphicsEngine.Destroy;
begin
  if UseShadow then ShadowSurface.destroy;
  inherited Destroy;
end;

initialization

finalization

end.
