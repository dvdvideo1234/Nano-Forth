; ARCHITECTURE OF FORTH MASHINE
; IP   = SI
; RP   = BP
; SP   = SP
; TOP  = BX
; SCRATCH   AX CX DI

; COMMANDS OF FORTH MASCHINE
; ------------------------
; 4 COMMANDS IN 2 BYTE CHUNKS
; ------------------------
; + XOR AND     +C  U2/C
; DUP DROP POP PUSH  SWAP
; @+ !+ LIT
; IF ; NOP CALL  JUMP NEXT
; IF,   JMP,  NEXT & CALL IN 1 & 3 SLOT ARE:
; +C   ;:     U2/C   SWAP
; ------------------------
; SUBS IMPLY START ON EVEN ADDRESSES

; -----------------------
; MACROSES
; : ! !+ DROP ;
; : NIP  SWAP DROP ;
; : @ @+ NIP ;
; : XCHG POP SWAP PUSH ;
; : ROT PUSH SWAP POP SWAP ;
; : -ROT SWAP PUSH SWAP POP ;
; : 2* DUP + ;
; : 2*C DUP +C ;
; : CLC 2* U2/C ;
; : U2/ CLC U2/C ;
; : RDROP POP DROP ;
; : AJUMP ( NUM) PUSH ;
; : NIP PUSH DROP POP ;
; : OVER  PUSH DUP POP SWAP ;
; : NUP   DUP  PUSH SWAP POP ;
; : 2DROP DROP DROP ;
;
;
;

; SEMPLES
; : INV -1 XOR ;
; : OR OVER -1 XOR AND XOR ;
; : 1 1 ;   : 0 0 ;  : -1 -1 ;  : -2 -2 ;   : 2 2 ;
; : 1- -1 + ;    : 1+ 1 + ;
; : NEGATE INV 1+ ;
; : 2/ DUP 2* DROP U2/C ;
; : RJUMP POP @+ + PUSH ;
; : ;2DROP ;: 2DROP ;
; : DOVAR ;: ;
; : EXECUTE PUSH ;
; : MOVE ?FOR 2DROP ;THEN
;        BEGIN PUSH @+ POP !+ NEXT 2DROP ;

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

nfC    macro   token,PCODE
  NF   TOKEN
  DW   PCODE
  endm

Inf     macro   token
ppppp = $
  dstr2 token,080h
  dw    qqqqq
qqqqq = ppppp
  endm

InfC    macro   token,PCODE
  INF   TOKEN
  DW  PCODE
  endm

.386

MyCseg  segment para  use16
        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg

        org 100h
Start   Label byte
;       JMP   SHORT  UvSET
        mov     bx,1000h
        mov     ah,4ah
        int     21h
;       call Wreset
;       DW   TF83,INITW,aINTERP,FSYS1


 INFC 0,XEXIT

 nf '>CODE'
 DW XFROMF
XFROMF: JMP   SI

SUB4TH: x
        push  si
        x
J4th:   POP   SI
        JMP  _next

 nf 'NIP'
tNIP:   DW   XNIP       ; EXIT
xnip:   PUSH BX
        pop  EBX
        next

 nf 'EXIT'
texit   DW   XEXIT      ; EXIT

 NF 'else'
tbran   DW   XBRAN      ; BRANCH

 NF 'PUSH'
ttor    DW   XPUSH      ; >R
XPUSH:  POP   AX
        XCHG  AX,BX
XPUSHZ: DEC   BP
        DEC   BP
        MOV   [BP],AX
        NEXT

  NFC   'CALL',$+2
        LODSW
CFZ0:   XCHG   AX,SI
        JMP    XPUSHZ
DOESZ:  POP    AX
        PUSH   BX
        LEA    BX,[DI+2]
        JMP   SHORT CFZ0

 NF 'POP'
trfr    DW   $+2        ; R>
 PUSH BX
 MOV  BX,[BP]
 JMP  XRDROP

 NF 'IND'
trat    DW   XRAT       ; R@

 NF 'AND'
tand    DW   XAND       ; AND


 NFC 'LIT',$+2
        LODSW
        PUSHREG

 NF 'DROP'
tdrop   DW   XDROP      ; DROP

; NF 'OVER'
; tover   DW   XOVER      ; OVER

 NF 'DUP'
