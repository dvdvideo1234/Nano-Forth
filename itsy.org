%include "macros.asm"

        org 0100h
        jmp xt_abort+2

; -------------------
; Variables
; -------------------

        variable 'state',state,0

        variable '>in',to_in,0

        variable '#tib',number_t_i_b,0

        variable 'dp',dp,freemem

        variable 'base',base,10

        variable 'last',last,final

        constant 'tib',t_i_b,32768

; -------------------
; Initialisation
; -------------------

        primitive 'abort',abort
        mov ax,word[val_number_t_i_b]
        mov word[val_to_in],ax
        xor bp,bp
        mov word[val_state],bp
        mov sp,-256
        mov si,xt_interpret+2
        jmp next

; -------------------
; Compilation
; -------------------

        primitive ',',comma
        mov di,word[val_dp]
        xchg ax,bx
        stosw
        mov word[val_dp],di
        pop bx
        jmp next

        primitive 'lit',lit
        push bx
        lodsw
        xchg ax,bx
        jmp next

; -------------------
; Stack
; -------------------

        primitive 'rot',rote
        pop dx
        pop ax
        push dx
        push bx
        xchg ax,bx
        jmp next

        primitive 'drop',drop
        pop bx
        jmp next

        primitive 'dup',dupe
        push bx
        jmp next

        primitive 'swap',swap
        pop ax
        push bx
        xchg ax,bx
        jmp next

; -------------------
; Maths / Logic
; -------------------

        primitive '+',plus
        pop ax
        add bx,ax
        jmp next

        primitive '=',equals
        pop ax
        sub bx,ax
        sub bx,1
        sbb bx,bx
        jmp next

; -------------------
; Peek and Poke
; -------------------

        primitive '@',fetch
        mov bx,word[bx]
        jmp next

        primitive '!',store 
        pop word[bx]
        pop bx
        jmp next

; -------------------
; Inner Interpreter
; -------------------

next    lodsw
        xchg di,ax
        jmp word[di]

; -------------------
; Flow Control
; -------------------

        primitive '0branch',zero_branch
        lodsw
        test bx,bx
        jne zerob_z
        xchg ax,si
zerob_z pop bx
        jmp next

        primitive 'branch',branch
        mov si,word[si]
        jmp next

        primitive 'execute',execute
        mov di,bx
        pop bx
        jmp word[di]

        primitive 'exit',exit
        mov si,word[bp]
        inc bp
        inc bp
        jmp next

; -------------------
; String
; -------------------

        primitive 'count',count
        inc bx
        push bx
        mov bl,byte[bx-1]
        mov bh,0
        jmp next

        primitive '>number',to_number
        pop di
        pop cx
        pop ax
to_numl test bx,bx
        je to_numz
        push ax
        mov al,byte[di]
        cmp al,'a'
        jc to_nums
        sub al,32
to_nums cmp al,'9'+1
        jc to_numg
        cmp al,'A'
        jc to_numh
        sub al,7
to_numg sub al,48
        mov ah,0
        cmp al,byte[val_base]
        jnc to_numh
        xchg ax,dx
        pop ax
        push dx
        xchg ax,cx
        mul word[val_base]
        xchg ax,cx
        mul word[val_base]
        add cx,dx
        pop dx
        add ax,dx
        dec bx
        inc di
        jmp to_numl
to_numz push ax
to_numh push cx
        push di
        jmp next

; -----------------------
; Terminal Input / Output
; -----------------------

        primitive 'accept',accept
        pop di
        xor cx,cx
acceptl call getchar
        cmp al,8
        jne acceptn
        jcxz acceptb
        call outchar
        mov al,' '
        call outchar
        mov al,8
        call outchar
        dec cx
        dec di
        jmp acceptl
acceptn cmp al,13
        je acceptz
        cmp cx,bx
        jne accepts
acceptb mov al,7
        call outchar
        jmp acceptl
accepts stosb
        inc cx
        call outchar
        jmp acceptl
acceptz jcxz acceptb
        mov al,13
        call outchar
        mov al,10
        call outchar
        mov bx,cx
        jmp next

        primitive 'word',word
        mov di,word[val_dp]
        push di
        mov dx,bx
        mov bx,word[val_t_i_b]
        mov cx,bx
        add bx,word[val_to_in]
        add cx,word[val_number_t_i_b]
