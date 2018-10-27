/*
 * This code is for the very freshest newcomers to the
 * world of C, asm, reversing, all of it.
 * 
 * Basicly, the code explains itself, hopefully, and
 * shows how it's converted to assembly, and how it's
 * executed.
 *
 * This code may, or may not be used during the event, and is not
 * considered as a challenge for people, more like just a reference
 * or a cheat-sheet, kind of.
 */

/*
 * Following lines are for including different library code,
 * such as printf() from stdio.h for outputing stuff.
 * 
 * See openbsd man (9) style for how to factor the code.
 * sys/ includes are the first ones to come
 */

#include <sys/types.h> /* Different types that we can use */

/* Includes are in alphabetical order */
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/* 
 * Defining functions works in the following way:
 *
 * return type
 * name(arguments)
 * {
 *   code
 * }
 *
 * eg.
 *
 * int
 * main(int argc, char *argv[])
 * {
 * 	return 0;
 * }
 *
 * the code above defines the main function of this file to return
 * integer, and having 2 arguments, integer argument count, ant
 * char * argument array.
 */

/*
 * This function is used  to show a fancy greeting message
 * for user :)
 * 
 * Returns 0 on successs or non-zero if printf() fails.
 */
int
say_hello(char *message)
{
	int ret;

	ret = printf("Hello: %s\n", message);
	return ret;
}

/*
 * If user does not know how-to use this program, we'll
 * show a syntax message.
 *
 * Returns 0 on success or non-zero if printf() fails.
 */
int
usage(char *name_of_program)
{
	int ret;

	ret = printf("Syntax: %s <name>\n", name_of_program);
	return ret;
}

/*
 * Main function of this program, called by _init, which expects
 * this to return int, we'll have to define it as such.
 *
 * Returns 0 on success or non-zero value on error.
 */
int
main(int argc, char *argv[])
{
	/* See if amount of command-line arguments is 2 */
	if (argc != 2) {
		/* if not, show usage */
		return usage(argv[0]);
	}
	/* argument count is 2 (name of program is 1st argument) */
	return say_hello(argv[1]);
}


