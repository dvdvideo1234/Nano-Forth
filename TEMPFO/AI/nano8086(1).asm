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
;   CX  = nibble work: extraction (CL), table index, relative offset
;   DX  = nibble word during dispatch: DH=bits15:8, DL=bits7:0
;          (untouched by all primitives -- no reload needed)
;   DI  = dispatch address scratch; free temp in inline jump handlers
;
; Memory:
;   AREG   DW -- 16-bit accumulator register A
;
; Stack conventions:
;   Data:   SI decrements by 2 on push (_DUP); LODSW on pop (_DROP)
;   Return: BP decrements by 2 on push; BP increments by 2 on pop
;
; Primitive encoding:
;   Even cell -> CALL:  push IP to return stack, set IP = cell
;   Odd cell  -> 4 nibbles packed in cell-1, MSB-first:
;                  nibble 0 = bits 15:12 (first to execute)
;                  nibble 1 = bits 11:8
;                  nibble 2 = bits  7:4
;                  nibble 3 = bits  3:0 (last to execute)
;
; Relative jumps (if/if-/jmp at nibble position N):
;   Remaining bits (lower bits of DX) = signed cell offset.
;   Zero offset = sentinel -> absolute fallback reads [BX].
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

;----------------------------------------------------------------------
; Inner interpreter  _next
;
; Fetches one 16-bit cell from [BX], advances BX by 2, then either:
;   even cell -> CALL (push BX to return stack, jump to cell)
;   odd  cell -> extract and dispatch 4 nibbles (MSB-first)
;
; DX holds cell-1 during dispatch; no memory reload needed.
; If/if-/jmp at nibble N: remaining bits = signed relative cell offset.
; Zero offset -> absolute fallback (primitive reads [BX] for target).
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

        ; --- odd cell: 4 nibbles, MSB-first ---
        ; DX = cell-1: DH = bits 15:8 (nibbles 0,1); DL = bits 7:0 (nibbles 2,3)
        ; DX survives all CALL pw[DI] dispatches unchanged.
@@nibs:
        DEC  CX                 ; clear bit 0; CX = packed nibbles
        MOV  DX,CX              ; DH=bits15:8, DL=bits7:0; held for all 4 nibbles

        ;------------------------------------------------------
        ; Nibble 0: bits 15:12
        ;------------------------------------------------------
        MOV  CL,DH              ; CL = bits 15:8
        SHR  CL,1               ;
        SHR  CL,1               ; CL = nibble 0 (bits 15:12)
        SHR  CL,1               ;
        SHR  CL,1               ;
        CMP  CL,9
        JB   @@n0_disp          ; < 9: not a jump, normal dispatch
        CMP  CL,11
        JA   @@n0_disp          ; > 11: not a jump, normal dispatch
        ; jump primitive at position 0: remaining bits 11:0 are offset
        CMP  CL,11
        JE   @@n0_jmp
        CMP  CL,10
        JE   @@n0_ifm
        ; op = 9 (if): pop TOS; jump if zero
        MOV  CX,DX
        AND  CX,0FFFh           ; 12-bit raw offset
        JCXZ @@n0_abs           ; zero -> absolute fallback
        TEST CX,0800h           ; test sign bit (bit 11)
        JZ   @@n0_if_se
        OR   CX,0F000h          ; sign-extend negative
@@n0_if_se:
        SHL  CX,1               ; cell offset -> byte offset
        MOV  DI,AX              ; save TOS (LODSW in _DROP changes AX)
        _DROP                   ; pop new TOS
        TEST DI,DI              ; was old TOS zero?
        JNZ  @@n0_if_skip
        ADD  BX,CX              ; zero: take relative jump
        JMP  _next
@@n0_if_skip:
        JMP  _next              ; non-zero: skip (remaining nibbles = offset data)
@@n0_ifm:
        ; op = 10 (if-): decrement TOS; jump if >= 0
        MOV  CX,DX
        AND  CX,0FFFh
        JCXZ @@n0_abs
        TEST CX,0800h
        JZ   @@n0_ifm_se
        OR   CX,0F000h
@@n0_ifm_se:
        SHL  CX,1
        DEC  AX
        JS   @@n0_ifm_skip      ; negative: skip
        ADD  BX,CX              ; >= 0: take relative jump
        JMP  _next
@@n0_ifm_skip:
        JMP  _next
@@n0_jmp:
        ; op = 11 (jmp): unconditional relative jump
        MOV  CX,DX
        AND  CX,0FFFh
        JCXZ @@n0_abs
        TEST CX,0800h
        JZ   @@n0_jmp_se
        OR   CX,0F000h
@@n0_jmp_se:
        SHL  CX,1
        ADD  BX,CX
        JMP  _next
@@n0_abs:
        ; offset=0: absolute fallback -- re-derive nibble 0, dispatch through table
        MOV  CL,DH
        SHR  CL,1
        SHR  CL,1
        SHR  CL,1
        SHR  CL,1
        XOR  CH,CH
        SHL  CX,1
        MOV  DI,CX
        ADD  DI,OFFSET T_NANO
        CALL pw [DI]
        JMP  _next
@@n0_disp:
        ; Normal (non-jump) dispatch for nibble 0
        XOR  CH,CH
        SHL  CX,1
        MOV  DI,CX
        ADD  DI,OFFSET T_NANO
        CALL pw [DI]

        ;------------------------------------------------------
        ; Nibble 1: bits 11:8
        ;------------------------------------------------------
        MOV  CL,DH
        AND  CL,0Fh             ; CL = nibble 1 (bits 11:8)
        CMP  CL,9
        JB   @@n1_disp
        CMP  CL,11
        JA   @@n1_disp
        CMP  CL,11
        JE   @@n1_jmp
        CMP  CL,10
        JE   @@n1_ifm
        ; op = 9 (if): 8-bit offset in DL
        MOV  CL,DL
        XOR  CH,CH              ; CX = DL (bits 7:0)
        JCXZ @@n1_abs
        TEST CL,80h             ; test sign bit (bit 7)
        JZ   @@n1_if_se
        MOV  CH,0FFh            ; sign-extend negative
