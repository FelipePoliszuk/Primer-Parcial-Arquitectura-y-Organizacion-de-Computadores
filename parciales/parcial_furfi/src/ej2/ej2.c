#include "../ejs.h"

void bloquearUsuario(usuario_t *usuario, usuario_t *usuarioABloquear){

  usuario->bloqueados[usuario->cantBloqueados] = usuarioABloquear;
  usuario->cantBloqueados ++;

  bloquearUsuario_aux(usuario->feed, usuarioABloquear);
  bloquearUsuario_aux(usuarioABloquear->feed,usuario);

}

void bloquearUsuario_aux(feed_t *feed, usuario_t *usuario){

  // indirecto apunta a la flecha que apunta al nodo actual
  publicacion_t **indirecto = &(feed->first);
  
  while (*indirecto){
    
    publicacion_t *actual = *indirecto; // Desreferenciamos para ver el nodo
    
    if (actual->value->id_autor == usuario->id){
      // Lo salteamos directamente cambiando a dónde apunta la flecha original
      *indirecto = actual->next;
      free(actual);
    } else {
      // Si no lo borramos, avanzamos NUESTRA flecha al next del nodo actual
      indirecto = &(actual->next);
    }
  }
}

// void bloquearUsuario_aux(feed_t *feed, usuario_t *usuario){
  
//   publicacion_t* actual = feed->first; 
//   publicacion_t* previa = NULL; 

//   while (actual) { 

//     publicacion_t* siguiente = actual->next; 

//     if (actual->value->id_autor == usuario->id) { 
      
//       // Hay que borrar.
//       // ¿Es el primer nodo de la lista (o los primeros consecutivos)?
//       if (previa == NULL) { 
//         feed->first = siguiente; 
//       } else { 
//         // Es un nodo en el medio o al final
//         previa->next = siguiente; 
//       } 
      
//       free(actual); 

//     } else { 
      
//       // No hay que borrar. Avanzamos el puntero "previa".
//       // A partir de acá, previa ya nunca más será NULL.
//       previa = actual; 

//     } 

//     actual = siguiente; 

//   } 
// }