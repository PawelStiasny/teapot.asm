// #include <stdlib.h>
#include <allegro.h>
#include <stdio.h>

void render();

int main(int argc, char** argv)
{
	allegro_init();
	install_keyboard();
	install_timer();
	set_color_depth(8);
	set_gfx_mode(GFX_AUTODETECT_WINDOWED, 640, 480, 0, 0);
	printf("%d\n", get_color_depth());
	BITMAP *buf = create_bitmap(640,480);
	int i;
	for(;;) {
		//for (i = 0; i < 480; i += 10) {
		/*
		for (i = 0; i < 630; i += 1) {
			if (key[KEY_ESC]) return 0;
			rest(1000);
			//fastline(buf, 0, i, 639, i, makecol(255,0,0));
			ellipsefill(buf, i, 320, 20, 20, makecol(255,20,20));
			blit(buf, screen, 0, 0, 0, 0, 640, 480);
		}
		clear(buf);
		blit(buf, screen, 0, 0, 0, 0, 640, 480);
		for (i = 470; i >= 0; i -= 10) {
			if (key[KEY_ESC]) return 0;
			rest(1000);
			fastline(buf, 0, i, 639, i, makecol(255,0,0));
			blit(buf, screen, 0, 0, 0, 0, 640, 480);
		}
		clear(buf);
		blit(buf, screen, 0, 0, 0, 0, 640, 480);*/
		unsigned x, y;
		if (key[KEY_ESC]) return 0;
		for (x = 0; x < 640; x++)
			for (y = 0; y < 480; y++)
				buf->line[y][x] = rand();
		blit(buf, screen, 0, 0, 0, 0, 640, 480);
		rest(20);
	}
	//readkey();
	return 0;
}
END_OF_MAIN()
