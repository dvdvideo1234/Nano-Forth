        INCLUDE  NF6.I0

        org 100h
Start   Label byte
        JMP SELF0

        ORG 4103H

SELF0:  CALL SELF2
SELF1:
;       INCLUDE NF6.I
;       INCLUDE NF6.I_3

;t_TICK :_entry ''''    ,xt_TICK
T_ENTRY :_entry '=:'    ,XT_ENTRY
 _entry ''      ,0      ; LAST WORD

xt_states dw _arw                       ;= STATES
          DW xt_clit,xt_num,xt_comma,xt_exec

; -----------------------
; Constants
; -----------------------

        _BCONST XT_BTICK,'`'
        _BCONST xt_zer,0                ;= 0
        _BVECT  xt_BL,' '               ;= BL
XT_SPACE = XT_BL+_TO                    ;= SPACE
        _CONST  XT_HBUF,0FF00H          ;= SBUF

; -------------------
; Variables
; -------------------

        _DEFER  xt_ACCEPT,XT_ACPT       ;= ACCEPT
        _DEFER  xt_ERR,0                ;= ERROR
        _DEFER  xt_OKV,0                ;= OKv
        _DEFERO xt_emit,xt_demit        ;= EMIT
        _DEFER  xt_key,xt_dkey          ;= KEY
        _POINT  XT_DoSRCH,0             ;= (SRCH?
        _value  xt_ltb,0                ;= >IN
        _value  xt_etb,0                ;= TIB<
        _value  xt_cntc,0               ;= CNTC
        _VALUE  xt_tib,128              ;= TIB
        _VALUE  XT_LAST,SELF1           ;= LAST
        _VALUE  XT_here,freemem         ;= HERE
        _VALUE  xt_latest,SELF1         ;= LAteST

; -------------------

SELF2:  CALL MOVER      ; relocator

; -------------------
; Initialisation  and main loop
; -------------------

_INIT:  call _INI4TH    ; COLD START
        dw   xt_lbrak,xt_tib,xt_count
?xsyslp dw   xt_eval,xt_OKV
?QUIT   dw   xt_tib,xt_BTICK,xt_accept,XT_BR,?xsyslp

        _COLON xt_eval                  ;= (EVAL
        dw xt_TOEVAL,XT_ltb+_TO,Xt_etb+_TO
?int:   dw XT_TOKEN,xt_0STRX,xt_DoSRCH
        DW xt_states,xt_perform,xt_br,?int

MOVER:  mov  bx,1000h     ; only 64k allocate
        mov  ah,4ah
        int  21h
        POP  BX           ; and relocate
        MOV  DI,[BX-5]    ; CELL + [CAL]
        MOV  CX,[BX-11]   ; 5 CELLS + [CAL]
        SUB  CX,DI
        POP  AX
        SUB  BX,AX
        ADD  BX,DI
        PUSH BX
__MOVE?:CMP  DI,AX
        JB   CMOVE
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

        _XT  XT_count,_COUNT            ;= CSTR

        _XT XT_EPUSH,@2NIP              ;= S!-
        INC  CX
        MOV  DI,BX
        CALL CPUSHU
        MOV  BX,DI
        MOV  [BX],CL
        RET

        _XT  XT_movSTR,@2nip            ;= S!
        MOV  [BX],CL
        LEA  DI,[BX+1]
        JMP  CMOVE

        _XT  XT_strpc,@NIP              ;= S+C!
        XCHG AX,BX
_STRPC: MOV  DI,255
        inc  PB [bx]
        AND  DI,[BX]
        MOV  [BX+DI],AL
        RET

; ------------------------
; ENTRY LIST
; ------------------------

        _COLON XT_TOKEN                 ;= ="
        DW XT_BL,XT_PARS,XT_HBUF,XT_MOVSTR,XT_EXIT

        _COLON  xt_entry                ;= =:
        DW XT_LAteST,XT_LAST+_TO,XT_TOKEN?,XT_CFETCHD
        DW XT_LAteST,XT_EPUSH,XT_STOREM,XT_LAteST+_TO,XT_EXIT

; ------------------------
; parsing NUMBERS
; ------------------------

        _XT  XT_number,@ninu            ;= (>#
        push BP
        MOV  di,10  ; base := 10
        xchg ax,Di  ; ENDBUF
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

@@NUM:  CALL @@NUMini
        CALL @@SGN
@@NUMZ: CALL @@CNUM
        CALL @@N1
        JMP  SHORT  @@NUMZ

@@n1:   cmp  al,'$'     ; BASE := 16
        JNE  @@N2
        MOV  al,16
        jmp  SHORT @@setbas

@@N2:   cmp  al,'#'     ; BASE := CX
        JNE  @@N3
        mov  al,cl
@@numini:xor cx,cx      ; ACCUMULATOR
@@setbas:mov bp,ax
        deC  BX     ; back one char
@@CNUM: INC  BX
        MOV  AL,[BX+DI]
        JnE  @@noEXN
@@EXNUM:pop  dx    ; rdrop
@@noEXn:RET

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

        _xt   XT_PARS,@nup              ;= PARSE
        mov   ax,PW [XT_etb+_AT]
        xchg  ax,bx
        mov   dx,ax
        mov   DI,PW [XT_ltb+_AT]
        CMP   AL,' '
        JNE   @@SKIPX
        DEC   di
@@WSKP: INC   di
        JE    @@SKIPX
        MOV   dH,[BX+DI]
        CMP   dH,dL
        JBE   @@WSKP
@@SKIPX:LEA   aX,[BX+DI]
        DEC   di
@@WSCZ: INC   di
        JE    @@WEX
        MOV   dH,[BX+DI]
        CMP   dH,dL
        JNE   @@WSCZ
@@WEX:  SUB   bx,aX
        ADD   BX,DI
        or    di,di
        Je    @@WORDE
        INC   di
@@worde:mov   PW [XT_ltb+_AT],di
        rET

; -------------------
; Inner Interpreter
; -------------------

DOPOINT:MOV   AX,[DI+2]
        jmp   SHORT pcpush

_INI4TH:pop   si
        MOV   bp,XT_HBUF+_TO
        LEA   sp,[BP-1024]
_0:     jmp   SHORT _nop

DEFERO: INC   PW [XT_CNTC+_AT]
        DB    0B9H
defer3: scasw
defer2: scasw
DEFER:  push  bx
        MOV   bx,di

_perform:mov  bx,[bx]
_exec:  OR    Bx,BX
        POP   AX
        xchg  Ax,bx
        JZ    _0
        jmp   SHORT _nop1

_arw:   add   bx,bx      ; array of words
_arb:   lea   bx,[bx+di] ; array of bytes
        JMP   SHORT _nOP

        _XT XT_CDOES,dovar1
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

__call: lodsw
        jmp   pcpush

        scasw
        scasw
docolon:xchg  ax,di
        jmp   SHORT pcpush

docons3:scasw
docons2:scasw
doconst:PUSH  Bx
        MOV   BX,DI
_FETCH: mov   Bx,[BX]
        JMP   SHORT _nOP

_LDWP:  PUSH  [BX]
_2P:    INC   BX        ; 2+
_1P:    INC   BX        ; 1+
        JMP   SHORT _nOP

_STWP:  POP   [BX]
        JMP   _2P

_STBP:  POP   AX
        MOV   [BX],AL
        JMP   _1P

_STWM:  POP  [BX-2]    ; !-
__2M:   DEC  BX        ; 2-
__1M:   DEC  BX        ; 1-
        JMP   SHORT _nOP

        SCASW
Bconst: PUSH  Bx
        MOV   BX,DI
        JMP   SHORT _CFETCH

_COUNT1:INC   BX
_COUNT: INC   BX
        PUSH  BX
        DEC   BX

_CFETCH:MOV   BH,[BX]
__WHI:  MOV   BL,0
__FLIP: XCHG  BL,BH
        JMP   SHORT _nOP

dovar1: SCASW
dovar:  XCHG  ax,di
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

_STRX:  CMP   PB [BX],0
        JNE   _NOP
        DB    0B9H

_0ex:   or    bx,bx
        jNe   _DROP

_DROPX: pop   bx
_exit:  mov   si,Pw [bp]
__rdrop:inc   bp
        inc   bp
        next

@3DROP: POP   CX
@2drop: POP   AX
@DRoP:  CALL  DI
_drop:  pop   bx
        next

@ROT:   POP   CX
@OVER:  POP   AX
        CALL  DI
        PUSH  Cx
        PUSH  Ax
        next

__OF:   POP   AX
        XCHG  BX,AX
        SUB   AX,BX
        JE    __SKDRP
        JMP   SHORT _JUMP

__?SKDR:or    bx,bx
        jNE   _1
__SKDRP:POP   BX
_skip:  lodsw
_1:     next

__?br:  PUSH  BX
_0br:   OR    bx,BX
        pop   bx
        jZ    _jump
        JMP   _SKIP

__MBR:  INC   BX
        dec   bx
        js    _skip
_jump:  mov   si,[si]
        next

__FOR:  SUB   BX,1
        JNC   @@1
        DEC   BX
@@1:    JS    _JUMP
        LODSW

_push:  pop   ax
        xchg  ax,bx
        jmp   _rpush

__NEXT: SUB   PW [BP],1
        JNC   _JUMP
        LODSW

_pop:   push  bx
        mov   bx,[bp]
        jmp   __rdrop   ; OVER - PUSH - POP U<  SUB BX,CX
                        ; A C B C               SUB AX,CX
@2nip:  POP   cX        ; A C B-C  >R           SUB AX,BX
@nip:   POP   AX        ; A-C B-C               SBB BX,BX
@nop:   CALL  DI        ;
        NEXT            ;

SETPOINT: MOV   [DI],SI
        JMP   SHORT _EXIT
;
; Inner Interpreter
; -------------------

; -----------------------
; Terminal Input / Output
; -----------------------

        _PRIM  XT_acpt                  ;= (DA
        POP  AX
        XCHG AX,BX
        MOV  [BX],AX
        MOV  AH,10
        CALL @@DOS1
        JMP  _COUNT1

        _XT  XT_demit,@DRoP             ;= (DE
        mov  ah,2
@@DOS1: MOV  DX,BX
        JMP  SHORT @@DOS

        _XT  XT_dkey,@pusha             ;= (DK
        mov  ah,7
@@DOS:  int  021h
@@BYTE: MOV  AH,0
        RET

; -------------------
; Peek and Poke
; -------------------

        _XT  XT_CFETCHD,@PUSHA          ;= C@.
        MOV  AL,[BX]
        JMP  @@BYTE

        _xt  XT_CFETCH,_CFETCH          ;= C@

        _xt  XT_FETCH,_FETCH            ;= @    !!!

        _xt  XT_storep,_STWP            ;= !+

        _xt  XT_storeM,_STWM            ;= !-

        _xt  XT_Cstorep,_STBP           ;= C!+

        _XT  XT_FETCHp,_LDWP            ;= @+

        _COLON XT_STR                   ;= STR
        dw   XT_FETCHP,XT_SWAP,XT_EXIT

; -------------------
; Maths / Logic / registers
; -------------------

        _xt  XT_lit,@PUSHA              ;= (#
        LODSW
        RET

        _XT  XT_TOEVAL,@ninu            ;= >EVAL
        ADD   AX,BX
        NEG   BX
        RET

        _xt xt_eqz,@nop                 ;= 0=
        CMP  BX,1
@@CARRY:SBB  BX,BX
        rET

        _XT XT_0LESS,@NOP               ;= 0<
        SHL BX,1
        JMP @@CARRY

        _XT XT_ULESS,@NIP               ;= U<
@@ULESS:SUB  AX,BX
        JMP  @@CARRY

        _XT  XT_WITHIN,@2NIP            ;= WITHIN
        SUB  BX,CX
        SUB  AX,CX
        JMP  @@ULESS

        _XT XT_2P,_2P                   ;= 2+
        _XT XT_1P,_1P                   ;= 1+

; -------------------
; Stack
; -------------------

        _XT XT_DUP,_DUP                 ;= DUP
        _XT XT_drop,_DROP               ;= DROP
        _xt XT_push,_push               ;= PUSH
        _xt XT_pop,_pop                 ;= POP

        _XT XT_OVER,@OVER               ;= OVER
        XCHG  AX,BX
        MOV   CX,BX
        RET

        _XT XT_SWAP,@SWAP               ;= SWAP
        RET

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
        DW XT_HERE,XT_STOREP,XT_HERE+_TO,XT_EXIT

        _xt XT_litcom,_does0            ;= #`
        dw xt_lit,xt_comma

        _COLON XT_CODECOM               ;= =:,
        dw XT_HERE,XT_ENTRY,xt_comma,xt_exit

_does0: call _does  ; like ;
        dw XT_STR,xt_comma,xt_perform,xt_exit

_does1: call _does  ; like :
        dw XT_STR,XT_CODECOM,xt_perform,xt_exit

_DOES5: CALL _DOES
        DW  XT_CFETCH,XT_EMIT,XT_EXIT

        _COLON xt_clit                  ;= (NUM,
        dw xt_num,xt_litcom,xt_exit

; -------------------
; Flow Control
; -------------------

        _XT XT_0BR,_0BR                 ;= (0BR
        _XT XT_br,_jump                 ;= (BR
        _xt XT_exec,_exec               ;= EXEC
        _xt XT_perform,_perform         ;= @EXEC
        _XT XT_SKIP,_SKIP               ;= SKIP
        _XT XT_exit,_exit               ;= ;;
        _xt XT_0ex,_0ex                 ;= 0;
        _XT XT_DROPX,_DROPX             ;= DROP;
        _XT XT_0STRX,_STRX              ;= 0STR;

; -----------------------
; Dictionary Search
; -----------------------

        _XT  XT_FIND,@SWAP              ;= FIND
        push  si
        XCHG  AX,BX
        XCHG  AX,SI
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

        _XT XT_DEC,@NOP                 ;= DEC
        DEC  PW [BX]
        RET

        _COLON XT_lbrak                 ;= [`
        DW  _TO+XT_DOSRCH,XT_LATEST,XT_FIND,XT_1P,XT_EXIT

        _COLON XT_rbrak                 ;= ]
        DW  _TO+XT_DOSRCH,XT_BTICK,XT_STRPC,XT_LAST,XT_FIND
        DW  XT_0BR,@@RFND,XT_LIT,3,XT_EXIT
@@RFND  DW  XT_DEC,XT_LAST,XT_FIND,XT_EXIT

; -----------------------
; Outer Interpreter
; -----------------------

        _COLON xt_num                   ;= (NUM
        dw xt_count,XT_TOEVAL,xt_number,XT_Z?,xt_EXIT

        _PRIM XT_ABORT                  ;= ABORT
        CALL  _INI4TH
        DW XT_LBRAK,xt_ERR,XT_qm,XT_BR,?QUIT

        _XT xt_qm,_DOES5                ;= c?
        DB '?'

        _COLON  XT_TOKEN?               ;= TOKEN?
        DW XT_TOKEN,xt_cfetchD
        _COLONP XT_NZ?                  ;= <>0?
        DW  XT_EQZ
        _COLONP XT_Z?                   ;= =0?
        DW  xt_0ex,XT_ABORT

; -----------------------
; Outer Interpreter2
; -----------------------

;       include nf6.i1
;       include nf6.i2
;       include nf6.i3

freemem:

lastw = ppppp

MyCseg  ends
        end  Start

