#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej1.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
bool EJERCICIO_1A_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - indice_a_inventario
 */
bool EJERCICIO_1B_HECHO = true;

/**
 * OPCIONAL: implementar en C
 */
bool es_indice_ordenado(item_t **inventario, uint16_t *indice, uint16_t tamanio, comparador_t comparador) {

  for (int i = 0; i < tamanio - 1; i++) {
    item_t *item_actual = inventario[indice[i]];
    item_t *item_siguiente = inventario[indice[i + 1]];

    // Si el comparador dice que no están en orden correcto
    if (!comparador(item_actual, item_siguiente)) {
      return false;
    }
  }

  return true;
}


/**
 * OPCIONAL: implementar en C
 */
item_t **indice_a_inventario(item_t **inventario, uint16_t *indice, uint16_t tamanio) {
  
  item_t** nuevo_inventario = malloc(sizeof(item_t*) * tamanio);

  for (int i = 0; i < tamanio; i++){
    nuevo_inventario[i] = inventario[indice[i]];
  }

  return nuevo_inventario;
}
