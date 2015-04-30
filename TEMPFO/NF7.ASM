        INCLUDE  NF7.i0

; REGISTERS
; SI INSTRUCTION POINTER
; AX DATA STACK POINTER
; SP RETURN STACK POINTER
; BX DATA STACK TOP REGISTER
; DX DATA STACK NEXT REGISTER
; DI WORK REGISTER

ip  = si        ; for interpretter
w   = di
dsp = ax
rsp = sp
top = Bx
topL = BL
toph = Bh
NR   = DX
NRL  = DL
NRH  = DH
;ar   = bx       ; address  register
;tr   = dx       ; temp register
;trl  = dl

nbase = bx      ; for number utility
nacc  = di

; ADRESS REGISTER  ?
; BP   - NOT USED
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

  __DEFERO _EMIT,_@EMIT
  __DEFER  _SOURCE,_ETIB
  __DEFER  _ACCEPT,_ACC
;  __DEFER  _OK,0
;  __DEFER  _ERROR,0
  __DEFER  _OK,_@OK
  __DEFER  _ERROR,_@ERROR

  __CONST  _TBL,80H
  __CONST  _TIB,@TIB
  __CONST  _TBUF,@TBuf
  __CONST  _0,0
  __CONST  _BL,32

  __POINT  _INIT,_@_INI
  __VALUE  _HERE,FREEMEM
  __VALUE  _ETIB,0
  __VALUE  _LTIB,0
  __VALUE  _DICT,@VOCTOP
  __VALUE  _CNTC,0
  __value  _stat,0

;------------  MAIN LOOP  OUTER INTERPRETTER ----

SELF0:
  mov   bx,1000h     ; only 64k allocate
  mov   ah,4ah
  int   21h
@ABORT:
  MOV   RSP,@R_TOP
  MOV   DSP,@S_TOP
  CALL  @RETURN
  ; DW    _BRK ; ,_LIT,'?',_EMIT
  ;DW    _DEBUG
  ;__NAM "INIT !"

  DW    _INIT,_INIT,_TBL,_cstr
@MAINLP:
  DW _EVAL,_OK,_TIB,_TBL,_ACCEPT,_JUMP,@MAINLP

  __COL _EVAL                           ; EVAL
        DW _dup,to_+_LTIB,_add,to_+_ETIB
        ;,_DEBUG
        ;__NAM " BEFORE TOKEN"
@DoEval DW _TOKEN
        ;DW _DEBUG
        ;__NAM "AFTER TOKEN"
        DW _LDB,_BRK,_ZEX
        DW _CR,_SPACE,_TBUF,_STYPE
        DW _BRK

        DW _tbuf,_FIND
        DW _OPERATION,_PERFORM,_JUMP,@DoEval

  __COL _WAIT
        DW _SPACE,_LIT,5CH,_LIT,30,_ACCEPT,_DROP,_DROP,_EXIT

;------------------------------------
; LOGICAL      COMMANDS  XOR AND

  __XT  _3P,@_CALL      ; 3+
  inc   top
@2p:
  inc   top
  inc   top
  RET

; __XT  _1P,@_CALL      ; 1+
; INC   TOP
; RET

  __XT  _STBP,@_NIP     ; C!+
  MOV   [TOP],NRL
  INC   TOP
  RET

  __XT  _STP,@_NIP      ; !+
  MOV   [TOP],NR
  JMPS  @2P

  __XT  _LDP,@_DUP      ; @+
@LDP:
  MOV   NR,[Top]
  JMPS  @2P

@_FOR:
  NEG   TOP
@_PUSH:
  TO_R  TOP
@_DROP:
  OR    top,top
  to_r  W
@SETDROP:
  MOV   W,top
@TOPDROP:
  MOV   TOP,NR