tdup    DW   XDUP       ; DUP

 NF 'KEY'
; tkey    DW   XKEY       ; KEY

 NF 'EMIT'
; temit   DW   XEMIT      ; EMIT

 NFC 'OR',XORE

 NF '+'
tplus   DW   XPLUS

 NF '-'
tsubt   DW   XSUBT

; NF 'SWAP'
; tswap   DW   XSWAP

; NFC '2/',X2SLS


 NFC 'UM/MOD',$+2
        POP  CX
        XOR  AX,AX
        CMP  CX,BX
        JNB  @@1
        XCHG CX,DX
        pop  AX
        DIV  BX
        XCHG CX,DX
        PUSH CX
@@1:    swapreg

_CALL:  SCASW
        CALL   DI
        JMP    _NEXT

 nfC ';>CODE',$+2
        PUSH  SI
popR:   x
        pop   SI
        x
        RET

 nfC 'ODD',$+2
     AND  BX,1
     NEXT

 nfC '0<',$+2
        SHL   BX,1
CARRY:  SBB   BX,BX
        next

 NFC   'BRK',$+2
        int  3
        next

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

XAND:   POP  AX
        AND  BX,AX
        JMP  SHORT _next

XORE:   POP  AX
        OR   BX,AX
        JMP  SHORT _next

 nf 'XOR'
txor    DW   $+2
        POP  AX
        XOR  BX,AX
        JMP  SHORT _next

xsubt:  neg  bx
XPLUS:  POP  AX
        ADD  BX,AX
        JMP  SHORT _next

XRAT:   mov  Ax,[bp]
        JMP  SHORT _PUSHAX

XZBRAN: OR    BX,BX
        je    XBR_DR
        JMP   XPC2_DR
XBR_DR: POP   BX
XBRAN:  mov   si,[si]
        JMP   _next

XEXIT:  mov  si,[bp+0]
xrdrop: inc  bp
        inc  bp
        JMP SHORT _NEXT

XOF:    POP  AX
        XCHG BX,AX
        CMP  AX,BX
        JNZ  XBRAN
        JMP  SHORT XPC2_DR

XQDUP:  OR   BX,BX
        JZ   _NEXT

XDUP:   PUSH BX
        JMP  SHORT _next

jsr4:   scasw
jsr3:   scasw
jsr2:   scasw
jsr1:   scasw
JSR:    DEC  BP
        DEC  BP
        MOV  [BP],SI
XJMP:   mov  si,di
XPC_P:  INC  SI
        INC  SI
        JMP  SHORT _next

dovar2: scasw
dovar1: scasw
DOVAR:  JMP  SHORT DOVARZ
XPC2_DR:LODSW
xdrop:  pop  bx
        JMP  SHORT _NEXT

        scasw
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
;       JMP  DEBUGerr

 NFC '!',$+2
X0EXIT: OR    BX,BX
        POP   BX
        JNE   _NEXT
        JMP  XEXIT

 NFC 'TUCK',$+2
        POP  AX
        PUSH BX
        PUSH AX
        NEXT

 NFC '1-!',XM1STO

 NFC '2-!',$+2
        DEC  pw [BX]
XM1STO: DEC  pw [BX]
        DROPREG

 NFC '1+!',XP1STO

 NFC '2+!',$+2
        INC  pw [BX]
XP1STO: INC  pw [BX]
        DROPREG

 NFC '!',$+2
        POP  PW [BX]
        DROPREG

 NFC 'XOR!',$+2
        POP  AX
        XOR  [BX],AX
        DROPREG

 NFC 'C!',$+2
        POP  AX
        MOV  [BX],AL        ; NOT USED YET
        DROPREG

 NFC '+!',$+2
        POP  AX
        ADD  [BX],AX
        DROPREG

 NFC 'SWAP',$+2
        POP  AX
        PushReg

 NFC 'OVER',$+2
        POP  AX
        PUSH AX
        PushReg

 NFC 'ROT',$+2
        POP  CX aX      ; ax cx bx->
        PUSH CX         ; cx bx ax
        PushReg

 NFC '-ROT',$+2
        POP  aX cX      ; cx ax bx->
        PUSH bx CX      ; bx cx ax
        swapReg

