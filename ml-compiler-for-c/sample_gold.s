; IDEAL ASSEMBLY FILE FOR sample.c, GENERATED BY CLANG COMPILER USING COMMAND clang -s sample.c
	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 15, 0	sdk_version 15, 0
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	wzr, [sp, #12]
	mov	w8, #5                          ; =0x5
	str	w8, [sp, #8]
	mov	w8, #10                         ; =0xa
	str	w8, [sp, #4]
	ldr	w8, [sp, #8]
	ldr	w9, [sp, #4]
	add	w8, w8, w9
	str	w8, [sp]
	ldr	w8, [sp]
	subs	w8, w8, #10
	cset	w8, le
	tbnz	w8, #0, LBB0_2
	b	LBB0_1
LBB0_1:
	ldr	w8, [sp]
	str	w8, [sp, #12]
	b	LBB0_3
LBB0_2:
	str	wzr, [sp, #12] 
	b	LBB0_3
LBB0_3:
	ldr	w0, [sp, #12]
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
.subsections_via_symbols
