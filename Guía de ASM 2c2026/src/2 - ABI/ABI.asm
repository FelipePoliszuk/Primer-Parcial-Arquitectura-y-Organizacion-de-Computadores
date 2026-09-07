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


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
alternate_sum_8:
; registros:
	; edi = x1
	; esi = x2
	; edx = x3
	; ecx = x4
	; r8d = x5
	; r9d = x6

  ; [rbp + 16] = x7
  ; [rbp + 24] = x8
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    sub edi, esi
    add edi, edx
    sub edi, ecx
    add edi, r8d
    sub edi, r9d

    add edi, dword[rbp + 16]
    sub edi, dword[rbp + 24]

    mov eax, edi

    ; === EPÍLOGO ===
    pop rbp
    ret



; Mapa conceptual de la Pila respecto a RBP

;     [rbp + 24] -> Parámetro 8 (Puesto por el caller)

;     [rbp + 16] -> Parámetro 7 (Puesto por el caller)

;     [rbp + 8]  -> Dirección de retorno (Puesta automáticamente por el call)

;     [rbp + 0]  -> El rbp original (Puesto por tu push rbp)

;     [rbp - 8]  -> Tu primera variable local (o registro preservado)

;     [rbp - 16] -> Tu segunda variable local

;     [rbp - 24] -> Tu tercera variable local

; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t* destination, uint32_t x1, float f1);
product_2_f:
; registros:
  ; rdi = *destination
  ; esi  = x1
  ; xmm0 = f1

  cvtsi2ss xmm1, esi 
  
  mulss xmm0, xmm1

  cvttss2si eax, xmm0 

  mov dword[rdi], eax 

	ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
global product_9_f
product_9_f:
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; rdi = destination
    ; esi = x1, edx = x2, ecx = x3, r8d = x4, r9d = x5
    ; xmm0 = f1, xmm1 = f2, xmm2 = f3, xmm3 = f4, xmm4 = f5, xmm5 = f6, xmm6 = f7, xmm7 = f8
    ; Pila: [rbp+16] = x6, [rbp+24] = x7, [rbp+32] = x8, [rbp+40] = x9, [rbp+48] = f9

    ; 1. Convertir los flotantes de los registros a doubles
    cvtss2sd xmm0, xmm0
    cvtss2sd xmm1, xmm1
    cvtss2sd xmm2, xmm2
    cvtss2sd xmm3, xmm3
    cvtss2sd xmm4, xmm4
    cvtss2sd xmm5, xmm5
    cvtss2sd xmm6, xmm6
    cvtss2sd xmm7, xmm7

    ; 2. Multiplicar todos los doubles presentes en registros
    mulsd xmm0, xmm1
    mulsd xmm0, xmm2
    mulsd xmm0, xmm3
    mulsd xmm0, xmm4
    mulsd xmm0, xmm5
    mulsd xmm0, xmm6
    mulsd xmm0, xmm7

    ; 3. Extraer f9 de la pila, convertirlo y multiplicarlo
    ; Usamos xmm1 temporalmente como auxiliar
    cvtss2sd xmm1, dword [rbp + 48]
    mulsd xmm0, xmm1

    ; 4. Convertir enteros de registros a doubles y multiplicar
    cvtsi2sd xmm1, rsi
    mulsd xmm0, xmm1

    cvtsi2sd xmm1, rdx
    mulsd xmm0, xmm1

    cvtsi2sd xmm1, rcx
    mulsd xmm0, xmm1

    cvtsi2sd xmm1, r8
    mulsd xmm0, xmm1

    cvtsi2sd xmm1, r9
    mulsd xmm0, xmm1

    ; 5. Extraer enteros de la pila, convertirlos y multiplicar
    mov eax, dword [rbp + 16]   ; x6
    cvtsi2sd xmm1, rax
    mulsd xmm0, xmm1

    mov eax, dword [rbp + 24]   ; x7
    cvtsi2sd xmm1, rax
    mulsd xmm0, xmm1

    mov eax, dword [rbp + 32]   ; x8
    cvtsi2sd xmm1, rax
    mulsd xmm0, xmm1

    mov eax, dword [rbp + 40]   ; x9
    cvtsi2sd xmm1, rax
    mulsd xmm0, xmm1

    ; 6. Guardar el resultado final de 64 bits (double) en el puntero de memoria
    movsd qword [rdi], xmm0

    ; === EPÍLOGO ===
    pop rbp
    ret

