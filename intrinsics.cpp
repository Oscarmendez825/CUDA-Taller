#include <iostream>
#include <immintrin.h> //biblioteca para AVX2

// Función para calcular el producto punto de dos arreglos de tipo float utilizando AVX2
float VectorDotProduct(float* arr1, float* arr2, int N) {
    __m256 result = _mm256_setzero_ps(); // Inicializa el resultado a cero 

    int i;
    for (i = 0; i <= N - 8; i += 8) {
        // Cargar en registros AVX: __m256 : Es un vector de 8 numeros de punto flotante (8x32 = 256 bits)
        __m256 vec1 = _mm256_loadu_ps(&arr1[i]); // Cargar 8 elementos de arr1
        __m256 vec2 = _mm256_loadu_ps(&arr2[i]); // Cargar 8 elementos de arr2

        // Realizar multiplicación y suma vectorial de los elementos
        //_mm256_mul_ps: Multiplica elementos single-precision (32-bit) floating-point de a y b y los guarda.
        //_mm256_add_ps: Devuelve un vector __mm256 donde cada uno de los elementos se establece igual a la suma de a y b
        result = _mm256_add_ps(result, _mm256_mul_ps(vec1, vec2)); 
    }

    // Inicializar un arreglo para almacenar los resultados finales
    float finalSum[8];
    //_mm256_storeu_ps: Copia los resultados de un vector __m256(result) en un array float b(finalSum).
    _mm256_storeu_ps(finalSum, result);

    // Realiza la suma de todos los elementos del arreglo finalSum
    float dotProduct = 0.0f;
    for (int j = 0; j < 8; j++) {
        dotProduct += finalSum[j];
    }

    return dotProduct;
}

int main() {
    const int N = 1000; // N mayor a 500 y múltiplo de 8 para AVX2
    float arr1[N];
    float arr2[N];

    // Llena los arreglos con datos
    for (int i = 0; i < N; i++) {
        arr1[i] = 2.0;
        arr2[i] = 4.0;
    }

    float result = VectorDotProduct(arr1, arr2, N);

    std::cout << "Resultado del producto punto (AVX2): " << result << std::endl;

    return 0;
}