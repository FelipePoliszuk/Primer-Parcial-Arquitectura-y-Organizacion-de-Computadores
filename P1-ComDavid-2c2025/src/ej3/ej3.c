#include "../ejs.h"
#include <stdint.h>


usuario_t** asignarNivelesParaNuevosUsuarios(uint32_t *ids, uint32_t cantidadDeIds, uint8_t (*deQueNivelEs)(uint32_t)) {

    if (cantidadDeIds == 0){
        return 0;
    }
    
    usuario_t** arreglo = malloc(sizeof(usuario_t*) * (cantidadDeIds));
    
    for (uint32_t i = 0; i < cantidadDeIds; i++){
        
        uint32_t nivel_usuario = deQueNivelEs(ids[i]);

        usuario_t* nuevo_usuario = malloc(sizeof(usuario_t));

        nuevo_usuario->nivel = nivel_usuario;
        nuevo_usuario->id = ids[i];
        

        arreglo[i] = nuevo_usuario;

    }
    
    return arreglo;
}


