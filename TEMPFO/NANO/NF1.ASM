locals  @@

pd  equ dword ptr
pw  equ word  ptr
pb  equ byte  ptr

_TO =   2
_AT =   4
_VAL =  6

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
        jmp  _nop
      ENDM
X     MACRO
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

        ORG 4103H

SELF0:  CALL SELF2
SELF1:
   _entry   '.',XT_nUMO
   _entry   'ENTRY',XT_ENTRY
   _entry   'H.',XT_HPRT
   _entry   ':',XT_COLON
COL@ = $-2
   _entry   '',0
;   DW 0  ; LAST WORD
;   DB 0,0

xt_states dw _arw,xt_clit,xt_num,xt_comma,xt_exec

; -----------------------
; Constants
; -----------------------

        _CONST  xt_zer,0
        _CONST  xt_oNE,1
        _CONST  xt_TWO,2
        _CONST  xt_TRE,3
        _CONST  xt_FLAG,'`'
        _CONST  xt_BL,' '
        _CONST  xt_QM,'?'

; -------------------
; Variables
; -------------------

        _vectoR xt_ACCEPT,XT_ACPT
        _vectoR xt_OK,xt_ok_do
;        _vectoR xt_OK,0
        _vectoR xt_key,xt_dkey
        _vecto  xt_emit,xt_demit
        _POINT  xt_SEARCH,0
        _value  xt_ltb,0
        _value  xt_etb,0
        _value  xt_cntc,0
        _VALUE  xt_tib,128
;       _QUAN   XT_IOB,0
        _QUAN   XT_here,freemem
        _QUAN   xt_last,SELF1

; -------------------

SELF2:  CALL MOVER      ; relocator

; -------------------
; Initialisation  and main loop
; -------------------

_restart:cld
        MOV  bp,-256
        mov  sp,-512
        call _toforth
        DW XT_LIT,COL@,XT_BP,XT_FIND
        DW XT_PWORD
        DW XT_PWORD
;       DW XT_LIST
        DW XT_BYE

        DW XT_LIT,12345,XT_numo     ; !!!

        DW XT_ADRSTR
        _NAM 'DW XT_POP,XT_COUNT,XT_PTYPE,XT_PUSH,XT_EXIT'
        DW XT_COUNT,XT_TYPE
        DW XT_CR
        DW XT_PRTSTR
        _NAM ' HELLO WORLD !'
        DW XT_LIT,128
        DW XT_PWORD

        DW XT_LIT,60
        DW XT_DUMP
;       DW XT_PRTC
;       DB ']'
        DW XT_BYE

        dw   xt_lbrak,xt_tib,xt_count
xsyslp  dw   xt_eval,xt_OK,xt_tib,xt_FLAG
        dw   xt_accept,xt_cr
        dw   xt_br,xsyslp

        _COLON xt_eval
        dw xt_TOEVAL,XT_ltb+_TO,Xt_etb+_TO
_int:   dw XT_TOKEN,XT_0EX,XT_HERE
;        dw xt_dup,xt_id
        dw xt_SEARCH
        dw xt_states,xt_perform,xt_br,_int

        _XT XT_QUIT,_RESTART

        _COLON XT_ABORT
        DW XT_ZER,XT_TIB,XT_STOREP,XT_QUIT

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
CMOVEU0:PUSH BX
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
; ENRTY LIST
; ------------------------

        _COLON XT_TOKEN
        dw XT_LTB,XT_DUP,XT_0EX,XT_DROP,XT_BL,XT_PARS
        DW XT_BL,XT_UMIN,XT_HERE,XT_MOVSTR,XT_CFETCHP,XT_DROPX

        _COLON  xt_entry
        DW XT_ZER,XT_TOKEN,XT_NZ?,XT_HERE,XT_COUNT
        DW XT_LAST+_AT,XT_STDSTR,XT_STDB,XT_STDW,XT_EXIT

; ------------------------
; parsing
; ------------------------

        _XT  XT_number,@ninu
        push BP
        MOV  di,10  ; num base
        xchg ax,Di  ; ENDBUF
        deC  BX     ; back one char
        CALL _NUM
        POP  BP
        XCHG CX,AX
        RET

_SGN:   CMP  AL,'-'
        JNE  _N1
        POP  dX
        CALL dX
        NEG  CX
        RET

_numini:xor  cx,cx      ; ACCUMULATOR
_setbas:mov  bp,ax
_CNUM:  INC  BX
        MOV  AL,[BX+DI]
        JnE  _noEXN
_EXNUM: pop  dx    ; rdrop
_noEXn: RET

_NUM:   CALL _NUMini
        CALL _SGN
_NUMZ:  CALL _CNUM
        CALL _N1
        JMP  SHORT  _NUMZ

