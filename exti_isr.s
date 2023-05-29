.include "exti_map.inc"

.extern delay

.cpu cortex-m3      @ Generates Cortex-M3 instructions
.section .text
.align	1
.syntax unified
.thumb
.global EXTI0_Handler
EXTI0_Handler:
    push {lr}
    mov     r0, #500
    bl      delay
    adds    r8, r8, #1
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    orr     r1, r1, 0x40
    str     r1, [r0, EXTI_PR_OFFSET]
    pop     {lr}
    bx      lr

.global EXTI4_Handler
EXTI4_Handler:
    push    {lr}
    mov     r0, #500
    bl      delay
    cmp     r9, #1
    beq     .L0
    mov     r9, #1
    b       .L1
.L0:
    mov     r9, #0
.L1:
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    orr     r1, r1, 0x400
    str     r1, [r0, EXTI_PR_OFFSET]
    pop     {lr}
    bx      lr
