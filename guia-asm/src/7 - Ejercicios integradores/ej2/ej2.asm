extern malloc
extern free
extern strcpy

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - optimizar
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ATTACKUNIT_CLASE EQU 0
ATTACKUNIT_COMBUSTIBLE EQU 12
ATTACKUNIT_REFERENCES EQU 14
ATTACKUNIT_SIZE EQU 16


; void optimizar(mapa_t mapa, attackunit_t* compartida, uint32_t (*fun_hash)(attackunit_t*));

; registros
; mapa = rdi
; compartida = rsi
; fun_hash  = rdx

global optimizar
optimizar:
    ; mapa = rdi
    ; compartida = rsi
    ; fun_hash = rdx

    ; prologo
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi        ; r12 = mapa
    mov r13, rsi        ; r13 = compartida
    mov r14, rdx        ; r14 = fun_hash

    ; calcular hash(compartida) UNA vez
    mov rdi, r13
    call r14
    mov r15d, eax       ; r15d = hash_compartida

    xor r11, r11        ; r11 = contador total de referencias
    xor r10, r10        ; r10 = índice lineal (i)

.loop:
    cmp r10, 255*255
    je .fin

    mov r9, [r12 + r10*8]   ; r9 = mapa[i]
    cmp r9, FALSE
    je .siguiente

    cmp r9, r13
    je .ya_es_compartida

    ; --- llamar hash(current) preservando temporales ---
    ; guardo temporales que quiero mantener (R11, R10, R9)
    push r9
    push r10
    push r11
    sub rsp, 8        ; mantener alineamiento antes del CALL (3 pushes -> +24, faltan 8)
    mov rdi, r9
    call r14
    add rsp, 8
    pop r11
    pop r10
    pop r9
    mov r8d, eax      ; hash_current

    cmp r8d, r15d
    jne .siguiente

    ; coincidencia: sumo al contador total
    inc r11
    
    ; verificar si references == 1 para decidir si hacer free
    movzx rax, byte [r9 + ATTACKUNIT_REFERENCES]  ; cargar references de la unidad actual
    cmp al, 1
    je .free
    jmp .no_free

.free:
    ; si references == 1, llamar free y luego asignar compartida
    push r9
    push r10
    push r11
    sub rsp, 8        ; mantener alineamiento para call
    mov rdi, r9       ; argumento para free
    call free
    add rsp, 8
    pop r11
    pop r10
    pop r9
    jmp .asignar_compartida

.no_free:
    ; si references > 1, decrementar references
    dec byte [r9 + ATTACKUNIT_REFERENCES]

.asignar_compartida:
    ; asigno compartida en el mapa
    mov [r12 + r10*8], r13
    jmp .siguiente

.ya_es_compartida:
    ; si la celda ya apuntaba a compartida, también la contamos
    inc r11
    jmp .siguiente

.siguiente:
    inc r10
    jmp .loop

.fin:
    ; al final escribimos el total en compartida->references
    mov [r13 + ATTACKUNIT_REFERENCES], r11b

    ; epilogo
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


; uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char*));

global contarCombustibleAsignado
contarCombustibleAsignado:
; ; registros
; ; mapa = rdi
; ; fun_combustible(char*) = rsi

    ; prologo
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi        ; r12 = mapa
    mov r13, rsi        ; r13 = fun_combustible(char*)

    xor r14, r14        ; r14 = 0 - índice 
    xor r15, r15        ; r15 = 0 - acumulador 

.loop:
    cmp r14, 255*255
    je .fin

    mov r8, [r12 + r14*8]       ;r8 = mapa[i]
    cmp r8, FALSE               ; si r8 == Null salto a siguiente
    je .siguiente

    push r8
    push r9
    push r10
    push r11

    lea rdi, [r8 + ATTACKUNIT_CLASE]   ;rdi = mapa[i].clase
    call r13

    pop r11
    pop r10
    pop r9
    pop r8

    
    mov r10w, ax         ; r10w = combustible base

    mov r9w, [r8 + ATTACKUNIT_COMBUSTIBLE]  ;r9 =  mapa[i].combustible

    sub r9w, r10w

    add r15w, r9w

    jmp .siguiente


