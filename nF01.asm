;locals  @@
pd  equ dword ptr
pw  equ word  ptr
pb  equ byte  ptr

_TO =   -2
_AT =   -4
_VAL =  2

SKP2   MACRO reg
LOCAL ADR,DIFF
ADR = $
        mov   reg,0
DIFF = $-ADR-3
        IF DIFF
                NOT_WORD_REGISTR
        ENDIF
        org   $-2
    ENDM

SKP1   MACRO reg
LOCAL ADR,DIFF
ADR = $
        mov   reg,0
DIFF = $-ADR-2
        IF DIFF
                NOT_BYTE_REGISTR
        ENDIF
        org   $-1
    ENDM


JMPS  MACRO  LBL
        jmp  SHORT LBL
      ENDM

X   MACRO
	xchg sp,bp
  ENDM

MSG	macro   Amsg
  local endstr
  db    endstr-$-1
  db    Amsg
endstr  label   byte
  endm

Col3   macro  lbl
LBL DW  @NEST3
  endm

col2   macro  lbl
LBL DW  @NEST2
  endm

col    macro  lbl
LBL DW  @NEST
  endm

RVAR3  macro  lbl
LBL: DW  @PUSHW3
  endm

RVAR2  macro  lbl
LBL: DW  @PUSHW2
  endm

RVAR   macro  lbl
LBL: DW  @PUSHW
  endm

VAR macro   LBL,dat
	XT	LBL,@@VAR
	DW  dat
  ENDM

PRIM   macro   LBL
	XT	LBL,$+2
  ENDM

XT     macro   LBL,token
LBL DW      TOKEN
  ENDM

value   macro  lbl,dat
	dw @@setvar
	cnst lbl,dat
  endm

defCNT macro  lbl,dat
	xt lbl,@@DEFCNT
	dw  dat
  endm

defer   macro  lbl,dat
	xt lbl,@@defer
	dw dat
  endm

vector macro  lbl,dat
	DW  @@setvar
	defer lbl,dat
  endm

point  macro  lbl,dat
	DW	@@topnt
lbl dw  @@point,dat
        endm

QUAN    MACRO  LBL,DAT
	DW  @@var-2,@@setvar
	cnst	lbl,dat
  ENDM

vQUAN   MACRO  LBL,DAT
	DW	@@var-2,@@setvar
	defer   lbl,dat
  ENDM

cnst    macro lbl,dat
lbl	DW    @@const,DAT
  endm

entr  macro nam,dat   ; DO ENTRY
	DW    DAT,0
	MSG  nam
  endm

