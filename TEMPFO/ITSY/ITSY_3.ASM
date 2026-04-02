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
        DW     setvar2,dovar,dat
        ENDM

quan    macro  nam,lbl,dat
        _ln    nam
        _QUAN  LBL,DAT
        endm

_const  macro lbl,dat
lbl     DW    doconst,DAT
        endm

MyCseg  segment para  use16
        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg


        org 100h
Start   Label byte
_boot:  JMP SELF1

        ORG 103H
       ;ORG 4000H
SELF1:  CALL SELF2
   DW XT_ENTRY
   DB 0
   _NAM 'ENTRY'

   DW 0  ; LAST WORD
   DB 0,0

; -----------------------
; Constants
; -----------------------

        _CONST  xt_zer,0
        _CONST  xt_oNE,1
        _CONST  xt_TWO,2
        _CONST  xt_TRE,3
        _CONST  xt_FLAG,'`'
        _CONST  xt_BL,' '

; -------------------
; Variables
; -------------------

        _vectoR xt_key,xt_dkey
        _vecto  xt_emit,xt_demit
        _POINT  xt_SEARCH,0
        _value  xt_ltb,0
        _value  xt_etb,0
        _value  xt_cntc,0
        _VALUE  xt_tib,128
;        _QUAN   XT_IOB,0
        _QUAN   XT_here,freemem
        _value  xt_last,SELF1+3

; -------------------

SELF2:  POP  SI
        CALL MOVER

; -------------------
; Initialisation  and main loop
; -------------------

_restart:cld
        MOV  bp,-256
        mov  sp,-512
        call _forth
        dw   xt_lbrak
        dw   xt_tib,xt_count
xsyslp  dw   xt_eval,xt_cr,xt_tib,xt_FLAG,xt_accept
        DW   xt_br,xsyslp

;        _XT xt_bye,0
;        _XT xt_nop,_nop

        _COLON XT_TOKEN
        DW XT_BL,XT_PARSE,XT_BL,XT_UMIN,XT_HERE,XT_SETSTR,XT_EXIT

        _COLON xt_eval
        dw xt_TOEVAL,XT_ltb+_TO,Xt_etb+_TO
_int:   dw XT_LTB,XT_0EX,XT_TOKEN,XT_0EX
        dw XT_HERE,xt_SEARCH,xt_states,xt_perform,xt_br,_int

        _COLON XT_CR
        DW XT_ECR,XT_ELF,XT_ZER,XT_CNTC+2,XT_EXIT

        _PRIM XT_ABORT
        xor ax,ax
        mov DI,[XT_tib+_AT]
        STOSW
        jmp _restart

_forth: pop si
        next

;_DOS:   POP  DI
;        MOV  BX,[DI+2]
;        MOV  AX,[DI]
;        int 21h
;        RET

MOVER:  PUSH SI
        mov bx,1000h     ; only 64k allocate
        mov ah,4ah
        int 21h
        ADD  SI,[SI-2]
        MOV  DI,[SI-2]
        MOV  CX,[SI-8]
        SUB  CX,DI
        POP  SI
CMOVEU: STD
        ADD  SI,CX
        ADD  DI,CX
        CMPSB
        REP  MOVSB
        RET

; ------------------------
; COMPILing
; ------------------------

        _PRIM  XT_ENTRYP
        POP  AX
        XCHG AX,SI
        MOV  CX,BX
        MOV  DI,XT_LAST+_AT
        CALL CMOVEU  ; DN - 3
        XCHG SI,AX
        MOV  AL,BL
        STOSB
        POP  AX
        STOSB
        SCASB
        MOV  XT_LAST+_AT,DI
        POP  AX
        STOSW
        CLD
        JMP  _DROP

; ------------------------
; parsing
; ------------------------

        _PRIM  XT_number
        POP  AX
        push BP
        MOV  BP,10
        XOR  CX,CX  ; ACCUMULATOR
        xchg ax,Di
        add  DI,bx
        NEG  BX
        CALL _NUM
        POP  BP
        PUSH CX
        NEXT

_CNUM:  OR   BX,BX
        JE   _EXNUM
        XOR  AH,AH
        MOV  AL,[BX+DI]
        RET

_NUM:   CALL _CNUM
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
        lea   bx,[di+2]
_perform:mov  bx,[bx]
_exec:  pop   ax
        xchg  ax,bx
        OR    AX,AX
        JE    _0
        jmp   SHORT _ex

;_ard:   add   bx,bx
_arw:   add   bx,bx     ; array of words
_arb:   lea   bx,[bx+di] ; array of bytes
_2:     inc   bx
_1:     inc   bx
_0:     next
_Cfetchp:xor  ah,ah
        mov   al,[bx]
        PUSH  AX
        JMP   _1
_fetchp:PUSH  PW [bx]
        JMP   _2
dopoint:mov   AX,[di+4]
        JMP   SHORT PCPUSH
setpoint:mov  [di+2],si
        jmp   _exit
_STOREP:POP   PW [BX]
        JMP   _2
_CSTOREP:POP   AX
        MOV   [BX],AL
        JMP   _1
_2M:    DEC   bx
_1M:    DEC   bx
        next

docons3:scasw
docons2:scasw
doconst:mov   ax,[di+2]
        jmp   SHORT _pushw
;        SCASW
dovar:  lea   ax,[di+2]
        jmp   SHORT _pushw
;        _XT   XT_DOES,DOVAR-1
;        scasw
;        scasw
_does:  pop   ax
        push  bx
        lea   bx,[di+2]
pcpush: XCHG  AX,SI
_rpush: dec   bp
        dec   bp
        mov   [bp],AX
        next

        scasw
docolon:scasw
        xchg  ax,di
        jmp   pcpush
_on_ex: lodsw
        jmp   _rpush
;_call:  lodsw
;        jmp   pcpush
;_toforth:pop  ax
;        jmp   pcpush
;_J:     MOV   DI,2
;        db    0B9h
;_I:     XOR   DI,DI
;        MOV   AX,[BP+DI]
;        JMP   SHORT _PUSHW

_SWAP:  POP   AX
        db    0B9h
_over:  pop   ax
        push  ax
        db    0B9h
_PUSHB: MOV   AH,0
_pushw: push  bx
_swapw: xchg  ax,bx

_nop:   lodsw
_ex:    xchg  di,ax
        jmp   Pw [di]
_LIT:   LODSW
        JMP   SHORT _PUSHW
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
_DEMIT:  xchg Bx,dx
        mov  ah,2
        int  021h
        JMP  _DROP
_DKEY:  mov  ah,7
        int  021h
        JMP  _PUSHB
_TOEVAL:POP   AX
        ADD   AX,BX
        PUSH  AX
_NEG:   NEG   BX
        NEXT
_ADD:   POP   AX
        ADD   BX,AX
        NEXT
_AND:   POP   AX
        AND   BX,AX
        NEXT
;_SWPSTO:POP   DI
;        DB    0B9H
setvar2:scasw
setvar: SCASW
        mov   [di],bx
        jmp   _drop
_0ex:   or    bx,bx
        je    _dropx
_drop:  pop   bx
        next
_BRM:   PUSH  BX
        SHL   BX,1
        JMP   SHORT _BR_DR
;_BRP:   PUSH  BX
;        SHL   BX,1
;        CMC
;        JMP   SHORT _BR_DR
_BRZ:   PUSH  BX
_0br:   SUB   bx,1
_br_dr: pop   bx
        jC    _jump
_skip:  lodsw
        next
_dropx: pop   bx
_exit:  mov   si,Pw [bp]
_rdrop: inc   bp
        inc   bp
        next
;_next:  SUB   Pw [bp],1
;        jNC   _jump
;        jmp   _SKIP
_jump:  mov   si,[si]
        next
_DUP:   PUSH  BX
        db    0B9h
_DEC:   DEC   PW [BX]
        NEXT
_push:  pop   ax
        xchg  ax,bx
        jmp   _rpush
_pop:   push  bx
        mov   bx,[bp]
        jmp   _rdrop
_UMIN:  POP   AX
        CMP   AX,BX
        JNC   @@1
        XCHG  AX,BX
@@1:    NEXT
;
; Inner Interpreter
; -------------------


; -------------------
; String
; -------------------
        _PRIM XT_strpc
        POP   DI
        XOR   AX,AX
        XCHG  AX,BX
        MOV   BL,[DI]
        mov   Pb [bx+di+1],al
        XCHG  BX,DI
_inc:   inc   Pw [bx]
        NEXT

        _XT  XT_count,_COUNT

        _PRIM XT_SETSTR
        POP   CX
        MOV   CH,0
        POP   AX
        PUSH  CX
        LEA   DI,[BX+1]
        XCHG  AX,SI
        CALL  CMOVEU
        XCHG  AX,SI
        POP   AX
        STOSB
        CLD
        JMP   _SWAPW

;       _COLON  XT_count
;       DW XT_CFETCHP,XT_SWAP,XT_EXIT
;        _COLON  XT_STR
;        DW XT_FETCHP,XT_SWAP,XT_EXIT

; -------------------
; Peek and Poke
; -------------------

        _XT  XT_1P,_1
        _XT  XT_1M,_1M
        _XT  XT_2M,_2M
        _XT  XT_fetchp,_fetchp
        _xt  XT_storep,_storep
        _xt  XT_cstorep,_cstorep
        _XT  XT_Cfetchp,_Cfetchp

        _COLON  XT_CSTORE
        DW XT_CSTOREP,XT_DROPX
        _COLON  XT_CFETCH
        DW XT_CFETCHP,XT_DROPX
;        _COLON  XT_FETCH
;        DW XT_FETCHP,XT_DROPX

; accp0:  ret

; -----------------------
; Terminal Input / Output
; -----------------------

        _PRIM  XT_accept
        POP    AX
        XCHG   AX,BX
        MOV    [BX],AX
        MOV    DX,BX
        MOV    AH,10
        INT    21H
        INC    BX
_COUNT: MOV    AL,[BX]
        INC    BX
        JMP    _PUSHB

        _XT  XT_demit,_DEMIT
        _XT  XT_dkey,_DKEY

; -----------------------
; searching
; -----------------------

        _PRIM XT_find
_fnd:   mov   AX,[XT_last+_AT]
_SRC:   push  si
        XCHG  AX,SI
        XOR   cX,CX
        DB    0B9H
findN:  add   si,cx
        mov   di,bx
        LEA   SI,[SI+3]
        mov   cl,byte[si]
        jcxz  not_fnd
        inc   cx
        repe  cmpsb
        jNZ   findN
        SUB   BX,DI     ;fnd_ok:
        LEA   BX,[BX+SI-3]
        MOV   CX,BX
not_fnd:xchg  ax,CX
        LEA   DX,[SI+1]
        pop   si
        JMP   _PUSHW

; -------------------
; Maths / Logic / registers
; -------------------

        _XT XT_UMIN,_UMIN
        _xt XT_plus,_ADD
;        _xt XT_MUL2,_MUL2
;        _xt XT_DIV2,_DIV2
;        _xt XT_NOT,_NOT
        _xt XT_TOEVAL,_TOEVAL
;        _xt XT_RCR,_RCR
        _xt XT_dec,_DEC
        _xt XT_and,_AND
        _xt XT_lit,_LIT

; -------------------
; Stack
; -------------------

        _XT XT_drop,_drop
        _xt XT_dup,_DUP
        _xt XT_over,_over
        _xt XT_swap,_SWAP
        _xt XT_pop,_pop
        _xt XT_push,_push
        _xt XT_on_ex,_on_ex  ; rliteral
;        _XT XT_J,_J
;        _XT XT_I,_I
;        _XT XT_XCHG,_XCHG
;        _XT XT_EX,_CO

;        _COLON XT_TIMES
;        DW XT_1M,XT_BRM,_TMS2,XT_PUSH
;_TMS:   DW XT_J,XT_EXECUTE,XT_NEXT,_TMS,XT_POP
;_TMS2:  DW XT_RDROP,XT_DROPX

;       _COLON XT_DNB
;       DW XT_LAST,XT_1M,XT_DUP,XT_LAST+_TO,XT_CSTOREP,XT_DROPX
;
;       _COLON XT_GetStrEnd
;       DW XT_CFETCHP,XT_OVER,XT_PLUS,XT_SWAP,XT_1P,XT_EXIT
;
;       _COLON XT_DNSTR
;       DW XT_ONXDROP,XT_TIMES,XT_1M,XT_COUNT,XT_DNB,XT_1M,XT_EXIT
;
;       _COLON XT_XEP
;       DW XT_XCHG,XT_PUSH,XT_EX,XT_POP,XT_EXIT
;
;       _COLON XT_ONXDROP
;       DW XT_EX,XT_DROPX
;
;       _COLON XT_CMOVE
;       DW XT_ONXDROP,XT_ONXDROP
;       DW XT_TIMES,XT_PUSH,XT_COUNT,XT_POP,XT_CSTOREP,XT_EXIT
;
;       _COLON XT_GETWORD
;       DW XT_PARSEBL,XT_LIT,31,XT_UMIN
;       DW XT_DUP,XT_0BR,DO_ABORT,XT_HERE,XT_SKIP  ; CONTINUE !!!
;       _COLON XT_STRMAKE
;       DW XT_XEP,XT_DUP,XT_J,XT_CSTOREP,XT_SWAP,XT_CMOVE,XT_EXIT
;
;       _colon XT_ENTRY
;       DW XT_GETWORD,XT_GetStrEnd,XT_DNSTR,XT_DNB,XT_SKIP
;       _COLON XT_DNW
;       DW XT_LAST,XT_2M,XT_DUP,XT_LAST+_TO,XT_STOREP,XT_DROPX
;
; -----------------------
; Colon Definition
; -----------------------

        _COLON XT_ENTRY
        DW XT_ZER,XT_TOKEN,XT_BRZ,DO_ABORT
        DW XT_HERE,XT_COUNT,XT_ENTRYP,XT_EXIT  ; CONTINUE !!!

        _XT XT_semicolon,_does0 ; ;`
        dw xt_exit,xt_lbrak

        _XT XT_colon,_does1     ; :
        dw docolon,xt_rbrak

        _XT XT_colCoMP,_does0   ; :`
        dw XT_SKIP,xt_COLON

; -------------------
; Compilation
; -------------------

        _PRIM XT_COMMA
        POP   AX
        XCHG  AX,BX
        MOV   DI,XT_HERE+_VAL
        STOSW
        MOV   XT_HERE+_VAL,DI
        NEXT

        _xt XT_litcom,_does0
          dw xt_lit,xt_comma

_doespc:call _does
        dw  xt_count,xt_emit,xt_dropx

xt_Ecr  dw _doespc
        db 13
xt_Elf  dw _doespc
        db 10
xt_Eqm  dw _doespc
        db '?'

_does0: call _does  ; like ;
        dw xt_wcomma,xt_perform,xt_exit

;        _COLON XT_WORD
;        DW XT_ZER,XT_ENTRY,XT_EXIT

_does1: call _does  ; like :
        dw XT_HERE,XT_ENTRY,xt_wcomma,xt_perform,xt_exit

;        _colon XT_comma
;        dw xt_here,xt_storep,Xt_here+_TO,xt_exit

        _COLON XT_wcomma
        dw xt_fetchp,xt_swap,xt_comma,xt_exit  ; 'w,',wcomma

        _COLON xt_clit
        dw xt_num,xt_litcom,xt_exit

; -------------------
; Flow Control
; -------------------

        _XT XT_0BR,_0BR
        _XT XT_BRM,_BRM
        _XT XT_BRZ,_BRZ
        _XT XT_br,_jump
        _xt XT_skip,_skip
        _xt XT_exec,_exec
        _xt XT_perform,_perform
        _XT XT_RDROP,_RDROP
        _XT XT_exit,_exit
        _xt XT_dropx,_dropx
        _xt XT_0ex,_0ex

;       _XT XT_BRP,_BRP
;        _xt XT_call,_call
;        _xt XT_for,_for
;        _xt XT_next,_next

;        _COLON XT_EXECUTE
;        DW XT_PUSH,XT_EXIT

;        _COLON XT_rnum
;        DW XT_POP,XT_FETCHP,XT_DROPX

; -----------------------

; Dictionary Search
; -----------------------

        _COLON XT_tick
        DW XT_ON_EX,DO_ABORT,XT_TOKEN,XT_0EX
        dw xt_SEARCH,xt_TWO,xt_and,xt_0EX,XT_RDROP,xt_exit

        _COLON XT_lbrak         ; interpreter search
        dw Xt_SEARCH+_TO,xt_find,xt_0br,num_chk,XT_TRE,xt_EXIT
num_chk:dw XT_ONE,xt_EXIT

        _COLON XT_rbrak         ; compiler search
        dw Xt_SEARCH+_TO,XT_FLAG,xt_strpc
;       DW XT_OVER,XT_COUNT,XT_PLUS,XT_CSTORE,XT_INC
        dw xt_find,xt_0br,comp_it,XT_TRE,xt_EXIT
comp_it dw  xt_dec
        dw  xt_find,xt_0br,comp_num,XT_TWO,xt_EXIT
comp_num dw XT_ZER,xt_EXIT

        _COLON xt_num
        dw xt_count,xt_number,xt_0ex
do_abort dw xt_Eqm,xt_abort

; -----------------------
; Outer Interpreter
; -----------------------

xt_states dw _arw,xt_clit,xt_num,xt_comma,xt_exec

freemem:

lastw = ppppp

MyCseg  ends
        end  Start

