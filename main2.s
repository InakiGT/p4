.include "gpio_map.inc"

.thumb
.syntax unified
.cpu cortex-m3

.global EXTI_Init

.include "ivt.s"
.include "gpio_map.inc"
.include "rcc_map.inc"
.include "systick_map.inc"
.include "nvic_reg_map.inc"
.include "afio_map.inc"
.include "exti_map.inc"

.equ RCC_APB2ENR_SYSCFGEN, 0x00004000
.equ SYSCFG_EXTICR1_EXTI3_PA, 0x00000000
.equ EXTI_RTSR_RT3, 0x00000008
.equ EXTI_FTSR_RT3, 0x00000008
.equ EXTI_IMR1_IM3, 0x00000008
.equ SYSCFG_EXTICR1_EXTI3, 0x00000002

.extern RCC
.extern SYSCFG
.extern EXTI
.extern NVIC

EXTI_Init:
    @ Enable SYSCFG clock
    ldr r0, =RCC_BASE
    ldr r1, [r0, #0x18]
    orr r1, r1, #RCC_APB2ENR_SYSCFGEN
    str r1, [r0, #0x18]

    @ Select PA.3 as the trigger source of EXTI 3
    ldr r0, =AFIO_BASE
    ldr r1, [r0, #0x08]
    bic r1, r1, #SYSCFG_EXTICR1_EXTI3
    orr r1, r1, #SYSCFG_EXTICR1_EXTI3_PA
    str r1, [r0, #0x08]
    bic r1, r1, #0x000F
    str r1, [r0, #0x08]

    @ Enable rising edge trigger for EXTI 3
    ldr r0, =EXTI_BASE
    ldr r1, [r0, #0x00]
    orr r1, r1, #EXTI_RTSR_RT3
    str r1, [r0, #0x00]

    @ Disable falling edge trigger for EXTI 3
    ldr r1, [r0, #0x04]
    bic r1, r1, #EXTI_FTSR_RT3
    str r1, [r0, #0x04]

    @ Enable EXTI 3 interrupt
    ldr r1, [r0, #0x08]
    orr r1, r1, #EXTI_IMR1_IM3
    str r1, [r0, #0x08]

    @ Set EXTI 3 priority to 1
    ldr r0, =NVIC_BASE
    mov r1, #1
    str r1, [r0, #0x100]

    @ Enable EXTI 3 interrupt
    str r1, [r0, #0x104]

    bx lr

.global EXTI3_IRQHandler
EXTI3_IRQHandler:
    @ Check for EXTI 3 interrupt flag
@     ldr r0, =EXTI_BASE  @ Dirección base del registro EXTI
@     ldr r1, [r0, EXTI_PR_OFFSET]  @ Leer el registro EXTI_PR1
@     ldr r2, =0x00000008  @ Máscara para la bandera de interrupción EXTI 3
@     tst r1, r2           @ Comprobar la bandera de interrupción EXTI 3
@     bne toggle_led       @ Saltar a toggle_led si la bandera está activa

@     @ Clear interrupt pending request
@     str r2, [r0, #0x14]  @ Escribir 1 para borrar la bandera EXTI 3
@     bx lr                @ Salir de la ISR

@ toggle_led:
@     @ Toggle LED
    ldr 	r3, =GPIOB_BASE
    ldr		r0, [r7, #4]
    mov 	r1, 0xFFF
    lsl 	r1, r1, #5
    str 	r1, [r3, GPIOx_ODR_OFFSET]
    bx      lr  @ Volver a comprobar la bandera EXTI 3

.section .text
.align  1
.syntax unified
.thumb
.global __main
__main:
    ldr     r2, =GPIOB_BASE
    ldr     r3, =0x33344444
    str     r3, [r2, GPIOx_CRL_OFFSET]

    @ set pins PB8 - PB15 as digital output
    ldr     r2, =GPIOB_BASE
    ldr     r3, =0x33333333
    str     r3, [r2, GPIOx_CRH_OFFSET]

    @ set pins PA0 and PA4, PA3 as digital input
    ldr     r2, =GPIOA_BASE
    ldr     r3, =0x44488448
    str     r3, [r2, GPIOx_CRL_OFFSET]

        # set led status initial value
    ldr     r3, =GPIOB_BASE
    mov		r4, 0x0
    str		r4, [r3, GPIOx_ODR_OFFSET]

    cpsie   i

    bl  EXTI_Init
loop:
    b loop
