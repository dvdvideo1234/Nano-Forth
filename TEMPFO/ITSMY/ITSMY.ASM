INCLUDE ITSMY.MAC

MYCSEG  SEGMENT PARA  USE16

        ASSUME CS: MYCSEG,  DS: MYCSEG, SS: MYCSEG, ES: MYCSEG
 
        ORG 0100H
		
START   LABEL BYTE

        JMP @COLD

; -----------------------

;PRIMITIVE 'ACCDOS',ACCDOS
PRIM ACCDOS
  POP   AX
  mov   DX,AX
  XCHG  BX,AX
	mov   [BX],AX
	mov   ah,10
	INT   21h
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
  NEXT

@_LDM:
  PUSH [BX-2]
  JMPS @_M2
@_STM:
  POP [BX-2]
@_M2:
  DEC BX
@_M1:
  DEC BX
  NEXT

@_NIP:
  POP   AX
@_NOP:
  CALL  DI
  NEXT

@_POPSTX:
  RPOP  DI
  mov   [DI],BX
@_DROPX:
  POP   BX
@_exit:
  MOV SI,PW [BP]
@_RDROP:
  INC BP
  INC BP
@_MAIN1:
  NEXT
@_SETMODE:
  mov   [DI],SI
  JMPS @_exit

@_LDP:
  push  [BX]
  SKIPA
@_STP:
  POP [BX]
@_P2:
  INC BX
@_P1:
  INC BX
  NEXT

@_@XREX:
  push  [BX]
@_XREX:
  XCHG  BX,[BP]
@_EXECUTE:
	pop	ax
	xchg ax,bx
	jmp @_SETPCPH
	
@_RSLD_:
	push  BX
	XOR		ah,ah
  SKIPA
@_RSST_:
	POP	  AX
	xchg  AX,bx
	xchg  SI,[BP]
	call  DI
@_EX:
  xchg    SI,[BP]
  NEXT

; -------------------
; VARIABLES
; -------------------

DEFERNI   'EMIT',EMIT,_DE
DEFERN    'KEY',KEY,_DK
DEFERN    'ERR',ERR,_ERR1
DEFERN    'ACCEPT',ACCEPT,_DACPT

XTNAME   'MODE',MODE,@_MODE
XT SETMODE,@_SETMODE
;VAL_MODE
 DW 0


VARIABLE 'ETIB',ETIB,0
VARIABLE 'LTIB',LTIB,0
CONSTANT 'TIB',TIB,80h


VARIABLE 'DP',DP,FREEMEM
      DW 0    ; OFFSET

VARIABLE 'CNTC',CNTC,0

VARIABLE 'BASE',BASE,10

VARIABLE 'LAST',LAST,FINAL

CONSTANT '@NAME',@NAME,0
CONSTANT '0',ZERO,0
;CONSTANT '-1',MONE,-1
CONSTANT 'BL',BL_,32

; -------------------
; INITIALISATION
; -------------------

        xtname 'ABORT',ABORT,restart

; -------------------
; COMPILATION
; -------------------

@SETLAST:
  SCASW
  mov   VAL_LAST,di
  NEXT

xtname 'FORTH',FORTH,@SETLAST   ; COMPILING TO FORTH
XT ATFORTH,DOVAR
  DW FINAL
@FORTH:
  DW 0

xtname 'COMP',COMP,@SETLAST
XT ATCOMP,DOVAR
  DW COMPILER
@COMP:
  DW @FORTH

XT NULSTR?,DOCOLON
  DW _BL_
  DW _WORD
XT Z@ADR?,DOCOLON
  DW _DUP,_C@
XT ZERR?,DOCOLON
  DW _ZEQ
XT CHKERR,DOCOLON
  DW _ERR?
  MSG '?'
  DW _EXIT


XT ERR?,DOCOLON
  DW _SKIPSTR,_SWAP
  DW _IF,@__DROPX  
  DW _ERR,_ABORT

XTNAME 'ERR.',ERR1,DOCOLON
  DW _CR,_DP,_FETCH,_P2,_IDOT,_IDOT,_EXIT

COLON 'NUMC',NUMC
  DW _NUM,_COMPILE,_LIT,_COMMA,_EXIT

xtname ',',COMMA,@COMPBX_
  STOSW
  RET

xtname 'C,',BCOMMA,@COMPBX_
  STOSB
  RET

