UNIT DOWNGR; {DOWNGRADE FROM LAZARUS}

interface

USES STRLIB;

  TYPE
    SHORTSTRING = STRING;
    DWORD = LONGINT;
    CARDINAL = LONGINT;


  function  ascUnPack(s, d: pchar; l: WORD): WORD;
  function  ascPack(s, d: pchar; l: WORD): WORD;
  function  strPack(s: shortstring): shortstring;
  function  strUnPack(s: str85): shortstring;

  function  strToNum(s: shortstring): longint;
  procedure stradd(var sd: shortstring; ss: shortstring; del: char);
  function  NToHex(n: dword; chars: byte): str15;
  function  NumberToStr(n: longint; chars, BASE: byte): str33;
  function  NToStr(n: longint): str15;
  function  byteTobin(n: byte): str15;

  function  RelADR(inw, Mask: WORD): WORD;
  function  divmod(var w: dword; d: word): word;
  FUNCTION  FREG: POINTER;
  FUNCTION  CALRETADR: POINTER;
  function  getc(var where: pchar): char;
  procedure putc(what: char; var where: pchar);
  function  DigChar(n: byte): char;


implementation
{  function  LongToHex(n: dword): str15;}
{  function  byteTohex(n: byte): str5;}
{  function  WordTohex(n: word): str15;}
{  FUNCTION  STKPTR: WORD;}


  function  RelADR(inw, Mask: WORD): WORD;       EXTERNAL;
  function  divmod(var w: dword; d: word): word; EXTERNAL;
  FUNCTION  FREG: POINTER;                       EXTERNAL;
  FUNCTION  CALRETADR: POINTER;                  EXTERNAL;
  function  getc(var where: pchar): char;        EXTERNAL;
  procedure putc(what: char; var where: pchar);  EXTERNAL;
  function  DigChar(n: byte): char;              EXTERNAL;
  FUNCTION  FREG: POINTER;                       EXTERNAL;
  FUNCTION  CALRETADR: POINTER;                  EXTERNAL;

{$L ASMLIB.OBJ}
{
  FUNCTION  STKPTR: WORD;
  VAR P: WORD;
  BEGIN
    ASM
      LEA AX,[BP+4]
      MOV P,AX
    END;
    STKPTR := P;
  END;
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

{
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

}
  function  NToHex(n: dword; chars: byte): str15;
    begin
      if (chars in [1..7])
        then  NToHex := NumberToStr(n or $80000000, chars, 16)
        else  NToHex := dwordToHex(n);
    end;

  PROCEDURE DUMP(VAR SRS; LEN: WORD);
  VAR AR: ARRAY[0..255] OF BYTE ABSOLUTE SRS;
      I, T: INTEGER;  RES, TXT: STR85;  C : CHAR;
  BEGIN  LEN := (LEN AND 255) OR 15;  WRITELN;
    FOR I := 0 TO LEN DO BEGIN
      IF (I AND 15) = 0 THEN BEGIN
        RES := dwordTOHEX(DWORD(@AR[I]))+' ';
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

{
  PROCEDURE TEST;
  VAR SRS, DST: STRING;
  DD: DWORD; DELTA: INTEGER; DVD: WORD;
  CH: CHAR;  PC: PCHAR;
  BEGIN
    SRS := ^A^B^C'4~_^"';
    WRITELN('function  DigChar(n: byte): char;',CHAR($6E));
    CH := DigChar(11);
    WRITELN('DigChar ',11,' = ',CH);

    WRITELN('DST := STRUNPACK(SRS)');
    DST := STRUNPACK(SRS);
    WRITELN(DST,BOOLTXT(STRPACK(DST)=SRS));
\    TESTPARAM(SRS,3);
\    WRITELN(VA,' ',VB,' ',VC);

  WRITELN('function  getc(var where: pchar): char');
  PC := @CH;
  WRITELN('getc = ',GETC(PC),' ',BOOLTXT((PC-1)=(@CH)));


  WRITELN('procedure putc(what: char; var where: pchar)');
  PC := @CH;
  PUTC('A',PC);
  WRITELN('PUTc = ',BOOLTXT(CH='A'),' ',BOOLTXT((PC-1)=(@CH)));

  WRITELN('function  divmod(var w: dword; d: word): word');
  DD := 70;
  DVD := divmod(DD, 17);
  WRITELN('DIVMOD = ',BOOLTXT(DVD=(70 MOD 17)),' ',BOOLTXT(DD=(70 DIV 17)));

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

    READLN;
  END;
}

begin
END.