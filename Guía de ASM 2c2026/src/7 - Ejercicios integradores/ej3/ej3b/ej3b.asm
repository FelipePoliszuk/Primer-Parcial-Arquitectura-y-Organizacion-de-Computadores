extern strcmp

section .rodata
    str_clt db "CLT", 0  ; El texto con su byte nulo al final
    str_rbo db "RBO", 0  ; El texto con su byte nulo al final

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

CERRADO_FAVORABLE EQU 1
CERRADO_DESFAVORABLE EQU 2

global resolver_automaticamente

;void resolver_automaticamente(funcionCierraCasos* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo)
resolver_automaticamente:
; registros:
	; rdi = *funcion
	; rsi = *arreglo_casos
	; rdx = *casos_a_revisar
	; rcx =  largo
    
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
    
    mov r12,  rdi        ; r12 = *funcion
    mov r13,  rsi        ; r13 = *arreglo_casos
    mov r14,  rdx        ; r14 = *casos_a_revisar
    mov r15d, ecx        ; r15d =  largo

    xor r8, r8          ; r8  = 0 = j

    xor rbx, rbx        ; ebx = índice = i    

    shl r15d, 4          ; imul r15d, 16        

.loop:
    cmp ebx, r15d          ; condición de corte
    je .fin

    lea r9, qword[r13 + rbx]                      ; r14 = &arreglo_casos[i] = *caso;

    mov rsi, qword[r9 + CASO_USUARIO_OFFSET]      ; rsi  = caso->usuario
    mov esi, dword[rsi + USUARIO_NIVEL_OFFSET]    ; esi = caso->usuario->nivel;

    cmp esi, 1
    je .nivel1o2

    cmp esi, 2
    je .nivel1o2    

    cmp esi, 0
    je .nivel0

    jmp .siguiente


.nivel1o2:

    mov rdi, r9   ; paso caso por rdi 

    push r8
    push r9
    call r12
    pop r9
    pop r8

    cmp ax, 1
    je .pongo1

    cmp ax, 0
    je .comparoCategorias    

    jmp .siguiente

.comparoCategorias:

.CLT:
    lea rdi, [r9 + CASO_CATEGORIA_OFFSET]       ; rdi = caso->categoria
    mov rsi, str_clt      ; rsi = puntero al string estático

    push r8
    push r9
    call strcmp    
    pop r9
    pop r8

    cmp eax, 0
    je .pongo2


.RBO:
    lea rdi, [r9 + CASO_CATEGORIA_OFFSET]       ; rdi = caso->categoria
    mov rsi, str_rbo        ; ; rsi = puntero al string estático

    push r8
    push r9
    call strcmp    
    pop r9
    pop r8

    cmp eax, 0
    je .pongo2    

    ; copio de a partes el caso porque mide 16 bytes y no puedo en un reg solo
    mov r10, qword[r9]
    mov r11, qword[r9 + 8] 

    mov qword[r14 + r8], r10
    mov qword[r14 + r8 + 8], r11

    add r8, 16

    jmp .siguiente

.pongo1:
    mov word[r9 +CASO_ESTADO_OFFSET], 1
    jmp .siguiente

.pongo2: 
    mov word[r9 +CASO_ESTADO_OFFSET], 2
    jmp .siguiente


.nivel0:
    ; copio de a partes el caso porque mide 16 bytes y no puedo en un reg solo
    mov r10, qword[r9]
    mov r11, qword[r9 + 8] 

    mov qword[r14 + r8], r10
    mov qword[r14 + r8 + 8], r11

    add r8, 16

.siguiente:
    add ebx, 16
    jmp .loop

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