COLON '''ADR',TICKADR
  DW _NULSTR?,_MODE,_ZERR?,_FETCH,_EXIT

COLON '''',TICK
  DW _TICKADR,_FETCH,_EXIT

; -------------------
; MATHS / LOGIC
; -------------------

xtname 'LIT',LIT,@_PUSHAX
  LODSW
  RET

xtname 'I',@R,@_PUSHAX
  mov  ax,[BP]
  RET

xtname 'J',J,@_PUSHAX
  mov  ax,[BP+2]
  RET

xtname '1+',P1,@_P1
xtname '2+',P2,@_P2
xtname '1-',M1,@_M1
xtname '2-',M2,@_M2

xtname 'AND',AND,@_NIP
  AND BX,AX
  RET

xtname 'XOR',XOR,@_NIP
  XOR BX,AX
  RET

xtname '+',PLUS,@_NIP
  ADD BX,AX
  RET

xtname '-',MINUS,@_NIP
  SUB AX,BX
  XCHG BX,AX
  RET

xtname '=',EQUALS,@_NIP
  SUB BX,AX
  JMPS  @ZEQ

xtname '0=',ZEQ,@_NOP
@ZEQ: 
  SUB BX,1
@CARRY:
  SBB BX,BX
  RET

xtname '0<',ZLESS,@_NOP
  shl   BX,1
  JMPS  @CARRY

xtname 'U<',ULESS,@_NIP
  SUB AX,BX
  JMPS  @CARRY

; -------------------
; PEEK AND POKE
; -------------------

xtname 'C@',C@,@_C@

xtname 'C!',CSTORE,@_DROP2_
  STOSB
  RET

PRIMITIVE 'D@',FETCH2
  PUSH  PW [BX+2]
@FETCH:
  MOV BX,PW [BX]
  NEXT

xtname 'D!',2STORE,@_DROP3_
  XCHG  AX,CX
  STOSW
  XCHG  AX,CX
  STOSW
  RET

xtname '@',FETCH,@FETCH

xtname '!',STORE,@_DROP2_
  STOSW
  RET

xtname 'SWAP!',SWPSTORE,@_DROP2_
  XCHG  AX,DI
  STOSW
  RET

xtname '+!',PSTORE,@_DROP2_
  ADD   PW [DI],AX
  RET

xtname '("+', SKIPSTR,@_RSLD_	  ; string skip
	MOV     BX,si
	lodsb
	add		si,AX
	ret

xtname '@R+',	RLDP,@_RSLD_       ; @R+
	LODSW
	xchg    AX,bx
	RET

  xtname '!R+',RSTP,@_RSST_      ;!R+
	mov		[SI],AX
	LODSW
	RET

  xtname 'C!R+',CRSTP,@_RSST_    ;C!R+
	mov		[SI],AL
	INC		SI
	RET

  xtname 'C@R+',CRldP,@_RSLD_    ;C@R+
	LODSb
	xchg    AX,bx
	RET

xtname '@R',	RLD, @_RSLD_       ; @R
	mov		bx,[SI]
	RET

  xtname '!R',RST, @_RSST_       ;!R
	mov		[SI],AX
	RET

  xtname '@+',LDP, @_LDP         ; @+

  xtname '!+',STP, @_STP         ; !+

  xtname '@-',LDM, @_LDM         ; @-

  xtname '!-',STM, @_STM         ; !-

; -------------------
; INNER INTERPRETER
; ------------------- 

@_DEFERI:
  INC   PW [VAL_CNTC]
  SKIPA
  SCASW
  SCASW
@_defer: 
  push bx
  mov	bx,di
@_EXEC@:
  mov bx,[bx]
@_EXEC:
  mov di,bx
  scasw
  pop bx
	jmps @_MAINZ

DOCOLON:
;@_NOP:
  SKIPB
  DB    1
@_PCPUSH:
  XCHG  AX,DI
@_SETPCPH:
  XCHG  SI,AX
@_RPUSH:
  X
  PUSH AX
  X
@_MAIN:  
  MOV DI,[SI]
  CMPSW
@_MAINZ:
  JMP PW [DI-2]

@_SWAP:
  POP   AX
  SKIPA
@_PUSHAX:
  CALL  DI
@_Ph:
  PUSH BX
@_sw:
  XCHG AX,BX
  NEXT

@SUB4th: 
  RPUSH  SI
@_to4th: 
  pop  si
  NEXT

@FROM4TH:
  JMP   SI

  SCASW
  SCASW
