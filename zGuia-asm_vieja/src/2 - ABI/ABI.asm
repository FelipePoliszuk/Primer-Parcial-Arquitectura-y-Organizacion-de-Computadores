extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_using_c
global alternate_sum_4_using_c_alternative
global alternate_sum_8
global product_2_f
global product_9_f

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4:
  sub EDI, ESI
  add EDI, EDX
  sub EDI, ECX

  mov EAX, EDI
  ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4_using_c:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  push R12
  push R13	; preservo no volatiles, al ser 2 la pila queda alineada

  mov R12D, EDX ; guardo los parámetros x3 y x4 ya que están en registros volátiles
  mov R13D, ECX ; y tienen que sobrevivir al llamado a función

  call restar_c 
  ;recibe los parámetros por EDI y ESI, de acuerdo a la convención, y resulta que ya tenemos los valores en esos registros
  
  mov EDI, EAX ;tomamos el resultado del llamado anterior y lo pasamos como primer parámetro
  mov ESI, R12D
  call sumar_c

  mov EDI, EAX
  mov ESI, R13D
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  pop R13 ;restauramos los registros no volátiles
  pop R12
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


alternate_sum_4_using_c_alternative:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  sub RSP, 16 ; muevo el tope de la pila 8 bytes para guardar x4, y 8 bytes para que quede alineada

  mov [RBP-8], RCX ; guardo x4 en la pila

  push RDX  ;preservo x3 en la pila, desalineandola
  sub RSP, 8 ;alineo
  call restar_c 
  add RSP, 8 ;restauro tope
  pop RDX ;recupero x3
  
  mov EDI, EAX
  mov ESI, EDX
  call sumar_c

  mov EDI, EAX
  mov ESI, [RBP - 8] ;leo x4 de la pila
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  add RSP, 16 ;restauro tope de pila
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret

; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4,
;                          uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; x1 -> EDI 
; x2 -> ESI
; x3 -> EDX
; x4 -> ECX
; x5 -> R8D
; x6 -> R9D
; x7, x8 en pila (caller)

; alternate_sum_8:
;     ; PRÓLOGO
;     push RBP
;     mov  RBP, RSP
;     push R12
;     push R13
;     push R14
;     push R15

;     ; reservamos 16 bytes para locals (alineado)
;     sub  RSP, 16        ; espacio para guardar x7,x8 (2 * 8 bytes)

;     ; guardamos parámetros volátiles en no-volátiles
;     mov  R12D, EDX      ; x3
;     mov  R13D, ECX      ; x4
;     mov  R14D, R8D      ; x5
;     mov  R15D, R9D      ; x6

;     ; guardamos x7,x8 en los locals (usamos qword stores por simplicidad)
;     mov  EAX, dword [RBP+16]    ; x7 (leer desde stack de caller)
;     mov  dword [RBP-8], EAX
;     mov  EAX, dword [RBP+24]    ; x8
;     mov  dword [RBP-16], EAX

;     ; CUERPO
;     call restar_c               ; result = x1 - x2

;     mov  EDI, EAX
;     mov  ESI, R12D
;     call sumar_c                ; result += x3

;     mov  EDI, EAX
;     mov  ESI, R13D
;     call restar_c               ; result -= x4

;     mov  EDI, EAX
;     mov  ESI, R14D
;     call sumar_c                ; result += x5

;     mov  EDI, EAX
;     mov  ESI, R15D
;     call restar_c               ; result -= x6

;     mov  EDI, EAX
;     mov  ESI, dword [RBP-8]     ; x7 desde local
;     call sumar_c                ; result += x7

;     mov  EDI, EAX
;     mov  ESI, dword [RBP-16]    ; x8 desde local
;     call restar_c               ; result -= x8

;     ; EAX contiene el resultado

;     ; EPÍLOGO
;     add  RSP, 16
;     pop  R15
;     pop  R14
;     pop  R13
;     pop  R12
;     pop  RBP
;     ret

; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa

; MEJOR VERSION UPDATED:

alternate_sum_8:
    ; PRÓLOGO
    push RBP
    mov  RBP, RSP
    push R12
    push R13
    push R14
    push R15

    ; guardamos parámetros volátiles en no-volátiles
    mov  R12D, EDX      ; x3
    mov  R13D, ECX      ; x4
    mov  R14D, R8D      ; x5
    mov  R15D, R9D      ; x6

    ; CUERPO
    call restar_c               ; result = x1 - x2

    mov  EDI, EAX
    mov  ESI, R12D
    call sumar_c                ; result += x3

    mov  EDI, EAX
    mov  ESI, R13D
    call restar_c               ; result -= x4

    mov  EDI, EAX
    mov  ESI, R14D
    call sumar_c                ; result += x5

    mov  EDI, EAX
    mov  ESI, R15D
    call restar_c               ; result -= x6

    mov  EDI, EAX
    mov  ESI, dword [RBP+16]     ; x7 desde local
    call sumar_c                ; result += x7

    mov  EDI, EAX
    mov  ESI, dword [RBP+24]    ; x8 desde local
    call restar_c               ; result -= x8

    ; EAX contiene el resultado

    ; EPÍLOGO
    pop  R15
    pop  R14
    pop  R13
    pop  R12
    pop  RBP
    ret

;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: 
; destination -> [RDI]
; x1 -> ESI
; f1 -> XMM0

product_2_f:
; PRÓLOGO
    push RBP
    mov  RBP, RSP

    push R12
    push R13

    ; guardamos parámetros volátiles en no-volátiles
    mov  R12, RDI      ; guardo destination
    mov  R13D, ESI      ; guardo x1

  ; CUERPO
  cvtsi2sd XMM1, R13D  ; convierte x1 a double (int -> double)  
  cvtss2sd XMM0, XMM0  ; convierte f1 a double (float -> double) 
  mulsd   XMM0, XMM1 ; xmm0 = xmm0 * xmm1   (f1 * x1)
  cvttsd2si EAX, XMM0      ; convierte a int32 truncado (resultado en eax)
  mov     [R12], EAX       ; guarda en *destination

; EPÍLOGO
  
    pop  R13
    pop  R12
    pop  RBP
    ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);

;
; Registros:

;  RDI -> destination (double *)
;  RSI -> x1 (uint32_t)       XMM0 -> f1 
;  RDX -> x2 (uint32_t)       XMM1 -> f2
;  RCX -> x3 (uint32_t)       XMM2 -> f3
;  R8  -> x4 (uint32_t)       XMM3 -> f4
;  R9  -> x5 (uint32_t)       XMM4 -> f5
;  stack:                     XMM5 -> f6
;   [RBP+16] -> x6 (uint32_t) XMM6 -> f7
;   [RBP+24] -> x7 (uint32_t) XMM7 -> f8
;   [RBP+32] -> x8 (uint32_t) f9 en stack -> [RBP+48] 
;   [RBP+40] -> x9 (uint32_t) 
;
; Nota: los argumentos enteros después del sexto (x6, x7, x8, x9) se pasan en la pila en [RBP+16], [RBP+24], [RBP+32], [RBP+40].
;       Los argumentos float después del octavo (f9) se pasan en la pila como float, en este caso f9 está en [RBP+48].


product_9_f:
    ; -------- PRÓLOGO --------
    push RBP
    mov  RBP, RSP

    push R12 ;Por lo que entendi estos registros podria no usarlos y usar directamente los temporales 
    push R13
    push R14
    push R15
    ; ahora RSP está alineado a 16 bytes 

    ; reservar 32 bytes para locals (espacio para x6, x7, x8 y x9)
    sub  RSP, 32             ; reserva locals: [RBP-8], [RBP-16], [RBP-24], [RBP-32]

    ; guardar enteros volátiles en no-volátiles (x3, x4 y x5)
    ; (x1, x2 están en RSI, RDX; los usamos directo, no hace falta copiarlos)

    mov  R12D, EDX    ; R12D <- x2 
    mov  R13D, ECX    ; R13D <- x3
    mov  R14D, R8D    ; R14D <- x4
    mov  R15D, R9D    ; R15D <- x5

    ; copiar los enteros que vienen en la pila (x6, x7, x8 y x9) a locales
    ; offsets: (al entrar y tras mov RBP,RSP)
    ; [RBP+8]  = return addr
    ; [RBP+16] = primer arg on stack = x6
    ; [RBP+24] = x7
    ; [RBP+32] = x8
    ; [RBP+40] = x9
    mov  EAX, dword [RBP+16]    ; x6
    mov  dword [RBP-8], EAX
    mov  EAX, dword [RBP+24]    ; x7
    mov  dword [RBP-16], EAX
    mov  EAX, dword [RBP+32]    ; x8
    mov  dword [RBP-24], EAX
    mov  EAX, dword [RBP+40]    ; x9
    mov  dword [RBP-32], EAX

    ; -------- CONVERTIR LOS FLOATS f1..f8 A DOUBLE -------
    ; (XMM0..XMM7 contienen f1..f8 en single; los convertimos a double in-place)
    cvtss2sd XMM0, XMM0    ; f1 -> double
    cvtss2sd XMM1, XMM1    ; f2 -> double
    cvtss2sd XMM2, XMM2    ; f3 -> double
    cvtss2sd XMM3, XMM3    ; f4 -> double
    cvtss2sd XMM4, XMM4    ; f5 -> double
    cvtss2sd XMM5, XMM5    ; f6 -> double
    cvtss2sd XMM6, XMM6    ; f7 -> double
    cvtss2sd XMM7, XMM7    ; f8 -> double

    ; -------- MULTIPLICAR TODOS LOS FLOATS (en double) --------
    ; XMM0 = f1 * f2 * f3 * ... * f8
    mulsd XMM0, XMM1
    mulsd XMM0, XMM2
    mulsd XMM0, XMM3
    mulsd XMM0, XMM4
    mulsd XMM0, XMM5
    mulsd XMM0, XMM6
    mulsd XMM0, XMM7

    ; ahora cargar f9 (está en la pila como float: [RBP+48])
    ; y multiplicar: XMM0 *= f9 (promoviendo a double)
    cvtss2sd XMM1, dword [RBP+48]   ; XMM1 <- double(f9)
    mulsd XMM0, XMM1

    ; -------- MULTIPLICAR POR LOS ENTEROS (convertidos a double) -------
    ; Usaremos XMM1 como registro temporal para cada cvtsi2sd.
    ; Usamos R11D como temp para valores desde memoria cuando sea necesario.

    ; x1 in RSI
    mov  R11D, ESI
    cvtsi2sd XMM1, R11D
    mulsd XMM0, XMM1

    ; x2 in R12D 
    mov  R11D, R12D
    cvtsi2sd XMM1, R11D
    mulsd XMM0, XMM1

    ; x3 in R13D
    mov  R11D, R13D
    cvtsi2sd XMM1, R11D
    mulsd XMM0, XMM1

    ; x4 in R14D
    mov  R11D, R14D
    cvtsi2sd XMM1, R11D
    mulsd XMM0, XMM1

    ; x5 in R15D
    mov  R11D, R15D
    cvtsi2sd XMM1, R11D
    mulsd XMM0, XMM1

    ; x6 from [RBP-8]
    mov  R11D, dword [RBP-8]
    cvtsi2sd XMM1, R11D
    mulsd XMM0, XMM1

    ; x7 from [RBP-16]
    mov  R11D, dword [RBP-16]
    cvtsi2sd XMM1, R11D
    mulsd XMM0, XMM1

    ; x8 from [RBP-24]
    mov  R11D, dword [RBP-24]
    cvtsi2sd XMM1, R11D
    mulsd XMM0, XMM1

    ; x9 from [RBP-32]
    mov  R11D, dword [RBP-32]
    cvtsi2sd XMM1, R11D
    mulsd XMM0, XMM1

    ; -------- GUARDAR RESULTADO (double) EN *destination --------
    ; destination is in RDI
    movsd qword [RDI], XMM0

    ; -------- EPÍLOGO --------
    add  RSP, 32          ; liberar locals
    pop  R15
    pop  R14
    pop  R13
    pop  R12
    pop  RBP
    ret


; [rbp+0]   = antiguo RBP
; [rbp+8]   = return address (la dir. a donde vuelve el call)
; [rbp+16]  = primer argumento que no entró en registros (acá x6)
; [rbp+24]  = segundo argumento en pila (x7)
; [rbp+32]  = tercero (x8)
; [rbp+40]  = cuarto (x9)
; [rbp+48]  = quinto... (acá f9, que como es float ocupa 4 bytes pero está alineado a 8)

