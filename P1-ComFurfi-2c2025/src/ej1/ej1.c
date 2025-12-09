#include "../ejs.h"
#include <string.h>

// Función principal: publicar un tuit

tuit_t* publicar(char* mensaje, usuario_t* usuario) {
    // PASO 1: Crear el Tuit (la carga)
    // - Malloc de tuit_t
    // - Copiar el mensaje con strcpy (porque tuit->mensaje es un array, no un puntero)
    // - Inicializar likes, retuits e id_autor
    
    tuit_t* nuevo_tuit = malloc(sizeof(tuit_t));
    strcpy(nuevo_tuit->mensaje, mensaje); 
    nuevo_tuit->favoritos = 0;
    nuevo_tuit->retuits = 0;
    nuevo_tuit->id_autor = usuario->id;

    // PASO 2: Agregar al feed del PROPIO usuario
    crear_pub(usuario->feed, nuevo_tuit);

    // PASO 3: Agregar al feed de los SEGUIDORES
    // Aquí tendrás que hacer un loop recorriendo usuario->seguidores
    // y llamando a crear_pub(seguidor->feed, nuevo_tuit)
    
    for (size_t i = 0; i < usuario->cantSeguidores; i++){
      if (usuario->seguidores[i])
      {
        crear_pub(usuario->seguidores[i]->feed, nuevo_tuit);
      }

    }

    return nuevo_tuit;
}

void crear_pub(feed_t* feed, tuit_t* tuit_a_publicar) {
    
    // 1. Reservamos memoria para EL NODO (la publicación), no para el mensaje
    publicacion_t* nueva_pub = malloc(sizeof(publicacion_t));

    // 2. Guardamos el puntero al tuit en el campo 'value'
    nueva_pub->value = tuit_a_publicar;

    // 3. El 'next' del nuevo nodo apunta a lo que antes era el primero
    nueva_pub->next = feed->first;

    // 4. El feed ahora arranca con nuestro nuevo nodo
    feed->first = nueva_pub;
}

