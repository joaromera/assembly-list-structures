section .data

NULL_STRING db 'NULL',0
OPEN_BRACKET db '[',0
COMMA db ',',0
CLOSE_BRACKET db ']',0
POINTER_FORMAT db '%p',0
STRING_FORMAT db '%s',0

section .rodata

section .text

%define NULL 0
%define POINTER_SIZE 8

%define ELEM_SIZE 24
%define ELEM_DATA_OFFSET 0
%define ELEM_NEXT_OFFSET 8
%define ELEM_PREV_OFFSET 16

%define LIST_SIZE 16
%define LIST_FIRST_OFFSET 0
%define LIST_LAST_OFFSET 8

%define N3TREE_SIZE 8
%define N3TREE_FIRST_OFFSET 0

%define N3TREE_ELEM_SIZE 32
%define N3TREE_ELEM_DATA_OFFSET 0
%define N3TREE_ELEM_LEFT_OFFSET 8
%define N3TREE_ELEM_CENTER_OFFSET 16
%define N3TREE_ELEM_RIGHT_OFFSET 24

%define NTABLE_SIZE 16
%define NTABLE_LIST_OFFSET 0
%define NTABLE_SIZE_OFFSET 8

extern malloc
extern free
extern fprintf

global strLen
global strClone
global strCmp
global strConcat
global strDelete
global strPrint
global listNew
global listAddFirst
global listAddLast
global listAdd
global listRemove
global listRemoveFirst
global listRemoveLast
global listDelete
global listPrint
global n3treeNew
global n3treeAdd
global n3treeRemoveEq
global n3treeDelete
global nTableNew
global nTableAdd
global nTableRemoveSlot
global nTableDeleteSlot
global nTableDelete

strLen:
    ; rdi <-- char* a
    push rbp
    mov rbp, rsp
    xor rax, rax

.countByByte:
    cmp byte [rdi + rax], NULL      ; cuento en rax cada byte != 0
    je .end
    inc rax
    jmp .countByByte

.end:
    pop rbp
    ret


strClone:
    ; rdi <-- char* a
    push rbp
    mov rbp, rsp
    push r12
    push r13

    mov r12, rdi
    call strLen
    mov r13, rax                ; preservo length del string
    mov rdi, rax
    inc rdi                     ; necesito un byte extra para el \0
    call malloc
    
    xor rcx, rcx
.copyEachByte:
    cmp rcx, r13                ; copio byte a byte
    je .end
    mov r10b, byte [r12 + rcx]
    mov byte [rax + rcx], r10b
    inc rcx
    jmp .copyEachByte

.end:
    mov byte [rax + rcx], NULL  ; agrego \0 al final
    pop r13
    pop r12
    pop rbp
    ret


strCmp:
    ; rdi <-- char *a
    ; rsi <-- char *b
    push rbp
    mov rbp, rsp
    xor rax, rax
    xor rcx, rcx

.compareNextByte:
    cmp byte [rdi + rcx], NULL
    je .rdiMaybeShortest
    mov dl, byte [rdi + rcx]
    cmp byte [rsi + rcx], dl
    jg .rdiSmaller
    jl .rsiSmaller
    inc rcx
    jmp .compareNextByte

.rdiMaybeShortest:
    cmp byte [rsi + rcx], NULL
    je .end                         ; a = b & rax = 0.

.rdiSmaller:
    mov rax, 1
    jmp .end

.rsiSmaller:
    mov rax, -1

.end:
    pop rbp
    ret


strConcat:
    ; rdi <-- char *a
    ; rsi <-- char *b
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 8

    mov r12, rdi                    ; r12 <-- char*a
    mov r13, rsi                    ; r13 <-- char*b
    call strLen
    mov r14, rax
    mov rdi, r13
    call strLen
    add r14, rax                    ; r14 <-- len(a) + len(b)
    inc r14                         ; byte para \0
    mov rdi, r14
    call malloc
    mov r14, rax

    xor r10, r10
    xor rdx, rdx
.concatFirst:
    cmp byte [r12 + rdx], NULL
    je .concatSecondInit
    mov r10b, byte [r12 + rdx]
    mov byte [r14 + rdx], r10b
    inc rdx
    jmp .concatFirst

.concatSecondInit:
    xor rcx, rcx

.concatSecond:
    cmp byte [r13 + rcx], NULL
    je .end
    mov r10b, byte [r13 + rcx]
    mov byte [r14 + rdx], r10b
    inc rcx
    inc rdx
    jmp .concatSecond

.end:
    mov byte [r14 + rdx], NULL

    cmp r13, r12
    je .aliasing
    mov rdi, r13
    call strDelete
.aliasing:
    mov rdi, r12
    call strDelete

    mov rax, r14
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


strDelete:
    ; rdi <-- char+a
    push rbp
    mov rbp, rsp
    call free
    pop rbp
    ret


strPrint:
    ; rdi <-- char* a
    ; rsi <-- *pFile
    push rbp
    mov rbp, rsp
    
    push rdi
    push rsi
    call strLen
    pop rdi
    pop rsi

    cmp rax, NULL
    je .printNULL

    mov rdx, rsi
    mov rsi, STRING_FORMAT
    call fprintf
    jmp .end

.printNULL:
    mov rdx, qword NULL_STRING
    mov rsi, STRING_FORMAT
    call fprintf

.end:
    pop rbp
    ret


listNew:
    push rbp
    mov rbp, rsp
    mov rdi, LIST_SIZE
    call malloc
    mov qword [rax + LIST_FIRST_OFFSET], NULL
    mov qword [rax + LIST_LAST_OFFSET], NULL
    pop rbp
    ret


listAddFirst:
    ; rdi <-- *list
    ; rsi <-- *data
    push rbp
    mov rbp, rsp
    
    push rdi
    push rsi
    mov rdi, ELEM_SIZE
    call malloc
    pop rsi
    pop rdi

    mov qword [rax + ELEM_DATA_OFFSET], rsi
    mov qword [rax + ELEM_NEXT_OFFSET], NULL
    mov qword [rax + ELEM_PREV_OFFSET], NULL

    cmp qword [rdi + LIST_FIRST_OFFSET], NULL
    jne .notFirstToAdd

    mov qword [rdi + LIST_FIRST_OFFSET], rax
    mov qword [rdi + LIST_LAST_OFFSET], rax
    jmp .end

.notFirstToAdd:
    mov rdx, qword [rdi + LIST_FIRST_OFFSET]
    mov qword [rax + ELEM_NEXT_OFFSET], rdx
    mov qword [rdx + ELEM_PREV_OFFSET], rax
    mov qword [rdi + LIST_FIRST_OFFSET], rax
    
.end:
    pop rbp
    ret


listAddLast:
    ; rdi <-- *list
    ; rsi <-- *data
    push rbp
    mov rbp, rsp
    
    push rdi
    push rsi
    mov rdi, ELEM_SIZE
    call malloc
    pop rsi
    pop rdi

    mov qword [rax], rsi
    mov qword [rax + ELEM_NEXT_OFFSET], NULL
    mov qword [rax + ELEM_PREV_OFFSET], NULL

    cmp qword [rdi + LIST_LAST_OFFSET], NULL
    jne .notFirstToAdd

    mov qword [rdi + LIST_FIRST_OFFSET], rax
    mov qword [rdi + LIST_LAST_OFFSET], rax
    jmp .end

.notFirstToAdd:
    mov rdx, qword [rdi + LIST_LAST_OFFSET]
    mov qword [rdx + ELEM_NEXT_OFFSET], rax
    mov qword [rax + ELEM_PREV_OFFSET], rdx
    mov qword [rdi + LIST_LAST_OFFSET], rax

.end:
    pop rbp
    ret


listAdd:
    ; rdi list_t * l
    ; rsi void* data
    ; rdx funcCmp_t *
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    ; muevo registros para preservarlos
    mov r12, rdi
    mov r13, qword [rdi + LIST_FIRST_OFFSET]
    mov r14, rsi
    mov r15, rdx

    cmp r13, NULL       ; lista con elementos, busco lugar para insertar
    jne .searchWhereToAdd
    mov rdi, r12            
    call listAddFirst
    jmp .end

