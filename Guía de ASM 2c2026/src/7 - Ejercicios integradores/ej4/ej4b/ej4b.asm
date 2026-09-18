extern strcmp
global invocar_habilidad

; Completar las definiciones o borrarlas (en este ejercicio NO serán revisadas por el ABI enforcer)
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
; -------------------------------
DIRENTRY_SIZE EQU 24


FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
; -------------------------------
FANTASTRUCO_SIZE EQU 32

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text

; void invocar_habilidad(void* carta, char* habilidad);
invocar_habilidad:
; registros:
	; rdi = *carta
	; rsi = *habilidad

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    push r14
    
    mov r12, rdi		; r12 = *carta
    mov r13, rsi		; r13 = *habilidad

	mov r14w, word[r12 + FANTASTRUCO_ENTRIES_OFFSET]		; r14 = carta->__dir_entries

    xor rbx, rbx        ; bx = índice = 0

.loop:
    cmp bx, r14w          ; condición de corte
    je .chequear_arquetipo

	mov rdi, qword[r12 + FANTASTRUCO_DIR_OFFSET]		; carta->__dir
	mov rdi, qword[rdi + (rbx*8)]						; carta->__dir[i]

	lea rdi, [rdi + DIRENTRY_NAME_OFFSET]				; carta->__dir[i]->ability_name
	mov rsi, r13	; rsi = habilidad

	call strcmp

	test eax, eax
	jnz .siguiente

	mov r8, qword[r12 + FANTASTRUCO_DIR_OFFSET]		; carta->__dir
	mov r8, qword[r8 + (rbx*8)]						; carta->__dir[i]
	mov r8, qword[r8 + DIRENTRY_PTR_OFFSET] 	   	; carta->__dir[i]->ability_ptr

	mov rdi, r12			; rdi = *carta
	call r8					; llamo a funcion habilidad

.siguiente:
    inc bx
    jmp .loop

.chequear_arquetipo:
	mov r8, qword[r12 + FANTASTRUCO_ARCHETYPE_OFFSET]		; r8 = carta->__archetype
	test r8, r8
	jz .fin

	mov rdi, r8		; rdi = carta->__archetype
	mov rsi, r13	; rsi = habilidad

	call invocar_habilidad

.fin:
    ; === EPÍLOGO ===
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret