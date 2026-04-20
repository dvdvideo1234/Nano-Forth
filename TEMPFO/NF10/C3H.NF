$24F =: ;       $10C =: EMIT    $22F =: :       $235 =: ;`
$27D =: =,      $259 =: <RLS`   $13A =: <MRK`   $201 =: CSWAP`
$203 =: DROP    $299 =: TOKEN?  $146 =: LTIB    $1EA =: DUP
$209 =: +       $3E2 =: !       $48B =: >,      $1FD =: ,<`
$247 =: RDROP   $12C =: 0       $140 =: ETIB    $3A9 =: (FND
$251 =: EX      $14C =: DICT    $249 =: (JUMP   $1D7 =: @R+
$444 =: PUSH    $253 =: POP     $1E5 =: XCHG    $2BB =: #??
$24B =: SKIP    $241 =: J       $245 =: (NEXT   $4B1 =: (FOR
$4C8 =: (IF     $205 =: OVER    $47F =: EXECUTE $207 =: -
$483 =: EXEC    $1C4 =: >DICT   $134 =: vINIT   $4C2 =: (#IF
$219 =: CSTR    $257 =: ;,      $1F8 =: @       $424 =: C!+
$273 =: ;HERE   $259 =: ,       $13A =: HERE    $201 =: SWAP
$114 =: ACCEPT  $158 =: STATE   $128 =: TBUF    $215 =: C@
$152 =: CNTC    $255 =: NIP;    $118 =: vOK.    $1F2 =: LIT
$20B =: STR     $269 =: NUM?    $23B =: #,`     $1AC =: DROP;
$27F =: =H      $487 =: @EXEC   $48D =: #DOES   $102 =: OPER[]
$11C =: vERR    $194 =: (A"     $42A =: !+      $2BD =: ??
$37A =: (S!     $29F =: PARSE   $29D =: WORD    $4B8 =: 0?SKIP
$4EF =: 0=      $36D =: (MPUSH  $1DD =: (?S     $39D =: (DE
$110 =: SOURCE  $130 =: BL      $1A8 =: ;DROP   $24D =: ABORT
$4E2 =, 2+      $3FE =, AND     $4EB =, NOT     $4EA =, NEG
$401 =, XOR HERE $4B4B , $F0EB , DUP =, 2-       1 + =, 1-
$1CE =, U< $DF2B , $E4EB ,   HERE 2+ =, 0< $E3D1 , $DEEB ,
$44B =, UM* $F793 , $92E2 , $C393 , : I J ;     $3EC =, ROT
$462 =, 2DROP $461 =, 2DROP;  $4E3 =, 1+     : -ROT ROT ROT ;
$CC00  $40B =, THERE $41B , , : OVER- OVER - ; : NAME> CSTR + ;
$2DA =, :` >, SKIP : ,< : C, ;HERE C!+ ; $441 =, `;#?? >, #?? ;
: ,' ;, : ' `;#?? TOKEN? : Afnd HERE DICT (FND ; : TO` ' 2+ , ;
: <!> HERE THERE TO HERE TO THERE ; : META ' : IS ' 2+ ! ;
: MRK>` HERE : Z, 0 , ; : RLS>` HERE : SWAP! SWAP ! ; : NOP ;
$2DF =, DEFER $470 , ,' ,  $2DF =, CONST $40C , ,' , <!> Z, <!>

$41B $46F =, vLOAD , Z, : ;1+ EX 1+ ; : ;CL+ EX 2+ ; : ;2CL+ EX
4 + ; 64 CONST 1L : L/ 1L NEG AND ; $40B =, BLK $41B , 0 ,
: \ BLK (#IF MRK> DROP LTIB 1- L/ RLS> TO LTIB ; : @' ' @  ;
: ..TIMES ;DROP : .TIMES ;DROP : TIMES PUSH XCHG
: LOOPS (FOR MRK> <MRK  J EXECUTE (NEXT <RLS RLS> RDROP ;
$44B =, ?BL. $FB80 , $7320 , $B302 , $C32E , : (." (?S
: ". CSTR : TYPE ;DROP : ?TYPE LOOPS CSTR ?BL. EMIT ;
: (CALL @R+ PUSH ; : 0<; 0< : 0<>; (IF MRK> : EXIT RDROP RLS> ;
: 0>=; 0< : 0; (IF TO EXIT ; 1024 CONST 1K  2 CONST #2 : 2* #2
: U* UM* DROP; ,< : 1K* 1K U* ;        3 CONST #3 ' 0 2+ =: BYE
: `MBLK 1K* $100 + ; ' `MBLK DEFER BLOCK   : `SRC ETIB BLK 0;
DUP 0<>; BLK XOR BLOCK 1K + DUP TO ETIB ; META `SRC SOURCE
: ;0TI 0 : ;TI BLK XCHG LTIB PUSH ETIB PUSH PUSH (CALL MRK> EX
POP POP POP RLS> TO BLK TO LTIB TO ETIB : /BLK BLK 0; 0 TO ETIB
; : LOAD DUP #?? 0 1K ROT ;TI vLOAD (JUMP ,< $182 ,

: D>NAME DUP : >NAME NAME> 2+ NOP ; : N>C  NAME> @ ; <!> : >,
>, ; : ;A, EX : A, #3 OPER[] @EXEC ; : HP HERE 2+ ; : W, ;A,
STR ; : DOES, 0 : DOES- #DOES SWAP - : CALL, $E8 C, : ,R HP - ,
; : >NUM TOKEN? NUM? ; : RECURSE` ;A, : LATEST DICT N>C ;
: `;code POP : TOBE LATEST ! ; : `(: =H W, EX @EXEC ; : `MKR =H
Z, , EX ,' ; @' ;` =, DOES>` >, `;code DOES, ,< : 1MKR `MKR
DOES> `(: ; : 2MKR `MKR , DOES> `(: W, ; : 3MKR `MKR , , DOES>
`(: W, W, ; $41B $40B 2MKR VALUE , $41B $46F 2MKR VECTOR ,
0 VECTOR `DO $40E $41A $46E 3MKR VQUAN , $40E $41A $40A 3MKR
QUAN , 0 VALUE THOLD HERE DOES, >, C@ HERE SWAP DOES- >, ;
           DUP DUP =, 0]> 0 C, =, 1]> 1 C, =, 2]> 2 C, <!> 0]>
C@ EMIT ;  1]> C@ ; <!> 2MKR CONST.C C, : `AT@ ' TO `DO POP ;
: #DO `AT@ >NUM `DO ; : DO `AT@ `DO ; : +DO `AT@ DUP `DO
: OVER+ OVER + ; : ZDO `AT@ 0 `DO ; : 'DO `AT@ ' `DO ;  <!>
: X` ' EXEC ;

: DXEP+ ;1+ : DXEP DUP : XEP XCHG EXECUTE POP ;
: DU+ DUP : U+ XEP + ; : ;RANGE OVER- 1+ : ;DROP EX DROP ;
: ," '" : ?, WORD : CSTR, CSTR : STR, ;HERE (S! DROP ;
: CODE: HP =, ;  : M: '; : ?M: CODE: ?, DOES>
: SEVAL CSTR : MEVAL DU+ ;0TI (JUMP ,< $182 , <!>
M: C4 USING C4H.COM; M: C3 USING C3H.COM;
: ID. ". : SPACE 32 EMIT ; : CR 13 EMIT 10 EMIT 0 TO CNTC ;
: (ERR CR TBUF ID. STATE ID. CR ; META (ERR vERR
<!> : THRU ;RANGE LOOPS DXEP+ LOAD ;
   6  9 THRU   { COMMON }         10 19 THRU   { COMPILER }
  56 59 THRU   { VIDEO KBD DOS  BUFFERS FILES FBLOCKS }
USE/ FBLOCK USING C3H.COM  { SWITCH TO FBLOCKS -> SELF READ }
  51 55 THRU   { EDITOR }         48 50 THRU   61 62 THRU
{ USING BBB  865 LOAD}
CR HERE .  HI.  DICT. .( BYTES)

@' DUP =, U/MOD  $C933 , $9291 , $F3F7 , $9193 , $C3 C,
: 2/ #2 : U/ U/MOD NIP; ,< : UMOD U/MOD DROP; ,< : @+ STR SWAP
; @' DUP =, SM*  $F793 , $92EA , $C393 ,  @' STR =, (BK $DB31 ,
$CD93 , $816 , $74C0 , $3002 , $93E4 , $C3 C, : (" (?S ;
 ' TOKEN?  VECTOR vTOK?     ' (BK VQUAN KEY  0 DEFER vALIGN
#DO CONST.C 7 TIMES  13 cr 10 lf 8 bs '- sgn '0 zr 32 bl 7 bel
ZDO VALUE 9 TIMES  BASE SCRH XY SCR LO^ HI^ >LT< >CF<  HDICT
#DO CONST 6 TIMES  256 1B 26 eof $7C NPAD 1 1 16 1H $E000 FIRST
: ;SPC EX : SPACE TO bl ; : ID. CSTR : (ID. ;SPC TYPE ; : CR
TO cr TO lf 0 TO CNTC ; : TWICE I PUSH ; : 9>? 9 OVER U< bel
 AND ; : ALPHA 9>? + zr + ;   : XY? 1K LTIB - ; : ;KEY EX KEY
: DROP; DROP ; : W>B 255 AND ; : B>HH W>B 1H U/MOD ; : W>BB
1B U/MOD ; : 1B* 1B U* ; : . DUP 0< (IF MRK> TO sgn NEG RLS>
: U. ;SPC : ` lf U/MOD 0?SKIP RECURSE : DIG. ALPHA EMIT ;
: H. W>BB (CALL MRK> : B. ;SPC RLS> B>HH TWICE DIG. ;

: (ERR CR TBUF ID. STATE ID. CR LIT (BK TO KEY BLK 0; BLK TO
SCR 0 TO BLK XY? : >XY 1K 1- AND TO XY ; : 2DUP OVER OVER ;
META (ERR vERR META CR vOK.
: (;GO @R+ XCHG PUSH ; : ;2DROP EX 2DROP; ,< : = XOR 0= ; : ;[]
'[ EMIT EX '] EMIT ; : [ID] ;SPC ;[] ". ; : EXI?T (;GO TO 0<>;
: EXIST? LTIB TO >LT< TOKEN? Afnd SWAP TO >CF< ; : SAME? TBUF
EXIST? 0; TBUF [ID] : ?BLK. BLK 0; : BLK. BLK . ; : (!R @R+ J +
! ; : (@R @R+ J + @ ; : ;+ EX + ; : ALIGNED ;HERE : ALIGN ;+
DUP : ODD 1 AND ; : CMOVE> SWAP OVER + (MPUSH DROP ;
: PLACE OVER C@ 1+ : CMOVE ;2DROP LOOPS PUSH CSTR POP C!+ ;
: EDGE HDICT DUP 0<>; DROP FIRST ; : ;EDGE DICT EDGE DICT - DUP
 HERE !+ SWAP CMOVE : ;(DICT EX HERE STR EDGE (MPUSH TO DICT ;
: HIPUSH ;EDGE PUSH HDICT EDGE POP 2+ - DUP TO HDICT !+ ;
: HIDROP HDICT 0; ;EDGE HDICT @ TO HDICT ;
: HI. $E000 EDGE - U. ;  : DICT. EDGE DICT - . ;

: COMPILE @R+ A, ;  : .( ') WORD ". ; <!> : `=, STR =, ;
: SHB BLK . XY? 1L U/MOD 1+ . . : SHC CR POP POP POP (CALL MRK>
PUSH PUSH PUSH SPACE ;KEY RLS> : SH3 3 LOOPS ROT DUP H. ;
 @' ;` =, A"` >, (A" ," ,< 0]> : `+ C@ ' + ;
1]> RECURSE , ; 2]> RECURSE EXEC ; =, TO =, TO` =, 'TO 2 C,
      ' TO `=, AT `=, AT` `=, 'AT 4 C, DROP <!>
: WAS ' 2+ @ ; : {` '} PARSE : 2DROP DROP DROP ; ' {` =: {
<!> M: FOR` (FOR MRK> <MRK;    M: NEXT` (NEXT <RLS RLS>;
M: IF` (IF MRK>; ' IF` =: WHILE` M: THEN` RLS>; M: BEGIN` <MRK;
M: AGAIN` (JUMP <RLS; M: AHEAD` (JUMP MRK>; <!>
: C@I  J C@ ; : (TYP N>C @ ; : CORA DUP C@ 1+
: -TEXT FOR PUSH CSTR XCHG CSTR POP = IF X -ROT NEXT -1 PUSH
 THEN 2DROP POP 1+ ;  : ;FND DICT AHEAD : ;FND2 BEGIN X SWAP
 >NAME THEN PUSH C@I IF X SWAP DUP J EXECUTE POP AGAIN THEN
     0 : EXIT2 RDROP (JUMP TO EXIT ;

 ' vTOK? $289 !  ' SAME? TO vTOK?     $CC00 TO HDICT
                      : NUP PUSH DUP POP ;
0]> C@ : FILL -ROT ;2DROP LOOPS NUP C!+ ;
DUP =, ERASE 0 C, =, BLANK bl C, : TUCK DUP : USWAP XEP SWAP ;
: ;MAX 2DUP EX (IF MRK> XEP RLS> DROP ; : UMAX ;MAX U< ;
: OR OVER NOT AND XOR ;
: UMIN ;MAX : U>= U< 0= ; : U- XEP - ; : WITHIN OVER- U- U< ;
: !- 2- DXEP ! ;
: MAX ;MAX : < - 0< ;  : <> = 0= ;  : @- 2- DXEP @ ;
: [], HERE DUP PUSH 2- DUP =: EXEC POP - : CLARY HERE OVER
 ERASE  : ALLOT ;HERE + ;  : U16? 1H : UN? U/MOD SWAP 0; 1+ ;
\ HERE 3 C, $F9 C, $AF C, $AF C, $C3 C,    ' \ DEFER \`
\ : S>UD! 0 -ROT : D! !+ ! ;
\ : FIX_E3_SZ #, : FIX1 ;HERE XEP $3B6 TO HERE CALL, ;
\ 22 LOAD  21 LOAD

<!>
: `TYPE EX
 SPACE 1H - 1H ;[] ?TYPE ; : []: $2DA =, , COMPILE [], ;
: DUMP U16? ;DROP  LOOPS
: DU CR DUP H. SPACE `TYPE 1H LOOPS CSTR B. ;
: S. ,< $F800  1L - >, #, : `S. bl : WDUMP ;DROP LOOPS STR H. ;
: R. ,< $FC00  1L - >, #, `S. ;

  <!>







: @BNDS? @+ @ : BOUNDS? WITHIN 0= A" BOUNDS!" ; : ;STK @BNDS?
: ;@! @+ XCHG EXECUTE POP !- DROP ; : TOP @ @- DROP ; : ZSTK
DUP 2+ @ SWAP! ; : ITEMS@ DUP 2+ @ SWAP : ITEMS? @+ @ - 2/ ;
            <!>
: `CLARY XEP RLS>` RLS>` CLARY ; : STK+, 2* MRK>` MRK>` MRK>`
`CLARY RLS>` ; : .STACK ;DROP ITEMS@ LOOPS STR . ;
: STK, SWAP DUP , , , ; <!>   $40E 1]> DUP @+ ;STK !+ ;
2]> DUP STR 2- SWAP ;STK @- ; <!> 3MKR STACK+ STK+,
       ' STACK+ 8 + @- @- @- DROP 3MKR STACK STK,
#DO []: 3 TIMES  $4AB WARY $4AD BARY  $4A9 LARY <!> { RUN TIME}
$5C NPAD STACK HANDLES     20 STACK+ CSTK> 20 STACK+ <CSTK
: `;STK> CSTK> EX TO CSTK> ;    : `;<STK <CSTK EX TO <CSTK ;
: STK? AT <CSTK ITEMS? AT CSTK> ITEMS? + ;
: ZCSTK AT CSTK> ZSTK  AT <CSTK ZSTK ;


{ EXTENDER (OF (BE 2* BE @I !I COMPILE } : @I J @ ; : !I J ! ;
: C!- 1- DXEP : C! C!+ DROP ;   : D0 0 0 ;  : 0SWAP 0 SWAP ;
: (OF OVER XOR  @R+ SWAP (IF MRK> XCHG SKIP RLS> DROP DROP ;
 @' (DE =, (BE  $3196 , $B4DB , $CD0E , $9610 , $C3 C,
<!>                                     : @R` COMPILE (@R
: ,NUM? >NUM DUP ODD ?? , ;     : !R` COMPILE (!R ,NUM? ;
: ;DICT DICT EX TO DICT ; : TOKEN+ TOKEN? DUP : INC ;@! 1+ ;
: CFA? TOKEN+ Afnd ;     : SUCSTR SWAP XEP CSTR ;
: (: =H : ;, EX , ;    : ;>DICT EX DUP C@ 1+ >DICT ;
: LINK? PUSH @R 2 DUP 2+ !R 2 XCHG POP ODD ; : @, NOP @ , ;
: =HT HERE : =:T TOKEN+ : =:NAME ;>DICT XEP : DICT!- ;DICT !- ;
: (,) 0SWAP : (T) =HT  Z, , , DOES> <MRK  LINK? (IF TO @,
: LINK, PUSH HERE @I , POP ! ;  3 - CONST #TARGET
<!>


<!> #DO (,) 13 TIMES $40C (CON $40B (CON2 $40A (CON3
$1F2 (LIT  $40E (VAR  $41B (SET  $41A (SET2  $470 (DEF
$46F (DEF2  $46E (DEF3  $24F X  $444 PUSH  $203 DROP
' HANDLES STR (,) (STK>  @ (,) (>STK   WAS bs (,) (EMT
: CONST (: (CON` ;      : NUM?,  NUM? : #,` (LIT` , ;
: VALUE (: (CON2` (SET` ;       : VECTOR (: (DEF2` (SET` ;
: VAR (: (VAR` ;  : STACK (: (STK>` (>STK` (VAR` TUCK , , ;
: DEFER (: (DEF` ; : CREATE  0 VAR : H- ;DROP : @H- ;HERE @- ;
: VQUAN (: (DEF3` (SET2` (VAR` ; : CONST.C (: (CON2` (EMT` ;
: QUAN (: (CON3` (SET2` (VAR` ;

'DO (,) 10 TIMES  (IF (IF (JUMP (JMP (;GO (;GO  (#IF (#IF
 (NEXT (NXT  (CALL (CALL  (OF (OF  (" ("  (A" (A"  (." (."
: H.-@ HERE : .-@ 2- @ ;  : RANGE? LO^ HI^ WITHIN ;
<!>

<!> : `THEN EX : THEN` CSTK> RLS>` ;
: CSWAP>` `;STK> `;STK> SWAP ; : <CSWAP` `;<STK `;<STK SWAP ;
: ,T bl ?, ;  : A"` (A"` ," ; : ."` (."` ," ; : " HERE ," ;
: AHEAD` (JMP` : MARK>` MRK>` TO CSTK> ; : ;GO` (;GO` MARK>` ;
: IF` (IF` MARK>` ; : [` : CALL`  (CALL` MARK>` ;
: FOR` PUSH` AHEAD` : BEGIN` HERE TO <CSTK ; ' IF`   =: WHILE`
: NEXT` THEN`   : <NEXT`  (NXT` : <RELEASE` <CSTK , ;
: FOR>` PUSH` BEGIN` ;  { : DROP, LIT DROP , ;  }
: ELSE` AHEAD` CSWAP>` THEN` ;  : FOR?`  (NXT` MARK>` ;
' ELSE` =: ENDOF`     : OF`  (OF` MARK>` ; : CASE` 0 TO CSTK> ;
: REPEAT` `THEN : AGAIN` (JMP` <RELEASE` ; : UNTIL` (IF`
<RELEASE` ; : ;CASE` DROP` BEGIN CSTK> DUP WHILE TO CSTK> THEN`
REPEAT DROP ; : "` ("` ," ; M: -IF` DUP 0< IF; <!>



<!> { TAIL RECURSION OPTIMIZER} 0 VECTOR vIS:?
' 2+ VECTOR vTOC>. : `:=? @ LIT ,< @' Z, , >, = ;
' `:=? TO vIS:? : ;;` X` STK? 0<>; ,<` ;
: `x??x EX #?? : `(@H, @H- vTOC>. TO <CSTK ;
: `?? `x??x : `H@:? HERE @- DROP vIS:? ;  : ]` : ;THEN` `THEN
: ;` `H@:? ;;` 0; H- `(@H, AGAIN` ;    : ?;` `?? UNTIL` ;
: #?;` `?? (#IF` <RELEASE` ;
: :;` `??  (;GO` <RELEASE` ;
: #IF` (#IF` MARK>` ; : ID-. CSTR  1- (ID. ;
: : ,< $22F , >, ZCSTK ;   { :  - !!! NEW :{]]]]  }
<!>





{ NUMOUT}     0 VALUE HLD

: (AC  OVER + PUSH DUP BEGIN KEY CASE cr OF DUP XCHG DROP ENDOF
     bs OF  2DUP <>  IF 1- TO bs SPACE  TO bs THEN  ENDOF
     DUP bl 1B WITHIN  IF DUP EMIT SWAP C!+ DUP THEN
  ;CASE DUP I =  UNTIL RDROP OVER - 1 : SPACES LOOPS SPACE ;
  META (AC ACCEPT

: ;HLD HLD EX TO HLD ; : BASE! 2 UMAX TO BASE ;
: <# 0 : <#? 0 TO HLD 0; NEG EX sgn : HOLD ;HLD C!- ;
: 1# BASE U/MOD SWAP ALPHA HOLD ; : ?#> HLD DUP NEG ;
: `N# XEP DUP 0< <#? : S# 1# DROP; #?; RECURSE ;
: .R lf : .RB BASE! `N# HLD + SPACES : #> ?#> TYPE ;



{ LIST } : LIST DUP TO SCR BLOCK
: .BLOCK  ;DROP ." SCR# " SCR . CR 1H LOOPS CR 1H  J -
: .LINE 4 .R SPACE 1L ;[] ?TYPE ;
: INDEX ;RANGE LOOPS DXEP+ BLOCK CR J ;DROP .LINE ;
=H (SCAN> >, POP RDROP POP SWAP - 1- NIP; ,<
: SCAN     OVER PUSH PUSH  FOR  STR J XOR
                (IF (SCAN> NEXT J (JUMP TO (SCAN> ,<
: BSCAN W>B OVER PUSH PUSH FOR CSTR J XOR
                (IF (SCAN> NEXT J (JUMP TO (SCAN> ,<
 0 VALUE SPTRTOP  0 VALUE SPTR : ;SPTR  SPTR EX TO SPTR ;
: S! { ADR LEN NEWADR -- } OVER PUSH C!+ POP CMOVE ;
: >S! CSTR : >S ;SPTR OVER PUSH (MPUSH XCHG POP  C!- ;
: SPTRTOP? SPTRTOP DICT <>  SPTR SPTRTOP U< 0=  OR  0;
  DICT DUP TO SPTRTOP TO SPTR TWICE  D0 >S ;
: S> SPTR : SDROP ;SPTR CSTR + ;

: UCSTR XEP CSTR ; <!>  : VARIABLE 0 VAR ;
: "CREATE CREATE 256 ALLOT ;  "CREATE `SBUF  VARIABLE `CBUF <!>
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


{ SWITCH}
0 VALUE XK     'TO  bel  =: WHAT?
 0]> SWAP TO XK CSTR 2DUP XK BSCAN 1+ 2* + + @EXEC ; =: `XK!
<!>
: -:  ' , C,  XK 2+ DUP TO XK       { BYTES FOR MOVE UP 1 }
         HERE OVER - DUP PUSH       { START ADDRESS    }
         DUP 1+ ROT                 { PREPARE FOR MOVE }
         CMOVE>  HERE C@ POP C!   ; { FIX CODE  }
: SWITCH: CREATE HERE 73 1 TO XK 0 -: LIT  `XK!  TOBE ;
: ;SWITCH  73 - A" BAD KEYS" XK 2/ 1- SWAP C! ;

\ 48 LOAD
<!>
\ 20 21 THRU     FIX_D    FORGET FIX_E3_SZ


\ $3B6 : CALL FIX       -- FIX : 03 F9 AF AF C3
HERE 3 C, $F9 C, $AF C, $AF C, $C3 C,    ' \ DEFER \`
: S>UD! 0 -ROT : D! !+ ! ;
: FIX_E3_SZ #, : FIX1 ;HERE XEP $3B6 TO HERE CALL, ;
: +! ;@! + ; : END> HERE STR + ;
\ $3B6 : 03 F9 AF       -- NOW
CREATE `EMPTY 0 ,
: `NODE+ [ HERE +! END> 2- OFF ]  D>NAME 2+ OVER-
         XEP END>  J CMOVE ;
: #FX ;(DICT ;DROP  [ `EMPTY `NODE+ ]
                     HERE OFF ;FND DROP J `NODE+ ;
: FIX_D { ICTIONARY}   FIX_E3_SZ  #FX  \ DICTIONARY
  LIT 2+ LIT >NAME  6 + !  \ FIX IN CORA
: FIX_ON LIT S>UD! $28F ! LIT OVER- LIT D>NAME $293 D! ; \ ON


: U- XEP - ; : WITHIN OVER- U- U< ;
CREATE `EMPTY 0 ,
: `NODE+ [ HERE @ + HERE ! ]  DUP >NAME OVER-
         XEP HERE STR + J CMOVE ;
: FORGET ' [ TO HERE ] ;(DICT ;DROP [ `EMPTY `NODE+ ] 0 HERE !
     ;FND  J N>C SWAP HDICT WITHIN 0<>;  J `NODE+ ;










M: FOR` (FOR MRK> <MRK;         M: NEXT` (NEXT <RLS RLS>;
M: IF` (IF MRK>;                M: THEN` RLS>;
M: CALL` (CALL MRK>;             ' CALL` =: [`
'" ?M: ]` ; >, THEN"             ' ]`    =: ;THEN`
M: WHILE` IF X SWAP;            M: REPEAT` AGAIN THEN;
M: BEGIN` <MRK;                 M: AGAIN` (JUMP <RLS;
M: AHEAD` (JUMP MRK>;









: FORGET ' AHEAD
: `NODE+ [ HERE ;@! + ]  DUP >NAME OVER-
         XEP HERE STR + J CMOVE ;
,< CREATE `EMPTY 0 , >, : PRUNE HERE
: #FGT THEN [ TO HERE ] ;(DICT ;DROP  [ `EMPTY `NODE+ ]
        0 HERE !  ;FND  J N>C SWAP HDICT WITHIN 0<>;
        J 1+ C@ '` XOR 0;  J `NODE+ ;
: ;CR EX CR ; 0 VALUE `ROWS
: `ROWS! bs TO `ROWS ;
: `EOL? C@ CNTC + ,< 80 5 - >, #, U< 0<>;
: `NEWLINE  ;CR `ROWS 1- DUP TO `ROWS 0<>;
     (BK 27  = `ROWS! ?; J RDROP EXIT3 ;
: WORDS CR ;DROP `ROWS! ;FND DROP
          J `EOL? J N>C H. J ". CNTC 65  U< `NEWLINE ?; 13
: ?ALIGN CNTC : ALI-N OVER UMOD - SPACES ;

: EXIT3 RDROP : EXIT2 RDROP : EXIT RDROP ;
: C@I  J C@ ; : (TYP N>C @ ; : WAS@ ' 2+ @ ; : `H ." `$" H. ;
: CORA DUP C@ 1+ : -TEXT
      FOR PUSH CSTR XCHG CSTR POP = IF CSWAP> NEXT
      -1 PUSH THEN  DROP DROP POP 1+ ;
: ;FND DICT AHEAD  : ;FND2 BEGIN >NAME THEN PUSH C@I
           WHILE   DUP J EXECUTE POP   REPEAT  0  EXIT2 ;
: C>N? ;FND J N>C - 0= 0= : `C 0<>; DROP J J EXIT3 ;
: `CN 2- C>N?  : `N  EXIT ?; POP ID.   ID. EXIT ;
: `TO. `CN ,< ,T TO   : `AT. `CN ,< ,T AT
: .ALL ;2DROP ;FND J (TYP : >PRINT = : >PRT? 0; : JID J ID. ;
: -FIND TOKEN? : FND  ;FND J CORA `C ;




            \ $3B6 : CALL FIX       -- FIX : 03 F9 AF AF C3
HERE 3 C, $F9 C, $AF C, $AF C, $C3 C,    ' \ DEFER \`
: S>UD! 0 -ROT : D! !+ ! ;
: FIX_E3_SZ #, : FIX1 ;HERE XEP $3B6 TO HERE CALL, ;
            \ $3B6 : 03 F9 AF       -- NOW
CREATE `EMPTY 0 ,  : +! ;@! + ; : END> HERE STR + ;
: `NODE+ [ HERE +! END> 2- OFF ]  D>NAME 2+ OVER-
         XEP END>  J CMOVE ;
: #FX ;(DICT ;DROP  [ `EMPTY `NODE+ ]
                     HERE OFF ;FND DROP J `NODE+ ;
: FIX_D { ICTIONARY}   FIX_E3_SZ  #FX  \ DICTIONARY
  LIT 2+ LIT >NAME  6 + !  \ FIX IN CORA
: FIX_ON LIT S>UD! $28F ! LIT OVER- LIT D>NAME $293 D! ; \ ON

\ FIX_D

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

: UCSTR XEP CSTR ;   : VARIABLE 0 VAR ;
: "CREATE CREATE 256 ALLOT ;   "CREATE `SBUF   VARIABLE `CBUF
: U"R! XEP : "R! `SBUF : "! DXEP
: >"   { SRC DST -- ALIAS PLACE } OVER C@ 1+ CMOVE ;
: S>"  { ADR LEN -- >STR} `SBUF
: S>"! { ADR LEN >STR -- >STR} DXEP C! J CSTR CMOVE ;
: C>"  { CHAR -- >STR} `CBUF
: C>"! { CHAR >STR -- >STR } DXEP 1+ C! 1 J C! ;
: "+C! { >STR CHAR -- >STR }  C>"
: "+!  { >STR STR -- >STR  } CSTR
: "+S! { >STR ADR LEN -- >STR}  ROT DXEP C@ TUCK + 255 UMIN DUP
         J C! SWAP - J CSTR + OVER - SWAP CMOVE ;
: +" SWAP : "+ { STRA STRB -- >STR } U"R! "+! ;
: AUTO { NAME -- AUTO\NAME.CF} " AUTO\"  +"  " .CF" "+! ;
\ " BG" AUTO ".

: PROBA1 [ 1 . [ 2 . [ 3 . ]  [ 4 . ] ]
              [ 5 . [ 6 . ]  [ 7 . ] ]
          8 . ]
   9 . ;
: . DUP . ;
: PROBA [ [ 9 . [ + . ]  4 . ] EX  [ U* . ]  10 . ]  EX .
        [ - . ]
        [ [ 8 . [ + . ]  3 . ] EX  [ U* . ]
    [ 8 . [ - . ] 3 . ] EX  ]  EX .
;






NEEDS WORDS
: NODE+ [ HERE ;@! + ]  DUP C@ 3 + XEP HERE STR + J CMOVE ;
CREATE `EMPTY 0 ,
: PRUNE HERE : `P  [ TO HERE ] ;(DICT ;DROP
                   [ `EMPTY NODE+ ]
        0 HERE !  ;FND  J N>C SWAP HDICT WITHIN 0<>;
        J 1+ C@ '` XOR 0;  J NODE+ ;;
: FORGET ' `P ;








































































































































































































































































































\ : -TEXT FOR PUSH CSTR XCHG CSTR POP = IF CSWAP> NEXT
\      -1 PUSH THEN  DROP DROP POP 1+ ;
\ : ;FND DICT AHEAD  : ;FND2 BEGIN >NAME THEN PUSH C@I
\   WHILE   DUP J EXECUTE POP   REPEAT  0 : EXIT2 RDROP EXIT ;

\ : ;FND DICT AHEAD : ;FND2 BEGIN >NAME THEN PUSH C@I
\  WHILE  DUP J EXECUTE POP REPEAT  0 : EXIT2 RDROP EXIT ;









: C>N? ;FND J N>C <> : `C 0<>; DROP J J : EXIT3 RDROP EXIT2 ;
: .ALL ;2DROP ;FND J (TYP : >PRINT = : >PRT? 0; : JID J ID. ;
: -FIND TOKEN? : FND  ;FND J CORA `C ;

: `~POSIBLE? J C@ - DUP 0< 0; RDROP : `SRCH; 2DROP 0 EXIT ;
: IN-STR> SUCSTR : SRCH> PUSH `~POSIBLE? FOR>
 DUP J CSTR  -TEXT EXIT2 ?; 1+ <NEXT DUP `SRCH; ;
: <IN-STR SUCSTR : <SRCH PUSH `~POSIBLE? DU+ FOR>
 DUP J CSTR  -TEXT EXIT2 ?; 1- <NEXT DUP `SRCH; ;

: `CN 2- C>N?  : `N  EXIT ?; POP ID.   ID. EXIT ;
: `TO. `CN ,< ,T TO   : `AT. `CN ,< ,T AT




\ : B>N? ;FND J  N>C 2+ @ - 0<>;   J (TYP #TARGET - `C ;
: `H ." `$" H. ;
: `6N  PUSH PUSH PUSH  CALL  POP POP POP
: `N3  THEN  SPACE 3 LOOPS ROT DUP H. ;
: T?ID. DUP 0< OVER 2* RANGE? AND IF 2*  THEN
: ?ID.   C>N? 0= ID. ?; `TO. `AT. 2+ 2+ `H ;
\        B>N? `H ?; CSTR 1- ;SPC    TYPE ;
: SHN CR { S. R.}
         POP J H. PUSH J H. I H. `6N I @ ?ID. KEY 17 =
      IF ABORT THEN ;;
: .CODE ;2DROP ;FND DROP J N>C @+ >PRINT ;
: .WORDS ;2DROP ;FND DUP >PRINT ;
: .NAMES ;2DROP ;FND J IN-STR>  >PRT? ;
: HIDE -FIND #?? 1+ '` : CSWAP! SWAP C! ;
: HIDE-TEST -FIND IF ID. ; THEN DROP ;

\ BLOCK1 OF EDITOR

: ONPLACE ;GO  DXEP  TWICE NUP  THEN
: REVERT   ;2DROP  BEGIN 1-  2DUP U< 0;
     PUSH PUSH  J C@  I C@  J C!    POP  C!+ POP  AGAIN ,<

ZDO VALUE 4 TIMES  `PDATA `INS  `SZ  `ALTER
: NIP NIP; ,<
: BB>W 1B* SWAP W>B XOR ;
: `;HOME EX : HOME D0 : @XY BB>W D0 $200 (VID ;
: PAGE `;HOME  0 24 @XY  25 : CRS  LOOPS CR ;





\ BLOCK2 OF EDITOR
: `?XY 1L U/MOD 6 3 ROT + XEP + ;
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
: `WIPE `;RDRC 1K LOOPS `EOS^ J - 1- : `IWIPE   DUP C@ bl U<
         DROP; ?; bl SWAP C! ;

\ BLOCK3 OF EDITOR
: `<_|   `L_DN  : `L_BEG `;LRUD L/ ;    : `->  1 `XY+ ;
: `<-  1 `XY- ;  : `TAB> bs : `SZTB> `-> :; 1- `;LRUD OR ;
: `<TAB bs : `<SZTB `<- NEG : `TAB& `;LRUD AND ; { PREVIOUS}
: `APOS  0 `TAB& ; : `LINE/ `;LPOS  L/ ;  : `/LINE `;LPOS `/L ;
: `LDRAW `POSXY `LINE/ XY 1L U/ 1+ cr EMIT .LINE DROP ;
: `RESET -BUF : `LOADRAW `RELOAD `REDRAW ; { !!!!!!! }
: `N  1 : `LB SCR + 0 MAX TO SCR `LOADRAW ;  : `B -1 `LB ;
: `ALT SCR `ALTER TO SCR TO `ALTER `LOADRAW ;
: `ADV 1K XY - TO LTIB bl PARSE TO `SZ DROP XY? >XY XY 0; `<- ;
: `TEST bl `POS^ C@ U< ;  : `BACK  BEGIN `<- XY 0; `TEST UNTIL
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
: `SCR; `APOS `<- : `PREPARE `L_END `PREP ;  60 LOAD


\ BLOCK5 OF EDITOR
SWITCH: `EF WHAT?   kaA -: `ALT    kLEFT -: `<-    kUP -: `L_UP
 kHOME -: `L_BEG   kEND -: `L_END  kPGUP -: `B   kPGDN -: `N
 kDOWN -: `L_DN  kRIGHT -: `->     kINS  -: `_INS kDEL -: `DELC
 kaW   -: `WIPE kcRIGHT -: `ADV  kcLEFT -: `BACK kcEND -: `SCR;
 ksTAB -: `<TAB  kcHOME -: `APOS   kaS -: `altS  kaD -: `DELL
;SWITCH        : `ONEC XK bl U<  IF WHAT? ;THEN XK `INSC `-> ;
SWITCH: `EK `ONEC C^ J -: `<- C^ K -: `-> C^ X -: `CUT 127
-: `BKCW bs -: `BS C^ D -: `DELC cr -: `<_| bel -: `CUTW C^ Z
-: `PREPARE C^ N -: `N C^ B -: `B C^ R -: `RESET C^ I -: `TAB>
 C^ C -: `COPY C^ V -: `PASTE C^ Q -: `ESQ/E C^ F -: `MOVE
 C^ A -: `ADV  kESQ -: `Q/ED  C^ S -: `INSL  0 -: `EF ;SWITCH
: `@KEY `POSXY (BK W>BB #IF SWAP ;THEN DROP ;
: HELP ;GO SCR XEP : `(E THEN TO SCR : E  D0 ;0TI `LOADRAW ;EOS
 BEGIN `@KEY `EK EOS  UNTIL ;  : EDIT PAGE `(E ; : PE PAGE E ;

{ IO (DOS (VID (KBD } 0 QUAN Fbuf
ZDO VALUE 6 TIMES  _AX _BX _CX _DX _FR  EOS
CODE: (IO  $1E88 , HERE 12 + , $9456 ,  $595B , $945F , $9297 ,
  $CD57 , $5F21 , $9497 , $5152 , $5753 , $949C , $E9 C,
 @' 2DROP; ,R   : IO? _FR ODD A" :IO?" ;
0]> C@ (IO TO _FR TO _AX TO _BX TO _CX TO _DX ;
  DUP =, (DOS $21 C,  DUP =, (VID $10 C,  =, (KBD $16 C,
0]> @ (DOS ;    DUP =, Fopen $3D02 ,   DUP =, Fread  $3F00 ,
 DUP =, Fwrite  $4000 , DUP =, Fseek $4200 , =, Fcreate $3C00 ,
0]> @ PUSH D0 ROT POP (DOS ;
DUP =, Fsize  $4202 ,   DUP =, Fpos  $4201 ,  =, Fclose $3E00 ,
: =" '" WORD CSTR : >ZSTR '| (S! SWAP : OFF 0 SWAP! ;
                         : ;File CSTR >ZSTR 1+ D0 EX IO? _AX ;
: FOPEN ;File Fopen ;     : FCREATE ;File Fcreate ;


{ STREAMS }: FGET Fbuf CALL DROP  cr : EOS! bs TO EOS ;THEN
  AT Fbuf 1 AT HANDLES TOP  Fread  _AX 0;  { IF EOF THEN EOS}
  DROP Fbuf  DUP eof XOR 0; RDROP  ; : ;EOS EOS XCHG 0 TO EOS
  EXECUTE POP TO EOS ; : ;FILE TO HANDLES AT KEY @ XCHG PUSH
 LIT FGET TO KEY EX POP TO KEY     : HCLOSE HANDLES Fclose ;
: ;NOEMIT LIT DROP; : ;EMIT! LIT TO EMIT
: ;SAFE! DUP XCHG OVER @ PUSH PUSH ! EX POP POP ! ;
: INCLUDE TOKEN? : INCLUDED FOPEN ;FILE D0 ;0TI ;NOEMIT
: KEVAL ;EOS BEGIN vINIT EVAL EOS UNTIL ;
: NEEDS EXIST? 0<>; TBUF : ?NEEDS AUTO INCLUDED ;
: FTYPE TOKEN? FOPEN ;FILE ;EOS BEGIN KEY EMIT EOS UNTIL ;
: CLOSE_ALL    AT HANDLES ITEMS? LOOPS HCLOSE ;




0 VALUE `USE 4 CONST `NBUFS 0 VALUE `PREV
: `RW 1K UM* SCRH Fseek  IO?  1K SCRH  EX IO? ;
: FCUT `RW 0SWAP Fwrite ;
: `WBLK `RW Fwrite ;    : `RBLK `RW Fread ; `NBUFS BARY `FBUFS
  `NBUFS WARY  `BUFS    : `@BUF `PREV 1K U* FIRST + ;
0]> C@ `PREV `FBUFS C! ; DUP  =, DISCARD  0 C, =, UPDATE  -1 C,
: -BUF DISCARD -1  : `!BUF `PREV `BUFS ! ;
: `+BUF `USE 1+ `NBUFS 1- AND DUP TO `USE ;
: !BUFS  `NBUFS LOOPS `+BUF TO `PREV
: `?SAVE `PREV `FBUFS C@ 0; `@BUF `PREV `BUFS @ `WBLK DISCARD ;
: FLUSH !BUFS : /BUFS `NBUFS  LOOPS `+BUF TO `PREV
: `EMPTY-BUF -BUF : `/BUF `@BUF 1K ERASE ;
: `?BUF PUSH 0 `BUFS `NBUFS POP SCAN ;
: (OK ."  Ok" CR ." >" ; META (OK vOK.


: `;ABLK /BLK 0 TO _FR XCHG PUSH J `?BUF  EX RDROP `@BUF IO? ;
: Fbuffer `;ABLK -IF `?BUF
      -IF DROP `+BUF THEN THEN TO `PREV `?SAVE `/BUF J `!BUF ;
: Fblock `;ABLK -IF DROP J Fbuffer J `RBLK ;THEN TO `PREV ;

: FIXER CONST , DOES> @+ @ ! ; 'TO BLOCK WAS BLOCK FIXER MBLOCK
: `-USE SCRH 1+ 0; SCRH Fclose : `/SCR -1 TO SCRH ;
'TO BLOCK  ' Fblock  FIXER FBLOCK       : USE/ `/SCR /BUFS ;

: USING FLUSH `-USE TOKEN? FOPEN TO SCRH ;
: +BLK BLK + ;                       { LINE BEGIN FUNCTION }





\ KEY CONSTANTS
\ THERE TO THOLD  1000 HIPUSH LO^ TO THERE
\ <!>
    : C^ TOKEN? 1+ C@ 31 AND ;
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
\ <!> THOLD TO THERE  \ HIDROP

\ DEBUGGER  : ;[] '[ EMIT EX '] EMIT ; : ;CR EX CR ;
NEEDS CORA
0]> PUSH XCHG CSTR POP SCAN 1+ 0;  ;SPC ;[] DUP ". CSTR + ;
 =, `?STR 3 C, >, (A"  (" (." ,<
0 VALUE `WW : `;WW `WW EX TO `WW ;
: `STR EX DUP 2- @ `?STR ;
: `:ID. DUP C>N? NOP #?; XEP OVER CALL ." : " ID. ;THEN : ``CR-
  CR H. ; : `CR-H `:ID. ``CR- ?; ; : `CR- `:ID. DROP; ?; ;
' ?ID. 2+ VALUE vDBG  : SEE ' : @SEE TO `WW : L `;WW bs LOOPS
: WW `CR-H @+ OVER H.  : `W0 `STR XEP vDBG PUSH ;
: HACK ' : @HACK TO `WW : HL CR bs LOOPS `;WW `CR- @+ `W0 ;
: -HL `WW 23 - @HACK ;  : .HL `WW H. ;




NEEDS CORA
CREATE `SEARCHBUF 80 ALLOT    62 CONST `BLOCKS  \  ABRAKADABRA
: `BLK>LINES `BLOCKS 1H U* ; : S0! 0 TO SCR  0 TO XY ; \
: AT-VLINE 1H U/MOD TO SCR 1L U* ;
: AT-VMEM AT-VLINE 1L 1- OR  DUP TO XY  : AT-SCR SCR BLOCK + ;
: SRCH XY AT-SCR 1K XY - `SEARCHBUF SRCH> DUP  TO XY 0;
  XY 0 AT-SCR - `SEARCHBUF C@ + >XY E ; >, BEGIN SCR 1+ TO SCR
: `BLOCKSRCH  SCR `BLOCKS U< 0;  SRCH XY UNTIL ;
: S bl : `BLOCKSEARCH  WORD C@ IF  TBUF `SEARCHBUF PLACE  THEN
  `SEARCHBUF C@ 0; `BLOCKSRCH ;
: S" '"  `BLOCKSEARCH ; : ?S TOKEN? 1+ C@ `BLOCKSEARCH ;
: S?EL `BLK>LINES LOOPS J AT-VMEM  C@ bl - 0; E ;
: cr>EL FLUSH :; S?EL `BLK>LINES LOOPS cr J AT-VMEM C! UPDATE ;
: bl>EL FLUSH :; `BLK>LINES LOOPS bl J AT-VMEM C! UPDATE ;


