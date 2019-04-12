section .data

NULL_STRING db 'NULL',0
OPEN_BRACKET db '[',0
COMMA db ',',0
CLOSE_BRACKET db ']',0
POINTER_FORMAT db '%p',0

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
    push rbp
    mov rbp, rsp
    xor rax, rax

.loop:
    cmp byte [rdi], NULL
    je .end
    inc rax
    inc rdi
    jmp .loop

.end:
    pop rbp
    ret


strClone:
    push rbp
    mov rbp, rsp
    push r12
    push r13

    mov r12, rdi
    call strLen
    mov r13, rax
    mov rdi, rax
    inc rdi
    call malloc
    
    xor rcx, rcx
.loop:
    cmp rcx, r13
    je .end
    mov r10b, byte [r12 + rcx]
    mov byte [rax + rcx], r10b
    inc rcx
    jmp .loop

.end:
    mov byte [rax + rcx], NULL
    pop r13
    pop r12
    pop rbp
    ret


strCmp:
    push rbp
    mov rbp, rsp
    xor rax, rax
    xor rcx, rcx

.loop:
    cmp byte [rdi + rcx], NULL
    je .rdiMaybeShortest
    mov dl, byte [rdi + rcx]
    cmp byte [rsi + rcx], dl
    jg .rdiSmaller
    jl .rsiSmaller
    inc rcx
    jmp .loop

.rdiMaybeShortest:
    cmp byte [rsi + rcx], NULL
    je .end                         ; a = b
    jmp .rdiSmaller

.rdiSmaller:
    mov rax, 1
    jmp .end

.rsiSmaller:
    mov rax, -1

.end:
    pop rbp
    ret

strConcat:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 8

    mov r12, rdi
    mov r13, rsi
    call strLen
    mov r14, rax
    mov rdi, r13
    call strLen
    add r14, rax
    inc r14
    mov rdi, r14
    call malloc
    mov r14, rax

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

    mov rdi, r12
    call strDelete
    mov rdi, r13
    call strDelete

    mov rax, r14

    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


strDelete:
    push rbp
    mov rbp, rsp
    call free
    pop rbp
    ret


strPrint:
    push rbp
    mov rbp, rsp

    cmp byte [rdi], NULL
    je .printNULL

    xchg rdi, rsi
    call fprintf
    jmp .end

.printNULL:
    mov rdi, qword NULL_STRING
    xchg rdi, rsi
    call fprintf

.end:
    pop rbp
    ret


listNew:
    push rbp
    mov rbp, rsp
    mov rdi, qword LIST_SIZE
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
    mov rdi, qword ELEM_SIZE
    call malloc
    pop rsi
    pop rdi

    mov qword [rax], rsi
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
    ret

listRemove:
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

    cmp qword [r12 + LIST_FIRST_OFFSET], NULL
    je .end

    cmp r13, NULL
    jne .useFuncDelete
    mov r13, free

.useFuncDelete:
    mov r14, qword [r12 + LIST_FIRST_OFFSET]
    cmp qword [r14 + ELEM_NEXT_OFFSET], NULL
    je .listHasOneElement

    mov rcx, qword [r14 + ELEM_NEXT_OFFSET]
    mov qword [rcx + ELEM_PREV_OFFSET], NULL
    mov qword [r12 + LIST_FIRST_OFFSET], rcx

    mov rdi, qword [r14 + ELEM_DATA_OFFSET]
    call r13
    jmp .end

.listHasOneElement:
    mov qword [r12 + LIST_FIRST_OFFSET], NULL
    mov qword [r12 + LIST_LAST_OFFSET], NULL
    mov rdi, qword [r14 + ELEM_DATA_OFFSET]
    call r13

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

    cmp qword [r12 + LIST_LAST_OFFSET], NULL
    je .end

    mov r14, qword [r12 + LIST_LAST_OFFSET]
    cmp qword [r14 + ELEM_PREV_OFFSET], NULL
    je .listHasOneElement

    mov r15, qword [r14 + ELEM_PREV_OFFSET]
    mov qword [r15 + ELEM_NEXT_OFFSET], NULL
    mov qword [r12 + LIST_LAST_OFFSET], r15

    mov rdi, qword [r14 + ELEM_DATA_OFFSET]
    cmp r13, NULL
    jne .callRSIfun
    call free
    jmp .freeNode

.callRSIfun:
    call r13
    jmp .freeNode

