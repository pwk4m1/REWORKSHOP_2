
cc=gcc
cflags=-Wall -Wextra -O0

.PHONY: all stage1 stage2 stage3 clean
.SUFFIXES: .c

all: check stage0 stage1 stage2 stage3

check:
	command -v "gcc">/dev/null 2>&1 || {\
		echo "Missing gcc in PATH, abort";\
		exit 1;\
	}\


stage0: check
	mkdir -p stage0/bin/
	$(cc) $(cflags) -o stage0/bin/stage0 stage0/src/*.c

stage1: check
	mkdir -p stage1/bin
	$(cc) $(cflags) -o stage1/bin/stage1 stage1/src/*.c

stage2: check
	mkdir -p stage2/bin
	nasm -f bin -o stage2/bin/stage2 stage2/src/*.asm

stage3: check
	mkdir -p stage3/bin
	$(cc) $(cflags) -o stage3/bin/stage3 stage3/src/*.c
	strip -x -o stage3/bin/stage3 stage3/bin/stage3

clean:
	rm -rf stage0/bin/*
	rm -rf stage1/bin/*
	rm -rf stage2/bin/*
	rm -rf stage3/bin/*

