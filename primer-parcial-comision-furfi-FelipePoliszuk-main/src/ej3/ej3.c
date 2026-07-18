#include "../ejs.h"

uint32_t trendingTopic_aux(usuario_t *user, uint8_t (*esTuitSobresaliente)(tuit_t *));


tuit_t **trendingTopic(usuario_t *user, uint8_t (*esTuitSobresaliente)(tuit_t *)) {
    
    uint32_t tamaño = trendingTopic_aux(user, esTuitSobresaliente);


    if (tamaño == 0){
        return NULL;
    }
    

    tuit_t **arreglo = malloc(sizeof(tuit_t*) * (tamaño + 1));
    
    publicacion_t *actual = user->feed->first;

    uint32_t i = 0;



    while (actual){

        if (actual->value->id_autor == user->id && esTuitSobresaliente(actual->value)){
           arreglo[i] = actual->value;
           i ++;
        }

        actual = actual->next;
    }

    arreglo[tamaño] = NULL;

    return arreglo;
}


// Consejo: armar una función auxiliar que cuente la cantidad de tuits sobresalientes del feed de un usuario.

uint32_t trendingTopic_aux(usuario_t *user, uint8_t (*esTuitSobresaliente)(tuit_t *)) {
    
    uint32_t cantidad = 0;

    publicacion_t *actual = user->feed->first;

    while (actual){
        if (actual->value->id_autor == user->id && esTuitSobresaliente(actual->value)){
            cantidad ++;
        }
        actual = actual->next;
    }
    
    return cantidad;
}
