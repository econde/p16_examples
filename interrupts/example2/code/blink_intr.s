	.section .startup
	b	_start
	ldr	pc, addressof_isr
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
addressof_isr:
	.word	isr

	.text

	.data

	.section .stack
	.equ	STACK_SIZE, 1024
	.space	STACK_SIZE
stack_end:

/*==============================================================================

#define	LED_MASK	(1 << 0)
#define	BUTTON_MASK	(1 << 3)

int blink_state;
int led_state;

void main() {
	port_output(led_state | LED_MASK);
	interrupt_enable():
	while (1) {
		while ((port_input() & BUTTON_MASK) != 0)
			;

		blink_state = !blink_state;

		while ((port_input() & BUTTON_MASK) == 0)
			;
	}
}
*/

	.data
blink_state:
	.byte	0	; uint8_t blink_state;
led_state:
	.byte	0	; uint8_t led_state;

	.text

	.equ	BUTTON_MASK,	(1 << 3)
	.equ	LED_MASK,	(1 << 0)

	.equ	IFLAG_MASK,	(1 << 4)

main:
	ldr	r1, addressof_led_state	; port_output(led_state | LED_MASK);
	ldrb	r0, [r1]
	mov	r1, LED_MASK
	and	r0, r0, r1
	bl	port_output

	mov	r0, IFLAG_MASK		; interrupt_enable();
	msr	cpsr, r0
while:					; while (1) {
while1:
	bl	port_input		; while ((port_input() & BUTTON_MASK) != 0)
	mov	r1, BUTTON_MASK
	and	r0, r0, r1
	bzc	while1
	ldr	r1, addressof_blink_state
	ldrb	r0, [r1]		; blink_state = !blink_state;
	mvn	r0, r0
	strb	r0, [r1]
while2:
	bl	port_input		; while ((port_input() & BUTTON_MASK) == 0)
	mov	r1, BUTTON_MASK
	and	r0, r0, r1
	bzs	while2
	b	while

/*------------------------------------------------------------------------------
void isr() {
	if (blink_state)
		led_state = ~led_state;
	else
		led_state = 0;
	port_output(led_state  & LED_MASK);
	irequest_clear();
}
*/
	.equ	INTR_CLEAR_ADDRESS, 0xff40

isr:
	push	lr
	push	r0
	push	r1
	push	r2
	push	r3

	ldr	r1, addressof_blink_state	; if (blink_state)
	ldrb	r0, [r1]
	ldr	r1, addressof_led_state
	add	r0, r0, 0
	beq	isr_if_else
	ldrb	r0, [r1]		; led_state = !led_state;
	mvn	r0, r0
	b	isr_if_end
isr_if_else:
	mov	r0, 0			; led_state = 0;
isr_if_end:
	strb	r0, [r1]
	mov	r1, LED_MASK		; port_output(led_state  & LED_MASK);
	and	r0, r0, r1
	bl	port_output

	mov	r0, INTR_CLEAR_ADDRESS & 0xff
	movt	r0, INTR_CLEAR_ADDRESS >> 8
	ldr	r0, [r0]

	pop	r3
	pop	r2
	pop	r1
	pop	r0
	pop	lr
	movs	pc, lr

addressof_blink_state:
	.word	blink_state

addressof_led_state:
	.word	led_state

/*------------------------------------------------------------------------------
*/
	.equ	PORT_ADDRESS, 0xff00
port_input:
	mov	r0, PORT_ADDRESS & 0xff
	movt	r0, PORT_ADDRESS >> 8
	ldrb	r0,[r0]
	mov	pc, lr

port_output:
	mov	r1, PORT_ADDRESS & 0xff
	movt	r1, PORT_ADDRESS >> 8
	strb	r0,[r1]
	mov	pc, lr

