#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej2.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
bool EJERCICIO_2A_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - contarCombustibleAsignado
 */
bool EJERCICIO_2B_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - modificarUnidad
 */
bool EJERCICIO_2C_HECHO = true;

/**
 * OPCIONAL: implementar en C
 */

void optimizar(mapa_t mapa, attackunit_t *compartida, uint32_t (*fun_hash)(attackunit_t *)) {

  for (int x = 0; x < 255; x++){
    for (int y = 0; y < 255; y++){

      if (mapa[x][y]){
      
        if ((mapa[x][y] != compartida) && (fun_hash(mapa[x][y]) == fun_hash(compartida))){
        
          if (mapa[x][y]->references == 1){
            free(mapa[x][y]);
          } else {
            mapa[x][y]->references --;
          }
          
          compartida->references ++;
        
          mapa[x][y] = compartida;
        
        } 
      }
    }
  }
}

/**
 * OPCIONAL: implementar en C
 */
uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char *)) {
  uint32_t total = 0;

  for (size_t i = 0; i < 255; i++){
    for (size_t j = 0; j < 255; j++){
      if (mapa[i][j]){
        total += mapa[i][j]->combustible - fun_combustible(mapa[i][j]->clase);
      }
    } 
  }
  return total;
}

/**
 * OPCIONAL: implementar en C
 */
void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t *)) {

  if (mapa[x][y]){
    if (mapa[x][y]->references > 1){
      attackunit_t *nueva = malloc(sizeof(attackunit_t));

      mapa[x][y]->references -= 1;
      
      strcpy(nueva->clase, mapa[x][y]->clase);
      nueva->combustible = mapa[x][y]->combustible;
      
      nueva->references = 1;

      fun_modificar(nueva);

      mapa[x][y] = nueva;
    } else {
      fun_modificar(mapa[x][y]);
    }

  }
  
  
}