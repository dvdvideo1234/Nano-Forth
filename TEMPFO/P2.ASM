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
next  MACRO
        jmp  _next
      ENDM
num   MACRO n
          dw n + n + 80h
      ENDM
X     MACRO
        xchg sp,bp
      ENDM

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
Start   Label byte
;       JMP START1
;       ORG 500H
START1: JMP   SHORT  UvSET
       CLD
       CALL @@1
       DW  START1
       DW  SMARTM
       DW  LASTW
       NOP
       NOP
        DW    _NEXT
        DW    0
        DW    0
        DW    0
; UvCOLD  DW    0
; UvWARM  DW    0
; UvINIT  DW    0
; OPTBL   DW    0
@@1:   POP  SI
       LODSW   ; SEND CONTROL TO
       PUSH   AX
       XCHG   AX,DI
       LODSW   ; MOVE U D
       PUSH   AX
       LODSW
       XCHG CX,AX
       LODSW
       SUB  CX,DI
       XCHG AX,[SI-14]
       MOV  [SI-2],AX
       MOV  AX,100H
       CMP  SI,DI
       JC  @@2
       XCHG  AX,DI
@@2:   RET
UvSET:
        CLD
        MOV  SP,-2048
        CALL  INITF1
Uv0     dw   TWAKE
UvNextT dw   -84
UvPrevT dw   -84 ; UvFlags
UvCrSP  dw   -1280
UvS0    dw   -1280
UvR0    dw   -512 ;
UvH     dw   dtop
UvBASE  dw   10
UvCURR  dw   AFORTH+6
UvCONT  dw   AFORTH+6
UvTIB   dw   -168
UvHLD   dw   0
UvBLK   dw   0
UvTOIN  dw   0
UvSTAT  dw   0
UvSPAN  dw   0
UvDBL   dw   0
UvCSP   dw   0
UvOUT   dw   0
UvSCR   dw   0
UvHDR   dw   0
UvSELF  dw   0
UvVOCL  dw   AFORTH+8
UvFIRST DW   -2048-3084 ;       5132
UvLIMIT DW   -2048
UvPREV  DW   -2048-2056
UvUSE   DW   -2048-1028
UvMTOP  DW   -8332  ;iMTOP
UvMPTR  DW   -8332  ;iMPTR
UvSPTR  DW   -8332  ;iSPTR
INITF1: POP  SI
        MOV  CX,[SI-2]
        MOV  DI,[SI+2]
        MOV  PW USERV,DI
        REP  MOVSB
        xor  Ax,Ax
        MOV  SI,80H
        MOV  DI,-168
        LODSB
        MOV  BX,AX
        MOV  [SI+BX],AH
        LEA  CX,[BX+1]
        REP  MOVSB
        mov     bx,1000h
        mov     ah,4ah
        int     21h
        MOV  AH,15
        CALL _INT_10
        MOV  VPAG,BH
;       call  _set_tr
        call Wreset
        DW   TF83,INITW,aINTERP,FSYS1

_DNEGAT:POP  DI
        POP  AX
        XOR  CX,CX
        NEG  AX
        SBB  CX,BX
        MOV  BX,CX
        PUSH AX
        JMP  DI

XRET4TH:PUSH  SI
popR:   x
        pop   SI
        x
        RET
XFROMF: JMP   SI

; STORAGE LOCATIONS FOR USER VARIABLES

; iS0     =   4
; iR0     =   iS0+1
; iH      =   iS0+2
; iBASE   =   iS0+3
; iCURR   =   iS0+4
; iCONT   =   iS0+5
; iTIB    =   iS0+6
; iHLD    =   iS0+7
; iBLK    =   iS0+8
; iTOIN   =   iS0+9
; iSTAT   =   iS0+10
; iSPAN   =   iS0+11
; iDBL    =   iS0+12
; iCSP    =   iS0+13
; iOUT    =   iS0+14
; iSCR    =   iS0+15
; iHDR    =   iS0+16
; iSELF   =   iS0+17
; iV0CL   =   iS0+18
; iFIRST  =   iS0+19
; iLIMIT  =   iS0+20
; iPREV   =   iS0+21
; iUSE    =   iS0+22
; iMTOP   =   iS0+23      ;RESIDENT PROGRAMS
; iMPTR   =   iS0+24      ;MACRO
; iSPTR   =   iS0+25      ; STRING STACK
;
; HEADERLESS EXECUTION CODE GOES HERE

X3RAT:  CALL _RFRS@
        DB   6
X2RAT:  CALL _RFRS@
        DB   4
X3RFR:  CALL _RFRS_
        DB   6
X2RFR:  CALL _RFRS_
        DB   4
XRFR:   CALL _RFRS_
        DB   2
_RFRS_: DB   0B9H
_RFRS@: XOR  CX,CX
        POP  DI
        MOV  DI,[DI]
        AND  DI,255
        JCXZ @@1
        MOV  CX,DI
@@1:    PUSH BX
        DEC  DI
        DEC  DI
        MOV  BX,[BP+DI]
        JNE  @@1
        ADD  BP,CX
        NEXT
xnip:   pop  ax
        next
X2TOR:  SUB  BP,4
        POP  CX
        JMP  SHORT _2TOR
@MYARY: MOV  AX,OFFSET Uv0
        PUSH AX
MYARY:  SHL  BX,1
        JMP  XPLUS
XDOP:   POP   DI
_DOP1:  lodsw
        mov   Cx,8000h
        sub   Cx,DI
        add   Bx,Cx
        DB    0BFH  ; MOV DI,
X3TOR:  POP  CX
        POP  AX
        JMP  SHORT _3TOR
xfor:   OR    BX,BX
        je    XBR_DR
        LODSW
        DEC   BX
        MOV   CX,SI
_3TOR:  SUB   BP,6
        MOV   [BP+4],AX ;  PUSH  AX
_2TOR:  MOV   [BP+2],CX ;  PUSH  SI
        DB    0B9H
XTOR:   DEC   BP
        DEC   BP
X_TOR:  MOV   [BP],BX
        dropREG
xnext:  MOV   CX,[BP]
        JCXZ  XLEAVE
        DEC   CX
        MOV   [BP],CX
        MOV   SI,[BP+2]
        next
XBTOD:  XCHG  AX,BX
        CBW
        XCHG  AX,BX
XsTOd:  PUSH  BX
X0LESS: SHL   BX,1
XCARRY: SBB   BX,BX
        JMP   _NEXT
XNZBRAN:OR    BX,BX
        jNe   XBR_DR
        INC   BX
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
xbp:    int  3
        JMP SHORT _next
jsr4:   scasw
jsr3:   scasw
jsr2:   scasw
jsr1:   scasw
JSR:    X
JSR0:   PUSH SI
        X
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
XMABS:  POP  AX
        SUB  BX,AX
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
XSTR:   MOV  DI,SP
        SCASW
        ADD  SS:[DI],BX
xsubt:  neg  bx
XPLUS:  POP  AX
_plus:  ADD  BX,AX
        JMP  SHORT _next
XRAT:   mov  Ax,[bp]
        JMP  SHORT _PUSHAX
dovar2: scasw
dovar1: scasw
DOVAR:  JMP  SHORT DOVARZ
XPC2_DR:LODSW
xdrop:  pop  bx
        JMP  SHORT _NEXT
        scasw
        scasw
_does:  x
        push si
        x
        POP  SI
DOVARZ: scasw
_PUSHDI:xchg AX,DI
_PushAx:PUSH BX
_SwapAx:xchg BX,ax
_next:  lodsw
_ex:    xchg di,ax
        jmp  pw [di]
        JMP  DEBUGerr
X0EXIT: OR    BX,BX
        POP   BX
        JNE   _NEXT
        JMP  XEXIT
XTUCK:  POP  AX
        PUSH BX
        PUSH AX
        NEXT
XM2STO: DEC  pw [BX]
XM1STO: DEC  pw [BX]
        DROPREG
XP2STO: INC  pw [BX]
XP1STO: INC  pw [BX]
        DROPREG
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
XNSTOR: MOV  [BX],AX        ; NOT USED YET
        DROPREG
XCSTOR: POP  AX
XBSTOR: MOV  [BX],AL        ; NOT USED YET
DDD:    DROPREG

XPSTORE:POP  AX
        ADD  [BX],AX
        DROPREG
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
DO2CON2:SCASW
DO2CON1:SCASW
DO2CON: SCASW
DO2CON0:PUSH BX
        MOV  BX,DI
