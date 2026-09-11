#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "../test-utils.h"
#include "LiveDebugging.h"

// Callback SSE sensible a desalineación de stack
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

int criterio_par(uint32_t id) {
	return (id % 2 == 0);
}

int criterio_mayor_a_10(uint32_t id) {
	return (id > 10);
}

// ==============================================================================
// TESTS EJERCICIO 1: procesar_registros
// ==============================================================================
TEST(test_1_vacio) {
	int64_t res = TEST_CALL_I(procesar_registros, NULL, 0, criterio_par);
	TEST_ASSERT_EQUALS(int32_t, 0, res);
}

TEST(test_1_un_elemento_cumple) {
	registro_t arr[1] = {
		{ .id = 42, .descripcion = "Solo un par" }
	};
	int64_t res = TEST_CALL_I(procesar_registros, arr, 1, criterio_par);
	TEST_ASSERT_EQUALS(int32_t, 1, res);
}

TEST(test_1_un_elemento_no_cumple) {
	registro_t arr[1] = {
		{ .id = 43, .descripcion = "Solo un impar" }
	};
	int64_t res = TEST_CALL_I(procesar_registros, arr, 1, criterio_par);
	TEST_ASSERT_EQUALS(int32_t, 0, res);
}

TEST(test_1_varios_elementos) {
	registro_t arr[5] = {
		{ .id = 2,  .descripcion = "Dos" },
		{ .id = 5,  .descripcion = "Cinco" },
		{ .id = 12, .descripcion = "Doce" },
		{ .id = 15, .descripcion = "Quince" },
		{ .id = 20, .descripcion = "Veinte" }
	};
	int64_t res_pares = TEST_CALL_I(procesar_registros, arr, 5, criterio_par);
	TEST_ASSERT_EQUALS(int32_t, 3, res_pares);
	

	int64_t res_mayores = TEST_CALL_I(procesar_registros, arr, 5, criterio_mayor_a_10);
	TEST_ASSERT_EQUALS(int32_t, 3, res_mayores);
}


TEST(test_1_cuadrados_perfectos_sse) {
	registro_t arr[6] = {
		{ .id = 0,  .descripcion = "Cero (0^2)" },
		{ .id = 9,  .descripcion = "Nueve (3^2)" },
		{ .id = 10, .descripcion = "Diez" },
		{ .id = 16, .descripcion = "Dieciseis (4^2)" },
		{ .id = 20, .descripcion = "Veinte" },
		{ .id = 25, .descripcion = "Veinticinco (5^2)" }
	};
	int64_t res = TEST_CALL_I(procesar_registros, arr, 6, criterio_es_cuadrado_perfecto);
	TEST_ASSERT_EQUALS(int32_t, 4, res);
}


TEST(test_1_lote_con_acumulador) {
	register int32_t total_esperado __asm__("rbx") = 2;
	register uint32_t batch_size __asm__("r13") = 3;

	registro_t arr[3] = {
		{ .id = 9,  .descripcion = "Nueve" },
		{ .id = 16, .descripcion = "Dieciseis" },
		{ .id = 20, .descripcion = "Veinte" }
	};

	int64_t res = TEST_CALL_I(procesar_registros, arr, batch_size, criterio_es_cuadrado_perfecto);

	TEST_ASSERT_EQUALS(int32_t, total_esperado, res);
	TEST_ASSERT(batch_size == 3);
}

void test_ej_1() {
	if (!EJERCICIO_1_HECHO) {
		printf( "El ejercicio 1 no está habilitado aún (EJERCICIO_1_HECHO == FALSE).\n");
		return;
	}

	test_1_vacio();
	test_1_un_elemento_cumple();
	test_1_un_elemento_no_cumple();
	test_1_varios_elementos();
	test_1_cuadrados_perfectos_sse();
	test_1_lote_con_acumulador();
}


// ==============================================================================
// TESTS EJERCICIO 2: clonar_filtrados
// ==============================================================================
TEST(test_2_vacio) {
	uint32_t out_len = 0;
	registro_t* res = TEST_CALL_S(clonar_filtrados, NULL, 0, criterio_par, &out_len);
	TEST_ASSERT(res == NULL);
	TEST_ASSERT_EQUALS(uint32_t, 0, out_len);
}

TEST(test_2_ninguno_cumple) {
	registro_t arr[3] = {
		{ .id = 1, .descripcion = "Uno" },
		{ .id = 3, .descripcion = "Tres" },
		{ .id = 5, .descripcion = "Cinco" }
	};
	uint32_t out_len = 999;
	registro_t* res = TEST_CALL_S(clonar_filtrados, arr, 3, criterio_par, &out_len);
	TEST_ASSERT(res == NULL);
	TEST_ASSERT_EQUALS(uint32_t, 0, out_len);
}

TEST(test_2_clonacion_profunda_y_offsets) {
	registro_t arr[4] = {
		{ .id = 9,  .descripcion = "Original 9" },
		{ .id = 12, .descripcion = "Original 12" },
		{ .id = 16, .descripcion = "Original 16" },
		{ .id = 21, .descripcion = "Original 21" }
	};
	uint32_t out_len = 0;
	registro_t* res = TEST_CALL_S(clonar_filtrados, arr, 4, criterio_es_cuadrado_perfecto, &out_len);

	TEST_ASSERT(res != NULL);
	TEST_ASSERT_EQUALS(uint32_t, 2, out_len);

	TEST_ASSERT_EQUALS(uint32_t, 9, res[0].id);
	strcpy(assert_name, "res[0].descripcion == \"Original 9\"");
	TEST_ASSERT(strcmp(res[0].descripcion, "Original 9") == 0);
	strcpy(assert_name, "res[0].descripcion != arr[0].descripcion (deep copy)");
	TEST_ASSERT(res[0].descripcion != arr[0].descripcion);

	TEST_ASSERT_EQUALS(uint32_t, 16, res[1].id);
	strcpy(assert_name, "res[1].descripcion == \"Original 16\"");
	TEST_ASSERT(strcmp(res[1].descripcion, "Original 16") == 0);
	strcpy(assert_name, "res[1].descripcion != arr[2].descripcion (deep copy)");
	TEST_ASSERT(res[1].descripcion != arr[2].descripcion);

	free(res[0].descripcion);
	free(res[1].descripcion);
	free(res);
}

void test_ej_2() {
	if (!EJERCICIO_2_HECHO) {
		printf( "El ejercicio 2 no está habilitado aún (EJERCICIO_2_HECHO == FALSE).\n");
		return;
	}

	test_2_vacio();
	test_2_ninguno_cumple();
	test_2_clonacion_profunda_y_offsets();
}

int main(int argc, char* argv[]) {
	(void)argc;
	(void)argv;

	char test_suite_name[] = "Live Debugging";

	printf("=====================================\n");
	printf("= %s\n", test_suite_name);
	printf("=====================================\n\n");

	printf("--- EJERCICIO 1 ---\n");
	test_ej_1();

	printf("\n--- EJERCICIO 2 ---\n");
	test_ej_2();

	printf("\n");
	tests_end(test_suite_name);
	return 0;
}
