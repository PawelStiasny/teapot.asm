bits 32

; line drawing in C
extern draw_line

global render
%idefine	buffer		DWORD [ebp+8]
%idefine	points		DWORD [ebp+12]
%idefine	num_points	DWORD [ebp+16]
%idefine	movx		DWORD [ebp+20]
%idefine	movy		DWORD [ebp+24]

%idefine	screen_w	640
%idefine	screen_h	480

render:
	push	ebp
	mov		ebp, esp
	push	esi
	push	edi

	mov		ecx, num_points
	shl		ecx, 4
	mov		eax, points
	mov		edi, buffer
draw_loop:
; preserve for calling a C drawing function
	push	ecx
	push	eax
; find the beginning of the line
	mov		edx, [eax+ecx-12]	; edx := point[n].y
	add		edx, movx			; shift transfrom (y)
	js		skip_loop			; in drawing area?
	cmp		edx, screen_h
	jns		skip_loop

	push	edx

	;mov		esi, [edi+4*edx]	; esi := (long*)line[edx]
	mov		edx, [eax+ecx-16]	; edx := point[n].x
	add		edx, movy			; shift transofrm (x)
	js		skip_loop			; in drawing area?
	cmp		edx, screen_w
	jns		skip_loop

	push	edx

; find the end of the line
	mov		edx, [eax+ecx-4]	; edx := point[n].y
	add		edx, movx			; shift transfrom (y)
	js		skip_loop			; in drawing area?
	cmp		edx, screen_h
	jns		skip_loop

	push	edx

	;mov		esi, [edi+4*edx]	; esi := (long*)line[edx]
	mov		edx, [eax+ecx-8]	; edx := point[n].x
	add		edx, movy			; shift transofrm (x)
	js		skip_loop			; in drawing area?
	cmp		edx, screen_w
	jns		skip_loop

	push	edx

	;mov		DWORD [esi+edx*4], 0xffffff	; line[..][edx] := 1
	push	buffer
	call	draw_line
	add		esp, 20
	pop		eax
	pop		ecx


skip_loop:
	sub		ecx, 16
	jnz		draw_loop

	pop		edi
	pop		esi
	leave
	ret

