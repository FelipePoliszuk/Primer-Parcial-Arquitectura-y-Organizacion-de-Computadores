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
extern malloc
extern calloc
extern free

; ----------------------------------------------------
; combo_t *armarCombo(
;     const rutina_t *catalogo,
;     uint32_t cant_catalogo,
;     const uint32_t *ids_elegidos,
;     uint32_t cant_elegidos
; )
; Argumentos:
;   rdi = const rutina_t *catalogo
;   ??? = uint32_t cant_catalogo
;   ??? = const uint32_t *ids_elegidos
;   ??? = uint32_t cant_elegidos
; Retorno:
;   ??? = combo_t *
; ----------------------------------------------------
global armarCombo
armarCombo:
; registros:
	; rdi = *catalogo
	; esi =  cant_catalogo
	; rdx = *ids_elegidos
	; ecx =  cant_elegidos
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24          ; Alineamiento GLOBAL (La pila ya es segura para toda la función)
    
    mov r12, rdi        ; r12  = *catalogo
    mov r13d, esi       ; r13d =  cant_catalogo
    mov r14, rdx        ; r14  = *ids_elegidos
    mov r15d, ecx       ; r15d =  cant_elegidos

    mov rdi, COMBO_SIZE
    call malloc

    mov rbx, rax        ; rbx = *combo

    mov dword[rbx + COMBO_CANT_OFFSET], 0
    mov dword[rbx + COMBO_PUNTAJE_OFFSET], 0

    mov edi, RUTINA_SIZE
    imul edi, r15d      ; chequear tamaños
    call malloc

    mov qword[RBP-48], rax          ; qword[RBP-48] = **rutinas

    mov dword[RBP-56], 0            ; ; rbx = índice = 0
.loop:
    cmp dword[RBP-56], r15d          ; condición de corte
    je .retCombo

    mov r8d, dword[RBP-56]

    mov edi, dword[r14 + (r8*4)]
    mov rsi, r12
    mov edx, r13d

    call obtenerRutinaDeCatalogo

    test rax, rax
    jz .retNULL

    ; ; ; ---------------------
    xor r9, r9
    mov r9d, dword[rbx + COMBO_CANT_OFFSET]

    imul r9d, RUTINA_SIZE

    mov r8, qword[RBP-48]
    mov r11d, dword[RBP-56]

    mov qword[r8 + (r11*8)], rax

    inc dword[rbx + COMBO_CANT_OFFSET]

    mov r9d, dword[RBP-56]
    imul r9d, RUTINA_SIZE

    movzx r8, byte[r12 + r9 + RUTINA_FASE_OFFSET]

    movzx r10, word[r12 + r9 + RUTINA_DURACION_OFFSET]

    imul r10, r8

    movsx r11d, byte[r12 + r9 + RUTINA_AJUSTE_OFFSET]

    imul r11d, 10

    add r10, r11

    add dword[rbx + COMBO_PUNTAJE_OFFSET], r10d
;     ; ; ---------------------

.siguiente:
    inc dword[RBP-56]
    jmp .loop

.retNULL:
    mov rdi, rbx
    call free           ; free(combo);

    mov rdi, qword[RBP-48]
    call free           ; free(rutinas);

    xor rax, rax        ; return null
    jmp .fin

.retCombo:
    mov r8, qword[RBP-48]
    mov qword[rbx + COMBO_RUTINAS_OFFSET], r8       ; combo->rutinas = rutinas;
    mov rax, rbx            ; return combo;

.fin:
    ; === EPÍLOGO ===
    add rsp, 24          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret



;Función auxiliar
; rutina_t *obtenerRutinaDeCatalogo(uint32_t id_rutina, rutina_t *catalogo, uint32_t cant_catalogo){
global obtenerRutinaDeCatalogo
obtenerRutinaDeCatalogo:
; registros:
	; edi =  id_rutina
	; rsi = *catalogo
	; edx =  cant_catalogo
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    push r14
    
    mov r12d, edi        ; r12d = id_rutina
    mov r13,  rsi        ; r13 = *catalogo
    mov r14d, edx        ; r14d = cant_catalogo

    xor rbx, rbx         ; ebx = índice = 0
.loop:
    cmp ebx, r14d           ; condición de corte
    je .retNULL

    mov r8, RUTINA_SIZE
    imul r8, rbx
 
    cmp dword[r13 + r8 + RUTINA_ID_OFFSET], r12d            ;  chequear Offsets
    je .retRutina

.siguiente:
    inc ebx
    jmp .loop

.retRutina:
    lea rax, [r13 + r8] 
    jmp .fin

.retNULL:
    xor rax, rax        ; return NULL;

.fin: 
    ; === EPÍLOGO ===
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret




























































;     ; ------------------------
; ; Offsets para los structs
; ; Plataforma: x86_64 (LP64)
; ; ------------------------

; section .data

; section .text


; ; ------------------------
; ; disciplina_t
; ; ------------------------
; DISCIPLINA_DIAS_OFFSET    EQU 0
; DISCIPLINA_NOMBRE_OFFSET  EQU 1
; DISCIPLINA_ID_OFFSET      EQU 20
; DISCIPLINA_NIVEL_OFFSET   EQU 24
; DISCIPLINA_SIZE           EQU 28

; ; ------------------------
; ; suscripcion_t
; ; ------------------------
; SUSCRIPCION_ACTIVA_OFFSET     EQU 0
; SUSCRIPCION_DISCIPLINA_OFFSET EQU 8
; SUSCRIPCION_SEMANAS_OFFSET    EQU 16
; SUSCRIPCION_SIZE              EQU 24

; ; ------------------------
; ; usuario_t
; ; ------------------------
; USUARIO_ID_OFFSET         EQU 0
; USUARIO_SUSC_OFFSET       EQU 8
; USUARIO_CANT_SUSC_OFFSET  EQU 16
; USUARIO_MAX_SUSC_OFFSET   EQU 20
; USUARIO_SIZE              EQU 24

; ; ------------------------
; ; rutina_t
; ; ------------------------
; RUTINA_FASE_OFFSET      EQU 0
; RUTINA_ID_OFFSET        EQU 4
; RUTINA_AJUSTE_OFFSET    EQU 8
; RUTINA_DURACION_OFFSET  EQU 10
; RUTINA_NOMBRE_OFFSET    EQU 12
; RUTINA_CALORIAS_OFFSET  EQU 34
; RUTINA_SIZE             EQU 36

; ; ------------------------
; ; combo_t
; ; ------------------------
; COMBO_RUTINAS_OFFSET    EQU 0
; COMBO_CANT_OFFSET       EQU 8
; COMBO_PUNTAJE_OFFSET    EQU 12
; COMBO_SIZE              EQU 16

; ; ------------------------
; ; solicitud_t & lista_solicitudes_t
; ; ------------------------
; SOLICITUD_DIAS_OFFSET     EQU 0
; SOLICITUD_DISC_ID_OFFSET  EQU 4
; SOLICITUD_NEXT_OFFSET     EQU 8
; SOLICITUD_USUARIO_OFFSET  EQU 16
; SOLICITUD_SIZE            EQU 24

; LISTA_SOL_FIRST_OFFSET    EQU 0
; LISTA_SOL_SIZE            EQU 8

; ; ------------------------
; ; cancha_t & reserva_t
; ; ------------------------
; CANCHA_DISC_ID_OFFSET     EQU 0
; CANCHA_MIN_OFFSET         EQU 4
; CANCHA_MAX_OFFSET         EQU 6
; CANCHA_SIZE               EQU 8

; RESERVA_CANT_OFFSET          EQU 0
; RESERVA_DIA_OFFSET           EQU 4
; RESERVA_CANCHA_OFFSET        EQU 8
; RESERVA_SIZE                 EQU 16

; ; ------------------------
; ; Funciones externas
; ; ------------------------
; extern malloc
; extern calloc
; extern free

; ; ----------------------------------------------------
; ; combo_t *armarCombo(
; ;     const rutina_t *catalogo,
; ;     uint32_t cant_catalogo,
; ;     const uint32_t *ids_elegidos,
; ;     uint32_t cant_elegidos
; ; )
; ; Argumentos:
; ;   rdi = const rutina_t *catalogo
; ;   ??? = uint32_t cant_catalogo
; ;   ??? = const uint32_t *ids_elegidos
; ;   ??? = uint32_t cant_elegidos
; ; Retorno:
; ;   ??? = combo_t *
; ; ----------------------------------------------------
; global armarCombo
; armarCombo:
; ; registros:
; 	; rdi = *catalogo
; 	; esi =  cant_catalogo
; 	; rdx = *ids_elegidos
; 	; ecx =  cant_elegidos
    
;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp

;     ; preservar registros callee-saved 
;     push rbx   
;     push r12
;     push r13
;     push r14
;     push r15
;     sub rsp, 24          ; Alineamiento GLOBAL (La pila ya es segura para toda la función)
    
;     mov r12, rdi        ; r12  = *catalogo
;     mov r13d, esi       ; r13d =  cant_catalogo
;     mov r14, rdx        ; r14  = *ids_elegidos
;     mov r15d, ecx       ; r15d =  cant_elegidos

;     mov rdi, COMBO_SIZE
;     call malloc

;     mov rbx, rax        ; rbx = *combo

;     mov dword[rbx + COMBO_CANT_OFFSET], 0
;     mov dword[rbx + COMBO_PUNTAJE_OFFSET], 0

;     mov edi, RUTINA_SIZE
;     imul edi, r15d      ; chequear tamaños
;     call malloc

;     mov qword[RBP-48], rax          ; qword[RBP-48] = **rutinas

;     mov dword[RBP-56], 0            ; ; rbx = índice = 0
; .loop:
;     cmp dword[RBP-56], r15d          ; condición de corte
;     je .retCombo

;     mov r8d, dword[RBP-56]

;     mov edi, dword[r14 + (r8*4)]
;     mov rsi, r12
;     mov edx, r13d

;     call obtenerRutinaDeCatalogo

;     test rax, rax
;     jz .retNULL

;     ; ; ; ---------------------
;     xor r9, r9
;     mov r9d, dword[rbx + COMBO_CANT_OFFSET]

;     imul r9d, RUTINA_SIZE

;     mov r8, qword[RBP-48]
;     mov qword[r8 + r9], rax

;     inc dword[rbx + COMBO_CANT_OFFSET]

;     mov r9d, dword[RBP-56]
;     imul r9d, RUTINA_SIZE

;     movzx r8, byte[r12 + r9 + RUTINA_FASE_OFFSET]

;     movzx r10, word[r12 + r9 + RUTINA_DURACION_OFFSET]

;     imul r10, r8

;     movsx r11d, byte[r12 + r9 + RUTINA_AJUSTE_OFFSET]

;     imul r11d, 10

;     add r10, r11

;     add dword[rbx + COMBO_PUNTAJE_OFFSET], r10d
; ;     ; ; ---------------------

; .siguiente:
;     inc dword[RBP-56]
;     jmp .loop

; .retNULL:
;     ; mov rdi, rbx
;     ; call free           ; free(combo);

;     ; mov rdi, qword[RBP-48]
;     ; call free           ; free(rutinas);

;     xor rax, rax        ; return null
;     jmp .fin

; .retCombo:
;     mov r8, qword[RBP-48]
;     mov qword[rbx + COMBO_RUTINAS_OFFSET], r8       ; combo->rutinas = rutinas;
;     mov rax, rbx            ; return combo;

; .fin:
;     ; === EPÍLOGO ===
;     add rsp, 24          ; Deshago el alineamiento global
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbx
;     pop rbp
;     ret



; ;Función auxiliar
; ; rutina_t *obtenerRutinaDeCatalogo(uint32_t id_rutina, rutina_t *catalogo, uint32_t cant_catalogo){
; global obtenerRutinaDeCatalogo
; obtenerRutinaDeCatalogo:
; ; registros:
; 	; edi =  id_rutina
; 	; rsi = *catalogo
; 	; edx =  cant_catalogo
    
;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp

;     ; preservar registros callee-saved 
;     push rbx   
;     push r12
;     push r13
;     push r14
    
;     mov r12d, edi        ; r12d = id_rutina
;     mov r13,  rsi        ; r13 = *catalogo
;     mov r14d, edx        ; r14d = cant_catalogo

;     xor rbx, rbx         ; ebx = índice = 0
; .loop:
;     cmp ebx, r14d           ; condición de corte
;     je .retNULL

;     mov r8, RUTINA_SIZE
;     imul r8, rbx
 
;     cmp dword[r13 + r8 + RUTINA_ID_OFFSET], r12d            ;  chequear Offsets
;     je .retRutina

; .siguiente:
;     inc ebx
;     jmp .loop

; .retRutina:
;     lea rax, [r13 + r8] 
;     jmp .fin

; .retNULL:
;     xor rax, rax        ; return NULL;

; .fin: 
;     ; === EPÍLOGO ===
;     pop r14
;     pop r13
;     pop r12
;     pop rbx
;     pop rbp
;     ret