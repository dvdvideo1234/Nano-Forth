















M: TWICE` CALL THEN;   : N: DUP =, ; : U1- XEP 1- ;
: STR- 1- XEP 1+ ;
INCLUDE PB5_BODY
: TT ;  ' BLK. TO vLOAD
: SRCA1 ;











\ FILE <> BLOCKS CONVERTERS   - PART OF FILE_WRITER
0 VALUE VBLK   0 VALUE `LastB : LFBLK ;UNTIL 1- DUP ;NIP
: TRIM<BLK BLOCK 1K : TRIM< FOR  DUP I+ C@ '! U< IF CSWAP> NEXT
 SKIP THEN POP 1+ ; : `L 2DUP 1+ U< 0; DUP TO `LastB EX `LastB
 TRIM<BLK 1L UN? AHEAD : B2F TOKEN? AUTO : "B2F ;@CREATE Fput
;HCLOSE `L 1- ;RNG> BLOCK 1H THEN .LOOPS DUP 1L + XEP 1L TRIM<
TYPE CR ; : `NEWBLK? XEP LTIB 0<>; 1K TO LTIB BLK 1+ DUP TO BLK
0 TO ETIB : WIPE DUP : WIPES ;RNG> BLOCK 1K BLANK UPDATE FLUSH
; : C>BLK `NEWBLK? DUP BL U< IF cr = 0; \` ;THEN SOURCE LTIB  -
C! UPDATE ;LTIB 1- ; : `FREAD DXEP : FREAD TOKEN? : FREADED
;@OPENI Fget ;BLKTI BLK WIPE BEGIN KEY C>BLK EOS UNTIL ;
: FEDIT 100 LFBLK 1+ `FREAD DUP TO VBLK EDIT ;
: FWIPE VBLK 100 LFBLK WIPES ;



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
 <H>  : `?XY 1L U/MOD 4 0 { : V+} ROT + XEP + ;



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
        DROP ?; BL SWAP C! ;

\ BLOCK3 OF EDITOR
: `<_|   `L_DN  : `L_BEG `;LRUD L/ ;    : `->  1 `XY+ ;
: `<-  1 `XY- ;  : `TAB> bs : `SZTB> `-> :; 1- `;LRUD OR ;
: `<TAB bs : `<SZTB `<- NEG : `TAB& `;LRUD AND ; { PREVIOUS}
: `APOS  0 `TAB& ; : `LINE/ `;LPOS  L/ ;  : `/LINE `;LPOS `/L ;
: `LDRAW `POSXY `LINE/ XY 1L U/ 1+ cr EMIT .LINE DROP ;
: `RESET -BUF : `LOADRAW `RELOAD `REDRAW ;
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
: `X-POS 75 15 @XY EOS! ; : `Q/ED FLUSH `X-POS ;
: `SCR; `APOS `<- : `PREPARE `L_END `PREP ;
 <H>  : C^ TOKEN? 1+ C@ 31 AND ;

{ BLOCK5 OF EDITOR \ KEY CONSTANTS}
80 CONST kDOWN  81 CONST kPGDN  82 CONST kINS   83 CONST kDEL
79 CONST kEND   84 CONST ksF1
59 CONST kF1    60 CONST kF2    61 CONST kF3    62 CONST kF4
63 CONST kF5    64 CONST kF6    65 CONST kF7    66 CONST kF8
67 CONST kF9    68 CONST kF10   30 CONST kaA
113 CONST kaF10 17 CONST kaW    71 CONST kHOME  72 CONST kUP
73 CONST kPGUP  75 CONST kLEFT  77 CONST kRIGHT 27 CONST kESQ
9 CONST kTAB    104 CONST kaF1  93 CONST ksF10  94 CONST kCF1
103 CONST kcF10 15 CONST ksTAB  32 CONST kaD    31 CONST kaS
115 CONST kcLEFT  116 CONST kcRIGHT  117 CONST kcEND
118 CONST kcPGDN  119 CONST kcHOME   132 CONST kcPGUP




{ BLOCK6 OF EDITOR }  <H>
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
: `@KEY `POSXY KEY W>BB DUP IF SWAP ;THEN DROP ;
: EDIT TO SCR : PE PAGE : E  D0 ;MEMTI `LOADRAW ;EOS
 BEGIN `@KEY `EK EOS  UNTIL ;  HIDROP

: ,T BL ?", ; : `CN 2- C>N?  : `N  EXIT ?; POP ID.   ID. EXIT ;
: `TO. `CN ,< ,T TO   : `AT. `CN ,< ,T AT
: ?ID.   C>N? 0= ID. ?; `TO. `AT. 2+ 2+ : `H ." `$" H. ; 0#>
 PUSH XCHG CSTR POP SCAN 1+ ; =, `?STR 3 C, >, ((A" ((" ((." ,<
0 VALUE `WW  : `C>N  C>N? ; : `;WW `WW EX TO `WW ; : .HL `WW H.
; : `GETW `;WW @+ ; : `WW! T>R TO `WW ; : `?TA. `WW R>T `C>N
NIP 0; : `TA. `WW R>T ADRS. `C>N DROP ?; ." : " ID. ;
: SEE ' : @SEE `WW! : SL bs LOOPS : WW `TA. `GETW DUP H.
: `W0 DUP ?ID. `?STR 0; `;WW ;SPC ;[] DUP ". NAME> ;
: HACK ' : @HACK `WW! : HL `TA. bs LOOPS `?TA. `GETW `W0 ;
: -HL `WW 23 - @HACK ; : TEST 1 2 3 " 1234" ;





: PRUNE  [ TO T DUP STR + OFF DUP INC STR >DICT ] EDICT XEP
 H DUP OFF ;DROP ;FND J N>C SWAP U< 0;  J 1+ C@ '` - 0;
 J D>NAME OVER- H S+! DROP ;
0 VALUE FOUND
: `DEF: C: : DOES> [ H @ DUP TO FOUND CR . CR ]
 TO XK H OFF ;2DROP ;FND J NAME> 2+ @ XK PUSH ;
`DEF: DEF ODD = : `CNTR 0; J ID. H INC ;
`DEF: =USED 2/ = `CNTR ;
`DEF: >USED 2/ U< `CNTR ;

: `? J C@ - DUP 0< 0; RDROP : `SRCH; 2DROP 0 EXIT ;
: IN-STR> SUCSTR : SRCH> PUSH `? FOR> DUP J CSTR -TEXT EXIT2 ?;
1+ <NEXT DUP `SRCH; ;
: <IN-STR SUCSTR : <SRCH PUSH `? A+L FOR> DUP J CSTR -TEXT
EXIT2 ?; 1- <NEXT DUP `SRCH; ;

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



: .ALL ;2DROP ;FND J (TYP : >PRINT = : >PRT? 0; : JID J ID. ;
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





















































































{ INIT}
: @I J @ ; : .C@ DUP C@ ; : OPER! POP 0 OPER[] 8 CMOVE ;;
: "BSCAN =: :(BSC ;
 "BSCAN `SPEC? ,T ",!. : TERR. TO STATE vERR ;
0 WARY `STR  >, CSTR, BS, TERR. ". ,<
0 WARY `STR, >, TB" BS, TB! TB." ,<
: `OK" OVER C@ '" - NOP ?; OVER 1+ C@ '" <> STR- ?; ;;
: `STR@ CSTR `OK" 2- OVER C! SBUF "PK ;
: STR? DUP NAME> 1- C@ '" = PUSH DUP 1+ C@
                `SPEC? DUP 1- TO XK   0 <> POP AND ;
: `NUM STR? NUM? ?; `STR@ XK `STR @EXEC ; : `.R, RDROP , ;
: `NUM, STR? NUM?, ?; `STR@ XK `STR, @EXEC ;
: `EXE >NF< NAME> PUSH 2 I+ @ ODD A" DEFINED?" RDROP EXEC ;
: `COM >NF< NAME> PUSH 2 I+ @ ODD `.R, ?; DROP H @I , POP ! ;
: TINIT CALL `NUM `EXE `NUM, `COM THEN OPER! ; { TINIT}

: ` PUSH  PUSH !TD- POP !TD- POP  .C@ 1+ : >T ;TD (MPUSH ;
{ : ` ` TD @ [ID] KEY DROP ;} : S0 40 TO SCR 0 TO XY S ;
: TWORDS  ;<D> WORDS ; : % 0 ' >NF< ` ;; : %2 0 ' TOKEN? ` ;;
\ ' ' =: 'O  ' =H =: =HO   ' =: =: =:O  ' =, =: =,O
: TT? TOKEN? : TFND TD @ Dfnd ;  ' ' =: T'
: OBJ! TO H ; : ORG! H - TO HOFS ;  H ORG! { PREPARE FOR <H>}
: HERE! HERE - ALLOT ; $227 =: `-   $23D =: `vLIT,
: CALL! ;H XEP HERE SWAP HERE!  CALL, ;
: INITO FX SAME? AT vTOK? FX (LIT `vLIT,
   FX (; TO ESC FX - `- CALL NUM?  EXEC NUM?, , THEN OPER! ;
: =, ;, : =H HERE : =: PUSH TT? NIP 0= IF 0 POP TBUF ` ;THEN
 >NF<  NAME> PUSH 2 I+ @ ODD IF 2 I+ @ 3 - 2 I+ ! BEGIN I
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





{ PB5 PR5.COM C5 PRB C4 }
FORGET TT  CREATE TT   33 34 THRU      37 39 THRU

: STOP (LIT TO ESC  @  (LIT (; - 0; MARK@ HIDROP INITO ;;
: START STOP : EGG PAGE 18000 HIPUSH  36 LOAD MARK!
 FX NOP TO ESC   <H> TINIT TARGET,! ;; \ 40 62 THRU ;;
: ' ;?# TT? ; : META ' ' 2+ : T! T>R ! ;
: THACK ' T?ID! @HACK ; : TSEE ' T?ID! @SEE ;
: T:  =H CALL THEN T : USED+ NAME> 2+ INC ;
: =! 0 =: TD @ USED+ ; : N: DUP =, ;
: TTO ' 2- , ; : TAT ' 2- 2- , ; : VAL' ' 2+ ;
: : (ZST =H >, ;;
PRUNE
\ %2 MARK> CALL`  %2 MARK> [`


% ,<` % ;CASE` % TWICE` % ?;` % ;THEN`  % CASE` % {`    % \`
% AHEAD`  % REPEAT`  % AGAIN`   % UNTIL`  % BEGIN`  % WHILE`
% OF`   % ELSE` % ENDOF` % IF`  % THEN` % ;GO`  % ;;`   % -IF`
% IND<` % IND>` % DO>`  % DO<`  % LOOP` % NEXT` % <NEXT` % ESC
% UNTIL-` % ]`  % FOR`  % FOR>` % DOES>` % IF-` % CSWAP>` % :;`
%2 TAT AT`  %2 :RDROP (RDROP` %2 :(DROP (DROP`  %2 TTO TO`
%2 :RECURSE RECURSE`   %2 T: :` %2 :(IF IO`     %2 :(1- (1-`









: 0#> >, HERE :(DZ#0 ; : TDOES :CODE :(DZ#0 ;
: 1#> >, HERE :(DZ#1 ; : 2#> >, HERE :(DZ#2 ;
M: TWICE` CALL THEN;













{ DEFINITIONS }
: `T >, EX ,<` , ; : `Q :(VAR3 : `S :(SET2 : `H ,<` =H >, ;
: CREATE UNW :; : VARIABLE 0 : VAR `T `H :(VAR ;
: VARCON `T :(VAR2 `H :(CON ;   : QUAN `T `Q :(CON ;
: VQUAN `T `Q :(DEF ;           : VECTOR `T `S :(DEF ;
: DEFER `T `H :(DEF ;           : CONST `T  `H :(CON ;
: ;VALUE HERE DUP 6 + ,  :EX  " =: ;" SBUF >"! TOKEN? "+!
 >SEVAL TO LTIB    : VALUE `T `S :(CON ;
: `4ARY 2* : `2ARY 2* : `ARY =H >, EX ,<` CLARY ;
: BARY `ARY :(BARY ; : WARY `2ARY :(WARY ;
: LARY `4ARY :(LARY ;
: :RECURSE TD @ N>C , ; : N: DUP =, ;
: :VALUE >, :POP :(SET2 :(CON `H :(RET ;;



: `CLRY XEP RLS> RLS> : WALLOT LOOPS Z, ;
: 3PICK PUSH OVER POP SWAP ;
: STACK! =H PUSH , , , POP MRK> MRK> MRK> `CLRY RLS> ;
: ;2ALIGNED EX : 2ALIGNED 2 ALIGNED ;
' ;2ALIGNED TO v",

: `TvIS:? ODD 0= ; : `x??x EX ??# : `(@H, @H- ;
: `?? `x??x : `H@:? H 2- @ `TvIS:? HERE ENDH <> AND ;
: T:; `?? TO <CSTK :(;GO <RELS ;
: T; `H@:? ;;` 0; UNW `(@H, TO <CSTK AGAIN` ;
: T;THEN T; THEN` ;  : T?; `?? TO <CSTK UNTIL` ;





FDGSDFG
$100 ORG!  0 1 H RBLOCKS                     241 =: --END--
T' H 4 + T>R @ DUP  HERE! T>R  STR 1- >T
=! 2-DXEP  =! EMIT  =! vINIT     : `99 vINIT
: @- 2-DXEP : @ PUSH : (CON @R+ : EXIT POP : DROP (DROP ; : ?EX
EXIT ?; : EX POP : XPSH XCHG : EXECUTE PUSH ; : (LIT @R+ ;
: 2-DXEP (1- : 1-DXEP (1- : DXEP DUP : XEP XCHG EXECUTE POP ;
: !- 2-DXEP : ! PUSH : (SET !R+ EXIT ; : (SET2 @R+ (DROP (SET ;
: (+ @R+ +2/ : .EXIT POP : 2DROP NAND (DROP ;  : 1+ (+ ,< 1 ,
: (VAR3 @R+ (DROP : (VAR2 @R+ : .POP (DROP : (VAR POP : NOP ;
: @EXECUTE PUSH : (DEF @R+ DUP .EXIT ?; : (GO XCHG (DROP ; : (&
@R+ : AND; NAND : NOT; DUP NAND EXIT ; : SIGN? (& ,< $8000 ,
: U- XEP : - (1- : NOT+ DUP NAND : + +2/ (DROP ; : 2* DUP + ;
: (LARY 2* : (WARY 2* : (BARY POP + ; : DXEP1+ DUP 1+ XEP ;
: (DZ#2 @R+ (DROP : (DZ#1 @R+ (DROP : (DZ#0  POP XCHG ; : I J ;
: (.CON @R+ (DROP @R+ EMIT EXIT ;
{ VARIABLES }
#DO CONST 13 TIMES     64 1L 1024 1K 16 1H 256 1B $8000 SGN
             $7C NPAD $E000 FIRST  $FD00 SBUF  2 2  9 BOOT 1 1
             $FF00 TBUF  $FE00 TIB
ZDO VALUE 23 TIMES
   _AX _BX _CX _DX _FR EOS SCRH `USE `PREV BLK ETIB `BASE
   XY XK L HOFS >LT< >CF< HDICT ENDH >NF< DFLTKEY `ROWS
ZDO VECTOR  7 TIMES   vNUM vEXE vNUM, vCOM v=: vOK vERR
ZDO ;VALUE  6 TIMES   CNTC RES LTIB H T SCR
:VALUE PERFORM ;  :VALUE vINIT ;  :VALUE KEY ;   0 QUAN Fbuf
:VALUE EMIT  ;CNTC 1+ ;
: ;SPC EX ,< =H SPACE #DO .CONST 12 TIMES  32 BL  '[ c[  '] c]
  '" c"  '. c.  7 bel 9 tab  13 cr 10 lf 8 bs  '- c-  '0 c0



{ BASE FUNCTIONS} : !+ PUSH !R+ POP ; : @+ PUSH @R+ POP ;
: 2/ 0 : AVG +2/ : NIP PUSH .POP ; : C@ @ : W>B (& ,< $FF ,
: 2SWAP CALL XEP THEN : -ROT CALL : USWAP XEP THEN : SWAP PUSH
: XPOP XCHG POP ; : 2DUP TWICE : OVER PUSH DUP XCHG POP ;
: 0>=; SIGN? : 0; EXIT ?; ; : 0<; SIGN? : 0<>; NOP ?; EXIT ;
: ABS DUP 0>=; : NEG (1- : NOT DUP NAND ;     : ;DROP EX DROP ;
: AND NAND NOT ;  : R>S 1+ : OVER- OVER - ; : (;GO @R+ XPSH ;
: 0?SKIP DUP IF : (CALL @R+ PUSH ;THEN : .SKIP DROP : SKIP @R+
   DROP ; : (OF OVER- .SKIP ?; (GO ; : ?SKIP DUP DROP ?; SKIP ;
: ;2- EX : 2- (1- : 1- (1- ; : 2+ (+ ,< 2 , : ;SWAP EX SWAP ;
: WITHIN OVER- U- : U< SWAP : U? NOT AVG : 0< SIGN? : 0<> IF
BEGIN ,< -1 CONST -1 >, : 0= UNTIL THEN ,< 0 CONST 0
: ;NIP EX NIP ; : OR NOT PUSH NOT POP NAND ; : RDROP POP (GO ;
         : NUP XEP DUP ; : ROT USWAP SWAP ; : ;2DROP EX 2DROP ;
: 2/ODD; ?EX :; ;SWAP : 2/MOD 0 +2/ : UODD XEP : ODD (& ,< 1 ,

{ MEMORY OPERATIONS } : < - 0< ; : = - 0= ; : TUCK DUP USWAP ;
: ..LOOPS XCHG POP : ..TIMES ;DROP : .TIMES ;DROP : TIMES  PUSH
XCHG : LOOPS FOR J EXECUTE NEXT .EXIT ; : .LOOPS XCHG POP
.TIMES ; : FX @R+ @R+ ! ; : D! !+ ! ; : D@ @+ : @SWAP @ SWAP ;
: USTR XEP : STR PUSH @R+ XPOP ; : USTR- : STR- ;SWAP @- ;
: OFF 0 : SWAP! SWAP ! ; : ON -1 SWAP! ; : (CSTR @+ (1- SWAP ;
: ITEMS@ DUP 2+ @SWAP : ITEMS? @+ @ - 2/ ; : TOP @ @- DROP ;
: ZST DUP 2+ @ SWAP! ; : UNW ;DROP : @H- ;H @- ; : !I J ! ;
: H@I J @ : W>H (& ,< $FF00 , : C@I J C@ ; : @I J @ ;
: C!+ PUSH : (C!R+ W>B H@I + !R+ POP 1- ; : C!- 1-DXEP
: C!  C!+ DROP ; : SUCSTR SWAP : UCSTR XEP : CSTR (CSTR W>B ;
: UCSTR- XEP : CSTR- ;SWAP : C@- 1-DXEP C@ ;
: NAME> CSTR + ; : D>NAME DUP : >NAME NAME> : 4+ (+ ,< 4 ,
: "+C! SWAP : C+"! DXEP NAME> !+ (1- : L"! J NOT+ J C! ;


{ MATH }
: A! PUSH XA EXIT ; : A@ XA I XA ;
: 1B* 1B : U* ;DROP : UM* A! : (UM* 0 TWICES +* +* +* +* ;
: U/ ;DROP : (A/MOD A! : (Z/MOD 0 : (/MOD TWICES -/ -/ -/ -/ ;
: W>BB 1B : U/MOD (A/MOD SWAP ; : BB>W 1B* SWAP W>B + ;
: UMOD ;DROP U/MOD ; : U16? 1H : UN? U/MOD SWAP 0; 1+ ;
: ;MAX 2DUP EX IF  XEP THEN DROP ; : UMAX ;MAX U< ; : UMIN ;MAX
: U>= U< 0= ; : MAX ;MAX < ; : 0SWAP 0 SWAP  ;
: DU+ DUP : U+ XEP + ;
: ;0>A 0 : ;>A XCHG XA EXECUTE XA EXIT ; : D2/ ;0>A +* ;
: D2* ;0>A -/ : U1- XEP 1- ; : UPC '` OVER U< 0; (& ,< $DF ,
: XOR PUSH DUP PUSH J NAND DUP POP NAND XCHG NAND POP NAND ;
: A-L XEP : I- J - ; : SRCA XEP : A+L XEP : I+ J + ;



{ NUMOUT & PRINT} : LB10 0SWAP : `2 lf U/ 0?SKIP  RECURSE 1+ ;
: 2ALIGNED 2 : ALIGNED ;H SKIP : ALIGN 1- SWAP 1- OR 1+ ; : (?S
   J POP POP NAME> 2 ALIGN PUSH PUSH ; : SPACES LOOPS SPACE ;
: 9>? tab OVER U< bel AND ; : ALFA 9>? + c0 + ;  : (" (?S ;;
: H. W>BB CALL : B. ;SPC THEN 1H U/MOD TWICE : DIG. ALFA EMIT ;
: . -IF TO c- NEG THEN : U. ;SPC : `1 lf U/MOD 0?SKIP RECURSE
DIG. ; : .UR OVER LB10 - SPACES `1 ; : ;[] TO c[ EX TO c] ;
: [ID] ;[] : ID. ;SPC : ". CSTR : TYPE ;DROP : ?TYPE LOOPS CSTR
: ?EMIT DUP BL < IF DROP '. THEN EMIT ; : (." (?S ". ;
: (A" (?S SWAP  DROP ?;  vERR ABORT ; UNW
: ;CR EX : CR TO cr  TO lf 0 TO CNTC ; : (OK ."_Ok" CR  .">" ;
: `TYPE EX SPACE 1H - 1H ;[] ?TYPE ; : DUMP U16? ;DROP LOOPS
: DU CR DUP H. SPACE `TYPE 1H LOOPS CSTR B. ;



{ ERRORS & ACCEPT }
: XY? 1K LTIB - ;
: @BNDS? @+ @ : BOUNDS? WITHIN 0= !"BOUNDS!" ;
: ;STK @BNDS? : ;@! @+ XCHG EXECUTE POP !- DROP ;
: ;??# EX : ??# 0= : ?? !"?" ;
: (ERR CR TBUF ID. ID. CR DFLTKEY TO KEY BLK 0; BLK TO SCR
  0 TO BLK XY? : >XY 1K 1- AND TO XY ;

: ACCEPT
       OVER + PUSH DUP BEGIN KEY CASE cr OF DUP XCHG DROP ENDOF
     bs OF  2DUP - IF 1- TO bs SPACE TO bs THEN  ENDOF
     DUP BL 1B WITHIN  IF DUP EMIT SWAP C!+ DUP THEN
  ;CASE DUP I =  UNTIL  OVER- EXIT ;



{ CHAR, FILE & BLOCK IO }
{ : (ACC IO (@ACC CSTR ; : RESET IO (@AB ; : (DE IO (@DE ;
HERE 1+ =: `D ' (IO CALL, $21CD , $C3 C, : (DOS IO `D REGS! ;
HERE 1+ =: `V ' (IO CALL, $10CD , $C3 C, : (VID IO `V REGS! ;
HERE 1+ =: `K ' (IO CALL, $16CD , $C3 C, : (KBD IO `K REGS! ; }

0#> C@ (IO : REGS! TO _FR TO _AX TO _BX TO _CX TO _DX ;
N: (DOS $21 , N: (VID $10 , =, (KBD $16 ,
' (DE ' EMIT T!        ' (BK ' KEY T!   : IO? _FR ODD !"IO?" ;

: XDROT XEP : D0ROT ROT :; : D0 0 0 ;
0#> @ (DOS ; N: Fseek $4200 ,  N: Fread $3F00 , =, Fwrite $4000
,  : `RW 1K UM* SCRH Fseek IO? 1K SCRH EX IO? ;
0#> @ D0ROT (DOS ;    N: Fopen  $3D02 , =, Fcreate $3C00 ,
0#> @ XDROT (DOS ;    =, Fclose $3E00 ,

{ MEMORY MOVE & COMPARE}
: `MOV1? 2/ODD; PUSH (CSTR (C!R+ ;  : `FIL1? 2/ODD; NUP C!+ ;
: `MOV1>? 2/ODD; UCSTR- C!- ; : >HERE H : M! NUP !+ : MOVM SWAP
: CMOVE ;2DROP : (CMOV `MOV1? LOOPS PUSH STR !R+ POP ;
: CMOVE> ;2DROP : (PUSHM `MOV1>? LOOPS USTR- !- ;
: >DICT ;T H STR : (MPUSH SRCA SWAP (PUSHM NIP ;
0#> C@ : FILL -ROT ;2DROP `FIL1? LOOPS NUP !+ ;    N: ERASE 0 ,
    N: BLANK BL ,  =, ONES -1 , : (S! DXEP NUP C!+ (CMOV NIP ;
: ONPLACE ;GO DXEP TWICE NUP THEN ;2DROP BEGIN 1- 2DUP U< 0;
   PUSH PUSH  J C@  I C@  J C!    POP  C!+ POP  AGAIN ; UNW
: >"! DXEP : >" OVER C@ 1+ CMOVE ; : "+! SUCSTR DXEP NAME> SWAP
 (CMOV DROP L"! ; : CORA DUP C@ 1+ : -TEXT FOR PUSH CSTR XCHG
 CSTR POP = IF CSWAP> NEXT PUSH THEN 2DROP POP 1+ ;
: >ZSTR CSTR SBUF : S! (S! SWAP  OFF ;
: ;File >ZSTR 1+ EX IO? _AX ;

{ COMPILER STUFF} : HERE H : R>T HOFS + ; : ;, EX : , ;H !+ ;
                                         : RLS> HERE SWAP! ;
: HP HERE  2+ ; : T>R HOFS - ; : MRK> H : Z, 0 , ;
: LATEST T : N>C NAME> @ ; : ;code POP : TOBE LATEST ! ;
: WCLARY 2 ALIGN : CLARY H OVER ERASE : ALLOT ;H + ;
: C, ;H C!+ ; : !T- ;T !- ; : CALL, $E8 : ,R C, HP - , ;
: \ ;LTIB 1- : L/ 1L NEG AND ;
: ;STR CSTR : ;MEM DU+ : ;0TI 0 : ;TI BLK XCHG LTIB PUSH ETIB
    PUSH PUSH CALL EX POP POP POP THEN TO BLK TO LTIB TO ETIB
: /BLK BLK 0; 0 TO ETIB ; : ;BLK 1K OVER ;TI ;
: `4 POP NOT J + : `3 NIP : 2EXIT POP .EXIT ;
: SCAN OVER PUSH PUSH FOR STR J - (IF `4 NEXT `3 ;
: BSCAN W>B OVER PUSH PUSH FOR CSTR J - (IF `4 NEXT `3 ;
: ;FND T AHEAD : ;FND2 BEGIN >NAME THEN PUSH C@I WHILE DUP J
     EXECUTE  POP REPEAT 0 2EXIT ;

{ BUFS }                               : FOPEN ;File Fopen ; 4
DUP DUP CONST `NBUFS BARY `FBUFS WARY `BUFS : WBLK `RW Fwrite ;
: RBLK `RW Fread ; : `@BUF `PREV 1K U* FIRST + ;
: ?BUF PUSH 0 `BUFS `NBUFS POP SCAN ;
0#> C@ `PREV `FBUFS C! ; N: DISCARD 0 , =, UPDATE -1 ,
: -BUF DISCARD -1 : `!BUF `PREV `BUFS ! ;
: `+BUF `USE 1+ `NBUFS 1- AND DUP TO `USE ; : !BUFS `NBUFS
LOOPS `+BUF TO `PREV : `?SAVE `PREV `FBUFS C@ 0; `@BUF `PREV
`BUFS @  WBLK DISCARD ; : FLUSH !BUFS : /BUFS `NBUFS LOOPS
`+BUF TO `PREV : `EMPTY-BUF -BUF : `/BUF `@BUF 1K ERASE ;
: `;ABLK /BLK 0 TO _FR XCHG PUSH J ?BUF EX RDROP `@BUF IO? ;
: BUFFER `;ABLK -IF ?BUF -IF DROP `+BUF THEN THEN TO `PREV
 `?SAVE `/BUF J `!BUF ;
: BLOCK `;ABLK -IF DROP J BUFFER J  RBLK ;THEN TO `PREV  ;


{ SEARCH & PARSE} : `XSC0 RDROP : INTIB ETIB LTIB A-L ;
: `XSC POP : `XSC2 1+ NIP DUP TO LTIB EXIT ;
: `BLSKIP J PUSH INTIB FOR CSTR J = (IF `XSC  NEXT `XSC2 ;
: `CSCAN J PUSH  INTIB FOR CSTR J - (IF `XSC  NEXT `XSC2 ;
: `SRC BLK 0; ETIB 0<>; BLK BLOCK 1K + TO ETIB ;
: TOKEN? ;??# [ : C@. DUP C@ ] : TOKEN BL
: WORD [ : >TBUF TBUF (S! '` ROT ! ]
: PARSE LTIB TO >LT< `SRC W>B DUP PUSH BL =
 IF `BLSKIP (IF `XSC0 THEN  INTIB DROP LTIB `CSCAN - EXIT ;
: AT' ;2- : TO' ;2- : ' ;??# : T? TOKEN? : FND ;FND J CORA
: `C 0<>; POP 2DROP POP DUP DUP TO >NF< EXIT ; : ,' ;, ' ;
>, BEGIN >NAME : DICT. C@. 1+ ?; AGAIN ; UNW : EDICT T DICT. ;
: FORGET ' TO H >NF< >NAME TO T ;
: FND2 T ;FND2 J CORA `C ; : FROM ' : C>N? ;FND J N>C - `C ;
: `(INIT >DICT AT vINIT NPAD DUP ACCEPT ;  ' `(INIT ' vINIT T!

















{ NUMBER PARSER}  : L? 1 LTIB U< ; : `DC@ INTIB DROP C@ ;   0#>
NUP CSTR ROT BSCAN 1+ DUP 0; NIP ; =, `NUM' ,T #$%' 2 ALIGNED
: EX0; LTIB 0<>; RDROP : LTIB- ;LTIB 1- ; 0#> @ : `BASE! 2- W>B
 2+ TO `BASE : L?; L? 0; ; N: `1H 16 , =, `BIN 2 ,
: `INI0 L? EXIT ?; : `INI ;RES `BASE! 0 ;
: DIGIT [ 0= DUP 0; DROP DUP `BASE U< ] UPC c0 - 9>? DUP 0;   -
 DUP lf U< ; : ``NUM L? EXIT ?; LTIB- `DC@ : `*+ ;RES `BASE U*
 + ; : `NCHAR DIGIT .EXIT ?; `*+ ;
0 WARY `NUMA >, `NCHAR `INI0 `1H `BIN ``NUM ,<
: ("NUM CSTR : (NUM ;MEM `INI lf TO `BASE [ RES LTIB ] EX0;
 `DC@ c- = IF L?; [ ;RES NEG ] BEGIN LTIB- THEN LTIB 0; `DC@
 `NUM' `NUMA @EXECUTE AGAIN ; : NUM? TOKEN? : >NUM? ("NUM ?? ;
\ `STATE  vNUM  vEXE
\  vNUM, vCOM


{ CREATE & FIND TOKENS}  : INC ;@! 1+ ; : DEC ;@! 1- ;
: =" c" WORD >ZSTR ; : =0, 0 : =, ;, : =H HERE : =: v=: ;
: (=: TOKEN? : (N3 0 !T- !T- TBUF C@. 1+ ;T (MPUSH NIP ;
  ' (=: VAL' v=: T!

: ,<T AT PERFORM FND  vNUM ?; : `INTER N>C vEXE ; { INTERPRET}
: `COM? DUP DEC FND2 IF N>C vCOM ;THEN vNUM, ;
: >,  AT PERFORM DUP INC  FND2 `COM? ?; `INTER ;  { COMPILER}
: SEVAL CSTR : EVAL ;MEM
: EVLP TOKEN C@. DROP ?; PERFORM RECURSE ;

HERE T' vINIT 4 + T! >, : KUKU F>AI 65 EMIT 55 EMIT 66 EMIT ,<T
 TO c[ TO c- TO c] BYE
: QUIT BEGIN vINIT EVAL AGAIN ; UNW


: +LOAD BLK + : LOAD DUP DROP ?; ;BLK EVLP ; : `-USE SCRH
1+ 0; SCRH Fclose : `/SCR -1 TO SCRH ; : USE/ `/SCR /BUFS ;
: USING TOKEN? : USED FLUSH `-USE FOPEN TO SCRH ;

: TO TO' EXECUTE ; : AT AT' EXECUTE ; : >NUM TOKEN? >NUM? ;
: BS, CSTR : S, ;DROP LOOPS CSTR C, ;
: " HERE : ," '" : ?, WORD : CSTR, CSTR : STR, ;H (S! DROP  ;
: M: '; : ?M: 0 =, ?, DOES>  SEVAL ; : (M: (?S SEVAL ;
: { '} PARSE 2DROP ; \ META (OK vOK. META (ERR vERR







{ MAKERS }
: `MKR =0, , EX ,' ; : `(: =H CALL EX @EXECUTE ;
: 2MKR `MKR , DOES> `(: : `W, THEN STR , ;
: 1MKR `MKR DOES> `(: ; : 3MKR `MKR , , DOES> `(: `W, `W, ;
: S+! XEP TUCK J STR +   SWAP CMOVE J : +! ;@! + ;
: `WITH POP ' ,<  0 VECTOR `DO  : WITHZ `WITH 0 `DO ;
: WITH' `WITH ' `DO ; : WITH# `WITH >NUM `DO ;
: WITH `WITH `DO ; : WITH+ `WITH DUP `DO : OVER+ OVER + ;

{
: `AT@ ' TO `DO POP ; : ZDO `AT@ 0 `DO ; : 'DO `AT@ ' `DO ;
: #DO `AT@ >NUM `DO ; : DO `AT@ `DO ; : +DO `AT@ DUP `DO
: OVER+ OVER + ;
}


{ WORDS}
: `ROWS! bs TO `ROWS ;
: `EOL? C@ CNTC + ,< 80 5 - >, #, U< 0<>;
: `NEWLINE ;CR `ROWS 1- DUP TO `ROWS 0<>; DFLTKEY 27 = `ROWS!
 ?; RDROP POP 2EXIT ;
: WORDS CR ;DROP `ROWS! ;FND DROP J `EOL? J N>C H. J ". CNTC
 65 U< `NEWLINE ?; 13 : ?ALIGN CNTC OVER UMOD - SPACES ;

{ LIST .BLOCK .LINE EXI?T EXIST SAME? }
: LIST DUP TO SCR BLOCK
: .BLOCK ;DROP ."SCR#_" SCR . CR 1H LOOPS CR 1H J -
: .LINE 4 .UR SPACE 1L ;[] ?TYPE ;
: EXI?T 0<>; :; : EXIST? T? SWAP TO >CF< ;
: SAME? TBUF EXIST? 0; TBUF [ID] : ?BLK. BLK 0; : BLK. BLK . ;


{ TARGET COMPILER STUFF }
: `EG T EDICT OVER- >HERE EX
     H STR HDICT ?SKIP FIRST (MPUSH TO   T ;
0#> C@ HDICT + ; N:  TL 2 , N: TH 4 , =, TD 6 ,
: ;TD TD @ EX TD ! ; : !TD- ;TD !- ;
: ;<D> CALL EX : <D> THEN T TD @ TO T TD ! ;
: HIPUSH `EG PUSH HDICT DUP ?SKIP FIRST 10 I+ - DUP TO HDICT
!+ XCHG 0 !R+ TD 2+ DUP !R+ + DUP POP ! OFF ;
: HIDROP HDICT 0; `EG HDICT @ TO HDICT ;
: <H> TL  D@ H HOFS TL D! TO HOFS TO H ;
0#> PUSH @R+ TO HOFS @R+ TO H POP @ TO T ;
1#> PUSH HOFS !R+  H !R+ T POP ! ;
>, (VAR3 ,< =, MARK! =, MARK@ Z, Z, Z,



{ STACKS }
' (VAR  1#> DUP @+ ;STK !+ ; 2#> DUP STR 2- SWAP ;STK @- ;
3PICK 3PICK 3PICK  20 STACK! HANDLES 3PICK 3PICK 3PICK
  20 STACK! CSTK>    20 STACK! <CSTK
: `;STK> CSTK> EX TO CSTK> ;  : CSWAP> `;STK> `;STK> SWAP ;
: `;<STK <CSTK EX TO <CSTK ;  : <CSWAP `;<STK `;<STK SWAP ;
: ZSTK AT CSTK> ZST  AT <CSTK ZST ;;

: `M> TO CSTK> : `;E EX : END! HERE TO ENDH ; : `R> CSTK> `;E ;
: `<M TO <CSTK `;E ;  : `<R  <CSTK `;E ;   : <RELS `<R , ;
: MARK> MRK> `M> ;;  : MARK>< MARK> : <MARK HERE `<M ;;
: <RELS> <RELS : RELS> `R> RLS> ;




{ MACROSES }
0#> SEVAL ; N: :J "J"   N: :I+ "I+"     N: :I-    "I-"
N: :(JUMP "(JUMP"   N: :(;GO  "(;GO"    N: :(IF   "(IF"
N: :(RET  "(;"      N: :(LIT  "(LIT"    N: :(CON  "(CON"
N: :(."   "(."""    N: :(AB   "(A"""    N: :("    "("""
N: :(VAR  "(VAR"    N: :(VAR2 "(VAR2"   N: :(VAR3 "(VAR3"
N: :(SET  "(SET"    N: :(SET2 "(SET2"   N: :(DEF  "(DEF"
N: :(BARY "(BARY"   N: :(WARY "(WARY"   N: :(LARY "(LARY"
N: :-IF   "1+_IF-"  N: :POP   "POP"     N: :CODE  ";code"
N: :(DZ#0 "(DZ#0"   N: :(DZ#1 "(DZ#1"   N: :(DZ#2 "(DZ#2"
N: :(DO>  "(DO>"    N: :(DO<  "(DO<"    N: :RDROP "RDROP"
N: :DROP  "DROP"    N: :PUSH  "PUSH"    N: :(OF   "(OF"
N: :(DROP "IF_THEN" N: :(1- "IF-_THEN"  N: :EX    "EX"
N: :(IF-  "(IF-"  N: :TWICE "CALL_THEN" DROP


: `(DO XCHG PUSH - XCHG @ PUSH ; : (DO< DUP `(DO ;
: (DO> OVER 1- `(DO ; : -ROT;DROP -ROT EX DROP ;
0 VALUE `5 : `T  POP `5 XCHG TO `5 PUSH : R>DO 1+ SWAP ;
: QQ DO> LOOP ;
: ;RNG> `T DO> IND> `5 EXECUTE LOOP : `T2 POP TO `5 ;
: ;RNG< `T DO< IND< `5 EXECUTE LOOP `T2 ; : `KMOVE 1K CMOVE ;
: RBLOCKS -ROT;DROP ;RNG> BLOCK OVER `KMOVE : 1K+ 1K + ;
: WBLOCKS -ROT;DROP ;RNG> NUP BLOCK `KMOVE UPDATE 1K+ ; : THRU
;RNG> LOAD ; : +THRU ;RNG> +LOAD ; : CHARS ;RNG> DUP EMIT . ;

: : ZSTK =H >, ;
$221 =: FOUND? ESQ HIDE ;` ESQ $235 =: ;`
HERE 'AT H T!
      DDDDDDDDDDDDDDDDD
TSAVE PIF.COM

















