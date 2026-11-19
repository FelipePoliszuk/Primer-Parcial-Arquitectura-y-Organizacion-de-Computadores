#include "../ejs.h"

uint32_t sumarTesoros(Mapa *mapa, uint32_t actual, bool *visitado) {
    
    uint32_t acumulador = 0;

    if ((actual != 99) && (!visitado[actual])){

        if (mapa->habitaciones[actual].contenido.es_tesoro){
            acumulador += mapa->habitaciones[actual].contenido.valor;
        }
        
        visitado[actual] = true;
        
        for (int i = 0; i < 4; i++){
            acumulador += sumarTesoros(mapa, mapa->habitaciones[actual].vecinos[i], visitado);
        }
    }
    
    return acumulador;
}