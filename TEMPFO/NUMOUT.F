(  SPACES <# #> # #S D# D.R D. .R . U. ( FLOAD TEMP.TX)
(  : .ROT ROT DUP H. ;  : RT CR .ROT .ROT .ROT ;)
: ;BASE BASE XCHG PUSH TO BASE EX POP TO BASE ;
: ;<#> 0 -ROT EX 2DROP ; : D0= 2DUP OR 0= ;
: ;SIGN IF DABS EX C" - SWAP 1+ THEN ; : ;SPC EX SPACE ;
: M/MOD TUCK U/MOD PUSH  SWAP UM/MOD POP ;
: ;N. EX FOR EMIT NEXT ;
: 1#  BASE M/MOD PUSH PUSH ALPHA SWAP 1+ POP POP ;
: S# BEGIN 1# D0= UNTIL ; : UD# ;<#> S# ; : D# ;SIGN UD# ;
: D.R ;N. PUSH D# POP OVER - SPACES ;  : UD. ;SPC ;N. UD# ;
: D. ;SPC S>D 0 D.R ; : . S>D D. ;
: UD.R 0 SWAP D.R ;
: U.R  0 SWAP UD.R ;
: .. 10 ;BASE 6 U.R ;
: .R PUSH S>D S>D POP D.R ;
: HD. ;SPC 1H ;BASE ;N. ;<#> 1# S# ;
: .H 0 HD. ;
