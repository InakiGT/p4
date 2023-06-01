

# Configuración de EXTI
En este proyecto realizamos la configuración de interrupciones externas invocadas por Hardware, haciendo uso del vector de interrupciones del Micro Controlador CortexM3.
Este proyecto está construido en ensamblador ARMv7, sintaxis GAS

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

![img](https://i.ibb.co/2MvHhdV/P4-Ejemplo-de-diagrama-esquem-tico.png[/img][/url])
