; ------------------------
; Offsets para los structs
; Plataforma: x86_64 (LP64)
; ------------------------

section .data

section .text

; COMPLETAR las definiciones (serán revisadas por ABI enforcer):
; Contenido
; ------------------------
CONT_NOMBRE_OFFSET      EQU 0      ; char nombre[64]
CONT_VALOR_OFFSET       EQU 64      ; uint32_t valor
CONT_COLOR_OFFSET       EQU 68      ; char color[32]
CONT_ES_TESORO_OFFSET   EQU 100      ; bool es_tesoro
CONT_PESO_OFFSET        EQU 104      ; float peso        // 4 bytes

CONT_SIZE               EQU 108      ; sizeof(Contenido) (rounded)

; ------------------------
; Habitacion
; ------------------------
HAB_ID_OFFSET          EQU 0         ; uint32_t id
HAB_VECINOS_OFFSET     EQU 4         ; uint32_t vecinos[ACC_CANT] (4 entradas)

HAB_CONTENIDO_OFFSET   EQU 20        ; Contenido contenido (aligned to 4)
; cuando se alinea con padding sobre otra estructura se alinea a el mayor  de esa struct?

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
	; rdi = *mapa
	; esi =  actual
	; rdx = *visitado
    
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
    
    mov r12, rdi         ; r12  = *mapa
    mov r13d, esi        ; r13d =  actual
    mov r14, rdx         ; r14  = *visitado

    xor r15, r15         ; r15d = acumulador = 0

    cmp r13, 99
    je .fin

    cmp byte[r14 + (r13*1)], 0
    jne .fin    

    mov r8, qword[r12 + MAP_HABITACIONES_OFFSET]    ; mapa->habitaciones

    mov r9d, HAB_SIZE
    imul r9d, r13d        

    cmp byte[r8 + r9 + HAB_CONTENIDO_OFFSET + CONT_ES_TESORO_OFFSET], 0   
    
    je .noAcumulo

    add r15d, dword[r8 + r9 + HAB_CONTENIDO_OFFSET + CONT_VALOR_OFFSET]   

.noAcumulo:

    mov byte[r14 + (r13*1)], 1      ; visitado[actual] = true;

    xor rbx, rbx        ; rbx = índice = 0
.loop:
    cmp rbx, 4          ; condición de corte
    je .fin

    mov rdi, r12        ; rdi = *mapa
    ; ---------
    mov r10, qword[r12 + MAP_HABITACIONES_OFFSET]    ; mapa->habitaciones  
    mov r9d, r13d    
    imul r9, HAB_SIZE
    add r10, r9
    mov esi, dword[r10 + HAB_VECINOS_OFFSET + (rbx*4)]  
    ; ---------
    mov rdx, r14        ; r14 = *visitado
    call sumarTesoros

    add r15d, eax       ; acumulador += sumarTesoros(mapa, mapa->habitaciones[actual].vecinos[i], visitado);

.siguiente:
    inc rbx
    jmp .loop

.fin:
    mov eax, r15d        ; return acumulador;

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret