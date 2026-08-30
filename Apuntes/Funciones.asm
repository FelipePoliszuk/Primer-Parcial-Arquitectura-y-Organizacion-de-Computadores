; ===================================================================
; FUNCIONES UTILITARIAS EN ASM x86-64
; Para examen: malloc, calloc, free, strcpy, strcmp, strlen, memcpy, memset, puts, atoi, exit
; ===================================================================

; ================================================================
; malloc simple (usa syscall mmap)
; argumentos: RDI = size
; retorna: RAX = puntero
; ================================================================
global mi_malloc


mi_malloc:
    mov rsi, rdi    ; length = size (mantener size y pasarlo a rsi)
    xor rdi, rdi    ; addr = NULL
    mov rdx, 3      ; PROT_READ | PROT_WRITE
    mov r10, 0x22   ; MAP_ANONYMOUS | MAP_PRIVATE
    mov r8, -1      ; fd
    xor r9, r9      ; offset
    mov rax, 9      ; syscall: mmap
    syscall
    ret

; ================================================================
; calloc simple: malloc + zero
; argumentos: RDI = nmemb, RSI = size
; retorna: RAX = puntero
; ================================================================
global mi_calloc
mi_calloc:
    mov rax, rdi
    imul rax, rsi       ; total size = nmemb*size
    mov rdi, rax        ; tamaño total (arg para mi_malloc)
    mov rdx, rax        ; guardar tamaño total (caller-saved)
    call mi_malloc
    test rax, rax
    jz .fin
    mov rdi, rax        ; puntero destino
    mov rcx, rdx        ; restaurar tamaño para stosb
    xor rax, rax        ; valor 0 en AL para stosb
    rep stosb           ; llena RCX bytes con AL en [RDI]
.fin:
    ret

; ================================================================
; free simple: munmap (tamaño fijo)
; argumentos: RDI = ptr
; ================================================================
global mi_free
mi_free:
    mov rax, 11         ; syscall munmap
    ; rdi = ptr, rsi = size
    syscall
    ret

; ================================================================
; strcpy
; argumentos: RDI = dest, RSI = src
; ================================================================
global strcpy
strcpy:
.copy_loop:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    test al, al
    jnz .copy_loop
    ret

; ================================================================
; strcmp
; argumentos: RDI = str1, RSI = str2
; retorno: RAX
; ================================================================
global strcmp
strcmp:
.loop:
    mov al, [rdi]
    mov bl, [rsi]
    cmp al, bl
    jne .diff
    test al, al
    je .eq
    inc rdi
    inc rsi
    jmp .loop
.diff:
    movzx eax, al
    movzx ebx, bl
    sub eax, ebx
    ret
.eq:
    xor eax, eax
    ret

; ================================================================
; strlen
; argumentos: RDI = str
; retorno: RAX = length
; ================================================================
global strlen
strlen:
    xor rax, rax
.loop_len:
    cmp byte [rdi + rax], 0
    je .fin_len
    inc rax
    jmp .loop_len
.fin_len:
    ret

; ================================================================
; memcpy
; argumentos: RDI = dest, RSI = src, RDX = size
; ================================================================
global memcpy
memcpy:
    test rdx, rdx
    jz .fin_mem
.loop_mem:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec rdx
    jnz .loop_mem
.fin_mem:
    ret

; ================================================================
; memset
; argumentos: RDI = ptr, AL = value, RCX = size
; ================================================================
global memset
memset:
    mov rax, rdi        ; devolver ptr
    test rdx, rdx       ; size == 0?
    jz .fin_set
    mov cl, sil         ; byte valor desde RSI
.loop_set:
    mov [rdi], cl
    inc rdi
    dec rdx
    jnz .loop_set
.fin_set:
    ret

; ================================================================
; puts (stdout = fd 1)
; argumentos: RDI = puntero string
; ================================================================
global puts
puts:
    mov rsi, rdi        ; guardar puntero en RSI
    mov rdi, rsi        ; strlen(arg)
    call strlen
    mov rdx, rax        ; len
    mov rax, 1          ; write
    mov rdi, 1          ; fd = stdout
    ; rsi = ptr
    syscall
    ; newline
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel newline]
    mov rdx, 1
    syscall
    ret

section .data
newline db 10

; ================================================================
; atoi
; argumentos: RDI = string
; retorno: RAX = integer
; ================================================================
global atoi
atoi:
    xor rax, rax
    xor rcx, rcx
.parse_loop:
    mov dl, [rdi + rcx]
    test dl, dl
    je .done
    sub dl, '0'
    imul rax, rax, 10
    movzx rdx, dl
    add rax, rdx
    inc rcx
    jmp .parse_loop
.done:
    ret

; ================================================================
; exit
; argumentos: RDI = exit code
; ================================================================
global exit
exit:
    mov rax, 60       ; syscall exit
    syscall