_n1:    cmp  al,'$'
        JNE  _N2
        MOV  al,16
        jmp  _setbas

_N2:    cmp  al,'#'
        JNE  _N3
        mov  al,cl
        jmp  _numini

_N3:    cmp  al,'9'+1
        jc   to_n2
        AND  AL,0DFH
        cmp  al,'A'      ; no case sensivity
        jc   _EXNUM
        sub  al,7
to_n2:  sub  al,'0'
        cmp  ax,BP
        jnc  _EXNUM
        xchg ax,cx
        mul  BP
        xchg ax,cx
        add  cx,ax
        RET


        _xt  XT_PARS,@nup
_PARS:  mov  ax,PW [XT_etb+_AT]
        xchg ax,bx
        mov  dx,ax
        mov  DI,PW [XT_ltb+_AT]
        CMP  AL,' '
        JNE  _SKIPEX
        DEC  di
_WSKP:  INC  di
        JE   _SKIPEX
        MOV  dH,[BX+DI]
        CMP  dL,dH
        JE   _WSKP
_SKIPEX:LEA  aX,[BX+DI]
        DEC  di
_WSCZ:  INC  di
        JE   _WEX
        MOV  dH,[BX+DI]
        CMP  dL,dH
        JNE  _WSCZ
_WEX:   SUB  bx,aX
        ADD  BX,DI
        or   di,di
        Je   WORDE
        INC  di
worde:  mov  PW [XT_ltb+_AT],di
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
_EX:    XCHG  SI,[BP]
        NEXT
_XCHG:  XCHG  BX,[BP]
        NEXT

_lit:   lodsw
        DB    0B9H
_over:  pop   ax
        push  ax
        jmp   _pushw

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

_ifm:   inc   bx
        dec   bx
        js    _skip
_jump:  mov   si,[si]
        next
_for:   OR    bx,BX
        JNE   @@FOR
        DEC   BX
@@for:  dec   bx
        js    _jump
        lodsw           ; skip

_push:  pop   ax
        xchg  ax,bx
        jmp   _rpush

_next:  dec   pw [bp]
        jns   _jump
        lodsw           ; skip

_pop:   push  bx
        mov   bx,[bp]
        jmp   _rdrop

@cnip:  POP   cX
@nip:   POP   AX
@nop:   CALL  DI
nop@@:  NEXT

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

;_call:  lodsw
;        jmp   pcpush
;        _XT   XT_DOES,DOVAR-1
;        scasw
;        scasw
;_SWPSTO:POP   DI
;        DB    0B9H

; -------------------
; String
; -------------------

        _XT  XT_strpc,@NIP      ; S+C!
XSTRPC: MOV  DI,255
        inc  PB [bx]
        AND  DI,[BX]
        MOV  [BX+DI],AL
        RET

        _XT  XT_stdSTR,@cnip    ; S!-
        PUSH CX
        MOV  DI,BX
        CALL CPUSHU
        MOV  BX,DI
        POP  aX
xSTB:   MOV  [BX],AL   ;  C!.
        ret

        _XT  XT_movSTR,@cnip    ; S!
        MOV  [BX],CL
        LEA  DI,[BX+1]
        JMP  CMOVE

        _XT XT_STDB,@nip
        DEC   BX        ;  C!-
        jmp   xSTB

        _XT XT_STDW,@nip
xSTDW:  DEC   BX        ;  !-
        DEC   BX
xSTW:   mov   [BX],ax   ;  !.
        RET

        _XT  XT_STW,@nip
        jmp  xSTW

@XPE:   CALL  _DOES
        DW  xt_@xpe,XT_POP,XT_STW,XT_DROPX

; -----------------------
; Terminal Input / Output
; -----------------------

        _XT  XT_acpt,@swap
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

        _XT  XT_demit,@DRoP
_DEMIT:  xchg Bx,dx
        mov  ah,2
        int  021h
        RET

        _XT  XT_dkey,@pusha
_DKEY:  mov  ah,7
        int  021h
        JMP  _LOBYTE

; -------------------
; Peek and Poke
; -------------------

        _XT  XT_STR,@pusha
        DB    0B9H
        _XT  XT_fetchp,@NUp
        MOV   AX,[BX]
        JMP   SHORT _2

;       _XT  XT_STORE,@2drop
;       DB    0B9H
        _xt  XT_storep,@nip
_storep:MOV   PW [BX],AX
_2:     INC   BX
_1:     INC   BX
        RET

        _XT  XT_CSTORE,@2drop
        DB    0B9H
        _xt  XT_cstorep,@nip
        MOV   [BX],AL
        JMP  _1

        _XT  XT_Cfetchp,@NUp
         DB    0B9H
        _XT  XT_count,@pusha
        JMP  _COUNT

