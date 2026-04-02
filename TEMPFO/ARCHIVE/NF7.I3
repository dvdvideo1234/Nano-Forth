
        __XT _ifm,__mBR                ;= (-BR
        __XT _?SKIP,__?SKDR            ;= ?SKIP

        _bvect  _lp,'['               ;= c[
        _bvect  _rp,']'               ;= c]

        __XT     _2M,__2M              ;= 2-
        __XT     _CALL  ,__CALL        ;= call
        __XT     _FLIP  ,__FLIP        ;= FLIP
        __XT     _MBR   ,__MBR         ;= (mbr
        __XT     _WHI   ,__WHI         ;= hb>b

_does2: call _does  ; like C,
        dw _CFETCH,_COMMAB,_exit

_does3: call _does  ; like ,
        dw _FETCH,_COMMA,_exit

        __XT _CPOP,_DOES2              ;= (POP,
        DW  _POP

        __XT _CDROP,_DOES2             ;= (DROP,
        DW  _DROP

        __XT _BCALL,_DOES2             ;= (CAL,
        DB  232

        _COL _REL                   ;= (REL
        DW  _HERE,_2P,_minus,_COMMA,_EXIT

_DOES4: CALL _DOES-1
        DW  _PLUS,_BCALL,_REL,_EXIT

        __XT _BYE,0                    ;= BYE

        _COL  _numo                 ;= .
        DW _XSPC      ;; !!! ; : . DUP 0< IF '- EMIT NEG THEN .. ;
        dw _mbr,_@@1,_lit,'-',_emit,_neg
_@@1:   _COLONP _nprt                 ;= ..
        DW _LF,_DM,_?SKIP,_nprt,_PDIG,_EXIT

        _COL _ok_do                 ;= DO_OK
        dw _space,_cr,_lit,'!',_emit,_exit

        _COL _id                    ;= ID.
        dw _count,_type,_space,_exit

        _COL _list                  ;= VLIST
        dw _latest,_xdrop
_list   dw _DUP,_LIT,1,_DUMP,_SPACE
        DW _str,_HPRT
        ;DW _1P               !!!
        DW _COUNT,_0EX
        DW _1m,_count,_plus,_br,_list

        _COL  _PRTSTR               ;= (."
        DW _POP,_COUNT,_PTYPE,_PUSH,_EXIT

        _COL  _ADRSTR               ;= ("
        DW _I,_COUNT,_PLUS,_XCHG,_EXIT

        _COL _SKOBA                 ;= .[]
        DW _SPACE,_lP+_to,_EX,_rP+_to,_EXIT

        _COL _Xtype                 ;= ;TYPE
        DW _EX,_DUP,_1H,_minus,_1H,_SKOBA,_TYPE,_EXIT

        _COL _DUMP                  ;= DUMP
        DW  _1H,_0SWAP,_DIV,_EQZ,_EQZ,_minus
        DW  _XDROP,_TIMES,_XTYPE
        _colonP  _DU                  ;= DU
        DW  _CR,_DUP,_HPRT,_twice,_BS,_SPACE
        DW  _TIMES,_COUNT,_PBYTE,_SPACE,_EXIT

        _COL _scom                  ;= >N,
        dw _xdrop,_times,_count,_commaB,_exit

