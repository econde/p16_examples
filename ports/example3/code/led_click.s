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
	.equ	BUTTON_MASK,	(1 << 2)
	.equ	LED_MASK,	(1 << 4)

/*
void main() {
	uint8_t led_state = 0;
	port_output(led_state);
	while (1) {
		while ((port_input() & BUTTON_MASK) == 0)
			;
		led_state = ~led_state;
		port_output(led_state & LED_MASK);
		while ((port_input() & BUTTON_MASK) != 0)
			;
	}
}
*/

	.text
main:
	mov	r4, 0		; uint8_t led_state = 0;
	mov	r0, r4		; port_output(led_state);
	bl	port_output
while:
while1:
	bl	port_input	; while ((port_input() & BUTTON_MASK) == 0)
	mov	r1, BUTTON_MASK		;
	and	r0, r0, r1
	bzc	while1

	mvn	r4, r4		; led_state = ~led_state;
	mov	r0, LED_MASK
	and	r0, r0, r4
	bl	port_output	; port_output(led_state & LED_MASK);
while2:
	bl	port_input	; while ((port_input() & BUTTON_MASK) != 0)
	mov	r1, BUTTON_MASK		;
	and	r0, r0, r1
	bzs	while2

	b	while

/*------------------------------------------------------------------------------
*/
	.equ	PORT_ADDRESS, 0xcc00

port_input:
	mov	r0, PORT_ADDRESS & 0xff
	movt	r0, PORT_ADDRESS >> 8
	ldrb	r0, [r0, 1]
	mov	pc, lr

port_output:
	mov	r1, PORT_ADDRESS & 0xff
	movt	r1, PORT_ADDRESS >> 8
	strb	r0, [r1, 1]
	mov	pc, lr

