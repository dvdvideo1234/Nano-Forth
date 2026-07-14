;======================================================================
; nano6502.asm  --  Nano-Forth VM for 6502
;
; Implements all 16 Nano-Forth primitives.
; Generic 6502 assembly syntax (DASM / ca65 / xa compatible).
;
; Architecture:
;   Data stack  : 6502 hardware stack  $0100-$01FF
;                 Convention: push hi first, then lo.
;                 PLA => lo byte;  second PLA => hi byte.
;   Return stack: page $0200, indexed by X (RSP).
;                 X points to lo byte of TOS; X+1 = hi byte.
;                 Push: DEX DEX, STA $0200,X (lo), STA $0201,X (hi)
;                 Pop : LDA $0200,X (lo), LDA $0201,X (hi), INX INX
;   Y register  : held = 0 across the NEXT loop for (PC_LO),Y
;
; Dispatch mechanism (no JSR -- avoids corrupting the data stack):
;   JMPVEC ($18-$1A) holds a 3-byte JMP abs instruction:
;     $18 = $4C (JMP opcode, written once at INIT)
;     $19 = lo byte of primitive address  (set per nibble)
;     $1A = hi byte of primitive address  (set per nibble)
;   Executing  JMP JMPVEC  transfers control to the primitive.
;   Primitives end with  JMP (CONT)  (indirect through $1B/$1C).
;   CONT is set to NIBDONE before each nibble dispatch.
;   NIBDONE increments NIBI and loops until all 4 nibbles done.
;
; Zero-page layout  ($10-$25):
;   PC_LO  $10  Instruction pointer lo
;   PC_HI  $11  Instruction pointer hi
;   AR_LO  $12  Register A lo
;   AR_HI  $13  Register A hi
;   TMP_LO $14  Scratch lo
;   TMP_HI $15  Scratch hi
;   CL_LO  $16  Fetched cell lo
;   CL_HI  $17  Fetched cell hi
;   JMPVEC $18  JMP opcode ($4C), fixed at INIT
;   JMP_LO $19  Target lo, set per nibble
;   JMP_HI $1A  Target hi, set per nibble
;   CONT   $1B  Continuation ptr lo  (target of JMP (CONT))
;   CONT+1 $1C  Continuation ptr hi
;   NIB0   $1D  Nibble 0 * 2
;   NIB1   $1E  Nibble 1 * 2
;   NIB2   $1F  Nibble 2 * 2
;   NIB3   $20  Nibble 3 * 2
;   NIBI   $21  Current nibble index (0-3)
;   TOP_LO $22  Math op: TOP lo
;   TOP_HI $23  Math op: TOP hi
;   NXT_LO $24  Math op: NXT lo
;   NXT_HI $25  Math op: NXT hi
;
; Assemble (DASM):   dasm nano6502.asm -o nano6502.bin -f3
;======================================================================

;----------------------------------------------------------------------
; Zero-page equates
;----------------------------------------------------------------------
PC_LO   EQU  $10
PC_HI   EQU  $11
AR_LO   EQU  $12
AR_HI   EQU  $13
TMP_LO  EQU  $14
TMP_HI  EQU  $15
CL_LO   EQU  $16
CL_HI   EQU  $17
JMPVEC  EQU  $18    ; 3-byte JMP instruction: opcode at $18, addr at $19/$1A
JMP_LO  EQU  $19
JMP_HI  EQU  $1A
CONT    EQU  $1B    ; 2-byte indirect JMP target (lo=$1B, hi=$1C)
NIB0    EQU  $1D    ; pre-extracted nibbles * 2 (sequential in ZP)
NIB1    EQU  $1E
NIB2    EQU  $1F
NIB3    EQU  $20
NIBI    EQU  $21    ; nibble index 0-3
TOP_LO  EQU  $22
TOP_HI  EQU  $23
NXT_LO  EQU  $24
NXT_HI  EQU  $25

;----------------------------------------------------------------------
; Dispatch table TBLOP at $0300
; 16 entries, each 2 bytes: lo byte then hi byte of primitive address.
; Indexed: Y = nibble * 2;  lo = $0300,Y;  hi = $0301,Y
;----------------------------------------------------------------------
        ORG  $0300

