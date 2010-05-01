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

unit fonts;

{Provides a object-oriented wrapper around SDL_ttf}

interface

uses SDL, SDL_ttf, SDL_video, GraphCore, AmoebaDebug, Strings;

type

  Attributes = (underline, italic, bold);
  AttributeSet = set of Attributes;

  TFont = class(TFont_proto)
  
  protected
    
    pfontptr: TTF_font;
    PAttrib: AttributeSet;
    
    procedure SetAttributes(a: AttributeSet);
  
  public
  
    property Attrib: AttributeSet read PAttrib write SetAttributes;
  
    function RenderText_Shaded(text: String; fg, bg: SDL_Color): TSDL_Surface; override;
    function TextWidth(text: String): Integer;
        
    {WARNING (FIXME): This desn't check if the filename specified is valid and will most
    likely produce a runtime error if it isn't!}
    constructor CreateFromFile(filename: string; size: longint);
    destructor Destroy; override;
    
  end;
  

implementation

procedure TFont.SetAttributes(a: AttributeSet);
var
  sty: Longint;
begin
  PAttrib := a;
  sty := TTF_STYLE_NORMAL;
  if italic in PAttrib then sty := sty or TTF_STYLE_ITALIC;
  if bold in PAttrib then sty := sty or TTF_STYLE_BOLD;
  if underline in PAttrib then sty := sty or TTF_STYLE_UNDERLINE;
  TTF_SetFontStyle(pfontptr, sty);
end;
  
function TFont.RenderText_Shaded(text: String; fg, bg: SDL_Color): TSDL_Surface;
begin
  result := TSDL_Surface.CreateFromSurface(TTF_RenderText_shaded(pfontptr, text, fg, bg));
end;

function TFont.TextWidth(text: String): Integer;
var
  w, h: Longint;
begin
  TTF_SizeText(pfontptr, text, w, h);
  result := w;
end;

constructor TFont.CreateFromFile(filename: string; size: longint);
begin
  inherited create;
  pfontptr := TTF_OpenFont(filename, size);
  PAttrib := [];
end;

destructor TFont.Destroy;
begin
  TTF_CloseFont(pfontptr);
  inherited Destroy;
end;

initialization

if TTF_Init <> 0 then panic('Fatal: Unable to initialize SDL_ttf!');
DebugOut('SDL_ttf initialized...');

finalization

TTF_Quit;
DebugOut('SDL_ttf quit succesfully');

end.