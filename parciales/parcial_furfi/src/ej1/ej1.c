#include "../ejs.h"
#include <string.h>

// Función auxiliar: Crea una publicación con el tuit y la agrega al comienzo del feed.
publicacion_t *publicar_aux(tuit_t *tuit, feed_t *feed) {

  publicacion_t *publicacion_nueva = malloc(sizeof(publicacion_t));

  publicacion_nueva->value = tuit;

  publicacion_nueva->next = feed->first;
  
  feed->first = publicacion_nueva;

  return publicacion_nueva;
    
}

// Función principal: publicar un tuit
tuit_t *publicar(char *mensaje, usuario_t *user) {

  tuit_t *tuit = malloc(sizeof(tuit_t));

  tuit->favoritos = 0;
  tuit->retuits = 0;
  tuit->id_autor = user->id;
  strcpy(tuit->mensaje, mensaje);

  publicar_aux(tuit, user->feed);

  for (uint32_t i = 0; i < user->cantSeguidores; i++){
    publicar_aux(tuit, user->seguidores[i]->feed);
  }

  return tuit;
}
