/* Tests del Ejercicio 2 */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../ejs.h"
#include "../utils.h"

static rutina_t hacer_rutina(uint32_t id, uint8_t fase, int8_t ajuste, uint16_t duracion, const char *nombre, uint16_t calorias) {
    rutina_t r;
    memset(&r, 0xAA, sizeof(rutina_t));
    r.id = id;
    r.fase = fase;
    r.ajuste_intensidad = ajuste;
    r.duracion_min = duracion;
    snprintf(r.nombre, sizeof(r.nombre), "%s", nombre);
    r.calorias_base = calorias;
    return r;
}

TEST(test_ej2_combo_valido_con_ajuste_negativo) {
    rutina_t catalogo[4] = {
        hacer_rutina(10, FASE_CALENTAMIENTO, -2, 10, "Movilidad", 50),
        hacer_rutina(20, FASE_ENTRENAMIENTO,  5, 30, "Sprints",   300),
        hacer_rutina(30, FASE_ESTIRAMIENTO,  -5, 15, "Elongacion", 40),
        hacer_rutina(40, FASE_ENTRENAMIENTO,  0, 20, "Trote",     180)
    };
    uint32_t ids[4] = {10, 20, 40, 30};
    rutina_t catalogo_orig[4];
    uint32_t ids_orig[4];
    memcpy(catalogo_orig, catalogo, sizeof(catalogo));
    memcpy(ids_orig, ids, sizeof(ids));

    combo_t *c = TEST_CALL_S(armarCombo, catalogo, 4, ids, 4);

    TEST_ASSERT(c != NULL);
    TEST_ASSERT_EQUALS(uint32_t, 4, c->cant_rutinas);
    TEST_ASSERT(c->rutinas[0] == &catalogo[0]);
    TEST_ASSERT(c->rutinas[1] == &catalogo[1]);
    TEST_ASSERT(c->rutinas[2] == &catalogo[3]);
    TEST_ASSERT(c->rutinas[3] == &catalogo[2]);
    // (1*10 - 20) + (3*30 + 50) + (3*20 + 0) + (2*15 - 50) = -20 + 140 + 60 - 20 = 170
    TEST_ASSERT_EQUALS(int32_t, 170, c->puntaje_intensidad);
    TEST_ASSERT(memcmp(catalogo, catalogo_orig, sizeof(catalogo)) == 0);
    TEST_ASSERT(memcmp(ids, ids_orig, sizeof(ids)) == 0);

    liberar_combo(c);
}

TEST(test_ej2_puntaje_negativo_por_ajuste_minimo) {
    rutina_t catalogo[3] = {
        hacer_rutina(1, FASE_CALENTAMIENTO, -128, 5, "Calent", 20),
        hacer_rutina(2, FASE_ENTRENAMIENTO, -100, 5, "Entren", 30),
        hacer_rutina(3, FASE_ESTIRAMIENTO,   -50, 5, "Estira", 10)
    };
    uint32_t ids[3] = {1, 2, 3};
    rutina_t catalogo_orig[3];
    uint32_t ids_orig[3];
    memcpy(catalogo_orig, catalogo, sizeof(catalogo));
    memcpy(ids_orig, ids, sizeof(ids));

    combo_t *c = TEST_CALL_S(armarCombo, catalogo, 3, ids, 3);

    TEST_ASSERT(c != NULL);
    // (1*5 - 1280) + (3*5 - 1000) + (2*5 - 500) = -1275 - 985 - 490 = -2750
    TEST_ASSERT_EQUALS(int32_t, -2750, c->puntaje_intensidad);
    TEST_ASSERT(memcmp(catalogo, catalogo_orig, sizeof(catalogo)) == 0);
    TEST_ASSERT(memcmp(ids, ids_orig, sizeof(ids)) == 0);

    liberar_combo(c);
}

TEST(test_ej2_combo_una_sola_fase_es_valido) {
    rutina_t catalogo[3] = {
        hacer_rutina(1, FASE_ENTRENAMIENTO, 0, 10, "Entren1", 100),
        hacer_rutina(2, FASE_ENTRENAMIENTO, 2, 20, "Entren2", 200),
        hacer_rutina(3, FASE_ESTIRAMIENTO,  1, 15, "Estira",  50)
    };
    uint32_t ids[2] = {1, 2};
    rutina_t catalogo_orig[3];
    uint32_t ids_orig[2];
    memcpy(catalogo_orig, catalogo, sizeof(catalogo));
    memcpy(ids_orig, ids, sizeof(ids));

    combo_t *c = TEST_CALL_S(armarCombo, catalogo, 3, ids, 2);

    TEST_ASSERT(c != NULL);
    TEST_ASSERT_EQUALS(uint32_t, 2, c->cant_rutinas);
    TEST_ASSERT(c->rutinas[0] == &catalogo[0]);
    TEST_ASSERT(c->rutinas[1] == &catalogo[1]);
    // (3*10 + 0) + (3*20 + 20) = 30 + 80 = 110
    TEST_ASSERT_EQUALS(int32_t, 110, c->puntaje_intensidad);
    TEST_ASSERT(memcmp(catalogo, catalogo_orig, sizeof(catalogo)) == 0);
    TEST_ASSERT(memcmp(ids, ids_orig, sizeof(ids)) == 0);

    liberar_combo(c);
}

TEST(test_ej2_duracion_alta_sin_extension_de_signo) {
    rutina_t catalogo[2] = {
        hacer_rutina(1, FASE_CALENTAMIENTO, -5, 40000, "Maraton", 400),
        hacer_rutina(2, FASE_ESTIRAMIENTO,   2, 32768, "Ultra",   200)
    };
    uint32_t ids[2] = {2, 1};
    rutina_t catalogo_orig[2];
    uint32_t ids_orig[2];
    memcpy(catalogo_orig, catalogo, sizeof(catalogo));
    memcpy(ids_orig, ids, sizeof(ids));

    combo_t *c = TEST_CALL_S(armarCombo, catalogo, 2, ids, 2);

    TEST_ASSERT(c != NULL);
    TEST_ASSERT_EQUALS(uint32_t, 2, c->cant_rutinas);
    TEST_ASSERT(c->rutinas[0] == &catalogo[1]);
    TEST_ASSERT(c->rutinas[1] == &catalogo[0]);
    // (2*32768 + 20) + (1*40000 - 50) = 65556 + 39950 = 105506
    TEST_ASSERT_EQUALS(int32_t, 105506, c->puntaje_intensidad);
    TEST_ASSERT(memcmp(catalogo, catalogo_orig, sizeof(catalogo)) == 0);
    TEST_ASSERT(memcmp(ids, ids_orig, sizeof(ids)) == 0);

    liberar_combo(c);
}

TEST(test_ej2_id_inexistente_hace_rollback) {
    rutina_t catalogo[3] = {
        hacer_rutina(1, FASE_CALENTAMIENTO, 0, 10, "Calent", 40),
        hacer_rutina(2, FASE_ENTRENAMIENTO, 2, 20, "Entren", 200),
        hacer_rutina(3, FASE_ESTIRAMIENTO,  0, 10, "Estira", 30)
    };
    uint32_t ids[3] = {1, 999, 3};
    rutina_t catalogo_orig[3];
    uint32_t ids_orig[3];
    memcpy(catalogo_orig, catalogo, sizeof(catalogo));
    memcpy(ids_orig, ids, sizeof(ids));

    combo_t *c = TEST_CALL_S(armarCombo, catalogo, 3, ids, 3);
    TEST_ASSERT(c == NULL);
    TEST_ASSERT(memcmp(catalogo, catalogo_orig, sizeof(catalogo)) == 0);
    TEST_ASSERT(memcmp(ids, ids_orig, sizeof(ids)) == 0);
}

int main(int argc, char *argv[]) {
    (void)argc;
    (void)argv;
    printf("Corriendo los tests del ejercicio 2 ...\n");

    test_ej2_combo_valido_con_ajuste_negativo();
    test_ej2_puntaje_negativo_por_ajuste_minimo();
    test_ej2_combo_una_sola_fase_es_valido();
    test_ej2_duracion_alta_sin_extension_de_signo();
    test_ej2_id_inexistente_hace_rollback();

    tests_end("Ejercicio 2");
    return 0;
}