.searchWhereToAdd:
    mov rdi, r14
    mov rsi, qword [r13 + ELEM_DATA_OFFSET]
    call r15                                    ; comparo usando *funcComp
    cmp rax, -1
    jne .addHere
    mov r13, qword [r13 + ELEM_NEXT_OFFSET]
    cmp r13, NULL
    je .addLast
    jmp .searchWhereToAdd

.addHere:
    mov rdi, ELEM_SIZE
    call malloc
    mov rdi, qword [r13 + ELEM_PREV_OFFSET]
    ; r13 <-- next
    ; rdi <-- prev
    
    mov qword [rax + ELEM_DATA_OFFSET], r14
    mov qword [rax + ELEM_PREV_OFFSET], rdi
    mov qword [rax + ELEM_NEXT_OFFSET], r13
    mov qword [r13 + ELEM_PREV_OFFSET], rax
    cmp rdi, NULL   ; si no hay previo actualizo primero de la lista
    je .newFirst
    mov qword [rdi + ELEM_NEXT_OFFSET], rax
    jmp .end

.addLast:               ; reutilizo listaddlast si va al final
    mov rdi, r12
    mov rsi, r14
    call listAddLast
    jmp .end

.newFirst:
    mov qword [r12 + LIST_FIRST_OFFSET], rax

.end:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


listRemove:
    ;rdi list_t* l
    ;rsi void* data
    ;rdx funcCmp_t* fc
    ;rcx funcDelete_t* fd
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx
    mov r15, rcx

    cmp qword [r12 + LIST_FIRST_OFFSET], NULL   ; check empty list
    je .end

    mov rbx, qword [r12 + LIST_FIRST_OFFSET]
.nextElement:
    ; la comparacion se hace llamando a r14
    cmp rbx, NULL
    je .end
    mov rdi, qword [rbx + ELEM_DATA_OFFSET]
    mov rsi, r13
    call r14
    cmp rax, NULL
    je .delete
    mov rbx, qword [rbx + ELEM_NEXT_OFFSET]
    jmp .nextElement
.delete:                                        ; en r15 func delete
    cmp r15, NULL
    je .dontDeleteData
    mov rdi, qword [rbx + ELEM_DATA_OFFSET]
    call r15
.dontDeleteData:                                ; si funcdelete = 0 no borro el elemento
    mov rdx, qword [rbx + ELEM_PREV_OFFSET]
    mov rcx, qword [rbx + ELEM_NEXT_OFFSET]
    ; rdx <<< prev
    ; rcx <<< next
    cmp rdx, NULL
    jne .prevNotNull
    mov qword [r12 + LIST_FIRST_OFFSET], rcx
    jmp .continue
.prevNotNull:                                   ; re asigno links entre elementos
    mov qword [rdx + ELEM_NEXT_OFFSET], rcx
.continue:
    cmp rcx, NULL
    jne .nextNotNull
    mov qword [r12 + LIST_LAST_OFFSET], rdx
    jmp .freeNode
.nextNotNull:
    mov qword [rcx + ELEM_PREV_OFFSET], rdx
.freeNode:                                      ; ahora libero la memoria del nodo
    mov rdi, rbx
    mov rbx, qword [rbx + ELEM_NEXT_OFFSET]
    cmp rbx, NULL
    jne .freeAndLoop
    mov qword [r12 + LIST_LAST_OFFSET], rdx
.freeAndLoop:
    call free
    jmp .nextElement
.end:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

listRemoveFirst:
    ; rdi <-- *list
    ; rsi <-- *func_delete
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 8
    mov r12, rdi
    mov r13, rsi

    cmp qword [r12 + LIST_FIRST_OFFSET], NULL       ; check si len(lista)=0
    je .end

.useFuncDelete:
    mov r14, qword [r12 + LIST_FIRST_OFFSET]
    cmp qword [r14 + ELEM_NEXT_OFFSET], NULL        ; check si hay un solo elemento
    je .listHasOneElement

    mov rcx, qword [r14 + ELEM_NEXT_OFFSET]
    mov qword [rcx + ELEM_PREV_OFFSET], NULL
    mov qword [r12 + LIST_FIRST_OFFSET], rcx        ; reasigno el puntero al primero

    cmp r13, NULL
    je .deleteNode                                  ; si funcdelete es 0 no borro dato
    mov rdi, qword [r14 + ELEM_DATA_OFFSET]         ; por lo que no se hace rdi <-- data
    call r13
    jmp .deleteNode

.listHasOneElement:
    mov qword [r12 + LIST_FIRST_OFFSET], NULL       ; si era el unico elemento re asigno punteros de list
    mov qword [r12 + LIST_LAST_OFFSET], NULL
    cmp r13, NULL
    je .deleteNode
    mov rdi, qword [r14 + ELEM_DATA_OFFSET]
    call r13
.deleteNode:
    mov rdi, r14
    call free

.end:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


listRemoveLast:
    ; rdi <-- *list
    ; rsi <-- *func_delete
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi

    cmp qword [r12 + LIST_LAST_OFFSET], NULL        ; check list empty
    je .end

    mov r14, qword [r12 + LIST_LAST_OFFSET]
    cmp qword [r14 + ELEM_PREV_OFFSET], NULL        ; one element
    je .listHasOneElement

    mov r15, qword [r14 + ELEM_PREV_OFFSET]
    mov qword [r15 + ELEM_NEXT_OFFSET], NULL
    mov qword [r12 + LIST_LAST_OFFSET], r15

    mov rdi, qword [r14 + ELEM_DATA_OFFSET]
    cmp r13, NULL
    je .freeNode
    call r13
    jmp .freeNode

.listHasOneElement:
    mov qword [r12 + LIST_FIRST_OFFSET], NULL
    mov qword [r12 + LIST_LAST_OFFSET], NULL
    mov rdi, qword [r14 + ELEM_DATA_OFFSET]
    cmp r13, NULL
    je .freeNode
    call r13

.freeNode:
    mov rdi, r14
    call free
.end:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


listDelete:
    ; rdi <-- *list
    ; rsi <-- *funcdelete
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    cmp qword [r12 + LIST_FIRST_OFFSET], NULL   ; check list empty
    je .end

    mov r13, rsi
    mov r14, qword [r12 + LIST_FIRST_OFFSET]    ; r14 <-- current node

.loop:
    mov r15, qword [r14 + ELEM_NEXT_OFFSET]
    cmp r13, NULL
    je .deleteNode                              ;r15 <-- next node
    mov rdi, qword [r14 + ELEM_DATA_OFFSET]
    mov qword [r14 + ELEM_DATA_OFFSET], NULL
    call r13
.deleteNode:
    mov rdi, r14
    call free
    cmp r15, NULL                               ; check if end of list
    je .end
    mov r14, r15
    jmp .loop

.end:
    mov rdi, r12
    call free
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

listPrint:
    ; rdi <-- *list
    ; rsi <-- *pFile
    ; rdx <-- *funcPrint
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    mov r12, rdi
    mov r13, rsi
    mov r14, rdx 
    
    mov rdi, r13
    mov rsi, OPEN_BRACKET
    call fprintf
    
    cmp qword [r12 + LIST_FIRST_OFFSET], NULL
    je .end
    mov rbx, qword [r12 + LIST_FIRST_OFFSET]

.printEachElement:
    cmp rbx, NULL                               ; end of list?
    je .end
    mov rdi, qword [rbx + ELEM_DATA_OFFSET]     ; rdi <-- *data
    cmp rdi, NULL                               ; if pointer to data is null print next
    je .nextElement
    cmp r14, NULL                               ; if no print functon print pointer
    je .printPointer
    mov rsi, r13                                ; (*pFile)
    ; strPrint(char* a, FILE *pFile)
    ; rdi <-- *list
    ; rsi <-- *pFile
    ; rdx <-- *funcPrint
    call r14

    jmp .nextElement

.printPointer:
    mov rdi, r13
    mov rsi, POINTER_FORMAT
    mov rdx, qword [rbx + ELEM_DATA_OFFSET]
    call fprintf

.nextElement:
    cmp qword [rbx + ELEM_NEXT_OFFSET], NULL
    je .end

    mov rdi, r13
    mov rsi, COMMA
    call fprintf

    mov rbx, qword [rbx + ELEM_NEXT_OFFSET]
    jmp .printEachElement

.end:
    mov rdi, r13
    mov rsi, CLOSE_BRACKET
    call fprintf

    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


n3treeNew:
    push rbp
    mov rbp, rsp

    mov rdi, N3TREE_SIZE
    call malloc
    mov qword [rax + N3TREE_FIRST_OFFSET], NULL

    pop rbp
    ret

n3treeAdd:
    ; rdi <-- n3tree_t* t
    ; rsi <-- void* data
    ; rdx <-- funcCmp_t* fc
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 8
    mov r12, rdi    ; *n3tree
    mov r13, rsi    ; *data
    mov r14, rdx    ; *funcCmp

    cmp qword [rdi + N3TREE_FIRST_OFFSET], NULL     ; empty n3tree
    je .firstElem

    mov r12, qword [rdi + N3TREE_FIRST_OFFSET]      ; if not empty search where to add
    call search
    jmp .end

.firstElem:
    call createNewNodeAndInsert
    mov qword [r12 + N3TREE_FIRST_OFFSET], rax

.end:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


search:
    ; r12 <-- *elem
    ; r13 <-- void* data
    ; r14 <-- funcCmp_t* fc
    push rbp
    mov rbp, rsp
    push r12
    sub rsp, 8
    
    mov rdi, qword [r12 + N3TREE_ELEM_DATA_OFFSET]      ; rdi <-- *data de nodo actual
    mov rsi, r13                                        ; rsi <-- *data para agregar
    call r14                                            ; comparo para saber si ir izq, der o agregar
    cmp rax, NULL
    jl .goLeft
    jg .goRight
    call addElemToList
    jmp .end

    ; en cada chequeo si la sub rama es NULL creo un nuevo nodo y agrego
.goLeft:
    cmp qword [r12 + N3TREE_ELEM_LEFT_OFFSET], NULL
    jne .leftNotNull
    call createNewNodeAndInsert
    mov qword [r12 + N3TREE_ELEM_LEFT_OFFSET], rax
    jmp .end

.leftNotNull:
    mov r12, qword [r12 + N3TREE_ELEM_LEFT_OFFSET]
    call search
    jmp .end

.goRight:
    cmp qword [r12 + N3TREE_ELEM_RIGHT_OFFSET], NULL
    jne .rightNotNull
    call createNewNodeAndInsert
    mov qword [r12 + N3TREE_ELEM_RIGHT_OFFSET], rax
    jmp .end

.rightNotNull:
    mov r12, qword [r12 + N3TREE_ELEM_RIGHT_OFFSET]
    call search

.end:
    add rsp, 8
    pop r12
    pop rbp
    ret


addElemToList:
    ; r12 <-- *ntree_elem actual
    ; r13 <-- *data para agregar
    push rbp
    mov rbp, rsp
    mov rdi, qword [r12 + N3TREE_ELEM_CENTER_OFFSET]
    mov rsi, r13
    call listAddFirst
    pop rbp
    ret


createNewNodeAndInsert:
    ; r13 <-- *data para agregar
    push rbp
    mov rbp, rsp
    mov rdi, N3TREE_ELEM_SIZE
    call malloc
    
    mov qword [rax + N3TREE_ELEM_DATA_OFFSET], r13
    mov qword [rax + N3TREE_ELEM_LEFT_OFFSET], NULL
    mov qword [rax + N3TREE_ELEM_RIGHT_OFFSET], NULL

    push rax
    sub rsp, 8
    call listNew
    mov rdi, rax
    add rsp, 8
    pop rax
    mov qword [rax + N3TREE_ELEM_CENTER_OFFSET], rdi
    pop rbp
    ret


