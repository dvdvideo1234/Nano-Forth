;======================================================================
; n86_386_opt.asm  -- Nano-Forth VM (COM, 80386 optimized)
;======================================================================

.386

;----------------------------------------------------------------------
; Macros
;----------------------------------------------------------------------

X   MACRO
  XCHG SP,BP
ENDM

RPUSH MACRO REG
  X
  push REG
  X
ENDM

RPOP MACRO REG
  X
  pop REG
  X
ENDM

ALIG1 MACRO
  IF ($-@_START+1) AND 1
    NOP
  ENDIF
ENDM

DEFW MACRO NAM
  DW  N_&NAM
I_&NAM = CNT
  CNT = CNT+1
ENDM

PACKW MACRO N3,N2,N1,N0
  LOCAL ACC
  IF (N0) AND 1
    CAN'T PACK  NIBBLE_&N0
  ENDIF
  ACC = ((N3)*1000H)+((N2)*100H) + ((N1)*10H) + (N0) + 1
  DW ACC
ENDM

_NANO_ MACRO
  ALIG1
  CALL  _NANO
ENDM

AREG  = di
NIBTMP= DX
NIBI  = CX

CNT   = 0
;----------------------------------------------------------------------
; SEGMENT (COM)
;----------------------------------------------------------------------

MyCseg  segment  para use16
        assume   cs:MyCseg, ds:MyCseg, ss:MyCseg

        org 100h

@_START:
        jmp @_NANO_INIT

;----------------------------------------------------------------------
_NANO:
        pop si
        jmp short @MAIN

;----------------------------------------------------------------------
; Dispatch table
;----------------------------------------------------------------------

align 2                    ; INDEX (CODE) OF NIBBLE
@_NANO label word          ; DEC  HEX NAME   SOME_EXTRAS
  DEFW    JMP              ;  0    0  (JMP   (EFECTIVE NOP/NOPS)
  DEFW    P2DIV            ;  1    1  (+2/   (EFECTIVE SUM & AVERIGE)
  DEFW    RDROP            ;  2    2  (RDROP
  DEFW    NAND             ;  3    3  (NAND
  DEFW    IF               ;  4    4  (IF    (EFECTIVE DROP)
  DEFW    J                ;  5    5  (J
  DEFW    DUP              ;  6    6  (DUP
  DEFW    POP              ;  7    7  (POP
  DEFW    IFM              ;  8    8  (IF-   (EFECTIVE 1-)
  DEFW    RSTORE           ;  9    9  (!R+
  DEFW    PUSH             ; 10    A  (PUSH       
  DEFW    RFETCH           ; 11    B  (@R+        
  DEFW    RET              ; 12    C  (;          
  DEFW    XR               ; 13    D  (XR         
  DEFW    XA               ; 14    E  (XA
  DEFW    ESC              ; 15    F  (4TH> TRANSFER CONTROL FROM NANO TO REAL MASHINE
  
_END_ = 0F001H

;-------------------------------------------------------------
;     INSTRUCTION MATRIX
;
;           JMP     +2/     RDROP   NAND   
;           IF      J       DUP     POP    
;           IF-     !R+     PUSH    @R+    
;           ;       XR      XA      4TH>   
;

;----------------------------------------------------------------------
; DATA
;----------------------------------------------------------------------

;@_NIBTMP  dw 0
;@_NIBI    dB 0,0        ; NIBBLE INDEX IN BITS

;----------------------------------------------------------------------
@_NEST:
  xchg ax,si
  RPUSH ax
  jmp short @MAIN

;======================================================================
; PRIMITIVES
;======================================================================

N_ESC:          ; TRANSFER CONTROL FROM NANO TO REAL MASHINE 
  jmp si

;----------------------------------------------------------------------
align 2
_XOR:           ; NOT NIBBLE BUT WORD
  dw  _END_    ; N_ESC  TRANSFER CONTROL FROM NANO TO REAL MASHINE 
  pop ax
  pop cx
  xor ax,cx

  push ax

;----------------------------------------------------------------------
N_RET:
  MOV si,[BP]
  INC   BP
  INC   BP
  jmp short @MAIN

;----------------------------------------------------------------------
N_IF:
  pop Ax
  or  AX,AX
  jz  N_JMP
  jmp short @MAIN

N_IFM:
  pop ax
  dec ax
  push ax
  js  short  @MAIN

;----------------------------------------------------------------------
N_JMP:
  jcxz @MAIN
;  mov ax,@_NIBTMP
  SUB CL,4
  xor cl,12
  shl Dx,cl
  sar Dx,cl
  add si,Dx

@MAIN:
  lodsw
  test al,1
  je @_NEST
  dec ax
  mov NIBTMP,ax
  mov NIBI,12

;----------------------------------------------------------------------
@_NIBDISPATCH:    ; --- nibble decode (386 optimized) ---
;  mov CX,WORD PTR @_NIBI
  mov bX,NIBTMP
  SHR BX,CL
  AND BX,15
  shl BX,1
  jmp [bx+@_NANO]
@_NIBDISP = $-2

;======================================================================
; EXEC
;======================================================================

N_P2DIV:
  pop Bx
  pop ax
  add ax,Bx
  mov Bx,ax
  rcr ax,1
@PHBX:
  push Bx
@PHAX:
  push ax

@_NIBDONE:
  SUB CL,4
  jns @_NIBDISPATCH
  jmp @MAIN

;----------------------------------------------------------------------
N_RDROP:
  INC   BP
  INC   BP
  jmp short @_NIBDONE

;----------------------------------------------------------------------
N_NAND:
  pop ax
  pop Bx
  and ax,Bx
  not ax
  jmp @PHAX

;----------------------------------------------------------------------
N_PUSH:
  pop ax
  RPUSH ax
  jmp @_NIBDONE

;----------------------------------------------------------------------
N_POP:
  RPOP ax
  jmp @PHAX

;----------------------------------------------------------------------
N_DUP:
  pop ax
  push ax
  jmp @PHAX

;----------------------------------------------------------------------
N_J:
  push word ptr [bp+2]
  jmp @_NIBDONE

;----------------------------------------------------------------------
N_RFETCH:
  xchg si,[bp]
  lodsw
  xchg si,[bp]
  jmp @PHAX

;----------------------------------------------------------------------
N_RSTORE:
  pop ax
  xchg DI,[bp]    ; AREG = DI
  stosw

N_XA:
  xchg DI,[bp]
  jmp @_NIBDONE

;----------------------------------------------------------------------
N_XR:
  pop ax
  xchg ax,[bp]
  jmp @PHAX

;======================================================================
; INIT
;======================================================================

@_NANO_INIT:
  cld
  ;mov AREG,0
  mov bp,0FFFEh
  mov sp,0EFFEh
  ;MOV AX,OFFSET @_NANO
  ;MOV WORD PTR @_NIBDISP,AX

  _NANO_    ; TEST
  dw  _LIT,1,_NOT,_DUP,_1M,_SWAP,_XOR
  DW  _END_
  INT   20H

_LIT:
  ;DW  0BC01H     ; (@R+ (;
  PACKW   I_RFETCH,I_RET,0,0
_NEG:
  PACKW   I_IFM,0,0,0
_NOT:
  ;dw  63C1H     ; (DUP (NAND (;
  PACKW   I_DUP,I_NAND,I_RET,0
_DUP:
  PACKW   I_DUP,I_RET,0,0
_SWAP:
  PACKW   I_PUSH,I_XR,I_POP,I_RET
_1M:
  PACKW   I_IFM,0,0,0
_NOP:
  PACKW   I_RET,0,0,0

MyCseg ends
end @_START