; ------------------------
; Offsets para los structs
; Plataforma: x86_64 (LP64)
; ------------------------

section .data

section .text

; COMPLETAR las definiciones (serán revisadas por ABI enforcer):
; ------------------------
; Contenido
; ------------------------
CONT_NOMBRE_OFFSET      EQU 0      ; char nombre[64]
CONT_VALOR_OFFSET       EQU 64      ; uint32_t valor
CONT_COLOR_OFFSET       EQU 68      ; char color[32]
CONT_ES_TESORO_OFFSET   EQU 100      ; bool es_tesoro
CONT_PESO_OFFSET        EQU 104      ; float peso

CONT_SIZE               EQU 108      ; sizeof(Contenido) (rounded)

; ------------------------
; Habitacion
; ------------------------
HAB_ID_OFFSET          EQU 0         ; uint32_t id
HAB_VECINOS_OFFSET     EQU 4         ; uint32_t vecinos[ACC_CANT] (4 entradas)
HAB_CONTENIDO_OFFSET   EQU 20        ; Contenido contenido (aligned to 4)
HAB_VISITAS_OFFSET     EQU 128       ; uint32_t visitas

HAB_SIZE               EQU 132       ; sizeof(Habitacion)

; ------------------------
; Mapa
; ------------------------
MAP_HABITACIONES_OFFSET    EQU 0     ; Habitacion *habitaciones  (pointer, 8 bytes)
MAP_N_HABITACIONES_OFFSET  EQU 8     ; uint64_t n_habitaciones       (8 bytes)
MAP_ID_ENTRADA_OFFSET      EQU 16    ; uint32_t id_entrada         (4 bytes)

MAP_SIZE                   EQU 24    ; sizeof(Mapa) (padded to 8)

; ------------------------
; Recorrido
; ------------------------
REC_ACCIONES_OFFSET        EQU 0     ; Accion *acciones  (pointer, 8 bytes)
REC_CANT_ACCIONES_OFFSET   EQU 8     ; uint64_t cant_acciones (8 bytes)

REC_SIZE                  EQU 16     ; sizeof(Recorrido)

; Notar que el enum aparece como puntero, entonces no afecta los offsets


; uint32_t sumarTesoros(Mapa *mapa, uint32_t actual, bool *visitado) 
global  sumarTesoros
sumarTesoros:
; registros:
    ; rdi = mapa
    ; rsi = actual
    ; rdx = visitado

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi         ; r12 = mapa
    mov r13d, esi        ; r13 = actual
    mov r14, rdx         ; r14 = visitado

    xor r15, r15        ; r15 = acumulador = 0

    cmp r13d, 99    
    je .fin                 ; si actual es inválido, corto

    cmp byte[r14 + r13], 1              
    je .fin                 ; si ya fue visitado, corto

    mov r9, [r12 + MAP_HABITACIONES_OFFSET] ; r9 = mapa->habitaciones      
    
    mov rax, r13

    imul rax, HAB_SIZE  ; rax = actual * sizeof(Habitacion)
    add r9, rax              ; r9 = mapa->habitaciones[actual]

    cmp byte[r9 + HAB_CONTENIDO_OFFSET + CONT_ES_TESORO_OFFSET], 0      
    je .noSumo      ; si no es tesoro, salto

    add r15d, [r9 + HAB_CONTENIDO_OFFSET + CONT_VALOR_OFFSET]   ; sumo el valor del tesoro al acumulador   

.noSumo:

    mov byte[r14 + r13], 1          ; marco como visitado

    xor rbx, rbx        ; rbx = índice = 0

.loop:
    cmp ebx, 4          ; condición de corte
    je .fin

    mov r10d, [r9 + HAB_VECINOS_OFFSET + (rbx*4)]     ;r10d = habitacion_actual.vecinos[i]

    push r9

    mov rdi, r12         ;rdi = mapa
    mov esi, r10d        ;esi = habitacion_actual.vecinos[i]
    mov rdx, r14         ;rdx = visitado

    call sumarTesoros

    pop r9
    
    add r15d, eax         ; sumar al acumulador el resultado de la llamada

.siguiente:
    inc ebx
    jmp .loop          


.fin:
    ; valor de retorno
    mov eax, r15d       ; ejemplo, devolver acumulador en eax

    ; === EPÍLOGO ===
    pop r15
    pop r14         
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


    
