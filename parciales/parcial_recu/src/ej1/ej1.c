#include "../ejs.h"
#include <string.h>

bool encontrarTesoroEnMapa(Mapa *mapa, Recorrido *rec, uint64_t *acciones_ejecutadas) {

    *acciones_ejecutadas = 0;

    uint32_t actual = mapa->id_entrada;
    
    if (mapa->habitaciones[actual].contenido.es_tesoro){
        return true;
    }    

    for (uint64_t i = 0; i < rec->cant_acciones; i++){

        Accion indice = rec->acciones[i];

        uint32_t proxima_habitacion = mapa->habitaciones[actual].vecinos[indice];

        if (proxima_habitacion == 99){
            return false;
        }
        
        *acciones_ejecutadas += 1;      // *acciones_ejecutadas ++; no funciona lol

        if (mapa->habitaciones[proxima_habitacion].contenido.es_tesoro){
            return true;
        }

        actual = proxima_habitacion;
    }    
    
    return false;
}

// // copio en cada iteracion el struct habitación (muy malo)
// bool encontrarTesoroEnMapa(Mapa *mapa, Recorrido *rec, uint64_t *acciones_ejecutadas) {

//     Habitacion primera_habitacion = mapa->habitaciones[mapa->id_entrada];

//     if (primera_habitacion.contenido.es_tesoro){
//         return true;
//     }

//     Habitacion actual = primera_habitacion;

//     for (uint64_t i = 0; i < rec->cant_acciones; i++){

//         Accion indice = rec->acciones[i];

//         uint32_t proxima_habitacion = actual.vecinos[indice];

//         if (proxima_habitacion == 99){
//             return false;
//         }
        
//         *acciones_ejecutadas += 1;     

//         if (mapa->habitaciones[proxima_habitacion].contenido.es_tesoro){
//             return true;
//         }

//         actual = mapa->habitaciones[proxima_habitacion];
//     }    
    
//     return false;
// }