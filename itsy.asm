;ABC		EQU <def>                           ;ABC = "def" (redefined)
;ABC3		CATSTR ABC2,<,>,ABC,<,>,ABC2	    ;ABC3 = "abc, def, abc" .
;ABCLEN		SIZESTR ABC						    ;ABCLEN = 3
;COMMA1 	INSTR ABC3,<,>					    ;COMMA1 = 4
;ABC4 		SUBSTR ABC3,5					    ;ABC4 = "def,abc"
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
  dw @_doconst
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
  dw @_DOCOLON
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
  xt 	anam,@_doconst
  dat 	anam,data
  endm
  
defer macro anam,data
  xt 	anam,@_defer
  dat 	anam,data
  endm
  
var macro anam,data
  xt 	anam,@dovar
  dat 	anam,data
  endm
  
value macro anam,data
  xto  	anam,@_setvar
  cnst 	anam,data
  endm
  
WATCH macro anam,data
  xat 	anam,@dovar-2
  xto 	anam,@setwatch
  xt  	anam,@getwatch
  dat 	anam,data
  endm
  
vector macro anam,data
  xto 	anam,@_setvar
  defer anam,@_defer
  endm
  
point  macro anam,data
  xto 	anam,@_setpoint
  xt 	anam,@_dopoint
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
  xt anam,@_DOCOLON
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

@_ABORT:
        mov bp,0
        mov sp,-256
        call @troff
        call @does
		dw _lpar 						;init interpretter
@_CICLE	dw _init,_eval,_nop,_BRAN,@_CICLE

  lbl oper 
	dw @wary,_@exec,_to_num,_@comma,_numc

@__accept:
	pop di
	mov [di],bx
	mov ah,10
	mov dx,di
	int 21h
	;call @dos
	lea bx,[di+1]
@_count:
	inc bx
	push bx
	dec bx
@c@:		
	mov bl,[bx]
@lobyte:
	mov bh,0
	jmps @_DONEXT
@_dc@:
	push bx
	jmps @c@
@_COMMENT:
	skipr ax	
  lbl bye		
	DW 0
	mov	@_LTIB,AX
	SKIPB
@dup:
	push bx
	jmps @_DONEXT
	
@getwatch:
	mov	di,[di]
@_doconst:
	mov ax,[di]
	jmp @ph
@XA:
    xchg    DX,[BP]                 ;XA
    jmps  @_DONEXT
@RSLD_:
	push    BX
	XOR		ah,ah
	SKIPR Cx
@RSST_:
	POP	AX
	xchg    AX,bx
	xchg    SI,[BP]
	call    DI
@_EX:
    xchg    SI,[BP]
    jmps  @_DONEXT

@wary:
	shl bx,1
@bary:
	add bx,di
	jmps @_DONEXT
@str:  
	lea ax,[bx+2]
	push ax
@fetch:
	mov bx,[bx]
	jmps @_DONEXT

;@minus:
;		neg bx
;@plus:
;        pop ax
;        add bx,ax
;        jmps @_DONEXT
@_COL_EVAL:
	pop  ax
	add  ax,bx
	push ax
	
  lbl nop
  
@_DOCOLON:
	SKIPB
	db 1
	xchg ax,di
	jmps @_pcpush
@xr:
	xchg bx,[bp]
    jmps @_DONEXT
@j:
	mov	ax,[bp+2]
	jmps @ph
@pop:
	mov	ax,[bp]
	inc bp
	inc bp
	jmps @ph
@_here:
	mov ax,@_dp
	add ax,@_ofst
	jmps @ph
@_FRELS:				; FOR THEN  - RELEASE FORWARD BRANCHES
	PUSH BX
    MOV BX,@_dp
	JMPS @SWAPSTOR
	
	scasw
	scasw
@does:
	pop ax
	push bx
	mov	 bx,di
@_pcpush:		
	xchg ax,si
@_rpush:		
	dec bp
	dec bp
	mov [bp],ax
	jmps @_DONEXT
@_cnip_:  
	POP   cX
@_nip_:   
	POP   AX
@nop_:   
	CALL  DI
	jmps @_DONEXT

@swapc_:
	pop cx
@swap_:
	pop ax
@dup_:
	call di

; -------------------
; Inner Interpreter
; vvvvvvvvvvvvvvvvv

@ph:
        push bx
