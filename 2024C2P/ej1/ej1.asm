extern malloc

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
OFFSET_NOMBRE EQU 0
OFFSET_FUERZA EQU 18
OFFSET_DURABILIDAD EQU 20
OFFSET_ITEM_T EQU 24
section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

global es_indice_ordenado
es_indice_ordenado:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = item_t**     inventario
	; rsi = uint16_t*    indice
	; dx = uint16_t     tamanio
	; rcx = comparador_t comparador
	push rbp
	mov rbp, rsp		; armamos el stack frame
	push rbx
	push r15
	push r14
	push r13

	mov rbx, rdi		; preservamos el inventario
	mov r15, rsi		; preservamos el indice
	movzx r14, dx		; preservamos el tamaño
	mov r13, rcx		; preservamos el comparador

	cmp r14, 2			; la longitud del array es mayor o igual a dos?
	jl .esta_ord
	sub r14, 1			; como comparamos 2 a 2, le restamos 1
	.ciclo:
		cmp r14, 0
		je .fin

		; accedemos a los indices
		movzx r8, word[r15]			;obtenemos el idx
		mov rdi, [rbx + 8*r8]		; item a comparar
		add r15, 2
		movzx r8, word[r15]	
		mov rsi, [rbx + 8*r8]		; 2do item a comparar

		call r13					; esta_ord = 1, no_ord = 0

		cmp rax, 0
		je .fin					; si no son iguales, termino

		;seguimos comparando
		dec r14
		jmp .ciclo
		.esta_ord:
			mov rax, 1			; inventario de un solo elem, esta ordenado
	
 .fin:
	pop r13
	pop r14
	pop r15
	pop rbx
	pop rbp
	ret

;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = item_t**  inventario
	; rsi = uint16_t* indice
	; dx = uint16_t  tamanio

	push rbp
	mov rbp, rsp
	push rbx
	push r15
	push r14
	push r13

	mov rbx, rdi 		;preservamos el inventario
	mov r15, rsi		; preservamos los indices
	movzx r14, dx

	; creamos el array
	mov rdi, r14
	shl rdi, 3
	call malloc			; obetenemos el puntero al res
	mov r13, rax
	.ciclo:
		cmp r14, 0
		je .fin

		movzx r8, word[r15]			;obtenemos el idx
		mov r10, [rbx + 8*r8]		; r8 = inventario[indice[idx]]

		mov [rax], r10		; res[idx] = inventario[indice[idx]]

		;siguiente nodo
		add r15, 2
		sub r14, 1
		add rax, 8
		jmp .ciclo
 .fin:
	mov rax, r13
	pop r13
	pop r14
	pop r15
	pop rbx
	pop rbp
	ret
