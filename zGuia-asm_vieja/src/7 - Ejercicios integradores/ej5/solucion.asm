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

carta.SIZE     EQU 18

tablero.mano_jugador_rojo EQU 0
tablero.mano_jugador_azul EQU 8
tablero.campo             EQU 16

tablero.SIZE              EQU 416

accion.invocar   EQU 0
accion.destino   EQU 8
accion.siguiente EQU 16

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
    ; rdi = accion
    ; rsi = nombre

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push r12
    push r13

    mov r12, rdi        ; r12 = accion
    mov r13, rsi        ; r13 = nombre


.loop:
    cmp r12, 0          ; condición de corte
    je .devuelvoFalse

    mov rdi, r13 
    mov rsi, [r12 + accion.destino]   
    lea rsi, [rsi + carta.nombre]     

    call strcmp            ; llamada a función

    cmp eax, 0
    je .devuelvoTrue

.siguiente:
    mov r12, [r12 + accion.siguiente]           ; accion = accion->siguiente;
    jmp .loop


.devuelvoTrue:
    mov rax, 1
    jmp .fin

.devuelvoFalse:
    mov rax, 0

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
    ; rdi = accion
    ; rsi = tablero

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

    mov r12, rdi        ; r12 = accion
    mov r13, rsi        ; r13 = tablero

.loop:
    cmp r12, 0          ; condición de corte
    je .fin

    mov rbx, [r12 + accion.destino]     ; rbx = accion->destino

    cmp byte[rbx + carta.en_juego], 0
    je .siguiente

    mov rdi, r13                    ; rdi = tablero
    mov rsi, rbx                    ; rsi = accion->destino

    call [r12 + accion.invocar]     ; call accion->invocar

    cmp word[rbx + carta.vida], 0
    jne .siguiente

    mov byte[rbx + carta.en_juego], FALSE       ; accion->destino->en_juego = false;


.siguiente:
    mov r12, [r12 + accion.siguiente]
    jmp .loop

.fin: 
    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r14
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

; Version con registros volatiles (preguntar)
global contar_cartas
contar_cartas:
    ; registros:
        ; rdi = tablero
        ; rsi = cant_rojas
        ; rdx = cant_azules

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    xor r8, r8        ; r8d = contador_rojas = 0
    xor r9, r9        ; r9d = contador_azules = 0

    xor r10, r10        ; r10 = índice = 0

.loop:
    cmp r10, tablero.ALTO * tablero.ANCHO         ; condición de corte
    je .fin

    mov r11, qword[rdi + tablero.campo + (r10*8)]            ; r9 = tablero->campo[i][j]

    cmp r11, 0
    je .siguiente

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
    mov dword[rsi], r8d      ; *cant_rojas = contador_rojas;
    mov dword[rdx], r9d      ; *cant_azules = contador_azules;

    ; === EPÍLOGO ===
    pop rbp
    ret


; Version con registros no volatiles (preguntar)

; global contar_cartas
; contar_cartas:
;     ; registros:
;         ; rdi = tablero
;         ; rsi = cant_rojas
;         ; rdx = cant_azules

;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp

;     ; preservar registros callee-saved 
;     push rbx   
;     push r12
;     push r13
;     push r14
;     push r15
;     sub rsp, 8          ; Alineamiento GLOBAL (La pila ya es segura para toda la función)

;     mov rbx, rdi        ; rbx = tablero
;     mov r12, rsi        ; r12 = cant_rojas
;     mov r13, rdx        ; r13 = cant_azules

;     xor r14, r14        ; r14d = contador_rojas = 0
;     xor r15, r15        ; r15d = contador_azules = 0


;     xor r8, r8        ; r8 = índice = 0

; .loop:
;     cmp r8, tablero.ALTO * tablero.ANCHO         ; condición de corte
;     je .fin

;     mov r9, qword[rbx + tablero.campo + (r8*8)]            ; r9 = tablero->campo[i][j]

;     cmp r9, 0
;     je .siguiente

;     cmp byte[r9 + carta.jugador], JUGADOR_ROJO
;     je .sumoRojo

;     cmp byte[r9 + carta.jugador], JUGADOR_AZUL
;     je .sumoAzul

; .siguiente:
;     inc r8
;     jmp .loop

; .sumoRojo:
;     inc r14d
;     jmp .siguiente

; .sumoAzul:
;     inc r15d
;     jmp .siguiente

; .fin:
;     mov dword[r12], r14d      ; *cant_rojas = contador_rojas;
;     mov dword[r13], r15d      ; *cant_azules = contador_azules;

;     ; === EPÍLOGO ===
;     add rsp, 8          ; Deshago el alineamiento global
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbx
;     pop rbp
;     ret




; -----------------------------------------------------



; ; Dada una secuencia de acciones determinar si hay alguna cuya carta tenga un
; ; nombre idéntico (mismos contenidos, no mismo puntero) al pasado por
; ; parámetro.
; ;
; ; El resultado es un valor booleano, la representación de los booleanos de C es
; ; la siguiente:
; ;   - El valor `0` es `false`
; ;   - Cualquier otro valor es `true`
; ;
; ; ```c
; ; bool hay_accion_que_toque(accion_t* accion, char* nombre);
; ; ```
; global hay_accion_que_toque
; hay_accion_que_toque:
; ; registros: 
; ;   1. RDI = accion_t*  accion
; ;   2. RSI = char*      nombre

;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp

;     ; preservar registros callee-saved si los vas a usar
;     push r12
;     push r13
;     push r14
;     push r15

; 	mov r12, rdi	;r12 = accion
; 	mov r13, rsi	;r13 = nombre

