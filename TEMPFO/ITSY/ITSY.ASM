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

PRIM accpt
  POP   AX
  mov   DX,AX
  XCHG  BX,AX
	mov   [BX],AX
	mov   ah,10
	CALL  @DOS
	INC   bx

;===========================================================

@_count:
	inc   bx
	push  bx
	dec   bx
@_c@:		
	mov   bH,[bx]
@_HIbyte:
	mov   BL,bh
@_lobyte:
	mov   bh,0
	jmps @_DONE

@_STP:	
	POP	[bx]
	INc bx
@_P:
	INc bx
@_DONE:
	jmp @_DONEXT      ; =================  !!!

@_STM:	
	POP	  [bx-2]
	dec   bx
@_M:
	dec   bx
	jmps  @_DONE
	
@_dc@:
	push  bx
	jmps  @_c@

;------------------------------
; FLAGS & REGISTERS
	
@_xr:
	xchg  bx,[bp]         ;XR
  jmps  @_DONE
	
@_XA:
  xchg  DX,[BP]         ;XA
  jmps  @_DONE
	
@_Uless:
  pop   ax
  SUB   Ax,Bx
	skipr cx
@_zless:
	SHL	  bx,1
@_cf_bx:
	sbb   bx,bx
	jmps  @_DONE		
@_zeq:		
	sub   bx,1
  jmps  @_cf_bx
				
  XT  RSP,@_DUSWA_
  MOV   AX,RSP
  RET

  XT  DSP,@_DUSWA_
  MOV   AX,DSP
  RET

  XT  RSPST,@_DROP_
  MOV   RSP,BX
  RET

PRIM DSPST
  mov   DSP,bx
  NEXT

;==============================================
; PEAK & POKE PRIMITIVES

@_DCONST:
  push  bx
  mov   BX,DI
@_Dfetch:
	PUSH  [bx+2]
@_fetch:
	mov   bx,[bx]
	jmp   @_DONEXT	

@_getwatch:
	mov	  di,[di]
@_doconst:
	mov   ax,[di]
	jmp   @_ph
	
@_setwatch:
	mov   di,[di+2]
	skipb
@_setvar:
	scasw
	mov   [di],bx
	jmp   @_drop
	
@_lary:
	shl   bx,1
@_wary:
	shl   bx,1
@_bary:
	add   bx,di
	jmps  @_DONEXT
;------------------------------------------------


;------------------------------------------------
; Inner Interpreter


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
	
	scasw
	scasw
@_does:
	pop ax
	push bx
	mov	 bx,di
@_pcpush:		
	xchg ax,si
@_rpush:	
  X
  push  AX
  X
	jmps @_DONEXT
	
@_DINU_:  
	POP	  DX
@_CINU_:  
	POP	  CX
@_NINU_:  
	POP   AX
@_NUP_:   
	CALL  DI
@_phax:	
	PUSH  AX
	jmps  @_DONEXT
		
	scasw
	scasw
	scasw
@_TRAP:
	skipr cx
@_cont:
	dec   di
	dec   di
@_twice:	
	XCHG  ax,di
	jmps  @_rpush
	
@_execute:
	pop	ax
	xchg ax,bx
	skipa
@_dopoint:
	mov ax,[di]
	jmps @_pcpush
	
@_RSLD_:
	push  BX
	XOR		ah,ah
	SKIPR Cx
@_RSST_:
	POP	  AX
	xchg  AX,bx
	xchg  SI,[BP]
	call  DI
@_EX:
  xchg    SI,[BP]
  jmps  @_DONEXT

@_DROP_3: 
	POP   CX        ;DRP3
@_DROP_2: 
	POP   AX        ;DRP2
@_DROP_:  
	xchg	DI,BX
@_CALDR_:  
	CALL  BX        ;DRP
@_drop:		
  pop bx
  jmps @_DONEXT   ; GETS 1,2,3 RETURNS 0

@_cLnip_:  
	POP   cX
  mov   CH,0
  SKIPA
@_bnip_:  
	push   bX
@_cnip_:  
	POP   cX
@_nip_:   
	POP   AX
@_nop_:   
	CALL  DI
	jmps @_DONEXT     ; GETS 1,2,3 RETURNS 1

@_SOURCE_:
	mov		AX,@_Etib
	mov		cx,@_ltib
	SUB   AX,CX
@_dup_:
  push bx
	jmps @_nop_

@_swapc_:
	pop   cx
@_swap_:
	pop   ax
@_DUSWA_:
	call  di      ; GETS 1,2,3 RETURNS 2

; -------------------
; Inner Interpreter
; vvvvvvvvvvvvvvvvv

@_ph:
  push bx
