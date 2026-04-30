        INCLUDE  NF7.i0

; REGISTERS
; SI INSTRUCTION POINTER
; AX DATA STACK POINTER
; SP RETURN STACK POINTER
; BX DATA STACK TOP REGISTER
; DX DATA STACK NEXT REGISTER
; DI WORK REGISTER
; BP ARITHMETIC/ADDRESS REGISTER
; CX TEMP REGISTER

; PUSH POP J DUP @R+ !R+ AR XR (IF (IF- (; (JMP +2/ NAND          14 + 64
; EXTENDED 
; NOT NEG STR CSTR !+ C!+ !- 0= ! @ DC@ 1+ LIT LITC` FIND FINDC   16
; (VAR (SETV (CON (DOES (DEFER (PNT (TOPNT 2+ 1- 2- (-IF          11
; WORD PARS PARSE 0SWAP SWAP ROT OVER DROP NIP DROP; NIP; ;DROP   12
; =: =H CODE, ;, @, EXEC @EXEC EXECUTE TOKEN TOKEN? ; : :`        13
; NUM NUMBER ?? 0?? (S! MPUSH EVAL ABORT SOURCE ,< >,   TOKEN     12
; EMIT ACCEPT DEMIT  U/MOD                                         4



ip  = si        ; for interpretter
w   = di
dsp = ax
rsp = sp
top = Bx
AR  = BP

topL = BL
toph = Bh
NR   = DX
NRL  = DL
NRH  = DH
TR   = CX
TRH	 = CH
TRL  = cl

nbase = bx      ; for number utility
nacc  = di

; MINIMAL SET INTERPRETTER COMMANDS
; CONTROL      	COMMANDS  (IF (JUMP (IFM (RETURN
; RETURN STACK 	COMMANDS  POP PUSH XA XR
; DATA STACK   	COMMANDS  DUP J 
; MATH         	COMMANDS  +2/ -/ +*
; LOGICAL      	COMMANDS  NAND
; DATA TRANSF  	COMMANDS  @R+ !R+ 
; ADDITIONAL	RDROP I LIT  ABS NEG NOT  1- 2- 1+ 2+ (EX DROP
;				(NEST (NEST2 (NEST3 (EXEC (PERF NEG NOT C!R+
; METHOD		(DOES (VAR (VAR2 (VAR3 (CNST (DEFER (DEFER0
;				(SETVAR (SETVAR2 (SETPOINT (POINT (BARY (WARY (LARY

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
;------------  MAIN LOOP  OUTER INTERPRETTER ----

  mov   bx,1000h     ; only 64k allocate
  mov   ah,4ah
  int   21h
@_ABORT:
  MOV   RSP,@R_TOP
@_QUIT:
  MOV   DSP,@S_TOP
  CALL  @_TROFFZ
  CALL  @_RETURN
@_MAINLP DW INIT,EVAL,OK,BR,@_MAINLP

  POINT  INIT,@_INI
  CNST  _BL,32

  XT STP,@_NIP            ; (!+
  MOV   [TOP],CX
@2p:
  inc   top
@_1p:
  inc   top
  JMPS  @_MAIN1

  XT STPB,@_NIP            ; (C!+
  MOV   [TOP],CL
  JMPS  @_1P

  XT STM,@_NIP            ; (!-
  MOV   [TOP-2],CX
@2M:
  DEC   TOP
@1M:
  DEC   TOP
@_MAIN1:  JMP  @_MAIN

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  DEFERO EMIT,DEMIT
  DEFER  SOURCE,ETIB
  DEFER  ACCEPT,@_ACC
  DEFER  OK,NOOP
  DEFER  ERROR,NOOP

  CNST  TBL,80H
  CNST  TIB,@TIB
  CNST  TBUF,@TBuf

  POINT  FIND,0

  VALUE  H,@_FREEMEM
    
  VALUE  ETIB,0
  VALUE  LTIB,0
  VALUE  DICT,@VOCTOP*2
  VALUE  CNTC,0
  value  stat,0

OPERATION DW @_WARY    
                ;   , COMPILE   ;
        DW NUMBER	  , PERFORM   ; | INTERPRET
      ;-------------------------;---------
        DW COMP_NUM , ATCOMMA   ; | COMPILE 
      ;-------------------------;---------
        dw 0        , 0         ; | REMARK
;------------------------------------

@_NIP:
  to_r  W
  mov	TR,NR
  JMPS @_NR_NIP  
  
@__DROP:
  to_r  W
@SETDROP:
  MOV   W,top
@TOPDROP:
  MOV   TOP,NR
@_NR_NIP:
  D_TO  NR
  RET

  XT  RLDP,@_RLD@    ; @R+
  MOV   TOP,[W]
  W2
  RET

 XT  RSTP,@_RST@
 MOV   [W],TOP
 W2
 JMPS  @TOPDROP

  XT  ASTR,@_RLD@    ; (STR
  MOV   TOPL,[W]
  inc   top
  ADD   top,W
  SKIPA

  XT  XR,@_RST@    ; XR
  XCHG  TOP,W
  RET

  XT  XA,@_RST@    ; XA
  XCHG  AR,W
  RET

  XT  DUPW,@_CALL     ; dup
@_TOPDUP:
  TO_D  NR
  MOV   NR,TOP
  RET

;  XT  LIT,@_DUP       ; LIT
;  MOV   TOP,[IP]
;  wiP2
;  RET

COL LIT
  DW RLDP,EXIT

  XT  LD,@_CALL      ; @
  MOV   TOP,[TOP]
  RET

;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

  ;-------------------  NUMBER  ------------
         ; adr count base  / num flag -> =0 ok


@_NUM:
  CALL  @@numini
  CALL  @@END?
  CALL  @@SGN
@@NUMZ:
  CALL  @@END?
  CALL  @@N0
  JMPS  @@NUMZ

@@SGN:
  CMP   AL,'-'     ; SGN
  JNE   @@n0
  POP   dX
  CALL  dX         ; return to caller
  NEG   nacc
  RET
@@n0:
  JCXZ  @@N5
  cmp  al,'#'     ; BASE := nbase
  JNE   @@N1
  RCHG  nacc
@@numini:
  Xor   nacc,nacc       ; ACCUMULATOR
@@setbas:
  DEC   AX
  DEC   AX
  xor   ah,ah
  mov   NBASE,ax
  INC   NBASE
  INC   NBASE
  RET
@@N1:
  cmp   al,''''
  jNE   @@N2
  LODSB
@@ESCAPE1:
  deC   CX
@@ESCAPE:
  rchg  nacc
  mul   nbase
  rchg  nacc
  add   nacc,ax
  JCXZ  @@EXNUM
  RET
@@N2:
  cmp   al,'^'
  jNE   @@N3
  LODSB
  AND   AL,31
  JMPS @@ESCAPE1
@@N3:
  cmp   al,'%'     ; BASE := 16
  JNE   @@N4
  MOV   al,2
  jmp   SHORT @@setbas
@@N4:
  cmp   al,'$'     ; BASE := 16
  JNE   @@N5
  MOV   al,16
  jmp   SHORT @@setbas

@@N5:
  cmp   al,'9'+1
  jc    @@ton2
  cmp   al,'A'      ; no case sensivity
  jc    @@ERNUM
  sub   al,7
@@ton2:
  sub   al,'0'
  cmp   ax,nbase
  jc   @@ESCAPE  ;ERNUM
@@ERNUM:
  INC   CX
@@EXNUM:
  pop   dx    ; rdrop
  RET
@@END?:
  JCXZ  @@ERNUM
  deC   CX
  LODSB
@_TROFFZ:
  RET


@_PARAM:
  PUSH  IP BP 
  MOV BP,SP
  X
  PUSH  NR TOP
  XOR CX,CX
  JMP W
  
@_ZFND:           ; SKIP FIRST WORD IN DICTIONARY
  W2
  W2
  MOV   CL,[DI] ; ON COMPILE ONLY
  INC   DI
@_NFND:
  add   di,cx
@_l@Nfnd:
  mov	  BX,DI
  W2
  W2
  mov   cl,[di]
  jcxz  @@xfnd?
  INC   CX
  PUSH  SI
  repe  cmpsb
  POP	  SI
  jNZ   @_Nfnd
@@YFND:
  INC   CX
  MOV   DX,BX
  INC	  pw [BX+2]	
@@xFND?:
  MOV   BX,CX
  ret

@_FNDZ:
  push  di      ; COMPILE MODE SEARCH
  inc   pb [SI]
  call  @_Zfnd
  dec   pb [SI]
  pop   di
  jCXZ  @_Dfnd
  RET

@_dfnd:
  call  @_ZFND
  inc   cx
  INC   CX
  ret

  XT  P1,@_1P         ; 1+

  XT  Wstr,@_DUP     ; STR
  MOV   TOP,[TOP]
  INC   NR
  INC   NR
  RET

  XT  ZSWAP,@_DUP     ; STR
  SKIPR   NR
BYE: DW 0  
  RET

  XT  DLDB,@_DUP     ; DUP C@
@_LDB:
  MOV   TOPL,[TOP]
  MOV   TOPH,0
  RET

  XT  CSTR,@_DUP     ; CSTR
  INC   NR
  JMPS  @_LDB

;  xt plmul,@_CALL
;	TEST	NRl,1
;	jz	@@pl1
;	ADD	TOP,AR
;@@pl1:
;	rcr	TOP,1
;	rcr	NR,1
;	RET

;  xt midiv,@_CALL                        ; -/
;	SHL	NR,1
;	rcl	TOP,1
;	CMP	TOP,AR
;	jNC	@@mi1
;	sub	TOP,AR
;	INC	NR
;@@mi1:
;	RET
;
;XT DIVMOD,@_CALL
;  XCHG  AX,CX
;  Xor   AX,AX
;  XCHG  AX,DX
;@_DM2:
;  DIV BX
;  XCHG  AX,DX
;  mov   BX,DX
;  XCHG  AX,CX
;  RET


RVAR3 XEVAL
XT  EVAL,@_TOEVAL           ; EVAL
        DW to_+LTIB,to_+ETIB
@_DoEval DW TOKEN,DLDB,BR?,@_ABORTX
;        DW CR,SPACE,DUP,STYPE ;DW BRK
        DW FIND,OPERATION,PERFORM,BR,@_DoEval; for ( ) \ |

  COL DICTX                          ; ;HERE
        DW DICT,EX,to_+DICT,EXIT

COL HEREX                          ; ;HERE
      DW H,EX,to_+H,EXIT

  COL RPAR
	DW FIND+TO_,DICT,FNDC,exit
	
  COL LPAR
	DW FIND+TO_,DICT,FND
@_ERRX:	
	DW exit
		
  COL ERROR?                         ; (A"
        DW ASTR,TO_+STAT,BR?,@_ERRX
        DW ERROR,ABORT
        ; ADDRESS OF ERROR MESSAGE IS IN STAT

   RVAR XDROP
@_ABORTX DW DROPX

  XT  DROPX,@_DROPX

;@_INI  DW  HERE,WSTR,DPUSH,TBL,cstr,XEVAL,TO_+INIT
@_INI  DW  H,WSTR,DPUSH,XEVAL,TO_+INIT
        DW  TIB,TBL,ACCEPT,EXIT

  COL    DPUSH                        ; >DICT
        DW  DICTX,MPUSH,EXIT

;------------------------------------
; LOGICAL      COMMANDS  XOR AND


;  col find                           ; FIND  with status
;        DW stat,DOES,SUB,dict,FND,EXIT

  XT COLON,@_MAKER           ; :
        DW @_NEST,RPAR

  XT  SEMICO,@_COMMA
        DW EXIT,LPAR          ; ;`

  XT CLIT,@_COMMA
        DW LIT,COMMA          ; #,`

  XT  J,@_IJ
        DW 2

;  XT  NEXT,@NEXT             ; (NEXT
;  XT  RDROP,@RDROP           ; RDROP
  XT  BR,@_JUMP             ; (JUMP
;  XT  SKIP,@_SKIP             ; SKIP
  XT  ABORT,@_ABORT           ; ABORT
  XT  EXIT,@_RETURN           ; EXIT
  XT  EX,@_EX                 ; EX
;  XT  POPW,@POP               ; POP
  XT  NIPX,@_NIPX             ; ;NIP

RVAR3 XCOMMA               ; ;,
col  ATCOMMA                 ; @,
	DW LD
col  COMMA                 ; ,
	DW Herex,STP,EXIT

  COL COMP_NUM               ; (NUM,
        DW NUMBER,CLIT,EXIT

  COL NUMBER                         ; (NUMBER
        DW cstr,NUM,??,EXIT

  COL ENTRYC                        ; CODE,    
        DW XCOMMA
  COL ENTRYH                        ; =H    HEADER
        DW H    ;ERE
  COL ENTR                         ; =:    ALIAS
        DW TOKEN?
@SAME:
    DW NOOP,DLDB,P1,DPUSH
		DW DICTX,ZSWAP,STM,STM,EXIT

  COL TOKEN?	; TOKEN? ( - TADR )  ; IS IT A TOKEN IN THE BUFFER ?
        DW XTOK?       
  COL TOKEN	; TOKEN ( - TADR )
        DW _BL ; LIT,32
  COL WRD	;  ( CHAR - TADR )
        DW XSETSTR     ; SET TEXT TO BUF AFTER PARSING
  COL PARSE	; PARSE ( CHAR ADRBUF LENBUF - ATOK LTOK LENBUF1
        DW SOURCE,LTIB,PARS,to_+LTIB,EXIT  ; PARSE

  RVAR XSETSTR                       ; ;S!
        dw TBUF,MSTR,nipx

  RVAR XTOK?                        ; ;TOK?
        DW DLDB        ; DUP C@
  COL  Z??                          ; #??
        DW ZEQ         ; LOGICAL INVERT -> #0 IS OK
  COL  ??                           ; ??
        DW ERROR?      ; ZERO ? 0 / FALSE IS OK
     NAM "?"
        DW EXIT

  LBL @_COMMAER
  dw Wstr,comma,perfORM,exit

@_comma:
  call @does
  DW @_COMMAER

@_MAKER:
  call @does
  dw entryH,@_commaER

  ;----------------  PARSE   -----------------

; CHAR ADRBUF LENBUF  - TOK_ADR TOK_LEN REM_LENBUF

  XT  PARS,@_PARAM           ;= (PARS
  POP  CX DI AX
  SUB   DI,CX
;  CMP   AL,' '
;  JNE   @@SKIPX
  JCXZ  @@SKIPX
  REPE  SCASB
  JE    @@SKIPX
  DEC   DI
  INC   CX
@@SKIPX:
  MOV  BX,di      ;  START OF THE SOURCE
  JCXZ  @@WEX

  REPNE SCASB
  JNE   @@WEX
  DEC   DI

@@WEX:          ; END OF THE SOURCE  IN DI
  SUB   di,BX
  PUSH  BX      ; START OF THE SOURCE
  JMPS  @_PUSH_DC

  XT  num,@_PARAM           ;= (ATOI
  POP   Cx SI 
  MOV   AL,10   ; BASE 10
  CALL  @_NUM
@_Push_DC:
  PUSH  DI CX
  JMPS @_XPARAM

  ;----------------  MEMORY  -------------------

  XT  MPUSH,@_PARAM ; TOP OF DICTIONARY   IN DI
  POP DI CX SI
  ADD   SI,CX                ; AFTER NAME ADDRESS
  STD                        ; BACKWARDS
  CMPSB                      ; PREPARE FOR DIRECTION
  REP   MOVSB                ; NAME  MOVE
  CLD
  inc   di
  PUSH DI
  JMPS @_XPARAM

  XT  MSTR,@_PARAM        ; (S!
  POP DI CX SI
  PUSH DI
  MOV   [DI],CL
  INC   DI
  REP   MOVSB   ; NAME  MOVE
  MOV   PB [DI],'`'
  JMPS @_XPARAM
  
  ;--------------------   IO  ---------------

  XT  @_ACC,@_PARAM   ; RETURNS 2 PARAM
  POP AX DI			; DI := DX
  STOSB
  MOV AH,10
  INT 21H
  mov BX,DI
  CALL  @_LDB
  PUSH DI BX
  JMPS @_XPARAM

  XT  DEMIT,@_PARAM   ; (EMIT
  POP DX
  MOV   AH,2  ; dos function number EMIT
  INT   21H
  JMPS @_XPARAM

  ; ------------ SEARCH  --------------
  ; WHAT WHERE 
  XT  FND,@_PARAM            ; (FIND
  POP DI SI  ; DX=SI
  CALL  @_l@Nfnd
@_PUSH_SC:; RETURNS DX CX
  PUSH  DX CX
@_XPARAM:
  MOV AX,SP 
  mov	SP,BP
  POP  BP
@2dropx:
  R_TO  IP
@2drop:
  DROP2 TOP,NR
  JMPS  @_MAIN
  

  XT  FNDC,@_PARAM            ; (FIND
  POP DI SI  ; 
  CALL  @_FNDZ
  JMPS  @_PUSH_SC
  


;------------  MAIN LOOP  INNER INTERPRETTER ----
;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

;  XT  CST,@__DROP      ; C!
;  mov	[DI],BL
;  JMPS @_DROP
  
@ROT:
  D_TO  W
  JMPS  @_VAR

@over:
  TO_R  NR

; RETURN STACK COMMANDS  POP PUSH XCHG

@POP:
  r_to  W
  skipA

  W2
  W2
@VAR:
  JMPS  @_VAR

@_IJ:
  MOV   W,[W]
  ADD   W,rSP
@_CONS:
  MOV   W,[W]
@_VAR:
  tDUP
@_ADR:
  MOV   top,W
  JMPS   @_MAIN

@_DROPX:
  POP   IP
  JMPS  @_DROP

  XT  STW,@__DROP      ; !
  SKIPB
;  JMPS  @_SETVAR

@_SETVAR2:
  W2
@_SETVAR:
  MOV   [W],top
@_DROP:
  MOV   TOP,NR
@__NIP:
  D_TO  NR
  JMPS  @_MAIN

@_NIPX:
  R_TO  IP
  JMPS  @__NIP

@_RLD@:
  TDUP
  MOV   TOPH,0
@_RST@:
  R_TO  TR
  XCHG  TR,W
  CALL  TR
  SKIPA

XT  PUSHW,@__DROP       ; PUSH

@PUSHW:
  to_r  W
  JMPS  @_MAIN

@PUSHW3:
  W2
@PUSHW2:
  W2
@PUSHW1:
  W2
  JMPS  @PUSHW

@_DUP:
  tDUP
@_CALL:
  CALL  W
  JMPS   @_MAIN

; CONTROL      COMMANDS

@_DEFERO:
  INC   PW VL_+CNTC
@_DEFER:
  MOV   W,[W]
@_EXEC:
  W2
  JMP   [W-2]

  XT  EXECUTE,@__DROP      ; EXECUTE
  JMPS  @_NESTZ

  XT  EXEC,@__DROP       ; EXEC
  jmps  @_EXEC

  XT  PERFORM,@__DROP    ; @EXEC
  jmps  @_DEFER

@_TOEVAL:  ; >EVAL
  ADD   NR,TOP
NOOP:
@_NEST:
  SKIPB
  DB 1
  JMPS @_NESTZ  

; MAIN  LOOP

  W2
  W2
@DOES:
  tDUP
  MOV   top,W
@_EX:
  r_to  W
@_NESTZ:
  to_r  IP
@LBL:
  to_r  W
@_RETURN:
  r_to  IP
@_MAIN:
  MOV   W,[IP]
  wiP2
  JMP   [W-2]

@TODBG:
  JMP @_ABORT

@_POINT:
  MOV   W,[W]
  JMPS  @_NESTZ

@_setpnt:
  MOV   [W+2],IP
  JMPS  @_RETURN

@_LARY:
  SHL   top,1
@_WARY:
  SHL   top,1
@_BARY:
  ADD   top,W
  JMPS  @_MAIN

XT  IFM,@_IFM
@MIF:
  inc   TOP
@_IFM:
  dec	TOP
  JNS    @_JUMP
@SKIP:
  INC IP
  INC IP
  JMPS  @_MAIN

  XT  BR?,@__DROP      ; (IF
	OR    W,W
  JNE   @SKIP
@_JUMP:    ; (JUMP
  MOV   IP,[IP]
  JMPS  @_MAIN

@SWAPX:
  R_TO  IP
@SWAP:
  XCHG  TOP,NR
  SKIPB

@RDROP:
  r_to  TR
  JMPS  @_MAIN

;  XT  xorW,@NIP       ; xor
;  XOR  TOP,TR
;  JMPS  @_MAIN
;  
  XT  NAND,@_NIP
  AND  TOP,TR
@NOT:
  inc   TOP
@NEG:
  NEG   TOP
  JMPS  @_MAIN

  PRIM ZEQ            ; 0=
  SUB   top,1
@_CF:
  cf_to top
  JMPS  @_MAIN

;  xt ULESS,@_nip
;    SUB   TOP,W
;    JMPS @_CF

  XT  P2DIV,@_CALL   ; +2/
  ADD   TOP,NR
  MOV   NR,TOP
  RCR   TOP,1
  RET

@_freemem:
  DW @_ENDMEM-@_FREEMEM-2
  ENTRY  '=:',ENTR
  DW 0,0
  DB 0
@_EndMem:

lastw = ppppp

MyCseg  ends
        end  Start

