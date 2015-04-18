locals  @@
; 0898150510 EROTICHEN BUTIC
pd  equ dword ptr
pw  equ word  ptr
pb  equ byte  ptr

_TO =   2
_AT =   4
_VAL =  6

PushReg MACRO
         jmp  _PushAx
        ENDM
SWAPREG MACRO
         JMP _SWAPAX
        ENDM
DROPREG MACRO
         JMP _DROP
        ENDM
next    MACRO
         jmp  _nop
        ENDM
X       MACRO
         xchg sp,bp
        ENDM

qqqqq = 0
ppppp = qqqqq

_nam    macro   msg
  local endstr
  db    endstr-$-1
  db    msg
endstr  label   byte
        endm

_VAR    macro   LBL
LBL     DW      DOVAR
        ENDM

_PRIM   macro   LBL
LBL     DW      $+2
        ENDM

_XT     macro   LBL,token
LBL     DW      TOKEN
        ENDM

_ln     macro   token
ppppp = $
  _nam  token
  dw    qqqqq
qqqqq = ppppp
        endm

head    macro  nam, lbl, val1
        _ln    nam
        _XT    LBL,VAL1
        endm

primitive macro nam,lbl
        _ln    nam
        _PRIM  lbl
        endm

primitiv macro nam,lbl,dat
        _ln    nam
        _XT    lbl,dat
        endm

_colon2 macro  lbl
LBL     DW     DOCOLON-1
        endm

_colon  macro  lbl
LBL     DW     DOCOLON
        endm

_colonP macro  lbl
        DW     XT_SKIP
        _COLON LBL
        endm

colon   macro  nam,lbl
        _ln    nam
        _COLON lbl
        endm

_value  macro  lbl,dat
lbl     DW     docons2,setvar,dat
        endm

value   macro  nam,lbl,dat
        _ln    nam
        _value lbl,dat
        endm

_vecto  macro  lbl,dat
lbl     DW     deferO,setvar,dat
        endm

_DEFER  macro  lbl,dat
lbl     DW     defer,dat
        endm

_vector macro  lbl,dat
lbl     DW     defer2,setvar,dat
        endm

_point  macro  lbl,dat
lbl     DW     dopoint,setpoint,dat
        endm

_QUAN   MACRO  LBL,DAT
        _XT    lbl,docons3
        DW     setvar2,@XPE,dat
        ENDM

quan    macro  nam,lbl,dat
        _ln    nam
        _QUAN  LBL,DAT
        endm

_const  macro lbl,dat
lbl     DW    doconst,DAT
        endm

_entry  macro nam,dat
        DW    DAT
        db    0
        _nam  nam
        endm

MyCseg  segment para  use16
        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg


        org 100h
Start   Label byte
        JMP SELF0

;       ORG 4103H

SELF0:  CALL SELF2
SELF1:
   _entry   'ENTRY',XT_ENTRY
   _entry   '',0   ; LAST WORD

xt_states dw _arw,xt_clit,xt_num,xt_comma,xt_exec

; -----------------------
; Constants
; -----------------------

        _CONST  xt_zer,0
        _CONST  xt_BL,' '
        _CONST  XT_HBUF,0FF00H

; -------------------
; Variables
; -------------------

        _DEFER  xt_ACCEPT,XT_ACPT
        _DEFER  xt_ERR,XT_INITQ
        _DEFER  xt_OKV,0
        _vectoR xt_key,xt_dkey
        _vecto  xt_emit,xt_demit
        _POINT  xt_SEARCH,0
        _value  xt_ltb,0
        _value  xt_etb,0
        _value  xt_cntc,0
        _VALUE  xt_tib,128
        _QUAN   XT_here,freemem
        _QUAN   xt_last,SELF1

; -------------------

SELF2:  CALL MOVER      ; relocator

; -------------------
; Initialisation  and main loop
; -------------------

_restart:cld
        MOV  bp,XT_HBUF+_TO
        LEA  sp,[BP-1024]
        call _toforth
        dw   xt_lbrak,xt_tib,xt_count
xsyslp  dw   xt_eval,xt_OKV,xt_tib,xt_LIT,126
        dw   xt_accept,xt_br,xsyslp

        _COLON xt_eval
        dw xt_TOEVAL,XT_ltb+_TO,Xt_etb+_TO
_int:   dw XT_TOKEN,XT_0BR,DO_DROPX
        dw xt_SEARCH,xt_states,xt_perform,xt_br,_int

MOVER:  mov  bx,1000h     ; only 64k allocate
        mov  ah,4ah
        int  21h
        POP  BX           ; and relocate
        MOV  DI,[BX-5]    ; CELL + [CAL]
        MOV  CX,[BX-13]   ; 5 CELLS + [CAL]
        SUB  CX,DI
        POP  AX
        SUB  BX,AX
        ADD  BX,DI
        PUSH BX