@sw:
        xchg ax,bx
@_DONEXT:   
		mov di,[si]
		cmpsw
@_DONEXT1:		
        jmp [di-2]

; ^^^^^^^^^^^^^^^^^^
; Inner Interpreter
; -------------------

@TODBG: JMP @TROFF		; POINTS TO DEBUGGER IF ANY

@Uless:
    pop ax
    SUB Ax,Bx
    jmps @_cf_bx
@_zeq:		
	sub bx,1
	skipr cx
@zless:
	SHL	bx,1
@_cf_bx:
	sbb bx,bx
	jmps @_DONEXT		
		
@_DROP_3: 
	POP   CX        ;DRP3
@_DROP_2: 
	POP   AX        ;DRP2
@_DROP_:  
	xchg	DI,BX
@CALDR_:  
	CALL  BX        ;DRP
	jmps @drop

@setwatch:
	mov di,[di+2]
	skipb
@_setvar:
	scasw
	skipb
@swapstor:
	pop DI
	mov [di],bx
	jmps @drop
@_setpoint:
	scasw
	mov [di],si
	jmps @_rts
@_0ex:	
	or bx,bx
	je @_dropx
@drop:		
    pop bx
    jmps @_DONEXT
	
@nipx:
	pop ax
	skipr cl
@_dropx:
	pop bx
@_rts:
	mov si,[bp]
@rdrop:		
	inc bp
	inc bp
	jmps @_DONEXT
	
@_BINU_:  
	PUSH BX
@DINU_:  
	POP	 CX
@_NINU_:  
	POP  AX
@_NUP_:   
	CALL DI
@phax:	
	PUSH AX
	jmps @_DONEXT

		
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
	jmps @_rpush
@execute:
	pop	ax
	xchg ax,bx
	skipa
@_dopoint:
	mov ax,[di]
	jmps @_pcpush
@for:
	mov	si,[si]
@push:
	pop ax
	xchg ax,bx
	jmps @_rpush

	scasw
	scasw
@dovar:  
	xchg ax,di
	jmps @ph
@_defer: 
	push bx
	mov	bx,di
@_exec@:
	mov bx,[bx]
@exec:
	mov di,bx
	scasw
    pop bx
	jmps @_DONEXT1
	
@_zero_branch:
	test bx,bx
	pop bx
	je @_br
@skip:		
	lodsw
@_DONEXT2:
	jmps @_DONEXT
@mif:
		inc bx
@ifm:	
	dec bx
	js @skip
@_br:
	mov si,[si]
	jmps @_DONEXT2
@_ZCOMMA:
	PUSH bx
	XOR BX,bx
	SKIPA
@_comma@:
	mov bx,[bx]
@_comma:		
	mov di,[@_dp]
	xchg ax,bx
	stosw
	mov [@_dp],di
	jmps @drop

@_pars:
	mov	cx,bx
	pop di ax
	SUB   DI,CX
	cmp   AL,' '
	JNE   @_SKIPX
	JCXZ  @_SKIPX
	REPE  SCASB
	JE    @_SKIPX
	DEC   DI
	INC   CX
@_SKIPX:
	MOV  bX,di      ;  START OF THE SOURCE
	JCXZ  @_WEX	
	REPNE SCASB
	JNE   @_WEX
	DEC   DI
@_WEX:
	push bx
	sub di,bx
	push di
	mov bx,cx
	jmps @_DONEXT2
	
  XT	MAKESTR,@_cnip_
	mov [BX],CL                ; SET strlen
	XOR CH,CH					; CUT LEN TO 255
	LEA DI,[BX+1]
	ADD DI,CX                  ; AFTER END ADDRESS
	mov byte ptr [DI],'`'            ;after str flag
@_CPUSHU:
	ADD  AX,CX
@_CMOVEU:
	STD
	DEc	AX
	DEC DI
@_CMOVE:
	XCHG AX,SI
	REP  MOVSB
	XCHG AX,SI
	CLD
@_troff: 
	RET

  XT    CPUSHU,@_cnip_
	MOV DI,BX
	sub	BX,CX
	JMPS @_CPUSHU

  xt	CMOVEU,@_DROP_3
	JMPS @_CMOVEU

  XT	CMOVE,@_DROP_3
	JMPS @_CMOVE
		
  xt dk,@dup_
