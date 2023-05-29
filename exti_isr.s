.include "exti_map.inc"

.cpu cortex-m3      @ Generates Cortex-M3 instructions
.section .text
.align	1
.syntax unified
.thumb
.global EXTI0_Handler
EXTI0_Handler:
    adds    r8, r8, #1
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    orr     r1, r1, 0x40
    str     r1, [r0, EXTI_PR_OFFSET]
    bx      lr

.global EXTI4_Handler
EXTI4_Handler:
    mov     r3, #1
    eor     r9, r9, r3
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    orr     r1, r1, 0x400
    str     r1, [r0, EXTI_PR_OFFSET]
    bx      lr