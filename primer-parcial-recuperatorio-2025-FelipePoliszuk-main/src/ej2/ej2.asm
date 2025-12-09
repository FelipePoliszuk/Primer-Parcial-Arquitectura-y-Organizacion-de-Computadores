; ------------------------
; Offsets para los structs
; Plataforma: x86_64 (LP64)
; ------------------------

extern malloc

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


global  invertirRecorridoConDirecciones
invertirRecorridoConDirecciones:
; registros:
    ; rdi = rec
    ; rsi = len
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8          ; para que el movmiento de la pila sea par (mult 16)

    cmp rsi, 0
    je .devuelvoNull    

    xor r12, r12        ; índice = 0 = r12

    mov r13, rdi        ; r13 = rec
    mov r14, rsi        ; r14 = len

    mov rdi, REC_SIZE
    call malloc
    mov rbx, rax        ;rbx = inverso

    mov edi, 4        ; edi = 4 = size(Accion)
    imul edi, r14d    ; multiplico size(Accion) * len
    call malloc
    mov r15, rax      ; r15 = acciones


.loop:
    cmp r12, r14          ; condición de corte
    je .devuelvoArreglo

    xor r8, r8

    mov r8, [r13 + REC_ACCIONES_OFFSET]     ; r8 = Base del array rec.acciones

    mov r9, r14
    sub r9, r12
    sub r9, 1

    mov r8d, [r8 + r9*4]            ; r8d = rec->acciones[len-i-1];

    mov edi, r8d                    ; pasar argumento
    call accion_inversa             ; llamada a función
    mov [r15 + (r12 * 4)], eax      ; acciones[i] = accion_inversa(accion);

.siguiente:
    inc r12
    jmp .loop

.devuelvoArreglo:

    mov [rbx + REC_ACCIONES_OFFSET], r15        ; inverso->acciones = acciones;
    mov [rbx + REC_CANT_ACCIONES_OFFSET], r14   ; inverso->cant_acciones = len;

    mov rax, rbx
    jmp .fin

.devuelvoNull:
    xor rax, rax   

.fin:
    ; === EPÍLOGO ===

    add rsp, 8

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

    cmp rdi, 0
    je .devuelvoSur

    cmp rdi, 1
    je .devuelvoNorte

    cmp rdi, 2
    je .devuelvoOeste

    mov eax, 2     
    jmp .fin   
        
    
.devuelvoSur:
    mov eax, 1     
    je .fin

.devuelvoNorte:
    mov eax, 0     
    je .fin

.devuelvoOeste:
    mov eax, 3     
    je .fin    
         
.fin: 
    ret  