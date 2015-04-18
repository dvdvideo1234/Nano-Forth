; LIST OF CHANGES
;
; ALIGN 4
;  AX  -  TOP
;  SI  =  DSTACK
;  DI  =  AREG
;  DX  =  BREG
;  BX  =  IPTR
;  SP  =  STACK
;
;  BP, CX, TEMPORARY USAGE
;
;  _U<:    CMP [SI],AX  ;
;  _A2*:   SHL DI,1 ;
;  _A2/C:  RCR DI,1 ;
;  _0:     _DUP ; MOV AX,0
;  _-1:     _DUP ; MOV AX,-1
;
;  _B<>S  XCHG DX,SI ;
;  _B<>A  XCHG DX,DI ;
;  _ANEXT:  MOV  BP,[BX] ; SKIP1; JMP  CS:[BP] ;
;  _A++:   LEA  DI,[DI+WS] ;
;  _A1+:   LEA  DI,[DI+1] ;
;
;  _B+:    LEA  DI,[DI+[SLOT]] ;
;  _SKIP1:  LEA  BX,[BX+2] ;
;  _LIT!:  MOV [BX],AX ; _DROP ; SKIP1 ;
;  _LIT:   _DUP ; MOV AX,[BX] ; SKIP1 ;
;
;  1
;  _UNEXT:
;  _EXIT:  RET     ;
;  _0;:    MOV CX,AX ; CXZ IF _DROP ; EXIT ; THEN ;
;  _?FOR:  OR AX,AX ; NZ, IF, ; CS-DROP ; _DROP ; JMP 'ADR ; THEN,  1- ; FOR ;
;  _;::    ----------------
;  _FOR:   MOV CX,AX ; _DROP ; BEGIN, ;
;
;  2
;  _IF:    JE   'ADR ;
;  _-IF:   JNM  'ADR ;
;  _JUMP:  JMP  'ADR ;
;  _CALL:  CALL 'ADR ;
;  _NEXT:  DEC CX ;  JNE 'ADR ;
;  _IFC:    JNC   'ADR ;
;
;  3
;  _DUP:   LEA  SI,[SI-WS]  ;  MOV [SI],AX ;
;  _DROP:  LODSW   ;
;  _SWAP:  XCHG AX,[SI] ;
;  _PUSH:  PUSH AX ; _DROP ;
;  _POP:   _DUP ; POP  AX ;
;  _IND:   _POP ; PUSH AX ;
;
;  4
;  _OVER:  _DUP ;  MOV  AX,[SI+WS] ;
;  _NIP:   LEA  SI,[SI+WS] ;
;  _B:     _DUP ; MOV AX,DX ;
;  _B!:    MOV  DX,AX ; _DROP ;
;  _A:     _DUP ; MOV AX,DI ;
;  _A!:    MOV  DI,AX ; _DROP ;
;
;  5
;  _-!B:   MOV BP,DX ; MOV CS:[BP-2],AX ; LEA DX,[BP-2] ; _DROP ;
;  _@B+:   _DUP ; MOV BP,DX ; LEA DX,[BP+2] ; MOV AX,CS:[BP] ; _DROP ;
;  _C!B:   OUT AL,DX ; _DROP ;
;  _C@B:   _DUP  ;  IN  AL,DX  ; MOV AH,0  ;
;  _!B:    OUT AX,DX ; _DROP ;
;  _@B:    _DUP  ;  IN  AX,DX ;
;
;  6
;  _!A:    MOV [DI],AX ; _DROP ;
;  _@A:    _DUP  ;  MOV  AX,[DI]
;  _@+:    _@ ; WINC ;
;  _!+:    STOSW ; _DROP ;
;  _@:     A! ;  @A ;
;  _!:     A!  ;  !A   ;
;
;   7
;  _C!A:   MOV [DI],AL ; _DROP ;
;  _C@A:   _DUP  ;  MOV  AL,[DI]  ; MOV AH,0  ;
;  _C@+:   _C@ ; 1INC ;
;  _C!+:    STOSB  ; _DROP ;
;  _C@:     A!  ;  C@A ;
;  _C!:     A!  ;  C!A   ;
;
;   8
;  _NEGATE:  NOT ; 1+ ;
;  _+:     ADD [SI],AX  ;  _DROP ;
;  _+C:    ADC [SI],AX  ;  _DROP ;
;  _-:     SUB [SI],AX  ;  _DROP ;
;  _M*;    B! ; IMUL DX ;
;  _M/MOD: MOV BP,AX ; _DROP ; IDIV BP ;
;
;   9
;  _AND:   AND [SI],AX  ;  _DROP ;
;  _XOR:   XOR [SI],AX  ;  _DROP ;
;  _OR:    OR  [SI],AX  ;  _DROP ;
;  _INV:   NOT AX ;
;  _+*:    TEST DI,1 ; IF ; ADD AX,[SI] ; THEN ; 2/C ; A2/C ;
;  _-/:    A2* ; 2*C ; U< ; IFC ; SUB AX,[SI] ; A1+ ; THEN ;
;
;  10
;  _2*:    SHL AX,1 ;
;  _2/:    SAR AX,1 ;
;  _2/C:   RCR AX,1 ;
;  _2*C:   RCL AX,1 ;
;  _1+:    INC  AX ;
;  _1-:    DEC  AX ;
;
;   :NONAME ; LITERAL IF UBTIL AGAIN ABORT" ."
; : META ' ' 2 CELLS + ! ; \ AS IN META 0BRANCH IF

locals  @@
pd  equ dword ptr
pw  equ word  ptr
pb  equ byte  ptr

PushReg  MACRO
        jmp  _PushAx
      ENDM
SWAPREG MACRO
         JMP _SWAPAX
        ENDM
DROPREG MACRO
         JMP XDROP
        ENDM
SJMP  MACRO  ADDRS
        jmp  SHORT ADDRS
      ENDM
next  MACRO
        jmp  _next
      ENDM
num   MACRO n
          dw n + n + 80h
      ENDM
; X     MACRO
;         xchg sp,bp
;       ENDM
;
;-----------------
TRACE_OFF MACRO
        mov  PB  _EX,097h
      ENDM

TRACE_ON MACRO
        mov  PB _EX,0B9h
      ENDM
;-----------------

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

FRST = 0-4*1024-4*4
MyCseg  segment para  use16
        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg

        ORG 100H

Start   Label byte
        SJMP   INITF1   ; 0
INITV   DW     _INIT    ; 2
RESETV  DW     _ABORT   ; 4
DEBUGV  DW     0        ; 6
COMPWV  DW     TCOMMA   ; 8

CrSP  dw   0
CrSS  dw   0

Uv0     dw   00000 ;TWAKE
UvNextT dw   Uv0
UvCrSP  dw   FRST-1024
UvS0    dw   FRST-1024
UvR0    dw   FRST
UvBASE  dw   10
UvCURS  DW   0
        DW   25 DUP (0)

INITF1: call XTOF_INI
        CALL VEXEC
        DB   INITV-START

XABORT: CALL XRESET
        CALL VEXEC
        DB   RESETV-START

XTOF_INI:
        MOV  SI,81H
        XOR  BX,BX
        MOV  BL,[SI-1]
        MOV  [BX+SI],BH
        mov  bx,1000h
        mov  ah,4ah
        int  21h
        MOV  AH,15
        CALL _INT_10
        MOV  VPAG,BH
;       TRACE_OFF                ; !!!

Xreset: cli

;       TRACE_ON                ; !!! START TRACE
        POP  BX
        MOV  DI,PW USERV
        mov  bp,[DI+UvR0-Uv0]
        mov  sp,[DI+UvS0-Uv0]
        PUSH BX
        xor  BX,BX
        sti
        CLD
        RET

_DNEGAT:POP  DI
        POP  AX
        NOT  AX
        NOT  BX
        INC  AX
        JNE  @@1
        INC  BX
@@1:    PUSH AX
        JMP  DI

XRET4TH:PUSH  SI
popR:   MOV   SI,[BP]
        LEA   BP,[BP+2]
        RET

XFROMF: JMP   SI
; STORAGE LOCATIONS FOR USER VARIABLES

; MTOP                   ;RESIDENT PROGRAMS
; MPTR                   ;MACRO
; SPTR                   ;STRING STACK
;
; HEADERLESS EXECUTION CODE GOES HERE

xbp:    int  3
        JMP  _next

XDOP:   POP   DI
_DOP1:  lodsw
        mov   Cx,8000h
        sub   Cx,DI
        add   Bx,Cx
        DB    0BFH  ; MOV DI,
X3TOR:  POP  CX
        POP  AX
        JMP  SHORT _3TOR

xfor:   ; OR    BX,BX
        DEC   BX
        ; je    XBR_DR
        jL    XBR_DR
        LODSW
        MOV   CX,SI
_3TOR:  SUB   BP,6
        MOV   [BP+4],AX ;  PUSH  AX
_2TOR:  MOV   [BP+2],CX ;  PUSH  SI
        DB    0B9H
XTOR:   DEC   BP
        DEC   BP
X_TOR:  MOV   [BP],BX
        dropREG
XTIMES: DEC   BX
        JNL   XCONT
        POP   BX
        SJMP  XEXIT
XCONT:  PUSH  BX
        LEA   BX,[SI-2]
        SJMP  XTOR
