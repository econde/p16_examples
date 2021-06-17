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
	.word stack_end
addressof_main:
	.word main
addressof_isr:
	.word isr

	.text

	.data

	.section .stack
	.equ	STACK_SIZE, 64
	.space	STACK_SIZE
stack_end:

/*==============================================================================
*/
/*
   #define LED_MASK (1 << 7)

   #define HALF_PERIOD 50

   volatile uint16_t system_clock;

   void main() {
   	uint8_t led_state = ~0;
   	interrupt_enable();
   	while (1) {
   		port_output(led_state & LED_MASK);
   		uint16_t initial = system_clock;
   		while (system_clock - initial < HALF_PERIOD)
   			;
   		led_state = ~led_state;
   	}
   }

   void isr() {
   	system_clock++;
   }
*/

	.data
system_clock:
	.word 0				; volatile uint16_t system_clock;

	.text

	.equ	IFLAG_MASK,	(1 << 4)

	.equ	LED_MASK,	(1 << 7)

	.equ	PERIOD, 	10
	.equ	HALF_PERIOD,	PERIOD / 2

main:
	mov	r4, ~0			; uint8_t led_state = ~0
	mov	r0, IFLAG_MASK		; interrupt_enable();
	msr	cpsr, r0
while:               			; while (1) {
	mov	r0, LED_MASK
	and	r0, r0, r4
	bl 	port_output		; port_output(led_state & LED_MASK);
	ldr	r1, addressof_system_clock
	ldr	r5, [r1]		; uint16_t initial = system_clock;
while1:              			; while (
	ldr	r0, [r1]		;	system_clock - initial
	sub	r0, r0, r5
	mov	r2, HALF_PERIOD & 0xff
	movt	r2, HALF_PERIOD >> 8
	cmp	r0, r2			;	< HALF_PERIOD)
	blo	while1
	mvn	r4, r4			; led_state = ~led_state;
	b	while

/*-------------------------------------------------------------------------
*/
	.text
isr:
	push r0
	push r1

	ldr	r1,addressof_system_clock	; system_clock++;
	ldr	r0,[r1]
	add	r0,r0, 1
	str	r0,[r1]

	pop	r1
	pop	r0
	movs	pc, lr

addressof_system_clock:
	.word system_clock

/*-------------------------------------------------------------------------
*/
	.equ SDP16_PORT_ADDRESS, 0xff00

port_output:
	mov	r1, SDP16_PORT_ADDRESS & 0xff
	movt	r1, SDP16_PORT_ADDRESS >> 8
	strb	r0,[r1]
	mov	pc, lr
