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
PC_LO   EQU  $10    ; ALLWAYS ZERO
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
PC_Y    EQU  $1B
RSP_X   EQU  $1C
NIB0    EQU  $1D    ; pre-extracted nibbles * 2 (sequential in ZP)
NIB1    EQU  $1E
NIB2    EQU  $1F
NIB3    EQU  $20
NIBI    EQU  $21    ; nibble index 0-3

RSPBTM  EQU  $80    ; CIRCULAR RETURN STACK BOTTOM - 128 BYTES


;----------------------------------------------------------------------
; Dispatch table TBLOP at $0300
; 16 entries, each 2 bytes: lo byte then hi byte of primitive address.
; Indexed: Y = nibble * 2;  lo = $0300,Y;  hi = $0301,Y
;----------------------------------------------------------------------
        ORG  $0300

TBLOP:
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

;       jmp   +2/   DUP     J
;       if    +*    XA      XR
;       if-   -/    PUSH    @R+
;       ;     NAND  POP     !R+


;----------------------------------------------------------------------
; NEXT -- inner interpreter loop
;
; Fetches a 16-bit cell from [PC], advances PC by 2, then:
;   even cell (bit 0 = 0) -> CALL
;   odd  cell (bit 0 = 1) -> 4-nibble dispatch
;
;----------------------------------------------------------------------

N_FROM:         ; RETURN TO 6502    TO ADRES PC_HI:PC_Y
  LDX   PC_HI 
  LDY   PC_Y
  BNE   FROM4
  DEX
FROM4:
  DEY
  TXA
  PHA
  TYA
  PHA
  RTS

TO4TH:      ; Y & PC_HI  is set BY CALL TO THIS ADDRESS 
  PLA   
  TAY
  PLA   
  STA  PC_HI
  INY
  BNE  GETW
  INC  PC_HI
  JMP   GETW    ; AFTER EXIT  Y MUST BE EVEN

NEXT:  
  LDY  PC_Y             ; 2  

GETW: 
  LDA  (PC_LO),Y        ; 5  FETCH BYTE
  TAX
  LSR
  INY                   ; 5  
  LDA  (PC_LO),Y        ; 5  FETCH BYTE
  INY                   ; 5  
  BNE  NEXT_TST         ; 3  INCR SWEET16 PC FOR FETCH
  INC  PC_HI            ;   

NEXT_TST:
  BCS  NIBS               ; carry set -> odd -> nibble dispatch

  STX   CL_LO
  PHA
;  LDY  PC_LO
  LDA  PC_HI
  JSR   RPUSH
  LDY   CL_LO
;  STY  PC_Y
  PLA
  STA  PC_HI
  JMP  GETW

NIBS:
  STY  PC_Y 
  DEX
  STX  CL_LO
  STA  CL_HI

  TAY
  AND  #$0F
  STA  NIB2
  TYA     ; Extract nibble 3: bits 7:4 of CL_HI
  LSR
  LSR
  LSR
  LSR
  STA  NIB3
  TXA
  AND  #$0F
  STA  NIB0
  TXA     ; Extract nibble 3: bits 7:4 of CL_HI
  LSR
  LSR
  LSR
  LSR
  STA  NIB1

  LDA  #3
  STA  NIBI

NIBDISPATCH:
  LDX  NIBI
  LDA  NIB0,X             ; NIB0+NIBI = nibble[NIBI] * 2
DISPATCH:
  ASL
  STA  JMP_LO             ; INDEX IN TABLE
  JMP  JMPVEC

N_AFETCH:
  LDX   #AR_LO
  JMP   @FETCH

N_RFETCH:
  LDX   RSP_X
@FETCH:
  JSR   LDAT          
  TAY
  JSR   LDAT

PHAY:
  PHA
  TYA
  PHA

NIBDONE:
  DEC   NIBI
  BPL   NIBDISPATCH
  JMP  NEXT               ; all 4 done

N_PUSH:
  PLA                     ; lo
  TAY
  PLA                     ; hi
  JSR   RPUSH
  JMP   NIBDONE

N_POP:
  JSR   RPOP
  JMP   PHAY

N_DUP:
  PLA                     ; lo
  TAY
  PLA                     ; hi
  TAX
  PHA
  TYA
  PHA
  TXA
  JMP   PHAY

N_J:
  LDX   RSP_X
  INX   
  INX   
  BMI   RPHJ
  LDX   #128
RPHJ:
  LDA  1,X            ; 2nd element hi
  LDY  0,X            ; 2nd element lo
  JMP   PHAY

N_RSTORE:
  LDX   RSP_X
  PLA
  JSR   STAT
  PLA
  JSR   STAT
  JMP   NIBDONE

N_XR:
  LDX   RSP_X
  PLA                     ; data TOS lo
  TAY
  PLA                     ; data TOS hi
  STA   TMP_HI
  LDA   1,X
  PHA
  LDA   0,X
  PHA
  LDA   TMP_HI
  STA   1,X
  STY   0,X
  JMP   NIBDONE

N_XA:
  LDX   RSP_X
  LDA   AR_LO
  LDY   0,X
  STY   AR_LO
  STA   0,X
  LDA   AR_HI
  LDY   1,X
  STY   AR_HI
  STA   1,X
  JMP   NIBDONE

N_IF:
  PLA                     ; lo
  STA  TMP_LO
  PLA                     ; hi
  ORA  TMP_LO             ; zero test
  BNE   N_SKIP

N_JMP:
  TXA
  BEQ   N_SKIP
  JSR   REL_OFST
  CLC
  LDA   CL_LO
  ADC   PC_Y
  TAY
  LDA   CL_HI
  ADC   PC_HI
  STA   PC_HI
  JMP  GETW

N_RET:
  TXA
  BEQ   N_RETZ
  LDA   NIB0
  BEQ   N_RETZ
  LSR
  ORA   #16         ; ADD 8 COMMANDS TO VM
  JMP   DISPATCH

N_RETZ:
  JSR   RPOP
  STY  PC_Y
  STA  PC_HI
N_SKIP:
  JMP   NEXT
 
N_IFM:
  SEC
  PLA 
  SBC   #1                    ; lo
  TAY
  PLA                     ; hi
  SBC   #0
  PHA
  ASL
  TYA
  PHA
  BCS   N_SKIP
  JMP   N_JMP

N_NAND:
  PLA                     ; b lo
  STA  TMP_LO
  PLA                     ; b hi
  STA  TMP_HI
  PLA                     ; a lo
  AND  TMP_LO
  EOR  #$FF               ; NAND lo
  TAY
  PLA                     ; a hi
  AND  TMP_HI
  EOR  #$FF               ; NAND hi
  JMP   PHAY

N_XOR:
  PLA                     ; b lo
  STA  TMP_LO
  PLA                     ; b hi
  STA  TMP_HI
  PLA                     ; a lo
  XOR  TMP_LO
  TAY
  PLA                     ; a hi
  XOR  TMP_HI
  JMP   PHAY

N_P2DIV:
  TSX
  INX
  CLC
  LDA  $200,X      ;TOP_LO
  ADC  $202,X      ;NXT_LO
  STA  $200,X      ;TOP_LO             ; TOP_LO = sum lo
  STA  $202,X      ;NXT_LO             ; NXT_LO = sum lo  (both get sum)
  LDA  $201,X      ;TOP_HI
  ADC  $203,X      ;NXT_HI
  STA  $201,X      ;TOP_HI             ; TOP_HI = sum hi
  STA  $203,X      ;NXT_HI             ; NXT_HI = sum hi
  ROR  $201,X      ;TOP_HI
  ROR  $200,X      ;TOP_LO
  JMP   NIBDONE

N_PMUL:
  TSX
  INX
  LDA  $202,X      ;NXT_LO           
  LSR
  BCC  PMUL_SHIFT         ; C=0 -> NXT was even -> skip add
  CLC
  LDA  $200,X      ;TOP_LO
  ADC  AR_LO
  STA  $200,X      ;TOP_LO
  LDA  $201,X      ;TOP_HI
  ADC  AR_HI
  STA  $201,X      ;TOP_HI