xnext:  MOV   CX,[BP]
        JCXZ  XLEAVE
        DEC   CX
        MOV   [BP],CX
        MOV   SI,[BP+2]
        next

X0LESS: SHL   BX,1
XCARRY: SBB   BX,BX
        JMP   _NEXT
XZBRAN: OR    BX,BX
        je    XBR_DR
        JMP   XPC2_DR

XDO:    pop   dI
        cmp   Bx,dI
        JNE   _DOP1
XBR_DR: POP   BX
XBRAN:  mov   si,[si]
        JMP   _next
XPLOOP: ADD   [bp+0],BX
        jno   XBR_DR
XLEAVDR:POP   BX
XLEAVE: add  bp,4
XEXIT:  mov  si,[bp+0]
xrdrop: inc  bp
        inc  bp
        JMP SHORT _NEXT

XLOOP:  inc   word ptr [bp+0]
        jno   XBRAN
        Jmp  short XLEAVE
jsr4:   scasw
jsr3:   scasw
jsr2:   scasw
jsr1:   scasw
JSR:    LEA  BP,[BP-2]
        MOV  [BP],SI
XJMP:   mov  si,di
XPC2PLS:INC  SI
XPC1PLS:INC  SI
        JMP  SHORT _next
XOF:    POP  AX
        XCHG BX,AX
        CMP  AX,BX
        JNZ  XBRAN
        JMP  SHORT XPC2_DR

XQDUP:  OR   BX,BX
        JZ   _NEXT
XDUP:   PUSH BX
        JMP  SHORT _next
xAbs:   or   bx,bx
        jns  xnegat2
XNEGATE:NEG  BX
        DB   0B9H
XNOT:   NOT  BX
XNEGAT2:JMP  SHORT _next
XAND:   POP  AX
        AND  BX,AX
        JMP  SHORT _next
XORE:   POP  AX
        OR   BX,AX
        JMP  SHORT _next
XXORX:  POP  AX
        XOR  BX,AX
        JMP  SHORT _next
XSPgT:  push BX
        mov  bx,sp
        jmp  short _next
XRPgT:  MOV  ax,bp
        jmp  short _pushax
XSPST:  MOV  SP,BX
        DB   0B9H
XRPST:  MOV  BP,BX
        jmp  short xDROP
XSTRP:  NEG  BX
XSTR:   POP  AX
        POP  CX
        ADD  CX,BX
        PUSH CX
        SUB  AX,BX
        swapReg

xsubt:  neg  bx
XPLUS:  POP  AX
_plus:  ADD  BX,AX
        JMP  SHORT _next

dovar2: scasw
dovar1: scasw
DOVAR:  JMP  SHORT DOVARZ
XPC2_DR:LODSW
xdrop:  pop  bx
        JMP  SHORT _NEXT
        scasw
        scasw
_does:  LEA  BP,[BP-2]
        MOV  [BP],si
        POP  SI
DOVARZ: scasw
_PUSHDI:xchg AX,DI
_PushAx:PUSH BX
_SwapAx:xchg BX,ax
_next:  lodsw
_ex:    xchg di,ax
        jmp  pw [di]
; XCOMMA
        JMP  DEBUGerr

X0EXIT: OR    BX,BX
        POP   BX
        JNE   _NEXT
        JMP  XEXIT

XSTORE2:POP  [BX]
        inc  bx
        inc  bx
XSTORE1:POP  [BX]
        DROPREG
XSTOREA:   ; L!
        POP  [BX+2]
        jmp  short xstore1
XXORTO: POP  AX
        XOR  [BX],AX
        DROPREG
XM1STOR:MOV  AX,-1
        DB   0B9H
XZSTOR: XOR  AX,AX
        MOV  [BX],AX        ; NOT USED YET
        DROPREG
XCSTOR: POP  AX
        MOV  [BX],AL        ; NOT USED YET
DDD:    DROPREG

XXCHG:  XCHG  BX,[BP]
        NEXT
XSWAP:  POP  AX
        PushReg
XOVER:  POP  AX
        PUSH AX
        PushReg
XROT:   POP  CX aX      ; ax cx bx->
        PUSH CX         ; cx bx ax
        PushReg
XMROT:  POP  aX cX      ; cx ax bx->
        PUSH bx CX      ; bx cx ax
        swapReg
XDUP2:  Pop  aX
        push ax
        PUSH BX
        push ax
        NEXT
XTUCK:  POP  AX
        PUSH BX
        PUSH AX
        NEXT
XRFR:   PUSH  BX
        MOV  BX,[BP]
        JMP  XRDROP
xnip:   pop  ax
        next
XDROP2: POP  BX
        JMP  XDROP

XM2STO: DEC  pw [BX]
XM1STO: DEC  pw [BX]
        DROPREG
XP2STO: INC  pw [BX]
XP1STO: INC  pw [BX]
        DROPREG
@MYARY: MOV  AX,OFFSET Uv0
        PUSH AX
MYARY:  SHL  BX,1
MYARYB: JMP  XPLUS

DO2CON2:SCASW
DO2CON1:SCASW
DO2CON: SCASW
DO2CON0:PUSH BX
        MOV  BX,DI
XTWOAT: PUSH [BX+2]
xFETCH: MOV  BX,[BX]
        NEXT

XTWOATA:PUSH  [BX]     ; TO FADR
        inc   bx
        inc   bx
        Sjmp  xfetch
XCOUNT: INC  BX
        PUSH BX
        DEC  BX
XCAT:   MOV  BH,[BX]
xhi:    xchg bh,bl
xlo:    MOV  BH,0
        NEXT

SUB4TH: LEA   BP,[BP-2]
        MOV   [BP],si
J4th:   POP   SI
        NEXT

_Zero:  push bx
        XOR  bx,BX
        next
_m1:    push bx
        XOR  bx,BX
        db   0b9h
        DEC  BX
XTWOMI: DEC  BX
XONEMI: DEC  BX
_0mi:   NEXT

XUCHK:  POP  AX
        SUB  AX,BX
        JC   LCHK2
        JMP  SHORT LCHK1
XCHK:   POP  AX
        SUB  AX,BX
        DB   0B9H
XZCHK:  OR   BX,BX
        JS   LCHK2
LCHK1:  JZ   LCHK3
        INC  DI
        DB   0B1H
LCHK2:  DEC  DI
LCHK3:  MOV  AL,[DI+3]
        CBW
        SWAPREG
XSCAT:  INC  BX
        PUSH BX
        LEA  DI,[BX-4]
        JMP  SHORT LCHK3

X2PWR:  XOR  AX,AX
        INC  AX
        PUSH AX
XSHIFT: OR   BX,BX
        MOV  CX,BX
        POP  BX
        JNS  X2STAR_
        NEG  CX
        shR  BX,CL
        NEXT
X2SLS:  SHR  BX,1
        NEXT
X2STAR: MOV  CL,1
X2STAR_:SHL  BX,CL
        NEXT
XUMSTAR:POP  AX
        MUL  BX
        PUSH AX
        MOV  BX,DX
        NEXT

XRAT:   CALL _XSKPS
        MOV  BX,SI
        RET
XRATPW: CALL _XSKPS
        LODSW
        XCHG  AX,BX
        RET
XRATPB: CALL _XSKPS_0
        LODSB
        XCHG  AX,BX
        RET
XSKPSW: CALL _XSKPS
        mov  bx,si
        lodsW
        add  si,ax
        RET
XSKPS:  CALL _XSKPS_0
        mov  bx,si
        lodsb
        add  si,ax
        RET
_XSKPS_0: xor  ax,ax
_XSKPS: POP  CX
        push bx
        xchg si,[bp]
        CALL CX
X_CO:   XCHG SI,[BP]
        next

XSWAP2: POP  cX aX DI
_SWAP2Z:PUSH cX BX DI
        swapreg

XOVER2: POP  cX aX DI
        PUSH DI aX  ;cX BX DI ;swapreg
        JMP  SHORT _SWAP2Z

XDMINUS:CALL _DNEGAT
XDPLUS: POP  AX
        POP  DX
        POP  CX
        add Cx,Ax
        adC bx,Dx
        PUSH CX
        next

XUMSLSM:POP  dX
        XOR  AX,AX
        CMP  DX,BX
        JNB  @@1
        pop  AX
        DIV  BX
        PUSH DX
@@1:    swapreg

xTary:  shl  bx,1
x5ary:  ADD  DI,bx
xqary:  shl  bx,1
XWARY:  shl  BX,1
XBARY:  ADD  BX,DI
        JMP  ADRP2

xdabs:  or   bx,bx
        jns  no_abs
XDNEGAT:CALL _DNEGAT
no_abs: NEXT

XI:     XOR   DI,DI
_ILOOP: mov   ax,[bp+0+DI]
        sub   ax,[bp+2+DI]
        PushReg

xcntdo: pop  ax
        add  bx,ax
        jmp  _pushax

_CALL:  SCASW
        CALL  DI
        NEXT

_MOVER: POP  CX DI AX
        push cs
        pop  es
        XCHG CX,BX
        CALL BX
        DROPREG

XSTRPLS:POP  AX
        MOV  DI,[BX]
        ADD  [BX],AX
        LEA  DI,[BX+DI+2]
        JMP  SHORT _XSTRST
XSTRSTO:POP  AX
        MOV  DI,BX
        STOSW
_XSTRST:PUSH DI
        XCHG AX,BX