@@n1_if_se:
        SHL  CX,1
        MOV  DI,AX
        _DROP
        TEST DI,DI
        JNZ  @@n1_if_skip
        ADD  BX,CX
        JMP  _next
@@n1_if_skip:
        JMP  _next
@@n1_ifm:
        ; op = 10 (if-): 8-bit offset in DL
        MOV  CL,DL
        XOR  CH,CH
        JCXZ @@n1_abs
        TEST CL,80h
        JZ   @@n1_ifm_se
        MOV  CH,0FFh
@@n1_ifm_se:
        SHL  CX,1
        DEC  AX
        JS   @@n1_ifm_skip
        ADD  BX,CX
        JMP  _next
@@n1_ifm_skip:
        JMP  _next
@@n1_jmp:
        ; op = 11 (jmp): 8-bit offset in DL
        MOV  CL,DL
        XOR  CH,CH
        JCXZ @@n1_abs
        TEST CL,80h
        JZ   @@n1_jmp_se
        MOV  CH,0FFh
@@n1_jmp_se:
        SHL  CX,1
        ADD  BX,CX
        JMP  _next
@@n1_abs:
        ; offset=0: absolute fallback -- re-derive nibble 1, dispatch through table
        MOV  CL,DH
        AND  CL,0Fh
        XOR  CH,CH
        SHL  CX,1
        MOV  DI,CX
        ADD  DI,OFFSET T_NANO
        CALL pw [DI]
        JMP  _next
@@n1_disp:
        ; Normal (non-jump) dispatch for nibble 1
        XOR  CH,CH
        SHL  CX,1
        MOV  DI,CX
        ADD  DI,OFFSET T_NANO
        CALL pw [DI]

        ;------------------------------------------------------
        ; Nibble 2: bits 7:4
        ;------------------------------------------------------
        MOV  CL,DL              ; CL = bits 7:0
        SHR  CL,1               ;
        SHR  CL,1               ; CL = nibble 2 (bits 7:4)
        SHR  CL,1               ;
        SHR  CL,1               ;
        CMP  CL,9
        JB   @@n2_disp
        CMP  CL,11
        JA   @@n2_disp
        CMP  CL,11
        JE   @@n2_jmp
        CMP  CL,10
        JE   @@n2_ifm
        ; op = 9 (if): 4-bit offset in DL bits 3:0
        MOV  CL,DL
        AND  CL,0Fh
        XOR  CH,CH              ; CX = bits 3:0
        JCXZ @@n2_abs
        TEST CL,08h             ; test sign bit (bit 3)
        JZ   @@n2_if_se
        OR   CX,0FFF0h          ; sign-extend negative
@@n2_if_se:
        SHL  CX,1
        MOV  DI,AX
        _DROP
        TEST DI,DI
        JNZ  @@n2_if_skip
        ADD  BX,CX
        JMP  _next
@@n2_if_skip:
        JMP  _next
@@n2_ifm:
        ; op = 10 (if-): 4-bit offset in DL bits 3:0
        MOV  CL,DL
        AND  CL,0Fh
        XOR  CH,CH
        JCXZ @@n2_abs
        TEST CL,08h
        JZ   @@n2_ifm_se
        OR   CX,0FFF0h
@@n2_ifm_se:
        SHL  CX,1
        DEC  AX
        JS   @@n2_ifm_skip
        ADD  BX,CX
        JMP  _next
@@n2_ifm_skip:
        JMP  _next
@@n2_jmp:
        ; op = 11 (jmp): 4-bit offset in DL bits 3:0
        MOV  CL,DL
        AND  CL,0Fh
        XOR  CH,CH
        JCXZ @@n2_abs
        TEST CL,08h
        JZ   @@n2_jmp_se
        OR   CX,0FFF0h
@@n2_jmp_se:
        SHL  CX,1
        ADD  BX,CX
        JMP  _next
@@n2_abs:
        ; offset=0: absolute fallback -- re-derive nibble 2, dispatch through table
        MOV  CL,DL
        SHR  CL,1
        SHR  CL,1
        SHR  CL,1
        SHR  CL,1
        XOR  CH,CH
        SHL  CX,1
        MOV  DI,CX
        ADD  DI,OFFSET T_NANO
        CALL pw [DI]
        JMP  _next
@@n2_disp:
        ; Normal (non-jump) dispatch for nibble 2
        XOR  CH,CH
        SHL  CX,1
        MOV  DI,CX
        ADD  DI,OFFSET T_NANO
        CALL pw [DI]

        ;------------------------------------------------------
        ; Nibble 3: bits 3:0 -- no jump detection (no remaining bits)
        ;------------------------------------------------------
        MOV  CL,DL
        AND  CL,0Fh             ; CL = nibble 3 (bits 3:0)
        XOR  CH,CH
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
; Encoding: cell must be odd (bit 0 = 1); cell-1 holds 4 nibbles,
; MSB-first: nibble0=bits15:12, nibble1=bits11:8, nibble2=bits7:4,
; nibble3=bits3:0.
;
; NANO_TEST_CELL encodes nibble0=DUP(2), nibble1=;(8), nibbles2-3=0:
;   cell-1 = (2<<12)|(8<<8)|(0<<4)|0 = $2800
;   cell   = $2801
;======================================================================
NANO_START  label  byte
        DW  2801H               ; nibble0=DUP(2), nibble1=;(8)

MyCseg  ends
        end  Start
