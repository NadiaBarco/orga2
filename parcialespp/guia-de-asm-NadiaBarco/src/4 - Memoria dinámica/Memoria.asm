extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
 push rbp
 mov rbp, rsp
 push rbx
 

 .ciclo:
	movzx ecx, byte[rdi]
 	movzx ebx, byte[rsi]

	cmp ecx, ebx
	jg .aEsMayor
	jl .bEsMayor

	cmp ecx, 0 				;llego al final del string
	je .sonIguales

	inc rsi
	inc rdi
	jmp .ciclo

	.sonIguales:
		mov eax, 0
		jmp .fin

	.aEsMayor:
		mov eax, -1
		jmp .fin

	.bEsMayor:
		mov eax, 1
		jmp .fin




	.fin:
 		pop rbx
		pop rbp
		ret

; char* strClone(char* a)
strClone:
 push rbp
 mov rbp, rsp
 push r12						; contador
 push r13						; r13 = len del string 
 push r14						; Muevo el tope de la pila para guardar rdi y 8 bytes + para alinear
 push r15						; puntero a la nueva memoria
 push rbx
 sub rsp,8						; ALINEADO	
 mov r14, rdi					; rbx= el puntero del string 

 ; rdi sigue siendo el puntero
 call strLen						; Obteniene la longitud del string 
 mov r13d, eax							; preserva rax, contiene la longitud del  string 
 add r13d, 1							; Sumamos el caracter nulo
 
 ;Calcula el espacio que tendra la memoria 
 mov edi, r13d						; Son bytes entonces long(a)=espacio_de_mem_en_bytes
 call malloc						; rax= puntero se encuentra 
 

 mov r15, rax						; r15 = puntero a la nueva mem
 mov rbx, rax
; Copia byte a byte
 .ciclo:
	cmp r13, 0
	je .fin

	mov r12b, byte[r14]
	mov byte[r15], r12b
	inc r14
	inc r15
	dec r13
	jmp .ciclo

 .fin:
	mov rax, rbx
	add rsp,8
	pop rbx
 	pop r15
	pop r14
	pop r13
	pop r12
 	pop rbp
	ret

; void strDelete(char* a)
strDelete:
    push rbp
    mov rbp, rsp
    
    ; Check if pointer is NULL
    cmp rdi, 0
    je .fin
    
    ; Just free the original pointer once
    call free
    
.fin:
    pop rbp
    ret
; void strPrint(char* a, FILE* pFile)
strPrint:
	ret

; uint32_t strLen(char* a)
strLen:
 push rbp
 mov rbp, rsp
 push r12
 sub rsp, 8
 xor eax, eax			; inicializo contador
 mov r12, rdi
 .ciclo:

	; Accede rdi al primer caracter
	cmp byte[r12], 0		; Es igual a NULL(0)?
	je .fin					; Si es igual, termino

	inc eax					; incremento el contador
	inc r12					; Incrementa en un Byte, el puntero al proximo caracter

	jmp .ciclo
	 
 .fin:
	add rsp, 8
 	pop r12
 	pop rbp
	ret


