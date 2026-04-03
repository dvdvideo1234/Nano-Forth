INCLUDE ITSMY.MAC

MYCSEG  SEGMENT PARA  USE16

        ASSUME CS: MYCSEG,  DS: MYCSEG, SS: MYCSEG, ES: MYCSEG
 
        ORG 0100H
		
START   LABEL BYTE

        JMP restart

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

; -------------------
; INITIALISATION
; -------------------

        ;PRIMITIVE 'ABORT',ABORT
        xtname 'ABORT',ABORT,restart

; -------------------
; COMPILATION
; -------------------

        ;PRIMITIVE ',',COMMA
        xtname ',',COMMA,@USEBX_
        MOV DI,PW [VAL_DP]
        ;XCHG AX,BX
        STOSW
        MOV PW [VAL_DP],DI
        RET
        ;POP BX
        ;NEXT

        PRIMITIVE 'LIT',LIT
        LODSW
        JMPS  @PUSHBX
        ;PUSH BX
        ;XCHG AX,BX
        ;NEXT

; -------------------
; STACK
; -------------------

        PRIMITIVE 'ROT',ROTE
        POP DX
        POP AX
        PUSH DX
@PUSHBX:
        PUSH BX
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
        ;PRIMITIVE 'DROP',DROP
        xtname 'DROP',DROP,@DROP

        PRIMITIVE 'DUP',DUPE
        PUSH BX
        NEXT

        PRIMITIVE 'SWAP',SWAP
        POP AX
        JMPS @PUSHBX
        ;PUSH BX
        ;XCHG AX,BX
        ;NEXT

; -------------------
; MATHS / LOGIC
; -------------------

@NIP_:
  POP   AX
@NOP_:
  CALL  DI
  NEXT

        ;PRIMITIVE '+',PLUS
        xtname '+',PLUS,@NIP_
        ;POP AX
        ADD BX,AX
        RET
        ;NEXT

        xtname '-',MINUS,@NIP_
        SUB AX,BX
        XCHG BX,AX
        RET

        ;PRIMITIVE '=',EQUALS
        xtname '=',EQUALS,@NIP_
        ;POP AX
        SUB BX,AX
        JMPS  @ZEQ
        ;SUB BX,1
        ;SBB BX,BX
        ;NEXT

        xtname '0=',ZEQ,@NOP_
@ZEQ:
        SUB BX,1
        SBB BX,BX
        RET

; -------------------
; PEEK AND POKE
; -------------------

        xtname 'C@',CFETCH,@peek

        xtname 'C!',CSTORE,@DROP2_
        STOSB
        RET

        PRIMITIVE '@',FETCH
        MOV BX,PW [BX]
        NEXT

        ;PRIMITIVE '!',STORE 447

        xtname '!',STORE,@DROP2_
        STOSW
        RET
        ;POP PW [BX]
        ;POP BX
        ;NEXT

        xtname '+!',PSTORE,@DROP2_
        ADD   PW [DI],AX
        RET

; -------------------
; INNER INTERPRETER
; -------------------

@to4th: pop  si
@MAIN:  ;LODSW
        MOV DI,[SI]
        ;XCHG DI,AX
        CMPSW
        JMP PW [DI-2]

; -------------------
; FLOW CONTROL
; -------------------

        ;PRIMITIVE '0BRANCH',ZERO_BRANCH
        xtname '0BRANCH',ZERO_BRANCH,@DROP1_
        LODSW
        TEST DI,DI
        JNE ZEROB_Z
        XCHG AX,SI
ZEROB_Z:RET 
        ;POP BX
        ;NEXT

        PRIMITIVE 'BRANCH',BRANCH
        MOV SI,PW [SI]
        NEXT

        PRIMITIVE 'EXEC',EXECUTE
        MOV DI,BX
        SCASW
        POP BX
        JMP PW [DI-2]

        ;PRIMITIVE 'EXIT',EXIT
        xtname 'EXIT',EXIT,@exit
        ;MOV SI,PW [BP]
        ;INC BP
        ;INC BP
        ;NEXT

        PRIMITIVE 'BYE',BYE
        XOR AX,AX
        JMP AX

; -------------------
; STRING
; -------------------

        PRIMITIVE 'COUNT',COUNT
        INC BX
        PUSH BX
        DEC bx
@peek:
        MOV BL,PB[BX]
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
        MOV AL,13
        CALL OUTCHAR
        MOV AL,10
        CALL OUTCHAR
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
WORDF:   CMP CX,BX
        JE WORDZ
        MOV AL,PB[BX]
        INC BX
        CMP AL,DL
        JE WORDF
WORDC:   INC DI
        MOV PB[DI],AL
        CMP CX,BX
        JE WORDZ
        MOV AL,PB[BX]
        INC BX
        CMP AL,DL
        JNE WORDC
WORDZ:   MOV PB [DI+1],32
        MOV AX,PW [VAL_DP]
        XCHG AX,DI
        SUB AX,DI
        MOV PB[DI],AL
        SUB BX,PW [VAL_T_I_B]
        MOV PW [VAL_TO_IN],BX
        POP BX
        NEXT

        ;PRIMITIVE 'EMIT',EMIT
        xtname 'EMIT',EMIT,@USEBX_
OUTCHAR: XCHG AX,DX
        MOV AH,2
        INT 021H
        RET

        ;XCHG AX,BX
        ;CALL OUTCHAR
        ;POP BX
        ;NEXT

GETCHAR: MOV AH,7
        INT 021H
        MOV AH,0
        RET

; -----------------------
; DICTIONARY SEARCH
; -----------------------

        PRIMITIVE 'FIND',FIND
        MOV DI,VAL_LAST
FINDL:   PUSH DI
        PUSH BX
        MOV CL,PB[BX]
        MOV CH,0
        INC CX
FINDC:   MOV AL,PB[DI+2]
        AND AL,07FH
        CMP AL,PB[BX]
        JE FINDM
        POP BX
        POP DI
        MOV DI,PW [DI]
        TEST DI,DI
        JNE FINDL
FINDNF:  PUSH BX
        XOR BX,BX
        NEXT
FINDM:   INC DI
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
FINDI:   AND AX,31
        ADD DI,AX
        INC DI
        PUSH DI
        NEXT

; -----------------------
; COLON DEFINITION
; -----------------------

        COLON ':',COLON
        DW XT_LIT,-1,XT_STATE,XT_STORE,XT_CREATE
        DW XT_DO_SEMI_CODE
DOCOLON: DEC BP
        DEC BP
        MOV PW [BP],SI
        ;LEA SI,[DI+2]
        MOV  SI,DI
        NEXT

        COLON ';',SEMICOLON,IMMEDIATE
        DW XT_LIT,XT_EXIT,XT_COMMA,XT_LIT,0,XT_STATE
        DW XT_STORE,XT_EXIT

; -----------------------
; HEADERS
; -----------------------

        COLON 'CREATE',CREATE
        DW XT_DP,XT_FETCH,XT_LAST,XT_FETCH,XT_COMMA
        DW XT_LAST,XT_STORE,XT_LIT,32,XT_WORD,XT_COUNT
        DW XT_PLUS,XT_DP,XT_STORE,XT_LIT,0,XT_COMMA
        DW XT_DO_SEMI_CODE
DOVAR:  PUSH BX
        ;LEA BX,[DI+2]
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
        DW XT_CREATE,XT_COMMA,XT_DO_SEMI_CODE
DOCONST:PUSH BX
        ;MOV BX,PW [DI+2]
        MOV BX, [DI]
        NEXT

; -----------------------
; OUTER INTERPRETER
; -----------------------

restart:
        MOV AX,PW [VAL_NUMBER_T_I_B]
        MOV PW [VAL_TO_IN],AX
        XOR BP,BP
        MOV PW [VAL_STATE],BP
        MOV SP,-256
;        MOV SI,OFFSET XT_INTERPRET+2
        Goforth

        ;COLON 'INTERPRET',INTERPRET							          ; 
INTERPT DW XT_NUMBER_T_I_B,XT_FETCH,XT_TO_IN,XT_FETCH		  ; BEGIN   #TIB @ >IN @ 
        DW XT_EQUALS,XT_ZERO_BRANCH,INTPAR,XT_T_I_B			  ;   = IF TIB		          \ IF EMPTY
        DW XT_LIT,50,XT_ACCEPT,XT_NUMBER_T_I_B,XT_STORE		;     50 ACCEPT #TIB !  
        DW XT_LIT,0,XT_TO_IN,XT_STORE						          ;     0 >IN !  THEN       \ FULL BUF
INTPAR  DW XT_LIT,32,XT_WORD,XT_FIND,XT_DUPE				      ;   BL WORD FIND DUP      \ FOUND ?
        DW XT_ZERO_BRANCH,INTNF,XT_STATE,XT_FETCH			    ;   IF STATE @            \ COMPILATION ?
        DW XT_EQUALS,XT_ZERO_BRANCH,INTEXC,XT_COMMA			  ;	    = IF , 	            \ YES
        DW XT_BRANCH,INTDONE                              ;     ELSE 
INTEXC  DW XT_EXECUTE,XT_BRANCH,INTDONE						        ;     EXECUTE ELSE
INTNF   DW XT_DUPE,XT_ROTE,XT_COUNT,XT_TO_NUMBER			    ;     DUP ROT COUNT >NUM  \ NUMBER
        DW XT_ZERO_BRANCH,INTSKIP,XT_STATE,XT_FETCH			  ;     IF STATE @  
        DW XT_ZERO_BRANCH,INTNC,XT_LAST,XT_FETCH,XT_DUPE	;       IF LAST @ DUP
        DW XT_FETCH,XT_LAST,XT_STORE,XT_DP,XT_STORE			  ;          @ LAST ! DP !
INTNC   DW XT_ABORT											                  ;       THEN ABORT  THEN  
INTSKIP DW XT_DROP, XT_DROP, XT_STATE, XT_FETCH				    ;     DROP DROP STATE @
        DW XT_ZERO_BRANCH,INTDONE,XT_LIT,XT_LIT,XT_COMMA	;     IF LIT LIT , ,
        DW XT_COMMA                                       ;   THEN  THEN THEN
INTDONE DW XT_BRANCH,INTERPT								              ; AGAIN

FREEMEM:

MYCSEG  ENDS
        END  START


