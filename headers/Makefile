files = SDL_ttf.ppu

SDL_ttf.ppu: SDL_ttf.pas
	$(pp) $(args) $(pathargs) SDL_ttf.pas

all: $(files)

clean:
	$(delpp) .
	rm -f SDL_ttf.o
