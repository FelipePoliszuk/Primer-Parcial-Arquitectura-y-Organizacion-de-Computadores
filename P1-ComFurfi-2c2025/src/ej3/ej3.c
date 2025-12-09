#include "../ejs.h"

uint32_t cantidadDeSobresalientes(usuario_t* usuario, uint8_t (*esTuitSobresaliente)(tuit_t *));




tuit_t** trendingTopic(usuario_t* usuario, uint8_t (*esTuitSobresaliente)(tuit_t*)) {

    uint32_t cantidad = cantidadDeSobresalientes(usuario, esTuitSobresaliente);

    if (cantidad == 0) {
        return NULL;
    }
    tuit_t **arreglo = malloc(sizeof(tuit_t*) * (cantidad + 1));

    publicacion_t* actual = usuario->feed->first;
    int i = 0; // Índice para escribir en el arreglo

    while (actual != NULL) {
        tuit_t* tuit = actual->value;

        if (tuit != NULL && tuit->id_autor == usuario->id) {
            
            if (esTuitSobresaliente(tuit)) {
                arreglo[i] = tuit;
                i++; 
            }
        }

        actual = actual->next;
    }

    arreglo[cantidad] = NULL;
    return arreglo;
}



uint32_t cantidadDeSobresalientes(usuario_t* usuario, uint8_t (*esTuitSobresaliente)(tuit_t *)){
    
    uint32_t contador = 0;
    
    // Obtenemos el inicio de la lista
    publicacion_t* actual = usuario->feed->first;

    while (actual != NULL) {
        tuit_t* tuit = actual->value;

        // 1. Chequeamos que el tuit no sea NULL
        // 2. Chequeamos que el tuit sea MIO (id_autor == usuario->id)
        if (tuit != NULL && tuit->id_autor == usuario->id) {
            
            // 3. Llamamos al puntero a función
            // Si devuelve cualquier cosa distinta de 0 (true), sumamos
            if (esTuitSobresaliente(tuit)) {
                contador++;
            }
        }

        // Avanzamos al siguiente nodo
        actual = actual->next;
    }

    return contador;
}