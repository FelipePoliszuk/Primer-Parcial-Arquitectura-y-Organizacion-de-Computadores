;########### SECCION DE DATOS
section .data
extern malloc
extern strcmp


section .rodata
    strCLT: db "CLT", 0
    strRBO: db "RBO", 0
    strKSC: db "KSC", 0
    strKDT: db "KDT", 0

;########### SECCION DE TEXTO (PROGRAMA)
section .text
; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4
USUARIO_SIZE EQU 8

CASO_CATEGORIA_OFFSET EQU 0
CASO_ESTADO_OFFSET EQU 4
CASO_USUARIO_OFFSET EQU 8
CASO_SIZE EQU 16

SEGMENTACION_CASOS0_OFFSET EQU 0
SEGMENTACION_CASOS1_OFFSET EQU 8
SEGMENTACION_CASOS2_OFFSET EQU 16
SEGMENTACION_SIZE EQU 24

ESTADISTICAS_CLT_OFFSET EQU 0
ESTADISTICAS_RBO_OFFSET EQU 1
ESTADISTICAS_KSC_OFFSET EQU 2
ESTADISTICAS_KDT_OFFSET EQU 3
ESTADISTICAS_ESTADO0_OFFSET EQU 4
ESTADISTICAS_ESTADO1_OFFSET EQU 5
ESTADISTICAS_ESTADO2_OFFSET EQU 6
ESTADISTICAS_SIZE EQU 7



; estadisticas_t* calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id);
; registros

global calcular_estadisticas
calcular_estadisticas:
; arreglo_casos = rdi   rdi / 64 bits
; largo = rsi           no dice tamaño de bits..?
; usuario_id = rdx      edx / 32 bits

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved si los vas a usar
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8            ; alinear stack a 16 bytes


    mov r13, rdi           ; r13 = puntero aa arreglo_casos
    mov r14d, edx          ; r14d = usuario_id
    mov rbx, rsi           ; rbx = largo (preservado entre llamadas)

    mov rdi, ESTADISTICAS_SIZE
    call malloc
    mov r15, rax           ; r15 = resultado - estadisticas_t* 

    mov byte [r15 + ESTADISTICAS_CLT_OFFSET], 0
    mov byte [r15 + ESTADISTICAS_RBO_OFFSET], 0
    mov byte [r15 + ESTADISTICAS_KSC_OFFSET], 0
    mov byte [r15 + ESTADISTICAS_KDT_OFFSET], 0
    mov byte [r15 + ESTADISTICAS_ESTADO0_OFFSET], 0
    mov byte [r15 + ESTADISTICAS_ESTADO1_OFFSET], 0
    mov byte [r15 + ESTADISTICAS_ESTADO2_OFFSET], 0

    xor r12, r12               ;r12 = 0 = indice.
    


    cmp r14d, 0                ;si id == 0 salto a loopCero
    je .loopCero

.loopDistintoCero:
    cmp r12, rbx                ; si r12 = largo salto a fin
    je .fin


    ; calculo offset
    imul r9, r12, CASO_SIZE                     ; r9 = i * sizeof(caso_t)
    mov  r8, [r13 + r9 + CASO_USUARIO_OFFSET] ; r8 = arreglo_casos[i].usuario (puntero)
    cmp dword [r8 + USUARIO_ID_OFFSET], r14d   ; comparar id de usuario (32 bits)
    jne .siguiente1



    imul r9, r12, CASO_SIZE                     ; r9 = i * sizeof(caso_t)

    lea rdi, [r13 + r9 + CASO_CATEGORIA_OFFSET]  
    lea rsi, [rel strCLT]
    call strcmp
    cmp eax, 0
    jne .casoRBO

    add byte [r15 + ESTADISTICAS_CLT_OFFSET], 1

.casoRBO:    

    imul r9, r12, CASO_SIZE  
    lea rdi, [r13 + r9 + CASO_CATEGORIA_OFFSET]  
    lea rsi, [rel strRBO]
    call strcmp
    cmp eax, 0
    jne .casoKSC

    add byte [r15 + ESTADISTICAS_RBO_OFFSET], 1

.casoKSC:  

    imul r9, r12, CASO_SIZE  
    lea rdi, [r13 + r9 + CASO_CATEGORIA_OFFSET]  
    lea rsi, [rel strKSC]
    call strcmp
    cmp eax, 0
    jne .casoKDT

    add byte [r15 + ESTADISTICAS_KSC_OFFSET], 1

.casoKDT:  

    imul r9, r12, CASO_SIZE  
    lea rdi, [r13 + r9 + CASO_CATEGORIA_OFFSET]  
    lea rsi, [rel strKDT]
    call strcmp
    cmp eax, 0
    jne .casoE1

    add byte [r15 + ESTADISTICAS_KDT_OFFSET], 1

.casoE0:  

    imul r9, r12, CASO_SIZE  
    cmp word [r13 + r9 + CASO_ESTADO_OFFSET], 0
    jne .casoE1

    add byte [r15 + ESTADISTICAS_ESTADO0_OFFSET], 1

.casoE1:    

    imul r9, r12, CASO_SIZE 
    cmp word [r13 + r9 + CASO_ESTADO_OFFSET], 1
    jne .casoE2

    add byte [r15 + ESTADISTICAS_ESTADO1_OFFSET], 1

.casoE2:   

    imul r9, r12, CASO_SIZE 
    cmp word [r13 + r9 + CASO_ESTADO_OFFSET], 2
    jne .siguiente1

    add byte [r15 + ESTADISTICAS_ESTADO2_OFFSET], 1
    
    jmp .siguiente1


.siguiente1:
    inc r12
    jmp .loopDistintoCero



; ------------------ELSE-------------------



.loopCero:
    cmp r12, rbx                ; si r12 = largo salto a fin
    je .fin

    imul r9, r12, CASO_SIZE 
    lea rdi, [r13 + r9 + CASO_CATEGORIA_OFFSET]  
    lea rsi, [rel strCLT]
    call strcmp
    cmp eax, 0
    jne .casoRBO2

    add byte [r15 + ESTADISTICAS_CLT_OFFSET], 1

.casoRBO2:    

    imul r9, r12, CASO_SIZE 
    lea rdi, [r13 + r9 + CASO_CATEGORIA_OFFSET]  
    lea rsi, [rel strRBO]
    call strcmp
    cmp eax, 0
    jne .casoKSC2

    add byte [r15 + ESTADISTICAS_RBO_OFFSET], 1

.casoKSC2:  

    imul r9, r12, CASO_SIZE 
    lea rdi, [r13 + r9 + CASO_CATEGORIA_OFFSET]  
    lea rsi, [rel strKSC]
    call strcmp
    cmp eax, 0
    jne .casoKDT2

    add byte [r15 + ESTADISTICAS_KSC_OFFSET], 1

.casoKDT2:  

    imul r9, r12, CASO_SIZE 
    lea rdi, [r13 + r9 + CASO_CATEGORIA_OFFSET]  
    lea rsi, [rel strKDT]
    call strcmp
    cmp eax, 0
    jne .casoE02

    add byte [r15 + ESTADISTICAS_KDT_OFFSET], 1

.casoE02:  

    imul r9, r12, CASO_SIZE 
    cmp word [r13 + r9 + CASO_ESTADO_OFFSET], 0
    jne .casoE12

    add byte [r15 + ESTADISTICAS_ESTADO0_OFFSET], 1

.casoE12:    

    imul r9, r12, CASO_SIZE 
    cmp word [r13 + r9 + CASO_ESTADO_OFFSET], 1
    jne .casoE22

    add byte [r15 + ESTADISTICAS_ESTADO1_OFFSET], 1

.casoE22:   

    imul r9, r12, CASO_SIZE 
    cmp word [r13 + r9 + CASO_ESTADO_OFFSET], 2
    jne .siguiente2

    add byte [r15 + ESTADISTICAS_ESTADO2_OFFSET], 1
    
    jmp .siguiente2


.siguiente2:
    inc r12
    jmp .loopCero    
    



.fin:
    ; valor de retorno
    mov rax, r15       ; ejemplo, devuelvo puntero en rax

    ; === EPÍLOGO ===
    add rsp, 8            ; restaurar alineación antes de los pops
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret    
