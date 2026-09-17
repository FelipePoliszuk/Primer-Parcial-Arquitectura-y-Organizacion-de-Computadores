#include "../ejs.h"

uint32_t trendingTopic_aux(usuario_t *user, uint8_t (*esTuitSobresaliente)(tuit_t *));

tuit_t **trendingTopic(usuario_t *user, uint8_t (*esTuitSobresaliente)(tuit_t *)) {

    uint32_t cantidad = trendingTopic_aux(user, esTuitSobresaliente); 

    if (cantidad == 0){
        return NULL;
    }
    
    tuit_t **arreglo = malloc(sizeof(tuit_t*) * (cantidad + 1));

    publicacion_t *actual = user->feed->first;

    uint32_t j = 0;
    while (actual){
        tuit_t *tuit = actual->value;

        if((tuit->id_autor == user->id) && (esTuitSobresaliente(tuit))){
            arreglo[j] = tuit;
            j++;

        }
        actual = actual->next;
    }

    arreglo[cantidad] = NULL; 
            
    return arreglo;
}

// Consejo: armar una función auxiliar que cuente la cantidad de tuits sobresalientes del feed de un usuario.
uint32_t trendingTopic_aux(usuario_t *user, uint8_t (*esTuitSobresaliente)(tuit_t *)) {

    uint32_t cantidad = 0;

    publicacion_t *actual = user->feed->first;

    while (actual){
        tuit_t *tuit = actual->value;
        if((tuit->id_autor == user->id) && (esTuitSobresaliente(tuit))){
            cantidad ++;
        }
        actual = actual->next;
    }
            
    return cantidad;
}