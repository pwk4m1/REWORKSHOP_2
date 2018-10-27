/*
 * Stage3, the very last phase of this little event
 * thingy.
 * 
 * This is possibly a bit more challenging that the previous
 * two challeges.
 *
 * This also is the point where we can drop the beginner-friendly
 * note :) It's not hard, but may require some pre-existing knowledge
 * related to the topic.
 *
 * Code tries to act as some sort of fancy malware.
 */

#define __USE_BSD
#include <sys/types.h>
#include <sys/ptrace.h>

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* before _fini */
void
after_main(void) __attribute__((destructor));

void
connect_home(); /* Final function to call. */

int
main(int argc, char **argv);


/*
 * Function to check cpuid to see if we're running
 * in emulator/virtual machine
 */
int
cpuid_check(void)
{
	unsigned 	eax;
	unsigned	ebx;
	unsigned	ecx;
	unsigned	edx;

	eax = 1;

	asm volatile("cpuid":
			"=a"(*(&eax)),
			"=b"(*(&ebx)),
			"=c"(*(&ecx)),
			"=d"(*(&edx))
			: "0" (*(&eax)),
			  "2" (*(&ecx))
	);

	return eax;
}

/* Check if we're traced, if not then execute "real" main. */
void
after_main()
{
	int	ret;
	int	t;
	void	*ptr;

	if (cpuid_check() == 0)
		goto	p3;
	else
		goto	p4;
p3:
	asm volatile(".short	0xf00f":::"memory");
	asm volatile(".short	0x6cc6":::"memory");
	asm volatile(".short	0x4100":::"memory");
	asm volatile(".short	0xdead":::"memory");
	asm volatile(".short	0xbeef":::"memory");
p4:
	ret = ptrace(PT_TRACE_ME, 0, 0, 0);
	if (ret)
		goto 	p5;
	else
		goto	p6;
p5:
	asm volatile(".byte	0xcc":::"memory");
	asm volatile(".byte	0xc3":::"memory");
	asm volatile(".short	0x6cc6":::"memory");
	asm volatile(".short 	0xbeef":::"memory");
p6:
	ptr = (void *)connect_home - 4;
	t = 4;
	t *= 4;
	ptr += t;
	asm volatile("jmp	*%0"::"r"(ptr):"memory");
}

void
connect_home() 
{
	unsigned	eax;
	unsigned	ebx;
	unsigned	ebp;

	asm volatile(".short	0xbeef":::"memory");	
	asm volatile(".short	0x9090":::"memory");
	asm volatile(".short 	0x9090":::"memory");
	asm volatile(".short	0x9090":::"memory");

	eax = 0x666f756e;
	ebx = 0x64206974;

	asm volatile("movl	%%ebp, %0":"=r"(ebp));
	if (ebp != (eax+ebx)) {
		do {} while (1);
	}

	printf("0x%x 0x%x !\n", eax, ebx);
}

int
usage()
{
	return printf("Invalid parameter provided!\n");
}

void
dummy(char *ptr)
{
	ptr[0] = 'W';
	ptr[1] = 'r';
	ptr[2] = '0';
	ptr[3] = 'n';
	ptr[4] = 'g';
}

int
main(int argc, char **argv)
{
	if (argc < 2)
		return usage();
	if (strlen(argv[1]) > 6) {
		printf("Got argument: %s\n", argv[1]);
		printf("Doing some kind things with argument.\n");
		dummy(argv[1]);
	} else {
		printf("Bad argument.\n");

	}
	return 0;
}

