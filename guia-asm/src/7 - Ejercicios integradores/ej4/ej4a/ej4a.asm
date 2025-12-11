extern malloc
extern sleep
extern wakeup
extern create_dir_entry

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
sleep_name: DB "sleep", 0
wakeup_name: DB "wakeup", 0

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - init_fantastruco_dir
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - summon_fantastruco
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32


; void init_fantastruco_dir(fantastruco_t* card);
global init_fantastruco_dir
init_fantastruco_dir:
; registros:
;   1. RDI = card

    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12
    push r13
    push r14
    push r15

    mov rbx, rdi        ; rbx = card

    mov word[rbx + FANTASTRUCO_ENTRIES_OFFSET], 2       ; card->__dir_entries = 2;

    ; directorio1
    sub rsp, 8
    mov rdi, sleep_name             ; rdi = sizeof(directory_entry_t*) * 2
    mov rsi, sleep                  ; rdi = sizeof(directory_entry_t*) * 2
    call create_dir_entry
    add rsp, 8 
    mov r12, rax

    ; directorio2
    sub rsp, 8
    mov rdi, wakeup_name             ; rdi = sizeof(directory_entry_t*) * 2
    mov rsi, wakeup                   ; rdi = sizeof(directory_entry_t*) * 2
    call create_dir_entry
    add rsp, 8 
    mov r13, rax

    ;malloc
    mov r8, 2
    imul r8, 8

    sub rsp, 8
    mov rdi, r8             ; rdi = sizeof(directory_entry_t*) * 2
    call malloc
    add rsp, 8

    mov [rax], r12          ; card->__dir[0] = directorio1;
    mov [rax + 8], r13      ; card->__dir[1] = directorio2;

    mov [rbx + FANTASTRUCO_DIR_OFFSET], rax


.fin:    
    ; === EPÍLOGO ===
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


; fantastruco_t* summon_fantastruco();
global summon_fantastruco
summon_fantastruco:


    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push r12
    push r13

    mov rdi, FANTASTRUCO_SIZE
    call malloc             ; fantastruco_t* puntero = malloc(sizeof(fantastruco_t));

    mov r12, rax        ; r12 = puntero
    
    mov byte[r12 + FANTASTRUCO_FACEUP_OFFSET], 1        ; puntero->face_up = 1;
    mov qword[r12 + FANTASTRUCO_ARCHETYPE_OFFSET], 0    ; puntero->__archetype = NULL;

    mov rdi, r12        ; paso puntero a función
    call init_fantastruco_dir

.fin:

    mov rax, r12       ; devuelvo puntero en rax

    ; === EPÍLOGO ===
    pop r13
    pop r12
    pop rbp
    ret





















; ; void init_fantastruco_dir(fantastruco_t* card);
; global init_fantastruco_dir
; init_fantastruco_dir:
; 	; Te recomendamos llenar una tablita acá con cada parámetro y su
; 	; ubicación según la convención de llamada. Prestá atención a qué
; 	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
; 	;
; 	; RDI r/m64 = fantastruco_t*     card
; 	push rbp
; 	mov rbp, rsp
; 	push R12
; 	push R13

; 	mov R12, RDI

; 	mov RDI, DIRENTRY_SIZE
; 	sal RDI, 1
; 	call malloc

; 	mov R13, RAX ; dir

; 	mov RDI, sleep_name
; 	mov RSI, sleep
; 	call create_dir_entry

; 	mov [R13], RAX

; 	mov RDI, wakeup_name
; 	mov RSI, wakeup
; 	call create_dir_entry

; 	mov [R13+8], RAX

; 	mov [R12 + FANTASTRUCO_DIR_OFFSET], R13
; 	mov WORD[R12 + FANTASTRUCO_ENTRIES_OFFSET], 2

; 	pop R13
; 	pop R12
; 	pop rbp
; 	ret ;No te olvides el ret!

; ; fantastruco_t* summon_fantastruco();
; global summon_fantastruco
; summon_fantastruco:
; 	; Esta función no recibe parámetros
; 	push rbp
; 	mov rbp, rsp
; 	push R12
; 	sub rsp, 8

; 	mov RDI, FANTASTRUCO_SIZE
; 	call malloc
; 	mov R12, RAX ; card

; 	mov RDI, R12
; 	call init_fantastruco_dir

; 	mov BYTE[R12 + FANTASTRUCO_FACEUP_OFFSET], 1
; 	mov QWORD[R12 + FANTASTRUCO_ARCHETYPE_OFFSET], 0

; 	mov RAX, R12

; 	add rsp, 8
; 	pop R12
; 	pop rbp
; 	ret ;No te olvides el ret!