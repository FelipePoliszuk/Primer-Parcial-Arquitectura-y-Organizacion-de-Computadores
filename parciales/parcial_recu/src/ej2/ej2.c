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

// es la versión que tengo resuelta en asm
// versión con un indice pero haciendo rec->acciones[len-i-1]; feo.
Recorrido *invertirRecorridoConDirecciones(const Recorrido *rec, uint64_t len) {
    
    if (len == 0){
        return NULL;
    }

    Recorrido *inverso = malloc((sizeof(Recorrido)));
    Accion *acciones = malloc((sizeof(Accion)) * len);

    for (uint64_t i = 0; i < len; i++){

        Accion accion = rec->acciones[len-i-1];
        acciones[i] = accion_inversa(accion);

    }    

    inverso->acciones = acciones;
    inverso->cant_acciones = len;

    return inverso;

}





// // mejor versión
// Recorrido *invertirRecorridoConDirecciones(const Recorrido *rec, uint64_t len) {
    
//     if (len == 0) {
//         return NULL;
//     }

//     Recorrido *inverso = malloc(sizeof(Recorrido));
//     Accion *acciones = malloc(sizeof(Accion) * len);

//     uint64_t i = len - 1; 
    
//     for (uint64_t j = 0; j < len; j++) { 
        
//         Accion accion = rec->acciones[i];
//         acciones[j] = accion_inversa(accion);
        
//         i--;
//     }    

//     inverso->acciones = acciones;
//     inverso->cant_acciones = len;

//     return inverso;
// }

// // versión con dos indices pero con int
// Recorrido *invertirRecorridoConDirecciones(const Recorrido *rec, uint64_t len) {
 
//     if (len == 0){
//         return NULL;
//     }

//     Recorrido *recorrido_inverso = malloc(sizeof(Recorrido));

//     recorrido_inverso->cant_acciones = len;

//     Accion *acciones_inversas = malloc(sizeof(Accion)*len);

//     int j = 0;

//     for (int i = (len-1); i >= 0; i --){
        
//         Accion accion = rec->acciones[i];

//         acciones_inversas[j] = accion_inversa(accion);
//         j ++;
//     }

//     recorrido_inverso->acciones = acciones_inversas;

//     return recorrido_inverso;

// }



