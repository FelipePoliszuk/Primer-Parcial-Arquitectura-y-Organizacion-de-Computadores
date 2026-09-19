; Definiciones comunes
TRUE  EQU 1
FALSE EQU 0

; Identificador del jugador rojo
JUGADOR_ROJO EQU 1
; Identificador del jugador azul
JUGADOR_AZUL EQU 2

; Ancho y alto del tablero de juego
tablero.ANCHO EQU 10
tablero.ALTO  EQU 5

; Marca un OFFSET o SIZE como no completado
; Esto no lo chequea el ABI enforcer, sirve para saber a simple vista qué cosas
; quedaron sin completar :)
NO_COMPLETADO EQU -1

extern strcmp

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
carta.en_juego EQU 0
carta.nombre   EQU 1
carta.vida     EQU 14
carta.jugador  EQU 16
; ---------------------------------
carta.SIZE     EQU 18


tablero.mano_jugador_rojo EQU 0
tablero.mano_jugador_azul EQU 8
tablero.campo             EQU 16
; ---------------------------------

tablero.SIZE              EQU 416


accion.invocar   EQU 0
accion.destino   EQU 8
accion.siguiente EQU 16
; ---------------------------------
accion.SIZE      EQU 24

; Variables globales de sólo lectura
section .rodata

; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - hay_accion_que_toque
global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE

; Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - invocar_acciones
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE

; Marca el ejercicio 3 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contar_cartas
global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db TRUE

section .text

; Dada una secuencia de acciones determinar si hay alguna cuya carta tenga un
; nombre idéntico (mismos contenidos, no mismo puntero) al pasado por
; parámetro.
;
; El resultado es un valor booleano, la representación de los booleanos de C es
; la siguiente:
;   - El valor `0` es `false`
;   - Cualquier otro valor es `true`
;
; ```c
; bool hay_accion_que_toque(accion_t* accion, char* nombre);
; ```
global hay_accion_que_toque
hay_accion_que_toque:
; registros:
	; rdi = *accion
	; rsi = *nombre
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push r12
    push r13
    
    mov r12, rdi 		; r12 = *accion
    mov r13, rsi 		; r13 = *nombre		

.loop:
    test r12, r12          ; condición de corte
    je .devuelvoFalse

	mov rdi, qword[r12 + accion.destino] 
	lea rdi, [rdi + carta.nombre] 

	mov rsi, r13			; rsi = *nombre
    call strcmp             ; llamada a función

	test al, al 
	jnz .siguiente

	mov rax, 1		; True
	jmp .fin

.siguiente:
    mov r12, qword[r12 + accion.siguiente]
    jmp .loop

.devuelvoFalse:
	mov rax, 0		; False

.fin:
    ; === EPÍLOGO ===
    pop r13
    pop r12
    pop rbp
    ret


; Invoca las acciones que fueron encoladas en la secuencia proporcionada en el
; primer parámetro.
;
; A la hora de procesar una acción esta sólo se invoca si la carta destino
; sigue en juego.
;
; Luego de invocar una acción, si la carta destino tiene cero puntos de vida,
; se debe marcar ésta como fuera de juego.
;
; Las funciones que implementan acciones de juego tienen la siguiente firma:
; ```c
; void mi_accion(tablero_t* tablero, carta_t* carta);
; ```
; - El tablero a utilizar es el pasado como parámetro
; - La carta a utilizar es la carta destino de la acción (`accion->destino`)
;
; Las acciones se deben invocar en el orden natural de la secuencia (primero la
; primera acción, segundo la segunda acción, etc). Las acciones asumen este
; orden de ejecución.
;
; ```c
; void invocar_acciones(accion_t* accion, tablero_t* tablero);
; ```
global invocar_acciones
invocar_acciones:
; registros:
	; rdi = *accion
	; rsi = *tablero
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    sub rsp, 8          ; Alineamiento GLOBAL (La pila ya es segura para toda la función)
    
    mov r12, rdi 		; r12 = *accion =  actual
    mov r13, rsi 		; r13 = *tablero		

.loop:
    test r12, r12          ; condición de corte
    je .fin

	mov rbx, qword[r12 + accion.destino]		; rbx = *carta

	cmp byte[rbx + carta.en_juego], FALSE
	je .siguiente

	mov r9, qword[r12 + accion.invocar] 		; r9 = actual->invocar
	
	mov rdi, r13			; rdi = *tablero
	mov rsi, rbx			; rsi = *carta
	
	call r9		; actual->invocar(tablero, carta);

	cmp word[rbx + carta.vida], 0
	jne .siguiente

	mov byte[rbx + carta.en_juego], FALSE

.siguiente:
    mov r12, qword[r12 + accion.siguiente]
    jmp .loop

.fin:
    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


; Cuenta la cantidad de cartas rojas y azules en el tablero.
;
; Dado un tablero revisa el campo de juego y cuenta la cantidad de cartas
; correspondientes al jugador rojo y al jugador azul. Este conteo incluye tanto
; a las cartas en juego cómo a las fuera de juego (siempre que estén visibles
; en el campo).
;
; Se debe considerar el caso de que el campo contenga cartas que no pertenecen
; a ninguno de los dos jugadores.
;
; Las posiciones libres del campo tienen punteros nulos en lugar de apuntar a
; una carta.
;
; El resultado debe ser escrito en las posiciones de memoria proporcionadas
; como parámetro.
;
; ```c
; void contar_cartas(tablero_t* tablero, uint32_t* cant_rojas, uint32_t* cant_azules);
; ```
global contar_cartas
contar_cartas:
; registros:
	; rdi = *tablero
	; rsi = *cant_rojas
	; rdx = *cant_azules
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp
    
	xor r8, r8			; r8d = cantidad_rojas = 0
	xor r9, r9			; r9d = cantidad_azules = 0

    xor r10, r10        ; r10 = índice = 0

.loop:
    cmp r10, 50          ; tablero.ALTO * tablero.ANCHO 
    je .fin

	mov r11, qword[rdi + tablero.campo + (r10*8)]		; r10 = tablero->campo[i][j]

	test r11, r11	
	jz .siguiente

	cmp byte[r11 + carta.jugador], JUGADOR_ROJO
	je .sumoRojo

	cmp byte[r11 + carta.jugador], JUGADOR_AZUL
	je .sumoAzul
	
.siguiente:
    inc r10
    jmp .loop

.sumoRojo:
	inc r8d
	jmp .siguiente

.sumoAzul:
	inc r9d
	jmp .siguiente	

.fin:
    mov dword[rsi], r8d       ; *cant_rojas = cantidad_rojas;
    mov dword[rdx], r9d       ; *cant_azules = cantidad_azules;

    ; === EPÍLOGO ===
    pop rbp
    ret