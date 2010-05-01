{Copyright (C) 2005  Christian Speckner

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA}

{---------------------------------SDL_ttf.pp--------------------------------

Automatically created from a modified SDL_ttf.h by h2pas; additional cleanup and
hacking by Christian Speckner (cspeckner@freenet.de). 
TTF_font is defined as a simple pointer, and thecompatibility function have been
removed; TTF_GetError and TTF_SetError also have been removed as they only call 
the corresponding SDL functions anyway. In adition, TTF_linked_version is also
ommited.
Functions taking PChar types as arguments are overloaded and can be called with
string arguments.

Original header:
  
      SDL_ttf:  A companion library to SDL for working with TrueType (tm) fonts
      Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga
  
      This library is free software; you can redistribute it and/or
      modify it under the terms of the GNU Library General Public
      License as published by the Free Software Foundation; either
      version 2 of the License, or (at your option) any later version.
  
      This library is distributed in the hope that it will be useful,
      but WITHOUT ANY WARRANTY; without even the implied warranty of
      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
      Library General Public License for more details.
  
      You should have received a copy of the GNU Library General Public
      License along with this library; if not, write to the Free
      Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  
      Sam Lantinga
      slouken@libsdl.org

      This library is a wrapper around the excellent FreeType 2.0 library,
      available at:
      http://www.freetype.org/
   
------------------------------------------------------------------------------}


unit SDL_ttf;

interface

{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


uses SDL, SDL_types, SDL__rwops, SDL_video;


  const
    External_library='SDL_ttf';
    TTF_MAJOR_VERSION = 2;     
    TTF_MINOR_VERSION = 0;     
    TTF_PATCHLEVEL = 6;     
    UNICODE_BOM_NATIVE = $FEFF;     
    UNICODE_BOM_SWAPPED = $FFFE; 
    TTF_STYLE_NORMAL = $00;     
    TTF_STYLE_BOLD = $01;     
    TTF_STYLE_ITALIC = $02;     
    TTF_STYLE_UNDERLINE = $04;     
    
  Type
    Pchar  = ^char;
    Plongint  = ^longint;
    PSDL_RWops  = ^SDL_RWops;
    TTF_Font = Pointer;
    PUint16  = ^Uint16;

  { This function tells the library whether UNICODE text is generally
     byteswapped.  A UNICODE BOM character in a string will override
     this setting for the remainder of that string.
   }
    
  procedure TTF_ByteSwappedUNICODE(swapped:longint);cdecl;external External_library name 'TTF_ByteSwappedUNICODE';

  { The internal structure containing font information  }
  { Initialize the TTF engine - returns 0 if successful, -1 on error  }

  function TTF_Init:longint;cdecl;external External_library name 'TTF_Init';

  { Open a font file and create a font of the specified point size.
   * Some .fon fonts will have several sizes embedded in the file, so the
   * point size becomes the index of choosing which size.  If the value
   * is too high, the last indexed size will be the default.  }
  function TTF_OpenFont(tfile:Pchar; ptsize:longint):TTF_Font;cdecl;external External_library name 'TTF_OpenFont'; overload;
  function TTF_OpenFont(tfile: String; ptsize: Longint): TTF_Font; overload;

  function TTF_OpenFontIndex(tfile: Pchar; ptsize: longint; index: longint): TTF_Font;cdecl;external External_library name 'TTF_OpenFontIndex'; overload;
  function TTF_OpenFontIndex(tfile: String; ptsize: longint; index: longint): TTF_Font; overload;

  function TTF_OpenFontRW(var src: SDL_RWops; freesrc:longint; ptsize:longint):TTF_Font;cdecl;external External_library name 'TTF_OpenFontRW';

  function TTF_OpenFontIndexRW(var src: SDL_RWops; freesrc:longint; ptsize:longint; index:longint):TTF_Font;cdecl;external External_library name 'TTF_OpenFontIndexRW';

  { Set and retrieve the font style
     This font style is implemented by modifying the font glyphs, and
     doesn't reflect any inherent properties of the truetype font file.
   }

  function TTF_GetFontStyle(font:TTF_Font):longint;cdecl;external External_library name 'TTF_GetFontStyle';

  procedure TTF_SetFontStyle(font:TTF_Font; style:longint);cdecl;external External_library name 'TTF_SetFontStyle';

  { Get the total height of the font - usually equal to point size  }
  function TTF_FontHeight(font:TTF_Font):longint;cdecl;external External_library name 'TTF_FontHeight';

  { Get the offset from the baseline to the top of the font
     This is a positive value, relative to the baseline.
    }
  function TTF_FontAscent(font:TTF_Font):longint;cdecl;external External_library name 'TTF_FontAscent';

  { Get the offset from the baseline to the bottom of the font
     This is a negative value, relative to the baseline.
    }
  function TTF_FontDescent(font:TTF_Font):longint;cdecl;external External_library name 'TTF_FontDescent';

  { Get the recommended spacing between lines of text for this font  }
  function TTF_FontLineSkip(font:TTF_Font):longint;cdecl;external External_library name 'TTF_FontLineSkip';

  { Get the number of faces of the font  }
  function TTF_FontFaces(font:TTF_Font):longint;cdecl;external External_library name 'TTF_FontFaces';

  { Get the font face attributes, if any  }
  function TTF_FontFaceIsFixedWidth(font: TTF_Font): longint;cdecl;external External_library name 'TTF_FontFaceIsFixedWidth';

  function TTF_FontFaceFamilyName(font: TTF_Font): Pchar;cdecl;external External_library name 'TTF_FontFaceFamilyName';

  function TTF_FontFaceStyleName(font:TTF_Font):Pchar;cdecl;external External_library name 'TTF_FontFaceStyleName';

  { Get the metrics (dimensions) of a glyph  }
  function TTF_GlyphMetrics(font:TTF_Font; ch:Uint16; var minx, maxx, miny, maxy, advance: Longint):longint; cdecl;external External_library name 'TTF_GlyphMetrics';

  { Get the dimensions of a rendered string of text  }
  function TTF_SizeText(font: TTF_Font; text: Pchar; var w, h: Longint): longint;cdecl;external External_library name 'TTF_SizeText'; overload;
  function TTF_SizeText(font: TTF_Font; text: String; var w, h: Longint): longint; overload;

  function TTF_SizeUTF8(font: TTF_Font; text: Pchar; var w, h: Longint): longint;cdecl;external External_library name 'TTF_SizeUTF8';overload;
  function TTF_SizeUTF8(font: TTF_Font; text: String; var w, h: Longint): longint; overload;

  function TTF_SizeUNICODE(font: TTF_Font; text:PUint16; var w, h: Longint):longint;cdecl;external External_library name 'TTF_SizeUNICODE';

  { Create an 8-bit palettized surface and render the given text at
     fast quality with the given font and color.  The 0 pixel is the
     colorkey, giving a transparent background, and the 1 pixel is set
     to the text color.
     This function returns the new surface, or NULL if there was an error.
   }
  function TTF_RenderText_Solid(font: TTF_Font; text: Pchar; fg: SDL_Color): PSDL_Surface;cdecl;external External_library name 'TTF_RenderText_Solid'; overload;
  function TTF_RenderText_Solid(font: TTF_Font; text: String; fg: SDL_Color): PSDL_Surface; overload;

  function TTF_RenderUTF8_Solid(font: TTF_Font; text: Pchar; fg: SDL_Color): PSDL_Surface;cdecl;external External_library name 'TTF_RenderUTF8_Solid'; overload;
  function TTF_RenderUTF8_Solid(font: TTF_Font; text: String; fg: SDL_Color): PSDL_Surface; overload;

  function TTF_RenderUNICODE_Solid(font:TTF_Font; text:PUint16; fg:SDL_Color):PSDL_Surface;cdecl;external External_library name 'TTF_RenderUNICODE_Solid';

  { Create an 8-bit palettized surface and render the given glyph at
     fast quality with the given font and color.  The 0 pixel is the
     colorkey, giving a transparent background, and the 1 pixel is set
     to the text color.  The glyph is rendered without any padding or
     centering in the X direction, and aligned normally in the Y direction.
     This function returns the new surface, or NULL if there was an error.
   }
  function TTF_RenderGlyph_Solid(font:TTF_Font; ch:Uint16; fg:SDL_Color):PSDL_Surface;cdecl;external External_library name 'TTF_RenderGlyph_Solid';

  { Create an 8-bit palettized surface and render the given text at
     high quality with the given font and colors.  The 0 pixel is background,
     while other pixels have varying degrees of the foreground color.
     This function returns the new surface, or NULL if there was an error.
   }
  function TTF_RenderText_Shaded(font: TTF_Font; text: Pchar; fg: SDL_Color; bg:SDL_Color): PSDL_Surface;cdecl; external External_library name 'TTF_RenderText_Shaded'; overload;
  function TTF_RenderText_Shaded(font: TTF_Font; text: String; fg: SDL_Color; bg:SDL_Color): PSDL_Surface; overload;

  function TTF_RenderUTF8_Shaded(font: TTF_Font; text: Pchar; fg: SDL_Color; bg:SDL_Color): PSDL_Surface; cdecl;external External_library name 'TTF_RenderUTF8_Shaded'; overload;
  function TTF_RenderUTF8_Shaded(font: TTF_Font; text: String; fg: SDL_Color; bg:SDL_Color): PSDL_Surface; overload;

  function TTF_RenderUNICODE_Shaded(font:TTF_Font; text:PUint16; fg:SDL_Color; bg:SDL_Color):PSDL_Surface;cdecl;external External_library name 'TTF_RenderUNICODE_Shaded';

  { Create an 8-bit palettized surface and render the given glyph at
     high quality with the given font and colors.  The 0 pixel is background,
     while other pixels have varying degrees of the foreground color.
     The glyph is rendered without any padding or centering in the X
     direction, and aligned normally in the Y direction.
     This function returns the new surface, or NULL if there was an error.
   }
  function TTF_RenderGlyph_Shaded(font:TTF_Font; ch:Uint16; fg:SDL_Color; bg:SDL_Color):PSDL_Surface;cdecl;external External_library name 'TTF_RenderGlyph_Shaded';

  { Create a 32-bit ARGB surface and render the given text at high quality,
     using alpha blending to dither the font with the given color.
     This function returns the new surface, or NULL if there was an error.
   }
  function TTF_RenderText_Blended(font: TTF_Font; text: Pchar; fg: SDL_Color): PSDL_Surface;cdecl;external External_library name 'TTF_RenderText_Blended'; overload;
  function TTF_RenderText_Blended(font: TTF_Font; text: String; fg: SDL_Color): PSDL_Surface; overload;

  function TTF_RenderUTF8_Blended(font: TTF_Font; text: Pchar; fg: SDL_Color): PSDL_Surface;cdecl;external External_library name 'TTF_RenderUTF8_Blended'; overload;
  function TTF_RenderUTF8_Blended(font: TTF_Font; text: String; fg: SDL_Color): PSDL_Surface; overload;

  function TTF_RenderUNICODE_Blended(font:TTF_Font; text:PUint16; fg:SDL_Color):PSDL_Surface;cdecl;external External_library name 'TTF_RenderUNICODE_Blended';

  { Create a 32-bit ARGB surface and render the given glyph at high quality,
     using alpha blending to dither the font with the given color.
     The glyph is rendered without any padding or centering in the X
     direction, and aligned normally in the Y direction.
     This function returns the new surface, or NULL if there was an error.
   }
  function TTF_RenderGlyph_Blended(font:TTF_Font; ch:Uint16; fg:SDL_Color):PSDL_Surface;cdecl;external External_library name 'TTF_RenderGlyph_Blended';

  { Close an opened font file  }
  procedure TTF_CloseFont(font:TTF_Font);cdecl;external External_library name 'TTF_CloseFont';

  { De-initialize the TTF engine  }
  procedure TTF_Quit;cdecl;external External_library name 'TTF_Quit';

  { Check if the TTF engine is initialized  }
  function TTF_WasInit:longint;cdecl;external External_library name 'TTF_WasInit';

implementation

uses Strings;

{$INLINE ON}

function Str2PChar(i: String): PChar; inline;
var
  data: PChar;
begin
  data := StrAlloc(Length(i) + 1);
  result := StrPCopy(data, i);  
end;

function TTF_OpenFont(tfile: String; ptsize: Longint): TTF_Font; overload;
var  
  data: PChar;
begin
  data := Str2PChar(tfile);
  result := TTF_OpenFont(data, ptsize);
  StrDispose(data);
end;

function TTF_OpenFontIndex(tfile: String; ptsize: longint; index: longint): TTF_Font; overload;
var  
  data: PChar;
begin
  data := Str2PChar(tfile);
  result := TTF_OpenFontIndex(data, ptsize, index);
  StrDispose(data);
end;

function TTF_SizeText(font: TTF_Font; text: String; var w, h: Longint): longint; overload;
var
 data: PChar;
begin;
  data := Str2PChar(text);
  result := TTF_SizeText(font, data, w, h);
  StrDispose(Data);
end;

function TTF_SizeUTF8(font: TTF_Font; text: String; var w, h: Longint): longint; overload;
var
 data: PChar;
begin
  data := Str2PChar(text);
  result := TTF_SizeUTF8(font, data, w, h);
  StrDispose(Data);
end;

function TTF_RenderText_Solid(font: TTF_Font; text: String; fg: SDL_Color): PSDL_Surface; overload;
var
  data: PChar;
begin
  data := Str2PChar(text);
  result := TTF_RenderText_Solid(font, data, fg);
  StrDispose(Data);
end;

function TTF_RenderUTF8_Solid(font: TTF_Font; text: String; fg: SDL_Color): PSDL_Surface; overload;
var
  data: PChar;
begin
  data := Str2PChar(text);
  result := TTF_RenderUTF8_Solid(font, data, fg);
  StrDispose(Data);
end;

function TTF_RenderText_Shaded(font: TTF_Font; text: String; fg: SDL_Color; bg:SDL_Color): PSDL_Surface; overload;
var
  data: PChar;
begin
  data := Str2PChar(text);
  result := TTF_RenderText_Shaded(font, data, fg, bg);
  StrDispose(Data);
end;

function TTF_RenderUTF8_Shaded(font: TTF_Font; text: String; fg: SDL_Color; bg:SDL_Color): PSDL_Surface; overload;
var
  data: PChar;
begin
  data := Str2PChar(text);
  result := TTF_RenderUTF8_Shaded(font, data, fg, bg);
  StrDispose(Data);
end;

function TTF_RenderText_Blended(font: TTF_Font; text: String; fg: SDL_Color): PSDL_Surface; overload;
var
  data: PChar;
begin
  data := Str2PChar(text);
  result := TTF_RenderText_Blended(font, data, fg);
  StrDispose(Data);
end;

function TTF_RenderUTF8_Blended(font: TTF_Font; text: String; fg: SDL_Color): PSDL_Surface; overload;
var
  data: PChar;
begin
  data := Str2PChar(text);
  result := TTF_RenderUTF8_Blended(font, data, fg);
  StrDispose(Data);
end;

end.