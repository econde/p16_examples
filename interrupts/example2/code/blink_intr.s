	.section .startup
	b	_start
	ldr	pc, addressof_isr
_start:
	ldr	sp, addressof_stack_end
	mov	r0, pc
	add	lr, r0, #4
	ldr	pc, addressof_main
	b	.

addressof_stack_end:
	.word stack_end
addressof_main:
	.word main
addressof_isr:
	.word isr

	.text

	.bss

	.equ	STACK_SIZE, 64
	.section .stack
	.space	STACK_SIZE
stack_end:

	.equ	IFLAG_MASK,	1 << 4	

/*==============================================================================

#define	LED_MASK	(1 << 0)
#define	BUTTON_MASK	(1 << 3)

int blink_state;
int led_state;

void main() {
	outport_write(led_state | LED_MASK);
	interrupt_enable():
	while (1) {
		while ((inport_read() & BUTTON_MASK) != 0)
			;

		blink_state = !blink_state;

		while ((inport_read() & BUTTON_MASK) == 0)
			;
	}
}
*/

	.bss
blink_state:
	.byte	0	; uint8_t blink_state;
led_state:
	.byte	0	; uint8_t led_state;

	.text

	.equ	BUTTON_MASK,	1 << 3
	.equ	LED_MASK,	1 << 0

main:
	ldr	r1, addressof_led_state	; outport_write(led_state | LED_MASK);
	ldrb	r0, [r1]
	mov	r1, #LED_MASK
	and	r0, r0, r1
	bl	outport_write

	mov	r1, #IFLAG_MASK		; interrupt_enable();
	mrs	r0, cpsr
	orr	r0, r0, r1
	msr	cpsr, r0
while:					; while (1) {
while1:
	bl	inport_read		; while ((inport_read() & BUTTON_MASK) != 0)
	mov	r1, #BUTTON_MASK
	and	r0, r0, r1
	bzc	while1
	ldr	r1, addressof_blink_state
	ldrb	r0, [r1]		; blink_state = !blink_state;
	mvn	r0, r0
	strb	r0, [r1]
while2:
	bl	inport_read		; while ((inport_read() & BUTTON_MASK) == 0)
	mov	r1, #BUTTON_MASK
	and	r0, r0, r1
	bzs	while2
	b	while

/*------------------------------------------------------------------------------
void isr() {
	if (blink_state)
		led_state = ~led_state;
	else
		led_state = 0;
	outport_write(led_state  & LED_MASK);
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
	add	r0, r0, #0
	beq	isr_if_else
	ldrb	r0, [r1]		; led_state = !led_state;
	mvn	r0, r0
	b	isr_if_end
isr_if_else:
	mov	r0, #0			; led_state = 0;
isr_if_end:
	strb	r0, [r1]
	mov	r1, #LED_MASK		; outport_write(led_state  & LED_MASK);
	and	r0, r0, r1
	bl	outport_write

	mov	r0, #INTR_CLEAR_ADDRESS & 0xff
	movt	r0, #INTR_CLEAR_ADDRESS >> 8
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
	.equ	INPORT_ADDRESS, 0xff80
inport_read:
	mov	r0, #INPORT_ADDRESS & 0xff
	movt	r0, #INPORT_ADDRESS >> 8
	ldrb	r0, [r0]
	mov	pc, lr

	.equ	OUTPORT_ADDRESS, 0xffc0
outport_write:
	mov	r1, #OUTPORT_ADDRESS & 0xff
	movt	r1, #OUTPORT_ADDRESS >> 8
	strb	r0, [r1]
	mov	pc, lr