PMUL_SHIFT:
  ROR  $201,X      ;TOP_HI
  ROR  $200,X      ;TOP_LO
  ROR  $203,X      ;NXT_HI 
  ROR  $202,X      ;NXT_LO
  JMP   NIBDONE

N_SDIV:
  TSX
  INX
  ASL  $202,X      ;NXT_LO
  ROL  $203,X      ;NXT_HI 
  ROL  $200,X      ;TOP_LO
  ROL  $201,X      ;TOP_HI
  SEC
  LDA  $200,X      ;TOP_LO
  SBC  AR_LO
  TAY                     ; save lo of (TOP - AREG)
  LDA  $201,X      ;TOP_HI
  SBC  AR_HI
  BCC  SDIV_DONE          ; borrow -> TOP < AREG -> skip
  STY  $200,X      ;TOP_LO
  STA  $201,X      ;TOP_HI
  INC  $202,X      ;NXT_LO
SDIV_DONE:
  JMP   NIBDONE

;======================================================================
; HELPERS
;======================================================================

RPUSH:
  LDX   RSP_X
  DEX   
  DEX  
  BMI   RPH1
  LDX   #254
RPH1:
  STA   1,X
  STY   0,X
  STX   RSP_X
  RTS

RPOP:
  LDX   RSP_X
  LDA   1,X
  LDY   0,X
  INX   
  INX   
  BMI   RPH1
  LDX   #128
RPH1:
  STX   RSP_X
  RTS


STAT    STA  (0,X)        ;STORE BYTE INDIRECT
        JMP  INRZ    
         
LDAT    LDA  (0,X)        ;LOAD INDIRECT (RX)
INRZ    INC  0,X          ;  ZERO
        BNE  INR2           ;INCR RX
        INC  1,X
INR2    RTS

; 1    2    3       NIBLE
; FFF0 FF00 F000    OR  MASK
; 000F 00FF 0FFF    AND MASK

REL_OFST:
  LSR             ; ODD NIBLE IN BYTE
  TAY             ; BYTE INDEX IN cell CL
;  DEX
  LDA   NIB0-1,X    ; Nibble INDEX IN X
;  INX             
  and   #8        ; SIGN OF OFSET
  BEQ   FORE      ; POSITIVE     
                  ; NEGATIVE
  BCC   EVENIB0
  LDA   NIB0,X
  ORA   #$F0
  STA   CL_LO,Y
EVENIB0:
  TYA
  BNE   REL_X
  DEY
SET_CLHI:
  STY  CL_HI
REL_X:
  RTS

FORE:             ; POSITIVE 
  BCC   EVENIB1
  LDA   NIB0,X
  STA   CL_LO,Y
EVENIB1:
  TYA 
  BEQ   SET_CLHI
  RTS
  

;======================================================================
; Test thread
;
; Encoding:
;   Odd cell: bit 0 = 1; cell - 1 holds nibble data.
;   DW $0003: cell-1 = $0002 => nibble0 = 2 (DUP); nibbles 1-3 = 0 (PUSH)
;   DW $0009: cell-1 = $0008 => nibble0 = 8 (;); nibbles 1-3 = 0 (PUSH)
;======================================================================

;----------------------------------------------------------------------
; INIT -- one-time setup; falls through to NEXT
;----------------------------------------------------------------------
INIT:
        ; Write $4C (JMP opcode) into JMPVEC once; the lo/hi bytes
        ; ($19/$1A) are updated per nibble during dispatch.
        LDA   #$4C
        STA   JMPVEC
        LDA   #3
        STA   JMP_HI

        LDX   #$FF     ; DATA stack empty (grows down)
        TXS

        DEX
        STX   RSP_X   ;return stack empty (grows down / CIRCULAR)

        ; AREG = 0
        LDA   #0
        STA   PC_LO
        STA   AR_LO
        STA   AR_HI
        JMP   NANO_START

  ALIGN 2

NANO_START:
        NOP
        JSR TO4TH               ; 

        DW   $0003              ; nibble0 = DUP (2)
        DW   $0009              ; nibble0 = ;   (8)
