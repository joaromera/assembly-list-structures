%include "macros.asm"

section .data

NULL_STRING db 'NULL',0
OPEN_BRACKET db '[',0
COMMA db ',',0
CLOSE_BRACKET db ']',0
POINTER_FORMAT db '%p',0

section .rodata

section .text

%define NULL 0
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

    push rdi
    xor rax, rax

.loop:
    cmp byte [rdi], NULL
    je .end
    inc rax
    inc rdi
    jmp .loop

.end:
    pop rdi
    pop rbp
    ret


strClone:
    push rbp
    mov rbp, rsp
    push rdi
    push r12
    push r13
    push r14

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
    mov r14b, byte [r12 + rcx]
    mov byte [rax + rcx], r14b
    inc rcx
    jmp .loop

.end:
    mov byte [rax + rcx], NULL
    pop r14
    pop r13
    pop r12
    pop rdi
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
    jg .rdiShortest
    jl .rsiShortest
    inc rcx
    jmp .loop

.rdiMaybeShortest:
    cmp byte [rsi + rcx], NULL
    je .end
    jmp .rdiShortest

.rdiShortest:
    mov rax, 1
    jmp .end

.rsiShortest:
    mov rax, -1
    jmp .end

.end:
    pop rbp
    ret

strConcat:
    PROLOGUE

    push rdi
    push rsi
    call strLen
    pop rsi
    pop rdi

    mov rcx, rax

    push rcx
    push rdi
    push rsi
    sub rsp, 8
    xchg rdi, rsi
    call strLen
    add rsp, 8
    pop rsi
    pop rdi
    pop rcx
    add rcx, rax
    inc rcx


    push rcx
    push rdi
    push rsi
    xchg rcx, rdi

    sub rsp, 8
    call malloc
    add rsp, 8
    pop rsi
    pop rdi
    pop rcx
    dec rcx

    xor rcx, rcx
    xor rdx, rdx

.concatFirst:
    cmp byte [rdi + rcx], NULL
    je .concatSecondInit
    mov r10b, byte [rdi + rcx]
    mov byte [rax + rcx], r10b
    inc rcx
    inc rdx
    jmp .concatFirst

.concatSecondInit:
    xor rcx, rcx

.concatSecond:
    cmp byte [rsi + rcx], NULL
    je .end
    mov r10b, byte [rsi + rcx]
    mov byte [rax + rdx], r10b
    inc rcx
    inc rdx
    jmp .concatSecond

.end:
    mov byte [rax + rdx], NULL
    push rsi
    push rax
    call strDelete
    pop rax
    pop rsi
    mov rdi, rsi
    push rax
    sub rsp, 8
    call strDelete
    add rsp, 8
    pop rax
    EPILOGUE

strDelete:
    push rbp
    mov rbp, rsp
    call free
    pop rbp
    ret
 
strPrint:
    push rbp
    mov rbp, rsp
    push rdi
    push rsi

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
    pop rsi
    pop rdi
    pop rbp
    ret


listNew:
    push rbp
    mov rbp, rsp
    xor rdi, rdi
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
    xor rdi, rdi
    mov rdi, ELEM_SIZE
    call malloc
    pop rsi
    pop rdi

    mov qword [rax], rsi
    mov qword [rax + ELEM_NEXT_OFFSET], NULL
    mov qword [rax + ELEM_PREV_OFFSET], NULL

    cmp qword [rdi + LIST_FIRST_OFFSET], NULL
    je .firstToAdd

    mov rdx, [rdi + LIST_FIRST_OFFSET]

    cmp qword [rdx + ELEM_NEXT_OFFSET], NULL
    je .secondToAdd

    mov [rax + ELEM_NEXT_OFFSET], rdx
    mov [rdx + ELEM_PREV_OFFSET], rax
    mov qword [rdi + LIST_FIRST_OFFSET], rax
    jmp .end

.firstToAdd:

    mov qword [rdi + LIST_FIRST_OFFSET], rax
    mov qword [rdi + LIST_LAST_OFFSET], rax
    jmp .end

.secondToAdd:

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
    je .firstToAdd

    mov rdx, [rdi + LIST_LAST_OFFSET]

    cmp qword [rdx + ELEM_PREV_OFFSET], NULL
    je .secondToAdd

    mov [rax + ELEM_PREV_OFFSET], rdx
    mov [rdx + ELEM_NEXT_OFFSET], rax
    jmp .end

.firstToAdd:

    mov qword [rdi + LIST_FIRST_OFFSET], rax
    mov qword [rdi + LIST_LAST_OFFSET], rax
    jmp .end

.secondToAdd:

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

    cmp qword [rdi + LIST_FIRST_OFFSET], NULL
    je .end

    mov rdx, qword [rdi + LIST_FIRST_OFFSET]
    cmp qword [rdx + ELEM_NEXT_OFFSET], NULL
    je .listHasOneElement

    mov rcx, qword [rdx + ELEM_NEXT_OFFSET]
    mov qword [rcx + ELEM_PREV_OFFSET], NULL
    mov qword [rdi + LIST_FIRST_OFFSET], rcx

    mov rdi, qword [rdx + ELEM_DATA_OFFSET]
    push rdx
    sub rsp, 8
    cmp rsi, NULL
    jne .callRSIfun
    call free
    jmp .unstack

.callRSIfun:
    call rsi

.unstack:
    add rsp, 8
    pop rdx

    mov rdi, rdx
    call free
    jmp .end

.listHasOneElement:
    mov qword [rdi + LIST_FIRST_OFFSET], NULL
    mov qword [rdi + LIST_LAST_OFFSET], NULL
    mov rdi, qword [rdx + ELEM_DATA_OFFSET]
    push rdx
    sub rsp, 8
    cmp rsi, NULL
    jne .callRSIfun2
    call free
    jmp .unstack2

.callRSIfun2:
    call rsi

.unstack2:
    add rsp, 8
    pop rdx

    mov rdi, rdx
    call free

.end:
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
    mov r13, rsi
    mov r14, qword [r12 + LIST_FIRST_OFFSET]        ;r14 <-- actual

.loop:
    cmp r14, NULL
    je .end
    mov r15, qword [r14 + ELEM_NEXT_OFFSET]         ;r15 <-- next
    mov rdi, [r14 + ELEM_DATA_OFFSET]
    cmp r13, NULL
    je .useFuncDelete
    call free
    jmp .datasMemoryFreed

.useFuncDelete:
    call r13

.datasMemoryFreed:
    mov rdi, r14
    call free

    mov r14, r15
    mov r15, [r15 + ELEM_NEXT_OFFSET]
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
    mov rbx, [r12 + LIST_FIRST_OFFSET]

.loop:
    cmp r14, NULL
    je .printPointer
    mov rdi, [rbx + ELEM_DATA_OFFSET]
    mov rsi, r13
    call r14

    jmp .nextElement

.printPointer:
    mov rdi, r13
    mov rsi, POINTER_FORMAT
    mov rdx, [rbx + ELEM_DATA_OFFSET]
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
    PROLOGUE

    mov rdi, N3TREE_SIZE
    call malloc
    mov qword [rax + N3TREE_FIRST_OFFSET], NULL

    EPILOGUE

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
    PROLOGUE
    mov rdi, qword [r12 + N3TREE_ELEM_DATA_OFFSET]
    mov rsi, r13
    call r14
    cmp rax, NULL
    jl .goLeft
    jg .goRight
    call addElemToList
    EPILOGUE

.goLeft:
    cmp qword [r12 + N3TREE_ELEM_LEFT_OFFSET], NULL
    jne .leftNotNull
    call createNewNodeAndInsert
    mov qword [r12 + N3TREE_ELEM_LEFT_OFFSET], rax
    EPILOGUE
.leftNotNull:
    mov r12, qword [r12 + N3TREE_ELEM_LEFT_OFFSET]
    call search
    EPILOGUE

.goRight:
    cmp qword [r12 + N3TREE_ELEM_RIGHT_OFFSET], NULL
    jne .rightNotNull
    call createNewNodeAndInsert
    mov qword [r12 + N3TREE_ELEM_RIGHT_OFFSET], rax
    EPILOGUE
.rightNotNull:
    mov r12, qword [r12 + N3TREE_ELEM_RIGHT_OFFSET]
    call search
    EPILOGUE



addElemToList:
    PROLOGUE
    mov rdi, qword [r12 + N3TREE_ELEM_CENTER_OFFSET]
    mov rsi, r13
    call listAddFirst
    EPILOGUE



createNewNodeAndInsert:
    PROLOGUE
    mov rdi, N3TREE_ELEM_SIZE
    call malloc
    
    mov qword [rax + N3TREE_ELEM_DATA_OFFSET], r13
    mov qword [rax + N3TREE_ELEM_LEFT_OFFSET], NULL
    mov qword [rax + N3TREE_ELEM_RIGHT_OFFSET], NULL

    push rax
    sub rsp, 8
    call listNew
    add rsp, 8
    mov rdi, rax
    pop rax
    mov qword [rax + N3TREE_ELEM_CENTER_OFFSET], rdi
    EPILOGUE

n3treeRemoveEq:
    ret

n3treeDelete:
    ret

nTableNew:
    ret

nTableAdd:
    ret
    
nTableRemoveSlot:
    ret
    
nTableDeleteSlot:
    ret

nTableDelete:
    ret
