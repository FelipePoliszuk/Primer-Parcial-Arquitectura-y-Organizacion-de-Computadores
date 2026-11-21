/* Tests del Ejercicio 1 */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../ejs.h"
#include "../utils.h"

/* Callback que fuerza el uso de movaps sobre la pila para verificar alineación a 16 bytes */
static bool unificable_mismo_nivel_con_movaps(const disciplina_t *a, const disciplina_t *b) {
    __attribute__((aligned(16))) uint8_t buf[16] = {0};
    __asm__ volatile("movaps %0, %%xmm0" : : "m"(buf) : "xmm0");
    return a->nivel_requerido == b->nivel_requerido;
}

static bool siempre_no_unificable(const disciplina_t *a, const disciplina_t *b) {
    __attribute__((aligned(16))) uint8_t buf[16] = {0};
    __asm__ volatile("movaps %0, %%xmm0" : : "m"(buf) : "xmm0");
    (void)a;
    (void)b;
    return false;
}

TEST(test_ej1_usuario_vacio_agrega_al_final) {
    usuario_t *u = crear_usuario(1, 2);
    disciplina_t *basquet = crear_disciplina(10, "Basquet", 0b0000101, 2);
    disciplina_t basquet_orig = *basquet;

    bool ok = TEST_CALL_B(suscribirDisciplina, u, basquet, unificable_mismo_nivel_con_movaps);

    TEST_ASSERT(ok == true);
    TEST_ASSERT_EQUALS(uint32_t, 1, u->id);
    TEST_ASSERT_EQUALS(uint32_t, 2, u->max_suscripciones);
    TEST_ASSERT_EQUALS(uint32_t, 1, u->cant_suscripciones);
    TEST_ASSERT(u->suscripciones[0].disciplina == basquet);
    TEST_ASSERT(u->suscripciones[0].activa == true);
    TEST_ASSERT_EQUALS(uint32_t, 4, u->suscripciones[0].semanas_restantes);
    TEST_ASSERT(memcmp(basquet, &basquet_orig, sizeof(disciplina_t)) == 0);

    free(basquet);
    liberar_usuario(u);
}

TEST(test_ej1_capacidad_cero_rechaza) {
    usuario_t *u = crear_usuario(2, 0);
    disciplina_t *judo = crear_disciplina(20, "Judo", 0b0000010, 1);
    disciplina_t judo_orig = *judo;

    bool ok = TEST_CALL_B(suscribirDisciplina, u, judo, unificable_mismo_nivel_con_movaps);

    TEST_ASSERT(ok == false);
    TEST_ASSERT_EQUALS(uint32_t, 2, u->id);
    TEST_ASSERT_EQUALS(uint32_t, 0, u->max_suscripciones);
    TEST_ASSERT_EQUALS(uint32_t, 0, u->cant_suscripciones);
    TEST_ASSERT(memcmp(judo, &judo_orig, sizeof(disciplina_t)) == 0);

    free(judo);
    liberar_usuario(u);
}

TEST(test_ej1_duplicado_rechaza_sin_modificar) {
    usuario_t *u = crear_usuario(3, 3);
    disciplina_t *voley = crear_disciplina(30, "Voley", 0b0001010, 2);
    disciplina_t *voley_dup = crear_disciplina(30, "Voley", 0b0100000, 2);
    agregar_suscripcion_inicial(u, voley, true, 7);
    disciplina_t voley_orig = *voley;
    disciplina_t voley_dup_orig = *voley_dup;

    bool ok = TEST_CALL_B(suscribirDisciplina, u, voley_dup, unificable_mismo_nivel_con_movaps);

    TEST_ASSERT(ok == false);
    TEST_ASSERT_EQUALS(uint32_t, 3, u->id);
    TEST_ASSERT_EQUALS(uint32_t, 3, u->max_suscripciones);
    TEST_ASSERT_EQUALS(uint32_t, 1, u->cant_suscripciones);
    TEST_ASSERT(u->suscripciones[0].disciplina == voley);
    TEST_ASSERT(u->suscripciones[0].activa == true);
    TEST_ASSERT_EQUALS(uint32_t, 7, u->suscripciones[0].semanas_restantes);
    TEST_ASSERT(memcmp(voley, &voley_orig, sizeof(disciplina_t)) == 0);
    TEST_ASSERT(memcmp(voley_dup, &voley_dup_orig, sizeof(disciplina_t)) == 0);

    free(voley);
    free(voley_dup);
    liberar_usuario(u);
}