XTWOAT: PUSH [BX+2]
xFETCH: MOV  BX,[BX]
        NEXT
XCOUNT: inc  bx
        PUSH BX
        DEC  BX
XCAT:   MOV  BH,[BX]
xhi:    xchg bh,bl
xlo:    MOV  BH,0
        NEXT
XDUP2:  Pop  aX
        push ax
        PUSH BX
        push ax
        NEXT
SUB4TH: x
        push  si
        x
J4th:   POP   SI
        JMP  SHORT _next
XTWOATA:   ; TO FADR
        PUSH  [BX]
        inc   bx
        inc   bx
        jmp   short xfetch
_Zero:  push bx
        XOR  bx,BX
        next
_m1:    push bx
        XOR  bx,BX
        db   0b9h
X3MINUS:DEC  BX
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
X64SLS: SHR  BX,1
X32SLS: SHR  BX,1
X16SLS: SHR  BX,1
X8SLS:  SHR  BX,1
X4SLS:  SHR  BX,1
X2SLS:  SHR  BX,1
        NEXT
XP2SLS: POP  AX
        ADD  BX,AX
        RCR  BX,1
        NEXT
X8STAR: SHL  BX,1
X4STAR: SHL  BX,1
X2STAR: MOV  CL,1
X2STAR_:SHL  BX,CL
        NEXT
XUMSTAR:POP  AX
        MUL  BX
        PUSH AX
        MOV  BX,DX
        NEXT
XPICK:  SHL  BX,1
        ADD  BX,SP
        MOV  BX,SS:[BX]
        db   0b9h
XSLICE: INT  28H
        NEXT

XSKPSW: CALL _XSKPS
        mov  bx,si
        lodsW
        add  si,ax
        RET
XSKPS:  CALL _XSKPS
        mov  bx,si
        xor  ax,ax
        lodsb
        add  si,ax
        RET
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
        DB   0B9H
XUMSLS: XOR  DX,DX
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
XTWOPL: INC  BX
XONEPL: INC  BX
        next
xcntdo: pop  ax
        add  bx,ax
        jmp  _pushax
xdabs:  or   bx,bx
        jns  no_abs
XDNEGAT:CALL _DNEGAT
no_abs: NEXT
XI:     XOR   DI,DI
_ILOOP: mov   ax,[bp+0+DI]
        sub   ax,[bp+2+DI]
        PushReg
_CALL:  SCASW
        CALL  DI
        NEXT
_MOVER: POP  DX
        POP  DI AX
        push cs
        pop  es
        MOV  CX,BX
        CALL DX
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
XROLL:  ADD  BX,BX
        MOV  DI,SP
        PUSH SS:[DI+BX]
        MOV  AX,SP
        LEA  CX,[BX+2]
        CALL _MOVEU
XDROP2: POP  BX
        JMP  XDROP
XROLLM: ADD  BX,BX
        MOV  CX,BX
        ADD  CX,SP
        PUSH CX
        MOV  AX,SP
        PUSH CX
        MOV  DI,SP
        LEA  CX,[BX+4]
        CALL _MOVE1
        POP  BX
        JMP  XSTORE1

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
XWLOD:  SHL  BX,1
XNLOD:  MOV  CX,BX
        POP  DI
        MOV  DX,SI
        LEA  SI,[BX+DI]
        STD
        DEC  SI
        XOR  AX,AX
        SHR  CX,1
        JNC  @@1
        LODSB
        PUSH AX
@@1:    DEC  SI
        JCXZ @@3
@@2:    LODSW
        PUSH AX
        LOOP  @@2
@@3:    CLD
        MOV   SI,DX
        DROPREG
XWSTO:  SHL  BX,1
XNSTO:  MOV  CX,BX
        POP  DI
        SHR  CX,1
        JZ   @@2
@@1:    POP  AX
        STOSW
        LOOP @@1
@@2:    JNC  @@3
        POP  AX
        STOSB
@@3:    DROPREG
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
XSCANS: OR   BX,BX
        POP  DI
        JE   @@4
        POP  CX
        POP  AX
        PUSH AX
        PUSH CX
        SUB  CX,BX
        JB   @@4
        push cs
        pop  es
        XCHG AX,DI  ; DST ADR
        XCHG AX,BX  ; SRC ADR
        XCHG AX,DX  ; SRC CNT
        INC  CX     ; DST CNT
        DEC  DX
@@2:    MOV  AL,[BX]
        REPNE SCASB
        JNE  @@4
        OR   DX,DX
        JE   @@3
        PUSH CX
        PUSH DI
        LEA  AX,[BX+1]
        XCHG AX,SI
        MOV  CX,DX
        CALL _STRCMP
        XCHG AX,SI
        POP  DI
        POP  CX
        JNE     @@2
        ADD  CX,DX
        DB   0B8H
@@4:    POP  CX
        PUSH CX
@@3:    INC  CX
        POP  AX
        PUSH AX
        SUB  AX,CX
        SWAPREG
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
XATSWAP:POP  AX
        DB   0B9H
XATSWP2:POP  AX
        XCHG AX,BX
        JMP  SHORT X2CHG
X@SWAP: POP  DI
        MOV  AX,[DI]
        XCHG AX,[BX]
        STOSW
        DROPREG
X@PLSTO:POP  AX
        OR   AX,AX
        JS   _MINS@
        JMP  SHORT _@PLUS
X@NPACK:MOV   BX,[BX]
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
XPVECT: PUSH BX
        MOV  BX,[DI+4]
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
XDLIT:  LODSW
        XCHG  AX,CX
        LODSW
_PUSH2: PUSH  BX
        PUSH  AX
        MOV   BX,DX
_psh2:  NEXT
?NONAM1:POP  AX
        POP  DI
        PUSH DI
        SCASW
        JNE  _PSH2
        POP  AX
        PUSH [DI]
        JMP  SHORT _PSH2
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
        mov  cx,[di+UvStat-Uv0]
        jcxz xEXEC
        jmp  short xcomma

xcomMF: POP  Ax         ; SWAP D,
        push bx
        xchg ax,bx
xcommD: call _comp      ; D,
        stosw
        pop  ax
        stosw
        jmp  short _comp_
xcompb: push bx         ;compileb
        lodsb
        xchg ax,bx
xcommab:call _comp      ;,
        stosb
_comp_: xchg cx,di
        mov  [di],cx
        dropreg
xcompw: lodsw
        push bx
        xchg ax,bx
xcomma: call _comp      ;,
        stosw
        jmp  short _comp_
x_hold: call  doUvar1
        call  start_h
        dec   di
        mov   [di],al
        jmp  short _comp_
XCFAst: SCASW
        mov  di,[di]
        MOV  [DI],BX
        DROPREG
Start_h:xchg ax,bx
        mov  cx,di
        mov  di,[di]
        ret
x0max:  push bx
        xor  bx,bx
xmax:   pop  ax
        cmp  bx,ax
        jmp  short _mm
x0mIN:  push bx
        xor  bx,bx
xmin:   pop  ax
        cmp  ax,bx
_mm:    jGE  NEXT@@2
        xchg ax,bx
NEXT@@2:next
xnamCf: mov   al,[bx]
        and   ax,31
        add   bx,ax
xtreePl:inc   bx
        jmp   xtwopl
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
  cli
  repe    cmpsb
  sti
  jz      _l6
_l5:
  add     si,cx
_l6:  ret
X_W:  mov   di,bx ; _WORD ;X_W:            ; _WORD  ;
      pop   bx            ;  mov   di,bx            ;
      pop   ax            ;  pop   bx               ;
      pop   dx            ;  pop   ax               ;
      push  di            ;  pop   dx               ;
      push  si            ;  push  di               ;
      xor   si,si         ;  push  si               ;
      xchg  ax,si         ;  xor   si,si            ;
      inc   di            ;  xchg  ax,si            ;
                          ;  inc   di               ;
                          ;  dec   bx               ;
                          ;readtib:                 ;
                          ;  inc   bx               ;
      DEC   BX            ;  mov   al,[si+bx]       ;
@@1:  INC   BX            ;  cmp   al,dl            ;
      mov   al,[si+bx]    ;  je    readtib          ;
      or    al,al         ;  or    al,al            ;
      je    @@3           ;  jne   wordlp           ;
      cmp   al,dl         ;  inc   ah               ;
      je    @@1           ;  stosb                  ;
                          ;  jmp   short exword     ;
