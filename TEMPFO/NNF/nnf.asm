include NNF.mac

.386

MyCseg  segment para  use16

        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg, es: MyCseg

  org 0100h
		
@_Start   Label byte
@_AZERO = @_Start-0100h
  

  mov   bx,1000h     ; only 64k allocate
  mov   ah,4ah
  int   21h
  CLD

; -------------------
; Initialisation
; -------------------

PRIM ABORT
  mov bp,-320
  mov sp,-768
  
  call @_TROFF
  call @toforth
  dw _lpar 						;init interpretter
@_CICLE	dw _init,_eval,_ok,_BR,@_CICLE

; -------------------
; Variables
; -------------------

COL NOP
  DW _exit

  defer OK,_NOP

  value erra,0
  defer errv,_NOP

  point found,0
  point init,_initadr

  value MEMp,@_FREEMEM

xat 	key,_@dovar2
  vector key,_MEMK
	value CNTC,0
	value HIRES,0

xat 	emit,_@dovar2
xto 	emit,_@setvar
  XT emit,_@deferI
			DW _DROP     ;_de

	defer accept,_ACCDOS

  value ltib,0
  value etib,0
	defer source,_etib


  xat 	dp,_@dovar2
  value dp,@_FINAL
	VAR ofst,0
  value dict,0f000h
  vector cdict,_dict


;col dictx
;	dw _dict,_ex,to_dict,_exit
;col DPx
;	dw _DP,_ex,to_DP,_exit
;
;	value DOSERR,0
;	value base,10
;
;@_setbase:
;  call  @does
;  dw _c@,to_base,_EXIT
;
;xt hex,@_setbase
;  db 16
;
;xt dec,@_setbase
;  db 10
;
;xt bin,@_setbase
;  db 2
;
  cnst  bl_,32
  cnst  zero,0

XT bye,0

  cnst  tib,080h
  cnst  inl,80			; max charS in line
  cnst  tbuf,-260	  ; str evaluation
;  cnst  CSTK,-260	; str evaluation
;  cnst  LASTOK,0	; LAST TOKEN ADDRESS

		
;----------------------------------------------

PRIM ACCDOS
  POP   AX
  mov   DX,AX
  XCHG  BX,AX
	mov   [BX],AX
	mov   ah,10
	INT   21h
	INC   bx

;===========================================================
;==============================================
; PEAK & POKE PRIMITIVES


PRIM count
	inc   bx
	push  bx
	dec   bx
PRIM c@
	mov   bH,[bx]
PRIM HIbyte
	mov   BL,bh
PRIM lobyte
	mov   bh,0
  NEXT

PRIM LDM
  PUSH PW [BX-2]
  JMPS @__M2

PRIM STM
  POP PW [BX-2]
@__M2:
  DEC BX
PRIM M1
  DEC BX
  NEXT
PRIM M2
  JMPS @__M2

PRIM P1
  JMPS @_P2+1
PRIM LDP
  push  PW [BX]
  ALIG1
  SKIPA
PRIM STP
  POP PW [BX]
PRIM P2
  INC BX
  INC BX
  NEXT

COL DCONST
  DW _POP,_DFETCH,_exit

;  push  bx
;  mov   BX,DI
PRIM Dfetch
	PUSH  PW [bx+2]
PRIM fetch
	mov   bx,[bx]
	jmp   @_MAIN	

PRIM zeq
	sub   bx,1
  jmps  @_cf_bx

PRIM Uless
  pop   ax
  SUB   Ax,Bx
	skipr cx
PRIM zless
	SHL	  bx,1
@_cf_bx:
	sbb   bx,bx
  NEXT
				
; -----------------------
; Headers
; -----------------------

COL CODECOMMA
  DW _XCOMMA
col head		        ; =h
	dw _DP,_D2SGN     ; 
col header	        ; =:			NOP IS PLACE FOR THE (SAME) FUNCTION 
	dw _NOP,_token?   ;  DW _dumpstr
  DW _dup,to_dict,_COUNT,_PLUS,_store,_exit

; -----------------------
; Colon Definition
; -----------------------

COL COMPILE
  DW _POP,_LDP,_PUSH,_SKIP
COL XCOMMA
  DW _EX
COL COMMA
  DW AT_DP,_@XEP,_STP,_exit

COL @XEP
  DW _@XREX,_POPSTX

COL @comma
  DW _FETCH,_COMMA,_EXIT
  		
COL semicolon
  DW _COMPILE,_exit
col lpar							; interpretter is on
	dw to_found,_dict,_find,_exit
  
Albl col
COL colI
  DW _HEAD
  ; DW _LASTOK,_dumpstr,_DROP  ;DW _COMPILE,@_DOCOLON
col rpar							; compiler is on
	dw to_found,_TOCdict,_findc,_exit
		
;------------------------------
;@_SCANL_:  
;  POP   AX
;  push  BX AX
;  POP   EBX
;@_SCAN_:  ;where times  what  di cx bx -> index bx
;  POP   cx aX
;  push  cx
;  xchg  ax,di
;  xchg  ax,bx
;  CALL  bX
;  POP   bx
;  cld
;  JE    @@1
;  MOV   CX,bX
;@@1:
;  INC   CX
;  SUB   bX,CX
;  next

;------------------------------------------------

;-----------------------------------------
; MEMORY

XT    CPUSHU,_cnip_
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

COL TOKEN?
  DW _xtok?
COL TOKEN
  DW _SOURCE,_LTIB,_PARSE,to_ltib
COL MAKESTR
  DW _LIT,'`'
COL MSTRZ
  DW _ZERO,_SWAP,_DICT,_STM,_STM

XT	PUSHSTR,_CLnip_
  SUB   BX,CX         ; MAKE ROOM FOR CHARS
  dec   BX            ; MAKE ROOM FOR COUNTER
;  mov   PW @_LASTOK,BX    ; REGISTER FOR ERRORS & OTHER
  ALIG1
  SKIPA

XT  movESTR,_cLnip_ ; S!
  MOV   [BX],CL       ; STORE LENGTH OF THE NAME
  LEA   DI,[BX+1]
  JMPS  @_CMOVE

PRIM PARSE
  mov   CX,bx
  POP   DI
	SUB   DI,CX
	mov	  AL,' '
	inc   CX
@@P1:
	DEC	  CX
	JZ  SHORT  @@PSKIPX
	SCASB
	JAE   @@P1       	  ;{ SPACE IS ABOVE OR EQUAL TO }
	DEC   DI
@@PSKIPX:
	push di DI	        ;{;  START OF THE WORD}
	JCXZ SHORT @@PWEX
	inc   CX
@@P3:
	DEC	  CX
	JZ  SHORT  @@PWEX		    ; END OF THE WORD  IN DI
	SCASB               ;{ SPACE IS BELOW THEN}
	JB    @@P3
	DEC     DI
@@PWEX:               ;{; END OF THE WORD  IN DI}
  mov   BX,CX
	pop   ax
	sub		DI,ax		      ; LENGTH OF THE WORD
  push  DI
  NEXT

;xt	CMOVEU,@_DROP_3
;	JMPS @_CMOVEU

; -------------------
; Maths / Logic
; -------------------
		
;  xt and,_nip_
;    AND   BX,AX
;    RET
;
;  xt XOR,_nip_
;    XOR   BX,AX
;    RET
;
;XT NEG,_NOP_
;    NEG   BX
;    RET
;
xt OR,_nip_
   OR   BX,AX
   RET

PRIM pl2div
  POP     AX
	ADD     ax,bx
  push    AX
	mov     bx,AX
PRIM DIV2
@_DIV2:
	rcr     bx,1
	NEXT
PRIM D2SGN
  STC
  JMPS  @_DIV2
;
;xt dplus,@_dINU_    ; bx dx cx ax
;	ADD     ax,dx
;	ADc     bx,cx
;	RET
;
;xt dminus,@_dINU_    ; bx dx cx ax
;	sub     ax,dx
;	sbb     cx,bx
;  mov     bx,cx
;	RET
;
;COL MINUS
;	DW _NEG
COL plus
	DW _pl2div
@_xplus:
  DW _DROPX
;
;xt plmul,@_NINU_
;	TEST	al,1
;	jz	@_pl1
;	ADD	bx,dx
;@_pl1:
;	rcr	bx,1
;	rcr	ax,1
;	RET
;	
;  XT ASTZ,@_nop_
;	XOR DX,DX
;	XCHG BX,DX	
;	RET
;	
;;  COL Umul
;;	DW _XDROP
;;  COL UMmul
;;    DW _ASTZ,_TWICE,_TWICE,_plmul,_plmul,_plmul,_plmul,_EXIT
;
;  xt midiv,@_NINU_                        ; -/
;	SHL	ax,1
;	rcl	bx,1
;	CMP	bx,dx
;	jNC	@_mi1
;	sub	bx,dx
;	INC	AX
;@_mi1:
;	RET
;
;COL UDIV
;	DW _XDROP
;COL UMDIVMOD
;  DW _ASTZ,_TWICE,_TWICE,_midiv,_midiv,_midiv,_midiv,_EXIT

; -------------------
; String
; -------------------

XT  to_number,_NINU_
  push 	SI BP
  mov   CX,BX
  xchg 	ax,SI  	; START ADR
  mov		AL,10	; NUM BASE
  call  @_NUM
  xchg  AX,Di   ; RESULT
  mov   PW @_HIRES,BP
  mov   BX,CX   ; REMAINDER BYTES <> 0 ERROR
  POP   BP SI
  RET

@_NUM:
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
  NOT   DI
  NOT   BP
  inc   di
  JNE   @@2
  inc   BP
@@2:
  RET
@@n0:
  JCXZ  @@N5
  cmp  al,'#'     ; BASE := nbase
  JNE   @@N1
  XCHG  AX,DI
@@numini:
  Xor   DI,DI       ; ACCUMULATOR LO
  Xor   BP,BP       ; ACCUMULATOR HI
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
  XCHG  BP,AX
  mul   BX
  XCHG  BP,AX
  XCHG  DI,AX
  mul   BX
  XCHG  DI,AX
  add   DI,ax
  adC   BP,Dx
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
  jc    @@ton2      ; and   AL,0DFH
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
;@_TROFFZ:
  RET

;---------------------------------------
; IO

;XT SCRN,_@DOVAR2
;XT WBLK,_@_WBLK
;XT RBLK,_@_RBLK
;  DW -1 
;
;	value AX,0
;	value BX,0
;	value CX,0
;	value DX,0
;
;PRIM @_WBLK
;  MOV   CH,40H
;  LODSW
;  DB    0B8H
;PRIM @_RBLK
;  MOV   CH,3FH
;  MOV   AX,1024
;  push  AX CX
;  MUL   BX
;  XCHG  AX,DX
;  XCHG  AX,CX
;  MOV   AX,4200H
;  MOV   BX,[SI]     ; _SCRH
;  INT   21H
;  POP   AX CX DX
;  JC    @_SETREG
;@_DOS0:
;  INT   21H
;  JNC   @_SETREG
;  MOV   PW @_DOSERR,AX
;@_SETREG:
;  MOV   PW @_AX,AX
;  MOV   PW @_BX,BX
;  MOV   PW @_CX,CX
;  MOV   PW @_DX,DX
;  JMP @_DROPX
;
;PRIM DOS2
;  XOR   CX,CX
;  XOR   DX,DX
;  xchg  DX,BX
;  SKIPA
;PRIM DOS4
;  POP   CX DX
;PRIM DOS5
;  mov   AX,[SI]
;  jmps  @_DOS0
;
;XT UmMUL,_NINU_
;  mul   bx
;  mov   BX,DX
;  RET
;
;col Umul
;  DW _UMMUL,_DROPX
;
;XT FAPOS,_DOS4
;  dw  4200H
;
;XT FREAD,_DOS4
;  dw  3F00H
;
;XT FWRITE,_DOS4
;  dw  4000H
;
;XT  FCREATE,_DOS2
;  dw  3C00H         ; ????
;
;XT  FOPEN,_DOS2
;  dw  3D02H         ; ????
;
;XT  FCLOSE,_DOS5
;  dw  3E00H         ; ????
;
;XT  FNEW,_DOS2
;  dw  5B02H         ; ????

; -------------------
; Inner Interpreter
; vvvvvvvvvvvvvvvvv

PRIM DOES2
  ADD PW [BP],2
PRIM DOES1
  ADD PW [BP],2
PRIM POP
  PUSH bx
  X
  POP BX
	jmps @_STKSWP
  
PRIM DUP
  PUSH  BX

PRIM TRAP
  LODSW
	jmps @_RPUSH
  
PRIM @deferI
  INC   PW [@_CNTC]
PRIM @defer
  LODSW
  RPOP  SI
  JMPS @_MAIN1

PRIM @exec
	mov   bx,[bx]
