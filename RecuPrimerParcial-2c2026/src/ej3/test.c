/* Tests del Ejercicio 3 */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../ejs.h"
#include "../utils.h"

static cancha_t hacer_cancha(uint32_t disciplina_id, uint16_t min_jugadores, uint16_t max_cupos) {
    cancha_t c;
    memset(&c, 0xAA, sizeof(cancha_t));
    c.disciplina_id = disciplina_id;
    c.min_jugadores = min_jugadores;
    c.max_cupos = max_cupos;
    return c;
}

TEST(test_ej3_lista_vacia_retorna_null) {
    lista_solicitudes_t *lista = crear_lista_solicitudes();
    cancha_t cancha = hacer_cancha(10, 2, 5);
    cancha_t cancha_orig = cancha;

    reserva_t *res = TEST_CALL_S(confirmarReserva, lista, &cancha, (uint8_t)0b0000100);

    TEST_ASSERT(res == NULL);
    TEST_ASSERT(lista->first == NULL);
    TEST_ASSERT(memcmp(&cancha, &cancha_orig, sizeof(cancha_t)) == 0);

    liberar_lista_solicitudes(lista);
}

TEST(test_ej3_depura_invalidez_por_dia_y_disciplina_y_confirma) {
    usuario_t *u1 = crear_usuario(1, 0);
    usuario_t *u2 = crear_usuario(2, 0);
    usuario_t *u3 = crear_usuario(3, 0);
    usuario_t *u4 = crear_usuario(4, 0);
    usuario_t *u5 = crear_usuario(5, 0);
    usuario_t u1_orig = *u1, u2_orig = *u2, u3_orig = *u3, u4_orig = *u4, u5_orig = *u5;

    lista_solicitudes_t *lista = crear_lista_solicitudes();
    agregar_solicitud(lista, u1, 0b0000010, 10); // dia invalido (cabeza)
    agregar_solicitud(lista, u2, 0b0000101, 10); // valido
    agregar_solicitud(lista, u3, 0b0000100, 20); // disciplina distinta (medio)
    agregar_solicitud(lista, u4, 0b0001100, 10); // valido
    agregar_solicitud(lista, u5, 0b0010000, 10); // dia invalido (cola)

    cancha_t cancha = hacer_cancha(10, 2, 4);
    cancha_t cancha_orig = cancha;

    reserva_t *res = TEST_CALL_S(confirmarReserva, lista, &cancha, (uint8_t)0b0000100);

    TEST_ASSERT(res != NULL);
    TEST_ASSERT(res->cancha == &cancha);
    TEST_ASSERT_EQUALS(uint32_t, 0b0000100, res->dia_bitmask);
    TEST_ASSERT_EQUALS(uint32_t, 2, res->cant_participantes);
    TEST_ASSERT(memcmp(&cancha, &cancha_orig, sizeof(cancha_t)) == 0);

    // Lista depurada mantiene las validas y sus campos intactos: u2 -> u4 -> NULL
    TEST_ASSERT(lista->first != NULL);
    TEST_ASSERT(lista->first->usuario == u2);
    TEST_ASSERT_EQUALS(uint32_t, 0b0000101, lista->first->dias_disponibles);
    TEST_ASSERT_EQUALS(uint32_t, 10, lista->first->disciplina_id);
    TEST_ASSERT(lista->first->next != NULL);
    TEST_ASSERT(lista->first->next->usuario == u4);
    TEST_ASSERT_EQUALS(uint32_t, 0b0001100, lista->first->next->dias_disponibles);
    TEST_ASSERT_EQUALS(uint32_t, 10, lista->first->next->disciplina_id);
    TEST_ASSERT(lista->first->next->next == NULL);

    TEST_ASSERT(memcmp(u1, &u1_orig, sizeof(usuario_t)) == 0);
    TEST_ASSERT(memcmp(u2, &u2_orig, sizeof(usuario_t)) == 0);
    TEST_ASSERT(memcmp(u3, &u3_orig, sizeof(usuario_t)) == 0);
    TEST_ASSERT(memcmp(u4, &u4_orig, sizeof(usuario_t)) == 0);
    TEST_ASSERT(memcmp(u5, &u5_orig, sizeof(usuario_t)) == 0);

    liberar_reserva(res);
    liberar_lista_solicitudes(lista);
    liberar_usuario(u1);
    liberar_usuario(u2);
    liberar_usuario(u3);
    liberar_usuario(u4);
    liberar_usuario(u5);
}

TEST(test_ej3_limita_a_max_cupos) {
    usuario_t *u1 = crear_usuario(1, 0);
    usuario_t *u2 = crear_usuario(2, 0);
    usuario_t *u3 = crear_usuario(3, 0);

    lista_solicitudes_t *lista = crear_lista_solicitudes();
    agregar_solicitud(lista, u1, 0b0000010, 30);
    agregar_solicitud(lista, u2, 0b0000010, 30);
    agregar_solicitud(lista, u3, 0b0000010, 30);

    cancha_t cancha = hacer_cancha(30, 2, 2);

    reserva_t *res = TEST_CALL_S(confirmarReserva, lista, &cancha, (uint8_t)0b0000010);

    TEST_ASSERT(res != NULL);
    TEST_ASSERT(res->cancha == &cancha);
    TEST_ASSERT_EQUALS(uint32_t, 0b0000010, res->dia_bitmask);
    TEST_ASSERT_EQUALS(uint32_t, 2, res->cant_participantes);

    liberar_reserva(res);
    liberar_lista_solicitudes(lista);
    liberar_usuario(u1);
    liberar_usuario(u2);
    liberar_usuario(u3);
}

