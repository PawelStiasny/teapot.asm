CFLAGS = -m32
text: main.o render.o
	gcc $(CFLAGS) main.o render.o -L/usr/lib -lalleg -o scena

main.o: main.c
	gcc $(CFLAGS) -c main.c -I/usr/include -o main.o

render.o: render.s
	nasm -f elf render.s

clean:
	rm -f scena render.o main.o

test:
	./scena
