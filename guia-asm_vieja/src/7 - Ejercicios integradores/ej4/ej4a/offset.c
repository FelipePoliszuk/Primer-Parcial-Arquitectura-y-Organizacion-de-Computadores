#include <stdio.h>
#include <stddef.h>
#include "ej4a.h" //reemplazar por el .h 

int main() {
    printf("Offset en_juego: %zu\n", offsetof(directory_entry_t, ability_name));
    printf("Offset nombre:   %zu\n", offsetof(directory_entry_t, ability_ptr));
    // printf("Offset vida:     %zu\n", offsetof(directory_entry_t, vida));
    // printf("Offset jugador:  %zu\n", offsetof(directory_entry_t, jugador));
    printf("SIZE:            %zu\n\n", sizeof(directory_entry_t));
    
    printf("Offset mano rojo: %zu\n", offsetof(fantastruco_t, __dir));
    printf("Offset mano azul: %zu\n", offsetof(fantastruco_t, __dir_entries));
    printf("Offset campo:     %zu\n", offsetof(fantastruco_t, __archetype));
	printf("Offset campo:     %zu\n", offsetof(fantastruco_t, face_up));
    printf("SIZE:            %zu\n\n", sizeof(fantastruco_t));
    
    // printf("Offset invocar: %zu\n", offsetof(accion_t, invocar));
    // printf("Offset destino: %zu\n", offsetof(accion_t, destino));
    // printf("Offset siguiente:     %zu\n", offsetof(accion_t, siguiente));
    // printf("SIZE:            %zu\n\n", sizeof(accion_t));
    

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

	// xor r12, r12	;limpio posible basura
	// xor r13, r13	;limpio posible basura
	// xor r14, r14	;limpio posible basura
	// xor r15, r15	;limpio posible basura
	// xor rbx, rbx	;limpio posible basura





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