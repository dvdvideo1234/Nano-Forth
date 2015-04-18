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
   _entry   '.',XT_p10
   _entry   'ENTRY',XT_ENTRY
   _entry   0,0
   DW 0  ; LAST WORD
   DB 0,0

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
        _vectoR xt_OK,0
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

SELF2:  CALL MOVER

; -------------------
; Initialisation  and main loop
; -------------------

_restart:cld
        MOV  bp,-256
        mov  sp,-512
        call _forth
        dw   xt_lbrak,xt_tib,xt_count
xsyslp  dw   xt_eval,xt_OK,xt_tib,xt_FLAG,xt_accept,xt_br,xsyslp

        _XT xt_nop,_nop

        _COLON xt_eval
        dw xt_TOEVAL,XT_ltb+_TO,Xt_etb+_TO
_int:   dw XT_TOKEN,XT_0EX,XT_HERE,xt_SEARCH
        dw xt_states,xt_perform,xt_br,_int

        _XT XT_QUIT,_RESTART

        _COLON XT_ABORT
        DW XT_ZER,XT_TIB,XT_STOREP,XT_QUIT

_forth: pop si
        next

MOVER:  mov  bx,1000h     ; only 64k allocate
        mov  ah,4ah
        int  21h
        POP  BX
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
        dw XT_LTB,XT_DUP,XT_0EX,XT_DROP,XT_BL,XT_PARSE
        DW XT_BL,XT_UMIN,XT_HERE,XT_MOVSTR,XT_CFETCHP,XT_DROPX

        _XT XT_@XPE,_@XPE

        _COLON XT_ENTRY
        DW XT_ZER,XT_TOKEN,XT_NZ?,XT_HERE,XT_COUNT
        DW XT_LAST+_AT,XT_STDSTR,XT_STDB,XT_STDW,XT_EXIT

; ------------------------
; parsing
; ------------------------

        _XT  XT_number,PADA
        push BP
        XOR  CX,CX  ; ACCUMULATOR
        xchg ax,Di  ; ENDBUF
        CALL _NUM
        POP  BP
        XCHG CX,AX
        RET

_CNUM:  OR   BX,BX
        JE   _EXNUM
        XOR  AH,AH
        MOV  AL,[BX+DI]
        RET

_NUM:   CALL _CNUM
        MOV  BP,10
        CALL _SGN
_NUMZ:  INC  BX
        CALL _CNUM
        CALL _N1
        JMP  SHORT  _NUMZ

_SGN:   CMP  AL,'-'
        JNE  _N1
        POP  AX
        CALL AX
        NEG  CX
        RET

_n1:    cmp  al,'$'
        JNE  _N2
        MOV  BP,16
        RET
_N2:    cmp  al,'#'
        JNE  _N3
        MOV  BP,CX
        XOR  CX,CX
        RET
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
_EXNUM: POP  AX
        ret

        _PRIM XT_PARSE
_PARS:  mov  aL,bl
        mov  Bx,PW [XT_ltb+_AT]
        mov  DI,PW [XT_Etb+_AT]
        CMP  AL,' '
        JNE  _SKIPEX
        DEC  BX
_WSKP:  INC  BX
        JE   _SKIPEX
        MOV  AH,[BX+DI]
        CMP  AL,AH
        JE   _WSKP
_SKIPEX:LEA  CX,[BX+DI]
        PUSH CX
        DEC  BX
_WSCZ:  INC  BX
        JE   _WEX
        MOV  AH,[BX+DI]
        CMP  AL,AH
        JNE  _WSCZ
_WEX:   SUB  DI,CX
        MOV  CX,BX
        ADD  BX,DI
        JCXZ WORDE
        INC  CX
worde:  mov  PW [XT_ltb+_AT],cx
        NEXT

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

_arw:   LEA   DI,[bx+di] ; array of words
_arb:   lea   bx,[bx+di] ; array of bytes
_0:     JMP   SHORT _nOP
dopoint:mov   AX,[di+2]
        JMP   SHORT PCPUSH
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
setpoint:mov  [di],si
        jmp   SHORT _exit
docons3:scasw
docons2:scasw
doconst:mov   ax,[di]
        jmp   SHORT _pushw
dovar:  MOV   ax,di
        jmp   SHORT _pushw

PSDA:   POP   AX
PS:     CALL  DI
_pushw: push  bx
_swapw: xchg  ax,bx

_nop:   lodsw
_nop1:  xchg  di,ax
        LEA   DI,[DI+2]    ; !!!
        jmp   Pw [di-2]    ; !!!
PADA:   POP   AX
PA:     CALL  DI
_PHA:   PUSH  AX
        NEXT
_LDB:   MOV   AL,[BX]
        MOV   AH,0
        JMP   _PHA
_LDW:   PUSH  [BX]      ;  !.
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
DDP:    POP   AX
DRP:    CALL  DI
_drop:  pop   bx
        next
