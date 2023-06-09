

# Configuración de EXTI
En este proyecto realizamos la configuración de interrupciones externas invocadas por Hardware, haciendo uso del vector de interrupciones del Micro Controlador CortexM3.
Este proyecto está construido en ensamblador ARMv7, sintaxis GAS

## Configuración del reloj del sisetma e interrupciones externas
Para realizar cualquier configuración debemos de estar seguro de importar el archivo de mapeado que vamos a utilizar en la configuración
### Reloj del sistema
Para realizar la configuración del reloj de sistema tenemos una función que se encarga de esto
Como para este proyecto estamos trabajando con un cristal de 8Mhz debemos asignar un valor de 7999 al STK_LOAD para poder trabajar con 1ms

    ldr r2, =7999 @ No es 262
    str r2, [r0, #STK_LOAD_OFFSET] 

### AFIO
Para configurar AFIO debemos de mandar el valor correspondiente al puerto que vamos a utilizar al ICR correspondiente, es este caso estamos utilizando el puerto A por ende debemos mandar el valor de 0 y como estamos usando los EXTI5 y 6 debemos usar el ICR2
    		
    ldr 	r0, =AFIO_BASE
	eor		r1, r1
	str 	r1, [r0, AFIO_EXTICR2_OFFSET]
    
### EXTI
Para configurar las interrupciones externas en este proyecto lo que debemos hacer es desactivar el flanco de bajada en la lectura de la interrupción externa, eso lo hacemos mandando un valor 0 a EXTI_FTST_OFFSET que es el encargado de asignar el flanco de bajada

    ldr 	r0, =EXTI_BASE
	eor		r1, r1
	str 	r1, [r0, EXTI_FTST_OFFSET]

También es necesario hacer la activación del flanco de súbida en el valor correspondiente a los pines que vamos a utilizar, en este caso utilizaremos el pin PA5 y el pin PA6

    ldr 	r0, =EXTI_BASE
	ldr 	r1, =(0x3<<5)
	str		r1, [r0, EXTI_RTST_OFFSET]

Así mismo vamos a asignar este mismo valor a IMR que es el que se encarga de habilitar las EXTI correspondientes a los pines que estamos especificando

    ldr 	r0, =EXTI_BASE
	ldr 	r1, =(0x3<<5)
	str		r1, [r0, EXTI_IMR_OFFSET]

### NVIC
Para realizar la configuración de NVIC debemos de mandar el valor correspondiente a la exti que vamos a utilizar, en esta caso vamos a utilizar, en este caso en especifico utilizamos la EXTI5_9, por ende le debemos mandar el valor de 0x1<<23. Podemos encontrar más información al respecto en el manual del MC

    ldr 	r0, =NVIC_BASE
	ldr 	r1, =(0x1<<23)
	str		r1, [r0, NVIC_ISER0_OFFSET]

## Compilación del proyecto
Al utilizar un Make file podemos realizar el proceso de compilación con un simple comando

    make

Este comando se encarga de hacer la generación del archivo con extensión .bin, el nombre de este archivo lo definimos en la instrucción all del Makefile.
Debemos asegurarnos de que todos los archivos con extensión .s que forman parte del proyecto sean incluidos en la instrucción encargada de la inclusión de fuentes para la compilación

    SRCS = main.s ivt.s default_handler.s reset_handler.s delay.s systick_isr.s exti_isr.s
    
## Grabación
Para realizar la grabación del binario en el microcontrolador debemos ejecutar el comando:

    st-flash write prog.bin 0x8000000

Donde 'prog.bin' es el nombre del binario generado


## Diagrama de Hardware

![img](https://i.ibb.co/10pxHmH/P4-Ejemplo-de-diagrama-esquem-tico-3.png[/img][/url])
