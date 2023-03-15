# Makefile

all: fibonacci galois

fibonacci:
	@$(MAKE) -f Makefile.galois.f clean
	@$(MAKE) -f Makefile.fibonacci.f

galois:
	@$(MAKE) -f Makefile.fibonacci.f clean
	@$(MAKE) -f Makefile.galois.f

clean:
	@$(MAKE) -f Makefile.fibonacci.f clean
	@$(MAKE) -f Makefile.galois.f clean