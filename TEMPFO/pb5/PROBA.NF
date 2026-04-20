


\ 12 LOAD  { :`S , DOES>`S  AND  STACK`S  DEFINITION }
\ 13 LOAD  { IFS}
\ 14 LOAD  { ; - SES }
\ 15 LOAD  { STRING COMPILATION }
\ 16 LOAD  { INIT}
\ 17 LOAD  { EDITOR}







{ :`S , DOES>`S  AND  STACK`S DEFINITION} : `T =H >, EX ,<` , ;
M: :(CALL (CALL; M: :(FOR (FOR; M: :(NEXT (NEXT;
M: TWICE` CALL THEN;
' { =: {`       : TO` 'TO , ;  : AT` 'AT , ; : CODE: HP =, ;
: :` :(SKIP =H :(NEST 2 T NAME> 2+ +! ;
: 0#> D# :(DZ#0 ; : 1#> D# :(DZ#1 ; : 2#> D# :(DZ#2 ;
: DOES>` :CODE 0#> DROP ; ' RELS> =: THEN`   ' <MARK =: BEGIN`
: VARIABLE 0 : VAR `T :(VAR ; : CREATE VARIABLE UNW ;
: QUAN `T :(CON3 : `Q :(SET2 :(VAR ; : VQUAN `T :(DEF3 `Q ;
: VALUE `T :(CON2 : `S :(SET ; : VECTOR `T :(DEF2 `S ;
: DEFER `T :(DEF ; : CONST `T :(CON ;
: `4ARY 2* : `2ARY 2* : `ARY =H >, EX ,<` CLARY ;
: BARY `ARY :(BARY ; : WARY `2ARY :(WARY ;
: LARY `4ARY :(LARY ;
13 27 THRU  35 LOAD PRUNE

{ IFS} : AHEAD` :(JUMP MARK> ; : ;GO` :(;GO MARK> ;
: IF` :(IF MARK> ;             : CALL` :(CALL MARK> ;
: (#, @R+ : COMP, , END! ; : `NUM?, NUM? : ,LIT` :(LIT COMP, ;
: FOR` :(FOR MARK>< ;          : NEXT` :(NEXT <RELS> ;
: UNTIL` :(IF <RELS ;           : AGAIN` :(JUMP <RELS ;
: CASE` 0 TO CSTK> ;            : REPEAT` :(JUMP <RELS> ;
: FOR>` :PUSH <MARK ;           : OF` :(OF MARK> ;
: <NEXT` :(NEXT <RELS ;  : ;CSTR EX CSTR, ;   : TB" ;CSTR :(" ;
: TB." ;CSTR :(." ;             : TB-ABRT ;CSTR :(AB ;
: ;;` :(RET AT <CSTK ITEMS? AT CSTK> ITEMS? + 0<>; EX ,<` ;
' CALL` =: [`      ' IF` =: WHILE`    : ;CASE` :DROP
BEGIN CSTK> DUP WHILE TO CSTK> THEN` REPEAT     DROP ;
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
: C:` ,' ; : DXEP1+ DUP 1+ XEP ; : DXEP2+ DUP 2+ XEP ;



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
0 WARY `STR  >, CSTR, BS, TERR. ". ,<
0 WARY `STR, >, TB" BS, TB-ABRT TB." ,<
: `OK" OVER C@ '" - NOP ?; OVER 1+ C@ '" <> STR- ?; ;;
: `STR@ CSTR `OK" 2- OVER C! SBUF "PACK ;
: STR? DUP NAME> 1- C@ '" = PUSH DUP 1+ C@
                `SPEC? DUP 1- TO XK   0 <> POP AND ;
: `NUM STR? NUM? ?; `STR@ XK `STR @EXEC ; : `.R, RDROP , ;
: `NUM, STR? `NUM?, ?; `STR@ XK `STR, @EXEC ;
: `EXE >NF< NAME> PUSH 2 I+ @ ODD A" DEFINED?" RDROP EXEC ;
: `COM >NF< NAME> PUSH 2 I+ @ ODD `.R, ?; DROP H @I , POP ! ;
: TINIT CALL `NUM `EXE `NUM, `COM THEN OPER! ; { TINIT}



 0 VALUE SPTRTOP  0 VALUE SPTR : ;SPTR  SPTR EX TO SPTR ;
: EOS! bs TO EOS ; : S> SPTR : SDROP ;SPTR NAME> ;
: C!- 1-DXEP C! ; : ;EOS EOS XCHG 0 TO EOS EXECUTE POP TO EOS ;
: SPTRTOP? SPTRTOP T <>  SPTR SPTRTOP U< 0=  OR  0;
  T DUP TO SPTRTOP TO SPTR TWICE  D0
: >S ;SPTR OVER PUSH (MPUSH XCHG POP C!- ; : >S! CSTR >S ;
: >"! DXEP : >" OVER C@ 1+ CMOVE ;
: SUCSTR SWAP : UCSTR XEP CSTR ;
: "+!  SUCSTR DXEP NAME> (MOVM DROP : L"! J NOT + J C! ;
: "+C! SWAP DXEP NAME> C!+ L"! ;






\ BLOCK1 OF EDITOR
: WHAT? 7 EMIT ; : SWIPE SCR : WIPE BLOCK 1K BLANK UPDATE ;
ZDO VALUE 4 TIMES  `PDATA `INS  `SZ  `ALTER
0#> SWAP TO XK CSTR 2DUP XK BSCAN 1+ 2* + + @EXEC ; =: `XK!

 2000 HIPUSH <H>
: -:  ' , C,  XK 2+ DUP TO XK       { BYTES FOR MOVE UP 1 }
         HERE OVER - DUP PUSH       { START ADDRESS    }
         DUP 1+ ROT                 { PREPARE FOR MOVE }
         CMOVE>  HERE C@ POP C!   ; { FIX CODE  }
: SWITCH: CREATE HERE 73 1 TO XK 0 -: (LIT  `XK!  TOBE ;
: ;SWITCH  73 - A" BAD KEYS" XK 2/ 1- SWAP C! ;
 <H>  : `?XY 1L U/MOD 6 3 : V+ ROT + U+ ;



\ BLOCK2 OF EDITOR
: `POSXY XY `?XY @XY ; : `_INS `INS 0= TO `INS : `.INS 75 1 @XY
`INS IF ." INS" ;THEN ." OVT" ; ' ETIB =: `EOS^ : `;LRUD XY  EX
>XY  73 3 @XY XY 5 .UR 72 5 @XY  XY 1L U/MOD 3 .UR 3 .UR ;
: `ERR 73 1 @XY ;
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
: NBLK1  1 : `LB SCR + 0 MAX TO SCR `LOADRAW ;  : `B -1 `LB ;
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
 kHOME -: `L_BEG   kEND -: `L_END  kPGUP -: `B   kPGDN -: NBLK1
 kDOWN -: `L_DN  kRIGHT -: `->     kINS  -: `_INS kDEL -: `DELC
 kaW   -: `WIPE kcRIGHT -: `ADV  kcLEFT -: `BACK kcEND -: `SCR;
 ksTAB -: `<TAB  kcHOME -: `APOS   kaS -: `altS  kaD -: `DELL
;SWITCH        : `ONEC XK BL U<  IF WHAT? ;THEN XK `INSC `-> ;
SWITCH: `EK `ONEC C^ J -: `<- C^ K -: `-> C^ X -: `CUT 127 -:
`BKCW bs -: `BS C^ D -: `DELC cr -: `<_| C^ G -: `CUTW C^ Z -:
`PREPARE C^ N -: NBLK1 C^ B -: `B C^ R -: `RESET C^ I -: `TAB>
 C^ C -: `COPY C^ V -: `PASTE C^ Q -: `ESQ/E C^ F -: `MOVE
 C^ A -: `ADV  kESQ -: `Q/ED  C^ S -: `INSL  0 -: `EF ;SWITCH
: `@KEY `POSXY KEY W>BB DUP IF SWAP ;THEN DROP ;
: EDIT TO SCR : PE PAGE : E  D0 ;0TI `LOADRAW ;EOS  BEGIN `@KEY
`EK EOS  UNTIL ;  HIDROP

{ HACKER }
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


{ PRUNE DEF =USED >USED }
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

{ NUMBER PARSER} FORGET >STR : >STR : >MEM DU+ ;0TI ; : L?
1 LTIB U< ; : ??# 0= : ?? 0; I '@ EMIT H. 1 A" NUMBER ? " ; 0#>
NUP CSTR ROT BSCAN 1+ DUP 0; NIP ; =, `NUM' ,T #$%' : EX0; LTIB
0<>; RDROP : LTIB- ;LTIB 1- ; : INTIB ETIB LTIB : A+L XEP I- ;
0 VALUE `BASE 0 VALUE `RES 0#> @ : `BASE! 2- W>B 2+ TO `BASE :
L?; L? 0; ; DUP =, `1H 16 , =, `BIN 2 , : `DC@ INTIB DROP C@ ;
: `;RES `RES EX TO `RES ; : `INI0 L? EXIT ?; : `INI `;RES
`BASE! 0 ; : `ZIFR [ 0= DUP 0; DROP DUP `BASE U< ] '` OVER   U<
IF $DF AND THEN '0 - 9>? DUP 0; - DUP lf U< ; : ``NUM L?   EXIT
?; LTIB- `DC@ : `*+ `;RES `BASE U* + ; : `NCHAR `ZIFR .EXIT  ?;
`*+ ; 0 WARY `NUMA >, `NCHAR `INI0 `1H `BIN ``NUM ,<
: >(NUM CSTR : (NUM >MEM `INI lf TO `BASE [ `RES LTIB ] EX0;
   `DC@ '- = IF L?; [ `;RES NEG ] BEGIN LTIB- THEN LTIB 0;
 `DC@ `NUM' `NUMA @EXEC AGAIN ; : ?N TOKEN? : >NUM? >(NUM ?? ;


{ NUMBER PARSER CF }
: L? 1 LTIB U< ; : `DC@ INTIB DROP C@ ;   0#>
NUP CSTR ROT BSCAN 1+ DUP 0; NIP ; =, `NUM' ,T #$%' 2 ALIGNED
0 VALUE `BASE : EX0; LTIB 0<>; RDROP : LTIB- ;LTIB 1- ; 0#>   @
: `BASE! 2- W>B 2+ TO `BASE : L?; 0; ; N: `1H 16 , =, `BIN 2 ,
: `INI0 L? EXIT ?; : `INI ;RES `BASE! 0 ;
: DIGIT [ 0= DUP 0; DROP DUP `BASE U< ] UPC '0 - 9>? DUP 0;   -
DUP lf U< ; : ``NUM L? EXIT ?; LTIB- `DC@ : `*+ ;RES `BASE U* +
; : `NCHAR DIGIT .EXIT ?; `*+ ; 0 WARY `NUMA >, `NCHAR `INI0
`1H `BIN ``NUM ,<
: >(NUM CSTR : (NUM >MEM `INI lf TO `BASE [ `RES LTIB ] EX0;
 `DC@ '- = IF L?; [ `;RES NEG ] BEGIN LTIB- THEN LTIB 0; `DC@
 `NUM' `NUMA @EXEC AGAIN ; : NUM? TOKEN? : >NUM? >(NUM ?? ;



{ HEX FILE GENERATION}
: .LADR W>BB TWICE : .LB W>B DUP L+ .B ;
: .HEX { TYPE ADDRES LENGTH }  [ L NEG W>B .B CR DROP ] ': EMIT
0 TO L DUP PUSH .LB DUP .LADR SWAP .LB POP  LOOPS CSTR .LB ;












ª ¥JÕ!È‹ ^î_[YZîóWˇ÷_óîRQSWúî√êø î^îã÷óÕ!ó√êø 
îY^îâËÏˇîFVî√ê
ó≠®óu„<Q=ã˜îYîÎ>OVSRUîQîˇ◊îYî¸]Z[Î*FFÎ'Ix˘êã4Î_îQîãÎ!_âîYî
Î_QãœÎ	_SãﬂÎVW^ó≠®ótˆOˇÁGGWÎÒÎ	îQî_YQWÎÊQîQîYÎﬂî_—Á——;Àr+ÀGW
îÎŒêî_˘ãœ—ŸÎÒî_˜« tÀ—Ÿ—ﬂÎ·î_#œ˜—Î⁄º ˛∏ ˚êË†ˇ                

$10A 1+ =: (@REG        $120 1+ =: (@DE
$12E 1+ =: (@ACC
$16E 1+ =: (JUMP        $140 1+ =: (IF
$190 1+ =: (;           $16A 1+ =: (IF-
$17A 1+ =: !R+          $172 1+ =: @R+
$182 1+ =: XCHG         $188 1+ =: XA
$14A 1+ =: PUSH         $1AC 1+ =: POP
$1A0 1+ =:  DUP         $1A2 1+ =: J
$1C4 1+ =: +2/          $1DE 1+ =: NAND
$1CE 1+ =: +*           $1B2 1+ =: -/

{ STREAMS : D". DUP : ?".  CR ". SPACE SBUF ". ; } 26 CONST eof
: AUTO PUSH " \AUTO\" SBUF >"! POP "+! " .CF" "+! ;
: FGET Fbuf [ DROP cr EOS! ] AT Fbuf 1 AT HANDLES TOP Fread _AX
0; DROP Fbuf DUP eof XOR 0; RDROP ; : ;@FILE TO HANDLES @R+ AT
  KEY @ XCHG PUSH TO KEY EX POP TO KEY : HCLOSE HANDLES Fclose
;   \ : EDKEY XY 960 = IF 0 TO XY NBLK1 THEN XY 0= IF WIPE1 THEN
: EDKEY  FGET DUP lf = IF DROP 0 THEN ;
                            : ;NOEMIT (LIT DROP; : ;EMIT!  (LIT
TO EMIT : ;SAFE! DUP XCHG OVER @ PUSH PUSH ! EX POP POP ! ;
: NEEDS EXIST? 0<>; TBUF AUTO : INCLUDED FOPEN ;@FILE FGET D0
 ;0TI ;NOEMIT : KEVAL ;EOS BEGIN vINIT EVAL EOS UNTIL ;
: INCLUDE TOKEN?  INCLUDED ;
: FTYPE TOKEN? FOPEN ;@FILE FGET ;EOS BEGIN KEY EMIT EOS UNTIL
;     : CLOSE_ALL    AT HANDLES ITEMS? LOOPS HCLOSE ;
: FLOAD TOKEN? FOPEN ;@FILE EDKEY E ;

\ FILE TO BLOCKS CONVERTER   PART OF FILE_READER
CREATE FBUFFER 70 ALLOT  ZDO VALUE 3 TIMES  SPAN MPTR 1BLK
: GETLINE FBUFFER 1L ACCEPT TO SPAN DROP ;
: WIPE? XY 1K U< 0<>; SCR 1+ TO SCR
: `?ADDLINE WIPE? FBUFFER  MPTR XY + SPAN CMOVE XY 1L + TO XY ;
: F2B  TOKEN?  : "F2B FOPEN ;FILE SCR TO 1BLK WIPE ;EOS
  ;NOEMIT BEGIN  GETLINE `?ADDLINE EOS  UNTIL ;

\ TO DO         DEFINERS
\          IO  FILE_READER  COMPILER  FILE_WRITER
\ EDITOR  TARGET_COMPILER         NEW_KERNEL   NEW_FORTH





: FLOAD TOKEN? FOPEN ;FILE E ;
: F62  FLUSH 62 BLOCK DROP D0 SCRH Fwrite ;
EXIT
EXI?T HLD     0 VALUE HLD
: ;HLD HLD EX TO HLD ; : BASE! 2 UMAX TO BASE ;
: <# 0 : <#? 0 TO HLD 0; NEG EX sgn : HOLD ;HLD C!- ;
: 1# BASE U/MOD SWAP ALPHA HOLD ; : ?#> HLD DUP NEG ;
: `N# XEP DUP 0< <#? : S# 1# DROP; #?; RECURSE ;
: .R lf : .RB BASE! `N# HLD + SPACES : #> ?#> TYPE ;           .







{ PROBA.COM } ' \ =: \`    $178 =: EVAL   CMDLN OFF
M: PRB USING PROBA.COM; \ SELF LOAD
M: C4 USING C4H.COM;
M: C5 USING C5H.COM;
M: PR5 USING PB5.COM;
M: NFC USING NFC.COM;
M: CLR STOP FORGET S0;
CR .( PROBA.COM !!!)
CREATE TT  PAGE 35 LIST







: Q ; 1 =: (IF-  2 =: (EX  3 =: (A"  4 =: ("  5 =: (."
M: IF- (IF- X: MARK>;
: MAC
 :J  :I+ :I- :(IF- :(EX :(JUMP :(EX :(;GO :(EX :(IF :(EX
:(OF :(EX :DROP :PUSH :(RET :(AB :(" :(." :(LIT :(CON :(CON2
:(VAR :(CON3 :(DEF3 :(SET :(SET2 :(DEF :(DEF2 :(NEST :(SKIP
:(BARY :(DROP :(1- :(WARY :POP :(NOP :(LARY :CODE :(DZ#0 :(DZ#1
:(DZ#2 :(DO>  :(DO< :RDROP :(VAR3 :(VAR2 :(RDROP :.RDRP
;







     0 VALUE HLD    0 VALUE BASE

: ;HLD HLD EX TO HLD ; : BASE! 2- W>B 2+ TO BASE ;
: <# 0 : <#? CMDLN TO HLD 0; NEG EX '- : HOLD ;HLD C!- ;
: 1# BASE U/MOD SWAP ALPHA HOLD ; : ?# CMDLN HLD - ;
: `N# XEP DUP 0< <#? : S# BEGIN 1# DUP 0= UNTIL DROP ;
: .R lf : .RB BASE! `N# ?# - SPACES : #> HLD ?# TYPE ;









FORGET HLD
0 VALUE HLD 0 VALUE BASE '- CONST sgn
: ;HLD HLD EX TO HLD ; : BASE! 2- W>B 2+ TO BASE ; : N# LOOPS :
# BASE U/MOD SWAP ALPHA : HOLD ;HLD C!- ; : ?SPC CMDLN HLD - -
: SPACES LOOPS SPACE ; : <# CMDLN TO HLD BASE! ; 0#> @ 1H ;SPC
<# N# : #> DROP HLD CMDLN OVER- TYPE ; DUP =, H. 4 , =, B. 2 ,
: ;<#> <# EX ?SPC #> ; : U. 0 ;SPC : U.R lf : U.R# ;<#> : u. 31
AND XEP : S# BEGIN # DUP 0= UNTIL ; : ` DUP 0< 0; NEG EX    sgn
HOLD ; : . 0 ;SPC : .R lf : .R# ;<#> SWAP ` SWAP u. ;







\ FLOAD AUTO\BLHS.CF
0 VALUE V  0 VALUE VH
: ;V V EX TO V ; : C!V+ ;V C!+
: VHI! DUP 1K U* TO V ;
: 1L+ : V+ ;V 1L + ;
: C!V+ ;V 1K U/MOD OVER ?WIPE
                        960 U< IF

IF V 1023 AND
              960 = IF 1L+ THEN






 34 ALLOT HERE CONSTANT #BUF     10 TO BASE
: ` DUP 0< 0; NEG EX sgn : HOLD HLD C!-  TO HLD ; : <# #BUF TO
: ` DUP 0< 0; NEG EX sgn : HOLD HLD C!-  TO HLD ; : <# #BUF TO
 HLD ; : BLHS LOOPS : BLH BL HOLD ; : ;<#> <# TO BASE EX CALL -
  BLHS : #> DROP HLD THEN #BUF HLD - ; : #.>S ;<#> BLH DXEP
: N# LOOPS : # BASE U/MOD SWAP ALPHA HOLD ; : `1 BLH ?; ; :
 .R#>S ;<#> SWAP ` SWAP : U_S# 0 MAX 33 UMIN XEP J `1
: S# BEGIN # DUP 0= UNTIL ; : U.R>S lf : U.R#>S ;<#> U_S# ;
: . 0 : .R lf : .R# .R#>S TYPE ; : H. 4 : H.L 1H #.>S TYPE ;
: U. 0 : U.R lf : U.R# U.R#>S TYPE ; : B. 2 H.L ; : 1H. 1 H.L ;
: %. 16 : %.L 2 : #.L #.>S TYPE ;





































































































































































































































































































































































