locals  @@
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


;PushReg  MACRO
;        jmp  _PushAx
;      ENDM
;SWAPREG MACRO
;         JMP _SWAPAX
;        ENDM
;DROPREG MACRO
;         JMP XDROP
;        ENDM
;next  MACRO
;        jmp  @MAIN
;      ENDM

JMPS  MACRO  LBL
        jmp  SHORT LBL
      ENDM

X     MACRO
        xchg sp,bp
      ENDM

MSG		macro   Amsg
  local endstr
  db    endstr-$-1
  db    Amsg
endstr  label   byte
        endm

VAR    macro   LBL,dat
		XT		LBL,@VAR
		DW      dat
        ENDM

PRIM   macro   LBL
		XT		LBL,$+2
        ENDM

XT     macro   LBL,token
LBL     DW      TOKEN
        ENDM

colon   macro  lbl
		XT		LBL,@colon
        endm

value   macro  lbl,dat
        dw @setvar
        cnst lbl,dat
        endm

vectinc macro  lbl,dat
		DW  @setvar
lbl		dw 	@deferO,dat
        endm

defer 	macro  lbl,dat
		xt 	lbl,@defer
		dw dat
        endm

vector macro  lbl,dat
		DW  @setvar
		defer lbl,dat
        endm

point  macro  lbl,dat
		DW		@point
lbl		dw		@topnt,dat
        endm

QUAN    MACRO  LBL,DAT
        DW     	@var2,@setvar
		cnst 	lbl,dat
        ENDM

vQUAN   MACRO  LBL,DAT
        DW     	@var2,@setvar
		defer 	lbl,dat
        ENDM

cnst  	macro lbl,dat
lbl     DW    @const,DAT
        endm

entr  	macro nam,dat	; DO ENTRY
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
@rst:	cld
        mov  sp,-768
@QUIT:	MOV  bp,-260
		call @troff
        call @forth
 ;       DW LIT,12345,DD    ; !!!

        dw  lbrak
xsyslp  dw	tib,entrance,eval,OK,br,xsyslp

; -----------------------
; Constants
; -----------------------

        CNST  TEN,10
        CNST  zer,0
        CNST  ALINE,64
        CNST  CBL,' '
        CNST  tbUF,-258

; -------------------
; Peek and Poke 
; -------------------

	PRIM  stp
		pop   [bx]
@2P:	INC   BX
@1P:	INC   BX
@MAIN1: jmp   @MAIN

	PRIM SKIPSTR
		PUSH	BX
		MOV		BX,[BP]
		call	@COUNT
		add		BX,AX
@XR:	xchg	BX,[BP]			;XR
        jmpS   @MAIN1

@XA:	xchg	DX,[BP]			;XA
        jmpS   @MAIN1

	XT LD,nop_				; @
		mov		BX,[BX]
		RET
		
	PRIM ldp   
		PUSH  [BX]
        jmpS   @2P

	PRIM ldM   
		PUSH  [BX-2]
@2M:	DEC   BX
@1M:	DEC   BX
        jmpS   @MAIN1
		
	PRIM  stM
		pop   [bx-2]
        JMPS @2M
		
	PRIM  CstM
		pop   AX
		MOV   [bx-1],AL
        JMPS @1M
		
@RSST:	POP		AX
		SKP1 CL
@RSLD:	push	BX
		xchg	SI,[BP]
		call	DI
@EX:	xchg	SI,[BP]
        jmpS   @MAIN1

;	XT  WST,DROP2_			; !
;		MOV   PW [BX],AX
;        RET
		
    XT  WSTR,dup_			;STR
        MOV   AX,[BX]
@2:     INC   BX
@1:     INC   BX
        RET

    XT  CST,DROP2_			; C!
		SKP2	CX
    xt  cstp,nip_			; C!+
        MOV   [BX],AL
        JMP  @1

    XT  count,dup_			; CSTR
        JMPS @COUNT

; -----------------------
; Terminal Input / Output
; -----------------------

        XT  acpt,SwAp_
        XCHG   AX,BX
        MOV    [BX],AX
        MOV    DX,BX
        MOV    AH,10
        INT    21H
        INC    BX
@COUNT: MOV    AL,[BX]
        INC    BX
@LOBYTE:MOV    AH,0
        RET

        XT  demit,DRoP_
@DEMIT:  xchg Bx,dx
        mov  ah,2
        int  021h
        RET

        XT  dkey,dup_
@DKEY:  mov  ah,7
        int  021h
        JMP  @LOBYTE

states dw @ARW,numBER,clit,perform,at_comma

; -------------------
; Variables
; -------------------

        vQUAN	key,dkey
		DW		@var2
        vectinc emit,demit
        defer 	ACCEPT,ACPT
        defer 	OK,NOOP
        defer 	errV,NOOP
        POINT  entrance,doINIT
        POINT  FOUND,0
        value  ltb,0
        value  etb,0
        value  cntc,0
        VALUE  tib,128
        VALUE   h,freemem
		QUAN	t,-2000

; -------------------
; Initialisation  and main loop
; -------------------

        COLON eval
        dw TOEVAL,ltb+_TO,etb+_TO
@EVALDO:dw TOKEN,?BR,@EVALX,Found
        dw states,perform,br,@EVALDO
@EVALX	DW DROPX

	XT QUIT,@QUIT
	
	XT ABORT,@RST 
	
; -------------------
; Memory
; -------------------

        XT	MAKESTR,cnip_
		mov	 [BX],CL		; SET strlen
		XOR	 CH,CH
		LEA	 DI,[BX+1]
		ADD	 DI,CX			; AFTER END ADDRESS
		mov	 PB [DI],'`'		;after str flag
@CPUSHU:
        ADD  AX,CX
@CMOVEU:
        STD
		XCHG AX,SI
		cmpsb
@CMOVE: REP  MOVSB
        XCHG AX,SI
        CLD
@troff:	RET

	XT	CPUSHU,cnip_
        MOV  DI,BX
		sub		BX,CX
		JMPS	@CPUSHU
		
	xt	CMOVEU,DROP3_
        MOV  DI,BX
		JMPS	@CMOVEU

	XT 	CMOVE,DROP3_
        MOV  DI,BX
		XCHG AX,SI
		JMPS @CMOVE	
		
; ------------------------
; ENRTY LIST
; ------------------------

	COLON LISTUP
		DW H,WSTR,T,CPUSHU,T+_TO,RTS

	COLON ENTRY
        DW TOKEN,ZEQ,Z?,TBUF,COUNT,STRP,T
        DW CPUSHU,ZSWAP,STM,STM,T+_TO,RTS

; ------------------------
; parsing
; ------------------------
; 	  si	cx BX
; 0 0 ADR LEN BASE  -> WLO WHI ADR1 LEN1 | LEN1 <> 0 ERR [ADR1] = UNVALUED CHAR 

        XT  numb,Dinu_
        push BP SI
		mov	 BP,SP
        xchg ax,SI  ; ENDBUF
		dec	BX
		dec	BX
		mov	BH,AH
		INC	BX
		INC	BX
        CALL @NUM
        XCHG SI,AX
        POP  SI BP
		mov	 BX,CX
@EXNUM:	RET

@Nm:	mov	DI,[BP+4]	;HI
        xchg ax,DI
        mul  BX
		push	AX
		mov	 AX,[BP+6]	;LO
        mul  BX
		ADD	 AX,di
		pop	 DI
		ADC	 DX,DI
		mov	 [BP+4],DX	
		mov	 [BP+6],AX	
@NUM:   JCXZ @EXNUM	
		XOR	 ax,ax
		lodsb
		DEC	 cx
		cmp  al,'9'+1
        jc   @n
        ;AND  Al,0DFH	; no case sensivity
        cmp  al,'A'      
        jc   @EXNUM2
        sub  al,7
@n:		sub  al,'0'
        cmp  ax,BX
        jc   @NM
@EXNUM2:
		INC	 cx
		DEC	 si
        RET

; CHAR buflen ADR -> ADR1 LEN1 buflen1
  XT PARS,Dinu_
	pop dx			; retadr
	mov		DI,BX
	SUB  	DI,CX	   
	CMP  	AL,' '
	JNE  	@@SKIPX
	JCXZ 	@@SKIPX
	REPE 	SCASB
	JE   	@@SKIPX
	DEC  	DI
	INC  	CX
@@SKIPX:
	push  	di di     ;  START OF THE WORD
	JCXZ  	@@WEX
	REPNE 	SCASB
	JNE   	@@WEX
	DEC   	DI
@@WEX:          ; END OF THE WORD  IN DI
	POP		AX 	; START OF THE WORD
	xchg	ax,di
	SUB   	ax,di   ; LENGTH OF THE WORD
	mov		BX,cx	; CX REMAIN LENGTH OF THE BUFFER
	jmp		dx		;return

 colon PARSE
	dw ltb,etb,pars,etb+_to,RTS
	
 colon Aword
	dw parse,tbuf,makestr,RTS

 colon token
	dw Cbl,Aword,ldb,rts
	
; -------------------
; Inner Interpreter
; -------------------

@forth: pop si
        JMPS  @MAIN

@DEFERO:INC   PW [CNTC+_AT]
@DEFER: push  bx
        MOV   bx,di
@perform:mov  bx,[bx]
@exec:  pop   ax
        xchg  ax,bx
        JMPS  @nop1

@arD:   SHL   bx,1       ; array of Dwords
@arw:   SHL   bx,1       ; array of words
@arb:   ADD   bx,di ; array of bytes
		JMPS  @MAIN

noop:
@colon:	cmp	  al,1
		xchg  ax,di
        JMPS  @pcpush
		
@topnt:	mov  [di],si
        JMPS  @RET
		
@point:	mov   SI,[di+2]
        JMPS  @MAIN
		
@const:	mov   ax,[di]
        JMPS  @pushw
		
@var2:	scasw
@var1:	scasw
@var: 	MOV   ax,di
        JMPS  @pushw
		
@does2: scasw
@does1: scasw
@does:  pop   ax
        push  bx
        MOV   bx,di
@pcpush:XCHG  AX,SI
@rpush: dec   bp
        dec   bp
        mov   [bp],AX
        JMPS  @MAIN

SWAP_:  POP   AX           ; NIP DUP SWAP
DUP_:   CALL  DI
@pushw: push  bx
@swapw: xchg  ax,bx

@MAIN:	lodsw
@nop1:  xchg  di,ax
        LEA   DI,[DI+2]    ; !!!
        jmp   Pw [di-2]    ; !!!

DINU_:  POP   CX
NINU_:  POP   AX
NUP_:   CALL  DI
@NUP:   PUSH  AX
        JMPS  @MAIN

	prim ldb
@LDB:   MOV   AL,[BX]
@PHb:	MOV   AH,0
        JMPS  @pushw
		
@setvar: mov   [di+2],bx
        JMPS  @drop
		
@0ex:   or    bx,bx
        jNe   @DROP
@DROPX: pop   bx
@RET:  mov   si,Pw [bp]
@rdrop: inc   bp
        inc   bp
        JMPS  @MAIN
		
DROP3_: POP   CX        ;DRP3
DROP2_: POP   AX        ;DRP2
DROP_:  CALL  DI        ;DRP
@drop:  pop   bx
        JMPS  @MAIN
		
@FOR:	mov   SI,[SI]
@push:  pop   ax
        xchg  ax,bx
        jmp   @rpush
@pop:   push  bx
        mov   bx,[bp]
        jmpS  @rdrop
		
cnip_:  POP   cX
nip_:   POP   AX
nop_:   CALL  DI
        JMPS  @MAIN

; -------------------
; Inner Interpreter
; -------------------

; String
; -------------------

@DBG:	jmp	@MAIN1		; PREPARE SPACE AND ADDRESS

    XT STRP,niNU_
		INC	ax
		DEC   BX
		ret
		
;    XT STRM,niNU_
;		INC	Bx
;		DEC AX
;		ret
		
; -----------------------
; searching
; -----------------------

  XT find,NINU_
@FIND:  
	push  SI	
	MOV   DI,BX	
    XOR   cX,CX
    SKP2  SI
@FND:
	add   DI,cx
	mov   Bx,DI
    LEA   DI,[DI+4]
    mov   cl,[Di]
    jcxz  @not_fnd
    inc   cx
	MOV   SI,AX
    repe  cmpsb
    jNZ   @fnd
	mov	  CL,2		;fnd_ok:
    ADD	  [BX+2],CX
	xchg  AX,BX	
@not_fnd:
	POP	  SI
	MOV  Bx,CX
    RET

  XT Cfind,NINU_
	mov	DI,ax
	push	BX 
	INC		PB [DI]
	call	@FIND
	pop		DI
	DEc		PB [DI]
	JCXZ  @FND2
	RET
@FND2:	
	mov		BX,DI
	call	@FIND
	INC		bx
	RET

; -------------------
; Maths / Logic / registers
; -------------------

        xt Zeq,nop_
        CMP    BX,1
@SBB:   SBB    BX,BX
        rET

        xt lit,dup_
		LODSW
        RET

        xt andW,nip_
        AND   BX,AX
        RET

        xt XORW,nip_
        XOR   BX,AX
        RET

        xt ULESS,nip_
        SUB   AX,BX
        JMPS @SBB

;        XT UMIN,nip_
;        CMP   AX,BX
;        JNC   @@1
;        XCHG  AX,BX
;@@1:    RET
;
;    xt decW,drop_
;        DEC   PW [BX]
;        RET
;
;    xt INCW,drop_
;        INC   PW [BX]
;        RET

        XT  TOEVAL,ninu_
        ADD   AX,BX
        RET

  xt pl2div,NINU_
		ADD	ax,bx
		mov	bx,AX
		rcr	bx,1
		RET

  xt plmul,NINU_
		TEST	al,1
		jz	@pl1
		ADD		bx,dx
