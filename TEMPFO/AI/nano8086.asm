;======================================================================
; nano8086.asm  --  Nano-Forth VM for 8086
;
; 16 primitives, 16-bit cells, .COM file model (ORG 100H).
;
; Register assignments:
;   AX  = TOS (data stack top, register-cached)
;   SI  = data stack pointer (grows toward lower addresses;
;         [SI] = 2nd element after a push)
;   BX  = IP  (instruction pointer)
;   BP  = return stack pointer (grows toward lower addresses;
;         [BP] = return TOS)
;   CX  = nibble work register
;   DI  = dispatch / scratch
;   DX  = scratch (not used as AREG to avoid MUL/DIV conflicts)
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
;                  nibble 0 = bits  3:0  (first to execute)
;                  nibble 1 = bits  7:4
;                  nibble 2 = bits 11:8
;                  nibble 3 = bits 15:12 (last to execute)
;
; Build: TASM nano8086.asm  /  TLINK nano8086
;======================================================================

locals @@
pw  equ  word ptr
pb  equ  byte ptr

;----------------------------------------------------------------------
; Macros
;----------------------------------------------------------------------

_DUP    MACRO                   ; push AX onto data stack
        LEA  SI,[SI-2]
        MOV  [SI],AX
        ENDM

_DROP   MACRO                   ; pop data stack into AX
        LODSW
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
        DW  _N_PUSH             ; nibble  0  PUSH
        DW  _N_POP              ; nibble  1  POP
        DW  _N_DUP              ; nibble  2  DUP
        DW  _N_J                ; nibble  3  J
        DW  _N_RFETCH           ; nibble  4  @R+
        DW  _N_RSTORE           ; nibble  5  !R+
        DW  _N_XR               ; nibble  6  XR
        DW  _N_XA               ; nibble  7  XA
        DW  _N_RET              ; nibble  8  ;
        DW  _N_IF               ; nibble  9  if
        DW  _N_IFM              ; nibble 10  if-
        DW  _N_JMP              ; nibble 11  jmp
        DW  _N_NAND             ; nibble 12  NAND
        DW  _N_P2DIV            ; nibble 13  +2/
        DW  _N_PMUL             ; nibble 14  +*
        DW  _N_SDIV             ; nibble 15  -/

;----------------------------------------------------------------------
; Data
;----------------------------------------------------------------------
AREG    DW  0                   ; register A (16-bit)
NIBTMP  DW  0                   ; cell-1 copy for nibble extraction

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
_next:
        MOV  CX,[BX]            ; fetch cell
        INC  BX
        INC  BX                 ; IP += 2

        TEST CL,1               ; bit 0 set? -> odd -> nibble cell
        JNE  @@nibs

        ; --- even cell: CALL ---
        LEA  BP,[BP-2]
        MOV  [BP],BX            ; push return address
        MOV  BX,CX              ; set IP = call target
        JMP  _next

        ; --- odd cell: 4 nibbles ---
@@nibs:
        DEC  CX                 ; clear bit 0; CX = packed nibbles
        MOV  NIBTMP,CX

        ; nibble 0: bits 3:0
        MOV  CX,NIBTMP
        AND  CX,0FH
        SHL  CX,1
        MOV  DI,CX
        ADD  DI,OFFSET T_NANO
        CALL pw [DI]

        ; nibble 1: bits 7:4  (shift right 4 = four SHR reg,1)
        MOV  CX,NIBTMP
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        AND  CX,0FH
        SHL  CX,1
        MOV  DI,CX
        ADD  DI,OFFSET T_NANO
        CALL pw [DI]

        ; nibble 2: bits 11:8  (shift right 8 = eight SHR reg,1)
        MOV  CX,NIBTMP
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        AND  CX,0FH
        SHL  CX,1
        MOV  DI,CX
        ADD  DI,OFFSET T_NANO
        CALL pw [DI]

        ; nibble 3: bits 15:12  (shift right 12 = twelve SHR reg,1)
        MOV  CX,NIBTMP
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        SHR  CX,1
        AND  CX,0FH
        SHL  CX,1
        MOV  DI,CX
        ADD  DI,OFFSET T_NANO
        CALL pw [DI]

        JMP  _next

;======================================================================
; Primitives  -- each ends with RET
; (CALL pw[DI] pushes return address to 8086 hardware stack (SS:SP),
;  separate from the Nano-Forth data stack SI and return stack BP)
;======================================================================

;----------------------------------------------------------------------
; 0: PUSH  ( n -- )  data TOS -> return stack
;----------------------------------------------------------------------
_N_PUSH:
        LEA  BP,[BP-2]
        MOV  [BP],AX            ; push AX to RSP
        _DROP                   ; AX = new data TOS
        RET

;----------------------------------------------------------------------
; 1: POP  ( -- n )  return TOS -> data stack
;----------------------------------------------------------------------
_N_POP:
        _DUP                    ; save AX to data stack
        MOV  AX,[BP]            ; AX = return TOS
        LEA  BP,[BP+2]          ; pop return stack
        RET

;----------------------------------------------------------------------
; 2: DUP  ( n -- n n )
;----------------------------------------------------------------------
_N_DUP:
        _DUP                    ; AX unchanged; copy of AX now at [SI]
        RET

