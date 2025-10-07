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
        CLD
		mov bp,0
        mov sp,-256

        call @_TROFF
        call @_does
		dw _lpar 						;init interpretter
@_CICLE	dw _init,_eval,_nop,_BRAN,@_CICLE

  lbl oper 
	dw @_wary,_@exec,_to_num,_@comma,_numc

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
@_c@:		
	mov bl,[bx]
@_lobyte:
	mov bh,0
	jmps @_DONEXT
@_Dfetch:
	PUSH [bx+2]
@_fetch:
	mov bx,[bx]
	jmps @_DONEXT	
@_dc@:
	push bx
	jmps @_c@
	
@_DROPDUP:
	POP BX
@_dup:
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

@_getwatch:
	mov	di,[di]
@_doconst:
	mov ax,[di]
	jmp @_ph
	
@_XA:
    xchg    DX,[BP]                 ;XA
    jmps  @_DONEXT
	
@_RSLD_:
	push    BX
	XOR		ah,ah
	SKIPR Cx
@_RSST_:
	POP	AX
	xchg    AX,bx
	xchg    SI,[BP]
	call    DI
@_EX:
    xchg    SI,[BP]
    jmps  @_DONEXT

@_lary:
	shl bx,1
@_wary:
	shl bx,1
@_bary:
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
	
@_xr:
	xchg bx,[bp]
    jmps @_DONEXT
	
@_j:
	mov	ax,[bp+2]
	jmps @_ph
	
@_pop:
	mov	ax,[bp]
	inc bp
	inc bp
	jmps @_ph

	scasw
	scasw
@_does:
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
@_nop_:   
	CALL  DI
	jmps @_DONEXT

@_swapc_:
	pop cx
@_swap_:
	pop ax
@_dup_:
	call di

; -------------------
; Inner Interpreter
; vvvvvvvvvvvvvvvvv

@_ph:
        push bx
;@sw:
        xchg ax,bx
@_DONEXT:   
		mov di,[si]
		cmpsw
@_DONEXT1:		
        jmp [di-2]

; ^^^^^^^^^^^^^^^^^^
; Inner Interpreter
; -------------------

@_TODBG: JMP @_TROFF		; POINTS TO DEBUGGER IF ANY

@_Uless:
    pop ax
    SUB Ax,Bx
	skipr cx
@_zless:
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
;@CALDR_:  
	CALL  BX        ;DRP
	jmps @_drop

@_setwatch:
	mov di,[di+2]
	skipb
@_setvar:
	scasw
	mov [di],bx
	jmps @_drop
	
@_setpoint:
	mov [di+2],si
	jmps @_rts
	
@_0ex:	
	or bx,bx
	je @_dropx
@_drop:		
    pop bx
    jmps @_DONEXT
	
@_SWAPX:
	pop ax
	XCHG BX,AX
	PUSH AX
	skipr cl
@_nipx:
	pop ax
	skipr cl
@_dropx:
	pop bx
@_rts:
	mov si,[bp]
@_rdrop:		
	inc bp
	inc bp
	jmps @_DONEXT
	
@_BINU_:  
	PUSH BX
@_DINU_:  
	POP	 CX
@_NINU_:  
	POP  AX
@_NUP_:   
	CALL DI
@_phax:	
	PUSH AX
	jmps @_DONEXT
		
	scasw
	scasw
	scasw
@_trap:
	skipr cx
@_cont:
	dec di
	dec di
@_twice:	
	mov ax,di
	jmps @_rpush
	
@_execute:
	pop	ax
	xchg ax,bx
	skipa
@_dopoint:
	mov ax,[di]
	jmps @_pcpush
	
@_for:
	mov	si,[si]
@_push:
	pop ax
	xchg ax,bx
	jmps @_rpush

	scasw
	scasw
@_dovar:  
	xchg ax,di
	jmps @_ph
	
@_DEFERI:
  INC   PW [@_CNTC]
@_defer: 
	push bx
	mov	bx,di
@_exec@:
	mov bx,[bx]
@_exec:
	mov di,bx
	scasw
    pop bx
	jmps @_DONEXT1

@_zeq:		
	sub bx,1
    jmps @_cf_bx
		
@_zSKIP:
	test bx,bx
	jNe @_NONE
@_DRskip:		
	pop bx
@_skip:		
	lodsw
@_NONE:	
	jmps @_DONEXT

@_zero_branch:
	test bx,bx
	jNe @_DrSKIP
@_DRbr:
	pop bx
@_br:
	mov si,[si]
@_DONEXT2:
	jmp @_DONEXT
	
@_NEXT:
	DEC pw [bp]
	SKIPR CX
@_mif:
	inc bx
@_ifm:	
	dec bx
	JNS @_br
	jMPs @_skip
		
  XT PARS,@_bnip_
	XCHG  DI,ax
	SUB     DI,CX
	mov	AL,' '
	inc CX
@@P1:
	DEC	CX
	JZ @@PSKIPX
	SCASB
	JAE @@P1       	;{ SPACE IS ABOVE OR EQUAL TO }
	DEC     DI
@@PSKIPX:
	push di  		;{;  START OF THE WORD}
	JCXZ @@PWEX
	inc CX
@@P3:
	DEC	CX
	JZ @@PWEX		; END OF THE WORD  IN DI
	SCASB           ;{ SPACE IS BELOW THEN}
	JB @@P3
	DEC     DI
@@PWEX:          ;{; END OF THE WORD  IN DI}
	mov		@_ltib,cx
	pop ax
	mov		cx,di
	sub		cx,ax		; LENGTH OF THE WORD
	SKIPA
	
  XT	MAKESTR,@_Bnip_
	and Cx,127			; CUT LEN TO 127
	mov		bx,@_dict
	lea		BX,[BX-4]	;
	mov		DI,BX
	mov pb [DI],'`' 	;after str flag
	mov	pw [DI+2],0	
	DEc		BX
	sub		bx,cx
	mov [BX],CL                ; SET strlen
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
		
  xt dk,@_DUP_
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
	PUSH AX
	JC  @@DOS
	XOR AX,AX
@@DOS:	
	MOV @_DOSERR,AX
	POP AX
	ret

  xt FILL,@_DROP_3
	XCHG AX,DI
	REP STOSB
	RET
	
  xt FILLW,@_DROP_3
	XCHG AX,DI
	REP STOSW
	RET
	
  XT  RSP,@_DUP_
  MOV   BX,RSP
  RET

  XT  DSP,@_DUP_
  MOV   BX,DSP
  RET

; -------------------
; Variables
; -------------------

        point found,0
		point init,_initadr
        defer errv,0
        defer key,_dk
        XT emit,@_deferI
			DW _de
		defer accept,_accpt
		defer source,_etib
        value ltib,0
        value etib,0
        value erra,0
        value dp,@_freemem
		value ofst,0
		value CNTC,0
		value DOSERR,0
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
  
  trap1 xthen
  col THEN
	dw _here,_swap,_storE,_exit

  xt lit,@_DUP_
	lodsw
    RET
		
@_commaer:
		call @_DOES
@_COMM   dw _str,_comma,_@exec,_exit
				
  xt litc,@_commaer
	dw _lit,_comma
		
@_defcomm:
		call @_DOES
		dw _head,_bran,@_comm

; -------------------
; Stack
; -------------------

  xt drop,@_drop
  xt dup,@_dup

  lbl cswap
  xt swap,@_swap_
	ret

  XT POP,@_POP
  XT PUSH,@_PUSH
  XT RDROP,@_RDROP
  XT J,@_J
  XT XA,@_XA
  XT XR,@_XR
  XT DROPDUP,@_DROPDUP
		
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
  XT ULESS,@_ULESS
  XT ZLESS,@_ZLESS
  XT LOBYTE,@_LOBYTE
		
  xt and,@_nip_
    AND   BX,AX
    RET

  xt XOR,@_nip_
    XOR   BX,AX
    RET

  xt NEG,@_NOP_
    NEG   BX
    RET

  xt pl2div,@_NINU_
	ADD     ax,bx
	mov     bx,AX
	rcr     bx,1
	RET

  COL MINUS
	DW _NEG
  COL plus
	DW _pl2div,_DROPX
	
  xt plmul,@_NINU_
	TEST	al,1
	jz	@_pl1
	ADD	bx,dx
@_pl1:
	rcr	bx,1
	rcr	ax,1
	RET
	
  XT ASTZ,@_nop_
	XOR DX,DX
	XCHG BX,DX	
	RET
	
  COL Umul
	DW _XDROP
  COL UMmul
	DW _ASTZ,_TWICE,_TWICE,_plmul,_plmul,_plmul,_plmul,_EXIT

  xt midiv,@_NINU_                        ; -/
	SHL	ax,1
	rcl	bx,1
	CMP	bx,dx
	jNC	@_mi1
	sub	bx,dx
	INC	AX
@_mi1:
	RET

  COL UDIV
	DW _XDROP
  COL UMDIVMOD
	DW _ASTZ,_TWICE,_TWICE,_midiv,_midiv,_midiv,_midiv,_EXIT

; -------------------
; Peek and Poke
; -------------------

  XT C@,@_C@
  xt fetch,@_fetch
  xt Dfetch,@_Dfetch
  xt dC@ ,@_dC@
  xt store ,@_DROP_2
	stosw
	RET
	
  xt Dstore ,@_DROP_3
	XCHG AX,CX
	stosw
	XCHG AX,CX
	stosw
	RET
	
  XT STM,@_stm
  XT STP,@_stP

  XT  STR,@_DUP_                   ;STR
    MOV   AX,[BX]
	INC   BX
	INC   BX
	RET

  
  xt STRSKIP,@_RSLD_					; string skip
	MOV     BX,si
	lodsb
	add		si,AX
	ret

  XT	RLDP,@_RSLD_                 ;@R+
	LODSW
	xchg    AX,bx
	RET

  XT    RSTP,@_RSST_                 ;!R+
	mov		[SI],AX
	LODSW
	RET

  XT    CRSTP,@_RSST_                 ;C!R+
	mov		[SI],AL
	INC		SI
	RET

  XT    CRldP,@_RSLD_                 ;C@R+
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
  xt zSKIP,@_zSKIP
  xt bran,@_br
  XT CONT,@_CONT
  XT EXEC,@_EXEC
  XT EXECUTE,@_EXECUTE
  XT SKIP,@_SKIP
  XT TRAP,@_TRAP
  XT TWICE,@_TWICE
  XT FOR,@_FOR
  XT IFM,@_IFM
  XT MIF,@_MIF
  XT NEXT,@_NEXT
  xt exit,@_rts
  xt ex,@_ex
  xt @exec,@_exec@
  xt dropx,@_dropx
  XT SWAPX,@_SWAPX
  xt 0x,@_0ex

; -------------------
; String
; -------------------

  col TIMES
	dw _push,_xr
  col xTIMES
        DW _FOR,@@LP2
@@LP1   DW _J,_EXECUTE
@@LP2	DW _NEXT,@@LP1
		DW _RDROP,_EXIT

 COL STRTYPE	;COMPILE MODE ONLY
       DW _STRSKIP
 COL STYPE
       DW _COUNT
 COL TYPE
       DW _XDROP,_xTIMES,_COUNT,_EMIT,_EXIT

  XT  to_number,@_BINU_
    push 	SI
    xchg 	ax,SI  	; START ADR
    mov		BL,10	; NUM BASE
    XOR		ax,ax
    
    PUSHF	; =0
    JCXZ @_ZEROACC
    CMP pb [SI],'-'
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
    push dx
    mul  	BX
    pop dx
    xchg 	ax,DI
    ADD		DI,AX
@_NUM:   
    JCXZ @_EXNUM
    DEC      cx
    lodsb
    JE @_NM5		; <>0 ENABLES NEXT 5 OPTIONS
    CMP		AL,'^'
    JNE	@_NM2
    lodsb
    AND  AL,31
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
@_n: 
    sub  al,'0'
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
	dw _strskIp,to_erra,_0x,_errv,__ABORT
	
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

  xt find,@_NINU_
	xchg si,ax
	xor  cx,cx		; ch = 0   search from start dea
	jmps @_dofind2

@_dofindc:
	mov  cx,5		; ch = 0
	add  cl,[bx]	; search from next dea
@_dofind2: 
    push ax 		
	xchg ax,si
	LEA  di,[bx-4]	; di := bx - 4
@_findm:
	lea  DI,[DI+4]	; di := di + 4
	add di,cx		; adjust to next
	mov cl,[di]
	jcxz @_findi
	inc cx
	MOV si,AX
	rep cmpsb
    jne @_findm
	MOV cL,2
	ADD [DI+2],CX	; COUNTER OF USING & FLAG of undefinity
@_findi:
	xchg ax,di
	pop si
	mov bx,cx
	ret
		
  xt findc,@_NINU_
	xchg si,ax
	inc  pb [si]
	push bx
	call @_dofindc
	pop  cx
	inc  pb [di]
	or  bx,bx
	jnz   @_fend
	mov  bx,cx
	xchg di,ax
	xchg si,ax
	call @_dofindc
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
	dw _push,_strskIp,_pop,_exit
	
; -----------------------
; Makers
; -----------------------


  xt constant,@_defcomm
	dw @_doconst,_comma
	
  XT GETWATCH,@_GETWATCH
  XT SETWATCH,@_SETWATCH
  XT LARY,@_LARY
  XT WARY,@_WARY


; -----------------------
; Outer Interpreter
; -----------------------

  xt _ABORT,@_ABORT
		
  trap3 _xeval
  xt eval,@_COL_EVAL
		dw to_ltib,to_etib
@_eval	dw _token,_dc@,_zbran,@_xeval
		dw _found,_oper,_@exec,_BRAN,@_eval

  trap xdrop
@_xeval	dw _dropx

;  col forget1
;  dw _dictx,_dup,_fetch,to_dp,_skpdtok,_exit  

  col phmem
	dw _dictx,_cpushu,_exit

  lbl initadr
	dw  _tib,_count,_MAKESTR,to_dict	; GET CMD LINE
	DW _dp,_str,_phmem,__xeval,to_init	; GET VOCABULAY AND EVAL
	dw _tib,_inl,_accept,_exit
		
@_freemem:
  dw @_final-@_freemem-2
  
  aname '=:'
  dw _header,0
  db 0
  
@_final = $

  
MyCseg  ends
        end  Start

