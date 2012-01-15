CFLAGS = -g -Wall
scena: main.o render.o
	gcc $(CFLAGS) main.o render.o `allegro-config --libs` -lm -o scena

main.o: main.c
	gcc $(CFLAGS) -lm -c main.c `-I/usr/include` -o main.o

render.o: render.s
	nasm -f elf64 -g render.s

clean:
	rm -f scena render.o main.o

test: scena
	./scena
