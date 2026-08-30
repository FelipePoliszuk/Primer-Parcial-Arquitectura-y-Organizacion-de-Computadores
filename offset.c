#include <stdio.h>
#include <stddef.h>
#include "ej4a.h" //reemplazar por el .h 

int main() {
    printf("Offset en_juego: %zu\n", offsetof(item_kind_t, ITEM_KIND_TENT));
    printf("Offset nombre:   %zu\n", offsetof(item_kind_t, ability_ptr));
    printf("Offset vida:     %zu\n", offsetof(directory_entry_t, vida));
    printf("Offset jugador:  %zu\n", offsetof(directory_entry_t, jugador));
    printf("SIZE:            %zu\n\n", sizeof(directory_entry_t));
    
    printf("Offset mano rojo: %zu\n", offsetof(fantastruco_t, __dir));
    printf("Offset mano azul: %zu\n", offsetof(fantastruco_t, __dir_entries));
    printf("Offset campo:     %zu\n", offsetof(fantastruco_t, __archetype));
	printf("Offset campo:     %zu\n", offsetof(fantastruco_t, face_up));
    printf("SIZE:            %zu\n\n", sizeof(fantastruco_t));

    return 0;
}

// gcc -o offsets offset.c 
// ./offsets


	// ;prologo
	// push rbp	;alineado
	// mov rbp, rsp
	// push r12	;desalineado
	// push r13	;alineado
	// push r14	;desalineado
	// push r15	;alineado
	// push rbx	;desalineado
	// sub rsp, 8	;alineado


    // .fin:

	// ;epilogo
	// add rsp, 8
	// pop rbx
	// pop r15
	// pop r14
	// pop r13
	// pop r12
	// pop rbp
	// ret