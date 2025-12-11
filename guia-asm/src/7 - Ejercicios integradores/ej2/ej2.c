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

  uint32_t compartida_hash = fun_hash(compartida);
  
  for (int x = 0; x < 255; x++){
    for (int y = 0; y < 255; y++){

      if (mapa[x][y]){
      
        if ((mapa[x][y] != compartida) && (fun_hash(mapa[x][y]) == compartida_hash)){
        
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
  
  uint32_t combustible = 0;

  for (int x = 0; x < 255; x++){
    for (int y = 0; y < 255; y++){

      if (mapa[x][y]){

      combustible += mapa[x][y]->combustible - fun_combustible(mapa[x][y]->clase);
        
      } 
    }
  }

  return combustible;

}


/**
 * OPCIONAL: implementar en C
 */
void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t *)) {
  
  if (mapa[x][y] == 0){
    return;
  }

  if (mapa[x][y]->references == 1){
    fun_modificar(mapa[x][y]);
  } else {
    
    mapa[x][y]->references --;
    attackunit_t* nueva_unidad = malloc(sizeof(attackunit_t));

    nueva_unidad->combustible = mapa[x][y]->combustible;
    nueva_unidad->references = 1;

    strcpy(nueva_unidad->clase, mapa[x][y]->clase);
    mapa[x][y] = nueva_unidad;

    fun_modificar(mapa[x][y]);
  
  }

}






// /**
//  * OPCIONAL: implementar en C
//  */

// void optimizar(mapa_t mapa, attackunit_t *compartida,
//                uint32_t (*fun_hash)(attackunit_t *)) {

//   for (uint32_t i = 0; i < 255; i++) {
//     for (uint32_t j = 0; j < 255; j++) {
//       if (mapa[i][j]) {

//         if (mapa[i][j] != compartida &&
//             (fun_hash(mapa[i][j]) == fun_hash(compartida))) {

//           if (mapa[i][j]->references == 1) {
//             free(mapa[i][j]);
//           } else {
//             mapa[i][j]->references -= 1;
//           }

//           compartida->references += 1;
          
//           mapa[i][j] = compartida;
//         }
//       }
//     }
//   }
// }

// /**
//  * OPCIONAL: implementar en C
//  */
// uint32_t contarCombustibleAsignado(mapa_t mapa,
//                                    uint16_t (*fun_combustible)(char *)) {

//   uint32_t acumulador = 0;

//   for (uint32_t i = 0; i < 255; i++) {
//     for (uint32_t j = 0; j < 255; j++) {
//       if (mapa[i][j]) {
//         acumulador +=
//             (mapa[i][j]->combustible) - (fun_combustible(mapa[i][j]->clase));
//       }
//     }
//   }
//   return acumulador;
// }

// /**
//  * OPCIONAL: implementar en C
//  */
// void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y,
//                      void (*fun_modificar)(attackunit_t *)) {

//   if (mapa[x][y] == 0) // si mapa[x][y] == null devuelvo la funcion
//     return;
    
//   if (mapa[x][y]->references == 1) {
//     fun_modificar(mapa[x][y]); // modifico in-place
//   } else {

//     // Hago la copia (nueva instancia)
//     mapa[x][y]->references -= 1;
//     attackunit_t *individual = malloc(sizeof(attackunit_t));
//     individual->combustible = mapa[x][y]->combustible;

//     individual->references = 1;

//     strcpy(individual->clase, mapa[x][y]->clase);

//     // Actualizo el mapa
//     mapa[x][y] = individual;

//     // Modifico la copia
//     fun_modificar(mapa[x][y]);
//   }
//   return;
// }