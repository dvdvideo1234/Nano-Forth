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
;ABC7 		EQU %3+2+1						    ;ABC7 = "6" (textname macro)
;ABC8 		EQU %COMMA 1					    ;ABC8 = "4"

ppp = 0
qqq = 0

SKIPA   MACRO		; change the carry
  DB    03DH
  ENDM

SKIPB   MACRO		; change the carry
  DB    03CH
  ENDM

SKIPR   MACRO reg	; does not change the carry
  local diff
diff = $
  mov   reg,0
diff = $-diff-2
  if diff
    org $-1
  endif
  org   $-1
  ENDM

aname macro cnam
  local len,end
  db end-len
len:
  db cnam
end:
  endm
  
header macro cnam,anam
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
  
xtname macro cnam,anam,adr
  header cnam,anam,0
  dw adr
  endm
		
primitive macro cnam,anam
  xtname cnam,anam,$+2
  endm
		
colon macro cnam,anam
  header cnam,anam,0
  dw @docolon
  endm

jmps macro adr
  jmp short adr
  endm

lbl macro anam
_&anam:
ENDM

dat macro anam,adr	;define data field
@_&anam dw adr
ENDM

xto macro anam,adr	;define second code field
to_&anam: dw adr
ENDM

xat macro anam,adr	;define third code field
at_&anam: dw adr
ENDM

xt macro anam,adr	;define code field
  lbl anam
  dw adr
  endm

cnst macro anam,data
  xt 	anam,@doconst
  dat 	anam,data
  endm
  
defer macro anam,data
  xt 	anam,@defer
  dat 	anam,data
  endm
  
var macro anam,data
  xt 	anam,@dovar
  dat 	anam,data
  endm
  
value macro anam,data
  xto  	anam,@setvar
  cnst 	anam,data
  endm
  
WATCH macro anam,data
  xat 	anam,@dovar-2
  xto 	anam,@setwatch
  xt  	anam,@getwatch
  dat 	anam,data
  endm
  
vector macro anam,data
  xto 	anam,@setvar
  defer anam,@defer
  endm
  
point  macro anam,data
  xto 	anam,@setpoint
  xt 	anam,@dopoint
  dat 	anam,data
  endm

trap3 macro anam
  xt anam,@trap-3
endm

trap2 macro anam
  xt anam,@trap-2
endm

trap1 macro anam
  xt anam,@trap-1
endm

trap macro anam
  xt anam,@trap
endm

twice macro anam
  dw @trap
endm

prim macro anam
  xt anam,$+2
  endm
		
col macro anam
  xt anam,@docolon
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
        mov bp,0
        mov sp,-256
        call @troff
        call @does
		dw _lpar 						;init interpretter
@cicle	dw _init,_eval,_nop,_BRAN,@cicle

  lbl oper 
	dw @wary,_@exec,_to_num,_@comma,_numc

@accept:
	pop di
	mov [di],bx
	mov ah,10
	mov dx,di
	int 21h
	;call @dos
	lea bx,[di+1]
@count:
	inc bx
	push bx
	dec bx
@c@:		
	mov bl,[bx]
@lobyte:
	mov bh,0
	jmps @donext
@dup:
	push bx
	jmps @donext
@getwatch:
	mov	di,[di]
@doconst:
	mov ax,[di]
	jmp @ph
@XA:
    xchg    DX,[BP]                 ;XA
    jmps  @donext
@@RSST:
	POP	AX
	xchg    AX,bx
	SKIPR CL
@@RSLD:  
	push    BX
	xchg    SI,[BP]
	call    DI
@@EX:
    xchg    SI,[BP]
    jmps  @donext

@wary:
	shl bx,1
@bary:
	add bx,di
	jmps @donext
@str:  
	lea ax,[bx+2]
	push ax
@fetch:
	mov bx,[bx]
	jmps @donext

@minus:
		neg bx
@plus:
        pop ax
        add bx,ax
        jmps @donext
@equals:
        pop ax
        sub bx,ax
