.section .startup
	b	_start
	b	.
_start:
	ldr	sp, addr_stack_top
	bl	main
	b	.

addr_stack_top:
	.word	stack_top

	.text

	.data

	.section .stack
	.space	64
stack_top:

/*------------------------------------------------------------------------------

int main() {
	while (true) {
		if ((inport_read() & BUTTON_MASK) != 0)
			outport_write(LED_MASK);
		else
			outport_write(0);
	}
}
*/
	.equ	BUTTON_MASK, (1 << 2)
	.equ	LED_MASK, (1 << 4)

	.equ	PORT_ADDRESS, 0xcc00

	.text
main:
while:
	bl	inport_read	; if ((inport_read() & BUTTON_MASK) != 0)
	mov	r2, BUTTON_MASK
	and	r0, r0, r2
	bzs	if_else
	mov	r0, LED_MASK
	b	if_end
if_else:
	mov	r0, 0
if_end:
	bl	outport_write	; outport_write(...);
	b	while

/*------------------------------------------------------------------------------
	uint8_t inport_read();
*/
inport_read:
	mov	r0, PORT_ADDRESS & 0xff
	movt	r0, PORT_ADDRESS >> 8
	ldrb	r0,[r0]
	mov	pc, lr

/*------------------------------------------------------------------------------
	void outport_write(uint8_t);
*/
outport_write:
	mov	r1, PORT_ADDRESS & 0xff
	movt	r1, PORT_ADDRESS >> 8
	strb	r0,[r1]
	mov	pc, lr