.listHasOneElement:
    mov qword [r12 + LIST_FIRST_OFFSET], NULL
    mov qword [r12 + LIST_LAST_OFFSET], NULL
    mov rdi, qword [r14 + ELEM_DATA_OFFSET]
    cmp r13, NULL
    jne .callRSIfun2
    call free
    jmp .freeNode

.callRSIfun2:
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
    cmp qword [r12 + LIST_FIRST_OFFSET], NULL
    je .end

    mov r13, rsi
    cmp r13, NULL
    jne .useFuncDelete
    mov r13, free

.useFuncDelete:
    mov r14, qword [r12 + LIST_FIRST_OFFSET]

.loop:
    cmp qword [r14 + ELEM_NEXT_OFFSET], NULL
    je .end
    mov r15, qword [r14 + ELEM_NEXT_OFFSET]         ;r15 <-- next
    mov rdi, qword [r14 + ELEM_DATA_OFFSET]
    call r13
    mov r14, r15
    mov r15, qword [r15 + ELEM_NEXT_OFFSET]
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
    mov rsi, qword OPEN_BRACKET
    call fprintf
    
    cmp qword [r12 + LIST_FIRST_OFFSET], NULL
    je .end
    mov rbx, qword [r12 + LIST_FIRST_OFFSET]

.loop:
    cmp r14, NULL
    je .printPointer
    mov rdi, qword [rbx + ELEM_DATA_OFFSET]
    mov rsi, r13
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
    mov rsi, qword COMMA
    call fprintf

    mov rbx, qword [rbx + ELEM_NEXT_OFFSET]
    jmp .loop

.end:
    mov rdi, r13
    mov rsi, qword CLOSE_BRACKET
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
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx

    cmp qword [rdi + N3TREE_FIRST_OFFSET], NULL
    je .firstElem

    mov r12, qword [rdi + N3TREE_FIRST_OFFSET]
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
    push rbp
    mov rbp, rsp
    mov rdi, qword [r12 + N3TREE_ELEM_DATA_OFFSET]
    mov rsi, r13
    call r14
    cmp rax, NULL
    jl .goLeft
    jg .goRight
    call addElemToList
    pop rbp
    ret

.goLeft:
    cmp qword [r12 + N3TREE_ELEM_LEFT_OFFSET], NULL
    jne .leftNotNull
    call createNewNodeAndInsert
    mov qword [r12 + N3TREE_ELEM_LEFT_OFFSET], rax
    pop rbp
    ret
.leftNotNull:
    mov r12, qword [r12 + N3TREE_ELEM_LEFT_OFFSET]
    call search
    pop rbp
    ret

.goRight:
    cmp qword [r12 + N3TREE_ELEM_RIGHT_OFFSET], NULL
    jne .rightNotNull
    call createNewNodeAndInsert
    mov qword [r12 + N3TREE_ELEM_RIGHT_OFFSET], rax
    pop rbp
    ret
.rightNotNull:
    mov r12, qword [r12 + N3TREE_ELEM_RIGHT_OFFSET]
    call search
    pop rbp
    ret

addElemToList:
    push rbp
    mov rbp, rsp
    mov rdi, qword [r12 + N3TREE_ELEM_CENTER_OFFSET]
    mov rsi, r13
    call listAddFirst
    pop rbp
    ret

createNewNodeAndInsert:
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

    cmp qword [r12 + N3TREE_FIRST_OFFSET], NULL
    je .end

    cmp r13, NULL
    jne .useFuncDelete
    mov r13, free

.useFuncDelete:
    ; r13 = funcDelete
    mov r12, qword [r12 + N3TREE_FIRST_OFFSET]
    call searchAndRemoveEQ

.end:
    pop r13
    pop r12
    pop rbp
    ret

searchAndRemoveEQ:
    push rbp
    mov rbp, rsp
    push r12
    push r13

    cmp qword [r12 + N3TREE_ELEM_CENTER_OFFSET], NULL
    je .noList
    mov rdi, qword [r12 + N3TREE_ELEM_CENTER_OFFSET]
    mov rsi, r13
    call listDelete
    call listNew
    mov qword [r12 + N3TREE_ELEM_CENTER_OFFSET], rax
.noList:
    cmp qword [r12 + N3TREE_ELEM_LEFT_OFFSET], NULL
    je .noLeft
    mov r12, qword [r12 + N3TREE_ELEM_LEFT_OFFSET]
    call searchAndRemoveEQ
