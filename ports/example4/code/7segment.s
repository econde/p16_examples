	.section .startup
	b	_start
	b	.
_start:
	ldr	sp, addressof_stack_end
	bl	main
	b	.

addressof_stack_end:
	.word	stack_end

	.text

	.data

	.section .stack
	.space	64
stack_end:

/*------------------------------------------------------------------------------
#define	LED_MASK		(1 << 7)
#define	DISPLAY_MASK		0x7f
#define	BUTTON_UPDOWN_MASK	(1 << 1)
#define	BUTTON_CLOCK_MASK	(1 << 6)

	   a
	   --
	f |  | b
	   --
	e |  | c
	   --
	   d

const uint8_t bin7seg[] =
	{0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f};

Logisim
7 6 5 4 3 2 1 0		g f e d c b a
  c d e g f a b         3 2 4 5 6 0 1

const uint8_t bin7seg[] =
	{0x77, 0x41, 0x3b, 0x6b, 0x4d, 0x6e, 0x7e, 0x43, 0x7f, 0x6f};

void main() {
	uint16_t counter;
	uint8_t direction_state = 0;
	uint8_t port_prev = ~inport_read();

	outport_write_bits(LED_MASK, direction_state ? LED_MASK : 0);
	outport_write_bits(DISPLAY_MASK, tab7seg[counter]);

	while (1) {
		uint8_t port_actual = ~inport_read();
		if ((port_prev & BUTTON_UPDOWN_MASK) == 0 && (port_actual & BUTTON_UPDOWN_MASK) != 0) {
			direction_state = ~direction_state;
			outport_write_bits(LED_MASK, direction_state ? LED_MASK : 0);
		}
		if ((port_prev & BUTTON_CLOCK_MASK) == 0 && (port_actual & BUTTON_CLOCK_MASK) != 0) {
			if (direction_state)
				if (counter == 9)
					counter = 0;
				else
					counter += 1;
			else
				if (counter == 0)
					counter = 9;
				else
					counter -= 1;
			outport_write_bits(DISPLAY_MASK, tab7seg[counter]);
		}
		port_prev = port_actual;
	}
}
/*------------------------------------------------------------------------------
*/
	.equ	LED_MASK,		(1 << 7)
	.equ	DISPLAY_MASK,		0b01111111
	.equ	BUTTON_UPDOWN_MASK,	(1 << 1)
	.equ	BUTTON_CLOCK_MASK,	(1 << 6)

	.text

bin7seg:
	.byte	0x77, 0x41, 0x3b, 0x6b, 0x4d, 0x6e, 0x7e, 0x43, 0x7f, 0x6f

main:
	push	lr
	push	r4
	push	r5
	push	r6
	push	r7
	mov	r4, 0		; uint8_t counter = 0;
	mov	r5, 0 		; uint8_t direction_state = 0;
	bl	inport_read	; uint8_t port_prev = ~inport_read();
	mvn	r6, r0

	add	r5, r5, 0	; outport_write_bits(LED_MASK, direction_state ? LED_MASK : 0);
	bzs	main_cond1
	mov	r1, LED_MASK
	b	main_cond1_end
main_cond1:
	mov	r1, 0
main_cond1_end:
	mov	r0, LED_MASK
	bl	outport_write_bits

	ldr	r0, addressof_bin7seg	; outport_write_bits(DISPLAY_MASK, tab7seg[counter]);
	ldrb	r1, [r0, r4]
	mov	r0, DISPLAY_MASK
	bl	outport_write_bits
main_while:
	bl	inport_read		; uint8_t port_actual = ~inport_read();
	mvn	r7, r0
	mov	r1, BUTTON_UPDOWN_MASK	; if ((port_prev & BUTTON_UPDOWN_MASK) == 0
	and	r0, r6, r1
	bzc	main_if1_end
	and	r0, r7, r1
	bzs	main_if1_end		; && (port_actual & BUTTON_UPDOWN_MASK) != 0) {
	mvn	r5, r5			; direction_state = ~direction_state;
	add	r5, r5, 0
	bzs	main_cond2		; outport_write_bits(LED_MASK, direction_state ? LED_MASK : 0);
	mov	r1, LED_MASK
	b	main_cond2_end
main_cond2:
	mov	r1, 0
main_cond2_end:
	mov	r0, LED_MASK
	bl	outport_write_bits
main_if1_end:

	mov	r1, BUTTON_CLOCK_MASK	; if ((port_prev & BUTTON_CLOCK_MASK) == 0
	and	r0, r6, r1
	bzc	main_if2_end
	and	r0, r7, r1
	bzs	main_if2_end		; && (port_actual & BUTTON_CLOCK_MASK) != 0) {

	add	r5, r5, 0		; if (direction_state)
	bzs	main_if3_else
	mov	r0, 9			; if (counter == 9)
	cmp	r4, r0
	bzc	main_if4_else
	mov	r4, 0			; counter = 0;
	b	main_if4_end
main_if4_else:
	add	r4, r4, 1		; counter += 1;
main_if4_end:
	b	main_if3_end
main_if3_else:
	add	r4, r4, 0		; if (counter == 0)
	bzc	main_if5_else
	mov	r4, 9			; counter = 9;
	b	main_if5_end
main_if5_else:
	sub	r4, r4, 1		; counter -= 1;
main_if5_end:
main_if3_end:
	ldr	r0, addressof_bin7seg	; outport_write_bits(DISPLAY_MASK, tab7seg[counter]);
	ldrb	r1, [r0, r4]
;	mov	r1, r4
	mov	r0, DISPLAY_MASK
	bl	outport_write_bits
main_if2_end:
	mov	r6, r7			; port_prev = port_actual;
	b	main_while
	pop	r6
	pop	r5
	pop	r4
	pop	pc

addressof_bin7seg:
	.word	bin7seg

/*------------------------------------------------------------------------------
static uint8_t outport_image;

void outport_write_bits(uint8_t mask, uint8_t value) {
	outport_write(outport_image & ~mask | value & mask);
}
*/
	.data
image:
	.byte	0

	.text
outport_write_bits:
	push	lr
	ldr	r2, addressof_outport_image
	ldrb	r3, [r2]
	mvn	r0, r0
	and	r3, r3, r0
	mvn	r0, r0
	and	r1, r1, r0
	orr	r0, r3, r1
	bl	outport_write
	pop	pc

/*------------------------------------------------------------------------------
	;uint8_t inport_read();
*/
	.equ	INPORT_ADDRESS, 0xcc00

inport_read:
	mov	r0, INPORT_ADDRESS & 0xff
	movt	r0, INPORT_ADDRESS >> 8
	ldrb	r0,[r0, 0]
	mov	pc, lr

/*------------------------------------------------------------------------------
	;void outport_write(uint8_t);
*/
	.equ	OUTPORT_ADDRESS, 0xcc00

outport_write:
	mov	r1, OUTPORT_ADDRESS & 0xff
	movt	r1, OUTPORT_ADDRESS >> 8
	strb	r0, [r1, 0]
	ldr	r1, addressof_outport_image
	strb	r0, [r1, 0]
	mov	pc, lr

addressof_outport_image:
	.word	image
