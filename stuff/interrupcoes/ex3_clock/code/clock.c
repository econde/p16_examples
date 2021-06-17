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

	.data

	.text

	.section .stack
	.equ	STACK_SIZE, 1024
	.space	STACK_SIZE
stack_top:

#endif

/*------------------------------------------------------------------------------
*/

#ifndef ASSEMBLY

#include <stdint.h>
void interrupt_enable();
void irequest_clear();
uint8_t button_read();

void hour_inc();
void hour_dec();

void minute_inc();
void minute_dec();

void display_write(uint8_t hour, uint8_t minute);
void display_refresh();
void clock_tic();

void port_ex0_write(uint8_t, uint8_t);
void port_write(uint8_t, uint8_t);

uint8_t port_input();
void port_output(uint8_t);
void port_ex0_output(uint8_t);

#define BUTTON_UP_MASK		1
#define BUTTON_DOWN_MASK	2
#define BUTTON_HOUR_MIN_MASK	4

uint8_t hour;
uint8_t minute;
uint8_t second;

int main() {
	uint8_t hit = 0;
	irequest_clear();
	interrupt_enable();
	while (1) {
		uint8_t button = button_read();
		if ((button & BUTTON_UP_MASK) != 0) {
			if (hit)
				hour_inc();
			else
				minute_inc();
			display_write(hour, minute);
		}
		if ((button & BUTTON_DOWN_MASK) != 0) {
			if (hit)
				hour_dec();
			else
				minute_dec();
			display_write(hour, minute);
		}
		if ((button & BUTTON_HOUR_MIN_MASK) != 0) {
			hit != hit;
		}
	}
}

#else

	.data
hour:
	.byte	0
minute:
	.byte	0
second:
	.byte	0
hit:
	.byte	0

	.equ	BUTTON_UP_MASK,		1
	.equ	BUTTON_DOWN_MASK,	2
	.equ	BUTTON_HOUR_MIN_MASK,	4

	.equ 	IFLAG_MASK, 0x10
	.equ	SDP16_PORT_ADDRESS, 0xff00
	.equ	SDP16_CS_EX0_ADDRESS, 0xff40

	.text
main:
	bl	irequest_clear
	mov	r0, IFLAG_MASK		;  interrupt_enable();
	msr	cpsr, r0
	mov	r4, 0			; uint8_t hit = 0;
while:
	bl	button_read		; uint8_t button = button_read();
