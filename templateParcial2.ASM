global mi_funcion_ejemplo
mi_funcion_ejemplo:

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; PRESERVACIÓN DE CALLEE-SAVED
    ; (Solo pushear los que realmente vayas a modificar en tu función)
    push rbx    ; <--- AGREGADO: RBX también es callee-saved
    push r12
    push r13
    push r14
    push r15

    ; -------------------
    ; Código de inicialización
    ; -------------------
    xor r12, r12        ; índice
    xor r13, r13        ; acumulador

.loop:
    cmp r12, 10         ; condición de corte (ejemplo)
    je .fin

    ; ==========================================================
    ; BLOQUE: CALL CON PRESERVACIÓN MÚLTIPLE
    ; ==========================================================
    
    ; 1. Guardar registros VOLÁTILES que estés usando y no quieras perder.
    ;    (Supongamos que estás usando r8, r9, r10 y r11 para cuentas).
    ;    OJO: El orden de POP debe ser inverso al de PUSH.
    
    push r8
    push r9
    push r10
    push r11  
    
    ; 2. Chequeo de Alineación (MATEMÁTICA DEL STACK):
    ;    Hicimos 4 pushes. 4 * 8 bytes = 32 bytes.
    ;    32 es múltiplo de 16. ¡ESTAMOS ALINEADOS!
    ;    -> NO hace falta 'sub rsp, 8'.
    ;
    ;    NOTA: Si hubieras pusheado 3 registros (24 bytes), 
    ;    faltarían 8 bytes para llegar a 32. Ahí sí iría 'sub rsp, 8'.

    ; 3. Preparar argumentos para la función a llamar
    mov rdi, r12       ; Primer argumento
    mov rsi, r13       ; Segundo argumento

    ; 4. Llamar
    call funcion_externa

    ; 5. Recuperar registros (EN ORDEN INVERSO)
    ;    Si hubieras hecho 'sub rsp, 8', aquí harías 'add rsp, 8' primero.
    
    pop r11
    pop r10
    pop r9
    pop r8
    
    ; ==========================================================

    ; Usar el resultado (rax) si hace falta...
    add r13, rax       ; Acumular resultado

.siguiente:
    inc r12
    jmp .loop

.fin:
    ; Valor de retorno
    mov rax, r13

    ; === EPÍLOGO ===
    ; Recuperar en orden inverso al prólogo
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx     ; <--- No te olvides de popear RBX
    pop rbp
    ret
