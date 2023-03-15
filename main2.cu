#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <cuda.h>
#include <math.h>
#include <iostream>
#include <fstream>
using namespace std;



//altan
//Bomba
//tnt
//gravedad
//rompecabezas
//Automatico




//---------Método que comprueba si lo introducido por consola es un valor entero.---------
bool validarEntero(int& numero) {
    //Si no es un numero entero lo introducido, el código gestiona el error.
    if (cin.fail()) {
        cin.clear();
        cin.ignore();
        cout << "[Error]: El valor introducido no es correcto." << endl;
        cout << endl;
        return false;
    }
    else {
        cout << endl;
        return true;
    }
}

//---------Método que pide al usuario las filas para comenzar.---------
int pedirFilas(){
	int filas;
    bool validarEnteroCheck = false;

	while (!validarEnteroCheck) {
        cin >> filas;
        validarEnteroCheck = validarEntero(filas);
    }
    validarEnteroCheck = false;
	return filas;
}

//---------Método que pide al usuario las columnas para comenzar.---------
int pedirColumnas(){
	int columnas;
    bool validarEnteroCheck = false;
	//--------Pide las columnas de la matriz. Si no introduce un numero entero, error.------------
    while (!validarEnteroCheck) {
        cin >> columnas;
        validarEnteroCheck = validarEntero(columnas);
    }
    validarEnteroCheck = false;
	return columnas;
}

//---------Método que pide al usuario la dificultad del juego.---------
int pedirDificultad(){
	//Pide el nivel de dificultad. Si no introduce un numero entero o (1 o 2),Error.
    // FACIL = 1. DIFICIL = 2
	 int dificultad;
    bool validarEnteroCheck = false;
    while (!validarEnteroCheck) {
        cout << "Selecciona nivel de dificultad (1 = FACIL | 2 = DIFICIL)" << endl;
        cout << "\tFACIL -> Candry Crosh genera numeros del 1 al 4." << endl;
        cout << "\tDIFICIL -> Candry Crosh genera numeros del 1 al 6." << endl;
        cout << "Introduce el numero: ";
        cin >> dificultad;
        validarEnteroCheck = validarEntero(dificultad);
        if (dificultad != 1 && dificultad != 2) { validarEnteroCheck = false; }
    }
    validarEnteroCheck = false;
	return dificultad;

}

//---------Método que genera la matriz inicial y la devuelve.---------
int* generarMatriz (int* h_matriz,int filas, int columnas, int dificultad){
	//Se genera la matriz
	printf("\n Da comienzo el juego\n");
	printf("**********************");
	printf("\n Se genera aleatoriamente la siguiente matriz:\n");
	for (int i = 0; i < filas; i++){
		for (int j = 0; j < columnas; j++) {
			if (dificultad == 1) {
				h_matriz[i*columnas+j]= rand() % 5; //numero aleatorio entre el 0-10
				printf("%d", h_matriz[i*columnas+j]);
				printf("  ");
			} else if (dificultad == 2) {
                h_matriz[i*columnas+j] = rand() % 7;
				printf("%d", h_matriz[i*columnas+j]);
				printf("  ");
            }       

		}
		printf("\n");
	}
	printf("**********************\n");

	return h_matriz;

}

//---------Método que genera la matriz mientras el juego esta en marcha.---------
__global__ void imprimirMatriz(int *dev_R, int c) {
	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;
	
	//posicion de la matriz final 
	int pos = fil * c + col;
	if (pos == 0){
		printf("\n Matriz:\n");
	}
	if ((pos%c) == 0){
		printf("\n%d",dev_R[pos]);
		printf("  ");
	}else{
		printf("%d",dev_R[pos]);
		printf("  ");
	}
	
}

//---------Método que copia la matriz de dev_A a dev_R.---------
__global__ void copiarMatriz(int *dev_A, int *dev_R, int c) {
	//declaramos las col y filas
	int i = threadIdx.x + blockDim.x * blockIdx.x;
	int j = threadIdx.y + blockDim.y * blockIdx.y;
	
	//posicion de la matriz final 
	int pos = i * c + j;
	dev_R[pos] = dev_A[pos];

}
	
/*
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

*/
//se busca donde haya cuatro elementos iguales, tanto en posiciones horizontales como verticales y se pone la bomba
//se tiene que guardar si es columna o fila, para despues explotar

