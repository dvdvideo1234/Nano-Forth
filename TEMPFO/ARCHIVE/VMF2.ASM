; AX IS DATA STACK REGISTER  AND ALTERNATIVE STACK REGISTER
; SP IS STACK REGISTER  AND ALTERNATIVE DATA STACK REGISTER
; BX IS INSTRUCTION POINTER
; DX IS DATA TOP REGISTER
; BP IS LOCAL STACK FRAME REGISTER

locals  @@
pd  equ dword ptr
pw  equ word  ptr
pb  equ byte  ptr

XSKIPCX MACRO
        DB 0B9H
      ENDM

XSKIPCL MACRO
        DB 0B1H
      ENDM

XSKIPDI MACRO
        DB 0BFH
      ENDM

XC    MACRO
        XCHG  AX,CX
      ENDM

X     MACRO
        XCHG  AX,SP
      ENDM

XDUP  MACRO
        X
        PUSH  DX
        X
      ENDM

XDROP MACRO
        X
        POP DX
        X
      ENDM

SJMP  MACRO  ADDRS
        jmp  SHORT ADDRS
      ENDM

next  MACRO
        jmp  _NOP
      ENDM

num   MACRO n
        dw n + n + 80h
      ENDM

WPUSH MACRO
       SJMP XCX_PUSH
      ENDM

XNEXT MACRO
       SJMP X_XNEXT
      ENDM

;-----------------


FNPAGE= 256
qqqqq = 0
ppppp = qqqqq

dstr2   macro   msg,flg
  local endstr
  db    endstr-$-1+flg
  db    msg
endstr  label   byte
  endm

dstr    macro   msg
     dstr2 msg,0
        endm

nf      macro   token
ppppp = $
  dstr2 token,0
  dw    qqqqq
qqqqq = ppppp
  endm

nfi     macro   token
ppppp = $
  dstr2 token,080h
  dw    qqqqq
qqqqq = ppppp
  endm


MyCseg  segment para  use16
        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg

        ORG 100H

T       Label byte

T_NOP   =    ($-T)/2
        DW   _NOP
T_EX    =    ($-T)/2
        DW   _EX
T_XCHG  =    ($-T)/2
        DW   _XCHG
T_CALL  =    ($-T)/2
        DW   _CALL
T_JUMP  =    ($-T)/2
        DW   _JUMP
T_SCALL =    ($-T)/2
        DW   _SCALL
T_SJUMP =    ($-T)/2
        DW   @SJUMP
T_EXIT  =    ($-T)/2
        DW   _EXIT

T_LOCOUT=    ($-T)/2
        DW   _LOCOUT
T_LGN   =    ($-T)/2
        DW   _LGN
T_LSN   =    ($-T)/2
        DW   _LSN
T_LIN   =    ($-T)/2
        DW   _LIN
T_LDN   =    ($-T)/2
        DW   _LDN
T_LAN   =    ($-T)/2
        DW   _LAN
T_LADDN =    ($-T)/2
        DW   _LADDN
T_LOCIN =    ($-T)/2
        DW   _LOCIN

T_LIT   =    ($-T)/2
        DW   _LIT
T_DLIT  =    ($-T)/2
        DW   _DLIT
T_HLIT  =    ($-T)/2
        DW   _HLIT
T_LITBM =    ($-T)/2
        DW   _LITBM
T_LITB  =    ($-T)/2
        DW   _LITB
T_LITB1 =    ($-T)/2
        DW   _LITB1
T_LITB2 =    ($-T)/2
        DW   _LITB2
T_LITB3 =    ($-T)/2
        DW   _LITB3

T_PUSH  =    ($-T)/2
        DW   _PUSH
T_POP   =    ($-T)/2
        DW   _POP
T_DUP   =    ($-T)/2
        DW   _DUP
T_DROP  =    ($-T)/2
        DW   _DROP
T_JAT   =    ($-T)/2
        DW   _JAT
T_RAT   =    ($-T)/2
        DW   _RAT
T_OVER  =    ($-T)/2
        DW   _OVER
T_SWAP  =    ($-T)/2
        DW   _SWAP

T_CONT  =    ($-T)/2
        DW   _CONT
T_TIMES =    ($-T)/2
        DW   _TIMES
T_RETF  =    ($-T)/2
        DW   _RETF
T_FROMF =    ($-T)/2
        DW   _FROMF
T_IFM   =    ($-T)/2
        DW   _IFM
T_IFND  =    ($-T)/2
        DW   _IFND
T_NEXT  =    ($-T)/2
        DW   _NEXT
T_FOR   =    ($-T)/2
        DW   _FOR

T_NOT   =    ($-T)/2
        DW   _NOT
T_XOR   =    ($-T)/2
        DW   _XOR
T_AND   =    ($-T)/2
        DW   _AND
T_PL2_DIV =    ($-T)/2
        DW   _PL2_DIV
T_PLUS  =    ($-T)/2
        DW   _PLUS
T_MINUS =    ($-T)/2
        DW   _MINUS
T_UMUL  =    ($-T)/2
        DW   _UMUL
