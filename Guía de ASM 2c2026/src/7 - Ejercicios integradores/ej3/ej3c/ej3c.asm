extern strcmp
extern malloc

section .rodata
    str_clt db "CLT", 0  ; El texto con su byte nulo al final
    str_rbo db "RBO", 0  ; El texto con su byte nulo al final
    str_ksc db "KSC", 0  ; El texto con su byte nulo al final
    str_kdt db "KDT", 0  ; El texto con su byte nulo al final

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

global calcular_estadisticas

;void calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id)
calcular_estadisticas:
; registros:
	; rdi = *arreglo_casos
	; esi =  largo
	; edx = usuario_id
    
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
    
    mov r12,  rdi         ; r12 = *arreglo_casos
    mov r13d,  esi        ; r13 =  largo
    mov r14d,  edx        ; r14 =  usuario_id

    mov rdi, ESTADISTICAS_SIZE
    call malloc

    mov rbx, rax        ; rbx =  *estadisticas

    mov byte[rbx + ESTADISTICAS_CLT_OFFSET], 0
    mov byte[rbx + ESTADISTICAS_RBO_OFFSET], 0
    mov byte[rbx + ESTADISTICAS_KSC_OFFSET], 0
    mov byte[rbx + ESTADISTICAS_KDT_OFFSET], 0

    mov byte[rbx + ESTADISTICAS_ESTADO0_OFFSET], 0
    mov byte[rbx + ESTADISTICAS_ESTADO1_OFFSET], 0
    mov byte[rbx + ESTADISTICAS_ESTADO2_OFFSET], 0


    xor r15, r15        ; r15d = índice = i    
    shl r13d, 4          ; imul r13d, 16     

    cmp r14d, 0
    je .loop0

.loopNo0:
    cmp r15d, r13d          ; condición de corte
    je .fin

    lea r9, qword[r12 + r15]                      ; r9 = &arreglo_casos[i] = *caso;

    mov rsi, qword[r9 + CASO_USUARIO_OFFSET]      ; rsi  = caso->usuario
    mov esi, dword[rsi + USUARIO_ID_OFFSET]       ; esi = caso->usuario->id;

    cmp esi, r14d
    jne .siguienteNo0

.chequeoCategorias:

.CLT:
    lea rdi, [r9 + CASO_CATEGORIA_OFFSET]       ; rdi = caso->categoria
    mov rsi, str_clt                            ; rsi = puntero al string estático

    push r8
    push r9
    call strcmp    
    pop r9
    pop r8

    cmp eax, 0
    je .sumoCLT

.RBO:
    lea rdi, [r9 + CASO_CATEGORIA_OFFSET]       ; rdi = caso->categoria
    mov rsi, str_rbo                            ; rsi = puntero al string estático

    push r8
    push r9
    call strcmp    
    pop r9
    pop r8

    cmp eax, 0
    je .sumoRBO

.KSC:
    lea rdi, [r9 + CASO_CATEGORIA_OFFSET]       ; rdi = caso->categoria
    mov rsi, str_ksc                           ; rsi = puntero al string estático

    push r8
    push r9
    call strcmp    
    pop r9
    pop r8

    cmp eax, 0
    je .sumoKSC

.KDT:
    lea rdi, [r9 + CASO_CATEGORIA_OFFSET]       ; rdi = caso->categoria
    mov rsi, str_kdt                            ; rsi = puntero al string estático

    push r8
    push r9
    call strcmp    
    pop r9
    pop r8

    cmp eax, 0
    je .sumoKDT            

.chequeoEstados:

    cmp word[r9 + CASO_ESTADO_OFFSET], 0
    je .sumoCaso0

    cmp word[r9 + CASO_ESTADO_OFFSET], 1
    je .sumoCaso1

    cmp word[r9 + CASO_ESTADO_OFFSET], 2
    je .sumoCaso2        

.siguienteNo0:
    add r15d, 16
    jmp .loopNo0

