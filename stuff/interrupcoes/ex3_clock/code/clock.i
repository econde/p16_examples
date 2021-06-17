# 1 "clock.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 31 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 32 "<command-line>" 2
# 1 "clock.c"




.section .startup
 b _start
 ldr pc, addr_isr
_start:
 ldr sp, addr_stack_top
 ldr r0, addr_main
 mov r1, pc
 add lr, r1, 4
 mov pc, r0
 b .
addr_stack_top:
 .word stack_top
addr_main:
 .word main
addr_isr:
 .word isr

 .data

 .text

 .section .stack
 .equ STACK_SIZE, 1024
 .space STACK_SIZE
stack_top:
# 96 "clock.c"
 .data
hour:
 .byte 0
minute:
 .byte 0
second:
 .byte 0
hit:
 .byte 0

 .equ BUTTON_UP_MASK, 1
 .equ BUTTON_DOWN_MASK, 2
 .equ BUTTON_HOUR_MIN_MASK, 4

 .equ IFLAG_MASK, 0x10
 .equ SDP16_PORT_ADDRESS 0xff00
 .equ SDP16_CS_EX0_ADDRESS 0xff40

 .text
main:
 bl irequest_clear
 mov r1, IFLAG_MASK
 mrs r0, cpsr
 orr r0, r0, r1
 msr cpsr, r0
while:
 bl button_read
if_up:
 mov r1, BUTTON_UP_MASK
 and r1, r1, r0
 bne if_down
 ldr r0, addr_hit
 ldrb r0, [r0]
 add r0, r0, 0
 bne if_up_else
 bl hour_inc
 b while
if_up_else:
 bl minute_inc
 b while

if_down:
 mov r1, BUTTON_DOWN_MASK
 and r1, r1, r0
 bne if_hour_min
 ldr r0, addr_hit
 ldrb r0, [r0]
 add r0, r0, 0
 bne if_down_else
 bl hour_dec
 b while
if_down_else:
 bl minute_dec
 b while

if_hour_min:
 ldr r1, addr_hit
 ldrb r0, [r1]
 not r0, r0
 strb r0, [r1]
 b while

addr_hit:
 .word hit
# 175 "clock.c"
 .text
isr:
 push r0
 push r1
 push r2
 push r3
 push lr
 bl display_refresh
 bl clock_tic
 bl irequest_clear
 pop lr
 pop r3
 pop r2
 pop r1
 pop r0
 movs pc, lr
# 219 "clock.c"
 .data
 .align
clock_scale:
 .word 0
 .equ CLOCK_SCALE_MAX, 1000

 .text
