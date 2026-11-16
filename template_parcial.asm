; registros:
	; rdi = 
	; rsi = 
	; rdx = 
	; rcx = 
	; r8 = 
	; r9 =    
    
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
    
    mov r12, rdi        ; r12 = 
    mov r13, rsi        ; r13 = 
    mov r14, rdx        ; r14 = 
    mov r15, rcx        ; r15 = 
    mov rbx, r8         ; rbx = 

    ; -------------------
    ; Código de inicialización
    ; -------------------

    xor rbx, rbx        ; rbx = índice = 0
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
    mov rax, r15       

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret