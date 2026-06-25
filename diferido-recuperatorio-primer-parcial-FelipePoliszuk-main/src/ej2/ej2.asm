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


; void filterPossibleDestinations(itinerary_t *itinerary, backpack_t *backpack)
global filterPossibleDestinations
filterPossibleDestinations:
    ret
    







; ----------- Función Auxiliar - meetsRequirements -----------

; bool meetsRequirements(backpack_t *backpack, destination_t *dest) {
global meetsRequirements
meetsRequirements:
    ret


; ----------- Función Auxiliar - free_event -----------


; void free_event2(event_t *event) 
global free_event2
free_event2:
































; ; void filterPossibleDestinations(itinerary_t *itinerary, backpack_t *backpack)
; global filterPossibleDestinations
; filterPossibleDestinations:
; ; registros:

; ; RDI = itinerary
; ; RSI = backpack

;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp

;     ; preservar registros callee-saved 
;     push rbx   
;     push r12
;     push r13
;     push r14
;     push r15
;     sub rsp, 8          ; Alineo la pila para TODA la función

;     mov r12, rdi        ; r12 = itinerary
;     mov r13, rsi        ; r13 = backpack

;     mov r14, [r12 + ITINERARY_FIRST_OFFSET]          ; r14 = actual  
;     mov r15, 0                                       ; r15 = prev  


; .loop:
;     cmp r14, 0          ; condición de corte
;     je .fin

;     mov rbx, [r14 + EVENT_NEXT_OFFSET]          ; rbx = proximo
    
;     ;paso argumentos a meetsRequirements
    
;     mov rdi, r13        ; rdi = backpack
;     mov rsi, qword[r14 + EVENT_DESTINATION_OFFSET]        ; rsi = actual->destination

;     call meetsRequirements      ; llamo a meetsRequirements

;     cmp al, 1
;     je  .else          ; caso else

;     ; si no cumple los requisitos hay que eliminar el nodo de la LE

;     cmp r15, 0            ; prev == NULL
;     jne .else2       

;     mov [r12 + ITINERARY_FIRST_OFFSET], rbx      ; itinerary->first = proximo;
;     jmp .free

; .else2:
;     mov [r15 + EVENT_NEXT_OFFSET], rbx      ; prev->next = proximo;
;     jmp .free

; .free:
    
;     mov rdi, r14            ; rdi = actual

;     call free_event2               ; libero puntero

; .siguiente:
;     mov r14, rbx            ; actual = proximo;
;     jmp .loop

; .else:
;     mov r15, r14     ; prev = actual
;     jmp .siguiente

; .fin:   

;     ; === EPÍLOGO ===
;     add rsp, 8      ; Restauro la pila justo antes de los pop
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbx
;     pop rbp
;     ret


; ; ----------- Función Auxiliar - meetsRequirements -----------

; ; bool meetsRequirements(backpack_t *backpack, destination_t *dest) {
; global meetsRequirements
; meetsRequirements:
; ; registros:

; ; RDI = backpack
; ; RSI = dest

;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp

;     ; preservar registros callee-saved 
;     push rbx   
;     push r12
;     push r13
;     push r14
;     push r15
;     sub rsp, 8          ; Alineo la pila para TODA la función

;     mov r12, rdi        ; r12 = backpack
;     mov r13, rsi        ; r13 = dest

;     xor rbx, rbx        ; índice
;     xor r14, r14

;     mov al, 1          ; seteo true valor predeterminado

; .loop:
;     cmp ebx, dword[r13 + DESTINATION_REQUIREMENTS_SIZE_OFFSET]          ; condición de corte
;     je .fin

;     ; mov r14, [r13 + DESTINATION_REQUIREMENTS_OFFSET + (rbx*4)]           ; dest->requirements[i]   mal mal mal
    
;     mov r8, [r13 + DESTINATION_REQUIREMENTS_OFFSET]           ; r8 = dest->requirements
;     mov r14d, dword[r8 + (rbx*4)]                       ; r14 = dest->requirements[i]
    
;     ;paso argumentos a backpackContainsItem

;     mov rdi, r12            ; rdi = backpack
;     mov esi, r14d            ; rsi = dest->requirements[i]

;     call backpackContainsItem            ; llamada a función

;     cmp al, 0 
;     je  .devuelvoFalse          ; devuelvo false 


; .siguiente:
;     inc rbx
;     jmp .loop

; .devuelvoTrue:
;     mov al, 1    
;     jmp .fin 

; .devuelvoFalse:
;     mov al, 0 

; .fin:     
;     ; === EPÍLOGO ===
;     add rsp, 8      ; Restauro la pila justo antes de los pop
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbx
;     pop rbp
;     ret



; ; ----------- Función Auxiliar - free_event -----------


; ; void free_event2(event_t *event) 
; global free_event2
; free_event2:
; ; registros:

; ; RDI = event

;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp

;     ; preservar registros callee-saved 
;     push rbx   
;     push r12
;     push r13
;     push r14
;     push r15
;     sub rsp, 8          ; Alineo la pila para TODA la función

;     mov r12, rdi        ; r12 = event

;     mov r8, [r12 + EVENT_DESTINATION_OFFSET]       ; r8 = event->destination
;     mov rdi, [r8 + DESTINATION_REQUIREMENTS_OFFSET] ; rdi = event->destination->requirements 
;     call free

;     mov rdi, [r12 + EVENT_DESTINATION_OFFSET]       ; rdi = event->destination
;     call free

;     mov rdi, r12                                    ; rdi = event
;     call free


; .fin:     
;     ; === EPÍLOGO ===
;     add rsp, 8      ; Restauro la pila justo antes de los pop
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbx
;     pop rbp
;     ret    