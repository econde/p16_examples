#define ASSEMBLY

#ifdef ASSEMBLY

.section .startup
	b	_start
	ldr	pc, addr_isr
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
addr_isr:
	.word	isr

	.text

	.data

	.section .stack
	.equ	STACK_SIZE, 1024
	.space	STACK_SIZE
stack_top:

#endif

/*------------------------------------------------------------------------
*/

#ifndef	ASSEMBLY

#include <stdint.h>

#define	LED_MASK	1
#define	BUTTON_MASK	1

void timer_delay();
void timer_init();

uint8_t blink_state = 0;
uint8_t led_state = 0;

#define	LED_MASK	1
#define	HALF_PERIOD	500

void timer_delay(uint16_t time) {
	while (time--> 0)
		;
}

void main() {
	timer_init();
	iflag_enable();
	while (1) {		
		if (blink_state != 0)
			led_state = ~led_state;
		else
			led_state = 0;
		outport_write(led_state & LED_MASK);
		timer_delay(HALF_PERIOD);
	}
}

#else

	.data
blink_state:
	.byte	0	; uint8_t blink_state;
led_state:
	.byte	0	; uint8_t led_state;

	.equ	BUTTON_MASK, 1
	.equ	LED_MASK, 1
	.equ	IFLAG_MASK, 0x10
	.equ	HALF_PERIOD, 500

	.text
main:
	ldr	r1, addr_led_state	; outport_write(led_state & LED_MASK);
	ldrb	r0, [r1]
	mov	r1, LED_MASK
	and	r0, r0, r1
	ldr	r1, addr_port
	strb	r0, [r1]
	mov	r0, IFLAG_MASK		; iflag_enable();
	msr	cpsr, r0
while:					; while (1) {
	ldr	r1, addr_blink_state
	ldrb	r0, [r1]		; if (blink_state != 0)
	and	r0, r0, r0
	ldr	r1, addr_led_state
	ldrb	r0, [r1]
	bzs	if_else
	not	r0, r0			; led_state = ~led_state;
	b	if_end
if_else:
	mov	r0, 0
if_end:
	strb	r0, [r1]
	mov	r2, LED_MASK		; outport_write(led_state & LED_MASK);
	and	r0, r0, r12
	ldr	r1, addr_port
	strb	r0, [r1]
	bl	timer_delay
	b	while
#endif

addr_led_state:
	.word	led_state

timer_delay:
	sub	r0, r0, 0
	bzs	timer_delay_exit
timer_delay_while:
	sub	r0, r0, 1
	bzc	timer_delay_while
timer_delay_exit:
	mov	pc, lr

/*------------------------------------------------------------------------
*/

#ifndef ASSEMBLY

void irequest_clear();

void isr() {
	blink_state = ~blink_state;
	irequest_clear();
}

#else

	.equ	IREQUEST_MASK, 0x80
	.text
isr:
	push	r0
	push	r1

	ldr	r1, addr_blink_state	; blink_state = ~blink_state;
	ldrb	r0, [r1]
	not	r0, r0
	strb	r0, [r1]

	ldr	r1, addr_port		; irequest_clear();
	mov	r0, IREQUEST_MASK
	strb	r0, [r1]

	pop	r1
	pop	r0
	movs	pc, lr

addr_blink_state:
	.word	blink_state

addr_port:
	.word	0xff00

#endif
