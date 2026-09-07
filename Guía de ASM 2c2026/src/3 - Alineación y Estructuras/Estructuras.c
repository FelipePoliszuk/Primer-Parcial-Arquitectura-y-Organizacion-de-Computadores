#include "Estructuras.h"

/* Pueden programar alguna rutina auxiliar acá */

uint32_t cantidad_total_de_elementosC(lista_t* lista){

    uint32_t cantidad = 0;

    nodo_t *actual = lista->head;

    while (actual){
        
        cantidad += actual->longitud; 

        actual = actual->next;
    }

    return cantidad;
}


uint32_t cantidad_total_de_elementos_packedC(packed_lista_t* lista){

    uint32_t cantidad = 0;

    packed_nodo_t *actual = lista->head;

    while (actual){
        
        cantidad += actual->longitud; 

        actual = actual->next;
    }
    
    return cantidad;
}