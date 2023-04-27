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

/*-----------------------------------------------------------------------------

int main() {
	while (true) {
		uint8_t a = inport_read();
		outport_write(a);
	}
}
*/
	.equ	PORT_ADDRESS, 0xcc00

	.text
main:
	mov	r1, PORT_ADDRESS & 0xff
	movt	r1, PORT_ADDRESS >> 8
while:
	ldrb	r0,[r1]
	strb	r0,[r1]
	b	while
