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

{------------program graphdemo-------------

little demo to test graphics classes

------------------------------------------}

{$DEFINE NO_FULLSCREEN}

program Graphdemo;

uses Crt, SDL, SDL_Video, SDL_Types, SDL_Events, SDL_Timer,
  SDL_Keyboard, SDL_Mouse, Coreinit, amoebadebug, graphcore, graphengine, math,
  sysutils, fonts;

const
  NumPixels = 500;

var
  i,j: Integer;
  Event: SDL_Event;
  quitflag: Boolean = false;
  HaveFont: Boolean;
  pixels: array[1..NumPixels,1..2] of Integer;
  Timer: Uint32;
  s: PSDL_Surface;
  Font, Font10: TFont;
  Fontfile: String;

function exp_(x: Double): Double;
var
  a: word;
  b: Double;
begin
  {$IFDEF CPUPOWERPC}
  if x < -20 then begin
    a := Round(x / (-20));
    b := exp(x / a);
    result := b ** a;
  end else result := exp(x);
  {$ELSE}
  result := exp(x);
  {$ENDIF}
end;

procedure InitSurface(fs: Boolean);
var
  flags: TVideoFlagSet;
begin
  flags := [Hardware, Anydepth, Async];
  if fs then flags := flags + TVideoFlagSet([Fullscreen]);
  if NOT GraphicsEngine.InitVMode(640, 480, 16, flags) then
  DebugOut('Allocated surface....');
  if SW_Surface in GraphicsEngine.Surface.Flags then DebugOut('Allocated surface is no hardware surface.')
    else DebugOut('Allocated surface is a hardware surface.');
  SDL_ShowCursor(0);
  GraphicsEngine.Surface.InstantUpdate := true;
end;

procedure Stars;
begin
  quitflag := false;
  GraphicsEngine.Surface.Clear;
  repeat
    for i := 1 to NumPixels do begin
      timer := SDL_GetTicks;
      pixels[i,1] := Random(640);
      pixels[i,2] := Random(480);
      GraphicsEngine.Surface.RGBPixels[Pixels[i,1],Pixels[i,2]] := RGB(Random(256), Random(256),Random(256));
      repeat until (SDL_GetTicks - Timer) > 1;
    end;
    for i := 1 to NumPixels do begin
      timer := SDL_GetTicks;
      GraphicsEngine.Surface.RGBPixels[Pixels[i,1],Pixels[i,2]] := RGB(0,0,0);
      repeat until (SDL_GetTicks - Timer) > 1;
    end;
    while SDL_PollEvent(@Event) = True do begin
      if Event.eventtype = SDL_KEYDOWN then quitflag := true;
    end;
  until quitflag;
end;

procedure flies;
var
  dx_up,dx_down,dy_up,dy_down: Uint8;
  pixels2: array[1..NumPixels] of Uint32;
begin
  GraphicsEngine.Surface.InstantUpdate := false;
  dx_up := 1; dx_down := 1; dy_up := 1; dy_down := 1; j:=1;
  for i := 1 to NumPixels do begin
    Pixels2[i] := GraphicsEngine.Surface.MapRGB(Random(256), Random(256), Random(256));
  end;
  quitflag := false;
  repeat
    for i := 1 to NumPixels do begin
      GraphicsEngine.Surface.RAWPixels[Pixels[i,1],Pixels[i,2]] := 0;
      case Random(4) of
        0: if Pixels[i,1] > (dx_down - 1) then Dec(Pixels[i,1], dx_down);
	1: if Pixels[i,1] < (640 - dx_up) then Inc(Pixels[i,1], dx_up);
	2: if Pixels[i,2] > (dy_down - 1) then Dec(Pixels[i,2], dy_down);
	3: if Pixels[i,2] < (480 - dy_up) then Inc(Pixels[i,2], dy_up);
      end;
      GraphicsEngine.Surface.RAWPixels[Pixels[i,1],Pixels[i,2]] := Pixels2[i];
    end;
    while SDL_PollEvent(@Event) = True do begin
      if Event.eventtype = SDL_KEYDOWN then case SDL_KeyboardEvent(Event).keysym.sym of
        SDLK_SPACE: quitflag := true;
	SDLK_UP: if dy_up > 1 then Dec(dy_up) else Inc(dy_down);
	SDLK_DOWN: if dy_down > 1 then Dec(dy_down) else Inc(dy_up);
	SDLK_LEFT: if dx_up > 1 then Dec(dx_up) else Inc(dx_down);
	SDLK_RIGHT: if dx_down > 1 then Dec(dx_down) else Inc(dx_up);
      end;
    end;
    GraphicsEngine.Surface.UpdateScreen;
  until quitflag;
  GraphicsEngine.Surface.InstantUpdate := true;
