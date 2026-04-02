 0 VALUE WADR
: @WORD WADR @+ TO WADR ;
: @BYTE WADR C@+ TO WADR ;
: .ADR CR WADR H. SPACE ;
| : .STR? CREATE DUP C, FOR , NEXT
     DOES> CSTR WADR 2- @ SCAN 1+
    IF WADR 2- 2- @ [ ' A" @ ] LITERAL XOR 0;
       WADR DUP ". CSTR + TO WADR THEN ;
| ' A" 2+ @  ' " 2+ @ ' ." 2+ @  3 .STR? ?STR
| : WW .ADR @WORD DUP H. ?ID. ?STR ;
: L bs FOR WW NEXT ;
: @SEE TO WADR L ;
: SEE ' @SEE ;
| : D8 bs FOR @BYTE .H NEXT SPACE ;
: DU .ADR D8 D8 WADR 1H - 1H TYPE ;
| : ?DU 1H U/MOD SWAP IF 1+ THEN ;
: DUMP SWAP TO WADR ?DU FOR DU NEXT ;
