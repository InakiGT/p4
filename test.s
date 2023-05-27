/* Configure the external interrupt for pin PA0. */

/* Habilitar el reloj del GPIOA */
LDR R0, =0x40023830
MOV R1, #0x00000001
STR R1, [R0]

/* Set the EXTI0 line to be edge-triggered and active low. */
LDR R0, =0x40013C00
MOV R1, #0x00000003
STR R1, [R0]

/* Configure the IVT to use EXTI0. */

/* Write the vector table entry for EXTI0. */
LDR R0, =0x2001C000
LDR R1, =EXTI0_IRQHandler
STR R1, [R0, #0x08]

/* Enable the EXTI0 interrupt in the NVIC. */
LDR R0, =0xE000E100
MOV R1, #0x00000001
STR R1, [R0]

/*
 * Set all the PB pins to be outputs.
 */

/* Habilitar el reloj del GPIOB */
LDR R0, =0x40023834
MOV R1, #0x00000001
STR R1, [R0]

/* Set the GPIOB pins as outputs. */
LDR R0, =0x48000400
MOV R1, #0x0000FFFF
STR R1, [R0]

/* Set all the PB pins to low. */
LDR R0, =0x48000414
MOV R1, #0x00000000
STR R1, [R0]

/*
 * The interrupt handler function.
 */
EXTI0_IRQHandler:

/* Clear the interrupt flag. */
LDR R0, =0x40013C0C
MOV R1, #0x00000001
STR R1, [R0]

/* Check if the interrupt was caused by a falling edge. */
LDR R0, =0x40013C08
LDR R1, [R0]
AND R1, R1, #0x00000001
CMP R1, #0x00000001

/* If the interrupt was caused by a falling edge, turn all the PB pins on. */
BEQ turn_on_all_pb

/* Turn only PB9 on. */
LDR R0, =0x48000414
LDR R1, =0x00000200
STR R1, [R0]

/* Return from the interrupt handler. */
BX LR

/* Turn all the PB pins on. */
turn_on_all_pb:
LDR R0, =0x48000414
LDR R1, =0x0000FFFF
STR R1, [R0]

/* Return from the interrupt handler. */
BX LR