PRIM exec
  pop   Ax
  XCHG  AX,BX
  JMPS @_MAIN1

PRIM CINU_
	POP   CX
PRIM NINU_
	POP   AX
PRIM NUP_
  CALL  SI
	PUSH  AX

PRIM EXIT
  X
  POP SI
@_STKSWP:
  X

@_MAIN:
  LODSW
@_MAIN1:
  shl AX,1
  jc  @_NEST
  jmp AX

PRIM @XREX
  push  PW [BX]
PRIM XREX
  XCHG  BX,[BP]
PRIM EXECUTE
	pop	ax
	xchg ax,bx
@_NEST:
  xchg  AX,SI
@_RPUSH:
  X
  PUSH AX
  JMPS @_STKSWP

PRIM EX
  xchg    SI,[BP]
  NEXT

PRIM @doVAR2
  LODSW
  LODSW
PRIM @doVAR
  XCHG AX,SI
  SKIPA
PRIM @doconst
	mov   ax,[SI]
  push bx
  xchg ax,bx
  JMPS @_EXIT

PRIM @setvar
  mov [SI],bx
  JMPS @_DROPX

PRIM lary
	shl   bx,1
PRIM wary
	shl   bx,1
PRIM bary
	add   bx,Si
	jmps  @_EXIT

@TODBG: JMP @_TROFF		; POINTS TO DEBUGGER IF ANY

PRIM POPSTX
  X
  POP  DI
  X
  mov   [DI],BX
PRIM DROPX
  POP   BX
@_rts:
  MOV SI,PW [BP]
PRIM RDROP
  INC BP
  INC BP
  NEXT

; ^^^^^^^^^^^^^^^^^^
; Inner Interpreter

;--------------------------------------
; Control

PRIM cnip_
  JMPS @__cnip_
PRIM cLnip_
	POP   cX
  mov   CH,0
  SKIPA
PRIM bnip_
	push   bX
@__cnip_:  
	POP   cX
PRIM nip_
	POP   AX
PRIM nop_
	CALL  SI
	jmps @_rts

PRIM nipx
	pop ax
	jmps @_rts

PRIM FOR
  mov SI,[SI]
PRIM PUSH
  X
PRIM SWAPSTK
  PUSH BX
  X
@__DROP:
  POP   BX
  next

PRIM BE
  XCHG AX,BX
  mov ah,0EH
  INT 010h
	jmps @__DROP

PRIM DE,@_USEBX_
  XCHG AX,DX
  MOV AH,2
  INT 021H
	jmps @__DROP

PRIM zSKIP
	test bx,bx
	jNe @_NONEQ
@_DRskip:		
	pop bx
@__skip:		
	lodsw
@_NONEQ:	
	jmps @_MAIN

PRIM DROP
  JMPS @__DROP

PRIM IF
	test bx,bx
	jNe @_DrSKIP
	mov si,[si]
	jmpS @__DROP	

PRIM br
	mov si,[si]
@MAIN2:
	jmp @_MAIN	

PRIM NEXT
  DEC   PW [BP]
  JNS   @_br
@_RDROPskip:
  LODSW
	jMPs @_RDROP

PRIM ifm
  JMPS @_MIF+1

PRIM mif
	inc bx
	dec bx
	JNS @_br
PRIM SKIP
	jMPs @__skip
		
; -----------------------
; Dictionary Search
; -----------------------

COL TOCdict
  DW _Cdict
COL NENTRY
  DW _COUNT,_PLUS
COL P4
  DW _P2,_P2,_EXIT

XT find,_NINU_
@_FIND:
	xor   cx,cx		  ; ch = 0   search from start dea
	mov   di,bx 
@_NEXTRY:
	mov   cl,[di]
  jcxz  @_findi
	inc   cx
	MOV   si,AX
	rep   cmpsb
  je  SHORT  @__FOUND
	add   di,cx		    ; adjust to next
  SCASW           ; di := di + 4
  SCASW
  jMPS  @_NEXTRY
@__FOUND:
	inc   cx
	INC   PW [DI+2]	; COUNTER OF USING & FLAG of undefinity
	xchg  ax,DI     ; RETURNS ADDRESS OF ADDRESS
