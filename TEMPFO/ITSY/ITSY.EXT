$317 =: \`
$317 =: \
\	NOW WE HAVE COMMENTS

\ CURRENT LIST OF WORDS

$177 =: `BARY
$138 =: `C@
$1CF =: `CALDR_
$1FE =: `CONT
$1F3 =: `DINU_
$19B =: `DOES
$28A =: `DOS
$213 =: `DOVAR
$1E5 =: `DROP
$141 =: `DUP
$1AF =: `DUP_
$21B =: `EXEC
$204 =: `EXECUTE
$20B =: `FOR
$159 =: `GETWATCH
$22A =: `IFM
$18D =: `J
$13A =: `LOBYTE
$229 =: `MIF
$1E8 =: `NIPX
$1A9 =: `NOP_
$1B1 =: `PH
$1F7 =: `PHAX
$192 =: `POP
$20D =: `PUSH
$1EE =: `RDROP
$165 =: `RSLD_
$169 =: `RSST_
$1D3 =: `SETWATCH
$226 =: `SKIP
$1B2 =: `SW
$1AD =: `SWAPC_
$1AE =: `SWAP_
$1B9 =: `TODBG
$1FD =: `TRAP
$3FF =: `TROFF
$200 =: `TWICE
$1BC =: `ULESS
$175 =: `WARY
$160 =: `XA
$4D0 =: `XEVAL
$188 =: `XR
$1C5 =: `ZLESS
$3C4 =: 0;
$343 =: 1-
$2A9 =: ACCEPT
$434 =: `(ACPT
$347 =: AND
$30D =: BEGIN`
$305 =: <RELS`
$3BA =: (JMP
$2D7 =: CDICT
$279 =: CMOVE
$275 =: CMOVE<
$398 =: :`
$398 =: :
$305 =: ,
$3F9 =: CSTR
$26D =: CPUSHU
$377 =: DC@
$286 =: (DE
$2D1 =: T
$2EB =: T|
$27D =: (DK
$2C5 =: H
$2F5 =: H|
$3C2 =: DROP;
$2A5 =: EMIT
$42C =: ??
$2BF =: ERRA
$418 =: ERROR?
$29D =: ERRV
$2B9 =: ETIB
$4B6 =: EVAL
$3BE =: EX
$3BC =: (;
$375 =: @
$462 =: FIND
$483 =: FINDC
$293 =: FOUND
$49C =: =H
$4A0 =: `=:
$30D =: HERE
$299 =: INIT
$4E0 =: (INIT
$2E3 =: 1L
$2A1 =: KEY
$383 =: @+
$31F =: LIT
$32E =: LIT,
$3A4 =: ,<`
$2B3 =: LTIB
$254 =: S>"
$367 =: -/
$183 =: NOP
$40E =: NUMC
$428 =: NZ?
$2CB =: OFST
$11F =: OPER[
$436 =: (PARS
$446 =: PARSE
$4D8 =: S>T
$4D2 =: ">T
$351 =: +2/
$35A =: +*
$33F =: POP
$341 =: PUSH
$38D =: @R+
$3AE =: >,
$392 =: !R+
$39E =: ;`
$2AD =: SOURCE
$37F =: !-
$37B =: !
$381 =: !+
$379 =: STR
$3FB =: S1+
$385 =: ("+
$2E7 =: TBUF
$2DF =: TIB
$43C =: TOKEN
$438 =: TOKEN?
$400 =: >NUM
$404 =: `TO_NUM2
$3C6 =: (NUM
$442 =: WORD
$2FF =: ;,
$4CE =: ;DROP
$4B4 =: ;(EVL
$34C =: XOR
$424 =: XTOK?
$452 =: ;(>"
$3B8 =: (IF
$345 =: 0=
$2DB =: 0

\ SOME VOCABULARY
\ "STRING" -- LIST OF CHARS
\ DLM 	-- DELIMITER
\ CF 	-- CODE FIELD
\ ACF	-- ADDRESS OF CODE FIELD
\ ADR   -- ADDRESS ( LOBYTE HIBYTE )
\ LSTR  -- ( BYTE "STRING" ) 
\ DTR   -- DICTIONARY TOKEN RECORD  ( ADR LSTR )
\ ADT   -- ADDRESS OF DTR 
\ TOKEN -- "STRING" WITHOUT SPACES

\ MAKE THE SEARCHERS  - NEEDS -- TOKEN? FIND DICT ;` @ NZ? ;,
: LOCATE
 TOKEN? DICT FIND NZ? ;	\ RETURNS ADDRES  OF DICTIONARY TOKEN 
: ', ;, 				\ COMPILES FOUND WORD
: ' LOCATE @ ;			\ RETURMS ADDRES OF CODE FIELD OF WORD
: LIKE ' @ ;			\ RETURMS CODE FIELD OF THE WORD
: CODE, ;, =H ;			\ CREATES WORD ( ADR /NAME/  -- H:=H+2 )

\ MINIMAL COMPILER 
: -ALLOT NEG  : ALLOT H| + ;	\ DE/ALLOCATE SPACE
' `J        CODE, J     		' `RDROP    CODE, RDROP        
'  `IFM  	CODE, (IF-			'  `FOR     CODE, (FOR
' `DUP      CODE, DUP      	' `DROP     CODE, DROP       
=H CSWAP`		' `SWAP_ CODE, SWAP $C3 C,
: MARK>` H : Z, 0 , ;   		       : COMPILE @R+ , ;
: FOR` COMPILE (FOR MARK>` BEGIN` COMPILE PUSH ;
: NEXT` COMPILE POP SWAP THEN` COMPILE (IF- <RELS` RDROP ;
: NEG 1-	: NOT -1 XOR ;   : - NEG		: + 2/ DROP;  ,<
LIKE 1- 1-   CODE, 2-
LIKE STP 3 + 	CODE 1+			LIKE 1+ 1- 		CODE, 2+
: C, DP| 	: C!+ PUSH C!R+ POP ;
LIKE 0  LIKE : CODE, CONST , ', ,			\ WE HAVE CONSTS
$FFFF CONST -1								\ CONSTANT -1
'  `DOES    CONST @DOES 
: (CODE; POP T @ ! ;
: DOES>` COMPILE (CODE; 0 
: `(DZ @DOES +
: CALL, $E8 C,   : REL, HERE 2+ - , ;
: `DZ#  NEG CONST DOES> @ HERE SWAP >, `(DZ ;
0 `DZ# DZ0>   1 `DZ# DZ1>   2 `DZ# DZ2>
\ ADR CNT BYTE --
: FILL 
DZ0> @
\	PUSH  FOR J C, NEXT RDROP DROP; ,<
 CODE, ERASE 0 ,
 


\ DEFINING WORDS
' DP 2- @ LIKE ;` CODE, VALUE , ', CONST	\ WE HAVE VALUES
' `DOVAR  LIKE :  CODE, VAR , ', ,			\ WE HAVE VARS
' ERRV @  LIKE :  CODE, DEFER , ', ,		\ WE HAVE DEFERS
' DP 2- @ LIKE ;` CODE, VECTOR , ', DEFER	\ WE HAVE VECTORS
' `DOVAR 2- LIKE ;` CODE, QUAN , ', VALUE	\ WE HAVE QUANS
' `DOVAR 2- LIKE ;` CODE, VQUAN , ', VECTOR	\ WE HAVE QUANS
: WATCH COMPILE ,< ' `DOVAR 2- , >, COMPILE `SETWATCH 
	LIT `GETWATCH  CODE, , ;

\ ERROR CHECKERS & INITIALIZERS
\ ?? ERRA ERROR? ERRV NZ? INIT (INIT

\ PEEKS , POKES  & MEMORY
\ `C@ CMOVE CMOVE< CSTR CPUSHU DC@ S>" @R+ !R+ !- STR
\ SWAP! S>T ">T C@R+ C!R+ @+ @   
' `C@  CODE, C@ 
: C@+ PUSH C@R+ POP ;


\ PARSING WORDS
\ TOKEN?	( -- LSTR/ERROR)
\ EVAL		GENERAL PARSER/INTERPRETER/COMPILER
\ TOKEN		( DLM -- LSTR )
\ ;(EVL		EVALUATE MEMORY ON INITIALIZING
\ (NUM		( ADR LEN -- NUM/ERROR 0/<>0 )
\ >NUM      ( LSTR -- NUM )
\ NUMC      ( LSTR -- NUM, )
\ OPER[]    [ >NUM @EXEC NUMC @, ]
\ (PARS		( DLM ADR LEN -- ADR1 LEN1 ) 
\ WORD      ( DLM -- LSTR )
\ PARSE     ( DLM -- ADR LEN )
\ LTIB      LENGTH OF REMAINING TEXT BUFFER
\ ETIB      END OF TEXT BUFFER
\ FOUND     POINTS STATE OF FORTH MASHINE INTERPRET/COMPILE
\ SOURCE    KEEPS PROCEDURE OF FINDING END TEXT BUFFER 
\ TBUF      ADDRESS WHITCH HOLDS THE LAST PARSED WORD/LSTR
\ FINDC     SEARCH METHOD ON COMPILING
\ FIND		( LSTR DICT -- ADT/LSTR 1/0 )
\ =H		CREATES WORD POINTED TO HERE
\ T			VALUE -- DICTIOMARY POINTER -     

\ COMPILER WORDS
\ ;,		COMPILES WORD ON EXITTING OF CALLER
\ ("+		SKIPS LSTR
\ H|		MAKES PARENTISIS FROM  H| ( BODY ) TO ;
\ T|		MAKES PARENTISIS FROM  H| ( BODY ) TO ;
\ BEGIN`	MARK START OF LOOP
\ <RELS`	BACK RELEASE OF LOOPS & IFS
\ THEN`		FORWARD RELEASE OF LOOPS & IFS
\ CDICT		DICTIONARY POINTER OF LIST OF WORDS ON COMPILING
\ ;(>"		ON EXIT CREATES LSTR ( ADR LEN -- TBUF )
\ ;DROP		ON EXIT DOES DROP
\ ;THEN		ON EXIT DOES (THEN)
\ (;		PRIMITIVE OF EXIT
\ (JMP		PRIMITIVE OF BRANCH
\ DROP;		DOES -- DROP EXIT
\ (IF		( NUM -- IF NUM=0 THEN BRANCH / ELSE SKIP BRANCH )
\ 0;		( NUM -- IF NUM=0 THEN EXIT )
\ LIT		SENDS NEXT CEIL TO DATA STACK
\ LIT,		COMPILES NUMBER ( NUM -- LIT LIT , , )
\ NOP		DOES NOTHING
\ HERE		OBJECT ADDRESS OF COMPILING
\ OFST		OFFSET TO ORIGINAL ADDRES  OF COMPILING
\
\  `CONT  `DOES  `DOVAR  `GETWATCH  `SETWATCH  `IFM  `MIF
\  `NIPX  `EXEC  `EXECUTE  `FOR  `TWICE  `SKIP  `TODBG
\  `TRAP  `WARY  `BARY
'  `CONT  	CODE, LOOP;
'  `MIF     CODE, (-IF
'  `NIPX    CODE, NIP;
'  `EXEC    CODE, EXEC
'  `EXECUTE CODE, EXECUTE
'  `TWICE   CODE, TWICE|
'  `SKIP    CODE, (SKIP
'  `TODBG   CONST @DBG 
'  `TRAP    CONST @TRAP 
'  `WARY    CODE, (WARY
'  `BARY    CODE, (BARY


\ SKIPPED WORDS
\ `TO_NUM2 `(ACPT `=: XTOK? `PHAX `SW `TROFF `XEVAL `PH  `DOVAR  

\ FACTORY FOR WORDS & SPECIAL ADDRESSES
\ `DINU_  `CALDR_  `DUP_  `NOP_  `RSLD_  `RSST_  `SWAPC_  `SWAP_

\  IO WORDS 
\ ACCEPT  (DE  (DK  EMIT KEY  TIB 

\ MATH , CONSTANTS , LOGIC & STACK
\ AND 1L -/ +2/ +* S1+ 0=     
' `LOBYTE   CODE, W>B         
' `XA       CODE, XA       
' `XR       CODE, XR         ' `ULESS    CODE, U<       
' `ZLESS    CODE, 0<       


\ PRIMITIVES  

: 2LIT @R+ 
: LIT @R+ ;  \ Pushes a constant value onto the top of the data stack. 
: XOR PUSH DUP PUSH J NAND DUP  POP NAND XR NAND POP NAND ;	\ Pops two values, performs XOR, and pushes the result.
: (& @R+ rdrop
: AND NAND \ Pops two bitwise values, performs a bitwise AND, and pushes the result.
: NOT not ; \ Pops one value, performs bitwise NOT, and pushes the result.
: OR  not PUSH not POP NAND ; \ Pops two values, performs a bitwise OR, and pushes the result.
: - neg  \ (SUB) Pops two values, subtracts the second from the first, and pushes the result.
: + +2/ \ (ADD) Pops two values, adds them, and pushes the sum.
: DROP drop ; \ Removes the top element from the data stack. 
: (+ @R+ +2/
: .EXIT POP 
: 2DROP NAND drop ; Removes the top TWO elements from the stack.
: EX POP XR 
: EXECUTE PUSH ;
\ : ;2DROP EX 2DROP ;
: FIX  @R+
: STA  @R+ \ STORE (address): Pops a value from the stack and stores it at a given memory address.
: ! PUSH 
: (! !R+ rdrop ;
: (SETV  rskip (! ;
: LDA  @R+ \ LOAD (address): Pushes the value stored at a given memory address onto the stack.
: @ PUSH 
: (@  @R+ rdrop ; 	\ CONSTANT

\ CONSTANTS

 0 CONST 0 
 -1 CONST -1  
 1 CONST 1
 2 CONST 2


\ ADDITIONAL   = < > <> UM*  UM\MOD U*  U\ 2* 2\ AVG NIP UMOD (DZ2 (DZ1 (DZ (2CON (VAR2 (VAR1 (VAR  

: 2DUP TWICE
: OVER PUSH DUP XR POP ; \ Push the MAIN on the data stack.
: ;DROP EX drop ;
: W>HI (&  ,<  $FF00 ,
: 2OP-? 2DUP XOR
: MSB& (& -32768 ,  
: ?ODD DUP
: ODD (& ,< 1 ,
: (2CON  @R+  (CON ; 	\ 2CONSTANT
: (VAR2  rskip
: (VAR1  rskip
: (VAR  POP ;
: (DZ  POP XR ;					\ FIRST METHOD
: (DZ1 POP XR : 2+ (+ ,< 2 ,	\ SECOND METHOD  ( TO )
: (DZ2 POP XR : 4+ (+ ,< 4 ,	\ THIRD METHOD	 ( AT )
: I J ;
: A@ XA I XA ;
: 0A! 0
: A! PUSH XA
: EXIT rdrop ;
: 0>=; MSB&
: 0; (if EXIT ;;
: = -				\ EQUAL: Pops two values, compares them for equality, and pushes a boolean result (true/false).
: 0= (IF -1  0 ;
: <> -				\ UNEQUAL: Pops two values, compares them for unequality, and pushes a boolean result (true/false).
: 0<> (IF 0 -1 ;
: < - 				\ LESS_THAN: Pops two values, compares if the first is less than the second, and pushes a boolean result.
: 0< MSB& 0<> ;
: > -		\ GREATER_THAN: Pops two values, compares if the first is greater than the second, and pushes a boolean result.
: 0> DUP 0; 
: 0>= MSB& 0= ;
: D1- PUSH DUP IF (1- POP ; THEN (1- POP (1- ;
\ : D1- OVER IF | CSWAP THEN XEP| THEN (1- ;
: DABS DUP 0>=;
: DNEG D1- 
: 2NOT not PUSH not POP ;
: 1+ not 
: NEG (1- not ; \ Pops one value, negates it, and pushes the result.
: D2* 0A! -\
: U1- XEP|
: 1- (1- ;
: D2/ 0A! +* ;
: TIMES PUSH XR 
: TIMES| AHEAD BEGIN PUSH J EXECUTE  POP THEN UNTIL- .EXIT ;
: ROT swap
: USWAP PUSH swap POP ;
: -ROT PUSH swap POP
: SWAP swap ; \ Swaps the top two elements on the stack.
: 2ABS PUSH CALL POP THEN
: ABS DUP <0; NEG ; 
: M+ +2/
: MSB>LSB SIGN&  (IF 0  ,< 1 CONST 1 

\ STANDART	
: D- DNEG
: D+  ROT + PUSH M+ POP + ;
: UM* A! 
: (UM*   0 +* +* +* +* +* +* +* +* +* +* +* +* +* +* +* +* ; 
: UM/MOD A!  0
: (UM/  -/ -/ -/ -/ -/ -/ -/ -/ -/ -/ -/ -/ -/ -/ -/ -/ ;
: U* UM*  DROP ;
: U/ UM/MOD DROP ;
: BIT 1 SWAP
: << TIMES|
: 2* DUP + ;
: >> TIMES|
: 2/ 0
: AVG +2/
: NIP PUSH drop POP ;
: UMOD UM/MOD NIP ;
: * ;DROP  \ MUL: Pops two values, multiplies them, and pushes the product.
: M* 2OP-? PUSH 2ABS UM* POP 0; DNEG ;
: / ;DROP  \ DIV: Pops two values, divides the first by the second, and pushes the quotient.
: M/MOD 2OP-? PUSH 2ABS UM/MOD POP 0; XEP| NEG ;
: MOD M/MOD NIP ;
: UDM* UM* PUSH PUSH (UM* POP M+ POP + ;
: UDM/MOD UM\MOD PUSH XR (UM/ XR POP ;
 

\ Variables AND COMPILATION

: H| val|   0 CONST H
: T| val|   0 CONST T

: ;, EX
: , H|
: !+ PUSH !R+ POP ;
: C, H|  !+ (1- ;   \ IF LITTLE ENDIAN
: 2-DXEP| (1-
: 1-DXEP| (1-
: DXEP| DUP
: XEP| XR EXECUTE POP ;
: BB>W H| C!+ C!+ \ PACK LOW BYTE &  HI BYTE  TO  LITTLE ENDIAN WORD  
: @- 2-DXEP| @ ;
: W>BB H| !+ TWICE ( C@- ) 
: C@- 1-DXEP| 
: C@ @ 
: W>B (& ,< 255 ,
: C!- 1-DXEP| 
: C! DUP PUSH @ W>HI PUSH W>B POP + (! ; \ TAIL COMILATION 
: ALLOT H| + ;
: STR PUSH @R+ XR POP ;
: CSTR @+ (1- swap W>B ;
: C!+ DUP PUSH C! POP 
: 1+ (+ ,< 1 ,
: ;A! EX A! ;
: CMOVE SWAP A! 
: >MOVE PUSH XR ?ODD IF POP CSTR A@ C!+ A! PUSH THEN 2/ 
	AHEAD BEGIN @R+ !a+ THEN UNTIL- .EXIT ; 
: CMOVE< SWAP 
: MOVE< ;DROP ;A! ?ODD IF PUSH PUSH C@- SWAP POP C!- POP THEN 2/
    TIMES| PUSH @- swap POP 
: !- 2-DXEP| ! ;
: `-TEXT 1+ EXIT ; 
: -TEXT ?ODD PUSH -ROT POP 
	IF 1- A! 1- PUSH @R+ W>HI @a+ W>HI = (IF `-TEXT 
	ELSE A! PUSH THEN
  2/ AHEAD BEGIN  @R+ !a+ = (IF `-TEXT THEN UNTIL-  `-TEXT ;




PRINT: Pops a value from the stack and outputs it (e.g., to console).
READ: Reads a value from input and pushes it onto the stack.


\ minimal forth 

: interpretter
 begin  #tib @ >in @ = 
	if 		 		\ if empty then accept new line
		tib  50 accept #tib !   0 >in !    	
	then  			\ full buf
	bl word find dup		\ parse and find
	if 				\ found
		state @  = 
		if 	\ if not imm word on compiling then ,
			, 	
			continue
		then \ if imm word or interpetting then execute
			execute 
			continue	
	then 	\ not found
	dup rot count >num  	\ traing to parse number
	if 	\ unsucessful --
		state @					
		if 		 			\ compiling 
							\ then discard last word
			last @ dup  @ last ! dp ! 
		then 
		abort
	then 					\ sucessful --
	drop drop state @
	if lit lit , , then		\ compile a number 
 again ;