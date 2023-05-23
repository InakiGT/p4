; Definir los registros
.equ NVIC_ISER0, 0xE000E100  ; Registro de habilitación de interrupciones
.equ GPIOA_BASE, 0x40010800  ; Dirección base del periférico GPIOA
.equ GPIOA_IDR, GPIOA_BASE + 0x08  ; Registro de datos de entrada

.section .text
.global reset_handler
.type reset_handler, %function

reset_handler:
  
  ; Configurar y habilitar la interrupción
  ldr r0, =NVIC_ISER0
  ldr r1, [r0]
  orr r1, r1, #(1 << 17)  ; Habilitar la interrupción EXTI0
  str r1, [r0]
  
  ; Configurar el pin A0 para generar una interrupción EXTI0
  ldr r0, =AFIO_EXTICR1  ; Registro de configuración de EXTI0
  ldr r1, [r0]          ; Leer el valor actual
  and r1, r1, #(0xFFF0) ; Limpiar los bits 0 a 3 para configurar el pin A0
  orr r1, r1, #(0x0 << 0) ; Configurar el pin A0
  str r1, [r0]          ; Escribir el valor actualizado
  
  ; Configurar el registro EXTI0 para detectar flancos de subida
  ldr r0, =EXTI_RTSR
  ldr r1, [r0]
  orr r1, r1, #(1 << 0) ; Habilitar la detección de flanco de subida para EXTI0
  str r1, [r0]
  
  ; Saltar a la rutina principal
  ldr r0, =main
  bx r0

; Rutina de interrupción EXTI0
.section .text
.global EXTI0_IRQHandler
.type EXTI0_IRQHandler, %function

EXTI0_IRQHandler:
  ; Guardar los registros necesarios
  push {lr}
  
  ; Leer el estado del pin A0
  ldr r0, =GPIOA_IDR
  ldr r1, [r0]
  and r1, r1, #(1 << 0)  ; Máscara para leer solo el bit 0
  
  ; Hacer algo en función del estado del pin A0
  cmp r1
