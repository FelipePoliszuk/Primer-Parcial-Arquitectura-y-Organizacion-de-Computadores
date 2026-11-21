#include "utils.h"
#include "ejs.h"

static uint32_t next_unified_id = 10000;

disciplina_t *unificar(disciplina_t *A, disciplina_t *B) {
    if (!A || !B) return NULL;
    disciplina_t *nueva = calloc(1, sizeof(disciplina_t));
    if (!nueva) return NULL;

    nueva->id = next_unified_id++;
    nueva->dias = (uint8_t)(A->dias | B->dias);
    nueva->nivel_requerido = (A->nivel_requerido > B->nivel_requerido)
                                 ? A->nivel_requerido
                                 : B->nivel_requerido;
    snprintf(nueva->nombre, sizeof(nueva->nombre), "%.9s+%.8s", A->nombre, B->nombre);
    return nueva;
}

disciplina_t *crear_disciplina(uint32_t id, const char *nombre, uint8_t dias, uint8_t nivel_requerido) {
    disciplina_t *d = malloc(sizeof(disciplina_t));
    if (!d) return NULL;
    memset(d, 0xAA, sizeof(disciplina_t));
    d->id = id;
    d->dias = dias;
    d->nivel_requerido = nivel_requerido;
    if (nombre) {
        snprintf(d->nombre, sizeof(d->nombre), "%s", nombre);
    } else {
        d->nombre[0] = '\0';
    }
    return d;
}

usuario_t *crear_usuario(uint32_t id, uint32_t max_suscripciones) {
    usuario_t *u = malloc(sizeof(usuario_t));
    if (!u) return NULL;
    memset(u, 0xAA, sizeof(usuario_t));
    u->id = id;
    u->max_suscripciones = max_suscripciones;
    u->cant_suscripciones = 0;
    u->suscripciones = NULL;
    if (max_suscripciones > 0) {
        u->suscripciones = malloc(max_suscripciones * sizeof(suscripcion_t));
        if (u->suscripciones) {
            memset(u->suscripciones, 0xAA, max_suscripciones * sizeof(suscripcion_t));
        }
    }
    return u;
}

void agregar_suscripcion_inicial(usuario_t *u, disciplina_t *d, bool activa, uint16_t semanas) {
    if (!u || u->cant_suscripciones >= u->max_suscripciones) return;
    suscripcion_t *s = &u->suscripciones[u->cant_suscripciones++];
    s->activa = activa;
    s->disciplina = d;
    s->semanas_restantes = semanas;
}

void liberar_usuario(usuario_t *u) {
    if (!u) return;
    free(u->suscripciones);
    free(u);
}

void liberar_combo(combo_t *c) {
    if (!c) return;
    free(c->rutinas);
    free(c);
}

lista_solicitudes_t *crear_lista_solicitudes(void) {
    return calloc(1, sizeof(lista_solicitudes_t));
}

void agregar_solicitud(lista_solicitudes_t *lista, usuario_t *u, uint8_t dias_disponibles, uint32_t disciplina_id) {
    if (!lista) return;
    solicitud_t *nodo = malloc(sizeof(solicitud_t));
    if (!nodo) return;
    memset(nodo, 0xAA, sizeof(solicitud_t));
    nodo->usuario = u;
    nodo->dias_disponibles = dias_disponibles;
    nodo->disciplina_id = disciplina_id;
    nodo->next = NULL;

    if (!lista->first) {
        lista->first = nodo;
    } else {
        solicitud_t *curr = lista->first;
        while (curr->next) {
            curr = curr->next;
        }
        curr->next = nodo;
    }
}

void liberar_lista_solicitudes(lista_solicitudes_t *lista) {
    if (!lista) return;
    solicitud_t *curr = lista->first;
    while (curr) {
        solicitud_t *next = curr->next;
        free(curr);
        curr = next;
    }
    free(lista);
}

void liberar_reserva(reserva_t *r) {
    if (!r) return;
    free(r);
}
