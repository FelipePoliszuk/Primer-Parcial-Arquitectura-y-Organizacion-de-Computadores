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


// mapa_t es una matriz de 255×255 punteros a attackunit_t. Cada casilla mapa[i][j] es un attackunit_t*: 
// o apunta a una unidad, o es NULL si la casilla está vacía.

/**
 * OPCIONAL: implementar en C
 */
void optimizar(mapa_t mapa, attackunit_t* compartida, uint32_t (*fun_hash)(attackunit_t*)) {

    uint32_t compartida_hash = fun_hash(compartida);

    for (size_t i = 0; i < 255; i++){
        for (size_t j = 0; j < 255; j++){
            if (mapa[i][j]){
                if ((compartida != mapa[i][j]) && compartida_hash == fun_hash(mapa[i][j])){ 
                        mapa[i][j]->references --;

                        if (mapa[i][j]->references == 0){
                            free(mapa[i][j]);
                        }
                        
                        mapa[i][j] = compartida; 
                        compartida->references ++;
                }
            }
        }
    }
}

/**
 * OPCIONAL: implementar en C
 */
uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char*)) {
    
    uint32_t combustible_total = 0;

    for (size_t i = 0; i < 255; i++){
        for (size_t j = 0; j < 255; j++){
            if (mapa[i][j]){
                combustible_total += mapa[i][j]->combustible - fun_combustible(mapa[i][j]->clase) ;
            }
        }
    }

    return combustible_total;
}

/**
 * OPCIONAL: implementar en C
 */
void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t*)) {

    if (mapa[x][y]){
        if (mapa[x][y]->references > 1){

            attackunit_t* nueva_unidad = malloc(sizeof(attackunit_t));
            
            strcpy(nueva_unidad->clase, mapa[x][y]->clase),
            
            nueva_unidad->combustible = mapa[x][y]->combustible;

            nueva_unidad->references = 1;
            mapa[x][y]->references --;
            
            fun_modificar(nueva_unidad);
            mapa[x][y] = nueva_unidad;

        } else{
            fun_modificar(mapa[x][y]);
        }
    }
}