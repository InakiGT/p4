.cpu cortex-m3      @ Generates Cortex-M3 instructions
.extern __main
.section .text
.align	1
.syntax unified
.thumb
.global SysTick_Handler

SysTick_Handler:
    mov     r0, #500
    bl      delay

    bx      lr
.size   SysTick_Handler, .-SysTick_Handler