TBLOP:
        DW   N_PUSH             ; 0   PUSH
        DW   N_POP              ; 1   POP
        DW   N_DUP              ; 2   DUP
        DW   N_J                ; 3   J
        DW   N_RFETCH           ; 4   @R+
        DW   N_RSTORE           ; 5   !R+
        DW   N_XR               ; 6   XR
        DW   N_XA               ; 7   XA
        DW   N_RET              ; 8   ;
        DW   N_IF               ; 9   if
        DW   N_IFM              ; 10  if-
        DW   N_JMP              ; 11  jmp
        DW   N_NAND             ; 12  NAND
        DW   N_P2DIV            ; 13  +2/
        DW   N_PMUL             ; 14  +*
        DW   N_SDIV             ; 15  -/

;======================================================================
; Code begins at $0400
;======================================================================
        ORG  $0400

;----------------------------------------------------------------------
; INIT -- one-time setup; falls through to NEXT
;----------------------------------------------------------------------
INIT:
        ; Write $4C (JMP opcode) into JMPVEC once; the lo/hi bytes
        ; ($19/$1A) are updated per nibble during dispatch.
        LDA  #$4C
        STA  JMPVEC

        ; X = $FF: return stack empty (grows down)
        LDX  #$FF

        ; AREG = 0
        LDA  #0
        STA  AR_LO
        STA  AR_HI

        ; IP = NANO_START
        LDA  #<NANO_START
        STA  PC_LO
        LDA  #>NANO_START
        STA  PC_HI
        ; fall through to NEXT

;----------------------------------------------------------------------
; NEXT -- inner interpreter loop
;
; Fetches a 16-bit cell from [PC], advances PC by 2, then:
;   even cell (bit 0 = 0) -> CALL
;   odd  cell (bit 0 = 1) -> 4-nibble dispatch
;
; Y is set to 0 at entry and must remain 0 for (PC_LO),Y.
;----------------------------------------------------------------------
NEXT:
        LDY  #0

        ; Fetch cell lo
        LDA  (PC_LO),Y
        STA  CL_LO
        INY
        ; Fetch cell hi
        LDA  (PC_LO),Y
        STA  CL_HI

        ; PC += 2
        CLC
        LDA  PC_LO
        ADC  #2
        STA  PC_LO
        BCC  NEXT_TST
        INC  PC_HI

NEXT_TST:
        ; Test bit 0 of cell lo
        LDA  CL_LO
        LSR                     ; bit 0 -> carry; A = CL_LO >> 1
        BCS  NIBS               ; carry set -> odd -> nibble dispatch

        ; -------------------------------------------------------
        ; CALL (even cell): push PC to return stack, set PC = cell
        ; -------------------------------------------------------
        DEX
        DEX
        LDA  PC_LO
        STA  $0200,X            ; return addr lo
        LDA  PC_HI
        STA  $0201,X            ; return addr hi

        LDA  CL_LO
        STA  PC_LO
        LDA  CL_HI
        STA  PC_HI
        JMP  NEXT

        ; -------------------------------------------------------
        ; NIBS: pre-extract 4 nibbles, dispatch each via JMPVEC
        ;
        ; JMPVEC points to a 3-byte JMP abs at $18-$1A.
        ; Setting JMP_LO ($19) selects the primitive from TBLOP.
        ; The primitive ends with JMP (CONT) -> NIBDONE.
        ; NIBDONE increments NIBI; when NIBI = 4 it jumps NEXT.
        ; -------------------------------------------------------
