bits 32

; line drawing in C
extern draw_line
extern print_vec

; %define	EXTERN_DRAW	0

%macro	print_xmm 1
%if 0 ; disable debugging
	push	ecx
	push	eax

	sub		esp, 16
	movups	[esp], %1
	call	print_vec
	add		esp, 16

	pop		eax
	pop		ecx
%endif
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
%idefine	buffer		DWORD [ebp+8]
%idefine	points		DWORD [ebp+12]
%idefine	num_points	DWORD [ebp+16]
%idefine	movmx		DWORD [ebp+20]
%idefine	rotmx		DWORD [ebp+24]

%idefine	screen_w	640
%idefine	screen_h	480

render:
	push	ebp
	mov		ebp, esp
	push	esi
	push	edi
	push	ebx

; ecx := 24 * num_points
	mov		ecx, num_points
	mov		eax, ecx
	shl		eax, 3
	shl		ecx, 4
	add		ecx, eax

; register xmm1 contains the translation matrix
	mov		eax, movmx
	movups	xmm1, [eax]		; xmm1 := movx, movy, movz, ...

; registers xmm5..7 contain the rotation matrix
	mov		eax, rotmx
	movups	xmm5, [eax]
	print_xmm xmm5
	movups	xmm6, [eax+16]
	print_xmm xmm6
	movups	xmm7, [eax+32]
	print_xmm xmm7

	mov		eax, points
	mov		edi, buffer

vertex_loop:
; preserve for calling a C drawing function
%ifdef EXTERN_DRAW
	push	ecx
	push	eax
%endif

	movups	xmm0, [eax+ecx-24]
	handle_point esi, edx
	push	edx
	push	esi
	movaps	xmm4, xmm0

	movups	xmm0, [eax+ecx-12]
	handle_point esi, edx
	push	edx
	push	esi

	;mov		DWORD [esi+edx*4], 0xffffff	; line[..][edx] := 1

%ifdef EXTERN_DRAW
	push	buffer
	call	draw_line
	add		esp, 20
	pop		eax
	pop		ecx
%else

	; ...

%endif

	
draw_loop:

continue_vertex_loop:
%ifndef EXTERN_DRAW
	add		esp, 16		; pop calculated points
%endif
	sub		ecx, 24
	jnz		vertex_loop

	pop		ebx
	pop		edi
	pop		esi
	leave
	ret

