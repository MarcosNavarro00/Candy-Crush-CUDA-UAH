#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <cuda.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <time.h>
#ifndef __CUDACC__ 
#define __CUDACC__
#endif
#include <device_functions.h>
#include <device_launch_parameters.h>
#include <curand_kernel.h>
#include <thrust/sort.h>
using namespace std;



//Faltan
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
int pedirFilas() {
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
int pedirColumnas() {
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
int pedirDificultad() {
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
int* generarMatriz(int* h_matriz, int filas, int columnas, int dificultad, curandState* estado) {
	//Se genera la matriz
	printf("\n Da comienzo el juego\n");
	printf("**********************");
	printf("\n Se genera aleatoriamente la siguiente matriz:\n");
	for (int i = 0; i < filas; i++) {
		for (int j = 0; j < columnas; j++) {
			if (dificultad == 1) {
				h_matriz[i * columnas + j] = (rand() % 4) + 1;; //numero aleatorio entre el 1-4
				printf("%d", h_matriz[i * columnas + j]);
				printf("  ");
			}
			else if (dificultad == 2) {
				h_matriz[i * columnas + j] = (rand() % 6) + 1; //numero aleatorio entre el 1-6
				printf("%d", h_matriz[i * columnas + j]);
				printf("  ");
			}

		}
		printf("\n");
	}
	printf("**********************\n");

	return h_matriz;

}

//---------Método que genera la matriz inicial y la devuelve.---------
void imprimirMatriz2(int* h_R, int c, int f) {
	//Se genera la matriz

	printf("\n Tablero:\n");
	printf("---------\n");
	for (int i = 0; i < f; i++) {
		for (int j = 0; j < c; j++) {

			//printf("%d", dev_R[i*c+j]);
			//printf("  ");
			//switch (h_R[i * c + j]) {
			switch (h_R[i * c + j]) {
			case -3:
				printf("R");
				break;
			case -2:
				printf("T");
				break;
			case -1:
				printf("B");
				break;
			case 0:
				printf("O");
				break;
			case 1:
				printf("1");
				break;
			case 2:
				printf("2");
				break;
			case 3:
				printf("3");
				break;
			case 4:
				printf("4");
				break;
			case 5:
				printf("5");
				break;
			case 6:
				printf("6");
				break;
			}
			printf(" ");
		}
		printf("\n");
	}
	printf("---------\n");

}


//-----------------------------------------------------------

__device__ int* gravedad_horizontal_TNT(int* dev_R, int f, int c, int fila, int* arr_adyacente, int n, int dificultad, curandState* estado) {
	//fila actual de la posicion
	//int fila_actual = pos/c;
	int pos = arr_adyacente[0];
	int pos2 = arr_adyacente[1];
	int pos3 = arr_adyacente[2];
	int pos4 = arr_adyacente[3];
	int pos5 = arr_adyacente[4];
	int pos6 = arr_adyacente[5];
	if (fila == 0) {
		if (dificultad == 1) {
			dev_R[pos2] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos3] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos4] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos5] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos6] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos] = -2;
		}
		else {
			dev_R[pos2] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos3] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos4] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos5] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos6] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos] = -2;
		}
	}
	else {
		for (int i = 0; i < fila; i++) {
			//dev_R[pos-(c*i)] = dev_R[pos-(c*(i+1))];
			dev_R[pos2 - (c * i)] = dev_R[pos2 - (c * (i + 1))];
			dev_R[pos3 - (c * i)] = dev_R[pos3 - (c * (i + 1))];
			dev_R[pos4 - (c * i)] = dev_R[pos4 - (c * (i + 1))];
			dev_R[pos5 - (c * i)] = dev_R[pos5 - (c * (i + 1))];
			dev_R[pos6 - (c * i)] = dev_R[pos6 - (c * (i + 1))];
		}
		//Introduce los valores aleatoros de la primera fila

		if (dificultad == 1) {
			dev_R[pos2 % c] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos3 % c] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos4 % c] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos5 % c] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos6 % c] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos] = -2;
		}
		else {
			dev_R[pos2 % c] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos3 % c] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos4 % c] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos5 % c] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos6 % c] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos] = -2;
		}
		
	}
	return dev_R;
}

__device__ int* gravedad_vertical_TNT(int* dev_R, int f, int c, int fila, int* arr_adyacente, int n, int dificultad, curandState* estado) {

	int pos = arr_adyacente[0];
	int pos2 = arr_adyacente[1];
	int pos3 = arr_adyacente[2];
	int pos4 = arr_adyacente[3];
	int pos5 = arr_adyacente[4];
	int pos6 = arr_adyacente[5];
	//se obtiene cuando comienza los 4 numeros adyancentes
	int fila_ini = pos / c;
	//se obtiene en que fila termina los cuatro repetidos
	int fila_ult = pos6 / c;
	//printf("\nnn: %d %d", fila_ini, fila_ult);
	//se obtiene cuantos huecos se tienen que intercambiar 
	int huecos_cambio = f - (fila_ult - fila_ini + 1);
	//printf("\nHuecos: %d", huecos_cambio);
	//se obtiene cual es la columna en la que iteramos
	int primera_columna = pos % c;

	//Obtiene cuantos huecos se tienen que asignar de forma aleatoria
	int huecos_aleatorios = fila_ult - huecos_cambio;

	//Se comprueba si hay alguna posicion que esta en la primera fila.
	//Si la hay no gravedad y se asignan los valores aleatorio.
	if (pos / c == 0 || pos2 / c == 0 || pos3 / c == 0 || pos4 / c == 0 || pos5 / c == 0 || pos6 / c == 0) {
		if (dificultad == 1) {
			dev_R[pos2] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos3] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos4] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos5] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos6] = 1 + (int)(curand_uniform(estado) * 4);
			dev_R[pos6] = -2;
		}
		else {
			dev_R[pos2] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos3] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos4] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos5] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos6] = 1 + (int)(curand_uniform(estado) * 6);
			dev_R[pos6] = -2;
		}
	}
	else {
		//Cambia los numeros repetidos por los de arriba
		for (int i = 0; i < huecos_cambio; i++) {
			dev_R[pos5 - (c * i)] = dev_R[pos - (c * (i + 1))];
		}
		//Cambia los valores de arriba por valores aleatorios
		for (int i = 0; i < fila_ini; i++) {
			if (dificultad == 1) {
				dev_R[primera_columna + (c * i)] = 1 + (int)(curand_uniform(estado) * 4);
			}
			else {
				dev_R[primera_columna + (c * i)] = 1 + (int)(curand_uniform(estado) * 6);
			}
		}
		dev_R[pos6] = -2;
	}
	return dev_R;
}




