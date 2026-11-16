#include "../ejs.h"
#include "../utils.h"
#include <string.h>

pokemon_t* buscar_pokemon_por_id(pokedex_t* pokedex, uint16_t id);

nodo_evolucion_t* rastrear_linea_evolutiva(pokedex_t* pokedex, uint16_t id_final) {

    nodo_evolucion_t *anterior = NULL;

    while (id_final != 0){

        nodo_evolucion_t* nodo_nuevo = malloc(sizeof(nodo_evolucion_t));

        pokemon_t* pokemon = buscar_pokemon_por_id(pokedex, id_final);
        
        nodo_nuevo->id = id_final;
        nodo_nuevo->evoluciona_en = anterior;

        anterior = nodo_nuevo;

        id_final = pokemon->evoluciona_de_id;
    }

    return anterior;
}

pokemon_t* buscar_pokemon_por_id(pokedex_t* pokedex, uint16_t id) {

    for (uint32_t i = 0; i < pokedex->filas; i++){
        for (uint32_t j = 0; j < pokedex->columnas; j++){
            if (pokedex->pokemons[i][j]){
                if (pokedex->pokemons[i][j]->id == id){
                    return pokedex->pokemons[i][j];
                }
            }
        }
    }

}