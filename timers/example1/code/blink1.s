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
#define	LED_MASK	(1 << 0)
#define	PERIOD		(100 * 16)			 100 milisegundos
#define	HALF_PERIOD	(PERIOD / 2)

void main() {
	while (1) {
		outport_write(LED_MASK);
		timer_delay(HALF_PERIOD);
		outport_write(0);
		timer_delay(HALF_PERIOD);
	}
}
*/
	.equ	LED_MASK, 1 << 0
	.equ	PERIOD, 100 * 16
	.equ	HALF_PERIOD, PERIOD / 2

	.text
main:
while:
	mov	r0, #LED_MASK
	bl	outport_write
	mov	r0, #HALF_PERIOD & 0xff
	movt	r0, #HALF_PERIOD >> 8
	bl 	delay

	mov	r0, #0
	bl	outport_write
	mov	r0, #HALF_PERIOD & 0xff
	movt	r0, #HALF_PERIOD >> 8
	bl 	delay

	b	while

/*------------------------------------------------------------------------------
void delay(uint16_t n) {
	while (n-- > 0)
		;
}
*/

delay:
	sub	r0, r0, #0
	beq	delay_exit
delay_while:
	sub	r0, r0, #1
	bzc	delay_while
delay_exit:
	mov	pc, lr

/*------------------------------------------------------------------------------
	void outport_write(uint8_t);
*/

	.equ	OUPORT_ADDRESS, 0xff00

outport_write:
	mov	r1, #OUPORT_ADDRESS & 0xff
	movt	r1, #OUPORT_ADDRESS >> 8
	strb	r0, [r1]
	mov	pc, lr

