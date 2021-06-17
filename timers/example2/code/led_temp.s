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

int main() {
	while (1) {
		port_output(0)
		while ((port_input() & BUTTON_MASK) == 0)
			;
		while ((port_input() & BUTTON_MASK) != 0)
			;

		port_output(LED_MASK)
		uint16_t time_initial = timer_read();

		while ((port_input() & BUTTON_MASK) == 0
			&& timer_elapsed(timer_initial) < LED_TIME)
			;
		while ((port_input() & BUTTON_MASK) != 0
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
	mov	r0, 0
	bl	port_output	; port_output(0)
while1:				; while ((port_input() & BUTTON_MASK) == 0)
	bl	port_input
	mov	r2, BUTTON_MASK
	and	r0, r0, r2
	bzs	while1
while2:				; while ((port_input() & BUTTON_MASK) != 0)
	bl	port_input
	mov	r2, BUTTON_MASK
	and	r0, r0, r2
	bzc	while2

	mov	r0, LED_MASK
	bl	port_output	; port_output(LED_MASK)

	mov	r4, LED_TIME && 0xff	; r4 - LED_TIME
	movt	r4, LED_TIME >> 8
	bl	timer_read
	mov	r5, r0		; r5 - time_initial
while3:
	bl	port_input	; while ((port_input() & BUTTON_MASK) == 0
	mov	r2, BUTTON_MASK
	and	r0, r0, r2
	bzc	while3_end

	mov	r0, r5
	bl	timer_elapsed
	cmp	r0, r4		; && timer_elapsed(timer_initial) < LED_TIME)
	blo	while3
while3_end:
while4:
	bl	port_input	; while ((port_input() & BUTTON_MASK) != 0
	mov	r2, BUTTON_MASK
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
	.equ	TIMER_ADDRESS, 0xff80

timer_read:
	mov	r0, TIMER_ADDRESS & 0xff
	movt	r0, TIMER_ADDRESS >> 8
	ldr	r0, [r0]
	mov	pc, lr

/*------------------------------------------------------------------------------
	uint8_t port_input();
*/
	.equ	PORT_ADDRESS, 0xff00

port_input:
	mov	r0, PORT_ADDRESS & 0xff
	movt	r0, PORT_ADDRESS >> 8
	ldrb	r0,[r0]
	mov	pc, lr

/*------------------------------------------------------------------------------
	void port_output(uint8_t);
*/
port_output:
	mov	r1, PORT_ADDRESS & 0xff
	movt	r1, PORT_ADDRESS >> 8
	strb	r0,[r1]
	mov	pc, lr
