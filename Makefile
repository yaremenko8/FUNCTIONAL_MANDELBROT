CC = ghc
HSSFLAGS = -threaded -rtsopts
all : mru
mru : Main.hs Mandelbrot.hs
	$(CC) $(HSSFLAGS) $< -o $@
clean :
	rm -f  *.o *.hi mru

