//*************************************
//Declaración de estructuras
//*************************************

// Lista de arreglos de enteros de 32 bits sin signo.
// next: Siguiente elemento de la lista o NULL si es el final
// categoria: Categoría del nodo
// arreglo: Arreglo de enteros
// longitud: Longitud del arreglo

#include <stdint.h>

typedef struct nodo_s {
    struct nodo_s* next;   //asmdef_offset:NODO_OFFSET_NEXT 0+8
    uint8_t categoria;     //asmdef_offset:NODO_OFFSET_CATEGORIA 8
    uint32_t* arreglo;     //asmdef_offset:NODO_OFFSET_ARREGLO 16
    uint32_t longitud;     //asmdef_offset:NODO_OFFSET_LONGITUD 24
} nodo_t; //asmdef_size:NODO_SIZE 32

typedef struct __attribute__((__packed__)) packed_nodo_s {
    struct packed_nodo_s* next;   //asmdef_offset:PACKED_NODO_OFFSET_NEXT 0+8
    uint8_t categoria;     //asmdef_offset:PACKED_NODO_OFFSET_CATEGORIA 8+1
    uint32_t* arreglo;     //asmdef_offset:PACKED_NODO_OFFSET_ARREGLO 9+8
    uint32_t longitud;     //asmdef_offset:PACKED_NODO_OFFSET_LONGITUD 17+4
} packed_nodo_t; //asmdef_size:PACKED_NODO_SIZE 21

// Puntero al primer nodo que encabeza la lista
typedef struct lista_s {
    nodo_t* head;    //asmdef_offset:LISTA_OFFSET_HEAD 0+8
} lista_t; //asmdef_size:LISTA_SIZE 8

// Puntero al primer nodo que encabeza la lista
typedef struct __attribute__((__packed__)) packed_lista_s {
    packed_nodo_t* head;    //asmdef_offset:PACKED_LISTA_OFFSET_HEAD 0+8
} packed_lista_t; //asmdef_size:PACKED_LISTA_SIZE 8
