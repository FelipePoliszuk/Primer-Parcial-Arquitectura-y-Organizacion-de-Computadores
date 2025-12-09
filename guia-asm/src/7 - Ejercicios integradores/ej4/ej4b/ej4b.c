#include "ej4b.h"

#include <string.h>

// OPCIONAL: implementar en C
void invocar_habilidad(void* carta_generica, char* habilidad) {
    if (carta_generica == NULL) return;
    card_t* carta = (card_t*)carta_generica;

    directory_t dir = carta->__dir;
    uint16_t entries = carta->__dir_entries;

    for (uint16_t i = 0; i < entries; i++) {
        directory_entry_t* entry = dir[i];
        if (entry != NULL && strcmp(entry->ability_name, habilidad) == 0) {
            ability_function_t* fn = (ability_function_t*) entry->ability_ptr;
            fn(carta);
            return;
        }
    }

    if (carta->__archetype != NULL) {
        invocar_habilidad(carta->__archetype, habilidad);
    }
}
