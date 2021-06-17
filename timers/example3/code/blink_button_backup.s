	.section .startup
	b	_start
	b	.
_start:
	ldr	sp, addr_stack_end
	ldr	r0, addr_main
	mov	r1, pc
	add	lr, r1, 4
	mov	pc, r0
	b	.

addr_stack_end:
	.word	stack_end

addr_main:
	.word	main

	.text

	.data

	.section .stack
	.equ	STACK_SIZE, 1024
	.space	STACK_SIZE
stack_end:

/*------------------------------------------------------------------------------
*/
	.equ	LED_MASK,	(1 << 0)
	.equ	BUTTON_MASK,	(1 << 3)

	.equ	HALF_PERIOD,	1000

/*------------------------------------------------------------------------------
void main() {
	uint8_t led_state = 0;
	uint8_t blink_state = 0;
	uint16_t initial = timer_read();
	port_output(LED_MASK & led_state);
	while (1) {
		while ((port_input() & BUTTON_MASK) == 0)
			if (timer_elapsed(initial) >= HALF_PERIOD) {
				if (blink_state)
					led_state = ~led_state;
				else
					led_state = 0;
				port_output(LED_MASK & led_state);
				initial = timer_read();
			}
		blink_state = !blink_state;

		while (port_input_test(BUTTON_MASK) == 1)
			if (timer_elapsed(initial) >= HALF_PERIOD) {
				if (blink_state)
					led_state = ~led_state;
				else
					led_state = 0;
				port_output(LED_MASK & led_state);
				initial = timer_read();
			}
	}
}
*/
	.text
main:
	push	r4
	push	r5
	push	r6
	mov	r4, 0		; uint8_t led_state = 0;
	mov	r5, 0		; uint8_t blink_state = 0;
	bl	timer_read	; uint8_t initial = timer_read();
	mov	r6, r0
	mov	r0, r4		; port_output(LED_MASK & led_state);
	bl	port_output
while:				; while (1) {
while1:
	bl	port_input	; while ((port_input() & BUTTON_MASK) == 0)
	mov	r1, BUTTON_MASK
	and	r0, r0, r1
	bzc	while1_end
	mov	r0, r6		; if (timer_elapsed(initial) >= HALF_PERIOD) {
	bl	timer_elapsed
	mov	r1, HALF_PERIOD & 0xff
	movt	r1, HALF_PERIOD >> 8
	cmp	r0, r1
	blo	if1_end
	and	r5, r5, r5	; if (blink_state)
	bzc	if11_else
	mvn	r4, r4		; led_state = ~led_state;
	b	if11_end
if11_else:
	mov	r4, 0		; led_state = 0;
if11_end:
	mov	r0, LED_MASK	; port_output(LED_MASK & led_state);
	and	r0, r0, r4
	bl	port_output
	bl	timer_read	; initial = timer_read();
	mov	r6, r0
if1_end:
while1_end:

	mvn	r5, r5		; blink_state = ~blink_state;
while2:
	bl	port_input	; while ((port_input() & BUTTON_MASK) == 0)
	mov	r1, BUTTON_MASK
	and	r0, r0, r1
	bzs	while2_end
	mov	r0, r6		; if (timer_elapsed(initial) >= HALF_PERIOD) {
	bl	timer_elapsed
	mov	r1, HALF_PERIOD & 0xff
	movt	r1, HALF_PERIOD >> 8
	cmp	r0, r1
	blo	if2_end
	and	r5, r5, r5	; if (blink_state)
	bzc	if21_else
	mvn	r4, r4		; led_state = !led_state;
	b	if21_end
if21_else:
	mov	r4, 0		; led_state = 0;
if21_end:
	mov	r0, LED_MASK	; port_output(LED_MASK & led_state);
	and	r0, r0, r4
	bl	port_output
	bl	timer_read	; initial = timer_read();
	mov	r6, r0
if2_end:
while2_end:
	b	while

/*------------------------------------------------------------------------------
*/
	.equ	PORT_ADDRESS, 0xff00
	.equ	TIMER_ADDRESS, 0xcc00

/*------------------------------------------------------------------------------
	uint8_t timer_read();
*/
timer_read:
	mov	r0, TIMER_ADDRESS & 0xff
	movt	r0, TIMER_ADDRESS >> 8
	ldr	r0, [r0]
	mov	pc, lr

timer_elapsed:
	mov	r0, TIMER_ADDRESS & 0xff
	movt	r0, TIMER_ADDRESS >> 8
	ldr	r1, [r1]
	sub	r0, r1, r0
	mov	pc, lr

/*------------------------------------------------------------------------------
	uint8_t port_input();
*/
port_input:
	mov	r0, PORT_ADDRESS & 0xff
	movt	r0, PORT_ADDRESS >> 8
	ldrb	r0,[r0]
	mov	pc, lr

/*------------------------------------------------------------------------------
	void port_output(uint8_t);
*/
port_output:
	mov	r1, PORT_ADDRESS & 0xff
	movt	r1, PORT_ADDRESS >> 8
	strb	r0,[r1]
	mov	pc, lr

