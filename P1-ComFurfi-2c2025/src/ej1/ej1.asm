extern malloc
extern strcpy

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

; tuit_t *publicar(char *mensaje, usuario_t *usuario);
global publicar
publicar:
; registros
;   1. RDI = char *mensaje
;   2. RSI = usuario_t *usuario

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15

    mov r12, rdi               ;r12 = mensaje
    mov r13, rsi               ;r13 = usuario


    mov r8, TUIT_SIZE

    mov rdi, r8                          ; pasar argumento
    call malloc                          ; llamada a función

    mov r14, rax                         ;r14 = nuevo_tuit
    lea rdi, [r14 + TUIT_MENSAJE_OFFSET]

    mov rsi, r12

    call strcpy

    mov word[r14 + TUIT_FAVORITOS_OFFSET], 0
    mov word[r14 + TUIT_RETUITS_OFFSET], 0 

    mov r8d, [r13 + USUARIO_ID_OFFSET]

    mov [r14 + TUIT_ID_AUTOR_OFFSET], r8d

    mov rdi, [r13 + USUARIO_FEED_OFFSET]
    mov rsi, r14

    call crear_pub

    xor r15, r15            ;r15 = contador = 0

.loop:
    cmp r15d, [r13 + USUARIO_CANT_SEGUIDORES_OFFSET]          ; condición de corte
    je .fin

    mov r8, [r13 + USUARIO_SEGUIDORES_OFFSET]

    mov r8, [r8 + r15*8] 

    mov r8, [r8 + USUARIO_FEED_OFFSET]

    mov rdi, r8             ; pasar argumento
    mov rsi, r14            ; pasar argumento

    call crear_pub            ; llamada a función


.siguiente:
    inc r15
    jmp .loop

.fin:

    mov rax, r14
    ; === EPÍLOGO ===
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret






; void crear_pub(feed_t* feed, tuit_t* tuit_a_publicar);
global crear_pub
crear_pub:
; registros
;   1. RDI = feed_t *feed
;   2. RSI = tuit_t *tuit_a_publicar

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14

    mov r12, rdi        ;r12 = feed
    mov r13, rsi        ;r13 = tuit

    mov r8, PUBLICACION_SIZE

    mov rdi, r8         ; pasar argumento
    call malloc            ; llamada a función

    mov r8, rax

    mov [r8 + PUBLICACION_VALUE_OFFSET], r13

    mov r9, [r12 + FEED_FIRST_OFFSET]

    mov [r8 + PUBLICACION_NEXT_OFFSET], r9

    mov [r12 + FEED_FIRST_OFFSET], r8

    ; === EPÍLOGO ===
    pop r14
    pop r13
    pop r12
    pop rbp
    ret