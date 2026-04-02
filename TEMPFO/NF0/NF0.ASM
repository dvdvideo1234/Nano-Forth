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
SJMP  MACRO  LBL
        jmp  SHORT LBL
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
;  _entry   '.',XT_DD
   _entry   'BYE',0
   _entry   'ENTRY',XT_ENTRY
   _entry   '',0   ; LAST WORD

_states dw xt_clit,xt_num,xt_comma,xt_exec

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
        _POINT  xt_FOUND,0
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
        DW XT_LIT,12345,XT_DD    ; !!!

        dw   xt_lbrak,xt_tib,xt_count
xsyslp  dw   xt_eval,xt_OK,xt_tib,xt_FLAG,xt_accept,xt_br,xsyslp

        _XT xt_nop,_nop

        _COLON xt_eval
        dw xt_TOEVAL,XT_ltb+_TO,Xt_etb+_TO
_int:   dw XT_TOKEN,XT_0EX,xt_here,XT_found
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
        dw XT_BL,XT_PARSE,XT_BL,XT_UMIN
        DW XT_HERE,XT_MOVSTR,XT_CFETCHP,XT_DROPX

        _XT XT_@XPE,_@XPE

        _COLON XT_ENTRY
        DW XT_ZER,XT_TOKEN,XT_NZ?,XT_HERE,XT_COUNT
        DW XT_LAST+_AT,XT_STDSTR,XT_STDB,XT_STDW,XT_EXIT

; ------------------------
; parsing
; ------------------------

        _XT  XT_number,@ninu
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
        SJMP _NUMZ

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
_PARS:  mov  ax,PW [XT_ltb+_AT]
        xchg ax,bx
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
        Sjmp  _nop1

;_arD:   SHL   bx,1       ; array of Dwords
_arw:   SHL   bx,1       ; array of words
_arb:   ADD   bx,[di] ; array of bytes
_0:     SJMP  _nOP
        scasw
        scasw
docolon:xchg  ax,di
        Sjmp  pcpush
setpoint:mov  [di],si
        Sjmp  _exit
dopoint:mov   SI,[di+2]
        SJMP  _NOP
docons3:scasw
docons2:scasw
doconst:mov   ax,[di]
        Sjmp  _pushw
dovar:  MOV   ax,di
        Sjmp  _pushw
        scasw
        scasw
_does:  pop   ax
        push  bx
        MOV   bx,di
pcpush: XCHG  AX,SI
_rpush: dec   bp
        dec   bp
        mov   [bp],AX
        SJMP  _nOP

@SWAP:  POP   AX           ; NIP DUP SWAP
@DUP:   CALL  DI
_pushw: push  bx
_swapw: xchg  ax,bx

_nop:   lodsw
_nop1:  xchg  di,ax
        LEA   DI,[DI+2]    ; !!!
        jmp   Pw [di-2]    ; !!!

@DINU:  POP   DX
@NINU:  POP   AX
@NUP:   CALL  DI
_PHA:   PUSH  AX
        NEXT
_LDB:   MOV   AL,[BX]
_w_to_b:MOV   AH,0
        JMP   _PHA
_LDW:   PUSH  [BX]      ;  !.
        NEXT
setvar2:scasw
setvar: mov   [di],bx
        Sjmp  _drop
_0ex:   or    bx,bx
        jNe   _DROP
_DROPX: pop   bx
_exit:  mov   si,Pw [bp]
_rdrop: inc   bp
        inc   bp
        next
@2DROP: POP   AX        ;DDP
@DROP:  CALL  DI        ;DRP
_drop:  pop   bx
        next
_push:  pop   ax
        xchg  ax,bx
        jmp   _rpush
_pop:   push  bx
        mov   bx,[bp]
        jmp   _rdrop
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
;        SJMP  _PUSHW
;        _XT   XT_DOES,DOVAR-1
;        scasw
;        scasw
;_SWPSTO:POP   DI
;        DB    0B9H
;_BRP:   PUSH  BX
;        SHL   BX,1
;        CMC
;        SJMP  _BR_DR
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
        Sjmp  xmovstr

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

        _XT  XT_acpt,@SwAp
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

        _XT  XT_dkey,@dup
_DKEY:  mov  ah,7
        int  021h
        JMP  _LOBYTE

; -------------------
; Peek and Poke
; -------------------

;       _XT  XT_STR,@dup
;       DB    0B9H
        _XT  XT_fetchp,@nup
        MOV   AX,[BX]
        SJMP  _2

;       _XT  XT_STORE,@2DROP
;       DB    0B9H
        _xt  XT_storep,@nip
_storep:MOV   PW [BX],AX
_2:     INC   BX
_1:     INC   BX
        RET

        _XT  XT_CSTORE,@2DROP
        DB    0B9H
        _xt  XT_cstorep,@nip
        MOV   [BX],AL
        JMP  _1

        _XT  XT_Cfetchp,@nup
         DB    0B9H
        _XT  XT_count,@dup
        JMP  _COUNT

; -----------------------
; searching
; -----------------------

        _XT XT_find,@dup
        push  si
        mov   SI,[XT_last+_AT]
        XOR   cX,CX
        DB    0B9H
        ;SJMP FINDN
FND:    add   si,cx
findN:  mov   di,bx
        MOV   DX,SI
        LEA   SI,[SI+3]
        mov   cl,[si]
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

;        _xt  xt_fetch,@nop
;xfetch: mov   bx,[bx]
;        ret

; -------------------
; Maths / Logic / registers
; -------------------

        _xt xt_eqz,@nop
        CMP    BX,1
        SBB    BX,BX
        rET

        _xt XT_lit,@dup
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

        _XT  XT_TOEVAL,@ninu
        ADD   AX,BX
_NEG:   NEG   BX
        RET

; -------------------
; Stack
; -------------------

        _xt XT_dup,@dup
        MOV AX,BX
        RET

        _xt XT_swap,@SwAp
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

        _XT XT_0BR,@DROP
        SUB   bx,1
@ONC:   jC    @jump
@skip:  lodsw
        RET

        _XT XT_br,@NOP
@jump:  mov   si,[si]
        RET

        _xt XT_skip,@NOP
        JMP   @SKIP

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
        DW XT_TOKEN,XT_NZ?,xt_here,xt_find,xt_NZ?,xt_exit

        _COLON XT_lbrak         ; interpreter search
        dw xt_found+_TO,xt_find,xt_0br,num_chk,XT_TRE,xt_EXIT
num_chk:dw XT_ONE,xt_EXIT

        _COLON XT_rbrak         ; compiler search
        dw  xt_found+_TO,XT_FLAG,xt_strpc
        dw  xt_find,xt_0br,comp_it,XT_TRE,xt_EXIT
comp_it dw  xt_dec,xt_find,xt_0br,comp_num,XT_TWO,xt_EXIT
comp_num dw XT_ZER,xt_EXIT

        _COLON xt_num
        dw xt_count,XT_TOEVAL,xt_number,XT_Z?,XT_EXIT

        _COLON2 XT_NZ?
        _COLON2 XT_Z?
        DW XT_EQZ,xt_0ex,xt_qm,XT_EMIT
        DW XT_LIT,12345,XT_DD    ; !!!
        DW XT_ZER,XT_LTB+_TO      ; !!!
        DW XT_LIT,13,XT_emit   ; !!!
        DW XT_LIT,10,XT_emit   ; !!!
        DW XT_LIT,'!',XT_emit   ; !!!
        DW xt_abort

        _xt xt_states,_arw
        dw _states

; -----------------------
; Outer Interpreter TEST
; -----------------------

        _COLON XT_P
        DW XT_KEY,XT_DROP,XT_EXIT

        _COLON XT_?DUP  ; : ?DUP DUP 0; DUP ;
        DW XT_DUP,XT_0EX,XT_DUP,XT_EXIT

        _COLON  XT_DM  ; : #1 10 0SWAP U/MOD >DIG SWAP ;
        DW XT_LIT,10,XT_0SWAP,XT_DIV,XT_DIG,XT_SWAP,XT_EXIT

        _COLON  XT_DD         ; : .. #1 ?DUP IF .. THEN EMIT ;
        DW XT_DM,XT_?DUP,XT_0BR,_DD,XT_DD
_DD     DW XT_EMIT,XT_EXIT    ; : . DUP 0< IF '- EMIT NEG THEN .. ;

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

freemem:

lastw = ppppp

MyCseg  ends
        end  Start

