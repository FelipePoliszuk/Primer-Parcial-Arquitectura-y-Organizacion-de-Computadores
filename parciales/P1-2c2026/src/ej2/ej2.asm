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
extern strcmp
extern obtener_bit  ; uint8_t obtener_bit(const uint8_t* bitmap, uint32_t posicion)

extern free

; ----------------------------------------------------
; pokemon_filtrados_t* obtener_avistados_por_tipo(pokedex_t* pokedex, char* tipo_objetivo)
; ----------------------------------------------------
global obtener_avistados_por_tipo
obtener_avistados_por_tipo:
; registros:
	; rdi = *pokedex
	; rsi = *tipo_objetivo
    
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
    mov r13, rsi        ; r13 = *tipo_objetivo

    mov rdi, POKEMON_FILTRADOS_TAMANIO
    call malloc

    mov r15, rax        ; r15 = *pokemon_filtrados

    mov rdi, 20
    imul rdi, 2
    call malloc

    mov r14, rax        ; r14 = *ids_pokemons

    xor rbx, rbx        ; rbx = cantidad_pokemons = 0
    
    mov dword[RBP-48], 0            ; dword[RBP-48] = i = 0

.loopFilas:
    mov r8d, dword[r12 + POKEDEX_FILAS_OFFSET]
    cmp dword[RBP-48], r8d                        ; condición de corte
    je .fin

    
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

        lea rdi, qword[r8 + POKEMON_INFO_OFFSET + INFO_TIPO_OFFSET]   ; rdi = pokedex->pokemons[i][j]->info.tipo
        mov rsi, r13
        
        call strcmp

        test eax, eax
        jne .siguienteColumnas

        mov rdi, qword[r12 + POKEDEX_BITMAP_OFFSET]
        mov esi, dword[RBP-48]
        mov r8d, dword[r12 + POKEDEX_COLUMNAS_OFFSET]
        imul esi, r8d
        add esi, dword[RBP-56]

        call obtener_bit

        cmp al, 1 
        jne .siguienteColumnas

        mov r8, qword[r12 + POKEDEX_POKEMONS_OFFSET]    ; r8 = pokedex->pokemons
        
        mov r9d, dword[RBP-48]       ; r9 = i
        
        mov r8, qword[r8 + (r9*8)]    ; r8 = pokedex->pokemons[i]

        mov r10d, dword[RBP-56]       ; r10 = j

        mov r8, qword[r8 + (r10*8)]    ; r8 = pokedex->pokemons[i][j]

        mov r8w, word[r8 + POKEMON_ID_OFFSET]
        mov word[r14 + (rbx*2)], r8w

        inc ebx     ; cantidad_pokemons ++;

    .siguienteColumnas:
        inc dword[RBP-56]
        jmp .loopColumnas

.siguienteFilas:
    inc dword[RBP-48]
    jmp .loopFilas

.fin:
    mov qword[r15 + POKEMON_FILTRADOS_IDS_OFFSET], r14  
    mov dword[r15 + POKEMON_FILTRADOS_CANTIDAD_OFFSET], ebx  

    mov rax, r15        ; return pokemon_filtrados;

    ; === EPÍLOGO ===
    add rsp, 24          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret