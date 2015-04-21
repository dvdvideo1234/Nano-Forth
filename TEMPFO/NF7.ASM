        INCLUDE  NF7.i0

; REGISTERS
; SI INSTRUCTION POINTER
; AX DATA STACK POINTER
; SP RETURN STACK POINTER
; CX DATA STACK TOP REGISTER
; DI WORK REGISTER

ip  = si        ; for interpretter
w   = di
dsp = ax
rsp = sp
top = cx
topL = cL
toph = ch
ar   = bx       ; address  register
tr   = dx       ; temp register
trl  = dl

nbase = bx      ; for number utility
nacc  = di

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
@VOCTOP = @S_TOP * 5    ; 2048 = 4 BUFFERS * 512

Start   Label byte
        JMPS SELF0

_OPERATION DW @_WARY
        DW _NUMBER,_EXEC        ; INTERPRET
        DW _COMP_NUM,_COMMA     ; COMPILE

  __CONST  _lf,10
  __CONST  _TBL,80H
  __CONST  _TIB,@TIB
  __CONST  _TBUF,@TBuf
  __CONST  _0,0
  __CONST  _BL,32

  __VALUE  _HERE,FREEMEM
  __VALUE  _ETIB,0
  __VALUE  _LTIB,0
  __VALUE  _DICT,@VOCTOP
  __VALUE  _CNTC,0
  __value  _stat,0

  __POINT  _INIT,_@_INI
  __DEFERO _EMIT,_@EMIT
  __DEFER  _SOURCE,_ETIB
  __DEFER  _OK,0
  __DEFER  _ACCEPT,_ACC
  __DEFER  _ERROR,0

;------------  MAIN LOOP  OUTER INTERPRETTER ----

SELF0:
  mov   bx,1000h     ; only 64k allocate
  mov   ah,4ah
  int   21h
@ABORT:
  ;INT 3
  MOV   RSP,@R_TOP
  MOV   DSP,@S_TOP
  CALL  @RETURN
  DW    _INIT,_INIT,_TBL,_cstr
@MAINLP:  ; DW _BRK
  DW _EVAL,_TIB,_TBL,_ACCEPT,_OK,_JUMP,@MAINLP

;------------------------------------

_@_INI:
        DW  _HERE,_WSTR,_DPUSH
        DW  to_+_INIT
        DW  _LPAR,_0,to_+_LTIB,_EXIT

  __COL _EVAL                           ; EVAL
        DW _dup,to_+_LTIB,_add,to_+_ETIB
@DoEval DW _TOKEN
    ;   DW _BRK
        DW _LDB
    ;   DW _BRK
        DW _ZEX
    ;   DW _BRK
        DW _tbuf
        DW _dict
        DW _FIND
        DW _OPERATION,_PERFORM,_JUMP,@DoEval

  __col _find                           ; FIND  with status
        DW _stat,_DOES,_SUB,_FND,_EXIT

_COLON  DW @_MAKER,@NEST,_RPAR          ; :

