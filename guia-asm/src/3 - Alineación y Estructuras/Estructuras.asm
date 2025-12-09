; ########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
NODO_OFFSET_NEXT EQU 0
NODO_OFFSET_CATEGORIA EQU 8
NODO_OFFSET_ARREGLO EQU 16
NODO_OFFSET_LONGITUD EQU 24
; ---------------------
NODO_SIZE EQU 32

PACKED_NODO_OFFSET_NEXT EQU 0
PACKED_NODO_OFFSET_CATEGORIA EQU 8
PACKED_NODO_OFFSET_ARREGLO EQU 9
PACKED_NODO_OFFSET_LONGITUD EQU 17
; ---------------------
PACKED_NODO_SIZE EQU 21

LISTA_OFFSET_HEAD EQU 0
LISTA_SIZE EQU 8

PACKED_LISTA_OFFSET_HEAD EQU 0

PACKED_LISTA_SIZE EQU 8

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES

; extern uint32_t cantidad_total_de_elementos(lista_t* lista);
; registros: lista -> RDI
cantidad_total_de_elementos:
    ; prólogo
    push rbp
    mov rbp, rsp
    push r12

    xor eax, eax                         ; acumulador = 0
    mov r12, [rdi + LISTA_OFFSET_HEAD]   ; nodo = lista->head

.ciclo:
    test r12, r12
    jz .fin                              ; si nodo == NULL, salir

    add eax, dword [r12 + NODO_OFFSET_LONGITUD] ; acum += nodo->longitud
    mov r12, [r12 + NODO_OFFSET_NEXT]          ; nodo = nodo->next
    jmp .ciclo

  ; epílogo
.fin:
    pop r12
    pop rbp
    ret

; int cantidad_total_de_elementos(lista_t* lista) {                 //ANALOGÍA EN C
;     int acumulador = 0;
;     nodo_t* nodo = lista->head;

;     while (nodo != NULL) {
;         acumulador += nodo->longitud;
;         nodo = nodo->next;
;     }

;     return acumulador;
; }

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
; registros: lista -> RDI
cantidad_total_de_elementos_packed:
    ; prólogo
    push rbp
    mov rbp, rsp
    push r12

    xor eax, eax                                   ; acumulador = 0
    mov r12, [rdi + PACKED_LISTA_OFFSET_HEAD]      ; nodo = lista->head

.ciclo:
    test r12, r12
    jz .fin                                        ; si nodo == NULL, salir

    add eax, dword [r12 + PACKED_NODO_OFFSET_LONGITUD]    ; acum += nodo->longitud
    mov r12, [r12 + PACKED_NODO_OFFSET_NEXT]              ; nodo = nodo->next
    jmp .ciclo

  ; epílogo
.fin:
    pop r12
    pop rbp
    ret