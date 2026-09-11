#pragma once
#include <stdbool.h>
#include <stdint.h>
#include "structs.h"

// Marca el ejercicio como hecho (`true`) o pendiente (`false`).
extern bool EJERCICIO_1_HECHO;
extern bool EJERCICIO_2_HECHO;

// Ejercicio 1: Conteo de elementos filtrados 
int64_t procesar_registros(registro_t* array, uint32_t len, int (*criterio)(uint32_t));

// Ejercicio 2: Clonación y filtrado con memoria dinámica
registro_t* clonar_filtrados(registro_t* array, uint32_t len, int (*criterio)(uint32_t), uint32_t* out_len);
