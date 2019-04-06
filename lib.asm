section .data

NULL_STRING dw "NULL"

ELEM_SIZE db 24
ELEM_DATA_OFFSET db 0
ELEM_NEXT_OFFSET db 8
ELEM_PREV_OFFSET db 16

LIST_SIZE db 16
LIST_FIRST_OFFSET db 0
LIST_LAST_OFFSET db 8


section .rodata

section .text

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
    cmp byte [rdi], 0
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
    mov byte [rax + rcx], 0
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
    cmp byte [rdi + rcx], 0
    je .rdiMaybeShortest
    mov dl, byte [rdi + rcx]
    cmp byte [rsi + rcx], dl
    jg .rdiShortest
    jl .rsiShortest
    inc rcx
    jmp .loop

.rdiMaybeShortest:
    cmp byte [rsi + rcx], 0
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
    push rbp
    mov rbp, rsp

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
    cmp byte [rdi + rcx], 0
    je .concatSecondInit
    mov r10b, byte [rdi + rcx]
    mov byte [rax + rcx], r10b
    inc rcx
    inc rdx
    jmp .concatFirst

.concatSecondInit:
    xor rcx, rcx

.concatSecond:
    cmp byte [rsi + rcx], 0
    je .end
    mov r10b, byte [rsi + rcx]
    mov byte [rax + rdx], r10b
    inc rcx
    inc rdx
    jmp .concatSecond

.end:
    mov byte [rax + rdx], 0
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
    push rdi
    push rsi

    cmp byte [rdi], 0
    je .printNULL

    xchg rdi, rsi
    call fprintf
    jmp .end

.printNULL:
    mov dword rdi, NULL_STRING
    xchg rdi, rsi
    call fprintf

.end:
    pop rsi
    pop rdi
    pop rbp
    ret


;typedef struct s_list{
;   struct s_listElem *first;
;   struct s_listElem *last;
;} list_t;


listNew:
    push rbp
    mov rbp, rsp
    xor rdi, rdi
    mov rdi, LIST_SIZE
    call malloc
    mov qword [rax], 0
    mov qword [rax + 8], 0
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

    mov qword [rax], rsi
    mov qword [rax + ELEM_NEXT_OFFSET], 0
    mov qword [rax + ELEM_PREV_OFFSET], 0

    cmp qword [rdi + LIST_FIRST_OFFSET], 0
    je .firstToAdd

    mov rdx, [rdi + LIST_FIRST_OFFSET]

    cmp qword [rdx + ELEM_NEXT_OFFSET], 0
    je .secondToAdd

    mov [rax + ELEM_NEXT_OFFSET], rdx
    mov [rdx + ELEM_PREV_OFFSET], rax
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
    mov qword [rax + ELEM_NEXT_OFFSET], 0
    mov qword [rax + ELEM_PREV_OFFSET], 0

    cmp qword [rdi + LIST_LAST_OFFSET], 0
    je .firstToAdd

    mov rdx, [rdi + LIST_LAST_OFFSET]

    cmp qword [rdx + ELEM_PREV_OFFSET], 0
    je .secondToAdd

    mov [rax + ELEM_NEXT_OFFSET], rdx
    mov [rdx + ELEM_PREV_OFFSET], rax
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
    mov qword [rdi + LIST_FIRST_OFFSET], rcx

    mov rdi, qword [rdx + ELEM_DATA_OFFSET]
    push rdx
    sub rsp, 8
    cmp rsi, NULL
    jne .callRSIfun
    call free
    jmp .unstack

.callRSIfun:
    call [rsi]

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
    call [rsi]

.unstack2:
    add rsp, 8
    pop rdx

    mov rdi, rdx
    call free

.end:
    pop rbp
    ret

listRemoveLast:
    ret

listDelete:
    ret

listPrint:
    ret

n3treeNew:
    ret

n3treeAdd:
    ret

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
