


12 LOAD
13 LOAD
14 LOAD
15 LOAD












12 LOAD  { :`S , DOES>`S  AND  STACK`S  DEFINITION }
13 LOAD  { IFS}
14 LOAD  { ; - SES }
15 LOAD  { DEFINITIONS }
16 LOAD  { DO / LOOP / RANGE }
17 LOAD  { STRING COMPILATION }
18 LOAD  { INIT}
21 LOAD  { EDITOR}
{ 45 LOAD  { STATISTICS }
PRUNE



{ :`S , DOES>`S  AND  STACK`S  DEFINITION }
' { =: {`       : TO` 'TO , ;  : AT` 'AT , ; : CODE: HP =, ;
: :` :(SKIP =H :(NEST 2 T NAME> 2+ +! ;
: 0#> D# :(DZ#0 ; : 1#> D# :(DZ#1 ; : 2#> D# :(DZ#2 ;
: DOES>` :CODE 0#> DROP ; ' RELS> =: THEN`   ' <MARK =: BEGIN`

{ DEFINITIONS } : `T =H >, EX ,<` , ;
: VARIABLE 0 : VAR `T :(VAR ; : CREATE VARIABLE UNW ;
: QUAN `T :(CON3 : `Q :(SET2 :(VAR ; : VQUAN `T :(DEF3 `Q ;
: VALUE `T :(CON2 : `S :(SET ; : VECTOR `T :(DEF2 `S ;
: DEFER `T :(DEF ; : CONST `T :(CON ;
: `4ARY 2* : `2ARY 2* : `ARY =H >, EX ,<` CLARY ;
: BARY `ARY :(BARY ; : WARY `2ARY :(WARY ;
: LARY `4ARY :(LARY ;


{ IFS} : AHEAD` :(JUMP MARK> ; : ;GO` :(;GO MARK> ;
: IF` :(IF MARK> ;             : CALL` :(CALL MARK> ;
: (#, @R+ : COMP, , END! ; : `NUM?, NUM? : ,LIT` :(LIT COMP, ;
: FOR` :(FOR MARK>< ;          : NEXT` :(NEXT <RELS> ;
: UNTIL` :(IF <RELS ;           : AGAIN` :(JUMP <RELS ;
: CASE` 0 TO CSTK> ;            : REPEAT` :(JUMP <RELS> ;
: FOR>` :PUSH <MARK ;         : OF` :(OF MARK> ;
: <NEXT` :(NEXT <RELS ;         : -UNTIL` :(-IF <RELS ;
: ;CSTR EX CSTR, ;              : TB-ABRT ;CSTR :(AB ;
: TB" ;CSTR :(" ;              : TB." ;CSTR :(." ;
: ;;` :(RET AT <CSTK ITEMS? AT CSTK> ITEMS? + 0<>; EX ,<` ;
' CALL` =: [`      ' IF` =: WHILE`    : ;CASE` :DROP
BEGIN CSTK> DUP WHILE TO CSTK> THEN` REPEAT     DROP ;
\ CSWAP> `;STK> `;STK> SWAP ;  : <CSWAP `;<STK `;<STK SWAP ;
: ELSE` AHEAD` CSWAP> THEN` ;          ' ELSE` =: ENDOF`

{ ; - SES }

: `TvIS:? T>R @ $497 = ; : `TvTOC>. 2+ ;

: `x??x EX ??# : `(@H, @H- `TvTOC>. ;
: `?? `x??x : `H@:? H 2- @ `TvIS:? HERE ENDH <> AND ;
: :;` `?? TO <CSTK :(;GO <RELS ;
: ;` `H@:? ;;` 0; UNW `(@H, TO <CSTK AGAIN` ;
: ;THEN` ;` THEN` ;   ' ;THEN` =: ]`
: ?;` `?? TO <CSTK UNTIL` ;

: "BSCAN =0, DOES> : B>IN" PUSH XCHG CSTR POP BSCAN 1+ ;
: ,T BL ?, ;



: C:` ,' ;
: DXEP1+ DUP 1+ XEP ; : DXEP2+ DUP 2+ XEP ;
: THRU 1+ OVER- ;DROP LOOPS DXEP1+ LOAD ;
' :TWICE =: TWICE`




























{ STRING COMPILATION } : UNB ;DROP : C@H- ;H : C@- 1-DXEP C@ ;
"BSCAN `Ctbl ,T "^~_ : PK: C: : DOES> SWAP  ;H XEP DXEP TO H 0
 C, PUSH CSTR TO L POP EXECUTE  H J NOT + : C!I J C! ;
: ;L L EX TO L ;                  PK: "UNPACK L ;DROP LOOPS
CSTR DUP 128 AND IF 128 - [ '~ C, ] THEN [ L C, ] DUP TO L
`Ctbl IF '" C, ;THEN BL L = IF '_ TO L ;THEN L BL U< 0; '^ C,
'@ ;L + ; : `SRC CSTR ;L 1- ; : `^ UNB L 0; `SRC
31 AND C, ; : `" UNB L 0; `SRC C, ; : `~ UNB C@H- 128 XOR C, ;
: `_ UNB BL C, ; 0 WARY `tbl >, NOP `" `^ `~ `_ ,< PK: "PACK
 ;DROP BEGIN L  0; `SRC DUP C, `Ctbl `tbl @EXEC AGAIN ; UNW

: @' ' @ ;  ' ((." (,X ."` ,"  ' ((" (,X "` ,"  $194 (,X A"` ,"
@' (DOS  DUP =, (VID $10 C,  =, (KBD $16 C,
: `;HOME EX : HOME D0 : @XY BB>W D0 $200 (VID ;
: PAGE `;HOME  0 24 @XY  25 : CRS  LOOPS CR ;

{ INIT}
 "BSCAN `SPEC? ,T ",!. : TERR. TO STATE vERR ;
0 WARY `STR  >, NOP BS, TERR. ". ,<
0 WARY `STR, >, TB" BS, TB-ABRT TB." ,<    : STR- 1- XEP 1+ ;
: `OK" OVER C@ '" - NOP ?; OVER 1+ C@ '" <> STR- ?; ;;
: `STR@ CSTR `OK" 2- OVER C! SBUF "PACK ;
: STR? DUP NAME> 1- C@ '" = PUSH DUP 1+ C@
                `SPEC? DUP 1- TO XK   0 <> POP AND ;
: `NUM STR? NUM? ?; `STR@ XK `STR @EXEC ; : `.R, RDROP , ;
: `NUM, STR? `NUM?, ?; `STR@ XK `STR, @EXEC ;
: `EXE >NF< NAME> PUSH 2 I+ @ ODD A" DEFINED?" RDROP EXEC ;
: `COM >NF< NAME> PUSH 2 I+ @ ODD `.R, ?; DROP H @I , POP ! ;
: TINIT CALL `NUM `EXE `NUM, `COM THEN OPER! ; { TINIT}



: =, ;, : =H HERE : =: PUSH TT? NIP 0= IF 0 POP TBUF ` ;THEN
 >NF<  NAME> PUSH 2 I+@ ODD IF 2 I+@ 3 - 2 I+! BEGIN I
 WHILE @I J POP ! PUSH REPEAT : 2EXIT POP .EXIT ;THEN RDROP 1
A" ALREADY DEFINED!" ;
: ALGN 1- SWAP 1- OR 1+ ; : ?DUP DUP 0; DUP ;
0 VAR `T_DATA  0 VALUE `T_HND     0 VAR `TOTAL
: TWRITE1 `T_DATA ! `T_DATA SWAP : TWRITE3 DUP `TOTAL +! `T_HND
 Fwrite CR _DX H. _CX . _AX . ;
: ADDZONE ;RNG> : ADDBLK BLOCK 1K TWRITE3 ;
: TSAVE  ESC PRUNE ESC  `TOTAL OFF
         TOKEN? FCREATE TO `T_HND   TD 2+ H OVER- TWRITE3
  2  TD @ " --END--" TFND ??# DROP >NF< SWAP - 1+ TWRITE1
   TD @   `T_DATA @ 1-  TWRITE3               1 0 TWRITE1
`TOTAL @ 1K ALGN `TOTAL @ - ?DUP IF 63 BLOCK SWAP TWRITE3 THEN
   1 9 ADDZONE    35 62 ;RNG> ADDBLK ;

                   0 VALUE ENDH : S0 48 TO SCR 0 TO XY S ;
: @I J @ ; : ` PUSH  PUSH !TD- POP !TD- POP .C@ 1+ ;TD (MPUSH ;
: TWORDS  ;<D> WORDS ; : % 0 ' >NF< ` ;; : %2 0 ' TOKEN? ` ;;
' ' =: 'O  ' =H =: =HO   ' =: =: =:O  ' =, =: =,O
: TT? TOKEN? : TFND TD @ Dfnd ;
0 VALUE FOUND  : `;RESULT TO XK HERE OFF EX HERE @ TO FOUND ;
: `DEF: C: : DOES> `;RESULT ;2DROP ;FND J NAME> 2+ @ XK PUSH ;
`DEF: DEF ODD = : `CNTR 0; J ID. HERE INC ;
`DEF: =USED 2/ = `CNTR ; `DEF: >USED 2/ U< `CNTR ;
' HERE =: H      0 TL !    { PREPARE FOR <H>}
: OBJ! TO H ; : ORG! H - TO HOFS ;  H ORG! { PREPARE FOR <H>}
: UNW ;DROP @H- ;

: HERE! HERE - ALLOT ; : CALL! ;H XEP HERE SWAP HERE!  CALL, ;
: TINIT CALL `NUM `EXE `NUM, `COM THEN OPER! ;


M: C4 USING C4H.COM;    M: PRB USING PROBA.COM;
M: NFC USING NFC.COM;
: SUCSTR SWAP : UCSTR XEP CSTR ;  ' \ =: \`

 0 VALUE SPTRTOP  0 VALUE SPTR : ;SPTR  SPTR EX TO SPTR ;
: EOS! bs TO EOS ; : S> SPTR : SDROP ;SPTR NAME> ;
: C!- 1-DXEP C! ; : ;EOS EOS XCHG 0 TO EOS EXECUTE POP TO EOS ;
: SPTRTOP? SPTRTOP T <>  SPTR SPTRTOP U< 0=  OR  0;
  T DUP TO SPTRTOP TO SPTR TWICE  D0
: >S ;SPTR OVER PUSH (MPUSH XCHG POP C!- ; : >S! CSTR >S ;
: >" OVER C@ 1+ CMOVE ;

22 31 THRU     CREATE TT


\ BLOCK1 OF EDITOR
    : WHAT? 7 EMIT ;
ZDO VALUE 4 TIMES  `PDATA `INS  `SZ  `ALTER
0#> SWAP TO XK CSTR 2DUP XK BSCAN 1+ 2* + + @EXEC ; =: `XK!

 2000 HIPUSH <H>
: -:  ' , C,  XK 2+ DUP TO XK       { BYTES FOR MOVE UP 1 }
         HERE OVER - DUP PUSH       { START ADDRESS    }
         DUP 1+ ROT                 { PREPARE FOR MOVE }
         CMOVE>  HERE C@ POP C!   ; { FIX CODE  }
: SWITCH: CREATE HERE 73 1 TO XK 0 -: (LIT  `XK!  TOBE ;
: ;SWITCH  73 - A" BAD KEYS" XK 2/ 1- SWAP C! ;
 <H>



\ BLOCK2 OF EDITOR
: `?XY 1L U/MOD 6 3 : V+ ROT + U+ ;
: `POSXY XY `?XY @XY   ;        : `_INS  `INS 0= TO `INS
: `.INS  75 1 @XY `INS IF ." INS" ;THEN ." OVT" ;
: `;LRUD  XY EX >XY ; : `ERR 73 1 @XY ; ' ETIB =: `EOS^
: `;LPOS  XY : `;PDATA+ EX `PDATA + ;   : `POS^ `;LPOS ;;
: `RELOAD SCR BLOCK DUP TO `PDATA 1K + TO ETIB  SPTRTOP? ;
: `REDRAW  `ERR SPACE  `.INS HOME CR  `PDATA .BLOCK ;
: `L_DN 1L : `XY+ `;LRUD + ;    : `L_UP 1L : `XY- NEG `XY+ ;
: `L_END `;LRUD : `/L  1L 1- OR ;  : `EOL `;LPOS `/L 1+ ;
: `ERR.EXIT `ERR '? EMIT : .EXIT2 RDROP : .EXIT DROP EXIT ;
: `1L<?; 1L : `>SZ?; TO `SZ : `SZ<?; 1K XY - `SZ U< 0?SKIP
 `ERR.EXIT  : `;RDRC EX  : `RDRC  `REDRAW UPDATE ;
: `WIPE `;RDRC 1K LOOPS `EOS^ J - 1- : `IWIPE   DUP C@ BL U<
         IF BL SWAP C! ;THEN DROP; ,<

\ BLOCK3 OF EDITOR
: `<_|   `L_DN  : `L_BEG `;LRUD L/ ;    : `->  1 `XY+ ;
: `<-  1 `XY- ;  : `TAB> bs : `SZTB> `-> :; 1- `;LRUD OR ;
: `<TAB bs : `<SZTB `<- NEG : `TAB& `;LRUD AND ; { PREVIOUS}
: `APOS  0 `TAB& ; : `LINE/ `;LPOS  L/ ;  : `/LINE `;LPOS `/L ;
: `LDRAW `POSXY `LINE/ XY 1L U/ 1+ cr EMIT .LINE DROP ;
: `RESET -BUF : `LOADRAW `RELOAD `REDRAW ; { !!!!!!! }
: `N  1 : `LB SCR + 0 MAX TO SCR `LOADRAW ;  : `B -1 `LB ;
: `ALT SCR `ALTER TO SCR TO `ALTER `LOADRAW ;
: `ADV 1K XY - TO LTIB BL PARSE TO `SZ DROP XY? >XY XY 0; `<- ;
: `TEST BL `POS^ C@ U< ;  : `BACK  BEGIN `<- XY 0; `TEST UNTIL
         BEGIN `<- XY 0; `TEST 0= UNTIL `-> ;
: `;INSPOS EX PUSH `POS^ I `SZ - DUP `SZ BLANK POP ONPLACE ;
: `;DELPOS `POS^ DUP `SZ + OVER `SZ BLANK EX ONPLACE ;
: `AW `ADV : `PREP { ARE} `BACK  : `SKIP `ADV `-> ;

\ BLOCK4 OF EDITOR
: `DELL `1L<?; : `DO-DEL `;DELPOS `EOS^ ; : `INSL `1L<?;
: `DO-INS `;INSPOS `EOS^ ; : `altS 1L 1+ `>SZ?; 1L TO `SZ `POS^
`<_| `DO-INS `POS^ 2DUP - NUP - ONPLACE ; : `COPY `1L<?; RDROP
: `DO-COPY `POS^ `SZ DUP `XY+ >S ; : `CUT `1L<?; : `DO-CUT
`DO-COPY  `SZ `XY- `DO-DEL ;
: `BKCW `AW `BACK `BACK : `CUTW `AW `SZ 0; `SZ 1+ TO `SZ
 `BACK `;RDRC `DO-CUT `PREP ; : `MOVE `CUTW `SZ 0; `SKIP :;
: `PASTE SPTR C@ DUP TO `SZ 0; `SZ<?; : `DO-PASTE `DO-INS S> 1+
 `POS^ `SZ CMOVE ; : `;LDRU 1 TO `SZ EX : `LDRU `LDRAW UPDATE ;
: `INSC `;LDRU CALL `POS^ C! ;THEN `INS 0; `;INSPOS `EOL ;
: `BS `<- : `DELC `;LDRU `;DELPOS `EOL ; : `ESQ/E /BUFS
: `X-POS 71 18 @XY EOS! ; : `Q/ED FLUSH `X-POS ;
: `SCR; `APOS `<- : `PREPARE `L_END `PREP ;
 <H>  : C^ TOKEN? 1+ C@ 31 AND ;

\ BLOCK5 OF EDITOR \ KEY CONSTANTS :

1 79 +DO CONST 6 ..TIMES  kEND kDOWN kPGDN kINS kDEL ksF1
1 59 +DO CONST 10 ..TIMES
                  kF1 kF2 kF3 kF4 kF5 kF6 kF7 kF8 kF9 kF10
1 115 +DO CONST 5 ..TIMES
     kcLEFT  kcRIGHT  kcEND  kcPGDN kcHOME
#DO CONST 18 TIMES
     113 kaF10  132 kcPGUP
     71 kHOME  72 kUP  73 kPGUP  75 kLEFT  77 kRIGHT 27 kESQ
     9 kTAB  104 kaF1  93 ksF10  94 kCF1  103 kcF10  15 ksTAB
     32 kaD  31 kaS  30 kaA  17 kaW




<H> \ BLOCK6 OF EDITOR
SWITCH: `EF WHAT?   kaA -: `ALT    kLEFT -: `<-    kUP -: `L_UP
 kHOME -: `L_BEG   kEND -: `L_END  kPGUP -: `B   kPGDN -: `N
 kDOWN -: `L_DN  kRIGHT -: `->     kINS  -: `_INS kDEL -: `DELC
 kaW   -: `WIPE kcRIGHT -: `ADV  kcLEFT -: `BACK kcEND -: `SCR;
 ksTAB -: `<TAB  kcHOME -: `APOS   kaS -: `altS  kaD -: `DELL
;SWITCH        : `ONEC XK BL U<  IF WHAT? ;THEN XK `INSC `-> ;
SWITCH: `EK `ONEC C^ J -: `<- C^ K -: `-> C^ X -: `CUT 127
-: `BKCW bs -: `BS C^ D -: `DELC cr -: `<_| C^ G -: `CUTW C^ Z
-: `PREPARE C^ N -: `N C^ B -: `B C^ R -: `RESET C^ I -: `TAB>
 C^ C -: `COPY C^ V -: `PASTE C^ Q -: `ESQ/E C^ F -: `MOVE
 C^ A -: `ADV  kESQ -: `Q/ED  C^ S -: `INSL  0 -: `EF ;SWITCH
: `@KEY `POSXY (BK W>BB DUP IF SWAP ;THEN DROP ;
: EDIT TO SCR : PE PAGE : E  D0 ;0TI `LOADRAW ;EOS  BEGIN `@KEY
`EK EOS  UNTIL ;  HIDROP

0#> PUSH XCHG CSTR POP SCAN 1+ 0;  ;SPC ;[] DUP ". NAME> ;
=, `?STR 3 C, >, ((A"  ((" ((." ,< : `STR EX DUP 2- @ `?STR ;
0 VALUE `WW 0 VECTOR `DBG : `ID! 0 TO `DBG ; : `C>N `DBG C>N? ;

: `;WW `WW EX TO `WW ; : `:ID. DUP R>T `C>N
 DUP NOP ?; XEP OVER CALL ." : " ID. ;THEN : ``CR- CR R>T H. ;
: `CR-H `:ID.    ``CR- ?; ; : `CR- `:ID. IF ;THEN DROP ;
: .HL `WW H. ; : T?ID! (LIT ;<D> TO `DBG ;

: SEE ' `ID! : @SEE T>R TO `WW : SL      bs LOOPS
: WW `;WW `CR-H @+ OVER H. : `W0 `STR XEP `DBG ?ID. ; : HACK '
 `ID! : @HACK T>R TO `WW : HL CR bs LOOPS `;WW `CR- @+ `W0 ;
: -HL `WW 23 - @HACK ;



: PRUNE  [ TO T DUP STR + OFF DUP INC STR >DICT ] EDICT XEP
 H DUP OFF ;DROP ;FND J N>C SWAP U< 0;  J 1+ C@ '` - 0;
 J D>NAME OVER- H S+! DROP ;
0 VALUE FOUND
: `DEF: C: : DOES> [ H @ DUP TO FOUND CR . CR ]
 TO XK H OFF ;2DROP ;FND J NAME> 2+ @ XK PUSH ;
`DEF: DEF ODD = : `CNTR 0; J ID. H INC ;
`DEF: =USED 2/ = `CNTR ;
`DEF: >USED 2/ U< `CNTR ;







: .ALL ;2DROP ;FND J (TYP : >PRINT = : >PRT? 0; : JID J ID. ;
: `? J C@ - DUP 0< 0; RDROP : `SRCH; 2DROP 0 EXIT ; : IN-STR>
SUCSTR : SRCH> PUSH `? FOR> DUP J CSTR -TEXT EXIT2 ?; 1+ <NEXT
DUP `SRCH; ; : <IN-STR SUCSTR : <SRCH PUSH `? DU+ FOR> DUP J
CSTR -TEXT EXIT2 ?; 1- <NEXT DUP `SRCH; ;  \ : `H ." `$" H. ;
: `6N  PUSH PUSH PUSH  CALL  POP POP POP : `N3 THEN SPACE 3
 LOOPS ROT DUP H. ; : /DBG KEY 17 = A" /DBG" ;
: `PREFETCH  TOKEN? >LT< TO LTIB FOUND? DROP H. ;
: DBG  CR POP J H. PUSH J H. I H. `6N I @ ?ID. /DBG ;;
: [D]` CR POP J H. PUSH J H. I H. `N3 HERE H. TD @ H. `PREFETCH
  SPACE >NF< ID. TD @ ID. HERE 2- @ ?ID. /DBG ; : .CODE ;2DROP
  ;FND DROP J N>C @+ >PRINT ; : .WORDS ;2DROP ;FND DUP >PRINT ;
: .NAMES ;2DROP ;FND J IN-STR> >PRT? ;
: HIDE -FIND ??# 1+ '` : CSWAP! SWAP C! ;
: HD-TEST -FIND IF ID. ; THEN DROP ;

CREATE `SEARCHBUF 80 ALLOT    63 VALUE ENDBLK  \  ABRAKADABRA
: `BLK>LINES ENDBLK 1H U* ; : S0! 0 TO SCR  0 TO XY ; \
: VLINE 1H U/MOD TO SCR 1L U* ;
: `VMEM VLINE 1L 1- OR  DUP TO XY  : `AT-SCR SCR BLOCK + ;
: SRCH XY `AT-SCR 1K XY - `SEARCHBUF SRCH> DUP  TO XY 0;
  XY 0 `AT-SCR - `SEARCHBUF C@ + >XY E ; >, BEGIN SCR 1+ TO SCR
: `BLOCKSRCH  SCR ENDBLK U< 0;  SRCH XY UNTIL ;
: S BL : `BLOCKSEARCH  WORD C@ IF   TBUF `SEARCHBUF >" THEN
  `SEARCHBUF C@ 0; `BLOCKSRCH ;
: S" '"  `BLOCKSEARCH ; : ?S TOKEN? 1+ C@ `BLOCKSEARCH ;
: S?EL `BLK>LINES LOOPS J `VMEM  C@ BL - 0; E ;
: cr>EL FLUSH :; S?EL `BLK>LINES LOOPS cr J `VMEM C! UPDATE ;
: bl>EL FLUSH :; `BLK>LINES LOOPS BL J `VMEM C! UPDATE ;
: (LD. '# EMIT BLK . ;  ' (LD. TO vLOAD
: .( ') PARSE TYPE ;

                  : S0 48 TO SCR 0 TO XY S ;
: ` PUSH  PUSH !TD- POP !TD- POP .C@ 1+ ;TD (MPUSH ;
: TWORDS  ;<D> WORDS ; : % 0 ' >NF< ` ;; : %2 0 ' TOKEN? ` ;;
\ ' ' =: 'O  ' =H =: =HO   ' =: =: =:O  ' =, =: =,O
: TT? TOKEN? : TFND TD @ Dfnd ;
: OBJ! TO H ; : ORG! H - TO HOFS ;  H ORG! { PREPARE FOR <H>}
: UNW ;DROP @H- ;









: HERE! HERE - ALLOT ;
: CALL! ;HERE XEP HERE SWAP HERE!  CALL, ;














: =, ;, : =H HERE : =: PUSH TT? NIP 0= IF 0 POP TBUF ` ;THEN
 >NF<  NAME> PUSH 2 I+@ ODD IF 2 I+@ 3 - 2 I+! BEGIN I
 WHILE @I J POP ! PUSH REPEAT : 2EXIT POP .EXIT ;THEN RDROP 1
A" ALREADY DEFINED!" ;
: ALGN 1- SWAP 1- OR 1+ ; : ?DUP DUP 0; DUP ;
0 VAR `T_DATA  0 VALUE `T_HND     0 VAR `TOTAL
: TWRITE1 `T_DATA ! `T_DATA SWAP : TWRITE3 DUP `TOTAL +! `T_HND
 Fwrite CR _DX H. _CX . _AX . ;
: ADDZONE ;RNG> : ADDBLK BLOCK 1K TWRITE3 ;
: TSAVE  ESC PRUNE ESC  `TOTAL OFF TOKEN? FOPEN
            {  FCREATE} TO `T_HND   TD 2+ H OVER- TWRITE3
  2  TD @ " --END--" TFND ??# DROP >NF< SWAP - 1+ TWRITE1
   TD @   `T_DATA @ 1-  TWRITE3               1 0 TWRITE1 ; {
`TOTAL @ 1K ALGN `TOTAL @ - ?DUP IF 63 BLOCK SWAP TWRITE3 THEN
   1 9 ADDZONE    35 62 ;RNG> ADDBLK ; }

{ PROBA.COM }
FORGET TT CREATE TT  32 LOAD      37 43 THRU

: STOP LIT TO ESC @  LIT C: ; - 0; MARK@ HIDROP INITO ;
: START STOP : EGG PAGE 18000 HIPUSH   TL  OFF 36 LOAD MARK!
 FX C: NOP TO ESC <H> TINIT TARGET,! 45 62 THRU ;; ' : =:O :O
: ' ;?# TT? ; : 'TO ' 2+ ; : META ' 'TO : T! T>R ! ;
: THACK ' T?ID! @HACK ; : TSEE ' T?ID! @SEE ;
: T: `(SKIP  =H `(NEST TWICE DICT : USED+ NAME> 2+ INC ;
: =! 0 =: TD @ USED+ ; : TTO 'TO , ;
: : ZCSTK =H >, `(NEST ;;      PRUNE





% DEF   % =USED % >USED % ESC   % DBG   % STOP
% HACK  % @HACK % HL    % SEE   % @SEE  % START
% SL    % {`    % \`
%2 [D]` [D]`    %2 ESC ESQ
%2 TTHEN THEN`  %2 T;GO ;GO`    %2 TIF IF`      %2 TCALL CALL`
%2 TFOR FOR`    %2 TNEXT NEXT`  %2 TCASE CASE`  %2 TFOR> FOR>`
%2 TOF OF`      %2 T;; ;;`      %2 T:; :;`      %2 T: :`
%2 T; ;`        %2 T?; ?;`      %2 TIF WHILE`
%2 T;THEN ;THEN`        %2 T;CASE ;CASE`       %2 TAHEAD AHEAD`
%2 T<NEXT <NEXT`        %2 TREPEAT REPEAT`     %2 TAGAIN AGAIN`
%2 TUNTIL UNTIL`        %2 TBEGIN BEGIN`       %2 ]` ]`
%2 TTWICE TWICE`        %2 TTO TO`      %2 TD0 D0`
%2 T-IF -IF`            %2 TELSE ELSE`  %2 TELSE ENDOF`
%2 TDOES> DOES>`        %2 CSWAP>` CSWAP>`     %2 [` [`
%2 HIDE HIDE

































































































































$100 ORG!  0 BLOCK H 1K CMOVE 1K 8 - ALLOT  1 =: --END--
$102 =: OPER[]  $10C =: EMIT    $110 =: SOURCE  $114 =: ACCEPT
$118 =: vOK.    $11C =: vERR    $120 =: TBL     $124 =: TIB
$128 =: TBUF    $12C =: 0       $12E =: BYE     $130 =: BL
$134 =: vINIT   $13A =: H       $140 =: ETIB    $146 =: LTIB
$14C =: T       $152 =: CNTC    $158 =: STATE   $194 =: ((A"
$1A8 =: ;DROP   $1AC =: DROP;   $1C4 =: >DICT   $1D7 =: @R+
$1DD =: (?S     $1E5 =: XCHG    $1EA =: DUP     $1F2 =: (LIT
$1F8 =: @       $1FD =: ,<`     $1FF =: 3+      $201 =: SWAP
$203 =: DROP    $205 =: OVER    $207 =: -       $209 =: +
$20B =: STR     $212 =: .C@     $215 =: C@      $219 =: CSTR
$241 =: J       $245 =: (NEXT   $247 =: RDROP   $249 =: (JUMP
$251 =: EX      $253 =: POP     $255 =: NIP;    $257 =: ;,
$259 =: ,       $261 =: NUM?,   $269 =: NUM?    $273 =: ;H
$299 =: TOKN?   $29D =: WORD    $29F =: PARSE   $2BB =: ??#

$36D =: (MPUSH $37A =: (S! $3A9 =: (FND $3E2 =: ! $424 =: C!+
$42A =: !+ $444 =: PUSH $47F =: EXECUTE $483 =: EXEC $487 =:
@EXEC $48B =: >, $491 =: (DZ#0 $490 =: (DZ#1 $48F =: (DZ#2
$4B1 =: (FOR    $4B8 =: 0?SKIP  $4C8 =: (IF     $4EF =: 0=
$4E2 =, 2+      $3FE =, AND     $4EB =, NOT     $4EA =, NEG
$401 =, XOR HERE $4B4B , $F0EB , DUP =, 2-       1 + =, 1-
$1CE =, U< $DF2B , $E4EB ,   HERE 2+ =, 0< $E3D1 , $DEEB ,
$462 =, 2DROP   $461 =, 2DROP;  $4E3 =, 1+      $3EC =, ROT
 #DO =: 16 TIMES        $40C (CON   $40B (CON2  $40A (CON3
$40E (VAR   $41B (SET   $41A (SET2  $470 (DEF   $24F (;
$46F (DEF2  $46E (DEF3  $497 (:     $24B (SKIP  $23B (LIT,
$4AB (WARY  $4AD (BARY  $4A9 (LARY : ;SPC EX : SPACE BL EMIT ;
#DO CONST 17 TIMES 64 1L 1024 1K 16 1H -1 -1 256 1B $8000 SGN 1
1 $7C NPAD $E000 FIRST 13 cr 10 lf 8 bs $FD00 SBUF 2 2 255  1B&
0 >NF< 9 BOOT : ;+ EX + ; : ;2DROP EX 2DROP; ,< $261 =: N>#,

: -ROT ROT ROT ; 0 QUAN Fbuf  ZDO VECTOR 3 TIMES vLOAD v=: `DO
ZDO VALUE 20 TIMES _AX _BX _CX _DX _FR EOS SCRH `USE `PREV BLK
SCR XY XK L HOFS >LT< >CF< HDICT ENDH `REGA   HERE 2- =: `REG
@' DUP =, +2/ ,"^CZ~^K~S~Q~[~C~"   : I J ; : = XOR 0= ;
@' DUP =, +*  ,"v~B~^At^D^C^^" ' `REG , ,"Q~[~Q~Z~C~"
@' DUP =, -/  ,"Q~b~Q~S~^K~^N" ' `REG , ,";Y~r^C+Y~BC~"
@' STR =, (BK ,"1[~^S~M~^V^H@~t^B0d~^S~C~"  ' (BK VQUAN KEY
: ..TIMES ;DROP : .TIMES ;DROP : TIMES PUSH XCHG : LOOPS FOR J
EXECUTE NEXT : EXIT RDROP ; $44B =, ?BL. ,"^@~{~_s^B3~.C~" :
ID. ;SPC : ". CSTR : TYPE ;DROP : ?TYPE LOOPS CSTR ?BL. EMIT ;
$3B6 CALL! ,"^Cy~/~/~C~"  @' (DE =, (BE ,"^V~1[~4~^NM~^P^V~C~"
$3C4 CALL! ,"^K~5^J~^W2v~w~R~^CW~^I~^V" 'TO >NF< ,
 ,":~^B^@^AU^BAC~"       @' (S! =, (MOVM $57 C, $F3 C, $A4 C,
 ' (S! 11 + $E9 ,R     HERE 2+ =, (IO  ,"^H~^^" HERE 12 + ,
 ,"V^T~[Y"_^T~^W~^R~WM~^P"_^W~^T~RQSW^\~^T~"  @' 2DROP; $E9 ,R

: 2-DXEP 1- : 1-DXEP 1- : DXEP DUP : XEP XCHG EXECUTE POP ;
: TUCK DUP XEP SWAP ; : NUP XEP DUP ; : =" '" WORD : >ZSTR CSTR
SBUF : S! (S! SWAP : OFF 0 : SWAP! SWAP ! ; : OR OVER NOT AND
XOR ; : ODD 1 AND ; : ALIGNED ;H : ALIGN 1- SWAP 1- OR 1+ ; :
IO? _FR ODD !":IO?" ; 0#> C@ (IO TO _FR TO _AX TO _BX TO _CX TO
_DX ; =, (DOS $21 C, : A! TO `REGA ; : A@ `REGA ; : (CALL @R+
PUSH ; : 2DUP OVER OVER ; : U/ ;DROP : (A/MOD A! : (Z/MOD 0 :
(/MOD TWICE TWICE -/ -/ -/ -/ ; : UMOD ;DROP : U/MOD (A/MOD
SWAP ; : 9>? 9 OVER U< 7 AND ; : ALPHA 9>? + '0 + ; : . -IF '-
EMIT NEG THEN : U. ;SPC : ` lf U/MOD 0?SKIP ,< ' ` , >, : DIG.
ALPHA EMIT ; : 1B* 1B : U* ;DROP : UM* A! 0 TWICE TWICE +* +*
+* +* ; : BB>W 1B* SWAP ;+ : W>B 1B& AND ; : W>BB 1B U/MOD ; :
H. W>BB CALL : B. ;SPC THEN 1H U/MOD TWICE DIG. ; : SPACES
LOOPS SPACE ; : 0SWAP 0 SWAP ; : LB10 0SWAP : `LB lf U/ 0?SKIP
,< ' `LB , >, 1+ ; : .UR OVER LB10 - SPACES ` ;

: U- XEP - ; : R>S 1+ : OVER- OVER - ; : WITHIN OVER- U- U< ;
: NAME> CSTR + ; : D>NAME DUP : >NAME NAME> 2+ 2+ ; 0#> @ (DOS
; DUP =, Fseek $4200 , DUP =, Fread $3F00 ,  =, Fwrite $4000 ,
0#> @ D0 ROT (DOS ; DUP =, Fopen $3D02 , =, Fcreate $3C00 ,
0#> @ PUSH D0 ROT POP (DOS ; =, Fclose $3E00 ,
HERE >, NAME> !+  OFF  TBUF D>NAME OVER- ,< DUP HERE! T>R $28B
T>R 12 CMOVE : ;File >ZSTR 1+ EX IO? _AX ; : FOPEN ;File
Fopen ; 4 DUP DUP CONST `NBUFS BARY `FBUFS WARY `BUFS : `RW 1K
UM* SCRH Fseek IO? 1K SCRH EX IO? ; : NOP ; : WBLK `RW Fwrite
; : RBLK `RW Fread ; : C! C!+ DROP ; : `1 J (SKIP ,< =H `2 >,
POP NOT RDROP POP + NIP; ,< : `@BUF `PREV 1K U* FIRST + ; :
 ?BUF PUSH 0 `BUFS `NBUFS POP : SCAN OVER PUSH PUSH FOR STR J
XOR (IF `2 NEXT `1 ; : BSCAN W>B OVER PUSH PUSH FOR CSTR J XOR
(IF `2 NEXT `1 ; 0#> C@ `PREV `FBUFS C! ; DUP =, DISCARD 0 C,
=, UPDATE -1 C, : -BUF DISCARD -1 : `!BUF `PREV `BUFS ! ;

: CMOVE SWAP : MOVM ;2DROP (MOVM ; : >HERE H : M! NUP !+ MOVM ;
0#> C@ : FILL -ROT ;2DROP DUP PUSH EXIT ?; TUCK C!+ POP 1-
SWAP (MOVM ; DUP =, ERASE 0 C, DUP =, BLANK BL C, =, ONES -1 C,
   : 0<; 0< : 0<>; NOP ?; EXIT ; : 0>=; 0< : 0; EXIT ?; ;
: `+BUF `USE 1+ `NBUFS 1- AND DUP TO `USE ; : !BUFS `NBUFS
LOOPS `+BUF TO `PREV : `?SAVE `PREV `FBUFS C@ 0; `@BUF `PREV
`BUFS @  WBLK DISCARD ; : FLUSH !BUFS : /BUFS `NBUFS LOOPS
`+BUF TO `PREV : `EMPTY-BUF -BUF : `/BUF `@BUF 1K ERASE ;
: ;B_TI 1K OVER : ;TI BLK XCHG LTIB PUSH ETIB PUSH PUSH CALL
 EX POP POP POP THEN TO BLK TO LTIB TO ETIB : /BLK BLK 0;
0 TO ETIB ; : ;0TI 0 ;TI ; : EVLP (JUMP ,< $182 , : `;ABLK /BLK
0 TO _FR XCHG PUSH J  ?BUF EX RDROP `@BUF IO? ; : BUFFER `;ABLK
-IF  ?BUF -IF DROP `+BUF THEN THEN TO `PREV `?SAVE `/BUF J
`!BUF ; : BLOCK `;ABLK -IF DROP J BUFFER J  RBLK ;THEN TO `PREV
; : CMOVE> SWAP OVER + (MPUSH : .; DROP; ,<

: ZST DUP 2+ @ SWAP! ; : UNW ;DROP : @H- ;H : @- 2-DXEP @ ; :
`SRC ETIB BLK 0; DUP 0<>; DROP BLK BLOCK 1K + DUP TO ETIB ; :
+LOAD BLK + : LOAD DUP .; ?; ;B_TI vLOAD EVLP ; META `SRC
SOURCE : XY? 1K LTIB - ; : `-USE SCRH 1+ 0; SCRH Fclose : `/SCR
-1 TO SCRH ; : USE/ `/SCR /BUFS ; : USING TOKN? : USED FLUSH
`-USE FOPEN TO SCRH ; : ((." (?S ". ; : ((" (?S ; : ;CR EX : CR
cr EMIT lf EMIT 0 TO CNTC ; : (OK ."_Ok" CR .">" ; : (ERR CR
TBUF ID. STATE ID. CR (LIT (BK TO KEY BLK 0; BLK TO SCR 0 TO
BLK XY? : >XY 1K 1- AND TO XY ; META (OK vOK. META (ERR vERR
: (OF OVER XOR @R+ SWAP IF XCHG  (SKIP THEN DROP DROP ;
: (AC  OVER + PUSH DUP BEGIN KEY CASE cr OF DUP XCHG DROP ENDOF
     bs OF  2DUP - IF 1- bs EMIT SPACE bs EMIT THEN  ENDOF
     DUP BL 1B WITHIN  IF DUP EMIT SWAP C!+ DUP THEN
  ;CASE DUP I =  UNTIL RDROP SPACE OVER- ; : TOP @ @- DROP; ,<
' (BK 'TO KEY 4 + T!     META (AC ACCEPT

: T>R HOFS - ; : HERE H : R>T HOFS + ; : C, ;H C!+ ; : HP HERE
2+ ;              : DU+ DUP : U+ XEP + ;
: LATEST T : N>C NAME> @ ; : ;code POP : TOBE LATEST ! ;
: D# >, EX @H- HERE SWAP : CALL, $E8 : ,R C, HP - , ;
: " HERE : ," '" : ?, WORD : CSTR, CSTR : STR, ;H (S! DROP; ,<
$441 =, ;?# >, ??# ; : TOKEN? LTIB TO >LT< TOKN? ; : =0, 0 : =,
;, : =H HERE : =: v=: ; : ,X: $2DF : `X =, , : ,' ;, : ' ;?# :
T? TOKEN? : FND T : FND2 H SWAP (FND ; : M: '; : ?M: 0 =, ?,
DOES> : SEVAL CSTR : MEVAL DU+ ;0TI EVLP ; : (M: (?S SEVAL ; :
 'TO ' 2+ ; : 'AT 'TO 2+ ; : (,X $2DA `X ; $281 ' v=: 4 + T>R !
: ;LTIB LTIB EX TO LTIB ; : \ ;LTIB 1- : L/ 1L NEG AND ;
: { '} PARSE 2DROP ; : BS, CSTR : S, ;DROP LOOPS CSTR C, ;
: (;GO @R+ XCHG PUSH ; : (GO @R+ XCHG DROP ;
: ;MAX 2DUP EX IF  XEP THEN DROP ; : UMAX ;MAX U< ;
: UMIN ;MAX : U>= U< 0= ; : MAX ;MAX : < - 0< ;  : <> = 0= ;

: CLARY H OVER ERASE : ALLOT ;H + ; : META ' : TO! 'TO ! ; : TO
'TO EXEC ; : AT 'AT EXEC ; : TO@ 'TO @ ; : >NUM TOKEN? NUM? ; :
2* DUP + ; : `AT@ ' TO `DO POP ; : ZDO `AT@ 0 `DO ; : 'DO `AT@
' `DO ; : #DO `AT@ >NUM `DO ; : DO `AT@ `DO ; : +DO `AT@ DUP
`DO : OVER+ OVER + ; : @+ PUSH @R+ POP ; : 2*I+ 2* : I+ J + ; :
2*I- 2* : I- J - ; : C@I J C@ ; : `(: =H CALL EX @EXEC ; : `MKR
=0, , EX ,' ; : 2MKR `MKR , DOES> `(: : `W, THEN STR , ; : 1MKR
`MKR DOES> `(: ; : 3MKR `MKR , , DOES> `(: `W, `W, ; : STK,
SWAP DUP , , , ; : (TYP N>C @ ; : !- 2-DXEP ! ; : @BNDS? @+ @ :
BOUNDS? WITHIN 0= !"BOUNDS!" ; : ;STK @BNDS? : ;@! @+ XCHG
EXECUTE POP !- DROP; ,< : INC ;@! 1+ ; : S+! XEP TUCK J STR +
SWAP CMOVE J : +! ;@! + ; : U16? 1H : UN? U/MOD SWAP 0; 1+ ;
: EDICT T (SKIP BEGIN >NAME .C@ 0= UNTIL 1+ ; : ITEMS@ DUP 2+ @
SWAP : ITEMS? @+ @ - : 2/ 0 : AVG +2/ : NIP NIP; ,<
: @I J @ ; : !I J ! ;

: CORA DUP C@ 1+ : -TEXT FOR PUSH CSTR XCHG CSTR POP = IF
 CSWAP> NEXT -1 PUSH THEN 2DROP POP 1+ ; : ;FND T AHEAD
: ;FND2 BEGIN >NAME THEN PUSH C@I WHILE DUP J EXECUTE POP
  REPEAT 0 : EXIT2 RDROP EXIT ;
: FROM ' : C>N? ;FND J N>C - : `C 0<>; POP 2DROP POP DUP EXIT ;
: -FIND TOKEN? : -FND  ;FND J CORA `C ;
                           : FORGET ' TO H >NF< >NAME TO T ;
0 VALUE `ROWS   : `ROWS! bs TO `ROWS ; : `EOL? C@ CNTC + ,< 80
5 - >, #, U< 0<>; : `NEWLINE ;CR `ROWS 1- DUP TO `ROWS 0<>; (BK
27 = `ROWS! ?; RDROP POP EXIT2 ; : WORDS CR ;DROP `ROWS! ;FND
DROP J `EOL? J N>C H. J ". CNTC 65 U< `NEWLINE ?; 13 : ?ALIGN
         CNTC { : ALI-N} OVER UMOD - SPACES ;
: ;[] '[ EMIT EX '] EMIT ; : `TYPE EX SPACE 1H - 1H ;[] ?TYPE ;
: DUMP' ' DROP >NF< SWAP : DUMP U16? ;DROP LOOPS
: DU CR DUP H. SPACE `TYPE 1H LOOPS CSTR B. ;

HERE : `INJECT >DICT USE/ "PROBA.COM" USED
 BOOT LOAD 0 TO LTIB ;  'TO DROP; 4 + T!
: ONPLACE ;GO DXEP TWICE NUP THEN ;2DROP BEGIN 1- 2DUP U< 0;
     PUSH PUSH  J C@  I C@  J C!    POP  C!+ POP  AGAIN ,<
: [ID] ;SPC ;[] ". ; : `H ."`$" H. ;
: `CN 2- C>N?  : `N  EXIT ?; POP ID.   ID. EXIT ;
: `TO. `CN ,< ,T TO   : `AT. `CN ,< ,T AT
: ?ID.   C>N? 0= ID. ?; `TO. `AT. 2+ 2+ `H ;
: LIST DUP TO SCR BLOCK : .BLOCK ;DROP ."SCR#_" SCR . CR 1H
LOOPS CR 1H  J - : .LINE 4 .UR SPACE 1L ;[] ?TYPE ;
             : EXI?T (;GO TO 0<>; : EXIST? T? SWAP TO >CF< ;
: SAME? TBUF EXIST? 0; TBUF [ID] : ?BLK. BLK 0; : BLK. BLK . ;
' SAME? VECTOR vTOK?     ' vTOK? $289 T!
: !R+ XCHG POP POP !+ PUSH PUSH ; VARIABLE @HD Z, Z, $227 =: `-


















: D! !+ ! ; : D@ 2+ @+ 2- : 2-@ 2- @ ; 0#> C@ HDICT + ; DUP =,
 TL 2 C, DUP =, TH 4 C, =, TD 6 C, : ;TD TD @ EX TD ! ; : `TRG
- DUP 0<>; : ;<D> CALL EX : <D> THEN T TD @ TO T TD ! ; : FX
@R+ @R+ ! ; : ?SKIP DUP IF @R+ THEN DROP ; : !TD- ;TD !- ; :
`EG T EDICT OVER- >HERE EX H STR HDICT ?SKIP FIRST (MPUSH TO T
; : HIPUSH `EG PUSH HDICT DUP ?SKIP FIRST 10 I+ - DUP TO HDICT
!+ XCHG 0 !R+ TD 2+ DUP !R+ + DUP POP ! OFF ; : HIDROP HDICT 0;
`EG HDICT @ TO HDICT ;       : TARGET,! FX `TRG `- ;; : <H> TL
D@ H HOFS TL D! TO HOFS TO H ; : INITO FX SAME? AT vTOK? FX
(LIT TO (LIT, FX (; TO ESC FX - `- CALL NUM? EXEC N>#, , :
OPER! THEN POP 0 OPER[] 8 CMOVE ; : MARK@ @HD PUSH @R+ TO HOFS
@R+ TO H POP @ TO T ; $221 =: FOUND? : MARK! @HD PUSH HOFS !R+
H !R+ T POP ! ; ESC HIDE ESC ESQ : ESC (; <H> <D> ; ESC HIDE ;`
ESQ $235 =: ;` $22F =: : HERE 'AT H T! TSAVE PROBA.COM
FFFFFFFFFFFFFFFFF

{ MACRO }
M: `(JUMP (JUMP; '' ?M: `(;GO (;GO'     M: `(IF (IF;
M: `(CALL (CALL;     M: `(FOR (FOR;     M: `(OF (OF;
M: `(NEXT (NEXT;     M: `(DROP DROP;    M: `(PUSH PUSH;
'" ?M: `(RET (;"     M: `(ABRT ((A";    M: `((" ((";
M: `((." ((.";       M: `(LIT (LIT;     M: `(CON (CON;
M: `(CON2 (CON2;     M: `(CON3 (CON3;   M: `(DEF3 (DEF3;
M: `(VAR (VAR;       M: `(SET (SET;     M: `(SET2 (SET2;
M: `(DEF (DEF;       M: `(DEF2 (DEF2;   M: `(NEST (:;
M: `(SKIP (SKIP;     M: `BARY (BARY;    M: `WARY (WARY;
M: `(-IF  (-IF;  '' ?M: `CODE ;code'    M: `LARY (LARY;
M: `DZ#0 (DZ#0;      M: `DZ#1 (DZ#1;    M: `DZ#2 (DZ#2;
M: TWICE` CALL THEN; M: -IF` DUP 0< IF; M: D0` 0 0;
                                                                
                                                                
                                                                
{ MARK> <MARK RELS> <RELS }
$498 =, `;E >, @H- EXEC EX : END! HERE TO ENDH ;
'TO CSTK> (,X .M> `;E  ' CSTK> (,X .R> `;E
'TO <CSTK (,X .<M `;E  ' <CSTK (,X .<R `;E

: `MARK> MRK>. .M> ;
: `MARK>< `MARK>
: `<MARK HERE .<M ;
: .<RLS .<R , ;
: `<RLS> .<RLS
: `RELS> .R> RLS>. ;
' `RELS> =: THEN`
' `<MARK =: BEGIN`
                                                                
                                                                
                                                                
{ IFS} : AHEAD` `(JUMP `MARK> ; : ;GO` `(;GO `MARK> ;
: (#, @R+ : COMP, , END! ; : `NUM?, NUM? : ,LIT` `(LIT COMP, ;
: IF` `(IF `MARK> ;             : CALL` `(CALL `MARK> ;
: FOR` `(FOR `MARK>< ;          : NEXT` `(NEXT `<RLS> ;
: UNTIL` `(IF .<RLS ;           : AGAIN` `(JUMP .<RLS ;
: CASE` 0 TO CSTK> ;            : REPEAT` `(JUMP `<RLS> ;
: FOR>` `(PUSH `<MARK ;         : OF` `(OF `MARK> ;
: <NEXT` `(NEXT .<RLS ;         : -UNTIL` `(-IF .<RLS ;
: ;CSTR EX CSTR, ;              : TB-ABRT ;CSTR `(ABRT ;
: TB" ;CSTR `((" ;              : TB." ;CSTR `((." ;
: ;;` `(RET AT <CSTK ITEMS? AT CSTK> ITEMS? + 0<>; EX ,<` ;
' CALL` =: [`      ' IF` =: WHILE`    : ;CASE` `(DROP
BEGIN CSTK> DUP WHILE TO CSTK> THEN` REPEAT     DROP ;
: CSWAP>` `;STK> `;STK> SWAP ;  : <CSWAP` `;<STK `;<STK SWAP ;
: ELSE` AHEAD` CSWAP>` THEN` ;          ' ELSE` =: ENDOF`
                                                                
{ ; - SES }

: `TvIS:? T>R @ $497 = ; : `TvTOC>. 2+ ;

: `x??x EX ??# : `(@H, @H- `TvTOC>. ;
: `?? `x??x : `H@:? H 2- @ `TvIS:? HERE ENDH <> AND ;
: :;` `?? TO <CSTK `(;GO .<RLS ;
: ;` `H@:? ;;` 0; UNW `(@H, TO <CSTK AGAIN` ;
: ;THEN` ;` THEN` ;   ' ;THEN` =: ]`
: ?;` `?? TO <CSTK UNTIL` ;

: "BSCAN =0, DOES> : B>IN" PUSH XCHG CSTR POP BSCAN 1+ ;
: ,T BL ?, ;
                                                                
                                                                
                                                                
