DOCONST:
  MOV   AX,[DI]
  PUSHREG

  SCASW
  SCASW
@DOES:
  POP   AX
  push  BX
  MOV  BX,DI
  JMPS  @_SETPCPH

@_MODE:
  mov   AX,[DI+2];VAL_MODE
  JMPS  @_SETPCPH

PRIM FOR
  MOV   SI,[SI]
@_PUSH:
  pop   AX
  XCHG  BX,AX
  JMPS  @_RPUSH

@_EVAL:
  POP   AX
  ADD   AX,BX
  MOV   VAL_ETIB,AX
  MOV   VAL_LTIB,BX
  pop   BX
  JMPS  @_PCPUSH

; -------------------
; STACK
; -------------------

; : XEP XR EXECUTE POP ;
; : @XEP! @+ 2-  XR EXECUTE POP ! ;

XTNAME 'PUSH',PUSH,@_PUSH    

XTNAME 'POP',POP,$+2
  push  BX
  RPOP BX
  NEXT

@_TESTJMPM:
  dec BX
@_TESTJMP:
  OR  BX,BX
  JMP di

@_NUP3:  
	POP	  DX
@_NUP2:  
	POP	  CX
@_NUP1:  
	POP   AX
@_NUP:   
	CALL  DI
@_phax:	
	PUSH  AX
	NEXT
		
@_DROP4_:
  POP   DX
@_DROP3_:
  POP   CX
@_DROP2_:
  POP   AX
@_DROP1_:
  XCHG  BX,DI
  CALL  BX
@_DROP:
  POP BX
  NEXT

@USEBX_:
  XCHG  AX,BX
  JMPS  @_DROP1_

@COMPBX_:
  MOV   AX,PW [VAL_DP]
  XCHG  AX,BX
  XCHG  BX,DI
  call  BX
  MOV PW [VAL_DP],DI
  DROPREG

PRIMITIVE '-ROT',MROT  ; DX AX BX  - BX DX AX  ; BX DX AX
  POP AX DX
  PUSH BX DX
  SWAPREG

PRIMITIVE 'OVER',OVER  ;
  POP AX 
  PUSH AX 
  SWAPREG

PRIMITIVE 'ROT',ROT    ; AX DX BX  - DX BX AX
  POP DX AX
  PUSH DX
  PUSHREG

xtname 'DROP',DROP,@_DROP

xtname 'DUP',DUP,$+2
  push  BX
  NEXT

xtname 'SWAP',SWAP,@_SWAP

xtname '3NIP',NIP3,$+3
  POP   AX    ; NIP 4
  POP   AX    ; NIP 3
  POP   AX    ; NIP 2
  POP   AX    ; NIP 
  NEXT

XTNAME 'XR',XR,$+2
  XCHG  BX,[BP]
  NEXT

; -----------------------
; COLON DEFINITION
; -----------------------

  COLON ':',COLON
  DW _HEAD,_COMPILE,DOCOLON
XT SETCOMP,DOCOLON    ;  TO EXECUTE       ; TO COMPILE
  DW _SETMODE
  DW _ATCOMP,_FIND,_ZSKIP,_EXIT
  DW _ATFORTH,_FIND,_P2,_EXIT    ; TO EXECUTE  OR NUMBER

COLON 'COMPILE',COMPILE
  DW _RLDP,_COMMA,_EXIT

; -------------------
; FLOW CONTROL
; -------------------

xtname '(NEXT',NEXT,$+2
  DEC   PW [BP]
  JNS   @_BR
  LODSW
  JMP   @_RDROP

xtname '(0BR',IF,@_TESTJMP
  POP   BX
  JNE   @_SKIP
@_BR:
  MOV SI,PW [SI]
  NEXT

xtname '-IF',MIF,@_TESTJMP
  JS   @_SKIP
  JMPS  @_BR

xtname '(BR',JUMP,@_BR
  
XT ZSKIP,@_TESTJMP
  JNE @_ZSKIP
  POP   BX
@_SKIP:
  LODSW
@_ZSKIP:
  NEXT  

XTNAME '@EXEC',PERFORM,@_EXEC@

xtname 'EXEC',EXEC,@_EXEC

xtname 'EX',EX,@_EX

xtname 'EXIT',EXIT,@_exit
  
xtname 'DROP;',DROPX,@_DROPX

xtname 'BYE',BYE,0

XTNAME '@XREX',@XREX,@_@XREX