NIBS:
        ; Extract nibble 0: bits 3:0 of CL_LO
        LDA  CL_LO
        AND  #$0F
        ASL                     ; * 2 for table index
        STA  NIB0

        ; Extract nibble 1: bits 7:4 of CL_LO
        LDA  CL_LO
        LSR
        LSR
        LSR
        LSR
        AND  #$0F
        ASL
        STA  NIB1

        ; Extract nibble 2: bits 3:0 of CL_HI
        LDA  CL_HI
        AND  #$0F
        ASL
        STA  NIB2

        ; Extract nibble 3: bits 7:4 of CL_HI
        LDA  CL_HI
        LSR
        LSR
        LSR
        LSR
        AND  #$0F
        ASL
        STA  NIB3

        ; Initialise nibble counter
        LDA  #0
        STA  NIBI

        ; Set continuation -> NIBDONE
        LDA  #<NIBDONE
        STA  CONT
        LDA  #>NIBDONE
        STA  CONT+1

        ; Fall into NIBDISPATCH for nibble 0
        ; (NIBI = 0, so NIB0,Y with Y=0 picks NIB0)

NIBDISPATCH:
        ; Y = NIBI (0-3); NIB0..NIB3 are sequential in ZP at $1D-$20
        LDY  NIBI
        LDA  NIB0,Y             ; NIB0+NIBI = nibble[NIBI] * 2
        TAY                     ; Y = nibble * 2  (table index)

        ; Load primitive address from TBLOP into JMPVEC+1/+2
        LDA  $0300,Y            ; lo byte of primitive address
        STA  JMP_LO
        INY
        LDA  $0300,Y            ; hi byte
        STA  JMP_HI

        ; Jump to JMPVEC: CPU executes JMP abs stored at $18-$1A
        JMP  JMPVEC

        ; (primitive executes; ends with JMP (CONT) -> NIBDONE)

;----------------------------------------------------------------------
; NIBDONE -- continuation after each primitive
; Increments NIBI; when all 4 nibbles done, goes to NEXT.
;----------------------------------------------------------------------
NIBDONE:
        INC  NIBI
        LDA  NIBI
        CMP  #4
        BCC  NIBDISPATCH        ; nibbles 1, 2, 3
        JMP  NEXT               ; all 4 done

;======================================================================
; Primitives -- each ends with JMP (CONT)
;
; X = RSP throughout (never modified except by primitives that
; explicitly push/pop the return stack).
;======================================================================

;----------------------------------------------------------------------
; 0: PUSH  ( n -- )  data TOS -> return stack
;----------------------------------------------------------------------
N_PUSH:
        PLA                     ; lo byte of data TOS
        STA  TMP_LO
        PLA                     ; hi byte of data TOS
        STA  TMP_HI
        ; push to return stack (X decrements by 2)
        DEX
        DEX
        LDA  TMP_LO
        STA  $0200,X
        LDA  TMP_HI
        STA  $0201,X
        JMP  (CONT)

;----------------------------------------------------------------------
; 1: POP  ( -- n )  return TOS -> data stack
;----------------------------------------------------------------------
N_POP:
        LDA  $0201,X            ; hi byte of return TOS
        PHA                     ; push hi to data stack first
        LDA  $0200,X            ; lo byte
        PHA                     ; push lo
        INX
        INX                     ; pop return stack
        JMP  (CONT)

;----------------------------------------------------------------------
; 2: DUP  ( n -- n n )
;----------------------------------------------------------------------
N_DUP:
        PLA                     ; lo
        STA  TMP_LO
        PLA                     ; hi
        STA  TMP_HI
        ; push first copy
        LDA  TMP_HI
        PHA
        LDA  TMP_LO
        PHA
        ; push second copy
        LDA  TMP_HI
        PHA
        LDA  TMP_LO
        PHA
        JMP  (CONT)

;----------------------------------------------------------------------
; 3: J  ( -- n )  2nd return stack element -> data stack
; Return stack at page $0200; X -> TOS lo, X+1 -> TOS hi,
;                              X+2 -> 2nd lo, X+3 -> 2nd hi
;----------------------------------------------------------------------
N_J:
        LDA  $0203,X            ; 2nd element hi
        PHA
        LDA  $0202,X            ; 2nd element lo
        PHA
        JMP  (CONT)

