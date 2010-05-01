files = coreinit.ppu amoebadebug.ppu exceptions.ppu

coreinit.ppu: coreinit.pas
	$(pp) $(args) $(pathargs) coreinit.pas

amoebadebug.ppu: amoebadebug.pas
	$(pp) $(args) $(pathargs) amoebadebug.pas

exceptions.ppu: exceptions.pas
	$(pp) $(args) $(pathargs) exceptions.pas

all: $(files)

clean:
	$(delpp) .

