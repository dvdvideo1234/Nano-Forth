include NNF.mac

.386

MyCseg  segment para  use16

        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg, es: MyCseg

  org 0100h
		
@_Start   Label byte
@_Z = @_Start-0100h
  

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
@_CICLE	dw _init,_eval,_OK,_BR,@_CICLE

; -------------------
; Variables
; -------------------

  defer errv,_?ERR
  defer OK,_NOP

;  value erra,0

  point found,0
  point init,_initadr

;COL XMEM
;  DW  _MEMp,_SWAP
  value MEMp,@_FINAL

  vector key,_BK

COL HIRES
  DW _@dovar2
value RES,0
    DW 0

xto 	emit,_@setvar
  XT emit,_@deferI
			DW _BE    

COL CR
  DW _PRT
  DB 2,13,10,0
  DW _zero
value CNTC,0

	defer accept,_ACCDOS

COL Xltib
  DW  _ltib,_EX
  value ltib,0
  value etib,0
	defer source,_etib


COL XDP
  DW  _DP,_EX
  value dp,@_FINAL

COL XDICT
  DW  _DICT,_EX
  value dict,0E000h

  vector cdict,_dict

COL SPC
  DW _XEMIT
  cnst  bl_,32

  cnst  zero,0
  cnst  ONE,1
  cnst  MONE,-1

  ORG   $-2
XT bye,0

;  cnst  tib,080h
;  cnst  inl,80			; max charS in line
;  cnst  tbuf,-260	  ; str evaluation
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

;PRIM LDPB
;  XOR   AH,ah
;  mov   AL,[BX]
;  push  AX
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

  push  bx
  mov   BX,DI
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

COL XCOMMA
  DW _EX,_COMMA,_EXIT

COL @comma
  DW _FETCH
COL COMMA
  DW _XDP,_STP
COL NOP
  DW _exit

;COL @XEP
;  DW _@XREX,_POPSTX

  		
COL semicolon
  DW _LIT,_exit,_COMMA
col lpar							; interpretter is on
	dw to_found
COL INDICT
  DW  _dict
XT find,_NINU_
@_FIND:
  push  SI
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
  POP   SI
  RET
		 
Albl col
COL colI
  DW _HEAD
  ; DW _LASTOK,_dumpstr,_DROP  ;DW _COMPILE,@_DOCOLON
col rpar							; compiler is on
	dw to_found,_TOCdict
xt findc,@_NINU_
	MOV   Di,ax
	inc   pb [Di]
  push  DI
	call  @_FIND
  POP   DI
	DEC   pb [di]
	or    bx,bx
	jnz   SHORT @_fend      ; FOUND & EXECUTE
	mov   bx,cx       ;	xchg  di,ax
	call  @_FIND
	inc bx
	inc bx
@_fend:
	ret


;------------------------------
@SCANL: 
  POP   DX
  push  BX 
  POP   EAX
  SKIPA
@SCAN:  ;  ;where times  what  di cx bx -> index bx
  POP   DX
  xchg  ax,bx
  POP   cx DI
  push  cx
  CALL  DX
  POP   bx
  cld
  JE  SHORT  @@1
  MOV   CX,bX
@@1:
  INC   CX
  SUB   bX,CX
  NEXT

;------------------------------------------------

;-----------------------------------------
; MEMORY

COL TODICT
  DW  _XDICT
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
  DW _PARSE,_MAKESTR,_dUP,TO_RES
COL DC@
  DW _dUP,_c@,_EXIT
COL PARSE
  DW _SOURCE,_XLTIB
XT  PARS,_NIP_
  POP   DX
  mov   CX,bx
  XCHG  AX,DI
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
	DEC   DI
@@PWEX:               ;{; END OF THE WORD  IN DI}
  mov   BX,CX         ; BUFFER REMAINDER
	pop   ax
	sub		DI,ax		      ; LENGTH OF THE WORD
  push  DI
  JMP   DX

COL MAKESTR
  DW _LIT,'`'
COL MSTRZ
  DW _ZERO,_DICT,_STM,_STM

