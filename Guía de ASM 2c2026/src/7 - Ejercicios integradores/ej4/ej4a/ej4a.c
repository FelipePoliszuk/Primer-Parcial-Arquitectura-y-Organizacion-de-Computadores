#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej4a.h"

directory_entry_t* create_dir_entry(char* ability_name, void* ability_ptr);
void wakeup(void* card);
void sleep(void* card);

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - init_fantastruco_dir
 */
bool EJERCICIO_1A_HECHO = true;

// OPCIONAL: implementar en C
void init_fantastruco_dir(fantastruco_t* card) {

    card->__dir_entries = 2;

    directory_t directorio = malloc(sizeof(directory_entry_t*) * 2);
    // directory_t directorio = malloc(1024);       Tecnica para el parcial cuando no sé de cuanto es..
    // directory_t directorio = calloc(100, 8);     Tecnica para el parcial cuando no sé de cuanto es..
    
    directorio[0] = create_dir_entry("wakeup", wakeup);
    directorio[1] = create_dir_entry("sleep", sleep);

    card->__dir = directorio;

}

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - summon_fantastruco
 */
bool EJERCICIO_1B_HECHO = true;

// OPCIONAL: implementar en C
fantastruco_t* summon_fantastruco() {

    fantastruco_t *fantastruco = malloc(sizeof(fantastruco_t));

    fantastruco->__archetype = NULL; 
    fantastruco->face_up = 1;

    init_fantastruco_dir(fantastruco);

    return fantastruco;
}
