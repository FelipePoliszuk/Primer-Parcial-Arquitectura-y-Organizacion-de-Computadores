#pragma once
#include <assert.h>
#include <ctype.h>
#include <math.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

//*************************************
// Declaración de estructuras del examen
//*************************************
// NOTA: Cada campo y cierre de struct debe incluir los comentarios
// `asmdef_offset:<CONSTANTE>` y `asmdef_size:<CONSTANTE>` para que
// `test_utils/parse.py` y `make check_offsets` validen los offsets en ASM.

typedef enum {
    FASE_CALENTAMIENTO = 1,
    FASE_ESTIRAMIENTO  = 2,
    FASE_ENTRENAMIENTO = 3
} fase_t;

// Bitmask de días: bit 0 = Lunes ... bit 6 = Domingo
typedef struct {
    uint8_t dias;                // asmdef_offset:DISCIPLINA_DIAS_OFFSET
    char nombre[19];             // asmdef_offset:DISCIPLINA_NOMBRE_OFFSET
    uint32_t id;                 // asmdef_offset:DISCIPLINA_ID_OFFSET
    uint8_t nivel_requerido;     // asmdef_offset:DISCIPLINA_NIVEL_OFFSET
} disciplina_t;                  // asmdef_size:DISCIPLINA_SIZE

typedef struct {
    bool activa;                 // asmdef_offset:SUSCRIPCION_ACTIVA_OFFSET
    disciplina_t *disciplina;    // asmdef_offset:SUSCRIPCION_DISCIPLINA_OFFSET
    uint16_t semanas_restantes;  // asmdef_offset:SUSCRIPCION_SEMANAS_OFFSET
} suscripcion_t;                 // asmdef_size:SUSCRIPCION_SIZE

typedef struct {
    uint32_t id;                 // asmdef_offset:USUARIO_ID_OFFSET
    suscripcion_t *suscripciones;// asmdef_offset:USUARIO_SUSC_OFFSET
    uint32_t cant_suscripciones; // asmdef_offset:USUARIO_CANT_SUSC_OFFSET
    uint32_t max_suscripciones;  // asmdef_offset:USUARIO_MAX_SUSC_OFFSET
} usuario_t;                     // asmdef_size:USUARIO_SIZE

// Estructuras para Ejercicio 2
typedef struct {
    uint8_t fase;                // asmdef_offset:RUTINA_FASE_OFFSET
    uint32_t id;                 // asmdef_offset:RUTINA_ID_OFFSET
    int8_t ajuste_intensidad;    // asmdef_offset:RUTINA_AJUSTE_OFFSET
    uint16_t duracion_min;       // asmdef_offset:RUTINA_DURACION_OFFSET
    char nombre[21];             // asmdef_offset:RUTINA_NOMBRE_OFFSET
    uint16_t calorias_base;      // asmdef_offset:RUTINA_CALORIAS_OFFSET
} rutina_t;                      // asmdef_size:RUTINA_SIZE

typedef struct {
    rutina_t **rutinas;          // asmdef_offset:COMBO_RUTINAS_OFFSET
    uint32_t cant_rutinas;       // asmdef_offset:COMBO_CANT_OFFSET
    int32_t puntaje_intensidad;  // asmdef_offset:COMBO_PUNTAJE_OFFSET
} combo_t;                       // asmdef_size:COMBO_SIZE

// Estructuras para Ejercicio 3
typedef struct solicitud_t {
    uint8_t dias_disponibles;    // asmdef_offset:SOLICITUD_DIAS_OFFSET
    uint32_t disciplina_id;      // asmdef_offset:SOLICITUD_DISC_ID_OFFSET
    struct solicitud_t *next;    // asmdef_offset:SOLICITUD_NEXT_OFFSET
    usuario_t *usuario;          // asmdef_offset:SOLICITUD_USUARIO_OFFSET
} solicitud_t;                   // asmdef_size:SOLICITUD_SIZE

typedef struct {
    solicitud_t *first;          // asmdef_offset:LISTA_SOL_FIRST_OFFSET
} lista_solicitudes_t;           // asmdef_size:LISTA_SOL_SIZE

typedef struct {
    uint32_t disciplina_id;           // asmdef_offset:CANCHA_DISC_ID_OFFSET
    uint16_t min_jugadores;           // asmdef_offset:CANCHA_MIN_OFFSET
    uint16_t max_cupos;               // asmdef_offset:CANCHA_MAX_OFFSET
} cancha_t;                           // asmdef_size:CANCHA_SIZE

typedef struct {
    uint32_t cant_participantes; // asmdef_offset:RESERVA_CANT_OFFSET
    uint8_t dia_bitmask;         // asmdef_offset:RESERVA_DIA_OFFSET
    cancha_t *cancha;            // asmdef_offset:RESERVA_CANCHA_OFFSET
} reserva_t;                     // asmdef_size:RESERVA_SIZE

//*************************************
// Función auxiliar provista (C)
//*************************************
disciplina_t *unificar(disciplina_t *A, disciplina_t *B);

//*************************************
// Declaración de funciones de los ejercicios
//*************************************

// Ejercicio 1:
bool suscribirDisciplina(
    usuario_t *usuario,
    disciplina_t *candidata,
    bool (*son_unificables)(const disciplina_t *, const disciplina_t *)
);

// Ejercicio 2:
combo_t *armarCombo(
    const rutina_t *catalogo,
    uint32_t cant_catalogo,
    const uint32_t *ids_elegidos,
    uint32_t cant_elegidos
);

// Ejercicio 3:
reserva_t *confirmarReserva(
    lista_solicitudes_t *lista,
    cancha_t *cancha,
    uint8_t dia_bitmask
);
