	.thumb              @ Assembles using thumb mode
	.cpu cortex-m3      @ Generates Cortex-M3 instructions
	.syntax unified

	.include "ivt.s"
	.include "gpio_map.inc"
	.include "rcc_map.inc"

	.section .text
 	.align  1
 	.syntax unified
 	.thumb
 	.global __main
delay:
        # Prologue
        push    {r7} @ backs r7 up
        sub     sp, sp, #28 @ reserves a 32-byte function frame
        add     r7, sp, #0 @ updates r7
        str     r0, [r7] @ backs ms up
        # Body function
        mov     r0, #255 @ ticks = 255, adjust to achieve 1 ms delay
        str     r0, [r7, #16]
# for (i = 0; i < ms; i++)
        mov     r0, #0 @ i = 0;
        str     r0, [r7, #8]
        b       F3
# for (j = 0; j < tick; j++)
F4:     mov     r0, #0 @ j = 0;
        str     r0, [r7, #12]
        b       F5
F6:     ldr     r0, [r7, #12] @ j++;
        add     r0, #1
        str     r0, [r7, #12]
F5:     ldr     r0, [r7, #12] @ j < ticks;
        ldr     r1, [r7, #16]
        cmp     r0, r1
        blt     F6
        ldr     r0, [r7, #8] @ i++;
        add     r0, #1
        str     r0, [r7, #8]
F3:     ldr     r0, [r7, #8] @ i < ms
        ldr     r1, [r7]
        cmp     r0, r1
        blt     F4
        # Epilogue
        adds    r7, r7, #28
        mov	    sp, r7
        pop	    {r7}
        bx	    lr

# This subrutine reads if buttons are pressed
read_button_input:
		push	{r7}
		sub 	sp, sp, #4
		add		r7, sp, #0
		str 	r0, [r7]

		ldr		r0, =GPIOA_BASE
		ldr 	r1, [r0, GPIOx_IDR_OFFSET]
		ldr 	r0, [r7]
		and		r1, r1, r0
		cmp		r1, r0
		beq		.L0
		mov		r0, #0
.L0:
		adds 	r7, r7, #4
		mov		sp, r7
		pop 	{r7}
		bx		lr


# This subrutine aprove if a combination of buttons are pressed
is_button_pressed:
		push 	{r7, lr}
		sub		sp, sp, #16
		add		r7, sp, #0
		str 	r0, [r7, #4]

		# read button input
		ldr		r0, [r7, #4]
		bl		read_button_input
		ldr 	r3, [r7, #4]
		cmp		r0, r3
		beq		L1
		mov		r0, #0
		adds	r7, r7, #16
		mov		sp, r7
		pop 	{r7}
		pop 	{lr}
		bx		lr

L1:
		# counter = 0
		mov		r3, #0
		str		r3, [r7, #8]

		# for (int i = 0, i < 10, i++) 
		mov     r3, #0 @ j = 0;
        str     r3, [r7, #12]
        b       L2
L5:     
		# wait 5 ms
		mov 	r0, #50
		bl   	delay
		# read button input
		ldr		r0, [r7, #4]
		bl		read_button_input
		ldr 	r3, [r7, #4]
		cmp		r0, r3
		beq 	L3
		mov 	r3, #0
		str		r3, [r7, #8]
L3:		
		# counter = counter + 1
		ldr 	r3, [r7, #8]
		add		r3, #1
		str 	r3, [r7, #8]

		ldr 	r3, [r7, #8]
		cmp		r3, #4
		blt		L4
		ldr		r0, [r7, #4]
		adds	r7, r7, #16
		mov		sp, r7
		pop 	{r7}
		pop 	{lr}
		bx		lr

L4:
		ldr     r3, [r7, #12] @ j++;
        add     r3, #1
        str     r3, [r7, #12]
L2:     
		ldr     r3, [r7, #12] @ j < 10;
        cmp     r3, #10
        blt     L5

		# return 0
		mov 	r0, #0
		adds	r7, r7, #16
		mov		sp, r7
		pop 	{r7}
		pop 	{lr}
		bx		lr


inc_count:
    	@ Increase counter
		push 	{r7, lr}
		sub 	sp, sp, #8
		add		r7, sp, #0
		str		r0, [r7, #4]
		ldr		r0, [r7, #4]
    	adds	r0, r0, #1
		str		r0, [r7, #4]
		ldr		r3, =0x3FF
    	cmp 	r0, r3
    	ble 	.L9   @ Jumps to "reset_count" if counter value is grather than 1023
		bl		reset_count
		str		r0, [r7, #4]
.L9:
		ldr		r0, [r7, #4]
		adds	r7, r7, #8
		mov		sp, r7
		pop 	{r7}
		pop		{lr}
		bx		lr


dec_count:
	   	@ Decrease counter
		push 	{r7, lr}
		sub 	sp, sp, #8
		add		r7, sp, #0
		str		r0, [r7, #4]
		ldr		r0, [r7, #4]
    	subs 	r0, r0, #1
		str		r0, [r7, #4]
    	cmp 	r0, #0
		bge		.L10
    	bl 		reset_count   @ Jumps to "reset_count" if counter value is less than 0
		str		r0, [r7, #4]
.L10:
		ldr		r0, [r7, #4]
		adds	r7, r7, #8
		mov		sp, r7
		pop 	{r7}
		pop		{lr}
		bx		lr


reset_count:
		@ Turn LEDs off
		push 	{r7, lr}
		sub 	sp, sp, #8
		add		r7, sp, #0
		ldr 	r3, =GPIOB_BASE
		mov 	r1, 0x0
		str 	r1, [r3, GPIOx_ODR_OFFSET]
		str		r1, [r7, #4]
		ldr		r3, [r7, #4]
		mov 	r0, r3
		adds	r7, r7, #8
		mov		sp, r7
		pop 	{r7}
		pop		{lr}
		bx		lr

__main:
		push 	{r7, lr}
		sub 	sp, sp, #8
		add		r7, sp, #0
		
        @ enabling clock in port A, B and C
        ldr     r2, =RCC_BASE
        mov     r3, 0x1C
        str     r3, [r2, RCC_APB2ENR_OFFSET]

		@ set pins PB5 - PB7 as digital output
        ldr     r2, =GPIOB_BASE
        ldr     r3, =0x33344444
        str     r3, [r2, GPIOx_CRL_OFFSET]

		@ set pins PB8 - PB15 as digital output
        ldr     r2, =GPIOB_BASE
        ldr     r3, =0x33333333
        str     r3, [r2, GPIOx_CRH_OFFSET]

        @ set pins PA0 and PA4 as digital input
        ldr     r2, =GPIOA_BASE
        ldr     r3, =0x44484448
        str     r3, [r2, GPIOx_CRL_OFFSET]

        # set led status initial value
		ldr     r3, =GPIOB_BASE
		mov		r4, 0x0
		str		r4, [r3, GPIOx_ODR_OFFSET]

		mov		r3, 0x0
		str		r3, [r7, #4]
loop:
		@ Check if both A0 and A4 are pressed at the same time
		mov 	r0, 0x11
		bl 		is_button_pressed
		cmp		r0, 0x11
		bne		.L6
		bl      reset_count
		str		r0, [r7, #4]

.L6:
    	@ Continue reading if any of them are pressed
		@ Check if A0 is pressed
		mov 	r0, 0x1
		bl		is_button_pressed
    	cmp 	r0, 0x1
    	bne 	.L7
		ldr		r0, [r7, #4]
		bl 		inc_count
		str		r0, [r7, #4]

.L7:		
		mov		r0, 0x10
		bl		is_button_pressed
    	cmp 	r0, 0x10
    	bne		.L8
		ldr		r0, [r7, #4]
		bl		dec_count
		str		r0, [r7, #4]

.L8:
		@ Turn LEDs on
    	ldr 	r3, =GPIOB_BASE
		ldr		r0, [r7, #4]
		mov 	r1, r0
		lsl 	r1, r1, #5
    	str 	r1, [r3, GPIOx_ODR_OFFSET]
		b 		loop
