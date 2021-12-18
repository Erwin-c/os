;Erwin @ 2021.12.18

MBT_HDR_FLAGS	EQU 0x00010003
MBT_HDR_MAGIC	EQU 0x1BADB002 ;Magic number of multi-boot protocol header.
MBT_HDR2_MAGIC	EQU 0xe85250d6 ;Magic number of multi-boot protocol header v2.
global _start ;Export symbol '_start'.
extern main ;Import external function symbol 'main'.

[section .start.text] ;Define section '.start.text'.
[bits 32] ;Assemble to 32 bits.
_start:
	jmp _entry
ALIGN 8
mbt_hdr:
	dd MBT_HDR_MAGIC
	dd MBT_HDR_FLAGS
	dd -(MBT_HDR_MAGIC+MBT_HDR_FLAGS)
	dd mbt_hdr
	dd _start
	dd 0
	dd 0
	dd _entry

;Above is the header for GRUB.
ALIGN 8
mbt2_hdr:
	DD	MBT_HDR2_MAGIC
	DD	0
	DD	mbt2_hdr_end - mbt2_hdr
	DD	-(MBT_HDR2_MAGIC + 0 + (mbt2_hdr_end - mbt2_hdr))
	DW	2, 0
	DD	24
	DD	mbt2_hdr
	DD	_start
	DD	0
	DD	0
	DW	3, 0
	DD	12
	DD	_entry
	DD      0
	DW	0, 0
	DD	8
mbt2_hdr_end:
;Above is the header for GRUB2.
;Two headers are compatible for GRUB and GRUB2.

ALIGN 8

_entry:
	;Turn off 'interrupt'.
	cli
	;Turn off 'non-maskable interrupt'.
	in al, 0x70
	or al, 0x80
	out 0x70,al
	;Reload GDT.
	lgdt [GDT_PTR]
	jmp dword 0x8 :_32bits_mode

_32bits_mode:
	;Initialize registers that C needs possibly.
	mov ax, 0x10
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor edi,edi
	xor esi,esi
	xor ebp,ebp
	xor esp,esp
	;Initialize the stack that C needs for work.
	mov esp,0x9000
	;Call function 'main'.
	call main
	;Tell the CPU to stop executing instructions.
halt_step:
	halt
	jmp halt_step

;Data required for CPU working mode.
GDT_START:
knull_dsc: dq 0
kcode_dsc: dq 0x00cf9e000000ffff
kdata_dsc: dq 0x00cf92000000ffff
k16cd_dsc: dq 0x00009e000000ffff
k16da_dsc: dq 0x000092000000ffff
GDT_END:

GDT_PTR:
GDTLEN	dw GDT_END-GDT_START-1
GDTBASE	dd GDT_START
