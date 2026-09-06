extern strcpy
extern malloc
extern free

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

ITEM_OFFSET_NOMBRE EQU 0
ITEM_OFFSET_ID EQU 12
ITEM_OFFSET_CANTIDAD EQU 16

POINTER_SIZE EQU 8
UINT32_SIZE EQU 4

; Marcar el ejercicio como hecho (`true`) o pendiente (`false`).

global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_4_HECHO
EJERCICIO_4_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.


; uint64_t ejercicio1(uint64_t sum1, uint64_t sum2, uint64_t sum3, uint64_t sum4, uint64_t sum5);
global ejercicio1
ejercicio1:

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp	

	add rdi, rsi
	add rdi, rdx
    add rdi, rcx
    add rdi, r8

	mov rax, rdi			; devuelvo en rax
	
	; === EPÍLOGO ===
	pop rbp
	ret	


	; add edi, ecx
	; add edi, edx
    ; add edi, ebx
    ; add edi, r9d

	; mov eax, edi

	; ret

; void ejercicio2(item_t* un_item, uint32_t id, uint32_t cantidad, char nombre[]);
global ejercicio2
ejercicio2:
; rdi = *un_item
; esi = id
; edx = cantidad
; rcx = nombre[]

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp
	
	mov dword[rdi + ITEM_OFFSET_ID], esi
	mov dword[rdi + ITEM_OFFSET_CANTIDAD], edx

	lea rdi, [rdi + ITEM_OFFSET_NOMBRE]		; rdi = un_item->nombre[9];
	mov rsi, rcx							; rsi = nombre[];
	call strcpy 

	; === EPÍLOGO ===
	pop rbp
	ret

	; mov [rdi+ITEM_OFFSET_ID], rsi
	; mov [rdi+ITEM_OFFSET_CANTIDAD], rdx
	; call strcpy 
	; ret	

; ; 				SOLUCIÓN RECURSIVA

; ; uint32_t ejercicio3(uint32_t* array, uint32_t size, uint32_t (*fun_ej_3)(uint32_t a, uint32_t b));
; global ejercicio3
; ejercicio3:
; ; rdi = *array
; ; esi = size
; ; rdx = *fun_ej_3

;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp	

; 	push rbx
; 	push r12
; 	push r13
; 	push r14

; 	xor rbx, rbx	

; 	mov r12, rdi 			; r12 = *array
; 	mov r13d, esi 			; r13d = size
; 	mov r14, rdx 			; r14 = *fun_ej_3
	
; 	test r13d, r13d			
; 	jz .tamaño0				; si n = 0
	
; 	cmp r13d, 1			
; 	je .tamaño1				; si n = 1

; 	; n > 1
; 	mov rdi, r12			; rdi = *array
; 	mov esi, r13d			; esi = size
; 	dec esi					; size - 1	
; 	mov rdx, r14			; r14 = *fun_ej_3

; 	call ejercicio3

; 	add ebx, eax

; 	mov edi, eax			; edi = ej3(arr, n-1, fun) 
	
; 	xor r8, r8
; 	mov r8d, r13d
; 	dec r8d

; 	mov esi, dword[r12 + (r8*4)]		; esi = arr[0] 

; 	call r14

; 	add ebx, eax						; acumulado 
; 	mov eax, ebx
; 	jmp .fin

; .tamaño1:
; 	mov edi, 0			; xor rdi, rdi
; 	mov esi, dword[r12]		; esi = arr[0]
; 	call r14

; 	jmp .fin

; .tamaño0:
; 	mov eax, 64

; .fin:
; 	; === EPÍLOGO ===
; 	pop r14
; 	pop r13
; 	pop r12
; 	pop rbx
	
; 	pop rbp
; 	ret



; 				SOLUCIÓN ITERATIVA

; uint32_t ejercicio3(uint32_t* array, uint32_t size, uint32_t (*fun_ej_3)(uint32_t a, uint32_t b));
global ejercicio3
ejercicio3:
; rdi = *array
; esi = size
; rdx = *fun_ej_3

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp	

	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	xor rbx, rbx	

	mov r12, rdi 			; r12 = *array
	mov r13d, esi 			; r13d = size
	mov r14, rdx 			; r14 = *fun_ej_3
	
	test r13d, r13d			
	jz .tamaño0				; si n = 0
	
	cmp r13d, 1			
	je .tamaño1				; si n = 1

	; n > 1

	xor rbx, rbx 			; ebx = resultado parcial = 0
	xor r15, r15 			; r15d = indice = 0  

.loop:
	mov rdi, rbx
	mov esi, dword[r12 + (r15*4)]

	call r14

	add ebx, eax
	mov eax, ebx

	inc r15
	cmp r15d, r13d
	je .fin

	jmp .loop

.tamaño1:
	mov edi, 0					; xor rdi, rdi
	mov esi, dword[r12]			; esi = arr[0]
	call r14

	jmp .fin

.tamaño0:
	mov eax, 64

.fin:
	; === EPÍLOGO ===
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	
	pop rbp
	ret



; 	cmp rsi, 0
; 	je .vacio
	
; 	mov rcx, rdi ; array
; 	mov r8, 0 ; resultado parcial
; 	mov r9, 0 ; i

; 	.loop:
; 	mov rdi, r8
; 	mov rsi, [rcx + r9*4]

; 	call rdx

; 	add r8, rax
; 	mov rax, r8

; 	inc r9
; 	cmp r9, rsi
; 	je .end

; 	jmp .loop

; 	.vacio:
; 	mov rax, 64

; 	.end:
; 	ret


; uint32_t* ejercicio4(uint32_t** array, uint32_t size, uint32_t constante);
global ejercicio4
ejercicio4:
; registros:
; rdi = *array
; esi =  size
; edx =  constante

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

	mov r12, rdi		; r12  = *array
	mov r13d, esi		; r13d =  size
	mov r14d, edx		; r14  =  constante

	mov eax, UINT32_SIZE
	mul r13d
	mov edi, eax

	call malloc
	mov r15, rax			; r15 = *res_arr
	
	xor rbx, rbx			; ebx =  indice = 0

.loop:
	cmp ebx, r13d
	je .fin

	mov r8, qword[r12 + (rbx*POINTER_SIZE)]		; r8 = *arr[i]
	mov r9d, dword[r8]							; r9d = arr[i]

	mov eax, r14d
	mul r9d

	mov dword[r15 + (rbx*UINT32_SIZE)], eax

	mov rdi, r8
	mov qword[r12 + (rbx*POINTER_SIZE)], 0

	call free
	
.siguiente:
    inc rbx
    jmp .loop

.fin:

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