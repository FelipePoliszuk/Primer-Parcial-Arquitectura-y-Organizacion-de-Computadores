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
ATTACKUNIT_COMBUSTIBLE EQU  12
ATTACKUNIT_REFERENCES EQU  14
ATTACKUNIT_SIZE EQU  16

global optimizar
optimizar:
; registros:
	; rdi =  mapa
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

    mov rdi, r13        ; rdi = *compartida
    call r14   

    mov r15d, eax       ; r15 = compartida_hash

    xor rbx, rbx        ; rbx = índice = 0

.loop:
    cmp rbx, 255*255          ; condición de corte
    je .fin

    cmp qword[r12 + (rbx*8)], 0     ; if (mapa[i][j])
    je .siguiente

    cmp r13, qword[r12 + (rbx*8)]   ; compartida != mapa[i][j]
    je .siguiente

    mov rdi, qword[r12 + (rbx*8)]   ; rdi = mapa[i][j]
    call r14                        ; fun_hash(mapa[i][j])

    cmp r15d, eax   ; compartida_hash == fun_hash(mapa[i][j])
    jne .siguiente    

    mov r8, qword[r12 + (rbx*8)]             ; r8 = mapa[i][j]
    dec byte[r8 + ATTACKUNIT_REFERENCES]     ; mapa[i][j]->references --;

    cmp byte[r8 + ATTACKUNIT_REFERENCES], 0      ; (mapa[i][j]->references == 0)
    jne .actualizo

    mov rdi, qword[r12 + (rbx*8)]   ; rdi = mapa[i][j]
    call free                       ; free(mapa[i][j]);

    .actualizo:
    mov qword[r12 + (rbx*8)], r13           ; mapa[i][j] = compartida; 
    inc byte[r13 + ATTACKUNIT_REFERENCES]   ; compartida->references ++;

.siguiente:
    inc rbx
    jmp .loop

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


global contarCombustibleAsignado
contarCombustibleAsignado:
; registros:
	; rdi =  mapa
	; rsi = *fun_combustible
    
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
    mov r13, rsi        ; r13 = *fun_combustible

    xor r15, r15        ; r15d = combustible_total = 0 

    xor rbx, rbx        ; rbx = índice = 0

.loop:
    cmp rbx, 255*255          ; condición de corte
    je .fin

    cmp qword[r12 + (rbx*8)], 0     ; if (mapa[i][j])
    je .siguiente

    mov r8, qword[r12 + (rbx*8)]    ; r8 = mapa[i][j]

    movzx r9d, word[r8 + ATTACKUNIT_COMBUSTIBLE]    

    add r15d, r9d    ; mapa[i][j]->combustible 

    lea rdi, [r8 + ATTACKUNIT_CLASE]        ; rdi = mapa[i][j]->clase
    
    call r13
    movzx eax, ax

    sub r15d, eax

.siguiente:
    inc rbx
    jmp .loop

.fin:
    mov eax, r15d       ; eax = combustible_total

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


global modificarUnidad
modificarUnidad:
 ; registros:
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
    sub rsp, 8           ; Alineamiento GLOBAL (La pila ya es segura para toda la función)
    
    mov r12,  rdi        ; r12 = mapa
    mov r15,  rcx        ; r15 = *fun_modificar

    ; Calcular índice lineal: (x * 255) + y

    movzx r8, sil      ; r8 = x
    movzx r9, dl       ; r9 = y

    imul rbx, r8, 255  ; (x * 255)

    add rbx, r9        ; + y

    mov r13, qword[r12 + (rbx*8)]   ; r13 = mapa[x][y]
   
    test r13, r13
    jz .fin

    cmp byte[r13 + ATTACKUNIT_REFERENCES], 1
    jbe .else
    
    mov rdi, ATTACKUNIT_SIZE
    call malloc

    mov r14, rax        ; r14 = *nueva_unidad

    lea rdi, [r14 + ATTACKUNIT_CLASE]    ; rdi = nueva_unidad->clase
    lea rsi, [r13 + ATTACKUNIT_CLASE]    ; rsi = mapa[x][y]->clase

    call strcpy     ; strcpy(nueva_unidad->clase, mapa[x][y]->clase)

    mov r8w, word[r13 + ATTACKUNIT_COMBUSTIBLE]          ; r8w = mapa[x][y]->combustible
    mov word[r14 + ATTACKUNIT_COMBUSTIBLE], r8w          ; nueva_unidad->combustible = mapa[x][y]->combustible;

    mov byte[r14 + ATTACKUNIT_REFERENCES], 1        ; nueva_unidad->references = 1;
    dec byte[r13 + ATTACKUNIT_REFERENCES]           ; mapa[x][y]->references --;

    mov rdi, r14        ; rdi = nueva_unidad
    call r15            ; fun_modificar(nueva_unidad);

    mov qword[r12 + (rbx*8)], r14   ; mapa[x][y] = nueva_unidad;

    jmp .fin

.else:
    mov rdi, qword[r12 + (rbx*8)]       ; rdi = mapa[x][y]
    call r15                            ; fun_modificar(mapa[x][y]);

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