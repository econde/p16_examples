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
	mov	r1, #PORT_ADDRESS & 0xff
	movt	r1, #PORT_ADDRESS >> 8
while:
	ldrb	r0,[r1]
	strb	r0,[r1]
	b	while
