
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved si los vas a usar
    push r12
    push r13
    push r14
    push r15

    ; -------------------
    ; Código de inicialización
    ; -------------------

    xor r12, r12        ; ejemplo de índice
    xor r13, r13        ; ejemplo de acumulador

.loop:
    cmp r12, N          ; condición de corte
    je .fin

    ; -------------------
    ; Ejemplo de call con preservación
    ; -------------------
    push r8             ; si necesitás guardar valores caller-saved
    sub rsp, 8          ; mantener alineamiento 16 bytes
    mov rdi, r8         ; pasar argumento
    call r14            ; llamada a función
    add rsp, 8
    pop r8

    ; -------------------
    ; Código dentro del loop
    ; -------------------

.siguiente:
    inc r12
    jmp .loop

.fin:
    ; valor de retorno
    mov eax, r13d       ; ejemplo, devolver acumulador en eax

    ; === EPÍLOGO ===
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
