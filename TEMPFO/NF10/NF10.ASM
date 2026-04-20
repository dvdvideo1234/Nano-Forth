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

__nam    macro   msg
  local endstr
  db    endstr-$-1
  db    msg
endstr  label   byte
        endm

__ln     macro   token
ppppp = $
  __nam  token
  dw    qqqqq
qqqqq = ppppp
        endm

__ALIGN  MACRO  FLAG
        IF ($-START+FLAG) AND 1
        NOP
        ENDIF
        ENDM

_ALIGN  MACRO
        __ALIGN 0
        ENDM

__entry  macro nam,ADR
        __nam  nam
        DW    ADR,0
        endm

; REGISTERS
; SI INSTRUCTION POINTER
; AX DATA STACK POINTER
; SP RETURN STACK POINTER
; CX DATA STACK TOP REGISTER
; DI WORK REGISTER

ip  = si        ; for interpretter
w   = di
dsp = ax
rsp = sp
top = cx
ar   = bx       ; address  register

;  REGISTER  ?
; DX, BP   - NOT USED
;
; MINIMAL SET INTERPRETTER COMMANDS
; CONTROL      COMMANDS  (IF (JUMP (RETURN (IF-
; RETURN STACK COMMANDS  POP PUSH 
; DATA STACK   COMMANDS  DUP J
; DATA TRANSF  COMMANDS  @R+ !R+ XCHG XR
; MATH         COMMANDS  +2/ +* -/ NAND
; IO           COMMANDS  (IO

MyCseg  segment para  use16

        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg, es: MyCseg

        org 100h

@TBUF   = -256          ; -256    TBUF = 256   
@TIB    = @TBUF * 2     ; -512    TIB  = 256  + 
@R_TOP  = @TIB          ; -512  RSTACK = 768  +
@S_TOP  = @TBUF+@TIB*2  ; -1280 DSTACK = 768  += TOTAL = 2048
@VOCTOP = @TIB * 12     ; -6144 = 4 BUFFERS * 1024 + TOTAL

Start   Label byte
  mov   bx,1000h     ; only 64k allocate
  mov   ah,4ah
  int   21h
  JMP   @ABORT
  
 _ALIGN
@__INIREG:
  POP	IP
  X
  POP	W BX CX DX
  X
  RCHG	W
  PUSH  W
  CALL	IP
  POP	W
  RCHG	W
  X
  PUSH  DX CX BX W
  PUSHF
  X
  RET

 _ALIGN
@__DEMIT:
  MOV   W,200h
@DOS1:
  X
  POP	SI
  X
@DOS:
  MOV   DX,SI
  RCHG	W
  INT   21H
  RCHG	W
  RET
  
 _ALIGN
@__ACC:
  MOV   W,0A00h
  X
  POP	CX SI
  X
  MOV   [SI],CX 
  CALL	@DOS
  X
  INC	SI
  PUSH  SI
  X
  RET  
  
; CONTROL      COMMANDS  (IF (JUMP (RETURN (IF-
 _ALIGN
@_IF:	 			; (IF
  rchg  w
  lodsw
  test 	al,1
  rchg  w
  JNE   _IO 
  JCXZ  _IF0    ; TOP = 0
  SKIPB
 _ALIGN
@_PUSH:
  TO_R	TOP
  SKIPA
_IF0:
  MOV   IP,W
_DROP:
  D_TO 	TOP
  JMPS  _MAIN

; IO           COMMANDS  (IO  vvvvvvvvvv
_IO:  
  DEC   W
  PUSH  IP BX DX BP
  X
  PUSH   TOP
  X
  CALL  W
  X
  POP	TOP
  X
  CLD
  POP  	BP DX BX
  JMPS  @_RETURN
; IO           COMMANDS  (IO  ^^^^^^^
_SKIP:
  INC   ip
  INC   ip
  JMPS  _MAIN

 _ALIGN
@_IFM:    			; (IF-
  DEC   TOP
  JS    _SKIP

 _ALIGN
@_JUMP:    			; (JUMP
  MOV   IP,[IP]
  JMPS  _MAIN

; DATA TRANSFER  COMMANDS  @R+ !R+ XCHG XA
 _ALIGN
@_RAT:				; @R+
  R_TO 	W
  TO_D  TOP
  MOV   TOP,[W]
  JMPS  _RAT

 _ALIGN
@_RTO:				; !R+
  R_TO 	W
  MOV   [W],TOP
  D_TO  TOP
  JMPS  _RAT

 _ALIGN
@_XCHG:				; XCHG
  R_TO	W
  TO_R  TOP
  MOV   TOP,W
  JMPS  _MAIN 
  
 _ALIGN
@_XA:				; XA
  R_TO	W
  TO_R 	AR
  MOV	AR,W
  JMPS  _MAIN 
  

; MAIN  LOOP
_NEST:				; (NEST
  to_r  IP
_LBL:  
  to_r  W
  
 _ALIGN
@_RETURN:			; (RET
  r_to  IP
_MAIN:
  rchg  w
  lodsw
  test 	al,1
  rchg  w
  je    _nest
  dec   w
  JMP   W
_RAT:  
  inc   W
  inc   W
  TO_R  W
  JMPS  _MAIN

;  STACK COMMANDS   PUSH DUP
 _ALIGN
@_DUP:
  JMPS  _DUP

;  STACK   COMMANDS   J POP
 _ALIGN
@_J:
  TO_D  TOP
  R_TO  W
  R_TO  TOP
  TO_R  TOP
  TO_R  W
  JMPS  _MAIN
_DUP:
  TO_R	TOP
  
 _ALIGN
@_POP:				; POP 
  TO_D  TOP
  R_TO  TOP
  JMPS  _MAIN
   
; MATH         COMMANDS  +2/ +* -/ NAND
 _ALIGN
@_MDIV:
  X
  R_TO 	W
  SHL	W,1
  RCL   TOP,1
  CMP   TOP,AR
  JB	_MDIV
  SUB   TOP,AR
  INC	W
_MDIV:  
  TO_R	W
_MDIV2:  
  X
  JMPS  _MAIN
   
 _ALIGN
@_P2DIV:
  X
  R_TO 	W
  ADD   W,TOP
  MOV	TOP,W
  RCR   TOP,1
  JMPS  _MDIV
   
 _ALIGN
@_PMUL:
  X
  R_TO 	W
  TEST	W,1
  JE    _PMUL2
  ADD   TOP,AR
_PMUL2:
  RCR   TOP,1
  RCR   W,1
  JMPS  _MDIV
   
 _ALIGN
@_NAND:
  X
  R_TO 	W
  AND   TOP,W
  NOT	TOP
  JMPS  _MDIV2
   
 _ALIGN
@ABORT:
  MOV   RSP,@R_TOP
  MOV   DSP,@S_TOP
  __ALIGN 1
  CALL  @_RETURN
  
EndMem:

lastw = ppppp

MyCseg  ends
        end  Start


;----------------  PARSE   -----------------

;  CHAR etib ltib  /  START LEN >IN
;  SI   DI   Cx       di    si  cx

  __XT  _PARS,@_PARAM3           ;= (PARS
  SUB   DI,CX
  XCHG  AX,SI

  CMP   AL,' '
  JNE   @@SKIPX
  JCXZ  @@SKIPX
  REPE  SCASB
  JE    @@SKIPX
  DEC   DI
  INC   CX
@@SKIPX:
  push  di      ;  START OF THE SOURCE
  JCXZ  @@WEX

  REPNE SCASB
  JNE   @@WEX
  DEC   DI

@@WEX:          ; END OF THE SOURCE  IN DI
  xchg  ax,di
  pop   di
  SUB   ax,di
  XCHG  AX,SI
  X
  PUSH  di      ; START OF THE SOURCE
  JMPS  @PUSH_sC+1
                        ; (>MEM
  __XT  _MPUSH,@_PARAM3 ; TOP OF DICTIONARY   IN DI
  xchg  cx,di
  ADD   SI,CX                ; AFTER NAME ADDRESS
  STD                        ; BACKWARDS
  CMPSB                      ; PREPARE FOR DIRECTION
  REP   MOVSB                ; NAME  MOVE
  inc   di
  TO_D  DI
  RET

  __XT  _MSTR,@_PARAM3        ; (S!
  xchg  cx,di
  to_r  di
  MOV   [DI],CL
  INC   DI
  REP   MOVSB   ; NAME  MOVE
  MOV   PB [DI],'`'
  r_to  cx
@push_DC:
  DUP2  DI,CX
  RET

