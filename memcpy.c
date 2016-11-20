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
	unsigned *_udst, *_usrc;

	if (likely(size > 3)) {
		switch (((unsigned long)_dst & 3)) {
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
		_udst = (unsigned *)_dst; _usrc = (unsigned *)_src;
		while(size >= sizeof(unsigned)) {
			*_udst++ = *_usrc++;
			size -= sizeof(unsigned);
		}
		_dst = (char *)_udst; _src = (const char *)_usrc;
	}
	switch (((unsigned long)_dst & 3)) {
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
	while (size--) *(_dst++) = *(_src++);
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
	unsigned loops = 0xFFFFFF / size, i;
	clock_t start, stop;

	memset(_dst, 0, sizeof(_dst));
	/* Start the loop */
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
		{ memcpy, "memcpy" },
		{ memcpy2, "memcpy2" },
		{ memcpy3, "memcpy3" }
	};
	size_t sizes[] = {
		4 + 1, 64 + 1, 256 + 1,
		4 * 1024, 64 * 1024, 256 * 1024
	};

	for (i = 0; i < sizeof(functions) / sizeof(struct task); ++i) {
		for (j = 0; j < sizeof(sizes) / sizeof(size_t); ++j)
			test(sizes[j], functions[i]);
		putchar('\n');
	}
	return 0;
}
