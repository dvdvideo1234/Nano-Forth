{ :`S , DOES>`S  AND  STACK`S DEFINITION} : `T =H >, EX ,<` , ;
M: :(CALL (CALL; M: :(FOR (FOR; M: :(NEXT (NEXT;
M: TWICE` CALL THEN;
' { =: {`       : TO` 'TO , ;  : AT` 'AT , ; : CODE: HP =, ;
: :` :(SKIP =H :(NEST 2 T NAME> 2+ +! ; : @' ' @ ;
: 0#> D# :(DZ#0 ; : 1#> D# :(DZ#1 ; : 2#> D# :(DZ#2 ;
: DOES>` :CODE 0#> DROP ; ' RELS> =: THEN`   ' <MARK =: BEGIN`
: VARIABLE 0 : VAR `T :(VAR ; : CREATE VARIABLE UNW ;
: QUAN `T :(CON3 : `Q :(SET2 :(VAR ; : VQUAN `T :(DEF3 `Q ;
: VALUE `T :(CON2 : `S :(SET ; : VECTOR `T :(DEF2 `S ;
: DEFER `T :(DEF ; : CONST `T :(CON ;
: `4ARY 2* : `2ARY 2* : `ARY =H >, EX ,<` CLARY ;
: BARY `ARY :(BARY ; : WARY `2ARY :(WARY ;
: LARY `4ARY :(LARY ; : "BSCAN =H :(BSC ;
13 27 THRU  35 LOAD  PRUNE

{ IFS}  ' CSWAP> =: CSWAP>`
: AHEAD` :(JUMP MARK> ; : ;GO` :(;GO MARK> ;
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
: ELSE` AHEAD` CSWAP>` THEN` ;          ' ELSE` =: ENDOF`


{ ; - SES }
: `TvIS:? T>R @ $497 = ; : `TvTOC>. 2+ ;

: `x??x EX ??# : `(@H, @H- `TvTOC>. ;
: `?? `x??x : `H@:? H 2- @ `TvIS:? HERE ENDH <> AND ;
: :;` `?? TO <CSTK :(;GO <RELS ;
: ;` `H@:? ;;` 0; UNW `(@H, TO <CSTK AGAIN` ;
: ;THEN` ;` THEN` ;   ' ;THEN` =: ]`
: ?;` `?? TO <CSTK UNTIL` ;

: ,T BL ?, ; : C:` ,' ;
' ((." (,X ."` ,"  ' ((" (,X "` ,"  $194 (,X A"` ,"
@' (DOS  DUP =, (VID $10 C,  =, (KBD $16 C,
: `;HOME EX : HOME D0 : @XY BB>W D0 $200 (VID ;
: PAGE `;HOME  0 24 @XY  25 : CRS  LOOPS CR ;

{ INIT}
"BSCAN `SPEC? ,T ",!. : TERR. TO STATE vERR ;
0 WARY `STR  >, CSTR, BS, TERR. ". ,<
0 WARY `STR, >, TB" BS, TB-ABRT TB." ,<
: `OK" OVER C@ '" - NOP ?; OVER 1+ C@ '" <> STR- ?; ;;
: `STR@ CSTR `OK" 2- OVER C! SBUF "PK ;
: STR? DUP NAME> 1- C@ '" = PUSH DUP 1+ C@
                `SPEC? DUP 1- TO XK   0 <> POP AND ;
: `NUM STR? NUM? ?; `STR@ XK `STR @EXEC ; : `.R, RDROP , ;
: `NUM, STR? `NUM?, ?; `STR@ XK `STR, @EXEC ;
: `EXE >NF< NAME> PUSH 2 I+ @ ODD A" DEFINED?" RDROP EXEC ;
: `COM >NF< NAME> PUSH 2 I+ @ ODD `.R, ?; DROP H @I , POP ! ;
: TINIT CALL `NUM `EXE `NUM, `COM THEN OPER! ; { TINIT}



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
 <H>  : `?XY 1L U/MOD 4 0 : V+ ROT + U+ ;



\ BLOCK2 OF EDITOR
: `POSXY XY `?XY @XY ; : `_INS `INS 0= TO `INS : `.INS 72 0 @XY
`INS IF ." INS" ;THEN ." OVT" ; ' ETIB =: `EOS^ : `;LRUD XY  EX
>XY  69 2 @XY XY 6 U.R 69 4 @XY  XY 1L U/MOD 3 U.R 3 U.R ;
: `ERR 73 1 @XY ;
: `;LPOS  XY : `;PDATA+ EX `PDATA + ;   : `POS^ `;LPOS ;;
: `RELOAD SCR BLOCK DUP TO `PDATA 1K + TO ETIB  SPTRTOP? ;
: `REDRAW  `ERR SPACE  `.INS HOME `PDATA .BLOCK ;
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
: `X-POS 75 15 @XY EOS! ; : `Q/ED FLUSH `X-POS ;
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

{ STREAMS : D". DUP : ?".  CR ". SPACE SBUF ". ; } 26 CONST eof
' \ =: \`  $178 =: EVAL : ;HCLOSE EX : HCLOSE HANDLES Fclose ;
: gpt AT Fbuf 1 AT HANDLES TOP ; : FCREATE ;File Fcreate ;
: AUTO PUSH " NF10\AUTO\" SBUF >"! POP "+! " .CF" "+! ; : FGET
 [ cr EOS! ] gpt Fread _AX 0; Fbuf eof - 0; RDROP Fbuf ; : Fput
TO Fbuf gpt Fwrite ; : @EMT (LIT TO EMIT ; : ;@OPENI FOPEN   TO
HANDLES @R+ AT KEY @ XCHG EOS PUSH PUSH TO KEY 0 TO EOS  EX POP
TO EOS POP TO KEY HCLOSE ; : ;@CREATE FCREATE AHEAD    : ;@OPEN
FOPEN THEN TO HANDLES : ;@!EMIT @R+ @EMT @ XCHG PUSH CALL    EX
POP THEN @EMT ! ; : NEEDS EXIST? 0<>; TBUF AUTO : INCLUDED
;@OPENI FGET D0 ;0TI ;@!EMIT DROP; BEGIN vINIT EVAL EOS UNTIL ;
: FTYPE TOKEN? : FTYPED ;@OPENI FGET BEGIN KEY EMIT EOS UNTIL ;
: CLOSE_ALL AT HANDLES ITEMS? LOOPS HCLOSE ; : INCLUDE   TOKEN?
INCLUDED ;


\ FILE <> BLOCKS CONVERTERS   - PART OF FILE_WRITER
: FCUT FLUSH 1- BLOCK DROP D0 SCRH Fwrite ; : ;NIP EX NIP ;
0 VALUE VBLK  : IXEC J PUSH ; : ;UNTIL BEGIN IXEC UNTIL RDROP ;
: LFBLK ;UNTIL 1- DUP ;NIP : TRIM<BLK BLOCK 1K : TRIM< FOR  DUP
I+ C@ '! U< IF CSWAP> NEXT 0 ;THEN POP 1+ ; 0 VALUE `LastB : `L
2DUP 1+ U< 0; DUP TO `LastB EX `LastB TRIM<BLK 1L UN? AHEAD :
 B2F TOKEN? AUTO : "B2F ;@CREATE Fput ;HCLOSE `L 1- ;RNG> BLOCK
1H THEN .LOOPS DUP 1L + XEP 1L TRIM< TYPE CR ;
: `NEWBLK? XEP LTIB 0<>; 1K TO LTIB BLK 1+ DUP TO BLK 0 TO ETIB
: WIPE DUP : WIPES ;RNG> BLOCK 1K BLANK UPDATE FLUSH ;
: C>BLK `NEWBLK? DUP BL U< IF cr = 0; \` ;THEN SOURCE LTIB - C!
UPDATE ;LTIB 1- ; : `FREAD DXEP : FREAD TOKEN? : FREADED
;@OPENI FGET ;B_TI BLK WIPE BEGIN KEY C>BLK EOS UNTIL ;
: FEDIT 100 LFBLK 1+ `FREAD DUP TO VBLK EDIT ; : FWIPE VBLK 100
LFBLK WIPES ;

















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


































{ PROBA.COM }                             CMDLN OFF
M: PRB USING PROBA.COM; \ SELF LOAD
M: C4 USING C4H.COM;
M: C5 USING C5H.COM;
M: PR5 USING PB5.COM;
M: NFC USING NFC.COM;
M: CLR STOP FORGET S0;
\ CR .( PROBA.COM !!!)
CREATE TT CR  35 LIST







: Q ; 1 =: (IF-  2 =: (EX  3 =: (A"  4 =: ("  5 =: (."
M: IF- (IF- X: MARK>;
: MAC
 :J  :I+ :I- :(IF- :(EX :(JUMP :(EX :(;GO :(EX :(IF :(EX
:(OF :(EX :DROP :PUSH :(RET :(AB :(" :(." :(LIT :(CON :(CON2
:(VAR :(CON3 :(DEF3 :(SET :(SET2 :(DEF :(DEF2 :(NEST :(SKIP
:(BARY :(DROP :(1- :(WARY :POP :(NOP :(LARY :CODE :(DZ#0 :(DZ#1
:(DZ#2 :(DO>  :(DO< :RDROP :(VAR3 :(VAR2 :(RDROP :.RDRP
;







FORGET TT  CREATE TT
: C@ @ : W>B 255 AND ; : C@+ PUSH @R+ W>B POP 1- ; : W>BB TO
 Fbuf AT Fbuf C@+ C@ ; : B>N 2/ 2/ 2/ 2/ : B>H 15 AND ; : B>HH
 DUP B>N XEP B>H ; : H. W>BB TWICE B>HH TWICE ALPHA EMIT ;




























































































































































































































































































































































































































