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
		mov rsi, rbx

		call compare

		cmp al, 0
		je .son_iguales

		;No son iguales, seguimos
		add rbx, 8
		dec r15
		jmp .loop

		.son_iguales:
			jmp .end

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
	sub rsp, 32
	push r15
	push r14
	push r13
	push r12
	push rbx
	
	mov rbx, rdx		; rbx = **arr_comercios 
	mov [rbp-8], rbx

	mov r12, rsi		; r12 = *arr_pagos
	mov [rbp-16], r12

	movzx r13, dil		; r13 = cantidad_pagos
	movzx r14, cl		; r14 = size_comercios
	

	movzx r9,cl
	movzx r8, dil
	;Contamos la cantidad de elementos de salida
	.while_pagos:
		cmp r13, 0
		je .reservarMemoria
		
		.while_comercios:
			cmp r14, 0
			je .restauro_while_pagos

			mov rdi, [r12 + OFFSET_COMERCIO]		; rdi = arr_pagos[i]->comercio
			mov rsi, [rbx]							; rsi = arr_comercios[j]

			;los comparo
			call compare

			cmp al, 0
			je .siguiente

			; Son strings iguales
			inc r15									; count++

			
			cmp r14, 0								;Llegamos al final del array?
			je .restauro_while_pagos
			
		
			.siguiente:
				dec r14
				cmp r14, 0 
				je .restauro_while_pagos
				add rbx, 8							; arr_comercio[j+1]
				jmp .while_comercios


		.restauro_while_pagos:
			dec r13
			cmp r13, 0
			je .while_pagos
			mov r14, r9

			;Volvemos al inicio de array_comercios			
			mov rbx, [rbp-8]			; rbx = arr_comercios[0]
			add r12, OFFSET_PAGO		; r12 = arr_pagos[i+1]
			jmp .while_pagos

 .reservarMemoria:
 	mov r14, r9
	mov r13, r8
	mov rdi, r15
	shl rdi, 3

	call malloc				; rax = pago_t** res
	
	mov [rbp-24], rax		; guardamos el puntero del array de pago_t
	mov r15, rax			; r15 = pago_t** res
	
	; Rellenamos el array de los pagos
	mov r12, [rbp-16]
	mov rbx, [rbp-8]
	;BUSCAMOS LOS COMERCIOS QUE ESTEN EN AMBAS LISTAS
	.loop_pagos:
		cmp r13, 0
		je .end

		
		.loop_comercios:
			cmp r14, 0
			je .siguiente_pago

			mov rdi, [r12 + OFFSET_COMERCIO]		; rdi = arr_pagos[i]->comercio
			mov rsi, [rbx]							; rsi = arr_comercios[j]

			;los comparo
			call compare

			cmp al, 0
			je .next

			; Son strings iguales
			mov [r15], r12							; res[k] = arr_pagos[i]

			.next:
				dec r14
				cmp r14, 0 
				je .siguiente_pago
				
				add rbx, 8							; arr_comercio[j+1]
				jmp .loop_comercios
		
	.siguiente_pago:	
		dec r13
		cmp r13, 0 
		je .loop_pagos
		mov r14, r9
		mov r12, [rbp-16]			;Volvemos al inicio de array_comercios
		add r12, OFFSET_PAGO		; r12 = arr_pagos[i+1]
		jmp .loop_pagos

 .end:
    mov rax, [rbp-24]
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15
	add rsp, 32
	pop rbp
	ret


global compare
; uint_8 compare(char* str, char* str2)
; rdi = str
; rsi = str2
compare:
	push rbp
	mov rbp ,rsp

	cmp rdi,rsi
	je .sonIguales


	.loop:
		mov al, byte[rdi]
		mov bl, byte[rsi]

		cmp al, bl
		jne .sonDiff
		test al, al
		je .sonIguales

		inc rdi
		inc rsi
		jmp .loop

		.sonDiff:
			mov al, 0
			jmp .end
		.sonIguales:
			mov al, 1

			jmp .end
 .end:
	pop rbp
	ret