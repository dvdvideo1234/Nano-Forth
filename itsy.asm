;VERSION T300
;IDEAL
;ABC		EQU <abc> 							;ABC = "abc"
;ABC2		EQU ABC							    ;ABC2 = "abc"
;ABC		EQU <def>                           ;ABC = "def" (redefined)
;ABC3		CATSTR ABC2,<,>,ABC,<,>,ABC2	    ;ABC3 = "abc, def, abc" .
;ABCLEN		SIZESTR ABC						    ;ABCLEN = 3
;ABC3LEN 	SIZESTR ABC3					    ;ABC3LEN = 11
;COMMA1 	INSTR ABC3,<,>					    ;COMMA1 = 4
;COMMA2 	INSTR COMMA1+1,ABC3,<,>			    ;COMMA2 = 8
;ABC4 		SUBSTR ABC3,5					    ;ABC4 = "def,abc"
;ABC5 		SUBSTR ABC3,5,3					    ;ABC5 = "def"
;ABC6 		EQU 3+2+1						    ;ABC6 = 6 (numeric equate)
;ABC7 		EQU %3+2+1						    ;ABC7 = "6" (text macro)
;ABC8 		EQU %COMMA 1					    ;ABC8 = "4"

ppp = 0
qqq = 0

SKIPA   MACRO
        DB    03DH
        ENDM

SKIPB   MACRO
        DB    03CH
        ENDM

SKIPr   MACRO reg
  mov   reg,0
  org   $-2
  ENDM

aname macro cnam
  local len,end
  db end-len
len:
  db cnam
end:
  endm
  
header macro cnam,anam,imm
qqq = $
  dw ppp
ppp = qqq
  aname cnam
_&anam:
  endm

variable macro cnam,anam,data
  header cnam,anam,0
  dw @dovar
@_&anam dw  data
  endm
  
constant macro cnam,anam,data
  header cnam,anam,0
  dw @doconst
@_&anam dw data
  endm
  
xt macro cnam,anam,adr
  header cnam,anam,0
  dw adr
  endm
		
primitive macro cnam,anam
  xt cnam,anam,$+2
  endm
		
colon macro cnam,anam
  header cnam,anam,0
  dw @docolon
  endm

jmps macro adr
  jmp short adr
  endm

MyCseg  segment para  use16

        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg, es: MyCseg
 
        org 0100h
		
Start   Label byte

  mov   bx,1000h     ; only 64k allocate
  mov   ah,4ah
  int   21h

; -------------------
; Initialisation
; -------------------

@abort:
        skipr bp
@bye:		
		dw 0	;addres of bye
        mov sp,-256
        call @does
		dw _lpar 						;init interpretter
@cicle	dw _expect,_eval,_noop,_BRAN,@cicle
_oper dw @wary,_execute,_to_num,_comma,_numc

_semi	dw @dovar ;
		
@do_semi_code:
        mov di,[@_last]
        mov al,[di+2]
        and ax,31
        add di,ax
        mov [di+3],si
@rts:
        mov si,[bp]
@rdrop:		
        inc bp
        inc bp
        jmps next
@doconst:
        mov ax,[di]
        jmp @ph
@accept:
        pop dx
		mov di,dx
		mov [di],bx
		mov ah,10
		int 21h
		lea bx,[di+1]
@count:
        inc bx
        push bx
		dec bx
@c@:		
        mov bl,[bx]
@lobyte:
        mov bh,0
        jmps next
@wary:
		shl bx,1
@bary:
		add bx,di
        jmps next
@strw:  
		lea ax,[bx+2]
		push ax
@fetch:
        mov bx,[bx]
        jmps next
		
@docolon:
		SKIPB
		db 1
		xchg ax,di
		jmps @pcpush
		
		scasw
		scasw
@does:
		pop ax
		push bx
		mov	 bx,di
@pcpush:		
		xchg ax,si
@rpushw:		
		dec bp
        dec bp
        mov [bp],ax
		skipa

; -------------------
; Inner Interpreter
; vvvvvvvvvvvvvvvvv

@ph:
        push bx
@sw:
        xchg ax,bx
next:   
		mov di,[si]
		cmpsw
next2:		
        jmp [di-2]

; ^^^^^^^^^^^^^^^^^^
; Inner Interpreter
; -------------------

@for:
	mov	si,[si]
@pushw:
	pop ax
	xchg ax,bx
	jmps @rpushw
	
@popw:
		mov	ax,[bp]
		inc bp
		inc bp
		jmps @ph
		
		scasw
		scasw
@dovar:  xchg ax,di
        jmps @ph
@dupe:
        push bx
        jmps next
@swap:
        pop ax
        jmps @ph
@lit:		
        lodsw
        jmps @ph
@rote:
        pop dx
        pop ax
        push dx
        jmps @ph
@execute:
        mov di,bx
		scasw
        pop bx
		jmps next2
@zero_branch:
        test bx,bx
        pop bx
        je @br
@skip:		
        lodsw
        jmps next
@mif:
		inc bx
@ifm:	
		dec bx
		js @skip
@br:
        mov si,[si]
        jmps next
@comma:		
        mov di,[@_dp]
        xchg ax,bx
        stosw
        mov [@_dp],di
		skipa
@store:		
        pop [bx]
@drp:		
        pop bx
        jmps next
@minus:
		neg bx
@plus:
        pop ax
        add bx,ax
        jmps next
@equals:
        pop ax
        sub bx,ax
@zeq:		
        sub bx,1
        sbb bx,bx
        jmps next		
		
		
  POP  CX DI
  SUB   DI,CX
  MOV   AL,' '
  JNE   @@SKIPX
  JCXZ  @@SKIPX
  REPE  SCASB
  JE    @@SKIPX
  DEC   DI
  INC   CX
@@SKIPX:
  MOV  BX,di      ;  START OF THE SOURCE
  JCXZ  @@WEX

  REPNE SCASB
  JNE   @@WEX
  DEC   DI
@@WEX:

		
		
		
@word:
        xchg ax,bx
		mov di,[@_dp]
        push di
        mov dx,bx
        mov bx,[@_tib]
        mov cx,bx
        add bx,[@_ltib]
        add cx,[@_etib]
@@wordf:  cmp cx,bx
        je @@wordz
        mov al,[bx]
        inc bx
        cmp al,dl
        je @@wordf
@@wordc:  inc di
        mov [di],al
        cmp cx,bx
        je @@wordz
        mov al,[bx]
        inc bx
        cmp al,dl
        jne @@wordc
@@wordz:  mov byte ptr [di+1],32
        mov ax,[@_dp]
        xchg ax,di
        sub ax,di
        mov [di],al
        sub bx,[@_tib]
        mov [@_ltib],bx
        jmps @drp
@emit:
        xchg ax,bx
        call outchar
        jmps @drp

getchar:mov ah,7
        int 021h
        mov ah,0
        ret

outchar:xchg ax,dx
        mov ah,2
        int 021h
        ret
@dofind:
        mov di,@_last
		push si
		jmps @@findl
@@findm:
		mov	di,dx
		mov	cx,[di]
@@findl:  
		mov di,cx
		jcxz @@findi
		mov dx,di
		scasw
        mov ch,0
		mov cl,[di]
		inc cx
		mov	si,bx
		rep cmpsb
        jne @@findm
		dec cx
		cmp [di],cx
		jne @@no_als
		mov di,[di+2]
@@no_als:	cmp ax,-1
		org $-2
@@findi:  mov	di,bx 
		pop si
		inc cx
		ret
@find:
		call @dofind
@@found:		
		push di
		mov  bx,cx
        jmp next

@findc:
		inc  byte ptr [bx]
		call @dofind
		inc  byte ptr [bx]
		jz   @@found
		call @dofind
		inc cx
		inc cx
		jmps   @@found

@to_number:
        pop di
        pop cx
        pop ax
@@to_numl:test bx,bx
        je @@to_numz
        push ax
        mov al,[di]
		cmp al,'9'+1
        jc @@to_numg
        cmp al,'A'
        jc @@to_numh
        sub al,7
@@to_numg:sub al,48
        mov ah,0
        cmp al,byte ptr [@_base]
        jnc @@to_numh
        xchg ax,dx
        pop ax
        push dx
        xchg ax,cx
        mul [@_base]
        xchg ax,cx
        mul [@_base]
        add cx,dx
        pop dx
        add ax,dx
        dec bx
        inc di
        jmp @@to_numl
@@to_numz:push ax
@@to_numh:push cx
        push di
        jmp next

; -------------------
; Variables
; -------------------

        variable 'state',state,0
        variable "ltib",ltib,0
        variable 'etib',etib,0
        variable 'dp',dp,freemem
        variable 'base',base,10
        variable 'last',last,final
        constant 'tib',tib,128
        constant '1l',inl,64		; max char in line
        constant '0',zero,0
		constant 'bl',spc,32
		
; -------------------
; Compilation
; -------------------

        xt ',',comma,@comma
        xt 'lit',lit,@lit
		
@commaer:
		call @does
