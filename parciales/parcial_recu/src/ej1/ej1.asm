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
CONT_NOMBRE_OFFSET      EQU 0        ; char nombre[64]
CONT_VALOR_OFFSET       EQU 64       ; uint32_t valor
CONT_COLOR_OFFSET       EQU 68       ; char color[32]
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

; bool encontrarTesoroEnMapa(Mapa *mapa, Recorrido *rec, uint64_t *acciones_ejecutadas) {
global  encontrarTesoroEnMapa
encontrarTesoroEnMapa:
; registros:
	; rdi = *mapa
	; rsi = *rec
	; rdx = *acciones_ejecutadas
    
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
    
    mov r12, rdi        ; r12 = *mapa
    mov r13, rsi        ; r13 = *rec
    mov r14, rdx        ; r14 = *acciones_ejecutadas

    mov qword[r14], 0

    mov r15d, dword[r12 + MAP_ID_ENTRADA_OFFSET]    ; r15d = actual

    mov r8, qword[r12 + MAP_HABITACIONES_OFFSET]    ; mapa->habitaciones

    mov r9d, HAB_SIZE
    imul r9d, r15d        

    cmp byte[r8 + r9 + HAB_CONTENIDO_OFFSET + CONT_ES_TESORO_OFFSET], 0   

    jne .retTrue

    xor rbx, rbx        ; rbx = índice = 0
.loop:
    cmp rbx, qword[r13 + REC_CANT_ACCIONES_OFFSET]          ; condición de corte
    je .retFalse

    mov r8, qword[r13 + REC_ACCIONES_OFFSET]
    mov r8d, dword[r8 + (rbx*4)]                ; r8 = indice

    mov r10, qword[r12 + MAP_HABITACIONES_OFFSET]    ; mapa->habitaciones  

    mov r9d, r15d    

    imul r9, HAB_SIZE
    add r10, r9

    mov r10d, dword[r10 + HAB_VECINOS_OFFSET + (r8*4)]   
    
    cmp r10d, 99
    je .retFalse

    inc qword[r14]

    ; -----------   

    mov r8, qword[r12 + MAP_HABITACIONES_OFFSET]    ; mapa->habitaciones

    mov r9d, HAB_SIZE
    imul r9d, r10d        

    cmp byte[r8 + r9 + HAB_CONTENIDO_OFFSET + CONT_ES_TESORO_OFFSET], 0    ; mapa->habitaciones

    jne .retTrue

    ; -----------

    mov r15d, r10d
    
.siguiente:
    inc rbx
    jmp .loop

.retFalse:
    xor rax, rax        ; return false; 
    jmp .fin

.retTrue:
    mov rax, 1          ; return true;
    
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


; Otra versión

; ; bool encontrarTesoroEnMapa(Mapa *mapa, Recorrido *rec, uint64_t *acciones_ejecutadas) {
; global  encontrarTesoroEnMapa
; encontrarTesoroEnMapa:
; ; registros:
;     ; rdi = mapa
;     ; rsi = rec
;     ; rdx = acciones_ejecutadas
    
;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp

;     ; preservar registros callee-saved 
;     push rbx   
;     push r12
;     push r13
;     push r14
;     push r15

;     mov r13, rdi        ; r13 = mapa
;     mov r14, rsi        ; r14 = rec
;     mov r15, rdx        ; r15 = acciones_ejecutadas

;     xor r12, r12        ; r12 = índice
     
;     mov qword[r15], 0      ; r15 = acciones_ejecutadas = 0

;     xor r8, r8                          ; limpio r8

;     mov r8d, dword[r13 + MAP_ID_ENTRADA_OFFSET]         ; r8d = actual
;     imul r8d, HAB_SIZE

;     mov r9, [r13 + MAP_HABITACIONES_OFFSET]                

;     add r9, r8                                          ;r9 = mapa->habitaciones[actual]

;     cmp byte[r9 + HAB_CONTENIDO_OFFSET + CONT_ES_TESORO_OFFSET], 1
;     je .devuelvoTrue

;     mov rbx, [r13 + MAP_HABITACIONES_OFFSET]            ;rbx = mapa->Habitaciones

; .loop:
;     cmp r12, [r14 + REC_CANT_ACCIONES_OFFSET]          ; condición de corte
;     je .devuelvoFalse

;     mov r10, [r14 + REC_ACCIONES_OFFSET]            ; r10 = base array rec.acciones    
    
;     mov r10d, [r10 + (r12*4)]                       ; r10d = rec->acciones[i];


;     mov r8d, [r9 + HAB_VECINOS_OFFSET + (r10*4)]    ; r8d = mapa->habitaciones[actual].vecinos[direccion];

;     cmp r8d, 99
;     je .devuelvoFalse

;     mov rax, r8             ; Copiamos id nuevo a registro de 64 bits
;     imul rax, HAB_SIZE      ; Offset = id * 132
    
;     mov r9, rbx             ; Base del array
;     add r9, rax             ; r9 AHORA apunta a la NUEVA habitación

;     inc qword [r15]         ; (*acciones_ejecutadas)++

;     cmp byte[r9 + HAB_CONTENIDO_OFFSET + CONT_ES_TESORO_OFFSET], 1
;     je .devuelvoTrue

; .siguiente:
;     inc r12
;     jmp .loop

; .devuelvoFalse:
;     mov rax, 0
;     jmp .fin

; .devuelvoTrue:
;     mov rax, 1

; .fin:
;     ; === EPÍLOGO ===
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbx
;     pop rbp
;     ret    