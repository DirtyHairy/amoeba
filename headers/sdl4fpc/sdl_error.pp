unit SDL_error;
interface

{
  Automatically converted by H2Pas 0.99.15 from SDL_error.h
  The following command line parameters were used:
    -d
    -e
    SDL_error.h
}

{ Manually edited by Elio Cuevas Gómez: elcugo@yahoo.com.mx }

{$PACKRECORDS C}

  {
      SDL - Simple DirectMedia Layer
      Copyright (C) 1997, 1998, 1999, 2000, 2001, 2002  Sam Lantinga
  
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
   }
    { Simple error message routines for SDL  }
    { Public functions  }
    //procedure SDL_SetError(fmt: PChar; values: array of const); cdecl; 
    function SDL_GetError: PChar; cdecl;
    procedure SDL_ClearError; cdecl;
    { Private error message function - used internally  }
    { was #define dname(params) para_def_expr }
    //procedure SDL_OutOfMemory;


    type

       SDL_errorcode =  Longint;
       Const
         SDL_ENOMEM = 0;
         SDL_EFREAD = 1;
         SDL_EFWRITE = 2;
         SDL_EFSEEK = 3;
         SDL_LASTERROR = 4;

    //procedure SDL_Error_(code:SDL_errorcode);cdecl;

implementation
    //procedure SDL_SetError(fmt: PChar; values: array of const); cdecl; 
    // external 'SDL';

    function SDL_GetError: PChar; cdecl; external 'SDL';
    
    procedure SDL_ClearError; cdecl; external 'SDL';
    
    { was #define dname(params) para_def_expr }
    {procedure SDL_OutOfMemory;
      begin
         SDL_Error_(SDL_ENOMEM);
      end;}

    //procedure SDL_Error(code: SDL_errorcode);cdecl; external 'SDL';
end.
