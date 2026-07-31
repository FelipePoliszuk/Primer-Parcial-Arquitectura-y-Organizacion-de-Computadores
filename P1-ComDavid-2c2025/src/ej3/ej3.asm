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


;usuario_t **asignarNivelesParaNuevosUsuarios(uint32_t *ids, uint32_t cantidadDeIds, uint8_t (*deQueNivelEs)(uint32_t))
global asignarNivelesParaNuevosUsuarios 
asignarNivelesParaNuevosUsuarios:
; registros
    ; rdi = *ids
    ; esi = cantidadDeIds
    ; rdx = *deQueNivelEs

; PRÓLOGO
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8

    test esi, esi
    jz .devuelvoNULL

    mov r12, rdi            ; r12 = *ids
    mov r13d, esi           ; r13d = cantidadDeIds
    mov r14, rdx            ; r14 = *deQueNivelEs

    mov edi, r13d           ; edi = cantidadDeIds
    imul edi, 8

    call malloc

    mov r15, rax            ; r15 = ** arreglo

    xor rbx, rbx            ; ebx = i = 0

.loop:
    cmp ebx, r13d
    je .devuelvoARREGLO

    mov edi, dword[r12 + (rbx*4)]            ; edi = ids[i]
    call r14    

    mov byte[rbp-48], al              ; [rbp-48] = nivel_usuario

    mov rdi, USUARIO_SIZE
    call malloc

    mov r8b, byte[rbp-48]                  ; r8b = nivel_usuario
    mov byte[rax + USUARIO_NIVEL_OFFSET], r8b

    mov edi, [r12 + (rbx*4)]                    ; edi = ids[i]
    mov dword[rax + USUARIO_ID_OFFSET], edi

    mov qword[r15 + (rbx*8)], rax

.siguiente:
    inc ebx
    jmp .loop

.devuelvoNULL:
    mov rax, 0
    jmp .fin

.devuelvoARREGLO:
    mov rax, r15

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