NR_NIP:
  D_TO  NR
  RET

  __XT  _RSTBP,@_RST@   ; C!R+
  MOV   [W],TOPL
  INC   W
  JMPS  @TOPDROP

  __XT  _RLDP,@_RLD@    ; @R+
  MOV   TOP,[W]
  W2
  RET

  __XT  _ASTR,@_RLD@    ; (STR
  MOV   TOPL,[W]
  inc   top
  ADD   top,W
  SKIPA

  __XT  _XCHG,@_RST@    ; XCHG
  XCHG  TOP,W
  RET

; __XT  _RST,@_RST
; MOV   [W],TOP
; W2
; JMPS  @TOPDROP

  __XT  _DROP,@DROP     ; DROP

  __XT  _OVER,@OVER     ; OVER

  __XT  _DUP,@_CALL     ; dup
@TOPDUP:
  TO_D  NR
  MOV   NR,TOP
  RET

  __XT  _SWAP,@_CALL    ; SWAP
  XCHG  TOP,NR
  RET

  __XT  _Wstr,@_2P_DUP  ; STR
  MOV   TOP,[TOP-2]
  RET

  __XT  _LIT,@_DUP       ; LIT
  MOV   TOP,[IP]
  wiP2
  RET

  __XT  _CSTR,@_1P_DUP  ; CSTR
  DEC   TOP
  JMPS  @LDB

  __XT  _DLDB,@_DUP     ; DUP C@
  SKIPA

  __XT  _LDB,@_CALL     ; C@
@LDB:
  MOV   TOPL,[TOP]
  MOV   TOPH,0
  RET

  __XT  _LD,@_CALL      ; @
  MOV   TOP,[TOP]
  RET

  __XT  _LPAR,@_state   ; [`

  __XT  _and,@_NIP      ; and
  and   TOP,NR
  RET

  __XT  _xor,@_NIP      ; xor
  xor   TOP,NR
  RET

  __XT   _SUB,@_SWAP_NIP; -
  SUB   TOP,NR
  RET

  __XT  _add,@_NIP      ; +
  ADD   TOP,NR
  RET

  __XT  _ZEQ,@_CALL     ; 0=
  SUB   top,1
@CF:
  cf_to top
  RET

  ;--------------------   IO  ---------------

  __XT  _ACC,@_CALL     ; RETURNS 2 PARAM
  PUSH  BX
  MOV   BX,DX
  POP   PW [BX]
  MOV   DI,0A00H        ; DOS ACCEPT FUNCTION NUMBER
  CALL  @DOS_DX
  INC   DX
  INC   DX
  MOV   BL,[BX+1]
  MOV   BH,0
  RET

  __XT  _@EMIT,@_SWAP_NIP     ; (EMIT
  MOV   DI,200h  ; dos function number EMIT
@DOS_DX:
  RCHG  DI
  INT   21H
  RCHG  DI
  RET

; __COL _ACC
;       DW _OVER,_ST,_ACCZ,_1P,_CSTR,_EXIT

;------------------------------------

_@_INI:
        DW  _HERE,_WSTR,_DPUSH
        DW  to_+_INIT
        DW  _LPAR,_0,to_+_LTIB,_EXIT

  __col _find                           ; FIND  with status
        DW _stat,_DOES,_SUB,_dict,_FND,_EXIT

  __XT _COLON,@_MAKER           ; :
        DW @NEST,_RPAR

  __XT  _SEMICO,@_COMMA
        DW _EXIT,_LPAR          ; ;`

  __XT _CLIT,@_COMMA
        DW _LIT,_COMMA          ; #,`

  __XT  _J,@_IJ
        DW 2

  __COL _LOOPS                  ; LOOPS
        DW _FOR,@@LP2
@@LP1   DW _J,_EXECUTE,_NEXT,@@LP1
@@LP2   DW _RDROP,_EXIT

  __XT  _NEXT,@NEXT             ; (NEXT
  __XT  _RDROP,@RDROP           ; RDROP
  __XT  _JUMP,@JUMP             ; (JUMP
  __XT  _SKIP,@SKIP             ; SKIP
  __XT  _ABORT,@ABORT           ; ABORT
  __XT  _EXIT,@RETURN           ; EXIT
  __XT  _EX,@EX                 ; EX
  __XT  _POP,@POP               ; POP
  __XT  _NIPX,@NIPX             ; NIP;

  __RVAR2 _XCOMMA               ; ;,
  __col  _COMMA                 ; ,
        DW _HEREX,_STP,_EXIT

  __COL _COMP_NUM               ; (NUM,
        DW _NUMBER,_CLIT,_EXIT

  __COL _NUMBER                         ; (NUMBER
        DW _cstr,_NUM,_??,_EXIT

  __COL _HEREX                          ; ;HERE
        DW _HERE,_EX,to_+_HERE,_EXIT

  __COL _ABORT?                         ; (A"
        DW _ASTR,TO_+_STAT,_ZEX,_ERROR,_ABORT
        ; ADDRESS OF ERROR MESSAGE IS IN _STAT

  __COL3 _ENTRYC                        ; =,    CODE,
  __COL3 _ENTRYH                        ; =H    HEADER
  __COL3 _ENTRY                         ; =:    ALIAS
        DW _XCOMMA,_HERE,_TOKEN?,_CSTR,_ADD,_ST,_TBUF,_DLDB,_3P
        DW _SKIP
  __COL   _DPUSH                        ; >DICT
        DW  _DICT,_MPUSH,To_+_DICT,_EXIT

  __COL4 _TOKEN?                        ; TOKEN?
  __COL4 _TOKEN                         ; TOKEN
  __COL4 _WORD                          ; WORD
  __COL4 _PARSE                         ; PARSE
        DW _XTOK?       ; IS IT A TOKEN IN THE BUFFER ?
        DW _BL          ; SPACE IS DELIMITER
        DW _XSETSTR     ; SET TEXT TO BUF AFTER PARSING

        DW _SOURCE
        DW _LTIB
;,_DEBUG
        ;__NAM "PARSE1"
        DW _PARS
        ;DW _DEBUG
        ;__NAM "PARSE2"
        DW to_+_LTIB
        DW _BRK
        DW _EXIT

  __RVAR _XSETSTR                       ; ;S!
        dw _TBUF,_MSTR,_nipx

  __RVAR3 _XTOK?                        ; ;TOK?
  __COL3  _Z??                          ; #??
  __COL3  _??                           ; ??
        DW _DLDB        ; DUP C@
        DW _ZEQ         ; LOGICAL INVERT -> #0 IS OK
        DW _ABORT?      ; ZERO ? 0 / FALSE IS OK
     __NAM " ? "
        DW _EXIT

@_state:
  call  @does3
  dw to_+_stat,_exit

;  __COL _BCOMMA,_BCOMMAL          ; C, >C,
;        DW _HEREX,_STBP,_EXIT

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
  RCHG  nacc
@@numini:
  DEC   AX
  Xor   nacc,nacc       ; ACCUMULATOR
@@setbas:
  xor   ah,ah
  mov   nbase,ax
  INC   NBASE
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
;  SI   CX   DI       di    si  cx

  __XT  _PARS,@_PARAM3           ;= (PARS
  XCHG  CX,DI
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
  JMPS  @PUSH_sC+1

  __XT  _num,@_PARAM2           ;= (ATOI
  INT 3
  to_r  ax
  MOV   AL,10   ; BASE 10
  CALL  @NUM
  r_to  AX
  jmps  @push_DC

  ;----------------  MEMORY  -------------------

  __XT  _MPUSH,@_PARAM3 ; TOP OF DICTIONARY   IN DI
  ADD   SI,CX                ; AFTER NAME ADDRESS
  STD                        ; BACKWARDS
  CMPSB                      ; PREPARE FOR DIRECTION
  REP   MOVSB                ; NAME  MOVE
  inc   di
  TO_D  DI
  RET

  __XT  _MSTR,@_PARAM3        ; (S!
  to_r  di
  MOV   [DI],CL
  INC   DI
  REP   MOVSB   ; NAME  MOVE
  MOV   PB [DI],'`'
  r_to  cx
@push_DC:
  DUP2  DI,CX
  RET

  ; ------------ SEARCH  --------------
  __XT  _FND,@_PARAM3            ; (FIND
  CALL  FNDZ
@PUSH_SC:; RETURNS SI CX
  DUP2  SI,CX
  RET
FNDZ:
  MOV   BX,SI
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
  MOV   SI,BX
  mov   cl,[di]
  jcxz  xfnd?
  INC   CX
  repe  cmpsb
  jNZ   Nfnd
YFND:
  MOV   SI,[DI]
  inc   cx
xFND?:
  ret

MFND:       ; COMPILE MODE SEARCH
  push  di
  inc   pb [BX]
  call  Zfnd
  dec   pb [BX]
  pop   di
  jCXZ  Dfnd
  RET

dfnd:
  call  ZFND
  inc   cx
  inc   cx
  ret

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


;------------  MAIN LOOP  INNER INTERPRETTER ----
;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

@_RLD@:
  TDUP
  MOV   TOPH,0
@_RST@:
  R_TO  CX
  XCHG  CX,W
  CALL  CX
  SKIPA

@PUSHW3:
  W2
@PUSHW2:
  W2

@PUSHW:
  to_r  W
  JMPS  @1


@_IJ:
  MOV   W,[W]
  ADD   W,rSP
  SKIPA

@_CONS3:
  W2
@_CONS2:
  W2
@_CONS:
  MOV   W,[W]
@_VAR:
  tDUP
@ADR:
  MOV   top,W
  JMP   @MAIN

@_VAR3:
  W2
@_VAR2:
  W2
  skipA

@over:
  TO_R  NR

; RETURN STACK COMMANDS  POP PUSH XCHG

@POP:
  r_to  W
  JMPS  @_VAR

@DROPX:
  POP   IP
  JMPS  @DROP

@_SETVAR3:
  W2
@_SETVAR2:
  W2
  SKIPA

  __XT  _ST,@_DROP
@_SETVAR:
  MOV   [W],top
@DROP:
  tDROP
  JMPS  @1

@_SWAP_NIP:
  XCHG  NR,TOP
  SKIPA

@NIPX:
  R_TO  IP
  SKIPA

@_NIP:
  CALL  W
@NIP:
  D_TO  NR
  JMPS  @1

@_2P_DUP:
  INC   TOP
@_1P_DUP:
  INC   TOP
@_DUP:
  tDUP
@_CALL:
  CALL  W
@1:
  JMPS  @MAIN

  __XT  _FOR,@_FOR        ; (FOR
  JS    @SKIP
  MOV   IP,[IP]

@RDROP:
  r_to  W
  JMPS  @MAIN

  __XT  _IF,@_DROP       ; (IF
  JE    @JUMP

@SKIP:
  INC   SI
  INC   SI
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

  __XT  _ZEX,@_DROP       ; 0;
  JNE   @MAIN
  SKIPA

@_setpnt:
  MOV   [W],IP
  JMPS  @RETURN

@_PARAM1:
  TDUP
@_PARAM2:
  TDUP
@_PARAM3:
  PUSH  IP
  MOV   CX,NR
  D_TO  SI
  XCHG  W,TOP
  CALL  TOP
  CLD
@2DROPX:
  DROP2 TOP,NR
  JMPS  @RETURN

  __XT  _PUSH,@_PUSH       ; PUSH
  JMPS  @MAIN

; CONTROL      COMMANDS

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

  __XT  _EXECUTE,@_DROP      ; EXECUTE
  JMPS  @NEST

  __XT  _EXEC,@_DROP       ; EXEC
  jmps  @EXEC

  __XT  _PERFORM,@_DROP    ; @EXEC
  jmps  @_DEFER

@_WARY:
  SHL   top,1
@_BARY:
  ADD   top,W
  JMPS  @MAIN

; MAIN  LOOP

  __XT _rPAR,@_state              ; ]

  __XT _does,@_var2
@DOES3:
  W2
@DOES2:
  W2
@DOES:
  tDUP
  MOV   top,W
@EX:
  r_to  W
@NEST:
  to_r  IP
@LBL:
  to_r  W
@RETURN:
  r_to  IP
@MAIN:
  MOV   W,[IP]
  wiP2
  JMP   [W-2]

;

;freemem:
;  DW ENDMEM-FREEMEM-2
;  __ENTRY  '=:',_ENTRY
;  DB 0
;EndMem:
;
;lastw = ppppp
;
;MyCseg  ends
;        end  Start
;
;-----------------------------------------------
;  TEST
;

   __RVAR _XDROP
        DW _DROPX

  __CONST _LF,10
  __CONST _1H,16
  __CONST _1,1
  __CONST _LT0,'0'

@ABS:
  OR    TOP,TOP
  JNS   @MAIN
@NEG:
  DEC   TOP
@NOT:
  NOT   TOP
  JMPS  @MAIN

  __XT  _ABS,@ABS
  __XT  _NEG,@NEG
  __XT  _NOT,@NOT

  __XT  _DROPX,@DROPX

; __XT  _RLDP,@_RLD        ; @R+
;       JMP  @PUSHW2

  __XT  _BRK,@_CALL
  INT 3
  RET

  __XT  _I,@_IJ
        DW 0

  __COL _DEBUG
        DW _CR,_I,_HEXP,_RP,_HEXP,_SP,_HEXP
        DW _HERE,_HEXP,_ASTR,_STYPE
        DW _WAIT,_CR,_EXIT


  __COL _TWICE
        DW _I,_PUSH,_EXIT

  __COL _HEXP
        DW _XSPC,_LIT,256,_DIV,_TWICE,_1H,_DIV,_TWICE,_DIGP,_EXIT

  __COL _ALPHA  ; : ALPHA  LF OVER U< 7 AND + '0 + ;
        DW _DUP,_LF,_ULESS,_ZEQ,_LIT,7,_AND,_ADD,_LT0,_ADD,_EXIT

  __COL  _SGN?
        DW _DUP,_SGN,_ZEX,_LIT,'-',_EMIT,_ABS,_EXIT

  __COL _ZSKIP
        DW _DUP,_ZEQ,_ZEX,_DROP,_RLDP,_DROPX

  __COL _HP
        DW _XSPC,_SGN?,_SKIP
  __COL _HP2
        DW _LF,_DIV,_ZSKIP,_HP2,_SKIP
  __COL _DIGP
        DW _ALPHA,_EMIT,_EXIT


  __COL _LOCATE
        DW _TOKEN?,_FIND,_1,_AND,_Z??,_EXIT

;  __RVAR2 _XEMIT
  __RVAR2 _XSPC
  __COL   _SPACE
       DW _BL,_EMIT,_EXIT


  __COL _CR
       DW _STRTYPE
       DB 2,13,10
       DW _0,TO_+_CNTC,_EXIT

 __COL _@OK
       DW _STRTYPE
       __NAM " Ok"
       DW _CR
       DW _STRTYPE
       __NAM "> "
       DW _EXIT

  __COL _@ERROR
       DW _CR,_TBUF,_STYPE,_SPACE,_STAT,_STYPE,_CR,_ABORT

 __COL3 _STRTYPE
 __COL3 _STYPE
 __COL3 _TYPE
       DW _ASTR
       DW _CSTR
       DW _XDROP,_LOOPS,_CSTR,_EMIT,_EXIT

  __XT _DIV,@_CALL
  XOR   CX,CX
  RCHG  CX
  RCHG  NR
  DIV   TOP
  RCHG  TOP
  RCHG  CX
  RET

  __XT _MUL,@_NIP
  RCHG  TOP
  MUL   NR
  RCHG  TOP
  RET

  __XT  _add2D,@_CALL   ; +2/
  ADD   TOP,NR
  MOV   NR,TOP
  RCR   TOP,1
  RET

  __XT  _ULESS,@_NIP    ; U<
  SUB   NR,TOP
  JMP   @CF

  __XT  _SGN,@_CALL     ; 0<
  SHL   TOP,1
  JMP   @CF

  __XT  _RP,@_DUP
  MOV   TOP,RSP
  RET

  __XT  _SP,@_DUP
  MOV   TOP,DSP
  RET

;  w2
;@nupw:
;  to_D  W
;  JMP   @MAIN

;  __XT  _TUCK,@_DROP
;@TUCKW:
;  CALL  @PUSH_DC
;  JMPS  @ADR


;@2m:
;  DEC   top
;@1m:
;  DEC   top
;  JMPS  @1

;@_RDLD:
;  TO_R  TOP
;@_RLD:
;  TDUP
;  R_TO  TOP
;@_LD@:
;  to_r  W
;  MOV   W,top
;  MOV   top,[W]
;  RET

;_RLDBP  DW @_RLD        ; C@R+
;  XOR   topH,topH
;@PUSH1P:
;  INC   W
;  JMPS  @PUSHW

freemem:
  DW ENDMEM-FREEMEM-2
  __ENTRY  '=:',_ENTRY
  __ENTRY  'CR',_CR
  __ENTRY  '=,',_ENTRYC
  __ENTRY  'EMIT',_EMIT
  __ENTRY  ':',_COLON
  __ENTRY  ';`',_SEMICO
  __ENTRY  '[`',_LPAR
  __ENTRY  ']',_RPAR
  __ENTRY  ',',_COMMA
  __ENTRY  '@',_LD
  __ENTRY  '!',_ST
  __ENTRY  '+',_ADD
  __ENTRY  '-',_SUB
  __ENTRY  'H.',_HEXP
  __ENTRY  '.',_HP
  __ENTRY  'SGN?',_SGN?
  __ENTRY  'HERE',_HERE
  __ENTRY  'OK.',_OK
  __ENTRY  '''',_LOCATE
  __ENTRY  'ALPHA',_ALPHA
  DB 0

EndMem:

lastw = ppppp

MyCseg  ends
        end  Start

;____________________________________________


;-----------------------------------------------

NF7      OUT     1725   1-30-15   5:38p
NF7      SN      4968   4-14-15   3:48p
NF7      SN1     4968   4-14-15   5:01p
NF7      SN2     5579   4-15-15  12:55p
NF7      SRT     1683  12-11-14  10:55p

