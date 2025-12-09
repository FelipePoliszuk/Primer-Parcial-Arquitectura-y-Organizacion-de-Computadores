extern malloc
extern free
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4
USUARIO_SIZE EQU 8

CASO_CATEGORIA_OFFSET EQU 0
CASO_ESTADO_OFFSET EQU 4
CASO_USUARIO_OFFSET EQU 8
CASO_SIZE EQU 16
; [c c c # | e e # #]
; [u u u u | u u u u]

SEGMENTACION_CASOS0_OFFSET EQU 0
SEGMENTACION_CASOS1_OFFSET EQU 8
SEGMENTACION_CASOS2_OFFSET EQU 16
SEGMENTACION_SIZE EQU 24

ESTADISTICAS_CLT_OFFSET EQU 0
ESTADISTICAS_RBO_OFFSET EQU 1
ESTADISTICAS_KSC_OFFSET EQU 2
ESTADISTICAS_KDT_OFFSET EQU 3
ESTADISTICAS_ESTADO0_OFFSET EQU 4
ESTADISTICAS_ESTADO1_OFFSET EQU 5
ESTADISTICAS_ESTADO2_OFFSET EQU 6
ESTADISTICAS_SIZE EQU 7
; [C R K D | 0 1 2 _] SIZE = 7, alineado a 1

; rdi -> caso_t*
; rsi -> largo
; rdx -> nivel
contar_casos_por_nivel:
	push rbp
	mov rbp, rsp

	xor rax, rax

	cmp rsi, 0
	jz .end

	.loop:
	dec rsi
	; cargo caso_t
	mov r11, rsi
	imul r11, CASO_SIZE
	add r11, CASO_USUARIO_OFFSET
	mov r9, QWORD [rdi + r11]
	mov r10d, DWORD [r9 + USUARIO_NIVEL_OFFSET]
	
	cmp r10d, edx
	jne .otherlevel
	
	inc rax
	.otherlevel:
	test rsi, rsi
	jnz .loop

	.end:
	pop rbp
ret

;segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo)
global segmentar_casos
segmentar_casos:
	push rbp
	mov rbp, rsp
	sub rsp, 8
	push rbx
	push r12
	push r13
	push r14
	push r15

	mov	rbx, rdi ; caso_t*
	mov r12, rsi ; largo

	; contadores por nivel r13 -> 0, r14 -> 1, r15 -> 2.
	;
	; rdi -> caso_t*
	; rsi -> largo
	mov rdx, 0 ; nivel
	call contar_casos_por_nivel
	mov r13, rax

	mov rdi, rbx
	mov rsi, r12
	mov rdx, 1 ; 
	call contar_casos_por_nivel
	mov r14, rax

	mov rdi, rbx
	mov rsi, r12
	mov rdx, 2 ; 
	call contar_casos_por_nivel
	mov r15, rax
	; fin contadores

	; aprovecho los registros no-volatiles para apuntar a memoria.
	.malloc_l0:
	cmp r13, 0
	je .malloc_l1 ; caso NULL queda en 0
	shl r13, 3 ; voy a guardar solo punteros al array original, no copias	
	mov rdi, r13
	call malloc
	mov r13, rax
	.malloc_l1:
	cmp r14, 0
	je .malloc_l2 ; caso NULL queda en 0
	shl r14, 3	
	mov rdi, r14
	call malloc
	mov r14, rax
	.malloc_l2:
	cmp r15, 0
	je .finmalloc_lvl ; caso NULL queda en 0
	shl r15, 3	
	mov rdi, r15
	call malloc
	mov r15, rax
	.finmalloc_lvl:
	; Indices por nivel, para meterlos en una sola pasada en cada nivel.
	xor r8, r8 ; contador lvl 0
	xor r9, r9 ; indice lvl 0
	xor r10, r10 ; indice lvl 0

	xor r11, r11 ; indice para caso_t*
	; recordando:
	; rbx -> caso_t*
	; r12 -> largo
	test r12, r12
	jz .fin_llenado
	
	.loop_llenado:
	; En cada iter. RBX cambia al siguiente caso_t.

	; lea rdi, QWORD [rbx + CASO_USUARIO_OFFSET]
	;imul rdi, r11, CASO_SIZE
	;add rbx

	; cargo usuario_t
	mov rdi, QWORD [rbx + CASO_USUARIO_OFFSET]
	mov ecx, DWORD [rdi + USUARIO_NIVEL_OFFSET]
	
	; aca como si fuera un switch para agregar por nivel
	cmp ecx, 0
	jne .llenar_l1
	mov QWORD [r13 + 8*r8], rbx
	inc r8

	.llenar_l1:
	cmp ecx, 1
	jne .llenar_l2
	mov QWORD [r14 + 8*r9], rbx 
	inc r9

	.llenar_l2:
	cmp ecx, 2
	jne .continuar_llenado
	mov QWORD [r15 + 8*r10], rbx 
	inc r10
	.continuar_llenado:
	add rbx, CASO_SIZE
	inc r11
	cmp r11, r12
	jl .loop_llenado
	.fin_llenado:
	
	mov rdi, SEGMENTACION_SIZE
	call malloc
	mov QWORD [RAX + SEGMENTACION_CASOS0_OFFSET], r13 
	mov QWORD [RAX + SEGMENTACION_CASOS1_OFFSET], r14 
	mov QWORD [RAX + SEGMENTACION_CASOS2_OFFSET], r15 

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	add rsp, 8
	pop rbp
ret
