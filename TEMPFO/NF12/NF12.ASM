locals  @@

pd  equ dword ptr
pw  equ word  ptr
pb  equ byte  ptr

TO_     =  -2
AT_     =  -4
VL_     =  2

AnamE    macro   msg
  local endstr
  db    endstr-$-1
  db    msg
endstr  label   byte
        endm

qqqqq = 0
ppppp = qqqqq

lnKNAM     macro   token
ppppp = $
  AnamE  token
  dw    qqqqq
qqqqq = ppppp
        endm

JMPS    MACRO LBL
          jmp  SHORT LBL
        ENDM

SKIPA   MACRO
        DB    03DH
        ENDM

SKIPB   MACRO
        DB    03CH
        ENDM

SKIPr   MACRO reg
        mov   reg,0
        org   $-2
        ENDM


X       MACRO
  xchg Rsp,DSP
        ENDM

TO_R    MACRO  REG
  PUSH   REG
        ENDM

R_TO    MACRO  REG
  POP    REG
        ENDM

TO_D    MACRO  REG
  X
  PUSH   REG
  X
        ENDM

D_TO    MACRO  REG
  X
  POP    REG
  X
        ENDM

cf_to   macro  reg
  sbb   reg,reg
        endm

rchg    macro   reg
  xchg  ax,reg
        endm

DUPTOP  MACRO 
  X
  PUSH  NXT
  X
  mov   NXT,TOP
  ENDM

DROPTOP   MACRO   
  mov   TOP,NXT
  X
  POP   NXT
  X
  ENDM

DUP2    MACRO   R1,R2
  X
  PUSH  R1
  PUSH  R2
  X
        ENDM

DROP2   MACRO   R1,R2
  X
  POP   R1
  POP   R2
  X
        ENDM

ALGN  MACRO  FLAG
  IF ($-START+FLAG) AND 1
  NOP
  ENDIF
  ENDM

P MACRO LBL
  ALGN 0
@&LBL:
  local ADR,NEW
  ALGN 0
ADR = $
NEW = ((ADR - ZED)/2) 
  ORG NEW
_&LBL:
  ORG ADR
  ENDM
        
CNST MACRO LBL,DAT
  L LBL
  DW CON_
@&LBL DW DAT 
  ENDM
        
L  MACRO LBL
  local ADR,NEW
  ALGN 0
ADR = $
NEW = ((ADR - ZED)/2) + 08000H
  ORG NEW
LBL&_:
  ORG ADR
  ENDM

entry  macro nam,ADR
  AnamE  nam
  DW    ADR,0
  endm

i@p2 MACRO
  RCHG W
    LODSW
    TEST AL,1
  RCHG W
ENDM

BUMP MACRO 
  scasw
ENDM

; REGISTER  ASIGNMENTS for interpretter
;-------------------------------------------
ip  = Di    ; INSTRUCTION POINTER
TR  = BP    ; TASK REGISTER
dsp = ax    ; DATA STACK POINTER
rsp = sp    ; RETURN STACK POINTER
top = cx    ; DATA STACK TOP REGISTER
topL= cL    ; DATA STACK TOP REGISTER LO
AR  = SI    ; ARITHMETIC/ADDRESS  register
w 	= BX		; WORK register
WL  = BL    ; WORK register LO
WH  = BH    ; WORK register HI
NXT = DX    ; DATA STACK NEXT REGISTER
NXTL= DL    ; DATA STACK NEXT REGISTER

;
; MINIMAL SET INTERPRETTER COMMANDS
;--------------------------------------------
; CONTROL      COMMANDS  (IF (JUMP (RETURN (IF-
; RETURN STACK COMMANDS  POP PUSH 
; DATA STACK   COMMANDS  DUP J
; DATA TRANSF  COMMANDS  @R+ !R+ XA XR
; MATH         COMMANDS  +2/ +* -/ 
; IO           COMMANDS  (IO

; 0; RDROP RDROP; 2DROP; NOT NEG AND NIP DROP
; 0-ROT2 C!R+ C@R+ PAR TWICE 2/ D2/ U1+ DROP;
; ?.SKIP

MyCseg  segment para  use16

        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg, es: MyCseg

@TBUF  = -256      	; -256    TBUF = 256   
@TIB   = @TBUF * 2    ; -512    TIB  = 256  + 
@R_TOP  = @TIB         ; -512  RSTACK = 768  +
@S_TOP  = @TBUF+@TIB*2; -1280 DSTACK = 768  += TOTAL = 2048
@VOCTOP= @TIB * 12    ; -6144 = 4 BUFFERS * 1024 + TOTAL

        org 100h

Start   Label byte
ZED   = START - 100H

      mov   bx,1000h     ; only 64k allocate
      mov   ah,4ah
      int   21h
      mov   ax,500h
      int   10h
  P ABORT 
      MOV   RSP,@R_TOP
      MOV   DSP,@S_TOP
      ALGN  1             ; !!!
      CALL  @RET
      DW  0   ; START ADR

  L LIT
      DW	_RAT,_RET
  L FETCH@
      DW _RAT
  L DEEK				; @
      DW	_PUSH
  L CON       ; CONS
      DW	_RAT,_RDROPX

  L FIX
      DW _RAT
  L STORE
      DW _RAT
  L DOKE				; !
      DW	_PUSH
  L TOV
      DW	_RTO,_RDROPX


  L SETV
    DW	_SKIP
  L SET DW P_RTO,_RDROPX 

  CNST AX,0
  CNST BX,0
  CNST CX,0
  CNST DX,0
  CNST FL,0
  
; IO           COMMANDS  (IO  vvvvvvvvvv

L DOS
  DW  _IO
  INT   21H
  RET
  
L VID
  DW  _IO
  INT	10H  
  RET  
  
L KBD
  DW  _IO
  INT	16H  
  RET  
  
P 0MROT2    ; PREPARE FOR 2PAR DOS FUNC
  X         ; = 0 -ROT 0 -ROT
  PUSH NXT
  XOR NXT,NXT
  PUSH NXT
  X 
  JMP @MAIN

P IO
  PUSH  TR AR
  MOV   AR,RSP
  X
  PUSH  NXT 
  rchg  top   
  POP   BX CX DX
  PUSH  DS ES AR
  CALL  IP
  POP	  AR ES DS
  PUSHF
  POP	  @FL
  MOV	  @DX,DX
  MOV	  @CX,CX
  MOV	  @BX,BX
  MOV	  @AX,AX
  mov   AX,Rsp
  mov   RSP,AR
  POP   AR TR
P 2DROPX
  CLD
  DROP2 TOP NXT
  SKIPB
P RDROPX
  POP   W
  POP	  IP
  JMPS  @MAIN

P zSKIP
	jCXZ  @DRskip   ; CX = TOP
  JMPS  @MAIN
P DRskip		
  BUMP  ip
  SKIPA
P 0EX
  JCXZ  @DROPX
  JMPS  @DROP

P IF	 			; (IF
  OR   TOP,TOP
  DROPTOP
  SKIPR  W
P ZIF
  OR  TOP,TOP
  JZ	@JUMP   ; TOP = 0

P SKIP
  INC   IP
  INC   IP
  JMPS   @MAIN

P NEXT
    POP W
  OR  W,W
  JE  @SKIP
    DEC W
    PUSH W
  JMPS @JUMP

@MIFZ:    			; (-IF
  INC   TOP
P IFM    			
  DEC   TOP
  JS    @SKIP

P JUMP    			; (JUMP
  MOV   IP,[IP]
  JMPS   @MAIN

P MIF    			; (IF-
    JMPS @MIFZ


; DATA TRANSFER  COMMANDS  @R+ !R+ XA XR

P CRTO				; C!R+
  POP   W
  MOV   [W],TOPL
  JMPS   @RTO1  
  
P RTO				; !R+
  POP   W
  MOV   [W],TOP
  INC   W
@RTO1:
  INC   W
  PUSH  W
  JMPS   @DROP  
  
P PUSH
  JMPS  @DO_PUSH

P DROPX
  POP   ip
  SKIPA
P FOR 
  DEC   TOP       ; PREDECREMENT ON START OF THE CYCLE
@DO_PUSH:
  PUSH	TOP
P DROP
  mov   TOP,NXT
P NIP
  X
  POP   NXT
  X
  JMPS   @MAIN

P XR				; XR
  POP   W
  PUSH	TOP
  XCHG	TOP,W
  JMPS   @MAIN
  
P XA				; XA
  POP   W
  PUSH	AR
  XCHG	AR,W
  JMPS   @MAIN

; MAIN  LOOP
P EX
  POP   W
P NEST				; (NEST
  PUSH	IP
  PUSH	W
P RET 
  POP   IP

@MAIN:
  mov W,[IP]
  ADD IP,2
  SHL W,1
  jC	@nest
  JMP W

;  STACK COMMANDS   PUSH DUP

; MATH         COMMANDS  +2/ +* -/ NAND
P SDIV
  SHL	  NXT,1
  RCL   TOP,1
  CMP   TOP,AR
    JB	@MDIV_
  SUB   TOP,AR
P U1P
  INC	  NXT
@MDIV_: 
  JMPS @MAIN
   
P P2DIV
  ADD   NXT,TOP
  MOV	  TOP,NXT
P DIV2
  RCR   TOP,1
  JMPS @MAIN
   
P PMUL
  TEST	NXTL,1
  JE    @LDIV2
  ADD   TOP,AR
P LDIV2
  RCR   TOP,1
  RCR   NXT,1
  JMPS @MAIN
   
P AND
  AND   TOP,NXT
  JMPS  @NIP

P XOR
  XOR   TOP,NXT
  JMPS  @NIP

P ABS
  OR    TOP,TOP
  JNS   @POSITIVE
P NEG
  DEC   TOP
P NOT
  NOT   TOP
@POSITIVE:
  JMPS @MAIN
  
;  STACK   COMMANDS   J POP

P TWICE
  PUSH  ip
  SKIPB
P RDROP
  POP W
  JMPS   @MAIN

P J
  MOV	  W,RSP
  mov   W,[W+2]
  JMPS   @PUSHW
  
P RAT				; @R+
  POP   W
  ADD   W,2
  PUSH  W
  MOV   W,[W-2]
  JMPS   @PUSHW

P CRAT				; C@R+
  POP   W
  INC   W
  PUSH  W
  MOV   WL,[W-1]
@PUSHWL:
  mov   WH,0
  JMP   @PUSHW

P OVER 
  TO_D  NXT
P SWAP
  xchg  NXT,TOP
  JMPS   @MAIN

P DUP
  MOV   W,TOP
  JMPS   @PUSHW

P POP				; POP
  POP	  W
@PUSHW:
  DUPTOP
  MOV   TOP,W
  JMPS   @MAIN
    
   
;@DUP_:
;  X
;  PUSH	NXT
;  X
;  MOV	NXT,TOP
;  RET
;  
;@PREDR_:
;  mov   W,TOP
;@DROP_:
;  MOV	  TOP,NXT
;  D_TO  NXT
;  RET
;

@_START:

lastw = ppppp

MyCseg  ends
        end  Start


