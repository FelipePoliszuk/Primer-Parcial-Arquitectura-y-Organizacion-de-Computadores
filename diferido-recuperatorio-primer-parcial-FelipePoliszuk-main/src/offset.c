#include <stdio.h>
#include <stddef.h>
#include "ejs.h" //reemplazar por el .h 

int main() {
    // printf("Offset en_juego: %zu\n", offsetof(item_kind_t, ITEM_KIND_TENT));
    // printf("Offset nombre:   %zu\n", offsetof(item_kind_t, ITEM_KIND_SLEEPING_BAG));
    // printf("Offset vida:     %zu\n", offsetof(item_kind_t, vida));
    // printf("Offset jugador:  %zu\n", offsetof(item_kind_t, jugador));
    // printf("SIZE:            %zu\n\n", sizeof(item_kind_t));
    
    printf("Offset mano rojo: %zu\n", offsetof(item_t, kind));
    printf("Offset mano azul: %zu\n", offsetof(item_t, weight));
    // printf("Offset campo:     %zu\n", offsetof(item_t, __archetype));
	// printf("Offset campo:     %zu\n", offsetof(item_t, face_up));
    printf("SIZE:            %zu\n\n", sizeof(item_t));
    
    printf("Offset invocar: %zu\n", offsetof(backpack_t, items));
    printf("Offset destino: %zu\n", offsetof(backpack_t, max_weight));
    printf("Offset siguiente:     %zu\n", offsetof(backpack_t, item_count));
    printf("SIZE:            %zu\n\n", sizeof(backpack_t));

	printf("Offset invocar: %zu\n", offsetof(destination_t, name));
    printf("Offset destino: %zu\n", offsetof(destination_t, requirements));
    printf("Offset siguiente:     %zu\n", offsetof(destination_t, requirements_size));
    printf("SIZE:            %zu\n\n", sizeof(destination_t));

	printf("Offset invocar: %zu\n", offsetof(event_t, next));
    printf("Offset destino: %zu\n", offsetof(event_t, destination));
    // printf("Offset siguiente:     %zu\n", offsetof(event_t, item_count));
    printf("SIZE:            %zu\n\n", sizeof(event_t));

	printf("Offset invocar: %zu\n", offsetof(itinerary_t, first));
    // printf("Offset destino: %zu\n", offsetof(itinerary_t, max_weight));
    // printf("Offset siguiente:     %zu\n", offsetof(itinerary_t, item_count));
    printf("SIZE:            %zu\n\n", sizeof(itinerary_t));
    

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