.loop0:
    cmp r15d, r13d          ; condición de corte
    je .fin

    lea r9, qword[r12 + r15]                      ; r9 = &arreglo_casos[i] = *caso;

.chequeoCategorias2:

.CLT2:
    lea rdi, [r9 + CASO_CATEGORIA_OFFSET]       ; rdi = caso->categoria
    mov rsi, str_clt                            ; rsi = puntero al string estático

    push r8
    push r9
    call strcmp    
    pop r9
    pop r8

    cmp eax, 0
    je .sumoCLT2

.RBO2:
    lea rdi, [r9 + CASO_CATEGORIA_OFFSET]       ; rdi = caso->categoria
    mov rsi, str_rbo                            ; rsi = puntero al string estático

    push r8
    push r9
    call strcmp    
    pop r9
    pop r8

    cmp eax, 0
    je .sumoRBO2

.KSC2:
    lea rdi, [r9 + CASO_CATEGORIA_OFFSET]       ; rdi = caso->categoria
    mov rsi, str_ksc                           ; rsi = puntero al string estático

    push r8
    push r9
    call strcmp    
    pop r9
    pop r8

    cmp eax, 0
    je .sumoKSC2

.KDT2:
    lea rdi, [r9 + CASO_CATEGORIA_OFFSET]       ; rdi = caso->categoria
    mov rsi, str_kdt                            ; rsi = puntero al string estático

    push r8
    push r9
    call strcmp    
    pop r9
    pop r8

    cmp eax, 0
    je .sumoKDT2            

.chequeoEstados2:

    cmp word[r9 + CASO_ESTADO_OFFSET], 0
    je .sumoCaso02

    cmp word[r9 + CASO_ESTADO_OFFSET], 1
    je .sumoCaso12

    cmp word[r9 + CASO_ESTADO_OFFSET], 2
    je .sumoCaso22 

.siguiente0:
    add r15d, 16
    jmp .loop0



.sumoCLT:
    inc byte[rbx + ESTADISTICAS_CLT_OFFSET]
    jmp .chequeoEstados

.sumoRBO:
    inc byte[rbx + ESTADISTICAS_RBO_OFFSET]
    jmp .chequeoEstados

.sumoKSC:
    inc byte[rbx + ESTADISTICAS_KSC_OFFSET]
    jmp .chequeoEstados

.sumoKDT:
    inc byte[rbx + ESTADISTICAS_KDT_OFFSET]
    jmp .chequeoEstados


.sumoCaso0:
    inc byte[rbx + ESTADISTICAS_ESTADO0_OFFSET]
    jmp .siguienteNo0

.sumoCaso1:
    inc byte[rbx + ESTADISTICAS_ESTADO1_OFFSET]
    jmp .siguienteNo0

.sumoCaso2:
    inc byte[rbx + ESTADISTICAS_ESTADO2_OFFSET]
    jmp .siguienteNo0


.sumoCLT2:
    inc byte[rbx + ESTADISTICAS_CLT_OFFSET]
    jmp .chequeoEstados2

.sumoRBO2:
    inc byte[rbx + ESTADISTICAS_RBO_OFFSET]
    jmp .chequeoEstados2

.sumoKSC2:
    inc byte[rbx + ESTADISTICAS_KSC_OFFSET]
    jmp .chequeoEstados2

.sumoKDT2:
    inc byte[rbx + ESTADISTICAS_KDT_OFFSET]
    jmp .chequeoEstados2


.sumoCaso02:
    inc byte[rbx + ESTADISTICAS_ESTADO0_OFFSET]
    jmp .siguiente0

.sumoCaso12:
    inc byte[rbx + ESTADISTICAS_ESTADO1_OFFSET]
    jmp .siguiente0

.sumoCaso22:
    inc byte[rbx + ESTADISTICAS_ESTADO2_OFFSET]
    jmp .siguiente0


.fin:
    mov rax, rbx        ; devuelvo *estadisticas en rax

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
