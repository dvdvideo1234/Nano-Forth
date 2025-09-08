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
; RETURN STACK 	COMMANDS  POP PUSH J XA XR
; DATA STACK   	COMMANDS  DUP
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

OPERATION DW @_WARY
        DW NUMBER	; INTERPRET
		DW COMP_NUM	; COMPILE     
        DW PERFORM  ; INTERPRET 
		DW ATCOMMA	; COMPILE

  XT STP,@_NIP            ; (C!+
  MOV   [TOP],CX
@2p:
  inc   top
@1p:
  inc   top
  JMPS  @_MAIN1

  XT STPB,@_NIP            ; (C!+
  MOV   [TOP],CL
  JMPS  @1P

  XT STM,@_NIP            ; (!-
  MOV   [TOP-2],CX
@2M:
  DEC   TOP
@1M:
  DEC   TOP
@_MAIN1:  JMP  @_MAIN

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

@_NIP:
  to_r  W
  mov	CX,NR
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

  XT  LIT,@_DUP       ; LIT
  MOV   TOP,[IP]
  wiP2
  RET

  XT  LD,@_CALL      ; @
  MOV   TOP,[TOP]
  RET

;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

  ;-------------------  NUMBER  ------------
         ; adr count base  / num flag -> =0 ok

@NUM:
  CALL  @@numini
  CALL  @@SGN
@@NUMZ:
  CALL  @@N1
  JMPS  @@NUMZ

@@n1:
  cmp   al,'$'     ; BASE := 16
  JNE   @@N2
  MOV   al,16-1
  jmp   SHORT @@setbas

@@N2:   cmp  al,'#'     ; BASE := nbase
  JNE   @@N3
  RCHG  nacc
@@numini:
  DEC   AX
  Xor   nacc,nacc       ; ACCUMULATOR
@@setbas:
  xor   ah,ah
  mov   nbase,ax
  INC   NBASE
@@END?:
  or    CX,cx
  Jnz   @@GETC
@@ERNUM:
  INC   CX
@@EXNUM:
  pop   dx    ; rdrop
  RET

@@N3:
  cmp   al,''''
  jNE   @@N4
  CALL  @@END?
  JMPS  @@ESCAPE

@@N4:
  cmp   al,'9'+1
  jc    @@ton2
  cmp   al,'A'      ; no case sensivity
  jc    @@ERNUM
  sub   al,7
@@ton2:
  sub   al,'0'
  cmp   ax,nbase
  jnc   @@ERNUM
@@ESCAPE:
  rchg  nacc
  mul   nbase
  rchg  nacc
  add   nacc,ax
  JCXZ  @@EXNUM
@@GETC:
  deC   CX
  LODSB
  RET

@@SGN:
  CMP   AL,'-'     ; SGN
  JNE   @@N1
  CALL  @@END?
  POP   dX
  CALL  dX         ; return to caller
  NEG   nacc
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
  mov	BX,DI
  W2
  W2
  mov   cl,[di]
  jcxz  @@xfnd?
  INC   CX
  PUSH  SI
  repe  cmpsb
  POP	SI
  jNZ   @_Nfnd
@@YFND:
  MOV   DX,BX
  MOV   cL,2
  ADD	[BX+2],CX	
@@xFND?:
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
  ret

  XT  P1,@1P         ; 1+

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
@LDB:
  MOV   TOPL,[TOP]
  MOV   TOPH,0
  RET

  XT  CSTR,@_DUP     ; CSTR
  INC   NR
  JMPS  @LDB

;  xt plmul,@_CALL
;	TEST	NRl,1
;	jz	@@pl1
;	ADD	TOP,AR
;@@pl1:
;	rcr	TOP,1
;	rcr	NR,1
;	RET

  xt midiv,@_CALL                        ; -/
	SHL	NR,1
	rcl	TOP,1
	CMP	TOP,AR
	jNC	@@mi1
	sub	TOP,AR
	INC	NR
@@mi1:
	RET


;------------------------------------

  DEFERO EMIT,@EMIT
  DEFER  SOURCE,ETIB
  DEFER  ACCEPT,@_ACC
  DEFER  OK,0
  DEFER  ERROR,0

  CNST  TBL,80H
  CNST  TIB,@TIB
  CNST  TBUF,@TBuf
  POINT  INIT,@_INI
  POINT  FIND,0
  VALUE  HERE,@_FREEMEM
  VALUE  ETIB,0
  VALUE  LTIB,0
  VALUE  DICT,@VOCTOP*2
  VALUE  CNTC,0
  value  stat,0

  COL EVAL                           ; EVAL
        DW TOEVAL,to_+LTIB,to_+ETIB
@DoEval DW TOKEN,DLDB,BR?,@_ABORTX
;        DW CR,SPACE,DUP,STYPE ;DW BRK
        DW FIND,OPERATION,PERFORM,BR,@DoEval

  COL DICTX                          ; ;HERE
        DW DICT,EX,to_+DICT,EXIT

;  COL HEREX                          ; ;HERE
;        DW HERE,EX,to_+HERE,EXIT

  COL RPAR
	DW FIND+TO_,DICT,FNDC,exit
	
  COL LPAR
	DW FIND+TO_,DICT,FND
@ERRX:	
	DW exit
		
  COL ERROR?                         ; (A"
        DW ASTR,TO_+STAT,BR?,@ERRX
        DW ERROR,ABORT
        ; ADDRESS OF ERROR MESSAGE IS IN STAT

   RVAR XDROP
@_ABORTX DW DROPX

  XT  DROPX,@_DROPX

@_INI  DW  HERE,WSTR,DPUSH,TBL,cstr,TO_+INIT
        DW  TIB,TBL,ACCEPT,EXIT

  COL    DPUSH                        ; >DICT
        DW  DICTX,MPUSH,EXIT

;------------------------------------
; LOGICAL      COMMANDS  XOR AND


;  col find                           ; FIND  with status
;        DW stat,DOES,SUB,dict,FND,EXIT

  XT COLON,@_MAKER           ; :
        DW @_NESTZ,RPAR

  XT  SEMICO,@_COMMA
        DW EXIT,LPAR          ; ;`

  XT CLIT,@_COMMA
        DW LIT,COMMA          ; #,`

  XT  J,@_IJ
        DW 2

;  XT  NEXT,@NEXT             ; (NEXT
;  XT  RDROP,@RDROP           ; RDROP
  XT  BR,@_JUMP             ; (JUMP
  XT  SKIP,@_SKIP             ; SKIP
  XT  ABORT,@_ABORT           ; ABORT
  XT  EXIT,@_RETURN           ; EXIT
  XT  EX,@_EX                 ; EX
  XT  POPW,@_POP               ; POP
  XT  NIPX,@_NIPX             ; ;NIP

  col3  ATCOMMA                 ; @,
  RVAR3 XCOMMA               ; ;,
  col2  COMMA                 ; ,
	DW LD
	DW HERE,STP,TO_+HERE,EXIT

  COL COMP_NUM               ; (NUM,
        DW NUMBER,CLIT,EXIT

  COL NUMBER                         ; (NUMBER
        DW cstr,NUM,??,EXIT

  COL3 ENTRYC                        ; CODE,    
  COL3 ENTRYH                        ; =H    HEADER
  COL3 ENTR                         ; =:    ALIAS
        DW XCOMMA,HERE,TOKEN?,DLDB,P1,DPUSH
		DW DICTX,ZSWAP,STM,STM,EXIT

  COL3 TOKEN?	; TOKEN? ( - TADR )
  COL3 TOKEN	; TOKEN ( - TADR )
  COL3 PARSE	; PARSE ( ADRBUF LENBUF - ATOK LTOK LENBUF1
        DW XTOK?       ; IS IT A TOKEN IN THE BUFFER ?
        DW XSETSTR     ; SET TEXT TO BUF AFTER PARSING
        DW SOURCE,LTIB,PARS,to_+LTIB,EXIT  ; PARSE

  RVAR XSETSTR                       ; ;S!
        dw TBUF,MSTR,nipx

  RVAR3 XTOK?                        ; ;TOK?
  COL3  Z??                          ; #??
  COL3  ??                           ; ??
        DW DLDB        ; DUP C@
        DW ZEQ         ; LOGICAL INVERT -> #0 IS OK
        DW ERROR?      ; ZERO ? 0 / FALSE IS OK
     NAM "?"
        DW EXIT

;@_state:
;  call  @does3
;  dw to_+_stat,exit

  LBL @_COMMAER
  dw Wstr,comma,perfORM,exit

@_comma:
  call @does
  DW @_COMMAER

@_MAKER:
  call @does
  dw entryH,@_commaER

  ;----------------  PARSE   -----------------

;  CHAR etib ltib  /  START LEN >IN
;  SI   CX   DI       di    si  cx

  XT  PARS,@_PARAM           ;= (PARS
  POP  CX DI
  SUB   DI,CX
  MOV   AL,' '
  JNE   @@SKIPX
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
  POP   SI Cx
  MOV   AL,10   ; BASE 10
  CALL  @NUM
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
  STOSW
  MOV AH,10
  INT 21H
  mov BX,DX
  INC BX
  CALL  @LDB
  PUSH DI BX
  JMPS @_XPARAM

  XT  @EMIT,@_PARAM   ; (EMIT
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
  R_TO  IP
  DROP2 TOP,NR
  JMP  @_MAIN
  

  XT  FNDC,@_PARAM            ; (FIND
  POP DI SI  ; 
  CALL  @_FNDZ
  JMPS  @_PUSH_SC
  


;------------  MAIN LOOP  INNER INTERPRETTER ----
;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

;  XT  CST,@__DROP      ; C!
;  mov	[DI],BL
;  JMPS @_DROP
  
  XT  STW,@__DROP      ; !
  JMPS  @_SETVAR

@ROT:
  D_TO  W
  JMPS  @_VAR

@over:
  TO_R  NR

; RETURN STACK COMMANDS  POP PUSH XCHG

@_POP:
  r_to  W
  skipA

@VAR3:
  W2
@VAR2:
  W2
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
  JMP   @_MAIN

@_DROPX:
  POP   IP
  JMPS  @_DROP

@_SETVAR2:
  W2
@_SETVAR:
  MOV   [W],top
@_DROP:
  MOV   TOP,NR
@NIP:
  D_TO  NR
  JMPS  @_MAIN

@_NIPX:
  R_TO  IP
  JMPS  @NIP

@_RLD@:
  TDUP
  MOV   TOPH,0
@_RST@:
  R_TO  TR
  XCHG  TR,W
  CALL  TR
  SKIPA

@PUSHW3:
  W2
@PUSHW2:
  W2

@PUSHW:
  to_r  W
  JMPS  @_MAIN

  XT  PUSHW,@__DROP       ; PUSH
  JMPS  @PUSHW

@_DUP:
  tDUP
@_CALL:
  CALL  W
  JMP   @_MAIN

; CONTROL      COMMANDS

  XT  PERFORM,@__DROP    ; @EXEC
  jmps  @_DEFER

@_DEFERO:
  INC   PW [VL_+CNTC]
@_DEFER:
  MOV   W,[W]
@_EXEC:
;  OR    W,W
;  JZ    @_MAIN
  W2
  JMP   [W-2]

@nest3:
  w2
@nest2:
  w2
@NEST:
  SKIPB
  DB 1
  JMPS @_NESTZ  

  XT  EXECUTE,@__DROP      ; EXECUTE
  JMPS  @_NESTZ

  XT  EXEC,@__DROP       ; EXEC
  jmps  @_EXEC

; MAIN  LOOP

@DOES3:
  W2
@DOES2:
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

  PRIM  IFM
  dec	TOP
  JNS    @_JUMP
@_SKIP:
  INC IP
  INC IP
  JMPS  @_MAIN

  XT  BR?,@__DROP      ; (IF
	OR DI,DI
  JNE   @_SKIP
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

  XT  xorW,@NIP       ; xor
  XOR  TOP,TR
  JMPS  @_MAIN
  
  XT  NAND,@_NIP
  AND  TOP,TR
@NOT:
  NOT   TOP
  JMPS  @_MAIN

  PRIM ZEQ            ; 0=
  SUB   top,1
@_CF:
  cf_to top
  JMPS  @_MAIN

  xt ULESS,@_nip
    SUB   TOP,W
    JMPS @_CF

  XT  P2DIV,@_CALL   ; +2/
  ADD   TOP,NR
  MOV   NR,TOP
  RCR   TOP,1
  RET

  XT  TOEVAL,@_CALL   ; >EVAL
    ADD   NR,TOP
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

;-----------------------------------------------
;  TEST

; XT  1P,@_CALL      ; 1+
; INC   TOP
; RET

;  XT  LDP,@_DUP      ; @+
;@LDP:
;  MOV   NR,[Top]
;  JMPS  @2P

; XT  RSTBP,@_RST@   ; C!R+
; MOV   [W],TOPL
; INC   W
; JMPS  @TOPDROP

;  COL BCOMMA,BCOMMAL          ; C, >C,
;        DW HEREX,STBP,EXIT

;     : C,  ;HERE C!+ ;

  COL BCOMMA
        DW HEREX,STBP,EXIT

  XT  ULESS,@__DROP   ; U<
  SUB   TOP,W
  JMPS  @CF

  PRIM SGN            ; 0<
  SHL   TOP,1
  JMPS  @CF

  CNST LF,10
  CNST 1H,16
  CNST 1,1
  CNST LT0,'0'

  XT  AND,@AND
  XT  XOR,@XOR
; XT  ABS,@ABS
  XT  NEG,@NEG
  XT  NOT,@NOT


; XT  RLDP,@_RLD        ; @R+
;       JMP  @PUSHW2

  XT  BRK,@_CALL
  INT 3
  RET

  XT  I,@_IJ
        DW 0

  COL DEBUG
        DW CR,I,HEXP,RP,HEXP,SP,HEXP
        DW HERE,HEXP,ASTR,STYPE
        DW WAIT,CR,EXIT


  COL TWICE
        DW I,PUSH,EXIT

  COL HEXP
        DW XSPC,LIT,256,UDIV,TWICE
        DW 1H,UDIV,TWICE,SKIP
  COL DIGP
        DW ALPHA,EMIT,EXIT

  COL ALPHA  ; : ALPHA  LF OVER U< 7 AND + '0 + ;
        DW DUP,LF,ULESS,ZEQ,LIT,7,AND,ADD,LT0,ADD,EXIT

; XT  ZSKIP,@?SKIP
;        DW @_DUP,ZEQ,ZEX,DROP,RLDP,DROPX

  COL HP
        DW DUP,SGN,IF,@@NOSGN,LIT,'-',EMIT,ABS
@@NOSGN DW SKIP
  COL UNP
        DW XSPC,SKIP
  COL HP2
        DW LF,UDIV,ZSKIP,HP2,DIGP,EXIT

;  COL LOCATE
;        DW TOKEN?,FIND,1,AND,Z??,EXIT

;  RVAR2 XEMIT
  RVAR2 XSPC
  COL   SPACE
       DW BL,EMIT,EXIT


  COL CR
       ;DW BRK
       DW STRTYPE
       DB 2,13,10
       DW 0,TO_+_CNTC,EXIT

 COL @OK
       DW STRTYPE
       NAM " Ok"
       DW CR
       DW STRTYPE
       NAM "> "
       DW EXIT

  COL @ERROR
       DW CR,TBUF,STYPE,SPACE,STAT,STYPE,CR,EXIT

  COL LOOPS                  ; LOOPS
        DW FOR,@RDROPX
@@LP1   DW J,EXECUTE,NEXT,@@LP1
@RDROPX DW RDROP,EXIT

 COL3 STRTYPE
 COL3 STYPE
 COL3 TYPE
       DW ASTR
       DW CSTR
       DW XDROP,LOOPS,CSTR,EMIT,EXIT

  XT UDIV,@_CALL
  XOR   CX,CX
@UMDIV:
  RCHG  CX
  RCHG  NR
  DIV   TOP
  RCHG  TOP
  RCHG  CX
  RET

  XT UMDIV,@_CALL
  D_TO  CX
  JMPS  @UMDIV

  XT MUL,@_CALL      ; UM*
  RCHG  TOP
  MUL   NR
  RCHG  NR
  RCHG  TOP
  RET

  XT  RP,@_DUP
  MOV   TOP,RSP
  RET

  XT  SP,@_DUP
  MOV   TOP,DSP
  RET

  COL WAIT
        DW SPACE,LIT,5CH,LIT,30,ACCEPT,DROP,DROP,EXIT


freemem:
  DW ENDMEM-FREEMEM-2
  ENTRY  '=:',ENTRY
  ENTRY  'CR',CR
  ENTRY  '=,',ENTRYC
  ENTRY  'EMIT',EMIT
  ENTRY  ':',COLON
  ENTRY  ';`',SEMICO
  ENTRY  ',<`',LPAR
  ENTRY  '>,',RPAR
  ENTRY  ',',COMMA
  ENTRY  '@',LD
  ENTRY  '!',ST
  ENTRY  '+',ADD
  ENTRY  '-',SUB
  ENTRY  'H.',HEXP
  ENTRY  '.',HP
  ENTRY  'SGN',SGN
  ENTRY  'DUP',DUP
  ENTRY  'WORD',WORD
  ENTRY  'HERE',HERE
  ENTRY  'OK.',OK
  ENTRY  'C!+',STBP
  ENTRY  'C@',LDB
;  ENTRY  '''',LOCATE
; ENTRY  'ALPHA',ALPHA
; ENTRY  ';HERE',HEREX
; ENTRY  'DROP;',DROPX
; ENTRY  '#DOES',DOES
  DB 0

EndMem:

lastw = ppppp

MyCseg  ends
        end  Start

;

;-----------------------------------------------

NF7      OUT     1725   1-30-15   5:38p
NF7      SN      4968   4-14-15   3:48p
NF7      SN1     4968   4-14-15   5:01p
NF7      SN2     5579   4-15-15  12:55p
NF7      SRT     1683  12-11-14  10:55p

