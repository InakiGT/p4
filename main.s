	.thumb              @ Assembles using thumb mode
	.cpu cortex-m3      @ Generates Cortex-M3 instructions
	.syntax unified

	.include "gpio_map.inc"
	.include "rcc_map.inc"
	.include "systick_map.inc"
	.include "nvic_reg_map.inc"
	.include "afio_map.inc"
	.include "exti_map.inc"
	
	.extern delay
	.extern SysTick_Initialize

check_speed:
		push 	{r7}
		sub 	sp, sp, #4
		add		r7, sp, #0

		cmp		r8, #1
		bne		.CH1
		mov		r0, #1000
		adds	r7, r7, #4
		mov		sp, r7
		pop		{r7}
		bx 		lr
.CH1:	
		cmp		r8, #2
		bne		.CH2
		mov		r0, #500
		adds	r7, r7, #4
		mov		sp, r7
		pop		{r7}
		bx 		lr
.CH2:	
		cmp		r8, #3
		bne		.CH3
		mov		r0, #250
		adds	r7, r7, #4
		mov		sp, r7
		pop		{r7}
		bx 		lr
.CH3:	
		cmp		r8, #4
		bne		.CH4
		mov		r0, #125
		adds	r7, r7, #4
		mov		sp, r7
		pop		{r7}
		bx 		lr
.CH4:	
		mov		r8, #1
		mov		r0, #1000

		adds	r7, r7, #4
		mov		sp, r7
		pop		{r7}
		bx 		lr


	.section .text
 	.align  1
 	.syntax unified
 	.thumb
 	.global __main
__main:
		push 	{r7, lr}
		sub 	sp, sp, #16
		add		r7, sp, #0

		bl 		SysTick_Initialize

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
        ldr     r3, =0x48884448
        str     r3, [r2, GPIOx_CRL_OFFSET]

		ldr 	r0, =AFIO_BASE
		eor		r1, r1
		str 	r1, [r0, AFIO_EXTICR2_OFFSET]

		ldr 	r0, =EXTI_BASE
		eor		r1, r1
		str 	r1, [r0, EXTI_FTST_OFFSET]
		ldr 	r1, =(0x3<<5)
		str		r1, [r0, EXTI_RTST_OFFSET]
		str 	r1, [r0, EXTI_IMR_OFFSET]

		ldr 	r0, =NVIC_BASE
		ldr 	r1, =(0x1<<23)
		str		r1, [r0, NVIC_ISER0_OFFSET]

        # set led status initial value
		ldr     r3, =GPIOB_BASE
		mov		r4, 0x0
		str		r4, [r3, GPIOx_ODR_OFFSET]

		@ Set counter with 0
		mov		r3, 0x0
		str		r3, [r7, #4]

		@ Set delay with 1000
		mov		r3, #1000
		str 	r3, [r7, #8]

		@ Set counter initial status as increment
		mov		r5, #1
		mov		r8, #1
		
loop:
		@ Check if counter status is 1 or not
		bl		check_speed
		str 	r0, [r7, #8]

		cmp 	r5, #1
		bne 	.L0
		ldr 	r0, [r7, #4]
		add		r0, r0, #1
		str		r0, [r7, #4]
		b 		.L1
.L0:
		ldr 	r0, [r7, #4]
		sub		r0, r0, #1
		str		r0, [r7, #4]
.L1:
    	ldr 	r3, =GPIOB_BASE
		ldr		r0, [r7, #4]
		mov 	r1, r0
		lsl 	r1, r1, #5
    	str 	r1, [r3, GPIOx_ODR_OFFSET]
		ldr		r0, [r7, #8]
		bl		delay
		b 		loop