#include "../ejs.h"

void bloquearUsuario(usuario_t* usuario, usuario_t* usuarioABloquear) {
  
    // 1. Agregar al final del array de bloqueados 
    usuario->bloqueados[usuario->cantBloqueados] = usuarioABloquear;

    usuario->cantBloqueados += 1;

    // 2. Limpiar mi feed (borrar lo que publicó el otro)
    bloquear_auxiliar(usuario->feed, usuarioABloquear);

    // 3. Limpiar el feed del otro (borrar lo que publiqué yo)
    bloquear_auxiliar(usuarioABloquear->feed, usuario);

}

void bloquear_auxiliar(feed_t* feed, usuario_t* usuarioABloquear) {
  
    publicacion_t **actual = &feed->first;  // Puntero al puntero
    
    while (*actual != NULL) {
        if ((*actual)->value && (*actual)->value->id_autor == usuarioABloquear->id) {
            // Borrar: desvinculamos el nodo
            publicacion_t* a_borrar = *actual;
            *actual = (*actual)->next;
            free(a_borrar);
        } else {
            // No borrar: avanzar al siguiente
            actual = &(*actual)->next;
        }
    }
}