;----------------------------------------------------------------------
; 4: @R+  ( -- n )  fetch word at [RSP TOS]; RSP TOS address += 2
;----------------------------------------------------------------------
N_RFETCH:
        ; Address is in return TOS ($0200+X lo, $0201+X hi)
        LDA  $0200,X
        STA  TMP_LO
        LDA  $0201,X
        STA  TMP_HI
        ; Fetch word from [TMP]
        LDY  #0
        LDA  (TMP_LO),Y
        STA  CL_LO              ; borrow CL for result temp
        INY
        LDA  (TMP_LO),Y
        STA  CL_HI
        ; Advance address stored in RSP TOS by 2
        CLC
        LDA  $0200,X
        ADC  #2
        STA  $0200,X
        BCC  RFETCH_NI
        INC  $0201,X
RFETCH_NI:
        ; Push fetched word to data stack
        LDA  CL_HI
        PHA
        LDA  CL_LO
        PHA
        JMP  (CONT)

;----------------------------------------------------------------------
; 5: !R+  ( n -- )  store data TOS to [RSP TOS]; RSP TOS address += 2
;----------------------------------------------------------------------
N_RSTORE:
        PLA                     ; data TOS lo
        STA  TMP_LO
        PLA                     ; data TOS hi
        STA  TMP_HI
        ; Destination address from return TOS
        LDA  $0200,X
        STA  CL_LO
        LDA  $0201,X
        STA  CL_HI
        ; Store word
        LDY  #0
        LDA  TMP_LO
        STA  (CL_LO),Y
        INY
        LDA  TMP_HI
        STA  (CL_LO),Y
        ; Advance RSP TOS address by 2
        CLC
        LDA  $0200,X
        ADC  #2
        STA  $0200,X
        BCC  RSTORE_NI
        INC  $0201,X
RSTORE_NI:
        JMP  (CONT)

;----------------------------------------------------------------------
; 6: XR  ( n -- m )  swap data TOS <-> return TOS
; Ref: INDIRCT_Threaded.txt lines 210-225
;----------------------------------------------------------------------
N_XR:
        PLA                     ; data TOS lo
        STA  TMP_LO
        PLA                     ; data TOS hi
        STA  TMP_HI
        ; Push return TOS to data stack (hi first)
        LDA  $0201,X
        PHA
        LDA  $0200,X
        PHA
        ; Write old data TOS to return TOS
        LDA  TMP_LO
        STA  $0200,X
        LDA  TMP_HI
        STA  $0201,X
        JMP  (CONT)

;----------------------------------------------------------------------
; 7: XA  swap return TOS <-> AREG
; Ref: INDIRCT_Threaded.txt lines 226-235
;----------------------------------------------------------------------
N_XA:
        LDA  AR_LO
        STA  TMP_LO
        LDA  AR_HI
        STA  TMP_HI
        LDA  $0200,X
        STA  AR_LO
        LDA  $0201,X
        STA  AR_HI
        LDA  TMP_LO
        STA  $0200,X
        LDA  TMP_HI
        STA  $0201,X
        JMP  (CONT)

;----------------------------------------------------------------------
; 8: ;  pop return TOS -> IP
;----------------------------------------------------------------------
N_RET:
        LDA  $0200,X
        STA  PC_LO
        LDA  $0201,X
        STA  PC_HI
        INX
        INX
        JMP  (CONT)

;----------------------------------------------------------------------
; 9: if  ( n -- )  pop TOS; if zero: IP = [IP]; else IP += 2
;----------------------------------------------------------------------
N_IF:
        PLA                     ; lo
        STA  TMP_LO
        PLA                     ; hi
        ORA  TMP_LO             ; zero test
        BNE  IF_SKIP
        ; Take jump: load 2-byte address from [PC]
        LDY  #0
        LDA  (PC_LO),Y
        STA  TMP_LO
        INY
        LDA  (PC_LO),Y
        STA  PC_HI
        LDA  TMP_LO
        STA  PC_LO
        JMP  (CONT)
IF_SKIP:
        CLC
        LDA  PC_LO
        ADC  #2
        STA  PC_LO
        BCC  IF_NI
        INC  PC_HI
IF_NI:
        JMP  (CONT)

