include itsy.mac

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
        call @does
		dw _lpar 						;init interpretter
@_CICLE	dw _init,_eval,_nop,_BRAN,@_CICLE

  lbl oper 
	dw @wary,_@exec,_to_num,_@comma,_numc

@__accept:
	pop di
	mov [di],bx
	mov ah,10
	CALL @DOS
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
@_fetch:
	mov bx,[bx]
	jmps @_DONEXT	
@_dc@:
	push bx
	jmps @c@
	
@dup:
	push bx
	jmps @_DONEXT
	
@_STM:	
	POP	[bx-2]
	dec bx
@_M:
	dec bx
	jmps @_DONEXT
	
;@_LDP:
;	PUSH [BX]
;	SKIPA
@_STP:	
	POP	[bx]
	INc bx
@_P:
	INc bx
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

@lary:
	shl bx,1
@wary:
	shl bx,1
@bary:
	add bx,di
	jmps @_DONEXT

@_COL_EVAL:
	pop  ax
	add  ax,bx
	push ax
	skipa
@_DOCOLON2:
	scasw
@_DOCOLON1:
	scasw		
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
	
@_bnip_:  
	push   bX
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
	mov [di],bx
	jmps @drop
	
@_setpoint:
	mov [di+2],si
	jmps @_rts
	
@_0ex:	
	or bx,bx
	je @_dropx
@drop:		
    pop bx
    jmps @_DONEXT
	
@_SWAPX:
	pop ax
	XCHG BX,AX
	PUSH AX
	skipr cl
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
	jmps @_DONEXT
	
@NEXT:
	POP DI
	DEC DI
	PUSH DI
	SKIPR CX
@mif:
		inc bx
@ifm:	
	dec bx
	js @skip
@_br:
	mov si,[si]
@_DONEXT2:
	jmps @_DONEXT

@Uless:
    pop ax
    SUB Ax,Bx
	skipr cx
@_zeq:		
	sub bx,1
    jmps @_cf_bx
		
		
  XT PARS,@_bnip_
	XCHG  DI,ax
	SUB     DI,CX
	mov	AL,' '
	inc CX
@@P1:
	DEC	CX
	JZ @@PSKIPX
	SCASB
	JAE @@P1       ;{ SPACE IS ABOVE OR EQUAL TO }
	DEC     DI
@@PSKIPX:
	push di  ;{;  START OF THE WORD}
	JCXZ @@PWEX
	inc CX
@@P3:
	DEC	CX
	JZ @@PWEX        ; END OF THE WORD  IN DI
	SCASB           ;{ SPACE IS BELOW THEN}
	JB @@P3
	DEC     DI
@@PWEX:          ;{; END OF THE WORD  IN DI}
	mov		@_ltib,cx
	pop ax
	mov		cx,di
	sub		cx,ax		; LENGTH OF THE WORD
	XOR CH,CH			; CUT LEN TO 255
	mov		bx,@_dict
	DEc		bx
	DEc		bx
	sub		bx,cx
	SKIPA
	
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
@DOS:
	XCHG dx,di
	int 021h
	XCHG dx,di
	ret

  xt FILL,@_DROP_3
	XCHG AX,DI
	REP STOSB
	RET
	
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
        value dict,0f000h-270
		vector cdict,_dict
        cnst  zero,0
        cnst  tib,080h
        cnst  inl,64			; max char in line
        cnst  tbuf,0f000h-260	; str evaluation

  col dictx
	dw _dict,_ex,to_dict,_exit

  col DPx
	dw _DP,_ex,to_DP,_exit

		
; -------------------
; Compilation
; -------------------

  TRAP3 XCOMMA
  COL @comma
	DW _FETCH
  LBL BECKREL
  COL comma
	DW _DPX,_STP,_EXIT
  
  LBL BACKMARK		; BEGIN
  col HERE
	dw _dp,_ofst
  col _plus
	dw _pl2div,_dropx
  
  LBL COMMENT
  COL COMMENTI
	dw _zero,To_ltib,_exit
  
;  trap1 xthen
;  col THEN
;	dw _here,_swapstor,_exit
	
  xt lit,@dup_
	lodsw
    RET
		
@_commaer:
		call @does
@_COMM   dw _str,_comma,_@exec,_exit
				
  ;trap2 xcomma		; ;,
  xt litc,@_commaer
	dw _lit,_comma,_exit
		
@_defcomm:
		call @does
		dw _head,_bran,@_comm

; -------------------
; Stack
; -------------------

  xt drop,@drop
  xt dup,@dup

  lbl cswap
  xt swap,@swap_
	ret
  xt pop,@pop
  xt push,@push
  xt RDROP,@RDROP
  xt j,@j
  xt xr,@xr
  xt xa,@xa
		
