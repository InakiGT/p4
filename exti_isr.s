.include "exti_map.inc"
.include "gpio_map.inc"

.extern delay

.cpu cortex-m3      @ Generates Cortex-M3 instructions
.section .text
.align	1
.syntax unified
.thumb
.global EXTI_Handler
EXTI_Handler:
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    ldr     r0, =0x20
    cmp     r1, r0
    beq     EXTI5_Handler
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    ldr     r0, =0x40
    cmp     r1, r0
    beq     EXTI6_Handler
.L0:
    bx      lr

EXTI5_Handler:
    adds    r8, r8, #1
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    orr     r1, r1, 0x20
    str     r1, [r0, EXTI_PR_OFFSET]
    bx      lr

EXTI6_Handler:
    eor     r5, r5, #1
    and     r5, r5, #1
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    orr     r1, r1, 0x40
    str     r1, [r0, EXTI_PR_OFFSET]
    bx      lr
