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
*/
	.equ	LED_MASK,	1 << 0
	.equ	PERIOD,		50000
	.equ	HALF_PERIOD, 	PERIOD / 2

/*------------------------------------------------------------------------------
void main() {
	while (1) {
		output_write(LED_MASK);
		timer_delay(HALF_PERIOD);
		output_write(0);
		timer_delay(HALF_PERIOD);
	}
}
*/
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
void delay(uint16_t time) {
	uint16_t initial = timer_read();
	while (timer_read() - initial < time)
		;
}
*/
delay:
	push	lr
	push	r4
	push	r5
	mov	r4, r0
	bl	timer_read
	mov	r5, r0
delay_while:
	bl	timer_read
	sub	r0, r0, r5
	cmp	r0, r4
	bcs	delay_while
	pop	r5
	pop	r4
	pop	pc

/*------------------------------------------------------------------------------
	void outport_write(uint8_t);
*/
	.equ	OUTPORT_ADDRESS, 0xffc0

outport_write:
	mov	r1, #OUTPORT_ADDRESS & 0xff
	movt	r1, #OUTPORT_ADDRESS >> 8
	strb	r0, [r1]
	mov	pc, lr

/*------------------------------------------------------------------------------
	uint16_t timer_read();
*/
	.equ	TIMER_ADDRESS, 0xff40

timer_read:
	mov	r1, #TIMER_ADDRESS & 0xff
	movt	r1, #TIMER_ADDRESS >> 8
	ldr	r0, [r1]
	mov	pc, lr
