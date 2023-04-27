	.section .startup
	b	_start
	b	.
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

	.text

	.data

	.section .stack
	.equ	STACK_SIZE, 64
	.space	STACK_SIZE
stack_end:

/*==============================================================================
*/

/*------------------------------------------------------------------------------
uint8_t led_state;
uint8_t blink_state;
uint16_t timer_initial;
*/
	.data
led_state:
	.byte 	0
blink_state:
	.byte 	0
timer_initial:
	.word 	0

/*------------------------------------------------------------------------------
void main() {
	blink_init();
	while (1) {
		while ((inport_read() & BUTTON_MASK) != 0)
			blink_processing();

		blink_state = !blink_state;

		while (inport_read_test(BUTTON_MASK) == 0)
			blink_processing();
	}
}
*/
	.equ	LED_MASK, 	(1 << 0)
	.equ	BUTTON_MASK,	(1 << 3)
	.equ	HALF_PERIOD,	10


	.text
main:
	bl	blink_init
while:				; while (1) {
while1:
	bl	inport_read	; while ((inport_read() & BUTTON_MASK) == 0)
	mov	r1, BUTTON_MASK
	and	r0, r0, r1
	bzc	while1_end
	bl	blink_processing
	b	while1
while1_end:

	ldr	r1, addressof_blink_state
	ldrb	r0, [r1]
	mvn	r0, r0		; blink_state = ~blink_state;
	strb	r0, [r1]

while2:
	bl	inport_read	; while ((inport_read() & BUTTON_MASK) == 0)
	mov	r1, BUTTON_MASK
	and	r0, r0, r1
	bzs	while2_end
	bl	blink_processing
	b	while2
while2_end:
	b	while

/*------------------------------------------------------------------------------
void blink_init() {
	led_state = 0;
	blink_state = 0;
	timer_initial = timer_read();
	outport_write(LED_MASK & led_state);
}
*/
	.text
blink_init:
	push	lr
	mov	r0, 0
	ldr	r1, addressof_led_state
	strb	r0, [r1]
	ldr	r1, addressof_blink_state
	strb	r0, [r1]
	ldr	r1, addressof_initial
	bl	timer_read
	str	r0, [r1]

	mov	r0, 0		; outport_write(LED_MASK & led_state);
	bl	outport_write

	pop	pc

/*------------------------------------------------------------------------------
void blink_processing() {
	if (timer_elapsed(timer_initial) >= HALF_PERIOD) {
		if (blink_state)
			led_state = ~led_state;
		else
			led_state = 0;
		outport_write(LED_MASK & led_state);
		timer_initial = timer_read();
	}
}
*/

blink_processing:
	push	lr
	ldr	r1, addressof_initial
	ldr	r0, [r1]	; if (timer_elapsed(timer_initial) >= HALF_PERIOD) {
	bl	timer_elapsed
	mov	r1, HALF_PERIOD & 0xff
	movt	r1, HALF_PERIOD >> 8
	cmp	r0, r1
	blo	if1_end
	ldr	r1, addressof_blink_state	; if (blink_state)
	ldrb	r0, [r1]
	and	r0, r0, r0
	ldr	r2, addressof_led_state
	ldrb	r0, [r2]
	bzs	if2_else
	mvn	r0, r0		; led_state = ~led_state;
	b	if2_end
if2_else:
	mov	r0, 0		; led_state = 0;
if2_end:
	strb	r0, [r2]
	mov	r1, LED_MASK	; outport_write(LED_MASK & led_state);
	and	r0, r0, r1
	bl	outport_write
	bl	timer_read	; timer_initial = timer_read();
	ldr	r1, addressof_initial
	str	r0, [r1]
if1_end:
	pop	pc

addressof_led_state:
	.word	led_state

addressof_blink_state:
	.word	blink_state

addressof_initial:
	.word	timer_initial

/*------------------------------------------------------------------------------
	uint8_t timer_read();
*/
	.equ	TIMER_ADDRESS, 0xff80
timer_read:
	mov	r0, TIMER_ADDRESS & 0xff
	movt	r0, TIMER_ADDRESS >> 8
	ldr	r0, [r0]
	mov	pc, lr

/*------------------------------------------------------------------------------
	uint16_t timer_elapsed(uint16_t timer_initial) {
		return timer_read() - timer_initial;
	}
*/

timer_elapsed:
	mov	r1, TIMER_ADDRESS & 0xff
	movt	r1, TIMER_ADDRESS >> 8
	ldr	r1, [r1]
	sub	r0, r1, r0
	mov	pc, lr

/*------------------------------------------------------------------------------
	uint8_t inport_read();
*/
	.equ	PORT_ADDRESS, 0xff00

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