XCMOVE: CALL _MOVER
_move1: XCHG SI,AX
        rep  MOVSB
        XCHG SI,AX
        CLD
_movex: RET
XMOVE:  CALL _MOVER
SMARTM: CMP  DI,AX
        JBE  _MOVE1
        JMP  SHORT _MOVEU

XCMOVUP:CALL _MOVER
_MOVEU: ADD  DI,CX
        ADD  AX,CX
        DEC  AX
        DEC  DI
        STD
        JMP  SHORT _MOVE1

_FILLER:PUSH  BX
        SCASW
        MOV   BX,[DI]
xfill:  POP     CX
        POP     DI
        push cs
        pop  es
        xchg ax,bx
        REP  stosb
        DROPREG

_SCANER:POP  AX
        XCHG AX,BX
        POP  CX
        POP  DI
        push cs
        pop  es
        MOV  DX,CX
        CALL BX
        JE   @@1
        MOV  CX,DX
@@1:    INC  CX
        SUB  DX,CX
        XCHG AX,DX
        SWAPREG

XSCANW: CALL _SCANER
        REPNE SCASW
        RET
XSCANB: CALL _SCANER
        REPNE SCASB
        RET

XSCANL: CALL _SCANER
        PUSH SI
        OR   BX,BX
        XCHG AX,BX
        MOV  SI,DI
        JCXZ @@3
@@2:    MOV  DI,BX
        PUSH CX
        CALL _STREQU
        POP  CX
        LOOPNE  @@2
@@3:    POP  SI
        RET

XMTEXT: POP  DI
        POP  AX
        push cs
        pop  es
        MOV  CX,BX
        XCHG AX,SI
        CALL _STRCMP
        XCHG AX,SI
        JE   @@1
        SUB  AX,CX
        XCHG AX,BX
        DEC  DI
        MOV  AL,[BX-1]
        SUB  AL,[DI]
        CBW
@@1:    XCHG AX,CX
        SWAPREG

XSCANI: POP  AX
        XCHG AX,SI
        XOR  CX,CX
        XCHG CX,BX
        JCXZ @@1
@@2:    MOV  BL,[SI]
        LEA  SI,[SI+BX+1]
        LOOP @@2
@@1:    XCHG AX,SI
        SWAPREG

XMINS@: mov  ax,[di+2]
        DB   0B1H
XALLOTM:POP  AX
        NEG  AX
_MINS@: ADD  PW [BX],ax
        MOV  AX,[BX]
        SWAPREG

X@PLUS: mov  AX,[di+2]
_@PLUS: ADD  AX,[BX]
X2CHG:  XCHG PW [BX],AX
        SWAPREG

XATSWP2:POP  AX
        XCHG AX,BX
        JMP  SHORT X2CHG
X@PLSTO:POP  AX
        OR   AX,AX
        JS   _MINS@
        JMP  SHORT _@PLUS

xUNpack:XOR   ax,AX
        xchg  Al,bh
        PUSHREG
xpack:  pop   ax
        xchg  bl,bh
        mov   bl,al
        next

CALL_D2:PUSH BX
        CALL PW [DI+2]
        POP  BX
        NEXT

XaLPHA: XCHG AX,BX
        XOR  AH,AH
        CMP  AL,10
        JB   @@1
        ADD  AL,7
@@1:    ADD  AL,'0'
        SWAPREG

VEXEC:  POP  CX
        PUSH BX
        XCHG CX,BX
        MOV  CL,[BX]
        MOV  CH,1
        MOV  BX,CX
XPERF:  MOV  bX,[BX]
xqexec: or   bx,bx
        JZ   X_set
XEXEC:  XCHG AX,BX
        POP  BX
_ex2:   jmp  _ex

xSetUv: mov  pw userv,bx
x_set:  dropreg

XBlit:  lodsb
push_al:xor  AH,ah
        db   0b1h
XLIT:   LODSW
        PUSHREG

?NONAM1:POP  AX
        POP  DI
        PUSH DI
        SCASW
        JNE  _PSH2
        POP  AX
        PUSH [DI]
_psh2:  NEXT

ExecAt2:scasw
ExecAt1:scasw
ExecAt: scasw
ExecAt0:MOV  cx,[DI]   ;@addr
        jcxz _psh2
        xchg ax,cx
        JMP  short _ex2

XVBLK:  INC   BX            ; : VBLK  DUP
        JZ    @@1           ;     -1 = IF DROP EXECAT EXIT ELSE DUP
        scasw               ;      0 = IF DROP EXECAT1 EXIT ELSE
        dec   BX            ;           EXECAT2
        JNZ   execAt1       ;          THEN THEN ;
@@1:    POP   BX            ;
        jmp   short execAt  ;

xqcomm: inc  bx
        pop  bx
        jz   xEXEC
        JMP  SHORT XEXQCOM  ;
XNONA2: OR   BX,BX
        JE   _PSH2
        CALL ?NONAM1
XNONAME:SCASW               ;
        PUSH BX             ;
        MOV  BX,[DI]        ;
XEXQCOM:mov  di,PW userv
        mov  cx,[UvStat]
        jcxz xEXEC
        CALL VEXEC
        DB   COMPWV-START  ; COMPILE

xnamCf: mov   al,[bx]
        and   ax,31
        add   bx,ax
ADRP3:  inc   bx
        jmp   ADRp2

X_FIND:
  MOV   DX,SI
@@1:
  pop   si
  inc   si
  jne   @@2
  push  bx
  xchg  ax,si
  jmp   short @@8
@@2:
  dec   si
  je    @@1
@@3:
  pop   cx
  cmp   si,cx
  je    @@3
  push  cx
@@4:
  mov   di,bx
  mov   cx,31
  call  _strequ1
  jnz     @@5
  test    al,20h
  jz      @@7
@@5:
  mov     si,[si]
  or      si,si
  jnz     @@4
  jmp     short @@1
@@7:
  pop   cx
  inc   cx
  jne   @@7
  inc     si
  inc     si
  push  si
  cbw
  stc
  mov   al,ah
  rcl   ax,1
@@8:
  MOV   SI,DX
  SWAPREG       ; _FIND_

_strequ:
  mov   cx,255
_strequ1:
  lodsb
  and     cx,ax
  cmp     cl,[di]
  jne     _l5
  inc     di
_strcmp:
  repe    cmpsb
  jz      _l6
_l5:
  add     si,cx
_l6:  ret

X_W:  mov   di,bx ; _WORD ;
      pop   bx            ; >IN
      pop   ax            ; TIB
      pop   dx            ; DELIMITTER
      push  di            ; WHERE TO PLACE WORD
      push  si            ;
      xor   si,si         ;
      xchg  ax,si         ;
      inc   di            ;
      DEC   BX            ;
@@1:  INC   BX            ;
      mov   al,[si+bx]    ;
      or    al,al         ; ZERO ?
      je    @@3           ;
      cmp   al,dl         ;
      je    @@1           ;
@@2:  inc   ah            ;
      stosb               ;
      inc   bx            ;
      mov   al,[si+bx]    ;
      or    al,al         ;
      je    @@4           ;
      cmp   al,dl         ;
      jNe   @@2           ;
      inc   bX            ;
      JMP   SHORT @@4     ;
@@3:  INC   AH            ;
@@4:  mov   al,0          ;
      stosb               ;
      pop   si            ;
      pop   di            ;
      push  di            ;
      mov   [di],ah       ;
      NEXT  ; _WORD_      ;

XC2I:   ;
  mov   cx,bx   ; = 0
  pop   Dx      ; -1
  pop   di      ; base
  pop   AX
  PUSH  SI
  XCHG  AX,SI
  inc   si      ; skip counter
  cmp   byte ptr [si],'-'
  jne   @@1
  inc   si
  inc   Dx
@@1:
  push  Dx      ; sign
  call  convn
@@2:
  mov   al,[si-1]
  cmp   al,':'
  je    @@3
  cmp   al,'/'
  ja    outitoc
  cmp   al,','
  jb    outitoc
@@3:
  PUSH  SI
  call  convn
  MOV   PW [BP],SI
  POP   DX
  INC   DX
  SUB   pw [bp],DX ; dbl
  jmp   short @@2
outitoc:
  dec   si
  sub   [bp+2],si
  pop   ax
  pop   SI
  push  cx
  PUSHREG

digit?: xor   ah,ah
        cmp   al,'9'
        jbe   okdig
        and   al,0dfh
        cmp   al,'A'
        jb    notdig
        sub   al,7
okdig:  sub   al,'0'
        jb    notdig
        cmp   ax,di
        cmc
notdig: ret
convn:  lodsb
        call  digit?
        jc    notdig
        push  ax
        call  _mul
        pop   ax
        ADD   CX,AX
        JNC   CONVN
        INC   BX
        jmp   short convn
_mul:   xchg  ax,cx
        mul   di
        xchg  cx,ax
        xchg  dx,ax
        xchg  bx,ax
        OR    AX,AX
        JE    @@1
        mul   di
        add   bx,ax
@@1:    ret
setvar2:scasw
setvar1:scasw
setvar: scasw
setvar0:MOV   [DI],BX
        DROPREG
DOCON2: SCASW
DOCON1: SCASW
DOCON:  SCASW
DOCON0: MOV  AX,[DI]
        PUSHREG
XUVAR@@:call  doUvar
        MOV   DI,[DI]
        jmp   short doCon0
XUVAR@: scasw
XUVAR@0:call  doUvar1
        jmp   short doCon0
XtoUVAR:SCASW
XtoUVR: call  doUvar
        jmp   short Setvar0
X@UVAR: call  doUvar
        xchg  ax,di
        pushReg
doUVAR2:scasw
doUVAR1:scasw
doUVAR: mov   di,[di+2]
DoUvar0:add   di,offset Uv0
USERV   =    $-2
        ret
TONAME:
  DEC DI
  mov   cx,31
  DEC DI
  MOV AX,CX
  MOV BX,DI
@@1:
  DEC   BX
  INC   AH
  CMP   PB [BX],32
  JBE   @@4
  mov   al,[bx-1]
  XOR   AL,AH
  SHL   AL,1
  je    @@3
@@2:
  loop  @@1
@@4:
  XOR  bx,BX
  INC  CX
@@3:
  RET

XFNAME:
  MOV DI,BX
  PUSH DI
  CALL  TONAME
  JE    TONAME2
  CALL  TONAME
  JE    TONAME2
  CALL  TONAME
  JE    TONAME2
  POP  DI
  next
toname2:
  DEC   BX
  POP   AX
  INC   DI
  push  bx
  SUB   AX,DI
  swapreg

XSWPSTO:SUB BX,DADR+4
;XSWPSTO:
        POP   DI
        MOV   [DI],BX
        DROPREG
XWCOUNT:MOV   AX,[BX]
        INC   BX
        INC   BX
        PUSHREG
XMULT2: POP   AX
        IMUL  BX
        PUSH  AX
        MOV   BX,DX
        NEXT
XDIVMOD:POP   AX
        CWD
        IDIV   BX
        PUSH  DX
        SWAPREG
XDIV:   POP   AX
        CWD
        IDIV  BX
        SWAPREG
