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

; void bloquearUsuario(usuario_t *usuario, usuario_t *usuarioABloquear);
global bloquearUsuario 
bloquearUsuario:
; registros:
	; rdi = *usuario
	; rsi = *usuarioABloquear
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push r12
    push r13
    
    mov r12, rdi        ; r12 = *usuario
    mov r13, rsi        ; r13 = *usuarioABloquear

    mov r8d, dword[r12 + USUARIO_CANT_BLOQUEADOS_OFFSET]        ; r8d = usuario->cantBloqueados

    mov r9, qword[r12 + USUARIO_BLOQUEADOS_OFFSET]              ; usuario->bloqueados
    mov qword[r9 + (r8*8)], r13                                 ; usuario->bloqueados[usuario->cantBloqueados]

    inc dword[r12 + USUARIO_CANT_BLOQUEADOS_OFFSET]

    mov rdi, qword[r12 + USUARIO_FEED_OFFSET]
    mov rsi, r13
    call bloquearUsuario_aux

    mov rdi, qword[r13 + USUARIO_FEED_OFFSET]
    mov rsi, r12
    call bloquearUsuario_aux    

.fin:
    ; === EPÍLOGO ===
    pop r13
    pop r12
    pop rbp
    ret


; void bloquearUsuario_aux(feed_t *feed, usuario_t *usuario);
global bloquearUsuario_aux 
bloquearUsuario_aux:
; registros:
	; rdi = *feed
	; rsi = *usuario
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    push r14
    
    mov r12, rdi        ; r12 = *feed
    mov r13, rsi        ; r13 = *usuario

    lea rbx, [r12 + FEED_FIRST_OFFSET]      ; rbx = **indirecto = &(feed->first) 

.loop:
    cmp qword[rbx], 0          ; condición de corte
    je .fin

    mov r14, qword[rbx]         ;r14 = *actual

    mov r8, qword[r14 + PUBLICACION_VALUE_OFFSET]       ; actual->value
    mov r8d, dword[r8 + TUIT_ID_AUTOR_OFFSET]       ; actual->value->id_autor

    cmp r8d, dword[r13 + USUARIO_ID_OFFSET]
    je .borro

    jmp .else

.borro: 

    mov r8, qword[r14 + PUBLICACION_NEXT_OFFSET]
    mov qword[rbx], r8      ; *indirecto = actual->next;

    mov rdi, r14
    call free

    jmp .loop

.else:
    lea rbx, [r14 + PUBLICACION_NEXT_OFFSET]        ; indirecto = &(actual->next);
    jmp .loop

.fin:
    ; === EPÍLOGO ===
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
