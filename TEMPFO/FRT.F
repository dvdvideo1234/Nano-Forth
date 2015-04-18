MARKER -DBG

: REQUIRE ' DROP ;
: @+ WCOUNT ;
: C@+ COUNT ;
: !CSP CSP! ;
: >BYTE 255 AND ;
: RSHIFT >BYTE NEGATE SHIFT ;
: LSHIFT >BYTE SHIFT ;
: ?ERROR SWAP IF CR . ABORT THEN DROP ;
: <> = 0= ;
: INVERT -1 XOR ;


: >CFA N>C ;  : CFA> C>N IF ;THEN ?? ;
: >BODY 2+ ;  : BODY> 2- ;
: >LFA >CFA 2- ;
: %>BODY ' >BODY ;
: (>NEXT%) >LFA @ ; ( Given a DEA, return the next DEA. )
: >NEXT% BEGIN  (>NEXT%) DUP 1+ C@ C" - - UNTIL ;
: STARTVOC AT ASSEMBLER  @ ;
| : ?## CONSTANT DOES> @ ;
| 0 ?## #DOES |  : DOES= @ 1+ WCOUNT + #DOES - ;
 ' #DOES  DOES=  ' #DOES 2+ !

\ : STARTVOC ['] ASSEMBLER >WID >LFA @ ;

\ : %>DOES >DFA @ ; ( From DEA to the DOES> pointer for a ``DOES>'' word )
: %ID. ID. ;   ( Print a definitions name from its DEA.)
: IGNORE? 1+ C@ C" ~ = ;


VOCABULARY ASSEMBLER

FLOAD ASGEN.F
FLOAD CIAGIAS.F