DO2CON2:SCASW
DO2CON1:SCASW
DO2CON: SCASW
DO2CON0:PUSH BX
        MOV  BX,DI
XTWOAT: PUSH PW [BX+2]
xFETCH: MOV  BX,[BX]
        NEXT

 NFC '@',xFETCH

 NFC '2@',xTWOAT

 NFC 'C@',XCAT

 NFC '256%',XLO

 NFC '256/',XLO

  NFC '@+',$+2
        MOV   AX,[BX]
        INC   BX
        INC   BX
        PUSHREG

 NFC 'C@+',$+2
        inc  bx
        PUSH BX
        DEC  BX
XCAT:   MOV  BH,[BX]
xhi:    xchg bh,bl
xlo:    MOV  BH,0
        NEXT

 NFC '1-',XONEMI

 NFC '2-',$+2
        DEC  BX
XONEMI: DEC  BX

        NEXT

 NFC '2/',$+2
        SAR  BX,1
        NEXT

 NFC '2*',$+2
        SHL  BX,1
        NEXT

 NFC 'UM*',$+2
        POP  AX
        XCHG BX,DX
        MUL  DX
        PUSH AX
        XCHG BX,DX
        NEXT

 NFC ';:',X_CO

 NFC '(W"',$+2
XSKPSW: CALL _XSKPS
        lodsW
        RET

 NFC '(B"',$+2
        CALL _XSKPS
        lodsb
        RET

_XSKPS: POP  CX
        push bx
        xchg si,[bp]
        xor  ax,ax
        mov  bx,si
        CALL CX
        add  si,ax
X_CO:   XCHG SI,[BP]
        next

 NFC '2SWAP',$+2
        POP  cX aX DI
_SWAP2Z:PUSH cX BX DI
        swapreg

 NFC '2OVER',$+2
        POP  cX aX DI
        PUSH DI aX  ;cX BX DI ;swapreg
        JMP  SHORT _SWAP2Z

 NFC 'DNEGATE',_CALL
_DNEGAT:POP  DI
        POP  AX
        XOR  CX,CX
        NEG  AX
        SBB  CX,BX
        MOV  BX,CX
        PUSH AX
        JMP  DI

 NFC 'D+',XDPLUS

 NFC 'D-',$+2
        CALL _DNEGAT
XDPLUS: POP  AX
        POP  DI
        POP  CX
        add Cx,Ax
        adC bx,DI
        PUSH CX
        next

XWARY:  shl  BX,1
XBARY:  ADD  BX,DI
XTWOPL: INC  BX
XONEPL: INC  BX
        next

 NFC '1+',XONEPL

 NFC '2+',XTWOPL

_KEY1:  MOV  AH,0
        INT  016h
_emit2: ret

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

_MOVER: POP  CX
        POP  DI AX
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
        CMP  DI,AX
        JBE  _MOVE1
        JMP  SHORT _MOVEU

XCMOVUP:CALL _MOVER
_MOVEU: ADD  DI,CX
        ADD  AX,CX
        DEC  AX
        DEC  DI
        STD
        JMP  SHORT _MOVE1

xfill:  POP     CX
        POP     DI
        push cs
        pop  es
        xchg ax,bx
        REP  stosb
        DROPREG

_BSCANR:STD
_SCANER:POP  AX
        XCHG EAX,EBX
        POP  CX
        POP  DI
        push cs
        pop  es
        PUSH CX
        CALL BX
        POP  BX
        JE   @@1
        MOV  CX,BX
@@1:    INC  CX
        SUB  BX,CX
        CLD
        NEXT

FSCAND: CALL _SCANER
        REPNE SCASD
        RET

FSCANW: CALL _SCANER
        REPNE SCASW
        RET

FSCANB: CALL _SCANER
        REPNE SCASB
        RET

XATSWAP:POP  AX
        XCHG PW [BX],AX
        PUSH AX
        next

handles DW   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

_HND_GT:mov  DI,offset handles ;
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
;        JMP  XDROPH1

XOPEN:  MOV DX,BX
        MOV AX,3D02H
        DB  0B9H
XCLOSE: MOV AH,3EH
XDOS1:  INT 21H
        JNC @@1
        NOT AX
@@1:    SWAPREG

XaLPHA: XCHG AX,BX
        XOR  AH,AH
        CMP  AL,10
        JB   @@1
        ADD  AL,7
@@1:    ADD  AL,'0'
        SWAPREG

XPERF:  MOV  bX,[BX]
xqexec: or   bx,bx
;        JZ   X_set             ;???
XEXEC:  XCHG AX,BX
        POP  BX
_ex2:   jmp  _ex

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
        RET
regout: call outWord
space1: mov  al,' '
        jmp short outc

_EMIT1: MOV  DL,BL
        MOV  AH,2
        INT  021h
        ret

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


X_W:  mov   di,bx ; _WORD
      pop   bx
      pop   ax
      pop   dx
      push  di
      push  si
      xor   si,si
      xchg  ax,si
      inc   di
      DEC   BX
@@1:  INC   BX
      mov   al,[si+bx]
      or    al,al
      je    @@3
      cmp   al,dl
      je    @@1

@@2:  inc   ah
      stosb
      inc   bx
      mov   al,[si+bx]
      or    al,al
      je    @@4
      cmp   al,dl
      jNe   @@2
      inc   bX
      JMP   SHORT @@4
@@3:  INC   AH
@@4:  mov   al,0
      stosb
      pop   si
      pop   di
      push  di
      mov   [di],ah
      NEXT  ; _WORD_

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
        ADC   BX,0
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


DERR    DW 0
SCRH    DW 0

XWBLK:  MOV   CH,40H
        DB    0B8H
XRBLK:  MOV   CH,3FH
        MOV   AX,1024
        PUSH  CX
        PUSH  AX
        MUL   BX
        XCHG  AX,DX
        XCHG  AX,CX
        MOV   BX,SCRH           ;
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
@@1:    MOV   DERR,AX        ;
@@2:    DROPREG

