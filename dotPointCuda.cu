#include <iostream>
#include <cuda_runtime.h>

const int N = 1000; // Tamaño de los arreglos

// Kernel para el producto punto de dos arreglos
// a y b son los arreglos de entrada
// result es el arreglo de salida
// n es el tamaño de los arreglos
__global__ void dotProductKernel(const float* a, const float* b, float* result, int n) {
    
    // Calcula el índice global
    int tid = threadIdx.x + blockIdx.x * blockDim.x;

    // Variable compartida para almacenar la suma parcial en el bloque
    __shared__ float partialSum[256];

    // Inicializa la suma parcial en el bloque
    partialSum[threadIdx.x] = 0.0f;

    // Calcula la suma parcial en el bloque
    while (tid < n) {
        partialSum[threadIdx.x] += a[tid] * b[tid];
        tid += blockDim.x * gridDim.x;
    }

    // Asegura que se hayan completado la sumas parciales antes de continuar.
    __syncthreads();

    // Se reduce el número de elementos a la mitad en cada iteración
    for (int stride = blockDim.x / 2; stride > 0; stride >>= 1) {
        if (threadIdx.x < stride) {
            partialSum[threadIdx.x] += partialSum[threadIdx.x + stride];
        }
        // Asegura que se hayan completado las sumas parciales antes de continuar.
        __syncthreads();
    }

    // El primer thread de cada bloque almacena el resultado final 
    // en el vector de resultados
    if (threadIdx.x == 0) {
        atomicAdd(result, partialSum[0]);
    }
}

int main() {

    // Tamaño de los arreglos en bytes
    const int arraySize = N * sizeof(float);
    // Arreglos en el host
    float *h_a, *h_b, *h_result;
    // Arreglos en el dispositivo
    float *d_a, *d_b, *d_result;

    // Asigna memoria en el host
    h_a = (float*)malloc(arraySize);
    h_b = (float*)malloc(arraySize);
    h_result = (float*)malloc(sizeof(float));

    // Inicializa arreglos en el host
    // Todos los elementos de los arreglos son 2.0f y 4.0f respectivamente
    for (int i = 0; i < N; ++i) {
        h_a[i] = 2.0f;
        h_b[i] = 4.0f;
    }

    // Asigna memoria en el dispositivo 
    cudaMalloc((void**)&d_a, arraySize);
    cudaMalloc((void**)&d_b, arraySize);
    cudaMalloc((void**)&d_result, sizeof(float));

    // Copia datos del host al dispositivo
    cudaMemcpy(d_a, h_a, arraySize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, arraySize, cudaMemcpyHostToDevice);
    // Inicializa el resultado en el dispositivo
    cudaMemset(d_result, 0, sizeof(float));

    // Configura dimensiones del bloque 
    int blockSize = 256;
    int numBlocks = (N + blockSize - 1) / blockSize;

    // Lanza el kernel
    dotProductKernel<<<numBlocks, blockSize>>>(d_a, d_b, d_result, N);

    // Copia el resultado de vuelta al host
    // El resultado se encuentra en el dispositivo
    // por lo que se debe copiar de vuelta al host
    cudaMemcpy(h_result, d_result, sizeof(float), cudaMemcpyDeviceToHost);

    // Imprime el resultado
    std::cout << "Resultado del producto punto: " << *h_result << std::endl;

    // Libera memoria en el host y el dispositivo
    free(h_a);
    free(h_b);
    free(h_result);
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_result);

    return 0;
}
