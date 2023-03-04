#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <cuda.h>
#include <math.h>
#include <iostream>
#include <fstream>
using namespace std;

//conjunto de 4 numeros localizados en memoria

const int Col = 6;
const int Fil = 6;
const int SIZE = Fil*Col;



__global__ void imprimirMatriz(int *dev_A, int *dev_R) {
	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;
	
	//posicion de la matriz final 
	int pos = fil * Col + col;
	if (pos == 0){
		printf("\n Matriz:\n");
	}
	if ((pos%Col) == 0){
		printf("\n%d",dev_R[pos]);
		printf("  ");
	}else{
		printf("%d",dev_R[pos]);
		printf("  ");
	}
	
}

__global__ void copiarMatriz(int *dev_A, int *dev_R) {
	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;
	
	//posicion de la matriz final 
	int pos = fil * Col + col;
	dev_R[pos] = dev_A[pos];

}
	

__global__ void moverPosiciones(int *dev_A, int *dev_R, int x, int y, int dirr) {
	
	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;
	
	//posicion de la matriz final 
	int pos = fil * Col + col;
	int posCambiar = x * Col + y;
	
	if (posCambiar < SIZE && posCambiar >= 0){ //se comprueba que la coor esta dentro de los limites
		if (pos == posCambiar){ //entra cuando esta en la posicion que se quiere cambiar
			if (dirr == 0 && posCambiar-col > 0 ){//indica la dirrecion 0 = arriba
				int aux =  dev_A[pos-Col];
				dev_R[pos] = aux;
				dev_R[pos-Col] = dev_A[pos];

			}
			if (dirr == 1 && (posCambiar+1)%Col !=0 ){//indica la dirrecion 1 = derecha. Si el resto +1 = 0 se trata de la ultima columna por lo que no puede moverse a la der
				int aux =  dev_A[pos+1];
				dev_R[pos] = aux;
				dev_R[pos+1] = dev_A[pos];

			}
			if (dirr == 2 && posCambiar+col < SIZE ){//indica la dirrecion 2 = abajo
				int aux =  dev_A[pos+Col];
				dev_R[pos] = aux;
				dev_R[pos+Col] = dev_A[pos];

			}
			if (dirr == 3 && (posCambiar)%Col !=0 ){//indica la dirrecion 3 = izquierda. Si el resto = 0 se trata de la primera columna por lo que no puede moverse a la izq
				int aux =  dev_A[pos-1];
				dev_R[pos] = aux;
				dev_R[pos-1] = dev_A[pos];
			}
		}
	}
}

//se busca donde haya cuatro elementos iguales, tanto en posiciones horizontales como verticales y se pone la bomba
//se tiene que guardar si es columna o fila, para despues explotar
__global__ void ponerBomba(int *dev_R) {
	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;
	
	//posicion de la matriz final 
	int pos = fil * Col + col;
	int valor = dev_R[pos];
	int fila = pos/Col;

	//Derecha
	//compruba que los 3 elementos siguientes tienen el mismo valor y que estan en la misma fila
	if (dev_R[pos+1] == valor && dev_R[pos+2] == valor && dev_R[pos+3] == valor && pos+1/Col == fila && pos+2/Col == fila && pos+3/Col == fila){
		dev_R[pos] = -1;
		dev_R[pos+1] = rand() % 5;
		dev_R[pos+2] = rand() % 5;
		dev_R[pos+3] = rand() % 5;

	}

	//Arriba y Abajo
	//compruba que los 3 elementos de arriba tienen el mismo valor y que esta dentro de matriz
	
	if (pos+(Col*3) < SIZE){
		if (dev_R[pos+Col] == valor && dev_R[pos+(Col*2)] == valor && dev_R[pos+(Col*3)]== valor){
			dev_R[pos] = -1;
			dev_R[pos+(Col*1)] = rand() % 5;
			dev_R[pos+(Col*2)] = rand() % 5;
			dev_R[pos+(Col*3)] = rand() % 5;
		}
	}

	

}


