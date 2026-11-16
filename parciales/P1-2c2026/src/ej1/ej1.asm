; ------------------------
; Offsets para los structs
; Plataforma: x86_64 (LP64)
; ------------------------

section .data

section .text

; ------------------------
; info_t (packed)
; ------------------------
INFO_NOMBRE_OFFSET        EQU 0   ; char nombre[16]
INFO_TIPO_OFFSET          EQU 16   ; char tipo[12]
INFO_NIVEL_OFFSET         EQU 28   ; uint16_t nivel
INFO_TAMANIO              EQU 30   ; sizeof(info_t)

; ------------------------
; pokemon_t
; ------------------------
POKEMON_ID_OFFSET               EQU 0   ; uint16_t id
POKEMON_MOVIMIENTOS_OFFSET      EQU 8   ; char* movimientos[4]
POKEMON_INFO_OFFSET             EQU 40   ; info_t info
POKEMON_DESCRIPCION_OFFSET      EQU 72   ; char* descripcion
POKEMON_EVOLUCIONA_DE_ID_OFFSET EQU 80   ; uint16_t evoluciona_de_id
POKEMON_TAMANIO                 EQU 88   ; sizeof(pokemon_t)

; ------------------------
; nodo_evolucion_t
; ------------------------
NODO_EVOLUCION_ID_OFFSET            EQU 0   ; uint16_t id
NODO_EVOLUCION_EVOLUCIONA_EN_OFFSET EQU 8   ; struct nodo_evolucion* evoluciona_en
NODO_EVOLUCION_TAMANIO              EQU 16   ; sizeof(nodo_evolucion_t)

; ------------------------
; pokedex_t
; ------------------------
POKEDEX_POKEMONS_OFFSET EQU 0   ; matriz_pokemons pokemons
POKEDEX_BITMAP_OFFSET   EQU 8   ; uint8_t* bitmap
POKEDEX_FILAS_OFFSET    EQU 16   ; uint32_t filas
POKEDEX_COLUMNAS_OFFSET EQU 20   ; uint32_t columnas
POKEDEX_TAMANIO         EQU 24   ; sizeof(pokedex_t)

; ------------------------
; pokemon_filtrados_t
; ------------------------
POKEMON_FILTRADOS_IDS_OFFSET      EQU 0   ; uint16_t* ids_pokemons
POKEMON_FILTRADOS_CANTIDAD_OFFSET EQU 8   ; uint16_t cantidad_pokemons
POKEMON_FILTRADOS_TAMANIO         EQU 16   ; sizeof(pokemon_filtrados_t)

; ------------------------
; Funciones externas
; ------------------------
extern free
extern strdup

extern malloc
extern strlen
extern strcpy


; ----------------------------------------------------
; void actualizar_movimientos_pokemon(pokemon_t* pokemon, char** nuevos_movimientos, int cantidad)
; ----------------------------------------------------
global actualizar_movimientos_pokemon
actualizar_movimientos_pokemon:
; registros:
	; rdi =  *pokemon
	; rsi = **nuevos_movimientos
	; edx =   cantidad
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    push r14
    
    mov r12, rdi        ; r12 =  *pokemon
    mov r13, rsi        ; r13 = **nuevos_movimientos
    mov r14d, edx        ; r14d =   cantidad
    

    test r12, r12       ; if (pokemon == NULL)
    jz .fin

    xor rbx, rbx        ; ebx = 0 
.loopFree:
    cmp ebx, 4          ; condición de corte
    je .ifCantidad

    mov rdi, qword[r12 + POKEMON_MOVIMIENTOS_OFFSET + (rbx*8)]

    call free 

.siguienteFree:
    inc ebx
    jmp .loopFree

.ifCantidad:
    cmp r14, 4
    jg .else        ;  else

    xor rbx, rbx
.loopThen1:
    cmp rbx, r14
    je .loopThen2

    mov rdi, qword[r13 + (rbx*8)]

    call strdup

    mov qword[r12 + POKEMON_MOVIMIENTOS_OFFSET + (rbx*8)], rax

.siguienteThen1:
    inc rbx
    jmp .loopThen1  

.loopThen2:    
    cmp r14, 4
    je .fin

    mov qword[r12 + POKEMON_MOVIMIENTOS_OFFSET + (r14*8)], 0

.siguienteThen2:
    inc r14
    jmp .loopThen2  

.else:
    xor rbx, rbx

.loopElse:
    cmp rbx, 4
    je .fin

    mov rdi, qword[r13 + (rbx*8)]

    call strdup

    mov qword[r12 + POKEMON_MOVIMIENTOS_OFFSET + (rbx*8)], rax

.siguienteElse:
    inc rbx
    jmp .loopElse    

.fin:
    ; ; === EPÍLOGO ===
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

