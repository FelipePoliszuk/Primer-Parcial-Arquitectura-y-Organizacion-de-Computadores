#include "../ejs.h"

void bloquearUsuario(usuario_t *usuario, usuario_t *usuarioABloquear){

  bloquearUsuario_aux(usuario->feed, usuarioABloquear);
  bloquearUsuario_aux(usuarioABloquear->feed, usuario);

  usuario->bloqueados[usuario->cantBloqueados] = usuarioABloquear;
  usuario->cantBloqueados ++;
}

void bloquearUsuario_aux(feed_t *feed, usuario_t *usuario){

  // "indirecto" apunta a la flecha que apunta al nodo actual
  publicacion_t **indirecto = &(feed->first);
  
  while (*indirecto){
    
    publicacion_t *actual = *indirecto; // Desreferenciamos para ver el nodo
    
    if (actual->value->id_autor == usuario->id){
      // Lo salteamos directamente cambiando a dónde apunta la flecha original
      *indirecto = actual->next;
      // free(actual);
    } else {
      // Si no lo borramos, avanzamos nuestra flecha al "next" del nodo actual
      indirecto = &(actual->next);
    }
    
  }

}