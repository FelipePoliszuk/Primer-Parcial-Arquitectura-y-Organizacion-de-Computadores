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
DISCIPLINA_NOMBRE_OFFSET  EQU 1
DISCIPLINA_ID_OFFSET      EQU 20
DISCIPLINA_NIVEL_OFFSET   EQU 24
DISCIPLINA_SIZE           EQU 28

; ------------------------
; suscripcion_t
; ------------------------
SUSCRIPCION_ACTIVA_OFFSET     EQU 0
SUSCRIPCION_DISCIPLINA_OFFSET EQU 8
SUSCRIPCION_SEMANAS_OFFSET    EQU 16
SUSCRIPCION_SIZE              EQU 24

; ------------------------
; usuario_t
; ------------------------
USUARIO_ID_OFFSET         EQU 0
USUARIO_SUSC_OFFSET       EQU 8
USUARIO_CANT_SUSC_OFFSET  EQU 16
USUARIO_MAX_SUSC_OFFSET   EQU 20
USUARIO_SIZE              EQU 24

; ------------------------
; rutina_t
; ------------------------
RUTINA_FASE_OFFSET      EQU 0
RUTINA_ID_OFFSET        EQU 4
RUTINA_AJUSTE_OFFSET    EQU 8
RUTINA_DURACION_OFFSET  EQU 10
RUTINA_NOMBRE_OFFSET    EQU 12
RUTINA_CALORIAS_OFFSET  EQU 34
RUTINA_SIZE             EQU 36

; ------------------------
; combo_t
; ------------------------
COMBO_RUTINAS_OFFSET    EQU 0
COMBO_CANT_OFFSET       EQU 8
COMBO_PUNTAJE_OFFSET    EQU 12
COMBO_SIZE              EQU 16

; ------------------------
; solicitud_t & lista_solicitudes_t
; ------------------------
SOLICITUD_DIAS_OFFSET     EQU 0
SOLICITUD_DISC_ID_OFFSET  EQU 4
SOLICITUD_NEXT_OFFSET     EQU 8
SOLICITUD_USUARIO_OFFSET  EQU 16
SOLICITUD_SIZE            EQU 24

LISTA_SOL_FIRST_OFFSET    EQU 0
LISTA_SOL_SIZE            EQU 8

; ------------------------
; cancha_t & reserva_t
; ------------------------
CANCHA_DISC_ID_OFFSET     EQU 0
CANCHA_MIN_OFFSET         EQU 4
CANCHA_MAX_OFFSET         EQU 6
CANCHA_SIZE               EQU 8

RESERVA_CANT_OFFSET          EQU 0
RESERVA_DIA_OFFSET           EQU 4
RESERVA_CANCHA_OFFSET        EQU 8
RESERVA_SIZE                 EQU 16


; ------------------------
; Funciones externas
; ------------------------
extern unificar

; ----------------------------------------------------
; bool suscribirDisciplina(
;     usuario_t *usuario,
;     disciplina_t *candidata,
;     bool (*son_unificables)(const disciplina_t *, const disciplina_t *)
; )
; ----------------------------------------------------
global suscribirDisciplina
suscribirDisciplina:
; Argumentos:
	; rdi = *usuario
	; rsi = *candidata
	; rdx = *son_unificables
; Retorno:
;   al = bool    
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8          ; Alineamiento GLOBAL (La pila ya es segura para toda la función)
    
    mov r12, rdi        ; r12 = *usuario
    mov r13, rsi        ; r13 = *candidata
    mov r14, rdx        ; r14 = *son_unificables

    xor rbx, rbx        ; ebx = índice = 0
.loop:
    cmp ebx, dword[r12 + USUARIO_CANT_SUSC_OFFSET]          ; condición de corte
    je .if

    mov r8, qword[r12 + USUARIO_SUSC_OFFSET]        ; usuario->suscripciones

    mov r9d, ebx
    imul r9d, SUSCRIPCION_SIZE
    mov r8, qword[r8 + r9 + SUSCRIPCION_DISCIPLINA_OFFSET]  ; usuario->suscripciones[i].disciplina

    mov r8d, dword[r8 + DISCIPLINA_ID_OFFSET]    ; usuario->suscripciones[i].disciplina->id

    cmp r8d, dword[r13 + DISCIPLINA_ID_OFFSET]
    je .retFalse

    mov r8, qword[r12 + USUARIO_SUSC_OFFSET]        ; usuario->suscripciones

    mov r9d, ebx
    imul r9d, SUSCRIPCION_SIZE
    mov r8, qword[r8 + r9 + SUSCRIPCION_DISCIPLINA_OFFSET]

    cmp byte[r8 + DISCIPLINA_DIAS_OFFSET], 0
    je .siguiente

    mov r8, qword[r12 + USUARIO_SUSC_OFFSET]        ; usuario->suscripciones

    mov r9d, ebx
    imul r9d, SUSCRIPCION_SIZE
    mov rdi, qword[r8 + r9 + SUSCRIPCION_DISCIPLINA_OFFSET] ; rdi = usuario->suscripciones[i].disciplina

    mov rsi, r13

    call r14        ; call son_unificables 

    test al, al
    jz .siguiente

    mov r8, qword[r12 + USUARIO_SUSC_OFFSET]        ; usuario->suscripciones

    mov r9d, ebx
    imul r9d, SUSCRIPCION_SIZE
    mov rdi, qword[r8 + r9 + SUSCRIPCION_DISCIPLINA_OFFSET] ; rdi = usuario->suscripciones[i].disciplina

    mov rsi, r13

    call unificar   

    mov r10, rax     ; r10 = *unificacion

    mov r8, qword[r12 + USUARIO_SUSC_OFFSET]        ; usuario->suscripciones

    mov r9d, ebx
    imul r9d, SUSCRIPCION_SIZE
    mov qword[r8 + r9 + SUSCRIPCION_DISCIPLINA_OFFSET], r10 

    jmp .retTrue

.siguiente:
    inc ebx
    jmp .loop

.if:
    xor r15, r15
    mov r15d, dword[r12 + USUARIO_CANT_SUSC_OFFSET]

    cmp r15d, dword[r12 + USUARIO_MAX_SUSC_OFFSET]
    jge .retFalse    

    ; ; --------------
    mov r8, qword[r12 + USUARIO_SUSC_OFFSET]    ; usuario->suscripciones
    
    mov r9, r15
    imul r9, SUSCRIPCION_SIZE
    
    mov byte[r8 + r9 + SUSCRIPCION_ACTIVA_OFFSET], 1
    mov qword[r8 + r9 + SUSCRIPCION_DISCIPLINA_OFFSET], r13
    mov word[r8 + r9 + SUSCRIPCION_SEMANAS_OFFSET], 4
    inc dword[r12 + USUARIO_CANT_SUSC_OFFSET]
    ; ; --------------

.retTrue:
    mov rax, 1          ; return true;
    jmp .fin

.retFalse:
    xor rax, rax        ; return false;

.fin:
    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret