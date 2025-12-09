#include "../ejs.h"

catalogo_t *removerCopias(catalogo_t *h) {
   
    publicacion_t* actual = h->first;

    while (actual != NULL) {
      removerAparicionesPosterioresDe(actual);
      actual = actual->next;

    }

   return h;
}


void removerAparicionesPosterioresDe(publicacion_t* publicacion){


    publicacion_t **actual = &publicacion->next;  // Puntero al puntero
    
    while (*actual != NULL) {
      producto_t* producto = (*actual)->value;
      if (strcmp(producto->nombre, publicacion->value->nombre) == 0 && (producto->usuario == publicacion->value->usuario)){
         // Borrar: desvinculamos el nodo
         publicacion_t* a_borrar = *actual;
         *actual = (*actual)->next;
         free(a_borrar);
         free(producto);
     } else {
      actual = &(*actual)->next;
     }

        
    }

}