        INCLUDE  NF70.i0

; REGISTERS
; BX INSTRUCTION POINTER
; SI DATA STACK POINTER
; SP RETURN STACK POINTER
; AX DATA STACK TOP REGISTER
; cx WORK REGISTER
; di temp register

ip   = si        ; for interpretter
w    = di
dsp  = SI
rsp  = sp
top  = bx
ar   = dx
t    = cx
tl   = cL
topL = bL
th   = ch
toph = bh

NBASE = di
NACC  = bx


MyCseg  segment para  use16

        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg, es: MyCseg

        org 100h

@TBUF   = -256          ;  256
@TIB    = @TBUF  * 2    ;  256
                        ;  512 B FSTACK
@R_TOP  = @TIB   * 2    ; 1024 B RSTACK
@S_TOP  = @R_TOP * 2    ; 2048 B DSTACK
@VOCTOP = @S_TOP * 2    ; 4096 B = 4 BUFFERS * 1024 B

Start   Label byte
  mov   bx,1000h     ; only 64k allocate
  mov   ah,4ah
  int   21h
@ABORT:
  MOV   RSP,@R_TOP
  MOV   DSP,@S_TOP
  __C  @RETURN


;------------  inner INTERPRETTER ----
; CONTROL      COMMANDS
; xep ex exit execute nop skip zskip
; -if if jump f>c f>c; 0;

@0x:
  or    top,top
  jz    @dropx
  jmps  @drp

@_defero:
  ;inc   pw @CNTC
  jmps  @_defer

@does:
  mov   TOP,w
  d_to  w
  jmps  @NEST

@ex:
  r_to  w
  jmps  @NEST

@_setpnt:
  mov   [w],ip
  JMPs  @return

@_POINT:
  mov   w,[w+2]
  jmps  @nest

@retcal:
  d_to  ar
  d_to  ip
  x
@drp:
  drop
  jmps  @main

@swapx:         ; skip
  d_to  w
  ddup
  to_d  w
  skipa

@nipx:          ; nip
  d_to  w
  skipb

@dropx:         ; drop
  drop

@return:        ; exit
  r_to  ip
  JMPs  @main

@ANDX:
  AND   TOP,[IP]
  JMPS  @RETURN

@NESTz:
  sub   w,3
@NEST:
  xchg  w,ip
@rpush:
  x
  to_d  w
@x: x
  JMPs  @MAIN

@perform:
  pop   w
  Rchg  w
  skipa

@_defer3:
  w2p
@_defer2:
  w2p
@_defer:
  mov   t,[w]
  SKIPA

@exec:
  pop   t
  Rchg  t
  jcxz  @MAIN
  MOV   W,T
  jmps  @exec0

@stm:
  pop   pw [top-2]
@2m:
  dec   top
@1m:
  dec   top
  jmps  @main

@ldpb:
  xor   t,t
  mov   tl,[top]
  to_d  t
  jmps  @1p

@stpb:
  pop   t
  mov   [top],tl
  jmps  @1p

@stp:
  pop   pw [top]
  skipa
@ldp:
  push  pw [top]
@2p:
  inc   top
@1p:
  inc   top
  jmps  @main

; LOGICAL      COMMANDS  XOR AND not

@sub:
  neg   top
@add:
  d_to  t
  add   top,t
  jmps  @drop

@andc:
  mov   t,[w]
  skipb
@and:
  d_to  t
  and   top,t
  jmps  @drop

@xor:
  d_to  t
  xor   top,t
  jmps  @drop

@xchg:
  mov   w,rsp
  skipr cx

@swap:
  mov   w,dsp
  xchg  [w],top
  jmps  @main

@DUP:
  ddup
  jmps  @main

@ij:
  mov   w,[w]
  add   w,rsp
  skipr cx

@_CONS3:
  w2p
@_CONS2:
  w2p
@_CONS:
  mov   w,[w]
  skipa

@_VAR3:
  w2p
@_VAR2:
  w2p
@_VAR:

@PUSHW:
  ddup
@set:
  mov   TOP,w

; MAIN  LOOP  INNER INTERPRETTER

@MAIN:
  mov   w,[ip]
  cmpsw
@exec0:
  test  w,1
  Jnz   @NESTz
  JMP   [w-2]

@swapst:
  d_to  w
  skipa

@_SETVAR3:
  w2p
@_SETVAR2:
  w2p
@_SETVAR:
  mov   [w],top
@drop:          ; drop
  drop
  jmps  @main

@for:           ; for
  MOV   IP,[IP]
@push:          ; push
  d_to  w
  xchg  w,top
  jmps  @rpush

; ---------------------------------------

@ZSKIP:
  or    top,top
  jnz   @main
  drop
  jmps  @skip

