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

    xor r8, r8        ; r8d = índice = 0
    xor r9, r9        ; r9  = peso = 0

    mov r11d, dword[rdi + BACKPACK_ITEM_COUNT_OFFSET]   ; r11 = backpack->item_count

.loop:
    cmp r8d, r11d          ; condición de corte
    je .comparo

    mov r10, qword[rdi + BACKPACK_ITEMS_OFFSET]
    movzx r10, byte[r10 + (r8*ITEM_SIZE) + ITEM_WEIGHT_OFFSET]

    add r9, r10     ; peso += backpack->items[i].weight;

.siguiente:
    inc r8d
    jmp .loop

.comparo:
    movzx r10, byte[rsi + ITEM_WEIGHT_OFFSET]   

    add r9, r10         ; peso + item->weight


    movzx rax, byte[rdi + BACKPACK_MAX_WEIGHT_OFFSET]     
    cmp r9, rax

    ja .retFalse

.retTrue:
    mov rax, 1      ; return true;
    jmp .fin

.retFalse:
    xor rax, rax    ; return false;    

.fin:
    ; === EPÍLOGO ===
    pop rbp
    ret