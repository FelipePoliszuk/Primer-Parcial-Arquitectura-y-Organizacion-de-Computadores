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
	; rsi = *usuario
    
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
    mov r13, rsi        ; r13 = *usuario

    mov rdi, TUIT_SIZE
    call malloc
    mov rbx, rax        ; rbx = *tuit

    mov word[rbx + TUIT_FAVORITOS_OFFSET], 0        ; tuit->favoritos = 0;
    mov word[rbx + TUIT_RETUITS_OFFSET], 0          ; tuit->retuits = 0;
    mov r8d, dword[r13 + USUARIO_ID_OFFSET] 
    mov dword[rbx + TUIT_ID_AUTOR_OFFSET], r8d      ; tuit->id_autor = user->id;


    lea rdi, [rbx + TUIT_MENSAJE_OFFSET]             ; rdi = tuit->mensaje
    mov rsi, r12                                     ; rsi = mensaje
    call strcpy


    mov rdi, rbx                                     ; rdi = *tuit
    mov rsi, qword[r13 + USUARIO_FEED_OFFSET]        ; rsi =  user->feed
    call publicar_aux 


    xor r14, r14        ; r14d = índice = 0

.loop:
    cmp r14d, dword[r13 + USUARIO_CANT_SEGUIDORES_OFFSET]          ; condición de corte
    je .fin

    mov rdi, rbx                                              ; rdi = *tuit

    mov rsi, qword[r13 + USUARIO_SEGUIDORES_OFFSET]            ; user->seguidores
    mov rsi, qword[rsi + (r14*8)]                              ; user->seguidores[i]
    mov rsi, qword[rsi + USUARIO_FEED_OFFSET]                  ; user->seguidores[i]->feed

    call publicar_aux

.siguiente:
    inc r14d
    jmp .loop

.fin:
    mov rax, rbx        ; return tuit

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
    
    mov r12, rdi        ; r12 = *tuit
    mov r13, rsi        ; r13 = *feed

    mov rdi, PUBLICACION_SIZE
    call malloc
    mov r9, rax        ; r9 = *publicacion_nueva

    mov qword[r9 + PUBLICACION_VALUE_OFFSET], r12   ; publicacion_nueva->value = tuit;
    mov r8, qword[r13 + FEED_FIRST_OFFSET]
    mov qword[r9 + PUBLICACION_NEXT_OFFSET], r8     ; publicacion_nueva->next = feed->first;

    mov qword[r13 + FEED_FIRST_OFFSET], r9     ; feed->first = publicacion_nueva;

.fin:
    mov rax, r9        ; return publicacion_nueva;

    ; === EPÍLOGO ===
    pop r13
    pop r12
    pop rbp
    ret