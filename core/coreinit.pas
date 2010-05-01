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

{------------unit 'coreinit'-------------

provides initialization and shutdown of the core

------------------------------------------}

unit coreinit;


interface

uses Graphengine;

procedure InitCore;
procedure ShutdownCore;

var
  GraphicsEngine: TGraphicsEngine;

implementation

uses SDL, amoebadebug;

procedure InitCore;
begin

  GraphicsEngine := TGraphicsEngine.Create;
  if SDL_Init(SDL_INIT_VIDEO) <> -1 then DebugOut('SDL initialized...') else
    panic('Error: SDL failed to initialize...');
end;

procedure ShutdownCore;
begin
  GraphicsEngine.Destroy;    
  SDL_Quit;
  DebugOut('SDL quit succesfully...');
end;


initialization


finalization

end.
