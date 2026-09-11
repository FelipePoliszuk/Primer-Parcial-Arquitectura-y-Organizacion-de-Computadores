//*************************************
// Declaración de estructuras
//*************************************
#pragma once
#include <stdint.h>

typedef struct registro_s {
	uint32_t id;          //asmdef_offset:REGISTRO_OFFSET_ID
	char* descripcion;    //asmdef_offset:REGISTRO_OFFSET_DESCRIPCION
} registro_t;	//asmdef_size:REGISTRO_SIZE
