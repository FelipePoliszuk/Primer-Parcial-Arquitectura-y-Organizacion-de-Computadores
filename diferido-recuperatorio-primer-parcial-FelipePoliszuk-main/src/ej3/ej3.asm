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

NULL EQU 0

extern backpackContainsItem
extern malloc

; backpack_t *prepareBackpack(itinerary_t *itinerary, uint8_t getItemWeight(item_kind_t))
global prepareBackpack 
prepareBackpack:
; registros:
    ; rdi =  *itinerary
    ; rsi = getItemWeight

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24         


    mov r12, rdi        ; r12 = itinerary
    mov r13, rsi        ; r13 = getItemWeight

    mov rdi, BACKPACK_SIZE
    call malloc

    mov rbx, rax        ; rbx = *mochila

    mov dword[rbx + BACKPACK_ITEM_COUNT_OFFSET], 0      ; mochila->item_count = 0;
    mov byte[rbx + BACKPACK_MAX_WEIGHT_OFFSET], 255     ; mochila->max_weight = 255;

    mov rdi, 8      ; rdi = sizeof(item_t)
    imul rdi, 7     ; multiplico por 7

    call malloc

    mov qword[rbx + BACKPACK_ITEMS_OFFSET], rax

    mov r14, qword[r12 + ITINERARY_FIRST_OFFSET]        ; r14 = *actual

.whileLoop:
    test r14, r14          ; condición de corte
    jz .fin

    mov r8, qword[r14 + EVENT_DESTINATION_OFFSET]                    ; r8 = actual->destination
    mov r8d, dword[r8 + DESTINATION_REQUIREMENTS_SIZE_OFFSET]       ; r8 = actual->destination->requirements_size

    mov dword[rbp-56], r8d

    xor r15, r15    ; r15 = i = 0
    
.forLoop:
    cmp r15d, dword[rbp-56]       ; condición de corte
    je .siguienteWhile
    
    mov r8, qword[r14 + EVENT_DESTINATION_OFFSET]                    ; r8 = actual->destination
    mov r8, qword[r8 + DESTINATION_REQUIREMENTS_OFFSET]   ; r8d = actual->destination->requirements
    mov r8d, dword[r8 + (r15*4)]

    mov dword[rbp-48], r8d       ; [rbp-48] = item

    mov rdi, rbx                ; rdi = mochila
    mov esi, dword[rbp-48]      ; rsi = item

    call backpackContainsItem

    test al, al     
    jz .agregarItem

    jmp .siguienteFor
    
    
.siguienteWhile:
    mov r14, qword[r14 + EVENT_NEXT_OFFSET]
    jmp .whileLoop

.agregarItem:       

    xor r8, r8  ; limpio r8
    mov r8d, dword[rbx + BACKPACK_ITEM_COUNT_OFFSET] ;    r8 = mochila->item_count    

    mov r9d, dword[rbp-48]      ; r9d = [rbp-48] = item
    mov r10, qword [rbx + BACKPACK_ITEMS_OFFSET]
    mov dword[r10 + (r8*ITEM_SIZE) + ITEM_KIND_OFFSET], r9d      ; mochila->items[mochila->item_count].kind = item;


    mov edi, dword[rbp-48]       ; edi = item
    call r13

    xor r8, r8  ; limpio r8
    mov r8d, dword[rbx + BACKPACK_ITEM_COUNT_OFFSET] ;    r8 = mochila->item_count        

    mov r10, qword[rbx + BACKPACK_ITEMS_OFFSET] 
    mov byte[r10 + (r8*ITEM_SIZE) + ITEM_WEIGHT_OFFSET], al
    

    inc dword[rbx + BACKPACK_ITEM_COUNT_OFFSET]     ; mochila->item_count ++;

.siguienteFor:
    inc r15d
    jmp .forLoop


.fin:
    mov rax, rbx    ; devuelvo *mochila    

    ; === EPÍLOGO ===
    add rsp, 24          
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret