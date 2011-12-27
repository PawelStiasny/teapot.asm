// #include <stdlib.h>
#include <allegro.h>
#include <stdio.h>
#include <math.h>
#include <assert.h>

#include "points.h"

#define _SCREEN_W 640
#define _SCREEN_H 480

void render(long **gbuffer, float *points, unsigned long num_points,
		float* movmx, float* rotmx);

#define swap(a,b,t) t = a; a = b; b = t;

void print_vec(float a, float b, float c, float d)
{
	printf("%f %f %f %f\n", a, b, c, d);
}

void draw_line(long** bmp, long x, long y, long x1, long y1)
{
	/*fprintf(stderr, "draw_line called, %ld, %ld, %ld, %ld\n", x, y, x1, y1);
	fflush(stderr);*/
	assert(0 <= x && x < 640);
	assert(0 <= y && y < 480);
	assert(0 <= x1 && x1 < 640);
	assert(0 <= y1 && y1 < 480);
	/*rest(25);*/

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
}

void make_rotation(float* mx, double x, double y, double z)
{
	mx[0] = sin(x)*sin(y)*sin(z)+cos(y)*cos(z);
	mx[1] = sin(x)*sin(y)*cos(z)-cos(y)*sin(z);
	mx[2] = cos(x)*sin(y);
	mx[3] = 0;

	mx[4] = cos(x)*sin(z);
	mx[5] = cos(x)*cos(z);
	mx[6] = -sin(x);
	mx[7] = 0;
	
	mx[8] = sin(x)*cos(y)*sin(z)-sin(y)*cos(z);
	mx[9] = sin(y)*sin(z)+sin(x)*cos(y)*cos(z);
	mx[10] = cos(x)*cos(y);
	mx[11] = 0;
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

	float movmx[4] = { 0.0, 0.0, 0.0, 0.0 };
	float rotz = 0;
	float rotation[12];
	for(;;) {
		if (key[KEY_ESC]) return 0;
		if (key[KEY_UP]) movmx[1]--;
		if (key[KEY_DOWN]) movmx[1]++;
		if (key[KEY_LEFT]) movmx[0]--;
		if (key[KEY_RIGHT]) movmx[0]++;
		if (key[KEY_Z]) {
			rotz += 0.2;
			if (rotz > 6.28) rotz = rotz - 6.28; }
		if (key[KEY_A]) {
			rotz -= 0.2;
			if (rotz < 0) rotz = 6.28 - rotz; }

		make_rotation(rotation, 0, 0, rotz);
		render((long**)buf->line, points, num_points, movmx, rotation);
		blit(buf, screen, 0, 0, 0, 0, _SCREEN_W, _SCREEN_H);
		//return 1;
		rest(25);
		clear(buf);
	}
	return 0;
}
END_OF_MAIN()
