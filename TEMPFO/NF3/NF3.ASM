; * ÃÚÐÌÈ ÏÎ ÏÀÌÅÒ  
; ÐÀÇÄÅËÅÍÎ Å ÑÅÃÀ ÍÀ 3  È ÑÀ ÇÀÊÎÌÅÍÒÈÐÀÍÈ ÌÀÊÐÎÑÈÒÅ


locals  @@
; 0898150510 EROTICHEN BUTIC
pd  equ dword ptr
pw  equ word  ptr
pb  equ byte  ptr

_TO =   2
_AT =   4
_VAL =  6

;PushReg MACRO
;         jmp  _PushAx
;        ENDM
;SWAPREG MACRO
;         JMP _SWAPAX
;        ENDM
;DROPREG MACRO
;         JMP _DROP
;        ENDM
;next    MACRO
;         jmp  _nop
;        ENDM
;X       MACRO
;         xchg sp,bp
;        ENDM
;
;qqqqq = 0
;ppppp = qqqqq
;
;nam    macro   msg
;  local endstr
;  db    endstr-$-1
;  db    msg
;endstr  label   byte
;        endm
;
;VAR_    macro   LBL
;LBL     DW      DOVAR
;        ENDM
;
;PRIM   macro   LBL
;LBL     DW      $+2
;        ENDM
;
;XT     macro   LBL,token
;LBL     DW      TOKEN
;        ENDM
;
;ln     macro   token
;ppppp = $
;  _nam  token
;  dw    qqqqq
;qqqqq = ppppp
;        endm
;
;head    macro  nam, lbl, val1
;        ln    nam
;        XT    LBL,VAL1
;        endm
;
;primitive macro nam,lbl
;        ln    nam
;        PRIM  lbl
;        endm
;
;primitiv macro nam,lbl,dat
;        ln    nam
;        XT    lbl,dat
;        endm
;
;colon2 macro  lbl
;LBL     DW     @DOCOLON-1
;        endm
;
;colon   macro  lbl
;LBL     DW     @DOCOLON
;        endm
;
;colonP macro  lbl
;        DW     SKIP
;        COLON LBL
;        endm
;
;colon_  macro  nam,lbl
;        ln    nam
;        COLON lbl
;        endm
;
;value  macro  lbl,dat
;lbl     DW     @docons2,@setvar,dat
;        endm
;
;value_  macro  nam,lbl,dat
;        ln    nam
;        value lbl,dat
;        endm
;
;vecto  macro  lbl,dat
;lbl     DW     @deferO,@setvar,dat
;        endm
;
;DEFER_  macro  lbl,dat
;lbl     DW     @defer,dat
;        endm
;
;vector macro  lbl,dat
;lbl     DW     @DEFER2,@setvar,dat
;        endm
;
;point  macro  lbl,dat
;lbl     DW     @dopoint,@setpoint,dat
;        endm
;
;QUAN   MACRO  LBL,DAT
;        XT    lbl,@docons3
;        DW     @setvar2,@XPE,dat
;        ENDM
;
;quan    macro  nam,lbl,dat
;        ln    nam
;        QUAN  LBL,DAT
;        endm
;
;CONST_  macro lbl,dat
;lbl     DW    doCONST_,DAT
;        endm
;
;ENTRY_  macro nam,dat
;        DW    DAT
;        db    0
;        nam  nam
;        endm

MyCseg  segment para  use16
        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg


        org 100h
Start   Label byte
        JMP @_restart   ;SELF0

;       ORG 4103H

;SELF0:  CALL SELF2
SELF1:
   ENTRY_   '=:',ENTR
   ENTRY_   '',0   ; LAST WORD

states dw _arw,clit,num,comma,exec

; -----------------------
; CONST_ants
; -----------------------

        CONST_  zer,0
        CONST_  BLC,' '
        CONST_  HBUF,0FF00H

; -------------------
; Variables
; -------------------

        DEFER_  ACCEPT,ACPT
        DEFER_  ERRV,INITQ
        DEFER_  OKV,0
        vectoR key,dkey
        vecto  emit,demit
        POINT  SEARCH,0
        value  ltb,0
        value  etb,0
        value  cntc,0
        VALUE  tib,128
        QUAN   here,freemem
        QUAN   last,SELF1

