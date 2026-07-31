extern malloc

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


;producto_t* filtrarPublicacionesNuevasDeUsuariosVerificados (catalogo* h)
global filtrarPublicacionesNuevasDeUsuariosVerificados
filtrarPublicacionesNuevasDeUsuariosVerificados:
; Registros:
    ; rdi = *h

; PRÓLOGO
    push rbp
    mov rbp, rsp
; Preservo registros volatiles
    push rbx 
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8        ;  alineo la pila

    mov r12, rdi        ; r12 = *h

    call cantidadDeProductos

    mov r13d, eax        ; r13d  = tamaño

    test r13d, r13d
    jz  .devuelvoNULL

    mov edi, r13d           ; fijarme si no hay que usar movxz /movzx

    inc edi             ; edi = (tamaño + 1)

    imul edi, 8

    call malloc

    mov r15, rax        ; r15 = **arreglo

    mov rbx, qword[r12 + CATALOGO_FIRST_OFFSET]     ; r12 = *actual

    xor r14, r14         ; i = 0


.loop:
    test rbx, rbx
    jz .devuelvoARREGLO
    
    mov rdi, qword[rbx + PUBLICACION_VALUE_OFFSET]

    call cumpleCondiciones

    test al, al
    jz .siguiente

    mov rdi, qword[rbx + PUBLICACION_VALUE_OFFSET]

    mov qword[r15 + (r14*8)], rdi       ; arreglo[i] = actual->value; 

    inc r14             ; i++

.siguiente:
    mov rbx, qword[rbx + PUBLICACION_NEXT_OFFSET]       ;actual = actual->next;
    jmp .loop

.devuelvoNULL:
    mov rax, 0
    jmp .fin

.devuelvoARREGLO:

    mov qword[r15 + (r13*8)], 0       ; arreglo[tamaño] = NULL
    mov rax, r15


.fin:
; EPÍLOGO
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx 
    
    pop rbp
    ret


; uint32_t cantidadDeProductos(catalogo_t *h)
global cantidadDeProductos
cantidadDeProductos:
; Registros:
    ; rdi = *h

; PRÓLOGO
    push rbp
    mov rbp, rsp
; Preservo registros volatiles
    push rbx 
    push r12
    push r15
    sub rsp, 8        ;  alineo la pila

    mov r12, rdi        ; r12 = *h
    xor r15, r15        ; r15 = cantidad = 0 

    mov rbx, qword[r12 + CATALOGO_FIRST_OFFSET]     ; r12 = *actual

.loop:
    test rbx, rbx
    jz .fin
    
    mov rdi, qword[rbx + PUBLICACION_VALUE_OFFSET]

    call cumpleCondiciones

    test al, al
    jz .siguiente

    inc r15     ; cantidad++;


.siguiente:
    mov rbx, qword[rbx + PUBLICACION_NEXT_OFFSET]       ;actual = actual->next;
    jmp .loop

.fin:
    mov rax, r15

; EPÍLOGO
    add rsp, 8
    pop r15
    pop r12
    pop rbx 
    
    pop rbp
    ret

; bool cumpleCondiciones(producto_t *producto)
global cumpleCondiciones
cumpleCondiciones:
; Registros:
    ; rdi = *producto

; PRÓLOGO
    push rbp
    mov rbp, rsp

    cmp word[rdi + PRODUCTO_ESTADO_OFFSET], 1

    jne .devuelvoFalse

    mov r8, qword[rdi + PRODUCTO_USUARIO_OFFSET]

    cmp byte[r8 + USUARIO_NIVEL_OFFSET], 1

    jb .devuelvoFalse      

.devuelvoTrue:
    mov rax, 1
    jmp .fin

.devuelvoFalse:
    mov rax, 0

.fin:
; EPÍLOGO
    pop rbp
    ret