#include "../ejs.h"

uint32_t trendingTopic_aux(usuario_t *user, uint8_t (*esTuitSobresaliente)(tuit_t *));

tuit_t **trendingTopic(usuario_t *user, uint8_t (*esTuitSobresaliente)(tuit_t *)) {

    uint32_t tamaño = trendingTopic_aux(user, esTuitSobresaliente);

    if (tamaño == 0){
        return NULL;
    }
    
    tuit_t **nuevo_arreglo = malloc(sizeof(tuit_t*) * (tamaño + 1));

    publicacion_t *actual = user->feed->first;

    uint32_t i = 0;
    while (actual){
        if ((actual->value->id_autor == user->id && (esTuitSobresaliente(actual->value)))){
            nuevo_arreglo[i] = actual->value;
            i ++;
        }
        actual = actual->next;
    }
    
    nuevo_arreglo[i] = NULL;

    return nuevo_arreglo;
}

// Consejo: armar una función auxiliar que cuente la cantidad de tuits sobresalientes del feed de un usuario.
uint32_t trendingTopic_aux(usuario_t *user, uint8_t (*esTuitSobresaliente)(tuit_t *)) {

    publicacion_t *actual = user->feed->first;

    uint32_t cantidad = 0;

    while (actual){
        if ((actual->value->id_autor == user->id && (esTuitSobresaliente(actual->value)))){
            cantidad ++;
        }
        actual = actual->next;
    }
    return cantidad;
}   