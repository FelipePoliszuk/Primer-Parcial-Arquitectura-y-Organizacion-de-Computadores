extern malloc

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4
; ; -------------------------
USUARIO_SIZE EQU 8


PRODUCTO_USUARIO_OFFSET EQU 0        
PRODUCTO_CATEGORIA_OFFSET EQU 8
PRODUCTO_NOMBRE_OFFSET EQU 17       
PRODUCTO_ESTADO_OFFSET EQU 42       
PRODUCTO_PRECIO_OFFSET EQU 44      
PRODUCTO_ID_OFFSET EQU 48          
; ; -------------------------
PRODUCTO_SIZE EQU 56              


PUBLICACION_NEXT_OFFSET EQU 0
PUBLICACION_VALUE_OFFSET EQU 8
; ; -------------------------
PUBLICACION_SIZE EQU 16


CATALOGO_FIRST_OFFSET EQU 0
; ; -------------------------
CATALOGO_SIZE EQU 8


;producto_t* filtrarPublicacionesNuevasDeUsuariosVerificados (catalogo* h)
global filtrarPublicacionesNuevasDeUsuariosVerificados
filtrarPublicacionesNuevasDeUsuariosVerificados:
; registros:
	; rdi = *h
    
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
    
    mov r12, rdi        ; r12 = *h

    call cantidadDeProductos

    ; inc eax

    ; imul eax, 8

    ; mov edi, eax

    lea rdi, [(rax*8) + 8]

    call malloc

    mov r15, rax        ; r15 = **arreglo

    mov rbx, qword[r12 + CATALOGO_FIRST_OFFSET]        ; rbx = *actual

    xor r13, r13        ; r13 = j = 0

.loop:
    cmp rbx, 0          ; condición de corte
    je .fin

    mov r14, qword[rbx + PUBLICACION_VALUE_OFFSET]  ; r14 =  *producto

    mov rdi, r14

    call cumpleCondiciones

    test al, al
    jnz .agregoAlArreglo

.siguiente:
    mov rbx, qword[rbx + PUBLICACION_NEXT_OFFSET]       ; actual = actual->next;
    jmp .loop

.agregoAlArreglo:
    mov qword[r15 + (r13*8)], r14        ; arreglo[j] = producto;
    inc r13                              ; j++;

    jmp .siguiente

.fin:

    mov qword[r15 + (r13*8)], 0  ; arreglo[j] = NULL;
    mov rax, r15            ; return arreglo;

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
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
; registros:
	; rdi = *h
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r15
    sub rsp, 8          ; Alineamiento GLOBAL (La pila ya es segura para toda la función)
    
    mov r12, rdi        ; r12 = *h

    xor r15, r15        ; r15d = tamaño

    mov rbx, qword[r12 + CATALOGO_FIRST_OFFSET]     ; rbx = *actual

.loop:
    cmp rbx, 0          ; condición de corte
    je .fin

    mov rdi, qword[rbx + PUBLICACION_VALUE_OFFSET]       ; rdi =  actual->value;

    call cumpleCondiciones      ; cumpleCondiciones(producto)

    test al, al
    jnz .sumoUno

.siguiente:
    mov rbx, qword[rbx + PUBLICACION_NEXT_OFFSET]        ; actual = actual->next;
    jmp .loop

.sumoUno:
    inc r15     ; tamaño++;
    jmp .siguiente

.fin:
    mov eax, r15d       ; return tamaño;

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r12
    pop rbx
    pop rbp
    ret


; bool cumpleCondiciones(producto_t *producto)
global cumpleCondiciones
cumpleCondiciones:
; registros:
	; rdi = *producto
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    mov r8w, word[rdi + PRODUCTO_ESTADO_OFFSET]    ; r8w = producto->estado

    cmp r8w, 1
    jne .devuelvoFalse

    mov r8, qword[rdi + PRODUCTO_USUARIO_OFFSET]    ; producto->usuario
    mov r8b, byte[r8 + USUARIO_NIVEL_OFFSET]        ; r8b = producto->usuario->nivel

    cmp r8b, 1
    jge .devuelvoTrue

.devuelvoFalse:
    mov rax, 0      ; False
    jmp .fin

.devuelvoTrue:
    mov rax, 1      ; True    

.fin:
    ; === EPÍLOGO ===
    pop rbp
    ret
