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

NULL EQU 0

extern backpackContainsItem
extern malloc

; backpack_t *prepareBackpack(itinerary_t *itinerary, uint8_t getItemWeight(item_kind_t))
global prepareBackpack 
prepareBackpack:
; registros:
	; rdi = *itinerary
	; rsi =  getItemWeight
    
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
    
    mov r12, rdi        ; r12 = *itinerary
    mov r13, rsi        ; r13 =  getItemWeight

    mov rdi, BACKPACK_SIZE
    call malloc

    mov r15, rax        ; r15 = *mochila

    mov dword[r15 + BACKPACK_ITEM_COUNT_OFFSET], 0      ; mochila->item_count = 0;
    mov byte[r15 + BACKPACK_MAX_WEIGHT_OFFSET], 255     ; mochila->max_weight = 255;

    mov rdi, ITEM_SIZE*7
    call malloc

    mov qword[r15 + BACKPACK_ITEMS_OFFSET], rax     ; mochila->items = malloc(sizeof(item_t)*7); 

    mov rbx, qword[r12 + ITINERARY_FIRST_OFFSET]    ; rbx = actual

.whileLoop:
    cmp rbx, 0          ; condición de corte
    je .fin


    xor r14, r14        ; r14d = i = 0
    .forLoop:
        mov r8, qword[rbx + EVENT_DESTINATION_OFFSET]      
        cmp r14d, dword[r8 + DESTINATION_REQUIREMENTS_SIZE_OFFSET]   
        je .siguienteWhile
        
        ; r12 = item (antes: itinerary)
        mov r12, qword[rbx + EVENT_DESTINATION_OFFSET]
        mov r12, qword[r12 + DESTINATION_REQUIREMENTS_OFFSET]
        mov r12d, dword[r12 + (r14*4)]
        
        mov rdi, r15        ; mochila
        mov esi, r12d       ; item

        call backpackContainsItem

        test al, al
        jnz .siguienteFor

        mov r8d, dword[r15 + BACKPACK_ITEM_COUNT_OFFSET]    ; r8d = mochila->item_count

        mov r9, qword[r15 + BACKPACK_ITEMS_OFFSET]         ; mochila->items
        mov dword[r9 + (r8*8) + ITEM_KIND_OFFSET], r12d    ; mochila->items[mochila->item_count].kind = item;

        mov edi, r12d
        call r13

        mov r8d, dword[r15 + BACKPACK_ITEM_COUNT_OFFSET]    ; r8d = mochila->item_count
        mov r9, qword[r15 + BACKPACK_ITEMS_OFFSET]         ; mochila->items
        mov byte[r9 + (r8*8) + ITEM_WEIGHT_OFFSET], al    ; mochila->items[mochila->item_count].weight = item;

        inc dword[r15 + BACKPACK_ITEM_COUNT_OFFSET]

    .siguienteFor:
        inc r14d
        jmp .forLoop

.siguienteWhile:
    mov rbx, qword[rbx + EVENT_NEXT_OFFSET]     ; actual = actual->next;
    jmp .whileLoop

.fin:
    mov rax, r15        ; return mochila;

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret





























; ; backpack_t *prepareBackpack(itinerary_t *itinerary, uint8_t getItemWeight(item_kind_t))
; global prepareBackpack 
; prepareBackpack:
; ; registros:
; 	; rdi = *itinerary
; 	; rsi = *getItemWeight
    
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

;     mov r12, qword[rdi + ITINERARY_FIRST_OFFSET]     ; r12 = *actual
;     mov qword[RBP-48], rsi                           ; [RBP-48] = *getItemWeight

;     mov rdi, BACKPACK_SIZE
;     call malloc

;     mov rbx, rax            ; rbx = *mochila

;     mov dword[rbx + BACKPACK_ITEM_COUNT_OFFSET], 0      ; mochila->item_count = 0;
;     mov byte[rbx + BACKPACK_MAX_WEIGHT_OFFSET], 255     ; mochila->max_weight = 255;

;     mov rdi, ITEM_SIZE
;     imul rdi, 7
;     call malloc

;     mov qword[rbx + BACKPACK_ITEMS_OFFSET], rax     ; mochila->items = malloc(sizeof(item_t)*7); 

; .whileLoop:
;     test r12, r12          ; condición de corte
;     jz .fin

;     mov r15, qword[r12 + EVENT_DESTINATION_OFFSET]                ;        actual->destination
;     mov r15d, dword[r15 + DESTINATION_REQUIREMENTS_SIZE_OFFSET]   ; r15d = actual->destination->requirements_size

;     xor r14, r14           ; r14d = indice = 0 
;     .forLoop:
;         cmp r14d, r15d
;         je .siguienteWhile

;         mov rdi, rbx    

;         mov rsi, qword[r12 + EVENT_DESTINATION_OFFSET]          ; actual->destination
;         mov rsi, qword[rsi + DESTINATION_REQUIREMENTS_OFFSET]   ; actual->destination->requirements
;         mov esi, dword[rsi + (r14*4)]        ; rsi = actual->destination->requirements[i]
;         mov r13d, esi                        ; r13d = actual->destination->requirements[i]

;         call backpackContainsItem

;         test al, al
;         jnz .siguienteFor

;         mov r9d, dword[rbx + BACKPACK_ITEM_COUNT_OFFSET]  ; r9d = mochila->item_count
;         mov r8, qword[rbx + BACKPACK_ITEMS_OFFSET]        ; r8 = mochila->items

;         mov edi, r13d       ; edi = item

;         mov dword[r8 + (r9*ITEM_SIZE) + ITEM_KIND_OFFSET], edi      ; mochila->items[mochila->item_count].kind = item;

;         call qword[RBP-48]  ; getItemWeight(item)

;         mov r9d, dword[rbx + BACKPACK_ITEM_COUNT_OFFSET]  ; r9d = mochila->item_count
;         mov r8, qword[rbx + BACKPACK_ITEMS_OFFSET]        ; r8 = mochila->items        

;         mov byte[r8 + (r9*ITEM_SIZE) + ITEM_WEIGHT_OFFSET], al      ; mochila->items[mochila->item_count].weight = getItemWeight(item);

;         inc dword[rbx + BACKPACK_ITEM_COUNT_OFFSET]     ;  mochila->item_count++;

;     .siguienteFor:
;         inc r14d
;         jmp .forLoop

; .siguienteWhile:
;     mov r12, qword[r12 + EVENT_NEXT_OFFSET]
;     jmp .whileLoop

; .fin:
;     mov rax, rbx        ; return mochila;

;     ; === EPÍLOGO ===
;     add rsp, 8          ; Deshago el alineamiento global
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbx
;     pop rbp
;     ret