n3treeRemoveEq:
    ; rdi <-- n3tree_t* t
    ; rsi <-- funcDelete_t* fd
    push rbp
    mov rbp, rsp
    push r12
    push r13
    mov r12, rdi
    mov r13, rsi

    cmp qword [r12 + N3TREE_FIRST_OFFSET], NULL     ; check empty n3tree
    je .end
    mov r12, qword [r12 + N3TREE_FIRST_OFFSET]
    call searchAndRemoveEQ

.end:
    pop r13
    pop r12
    pop rbp
    ret


searchAndRemoveEQ:
    ; rdi <-- n3tree_t eleme* t
    ; rsi <-- funcDelete_t* fd
    push rbp
    mov rbp, rsp
    push r12
    push r13

    cmp qword [r12 + N3TREE_ELEM_CENTER_OFFSET], NULL
    je .noList
    mov rdi, qword [r12 + N3TREE_ELEM_CENTER_OFFSET]        ; delete list
    mov rsi, r13
    call listDelete       
    call listNew                                            ; adds new list
    mov qword [r12 + N3TREE_ELEM_CENTER_OFFSET], rax
.noList:
    cmp qword [r12 + N3TREE_ELEM_LEFT_OFFSET], NULL         ; deletes left branch if exists
    je .noLeft
    push r12
    push r13
    mov r12, qword [r12 + N3TREE_ELEM_LEFT_OFFSET]
    call searchAndRemoveEQ
    pop r13
    pop r12
.noLeft:
    cmp qword [r12 + N3TREE_ELEM_RIGHT_OFFSET], NULL        ; deletes left branch if exists
    je .noRight
    push r12
    push r13
    mov r12, qword [r12 + N3TREE_ELEM_RIGHT_OFFSET]
    call searchAndRemoveEQ
    pop r13
    pop r12
.noRight:
    pop r13
    pop r12
    pop rbp
    ret


n3treeDelete:
    ; rdi <-- n3tree_t* t
    ; rsi <-- funcDelete_t* fd
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 8
    mov r12, rdi
    mov r13, rsi
    mov r14, rdi

    cmp qword [r12 + N3TREE_FIRST_OFFSET], NULL     ; check empty n3tree
    je .end

.useFuncDelete:
    ; r13 = funcDelete
    mov r12, qword [r12 + N3TREE_FIRST_OFFSET]      ; function to delete nodes
    call deleteAllNodes

.end:                                               ; finally free *n3tree memory
    mov rdi, r14
    call free
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


deleteAllNodes:
    ; r12 <-- *elemt 
    ; r13 <-- funcDelete_t* fd
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 8

    mov r14, r12
    mov rdi, qword [r12 + N3TREE_ELEM_DATA_OFFSET]
    cmp r13, NULL                                           ; si funcdelete es 0 no se borra data
    je .dontdelete
    call r13
.dontdelete:
    cmp qword [r12 + N3TREE_ELEM_CENTER_OFFSET], NULL
    je .noList
    mov rdi, qword [r12 + N3TREE_ELEM_CENTER_OFFSET]
    mov rsi, r13
    call listDelete
.noList:
    cmp qword [r12 + N3TREE_ELEM_LEFT_OFFSET], NULL         ; delete left y right recursivamente
    je .noLeft
    mov r12, qword [r12 + N3TREE_ELEM_LEFT_OFFSET]
    call deleteAllNodes
    mov r12, r14
.noLeft:
    cmp qword [r12 + N3TREE_ELEM_RIGHT_OFFSET], NULL
    je .noRight
    mov r12, qword [r12 + N3TREE_ELEM_RIGHT_OFFSET]
    call deleteAllNodes
    mov r12, r14
.noRight:
    mov rdi, r14
    call free

    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


nTableNew:
    ; edi <-- uint32_t size
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    mov r12d, edi                                       ; r12 size (la parte alta se elimina)
    mov rdi, NTABLE_SIZE
    call malloc
    mov qword [rax + NTABLE_SIZE_OFFSET], r12
    mov r13, rax                                        ; r13 <-- *ntable

    ; r12 size
    ; r13 *ntable
    shl r12, 3                                          ; r12 <-- cantidad de slots en bytes
    mov rdi, r12
    call malloc
    mov r14, rax                                        ; r14 **listarray

    ; r12 size * 8
    ; r13 *ntable
    ; r14 list** array
    xor r15, r15
