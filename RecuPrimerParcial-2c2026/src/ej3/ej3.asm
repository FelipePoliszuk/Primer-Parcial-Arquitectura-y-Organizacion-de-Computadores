; ------------------------
; Offsets para los structs
; Plataforma: x86_64 (LP64)
; ------------------------

section .data

section .text

; ------------------------
; disciplina_t
; ------------------------
DISCIPLINA_DIAS_OFFSET    EQU 0
DISCIPLINA_NOMBRE_OFFSET  EQU 0
DISCIPLINA_ID_OFFSET      EQU 0
DISCIPLINA_NIVEL_OFFSET   EQU 0
DISCIPLINA_SIZE           EQU 0

; ------------------------
; suscripcion_t
; ------------------------
SUSCRIPCION_ACTIVA_OFFSET     EQU 0
SUSCRIPCION_DISCIPLINA_OFFSET EQU 0
SUSCRIPCION_SEMANAS_OFFSET    EQU 0
SUSCRIPCION_SIZE              EQU 0

; ------------------------
; usuario_t
; ------------------------
USUARIO_ID_OFFSET         EQU 0
USUARIO_SUSC_OFFSET       EQU 0
USUARIO_CANT_SUSC_OFFSET  EQU 0
USUARIO_MAX_SUSC_OFFSET   EQU 0
USUARIO_SIZE              EQU 0

; ------------------------
; rutina_t
; ------------------------
RUTINA_FASE_OFFSET      EQU 0
RUTINA_ID_OFFSET        EQU 0
RUTINA_AJUSTE_OFFSET    EQU 0
RUTINA_DURACION_OFFSET  EQU 0
RUTINA_NOMBRE_OFFSET    EQU 0
RUTINA_CALORIAS_OFFSET  EQU 0
RUTINA_SIZE             EQU 0

; ------------------------
; combo_t
; ------------------------
COMBO_RUTINAS_OFFSET    EQU 0
COMBO_CANT_OFFSET       EQU 0
COMBO_PUNTAJE_OFFSET    EQU 0
COMBO_SIZE              EQU 0

; ------------------------
; solicitud_t & lista_solicitudes_t
; ------------------------
SOLICITUD_DIAS_OFFSET     EQU 0
SOLICITUD_DISC_ID_OFFSET  EQU 0
SOLICITUD_NEXT_OFFSET     EQU 0
SOLICITUD_USUARIO_OFFSET  EQU 0
SOLICITUD_SIZE            EQU 0

LISTA_SOL_FIRST_OFFSET    EQU 0
LISTA_SOL_SIZE            EQU 0

; ------------------------
; cancha_t & reserva_t
; ------------------------
CANCHA_DISC_ID_OFFSET     EQU 0
CANCHA_MIN_OFFSET         EQU 0
CANCHA_MAX_OFFSET         EQU 0
CANCHA_SIZE               EQU 0

RESERVA_CANT_OFFSET          EQU 0
RESERVA_DIA_OFFSET           EQU 0
RESERVA_CANCHA_OFFSET        EQU 0
RESERVA_SIZE                 EQU 0

; ------------------------
; Funciones externas
; ------------------------
extern malloc
extern calloc
extern free

; ----------------------------------------------------
; reserva_t *confirmarReserva(
;     lista_solicitudes_t *lista,
;     cancha_t *cancha,
;     uint8_t dia_bitmask
; )
; Argumentos:
;   rdi = lista_solicitudes_t *lista
;   rsi = cancha_t *cancha
;   dl  = uint8_t dia_bitmask
; Retorno:
;   rax = reserva_t *
; ----------------------------------------------------
global confirmarReserva
confirmarReserva:
    xor rax, rax
    ret