; INSTR: RTS XR XA RSTP RLDP (IF JUMP +2/ +* -/ PUSH POP DUP J (IF- NAND

MyCseg  segment para  use16

        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg


        org 100h

Start   Label byte
        mov  bx,1000h     ; only 64k allocate
        mov  ah,4ah
        int  21h
@@rst:  cld
        mov  sp,-768
@@QUIT: MOV  bp,-260
        call @@troff
        call @@forth
        dw  lbrak
@@syslp  dw  tib,INIT_,eval,OK,br,@@syslp

; -----------------------
; Constants
; -----------------------

	defer ACCEPT,@@ACPT
	defer errV,NOOP
	defer   OK,NOOP
	CNST  ALINE,64
	cnst  NUMA,0

; -------------------
; Peek and Poke
; -------------------

  PRIM  stp
        pop   [bx]
@2P:    INC   BX
@1P:    INC   BX
@@MAIN1:jmp   @MAIN			; @@MAIN1 MUST BE EQU TO $13C

  XT LD,@@nop_                              ; @
	mov  BX,[BX]
    RET

;  PRIM ldp
;    PUSH  [BX]
;    jmpS   @2P

  PRIM  stM
	pop   [bx-2]
@2M:
    DEC   BX
@1M:
    DEC   BX
	jmpS   @@MAIN1

;@@SCAN:	POP CX AX
;	XCHG  BX,DI
;	xchg  AX,DI	
;	PUSH	CX
;	call  BX
;	POP	  BX
;	JE @@SCAN1
;	mov	CX,BX
;@@SCAN1:
;	INC CX
;    SUB  BX,CX
;	jmpS   @1P

;  PRIM  CstM
;	pop   AX
;	MOV   [bx-1],AL
;	JMPS @1M

;  XT  SWAPST,@@DROP2_               ; SWAP!
;	xchg AX,BX
;;	SKP2 DI
;
  XT  STW,@@DROP2_   ; !
	STOSW
	RET

;  XT  CST,@@DROP2_                   ; C!
;	SKP2 DI
;  xt  cstp,@@nip_                    ; C!+
;    MOV   [BX],AL
;    JMPS  @@1

; -------------------
; TRANSFER
; -------------------

@@RSST:
	POP	AX
	xchg    AX,bx
	SKP1 CL
@@RSLD:  
	push    BX
	xchg    SI,[BP]
	call    DI
@@EX:
    xchg    SI,[BP]
    jmpS   @@MAIN1

@XA:
    xchg    DX,[BP]                 ;XA
    jmpS   @@MAIN1

  xt STRS,@@RSLD					; string skip
	MOV     BX,si
	XOR		ah,ah
	lodsb
	add		si,AX
	ret

@XR:
	xchg    BX,[BP]                 ;XR
    jmpS   @@MAIN1

  XT	RLDP,@@RSLD                 ;@R+
	LODSW
	xchg    AX,bx
	RET

  XT    RSTP,@@RSST                 ;!R+
	mov		[SI],AX
	LODSW
	RET

  XT    CRSTP,@@RSST                 ;C!R+
	mov		[SI],AL
	INC		SI
	RET

  XT  ldp,@@nup_                   ; @+
	skp2 di
  XT  WSTR,@@dup_                   ;STR
    MOV   AX,[BX]
@@2: INC   BX
@@1: INC   BX
	RET

  XT  ldpb,@@nup_                   ; C@+
	skp2 di
  XT  count,@@dup_                   ; CSTR
    JMPS @@COUNT

; -----------------------
; Terminal Input / Output
; -----------------------

  XT  @@acpt,@@SwAp_
	XCHG   AX,BX
	MOV    [BX],AX
	MOV    DX,BX
	MOV    AH,10
	INT    21H
	INC    BX
@@COUNT:
	MOV    AL,[BX]
	INC    BX
@@LOBYTE:
	MOV    AH,0
	RET

  XT  demit,@@DRoP_
	mov dx,DI
	mov  ah,2
	int  021h
	RET

  XT  dkey,@@dup_
	mov  ah,7
	int  021h
	JMPs  @@LOBYTE

  XT DUPC@,@@DUP_
     MOV  AL,[BX]
	JMPs  @@LOBYTE
	 

states dw @@ARW,numBER,clit,perform,at_comma

; -------------------
; Variables
; -------------------

	POINT  	INIT_,doINIT
	POINT  	FOUND,0
	value  	ltb,0
	value  	etb,250

		DW @@SETVAR
	defer   key,dkey
		DW @@SETVAR
	defCNT  emit,demit
	value  	cntc,0
	value  	tbUF,-258
	VALUE  	tib,128
		DW @@SETVAR
XBEGIN:		
	CNST    h,@@freemem
	VALUE   ERRMSG,0
	VALUE   t,-2000
	
  COL TRET
	DW T,EX,T+_TO,RTS
	
;  COL HRET
;	DW H,EX,H+_TO,RTS

; -------------------
; Initialisation  and main loop
; -------------------

  COL eval
        dw TOEVAL,ltb+_TO,etb+_TO
  COL evaldo
@@EVALDO:
	dw TOKEN,?BR,@@EVALX,Found
    dw states,perform,br,@@EVALDO
	
@@EVALX  DW DROPX

  XT QUIT,@@QUIT
  
  XT ABORT,@@RST

; -------------------
; Memory
; -------------------

  XT	MAKESTR,@@cnip_
	mov [BX],CL                ; SET strlen
	XOR CH,CH					; CUT LEN TO 255
	LEA DI,[BX+1]
	ADD DI,CX                  ; AFTER END ADDRESS
	mov PB [DI],'`'            ;after str flag
@@CPUSHU:
	ADD  AX,CX
@@CMOVEU:
	STD
	DEc	AX
	DEC DI
@@CMOVE:
	XCHG AX,SI
	REP  MOVSB
	XCHG AX,SI
	CLD
@@troff: 
	RET

  XT    CPUSHU,@@cnip_
	MOV DI,BX
	sub	BX,CX
	JMPS @@CPUSHU

  xt	CMOVEU,@@DROP3_
	JMPS @@CMOVEU

  XT	CMOVE,@@DROP3_
	JMPS @@CMOVE

; ------------------------
; ENRTY LIST
; ------------------------
  COL STRT
	dw count,STRP
  COL memUP
	DW TRET,CPUSHU,RTS

  COL2 ENTRYH                        ; =H    HEADER
  COL2 ENTRY                         ; =:    ALIAS
    DW H	
	DW TOKEN?,STRT,TRET,ZSWAP,STM,STM,RTS

; ------------------------
; parsing
; ------------------------
; si  cx 
; ADR LEN -> NUM LEN1 | LEN1 <> 0 ERR [ADR1] = UNVALUETED CHAR

  XT  numb,@@Binu_
	push 	SI
	xchg 	ax,SI  	; START ADR
	mov		BL,10	; NUM BASE
	XOR		ax,ax
	XOR		DI,DI	; ZERO ACCUM
	CALL @@NUM
	XCHG	DI,AX	; RESULT NUMBER IN AX
	mov		NUMA+_VAL,SI
	POP 	SI
	mov		BX,CX
@@EXNUM: 
	RET

@@Nm:xchg 	ax,DI
    mul  	BX
	xchg 	ax,DI
    ADD		DI,AX
@@NUM:   JCXZ @@EXNUM
	lodsb
	DEC      cx
	CMP		AL,'$'
	JNE	@@NM2
	mov		BL,16
	JMPS	@@NUM
@@NM2:
	cmp  	al,'9'+1
	jc   @@n
	;AND  Al,0DFH   ; no case sensivity
	cmp  al,'A'
	jc   @@EXNUM2
	sub  al,7
@@n: sub  al,'0'
	cmp  ax,BX
	jc   @@NM
@@EXNUM2:
	INC      cx
	DEC      si
	RET

; ADR buflen  -> ADR1 LEN1 buflen1
  XT PARS,@@drop_
    pop   Bx cx
	XCHG  DI,CX
	SUB     DI,CX
	mov	AL,' '
	inc CX
@@P1:
	DEC	CX
	JZ @@PSKIPX
	SCASB
	JAE @@P1       ;{ SPACE IS ABOVE OR EQUAL TO }
	DEC     DI
@@PSKIPX:
	push    di  di  ;{;  START OF THE WORD}
	JCXZ @@PWEX
	inc CX
@@P3:
	DEC	CX
	JZ @@PWEX        ; END OF THE WORD  IN DI
	SCASB           ;{ SPACE IS BELOW THEN}
	JB @@P3
	DEC     DI
@@PWEX:          ;{; END OF THE WORD  IN DI}
	POP	AX      ;{; START OF THE WORD}
	SUB     di,ax   ; LENGTH OF THE WORD
	push  di cx
	jmp Bx             ;return

;  XT SCANB,@@SCAN
;	REPNE SCASB
;	RET

  COL3 token?
  COL3 token
  COL3 PARSE
	DW XTOK?,XSETSTR
    dw etb,ltb,pars,ltb+_to,RTS
		
  RVAR XSETSTR
	DW tbuf,makestr,RTS

; -------------------
; Inner Interpreter
; -------------------

@@forth:
	pop si
	JMPS  @MAIN

@@DEFCNT:
	INC   PW [CNTC+_VAL]
@@DEFER:
	push  bx
	MOV   bx,di
@@perform:
	mov	bx,[bx]
@@EXEC: 
	mov	DI,bx	
	pop Bx
	SCASW
	JMPS  @@nop1

		SHL   bx,1       ; array of Dwords
@@arw:  SHL   bx,1       ; array of words
		ADD   bx,di ; array of bytes
		JMPS  @MAIN


@NEST3:
  SCASW
@NEST2:
  SCASW
noop:
@NEST: cmp   al,1
        xchg  ax,di
        JMPS  @@pcpush

@@topnt: 
	mov   [di+2],si		; LIKE RETURN
	JMPS  @@RET

@@point:
	mov   AX,[di]		; LIKE COLON
	JMPS  @@pcpush

@@const:mov   ax,[di]
        JMPS  @@pushw

		scasw
		scasw
@@var:   MOV   ax,di
        JMPS  @@pushw
		
@PUSHW3:
  SCASW
@PUSHW2:
  SCASW
@PUSHW:
  xchg	AX,DI
  JMPS  @@rpush
  
		scasw
		scasw
@@does:  pop   ax
        push  bx
        MOV   bx,di
@@pcpush:XCHG  AX,SI
@@rpush: dec   bp
        dec   bp
        mov   [bp],AX
        JMPS  @MAIN

;@@DUPBX:
;	PUSH  BX
@@SWAP_:  
	POP   AX           ; NIP DUP SWAP
@@DUP_:   
	CALL  DI
@@pushw: 
	push  bx
	xchg  ax,bx

@MAIN:
	mov	DI,[SI]
	CMPSW
@@nop1:	
	jmp   Pw [di-2]    ; !!!

@@BINU_:  PUSH BX
@@DINU_:  POP   CX
@@NINU_:  POP   AX
@@NUP_:   CALL  DI
		PUSH  AX
        JMPS  @MAIN

@@setvar: mov   [di+2],bx
        JMPS  @@drop

@@0ex:   or    bx,bx
        jNe   @@DROP
@@DROPX: pop   bx
@@RET:   mov   si,Pw [bp]
@rdrop: inc   bp
        inc   bp
        JMPS  @MAIN

@@DROP3_: POP   CX        ;DRP3
@@DROP2_: POP   AX        ;DRP2
@@DROP_:  xchg	DI,BX
@@CALDR:  CALL  BX        ;DRP
@@drop:   pop   bx
        JMPS @MAIN

@FOR:   mov   SI,[SI]
@@push:  pop   ax
        xchg  ax,bx
        jmps @@rpush
		
@@pop:   push  bx
        mov   bx,[bp]
        jmpS  @rdrop

@@cnip_:  POP   cX
@@nip_:   POP   AX
@@nop_:   CALL  DI
        JMPS @MAIN

; -------------------
; Inner Interpreter
; -------------------

; String
; -------------------

@DBG:   jmp     @@MAIN1          ; PREPARE SPACE AND ADDRESS

  XT STRP,@@niNU_
    INC   ax
    DEC   BX
    ret

;    XT STRM,niNU_
;               INC     Bx
;               DEC AX
;               ret

; -----------------------
; searching
; -----------------------

  XT find,@@NINU_
    mov   DI,ax
@@FIND2:
    push  SI
	mov	  si,bx
    XOR   cX,CX
@@FND:
    add   sI,cx
    mov   Bx,sI
    LEA   sI,[sI+4]
    mov   cl,[sI]
    jcxz  @@not_fnd
    inc   cx
    push  di
    repe  cmpsb
	pop   di
    jNZ   @@fnd
    mov   CL,2          ;fnd_ok:
    ADD   [BX+2],CX
    xchg  AX,BX
@@not_fnd:
    POP   SI
    MOV   Bx,CX
    RET

  XT Cfind,@@NINU_
    mov   DI,ax
    push  bx 
    INC   PB [DI]
    call  @@FIND2
    DEc   PB [DI]
    JCXZ  @@FND2
	pop   di
    RET
@@FND2:
	pop   bx
    call  @@FIND2
    INC   bx
    RET

; -------------------
; Maths / Logic / registers
; -------------------

  xt Zeq,@@nop_
    CMP    BX,1
@@SBB:
    SBB    BX,BX
    rET

  xt ULESS,@@nip_
    SUB   AX,BX
    JMPS @@SBB

  xt ZLESS,@@nop_
    SHL  BX,1
    JMPS @@SBB

  xt lit,@@dup_
    LODSW
    RET

  xt Nand,@@nip_
    AND   BX,AX
	NOT   BX
    RET

  xt XORW,@@nip_
    XOR   BX,AX
    RET

  XT  TOEVAL,@@ninu_
    ADD   AX,BX
    RET

  xt pl2div,@@NINU_
	ADD     ax,bx
	mov     bx,AX
	rcr     bx,1
	RET

  xt plmul,@@NINU_
	TEST	al,1
	jz	@@pl1
	ADD	bx,dx
@@pl1:
	rcr	bx,1
	rcr	ax,1
	RET

  xt midiv,@@NINU_                        ; -/
	SHL	ax,1
	rcl	bx,1
	CMP	bx,dx
	jNC	@@mi1
	sub	bx,dx
	INC	AX
@@mi1:
	RET

; -------------------
; Stack
; -------------------

  xt dupW,@@dup_
    MOV AX,BX
    RET

  xt j,@@dup_
    MOV AX,[Bp+2]
    RET

;  xt nip,@@nip_
;    RET

  XT drop,@@DROP
  xt popW,@@pop
  xt pushW,@@push

  xt ZSWAP,@@nup_
    skp2 ax
BYE dw 0	
    ret

CSWAP:
  xt SWAP,@@SWAP_
    ret

; -----------------------
; COL Definition
; -----------------------

  COL COMPILE
	DW RLDP,COMMA,RTS

@@COMPERF:
	call @@does  ; STR , PERFORM
    dw WsTR,comma,perform,RTS

  RVAR3 XCOMMA
  COL2  AT_COMMA
XREL:	
  COL2  COMMA
    DW LD
    DW H,STP,_TO+H,RTS

  xt litcom,@@COMPERF
    dw lit,comma

  COL clit
    dw number,litcom,RTS

; -------------------
; Compilation
; -------------------

  RVAR2 XTHEN
  COL DOTHEN
	DW H,SWAP,STW,RTS

  COL2 TFIND?
  COL2 TFIND
	DW XNZ?
    DW T,find,RTS
  
  COL SEMI                        ;  "," !!!
	DW COMPILE,RTS
	
  COL lbrak         				; interpreter search			; 	
	dw found+_TO,Tfind,RTS

COLC:								; ":`" ON COMPILE TIME
  COL COLON                         ;  ":" !!!
	DW ENTRYH,COMPILE,@NEST
	
  COL rbrak         				; compiler search
	dw  found+_TO,T,CFIND,RTS

; -------------------
; Flow Control
; -------------------

  XT ?BR,@@DRoP_                ; (IF
	or	DI,DI
	jZ	@@jump
	jMPS @@jump

  XT IFM,@@NOP_                     ; (MIF
	DEC	BX
	JNS	@@jump
@@skip:  lodsw
	RET

  XT br,@@NOP_
@@jump:  
	mov   si,[si]
	RET

  xt perform,@@perform
  XT RTS,@@RET
  XT DROPx,@@DROPX
  xt ZRET,@@0ex
  XT EXEC,@@EXEC
  XT EX,@@EX

; -----------------------
; Dictionary Search AND ERRORS
; -----------------------

doINIT:
	dw STRT,H,WSTR,memUP,evaldo,INIT_+_to
	DW ALINE,accept,rts

  RVAR3 XTOK?                        ; ;TOK?
  RVAR3  XNZ?                          ; #??
  RVAR3  XZ?                           ; ??
        DW DUPC@        ; DUP C@
        DW ZEQ         ; LOGICAL INVERT -> #0 IS OK
	DW ERROR?
	MSG "?"
	DW	RTS

  COL ERROR?	; ?ABORT
	DW STRS,ERRMSG+_TO,ZRET,ERRV,ABORT

  COL number
	dw  count,numb,XZ?,RTS


@@freemem:
        dw @@lastw-@@freemem
   entr   '=:',ENTRY,0
   entr   '',0,0   ; LAST WORD


@@lastw = $

MyCseg  ends
        end  Start

; -----------------------
; Outer Interpreter TEST
; -----------------------

        XT DIG,@@nop_
        CMP BL,10
        JL  @@11
        ADD BL,7
@@11:   ADD BL,'0'
        RET

;   :     XT DIV,@Dinu
;        DIV BX
;XDTOP:  MOV BX,DX
;        RET
;
;        XT MUL,@ninu
;        MUL BX
;        JMP XDTOP

        COL P
        DW KEY,DROP,RTS

        COL ?DUP  ; : ?DUP DUP 0; DUP ;
        DW DUPW,ZRET,DUPW,RTS

        COL  DM  ; : #1 10 ZSWAP U/MOD >DIG SWAP ;
        DW LIT,10,ZSWAP,UDIVMOD,DIG,SWAP,RTS

        COL  NDOT         ; : .. #1 ?DUP IF .. THEN EMIT ;
        DW DM,?DUP,?BR,@DD,NDOT
@DD     DW EMIT,RTS    ; : . DUP 0< IF '- EMIT NEG THEN .. ;

;        COLON2 NZ?
;        COLON2 Z?
        DW EQZ,ZReT,qm,RTS
;        DW LIT,12345,DD    ; !!!
        DW ZER,LTB+_TO      ; !!!
        DW LIT,13,emit   ; !!!
        DW LIT,10,emit   ; !!!
        DW LIT,'!',emit   ; !!!
        DW abort

