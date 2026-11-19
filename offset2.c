#include <stdio.h>
#include <stddef.h>
#include "ejs.h"   // el .h del parcial

#define OFF(T, f) printf("%-30s %zu\n", #T "." #f, offsetof(T, f))
#define SZ(T)     printf("%-30s %zu\n\n", "sizeof(" #T ")", sizeof(T))

int main(void) {
    // Un bloque por struct. Cada offset es relativo a SU struct
    // (es lo que va en las constantes del .asm).

    // Ejemplo (Pokédex):
    OFF(info_t, nombre);
    OFF(info_t, tipo);
    OFF(info_t, nivel);
    SZ(info_t);

    OFF(pokemon_t, id);
    OFF(pokemon_t, movimientos);
    OFF(pokemon_t, info);
    OFF(pokemon_t, descripcion);
    OFF(pokemon_t, evoluciona_de_id);
    SZ(pokemon_t);

    // Opcional, para chequear la suma de un campo anidado:
    // OFF(pokemon_t, info.tipo);   // = offset de info + offset de tipo

    return 0;
}

// Compilar desde la carpeta del parcial (donde está src/):
//   gcc -I src offset2.c -o offsets && ./offsets
