


  0
  1
  2   TCOMP.SCR
  3
  4
  5
  6
  7
  8
  9
 10
 11
 12
 13
 14
 15
  0
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
 11
 12
 13
 14
 15
  0
  1   : WORDLIST VOCLINK LINK+ ;
  2   : VOCABULARY TO FORTH MAKEVOC WORDLIST ;
  3   : PREVIOUS  AT ORDER# TO CONTEXT ;
  4   : ALSO CONTEXT TO ORDER# ;
  5   : DEFINITIONS CONTEXT TO CURRENT ;
  6
  7
  8
  9
 10
 11
 12
 13
 14
 15
  0 (  TEST +JUMP  MAKER					  )
  1
  2 : +JUMP POP + PUSH ;   : 1+2*JUMP 1+ 2* +JUMP ;
  3
  4 : MAKER CREATE 1- NEGATE 2+ 2* DUP C, +JUMP  , , ,	' ,
  5	    DOES> COUNT HEADER +JUMP W, W, W, AT EXEC ;
  6
  7 0 NM:   ;M	( GET ADDRESS  / VARIABLE )
  8 1 NM: ! ;M	( SET VARIABLE / VALUE )
  9 2 NM: @ ;M	( GET VARIABLE / CONSTANT )
 10
 11  3 MAKER QUAN ,
 12
 13  5 QUAN QUAN1
 14
 15
  0
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
 11
 12
 13
 14
 15
  0 \ HEAP MANAGEMENT	  <%   %>
  1 F83
  2 MARKER -HEAP   PRUNE
  3
  4 <%
  5	: C: <% CONSTANT %> ;
  6	: ?HERE <% HERE %> U. ;
  7	: +C: 2+ DUP C: ;
  8 %>
  9
 10
 11
 12
 13
 14
 15
  0
  1  MARKER -TARGET
  2    PREVIOUS
  3  VOCABULARY TCOMP
  4  ASSEMBLER ALSO
  5
  6  TCOMP ALSO   DEFINITIONS
  7
  8  |	 32768 CONSTANT MSB
  9  |	MSB 1-	CONSTANT -MSB
 10
 11    VARIABLE LX
 12
 13  : CODE, HEADER , ;
 14  | : @LITERAL @ [',] LITERAL ;
 15
  0
  1  | : @, @ , ;   : OLDTC LIT LIT LIT [ ' [LIT] 2+ , ] ! ;
  2  \ 10 WARY ADR:  10 WARY VAL:
  3  : ALIGNED HERE SWAP ALIGN TO HERE ;
  4  \ | :  GET:   0 DO ' 2+ DUP  I ADR: ! @  I VAL: ! LOOP ;
  5  \	: RESET:   0 DO I VAL: @  I ADR: @ ! LOOP ;
  6  \	:   SET:   0 DO ' EXEC    I ADR: @ ! LOOP ;
  7  \	 10 GET: AGAIN SKIP UNTIL IF -UNTIL -IF ;M DO: [LIT] OF
  8  : (( HEADER COMPILE [ ' DO: @, ] , , IMMEDIATE ;
  9  | : CONST CREATE LX LINK+ , , DOES> 2+ DUP 1+! 2+ @LITERAL ;
 10  | : <F> <% CONST IMMEDIATE %> ;   | : <00F> 0 0 <F> ;
 11
 12   <%
 13    ' IOV @
 14    1 NM: HERE 2+ SWAP! ;M
 15
  0
  1    2 NM: @LITERAL ;M
  2	HEADER JUSTIFY , , , 0 ,  IMMEDIATE
  3   %>
  4  : RDROPS CO RDROP ;
  5  | : DUPE? RDROPS RESCAN 0>=
  6	 IF 2DROP ;THEN STR ROT - IF DROP ;THEN  RDROP
  7	2+ STR 0< A" DUP! " MSB OVER 2- XOR!  HERE   ;
  8  | : ?REL HERE SWAP  IF OVER 2+ - THEN ;
  9  | : A?REL DUP 1- C@ 1 OR $ E9 XOR 0= ?REL ;
 10  : FW <00F> TO JUSTIFY
 11	    DOES> 2+ DUP 1+! STR 0<
 12	   IF @, ;THEN LINK+ ;
 13
 14  : ?FW JUSTIFY DUPE?  N>C SWAP
 15
  0
  1	 BEGIN OVER TO >< ?DUP -UNTIL DROP ;
  2
  3  : FL <00F> TO JUSTIFY
  4	    DOES> 2+ DUP 1+! STR 0<
  5	   IF @LITERAL ;THEN  ?E ' CASE
  6	    ['] JMP,  OF BCOMPILE [ $ E9 C, ]
  7	     LINK+ ENDOF
  8	    ['] CALL, OF BCOMPILE [ $ E8 C, ]
  9	     LINK+ ENDOF
 10	    [']   DW, OF LINK+ ENDOF
 11	    A" NO LBL OP!" ENDCASE ;
 12  | : ?FL JUSTIFY DUPE? BEGIN TO >< ?DUP
 13	   WHILE A?REL REPEAT
 14    ( !!! BLWORD DROP ) BLWORD DROP RDROP ;
 15
  0
  1
  2
  3    : C: MSB <F> ;	: L: ?FL HERE C: ;
  4   | : ?TAB 52 OUTC < IF CR ;THEN 26 OUTC OVER MOD - SPACES	;
  5   | : VIEWER: : DOES> PUSH	CR LX @ SKIP BEGIN
  6	STR SWAP DUP @ R@ EXECUTE THEN ?DUP -UNTIL RDROP ;
  7   | : ?NODE. 0= IF	DUP STR .H @ .H 4 - ?ID. ?TAB ;THEN DROP ;
  8   VIEWER:  TLIST.  DUP XOR ?NODE. ;
  9   VIEWER:  UNDEF.  0< ?NODE. ;
 10   VIEWER: UNUSED.  -MSB AND ?NODE. ;
 11   \ PREVIOUS
 12    VOCABULARY KERNEL   KERNEL ALSO F83 PRUNE
 13
 14
 15
  0
  1  FORTH'   DoVoc,dodef,dovar,lastw,0
  2  ABORT  A"  ?,   (" (". ".    (LIT")   (".   ".
  3  : >MARK  HERE COMPILE [ 0 , ] ;
  4  : ALIAS ENTRY COMPILE #ALI , ;
  5  : D+  PUSH SWAP PUSH + POP POP +? ;
  6  : S>D DUP 14 FOR 2/ NEXT ;
  7  : M+ S>D D+ ;
  8
  9
 10
 11
 12
 13
 14
 15
  0
  1
  2
  3  \ QUERY'
  4  : ?LITERAL DBL 1+ IF SWAP DUP [',] LITERAL
  5	       THEN DROP [',] LITERAL ;
  6  : LITERAL STATE IF [',] [LIT] THEN ; IMMEDIATE
  7  : INTERPRET BEGIN BEGIN -FIND
  8		?DUP IF ?,  AGAIN THEN
  9	   NUM ?? ?LITERAL  AGAIN ;
 10  : ?SOURCE	1  -1  WITHIN IF BLK BLOCK 1K ;THEN TIB SPAN ;
 11  : ?DELIM OVER  +
 12  : WORD ?SOURCE >IN - DUP PUSH + A! POP
 13	FOR C@A 0=
 14  BLWORD
 15
  0
  1  (word
  2   -FIND
  3  FIND
  4
  5  \	 USE:  DO: [LIT]   ;M
  6  :	[ 0 TO STATE ; IMMEDIATE
  7  : ] -1 TO STATE ;
  8  :	BINARY	  2  TO  BASE ;
  9  :	HEX	 16  TO  BASE ;
 10  :	DECIMAL  10  TO  BASE ;
 11  :	NUMBER	PUSH PUSH BASE	0 R@ C@ C" - CASE
 12	 C"  - OF -1 OR   ENDOF  C" $ OF HEX     ENDOF
 13	 C"  # OF DECIMAL ENDOF  C" % OF BINARY  ENDOF
 14    0 DUP	 POP POP ROT IF 1- PUSH 1+ POP
 15
  0
  1
  2
  3  : CONVERT FOR C@A+ ?DIGIT INV -IF INV M+ NEXT ;THEN
  4
  5  : NUMBER OVER C@ C" - = DUP TO DPL  \ SIGN
  6	  IF 1 /STRING	THEN  DPL -ROT -1 TO DPL  \ 1 STEP FORWARD
  7	PUSH A! 0 0 POP  CONVERT
  8
  9
 10
 11  : ENTRY  CURRENT @ BLWORD DUP CURRENT ! ", , ;
 12  : HEADER ?NONAME  ?DUP IF 1- TO ?NONAME HERE  TO CFA
 13		 TO VSWAP  CFA ALIAS  TO VSWAP ;THEN
 14	ENTRY HERE TO CFA ;
 15
  0
  1  : CREATE HEADER COMPILE #VAR ;
  2  : ;	SMUDGE [',] ;M  ;     IMMEDIATE
  3  : : HEADER SMUDGE [',] DO: ;
  4  : ;CODE  COMPILE ;code [',] [  ASM ;  IMMEDIATE
  5  2: DOES> :3 :4 COMPILE ;code
  6	   #VAR  232 C, HERE 2+ - , ;	   IMMEDIATE
  7  : ;code POP  CFA ! ;
  8
  9
 10
 11
 12
 13  : LB> 255 AND ;
 14  : 256* 8 FOR 2* NEXT ;
 15
  0
  1  : HB> -256 AND ;
  2  : 256/ 8 FOR 2/ NEXT ;
  3  : C@W 1- @ 256/ ;
  4  : C@ @ LB> ;
  5  : >< DUP 256* PUSH 256/ LB> POP XOR ;
  6  : +!   A! @A   + !A ;
  7  : -!   A! @A   - !A ;
  8  : XOR! A! @A XOR !A ;
  9  : C! A! LB> @A HB> XOR !A ;
 10
 11  0 VALUE ?NONAME
 12  0 VALUE CFA
 13  0 QUAN  HERE
 14  0 VALUE SCRH
 15
  0
  1  0 VALUE CURRENT
  2  0 VALUE CONTEXT
  3  0 VALUE FIRST	(  BUFFERS)
  4  0 VALUE LAST
  5
  6  : ALLOT AT HERE +! ;
  7  : ", C@ 1+ ALLOT ;
  8  : C, HERE C! 1 ALLOT ;
  9  : , DUP C, 256/ C, ;
 10  : D, , , ;
 11  : BCOMPILE @R C, POP 1+ PUSH ;
 12  : COMPILE	@R DUP !R+ , ;
 13  : DCOMPILE  @R DUP !R+ , @R DUP !R+ , ;
 14
 15
  0
  1
  2  \ CHARS
  3  \ : CHARS 1+ SWAP DO I EMIT LOOP ;
  4  \ (")  ; (LP  (DO  (FOR
  5  \	(OF  (BR   BRANCH  0BRANCH  -BRANCH  EXIT  R4TH>
  6
  7  \ IMMEDIATE  SMUDGE
  8  : >MARK HERE COMPILE [ 0 , ] ;
  9
 10
 11
 12
 13
 14
 15
  0
  1
  2
  3
  4  \ ERRORS
  5  : ?? A" Not Found" ;
  6  : ?C STATE 0= A" COMPILING ?" ;
  7  : ?E EXECUTING ?" ;
  8  : ?= - A" UNPAIRED" ;
  9  : TO: CREATE C, IMMEDIATE DOES> C@ ?' PUSH + POP ?, ?;
 10    2 TO: TO   4 TO: AT
 11  : ' ?' DROP ;
 12  : [TO:] TO: DOES> ' + , ; IMMEDIATE
 13
 14    0 [TO:] [',]    2 [TO:] [TO]    4 [TO:] [AT]
 15
  0
  1
  2  : FIND PUSH -1 ORDER# @T+ FOR @T+ @ SWAP NEXT
  3	   DROP CONTEXT @   (FIND TO ?, ;
  4
  5  \ DONE LIST
  6  C@     1+	 [  ]	 C,   ALIAS   ",   ALLOT
  7  \ TO DO LIST
  8  BLOCK  WORD  FIND	 '     [']   ?'    ?,
  9   W"     B"    BZ"   C@T+   FOR   NEXT  B",  W",
 10  CREATE DOES> HEADER EXEC  CFA   VSWAP
 11
 12
 13
 14
 15
  0 \ WQARY
  1 : ARY, HERE DUP PUSH 2- EXEC  POP - CLARY ;        ' WARY 2+ @
  2 0 NM: EXEC ! ;M  1 NM: EXEC @ ;M		3 MAKER WQARY ARY,
  3 HERE .
  4 10	WQARY  PQARY
  5 HERE .
  6 : SHOW 10 FOR R@ PQARY . NEXT ;
  7 : SETW 10 FOR R@ DUP TO PQARY NEXT ;
  8 \ VARIABLE COUNTING
  9 \ : . S. COUNTING AT 1+ SPACE U. BLK . CSP . ; IMMEDIATE
 10 \ : | 1 TO HEADER ;   ' >R ALIAS PUSH   ' R> ALIAS POP
 11 \ | : ARY, HERE DUP PUSH 2- EXEC  POP - CLARY ;   ' WARY 2+ @
 12 \ 0 NM: EXEC ! ;M	1 NM: EXEC @ ;M        |  3 MAKER WQARY ARY
 13 \ | 10 WQARY  ADR:	|  10 WQARY VAL:
 14 \	' XOR 2+  ALIAS XOR!
 15
  0 \ TARGET  COMPILER	PROJECT
  1 \ F83  VOCABULARY  TARGET  ALSO TARGET DEFINITIONS ALSO
  2 : TAR ;	       \ TARGET ADDRESS    LAST WORD ADDRESS
  3  0 VALUE  T-OFFS   0 VALUE	T-ADR  0 VALUE T-LAST
  4  VARIABLE T-H      0 VALUE	T-END  : T-HERE T-H @ T-OFFS - ;
  5 : T-SPACE HERE TO T-ADR CLARY HERE TO T-END ;
  6 : T-ALLOT T-H +! ;	 : T-C, T-H @1+! C! ;	: T-,  T-H @2+! ! ;
  7 : T-ORG T-ADR TUCK	T-H !  - TO T-OFFS ;	: T-!  T-OFFS + ! ;
  8 : T-@  T-OFFS + @ ;  : T-C! T-OFFS + C! ;  : T-C@ T-OFFS + C@ ;
  9 : T-STR, FOR COUNT T-C, NEXT DROP ;
 10 : T-",  COUNT DUP T-C, T-STR, ;
 11
 12 \  TEST   200 TSPACE  300 T-ORG  5 T,  300 T-@ .
 13
 14
 15
  0
  1
  2
  3  TH:	PUSH  SI	      ;   F>C;
  4	    MOV   SI,[BP]
  5		INC   BP
  6		INC   BP
  7		RET
  8  F: 	JMP   SI	      ;   F>C
  9  H: 	DEC   BP	      ;   :C>F
 10		DEC   BP
 11		MOV   [BP],si
 12  J4th:	POP   SI	      ;   C>F
 13	     NEXT
 14
 15
  0  PRUNE   ONLY	 F83	  \  -MAC
  1  MARKER -TARGET	 VOCABULARY TCOMP     VOCABULARY KERNEL
  2  KERNEL ALSO	 TCOMP ALSO    TO TCOMP     VARIABLE T-LX
  3 : OLDTC LIT LIT LIT [ ' [LIT] 2+ , ] ! ;
  4 \ : | 1 TO HEADER ; IMMEDIATE
  5 \ : HEADERS 0 TO HEADER ;	  IMMEDIATE
  6 \ : -HEADERS -1 TO HEADER ;   IMMEDIATE
  7   : "C  C" " WORD ", ;
  8
  9 : [[ POP >IN PUSH SWAP DUP IF 1- THEN PUSH PUSH ;
 10 : ]] POP POP ?DUP IF 1- R@ TO >IN PUSH PUSH ;THEN RDROP PUSH ;
 11 ' , 2+  ALIAS T-COMPILE      ' C, 2+ ALIAS T-BCOMPILE
 12    ' HERE    ALIAS T-HERE        ' C,  ALIAS  T-C,
 13    ' CLARY   ALIAS T-CLARY       ' ,   ALIAS  T-,
 14    ' ALLOT   ALIAS T-ALLOT       ' !   ALIAS  T-!
 15		   1 16 +THRU
  0 \ RENAMED WORDS
  1    ' @       ALIAS T-@           ' C!  ALIAS  T-C!
  2    ' C@      ALIAS T-C@      ' HEADER  ALIAS  T-HEADER
  3    ' STR,    ALIAS T-STR,        ' ",  ALIAS  T-",
  4 (  ' ALIAS   ALIAS T-ALIAS)' IMMEDIATE ALIAS  T-IMMEDIATE
  5    ' >MARK   ALIAS T->MARK  ' >MARK 2+ ALIAS  T->RELEASE
  6    ' <MARK   ALIAS T-<MARK   ' ,<MARK  ALIAS  T-<RELEASE
  7    : T-(( HEADER COMPILE [ ' DO: @ , ] , , ;
  8    ' [',]             ALIAS  T-[',]      IMMEDIATE
  9    ' TO               ALIAS  T-TO        IMMEDIATE
 10    ' AT               ALIAS  T-AT        IMMEDIATE
 11    ' [TO]             ALIAS  T-[TO]      IMMEDIATE
 12    ' [AT]             ALIAS  T-[AT]      IMMEDIATE
 13    ' T->RELEASE       ALIAS  T-THEN      IMMEDIATE
 14    ' \                ALIAS  T-\         IMMEDIATE
 15
  0 \ RENAMED WORDS 2
  1    ' T->MARK ' (BR           T-((  T-SKIP   IMMEDIATE
  2    ' T->MARK ' (BR 2+        T-((  T-IF     IMMEDIATE
  3    ' T->MARK ' (BR 4 +       T-((  T-IF#    IMMEDIATE
  4    ' T-<RELEASE ' (BR        T-((  T-AGAIN  IMMEDIATE
  5    ' T-<RELEASE ' (BR 2+     T-((  T-UNTIL  IMMEDIATE
  6    ' CSP!                  ALIAS   T-CASE   IMMEDIATE
  7    ' T->MARK    ' (OF        T-((  T-OF     IMMEDIATE
  8    ' T->MARK      ' (FOR     T-((  T-FOR    IMMEDIATE
  9    ' T->RELEASE ' (FOR 2+    T-((  T-NEXT   IMMEDIATE
 10    ' T-<RELEASE ' (BR 2+ 2+  T-((  T-UNTIL# IMMEDIATE
 11    ' -IF                   ALIAS   T-WHILE# IMMEDIATE
 12    ' T-<MARK               ALIAS   T-BEGIN  IMMEDIATE
 13    ' IF                    ALIAS   T-WHILE  IMMEDIATE
 14
 15
  0 \ RENAMED WORDS 3
  1 : T-ELSE T-[',] T-SKIP  SWAP T-[',] T-THEN ;   IMMEDIATE
  2	' T-ELSE              ALIAS   T-ENDOF      IMMEDIATE
  3
  4 : T-REPEAT	T-[',] T-AGAIN T-[',] T-THEN ;     IMMEDIATE
  5 : T-ENDCASE  COMPILE DROP T-BEGIN SP CSP  -
  6   T-WHILE T-[',] T-THEN  T-REPEAT TO CSP ;   IMMEDIATE
  7    ' F83      ALIAS T-F83    ' WORDS ALIAS T-WORDS
  8    ' [  ALIAS T-[  IMMEDIATE     ' ]   ALIAS  T-]
  9  : T-ALIGNED HERE SWAP ALIGN TO HERE ;
 10 \ | : T-GET:  T-FOR ' 2+ DUP  R@ TO ADR: @  R@ TO VAL: T-NEXT ;
 11 \ : T-RESET: 10 T-FOR  R@ VAL:   R@ ADR:  ! T-NEXT ;
 12 \ : T-SET:	T-FOR ' EXEC    R@ ADR: @ ! T-NEXT ;
 13 \ 10 T-GET:  T-AGAIN T-SKIP T-UNTIL T-IF  T--UNTIL T--IF T-OF
 14 \		   ;M DO: [LIT]
 15
  0 \ RENAMED WORDS 4
  1 \ ' ;M       ALIAS  T-;M       IMMEDIATE
  2 \ ' DO:      ALIAS  T-DO:
  3 ' :        ALIAS  T-:
  4 ' ;        ALIAS  T-;        IMMEDIATE
  5 ' '        ALIAS  T-'
  6 ' LITERAL  ALIAS  T-LITERAL  IMMEDIATE
  7
  8 \ : T-2*+JUMP 2* POP + PUSH ;
  9 \ : T-MAKER CREATE NEGATE 3 + DUP C, T-2*+JUMP  , , ,  ' ,
 10 \	     DOES> COUNT T-HEADER T-2*+JUMP W, W, W, AT EXEC ;
 11
 12 : T-ONLY ORDER# TO 0  KERNEL DEFINITIONS   ALSO
 13			  TCOMP ALSO ;
 14
 15
  0 \ TARGET COMPILER
  1    : CODE, HEADER , ;	   : ?HERE <% HERE %> U. ;
  2    : DUO,  CODE, , ;	   : TRIO, DUO, , ;
  3  |	 32768	   CONSTANT WRD    |   WRD 2/	 CONSTANT CNST
  4  |	WRD CNST + CONSTANT MSB    |  MSB NOT	 CONSTANT -MSB
  5  | : @LITERAL @ [',] LITERAL ; | : @, @ , ;
  6  | : CONST CREATE T-LX LINK+ , ,
  7	 DOES> 2+ DUP 1+! 2+ @LITERAL ;
  8  | : <F> <% CURRENT PUSH  TO TCOMP
  9	       CONST IMMEDIATE	 POP TO CURRENT %> ;
 10  | : RDROPS CO RDROP ;
 11  | : ?REL HERE SWAP  IF OVER 2+ - THEN ;
 12  | : A?REL DUP 1- C@ 1 OR $ E9 XOR 0= ?REL ;
 13
 14
 15
  0 \ TARGET COMPILER 2
  1   <%  ' IOV @
  2    1 NM: HERE 2+ SWAP! ;M
  3    2 NM: @LITERAL ;M
  4	HEADER JUSTIFY , , , 0 ,  IMMEDIATE
  5   %>
  6  | : DUPE? RDROPS RESCAN 0>=
  7	 IF 2DROP EXIT THEN STR ROT -
  8	 IF DROP  EXIT THEN  RDROP
  9	2+ STR 0< A" DUP! " WRD OVER 2- XOR!  HERE   ;
 10  |	: ?DEFWD IF @, ;THEN LINK+ ;
 11
 12  : C: CNST <F> ;	     : +C: 2+ DUP C: ;
 13
 14  : FW:  0 C: TO JUSTIFY DOES> 2+ DUP 1+! STR 0<  ?DEFWD ;
 15
  0 \ TARGET COMPILER 3
  1  : ?FW JUSTIFY DUPE?  N>C SWAP
  2	 BEGIN OVER TO >< ?DUP -UNTIL DROP ;
  3
  4				       ASM
  5  : FL: 0 0 <F> TO JUSTIFY
  6	    DOES> 2+ DUP 1+! STR 0<
  7	   STATE IF ?DEFWD  EXIT THEN
  8	   IF @LITERAL EXIT THEN  ?E ' CASE
  9	    ['] JMP,  OF BCOMPILE [ $ E9 C, ]
 10	     LINK+ ENDOF
 11	    ['] CALL, OF BCOMPILE [ $ E8 C, ]
 12	     LINK+ ENDOF
 13	    [']   DW, OF LINK+ ENDOF
 14	    A" NO LBL OP!" ENDCASE ;   END-CODE
 15
  0 \ TARGET COMPILER 4
  1  | : ?FL JUSTIFY DUPE? BEGIN TO >< ?DUP
  2	   WHILE A?REL REPEAT
  3    ( !!! BLWORD DROP ) BLWORD DROP RDROP ;
  4
  5 : L: ?FL HERE WRD <F> ;    IMMEDIATE
  6
  7 : T-COMP, DUP 2+ PUSH STATE PUSH ]
  8		PERFORM POP TO STATE POP ;
  9 : T-LABEL, POP  T-COMP, PUSH ;
 10   | : ?TAB 52 OUTC < IF CR EXIT
 11			 THEN 26 OUTC OVER MOD - SPACES  ;
 12   | : VIEWER: : DOES> PUSH	CR T-LX @ SKIP BEGIN
 13	STR SWAP DUP @ R@ EXECUTE THEN ?DUP -UNTIL RDROP ;
 14   | : ?NODE. 0= IF	DUP STR .H @ .H 4 - ?ID. ?TAB
 15		    EXIT THEN DROP ;
  0 \ TARGET COMPILER 5
  1 \  : DO' ' EXEC ; IMMEDIATE
  2
  3
  4   VIEWER:  TLIST.  DUP XOR ?NODE. ;
  5   VIEWER:  UNDEF.  MSB AND ?NODE. ;
  6   VIEWER: UNUSED.  -MSB AND ?NODE. ;
  7   VIEWER: DEF.  MSB AND 0= ?NODE. ;
  8   VIEWER: USED.  -MSB AND 0= ?NODE. ;
  9
 10   PRUNE
 11
 12
 13
 14
 15
  0 \ PREDEFINED LABELS & WORDS
  1  FL: _TOP	 FL: <SWAP   FL: <USER	 FL: <@USER   FL: <@EXEC-2
  2  FL: <MAIN	 FL: <WARY   FL: <PUSH	 FL: <DROP    FL: <!USER
  3  FL: <TRONX  FL: <EX     FL: <DBG	 FW: ;code    FL: <!USER-1
  4  FL: <VAR	 FL: <VAR-1  FL: <VAR-2  FL: <VAR-3   FL: <@USER-1
  5  FL: <CNST	 FL: <CNST-1 FL: <CNST-2 FL: <CNST-3  FL: <ALI
  6		 FL: <JSR-1  FL: <JSR-2  FL: <JSR-3   FL: <JSR-4
  7  FL: <STOR	 FL: <STOR-1 FL: <STOR-2 FL: <STOR-3  FL: <@REG
  8  FL: <DOES	 FL: <DOES-1 FL: <DOES-2 FL: <DOES-3  FL: <!REG
  9 FL: <@USER-2 FL: _"1     FL: _"2
 10
 11  FL: _OF	 FL: _JUMP   FL: _IF	 FL: IF#     FL: ;#
 12  FL: _-IF	 FL: @IP#    FL: JUMP#	 FL: _LIT    FL: EXEC#
 13  FL: _EXIT	 FL: _NEXT   FL: _EXEC	 FL: NEXT#   FL: _DROP
 14  FL: _PUSH	 FL: RPUSH#  FL: OF#	 FL: -IF#    FL: _ORIG1
 15
  0    : T:(  CREATE  , , DOES> T-COMP, PERFORM ;
  1    : T:-( <% T:( %> ;
  2    ' T->RELEASE       ALIAS        THEN   IMMEDIATE
  3    ' T->MARK       ' _JUMP   T:-(  SKIP   IMMEDIATE
  4    ' T->MARK       ' _IF     T:-(  IF     IMMEDIATE
  5    ' T->MARK       ' _-IF    T:-(  ~IF    IMMEDIATE
  6    ' T-<RELEASE    ' _JUMP   T:-(  AGAIN  IMMEDIATE
  7    ' T-<RELEASE    ' _IF     T:-(  UNTIL  IMMEDIATE
  8    ' CSP!                  ALIAS   CASE   IMMEDIATE
  9    ' T->MARK       ' _OF     T:-(  OF     IMMEDIATE
 10    ' T-<MARK       ' _PUSH   T:-(  FOR    IMMEDIATE
 11    ' T-<RELEASE    ' _NEXT   T:-(  NEXT   IMMEDIATE
 12    ' T-<RELEASE    ' _-IF    T:-(  ~UNTIL IMMEDIATE
 13    ' "C            ' _"1     T:-(  "      IMMEDIATE
 14    ' "C            ' _"2     T:-(  ."     IMMEDIATE
 15
  0    ' -IF                   ALIAS   ~WHILE IMMEDIATE
  1    ' T-<MARK               ALIAS   BEGIN  IMMEDIATE
  2    ' IF                    ALIAS   WHILE  IMMEDIATE
  3
  4 : ELSE T-[',] SKIP  SWAP T-[',] THEN ;   IMMEDIATE
  5	' ELSE            ALIAS   ENDOF      IMMEDIATE
  6
  7 : REPEAT  T-[',] AGAIN T-[',] THEN ;     IMMEDIATE
  8 : ENDCASE T-[',] _DROP T-BEGIN SP CSP  -
  9   T-WHILE T-[',] THEN  T-REPEAT TO CSP ; IMMEDIATE
 10
 11 T-: ;M  T-LABEL, T-[',] _EXIT [',] [ ;  IMMEDIATE
 12 T-: : ?FW T-: RECOVER T-[',] <JSR-1 ;
 13 T-: ; T-[',] ; RECOVER  [',] ;M ;  IMMEDIATE
 14
 15
  0 \ DEFINIG WORDS
  1 \	T-: DOES> [',] ;code  " <DOES-1 #, CALL,"
  2 \	    "EVAL T-; IMMEDIATE
  3
  4    T-: T-CREATE   T-HEADER
  5		      T-LABEL, T-[',] <VAR-1 T-;
  6
  7    T-: T-VARIABLE T-CREATE 0 T-, T-;
  8
  9    T-: T-CONSTANT T-HEADER
 10		      T-LABEL, T-[',] <CNST-1 T-, T-;
 11
 12    T-: T-USER     T-HEADER
 13		      T-LABEL, T-[',] <USER   T-, T-;
 14
 15
  0 \ DEFINIG WORDS	- CONTINUE 1
  1
  2    T-: T-VUSER    T-HEADER
  3		      T-LABEL, T-[',] <@USER-1
  4		      T-LABEL, T-[',] <!USER  T-, T-;
  5
  6    T-: T-QUSER    T-HEADER
  7		      T-LABEL, T-[',] <@USER-2
  8		      T-LABEL, T-[',] <!USER-1
  9		      T-LABEL, T-[',] <USER     T-, T-;
 10
 11    T-: T-RVALUE   T-HEADER
 12		      T-LABEL, T-[',] <@REG
 13		      T-LABEL, T-[',] <!REG  T-, T-;
 14
 15
  0 \ DEFINIG WORDS	- CONTINUE 2
  1
  2    T-: T-VALUE    T-HEADER
  3		      T-LABEL, T-[',] <CNST-2
  4		      T-LABEL, T-[',] <STOR-1   T-, T-;
  5
  6    T-: T-QUAN     T-HEADER
  7		      T-LABEL, T-[',] <CNST-3
  8		      T-LABEL, T-[',] <STOR-2
  9		      T-LABEL, T-[',] <VAR-1    T-, T-;
 10
 11  T-: NM: NEGATE HERE SWAP  [',] [  [',] <DOES-1  ] \ !!! ]
 12		[AT] DOES> HERE 2- +! ] T-;
 13
 14
 15
  0 \ DEFINIG WORDS	- CONTINUE 3
  1
  2    T-: T-RECOVER RECOVER T-;
  3
  4    T-: T-ALIAS  T-HEADER
  5		    T-LABEL, T-[',] <ALI  T-, T-;
  6
  7    T-: T-VECTOR T-HEADER
  8		    T-LABEL, T-[',] <@EXEC-2
  9		    T-LABEL, T-[',] <STOR-1   T-, T-;
 10
 11    T-: ;THEN   T-LABEL, T-[',] _EXIT
 12		   T-[',] THEN T-;         IMMEDIATE
 13
 14   -MAC	  \   !!!
 15
  0
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
 11
 12
 13
 14
 15
  0
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
 11
 12
 13
 14
 15
  0 \  TEST FOR NEXT : ALIAS DOES> CONSTANT VARIABLE USER ;
  1  0 CONSTANT 0  1 CONSTANT 1  -1 CONSTANT -1 2 CONSTANT 2
  2 : MAX INV OVER + INV -IF DROP EXIT THEN + ;  : 1+  1 + ;
  3 : MIN INV OVER + INV -IF + EXIT THEN DROP ;  : 1- -1 + ;
  4 : C@A+ @A DUP C!A+ 255 AND ; : @A+ @A DUP !A+ ;
  5 : ABS -IF INV 1+ THEN ;		: NIP OVER XOR XOR ;
  6 : PERFORM @ IF EXEC EXIT THEN DROP ; : OR OVER INV AND XOR ;
  7 : EMIT _EMIT PERFORM DROP ; 	      : ?2^ DUP 1- AND ;
  8 : ?EMIT OVER INV + -IF DROP EMIT EXIT THEN DROP ;
  9 : TYPE SWAP A! FOR C@A+ EMIT NEXT ; : CLIP PUSH MAX POP MIN ;
 10 : KEY  DUP	 _KEY PERFORM ;  : ?KEY DUP  _?KEY PERFORM ;
 11 : SEARCH FOR @A+ OVER XOR IF DROP NEXT # 0 EXIT THEN RDROP A ;
 12 : * A! 15 FOR +* NEXT DROP A ;
 13 : *M A! 15 FOR +* NEXT PUSH DROP A POP ;
 14 : /MOD  FOR BEGIN OVER OVER + -IF DROP 2* NEXT EXIT THEN
 15	    OVER XOR  XOR INV 2* INV NEXT ;
  0
  1  0 VALUE HANDLE
  2  0 VALUE AXREG   0 VALUE DXREG
  3 : D0 0 0 ;	\ IO KERNEL FUNCTIONS
  4 : DO_DOS A PUSH DOS TO AXREG  A TO DXREG  POP A! ;
  5 : DO_HANDLE PUSH HANDLE POP DO_DOS ;
  6 : HFSIZE D0 $ 4202 DO_HANDLE ;  : HCLOSE D0 $ 3E00 DO_HANDLE ;
  7 : HREAD $ 3F00 DO_HANDLE ;	      : HWRITE $ 4000 DO_HANDLE ;
  8 : BLKPOS 1K M* $ 4200 DO_HANDLE ; : FOPEN A D0 $ 3D02 DO_DOS ;
  9 : RBLK BLKPOS 1K HREAD ;	      : WBLK BLKPOS 1K HWRITE ;
 10 : F_KEY 1 SP@ OVER HREAD ;	      : F_EMIT SP@ 1 HWRITE NIP ;
 11 : STD_KEY  0 D0 $ 100 DO_DOS ;   : STD_EMIT  D0 $ 200 DO_DOS ;
 12 : STD_?KEY	D0 D0 DO_DOS ;
 13
 14
 15
