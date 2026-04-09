INCLUDE ITSMY.MAC

MYCSEG  SEGMENT PARA  USE16

        ASSUME CS: MYCSEG,  DS: MYCSEG, SS: MYCSEG, ES: MYCSEG
 
        ORG 0100H
		
START   LABEL BYTE

        JMP @COLD

; -----------------------

PRIMITIVE 'ACCDOS',ACCDOS
;PRIMITIVE 'ACCEPT',ACCEPT
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
  JMPS  @_C@

@_DC@:
  push  BX
@_c@:	
	mov   bH,[bx]
@_HIbyte:
	mov   BL,bh
@_lobyte:
	mov   bh,0
  JMPS  @MAIN1

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
  NEXT

@NIP2_:
  POP   CX
@NIP_:
  POP   AX
@NOP_:
  CALL  DI
@MAIN1:
  NEXT

; -------------------
; VARIABLES
; -------------------

DEFERNI   'EMIT',EMIT,_DE
DEFERN    'KEY',KEY,_DK
DEFERN    'ERR',ERR,_ERR1
DEFERN    'ACCEPT',ACCEPT,_DACPT

XTNAME   'FOUND',FOUND,@FOUND
XT SETMODE,@SETMODE
;VAL_FOUND
 DW 0


VARIABLE 'ETIB',ETIB,0
VARIABLE 'LTIB',LTIB,0
CONSTANT 'TIB',TIB,80h


VARIABLE 'DP',DP,FREEMEM
VARIABLE 'CNTC',CNTC,0

VARIABLE 'BASE',BASE,10

VARIABLE 'LAST',LAST,FINAL

CONSTANT '0',ZERO,0
CONSTANT '-1',MONE,-1
CONSTANT 'BL',BL_,32

; -------------------
; INITIALISATION
; -------------------

        xtname 'ABORT',ABORT,restart

; -------------------
; COMPILATION
; -------------------

@P2:
  INC BX
@P1:
  INC BX
  NEXT
@SETLAST:
  SCASW
  mov   VAL_LAST,di
  SKIPA
@M2:
  DEC BX
@M1:
  DEC BX
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

COLON 'NUM',NUM
  DW _ZSWAP,_ZSWAP,_COUNT,_TO_NUMBER,_NIP2
XT CHKERR,DOCOLON
  DW _ERR?
  MSG '?'
@EXNUM DW _EXIT

XT NULSTR?,DOCOLON
  DW _BLWORD
XT Z@ADR?,DOCOLON
  DW _DC@
XT ZERR?,DOCOLON
  DW _ZEQ,_CHKERR,_EXIT;

XT ERR?,DOCOLON
  DW _SKIPSTR,_SWAP
  DW _ZERO_BRANCH,@DROPX  ; DROPX
  DW _ERR,_ABORT

XTNAME 'ERR.',ERR1,DOCOLON
  DW _CR,_DP,_FETCH,_P2,_IDOT,_IDOT,_EXIT

COLON 'NUMC',NUMC
  DW _NUM,_COMPILE,_LIT,_COMMA,_EXIT

xtname ',',COMMA,@USEBX_
  MOV DI,PW [VAL_DP]
  STOSB
  mov   AL,AH
@_COMMA:
  STOSB
  MOV PW [VAL_DP],DI
  RET

xtname 'C,',BCOMMA,@USEBX_
  MOV DI,PW [VAL_DP]
  JMPS  @_COMMA

PRIMITIVE 'LIT',LIT
  LODSW
  pushREG

COLON '''ADR',TICKADR
  DW _NULSTR?,_FOUND,_ZERR?,_FETCH,_EXIT

COLON '''',TICK
  DW _TICKADR,_FETCH,_EXIT

; -------------------
; MATHS / LOGIC
; -------------------

xtname '1+',P1,@P1
xtname '2+',P2,@P2
xtname '1-',M1,@M1
xtname '2-',M2,@M2

xtname 'AND',AND,@NIP_
  AND BX,AX
  RET

xtname 'XOR',XOR,@NIP_
  XOR BX,AX
  RET

xtname '+',PLUS,@NIP_
  ADD BX,AX
  RET

xtname '-',MINUS,@NIP_
  SUB AX,BX
  XCHG BX,AX
  RET

xtname '=',EQUALS,@NIP_
  SUB BX,AX
  JMPS  @ZEQ

xtname '0=',ZEQ,@NOP_
@ZEQ: 
  SUB BX,1
@CARRY:
  SBB BX,BX
  RET

xtname '0<',ZLESS,@NOP_
  shl   BX,1
  JMPS  @CARRY

xtname 'U<',ULESS,@NIP_
  SUB AX,BX
  JMPS  @CARRY

