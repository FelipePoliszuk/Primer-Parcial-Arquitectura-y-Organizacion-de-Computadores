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
extern malloc

extern free


; ----------------------------------------------------
; nodo_evolucion_t* rastrear_linea_evolutiva(pokedex_t* pokedex, uint16_t id_final)
; ----------------------------------------------------
global rastrear_linea_evolutiva
rastrear_linea_evolutiva:
; registros:
	; rdi = *pokedex
	; si =   id_final
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8         ; Alineamiento GLOBAL (La pila ya es segura para toda la función)
    
    mov r12, rdi        ; r12  = *pokedex
    mov r13w, si        ; r13w =  id_final

    xor r14, r14        ; r14 = *anterior = NULL = 0


.loop:
    cmp r13w, 0          ; condición de corte
    je .fin

    mov rdi, NODO_EVOLUCION_TAMANIO
    call malloc

    mov r15, rax        ; r15 = nodo_nuevo

    mov rdi, r12
    mov si, r13w

    call buscar_pokemon_por_id

    mov word[r15 + NODO_EVOLUCION_ID_OFFSET], r13w              ; nodo_nuevo->id = id_final;
    mov qword[r15 + NODO_EVOLUCION_EVOLUCIONA_EN_OFFSET], r14   ; nodo_nuevo->evoluciona_en = anterior;

    mov r14, r15        ; anterior = nodo_nuevo;

.siguiente:
    mov r13w, word[rax + POKEMON_EVOLUCIONA_DE_ID_OFFSET]       ; id_final = pokemon->evoluciona_de_id;
    jmp .loop

.fin:
    mov rax, r14       

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; ----------------------------------------------------
; pokemon_t* buscar_pokemon_por_id(pokedex_t* pokedex, uint16_t id)
; ----------------------------------------------------
global buscar_pokemon_por_id
buscar_pokemon_por_id:
    ; registros:
	; rdi = *pokedex
	; si  =  id
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24          ; Alineamiento GLOBAL (La pila ya es segura para toda la función)
    
    mov r12, rdi        ; r12 = *pokedex
    mov r13w, si        ; r13w =  id
    
    mov dword[RBP-48], 0            ; dword[RBP-48] = i = 0

.loopFilas:
    mov r8d, dword[r12 + POKEDEX_FILAS_OFFSET]
    cmp dword[RBP-48], r8d                        ; condición de corte
    je .retNULL

    mov dword[RBP-56], 0             ; dword[RBP-56] = j = 0
    .loopColumnas:
        mov r8d, dword[r12 + POKEDEX_COLUMNAS_OFFSET]
        cmp dword[RBP-56], r8d                        ; condición de corte
        je .siguienteFilas

        mov r8, qword[r12 + POKEDEX_POKEMONS_OFFSET]    ; r8 = pokedex->pokemons
        
        mov r9d, dword[RBP-48]       ; r9 = i
        
        mov r8, qword[r8 + (r9*8)]    ; r8 = pokedex->pokemons[i]

        mov r10d, dword[RBP-56]       ; r10 = j

        mov r8, qword[r8 + (r10*8)]    ; r8 = pokedex->pokemons[i][j]

        test r8, r8
        jz .siguienteColumnas

        cmp word[r8 + POKEMON_ID_OFFSET], r13w
        je .retID

    .siguienteColumnas:
        inc dword[RBP-56]
        jmp .loopColumnas

.siguienteFilas:
    inc dword[RBP-48]
    jmp .loopFilas

.retNULL:
    xor rax, rax        ; return NULL;
    jmp .fin

.retID:
    mov rax, r8        ; return pokedex->pokemons[i][j];

.fin:
    ; === EPÍLOGO ===
    add rsp, 24          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret