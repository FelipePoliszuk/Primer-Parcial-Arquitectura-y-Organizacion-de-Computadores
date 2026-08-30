extern malloc

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


; tuit_t **trendingTopic(usuario_t *usuario, uint8_t (*esTuitSobresaliente)(tuit_t *));
global trendingTopic 
trendingTopic:

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


    mov r12, rdi        ; r12 = *usuario
    mov r13, rsi        ; r13 = *esTuitSobresaliente    

    call trendingTopic_aux

    test eax, eax
    jz .devuelvoNull 

    mov r14d, eax       ; r14d = tamaño

    mov r8d, r14d
    inc r8d     

    imul r8d, 8 
    mov edi, r8d    
    call malloc

    mov rbx, rax        ; rbx = **arreglo 

    mov r15, qword[r12 + USUARIO_FEED_OFFSET]       ; r15 = user->feed
    mov r15, qword[r15 + FEED_FIRST_OFFSET]         ; r15 = *actual = user->feed->first

    mov dword[rbp-48], 0        ; uint32_t i = 0;

.loop:
    test r15, r15          ; condición de corte
    jz .devuelvoArreglo


    mov r8, qword[r15 + PUBLICACION_VALUE_OFFSET]            ; r8 = actual->value
    mov r8d, dword[r8 + TUIT_ID_AUTOR_OFFSET]                   ; r8 = actual->value->id_autor

    cmp r8d, dword[r12 + USUARIO_ID_OFFSET]         
    jne .siguiente

    mov r8, qword[r15 + PUBLICACION_VALUE_OFFSET]            ; r8 = actual->value
    mov rdi, r8         ; rdi = actual->value
    call r13

    test al, al
    jz .siguiente

    mov r8, qword[r15 + PUBLICACION_VALUE_OFFSET]            ; r8 = actual->value
    xor r9, r9
    mov r9d, dword[rbp-48]
    mov qword[rbx + (r9*8)], r8            ; arreglo[i] = actual->value;

    inc dword[rbp-48]       ; i ++;

.siguiente:
    mov r15, qword[r15 + PUBLICACION_NEXT_OFFSET]        ; actual = actual->next;
    jmp .loop    

.devuelvoArreglo:
    mov qword[rbx + (r14*8)], 0     ; arreglo[tamaño] = NULL;
    mov rax, rbx      ; rax = arreglo
    jmp .fin

.devuelvoNull:
    mov rax, 0      ; rax = NULL

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


; uint32_t trendingTopic_aux(usuario_t *user, uint8_t (*esTuitSobresaliente)(tuit_t *));
global trendingTopic_aux 
trendingTopic_aux:
; registros  
    ; rdi = *user
    ; rsi = *esTuitSobresaliente

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push r12
    push r13
    push r14
    push r15


    mov r12, rdi        ; r12 = *user
    mov r13, rsi        ; r13 = *esTuitSobresaliente    

    xor r14, r14        ; r14b = cantidad = 0 

    mov r15, qword[r12 + USUARIO_FEED_OFFSET]     ; r15  = user->feed
    mov r15, qword[r15 + FEED_FIRST_OFFSET]     ; r15  = *actual = user->feed->first

.loop:
    test r15, r15          ; condición de corte
    jz .fin

    mov r8, qword[r15 + PUBLICACION_VALUE_OFFSET]            ; r8 = actual->value
    mov r8d, dword[r8 + TUIT_ID_AUTOR_OFFSET]                   ; r8 = actual->value->id_autor

    cmp r8d, dword[r12 + USUARIO_ID_OFFSET]
    jne .siguiente


    mov rdi, qword[r15 + PUBLICACION_VALUE_OFFSET]          ; rdi = actual->value
    call r13

    test al, al
    jz .siguiente        

    inc r14d        ; cantidad ++;

.siguiente:
    mov r15, qword[r15 + PUBLICACION_NEXT_OFFSET]        ; actual = actual->next;
    jmp .loop

.fin:
    mov eax, r14d       

    ; === EPÍLOGO ===
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
