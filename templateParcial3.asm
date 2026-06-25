
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

    ; -------------------
    ; Código de inicialización
    ; -------------------

    xor rbx, rbx        ; índice
    xor r12, r12        ; acumulador

.loop:
    cmp rbx, N          ; condición de corte
    je .fin

    ; -------------------
    ; Ejemplo de call
    ; -------------------

    call r14            ; llamada a función

    ; -------------------
    ; Código dentro del loop
    ; -------------------

.siguiente:
    inc rbx
    jmp .loop

.fin:
    ; valor de retorno
    mov rax, r12       

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
