#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej4a.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - init_fantastruco_dir
 */
bool EJERCICIO_1A_HECHO = true;

// OPCIONAL: implementar en C
void init_fantastruco_dir(fantastruco_t *card) {
  
  card->__dir_entries = 2;

  directory_entry_t *directorio1 = create_dir_entry("sleep", sleep);    // sleep es la función
  directory_entry_t *directorio2 = create_dir_entry("wakeup", wakeup);  // wakeup es la función

  directory_t nuevo_dir= malloc(sizeof(directory_entry_t*) * 2);
  
  nuevo_dir[0] = directorio1;
  nuevo_dir[1] = directorio2;

  card->__dir = nuevo_dir;
  
}

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - summon_fantastruco
 */
bool EJERCICIO_1B_HECHO = true;

// OPCIONAL: implementar en C
fantastruco_t *summon_fantastruco() {

  fantastruco_t* puntero = malloc(sizeof(fantastruco_t));
  
  puntero->face_up = 1;
  puntero->__archetype = NULL;

  init_fantastruco_dir(puntero);
  return puntero;
}










/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - init_fantastruco_dir
 */
// bool EJERCICIO_1A_HECHO = true;

// // OPCIONAL: implementar en C
// void init_fantastruco_dir(fantastruco_t *card) {

//   card->__dir_entries = 2;
//   card->__archetype = NULL;
//   card->face_up = 1;

//   // reservar directorio de 2 entradas
//   card->__dir = malloc(sizeof(directory_entry_t *) * card->__dir_entries);

//   directory_entry_t *directorio1 = create_dir_entry("sleep", sleep);
//   directory_entry_t *directorio2 = create_dir_entry("wakeup", wakeup);

//   card->__dir[0] = directorio1;
//   card->__dir[1] = directorio2;
// }

// /**
//  * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
//  *
//  * Funciones a implementar:
//  *   - summon_fantastruco
//  */
// bool EJERCICIO_1B_HECHO = true;

// // OPCIONAL: implementar en C
// fantastruco_t *summon_fantastruco() {

//   fantastruco_t *resultado = malloc(sizeof(fantastruco_t));
//   init_fantastruco_dir(resultado);
//   return resultado;
// }