XTNAME 'XREX',XREX,@_XREX

XTNAME 'EXECUTE',EXECUTE,@_EXECUTE

XTNAME 'POP!;',POPSTX,@_POPSTX

; -------------------
; PARSING
; -------------------

COLON 'NUM',NUM
  DW _PUSH,_ZERO,_ZERO,_LIT,10,_POP,_COUNT
  DW _TO_NUMBER,_NIP3,_CHKERR,_EXIT

PRIMITIVE '>NUMBER',TO_NUMBER
  mov CX,BX
  POP AX BX DI DX
  PUSH BP SI  
  XCHG  AX,SI
  XOR   AX,AX
  mov   BP,DX
@_NUML: 
  JCXZ @_NUMZ
  lodsb
  dec   CX
  cmp   al,'9'+1
  jc    @@ton2
  and   AL,0DFH
  cmp   al,'A'      ; no case sensivity
  jc    @_ERR
  sub   al,7
@@ton2:
  sub   al,'0'
  CMP AX,BX; PB [VAL_BASE]
  JNC @_ERR
  XCHG AX,DI
  MUL   BX  ; PW [VAL_BASE]
  XCHG AX,DI
  XCHG AX,BP
  MUL   BX  ; PW [VAL_BASE]
  XCHG AX,BP
  ADD BP,AX
  ADC DI,DX
  JMP @_NUML
@_ERR:
  dec   SI
  INC   CX

@_NUMZ: 
  POP  AX DX
  XCHG  AX,SI
  XCHG  DX,BP

  PUSH DX DI BX AX
  mov  BX,CX
  NEXT

xtname 'COUNT',COUNT,@_count

xtname 'WORD',WORD,@_NOP
  MOV   AH,BL
  MOV   CX,PW [VAL_LTIB]
  MOV   BX,PW [VAL_ETIB]
  SUB   BX,CX
  MOV   DI,PW [VAL_DP]
  SCASW       ; SKIP LINK - SAVE SPACE FOR
  PUSH  DI    ; SAVE ADDRESS
  INC   DI    ; ROOM FOR COUNT
  MOV   DX,DI ; START ADDRESS OF CHARS
WORDF:
  JCXZ  WORDZ
  MOV   AL,PB[BX]
  INC   BX
  DEC   CX
  CMP   AL,AH
  JE    WORDF     ; SKIP TARGET
WORDC:
  STOSB
  JCXZ   WORDZ
  MOV   AL,PB[BX]
  INC   BX
  DEC   CX
  CMP   AL,AH
  JNE   WORDC
WORDZ:
  MOV   PW [VAL_LTIB],CX
  XCHG  AX,DI
  SUB   AX,DX  
  POP   BX        ; RESTORE ADDRESS
  MOV   PB[BX],AL ; SET COUNT
  RET


; -----------------------
; TERMINAL INPUT / OUTPUT
; -----------------------

xtname '(DE',DE,@USEBX_
OUTCHAR:
  XCHG AX,DX
  MOV AH,2
  INT 021H
  RET

xtname 'CR',CR,@_NOP
  MOV AL,13
  CALL OUTCHAR
  MOV AL,10
  JMPS OUTCHAR

xtname 'DK',DK,@_PUSHAX
GETCHAR: 
  MOV AH,7
  INT 021H
  MOV AH,0
  RET

xt DACPT,@_NUP1
  PUSH  AX
  XCHG  AX,DI
  XOR   CX,CX
ACCEPTL: 
  CALL  GETCHAR
  CALL  DOKEY
  JMPS  ACCEPTL

DOKEY:
  CMP   AL,8
  JNE   ACCEPTN
  JCXZ  ACCEPTB
  CALL  OUTCHAR
  MOV   AL,' '
  CALL  OUTCHAR
  MOV   AL,8
  CALL  OUTCHAR
  DEC   CX
  DEC   DI
ACCEPTB:
  RET
ACCEPTN:
  CMP   AL,13
  JE    ACCEPTZ
  CMP   AL,32
  JB    ACCEPTB

ACCEPTS: 
  STOSB
  INC   CX
  CALL  OUTCHAR
  CMP   CX,BX
  JNE   ACCEPTB
ACCEPTZ: 
  MOV   BX,CX
  POP   AX  ; DROP RETURN
  POP   AX  ; POP ADDRESS
  RET       ; EXIT TO MAIN

; -----------------------
; DICTIONARY SEARCH
; -----------------------

