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
@_c@:	
@peek:	
	mov   bH,[bx]
@_HIbyte:
	mov   BL,bh
@_lobyte:
	mov   bh,0
  NEXT

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

@DUP_:
  push  BX
  SKIPA
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

VARIABLE 'STATE',STATE,0

VARIABLE 'ETIB',ETIB,0
VARIABLE 'LTIB',LTIB,0
CONSTANT 'TIB',TIB,80h


VARIABLE 'DP',DP,FREEMEM

VARIABLE 'BASE',BASE,10

VARIABLE 'LAST',LAST,FINAL
VARIABLE 'LASTVOC',LASTVOC,@LASTVOC

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

xtname 'FORTH',FORTH,@SETLAST
  DW FINAL,0
@FORTH:
  
xtname 'COMPILER',COMPILER,@SETLAST
  DW @COMPILER,@FORTH
@LASTVOC:

@SETLAST:
  mov   VAL_LAST,DI
  NEXT

xtname ',',COMMA,@USEBX_
  MOV DI,PW [VAL_DP]
  STOSW
  MOV PW [VAL_DP],DI
  RET

PRIMITIVE 'LIT',LIT
  LODSW
  JMP  @_Ph

; -------------------
; MATHS / LOGIC
; -------------------

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

; -------------------
; PEEK AND POKE
; -------------------

xtname 'C@',CFETCH,@peek

xtname 'C!',CSTORE,@DROP2_
  STOSB
  RET

PRIMITIVE 'D@',FETCH2
  PUSH  PW [BX+2]
@FETCH:
  MOV BX,PW [BX]
  NEXT

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

COLON 'OFF',OFF                
  DW _ZERO,_SWPSTORE,_EXIT

COLON 'ON',ON                
  DW _MONE,_SWPSTORE,_EXIT


xtname '("+', STRSKIP,@_RSLD_	  ; string skip
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

  SCASW
  SCASW
DODOES:
  POP   AX
  XCHG  AX,DI
  RPUSH  SI
  MOV   SI,DI
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

; -------------------
; STACK
; -------------------

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
  JMPS  @_sw

PRIMITIVE 'ROT',ROTE    ; AX DX BX  - DX BX AX
  POP DX AX
  PUSH DX
  JMPS  @_Ph

xtname 'DROP',DROP,@DROP

xtname 'DUP',DUPE,@DUP_
  RET

xtname 'SWAP',SWAP,@SWAP_
  RET

; -----------------------
; COLON DEFINITION
; -----------------------

  COLON ':',COLON
  DW _STATE,_ON,_CREATE,_DO_SEMI_CODE
@NOP:
  SKIPB
  DB    1
DOCOLON:
  XCHG  SI,DI
@RPUSH:
  DEC   BP
  DEC   BP
  MOV   PW [BP],DI
  NEXT

PRIM FOR
  MOV   SI,[SI]
@PUSH:
  pop   DI
  XCHG  BX,DI
  JMPS  @RPUSH

@EVAL:
  POP   AX
  ADD   AX,BX
  MOV   VAL_ETIB,AX
  MOV   VAL_LTIB,BX
  pop   BX
  JMPS  DOCOLON

@COMPILER:
COLONI ';',SEMICOLON                ;,IMMEDIATE
  DW _COMPILE,_EXIT,_STATE,_OFF,_EXIT

COLON 'COMPILE',COMPILE
  DW _RLDP,_COMMA,_EXIT

; -------------------
; FLOW CONTROL
; -------------------

PRIM NEXT
  DEC   PW [BP]
  JNS   @BR
  LODSW
  JMP   @RDROP

xtname '0BR',ZERO_BRANCH,@DROP1_
  LODSW
  TEST DI,DI
  JNE ZEROB_Z
  XCHG AX,SI
ZEROB_Z:
  RET 

PRIMITIVE 'BR',BRANCH
@BR:
  MOV SI,PW [SI]
  NEXT
  
PRIMITIVE 'EXEC',EXEC
  MOV DI,BX
  SCASW
  POP BX
  JMP PW [DI-2]
  
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
  CMP AL,'A'
  JC TO_NUMS
  SUB AL,32
TO_NUMS: 
  CMP AL,'9'+1
  JC TO_NUMG
  AND AL,0DFH
  CMP AL,'A'
  JC TO_NUMH
  SUB AL,7
TO_NUMG:
  SUB AL,48
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

xtname 'EMIT',EMIT,@USEBX_
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

xtname 'KEY',KEY,@PUSHAX_
GETCHAR: 
  MOV AH,7
  INT 021H
  MOV AH,0
  RET

PRIMITIVE 'ACCEPT',ACCEPT
  POP   DI
  PUSH  DI
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
  POP   AX
  NEXT

; -----------------------
; DICTIONARY SEARCH
; -----------------------