__global__ void ponerTNT(int* dev_R, int c, int f, int size, int fila, int columna, int* TNT, int n, int dificultad, curandState* estado) {

	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;

	//posicion de la matriz final 
	int pos = fil * c + col;


	//posicion indicada por el usuario
	int posUsuario = fila * c + columna;
	int filaUsuario = posUsuario / c;

	//Array que contendra las posiciones adyacentes y el valor de cada posicion 
	__shared__ int valor[1];
	__shared__ int arr_adyacente[5];


	///
	//comprueba que se esta en la pos en la que esta interactuando el usuario
	if (pos == posUsuario) {

		valor[0] = dev_R[pos];
		valor[1] = pos;
		arr_adyacente[0] = pos;
		//printf("Posicionwes: %d %d %d %d %d %d", dev_R[pos - (c * 5)], dev_R[pos - (c * 4)], dev_R[pos - (c * 3)], dev_R[pos - (c * 2)], dev_R[pos - (c * 1)], dev_R[pos + c]);

	}
	if (pos != posUsuario && valor[1] + 1 == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - 1] && valor[0] == dev_R[pos + 1] && valor[0] == dev_R[pos + 2] && valor[0] == dev_R[pos + 3] && valor[0] == dev_R[pos + 4] && pos / c == fila && (pos + 1) / c == fila && (pos + 2) / c == fila && (pos + 3) / c == fila && (pos + 4) / c == fila) {
		printf("Posicion que va a poner el TNT: %d %d", fil, col);
		arr_adyacente[0] = pos - 1; arr_adyacente[1] = pos; arr_adyacente[2] = pos + 1; arr_adyacente[3] = pos + 2; arr_adyacente[4] = pos + 3; arr_adyacente[5] = pos + 4;
		dev_R = gravedad_horizontal_TNT(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*TNT += 1;

	}
	else if (pos != posUsuario && valor[1] + 1 == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - 2] && valor[0] == dev_R[pos - 1] && valor[0] == dev_R[pos + 1] && valor[0] == dev_R[pos + 2] && valor[0] == dev_R[pos + 3] && pos / c == fila && (pos - 1) / c == fila && (pos + 1) / c == fila && (pos + 2) / c == fila && (pos + 3) / c == fila) {
		printf("Posicion que va a poner el TNT: %d %d", fil, col);
		arr_adyacente[0] = pos - 1; arr_adyacente[1] = pos; arr_adyacente[2] = pos - 2; arr_adyacente[3] = pos + 1; arr_adyacente[4] = pos + 2; arr_adyacente[5] = pos + 3;
		dev_R = gravedad_horizontal_TNT(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*TNT += 1;

	}
	else if (pos != posUsuario && valor[1] + 1 == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - 3] && valor[0] == dev_R[pos - 2] && valor[0] == dev_R[pos - 1] && valor[0] == dev_R[pos + 1] && valor[0] == dev_R[pos + 2] && pos / c == fila && (pos - 2) / c == fila && (pos - 1) / c == fila && (pos + 1) / c == fila && (pos - 3) / c == fila) {
		printf("Posicion que va a poner el TNT: %d %d", fil, col);
		arr_adyacente[0] = pos - 1; arr_adyacente[1] = pos; arr_adyacente[2] = pos - 3; arr_adyacente[3] = pos - 2; arr_adyacente[4] = pos + 1; arr_adyacente[5] = pos + 2;
		dev_R = gravedad_horizontal_TNT(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*TNT += 1;

	}
	else if (pos != posUsuario && valor[1] + 1 == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - 4] && valor[0] == dev_R[pos - 3] && valor[0] == dev_R[pos - 2] && valor[0] == dev_R[pos - 1] && valor[0] == dev_R[pos + 1] && pos / c == fila && (pos - 3) / c == fila && (pos - 2) / c == fila && (pos - 1) / c == fila && (pos - 4) / c == fila) {
		printf("Posicion que va a poner el TNT: %d %d", fil, col);
		arr_adyacente[0] = pos - 1; arr_adyacente[1] = pos; arr_adyacente[2] = pos - 4; arr_adyacente[3] = pos - 3; arr_adyacente[4] = pos - 2; arr_adyacente[5] = pos + 1;
		dev_R = gravedad_horizontal_TNT(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*TNT += 1;

	}
	else if (pos != posUsuario && valor[1] + 1 == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - 5] && valor[0] == dev_R[pos - 4] && valor[0] == dev_R[pos - 3] && valor[0] == dev_R[pos - 2] && valor[0] == dev_R[pos - 1] && pos / c == fila && (pos - 4) / c == fila && (pos - 3) / c == fila && (pos - 2) / c == fila && (pos - 5) / c == fila) {
		printf("Posicion que va a poner el TNT: %d %d", fil, col);
		arr_adyacente[0] = pos - 1; arr_adyacente[1] = pos; arr_adyacente[2] = pos - 5; arr_adyacente[3] = pos - 4; arr_adyacente[4] = pos - 3; arr_adyacente[5] = pos - 2;
		dev_R = gravedad_horizontal_TNT(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*TNT += 1;

	}
	else if (valor[1] == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - 5] && valor[0] == dev_R[pos - 4] && valor[0] == dev_R[pos - 3] && valor[0] == dev_R[pos - 2] && valor[0] == dev_R[pos - 1] && pos / c == fila && (pos - 4) / c == fila && (pos - 3) / c == fila && (pos - 2) / c == fila && (pos - 5) / c == fila) {

		printf("\nHola3\n");
		printf("Posicion que va a poner el TNT: %d ", pos);
		arr_adyacente[0] = pos - 1; arr_adyacente[1] = pos; arr_adyacente[2] = pos - 5; arr_adyacente[3] = pos - 4; arr_adyacente[4] = pos - 3; arr_adyacente[5] = pos - 2;
		dev_R = gravedad_horizontal_TNT(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*TNT += 1;

	}
	//Vertical
	if (pos != posUsuario && valor[1] + c == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - c] && valor[0] == dev_R[pos + c] && valor[0] == dev_R[pos + (c * 2)] && valor[0] == dev_R[pos + (c * 3)] && valor[0] == dev_R[pos + (c * 4)]) {
		printf("Posicion que va a poner el TNT6: %d %d", fil, col);
		arr_adyacente[0] = pos - c; arr_adyacente[1] = pos; arr_adyacente[2] = pos + c; arr_adyacente[3] = pos + (c * 2); arr_adyacente[4] = pos + (c * 3); arr_adyacente[5] = pos + (c * 4);
		dev_R = gravedad_vertical_TNT(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*TNT += 1;
	}
	if (pos != posUsuario && valor[1] + c == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - (c * 2)] && valor[0] == dev_R[pos - c] && valor[0] == dev_R[pos + c] && valor[0] == dev_R[pos + (c * 2)] && valor[0] == dev_R[pos + (c * 3)]) {
		printf("Posicion que va a poner el TNT7: %d %d", fil, col);
		arr_adyacente[0] = pos - (c * 2); arr_adyacente[1] = pos - c; arr_adyacente[2] = pos; arr_adyacente[3] = pos + c; arr_adyacente[4] = pos + (c * 2); arr_adyacente[5] = pos + (c * 3);
		dev_R = gravedad_vertical_TNT(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*TNT += 1;
	}
	if (pos != posUsuario && valor[1] + c == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - (c * 3)] && valor[0] == dev_R[pos - (c * 2)] && valor[0] == dev_R[pos - c] && valor[0] == dev_R[pos + c] && valor[0] == dev_R[pos + (c * 2)]) {
		printf("Posicion que va a poner el TNT8: %d %d", fil, col);
		arr_adyacente[0] = pos - (c * 3); arr_adyacente[1] = pos - (c * 2); arr_adyacente[2] = pos - c; arr_adyacente[3] = pos; arr_adyacente[4] = pos + c; arr_adyacente[5] = pos + (c * 2);
		dev_R = gravedad_vertical_TNT(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*TNT += 1;
	}
	if (pos != posUsuario && valor[1] + c == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - (c * 4)] && valor[0] == dev_R[pos - (c * 3)] && valor[0] == dev_R[pos - (c * 2)] && valor[0] == dev_R[pos - c] && valor[0] == dev_R[pos + c]) {
		printf("Posicion que va a poner el TNT9: %d %d", fil, col);
		arr_adyacente[0] = pos - (c * 4); arr_adyacente[1] = pos - (c * 3); arr_adyacente[2] = pos - (c * 2); arr_adyacente[3] = pos - c; arr_adyacente[4] = pos; arr_adyacente[5] = pos + c;
		dev_R = gravedad_vertical_TNT(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*TNT += 1;
	}
	if (pos != posUsuario && valor[1] + c == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - (c * 5)] && valor[0] == dev_R[pos - (c * 4)] && valor[0] == dev_R[pos - (c * 3)] && valor[0] == dev_R[pos - (c * 2)] && valor[0] == dev_R[pos - c]) {
		printf("Posicion que va a poner el TNT10: %d %d", fil, col);
		arr_adyacente[0] = pos - (c * 5); arr_adyacente[1] = pos - (c * 4); arr_adyacente[2] = pos - (c * 3); arr_adyacente[3] = pos - (c * 2); arr_adyacente[4] = pos - c; arr_adyacente[5] = pos;
		dev_R = gravedad_vertical_TNT(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*TNT += 1;
	} if (valor[1] == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - (c * 5)] && valor[0] == dev_R[pos - (c * 4)] && valor[0] == dev_R[pos - (c * 3)] && valor[0] == dev_R[pos - (c * 2)] && valor[0] == dev_R[pos - c]) {

		printf("Posicion que va a poner el TNT11: %d %d", fil, col);
		arr_adyacente[0] = pos - (c * 5); arr_adyacente[1] = pos - (c * 4); arr_adyacente[2] = pos - (c * 3); arr_adyacente[3] = pos - (c * 2); arr_adyacente[4] = pos - c; arr_adyacente[5] = pos;
		dev_R = gravedad_vertical_TNT(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*TNT += 1;
	}
	__syncthreads();
}

__global__ void explotarTNT(int* dev_R, int c, int f, int size, int fila, int columna, int n, int* explosion, int dificultad, curandState* estado) {
	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;

	//posicion de la matriz 
	int pos = fil * c + col;
	//posicion indicada por el usuario
	int posUsuario = fila * c + columna;
	int col_final = pos;
	int fil_inicial = pos;
	//pos inicial va empezar el pos 
	int pos_ini = pos;


	if (pos == posUsuario && dev_R[pos] == -2) {
		printf("Se explota el TNT, se explotan todas las casillas en un radio de 4");

		for (int i = 0; i < 4; i++) {
			//printf("\nPOS: %d %d", pos_ini, fila);
			//se comprueba que la posicion mas a la izq esta en la misma fila

			if ((pos_ini - 1) / c == fila && pos_ini - 1 >= 0) {
				pos_ini = pos_ini - 1;
			}
			//se comprueba que la posicion mas a la dere esta en la misma fila
			if (col_final / c == fila) {
				col_final = col_final + 1;
			}
		}
		//printf("\nPosicion inicial1: %d", pos_ini);
		for (int i = 0; i < 4; i++) {
			//printf("\nPOS: %d %d", pos_ini, fila);
			//se comprueba que la posicion mas abajo esta dentro del tablero
			if (pos_ini / c == f - 1) {
				pos_ini = pos_ini;
			}
			else {
				pos_ini = pos_ini + c;
			}
			//se calcula cual es la fila inicial
			if (fil_inicial / c == 0) {
				fil_inicial = fil_inicial;
			}
			else {
				fil_inicial = fil_inicial - c;
			}
		}
		//printf("\nPosicion inicial: %d", pos_ini);

		//se tiene que comprobar cual es la diferencia entre la menor fila a la que puede llegar al explosion y a la mas arriba que puede, ese sera el numero del for
		int fila_ult = pos_ini / c;
		int diferencia_fila = fila_ult - (fil_inicial / c);
		//se comprueba en que columna empieza y cual acaba
		int col_primera = pos_ini % c;
		//printf("\nColumnas: %d %d",col_final%c, col_primera);
		int diferencia_columna = abs((col_final % c) - col_primera);

		//printf("\ndiferencia_fila: %d", diferencia_fila);
		//printf("\ndiferencia_columna: %d", diferencia_columna);

		int col_restar = c * diferencia_fila;

		//Se intercambian los valores de arriba de la explosion del TNT en las posiciones que se han explotado
		for (int i = 0; i < diferencia_columna + 1; i++) {
			for (int j = 0; j < diferencia_fila + 1; j++) {
				//printf("\nFilaa: %d", pos_ini - (c * j) + i);
				//printf("Cambio: %d ", pos_ini - ((c * (j + 1)) + col_restar) + i);
				dev_R[pos_ini - (c * j) + i] = dev_R[pos_ini - ((c * (j + 1)) + col_restar) + i];
			}

		}
		//se calcula cuantos elemenos de la fila se ponen de forma alearoia
		//int huecos_aleatorios = c-col_primera;
		int huecos_aleatorios = 0;
		int nueva_col_primera = col_primera;
		for (int i = 0; i < 9; i++) {
			//printf("\ncool: %d", nueva_col_primera);
			//printf("\nhuecos: %d", huecos_aleatorios);
			if (huecos_aleatorios < c - 1 && huecos_aleatorios <= 4 + columna && nueva_col_primera + 1 <= c) {
				huecos_aleatorios = huecos_aleatorios + 1;
				nueva_col_primera = nueva_col_primera + 1;

			}
		}

		//se cambiam las filas de arriba por valores aleatorios
		//printf("\nhuecos: %d", huecos_aleatorios);
		//printf("\nfilas: %d", diferencia_fila + 1);
		for (int i = 0; i < huecos_aleatorios; i++) {
			for (int j = 0; j < diferencia_fila + 1; j++) {
				//printf("\nPossiciones nuevas: %d", col_primera + (c * j) + i);

				if (dificultad == 1) {
					dev_R[col_primera + (c * j) + i] = 1 + (int)(curand_uniform(estado) * 4);
				}
				else {
					dev_R[col_primera + (c * j) + i] = 1 + (int)(curand_uniform(estado) * 6);
				}
			}
		}
		*explosion += 1;
	}

}




__device__ int* asignarAleatorios(int* dev_R, int pos, int pos2, int pos3, int pos4, int pos5, int n, int dificultad, curandState* estado) {

	/*
	dev_R[pos + 1] = 1 + (int)(curand_uniform(estado) * n);
	dev_R[pos + 2] = 1 + (int)(curand_uniform(estado) * n);
	dev_R[pos + 3] = 1 + (int)(curand_uniform(estado) * n);
	*/
	if (dificultad == 1) {
		dev_R[pos2] = 1 + (int)(curand_uniform(estado) * 4);
		dev_R[pos3] = 1 + (int)(curand_uniform(estado) * 4);
		dev_R[pos4] = 1 + (int)(curand_uniform(estado) * 4);
		dev_R[pos5] = 1 + (int)(curand_uniform(estado) * 4);
	}
	else {
		dev_R[pos2] = 1 + (int)(curand_uniform(estado) * 6);
		dev_R[pos3] = 1 + (int)(curand_uniform(estado) * 6);
		dev_R[pos4] = 1 + (int)(curand_uniform(estado) * 6);
		dev_R[pos5] = 1 + (int)(curand_uniform(estado) * 6);
	}
	return dev_R;
}

__device__ int* gravedad_vertical_bomba(int* dev_R, int f, int c, int fila, int* arr_adyacente, int n, int dificultad, curandState* estado) {
	
	int pos = arr_adyacente[0];
	int pos2 = arr_adyacente[1];
	int pos3 = arr_adyacente[2];
	int pos4 = arr_adyacente[3];
	int pos5 = arr_adyacente[4];
	curand_init(1234, pos, 0, estado);
	//se obtiene cuando comienza los 4 numeros adyancentes
	int fila_ini = pos / c;
	//se obtiene en que fila termina los cuatro repetidos
	int fila_ult = pos5 / c;
	//se obtiene cuantos huecos se tienen que poner de forma aleatoria
	int filas_aleatorio = f - (fila_ult - fila_ini);
	//printf("\nHuecos: %d", filas_aleatorio);
	//se obtiene cual es la columna en la que iteramos
	int primera_columna = pos % c;

	//Se comprueba si hay alguna posicion que esta en la primera fila.
	//Si la hay no gravedad y se asignan los valores aleatorio.
	if (pos / c == 0 || pos2 / c == 0 || pos3 / c == 0 || pos4 / c == 0 || pos5 / c == 0) {

		dev_R = asignarAleatorios(dev_R, pos, pos2, pos3, pos4, pos5, n, dificultad, estado);
		dev_R[pos] = -1;
	}
	else {
		//Cambia los numeros repetidos por los de arriba
		for (int i = 0; i < fila; i++) {
			//printf("\niteraciones1: %d", i);
			dev_R[pos4 - (c * i)] = dev_R[pos - (c * (i + 1))];
		}
		//Cambia los valores de arriba por valores aleatorios
		for (int i = 0; i < fila_ini-1; i++) {
			if (dificultad == 1) {
				dev_R[primera_columna + (c * i)] = 1 + (int)(curand_uniform(estado) * 4);
			}
			else {
				dev_R[primera_columna + (c * i)] = 1 + (int)(curand_uniform(estado) * 6);
			}

			
		}
		dev_R[pos5] = -1;
	}

	return dev_R;


}

__device__ int* gravedad_horizontal_bomba(int* dev_R, int f, int c, int fila, int* arr_adyacente, int n, int dificultad, curandState* estado) {
	//fila actual de la posicion
	//int fila_actual = pos/c;

	int pos = arr_adyacente[0];
	int pos2 = arr_adyacente[1];
	int pos3 = arr_adyacente[2];
	int pos4 = arr_adyacente[3];
	int pos5 = arr_adyacente[4];

	if (fila == 0) {
		dev_R = asignarAleatorios(dev_R, pos, pos2, pos3, pos4, pos5, n, dificultad, estado);
		dev_R[pos] = -1;
	}
	else {

		for (int i = 0; i < fila; i++) {
			//dev_R[pos-(c*i)] = dev_R[pos-(c*(i+1))];
			dev_R[pos2 - (c * i)] = dev_R[pos2 - (c * (i + 1))];
			dev_R[pos3 - (c * i)] = dev_R[pos3 - (c * (i + 1))];
			dev_R[pos4 - (c * i)] = dev_R[pos4 - (c * (i + 1))];
			dev_R[pos5 - (c * i)] = dev_R[pos5 - (c * (i + 1))];
		}
		//Introduce los valores aleatoros de la primera fila
		dev_R = asignarAleatorios(dev_R, pos % c, pos2 % c, pos3 % c, pos4 % c, pos5 % c, n, dificultad, estado);
		dev_R[pos] = -1;
	}

	return dev_R;
}


//se busca donde haya cuatro elementos iguales, tanto en posiciones horizontales como verticales y se pone la bomba
//se tiene que guardar si es columna o fila, para despues explotar

//---------Método que pone la bomba donde haya 5 elementos iguales, indicados por el usuario.---------
__global__ void ponerBomba(int* dev_R, int c, int f, int size, int fila, int columna, int* bomba, int n, int dificultad, curandState* estado) {
	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;

	//posicion de la matriz final 
	int pos = fil * c + col;

	//posicion indicada por el usuario
	int posUsuario = fila * c + columna;
	int filaUsuario = posUsuario / c;

	//Array que contendra las posiciones adyacentes y el valor de cada posicion 
	__shared__ int valor[1];
	__shared__ int arr_adyacente[4];


	///
	//comprueba que se esta en la pos en la que esta interactuando el usuario
	if (pos == posUsuario) {

		valor[0] = dev_R[pos];
		valor[1] = pos;
		arr_adyacente[0] = pos;

	}

	__syncthreads();

	if (pos != posUsuario && valor[1] + 1 == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - 1] && valor[0] == dev_R[pos + 1] && valor[0] == dev_R[pos + 2] && valor[0] == dev_R[pos + 3] && pos / c == fila && (pos + 1) / c == fila && (pos + 2) / c == fila && (pos + 3) / c == fila) {
		printf("Bomba Puesta \n");
		arr_adyacente[0] = pos - 1; arr_adyacente[1] = pos; arr_adyacente[2] = pos + 1; arr_adyacente[3] = pos + 2; arr_adyacente[4] = pos + 3;
		dev_R = gravedad_horizontal_bomba(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*bomba += 1;

	}

	if (pos != posUsuario && valor[1] + 1 == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - 2] && valor[0] == dev_R[pos - 1] && valor[0] == dev_R[pos + 1] && valor[0] == dev_R[pos + 2] && (pos - 1) / c == fila && (pos + 1) / c == fila && (pos + 2) / c == fila) {
		printf("Bomba Puesta \n");
		arr_adyacente[0] = pos - 1; arr_adyacente[1] = pos; arr_adyacente[2] = pos - 2; arr_adyacente[3] = pos + 1; arr_adyacente[4] = pos + 2;
		dev_R = gravedad_horizontal_bomba(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*bomba += 1;

	}
	if (pos != posUsuario && valor[1] + 1 == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - 3] && valor[0] == dev_R[pos - 2] && valor[0] == dev_R[pos - 1] && valor[0] == dev_R[pos + 1] && (pos - 2) / c == fila && (pos - 1) / c == fila && (pos + 1) / c == fila) {
		printf("Bomba Puesta \n");
		arr_adyacente[0] = pos - 1; arr_adyacente[1] = pos; arr_adyacente[2] = pos - 3; arr_adyacente[3] = pos - 2; arr_adyacente[4] = pos + 1;
		dev_R = gravedad_horizontal_bomba(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*bomba += 1;

	}
	if (pos != posUsuario && valor[1] + 1 == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - 4] && valor[0] == dev_R[pos - 3] && valor[0] == dev_R[pos - 2] && valor[0] == dev_R[pos - 1] && (pos - 3) / c == fila && (pos - 2) / c == fila && (pos - 1) / c == fila) {
		printf("Bomba Puesta \n");
		arr_adyacente[0] = pos - 1; arr_adyacente[1] = pos; arr_adyacente[2] = pos - 4; arr_adyacente[3] = pos - 3; arr_adyacente[4] = pos - 2;
		dev_R = gravedad_horizontal_bomba(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*bomba += 1;

	}
	if (valor[1] == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - 4] && valor[0] == dev_R[pos - 3] && valor[0] == dev_R[pos - 2] && valor[0] == dev_R[pos - 1] && (pos - 3) / c == fila && (pos - 2) / c == fila && (pos - 1) / c == fila) {
		printf("Bomba Puesta \n");
		arr_adyacente[0] = pos; arr_adyacente[1] = pos - 1; arr_adyacente[2] = pos - 2; arr_adyacente[3] = pos - 3; arr_adyacente[4] = pos - 4;
		dev_R = gravedad_horizontal_bomba(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*bomba += 1;

	}

	//En vertical
	//compruba que los 3 elementos de arriba tienen el mismo valor
	if (pos != posUsuario && valor[1] + c == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - c] && valor[0] == dev_R[pos + c] && valor[0] == dev_R[pos + (c * 2)] && valor[0] == dev_R[pos + (c * 3)]) {
		printf("Bomba Puesta \n");
		arr_adyacente[0] = pos - c; arr_adyacente[1] = pos; arr_adyacente[2] = pos + c; arr_adyacente[3] = pos + (c * 2); arr_adyacente[4] = pos + (c * 3);
		dev_R = gravedad_vertical_bomba(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*bomba += 1;

	}
	else if (pos != posUsuario && valor[1] + c == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - (c * 2)] && valor[0] == dev_R[pos - c] && valor[0] == dev_R[pos + c] && valor[0] == dev_R[pos + (c * 2)]) {
		printf("Bomba Puesta \n");
		arr_adyacente[0] = pos - (c * 2); arr_adyacente[1] = pos - c; arr_adyacente[2] = pos; arr_adyacente[3] = pos + c; arr_adyacente[4] = pos + (c * 2);
		dev_R = gravedad_vertical_bomba(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*bomba += 1;

	}
	else if (pos != posUsuario && valor[1] + c == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - (c * 3)] && valor[0] == dev_R[pos - (c * 2)] && valor[0] == dev_R[pos - c] && valor[0] == dev_R[pos + c]) {
		printf("Bomba Puesta \n");
		arr_adyacente[0] = pos - (c * 3); arr_adyacente[1] = pos - (c * 2); arr_adyacente[2] = pos - c; arr_adyacente[3] = pos; arr_adyacente[4] = pos + c;
		dev_R = gravedad_vertical_bomba(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*bomba += 1;

	}
	else if (pos != posUsuario && valor[1] + c == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - (c * 4)] && valor[0] == dev_R[pos - (c * 3)] && valor[0] == dev_R[pos - (c * 2)] && valor[0] == dev_R[pos - c]) {
		printf("Bomba Puesta \n");
		arr_adyacente[0] = pos - (c * 4); arr_adyacente[1] = pos - (c * 3); arr_adyacente[2] = pos - (c * 2); arr_adyacente[3] = pos - c; arr_adyacente[4] = pos;
		dev_R = gravedad_vertical_bomba(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*bomba += 1;

	}
	else if (pos != posUsuario && valor[1] - c == pos && valor[0] == dev_R[pos] && valor[0] == dev_R[pos - (c * 3)] && valor[0] == dev_R[pos - (c * 2)] && valor[0] == dev_R[pos - (c * 1)] && valor[0] == dev_R[pos + c]) {
		printf("Bomba Puesta \n");
		arr_adyacente[0] = pos - (c * 3); arr_adyacente[1] = pos - (c * 2); arr_adyacente[2] = pos - (c * 1); arr_adyacente[3] = pos; arr_adyacente[4] = pos + c;
		dev_R = gravedad_vertical_bomba(dev_R, f, c, fila, arr_adyacente, n, dificultad, estado);
		*bomba += 1;
	}
	__syncthreads();

}

__global__ void explotarBomba(int* dev_R, int c, int f, int size, int fila, int columna, int n, int* explosion, int dificultad, curandState* estado) {
	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;

	//posicion de la matriz 
	int pos = fil * c + col;
	//posicion indicada por el usuario
	int posUsuario = fila * c + columna;
	//posicion de comienzo de la fila (fila por columnas totales de la matriz)
	int ini_fila = fila * c;
	//posicion de comienzo de la columna (columna por filas totales de la matriz)
	int ini_columna = columna * c;
	//numero aleatorio entre 0 y 1 que indica si se explota la fila o la columna
	//int f_c = rand() % 2;
	int f_c = 0;

	curand_init(1234, pos, 0, estado);


	if (pos == posUsuario && dev_R[pos] == -1) {
		//explota fila
		printf("\n [Informacion] Se explota la bomba\n");
		if (f_c == 0) {
			printf("Se genera una nueva fila y caen las demas: \n");
			//se cambian las cada una de las posiciones por la de arriba
			for (int i = 0; i < c; i++) {
				for (int j = 0; j < fila; j++) {
					//printf("\nFilaa: %d",ini_fila-(c*j)+ i);
					//printf("Cambio: %d ",ini_fila-(c*(j+1))+ i );
					dev_R[ini_fila - (c * j) + i] = dev_R[ini_fila - (c * (j + 1)) + i];
				}
			}
			//se cambia la primera fila por valores aleatorios
			for (int i = 0; i < c; i++) {
				
				if (dificultad == 1) {
					dev_R[0 + i] = 1 + (int)(curand_uniform(estado) * 4);
				}
				else {
					dev_R[0 + i] = 1 + (int)(curand_uniform(estado) * 6);
				}
			}

		}
		else {
			printf("Se genera una nueva columna: \n");
			//explota la columna
			//se cambia toda esa columna por valores aleatorios
			for (int i = 0; i < f; i++) {
				if (dificultad == 1) {
					dev_R[ini_columna + (c * i)] = 1 + (int)(curand_uniform(estado) * 4);
				}
				else {
					dev_R[ini_columna + (c * i)] = 1 + (int)(curand_uniform(estado) * 6);
				}
			}
		}
		*explosion += 1;
	}
}



//Chequea si hay elementos adyacentes con el mismo valor en toda la matriz, si es asi, los cambia por valores aleatorios
__global__ void comprobarPares(int* dev_R, int c, int f, int size, int fila, int columna, int* par, int dificultad, curandState* estado) {
	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;

	//posicion de la matriz final 
	int pos = fil * c + col;
	//posicion indicada por el usuario
	int posUsuario = fila * c + columna;

	//Numeros aleatorios
	curand_init(1234, pos, 0, estado);

	//Array que contendrá las posiciones adyacentes
	__shared__ int valor[2];
	__shared__ int arr_adyacente[2];

	if (pos == posUsuario) {
		valor[0] = dev_R[pos];
		valor[1] = pos;
		arr_adyacente[0] = pos;
	}
	__syncthreads();
	//Comprobar arriba
	if ((valor[1]-c) == (pos) && valor[0] == dev_R[pos] && pos != posUsuario) {
		arr_adyacente[1] = pos;
		*par += 1;
	}
	//Comprobar abajo
	else if ((valor[1] + c) == (pos) && valor[0] == dev_R[pos] && pos != posUsuario) {
		arr_adyacente[1] = pos;
		*par += 1;
	}
	//Comprobar derecha
	else if ((valor[1] + 1) == (pos) && valor[0] == dev_R[pos] && pos != posUsuario) {
		arr_adyacente[1] = pos;
		*par += 1;
	}
	//Comprueba izquierda
	else if ((valor[1] - 1) == (pos) && valor[0] == dev_R[pos] && pos != posUsuario) {
		arr_adyacente[1] = pos;
		*par += 1;
	}
	__syncthreads();

	
	if (fil < f && col < c && pos == posUsuario && (dev_R[arr_adyacente[1]] == 1 || dev_R[arr_adyacente[1]] == 2 || dev_R[arr_adyacente[1]] == 3 || dev_R[arr_adyacente[1]] == 4 || dev_R[arr_adyacente[1]] == 5 || dev_R[arr_adyacente[1]] == 6)) {
		//Arriba
		if (pos == arr_adyacente[1] + c) {
			int nuevo_f0 = 0; //Valor Declarativo
			int nuevo_f1 = 0; //Valor Declarativo
			//printf("\nSe añaden los valores: ");
			if (dificultad == 1) { //Coge aleatorios los nuevos valores de la fila 0 y fila 1
				nuevo_f0 = 1 + (int)(curand_uniform(estado) * 4);
				nuevo_f1 = 1 + (int)(curand_uniform(estado) * 4);
			}
			else {
				nuevo_f0 = 1 + (int)(curand_uniform(estado) * 6);
				nuevo_f1 = 1 + (int)(curand_uniform(estado) * 6);
			}
			int kAux = 2;
			int kFinal = 0;
			for (int k = 0; k < fila - 1; k++) { //Rellena todos los valores de la columna por gravedad
				dev_R[pos - (c * k)] = dev_R[pos - (c * kAux)];
				kAux++;
				//printf("%d ", dev_R[pos - (c * k)]);
				kFinal = k;
			}
			kFinal++;
			dev_R[pos - (c * kFinal)] = nuevo_f1; //Rellena valor de la fila 1
			//printf("%d ", dev_R[pos - (c * kFinal)]);
			kFinal++;
			dev_R[pos - (c * kFinal)] = nuevo_f0; //Rellena valor de la fila 0
			//printf("%d\n", dev_R[pos - (c * kFinal)]);

			*par += 1;
		}
		//Abajo
		else if (pos == arr_adyacente[1] - c) {
			int nuevo_f0 = 0; //Valor Declarativo
			int nuevo_f1 = 0; //Valor Declarativo
			//printf("\nSe añaden los valores: ");
			if (dificultad == 1) { //Coge aleatorios los nuevos valores de la fila 0 y fila 1
				nuevo_f0 = 1 + (int)(curand_uniform(estado) * 4);
				nuevo_f1 = 1 + (int)(curand_uniform(estado) * 4);
			}
			else {
				nuevo_f0 = 1 + (int)(curand_uniform(estado) * 6);
				nuevo_f1 = 1 + (int)(curand_uniform(estado) * 6);
			}
			if (fila == 0) { //Si el item examinado esta en la fila 0, solo hay que generar aleatoriamente los valores de f0 y f1.
				dev_R[pos] = nuevo_f0;
				dev_R[pos + c] = nuevo_f1;
				//printf("%d ", dev_R[pos]);
				//printf("%d ", dev_R[pos + c]);
			}
			else { //Si el item examinado NO esta en la fila 0, hay que generar aleatoriamente los valores de f0 y f1 y el resto por gravedad.
				pos = pos + c; //Para que se comporte como el algortimo que aplica gravedad arriba
				int kAux = 2;
				int kFinal = 0;
				for (int k = 0; k < fila; k++) { //Rellena todos los valores de la columna por gravedad
					dev_R[pos - (c * k)] = dev_R[pos - (c * kAux)];
					kAux++;
					//printf("%d ", dev_R[pos - (c * k)]);
					kFinal = k;
				}
				kFinal++;
				dev_R[pos - (c * kFinal)] = nuevo_f1; //Rellena valor de la fila 1
				//printf("%d ", dev_R[pos - (c * kFinal)]);
				kFinal++;
				dev_R[pos - (c * kFinal)] = nuevo_f0; //Rellena valor de la fila 0
				//printf("%d\n", dev_R[pos - (c * kFinal)]);
			}
			*par += 1;
		}
		//Izquierda y derecha
		else if (pos == arr_adyacente[1] + 1 || pos == arr_adyacente[1]-1) {
			for (int i = 0; i < fila; i++) {
				dev_R[pos - (c * i)] = dev_R[pos - c * (i + 1)];
				dev_R[arr_adyacente[1] - (c * i)] = dev_R[arr_adyacente[1] - (c * (i + 1))];
				if (i == fila - 1) {
					if (dificultad == 1) {
						dev_R[pos - (c * (i+1))] = 1 + (int)(curand_uniform(estado) * 4);
						dev_R[arr_adyacente[1] - (c * (i + 1))] = 1 + (int)(curand_uniform(estado) * 4);
					}
					else {
						dev_R[pos - (c * (i + 1))] = 1 + (int)(curand_uniform(estado) * 6);
						dev_R[arr_adyacente[1] - (c * (i + 1))] = 1 + (int)(curand_uniform(estado) * 6);
					}
				}

			}
			par += 1;
		}
				
	}
	__syncthreads();
	
}

__global__ void comprobarRompecabezas(int* dev_R, int c, int f, int size, int fila, int columna, int* rompe, int dificultad, curandState* estado) {
	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;

	//posicion de la matriz final 
	int pos = fil * c + col;
	//posicion indicada por el usuario
	int posUsuario = fila * c + columna;

	//Numeros aleatorios
	curand_init(1234, pos, 0, estado);

	int encontrado = 0;
	__shared__ int list_pos[6];
	__shared__ int list_pos2[6];
	if (pos == posUsuario) {
		//Rompecabezas en fila
		if (encontrado == 0) {
			int cumple_condicion = 1; //tiene que ser 7 para cumplir
			int pos_aux = pos + 1;
			int arr_aux = 0;
			//Cuenta cuantos bloques del mismo color tiene a la derecha
			while (dev_R[pos] == dev_R[pos_aux] && cumple_condicion < 7 && pos_aux < (((c + 1) * fila) + c + 1)) {
				list_pos[arr_aux] = pos_aux;
				pos_aux++;
				cumple_condicion++;
				arr_aux++;
			}
			__syncthreads();
			pos_aux = pos - 1;
			//Cuenta cuantos bloques del mismo color tiene a la izquierda
			while (dev_R[pos] == dev_R[pos_aux] && cumple_condicion < 7 && pos_aux >= (c * fila)) {
				list_pos[arr_aux] = pos_aux;
				pos_aux--;
				cumple_condicion++;
				arr_aux++;
			}
			__syncthreads();
			//Ha encontrado un rompecabezas y hay que ponerlos
			if (cumple_condicion == 7) {
				//gravedad si el rompecabezas esta en la fila 0
				if (fila == 0) {
					dev_R[pos] = -3;
					for (int k = 0; k < 6; k++) {
						if (dificultad == 1) {
							dev_R[list_pos[k]] = 1 + (int)(curand_uniform(estado) * 4);
						}
						else {
							dev_R[list_pos[k]] = 1 + (int)(curand_uniform(estado) * 6);
						}
					}
					__syncthreads();
				}
				//Gravedad si el rompecabezas esta en la fila != 0
				else {
					dev_R[pos] = -3;
					//Iteraciones que va a tener que hacer sobre las diferentes filas para cambiar los bloques
					for (int k = 0; k < fila; k++) {
						for (int m = 0; m < 6; m++) {
							dev_R[list_pos[m] - (c * k)] = dev_R[list_pos[m] - (c * (k + 1))];
						}
						__syncthreads();
						//Rellena primera fila de aleatorios
						if (k == fila - 1) {
							for (int m = 0; m < 6; m++) {
								if (dificultad == 1) {
									dev_R[list_pos[m] - (c * (k + 2))] = 1 + (int)(curand_uniform(estado) * 4);
								}
								else {
									dev_R[list_pos[m] - (c * (k + 2))] = 1 + (int)(curand_uniform(estado) * 6);
								}
							}
						}
						__syncthreads();
					}
				}
				encontrado = 1;
				*rompe += 1;
			}
		}
		//Rompecabezas en columna
		if (encontrado == 0) {
			int lista_ordenada[7];
			int cumple_condicion = 1; //tiene que ser 7 para cumplir
			int pos_aux = pos - c;
			int arr_aux = 0;
			//Cuenta bloques arriba
			while (dev_R[pos] == dev_R[pos_aux] && cumple_condicion < 7 && pos_aux > 0) {
				list_pos2[arr_aux] = pos_aux;
				pos_aux -= c;
				cumple_condicion++;
				arr_aux++;
			}
			__syncthreads();
			//Cuenta bloques abajo
			pos_aux = pos + c;
			while (dev_R[pos] == dev_R[pos_aux] && cumple_condicion < 7 && pos_aux < (f * c)) {
				list_pos2[arr_aux] = pos_aux;
				pos_aux += c;
				cumple_condicion++;
				arr_aux++;
			}
			__syncthreads();
			//Cumple condidicion
			if (cumple_condicion == 7) {
				for (int k = 0; k < 6; k++) {
					lista_ordenada[k] = list_pos2[k];
				}
				__syncthreads();
				lista_ordenada[6] = pos;

				for (int i = 0; i < 6; i++) {
					for (int j = 0; j < 6 - i; j++) {
						if (lista_ordenada[j] > lista_ordenada[j + 1]) {
							int temp = lista_ordenada[j];
							lista_ordenada[j] = lista_ordenada[j + 1];
							lista_ordenada[j + 1] = temp;
						}
					}
				}
				dev_R[lista_ordenada[6]] = -3;
				//Rellenar todo de numeros aleatorios
				if (lista_ordenada[0] <= c) {
					if (dificultad == 1) {
						dev_R[lista_ordenada[0]] = 1 + (int)(curand_uniform(estado) * 4);
						dev_R[lista_ordenada[1]] = 1 + (int)(curand_uniform(estado) * 4);
						dev_R[lista_ordenada[2]] = 1 + (int)(curand_uniform(estado) * 4);
						dev_R[lista_ordenada[3]] = 1 + (int)(curand_uniform(estado) * 4);
						dev_R[lista_ordenada[4]] = 1 + (int)(curand_uniform(estado) * 4);
						dev_R[lista_ordenada[5]] = 1 + (int)(curand_uniform(estado) * 4);
					}
					else {
						dev_R[lista_ordenada[0]] = 1 + (int)(curand_uniform(estado) * 6);
						dev_R[lista_ordenada[1]] = 1 + (int)(curand_uniform(estado) * 6);
						dev_R[lista_ordenada[2]] = 1 + (int)(curand_uniform(estado) * 6);
						dev_R[lista_ordenada[3]] = 1 + (int)(curand_uniform(estado) * 6);
						dev_R[lista_ordenada[4]] = 1 + (int)(curand_uniform(estado) * 6);
						dev_R[lista_ordenada[5]] = 1 + (int)(curand_uniform(estado) * 6);
					}
				}
				//Aplicar gravedad
				else {
					int posicionAux;
					posicionAux = lista_ordenada[0] - c;
					int iteraciones = 0;
					int iterador = 5;
					while (posicionAux > 0) {
						dev_R[lista_ordenada[iterador]] = dev_R[posicionAux];
						iteraciones += 1;
						posicionAux -= c;
						iterador -= 1;
					}
					for (int k = 0; k <= iterador; k++) {
						if (dificultad == 1) {
							dev_R[lista_ordenada[k]] = 1 + (int)(curand_uniform(estado) * 4);
						}
						else {
							dev_R[lista_ordenada[k]] = 1 + (int)(curand_uniform(estado) * 6);
						}
					}
					int posicionAux2;
					posicionAux2 = lista_ordenada[0] - c;
					while (posicionAux2 > 0) {
						if (dificultad == 1) {
							dev_R[posicionAux2] = 1 + (int)(curand_uniform(estado) * 4);
						}
						else {
							dev_R[posicionAux2] = 1 + (int)(curand_uniform(estado) * 6);
						}
						posicionAux2 -= c;
					}

				}
				encontrado = 1;
				*rompe += 1;
			}
		}
	}
	
}

__global__ void explotarRompecabezas(int* dev_R, int c, int f, int size, int fila, int columna, int* rompe, int dificultad, curandState* estado) {
	//declaramos las col y filas
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;

	//posicion de la matriz final 
	int pos = fil * c + col;
	//posicion indicada por el usuario
	int posUsuario = fila * c + columna;

	//Numeros aleatorios
	curand_init(1234, pos, 0, estado);

	int numero_quitar;
	if (dificultad == 1) {
		numero_quitar = 1 + (int)(curand_uniform(estado) * 4);
	}
	else {
		numero_quitar = 1 + (int)(curand_uniform(estado) * 6);
	}
	
	if (pos == posUsuario && dev_R[pos] == -3) {
		printf("\nExplotando el Rompecabezas con el color: %d \n", numero_quitar);
		//LO PRIMERO ES QUITAR EL BLOQUE ROMPECABEZAS Y APLICAR GRAVEDAD
		int ff = 0;
		for (int s = pos; s > c; s= s - c) {
			dev_R[s] = dev_R[s - c];
			ff = s;
		}
		if (dificultad == 1) {
			dev_R[ff-c] = 1 + (int)(curand_uniform(estado) * 4);
		}
		else {
			dev_R[ff-c] = 1 + (int)(curand_uniform(estado) * 6);
		}
		*rompe += 1;
		//for (int k=1; k <= c; k++) { CAMBIAR
		for (int k=1; k <= c; k++) {
			int valor_inicio = f * c - k;
			if (valor_inicio - c < 0) {//Solo hay una fila, asi que se pone aleatorio
				if (dificultad == 1) {
					dev_R[valor_inicio] = 1 + (int)(curand_uniform(estado) * 4);
				}
				else {
					dev_R[valor_inicio] = 1 + (int)(curand_uniform(estado) * 6);
				}
			}
			else { //Hay mas de de una fila, hay que evaluar valor a valor la columna
				int valor_evaluado = valor_inicio;
				int flag = 0;
				while (valor_evaluado > 0 && flag == 0) { //Se evaluan todos los valores, empezando desel el primero de la columna
					if (valor_evaluado < c) { //Se esta evaluando el ultimo valor
						if (dev_R[valor_evaluado] == numero_quitar) {//Si el ultimo  valor, coincide con el que se quiere quitar, se pone uno aleatorio. Si no lo es, no hace nada
							if (dificultad == 1) {
								dev_R[valor_evaluado] = 1 + (int)(curand_uniform(estado) * 4);
							}
							else {
								dev_R[valor_evaluado] = 1 + (int)(curand_uniform(estado) * 6);
							}
						}
					}
					else {//No se esta evaluando el ultimo valor
						if (dev_R[valor_evaluado] == numero_quitar) {//Si el valor evaluado, coincide con el que se quiere quitar... .Si no lo es, no hace nada
							//hay que coger el valor que tiene encima. Opciones: 1-El que tenga encima hay que quitarlo. 2- El que tenga encima no hay que quitarlo. Se va  ahacer un bucle que se romperá con un brake para saber qué 
							//tiene encima. Si o si va a haber gravedad.
							int valor_referencia = valor_evaluado - c; //Posicion de la matriz que se tendrá como referencia para coger su valor y aplicar gravedad
							int randoms_a_poner = 0;
							while (true) {
								if (dev_R[valor_referencia] == numero_quitar) { //Si el numero que se toma como referencia, se va a quitar a posteriori, se cogerá su valor de encima.
									valor_referencia -= c; //Para que siga avanzando por el bucle
									if (valor_referencia < 0) { //No se ha encontrado un valor de referencia, por lo que toda la fila es de numeros iguales y hay que meter todo randoms
										for (int j = valor_evaluado; j > 0; j = j - c) { //Pone a randoms todos los valores desde el evaluado hasta el final
											if (dificultad == 1) {
												dev_R[j] = 1 + (int)(curand_uniform(estado) * 4);
											}
											else {
												dev_R[j] = 1 + (int)(curand_uniform(estado) * 6);
											}
										}
										flag = 1;
										break;
									}
									randoms_a_poner += 1;
								}
								else {//Si el valor de referencia no se va a quitar, rompe el bucle, ya que ya se sabe su posicion
									randoms_a_poner += 1;
									break;
								}
							}
							//APLICAR GRAVEDAD a partir dle valor de referencia Y FLAG == 0
							if (flag == 0) { //Si no se ha llenado toda la fila de randoms, tomar el valor de VALOR_REFERENCIA para aplicar gravedad al VALOR_EVALUADO
								
								int evaluar_y_referencia = valor_evaluado; //Se usara como auxiliar para iterar desde el valor evaluado hasta el final
								for (int j = valor_referencia; j > 0; j = j - c) { //Va a aplicar gravedad a todos los valores desde el de referencia, excepto al primero, que ese siempre es aleatorio
									dev_R[evaluar_y_referencia] = dev_R[j];
									evaluar_y_referencia -= c;//Para que siga avanzando por los a apligar gravedad
								}
								int valor_columna_inicial = c - k; //Coge el valor inicial de la columna en base al numero de columnas y la iteracion en la que se encuentre k
								for (int g = 0; g < randoms_a_poner; g++) {//TIENE EN CUENTA CUANTOS VALORES HAY QUE METER ALEATORIOS, por cada numero saltado por ser igual, se pondra un numero aleaorio
									//Estos valores aleatorios iran en los primeros valores de la columna
									if (dificultad == 1) {
										dev_R[valor_columna_inicial] = 1 + (int)(curand_uniform(estado) * 4);
									}
									else {
										dev_R[valor_columna_inicial] = 1 + (int)(curand_uniform(estado) * 6);
									}
									valor_columna_inicial += c;
								}
							}
						}
					}
					valor_evaluado -= c;
				}
			}
		}
	}
}



int main(int argc, char** argv) {
	//------------------------------------- declaraciones de variables-------------------------------
	// 
	// 
	
	printf("Obtener las caracteristicas basicas de CUDA de tu tarjeta grafica.\n\n");
	int numDevices;
	cudaGetDeviceCount(&numDevices);
	int minimo_bloques;
	int minimo_hilos;

	for (int i = 0; i < numDevices; i++) {
		cudaDeviceProp prop;
		cudaGetDeviceProperties(&prop, i);

		printf("Nombre del Device: %s (Numero: %d)\n", prop.name, i);
		printf("Numero maximo de hilos por bloque: %d\n", prop.maxThreadsPerBlock);
		printf("Numero maximo de hilos en un SM: %d\n", prop.maxThreadsPerMultiProcessor);
		printf("Dimensiones maximas para organizar los hilos en bloques (x,y,z): (%d,%d,%d)\n", prop.maxThreadsDim[0], prop.maxThreadsDim[1], prop.maxThreadsDim[2]);
		printf("Dimensiones maximas para organizar los bloques en el grid (x,y,z): (%d,%d,%d)\n\n", prop.maxGridSize[0], prop.maxGridSize[1], prop.maxGridSize[2]);

		minimo_bloques = prop.maxGridSize[0];

		if (minimo_bloques > prop.maxGridSize[1]) {
			minimo_bloques = prop.maxGridSize[1];
		}
		
		minimo_hilos = prop.maxThreadsDim[0];
		if (minimo_hilos > prop.maxThreadsDim[1]) {
			minimo_hilos = prop.maxThreadsDim[1];
		}

	}

	//Seed para la generacion de numero aleatorios.
	srand(time(NULL));

	curandState* d_estado;
	cudaMalloc(&d_estado, sizeof(curandState));

	//Para el while, si es distnto a -1 se termina el juego
	int vidas = 5;

	//Se instancia las variables que nos indica si se ha realizado algun kernel
	int bomba, par, TNT, rompeCabezas, n, explosionB, automatico, f_comprobar, c_comprobar, explosionTNT, explosionCabezas;


	//llamadas a funciones
	cout << "Introduce el numero de filas de la matriz: ";
	int filas = pedirFilas();
	cout << "Introduce el numero de columnas de la matriz: ";
	int columnas = pedirColumnas();
	int dificultad = pedirDificultad();

	int minimo_filas_columnas = columnas;
	if (filas < minimo_filas_columnas) { minimo_filas_columnas = filas; }

	int minimo_global = 0;
	if (minimo_filas_columnas <= minimo_bloques) { minimo_global = minimo_filas_columnas; }
	else { minimo_global = minimo_bloques; }

	int blockSize = 0;
	double raiz = sqrt(minimo_global);
	double redondo = round(raiz);

	blockSize = (rand() % (int)redondo) + 1;

	int tamano = ceil((filas * columnas) / (blockSize * blockSize));
	int tamano_raiz = round(sqrt(tamano))+1;

	printf("Bloques Elegidos: %d, %d\n", blockSize, blockSize);
	printf("Hilos Elegidos: %d, %d\n", tamano_raiz, tamano_raiz);


	printf("dificultad %d", dificultad);

	if (dificultad == 1) {
		n = 5;
	}
	else {
		n = 7;
	}

	printf("\n[Informacion] Desea jugar de forma manual(0) o automatico(1) \n");
	scanf("%d", &automatico);

	//Instanciacion de la matriz host y resultante
	int size = filas * columnas;
	//int* h_matriz = (int*)malloc(size* sizeof(int));
	int* h_R = (int*)malloc(size * sizeof(int));

	//---------------------------------------------------------- GENERAR MATRIZ -------------------------------------------------------------
	//UNICO METODO GENERAR MATRIZ EN h_R - OBLIGATORIO
	generarMatriz(h_R, filas, columnas, dificultad, d_estado); // XXXXXXXXXX - USAAAAAAAAAAAAAAAAR
	//MATRIZ EJEMPLO
	/*
	int test_matriz[10][9]= {{1, 1, 1, 1, 1, 5, 5, 5, 5},
							 {2, 2, 2, 2, 2, 2, 6, 6, 6},
							 {3, 3, 1, 6, 1, 4, 3, 3, 3},
							 {4, 2, 4, 5, 1, 4, 4, 4, 4},
							 {1, 5, 4, 5, 1, 4, 5, 5, 5},
							 {1, 6, 1, 5, 1, 4, 6, 6, 6},
							 {1, 1, 1, 5, 1, 4, 1, 1, 1},
							 {1, 2, 1, 5, 1, 4, 2, 2, 3},
							 {1, 6, 6, 5, 6, 6, 6, 3, 4},
							 {1, 4, 4, 5, 4, 4, 4, 3, 4}};
	for (int i = 0; i < 10; i++) { // XXXXXXXXXX - BORRAR CUANDO NO SE QUIERA USAR UNA MATRIZ PREDEFINIDA DE EJEMPLO
		for (int j = 0; j < 9; j++) { // XXXXXXXXXX - BORRAR CUANDO NO SE QUIERA USAR UNA MATRIZ PREDEFINIDA DE EJEMPLO
			h_R[i * 9 + j] = test_matriz[i][j]; // XXXXXXXXXX - BORRAR CUANDO NO SE QUIERA USAR UNA MATRIZ PREDEFINIDA DE EJEMPLO
		} // XXXXXXXXXX - BORRAR CUANDO NO SE QUIERA USAR UNA MATRIZ PREDEFINIDA DE EJEMPLO
	} // XXXXXXXXXX - BORRAR CUANDO NO SE QUIERA USAR UNA MATRIZ PREDEFINIDA DE EJEMPLO*/
	//---------------------------------------------------------------------------------------------------------------------------------------
	
	//int h_matriz[] = { 1,1,1,1,0,2,4,2,3,3,2,1,2,3,0,0,1,1,2,3,1,2,1,3,3 };

	//instanciamos las variables del Device
	int* dev_R, * d_bomba, * d_par, * d_TNT, * d_rompeCabezas, * d_explosionB, * d_explosionTNT, *d_explosionCabezas;
	//int* dev_M; NO ES NECESARIO NO SE USA

	//Numero aleatorios ene la GPU
	

	//-------------------------------------cuestiones de memoria-------------------------------

	//cudaMalloc((void**)&dev_M, size * sizeof(int)); NO ES NECESARIO NO SE USA
	// Reservamos memoria en la GPU
	cudaMalloc((void**)&dev_R, size * sizeof(int));


	cudaMalloc((void**)&d_par, sizeof(int));
	cudaMalloc((void**)&d_bomba, sizeof(int));
	cudaMalloc((void**)&d_TNT, sizeof(int));
	cudaMalloc((void**)&d_rompeCabezas, sizeof(int));
	cudaMalloc((void**)&d_explosionB, sizeof(int));
	cudaMalloc((void**)&d_explosionTNT, sizeof(int));
	cudaMalloc((void**)&d_explosionCabezas, sizeof(int));

	// Copiamos los datos desde la memoria host a la memoria device
	cudaMemcpy(dev_R, h_R, size * sizeof(int), cudaMemcpyHostToDevice);


	//definimos el numero de bloques y hilos por bloque
	//dim3 numBloques(1);
	//dim3 ThreadsBloque(filas, filas);

	dim3 numBloques(blockSize, blockSize);
	dim3 ThreadsBloque(tamano_raiz, tamano_raiz);

	//Se copia la matriz inicial en la GPU - NO ES NECESARIO NO SE USA
	//copiarMatriz <<<numBloques, ThreadsBloque>>> (dev_M, dev_R, columnas); NO ES NECESARIO NO SE USA


	while (vidas > 0) {
		//se resetean los comprobadores
		bomba = 0, par = 0, TNT = 0, rompeCabezas = 0, explosionB = 0, explosionTNT = 0, explosionCabezas = 0;

		cudaMemcpy(d_par, &par, sizeof(int), cudaMemcpyHostToDevice);
		cudaMemcpy(d_bomba, &bomba, sizeof(int), cudaMemcpyHostToDevice);
		cudaMemcpy(d_explosionB, &explosionB, sizeof(int), cudaMemcpyHostToDevice);
		cudaMemcpy(d_TNT, &TNT, sizeof(int), cudaMemcpyHostToDevice);	
		cudaMemcpy(d_explosionTNT, &explosionTNT, sizeof(int), cudaMemcpyHostToDevice);
		cudaMemcpy(d_rompeCabezas, &rompeCabezas, sizeof(int), cudaMemcpyHostToDevice);
		cudaMemcpy(d_explosionCabezas, &explosionCabezas, sizeof(int), cudaMemcpyHostToDevice);

		cudaMemcpy(dev_R, h_R, size * sizeof(int), cudaMemcpyHostToDevice);

		//se imprime la matriz mostrando cada cambio
		imprimirMatriz2(h_R, columnas, filas);

		if (automatico == 0) {
			printf("\nIntroduce la fila que quiera comprobar: ");
			f_comprobar = pedirFilas();
			printf("\nIntroduce la columna que quiera comprobar: ");
			c_comprobar = pedirColumnas();
		}
		else {
			f_comprobar = rand() % filas;
			c_comprobar = rand() % columnas;

			printf("\nSe juega en la fila y columna: %d %d", f_comprobar, c_comprobar);
		}




		//------------------------------------- kernels -------------------------------

		//KERNEL-> EXPLOTAR ROMPECABEZAS
		explotarRompecabezas<<< numBloques, ThreadsBloque >>> (dev_R, columnas, filas, size, f_comprobar, c_comprobar, d_explosionCabezas, dificultad, d_estado);
		cudaMemcpy(&explosionCabezas, d_explosionCabezas, sizeof(int), cudaMemcpyDeviceToHost);
		if (explosionCabezas == 0) {
			comprobarRompecabezas << <numBloques, ThreadsBloque >> > (dev_R, columnas, filas, size, f_comprobar, c_comprobar, d_rompeCabezas, dificultad, d_estado);
			cudaMemcpy(&rompeCabezas, d_rompeCabezas, sizeof(int), cudaMemcpyDeviceToHost);
		}
		if (rompeCabezas == 0 && explosionCabezas == 0) {
			explotarTNT << <numBloques, ThreadsBloque >> > (dev_R, columnas, filas, size, f_comprobar, c_comprobar, n, d_explosionTNT, dificultad, d_estado);
			cudaMemcpy(&explosionTNT, d_explosionTNT, sizeof(int), cudaMemcpyDeviceToHost);
		}
		if (rompeCabezas == 0 && explosionCabezas == 0 && explosionTNT == 0) {
			ponerTNT << <numBloques, ThreadsBloque >> > (dev_R, columnas, filas, size, f_comprobar, c_comprobar, d_TNT, n, dificultad, d_estado);
			cudaMemcpy(&TNT, d_TNT, sizeof(int), cudaMemcpyDeviceToHost);
		}
		if (rompeCabezas == 0 && explosionCabezas == 0 && explosionTNT == 0 && TNT == 0) {
			explotarBomba << <numBloques, ThreadsBloque >> > (dev_R, columnas, filas, size, f_comprobar, c_comprobar, n, d_explosionB, dificultad, d_estado);
			cudaMemcpy(&explosionB, d_explosionB, sizeof(int), cudaMemcpyDeviceToHost);
		}
		if (rompeCabezas == 0 && explosionCabezas == 0 && explosionTNT == 0 && TNT == 0 && explosionB == 0) {
			ponerBomba << <numBloques, ThreadsBloque >> > (dev_R, columnas, filas, size, f_comprobar, c_comprobar, d_bomba, n, dificultad, d_estado);
			cudaMemcpy(&bomba, d_bomba, sizeof(int), cudaMemcpyDeviceToHost);
		}
		if (rompeCabezas == 0 && explosionCabezas == 0 && explosionTNT == 0 && TNT == 0 && explosionB == 0 && bomba == 0) {	
			comprobarPares << <numBloques, ThreadsBloque >> > (dev_R, columnas, filas, size, f_comprobar, c_comprobar, d_par, dificultad, d_estado);
			cudaMemcpy(&par, d_par, sizeof(int), cudaMemcpyDeviceToHost);
		}
	
		cudaMemcpy(h_R, dev_R, size * sizeof(int), cudaMemcpyDeviceToHost);

		if (par == 0 && bomba == 0 && TNT == 0 && rompeCabezas == 0 && explosionB == 0 && explosionTNT == 0 && explosionCabezas == 0) {
			printf("\n[Informacion] Se ha perdido una vida:\n");
			printf("\nNo se ha podido realizar ninguna accion en las coordenadas: %d %d\n", f_comprobar, c_comprobar);
			vidas = vidas - 1;
			printf("\nVidas restantes: %d\n", vidas);
		}


	}

	//---------------------------- Fin de la programacion paralela---------------------------------------
	// copiando el resultado a la memoria Host
	cudaMemcpy(h_R, dev_R, size * sizeof(int), cudaMemcpyDeviceToHost);



	printf("\nFin del Juego!!!!!\n");
	printf("**********************");
	printf("\n La matriz Resultante es:\n");
	imprimirMatriz2(h_R, columnas, filas);
	//cudaFree(dev_M);
	cudaFree(dev_R);

	cudaFree(d_bomba);
	cudaFree(d_par);
	cudaFree(d_TNT);
	cudaFree(d_rompeCabezas);


	return (EXIT_SUCCESS);
}