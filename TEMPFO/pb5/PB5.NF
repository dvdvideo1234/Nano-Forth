















M: TWICE` CALL THEN;   : N: DUP =, ; : U1- XEP 1- ;
: STR- 1- XEP 1+ ;
INCLUDE PB5_BODY
: TT ;  ' BLK. TO vLOAD
: SRCA1 ;











































































































































































































































































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

