CMOVEU: ADD  DI,CX
CPUSHU: DEC  DI
        ADD  AX,CX
        DEC  AX
        STD
CMOVE:  XCHG AX,SI
        REP  MOVSB
        XCHG AX,SI
        CLD
        RET

; ------------------------
; ENTRY LIST
; ------------------------

        _COLON XT_TOKEN
        DW XT_BL,XT_PARS,XT_HBUF,XT_MOVSTR,XT_LDB,XT_EXIT

        _COLON XT_REM
        DW XT_PARS,XT_DROP
DO_DROPX: DW XT_DROPX

        _COLON  xt_entry
        DW XT_ZER,XT_TOKEN,XT_NZ?,XT_LDB
        DW XT_LAST+_AT,XT_NTRY,XT_EXIT

; ------------------------
; parsing
; ------------------------

        _XT  XT_number,@ninu
        push BP
        MOV  di,10  ; num base
        xchg ax,Di  ; ENDBUF
        deC  BX     ; back one char
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

        _xt  XT_PARS,@nup
        mov  ax,PW [XT_etb+_AT]
        xchg ax,bx
        mov  dx,ax
        mov  DI,PW [XT_ltb+_AT]
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
@@worde:mov  PW [XT_ltb+_AT],di
        rET

; -------------------
; Inner Interpreter
; -------------------
DEFERO: INC   PW [XT_CNTC+_AT]
defer2: scasw
DEFER:  push  bx
        MOV   bx,di
_perform:mov  bx,[bx]
_exec:  pop   ax
        xchg  ax,bx
        OR    AX,AX
        JE    _0
        jmp   SHORT _nop1
_toforth: pop si
        jmp   SHORT _nop

_arw:   add   bx,bx      ; array of words
_arb:   lea   bx,[bx+di] ; array of bytes
_0:     JMP   SHORT _nOP

setpoint:mov  [di],si
        jmp   SHORT _exit
dopoint:mov   AX,[di+2]
        JMP   SHORT PCPUSH

        _XT   XT_DOES,DOVAR-1
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
_call:  lodsw
        jmp   pcpush
        scasw
        scasw
docolon:xchg  ax,di
        jmp   SHORT pcpush
docons3:scasw
docons2:scasw
doconst:mov   ax,[di]
        jmp   SHORT _pushw
dovar:  MOV   ax,di
        jmp   SHORT _pushw

@Swap:  POP   AX
        DB    0B9H
@over:  pop   ax
        push  ax
@PuSha: CALL  DI

_pushw: push  bx
_swapw: xchg  ax,bx

_nop:   lodsw
_nop1:  xchg  di,ax
        LEA   DI,[DI+2]    ; !!!
        jmp   Pw [di-2]    ; !!!

_?dup:  or    bx,bx
        je    _nop
_dup:   push  bx
        next

@dinu:  POP   dX
@ninu:  POP   AX
@nup:   CALL  DI
_PHA:   PUSH  AX
        NEXT

setvar2:scasw
setvar: mov   [di],bx
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

_ifm:   inc   bx
        dec   bx
        js    _skip
_jump:  mov   si,[si]
        next
_FOR:   SUB   BX,1
        JNC   @@1
        DEC   BX
@@1:    JS    _JUMP
        LODSW

_push:  pop   ax
        xchg  ax,bx
        jmp   _rpush
_NEXT:  DEC   PW [BP]
        JNS   _JUMP
        LODSW

_pop:   push  bx
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


; -------------------
; String
; -------------------

       _XT  XT_strpc,@NIP      ; S+C!
