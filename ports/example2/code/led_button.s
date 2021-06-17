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

int main() {
	while (true) {
		if ((port_input() & BUTTON_MASK) == 0)
			port_output(LED_MASK);
		else
			port_output(0);
	}
}
*/
	.equ	BUTTON_MASK, (1 << 2)
	.equ	LED_MASK, (1 << 4)

	.equ	PORT_ADDRESS, 0xcc00

	.text
main:
while:
	ldr	r1, addressof_port
	ldrb	r0,[r1, 1]
	mov	r2, BUTTON_MASK
	and	r0, r0, r2
	bzc	if_else
	mov	r0, LED_MASK
	b	if_end
if_else:
	mov	r0, 0
if_end:
	ldr	r1, addressof_port
	strb	r0,[r1, 1]
	b	while

addressof_port:
	.word	PORT_ADDRESS

