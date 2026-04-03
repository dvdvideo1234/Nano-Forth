INCLUDE ITSMY.MAC

MYCSEG  SEGMENT PARA  USE16

        ASSUME CS: MYCSEG,  DS: MYCSEG, SS: MYCSEG, ES: MYCSEG
 
        ORG 0100H
		
START   LABEL BYTE

        JMP @COLD

; -------------------
; VARIABLES
; -------------------

        VARIABLE 'STATE',STATE,0

        VARIABLE '>IN',TO_IN,0

        VARIABLE '#TIB',NUMBER_T_I_B,0

        VARIABLE 'DP',DP,FREEMEM

        VARIABLE 'BASE',BASE,10

        VARIABLE 'LAST',LAST,FINAL

        CONSTANT 'TIB',T_I_B,32768

        CONSTANT '0',ZERO,0
@BYE = $-2

        CONSTANT 'BL',SPC,32

; -------------------
; INITIALISATION
; -------------------

        xtname 'ABORT',ABORT,restart

; -------------------
; COMPILATION
; -------------------

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
@ZEQ:   SUB BX,1
        SBB BX,BX
        RET

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

        xtname '+!',PSTORE,@DROP2_
        ADD   PW [DI],AX
        RET

; -------------------
; INNER INTERPRETER
; -------------------

@to4th: 
  pop  si
@MAIN:  
  MOV DI,[SI]
  CMPSW
  JMP PW [DI-2]

@NIP_:
  POP   AX
@NOP_:
  CALL  DI
  NEXT

; -----------------------
; COLON DEFINITION
; -----------------------

        COLON ':',COLON
        DW _LIT,-1,_STATE,_STORE,_CREATE
        DW _DO_SEMI_CODE
DOCOLON:DEC BP
        DEC BP
        MOV PW [BP],SI
        MOV  SI,DI
        NEXT

        COLONI ';',SEMICOLON                ;,IMMEDIATE
        DW _LIT,_EXIT,_COMMA,_ZERO,_STATE
        DW _STORE,_EXIT

; -------------------
; STACK
; -------------------


        PRIMITIVE 'ROT',ROTE
        POP DX
        POP AX
        PUSH DX
@_Ph:
        PUSH BX
@_sw:
        XCHG AX,BX
        NEXT

@USEBX_:
        XCHG  AX,BX
        SKIPB
@DROP2_:
        POP   AX
@DROP1_:
        XCHG  BX,DI
        CALL  BX
@DROP:
        POP BX
        NEXT

        xtname 'DROP',DROP,@DROP

        PRIMITIVE 'DUP',DUPE
        PUSH BX
        NEXT

        PRIMITIVE 'SWAP',SWAP
        POP AX
        JMPS @_Ph

; -------------------
; FLOW CONTROL
; -------------------

        xtname '0BRANCH',ZERO_BRANCH,@DROP1_
        LODSW
        TEST DI,DI
        JNE ZEROB_Z
        XCHG AX,SI
ZEROB_Z:RET 

        PRIMITIVE 'BRANCH',BRANCH
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

        PRIMITIVE 'COUNT',COUNT
        INC BX
        PUSH BX
        DEC bx
@peek:  MOV BL,PB[BX]
        MOV BH,0
        NEXT

        PRIMITIVE '>NUMBER',TO_NUMBER
        POP DI
        POP CX
        POP AX
TO_NUML: TEST BX,BX
        JE TO_NUMZ
        PUSH AX
        MOV AL,PB[DI]
        CMP AL,'A'
        JC TO_NUMS
        SUB AL,32
TO_NUMS: CMP AL,'9'+1
        JC TO_NUMG
        AND AL,0DFH
        CMP AL,'A'
        JC TO_NUMH
        SUB AL,7
TO_NUMG: SUB AL,48
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
TO_NUMZ: PUSH AX
TO_NUMH: PUSH CX
        PUSH DI
        NEXT

; -----------------------
; TERMINAL INPUT / OUTPUT
; -----------------------

        PRIMITIVE 'ACCEPT',ACCEPT
        POP DI
        XOR CX,CX
ACCEPTL: CALL GETCHAR
        CMP AL,8
        JNE ACCEPTN
        JCXZ ACCEPTB
        CALL OUTCHAR
        MOV AL,' '
        CALL OUTCHAR
        MOV AL,8
        CALL OUTCHAR
        DEC CX
        DEC DI
        JMP ACCEPTL
ACCEPTN: CMP AL,13
        JE ACCEPTZ
        CMP CX,BX
        JNE ACCEPTS
ACCEPTB: MOV AL,7
        CALL OUTCHAR
        JMP ACCEPTL
ACCEPTS: STOSB
        INC CX
        CALL OUTCHAR
        JMP ACCEPTL
ACCEPTZ: JCXZ ACCEPTB
        MOV BX,CX
        NEXT

        PRIMITIVE 'WORD',WORD
        MOV DI,PW [VAL_DP]
        PUSH DI
        MOV DX,BX
        MOV BX,PW [VAL_T_I_B]
        MOV CX,BX
        ADD BX,PW [VAL_TO_IN]
        ADD CX,PW [VAL_NUMBER_T_I_B]
WORDF:  CMP CX,BX
        JE WORDZ
        MOV AL,PB[BX]
        INC BX
        CMP AL,DL
        JE WORDF
WORDC:  INC DI
        MOV PB[DI],AL
        CMP CX,BX
        JE WORDZ
        MOV AL,PB[BX]
        INC BX
        CMP AL,DL
        JNE WORDC
WORDZ:  MOV PB [DI+1],32
        MOV AX,PW [VAL_DP]
        XCHG AX,DI
        SUB AX,DI
        MOV PB[DI],AL
        SUB BX,PW [VAL_T_I_B]
        MOV PW [VAL_TO_IN],BX
        POP BX
        NEXT

        xtname 'EMIT',EMIT,@USEBX_
OUTCHAR:XCHG AX,DX
        MOV AH,2
        INT 021H
        RET

        xtname 'CR',CR,@NOP_
        MOV AL,13
        CALL OUTCHAR
        MOV AL,10
        JMPS OUTCHAR

GETCHAR: MOV AH,7
        INT 021H
        MOV AH,0
        RET

; -----------------------
; DICTIONARY SEARCH
; -----------------------

        PRIMITIVE 'FIND',FIND
        MOV DI,VAL_LAST
FINDL:  PUSH DI
        PUSH BX
        MOV CL,PB[BX]
        MOV CH,0
        INC CX
FINDC:  MOV AL,PB[DI+2]
        AND AL,07FH
        CMP AL,PB[BX]
        JE FINDM
        POP BX
        POP DI
        MOV DI,PW [DI]
        TEST DI,DI
        JNE FINDL
FINDNF: PUSH BX
        XOR BX,BX
        NEXT
FINDM:  INC DI
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
FINDI:  AND AX,31
        ADD DI,AX
        INC DI
        PUSH DI     ; CFA
        NEXT

; -----------------------
; HEADERS
; -----------------------

        COLON 'CREATE',CREATE
        DW _DP,_FETCH,_LAST,_FETCH,_COMMA
        DW _LAST,_STORE,_SPC,_WORD,_COUNT
        DW _PLUS,_DP,_STORE,_ZERO,_COMMA
        DW _DO_SEMI_CODE
DOVAR:  PUSH BX
        MOV  BX,DI
        NEXT

        PRIMITIVE '(;CODE)',DO_SEMI_CODE
        MOV DI,PW [VAL_LAST]
        MOV AL,PB[DI+2]
        AND AX,31
        ADD DI,AX
        MOV PW [DI+3],SI
@exit:  MOV SI,PW [BP]
@RDROP: INC BP
        INC BP
        NEXT

; -----------------------
; CONSTANTS
; -----------------------

FINAL:
        COLON 'CONSTANT',CONSTANT
        DW _CREATE,_COMMA,_DO_SEMI_CODE
DOCONST:PUSH BX
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
  MOV AX,PW [VAL_NUMBER_T_I_B]
  MOV PW [VAL_TO_IN],AX
  XOR BP,BP
  MOV PW [VAL_STATE],BP
  MOV SP,-256
  Goforth

INTERPT DW _NUMBER_T_I_B,_FETCH,_TO_IN,_FETCH	    ; BEGIN  CR  #TIB @ >IN @ 
        DW _EQUALS,_ZERO_BRANCH,INTPAR,_CR,_T_I_B	;   = IF CR TIB		          \ IF EMPTY
        DW _LIT,50,_ACCEPT,_NUMBER_T_I_B,_STORE		;     50 ACCEPT #TIB !  
        DW _ZERO,_TO_IN,_STORE,_SPC,_EMIT	        ;     0 >IN ! CR  THEN    \ FULL BUF
INTPAR  DW _SPC,_WORD,_FIND,_DUPE				          ;   BL WORD FIND DUP      \ FOUND ?
        DW _ZERO_BRANCH,INTNF,_STATE,_FETCH			  ;   IF STATE @            \ COMPILATION ?
        DW _EQUALS,_ZERO_BRANCH,INTEXC;,_FETCH		;	    = IF    	            \ YES
        DW _COMMA,_BRANCH,INTDONE                 ;       ,  ELSE 
INTEXC  DW _EXEC,_BRANCH,INTDONE						      ;     EXEC ELSE
INTNF   DW _DUPE,_ROTE,_COUNT,_TO_NUMBER			    ;     DUP ROT COUNT >NUM  \ NUMBER
        DW _ZERO_BRANCH,INTSKIP,_STATE,_FETCH			;     IF STATE @  
        DW _ZERO_BRANCH,INTNC,_LAST,_FETCH,_DUPE	;       IF LAST @ DUP
        DW _FETCH,_LAST,_STORE,_DP,_STORE			    ;          @ LAST ! DP !
INTNC   DW _ABORT											            ;       THEN ABORT  THEN  
INTSKIP DW _DROP, _DROP, _STATE, _FETCH				    ;     DROP DROP STATE @
        DW _ZERO_BRANCH,INTDONE,_LIT,_LIT,_COMMA	;     IF LIT LIT , ,
        DW _COMMA                                 ;   THEN  THEN THEN
INTDONE DW _BRANCH,INTERPT								        ; AGAIN

FREEMEM:

MYCSEG  ENDS
        END  START


