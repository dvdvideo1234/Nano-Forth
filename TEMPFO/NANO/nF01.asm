locals  @@
pd  equ dword ptr
pw  equ word  ptr
pb  equ byte  ptr

_TO =   -2
_AT =   -4
_VAL =  2

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
;        jmp  _nop
;      ENDM
SJMP  MACRO  LBL
        jmp  SHORT LBL
      ENDM
X     MACRO
        xchg sp,bp
      ENDM

qqqqq = 0
ppppp = qqqqq

nam    macro   msg
  local endstr
  db    endstr-$-1
  db    msg
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

;ln     macro   token
;ppppp = $
;  _nam  token
;  dw    qqqqq
;qqqqq = ppppp
;        endm

;head    macro  nam, lbl, val1
;        ln    nam
;        XT    LBL,VAL1
;        endm
;
;primitive macro nam,lbl
;        ln    nam
;        PRIM  lbl
;        endm
;
;primitiv macro nam,lbl,dat
;        ln    nam
;        XT    lbl,dat
;        endm
;
colon   macro  lbl
		XT		LBL,@nest
        endm

value   macro  nam,lbl,dat
        dw @setvar
        const lbl,dat
        endm

vectinc macro  lbl,dat
		DW  @setvar
lbl		dw 	@deferO,dat
        endm

defer 	macro  lbl,dat
lbl		xt 	lbl,@defer
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
		const 	lbl,dat
        ENDM

const  	macro lbl,dat
lbl     DW    @const,DAT
        endm

entry  	macro nam1,dat
        DW    DAT
        dw    0
        nam  nam1
        endm

MyCseg  segment para  use16
        assume cs: MyCseg,  ds: MyCseg, ss: MyCseg


        org 100h
Start   Label byte
        mov  bx,1000h     ; only 64k allocate
        mov  ah,4ah
        int  21h
restart:cld
        MOV  bp,-260
        mov  sp,-512
        call @forth
        DW LIT,12345,DD    ; !!!

        dw   lbrak,tib,count
xsyslp  dw   eval,OK,tib,FLAG,accept,br,xsyslp

states dw clit,num,comma,exec

; -----------------------
; Constants
; -----------------------

        CONST  zer,0
        CONST  oNE,1
        CONST  TWO,2
        CONST  BL,' '
        CONST  QM,'?'
        CONST  tbUF,-258

; -------------------
; Variables
; -------------------

        vectoR ACCEPT,ACPT
        vectoR OK,NOP
        vectoR key,dkey
        vectinc  emit,demit
        POINT  FOUND,0
        value  ltb,0
        value  etb,0
        value  cntc,0
        VALUE  tib,128
;       QUAN   IOB,0
        VALUE   here,freemem
        VALUE   last,SELF1

; -------------------

SELF2:  CALL MOVER

; -------------------
; Initialisation  and main loop
; -------------------

        XT nop,_nop

        COLON eval
        dw TOEVAL,ltb+_TO,etb+_TO
int:   dw TOKEN,0EX,here,found
        dw states,perform,br,_int

        XT QUIT,_RESTART

        COLON ABORT
        DW ZER,TIB,STOREP,QUIT

@forth: pop si
        next

 xt CMOVEU,DRP3_
        MOV  DI,BX
@CMOVEU:
        STD
		XCHG AX,SI
		cmpsb
		JMPS @CMOVE	
		
	XT 	CMOVE,DRP3_
        MOV  DI,BX
		XCHG AX,SI
@CMOVE: REP  MOVSB
        XCHG AX,SI
        CLD
        RET

        XT	MAKESTR,cnip_
		mov	 [BX],CL		; strlen
		XOR	 CH,CH
		LEA	 DI,[BX+1]
		ADD	 DI,CX
		mov	  [DI],'`'		;after str flag
@CPUSHU:
        ADD  AX,CX
		JMPS	@CMOVEU

XT 		CPUSHU,cnip_
        MOV  DI,BX
		sub		BX,CX
		JMPS	@CPUSHU
		
; ------------------------
; ENRTY LIST
; ------------------------

        COLON TOKEN
        dw BL,PARSE,BL,UMIN
        DW HERE,MOVSTR,CFETCHP,DROPX

        COLON ENTRY
        DW ZER,TOKEN,NZ?,HERE,COUNT
        DW LAST+_AT,STDSTR,STDB,STDW,EXIT

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
@NUM:   JCXZ EXNUM	
		XOR	 ax,ax
		lodsb
		DEC	 cx
		cmp  al,'9'+1
        jc   @n
        ;AND  Al,0DFH
        cmp  al,'A'      ; no case sensivity
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
	push  	di di     ;  START OF THE SOURCE
	JCXZ  	@@WEX
	REPNE 	SCASB
	JNE   	@@WEX
	DEC   	DI
@@WEX:          ; END OF THE SOURCE  IN DI
	POP		AX 	; START OF THE WORD
	xchg	ax,di
	SUB   	ax,di   ; LENGTH OF THE WORD
	mov		BX,cx	; CX REMAIN LENGTH OF THE BUFFER
	jmp		dx		;return

; -------------------
; Inner Interpreter
; -------------------

@DEFERO:INC   PW [CNTC+_AT]
@DEFER: push  bx
        MOV   bx,di
@perform:mov  bx,[bx]
@exec:  pop   ax
        xchg  ax,bx
        Sjmp  @nop1

@arD:   SHL   bx,1       ; array of Dwords
@arw:   SHL   bx,1       ; array of words
@arb:   ADD   bx,di ; array of bytes
@0:     SJMP  @MAIN

@colon:	cmp	  al,1
		xchg  ax,di
        Sjmp  pcpush
		
@topnt:	mov  [di],si
        Sjmp  @exit
		
@point:	mov   SI,[di+2]
        SJMP  @MAIN
		
@const:	mov   ax,[di]
        Sjmp  @pushw
		
@var2:	scasw
@var1:	scasw
@var: 	MOV   ax,di
        Sjmp  @pushw
		
        scasw
        scasw
@does:  pop   ax
        push  bx
        MOV   bx,di
@pcpush:XCHG  AX,SI
@rpush: dec   bp
        dec   bp
        mov   [bp],AX
        SJMP  @MAIN

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
@PHA:   PUSH  AX
        NEXT

@LDB:   MOV   AL,[BX]
@PHb:	MOV   AH,0
        JMP   @PHA
		
@setvar: mov   [di+2],bx
        Sjmp  @drop
		
@0ex:   or    bx,bx
        jNe   @DROP
@DROPX: pop   bx
@exit:  mov   si,Pw [bp]
@rdrop: inc   bp
        inc   bp
        next
		
DROP3_: POP   CX        ;DRP3
DROP2_: POP   AX        ;DRP2
DROP_:  CALL  DI        ;DRP
@drop:  pop   bx
        next
		
@push:  pop   ax
        xchg  ax,bx
        jmp   @rpush
@pop:   push  bx
        mov   bx,[bp]
        jmp   @rdrop
		
cnip_:  POP   cX
nip_:   POP   AX
nop_:   CALL  DI
		NEXT

@stp:   pop   [bx]
        db    0B9h
@ldp:   PUSH  [BX]
@2PX:   INC   BX
@1PX:   INC   BX
        jmp   @MAIN
		
; -------------------
; Inner Interpreter
; -------------------

;        SCASW
;_ard:   add   bx,bx
;_call:  lodsw
;        jmp   pcpush
;_toforth:pop  ax
;        jmp   pcpush
;_J:     MOV   DI,2
;        db    0B9h
;_I:     XOR   DI,DI
;        MOV   AX,[BP+DI]
;        SJMP  _PUSHW
;        _XT   DOES,DOVAR-1
;        scasw
;        scasw
;_SWPSTO:POP   DI
;        DB    0B9H
;_BRP:   PUSH  BX
;        SHL   BX,1
;        CMC
;        SJMP  _BR_DR
;_next:  SUB   Pw [bp],1
;        jNC   _jump
;        jmp   _SKIP
;_LIT:   LODSW
;        JMP   SHORT _PUSHW
;_BLIT:  LODSB
;        JMP   SHORT _PUSHB
;_CO:    xchg  si,[bp]
;        NEXT
;_XCHG:  XCHG  BX,[BP]
;        NEXT
;_NEG:   DEC   BX
;_NOT:   MOV   AX,0FFFFH
;        DB    0B9H
;_XOR:   POP   AX
;        XOR   BX,AX

; -------------------
; String
; -------------------

        XT  INC,drop_
		inc   Pw [bx]
        RET

        XT  DEC,drop_
		DEc   Pw [bx]
        RET

        XT STM,nip_
		mov   [BX-2],ax   ;  !.
@2m:	DEC   BX        ;  !-
@1m:    DEC   BX
		ret

;        _XT STB,_STB
;        XT  STW,nip_
;        jmp  xSTW

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

        XT  dkey,@dup
@DKEY:  mov  ah,7
        int  021h
        JMP  @LOBYTE

; -------------------
; Peek and Poke
; -------------------

;       _XT  STR,@dup
;       DB    0B9H
        XT  LDP,nup_
        MOV   AX,[BX]
        SJMP  @2

;       _XT  STORE,@2DROP
;       DB    0B9H
        xt  stp,nip_
@storep:MOV   PW [BX],AX
@2:     INC   BX
@1:     INC   BX
        RET

        XT  CST,DROP2_
        DB    0B9H
        xt  cstp,_nip
        MOV   [BX],AL
        JMP  @1

        XT  CLDP,nup_
         DB    0B9H
        XT  count,dup_
        JMP @COUNT

; -----------------------
; searching
; -----------------------

        XT find,dup_
        push  si
        mov   SI,[last+_AT]
        XOR   cX,CX
        DB    0B9H
        ;SJMP FINDN
FND:    add   si,cx
findN:  mov   di,bx
        MOV   DX,SI
        LEA   SI,[SI+3]
        mov   cl,[si]
        jcxz  not_fnd
        inc   cx
        repe  cmpsb
        jNZ   fnd
        MOV   BX,DX     ;fnd_ok:
        MOV   CX,BX
        MOV   BX,[BX]
