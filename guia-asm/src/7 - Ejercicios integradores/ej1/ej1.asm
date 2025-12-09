extern malloc

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_NOMBRE EQU 0
ITEM_FUERZA EQU 20
ITEM_DURABILIDAD EQU 24
ITEM_SIZE EQU 28

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)



;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

global es_indice_ordenado
es_indice_ordenado:
; registros:

; inventario = RDI
; indice = RSI
; tamanio = RDX (uint16_t, solo usar DX)
; comparador = RCX

;prologo
	push rbp	
	mov rbp, rsp
	push r12	
	push r13	
	push r14	
	push r15	
	push rbx	
	sub rsp, 8	

	xor r14, r14						;limpio basura
					
	xor r15, r15						; r15 = contador = 0
	mov r12, rdi 						;r12 = inventario
	mov r13, rsi 						;r13 = indice
	mov r14w, dx 						;r14 = tamanio
	mov rbx, rcx 						;rbx = funcion
					
	dec r14 							;le saco uno al tamanio ya que voy hacer accesos a i e i+1

.loop:
	cmp r15, r14 		
	je .iguales 						;si ya recorri todo, voy a iguales

	xor r8, r8							;limpio basura 
	xor r9, r9							;limpio basura

	mov r8w, word[r13+r15*2] 			;r8 = indice
	mov r9w, word[r13+(r15+1)*2] 		;r9 = indice + 1

	mov rdi, [r12+r8*8]					;rdi = item 1
	mov rsi, [r12+r9*8]					;rsi = item 2

	call rbx 							;llamo a comparador
	cmp rax, FALSE						;si rax == 0 salto a .noIguales
	je .noIguales

	inc r15								;avanzo al siguiente item/indice
	jmp .loop

.iguales:
	mov al, TRUE
	jmp .fin


.noIguales:
	mov al, FALSE

.fin:
	;epilogo
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario:
	
; registros:

; inventario = RDI
; indice = RSI
; tamanio = RDX (uint16_t, solo usar DX)

;prologo
	push rbp	
	mov rbp, rsp
	push r12	
	push r13	
	push r14	
	push r15	


	xor r14, r14			;limpio basura

	mov r12, rdi			;r12 = puntero a inventario
	mov r13, rsi			;r13 = puntero a indice
	mov r14w, dx			;r14w = tamanio
	xor r15, r15			; contador = 0

	mov rdi, rdx 			;rdi = tamaño 
	shl rdi, 3 				;rdi = tamanio * 8
	 
	call malloc				;rax = puntero a nuevo inventario

	
.loop:
	cmp r15, r14 		
	je .fin 						;si ya recorri todo, voy a fin

	xor r8, r8						;limpio r8

	mov r8w, word[r13 + r15 * 2]	;r8 = indice

	mov rdi, [r12 + r8 * 8]			;rdi = item
	mov [rax + r15*8], rdi			;guardo item

	inc r15							; avanzo uno 
	jmp .loop


.fin:
	;epilogo
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
