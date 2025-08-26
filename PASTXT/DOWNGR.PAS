UNIT DOWNGR; {DOWNGRADE FROM LAZARUS}

interface

USES STRLIB;

  TYPE
    SHORTSTRING = STRING;
    DWORD = LONGINT;
    CARDINAL = LONGINT;


  function ascUnPack(s, d: pchar; l: WORD): WORD;
  function  ascPack(s, d: pchar; l: WORD): WORD;
  function  strPack(s: shortstring): shortstring;
  function  strUnPack(s: str85): shortstring;

  function  strToNum(s: shortstring): longint;
  procedure stradd(var sd: shortstring; ss: shortstring; del: char);
  function  NToHex(n: dword; chars: byte): str15;
  function  LongToHex(n: dword): str15;
  function  NumberToStr(n: longint; chars, BASE: byte): str33;
  function  byteTohex(n: byte): str5;
  function  NToStr(n: longint): str15;
  function  byteTobin(n: byte): str15;
  function  WordTohex(n: word): str15;


  function  RelADR(inw, Mask: WORD): WORD;
  function  divmod(var w: dword; d: word): word;
  FUNCTION  FREG: POINTER;
  FUNCTION  CALRETADR: POINTER;
  function  getc(var where: pchar): char;
  procedure putc(what: char; var where: pchar);
  function  DigChar(n: byte): char;
  FUNCTION  WPICK(VAR P): POINTER;


implementation

  function  DigChar(n: byte): char;
  VAR C: CHAR ABSOLUTE N;
  BEGIN
    IF N > 9 THEN N := N + 7;
    N := N + BYTE('0');
    DIGCHAR := C;
  END;


  function  RelADR(inw, Mask: WORD): WORD;       EXTERNAL;
  function  divmod(var w: dword; d: word): word; EXTERNAL;
  FUNCTION  FREG: POINTER;                       EXTERNAL;
  FUNCTION  CALRETADR: POINTER;                  EXTERNAL;
  function  getc(var where: pchar): char;        EXTERNAL;
  procedure putc(what: char; var where: pchar);  EXTERNAL;
{  function  DigChar(n: byte): char;              EXTERNAL;}
  FUNCTION  FREG: POINTER;                       EXTERNAL;
  FUNCTION  CALRETADR: POINTER;                  EXTERNAL;
  FUNCTION  WPICK(VAR P): POINTER;               EXTERNAL;
 {$L ASMLIB.OBJ}

{
 function getc(var where: pchar): char; assembler;
   asm
     PUSH  DS
     LDS   BX,WHERE
     LES   DI,[BX]
     INC   WORD PTR [BX]
     POP   DS
     MOV   AL,ES:[DI]
   end;

  procedure putc(what: char; var where: pchar);assembler;
  asm
     PUSH  DS
     LDS   BX,WHERE
     LES   DI,[BX]
     INC   WORD PTR [BX]
     POP   DS
     MOV   AL,WHAT
     STOSB
  end;

  function  DigChar(n: byte): char;
    label noInc;
  asm
    MOV AL,N
    cmp   al,10
    jb    noInc
    add   al,7
  noInc:
    add   al,'0'
  end;
}
  function ascPack(s, d: pchar; l: WORD): WORD;
  var oldd: pchar; ch : char; c: byte absolute ch;
    procedure getc1; begin ch := getc(s); dec(l); end;
  begin  oldd := d;
    while l > 0 do begin  getc1;
      case ch of
        '"': if l <> 0  then begin getc1; putc(ch,d);  end;
        '^': if l <> 0  then begin getc1; c := c and 31; putc(ch,d); end;
        '~': if oldd <> d then  byte((d-1)^) := byte((d-1)^) xor $80;
        '_': begin ch := ' '; putc(ch,d); end;
      else putc(ch,d);;
      end;
    end;
    ASCPACK := d - oldd;
  end;

  function strPack(s: shortstring): shortstring;
  var c: byte;
  begin
    c := ascPack(@s[1], @s[1], length(s));
    s[0] := char(c);
    STRPACK := S;
  end;

  function strUnPack(s: str85): shortstring;
  var RA: string;
  begin
    ra[0] := char(ascUnPack(@s[1], @RA[1], length(s)));
    strUnPack := RA;
  end;

  function ascUnPack(s, d: pchar; l: WORD): WORD;
  var oldd: pchar; ch : char; c: byte absolute ch;  hibit: boolean;
  begin  oldd := d;
    for l := l downto 1 do begin  ch := s^; inc(s);
      hibit := c > 127; c :=  c and 127;
      case ch of
        #0..#31: begin putc('^',d);  c := c or ord('@'); end;
        '~','"','^','_':  putc('"',d);
        ' ': ch := '_';
      end;
      putc(ch,d);
      if hibit then putc('~',d);
    end;
    ascUnPack := d - oldd;
  end;

  procedure stradd(var sd: shortstring; ss: shortstring; del: char);
  begin
    if sd = ''
      then sd := ss
      else sd := sd + del + ss;
  end;

  function strToNum(s: shortstring): longint;
  var err: word;   RES: LONGINT;
  begin
    val(s,res,err);
  end;

  function  byteTobin(n: byte): str15;
  VAR RES : STR15;
  begin
    res := NumberToStr(n or 256, 8, 2);
    byteTobin := RES;
  end;

{
  function  incw(var acc: word; w: INTEGER): boolean;assembler;
  asm
    LES DI,ACC
    MOV DX,W
    add ES:[DI],dx
    mov al,0
    rcl al,1
  end;

  function  XCHGw(WHAT: WORD; var d: word): word; assembler;
  asm
    LES DI,D
    MOV AX,WHAT
    xchg  ax,ES:[dI]
  end;

Function  RelADR(inw, Mask: WORD): WORD;  assembler;
label nodec;
asm
   MOV  AX,INW
   MOV  DX,MASK
    shr   dx,1
    shl   dx,1
    mov   cx,dx
    jcxz  nodec
    dec   dx
    and   cx,ax
nodec:
    and   ax,dx
    sub   ax,cx
end;

  function Avg(a, b: intEGER): intEGER; assembler;
  asm
    MOV   AX,A
    MOV   DX,B
    add   ax,dx
    rcr   ax,1
  end;
}

  function  NToStr(n: longint): str15;
  VAR RES: STR15;
  begin res := '';
    if n < 0 then begin n := -n; res := '-'; end;
    res := res + NumberToStr(n,14,10);
    NTOSTR := RES;
  end;

  function  NumberToStr(n: longint; chars, base: byte): str33;
  var dw: dword absolute n;   i: INTEGER;  RES: STR33;
  begin  i := 33;
    if base > 63 then base := 64 else if base < 2 then base := 2;
    repeat
      RES[i] := digChar(divmod(dw, base));
      dec(i);
      dec(chars);
    until (n=0) or (chars=0);
    RES[i] := char(33-i);
    NumberToStr := pstr(@RES[i])^;
  end;

  function  byteToHex(n: byte): str5;
  begin
    byteToHex := digchar(n shr 4) + digchar(n and 15);
  end;

  function  WordToHex(n: word): str15;
  begin
    WordToHex := byteToHex(wordRec(n).Hi) + byteToHex(wordRec(n).Lo);
  end;

  function  LongToHex(n: dword): str15;
  begin
    LongToHex := WordToHex(LongRec(n).Hi) + WordToHex(LongRec(n).Lo);
  end;

  function  NToHex(n: dword; chars: byte): str15;
    begin
      if (chars in [1..7])
        then  NToHex := NumberToStr(n or $80000000, chars, 16)
        else  NToHex := LongToHex(n);
    end;

{
  function divmod(var w: dword; d: word): word; assembler;
  asm
      LES  DI,W         POINTER TO DWORD
      MOV  BX,D         DIVIDER
      XOR  DX,DX        CLEAR HI WORD
      MOV  AX,ES:[DI+2]
      DIV  BX
      MOV  ES:[DI+2],AX
      MOV  AX,ES:[DI]
      DIV  BX
      MOV  ES:[DI],AX   IN DX  IS MODULO OF DIVISION
      xchg ax,dx
  end;

  VAR VA, VB, VC: WORD;


  FUNCTION  FREG: WORD; ASSEMBLER;
    ASM
      MOV AX,BP
    END;



  FUNCTION  CALLERETADR: POINTER;  ASSEMBLER; FAR CALLER
  ASM
    LES AX,[BP+2]
    MOV DX,ES
  END;

  FUNCTION  HERE: POINTER;
  VAR P: POINTER;
  BEGIN
    HERE := CALLERETADR;
  END;

  F-}

  PROCEDURE DUMP(VAR SRS; LEN: WORD);
  VAR AR: ARRAY[0..255] OF BYTE ABSOLUTE SRS;
      I, T: INTEGER;  RES, TXT: STR85;  C : CHAR;
  BEGIN  LEN := (LEN AND 255) OR 15;  WRITELN;
    FOR I := 0 TO LEN DO BEGIN
      IF (I AND 15) = 0 THEN BEGIN
        RES := LONGTOHEX(DWORD(@AR[I]))+' ';
        TXT := '   [';
        T := I;
      END;
      C := CHAR(AR[I]); IF C IN [#0..#31] THEN C := '.';
      RES := RES + ' ' + BYTETOHEX(AR[I]);
      TXT := TXT + C;
      IF (I AND 15) = 15 THEN BEGIN
        WRITELN(RES,TXT,']');
      END;
    END;
  END;

{  FUNCTION  WPICK(VAR P): WORD;
  VAR W: WORD ABSOLUTE P;
  BEGIN
    WPICK := W;
  END;
}

  {$F+}
  PROCEDURE TESTPARAM(VAR A; C: WORD);
  VAR P, Q: POINTER; FR: WORD;
    BEGIN FR := 0;
      P := @FR; Q := CALRETADR;
      WRITELN( 'FRAME Q P BP RET C A');
      DUMP(P^,22);
      WRITELN('STR8');
      DUMP(A,18);
      WRITELN('WPICK');
      DUMP(POINTER(@WPICK)^,18);

      WRITELN( 'PARAMS ',
        LONGTOHEX(DWORD(@A)),' ' ,
        LONGTOHEX(DWORD(@C)),' ',
        LONGTOHEX(DWORD(P)),' ',
        LONGTOHEX(DWORD(Q))
        );
      WRITELN(WORDTOHEX(WPTR(DWORD(@C))^),' ',
             WORDTOHEX(WPTR(DWORD(@C)+2)^),' ',
             WORDTOHEX(WPTR(DWORD(@C)+4)^),' ',
             WORDTOHEX(WPTR(DWORD(@C)-2)^), ' ',
             WORDTOHEX(WPTR(DWORD(@C)-4)^), ' ',
             WORDTOHEX(WPTR(DWORD(@C)-6)^), ' ',
             WORDTOHEX(FR)
             );
    END;
{$F-}

{  ASM
    POP  AX
    POP  BX
    POP  CX
    POP  DX
    PUSH AX
    MOV  VA,BX
    MOV  VB,CX
    MOV  VC,DX
  END;
}
  PROCEDURE TEST;
  VAR SRS, DST: STRING;
  DD: DWORD;  DVD: WORD;
  BEGIN
    SRS := ^A^B^C'4~_^"';
    WRITELN('function  DigChar(n: byte): char;');
    WRITELN('DigChar 0 = ',DigChar(0));
    WRITELN('DigChar 9 = ',DigChar(9));
    WRITELN('DigChar 10= ',DigChar(10));

    {;DST := STRUNPACK(SRS);
    WRITELN(DST,BOOLTXT(STRPACK(DST)=SRS));}
    TESTPARAM(SRS,3);
{    WRITELN(VA,' ',VB,' ',VC);

  function  getc(var where: pchar): char;
  procedure putc(what: char; var where: pchar);
  function  strPack(s: shortstring): shortstring;
  function  strUnPack(s: str85): shortstring;

  function  strToNum(s: shortstring): longint;
  procedure stradd(var sd: shortstring; ss: shortstring; del: char);
  function  NToHex(n: dword; chars: byte): str15;
  function  LongToHex(n: dword): str15;
  function  NumberToStr(n: longint; chars, BASE: byte): str33;
  function  byteTohex(n: byte): str5;
  function  NToStr(n: longint): str15;
  function  byteTobin(n: byte): str15;
  function  WordTohex(n: word): str15;

  function  RelADR(inw, Mask: WORD): WORD;
  function  divmod(var w: dword; d: word): word;
}
    READLN;
  END;

begin
  TEST;
END.