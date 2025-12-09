#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "Estructuras.h"

int main() {
	// TEST 1: Lista vacía
	lista_t lista_vacia;
	lista_vacia.head = NULL;
	uint32_t result1 = cantidad_total_de_elementos(&lista_vacia);
	assert(result1 == 0);

	// TEST 2: Lista con múltiples nodos
	// Crear arreglos para los nodos
	uint32_t arreglo1[] = {1, 2, 3, 4, 5};        // 5 elementos
	uint32_t arreglo2[] = {10, 20};               // 2 elementos  
	uint32_t arreglo3[] = {100, 200, 300};        // 3 elementos

	// Crear nodos
	nodo_t nodo3 = {NULL, 3, arreglo3, 3};        // último nodo
	nodo_t nodo2 = {&nodo3, 2, arreglo2, 2};     // segundo nodo
	nodo_t nodo1 = {&nodo2, 1, arreglo1, 5};     // primer nodo

	// Crear lista con múltiples nodos
	lista_t lista_multiple;
	lista_multiple.head = &nodo1;
	
	uint32_t result2 = cantidad_total_de_elementos(&lista_multiple);
	assert(result2 == 10);  // 5 + 2 + 3 = 10 elementos totales

	return 0;



}