clock_tic:
 push lr
 ldr r1, addr_clock_scale ; if (--clock_scale == 0) {
 ldr r0, [r1]
 sub r0, r0, 1
 str r0, [r1]
 bzc tic_if1_end
 mov r0, CLOCK_SCALE_MAX & 0xff ; clock_scale = CLOCK_SCALE;
 movt r0, CLOCK_SCALE_MAX >> 8
 str r0, [r1]
 ldr r1, addr_second ; if (++second == 60) {
 ldrb r0, [r1]
 add r0, r0, 1
 str r0, [r1]
 mov r2, 60
 sub r0, r0, r2
 bne tic_if2_end
 strb r0, [r1] ; second = 0;
 ldr r1, addr_minute ; if (++minute == 60) {
 ldrb r0, [r1]
 add r0, r0, 1
 strb r0, [r1]
 mov r2, 60
 sub r0, r0, r2
 bne tic_if3_end
 strb r0, [r1] ; minute = 0;
 ldr r1, addr_hour ; if (++hour == 24)
 ldrb r0, [r1]
 add r0, r0, 1
 strb r0, [r1]
 mov r2, 24
 sub r0, r0, r2
 bne tic_if4_end
 strb r0, [r1] ; hour = 0;
tic_if3_end:
tic_if4_end:
 ldr r0, addr_hour ; display_write(hour, minute);
 ldrb r0, [r0]
 ldr r1, addr_minute
 ldrb r1, [r1]
 bl display_write
tic_if1_end:
tic_if2_end:
 pop lr

addr_clock_scale:
 .word clock_scale

addr_second:
 .word second

hour_inc:
 ldr r1, addr_hour
 ldrb r0, [r1]
 add r0, r0, 1
 strb r0, [r1]
 mov r2, 24
 sub r0, r0, r2
 bne hour_inc_exit
 strb r0, [r1]
hour_inc_exit:
 mov pc, lr

hour_dec:
 ldr r1, addr_hour
 ldrb r0, [r1]
 add r0, r0, 0
 bne hour_dec_exit
 mov r0, 24
hour_dec_exit:
 sub r0, r0, 1
 strb r0, [r1]
 mov pc, lr

minute_inc:
 ldr r1, addr_minute
 ldrb r0, [r1]
 add r0, r0, 1
 strb r0, [r1]
 mov r2, 60
 sub r0, r0, r2
 bne minute_inc_exit
 strb r0, [r1]
minute_inc_exit:
 mov pc, lr

minute_dec:
 ldr r1, addr_minute
 ldrb r0, [r1]
 add r0, r0, 0
 bne minute_dec_exit
 mov r0, 60
minute_dec_exit:
 sub r0, r0, 1
 strb r0, [r1]
 mov pc, lr

addr_minute:
 .word minute
addr_hour:
 .word hour
# 362 "clock.c"
 .equ DISPLAY_MASK, 0x7f
 .equ NDIGIT, 4

 .data
display_image:
 .space NDIGIT
display_current:
 .byte 0

 .text
display_refresh:
 push lr
 push r4
 push r5
 ldr r4, addr_display_current
 ldrb r0, [r4] ; display_current
 ldr r1, addr_display_comm
 ldrb r5, [r1, r0] ; uint8_t comm_mask
 mov r0, 0 = display_comm[display_current];
 mov r1, r5
 bl port_ex0_write
 ldr r1, addr_display_image
 ldrb r0, [r4] ; display_current
 ldrb r0, [r1, r0] ; port_write(diplay_image[display_current],
 mov r1, DISPLAY_MASK ; DISPLAY_MASK);
 bl port_write ;
 mov r0, r5 ; port_ex0_write(comm_mask, comm_mask);
 mov r1, r5
 bl port_ex0_write
 ldrb r0, [r4] ; if (++display_current == NDIGIT) {
 add r0, r0, 1
 strb r0, [r4]
 mov r1, NDIGIT
 sub r0, r0, r1
 bzc display_refresh_if_end
 str r0, [r4] ; display_current = 0;
display_refresh_if_end:
 pop r5
 pop r4
 pop pc

addr_display_current:
 .word display_current

display_comm:
 .byte 1, 2, 4, 8

addr_display_comm:
 .word display_comm

 .text
display_write:
 push lr
 push r4
 push r5
 push r6
 push r7
 ldr r6, addr_bin7seg
 ldr r7, addr_display_image
 mov r4, r0
 mov r5, r1
 mov r1, 10
 bl module
 ldrb r0, [r6, r0]
 strb r0, [r7, 2 + 4]

 mov r0, r4
 mov r1, 10
 bl divide
 ldrb r0, [r6, r0]
 strb r0, [r7, 3 + 4]

 mov r0, r5
 mov r1, 10
 bl module
 ldrb r0, [r6, r0]
 strb r0, [r7, 0 + 4]

 mov r0, r5
 mov r1, 10
 bl divide
 ldrb r0, [r6, r0]
 strb r0, [r7, 1 + 4]
 pop r7
 pop r6
 pop r5
 pop r4
 pop pc

bin7seg:
 .byte 0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f

addr_bin7seg:
 .word bin7seg

addr_display_image:
 .word display_image

divide:
 mov pc, lr

module:
 mov pc, lr
# 485 "clock.c"
 .data
button_prev:
 .byte 0

 .text
button_read:
 ldr r1, addr_port
 ldrb r2, [r1]
 ldr r0, addr_button_prev
 ldrb r1, [r0]
 strb r2, [r0]
 not r1, r1
 and r0, r1, r2
 mov pc, lr

addr_button_prev:
 .word button_prev
# 519 "clock.c"
 .equ CLEAR_MASK, 0x20

irequest_clear:
 push sp
 mov r0, 0 ; port_ex0_write(0, CLEAR_MASK);
 mov r1, CLEAR_MASK
 bl port_ex0_write
 mov r0, CLEAR_MASK ; port_ex0_write(CLEAR_MASK, CLEAR_MASK);
 mov r1, CLEAR_MASK
 bl port_ex0_write
 pop pc







 .data
port_image:
 .byte 0

port_ex0_image:
 .byte 0

 .text
port_write:
 and r0, r0, r1
 ldr r2, addr_port_image
 ldrb r3, [r2]
 not r1, r1
 and r3, r3, r1
 or r0, r0, r3
 strb r0, [r2]
 mov r1, SDP16_PORT_ADDRESS & 0xff
 movt r1, SDP16_PORT_ADDRESS >> 8
 strb r0, [r1]
 mov pc, lr

port_ex0_write:
 and r0, r0, r1
 ldr r2, addr_port_ex0_image
 ldrb r3, [r2]
 not r1, r1
 and r3, r3, r1
 or r0, r0, r3
 strb r0, [r2]
 mov r1, SDP16_CS_EX0_ADDRESS & 0xff
 movt r1, SDP16_CS_EX0_ADDRESS >> 8
 strb r0, [r1]
 mov pc, lr

addr_port_image:
 .word port_image

addr_port_ex0_image:
 .word port_ex0_image
