#include <stdio.h>
#include <stddef.h>
#include "ejs.h" //reemplazar por el .h 

int main() {
    // printf("Offset en_juego: %zu\n", offsetof(uint32_t, ability_name));
    // printf("Offset nombre:   %zu\n", offsetof(uint32_t, ability_ptr));
    // // printf("Offset vida:     %zu\n", offsetof(directory_entry_t, vida));
    // // printf("Offset jugador:  %zu\n", offsetof(directory_entry_t, jugador));
    // printf("SIZE:            %zu\n\n", sizeof(directory_entry_t));
    
    printf("Offset mano rojo: %zu\n", offsetof(producto_t, usuario));
    printf("Offset mano azul: %zu\n", offsetof(producto_t, categoria));
    printf("Offset campo:     %zu\n", offsetof(producto_t, nombre));
	printf("Offset campo:     %zu\n", offsetof(producto_t, estado));
	printf("Offset campo:     %zu\n", offsetof(producto_t, precio));
	printf("Offset campo:     %zu\n", offsetof(producto_t, id));	
    printf("SIZE:            %zu\n\n", sizeof(producto_t));
    
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