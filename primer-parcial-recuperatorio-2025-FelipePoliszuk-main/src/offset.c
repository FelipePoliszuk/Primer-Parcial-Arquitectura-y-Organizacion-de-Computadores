#include <stdio.h>
#include <stddef.h>
#include "ejs.h" //reemplazar por el .h 

int main() {
    printf("Offset en_juego: %zu\n", offsetof(Contenido, nombre));
    printf("Offset nombre:   %zu\n", offsetof(Contenido, valor));
    printf("Offset vida:     %zu\n", offsetof(Contenido, color));
    printf("Offset jugador:  %zu\n", offsetof(Contenido, es_tesoro));
	printf("Offset jugador:  %zu\n", offsetof(Contenido, peso));
    printf("SIZE:            %zu\n\n", sizeof(Contenido));

	
    
    printf("Offset mano rojo: %zu\n", offsetof(Habitacion, id));
    printf("Offset mano azul: %zu\n", offsetof(Habitacion, vecinos));
    printf("Offset campo:     %zu\n", offsetof(Habitacion, contenido));
	printf("Offset campo:     %zu\n", offsetof(Habitacion, visitas));
    printf("SIZE:            %zu\n\n", sizeof(Habitacion));
    
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