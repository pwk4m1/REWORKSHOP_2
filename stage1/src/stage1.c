/*
 * First of the challenges, simple "crack-me" type of program.
 * 
 * This program asks for user-input, and if user-input matches
 * required pass-code, it'll execute, othervice it'll close itself.
 */

#include <sys/types.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

char
gen_pwd_byte(int i)
{
	char *hex_str = "0123456789ABCDEF";

	if (!(i % 2)) {
		return (char)hex_str[(i * 3) % 16];
	} else {
		return (char)hex_str[(i + 5) % 16];
	}
}

void
usage(char *name)
{
	printf("%s <pass-key>\n", name);
}


int
main(int argc, char **argv)
{
	int i;
	char buf[64];

	if (argc != 2) {
		usage(argv[0]);
		return -1;
	}

	memset(buf, 0, 64);

	for (i = 0; i < 64; i++) {
		buf[i] = gen_pwd_byte(i);
	}
	buf[i++] = '\0';

	if (strcmp(buf, argv[1])) {
		printf("Invalid key provided.\n");
		return -2;
	} else {
		printf("Correct\n");
		return 0;
	}
}


