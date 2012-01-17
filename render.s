bits 64

extern print_vec

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

%macro	num_distance 3	; arg1 := abs(arg2 - arg3)
	mov %1, %2
	sub	%1, %3
	jge	%%no_inv
	neg %1
	inc	%1
%%no_inv:
%endmacro

global render
%idefine	screen_w	640
%idefine	screen_h	480

render:
	push	rbp
	mov		rbp, rsp
	push	rbx
	push	r12
	push	r13

; register xmm1 contains the translation matrix
	movups	xmm1, [rcx]		; xmm1 := movx, movy, movz, ...

; registers xmm5..7 contain the rotation matrix
	movups	xmm5, [r8]
	movups	xmm6, [r8+16]
	movups	xmm7, [r8+32]

; rdx := 32 * num_points
	shl		rdx, 5

vertex_loop:

%idefine	x	rax
%idefine	y	rcx
%idefine	x1	r9
%idefine	y1	r8

	movaps	xmm0, [rsi+rdx-32]
	handle_point x, y

	movaps	xmm0, [rsi+rdx-16]
	handle_point x1, y1

; Values used in the drawing loop
%idefine	ystep	r11
%idefine	d_x		r13
%idefine	d_y		r12
%idefine	error	rbx

; is slope > 45* ?
	num_distance	r12, y1, y
	num_distance	r13, x1, x
	cmp		r12, r13
	jle		draw_line_unswapped
	xchg	x, y
	xchg	x1, y1

%macro	draw_line	2
; if x > x1 swap the ends
	cmp		x, x1
	jle		%%no_x_swap
	xchg	x, x1
	xchg	y, y1
%%no_x_swap:

; y step := 1 if y < y1, else -1
	mov		ystep, 1
	mov		rbx, -1
	cmp		y, y1
	cmovge	ystep, rbx
;pos_step:

; dx := x1 - x
	mov		d_x, x1
	sub		d_x, x

; error := dx / 2
	mov		error, d_x
	shr		error, 1

; dy := abs(y1-y)
	num_distance	d_y, y1, y

%%draw_loop:

; check bitmap boundaries and put the pixel
	cmp		%2, 0
	jl		%%continue_draw
	cmp		%2, screen_h
	jge		%%continue_draw

	mov		r10, [rdi+%2*8]	; line pointer

	cmp		%1, 0
	jl		%%continue_draw
	cmp		%1, screen_w
	jge		%%continue_draw

	mov		DWORD [r10+%1*4], 0xffffff
%%continue_draw:

; error -= dy
	sub		error, d_y
; if (error < 0) { y+=step; error+=dx }
	jg		%%no_inc_y
	add		y, ystep
	add		error, d_x
%%no_inc_y:

; next iteration
	inc		x
	cmp		x, x1
	jle		%%draw_loop
%endmacro

	draw_line	y, x
	jmp		continue_vertex_loop
draw_line_unswapped:
	draw_line	x, y

continue_vertex_loop:
	sub		rdx, 32
	jnz		vertex_loop

; End of loop

	pop		r13
	pop		r12
	pop		rbx
	pop		rbp
	ret

