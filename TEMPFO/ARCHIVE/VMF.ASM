locals  @@
pd  equ dword ptr
pw  equ word  ptr
pb  equ byte  ptr

_DUP  MACRO
        LEA SI,[SI-2]
        MOV [SI],AX
      ENDM
_DROP MACRO
         LODSW
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

MyCseg  segment para  use16
        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg

        ORG 100H

Start   Label byte

XRET4TH:POP   CX
        PUSH  BX
        MOV   BX,CX
        RET
XFROMF: JMP   BX

; HEADERLESS EXECUTION CODE GOES HERE

XEXIT:  POP  BX
        NEXT
_DO_next:
        POP   CX
        JCXZ  _SKIP1
        DEC   CX
        PUSH  CX
_SJUMP: MOV   CL,[BX]
        MOV   CH,0
        OR    CL,CL
        JNS   @@1
        MOV   CH,-1
@@1:    ADD   BX,CX
        next

@@3:    DEC  CX
        MOV  CH,FNPAGE/256
        SJMP _EX

_SKIP:  INC  BX
_next:  MOV  CX,[BX]
        INC  BX
        TEST CL,1
        JNE  @@3
        INC  BX
_EX:    XCHG CX,DI
        jmp  pw [di]

_IF:    MOV  CX,AX
        JCXZ _SJUMP
        SJMP _SKIP

_IFM:   OR   AX,AX
        JM   _SKIP
        SJMP _SJUMP

_FOR?:  POP  CX
        DEC  CX
        JM   _SJUMP
        PUSH CX
        SJMP _SKIP

XSLS:   SAR  AX,1
        NEXT
X2MUL:  SHL  AX,1
        NEXT
XUMUL:  POP  DX
        MUL  AX
        PUSH DX
        NEXT

XRAT:   _DUP
        POP  AX
        PUSH AX
        NEXT
X_CO:   POP  CX
        PUSH BX
        MOV  BX,CX
        next

XPOP:   _DUP
        POP  AX
        NEXT

XPUSH:  PUSH AX
        _DROP
        NEXT

XDPLUS: MOV  DX,AX
        _DROP
        ADD [SI-4],AX
        ADC [SI-2],DX
        _DROP
        next

XUMSLSM:MOV  CX,AX
        _DROP
        MOV  DX,AX
        _DROP
        CMP  DX,CX
        JNB  @@1
        DIV  CX

@@1:    _DUP
        MOV  AX,DX
        NEXT

xTary:  shl  Ax,1
x5ary:  ADD  DI,Ax
xqary:  shl  Ax,1
XWARY:  shl  AX,1
XBARY:  ADD  AX,DI
ADRP2:  INC  AX
        JMP  ADRP1

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
xcomma: call sub4th
        DW HERE,TADRSP2,TOHERE,TEXIT
xmax:   pop  ax
        cmp  bx,ax
        jmp  short _mm
xmin:   pop  ax
        cmp  ax,bx
_mm:    jGE  NEXT@@2
        xchg ax,bx
NEXT@@2:next

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
doUVAR2:scasw
doUVAR1:scasw
doUVAR: mov   di,[di+2]
DoUvar0:add   di,offset Uv0
USERV   =    $-2
        ret
Wreset: cli
        cld
        pop  SI
        MOV  DI,PW USERV
        mov  bp,[DI+UvR0-Uv0]
        mov  sp,[DI+UvS0-Uv0]
        xor  BX,BX
        sti
        NEXT

XMULT2: POP   AX
        IMUL  BX
        PUSH  AX
        MOV   BX,DX
        NEXT

        ; -----------  IO  PRIMITIVES  vvvvvvvvvvv
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

_gs_ke: CALL _DOES
        DW  TTWOAT,IOV,TSTORE2,TEXIT

 NF 'SIO'
STDIO:  DW   _gs_ke,_key1,_emit1

  NF 'FIO'
FILEIO: DW   _gs_ke,_key2,_emit1

XEMIT:  call PW [jemit]
        CALL OUTC_1P
        DROPREG

_EMIT1: MOV  DL,BL
        MOV  AH,2
        INT  021h
_emit2: ret

XKEY:   PUSH BX
        call PW [jkey]
        SWAPREG

_BKEY:  DW   _CALL
_KEY1:  MOV  AH,0
        INT  016h
        ret


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
        ; -----------  IO  PRIMITIVES  ^^^^^^^^^^^^^^^

XADRSP1: POP  AX
         MOV  [BX],AL
ADRP1:   INC  BX
         NEXT
CFCH_P1: XOR  AX,AX
         MOV  AL,[BX]
         PUSH AX
         JMP  SHORT ADRP1

XBYE:  POP AX
  MOV AH,4CH
  INT 21H

; CODEMARK - END OF CODE

; COMPILATION WORDS

;--------------------vvvvvvv  CONTROL vvvvvvv--------------
ppppp = $
  dw    81h,qqqqq,TEXIT
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
tcntDo  DW   xcntdo     ; CntDo

 NF '(LP'
tloop   DW   XLOOP      ; (LOOP

 NF '(+LP'
tploop  DW   XPLOOP     ; (+LOOP

 NF 'LEAVE'
tleave  DW   XLEAVE     ; LEAVE

 NF '4TH>'
tfromf  DW   XFROMF     ; 4TH>

;--------------------^^^^^^^  CONTROL ^^^^^^--------------

;--------------------VVVVVV MEMORY  VVVVVVVVVVVV---------------

 NF 'C@'
 NF 'C!'
 NF '@'
 NF '!'

  NF 'C@+'       ; STREEM @ OPERATIONS
TADRP1  DW CFCH_P1

  NF '@+'       ; STREEM @ OPERATIONS
TADRP2  DW FCH_P2

  NF 'C!+'       ; STREEM ! OPERATIONS
TADRSP1  DW XADRSP1

  NF '!+'       ; STREEM ! OPERATIONS
TADRSP2  DW XADRSP2

 NF 'UNPACK'
TUNPACK  DW XUNPACK
 NF 'PACK'
TPACK    DW XPACK
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

 NF 'MAX'
tmax    DW   xmax       ; MAX

 NF 'MIN'
tmin    DW   xmin       ; MIN

 NF 'LOW'
TLOW    DW XLO
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

 NF 'SCRH'
 DW DOCON1,SETVAR
SCRH DW -1

  NF 'ORDER#'
TORDER: DW DOVAR2,_HND_TO,_HND_AT
      DW  1,AFORTH+6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

 NF 'OPEN'
TOPEN DW XOPEN
OPENED DW JSR,ZR,TOEOF,TEXIT
; : FOPEN HANDLES bs - 0= ?? FOPEN DUP 0< A" OPEN ERR" ;

 NF 'FOPEN'
OPENF: DW  JSR_TR,TBLWORD,TONEPL,TOPEN,TDUP,TZLESS,tsabrt
     dstr ' OPEN ERROR '
 DW tex_tr

 NF 'CLOSE'
TCLOSE: DW XCLOSE,XCLOSED
TCLOSEF: DW  CALL_D2,XDROPH1
XCLOSED: CALL SUB4TH
         DW MO,TOEOF,TEXIT

        nf 'TYPE'
tTYPE:  dw   jsr_TR,tcntDo,t?do,@@2
@@1:    dw   ti,tcat,t?emit,tloop,@@1
@@2:    dw   tex_tr

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
EOF?   dw DOCON1
TOEOF  dw SETVAR
LASTCH DW 0

 NF 'RBLK'
      DW XRBLK
 NF 'WBLK'
      DW XWBLK

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

dovoc:  scasw
        scasw
  call _does
  dw toCont,texit

        scasw
doDef:  scasw
  call _does
  dw toCurr,texit

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

; : 1LINE 1 LINES +! OK?  0 TO >IN  TIB 80 EXPECT  CO
;       0  TIB SPAN + C! TO INTERPRET ;
  NF   '1LINE'
LINE1 DW JSR,TOK,REFILL,TRPAT,AINT

  NF 'HANDLES'
HND: DW DOCON2,_HND_TO,_HND_AT
handles dw   0,0,0,0,0,0,0,0,0
xDROPH1:CALL SUB4TH
        DW   HND,TZBRAN,@@1,HND+4
        DW   TCLOSE,TDROP,HND
        DW   TZEQ,TZBRAN,@@1
        DW   ZR,TOBLK,STDIO
@@1:    DW   TCLOSE+2,TRETF
        MOV  al,0dh
        RET

  NF ';TI'
XINTER: DW JSR
        DW TRFR,BLK@,TTOR,TOIN@,TTOR,TIB@,TTOR,TTOR,TRPAT
        DW TRFR,TOTIB,TRFR,TRFR,TOSTREEM,TEXIT

; : ;RBUF ( N -- A )  POP   RP ROT - RP OVER
;    TO RP  PUSH SWAP PUSH   CO POP TO RP ;

  NF ';RBUF'
XBUF DW JSR,TPOP,TRPGT,TROT,TSUBT,TRPGT,TOVER
     DW TRPST,TPUSH,TSWAP,TPUSH,TRPAT,TPOP,TRPST,TEXIT

  NF 'EVAL'
TEVAL:  DW JSR,XINTER,ZR,TOSTREEM,ZR,TOTIB,AINT

  NF 'LOAD'
TLOAD:  DW JSR,XINTER,ZR,TSWAP,TOSTREEM,AINT

 NF 'NBLK'
TVBLK DW XVBLK,TIB@,TIB@,TNOP

 nf  '?,'
tqcomm: dw xqcomm,XNONA2,XNONAME

 NF 'EXEC'
texec   DW   XEXEC      ; EXEC

 NF '?EXEC'
aqexec  DW   xqexec     ; ?EXEC
apos0 DW JSR,TBLFIND,TQDUP,TZEQ,TSABRT,'?'*256+1,TEXIT

 NF 'PERFORM'
tperf   DW   XPERF      ; PERFORM
TOSTREEM  DW JSR,TOBLK,TOTOIN,TEXIT

  NF '''ERR'
erINI DW  ExecAt1,SETVAR,0

  nf 'F83'
TF83  DW JSR_TR,decim,Aforth,aforth+2,tex_tr

  nf 'FORTH'
Aforth: dw DoVoc,dodef,dovar,lastw,0

 NF ''''
apos DW JSR,APOS0,TDROP,TEXIT

 NF '(find'
T_FIND DW X_FIND
tfind: dw jsr
   DW    ttor,mo,TORDER,TWCOUNT
   DW    TFOR,@@1,TWCOUNT,TFETCH,TSWAP,TNEXT
@@1: DW  TDROP,CONT@,TFETCH,trfr,t_FIND,TQCOMM+2,TEXIT

 nf '-FIND'
tblfind DW JSR_TR,TBLWORD,TFIND,tex_tr

 NF 'BLWORD'
TBLWORD DW JSR1,X_W,BLC,TWORD,TEXIT
T_W = TBLWORD+2

 NF 'WORD'
TWORD:   DW  JSR_TR,BLK@,TVBLK,TOin@,Here,t_W,toTOin,tex_tr

Aint:DW XJMP    ; TO INTERPRET
     dw TBLfind,TQdup,TzBRAN,@@2,tQcomm,Aint
@@2  dw actoi,TSABRT
     dstr 'Not Found'
     DW TZLIT,Aint

  NF 'CLOSALL'
ZCLOSE: DW JSR
@@1    dw  HND,TZBRAN,@@2,TCLOSEF,TBRAN,@@1
@@2    DW  TEXIT

  nf 'ABORT'
ABORT:  DW  $+2
        CALL WRESET
       dw  _NTR,TF83,ZCLOSE,skobaL
FSYS2: DW  LOADKBD,TBRAN,FSYS2

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
Actoi:  dw jsr_TR,tdup,tcount,tplus,ttor
  dw  base@,mo,Tdup,ttor,zr,TC2I,TONEPL
  dw    tzbran,@@1,tdnegat
 @@1: dw trfr,toDbl,tRfr,tex_tr

; -------------TEXT INTERPRETTER   -------------^^^^^^

; ------------  COMPILER  --------------------vvvvvvvv
  nf 'CFA'
CFA:    DW   DOVAR,0    ; AT CFA = CFA !

  nf 'H'
ATHERE DW DOVAR,DtoP

; : C" TO WORD 1+ C@ [',] LITERAL ; IMMEDIATE
  NFI 'C"'
  DW JSR,TBLWORD,TONEPL,TCAT,LITERAL,TEXIT

  NFI '['']'   ; : ['] ' ?C TO , AT , , ; IMMEDIATE
  DW JSR,APOS,TCOMP,TLIT,TCOMMA,TEXIT

  NF 'LINK+'            ; : LINK+ HERE TO >< , ;
  DW JSR,HERE,T@SWP2,TCOMMA,TEXIT

   NFI '"C'     ; : 'C CREATE , IMMEDIATE DOES> ?C @ , C" " WORD ", ;
   DW JSR,ACREATE,TCOMMA,IMM,TCODESEMI
SCOMMA:  CALL _DOES
   DW TFETCH,TCOMMA,STRCOMP,TDROP,TEXIT

   NF 'S"'
STRCOMP   DW JSR,HERE,TLIT,'"',TWORD,TSTRCOM,TEXIT

   NFI 'A"'
   DW SCOMMA,TSABRT
tSABRT: dw  jsr_TR
        dw  tSKPs,tswap,tZbran,@@3,erINI
        DW  TCR,here,N_ID,BLK@,TOSCR,TOIN@,TOCSP
        DW  tsDot,TCR,ABORT
@@3:    Dw  tdrop,tex_tr

   NF '(("'
       DW  tSKPs

  nf 'STR,'
TSTRCOMMA:  DW JSR,TFOR,@@1,BCOMMA,TNEXT
@@1:   DW TDROP,TEXIT

  NF '(('     ; : (( CREATE , , IMMEDIATE DOES> STR , AT EXEC ;
  DW JSR,ACREATE,TCOMMA,TCOMMA,IMM,TCODESEMI
DOIMMD: CALL _DOES
        DW TSTR,TCOMMA,TPERF,TEXIT

  NF 'ALIAS'
TBIND:  DW JSR,AHEAD4,TCOMP,XNONAME,tcomma,TEXIT

 NF ','
tcomma:  DW   XCOMMA     ; ,

tlit:   DW   XLIT       ; LIT

 NF 'COMPILE'      ;
TCOMP DW JSR,TRATPW,TCOMMA,TEXIT

 NF 'ALLOT'      ; ALLOT
tallot: DW JSR,ATHERE,TPSTORE,TEXIT

  nfI    'LITERAL'
literal dw jsr,stat@,EXIT0,DOlit,texit;

  NF '?LITERAL'
TZLIT:dw JSR,dbl@,TONEPL,tZbran,@@1
     dw STAT@,EXIT0,TSWAP,literal,TDUP
@@1: DW TDROP,LITERAL,texIt

  nf ';code'
tCODESEMI dw jsr,tRFR,CFA,TSTORE1,texit

RCOMMA: CALL _DOES
  DW TCAT,TCOMMAB,HERE,TTWOPL,TSUBT,TCOMMA,TEXIT

TCALL DW RCOMMA
  DB 0E8H

  NF '?CODE'
CODE? DW JSR,TCALL,SKOBAR,HERE,TLIT,-3,TPLUS,TEXIT

  NF 'NM:'
  DW JSR,TNEGATE,TLIT,_DOES,TPLUS,CODE?,TEXIT

  NFI 'DOES>'
  DW JSR,TCOMP,TCODESEMI,TLIT,_DOES,TCALL,TEXIT

  NF 'CREATE'
ACREATE:dw   JSR,AHEADER,tCOMP,DoVar,TEXIT

  nf ':'
colon  dw jsr,AHEADER,asmudge,DOCOLON,TEXIT

  nfi ';'
semi   dw jsr,asmudge,DOSEMI,texit

  NF 'THEAD'
AHEAD4: DW   JSR ; call sub4th
        DW   CURR@,HERE,T@SWP2,TBLword    ; latest bl WORD
        dw   tstrcom,tcomma,TEXIT   ; ! c@

  NF 'N>C'
tnamcf  DW XNAMCF

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
 NF 'SWAP'
tswap   DW   XSWAP      ; SWAP
 NF '2SWAP'
tswap2  DW   XSWAP2     ; 2SWAP
 NF '(STR'
tSKPs   DW   XSKPS      ; (")
tSKPSW  DW   XSKPSW     ; (")
 NF 'ORIGIN+'
        DW   @MYARY     ;DW   xorig      ; ORIGIN+

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

debugerr:
        mov   pw saveSi,si
        mov   pw saveAX,AX
        TRACE_OFF
        call  j4th
        DW   TDUP2,HDOT,HDOT,TPUSH,TPUSH,TDUP2,HDOT,HDOT
        DW   TPOP,TPOP,TSPGT,HDOT
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

DtoP=$
lastw = ppppp

;       db   tbp      ;brkpt
MyCseg  ends
        end  Start