XMOD:   POP   AX
        CWD
        IDIV  BX
        MOV   BX,DX
        NEXT

        ; -----------  IO  PRIMITIVES  vvvvvvvvvvv
  NF '''EMIT'
VEMIT DW  ExecAt2,SETVAR1,DOVAR,0

_HND_GT:mov  DI,offset handles
cnt_GT0:mov  cx,di
        mov  di,[di]
        shl  di,1
        add  di,cx
        mov  Ax,[DI]
        RET
_HND_AT:scasw
        CALL cnt_GT0
        xchg cx,di
        DEC  pw [di]
        PUSHREG
_HND_TO:add  di,4
        inc  pw [di]
        CALL cnt_GT0
        mov  [DI],BX
        DROPREG

XOPEN:  MOV DX,BX
        MOV AX,3D02H
        DB  0B9H
XCLOSE: MOV AH,3EH
XDOS1:  INT 21H
        JNC @@1
        NOT AX
@@1:    SWAPREG
XQKEY:  MOV  AH,01h
        INT  016h
        MOV  AL,0FFH
        JNE  @@1
        INC  AX
@@1:    CBW
        PUSHREG

XQKEY2: MOV  AH,0Bh
        INT  021h
        CBW
        PUSHREG

_key2:  CALL _hnd_GT
        XCHG AX,BX
@@4:    mov  cx,1
        mov  DI,LASTCH
        mov  dx,OFFSET LASTCH
        mov  ah,3fh
        int  21h
        OR   ax,Ax
        jz   @@2
        mov  Ax,LASTCH
        cmp  al,' '
        jae  @@1
        cmp  al,1Ah
        je   @@2
        cmp  al,0dh
        je   @@1
        cmp  al,0Ah
        jNe  @@3
        CMP  DI,0DH
        JE   @@4
        MOV  AL,0DH
        RET
@@3:    mov  al,' '
@@1:    ret
@@2:    JMP  XDROPH1

  NF 'IOV'
ioV     DW  DOVAR
JKEY    DW      _key1
JEMIT   DW      _emit1

  NF 'IOV!'
        DW  JSR,TCODESEMI
_gs_ke: CALL _DOES
        DW  TTWOAT,IOV,TSTORE2,TEXIT

 NF 'SIO'
STDIO:  DW   _gs_ke,_key1,_emit1

  NF 'FIO'
FILEIO: DW   _gs_ke,_key2,_emit1

  NF 'MIO'
MEMIO: DW   _gs_ke,_key1,_emit2

xblank: mov  al,' '
        push bx
        xchg ax,bx
XEMIT:  call PW [jemit]
        CALL OUTC_1P
        DROPREG
X?EMIT: TEST BL,-32
        JNZ  XEMIT
        MOV  BL,'.'
        SJMP XEMIT

_EMIT1: MOV  DL,BL
        MOV  AH,2
        INT  021h
        ret

_EMIT2:
        CALL SUB4TH
        DW VEMIT,TRETF
        ret

XKEY:   PUSH BX
        call PW [jkey]
        SWAPREG

 NF 'BIOS-KEY'
_BKEY:  DW   _CALL
_KEY1:  MOV  AH,0
        INT  016h
        ret

_INT_10:PUSH  BP
        INT   10H
        POP   BP
        RET
_V_PAGE:PUSH  AX
        MOV   AH,15
        CALL  _INT_10
        POP   DX
        RET

CURSIZE:POP   AX
        MOV   AH,BL
        MOV   CH,1
        XCHG  AX,CX
        CALL  _INT_10
        DROPREG

GETCURS:PUSH  BX   ;CALL  _V_PAGE
        MOV   BH,VPAG
        MOV   AH,3
        CALL  _INT_10
        PUSH  DX
        MOV   BX,CX
        NEXT

XY_GOTO:POP   DX
        MOV   DH,BL
        MOV   BH,VPAG
        MOV   AH,2  ; CALL  _V_PAGE
        CALL  _INT_10
        DROPREG

XCLRSCR:PUSH  BX
        MOV   BH,ATTR
        MOV   DH,24
        MOV   DL,79
        MOV   AX,600H
        XOR   CX,CX
        CALL  _INT_10
        DROPREG

        ; -----------  IO  PRIMITIVES  ^^^^^^^^^^^^^^^

X?SS:   MOV     AX,Ss
        DB    0B9H
X?CS:   MOV     AX,cs
        PUSHREG

XC@SWAP:POP   DI
@@2:    MOV   AL,[DI]
        DEC   BX
        CMP   DI,BX
        JNC   @@1
        XCHG  AL,[BX]
        STOSB
        JMP   @@2
@@1:    DROPREG

XADRSP2: POP PW [BX]
ADRP2:   INC  BX
ADRP1:   INC  BX
         NEXT
XADRSP1: POP  AX
         MOV  [BX],AL
         JMP  SHORT ADRP1
CFCH_P1:  XOR  AX,AX
         MOV  AL,[BX]
         PUSH AX
         JMP  SHORT ADRP1
FCH_P2:  PUSH PW [BX]
         JMP  SHORT ADRP2

XTOAND: POP AX
        AND [BX],AX
        DROPREG
XTOORE: POP AX
        OR  [BX],AX
        DROPREG
XPSTORE:POP  AX
        ADD  [BX],AX
        DROPREG

XBYE:  MOV AL,BL
  MOV AH,4CH
  INT 21H

; CODEMARK - END OF CODE

; COMPILATION WORDS

;--------------------vvvvvvv  CONTROL vvvvvvv--------------
ppppp = $
  dw    81h,qqqqq,XEXIT
qqqqq = ppppp

  NF '0;'
EXIT0  DW X0EXIT

 nf 'EXIT'
texit   DW   XEXIT      ; EXIT

 NF ';4TH'
tretf   DW   XRET4TH    ; R4TH>

 NF 'BYE'
BYE     DW   XBYE

 NF '(BR'
tbran   DW   XBRAN      ; BRANCH

 NF '(0BR'
tzbran  DW   XZBRAN     ; 0BRANCH

 NF '(OF'
tof     DW   XOF        ; (OF

 NF 'EX'
TRpAt   DW   X_CO       ; SI<>[RP]
tex_tr  DW   XEX_TR
        DW   JSR_TR

 NF '(FOR'
tfor    DW   XFOR       ; (FOR

 NF '(NEXT'
tnext   DW   XNEXT      ; (NEXT

 NF '(?DO'
T?DO        DW   XDOP      ;  (DO

 NF '(DO'
tdo     DW   XDO       ; (?DO

 NF 'CNTDO'
tcntDo  DW   xcntdo     ; CntDo

 NF '(LP'
tloop   DW   XLOOP      ; (LOOP

 NF 'CONT'
 DW  XCONT

 NF 'TIMES'
 DW  XTIMES

 NF '(+LP'
tploop  DW   XPLOOP     ; (+LOOP

 NF 'LEAVE'
tleave  DW   XLEAVE     ; LEAVE

 NF '4TH>'
tfromf  DW   XFROMF     ; 4TH>

 NF 'BREAK.'
tbp     DW   xbp        ; brkPnt

;--------------------^^^^^^^  CONTROL ^^^^^^--------------

;--------------------VVVVVV MEMORY  VVVVVVVVVVVV---------------
;  NF '/STR'     ; STRING OPERATIONS  ( A L N - A+N L-N)
  NF 'STR-'      ; A - ADDRESS
  DW XSTR        ; L - LENGTH
                 ; N - SIZE TO CHANGE WITH
  NF 'STR+'      ; ( A L N - A-N L+N)
  DW XSTRP        ;,X2STR,X1STR

 NF 'CSTR'                    ; ( A - A+1 C )
tCouNT  DW  XCOUNT               ; C - CHAR  0..255

 NF  'BSTR'      ; ( A - A+1 B )
TSCOUNT DW   XSCAT  ; B - BYTE  -128..127

  NF 'STR'      ; GETSTR
TWCOUNT:
TSTR  DW  XWCOUNT

  NF 'STR!'     ; SETSTR
 DW XSTRSTO

  NF 'STR+!'    ; PLUSSTR
 DW XSTRPLS

  NF 'ON'
    DW   XM1STOR    ; -1!

  NF 'OFF'
tZstor DW  XZSTOR   ; 0!

 NF '@SWAP'
T@SWP2  DW   XATSWP2    ; OVER @ -ROT SWAP!
 NF '!'
tstore1 DW   XSTORE1    ; !
 NF '2!'
TSTORE2 DW   XSTORE2    ; 2!
 NF '@'
tfetch  DW   xfetch     ; @
 NF '2@'
TTWOAT  DW   XTWOAT     ; 2@
; NF 'FA@'
;        DW   XTWOATA    ; FA
; NF 'FA!'
;        DW   XSTOREA    ; TO FA
 NF 'C!'
tcstore DW   XCSTOR     ; C!

 NF 'C@'
tcat    DW   XCAT       ; C@

 NF '1-!'
        dw   xm1sto     ; DUP @ 1- SWAP !
 NF '1-!@'
tM1at   DW   XMINS@,1   ; 1-!@
 NF '2-!'
        dw   xm2sto     ; 2-!
 NF '2-!@'
tM2at   DW   XMINS@,2  ; 2-!@
 NF '1+!'
        dw   xp1sto     ; 1+!
 NF '@1+!'
tAtP1   DW   X@PLUS,1   ; @1+!
 NF '2+!'
        dw   xp2sto     ; 2+!
 NF '@2+!'
tAtP2   DW   X@PLUS,2   ; @2+!
 NF '@+!'
        DW X@PLSTO
 NF '@-!'
        DW XALLOTM
 nf 'XOR!'
txorTo  DW   xxorto     ; XOR!
 NF 'AND!'
TOand   DW   XTOAND       ; AND!
 NF 'OR!'
        DW   XTOORE       ; OR!
 NF '+!'
tpstore DW   XPSTORE    ; +!

 NF 'CMOVE'
        DW   XCMOVE     ; <CMOVE
 NF 'CMOVE>'
        DW   XCMOVUP    ; CMOVE>
 NF 'MOVE'
        DW   XMOVE      ; CMOVE
 NF 'FILL'
tFILL   DW   XFILL      ; MOVE

  NF '-TEXT'
  DW XMTEXT

  NF 'SCLST'
  DW XSCANL

  NF 'INDSCAN'
  DW XSCANI

  NF 'SCANB'
  DW XSCANB

  NF 'SCAN'
  DW XSCANW

 NF 'ERASE'
 DW _FILLER
 DB 0

 NF 'BLANK'
  DW _FILLER
  DB ' '

 NF 'REVERCE'
  DW   XC@SWAP

 NF 'SWAP!'
tswapsto DW XSWPSTO

  NF 'C@+'       ; STREEM @ OPERATIONS
TADRP1  DW CFCH_P1

  NF '@+'       ; STREEM @ OPERATIONS
TADRP2  DW FCH_P2

  NF 'C!+'       ; STREEM ! OPERATIONS
TADRSP1  DW XADRSP1

  NF '!+'       ; STREEM ! OPERATIONS
TADRSP2  DW XADRSP2

;----------------^^^^^^^^^ MEMORY  ^^^^^^^^^^-------------------

;---------------vvvvvvvv  MATH   vvvvvvvv-------------------
 NF 'NEGATE'
TNEGATE DW   XNEGATE    ; NEGATE

 NF 'DNEGATE'
tdnegat DW   XDNEGAT    ; DNEGATE

  NF 'SHIFT'
  DW XSHIFT

  NF '2^'
  DW X2PWR

  NF '/MOD'
  DW XDIVMOD

  NF 'MOD'
  DW XMOD

  NF '/'
  DW XDIV

 NF 'M*'
TMUL DW XMULT2

 NF '*'
 DW JSR,TMUL,TDROP,TEXIT

  NF 'ABS'
  DW XABS

  NF 'DABS'
  DW XDABS

  NF '(CLSC'
  DW XCLRSCR

 NF 'ALPHA'
 DW XALPHA

 NF '2/'
   DW   X2SLS      ; 2/

 NF '2*'
T2STAR  DW   X2STAR     ; 2*

 NF 'UM/MOD'
        DW   XUMSLSM    ; UM/MOD

 NF 'UM*'
        DW   XUMSTAR    ; UM*

 NF 'AND'
tand    DW   XAND       ; AND

 nf 'XOR'
txor    DW   XXORX      ; XOR

 NF 'COM'
tNOT    DW   xNOT       ; NOT

 NF 'PACK'
        DW XPACK
 NF 'LOW'
TLOW    DW XLO
 NF 'UNPACK'
        DW XUNPACK
 NF 'OR'
        DW   XORE       ; OR
 NF '+'
tplus   DW   XPLUS      ; +
 NF 'D+'
        DW   XDPLUS     ; D+
 NF '-'
tsubt   DW   XSUBT      ; -
 NF 'D-'
        DW   XDMINUS    ; D-
 NF '1-'
tonemi  DW   XONEMI     ; 1-
 NF '2-'
ttwomi  DW   XTWOMI     ; 2-
 NF '1+'
tonepl  DW   ADRP1     ; 1+
 NF '2+'
TTWOPL  DW   ADRP2     ; 2+

;---------------^^^^^^^^  MATH  ^^^^^^^^^-------------------

; --------------------------IO  ------------------vvvvvvv

  NF 'CURSOR'
SET_CURS DW CURSIZE
TO_CURS  DW XY_GOTO
GET_CURS DW GETCURS

  NF 'GOTOXY'
  DW XY_GOTO

 NF 'DERR'
 DW DOCON2,SETVAR1,DOVAR
DERR DW 0,0,0,0,0

 NF 'SCRH'
 DW DOCON1,SETVAR
SCRH DW -1

  NF 'ORDER#'
TORDER: DW DOVAR2,_HND_TO,_HND_AT
      DW  1,AFORTH+6,0,0,0,0,0,0,0
                 DW  0,0,0,0,0,0,0,0

 NF 'OPEN'
TOPEN DW XOPEN

 NF 'EOS-OFF'
OPENED DW JSR,ZR,TOEOF,TEXIT

 NF 'FOPEN'
OPENF: DW  JSR_TR,TBLWORD,TONEPL,TOPEN,TDUP,TZLESS,tsabrt
     dstr ' OPEN ERROR '
 DW tex_tr

 NF 'CLOSE'
TCLOSE: DW XCLOSE
TCLOSEF: DW  CALL_D2,XDROPH1

   NF 'EOS-ON'
TCLOSED: DW JSR,MO,TOEOF,TEXIT

        nf 'TYPE'
tTYPE:  dw   jsr_TR,tFOR,@@2
@@1:    dw   tCOUNT,t?emit,tNEXT ; ,@@1  NOT NESESERY NOW
@@2:    dw   TDROP,tex_tr

 NF 'EXPECT'
texpect:dw   jsr_TR,TDUP2,TCNTDO,T?DO,@@22
@@1:    Dw   TKEY,TLOW,TDUP,TI
        Dw   TCSTORE,blc
        Dw   TULESS,tzeq,TZBRAN,@@15
        Dw   TI,TCAT,temit,one
        dw   tbran,@@21
@@15:   Dw   TI,TCAT,cr,tof,@@16  ; cr?
        dw   ti,trot,tsubt,tleave ; I rot - leave
@@16:   dw   bs,tof,@@20             ;backsp?
        dw   tover,ti,tsubt,tZbran,@@1
        dw   bs,tdup,temit,tSPACE,temit         ; bs blank bs
        dw   mo,tbran,@@21
@@20:   dw   tdrop,zr
@@21:   Dw   TpLOOP,@@1
@@22:   Dw   ToSpan,tdrop,tex_tr

  nf 'EOF?'
EOF?:  dw DOCON1
TOEOF  dw SETVAR
LASTCH DW 0

 NF 'SPACE'
tSPACE  DW   xblank     ; BLANK

 NF '?KEY'
TQKEY   DW   XQKEY      ; ?KEY

 NF 'KEY'
TKEY    DW  XKEY

 NF '?EMIT'
T?EMIT   DW  X?EMIT

 NF 'EMIT'
TEMIT   DW  XEMIT

; ------------------  IO  -----------------^^^^^^^

; -------------TEXT INTERPRETTER   -------------vvvvvvvvvvv
  nf    'C>N'
cfname  dw XFNAME

dovoc:
  call _does-2
  dw toCont,texit

doDef:
  call _does-1
  dw toCurr,texit

  NFI '('
  DW JSR,TLIT,')',TWORD,TDROP,TEXIT  ;

  NFI '-->'
NEXTBLK  DW JSR,ZR,BLK@,TONEPL,TOSTREEM,TEXIT  ;

  NF 'EXECUTE'
XEXECUT  DW JSR,TTOR,TEXIT

  NF 'IO!'
IO? DW JSR,BLK@,TNOT,TZBRAN,IO?2,STDIO,TEXIT
IO?2 DW FILEIO,TEXIT

  NF 'OK?'
TOK DW JSR,BLK@,TZBRAN,TOK2,TRPAT,TCR,TEXIT
TOK2 DW T_SDOT
     dstr ' Ok'
     DW TCR,TRPAT,TSPACE,TEXIT

  nf 'CR'
tCR:    dw   jsr,cr,temit,lf,temit,ZR,TOoUTC,texit

  nf    'REFILL'
REFILL  dw jsr_TR,tib@,Tlit,80,texpect
        DW ZR,toToIn,tib@,span@,tplus,tZStor,tex_tr

  NF   '1LINE'
LINE1 DW JSR,TOK,REFILL,TRPAT,AINT,TEXIT

  NF '(CLOSE'
ZZCLOSE  DW JSR
        DW   HND,TZBRAN,@@1,HND+4
        DW   TCLOSE,TDROP,HND
        DW   TZEQ,TZBRAN,@@1
        DW   ZR,TOBLK,STDIO
@@1:    DW   TCLOSED,TEXIT

  NF 'HANDLES'
HND: DW DOCON2,_HND_TO,_HND_AT
handles dw   0,0,0,0,0,0,0,0,0
xDROPH1:CALL SUB4TH
        DW   ZZCLOSE,TRETF
        MOV  al,0dh
        RET

  NF ';TI'
XINTER: DW JSR
        DW TRFR,BLK@,TTOR,TOIN@,TTOR,TIB@,TTOR,TTOR,TRPAT
        DW TRFR,TOTIB,TRFR,TRFR,TOSTREEM,TEXIT

  NF ';RBUF'
XBUF DW JSR,TPOP,TRPGT,TROT,TSUBT,TRPGT,TOVER
     DW TRPST,TPUSH,TSWAP,TPUSH,TRPAT,TPOP,TRPST,TEXIT

  NF 'EVAL'
TEVAL:  DW JSR,XINTER,ZR,TOSTREEM,ZR,TOTIB,AINT,TEXIT

  NF 'LOAD'
TLOAD:  DW JSR,XINTER,ZR,TSWAP,TOSTREEM,AINT,TEXIT

 NF 'NBLK'
TVBLK DW XVBLK,TIB@,TIB@,TNOP

 nf  '?,'
tqcomm: dw xqcomm,XNONA2,XNONAME

 NF 'EXEC'
texec   DW   XEXEC      ; EXEC

 NF '?EXEC'
aqexec  DW   xqexec     ; ?EXEC

 NF 'LOCATE'
apos0 DW JSR,TBLFIND,TQDUP,TZEQ,TSABRT,'?'*256+1,TEXIT

 NF 'PERFORM'
tperf   DW   XPERF      ; PERFORM

 NF '>STREAM'
TOSTREEM  DW JSR,TOBLK,TOTOIN,TEXIT

  NF '''ERR'