@zeq:		
        sub bx,1
        sbb bx,bx
        jmps @donext		
		
@col_eval:
	pop  ax
	add  ax,bx
	push ax
	
  lbl nop
  
@docolon:
	SKIPB
	db 1
	xchg ax,di
	jmps @pcpush
@xr:
	xchg bx,[bp]
    jmps @donext
@j:
	mov	ax,[bp+2]
	jmps @ph
@pop:
	mov	ax,[bp]
	inc bp
	inc bp
	jmps @ph
@here:
	mov ax,@_dp
	add ax,@_ofst
	jmps @ph
@FRELS:				; FOR THEN  - RELEASE FORWARD BRANCHES
	PUSH BX
    MOV BX,@_dp
	JMPS @SWAPSTOR
	
	scasw
	scasw
@does:
	pop ax
	push bx
	mov	 bx,di
@pcpush:		
	xchg ax,si
@rpush:		
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
@donext:   
		mov di,[si]
		cmpsw
@donext1:		
        jmp [di-2]

; ^^^^^^^^^^^^^^^^^^
; Inner Interpreter
; -------------------

@TODBG: JMP @TROFF		; POINTS TO DEBUGGER IF ANY

@setwatch:
	mov di,[di+2]
	skipb
@setvar:
	scasw
	skipb
@swapstor:
	pop DI
	mov [di],bx
	jmps @drop
@SETPOINT:
	scasw
	mov [di],si
	jmps @rts
@0ex:	
	or bx,bx
	je @dropx
	skipa
@store:		
    pop [bx]
@drop:		
    pop bx
    jmps @donext
	
@dropx:
	pop bx
@rts:
	mov si,[bp]
@rdrop:		
	inc bp
	inc bp
@none:	
	jmps @donext
		
	scasw
	scasw
	scasw
@trap:
	skipr cx
@cont:
	dec di
	dec di
@twice:	
	mov ax,di
	jmps @rpush
@execute:
	pop	ax
	xchg ax,bx
	skipa
@DOPOINT:
	mov ax,[di]
	jmps @pcpush
@for:
	mov	si,[si]
@push:
	pop ax
	xchg ax,bx
	jmps @rpush

	scasw
	scasw
@dovar:  
	xchg ax,di
	jmps @ph
@swap:
	pop ax
	jmps @ph
@lit:		
	lodsw
	jmps @ph
@defer: 
	push bx
	mov	bx,di
@exec@:
	mov bx,[bx]
@exec:
	mov di,bx
	scasw
    pop bx
	jmps @donext1
	
@zero_branch:
	test bx,bx
	pop bx
	je @br
@skip:		
	lodsw
	jmps @donext
@mif:
		inc bx
@ifm:	
	dec bx
	js @skip
@br:
	mov si,[si]
	jmps @donext
@comma@:
	mov bx,[bx]
@comma:		
	mov di,[@_dp]
	xchg ax,bx
	stosw
	mov [@_dp],di
	jmps @drop

@@BINU_:  PUSH BX
@@DINU_:  POP   CX
@@NINU_:  POP   AX
@@NUP_:   CALL  DI
		PUSH  AX
@donext2:
        jmps @donext

@@cnip_:  POP   cX
@@nip_:   POP   AX
@@nop_:   CALL  DI
        jmps @donext2

@@DROP3_: POP   CX        ;DRP3
@@DROP2_: POP   AX        ;DRP2
@@DROP_:  xchg	DI,BX
@@CALDR:  CALL  BX        ;DRP
		jmps @drop

@pars:
	mov	cx,bx
	pop di ax
	SUB   DI,CX
	cmp   AL,' '
	JNE   @@SKIPX
	JCXZ  @@SKIPX
	REPE  SCASB
	JE    @@SKIPX
	DEC   DI
	INC   CX
@@SKIPX:
	MOV  bX,di      ;  START OF THE SOURCE
	JCXZ  @@WEX	
	REPNE SCASB
	JNE   @@WEX
	DEC   DI
@@WEX:
	push bx
	sub di,bx
	push di
	mov bx,cx
	jmps @donext2
	
;@to_number: ; di num   ax adrs  cx leng  bx - base
;	pop cx ax di
;	push si
;	xor si,si
;	xchg ax,si
;@@to_numl:
;	jcxz @@to_numz
;	lodsb
;	cmp al,'9'+1
;	jc @@to_numg
;	cmp al,'A'
;	jc @@to_numh
;	sub al,7
;@@to_numg:
;	sub al,48
;    cmp ax,bx
;    jnc @@to_numh
;	xchg ax,di
;	push dx
;	mul bx
;	pop dx
;	xchg ax,di
;	add di,ax
;	dec	cx
;	jmp @@to_numl
;@@to_numh:
;	dec si
;@@to_numz:
;	xchg ax,si
;	pop si
;@@found:		
;	push ax
;	mov  bx,cx
; @donext2:	
;	jmp @donext

  XT	MAKESTR,@@cnip_
	mov [BX],CL                ; SET strlen
	XOR CH,CH					; CUT LEN TO 255
	LEA DI,[BX+1]
	ADD DI,CX                  ; AFTER END ADDRESS
	mov byte ptr [DI],'`'            ;after str flag
@@CPUSHU:
	ADD  AX,CX
@@CMOVEU:
	STD
	DEc	AX
	DEC DI
@@CMOVE:
	XCHG AX,SI
	REP  MOVSB
	XCHG AX,SI
	CLD
@@troff: 
	RET

  XT    CPUSHU,@@cnip_
	MOV DI,BX
	sub	BX,CX
	JMPS @@CPUSHU

  xt	CMOVEU,@@DROP3_
	JMPS @@CMOVEU

  XT	CMOVE,@@DROP3_
	JMPS @@CMOVE
		
  xt dk,@@nup_
@getchar:
	mov ah,7
	int 021h
	mov ah,0
	ret

  xt de,@@drop_
@outchar:
	mov ah,2
@dos:
	push dx
	mov dx,di
	int 021h
	pop dx
	ret

; -------------------
; Variables
; -------------------

        point found,0
		point init,_initadr
        defer errv,0
        defer key,_dk
        defer emit,_de
		defer accept,_accpt
		defer source,_etib
        value ltib,0
        value etib,0
        value erra,0
        value dp,@freemem
		value ofst,0
        value base,10
        value dict,0f000h-270
		vector cdict,_dict
        cnst  tib,080h
        cnst  inl,64			; max char in line
        cnst  tbuf,0f000h-260	; str evaluation
		
; -------------------
; Compilation
; -------------------

  LBL BECKREL
  xt comma,@comma
  xt @comma,@comma@
  xt lit,@lit
  LBL BACKMARK		; BEGIN
  xt HERE,@HERE
		
@commaer:
		call @does
@COMM   dw _str,_comma,_@exec,_exit
				
  trap2 xcomma		; ;,
  xt litc,@commaer
	dw _lit,_comma,_exit
		
@defcomm:
		call @does
		dw _head,_bran,@comm

; -------------------
; Stack
; -------------------

  xt drop,@drop
  xt dup,@dup
;  lbl cswap
;  xt swap,@swap
;  xt pop,@pop
;  xt push,@push
;  xt RDROP,@RDROP
;  xt j,@j
;  xt xr,@xr
;  xt xa,@xa
		
  xt zswap,@@nup_
	skipr ax	
  lbl bye		
	dw 0	;addres of bye
	ret


; -------------------
; Maths / Logic
; -------------------

;  xt minus,@minus
;  xt plus,@plus
;  xt equals,@equals
  xt zeq,@zeq
		
  xt and,@@nip_
    AND   BX,AX
    RET

  xt XOR,@@nip_
    XOR   BX,AX
    RET

  xt pl2div,@@NINU_
	ADD     ax,bx
	mov     bx,AX
	rcr     bx,1
	RET

  xt plmul,@@NINU_
	TEST	al,1
	jz	@@pl1
	ADD	bx,dx
