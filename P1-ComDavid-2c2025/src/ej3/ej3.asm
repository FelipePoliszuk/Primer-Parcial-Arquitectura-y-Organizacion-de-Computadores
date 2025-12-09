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

;usuario_t **asignarNivelesParaNuevosUsuarios(uint32_t *ids, uint32_t cantidadDeIds, uint8_t (*deQueNivelEs)(uint32_t)) {
global asignarNivelesParaNuevosUsuarios 
asignarNivelesParaNuevosUsuarios:
; registros
;   1. RDI = uint32_t *ids
;   2. RSI = uint32_t cantidadDeIds
;   3. RDX = uint8_t (*deQueNivelEs)(uint32_t)

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved si los vas a usar
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r13, rdi        ; r13 = ids
    mov r14d, esi        ; r14 = cantidadDeIds
    mov r15, rdx        ; r15 = deQueNivelEs

    xor r12, r12        ; r12 = 0 - indice

    ; xor r8, r8        
    ; xor r9, r9 
    ; xor r10, r10 
    ; xor r11, r11 


    cmp r14d, 0
    je .null



    imul rdi, r14, 8     
    ; push r8
     sub rsp, 8          ; mantener alineamiento 16 bytes
    call malloc
    ; pop r8
    add rsp, 8

    mov rbx, rax

.loop:
    cmp r12d, r14d          ; condición de corte
    je .returnArreglo


    mov r8d, [r13 + (r12*4)]           ; r8d = ids[i]

    push r8

    mov edi, r8d         ; pasar argumento
    call r15            ; llamada a función

    mov r9b, al

    pop r8


    push r8
    push r9
    sub rsp, 8

    mov rdi, USUARIO_SIZE         ; pasar argumento
    call malloc                     ; llamada a función

    mov r10, rax

    add rsp, 8
    pop r9
    pop r8

    mov [r10 + USUARIO_ID_OFFSET], r8d
    mov [r10 + USUARIO_NIVEL_OFFSET], r9b

    mov [rbx + (r12*8)], r10

.siguiente:
    inc r12d
    jmp .loop


.null:
    mov rax, 0
    jmp .fin

.returnArreglo:
    mov rax, rbx

.fin:
    ; === EPÍLOGO ===
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp    
    ret