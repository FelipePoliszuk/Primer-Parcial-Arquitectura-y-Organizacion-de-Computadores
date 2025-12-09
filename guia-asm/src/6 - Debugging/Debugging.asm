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

POINTER_SIZE EQU 4
UINT32_SIZE EQU 8

; Marcar el ejercicio como hecho (`true`) o pendiente (`false`).

global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_4_HECHO
EJERCICIO_4_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.


; uint64_t ejercicio1(uint64_t sum1, uint64_t sum2, uint64_t sum3, uint64_t sum4, uint64_t sum5);
; registros:
; sum1 = [rdi]
; sum2 = [rsi]
; sum3 = [rdx]
; sum4 = [rcx]
; sum5 = [r8]

global ejercicio1
ejercicio1:

	add rdi, rsi
	add rdi, rdx
    add rdi, rcx
    add rdi, r8
	mov rax, rdi

	ret

	

; void ejercicio2(item_t* un_item, uint32_t id, uint32_t cantidad, char nombre[]);
; registros:
; un_item = [rdi] PUNTERO

; id = [esi]
; cantidad = [edx]
; char = [rcx]

; se usan registros e para 32 bits, y r para 64 bits (los punteros)

global ejercicio2
ejercicio2:
	
	mov [rdi+ITEM_OFFSET_ID], esi
	mov [rdi+ITEM_OFFSET_CANTIDAD], edx

	; se preparan los punteros para el call a strcopy
	mov rdi, rdi+ITEM_OFFSET_NOMBRE
	mov rsi, rcx
	
	call strcpy 
	
	ret

	


global ejercicio3
ejercicio3:
	cmp rsi, 0
	je .vacio
	
	mov rcx, rdi ; array
	mov r8, 0 ; sumatoria
	mov r9, 0 ; i

	.loop:
	mov rdi, r8
	mov rsi, [rcx + r9*4]

	call rdx

	add r8, rax
	mov rax, r8

	inc r9
	cmp r9, rsi
	je .end

	jmp .loop

	.vacio:
	mov rax, 64

	.end:
	ret

global ejercicio4
ejercicio4:
	mov r12, rdi
	mov r13, rsi
	mov r14, rdx

	xor rdi, rdi
	mov eax, UINT32_SIZE
	mul esi
	mov edi, eax

	call malloc
	mov r15, rax
	
	xor rbx, rbx
	.loop:
	
	cmp rbx, r13
	je .end

	mov r8, [r12+rbx*POINTER_SIZE]
	mov r9d, [r8]
	mov rax, r14
	mul r9d
	mov [r15+rbx*UINT32_SIZE], eax
	
	mov rsi, r8 
	call free

	inc rbx
	jmp .loop

	.end:
	mov rax, r15
	ret
