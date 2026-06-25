;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_KIND_OFFSET EQU 0 
ITEM_WEIGHT_OFFSET EQU 4

ITEM_SIZE EQU 8

BACKPACK_ITEMS_OFFSET EQU 0 
BACKPACK_MAX_WEIGHT_OFFSET EQU 8
BACKPACK_ITEM_COUNT_OFFSET EQU 12

BACKPACK_SIZE EQU 16

DESTINATION_NAME_OFFSET EQU 0 
DESTINATION_REQUIREMENTS_OFFSET EQU 32 
DESTINATION_REQUIREMENTS_SIZE_OFFSET EQU 40 

DESTINATION_SIZE EQU 48

EVENT_NEXT_OFFSET EQU 0 
EVENT_DESTINATION_OFFSET EQU 8

EVENT_SIZE EQU 16

ITINERARY_FIRST_OFFSET EQU 0 

ITINERARY_SIZE EQU 8

; bool canItemFitInBackpack(backpack_t *backpack, item_t *item)
global canItemFitInBackpack
canItemFitInBackpack:
    ; registros:
    ; rdi = backpack
    ; rsi = item

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp
    
    xor r8, r8        ; r8b = pesoMochila = 0
    xor r9, r9        ; r9 = indice = 0

    mov r11, [rdi + BACKPACK_ITEMS_OFFSET]             ; r11 = backpack->items

.loop:
    cmp r9d, dword[rdi + BACKPACK_ITEM_COUNT_OFFSET]          ; condición de corte
    je .sigo

    mov r10b, [r11 + (r9*ITEM_SIZE) + ITEM_WEIGHT_OFFSET]     ; r10b = backpack->items[i].weight

    add r8b, r10b

.siguiente:
    inc r9d
    jmp .loop

.sigo:
    
    add r8b, byte[rsi + ITEM_WEIGHT_OFFSET]         ; (pesoMochila + item->weight)
    cmp r8b, byte[rdi + BACKPACK_MAX_WEIGHT_OFFSET] ; (pesoMochila + item->weight) > backpack->max_weight)
    jg .devuelvoFalse

.devuelvoTrue:
    mov rax, 1
    jmp .fin    

.devuelvoFalse:
    mov rax, 0
    
.fin:
    ; === EPÍLOGO ===
    pop rbp
    ret