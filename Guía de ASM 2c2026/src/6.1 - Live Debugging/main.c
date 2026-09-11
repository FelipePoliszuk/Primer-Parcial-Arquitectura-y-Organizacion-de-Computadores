#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "../test-utils.h"
#include "LiveDebugging.h"

int criterio_es_cuadrado_perfecto(uint32_t id) {
	_Alignas(16) double vector_val[2] = { (double)id, 0.0 };

	__asm__ volatile (
		"movapd (%0), %%xmm0\n\t"
		"sqrtsd %%xmm0, %%xmm0\n\t"
		"movapd %%xmm0, (%0)\n\t"
		:
		: "r"(vector_val)
		: "xmm0", "memory"
	);

	uint32_t raiz_truncada = (uint32_t)vector_val[0];
	return (raiz_truncada * raiz_truncada == id);
}

int criterio_pares(uint32_t id) {
	return (id % 2 == 0);
}

int main(int argc, char* argv[]) {
	(void)argc;
	(void)argv;

	printf("============================================================\n");
	printf("   TALLER DE LIVE DEBUGGING (GDB & VALGRIND)\n");
	printf("============================================================\n\n");

	registro_t registros[4] = {
		{ .id = 9,  .descripcion = "Nueve (3^2)" },
		{ .id = 15, .descripcion = "Quince" },
		{ .id = 25, .descripcion = "Veinticinco (5^2)" },
		{ .id = 33, .descripcion = "Treinta y tres" }
	};

	printf("[1] Probando procesar_registros (GDB / Stack Alignment / Calling Convention)...\n");
	int64_t total = procesar_registros(registros, 4, criterio_es_cuadrado_perfecto);
	printf("    Resultado obtenido: %ld (Esperado: 2 -> 9 y 25 son cuadrados perfectos)\n\n", total);

	printf("[2] Probando clonar_filtrados (Valgrind / Malloc / Invalid Reads-Writes)...\n");
	uint32_t out_len = 0;
	registro_t* clonados = clonar_filtrados(registros, 4, criterio_pares, &out_len);
	printf("    Elementos clonados: %u\n", out_len);

	if (clonados != NULL) {
		for (uint32_t i = 0; i < out_len; i++) {
			printf("    - [%u] ID: %u, Desc: %s\n", i, clonados[i].id, clonados[i].descripcion);
			free(clonados[i].descripcion);
		}
		free(clonados);
	}

	return 0;
}



























