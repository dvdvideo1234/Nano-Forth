;======================================================================
; n8086_1.asm  --  Nano-Forth VM for 8086
;
; 16 primitives, 16-bit cells, .COM file model (ORG 100H).
;
; Register assignments:
;   SP  = data stack pointer (grows toward lower addresses;
;   SI  = IP  (instruction pointer)
;   BP  = return stack pointer (grows toward lower addresses;
;         [BP] = return TOS)
;   AX, BX, CX, DX, DI  = scratch 
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

;----------------------------------------------------------------------
; Segment  (COM model: CS=DS=SS, ORG 100H)
;----------------------------------------------------------------------

MyCseg  segment  para use16
        assume   cs:MyCseg, ds:MyCseg, ss:MyCseg

        ORG  100H

;----------------------------------------------------------------------
; Entry point -- jump over table so the table bytes are not executed
;----------------------------------------------------------------------
Start:
        JMP  NANO_INIT

;----------------------------------------------------------------------
; Dispatch table T_NANO -- 16 word entries
;
; Nibble N maps to:  DI = N*2 + OFFSET T_NANO
;                    CALL word ptr [DI]
;----------------------------------------------------------------------
T_NANO  label  word
        DW    N_JMP              ;  0   jmp
        DW    N_P2DIV            ;  1   +2/
        DW    N_DUP              ;  2   DUP
        DW    N_J                ;  3   J
        DW    N_IF               ;  4   if
        DW    N_PMUL             ;  5   +*
        DW    N_XA               ;  6   XA
        DW    N_XR               ;  7   XR
        DW    N_IFM              ;  8   if-
        DW    N_SDIV             ;  9   -/
        DW    N_PUSH             ; 10   PUSH
        DW    N_RFETCH           ; 11   @R+
        DW    N_RET              ; 12   ;
        DW    N_NAND             ; 13   NAND
        DW    N_POP              ; 14   POP
        DW    N_RSTORE           ; 15   !R+

        DW    N_FROM             ; 16
        DW    N_BP               ; 17
        DW    N_XOR              ; 18
        DW    N_AFETCH           ; 19
        DW    N_SKIP             ; 20
        DW    N_SKIP             ; 21
        DW    N_SKIP             ; 22
        DW    N_SKIP             ; 23

;----------------------------------------------------------------------
; Data
;----------------------------------------------------------------------
AREG    DW  0                   ; register A (16-bit)
NIBTMP  DW  0                   ; cell-1 copy for nibble extraction
NIBI    DW  0
NIB0    DB  0
NIB1    DB  0
NIB2    DB  0
NIB3    DB  0

;----------------------------------------------------------------------
; Inner interpreter  _next
;
; Fetches one 16-bit cell from [BX], advances BX by 2, then either:
;   even cell -> CALL (push BX to return stack, jump to cell)
;   odd  cell -> extract and dispatch 4 nibbles
;
; Nibble extraction uses 8086-legal SHR reg,1 (no SHR reg,imm).
; CX is reloaded from NIBTMP before each nibble level.
;----------------------------------------------------------------------

  ; --- even cell: CALL ---
_NEST:
  XCHG  AX,SI
_RPUSH:
  RPUSH AX
_next:
  LODSW     ;; fetch cell  ; IP += 2
  TEST AL,1               ; bit 0 set? -> odd -> nibble cell
  JE  _NEST

  ; --- odd cell: 4 nibbles ---
  DEC  AX                 ; clear bit 0; DX = packed nibbles
  MOV  NIBTMP,AX

  and  AX,0F0FH
  MOV  NIB0,AL
  MOV  NIB2,AH
  MOV  CX,4
  MOV  AX,NIBTMP
  and  AX,0F0F0H
  SHR  AX,CL
  MOV  NIB1,AL
  MOV  NIB3,AH

  DEC  CX
  MOV  NIBI,CX

NIBDISPATCH:
  MOV  BX,NIBI
  MOV  BL,NIB0[BX]             ; NIB0+NIBI = nibble[NIBI] * 2
DISPATCH:
  SHL  BX,1
  JMP  T_NANO[BX]

NIBDONE:
  DEC   NIBI
  JNS   NIBDISPATCH
  JMP  NEXT               ; all 4 done

;======================================================================
; Primitives  -- each ends WITH  JMP TO NIBDONE
;======================================================================

;----------------------------------------------------------------------
;  PUSH  ( n -- )  data TOS -> return stack
;----------------------------------------------------------------------
N_PUSH:
  pop   AX
  Rpush  AX
  JMP   NIBDONE

;----------------------------------------------------------------------
;  POP  ( -- n )  return TOS -> data stack
;----------------------------------------------------------------------
N_POP:
  Rpop  AX
  push  AX
  JMP   NIBDONE

;----------------------------------------------------------------------
;  DUP  ( n -- n n )
;----------------------------------------------------------------------
N_DUP:
  pop   AX
  push  AX
  push  AX
  JMP   NIBDONE

;----------------------------------------------------------------------
;  J  ( -- n )  push 2nd return stack element to data stack
;----------------------------------------------------------------------
N_J:
  PUSH  [BP+2]          ; 2nd return stack element
  JMP   NIBDONE

;----------------------------------------------------------------------
;  @R+  ( -- n )  fetch word at [RSP TOS]; RSP TOS += 2
;----------------------------------------------------------------------
N_RFETCH:
  X
  POP   DI
  MOV   AX,[DI]
  INC   DI
  INC   DI
  push  DI
  X
  push  AX
  JMP   NIBDONE

;----------------------------------------------------------------------
;  !R+  ( n -- )  store TOS to [RSP TOS]; RSP TOS += 2
;----------------------------------------------------------------------
N_RSTORE:
  pop   AX
  X
  POP   DI
  MOV   AX,[DI]
  STOSW
  push  DI
  X
  JMP   NIBDONE

;----------------------------------------------------------------------
;  XR  ( n -- m )  swap data TOS <-> return TOS
;----------------------------------------------------------------------
N_XR:
  pop   AX
  XCHG  AX,[BP]
  push  AX
  JMP   NIBDONE

;----------------------------------------------------------------------
;  XA  swap return TOS <-> AREG
;----------------------------------------------------------------------
N_XA:
  MOV   AX,AREG
  XCHG  AX,[BP]
  MOV   AREG,AX
  JMP   NIBDONE

;----------------------------------------------------------------------
;  ;  pop return TOS -> IP
;----------------------------------------------------------------------
N_RET:
  MOV   CX,NIBI
  JCXZ  @@RETZ
  MOV   CL,NIB0
  JCXZ  @@RETZ
  SHR   CX,1
  add   CL,16
  MOV   BX,CX
  JMP   DISPATCH

@@RETZ:
  RPOP  SI
  JMP   _NEXT

;----------------------------------------------------------------------
; if  ( n -- )  pop TOS; if zero: IP += OFFSET
;----------------------------------------------------------------------
N_IF:
  pop   CX
  JCXZ  N_JMP
  JMP   _NEXT

;----------------------------------------------------------------------
; if-  ( n -- n' )  decrement TOS; if >= 0: IP += OFFSET
;----------------------------------------------------------------------
N_IFM:
  pop   AX
  DEC   AX
  push  AX
  JS    _NEXT

;----------------------------------------------------------------------
; jmp  unconditional jump  IP += OFFSET
;----------------------------------------------------------------------
N_JMP:
  MOV   CX,NIBI
  JCXZ  JMPZ
  MOV   AX,NIBTMP
  SHL   CX,1
  SHL   CX,1
  DEC   CX
  MOV   BX,1
  SHL   BX,CL
  mov   cx,Bx
  dec   Bx
  and   cx,ax
  and   ax,Bx
  sub   ax,cx

  ADD  SI,AX
JMPZ:
  JMP   _NEXT
;wTest:
;  DW $8,$80, $800

;  DEC   CX
;  MOV   BX,CX
;  SHL   BX,1
;  MOV   DX,WTEST[BX]
;  mov   cx,dx
;  dec   dx
;  and   cx,ax
;  and   ax,dx
;  sub   ax,cx
;----------------------------------------------------------------------
; NAND  ( a b -- ~(a AND b) )
;----------------------------------------------------------------------
N_NAND:
  pop   AX CX
  and   AX,CX
  NOT  AX
  push  AX
  JMP   NIBDONE

;----------------------------------------------------------------------
;  +2/  ( nxt top -- sum sum>>1 )
;
; After: TOS = sum>>1, 2nd = sum.
;----------------------------------------------------------------------
N_P2DIV:
  pop   CX AX
  add   AX,CX
  MOV   CX,AX
  RCR   CX,1
  push  AX CX
  JMP   NIBDONE

;----------------------------------------------------------------------
; +*  ( nxt top -- nxt' top' )
;
; IF ODD(NXT): TOP += AREG   (carry from add captured in CF)
; SHIFTRIGHT(CF : TOP : NXT)  (32-bit right shift via carry chain)
;
; Note: TEST always clears CF, so CF=0 when NXT is even.
;----------------------------------------------------------------------
N_PMUL:
  pop   CX AX
  TEST AL,1          ; ZF=1 if NXT even; CF=0 always after TEST
  JZ   @@shift            ; NXT even: skip add (CF already 0)
  ADD  CX,AREG            ; NXT odd: TOP += AREG; CF = carry out
@@shift:
  RCR  CX,1               ; shift CF:TOP right
  RCR  AX,1          ; 32-bit chain into NXT
  push  AX CX
  JMP   NIBDONE

;----------------------------------------------------------------------
;  -/  ( nxt top -- nxt' top' )
;
; SHIFTLEFT(TOP : NXT)        (32-bit left shift)
; IF TOP >= AREG: TOP -= AREG; NXT += 1
;----------------------------------------------------------------------
N_SDIV:
  pop   CX AX
  SAL  AX,1          ; NXT <<= 1; CF = NXT bit 15
  RCL  CX,1               ; TOP <<= 1 with CF; CF = TOP bit 15 (lost)
  CMP  CX,AREG            ; unsigned compare
  JB   @@done             ; TOP < AREG -> done
  SUB  CX,AREG
  INC  AX
@@done:
  push  AX CX
  JMP   NIBDONE

;======================================================================
; Startup
;======================================================================

;----------------------------------------------------------------------
; NANO_INIT -- initialise registers and jump to test thread
;----------------------------------------------------------------------
NANO_INIT:
        CLD
        XOR  AX,AX
        MOV  AREG,AX            ; AREG = 0
        MOV  SP,0FFFEh          ; data stack base (top of segment)
        MOV  BP,0EFFEh          ; return stack base
        MOV  SI,OFFSET NANO_START
        JMP  _next

;======================================================================
; Test thread
;
; Encoding: cell must be odd (bit 0 = 1); cell-1 holds 4 nibbles.
;
; NANO_TEST_CELL encodes nibble0=DUP(2), nibble1=;(8), nibbles2-3=0:
;   cell-1 = (0<<12)|(0<<8)|(8<<4)|2 = $0082
;   cell   = $0083
;======================================================================
NANO_START  label  byte
        DW  0083H               ; nibble0=DUP(2), nibble1=;(8)

MyCseg  ends
        end  Start