T_UMSLSM =    ($-T)/2
        DW   _UMSLSM

T_GETA   =    ($-T)/2
        DW    _GETA
T_SETA   =    ($-T)/2
        DW    _SETA
T_AT     =    ($-T)/2
        DW    _AT
T_ATP    =    ($-T)/2
        DW    _ATP
T_TO     =    ($-T)/2
        DW    _TO
T_TOP    =    ($-T)/2
        DW    _TOP
T_CATP   =    ($-T)/2
        DW    _CATP
T_CTOP   =    ($-T)/2
        DW    _CTOP

T_ULESS? =    ($-T)/2
        DW    _ULESS?
T_ZLESS? =    ($-T)/2
        DW    _ZLESS?
T_ZERO?  =    ($-T)/2
        DW    _ZERO?
T_PLUS1  =    ($-T)/2
        DW    _PLUS1
T_PLUS2  =    ($-T)/2
        DW    _PLUS2
T_GETV2  =    ($-T)/2
        DW    _GETV2
T_SETV1  =    ($-T)/2
        DW    _SETV1
T_VAR    =    ($-T)/2
        DW    XVAR

        DW   0,0,_RETURN,_COUNT, 0,0,0,0
        DW   0,0,0,0,       0,0,0,0
        DW   0,0,0,0,       0,0,0,0
        DW   0,0,0,0,       0,0,0,0
        DW   0,0,0,0,       0,0,0,0
        DW   0,0,0,0,       0,0,0,0
        DW   0,0,0,0,       0,0,0,0
        DW   0,0,0,0,       0,0,0,0

_RETURN DB   T_LOCOUT,T_EXIT
_CFETCH DB   T_SETA,T_CATP,T_EXIT
_CFETCHP  DB T_SETA,T_CATP,T_GETA,T_EXIT
_COUNT  DB   T_SETA,T_CATP,T_GETA,T_SWAP,T_EXIT

_XCHG:  POP   CX
        PUSH  DX
        MOV   DX,CX
        NEXT
_LADDN: CALL  LCLS
        ADD   [BP+DI],DX
        SJMP  _XDROP
_LAN:   CALL  LCLS_DP
        LEA   DX,[BP+DI]
        RET
_LGN:   CALL  LCLS_DP
        MOV   DX,[BP+DI]
        RET
_LSN:   CALL  LCLS
        MOV   [BP+DI],DX
_XDROP: XDROP
        RET
_LIN:   CALL  LCLS
        INC   PW [BP+DI]
        RET
_LDN:   CALL  LCLS
        DEC   PW [BP+DI]
        RET
_RETF:  MOV   CX,BX
        POP   BX
        JMP   CX
_FROMF: JMP  BX         ; 31
_LIT:   CALL  LCLS_
XLIT:   XDUP
        MOV  DX,[BX]
        INC  BX
        INC  BX
        RET
_FUNC:  PUSH BX
        LEA  BX,[DI+2]
_LOCIN: CALL XLIT       ; PARAMETTERS
        XOR  CX,CX
        PUSH BP         ; & TEMPORARY
        MOV  BP,SP      ; LOCAL
        XCHG CL,DH      ; VARIABLES
        XOR  DI,DI
        SUB  DI,CX
        JE   @@2
        ADD  DI,DI
        LEA  DI,[DI+BP]
        MOV  SP,DI
        PUSH SI
        XCHG AX,SI
        REP  MOVSW
        XCHG AX,SI
        POP  SI
@@2:    XCHG CX,DX
        JCXZ @@9
@@3:    PUSH DX
        LOOP @@3
@@9:    JMP  _DROP

_GETV2: SCASW
        SCASW
_GETV:  MOV   CX,[DI+2]  ; CONSTANTS
        WPUSH

LCLS_DP:XDUP
LCLS:   MOV  DI,[BX]
        OR   DI,-256
        SHL  DI,1
        INC  BX
LCLS_:  POP  CX
        CALL CX
        SJMP _NOP
PRE_DR: X
        POP  DI
        X
        JMP  LCLS_

        SCASW
        SCASW
XDOES:  POP   CX         ; (DOES
        PUSH  BX
        MOV   BX,CX
        DB    0C9H
        SCASW
        SCASW
XVAR:   LEA   CX,[DI+2]  ; VARIABLES
        WPUSH

_UMSLSM:X               ; UM/MOD
        POP  DI
        XCHG DX,DI
        POP  CX
        XC
        CMP  DX,DI
        JNB  @@1
        DIV  DI
@@1:    XCHG DX,AX
        SJMP X_PNEXT
_UMUL:  X               ; UM*
        POP  CX
        XC
        MUL  DX
X_PNEXT:PUSH AX
X_CNEXT:XC
        SJMP  X_XNEXT
xqary:  shl  Dx,1
XWARY:  shl  DX,1
XBARY:  ADD  DX,DI
_PLUS2: INC  DX         ; 2+
_PLUS1: INC  DX         ; 1+    ; SJMP _NOP
        SJMP _NOP
_NEG:   DEC  BX
_NOT:   NOT  DX
        SJMP _NOP
_PL2_DV:X
        POP  CX
        ADD  DX,CX
        PUSH DX
        X
        RCR  DX,1
        SJMP _NOP
_AND:   CALL PRE_DR     ; AND
        AND  DX,DI
        RET
_OR:    CALL PRE_DR     ; OR
        OR   DX,DI
        RET
_XOR:   CALL PRE_DR     ; XOR
        XOR  DX,DI
        RET
_DUP:   X
        PUSH DX
        SJMP X_XNEXT
_CATRP: POP  DI
        MOV  CL,[DI]
        INC  DI
        PUSH DI
XCL_PUS:XOR  CH,CH
XCX_PUSH:  X
XD_PUSH:PUSH DX
XD_MOVE:MOV  DX,CX
X_XNEXT:X
_NOP:   MOV  CX,[BX]    ; NOP
X_next2:SHL  CL,1
        JC   X_EXI0
        MOV  CH,FNPAGE/256
        JNL  X_DO_TOK
X_EXI0: ADC  BX,1
X_EXI:  MOV  DI,CX
        jmp  pw [di]
X_DO_TOK:INC  BX
        MOV  DI,CX
        PUSH BX
        MOV  BX,[DI]
        JMP  _NOP

_CALL:  LEA  CX,[BX+2]  ; (CALL
        PUSH CX
_JUMP:  MOV  BX,[BX]    ; (JUMP
        NEXT

BOOT_REGS:

_LOCOUT:MOV  SP,BP      ; /LOC
        POP  BP
        SJMP _NOP
_dropex:xdrop
_EXIT:  POP  BX         ; EXIT
        SJMP _NOP

_GETA:  MOV  CX,SI      ; A@
        WPUSH
_JAT:   POP  DI         ; J
        POP  CX
        PUSH CX
        PUSH DI
        XSKIPDI
_RAT:   POP  CX         ; R@
        PUSH CX
        WPUSH
_B2W:   XCHG AX,DX
        CBW
        XCHG AX,DX
        NEXT
_HLIT:  MOV  CL,0
        MOV  CH,[BX]
        SJMP LTBZ
_LITBM: MOV  CH,-1      ; NBLIT
        XSKIPDI
_LITB:  MOV  CH,0
        MOV  CL,[BX]    ; BLIT
LTBZ:   INC  BX
        WPUSH
_POP:   POP  CX         ; POP
        WPUSH
_ATP:   MOV  DI,DX      ;  @+
        X
        PUSH PW [DI]
        X
        INC  DX
        INC  DX
        NEXT
_SETA:  MOV   SI,DX      ; A!
        SJMP   _DROP
_CTOP:  MOV   [SI],DL    ; C!A+
        INC   SI
        SJMP   _DROP
_TO:    MOV   [SI],DX    ;  !A
        SJMP   _DROP
_TOP:   MOV   [SI],DX    ; !A+
        INC   SI
        INC   SI
        SJMP   _DROP
_PUSH:  PUSH  DX         ; PUSH
_DROP:  X               ; DROP
        POP   DX
        XNEXT
_FOR:   MOV   CX,DX
        XDROP
        DEC   CX
        JL    @SJUMP
        PUSH  CX
        SJMP  @SKIP
_IFM:   OR    DX,DX      ; (-IF
        JNL   @SKIP
        SJMP  @SJUMP
_IFND:  OR    DX,DX      ; (#IF NON DROP
        JZ    @SJUMP
        SJMP  @SKIP
_SKIPB: XOR   CX,CX     ; (SKIPB
        MOV   CL,[BX]
        SJMP  WSKIP
_SCALL: LEA   CX,[BX+1]
        PUSH  CX
        SJMP  @SJUMP
_next:  POP   CX        ; (NEXT
        JCXZ  @SKIP
        DEC   CX
        PUSH  CX
@SJUMP: MOV   CL,[BX]   ; (SJUMP
        XC
        CBW
        XC
WSKIP:  ADD   BX,CX
@SKIP:  INC   BX
@_1:    NEXT

_ZERO?: SUB   DX,1       ; 0=
        SJMP _CARRY
_ULESS?:X               ; U<
        POP   CX
        PUSH  CX
        X
        SUB   CX,DX
        XSKIPDI
_ZLESS?:SHL   DX,1       ; 0<
_CARRY: SBB   DX,DX
        SJMP  @_1

_TIMES: DEC   DX
        JNL   _CONT
        POP   BX
        JMP   _DROP

_CONT:  LEA   CX,[BX-1]
        PUSH  CX
        SJMP  @_1

X4TH:
_EX:    POP   CX         ; (EX
XCALL:  PUSH  BX
XGOTO:  MOV   BX,CX
        SJMP  @_1

_SETV1: SCASW
_SETV:  MOV   [DI+2],DX    ; SETTERS
        JMP   _DROP


INIT_REGS:
DtoP=$
lastw = ppppp


;       db   tbp      ;brkpt
MyCseg  ends
        end  T