XT	PUSHSTR,_Cnip_
  XOR   CH,CH
  SUB   BX,CX         ; MAKE ROOM FOR CHARS
  dec   BX            ; MAKE ROOM FOR COUNTER
  ALIG1
  SKIPA

XT  movESTR,_cnip_ ; S!
  XOR   CH,CH
  MOV   [BX],CL       ; STORE LENGTH OF THE NAME
  LEA   DI,[BX+1]
  JMPS  @_CMOVE

; -------------------
; Maths / Logic
; -------------------
		
COL ODD
  DW _ONE
xt and,_nip_
  AND   BX,AX
  RET

COL NEG
  DW  _M1
COL NOT
  DW  _MONE
xt XOR,_nip_
  XOR BX,AX
  RET

xt OR,_nip_
   OR   BX,AX
   RET

COL MINUS
	DW _NEG
COL plus
	DW _pl2div
@_xplus:
  DW _DROPX

PRIM pl2div
  POP     AX
	ADD     ax,bx
  push    AX
	mov     bx,AX
PRIM DIV2
@_DIV2:
	rcr     bx,1
@_MD:
	NEXT
PRIM D2SGN
  STC
  JMPS  @_DIV2

xt dplus,@_dINU_    ; bx dx cx ax
	ADD     ax,dx
	ADc     bx,cx
	RET

xt dminus,@_dINU_    ; bx dx cx ax
	sub     ax,dx
	sbb     cx,bx
  mov     bx,cx
	RET

PRIM plmul
  POP   AX
	TEST	al,1
	jz	  SHORT @_pl1
	ADD	  bx,dx
@_pl1:
	rcr	  bx,1
	rcr	  ax,1
@_mi1:
  push  AX
	JMPS @_MD
	
PRIM midiv                       ; -/
  POP   AX
	SHL	  ax,1
	rcl	  bx,1
	CMP	  bx,dx
	jNC	  SHORT @_mi1
	sub	  bx,dx
	INC	  AX
	JMPS  @_mi1

  XT ASTZ,_nop_
	XOR DX,DX
	XCHG BX,DX	
	RET
	
;COL Umul
;  DW _DROPX
;COL UMmul
;  DW _ASTZ
;  DW _@UM1
;COL @UM1
;  DW _@UM2
;COL @UM2
;  DW  _plmul,_plmul,_plmul,_plmul,_EXIT

;COL UDIV
;	DW _DROPX
;COL UMDIVMOD
;  DW _ASTZ
;  DW _@UD1
;COL @UD1
;  DW _@UD2
;COL @UD2
;  DW _midiv,_midiv,_midiv,_midiv,_EXIT

; -------------------
; String
; -------------------

@_pkbyte:
    dec  cx
    je   SHORT @@wave
    mov  ah,255
    cmp  al,'"'
    jne  SHORT @@chav
@@store:
    lodsb
    and  al,ah
    dec  cx
    stosb
    ret
@@chav:
    mov  ah,31
    cmp  al,'^'
    je   @@store
@@wave:
    cmp  al,'~'
    jne  SHORT @@end_
    mov  al,80H
    xor  [di-1],al
    ret
@@end_:
    cmp  al,'_'
    jne  SHORT @@end
    mov  al,' '
@@end:
    stosb
  RET

XT ascPk,_Cnip_
  xchg  ax,Si
  XOR   CH,CH
  mov   di,BX
  STOSB
  push  DI
@@loop:
  jcxz  SHORT @@res
  lodsb
  call  @_pkbyte
  jmp   @@loop
@@res:
  xchg  ax,di
  POP   CX
  sub   Ax,CX
  mov   [BX],AL
  RET

@_STRCMD:
  call  @_search
  db 5,'"', ',', '.', '!','?'
@_search:
  POP   CX
  PUSH  di
  mov   DI,CX
  XOR   CH,CH
  mov   CL,[DI]
  INC   DI
  repne scasb
  POP   DI
  RET

xt unpk?,_NOP_
  mov   al,[bx]
  CMP   al,2
  JB    SHORT @_notok
  XOR   aH,aH
  mov   di,ax
  mov   al,[bx+di]
  CMP   al,'"'
  jNe   SHORT @_notok
  mov   al,[bx+1]
  call  @_STRCMD
  jNe   SHORT @_notok
  inc   cx
  mov   AL,[BX]
  dec   AX
  dec   AX
  inc   bx
  mov   [BX],AL
  mov   al,CL
  skipa
@_notok:
  mov   al,ah
@_DUSWA_:
  POP   DI
  push  BX
  xchg  AX,BX
  jmp   DI

col to_num			; NOPS RESERVED PLACE FOR STRING FUNCTIONS
  dw _NOP
COL @TO_NUM2
  DW _LSTR_to_number,_NIP
col err?
  dw _Z?
  aname '?'
  dw _exit
	
COL  LSTR_to_number
  DW  _COUNT
XT  to_number,_NINU_
  mov   CX,BX
  XOR   EBX,EBX ; CLEAR BASE
  xchg 	ax,SI  	; START ADR
  XOR   EAX,EAX
  mov		AL,10	  ; NUM BASE 10
  call  @_NUM
  mov   BX,CX   ; REMAINDER BYTES <> 0 ERROR
  POP   DX      ; RETURN ADDRESS
  push  di      ; RESULT LO
  SHR   edi,16  
  xchg  DI,AX   ; RESULT HI
  jmp   DX

col NUMC				; NOPS RESERVED PLACE FOR STRING FUNCTIONS
    dw _NOP,_@to_num2
COL litc
  DW _LIT,_LIT,_COMMA,_COMMA,_exit
		
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
  JNE   SHORT @@n0
  POP   dX
  CALL  dX         ; return to caller
  Neg   EDI
  RET
@@n0:
  JCXZ  SHORT @@N5
  cmp  al,'#'     ; BASE := nbase
  JNE   SHORT @@N1
  XCHG  AX,DI
@@numini:
  Xor   EDI,EDI       ; ACCUMULATOR
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
  jNE   SHORT @@N2
  LODSB
@@ESCAPE1:
  deC   CX
@@ESCAPE:
  XCHG  EAX,EDI
  mul   EBX
  XCHG  EDI,EAX
  add   EDI,Eax
  JCXZ  SHORT @@EXNUM
  RET
@@N2:
  cmp   al,'^'
  jNE   SHORT @@N3
  LODSB
  AND   AL,31
  JMPS @@ESCAPE1
@@N3:
  cmp   al,'%'     ; BASE := 2
  JNE   SHORT @@N4
  MOV   al,2
  jmp   SHORT @@setbas
@@N4:
  cmp   al,'$'     ; BASE := 16
  JNE   SHORT @@N5
  MOV   al,16
  jmp   SHORT @@setbas

@@N5:
  cmp   al,'9'+1
  jc    SHORT @@ton2      ; 
  and   AL,0DFH     ; no case sensivity
  cmp   al,'A'      
  jc    SHORT @@ERNUM
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
  RET

;---------------------------------------
; IO

XT SCRN,_@DOVAR2
XT WBLK,_@_WBLK
XT RBLK,_@_RBLK
  DW -1 

	value AX,0
	value BX,0
	value CX,0
	value DX,0
	value DERR,0

PRIM @_WBLK
  MOV   CH,40H
  LODSW
  SKIPA
PRIM @_RBLK
  MOV   CH,3FH
  MOV   AX,1024
  push  AX CX
  MUL   BX
  XCHG  AX,DX
  XCHG  AX,CX
  MOV   AX,4200H
  MOV   BX,[SI]     ; _SCRH
  INT   21H
  XCHG  AX,DI
  POP   AX CX DX
  JC    @_SETREG
@_DOS0:
  INT   21H
  JNC   @_SETREG
  mov   DI,AX
@_SETREG:
  rcl   DI,1
  MOV   PW @_DERR,DI
  MOV   PW @_AX,AX
  MOV   PW @_BX,BX
  MOV   PW @_CX,CX
  MOV   PW @_DX,DX
  JMP @_DROPX

PRIM DOS2
  XOR   CX,CX
  XOR   DX,DX
  xchg  DX,BX
  SKIPA
PRIM DOS4
  POP   CX DX
PRIM DOS5
  mov   AX,[SI]
  jmps  @_DOS0

XT UmMUL,_NINU_
  mul   bx
  mov   BX,DX
  RET

col Umul
  DW _UMMUL,_DROPX

XT FAPOS,_DOS4
  dw  4200H

XT FREAD,_DOS4
  dw  3F00H

XT FWRITE,_DOS4
  dw  4000H

COL FREWRITE
  DW  _FLUSE
XT  FCREAT,_DOS2
  dw  3C00H         ; ????

COL FOPEN
  DW  _FLUSE
XT  FOPE,_DOS2
  dw  3D02H         ; ????

COL FCREATE
  DW  _FLUSE
XT  FNEW,_DOS2
  dw  5B02H         ; ????

XT  FCLOSE,_DOS5
  dw  3E00H         ; ????

COL FLUSE           ; USE FILE WITH NAME 
  DW _TOKEN?,_DUP,_COUNT,_PLUS,_ZERO,_SWAPST,_P1,_EX,_AX
COL IO?
  DW _DERR,_ODD,_Z?
  ANAME "IO?"
  DW _EXIT
  
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
  
PRIM TRAP
  LODSW
  SHL   AX,1    ; !!!!  ONLY FOR COLON DEFS
	jmps @_RPUSH
  
@toforth:
  POP   si
  JMPS @_MAIN

PRIM @deferI
  INC   PW [@_CNTC]
PRIM @defer
  LODSW
  CALL  @_RTS
  JMPS @_MAIN1

PRIM @exec
	mov   bx,[bx]
PRIM exec
  pop   Ax
  XCHG  AX,BX
  JMPS @_MAIN1

PRIM NINU_
  JMPS  @_NINU
PRIM DINU_
	POP   DX
PRIM CINU_
	POP   CX
@_NINU:
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
  jc  SHORT @_NEST
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
  mov [SI+2],bx
  JMPS @_DROPX

PRIM lary
	shl   bx,1
PRIM wary
	shl   bx,1
PRIM bary
	add   bx,Si
	jmps  @_EXIT

PRIM FRTS
  PUSH SI
@_RTS:
  MOV SI,PW [BP]
  INC BP
  INC BP
  ret

@TODBG: JMP @_TROFF		; POINTS TO DEBUGGER IF ANY

PRIM POPSTX
  X
  POP  DI
  X
  mov   [DI],BX
PRIM DROPX
  POP   BX
  jmps @_EXIT

; ^^^^^^^^^^^^^^^^^^
; Inner Interpreter

;--------------------------------------
; Control

PRIM nip_
  JMPS @_nip
PRIM cnip_
	POP   cX
@_nip:  
	POP   AX
PRIM nop_
	CALL  SI
	jmps @_EXIT

COL XNIP
  dw  _EX
COL NIP
  dw  _NIPX
PRIM nipx
	pop ax
	jmps @_EXIT

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

PRIM DE
  MOV   DX,BX
  MOV AH,2
  INT 021H
	jmps @__DROP

PRIM zSKIP
	test bx,bx
	jNe SHORT @_NONEQ
@_DRskip:		
	pop bx
@__skip:		
	lodsw
@_NONEQ:	
	JMPS @_MAIN2

PRIM IF
	test bx,bx
	jNe @_DrSKIP
	mov si,[si]
PRIM DROP
	jmpS @__DROP	

PRIM br
	mov si,[si]
@_MAIN2:
	NEXT	

PRIM NEXT
  DEC   PW [BP]
  JNS   @_br
@_RDROPskip:
  LODSW
PRIM RDROP
  INC BP
  INC BP
	JMPS @_MAIN2

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

prim from4th
  jmp si

COL Xeval
  dw  _EX
COL eval
		dw _DUP,to_ltib,_PLUS,to_etib
@_eval:                 ;  bpnt "token/"
	dw _token,_IF,@_xplus   ;  bpnt "before-found"
  dw _found             ;  bpnt "after-found"
  dw _oper              ;  bpnt "before-@exec"
  dw _@exec             ;  bpnt "after-@exec"
  dw _BR,@_eval

  XT oper,_wary             ; OPERATE ON STATES
	dw _to_num,_@exec         ; INTERPRET
  DW _numc,_@comma          ; COMPILE
  DW 0,0                    ; REMARK

;------------------------------------------
; PEAK & POKE

COL XEP
  DW _XREX,_POP,_EXIT

COL @dopoint
  DW _POP,_FETCH,_PUSH,_EXIT
	
COL @setpoint
  DW _POP,_P2,_POP
COL SWAPST
  DW _SWAP
COL STORE
  DW _STP,_DROPX

PRIM SWAP
  POP AX 
  SKIPB
PRIM lit
  LODSW
@_ph:
  push  bx
  XCHG  AX,bx
  JMP @_MAIN

PRIM J
  mov   AX,[BP+2]
  SKIPA
PRIM DUP
  MOV  AX,bx
  JMPS  @_PH  

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
	DW _dp,_LDP,_SWAP,_TOdict
;	DW _dp,_PUSHwS
;  bpnt "init3"
  dw _LIT,@_FINAL,_LIT,0E000H-(@_FINAL-@_Start),_xeval
  ;DW _GETLINE
  DW to_init	; GET VOCABULAY AND EVAL
COL GETLINE
	dw _LIT,080h,_LIT,80,_accept,_SPC,_exit

;  cnst  tib,080h
;  cnst  inl,80			; max charS in line
	
; -----------------------
; errors prompt
; -----------------------

@_STKR:
  POP   DX
  push  BX
  XOR   AH,AH
  JMPS  @_STK
@_STKW:
  POP   DX AX
  XCHG  AX,BX
@_STK:  
  xchg  SI,[BP]
  call  DX
PRIM EX
  xchg  SI,[BP]
  NEXT

PRIM strskIp
  call  @_STKR
  MOV   BX,Si
  mov   AL,[SI]
  ADD   AX,SI
  OR    AL,1
  INC   AX
  XCHG  AX,Si
  RET

PRIM RLDP
  call  @_STKR
  LODSW
  XCHG  AX,bx
  RET

PRIM RLDPB
  call  @_STKR
  LODSB
  XCHG  AX,bx
  RET

PRIM RSTP
  call  @_STKW
  mov   [SI],AX
  LODSW
  RET

PRIM RSTPB
  call  @_STKW
  mov   [SI],AL
  INC   SI
  RET

col nz?
  dw  _zeq
col Z?
  dw  _strskIp     ;    bpnt "error?"
  dw  _SWAP,_IF,@_xplus,_errv,_ABORT
	
col xtok?
  dw  _EX,_NZ?
  ANAME "ID?"
  DW  _EXIT

;=================================================
; TYPE ID

COL XEMIT
  DW _DOES1,_FETCH,_EMIT,_EXIT

COL ?err
  DW _RES,_IDSP
COL IDSP
  DW _TRAP,_SPC
COL ID
  DW _COUNT
COL TYPE
  DW _FOR,@@2
@@1: DW _COUNT,_EMIT
@@2: DW _NEXT,@@1,_DROPX

COL PRT
  DW _strskIp,_ID,_EXIT

;-------------------------------------------
; MEM IO

;PRIM MEMK
;  mov   DI,OFFSET @_FINAL
;COL MEMK
;  DW _XMEM,_ZSKIP,_EXIT,_ZERO,_LIT,_DK,TO_KEY,_EXIT
;COL STDIO
;@_STDIO:
;  DW __STD
;COL SETIO
;  DW TO_KEY,TO_EMIT,_EXIT
;
;XT _STD,_DCONST
;  DW _DK,_dE
;
;COL SET_IO
;  DW _POP,_Dfetch,_SETIO,_EXIT
;
;XT BIO,_SET_IO
;  DW _BK,_BE
;
;===========================================

@_freemem:
  dw @_final-@_freemem-2
  
  aname '=:'
  dw _header,0
  db 0
  
@_FINAL = $
  
MyCseg  ends
        end  @_Start

