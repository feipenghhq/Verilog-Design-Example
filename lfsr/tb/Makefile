# Makefile

all: fibonacci galois

fibonacci:
	@$(MAKE) -f Makefile.galois clean
	@$(MAKE) -f Makefile.fibonacci

galois:
	@$(MAKE) -f Makefile.fibonacci clean
	@$(MAKE) -f Makefile.galois

clean:
	@$(MAKE) -f Makefile.fibonacci clean
	@$(MAKE) -f Makefile.galois clean