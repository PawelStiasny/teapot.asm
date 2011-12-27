CFLAGS = -m32 -g -Wall
scena: main.o render.o
	gcc $(CFLAGS) -lm main.o render.o -L/usr/lib -lalleg -o scena

main.o: main.c points.h
	gcc $(CFLAGS) -lm -c main.c -I/usr/include -o main.o

render.o: render.s
	nasm -f elf -F stabs -g render.s

clean:
	rm -f scena render.o main.o

test: scena
	./scena
