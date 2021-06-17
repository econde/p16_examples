.section .startup
	b	_start
	b	.
_start:
	ldr	sp, addressof_stack_end
	ldr	r0, addressof_main
	mov	r1, pc
	add	lr, r1, 4
	mov	pc, r0
	b	.
addressof_stack_end:
	.word	stack_end
addressof_main:
	.word	main

	.text

	.data

	.section .stack
	.equ	STACK_SIZE, 1024
	.space	STACK_SIZE
stack_end:

/*==============================================================================
void main() {
	while (1) {
		output_write(LED_MASK);
		timer_delay(HALF_PERIOD);
		output_write(0);
		timer_delay(HALF_PERIOD);
	}
}
*/
	.equ	LED_MASK,	(1 << 0)
	.equ	PERIOD, 	100
	.equ	HALF_PERIOD,	PERIOD / 2

	.text
main:
while:
	mov	r0, LED_MASK
	bl	port_output
	mov	r0, HALF_PERIOD & 0xff
	movt	r0, HALF_PERIOD >> 8
	bl 	delay

	mov	r0, 0
	bl	port_output
	mov	r0, HALF_PERIOD & 0xff
	movt	r0, HALF_PERIOD >> 8
	bl 	delay

	b	while

/*------------------------------------------------------------------------------
void delay(uint16_t time) {
	while (time-- > 0)
		;
}
*/

delay:
	sub	r0, r0, 0
	beq	delay_exit
delay_while:
	sub	r0, r0, 1
	bzc	delay_while
delay_exit:
	mov	pc, lr

/*------------------------------------------------------------------------------
	void port_output(uint8_t);
*/

	.equ	PORT_ADDRESS, 0xff00

port_output:
	mov	r1, PORT_ADDRESS & 0xff
	movt	r1, PORT_ADDRESS >> 8
	strb	r0, [r1]
	mov	pc, lr

