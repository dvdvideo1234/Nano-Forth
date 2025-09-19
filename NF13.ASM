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
LOCAL ADR,COD
  ALGN 0
@&LBL:
ADR = $
COD = (ADR - START + 100H) / 2
  ORG COD
P_&LBL:  
  ORG ADR
  ENDM
        
CNST MACRO LBL,DAT
  L LBL
  DW _CON
@_&LBL DW DAT 
  ENDM
        
L  MACRO LBL
LOCAL ADR,COD
  ALGN 0
?_&LBL:       ; BODY OF LABEL
ADR = $
COD = ((ADR - START + 100H) / 2) + 8000H
  ORG COD
_&LBL:  
  ORG ADR
  ENDM

entry  macro nam,ADR
  AnamE  nam
  DW    ADR,0
  endm

i@p2 MACRO
  RCHG W
    LODSW
    SHL AX,1
  RCHG W
ENDM

BUMP MACRO 
  scasw
ENDM

; REGISTER  ASIGNMENTS for interpretter
;-------------------------------------------
ip  = si    ; INSTRUCTION POINTER
tr   = BX   ; task  register
dsp = ax    ; DATA STACK POINTER
rsp = sp    ; RETURN STACK POINTER
top = cx    ; DATA STACK TOP REGISTER
NXT = DX    ; DATA STACK NEXT REGISTER
NXTLO = DL    ; DATA STACK NEXT REGISTER
AR  = bP    ; ARITHMETIC/ADDRESS  register
w 	= DI		; RETURN STACK TOP register

;
; MINIMAL SET INTERPRETTER COMMANDS
;--------------------------------------------
; CONTROL      COMMANDS  (IF (JUMP (RETURN (IF-
; RETURN STACK COMMANDS  POP PUSH 
; DATA STACK   COMMANDS  DUP J
; DATA TRANSF  COMMANDS  @R+ !R+ XCHG XR
; MATH         COMMANDS  +2/ +* -/ NAND
; IO           COMMANDS  (IO

MyCseg  segment para  use16

        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg, es: MyCseg

        org 100h

@TBUF  = -256      	; -256    TBUF = 256   
@TIB   = @TBUF * 2    ; -512    TIB  = 256  + 
@R_TOP  = @TIB         ; -512  RSTACK = 768  +
@S_TOP  = @TBUF+@TIB*2; -1280 DSTACK = 768  += TOTAL = 2048
@VOCTOP= @TIB * 12    ; -6144 = 4 BUFFERS * 1024 + TOTAL

Start   Label WORD
      mov   bx,1000h     ; only 64k allocate
      mov   ah,4ah
      int   21h
      mov   ax,500h
      int   10h
  P ABORT 
      MOV   RSP,@R_TOP
      MOV   DSP,@S_TOP
      CALL  @RET
      DW  0   ; START ADR

  L LIT
      DW	P_RAT,P_RET
  L FETCH
      DW P_RAT
  L AT				; @
      DW	P_PUSH
  L CON       ; CONS
      DW	P_RAT
  L EXIT
      DW	P_POP
  L DROP      ; DROP
      DW	P_IF,?_NOP
  L NOP
      DW	P_RET 

  L 0EX
      DW	P_IF,?_EXIT,P_RET 
  L FIX
      DW P_RAT
  L STORE
      DW P_RAT
  L TO				; !
      DW	P_PUSH
  L TOV
      DW	P_RTO,P_JUMP,?_EXIT

  L SETV
      DW	P_RAT,P_IF,?_SET
  L SET DW P_RTO,_EXIT 

  CNST AX,0
  CNST BX,0
  CNST CX,0
  CNST DX,0
  CNST FL,0
  
; IO           COMMANDS  (IO  vvvvvvvvvv

L DOS
  DW P_IO
  INT   21H
  RET
  
L VID
  DW P_IO
  INT	10H  
  RET  
  
L KBD
  DW P_IO
  INT	16H  
  RET  
  
P PAR2DOS   ; PREPARE FOR 2PAR DOS FUNC
  X 
  PUSH NXT
  XOR NXT,NXT
  PUSH NXT
  X 
  JMPS @MAIN

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
  POP	  @_FL
  MOV	  @_DX,DX
  MOV	  @_CX,CX
  MOV	  @_BX,BX
  MOV	  @_AX,AX
  mov   AX,Rsp
  mov   RSP,AR
  POP   AR TR
  CLD
P 2DROPX
  DROP2  TOP NXT

; CONTROL      COMMANDS  (IF (JUMP (RETURN (IF-
P RET				; (RET
  POP	IP
  JMPS   @MAIN
  
P IF	 			; (IF
  mov   W,TOP
  CALL @DROP
  OR    W,W
  mov   W,0
  ORG $-2
P ZIF
  OR  TOP,TOP
  JZ	@JUMP   ; TOP = 0

P SKIP
  INC   IP
  INC   IP
  JMPS   @MAIN

P IFM    			; (IF-
    JMPS @IFM_
P NEXT
    POP W
    DEC W
    PUSH W
    MOV W,0
    ORG $-2
P MIF    			; (-IF
  INC   TOP
@IFM_:    			
  DEC   TOP
  JS    @SKIP

P JUMP    			; (JUMP
  MOV   IP,[IP]
  JMPS   @MAIN

; DATA TRANSFER  COMMANDS  @R+ !R+ XCHG XA
P RAT				; @R+
  CALL  @DUP
  POP W
  MOV   TOP,[W]
  BUMP ;RT
  PUSH W
  JMPS   @MAIN
    
P RTO				; !R+
  POP W
  MOV   [W],TOP
  BUMP ;RT
  PUSH W
@DROP:
  CALL @DROP_
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
  POP W
@NEST:				; (NEST
  PUSH	IP
  MOV	IP,W
 
@MAIN:
  I@P2
  jC	@nest
  JMP W

;  STACK COMMANDS   PUSH DUP

;  STACK   COMMANDS   J POP
P RDROP
  POP W
  JMPS   @MAIN

P J
  CALL  @DUP_
  POP	  W TOP
  PUSH	TOP W
  JMPS   @MAIN
  
P FOR 
  MOV   IP,[IP]
P PUSH
  PUSH	TOP
  JMPS   @DROP  

P OVER 
  PUSH NXT
  SKIPB
P DUP
  PUSH TOP
P POP				; POP
  CALL  @DUP_
  POP	  TOP
  JMPS @MAIN
   
; MATH         COMMANDS  +2/ +* -/ NAND
P MDIV
  SHL	NXT,1
  RCL   TOP,1
  CMP   TOP,AR
  JB	@MDIV_
  SUB   TOP,AR
P U1P
  INC	NXT
@MDIV_: 
  JMPS @MAIN
   
P P2DIV
  ADD   NXT,TOP
  MOV	TOP,NXT
P DIV2
  RCR   TOP,1
  JMPS @MAIN
   
P PMUL
  TEST	NXTLO,1
  JE    @LDIV2
  ADD   TOP,AR
P LDIV2
  RCR   TOP,1
  RCR   NXT,1
  JMPS @MAIN
   
P NAND
  AND   TOP,NXT
  D_TO  NXT     ; NIP
P NOT
  DEC   TOP
P NEG
  NEG   TOP
  JMPS @MAIN
  
@DUP_:
  X
  PUSH	NXT
  X
  MOV	NXT,TOP
  RET
  
@PREDR_:
  mov   W,TOP
@DROP_:
  MOV	  TOP,NXT
  D_TO  NXT
  RET


@_START:

lastw = ppppp

MyCseg  ends
        end  Start


