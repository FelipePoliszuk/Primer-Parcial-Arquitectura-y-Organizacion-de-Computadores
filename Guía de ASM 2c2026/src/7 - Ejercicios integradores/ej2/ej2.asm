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

global optimizar
optimizar:
; registros:
	; rdi = *mapa
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

	mov r12, rdi		; r12 = *mapa
	mov r13, rsi		; r13 = *compartida
	mov r14, rdx		; r14 = *fun_hash
	 
	mov rdi, r13		; rdi = compartida
	call r14			; llamo a fun_hash
	
	xor r15, r15
	mov r15d, eax		; r15 = hash_compartida
	
	xor rbx, rbx        ; rbx = índice = 0

.loop:
    cmp rbx, 255*255          			; condición de corte
    je .fin

	mov r8, qword[r12 + (rbx*8)]       	; r8 = mapa[i][j]

	test r8, r8 
	jz .siguiente

	cmp r13, r8
	je .siguiente	

	mov rdi, r8							; rdi = mapa[i][j]
	call r14							; llamo a fun_hash

	cmp r15d, eax
	jne .siguiente

	mov r8, qword[r12 + (rbx*8)]       			; r8 = mapa[i][j]
	dec byte[r8 + ATTACKUNIT_REFERENCES]		; mapa[i][j]->references --;

	cmp byte[r8 + ATTACKUNIT_REFERENCES], 0
	jne .sigo

.free:
	mov rdi, qword[r12 + (rbx*8)]				; rdi = mapa[i][j]
	call free

.sigo: 
	mov qword[r12 + (rbx*8)], r13
	inc byte[r13 + ATTACKUNIT_REFERENCES]

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
	; rdi = *mapa
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

	mov r12, rdi		; r12 = *mapa
	mov r13, rsi		; r13 = *fun_combustible
	 
	xor r15, r15		; r15d = combustible = 0  
	xor rbx, rbx        ; rbx = índice = 0

.loop:
    cmp rbx, 255*255          			; condición de corte
    je .fin

	mov r8, qword[r12 + (rbx*8)]       	; r8 = mapa[i][j]

	test r8, r8 
	jz .siguiente

	movzx edi, word[r8 + ATTACKUNIT_COMBUSTIBLE]

	add r15d, edi

	lea rdi, qword[r8 + ATTACKUNIT_CLASE]			; rdi = mapa[i][j]->clase
	call r13
	
	movzx eax, ax
	sub r15d, eax

.siguiente:
    inc rbx
    jmp .loop

.fin:
	mov eax, r15d		; devuelvo combusitble enn eax

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
	; rdi 	= *mapa_t
	; sil 	=  x
	; dl 	=  y
	; rcx 	= *fun_modificar
    
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

    mov r12, rdi        ; r12 = *mapa_t

    mov r15, rcx        ; r15 = *fun_modificar

    ; Extender los parámetros de 8 bits a 64 bits llenando con ceros
    movzx rsi, sil      ; rsi = x limpio
    movzx rdx, dl       ; rdx = y limpio

    ; Calcular índice lineal: (x * 255) + y
    imul rsi, 255       ; rsi = x * 255
    add rsi, rdx        ; rsi = (x * 255) + y
    
    mov r14, rsi        ; r14 = indice

	mov r13, qword[r12 + (r14*8)]           	; r13 = mapa[x][y]

	test r13, r13 
	jz .fin
	
    cmp byte[r13 + ATTACKUNIT_REFERENCES], 1
    jng .else

    dec byte[r13 + ATTACKUNIT_REFERENCES]       ; mapa[x][y]->references --;

    mov rdi, ATTACKUNIT_SIZE
    call malloc
    mov rbx, rax                                    ; rbx = nueva_instancia

    lea rdi, [rbx + ATTACKUNIT_CLASE]               ; rdi = nueva_instancia->clase
    lea rsi, [r13 + ATTACKUNIT_CLASE]               ; rsi = mapa[x][y]->clase
    call strcpy                             

    mov r8w, word[r13 + ATTACKUNIT_COMBUSTIBLE]
    mov word[rbx + ATTACKUNIT_COMBUSTIBLE], r8w        ; nueva_instancia->combustible = mapa[x][y]->combustible;

    mov byte[rbx + ATTACKUNIT_REFERENCES], 1           ;  nueva_instancia->references = 1;
        
    mov rdi, rbx                              ; rdi = nueva_instancia
    call r15                                  ; fun_modificar(nueva_instancia);

    mov qword[r12 + (r14*8)], rbx             ; mapa[x][y] = nueva_instancia;

    jmp .fin
	
.else:
    mov rdi, r13                         ; paso mapa[x][y] a rdi
    call r15                             ; fun_modificar(mapa[x][y]);

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