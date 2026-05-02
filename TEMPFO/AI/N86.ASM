;======================================================================
; n86_1.asm  --  Nano-Forth VM for 8086
;
; 16 primitives, 16-bit cells, .COM file model (ORG 100H).
;
; Register assignments:
;   SP  = data stack pointer (grows toward lower addresses;
;   SI  = IP  (instruction pointer)
;   BP  = return stack pointer (grows toward lower addresses;
;         [BP] = return TOS)
;   di  = AREG
;   AX, BX, CX, DX, = scratch 
;
; Memory:
;   AREG   DW -- 16-bit accumulator register A
;   NIBTMP DW -- holds cell-1 during 4-nibble dispatch
;
; Stack conventions:
;   Data:   SI decrements by 2 on push (_DUP); LODSW on pop (_DROP)
;   Return: BP decrements by 2 on push; BP increments by 2 on pop
;
; Primitive encoding:
;   Even cell -> CALL:  push IP to return stack, set IP = cell
;   Odd cell  -> 4 nibbles packed in cell-1:
;                  nibble 3 = bits 15:12 (first to execute)
;                  nibble 2 = bits 11:8
;                  nibble 1 = bits  7:4
;                  nibble 0 = bits  3:0  (last to execute)
;
;======================================================================

locals @@
pw  equ  word ptr
pb  equ  byte ptr

;----------------------------------------------------------------------
; Macros
;----------------------------------------------------------------------

X   MACRO
  XCHG SP,BP
ENDM

RPUSH    MACRO  REG                 ; push REG onto RETURN stack
  X
  push  REG
  X
ENDM

RPOP   MACRO   REG                ; pop RETURN stack into REG
  X
  POP  REG
  X
ENDM

ALIG1 MACRO
  IF ($-@_START+1) AND 1
    NOP
  ENDIF
ENDM

_NANO_ MACRO
  ALIG1
  CALL  _NANO
ENDM

AREG = di

;----------------------------------------------------------------------
; Segment  (COM model: CS=DS=SS, ORG 100H)
;----------------------------------------------------------------------

MyCseg  segment  para use16
        assume   cs:MyCseg, ds:MyCseg, ss:MyCseg

        ORG  100H

;----------------------------------------------------------------------
; Entry point -- jump over table so the table bytes are not executed
;----------------------------------------------------------------------
@_START:
        JMP  @_NANO_INIT
_NANO:
  pop   SI
  JMP SHORT @MAIN

;----------------------------------------------------------------------
; Dispatch table T_NANO -- 16 word entries
;
; Nibble N maps to:  DI = N*2 + OFFSET T_NANO
;                    CALL word ptr [DI]
;----------------------------------------------------------------------

align 2

@_NANO  label  word
  DW    N_JMP              ;  0   JMP   (EFECTIVE NOP/NOPS)
  DW    N_P2DIV            ;  1   +2/   (EFECTIVE SUM & AVERIGE)
  DW    N_XOR              ;  2   XOR
  DW    N_NAND             ;  3   NAND
  DW    N_IF               ;  4   IF    (EFECTIVE DROP)
  DW    N_J                ;  5   J
  DW    N_DUP              ;  6   DUP
  DW    N_POP              ;  7   POP
  DW    N_IFM              ;  8   IF-   (EFECTIVE 1-)
  DW    N_RSTORE           ;  9   !R+
  DW    N_PUSH             ; 10   PUSH       
  DW    N_RFETCH           ; 11   @R+        
  DW    N_RET              ; 12   ;          
  DW    N_XR               ; 13   XR         
  DW    N_XA               ; 14   XA
  DW    N_ESC              ; 15   4TH>
  
;-------------------------------------------------------------
;     INSTRUCTION MATRIX
;
;           JMP     +2/     XOR     NAND   
;           IF      J       DUP     POP    
;           ;       !R+     PUSH    @R+    
;           IF-     XR      XA      4TH>   
;
;----------------------------------------------------------------------
; Data
;----------------------------------------------------------------------
@_NIBTMP  DW  0                   ; cell-1 copy for @_NIBble extraction
@_NIBI    DW  0
@_NIB0    DB  0
@_NIB1    DB  0
@_NIB2    DB  0
@_NIB3    DB  0

;----------------------------------------------------------------------
; Inner interpreter  @MAIN
;
; Fetches one 16-bit cell from [BX], advances BX by 2, then either:
;   even cell -> CALL (push BX to return stack, jump to cell)
;   odd  cell -> extract and dispatch 4 nibbles
;
; Nibble extraction uses 8086-legal SHR reg,1 (no SHR reg,imm).
; CX is reloaded from NIBTMP before each nibble level.
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; ESCAPE FORM NANO VM TO REAL MASHINE
;----------------------------------------------------------------------
N_ESC:
  JMP   SI

;----------------------------------------------------------------------

;======================================================================
; Primitives  -- each ends WITH  JMP TO @MAIN
;======================================================================

;----------------------------------------------------------------------
; if-  ( n -- n' )  decrement TOS; if >= 0: IP += OFFSET
;----------------------------------------------------------------------
N_IFM:
  pop   AX
  DEC   AX
  push  AX
  JS    @MAIN

;----------------------------------------------------------------------
; jmp  unconditional jump  IP += OFFSET
;----------------------------------------------------------------------
N_JMP:
  MOV   CX,@_NIBI
  JCXZ  @MAIN
  MOV   AX,@_NIBTMP
  DEC   CX
  XOR   cl,3
  SHL   CX,1
  SHL   CX,1
  SHL   AX,CL
  SAR   AX,CL
  ADD  SI,AX
  JMP SHORT  @MAIN

;----------------------------------------------------------------------
; if  ( n -- )  pop TOS; if zero: IP += OFFSET
;----------------------------------------------------------------------
N_IF:
  pop   CX
  JCXZ  N_JMP
  JMP  SHORT   @MAIN

;----------------------------------------------------------------------
;  ;  pop return TOS -> IP
;----------------------------------------------------------------------
N_RET:
  RPOP  SI
  JMP  SHORT   @MAIN

  ; --- even cell: CALL ---

@_NEST:
  XCHG  AX,SI
  RPUSH AX
@MAIN:
  LODSW     ;; fetch cell  ; IP += 2
  TEST AL,1               ; bit 0 set? -> odd -> nibble cell
  JE  @_NEST

  ; --- odd cell: 4 nibbles ---
  DEC  AX                 ; clear bit 0; DX = packed nibbles
  MOV  @_NIBTMP,AX

  and  AX,0F0FH
  SHL  ax,1
  MOV  @_NIB0,AL
  MOV  @_NIB2,AH
  MOV  CX,3
  MOV  @_NIBI,CX
  MOV  AX,@_NIBTMP
  and  AX,0F0F0H
  SHR  AX,CL
  MOV  @_NIB1,AL
  MOV  @_NIB3,AH

@_NIBDISPATCH:
  MOV  BX,@_NIBI
  MOV  BL,@_NIB0[BX]             ; NIB0+NIBI = nibble[NIBI] * 2
  JMP  @_NANO[BX]

;======================================================================
; Primitives  -- each ends WITH  JMP TO NIBDONE
;======================================================================

;----------------------------------------------------------------------
;  +2/  ( nxt top -- sum sum>>1 )
;
; After: TOS = sum>>1, 2nd = sum.
;----------------------------------------------------------------------
N_P2DIV:
  pop   CX AX
  add   AX,CX
  MOV   CX,AX
  RCR   AX,1
@PHCX:
  push  CX
@PHAX:
  push  AX

@_NIBDONE:
  DEC   @_NIBI
  JNS   @_NIBDISPATCH
  JMP  @MAIN               ; all 4 done

;----------------------------------------------------------------------
; NAND  ( a b -- ~(a AND b) )
;----------------------------------------------------------------------
N_NAND:
  pop   AX CX
  and   AX,CX
  NOT  AX
  JMP   @PHAX

;----------------------------------------------------------------------
; XOR  ( a b -- ~(a XOR b) )
;----------------------------------------------------------------------
N_XOR:
  pop   AX CX
  XOR   AX,CX
  JMP   @PHAX

;----------------------------------------------------------------------
;  PUSH  ( n -- )  data TOS -> return stack
;----------------------------------------------------------------------
N_PUSH:
  pop   AX
  Rpush  AX
  JMP   @_NIBDONE

;----------------------------------------------------------------------
;  POP  ( -- n )  return TOS -> data stack
;----------------------------------------------------------------------
N_POP:
  Rpop  AX
  JMP   @PHAX

;----------------------------------------------------------------------
;  DUP  ( n -- n n )
;----------------------------------------------------------------------
N_DUP:
  pop   AX
  push  AX
  JMP   @PHAX

;----------------------------------------------------------------------
;  J  ( -- n )  push 2nd return stack element to data stack
;----------------------------------------------------------------------
N_J:
  PUSH  [BP+2]          ; 2nd return stack element
  JMP   @_NIBDONE

;----------------------------------------------------------------------
;  @R+  ( -- n )  fetch word at [RSP TOS]; RSP TOS += 2
;----------------------------------------------------------------------
N_RFETCH:
  XCHG  SI,[BP]
  LODSW
  XCHG  SI,[BP]
  JMP   @PHAX

;----------------------------------------------------------------------
;  !R+  ( n -- )  store TOS to [RSP TOS]; RSP TOS += 2
;----------------------------------------------------------------------
N_RSTORE:
  pop   AX
  XCHG  AREG,[BP]
  STOSW

;----------------------------------------------------------------------
;  XA  swap return TOS <-> AREG
;----------------------------------------------------------------------
N_XA:
  XCHG  AREG,[BP]
  JMP   @_NIBDONE


;----------------------------------------------------------------------
;  XR  ( n -- m )  swap data TOS <-> return TOS
;----------------------------------------------------------------------
N_XR:
  pop   AX
  XCHG  AX,[BP]
  JMP   @PHAX

;======================================================================
; Startup
;======================================================================

;----------------------------------------------------------------------
; @_NANO_INIT -- initialise registers and jump to test thread
;----------------------------------------------------------------------
@_NANO_INIT:
        CLD
        XOR  AREG,AREG
        MOV  SP,0FFFEh          ; data stack base (top of segment)
        MOV  BP,0EFFEh          ; return stack base

;======================================================================
; Test thread
;
; Encoding: cell must be odd (bit 0 = 1); cell-1 holds 4 nibbles.
;
;   cell   = $6C01
;======================================================================

  _NANO_
  DW    6C01H               ; nibble3=DUP(6), nibble2 =;(12) 

MyCseg  ends
        end  @_START