TEST(test_ej3_menos_que_min_jugadores_retorna_null) {
    usuario_t *u1 = crear_usuario(1, 0);
    usuario_t *u2 = crear_usuario(2, 0);
    usuario_t *u3 = crear_usuario(3, 0);

    lista_solicitudes_t *lista = crear_lista_solicitudes();
    agregar_solicitud(lista, u1, 0b0000010, 10); // valido
    agregar_solicitud(lista, u2, 0b0000010, 20); // otra disciplina -> eliminado
    agregar_solicitud(lista, u3, 0b0000001, 10); // otro dia -> eliminado

    cancha_t cancha = hacer_cancha(10, 2, 4);

    reserva_t *res = TEST_CALL_S(confirmarReserva, lista, &cancha, (uint8_t)0b0000010);

    TEST_ASSERT(res == NULL);
    TEST_ASSERT(lista->first != NULL);
    TEST_ASSERT(lista->first->usuario == u1);
    TEST_ASSERT(lista->first->next == NULL);

    liberar_lista_solicitudes(lista);
    liberar_usuario(u1);
    liberar_usuario(u2);
    liberar_usuario(u3);
}

TEST(test_ej3_todos_invalidos_vacia_lista_y_retorna_null) {
    usuario_t *u1 = crear_usuario(1, 0);
    usuario_t *u2 = crear_usuario(2, 0);
    usuario_t *u3 = crear_usuario(3, 0);
    usuario_t u1_orig = *u1, u2_orig = *u2, u3_orig = *u3;

    lista_solicitudes_t *lista = crear_lista_solicitudes();
    agregar_solicitud(lista, u1, 0b0000001, 10); // otro dia
    agregar_solicitud(lista, u2, 0b0000010, 99); // otra disciplina
    agregar_solicitud(lista, u3, 0b0000000, 10); // sin dias

    cancha_t cancha = hacer_cancha(10, 1, 4);
    cancha_t cancha_orig = cancha;

    reserva_t *res = TEST_CALL_S(confirmarReserva, lista, &cancha, (uint8_t)0b0000010);

    TEST_ASSERT(res == NULL);
    TEST_ASSERT(lista->first == NULL);
    TEST_ASSERT(memcmp(&cancha, &cancha_orig, sizeof(cancha_t)) == 0);
    TEST_ASSERT(memcmp(u1, &u1_orig, sizeof(usuario_t)) == 0);
    TEST_ASSERT(memcmp(u2, &u2_orig, sizeof(usuario_t)) == 0);
    TEST_ASSERT(memcmp(u3, &u3_orig, sizeof(usuario_t)) == 0);

    liberar_lista_solicitudes(lista);
    liberar_usuario(u1);
    liberar_usuario(u2);
    liberar_usuario(u3);
}

TEST(test_ej3_exactamente_min_jugadores_confirma) {
    usuario_t *u1 = crear_usuario(1, 0);
    usuario_t *u2 = crear_usuario(2, 0);
    usuario_t *u3 = crear_usuario(3, 0);

    lista_solicitudes_t *lista = crear_lista_solicitudes();
    agregar_solicitud(lista, u1, 0b0001000, 5);  // valido
    agregar_solicitud(lista, u2, 0b0000001, 5);  // otro dia -> eliminado
    agregar_solicitud(lista, u3, 0b0001000, 5);  // valido

    cancha_t cancha = hacer_cancha(5, 2, 6);
    cancha_t cancha_orig = cancha;

    reserva_t *res = TEST_CALL_S(confirmarReserva, lista, &cancha, (uint8_t)0b0001000);

    TEST_ASSERT(res != NULL);
    TEST_ASSERT(res->cancha == &cancha);
    TEST_ASSERT_EQUALS(uint32_t, 0b0001000, res->dia_bitmask);
    TEST_ASSERT_EQUALS(uint32_t, 2, res->cant_participantes);
    TEST_ASSERT(memcmp(&cancha, &cancha_orig, sizeof(cancha_t)) == 0);
    TEST_ASSERT(lista->first != NULL);
    TEST_ASSERT(lista->first->usuario == u1);
    TEST_ASSERT(lista->first->next != NULL);
    TEST_ASSERT(lista->first->next->usuario == u3);
    TEST_ASSERT(lista->first->next->next == NULL);

    liberar_reserva(res);
    liberar_lista_solicitudes(lista);
    liberar_usuario(u1);
    liberar_usuario(u2);
    liberar_usuario(u3);
}

int main(int argc, char *argv[]) {
    (void)argc;
    (void)argv;
    printf("Corriendo los tests del ejercicio 3 ...\n");

    test_ej3_lista_vacia_retorna_null();
    test_ej3_depura_invalidez_por_dia_y_disciplina_y_confirma();
    test_ej3_limita_a_max_cupos();
    test_ej3_menos_que_min_jugadores_retorna_null();
    test_ej3_todos_invalidos_vacia_lista_y_retorna_null();
    test_ej3_exactamente_min_jugadores_confirma();

    tests_end("Ejercicio 3");
    return 0;
}
