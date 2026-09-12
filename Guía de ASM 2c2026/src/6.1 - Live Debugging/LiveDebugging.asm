extern malloc
extern free
extern strdup

extern procesar_registros2
extern clonar_filtrados2

section .rodata
; Constantes y offsets declarados
REGISTRO_OFFSET_ID EQU 0
REGISTRO_OFFSET_DESCRIPCION EQU 8
REGISTRO_SIZE EQU 16

section .text
FALSE EQU 0
TRUE  EQU 1

global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests del Ejercicio 1.

global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests del Ejercicio 2.

; ==============================================================================
; EJERCICIO 1: procesar_registros
; uint64_t procesar_registros(registro_t* array (rdi), uint32_t len (esi), int (*criterio)(uint32_t) (rdx))
; ==============================================================================
global procesar_registros
procesar_registros:
; registros:
	; rdi = *array
	; esi =  len
	; rdx = *criterio

; 	prólogo

	push rbp
	mov rbp, rsp

	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	mov r12,  rdi       ; Guardamos puntero al array en r12
	mov r13d, esi       ; Guardamos longitud len en r13d
	mov rbx,  rdx       ; Guardamos puntero a función criterio en rbx

	xor r15, r15          ; r15d = i = 0
	xor r14, r14          ; total_procesados = 0

	shl r13, 4			; lo mismo que imul r13, 16

.loop:
	cmp r15d, r13d
	je .fin		; jge

	mov edi, dword[r12 + r15 + REGISTRO_OFFSET_ID]		 	; edi = array[i].id

	call rbx           ; Invoca criterio(id)

	cmp eax, 1
	je .incrementar

.siguiente:
	add r15, 16
	jmp .loop

.incrementar:
	inc r14             ; Suma al total
	jmp .siguiente

.fin:
	mov rax, r14

; 	epílogo
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx

	pop rbp
	ret

; version llamando a c

    ; push rbp
    ; mov rbp, rsp

	; call procesar_registros2

	; pop rbp
	; ret

; ==============================================================================
; EJERCICIO 2: clonar_filtrados
; registro_t* clonar_filtrados(registro_t* array (rdi), uint32_t len (esi), int (*criterio)(uint32_t) (rdx), uint32_t* out_len (rcx))
; ==============================================================================
global clonar_filtrados
clonar_filtrados:
; ; registros:
; 	rdi = *array
; 	esi =  len
; 	rdx = *criterio
; 	rcx = *out_len

; prólogo
	push rbp
	mov rbp, rsp

	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	mov r12, rdi       ; r12  = *array original
	mov r13d, esi      ; r13d = len
	mov r14, rdx       ; r14  = *criterio
	mov r15, rcx       ; r15  = *out_len

	call procesar_registros
	mov dword[r15], eax

	test rax, rax 
	jz .devuelvoNULL

	; Reservamos memoria para el nuevo array en el Heap:
	mov edi, eax
	imul edi, REGISTRO_SIZE		   ; rdi * 16

	call malloc
	mov rbx, rax       ; rbx = *clonado

	xor rcx, rcx       ; ecx = índice i
	xor rdx, rdx       ; edx = índice j

	shl r13, 4			; lo mismo que imul r13, 16

.loop_clonar:
	cmp ecx, r13d
	je .fin_clonar		; jge	

	lea rsi, qword[r12 + rcx]		; *elemento = &array[i];

	; Evalúa criterio(original[i].id)
	mov edi, dword[rsi + REGISTRO_OFFSET_ID]

	push rcx
	push rdx
	push rsi
	sub rsp, 8

	call r14           ; Invoca criterio(id)

	add rsp, 8
	pop rsi
	pop rdx
	pop rcx

	cmp eax, 1
	jne .avanzar

	; Copia el ID al nuevo array clonado en la posición j

	mov r8d, dword[rsi + REGISTRO_OFFSET_ID]

	mov dword[rbx + rdx + REGISTRO_OFFSET_ID], r8d

	; Duplica la descripción con strdup
	mov rdi, qword[rsi + REGISTRO_OFFSET_DESCRIPCION]

	push rcx
	push rdx

	call strdup

	pop rdx
	pop rcx

	mov qword[rbx + rdx + REGISTRO_OFFSET_DESCRIPCION], rax 

	add edx, 16

.avanzar:
	add ecx, 16
	jmp .loop_clonar

.devuelvoNULL:
	mov rax, 0
	jmp .fin

.fin_clonar:
	mov rax, rbx       ; Retorna el puntero al array de structs
	
.fin:
; epílogo
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx

	pop rbp
	ret


; version llamando a c

	; push rbp
	; mov  rbp, rsp

	; call clonar_filtrados2


	; pop rbp
	; ret





; global clonar_filtrados
; clonar_filtrados:
; ; registros:
; 	; rdi = *array
; 	; esi =  len
; 	; rdx = *criterio
; 	; rcx = *out_len

; ; prólogo
; 	push rbp
; 	mov rbp, rsp

; 	push rbx
; 	push r12
; 	push r13
; 	push r14
; 	push r15
; 	sub rsp, 8

; 	mov r12, rdi       ; r12  = *array original
; 	mov r13d, esi      ; r13d = len
; 	mov r14, rdx       ; r14  = *criterio
; 	mov r15, rcx       ; r15  = *out_len

; 	call procesar_registros
; 	mov qword[r15], rax

; 	test rax, rax 
; 	jz .devuelvoNULL

; 	; Reservamos memoria para el nuevo array en el Heap:
; 	mov edi, eax
; 	imul edi, REGISTRO_SIZE		   ; rdi * 16

; 	call malloc
; 	mov rbx, rax       ; rbx = puntero al nuevo array clonado

; 	xor rcx, rcx       ; ecx = índice i
; 	xor rdx, rdx       ; edx = índice j

; .loop_clonar:
; 	cmp ecx, r13d
; 	jge .fin_clonar

; 	; Calcula dirección del struct original
; 	mov eax, ecx
; 	shl rax, 4       			  ; rax = i * 16
; 	lea rsi, qword[r12 + rax]

; 	; Evalúa criterio(original[i].id)
; 	mov edi, dword[rsi + REGISTRO_OFFSET_ID]
; 	push rcx
; 	push rdx
; 	push rsi
; 	sub rsp, 8

; 	call r14           ; Invoca criterio(id)

; 	add rsp, 8
; 	pop rsi
; 	pop rdx
; 	pop rcx

; 	cmp eax, 1
; 	jne .avanzar

; 	; Copia el ID al nuevo array clonado en la posición j
; 	mov eax, edx
; 	shl rax, 4       				  ; rax = j * 16 
; 	lea rdi, [rbx + rax]
; 	mov r8d, dword[rsi + REGISTRO_OFFSET_ID]
; 	mov dword[rdi + REGISTRO_OFFSET_ID], r8d

; 	; Duplica la descripción con strdup
; 	lea rdi, qword[rsi + REGISTRO_OFFSET_DESCRIPCION]
; 	push rcx
; 	push rdx
; 	push rax
; 	sub rsp, 8

; 	call strdup

; 	add rsp, 8
; 	pop rax
; 	pop rdx
; 	pop rcx

; 	; Guarda el puntero retornado por strdup en el nuevo struct
; 	mov [rbx + rax + REGISTRO_OFFSET_DESCRIPCION], rax 

; 	inc edx            ; j++

; .avanzar:
; 	inc ecx            ; i++
; 	jmp .loop_clonar


; .devuelvoNULL:
; 	mov rax, 0
; 	jmp .fin

; .fin_clonar:

; 	mov rax, rbx       ; Retorna el puntero al array de structs
	
; .fin:
; ; epílogo
; 	add rsp, 8
; 	pop r15
; 	pop r14
; 	pop r13
; 	pop r12
; 	pop rbx

; 	pop rbp
; 	ret