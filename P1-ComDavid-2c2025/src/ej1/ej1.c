#include "../ejs.h"

uint32_t cantidadDeProductos(catalogo_t *h);
bool cumpleCondiciones(producto_t *producto);


producto_t *filtrarPublicacionesNuevasDeUsuariosVerificados(catalogo_t *h) {
 
    
    uint32_t cantidad = cantidadDeProductos(h);

    if (cantidad == 0) {
        return NULL;
    }

    producto_t **arreglo = malloc(sizeof(producto_t*) * (cantidad + 1));
   
    publicacion_t* actual = h->first;

    int i = 0; // Índice para escribir en el arreglo

    while (actual != NULL) {
        producto_t* producto = actual->value;

        if (cumpleCondiciones(producto)) {
            arreglo[i] = producto;
            i++; 
        }
        actual = actual->next;
    }

    arreglo[cantidad] = NULL;
    return arreglo;
}


uint32_t cantidadDeProductos(catalogo_t *h){
    
    uint32_t contador = 0;
    
    publicacion_t* actual = h->first;

    while (actual != NULL) {
        producto_t* producto = actual->value;

        if (cumpleCondiciones(producto)) {
            contador++;
        }

        actual = actual->next;
    }

    return contador;
}

bool cumpleCondiciones(producto_t *producto){

    return ((producto->estado == 1) && (producto->usuario->nivel > 0));

}