@@2:  inc   ah            ;wordlp:                  ;
      stosb               ;  inc   ah               ;
      inc   bx            ;  stosb                  ;
      mov   al,[si+bx]    ;  inc   bx               ;
      or    al,al         ;  mov   al,[si+bx]       ;
      je    @@4           ;  cmp   al,dl            ;
                          ;  je    exword2          ;
                          ;  or    al,al            ;
      cmp   al,dl         ;  jne   wordlp           ;
      jNe   @@2           ;  db    0b0h             ;
      inc   bX            ;exword2:                 ;
      JMP   SHORT @@4     ;  inc   bX               ;
@@3:  INC   AH            ;exword:                  ;
@@4:  mov   al,0          ;  mov   al,0             ;
      stosb               ;  stosb                  ;
      pop   si            ;  pop   si               ;
      pop   di            ;  pop   di               ;
      push  di            ;  push  di               ;
      mov   [di],ah       ;  mov   [di],ah          ;
      NEXT  ; _WORD_      ;  NEXT  ; _WORD_         ;

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
_comp:  mov  cx,offset start_h
        push cx
        push cs
        pop  es
hereAdr:mov   di,offset @h
        db    0b9h
doUVAR2:scasw
doUVAR1:scasw
doUVAR: mov   di,[di+2]
DoUvar0:add   di,offset Uv0
USERV   =    $-2
        ret
xcatf:  mov  al,[bx]
        cbw
        swapreg
Wreset: cli
        cld
        pop  SI
        MOV  DI,PW USERV
        mov  bp,[DI+UvR0-Uv0]
        mov  sp,[DI+UvS0-Uv0]
        xor  BX,BX
        sti
        NEXT
xPause: push bx         ;       CALL J4TH
        X               ;       DW   TBP
        push si         ;       DW   TFROMF
        PUSH FRAME
        X
        push bp
        mov  di,pw userv
        mov  [di+6],sp
        mov  Si,[di+2]
        NEXT
XWAKE:  DEC  SI         ;TWAKE  dw JSR,TRFR,TFROMF
        DEC  SI
        mov  pw userv,SI
        mov  sp,[Si+6]
        pop  bp
        X
        POP  FRAME
        pop  si
        X
        dropreg

XFNAME: xor   ax,ax
  mov   dx,0fefch
  mov   cx,35
  sub   bx,3
prevbyte:
  dec   bx
  inc   ah
  inc   dh
  inc   dl
  mov   al,[bx]
  and   al,127
  cmp   al,64
  jge   prevb2
  cmp   al,ah
  je    toname2
  cmp   al,dl
  je    toname2
  cmp   al,dh
  je    toname2
prevb2:
  loop  prevbyte
  mov   bx,cx
  next
toname2:
  push  bx
  sub   ah,al
  mov   al,0
  xchg  al,ah
  shr   ax,1
  inc   ax
  swapreg
XRESOLV:CALL HEREADR
        PUSH  BX
        MOV   BX,[DI]
XSWPSTO:POP   DI
        MOV   [DI],BX
        DROPREG
X4COUNT:CALL  X2COUNT
        XCHG  AX,CX
X2COUNT:MOV   AX,[BX]
        INC   BX
        INC   BX
        RET

XDCOUNT:CALL  X4COUNT
        JMP   _PUSH2
XWCOUNT:CALL  X2COUNT
        PUSHREG
XMULT2: POP   AX
        IMUL  BX
        PUSH  AX
        MOV   BX,DX
        NEXT
XMULT1: POP   AX
        IMUL  BX
        SWAPREG
_DIVmAX:CWD
_DIVMOD:XOR   DI,DI
        OR    BX,BX
        JNS   @@2
        NEG   BX
        INC   DI
@@2:    OR    DX,DX
        JNS   @@3
        DEC   DI
        XOR   CX,CX
        NEG   AX
        SBB   CX,DX
        MOV   DX,CX
@@3:    CMP   DX,BX
        JNB   @@6
        DIV   BX
        OR    DI,DI
        JE    @@5
        OR    DX,DX
        JE    @@4
        INC   AX
@@4:    NEG   AX
@@5:    XCHG  AX,BX
        DB    0DH
@@6:    XOR   BX,BX
        RET
XMULDIV:POP   DX
        POP   AX
        IMUL  DX
        CALL  _DIVMOD
        NEXT
XDIVMOD:POP   AX
        CALL  _DIVMAX
        PUSH  DX
        NEXT
XDIV:   POP   AX
        CALL  _DIVMAX
        NEXT
XMOD:   POP   AX
        CALL  _DIVMAX
        MOV   BX,DX
        NEXT

        ; -----------  IO  PRIMITIVES  vvvvvvvvvvv
_HND_GT:mov  DI,offset handles
cnt_GT0:mov  cx,di               ; mov  cx,di
        mov  di,[di]             ; mov  di,[di]
        shl  di,1                ; shl  di,1
        add  di,cx               ; add  di,cx
        mov  Ax,[DI]             ; mov ax,[di]
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
OUTC_1P:MOV  DI,OFFSET toOUTC
        CALL DOuVAR
        INC  PW [DI]
        RET
regout: call outWord
space1: mov  al,' '
        jmp short outc
NEW_CR: MOV AL,0DH
        CALL OUTC
        MOV  AL,0AH
        JMP SHORT OUTC

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
        mov  cx,1
        push cx
        mov  dx,sp
        mov  ah,3fh
        int  21h
        pop  Cx
        xchg ax,cx
        jcxz @@2
        cmp  al,' '
        jae  @@1
        cmp  al,1Ah
        je   @@2
        cmp  al,0dh
        je   @@1
@@3:    mov  al,' '
@@1:    ret
@@2:  ; mov  cx, offset @@3
      ; push cx
        JMP  XDROPH1

  NF 'IOV'
ioV     DW  DOVAR
JKEY    DW      _key1
JEMIT   DW      _emit1

_gs_ke: CALL _DOES
        DW  TTWOAT,IOV,TSTORE2,TEXIT

 NF 'SIO'
STDIO:  DW   _gs_ke,_key1,_emit1

  NF 'FIO'
FILEIO: DW   _gs_ke,_key2,_emit1

xblank: mov  al,' '
        push bx
        xchg ax,bx
XEMIT:  call PW [jemit]
        CALL OUTC_1P
        DROPREG

_EMIT1: MOV  DL,BL
        MOV  AH,2
        INT  021h
        ret

XKEY:   PUSH BX
        call PW [jkey]
        SWAPREG

 NF 'BIOS-KEY'
_BKEY:  DW   _CALL
_KEY1:  MOV  AH,0
        INT  016h
        ret

_emit2: ret

XWBLK:  MOV   CH,40H
        DB    0B8H
XRBLK:  MOV   CH,3FH
        MOV   AX,1024
        PUSH  CX
        PUSH  AX
        MUL   BX
        XCHG  AX,DX
        XCHG  AX,CX
        MOV   BX,SCRH
        MOV   AX,4200H
        INT   21H
        POP   CX
        POP   DI
        POP   DX
        JC    @@1
        mov   AX,DI
        INT   21H
        JC    @@1
        sub   CX,AX
        JE    @@2
        xchg  di,dx
        cmp   dh,40h
        je    @@3
        add   di,ax
        xor   ax,ax
        rep   stosb
        db    0b9h
@@3:    MOV   Al,253
@@1:    MOV   DERR,AX
@@2:    DROPREG

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
        XOR   AX,AX
        XCHG  DH,AL
        PUSH  DX
        PUSH  AX
        XOR   BX,BX
        XCHG  BL,CH
        PUSH  CX
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

XFLIP:  XCHG  BL,BH
        NEXT
DO_SWAP: SCASW
        SCASW
        MOV   AX,[DI+2]
        XCHG  AX,SI
        MOV   CX,[DI]
        XCHG  CX,[SI]
        MOV   [DI],CX
        XCHG  AX,SI
        NEXT
setproc:SCASW
        x
        push si
        x
        mov  si,di
SETFRAM:LODSW
        PUSH BX
        XCHG AX,BX
PARSET: LEA  AX,[BP-2]
        XCHG FRAME,AX
        X
        PUSH AX
        XOR  AX,AX
        MOV  AL,BL
        MOV  DI,AX
        ADD  DI,DI
        LEA  CX,[BP+DI]
        JZ   @@2