; -----------------------
; searching
; -----------------------

        _XT XT_find,@pusha
        push  si
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
        pop   si
        RET

; -------------------
; Maths / Logic / registers
; -------------------

        _xt xt_0swap,@nup
        xor ax,ax
        ret

        _XT XT_DIG,@nop
        CMP BL,10
        JL  @@1
        ADD BL,7
@@1:    ADD BL,'0'
        RET

        _XT XT_DIV,@Dinu
        DIV BX
XDTOP:  MOV BX,DX
        RET

        _XT XT_MUL,@ninu
        MUL BX
        JMP XDTOP

        _xt xt_eqz,@nop
        CMP    BX,1
        SBB    BX,BX
        rET

        _xt XT_lit,_lit

        _XT  XT_1M,@nop
        DEC  BX
        RET

        _XT  XT_1P,@nop
        INC  BX
        RET

;       _XT  XT_not,@nop
;       not  BX
;       RET

        _xt XT_and,@nip
        AND   BX,AX
        RET

        _XT XT_UMIN,@nip
        CMP   AX,BX
        JNC   @@1
        XCHG  AX,BX
@@1:    RET

        _xt  XT_plus,@nip
        ADD   BX,AX
        RET

        _xt  XT_MINus,@nip
        XCHG  BX,AX
        SUB   BX,AX
        RET

        _xt  XT_dec,@nop
        DEC   PW [BX]
        RET

        _XT  XT_TOEVAL,@ninu
        ADD   AX,BX
_NEG:   NEG   BX
        RET

; -------------------
; Stack
; -------------------

        _XT XT_drop,_DROP
        _XT XT_over,_over
        _xt XT_pop,_pop
        _xt XT_push,_push
        _xt XT_dup,_dup
        _xt XT_?dup,_?dup

        _xt XT_swap,@swap
        RET

        _xt XT_I,@pusha
        mov  ax,[bp]
        RET

        _xt XT_j,@pusha
        mov  ax,[bp+2]
        RET

        _XT XT_XCHG,_XCHG

; -----------------------
; Colon Definition
; -----------------------

        _XT XT_semicolon,_does0 ; ;`
        dw xt_exit,xt_lbrak

        _XT XT_colon,_does1     ; :
        dw docolon,xt_rbrak

        _XT XT_colCoMP,_does0   ; :`
        dw XT_SKIP,xt_COLON

; -------------------
; Compilation
; -------------------

        _XT  XT_COMMA,XT_HERE+_AT
        DW XT_STOREP,XT_EXIT

        _XT  XT_bCOMMA,XT_HERE+_AT
        DW XT_cSTOREP,XT_EXIT

        _xt XT_litcom,_does0
          dw xt_lit,xt_comma

_does0: call _does  ; like ;
        dw xt_wcomma,xt_perform,xt_exit

_does1: call _does  ; like :
        dw XT_HERE,XT_ENTRY,xt_wcomma,xt_perform,xt_exit

        _COLON XT_wcomma
        dw xt_fetchp,xt_swap,xt_comma,xt_exit  ; 'w,',wcomma

        _COLON xt_clit
        dw xt_num,xt_litcom,xt_exit

; -------------------
; Flow Control
; -------------------

        _XT XT_@XPE,_@XPE
        _XT XT_0BR,_0BR
        _xt XT_for,_for
        _XT XT_br,_jump
        _xt XT_next,_next
        _xt XT_skip,_skip
        _xt XT_exec,_exec
        _xt XT_perform,_perform
        _XT XT_RDROP,_RDROP
        _XT XT_exit,_exit
        _XT XT_DROPx,_DROPX
        _xt XT_0ex,_0ex
        _XT XT_EX,_EX

        _colon xt_execute
        dw xt_push,xt_exit

        _colon xt_xdrop
        dw xt_ex,xt_dropx

        _colon xt_times ; for j execute next rdrop drop ;
        dw xt_for,_xtimes
_times  dw xt_j,xt_execute,xt_next,_times
_xtimes dw xt_rdrop,xt_dropx

; -----------------------
; Dictionary Search
; -----------------------

        _COLON XT_tick
        DW XT_TOKEN,XT_NZ?,xt_here,xt_find,xt_NZ?,xt_exit

        _COLON XT_lbrak         ; interpreter search
        dw Xt_SEARCH+_TO,xt_find,xt_0br,num_chk,XT_TRE,xt_EXIT
num_chk:dw XT_ONE,xt_EXIT

        _COLON XT_rbrak         ; compiler search
        dw Xt_SEARCH+_TO,XT_FLAG,xt_swap,xt_strpc
        dw xt_find,xt_0br,comp_it,XT_TRE,xt_EXIT
comp_it dw  xt_dec
        dw  xt_find,xt_0br,comp_num,XT_TWO,xt_EXIT
