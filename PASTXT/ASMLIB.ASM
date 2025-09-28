LOCAL @@


code segment 'CODE'
     assume  cs: code


INCPTR:
  INC   WORD PTR ES:[BX]
  LES   DI,ES:[BX]
  RET

       public  DigChar

DigChar  PROC FAR
  pop  cx DI
    POP  AX
  PUSH DI CX

    cmp   al,10
    jb    @@1
    add   al,7
@@1:
    add   al,'0'
    RET

DigChar     ENDP


;function getc(var where: pchar): char; assembler;

        public  GETC
GETC PROC FAR
  pop  cx DI
    POP  BX ES
  PUSH DI CX
  CALL  INCPTR
  MOV   AL,ES:[DI-1]
  RET

GETC    ENDP

;  procedure putc(what: char; var where: pchar);assembler;
;  asm

        public  PUTC
PUTC PROC FAR
  pop  cx DI
    POP  BX ES AX
  PUSH DI CX
  CALL  INCPTR
  DEC   DI
  STOSB
  RET

PUTC  ENDP

; function  incw(var acc: word; w: INTEGER): boolean;assembler;

        public  INCW
INCW PROC FAR
  pop  cx DI
    POP  AX BX ES
  PUSH DI CX
    add ES:[BX],Ax
    rcl al,1
    AND al,1
    RET

INCW   endP

; function  XCHGw(WHAT: WORD; var d: word): word; assembler;

        public  XCHGW
XCHGW PROC FAR
  pop  cx DI
    POP  BX ES AX
  PUSH DI CX
    xchg  ax,ES:[BX]
    RET

XCHGW endP

; FUNction  RelADR(inw, Mask: WORD): WORD;  assembler;

        public  RELADR
RELADR PROC FAR
  pop  cx DI
    POP   DX AX
  PUSH DI CX
    shr   dx,1
    shl   dx,1
    mov   cx,dx
    jcxz  nodec
    dec   dx
    and   cx,ax
nodec:
    and   ax,dx
    sub   ax,cx
    RET

RELADR    endP

;  function Avg(a, b: intEGER): intEGER; assembler;

        public  AVG
AVG PROC FAR
  pop  cx DI
    POP  DX AX
  PUSH DI CX
    add   ax,dx
    rcr   ax,1
    RET

AVG endP


;  function divmod(var w: dword; d: word): word; assembler;

        public  DIVMOD
DIVMOD PROC FAR
  pop  cx DI
    POP   BX AX ES   ;POINTER TO DWORD  DIVIDER}
  PUSH DI CX
    XCHG AX,DI
      XOR  DX,DX        ;{CLEAR HI WORD}
      SCASW           ; BUMP DI
	  STD
      MOV  AX,ES:[DI]
      DIV  BX
      STOSW
      MOV  AX,ES:[DI]
      DIV  BX
      STOSW
	  CLD
      xchg ax,dx   ;  {IN DX  IS MODULO OF DIVISION}
      RET

DIVMOD endP


;  FUNCTION  FREG: POINTER; ASSEMBLER;

        public  FREG
FREG PROC FAR
     MOV AX,BP
     MOV DX,SS
     RET

FREG  ENDP

;  FUNCTION  CALLERETADR: POINTER;  ASSEMBLER; {FAR CALLER}

        public  CALRETADR
CALRETADR PROC FAR

    LES AX,[BP+2]
    MOV DX,ES
    RET

CALRETADR  ENDP

; function  addptr(p: pointer; w: INTEGER): pointer;

        public  ADDPTR

ADDPTR PROC FAR
  pop  cx DI
    POP  AX BX DX
  PUSH DI CX
    add AX,BX
    RET

ADDPTR   endP


        public  AFTERSTR

AFTERSTR PROC FAR
  pop  cx DI
    POP  BX ES
  PUSH DI CX
    MOV DX,ES
    XOR AX,AX
    MOV AL,ES:[BX]
    INC BX
    add AX,BX
    RET

AFTERSTR   endP


code ends
     end
