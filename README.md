# Candy Crush en CUDA

Este repositorio contiene la implementación del juego **Candy Crush** utilizando el lenguaje de programación CUDA. El juego se ha desarrollado para aprovechar el poder del procesamiento paralelo mediante el uso de hilos CUDA. El repositorio se divide en tres partes principales:

## Parte 1: Implementación Básica del Juego
En esta primera parte del repositorio, encontrarás la implementación del juego de Candy Crush en CUDA. Se ha creado una versión funcional del juego en la que los elementos se pueden intercambiar y eliminar cuando se forma un grupo de tres o más elementos del mismo tipo en una fila o columna.

### Funcionalidades Destacadas:
- Generación de tablero de juego aleatorio.
- Detección y eliminación de grupos de elementos.
- Lógica de juego para intercambiar elementos.

## Parte 2: Optimización con Múltiples Bloques
En la segunda parte del repositorio, hemos llevado a cabo una optimización del juego utilizando múltiples bloques en función de la tarjeta gráfica utilizada. Esta optimización permite una distribución eficiente de la carga de trabajo en la GPU y mejora el rendimiento general del juego.

### Características de la Optimización:
- Distribución de trabajo en múltiples bloques.
- Aprovechamiento de la capacidad de procesamiento paralelo de la GPU.
- Mejora en la velocidad de ejecución.

## Parte 3: Optimización con Memoria Compartida
En la tercera parte del repositorio, hemos llevado la optimización un paso más allá utilizando memoria compartida. La memoria compartida es más rápida que la memoria global de la GPU y se utiliza para almacenar datos que se comparten entre hilos en un bloque, lo que reduce la latencia y mejora aún más el rendimiento.

### Características de la Optimización con Memoria Compartida:
- Uso de memoria compartida para acelerar operaciones críticas.
- Minimización de accesos a la memoria global.
- Mayor velocidad y eficiencia en la ejecución del juego.

## Contribuciones
¡Estamos abiertos a contribuciones de la comunidad! Si tienes ideas para mejorar el rendimiento, agregar nuevas características o corregir errores, no dudes en enviar solicitudes de extracción.

## Requisitos
Para ejecutar el juego de Candy Crush en CUDA, necesitarás una tarjeta gráfica compatible con CUDA y el entorno de desarrollo CUDA configurado en tu sistema.

## Instrucciones de Ejecución
Proporcionaremos instrucciones detalladas sobre cómo compilar y ejecutar el juego en CUDA en la sección correspondiente de cada parte del repositorio.

¡Diviértete jugando Candy Crush en CUDA y explorando las optimizaciones para una experiencia de juego más suave y rápida!

**Nota**: Este es un proyecto en desarrollo y puede haber cambios y actualizaciones en el repositorio a medida que avanzamos en el desarrollo y la optimización del juego. Te animamos a mantenerse actualizado con las últimas mejoras y contribuir al proyecto si lo deseas.
