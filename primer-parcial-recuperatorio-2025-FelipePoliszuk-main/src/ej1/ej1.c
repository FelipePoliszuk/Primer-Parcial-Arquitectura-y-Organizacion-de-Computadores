#include "../ejs.h"
#include <string.h>


bool encontrarTesoroEnMapa(Mapa *mapa, Recorrido *rec, uint64_t *acciones_ejecutadas) {

    *acciones_ejecutadas = 0;

    uint32_t actual = mapa->id_entrada;

    if (mapa->habitaciones[actual].contenido.es_tesoro){
            return true;
        }


    for (uint64_t i = 0; i < rec->cant_acciones; i++) {

        Accion direccion = rec->acciones[i];

        uint32_t id_destino = mapa->habitaciones[actual].vecinos[direccion];

        if (id_destino == 99) {
            return false; 
        }

        actual = id_destino;
        
        (*acciones_ejecutadas)++;

        if (mapa->habitaciones[actual].contenido.es_tesoro) {
            return true; 
        }
    }    
    

    return false;
}