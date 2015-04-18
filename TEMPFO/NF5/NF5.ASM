        INCLUDE  NF5.I0

        org 100h
Start   Label byte
        JMP SELF0

        ORG 4103H

SELF0:  CALL SELF2
SELF1:
;     INCLUDE NF5.I

;t_TICK   :_entry ''''     ,xt_TICK
T_ENTRY  :_entry 'ENTRY'  ,XT_ENTRY
 _entry ''       ,0   ; LAST WORD

xt_states dw _arw                       ;= STATES
          DW xt_clit,xt_num,xt_comma,xt_exec

; -----------------------
; Constants
; -----------------------

        _BCONST  xt_zer,0               ;= 0
        _BVECT   xt_BL,' '              ;= BL
        xt_space = xt_bl+2              ;= SPACE
        _CONST  XT_HBUF,0FF00H          ;= SBUF

; -------------------
; Variables
; -------------------

        _DEFER  xt_ACCEPT,XT_ACPT       ;= ACCEPT
        _DEFER  xt_ERR,XT_INITQ         ;= ERROR
        _DEFER  xt_OKV,0                ;= OKv
        _DEFERO xt_emit,xt_demit        ;= EMIT
        _DEFER  xt_key,xt_dkey          ;= KEY
        _XT     XT_HelpTO,DOCONS3       ;= (TO.
        _POINT  XT_DoSRCH,0             ;= (SRCH?
        _VALUE  xt_SRCHP,0              ;= (SRCH.
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
        dw   xt_lbrak
;       DW   xt_lit,T_ENTRY+3,XT_FIND,XT_HPRT,XT_HPRT
;       dw   xt_lit,35536,xt_numo
;       dw   xt_lit,35536,xt_numo
;       dw   xt_bye

?xsyslp dw   xt_tib,xt_count,xt_eval,xt_OKV
?QUIT   dw   xt_tib,xt_LIT,126,xt_accept,XT_BR,?xsyslp

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

        _PRIM  XT_EPUSH                 ;= S!-
        POP  CX
        POP  AX
        INC  CX
        DEC  AX
        MOV  DI,BX
        CALL CPUSHU
        MOV  BX,DI
        MOV  [BX],CL
__STWM: POP   [BX-2]    ; !-
__2M:   DEC   BX        ; 2-
_1M:    DEC   BX        ; 1-
        NEXT

        _XT  XT_movSTR,@2nip            ;= S!
        MOV  [BX],CL
        LEA  DI,[BX+1]
        JMP  CMOVE

        _XT  XT_strpc,@NIP              ;= S+C!
XSTRPC: MOV  DI,255
        inc  PB [bx]
        AND  DI,[BX]
        MOV  [BX+DI],AL
        RET

; ------------------------
; ENTRY LIST
; ------------------------

        _COLON XT_TOKEN                 ;= TOKEN
        DW XT_BL,XT_PARS,XT_HBUF,XT_MOVSTR,xt_dup,xt_cfetch,XT_EXIT

        _COLON  xt_entry                ;= ENTRY
        DW XT_LAteST,XT_LAST+_TO,XT_TOKEN?,XT_COUNT
        DW XT_LAteST,XT_EPUSH,XT_LAteST+_TO,XT_EXIT

; ------------------------
; parsing NUMBERS
; ------------------------

        _XT  XT_number,@ninu            ;= (NUMBER
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

_LIT:   LODSW
        jmp   SHORT _pushw

docons3:scasw
docons2:scasw
doconst:PUSH  Bx
        MOV   BX,DI
_FETCH: mov   Bx,[BX]
        JMP   SHORT _nOP

_LDWP:  PUSH  [BX]
_2P:    INC   BX        ; 2+
__1P:   INC   BX        ; 1+
        JMP   SHORT _nOP

_STBP:  POP   AX
        MOV   [BX],AL
        JMP   __1P

_STWP:  POP   [BX]
        JMP   _2P

        SCASW
Bconst: PUSH  Bx
        MOV   BX,DI
        JMP   SHORT _CFETCH

_COUNT: INC   BX
        PUSH  BX
        DEC   BX

_CFETCH:MOV   BH,[BX]
__WHI:  MOV   BL,0
__FLIP: XCHG  BL,BH
        JMP   SHORT _nOP

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
_0br:   SUB   bx,1
        pop   bx
        jC    _jump
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
        jmp   __rdrop    ; OVER - PUSH - POP U<  SUB BX,CX
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

        _XT  XT_acpt,@2DROP             ;= (DA
        DEC    AX
        XCHG   AX,BX
        MOV    [BX],AX
        MOV    AH,10
        JMP  SHORT @@DOS1

        _XT  XT_demit,@DRoP             ;= (DE
        mov  ah,2
@@DOS1: MOV    DX,BX
        JMP  SHORT @@DOS

        _XT  XT_dkey,@pusha             ;= (DK
        mov  ah,7
@@DOS:  int  021h
        MOV    AH,0
        RET

; -------------------
; Peek and Poke
; -------------------

        _XT  XT_count,_COUNT            ;= CSTR

        _xt  XT_CFETCH,_CFETCH          ;= C@

        _xt  XT_FETCH,_FETCH            ;= @    !!!

        _COLON  XT_STR                  ;= STR
        DW XT_FETCHP,XT_SWAP,XT_EXIT

        _xt  XT_Cstorep,_STBP           ;= C!+

        _xt  XT_storep,_STWP            ;= !+

        _XT  XT_FETCHp,_LDWP            ;= @+

; -------------------
; Maths / Logic / registers
; -------------------

        _xt xt_eqz,@nop                 ;= 0=
        CMP    BX,1
        SBB    BX,BX
        rET

        _xt XT_lit,_LIT                 ;= (#

        _XT  XT_TOEVAL,@ninu            ;= >EVAL
        ADD   AX,BX
        NEG   BX
        RET

        _XT XT_2P,_2P                   ;= 2+
        _XT XT_1M,_1M                   ;= 1-

; -------------------
; Stack
; -------------------

        _XT XT_DUP,_DUP                 ;= DUP
        _XT XT_drop,_DROP               ;= DROP
        _xt XT_pop,_pop                 ;= POP
        _xt XT_push,_push               ;= PUSH

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

        _xt XT_litcom,_does0            ;= \#
        dw xt_lit,xt_comma

        _COLON XT_CODECOM               ;= CODE,
        dw XT_HERE,XT_ENTRY,xt_comma,xt_exit

_does0: call _does  ; like ;
        dw xt_STR,xt_comma,xt_perform,xt_exit

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
        _XT XT_exit,_exit               ;= ;;
        _xt XT_0ex,_0ex                 ;= 0;
        _XT XT_DROPX,_DROPX             ;= DROP;
        _XT XT_SKIP,_SKIP               ;= SKIP

; -----------------------
; Dictionary Search
; -----------------------

                                        ;ON INTERPRET
        _XT  XT_FIND,@PUSHA             ;= FIND
        CALL @@FIND
@@2:    INC   AX
        RET
                                        ;ON COMPILE
        _XT XT_findC,@pusha             ;= FINDC
        MOV   AL,'`'
        CALL  XSTRPC
        CALL  @@FIND
        JNZ   @@2
        DEC   PB [BX]
@@FIND: push  si
        mov   SI,[XT_SRCHP+_AT] ; SEARCH POINT
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

        _COLON XT_lbrak                 ;= [`
        DW  XT_LATEST,_TO+XT_SRCHP,_TO+XT_DOSRCH
        DW  XT_FIND,XT_EXIT,XT_EXEC

        _COLON XT_rbrak                 ;= ]
        DW  XT_LAST,_TO+XT_SRCHP,_TO+XT_DOSRCH
        DW  XT_FINDC,XT_EXIT,XT_COMMA

        _COLON XT_TICK                  ;= '
        DW  XT_TOKEN?,XT_FIND,XT_1M,XT_NZ?,XT_EXIT

; -----------------------
; Outer Interpreter
; -----------------------

        _COLON XT_LIKE                  ;= LIKE
        DW XT_TICK,XT_FETCH,XT_EXIT

_DZTO:  CALL _DOES
        DW  XT_CFETCH,XT_TICK,XT_HelpTO
        DW  XT_2P,XT_2P,XT_PERFORM,XT_EXIT

        _XT XT_TO,_DZTO                 ;= TO
        DB  2

        _COLON xt_num                   ;= (NUM
        dw xt_count,XT_TOEVAL,xt_number,XT_Z?,xt_EXIT

        _XT XT_ABORT,_INIT              ;= ABORT

        _bvect  xt_qm,'?'               ;= c?

        _COLON  XT_TOKEN?               ;= TOKEN?
        DW XT_TOKEN
        _COLONP XT_NZ?                  ;= <>0?
        DW  XT_EQZ
        _COLONP XT_Z?                   ;= =0?
        DW  xt_0ex,xt_ERR,XT_qm+_To,XT_ABORT

        _COLON  XT_INITQ                ;= (INIT
        DW XT_ZER,XT_TIB,XT_STOREP
?XEVAL: DW XT_DROPX

        _COLON xt_eval                  ;= (EVAL
        dw xt_TOEVAL,XT_ltb+_TO,Xt_etb+_TO
?int:   dw XT_TOKEN,XT_0BR,?XEVAL
        dw xt_DoSRCH,xt_states,xt_perform,xt_br,?int

; -----------------------
; Outer Interpreter2
; -----------------------

;       include nf5.i2
 ;      include nf5.i3

freemem:

lastw = ppppp

MyCseg  ends
        end  Start