if_up:
	mov	r1, BUTTON_UP_MASK	; if ((button & BUTTON_UP_MASK) != 0) {
	and	r1, r1, r0
	bzs	if_down
	add	r4, r4, 0		; 	if (hit)
	bzc	if_up_else
	bl	hour_inc
	b	if_up_end
if_up_else:
	bl	minute_inc
if_up_end:
	ldr	r0, addr_hour_2		; display_write(hour, minute);
	ldrb	r0, [r0]
	ldr	r1, addr_minute_2
	ldrb	r1, [r1]
	bl	display_write
	b	while

if_down:
	mov	r1, BUTTON_DOWN_MASK	; if ((button & BUTTON_DOWN_MASK) != 0) {
	and	r1, r1, r0
	bzs	if_hour_min
	add	r4, r4, 0		; 	if (hit)
	bzc	if_down_else
	bl	hour_dec
	b	if_down_end
if_down_else:
	bl	minute_dec
if_down_end:
	ldr	r0, addr_hour_2		; display_write(hour, minute);
	ldrb	r0, [r0]
	ldr	r1, addr_minute_2
	ldrb	r1, [r1]
	bl	display_write
	b	while

if_hour_min:
	mov	r1, BUTTON_HOUR_MIN_MASK ; if ((button & BUTTON_HOUR_MIN_MASK) != 0) {
	and	r1, r1, r0
	bzs	while
	not	r4, r4
	b	while

addr_hit:
	.word	hit
#endif

addr_minute_2:
	.word	minute
addr_hour_2:
	.word	hour

/*------------------------------------------------------------------------------
*/

#ifndef ASSEMBLY

void isr() {
	display_refresh();
	clock_tic();
	irequest_clear();
}

#else

	.text
isr:
	push	r0
	push	r1
	push	r2
	push	r3
	push	lr
	bl	display_refresh
	bl	clock_tic
	bl	irequest_clear
	pop	lr
	pop	r3
	pop	r2
	pop	r1
	pop	r0
	movs	pc, lr
#endif

/*------------------------------------------------------------------------------
*/

#ifndef	ASSEMBLY

#define CLOCK_SCALE_MAX	2

uint16_t clock_scale;

void clock_tic() {
	if (--clock_scale == 0) {
		clock_scale = CLOCK_SCALE_MAX;
		if (++second == 60) {
			second = 0;
			if (++minute == 60) {
				minute = 0;
				if (++hour == 24)
					hour = 0;
			}
			display_write(hour, minute);
		}
	}
}

#else

	.data
	.align
clock_scale:
	.word	0
	.equ	CLOCK_SCALE_MAX, 1000

	.text
clock_tic:
	push	lr
	ldr	r1, addr_clock_scale	; if (--clock_scale == 0) {
	ldr	r0, [r1]
	sub	r0, r0, 1
	str	r0, [r1]
	bzc	tic_if1_end
	mov	r0, CLOCK_SCALE_MAX & 0xff	; clock_scale = CLOCK_SCALE;
	movt	r0, CLOCK_SCALE_MAX >> 8
	str	r0, [r1]
	ldr	r1, addr_second		; if (++second == 60) {
	ldrb	r0, [r1]
	add	r0, r0, 1
	str	r0, [r1]
	mov	r2, 60
	sub	r0, r0, r2
	bne	tic_if2_end
	strb	r0, [r1]		; second = 0;
	ldr	r1, addr_minute		; if (++minute == 60) {
	ldrb	r0, [r1]
	add	r0, r0, 1
	strb	r0, [r1]
	mov	r2, 60
	sub	r0, r0, r2
	bne	tic_if3_end
	strb	r0, [r1]		; minute = 0;
	ldr	r1, addr_hour		; if (++hour == 24)
	ldrb	r0, [r1]
	add	r0, r0, 1
	strb	r0, [r1]
	mov	r2, 24
	sub	r0, r0, r2
	bne	tic_if4_end
	strb	r0, [r1]		; hour = 0;
tic_if3_end:
tic_if4_end:
	ldr	r0, addr_hour		; display_write(hour, minute);
	ldrb	r0, [r0]
	ldr	r1, addr_minute
	ldrb	r1, [r1]
	bl	display_write
tic_if1_end:
tic_if2_end:
	pop	pc

addr_clock_scale:
	.word	clock_scale

addr_second:
	.word	second
	
hour_inc:
	ldr	r1, addr_hour
	ldrb	r0, [r1]
	add	r0, r0, 1
	strb	r0, [r1]
	mov	r2, 24
	sub	r0, r0, r2
	bne	hour_inc_exit
	strb	r0, [r1]
hour_inc_exit:
	mov	pc, lr

hour_dec:
	ldr	r1, addr_hour
	ldrb	r0, [r1]
	add	r0, r0, 0
	bne	hour_dec_exit
	mov	r0, 24
hour_dec_exit:
	sub	r0, r0, 1
	strb	r0, [r1]
	mov	pc, lr

minute_inc:
	ldr	r1, addr_minute
	ldrb	r0, [r1]
	add	r0, r0, 1
	strb	r0, [r1]
	mov	r2, 60
	sub	r0, r0, r2
	bne	minute_inc_exit
	strb	r0, [r1]
minute_inc_exit:
	mov	pc, lr

minute_dec:
	ldr	r1, addr_minute
	ldrb	r0, [r1]
	add	r0, r0, 0
	bne	minute_dec_exit
	mov	r0, 60
minute_dec_exit:
	sub	r0, r0, 1
	strb	r0, [r1]
	mov	pc, lr

addr_minute:
	.word	minute
addr_hour:
	.word	hour

#endif

/*------------------------------------------------------------------------------
*/

#ifndef	ASSEMBLY

#define	DISPLAY_MASK	0x7f
#define	NDIGIT	4

uint8_t display_image[4];
uint8_t display_current;
const uint8_t display_comm[] = {1, 2, 4, 8};
const uint8_t bin7seg[] = {0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f};

void display_write(uint8_t hour, uint8_t minute) {
	display_image[1] = bin7seg[hour % 10];
	display_image[0] = bin7seg[hour / 10];
	display_image[3] = bin7seg[minute % 10];
	display_image[2] = bin7seg[minute / 10];
	display_current = 0;
}

void display_refresh() {
	port_ex0_write(0, display_comm[display_current]);
	if (++display_current == NDIGIT)
		display_current = 0;
	port_write(display_image[display_current], DISPLAY_MASK);
	uint8_t comm_mask = display_comm[display_current];
	port_ex0_write(comm_mask, comm_mask);
}

#else

	.equ	DISPLAY_MASK, 0x7f
	.equ	NDIGIT, 4

	.data
display_image:
	.space	NDIGIT
display_current:
	.byte	0

	.text
display_refresh:
	push	lr
	push	r4

	ldr	r4, addr_display_current
	ldrb	r0, [r4]		; display_current
	ldr	r1, addr_display_comm	; display_comm[display_current]);
	ldrb	r1, [r1, r0]
	mov	r0, 0			; port_ex0_write(0, 
	bl	port_ex0_write

	ldrb	r0, [r4]		; if (++display_current == NDIGIT) {
	add	r0, r0, 1
	mov	r1, NDIGIT
	cmp	r0, r1
	bzc	display_refresh_if_end
	mov	r0, 0
display_refresh_if_end:
	strb	r0, [r4]

	ldr	r1, addr_display_image	; port_write(diplay_image[display_current],
	ldrb	r0, [r1, r0]		;	DISPLAY_MASK);
	mov	r1, DISPLAY_MASK
	bl	port_write

	ldrb	r0, [r4]
	ldr	r1, addr_display_comm	; uint8_t comm_mask = display_comm[display_current];
	ldrb	r0, [r1, r0]
	mov	r1, r0			; port_ex0_write(comm_mask, comm_mask);
	bl	port_ex0_write

	pop	r4
	pop	pc

addr_display_current:
	.word	display_current

display_comm:
	.byte	1, 2, 4, 8

addr_display_comm:
	.word	display_comm

	.text
display_write:
	push	lr
	push	r4
	push	r5
	push	r6
	push	r7
	ldr	r6, addr_bin7seg
	ldr	r7, addr_display_image
	mov	r4, r0
	mov	r5, r1
	mov	r1, 10
	bl	module
	ldrb	r0, [r6, r0]
	strb	r0, [r7, 1]

	mov	r0, r4
	mov	r1, 10
	bl	divide
	ldrb	r0, [r6, r0]
	strb	r0, [r7, 0]

	mov	r0, r5
	mov	r1, 10
	bl	module
	ldrb	r0, [r6, r0]
	strb	r0, [r7, 3]

	mov	r0, r5
	mov	r1, 10
	bl	divide
	ldrb	r0, [r6, r0]
	strb	r0, [r7, 2]
	pop	r7
	pop	r6
	pop	r5
	pop	r4
	pop	pc

bin7seg:
	.byte 0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f

addr_bin7seg:
	.word 	bin7seg

addr_display_image:
	.word	display_image

#endif

/*------------------------------------------------------------------------------
	Input port operations
*/

#ifndef	ASSEMBLY

uint8_t button_prev;

uint8_t button_read() {
	uint8_t button = port_input();
	uint8_t result = ~button_prev & button;
	button_prev = button;
	return result;
}

#else

	.data
button_prev:
	.byte	0

	.text
button_read:
	mov	r1, SDP16_PORT_ADDRESS & 0xff
	movt	r1, SDP16_PORT_ADDRESS >> 8
	ldrb	r2, [r1]
	ldr	r0, addr_button_prev
	ldrb	r1, [r0]
	strb	r2, [r0]
	not	r1, r1
	and	r0, r1, r2
	mov	pc, lr

addr_button_prev:
	.word	button_prev

#endif

/*------------------------------------------------------------------------------
 * Interrupt control
 */

#ifndef	ASSEMBLY
#define	IREQUEST_CLEAR_MASK	0x10

void irequest_clear() {
	port_ex0_write(0, IREQUEST_CLEAR_MASK);
	port_ex0_write(IREQUEST_CLEAR_MASK, IREQUEST_CLEAR_MASK);
}

#else

	.equ	IREQUEST_CLEAR_MASK, 0x10

irequest_clear:
	push	lr
	mov	r0, 0			; port_ex0_write(0, IREQUEST_CLEAR_MASK);
	mov	r1, IREQUEST_CLEAR_MASK
	bl 	port_ex0_write
	mov	r0, IREQUEST_CLEAR_MASK	; port_ex0_write(IREQUEST_CLEAR_MASK, IREQUEST_CLEAR_MASK);
	mov	r1, IREQUEST_CLEAR_MASK
	bl 	port_ex0_write
	pop	pc
#endif

/*------------------------------------------------------------------------
	Output port operations
*/
#ifdef	ASSEMBLY

	.data
port_image:
	.byte	0

port_ex0_image:
	.byte	0

	.text
port_write:
	and	r0, r0, r1
	ldr	r2, addr_port_image
	ldrb	r3, [r2]
	not	r1, r1
	and	r3, r3, r1
	or	r0, r0, r3
	strb	r0, [r2]
	mov	r1, SDP16_PORT_ADDRESS & 0xff
	movt	r1, SDP16_PORT_ADDRESS >> 8
	strb	r0, [r1]
	mov	pc, lr

port_ex0_write:
	and	r0, r0, r1
	ldr	r2, addr_port_ex0_image
	ldrb	r3, [r2]
	not	r1, r1
	and	r3, r3, r1
	or	r0, r0, r3
	strb	r0, [r2]
	mov	r1, SDP16_CS_EX0_ADDRESS & 0xff
	movt	r1, SDP16_CS_EX0_ADDRESS >> 8
	strb	r0, [r1]
	mov	pc, lr

addr_port_image:
	.word port_image

addr_port_ex0_image:
	.word port_ex0_image

/*--------------------------------------------------------------------
<r0> uint16_t int divide(<r0> uint16 dividend, <r1> uint16_t divisor) {
	<r2> uint16_t i = 16;
	<r3> uint16_t remainder = 0, <r4> quocient = 0;
	do {
		uint16 dividend_msb = dividend >> 15;
		dividend <<= 1;
		remainder = (remainder << 1) | dividend_msb;
		quotient <<= 1;
		if (remainder >= divisor) {
			remainder -= divisor;
			quotient += 1;
		}
	} while (--i > 0);
	return quotient (r0);
}
*/

divide:
	push	r4
	mov	r3, 0		; remainder = 0;
	mov	r4, 0		; quocient = 0;
	mov	r2, 16		; uint16_t i = 16;
div_while:			; uint16 dividend_msb = dividend >> 15;
	lsl	r0, r0, 1	; dividend <<= 1;
	adc	r3, r3, r3	; remainder = (remainder << 1) | dividend_msb;
	lsl	r4, r4, 1	; quotient <<= 1;
	cmp	r3, r1		; if (remainder >= divisor) {
	blo	div_if_end
	sub	r3, r3, r1	; remainder -= divisor;
	add	r4, r4, 1	; quotient += 1;
div_if_end:
	sub	r2, r2, 1	; } while (--i > 0);
	bne	div_while
	mov	r0, r4		; return quotient;
	pop	r4
	mov	pc, lr

module:
	push	r4
	mov	r3, 0		; remainder = 0;
	mov	r4, 0		; quocient = 0;
	mov	r2, 16		; uint16_t i = 16;
mod_while:			; uint16 dividend_msb = dividend >> 15;
	lsl	r0, r0, 1	; dividend <<= 1;
	adc	r3, r3, r3	; remainder = (remainder << 1) | dividend_msb;
	lsl	r4, r4, 1	; quotient <<= 1;
	cmp	r3, r1		; if (remainder >= divisor) {
	blo	mod_if_end
	sub	r3, r3, r1	; remainder -= divisor;
	add	r4, r4, 1	; quotient += 1;
mod_if_end:
	sub	r2, r2, 1	; } while (--i > 0);
	bne	mod_while
	mov	r0, r3		; return remainder;
	pop	r4
	mov	pc, lr

#endif