@@1:    DEC  DI
        DEC  DI
        PUSH [BP+DI]
        JNZ  @@1
        MOV  BP,CX
@@2:    MOV  AL,BH
        MOV  CX,AX
        JCXZ @@4
@@3:    PUSH DI
        LOOP @@3
@@4:    X
        DROPREG
XRETURN:DB   0B9H
GETFRAM:XOR  CX,CX
        MOV  BP,FRAME
        X
        POP  FRAME
        JCXZ @@1
        POP  SI
@@1:    X
        NEXT
GETLOC: CALL XLOC3
        DW   XGET-1
        MOV  AX,[DI+6]
        DB   0B1H
        LODSW
XGET:   ADD  AX,FRAME
        MOV  DI,AX
        MOV  AX,SS:[DI]
        PUSHREG
SETLOC: CALL XLOC2
        DW   XSET-1
        MOV  AX,[DI+4]
        DB   0B1H
        LODSW
XSET:   ADD  AX,FRAME
        XCHG BX,AX
        MOV  SS:[BX],AX
        DROPREG
ATLOC:  CALL XLOC1
        DW   XAT-1
        MOV  AX,[DI+2]
        DB   0B1H
        LODSW
XAT:    ADD  AX,FRAME
        PUSHREG
XLOC3:  SCASW
XLOC2:  SCASW
XLOC1:  SCASW
        POP   AX
        XCHG  AX,BX
        PUSH  AX
        MOV   AX,[DI]  ;AL
        PUSH  AX
        CALL  SUB4TH     ;B
        DW TCOMMA, TCOMMA, TEXIT
LOC8    DW  GETLOC+5,SETLOC+5,ATLOC+5,-16
LOC7    DW  GETLOC+5,SETLOC+5,ATLOC+5,-14
LOC6    DW  GETLOC+5,SETLOC+5,ATLOC+5,-12
LOC5    DW  GETLOC+5,SETLOC+5,ATLOC+5,-10
LOC4    DW  GETLOC+5,SETLOC+5,ATLOC+5,-8
LOC3    DW  GETLOC+5,SETLOC+5,ATLOC+5,-6
LOC2    DW  GETLOC+5,SETLOC+5,ATLOC+5,-4
LOC1    DW  GETLOC+5,SETLOC+5,ATLOC+5,-2
FRAME   DW      0
X?SS:   MOV     AX,SS
        DB      0B9H
X?CS:   MOV     AX,cs
        PUSHREG
X?FRAME:MOV  DI,[DI+4]
        MOV  AX,[DI]
        PUSHREG
XFRAME: MOV  DI,[DI+2]
        MOV  [DI],BX
        DROPREG
X@SELFP:MOV  BX,[BX]    ; ADDRES OF FIELD WORD CFA
        MOV  AX,[BX+2]  ; OFFSET IN RECORD
        MOV  BX, PW USERV
        ADD  AX,[BX+UvSELF-Uv0]
        SWAPREG
XSELFP: SCASW
        PUSH BX
        MOV  AX,[DI]
        MOV  BX, PW USERV
        ADD  AX,[BX+UvSELF-Uv0]
        XCHG AX,BX
        JMP  JSR
XMNAME: POP   DI
        XCHG  SI,BX
        MOV   CX,63
        CALL _strequ1
        XCHG  SI,BX
        JNE   @@1
        MOV   BX,CX
@@1:    NEXT



XRR:    MOV   DI,[BP]
        JMP   DOCON0
XTORR:  MOV   DI,[BP]
        ADD   PW [BP],2
        JMP   SETVAR0

X2FLIP: POP   AX
        XCHG  AL,AH
        XCHG  BH,BL
        SWAPREG

XC@SWAP:POP   DI
@@2:    MOV   AL,[DI]
        DEC   BX
        CMP   DI,BX
        JNC   @@1
        XCHG  AL,[BX]
        STOSB
        JMP   @@2
@@1:    DROPREG

X2STR:  MOV   AX,-1
        DB    0BFH  ; MOV DI,
X1STR:  XOR   AX,AX
        DEC   AX
        PUSH  BX
       XCHG  AX,BX
        JMP   XSTR


XADRSP2: POP PW [BX]
ADRP2:   INC  BX
ADRP1:   INC  BX
         NEXT
XADRSP1: POP  AX
         MOV  [BX],AL
         JMP  SHORT ADRP1
XADRP1:  XOR  AX,AX
         MOV  AL,[BX]
         PUSH AX
         JMP  SHORT ADRP1
XADRP2:  PUSH PW [BX]
         JMP  SHORT ADRP2
PMUL:    TEST PB [BP],1
         JE   @@1
         POP  AX
         ADD  BX,AX
         PUSH AX
@@1:     RCR  BX,1
         RCR  PW [BP],1
         NEXT

; CODEMARK - END OF CODE

; COMPILATION WORDS

ppppp = $
  dw    81h,qqqqq,ExecAt1,SETVAR,TEXIT
qqqqq = ppppp

  NF '0;'
  DW X0EXIT

; NF 'RRTR'       ; RETURN REGISTER (STACK TOP ELEMENT LIKE ADDRESS)
; DW XRR,XTORR

  NF '/STR'      ; STRING OPERATIONS  /STR |  -2 /STR |  -1 /STR
  DW XSTR,X2STR,X1STR

  NF 'STR'      ; STRING OPERATIONS  GETSTR SETSTR PLUSSTR
TSTR  DW  XWCOUNT,XSTRSTO,XSTRPLS

  NF 'C@+'       ; STREEM @ OPERATIONS
  DW XADRP1,XADRP2

  NF  '+*'
  DW PMUL

  NF 'C!+'       ; STREEM ! OPERATIONS
  DW XADRSP1,XADRSP2

  NF 'FRM'
     DW  XWARY,SETFRAM
tgetf:dw GETFRAM,GETLOC,SETLOC,ATLOC
      DW setproc,PARSET,FRAME,XRETURN,XSELFP

  NF 'SHIFT'
  DW XSHIFT
  DW X2PWR

  nf 'NIP'
  DW XNIP

  NF '*/'
  DW XMULDIV

  NF '/MOD'
  DW XDIVMOD

  NF 'MOD'
  DW XMOD

  NF '/'
  DW XDIV

 NF 'M*'
 DW XMULT2

 NF '*'
 DW XMULT1

 NF 'COUNT'
tCouNT  DW   XCOUNT     ; COUNT
TWCOUNT DW   XWCOUNT    ; WCOUNT
TDCOUNT DW   XDCOUNT    ; DCOUNT

 NF 'SWAP!'
 DW XSWPSTO

  NF 'ABS'
  DW XABS
  DW XDABS
  DW XMABS

  NF '(CLSC'
  DW XCLRSCR

  NF '3+'
  DW XTREEPL

  NF '-TEXT'
  DW XMTEXT,XSCANS,XMNAME

  NF 'SCLST'
  DW XSCANL,XSCANI

  NF 'SCAN'
  DW XSCANB,XSCANW

 NF 'ERASE'
 DW _FILLER
 DB 0

 NF 'BLANK'
 DW _FILLER
 DB ' '

; --------------------------IO  ------------------vvvvvvv

  NF 'CURSOR'
SET_CURS DW CURSIZE
TO_CURS  DW XY_GOTO
GET_CURS DW GETCURS

  NF 'GOTOXY'
  DW XY_GOTO

 NF 'DERR'
 DW DOCON1,SETVAR
DERR DW 0

 NF 'SCRH'
 DW DOCON1,SETVAR
SCRH DW -1

; ------------------  IO  -----------------^^^^^^^

 NF 'ALPHA'
 DW XALPHA

  NF 'ORDER#'
TORDER: DW DOVAR2,_HND_TO,_HND_AT
      DW  1,AFORTH+6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

  nf 'CR'
tCR:    dw   jsr,cr,temit,lf,temit,ZR,TOoUTC,texit

  NF 'HANDLES'
HND: DW DOCON2,_HND_TO,_HND_AT
handles dw   0,0,0,0,0,0,0,0,0
xDROPH1:CALL SUB4TH
        DW   HND,TZBRAN,@@1,HND+4
        DW   TCLOSE,TDROP,HND
        DW   TZEQ,TZBRAN,@@1,ZR,TOBLK,STDIO
@@1:    DW   TRETF
        MOV  al,0dh
        RET

 NF 'FOPEN'