end;


procedure dla;
type 
  TCluster = array[0..402, 0..402] of boolean;
  PCluster = ^TCluster;
var
  Phi, r: float;
  dla_cluster: PCluster;
  x, y, n, Rm2, dist: Integer;

  function EuclDist2(xi, yi: Integer): Integer;
  begin
    result := (xi-200)*(xi-200) + (yi-200)*(yi-200);
  end;
  
  procedure NewParticle;
  begin
    repeat
      x := Random(400) + 1; y := Random(400) + 1;
    until EuclDist2(x, y) > Rm2;
  end;
  
begin
  new(dla_cluster);
  GraphicsEngine.surface.InstantUpdate := true;  
  GraphicsEngine.surface.clear;
  if HaveFont then
    GraphicsEngine.surface.PrintText_Shaded('Calculating DLA aggregate...', 0, 0, 255, 255, 255, 0, 0, 0, Font);
  quitflag := false;
  for i := 0 to 402 do for j := 0 to 402 do dla_cluster[i,j] := false;
  dla_cluster[200,200] := true;
  GraphicsEngine.surface.RGBPixels[120+200, 40+200] := RGB(255,255,255);
  Rm2 := 1; n := 1;
  NewParticle;
  repeat
    dist := EuclDist2(x, y);
    if (dla_cluster[x+1, y] or dla_cluster[x-1, y] or dla_cluster[x, y+1] or dla_cluster[x, y-1]) then begin
      dla_cluster[x, y] := true;
      GraphicsEngine.surface.RGBPixels[120+x, 40+y] := RGB(Random(256), Random(200), Random(100));
      if dist > Rm2 then Rm2 := dist;
      Inc(n);
      NewParticle;
      if (n mod 50) = 0 then
        if (HaveFont and (Rm2 > 1)) then
          GraphicsEngine.surface.PrintText_Shaded(' Fractal dimension: ' + FLoatToStrF(ln(n)/ln(sqrt(Rm2)), ffFixed, 5, 5) + '  '
	    , 0, 441, 255, 255, 255, 0, 0, 0, Font);
    end;
    if dist > (Rm2 + Rm2 div 20) then begin
      Phi := 2*pi*Random;
      r := sqrt(dist) - sqrt(Rm2) - 1;
      if r < 1 then r := 1;
      x := x + Round(r * cos(Phi));
      y := y + Round(r * sin(Phi));
    end else begin
      case Random(4) of
        0: Inc(x);
	1: Dec(x);
	2: Inc(y);
	3: Dec(y);
      end;
    end;
    if EuclDist2(x, y) > 199*199 then NewParticle;
    if Rm2 > 198*198 then begin
      GraphicsEngine.surface.clear;
      for i := 0 to 402 do for j := 0 to 402 do dla_cluster[i,j] := false;
      dla_cluster[200, 200] := true;
      GraphicsEngine.surface.RGBPixels[120+200, 40+200] := RGB(255,255,255);  
      if HaveFont then
        GraphicsEngine.surface.PrintText_Shaded('Calculating DLA aggregate...', 0, 0, 255, 255, 255, 0, 0, 0, Font); 
      writeln('Aggregate comlete; fractal dimension was ', FloatToStrF(ln(n) / ln(sqrt(Rm2)), ffFixed, 5, 5), ' .');  
      Rm2 := 1; n := 1;
      NewParticle;
    end;
    while SDL_PollEvent(@Event) = True do 
      if Event.eventtype = SDL_KEYDOWN then quitflag := true;    
  until quitflag;
 writeln('Aggregate comlete; fractal dimension was ', FloatToStrF(ln(n) / ln(sqrt(Rm2)), ffFixed, 5, 5), ' .');
 FloatToStrF(0.01, ffFixed, 3, 3);
 dispose(dla_cluster);
