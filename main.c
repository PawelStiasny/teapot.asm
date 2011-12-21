// #include <stdlib.h>
#include <allegro.h>
#include <stdio.h>

#include "points.h"

#define _SCREEN_W 640
#define _SCREEN_H 480

void render(long **gbuffer, long *points, unsigned long num_points,
		long movx, long movy);

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
		rest(25);
		clear(buf);
	}
	return 0;
}
END_OF_MAIN()
