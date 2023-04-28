	.section .startup
	b	_start
	b	.

_start:
	ldr	sp, addressof_stack_top
	mov	r0, pc
	add	lr, r0, #4
	ldr	pc, addressof_main
	b	.

addressof_stack_top:
	.word	stack_top

addressof_main:
	.word	main

	.text

	.section .stack
	.equ	STACK_SIZE, 1024
	.space	STACK_SIZE
stack_top:

/*==============================================================================

int main() {
	while (1) {
		outport_write(0)
		while ((inport_read() & BUTTON_MASK) == 0)
			;
		while ((inport_read() & BUTTON_MASK) != 0)
			;

		outport_write(LED_MASK)
		uint16_t time_initial = timer_read();

		while ((inport_read() & BUTTON_MASK) == 0
			&& timer_elapsed(timer_initial) < LED_TIME)
			;
		while ((inport_read() & BUTTON_MASK) != 0
			&& timer_elapsed(timer_initial) < LED_TIME)
	}
}
*/
	.equ	BUTTON_MASK,	(1 << 3)
	.equ	LED_MASK, 	(1 << 0)

	.equ	LED_TIME,	1000

	.text
main:
while:
	mov	r0, #0
	bl	outport_write	; outport_write(0)
while1:				; while ((inport_read() & BUTTON_MASK) == 0)
	bl	inport_read
	mov	r2, #BUTTON_MASK
	and	r0, r0, r2
	bzs	while1
while2:				; while ((inport_read() & BUTTON_MASK) != 0)
	bl	inport_read
	mov	r2, #BUTTON_MASK
	and	r0, r0, r2
	bzc	while2

	mov	r0, #LED_MASK
	bl	outport_write	; outport_write(LED_MASK)

	mov	r4, #LED_TIME && 0xff	; r4 - LED_TIME
	movt	r4, #LED_TIME >> 8
	bl	timer_read
	mov	r5, r0		; r5 - time_initial
while3:
	bl	inport_read	; while ((inport_read() & BUTTON_MASK) == 0
	mov	r2, #BUTTON_MASK
	and	r0, r0, r2
	bzc	while3_end

	mov	r0, r5
	bl	timer_elapsed
	cmp	r0, r4		; && timer_elapsed(timer_initial) < LED_TIME)
	blo	while3
while3_end:
while4:
	bl	inport_read	; while ((inport_read() & BUTTON_MASK) != 0
	mov	r2, #BUTTON_MASK
	and	r0, r0, r2
	bzs	while4_end

	mov	r0, r5
	bl	timer_elapsed
	cmp	r0, r4		; && timer_elapsed(timer_initial) < LED_TIME)
	blo	while4
while4_end:
	b	while

/*------------------------------------------------------------------------------
uint16_t timer_elapsed(uint16_t initial) {
	return timer_read() - initial;
}
*/

timer_elapsed:
	push	lr
	push	r4
	mov	r4, r0
	bl	timer_read
	sub	r0, r0, r4
	pop	r4
	pop	pc

/*------------------------------------------------------------------------------
	uint8_t timer_read();
*/
	.equ	TIMER_ADDRESS, 0xff40

timer_read:
	mov	r0, #TIMER_ADDRESS & 0xff
	movt	r0, #TIMER_ADDRESS >> 8
	ldr	r0, [r0]
	mov	pc, lr

/*------------------------------------------------------------------------------
	uint8_t inport_read();
*/
	.equ	INPORT_ADDRESS, 0xff80

inport_read:
	mov	r0, #INPORT_ADDRESS & 0xff
	movt	r0, #INPORT_ADDRESS >> 8
	ldrb	r0,[r0]
	mov	pc, lr

/*------------------------------------------------------------------------------
	void outport_write(uint8_t);
*/
	.equ	OUTPORT_ADDRESS, 0xffc0

outport_write:
	mov	r1, #OUTPORT_ADDRESS & 0xff
	movt	r1, #OUTPORT_ADDRESS >> 8
	strb	r0,[r1]
	mov	pc, lr
