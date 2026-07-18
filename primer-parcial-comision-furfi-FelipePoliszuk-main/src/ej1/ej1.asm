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

USUARIO_FEED_OFFSET EQU 0
USUARIO_SEGUIDORES_OFFSET EQU 8
USUARIO_CANT_SEGUIDORES_OFFSET EQU 16
USUARIO_SEGUIDOS_OFFSET EQU 24
USUARIO_CANT_SEGUIDOS_OFFSET EQU 32
USUARIO_BLOQUEADOS_OFFSET EQU 40
USUARIO_CANT_BLOQUEADOS_OFFSET EQU 48
USUARIO_ID_OFFSET EQU 52
USUARIO_SIZE EQU 56



; tuit_t *publicar(char *mensaje, usuario_t *usuario);
global publicar
publicar:
; registros: 
    ; RDI = *mensaje
    ; RSI = *usuario

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    push r14

    mov r12, rdi        ; r12 = *mensaje
    mov r13, rsi        ; r13 = *usuario

    mov rdi, TUIT_SIZE
    call malloc

    mov rbx, rax        ; rbx = *nuevo_tuit

    mov word[rbx + TUIT_FAVORITOS_OFFSET], 0        ; nuevo_tuit->favoritos = 0;
    mov word[rbx + TUIT_RETUITS_OFFSET], 0          ; nuevo_tuit->retuits = 0;

    mov r8d, dword[r13 + USUARIO_ID_OFFSET]
    mov dword[rbx + TUIT_ID_AUTOR_OFFSET], r8d        ; nuevo_tuit->id_autor = user->id;


    lea rdi, [rbx + TUIT_MENSAJE_OFFSET]        ; rdi = char mensaje[140]
    mov rsi, r12
    call strcpy     


    mov rdi, rbx                                ; rdi = nuevo_tuit
    mov rsi, qword[r13 + USUARIO_FEED_OFFSET]        ; rsi = user->feed
    call publicar_aux

    xor r14, r14        ; r14 = índice = 0

.loop:
    cmp r14d, dword[r13 + USUARIO_CANT_SEGUIDORES_OFFSET]          ; condición de corte
    je .fin

    mov rdi, rbx                                ; rdi = nuevo_tuit
    
    mov r8, qword[r13 + USUARIO_SEGUIDORES_OFFSET]   ; r8 = user->seguidores

    mov r8, qword[r8 + (r14*8)]        ; r8 = user->seguidores[i]

    mov rsi, qword[r8 + USUARIO_FEED_OFFSET]        ; rsi = user->seguidores[i]->feed

    call publicar_aux


.siguiente:
    inc r14d
    jmp .loop

.fin:
    mov rax, rbx       

    ; === EPÍLOGO ===

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
    ; RDI = *tuit
    ; RSI = *feed

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

    mov qword[rax + PUBLICACION_VALUE_OFFSET], r12      ; nueva_publicacion->value = tuit;
    
    mov r8, qword[r13 + FEED_FIRST_OFFSET]
    mov qword[rax + PUBLICACION_NEXT_OFFSET], r8        ; nueva_publicacion->next = feed->first;

    mov qword[r13 + FEED_FIRST_OFFSET], rax             ; feed->first = nueva_publicacion;

    ; === EPÍLOGO ===
    pop r13
    pop r12
    pop rbp
    ret