_0br:   SUB   bx,1
        pop   bx
        jC    _jump
_skip:  lodsw
        next
_jump:  mov   si,[si]
        next
_push:  pop   ax
        xchg  ax,bx
        jmp   _rpush
_pop:   push  bx
        mov   bx,[bp]
        jmp   _rdrop
@drop:  pop   ax
        xchg  ax,bx
        db    0B9h
@cnip:  POP   cX
@nip:   POP   AX
@nop:   CALL  DI
nop@@:  NEXT

; ;HERE @. XCHG PUSH EX POP ! ;
; ;HERE_DOES @.XPE POP ! ;
@XPE:   CALL  _DOES
        DW  xt_@xpe,XT_POP,XT_STW,XT_DROPX

;_stwp:  pop   [bx]
;        db    0B9h
;_ldwp:  PUSH  [BX]
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

;        SCASW
;_ard:   add   bx,bx
;_call:  lodsw
;        jmp   pcpush
;_toforth:pop  ax
;        jmp   pcpush
;_J:     MOV   DI,2
;        db    0B9h
;_I:     XOR   DI,DI
;        MOV   AX,[BP+DI]
;        JMP   SHORT _PUSHW
;        _XT   XT_DOES,DOVAR-1
;        scasw
;        scasw
;_SWPSTO:POP   DI
;        DB    0B9H
;_BRP:   PUSH  BX
;        SHL   BX,1
;        CMC
;        JMP   SHORT _BR_DR
;_next:  SUB   Pw [bp],1
;        jNC   _jump
;        jmp   _SKIP
;_LIT:   LODSW
;        JMP   SHORT _PUSHW
;_BLIT:  LODSB
;        JMP   SHORT _PUSHB
;_CO:    xchg  si,[bp]
;        NEXT
;_XCHG:  XCHG  BX,[BP]
;        NEXT
;_NEG:   DEC   BX
;_NOT:   MOV   AX,0FFFFH
;        DB    0B9H
;_XOR:   POP   AX
;        XOR   BX,AX

; -------------------
; String
; -------------------

        _XT  XT_strpc,@drop
        XCHG  AX,CX
        CALL  _COUNT
        XCHG  AX,DI
        MOV   [BX+DI],CL
        DEC   BX
_inc:   inc   Pw [bx]
        RET

        _XT XT_stdSTR,@cnip
        SUB   BX,CX
        jmp   short xmovstr

        _XT  XT_movSTR,@cnip
        INC   BX
xmovstr:PUSH  CX
        MOV   DI,BX
        CALL  CMOVEU
        POP   AX
xSTDB:  DEC   BX        ;  C!-
xSTB:   MOV   [BX],AL   ;  C!.
        ret

        _XT XT_STDB,@nip
        jmp xstdb

        _XT XT_STDW,@nip
xSTDW:  DEC   BX        ;  !-
        DEC   BX
xSTW:   mov   [BX],ax   ;  !.
        NEXT
;

;        _XT XT_STB,_STB
        _XT  XT_STW,@nip
        jmp  xSTW

; -----------------------
; Terminal Input / Output
; -----------------------

        _XT  XT_acpt,PSDA
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

        _XT  XT_demit,DRP
_DEMIT:  xchg Bx,dx
        mov  ah,2
        int  021h
        RET

        _XT  XT_dkey,PS
_DKEY:  mov  ah,7
        int  021h
        JMP  _LOBYTE

; -------------------
; Peek and Poke
; -------------------

;       _XT  XT_STR,PS
;       DB    0B9H
        _XT  XT_fetchp,PA
        MOV   AX,[BX]
        JMP   SHORT _2

;       _XT  XT_STORE,DDP
;       DB    0B9H
        _xt  XT_storep,@nip
_storep:MOV   PW [BX],AX
_2:     INC   BX
_1:     INC   BX
        RET

        _XT  XT_CSTORE,DDP
        DB    0B9H
        _xt  XT_cstorep,@nip
        MOV   [BX],AL
        JMP  _1

        _XT  XT_Cfetchp,pA
         DB    0B9H
        _XT  XT_count,PS
        JMP  _COUNT

; -----------------------
; searching
; -----------------------

        _XT XT_find,PS
        push  si
        mov   SI,[XT_last+_AT]
        XOR   cX,CX
        JMP   SHORT FINDN
FND:    add   si,cx
findN:  mov   di,bx
        MOV   DX,SI
        LEA   SI,[SI+3]
        mov   cl,byte[si]
        jcxz  not_fnd
        inc   cx
        repe  cmpsb
        jNZ   fnd
        MOV   BX,DX     ;fnd_ok:
        MOV   CX,BX
        MOV   BX,[BX]
not_fnd:xchg  ax,CX
        pop   si
        RET