wordf   cmp cx,bx
        je wordz
        mov al,byte[bx]
        inc bx
        cmp al,dl
        je wordf
wordc   inc di
        mov byte[di],al
        cmp cx,bx
        je wordz
        mov al,byte[bx]
        inc bx
        cmp al,dl
        jne wordc
wordz   mov byte[di+1],32
        mov ax,word[val_dp]
        xchg ax,di
        sub ax,di
        mov byte[di],al
        sub bx,word[val_t_i_b]
        mov word[val_to_in],bx
        pop bx
        jmp next

        primitive 'emit',emit
        xchg ax,bx
        call outchar
        pop bx
        jmp next

getchar mov ah,7
        int 021h
        mov ah,0
        ret

outchar xchg ax,dx
        mov ah,2
        int 021h
        ret

; -----------------------
; Dictionary Search
; -----------------------

        primitive 'find',find
        mov di,val_last
findl   push di
        push bx
        mov cl,byte[bx]
        mov ch,0
        inc cx
findc   mov al,byte[di+2]
        and al,07Fh
        cmp al,byte[bx]
        je findm
        pop bx
        pop di
        mov di,word[di]
        test di,di
        jne findl
findnf  push bx
        xor bx,bx
        jmp next
findm   inc di
        inc bx
        loop findc
        pop bx
        pop di
        mov bx,1
        inc di
        inc di
        mov al,byte[di]
        test al,080h
        jne findi
        neg bx
findi   and ax,31
        add di,ax
        inc di
        push di
        jmp next

; -----------------------
; Colon Definition
; -----------------------

        colon ':',colon
        dw xt_lit,-1,xt_state,xt_store,xt_create
        dw xt_do_semi_code
docolon dec bp
        dec bp
        mov word[bp],si
        lea si,[di+2]
        jmp next

        colon ';',semicolon,immediate
        dw xt_lit,xt_exit,xt_comma,xt_lit,0,xt_state
        dw xt_store,xt_exit

; -----------------------
; Headers
; -----------------------

        colon 'create',create
        dw xt_dp,xt_fetch,xt_last,xt_fetch,xt_comma
        dw xt_last,xt_store,xt_lit,32,xt_word,xt_count
        dw xt_plus,xt_dp,xt_store,xt_lit,0,xt_comma
        dw xt_do_semi_code
dovar   push bx
        lea bx,[di+2]
        jmp next

        primitive '(;code)',do_semi_code
        mov di,word[val_last]
        mov al,byte[di+2]
        and ax,31
        add di,ax
        mov word[di+3],si
        mov si,word[bp]
        inc bp
        inc bp
        jmp next

; -----------------------
; Constants
; -----------------------

        colon 'constant',constant
        dw xt_create,xt_comma,xt_do_semi_code
doconst push bx
        mov bx,word[di+2]
        jmp next

; -----------------------
; Outer Interpreter
; -----------------------

final:
        colon 'interpret',interpret
interpt dw xt_number_t_i_b,xt_fetch,xt_to_in,xt_fetch
        dw xt_equals,xt_zero_branch,intpar,xt_t_i_b
        dw xt_lit,50,xt_accept,xt_number_t_i_b,xt_store
        dw xt_lit,0,xt_to_in,xt_store
intpar  dw xt_lit,32,xt_word,xt_find,xt_dupe
        dw xt_zero_branch,intnf,xt_state,xt_fetch
        dw xt_equals,xt_zero_branch,intexc,xt_comma
        dw xt_branch,intdone
intexc  dw xt_execute,xt_branch,intdone
intnf   dw xt_dupe,xt_rote,xt_count,xt_to_number
        dw xt_zero_branch,intskip,xt_state,xt_fetch
        dw xt_zero_branch,intnc,xt_last,xt_fetch,xt_dupe
        dw xt_fetch,xt_last,xt_store,xt_dp,xt_store
intnc   dw xt_abort
intskip dw xt_drop, xt_drop, xt_state, xt_fetch
        dw xt_zero_branch,intdone,xt_lit,xt_lit,xt_comma
        dw xt_comma
intdone dw xt_branch,interpt

freemem: