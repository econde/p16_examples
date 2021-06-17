.section .startup
	b	_start
	ldr	pc, addressof_isr
_start:
	ldr	sp, addressof_stack_end
	ldr	r0, addressof_main
	mov	r1, pc
	add	lr, r1,4
	mov	pc, r0
	b	.

addressof_stack_end:
	.word stack_end

addressof_main:
	.word main

addressof_isr:
	.word	isr

.section stack
    .equ STACK_SIZE, 64
.space  STACK_SIZE
stack_end:

/*------------------------------------------------------------------------------
*/
	.equ	PORT_ADDRESS, 0xff00

isr:
	push	r0
	push	r1
	mov	r1, PORT_ADDRESS & 0xff
	movt	r1, PORT_ADDRESS >> 8
	mov	r0, 1
	strb	r0, [r1]
	pop	r1
	pop	r0
	movs	pc, lr

main:
	mov	r1, PORT_ADDRESS & 0xff
	movt	r1, PORT_ADDRESS >> 8
	mov	r0, 0
	strb	r0, [r1]

	mov	r0, (1 << 4)
	msr	cpsr, r0
while:
	b 	while
