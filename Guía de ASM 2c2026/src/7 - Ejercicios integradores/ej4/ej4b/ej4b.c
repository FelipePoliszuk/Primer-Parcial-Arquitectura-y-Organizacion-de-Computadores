#include "ej4b.h"
#include <string.h>

// OPCIONAL: implementar en C

void invocar_habilidad(void* carta_generica, char* habilidad) {

	card_t *carta = carta_generica;

	for (uint16_t i = 0; i < carta->__dir_entries; i++){
		
		if (strcmp(carta->__dir[i]->ability_name, habilidad) == 0){
			void (*funcion_habilidad)(void*) = carta->__dir[i]->ability_ptr;
			funcion_habilidad(carta);
			// return;
		}
	}
	
	if (carta->__archetype){
		invocar_habilidad(carta->__archetype, habilidad);
	}
	
}		