@_findi:
	xchg  bx,cx     ; RETURNS /FOUND 1/ NOTFOUND 0/
  RET
		 
  xt findc,@_NINU_
	MOV   Di,ax
	inc   pb [Di]
  push  DI
	call  @_FIND
  POP   DI
	DEC   pb [di]
	or    bx,bx
	jnz   @_fend      ; FOUND & EXECUTE
	mov   bx,cx       ;	xchg  di,ax
	call  @_FIND
	inc bx
	inc bx
@_fend:
	ret

@_STOREGS:
  POP   dx
  push  si di bx cx dX
  xchg  ax,bx
@toforth:
  POP   si
  next

prim from4th
  jmp si

  COL eval
		dw _DUP,to_ltib,_PLUS,to_etib
@_eval:                 ;  bpnt "token/"
	dw _token             ;  bpnt "/token"    ;  dw _dumpstr
  dw _dUP,_c@,_IF,@_xplus   ;  bpnt "before-found"
  dw _found             ;  bpnt "after-found"
  dw _oper              ;  bpnt "before-@exec"
  dw _@exec             ;  bpnt "after-@exec"
  dw _BR,@_eval

  XT oper,_wary             ; OPERATE ON STATES
	dw _to_num,_@exec         ; INTERPRET
  DW _numc,_@comma          ; COMPILE
  DW 0,0                    ; REMARK

;------------------------------------------
; PRRK & POKE

COL STORE
  DW _STP,_DROPX

COL XEP
  DW _XREX,_POP,_EXIT

col to_num			; NOPS RESERVED PLACE FOR STRING FUNCTIONS
  dw _NOP
COL @TO_NUM2
  DW _count       ;  bpnt "before-num"
  dw _to_number   ;  bpnt "after-num"
  dw _err?,_exit
	
col NUMC				; NOPS RESERVED PLACE FOR STRING FUNCTIONS
    dw _NOP,_@to_num2
COL litc
  DW _COMPILE,_LIT,_COMMA,_exit
		
COL @dopoint
  DW _POP,_FETCH,_PUSH,_EXIT
;	mov ax,[di]
;	jmps @_NEST
	
PRIM @setpoint
  DW _POP,_POP,_SWAP,_STORE,_EXIT
;	mov [di+2],si
;	jmps @_rts
	
PRIM SWAP
  POP AX 
  SKIPB
PRIM lit
  LODSW
@_ph:
  push  bx
  XCHG  AX,bx
  JMP @_MAIN

PRIM DK
  MOV AH,7
  INT 021H
  MOV AH,0
  JMPS  @_PH

PRIM BK
  MOV AH,0
  INT 016H
  JMPS  @_PH

Albl initadr
;	dw  _tib,_count,_dict,_PUSHSTR,TO_dict	; GET CMD LINE
;  bpnt "init2"
	DW _dp,_LDP,_SWAP,_dict,_CPUSHU,TO_dict
;	DW _dp,_PUSHwS
;  bpnt "init3"
;  dw _xeval,
  DW _GETLINE
  DW to_init	; GET VOCABULAY AND EVAL
COL GETLINE
	dw _tib,_inl,_accept,_NOP,_exit
	
; -----------------------
; errors prompt
; -----------------------

COL strskIp
  DW _POP,_POP,_COUNT,_PLUS,_LIT,1,_OR,_P1,_PUSH,_PUSH,_EXIT

  col error?
    dw _strskIp     ;    bpnt "error?"
    dw  to_erra,_IF,@_xplus,_errv,_ABORT
	
  col xtok?
    dw _EX,_dUP,_c@
  col nz?
    dw _zeq
  col err?
    dw _error?
    aname '?'
    dw _exit

;-------------------------------------------
; MEM IO

COL MEMK
  DW _MEMp,_COUNT,_SWAP,to_MEMp,_DUP,_IF,@_STDIO,_EXIT
  ;DW _MEMp,_COUNT,_SWAP,to_MEMp,_DUP,_ZSKIP,_EXIT,_ZERO,_STDIO,_EXIT
COL STDIO
@_STDIO:
  DW __STD
COL SETIO
  DW TO_KEY,TO_EMIT,_EXIT

XT _STD,_DCONST
  DW _DK,_dE

COL SET_IO
  DW _POP,_Dfetch,_SETIO,_EXIT

XT BIO,_SET_IO
  DW _BK,_BE

;===========================================

@_freemem:
  dw @_final-@_freemem-2
  
  aname '=:'
  dw _header,0
  db 0
  
@_FINAL = $
  
MyCseg  ends
        end  @_Start

