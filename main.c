#include <allegro.h>
#include <stdio.h>
#include <math.h>
#include <assert.h>
#include <locale.h>

unsigned long num_points = 0;
float *points = NULL;

#define _SCREEN_W 640
#define _SCREEN_H 480

void render(int **gbuffer, float *points, unsigned long num_points,
		float* movmx, float* rotmx);

#define swap(a,b,t) t = a; a = b; b = t;

/* for SSE debugging */
void print_vec(float a, float b, float c, float d)
{
	printf("%f %f %f %f\n", a, b, c, d);
	rest(100);
}

void load_points(const char* filename)
{
	FILE* f = fopen(filename, "r");
	assert(f != NULL);
	fscanf(f, "%lu", &num_points);
	printf("num_points = %lu\n", num_points);
	points = malloc((num_points+1) * 32);
	/* 16-byte alignment */
	points = (void*)(
			(unsigned long)points +
			(unsigned long)(16 - ((unsigned long)points % 16)));

	unsigned long i;
	for (i = 0; i < num_points; i++) {
		float* line = points + i*8;
		line[3] = line[7] = 1.0f;
		if (
			fscanf(f, "%f %f %f %f %f %f",
				&line[0], &line[1], &line[2],
				&line[4], &line[5], &line[6])
			!= 6)
		{
			printf("invalid input on line %ld\n", i+2);
		}
	}
	fclose(f);
}

void draw_line(int** bmp, long x, long y, long x1, long y1)
{
	if (x < 0 || x >= 640 || y < 0 || y >= 480 ||
			x1 < 0 || x1 >= 640 || y1 < 0 || y1 >= 480)
		return;

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

void make_rotation(float* mx, float x, float y, float z)
{
	float six = sin(x);
	float siy = sin(y);
	float siz = sin(z);
	float cox = cos(x);
	float coy = cos(y);
	float coz = cos(z);

	mx[0] = six*siy*siz+coy*coz;
	mx[4] = six*siy*coz-coy*siz;
	mx[8] = cox*siy;

	mx[1] = cox*siz;
	mx[5] = cox*coz;
	mx[9] = -six;
	
	mx[2] = six*coy*siz-siy*coz;
	mx[6] = siy*siz+six*coy*coz;
	mx[10] = cox*coy;

	mx[3] = mx[7] = mx[11] = 0;
}

void turn(float* val, float deg)
{
	*val += deg;
	if (*val > 6.28) *val = *val - 6.28;
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

	/* required for reliable parsing of point-delimeted floats */
	setlocale(LC_NUMERIC, "C");
	load_points("teapot");

	float movmx[4] = { 320.0, 400.0, 0.0, 0.0 };
	float rotx = 3.14, roty = 0, rotz = 0;
	float rotation[12];
	for(;;) {
		if (key[KEY_ESC]) return 0;

		if (key[KEY_UP]) movmx[1]--;
		if (key[KEY_DOWN]) movmx[1]++;
		if (key[KEY_LEFT]) movmx[0]--;
		if (key[KEY_RIGHT]) movmx[0]++;

		if (key[KEY_Z]) turn(&rotz, 0.1);
		if (key[KEY_A]) turn(&rotz, -0.1);

		if (key[KEY_X]) turn(&rotx, 0.1);
		if (key[KEY_S]) turn(&rotx, -0.1);

		if (key[KEY_C]) turn(&roty, 0.1);
		if (key[KEY_D]) turn(&roty, -0.1);

		make_rotation(rotation, rotx, roty, rotz);
		render((int**)buf->line, points, num_points, movmx, rotation);
		blit(buf, screen, 0, 0, 0, 0, _SCREEN_W, _SCREEN_H);
		rest(25);
		clear(buf);
	}
	return 0;
}
END_OF_MAIN()
