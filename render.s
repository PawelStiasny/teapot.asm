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

	mov		ecx, screen_h ;num_points
	;dec		ecx
	mov		eax, buffer
draw_loop:
	dec		ecx
	mov		edx, [eax+4*ecx]		; edx := long*
	mov		DWORD [edx+16], 0xffffff	; line[0][0] := ...
	jnz		draw_loop

	leave
	ret