PRIMITIVE 'FIND',FIND
  MOV DI,VAL_LAST
FINDL:
  PUSH DI
  PUSH BX
  MOV CL,PB[BX]
  MOV CH,0
  INC CX
FINDC:
  MOV AL,PB[DI+2]
  AND AL,07FH
  CMP AL,PB[BX]
  JE FINDM
  POP BX
  POP DI
  MOV DI,PW [DI]
  TEST DI,DI
  JNE FINDL
FINDNF:
  PUSH BX
  XOR BX,BX
  NEXT
FINDM:
  INC DI
  INC BX
  LOOP FINDC
  POP BX
  POP DI
  MOV BX,1
  INC DI
  INC DI
  MOV AL,PB[DI]
  TEST AL,080H
  JNE FINDI
  NEG BX
FINDI:
  AND AX,31
  ADD DI,AX
  INC DI
  PUSH DI     ; CFA
  NEXT

; -----------------------
; HEADERS
; -----------------------

COLON 'CREATE',CREATE
  DW _DP,_FETCH,_LAST,_FETCH,_COMMA,_LAST,_STORE,_BLWORD,_COUNT
  DW _PLUS,_DP,_STORE,_ZERO,_COMMA,_DO_SEMI_CODE
DOVAR:
  PUSH BX
  MOV  BX,DI
  NEXT

PRIMITIVE '(;CODE)',DO_SEMI_CODE
  MOV DI,PW [VAL_LAST]
  MOV AL,PB[DI+2]
  AND AX,31
  ADD DI,AX
  MOV PW [DI+3],SI
@exit:
  MOV SI,PW [BP]
@RDROP:
  INC BP
  INC BP
  NEXT

; -----------------------
; CONSTANTS
; -----------------------

FINAL:

COLON 'CONSTANT',CONSTANT
  DW _CREATE,_COMMA,_DO_SEMI_CODE
DOCONST:
  PUSH BX
  MOV BX,[DI]
  NEXT

; -----------------------
; OUTER INTERPRETER
; -----------------------

@COLD:
  mov   bx,1000h     ; only 64k allocate
  mov   ah,4ah
  int   21h
restart:
  CLD
  MOV AX,PW [VAL_LTIB]
  MOV PW [VAL_ETIB],AX
  XOR BP,BP
  MOV PW [VAL_STATE],BP
  MOV SP,-256
  Goforth

INTERPT DW  _GETLINE,_EVAL,_CR,_BRANCH,INTERPT

XT EVAL,@EVAL
INTPAR  DW _BLWORD
;        DW _DUMPSTR
        DW _DUPE,_CFETCH,_ZERO_BRANCH,@DROPX

        DW _FIND,_DUPE				          ;   BL WORD FIND DUP      \ FOUND ?
        DW _ZERO_BRANCH,INTNF,_STATE,_FETCH			  ;   IF STATE @            \ COMPILATION ?
        DW _EQUALS,_ZERO_BRANCH,INTEXC	          ;	    = IF    	            \ YES
        DW _COMMA,_BRANCH,INTDONE                 ;       ,  ELSE 
INTEXC  DW _EXEC,_BRANCH,INTDONE						      ;     EXEC ELSE
INTNF   DW _DUPE,_ROTE,_COUNT,_TO_NUMBER			    ;     DUP ROT COUNT >NUM  \ NUMBER
        DW _ZERO_BRANCH,INTSKIP,_STATE,_FETCH			;     IF STATE @  
        DW _ZERO_BRANCH,INTNC,_LAST,_FETCH,_DUPE	;       IF LAST @ DUP
        DW _FETCH,_LAST,_STORE,_DP,_STORE			    ;          @ LAST ! DP !
INTNC   DW _ABORT											            ;       THEN ABORT  THEN  
INTSKIP DW _DROP, _DROP, _STATE, _FETCH				    ;     DROP DROP STATE @
        DW _ZERO_BRANCH,INTDONE,_COMPILE,_LIT	    ;     IF LIT LIT , ,
        DW _COMMA                                 ;   THEN  THEN THEN
INTDONE DW _BRANCH,INTPAR								        ; AGAIN

XT TYPE,DOCOLON
  DW _FOR,@TP2
@TP1  DW _COUNT,_EMIT
@TP2  DW _NEXT,@TP1
@DROPX: DW _DROP,_EXIT

XT GETLINE,DOCOLON
  DW _TIB,_LIT,50,_ACCEPT,_BL_,_EMIT,_EXIT 
        
XT DUMPSTR,DOCOLON
  DW _CR,_DUPE,_COUNT,_TYPE,_BL_,_EMIT,_EXIT

@_lary:
	shl   bx,1
@_wary:
	shl   bx,1
@_bary:
	add   bx,di
	NEXT

FREEMEM:

MYCSEG  ENDS
        END  START