@_getchar:
	mov ah,7
	int 021h
	mov ah,0
	ret

  xt de,@_DROP_
@_outchar:
	mov ah,2
	mov dx,di
	int 021h
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
        value dp,@_freemem
		value ofst,0
;        value base,10
        value dict,0f000h-270
		vector cdict,_dict
        cnst  tib,080h
        cnst  inl,64			; max char in line
        cnst  tbuf,0f000h-260	; str evaluation
		
; -------------------
; Compilation
; -------------------

  LBL BECKREL
  xt comma,@_comma
  xt @comma,@_comma@
  LBL BACKMARK		; BEGIN
  xt HERE,@_HERE
  
  LBL COMMENT
  XT COMMENTI,@_COMMENT
  XT THEN,@_FRELS
  
  xt lit,@dup_
	lodsw
    RET
		
@_commaer:
		call @does
@_COMM   dw _str,_comma,_@exec,_exit
				
  trap2 xcomma		; ;,
  xt litc,@_commaer
	dw _lit,_comma,_exit
		
@_defcomm:
		call @does
		dw _head,_bran,@_comm

; -------------------
; Stack
; -------------------

;  xt drop,@drop
;  xt dup,@dup
;@swap:
;	pop ax
;	jmps @ph
;  lbl cswap
;  xt swap,@swap
;  xt pop,@pop
;  xt push,@push
;  xt RDROP,@RDROP
;  xt j,@j
;  xt xr,@xr
;  xt xa,@xa
		
;  xt zswap,@_NUP_
;	skipr ax	
;  lbl bye		
;	dw 0	;addres of bye
;	ret

;  xt cx_to_d,@dup_
;	xchg ax,cx
;	ret

; -------------------
; Maths / Logic
; -------------------

;  xt minus,@minus
;  xt plus,@plus
;  xt equals,@equals
  xt zeq,@_zeq
		
  xt and,@_nip_
    AND   BX,AX
    RET

  xt XOR,@_nip_
    XOR   BX,AX
    RET

  xt pl2div,@_NINU_
	ADD     ax,bx
	mov     bx,AX
	rcr     bx,1
	RET

  xt plmul,@_NINU_
	TEST	al,1
	jz	@_pl1
	ADD	bx,dx
@_pl1:
	rcr	bx,1
	rcr	ax,1
	RET

  xt midiv,@_NINU_                        ; -/
	SHL	ax,1
	rcl	bx,1
	CMP	bx,dx
	jNC	@_mi1
	sub	bx,dx
	INC	AX
@_mi1:
	RET

; -------------------
; Peek and Poke
; -------------------

;  xt fetch,@fetch
  xt dC@ ,@_dC@
  xt str,@str
;  xt swapstor,@swapstor

  xt store ,@_DROP_2
	stosw
	RET
	
  xt stm,@_nip_
	mov	[bx-2],ax
	dec bx
	dec bx
	ret
	
  xt STRSKP,@RSLD_					; string skip
	MOV     BX,si
	lodsb
	add		si,AX
	ret

  XT	RLDP,@RSLD_                 ;@R+
	LODSW
	xchg    AX,bx
	RET

  XT    RSTP,@RSST_                 ;!R+
	mov		[SI],AX
	LODSW
	RET

  XT    CRSTP,@RSST_                 ;C!R+
	mov		[SI],AL
	INC		SI
	RET

  XT    CRldP,@RSLD_                 ;C@R+
	LODSb
	xchg    AX,bx
	RET

; -----------------------
; Colon Definition
; -----------------------

  lbl col
  xt colI,@_defcomm
  dw @_DOCOLON,_rpar
  		
  xt semicolon,@_commaer
	dw _exit,_lpar
  
  col lpar
	dw to_found,_dict,_find,_exit
  
  col rpar
	dw to_found,_cdict,_findc,_exit
		
; -------------------
; Flow Control
; -------------------

  xt zbran,@_zero_branch
  xt bran,@_br
;  xt exec,@exec
;  xt execute,@execute
  xt exit,@_rts
  xt ex,@_ex
  xt @exec,@_exec@
;  xt for,@for
;  xt skip,@skip
;  xt mif,@mif
;  xt ifm,@ifm
  xt dropx,@_dropx
  xt 0x,@_0ex

