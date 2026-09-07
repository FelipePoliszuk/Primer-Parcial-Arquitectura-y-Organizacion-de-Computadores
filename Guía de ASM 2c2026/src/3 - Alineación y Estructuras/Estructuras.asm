extern cantidad_total_de_elementosC
extern cantidad_total_de_elementos_packedC

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
NODO_OFFSET_NEXT EQU 0
NODO_OFFSET_CATEGORIA EQU 8
NODO_OFFSET_ARREGLO EQU 16
NODO_OFFSET_LONGITUD EQU 24
; -------
NODO_SIZE EQU 32


PACKED_NODO_OFFSET_NEXT EQU 0
PACKED_NODO_OFFSET_CATEGORIA EQU 8
PACKED_NODO_OFFSET_ARREGLO EQU 9
PACKED_NODO_OFFSET_LONGITUD EQU 17
; -------
PACKED_NODO_SIZE EQU 21


LISTA_OFFSET_HEAD EQU 0
; -------
LISTA_SIZE EQU 8

PACKED_LISTA_OFFSET_HEAD EQU 0
; -------
PACKED_LISTA_SIZE EQU 8

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
cantidad_total_de_elementos:
;registros: 
	; rdi = *lista
	
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp
	
	xor eax, eax						; eax = cantidad = 0 

	mov r8, qword[rdi + LISTA_OFFSET_HEAD]		; r8 = lista->head;

.loop:
    test r8, r8          ; condición de corte
    jz .fin

	mov r9d, dword[r8 + NODO_OFFSET_LONGITUD]

	add eax, r9d

.siguiente:
    mov r8, qword[r8 + NODO_OFFSET_NEXT]
    jmp .loop

.fin:

	; call cantidad_total_de_elementosC

    ; === EPÍLOGO ===
    pop rbp
    ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
cantidad_total_de_elementos_packed:
;registros: 
	; rdi = *lista
	
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp
	
	xor eax, eax						; eax = cantidad = 0 

	mov r8, qword[rdi + PACKED_LISTA_OFFSET_HEAD]		; r8 = lista->head;

.loop:
    test r8, r8          ; condición de corte
    jz .fin

	mov r9d, dword[r8 + PACKED_NODO_OFFSET_LONGITUD]

	add eax, r9d

.siguiente:
    mov r8, qword[r8 + PACKED_NODO_OFFSET_NEXT]
    jmp .loop

.fin:

	; call cantidad_total_de_elementos_packedC

    ; === EPÍLOGO ===
    pop rbp
    ret

