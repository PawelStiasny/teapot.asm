bits 32

global render
%idefine	buffer	[ebp+8]
%idefine	points	[ebp+12]
%idefine	num_points	[ebp+16]
%idefine	movx	[ebp+20]
%idefine	movy	[ebp+24]

%idefine	screen_w	640
%idefine	screen_h	480

render:
	push	ebp
	mov		ebp, esp
	push	esi
	push	edi

	mov		ecx, num_points
	;dec		ecx
	mov		eax, points
	mov		edi, buffer
draw_loop:
	mov		edx, [eax+8*ecx-4]	; edx := point[n].y
	add		edx, movx			; shift transfrom (y)
	js		skip_loop			; in drawing area?
	cmp		edx, screen_h
	jns		skip_loop
	mov		esi, [edi+4*edx]	; esi := (long*)line[edx]
	mov		edx, [eax+8*ecx-8]	; edx := point[n].x
	add		edx, movy			; shift transofrm (x)
	js		skip_loop			; in drawing area?
	cmp		edx, screen_w
	jns		skip_loop
	mov		DWORD [esi+edx*4], 0xffffff	; line[..][edx] := 1

skip_loop:
	dec		ecx
	jnz		draw_loop

	pop		edi
	pop		esi
	leave
	ret

