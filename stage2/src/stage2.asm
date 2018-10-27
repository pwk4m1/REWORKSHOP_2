
; A simple bootloader code, used for encrypting a
; full HDD-disk.
;
; we'll figure out what it is, and then build a decryption
; program for it.
;
; If you're not familliar with nasm syntax or assembly language
; in general, read the following wall of text
;
;
; Assembly language, is basicly CPU operations written in human-understandable
; format, that is directly converted to binary for the CPU to execute, hence
; it's as close as possible to hardware it's running, and does not require
; compiler, but only assembler to be converted to executable.
;
; CPU Operation Codes (opcodes) used in this file:
;
; bits 		- defines the bit-ness of the code
; org  		- defines the memory address where we start executing
; align 	- defines the alignment (wordsize)
; jmp		- jumps to specified memory address
; name:		- defines a label/function
; .name:	- defines a subroutine
; mov		- moves value from A to B
; xor		- logical XOR operation (value ^ other in C/Py/others)
; push		- stores value to stack-memory
; pop		- retrieves value from stack-memory
; and		- logical AND operation (value & other in C/Py/others)
; cli		- Tell CPU to ignore interrupts
; sti		- Tell CPU not to ignore interrupts
; lgdt		- Load Global Descriptor Table
; or		- Logical OR (value | other in C/Py/others)
; lodsb		- load byte from si to al
; int		- trigger a software interrupt
; loop		- loop until CX == 0, decrease CX on every iteration
; je		- jump if equal
; jne		- jump if not equal
; jz		- jump if zero
; jnz		- jump if not zero
; inc		- adds 1 to register value
; dec		- substracts 1 from register value
; add		- adds N to register value
; sub		- substracts N from register value
; hlt		- halts the CPU
; ret		- returns from function


[bits 	16]
org	0x7c00
align	4

; Jump to entry function, clear out code-segment value
jmp	0x0000:start


start:
	; Clear different segments
	xor	ax, ax
	mov	ds, ax
	mov	ss, ax

	; set up stack-pointer
	mov	sp, 0x7c00

	; disable interrupts and store real-mode segment
	cli
	push	ds

	; Load dummy GDT, and enable protected addressing/execution mode
	; we'll be in 32-bit mode for a while
	lgdt	[dummy_gdt]
	mov	eax, cr0
	or	al, 1
	mov	cr0, eax
	jmp	.pmode

.pmode:

	; Set up "unreal" mode, so we'll have 32-bit registers, but
	; rest in unprotected real mode, so we can interact with BIOS
	mov	bx, 0x08
	mov	ds, bx
	and	al, 0xFE
	mov	cr0, eax
	pop	ds
	sti

	; in 32-bit unreal mode now.
	xor	eax, eax
	mov	al, 0x03
	int	0x10

; Load rest of the code from the disk
load_second_stage:
	mov	bx, _start
	mov	dh, 1
	xor	ch, ch
	xor	dh, dh
	mov	cl, 2

	; Routines to read disk, as disk reads may fail due many reasons,
	; we'll retry up to 5 times
	.read_start:
		mov	di, 5
	.read:
		mov	ah, 0x02
		mov	al, 3
		int	0x13
		jc	.retry
		cmp	al, 3
		je	.done
		mov	cl, 1
		xor	dh, 1
		jnz	.read_start
		inc	ch
		jmp	.read_start
	.retry:
		xor	ah, ah
		int	0x13
		dec	di
		jnz	.read
		mov	si, msg_panic

		; If we fail with diskread, trigger a tiny panic()
		call	panic
	.done:
		jmp	_start

msg_panic db "Disk read failed.", 0x0A, 0

; print panic message, and hang the CPU
panic:
	lodsb
	or	al, al
	mov	ah, 0x0E
	int	0x10
	cmp	al, 0
	jne	panic
.hang:
	cli
	hlt
	jmp	.hang

dummy_gdt:
	dw	gdt_end - gdt - 1
	dd	gdt
gdt:
	dq	0
	dw	0xffff
	dw	0
	db	0
	db	10010010b
	db	11001111b
	db	0
gdt_end:

; Fill rest of 1st sector with 0 bytes, and add bootloader signature
times	510-($-$$) db 0
dw	0xAA55

; 2nd sector of disk, will be encrypting the disk 0x80 aka HDD
_start:
	mov	bx, 0x0
	mov	dh, 1
	call	load_disk
	mov	esi, plain_buf
	mov	edi, crypt_buf
	call	encrypt_data
	mov	eax, 0x1234
	cli
	hlt

key db "1234"

; esi= ptr to current 1024 byte buffer
; edi = encrypted data, 1024 bytes
encrypt_data:
	push	ebp
	mov	ebp, esp
	push	eax
	push	ebx
	push	ecx

	xor	eax, eax
	xor	ebx, ebx
	mov	ecx, 1024

	.encrypt_buf:
		mov	al, byte [esi + ecx]
		mov	bx, word [key]
		xor	al, bl
		xor	al, bh
		mov	byte [edi + ecx], al
		loop	.encrypt_buf

	pop	ecx
	pop	ebx
	pop	eax
	mov	esp, ebp
	pop	ebp
	ret	

; arguments,
; 	bx, start-addr
;	dh, sector-count
load_disk:
	mov	[sector_cnt], dh
	mov	dl, 0x80	; first disk
	xor	ch, ch
	mov	cl, 0x02
	.read_start:
		mov	di, 10
	.read:
		mov	ah, 0x02
		mov	al, [sector_cnt]
		int	0x13
		jc	.retry
		sub	[sector_cnt], al
		jz	.done
		mov	cl, 0x01
		xor	dh, 1
		jnz	.read_start
		inc	ch
		jmp	.read_start
	.retry:
		xor	ah, ah
		int	0x13
		dec	di
		jnz	.read
		mov	eax, 0x0001
		cli
		hlt
	.done:
		xor	eax, eax
		ret

; two 1024 bytes long emptry memory areas
plain_buf: times 1024 db 0
crypt_buf: times 1024 db 0

; empty byte for storing sector count
sector_cnt db 0


