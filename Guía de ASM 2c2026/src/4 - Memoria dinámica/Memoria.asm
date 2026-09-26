extern malloc
extern free
extern fprintf

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
formato_string: db "%s", 0
string_nulo: db "NULL", 0

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; uint32_t strLen(char* a)
strLen:
; registros:
    ; rdi = *a
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    xor eax, eax                ; eax = contador = 0

.loop:
    cmp byte[rdi + rax], 0      ; condición de corte ('\0')
    je .fin

    inc eax
    jmp .loop

.fin:
    ; === EPÍLOGO ===
    pop rbp
    ret


; int32_t strCmp(char* a, char* b)
strCmp:
; registros:
    ; rdi = *a
    ; rsi = *b
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    xor rcx, rcx                ; rcx = índice = 0

.loop:
    mov r8b, byte[rdi + rcx]    ; r8b = a[i]
    mov r9b, byte[rsi + rcx]    ; r9b = b[i]

    cmp r8b, r9b
    jb .menor                   ; Si a < b (sin signo), salto a menor
    ja .mayor                   ; Si a > b (sin signo), salto a mayor

    test r8b, r8b               ; Si llegué a '\0' y no saltó, son idénticas
    jz .iguales

    inc rcx
    jmp .loop

.menor:
    mov eax, 1                  ; La cátedra pide 1 cuando a < b
    jmp .fin

.mayor:
    mov eax, -1                 ; La cátedra pide -1 cuando a > b
    jmp .fin

.iguales:
    xor eax, eax                ; Devuelvo 0 si son iguales

.fin:
    ; === EPÍLOGO ===
    pop rbp
    ret


; char* strClone(char* a)
strClone:
; registros:
    ; rdi = *a
    
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

    mov r12, rdi        ; r12 = *a

    call strLen         ; rdi ya tiene *a
    mov r13d, eax       ; r13d = longitud original

    mov edi, r13d
    inc edi             ; edi = longitud + 1 (para incluir el '\0')
    call malloc
    mov rbx, rax        ; rbx = *nuevo_string

    xor rcx, rcx        ; rcx = índice = 0

.loop:
    cmp ecx, r13d       ; iteramos hasta longitud *inclusive* para copiar el '\0'
    jg .fin

    mov r8b, byte[r12 + rcx]    ; leo de original
    mov byte[rbx + rcx], r8b    ; escribo en copia

    inc rcx
    jmp .loop

.fin:
    mov rax, rbx        ; devuelvo el puntero clonado en rax

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


; void strDelete(char* a)
strDelete:
; registros:
    ; rdi = *a
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; rdi ya tiene el puntero al string, el setup está listo para llamar a free
    call free

    ; === EPÍLOGO ===
    pop rbp
    ret


; void strPrint(char* a, FILE* pFile)
strPrint:
; registros:
    ; rdi = *a
    ; rsi = *pFile
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp
    
    ; Solo necesito alinear la pila para llamar a fprintf de C
    ; Usamos sub rsp, 16 para mantener todo alineado (push rbp desalinea a 8)
    sub rsp, 16

    ; fprintf recibe:
    ; rdi = *pFile (actualmente lo tenemos en rsi)
    ; rsi = *formato (lo sacamos de rodata)
    ; rdx = *a (actualmente lo tenemos en rdi)

    mov rdx, rdi        ; rdx = *a
    mov rdi, rsi        ; rdi = *pFile

    test rdx, rdx       ; Chequeo de seguridad: ¿es NULL el string?
    jnz .imprimir

    mov rdx, string_nulo ; Si es NULL, imprimo "NULL"

.imprimir:
    mov rsi, formato_string
    call fprintf

    ; === EPÍLOGO ===
    add rsp, 16
    pop rbp
    ret