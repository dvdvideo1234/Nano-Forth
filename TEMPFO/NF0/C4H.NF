$13A =: HERE    $201 =: SWAP    $3A9 =: (FND    $48D =: DOES#
$1D7 =: @R+ $259 =: , $146 =: LTIB $203 =: DROP $1EA =: DUP
$10C =: EMIT $27D =: =, $24B =: SKIP $29F =: PARSE $12E =: BYE
$4E2 =, 2+ $3FE =, AND $4EB =, NOT $4EA =, NEG  $22F =: :
$209 =: + $401 =, XOR HERE $4B4B , $F0EB , DUP =, 2- 1 + =, 1-
$1CE =, U< $DF2B , $E4EB ,   HERE 2+ =, 0< $E3D1 , $DEEB ,
$462 =, 2DROP $461 =, 2DROP; $4E3 =, 1+ $3EC =, ROT $235 =: ;`
: -ROT ROT ROT ; $48B =: >, $1FD =: ,<` $2DA =, :` >, SKIP : ,<
: { '} PARSE 2DROP; ,< : NOP ; $299 =: TOKN? $2BB =: ??# $257
 =: ;, $14C =: DICT : TOKEN? LTIB DROP TOKN? ; $441 =, ;?# >,
 ??# NOP ; : `,X =, , : ,' ;, : ' ;?# : T? TOKEN? : Afnd DICT
: Dfnd HERE SWAP (FND ; : ,X: $2DF `,X ; : (,X $2DA `,X ; : (#,
@R+ , ; : HP HERE 2+ ; $470 ,X: DEFER , $40C ,X: CONST , $40E
,X: CREATE NOP : 'TO ' 2+ ; $1F8 =: @ ' { =: {` : 'AT 'TO 2+ ;
: TO` 'TO , ; : @' ' @ ; ' ,' =: C:` : CODE: HP =, ;

$41B (,X `V! , $23B =: ,#` $1C4 =: >DICT 8 CONST bs 13 CONST cr
$40B ,X: VALUE `V!   $46F ,X: VECTOR `V!   $40E ,X: VAR ,
: `Q $41A , $40E : D, , , ; $40A ,X: QUAN `Q $46E ,X: VQUAN `Q
64 CONST 1L     1024 CONST 1K   0 VALUE BLK     0 VECTOR vLOAD
0 VALUE >LT<    0 VALUE SCR     0 VQUAN KEY     0 VALUE XY
$29D =: WORD    $219 =: CSTR    $273 =: ;HERE   $37A =: (S!
$1AC =: DROP;   $152 =: CNTC    $1F2 =: LIT
$253 =: POP     $3E2 =: !       $424 =: C!+     $207 =: -
$1E5 =: XCHG    $47F =: EXECUTE $483 =: EXEC    $4EF =: 0=
: ," '" : ?, WORD : CSTR, CSTR : STR, ;HERE (S! DROP; ,<
: NAME> CSTR + ; : D>NAME DUP : >NAME NAME> 2+ NOP ;
: RECURSE` ;, : LATEST DICT : N>C NAME> @ ; : ;code POP
: TOBE LATEST ! ; : 2-DXEP 1- : 1-DXEP 1- : DXEP DUP : XEP XCHG
EXECUTE POP ; : C, ;HERE C!+ ; : @H- ;HERE : @- 2-DXEP @ ;
$11C =: vERR  'TO >LT< 'AT TOKEN? ! $114 =: ACCEPT 0 VALUE XK

$269 =: NUM?  $255 =: NIP;    $20B =: STR     $1A8 =: ;DROP
$251 =: EX      $205 =: OVER    $194 =: (A"  $194 (,X A"` ,"
: `DOES >, @H- HERE XEP : CALL, $E8 : ,R C, HP - , ;
DOES# (,X 0#> `DOES DOES# 1- (,X 1#> `DOES : ;2DROP EX 2DROP;
,< DOES# 2- (,X 2#> `DOES     : DOES>` (#, ;code 0#> DROP; ,<
: META ' : TO! 'TO ! ; : TO@ 'TO @ ; : X:` ' EXEC ; : TO 'TO
 EXEC ; : AT` 'AT , ; : AT 'AT EXEC ;  $118 =: vOK. $12C =: 0
@' DUP =, U/MOD  $C933 , $9291 , $F3F7 , $9193 , $C3 C,
: 2/ #2 : U/ U/MOD NIP; ,< : UMOD U/MOD DROP; ,< : 2* DUP + ;
$44B =, UM* $F793 , $92E2 , $C393 , : 1K* 1K : U* UM* DROP; ,<
  @' DUP =, SM*  $F793 , $92EA , $C393 ,  @' STR =, (BK $DB31 ,
$CD93 , $816 , $74C0 , $3002 , $93E4 , $C3 C, : ;1+ EX 1+ ;
$44B =, ?BL. $FB80 , $7320 , $B302 , $C32E , : !- 2-DXEP ! ;
: @+ STR SWAP ;  : U- XEP - ; : R>S 1+ : OVER- OVER - ;
: ;CR EX : CR cr EMIT 10 EMIT 0 TO CNTC ;  META CR vOK.

$444 =: PUSH    $215 =: C@      $4B1 =: (FOR    $241 =: J
$245 =: (NEXT   $247 =: RDROP   16 CONST 1H     $4C8 =: (IF
: WITHIN OVER- U- U< ; : ZST DUP 2+ @ : SWAP! SWAP ! ; : @BNDS?
@+ @ : BOUNDS? WITHIN 0= A" BOUNDS!" ; : TOP @ @- DROP; ,<
: ;STK @BNDS? : ;@! @+ XCHG EXECUTE POP !- DROP; ,<
: ITEMS@ DUP 2+ @ SWAP : ITEMS? @+ @ - 2/ ; : <MRK` HERE ;
: <RLS` , ; : MRK>` HERE : Z, 0 , ; : RLS>` HERE SWAP! ;
: >NUM TOKEN? NUM? ; : 0<; 0< : 0<>; (IF TO NOP : EXIT RDROP ;
: 0>=; 0< : 0; (IF TO EXIT ; : (CALL @R+ PUSH ;
: ..TIMES ;DROP : .TIMES ;DROP : TIMES PUSH XCHG : LOOPS (FOR
 MRK> <MRK J EXECUTE (NEXT <RLS RLS> RDROP ; : NUP XEP DUP ;
0#> C@ : FILL -ROT ;2DROP LOOPS NUP C!+ ;
DUP =, ERASE 0 C, =, BLANK 32 C, : TUCK DUP : USWAP XEP SWAP ;
: [], HERE DUP PUSH 2- DUP =: EXEC POP - : CLARY HERE OVER
 ERASE  : ALLOT ;HERE + ;  : U16? 1H : UN? U/MOD SWAP 0; 1+ ;

$140 =: ETIB    $42A =: !+      $249 =: (JUMP   $1DD =: (?S
$130 =: BL      $152 =: CNTC    $128 =: TBUF    $158 =: STATE
: `MBLK 1K* $100 + ; ' `MBLK DEFER BLOCK : XY? 1K LTIB - ;
: `SRC ETIB BLK 0; DUP 0<>; DROP BLK BLOCK 1K + DUP TO ETIB ;
: ;B_TI 1K OVER : ;TI BLK XCHG LTIB PUSH ETIB PUSH PUSH (CALL
 MRK> EX POP POP POP RLS> TO BLK TO LTIB TO ETIB : /BLK BLK 0;
 0 TO ETIB ; : +LOAD BLK + : LOAD DUP ??# ;B_TI vLOAD (JUMP ,<
$182 , : ;0TI 0 (JUMP TO ;TI ,< : DU+ DUP : U+ XEP + ; : M: ';
: ?M: CREATE ?, DOES> : SEVAL CSTR : MEVAL DU+ ;0TI (JUMP ,<
 $182 ,  : ;SPC EX : SPACE BL EMIT ; : (" (?S ; ' (" (,X "` ,"
: (." (?S : ". CSTR : TYPE ;DROP : ?TYPE LOOPS CSTR ?BL. EMIT ;
: TD. DICT : ID. ;SPC ". ; ' (." (,X ."` ," : 2DUP OVER OVER ;
: (ERR CR TBUF ID. STATE ID. CR LIT (BK TO KEY BLK 0; BLK TO
SCR 0 TO BLK XY? : >XY 1K 1- AND TO XY ; META (ERR vERR
$110 =: SOURCE  META `SRC SOURCE

$36D =: (MPUSH  $27F =: =H  : = XOR 0= ; $24F =: ; $39D =: (DE
$487 =: @EXEC   0 VECTOR `DO    1 CONST 1  256 CONST 1B
: (;GO @R+ XCHG PUSH ; ' =H =: =H`  : []: $2DA =, , (#, [], ;
: (!R @R+ : I+! J + ! ; : (@R @R+ : I+@ J + @ ; : ;+ EX + ;
: ALIGNED ;HERE : ALIGN ;+ DUP : ODD 1 AND ;
: CMOVE> SWAP OVER + (MPUSH DROP ;
: CMOVE ;2DROP LOOPS PUSH CSTR POP C!+ ;
: `(: C: =H (CALL MRK> EX @EXEC ; : `MKR C: =H Z, , EX ,' ;
: 2MKR `MKR , DOES> `(: : W, RLS> STR , ;
: 1MKR `MKR DOES> `(: ; : 3MKR `MKR , , DOES> `(: W, W, ;
: `CLRY XEP RLS>` RLS>` CLARY ; : STK+, 2* MRK>` MRK>` MRK>`
`CLRY RLS>` ; : STK, SWAP DUP , , , ; $40E 1#> DUP @+ ;STK !+ ;
2#> DUP STR 2- SWAP ;STK @- ;  3MKR STACK+ STK+,
       ' STACK+ 8 + @- @- @- DROP 3MKR STACK STK,
$7C CONST NPAD  $E000 CONST FIRST  : VARIABLE 0 VAR ;

: `AT@ ' TO `DO POP ; : #DO `AT@ >NUM `DO ; : DO `AT@ `DO ;
: +DO `AT@ DUP `DO : OVER+ OVER + ; : ZDO `AT@ 0 `DO ;
: 'DO `AT@ ' `DO ; : D! !+ ! ; : D@ @+ @ SWAP ;
#DO []: 3 TIMES  $4AB WARY $4AD BARY  $4A9 LARY
$5C NPAD STACK HANDLES     20 STACK+ CSTK> 20 STACK+ <CSTK
: `;STK> CSTK> EX TO CSTK> ;    : `;<STK <CSTK EX TO <CSTK ;
: STK? AT <CSTK ITEMS? AT CSTK> ITEMS? + ;
' :  : : ,< , >, : ZCSTK AT CSTK> ZST  AT <CSTK ZST ;
: (OF OVER XOR  @R+ SWAP (IF MRK> XCHG SKIP RLS> DROP DROP ;
: AHEAD` (#, (JUMP : MARK>` MRK>` TO CSTK> ;
: `THEN EX : THEN` CSTK> RLS>` ; : ;GO` (#, (;GO MARK>` ;
: CSWAP>` `;STK> `;STK> SWAP ; : <CSWAP` `;<STK `;<STK SWAP ;
: ,T BL ?, ;  : " HERE ," ;  : CASE` 0 TO CSTK> ;
: IF` (#, (IF MARK>` ; : [` : CALL`  (#, (CALL MARK>` ;
: NEXT` `THEN   : <NEXT`  (#, (NEXT : <RELEASE` <CSTK , ;

: FOR` (#, (FOR : MARK><` MARK>` : BEGIN` HERE TO <CSTK ;
: FOR>` (#, PUSH BEGIN` ; : ELSE` AHEAD` CSWAP>` THEN` ;
' ELSE` =: ENDOF` : OF` (#, (OF MARK>` ;
: REPEAT` `THEN : AGAIN` (#, (JUMP <RELEASE` ;
: UNTIL` (#, (IF <RELEASE` ;  ' IF` =: WHILE` : ;CASE` (#, DROP
  AHEAD BEGIN RLS>` THEN CSTK> DUP 0= UNTIL DROP ;
                              M: -IF` DUP 0< IF;
' 2+ VECTOR vTOC>. : `:=? @ LIT ,< @' Z, , >, = ;
' `:=? VECTOR vIS:? : ;;` (#, C: ; STK? 0<>; ,<` ;
: `x??x EX ??# : `(@H, @H- vTOC>. TO <CSTK ;
: `?? `x??x : `H@:? HERE @- DROP vIS:? ;  : ]` : ;THEN` `THEN
: ;` `H@:? ;;` 0; @H- DROP `(@H, AGAIN` ;    : ?;` `?? UNTIL` ;
: :;` `?? (#, (;GO <RELEASE` ; : ID-. CSTR  1- ;SPC TYPE ;
 @' (DE =, (BE  $3196 , $B4DB , $CD0E , $9610 , $C3 C,
VARIABLE @HD Z, Z, : MARK@ @HD : MK@ 2+ D@ TO HERE TO DICT ;

: MARK! @HD : MK! 2+ DICT HERE ROT D! ;
: I- J - ; : I J ; : C@I J C@ ; : (TYP N>C @ ; : CORA DUP C@ 1+
: -TEXT FOR PUSH CSTR XCHG CSTR POP = IF CSWAP> NEXT -1 PUSH
 THEN 2DROP POP 1+ ; : ;FND DICT AHEAD : ;FND2 BEGIN >NAME THEN
PUSH C@I WHILE DUP J EXECUTE POP REPEAT 0 : EXIT2 RDROP EXIT ;
: FROM ' : C>N? ;FND J N>C - : `C 0<>; POP 2DROP POP DUP EXIT ;
: -FIND TOKEN? : FND  ;FND J CORA `C ; : I+ J + ; 0 VALUE `
: `(DO< DUP XCHG PUSH - XCHG @ PUSH ; : IND<` (#, J (#, I+ ;;
: `(DO> OVER 1- (JUMP ,< 'AT `(DO< , : IND>` (#, J (#, I- ;;
: DO>` (#, `(DO> MARK><` ; : DO<` (#, `(DO< MARK><` ;
: LOOP` THEN` <NEXT` (#, RDROP ;
: `(RNG: C: : DOES> POP ` PUSH TO ` PUSH 1+ SWAP ;
`(RNG: ;RNG> DO> IND> ` EXECUTE LOOP : `XP! POP TO ` ;
`(RNG: ;RNG< DO< IND< ` EXECUTE LOOP `XP! ;
: THRU ;RNG> LOAD ; : +THRU ;RNG> +LOAD ; : CHARS ;RNG> EMIT ;

: `1 J SKIP =H `2 POP  NOT RDROP POP + NIP; ,< : W>B 255 AND ;
: SCAN      OVER PUSH PUSH FOR STR  J XOR (IF `2 NEXT `1 ;
: BSCAN W>B OVER PUSH PUSH FOR CSTR J XOR (IF `2 NEXT `1 ;
: (AC  OVER + PUSH DUP BEGIN KEY CASE cr OF DUP XCHG DROP ENDOF
     bs OF  2DUP - IF 1- bs EMIT SPACE bs EMIT THEN  ENDOF
     DUP BL 1B WITHIN  IF DUP EMIT SWAP C!+ DUP THEN
  ;CASE DUP I =  UNTIL RDROP OVER - 1 : SPACES LOOPS SPACE ;
' (BK TO KEY      META (AC ACCEPT
: "BSCAN CREATE DOES> : B>IN" PUSH XCHG CSTR POP BSCAN 1+ ;
=H `S>UD!  HERE 5 + =: `FIXA #DO C, 27 TIMES
3 $F9 $AF $AF $C3 $8B $35 $8A $17 $32 $F6 $F7 $D2 $03 $D7 $89
   $16 $A5 $A5 $BA $02 $00 $01 $55 $02 $41 $C3
HERE 2+ DUP 12 - !  0 CONST >NF<             : OFF 0 SWAP! ;
: S+! XEP TUCK J STR + SWAP CMOVE J : +! ;@! + ;


CREATE `EMPTY 0 ,  : `FIX1 ;HERE XEP TO HERE CALL, ;
: `FIXDI  0 HERE ! [ HERE STR >DICT ] ;DROP ;FND DROP J >NAME
 TO DICT J D>NAME OVER- HERE S+! `EMPTY 2 ROT S+! DROP ;
$3C4 =: `P2  $3B6 =: `P1  ' >NAME 6 + =: `P3 : `LIT2 @R+ @R+ ;
: `FIX_D `FIXDI `LIT2 `S>UD! `P1 `FIX1 `LIT2 `FIXA `P2 `FIX1
  `LIT2 2+ `P3 ! LIT `EMPTY TO HERE
 [ NAME> !+  OFF  TBUF D>NAME OVER- ] POP  $28B 14 CMOVE ;
`FIX_D
: ;LTIB LTIB EX TO LTIB ; : LTIB- ;LTIB 1- ;
: \ ;LTIB 1- : L/ 1L NEG AND ; ' \ =: \`
\ $3B6:  CALL : $03 $F9 $AF $AF $C3
\ $3B6 : 03 F9 AF -- NOW
\ $3C4:  CALL : $8B $35 $8A $17 $32 $F6 $F7 $D2 $03 $D7 $89
\ $16 $A5 $A5 $BA $02 $00 $01 $55 $02 $41 $C3
\ 3C4: 8B 35 41--NOW

: D0 0 0 ;  : (OK ."  Ok" CR ." >" ; META (OK vOK.
10 CONST lf   ' TOKEN? VECTOR vTOK?   ' vTOK? $289 !
: W>BB 1B U/MOD ; : 1B* 1B U* ; : BB>W 1B* SWAP W>B XOR ;
: 9>? 9 OVER U< 7 AND ; : ALPHA 9>? + '0 + ;  : 0SWAP 0 SWAP ;
: OR OVER NOT AND XOR ; : NIP NIP; ,<
$4B8 =: 0?SKIP  $134 =: vINIT   $212 =: .C@     $1FF =: 3+
: W+!HERE HERE : W+! DUP PUSH STR + ! 2 POP +! ;
: EDICT " =:" Afnd ??# DROP >NF< >NAME 1+ ;
: FORGET ' TO HERE >NF< >NAME TO DICT ;
0 VALUE REG   ' REG 2+ 2+ CONST `REG \ 03 DA 8B D3 D1 DB C3
 @' DUP =, +2/ $DA03 , $D38B , $DBD1 , $C3 C,
 @' DUP =, +* \ F6 C2 01 74 04 03 1E AA AA D1 DB D1 DA C3
  $C2F6 , $7401 , $304 , $1E C, `REG , $DBD1 , $DAD1 , $C3 C,
@' DUP =, -/ \ D1 E2 D1 D3 8B 0E AA AA 3B D9 72 03 2B D9 42 C3
  $E2D1 , $D3D1 , $E8B , `REG , $D93B , $372 , $D92B , $C342 ,

: ;MAX 2DUP EX IF  XEP THEN DROP ; : UMAX ;MAX U< ;
: UMIN ;MAX : U>= U< 0= ; : MAX ;MAX : < - 0< ;  : <> = 0= ;
: PRUNE EDICT HERE DUP OFF [ SWAP TO DICT STR >DICT ] ;DROP
 ;FND J N>C SWAP U< 0; J 1+ C@ '` - 0;
   J  D>NAME OVER-  HERE S+! DROP ;
{ : PRUNE HERE  0 HERE ! [ HERE STR >DICT TO HERE ] ;DROP
 ;FND J >NAME TO DICT J N>C SWAP U< 0; J 1+ C@ '` - 0;
   J  D>NAME OVER-  HERE S+! DROP ; }

: C!- 1-DXEP : C! C!+ DROP; ,< : TWICE  PUSH J XCHG ;
: ;[] '[ EMIT EX '] EMIT ; : [ID] ;SPC ;[] ". ;
: TILL FROM XEP : `UPPER? U< 0= A" A WORD MUST BE UPPER";
: WORDSUP 2DUP `UPPER? >NAME DICT -ROT
: ONPLACE ;GO DXEP TWICE NUP THEN ;2DROP BEGIN 1- 2DUP U< 0;
     PUSH PUSH  J C@  I C@  J C!    POP  C!+ POP  AGAIN ,<

 34 ALLOT HERE CONST `BUF#   10 VALUE `BASE  0 VALUE `HLD
: ` DUP 0< 0; NEG EX '- : HOLD `HLD C!- TO `HLD ;
: <# `BUF# TO `HLD ; : BLHS LOOPS : B# BL HOLD ;
: ;<#> <# TO `BASE EX CALL - BLHS
: #> DROP `HLD THEN `BUF# `HLD - ; : #.>S ;<#> B# DXEP
: N# LOOPS : # `BASE U/MOD SWAP ALPHA HOLD ; : `1 B# ?; ;
: .R#>S ;<#> SWAP ` SWAP : U_S# 0 MAX 33 UMIN XEP J `1
: S# BEGIN # DUP 0= UNTIL ; : U.R>S lf : U.R#>S ;<#> U_S# ;
: .STACK ;DROP ITEMS@ LOOPS STR
: . 0 : .R lf : .R# .R#>S TYPE ;
0#> C@ 1H #.>S TYPE ; DUP =, H. 4 C, DUP =, B. 2 C, =, 1H. 1 C,
: U. 0 : U.R lf : U.R# U.R#>S TYPE ;
: %. 16 : %.L 2 : #.L #.>S TYPE ;



0 VALUE `ROWS   : `ROWS! bs TO `ROWS ;
: `EOL? C@ CNTC + ,< 80 5 - >, #, U< 0<>;
: `NEWLINE  ;CR `ROWS 1- DUP TO `ROWS 0<>;
     (BK 27  = `ROWS! ?; RDROP POP EXIT2 ;
: WORDS CR ;DROP `ROWS! ;FND DROP
          J `EOL? J N>C H. J ". CNTC 65  U< `NEWLINE ?; 13
: ?ALIGN CNTC { : ALI-N} OVER UMOD - SPACES ;

 0 VALUE SPTRTOP  0 VALUE SPTR : ;SPTR  SPTR EX TO SPTR ;
: S! { ADR LEN NEWADR -- } OVER PUSH C!+ POP CMOVE ;
: >S! CSTR : >S ;SPTR OVER PUSH (MPUSH XCHG POP  C!- ;
: SPTRTOP? SPTRTOP DICT <>  SPTR SPTRTOP U< 0=  OR  0;
  DICT DUP TO SPTRTOP TO SPTR TWICE  D0 >S ;
: S> SPTR : SDROP ;SPTR CSTR + ;


: SUCSTR SWAP : UCSTR XEP CSTR ; 0 VALUE `SBUF VARIABLE `CBUF
: `U"R! XEP `SBUF : "! DXEP
: >"   { SRC DST --           } OVER C@ 1+ CMOVE ; { PLACE}
: S>"  { ADR LEN -- >STR      } `SBUF
: S>"! { ADR LEN >STR -- >STR } DXEP C! J CSTR CMOVE ;
: C>"  { CHAR -- >STR         } `CBUF
: C>"! { CHAR >STR -- >STR    } DXEP 1+ C! 1 J C! ;
: "+C! { >STR CHAR -- >STR    }  C>"
: "+!  { >STR STR -- >STR     } CSTR
: "+S! { >STR ADR LEN -- >STR}  ROT DXEP C@ TUCK + 255 UMIN DUP
         J C! SWAP - J CSTR + OVER - SWAP CMOVE ;
: +" SWAP : "+ { STRA STRB -- >STR } `U"R! "+! ;
: AUTO { NAME -- AUTO\NAME.CF} " AUTO\"  +"  " .CF" "+! ;
{ SXGFHFDGHDF }


0 VALUE >CF< : EXI?T (;GO TO 0<>; : EXIST? T? SWAP TO >CF< ;
: SAME? TBUF EXIST? 0; TBUF [ID] : ?BLK. BLK 0; : BLK. BLK . ;
' SAME? TO vTOK?

: LIST DUP TO SCR BLOCK
: .BLOCK  ;DROP ." SCR# " SCR . CR 1H LOOPS CR 1H  J -
: .LINE 4 .R SPACE 1L ;[] ?TYPE ;
: INDEX ;RNG> DUP BLOCK CR SWAP ;DROP .LINE ;

: `H ." `$" H. ;
: `CN 2- C>N?  : `N  EXIT ?; POP ID.   ID. EXIT ;
: `TO. `CN ,< ,T TO   : `AT. `CN ,< ,T AT
: ?ID.   C>N? 0= ID. ?; `TO. `AT. 2+ 2+ `H ;



: .ALL ;2DROP ;FND J (TYP : >PRINT = : >PRT? 0; : JID J ID. ;
: `? J C@ - DUP 0< 0; RDROP : `SRCH; 2DROP 0 EXIT ; : IN-STR>
SUCSTR : SRCH> PUSH `? FOR> DUP J CSTR -TEXT EXIT2 ?; 1+ <NEXT
DUP `SRCH; ; : <IN-STR SUCSTR : <SRCH PUSH `? DU+ FOR> DUP J
CSTR -TEXT EXIT2 ?; 1- <NEXT DUP `SRCH; ;
0 VALUE L  "BSCAN `Ctbl ,T "^~_ : PK: C: : DOES> TO XK ;HERE
 XEP DXEP TO HERE 0 C, CSTR TO L XK EXECUTE : /PK HERE J NOT +
 J C! ; PK: "UNPACK L ;DROP LOOPS CSTR DUP 128 AND IF 128 -
 [ '~ C, ] THEN [ L C, ] DUP TO L `Ctbl IF '" C, ;THEN BL L =
 IF '_ TO L ;THEN L BL U< IF '^ C, '@ L + TO L THEN ;
: `SRC  CSTR L 1- TO L ; : `UN ;DROP : C@H- ;HERE : C@- 1-DXEP
 C@ ; : `^ `UN L 0; `SRC 31 AND C, ; : `" `UN L 0; `SRC C, ;
: `~ `UN C@H- 128 XOR C, ; : `_ `UN BL C, ; 0 WARY `tbl >, NOP
 `" `^ `~ `_ ,<
PK: "PACK ;DROP BEGIN L 0; `SRC DUP C, `Ctbl `tbl @EXEC AGAIN ;

\ : B>N? ;FND J  N>C 2+ @ - 0<>;   J (TYP #TARGET - `C ;
\ : `H ." `$" H. ;
: `6N  PUSH PUSH PUSH  CALL  POP POP POP
: `N3  THEN  SPACE 3 LOOPS ROT DUP H. ;
\ : T?ID. DUP 0< OVER 2* RANGE? AND IF 2*  THEN
\ : ?ID.   C>N? 0= ID. ?; `TO. `AT. 2+ 2+ `H ;
\        B>N? `H ?; CSTR 1- ;SPC    TYPE ;
: SHN CR \ S. R.
         POP J H. PUSH J H. I H. `6N I @ ?ID. KEY 17 =
      IF A" /SHN" THEN ;;
: .CODE ;2DROP ;FND DROP J N>C @+ >PRINT ;
: .WORDS ;2DROP ;FND DUP >PRINT ;
: .NAMES ;2DROP ;FND J IN-STR>  >PRT? ;
: HIDE -FIND ??# 1+ '` : CSWAP! SWAP C! ;
: HIDE-TEST -FIND IF ID. ; THEN DROP ;

0 VALUE HDICT  : >HERE DUP HERE !+ SWAP CMOVE ;
: `EDGE HDICT DUP 0<>; DROP FIRST ; : DICL@ `EDGE DICT - ;
: `;EDGE DICT DICL@ >HERE    EX HERE STR `EDGE (MPUSH TO DICT ;
: HIPUSH `;EDGE PUSH HDICT `EDGE POP 2+ - DUP TO HDICT !+ ;
: HIDROP HDICT 0; `;EDGE HDICT @ TO HDICT ; 256 HIPUSH TO `SBUF
: HI. FIRST `EDGE - U. ;  : DICT. DICL@ . ;










{ IO (DOS (VID (KBD } 0 QUAN Fbuf
ZDO VALUE 6 TIMES  _AX _BX _CX _DX _FR  EOS
CODE: (IO  $1E88 , HERE 12 + , $9456 ,  $595B , $945F , $9297 ,
  $CD57 , $5F21 , $9497 , $5152 , $5753 , $949C ,
 @' 2DROP; $E9 ,R   : IO? _FR ODD A" :IO?" ;
0#> C@ (IO TO _FR TO _AX TO _BX TO _CX TO _DX ;
  DUP =, (DOS $21 C,  DUP =, (VID $10 C,  =, (KBD $16 C,
: HOME D0 : @XY BB>W D0 $200 (VID ;
0#> @ (DOS ;    DUP =, Fopen $3D02 ,   DUP =, Fread  $3F00 ,
 DUP =, Fwrite  $4000 , DUP =, Fseek $4200 , =, Fcreate $3C00 ,
0#> @ PUSH D0 ROT POP (DOS ;
DUP =, Fsize  $4202 ,   DUP =, Fpos  $4201 ,  =, Fclose $3E00 ,
: =" '" WORD : >ZSTR CSTR '| (S! SWAP OFF ;
                         : ;File >ZSTR 1+ D0 EX IO? _AX ;
: FOPEN ;File Fopen ;     : FCREATE ;File Fcreate ;

{ STREAMS }: FGET Fbuf CALL DROP  cr : EOS! bs TO EOS ;THEN
  AT Fbuf 1 AT HANDLES TOP  Fread  _AX 0;  { IF EOF THEN EOS}
  DROP Fbuf  DUP $1A XOR 0; RDROP  ; : ;EOS EOS XCHG 0 TO EOS
  EXECUTE POP TO EOS ; : ;FILE TO HANDLES AT KEY @ XCHG PUSH
 LIT FGET TO KEY EX POP TO KEY     : HCLOSE HANDLES Fclose ;
: ;NOEMIT LIT DROP; : ;EMIT! LIT TO EMIT
: ;SAFE! DUP XCHG OVER @ PUSH PUSH ! EX POP POP ! ;
: INCLUDE TOKEN? : INCLUDED FOPEN ;FILE D0 ;0TI ;NOEMIT
: KEVAL ;EOS BEGIN vINIT EVAL EOS UNTIL ;
: NEEDS EXIST? 0<>; TBUF AUTO INCLUDED ;
: FTYPE TOKEN? FOPEN ;FILE ;EOS BEGIN KEY EMIT EOS UNTIL ;
: CLOSE_ALL    AT HANDLES ITEMS? LOOPS HCLOSE ;
0 VALUE SCRH   0 VALUE `USE 4 CONST `NBUFS 0 VALUE `PREV
: `RW 1K UM* SCRH Fseek  IO?  1K SCRH  EX IO? ;


: FCUT `RW 0SWAP Fwrite ;
: `WBLK `RW Fwrite ;    : `RBLK `RW Fread ; `NBUFS BARY `FBUFS
  `NBUFS WARY  `BUFS    : `@BUF `PREV 1K U* FIRST + ;
0#> C@ `PREV `FBUFS C! ; DUP  =, DISCARD  0 C, =, UPDATE  -1 C,
: -BUF DISCARD -1  : `!BUF `PREV `BUFS ! ;
: `+BUF `USE 1+ `NBUFS 1- AND DUP TO `USE ;
: !BUFS  `NBUFS LOOPS `+BUF TO `PREV
: `?SAVE `PREV `FBUFS C@ 0; `@BUF `PREV `BUFS @ `WBLK DISCARD ;
: FLUSH !BUFS : /BUFS `NBUFS  LOOPS `+BUF TO `PREV
: `EMPTY-BUF -BUF : `/BUF `@BUF 1K ERASE ;
: `?BUF PUSH 0 `BUFS `NBUFS POP SCAN ;
: `;ABLK /BLK 0 TO _FR XCHG PUSH J `?BUF  EX RDROP `@BUF IO? ;
: Fbuffer `;ABLK -IF `?BUF
      -IF DROP `+BUF THEN THEN TO `PREV `?SAVE `/BUF J `!BUF ;
: Fblock `;ABLK -IF DROP J Fbuffer J `RBLK ;THEN TO `PREV ;

: FIXER CONST , DOES> @+ @ ! ; 'TO BLOCK TO@ BLOCK FIXER MBLOCK
: `-USE SCRH 1+ 0; SCRH Fclose : `/SCR -1 TO SCRH ;
'TO BLOCK  ' Fblock  FIXER FBLOCK       : USE/ `/SCR /BUFS ;
: USING FLUSH `-USE TOKEN? FOPEN TO SCRH ;

FBLOCK USE/ USING C4H.COM

\ : MARKER DICT CODE: , DOES>  DUP @ TO DICT 2- TO HERE ;
: COPY BLOCK SCR BLOCK 1K CMOVE UPDATE ;
: URED 2DUP U< 0= NOP ?; SWAP ;
: BLOCKS> URED ;RNG> COPY 1 : SCR+ SCR + TO SCR ;
: COPYBLX TO SCR FLUSH :; URED  OVER SCR U<  BLOCKS> ?;
   2DUP SWAP - SCR+ : BLOCKS< URED ;RNG< COPY -1 SCR+ ;



0#> PUSH XCHG CSTR POP SCAN 1+ 0;  ;SPC ;[] DUP ". CSTR + ;
 =, `?STR 3 C, >, (A"  (" (." ,<
0 VALUE `WW : `;WW `WW EX TO `WW ;
: `STR EX DUP 2- @ `?STR ;
: `:ID. DUP C>N? DUP NOP ?;
 XEP OVER CALL ." : " ID. ;THEN : ``CR- CR H. ; : `CR-H `:ID.
 ``CR- ?; ; : `CR- `:ID. IF ;THEN DROP ;
' ?ID. 2+ VALUE vDBG
: SEE ' : @SEE TO `WW : SL `;WW bs LOOPS
: WW `CR-H @+ OVER H.  : `W0 `STR XEP vDBG PUSH ;
: HACK ' : @HACK TO `WW : HL CR bs LOOPS `;WW `CR- @+ `W0 ;
: -HL `WW 23 - @HACK ;  : .HL `WW H. ;
: `TYPE EX SPACE 1H - 1H ;[] ?TYPE ; : DUMP U16? ;DROP LOOPS
: DU CR DUP H. SPACE `TYPE 1H LOOPS CSTR B. ;


\ BLOCK1 OF EDITOR
    : WHAT? 7 EMIT ; : `;HOME EX HOME ;
ZDO VALUE 4 TIMES  `PDATA `INS  `SZ  `ALTER
: PAGE `;HOME  0 24 @XY  25 : CRS  LOOPS CR ;
0#> SWAP TO XK CSTR 2DUP XK BSCAN 1+ 2* + + @EXEC ; =: `XK!

HERE 2000 HIPUSH TO HERE  VALUE THERE
: <!> HERE THERE TO HERE TO THERE ;
: -:  ' , C,  XK 2+ DUP TO XK       { BYTES FOR MOVE UP 1 }
         HERE OVER - DUP PUSH       { START ADDRESS    }
         DUP 1+ ROT                 { PREPARE FOR MOVE }
         CMOVE>  HERE C@ POP C!   ; { FIX CODE  }
: SWITCH: CREATE HERE 73 1 TO XK 0 -: LIT  `XK!  TOBE ;
: ;SWITCH  73 - A" BAD KEYS" XK 2/ 1- SWAP C! ;
<!>

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
<!>  : C^ TOKEN? 1+ C@ 31 AND ;

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




 <!> \ BLOCK6 OF EDITOR
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
: HELP ;GO SCR XEP : `(E THEN TO SCR : E  D0 ;0TI `LOADRAW ;EOS
 BEGIN `@KEY `EK EOS  UNTIL ;  : EDIT PAGE `(E ; : PE PAGE E ;

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



PRUNE
HIDROP

M: C4 USING C4H.COM;
M: BBB USING BBB;
M: C3 USING C3H.COM;

: T ;








: @I J @ ; : !I J ! ; : @R` COMPILE (@R : ,NUM? >NUM DUP ODD ??
, ; : !R` COMPILE (!R ,NUM? ;
: ;DICT DICT EX TO DICT ; : TOKEN+ TOKEN? DUP : INC ;@! 1+ ;
: CFA? TOKEN+ Afnd ;
: (: =H : ;, EX , ;    : ;>DICT EX DUP C@ 1+ >DICT ;
: LINK? PUSH @R 2 DUP 2+ !R 2 XCHG POP ODD ; : @, NOP @ , ;
: =HT HERE : =:T TOKEN+ : =:NAME ;>DICT XEP : DICT!- ;DICT !- ;
: (,) 0SWAP : (T) =HT  Z, , , DOES> <MRK  LINK? (IF TO @,
: LINK, PUSH HERE @I , POP ! ;  3 - CONST #TARGET























































































































































































































: PROBA1 [ 1 . [ 2 . [ 3 . ]  [ 4 . ] ]
              [ 5 . [ 6 . ]  [ 7 . ] ] 8 . ] 9 . ; : . DUP . ;
: PROBA [ [ 9 . [ + . ]  4 . ] EX  [ U* . ]  10 . ]  EX .
        [ - . ]
        [ [ 8 . [ + . ]  3 . ] EX  [ U* . ]
    [ 8 . [ - . ] 3 . ] EX  ]  EX .
;
M: FOR` (FOR MRK> <MRK;         M: NEXT` (NEXT <RLS RLS>;
M: IF` (IF MRK>;                M: THEN` RLS>;
M: CALL` (CALL MRK>;             ' CALL` =: [`
'" ?M: ]` ; >, THEN"             ' ]`    =: ;THEN`
M: WHILE` IF X SWAP;            M: REPEAT` AGAIN THEN;
M: BEGIN` <MRK;                 M: AGAIN` (JUMP <RLS;
M: AHEAD` (JUMP MRK>;


\ SELF PRUNE SCREEN  \ <H HERE 5 LOAD FGT H>
{ PRUNE BY ADDRESS}  : `HERE+! HERE  DUP PUSH @ + POP ! ;
: `DICTEL DPTR NPTR OVER - ; : `DEST HERE STR + ; 0 VALUE `H
: `ADD? DNEXT  ADR U< 0;  DPTR 1+ C@ '` XOR 0; `DICTEL `DEST
 OVER `HERE+! SWAP 1+ : `CMOVE ;2DROP LOOPS PUSH CSTR POP C!+ ;
: `P TO ADR   0 HERE !  DICT SKIP BEGIN  NPTR  END? WHILE
  `ADD? REPEAT 1 `HERE+! ;  CREATE `O >, (DE ETIB (ACC @_INI ,<
: FORGET ' : FGT `P $E000 TO DICT HERE STR >DICT  ADR TO HERE ;
: `N, LOOPS : `W, STR : `, `H !+ TO `H ; : 'PRUNE ' 2+ @ FGT ;
: `WS, `W, : `S, SWAP : `WS+, `W, SWAP 2+ ; : PRUNE HERE FGT ;
: `W+, `W, 2+ ;  : `INIT $100 TBL TO `H  7 `N, `O  `WS+,
  `WS, `WS, `W+, 0 `, `W+, 0 `, 12 `N, `S, NIP 2 `N,  ADR `, 2+
  8 `N, DROP $E000 `,  TBL `H
: `OVER-FWR OVER - : `FWR FHTOP FWRITE ; : SAVE TOKEN? FCREATE
  ;FILE `P  `INIT  $152 ADR `OVER-FWR  HERE DUP @ 2+ `FWR ;

T' 2+ =: 2+     T' AND  =: AND  T' NOT =: NOT   T' NEG =: NEG
T' XOR =: XOR   T' 2- =: 2-     T' 1- =: 1-  T' 2DROP; =: 2DRP;
T' U< =: U<     T' 0< =: 0<     T' 1+ =: 1+     T' ROT =: ROT
$27D =: =,      $48B =: >,      $1FD =: ,<`     $24B =: SKIP
$22F =: :       $259 =: ,       $257 =: ;,      $2BB =: ??#
$235 =: ;`      $203 =: DROP    $146 =: LTIB    $299 =: TOKN?
$14C =: DICT    $13A =: HERE    $201 =: SWAP    $3A9 =: (FND
$1D7 =: @R+     $3E2 =: !       $1A8 =: ;DROP   $444 =: PUSH
$1E5 =: XCHG    $4B1 =: (FOR    $483 =: EXEC    $241 =: J
$47F =: EXECUTE $245 =: (NEXT   $247 =: RDROP   $12C =: 0
$269 =: NUM?    $253 =: POP     $1EA =: DUP     $205 =: OVER
$209 =: +       $29D =: WORD    $219 =: CSTR    $273 =: ;HERE
$37A =: (S!     $1DD =: (?S     $130 =: BL      $10C =: EMIT
$1F8 =: @       $215 =: C@      $424 =: C!+     $207 =: -
$48D =: DOES#   $1AC =: DROP;   $27F =: =H      $487 =: @EXEC

$29F =: PARSE   $251 =: EX      $152 =: CNTC    $128 =: TBUF
$158 =: STATE   $20B =: STR     $4C8 =: (IF     $1F2 =: LIT
$1EA =: DUP     $4EF =: 0=      $255 =: NIP;    $194 =: (A"
$24F =: ;       $497 =: (:      $23B =: ,#`     $1C4 =: >DICT
$140 =: ETIB    $42A =: !+      $249 =: (JUMP   $12E =: BYE
$11C =: vERR    $114 =: ACCEPT  $102 =: OPER[]  $261 =: NUM?,
$12E =: BYE     $36D =: (MPUSH : C, ;HERE C!+ ; : HP HERE 2+ ;
$2DA =, :` >, SKIP : ,< $441 =, ;?# >, ??# ; : TOKEN? LTIB DROP
TOKN? ; : ,X: $2DF : `X =, , : ,' ;, : ' ;?# TOKEN? : Afnd DICT
: Dfnd HERE SWAP (FND ; : (,X $2DA `X ; : (#, @R+ , ; : X:` '
EXEC ; $41B (,X `V! , $46F ,X: VECTOR `V! $40B ,X: VALUE `V!
: NOP ; $470 ,X: DEFER ,  $40C ,X: CONST , $40E ,X: CREATE NOP
: 2-DXEP 1- : 1-DXEP 1- : DXEP DUP : XEP XCHG EXECUTE POP ;
: 'TO ' 2+ ; : TO` 'TO , ; : UNW ;DROP : @H- ;HERE : @- 2-DXEP
@ ; : C! C!+ DROP; : -ROT ROT ROT ; : ;2DR EX : 2DROP 2DRP; ,<

: MRK>` HERE : Z, 0 , ; : RLS>` HERE : SWAP! SWAP ! ; : (CAL
@R+ PUSH ; : (;GO @R+ XCHG PUSH ; : NAME> CSTR + ; : D>NAME DUP
: >NAME NAME> 2+ 2+ ; : LATEST DICT : N>C NAME> @ ; : ;code POP
: TOBE LATEST ! ; : `ND# HERE 2- >, : `DOES @H- : CALL, $E8
: ,R C, HP - , ; DOES# (,X `D# `DOES ' ;code (,X DOES>` `D#
DOES# (,X 0#> `ND# DOES# 1- (,X 1#> `ND# DOES# 2- (,X 2#> `ND#
: ..TIMES ;DROP : .TIMES ;DROP : TIMES PUSH XCHG : LOOPS (FOR
MRK> X: HERE  J EXECUTE (NEXT X: , RLS> RDROP ; : TUCK DUP
: USWAP XEP SWAP ; : NUP XEP DUP ; : 2DUP OVER OVER ;
: `(: =H (CAL MRK> EX @EXEC ; : `MKR =H Z, , EX ,' ; : 2MKR
`MKR , DOES> `(: : W, RLS> STR , ; : 1MKR `MKR DOES> `(: ; :
3MKR `MKR , , DOES> `(: W, W, ; 0#> C@ : FILL -ROT ;2DR LOOPS
NUP C!+ ; DUP =, ERASE 0 C, =, BLANK BL C, : [], HERE DUP PUSH
2- DUP =: EXEC POP - : CLARY HERE OVER ERASE : ALLOT ;HERE + ;
: @+ STR SWAP ; : !- 2-DXEP ! ; : @' ' @ ; 0 VALUE ENDH

: ," '" : ?, WORD : CSTR, CSTR : STR, ;HERE (S! DROP ;
$194 (,X A"` ,"  : U- XEP - ; : R>S 1+ : OVER- OVER - ;
: WITHIN OVER- U- U< ;      : @BNDS? @+ @ : BOUNDS? WITHIN 0=
A" BOUNDS!" ; : ;STK @BNDS? : ;@! @+ XCHG EXECUTE POP !- DROP ;
: `CLRY XEP RLS>` RLS>` CLARY ; : STK+, MRK>` MRK>` MRK>`
`CLRY RLS>` ; : STK, SWAP DUP , , , ; $40E 1#> DUP @+ ;STK !+ ;
2#> DUP STR 2- SWAP ;STK @- ; 3MKR STACK+ STK+, ' STACK+ 8 + @-
@- @- DROP 3MKR STACK STK, 40 STACK+ CSTK> 40 STACK+ <CSTK
$498 =, `;E >, @H- EXEC : ;END! EX : END! HERE TO ENDH ;
  'TO CSTK> (,X `M> `;E  'TO <CSTK (,X `<M `;E  ' ,' =: C:`
  '   CSTK> (,X `R> `;E  '   <CSTK (,X `<R `;E
: MARK>` MRK>` `M> ; : MARK><` MARK>` : <MARK` HERE `<M ; :
<RLS` `<R , ; : <RLS>` <RLS` : RELS>` `R> RLS>` ;
: `BYTES @+ @ - ; : META ' : TO! 'TO ! ; : TO 'TO EXEC ;
: 'AT 'TO 2+ ; : AT` 'AT , ; : AT 'AT EXEC ; : TO@ 'TO @ ;

' (JUMP (,X AHEAD` MARK>`      ' (;GO (,X  ;GO` MARK>`
' (IF   (,X IF` MARK>`         ' (CAL (,X  CALL` MARK>`
' (FOR  (,X FOR` MARK><`       ' RELS>` =: THEN` ' CALL`  =: [`
: (OF OVER XOR @R+ SWAP IF XCHG  SKIP THEN DROP DROP ;
' <MARK` =: BEGIN`             ' (NEXT (,X NEXT` <RLS>`
' (IF   (,X UNTIL` <RLS`       ' IF` =:  WHILE`
' (JUMP (,X AGAIN` <RLS`       ' (JUMP (,X REPEAT` <RLS>`
' PUSH  (,X FOR>` BEGIN`       ' (OF (,X   OF` MARK>`
' (NEXT (,X <NEXT` <RLS`       : CASE` 0 TO CSTK> ;
: ;CASE` (#, DROP SKIP BEGIN RLS>` CSTK> DUP 0= UNTIL DROP ;
: 0<; 0< : 0<>; (IF TO NOP : EXIT RDROP ;
: 0>=; 0< : 0; (IF TO EXIT ;
: `STK AT <CSTK `BYTES AT CSTK> `BYTES + 0<>; ,<` ; ' =H =: =H`
' ; (,X ;;` `STK       : `:=? @ LIT ,< @' Z, , >, : = XOR 0= ;
' 2+ VECTOR vTOC>.      ' `:=? VECTOR vIS:?     : <> = 0= ;

: ZST DUP 2+ @ SWAP! ; : `ZST C: : AT CSTK> ZST AT <CSTK ZST ;
: `THEN THEN` ;         : `x??x EX ??# : `(@H, @H- vTOC>. ;
: `?? `x??x : `H@:? HERE 2- @ vIS:?  HERE ENDH <> AND ;
: :;` `?? TO <CSTK (#, (;GO <RLS` ;
: ;THEN` `THEN :; : ;` `H@:? ;;` 0; UNW `(@H, TO <CSTK AGAIN` ;
: ?;` `?? TO <CSTK UNTIL` ; : : `ZST ; ' ;THEN` =: ]`
: `;STK> CSTK> EX TO CSTK> ;    : `;<STK <CSTK EX TO <CSTK ;
: CSWAP>` `;STK> `;STK> SWAP ; : <CSWAP` `;<STK `;<STK SWAP ;
: ENDOF` AHEAD` CSWAP>` THEN` ; ' ENDOF` =: ELSE`

: `1 J SKIP =H `2 POP  NOT RDROP POP + NIP; ,< : W>B 255 AND ;
: SCAN      OVER PUSH PUSH FOR STR  J XOR (IF `2 NEXT `1 ;
: BSCAN W>B OVER PUSH PUSH FOR CSTR J XOR (IF `2 NEXT `1 ;
: "BSCAN CREATE DOES> : B>IN" PUSH XCHG CSTR POP BSCAN 1+ ;
: ,T BL ?, ; 0 VALUE XK  0 VALUE >LT< 'TO >LT< 'AT TOKEN? !

$4AB (,X WARY [],  $4AD (,X BARY [],  $4A9 (,X LARY [],
0 VALUE L  "BSCAN `Ctbl ,T "^~_ : PK: C: : DOES> TO XK ;HERE
 XEP DXEP TO HERE 0 C, CSTR TO L XK EXECUTE : /PK HERE J NOT +
 J  C! ; : UNB ;DROP : C@H- ;HERE : C@- 1-DXEP C@ ;
PK: "UNPACK L ;DROP LOOPS CSTR DUP 128 AND IF 128 - [ '~ C, ]
THEN [ L C, ] DUP TO L `Ctbl IF '" C, ;THEN BL L = IF '_ TO L
;THEN L BL U< IF '^ C, '@ L + TO L THEN ; : `SRC CSTR L 1- TO L
; : `^ UNB L 0; `SRC 31 AND C, ; : `" UNB L 0; `SRC C, ; : `~
UNB C@H- 128 XOR C, ; : `_ UNB BL C, ; 0 WARY `tbl >, NOP `" `^
`~ `_ ,< $FD00 CONST SBUF 0 VECTOR `DO PK: "PACK ;DROP BEGIN L
0; `SRC DUP C, `Ctbl `tbl @EXEC AGAIN ;
: `Q $41A , $40E : D, , , ; $40A ,X: QUAN `Q $46E ,X: VQUAN `Q
: >NUM TOKEN? NUM? ; : `AT@ ' TO `DO POP ; : ZDO `AT@ 0 `DO ;
: 'DO `AT@ ' `DO ; : #DO `AT@ >NUM `DO ; : DO `AT@ `DO ;
: +DO `AT@ DUP `DO : OVER+ OVER + ; $40E ,X: VAR ,

#DO CONST 13 TIMES 64 1L 1024 1K 16 1H 1 1 -1 -1 2 2 256 1B
 $8000 SGN $7C NPAD $E000 FIRST 13 cr 10 lf 8 bs
ZDO VALUE 3 TIMES  BLK SCR XY  0 VQUAN KEY  0 VECTOR vLOAD
: BS>T TBUF DUP 256 ERASE (S! SBUF "UNPACK DUP C@ 1+ DUMP ;
: TS, BL WORD SBUF "PACK CSTR ;DROP LOOPS CSTR C, ;
$44B =, UM* TS, ^S~w~b~^R~^S~C~ : 1K* 1K : U* UM* DROP ;
: ;CR EX : CR cr EMIT lf EMIT 0 TO CNTC ;     : XY? 1K LTIB - ;
@' STR =, (BK TS, 1[~^S~M~^V^H@~t^B0d~^S~C~
: `MBLK 1K* $100 + ; ' `MBLK DEFER BLOCK : `SRC ETIB BLK 0; DUP
  0<>; DROP BLK BLOCK 1K + DUP TO ETIB ; : ;B_TI 1K OVER : ;TI
 BLK XCHG LTIB PUSH ETIB PUSH PUSH CALL MRK> EX POP POP POP
 THEN TO BLK TO LTIB TO ETIB : /BLK BLK 0;   0 TO ETIB ;
: +LOAD BLK + : LOAD DUP ??# ;B_TI vLOAD (JUMP ,< $182 ,
: ;0TI 0 (JUMP TO ;TI ,< : DU+ DUP : U+ XEP + ; : M: '; : ?M:
 CREATE ?, DOES> : SEVAL CSTR : MEVAL DU+ ;0TI (JUMP ,< $182 ,

: ;LTIB LTIB EX TO LTIB ; : \ ;LTIB 1- : L/ 1L NEG AND ;
@' DUP =, U/MOD TS, 3I~^Q~^R~w~s~^S~^Q~C~    ' \ =: \`
: (" (?S ; : " HERE ,"  ; $44B =, ?BL. TS, ^@~{~_s^B3~.C~
: (." (?S : ". CSTR : TYPE ;DROP : ?TYPE LOOPS CSTR ?BL. EMIT ;
: { '} PARSE : 2DROP 2DRP; ,< ' (" ,X: "` ," ' (." ,X: ." ,"
: ;SPC EX : SPACE BL EMIT ;      : TD. DICT : ID. ;SPC ". ;
: (ERR CR TBUF ID. STATE ID. CR LIT (BK TO KEY BLK 0; BLK TO
SCR 0 TO BLK XY? : >XY 1K 1- AND TO XY ; : UMOD U/MOD : DROP
DROP; ,< : TOP @ @- DROP ; : ITEMS@ DUP 2+ @ SWAP : ITEMS? @+ @
- : 2/ 2 : U/ U/MOD NIP; ,< @' DUP =, SM*  TS, ^S~w~j~^R~^S~C~
: (!R @R+ : I+! J + ! ; : (@R @R+ : I+@ J + @ ; : ;+ EX + ; :
ALIGNED ;HERE : ALIGN ;+ DUP : ODD 1 AND ; : U16? 1H : UN?
U/MOD SWAP 0; 1+ ; : CMOVE> SWAP OVER + (MPUSH DROP ; : CMOVE
;2DR LOOPS PUSH CSTR POP C!+ ;
: I+ J + ; : I- J - ; : I J ; : C@I J C@ ; : (TYP N>C @ ;

: CORA DUP C@ 1+ : -TEXT FOR PUSH CSTR XCHG CSTR POP = IF
 CSWAP> NEXT -1 PUSH THEN 2DROP POP 1+ ; : ;FND DICT AHEAD
: ;FND2 BEGIN >NAME THEN PUSH C@I WHILE DUP J EXECUTE POP
  REPEAT 0 : EXIT2 RDROP EXIT ; : ID-. CSTR  1- ;SPC TYPE ;
: C>N? ;FND J N>C - : `C 0<>; POP 2DROP POP DUP EXIT ;
: -FIND TOKEN? : FND  ;FND J CORA `C ;            0 VALUE `
: `(DO< DUP XCHG PUSH - XCHG @ PUSH ; : IND<` (#, J (#, I+ ;;
: `(DO> OVER 1- (JUMP ,< 'AT `(DO< , : IND>` (#, J (#, I- ;;
: DO>` (#, `(DO> MARK><` ; : DO<` (#, `(DO< MARK><` ;
: LOOP` THEN` <NEXT` (#, RDROP ;
: `(RNG: C: : DOES> POP ` PUSH TO ` PUSH 1+ SWAP ;
`(RNG: ;RNG> DO> IND> ` EXECUTE LOOP : `XP! POP TO ` ;
`(RNG: ;RNG< DO< IND< ` EXECUTE LOOP `XP! ;
: THRU ;RNG> LOAD ;  : +THRU ;RNG> +LOAD ; : CHARS ;RNG> EMIT ;
: S+! XEP TUCK J STR + SWAP CMOVE J : +! ;@! + ;

: PRUNE HERE  0 HERE ! [ HERE STR >DICT TO HERE ] ;DROP
 ;FND J >NAME TO DICT J N>C SWAP U< 0; J 1+ C@ '` - 0;
  J  D>NAME OVER-  HERE S+! DROP ; : TC:` T' , ; : TX T' EXEC ;
















: FORGET -FIND ??# DUP >NAME TO DICT N>C TO HERE ; PRUNE
: HI. TC: HDICT @ DICT - TC: . ;
: LO. HERE TC: HDICT 6 + - TC: .
; : FREE. DICT HERE - TC: . ; : .( ') PARSE TYPE ; CR .( CODE BY
TES: ) LO. .( DICTIONARY: ) HI. .( FREE MEMORY: ) FREE. CR
------------------
'TO SM* 6 BS>T
\ GSDFGHSDFGSD





FORGET T CREATE T  : `(# @R+ ; \ RESOLVE AN EGG-HEN PROBLEM
: `INIT `(# TOKEN? TO vTOK? $1F2 $23D ! ;  `INIT
: `;E HDICT MK! MARK@ EX HDICT MK@ ; : `ED `;E EDIT ;
: `E `;E E ; : `T `;E ' ; : `S0 50 TO SCR 0 TO XY S ;
: `N3 [ ROT (MPUSH ] TBUF >" TBUF (JUMP ,< $28B ,
: ``` (#, LIT ,' (#, (" ,T (#, `N3 ;;
: `` (#, LIT ' DUP , C>N? ??# (#, (" CSTR, (#, `N3 ;;
: `STOP MARK@ HIDROP `INIT ; : `START `STOP
: EGG PAGE 18006 HIPUSH MARK! 4 + TO HERE `INIT   0 HDICT @ !-
` =:    `` `E E ` DUMP  ` HACK  ` HL    ` @HACK ` S0!   ` WORDS
` S     ` SHN   ` PAGE
`` LOAD LD      `` `STOP STOP   `` `ED EDIT     `` `S0 S0
`` `START START `` H. T.        `` `T T'
TO DICT 50 61 THRU ;
PRUNE

