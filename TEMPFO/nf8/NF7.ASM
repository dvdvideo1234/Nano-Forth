        INCLUDE  NF7.i0

; REGISTERS
; SI INSTRUCTION POINTER
; AX DATA STACK POINTER
; SP RETURN STACK POINTER

ip  = si        ; for interpretter
w   = di
dsp = ax
rsp = sp
top = cx
toph = ch
ar   = bx       ; address  register
tr   = dx       ; temp register
trl  = dl

nbase = di      ; for number utility
nacc  = bx

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
@VOCTOP = @S_TOP * 5    ; 2048 = 4 BUFFERS * 512

Start   Label byte
        JMPS SELF0

_OPERATION DW @_WARY
        DW _COMP_NUM,_COMMA,_NUMBER,_EXEC

  __CONST  _TBL,80H
  __CONST  _TIB,@TIB
  __CONST  _TBUF,@TIB
  __CONST  _0,0
;  __CONST  _BL,32

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
  MOV   RSP,@R_TOP
  MOV   DSP,@S_TOP
  CALL  @RETURN
  DW    _INIT,_INIT,_TBL,_cstr
@MAINLP DW _EVAL,_TIB,_TBL,_ACCEPT,_OK,_JUMP,@MAINLP

;------------------------------------

_@_INI:
        DW  _HERE,_WSTR,_DPUSH
        DW  to_+_INIT
        DW  _LPAR,_0,to_+_LTIB,_EXIT

  __COL _EVAL                   ; EVAL
        DW _UADD,to_+_LTIB,to_+_ETIB
@DoEval DW _TOKEN,_ZEX,_tbuf,_FIND
        DW _OPERATION,_PERFORM,_JUMP,@DoEval

_LPAR   dw @_state              ; [`
        db 0

_rPAR   dw @_state              ; ]
        db 1

  __col _find                  ; FIND  with status
        DW _dict,_stat,_FND,_EXIT

_COLON  DW @_MAKER,@NEST,_RPAR  ; :

_SEMICO DW @_COMMA,_EXIT,_LPAR  ; ;`

_clit   dw @_comma,_lit,_comma  ; ##,`

  __COL _NUMBER                 ; (NUMBER
        DW _cstr,_NUM,_SKIP
  __COL _??
        DW _ABORT?
     __NAM " ?"
        DW _EXIT

  __COL _COMP_NUM               ; (NUM,
        DW _NUMBER,_cLIT,_COMMA,_EXIT

  __COL    _TOKEN?              ; TOKEN?
        DW _TOKEN,_ZEQ,_??,_TBUF,_EXIT

  __COL _DROPX                  ; ;DROP
        DW _EX
@ABORTX DW _DROP,_EXIT

  __COL _XEP                    ; XEP
        DW _XCHG,_EXECUTE,_POP,_EXIT

  __COL _HEREX                  ; ;HERE
        DW _HERE,_EX,to_+_HERE,_EXIT

  __COL _COMMA                  ; ,
        DW _HEREX,_STP,_EXIT

  __COL _BCOMMA                 ; C,
        DW _HEREX,_STBP,_EXIT

  __COL _STRCOMMA               ; S,
        DW _cstr,_herex,_mstr,_nip,_exit

  __COL _ABORT?                 ; (A"
        DW _ASTR,_SWAP,_IF,@ABORTX,_ERROR,_ABORT

  __COL _ENTRY                  ; =:
        DW _HEREX,_XEP,_COMMA,_0,_BCOMMA,_TOKEN?
        DW _STRCOMMA,_J,_here,_J,_SUB,_SKIP  ; !!!  J = OLD HERE
  __COL _DPUSH                  ; >DICT
    DW  _DICT,_SWAP,_MPUSH,to_+_DICT,_EXIT

  __COL _TOKEN                  ; TOKEN
        DW _lit,' ',_SKIP
  __COL _PARSE                  ; PARSE
        DW _SOURCE,_LTIB,_PARS,to_+_LTIB,_TBUF,_skip
  __col _makestr                ; S!
        dw _MSTR,_drop,_EXIT

@_state:
  call  @does
  dw _ldb,to_+_stat,_exit

@_comma:
  call @does
@commaer:
  dw _Wstr,_comma,_perfORM,_exit

@_MAKER:
  call @does
  dw _here,_entry,_JUMP,@commaER

;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

  ;-------------------  NUMBER  ------------

  __XT  _num,@_PARAM2           ;= (ATOI
  to_r  ax
  MOV   Al,10  ; base := 10
  CALL  @NUM
  r_to  AX
  X
  to_r  nacc
  to_r  cx
  X
  RET

@NUM:
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

@@N2:   cmp  al,'#'     ; BASE := nbase
  JNE   @@N3
  xchg  ax,nacc
@@numini:
  Xor   nacc,nacc       ; ACCUMULATOR
@@setbas:
  xor   ah,ah
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
  JCXZ  @@ERNUM
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
  jmps  xfnd3
; PUSH  sI      ; LENGTH OF THE SOURCE
; PUSH  CX      ; REST LEN OF BUF  in dx
; X
; RET

  ; ------------ SEARCH  --------------
dfnd:
  call  fnd
xfnd:
  inc   cx
  inc   cx
xfnd2:
  x
xfnd3:
  PUSH  sI
  PUSH  cx
  X
  RET

  __XT  _FND,@_PARAM3            ; (FIND
  jcxz  dfnd
  push  di
  inc   pb [si]
  call  fnd
  dec   pb [si]
  pop   di
  or    cx,cx
  jnz   xfnd
  call  fnd
  jmps  xfnd2

fnd:
  xor   cx,cx
l@Nfnd:
  add   di,cx
fnd2:
  mov   bx,di
  LEA   di,[bx+3]
  mov   cl,[di]
  jcxz  xfnd?
  INC   CX
  push  si
  repe  cmpsb
  pop   si
  jNZ   l@Nfnd
  mov   SI,[BX]
  mov   dx,bx
  inc   cx
xFND?:
  ret

  ;----------------  MEMORY  -------------------
                                ; (>MEM
  __XT  _MPUSH,@_PARAM3       ; TOP OF DICTIONARY   IN DI
  ADD   SI,CX                ; AFTER NAME ADDRESS
  STD                        ; BACKWARDS
  CMPSB                      ; PREPARE FOR DIRECTION
  REP   MOVSB                ; NAME  MOVE
  inc   di
@pushdi:
  to_d  di
  ret

  __XT  _MSTR,@_PARAM3        ; (S!
  xchg  cx,di
  to_d  cx
  MOV   [DI],CL
  INC   DI
  REP   MOVSB   ; NAME  MOVE
  MOV   PB [DI],'`'
  jmps  @pushdi

  ;--------------------   IO  ---------------
_ACC   DW @_param2
  call  @io
        dw 0A00H          ; (ACC
  mov   si,dx
  MOV   PW [si],79
  INT   21H
  INC   si
  xor   ax,ax
  lodsb
  xchg  ax,di
  x
  push  si
  push  di
  x
  ret

_@EMIT: DW @_param2             ; (EMIT
  call  @io
        dw 200h  ; dos function number EMIT
  INT   21H
  xchg  ax,di
  RET

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  __XT  _ZEQ,@_CALL     ; 0=
  SUB   top,1
  cf_to top
  RET

  __XT  _DUP,@_DUP      ; dup
  ret

  __XT  _J,@_IJ         ; J
        DW 2


;------------  MAIN LOOP  INNER INTERPRETTER ----
;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

;@_ST@:
;  dpush
;@_RST@:
;  r_tO  tr
;  tO_r  W
;  MOV   W,tr
;  mov   tr,top
;  D_TO  top
;  RET

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
  ADD   W,DSP
  SKIPA

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
@PUSHW:
  to_D W
  JMPS  @1

@POP:
  r_to  W
  JMPS  @_VAR

_STBP   DW @_DROP       ; C!+
  XCHG  AX,top
  STOSB
  JMPS  @STPZ

_STP    DW @_DROP       ; !+
  XCHG  AX,top
  STOSW
@STPZ:
  XCHG  AX,top
  JMPS  @ADR

; RETURN STACK COMMANDS  POP PUSH XCHG
_CSTR   DW @_LD@        ; CSTR
  MOV   topH,0
  INC   W
  JMPS  @PUSHW

_ASTR  DW @_RLD         ; (STR
  XOR   topH,topH
  DEC   top             ; : (STR POP pop CSTR + push push ;
  ADD   top,W
  XCHG  top,W
@PUSH2P:
  INC   W
@PUSH1P:
  INC   W
@PUSH:
  to_r  W
  JMPS  @1

@XCHG:
  r_to  W
  XCHG  top,W
  JMPS  @PUSH

_RLDP   DW @_RLD        ; @R+
  JMPS  @PUSH2P

_RLDBP  DW @_RLD        ; C@R+
  XOR   topH,topH
  JMPS  @PUSH1P

_PUSH   DW @_PUSH       ; PUSH
  JMPS  @1

@IO:    ; io adapter  to params
  xchg  dx,ax
  pop   bx
  xchg  si,bx
  push  bx
  push  di
  push  cx
  lodsw
  mov   di,dx
  pop   bx
  pop   cx
  pop   dx
  jmp   si      ; return

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
  CALL  BX
  CLD
  r_to  ar
  r_to  IP
@DROP:
  D_TO  top
@1:
  JMPS  @MAIN

@ABS:
  OR    top,top
  JNS   @1
@NEG:
  DEC   top
@NOT:
  NOT   top
  JMPS @MAIN

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

@_setpnt:
  MOV   [W],IP
  JMPS  @RETURN

@CALL:   ; (CALL
  ldip  w
  JMPS  @NEST

; MAIN  LOOP
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

_ZEX    DW @_DROP       ; 0;
  JE    @RETURN
  JMP   @MAIN

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

_EXECUTE DW @_DROP      ; EXECUTE
  JMPS  @NEST

_EXEC   DW @_DROP       ; EXEC
  jmps  @EXEC

_PERFORM   DW @_DROP    ; @EXEC
  jmps  @_DEFER

; LOGICAL      COMMANDS  XOR AND
_LIT    DW @_dup        ; lit
  ldip  top
  RET

_UADD   DW @_CALL       ; U+
  mov   W,DSP
  ADD   [W],top
  RET

_nip    DW @_CALL       ; nip
  inc   ax
  inc   ax
  ret

_and    DW @_DROP       ; -
  and   top,W
  JMPS  @MAIN

_xor    DW @_DROP       ; -
  xor   top,W
  JMPS  @MAIN

_SUB    DW @_DROP       ; -
  SUB   top,W
  JMPS  @MAIN

@_WARY:
  SHL   top,1
@_BARY:
  skipa
_add    dw @_drop
@Add:
  ADD   top,W
  JMPS  @MAIN

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