@@pl1:
	rcr	bx,1
	rcr	ax,1
	RET

  xt midiv,@@NINU_                        ; -/
	SHL	ax,1
	rcl	bx,1
	CMP	bx,dx
	jNC	@@mi1
	sub	bx,dx
	INC	AX
@@mi1:
	RET

; -------------------
; Peek and Poke
; -------------------

  xt fetch,@fetch
  xt store ,@store
  xt C@ ,@C@
  xt str,@str
;  xt swapstor,@swapstor

  xt stm,@@nip_
	mov	[bx-2],ax
	dec bx
	dec bx
	ret
	
  xt STRSKP,@@RSLD					; string skip
	MOV     BX,si
	XOR		ah,ah
	lodsb
	add		si,AX
	ret

  XT	RLDP,@@RSLD                 ;@R+
	LODSW
	xchg    AX,bx
	RET

  XT    RSTP,@@RSST                 ;!R+
	mov		[SI],AX
	LODSW
	RET

  XT    CRSTP,@@RSST                 ;C!R+
	mov		[SI],AL
	INC		SI
	RET

; -----------------------
; Colon Definition
; -----------------------

  lbl colc
  xt col,@defcomm
  dw @docolon,_rpar
  		
  xt semicolon,@commaer
	dw _exit,_lpar
  
  col lpar
	dw to_found,_dict,_find,_exit
  
  col rpar
	dw to_found,_cdict,_findc,_exit
		
; -------------------
; Flow Control
; -------------------

  xt zbran,@zero_branch
  xt bran,@br
;  xt exec,@exec
;  xt execute,@execute
  xt exit,@rts
  xt ex,@@ex
  xt @exec,@exec@
;  xt for,@for
;  xt skip,@skip
;  xt mif,@mif
;  xt ifm,@ifm
  xt dropx,@dropx
  xt 0x,@0ex

;  col TIMES
;	dw _push,_xr
;  col xTIMES
;	dw _bran,@@tim2
;@@tim1 dw _push,_j,_execute,_pop
;@@tim2 dw _ifm,@@tim1,_rdrop,_dropx	
  
; -------------------
; String
; -------------------

  XT  to_number,@@Binu_
	push 	SI
	xchg 	ax,SI  	; START ADR
	mov		BL,10	; NUM BASE
	XOR		ax,ax
	XOR		DI,DI	; ZERO ACCUM
	jmps @@NUM
	
@@Nm:xchg 	ax,DI
    mul  	BX
	xchg 	ax,DI
    ADD		DI,AX
	DEC      cx
@@NUM:   JZ @@EXNUM
	lodsb
	CMP		AL,'$'
	JNE	@@NM2
	mov		BL,16
	JMPS	@@NUM
@@NM2:
	cmp  	al,'9'+1
	jc   @@n
	cmp  al,'A'
	jc   @@EXNUM
	sub  al,7
@@n: sub  al,'0'
	cmp  ax,BX
	jc   @@NM
@@EXNUM: 
	POP 	SI
	XCHG	DI,AX	; RESULT NUMBER IN AX
	mov		BX,CX
	RET

  xt count,@count

  XT STRP,@@niNU_
    INC   ax
    DEC   BX
@TROFF:
    ret
	
  col to_num			; NOPS RESERVED PLACE FOR STRING FUNCTIONS
	dw _NOP
  COL TO_NUM2
	DW _count,_to_number,_err?,_exit
	
  col NUMC				; NOPS RESERVED PLACE FOR STRING FUNCTIONS
	dw _NOP,_to_num2,_litc,_exit
		
; -----------------------
; errors prompt
; -----------------------

  col error?
	dw _strskp,to_erra,_0x,_errv,_abort
	
  trap xnz?
	dw _zeq
  col err?
    dw _error?
	aname '?'
	dw _exit