; .loop:
;     cmp r12, 0          ; condición de corte
;     je .devuelvoFalse

; 	mov r14, [r12 + accion.destino]
; 	lea r15, [r14 + carta.nombre]
	
;     mov rdi, r13             ; pasar argumento
; 	mov rsi, r15             ; pasar argumento
;     call strcmp              ; llamada a función

; 	cmp rax, 0
; 	je .devuelvoTrue

; .siguiente:
; 	mov r12, [r12 + accion.siguiente]
;     jmp .loop

; .devuelvoFalse:
; 	mov rax, 0
; 	jmp .fin   

; .devuelvoTrue:
;     mov rax, 1    
; 	jmp .fin   

; .fin:
;     ; === EPÍLOGO ===
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbp
;     ret

; ; Invoca las acciones que fueron encoladas en la secuencia proporcionada en el
; ; primer parámetro.
; ;
; ; A la hora de procesar una acción esta sólo se invoca si la carta destino
; ; sigue en juego.
; ;
; ; Luego de invocar una acción, si la carta destino tiene cero puntos de vida,
; ; se debe marcar ésta como fuera de juego.
; ;
; ; Las funciones que implementan acciones de juego tienen la siguiente firma:
; ; ```c
; ; void mi_accion(tablero_t* tablero, carta_t* carta);
; ; ```
; ; - El tablero a utilizar es el pasado como parámetro
; ; - La carta a utilizar es la carta destino de la acción (`accion->destino`)
; ;
; ; Las acciones se deben invocar en el orden natural de la secuencia (primero la
; ; primera acción, segundo la segunda acción, etc). Las acciones asumen este
; ; orden de ejecución.
; ;
; ; ```c
; ; void invocar_acciones(accion_t* accion, tablero_t* tablero);
; ; ```
; global invocar_acciones
; invocar_acciones:
; ; registros: 
; ;   1. RDI = accion_t*   	 accion
; ;   2. RSI = tablero_t*      tablero

;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp

;     ; preservar registros callee-saved si los vas a usar
;     push r12
;     push r13
;     push r14
;     push r15

; 	mov r12, rdi						;r12 = accion
; 	mov r13, rsi						;r13 = tablero
	

; .loop:
;     cmp r12, 0          ; condición de corte
;     je .fin

; 	mov r15, [r12 + accion.destino] 
; 	mov r9, [r15 + carta.en_juego] 

; 	cmp r9b, 0         
;     je .siguiente
jugador
;     mov rdi, r13             ; pasar argumento
; 	mov rsi, r15              ; pasar argumento

; 	mov r14, [r12 + accion.invocar] 						;r14 = invocar

;     call r14               ; llamada a función


; 	mov r10w, [r15 + carta.vida]

; 	cmp r10w, 0
; 	je .fueraDeJuego

	
; .siguiente:
; 	mov r12, [r12 + accion.siguiente]
;     jmp .loop


; .fueraDeJuego:
; 	mov byte[r15 + carta.en_juego],  0
; 	jmp .siguiente

; .fin:
;     ; === EPÍLOGO ===
;     pop r15
;     pop r14
;     pop r13
;     pop r12
; ;   1. RDI = tablero_t*       tablero
; ;   2. RSI = uint32_t*        cant_rojas
; ;   3. RDX = uint32_t*        cant_azu
;     pop rbp
;     ret

; ; Cuenta la cantidad de cartas rojas y azules en el tablero.
; ;
; ; Dado un tablero revisa el campo de juego y cuenta la cantidad de cartas
; ; correspondientes al jugador rojo y al jugador azul. Este conteo incluye tanto
; ; a las cartas en juego cómo a las fuera de juego (siempre que estén visibles
; ; en el campo).
; ;
; ; Se debe considerar el caso de que el campo contenga cartas que no pertenecen
; ; a ninguno de los dos jugadores.
; ;
; ; Las posiciones libres del campo tienen punteros nulos en lugar de apuntar a
; ; una carta.
; ;
; ; El resultado debe ser escrito en las posiciones de memoria proporcionadas
; ; como parámetro.
; ;
; ; ```c
; ; void contar_cartas(tablero_t* tablero, uint32_t* cant_rojas, uint32_t* cant_azules);
; ; ```
; global contar_cartas
; contar_cartas:
; ; registros: 
; ;   1. RDI = tablero_t*       tablero
; ;   2. RSI = uint32_t*        cant_rojas
; ;   3. RDX = uint32_t*        cant_azules


;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp

;     ; preservar registros callee-saved si los vas a usar
;     push r12
;     push r13
;     push r14
;     push r15

; 	mov r12, rdi						;r12 = tablero
; 	mov r13, rsi						;r13 = cant_rojas (puntero)
;     mov r14, rdx						;r14 = cant_azules (puntero)
	
;     xor r15, r15                          ;r15 = contador

;     xor r8, r8                           ; contador_rojas = 0
;     xor r9, r9                           ; contador_azules = 0

; .loop:
;     cmp r15, tablero.ALTO * tablero.ANCHO         ; condición de corte
;     je .fin

;     mov r10, [r12 + tablero.campo + (r15*8)]

;     cmp r10, 0
;     je .siguiente

;     mov r11b, [r10 + carta.jugador]

;     cmp r11b, 1
;     je .sumoRojo

;     cmp r11b, 2
;     je .sumoAzul
	
; .siguiente:
; 	add r15, 1
;     jmp .loop

; .sumoRojo:
;     add r8d, 1
;     jmp .siguiente

; .sumoAzul:
;     add r9d, 1
;     jmp .siguiente

; .fin:

;     mov [r13], r8d
;     mov [r14], r9d



;     ; === EPÍLOGO ===
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbp
;     ret

