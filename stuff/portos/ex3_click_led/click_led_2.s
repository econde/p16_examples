.section .startup
	b	_start
	b	.
_start:
	ldr	sp, addr_stack_top
	bl	main
	b	.

addr_stack_top:
	.word	stack_top

	.text

	.data

	.section .stack
	.space	64
stack_top:

/*------------------------------------------------------------------------------
*/
	.equ	BUTTON_MASK, 1
	.equ	LED_MASK, 1
/*

void main() {
	uint8_t led_state = 0;	/* r4 */
	uint8_t button_prev = port_input() & BUTTON_MASK;	/* r5 */

	port_output(led_state);
	while (1) {
		uint8_t button = port_input() & BUTTON_MASK;	/* r6 */
		if (button_prev == 0 && button != 0) {
			led_state = ~led_state;
			port_output(led_state & LED_MASK);
		}
		button_prev = button;
	}
}
*/

	.text
main:
	mov	r4, 0		; uint8_t led_state = 0;
	bl	port_input	; uint8_t button_prev = port_input() & BUTTON_MASK;
	mov	r1, BUTTON_MASK
	and	r5, r0, r1
	mov	r0, r4		; port_output(led_state);
	bl	port_output
while:
	bl	port_input	; uint8_t button = port_input() & BUTTON_MASK;
	mov	r1, BUTTON_MASK
	and	r6, r0, r1
	and	r5, r5, r5	; if (button_prev == 0
	bzc	if_end
	and	r6, r6, r6	; 	 && button != 0) {
	bzs	if_end
	not	r5, r5		; led_state = ~led_state;
	mov	r0, LED_MASK	; port_output(led_state & LED_MASK);
	and	r0, r0, r5
	bl	port_output
if_end:
	mov	r4, r6		; button_prev = button;
	b	while

/*------------------------------------------------------------------------------
*/
	.equ	PORT_ADDRESS, 0xff00
port_input:
	mov	r0, PORT_ADDRESS & 0xff
	movt	r0, PORT_ADDRESS >> 8
	ldrb	r0,[r0, 1]
	mov	pc, lr

port_output:
	mov	r1, PORT_ADDRESS & 0xff
	movt	r1, PORT_ADDRESS >> 8
	strb	r0,[r1, 1]
	mov	pc, lr

