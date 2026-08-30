extern free
extern strcmp

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4

USUARIO_SIZE EQU 8


PRODUCTO_USUARIO_OFFSET EQU 0        
PRODUCTO_CATEGORIA_OFFSET EQU 8      
PRODUCTO_NOMBRE_OFFSET EQU 17       
PRODUCTO_ESTADO_OFFSET EQU 42        
PRODUCTO_PRECIO_OFFSET EQU 44        
PRODUCTO_ID_OFFSET EQU 48                

PRODUCTO_SIZE EQU 56                 


PUBLICACION_NEXT_OFFSET EQU 0
PUBLICACION_VALUE_OFFSET EQU 8

PUBLICACION_SIZE EQU 16


CATALOGO_FIRST_OFFSET EQU 0

CATALOGO_SIZE EQU 8

;catalogo* removerCopias(catalogo* h)
global removerCopias
removerCopias:
; registros:
    ; rdi  = *h

; PRÓLOGO
    push rbp
    mov rbp, rsp
; Guardo registros volatiles
    push r12
    push r13

    mov r12, rdi        ; r12 = *h

    mov r13, qword[r12 + CATALOGO_FIRST_OFFSET]     ; r13 = actual
.loop:
    test r13, r13
    jz .fin

    mov rdi, r13        ; paso actual por rdi
    call removerAparicionesPosterioresDe

.siguiente:
    mov r13, qword[r13 + PUBLICACION_NEXT_OFFSET] 
    jmp .loop

.fin:
    mov rax, r12

; EPÍLOGO
    pop r13
    pop r12

    pop rbp
    ret




; void removerAparicionesPosterioresDe(publicacion_t* publicacion)
global removerAparicionesPosterioresDe
removerAparicionesPosterioresDe:
; registros: 
    ; rdi = *publicacion

; PRÓLOGO
    push rbp
    mov rbp, rsp  
; Guardo registros volatiles
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8

    mov r12, rdi        ; r12 = *publicacion

    lea rbx, [r12 + PUBLICACION_NEXT_OFFSET]    ; rbx = **indirecto

.loop:
    cmp qword[rbx], 0
    je .fin

    mov r13, qword[rbx]         ; r13 =  *actual

    mov r8, qword[r13 + PUBLICACION_VALUE_OFFSET]       ; actual->value
    mov r8, qword[r8 + PRODUCTO_USUARIO_OFFSET]         ; actual->value->usuario

    mov r9, qword[r12 + PUBLICACION_VALUE_OFFSET]       ; publicacion->value
    mov r9, qword[r9 + PRODUCTO_USUARIO_OFFSET]         ; publicacion->value->usuario

    cmp r8, r9
    jne .else

    mov r8, qword[r13 + PUBLICACION_VALUE_OFFSET]       ; actual->value
    lea rdi, [r8 + PRODUCTO_NOMBRE_OFFSET]              ; actual->value->nombre

    mov r9, qword[r12 + PUBLICACION_VALUE_OFFSET]       ; publicacion->value
    lea rsi, [r9 + PRODUCTO_NOMBRE_OFFSET]              ; publicacion->value->nombre

    call strcmp

    cmp al, 0
    jne .else

    mov r8, qword[r13 + PUBLICACION_NEXT_OFFSET]
    mov qword[rbx], r8                                   ; *indirecto = actual->next;

    mov rdi, qword[r13 + PUBLICACION_VALUE_OFFSET]       ; actual->value

    call free

    mov rdi, r13       ; actual

    call free

    jmp .loop

.else:
    lea rbx, [r13 + PUBLICACION_NEXT_OFFSET]             ; indirecto = &(actual->next);
    jmp .loop


.fin:
; EPÍLOGO
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp
    ret

