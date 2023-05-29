	.section .text
 	.align  1
 	.syntax unified
 	.thumb
 	.global delay
delay:
        mov r10, r0
loop:
        cmp r10, #0 
        bne loop
        bx lr

.size   delay, .-delay
