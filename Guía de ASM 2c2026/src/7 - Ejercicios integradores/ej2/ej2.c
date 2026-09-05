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
void optimizar(mapa_t mapa, attackunit_t* compartida, uint32_t (*fun_hash)(attackunit_t*)) {

    uint32_t hash_compartida = fun_hash(compartida);

    for (size_t i = 0; i < 255; i++){
        for (size_t j = 0; j < 255; j++){
            if (mapa[i][j]){
                if (hash_compartida == fun_hash(mapa[i][j]) && (compartida != mapa[i][j])){
                    
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

    uint32_t combustible = 0;

    for (size_t i = 0; i < 255; i++){
        for (size_t j = 0; j < 255; j++){
            if (mapa[i][j]){
                combustible += mapa[i][j]->combustible - fun_combustible(mapa[i][j]->clase);
            }
        }
    }

    return combustible;
}


/**
 * OPCIONAL: implementar en C
 */
void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t*)) {

    if (mapa[x][y]){

        if (mapa[x][y]->references > 1){
            
            mapa[x][y]->references --;

            attackunit_t* nueva_instancia = malloc(sizeof(attackunit_t));
            
            strcpy(nueva_instancia->clase, mapa[x][y]->clase);
            nueva_instancia->combustible = mapa[x][y]->combustible;
            nueva_instancia->references = 1;

            fun_modificar(nueva_instancia);
            mapa[x][y] = nueva_instancia;
        
        }  else { 
            fun_modificar(mapa[x][y]);
        }

    }
}