.siguiente:
    inc r14                 ; incremento r14
    jmp .loop

.fin:
    xor rax, rax             ; limpio rax
    mov eax, r15d            ;devuelvo combustible asignado en eax

    ; epilogo
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret




; void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (modificar_t)(attackunit_t));
global modificarUnidad
modificarUnidad:
; registros:

; mapa = rdi            //64 bits       rdi
; x = rsi               //8 bits        sil
; y = rdx               //8 bits        dl
; fun_modificar = rcx   //64 bits       rcx

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved si los vas a usar
    push r12
    push r13
    push r14
    push r15



    mov r12, rdi                       ;r12 = mapa
    mov r14, rcx                       ;r14 = funcion
    
    ; calculo offset x,y

    movzx eax, sil                      ; eax = x (zero-extend 8 → 32 bits)
    imul eax, eax, 255                  ; eax = x * 255
    movzx edx, dl                       ; edx = y (zero-extend 8 → 32 bits)
    add eax, edx                        ; eax = x*255 + y
    imul rax, rax, 8                    ; rax = (x*255 + y) * 8


    mov r13, [r12 + rax]                ;r13 = mapa[x][y]


    cmp r13, FALSE                      ; si el puntero r13 == null devuelvo funcion
    je .fin

    cmp byte [r13 + ATTACKUNIT_REFERENCES], 1    ;chequeo si mapa[x][y].references == 1
    je .fun_modificar2


    sub byte [r13+ATTACKUNIT_REFERENCES], 1     ;mapa[x][y].references -= 1



    ;llamado a malloc para hacer la copia 
    push r8                             ; si necesitás guardar valores caller-saved
    push r9 
    push rax 
    sub rsp, 8                          ; mantener alineamiento 16 bytes
    mov rdi, ATTACKUNIT_SIZE                         ; pasar argumento
    call malloc                            ; llamada a función
    mov r15, rax                ;guardo el puntero que me devuelve malloc en r15
    add rsp, 8
    pop rax
    pop r9
    pop r8

    

    ;copio combustible
    xor r9, r9
    mov r9w, word[r13 + ATTACKUNIT_COMBUSTIBLE]

    mov word[r15 + ATTACKUNIT_COMBUSTIBLE], r9w

    ;asigno r15.references = 1

    mov byte [r15 + ATTACKUNIT_REFERENCES], 1



    ;llamo a strcpy
    push r8 
    push r9 
    push rax                                             ; si necesitás guardar valores caller-saved
    sub rsp, 8                                          ; mantener alineamiento 16 bytes
    lea rdi, [r15 + ATTACKUNIT_CLASE]                ; pasar argumento           
    lea rsi, [r13 + ATTACKUNIT_CLASE]               ; pasar argumento           
    call strcpy                                            ; llamada a función
    add rsp, 8
    pop rax
    pop r9
    pop r8

    ; actualizo el mapa

   mov [r12 + rax], r15   ; guarda el puntero individual en mapa[x][y]      -  mapa[x][y] = individual;
     
.fun_modificar:
    ;llamo a fun_modificar de mapa[x][y]
    push r8 
    push r9 
    push rax                             ; si necesitás guardar valores caller-saved
    sub rsp, 8                          ; mantener alineamiento 16 bytes
    mov rdi, r15                         ; pasar argumento
    call r14                            ; llamada a función
    add rsp, 8
    pop rax
    pop r9
    pop r8

    jmp .fin

.fun_modificar2:
    ;llamo a fun_modificar de mapa[x][y]
    push r8 
    push r9 
    push rax                             ; si necesitás guardar valores caller-saved
    sub rsp, 8                          ; mantener alineamiento 16 bytes
    mov rdi, r13                         ; pasar argumento
    call r14                            ; llamada a función
    add rsp, 8
    pop rax
    pop r9
    pop r8

    jmp .fin    


.fin:
    ; === EPÍLOGO ===
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


; otra forma:

; ; void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (modificar_t)(attackunit_t));
; global modificarUnidad
; modificarUnidad:
; ; registros:

; ; mapa = rdi            //64 bits       rdi
; ; x = rsi               //8 bits        sil
; ; y = rdx               //8 bits        dl
; ; fun_modificar = rcx   //64 bits       rcx

;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp

;     ; preservar registros callee-saved si los vas a usar
;     push r12
;     push r13
;     push r14
;     push r15



;     mov r12, rdi                       ;r12 = mapa
;     mov r14, rcx                       ;r14 = funcion
    
;     ; calculo offset x,y

;     movzx eax, sil                      ; eax = x (zero-extend 8 → 32 bits)
;     imul eax, eax, 255                  ; eax = x * 255
;     movzx edx, dl                       ; edx = y (zero-extend 8 → 32 bits)
;     add eax, edx                        ; eax = x*255 + y
;     imul rax, rax, 8                    ; rax = (x*255 + y) * 8


;     mov r13, [r12 + rax]                ;r13 = mapa[x][y]


;     cmp r13, FALSE                      ; si el puntero r13 == null devuelvo funcion
;     je .fin

;     cmp byte [r13 + ATTACKUNIT_REFERENCES], 1    ;chequeo si mapa[x][y].references == 1
;     je .fun_modificar2


;     sub byte [r13+ATTACKUNIT_REFERENCES], 1     ;mapa[x][y].references -= 1



;     ;llamado a malloc para hacer la copia 
;     push rax                            ; guardar offset (rax = offset calculado)
;     push r9 
;     push r8                             ; si necesitás guardar valores caller-saved
;     sub rsp, 8                          ; mantener alineamiento 16 bytes
;     mov rdi, ATTACKUNIT_SIZE            ; pasar argumento
;     call malloc                         ; rax ahora = puntero de malloc
;     add rsp, 8
;     pop r8                              ; orden inverso al push
;     pop r9
    
;     mov r15, rax                        ; r15 = puntero de malloc
;     pop rax                             ; rax = offset original (recuperado del stack)

;     ;copio combustible
;     xor r9, r9
;     mov r9w, word[r13 + ATTACKUNIT_COMBUSTIBLE]

;     mov word[r15 + ATTACKUNIT_COMBUSTIBLE], r9w

;     ;asigno r15.references = 1

;     mov byte [r15 + ATTACKUNIT_REFERENCES], 1



;     ;llamo a strcpy
;     push rax                            ; guardar offset
;     push r9 
;     push r8                             ; si necesitás guardar valores caller-saved
;     sub rsp, 8                          ; mantener alineamiento 16 bytes
;     lea rdi, [r15 + ATTACKUNIT_CLASE]   ; pasar argumento (destino)
;     lea rsi, [r13 + ATTACKUNIT_CLASE]   ; pasar argumento (origen)
;     call strcpy                         ; llamada a función
;     add rsp, 8
;     pop r8                              ; orden inverso al push
;     pop r9
;     pop rax                             ; recuperar offset

;     ; actualizo el mapa

;    mov [r12 + rax], r15   ; guarda el puntero individual en mapa[x][y]      -  mapa[x][y] = individual;
     
; .fun_modificar:
;     ;llamo a fun_modificar de mapa[x][y] (nueva unidad)
;     push rax                            ; guardar offset (aunque no lo necesitemos después)
;     push r9 
;     push r8                             ; si necesitás guardar valores caller-saved
;     sub rsp, 8                          ; mantener alineamiento 16 bytes
;     mov rdi, r15                        ; pasar argumento (nueva unidad)
;     call r14                            ; llamada a función
;     add rsp, 8
;     pop r8                              ; orden inverso al push
;     pop r9
;     pop rax

;     jmp .fin

; .fun_modificar2:
;     ;llamo a fun_modificar de mapa[x][y] (unidad original, references == 1)
;     push rax                            ; guardar offset (aunque no lo necesitemos después)
;     push r9 
;     push r8                             ; si necesitás guardar valores caller-saved
;     sub rsp, 8                          ; mantener alineamiento 16 bytes
;     mov rdi, r13                        ; pasar argumento (unidad original)
;     call r14                            ; llamada a función
;     add rsp, 8
;     pop r8                              ; orden inverso al push
;     pop r9
;     pop rax