.loop:
    cmp r15, r12
    je .end
    call listNew
    mov qword [r14 + r15], rax
    add r15, 8
    jmp .loop

.end:
    mov qword [r13 + NTABLE_LIST_OFFSET], r14
    mov rax, r13

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


nTableAdd:
    ; rdi <-- ntable*
    ; esi <-- slot
    ; rdx <-- data*
    ; rcx <-- funcCmp*
    push rbp
    mov rbp, rsp
    push r12
    sub rsp, 8

    push rdx
    push rcx
    xor rdx, rdx
    mov eax, esi
    mov ecx, dword [rdi + NTABLE_SIZE_OFFSET]       ; busco tener en rsi <-- rsi % ntable.size
    div ecx
    mov esi, edx
    pop rcx
    pop rdx

    mov r12, qword [rdi + NTABLE_LIST_OFFSET]
    shl rsi, 3                                      ; slot offset en bytes
    
    ;listAdd
    ;rdi <-- list_t* l
    ;rsi <-- void* data
    ;rdx <-- funcCmp_t* fc
    mov rdi, qword [r12 + rsi]
    mov rsi, rdx
    mov rdx, rcx
    call listAdd
    add rsp, 8
    pop r12
    pop rbp
    ret
    

nTableRemoveSlot:
    ; rdi <-- nTable_t* t
    ; esi <-- uint32_t slot
    ; rdx <-- void* data
    ; rcx <-- funcCmp_t* fc
    ; r8  <-- funcDelete_t* fd
    push rbp
    mov rbp, rsp
    
    push rdx
    push rcx
    xor rdx, rdx
    mov eax, esi
    mov ecx, dword [rdi + NTABLE_SIZE_OFFSET]       ; busco rsi <-- rsi % table.size
    div ecx
    mov esi, edx
    pop rcx
    pop rdx

    mov rax, qword [rdi + NTABLE_LIST_OFFSET]
    shl rsi, 3                                      ; size offset en bytes

    mov rdi, qword [rax + rsi]
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    ;listRemove(list_t* l, void* data, funcCmp_t* fc, funcDelete_t* fd)
    call listRemove
    pop rbp
    ret
    

nTableDeleteSlot:
    ; rdi <-- nTable_t* t
    ; rsi <-- uint32_t slot
    ; rdx <-- funcDelete_t* fd
    push rbp
    mov rbp, rsp
    push r12
    sub rsp, 8

    push rdx
    push rcx
    xor rdx, rdx
    mov eax, esi
    mov ecx, dword [rdi + NTABLE_SIZE_OFFSET]       ; busco rsi <-- rsi % table.size
    div ecx
    mov esi, edx
    pop rcx
    pop rdx

    mov r12, qword [rdi + NTABLE_LIST_OFFSET]
    shl rsi, 3                                      ; slot offset en bytes
    add r12, rsi                                    ; lo sumo a r12 para preservarlo

    mov rdi, qword [r12]
    mov rsi, rdx
    call listDelete
    mov rdi, LIST_SIZE
    call listNew
    mov qword [r12], rax
    
    add rsp, 8
    pop r12
    pop rbp
    ret


nTableDelete:
    ; rdi <-- nTable_t* t
    ; rsi <-- funcDelete_t* fd
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov rbx, rsi
    mov r12, qword [rdi + NTABLE_LIST_OFFSET]
    mov r13, qword [rdi + NTABLE_SIZE_OFFSET]
    xor r14, r14
    mov r15, rdi
.nextSlot:
    cmp r14, r13                                ; check if last slot
    je .end
    mov rdi, qword [r12 + r14 * 8]              ; get slot's list
    mov rsi, rbx
    call listDelete
    inc r14
    jmp .nextSlot
.end:
    mov rdi, r12                                ; delete table
    call free
    mov rdi, r15
    call free                                   ; delete pointer to table

    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret