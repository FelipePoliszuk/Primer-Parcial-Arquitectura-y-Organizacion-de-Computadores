#include <stdio.h>
#include <stddef.h>
#include "ejs.h" //reemplazar por el .h 

int main() {
    printf("Offset en_juego: %zu\n", offsetof(info_t, nombre));
    printf("Offset nombre:   %zu\n", offsetof(info_t, tipo));
    printf("Offset vida:     %zu\n", offsetof(info_t, nivel));
    // printf("Offset vida:     %zu\n", offsetof(info_t, columnas));
    // printf("Offset vida:     %zu\n", offsetof(info_t, nivel));
    printf("SIZE:            %zu\n\n", sizeof(info_t));
    
    // printf("Offset mano rojo: %zu\n", offsetof(fantastruco_t, __dir));
    // printf("Offset mano azul: %zu\n", offsetof(fantastruco_t, __dir_entries));
    // printf("Offset campo:     %zu\n", offsetof(fantastruco_t, __archetype));
	// printf("Offset campo:     %zu\n", offsetof(fantastruco_t, face_up));
    // printf("SIZE:            %zu\n\n", sizeof(fantastruco_t));

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

// gcc -S -Og -masm=intel -fverbose-asm -fno-asynchronous-unwind-tables -fcf-protection=none -U_FORTIFY_SOURCE ej2.c -o ej2.s

	// ;epilogo
	// add rsp, 8
	// pop rbx
	// pop r15
	// pop r14
	// pop r13
	// pop r12
	// pop rbp
	// ret