XSTRPC: MOV  DI,255
        inc  PB [bx]
        AND  DI,[BX]
        MOV  [BX+DI],AL
        RET

        _XT  XT_NTRY,@cnip      ; (NTR
        POP  DI         ; \ !!! DROP RETURN ADDRES
        INC  CX
        MOV  DI,BX
        CALL CPUSHU
        STD             ; !!!
        POP  aX
        STOSB
        DEC  DI
        MOV  BX,DI
        CLD             ; !!!
        POP  AX
        STOSW
        NEXT

        _XT  XT_movSTR,@cnip    ; S!
_MOVSTR:MOV  [BX],CL
        LEA  DI,[BX+1]
        JMP  CMOVE

@XPE:   CALL  _DOES
        DW  xt_@xpe,XT_POP,XT_STW,XT_DROPX

; -----------------------
; Terminal Input / Output
; -----------------------

        _XT  XT_acpt,@swap      ; (DA
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

        _XT  XT_demit,@DRoP     ; (DE
        xchg Bx,dx
        mov  ah,2
        int  021h
        RET

        _XT  XT_dkey,@pusha     ; (DK
        mov  ah,7
        int  021h
        JMP  _LOBYTE

; -------------------
; Peek and Poke
; -------------------

        _XT  XT_count,@pusha    ; CSTR
        JMP  _COUNT

        _XT  XT_LDB,@PUSHA      ; C@.
        mov   AL,[BX]
        JMP  _LOBYTE

        _XT  XT_STW,@nip        ; !.
        mov   [BX],ax
        RET

        _XT  XT_STR,@pusha      ; STR
        MOV   AX,[BX]
_2:     INC   BX
_1:     INC   BX
        RET

        _xt  XT_storep,@nip     ; !+
_storep:MOV   PW [BX],AX
        JMP   SHORT _2

; -----------------------
; searching
; -----------------------

        _XT XT_find,@pusha      ; FIND      ;ON INTERPRET
        CALL  _FIND
@@2:    INC   AX
        RET

        _XT XT_findC,@pusha     ; FINDC     ;ON COMPILE
        MOV   AL,'`'
        CALL  XSTRPC
        CALL  _FIND
        JNZ   @@2
        DEC   PB [BX]
_FIND:  push  si
        mov   SI,[XT_last+_VAL]
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

        _xt xt_eqz,@nop         ; 0=
        CMP    BX,1
        SBB    BX,BX
        rET

        _xt XT_lit,@PUSHA       ; (#
        lodsw
        RET

;       _XT  XT_1P,_1PX

        _XT  XT_TOEVAL,@ninu    ; >EVAL
        ADD   AX,BX
        NEG   BX
        RET

; -------------------
; Stack
; -------------------

        _XT XT_drop,_DROP       ; DROP
        _xt XT_pop,_pop         ; POP
        _xt XT_push,_push       ; PUSH

; -----------------------
; Colon Definition
; -----------------------

        _XT XT_semicolon,_does0 ; ;`
        dw xt_exit,xt_lbrak

        _XT XT_colon,_does1     ; :
        dw docolon,xt_rbrak

; -------------------
; Compilation
; -------------------

        _COLON  XT_COMMA        ; ,
        DW XT_HERE+_AT
        DW XT_STOREP,XT_EXIT

        _xt XT_litcom,_does0    ; (#,
        dw xt_lit,xt_comma

        _COLON XT_CODECOM       ; CODE,
        dw XT_HERE,XT_ENTRY,xt_comma,xt_exit

_does0: call _does  ; like ;
        dw xt_STR,xt_comma,xt_perform,xt_exit

_does1: call _does  ; like :
        dw XT_STR,XT_CODECOM,xt_perform,xt_exit

        _COLON xt_clit          ; (NUM,
        dw xt_num,xt_litcom,xt_exit

; -------------------
; Flow Control
; -------------------

        _XT XT_@XPE,_@XPE       ; @XPE
        _XT XT_0BR,_0BR         ; (0BR
        _XT XT_br,_jump         ; (BR
        _xt XT_exec,_exec       ; EXEC
        _xt XT_perform,_perform ; @EXEC
        _XT XT_exit,_exit       ; ;;
        _XT XT_DROPx,_DROPX     ; DROP;
        _xt XT_0ex,_0ex         ; 0;

; -----------------------
; Dictionary Search
; -----------------------

        _COLON XT_lbrak         ; [`  interpreter search
        dw Xt_SEARCH+_TO,xt_find,xt_EXIT

        _COLON XT_rbrak         ; ]   compiler search
        dw Xt_SEARCH+_TO,xt_findC,xt_EXIT

        _COLON xt_num           ; (NUM
        dw xt_count,XT_TOEVAL,xt_number,XT_Z?,xt_EXIT

; -----------------------
; Outer Interpreter
; -----------------------

        _XT XT_QUIT,_RESTART    ; QUIT

        _COLON XT_DO_ERR        ; (ERR
        DW  xt_ERR,XT_PRTC
        DB  '?'
        DW  XT_QUIT

        _COLON XT_NZ?           ; <>0?
        DW  XT_EQZ,xt_0ex,xt_DO_ERR

        _COLON XT_Z?            ; =0?
        DW  xt_0ex,XT_DO_ERR

        _COLON  XT_PRTC         ; C.
        DW XT_POP,XT_COUNT,XT_EMIT,XT_PUSH,XT_EXIT

        _COLON  XT_INITQ        ; (INIT
        DW XT_ZER,XT_TIB,XT_STOREP,XT_DROPX

freemem:

lastw = ppppp

MyCseg  ends
        end  Start

