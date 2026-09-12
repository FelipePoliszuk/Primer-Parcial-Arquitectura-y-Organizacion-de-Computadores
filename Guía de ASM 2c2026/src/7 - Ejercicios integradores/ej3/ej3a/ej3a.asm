extern malloc

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4
; -----------------------------------
USUARIO_SIZE EQU 8


CASO_CATEGORIA_OFFSET EQU 0
CASO_ESTADO_OFFSET EQU 4
CASO_USUARIO_OFFSET EQU 8
; -----------------------------------
CASO_SIZE EQU 16


SEGMENTACION_CASOS0_OFFSET EQU 0
SEGMENTACION_CASOS1_OFFSET EQU 8
SEGMENTACION_CASOS2_OFFSET EQU 16
; -----------------------------------
SEGMENTACION_SIZE EQU 24


ESTADISTICAS_CLT_OFFSET EQU 0
ESTADISTICAS_RBO_OFFSET EQU 1
ESTADISTICAS_KSC_OFFSET EQU 2
ESTADISTICAS_KDT_OFFSET EQU 3
ESTADISTICAS_ESTADO0_OFFSET EQU 4
ESTADISTICAS_ESTADO1_OFFSET EQU 5
ESTADISTICAS_ESTADO2_OFFSET EQU 6
; -----------------------------------
ESTADISTICAS_SIZE EQU 7


; int contar_casos_por_nivel(caso_t* arreglo_casos, int largo, int nivel)
global contar_casos_por_nivel
contar_casos_por_nivel:
; registros:
; 	rdi = *arreglo_casos
; 	rsi =  largo
; 	rdx =  nivel
    
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
    
    mov r12, rdi        ; r12 = *arreglo_casos
    mov r13, rsi        ; r13 =  largo
    mov r14, rdx        ; r14 =  nivel

    xor rbx, rbx        ; índice
    xor r15, r15        ; contador

    shl r13, 4          ; imul r13, 16  

.loop:
    cmp rbx, r13          ; condición de corte
    je .fin

    lea r8, qword[r12 + rbx]                            ; r8 = &arreglo_casos[i] = *caso;

    mov rsi, qword[r8 + CASO_USUARIO_OFFSET]            ; rsi  = caso->usuario
    mov esi, dword[rsi + USUARIO_NIVEL_OFFSET]          ; esi = caso->usuario->nivel;

    cmp esi, r14d
    je .sumo

.siguiente:
    add rbx, 16
    jmp .loop

.sumo:
    inc r15
    jmp .siguiente

.fin:
    mov rax, r15       

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


;segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo)
global segmentar_casos
segmentar_casos:
; registros:
	; rdi = *arreglo_casos
	; rsi = largo
    
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
    
    mov r12, rdi        ; r12 = *arreglo_casos
    mov r13, rsi        ; r13 =  largo

    mov rdi, SEGMENTACION_SIZE
    call malloc

    mov rbx, rax        ; rbx = *resultado 

.nivel0:
    mov rdi, r12
    mov rsi, r13
    mov rdx, 0
    call contar_casos_por_nivel

    test rax, rax
    jz .pongoNULL0

    mov rdi, CASO_SIZE
    imul rdi, rax
    call malloc             ; malloc((sizeof(caso_t))*largo0);

    mov qword[rbx + SEGMENTACION_CASOS0_OFFSET], rax
    
    jmp .nivel1

.pongoNULL0:
    mov qword[rbx + SEGMENTACION_CASOS0_OFFSET], 0

.nivel1:
    mov rdi, r12
    mov rsi, r13
    mov rdx, 1
    call contar_casos_por_nivel

    test rax, rax
    jz .pongoNULL1

    mov rdi, CASO_SIZE
    imul rdi, rax
    call malloc             ; malloc((sizeof(caso_t))*largo1);

    mov qword[rbx + SEGMENTACION_CASOS1_OFFSET], rax
    
    jmp .nivel2

.pongoNULL1:
    mov qword[rbx + SEGMENTACION_CASOS1_OFFSET], 0


.nivel2:
    mov rdi, r12
    mov rsi, r13
    mov rdx, 2
    call contar_casos_por_nivel

    test rax, rax
    jz .pongoNULL2

    mov rdi, CASO_SIZE
    imul rdi, rax
    call malloc             ; malloc((sizeof(caso_t))*largo2);
    
    mov qword[rbx + SEGMENTACION_CASOS2_OFFSET], rax

    jmp .sigo

.pongoNULL2:
    mov qword[rbx + SEGMENTACION_CASOS2_OFFSET], 0

.sigo:    

    xor r8, r8          ; r8  = 0 = j
    xor r9, r9          ; r9  = 0 = k
    xor r10, r10        ; r10 = 0 = l

    xor r15, r15        ; r15 = índice = i    

    shl r13, 4          ; imul r13, 16        

.loop:
    cmp r15, r13          ; condición de corte
    je .fin

    lea r14, qword[r12 + r15]       ; r14 = &arreglo_casos[i] = *caso;

    mov rsi, qword[r14 + CASO_USUARIO_OFFSET]      ; rsi  = caso->usuario
    mov esi, dword[rsi + USUARIO_NIVEL_OFFSET]    ; esi = caso->usuario->nivel;

.bNivel0:

    cmp esi, 0
    jne .bNivel1

    mov rdi, qword[rbx + SEGMENTACION_CASOS0_OFFSET]        ; resultado->casos_nivel_0

    ; 1. Levantas las dos mitades de 8 bytes
    mov rcx, qword[r14]              ; Lee los primeros 8 bytes (Categoría y Estado)
    mov rdx, qword[r14 + 8]         ; Lee los segundos 8 bytes (Puntero al usuario)

    ; 2. Descargás las dos mitades en el destino
    mov qword[rdi + r8], rcx         ; Escribe la primera mitad
    mov qword[rdi + r8 + 8], rdx    ; Escribe la segunda mitad

    add r8, 16      ; j++;
    jmp .siguiente

.bNivel1:

    cmp esi, 1
    jne .bNivel2

    mov rdi, qword[rbx + SEGMENTACION_CASOS1_OFFSET]        ; resultado->casos_nivel_1

    ; 1. Levantas las dos mitades de 8 bytes
    mov rcx, qword[r14]              ; Lee los primeros 8 bytes (Categoría y Estado)
    mov rdx, qword[r14 + 8]         ; Lee los segundos 8 bytes (Puntero al usuario)

    ; 2. Descargás las dos mitades en el destino
    mov qword[rdi + r9], rcx         ; Escribe la primera mitad
    mov qword[rdi + r9 + 8], rdx    ; Escribe la segunda mitad

    add r9, 16      ; k++;
    jmp .siguiente

.bNivel2:

    cmp esi, 2
    jne .siguiente

    mov rdi, qword[rbx + SEGMENTACION_CASOS2_OFFSET]        ; resultado->casos_nivel_2

    ; 1. Levantas las dos mitades de 8 bytes
    mov rcx, qword[r14]              ; Lee los primeros 8 bytes (Categoría y Estado)
    mov rdx, qword[r14 + 8]         ; Lee los segundos 8 bytes (Puntero al usuario)

    ; 2. Descargás las dos mitades en el destino
    mov qword[rdi + r10], rcx         ; Escribe la primera mitad
    mov qword[rdi + r10 + 8], rdx    ; Escribe la segunda mitad

    add r10, 16      ; l++;
    jmp .siguiente

.siguiente:
    add r15, 16
    jmp .loop

.fin:
    mov rax, rbx            ; devuelvo rbx = *resultado   

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret