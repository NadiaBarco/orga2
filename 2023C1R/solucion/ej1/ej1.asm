extern malloc
global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm

OFFSET_MONTO EQU 0
OFFSET_COMERCIO EQU 8
OFFSET_CLIENTE EQU 16
OFFSET_APROBADO EQU 17

OFFSET_PAGO EQU 24

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;uint32_t* acumuladoPorCliente_asm(uint8_t cantidadDePagos, pago_t* arr_pagos);

acumuladoPorCliente_asm:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	push r15
	push r14
	push r13
	push r12

	mov r15, rdi		; r15 = tamaño del array
	mov r14, rsi		;r14 = punt al array de estructuras

	; creamos el array de pagos aprobados
	mov rdi, 10
	shl rdi, 2								; rdi = len(array)* sizeof(uint_32)
	call malloc

	mov [rbp-8], rax
	mov r13, rax							; r13 = puntero al nuevo array
	mov r8, 10
	;INICIALIZO EL ARRAY
	.init_array:
		cmp r8, 0
		je .restauro_punt
		mov dword[r13], 0
		add r13, 4
		dec r8
		jmp .init_array

	.restauro_punt:
		mov r13, [rbp-8]
	; Verificamos los pagos 
	.ciclo:
		cmp r15, 0 
		je .fin 

		cmp byte[r14 + OFFSET_APROBADO], 0
		je .siguiente

		; Es un pago aprobado
		movzx r12, byte[r14 + OFFSET_CLIENTE] 	; r12b = arr_pagos[i].id
		movzx r9d, byte[r14+ OFFSET_MONTO]		; r9d = arr_pagos[i].monto

		add dword[r13 + r12*4], r9d				; r13[id]= r13[id] + arr_pagos[i].monto

		;vamos al proximo pago
		dec r15
		add r14, OFFSET_PAGO
		
		jmp .ciclo

		.siguiente:
			add r14, OFFSET_PAGO
			dec r15
			jmp .ciclo

 .fin:
	mov rax, [rbp-8]

	pop r12
	pop r13
	pop r14
	pop r15
	add rsp, 16
	pop rbp
	ret

;uint8_t en_blacklist_asm(char* comercio, char** lista_comercios, uint8_t n);
; rdi = *comercio
; rsi = **lista_comercio
; dl = uint_8 n
en_blacklist_asm:
	push rbp
	mov rbp, rsp
	push r15
	push r14
	push r13
	push rbx

	mov r14, rsi		; r14 = **lista_comercio
	mov r13, rdi		; r13 = *comercio
	movzx r15, dl
	;tomamos el primer string de la lista
	mov rbx, [r14]				; rbx = lista_comercios[0]
	.loop:
		cmp r15, 0 
		je .end

		; Comparamos los strings
		mov rdi, r13
		mov rsi, [r14]

		call compare

		cmp al, 1
		je .son_iguales

		;No son iguales, seguimos
		add r14, 8
		dec r15
		jmp .loop
		.notequal:
			mov al, 0
			jmp .end
		.son_iguales:
			mov al,1
			

 .end:
	pop rbx
	pop r13
	pop r14
	pop r15
	pop rbp
	ret



;pago_t** blacklistComercios_asm(uint8_t cantidad_pagos, pago_t* arr_pagos,
;char** arr_comercios,uint8_t size_comercios);
; dil = cantidad_pagos
; rsi = *arr_pagos
; rdx = **arr_comercios
; cl = size_comercios
blacklistComercios_asm:
	push rbp
	mov rbp, rsp
	sub rsp, 40
	push r15
	push r14
	push r13
	push r12
	push rbx
	
	mov rbx, rdx		; rbx = **arr_comercios 
	mov [rbp-8], rbx

	mov r12, rsi		; r12 = *arr_pagos
	mov [rbp-16], r12
	mov byte[rbp-24],dil ; cantidad de pagos
	mov byte[rbp-32], cl ; size_comercios
	movzx r13, dil		 ; r13 = camtidad_de_pagos
	movzx r14, cl		 ; r14 = size_comercios
	mov qword[rbp-40],0
	xor r15,r15
	.loop_comercios:
		cmp r13, 0	; cantidad_pagos-=1
		je .end

		;Chequeamos que arr_pagos[i]->comercio este en arr_comercios
		mov rsi, rbx							; **arr_comercio
		mov rdi, [r12 + OFFSET_COMERCIO]		; arr_pagos[i]->comercio				
		mov dl, byte[rbp-32]
		call en_blacklist_asm

		cmp al, 0
		je .siguiente_comercio

		; al = 1, esta en la black_list
		inc r15
		.siguiente_comercio:
			dec r13
			cmp r13, 0 
			je .reservarMemoria

			add r12, OFFSET_PAGO
			jmp .loop_comercios



  .reservarMemoria:
	cmp r15, 0
	je .end
 	mov rdi, r15
 	shl rdi, 3

 	call malloc				; rax = pago_t** res
	xor r8,r8
 	mov [rbp-40], rax		; guardamos el puntero del array de pago_t
	mov r12, [rbp-16]		; arr_pagos
	mov rbx, [rbp-8]		; arr_comercios
	movzx r13, byte[rbp-24]
	.loop_mod_blacklist:
		cmp r8, r15
		je .end

		cmp r13, 0
		je .end
		;Chequeamos que arr_pagos[i]->comercio este en arr_comercios
		mov rsi, rbx							; **arr_comercio
		mov rdi, [r12 + OFFSET_COMERCIO]		; arr_pagos[i]->comercio				
		mov dl, byte[rbp-32]
		call en_blacklist_asm

		cmp al, 0
		je .siguiente_pago

		; al = 1, esta en la black_list
		mov r14, [rbp-40]
		mov [r14 + r8*8], r12
		add r8, 1
		.siguiente_pago:
			dec r13
			cmp r13, 0
			je .end
			add r12, OFFSET_PAGO
			jmp .loop_mod_blacklist



 .end:
    mov rax, [rbp-40]
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15
	add rsp, 40
	pop rbp
	ret


global compare
; uint_8 compare(char* str, char* str2)
; rdi = str
; rsi = str2
compare:
    push rbp
    mov rbp, rsp

.loop:
    ; Cargar caracteres
    movzx eax, byte[rdi]
    movzx ebx, byte[rsi]
    
    ; Si son diferentes, las cadenas son diferentes
    cmp al, bl
    jne .different
    
    ; Si ambos caracteres son 0, hemos terminado y las cadenas son iguales
    test al, al
    jz .equal
    
    ; Avanzar al siguiente carácter
    inc rdi
    inc rsi
    jmp .loop
    
.different:
    mov eax, 0
    jmp .end
    
.equal:
    mov eax, 1
    
.end:
    pop rbp
    ret
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