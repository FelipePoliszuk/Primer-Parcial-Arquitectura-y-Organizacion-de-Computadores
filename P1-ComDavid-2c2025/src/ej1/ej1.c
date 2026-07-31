#include "../ejs.h"

uint32_t cantidadDeProductos(catalogo_t *h);
bool cumpleCondiciones(producto_t *producto);



producto_t *filtrarPublicacionesNuevasDeUsuariosVerificados(catalogo_t *h){

    uint32_t tamaño = cantidadDeProductos(h);

    if (tamaño == 0){
        return NULL;
    }
    
    producto_t **arreglo = malloc((sizeof(producto_t*)) * (tamaño + 1));

    publicacion_t *actual = h->first;

    uint32_t i = 0;
    while (actual){
        
        if (cumpleCondiciones(actual->value)){
            arreglo[i] = actual->value; 
            i++;
        }
        
        actual = actual->next;
    }
    
    arreglo[tamaño] = NULL;

    return arreglo;
}



uint32_t cantidadDeProductos(catalogo_t *h){

    uint32_t cantidad = 0;

    publicacion_t *actual = h->first;

    while (actual){
        if (cumpleCondiciones(actual->value)){
            cantidad++;
        }
        actual = actual->next;
    }

    return cantidad;
}


bool cumpleCondiciones(producto_t *producto){

    if ((producto->estado == 1) && (producto->usuario->nivel >= 1)){
        return true;
    } 

    return false;

}