; -------------------
; PEEK AND POKE
; -------------------

xtname 'DC@',DC@,@_DC@

xtname 'C@',CFETCH,@_C@

xtname 'C!',CSTORE,@DROP2_
  STOSB
  RET

PRIMITIVE 'D@',FETCH2
  PUSH  PW [BX+2]
@FETCH:
  MOV BX,PW [BX]
  NEXT

xtname 'D!',2STORE,@DROP3_
  XCHG  AX,CX
  STOSW
  XCHG  AX,CX
  STOSW
  RET

xtname '@',FETCH,@FETCH

xtname '!',STORE,@DROP2_
  STOSW
  RET

xtname 'SWAP!',SWPSTORE,@DROP2_
  XCHG  AX,DI
  STOSW
  RET

xtname '+!',PSTORE,@DROP2_
  ADD   PW [DI],AX
  RET

;COLON 'OFF',OFF                
;  DW _ZERO,_SWPSTORE,_EXIT
;
;COLON 'ON',ON                
;  DW _MONE,_SWPSTORE,_EXIT
;

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
@exec@:
  mov bx,[bx]
@exec:
  mov di,bx
  scasw
  pop bx
	jmps @MAINZ

XTNAME '@EXEC',PERFORM,@EXEC@

@_Ph:
  PUSH BX
@_sw:
  XCHG AX,BX

@MAIN:  
  MOV DI,[SI]
  CMPSW
@MAINZ:
  JMP PW [DI-2]

@SUB4th: 
  RPUSH  SI
@to4th: 
  pop  si
  NEXT

@FROM4TH:
  JMP   SI

  SCASW
  SCASW
DOCONST:
  MOV   AX,[DI]
  PUSHREG

DOCOLON:
@NOP:
  SKIPB
  DB    1
@PCPUSH:
  XCHG  AX,DI
@SETPCPH:
  XCHG  SI,AX
@RPUSH:
  X
  PUSH AX
  X
  NEXT

  SCASW
  SCASW
@DOES:
  POP   AX
  push  BX
  MOV  BX,DI
  JMPS  @SETPCPH

@FOUND:
  mov   AX,[DI+2];VAL_FOUND
  JMPS  @SETPCPH

PRIM FOR
  MOV   SI,[SI]
@PUSH:
  pop   AX
  XCHG  BX,AX
  JMPS  @RPUSH

@EVAL:
  POP   AX
  ADD   AX,BX
  MOV   VAL_ETIB,AX
  MOV   VAL_LTIB,BX
  pop   BX
  JMPS  @PCPUSH

; -------------------
; STACK
; -------------------

XTNAME 'PUSH',PUSH,@PUSH    

XTNAME 'POP',POP,$+2
  push  BX
  RPOP BX
  NEXT

@TESTJMP:
  OR  BX,BX
  JMP di

@NUP3_:  
	POP	  DX
@NUP2_:  
	POP	  CX
@NUP1_:  
	POP   AX
@NUP_:   
	CALL  DI
@phax:	
	PUSH  AX
	NEXT
		
@SWAP3_:
  POP DX
@SWAP2_:
  POP CX
@SWAP_:
  POP AX
@PUSHAX_:
  CALL  DI
  JMPS  @_Ph

@DROP4_:
  POP   DX
@DROP3_:
  POP   CX
@DROP2_:
  POP   AX
@DROP1_:
  XCHG  BX,DI
  CALL  BX
@DROP:
  POP BX
  NEXT

@USEBX_:
  XCHG  AX,BX
  JMPS  @DROP1_

PRIMITIVE '-ROT',MROT  ; DX AX BX  - BX DX AX  ; BX DX AX
  POP AX DX
  PUSH BX DX
  SWAPREG

PRIMITIVE 'OVER',OVER  ;
  POP AX 
  PUSH AX 
  SWAPREG

PRIMITIVE 'ROT',ROTE    ; AX DX BX  - DX BX AX
  POP DX AX
  PUSH DX
  PUSHREG

xtname 'DROP',DROP,@DROP

xtname 'DUP',DUPE,$+2
  MOV   AX,BX
  JMPS  @phax

xtname 'SWAP',SWAP,@SWAP_
  RET

xtname '2NIP',NIP2,@NIP2_
  RET

xtname '0SWAP',ZSWAP,@NUP_
  XOR   AX,AX
  RET

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
  DW _RLDP
DOCOMMA:
  DW _COMMA,_EXIT

; -------------------
; FLOW CONTROL
; -------------------

PRIM NEXT
  DEC   PW [BP]
  JNS   @BR
  LODSW
  JMP   @RDROP

xtname '0BR',ZERO_BRANCH,@TESTJMP
  POP   BX
  JNE   @SKIP
