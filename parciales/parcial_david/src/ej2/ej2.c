#include "../ejs.h"


catalogo_t* removerCopias(catalogo_t *h){

publicacion_t *actual = h->first;

  while (actual){
    
    removerAparicionesPosterioresDe(actual);
    actual = actual->next;
  }

  return h;
}

void removerAparicionesPosterioresDe(publicacion_t* publicacion){

  publicacion_t **indirecto = &publicacion->next;

  while (*indirecto){
    publicacion_t *actual = (*indirecto);

    if ((actual->value->usuario == publicacion->value->usuario) && ((strcmp(actual->value->nombre, publicacion->value->nombre)) == 0)){
      
      *indirecto = actual->next;
      free(actual->value);
      free(actual);
    } else{
      
      indirecto = &(actual->next);
    }
  }
}