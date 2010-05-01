files = graphdemo
ppus = ../core/*.ppu ../graphics/*.ppu ../headers/*.ppu

graphdemo: graphdemo.pas $(ppus)
	$(pp) $(args) $(pathargs) graphdemo.pas

all: $(files)

clean:
	$(delpp) .
	rm -f graphdemo