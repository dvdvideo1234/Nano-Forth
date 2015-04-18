
: M: HERE AT , [ ' WORD @ 1+ DUP @ + 2+ , ] [AT] DOES> ] ;
: JM: M: 5 HERE 2- +! ;
: LBL: HEADER COMPILE [ ' INTERPRET 2+ @ , ] ] ;

: CS! AT ON; @  TO ON; ;
: ?CS ON; AT ON; @  - A" CS CHG!"  ;
: CSP! CSP SP TO CSP ;
: ?CSP SP CSP - A" SP CHG!" TO CSP ;

: .MARK >MARK ;     ( FOR IFS , SKIPS, WHILES)
: ,.MARK >RESOLVE ;
: >LOOP >MARK HERE ;
: ,>LOOP , >RESOLVE ;
: ,<MARK ON; , ;
: <MARK HERE TO ON; ;