end;

procedure circle;
begin
  GraphicsEngine.surface.Clear;
  GraphicsEngine.surface.InstantUpdate := false;
  for i := 0 to 300 do 
    GraphicsEngine.surface.Line(320, 240, Round(320 + 200 * cos(2 * Pi * i / 200)), 
      Round(240 + 200 * sin(2 * Pi * i / 200)), 100, 255, 255);
  GraphicsEngine.surface.Line(1,1,1,1,255,255,255);
  GraphicsEngine.surface.UpdateScreen;
  repeat
    repeat sleep(10); until SDL_PollEvent(@Event) = True;
    sleep(10);
  until Event.eventtype = SDL_KEYDOWN;
end;

procedure Lines;
begin
  GraphicsEngine.surface.InstantUpdate := true;  
  GraphicsEngine.surface.Clear;
  quitflag := false;
  repeat
    GraphicsEngine.surface.line(Random(640), Random(480), Random(640), Random(480), Random(256), Random(256),
      Random(256));
    while SDL_PollEvent(@Event) = True do
      if Event.eventtype = SDL_KEYDOWN then quitflag := true;
  until quitflag;
end;

procedure Ising;
var
  spins: array [0..101,0..101] of Integer;
  exp8, exp4, temp: Float;
  energy: Integer;
  r, b: Uint16;

  procedure Spinflip;inline;
  begin
    spins[i, j] := (-1) * spins[i, j];
    if i = 1 then spins[101, j] := spins[i, j] else
      if i = 100 then spins[0, j] := spins[i, j];
    if j = 1 then spins[i, 101] := spins[i, j] else
      if j = 100 then spins[i, 0] := spins[i, j];
    if spins[i, j] > 0 then begin
      r := 255; b := 0;
    end else begin
      r := 0; b := 255;
    end;
    GraphicsEngine.Surface.FillRect(116 + i * 4, 36 + j * 4, 4, 4, r, 0, b);
  end;
  
  procedure Print;
  var
    t: String;
  begin
    t := ' Temperature: ' + FloatToStrF(temp, ffFixed, 2, 2) + ' Tc       ';
    if HaveFont then 
      GraphicsEngine.surface.PrintText_shaded(t, 0, 441, 225, 225, 225, 0, 0, 0, Font);
  end;
  
begin
  GraphicsEngine.surface.InstantUpdate := false;  
  GraphicsEngine.surface.Clear;
  if HaveFont then
    GraphicsEngine.surface.PrintText_shaded('Ising ferromagnet', 0, 0, 255, 255, 255, 0, 0, 0, Font);
  quitflag := false;
  for i := 0 to 101 do for j := 0 to 101 do 
    if Random(2) = 1 then spins[i, j] := 1 else spins[i, j] := -1;
  for i := 1 to 100 do for j := 1 to 100 do Spinflip;  
  GraphicsEngine.surface.UpdateScreen;
  GraphicsEngine.surface.InstantUpdate := true;  
  temp := 1;
  exp8 := exp( (-8) / temp / 2.269);
  exp4 := exp( (-4) / temp / 2.269);
  Print;
  repeat
    i := Random(100) + 1;
    j := Random(100) + 1;
    energy := (-1) * spins[i,j] * (spins[i+1, j] + spins[i-1, j] + spins[i, j+1] + spins[i, j-1]);
    if energy > 0 then Spinflip
    else if energy = -2 then begin
      if Random < exp4 then Spinflip;
    end else if energy = -4 then begin
      if Random < exp8 then Spinflip;
    end;
    while SDL_PollEvent(@Event) = True do
      if Event.eventtype = SDL_KEYDOWN then case SDL_KeyboardEvent(Event).keysym.sym of
        SDLK_SPACE: quitflag := true;
	SDLK_LEFT: if temp > 0.05 then begin
	  temp := temp - 0.05;
          exp8 := exp( (-8) / temp / 2.269);
  	  exp4 := exp( (-4) / temp / 2.269);
	  Print;
	end;	  
	SDLK_RIGHT: begin
	  temp := temp + 0.05;
	  exp8 := exp( (-8) / temp / 2.269);
  	  exp4 := exp( (-4) / temp / 2.269);
	  Print;
	end; 
      end;
  until quitflag;
