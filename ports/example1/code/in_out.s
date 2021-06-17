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
		uint8_t a = port_input();
		port_output(a);
	}
}
*/
	.equ	PORT_ADDRESS, 0xcc00

	.text
main:
	mov	r1, PORT_ADDRESS & 0xff
	movt	r1, PORT_ADDRESS >> 8
while:
	ldrb	r0,[r1]		; uint8_t a = port_input();

	strb	r0,[r1]		; port_output(a);

	b	while
