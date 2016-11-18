#include <stdio.h>
#include <string.h>
#include <time.h>


void *memcpy2(void *dst, const void *src, size_t size)
{
	void *_dst = dst;
	while (size--) *((char *)(dst++)) = *((const char *)(src++));
	return _dst;
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

void test(size_t size, void *(*function)(void *, const void *, size_t))
{
	char _dst[size], _src[size];
	char *dst = _dst, *src = _src;
	unsigned loops = 0x7FFFFFFF / size, i;
	clock_t start, stop;

	/* Start the loop */
	start = clock();
	for (i = 0; i < loops; ++i)
		function(dst, src, size);
	stop = clock();
	/* Display results */
	double useconds = (double)(stop - start) / CLOCKS_PER_SEC;
	double speed = (double)(size * loops) / useconds;
	printf("%lu bytes copied at ", size);
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
	void *(*functions[])(void *, const void*, size_t) = {
		memcpy,
		memcpy2
	};
	size_t sizes[] = {
		4, 64, 256,
		4 * 1024, 64 * 1024, 256 * 1024
	};

	for (j = 0; j < sizeof(sizes) / sizeof(size_t); ++j)
		for (i = 0; i < sizeof(functions) / sizeof(void *(*)(void *, const void*, size_t)); ++i)
			test(sizes[j], functions[i]);
	return 0;
}
