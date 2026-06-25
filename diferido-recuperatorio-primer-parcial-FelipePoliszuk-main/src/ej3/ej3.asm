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
    ret



















; ; backpack_t *prepareBackpack(itinerary_t *itinerary, uint8_t getItemWeight(item_kind_t))
; global prepareBackpack 
; prepareBackpack:
    
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

;     mov r12, rdi        ; r12 = itinerary
;     mov r13, rsi        ; r13 = getItemWeight       ; ver si hay que usar  un byte nada mas


;     mov rdi, BACKPACK_SIZE
;     call malloc     

;     mov rbx, rax        ; rbx = mochila
    
;     mov r8, ITEM_SIZE
;     imul r8, 7
;     mov rdi, r8
;     call malloc

;     mov [rbx + BACKPACK_ITEMS_OFFSET], rax  ; mochila->items = malloc(sizeof(item_t) * 7);

;     mov byte[rbx + BACKPACK_MAX_WEIGHT_OFFSET], 255    ; mochila->max_weight = 255;

;     mov dword[rbx + BACKPACK_ITEM_COUNT_OFFSET], 0      ; mochila->item_count = 0;

;     mov r14, [r12 + ITINERARY_FIRST_OFFSET]         ; r14 = actual

; .loopWhile: ;while
;     cmp r14, 0          ; condición de corte
;     je .fin

;     mov r15, [r14 + EVENT_NEXT_OFFSET]          ; r15 = proximo

; ; -------

;     xor r8, r8          ; r8 = indice = 0

; .loopFor:
;     mov r11, [r14 + EVENT_DESTINATION_OFFSET]   ; r11 = actual->destination
;     cmp r8d, dword[r11 + DESTINATION_REQUIREMENTS_SIZE_OFFSET]          ; condición de corte
;     je .siguienteWhile    

;     mov r10, [r11 + DESTINATION_REQUIREMENTS_OFFSET]  ; r10 = actual->destination->requirements
    
;     mov r9d, dword[r10 + r8*4]    ; r9 = item = actual->destination->requirements[i] 

;     push r8
;     push r9     ; o sub rsp, 8

;     ;preparo argumentos
;     mov rdi, rbx    ; rdi = mochila
;     mov rsi, r9     ; rsi = item
;     call backpackContainsItem
;     pop r9      ; o add rsp, 8
;     pop r8

;     cmp al, 1
;     je .siguienteFor

;     mov r10d, dword[rbx + BACKPACK_ITEM_COUNT_OFFSET]            ; r10 = mochila->item_count
    
;     mov r11, qword[rbx + BACKPACK_ITEMS_OFFSET]        ;r11 = mochila->items


;     mov dword[r11 + r10*ITEM_SIZE + ITEM_KIND_OFFSET], r9d       ; mochila->items[mochila->item_count].kind = item;

;     push r8
;     push r9     ; o sub rsp, 8
;     ;preparo argumento
;     mov rdi, r9     ; rdi = item
;     call r13
;     pop r9      ; o add rsp, 8
;     pop r8


;     mov r10d, dword[rbx + BACKPACK_ITEM_COUNT_OFFSET]            ; r10 = mochila->item_count
;     mov r11, [rbx + BACKPACK_ITEMS_OFFSET]                    ;r11 = mochila->items
;     mov byte[r11 + r10 *8 + ITEM_WEIGHT_OFFSET], al     ; mochila->items[mochila->item_count].weight = getItemWeight(item);


;     inc dword[rbx + BACKPACK_ITEM_COUNT_OFFSET]         ; mochila->item_count ++;

; .siguienteFor: 
;     inc r8            ; r8 ++
;     jmp .loopFor

; ; -------

; .siguienteWhile:
;     mov r14, r15            ; actual = proximo;
;     jmp .loopWhile

; .fin:
;     ; valor de retorno
;     mov rax, rbx            ; devuelvo mochila en rax

;     ; === EPÍLOGO ===
;     add rsp, 8          ; Deshago el alineamiento global
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbx
;     pop rbp
;     ret