; -------------------
; Maths / Logic / registers
; -------------------

        _xt xt_eqz,@nop
        CMP    BX,1
        SBB    BX,BX
        rET

        _xt XT_lit,PS
        LODSW
        RET

;        _XT  XT_1M,__
;        DEC  BX
;        RET

        _xt XT_and,@nip
        AND   BX,AX
        RET

        _XT XT_UMIN,@nip
        CMP   AX,BX
        JNC   @@1
        XCHG  AX,BX
@@1:    RET

        _xt XT_plus,@nip
        ADD   BX,AX
        RET

        _xt XT_dec,@nop
        DEC   PW [BX]
        RET

        _XT  XT_TOEVAL,PADA
        ADD   AX,BX
_NEG:   NEG   BX
        RET

; -------------------
; Stack
; -------------------

        _xt XT_dup,PS
        MOV AX,BX
        RET

        _xt XT_swap,PSDA
        RET

        _XT XT_drop,_DROP
        _xt XT_pop,_pop
        _xt XT_push,_push

;        _XT XT_J,_J
;        _XT XT_I,_I
;        _XT XT_XCHG,_XCHG
;        _XT XT_EX,_CO

;        _COLON XT_TIMES
;        DW XT_1M,XT_BRM,_TMS2,XT_PUSH
;_TMS:   DW XT_J,XT_EXECUTE,XT_NEXT,_TMS,XT_POP
;_TMS2:  DW XT_RDROP,XT_DROPX

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

        _XT XT_0BR,_0BR
        _XT XT_br,_jump
        _xt XT_skip,_skip
        _xt XT_exec,_exec
        _xt XT_perform,_perform
        _XT XT_RDROP,_RDROP
        _XT XT_exit,_exit
        _XT XT_DROPx,_DROPX
        _xt XT_0ex,_0ex
;        _xt XT_1Px,_1Px
;        _xt XT_2Px,_2Px

;        _xt XT_call,_call
;        _xt XT_for,_for
;        _xt XT_next,_next

; -----------------------
; Dictionary Search
; -----------------------

        _COLON XT_tick
        DW XT_TOKEN,XT_NZ?,xt_SEARCH,xt_TWO,xt_and,xt_NZ?,xt_exit

        _COLON XT_lbrak         ; interpreter search
        dw Xt_SEARCH+_TO,xt_find,xt_0br,num_chk,XT_TRE,xt_EXIT
num_chk:dw XT_ONE,xt_EXIT

        _COLON XT_rbrak         ; compiler search
        dw Xt_SEARCH+_TO,XT_FLAG,xt_strpc
        dw xt_find,xt_0br,comp_it,XT_TRE,xt_EXIT
comp_it dw  xt_dec
        dw  xt_find,xt_0br,comp_num,XT_TWO,xt_EXIT
comp_num dw XT_ZER,xt_EXIT

        _COLON xt_num
        dw xt_count,XT_TOEVAL,xt_number,XT_Z?,XT_EXIT

        _COLON2 XT_NZ?
        _COLON2 XT_Z?
        DW XT_EQZ,xt_0ex,xt_qm,XT_EMIT
        DW XT_LIT,12345,XT_P10    ; !!!
        DW XT_ZER,XT_LTB+_TO      ; !!!
        DW XT_LIT,13,XT_emit   ; !!!
        DW XT_LIT,10,XT_emit   ; !!!
        DW XT_LIT,'!',XT_emit   ; !!!
        DW xt_abort

; -----------------------
; Outer Interpreter
; -----------------------

        _COLON XT_P
        DW XT_KEY,XT_DROP,XT_EXIT

        _COLON  XT_DD  ; BEGIN 10 /MOD >DIG SWAP DUP 0; AGAIN
        DW XT_ZER,XT_SWAP
_DD     DW XT_LIT,10,XT_DIV,XT_DIG,XT_SWAP,XT_DUP,XT_0EX,XT_BR,_DD
        DW XT_ZER,XT_SWAP,XT_DD,XT_DROP,XT_PN,XT_P,XT_DROPX

        _COLON  XT_PN  ;  BEGIN DUP 0; EMIT AGAIN
_PD     DW XT_DUP,XT_0EX,XT_EMIT,XT_BR,_PD

        _COLON  XT_P10 ; 0 SWAP #D DROP #D. DROP ;
        DW XT_ZER,XT_SWAP,XT_DD,XT_DROP,XT_PN,XT_P,XT_DROPX

        _XT XT_DIV,PADA
        XOR DX,DX
        DIV BX
        MOV BX,DX
        RET

        _XT XT_MUL,PADA
        MUL BX
        MOV BX,DX
        RET

        _XT XT_DIG,@nop
        CMP BL,10
        JL  _PPP1
        ADD BL,7
_PPP1:  ADD BL,'0'
        RET

freemem:

lastw = ppppp

MyCseg  ends
        end  Start

