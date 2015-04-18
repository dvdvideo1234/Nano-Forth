$4420  =:  =:,
$4410  =:  ,
$4497  =:  ]
$448B  =:  [`
$441A  =:  #`
$440A  =:  :
$4404  =:  ;`
$411D  =:  0
$4261  =:  PARSE
$4167  =:  LATEST
$4161  =:  HERE
$4463  =:  FIND
$44D3  =:  ="?
$44DB  =:  <>0?
$43D3  =:  0=
$43E1  =:  U<
$43BC  =:  C!+
$43EF  =:  2+
$42BF  =:  #DOES
$43B6  =:  @
$43B4  =:  C@
$439D  =:  (DE
$43CC  =:  >EVAL
$43F3  =:  DUP
$41E9  =:  ="
$44E1  =:  =0?
$435A  =:, (?BR
$42CF  =:, (CAL
$436A  =:, (FOR
$4362  =:, (-BR
$4378  =:, (NXT
$434A  =:, (OF
$4356  =:, (SKDR
$4451  =:  (0BR
$4453  =:  (BR
$4337  =:, RDROP
$4459  =:  SKIP
$4352  =:, ?SKDR
$445B  =:  ;;
$445D  =:  0;
$4461  =:  0";
$445F  =:  DROP;
$44C1  =:  ABORT
$4129  =:  ACCEPT
$438F  =:  ACPT
$4120  =:  bl
$411A  =:  `C
$4449  =:  (>#,
$414F  =:  CNTC
$4486  =:  DEC
$43A5  =:  (DK
$412D  =:  ERRv
$4131  =:  OKv
\ $413D  =:  FIND?
$4139  =:  KEY
$4135  =:  EMIT
$4125  =:  HBUF
$415B  =:  LAST
$4143  =:  >IN
$4149  =:  TIB<
$4155  =:  TIB
$41C6  =:  E!-
$4187  =:  (EVL
$4455  =:  EXEC
$41D3  =:  S!
$43C8  =:  (#
$44B5  =:  (>#
$4209  =:  >#
$44D0  =:  .?
$4401  =:  SWAP
$43F5  =:  DROP
$43F9  =:  POP
$43F7  =:  PUSH
$43FB  =:  OVER
$4457  =:  @EXEC
$4122  =:  SPACE
$4110  =:  STATES
$43E7  =:  WITHIN
$43DB  =:  0<
$43F1  =:  1+
$42F3  =:, 1-
$42F2  =:, 2-
$4304  =:, FLIP
$4302  =:, HI>
$43C0  =:  STR
$41DC  =:  S+C!
$41C4  =:  CSTR
$43BA  =:  !-
$43B8  =:  !+
$43BE  =:  @+
$43AE  =:  C@.


: RECURCE` LATEST @ , ;
: ' ="? LATEST FIND <>0? ;
: LIKE ' @ ;
LIKE U<  =:, -      $2B93 , $C3D8 ,
LIKE 0=  =:, EX     $7687 , $C300 ,
: ;HERE HERE EX [ ' HERE 2+ , ] ;

: C, ;HERE C!+ ;

HERE
$E8
C,
#DOES
HERE
2+
-
,

]
C@
C,
HERE
2+
-
, ;

DUP      =:, CALL, $E8 C,

         =:, JUMP, $E9 C,

HERE #DOES  CALL, ] C@ C, ;

         =:, RET,  $C3 C,

LIKE (DE 1 - =:, 2DROP  RET,

: \ 0 PARSE 2DROP ;

LIKE \ =:  \`

LIKE 0=      =:, XCHG   $5E87 , $C300 ,
LIKE 2DROP   =:, !      $789  ,  RET,
LIKE !       =:, C!     $788  ,  RET,
LIKE U<      =:, +      $C301 ,  RET,
LIKE -       =:, AND    $D823 ,  RET,
LIKE -       =:, XOR    $D833 ,  RET,
LIKE (DK     =:, I      $468B , $C300
LIKE (DK     =:, J      $468B , $C302
LIKE 0=      =:, NEG    $DBF7 ,  RET,
LIKE 0=      =:, NOT    $D3F7 ,  RET,
LIKE 0=      =:, 2*     $E3D1 ,  RET,
LIKE 0=      =:, BL<.   $FB80 , $7320 , $B302 , $C32E ,
LIKE PARSE   =:, 0SWAP  $C033 ,  RET,
LIKE 0=      =:, >DIG   $FB80 , $7C0A , $8003 ,
                        $07C3 , $C380 , $C330 ,
LIKE >EVAL 1- =:,  UM/MOD  $F3F7 , $DA8B , RET,
LIKE >EVAL   =:, UM*    $E3F7 , $F7EB ,      \ AFTER UM/MOD


LIKE U<  =:, NIP  RET,
: U/MOD 0SWAP UM/MOD ;
: U/   U/MOD DROP ;
: UMOD U/MOD NIP ;

: ALLOT ;HERE + ;
: ', ' , ;
LIKE ;`  =:, 0,    0 ,  ', ,
: W, STR , ;


LIKE 0=  =:, BRP    $C3CC ,

\ BIOS IO
\ LIKE 0=  =:, (BK    $B4   ,  $16CD ,  RET,
LIKE (DK =:, (BK    $B4   ,  $16CD ,  $C008  ,
                    $0274 ,  $B4   ,  RET,
LIKE (DK =:, (BK?   $01B4 ,  $16CD ,  $F8   C,
                    $0174 ,  $F9  C,  $C019  ,  RET,
LIKE (DE =:, (BE    $93  C,  $0EB4 ,  $10CD  ,  RET,

: #1 U/MOD >DIG SWAP ;
: .. 10 #1 ?SKDR RECURCE EMIT ;

: ;SPC  EX SPACE ;
: CR 10 EMIT 13 EMIT ;
: . CR .. CR ;
' . .

: C" ="? 1+ C@ ;                : C"` C" #` ;
: ( C" ) PARSE 2DROP ;  LIKE ( =: (`
: IS ' 2+ ! ;

' :   =: :]
' ;`  =: [;`
HERE #DOES CALL, ] C@ PUSH HERE #DOES POP - CALL, ] ;
DUP  =:, 0]  0 C,
DUP  =:, 1]  1 C,
     =:, 2]  2 C,

0] C@ ' + EXEC [;
DUP      =:, TO   2 C,
         =:, AT   4 C,

0] C@ ' + , [;
DUP  =:, TO`  2 C,
     =:, AT`  4 C,

\ LIKE 2DROP 1-  =:, MOVE  $41B3  JUMP,

: code; POP LATEST @ ! ;
0] @ , [;
    =:, FIX,  ', code;

: DOES>` FIX, #DOES CALL, ;
: CODE;` FIX, [` ;
LIKE ;`  =:, CREATE  LIKE #DOES 1+ , ', =:,
: VARIABLE CREATE 0, ;

: @JUMP NOT 3 AND 2* POP + PUSH ;
: EXECUTE PUSH ;

: MAKER CREATE DUP C, @JUMP , , , ',
        DOES> HERE =: CSTR  @JUMP W, W, W, @EXEC ;

LIKE HBUF      1 MAKER  CONSTANT ,
LIKE 0         1 MAKER  BCONST  C,
LIKE KEY       1 MAKER  DEFER    ,
' TIB 2+ @ DUP
LIKE KEY 1-    2 MAKER  VECTOR   ,
LIKE TIB       2 MAKER  VALUE    ,
' bl @+ @ SWAP 2 MAKER  BVECT   C,

: COMPILE POP STR , PUSH ;
0 VALUE CSP
: ;CSP   CSP EX TO CSP ;
: ?CSP   ;CSP DUP CSP XOR =0? 1- ;
: <MARK  HERE ;CSP 1+ DUP ;
: <RELEASE  ?CSP , ;

0 VALUE HLD
: HPOP   HLD @+ TO HLD ;
: HPUSH  HLD !- TO HLD ;
: HLD?   HPOP HLD XOR =0? ;
: MARK! HPUSH HLD HPUSH ;
: >MARK  HERE 0, MARK! ;
: >RELEASE HLD? HERE HPOP ! ;

: >MARK>   >MARK <MARK ;
: <RELEASE< <RELEASE >RELEASE ;

' >RELEASE  =: THEN`
' <MARK     =: BEGIN`

LIKE ;`  =:, AHEAD`  ', (BR   ', >MARK
LIKE ;`  =:, ;THEN`  ', ;;    ', <RELEASE
LIKE ;`  =:, AGAIN`  ', (BR   ', <RELEASE
LIKE ;`  =:, IF`     ', (0BR  ', >MARK
LIKE ;`  =:, CALL`   ', (CAL  ', >MARK
LIKE ;`  =:, OF`     ', (OF   ', >MARK
LIKE ;`  =:, -IF`    ', (-BR  ', >MARK
LIKE ;`  =:, UNTIL`  ', (0BR  ', <RELEASE
LIKE ;`  =:, FOR>`   ', PUSH  ', <MARK
LIKE ;`  =:, <NEXT`  ', (NXT  ', <RELEASE

: ELSE`   HLD? HPOP  AHEAD` MARK! THEN` ;
: REPEAT` AGAIN` THEN` ;
' ELSE`  =: ENDOF`
' IF`    =: WHILE`
' CALL`  =: {`
: }` ;THEN` COMPILE POP ;

LIKE ;`  =:, FOR`    ', (FOR  ', >MARK>
LIKE ;`  =:, NEXT`   ', (NXT  ', <RELEASE<
: CASE` 0 MARK! ;
: ENDCASE`  COMPILE DROP  BEGIN HLD? HPOP DUP
    WHILE MARK! THEN` REPEAT  DROP  ;

LIKE ;`  =:, :`    ', SKIP  ', :
:  :  : 0 TO HLD CASE`  0 TO CSP ;
:] ;`  ?CSP HLD? HPOP =0? ;` ;

: TIMES SWAP PUSH
: LOOPS FOR J EXECUTE NEXT RDROP DROP ;

( : XEP XCHG EXECUTE POP ;)
: ;DROP EX DROP; ;  -2 ALLOT

: ID.  ;SPC  CSTR
: TYPE ;DROP
: >TYPE LOOPS CSTR EMIT ;
: (." POP CSTR >TYPE PUSH ;
: (" I CSTR + XCHG PUSH ;
: (A" IF POP ID. ABORT THEN POP CSTR + PUSH ;

: (STR, C" " PARSE HBUF S!
: STR, CSTR DUP C,
: BYTES, ;DROP LOOPS CSTR C, ;

LIKE [;`  =:, A"`   ', (A"  ', (STR,
LIKE [;`  =:, "`    ', ("   ', (STR,
LIKE [;`  =:, ."`   ', (."  ', (STR,

 10 BVECT  lf
 13 BVECT  cr
  8 BVECT  bs
255 BCONST &BYTE
: 2DUP OVER OVER ;
: CR cr EMIT  lf EMIT  0 TO CNTC ;

: (ACC  PUSH 0
 BEGIN KEY
   CASE
     cr OF DUP XCHG DROP ENDOF
     bs OF DUP IF 1- TO bs  SPACE  TO bs THEN  ENDOF
     PUSH  I bl &BYTE WITHIN
      IF 2DUP + I SWAP C! 1+  I EMIT THEN POP
   ENDCASE
 DUP I = UNTIL RDROP ;

: (OK ."  Ok" CR ;  ' (OK  IS OKv

' (BK  IS KEY   ' (BE  IS EMIT  ' (ACC IS ACCEPT