@_sw:
  xchg ax,bx

@_DONEXT:   
  mov di,[si]
  cmpsw
@_DONEXT1:		
  jmp [di-2]

@_TODBG: JMP @_TROFF		; POINTS TO DEBUGGER IF ANY

; ^^^^^^^^^^^^^^^^^^
; Inner Interpreter


; -------------------
; STACK

@_j:
	mov	ax,[bp+2]
	jmps @_ph
	
@_pop:
	mov	ax,[bp]
	inc bp
	inc bp
	jmps @_ph

@_DROPDUP:
	POP BX
@_dup:
	push bx
	jmps @_DONEXT
	
@_setpoint:
	mov [di+2],si
	jmps @_rts
	
@_nipx:
	pop ax
	jmps @_rts

@_0ex:	
	or bx,bx
	jNe @_drop
	
@_dropx:
	pop bx
@_rts:
	mov si,[bp]
@_rdrop:		
	inc bp
	inc bp
	jmps @_DONEXT
	
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

;--------------------------------------
; Control

@_for:
	mov	  si,[si]
@_push:
	pop   ax
	xchg  ax,bx
	jmp   @_rpush
@_zSKIP:
	test bx,bx
	jNe @_NONEQ
@_DRskip:		
	pop bx
@_skip:		
	lodsw
@_NONEQ:	
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
  DEC   PW [BP]
  JNS   @_br
@_RDROPskip:
  LODSW
	jMPs @_RDROP
@_mif:
	inc bx
@_ifm:	
	dec bx
	JNS @_br
	jMPs @_skip
		
;-----------------------------------------
; MEMORY

  XT PARSE,@_SOURCE_
  XCHG  AX,DI
	mov	  AL,' '
	inc   CX
@@P1:
	DEC	  CX
	JZ    @@PSKIPX
	SCASB
	JAE   @@P1       	  ;{ SPACE IS ABOVE OR EQUAL TO }
	DEC   DI
@@PSKIPX:
	push di  		        ;{;  START OF THE WORD}
	JCXZ  @@PWEX
	inc   CX
@@P3:
	DEC	  CX
	JZ    @@PWEX		    ; END OF THE WORD  IN DI
	SCASB               ;{ SPACE IS BELOW THEN}
	JB    @@P3
	DEC     DI
@@PWEX:               ;{; END OF THE WORD  IN DI}
	mov		@_ltib,cx
	pop   ax
	mov		cx,di
	sub		cx,ax		      ; LENGTH OF THE WORD
  SKIPA

  XT	MAKESTR,@_Bnip_
  mov   BX,@_dict     ; END OF DICTIONARY
  SUB   BX,4          ; MAKE ROOM FOR ADDRESS & COUNTER
  mov   PW [BX+2],0   ; SET  COUNTER
  mov   CH,0          ; MAX 255  - REAL 250 B LENGTH OF NAME
  mov   PB [BX],'`'   ; after TOKEN flag
  SKIPA

  XT	PUSHSTR,@_CLnip_
  SUB   BX,CX         ; MAKE ROOM FOR CHARS
  dec   BX            ; MAKE ROOM FOR COUNTER
  mov   @_LASTOK,BX    ; REGISTER FOR ERRORS & OTHER
  SKIPA

  XT  movESTR,@_cLnip_ ; S!
  MOV   [BX],CL       ; STORE LENGTH OF THE NAME
  LEA   DI,[BX+1]
  JMPS  @_CMOVE

  XT    CPUSHU,@_cnip_
  mov   DI,bx
  SUB   BX,CX
@_CPUSHU:
	ADD   AX,CX
@_CMOVEU:
	STD
	DEc	  AX
	DEC   DI
@_CMOVE:
	XCHG  AX,SI
	REP   MOVSB
	XCHG  AX,SI
	CLD
@_troff: 
	RET

  xt	CMOVEU,@_DROP_3
	JMPS @_CMOVEU

  XT	CMOVE,@_DROP_3
	JMPS @_CMOVE
		
  xt FILL,@_DROP_3
	XCHG AX,DI
	REP STOSB
	RET
	
  xt FILLW,@_DROP_3
	XCHG AX,DI
	REP STOSW
	RET
	

; -------------------
; Variables
; -------------------

  value erra,0
  defer errv,0

  point found,0
  point init,_initadr

  defer key,_dk
	value CNTC,0
  XT emit,@_deferI
			DW _de
	defer accept,_accpt

  value ltib,0
  value etib,0
	defer source,_etib
  value dp,@_freemem
	value ofst,0
  value dict,0f000h-270
  vector cdict,_dict
col dictx
	dw _dict,_ex,to_dict,_exit
col DPx
	dw _DP,_ex,to_DP,_exit

	value DOSERR,0

  cnst  zero,0
  cnst  tib,080h
  cnst  inl,80			; max char in line
  cnst  tbuf,0f000h-260	; str evaluation
  cnst  LASTOK,0	; LAST TOKEN ADDRESS

		
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

  xt lit,@_DUSWA_
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

;  COL MINUS
;	DW _NEG
;  COL plus
;	DW _pl2div,_DROPX
	
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
	
XT STM,@_stm          ; !-

XT STP,@_stP          ; !+

XT STR,@_DUSWA_        ; STR
  MOV   AX,[BX]
	INC   BX
	INC   BX
	RET

  
xt STRSKIP,@_RSLD_	  ; string skip
	MOV     BX,si
	lodsb
	add		si,AX
	ret

  XT	RLDP,@_RSLD_       ; @R+
	LODSW
	xchg    AX,bx
	RET

  XT    RSTP,@_RSST_      ;!R+
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

COL COMPILE
  DW _RLDP,_comma,_EXIT
  		
COL semicolon
  DW _COMPILE,_exit
col lpar							; interpretter is on
	dw to_found,_dict,_find,_exit
  
lbl col
COL colI
  DW _HEAD,_COMPILE,@_DOCOLON
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
  XT TRAP,@_TWICE
  XT TWICE,@_TWICE
  XT FOR,@_FOR
  XT IFM,@_IFM
  XT MIF,@_MIF
  XT NEXT,@_NEXT
  xt exit,@_rts
  xt ex,@_ex
  xt @exec,@_exec@
  xt dropx,@_dropx
;  XT SWAPX,@_SWAPX
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

XT  to_number,@_NINU_
  push 	SI 
  mov   CX,BX
  xchg 	ax,SI  	; START ADR
  mov		AL,10	; NUM BASE
  call  @NUM
  xchg  AX,Di   ; RESULT
  mov   BX,CX   ; REMAINDER BYTES <> 0 ERROR
  POP   SI
  RET

@NUM:
  CALL  @@numini
  CALL  @@END?
  CALL  @@SGN
@@NUMZ:
  CALL  @@END?
  CALL  @@N0
  JMPS  @@NUMZ

@@SGN:
  CMP   AL,'-'     ; SGN
  JNE   @@n0
  POP   dX
  CALL  dX         ; return to caller
  NEG   DI
  RET
@@n0:
  JCXZ  @@N5
  cmp  al,'#'     ; BASE := nbase
  JNE   @@N1
  XCHG  AX,DI
@@numini:
  Xor   DI,DI       ; ACCUMULATOR
@@setbas:
  DEC   AX
  DEC   AX
  xor   ah,ah
  mov   BX,ax
  INC   BX
  INC   BX
  RET
@@N1:
  cmp   al,''''
  jNE   @@N2
  LODSB
@@ESCAPE1:
  deC   CX
@@ESCAPE:
  XCHG  DI,AX
  mul   BX
  XCHG  DI,AX
  add   DI,ax
  JCXZ  @@EXNUM
  RET
@@N2:
  cmp   al,'^'
  jNE   @@N3
  LODSB
  AND   AL,31
  JMPS @@ESCAPE1
@@N3:
  cmp   al,'%'     ; BASE := 16
  JNE   @@N4
  MOV   al,2
  jmp   SHORT @@setbas
@@N4:
  cmp   al,'$'     ; BASE := 16
  JNE   @@N5
  MOV   al,16
  jmp   SHORT @@setbas

@@N5:
  cmp   al,'9'+1
  jc    @@ton2
  and   AL,0DFH
  cmp   al,'A'      ; no case sensivity
  jc    @@ERNUM
  sub   al,7
@@ton2:
  sub   al,'0'
  cmp   ax,BX
  jc   @@ESCAPE  ;ERNUM
@@ERNUM:
  INC   CX
@@EXNUM:
  pop   dx    ; rdrop
  RET
@@END?:
  JCXZ  @@ERNUM
  deC   CX
  LODSB
@_TROFFZ:
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
; Input / Output
; -----------------------

;  xt accpt,@__accept

xUNpack:XOR   ax,AX
        xchg  Al,bh
        PUSHREG

xpack:  pop   ax
        xchg  bl,bh
        mov   bl,al
        next


  col token?
    dw _xtok?
  col token
    dw _source,_parsE,_exit
	
;---------------------------------------
; IO

XT SCRN,@_DOVAR-2
XT WBLK,XWBLK
XT RBLK,XRBLK
  DW -1 

	value AX,0
	value BX,0
	value CX,0
	value DX,0

XWBLK:  
  MOV   CH,40H
  DB    0B8H
XRBLK:  
  MOV   CH,3FH
  MOV   AX,1024
  push  AX CX
  MUL   BX
  XCHG  AX,DX
  XCHG  AX,CX
  MOV   AX,4200H
  MOV   BX,[DI]     ; _SCRH
  call  @DOS
  POP   AX CX DX
  JC    @SETREG
@DOS0:
  call  @DOS
@SETREG:
  MOV   @_AX,AX
  MOV   @_BX,BX
  MOV   @_CX,CX
  MOV   @_DX,DX
  DROPREG

@DOS2:
  XOR   CX,CX
  XOR   DX,DX
  xchg  DX,BX
  SKIPA
@DOS4:
  POP   CX DX
@DOS5:
  mov   AX,[DI]
  jmps  @DOS0

;XT UMUL,@_NINU_
;  mul   bx
;  mov   BX,DX
;  RET

XT FAPOS,@DOS4
  dw  4200H

XT FREAD,@DOS4
  dw  3F00H

XT FWRITE,@DOS4
  dw  4000H

XT  FCREATE,@DOS2
  dw  3C00H         ; ????

XT  FOPEN,@DOS2
  dw  3D02H         ; ????

XT  FCLOSE,@DOS5
  dw  3E00H         ; ????

XT  FNEW,@DOS2
  dw  5B02H         ; ????

  xt dk,@_DUSWA_
@_getchar:
	mov ah,7
	int 021h
	mov ah,0
	ret

  xt de,@_DROP_
@_outchar:
  mov   DX,BX
	mov   ah,2
@DOS: 
	int   021h
	PUSH  AX
	JC    @@DOS
	XOR   AX,AX
@@DOS:  	
	MOV   @_DOSERR,AX
	POP   AX
	ret

; -----------------------
; Dictionary Search
; -----------------------

@_dofindc:
	mov  cx,5		; ch = 0
	add  cl,[bx]	; search from next dea
	jmps @_dofind2

xt find,@_NINU_
	xor   cx,cx		  ; ch = 0   search from start dea
@_dofind2: 
  push  SI AX
	mov   di,bx 
  SKIPA
@_NEXTRY:
  SCASW           ; di := di + 4
  SCASW
	add   di,cx		    ; adjust to next
  MOV   BX,DI
	mov   cl,[di]
  jcxz  @_findi
	inc   cx
	MOV   si,AX
	rep   cmpsb
  jne   @_NEXTRY
	MOV   cL,2
	ADD   [DI+2],CX	; COUNTER OF USING & FLAG of undefinity
	xchg  ax,DI     ; RETURNS ADDRESS OF ADDRESS
@_findi:
	pop   DI si
	MOV   bx,cx     ; RETURNS /FOUND 2/ NOTFOUND 0/
	ret
		
  xt findc,@_NINU_
	MOV   Di,ax
	inc   pb [Di]
	push  bx
	call  @_dofindc
	pop   cx
	DEC   pb [di]
	or    bx,bx
	jnz   @_fend      ; FOUND & EXECUTE
	mov   bx,cx
;	xchg  di,ax
	call  @_dofindc
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
	
  xt CREATE,@_defcomm
	dw @_doVAR,_NOP
	
  XT GETWATCH,@_GETWATCH
  XT SETWATCH,@_SETWATCH
  XT LARY,@_LARY
  XT WARY,@_WARY


; -----------------------
; Outer Interpreter
; -----------------------

  xt _ABORT,@_ABORT
		
  lbl oper  ; OPERATE ON STATES
	dw @_wary,_@exec,_to_num,_@comma,_numc

  trap3 _xeval
  xt eval,@_COL_EVAL
		dw to_ltib,to_etib
@_eval	dw _token,_dc@,_zbran,@_xeval
		dw _found,_oper,_@exec,_BRAN,@_eval

  trap xdrop
@_xeval	dw _dropx

;  col forget1
;  dw _dictx,_dup,_fetch,to_dp,_skpdtok,_exit  

  COL   PUSHwS
    DW  _str
  COL   PUSHwSTR
    dw _dictx,_cpushu,_exit

  COL PUSHcS
    dw  _count
  col phCSTR
    dw _dictx,_PUSHSTR,_exit

  lbl initadr
	dw  _tib,_PUSHcS	; GET CMD LINE
	DW _dp,_PUSHwS,__xeval,to_init	; GET VOCABULAY AND EVAL
	dw _tib,_inl,_accept,_exit
		
@_freemem:
  dw @_final-@_freemem-2
  
  aname '=:'
  dw _header,0
  db 0
  
@_final = $

  
MyCseg  ends
        end  Start