; COMPILATION WORDS
;
;   NF 'ALIAS'
; TBIND:  DW JSR,AHEAD2,TCOMP,XNONAME,tcomma,TEXIT
;
;  NF 'ALLOT'      ; ALLOT  -ALLOT RECOVER
; tallot: DW JSR,@H,TPSTORE,TEXIT
;
;
;   nf 'FORTH'
; Aforth: dw DoVoc,dodef,dovar,lastw,0
;
;  NF 'FIND'
; tfind: dw jsr1
; T_FIND DW X_FIND
;    DW    ttor,mo,TORDER,TWCOUNT
;    DW    TFOR,@@1,TWCOUNT,TFETCH,TSWAP,TNEXT
; @@1: DW  TDROP,CONT@,TFETCH,trfr,t_FIND,TQCOMM+2,TEXIT
;
;  nf '-FIND'
; tblfind DW JSR?TR,TBLWORD,TFIND,TEX?TR
;
;  NF 'WORD'
; TWORD   DW  xword      ; WORD
; tBLword DW  xBLword    ; BLWORD
; T_W     DW  X_W        ; word
; xblWord:
;   push bx
;   mov  bl,' '
; xword: call sub4th
;        dw  _GTR,BLK@,TVBLK,TOin@,Here,t_W,toTOin,tex?tR
;
;   nf 'INTERPRET'
; Ainterp: dw  jsr1
; Aint:DW XJMP    ; TO INTERPRET
;      dw TBLfind,TQdup,TzBRAN,@@2,tQcomm,Aint
; @@2  dw actoi,BADW,TZLIT,Aint
;
;   nf '=?'
;       dw   jsr,TSUBT,tsabrt
;      dstr 'Unpaired'
;       DW  TEXIT
;
;   nf '??'
; badw: dw   jsr?TR,tsabrt
;      dstr 'Not Found'
;       DW  TEX?TR
;
;   NFI '[LIT]'
; DOLIT:  DW  DOIMMD,TLIT,TCOMMA
; DOIMMD: CALL _DOES
;         DW TSTR,TCOMMA,TPERF,TEXIT
; ; : (( CREATE , , IMMEDIATE DOES> STR , AT EXEC ;
;
;   nfI    'LITERAL'
; literal dw jsr,stat@,tZbran,LITE,DOlit
; LITE:dw texit;  noth    dw ext
;
;   NF '?LITERAL'
; TZLIT:dw JSR?TR,dbl@,tOnepl,tZbran,@@1
;      DW STAT@,TZBRAN,@@2
;      dw TSWAP,literal,TDUP
; @@1: DW TDROP,LITERAL
; @@2: DW TEX?TR
;
;   nf    'QUERY'
; Aquery  dw jsr?TR,tib@,Tlit,80,texpect
;         DW TSPACE,tex?tR
;
;   nf    'QUIT'
; fsystem: dw  XJMP,R0@,tRpSt,zr,toBlk,skobaL,FSYS2
; FSYS1: DW XJMP,blk@,TNL,FSYS2
; FSYS2: dw XJMP,Aquery,ZR,toToIn
;        dw tib@,span@,tplus,tZStor
;        DW Ainterp,FSYS1
;
;   nf    'NUM'
; Actoi:  dw jsr1
; TC2I: DW XC2I
;   dw  _GTR,tdup,tcount,tplus,ttor
;   dw  base@,mo
;   dw   Tdup,ttor,zr,TC2I,TONEPL
;   dw    tzbran,@@1,tdnegat
;  @@1: dw trfr,toDbl,tRfr,tex?tR
;
;   nf ';code'
; tCODESEMI dw jsr,tRFR,tsetcf,texit
;
;   NFI 'DOES>'
;   DW JSR,TCODESEMI,TLIT,_DOES,TCOMPB
;   DB 0E8H
;   DW HERE,TTWOPL,TSUBT,TCOMMA,TEXIT
;
;   NF 'N>C'
; tnamcf  DW XNAMCF
;
;   nf  '",'
; tstrcom dw   jsr,tcat,tonepl,Tallot,texit
;
;   nf ':'
; colon  dw jsr,AHEADER,asmudge,DOCOLON,TEXIT
;
;   NFI ';M'
; DOSEMI DW DOIMMD,TEXIT,SKOBAL   ;  = MAC: ' EXIT , [ ;
;
;   nfi ';'
; semi   dw jsr,asmudge,DOSEMI,texit
;
;

: ?INDEX POP A! POP INVERT POP + A PUSH ;

: ;SCAN RDROP RDROP DROP -1 ;

: SCAN  DUP PUSH ?FOR ;SCAN ;THEN BEGIN
        @A+ OVER XOR IF DROP NEXT ;SCAN ;THEN
        DROP DROP ?INDEX ;

: SCANB DUP PUSH ?FOR ;SCAN ;THEN BEGIN
        C@A+ OVER XOR IF DROP NEXT ;SCAN ;THEN
        DROP DROP ?INDEX ;

: SKIPB DUP PUSH ?FOR ;SCAN ;THEN BEGIN
        C@A+ OVER + -IF DROP NEXT ;SCAN ;THEN
        DROP DROP ?INDEX ;

: SRC-ADV PUSH >IN TIB# POP /STR TO TIB# TO >IN ;

: SOURCE TIB >IN + TIB# ;

: PARSE 256% SOURCE  ?FOR NIP 0 ;THEN A! DUP INV 32
 ( WHITE SPACE ?)
        IFC PUSH DUP INV POP DUP ?FOR
           FOR C@A+ -33 +
              -IF DROP
           NEXT DROP ( DELIMITER) POP SRC-ADV A 0
              ;THEN
           DROP ?INDEX SRC-ADV SOURCE SWAP A!
        THEN DUP PUSH
        FOR C@A+ OVER XOR
          IF DROP
        NEXT DROP SOURCE POP SRC-ADV
          ;THEN
        DROP SOURCE DROP ?INDEX DUP 1+ SRC-ADV ;





: PARSE 256% SOURCE  IF SWAP A! ELSE ROT DROP ;THEN
     DUP 33 U<C ( WHITE SPACE ?)
        IFC PUSH DUP INV
           FOR C@A+ -33 +
              -IF DROP
           NEXT DROP ( DELIMITER) POP SRC-ADV A 0
              ;THEN
           DROP ?INDEX SRC-ADV SOURCE SWAP A!
        THEN DUP PUSH
        FOR C@A+ OVER XOR
          IF DROP
        NEXT DROP SOURCE POP SRC-ADV
          ;THEN
        DROP SOURCE DROP ?INDEX DUP 1+ SRC-ADV ;

DtoP=$
lastw = ppppp

MyCseg  ends
        end  Start