_SEMICO DW @_COMMA,_EXIT,_LPAR          ; ;`

_CLIT   DW @_COMMA,_LIT,_COMMA          ; #,`

  __col _LIT
        DW _rldp,_exit                  ; lit

  __col2 _XCOMMA                        ; ;,
  __col2 _COMMA                         ; ,
        dw _EX
        DW _HEREX,_STP,_EXIT

  __COL _COMP_NUM                       ; (NUM,
        DW _NUMBER,_CLIT,_EXIT

  __COL _NUMBER                         ; (NUMBER
        DW _cstr,_LF,_NUM,_??,_EXIT

  __COL _HEREX                          ; ;HERE
        DW _HERE,_EX,to_+_HERE,_EXIT

  __COL _ABORT?                         ; (A"
        DW _ASTR,TO_+_STAT,_ZEX,_ERROR,_ABORT
        ; ADDRESS OF ERROR MESSAGE IS IN _STAT

  __COL3 _ENTRYC                        ; =,
  __COL3 _ENTRYH                        ; =H
  __COL3 _ENTRY                         ; =:        ALIAS
        DW _XCOMMA,_HERE
        DW _TOKEN?,_ENTALE,_SKIP
  __COL _DPUSH                          ; >DICT
        DW  _DICT,_SWAP,_MPUSH,_drop,to_+_DICT,_EXIT

  __COL4 _TOKEN?                        ; TOKEN?
  __COL4 _TOKEN                         ; TOKEN
  __COL4 _WORD                          ; WORD
  __COL4 _PARSE                         ; PARSE
        DW _XTOK? ; IS IT A TOKEN ?
        DW _BL
        DW _XSETSTR ; SET TEXT TO BUF

     ;  DW _BRK
        DW _SOURCE
     ;  DW _BRK
        DW _LTIB
     ;  DW _BRK
        DW _PARS
     ;  DW _BRK
        DW to_+_LTIB
     ;  DW _BRK
        DW _EXIT

  __COL  _XSETSTR                       ; ;S!
        DW _EX
        DW _BRK
        dw _TBUF,_MSTR,_nipx

  __COL3 _XTOK?
  __COL5 _Z??
  __COL5 _??
        DW _EX
        DW _DUP
        DW _LDB
        DW _ZEQ
        DW _ABORT?
     __NAM "?"
        DW _EXIT

@_state:
  call  @does3
  dw to_+_stat,_exit

@_BCOMMA:
  call  @does
  DW _LDB,_BCOMMAL

  __COL2 _BCOMMA                 ; C,
  __LBL  _BCOMMAL                ; >C,
        DW _HEREX,_STBP,_EXIT

  __LBL _COMMAER
  dw _Wstr,_comma,_perfORM,_exit

@_comma:
  call @does
  DW _COMMAER

@_MAKER:
  call @does
  dw _entryH,_commaER

;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

  ;-------------------  NUMBER  ------------
         ; adr count base  / num flag -> =0 ok

@NUM:
  CALL  @@numini
  CALL  @@SGN
@@NUMZ:
  CALL  @@N1
  JMPS  @@NUMZ

@@n1:
  cmp   al,'$'     ; BASE := 16
  JNE   @@N2
  MOV   al,16-1
  jmp   SHORT @@setbas

@@N2:   cmp  al,'#'     ; BASE := nbase
  JNE   @@N3
@@numini:
  RCHG  nacc
  DEC   AX
  Xor   nacc,nacc       ; ACCUMULATOR
@@setbas:
  xor   ah,ah
  INC   AX
  mov   nbase,ax
@@END?:
  or    CX,cx
  Jnz   @@GETC
@@ERNUM:
  INC   CX
@@EXNUM:
  pop   dx    ; rdrop
  RET

@@N3:
  cmp   al,''''
  jNE   @@N4
  CALL  @@END?
  JMPS  @@ESCAPE

@@N4:
  cmp   al,'9'+1
  jc    @@ton2
  AND   AL,0DFH
  cmp   al,'A'      ; no case sensivity
  jc    @@ERNUM
  sub   al,7
@@ton2:
  sub   al,'0'
  cmp   ax,nbase
  jnc   @@ERNUM
@@ESCAPE:
  rchg  nacc
  mul   nbase
  rchg  nacc
  add   nacc,ax
  JCXZ  @@EXNUM
@@GETC:
  deC   CX
  LODSB
  RET

@@SGN:
  CMP   AL,'-'     ; SGN
  JNE   @@N1
  CALL  @@END?
  POP   dX
  CALL  dX         ; return to caller
  NEG   nacc
  RET

  ;----------------  PARSE   -----------------

;  CHAR etib ltib  /  START LEN >IN
;  SI   DI   Cx       di    si  cx

  __XT  _PARS,@_PARAM3           ;= (PARS
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
  push  di      ;  START OF THE SOURCE
  JCXZ  @@WEX

  REPNE SCASB
  JNE   @@WEX
  DEC   DI

@@WEX:          ; END OF THE SOURCE  IN DI
  xchg  ax,di
  pop   di
  SUB   ax,di
  XCHG  AX,SI
  X
  PUSH  di      ; START OF THE SOURCE
  JMPS  @PUSH_sCZ

  __XT  _num,@_PARAM3           ;= (ATOI
  to_r  ax
  xchg  nacc,cx
  CALL  @NUM
@PUSH_DC:
  XCHG  NACC,SI         ; di,si ?!

@PUSH_SCa:
  r_to  AX

@PUSH_sC:
  X
@PUSH_sCZ:
  PUSH  sI      ; LENGTH OF THE SOURCE
  PUSH  CX      ; REST LEN OF BUF  in dx
  X
  RET

  ; ------------ SEARCH  --------------
  __XT  _FND,@_PARAM3            ; (FIND
  MOV   DX,OFFSET @PUSH_sC ; RETURNS SI CX
  PUSH  DX
  jcxz  Mfnd
fnd:
  xor   cx,cx
  jMPS  l@Nfnd
ZFND:           ; SKIP FIRST WORD IN DICTIONARY
  MOV   CL,[DI] ; ON COMPILE ONLY
  INC   DI
NFND:
  add   di,cx
  SCASW
l@Nfnd:
  mov   cl,[di]
  jcxz  xfnd?
  INC   CX
  PUSH  SI
  repe  cmpsb
  POP   SI
  jNZ   Nfnd
YFND:
  MOV   SI,[DI]
  inc   cx
xFND?:
  ret

MFND:       ; COMPILE MODE SEARCH
  push  di
  push  SI
  inc   pb [SI]
  call  Zfnd
  pop   BX
  dec   pb [BX]
  pop   di
  jCXZ  Dfnd
  RET

dfnd:
  call  ZFND
  inc   cx
  inc   cx
  ret

  ;----------------  MEMORY  -------------------
                                ; (>MEM
  __XT  _MPUSH,@_PARAM3       ; TOP OF DICTIONARY   IN DI
  ADD   SI,CX                ; AFTER NAME ADDRESS
  to_r  cx
  STD                        ; BACKWARDS
  CMPSB                      ; PREPARE FOR DIRECTION
  REP   MOVSB                ; NAME  MOVE
  inc   di
  jmps  @push_dcp

  __XT  _MSTR,@_PARAM3        ; (S!
  xchg  cx,di
  to_r  di
  MOV   [DI],CL
  INC   DI
  REP   MOVSB   ; NAME  MOVE
  MOV   PB [DI],'`'
@push_dcp:
  r_to  cx
@push_dcA:
  to_r  Ax
  jmps  @push_Dc

_CSTR   DW @_PARAM1
  TO_R  DSP
  JMPS  CSTR@

_ENTALE DW @_PARAM2
  XOR   BX,BX
  MOV   BL,[DI]
  MOV   [DI+BX+1],SI
  LEA   CX,[BX+3]
  jmps  @push_DcA

  ;--------------------   IO  ---------------
_ACC   DW @_param2
  call  @io
        dw 0A00H          ; (ACC
  MOV   PW [si],CX
  INT   21H
  INC   si

  TO_R  di
CSTR@:
  xor   ax,ax
  lodsb
  rCHG  CX
  JMPS  @PUSH_SCA

_@EMIT: DW @_param1             ; (EMIT
  call  @io
        dw 200h  ; dos function number EMIT
  INT   21H
  xchg  ax,di
  RET

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


;------------  MAIN LOOP  INNER INTERPRETTER ----
;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

@_RLD:
  dpop
@_LD@:
  to_r  W
  MOV   W,top
  MOV   top,[W]
  RET

@_FOR:
  NEG   top
@_PUSH:
  to_r  top
@_DROP:
  to_r  W
  MOV   W,top
  D_TO  top
  OR    W,W
  RET

@_IJ:
  MOV   W,[W]
  ADD   W,rSP
  jmps  @_cons

@over:
  mov   w,dsp
  skipa

@_CONS3:
  W2
@_CONS2:
  W2
@_CONS:
  MOV   W,[W]
@_VAR:
  to_D top
@ADR:
  MOV   top,W
  JMP   @MAIN

_Wstr  dw @_ld@         ; STR
  w2
  skipa

_SWAP   DW @_DROP       ; SWAP
@nupw:
  to_D W
  JMPS  @1

@_VAR3:
  W2
@_VAR2:
  W2
  skipb

@POP:
  r_to  W
  JMPS  @_VAR

_STBP   DW @_DROP       ; C!+
  MOV   [W],TOPL
  JMPS  @ADR1P

_STP    DW @_DROP       ; !+
  MOV   [W],top
@ADR2P:
  INC   W
@ADR1P:
  INC   W
  JMPS  @ADR

; RETURN STACK COMMANDS  POP PUSH XCHG

_ASTR  DW @_RLD         ; (STR
  XOR   topH,topH       ; : (STR POP pop CSTR + push push ;
  inc   top
  ADD   top,W

  skipb
@XCHG:
  r_to  W

  XCHG  top,W

@PUSH:
  to_r  W
  JMPS  @1

_RLDBP  DW @_RLD        ; C@R+
  XOR   topH,topH
  JMPS  @PUSH1p

_RLDP   DW @_RLD        ; @R+
@PUSH2P:
  INC   W
@PUSH1P:
  INC   W
  JMPS  @PUSH2P

@CODE@:                 ; FORTH > CODE
  JMP   IP

_TOCODE DW @CODE@
_NIPX   DW @NIPX

@NIPX:
  R_TO  IP
@nip:
  inc   dsp
  inc   dsp
  SKIPA

_PUSH   DW @_PUSH       ; PUSH
  JMPS  @1

;_nip    dw @nip

  ; io adapter  to params
@IO:    ; RA [RA] SI DI CX =: SI AX DX CX BX
  POP   DX
  XCHG  DX,SI   ; SET DX
  RCHG  DI      ; SAVE AX
  RCHG  CX      ; SET CX
  RCHG  BX      ; SET BX
  LODSW         ; SET AX
  PUSH  SI
  MOV   SI,DX
  RET

@_PARAM1:       ; si=di=cx=top
  X
  to_r  top
  X
@_PARAM2:       ; di=cx=top
  X
  to_r  top
  X
@_PARAM3:       ; si di cx
  to_r  IP
  to_r  ar
  x
  r_to  BX
  r_to  si
  x
  XCHG  BX,DI
  ; INT 3         ; !!!!!
  CALL  BX
  CLD
  r_to  ar
@DROPX:
  r_to  IP
@DROP:
  D_TO  top
@1:
  JMPS  @MAIN

_DROPX  DW @DROPX

@2m:
  DEC   top
@1m:
  DEC   top
  skipa
@2p:
  inc   top
@1p:
  inc   top
  JMPS  @MAIN

@_SETVAR2:
  W2
  SKIPA

_ST     DW @_DROP
@_SETVAR:
  MOV   [W],top
  JMPS  @DROP

@_DUP:
  to_D top
@_CALL:
  CALL  W
  JMPS  @MAIN

_FOR    DW @_FOR        ; (FOR
  JS    @SKIP
  MOV   IP,[IP]

@RDROP:
  r_to  W
  JMPS  @MAIN

_IF     DW @_DROP       ; (IF
  JE    @JUMP

@SKIP:
  wiP2
  JMPS  @MAIN

@NEXT:    ; (NEXT
  r_to  W
  INC   W
  JE    @SKIP
  to_r W

@JUMP:    ; (JUMP
  MOV   IP,[IP]
  JMPS  @MAIN

@_POINT:
  MOV   W,[W+2]
  JMPS  @NEST

_ZEX    DW @_DROP       ; 0;
  JNE   @MAIN
  SKIPA

@_setpnt:
  MOV   [W],IP
  JMPS  @RETURN

; MAIN  LOOP
_rPAR   dw @_state              ; ]
_does   dw @_var2
@DOES3:
  W2
@DOES2:
  W2
@DOES:
  to_D  top
  MOV   top,W
@EX:
  r_to  W
@NEST:
  to_r  IP
@LBL:
  to_r  W
@RETURN: ; (;
  r_to  IP
@MAIN:
  MOV   W,[IP]
  wiP2
  JMP   [W-2]

; CONTROL      COMMANDS
_LDB    DW @_LD@        ; C@
  MOV   topH,0
  SKIPA
_LD     DW @_LD@        ; @
  JMPS  @MAIN

@_DEFERO:
  INC   PW [AT_+_CNTC]
  SKIPA
@_DEFER3:
  W2
@_DEFER2:
  W2
@_DEFER:
  MOV   W,[W]
@EXEC:
  OR    W,W
  JZ    @MAIN
  W2
  JMP   [W-2]

@nest5:
  w2
@nest4:
  w2
@nest3:
  w2
@nest2:
  w2
  skipa                 ; >nest  !!!

_EXECUTE DW @_DROP      ; EXECUTE
  JMPS  @NEST

_EXEC   DW @_DROP       ; EXEC
  jmps  @EXEC

_PERFORM   DW @_DROP    ; @EXEC
  jmps  @_DEFER

; LOGICAL      COMMANDS  XOR AND

_LPAR   dw @_state              ; [`
_and    DW @_DROP       ; and
  and   top,W
  JMPS  @MAIN

_xor    DW @_DROP       ; xor
  xor   top,W
  JMPS  @MAIN

_SUB    DW @_DROP       ; -
  SUB   top,W
  JMPS  @MAIN

@_WARY:
  SHL   top,1
@_BARY:
  skipa
_add    dw @_drop       ; +
@Add:
  ADD   top,W
  JMPS  @MAIN

@ZEQ:
  SUB   top,1
@CF:
  cf_to top
  JMPS  @MAIN

@ODD:
  SHR   TOP,1
  JMPS  @CF

  __XT  _DUP,@_DUP      ; dup
  ret

  __XT  _NEXT,@NEXT
  __XT  _RDROP,@RDROP
  __XT  _JUMP,@JUMP
  __XT  _SKIP,@SKIP
  __XT  _ABORT,@ABORT


  __XT  _EXIT,@RETURN
  __XT  _EX,@EX
  __XT  _XCHG,@XCHG
  __XT  _POP,@POP
  __XT  _DROP,@DROP
  __XT  _ZEQ,@ZEQ       ; 0=

;-----------------------------------------------
;  TEST
;
@BRK:
  INT 3
  JMP @MAIN

  __XT _BRK,@BRK

;
;
;
;-----------------------------------------------

freemem:
  DW ENDMEM-FREEMEM-2
  __ENTRY  '=:',_ENTRY
  DB 0
EndMem:


lastw = ppppp

MyCseg  ends
        end  Start

;____________________________________________

NF7      OUT     1725   1-30-15   5:38p
NF7      SN      4968   4-14-15   3:48p
NF7      SN1     4968   4-14-15   5:01p
NF7      SN2     5579   4-15-15  12:55p
NF7      SRT     1683  12-11-14  10:55p