;----------------------------------------------------------------------
; 3: J  ( -- n )  push 2nd return stack element to data stack
;----------------------------------------------------------------------
_N_J:
        _DUP
        MOV  AX,[BP+2]          ; 2nd return stack element
        RET

;----------------------------------------------------------------------
; 4: @R+  ( -- n )  fetch word at [RSP TOS]; RSP TOS += 2
;----------------------------------------------------------------------
_N_RFETCH:
        _DUP
        MOV  DI,[BP]            ; DI = address held in RSP TOS
        MOV  AX,[DI]            ; fetch word
        ADD  pw [BP],2          ; advance the address stored in RSP TOS
        RET

;----------------------------------------------------------------------
; 5: !R+  ( n -- )  store TOS to [RSP TOS]; RSP TOS += 2
;----------------------------------------------------------------------
_N_RSTORE:
        MOV  DI,[BP]
        MOV  [DI],AX
        ADD  pw [BP],2
        _DROP
        RET

;----------------------------------------------------------------------
; 6: XR  ( n -- m )  swap data TOS <-> return TOS
;----------------------------------------------------------------------
_N_XR:
        XCHG AX,[BP]
        RET

;----------------------------------------------------------------------
; 7: XA  swap return TOS <-> AREG
;----------------------------------------------------------------------
_N_XA:
        MOV  CX,AREG
        XCHG CX,[BP]
        MOV  AREG,CX
        RET

;----------------------------------------------------------------------
; 8: ;  pop return TOS -> IP
;----------------------------------------------------------------------
_N_RET:
        MOV  BX,[BP]
        LEA  BP,[BP+2]
        RET

;----------------------------------------------------------------------
; 9: if  ( n -- )  pop TOS; if zero: IP = [IP]; else IP += 2
;----------------------------------------------------------------------
_N_IF:
        MOV  CX,AX              ; capture TOS (LODSW in _DROP changes AX)
        _DROP
        JCXZ @@zero
        INC  BX                 ; skip 2-byte jump address
        INC  BX
        RET
@@zero: MOV  BX,[BX]            ; take jump
        RET

;----------------------------------------------------------------------
; 10: if-  ( n -- n' )  decrement TOS; if >= 0: IP = [IP]; else IP += 2
;----------------------------------------------------------------------
_N_IFM:
        DEC  AX
        JS   @@neg              ; sign set -> result < 0 -> skip
        MOV  BX,[BX]            ; sign clear -> result >= 0 -> take jump
        RET
@@neg:  INC  BX
        INC  BX
        RET

;----------------------------------------------------------------------
; 11: jmp  unconditional jump  IP = [IP]
;----------------------------------------------------------------------
_N_JMP:
        MOV  BX,[BX]
        RET

;----------------------------------------------------------------------
; 12: NAND  ( a b -- ~(a AND b) )
;----------------------------------------------------------------------
_N_NAND:
        MOV  DI,[SI]            ; DI = NXT (2nd data element)
        AND  AX,DI
        NOT  AX
        INC  SI
        INC  SI                 ; discard NXT from data stack
        RET

;----------------------------------------------------------------------
; 13: +2/  ( nxt top -- sum sum>>1 )
;
; Pops NXT (at [SI]) and TOP (AX).
; Pushes raw sum, then pushes sum>>1 (with carry from add).
; After: TOS = sum>>1, 2nd = sum.
;----------------------------------------------------------------------
_N_P2DIV:
        MOV  DI,AX              ; DI = TOP
        ADD  DI,[SI]            ; DI = TOP + NXT = sum; CF = carry out
        MOV  [SI],DI            ; store sum at NXT slot
        RCR  DI,1               ; DI = sum >> 1 (carry bit shifted in)
        MOV  AX,DI              ; AX (TOS) = sum>>1
        ; [SI] = raw sum (2nd element)
        RET

;----------------------------------------------------------------------
; 14: +*  ( nxt top -- nxt' top' )
;
; IF ODD(NXT): TOP += AREG   (carry from add captured in CF)
; SHIFTRIGHT(CF : TOP : NXT)  (32-bit right shift via carry chain)
;
; Note: TEST always clears CF, so CF=0 when NXT is even.
;----------------------------------------------------------------------
_N_PMUL:
        TEST pw [SI],1          ; ZF=1 if NXT even; CF=0 always after TEST
        JZ   @@shift            ; NXT even: skip add (CF already 0)
        ADD  AX,AREG            ; NXT odd: TOP += AREG; CF = carry out
@@shift:
        RCR  AX,1               ; shift CF:TOP right
        RCR  pw [SI],1          ; 32-bit chain into NXT
        RET

;----------------------------------------------------------------------
; 15: -/  ( nxt top -- nxt' top' )
;
; SHIFTLEFT(TOP : NXT)        (32-bit left shift)
; IF TOP >= AREG: TOP -= AREG; NXT += 1
;----------------------------------------------------------------------
_N_SDIV:
        SAL  pw [SI],1          ; NXT <<= 1; CF = NXT bit 15
        RCL  AX,1               ; TOP <<= 1 with CF; CF = TOP bit 15 (lost)
        CMP  AX,AREG            ; unsigned compare
        JB   @@done             ; TOP < AREG -> done
        SUB  AX,AREG
        INC  pw [SI]
@@done:
        RET

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
        MOV  SI,0FFFEh          ; data stack base (top of segment)
        MOV  BP,0EFFEh          ; return stack base
        MOV  BX,OFFSET NANO_START
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