TEST(test_ej1_sin_solapamiento_y_capacidad_llena) {
    usuario_t *u = crear_usuario(4, 2);
    disciplina_t *d1 = crear_disciplina(1, "Natacion", 0b0000001, 1); // Lun
    disciplina_t *d2 = crear_disciplina(2, "Tenis",    0b0000100, 2); // Mie
    disciplina_t *d3 = crear_disciplina(3, "Remo",     0b0010000, 3); // Vie

    agregar_suscripcion_inicial(u, d1, true, 5);
    disciplina_t d1_orig, d2_orig, d3_orig;
    memcpy(&d1_orig, d1, sizeof(disciplina_t));
    memcpy(&d2_orig, d2, sizeof(disciplina_t));
    memcpy(&d3_orig, d3, sizeof(disciplina_t));

    bool ok1 = TEST_CALL_B(suscribirDisciplina, u, d2, siempre_no_unificable);
    TEST_ASSERT(ok1 == true);
    TEST_ASSERT_EQUALS(uint32_t, 2, u->cant_suscripciones);
    TEST_ASSERT(u->suscripciones[0].disciplina == d1);
    TEST_ASSERT(u->suscripciones[0].activa == true);
    TEST_ASSERT_EQUALS(uint32_t, 5, u->suscripciones[0].semanas_restantes);
    TEST_ASSERT(u->suscripciones[1].disciplina == d2);
    TEST_ASSERT(u->suscripciones[1].activa == true);
    TEST_ASSERT_EQUALS(uint32_t, 4, u->suscripciones[1].semanas_restantes);

    bool ok2 = TEST_CALL_B(suscribirDisciplina, u, d3, siempre_no_unificable);
    TEST_ASSERT(ok2 == false);
    TEST_ASSERT_EQUALS(uint32_t, 4, u->id);
    TEST_ASSERT_EQUALS(uint32_t, 2, u->max_suscripciones);
    TEST_ASSERT_EQUALS(uint32_t, 2, u->cant_suscripciones);
    TEST_ASSERT(memcmp(d1, &d1_orig, sizeof(disciplina_t)) == 0);
    TEST_ASSERT(memcmp(d2, &d2_orig, sizeof(disciplina_t)) == 0);
    TEST_ASSERT(memcmp(d3, &d3_orig, sizeof(disciplina_t)) == 0);

    free(d1);
    free(d2);
    free(d3);
    liberar_usuario(u);
}

TEST(test_ej1_solapamiento_unificable_con_capacidad_llena) {
    usuario_t *u = crear_usuario(5, 1);
    disciplina_t *d1 = crear_disciplina(10, "Basquet", 0b0000101, 2); // Lun, Mie
    disciplina_t *d2 = crear_disciplina(11, "Handball", 0b0001100, 2); // Mie, Jue (solapa Mie)
    agregar_suscripcion_inicial(u, d1, true, 6);
    disciplina_t d1_orig = *d1;
    disciplina_t d2_orig = *d2;

    bool ok = TEST_CALL_B(suscribirDisciplina, u, d2, unificable_mismo_nivel_con_movaps);

    TEST_ASSERT(ok == true);
    TEST_ASSERT_EQUALS(uint32_t, 5, u->id);
    TEST_ASSERT_EQUALS(uint32_t, 1, u->max_suscripciones);
    TEST_ASSERT_EQUALS(uint32_t, 1, u->cant_suscripciones);
    disciplina_t *unif = u->suscripciones[0].disciplina;
    TEST_ASSERT(unif != d1 && unif != d2);
    TEST_ASSERT_EQUALS(uint32_t, 0b0001101, unif->dias);
    TEST_ASSERT_EQUALS(uint32_t, 2, unif->nivel_requerido);
    TEST_ASSERT(u->suscripciones[0].activa == true);
    TEST_ASSERT_EQUALS(uint32_t, 6, u->suscripciones[0].semanas_restantes);
    TEST_ASSERT(memcmp(d1, &d1_orig, sizeof(disciplina_t)) == 0);
    TEST_ASSERT(memcmp(d2, &d2_orig, sizeof(disciplina_t)) == 0);

    free(unif);
    free(d1);
    free(d2);
    liberar_usuario(u);
}

TEST(test_ej1_solapa_no_unificable_agrega_al_final) {
    usuario_t *u = crear_usuario(6, 3);
    disciplina_t *d1 = crear_disciplina(1, "Boxeo",   0b0000011, 3); // Lun, Mar
    disciplina_t *cand = crear_disciplina(3, "Pilates", 0b0000101, 1); // Lun (solapa, no unificable)
    agregar_suscripcion_inicial(u, d1, true, 4);
    disciplina_t d1_orig = *d1;
    disciplina_t cand_orig = *cand;

    bool ok = TEST_CALL_B(suscribirDisciplina, u, cand, unificable_mismo_nivel_con_movaps);

    TEST_ASSERT(ok == true);
    TEST_ASSERT_EQUALS(uint32_t, 2, u->cant_suscripciones);
    TEST_ASSERT(u->suscripciones[0].disciplina == d1);
    TEST_ASSERT(u->suscripciones[1].disciplina == cand);
    TEST_ASSERT(u->suscripciones[1].activa == true);
    TEST_ASSERT_EQUALS(uint32_t, 4, u->suscripciones[1].semanas_restantes);
    TEST_ASSERT(memcmp(d1, &d1_orig, sizeof(disciplina_t)) == 0);
    TEST_ASSERT(memcmp(cand, &cand_orig, sizeof(disciplina_t)) == 0);

    free(d1);
    free(cand);
    liberar_usuario(u);
}

TEST(test_ej1_solapa_primero_no_unificable_unifica_con_segundo) {
    usuario_t *u = crear_usuario(8, 2);
    disciplina_t *d1 = crear_disciplina(1, "Boxeo",   0b0000011, 3); // Lun, Mar (no unificable)
    disciplina_t *d2 = crear_disciplina(2, "Yoga",    0b0001100, 1); // Mie, Jue (unificable)
    disciplina_t *cand = crear_disciplina(3, "Pilates", 0b0000101, 1); // Lun, Mie
    agregar_suscripcion_inicial(u, d1, true, 4);
    agregar_suscripcion_inicial(u, d2, true, 5);
    disciplina_t d1_orig = *d1;
    disciplina_t d2_orig = *d2;
    disciplina_t cand_orig = *cand;

    bool ok = TEST_CALL_B(suscribirDisciplina, u, cand, unificable_mismo_nivel_con_movaps);

    TEST_ASSERT(ok == true);
    TEST_ASSERT_EQUALS(uint32_t, 2, u->cant_suscripciones);
    TEST_ASSERT(u->suscripciones[0].disciplina == d1);
    disciplina_t *unif = u->suscripciones[1].disciplina;
    TEST_ASSERT(unif != d2 && unif != cand);
    TEST_ASSERT_EQUALS(uint32_t, 0b0001101, unif->dias);
    TEST_ASSERT(u->suscripciones[1].activa == true);
    TEST_ASSERT_EQUALS(uint32_t, 5, u->suscripciones[1].semanas_restantes);
    TEST_ASSERT(memcmp(d1, &d1_orig, sizeof(disciplina_t)) == 0);
    TEST_ASSERT(memcmp(d2, &d2_orig, sizeof(disciplina_t)) == 0);
    TEST_ASSERT(memcmp(cand, &cand_orig, sizeof(disciplina_t)) == 0);

    free(unif);
    free(d1);
    free(d2);
    free(cand);
    liberar_usuario(u);
}

TEST(test_ej1_ids_con_bit_alto_en_uno) {
    usuario_t *u = crear_usuario(7, 2);
    disciplina_t *d1 = crear_disciplina(0x80000001u, "Esgrima", 0b0000001, 1);
    disciplina_t *d2 = crear_disciplina(0xFFFFFFFFu, "Arquer",  0b0000010, 2);
    disciplina_t *d1_dup = crear_disciplina(0x80000001u, "Esgrima", 0b0000100, 1);
    disciplina_t d1_orig = *d1;
    disciplina_t d2_orig = *d2;
    disciplina_t d1_dup_orig = *d1_dup;

    bool ok1 = TEST_CALL_B(suscribirDisciplina, u, d1, siempre_no_unificable);
    bool ok2 = TEST_CALL_B(suscribirDisciplina, u, d2, siempre_no_unificable);
    bool ok3 = TEST_CALL_B(suscribirDisciplina, u, d1_dup, siempre_no_unificable);

    TEST_ASSERT(ok1 == true);
    TEST_ASSERT(ok2 == true);
    TEST_ASSERT(ok3 == false);
    TEST_ASSERT_EQUALS(uint32_t, 2, u->cant_suscripciones);
    TEST_ASSERT(u->suscripciones[0].disciplina == d1);
    TEST_ASSERT(u->suscripciones[1].disciplina == d2);
    TEST_ASSERT(memcmp(d1, &d1_orig, sizeof(disciplina_t)) == 0);
    TEST_ASSERT(memcmp(d2, &d2_orig, sizeof(disciplina_t)) == 0);
    TEST_ASSERT(memcmp(d1_dup, &d1_dup_orig, sizeof(disciplina_t)) == 0);

    free(d1);
    free(d2);
    free(d1_dup);
    liberar_usuario(u);
}

int main(int argc, char *argv[]) {
    (void)argc;
    (void)argv;
    printf("Corriendo los tests del ejercicio 1 ...\n");

    test_ej1_usuario_vacio_agrega_al_final();
    test_ej1_capacidad_cero_rechaza();
    test_ej1_duplicado_rechaza_sin_modificar();
    test_ej1_sin_solapamiento_y_capacidad_llena();
    test_ej1_solapamiento_unificable_con_capacidad_llena();
    test_ej1_solapa_no_unificable_agrega_al_final();
    test_ej1_solapa_primero_no_unificable_unifica_con_segundo();
    test_ej1_ids_con_bit_alto_en_uno();

    tests_end("Ejercicio 1");
    return 0;
}
