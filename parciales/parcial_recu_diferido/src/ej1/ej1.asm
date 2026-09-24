;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_KIND_OFFSET EQU 0 
ITEM_WEIGHT_OFFSET EQU 4
; ; -----------------------------
ITEM_SIZE EQU 8

BACKPACK_ITEMS_OFFSET EQU 0 
BACKPACK_MAX_WEIGHT_OFFSET EQU 8
BACKPACK_ITEM_COUNT_OFFSET EQU 12
; ; -----------------------------
BACKPACK_SIZE EQU 16

DESTINATION_NAME_OFFSET EQU 0 
DESTINATION_REQUIREMENTS_OFFSET EQU 32 
DESTINATION_REQUIREMENTS_SIZE_OFFSET EQU 40 
; ; -----------------------------
DESTINATION_SIZE EQU 48

EVENT_NEXT_OFFSET EQU 0 
EVENT_DESTINATION_OFFSET EQU 8
; ; -----------------------------
EVENT_SIZE EQU 16

ITINERARY_FIRST_OFFSET EQU 0 
; ; -----------------------------
ITINERARY_SIZE EQU 8


; bool canItemFitInBackpack(backpack_t *backpack, item_t *item)
global canItemFitInBackpack
canItemFitInBackpack:
; registros:
	; rdi = *backpack
	; rsi = *item

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp
    
    xor r8, r8          ; r8 = pesoMochila = 0

    mov r9d, dword[rdi + BACKPACK_ITEM_COUNT_OFFSET]    ; r9d = backpack->item_count
    xor r10, r10                                        ; r10d = indice = 0

    mov r11, qword[rdi + BACKPACK_ITEMS_OFFSET]                   ; r10 = backpack->items

.loop:
    cmp r10d, r9d          ; condición de corte
    jz .if
    
    movzx rcx, byte[r11 + (r10*ITEM_SIZE) + ITEM_WEIGHT_OFFSET]
    add r8, rcx

.siguiente:
    inc r10d
    jmp .loop

.if:    
    movzx rcx, byte[rsi + ITEM_WEIGHT_OFFSET]
    add r8, rcx                                         ; pesoMochila + item->weight (seguro contra overflow)
    
    movzx rax, byte[rdi + BACKPACK_MAX_WEIGHT_OFFSET]     
    cmp r8, rax                                         ; comparo 64 bits contra 64 bits
    jbe .devuelvoTrue

.devuelvoFalse:
    mov rax, 0      ; return false;
    jmp .fin

.devuelvoTrue:
    mov rax, 1      ; return true;

.fin:
    ; === EPÍLOGO ===
    pop rbp
    ret