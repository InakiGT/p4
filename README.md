

# Configuración de GPIO
## Compilación del proyecto
Al utilizar un Make file podemos realizar el proceso de compilación con un simple comando

    make
Este comando se encarga de hacer la generación del archivo con extensión .bin, el nombre de este archivo lo definimos en la instrucción all del Makefile

### Grabación
Para realizar la grabación del binario en el microcontrolador debemos ejecutar el comando:

    st-flash write prog.bin 0x8000000

Donde 'prog.bin' es el nombre del binario generado

## Diagrama de Hardware

# Configuración de GPIO
## Compilación del proyecto
Al utilizar un Make file podemos realizar el proceso de compilación con un simple comando

    make
Este comando se encarga de hacer la generación del archivo con extensión .bin, el nombre de este archivo lo definimos en la instrucción all del Makefile

### Grabación
Para realizar la grabación del binario en el microcontrolador debemos ejecutar el comando:

    st-flash write prog.bin 0x8000000

Donde 'prog.bin' es el nombre del binario generado

## Diagrama de Hardware

![img](https://i.ibb.co/K7K4p12/Diagrama-en-blanco.png)

## Marco de las funciones
![img](https://i.ibb.co/yP2dnFb/Captura-de-pantalla-2023-05-17-a-la-s-14-23-09.png)