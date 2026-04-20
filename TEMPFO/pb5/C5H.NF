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
: TO` 'TO , ; : @' ' @ ; ' ,' =: C:` : CODE: HP =, ; $261 =: ,#

$41B (,X `V! , $23B =: ,#` $1C4 =: >DICT 8 CONST bs 13 CONST cr
$40B ,X: VALUE `V!   $46F ,X: VECTOR `V!   $40E ,X: VAR ,
: `Q $41A , $40E : D, , , ; $40A ,X: QUAN `Q $46E ,X: VQUAN `Q
64 CONST 1L 1024 CONST 1K 0 VALUE BLK 0 VECTOR vLOAD 0 VALUE
>LT< 0 VALUE SCR 0 VQUAN KEY 0 VALUE XY   0 VECTOR v",
$29D =: WORD    $219 =: CSTR    $273 =: ;HERE   $37A =: (S!
$1AC =: DROP;   $152 =: CNTC    $1F2 =: LIT     $102 =: OPER[]
$253 =: POP     $3E2 =: !       $424 =: C!+     $207 =: -
$1E5 =: XCHG    $47F =: EXECUTE $483 =: EXEC    $4EF =: 0= : ,"
'" : ?, WORD : CSTR, CSTR : STR, v", ;HERE (S! DROP; ,< : NAME>
CSTR + ; : D>NAME DUP : >NAME NAME> 2+ NOP ; : 'VAL 'AT 2+ ;
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
@+ @ : BOUNDS? WITHIN 0= A" BOUNDS!" ; : TOP @ @- DROP; ,< :
;STK @BNDS? : ;@! @+ XCHG EXECUTE POP !- DROP; ,< 0 VALUE HOFS
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
: (;GO @R+ XCHG PUSH ;              : []: $2DA =, , (#, [], ;
: (!R @R+ : I+! J + ! ; : (@R @R+ : I+@ J + @ ; : ;+ EX + ;
: ALIGNED ;HERE : ALIGN ;+ DUP : ODD 1 AND ;
: CMOVE> SWAP OVER + (MPUSH DROP ;
: CMOVE ;2DROP LOOPS PUSH CSTR POP C!+ ;
: `(: =H (CALL MRK> EX @EXEC ; : `MKR =H Z, , EX ,' ;
: 2MKR `MKR , DOES> `(: : W, RLS> STR , ;
: 1MKR `MKR DOES> `(: ; : 3MKR `MKR , , DOES> `(: W, W, ;
: `CLRY XEP RLS>` RLS>` CLARY ; : STK+, 2* MRK>` MRK>` MRK>`
`CLRY RLS>` ; : STK, SWAP DUP , , , ; $40E 1#> DUP @+ ;STK !+ ;
2#> DUP STR 2- SWAP ;STK @- ;  3MKR STACK+ STK+,
       ' STACK+ 8 + @- @- @- DROP 3MKR STACK STK,
$7C CONST NPAD  $E000 CONST FIRST  : VARIABLE 0 VAR ;

: `AT@ ' TO `DO POP ; : #DO `AT@ >NUM `DO ; : DO `AT@ `DO ;
: +DO `AT@ DUP `DO : OVER+ OVER + ; : ZDO `AT@ 0 `DO ;
: 'DO `AT@ ' `DO ; : D! !+ ! ; : D@ 2+ @+ 2- : 2-@ 2- @ ;
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
' ELSE` =: ENDOF` : OF` (#, (OF MARK>` ;  M: -IF` DUP 0< IF;
: REPEAT` `THEN : AGAIN` (#, (JUMP <RELEASE` ;
: UNTIL` (#, (IF <RELEASE` ;  ' IF` =: WHILE` : ;CASE` (#, DROP
  AHEAD BEGIN RLS>` THEN CSTK> DUP 0= UNTIL DROP ;
' 2+ VECTOR vTOC>. : `:=? @ LIT ,< @' Z, , >, = ;
' `:=? VECTOR vIS:? : ;;` (#, C: ; STK? 0<>; ,<` ;
: `x??x EX ??# : `(@H, @H- vTOC>. TO <CSTK ;
: `?? `x??x : `H@:? HERE @- DROP vIS:? ;  : ]` : ;THEN` `THEN
: ;` `H@:? ;;` 0; @H- DROP `(@H, AGAIN` ;    : ?;` `?? UNTIL` ;
: :;` `?? (#, (;GO <RELEASE` ; : ID-. CSTR  1- ;SPC TYPE ;
 @' (DE =, (BE  $3196 , $B4DB , $CD0E , $9610 , $C3 C,



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
: `(RNG: C: : DOES> ` XCHG TO ` PUSH 1+ SWAP ;
`(RNG: ;RNG> DO> IND> ` EXECUTE LOOP : `XP! POP TO ` ;
`(RNG: ;RNG< DO< IND< ` EXECUTE LOOP `XP! ;
: THRU ;RNG> LOAD ; : +THRU ;RNG> +LOAD ; : CHARS ;RNG> EMIT ;


: `1 J SKIP X: =H `2 POP  NOT RDROP POP + NIP; ,< : W>B 255 AND
; : SCAN OVER PUSH PUSH FOR STR  J XOR (IF `2 NEXT `1 ;
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
HERE 2+ DUP 12 - !  0 CONST >NF<
: S! { ADR LEN DST -- DST } (S! SWAP : OFF 0 SWAP! ;
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
: 9>? 9 OVER U< 7 AND ; : ALPHA 9>? + '0 + ;  : 0SWAP 0 SWAP ;
: OR OVER NOT AND XOR ; : NIP NIP; ,< : INC ;@! 1+ ;
$4B8 =: 0?SKIP  $134 =: vINIT   $212 =: .C@     $1FF =: 3+
: W+!HERE HERE : W+! DUP PUSH STR + ! 2 POP +! ;
: EDICT DICT SKIP BEGIN >NAME .C@ 0= UNTIL 1+ ;
: FORGET ' TO HERE >NF< >NAME TO DICT ;
0 VALUE REG   ' REG 2+ 2+ CONST `REG \ 03 DA 8B D3 D1 DB C3
 @' DUP =, +2/ $DA03 , $D38B , $DBD1 , $C3 C,
 @' DUP =, +* \ F6 C2 01 74 04 03 1E AA AA D1 DB D1 DA C3
  $C2F6 , $7401 , $304 , $1E C, `REG , $DBD1 , $DAD1 , $C3 C,
@' DUP =, -/ \ D1 E2 D1 D3 8B 0E AA AA 3B D9 72 03 2B D9 42 C3
  $E2D1 , $D3D1 , $E8B , `REG , $D93B , $372 , $D92B , $C342 ,


: ;MAX 2DUP EX IF  XEP THEN DROP ; : UMAX ;MAX U< ;
: UMIN ;MAX : U>= U< 0= ; : MAX ;MAX : < - 0< ;  : <> = 0= ;
: PRUNE EDICT HERE DUP OFF [ DUP STR + OFF DUP INC SWAP TO DICT
STR >DICT ] ;DROP ;FND J N>C SWAP U< 0; J 1+ C@ '` - 0;
   J  D>NAME OVER-  HERE S+! DROP ;

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
: SPTRTOP? SPTRTOP DICT <>  SPTR SPTRTOP U< 0=  OR  0;
  DICT DUP TO SPTRTOP TO SPTR TWICE  D0
: >S ;SPTR OVER PUSH (MPUSH XCHG POP C!- ; : >S! CSTR >S ;
: S> SPTR : SDROP ;SPTR NAME> ;



: SUCSTR SWAP : UCSTR XEP CSTR ; $FD00 CONST SBUF VARIABLE `CBF
: C@+ CSTR SWAP ; : W>BB `CBF ! `CBF C@+ C@ ; : `B C!+ C!+ 2- ;
: BB>W SWAP `CBF `B  @ ; : `U"R! XEP SBUF : "! UCSTR S! ;
: >"   { SRC DST --           } "! DROP; ,<
: S>"  { ADR LEN -- >STR      } SBUF S! ;
: C>"  { CHAR -- >STR         } `CBF
: C>"! { CHAR >STR -- >STR    } 1 SWAP `B ;
: "+C! { >STR CHAR -- >STR    }  C>"
: "+!  { >STR STR -- >STR     } CSTR
: "+S! { >STR ADR LEN -- >STR}  ROT DXEP C@ TUCK + 255 UMIN DUP
         J C! SWAP - J CSTR + OVER - SWAP CMOVE ;
: +" SWAP : "+ { STRA STRB -- >STR } `U"R! "+! ;
{ SXGFHFDGHDF }
0 VALUE >CF<    0 VALUE HDICT : T>R HOFS - ; : R>T HOFS + ;


             : EXI?T (;GO TO 0<>; : EXIST? T? SWAP TO >CF< ;
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
 `" `^ `~ `_ ,< : >HERE DUP HERE !+ SWAP CMOVE ;
PK: "PACK ;DROP BEGIN L 0; `SRC DUP C, `Ctbl `tbl @EXEC AGAIN ;

: !R+ XCHG POP POP !+ PUSH PUSH ; VARIABLE @HD Z, Z, $227 =: `-
                                               0#> C@ HDICT + ;
DUP =, TL 2 C, DUP =, TH 4 C, =, TD 6 C, : ;TD TD @ EX TD ! ;
: <D> DICT TD @ TO DICT TD ! ; : FX @R+ @R+ ! ; : ?SKIP DUP IF
@R+ THEN DROP ; : !TD- ;TD !- ; : `EG DICT EDICT OVER- >HERE EX
HERE STR HDICT (MPUSH TO DICT ; : HIPUSH `EG PUSH HDICT ?SKIP
FIRST DUP 10 I+ - DUP TO HDICT !+ XCHG !R+ TD 2+ !R+ HDICT @
!R+ RDROP 0 !TD- ;; 0 HIPUSH : HIDROP HDICT 0; `EG HDICT @ TO
HDICT ; : `TRG - DUP 0<>; : ;<D> <D> EX <D> ; : TARGET,! FX
`TRG `- ;; : <H> TL D@ HERE HOFS TL D! TO HOFS TO HERE ; : ESQ
 C: ; <H> <D> ; : INITO FX SAME? AT vTOK? FX LIT TO ,#` FX C: ;
TO ESQ FX - `- CALL NUM? EXEC C: ,# , : OPER! THEN POP 0 OPER[]
8 CMOVE ; : MARK@ @HD PUSH @R+ TO HOFS @R+ TO HERE POP @ TO
 DICT ; $221 =: FOUND? : MARK! @HD PUSH HOFS !R+ HERE !R+ DICT
 POP ! ;

\ : B>N? ;FND J  N>C 2+ @ - 0<>;   J (TYP #TARGET - `C ;
: `6N  PUSH PUSH PUSH  CALL  POP POP POP \ : `H ." `$" H. ;
: `N3 THEN SPACE 3 LOOPS ROT DUP H. ; : /DBG KEY 17 = A" /DBG"
           ; : `PREFETCH TOKEN? >LT< TO LTIB FOUND? DROP H. ;
\ : T?ID. DUP 0< OVER 2* RANGE? AND IF 2*  THEN
\ : ?ID.   C>N? 0= ID. ?; `TO. `AT. 2+ 2+ `H ;
\        B>N? `H ?; CSTR 1- ;SPC    TYPE ;
: DBG  CR POP J H. PUSH J H. I H. `6N I @ ?ID. /DBG ;
: [D]` CR POP J H. PUSH J H. I H. `N3 HERE H. TD @ H. `PREFETCH
 STK? . SPACE >NF< ID. TD @ ID. HERE 2- @ ?ID. /DBG ;
: .CODE ;2DROP ;FND DROP J N>C @+ >PRINT ; : .WORDS ;2DROP ;FND
DUP >PRINT ; : .NAMES ;2DROP ;FND J IN-STR> >PRT? ; : HIDE
-FIND ??# 1+ '` : CSWAP! SWAP C! ; : HIDE-TEST -FIND IF ID. ;
 THEN DROP ;


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
: =" '" WORD : >ZSTR CSTR '| S! ; : ;File >ZSTR 1+ D0 EX IO?
 _AX ; : FOPEN ;File Fopen ; : FCREATE ;File Fcreate ;


{ STREAMS }
: AUTO { NAME -- AUTO\NAME.CF} " NF10\AUTO\"  +"  " .CF" "+! ;
: FGET Fbuf CALL DROP  cr : EOS! bs TO EOS ;THEN
  AT Fbuf 1 AT HANDLES TOP  Fread  _AX 0;  { IF EOF THEN EOS}
  DROP Fbuf  DUP $1A XOR 0; RDROP  ; : ;EOS EOS XCHG 0 TO EOS
  EXECUTE POP TO EOS ; : ;FILE TO HANDLES AT KEY @ XCHG PUSH
 LIT FGET TO KEY EX POP TO KEY     : HCLOSE HANDLES Fclose ;
: ;NOEMIT LIT DROP; : ;EMIT! LIT TO EMIT
: ;SAFE! DUP XCHG OVER @ PUSH PUSH ! EX POP POP ! ;     : NEEDS
EXIST? 0<>; TBUF : INCLUDED AUTO FOPEN ;FILE D0 ;0TI
;EOS BEGIN vINIT EVAL EOS UNTIL ; : INCLUDE TOKEN? INCLUDED ;
: FTYPE TOKEN? FOPEN ;FILE ;EOS BEGIN KEY EMIT EOS UNTIL ;
: CLOSE_ALL    AT HANDLES ITEMS? LOOPS HCLOSE ;



INCLUDE C5_FLUSH
INCLUDE C5_DUMP
INCLUDE C5_EDIT
INCLUDE ENDBLOCK
 PRUNE
 HIDROP

M: C4 USING C4H.COM;
M: BBB USING BBB;
M: C5 USING C5H.COM;
M: PRB USING PROBA.COM;
M: PB5 USING PB5.COM;
M: NFC USING NFC.COM;
: T ;  PAGE 35 LOAD EGG


% ESQ  % DBG  % {` % \` %2 [D]` [D]`   %2 TRECURSE RECURSE`
%2 TTHEN THEN`  %2 T;GO ;GO`    %2 TIF IF`     %2 TCALL CALL`
%2 TFOR FOR`  %2 TNEXT NEXT`  %2 T<NEXT <NEXT` %2 TFOR> FOR>`
                %2 T;; ;;`      %2 T:; :;`     %2 T: :`
%2 T; ;`        %2 T?; ?;`      %2 TIF WHILE`  %2 TIND< IND<`
%2 TIND> IND>`  %2 TDO> DO>`    %2 TDO< DO<`   %2 TLOOP LOOP`
%2 T;THEN ;THEN`                               %2 TAHEAD AHEAD`
                        %2 TREPEAT REPEAT`     %2 TAGAIN AGAIN`
%2 TUNTIL UNTIL`        %2 TBEGIN BEGIN`       %2 T;THEN ]`
%2 TTWICE TWICE`        %2 TTO TO`             %2 TAT AT`
%2 TDOES> DOES>`        %2 CSWAP>` CSWAP>`     %2 TCALL [`
%2 T(DROP (DROP`        %2 TRDROP (RDROP`
%2 T@EXEC PERFORM`      $1FD =: ,<`     %2 T-IF -IF`



0 VALUE ENDH : S0 35 TO SCR 0 TO XY S ; : @I J @ ;
: ` PUSH  PUSH !TD- POP !TD- POP .C@ 1+ ;TD (MPUSH ;
: TWORDS  ;<D> WORDS ; : % 0 ' >NF< ` ;; : %2 0 ' TOKEN? ` ;;
' ' =: 'O  ' =H =: =HO   ' =: =: =:O  ' =, =: =,O
: TT? TOKEN? : TFND TD @ Dfnd ;
0 QUAN FOUND Z, : `@? AT FOUND : 2+@ 2+ @ ;
: `;RESULT AT FOUND 2+ ! HERE OFF EX HERE @ DUP TO FOUND CR . ;
: `DEF: C: : DOES> `;RESULT ;2DROP ;FND J NAME> 2+@ `@? PUSH ;
`DEF: DEF ODD = : `CNTR 0; J ID. HERE INC ;
`DEF: =USED 2/ = `CNTR ; `DEF: >USED 2/ U< `CNTR ;
' HERE =: H      0 TL !    { PREPARE FOR <H>}
: OBJ! TO H ; : ORG! H - TO HOFS ;  H ORG! { PREPARE FOR <H>}
: UNW ;DROP @H- ;



: HERE H R>T ; : TRECURSE TD @ N>C , ;
$498 =, `;E >, @H- EXEC EX HERE TO ENDH ;
'TO CSTK> (,X `M> `;E  ' CSTK> (,X `R> `;E
'TO <CSTK (,X `<M `;E  ' <CSTK (,X `<R `;E
: `MARK> MRK>` `M> ; : `MARK>< `MARK> : `<MARK HERE `<M ;
: `<RLS `<R , ; : `<RLS> `<RLS : `RELS> `R> : RLS. HERE SWAP! ;
' `RELS> =: TTHEN      ' `<MARK =: TBEGIN
: N: DUP : =, ;, : =H HERE : =: PUSH TT? NIP 0= IF 0 POP TBUF `
   ;THEN >NF< NAME> PUSH 2 I+@ ODD IF 2 I+@ 3 - 2 I+! BEGIN I
   WHILE @I J POP ! PUSH REPEAT : 2EXIT POP .EXIT ;THEN RDROP 1
   A" ALREADY DEFINED!" ;  : 3PICK PUSH OVER POP SWAP ;
: `CLRY XEP RLS. RLS. : WALLOT LOOPS Z, ;
: STACK: PUSH 3PICK 3PICK 3PICK POP
: STACK! =H PUSH , , , POP MRK>` MRK>` MRK>` `CLRY RLS. ;


M: `(JUMP (JUMP; '' ?M: `(;GO (;GO'     M: `(IF (IF;
M: `(CALL (CALL;     M: `(DROP DROP;    M: `(PUSH PUSH;
'" ?M: `(RET (;"     M: `(ABRT ((A";    M: `((" ((";
M: `((." ((.";       M: `(LIT (LIT;     M: `(CON (CON;
M: `(CON2 (CON2;     M: `(CON3 (CON3;   M: `(DEF3 (DEF3;
M: `(VAR (VAR;       M: `(SET (SET;     M: `(SET2 (SET2;
M: `(DEF (DEF;       M: `(DEF2 (DEF2;   M: `(NEST (:;
M: `(SKIP (SKIP;     M: `(-IF  (-IF;    M: `SCAN (BSC;
M: TRDROP POP (DROP; M: `BARY (BARY;    M: `WARY (WARY;
M: TTWICE CALL THEN; M: `(IF- (IF-; '' ?M: `CODE ;code'
M: `DZ#0 (DZ#0;      M: `DZ#1 (DZ#1;    M: `DZ#2 (DZ#2;
M: `J J; M: `I+ I+;  M: `I- I-;         M: `(DO> (DO>;
M: `(DO< (DO<;       M: `RDROP RDROP;   M: T(DROP IF THEN;
M: `(POP POP;        M: T@EXEC @ EXEC;  M: `(.RDR .RDROP;


: BS, CSTR : S, ;DROP LOOPS CSTR C, ;
: TAHEAD `(JUMP `MARK> ;        : T;GO `(;GO `MARK> ;
: TIF `(IF `MARK> ;             : TCALL `(CALL `MARK> ;
: TUNTIL `(IF `<RLS ;           : TAGAIN `(JUMP `<RLS ;
: T-IF `(-IF `MARK> ;           : TREPEAT `(JUMP `<RLS> ;
: TNEXT `(POP TTHEN             : TUNTIL- `(IF- `<RLS ;
: TFOR TAHEAD                   : TFOR> `<MARK `(PUSH ;
: T<NEXT `(POP TUNTIL- ;
: T;; `(RET STK? 0<>; EX ,<` ;  : `NUM?, NUM? : `LIT `(LIT , ;
: ;CSTR EX CSTR, ;              : TB-ABRT ;CSTR `(ABRT ;
: TB" ;CSTR `((" ;              : TB." ;CSTR `((." ;
: TIND< `J `I+ ;; : TIND> `J `I- ;; : TLOOP TNEXT `(.RDR ;
: TDO> `(DO> `MARK>< `(PUSH ;   : TDO< `(DO< `MARK>< `(PUSH ;



: `:=? T>R @ $497 = ;
' 2+ VECTOR TvTOC>.      ' `:=? VECTOR TvIS:?
: `x??x EX ??# : `(@H, @H- TvTOC>. ;
: `?? `x??x : `H@:? H 2- @ TvIS:? HERE ENDH <> AND ;
: T:; `?? TO <CSTK `(;GO `<RLS ;
: T; `H@:? T;; 0; UNW `(@H, TO <CSTK TAGAIN ;
: T;THEN T; TTHEN ;
: T?; `?? TO <CSTK TUNTIL ;

\ : T;CASE `(DROP BEGIN CSTK> DUP WHILE TO CSTK> TTHEN
\ REPEAT  DROP ; : TELSE TAHEAD CSWAP>` TTHEN ;
\ : T<NEXT `(NEXT `<RLS ;         : T-UNTIL `(-IF `<RLS ;
\ TCASE 0 TO CSTK> ;   %2 TELSE ENDOF` %2 TELSE ELSE`



: ALGN 1- SWAP 1- OR 1+ ; : ?DUP DUP 0; DUP ;
0 VAR `T_DATA  0 VALUE `T_HND     0 VAR `TOTAL
: TWRITE1 `T_DATA ! `T_DATA SWAP : TWRITE3 DUP `TOTAL +! `T_HND
 Fwrite CR _DX H. _CX . _AX . ;
: ADDZONE ;RNG> : ADDBLK BLOCK 1K TWRITE3 ;
: TSAVE  ESQ PRUNE ESQ  `TOTAL OFF TOKEN? FOPEN
            {  FCREATE} TO `T_HND   TD 2+ H OVER- TWRITE3
  2  TD @ " --END--" TFND ??# DROP >NF< SWAP - 1+ TWRITE1
   TD @   `T_DATA @ 1-  TWRITE3               1 0 TWRITE1 ; {
`TOTAL @ 1K ALGN `TOTAL @ - ?DUP IF 63 BLOCK SWAP TWRITE3 THEN
   1 9 ADDZONE    35 62 ;RNG> ADDBLK ; }





 "BSCAN `SPEC? ,T ",!. : TERR. TO STATE vERR ;
0 WARY `STR  >, CSTR, BS, TERR. ". ,<
0 WARY `STR, >, TB" BS, TB-ABRT TB." ,<    : STR- 1- XEP 1+ ;
: `OK" OVER C@ '" - NOP ?; OVER 1+ C@ '" <> STR- ?; ;;
: `STR@ [ TO XK ] XK XEP CSTR `OK" 2- OVER C! SBUF "PACK ;
: STR? DUP NAME> 1- C@ '" = PUSH DUP 1+ C@
                `SPEC? DUP 1- TO XK   0 <> POP AND ;
: `NUM STR? NUM? ?; `STR@ XK `STR @EXEC ;
: `NUM, STR? `NUM?, ?; `STR@ XK `STR, @EXEC ;
: `EXE >NF< NAME> PUSH 2 I+@ ODD IF POP A" NOT DEFINED!" ;THEN
 RDROP EXEC ; : `COM >NF< NAME> PUSH 2 I+@ ODD IF DROP
 H @I , POP ! ;THEN RDROP , ;




: `T =H >, EX ,<` , ;  : `2ARY 2* : `ARY =H >, EX ,<` CLARY ;
: CREATE UNW :; : VARIABLE 0 : VAR `T `(VAR ;
: QUAN `T `(CON3 : `Q `(SET2 `(VAR ; : `;>INT< ,<` EX >, ;
: VQUAN `T `(DEF3 `Q ;  : SCAN"C =H >, `SCAN ,<` ;
: VALUE `T `(CON2 : `S `(SET ;
: VECTOR `T `(DEF2 `S ;
: DEFER `T `(DEF ; : CONST `T  `(CON ;
: D# >, EX @H- HERE SWAP : CALL, $E8 : ,R C, HERE 2+ - , ;
: 0#> D# `DZ#0 ; : 1#> D# `DZ#1 ; : 2#> D# `DZ#2 ;
: TDOES> `CODE 0#> DROP ;
: HERE! HERE - ALLOT ;
: CALL! ;HERE XEP HERE SWAP HERE!  CALL, ;
: TINIT CALL `NUM `EXE `NUM, `COM THEN OPER! ;
: BARY `ARY `BARY ;  : WARY `2ARY `WARY ;


































{ C5H  CED} FORGET T CREATE T  25 32 THRU
: STOP LIT TO ESQ @  LIT C: ; - 0; MARK@ HIDROP INITO ;
: START STOP : EGG PAGE 18000 HIPUSH 24 LOAD MARK!
 FX C: NOP TO ESQ <H> TINIT TARGET,! 40 62 THRU ;; ' : =:O :O
: `I' `;>INT< : ' TT? ??# ; : `ITO `;>INT< : 'TO ' 2+ ;
: META ' 'TO : T! T>R ! ;
: THACK ' T?ID! @HACK ; : TSEE ' T?ID! @SEE ; : TDEF ;<D> DEF ;
: T=USED ;<D> =USED ; : T>USED ;<D> >USED ; : THIDE ;<D> HIDE ;
: TTO `ITO , ;  : TAT `ITO 2+ , ; : 'AT 'TO 2+ ;
: T: `(SKIP  =H `(NEST TWICE DICT : USED+ NAME> 2+ INC ;
: =! 0 =: TD @ USED+ ; : APT- ' THIDE :; : REUSE >LT< TO LTIB ;
: APT2 APT- : APT THIDE REUSE =: ;
: : ZCSTK =H >, `(NEST ;;      PRUNE



: ;MAX 2DUP EX IF  XEP THEN DROP ; : UMAX ;MAX U< ;
: UMIN ;MAX : U>= U< 0= ; : MAX ;MAX < ;
: CLARY H OVER ERASE : ALLOT ;H + ; : META ' : TO! 'TO ! ; : TO
'TO EXEC ; : AT 'AT EXEC ; : TO@ 'TO @ ;
: 2* DUP + ;
: 2*I+ 2* : I+ J + ; :
2*I- 2* : I- J - ; : C@I J C@ ;  : `(: =H CALL EX @EXEC ;
: `MKR =0, , EX ,' ; : 2MKR `MKR , DOES> `(:  : W, THEN STR , ;
: 1MKR `MKR DOES> `(: ; : 3MKR `MKR , , DOES> `(: W, W, ;























;RNG> LOAD ; : +THRU ;RNG> +LOAD ; : CHARS ;RNG> DUP EMIT . ;
: RBLOCKS -R;DR ;RNG> BLOCK OVER  : `KMOVE 1K CMOVE 1K + ;
: WBLOCKS -R;DR ;RNG> NUP BLOCK UPDATE `KMOVE ;













N: :J "J" N: :I+ "I+"  N: :I- "I-"         N: :(IF-  "(IF-"
N: :(RET "(;" N: :(ABRT "((A""" N: :((" "((""" N: :(BSC "(BSC"
N: :(JUMP "(JUMP"      N: :(;GO  "(;GO"    N: :(IF   "(IF"
N: :(OF   "(OF"        N: :DROP  "DROP"    N: :PUSH  "PUSH"
N: :(CALL "(CALL"      N: :(LIT  "(LIT"    N: :(CON  "(CON"
N: :(CON2 "(CON2"      N: :(CON3 "(CON3"   N: :(DEF3 "(DEF3"
N: :(VAR  "(VAR"       N: :(SET  "(SET"    N: :(SET2 "(SET2"
N: :(DEF  "(DEF"       N: :(DEF2 "(DEF2"   N: :(NEST "(:"
N: :(SKIP "(SKIP"      N: :(DROP "IF_THEN" N: :EX    "EX"
N: :(BARY "(BARY"      N: :(WARY "(WARY"   N: :POP   "POP"
N: :((."  "((."""      N: :(LARY "(LARY"   N: :CODE  ";code"
N: :(DZ#0 "(DZ#0"      N: :(DZ#1 "(DZ#1"   N: :(DZ#2 "(DZ#2"
N: :(DO>  "(DO>"       N: :(DO<  "(DO<"    N: :RDROP "RDROP"
N: :(VAR3 "(VAR3"      N: :(VAR2 "(VAR2"   N: :(1-   "IF-_THEN"
N: :(RDROP "POP_(DROP" N: :.RDRP ".RDRP"   N: :(-IF "(-IF" DROP

$100 ORG!  0 BLOCK H 1K CMOVE 1K 8 - ALLOT  201 =: --END--
$1D7 =: @R+     $24F =: (;      $444 =: PUSH    $1E5 =: XCHG
$1EA =: DUP     $253 =: POP     $241 =: J       $4C8 =: (IF
$249 =: (JUMP   $120 =: TBL     $124 =: TIB     $128 =: TBUF
$497 =: (:      $491 =: (DZ#0   $490 =: (DZ#1   $48F =: (DZ#2
$40C =: (CON    $40B =: (CON2   $40A =: (CON3   $24B =: (SKIP
$40E =: (VAR    $41B =: (SET    $41A =: (SET2   $470 =: (DEF
$46F =: (DEF2   $46E =: (DEF3   $4AB =: (WARY   $4AD =: (BARY
$4A9 =: (LARY   $10C =: EMIT    $110 =: SOURCE  $114 =: ACCEPT
$118 =: vOK.    $11C =: vERR    $12E =: BYE     $130 =: BL
$134 =: vINIT   $13A =: H       $140 =: ETIB    $146 =: LTIB
$14C =: T       $152 =: CNTC    $158 =: MESSAGE $483 =: EXEC
$4E2 =, 2+      $3FE =, `AN     $4EB =, `NOT    $4EA =, `NG
$401 =, `XOR HERE $4B4B , $F0EB , DUP =, 2-       1 + =, 1-
$1CE =, U< $DF2B , $E4EB ,   HERE 2+ =, 0< $E3D1 , $DEEB ,

$42A =: `!+ $424 =: `C!+ $165 =, RESTART                 : (LIT
@R+ ; $4E3 =, 1+ $3EC =, `ROT : -ROT `ROT : ROT `ROT ;  : 2 2 ;
0 VALUE `REGA HERE 2- =: `REG : XA POP `REGA XCHG TO `REGA PUSH
; @' DUP =, +2/ ,"^CZ~^K~S~Q~[~C~" : (CALL @R+ PUSH ; : NOP  ;
: EX POP XCHG : EXECUTE PUSH ; : 2-DXEP 1- : 1-DXEP 1- : DXEP
DUP : XEP XCHG EXECUTE POP ; : DXEP1+ DUP 1+ XEP ; : A-L XEP
: I- J : - `NG : + +2/ : DROP (DROP ; : SRCA XEP : A+L XEP : I+
J + ; : (;GO @R+ XCHG PUSH ; : `ND `AN `NOT ; : 2* DUP + ;
: 16/ TWICE : 4/ TWICE : 2/ 0 : AVR +2/ : NIP PUSH (DROP POP ;
@' DUP =, +*  ,"v~B~^At^D^C^^" ' `REG , ,"Q~[~Q~Z~C~"
@' DUP =, -/  ,"Q~b~Q~S~^K~^N" ' `REG , ,";Y~r^C+Y~BC~" : I J ;
: U* DROP :; : UM* TO `REGA 0 TWICE TWICE +* +* +* +* ; : U/
DROP :; : (/MD TO `REGA : (/M 0 : (Z/M TWICE TWICE -/ -/ -/ -/
; : UMOD (/MD NIP ; : U/MOD (/MD : SWAP PUSH : XPOP XCHG POP ;
: @- 2-DXEP : @ PUSH @R+ : EXIT POP (DROP ;

: C@+ DXEP1+ : C@ @ : W>B 255 : AND `ND : NOT DUP : NAND `ND ;
: !R+ XCHG POP POP `!+ : 2PUSH PUSH PUSH ; : NUP XEP DUP ;
: -R;. -ROT : ;DROP EX DROP ; : ;2+ EX 2+ ; : `;4+ EX 4 + ;
: CSTR C@+ SWAP ; : D>NAME DUP : >NAME `;4+ : NAME> CSTR + ;
: (?S J POP POP NAME> 2PUSH ; : ((" (?S ;; : CC! 1+ `C!+ 2-
: C! `C!+ DROP ; : C!+ DXEP1+ C! ; : USTR XEP : STR PUSH @R+
XCHG POP ; : SUCSTR SWAP : UCSTR XEP CSTR ; : C!- 1-DXEP C! ;
                                            : !- 2-DXEP : !
PUSH !R+ EXIT ; : !+ PUSH !R+ POP ; : @+ PUSH @R+ POP ; : ;NIP
EX NIP ; : 2DUP TWICE : OVER PUSH DUP XPOP ; : TUCK DUP : USWAP
XEP SWAP ; : .RDROP DROP : RDROP POP XCHG DROP ; : 2PICK PUSH
OVER XPOP ; : A! PUSH XA EXIT ; : A@ XA I XA ; : NEG 1- NOT ;
: OR NOT PUSH NOT POP  NAND ; : ODD 1 `AN ; : OVER+ OVER + ;



ZDO VECTOR 6 TIMES    vLOAD `DO v",  vNUM vLIT,  vSAME?

ZDO VALUE 11 TIMES  HLD BASE _AX _BX _CX _DX _FR EOS BLK SCR XY
ZDO VALUE 9  TIMES  HOFS >LT< >CF< HDICT ENDH STATE >NF< `5 AER
ZDO QUAN  1  TIMES  Fbuf
#DO CONST 5  TIMES  1024 1K  16 1H  1 1  $7C NPAD  $E000 FIRST
#DO CONST 5  TIMES  13 cr  10 lf  8 bs  $FD00 SBUF 128 CMDLN
#DO CONST 5  TIMES  '- sgn  256 1B  0 @EMT  64 1L  3 3
0 VQUAN KEY     'TO EMIT DUP @ =: (DE  'TO @EMT T!
HERE @' STR =, (BK ,"1[~^S~M~^V^H@~t^B0d~^S~C~" VALUE DFLTKEY
HERE @' (DE =, (BE ,"^V~1[~4~^NM~^P^V~C~"       VALUE DFLTEMT
: 0<; 0< : 0<>; NOP ?; EXIT ; : 0>=; 0< : 0; EXIT ?; ;
0 QUAN `CBF : W>BB TO `CBF AT `CBF : CC@ C@+ C@ ; : U1- XEP 1-
; : BB>W AT `CBF CC! `CBF ; : CSTR- 1- : .C@ DUP C@ ; : C!I J
C! ; : ?<> OVER : OVER- OVER - ; : C@- 1-DXEP C@ ; : C@I J C@ ;

$44B =, ?BL. ,"^@~{~_s^B3~.C~"  HERE 2+ =, (IO ,"^H~^^" HERE 12
+ , ,"V^T~[Y"_^T~^W~^R~WM~^P"_^W~^T~RQSW^\~^T~" $461 $E9 ,R
: 16/MOD DUP 16/ XEP 15 `AN ; 0#> C@ (IO TO _FR TO _AX TO _BX
TO _CX TO _DX ; N: (DOS $21 C, N: (VID $10 C, =, (KBD $16 C,
: XDROT XEP : DROT ROT :; : D0 0 0 ; : HOME D0 ;  : @XY BB>W D0
$200 (VID ; 0#> @ XDROT (DOS ; N: Fsize $4202 , N: Fpos $4201 ,
=, Fclose $3E00 , 0#> @ (DOS ; N: Fread $3F00 , N: Fseek $4200
, =, Fwrite $4000 , 0#> @ DROT (DOS ; N: Fopen $3D02 , : ReadLN
TIB 1L ACCEPT ; =, Fcreate $3C00 , : ;BLKTI 1K OVER AHEAD
                                                       : ;MEMTI
A+L 0 THEN BLK XCHG LTIB PUSH ETIB PUSH PUSH CALL EX POP POP
POP THEN TO BLK TO LTIB TO ETIB : /BLK BLK 0; 0 TO ETIB ;
: ;LTIB LTIB EX TO LTIB ; : ;H H EX TO H ; : XY? 1K LTIB - ;
: ;HLD HLD EX TO HLD ; : LT0 RDROP : INTIB ETIB LTIB A-L ;
: ;, EX : , ;H !+ ;

: (DO< DUP AHEAD : (DO> OVER 1- THEN XCHG PUSH - : (GO @R+ XCHG
DROP ;
: .SKIP DROP   : SKIP @R+ DROP ; : (IF- 1- : (-IF DUP 0< (GO ?;
SKIP ;
: `FOUND XCHG DUP TO >NF< DUP NAME> TO >CF< DUP C@ : 2EXIT POP
: .EXIT POP : 2DROP NAND DROP ; : ;2DROP EX 2DROP ; : ;?I AHEAD
: ;?C >NAME THEN PUSH C@I IF DUP J EXECUTE `FOUND ?; POP
RECURSE ;THEN 0 2EXIT ; : .LOOPS XCHG POP AHEAD  : ..LOOPS XCHG
POP : ..TIMES ;DROP : .TIMES THEN ;DROP : TIMES PUSH XCHG
: LOOPS FOR J EXECUTE NEXT .EXIT ;               : IXEC J PUSH
; : ;ZUNTIL IXEC EXIT ?; RECURSE ; : ;UNTIL BEGIN IXEC UNTIL
EXIT ; : ?SKIP DUP DROP ?; SKIP ; : S>RNG OVER+ 1- ;   : `T POP
`5 XCHG TO `5 PUSH : R>DO 1+ SWAP ; : ;STR> S>RNG : ;RNG> `T
DO> IND> `5 EXECUTE LOOP AHEAD : ;STR< S>RNG : ;RNG< `T DO<
IND< `5 EXECUTE LOOP THEN POP TO `5 ;

: ((." (?S : ". CSTR : TYPE .LOOPS CSTR EMIT ; : ;[] ."[" EX
."]" ; : ERR! BLK 0; BLK TO SCR 0 TO BLK XY? : >XY 1K 1- AND
TO XY ; : ;SPC EX : SPACE BL EMIT ; : ;CR EX : CR ."^M^J" 0
TO CNTC ;   : ALPHA [ + '0 + ] : 9>? 9 OVER U< 7 `AN ;
: `?SPC NPAD HLD - - : SPACES LOOPS SPACE ; : ID. ;SPC ". ;
: ?S. XEP XEP : 3ROT SPACE 3 LOOPS ROT DUP : H. W>BB CALL : B.S
 ;SPC : B. THEN 16/MOD TWICE ALPHA EMIT ; : ?R. POP POP POP POP
 3ROT PUSH PUSH 2PUSH ; : [ID] CSTR : [S] ;SPC ;DROP : [TYPE]
;[] : TYPE+ LOOPS CSTR ?BL. EMIT ; : "TB. TBUF : "2T. CR ?R.
?S. SPACE SWAP ID. [ID] : BK (BK DROP ; : ADRS. CR DUP H. SPACE
; : U16? 1H : UN? U/MOD SWAP 0; 1+ ; : BDUMP ;SPC .LOOPS CSTR
B.S ; : DUMP U16? .LOOPS : DU ADRS. 1H 2DUP BDUMP [TYPE] ;
: [INTIB] INTIB [S] ;



: ((A" (?S SWAP DROP ?; TO MESSAGE H TO AER  POP , POP , POP ,
POP , POP , POP , POP , POP , POP , POP , AER TO H RESTART ;
: = - : 0= IF : 0 0 ;THEN : -1 -1 ; : <> - : 0<> 0 ?; -1 ;  : <
- 0< ; : .ABLE DUP BL 1B : WITHIN OVER- PUSH - POP U< ;

: ;HLD, EX : HLD, ;HLD C!+ ; : C@HLD- ;HLD C@- ;
: # BASE U/MOD SWAP ALPHA : HOLD ;HLD C!- ;
: <# NPAD TO HLD : BASE! 2- W>B 2+ TO BASE ; : ;<#> <# EX `?SPC
: #> DROP HLD NPAD OVER- TYPE ; : `6 DUP 0< 0; NEG EX sgn HOLD
; : U. 0 : U.RS ;SPC
: U.R lf : U.R# ;<#> : u. 31 AND XEP  : S# ;ZUNTIL # DUP ;
: . 0 : .RS ;SPC : .R lf : .R# ;<#> SWAP `6 SWAP u. ;




: >HERE H NUP !+ : MOVM ;DROP : (MOVM ;NIP SWAP LOOPS UCSTR C!+
;  : >SBUF! SBUF : >"! DXEP : >" OVER C@ 1+ : CMOVE SWAP MOVM ;
0#> C@ : FILL -ROT ..LOOPS NUP C!+ ; N: ERASE 0 C, =, BLANK BL
C, : (S! DXEP NUP C!+ (MOVM ;

: CMOVE> A+L SWAP ;DROP : (MPUSH SRCA SWAP ;NIP LOOPS PUSH
CSTR- POP C!- ; : >ZSTR CSTR CMDLN : S>"! (S! SWAP : OFF 0
: SWAP! SWAP ! ; : ON -1 SWAP! ;
: IO? _FR ODD !":IO?_" ; : `@BNDS? @+ @ WITHIN 0= !"BNDS!" ;
: `;STK `@BNDS? : ;@! @+ XCHG EXECUTE POP !- DROP ;
: S+! XEP TUCK J STR + SWAP CMOVE J  : +! ;@! + ;
: "+! SUCSTR DXEP NAME> (MOVM : L"! J NOT + J C! ;
: "+C! SWAP DXEP NAME> C!+ L"! ;
: AUTO PUSH "NF10\AUTO" >SBUF! "\" "+! POP "+! ".CF" "+! ;


$40E 1#> DUP @+ `;STK !+ ; 2#> DUP STR 2- SWAP `;STK @- ; : ZST
DUP 2+ @ SWAP! ; : ITEMS@ DUP 2+ @ SWAP : ITEMS? @+ @ - 2/ ;
20 STACK: HANDLES  20 STACK: CSTK>  20 STACK! <CSTK
: TOP@ AT HANDLES @ @- DROP ; : >gpt TO Fbuf : gpt AT Fbuf 1 ;
: `ER CR TBUF ID. MESSAGE ID. CR ;
: `OK ."_Ok"  CR .">>" ; : ;?# EX : ??# 0= : ?? !"?" ;

: HP ;2+ : HERE H : R>T HOFS + ; : T>R HOFS - ; : C, ;H C!+ ;
: TRKS ;, : LATEST T : N>C NAME> @ ; : (TYP N>C @ ; : ;code POP
: TOBE LATEST ! ; : ALIGNED ;H : ALIGN 1- SWAP 1- OR 1+ ; : BS,
CSTR : S, .LOOPS CSTR C, ; : CSTR, CSTR : STR, v", DUP C, S, ;
: UPC '` OVER U< 0; $DF AND ;
: ?DGT UPC '0 - 9>? DUP IF - DUP lf U< THEN OR DUP BASE U< ;



{ SCAN ACCEPT & PARSE} : `XSC POP : `XSC2 1+ NIP EXIT ;
: BI?~> J : B?~> PUSH FOR CSTR J = `XSC ?; NEXT `XSC2 ;
: BI?> J : B?>  PUSH FOR CSTR J - `XSC ?; NEXT `XSC2 ;
: BI?< J : B?< PUSH A+L  FOR CSTR-  J - `XSC ?; NEXT `XSC2 ;
: W?< PUSH A+L A+L FOR @-   SWAP J - `XSC ?; NEXT  `XSC2 ;
: W?> PUSH FOR STR J - `XSC ?; NEXT  `XSC2 ; : `ONcr NIP DUP ;
0#> PUSH XCHG CSTR BI?< DUP XPOP ?; EXIT ; =: (BSC
: TOKEN? BL : WORD? ;?# : `WORD [ TBUF (S! '` ROT C! .C@ ]
: PARSE W>B PUSH LTIB TO >LT< SOURCE I BL = IF INTIB BI?~>
TO LTIB THEN LTIB LT0 ?; INTIB 2DUP BI?> DUP DUP IF 1- THEN
                                             TO LTIB - EXIT ;
: `ONbs 2PICK OVER- 0; 1- ."^H_^H" ; SCAN"C `CTBL0 "^M^H^@"
: `ONchar .ABLE DROP ?; DUP EMIT SWAP C!+ ;
0 WARY `FNtbl >, `ONchar `ONcr `ONbs NOP NOP ,< : AC OVER+ OVER
[ DROP OVER- ] ;ZUNTIL KEY `CTBL0 `FNtbl PERFORM ?<> ;

{ SEARCH COMPARE}  : LOC! POP TO STATE ; : LOCATE STATE PUSH ;
: C<@> PUSH CSTR XCHG CSTR XCHG POP - ;  : FNDC T ;?C AHEAD
: `-TEXT0 POP : `-TEXT1 1+ : 2NIP XEP 2DROP ; : AT' ;2+   : TO'
;2+ : ' ;?# : T? TOKEN? : FND T ;?I THEN J  : "- OVER C@ 1+ FOR
C<@> IF `-TEXT0 ;THEN NEXT `-TEXT1 ;   : MEM- FOR C<@> IF RDROP
U1- 1- C<@> 2NIP ;THEN NEXT `-TEXT1 ; : INC ;@! 1+ ; : DEC ;@!
1- ; : EXI?T 0<>; :;  : EXIST? T? NIP ;  : `COMP DUP DEC FNDC 2
?; N>C 3 ; : >, LOC! DUP INC FNDC `COMP ?; AHEAD
: T,< LOC! FND 0 ?; THEN N>C 1 ;
: \ ;LTIB DUP 0; 1- : L/ 1L NEG AND ; : { '} PARSE 2DROP ;
: SAME? TBUF FND NIP 0; TBUF [ID] : ?BLK. BLK 0;
: BLK. '# EMIT BLK . ;
: ?", WORD? CSTR, ; : STR- 1- XEP 1+ ; : =" '" WORD? >ZSTR ;



{ NUMBER PARSER} 0 VALUE SR1 : ZSR1 0 : >SR1 SR1 XEP TO SR1 ;
 SCAN"C `NUM' "#$%'"^^@" : `..ERR DROP : `.ERR DROP : `ERR
;LTIB 1- ; 0#> @ BASE! : ``ERR SR1 `ERR ?; ; N: `HEX 16 ,
=, `BIN 2 , : `DGT ?DGT `.ERR ?; : `*+ SWAP BASE U* + ;
: `RADIX ``ERR :; BASE! 0 ; : `C- OVER C@ '- - 0<>; STR- EX XEP
NEG ; : `NUM ZSR1 DUP `.ERR ?; `*+ ; : CHARS ;RNG> DUP EMIT . ;
: `^NUM ZSR1 DUP `.ERR ?; 31 AND `*+ ; 0 WARY `NUMA >, `DGT
 `RADIX `HEX `BIN `NUM `^NUM NOP  ,< : `;INI 0 INTIB 0 TO LTIB
0 TO SR1 TUCK OVER+ 1- lf TO BASE ROT EX ZSR1 AHEAD  : (NUM `C-
 ;MEMTI [ LTIB ] `;INI `..ERR ?; ;RNG> C@ >SR1 THEN `NUM' `NUMA
PERFORM ; : NUM? CSTR vNUM ?? ; : NUM?, NUM? vLIT, ;
 0 WARY OPER[] >, NUM? EXEC NUM?, , ,<




{ STREAMS } 26 CONST eof : ;HCLOSE EX : HCLOSE HANDLES Fclose ;
: ;File >ZSTR 1+ EX IO? _AX ; : FOPEN ;File Fopen ; : FCREATE
;File Fcreate ;
: Fget [ cr : EOS! eof TO EOS ] gpt TOP@ Fread _AX 0; Fbuf  eof
- 0; RDROP Fbuf ; : Fput >gpt TOP@ Fwrite ; : ;@OPENI FOPEN
TO HANDLES @R+ AT KEY @ XCHG EOS PUSH PUSH TO KEY 0 TO EOS EX
POP TO EOS POP TO KEY HCLOSE ; : ;@CREATE FCREATE AHEAD
: ;@OPEN FOPEN THEN TO HANDLES : ;@!EMIT @R+ @EMT @ XCHG PUSH
 CALL EX POP THEN @EMT ! ; : >SVL >LT< : >SEVL XEP : SEVAL CSTR
: EVAL ;MEMTI : EVLP BL `WORD DROP ?; LOCATE OPER[] PERFORM
RECURSE ; : NEEDS EXIST? 0<>; TBUF : INCLUDED AUTO ;@OPENI Fget
D0 ;MEMTI ;@!EMIT (BE BEGIN ReadLN CR EVAL EOS UNTIL ;
: FTYPE TOKEN? : FTYPED ;@OPENI Fget BEGIN KEY EMIT EOS UNTIL ;
: ALL_CLZ AT HANDLES ITEMS? LOOPS HCLOSE ; : INCLUDE TOKEN?
INCLUDED ;

{ STRING COMPILATION}            : ?DUP DUP 0; DUP ; : ;SB,
CSTR OVER+ 1- H 2+ TO HLD 0 HLD, 0 TO SR1 EX HLD H 2+ PUSH I
NOT + C!I POP ; SCAN"C `CTBL ,T "^~_ SCAN"C `Ctbl2 "^@"""^"~"_"
: "UPK ;SB, ;RNG> C@ DUP 128 AND IF 128 - '~ SWAP ;HLD, THEN
DUP ;HLD, `CTBL IF '" HLD, ;THEN BL = IF DROP '_ ;THEN DUP BL
U< 0; '^ HLD, '@ + ;
: `" ZSR1 ?DUP 0; HLD, ; : `^ ZSR1 ?DUP 0; 31 AND HLD, ;
: `~ C@HLD- 128 + HLD, ; : `_ BL HLD, ;
0 WARY `tbl >, HLD, NOP `" `^ `~ `_ ,< : `cTBL1 ZSR1 AHEAD
: "PK ;SB, `cTBL1 :; ;RNG> C@ >SR1 THEN `Ctbl2 `tbl PERFORM ;
: ;T T EX TO T ; : `ADR XEP 0 TWICE : !T- ;T !- ; : N: DUP : =,
   ;, : =H HERE : =: TOKEN? vSAME? : (=: `ADR .C@ 1+ : >DICT ;T
   (MPUSH ;



: M: '; : ?M: 0 =, ?", DOES> SEVAL ;  : `(LIT, (LIT (LIT , , ;
' (NUM 'AT vNUM T!   ' `(LIT, 'AT vLIT, T!  META NOP SOURCE
META `OK vOK.   META `ER vERR   ' (BE 'TO EMIT T!
META AC ACCEPT  ' (BK 'AT KEY 2+ T!     ' SAME?  'AT vSAME? T!
: PutER  >gpt 2 Fwrite ; : ERR. 0; ;@!EMIT PutER vERR ;
0#> AHEAD : (>M: (?S THEN STATE >, >SEVL TO STATE ; =: (MAC:

HERE 'AT vINIT T! >, H STR >DICT  CMDLN CSTR ;GO TO vINIT
DFLTKEY TO KEY DFLTEMT @EMT ! ALL_CLZ { ERR!} MESSAGE vERR
ReadLN THEN T,< : `QUIT SPACE EVAL vOK. ReadLN RECURSE ;






0#> C@ HDICT + ; N: TL 2 C, N: TH 4 C, =, TD 6 C,
: ;TD TD @ EX TD ! ; : !TD- ;TD !- ; : >NUM TOKEN? NUM? ;
: EDICT T (SKIP BEGIN >NAME DUP C@ 0= UNTIL 1+ ; : `EG T  EDICT
OVER- >HERE EX H STR HDICT ?SKIP FIRST (MPUSH TO T ;   : HIPUSH
`EG PUSH HDICT DUP ?SKIP FIRST 10 I + - DUP TO HDICT !+ XCHG  0
!R+ TD 2+ DUP !R+ + DUP POP ! OFF ; : HIDROP HDICT 0; `EG HDICT
@ TO HDICT ; : `AT@ ' TO `DO POP ; : ZDO `AT@ 0 `DO ; : #DO
`AT@ >NUM `DO ; : 'DO `AT@ ' `DO ; : DO `AT@ `DO ; : +DO `AT@
DUP `DO OVER+ ; : FORGET ' TO H >NF< >NAME TO T ;
0 VALUE `ROWS : `EOL? DUP DUP TO >NF< TO >CF< C@ CNTC + 72 U<
0<>; ;CR `ROWS 1- DUP TO `ROWS 0<>; (BK 27 - TO >CF< : `ROWS! 6
TO `ROWS ; : WORDS T : >WORDS CR ;2DROP `ROWS! 0 SWAP ;?I DROP
J `EOL? J N>C H. J ". >CF< 13 : ALI CNTC OVER UMOD - SPACES ;



' (MAC:   39 LOAD
: `;STK> CSTK> EX TO CSTK> ; : CSWAP> `;STK> `;STK> SWAP ;
: `;<STK <CSTK : `< EX TO <CSTK ; : <CSWAP `;<STK `;<STK SWAP ;
: MRK> H : Z, 0 , ; : RLS> HERE SWAP! ; : `<M TO <CSTK AHEAD
: `M> TO CSTK> : `;E THEN EX : END! HERE TO ENDH ;
: `R> CSTK> `;E ; : `<R <CSTK `;E ; : <MARK HERE `<M ;;
: <RELS `<R , ; : RELS> `R> RLS> ; : MARK> MRK> `M> ;;
: UNW ;DROP : @H- ;H @- ; : (ZST AT CSTK> ZST  AT <CSTK ZST ;
: T;; :(RET  AT <CSTK ITEMS? AT CSTK> ITEMS? + 0<>; T,< ;
: T: (ZST : `TH: =H >, :(NEST ; : T:: :(SKIP T,< `TH: ;
: :=? @ $497 = ; ' 2+ VECTOR vADJ      ' :=? VECTOR vISW?
: `x??x EX ??# : `(@H, @H- vADJ ; : `?? `< `x??x : `H@:? H 2- @
vISW? HERE ENDH <> AND ; : T:; `?? :(;GO <RELS ; : T?; `??
: TUNTIL :(IF <RELS ; : T; `H@:? T;; 0; UNW `(@H, TO <CSTK
: TAGAIN :(JUMP <RELS ;    : T;THEN T; : TTHEN RELS> ;

: TDOES> :CODE :(DZ#0 @H- : CALL, $E8 : ,R C, HP - , ;
: D# (ZST >, EX @H- HERE SWAP CALL, ;
: 0#> D# :(DZ#0 ; : 1#> D# :(DZ#1 ; : 2#> D# :(DZ#2 ;
: TIF :(IF MARK> ; : TIF- :(IF- MARK> ; : T-IF :(-IF MARK> ;
: TNEXT :POP RELS> : TUNTIL- :(IF- <RELS ; : TIND> :J :I- ;;
: TFOR :(JUMP : MRK>< MARK>     : TFOR> <MARK :PUSH ;
: TDO> :(DO> MRK>< ; : TDO< :(DO< MRK>< ; : TIND< :J :I+ ;;
: TLOOP TNEXT :RDROP ;          : T<NEXT :POP TUNTIL- ;
: TAHEAD :(JUMP MARK> ;         : T;GO :(;GO MARK> ;
: TCALL :(CALL MARK> ;          : TREPEAT TAGAIN TTHEN ;
: ;CSTR EX CSTR, ;              : TB! ;CSTR :(ABRT ;
: TB" ;CSTR :((" ;              : TB." ;CSTR :((." ;
: AT  AT' EXEC ; : TO  TO' EXEC ; : TAT AT' , ; : TTO TO' , ;



APT2 TTO TO`        APT2 TAT AT`        APT2 TREPEAT REPEAT`
APT2 T<NEXT <NEXT`  APT2 TFOR FOR`      APT2 TFOR> FOR>`
APT2 TAHEAD AHEAD`  APT2 T;GO ;GO`      APT2 TIF IF`
APT2 T:: :`         ' RELS> APT THEN`   ' <MARK APT BEGIN`
APT2 T:; :;`        APT2 T;THEN ;THEN`  APT2 T;  ;`
APT2 T?; ?;`        APT2 TUNTIL UNTIL`  APT2 TAGAIN AGAIN`
APT2 T;; ;;`        APT- T: =: :        APT2 TRKS RECURSE`
APT2 TIND< IND<`    APT2 TIND> IND>`    APT2 TDO>  DO>`
APT2 TDO<  DO<`     APT2 TLOOP LOOP`    APT- TUNTIL- =: UNTIL-`
APT2 TNEXT NEXT`    APT- TIF- =: IF-`   APT- <CSWAP =: <CSWAP`
APT2 CSWAP> CSWAP>` APT2 T-IF -IF`      APT2 TCALL CALL`
' CALL` APT [`      ' { APT {`          ' IF` APT WHILE`
' ;THEN` APT ]`     ' \ APT \`          APT2 TDOES> DOES>`
APT2 T,< ,<`
HERE 'AT H T! TSAVE PB5.COM   SDFGSDF----2 CR 0 T=USED

































HERE 2+ =, (IO  ,"^H~^^" HERE 12 + ,
 ,"V^T~[Y"_^T~^W~^R~WM~^P"_^W~^T~RQSW^\~^T~" @' 2DROP; $E9 ,R

HERE 2+ =, (IO ,"^H~^^" HERE 12 + ,
 ,"V^T~[Y"_^T~^W~^R~WM~^P"_^W~^T~RQSW^\~^T~" $518 $E9 ,R