;     jmp .fin


; .fin:
;     ; === EPÍLOGO ===
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbp
;     ret



; funciona perfecto:

; ; void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (modificar_t)(attackunit_t));
; global modificarUnidad
; modificarUnidad:
; ; registros:

; ; mapa = rdi            //64 bits       rdi
; ; x = rsi               //8 bits        sil
; ; y = rdx               //8 bits        dl
; ; fun_modificar = rcx   //64 bits       rcx

;     ; === PRÓLOGO ===
;     push rbp
;     mov rbp, rsp

;     ; preservar registros callee-saved si los vas a usar
;     push r12
;     push r13
;     push r14
;     push r15



;     mov r12, rdi                       ;r12 = mapa
;     mov r14, rcx                       ;r14 = funcion
    
;     ; calculo offset x,y
;     movzx eax, sil                      ; eax = x (zero-extend 8 → 32 bits)
;     imul eax, eax, 255                  ; eax = x * 255
;     movzx edx, dl                       ; edx = y (zero-extend 8 → 32 bits)
;     add eax, edx                        ; eax = x*255 + y
;     imul rax, rax, 8                    ; rax = (x*255 + y) * 8
;     mov r15, rax                        ; r15 = offset (guardamos para usar después)

;     mov r13, [r12 + r15]                ;r13 = mapa[x][y]


;     cmp r13, FALSE                      ; si el puntero r13 == null devuelvo funcion
;     je .fin

;     cmp byte [r13 + ATTACKUNIT_REFERENCES], 1    ;chequeo si mapa[x][y].references == 1
;     je .fun_modificar2


;     sub byte [r13+ATTACKUNIT_REFERENCES], 1     ;mapa[x][y].references -= 1



;     ;llamado a malloc para hacer la copia 
;     push r8                             ; si necesitás guardar valores caller-saved
;     sub rsp, 8                          ; mantener alineamiento 16 bytes
;     mov rdi, ATTACKUNIT_SIZE            ; pasar argumento
;     call malloc                         ; llamada a función
;     add rsp, 8
;     pop r8

;     push rax                            ; guardamos el puntero de malloc en el stack

;     ;copio combustible
;     mov r9w, word[r13 + ATTACKUNIT_COMBUSTIBLE]
;     mov word[rax + ATTACKUNIT_COMBUSTIBLE], r9w

;     ;asigno references = 1
;     mov byte [rax + ATTACKUNIT_REFERENCES], 1

;     ;llamo a strcpy
;     push r8                             ; si necesitás guardar valores caller-saved
;     sub rsp, 8                          ; mantener alineamiento 16 bytes
;     lea rdi, [rax + ATTACKUNIT_CLASE]   ; destino: nueva unidad
;     lea rsi, [r13 + ATTACKUNIT_CLASE]   ; origen: unidad original
;     call strcpy                         ; llamada a función
;     add rsp, 8
;     pop r8

;     pop rax                             ; recuperamos el puntero de malloc
;     ; actualizo el mapa
;     mov [r12 + r15], rax                ; mapa[x][y] = nueva_unidad (usando offset guardado)
     
;     ;llamo a fun_modificar de la nueva unidad
;     push r8                             ; si necesitás guardar valores caller-saved
;     sub rsp, 8                          ; mantener alineamiento 16 bytes
;     mov rdi, rax                        ; pasar la nueva unidad como argumento
;     call r14                            ; llamada a función
;     add rsp, 8
;     pop r8

;     jmp .fin

; .fun_modificar2:
;     ;llamo a fun_modificar de mapa[x][y] (references == 1, modificación in-place)
;     push r8                             ; si necesitás guardar valores caller-saved
;     sub rsp, 8                          ; mantener alineamiento 16 bytes
;     mov rdi, r13                        ; pasar argumento (unidad original)
;     call r14                            ; llamada a función
;     add rsp, 8
;     pop r8

;     jmp .fin


; .fin:
;     ; === EPÍLOGO ===
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbp
;     ret
