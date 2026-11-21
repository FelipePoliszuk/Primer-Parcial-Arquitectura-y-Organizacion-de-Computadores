#ifndef UTILS_H
#define UTILS_H

#include "../test_utils/test-utils.h"
#include "./ejs.h"

//*************************************
// Declaraciones de funciones auxiliares para tests
//*************************************

disciplina_t *crear_disciplina(uint32_t id, const char *nombre, uint8_t dias, uint8_t nivel_requerido);
usuario_t *crear_usuario(uint32_t id, uint32_t max_suscripciones);
void agregar_suscripcion_inicial(usuario_t *u, disciplina_t *d, bool activa, uint16_t semanas);
void liberar_usuario(usuario_t *u);

void liberar_combo(combo_t *c);

lista_solicitudes_t *crear_lista_solicitudes(void);
void agregar_solicitud(lista_solicitudes_t *lista, usuario_t *u, uint8_t dias_disponibles, uint32_t disciplina_id);
void liberar_lista_solicitudes(lista_solicitudes_t *lista);
void liberar_reserva(reserva_t *r);

#endif
