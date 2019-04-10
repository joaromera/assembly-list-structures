%ifndef MACROS_ASM


%macro PROLOGUE 0
    push rbp
    mov rbp, rsp
%endmacro

%macro EPILOGUE 0
    pop rbp
    ret
%endmacro


%endif