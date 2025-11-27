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
	; rdi = void*    card ; Vale asumir que card siempre es al menos un card_t*
	; rsi = char*    habilidad

	push rbp
	mov rbp, rsp
	push rbx
	push r15
	push r14
	push r13
	push r12
	push r8

	mov rbx, rdi	; rbx = carta
	mov r15, rsi	; r15 = habilidad
	mov [rsp], rdi 

	cmp rbx, 0
	je .fin
	mov r14, [rbx + FANTASTRUCO_DIR_OFFSET]		; r14 = carta-> __dir , obtenemos el puntero del array

	cmp word[rbx + FANTASTRUCO_ENTRIES_OFFSET], 0	; hay directorios por recorrer?
	je .buscoArchetype

	; entrasmos a directory y buscamos la habilidad
	movzx r13, word[rbx + FANTASTRUCO_ENTRIES_OFFSET] ; r13 = carta->__dir_entrie
	xor r12,r12
	.loop:
	
		cmp r12, r13		; hay directory_entry_t por evaluar?
		jge .buscoArchetype
		
		mov r8, [r14 + r12*8] 	; r8 = carta->__dir[i]
		lea rdi, [r8 + DIRENTRY_NAME_OFFSET] ; rdi =&carta->__dir[i].nombre
		mov rsi, r15

		;Comparo los nombres
		call strcmp
		cmp eax, 0
		je .invocar_habilidad

		; No lo encontramos, sigo
		inc r12
		jmp .loop

	
	.buscoArchetype:
		cmp QWORD[rbx + FANTASTRUCO_ARCHETYPE_OFFSET], 0  ; Tiene archetype?
		je .fin

		mov rbx, [rbx + FANTASTRUCO_ARCHETYPE_OFFSET]	;rbx = carta->__archetype
		movzx r13, word[rbx + FANTASTRUCO_ENTRIES_OFFSET]
		mov r14, [rbx + FANTASTRUCO_DIR_OFFSET]
		xor r12,r12
		jmp .loop
		
	.invocar_habilidad:
		mov r10, [r14 + r12*8] ; r10 = carta-> __dir[i]
		mov rax, [r10+ DIRENTRY_PTR_OFFSET]
		mov rdi, [rsp]
		call rax


 .fin:
	pop r8
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbx
	pop rbp
	ret ;No te olvides el ret!