end;
  
procedure Travel;
type
  City = record
    x, y: Word;
  end;
  Schedule = array[0..101] of City;
  PSchedule = ^Schedule;
var
  Sched, OldSched, TempSched: PSchedule;
  k, l, p, a, b, c : Byte;
  temp, un, dist, ddist, step: Real;
  DoFlip: Boolean;
  cntr, lc: Integer;
  DrawWin, DataWin, Title, LengthT: TSprite;

  function d(c1, c2: City): float; inline;
  begin
    result := sqrt( (c1.x - c2.x) ** 2 + (c1.y - c2.y) ** 2);
  end;
    
  procedure Render; inline;
  var
    recalc: Boolean;
  begin
    DrawWin.Surface.Clear(255, 255, 255);
    DrawWin.Surface.Line(Sched^[1].x + 2, Sched^[1].y + 2, Sched^[100].x + 2, Sched^[100].y + 2, 0, 0, 0);
    recalc := ( (lc mod 10) = 0 );
    if recalc then dist := d(Sched^[1], Sched^[100]);
    for i := 1 to 99 do begin
      DrawWin.Surface.Line(Sched^[i].x + 2, Sched^[i].y + 2, Sched^[i+1].x + 2, Sched^[i+1].y + 2, 0, 0, 0);
      DrawWin.Surface.FillRect(Sched^[i].x, Sched^[i].y, 5, 5, 0, 255, 0);
      if recalc then dist := dist + d(Sched^[i], Sched^[i+1]);
    end;
    DrawWin.Surface.FillRect(Sched^[100].x, Sched^[100].y, 5, 5, 0, 255, 0);
    DataWin.Surface.Clear(100, 100, 100);
    if HaveFont then DataWin.surface.PrintText_Shaded('Temperature: ' + FloatToStrF(temp, ffFixed, 4, 4), 0, 0, 
      0, 0, 0, 100, 100, 100, Font10);
    if HaveFont then DataWin.Surface.PrintText_Shaded('Step: ' + FloatToStrF(step, ffFixed, 4, 4), 0, 20,
      0, 0, 0, 100, 100 ,100, Font10);
    if HaveFont then DataWin.Surface.PrintText_Shaded('Red. length: ' + FloatToStrF(dist / 4000, ffFixed, 4, 4),
      0, 40, 0, 0, 0, 100, 100, 100, Font10);
    if HaveFont then LengthT.Surface := Font.RenderText_Shaded('Length of path: ' + FloatToStrF(dist, ffFixed, 3, 3),
      SDL_RGB(0, 0, 0), SDL_RGB(100, 100, 100));
    GraphicsEngine.Render;
    if HaveFont then LengthT.Surface.Destroy;
  end;
  
  function Neighbours(n, m: Byte): Boolean; inline;
  var
    q: Byte;
  begin
    if n = m then begin
      result := true;
      exit;
    end;
    if n > m then begin
      q := n; n := m; m := q;
    end;
    if (n = 1) and (m = 100) then begin
      result := true;
      exit;
    end;
    if m = (n + 1) then begin
      result := true;
      exit;
    end;
    result := false;
  end;
    
begin
  New(Sched);
  New(OldSched);
  GraphicsEngine.Surface.InstantUpdate := false;
  DataWin := TSprite.Create(2, 200);
  DataWin.Surface := GraphicsEngine.Surface.SpawnSurface(123,60, [Async_Blit]);
  DataWin.Surface.Convert2DisplayFormat;
  DrawWin := TSprite.Create(125, 37);
  DrawWin.Surface := GraphicsEngine.Surface.SpawnSurface(406, 406, [Async_Blit]);
  DrawWin.Surface.Convert2DisplayFormat;
  if HaveFont then begin
    Font.Attrib := [underline, italic];
    Title := TSprite.Create( Round( (640 - Font.TextWidth('Travelling Salesman')) / 2), 0);
    Title.Surface := Font.RenderText_Shaded('Travelling salesman', SDL_RGB(0, 0, 0), SDL_RGB(100, 100, 100));
    Title.Surface.Convert2DisplayFormat;
    FOnt.Attrib := [];
    GraphicsEngine.PushSprite(Title);
    LengthT := TSprite.Create(2, 443);
    GraphicsEngine.PushSprite(LengthT);
  end;
  GraphicsEngine.PushSprite(DataWin);
  GraphicsEngine.PushSprite(DrawWin);
  GraphicsEngine.Color := RGB(100, 100, 100);
  temp := 1;
  step := 0.05;
  for i := 1 to 100 do begin
    Sched^[i].x := Random(400) + 1;
    Sched^[i].y := Random(400) + 1;
  end;
  Sched^[0] := Sched^[100]; Sched^[101] := Sched^[1];
  lc := 0;
  quitflag := false;
  cntr := 1;
  un := 50;
  Render;
  repeat
    k := Random(100) + 1;
    repeat
      l := Random(100) + 1;
    until not Neighbours(k, l);
    c := k + 1; if c = 101 then c := 1;
    b := l + 1; if b = 101 then b := 1;
    ddist := d(Sched^[k], Sched^[c]) + d(Sched^[l], Sched^[b]) - d(Sched^[k], Sched^[l]) - d(Sched^[c], Sched^[b]);
    DoFlip := (ddist > 0);
    if not DoFlip then DoFlip := (Random < exp_(ddist / temp / un));
    if DoFlip then begin
      dist := dist - ddist;
      inc(lc);
      OldSched^[1] := Sched^[k];    
      p := l;
      a := 2;
      repeat
        OldSched^[a] := Sched^[p];
        Inc(a); Dec(p);
        if p = 0 then p := 100;
      until p = k;
      p := b;
      repeat
        OldSched^[a] := Sched^[p];
        Inc(a); Inc(p);
        if p = 101 then p := 1;
      until a = 101;
      TempSched := Sched;
      Sched := OldSched;
      OldSched := TempSched;
      if ( cntr mod 200 = 0) then Render;
    end;
    inc(cntr);
    while SDL_PollEvent(@Event) = True do 
     if Event.eventtype = SDL_KEYDOWN then case SDL_KeyboardEvent(Event).keysym.sym of
        SDLK_SPACE: quitflag := true;
	SDLK_LEFT: begin if temp > step then
	  temp := temp - step;	
	  Render;
	end;  
	SDLK_RIGHT: begin
	  temp := temp + step;
	  Render;
	end;
	SDLK_UP: begin
	  step := step * 2;
	  Render;
	end;
	SDLK_DOWN: begin
	  step := step / 2;
	  Render;
	end;	
      end;
  until quitflag;
  Dispose(Sched);
  Dispose(OldSched);
  DrawWin.DestroyAll;
  DataWin.DestroyAll;
  if HaveFont then begin
    Title.DestroyAll;
    LengthT.Destroy;
  end;
end;
  
  
procedure Blitters;
var
  bmpSurface: TSDL_Surface;
