# Tarea extra CUDA

**Estudiante**: Oscar Méndez Granados
**Carné**: 2019150432

## Compilación y ejecución

### Archivo: naive.cpp

Compilación: ` g++ -o dot_product_1 -O0 naive.cpp`

Ejecución: `./dot_product_1`

### Archivo intrinsics.cpp

Compilación: `g++ -o dot_product_2 -O0 -mavx2 -std=c++11 intrinsics.cpp`

Ejecución: `./dot_product_2`

### Archivo dotPointCuda.cu

Si se cuenta con la posibilidad de poder ejecutar el código de CUDA los comandos son los siguientes:

Compilación: `nvcc dotPointCuda.cu -o dotPoint -arch=sm_35`

Ejecución: `./dotPoint`

## Enlace del repositorio

https://github.com/Oscarmendez825/CUDA-Taller.git