xtname 'FIND',FIND,@_NUP1
@FIND:
  push  SI AX 
@_FINDLP:
  mov   Cx,[BX]
  JCXZ  @_ENDF
  mov   BX,CX
  LEA   DI,[BX+2]
  mov   CH,0
  MOV   CL,PB[DI]
  INC   CX
  MOV   SI,AX
  REP   cmpsB
  JNE   @_FINDLP
  INC   CX
  XCHG  AX,DI
  mov   VAL_@NAME,BX
@_ENDF:  
  POP DI SI
  MOV BX,CX
  RET

; -----------------------
; HEADERS
; -----------------------

COLON 'HEAD',HEAD
  DW _NULSTR?
  DW _DP,_FETCH,_LAST,_FETCH,_FETCH,_COMMA,_LAST,_FETCH,_STORE
  DW _COUNT,_PLUS,_DP,_STORE
  DW _EXIT

COLON 'CREATE',CREATE
  DW _HEAD,_COMPILE,DOVAR,_EXIT

  SCASW
  SCASW
DOVAR:
  PUSH BX
  MOV  BX,DI
  NEXT


; -----------------------
; CONSTANTS
; -----------------------

COLON 'CONSTANT',CONSTANT
  DW _HEAD,_COMPILE,DOCONST,_COMMA,_EXIT

; -----------------------
; OUTER INTERPRETER
; -----------------------

@COLD:
  mov   bx,1000h     ; only 64k allocate
  mov   ah,4ah
  int   21h
restart:
  CLD
  XOR BP,BP
  ;mov VAL_LTIB,BP
  MOV SP,-256
  GoForth
  DW _INTMODE,_FORTH    ; MODE
INTERPT DW  _GETLINE,_EVAL,_CR,_JUMP,INTERPT

XT OPERATIONS, @_WARY
  DW _NUM,_EXEC,_NUMC,_COMMA

@_lary:
	shl   bx,1
@_wary:
	shl   bx,1
@_bary:
	add   bx,di
	NEXT

XTNAME 'EVAL',EVAL,@_EVAL
@__EVAL  DW _BL_,_WORD,_DUP,_C@,_IF,@__DROPX
  DW _MODE,_OPERATIONS,_PERFORM,_JUMP,@__EVAL	

;-----------------------------------------
; PRINTING ROUTINES

XT SDOT,DOCOLON
  DW _SKIPSTR
XT STYPE,DOCOLON
  DW _COUNT
XT TYPE,DOCOLON
  DW _FOR,@TP2
@TP1  DW _COUNT,_EMIT
@TP2  DW _NEXT,@TP1
@__DROPX: DW _DROPX

XT GETLINE,DOCOLON
  DW _TIB,_LIT,50,_ACCEPT,_SPC,_EXIT 
        
XT DUMPSTR,DOCOLON
  DW _CR,_DUP
XT IDOT,DOCOLON
  DW _COUNT
XT TYPEBL,DOCOLON
  DW _TYPE
XT SPC,DOCOLON
  DW _BL_,_EMIT,_EXIT

XT DIVMOD,@_NUP1
  XOR DX,DX
@DM2:
  DIV BX
  XCHG  AX,DX
  mov   BX,DX
  RET

XT TC,@_NOP
  XCHG BX,AX
  mov AH,0
  CMP AL,10
  JB  @LESS10
  ADD AL,7
@LESS10:
  ADD AL,48
  XCHG BX,AX
  RET

XT DIVMOD2,@_NUP2
  XCHG  AX,DX
  XCHG  AX,CX
  JMPS  @DM2

XT NUMDOT,DOCOLON
  DW _BASE,_FETCH,_DIVMOD,_ZSKIP,_NUMDOT,_TC,_EMIT,_EXIT
; : >CHAR ( n -- c ) 
;   DUP 10 < IF 48 + ELSE 55 + THEN ;
; DUP 9 SWAP U< 7 AND 48 + ;

FINAL:

COLON '.',NUMD
  DW _NUMDOT,_SPC,_EXIT

PPP = 0
qqq = 0


COMPILER:
COLON ';',SEMICOLON                ;,IMMEDIATE
  DW _COMPILE,_EXIT
XT INTMODE,DOCOLON
  DW _SETMODE
  DW _ATFORTH,_FIND,_EXIT    ; TO EXECUTE  OR NUMBER

FREEMEM:

MYCSEG  ENDS
        END  START


