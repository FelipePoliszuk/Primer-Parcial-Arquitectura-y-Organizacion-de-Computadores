#include "../ejs.h"


Accion accion_inversa(Accion acc){

    if (acc == ACC_NORTE){
        return ACC_SUR;
    }

    if (acc == ACC_SUR){
        return ACC_NORTE;
    }

    if (acc == ACC_ESTE){
        return ACC_OESTE;
    }

    return ACC_ESTE;
    
}


Recorrido *invertirRecorridoConDirecciones(const Recorrido *rec, uint64_t len) {
    
    if (len == 0){
        return NULL;
    }

    Recorrido *inverso = malloc((sizeof(Recorrido)));
    Accion *acciones = malloc((sizeof(Accion)) * len);

    for (int i = 0; i < len; i++){

        Accion accion = rec->acciones[len-i-1];
        
        acciones[i] = accion_inversa(accion);

    }    

    inverso->acciones = acciones;
    inverso->cant_acciones = len;

    return inverso;

}