//Chequea si hay elementos adyacentes con el mismo valor en toda la matriz, si es asi, los cambia por valores aleatorios
__global__ void comprobarPares(int *dev_R, int f, int c) {
	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;
	
	//posicion de la matriz final 
	int pos = fil * Col + col;
	//posicion indicada por el usuario
	int posUsuario = f * Col + c;
		
	//chequea si en la posicion de de la derecha hay elementos iguales y si es la posicion indicada por el usuario
	if ( dev_R[pos] == dev_R[pos+1] && (pos+1)%Col !=0 && pos == posUsuario ){ 
		dev_R[pos] = rand() % 5;
		dev_R[pos+1] = rand() % 5;
	}

	//chequea abajo
	if ( dev_R[pos] == dev_R[pos+Col] && pos < SIZE && pos == posUsuario){
		dev_R[pos] = rand() % 5;
		dev_R[pos+Col] = rand() % 5; 
	}	
}

	

int main(int argc, char** argv) {
	//------------------------------------- declaraciones de variables-------------------------------
	//Seed para la generacion de numero aleatorios.
    srand(time(NULL));

    //Declaracion de varibles
    int filas, columnas, dificultad;
    int** h_matriz; //Matriz del host
    bool validarEnteroCheck = false;

	//declaramos la matriz
	int h_M[Fil][Col];
	
	//declaramos la lista con los valores
	int h_valores[6] = {1,2,3,4,5,6};
	
	//se instancia la matriz resultante
	int h_R[Fil][Col] = { 0 };
	

	//Para el while, si es distnto a -1 se termina el juego
	int ganador = -1; 

	//Se genera la matriz
	printf("\n Matriz Inicial:\n");
	for (int i = 0; i < Fil; i++){
		for (int j = 0; j < Col; j++) {
			h_M[i][j] = rand() % 5; //numero aleatorio entre el 0-10
			printf("%d", h_M[i][j]);
			printf("  ");
		}
		printf("\n");
	}
	printf("\n");

	//-------------------------------------cuestiones de memoria-------------------------------
	//instanciamos como vectores la matriz
	int*dev_M,*dev_valores,*dev_R;

	
	// Reservamos memoria en la GPU
	cudaMalloc((void**) &dev_M, SIZE * sizeof(int));
	cudaMalloc((void**) &dev_R, SIZE * sizeof(int));
	
	
	

	// Copiamos los datos desde la memoria host a la memoria device
	cudaMemcpy(dev_M, h_M, SIZE* sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_R, h_R, SIZE* sizeof(int), cudaMemcpyHostToDevice);

	
	
	//definimos el numero de bloques y hilos por bloque
	dim3 numBloques (1); 
	dim3 ThreadsBloque(Fil, Col);
	
	//------------------------------------- kernels -------------------------------
	//pedir coordenadas de la ficha que se quiera mover y direccion 
	
	//Se copia la matriz inicial en la final
	copiarMatriz <<<numBloques, ThreadsBloque >>> (dev_M,dev_R);
	
	//moverPosiciones <<<numBloques, ThreadsBloque >>> (dev_M,dev_R,0,0,2);
	
	comprobarPares <<<numBloques, ThreadsBloque >>> (dev_R, 2,4);
	imprimirMatriz <<<numBloques, ThreadsBloque >>> (dev_M,dev_R);
	
	ponerBomba <<<numBloques, ThreadsBloque >>> (dev_R);
	
	
	


	
	
	// copiando el resultado a la memoria Host
	cudaMemcpy(h_R, dev_R, SIZE* sizeof(int), cudaMemcpyDeviceToHost);
	

	cudaFree(dev_M);
	cudaFree(dev_R);
	
	printf("\n");
	printf("El resultado de mover posiciones de las matrices:\n");
	for (int i = 0; i < Fil; i++) {
		for (int j = 0; j < Col; j++) {
			printf("%d",h_R[i][j]);
			printf("  ");
			

		}
		printf("\n");
			
	} 

	return (EXIT_SUCCESS);
}