.noLeft:
    cmp qword [r12 + N3TREE_ELEM_RIGHT_OFFSET], NULL
    je .noRight
    mov r12, qword [r12 + N3TREE_ELEM_RIGHT_OFFSET]
    call searchAndRemoveEQ
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

    cmp qword [r12 + N3TREE_FIRST_OFFSET], NULL
    je .end

    cmp r13, NULL
    jne .useFuncDelete
    mov r13, free

.useFuncDelete:
    ; r13 = funcDelete
    mov r12, qword [r12 + N3TREE_FIRST_OFFSET]
    call deleteAllNodes

.end:
    mov rdi, r14
    call free
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


deleteAllNodes:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 8
    mov r14, r12
    cmp qword [r12 + N3TREE_ELEM_CENTER_OFFSET], NULL
    je .noList
    mov rdi, qword [r12 + N3TREE_ELEM_CENTER_OFFSET]
    mov rsi, r13
    call listDelete
.noList:
    cmp qword [r12 + N3TREE_ELEM_LEFT_OFFSET], NULL
    je .noLeft
    mov r12, qword [r12 + N3TREE_ELEM_LEFT_OFFSET]
    call deleteAllNodes
.noLeft:
    cmp qword [r12 + N3TREE_ELEM_RIGHT_OFFSET], NULL
    je .noRight
    mov r12, qword [r12 + N3TREE_ELEM_RIGHT_OFFSET]
    call deleteAllNodes
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
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi                                    ; r12 size
    mov rdi, NTABLE_SIZE
    call malloc
    mov qword [rax + NTABLE_SIZE_OFFSET], r12
    mov r13, rax                                    ; r13 *ntable

    shl r12, 3
    mov rdi, r12
    call malloc
    mov r14, rax                                    ; r14 *listarray

    xor r15, r15
.loop:
    cmp r15, r12
    je .end
    call listNew
    mov qword [r14 + r15], rax
    add r15, 8
    jmp .loop

.end:
    mov rdi, POINTER_SIZE
    call malloc
    mov qword [rax], r14
    mov qword [r13 + NTABLE_LIST_OFFSET], rax
    mov rax, r13

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

nTableAdd:
    push rbp
    mov rbp, rsp
    push r12
    sub rsp, 8
    mov r12, qword [rdi + NTABLE_LIST_OFFSET]
    shl rsi, 3
    add r12, rsi
    ;(nTable_t* t, uint32_t slot, void* data, funcCmp_t* fc)
    ;listAdd(list_t* l, void* data, funcCmp_t* fc)
    mov rdi, qword [r12 + rsi]
    mov rsi, rdx
    mov rdx, rcx
    call listAdd
    add rsp, 8
    pop r12
    pop rbp
    ret
    
nTableRemoveSlot:
;(nTable_t* t, uint32_t slot, void* data, funcCmp_t* fc,
 ;     funcDelete_t* fd)
    ; rdi <-- nTable_t* t
    ; rsi <-- uint32_t slot
    ; rdx <-- void* data
    ; rcx <-- funcCmp_t* fc
    ; r8  <-- funcDelete_t* fd
    push rbp
    mov rbp, rsp
    mov rax, qword [rdi + NTABLE_LIST_OFFSET]
    shl rsi, 3
    add rax, rsi
    ;listRemove(list_t* l, void* data, funcCmp_t* fc, funcDelete_t* fd)
    mov rdi, qword [rax]
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    call listRemove
    pop rbp
    ret
    
nTableDeleteSlot:       ;(nTable_t* t, uint32_t slot, funcDelete_t* fd)
    push rbp
    mov rbp, rsp
    push r12
    sub rsp, 8
    mov r12, qword [rdi + NTABLE_LIST_OFFSET]
    shl rsi, 3
    add r12, rsi
    ;listDelete(list_t* l, funcDelete_t* fd)
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
    push r12
    push r13
    mov r12, qword [rdi + NTABLE_LIST_OFFSET]
    mov r13, qword [rdi + NTABLE_SIZE_OFFSET]
    xor r14, r14
.loop:
    cmp r14, r13
    je .end

    ;listDelete(list_t* l, funcDelete_t* fd)
    mov rdi, qword [r12]
    mov rsi, rdx
    call listDelete
    mov rdi, LIST_SIZE
    call listNew
    mov qword [r12], rax

    add qword r12, POINTER_SIZE
    inc r14
    jmp .loop
.end:
    pop r13
    pop r12
    pop rbp
    ret