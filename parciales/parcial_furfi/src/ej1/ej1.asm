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
; ---------------------------------
TUIT_SIZE EQU 148

PUBLICACION_NEXT_OFFSET EQU 0
PUBLICACION_VALUE_OFFSET EQU 8
; ---------------------------------
PUBLICACION_SIZE EQU 16

FEED_FIRST_OFFSET EQU 0 
; ---------------------------------
FEED_SIZE EQU 8

USUARIO_FEED_OFFSET EQU 0
USUARIO_SEGUIDORES_OFFSET EQU 8
USUARIO_CANT_SEGUIDORES_OFFSET EQU 16
USUARIO_SEGUIDOS_OFFSET EQU 24
USUARIO_CANT_SEGUIDOS_OFFSET EQU 32
USUARIO_BLOQUEADOS_OFFSET EQU 40
USUARIO_CANT_BLOQUEADOS_OFFSET EQU 48
USUARIO_ID_OFFSET EQU 52
; ---------------------------------
USUARIO_SIZE EQU 56

; tuit_t *publicar(char *mensaje, usuario_t *usuario);
global publicar
publicar:
; registros:
	; rdi = *mensaje
	; rsi = *user
    
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
    
    mov r12, rdi        ; r12 = *mensaje
    mov r13, rsi        ; r13 = *user

    mov rdi, TUIT_SIZE
    call malloc

    mov r15, rax        ; r15 = *nuevo_tuit

    mov word[r15 + TUIT_FAVORITOS_OFFSET], 0        ; nuevo_tuit->favoritos = 0;
    mov word[r15 + TUIT_RETUITS_OFFSET], 0          ; nuevo_tuit->retuits = 0;

    mov r8d, dword[r13 + USUARIO_ID_OFFSET]
    mov dword[r15 + TUIT_ID_AUTOR_OFFSET], r8d       ; nuevo_tuit->id_autor = user->id;

    lea rdi, [r15 + TUIT_MENSAJE_OFFSET]
    mov rsi, r12
    call strcpy              ; strcpy(nuevo_tuit->mensaje, mensaje);

    mov rdi, r15
    mov rsi, qword[r13 + USUARIO_FEED_OFFSET]
    call publicar_aux        ; publicar_aux(nuevo_tuit, user->feed);

    mov r14d, dword[r13 + USUARIO_CANT_SEGUIDORES_OFFSET]   ; user->cantSeguidores
    xor rbx, rbx        ; rbx = índice = 0
.loop:
    cmp ebx, r14d          ; condición de corte
    je .fin

    mov rdi, r15
    mov rsi, qword[r13 + USUARIO_SEGUIDORES_OFFSET]
    mov rsi, qword[rsi + (rbx*8)]
    mov rsi, qword[rsi + USUARIO_FEED_OFFSET]

    call publicar_aux            ; llamada a función

.siguiente:
    inc ebx
    jmp .loop

.fin:
    mov rax, r15        ; rax = nuevo_tuit

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; publicacion_t *publicar_aux(tuit_t *tuit, feed_t *feed)
global publicar_aux
publicar_aux:
; registros:
	; rdi = *tuit
	; rsi = *feed
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push r12
    push r13
    push r15
    sub rsp, 8          ; Alineamiento GLOBAL (La pila ya es segura para toda la función)
    
    mov r12, rdi        ; r12 = *tuit
    mov r13, rsi        ; r13 = *feed

    mov rdi, PUBLICACION_SIZE
    call malloc

    mov r15, rax        ; r15 = *nueva_publicacion

    mov qword[r15 + PUBLICACION_VALUE_OFFSET], r12      ; nueva_publicacion->value = tuit;

    mov r8, qword[r13 + FEED_FIRST_OFFSET]              ; r8 = feed->first

    mov qword[r15 + PUBLICACION_NEXT_OFFSET], r8       ; nueva_publicacion->next = feed->first;

    mov qword[r13 + FEED_FIRST_OFFSET], r15             ; feed->first = nueva_publicacion;

.fin:
    mov rax, r15        ; rax = *nueva_publicacion 

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r13
    pop r12
    pop rbp
    ret