; -------------------

SELF2:  CALL MOVER      ; relocator

; -------------------
; Initialisation  and main loop
; -------------------

@_restart:cld
        MOV  bp,HBUF+_TO
        LEA  sp,[BP-1024]
        call _toforth
        dw   lbrak,tib,count
xsyslp  dw   eval,OKV,tib,LIT,126
        dw   accept,br,xsyslp

        COLON eval
        dw TOEVAL,ltb+_TO,etb+_TO
_int:   dw TOKEN,0BR,DO_DROPX
        dw SEARCH,states,perform,br,_int

; -------------------
; String
; -------------------

freemem:
lastw = ppppp
MyCseg  ends
        end  Start

CMOVEU: 
  ADD  DI,CX
CPUSHU: 
  DEC  DI
  ADD  AX,CX
  DEC  AX
  STD
CMOVE:  
  XCHG AX,SI
  REP  MOVSB
  XCHG AX,SI
  CLD
  RET

  XT  strpc,@NIP      ; S+C!
XSTRPC: 
  MOV  DI,255
  inc  PB [bx]
  AND  DI,[BX]
  MOV  [BX+DI],AL
  RET

  XT  PHMSTR,@cnip      ; (NTR PUSH MAKE STR
  MOV  CH,0
  dec   bx
  MOV   [BX],'`'
  CLC
  SBC   BX,CX
  SKIPA

  XT  movSTR,@cnip    ; S!
  MOV  CH,0
  MOV  [BX],CL
  LEA  DI,[BX+1]
  JMP  CMOVE

@XPE:   CALL  _DOES
        DW  @xpe,POP,STW,DROPX

; ------------------------
; ENTRY_ LIST
; ------------------------

        COLON TOKEN
        DW BLC,PARS,HBUF,MOVSTR,LDB,EXIT

        COLON REM
        DW PARS,DROP
DO_DROPX: DW DROPX

        COLON  ENTR
        DW ZER,TOKEN,NZ?,LDB
        DW LAST+_AT,NTRY,EXIT

; ------------------------
; parsing
; ------------------------

        XT  number,@ninu
        push BP
        xchg ax,Di  
        ADD   DI,bx ; ENDBUF
        not   BX
        MOV  AL,10  ; num base
        CALL @@NUM
        POP  BP
        XCHG CX,AX
        RET

@@SGN:  CMP  AL,'-'     ; SGN
        JNE  @@N1
        POP  dX
        CALL dX
        NEG  CX
        RET

@@CNUM: INC  BX
        MOV  AL,[BX+DI]
        JnE  @@noEXN
@@EXNUM:pop  dx    ; rdrop
@@noEXn:RET

@@NUM:  CALL @@NUMini
        CALL @@CNUM
        CALL @@SGN
@@NUMZ: CALL @@CNUM
        CALL @@N1
        JMP  SHORT  @@NUMZ

@@n1:   cmp  al,'$'
        JNE  @@N2
        MOV  al,16
        jmp  SHORT @@setbas

@@N2:   cmp  al,'#'
        JNE  @@N3
        mov  al,cl
@@numini:xor cx,cx      ; ACCUMULATOR
@@setbas:mov bp,ax
        RET

@@N3:   cmp  al,'9'+1
        jc   @@ton2
        AND  AL,0DFH
        cmp  al,'A'      ; no case sensivity
        jc   @@EXNUM
        sub  al,7
@@ton2: sub  al,'0'
        cmp  ax,BP
        jnc  @@EXNUM
        xchg ax,cx
        mul  BP
        xchg ax,cx
        add  cx,ax
        RET

        XT  PARS,@nup
        mov  ax,PW [etb+_AT]
        xchg ax,bx
        mov  dx,ax
        mov  DI,PW [ltb+_AT]
        CMP  AL,' '
        JNE  @@SKIPX
        DEC  di
@@WSKP: INC  di
        JE   @@SKIPX
        MOV  dH,[BX+DI]
        CMP  dL,dH
        JE   @@WSKP
@@SKIPX:LEA  aX,[BX+DI]
        DEC  di
@@WSCZ: INC  di
        JE   @@WEX
        MOV  dH,[BX+DI]
        CMP  dL,dH
        JNE  @@WSCZ
@@WEX:  SUB  bx,aX
        ADD  BX,DI
        or   di,di
        Je   @@WORDE
        INC  di
@@worde:mov  PW [ltb+_AT],di
        rET

; -------------------
; Inner Interpreter
; -------------------
@DEFERO: INC   PW [CNTC+_AT]
@defer2: scasw
@DEFER:  push  bx
        MOV   bx,di
@perform:mov  bx,[bx]
@exec:  pop   ax
        xchg  ax,bx
        OR    AX,AX
        JE    _0
        jmp   SHORT _nop1

_toforth: pop si
        jmp   SHORT _nop

_arw:   add   bx,bx      ; array of words
_arb:   lea   bx,[bx+di] ; array of bytes
_0:     JMP   SHORT _nOP

freemem:
lastw = ppppp
MyCseg  ends
        end  Start


setpoint:mov  [di],si
        jmp   SHORT _exit

dopoint:mov   AX,[di+2]
        JMP   SHORT PCPUSH

        XT   DOES,@DOVAR-1
        scasw
        scasw
_does:  pop   ax
        push  bx
        MOV   bx,di
pcpush: XCHG  AX,SI
_rpush: dec   bp
        dec   bp
        mov   [bp],AX
        JMP   SHORT _nOP

_Xcall: lodsw
        jmp   _rpush

        scasw
        scasw
@docolon:xchg  ax,di
        jmp   SHORT pcpush

@docons3:scasw
@docons2:scasw
@doCONST_:mov   ax,[di]
        jmp   SHORT _pushw

@dovar:  MOV   ax,di
        jmp   SHORT _pushw

@Swap:  POP   AX
        DB    0B9H
@over:  pop   ax
        push  ax
@PuSha: CALL  DI

_pushw: push  bx
_swapw: xchg  ax,bx

_nop:   MOV   DI,[SI]
_nop1:  CMPSW
        jmp   Pw [di-2]    

_?dup:  or    bx,bx
        je    _nop
_dup:   push  bx
        next

@dinu:  POP   dX
@ninu:  POP   AX
@nup:   CALL  DI
_PHA:   PUSH  AX
        NEXT

@setvar2:scasw
@setvar: mov   [di],bx
        jmp   SHORT _drop

_0ex:   or    bx,bx
        jNe   _DROP
_DROPX: pop   bx
_exit:  mov   si,Pw [bp]
_rdrop: inc   bp
        inc   bp
        next

@2drop: POP   AX
@DRoP:  CALL  DI
_drop:  pop   bx
        next

_0br:   SUB   bx,1
        pop   bx
        jC    _jump
_skip:  lodsw
        next

_OF:    POP   AX
        XCHG  BX,AX
        SUB   AX,BX
        JE    _SKIP
        JMP   SHORT _JUMP

_Mif:   inc   bx
_ifm:   dec   bx
        js    _skip
_jump:  mov   si,[si]
        next

_FOR:   
  DEC   BX
_push:  
  pop   ax
  xchg  ax,bx
  jmp   _rpush

_NEXT:  
  SUB   PW [BP],1
  JNC   _JUMP
  LODSW
  jmp   _rdrop

_pop:   
  push  bx
  mov   bx,[bp]
  jmp   _rdrop

@cnip:  POP   cX
@nip:   POP   AX
@nop:   CALL  DI
nop@@:  NEXT

_2MX:   DEC   BX
_1MX:   DEC   BX
        DB    0B9H
_2PX:   INC   BX
_1PX:   INC   BX
        jmp   nop@@

_@xpe:  PUSH  [BX]
_XPE:   X
        POP   AX
        PUSH  BX
        PUSH  SI
        X
        XCHG  AX,SI
        JMP   _DROP

; -------------------
; Inner Interpreter
; -------------------


; -----------------------
; Terminal Input / Output
; -----------------------

        XT  acpt,@swap      ; (DA
        XCHG   AX,BX
        MOV    [BX],AX
        MOV    DX,BX
        MOV    AH,10
        INT    21H
        INC    BX
_COUNT: MOV    AL,[BX]
        INC    BX
_LOBYTE:MOV    AH,0
        RET

        XT  demit,@DRoP     ; (DE
        xchg Bx,dx
        mov  ah,2
        int  021h
        RET

        XT  dkey,@pusha     ; (DK
        mov  ah,7
        int  021h
        JMP  _LOBYTE

; -------------------
; Peek and Poke
; -------------------

        XT  count,@pusha    ; CSTR
        JMP  _COUNT

        XT  LDB,@PUSHA      ; C@.
        mov   AL,[BX]
        JMP  _LOBYTE

        XT  STW,@nip        ; !.
        mov   [BX],ax
        RET

        XT  STR,@pusha      ; STR
        MOV   AX,[BX]
_2:     INC   BX
_1:     INC   BX
        RET

        XT  storep,@nip     ; !+
_storep:MOV   PW [BX],AX
        JMP   SHORT _2

; -----------------------
; searching
; -----------------------

        XT find,@pusha      ; FIND      ;ON INTERPRET
        CALL  _FIND
@@2:    INC   AX
        RET

        XT findC,@pusha     ; FINDC     ;ON COMPILE
        MOV   AL,'`'
        CALL  XSTRPC
        CALL  _FIND
        JNZ   @@2
        DEC   PB [BX]
_FIND:  push  si
        mov   SI,[last+_VAL]
        XOR   cX,CX
noFND:  add   si,cx
        mov   di,bx
        MOV   DX,SI
        LEA   SI,[SI+3]
        mov   cl,[si]
        jcxz  not_fnd
        inc   cx
        repe  cmpsb
        jNZ   nofnd
        inc   cx
        MOV   BX,DX     ;fnd_ok:
        MOV   BX,[BX]
not_fnd:xchg  ax,CX
        SHL   AX,1
        pop   si
        RET

; -------------------
; Maths / Logic / registers
; -------------------

        XT eqz,@nop         ; 0=
        CMP    BX,1
        SBB    BX,BX
        rET

        XT lit,@PUSHA       ; (#
        lodsw
        RET

;       XT  1P,_1PX

        XT  TOEVAL,@ninu    ; >EVAL
        ADD   AX,BX
        NEG   BX
        RET

; -------------------
; Stack
; -------------------

        XT drop,_DROP       ; DROP
        XT pop,_pop         ; POP
        XT push,_push       ; PUSH

; -----------------------
; Colon Definition
; -----------------------

        XT semicolon,_does0 ; ;`
        dw exit,lbrak

        XT colon,_does1     ; :
        dw docolon,rbrak

; -------------------
; Compilation
; -------------------

        COLON  COMMA        ; ,
        DW HERE+_AT
        DW STOREP,EXIT

        XT litcom,_does0    ; (#,
        dw lit,comma

        COLON CODECOM       ; CODE,
        dw HERE,ENTRY_,comma,exit

_does0: call _does  ; like ;
        dw STR,comma,perform,exit

_does1: call _does  ; like :
        dw STR,CODECOM,perform,exit

        COLON clit          ; (NUM,
        dw num,litcom,exit

; -------------------
; Flow Control
; -------------------

        XT @XPE,_@XPE       ; @XPE
        XT 0BR,_0BR         ; (0BR
        XT br,_jump         ; (BR
        XT exec,_exec       ; EXEC
        XT perform,_perform ; @EXEC
        XT exit,_exit       ; ;;
        XT DROPx,_DROPX     ; DROP;
        XT 0ex,_0ex         ; 0;

; -----------------------
; Dictionary Search
; -----------------------

        COLON lbrak         ; [`  interpreter search
        dw SEARCH+_TO,find,EXIT

        COLON rbrak         ; ]   compiler search
        dw SEARCH+_TO,findC,EXIT

        COLON num           ; (NUM
        dw count,TOEVAL,number,Z?,EXIT

; -----------------------
; Outer Interpreter
; -----------------------

        XT QUIT,_RESTART    ; QUIT

        COLON DO_ERR        ; (ERR
        DW  ERRV,PRTC
        DB  '?'
        DW  QUIT

        COLON NZ?           ; <>0?
        DW  EQZ,0ex,DO_ERR

        COLON Z?            ; =0?
        DW  0ex,DO_ERR

        COLON  PRTC         ; C.
        DW POP,COUNT,EMIT,PUSH,EXIT

        COLON  INITQ        ; (INIT
        DW ZER,TIB,STOREP,DROPX

freemem:

lastw = ppppp

MyCseg  ends
        end  Start