@COMM   dw _strw,_comma,_fetch,_execute,_exit
		
		xt 'litc',litc,@commaer
		dw _lit,_comma
		
		xt ':`',colc,@defcomm
		dw @docolon,_rpar
				
@defcomm:
		call @does
		dw _head,_bran,@comm

; -------------------
; Stack
; -------------------

        xt 'rot',rote,@rote
        xt 'drop',drop,@drp
        xt 'dup',dupe,@dupe
        xt 'swap',swap,@swap
        xt 'pop',popw,@popw
        xt 'push',pushw,@pushw

; -------------------
; Maths / Logic
; -------------------

        xt '+',plus,@plus
        xt '=',equals,@equals
		xt '0=',zeq,@zeq

; -------------------
; Peek and Poke
; -------------------

        xt '@',fetch,@fetch
        xt '!',store ,@store
        xt 'c@',C@ ,@C@
		xt 'str',strw,@strw

; -----------------------
; Colon Definition
; -----------------------

        xt ';',semicolon,@commaer
        dw _exit,_lpar

        xt ':',colon,-1		; 
		dw _colc
		
		colon '[`',lpar
		dw _par,_find,_exit
		
		colon ']',rpar
		dw _par,_findc,_exit
		
		colon 'par!',par
		dw _popw,_state,_store,_exit
		
		colon 'found',found
		dw _state,_fetch,_pushw,_exit
		
; -------------------
; Flow Control
; -------------------

        xt '0br',zbran,@zero_branch
        xt 'br',bran,@br
        xt 'execute',execute,@execute
        xt 'exit',exit,@rts
		xt 'nop',noop,@docolon

; -------------------
; String
; -------------------

        xt 'count',count,@count
        xt '>num',to_number,@to_number
	
  colon 'TO_NUM',to_num
	dw _zero,_zero,_rote,_count,_to_number,_err?
_2drop:
	dw _noop,_drop,_drop,_exit
	
	colon 'NUMC',NUMC
	dw _to_num,_litc,_exit
		
; -----------------------
; errors prompt
; -----------------------

  colon '!0',nerr?
	dw _zeq
_err? dw _noop
	dw _zbran,@@err
	dw _space
	dw _lit,'?',_emit,_abort
	
	colon 'space',space
	dw _spc,_emit
@@err	dw _exit

; -----------------------
; Terminal Input / Output
; -----------------------

        xt 'emit',emit,@emit
        xt 'accept',accept,@accept
		
        xt 'word',word,@word
		
		colon 'expect',expect
		dw _tib,_inl,_accept,_exit
		
		colon 'parse',parse
		dw _spc,_word
_dc@	dw _noop,_dupe,_c@,_exit
		

; -----------------------
; Dictionary Search
; -----------------------

        xt 'find',find,@find
        xt 'findc',findc,@findc

; -----------------------
; Headers
; -----------------------

        colon '=:',head
        dw _dp,_fetch,_last,_fetch,_comma
        dw _last,_store,_parse
		dw _count
        dw _plus,_dp,_store,_exit
		
        xt 'create',create,@defcomm
		dw @dovar,_noop

        xt '(;code)',do_semi_code,@do_semi_code

; -----------------------
; Constants
; -----------------------

        xt 'constant',constant,@defcomm
        dw @doconst,_comma

; -----------------------
; Outer Interpreter
; -----------------------

        xt 'abort',abort,@abort
		
final:
		colon 'eval',eval
		dw _dupe,_ltib,_store,_plus,_etib,_store
@eval	dw _parse,_zbran,@xeval
		dw _found,_oper,_fetch,_execute,_BRAN,@eval
@xeval	dw _drop,_exit		

        colon 'interpret',interpret
interpt dw _etib,_fetch,_ltib,_fetch
        dw _equals,_ZBRAN,intpar,_tib
        dw _lit,50,_accept,_etib,_store
        dw _lit,0,_ltib,_store
intpar  dw _lit,32,_word,_find,_dupe
        dw _ZBRAN,intnf,_state,_fetch
        dw _equals,_ZBRAN,intexc,_comma
        dw _BRAN,intdone
intexc  dw _execute,_BRAN,intdone
intnf   dw _dupe,_rote,_count,_to_number
        dw _ZBRAN,intskip,_state,_fetch
        dw _ZBRAN,intnc,_last,_fetch,_dupe
        dw _fetch,_last,_store,_dp,_store
intnc   dw _abort
intskip dw _drop, _drop, _state, _fetch
        dw _ZBRAN,intdone,_lit,_lit,_comma
        dw _comma
intdone dw _BRAN,interpt

freemem:

MyCseg  ends
        end  Start
