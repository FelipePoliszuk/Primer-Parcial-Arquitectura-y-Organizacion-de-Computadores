extern free

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
TUIT_MENSAJE_OFFSET EQU 0
TUIT_FAVORITOS_OFFSET EQU 140
TUIT_RETUITS_OFFSET EQU 142
TUIT_ID_AUTOR_OFFSET EQU 144

TUIT_SIZE EQU 148

PUBLICACION_NEXT_OFFSET EQU 0
PUBLICACION_VALUE_OFFSET EQU 8

PUBLICACION_SIZE EQU 16

FEED_FIRST_OFFSET EQU 0 

FEED_SIZE EQU 8

USUARIO_FEED_OFFSET EQU 0;
USUARIO_SEGUIDORES_OFFSET EQU 8; 
USUARIO_CANT_SEGUIDORES_OFFSET EQU 16; 
USUARIO_SEGUIDOS_OFFSET EQU 24; 
USUARIO_CANT_SEGUIDOS_OFFSET EQU 32; 
USUARIO_BLOQUEADOS_OFFSET EQU 40; 
USUARIO_CANT_BLOQUEADOS_OFFSET EQU 48; 
USUARIO_ID_OFFSET EQU 52; 

USUARIO_SIZE EQU 56

; void bloquearUsuario(usuario_t *usuario, usuario_t *usuarioABloquear);
global bloquearUsuario 
bloquearUsuario:
; registros
;   1. RDI = usuario_t *usuario
;   2. RSI = usuario_t *usuarioABloquear

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved si los vas a usar
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi            ;r12 = usuario 
    mov r13, rsi            ;r13 = usuarioABloquear

    mov r8, [r12 + USUARIO_BLOQUEADOS_OFFSET]

    mov r9d, [r12 + USUARIO_CANT_BLOQUEADOS_OFFSET]

    mov [r8 + r9*8], r13

    add dword[r12 + USUARIO_CANT_BLOQUEADOS_OFFSET], 1


    mov rdi, [r12 + USUARIO_FEED_OFFSET]         ; pasar argumento
    mov rsi, r13                                ; pasar 
    
    call bloquear_auxiliar                           ; llamada a función


    mov rdi, [r13 + USUARIO_FEED_OFFSET]         ; pasar argumento
    mov rsi, r12                             ; pasar argumento

    call bloquear_auxiliar            ; llamada a función

.fin:

    ; === EPÍLOGO ===
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret





global bloquear_auxiliar 
bloquear_auxiliar:
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    lea r12, [rdi + FEED_FIRST_OFFSET]
    mov r13, rsi

.loop:
    cmp qword [r12], 0
    je .fin

    mov rax, [r12]  ; rax = el nodo actual

    cmp qword [rax + PUBLICACION_VALUE_OFFSET], 0   
    je .siguiente

    mov r8, [rax + PUBLICACION_VALUE_OFFSET]    
    
    mov r8d, [r8 + TUIT_ID_AUTOR_OFFSET]
    mov r9d, [r13 + USUARIO_ID_OFFSET]

    cmp r8d, r9d
    jne .siguiente

    ; === BORRAR ===
    mov r10, [r12]  ; r10 = nodo a borrar (también está en rax)

    mov r11, [r10 + PUBLICACION_NEXT_OFFSET]

    mov [r12], r11  ; Actualizamos la flecha anterior

    mov rdi, r10    ; rdi = nodo a borrar
    call free       

    ; [FIX 3] Si borramos, NO avanzamos. Volvemos a evaluar r12.
    jmp .loop       

.siguiente:
    ; [FIX 2] Usar RAX (el nodo actual valido), r10 tiene basura aquí
    lea r12, [rax + PUBLICACION_NEXT_OFFSET]

    jmp .loop

.fin:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret