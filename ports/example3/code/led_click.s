	.section .startup
	b	_start
	b	.
_start:
	ldr	sp, addressof_stack_end
	bl	main
	b	.

addressof_stack_end:
	.word	stack_end

	.text

	.data

	.section .stack
	.space	64
stack_end:


/*------------------------------------------------------------------------------
*/
	.equ	BUTTON_MASK, (1 << 2)
	.equ	LED_MASK, (1 << 4)

/*
void main() {
	uint8_t led_state = 0;
	outport_write(led_state);
	while (1) {
		while ((inport_read() & BUTTON_MASK) != 0)
			;

		led_state = ~led_state;
		outport_write(led_state & LED_MASK);

		while ((inport_read() & BUTTON_MASK) == 0)
			;
	}
}
*/

	.text
main:
	mov	r4, 0		; uint8_t led_state = 0;
	mov	r0, r4		; outport_write(led_state);
	bl	outport_write
while:
while1:
	bl	inport_read	; while ((inport_read() & BUTTON_MASK) == 0)
	mov	r1, BUTTON_MASK		;
	and	r0, r0, r1
	bzc	while1

	mvn	r4, r4		; led_state = ~led_state;
	mov	r0, LED_MASK
	and	r0, r0, r4
	bl	outport_write	; outport_write(led_state & LED_MASK);
while2:
	bl	inport_read	; while ((inport_read() & BUTTON_MASK) != 0)
	mov	r1, BUTTON_MASK		;
	and	r0, r0, r1
	bzs	while2
	b	while

/*------------------------------------------------------------------------------
	;uint8_t inport_read();
*/
	.equ	INPORT_ADDRESS, 0xcc00

inport_read:
	mov	r0, INPORT_ADDRESS & 0xff
	movt	r0, INPORT_ADDRESS >> 8
	ldrb	r0, [r0, 1]
	mov	pc, lr

/*------------------------------------------------------------------------------
	;void outport_write(uint8_t);
*/
	.equ	OUTPORT_ADDRESS, 0xcc00

outport_write:
	mov	r1, OUTPORT_ADDRESS & 0xff
	movt	r1, OUTPORT_ADDRESS >> 8
	strb	r0, [r1, 1]
	mov	pc, lr