OPENF: DW  JSR1
TOPEN DW XOPEN
 DW  TBLWORD,TONEPL,TOPEN,TDUP
 DW TZLESS,BADW,TEXIT

 NF 'CLOSE'
TCLOSE: DW XCLOSE
TCLOSEF: DW  CALL_D2,XDROPH1


        nf 'TYPE'
tTYPE:  dw   jsr,_GTR,tcntDo,tdo,@@2
@@1:    dw   ti,tcat,temit,tloop,@@1
@@2:    dw   tex?tR

 NF 'EXPECT'
texpect:dw   jsr,_GTR,TDUP2,TCNTDO,TDO,@@22
@@1:    Dw   TKEY,TLIT,255,TAND,TDUP,TI
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
@@22:   Dw   ToSpan,tdrop,TEX?TR

dovoc:  scasw
        scasw
  call _does
  dw toCont,texit

        scasw
doDef:  scasw
  call _does
  dw toCurr,texit

; -------------TEXT INTERPRETTER   -------------vvvvvvvvvvv
;       TO_DO
;  : ( C" ) WORD DROP ; IMMEDIATE     ( nf '("'      ; (" (". ". )
  NFI '('
  DW JSR,TLIT,')',TWORD,TDROP,TEXIT  ;

;  : EXECUTE PUSH ;
  NF 'EXECUTE'
XEXECUT  DW JSR,TTOR,TEXIT

;
;  0 NM: BLK PUSH >IN PUSH EXECUTE POP TO >IN POP TO BLK ;M
  NF ';TI'
XINTER: DW JSR
        DW TRFR,BLK@,TTOR,TOIN@,TTOR,TIB@,TTOR,TTOR,TRPAT
        DW TRFR,TOTIB,TRFR,TOTOIN,TRFR,TOBLK,TEXIT

;  HEADER EVAL , ] 0 TO BLK  0 TO TIB  TO >IN  TO INTERPRET [
     NF 'EVAL'
     DW JSR,XINTER,ZR,TOBLK,ZR,TOTIB,TOTOIN,AINT

;  HEADER LOAD , ] 0 TO >IN  TO BLK  TO INTERPRET [
     NF 'LOAD'
     DW JSR,XINTER,ZR,TOTOIN,TOBLK,AINT
;

 NF 'NBLK'
      DW XRBLK,XWBLK
TVBLK DW XVBLK,TIB@,TIB@
VBLOCK DW XNOP
VFLUSH DW XNOP

  NF 'BLOCK'
  DW XPVECT,XFRAME,VBLOCK

  NF 'FLUSH'
  DW XPVECT,XFRAME,VFLUSH

 NF 'FLOAD'
LOADF: DW  JSR,HND,BS,TSUBT,TZEQ,BADW
 DW  OPENF                 ; ,REMARK   ;SKIP LINE
LOADF2: DW  HND+2,FILEIO,MO,TOBLK ;,TEXIT
 DW  TRDROP,FSYS2

 nf  '?,'
tqcomm: dw xqcomm,XNONA2,XNONAME

 NF 'EXEC'
texec   DW   XEXEC      ; EXEC
aqexec  DW   xqexec     ; ?EXEC
tperf   DW   XPERF      ; PERFORM

  NF 'vEHND'
erINI DW  ExecAt1,SETVAR,0

  nf 'F83'
TF83  DW JSR,decim,Aforth,aforth+2,TEXIT

  nf 'ABORT'
ABORT:  DW  _ABORT
tSABRT: dw  jsr    ; ,_GTR     ;CALL SUB4TH  ;(ABRT")
        dw  tSKPs,tswap,tZbran,@@3
        DW  TCR,here,N_ID,BLK@,TOSCR,TOIN@,TOCSP
        DW  tsDot,TCR,ABORT
@@3:    Dw  tdrop,TEXIT  ; tex?tR
_ABORT: CALL WRESET
        dw  TF83
@@1:   dw  HND,TZBRAN,@@2,TCLOSEF,TBRAN,@@1
@@2:   DW  STDIO     ; ,erINI,
       DW FSYSTEM


  nf 'FORTH'
Aforth: dw DoVoc,dodef,dovar,lastw,0

apos0 DW JSR,TBLFIND,TQDUP,TZEQ,BADW,TEXIT

 NF ''''
apos DW JSR,APOS0,TDROP,TEXIT

 NF 'FIND'
tfind: dw jsr1
T_FIND DW X_FIND
   DW    ttor,mo,TORDER,TWCOUNT
   DW    TFOR,@@1,TWCOUNT,TFETCH,TSWAP,TNEXT
;,Aforth+4,tfetch
;  DW    AMACRO+4,TFETCH
;  dw    TLATEST,CLATEST
@@1: DW  TDROP,CONT@,TFETCH,trfr,t_FIND,TQCOMM+2,TEXIT

 nf '-FIND'
tblfind DW JSR,_GTR,TBLWORD,TFIND,TEX?TR

 NF 'WORD'
TWORD   DW  xword      ; WORD
tBLword DW  xBLword    ; BLWORD
T_W     DW  X_W        ; word
xblWord:
  push bx
  mov  bl,' '
xword: call sub4th
       dw  _GTR,BLK@,TVBLK,TOin@,Here,t_W,toTOin,tex?tR

  nf 'INTERPRET'
Ainterp: dw  jsr1
Aint:DW XJMP    ; TO INTERPRET
     dw TBLfind,TQdup,TzBRAN,@@2,tQcomm,Aint
@@2  dw actoi,BADW,TZLIT,Aint

  nf '?E'
      dw   jsr,stat@,tsabrt
     dstr 'Executing?'
      DW  TEXIT

  nf '?C'
ON_COMP:  dw   jsr,stat@,tzeq,tsabrt
     dstr 'Compiling?'
      DW  TEXIT

  nf '??'
badw: dw   jsr,_GTR,tsabrt
     dstr 'Not Found'
      DW  TEX?TR

  nf    'QUERY'
Aquery  dw jsr,_GTR,tib@,Tlit,80,texpect
        DW TSPACE,tex?tR

  nf    'QUIT'
fsystem: dw  XJMP,R0@,tRpSt,zr,toBlk,skobaL,FSYS2
FSYS1: DW XJMP,blk@,TNL,FSYS2
FSYS2: dw XJMP,Aquery,ZR,toToIn
       dw tib@,span@,tplus,tZStor
       DW Ainterp,FSYS1

 nf 'eol'
TNL DW xvblk,tcr,blk0,tdrop

blk0 dw JSR,_GTR
       DW STAT@,TZEQ,TZBRAN,@@2
       DW T_SDOT
       DB 3,' Ok'
@@2    DW TCR
@@3    DW TEX?TR

  nf    'NUM'
Actoi:  dw jsr1
TC2I: DW XC2I
  dw  _GTR,tdup,tcount,tplus,ttor
  dw  base@,mo
  dw   Tdup,ttor,zr,TC2I,TONEPL
  dw    tzbran,@@1,tdnegat
 @@1: dw trfr,toDbl,tRfr,tex?tR

  nf 'DECIMAL'
decim dw xbase
      db  10

  nf 'HEX'
      dw xbase
      db  16

  nf 'BINARY'
      dw  xbase
      db  2
; -------------TEXT INTERPRETTER   -------------^^^^^^

; ------------  COMPILER  --------------------vvvvvvvv

; : C" TO WORD 1+ C@ [',] LITERAL ; IMMEDIATE
  NFI 'C"'
  DW JSR,TBLWORD,TONEPL,TCAT,LITERAL,TEXIT

; : ['] ' ?C TO , AT , , ; IMMEDIATE
  NFI '['']'
  DW JSR,APOS,ON_COMP,TCOMP,TLIT,TCOMMA,TEXIT

; : LINK+ HERE TO >< , ;
  NF 'LINK+'
  DW JSR,HERE,T@SWP2,TCOMMA,TEXIT

; : 'C CREATE , IMMEDIATE DOES> ?C @ , C" " WORD ", ;
   NFI '''C'
   DW JSR,ACREATE,TCOMMA,IMM,TCODESEMI
   CALL _DOES
   DW ON_COMP,TFETCH,TCOMMA,TLIT,'"',TWORD,TSTRCOM,TEXIT

; : STR, (FOR [ >MARK ] COUNT C, TO (FOR [ TO >MARK ] DROP ;
  nf 'STR,'
TSTRCOMMA:  DW JSR,TFOR,@@1
       DW TCOUNT,TCOMMAB,TNEXT
@@1:   DW TDROP,TEXIT

; : (( CREATE , , IMMEDIATE DOES> STR , AT EXEC ;
  NF '(('
  DW JSR,ACREATE,TCOMMA,TCOMMA,IMM,TCODESEMI
DOIMMD: CALL _DOES
        DW TSTR,TCOMMA,TPERF,TEXIT

;       ----  TODO -----
  NF 'W,'
WCOMMA  DW JSR,TWCOUNT,TCOMMA,TEXIT
PJUMP:  DW JSR,TRFR,TPLUS,TTOR,TEXIT

; : MAKER CREATE NOT 3 AND 2* DUP C, +JUMP , , , ' ,
;       ' , DOES> COUNT HEADER +JUMP W, W,  W, AT EXEC ;
  NF 'MAKER'
   DW JSR,ACREATE,TNOT,TLIT,3,TAND,T2STAR,TDUP,TCOMMAB,PJUMP
   DW TCOMMA,TCOMMA,TCOMMA,APOS,TCOMMA,TCODESEMI
   CALL _DOES
   DW TCOUNT,AHEADER,PJUMP,WCOMMA,WCOMMA,WCOMMA,TPERF,TEXIT


 nf '("'      ; (" (". ".
tLITSTR:dw  jsr2             ;(LIT")
t_SDOT: DW  JSR3             ;(".
tSDOT:  DW  JSR3,tSKPs,texit ; ".
        Dw   tSKPs,tCouNT,tTYPE,texit

 nf '?C'
XQCOMP: DW      JSR,STAT@,TZEQ
        DW      TSABRT
        DSTR    'COMPILING !',0
        DW      TEXIT

  NF 'ALIAS'
TBIND:  DW JSR,AHEAD2,TCOMP,XNONAME,tcomma,TEXIT

x?comp: call _DOES
        dw   tcat,apos0,TTOR,tPlus,TRFR,tretf
        JMP  XQCOMM

 NF '>MARK'
TMARK    DW JSR2        ;  >MARK >RESOLVE 0,
TRESOLVE DW XRESOLV,JSR1
         DW HERE,tcomP,0,TEXIT

 NF 'ALLOT'      ; ALLOT  -ALLOT RECOVER
tallot: DW JSR4,JSR2,JSR,TWO,TNEGATE,@H,TPSTORE,TEXIT

  nf '=?'
      dw   jsr,TSUBT,tsabrt
     dstr 'Unpaired'
      DW  TEXIT

  nfI    'LITERAL'
literal dw jsr,stat@,tZbran,LITE,DOlit
LITE:dw texit;  noth    dw ext

  NF '?LITERAL'
TZLIT:dw JSR,_GTR,dbl@,tOnepl,tZbran,@@1
     DW STAT@,TZBRAN,@@2
     dw TSWAP,literal,TDUP
@@1: DW TDROP,LITERAL
@@2: DW TEX?TR

  nf ';code'
tCODESEMI dw jsr,tRFR,tsetcf,texit

  NFI 'DOES>'
  DW JSR2,JSR3,JSR4,TCOMP,TCODESEMI,TLIT,_DOES,TCOMPB
  DB 0E8H
  DW HERE,TTWOPL,TSUBT,TCOMMA,TEXIT

  NF 'N>C'
tnamcf  DW XNAMCF

  nf  '",'
tstrcom dw   jsr,tcat,tonepl,Tallot,texit

  NF 'CREATE'
ACREATE:dw   JSR1
AHEAD2: DW  AHEAD4,AHEADER,tCOMP,DoVar,TEXIT

  nf 'CFA'
CFA:    DW   DOCON2,SETVAR1    ; AT CFA = CFA !
TSETCF  DW   XCFAst,0
                               ;  |-----  VALUE TO SWAP WITH
  nf 'VSWAP'                   ;  V V--  ADDRESS OF VARIABLE TO SWAP
VSWAP:  DW   X@SWAP,DO_SWAP,DOVAR,0,0

  NF '?SAME'
DUPLICA DW  ExecAt1,SETVAR,XNOP

  NF 'HEADER'
AHEADER:DW   JSR1,SETVAR1,TLIT,0,TQDUP,TZBRAN,AHEAD3
        DW   TONEMI,AHEADER+2                ;,CURR@,AMACRO+2
        DW   HERE,CFA+2,VSWAP+2,CFA,TBIND    ; ,IMM
        DW   VSWAP+2,TEXIT                   ; TOCURR,TEXIT   ;
AHEAD3: DW   AHEAD2,HERE,CFA+2,TEXIT
AHEAD4: call sub4th
        DW   DUPLICA
        DW   tlatest,tBLword    ; latest bl WORD
        dw   Tdup,Curr@,tstore1     ; dup current @
        dw   tstrcom,tcomma,TEXIT   ; ! c@

xbase: call _does
       dw Tcat,toBase,texit

xstate: call _does
  dw  tcatf,toStat,texit

  nf ']'
skobaR dw xstate
  db -1

  nfi '['
skobaL dw xstate
  db 0

  NF 'USE:'
  DW JSR,HERE,DOCOLON,TEXIT

  nf ':'
colon  dw jsr,AHEADER,asmudge,DOCOLON,TEXIT

  NF 'DO:'
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

;  nf 'SMUDGE'
asmudge dw xsmg ; AT IMMEDIATE = smudge
   db 32

xsmg:   CALL _does
        dw   TCAT,tlatest,tXORTO,texit

 nfi 'AT'
 DW  X?COMP
 DB  4

 nfi 'TO'
 DW  X?COMP
 DB  2

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

; ------------  COMPILER  --------------------^^^^^

 NF 'C!'
tcstore DW   XCSTOR     ; C!
        DW   XNSTO      ; FLD!
        DW   XNLOD      ; FLD@
 NF 'C@'
tcat    DW   XCAT       ; C@
tcatf:  dw   XCATF      ; C@W

  nf 'S0'
S0@    dw XUVAR@0
toS0   dw XtoUVR
    dw  UvS0-Uv0

  nf 'R0'
R0@    dw XUVAR@0
toR0   dw XtoUVR
    dw  UvR0-Uv0

  nf 'HERE'
Here     dw XUVAR@
toH    dw XtoUVAR
 @H    dw X@UVAR
    dw  UvH-Uv0
;    dw  iH*2

  nf 'BASE'
BASE@  dw XUVAR@0
toBASE dw XtoUVR
    dw  UvBASE-Uv0

  nf 'CURRENT'
CURR@  dw XUVAR@
toCURR dw XtoUVAR
TLATEST dw XUVAR@@
    dw  UvCURR-Uv0

  nf 'CONTEXT'
CONT@   dw XUVAR@
toCONT  dw XtoUVAR
CLATEST dw XUVAR@@
    dw  UvCONT-Uv0

  nf 'TIB'
TIB@   dw XUVAR@0
toTIB  dw XtoUVR
    dw  UvTIB-Uv0

  nf 'BLK'
BLK@   dw XUVAR@0
toBLK  dw XtoUVR
    dw  UvBLK-Uv0

  nf 'SELF'
      dw XUVAR@
      dw XtoUVAR
      dw X@SELFP  ; @ SELF +
    dw  UvSELF-Uv0

  nf '>IN'
TOIN@  dw XUVAR@0
toTOIN dw XtoUVR
    dw  UvTOIN-Uv0

  nf 'STATE'
STAT@  dw XUVAR@0
toSTAT dw XtoUVR
    dw  UvSTAT-Uv0

  nf 'SPAN'
SPAN@  dw XUVAR@0
toSPAN dw XtoUVR
    dw  UvSPAN-Uv0

  nf 'DBL'
DBL@   dw XUVAR@0
toDBL  dw XtoUVR
    dw  UvDBL-Uv0

  nf 'OUTC'
OUTC@   dw XUVAR@0
toOUTC  dw XtoUVR
    dw  UvOUT-Uv0

  nf 'CSP'
CSP@   dw XUVAR@0
toCSP  dw XtoUVR
    dw  UvCSP-Uv0

  nf 'SCR'
SCR@    dw XUVAR@0
toSCR   dw XtoUVR
    dw  UvSCR-Uv0

  nf 'VOCLINK'
        dw XUVAR@0
        dw XtoUVR
    dw  UvVOCL-Uv0

  NF 'FIRST'
        dw XUVAR@0
        dw XtoUVR
    dw  UvFIRST-Uv0

  NF 'LIMIT'
        dw XUVAR@0
        dw XtoUVR
    dw  UvLIMIT-Uv0

  NF 'MTOP'
        dw XUVAR@0
        dw XtoUVR
    dw  UvMTOP-Uv0

  NF 'MPTR'
        dw XUVAR@0
        dw XtoUVR
    dw  UvMPTR-Uv0

  NF 'SPTR'
        dw XUVAR@        ;  dw XUVAR@
        dw XtoUVAR       ;dw XtoUVAR
        dw X@UVAR        ;dw X@UVAR
    dw  UvSPTR-Uv0


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
    DW   XM1STOR    ; -1!

  nf '0'
zr     dw  _zero
tZstor DW  XZSTOR   ; 0!

  nf '2'
two dw docon,2

  nf '1'
one dw docon,1

 nf '(PAUSE'
TPAUSE dw xPause
TWAKE  dw XWAKE

  nf    'C>N'
cfname  dw XFNAME

 nf 'EXIT'
texit   DW   XEXIT      ; EXIT
tretf   DW   XRET4TH    ; R4TH>
BYE     DW   0
 NF '(BR'
tbran   DW   XBRAN      ; BRANCH
tzbran  DW   XZBRAN     ; 0BRANCH
TNZBRAN DW   XNZBRAN    ; !BRANCH
 NF '(OF'
tof     DW   XOF        ; (OF
 NF 'D,'
tcommad DW   xcommd     ; D,
tdlit   DW   xdlit      ; DLIT
 NF ','
tcomma  DW   XCOMMA     ; ,
tcomp   DW   XCOMPW     ; COMPILE
tlit    DW   XLIT       ; LIT
 NF 'C,'
tcommab DW   XCOMMAB    ; C,
tcompb  DW   XCOMPB     ; BCOMPILE
tblit   DW   XBLIT      ; BLIT
 NF 'RP'
tRpGt   DW   XRPGT      ; RP@
tRpSt   DW   XRPST      ; RP!
TRpAt   DW   X_CO       ; SI<>[RP]
 NF 'POP'
trfr    DW   XRFR       ; R>
        DW   X2RFR      ; 2R>
        DW   X3RFR      ; 3R>
 NF 'PUSH'
ttor    DW   XTOR       ; >R
        DW   X2TOR      ; 2>R
        DW   X3TOR      ; 3>R
 NF 'R@'
trat    DW   XRAT       ; R@
        DW   X2RAT      ; 2R@
        DW   X3RAT      ; 3R@
 NF '(FOR'
tfor    DW   XFOR       ; (FOR
tnext   DW   XNEXT      ; (NEXT
 NF '(DO'
        DW   XDOP      ;  (DO
tdo     DW   XDO       ; (?DO
tcntDo  DW   xcntdo     ; CntDo
 NF '(LP'
tloop   DW   XLOOP      ; (LOOP
tploop  DW   XPLOOP     ; (+LOOP
 NF 'LEAVE'
tleave  DW   XLEAVE     ; LEAVE
tfromf  DW   XFROMF     ; 4TH>
tbp     DW   xbp        ; brkPnt
 NF 'AND'
tand    DW   XAND       ; AND
TOand   DW   XTOAND       ; AND!
XTOAND: POP AX
        AND [BX],AX
        DROPREG
 NF 'CMOVE'
        DW   XCMOVE     ; <CMOVE
        DW   XCMOVUP    ; CMOVE>
        DW   XMOVE      ; CMOVE
 NF 'FILL'
tFILL   DW   XFILL      ; MOVE
 NF 'NEGATE'
TNEGATE DW   XNEGATE    ; NEGATE
tdnegat DW   XDNEGAT    ; DNEGATE
 NF 'DROP'
tdrop   DW   XDROP      ; DROP
tdrop2  DW   XDROP2     ; 2DROP
TRDROP  DW   XRDROP     ; RDROP
 NF 'DUP'
tdup    DW   XDUP       ; DUP
TDUP2   DW   XDUP2      ; 2DUP
        DW   XTUCK      ; TUCK

 NF 'SPACE'
tSPACE  DW   xblank     ; BLANK
TSLICE  DW   XSLICE     ; TIMESLICE
TQKEY   DW   XQKEY      ; ?KEY

 NF 'KEY'
TKEY    DW  XKEY
 NF 'EMIT'
TEMIT   DW  XEMIT

 NF '<'
TLESS   DW   XCHK       ; <
        DB   -1,0,0
 NF '='
tequal  DW   XCHK       ; =
        DB   0,-1,0
 NF 'U<'
TULESS  DW   XUCHK      ; U<
        DB   -1,0,0
 NF 'S>D'
        DW XSTOD
        DW XBTOD
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
ti      DW   XI         ; I
 NF 'B>W'
        DW   XLO        ; LO
        DW   XHI        ; HI
 NF 'OR'
        DW   XORE       ; OR
        DW   XTOORE       ; OR!
XTOORE: POP AX
        OR  [BX],AX
        DROPREG
 NF 'OVER'
tover   DW   XOVER      ; OVER
TOVER2  DW   XOVER2     ; 2OVER
        DW   XPICK      ; PICK
 NF '+'
tplus   DW   XPLUS      ; +
        DW   XDPLUS     ; D+
tpstore DW   XPSTORE    ; +!
 NF '?DUP'
tqdup   DW   XQDUP      ; ?DUP
 NF 'ROT'
trot    DW   XROT       ; ROT
tmrot   DW   XMROT      ; -ROT
        DW   XROLL      ; roll
 NF 'SP'
TSPGT   DW   XSPGT      ; SP@
tSpSt   DW   XSPST      ; SP!
 NF '!'
tstore1 DW   XSTORE1    ; !
TSTORE2 DW   XSTORE2    ; 2!
 NF '@'
tfetch  DW   xfetch     ; @
TTWOAT  DW   XTWOAT     ; 2@
 NF 'FA'
        DW   XTWOATA    ; FA
        DW   XSTOREA    ; TO FA
        DW   XCOMMF     ; AT FA

 NF '-'
tsubt   DW   XSUBT      ; -
        DW   XDMINUS    ; D-
 NF 'SWAP'
tswap   DW   XSWAP      ; SWAP
tswap2  DW   XSWAP2     ; 2SWAP
        DW   XATSWAP    ; @SWAP

 NF '><'
tflip   DW   XFLIP
T@SWP2  DW   XATSWP2
        DW   XC@SWAP
 NF '1-'
tonemi  DW   XONEMI     ; 1-
        dw   xm1sto     ; DUP @ 1- SWAP !
tM1at   DW   XMINS@,1   ; 1-!@
 NF '2-'
ttwomi  DW   XTWOMI     ; 2-
        dw   xm2sto     ; 2-!
tM2at   DW   XMINS@,2  ; 2-!@
 NF '1+'
tonepl  DW   XONEPL     ; 1+
        dw   xp1sto     ; 1+!
tAtP1   DW   X@PLUS,1   ; @1+!
 NF '2+'
TTWOPL  DW   XTWOPL     ; 2+
        dw   xp2sto     ; 2+!
tAtP2   DW   X@PLUS,2   ; @2+!
 NF '@+!'
        DW X@PLSTO
        DW XALLOTM
 NF 'PC1+'
tPC1PLS DW   XPC1PLS    ; PC1+
tPC2    DW   XPC2PLS    ; PC2+
tSKPs   DW   XSKPS      ; (")
 NF '16/'
        DW   X16SLS     ; 16/
        DW   X32SLS     ; 32/
        DW   X64SLS     ; 64/
 NF '2/'
        DW   X2SLS      ; 2/
        DW   X4SLS      ; 4/
        DW   X8SLS      ; 8/
 NF '2*'
T2STAR  DW   X2STAR     ; 2*
        DW   X4STAR     ; 4*
        DW   X8STAR     ; 8*
 NF 'U/MOD'
        DW   XUMSLS     ; U/MOD
        DW   XUMSLSM    ; UM/MOD
 NF 'UM*'
        DW   XUMSTAR    ; UM*
 nf 'XOR'
txor    DW   XXORX      ; XOR
txorTo  DW   xxorto     ; XOR!
tNOT    DW   xNOT       ; NOT

 NF 'MAX'
tmax    DW   xmax       ; MAX
t0max   DW   x0max      ; 0MAX
 NF 'MIN'
tmin    DW   xmin       ; MIN
        DW   X0MIN
 NF 'NOOP'
Xnop    DW   JSR,_GTR,TEX?TR
TEX?TR  DW   _CALL
XEX?TR: X
        POP  AX
        POP  SI
        X
        JMP _XCH_EX

 NF 'ORIGIN+'
        DW   @MYARY     ;DW   xorig      ; ORIGIN+
        DW   XQARY      ; 4* ARRAY
        DW   _NEXT
 NF 'UNPACK'
        DW   xUNpack      ;
apack   DW   xpack      ;
        DW   x@Npack      ;

    NF 'ATTR'
     dw      DOVAR
ATTR DB 26
VPAG DB 0

; ---------------    DEBUGER  ------------------vvvvvvvvv

  nf 'H.'
hdot  dw $+2
  XCHG ax,bx
  call regout
  dropreg

 NF '-TR'
_TR:  DW  _CALL
      JMP SHORT _CLR_TR

 NF 'TR'
_NTR: DW  _CALL
_SET_TR:mov   al,0B9h
_XCH_EX:XCHG  pb _ex,al
        ret

      NF 'TR?'
_GTR: DW  _CALL
      X
      PUSH  PW _EX
      X
_CLR_TR:mov   al,97h
      JMP   _XCH_EX

debugerr:
        mov   pw saveSi,si
        mov   pw saveAX,AX
        call  _CLR_tr
        call  j4th
        DW   TDUP2,HDOT,HDOT,TSPGT,HDOT
        DW   TRPGT,HDOT,TRAT,HDOT
        dw   sav_Si,tdup
        dw   ttwomi,tdup,hdot
        DW   TSWAP,TFETCH,HDOT
        dw   tfetch,hdot,HERE,HDOT
        dw   SAV_AX,v_ID
        dw   tfromf
        xor  ax,ax
        int  16h
        and  al,0dfh
        cmp  al,'S'
        PUSHF
        CALL NEW_CR
        call _SET_tR
        POPF
        jne  @@2
        call _CLR_tr
@@2:    mov  si,saveSi
        mov  di,saveAX
        jmp  [di]

sav_AX  dw   DoCon
saveAX  dw   0

sav_si  dw   DoCon
saveSi  dw   0

  nf    'ID.'
N_ID    DW    JSR,Tcount,Tlit,31,Tand,TtYpE
NOTV_id Dw Tspace,TexIt

  NF    '?ID.'
V_id:   dw    jsr,cfname,TQdup,TZBran,NotV_id
  dw tonemi,one,tof,@@1,t_sdot
  dstr 'to '
  dw tbran, @@3
@@1 dw two,tof,@@2,t_sdot
  dstr 'at '
  dw tbran,@@3
@@2: ; dw tdup,tonepl,tcat,tzeq,tbran,@@3,tdrop,tlitstr
     ; dstr '<nil>'
  dw tdrop
@@3: dw N_ID,TEXIT


; ---------------    DEBUGER  ------------------^^^^^^^^^^^

  ; ------------------  ARM 7 -----------------vvvvvvvvvvvv
    NF  'ARES'    ; ARM RESULT REGISTER (READING ONLY)
    DW   DO2CON2      ; LARE'S VALUE
  LARE:  DW   DOCON2
    DW  DOCON2   ; ERRA'S VALUE
  HARES  DW  0
  LARES  DW  0
  ERRA   DW  0     ; ERROR NUMBER IN ARM

       NF      '?CS:'
  segc dw      X?CS,X?SS      ; ?CS: , ?SS:
; armn dw      DOVAR
;      dstr    '..\ArM_r /m'
;
;      nf      'RELINK'
; relink       dw  jsr,prsntz,LARE,TZbran,relink2
; relink1      dw  connectz,LARE,TZbran,relink3,TexIt         ;if err
; relink2      dw  armn,shellz,LARE,TZbran,relink1       ; no err
; relink3      dw  bye

  FretCS: PUSH    CS      ;SEGMENT PART
  FretAR: PUSH    BX      ;OFFSET PART OF ADDRESS
  retDX:  SCASW
          XCHG    AX,BX
          mov     cx,offset pushaR
          push    cs
          push    cx
          xchg    sp,bp
          push    si ES DX
          xchg    sp,bp
          jmp     DI

  PUSHAR: MOV   HARES,DX
          MOV   LARES,AX
          CLD
          LES   DX,[BP]
          JC      @@1
          XOR     DI,DI
  @@1:    MOV     ERRA,DI
          JMP   XLEAVDR


       nf      'SHELL'
  shellz:
       dw      fretCS
  _shell:
       push    ds
       push    bp
       mov     dx,ss
       mov     bp,sp
       lea     ax,[bp-4]
       cli
       xchg    dx,pw cs:old_ss    ; save old vars to stack
       xchg    ax,pw cs:old_sp    ;
       push    dx                 ;
       push    ax                 ;
       sti
       xor     bx,bx
       lds     si,[bp+8]
       mov     bl,[si]
       lea     cx,[bx+4]  ; п░иго▓в┐не  на CX = д║лжина▓а + 4
       and     cl,0feh
       sub     sp,cx
       lea     cx,[bx+1]
       cld
       mov     ax,ss      ; copy line to stack
       mov     di,sp
       mov     es,ax
       rep     movsb
       mov     ds,ax
       mov     al,13      ; CR to end of line
       stosb
       mov     si,sp      ; DS:si points to line

       int     2eh        ; dos line executor
       cli
       mov     ax,0
  old_ss       =  $-2     ; restore ss:sp
       mov     ss,ax      ;
       mov     sp,0       ;
  old_sp       =  $-2     ;
       pop     pw cs:old_sp       ;
       pop     pw cs:old_ss       ;
       sti
       mov     ah,4dh     ;
       int     21h        ; dos extended Error number
       pop     bp
       pop     ds
       retf    4

;      nf      'A-PRSNT'
; prsntz:
;      dw      fretaR
; prsnt:mov     ax,0f100h
; _prsnt2:
;      PUSH    AX
;      call    is_here
;      jNc     _prsnt
;      inc     di
;      jne     _prsnt
;      inc     ax
;      jne     _prsnt
;      mov     ax,es
;      cmp     si,ax
;      jne     _prsnt
;      POP     AX
;      mov     PB my_process,ah
;      JMP     SHORT _PRESENT
; my_INT_func: mov     aH,pb my_process
;      db      0b9h
; is_here:mov  al,0
;      int     my_int
;      ret
; _prsnt:
;      POP     AX
;      INC     AH
;      jnZ     _prsnt2
; not_installed:
; not_present:
;      XOR     AX,AX
;      retF
;
;      nf      'A-CONN'
; connectz:
;      dw      fretaR
; connect:
;      push    cs
;      call    prsnt
;      or      al,al
;      je      not_installed
;      mov     si,cs
;      mov     es,si
;      mov     bx,offset  arm_ptr
;      mov     di,offset unit_eptr
;      MOV     AL,instal_cod
;      call    my_int_func
; _present:
;      mov     aX,1
;      retf
;
;      nf      'A-QUIT'
;      dw      fretaR
; quit_arm:
;      push    cs
;      call    prsnt
;      or      al,al
;      je      not_installed
;      MOV     AL,QUIT_cod
;      call    my_int_func
;      jc      not_present    ; on top
;      mov     es,ax
;      mov     ah,49h
;      int     21h
;      jc      not_present
;      jmp     short  _present
;
; @@1: SUB     AL,200
;      db      0eah
; unit_eptr    dd         0
;
;      nf      'FUNA'
;      dw      retdx
;      CMP     AL,200
;      JAE     @@1
;      mov     ah,0
; my_process   = $-1
;      db      0eah
; arm_ptr      dd         0
;
; ------------------  ARM 7 -----------------^^^^^^^^^^^^^^^^^

; NF  '-WIN'
;TWIN2 DW _WIND2
;TWIN1 DW _WIND1
;TWIN0 DW _WIND0

  NF 'PAUSE'
VPAUSE DW  ExecAt1,SETVAR,XNOP

  NF 'INITW'
INITW DW  ExecAt1,SETVAR,0

DtoP=$
lastw = ppppp

;       db   tbp      ;brkpt
MyCseg  ends
        end  Start
