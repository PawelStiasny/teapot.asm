bits 32

; line drawing in C
extern draw_line
extern print_vec

%macro	print_mmx 1
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
	
%macro	handle_point 0
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
	cvttss2si	esi, xmm0
	shufps		xmm0, xmm0, 0b00111001
	cvttss2si	edx, xmm0
	push	edx
	push	esi
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
	movups	xmm6, [eax+12]
	movups	xmm7, [eax+24]

	mov		eax, points
	mov		edi, buffer

draw_loop:
; preserve for calling a C drawing function
	push	ecx
	push	eax

	movups	xmm0, [eax+ecx-24]
	handle_point

	movups	xmm0, [eax+ecx-12]
	handle_point

	;mov		DWORD [esi+edx*4], 0xffffff	; line[..][edx] := 1
	push	buffer
	call	draw_line
	add		esp, 20
	pop		eax
	pop		ecx


skip_loop:
	sub		ecx, 24
	jnz		draw_loop

	pop		edi
	pop		esi
	leave
	ret