begin
  s := SDL_LoadBMP('./test.bmp');
  if s = NIL then begin
    Writeln('BMP not found! if you want to run the blit tests, the copy a '
      + 'small .bmp here and name it test.bmp!');
    exit;
  end;
  bmpSurface := TSDL_Surface.CreateFromSurface(s);

  quitflag := false;
  i := 0; j := 0;
  timer := SDL_GetTicks;
  GraphicsEngine.Surface.Clear;
  repeat
    if SDL_PollEvent(@Event) = True then
      if Event.eventtype = SDL_KEYDOWN then quitflag := true;
    GraphicsEngine.Surface.BlitFrom(bmpSurface, NIL, Random(640 - bmpSurface.surface.w), Random(480 - bmpSurface.surface.h));
    inc(j);
    if SDL_GetTicks - timer > 1000 then begin
      if i > 0 then i := (i + j) div 2 else i := j;
      j := 0;
      timer := SDL_GetTicks;
    end;
  until quitflag;
  Writeln('Average Blits per second (w/o optimizations): ', i);

  bmpSurface.Convert2DisplayFormat;
  quitflag := false;
  i := 0; j := 0;
  timer := SDL_GetTicks;
  GraphicsEngine.Surface.Clear;
  repeat
    if SDL_PollEvent(@Event) = True then
      if Event.eventtype = SDL_KEYDOWN then quitflag := true;
    GraphicsEngine.Surface.BlitFrom(bmpSurface, NIL, Random(640 - bmpSurface.surface.w),
      Random(480 - bmpSurface.surface.h));
    inc(j);
    if SDL_GetTicks - timer > 1000 then begin
      if i > 0 then i := (i + j) div 2 else i := j;
      j := 0;
      timer := SDL_GetTicks;
    end;
  until quitflag;
  Writeln('Average Blits per second (optimized): ', i);

  bmpSurface.SetColorKey(bmpSurface.RAWPixels[0,0]);
  quitflag := false;
  i := 0; j := 0;
  timer := SDL_GetTicks;
  GraphicsEngine.Surface.Clear;
  repeat
    if SDL_PollEvent(@Event) = True then
      if Event.eventtype = SDL_KEYDOWN then quitflag := true;
    GraphicsEngine.Surface.BlitFrom(bmpSurface, NIL, Random(640 - bmpSurface.surface.w), Random(480 - bmpSurface.surface.h));
    inc(j);
    if SDL_GetTicks - timer > 1000 then begin
      if i > 0 then i := (i + j) div 2 else i := j;
      j := 0;
      timer := SDL_GetTicks;
    end;
  until quitflag;
  Writeln('Average Blits per second (colorkeyed): ', i);
end;

begin
  Randomize;
  try
    InitCore;
    {$IFDEF NO_FULLSCREEN}
    InitSurface(false);
    {$ELSE}
    If ParamCount > 0 then begin
      if ParamStr(1) = '-w' then InitSurface(false) else begin
        Writeln; Writeln('Amoeba graphics test. Allowed Parameters:');
	Writeln('  -w : display windowed'); Writeln;
	ShutdownCore;
	halt;
      end;
    end else InitSurface(true);
    {$ENDIF}   
    Fontfile := FileSearch('font.ttf', '.:./demos/');
    if Fontfile <> '' then begin
      writeln('Font found!');
      HaveFont := true;
      Font := TFont.CreateFromFile(Fontfile, 25);
      Font10 := TFont.CreateFromFile(Fontfile, 12);
    end else begin
      writeln('Font not found; copy a truetype font named "font.ttf" here to test text output.');
      HaveFont := false;
    end;
    Stars;
    flies;
    dla;
    Circle;
    Lines;
    Blitters;
    Ising;
    Travel;
    if HaveFont then begin
      Font.Destroy;
      Font10.Destroy;
    end;
    ShutdownCore;
  except
    panic('Fatal: unhandled exception!');
  end;
end.