erINI DW  ExecAt1,SETVAR,0

  nf 'F83'      ; INIT INTERPRETTER & COMPILER
TF83  DW JSR_TR,decim,Aforth,aforth+2
      DW TLIT,ACTOI2,ACTOI+2
      DW TLIT,tblfind2,tblfind+2
      DW TLIT,TZLIT2,TZLIT+2
      DW TLIT,AINT1,TLIT,AINT+2,TSTORE1
      DW ZR,DADR+2
      DW  tex_tr

  nf 'FORTH'
Aforth: dw DoVoc,dodef,dovar,lastw,0

 NF ''''
apos DW JSR,APOS0,TDROP,TEXIT

 NF '(find'
T_FIND DW X_FIND

 NF 'FIND'
tfind: dw jsr
   DW    TROT,TTOR,MO,TMROT ; ttor,mo,TORDER,TWCOUNT
   DW    TFOR,@@1,TWCOUNT,TFETCH,TSWAP,TNEXT
@@1: DW  TDROP,CONT@,TFETCH,trfr,t_FIND,TQCOMM+2,TEXIT

 nf '-FIND'
tblfind  DW  ExecAt1,SETVAR,tblfind2

 NF '(-FIND'
tblfind2 DW JSR_TR,TBLWORD,TORDER,TWCOUNT,TFIND,tex_tr

 NF '(WORD'
T_W DW X_W

 NF 'BLWORD'
TBLWORD DW JSR,BLC,TWORD,TEXIT

 NF 'WORD'
TWORD:   DW  JSR_TR,BLK@,TVBLK,TOin@,Here,t_W,toTOin,tex_tr

 NF 'INTERPRET'
Aint: DW EXECAT,AINT1   ; DEFER WORD

 NF '(INT'
AINT1:  DW XJMP,TBLfind,TQdup,TzBRAN,@@2,tQcomm,Aint
@@2  dw actoi,TZLIT,Aint,TEXIT

  NF 'CLOSALL'
ZCLOSE: DW JSR
@@1    dw  HND,TZBRAN,@@2,TCLOSEF,TBRAN,@@1
@@2    DW  TEXIT

  nf 'ABORT'
ABORT: DW XABORT

  NF 'QUIT'
TQUIT: DW  XJMP,LOADKBD,TQUIT,TEXIT

  NF 'SEVAL'
SEVAL  DW JSR,XINTER,TOBLK,IO?,TLIT,90,XBUF,TOTIB,OPENED
SEVAL2 DW LINE1,EOF?,TZLESS,TZBRAN,SEVAL2,OPENED,TEXIT

  NF 'FLOAD'    ; : FLOAD FOPEN  -1 SEVAL ?IO ;
LOADF: DW  JSR,HND,BS,TSUBT,TZEQ,TSABRT
     dstr ' TOO MUCH FILES '
  DW  OPENF,HND+2,MO,SEVAL,IO?,texIt

  NF 'KBD'      ;  : KBD  0 SEVAL ?IO ;
LOADKBD DW JSR_TR,ZR,SEVAL,IO?,tex_tr

  nf    'NUM'
Actoi  DW  ExecAt1,SETVAR,ACTOI2

  NF '(NUM'
Actoi2:  dw jsr_TR,tdup,tcount,tplus,ttor
  dw  base@,mo,Tdup,ttor,zr,TC2I,TONEPL
  dw    tzbran,@@1,tdnegat
 @@1: dw trfr,toDbl,tRfr,TSABRT
     dstr 'Not Found'
  DW Tex_tr

  nf 'DECIMAL'
decim dw xbase
      db  10,0
TC2I: DW XC2I

  nf 'HEX'
      dw xbase
      db  16

  nf 'OCTAL'
      dw  xbase
      db  8

  nf 'BINARY'
      dw  xbase
      db  2
; -------------TEXT INTERPRETTER   -------------^^^^^^

; ------------  COMPILER  --------------------vvvvvvvv
  NFI 'C"'
  DW JSR,TBLWORD,TONEPL,TCAT,LITERAL,TEXIT

  NF 'LINK+'            ; : LINK+ HERE TO >< , ;
  DW JSR,HERE,T@SWP2,TCOMMA,TEXIT

   NF ',S"'
STRCOMP   DW JSR,TLIT,'"',TWORD,TSTRCOM,TEXIT

   NFI 'A"'
   DW DOIMMD,TSABRT,STRCOMP

   NF '(ABRT'
tSABRT: dw  jsr_TR
        dw  tSKPs,tswap,tZbran,@@3
        DW  TCR,here,N_ID,BLK@,TOSCR,TOIN@,TOCSP
        DW  tsDot,TCR,ABORT
@@3:    Dw  tdrop,tex_tr

   NFI '"'
   DW DOIMMD,TLITSTR,STRCOMP

   NF '("'
tLITSTR:dw  jsr,tSKPs,texit

   NFI '."'
   DW DOIMMD,T_SDOT,STRCOMP

   NF '(."'
t_SDOT: DW  JSR,tSKPs,tSDOT,texit

  nf 'STR,'
TSTRCOMMA:  DW JSR,TFOR,@@1,BCOMMA,TNEXT
@@1:   DW TDROP,TEXIT

  NF '(('     ; : (( CREATE , , IMMEDIATE DOES> STR , AT EXEC ;
  DW JSR,ACREATE,TCOMMA,TCOMMA,IMM,TCODESEMI
DOIMMD: CALL _DOES
        DW TSTR,TCOMMA,TPERF,TEXIT

  NF 'W,'
WCOMMA  DW JSR,TWCOUNT,TCOMMA,TEXIT

  NF 'B,'
BCOMMA  DW JSR,TCOUNT,TCOMMAB,TEXIT

   NF '+JUMP'
PJUMP:  DW JSR,TRFR,TPLUS,TTOR,TEXIT

  NF 'MAKER'
   DW JSR,ACREATE,TNOT,TLIT,3,TAND,T2STAR,TDUP,TCOMMAB,PJUMP
   DW TCOMMA,TCOMMA,TCOMMA,APOS,TCOMMA,TCODESEMI
TMAKER:  CALL _DOES
   DW TCOUNT,AHEADER,PJUMP,WCOMMA,WCOMMA,WCOMMA,TPERF,TEXIT

 nf '".'
tSDOT:  DW  JSR,tCouNT,tTYPE,texit

  NF 'ALIAS'
TBIND:  DW JSR,AHEAD4,TCOMP,XNONAME,tcomma,TEXIT

  NF 'X?COMP'
  DW  JSR,TCODESEMI
x?comp: call _DOES
        dw   tcat,apos0,TTOR,tPlus,TRFR,tretf
        JMP  XQCOMM

;  NF ',A'
; TACOMMA: DW   XACOMMA    ; ,

 NF ','
tcomma:  DW JSR,HERE,TADRSP2,TOHERE,TEXIT

 NF 'C,'
tcommab: DW JSR,HERE,TADRSP1,TOHERE,TEXIT

 NF 'lit'
tlit:   DW   XLIT       ; LIT

 NF 'blit'
tblit:   DW   XBLIT      ; BLIT

 NF 'Z,'
ZCOMMA   DW JSR,ZR,tcomMA,TEXIT

 NF 'ZC,'
ZCOMMAB   DW JSR,ZR,tcomMAB,TEXIT

 NF '>MARK'
TMARK    DW JSR,HERE,ZCOMMA,TEXIT

  NF ''','