;  col TIMES
;	dw _push,_xr
;  col xTIMES
;	dw _bran,@@tim2
;@@tim1 dw _push,_j,_execute,_pop
;@@tim2 dw _ifm,@@tim1,_rdrop,_dropx	
  
; -------------------
; String
; -------------------

  XT  to_number,@_BINU_
	push 	SI
	xchg 	ax,SI  	; START ADR
	mov		BL,10	; NUM BASE
	XOR		ax,ax
	XOR		DI,DI	; ZERO ACCUM
	jmps @_NUM
	
@_Nm:xchg 	ax,DI
    mul  	BX
	xchg 	ax,DI
    ADD		DI,AX
	DEC      cx
@_NUM:   JZ @_EXNUM
	lodsb
	CMP		AL,'$'
	JNE	@_NM2
	mov		BL,16
	JMPS	@_NUM
@_NM2:
	cmp  	al,'9'+1
	jc   @_n
	cmp  al,'A'
	jc   @_EXNUM
	sub  al,7
@_n: sub  al,'0'
	cmp  ax,BX
	jc   @_NM
@_EXNUM: 
	POP 	SI
	XCHG	DI,AX	; RESULT NUMBER IN AX
	mov		BX,CX
	RET

  xt count,@_count

  XT STRP,@_NINU_
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
	dw _strskp,to_erra,_0x,_errv,__ABORT
	
  trap2 xtok?
  trap2 xnz?
	dw _dc@
	dw _zeq
  col err?
    dw _error?
	aname '?'
	dw _exit

; -----------------------
; Terminal Input / Output
; -----------------------

  xt accpt,@__accept
  xt pars,@_pars

  col token?
    dw _xtok?
  col token
	dw _xtostr,_lit,32
  col parse
	dw _source,_ltib,_pars,to_ltib,_exit
	
  trap xtostr
	dw _tbuf,_makestr,_exit
	
;  trap xdc@
;	dw _dup,_c@,_exit

; -----------------------
; Dictionary Search
; -----------------------

@_dofindc:
	mov  cx,3
	add  cl,[bx+2]
	jmps @_dofind2

  xt find,@_NINU_
	xchg si,ax
@_dofind:
	xor  cx,cx
@_dofind2:
    push ax si
	mov  di,bx	;ax := di  di := bx
@_findm:
	add di,cx
	mov ax,di
	scasw
	mov cl,[di]
	jcxz @_findi
	inc cx
	push si
	rep cmpsb
	pop  si
    jne @_findm
	inc cx
	xchg ax,si
@_findi:
	xchg ax,si
	pop di si
	mov bx,cx
	ret
		
  xt findc,@_NINU_
	xchg si,ax
	inc  byte ptr [si]
	push bx
	call @_dofindc
	pop  cx
	inc  byte ptr [di]
	or  bx,bx
	jnz   @_fend
	mov  bx,cx
	xchg di,ax
	call @_dofindc
	inc bx
	inc bx
@_fend:
	ret

; -----------------------
; Headers
; -----------------------

  col head		; =h
	dw _HERE
  col header	; =:			NOP IS PLACE FOR THE (SAME) FUNCTION 
	dw _nop,_token?,_count,_strp,_dictx,_cpushu,_stm,_exit
		
;  xt create,@_defcomm
;	dw @dovar,_nop

; -----------------------
; Constants
; -----------------------

  xt constant,@_defcomm
	dw @_doconst,_comma

; -----------------------
; Outer Interpreter
; -----------------------

  xt _ABORT,@_ABORT
		
  trap3 xeval
  xt eval,@_COL_EVAL
		dw to_ltib,to_etib
@_eval	dw _token,_zbran,@xeval
		dw _found,_oper,_@exec,_BRAN,@_eval

  trap xdrop
@xeval	dw _dropx

;  col forget1
;  dw _dictx,_dup,_fetch,to_dp,_skpdtok,_exit
;  
  col phstr
	dw _count,_strp
  col phmem
	dw _dictx,_cpushu,_exit

  col dictx
	dw _dict,_ex,to_dict,_exit

  lbl initadr
	dw  _tib,_phstr,_dp,_str,_phmem,_xeval,to_init
	dw _tib,_inl,_accept,_exit
		
@_freemem:
  dw @_final-@_freemem-2
  dw _header
  aname '=:'
  dw 0
  db 0
  
@_final = $

  
MyCseg  ends
        end  Start

