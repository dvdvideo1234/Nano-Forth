        INCLUDE  NF7.i0

; REGISTERS
; SI INSTRUCTION POINTER
; SP RETURN STACK POINTER
; AX DATA STACK POINTER
; CX DATA STACK TOP REGISTER
; DI WORK REGISTER
; DX ADRESS REGISTER  ?
; DX BX BP   - NOT USED
;
; MINIMAL SET INTERPRETTER COMMANDS
; METHOD       COMMANDS  (DOES (VAR (CONST (CONST2 (DEFER (DEFER2
;                        (SETVAR (SETVAR2 (CONST3 (SETPOINT (POINT
;                        (BARY (WARY (RW_BLK
; CONTROL      COMMANDS  (IF (JUMP (CALL (NEXT (FOR (NEST (EXEC (PERF
;                        (GOTO (RETURN (EX (XNEST (IFZ (IFM
; RETURN STACK COMMANDS  POP PUSH RDROP I J
; DATA STACK   COMMANDS  DUP DROP XCHG
; MATH         COMMANDS  +2/ LIT  ABS NEG NOT _ 1- 2- 1+ 2+
; LOGICAL      COMMANDS  XOR AND
; DATA TRANSF  COMMANDS  @R+ !R+ C!R+
; IO           COMMANDS  (IO

MyCseg  segment para  use16

        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg, es: MyCseg

        org 100h

@TBUF   = -256          ; 256
@TIB    = @TBUF * 2     ; 256
@R_TOP  = @TIB * 2      ; 512  RSTACK
@S_TOP  = @R_TOP * 2    ; 1024 DSTACK
@VOCTOP = @S_TOP * 2    ; 2048 = 4 BUFFERS * 512

Start   Label byte
        JMPS SELF0

  __CONST  _TBL,80H
  __CONST  _TIB,-512
  __CONST  _TBUF,-256
  __CONST  _0,0
  __CONST  _BL,32

  __VALUE  _HERE,FREEMEM
  __VALUE  _ETIB,0
  __VALUE  _LTIB,0
  __VALUE  _DICT,@VOCTOP
  __VALUE  _CURR,VAL_@+_DFND
  __POINT  _FIND,0
_SETPNT = TO_@+_FIND

_OPERATION DW @_WARY
        DW _COMP_NUM,_COMMA,_NUMBER,_EXEC

  __XT     _CNTC,0

  __VOC    _DFND,@VOCTOP+ENDMEM-FREEMEM
  __VOC    _MFND,0

  __DEFERO _EMIT,_@EMIT
  __DEFER  _SOURCE,_ETIB
  __DEFER  _OK,0
  __DEFER  _ACCEPT,_ACC
  __DEFER  _ERROR,0

  __POINT  _INIT,_@_INI
_REINI  = TO_@+_INIT

SELF0:
  mov   bx,1000h     ; only 64k allocate
  mov   ah,4ah
  int   21h
@ABORT:
  MOV   SP,@R_TOP
  MOV   AX,@S_TOP
  CALL  @RETURN
  DW    _INIT,_INIT,_TBL,_COUNT
@MAINLP DW _EVAL,_TIB,_TBL,_ACCEPT,_OK,_JUMP,@MAINLP

;------------------------------------

  __COL _EVAL
        DW _DUP,TO_@+_LTIB,_ADD,TO_@+_ETIB
@EVAL   DW _TOKEN,_ZEX,_TBUF,_FIND
        DW _OPERATION,_PERFORM,_JUMP,@EVAL

@_commaer:
  call @does
@commaer:
  dw _strp,_comma,_perfORM,_exit

@_MAKER:
  call @does
  dw _HERE,_ENTRY,_JUMP,@commaER

_COLON  DW @_MAKER,@NEST,_RPAR          ; :

_SEMICO DW @_COMMAER,@RETURN,_LPAR      ; ;

_clit   dw @_commaer,_lit,_comma        ; #,

  __COL _NUMBER
        DW _COUNT,_NUM,_SKIP

  __COL _??
        DW _ABORT?
  __NAM  " ?"
        DW _EXIT

  __COL _COMP_NUM
        DW _NUMBER,_cLIT,_COMMA,_EXIT

  __XT  _num,@_PARAMZ      ;= (>#       ; (NUM
  push  ax
  MOV   AX,10  ; base := 10
  CALL  @@NUM
  pop   AX
  X
  PUSH  BX
  PUSH  CX
  X
  RET

@@NUM:
  CALL  @@numini
  CALL  @@SGN
@@NUMZ:
  CALL  @@N1
  JMPS  @@NUMZ

@@n1:
  cmp   al,'$'     ; BASE := 16
  JNE   @@N2
  MOV   al,16
  jmp   SHORT @@setbas

@@N2:   cmp  al,'#'     ; BASE := CX
  JNE   @@N3
  mov   al,Bl
@@numini:
  Xor   Bx,Bx      ; ACCUMULATOR
@@setbas:
  mov   DI,ax
@@END?:
  JCXZ  @@ERNUM
@@GETC:
  deC   CX
  LODSB
  RET

@@N3:
  cmp   al,'9'+1
  jc    @@ton2
  AND   AL,0DFH
  cmp   al,'A'      ; no case sensivity
  jc    @@ERNUM
  sub   al,7
@@ton2:
  sub   al,'0'
  cmp   ax,DI
  jnc   @@ERNUM
  xchg  ax,Bx
  mul   DI
  xchg  ax,Bx
  add   Bx,ax
  JCXZ  @@EXNUM
  JMP   @@GETC
@@ERNUM:
  INC   CX
@@EXNUM:
  pop   dx    ; rdrop
@@noEXn:
  RET

@@SGN:
  CMP   AL,'-'     ; SGN
  JNE   @@N1
  POP   dX
  CALL  @@END?
  CALL  dX
  NEG   bX
  RET

@_RLD:
  TPUSH CX
  POP   CX
@_LD@:
  PUSH  DI
  MOV   DI,CX
@LD@:
  MOV   CX,[DI]
  RET

@_FOR:
  NOT   CX
@_PUSH:
  PUSH  CX
@_DROP:
  PUSH  DI
@DRET:
  MOV   DI,CX
  TPOP  CX
  OR    DI,DI
  RET

  __XT  _ZEQ,@_CALL
@ZEQ:
  SUB   CX,1
  SBB   CX,CX
  RET

  __XT  _DUP,@_DUP
  ret

  __XT  _J,@_IJ         ; J
        DW 2

_@EMIT: DW @_2IO,200h ; dos function number EMIT
  INT   21H
  XCHG  SI,AX
  RET

  __COL _TOKEN
        DW _BL,_SKIP
  __COL _PARSE
        DW _SOURCE,_LTIB,_PARS,TO_@+_LTIB,_TBUF,_MAKESTR,_A,_EXIT

;  CHAR etib ltib  /  START LEN >IN
;  SI   BX   Cx
  __XT  _PARS,@_PARAM           ;= (PARS
  MOV   DI,BX
  SUB   DI,CX
  XCHG  AX,SI

  CMP   AL,' '
  JNE   @@SKIPX
  JCXZ  @@SKIPX
  REPE  SCASB
  JE    @@SKIPX
  DEC   DI
  INC   CX
@@SKIPX:
  MOV   DX,DI   ;  START OF THE SOURCE
  JCXZ  @@WEX

  REPNE SCASB
  JNE   @@WEX
  DEC   DI

@@WEX:
  XCHG  AX,DI   ; END OF THE SOURCE
  SUB   AX,DX
  XCHG  AX,SI
  X
  PUSH  DX      ; START OF THE SOURCE
  JMPS  @FND?2
; PUSH  SI      ; LENGTH OF THE SOURCE
; PUSH  CX      ; REST LEN OF BUF
; X
; RET

  __XT  _FND,@_PARAMz     ; (FIND
NEXTfnd:
  MOV   CX,[BX]
  Jcxz  @FND?
  MOV   BX,CX
  LEA   dI,[BX+5]
  mov   cl,[di]
  XOR   ch,ch
  INC   CX
  PUSH  SI
  repe  cmpsb
  POP   SI
  jNZ   NEXTfnd
  mov   SI,[BX+2]
  inc   cx        ; fnd_ok
@FND?:
  x
@FND?2:
  PUSH  SI
  PUSH  CX
  X
  RET

; DATA STACK   COMMANDS  DUP DROP

@_IJ:
  MOV   DI,[DI]
  ADD   DI,SP
  SKIPA

@_CONS3:
  SCASW
@_CONS2:
  SCASW
@_CONS:
  MOV   DI,[DI]
@_VAR:
  TPUSH CX
@ADR:
  MOV   CX,DI
  JMP   @MAIN

_strp   dw @_ld@
  scasw
  skipa
_SWAP   DW @_DROP       ; SWAP
@swap:
  XCHG  CX,DI
  JMPS  @_VAR

@POP:
  POP   DI
  JMPS  @_VAR

_LDP    DW @_LD@        ; @+
@_VAR2:
  SCASW
  JMPS  @_VAR

_STM    DW @_DROP
  DEC   DI
  MOV   [DI],CH
  SKIPA

_STMB   DW @_DROP
  DEC   DI
  MOV   [DI],CL
  JMPS  @ADR

_STP    DW @_DROP
  MOV   [DI],CX
@ADRP:
  SCASW
  JMPS  @ADR

; RETURN STACK COMMANDS  POP PUSH XCHG
_COUNT  DW @_LD@
  MOV   CH,0
  INC   DI
  XCHG  CX,DI
  JMPS  @_VAR

_@_STR  DW @_RLD
  XOR   CH,CH
  INC   CX
  ADD   CX,DI
  SKIPB

@XCHG:
  POP   DI
  XCHG  CX,DI
@PUSH:
  push  di
  JMPS  @1

_LIT    DW @_RLD
  SCASW
  JMPS  @PUSH

_PUSH   DW @_PUSH
  JMPS  @1

@_2IO:    ; DX/CX/BX AX
  X
  PUSH  CX
  PUSH  CX
  X
@_IO:
  PUSH  SI
  PUSH  BX
  MOV   BX,CX
  MOV   SI,[DI] ; TO BE  AX
  SCASW
  X
  POP   CX
  POP   DX
  X
  XCHG  SI,AX
  jmps  @doer

@_PARAMz:       ; UNIVERSAL ENTRY
  x
  push  cx
  x
@_PARAM:        ; UNIVERSAL ENTRY
  PUSH  SI
  PUSH  BX
  x
  pop   bx
  pop   si
  x
@doer:
  CALL  DI
@ret_self:
  CLD
  POP   BX
@RET_DR:
  POP   SI
@DROP:
  TPOP  CX
  JMPS  @MAIN

@ABS:
  OR    CX,CX
  JNS   @1
@NEG:
  DEC   CX
@NOT:
  NOT   CX
@1:
  JMPS @MAIN

@2M:
  DEC   CX
  DEC   CX
  SKIPA
@2P:
  INC   CX
  INC   CX
  JMPS @MAIN
_2P     DW @2P

_ST     DW @_DROP
  SKIPB

@_SETVAR2:
  SCASW
@_SETVAR:
  MOV   [DI],CX
  JMPS  @DROP

@_DUP:
  TPUSH CX
@_CALL:
  CALL  DI
  JMPS  @MAIN

_FOR    DW @_FOR
  JS    @SKIP
  MOV   SI,[SI]

@RDROP:
  POP   DI
  JMPS  @MAIN

_IF     DW @_DROP
  JE    @JUMP

@SKIP:
  CMPSW
  JMPS  @MAIN

@NEXT:    ; (NEXT
  POP   DI
  INC   DI
  JE    @SKIP
  PUSH  DI

@JUMP:    ; (JUMP
  MOV   SI,[SI]
  JMPS  @MAIN

@_POINT:
  MOV   DI,[DI+2]
  JMPS  @NEST

@_SETPNT:
  MOV   [DI],SI
  JMPS  @RETURN

; MAIN  LOOP
@DOES4:
  SCASW
@DOES3:
  SCASW
@DOES2:
  SCASW
@DOES:
  TPUSH CX
  MOV   CX,DI
@EX:
  POP   DI
@NEST:
  PUSH  SI
@LBL:
  PUSH  DI
@RETURN: ; (;
  POP   SI
@MAIN:
  MOV   DI,[SI]
  CMPSW
  JMP   [DI-2]

_ZEX    DW @_DROP
  JE    @RETURN
  JMP   @MAIN

@CALL:   ; (CALL
  XCHG  DI,AX
  LODSW
  XCHG  DI,AX
  JMPS  @NEST

; CONTROL      COMMANDS
@NEST3:
  SCASW
@NEST2:
  SCASW
  JMPS  @NEST

_EXECUTE DW @_DROP
  JMPS  @NEST

_LDB    DW @_LD@        ; C@
  MOV   CH,0
  SKIPA
_LD     DW @_LD@        ; @
  JMPS  @MAIN

@_DEFERO:
  INC   PW [_CNTC]
  SKIPA
@_DEFER3:
  SCASW
@_DEFER2:
  SCASW
@_DEFER:
  MOV   DI,[DI]
@EXEC:
  OR    DI,DI
  JZ    @MAIN
  SCASW
  JMP   [DI-2]

_EXEC   DW @_DROP
  jmps  @EXEC

_PERFORM   DW @_DROP
  jmps  @_DEFER

; LOGICAL      COMMANDS  XOR AND
_SUB    DW @_DROP
  SUB   CX,DI
  JMPS  @MAIN

@_WARY:
  SHL   CX,1
@_BARY:
  SKIPA
_ADD    DW @_DROP
  ADD   CX,DI
  JMPS  @MAIN

  __XT  _NEXT,@NEXT
  __XT  _RDROP,@RDROP
  __XT  _JUMP,@JUMP
  __XT  _EXIT,@RETURN
  __XT  _SKIP,@SKIP
  __XT  _ABORT,@ABORT

  __COL _LOOPS
        DW _FOR,@@LPS
@@LPS0  DW _J,_EXECUTE,_NEXT,@@LPS0
@@LPS   DW _RDROP,_EXIT

  __COL _ENTRY
        DW _CURR,_LD,_SWAP,_0,_TOKEN?
        DW _DICT,_STRPUSH,_A,_STMB,_STM
        DW _STM,_DUP,TO_@+_DICT,_CURR,_ST,_EXIT

  __COL _TYPES
        DW _LOOPS,_COUNT,_EMIT,_EXIT

  __COL    _TDOT
        DW _COUNT,_TYPES
@ABORTX DW _DROP,_EXIT


  __XT  _DROP,@DROP

  __COL    _TOKEN?
        DW _TOKEN,_ZEQ,_??,_TBUF,_EXIT

_ACCZ   DW @_2IO,0A00H
  MOV   PW [BX],120
  INT   21H
  INC   BX
  XCHG  SI,AX
  TPUSH BX
  RET

  __COL _ACC
  DW _DROP,_ACCZ,_COUNT,_EXIT

  __COL _COMMA
        DW _HERE,_STP,TO_@+_HERE,_EXIT

  __COL _ABORT?
        DW _@_STR,_SWAP,_IF,@ABORTX,_ERROR,_ABORT

@_SET_VOC:
  CALL  @DOES2
  DW    TO_@+_CURR,_EXIT

@_SRCH_VOC:
  CALL  @DOES
  DW    _FND,_EXIT

  __col _LPAR
        DW _SETPNT
@LPAR   DW TO_@+_DFND
@EXEC2P DW _2P,_EXIT            ; EXECUTE

  __col _RPAR
        DW _SETPNT,TO_@+_MFND,_DUP,_ZEQ,_IF,@EXEC2P
        DW _DROP,TO_@+_DFND,_EXIT  ; COMPILE

  __XT  _CMOVEU,@_PARAM
  ADD   BX,CX
  JMPS  @MPUSH

  __XT  _STRPUSH,@_PARAMZ       ; S!-
  mov   cl,[Si]
  XOR   ch,ch
  INC   CX
  SKIPA

  __XT  _MPUSH,@_PARAM
  XCHG  CX,BX
@MPUSH:
  MOV   DI,bX   ; TOP OF DICTIONARY
  ADD   SI,CX   ; AFTER NAME ADDRESS
  STD           ; BACKWARDS
  CMPSB         ; PREPARE FOR DIRECTION
  REP   MOVSB   ; NAME  MOVE
  LEA   DX,[DI+1]
  RET

  __XT  _MAKESTR,@_PARAM        ; S!
  XCHG  BX,CX
  MOV   DX,CX
  MOV   [BX],CL
  INC   BX
  SKIPA

  __XT  _CMOVE,@_PARAM          ; CMOVE
  MOV   DI,bX
  REP   MOVSB   ; NAME  MOVE
  RET

_AEX    DW @_CALL               ; A@!
  SKIPA
_A      DW @_DUP                ; A@
  XCHG  CX,DX
  RET

_@_INI:
    DW  _HERE,_STRP,_DICT,_MPUSH,_A,TO_@+_DICT
    DW  _REINI
    DW  _LPAR,_0,TO_@+_LTIB,_EXIT

;-----------------------------------------------

freemem:
  DW ENDMEM-FREEMEM-2
  __ENTRY  0,_ENTRY,'=:'
EndMem:


lastw = ppppp

MyCseg  ends
        end  Start

;____________________________________________
