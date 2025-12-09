extern strcmp
global invocar_habilidad

; Completar las definiciones o borrarlas (en este ejercicio NO serán revisadas por el ABI enforcer)
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text

; void invocar_habilidad(void* carta, char* habilidad);
invocar_habilidad:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; RDI r/m64 = void*    card ; Vale asumir que card siempre es al menos un card_t*
	; RSI r/m64 = char*    habilidad

	push rbp
	mov rbp, rsp
	push R12
	push R13
	push R14
	push R15
	push RBX
	sub rsp, 8

	cmp RDI, 0
	je epilogo

	mov R12, RDI ; card
	mov R13, RSI ; habilidad

	xor R14W, R14W ; i
	mov R15, [R12 + FANTASTRUCO_DIR_OFFSET] ; dir

	mov BX, [R12 + FANTASTRUCO_ENTRIES_OFFSET] ; dir_entries

	loop:
		cmp R14W, BX
		je notFound

		mov RDI, [R15] ; dir_entry
		;mov RDI, [RDI + DIRENTRY_NAME_OFFSET]
		add RDI, DIRENTRY_NAME_OFFSET
		mov RSI, R13
		call strcmp

		cmp EAX, 0
		je callFunc

		add R14W, 1
		add R15, 8
		jmp loop

notFound:
	mov RDI, [R12 + FANTASTRUCO_ARCHETYPE_OFFSET]
	mov RSI, R13
	call invocar_habilidad
	jmp epilogo

callFunc:
	mov R8, [R15]
	mov R8, [R8 + DIRENTRY_PTR_OFFSET]
	mov RDI, R12
	call R8
	jmp epilogo

epilogo:
	add rsp, 8
	pop RBX
	pop R15
	pop R14
	pop R13
	pop R12
	pop rbp
	ret ;No te olvides el ret!