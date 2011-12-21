CFLAGS = -m32
text: main.o render.o points.c
	gcc $(CFLAGS) main.o render.o points.c -L/usr/lib -lalleg -o scena --debug

main.o: main.c
	gcc $(CFLAGS) -c main.c -I/usr/include -o main.o --debug -Wall

render.o: render.s
	nasm -f elf render.s

clean:
	rm -f scena render.o main.o

test:
	./scena
