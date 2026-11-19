; ------------------------
; Offsets para los structs
; Plataforma: x86_64 (LP64)
; ------------------------

extern malloc

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

global  invertirRecorridoConDirecciones
invertirRecorridoConDirecciones:
; registros:
	; rdi = *rec
	; rsi =  len
    
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
    
    mov r12, rdi        ; r12 = *rec
    mov r13, rsi        ; r13 =  len

    test r12, r12 
    jz .retNull

    test r13, r13 
    jz .retNull

    mov rdi, REC_SIZE
    call malloc

    mov r15, rax        ; r15 = *recorrido_invertido

    mov rdi, 4
    imul rdi, r13
    call malloc

    mov r14, rax        ; r14 = *acciones

    xor rbx, rbx        ; rbx = índice = 0

.loop:
    cmp rbx, r13          ; condición de corte
    je .retRecorrido


    mov rdi, qword[r12 + REC_ACCIONES_OFFSET]

    mov r8, r13
    dec r8
    sub r8, rbx

    mov edi, dword[rdi + (r8*4)]

    call accion_inversa

    mov dword[r14 + (rbx*4)], eax

.siguiente:
    inc rbx
    jmp .loop


.retRecorrido:
    mov qword[r15 + REC_ACCIONES_OFFSET], r14           ; recorrido_invertido->acciones = acciones;
    mov qword[r15 + REC_CANT_ACCIONES_OFFSET], r13      ; recorrido_invertido->cant_acciones = len;

    mov rax, r15            ; return recorrido_invertido;
    jmp .fin

.retNull:
    xor rax, rax        ; return NULL;

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

global accion_inversa
accion_inversa:
; registros:
	; rdi = acc
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    cmp edi, 0
    je .retSur

    cmp edi, 1
    je .retNorte  

    cmp edi, 2
    je .retOeste   

.retEste:
    mov eax, 2
    jmp .fin

.retOeste:
    mov eax, 3
    jmp .fin

.retSur:
    mov eax, 1
    jmp .fin

.retNorte:
    mov eax, 0

.fin:    
    ; === EPÍLOGO ===
    pop rbp
    ret