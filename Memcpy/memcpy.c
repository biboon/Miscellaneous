#include <stdio.h>
#include <string.h>
#include <time.h>

#define likely(x) __builtin_expect((x),1)

struct task {
	void *(*function)(void *, const void *, size_t);
	char name[10];
};


void *memcpy2(void *dst, const void *src, size_t size)
{
	void *_dst = dst;
	while (size--) *((char *)(dst++)) = *((const char *)(src++));
	return _dst;
}

void *memcpy3(void *dst, const void *src, size_t size)
{
	char *_dst = dst;
	const char *_src = src;
	unsigned *_udst;
	const unsigned *_usrc;

	if (likely(size > 3)) {
		unsigned buf_left, buf_right;
		/* Align destination to word */
		switch ((unsigned long)_dst & 3) {
			case 1:
				*_dst++ = *_src++;
				--size;
			case 2:
				*_dst++ = *_src++;
				--size;
			case 3:
				*_dst++ = *_src++;
				--size;
		}
		/* Choose a copy scheme based on the source alignement */
		_udst = (void *)_dst;
		switch((unsigned long)_src & 3) {
			case 0:
				_usrc = (const void *)_src;
				for ( ; size >= sizeof(unsigned); size -= sizeof(unsigned)) {
					*_udst++ = *_usrc++;
				}
				_src = (const void *)_usrc;
				break;
			case 1:
				_usrc = (const void *)((unsigned long)_src & ~3);
				buf_left = *_usrc++ >> 8;
				for ( ; size >= sizeof(unsigned); size -= sizeof(unsigned)) {
					buf_right = *_usrc;
					*_udst++ = buf_left | (buf_right << 24);
					buf_left = buf_right >> 8;
				}
				_src = (const void *)_usrc;
				_src -= 3;
				break;
			case 2:
				_usrc = (const void *)((unsigned long)_src & ~3);
				buf_left = *_usrc++ >> 16;
				for ( ; size >= sizeof(unsigned); size -= sizeof(unsigned)) {
					buf_right = *_usrc;
					*_udst++ = buf_left | (buf_right << 16);
					buf_left = buf_right >> 16;
				}
				_src = (const void *)_usrc;
				_src -= 2;
				break;
			case 3:
				_usrc = (const void *)((unsigned long)_src & ~3);
				buf_left = *_usrc++ >> 24;
				for ( ; size >= sizeof(unsigned); size -= sizeof(unsigned)) {
					buf_right = *_usrc;
					*_udst++ = buf_left | (buf_right << 8);
					buf_left = buf_right >> 24;
				}
				_src = (const void *)_usrc;
				_src -= 1;
				break;
		}
		_dst = (void *)_udst;
	}
	switch (size) {
		case 3:
			*_dst++ = *_src++;
			--size;
		case 2:
			*_dst++ = *_src++;
			--size;
		case 1:
			*_dst++ = *_src++;
			--size;
	}
	return dst;
}


void print_size(double size)
{
	char prefixes[] = "kMGT";
	char *ptr = prefixes;

	if (size < 1024) { printf("%f", size); return; }
	do {
		size /= 1024;
	} while (size > 1024 && *(ptr++) != '\0');
	printf("%f %c", size, *ptr);
}

void test(size_t size, struct task function)
{
	char _dst[size], _src[size];
	char *dst = _dst, *src = _src;
	unsigned loops = 0xFFFFFFFF / size, i;
	//loops = 1;
	clock_t start, stop;

	memset(_src, -1, sizeof(_dst));
	memset(_dst, 0, sizeof(_dst));
	/* Start the loop */
	src++; size--;
	start = clock();
	for (i = 0; i < loops; ++i)
		function.function(dst, src, size);
	stop = clock();
	/* Display results */
	double useconds = (double)(stop - start) / CLOCKS_PER_SEC;
	double speed = (double)(size * loops) / useconds;
	printf("%s: \t%8lu bytes copied at ", function.name, size);
	print_size(speed);
	printf("B/s... ");
	/* Check if it is effectively copied */
	while (size--) {
		if (*(dst++) != *(src++)) {
			printf("failed\n");
			return;
		}
	}
	printf("ok\n");
}


int main(int argc, char const *argv[])
{
	unsigned i, j;
	struct task functions[] = {
//		{ memcpy, "memcpy" },
//		{ memcpy2, "memcpy2" },
		{ memcpy3, "memcpy3" }
	};
	size_t sizes[] = {
		4 + 3, 64 + 3, 256 + 3,
		4 * 1024 + 1, 64 * 1024 + 1, 256 * 1024 + 1,
		4 * 1024 + 2, 64 * 1024 + 2, 256 * 1024 + 2,
		4 * 1024 + 3, 64 * 1024 + 3, 256 * 1024 + 3,
		1024 * 1024
	};

	for (i = 0; i < sizeof(functions) / sizeof(struct task); ++i) {
		for (j = 0; j < sizeof(sizes) / sizeof(size_t); ++j)
			test(sizes[j], functions[i]);
		putchar('\n');
	}
	return 0;
}
