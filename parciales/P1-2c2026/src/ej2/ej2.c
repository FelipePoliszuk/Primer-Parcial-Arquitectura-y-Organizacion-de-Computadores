#include "../ejs.h"
#include "../utils.h"
#include <string.h>

pokemon_filtrados_t* obtener_avistados_por_tipo(pokedex_t* pokedex, char* tipo_objetivo) {

    pokemon_filtrados_t* pokemon_filtrados = malloc(sizeof(pokemon_filtrados_t));

    uint16_t* ids_pokemons = malloc(sizeof(uint16_t) * 20);

    uint32_t cantidad_pokemons = 0;
    for (uint32_t i = 0; i < pokedex->filas; i++){
        for (uint32_t j = 0; j < pokedex->columnas; j++){
            if (pokedex->pokemons[i][j]){

                if (((obtener_bit(pokedex->bitmap, (i*pokedex->columnas) + j)) == 1) && (strcmp(pokedex->pokemons[i][j]->info.tipo, tipo_objetivo) == 0)){

                    ids_pokemons[cantidad_pokemons] = pokedex->pokemons[i][j]->id;
                    cantidad_pokemons ++;

                }
            }
        }
    }

    pokemon_filtrados->ids_pokemons = ids_pokemons;
    pokemon_filtrados->cantidad_pokemons = cantidad_pokemons;

    return pokemon_filtrados;
}