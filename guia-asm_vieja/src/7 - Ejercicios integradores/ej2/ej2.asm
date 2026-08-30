extern malloc
extern free
extern strcpy

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - optimizar
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ATTACKUNIT_CLASE EQU 0
ATTACKUNIT_COMBUSTIBLE EQU 12
ATTACKUNIT_REFERENCES EQU 14
ATTACKUNIT_SIZE EQU 16


; void optimizar(mapa_t mapa, attackunit_t* compartida, uint32_t (*fun_hash)(attackunit_t*));
global optimizar
optimizar:
; Registros:
    ; rdi = mapa
    ; rsi = *compartida
    ; rdx = *fun_hash

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

    mov r12, rdi        ; r12 = mapa
    mov r13, rsi        ; r13 = *compartida
    mov r14, rdx        ; r14 = *fun_hash

    xor rbx, rbx        ; rbx = índice = 0

    mov rdi, r13             ; le paso *compartida
    call r14                ; llamo a fun_hash
    mov r15d, eax            ; guardo en r15 el valor del hash de compartida
    
.loop:
    cmp rbx, 65025          ; condición de corte    (255*255 = 65025)
    je .fin

    mov r8, [r12 + (rbx*8)]       ;  mapa[i][j]

    test r8, r8
    jz .siguiente

    cmp r8, r13
    je .siguiente

    mov rdi, r8             ; le paso mapa[i][j]
    call r14                ; llamo a fun_hash

    cmp eax, r15d
    jne .siguiente    
 
    mov r8, [r12 + (rbx*8)]       ;  mapa[i][j]

    mov r9, r8               ; *a_borrar = mapa[i][j];

    dec byte[r9 + ATTACKUNIT_REFERENCES]        ; a_borrar->references--;

    cmp byte[r9 + ATTACKUNIT_REFERENCES], 0
    je .free

.no_free:

    inc byte[r13 + ATTACKUNIT_REFERENCES]   ; compartida->references ++;

    mov qword[r12 + (rbx*8)], r13       ; mapa[i][j] = compartida;

.siguiente:
    inc rbx
    jmp .loop

.free:
    mov rdi, r9
    call free
    jmp .no_free

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


; uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char *))
global contarCombustibleAsignado
contarCombustibleAsignado:
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    push rbx   
    push r12
    push r13
    push r14
    push r15
    
    sub rsp, 8          ; Alineamiento GLOBAL

    mov r12, rdi        ; r12 = mapa
    mov r13, rsi        ; r13 = *fun_combustible

    xor r14, r14        ; r14d = combustible_total = 0
    xor rbx, rbx        ; rbx = índice = 0
    
.loop:
    cmp rbx, 65025      
    je .fin

    mov r8, qword[r12 + (rbx*8)]    ; r8 = mapa[i][j]

    test r8, r8
    jz .siguiente

    ; Sumamos extendiendo a 32 bits para evitar overflow
    movzx r9d, word[r8 + ATTACKUNIT_COMBUSTIBLE]
    add r14d, r9d     

    lea rdi, [r8 + ATTACKUNIT_CLASE]  
    call r13

    ; Restamos extendiendo el valor de retorno a 32 bits
    movzx eax, ax
    sub r14d, eax

.siguiente:
    inc rbx
    jmp .loop

.fin: 
    mov eax, r14d       ; Retornamos el total de 32 bits
    
    ; === EPÍLOGO ===
    add rsp, 8          
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


; void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t *))
global modificarUnidad
modificarUnidad:
; Registros:
    ; rdi = mapa
    ; sil = x
    ; dl = y
    ; rcx = *fun_modificar

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

    mov r12, rdi        ; r12 = mapa

    mov r15, rcx        ; r15 = *fun_modificar

    ; Extender los parámetros de 8 bits a 64 bits llenando con ceros
    movzx rsi, sil      ; rsi = x limpio
    movzx rdx, dl       ; rdx = y limpio

    ; Calcular índice lineal: (x * 255) + y
    imul rsi, 255       ; rsi = x * 255
    add rsi, rdx        ; rsi = (x * 255) + y
    
    mov r14, rsi
    ; lea r9, [r12 + rsi*8]     ; // FORMA ALTERNATIVA USANDO LEA
    mov rbx, qword[r12 + (rsi*8)]              ; rbx = mapa[x][y]

    test rbx, rbx
    jz .fin

    cmp byte[rbx + ATTACKUNIT_REFERENCES], 1
    jna .modifico_original


    mov rdi, ATTACKUNIT_SIZE
    call malloc

    mov r13, rax        ; r13 = *nueva

    dec byte[rbx + ATTACKUNIT_REFERENCES]       ;  mapa[x][y]->references -= 1;

    lea rdi, [r13 + ATTACKUNIT_CLASE]       ; rdi = nueva->clase
    lea rsi, [rbx + ATTACKUNIT_CLASE]       ; rsi = mapa[x][y]->clase)

    call strcpy

    mov r8w, word[rbx + ATTACKUNIT_COMBUSTIBLE] 
    mov word[r13 + ATTACKUNIT_COMBUSTIBLE], r8w      ; nueva->combustible = mapa[x][y]->combustible;

    mov byte[r13 + ATTACKUNIT_REFERENCES], 1       ; nueva->references = 1;

    mov rdi, r13
    call r15                                      ; fun_modificar(nueva);

    mov qword[r12 + (r14*8)], r13               ; mapa[x][y] = nueva;

    ; mov qword[r9], r13                        ; // FORMA ALTERNATIVA USANDO LEA

    jmp .fin

.modifico_original:
    mov rdi, rbx
    call r15

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