APOSADRC  DW JSR,APOS,TCOMMA,TEXIT

  NFI '['']'   ; : ['] ' ?C TO , AT , , ; IMMEDIATE
   DW DOIMMD,TLIT,APOSADRC

 NFI 'THEN'
THEN DW JSR,HERE,tswapsto,TEXIT ;

  NFI ';THEN'
     DW DOIMMD,TEXIT,THEN

 NF 'LOOP/'
LPBEG DW JSR,TMARK,HERE,TEXIT

 NF '/LOOP'
LPEND DW JSR,TCOMMA,THEN,TEXIT

; NFI '?DO'
; DW DOIMMD,T?DO,LPBEG
;
; NFI 'LOOP'
; DW DOIMMD,TLOOP,LPEND
;
; NFI 'DO'
; DW DOIMMD,TDO,LPBEG
;
; NFI '+LOOP'
; DW DOIMMD,TPLOOP,LPEND
;
; NF 'COMPILE,'      ;
; TACOMP DW JSR,TRATPW,TCOMMA,TEXIT

 NF 'COMPILE'      ;
TCOMP DW JSR,TRATPW,TCOMMA,TEXIT

  NFI 'AHEAD'
TAHEAD  DW DOIMMD,TBRAN,TMARK

  NFI 'IF'
TIF  DW DOIMMD,TZBRAN,TMARK

  NFI 'FOR'
  DW DOIMMD,TFOR,TMARK

  NFI 'OF'
  DW DOIMMD,TOF,TMARK

  NFI 'NEXT'
  DW DOIMMD,TNEXT,THEN

  NFI 'BEGIN'
TBEGIN DW XNONAME,HERE

  NFI 'WHILE'
 DW XNONAME,TIF

  NFI 'AGAIN'
TAGAIN  DW DOIMMD,TBRAN,TCOMMA

  NFI 'UNTIL'
  DW DOIMMD,TZBRAN,TCOMMA

  NFI ''','
  DW JSR,APOS,TCOMMA,TEXIT

  NFI 'REPEAT'
  DW JSR,TSWAP,TAGAIN,THEN,TEXIT

  NFI 'ELSE'
  DW JSR,TAHEAD,TSWAP,THEN,TEXIT

;  NF 'BCOMPILE'      ;
; TCOMPB DW JSR,TPOP,BCOMMA,TPUSH,TEXIT

 NF 'ALLOT'      ; ALLOT
tallot: DW JSR,ATHERE,TPSTORE,TEXIT

 NF 'RECOVER'
 DW JSR,TWO,TNEGATE,TALLOT,TEXIT

  nfI    'LITERAL'
literal dw jsr,stat@,EXIT0,DOlit,texit;

  NF '?LITERAL'
TZLIT DW  ExecAt1,SETVAR,TZLIT2

  NF '(?LIT'
TZLIT2:dw JSR,dbl@,TONEPL,tZbran,@@1
     dw STAT@,EXIT0,TSWAP,literal,TDUP
@@1: DW TDROP,LITERAL,texIt

  nf ';code'
tCODESEMI dw jsr,tRFR,CFA,TSTORE1,texit

  nf 'REL,'
  DW  JSR,TCODESEMI
RCOMMA: CALL _DOES
  DW TCAT,TCOMMAB,HERE,TTWOPL,TSUBT,TCOMMA,TEXIT

  nf 'RJUMP,'
TJUMP DW RCOMMA
  DB 0E9H

  nf 'RCALL,'
TCALL DW RCOMMA
  DB 0E8H

  NF '?CODE'
CODE? DW JSR,HERE,TSWAP,TCALL,SKOBAR,TEXIT

  NF 'M:'
  DW JSR,TLIT,SUB4TH,CODE?,TEXIT

  NF 'NM:'
  DW JSR,TNEGATE,CDOES,TPLUS,CODE?,TEXIT

  NFI 'DOES>'
  DW JSR,TCOMP,TCODESEMI,CDOES,TCALL,TEXIT

  nf  '",'
tstrcom dw   jsr,tcat,tonepl,Tallot,texit

  NF 'CREATE'
ACREATE:dw   JSR,AHEADER,tCOMP,DoVar,TEXIT

  NF 'USE:'
  DW JSR,HERE,DOCOLON,TEXIT

  nf ':'
colon  dw jsr,AHEADER,asmudge,DOCOLON,TEXIT

  NFI 'DO:'
DOCOLON DW DOIMMD,JSR,SKOBAR

  NFI ';M'
DOSEMI DW DOIMMD,TEXIT,SKOBAL

  NFI '[LIT]'
DOLIT:  DW  DOIMMD,TLIT,TCOMMA

  nfi ';'
semi   dw jsr,asmudge,DOSEMI,texit

  nf  'IMMEDIATE'
IMM:  dw xsmg
  DB 128,0

  nf 'SMUDGE'
asmudge dw xsmg ; AT IMMEDIATE = smudge
   db 32

  NF 'LATEST'
LATEST  dw   JSR,CURR@,TFETCH,texit

  NF 'XSMG'
  DW  JSR,TCODESEMI
xsmg:   CALL _does
        dw   TCAT,LATEST,tXORTO,texit

ADRAT:
 nfi 'AT'
 DW  X?COMP
 DB  4

ADRTO:
 nfi 'TO'
 DW  X?COMP
 DB  2

  NF '(COMPIL'
  DW  JSR,TCODESEMI
COMPIL: CALL _DOES
  dw   tcat,apos,tPlus,TCOMMA,TEXIT

 NFI "[',]"
  DW COMPIL
  DB 0

 NFI '[TO]'
  DW COMPIL
  DB 2

 NFI '[AT]'
  DW COMPIL
  DB 4

  NF '<N>'
NSWAP  DW  JSR,NPTR,HERE,TONPTR,TOHERE,TEXIT

  NF '''SAME'
DUPLICA DW  ExecAt1,SETVAR,TNOP

  nf 'CFA'
CFA:    DW   DOCON1,SETVAR,0    ; AT CFA = CFA !

  nf 'NPTR'   ; NAME POINTER
NPTR   Dw DOCON1
TONPTR DW SETVAR,0C000H

  nf 'dA'
DADR  Dw DOCON1,SETVAR,0

  nf 'THERE'
THere   dw DOVAR,0,0

  nf 'HERE'
Here   dw DOCON2
TOHERE DW SETVAR1
ATHERE DW DOVAR,DtoP

  NF 'HEADER'
AHEADER:DW   JSR_TR,HDRS?,TQDUP,TZBRAN,AHEAD3
        DW   TONEMI,HDRS?+2,HERE,CFA+2
        DW   NSWAP,CFA,TBIND,NSWAP,TEX_TR
AHEAD3: DW   AHEAD4,HERE,CFA+2,TEX_TR

  NF 'THEAD'
AHEAD4: DW   JSR,DUPLICA
        DW   CURR@,HERE,T@SWP2,TBLword
        dw   tstrcom,tcomma,TEXIT   ; ! c@

  NF 'N>C'
tnamcf  DW XNAMCF

  NF 'HDRS?'
HDRS? DW DOCON2,SETVAR1,DOVAR,0

  NF 'HEADERS'
  DW  JSR,ZR,HDRS?+2,TEXIT

  NF '-HEADERS'
  DW  JSR,MO,HDRS?+2,TEXIT

  NF '|'
  DW  JSR,ONE,HDRS?+2,TEXIT

  NF 'XBASE'
  DW  JSR,TCODESEMI
xbase: call _does
       dw Tcat,toBase,texit

  NF 'XSTATE'
  DW  JSR,TCODESEMI
xstate: call _does
  dw  tcat,toStat,texit

  nf ']'
skobaR dw xstate
  db -1

  nfi '['
skobaL dw xstate
  db 0

;-----------------------^^^^^^^  COMPILER  ^^^^^^^-------------
;

;
;----------------------vvvvvvvv GLOBALS  vvvvvvvv------------
  nf 'VOCLINK'
 DW DOCON1,SETVAR,AFORTH+8

  NF 'PREV'
 DW DOCON1,SETVAR,0

  NF 'USE'
 DW DOCON1,SETVAR,0

  NF 'FIRST'
 DW DOCON1,SETVAR,FRST

  NF 'LIMIT'
 DW DOCON1,SETVAR,0

  NF 'MTOP'
 dw DOCON2,SETVAR1,DOVAR,0

  NF 'MPTR'
 dw DOCON2,SETVAR1,DOVAR,0

  NF 'TPTR'
 dw DOCON2,SETVAR1,DOVAR,0

  NF 'SPTR'
 dw DOCON2,SETVAR1,DOVAR,0

  nf 'CURRENT'
CURR@   DW DOCON1
toCURR  dw SETVAR,AFORTH+6

  nf 'CONTEXT'
CONT@   dw DOCON1
toCONT  dw SETVAR,AFORTH+6

  nf 'TIB'
TIB@   dw DOCON1
toTIB  dw SETVAR,0

  nf 'BLK'
BLK@   dw DOCON1
toBLK  dw SETVAR,0

  nf '>IN'
TOIN@  dw DOCON1
toTOIN dw SETVAR,0

  nf 'STATE'
STAT@  dw DOCON1
toSTAT dw SETVAR
UvSTAT DW 0

  nf 'SPAN'
SPAN@  dw DOCON1
toSPAN dw SETVAR,0

  nf 'DBL'
DBL@   dw DOCON1
toDBL  dw SETVAR,0

  nf 'OUTC'
OUTC@   dw DOCON1
toOUTC  dw SETVAR,0

  nf 'CSP'
CSP@   dw DOCON1
toCSP  dw SETVAR,0

  nf 'SCR'
SCR@    dw DOCON1
toSCR   dw SETVAR,0

;----------------------^^^^^^^^ GLOBALS  ^^^^^^^^------------

;---------------vvvvvvvv TASK VARIABLES vvvvvv-----------
  nf 'S0'
S0@    dw XUVAR@0
toS0   dw XtoUVR
    dw  UvS0-Uv0

  nf 'R0'
R0@    dw XUVAR@0
toR0   dw XtoUVR
    dw  UvR0-Uv0

  nf 'BASE'
BASE@  dw XUVAR@0
toBASE dw XtoUVR
    dw  UvBASE-Uv0

  nf 'U0'
       dw X@UVAR
    dw  0

;---------------^^^^^^^^ TASK VARIABLES ^^^^^^^^---------


;---------------vvvvvvvv CONSTANTS vvvvvv-----------
  nf 'bs'
bs  dw docon,8

  nf 'bl'
blc dw docon,32

  nf 'lf'
lf  dw docon,0ah

  nf 'cr'
cr  dw docon,0dh

  nf '-1'
mo  dw   _m1

  nf '0'
zr     dw  _zero

  nf '2'
two dw docon,2

  nf '1'
one dw docon,1

  nf '#does'
CDOES dw docon,_DOES

;---------------^^^^^^^  CONSTANTS ^^^^^^^----------

;---------------^^^^^^^  STACK ^^^^^^^----------
 NF 'POP'
TPOP:
trfr    DW   XRFR       ; R>

 NF 'PUSH'
TPUSH:
ttor    DW   XTOR       ; >R

 NF '@R+'
TRATPW   DW XRATPW

 NF 'C@R+'
        DW XRATPB
 NF 'R@'
trat    DW   XRAT       ; R@

 NF 'RP@'
tRpGt   DW   XRPGT      ; RP@

 NF 'RP!'
tRpSt   DW   XRPST      ; RP!

 NF 'DROP'
tdrop   DW   XDROP      ; DROP
 NF '2DROP'
tdrop2  DW   XDROP2     ; 2DROP
 NF 'RDROP'
TRDROP  DW   XRDROP     ; RDROP
 NF 'DUP'
tdup    DW   XDUP       ; DUP
 NF '2DUP'
TDUP2   DW   XDUP2      ; 2DUP
 NF 'TUCK'
        DW   XTUCK      ; TUCK
  nf 'NIP'
  DW XNIP

;---------------^^^^^^^  STACK ^^^^^^^----------


;---------------vvvvvvv  LOGICAL vvvvvvv----------

 NF '<'
TLESS   DW   XCHK       ; <
        DB   -1,0,0
 NF '='
tequal  DW   XCHK       ; =
        DB   0,-1,0
 NF 'U<'
TULESS  DW   XUCHK      ; U<
        DB   -1,0,0
 NF '0<'
TZLESS  DW   X0LESS     ; 0<
 NF '0='
TZEQ    DW   XZCHK      ; 0=
        DB   0,-1,0
 NF '0>='
TZGREQ  DW   XZCHK      ; 0>=
        DB   0,-1,-1
 NF '0<>'
tzne    DW   XZCHK      ; 0<>
        DB   -1,0,-1
 NF 'I'
ti      DW   XI         ; I DO LOOP
 NF 'OVER'
tover   DW   XOVER      ; OVER
 NF '2OVER'
TOVER2  DW   XOVER2     ; 2OVER
 NF '?DUP'
tqdup   DW   XQDUP      ; ?DUP
 NF 'ROT'
trot    DW   XROT       ; ROT
 NF '-ROT'
tmrot   DW   XMROT      ; -ROT
 NF 'SP@'
TSPGT   DW   XSPGT      ; SP@
 NF 'SP!'
tSpSt   DW   XSPST      ; SP!
 NF 'XCHG'
tXCHG   DW   XXCHG      ; XCHG
 NF 'SWAP'
tswap   DW   XSWAP      ; SWAP
 NF '2SWAP'
tswap2  DW   XSWAP2     ; 2SWAP
 NF '(STR'
tSKPs   DW   XSKPS      ; (")
tSKPSW  DW   XSKPSW     ; (")
 NF 'ORIGIN+'
        DW   @MYARY     ;DW   xorig      ; ORIGIN+
        DW   XQARY      ; 4* ARRAY

        NF 'NOP'
TNOP        DW   _NEXT

    NF 'ATTR'
     dw      DOVAR
ATTR DB 26
VPAG DB 0
     DW   XQARY      ; 4* ARRAY

; ---------------    DEBUGER  ------------------vvvvvvvvv

OUTWORD:PUSH AX
        MOV  aL,aH
        call OUTBYTE
        pop  ax
OUTBYTE:push ax
        mov cl,4
        shr al,cl
        call outdig
        pop ax
outdig: and al,0fh
        ADD AL,090h
        DAA
        ADC AL,040h
        DAA
outc:   MOV CX,1
        mov ah,0EH
        INT 010h
OUTC_1P:           ;MOV  DI,OFFSET toOUTC+2
                   ; !!! NUT USER VAR
;       CALL DOuVAR
;        INC  PW [DI]
        INC  PW TOOUTC+2
        RET
regout: call outWord
space1: mov  al,' '
        jmp short outc
NEW_CR: MOV AL,0DH
        CALL OUTC
        MOV  AL,0AH
        JMP SHORT OUTC

XEX_TR: CALL POPR
        MOV  AX,[BP]
        MOV  pb _ex,al
        JMP  XRDROP

JSR_TR: MOV  AL,PB _ex
        TRACE_OFF
        LEA  BP,[BP-2]
        MOV  [BP],AX
        JMP  JSR

  nf 'H.'
hdot  dw $+2
  XCHG ax,bx
  call regout
  dropreg

 NFI 'TRACE'
 DW JSR,APOS,_TR,TEXEC,_NTR,TEXIT

 NF '-TR'
_NTR:  DW  $+2
     TRACE_OFF
     NEXT

 NF 'TR'
_TR: DW $+2
      TRACE_ON
      NEXT

      NF '(DEBUG'
ZZDBG DW JSR
        DW   TDUP2,HDOT,HDOT,TPUSH,TPUSH,TDUP2,HDOT,HDOT
        DW   TPOP,TPOP,TSPGT,HDOT
        DW   TRPGT,HDOT,TRAT,HDOT
        dw   sav_Si,tdup
        dw   ttwomi,tdup,hdot
        DW   TSWAP,TFETCH,HDOT
        dw   tfetch,hdot,HERE,HDOT
        dw   SAV_AX,v_ID
      DW TEXIT

debugerr:
        mov   pw saveSi,si
        mov   pw saveAX,AX
        TRACE_OFF
        call  j4th
        DW   ZZDBG
        dw   tfromf
        xor  ax,ax
        int  16h
        and  al,0dfh
        cmp  al,'S'
        PUSHF
        CALL NEW_CR
        TRACE_ON
        POPF
        jne  @@2
        TRACE_OFF
@@2:    mov  si,saveSi
        mov  di,saveAX
        jmp  [di]

sav_AX  dw   DoCon
saveAX  dw   0

sav_si  dw   DoCon
saveSi  dw   0

  nf    'ID.'
N_ID    DW    JSR,Tcount,Tlit,31,Tand
  DW TtYpE,Tspace,TexIt

  NF    '?ID.'
V_id:   dw    jsr,cfname,TQDUP,EXIT0
  DW tonemi,TQdup,tZbran,@@3
  dw tLIT,@@3+2,TPLUS,TFETCH,N_ID
@@3: dw N_ID,TEXIT,ADRTO,ADRAT


; ---------------    DEBUGER  ------------------^^^^^^^^^^^

  NF '''INIT'
INITW DW  ExecAt1,SETVAR,0

   NF '_INIT'
_INIT:  DW   JSR,TF83,INITW,TLIT,081H,TEVAL,TQUIT,TEXIT

   NF '_ABORT'
_ABORT: dw  JSR,_NTR,TF83,ZCLOSE,skobaL,erINI,TQUIT,TEXIT

DtoP=$
lastw = ppppp

;       db   tbp      ;brkpt
MyCseg  ends
        end  Start
