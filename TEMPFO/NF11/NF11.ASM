locals  @@

pd  equ dword ptr
pw  equ word  ptr
pb  equ byte  ptr

TO_     =  -2
AT_     =  -4
VL_     =  2

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

w2      macro
  scasw
        endm

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

qqqqq = 0
ppppp = qqqqq

AnamE    macro   msg
  local endstr
  db    endstr-$-1
  db    msg
endstr  label   byte
        endm

lnKNAM     macro   token
ppppp = $
  AnamE  token
  dw    qqqqq
qqqqq = ppppp
        endm

ALGN  MACRO  FLAG
  IF ($-START+FLAG) AND 1
  NOP
  ENDIF
  ENDM

P MACRO LBL
  ALGN 0
@&LBL:
  NOP
P_&LBL:
  ORG $-1
  ENDM
        
CNST MACRO LBL,DAT
  L LBL
  DW _CON
@_&LBL DW DAT 
  ENDM
        
L  MACRO LBL
  ALGN 0
_&LBL:  
  ENDM

entry  macro nam,ADR
  AnamE  nam
  DW    ADR,0
  endm

GETW MACRO
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
ip  = si    ; INSTRUCTION POINTER
W   = BX    ; WORK  register
dsp = ax    ; DATA STACK POINTER
rsp = sp    ; RETURN STACK POINTER
top = cx    ; DATA STACK TOP REGISTER
NXT = DX    ; DATA STACK NEXT REGISTER
NXTLO = DL    ; DATA STACK NEXT REGISTER
AR  = bP    ; ARITHMETIC/ADDRESS  register
RT	= DI		; RETURN STACK TOP register

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
@RTOP  = @TIB         ; -512  RSTACK = 768  +
@STOP  = @TBUF+@TIB*2; -1280 DSTACK = 768  += TOTAL = 2048
@VOCTOP= @TIB * 12    ; -6144 = 4 BUFFERS * 1024 + TOTAL

Start   Label byte
  mov   bx,1000h     ; only 64k allocate
  mov   ah,4ah
  int   21h
@ABRT:
  MOV   RSP,@RTOP
  MOV   DSP,@STOP
  CALL  @RETURN
  DW  0   ; START ADR

  P ABORT 
    JMPS @ABRT

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
      DW	P_IF,_NOP
  L NOP
      DW	P_RET 

  L FIX
      DW P_RAT
  L STORE
      DW P_RAT
  L TO				; !
      DW	P_PUSH
  L TOV
      DW	P_RTO,P_JUMP,_EXIT

  L SETV
      DW	P_RAT,P_IF,_SET
  L SET DW P_RTO,_EXIT 

  CNST AX,0
  CNST BX,0
  CNST CX,0
  CNST DX,0
  CNST FL,0
  
; IO           COMMANDS  (IO  vvvvvvvvvv
P IO
  PUSH  RT AR
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
  POP   AR RT
  CLD
P 2DROPX
  DROP2  TOP NXT
P RET				; (RET
  POP	    W
  MOV	    IP,RT
  POP	    RT
  JMP     W

L DOSZ
  DW P_IO
  INT   21H
  RET
  
L VIDZ
  DW P_IO
  INT	10H  
  RET  
  
L KBDZ
  DW P_IO
  INT	16H  
  RET  
  
; CONTROL      COMMANDS  (IF (JUMP (RETURN (IF-
P IF	 			; (IF
  MOV W,OFFSET @DROP
  TO_R W
P ZIF
  JCXZ	@JUMP   ; TOP = 0

P SKIP
  GETW
  RET

P IFM    			; (IF-
  DEC   TOP
  JS    @SKIP

P JUMP    			; (JUMP
  MOV   IP,[IP]
  RET

; DATA TRANSFER  COMMANDS  @R+ !R+ XCHG XA
P RAT				; @R+
  CALL  @DUP
  MOV   TOP,[RT]
  BUMP ;RT
  RET
    
P RTO				; !R+
  MOV   [RT],TOP
  BUMP ;RT
P DROP  
  MOV	  TOP,NXT
P NIP  
  D_TO  NXT
  RET
  
P XR				; XR
  XCHG	TOP,RT
  RET  
  
P XA				; XA
  XCHG	AR,RT
  RET  


; MAIN  LOOP
@NEST:				; (NEST
  PUSH	RT
  MOV	RT,IP
  MOV	IP,W
  
@MAIN:
  GETW
  jE	@nest
  DEC	W
  CALL  W
  JMP   @MAIN

;  STACK COMMANDS   PUSH DUP
P DUP
  X
  PUSH	NXT
  X
  MOV	NXT,TOP
  RET
  
@RETURN:  
  POP	IP
  JMP   @MAIN
  
;  STACK   COMMANDS   J POP
P J
  CALL  @DUP
  POP	  W
  POP	  TOP
  PUSH	TOP
  JMP   @MAIN
  
P PUSH
  POP	  W
  PUSH	RT
  PUSH  W
  MOV	  RT,TOP
  JMP   @DROP  

P POP				; POP
  CALL  @DUP
  MOV	TOP,RT
P RDROP
  POP	  W
  POP	RT
  JMP	  W
   
; MATH         COMMANDS  +2/ +* -/ NAND
P MDIV
  SHL	NXT,1
  RCL   TOP,1
  CMP   TOP,AR
  JB	@@MDIV
  SUB   TOP,AR
  INC	NXT
@@MDIV: 
  RET 
   
P P2DIV
  ADD   NXT,TOP
  MOV	TOP,NXT
P DIV2
  RCR   TOP,1
  RET
   
P PMUL
  TEST	NXTLO,1
  JE    @LDIV2
  ADD   TOP,AR
P LDIV2
  RCR   TOP,1
  RCR   NXT,1
  RET
   
P NAND
  AND   TOP,NXT
  NOT   TOP
  JMPS  @NIP
  
@_START:

lastw = ppppp

MyCseg  ends
        end  Start


