# Nano-Forth

### Description

It's a cross-platform forth-based envirionment

### Base features
1. Compile/decompile
2. Truely minmalistic

### Forth language main loop

```asm
INTERPT DW _NUMBER_T_I_B,_FETCH,_TO_IN,_FETCH      ; BEGIN  CR  #TIB @ >IN @
        DW _EQUALS,_ZERO_BRANCH,INTPAR,_CR,_T_I_B  ;   = IF CR TIB           \ IF EMPTY
        DW _LIT,50,_ACCEPT,_NUMBER_T_I_B,_STORE    ;     50 ACCEPT #TIB !
        DW _ZERO,_TO_IN,_STORE,_SPC,_EMIT          ;     0 >IN ! CR  THEN    \ FULL BUF
INTPAR  DW _SPC,_WORD,_FIND,_DUPE                  ;   BL WORD FIND DUP      \ FOUND ?
        DW _ZERO_BRANCH,INTNF,_STATE,_FETCH        ;   IF STATE @            \ COMPILATION ?
        DW _EQUALS,_ZERO_BRANCH,INTEXC             ;      = IF               \ YES
        DW _COMMA,_BRANCH,INTDONE                  ;       ,  ELSE
INTEXC  DW _EXEC,_BRANCH,INTDONE                   ;     EXEC ELSE
INTNF   DW _DUPE,_ROTE,_COUNT,_TO_NUMBER           ;     DUP ROT COUNT >NUM  \ NUMBER
        DW _ZERO_BRANCH,INTSKIP,_STATE,_FETCH      ;     IF STATE @
        DW _ZERO_BRANCH,INTNC,_LAST,_FETCH,_DUPE   ;       IF LAST @ DUP
        DW _FETCH,_LAST,_STORE,_DP,_STORE          ;          @ LAST ! DP !
INTNC   DW _ABORT                                  ;       THEN ABORT  THEN
INTSKIP DW _DROP, _DROP, _STATE, _FETCH            ;     DROP DROP STATE @
        DW _ZERO_BRANCH,INTDONE,_LIT,_LIT,_COMMA   ;     IF LIT LIT , ,
        DW _COMMA                                  ;   THEN  THEN THEN
INTDONE DW _BRANCH,INTERPT                         ; AGAIN
```