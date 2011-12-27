bits 32

; line drawing in C
extern draw_line
extern print_vec

%macro	print_mmx 1
	push	ecx
	push	eax

	sub		esp, 16
	movups	[esp], %1
	call	print_vec
	add		esp, 16

	pop		eax
	pop		ecx
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

	mov		eax, movmx
	movups	xmm1, [eax]		; xmm1 := movx, movy, movz, ...
	;print_mmx	xmm1

	mov		eax, rotmx
	movups	xmm5, [eax]
	print_mmx xmm5
	movups	xmm6, [eax+12]
	print_mmx xmm6
	movups	xmm7, [eax+24]
	print_mmx xmm7

	mov		eax, points
	mov		edi, buffer

draw_loop:
; preserve for calling a C drawing function
	push	ecx
	push	eax

	movups	xmm0, [eax+ecx-24]

	;print_mmx	xmm0

	addps		xmm0, xmm1
	;print_mmx	xmm0
	cvttss2si	esi, xmm0
	shufps		xmm0, xmm0, 0b00111001
	cvttss2si	edx, xmm0
	push	edx
	push	esi

	movups	xmm0, [eax+ecx-12]

	;print_mmx	xmm0

	addps		xmm0, xmm1
	cvttss2si	esi, xmm0
	shufps		xmm0, xmm0, 0b00111001
	cvttss2si	edx, xmm0
	push	edx
	push	esi


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

