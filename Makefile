
# $< is the first dependency

sudokell: sudokell.hs
	@ghc -dynamic -threaded $<

clean:
	@echo Removing artifacts...
	rm sudokell sudokell.o sudokell.hi

example: sudokell
	./$< +RTS -N8 -RTS 1 0 0 0 0 0 0 4 5 4 0 0 7 0 0 0 0 0 0 5 7 0 0 0 3 8 0 8 0 0 5 9 0 4 0 0 0 0 6 0 2 0 5 0 0 0 0 9 0 7 3 0 0 8 0 1 5 0 0 0 8 6 0 0 0 0 0 0 8 0 0 7 9 7 0 0 0 0 0 0 4

.PHONY: clean example
