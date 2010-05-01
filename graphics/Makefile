files = graphcore.ppu graphengine.ppu fonts.ppu

graphcore.ppu: graphcore.pas
	$(pp) $(args) $(pathargs) graphcore.pas

graphengine.ppu: graphengine.pas
	$(pp) $(args) $(pathargs) graphengine.pas

fonts.ppu: fonts.pas
	$(pp) $(args) $(pathargs) fonts.pas

all: $(files)

clean:
	$(delpp) .