//---------Método que pone la bomba donde haya 4 elementos iguales, indicados por el usuario.---------
__global__ void ponerBomba(int *dev_R, int c, int size, int fila, int columna) {
	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;
	
	//posicion de la matriz final 
	int pos = fil * c + col;
	int valor = dev_R[pos];
	int fila_ini = pos/c;

	//Derecha
	//compruba que los 3 elementos siguientes tienen el mismo valor y que estan en la misma fila
	if (dev_R[pos+1] == valor && dev_R[pos+2] == valor && dev_R[pos+3] == valor && pos+1/c == fila_ini && pos+2/c == fila && pos+3/c == fila_ini){
		dev_R[pos] = -1;
		dev_R[pos+1] = rand() % 5;
		dev_R[pos+2] = rand() % 5;
		dev_R[pos+3] = rand() % 5;

	}

	//Arriba y Abajo
	//compruba que los 3 elementos de arriba tienen el mismo valor y que esta dentro de matriz
	
	if (pos+(c*3) < size){
		if (dev_R[pos+c] == valor && dev_R[pos+(c*2)] == valor && dev_R[pos+(c*3)]== valor){
			dev_R[pos] = -1;
			dev_R[pos+(c*1)] = rand() % 5;
			dev_R[pos+(c*2)] = rand() % 5;
			dev_R[pos+(c*3)] = rand() % 5;
		}
	}

	

}


//Chequea si hay elementos adyacentes con el mismo valor en toda la matriz, si es asi, los cambia por valores aleatorios
__global__ void comprobarPares(int *dev_R, int fila, int columna, int c, int size) {
	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;
	
	//posicion de la matriz final 
	int pos = fil * c + col;
	//posicion indicada por el usuario
	int posUsuario = fila * c + columna;
		
	//chequea si en la posicion de de la derecha hay elementos iguales y si es la posicion indicada por el usuario
	if ( dev_R[pos] == dev_R[pos+1] && (pos+1)%c !=0 && pos == posUsuario ){ 
		dev_R[pos] = rand() % 5;
		dev_R[pos+1] = rand() % 5;
	}

	//chequea abajo
	if ( dev_R[pos] == dev_R[pos+c] && pos < size && pos == posUsuario){
		dev_R[pos] = rand() % 5;
		dev_R[pos+c] = rand() % 5; 
	}	
}

	

int main(int argc, char** argv) {
	//------------------------------------- declaraciones de variables-------------------------------
	//Seed para la generacion de numero aleatorios.
    //srand(time(NULL));
	
	//Para el while, si es distnto a -1 se termina el juego
	int ganador = -1; 
	
	//llamadas a funciones
	cout << "Introduce el numero de filas de la matriz: ";
	int filas=pedirFilas();
	cout << "Introduce el numero de columnas de la matriz: ";
	int columnas = pedirColumnas();
	int dificultad = pedirDificultad();

	//Instanciacion de la matriz host y resultante
	int size = filas * columnas ;
	int* h_matriz = (int*)malloc(size* sizeof(int));
	int* h_R = (int*)malloc(size* sizeof(int));

	h_matriz = generarMatriz (h_matriz,filas,columnas, dificultad);

	//-------------------------------------cuestiones de memoria-------------------------------
	//instanciamos como vectores la matriz
	int*dev_M,*dev_R;

	// Reservamos memoria en la GPU
	cudaMalloc((void**) &dev_M, size * sizeof(int));
	cudaMalloc((void**) &dev_R, size * sizeof(int));
	
	// Copiamos los datos desde la memoria host a la memoria device
	cudaMemcpy(dev_M, h_matriz, size* sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_R, h_R, size* sizeof(int), cudaMemcpyHostToDevice);

	
	//definimos el numero de bloques y hilos por bloque
	dim3 numBloques (1); 
	dim3 ThreadsBloque(filas, columnas);


	while(ganador==-1){
		printf("\n Introduce la fila y columna que quiera comprobar:\n");
		int f_comprobar=pedirFilas();
		int c_comprobar = pedirColumnas();
		//------------------------------------- kernels -------------------------------
		//pedir coordenadas de la ficha que se quiera mover y direccion 
		
		//Se copia la matriz inicial en la final
		copiarMatriz <<<numBloques, ThreadsBloque >>> (dev_M,dev_R, columnas);
		ponerBomba <<<numBloques, ThreadsBloque >>> (dev_R,columnas,size,f_comprobar,c_comprobar);
		
		//moverPosiciones <<<numBloques, ThreadsBloque >>> (dev_M,dev_R,0,0,2);
		
		comprobarPares <<<numBloques, ThreadsBloque >>> (dev_R, f_comprobar,c_comprobar,columnas,size);
		imprimirMatriz <<<numBloques, ThreadsBloque >>> (dev_R,columnas);
		
	
	}
	
	//---------------------------- Fin de la programacion paralela---------------------------------------
	// copiando el resultado a la memoria Host
	cudaMemcpy(h_R, dev_R, size* sizeof(int), cudaMemcpyDeviceToHost);
	
	
	printf("\nFin del Juego!!!!!\n");
	printf("**********************");
	printf("\n La matriz Resultante es:\n");
	for (int i = 0; i < filas; i++) {
		for (int j = 0; j < columnas; j++) {
			printf("%d",h_R[i*columnas+j]);
			printf("  ");
			

		}
		printf("\n");
			
	} 
	cudaFree(dev_M);
	cudaFree(dev_R);

	return (EXIT_SUCCESS);
}