comp_num dw XT_ZER,xt_EXIT

        _COLON xt_num
        dw xt_count,XT_TOEVAL,xt_number,XT_Z?,xt_dup,xt_numo
        dw XT_EXIT

        _COLON2 XT_NZ?
        _COLON2 XT_Z?
        DW XT_EQZ,xt_0ex,xt_here,xt_id,xt_qm,XT_EMIT,xt_abort

;        DW XT_LIT,12345,XT_numo     ; !!!
;        DW XT_ZER,XT_LTB+_TO      ; !!!
;        DW XT_LIT,13,XT_emit   ; !!!
;        DW XT_LIT,10,XT_emit   ; !!!
;        DW XT_LIT,'!',XT_emit   ; !!!

; -----------------------
; Outer Interpreter
; -----------------------

        _XT XT_BYE,0

        _XT XT_BP,@NOP
        INT 3
        RET

        _PRIM  XT_ASM
        JMP   SI

        _XT XT_CTRL_OUT,@NOP
        CMP BL,' '
        JAE @@EMIT
        MOV BL,'.'
@@EMIT: RET

        _CONST  XT_BS,8
        _CONST  XT_1H,16
        _CONST  XT_1B,256

        _COLON  XT_XSPC
        DW XT_EX  ; !!!
        _colonP xt_space
        dw xt_bl,xt_emit,xt_exit

        _COLON XT_P
        DW XT_KEY,XT_DROP,XT_EXIT

        _COLON  XT_DM  ; : #1 10 0SWAP U/MOD >DIG SWAP ;
        DW XT_0SWAP,XT_DIV,XT_SWAP,XT_EXIT

        _colon  xt_numo
        DW XT_XSPC      ;; !!! ; : . DUP 0< IF '- EMIT NEG THEN .. ;
        _COLONP XT_nprt       ; : .. #1 ?DUP IF .. THEN EMIT ;
        DW XT_LIT,10,XT_DM,XT_?DUP,XT_0BR,_DD,XT_nprt
_DD:    _COLONP  XT_PDIG
           DW XT_DIG,XT_EMIT,XT_EXIT

        _colon xt_cr
        dw xt_lit,13,xt_emit,xt_lit,10,xt_emit,xt_zer,xt_cntc+_to,xt_exit

        _colon xt_ok_do
        dw xt_space,xt_cr,xt_lit,'!',xt_emit,xt_exit

        _colon xt_id
        dw xt_count,xt_type,xt_space,xt_exit

        _colon xt_list
        dw xt_last,xt_xdrop
_list   dw XT_DUP,XT_ONE,XT_DUMP,XT_SPACE
        DW xt_str,xt_HPRT,XT_1P,xt_COUNT,XT_0EX
        DW xt_1m,xt_count,xt_plus,xt_br,_list

        _COLON   XT_Hprt
           DW XT_XSPC
        _COLONP  XT_PWORD
           DW XT_1B,XT_DM,XT_PBYTE
        _COLONP  XT_PBYTE
           DW XT_1H,XT_DM,XT_PDIG,XT_PDIG,XT_EXIT

        _COLON  XT_PRTC
        DW XT_POP,XT_COUNT,XT_EMIT,XT_PUSH,XT_EXIT

        _COLON  XT_PRTSTR
        DW XT_POP,XT_COUNT,XT_PTYPE,XT_PUSH,XT_EXIT

        _COLON  XT_ADRSTR
        DW XT_I,XT_COUNT,XT_PLUS,XT_XCHG,XT_EXIT

        _COLON XT_SKOBA
        DW XT_SPACE,XT_PRTC
        DB '['
        DW XT_EX
        DW XT_PRTC
        DB ']'
        DW XT_EXIT

        _colon xt_Xtype
        DW XT_EX,XT_DUP,XT_1H,XT_MINUS,XT_1H,XT_SKOBA
        _colonP xt_type
        dw xt_xdrop
        _colonP xt_Ptype
        DW xt_times,xt_count
        DW  XT_CTRL_OUT,xt_EMIT,xt_exit

        _colon xt_DUMP
        DW  XT_1H,XT_0SWAP,XT_DIV,XT_EQZ,XT_EQZ,XT_MINUS
        DW  XT_XDROP,XT_TIMES,XT_XTYPE
        _colonP  xt_DU
        DW  XT_CR,XT_DUP,XT_HPRT,XT_TWO,XT_TIMES
        DW  XT_BS,XT_SPACE,XT_TIMES
        DW  XT_COUNT,XT_PBYTE,XT_SPACE,XT_EXIT

;        _colon xt_scom
;        dw xt_xdrop,xt_times,xt_count,xt_bcomma,xt_exit

freemem:

lastw = ppppp

MyCseg  ends
        end  Start

