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
; -------------------------------
DIRENTRY_SIZE EQU 24


FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
; -------------------------------
FANTASTRUCO_SIZE EQU 32

; void init_fantastruco_dir(fantastruco_t* card);
global init_fantastruco_dir
init_fantastruco_dir:
; registros:
	; rdi = *card
    
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    push r12

    mov r12, rdi		; r12 = *card

	mov word[r12 + FANTASTRUCO_ENTRIES_OFFSET], 2

	mov rdi, 16			; (sizeof(directory_entry_t*) * 2)
	call malloc

	mov rbx, rax		; rbx = directorio

	mov rdi, wakeup_name
	mov rsi, wakeup

	call create_dir_entry

	mov qword[rbx], rax

	mov rdi, sleep_name
	mov rsi, sleep

	call create_dir_entry	

	mov qword[rbx + 8], rax
	
	mov qword[r12 + FANTASTRUCO_DIR_OFFSET], rbx		; card->__dir = directorio;

.fin:
    ; === EPÍLOGO ===
    pop r12
    pop rbx
    pop rbp
    ret


; fantastruco_t* summon_fantastruco();
global summon_fantastruco
summon_fantastruco:
; registros:
    ; === PRÓLOGO ===
    push rbp
    mov rbp, rsp

    ; preservar registros callee-saved 
    push rbx   
    sub rsp, 8          ; Alineamiento GLOBAL (La pila ya es segura para toda la función)
    
	mov rdi, FANTASTRUCO_SIZE
	call malloc
	
	mov rbx, rax		; rbx = *fantastruco

	mov qword[rbx + FANTASTRUCO_ARCHETYPE_OFFSET], 0
	mov byte[rbx + FANTASTRUCO_FACEUP_OFFSET], 1

	mov rdi, rbx		; rdi = *fantastruco
	call init_fantastruco_dir

.fin:
    mov rax, rbx       	; return fantastruco;

    ; === EPÍLOGO ===
    add rsp, 8          ; Deshago el alineamiento global
    pop rbx
    pop rbp
    ret