; -------------------
; Maths / Logic
; -------------------

;  xt minus,@minus
;  xt plus,@plus
;  xt equals,@equals
  XT 1M,@_M
  XT 2M,@_M-1
  XT 1P,@_P
  XT 2P,@_P-1
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

  xt fetch,@_fetch
  xt dC@ ,@_dC@
  xt store ,@_DROP_2
	stosw
	RET
	
  XT STM,@_stm
  XT STP,@_stP

  XT  STR,@dup_                   ;STR
    MOV   AX,[BX]
	INC   BX
	INC   BX
	RET

  
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
  
  col lpar							; interpretter is on
	dw to_found,_dict,_find,_exit
  
  col rpar							; compiler is on
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
  XT SWAPX,@_SWAPX
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
	
	PUSHF	; =0
	JCXZ @_ZEROACC
	CMP BYTE PTR  [SI],'-'
	JNZ @_ZEROACC
	DEC CX
	INC SI	; <>0
	POP DI
	PUSHF
	
@_ZEROACC:	
	XOR		DI,DI	; ZERO ACCUM
	jmps @_NUM
	
@_Nm0:
	DEC  CX
@_Nm:
	xchg 	ax,DI
    mul  	BX
	xchg 	ax,DI
    ADD		DI,AX
@_NUM:   
	JCXZ @_EXNUM
	DEC      cx
	lodsb
	JE @_NM5		; <>0 ENABLES NEXT 5 OPTIONS
	CMP		AL,'^'
	JNE	@_NM1
	lodsb
	AND  AL,31
	JMPS	@_Nm0
@_NM1:
	CMP		AL,''''
	JNE	@_NM2
	lodsb
	JMPS	@_Nm0	
@_NM2:
	CMP		AL,'#'
	JNE	@_NM3
	mov		BX,DI
	DEC BX
	DEC BX
	MOV BH,0
	INC BX
	INC BX	
	JMPS	@_ZEROACC
@_NM3:	
	CMP		AL,'$'
	JNE	@_NM4
	mov		BL,16
	JMPS	@_NUM
@_NM4:	
	CMP		AL,'%'
	JNE	@_NM5
	mov		BL,2
	JMPS	@_NUM
@_NM5:
	cmp  	al,'9'+1
	jc   @_n
	cmp  al,'A'
	jc   @_EXNUM_
	sub  al,7
@_n: sub  al,'0'
	cmp  ax,BX
	jc   @_NM
@_EXNUM_:	
	INC CX			; CX <> ON ERR
@_EXNUM: 
	POPF
	XCHG AX,DI
	JE @_NM_NOSGN
	NEG AX
@_NM_NOSGN:	
	; RESULT NUMBER IN AX
	POP 	SI
	mov		BX,CX		; FLAG SUCSESS
	RET

  xt count,@_count

  XT STRP,@_NINU_
    DEC   ax		; ADDRES
    INC   BX		; COUNT
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
	
  trap xtok?
	dw _dc@
  col nz?
	dw _zeq
  col err?
    dw _error?
	aname '?'
	dw _exit

; -----------------------
; Terminal Input / Output
; -----------------------

  xt accpt,@__accept

  col token?
    dw _xtok?
  col token
	dw _source,_ltib,_pars,_exit
	
; -----------------------
; Dictionary Search
; -----------------------

@_dofindc:
	mov  cx,3
;	add  cl,[bx+2]
	add  cl,[bx]		; now
	jmps @_dofind2

  xt find,@_NINU_
	xchg si,ax
@_dofind:
	xor  cx,cx
@_dofind2:
    push ax si	; di := bx
	mov  di,bx	; ax := di 
	skipb
@_findm:
	scasw
	add di,cx
	mov ax,di
	mov cl,[di]
	jcxz @_findi
	inc cx
	push si
	rep cmpsb
	pop  si
    jne @_findm
	inc cx
	xchg ax,di
	skipb
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
	dw _nop,_token?,_dup,to_dict,_n_to_c,_store,_exit
		
  col n_to_c
	dw _push,_strskp,_pop,_exit
	
; -----------------------
; Constants maker
; -----------------------

;  xt constant,@_defcomm
;	dw @_doconst,_comma

; -----------------------
; Outer Interpreter
; -----------------------

  xt _ABORT,@_ABORT
		
  trap3 xeval
  xt eval,@_COL_EVAL
		dw to_ltib,to_etib
@_eval	dw _token,_dc@,_zbran,@xeval
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

  lbl initadr
	dw  _tib,_phstr,_dp,_str,_phmem,_xeval,to_init
	dw _tib,_inl,_accept,_exit
		
@_freemem:
  dw @_final-@_freemem-2
  
  aname '=:'
  dw _header
  db 0
  
@_final = $

  
MyCseg  ends
        end  Start

