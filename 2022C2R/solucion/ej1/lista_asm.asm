%define OFFSET_NEXT  0
%define OFFSET_SUM   8
%define OFFSET_SIZE  16
%define OFFSET_ARRAY 24

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
	xor r9,r9
	;Verificmos si no es un puntero nulo
	cmp rdi, 0
	je .fin

	mov rbx, rdi

	cmp rsi, 0
	je .modificar_tarea
	mov r9, -1
	.ciclo:

		cmp r9, rsi 				; count < indice
		je .modificar_tarea		; la tarea esta en el proyecto

		add r9, [rbx + OFFSET_SIZE]	;incrementamos el count

		; Vamos al proximo nodo
		mov rbx,[rbx + OFFSET_NEXT]	
		cmp rbx, 0
		je .fin

		jmp .ciclo

		.modificar_tarea:
			sub r9, rsi				;Hallamos la posicion del indice en el array
			mov r12d, dword[rbx + OFFSET_ARRAY + 4*r9] ; r12 = a->array[i]

			;modificamos la suma
			sub dword[rbx + OFFSET_SUM], r12d
			mov dword[rbx + OFFSET_ARRAY + 4*r9],0
			jmp .fin
 .fin:
	pop r12
	pop rbx
	pop rbp
	ret

; uint64_t* tareas_completadas_por_proyecto(lista_t*)
;
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
	; COMPLETAR
	ret

; uint64_t lista_len(lista_t* lista)
;
; Dada una lista enlazada devuelve su longitud.
;
; - La longitud de `NULL` es 0
;
lista_len:
	; OPCIONAL: Completar si se usa el esquema recomendado por la cátedra
	ret

; uint64_t tareas_completadas(uint32_t* array, size_t size) {
;
; Dado un array de `size` enteros de 32 bits sin signo devuelve la cantidad de
; ceros en ese array.
;
; - Un array de tamaño 0 tiene 0 ceros.
tareas_completadas:
	; OPCIONAL: Completar si se usa el esquema recomendado por la cátedra
