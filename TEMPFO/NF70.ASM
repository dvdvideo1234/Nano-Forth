; _1P,  _2DIV,  _A@P,   _ADD,   _AND,   _DROPX, _DUP,   _EXIT
; _FOR, _I,     _IF,    _IFM,   _IFM1,  _J,     _JPDROP,_JUMP
; _NIPX, _NOP,  _POP,   _PUSH,  _RDROP, _RLDP,  _RLDPB, _ZSKIP
; _RSTP, _RSTR, _SKDROP, _SUB,  _SWAPX, _UDIV,  _ULESS, _XCHG
; _XOR,  _ZEQ,  _NEXT,  _STAP,  _DROP,  _2P,    _1M,    _2M

; +2/ u2/ and drop dup ; (0br (-br (br. (br
; 2DIV; ADD2D; AND; DROP; DUP; EXIT; IF; IFM; JPDROP; JUMP
; (next pop push rdrop dropsk skip !+ xchg xor 0.skip
; NEXT; POP; PUSH; RDROP; SKDROP; SKIP; STP; XCHG; XOR; ZSKIP
; @+ !- 1+ 2+ 1- 2- c!+ c@+




        INCLUDE  NF70.i0

; REGISTERS
; i    INSTRUCTION POINTER
; d    DATA STACK POINTER
; r    RETURN STACK POINTER
; t    DATA STACK TOP REGISTER
; a    arith/adrs register  - scratch
; w    word register  = scratch
; c    count register - scratch

i    = si       ; for interpretter
r    = bp
d    = sp
t    = di
a    = dx       ; arith register
c    = cx
w    = ax
wl   = aL
wh   = ah

NBASE = di
NACC  = bx


MyCseg  segment para  use16

        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg, es: MyCseg

        org 100h

@TBUF   = -256          ;  256
@TIB    = @TBUF  * 2    ;  256
                        ;  512 B FSTACK
@R_TOP  = @TIB   * 2    ; 1024 B RSTACK
@D_TOP  = @R_TOP * 2    ; 2048 B DSTACK
@VOCTOP = @D_TOP * 2    ; 4096 B = 4 BUFFERS * 1024 B

Start   Label byte

;        JMPS SELF0

; __W _OPERATION
;        DW _WARY,_NUMBER,_EXEC        ; INTERPRET
;        DW _COMP_NUM,_COMMA     ; COMPILE
;
;;  __DEFER  _ACCEPT,_ACC
;  __DEFER  _OK,0
;  __DEFER  _ERROR,0
;;  __DEFER  _OK,_@OK
;;  __DEFER  _ERROR,_@ERROR
;
;  __CONST _@SOURCE,@_SOURCE   ;_ETIB
;  __CONST  _TBL,80H
;  __CONST  _TIB,@TIB
;  __CONST  _TBUF,@TBuf
;  __CONST  _0,0
;_BYE    = $-1   ; JMP TO 0
;
;  __CONST  _BL,32
;
;  __POINT  _INIT,_@_INI
;  __VALUE  _HERE,FREEMEM
;  __VALUE  _ETIB,0
;  __VALUE  _LTIB,0
;  __VALUE  _DICT,@VOCTOP*2
;  __VALUE  _CNTC,0
;@CNTC   = $-2
;  __value  _stat,0
;
;------------  MAIN LOOP  OUTER INTERPRETTER ----

SELF0:
  mov   bx,1000h     ; only 64k allocate
  mov   ah,4ah
  int   21h
@ABORT:
  mov   r,offset @R_TOP
  mov   d,offset @D_TOP
 __C   @RETURN
  dw   _lit,128,_dup,_accept;_e_bl
; dw   _lit,128
; dw   _type ; ,_e_bl
  dw   _e_bl,_tpstr
 __nam2 "proba"

  dw _bye

 __l _abort
  jmps  @abort

 __w _q
  dw  _cemit
 __w _cq
  dw  _litx,'?'

 __w _execute
  dw  _go

 __W _md_LOOPS
  dw  _0swap,_sta,_lit,16
 __W _LOOPS
  DW  _FOR,@@2
@@1:    DW _J,_EXECUTE
@@2:    DW _NEXT,@@1,_RDROP,_RDROPX

 __w _inlstr
  dw  _astr,_exit

 __w _tpstr
  dw  _astr
 __w _tcstr
  dw  _cstr
 __w _type
  dw  _nipa,_loops,_cld@p,_emit,_exit

 __W _@KEY
  DW  _litx2,_setv
 __W _KEY
  DW  _@KEYD,_EXIT

 __W _@EMIT
  DW  _litx3,_setv2
 __W _EMIT
  DW  _nop,_@EMITD
 __w _nop
  dw  _EXIT

 __w _eq?               ; =?
  dw  _over
 __w _eq_to?            ; =to
  dw  _over
 __w _eq                ; =
  dw  _xor
 __w _zeq               ; 0=
  dw  _nif,@m1
 __w _0                 ; 0
@0:
  dw  _litx2
 __w _m1                ; -1
@m1:
  dw  _litx2
 __w _bye               ; bye
  dw  0,-1

@ac_cr:  dw  _dup,_sta,_exit
@ac_bs:  dw  _eq?,_0x,_1m,_tpstr
         db  3,8,32,8
         dw  _exit
@ac_oth: dw  _dup,_emit,_swap,_stpb,_exit

 __w _ac_tab
  dw  _do_tab
  db  2,8,13,0
  dw  @ac_oth,@ac_bs,@ac_cr

 __w _accept
  dw _over,_add,_sta,_dup
@@acc1:
  dw _key,_ac_tab,_lda,_eq_to?,_nif,@@acc1
 __w _overm
  dw  _over
 __w _sub
  dw  _neg
 __w _add
  dw  _add2d,_dropx

 __l _cemit
 __d @does2
 __w _c@emit
  dw  _cstr,_emit
  dw  _dropx

 __w _e_bl
  dw  _cemit
 __w _bl
  dw  _litx,32

 __W _UMMUL
  DW  _md_loops,_MULAD,_EXIT

 __W _UMDIVM
  DW  _md_loops,_DIVSUB,_EXIT

; __w _accept
;  dw  _push
; : (ACC  PUSH 0
;  BEGIN KEY
;    CASE
;      cr OF DUP XCHG DROP ENDOF
;      bs OF DUP IF 1- TO bs  SPACE  TO bs THEN  ENDOF
;      PUSH  I bl &BYTE WITHIN
;       IF 2DUP + I SWAP C! 1+  I EMIT THEN POP
;    ENDCASE
;  DUP I = UNTIL RDROP ;

;------------------------------------------------

 __l _@rldp             ; @r+
  call  @rptr
  lodsw
  rchg  t
  ret

 __l _astr              ; (str
  call  @rptr
@astr:
  xor   w,w
  mov   t,i
  lodsb
  mov   c,w
  or    wl,1
  add   i,w
  ret

 __L _litx2
  jmps  @litx2
 __L _litx3
  lodsw
@litx2:
  lodsw
 __L _litx
  lodsw
@pushwx:
  ddup
  xchg  t,w
@exit2:
  jmps  _exit

 __L _SETV3
  i2    i
 __l _SETV2
  i2    i
 __l _SETV
  mov   [i],t
  jmps  _dropx

;------------  inner INTERPRETTER ----
; CONTROL      COMMANDS
; xep ex exit execute nop skip zskip
; -if if jump f>c f>c; 0;

 __L _STMb
  d_to  w
  mov   [T-1],wl

 __L _1M
  JMPS  @1M

 __L _STM
  POP   PW [T-2]

 __L _2M
  DEC   T
@1M:
  DEC   T
  JMPS  _MAIN

 __L _abs
  OR    T,T
  JNS   @MAIN1

 __L _NEG
  DEC   T

 __L _NOT
  NOT   T
@MAIN1:
  JMPS  _MAIN

 __L _nipx
  D_to  w
  SKIPB

 __L _DROPx
  DROP
  SKIPR c

 __l _rDROPx
  i2    r

 __l _exit        ; exit
  mov   i,[r]
  jmps  _rdrop
@does3:
  i2    i
@does2:
  i2    i
@does:
  mov   t,i
@return:
  d_to  i
  jmps  _main

 __l _xchg
  xchg  t,[r]
  skipb

 __L _DuP
  ddup
  skipr c

 __L _STP
  d_to  w
  stosw
  JMPS  _MAIN

 __l _nipa
  pop   a
  JMPS  _MAIN

@rptr:
  pop   c
  ddup
  xchg  i,[r]
  call  c

 __l _ex
  xchg  i,[r]
  skipr c

 __L _STPB
  d_to  w
  stosb
  JMPS  _MAIN

 __L _LDP
  PUSH  PW [T]

 __L _2P
  INC   T
@1P:
  INC   T
  JMPS  _MAIN

 __L _1P
  JMPS  @1p

 __l _and
  d_to  w
  and   t,w
  jmps  _main

 __l _0
  ddup
  ddup

 __l _xor
  d_to  w
  xor   t,w
  jmps  _main

 __l _for
  mov   I,[I]

 __l _push
  d_to  w
  xchg  w,t
  skipr c   ; jmps @rpush

@NESTz:
  dec   w
@NEST:
  xchg  w,i
@rpush:
  to_r  w
  JMPs  _MAIN

; LOGICAL      COMMANDS  XOR AND not

 __l _add2d
  d_to  w
  add   t,w
  to_d  t

 __l _2div
  rcr   t,1
  jmps  _main

; MAIN  LOOP  INNER INTERPRETTER

 __l _go
  mov   i,t
  jmps  @drop

 __L _pop
  ddup
  MOV   T,[R]

 __l _rDROP
  i2    r

 __l _MAIN
  lodsw
  test  wl,1
  Jnz   @NESTz
  JMP   w
@JPDROP:
  drop

 __l _jump
  MOV   I,[I]
  JMPS  _MAIN

 __L _ZSKIP
  or    t,t
  jnz   _main
_SKDROP:
  drop
@skip:
  lodsw
  JMPS  _MAIN

 __L _NEXT
  DEC   PW [R]
  skipr c

 __l _nifm
  inc   t
@ifm1:
  dec   t
  Jns   _jump
_skip:
  JMPS  @SKIP

 __l _nifm1
  jmps  @ifm1

 __l _nifd
  ddup
 __l _nif
  or    t,t
  JNZ   _SKDROP
_JPDROP:
  JMPS  @JPDROP

 __l _0x
  or    t,t
  jz    @drop
 __a 1
  skipa

 __l _at                ; @
  mov   t,[t]
  jmps  _main

 __l _j                 ; j
  ddup
  mov   T,[R+2]
  JMPS  _main
@drop:
  drop
  jmps  _main

 __l _lda               ; a@
  mov   w,a
  jmps  _pushw

 __L _@EMITD
  push  dx
  MOV   DX,T
  MOV   AH,2
  INT   21H
  pop   dx
_drop:
  JMPS  @drop

 __L _@KEYD
  MOV   AH,8
  INT   21H

 __l _pushb
  MOV   wH,0
  JMPS  _PUSHW

 __L _swap
  d_to  w
  skipb

 __L _LIT
  LODSW
  skipr c

 __L _over
  d_to  w
  to_d  w

 __l _pushw
  ddup
  xchg  w,t
  JMPS  _main

 __l _ZEQ?
  ddup
@ZEQ:
  SUB   t,1
@CF:
  cf_to t
  JMPs  _MAIN

 __l _ZEQ
  jmps  @ZEQ

 __L _ZLESS
  SHL   t,1
  jmps  @CF

 __L _cstr
  MOV   w,[T]
  inc   t
  jmps  _pushb

 __L _cST@P
  XCHG  w,T
  XCHG  T,A
  STOSB

 __l _sta
  XCHG  a,t
  JMPS  @drop

 __L _cLD@P
  XCHG  I,A
  LODSB
  XCHG  I,A
  JMPS  _pushb

 __l _do_tab
  push  t
  call  @astr
  pop   w
  add   t,c
  std
  repne scasb
@do_tabx:
  cld
  mov   t,c
  push  w
  jne   _jtable
  pop   w
  inc   t

 __l _jtable
  shl   t,1

 __l _jrel
  add   i,t
  JMP   @JPDROP

 __L _MULAD     ;  1 AR AND IF T ADD THEN U2/ ;
  POP   w
  TEST  wL,1
  JE    @MUL
  ADD   T,A
@MUL:
  RCR   T,1
  RCR   w,1
  JMPs  @DIV

 __L _DIVSUB    ;  1 AR AND IF T ADD THEN U2/ ;
  POP   w
  SHL   w,1
  RCL   T,1
  CMP   T,A
  JB    @DIV
  SUB   T,A
  INC   w
@DIV:
  PUSH  w
  JMP   _MAIN

 __l _0swap
  xor   w,w
  jmps  @div

freemem:
  DW ENDMEM-FREEMEM-2
  ;__ENTRY  '=:',_ENTRY
  DB 0
EndMem:

lastw = ppppp

MyCseg  ends
        end  Start

;  xor   w,w
;  push  t
;  lodsb
;  push  w
;  push  i       ; search table start
;  mov   c,w
;  or    wl,1    ; align
;  add   i,w     ; table start
;  add   i,c
;  add   i,c     ; after table end
;  xchg  t,w
;  pop   t
;  rep   scasb
;  pop   t
;  jne   _drop
;  pop   w
;  not   c
;  mov   t,c

; __L @_VAR3
;  ip2p
;@_VAR2:
;  ip2p
;@_VAR:
;  DDUP
;  mov   top,ip
;  jmp   _exit; @return
;
;  __l _uless
;  pop   t
;  sub   t,top
;  jmps @cf
;
; __L _LDA
;  jmps  @LDA
;
; __l _ZEQ
;  SUB   top,1
;  SKIPR T
;
; __L _ZLESS
;  SHL   top,1
;@CF:
;  cf_to top
;  JMPs   @MAIN
;
; __L _STA
;  MOV   T,W
;  JMPS  @PUSHW
;
;@LDA:
;  MOV   W,TOP
;  skipr c
;
; __L _STAPB
;  RCHG  TOP
;  STOSB
;  jmp  _DROP
;
; __l _LDap
;@_ld:
;  mov   t,[w]
;  w2p
;@PUSHW:
;  ddup
;  rchg  TOP
;  jmps  @main

; __l _swapx
;  d_to  t
;  xchg  top,t
;  to_d  t
;  JMPS  _exit; @RETURN
;
; __l _nipx
;  d_to  T
;  JMPS  _exit; @RETURN
;
; __L _SETPNT
;  mov   T,[R]
;  mov   [IP],T
;  jmp _RDROPx
;
; __L _dropx
;  drop
;  skipa
;
;  __l _RDROPx
;  rp2P
;

; __L _LARY
;  SHL   TOP,1
;
; __L _WARY
;  SHL   TOP,1
;
; __L _BARY
;  ADD   TOP,IP
;@RET:
;  jmps  _exit; @return

;__l _ifm1
; JMPS @ifm1

; __L @_DEFER3
;  IP2P
; __L @_DEFER2
; __L @_POINT
;  IP2P
; __L @_DEFER
;  MOV   CX,[IP]
;  JCXZ  @RET

;@s8:    JMPS @s0
;@s7:    JMPS @s0
;@s6:    JMPS @s0
;@s5:    JMPS @s0
;@s4:    JMPS @s0
;@s3:    JMPS @s0
;@s2:    JMPS @s0
;@S0:    SUB  T,OFFSET @S0+2
;        ADD  T,PW FPTR
;        RCHG TOP
; __L _PSTORE
;        MOV  [TOP],T
;        JMP _DROP
;
;@G8:    JMPS @G0
;@G7:    JMPS @G0
;@G6:    JMPS @G0
;@G5:    JMPS @G0
;@G4:    JMPS @G0
;@G3:    JMPS @G0
;@G2:    JMPS @G0
;@G0:    SUB  T,OFFSET @G0+2
;        DDUP
;        ADD  T,0
;FPTR    = $-2
;        RCHG TOP
; __L _FETCH
;        MOV  TOP,[TOP]
;        JMP @MAIN
;
; __L _LOCALS
;        DDUP
;        LODSW
;        XCHG AX,BX
;        LEA  AX,[R-2]
;        XCHG PW FPTR,AX
;        X
;        PUSH AX
;        XOR  AX,AX
;        XCHG AL,BH
;        MOV  DI,BX
;        ADD  DI,DI
;        LEA  CX,[R+DI]
;        JZ   @@2
;@@1:    DEC  DI
;        DEC  DI
;        PUSH [R+DI]
;        JNZ  @@1
;        MOV  R,CX
;@@2:    MOV  CX,BX
;        JCXZ L@@4
;@@3:    PUSH DI
;        LOOP @@3
;L@@4:   X
;        JMP  _DROP
;
; __L _LOCALX
;        MOV  R,PW FPTR
;        MOV  T,[R]
;        MOV  PW FPTR,AX
;        JMP  @MAIN

; __W _TLD
;  DW _TLDP
; __W _DROP
;  DW _DROPX
;
; __W _WCSTR
;  DW  _LDA,_TLDPB,_STA,_EXIT
;
; __W _STR
;  DW _TLDP
; __W _SWAP
;  DW _SWAPX
;
; __W _CSTR
;  DW _TLDPB,_SWAPX
;
; __W _EX
;  DW  _POP,_XCHG
; __W _EXECUTE
;  DW  _PUSH,_EXIT
;
; __W _EQ
;  DW  _XOR,_ZEQ,_EXIT
;
;_ACC:
;
; __W _SETMOV
;  DW  _SWAP,_STA
; __W _XDROP
;  DW  _EX,_DROPX
;
; __W _TYPE
;  DW  _XDROP,_LOOPS,_CSTR,_EMIT,_EXIT
;
; __W _CMOVE
;  DW  _SETMOV,_LOOPS,_CSTR,_STAPB,_EXIT
;
; __W _MTEXT
;  DW  _SWAP,_STA,_FOR,@@2
;@@1: DW _CSTR,_WCSTR,_EQ,_IF,@@3
;@@2: DW _NEXT,@@1
;@@3: DW _DROP,_POP,_1P,_EXIT
;
; __L _NUMBER
; __L _COMP_NUM
; __L _@EMIT
; __L _@_INI
; __L _EXEC
; __L _COMMA
; __L @_SOURCE


;    dw _ifm,@@not
;  __w _neg
;    dw _1m
;  __w _not
;@@not:
;    dw _m1,_xor
;    dw _exit
;
; ---------------------------------------

; __L _PAR_IN
;  DDUP
;  X
;  PUSH  OP
;  PUSH  W
;  X
;
; __L _CODE_IN
;  JMP   IP
;
; __W _dos
;  DW _PAR_IN
;  pop  AX
;  pop  bx
;  pop  cx
;  pop  dx
;  INT  21H
;  mov  sav_ax,ax
;  mov  sav_dx,dx
;  RCL  Bx,1
;  mov  sav_fx,Bx
;@PAR_OUT:
;  X
;  POP   W
;  POP   OP
;  X
;  JMPS _DROPX
;

;__W @_mover:
; call @intcal
; pop  cx
; pop  DI
; pop  si
; x
; xchg bx,di
; jmp  bx

;
; __l _udiv
;  D_TO  AX
;  RCHG  DX
;  RCHG  CX
;  D_TO  AX
;  cmp   dx,cx
;  jnb   @@1
;  div   cx
;@@1:
;  RCHG  DX
;  TO_D  AX
;  JMPS @MAIN
;

;  __L  _ANDX
;
;  __W  _SGN
;    DW _ANDX,8000H
;
;  __l  _cmove
;@movd:
;  rep  movsb
;  cld
;  ret
;
;  __l  _cmoveu
;  ;,@_mover
;@movu:
;  add  di,cx
;@pushu:
;  add  si,cx
;  std
;  jmps @movd
;
;  __l  _move
; ;,@_mover
;  cmp  si,di
;  jb   @movd
;  jmps @movu
;
;sav_ax dw 0
;sav_dx dw 0
;sav_fx dw 0
;
; __l _umul
;  pop  t
;  mul  dx
;  push t
;  jmps @main


;  __w _xspc
;     dw _ex
;  __w _space
;     dw _bl,_emit,_exit
;
;  __w _DIGP
;        DW _ALPHA,_EMIT,_EXIT
;
;  __w _ALPHA  ; : ALPHA  LF OVER U< 7 AND + '0 + ;
;        DW _DUP,_LF,_ULESS,_ZEQ,_w_b7,_ADD,_LT0,_ADD,_EXIT
;
;; __XT  _ZSKIP,@?SKIP
;;        DW @_DUP,_ZEQ,_ZEX,_DROP,_RLDP,_DROPX
;
;  __w _HP
;        DW _DUP,_SGN,_IF,@@NOSGN,_LIT,'-',_EMIT,_ABS
;@@NOSGN DW _SKIP
;  __w _UNP
;        DW _XSPC,_SKIP
;  __w _HP2
;        DW _LF,_UDIV,_ZSKIP,_HP2,_DIGP,_EXIT