; -----------------------
; Terminal Input / Output
; -----------------------

  xt accpt,@accept
  xt pars,@pars

  col token?
    dw _xnz?
  col token
	dw _xdc@,_xtostr,_lit,32
  col parse
	dw _source,_ltib,_pars,to_ltib,_exit
	
  trap xtostr
	dw _tbuf,_makestr,_exit
	
  trap xdc@
	dw _dup,_c@,_exit

; -----------------------
; Dictionary Search
; -----------------------

@dofindc:
	mov  cx,3
	add  cl,[bx+2]
	jmps @dofind2

  xt find,@@ninu_
	xchg si,ax
@dofind:
	xor  cx,cx
@dofind2:
    push ax si
	mov  di,bx	;ax := di  di := bx
@@findm:
	add di,cx
	mov ax,di
	scasw
	mov cl,[di]
	jcxz @@findi
	inc cx
	push si
	rep cmpsb
	pop  si
    jne @@findm
	inc cx
	xchg ax,si
@@findi:
	xchg ax,si
	pop di si
	mov bx,cx
	ret
		
  xt findc,@@ninu_
	xchg si,ax
	inc  byte ptr [si]
	push bx
	call @dofindc
	pop  cx
	inc  byte ptr [di]
	or  bx,bx
	jnz   @@fend
	mov  bx,cx
	xchg di,ax
	call @dofindc
	inc bx
	inc bx
@@fend:
	ret

; -----------------------
; Headers
; -----------------------

  col head		; =h
	dw _HERE
  col header	; =:			NOP IS PLACE FOR THE (SAME) FUNCTION 
	dw _nop,_token?,_count,_strp,_xdict,_cpushu,_stm,_exit
		
;  xt create,@defcomm
;	dw @dovar,_nop

; -----------------------
; Constants
; -----------------------

  xt constant,@defcomm
	dw @doconst,_comma

; -----------------------
; Outer Interpreter
; -----------------------

  xt abort,@abort
		
  xt eval,@col_eval
		dw to_ltib,to_etib
@eval	dw _token,_zbran,@xeval
		dw _found,_oper,_@exec,_BRAN,@eval

  trap xdrop
@xeval	dw _dropx

;  col forget1
;  dw _xdict,_dup,_fetch,to_dp,_skpdtok,_exit
;  
  col phstr
	dw _count,_strp
  col phmem
	dw _xdict,_cpushu,_exit

  col xdict
	dw _dict,_ex,to_dict,_exit

  lbl initadr
	dw  _tib,_phstr,_dp,_str,_phmem,_expect,to_init
  col expect
	dw _tib,_inl,_accept,_exit
		
@freemem:
  dw @final-@freemem-2
  dw _header
  aname '=:'
  dw 0
  db 0
  
@final = $

  
MyCseg  ends
        end  Start


not used

@BARY			@CURSEG			@DOFIND			@FETCH2			@LOBYTE			@NONE			
@SW				@_ACCEPT		@_BASE			@_DICT			@_EMIT			@_ERRA			
@_ERRV			@_ETIB			@_FOUND			@_INIT			@_INL			@_KEY			
@_LTIB			@_TBUF			@_TIB			GETCHAR			OUTCHAR			TO_ACCEPT		
TO_BASE			TO_DP			TO_EMIT			TO_ERRV			TO_KEY			_AND			
_BYE			_CMOVE			_CMOVEU			_COLC			_CONSTANT		_CREATE			
_CRSTP			_DROP			_EMIT			_EQUALS			_ERRA			_EXEC			
_EXECUTE		_FETCH			_FOR			_IFM			_J				_KEY			
_MIDIV			_MIF			_MINUS			_PARSE			_PL2DIV			_PLMUL			
_PLUS			_POP			_PUSH			_RDROP			_RLDP			_RSTP			
_SEMICOLON		_SKIP			_STORE			_SWAP			_XA				_XCOMMA			
_XOR			_XR				__EXPECT		COLON			CONSTANT		HEADER			
PRIM			PRIMITIVE		trap1			VAR				VARIABLE		XAT				
XTNAME			
