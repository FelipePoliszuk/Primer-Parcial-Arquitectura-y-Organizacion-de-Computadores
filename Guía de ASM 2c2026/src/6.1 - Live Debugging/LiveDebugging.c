#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "LiveDebugging.h"

// Ejercicio 1: Conteo de elementos filtrados 
int64_t procesar_registros2(registro_t* array, uint32_t len, int (*criterio)(uint32_t)){

	int64_t cantidad = 0;

	for (uint32_t i = 0; i < len; i++){
		
		uint32_t elemento = array[i].id;
		
		if (criterio(elemento) == 1){
			cantidad ++;
		}
		
	}
	

	return cantidad;
}

// Ejercicio 2: Clonación y filtrado con memoria dinámica
registro_t* clonar_filtrados2(registro_t* array, uint32_t len, int (*criterio)(uint32_t), uint32_t* out_len){

    *out_len = procesar_registros2(array,len, criterio);

    if (*out_len == 0){
        return NULL;
    }
    

    registro_t* clonado = malloc(sizeof(registro_t)*(*out_len));

    uint32_t j = 0;

	for (uint32_t i = 0; i < len; i++){
		
        registro_t *elemento = &array[i];
		

		if (criterio(elemento->id) == 1){

			clonado[j].id = elemento->id;

            clonado[j].descripcion = strdup(array[i].descripcion);

            j++;

		}
	}

    return clonado;
}