not_fnd:xchg  ax,CX
        pop   si
        RET

; -------------------
; Maths / Logic / registers
; -------------------

        xt eqz,@nop
        CMP    BX,1
        SBB    BX,BX
        rET

        xt lit,@dup
        LODSW
        RET

        xt and,@nip
        AND   BX,AX
        RET

        XT UMIN,@nip
        CMP   AX,BX
        JNC   @@1
        XCHG  AX,BX
@@1:    RET

        xt plus,nip_
        ADD   BX,AX
        RET

        xt dec,@nop
        DEC   PW [BX]
        RET

        XT  TOEVAL,@ninu
        ADD   AX,BX
@NEG:   NEG   BX
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

  xt midiv,NINU_
		SHL		ax,1
		rcl		bx,1
		CMP		bx,dx
		jNC	@mi1
		sub		bx,dx
@mi1:	INC		AX
		RET
		
; -------------------
; Stack
; -------------------

        xt dup,@dup
        MOV AX,BX
        RET

        xt swap,@SwAp
        RET

        XT drop,@DROP
        xt pop,@pop
        xt push,@push

;        _COLON TIMES
;        DW 1M,BRM,_TMS2,PUSH
;_TMS:   DW J,EXECUTE,NEXT,_TMS,POP
;_TMS2:  DW RDROP,DROPX

; -----------------------
; Colon Definition
; -----------------------

        XT semicolon,_does0 ; ;`
        dw exit,lbrak

        XT colon,_does1     ; :
        dw docolon,rbrak

        XT colCoMP,_does0   ; :`
        dw SKIP,COLON

; -------------------
; Compilation
; -------------------

        XT  COMMA,HERE+_AT
        DW STOREP,EXIT

        xt litcom,_does0
          dw lit,comma

@does0: call @does  ; like ;
        dw wcomma,perform,exit

@does1: call @does  ; like :
        dw HERE,ENTRY,wcomma,perform,exit

        COLON wcomma
        dw fetchp,swap,comma,exit  ; 'w,',wcomma

        COLON clit
        dw num,litcom,exit

; -------------------
; Flow Control
; -------------------

        XT 0BR,DROP_
        SUB   bx,1
@ONC:   jC    @jump
@skip:  lodsw
        RET

        XT br,@NOP
@jump:  mov   si,[si]
        RET

        xt skip,NOP_
        JMP   @SKIP

        xt exec,_exec
        xt perform,_perform
        XT RDROP,_RDROP

        XT exit,_exit
        XT DROPx,_DROPX
        xt 0ex,_0ex

;        _xt 1Px,_1Px
;        _xt 2Px,_2Px

;        _xt call,_call
;        _xt for,_for
;        _xt next,_next

; -----------------------
; Dictionary Search
; -----------------------

        COLON tick
        DW TOKEN,NZ?,here,find,NZ?,exit

        COLON lbrak         ; interpreter search
        dw found+_TO,find,0br,num_chk,TRE,EXIT
num_chk:dw ONE,EXIT

        COLON rbrak         ; compiler search
        dw  found+_TO,FLAG,strpc
        dw  find,0br,comp_it,TRE,EXIT
comp_it dw  dec,find,0br,comp_num,TWO,EXIT
comp_num dw ZER,EXIT

        COLON num
        dw count,TOEVAL,number,Z?,EXIT

        COLON2 NZ?
        COLON2 Z?
        DW EQZ,0ex,qm,EMIT
        DW LIT,12345,DD    ; !!!
        DW ZER,LTB+_TO      ; !!!
        DW LIT,13,emit   ; !!!
        DW LIT,10,emit   ; !!!
        DW LIT,'!',emit   ; !!!
        DW abort

        xt states,_arw
        dw _states

; -----------------------
; Outer Interpreter TEST
; -----------------------

        COLON P
        DW KEY,DROP,EXIT

        COLON ?DUP  ; : ?DUP DUP 0; DUP ;
        DW DUP,0EX,DUP,EXIT

        COLON  DM  ; : #1 10 0SWAP U/MOD >DIG SWAP ;
        DW LIT,10,0SWAP,DIV,DIG,SWAP,EXIT

        COLON  DD         ; : .. #1 ?DUP IF .. THEN EMIT ;
        DW DM,?DUP,0BR,@DD,DD
@DD     DW EMIT,EXIT    ; : . DUP 0< IF '- EMIT NEG THEN .. ;

        xt 0swap,nup_
        xor ax,ax
        ret

        XT DIG,nop_
        CMP BL,10
        JL  @@1
        ADD BL,7
@@1:    ADD BL,'0'
        RET

;        XT DIV,@Dinu
;        DIV BX
;XDTOP:  MOV BX,DX
;        RET
;
;        XT MUL,@ninu
;        MUL BX
;        JMP XDTOP

freemem:
;  _entry   '.',DD
   entry   'BYE',0
   entry   'ENTRY',ENTRY
   entry   '',0   ; LAST WORD


lastw = ppppp

MyCseg  ends
        end  Start

