#include "../ejs.h"

uint32_t cantidadDeProductos(catalogo_t *h);
bool cumpleCondiciones(producto_t *producto);

producto_t *filtrarPublicacionesNuevasDeUsuariosVerificados(catalogo_t *h){
 
    uint32_t tamaño = cantidadDeProductos(h);
    
    producto_t **arreglo = malloc(sizeof(producto_t*)*(tamaño + 1));

    publicacion_t *actual =  h->first; 

    uint32_t j = 0;

    while (actual){
        
        producto_t *producto =  actual->value;

        if (cumpleCondiciones(producto)){
            arreglo[j] = producto;
            j++;
        }
        
        actual = actual->next;
    }
    
    arreglo[j] = NULL;

    return arreglo;
}

uint32_t cantidadDeProductos(catalogo_t *h){

    uint32_t tamaño = 0;

    publicacion_t *actual =  h->first; 

    while (actual){
        
        producto_t *producto =  actual->value;

        if (cumpleCondiciones(producto)){
            tamaño++;
        }
        
        actual = actual->next;
    }
    
    return tamaño;
}

bool cumpleCondiciones(producto_t *producto){

    if (producto->estado == 1 && producto->usuario->nivel >= 1){
        return true;
    }
    
    return false;

}