@BR:
  MOV SI,PW [SI]
  NEXT

xtname '-IF',MIF,@TESTJMP
  JS   @SKIP
  JMPS  @BR

xtname 'BR',BRANCH,@BR
  
XT ZSKIP,@TESTJMP
  JNE @ZSKIP
  POP   BX
@SKIP:
  LODSW
@ZSKIP:  NEXT  

xtname 'EXEC',EXEC,@EXEC

xtname 'EXIT',EXIT,@exit
  
xtname 'BYE',BYE,0

; -------------------
; STRING
; -------------------

PRIMITIVE '>NUMBER',TO_NUMBER
  POP DI
  POP CX
  POP AX
TO_NUML: 
  TEST BX,BX
  JE TO_NUMZ
  PUSH AX
  MOV AL,PB[DI]
  cmp   al,'9'+1
  jc    @@ton2
  and   AL,0DFH
  cmp   al,'A'      ; no case sensivity
  jc    TO_NUMH
  sub   al,7
@@ton2:
  sub   al,'0'
  MOV AH,0
  CMP AL,PB [VAL_BASE]
  JNC TO_NUMH
  XCHG AX,DX
  POP AX
  PUSH DX
  XCHG AX,CX
  MUL PW [VAL_BASE]
  XCHG AX,CX
  MUL PW [VAL_BASE]
  ADD CX,DX
  POP DX
  ADD AX,DX
  DEC BX
  INC DI
  JMP TO_NUML
TO_NUMZ: 
  
  PUSH AX
TO_NUMH:
  PUSH CX
  PUSH DI
  NEXT


; -----------------------
; TERMINAL INPUT / OUTPUT
xtname 'COUNT',COUNT,@_count

xtname 'WORD',WORD,@WORD
xtname 'BLWORD',BLWORD,@BLWORD
@BLWORD:
  push  BX
  mov   BL,32
@WORD:
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
  XCHG  DX,DI
  SUB   DX,DI  
  POP   BX        ; RESTORE ADDRESS
  MOV   PB[BX],DL ; SET COUNT
  NEXT

xtname '(DE',DE,@USEBX_
OUTCHAR:
  XCHG AX,DX
  MOV AH,2
  INT 021H
  RET

xtname 'CR',CR,@NOP_
  MOV AL,13
  CALL OUTCHAR
  MOV AL,10
  JMPS OUTCHAR

xtname 'DK',DK,@PUSHAX_
GETCHAR: 
  MOV AH,7
  INT 021H
  MOV AH,0
  RET

xt DACPT,@NUP1_
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

xtname 'FIND',FIND,@NUP1_
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

PRIMITIVE '(;CODE)',DO_SEMI_CODE
  call  @LASTCFA
  MOV   PW [DI],SI
  JMPS  @EXIT

@LASTCFA:
  MOV   DI,PW [VAL_LAST]
@NEXTCFA:
  mov   DI,[DI]
  mov   DX,DI
  SCASW
  MOV   AL,PB[DI]
  INC   DI
  MOV   AH,0
  ADD   DI,AX
  RET

@SETMODE:
  mov   [DI],SI
@exit:
  MOV SI,PW [BP]
@RDROP:
  INC BP
  INC BP
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
INTERPT DW  _GETLINE,_EVAL,_CR,_BRANCH,INTERPT

XT OPERATIONS, @_WARY
  DW _NUM,_EXEC,_NUMC,_COMMA

@_lary:
	shl   bx,1
@_wary:
	shl   bx,1
@_bary:
	add   bx,di
	NEXT

XTNAME 'EVAL',EVAL,@EVAL
@_EVAL  DW _BLWORD,_DC@,_ZERO_BRANCH,@DROPX
  DW _FOUND,_OPERATIONS,_PERFORM,_BRANCH,@_EVAL	

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
@DROPX: DW _DROP,_EXIT

XT GETLINE,DOCOLON
  DW _TIB,_LIT,50,_ACCEPT,_SPC,_EXIT 
        
XT DUMPSTR,DOCOLON
  DW _CR,_DUPE
XT IDOT,DOCOLON
  DW _COUNT
XT TYPEBL,DOCOLON
  DW _TYPE
XT SPC,DOCOLON
  DW _BL_,_EMIT,_EXIT

XT DIVMOD,@NUP1_
  XOR DX,DX
@DM2:
  DIV BX
  XCHG  AX,DX
  mov   BX,DX
  RET

XT TC,@NOP_
  XCHG BX,AX
  CMP AL,10
  JB  @LESS10
  ADD AL,7
@LESS10:
  ADD AL,48
  XCHG BX,AX
  RET

XT DIVMOD2,@NUP2_
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


