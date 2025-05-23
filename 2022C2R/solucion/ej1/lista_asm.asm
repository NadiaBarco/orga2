%define OFFSET_NEXT  0
%define OFFSET_SUM   8
%define OFFSET_SIZE  16
%define OFFSET_ARRAY 24
extern malloc
extern realloc
OFFSET_LISTA_T EQU 36

BITS 64

section .text


; uint32_t proyecto_mas_dificil(lista_t*)
; rdi= lista_t* a
; Dada una lista enlazada de proyectos devuelve el `sum` más grande de ésta.
;
; - El `sum` más grande de la lista vacía (`NULL`) es 0.
;
global proyecto_mas_dificil
proyecto_mas_dificil:
	push rbp
	mov rbp,rsp
	push rbx
	push r12


	xor rax,rax
	xor rbx, rbx					; rbx=0
	xor r12, r12					; r12=0

	; El array esta vacio?
	cmp rdi, 0 						; es nulo?
	je .fin						; si, rax=0 => fin



	;Tomamos el primer elem a comparar
	mov eax, dword[rdi+ OFFSET_SUM]

	;Verificamos si solo hay un proyecto
	mov	rbx, [rdi + OFFSET_NEXT]
	cmp rbx, 0
	je .fin


	;Vamos al segundo nodo
	mov r12d, dword[rbx+ OFFSET_SUM]


	.ciclo:
		cmp rbx, 0				;Lllegamos al final de array?
		je .fin 				; No hay nodos por recorrer, fin

		cmp eax, r12d			; si eax > r12d seguimos
		jg .siguiente

		; si eax <= r12d modificamos
		mov eax, r12d			
		mov rbx, [rbx + OFFSET_NEXT]	; Vamos al proximo nodo
		cmp rbx, 0						; chequeamos si era el nodo final
		je .fin

		
		mov r12d, dword[rbx + OFFSET_SUM]	; obtenemos el nuevo valor de r12d 
		jmp .ciclo 

			; Vamos al proximo nodo
			.siguiente:
				mov rbx, [rbx + OFFSET_NEXT]
				cmp rbx, 0
				je .fin
				mov r12d, dword[rbx + OFFSET_SUM]
				
				jmp .ciclo
 
 .fin:	

	pop r12
	pop rbx
	pop rbp
	ret

; void tarea_completada(lista_t*, size_t)
;
; Dada una lista enlazada de proyectos y un índice en ésta setea la i-ésima
; tarea en cero.
;
; - La implementación debe "saltearse" a los proyectos sin tareas
; - Se puede asumir que el índice siempre es válido
; - Se debe actualizar el `sum` del nodo actualizado de la lista
;
global marcar_tarea_completada
;rdi= lista a*
; rsi= size_t
marcar_tarea_completada:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r15

	mov r13,rsi
	;Verificmos si no es un puntero nulo
	cmp rdi, 0
	je .fin

	mov rbx, rdi
	xor r13,r13

	mov r15, [rbx + OFFSET_ARRAY]

	.ciclo:
		cmp qword[rbx + OFFSET_SIZE], 0 				; Llegamos al final de array?
		je .siguiente		; la tarea esta en el proyecto

		; Verificamos si es del mismo array
		mov r12, [rbx + OFFSET_SIZE]
		add r13, r12					; r13 = curr_i + lista->size

		cmp r13, rsi					; curr_i + lista->size <= index
		jg .modificar_tarea

		jmp .siguiente
		.modificar_tarea:
			;Hallamos la posicion del indice en el array
			sub r13,r12
			sub rsi, r13
			
			mov r12d, dword[r15 + 4*rsi] ; r12 = a->array[i]

			; verificamos si hay siguiente nodo 

			;modificamos la suma
			sub dword[rbx + OFFSET_SUM], r12d
			mov dword[r15+ 4*rsi],0
			
			jmp .fin

		.siguiente:
			; pasamos al siguiente nodo
			;add r13, r12	;incrementamos el count
			mov rbx, [rbx + OFFSET_NEXT]	
			mov r15, [rbx + OFFSET_ARRAY]
			
			cmp rbx, 0
			je .fin

			jmp .ciclo

 .fin:
	pop r15
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

; uint64_t* tareas_completadas_por_proyecto(lista_t*)
;	rdi = lista_t*
; Dada una lista enlazada de proyectos se devuelve un array que cuenta
; cuántas tareas completadas tiene cada uno de ellos.
;
; - Si se provee a la lista vacía como parámetro (`NULL`) la respuesta puede
;   ser `NULL` o el resultado de `malloc(0)`
; - Los proyectos sin tareas tienen cero tareas completadas
; - Los proyectos sin tareas deben aparecer en el array resultante
; - Se provee una implementación esqueleto en C si se desea seguir el
;   esquema implementativo recomendado
;
global tareas_completadas_por_proyecto
tareas_completadas_por_proyecto:
	push rbp
	mov rbp, rsp
	push r15		; puntero al nuevo array
	push r14
	push r12
	push rbx		; puntero a la estructura
	
	; El puntero es null? 
	mov rbx, rdi

	; Calculamos la longitud del array de salida
	call lista_len				; en rax tenemos la longitud
	mov r14, rax				; r14 = contador
	; rax = sizeof(uint_32) * rax
	shl rax, 3

	mov rdi, rax

	call malloc 

	mov r15, rax		;Puntero al nuevo array
	mov r12,rax
	.loop:
		cmp r14, 0
		je .fin
		mov rdi, [rbx + OFFSET_ARRAY]
		mov rsi, [rbx + OFFSET_SIZE]

		call tareas_completadas

		mov [r15], rax

		dec r14
		add r15, 8
		mov rbx, [rbx + OFFSET_NEXT]

		jmp .loop
	
	.esNULL:
		mov rax, 0

 .fin:
	mov rax, r12
	pop rbx
	pop r12
	pop r14
	pop r15
	pop rbp
	ret

; uint64_t lista_len(lista_t* lista)
;
; Dada una lista enlazada devuelve su longitud.
;	rdi = lista
; - La longitud de `NULL` es 0
;
global lista_len
lista_len:
	; OPCIONAL: Completar si se usa el esquema recomendado por la cátedra
	push rbp
	mov rbp, rsp
	push r15
	push rbx

	mov rbx, rdi
	cmp rbx, 0			; rbx es null?
	je .fin
	mov rax, 1
	.loop:
		mov rbx, qword[rbx + OFFSET_NEXT]	;Hay nodo siguiente?
		cmp rbx, 0
		je .fin

		inc rax
		jmp .loop

 .fin:	
	pop rbx
	pop r15
	pop rbp
	ret

; uint64_t tareas_completadas(uint32_t* array, size_t size) {
;
; Dado un array de `size` enteros de 32 bits sin signo devuelve la cantidad de
; ceros en ese array.
;	rdi = *array
;	rsi = size
; - Un array de tamaño 0 tiene 0 ceros.
global tareas_completadas
tareas_completadas:
	; OPCIONAL: Completar si se usa el esquema recomendado por la cátedra
	push rbp
	mov rbp, rsp
	push rbx
	push r15
	push r14
	push r13
	
	xor rax,rax

	mov rbx, rdi 
	cmp rbx, 0 
	je .fin

	.loop:
		cmp rsi, 0
		je .fin

		mov r15, [rbx]

		cmp r15, 0
		jne .siguiente

		inc rax

		.siguiente:
			dec rsi
			add rbx, 4
			jmp .loop
 .fin:
	pop r13
	pop r14
	pop r15
	pop rbx
	pop rbp
	ret