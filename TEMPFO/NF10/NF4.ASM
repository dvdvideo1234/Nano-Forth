locals  @@

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

_DEFERO macro  lbl,dat
lbl     DW     deferO,dat
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

       ORG 4103H    ;-240H+13

SELF0:  CALL SELF2
SELF1:
; _entry '(0br'   ,xt_0BR
; _entry '0;'     ,xt_0EX
; _entry '@XPE'   ,xt_@XPE
; _entry 'ACCEPT' ,xt_ACCEPT
; _entry 'ACPT'   ,xt_ACPT
; _entry 'BL'     ,xt_BL
; _entry 'BR'     ,xt_BR
; _entry 'CLIT'   ,xt_CLIT
; _entry 'CNTC'   ,xt_CNTC
; _entry 'CODE,'  ,xt_CODECOM
; _entry ':'      ,xt_COL
; _entry ','      ,xt_COMMA
; _entry 'COUNT'  ,xt_COUNT
; _entry '(#+'    ,xt_CPLUS
; _entry 'CSTK'   ,xt_CSTK
; _entry 'C!'     ,xt_CSTORE
; _entry '(DE'    ,xt_DEMIT
; _entry '(DKEY'  ,xt_DKEY
; _entry '(DOES'  ,xt_DOES
; _entry 'ERR'    ,xt_DO_ERR
; _entry 'DROP'   ,xt_DROP
; _entry '(DZTO'  ,xt_DZTO
; _entry 'EMIT'   ,xt_EMIT
; _entry '=0'     ,xt_EQZ
; _entry 'ERR'    ,xt_ERR
; _entry 'ETB'    ,xt_ETB
; _entry 'EVAL'   ,xt_EVAL
; _entry 'EXEC'   ,xt_EXEC
; _entry ';;'     ,xt_EXIT
; _entry '@'      ,xt_FETCH
; _entry '@+'     ,xt_FETCHP
; _entry 'FIND'   ,xt_FIND
; _entry 'FINDC'  ,xt_FINDC
; _entry '(FOR'   ,xt_FOR
; _entry 'HBUF'   ,xt_HBUF
; _entry 'HERE'   ,xt_HERE
; _entry 'INITQ'  ,xt_INITQ
; _entry 'KEY'    ,xt_KEY
; _entry 'LAST'   ,xt_LAST
; _entry 'LATEST' ,xt_LATEST
; _entry '[`'     ,xt_LBRAK
; _entry 'C@.'    ,xt_LDB
; _entry '(#'     ,xt_LIT
; _entry '(#,'    ,xt_LITCOM
; _entry '>TIB'   ,xt_LTB
; _entry '-'      ,xt_MINUS
; _entry 'S!'     ,xt_MOVSTR
; _entry '(NXT'   ,xt_NEXT
; _entry '(NUM'   ,xt_NUM
; _entry '(NUMB'  ,xt_NUMBER
; _entry '<>0?'   ,xt_NZ?
; _entry 'OKV'    ,xt_OKV
; _entry 'PARSE'  ,xt_PARS
; _entry '@EXEC'  ,xt_PERFORM
; _entry '+'      ,xt_PLUS
; _entry 'POP'    ,xt_POP
; _entry 'PUSH'   ,xt_PUSH
; _entry 'QUIT'   ,xt_QUIT
; _entry ']'      ,xt_RBRAK
; _entry 'RDROP'  ,xt_RDROP
; _entry '(SRCH'  ,xt_SEARCH
; _entry ';`'     ,xt_SEMI
; _entry 'S!-'    ,xt_SPUSH
; _entry 'STATES' ,xt_STATES
; _entry 'C!-'    ,xt_STBM
; _entry '!'      ,xt_STORE
; _entry '!+'     ,xt_STOREP
; _entry 'STR'    ,xt_STR
; _entry 'S+C!'   ,xt_STRPC
; _entry '!-'     ,xt_STWM
; _entry 'TIB'    ,xt_TIB
; _entry ''''     ,xt_TICK
; _entry '>EVAL'  ,xt_TOEVAL
; _entry 'TOKEN'  ,xt_TOKEN
; _entry '0=?'    ,xt_Z?
; _entry '0'      ,xt_ZER
 _entry 'ENTRY'  ,XT_ENTRY
 _entry ''       ,0   ; LAST WORD

xt_states dw _arw                       ;= STATES
          DW xt_clit,xt_num,xt_comma,xt_exec

; -----------------------
; Constants
; -----------------------

        _CONST  xt_zer,0                ;= 0
        _CONST  xt_BL,' '               ;= BL
        _CONST  XT_HBUF,0FF00H          ;= SBUF

; -------------------
; Variables
; -------------------

        _DEFER  xt_ACCEPT,XT_ACPT       ;= ACCEPT
        _DEFER  xt_ERR,XT_INITQ         ;= ERROR
        _DEFER  xt_OKV,0                ;= OKv
        _DEFERO xt_emit,xt_demit        ;= EMIT
        _DEFER  xt_key,xt_dkey          ;= KEY
        _XT     XT_DZTO,docons3         ;= (DZTO
        _vector xt_SEARCH,0             ;= (SRCH
        _value  xt_ltb,0                ;= >IN
        _value  xt_etb,0                ;= TIB<
        _value  xt_cntc,0               ;= CNTC
        _VALUE  xt_tib,128              ;= TIB
        _VALUE  XT_LATEST,SELF1         ;= LATEST
        _QUAN   XT_cstk,0               ;= CSTK
        _QUAN   XT_here,freemem         ;= HERE
        _QUAN   xt_last,SELF1           ;= LAST

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

DO_DROPX: DW XT_DROP,XT_EXIT
        _COLON xt_eval                  ;= (EVAL
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

; -------------------
; String
; -------------------

        _XT  XT_SPUSH,@cnip             ;= S!-
        INC  CX
        MOV  DI,BX
        SUB  BX,CX
        JMP  CPUSHU

        _XT  XT_movSTR,@cnip            ;= S!
        MOV  [BX],CL
        LEA  DI,[BX+1]
        JMP  CMOVE

@XPE:   CALL  _DOES
        DW  xt_@xpe,XT_POP,XT_STORE,XT_EXIT

       _XT  XT_strpc,@NIP               ;= S+C!
XSTRPC: MOV  DI,255
        inc  PB [bx]
        AND  DI,[BX]
        MOV  [BX+DI],AL
        RET

; ------------------------
; ENTRY LIST
; ------------------------

        _COLON XT_TOKEN                 ;= TOKEN
        DW XT_BL,XT_PARS,XT_HBUF,XT_MOVSTR,XT_LDB,XT_EXIT

        _COLON  xt_entry                ;= ENTRY
        DW XT_LAST,XT_LATEST+_TO
        DW XT_ZER,XT_TOKEN,XT_NZ?,XT_LDB
        DW XT_LAST+_AT,XT_SPUSH,XT_STBM,XT_STWM,XT_EXIT

; ------------------------
; parsing NUMBERS
; ------------------------

        _XT  XT_number,@ninu            ;= (NUMBER
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

        _xt  XT_PARS,@nup               ;= PARSE
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
        DB    0B9H
defer3: scasw
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
_0:     jmp   SHORT _nop

_arw:   add   bx,bx      ; array of words
_arb:   lea   bx,[bx+di] ; array of bytes
        JMP   SHORT _nOP

        _XT   XT_DOES,DOVAR-1           ;= #DZ
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
_ADDCON:LODSW
        JMP   SHORT _ADDZ
_SUB:   NEG   BX
_ADD:   POP   AX
_ADDZ:  ADD   BX,AX
        JMP   SHORT _nOP
docons3:scasw
docons2:scasw
doconst:mov   ax,[di]
        jmp   SHORT _pushw
dovar:  MOV   ax,di
        jmp   SHORT _pushw

@CSwap: POP   CX
@Swap:  POP   AX
@PuSha: CALL  DI

_pushw: push  bx
_swapw: xchg  ax,bx

_nop:   lodsw
_nop1:  xchg  di,ax
        LEA   DI,[DI+2]    ; !!!
        jmp   Pw [di-2]    ; !!!
@CTUCK: POP   CX   ; TUCK == @TUCKA MOV CX,BX
@TUCKA: POP   AX   ; OVER == @TUCKA XCHG AX,BX TUCK
@TUCK:  CALL  DI   ; -ROT == @CTUCK XCHG AX,BX
_PUSHCA:PUSH  CX   ; ROT  == @CTUCK XCHG AX,CX XCHG AX,BX
        PUSH  AX   ; USWAP== @CTUCK \
        NEXT       ;

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
        JNE   _JUMP
        POP   BX
        JMP   _SKIP

        dec   bx        ;_ifm:
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
        jmp   _rdrop    ; OVER - PUSH - POP U<  SUB BX,CX
                        ; A C B C               SUB AX,CX
@cnip:  POP   cX        ; A C B-C  >R           SUB AX,BX
@nip:   POP   AX        ; A-C B-C               SBB BX,BX
@nop:   CALL  DI        ;
        NEXT            ;

; -------------------
; Inner Interpreter
; -------------------

; LIKE PUSH POINTED BY BX
_STWM:  POP   [BX-2]    ; !-
_2MX:   DEC   BX        ; 2-
_1MX:   DEC   BX        ; 1-
        NEXT

_STWP:  POP   [BX]      ; !+
_2PX:   INC   BX        ; 2+
_1PX:   INC   BX        ; 1+
        NEXT

_@xpe:  PUSH  [BX]      ; @. XCHG PUSH EX
_XPE:   X               ;    XCHG PUSH EX
        POP   AX
        PUSH  BX
        PUSH  SI
        X
        XCHG  AX,SI
        JMP   _DROP

; -----------------------
; Terminal Input / Output
; -----------------------

        _XT  XT_acpt,@swap              ;= (DA
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

        _XT  XT_demit,@DRoP             ;= (DE
        xchg Bx,dx
        mov  ah,2
        JMP  SHORT @@DOS

        _XT  XT_dkey,@pusha             ;= (DK
        mov  ah,7
@@DOS:  int  021h
        JMP  _LOBYTE

; -------------------
; Peek and Poke
; -------------------

        _XT  XT_count,@pusha            ;= CSTR
        JMP  _COUNT

        _XT  XT_LDB,@PUSHA              ;= C@.
        mov   AL,[BX]
        JMP  _LOBYTE

        _XT  XT_STWM,_STWM              ;= !-

        _xt  XT_storep,_STWP            ;= !+

        _XT  XT_STBM,@NIP               ;= C!-
        DEC   BX
        DB    0B9H
        _xt  XT_CSTORE,@2DROP           ;= C!
        MOV  [BX],AL
        RET

        _XT  XT_STORE,@2DROP            ;= !
        mov   [BX],ax
        RET

        _xt  XT_FETCH,@NOP              ;= @    !!!
        MOV   BX,[BX]
        RET

        _xt  XT_FETCHp,@NUP             ;= @+
        DB    0B9H
        _XT  XT_STR,@PUSHA              ;= STR
        MOV  AX,[BX]
        INC  BX
        INC  BX
        RET

; -------------------
; Maths / Logic / registers
; -------------------

        _xt xt_eqz,@nop                 ;= 0=
        CMP    BX,1
        SBB    BX,BX
        rET

        _xt XT_lit,@PUSHA               ;= (#
        lodsw
        RET

        _XT  XT_TOEVAL,@ninu            ;= >EVAL
        ADD   AX,BX
        NEG   BX
        RET

        _XT  XT_MINUS,_SUB              ;= -
        _XT   XT_PLUS,_ADD              ;= +
        _XT  XT_CPLUS,_ADDCON           ;= (#+

; -------------------
; Stack
; -------------------

        _XT XT_drop,_DROP               ;= DROP
        _xt XT_pop,_pop                 ;= POP
        _xt XT_push,_push               ;= PUSH

; -----------------------
; Colon Definition
; -----------------------

        _XT XT_semi,_does0              ;= ;`
        dw xt_exit,xt_lbrak

        _XT XT_col,_does1               ;= :
        dw docolon,xt_rbrak

; -------------------
; Compilation
; -------------------

        _COLON  XT_COMMA                ;= ,
        DW XT_HERE+_AT
        DW XT_STOREP,XT_EXIT

        _xt XT_litcom,_does0            ;= (#,
        dw xt_lit,xt_comma

        _COLON XT_CODECOM               ;= CODE,
        dw XT_HERE,XT_ENTRY,xt_comma,xt_exit

_does0: call _does  ; like ;
        dw xt_STR,xt_comma,xt_perform,xt_exit

_does1: call _does  ; like :
        dw XT_STR,XT_CODECOM,xt_perform,xt_exit

        _COLON xt_clit                  ;= (NUM,
        dw xt_num,xt_litcom,xt_exit

; -------------------
; Flow Control
; -------------------

        _XT XT_@XPE,_@XPE               ;= @XPE
        _XT XT_0BR,_0BR                 ;= (0BR
        _XT XT_br,_jump                 ;= (BR
        _xt XT_exec,_exec               ;= EXEC
        _xt XT_perform,_perform         ;= @EXEC
        _XT XT_exit,_exit               ;= ;;
        _xt XT_0ex,_0ex                 ;= 0;

; -----------------------
; Dictionary Search
; -----------------------

        DW  XT_LAST+_VAL
        DW  XT_EXEC                     ; interpreter search
        _XT XT_lbrak,_DZFIND            ;= [`
                                        ;ON INTERPRET
        _XT XT_find,@pusha              ;= FIND
        CALL  @@FIND
@@2:    INC   AX
        RET

        DW  XT_LATEST+_AT
        DW  XT_COMMA            ;compiler search
        _XT XT_rbrak,_DZFIND            ;= ]
                                ;ON COMPILE
        _XT XT_findC,@pusha             ;= FINDC
        MOV   AL,'`'
        CALL  XSTRPC
        CALL  @@FIND
        JNZ   @@2
        DEC   PB [BX]
@@FIND: push  si
        mov   SI,[XT_SEARCH+_AT]
        MOV   SI,[SI-6]
        MOV   SI,[SI]
        XOR   cX,CX
@@noFND:add   si,cx
        mov   di,bx
        MOV   DX,SI
        LEA   SI,[SI+3]
        mov   cl,[si]
        jcxz  @@Xfnd
        inc   cx
        repe  cmpsb
        jNZ   @@nofnd
        inc   cx
        MOV   BX,DX     ;fnd_ok:
        MOV   BX,[BX]
@@Xfnd: xchg  ax,CX
        SHL   AX,1
        pop   si
        RET

_DZFIND: CALL _DOES
        DW Xt_SEARCH+_TO,XT_EXIT

; -----------------------
; Outer Interpreter
; -----------------------

;        _XT XT_TO,_DZtOaT               ;= TO
;        DW 2

        _COLON XT_TICK                  ;= '
        DW XT_TOKEN,XT_NZ?,XT_FIND,XT_NZ?,XT_EXIT

_dzToAt: CALL _DOES
        DW Xt_FETCH,XT_TICK,XT_PLUS,XT_DZTO
        DW XT_CPLUS,-4,XT_PERFORM,XT_EXIT

        _COLON xt_num                   ;= (NUM
        dw xt_count,XT_TOEVAL,xt_number,XT_Z?,xt_EXIT

        _XT XT_QUIT,_RESTART            ;= QUIT

        _COLON XT_DO_ERR                ;= (ERR

        _COLON2 XT_NZ?                  ;= <>0?
        _COLON2 XT_Z?                   ;= =0?
        DW  XT_EQZ,xt_0ex,xt_ERR,XT_LIT,'?',XT_EMIT,XT_QUIT

        _COLON  XT_INITQ                ;= (INIT
        DW XT_ZER,XT_TIB,XT_STORE,XT_EXIT

freemem:

lastw = ppppp

MyCseg  ends
        end  Start

