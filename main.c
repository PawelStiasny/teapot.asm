// #include <stdlib.h>
#include <allegro.h>
#include <stdio.h>
#include <math.h>
#include <assert.h>

#include "points.h"

#define _SCREEN_W 640
#define _SCREEN_H 480

void render(long **gbuffer, long *points, unsigned long num_points,
		long movx, long movy);

#define swap(a,b,t) t = a; a = b; b = t;

void draw_line(long** bmp, long x, long y, long x1, long y1)
{
	/*fprintf(stderr, "draw_line called, %ld, %ld, %ld, %ld\n", x, y, x1, y1);
	fflush(stderr);*/

	assert(0 <= x && x < 640);
	assert(0 <= y && y < 480);
	assert(0 <= x1 && x1 < 640);
	assert(0 <= y1 && y1 < 480);


	int steep = abs(y1-y) > abs(x1-x);
	long t;
	if (steep) {
		swap(x, y, t);
		swap(x1, y1, t);
	}
	if (x > x1) {
		swap(x, x1, t);
		swap(y, y1, t);
	}
	long dx = x1 - x, dy = abs(y1 - y);
	long error = dx >> 1;
	//double derror = dy / dx
	long ystep = (y < y1) ? 1 : -1;
	while (x <= x1) {
		if (steep) {
			bmp[x][y] = 0xffffff;
		} else {
			bmp[y][x] = 0xffffff;
		}
		error -= dy;
		if (error < 0) {
			y += ystep;
			error += dx;
		}
		x++;
	}
	/*rest(100);
	fprintf(stderr, "draw_line exiting\n");
	fflush(stderr);*/
}

int main(int argc, char** argv)
{
	allegro_init();
	install_keyboard();
	install_timer();
	set_color_depth(32);
	set_gfx_mode(GFX_AUTODETECT_WINDOWED, _SCREEN_W, _SCREEN_H, 0, 0);
	BITMAP *buf = create_bitmap(_SCREEN_W,_SCREEN_H);
	clear(buf);

	long movx = 0, movy = 0;
	for(;;) {
		if (key[KEY_ESC]) return 0;
		if (key[KEY_UP]) movx--;
		if (key[KEY_DOWN]) movx++;
		if (key[KEY_LEFT]) movy--;
		if (key[KEY_RIGHT]) movy++;

		render((long**)buf->line, points, num_points, movx, movy);
		blit(buf, screen, 0, 0, 0, 0, _SCREEN_W, _SCREEN_H);
		//return 1;
		rest(25);
		clear(buf);
	}
	return 0;
}
END_OF_MAIN()
