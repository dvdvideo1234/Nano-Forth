
        _colon xt_times                 ; = TIMES
        dw xt_for,?xtimes    ; for j execute next rdrop drop ;
?times  dw xt_j,xt_execute,xt_next,?times
?xtimes dw xt_rdrop,XT_DROPX

        _XT XT_OF,__OF                  ;= (OF
        _XT XT_ifm,__mBR                ;= (-BR
        _XT XT_FOR,__FOR                ;= (FOR
        _XT XT_NEXT,__NEXT              ;= (NXT
        _XT XT_?SKIP,__?SKDR            ;= ?SKIP
        _XT XT_RDROP,__RDROP            ;= RDROP

        _BCONST XT_1H,16                ;= 1H
        _CONST  XT_1B,256               ;= 1B
        _bvect  xt_lp,'['               ;= c[
        _bvect  xt_rp,']'               ;= c]
        _bvect  xt_BS,8                 ;= bs
        _bvect  xt_CCR,13               ;= cr
        _bvect  xt_LF,10                ;= lf

        _XT     xt_2M,__2M              ;= 2-
        _XT     xT_1P    ,__1P          ;= 1+
        _XT     xT_?BR   ,__?BR         ;= ?br
        _XT     xT_CALL  ,__CALL        ;= call
        _XT     xT_FLIP  ,__FLIP        ;= FLIP
        _XT     xT_MBR   ,__MBR         ;= (mbr
        _XT     xT_STWM  ,__STWM        ;= !-
        _XT     xT_WHI   ,__WHI         ;= hb>b

_does2: call _does  ; like C,
        dw xt_CFETCH,xt_COMMAB,xt_exit

_does3: call _does  ; like ,
        dw XT_FETCH,xt_COMMA,xt_exit

        _XT XT_CPOP,_DOES2              ;= (POP,
        DW  XT_POP

        _XT XT_CDROP,_DOES2             ;= (DROP,
        DW  XT_DROP

        _XT XT_BCALL,_DOES2             ;= (CAL,
        DB  232

        _COLON XT_REL                   ;= (REL
        DW  XT_HERE,XT_2P,XT_sub,XT_COMMA,XT_EXIT

_DOES4: CALL _DOES-1
        DW  XT_PLUS,XT_BCALL,XT_REL,XT_EXIT

        _colon xt_twice
        dw xt_i, xt_push,xt_exit

        _colon xt_execute               ;= EXECUTE
        dw xt_push,xt_exit

        _colon xt_xdrop                 ;= ;DROP
        dw xt_ex,xt_dropx

        _XT XT_BYE,0                    ;= BYE

        _COLON  XT_XSPC                 ;= ;SPC
        DW XT_EX,xt_space,xt_exit

        _COLON XT_P                     ;= keyWait
        DW XT_KEY,XT_DROP,XT_EXIT


        _COLON  XT_DM                   ;= #1
        ; : #1 10 0SWAP U/MOD >DIG SWAP ;
        DW XT_0SWAP,XT_DIV,XT_SWAP,XT_EXIT

        _colon  xt_numo                 ;= .
        DW XT_XSPC      ;; !!! ; : . DUP 0< IF '- EMIT NEG THEN .. ;
        dw xt_mbr,_@@1,xt_lit,'-',xt_emit,xt_neg
_@@1:   _COLONP XT_nprt                 ;= ..
        DW XT_LF,XT_DM,XT_?SKIP,XT_nprt
        _COLONP  XT_PDIG                ;= .DIG
           DW XT_DIG,XT_EMIT,XT_EXIT

        _colon xt_cr                    ;= CR
        dw xt_CCR+_TO,xt_LF+_TO,xt_zer,xt_cntc+_to,xt_exit

        _colon xt_ok_do                 ;= DO_OK
        dw xt_space,xt_cr,xt_lit,'!',xt_emit,xt_exit

        _colon xt_id                    ;= ID.
        dw xt_count,xt_type,xt_space,xt_exit

        _colon xt_list                  ;= VLIST
        dw xt_latest,xt_xdrop
_list   dw XT_DUP,XT_LIT,1,XT_DUMP,XT_SPACE
        DW xt_str,xt_HPRT
        ;DW XT_1P               !!!
        DW xt_COUNT,XT_0EX
        DW xt_1m,xt_count,xt_plus,xt_br,_list

        _COLON   XT_Hprt                ;= H.
           DW XT_XSPC
        _COLONP  XT_PWORD               ;= .W
           DW XT_1B,XT_DM,XT_PBYTE
        _COLONP  XT_PBYTE               ;= .B
           DW XT_1H,XT_DM,XT_PDIG,XT_PDIG,XT_EXIT

        _COLON  XT_PRTSTR               ;= (."
        DW XT_POP,XT_COUNT,XT_PTYPE,XT_PUSH,XT_EXIT

        _COLON  XT_ADRSTR               ;= ("
        DW XT_I,XT_COUNT,XT_PLUS,XT_XCHG,XT_EXIT

        _COLON XT_SKOBA                 ;= .[]
        DW XT_SPACE,XT_lP+_to,XT_EX,XT_rP+_to,XT_EXIT

        _colon xt_Xtype                 ;= ;TYPE
        DW XT_EX,XT_DUP,XT_1H,XT_sub,XT_1H,XT_SKOBA
        _colonP xt_type                 ;= TYPE
        dw xt_xdrop
        _colonP xt_Ptype                ;= PTYPE
        DW xt_times,xt_count
        DW  XT_CTRL_OUT,xt_EMIT,xt_exit

        _colon xt_DUMP                  ;= DUMP
        DW  XT_1H,XT_0SWAP,XT_DIV,XT_EQZ,XT_EQZ,XT_sub
        DW  XT_XDROP,XT_TIMES,XT_XTYPE
        _colonP  xt_DU                  ;= DU
        DW  XT_CR,XT_DUP,XT_HPRT,XT_twice,XT_BS,XT_SPACE
        DW  XT_TIMES,XT_COUNT,XT_PBYTE,XT_SPACE,XT_EXIT

        _colon xt_scom                  ;= >N,
        dw xt_xdrop,xt_times,xt_count,xt_commaB,xt_exit

