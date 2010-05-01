#amoeba makefile

#compiler and tools
pp = fpc
delpp = delp

#add compiler arguments here
args = -Sd -dHAVE_DEBUG -O3 -g -Si

#define paths
pathargs = -Fu../graphics -Fu../core -O3 -Fu../headers

export

all:
	cd graphics && $(MAKE) all
	cd core && $(MAKE) all
	cd headers && $(MAKE) all

demos: all
	cd demos && $(MAKE) all

clean:
	cd graphics && $(MAKE) clean
	cd core && $(MAKE) clean
	cd demos && $(MAKE) clean
