section .startup
	b	_start
	b	.
_start:
	ldr	sp, addr_stack_top
	ldr	r0, addr_main
	mov	r1, pc
	add	lr, r1, 4
	mov	pc, r0
	b	.
addr_stack_top:
	.word	stack_top
addr_main:
	.word	main

	.section .stack
	.equ	STACK_SIZE, 1024
	.space	STACK_SIZE
stack_top:

/*------------------------------------------------------------------------------

int main() {
	while (true) {
		if ((port_input() & BUTTON_MASK) != 0)
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
	ldr	r1, addr_port
	ldrb	r0,[r1, 1]
	mov	r2, BUTTON_MASK
	and	r0, r0, r2
	bzs	if_else
	mov	r0, LED_MASK
	b	if_end
if_else:
	mov	r0, 0
if_end:
	ldr	r1, addr_port
	strb	r0,[r1, 1]
	b	while

addr_port:
	.word	PORT_ADDRESS

