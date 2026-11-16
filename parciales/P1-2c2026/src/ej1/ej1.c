#include "../ejs.h"
#include <string.h>

void actualizar_movimientos_pokemon(pokemon_t* pokemon, char** nuevos_movimientos, int cantidad) {
    if (pokemon == NULL) {
        return;
    }

    for (int i = 0; i < 4; i++) {
        free(pokemon->movimientos[i]);              // free(NULL) es válido

        if (i < cantidad) {
            pokemon->movimientos[i] = strdup(nuevos_movimientos[i]);
        } else {
            pokemon->movimientos[i] = NULL;
        }
    }
}

// // Primera version que me salió y la cual traduje a ASM:
// void actualizar_movimientos_pokemon(pokemon_t* pokemon, char** nuevos_movimientos, int cantidad) {

//     if (pokemon == NULL){
//         return;
//     }

//     for (size_t i = 0; i < 4; i++){
//             free(pokemon->movimientos[i]);
//     }

//     if (cantidad < 4){
//         for (size_t i = 0; i < cantidad; i++){
//             pokemon->movimientos[i] = strdup(nuevos_movimientos[i]);
//         }

//         for (cantidad; cantidad < 4; cantidad++){
//             pokemon->movimientos[cantidad] = NULL;
//         }
//     } 
//     else {

//         for (size_t i = 0; i < 4; i++){
//             pokemon->movimientos[i] = strdup(nuevos_movimientos[i]);
//         }
//     }

// }