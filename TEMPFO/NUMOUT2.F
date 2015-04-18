(  SPACES <# #> # #S D# D.R D. .R . U.)
( FLOAD TEMP.TX)

  VARIABLE NUM2 Z,   ( 2VARIABLE)
: <# NUM2 2! 0 ;
: #> FOR EMIT NEXT ;
: HOLD SWAP 1+ ;
  : ;SIGN IF DABS EX C" - HOLD THEN ;
  : M/MOD TUCK U/MOD PUSH  SWAP UM/MOD POP ;
  : 1# NUM2 2@ BASE M/MOD NUM2 2! ALPHA HOLD  ;
  : S# BEGIN 1# NUM2 2@ OR 0= UNTIL ;
  : <D# ;SIGN <# S# ;
  : D.R PUSH <D# POP OVER - SPACES #> ;
: D. S>D 0 D.R SPACE ;
: . S>D D. ;
: .R PUSH S>D S>D POP D.R ;
: U.R  0 0 ROT D.R ;
: UD. <# 1# S# #> SPACE ;
: UD.R 0 SWAP D.R ;
: .DH BASE PUSH HEX UD. POP TO BASE ;
  : .. BASE PUSH DECIMAL 6 U.R POP TO BASE ;
( : .. [TO] # 6 U.R ;)
: .H 0 .DH ;

