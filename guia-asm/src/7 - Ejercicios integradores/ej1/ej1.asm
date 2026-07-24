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
    ; rdi = **inventario
    ; rsi = *indice
    ; dx = tamanio
    ; rcx = comparador

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

    mov r12, rdi        ; r12 = **inventario
    mov r13, rsi        ; r13 = *indice
    mov r14w, dx        ; r14w = tamanio
    mov r15, rcx        ; r15 = comparador

    xor rbx, rbx        ; índice = i = 0
    dec r14w            ; tamanio - 1

.loop:
    cmp bx, r14w          ; condición de corte
    je .true

    xor r8, r8
    xor r9, r9

    mov r8w, word[r13 + (rbx*2)]     ; r8 = indice[i]
    mov r9w, word[r13 + ((rbx+1)*2)]     ; r9 = indice[i + 1]


    mov rdi, qword[r12 + (r8*8)]            ; rdi = inventario[indice[i]]
    mov rsi, qword[r12 + (r9*8)]            ; rsi = inventario[indice[i + 1]]

    call r15        ; LLamo a comparador

    cmp al, 0
    je .false

.siguiente:
    inc bx
    jmp .loop

.false:
    mov rax, 0
    jmp .fin

.true:
    mov rax, 1

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


; item_t **indice_a_inventario(item_t **inventario, uint16_t *indice, uint16_t tamanio) {
global indice_a_inventario
indice_a_inventario:
; registros:    
    ; rdi = **inventario
    ; rsi = *indice
    ; dx = tamanio

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

    mov r12, rdi        ; r12 = **inventario
    mov r13, rsi        ; r13 = *indice
    mov r14w, dx        ; r14w = tamanio

    movzx rdi, r14w

    imul rdi, 8 
    
    call malloc

    mov r15, rax        ; r15 = **inventario_nuevo

    xor rbx, rbx        ; índice = i = 0

.loop:
    cmp bx, r14w          ; condición de corte
    je .fin

    xor r8, r8
    mov r8w, word[r13 + (rbx*2)]     ; r8w = indice[i]
    mov r8, qword[r12 + (r8*8)]      ; r8 = inventario[indice[i]]

    mov qword[r15 + (rbx*8)], r8    ; inventario_nuevo[i] = inventario[indice[i]];

.siguiente:
    inc bx
    jmp .loop

.fin:
    mov rax, r15       ; Devuelvo **inventario_nuevo

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


























; ;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; ; Completar las definiciones (serán revisadas por ABI enforcer):
; ITEM_NOMBRE EQU 0
; ITEM_FUERZA EQU 20
; ITEM_DURABILIDAD EQU 24

; ITEM_SIZE EQU 28

; ;; La funcion debe verificar si una vista del inventario está correctamente 
; ;; ordenada de acuerdo a un criterio (comparador)

; ;; Dónde:
; ;; - `inventario`: Un array de punteros a ítems que representa el inventario a
; ;;   procesar.
; ;; - `indice`: El arreglo de índices en el inventario que representa la vista.
; ;; - `tamanio`: El tamaño del inventario (y de la vista).
; ;; - `comparador`: La función de comparación que a utilizar para verificar el
; ;;   orden.
; ;; 
; ;; Tenga en consideración:
; ;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
; ;;   como parámetro podría tener basura.
; ;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
; ;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
; ;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
; ;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
; ;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
; ;;   de verificar que el orden sea estable.

; ;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

; global es_indice_ordenado
; es_indice_ordenado:
; ; registros:
;     ; RDI = inventario
;     ; RSI = indice
;     ; DX = tamanio
;     ; RCX = comparador

;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp

;     ; preservar registros callee-saved 
;     push rbx    
;     push r12
;     push r13
;     push r14
;     push r15

;     mov r12, rdi        ;r12 = inventario
;     mov r13, rsi        ;r13 = indice
;     mov r14w, dx        ;r14w = tamanio   
;     mov r15, rcx        ;r15 = comparador

;     xor rbx, rbx        ; rbx = índice del loop 

;     dec r14w            ; decremento el tamanio en 1 para el loop
; .loop:
;     cmp bx, r14w         ; condición de corte 
;     je .true


;     movzx r8, word[r13 + rbx*2]         ; r8 = indice[i]

;     movzx r9, word[r13 + rbx*2 + 2]     ; r9 = indice[i+1]

;     mov rdi, [r12 + r8*8]               ; rdi = inventario[indice[i]]

;     mov rsi, [r12 + r9*8]              ; r11 = inventario[indice[i+1]]

;     ;paso argumentos para llamar a la función

;     sub rsp, 8          ; mantener alineamiento 16 bytes

;     call r15            ; llamo a comparador

;     add rsp, 8          ; mantener alineamiento 16 bytes

;     cmp al, 0

;     je .false


; .siguiente:
;     inc rbx
;     jmp .loop

; .true:
;     mov rax, 1
;     jmp .fin


; .false:
;     mov rax, 0
;     jmp .fin

; .fin:
;     ; === EPÍLOGO ===
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbx  
;     pop rbp
;     ret


; ;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
; ;; orden descrito por la misma.

; ;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
; ;; utilizando `free(ptr)`.

; ;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

; ;; Donde:
; ;; - `inventario` un array de punteros a ítems que representa el inventario a
; ;;   procesar.
; ;; - `indice` es el arreglo de índices en el inventario que representa la vista
; ;;   que vamos a usar para reorganizar el inventario.
; ;; - `tamanio` es el tamaño del inventario.
; ;; 
; ;; Tenga en consideración:
; ;; - Tanto los elementos de `inventario` como los del resultado son punteros a
; ;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
; ;;   ítems**


; ; item_t **indice_a_inventario(item_t **inventario, uint16_t *indice, uint16_t tamanio) {

; global indice_a_inventario
; indice_a_inventario:
; ; registros:
;     ; RDI = inventario
;     ; RSI = indice
;     ; DX = tamanio

;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp

;     ; preservar registros callee-saved 
;     push rbx    
;     push r12
;     push r13
;     push r14
;     push r15

;     mov r12, rdi        ; r12 = inventario
;     mov r13, rsi        ; r13 = indice
;     mov r14w, dx        ; r14w = tamanio   

;     xor r8, r8

;     mov r8w, r14w       ; r8w = tamanio
;     imul r8w, r8w, 8    ; tamanio * 8 (size de un puntero) 
; ;   // shl rdi, 3 

;     mov rdi, r8         ; paso size por rdi

;     sub rsp, 8          ; mantener alineamiento 16 bytes
;     call malloc         ; llamo a malloc
;     add rsp, 8          ; mantener alineamiento 16 bytes
    
;     mov r15, rax        ; r15 = **inventario_nuevo

;     xor rbx, rbx        ; rbx = índice del loop 

; .loop:
;     cmp bx, r14w         ; condición de corte 
;     je .fin

;     movzx r8, word[r13 + rbx*2]         ; r8 = indice[i]

;     mov rdi, [r12 + r8*8]               ; rdi = inventario[indice[i]]

;     mov [r15 + rbx*8], rdi             ; inventario_nuevo[i] = inventario[indice[i]]

; .siguiente:
;     inc rbx
;     jmp .loop

; .fin:
;     mov rax, r15               ; devuelvo puntero en rax

;     ; === EPÍLOGO ===
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbx  
;     pop rbp
;     ret