# sudokell

Sudoku solver in Haskell, to try recursion and parallelism tricks.

## Usage:

* Compile: `ghc -dynamic -threaded sudokell`
* Run: `./sudokell +RTS -N8 -RTS 1 0 0 0 0 0 0 4 5 4 0 0 7 0 0 0 0 0 0 5 7 0 0 0 3 8 0 8 0 0 5 9 0 4 0 0 0 0 6 0 2 0 5 0 0 0 0 9 0 7 3 0 0 8 0 1 5 0 0 0 8 6 0 0 0 0 0 0 8 0 0 7 9 7 0 0 0 0 0 0 4`

The `+RTS -N8 -RTS` flags are to tell the RTS to use 8 cores.

The program expects the 81 initial values of the grid,
ordered by rows, using 0 to indicate missing ones.
