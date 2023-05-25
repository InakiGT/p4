	.thumb              @ Assembles using thumb mode
	.cpu cortex-m3      @ Generates Cortex-M3 instructions
	.syntax unified

	.include "ivt.s"
	.include "gpio_map.inc"
	.include "rcc_map.inc"
	.include "systick_map.inc"
	.include "nvic_reg_map.inc"
	.include "afio_map.inc"
	.include "exti_map.inc"
	
	.extern delay

	.equ SYSCFG_BASE, 0x40013800

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

		mov     r0, #1000
		ldr 	r3, =SYSTICK_BASE
        str     r0, [r3, STK_LOAD_OFFSET]

        @ Habilitar interrupción de SysTick y configurar el temporizador en modo de cuenta
        mov     r0, #7
        ldr     r1, =SYSTICK_BASE
        str     r0, [r1, STK_CTRL_OFFSET]

		@ enabling clock in port A, B and C
        ldr     r2, =RCC_BASE
        mov     r3, 0x401C
        str     r3, [r2, RCC_APB2ENR_OFFSET]

		@ Habilitar el reloj para SYSCFG
		ldr r0, =RCC_BASE
		ldr r1, [r0]
		orr r1, r1, #(1 << 14)  // Habilitar el reloj para SYSCFG
		str r1, [r0]

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


		@ Configurar el pin A0 para generar una interrupción EXTI0
		ldr r0, =AFIO_BASE  @ Registro de configuración de EXTI0
		ldr r1, [r0, AFIO_EXTICR1_OFFSET]   
		mov	r3, 0x000F       @ Leer el valor actual
		and r1, r1, r3 @ Limpiar los bits 0 a 3 para configurar el pin A0
		orr r1, r1, #(0x0 << 0) @ Configurar el pin A0
		str r1, [r0, AFIO_EXTICR1_OFFSET]          @ Escribir el valor actualizado

		@ Configurar la interrupción externa EXTI0
		ldr r0, =SYSCFG_BASE
		ldr r1, [r0, #0x00]
		orr r1, r1, #(1 << 0) // Habilitar la conexión de EXTI0 al pin A0
		str r1, [r0, #0x00]


		ldr r0, =EXTI_BASE
		ldr r1, [r0, EXTI_RTST_OFFSET]
		orr r1, r1, #(1 << 0) @ Habilitar la detección de flanco de subida para EXTI0
		str r1, [r0, EXTI_RTST_OFFSET]

		ldr r0, =EXTI_BASE
		ldr r1, [r0, EXTI_FTST_OFFSET]
		orr r1, r1, #(~(1 << 0)) @ Deshabilitar la detección de flanco de subida para EXTI0
		str r1, [r0, EXTI_FTST_OFFSET]

		ldr r0, =EXTI_BASE      @ Registro de máscara de interrupción de eventos
    	ldr r1, [r0, EXTI_IMR_OFFSET]          @ Cargar el valor actual del registro
    	orr r1, r1, #(1 << 0)   @ Habilitar la interrupción EXTI0
    	str r1, [r0, EXTI_IMR_OFFSET]

		ldr r0, =NVIC_BASE
		mov r1, #1
		strb r1, [r0, #0x14]
				
		@ Configurar y habilitar la interrupción
		ldr r0, =NVIC_BASE
		ldr r1, [r0, NVIC_ISER0_OFFSET]
		orr r1, r1, #(1 << 6)  @ Habilitar la interrupción EXTI0
		str r1, [r0, NVIC_ISER0_OFFSET]

		@ Configurar la rutina de interrupción EXTI0_IRQHandler
		ldr r0, =EXTI0_IRQHandler
		ldr r1, =0xE000E014          @ Dirección de inicio de la tabla de vectores de interrupción
		ldr r2, =0x6           @ Número de la interrupción EXTI0
		lsl r2, r2, #2               @ Calcular el offset de la entrada de la tabla de vectores
		add r1, r1, r2               @ Calcular la dirección de la entrada en la tabla de vectores
		str r0, [r1]                 @ Guardar la dirección de la rutina de interrupción EXTI0_IRQHandler en la tabla de vectores

		@ Habilitar las interrupciones
		cpsie i   

		# Set counter with 0
		mov		r3, 0x0
		str		r3, [r7, #4]

		# Set counter status as increment
		mov		r3, 0x1
		str		r3, [r7, #8]
loop:
		@ Check if A0 is pressed, if it is then change status
		@ mov 	r0, 0x1
		@ bl		is_button_pressed
    	@ cmp 	r0, 0x1
    	@ bne 	.L6
		@ ldr 	r3, [r7, #8]
		@ eor		r3, r3, 0x1
		@ str 	r3, [r7, #8]

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

.section .text
.global EXTI0_IRQHandler
.type EXTI0_IRQHandler, %function
EXTI0_IRQHandler:
	@ Turn LEDs on
    ldr 	r3, =GPIOB_BASE
	mov 	r1, 0xFFF
	lsl 	r1, r1, #5
    str 	r1, [r3, GPIOx_ODR_OFFSET]

    @ Realizar acciones cuando el pin A0 está en estado lógico alto
    ldr r0, =0x40010814 // Dirección del registro EXTI_PR
    mov r1, #(1 << 0) // Bit 0 corresponde a EXTI0
    str r1, [r0]
    bx lr