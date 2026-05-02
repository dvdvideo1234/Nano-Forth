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

_NANO_ MACRO
  ALIG1
  CALL  _NANO
ENDM

AREG = di

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

align 2
@_NANO label word
  dw N_JMP
  dw N_P2DIV
  dw N_XOR
  dw N_NAND
  dw N_IF
  dw N_J
  dw N_DUP
  dw N_POP
  dw N_IFM
  dw N_RSTORE
  dw N_PUSH
  dw N_RFETCH
  dw N_RET
  dw N_XR
  dw N_XA
  dw N_ESC

;----------------------------------------------------------------------
; DATA
;----------------------------------------------------------------------

@_NIBTMP  dw 0
@_NIBI    dB 0,0        ; NIBBLE INDEX IN BITS

;----------------------------------------------------------------------
; ESC
;----------------------------------------------------------------------

N_ESC:
  jmp si

;======================================================================
; PRIMITIVES
;======================================================================

N_IFM:
  pop ax
  dec ax
  push ax
  js  short  @MAIN

;----------------------------------------------------------------------
N_JMP:
  jcxz @MAIN
  mov ax,@_NIBTMP
  SUB CL,4
  xor cl,12
  shl ax,cl
  sar ax,cl
  add si,ax
  jmp short @MAIN

;----------------------------------------------------------------------
N_IF:
  pop Ax
  or  AX,AX
  jz  N_JMP
  jmp short @MAIN

;----------------------------------------------------------------------
N_RET:
  RPOP si
  jmp short @MAIN

;----------------------------------------------------------------------
@_NEST:
  xchg ax,si
  RPUSH ax

@MAIN:
  lodsw
  test al,1
  je @_NEST
  dec ax
  mov @_NIBTMP,ax
  mov @_NIBI,12

;----------------------------------------------------------------------
@_NIBDISPATCH:    ; --- nibble decode (386 optimized) ---
  mov CX,WORD PTR @_NIBI
  mov bX,@_NIBTMP
  SHR BX,CL
  AND BX,15
  shl BX,1
  jmp @_NANO[bx]

;======================================================================
; EXEC
;======================================================================

N_P2DIV:
  pop cx
  pop ax
  add ax,cx
  mov cx,ax
  rcr ax,1
@PHCX:
  push cx
@PHAX:
  push ax

@_NIBDONE:
  SUB @_NIBI,4
  jns @_NIBDISPATCH
  jmp @MAIN

;----------------------------------------------------------------------
N_NAND:
  pop ax
  pop cx
  and ax,cx
  not ax
  jmp @PHAX

;----------------------------------------------------------------------
N_XOR:
  pop ax
  pop cx
  xor ax,cx
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
  xchg AREG,[bp]
  stosw

N_XA:
  xchg AREG,[bp]
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
        xor AREG,AREG
        mov sp,0FFFEh
        mov bp,0EFFEh

  _NANO_
;  dw 6C01h

MyCseg ends
end @_START