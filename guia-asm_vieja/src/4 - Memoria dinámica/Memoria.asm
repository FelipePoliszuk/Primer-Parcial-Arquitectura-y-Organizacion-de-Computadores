extern malloc
extern free
extern fprintf

section .data
fmt_str: db "%s", 0
null_str: db "NULL", 0

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
; a -> [RDI]
; b -> [RSI]
strCmp:
    push rbp
    mov rbp, rsp

.cmp_loop:
    mov al, [rdi]        ; char a
    mov dl, [rsi]        ; char b (usamos DL, parte de RDX, volátil)

    cmp al, dl
    jne .diff

    test al, al
    jz .equal

    inc rdi
    inc rsi
    jmp .cmp_loop

.diff:
    ; comparación
    jb .less_than        ; a < b  -> return 1
    ja .greater_than     ; a > b  -> return -1

.equal:
    xor eax, eax         ; return 0
    jmp .done

.less_than:
    mov eax, 1
    jmp .done

.greater_than:
    mov eax, -1
    jmp .done

.done:
; epílogo
    pop rbp
    ret


; char* strClone(char* a)
; a -> [RDI]
strClone:
    push rbp
    mov rbp, rsp
    push r12           ; callee-saved, lo vamos a usar para la cadena original
    sub rsp, 8         ; alinear pila a 16 bytes antes de llamar

    mov r12, rdi       ; r12 = puntero a cadena original

    ; calcular longitud
    mov rdi, r12
    call strLen        ; rax = longitud de la cadena
    inc rax            ; +1 para '\0'

    ; reservar memoria
    mov rdi, rax       ; argumento para malloc
    call malloc        ; rax = puntero a memoria nueva
    ; test rax, rax
    ; jz .fail           ; malloc falló
    mov r8, rax        ; guardamos el inicio de la copia en r8

    ; copiar caracterescopy
.copy_loop:
    mov dl, [r12]      ; cargar carácter original
    mov [rax], dl      ; guardar en la copia
    test dl, dl
    jz .done           ; si es '\0', fin
    inc r12
    inc rax
    jmp .copy_loop

.done:
    mov rax, r8        ; devolver puntero al inicio del clon
    add rsp, 8
    pop r12
    pop rbp
    ret

; .fail:
;     xor rax, rax       ; devolver NULL si malloc falla
;     add rsp, 8
;     pop r12
;     pop rbp
;     ret


; void strDelete(char* a)
; a -> [RDI]
strDelete:
    sub rsp, 8         ; alinear pila antes de llamar
    call free
    add rsp, 8
    ret


; void strPrint(char* a, FILE* pFile)
; a -> [RDI]
; pFile -> [RSI]
strPrint:
    push rbp
    mov rbp, rsp

    mov rax, rdi
    mov rdi, rsi
    lea rsi, [rel fmt_str]
    mov rdx, rax

    call fprintf

    pop rbp
	
    ret



; uint32_t strLen(char* a)
; a -> [RDI]
strLen:
; prólogo
	push rbp
	mov rbp, rsp

	xor r9, r9 				 ; r9 = 0 (contador = 0)

	.loop:
		mov al, byte [rdi]   ; cargar *a en AL
		test al, al          ; comparar AL con 0
		jz .fin              ; si es 0 -> fin

		inc r9               ; cantidad++  equivalente a add r9, 1

		inc rdi              ; avanzar puntero
		jmp .loop            ; repetir


	.fin:
    mov eax, r9d             ; pasar resultado a eax (return)

; epílogo
	pop rbp
	ret