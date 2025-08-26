LOCAL @@


code segment 'CODE'
     assume  cs: code


; function  DigChar(n: byte): char;  {assembler;}
; VAR C: CHAR ABSOLUTE N;
; BEGIN
;   IF N > 9 THEN N := N + 7;
;   N := N + BYTE('0');
;   DIGTOCHAR := C;
; END;

;       public  DigChar
DigChar  PROC NEAR

    POP   DX AX
    cmp   al,10
    jb    @@1
    add   al,7

@@1:
    add   al,'0'
    JMP   DX

DigChar     ENDP


;function getc(var where: pchar): char; assembler;

        public  GETC
GETC PROC NEAR

  POP   DX BX ES
  INC   WORD PTR ES:[BX]
  LES   DI,ES:[BX]
  MOV   AL,ES:[DI-1]
  JMP   DX

GETC    ENDP

;  procedure putc(what: char; var where: pchar);assembler;
;  asm

        public  PUTC
PUTC PROC NEAR

  POP   DX AX BX ES
  INC   WORD PTR ES:[BX]
  LES   DI,ES:[BX]
  MOV   ES:[DI-1],AL
  JMP   DX

PUTC  ENDP

; function  incw(var acc: word; w: INTEGER): boolean;assembler;

        public  INCW
INCW PROC NEAR
    POP  DX AX DI ES
    add ES:[DI],Ax
    rcl al,1
    AND al,1
    JMP DX

INCW   endP

; function  XCHGw(WHAT: WORD; var d: word): word; assembler;

        public  XCHGW
XCHGW PROC NEAR

    POP  DX DI ES AX
    xchg  ax,ES:[dI]
    JMP  DX

XCHGW endP

; FUNction  RelADR(inw, Mask: WORD): WORD;  assembler;

        public  RELADR
RELADR PROC NEAR

    POP  BX DX AX
    shr   dx,1
    shl   dx,1
    mov   cx,dx
    jcxz  nodec
    dec   dx
    and   cx,ax
nodec:
    and   ax,dx
    sub   ax,cx
    JMP  BX

RELADR    endP

;  function Avg(a, b: intEGER): intEGER; assembler;

        public  AVG
AVG PROC NEAR

    POP  BX DX AX
    add   ax,dx
    rcr   ax,1
    JMP  BX

AVG endP


;  function divmod(var w: dword; d: word): word; assembler;

        public  DIVMOD
DIVMOD PROC NEAR

    POP  CX BX DI ES   ;POINTER TO DWORD  DIVIDER}
      XOR  DX,DX        ;{CLEAR HI WORD}
      MOV  AX,ES:[DI+2]
      PUSH DI
      DIV  BX
      SCASW           ; BUMP DI
      STOSW
      MOV  AX,ES:[DI]
      POP  DI
      DIV  BX
      STOSW
      xchg ax,dx   ;  {IN DX  IS MODULO OF DIVISION}
      JMP  CX

DIVMOD endP


;  FUNCTION  FREG: POINTER; ASSEMBLER;

        public  FREG
FREG PROC NEAR
     MOV AX,BP
     MOV DX,SS
     RET

FREG  ENDP

;  FUNCTION  CALLERETADR: POINTER;  ASSEMBLER; {FAR CALLER}

        public  CALRETADR
CALRETADR PROC FAR

    LES AX,[BP+2]
    MOV DX,ES
    RET FAR

CALRETADR  ENDP


;  FUNCTION  WPICK(VAR P): POINTER;

        public  WPICK
WPICK PROC NEAR

    POP  CX DI ES
    LES  AX,ES:[DI]
    MOV  DX,ES
    JMP  CX

WPICK  ENDP

code ends
     end