@pl1:	rcr		bx,1
		rcr		ax,1
		RET

  xt midiv,NINU_			; -/
		SHL		ax,1
		rcl		bx,1
		CMP		bx,dx
		jNC	@mi1
		sub		bx,dx
@mi1:	INC		AX
		RET
		
; -------------------
; TRANSFER
; -------------------

  XT	RLDP,@RSLD				;@R+
		JMPS	@RSTP

  XT	RSTP,@RSST				;!R+
		mov		[SI],bx
@RSTP:	xchg	AX,bx
		LODSW
		RET

; -------------------
; Stack
; -------------------

        xt dupW,dup_
        MOV AX,BX
        RET

        xt j,dup_
        MOV AX,[Bp+2]
        RET

        xt swap,SwAp_
        RET

        XT drop,@DROP
        xt popW,@pop
        xt pushW,@push

        xt ZSWAP,nup_
        xor ax,ax
        ret

;        _COLON TIMES
;        DW 1M,BRM,_TMS2,PUSH
;_TMS:   DW J,EXECUTE,NEXT,_TMS,POP
;_TMS2:  DW RDROP,DROPX

; -----------------------
; Colon Definition
; -----------------------

    COLON COMPILE
		DW RLDP,COMMA,RTS
		
@COMPERF: 
		call @does  ; STR , PERFORM
        dw WsTR,comma,perform,RTS

    COLON  AT_COMMA
		DW LD
    COLON  COMMA
        DW H,STP,H+_TO,RTS

    xt litcom,@COMPERF
          dw lit,comma

    COLON clit
        dw number,litcom,RTS

; -------------------
; Compilation
; -------------------

    COLON SEMI						;  "," !!!
		DW COMPILE,RTS
	COLON lbrak         ; interpreter search
        dw found+_TO,T,find,RTS

    COLON COL						;  ":" !!!
		DW H,ENTRY,COMPILE,@colon
	COLON rbrak         ; compiler search
        dw  found+_TO,T,CFIND,RTS

; -------------------
; Flow Control
; -------------------

    XT ZBR,NOP_			; (#IF		DOES NOT CHANGES DATA STACK
		SKP2 CX

    XT ?BR,DRoP_		; (IF
		or		BX,BX
		jZ	@jump
@skip:  lodsw
        RET

    XT MIF,NOP_			; (MIF		DOES NOT CHANGES DATA STACK
		INC		BX
@IFM:	DEC		BX
		JS	@SKIP
@jump:  mov   si,[si]
        RET
		
	XT br,NOP_
		jMPS @jump

	XT IFM,NOP_			; (MIF	
		JMPS @IFM

	XT NEXT,NOP_			; (NEXT		DOES NOT CHANGES DATA STACK
		DEc	PW [BP]
		JMPS @IFM+1

;        xt skip,NOP_
;        JMP   @SKIP

;        xt exec,@exec
        xt perform,@perform
;        XT RDROP,@RDROP

        XT RTS,@RET
        XT DROPx,@DROPX
        xt ZRET,@0ex
        xt EX,@ex

;        _xt 1Px,_1Px
;        _xt 2Px,_2Px

;        _xt call,_call
;        _xt for,_for
;        _xt next,_next

; -----------------------
; Dictionary Search AND ERRORS
; -----------------------

doINIT:
		dw count,LISTUP,entrance+_to,NOOP,ALINE,accept,rts

	COLON Z?					; ?ABORT
		DW SKIPSTR,SWAP,?BR,@EVALX,ERRV,ABORT

    COLON number
        dw ZSWAP,ZSWAP,count,TEN,numb,Z?
		MSG "?"
		DW	DROP,DROPX


freemem:
	dw lastw-freemem
;  _entry   '.',DD
;   entr   'BYE',ZER+2,0
   entr   '=:',ENTRY,0
   entr   '',0,0   ; LAST WORD


lastw = $

MyCseg  ends
        end  Start

; -----------------------
; Outer Interpreter TEST
; -----------------------
		
        XT DIG,nop_
        CMP BL,10
        JL  @@1
        ADD BL,7
@@1:    ADD BL,'0'
        RET

;   :     XT DIV,@Dinu
;        DIV BX
;XDTOP:  MOV BX,DX
;        RET
;
;        XT MUL,@ninu
;        MUL BX
;        JMP XDTOP

        COLON P
        DW KEY,DROP,RTS

        COLON ?DUP  ; : ?DUP DUP 0; DUP ;
        DW DUPW,ZRET,DUPW,RTS

        COLON  DM  ; : #1 10 ZSWAP U/MOD >DIG SWAP ;
        DW LIT,10,ZSWAP,UDIVMOD,DIG,SWAP,RTS

        COLON  NDOT         ; : .. #1 ?DUP IF .. THEN EMIT ;
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

		

