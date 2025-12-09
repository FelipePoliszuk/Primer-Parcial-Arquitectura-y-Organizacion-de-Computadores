#include "../ejs.h"
#include <stdint.h>

usuario_t** asignarNivelesParaNuevosUsuarios(uint32_t *ids, uint32_t cantidadDeIds,
                                 uint8_t (*deQueNivelEs)(uint32_t)) {

                                                
    if (cantidadDeIds == 0) {
        return NULL;
    }
    
    usuario_t **arreglo = malloc(sizeof(usuario_t*) * (cantidadDeIds));

    for (size_t i = 0; i < cantidadDeIds; i++){
      
        uint8_t nivel = deQueNivelEs(ids[i]);

        usuario_t* nuevo_usuario = malloc(sizeof(usuario_t));

        nuevo_usuario->id = ids[i];
        nuevo_usuario->nivel = nivel; 

        arreglo[i] = nuevo_usuario;

    }
    return arreglo;

}




