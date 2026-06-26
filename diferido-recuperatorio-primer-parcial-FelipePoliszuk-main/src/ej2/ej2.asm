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
extern free


; VERSION CON PUNTEROS DOBLES 

; void filterPossibleDestinations(itinerary_t *itinerary, backpack_t *backpack)
global filterPossibleDestinations
filterPossibleDestinations:
; registros:
    ; rdi = itinerary
    ; rsi = backpack

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    push r14

    mov r12, rdi        ; r12 = itinerary
    mov r13, rsi        ; r13 = backpack

    lea rbx, qword[r12 + ITINERARY_FIRST_OFFSET]        ; rbx = **indirecto

.loop:
    cmp qword[rbx], 0         ; condición de corte
    je .fin

    mov r14, qword[rbx]     ; r14 (*actual) = *indirecto

    mov rdi, r13            ; rdi = backpack
    mov rsi, qword[r14 + EVENT_DESTINATION_OFFSET]       ; rsi = actual->destination
    call meetsRequirements

    test al,al
    jne .else

    mov rdi, qword[r14 + EVENT_NEXT_OFFSET]
    mov [rbx], rdi

    mov rdi, r14        ; rdi = actual 
    call free_event2
    jmp .loop

.else: 
    lea rbx, qword[r14 + EVENT_NEXT_OFFSET]        ; rbx (indirecto) = &actual->next;
    jmp .loop

.fin:    
    ; === EPÍLOGO ===
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


; VERSION CLÁSICA

; ; void filterPossibleDestinations(itinerary_t *itinerary, backpack_t *backpack)
; global filterPossibleDestinations
; filterPossibleDestinations:
; ; registros:
;     ; rdi = itinerary
;     ; rsi = backpack

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
;     mov r13, rsi        ; r13 = backpack

;     mov rbx, qword[r12 + ITINERARY_FIRST_OFFSET]        ; rbx = (*)actual

;     xor r14, r14        ; r14 = anterior = NULL

; .loop:
;     test rbx, rbx         ; condición de corte
;     jz .fin

;     mov r15, qword[rbx + EVENT_NEXT_OFFSET]      ; r15 = proximo

;     mov rdi, r13            ; rdi = backpack
;     mov rsi, qword[rbx + EVENT_DESTINATION_OFFSET]       ; rsi = actual->destination
;     call meetsRequirements

;     test al,al
;     jne .else

;     test r14, r14   
;     je .ifTrue

;     mov qword[r14 + EVENT_NEXT_OFFSET], r15      ; anterior->next = proximo
;     jmp .free


; .ifTrue:
;     mov qword[r12 + ITINERARY_FIRST_OFFSET], r15
;     jmp .free


; .free:

;     mov rdi, rbx        ; rdi = actual
;     call free_event2

;     jmp .siguiente

; .else: 
;     mov r14, rbx        ; r14 (anterior) = actual

; .siguiente:
;     mov rbx, r15          ; rbx (actual) = proximo
;     jmp .loop

; .fin:    

;     ; === EPÍLOGO ===
;     add rsp, 8          ; Deshago el alineamiento global
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbx
;     pop rbp
;     ret


; ----------- Función Auxiliar - meetsRequirements -----------

; bool meetsRequirements(backpack_t *backpack, destination_t *dest) {
global meetsRequirements
meetsRequirements:
; registros:
    ; rdi = backpack
    ; rsi = dest

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    sub rsp, 8          ; Alineamiento GLOBAL (La pila ya es segura para toda la función)

    mov r12, rdi        ; r12 = backpack
    mov r13, rsi        ; r13 = dest

    xor rbx, rbx        ; ebx = índice = 0

.loop:
    cmp ebx, dword[r13 + DESTINATION_REQUIREMENTS_SIZE_OFFSET]          ; condición de corte
    je .devuelvoTrue

    mov rdi, r12        ; rdi = backpack
    mov rsi, [r13 + DESTINATION_REQUIREMENTS_OFFSET]       ; rsi = dest->requirements

    mov esi, [rsi + (rbx*4)]        ; esi = dest->requirements[i]

    call backpackContainsItem         ; llamada a función

    cmp al, 0
    je .devuelvoFalse

.siguiente:
    inc ebx
    jmp .loop

.devuelvoTrue:
    mov rax, 1
    jmp .fin

.devuelvoFalse:
    mov rax, 0    

.fin:  
    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret



; ----------- Función Auxiliar - free_event -----------

; void free_event2(event_t *event) 
global free_event2
free_event2:
; registros:
    ; rdi = event

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    sub rsp, 8          ; Alineamiento GLOBAL (La pila ya es segura para toda la función)

    mov rbx, rdi        ; rbx = event

    mov rdi, [rbx + EVENT_DESTINATION_OFFSET]
    mov rdi, [rdi + DESTINATION_REQUIREMENTS_OFFSET]
    call free       ; free(event->destination->requirements);

    mov rdi, [rbx + EVENT_DESTINATION_OFFSET]
    call free       ; free(event->destination);

    mov rdi, rbx  
    call free       ; free(event);

.fin:  
    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop rbx
    pop rbp
    ret