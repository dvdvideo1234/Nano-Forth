' >MARK 4 + ALIAS  2Z,
' >MARK 2+  ALIAS  !>MARK
' HERE      ALIAS  <MARK
' ,         ALIAS  !<MARK
: >LOOP  >MARK <MARK ;
: !>LOOP !<MARK !>MARK ;

' >MARK        ' (BR (( AHEAD
' >MARK     ' (BR 2+ (( IF
' >MARK       ' (FOR (( FOR      ( IN THIS VERSION!!!)
' !>MARK   ' (FOR 2+ (( NEXT     ( IN THIS VERSION!!)
' !<MARK       ' (BR (( AGAIN
' !<MARK    ' (BR 2+ (( UNTIL
' >LOOP        ' (DO (( DO
' >LOOP     ' (DO 2+ (( ?DO
' !>LOOP       ' (LP (( LOOP
' !>LOOP    ' (LP 2+ (( +LOOP

: ELSE  [ ' AHEAD , ]  SWAP !>MARK ; IMMEDIATE
: REPEAT SWAP [ ' AGAIN , ]  !>MARK ; IMMEDIATE
: ;THEN  [ ' ;M 2+ ] LITERAL @ , !>MARK ; IMMEDIATE
' <MARK     ALIAS  BEGIN  IMMEDIATE
' !>MARK    ALIAS  THEN   IMMEDIATE
' IF        ALIAS  WHILE  IMMEDIATE

