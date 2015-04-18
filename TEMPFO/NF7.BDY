;        ORG 4103H

;        INCLUDE NF7.I
;        INCLUDE NF7.I_3

;t_TICK :_entry ''''    ,xt_TICK
T_ENTRY :_entry '=:'    ,CL_ENTRY
 _entry ''      ,0      ; LAST WORD

xt_states dw _arw                       ;= STATES
          DW CL_clit,CL_num,CL_comma,xt_exec

; -----------------------
; Constants
; -----------------------

        _CONST  xt_0,0                  ;= 0
        _CONST  xt_1,1                  ;= 1
        _MCONS  xt_BL,' '               ;= BL
XT_SPACE = $-4
        _CONST  XT_HBUF,0FF00H          ;= SBUF

; -------------------
; Variables
; -------------------

        _DEFER  xt_ACCEPT,XT_ACPT       ;= ACCEPT
        _DEFER  xt_ERR,0                ;= ERROR
        _DEFER  xt_OKV,0                ;= OKv
        _DEFERO xt_emit,xt_demit        ;= EMIT
        _value  xt_cntc,0               ;= CNTC
        _DEFER  xt_key,xt_dkey          ;= KEY
        _POINT  XT_DoSRCH,0             ;= (SRCH?
        _value  xt_ltb,0                ;= >IN
        _value  xt_etb,0                ;= TIB<
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
        dw   CL_lbrak,xt_tib,xt_count
?xsyslp dw   CL_eval,xt_OKV
?QUIT   dw   xt_tib,xt_LIT,126,xt_accept,XT_BR,?xsyslp

        _colon  CL_times                ; = TIMES
        DW XT_SWAP,XT_PUSH
        _colon  CL_LOOPS                ; = LOOPS
        dw xt_for,?xtimes    ; for j execute next rdrop drop ;
?times  dw xt_j,CL_execute,xt_next,?times
?xtimes dw xt_rdrop,XT_DROPX

        _COLON CL_eval                  ;= (EVAL
        dw xt_TOEVAL,XT_ltb+_TO,Xt_etb+_TO
?int:   dw CL_TOKEN,xt_?BR,?XTIMES,xt_DoSRCH
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
_MOVE?: CMP  DI,AX
        JB   CMOVE
CMOVEU: ADD  DI,CX
CPUSHU: DEC  DI
        ADD  AX,CX
        DEC  AX
        STD
CMOVE:  PUSH CX
        XCHG AX,SI
        REP  MOVSB
        XCHG AX,SI
        POP  CX
        XCHG AX,CX
        CLD
        RET

; -------------------
; String
; -------------------

        _XT  XT_EMOVE,@CSWAP            ;= EMOVE
        MOV   DI,BX
        XCHG  CX,DI
        JMP   _MOVE?

        _XT  XT_EPUSH,@CSWAP            ;= S!-
        MOV  DI,BX
        SUB  BX,CX
        JMP  CPUSHU

        _XT  XT_movSTR,@2nip            ;= S!
        MOV  [BX],CL
        LEA  DI,[BX+1]
        JMP  CMOVE

        _XT  XT_strpc,@NIP              ;= S]C!
        MOV  DI,255
        AND  DI,[BX]
        MOV  [BX+DI],AL
        RET

; ------------------------
; ENTRY LIST
; ------------------------

        _COLON  CL_XHERE                ;= ;HERE
        DW XT_HERE,XT_EX,XT_HERE+_TO,XT_EXIT

        _COLON  CL_XLATEST              ;= ;LATEST
        DW XT_LATEST,XT_EX,XT_LATEST+_TO,XT_EXIT

        _COLON  CL_ALLOT                ;= ALLOT
        DW CL_XHERE,XT_PLUS,XT_EXIT

        _COLON CL_ALIGN                 ;= ALIGN
        DW XT_HERE,XT_1,XT_AND,XT_0EX
        _COLON CL_NOPCOM                ;= NOP,
        DW XT_LIT,090H
        _COLON CL_BCOMMA                ;= C,
        DW CL_XHERE,XT_CSTOREP,XT_EXIT

        _COLON CL_TOKEN                 ;= ="
        DW XT_BL,XT_PARS,XT_HBUF,XT_MOVSTR
        _COLON CL_CFETCHD               ;= C@.
        DW XT_DUP
        _COLON CL_CFETCH                ;= C@
        DW XT_COUNT,XT_NIP,XT_EXIT

        _COLON  CL_COL                  ;= :
        DW CL_ALIGN,XT_HERE,XT_1P
        _COLON  CL_entry                ;= =:
        DW XT_LAteST,XT_LAST+_TO,CL_TOKEN,CL_NZ?,XT_COUNT
        DW CL_XLAteST,XT_EPUSH,XT_FLIP,XT_SWAP,CL_STOREM
        _COLON  CL_STOREM
        DW XT_PUSH,XT_DUP,XT_FLIP,XT_POP
        DW XT_CSTOREM,XT_CSTOREM,XT_EXIT


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
        DB    0B1H
_NOP2:  DEC   AX

pcpush: XCHG  AX,SI
_rpush: dec   bp
        dec   bp
        mov   [bp],AX
        JMP   SHORT _nOP

docons3:scasw
docons2:scasw
doconst:PUSH  Bx
        MOV   BX,DI
_FETCH: mov   Bx,[BX]   ; @
        JMP   SHORT _nOP

_STWP:  POP   [BX]      ; !+
        DB    0B9H
_LDWP:  PUSH  [BX]      ; @+
_2P:    INC   BX        ; 2+
_1P:    INC   BX        ; 1+
        JMP   SHORT _nOP

_STBP:  POP   AX        ; C!+
        MOV   [BX],AL
        JMP   _1P

_STWB:  POP  AX        ; C!-
        MOV  [BX-1],AL
        DB    0B1H
_2M:    DEC  BX        ; 2-
_1M:    DEC  BX        ; 1-
        JMP   SHORT _nOP

_STBM:  POP   AX
        MOV   [BX-1],AL
        JMP   _1M

_WlOW:  MOV   BL,0
        DB    0B9H
_FLIP:  XCHG  BL,BH
        JMP   SHORT _nOP

dovar1: SCASW
dovar:  XCHG  ax,di
        jmp   SHORT _pushw

@OVER:  POP   AX
        PUSH  AX
        DB    0B9H
@CSwap: POP   CX
@Swap:  POP   AX
@PuSha: CALL  DI

_pushw: push  bx
_swapw: xchg  ax,bx

_nop:   lodsw
_NOP1:  TEST  AL,1
        JNE   _NOP2
        XCHG  DI,AX
        LEA   DI,[DI+2]    ; !!!
        jmp   Pw [di-2]    ; !!!

_MINUS: NEG   BX
_PLUS:  POP   AX
        ADD   BX,AX
        JMP   _NOP

_AND:   POP   AX
        AND   BX,AX
        JMP   _NOP

_ABS:   OR    BX,BX
        JNS   _2
_NEG:   DEC   BX
_NOT:   MOV   AX,-1
        DB    0B1H
_XOR:   POP   AX
        XOR   BX,AX
_2:     JMP   _NOP

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

@3DROP: POP   CX
@2drop: POP   AX
@DRoP:  CALL  DI
_drop:  pop   bx
        next

_OF:    POP   AX
        XCHG  BX,AX
        SUB   AX,BX
        JNE   SHORT _JUMP
_SKDRP: POP   BX
_skip:  lodsw
        next

_?SKDR: or    bx,bx
        jE    _SKDRP
        next

_?br:   PUSH  BX
_0br:   OR    bx,BX
        pop   bx
        jZ    _jump
        JMP   _SKIP

_MBR:   OR    bx,BX
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

_NEXT:  SUB   PW [BP],1
        JNC   _JUMP
        LODSW

_pop:   push  bx
        mov   bx,[bp]
        jmp   _rdrop    ; OVER - PUSH - POP U<  SUB BX,CX
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

        _XT  XT_acpt,@SWAP            ;= (DA
        XCHG AX,BX
        MOV  [BX],AX
        MOV  AH,10
        CALL @@DOS1
        INC  BX
@@COUNT:MOV  AL,[BX]
        INC  BX
@@BYTE: MOV  AH,0
        RET

        _XT  XT_demit,@DRoP             ;= (DE
        mov  ah,2
@@DOS1: MOV  DX,BX
        JMP  SHORT @@DOS

        _XT  XT_dkey,@pusha             ;= (DK
        mov  ah,7
@@DOS:  int  021h
        JMP  @@BYTE

; -------------------
; Peek and Poke
; -------------------

        _XT  XT_count,@PUSHA            ;= CSTR
        JMP  @@COUNT

        _xt  XT_FETCH,_FETCH            ;= @    !!!

        _xt  XT_storep,_STWP            ;= !+

        _xt  XT_CstoreM,_STBM           ;= C!-

        _xt  XT_Cstorep,_STBP           ;= C!+

        _XT  XT_FETCHp,_LDWP            ;= @+

        _COLON CL_ATEX                  ;= ;@X
        dw XT_FETCHP,XT_SWAP,XT_EX,XT_perform,xt_exit

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

        _XT XT_DIV,@Dinu                ;= UM/MOD
        DIV   BX
        XCHG  AX,DX
XDTOP:  MOV   BX,DX
        RET

        _XT XT_MUL,@ninu                ;= UM*
        MUL   BX
        JMP   XDTOP

        _XT XT_LOW,_WLOW                ;= W>B
        _XT XT_2M,_2M                   ;= 2-
        _XT XT_1M,_1M                   ;= 1-
        _XT XT_2P,_2P                   ;= 2+
        _XT XT_1P,_1P                   ;= 1+
        _XT XT_MINUS,_MINUS             ;= -
        _XT XT_PLUS,_PLUS               ;= +
        _XT XT_AND,_AND                 ;= AND
        _XT XT_ABS,_ABS                 ;= ABS
        _XT XT_NEG,_NEG                 ;= NEG
        _XT XT_NOT,_NOT                 ;= NOT
        _XT XT_XOR,_XOR                 ;= XOR

; -------------------
; Stack
; -------------------

        _XT XT_DUP,_DUP                 ;= DUP
        _XT XT_drop,_DROP               ;= DROP
        _xt XT_push,_push               ;= PUSH
        _xt XT_pop,_pop                 ;= POP
        _XT XT_FLIP,_FLIP               ;= FLIP

        _XT XT_NIP,@NIP                 ;= NIP
        RET

        _XT XT_OVER,@OVER               ;= OVER
        XCHG  AX,BX
        MOV   CX,BX
        RET

        _XT XT_SWAP,@SWAP               ;= SWAP
        RET

        _colon CL_xdrop                 ;= ;DROP
        dw xt_ex,xt_dropx

        _XT XT_XCHG,@NOP                ;= XCHG
        XCHG  BX,[BP]
        RET

        _XT XT_EX,@NOP                  ;= EX
        XCHG  SI,[BP]
        RET

        _xt XT_I,@pusha                 ;= I
        mov   ax,[bp]
        RET

        _xt XT_j,@pusha                 ;= J
        mov   ax,[bp+2]
        RET

; -----------------------
; Colon Definition
; -----------------------

        _XT XT_semi,_does0              ;= ;`
        dw xt_exit,CL_lbrak

        _XT XT_cREATE,_does1            ;= CREATE
        dw doVAR,CL_rbrak

; -------------------
; Compilation
; -------------------

        _xt XT_litcom,_does0            ;= #`
        dw xt_lit,CL_comma

_does1: NOP
        call _does  ; like :
        dw CL_ATEX
        _COLON CL_CODECOM               ;= =:,
        dw CL_ALIGN,XT_HERE,CL_ENTRY
        _COLON  CL_COMMA                ;= ,
        DW CL_XHERE,XT_STOREP,XT_EXIT

_does0: call _does  ; like ;
        dw CL_ATEX,CL_comma,xt_exit

_DOES5: CALL _DOES
        DW  XT_COUNT,XT_EMIT,XT_DROPX

        _COLON CL_clit                  ;= (NUM,
        dw CL_num,xt_litcom,xt_exit

; -------------------
; Flow Control
; -------------------


        _XT xT_?SKDR,_?SKDR             ;= ?>SKIP
        _XT xT_MBR,_MBR                 ;= (-br
        _XT XT_OF,_OF                   ;= (OF
        _XT XT_RDROP,_RDROP             ;= RDROP
        _XT xT_?BR,_?BR                 ;= (?br
        _XT XT_0BR,_0BR                 ;= (0BR
        _XT XT_br,_jump                 ;= (BR
        _XT XT_FOR,_FOR                 ;= (FOR
        _XT XT_NEXT,_NEXT               ;= (NXT
        _xt XT_exec,_exec               ;= EXEC
        _xt XT_perform,_perform         ;= @EXEC
        _XT XT_SKIP,_SKIP               ;= SKIP
        _XT XT_exit,_exit               ;= ;;
        _xt XT_0ex,_0ex                 ;= 0;
        _XT XT_DROPX,_DROPX             ;= DROP;

        _colon CL_execute               ;= EXECUTE
        dw xt_push,xt_exit


; -----------------------
; Dictionary Search
; -----------------------

        _XT   XT_FIND,@SWAP             ;= FIND
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

        _XT XT_INC,@NOP                 ;= INC
        inc  PW [bx]
        RET

        _XT XT_DEC,@NOP                 ;= DEC
        DEC  PW [BX]
        RET

        _COLON CL_lbrak                 ;= [`
        DW  _TO+XT_DOSRCH,XT_LATEST,XT_FIND,XT_1P,XT_EXIT

        _COLON CL_rbrak                 ;= ]
        DW  _TO+XT_DOSRCH,XT_INC,XT_LIT,'`'
        DW  XT_SWAP,XT_STRPC,XT_LAST,XT_FIND
        DW  XT_0BR,@@RFND,XT_LIT,3,XT_EXIT
@@RFND  DW  XT_DEC,XT_LAST,XT_FIND,XT_EXIT

; -----------------------
; Outer Interpreter
; -----------------------

        _COLON CL_num                   ;= (NUM
        dw xt_count,XT_TOEVAL,xt_number,CL_Z?,xt_EXIT

        _XT XT_ABORT,@@INI              ;= ABORT
@@INI:  CALL  _INI4TH
        DW CL_LBRAK,xt_ERR,XT_BR,?QUIT

        _XT xt_qm,_DOES5                ;= c?
        DB '?'

        _COLON CL_NZ?                   ;= <>0?
        DW  XT_EQZ
        _COLON CL_Z?                    ;= =0?
        DW  xt_0ex,XT_qm,XT_ABORT

        _colon  CL_type                 ;= TYPE
        dw CL_xdrop
        _colon  CL_Ptype                ;= PTYPE
        DW CL_LOOPs,xt_count,xt_EMIT,xt_exit

        _COLON  CL_ETYPE
        DW XT_SPACE,XT_HBUF
        _COLON  CL_ID
        DW XT_COUNT,CL_TYPE,XT_SPACE,XT_EXIT

; -----------------------
; Outer Interpreter2
; -----------------------

;       include nf7.i1
;       include nf7.i2
;       include nf7.i3
