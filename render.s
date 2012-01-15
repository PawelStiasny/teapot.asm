bits 64

; line drawing in C
extern draw_line
extern print_vec

%define	EXTERN_DRAW	1

%macro	print_xmm 1
; ...
%endmacro

%macro	handle_point 2 ; X := arg 1; Y := arg 2
; xmm2 := vec.x
	movaps		xmm2, xmm0
	shufps		xmm2, xmm2, 0b00000000
	mulps		xmm2, xmm5
; xmm3 := vec.y
	movaps		xmm3, xmm0
	shufps		xmm3, xmm3, 0b01010101
	mulps		xmm3, xmm6
	addps		xmm2, xmm3
; xmm0 := vec.z
	shufps		xmm0, xmm0, 0b10101010
	mulps		xmm0, xmm7
	addps		xmm0, xmm2

; translation
	addps		xmm0, xmm1

; convert the result to integer
	cvttss2si	%1, xmm0
	shufps		xmm0, xmm0, 0b00111001
	cvttss2si	%2, xmm0
%endmacro

global render
%idefine	screen_w	640
%idefine	screen_h	480

render:
	push	rbp
	mov		rbp, rsp
	push	rbx ; unused?

; register xmm1 contains the translation matrix
	movups	xmm1, [rcx]		; xmm1 := movx, movy, movz, ...

; registers xmm5..7 contain the rotation matrix
	movups	xmm5, [r8]
	print_xmm xmm5
	movups	xmm6, [r8+16]
	print_xmm xmm6
	movups	xmm7, [r8+32]
	print_xmm xmm7

; rcx := 32 * num_points
	mov		rcx, rdx
	shl		rcx, 5

	mov		rax, rsi ; points

vertex_loop:
; preserve for calling a C drawing function
%ifdef EXTERN_DRAW
	push	rcx
	push	rax
	push	r8
	push	rdi
%endif

	movaps	xmm0, [rax+rcx-32]
	;print_xmm	xmm0
	handle_point rsi, rdx
	;movaps	xmm4, xmm0

	movaps	xmm0, [rax+rcx-16]
	handle_point rcx, r8

%ifdef EXTERN_DRAW
	call	draw_line
	;add		rsp, 20
	pop		rdi
	pop		r8
	pop		rax
	pop		rcx
%else

	;mov		DWORD [rsi+edx*4], 0xffffff	; line[..][rdx] := 1
	; ...

%endif

	
draw_loop:

continue_vertex_loop:
%ifndef EXTERN_DRAW
	;add		rsp, 16		; pop calculated points
%endif
	sub		rcx, 32
	jnz		vertex_loop

	pop		rbx
	pop		rbp
	;leave
	ret