@next:
  mov   w,rsp
  dec   pw [w]
  skipr w
@ifm:
  inc   top
@ifm1:
  dec   top
  Js    @SKIP

@JUMP:
  MOV   IP,[IP]
  JMPS  @MAIN

@ifd:
  ddup
@if:
  or    top,top
  drop
  jz    @jump
  jmps  @skip

@lit:
  ddup
  mov   top,[ip]
@SKIP:
  INC   IP
  INC   IP
  JMPs  @MAIN

@_LARY:
   SHL  top,1
@_WARY:
   SHL  top,1
@_BARY:
   add  top,w
   jmps @main

@pop:
  ddup
  x
  drop
  x
  skipa

@rdrop:
  inc   rsp
  inc   rsp
@MAIN2:
  JMPs  @MAIN

@0SWAP:
  xor  cx,cx
  push  cx
  JMPs  @MAIN2

@intcal:
  d_to  cx
  ddup
  x
  to_d  ip
  to_d  ar
  mov   top,offset @retcal
  ddup
  x
  jmp   cx

@_dos@4:
  ddup
@_dos@3:
  ddup
@_dos@2:
  ddup
@_dos@1:
  ddup
@_dos:
  call @intcal
  pop  si
  pop  bx
  pop  cx
  pop  dx
  x
  rchg si
  push si
  CALL W
  mov  sav_ax,ax
  mov  sav_dx,dx
  RCL  Bx,1
  mov  sav_fx,Bx
  pop  top
  ret

@_mover:
  call @intcal
  pop  cx
  pop  bx
  pop  si
  x
  xchg bx,di
  jmp  bx

@_math1:
  ddup
@_math:
  call @intcal
  pop  cx
  pop  dx
  pop  si
  x
  rchg si
  jmp  di

  __L  _ANDX,@ANDX

  __W  _SGN
    DW _ANDX,8000H

  __l  _cmove,@_mover
@movd:
  rep  movsb
  cld
  ret

  __l  _cmoveu,@_mover
@movu:
  add  di,cx
@pushu:
  add  si,cx
  std
  jmps @movd

  __l  _move,@_mover
  cmp  si,di
  jb   @movd
  jmps @movu

sav_ax dw 0
sav_dx dw 0
sav_fx dw 0

  __l _udiv,@_math
  cmp  dx,cx
  jnb  @@1
  div  cx
@@1:
  rchg dx
@__setmath:
  rchg si
  x
  push si
  push dx
  x
  ret

  __l _ZEQ,$         ; 0=
  SUB   top,1
@CF:
  cf_to top
  JMP   @MAIN

  __l _uless,$
  pop  t
  sub  t,top
  jmps @cf

  __l _umul,@_math1
  mul  dx
  jmps @__setmath

  __l _@@key,@_dos@4,800h
  __w _key,_@@key,_w_b,_exit

  __l _emit,@_dos@3,200h
  __l _ex,@ex
  __l _1m,@1m
  __l _w_b,@andc,255
  __l _w_b7,@andc,7
  __l _m1,@_cons,-1
  __l _lf,@_cons,10
  __l _bl,@_cons,' '
  __l _dup,@dup
  __l _and,@and
  __l _exit,@return
  __l _zskip,@zskip
  __l _skip,@skip
  __l _add,@add
  __l _xor,@xor
  __l _lit,@lit
  __l _lt0,@_cons,'0'
  __l _ifm,@ifm
  __l _if,@if

  __w _abs
    dw _ifm,@@not
  __w _neg
    dw _1m
  __w _not
@@not:
    dw _m1,_xor
    dw _exit

  __w _xspc
     dw _ex
  __w _space
     dw _bl,_emit,_exit

  __w _DIGP
        DW _ALPHA,_EMIT,_EXIT

  __w _ALPHA  ; : ALPHA  LF OVER U< 7 AND + '0 + ;
        DW _DUP,_LF,_ULESS,_ZEQ,_w_b7,_ADD,_LT0,_ADD,_EXIT

; __XT  _ZSKIP,@?SKIP
;        DW @_DUP,_ZEQ,_ZEX,_DROP,_RLDP,_DROPX

  __w _HP
        DW _DUP,_SGN,_IF,@@NOSGN,_LIT,'-',_EMIT,_ABS
@@NOSGN DW _SKIP
  __w _UNP
        DW _XSPC,_SKIP
  __w _HP2
        DW _LF,_UDIV,_ZSKIP,_HP2,_DIGP,_EXIT


freemem:
  DW ENDMEM-FREEMEM-2
  ;__ENTRY  '=:',_ENTRY
  DB 0
EndMem:

lastw = ppppp

MyCseg  ends
        end  Start

