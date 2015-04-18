
 : N>LINK N>C 2- ;
 : V>LINK     2- ;
 0 VALUE FENCE

 : forget DUP FENCE  U< A" fence !" PUSH ( Žƒ€ˆ—ˆ’…‹ - R@ )
 BEGIN VOCLINK       ( ‘š„š†€ €„…‘€ € €„…‘€ € €‰-Ž‘‹…„ˆŸ ‘ˆ‘šŠ)
  @ ?DUP R@ U<        ( ’Ž‰ Ž-Œ€‹šŠ ‹ˆ … Ž’ ‡€„€„…ˆŸ ?)
 0= WHILE @ VOCLINK !  ( „ŽŠ€’Ž … … - …Œ€•ˆ ƒŽ ˆ …Œˆˆ ŠšŒ …„ˆ˜…)
 REPEAT
 VOCLINK             ( ‘‹…„ Š€’Ž ‘€ …Œ€•€’ˆ ‚‘ˆ—Šˆ Ž-ƒŽˆ ‘ˆ‘š–ˆ)
 BEGIN DUP 2-        ( „€ ‘… €€‚ˆ ‘š™Ž’Ž ˆ ‘ „“Œˆ’… Ž’ Ž‘’€€‹ˆ’…)
   BEGIN @ DUP       ( - €Œˆ€ ‘… €„…‘€ € €‰-ƒŽ€’€’€ „“Œ€ Ž’ ‘ˆ‘šŠ€)
     R@ U<           ( - ’Ž‰ Ž-Œ€‹šŠ ‹ˆ … Ž’ ‡€„€„…ˆŸ ?)
   0= WHILE N>LINK     ( - „ŽŠ€’Ž … … - …Œˆˆ ŠšŒ …„ˆ˜…)
   REPEAT            ( - €ŠŽ … €Œ…… -v €„Ž‹“)
   OVER 2- !         ( …ƒˆ‘’ˆ€… € €„…‘€ )
   @ ?DUP            ( ’Ž‚€ Ž‘‹…„ˆŸ ‘ˆ‘šŠ ‹ˆ … ?)
 0= UNTIL FORTH        ( FORTH -> CONTEXT)
 TO FORTH POP        ( FORTH -> CURRENT)
 TO HERE             ( R> -> HERE )
 DROP ;              ( VOCLINK @ )


 : FORGET ' C>N DROP forget ;

( HERE TO FENCE)

: WORDS CR 10 TO CSP CONTEXT -1 0 DO @ ?DUP
 IF DUP
    C@ #LEN AND 6 + OUTC + 80 <
    0= IF CR CSP ?DUP
        IF 1- TO CSP
        ELSE 10 TO CSP KEY LOW 27 =
            IF DROP I " LISTED" LEAVE THEN
        THEN
    THEN DUP H. DUP ID.
    1H OUTC OVER MOD ?DUP
    0= IF DUP THEN - DUP 13 < 0= IF DROP 1 THEN
    OUTC 64 < 0= IF 1- THEN SPACES
    N>C 2-
 ELSE CR I " TOTAL" LEAVE THEN
 LOOP ". ."  WORDS = " . ;

: PRUNE VOCLINK
 BEGIN DUP PUSH  ( „ŽŠ€’Ž ˆŒ€ Ž™… ‘ˆ‘š–ˆ               )
        V>LINK   ( Ž‡ˆ–ˆŽˆ€… ‚š•“ ‘ˆ‘šŠ           )
   BEGIN @ DUP   ( „ŽŠ€’Ž ‚ ‘ˆ‘šŠ€ ˆŒ€ Ž™… „“Œˆ        )
     HERE U<     ( €ŠŽ €„…‘€ … >= HERE                 )
 0= WHILE N>LINK REPEAT  ( ˆƒŽ’‚ˆ ‡€ ˆ‡’ˆ‚€…          )
 DUP R@ V>LINK !
       ( ‡€ŽŒˆ ‚š‚ ‚š‡‚€’ˆŸ ‘’…Š ‹ˆŠ € „“Œ€ < HERE)
       ( ˆ‡’ˆ‰ Š€’Ž Ž‹‡“‚€˜ ŠŽ…€ € ‘’…Š€           )
 ?DUP IF DUP PUSH      ( €ŠŽ ‘ˆ‘šŠ€ … €‡… - ‘‹…„‚€™ )
 BEGIN N>LINK          ( ‘‹…„‚€™€ „“Œ€                  )
 @ ?DUP                ( ˆŒ€ ‹ˆ                         )
 WHILE DUP HERE U<     ( „ŽŠ€’Ž „“Œˆ’… ‘€ ‘ €„…‘ < HERE)
  IF DUP POP            ( ‘… €‚š‡‚€’ ‚ ‘ˆ‘šŠ        )
    N>LINK               ( Ž‘’€€‹ˆ’… ‘… Ž“‘Š€’     )
    ! DUP PUSH           (                              )
  THEN                  (                             )
 REPEAT                (                              )
 0 POP N>LINK !        ( …ƒˆ‘’ˆ€ ‘… Š€Ÿ € ‘ˆ‘šŠ€)
 THEN
 POP @ ?DUP 0= UNTIL     ( ‘‹…„‚€™ ‘ˆ‘šŠ)
 -HEAD  AT HIDDEN OFF
 ;
