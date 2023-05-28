	.thumb              @ Assembles using thumb mode
	.cpu cortex-m3      @ Generates Cortex-M3 instructions
	.syntax unified

	.include "ivt.s"
	.include "gpio_map.inc"
	.include "rcc_map.inc"
	.include "nvic_reg_map.inc"
	
	.extern delay

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

	.section .text
 	.align  1
 	.syntax unified
 	.thumb
 	.global __main
__main:
		push 	{r7, lr}
		sub 	sp, sp, #16
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

		/* SystemClock Config */

		/* NVIC_EnableIRQ (6) */
		ldr 	r3, =NVIC_BASE
		mov		r2, #6
		lsr 	r2, r2, #5
		ldr 	r4, =0x1F
		ands	r2, r2, r4
		mov		r4, #1
		lsl		r4, r4, r2
		str 	r4, [r3, NVIC_ISER0_OFFSET]

		/* NVIC_EnableIRQ (6) */
		ldr 	r3, =NVIC_BASE
		mov		r2, #10
		lsr 	r2, r2, #5
		ldr 	r4, =0x1F
		ands	r2, r2, r4
		mov		r4, #1
		lsl		r4, r4, r2
		str 	r4, [r3, NVIC_ISER0_OFFSET]


		# Set counter with 0
		mov		r3, 0x0
		str		r3, [r7, #4]

		# Set counter status as increment
		mov		r3, 0x1
		str		r3, [r7, #8]
loop:
		@ Check if A0 is pressed, if it is then change status
		mov 	r0, 0x1
		bl		is_button_pressed
    	cmp 	r0, 0x1
    	bne 	.L6
		ldr 	r3, [r7, #8]
		eor		r3, r3, 0x1
		str 	r3, [r7, #8]

.L6:		
		@ Check if A4 is pressed, if it is then changes speed
		@ mov		r0, 0x10
		@ bl		is_button_pressed
    	@ cmp 	r0, 0x10
    	@ bne		.L7
		@ ldr		r0, [r7, #4]
		@ bl		dec_count
		@ str		r0, [r7, #4]

.L7:
		@ Check if counter status is 1 or 0
		ldr 	r3, [r7, #8]
		cmp 	r3, 0x1
		bne 	.L8
		ldr 	r0, [r7, #4]
		bl		inc_count
		str		r0, [r7, #4]
		b 		.L11
.L8:
		ldr 	r0, [r7, #4]
		bl		dec_count
		str		r0, [r7, #4]
.L11:
		mov		r0, #500
		bl		delay
		@ Turn LEDs on
    	ldr 	r3, =GPIOB_BASE
		ldr		r0, [r7, #4]
		mov 	r1, r0
		lsl 	r1, r1, #5
    	str 	r1, [r3, GPIOx_ODR_OFFSET]
		b 		loop