;----------------------------------------------------------------------
; 10: if-  ( n -- n' )  decrement TOS; if >= 0: IP = [IP]; else IP += 2
;----------------------------------------------------------------------
N_IFM:
        PLA                     ; lo
        STA  TMP_LO
        PLA                     ; hi
        STA  TMP_HI
        ; 16-bit decrement TMP
        LDA  TMP_LO
        BNE  IFM_NB
        DEC  TMP_HI
IFM_NB:
        DEC  TMP_LO
        ; Push decremented value back to data stack
        LDA  TMP_HI
        PHA
        LDA  TMP_LO
        PHA
        ; Check sign (bit 7 of hi): set -> negative -> skip
        BIT  TMP_HI
        BMI  IFM_SKIP
        ; Positive (>= 0): take jump
        LDY  #0
        LDA  (PC_LO),Y
        STA  TMP_LO
        INY
        LDA  (PC_LO),Y
        STA  PC_HI
        LDA  TMP_LO
        STA  PC_LO
        JMP  (CONT)
IFM_SKIP:
        CLC
        LDA  PC_LO
        ADC  #2
        STA  PC_LO
        BCC  IFM_NI
        INC  PC_HI
IFM_NI:
        JMP  (CONT)

;----------------------------------------------------------------------
; 11: jmp  IP = [IP]  (unconditional jump)
;----------------------------------------------------------------------
N_JMP:
        LDY  #0
        LDA  (PC_LO),Y
        STA  TMP_LO
        INY
        LDA  (PC_LO),Y
        STA  PC_HI
        LDA  TMP_LO
        STA  PC_LO
        JMP  (CONT)

;----------------------------------------------------------------------
; 12: NAND  ( a b -- ~(a AND b) )
; Ref: INDIRCT_Threaded.txt lines 171-182
;----------------------------------------------------------------------
N_NAND:
        PLA                     ; b lo
        STA  TMP_LO
        PLA                     ; b hi
        STA  TMP_HI
        PLA                     ; a lo
        AND  TMP_LO
        EOR  #$FF               ; NAND lo
        STA  TMP_LO
        PLA                     ; a hi
        AND  TMP_HI
        EOR  #$FF               ; NAND hi
        PHA                     ; push result hi
        LDA  TMP_LO
        PHA                     ; push result lo
        JMP  (CONT)

;----------------------------------------------------------------------
; 13: +2/  ( nxt top -- sum  sum>>1 )
;
; Pops TOP (TOS) and NXT (2nd), pushes raw sum then sum>>1 with carry.
; Ref: INDIRCT_Threaded.txt P2DIV lines 400-411
;----------------------------------------------------------------------
N_P2DIV:
        PLA                     ; TOP lo
        STA  TOP_LO
        PLA                     ; TOP hi
        STA  TOP_HI
        PLA                     ; NXT lo
        STA  NXT_LO
        PLA                     ; NXT hi
        STA  NXT_HI
        ; sum = TOP + NXT
        CLC
        LDA  TOP_LO
        ADC  NXT_LO
        STA  TOP_LO             ; TOP_LO = sum lo
        STA  NXT_LO             ; NXT_LO = sum lo  (both get sum)
        LDA  TOP_HI
        ADC  NXT_HI
        STA  TOP_HI             ; TOP_HI = sum hi
        STA  NXT_HI             ; NXT_HI = sum hi
        ; sum>>1 with carry (carry from ADC is still in C)
        ROR  TOP_HI
        ROR  TOP_LO
        ; Push NXT = raw sum (hi first)
        LDA  NXT_HI
        PHA
        LDA  NXT_LO
        PHA
        ; Push TOP = sum>>1
        LDA  TOP_HI
        PHA
        LDA  TOP_LO
        PHA
        JMP  (CONT)

;----------------------------------------------------------------------
; 14: +*  ( nxt top -- nxt' top' )
;
; IF ODD(NXT): TOP += AREG
; SHIFTRIGHT(CF : TOP : NXT)  -- 32-bit right shift via carry chain
; Ref: INDIRCT_Threaded.txt PMULZ lines 346-370
;----------------------------------------------------------------------
N_PMUL:
        PLA                     ; TOP lo
        STA  TOP_LO
        PLA                     ; TOP hi
        STA  TOP_HI
        PLA                     ; NXT lo
        STA  NXT_LO
        PLA                     ; NXT hi
        STA  NXT_HI
        ; Test bit 0 of NXT lo: load into A, then LSR accumulator (does NOT
        ; write back to NXT_LO); old bit0 -> C.  The later ROR NXT_LO is the
        ; only shift applied to NXT_LO, keeping the 32-bit chain correct.
        LDA  NXT_LO             ; load NXT lo into A (NXT_LO in ZP unchanged)
        LSR                     ; A >>= 1; old bit0 -> C; NXT_LO unmodified
        BCC  PMUL_SHIFT         ; C=0 -> NXT was even -> skip add
        ; NXT was odd: TOP += AREG
        CLC
        LDA  TOP_LO
        ADC  AR_LO
        STA  TOP_LO
        LDA  TOP_HI
        ADC  AR_HI
        STA  TOP_HI
        ; carry from this ADD is now in C for the shift chain
PMUL_SHIFT:
        ; 32-bit right shift: C:TOP_HI:TOP_LO:NXT_HI:NXT_LO
        ; NXT_LO was already shifted right by 1 (the LSR above),
        ; so the chain continues from NXT_HI:
        ROR  TOP_HI
        ROR  TOP_LO
        ROR  NXT_HI
        ROR  NXT_LO             ; completes 32-bit chain
        ; Push NXT then TOP (NXT is below, TOP on top)
        LDA  NXT_HI
        PHA
        LDA  NXT_LO
        PHA
        LDA  TOP_HI
        PHA
        LDA  TOP_LO
        PHA
        JMP  (CONT)

;----------------------------------------------------------------------
; 15: -/  ( nxt top -- nxt' top' )
;
; SHIFTLEFT(TOP : NXT)        -- 32-bit left shift
; IF TOP >= AREG: TOP -= AREG; NXT += 1
; Ref: INDIRCT_Threaded.txt SDIVZ lines 381-398
;----------------------------------------------------------------------
N_SDIV:
        PLA                     ; TOP lo
        STA  TOP_LO
        PLA                     ; TOP hi
        STA  TOP_HI
        PLA                     ; NXT lo
        STA  NXT_LO
        PLA                     ; NXT hi
        STA  NXT_HI
        ; 32-bit left shift: ROL NXT_LO, ROL NXT_HI, ROL TOP_LO, ROL TOP_HI
        ; (carry into NXT_LO comes from previous operation state)
        ROL  NXT_LO
        ROL  NXT_HI
        ROL  TOP_LO
        ROL  TOP_HI
        ; Unsigned compare: TOP >= AREG?
        SEC
        LDA  TOP_LO
        SBC  AR_LO
        TAY                     ; save lo of (TOP - AREG)
        LDA  TOP_HI
        SBC  AR_HI
        BCC  SDIV_DONE          ; borrow -> TOP < AREG -> skip
        ; TOP >= AREG: apply correction
        STY  TOP_LO
        STA  TOP_HI
        INC  NXT_LO
        BNE  SDIV_DONE
        INC  NXT_HI
SDIV_DONE:
        ; Push NXT then TOP
        LDA  NXT_HI
        PHA
        LDA  NXT_LO
        PHA
        LDA  TOP_HI
        PHA
        LDA  TOP_LO
        PHA
        JMP  (CONT)

;======================================================================
; Test thread
;
; Encoding:
;   Odd cell: bit 0 = 1; cell - 1 holds nibble data.
;   DW $0003: cell-1 = $0002 => nibble0 = 2 (DUP); nibbles 1-3 = 0 (PUSH)
;   DW $0009: cell-1 = $0008 => nibble0 = 8 (;); nibbles 1-3 = 0 (PUSH)
;======================================================================
NANO_START:
        DW   $0003              ; nibble0 = DUP (2)
        DW   $0009              ; nibble0 = ;   (8)
