UNIT STRLIB;

INTERFACE

uses baselib;

  function  boolTxt(cond: boolean): str5;
  procedure ShowStr(s:string);
  function  fixblanks(s: string): STRING;
  function  upcase(s: string): STRING;
  PROCEDURE REVERT(Data: PCHAR; LEN: Word);
  PROCEDURE ONPLACE(Data: PCHAR; LEN1, LEN2: Word);
  function  strToMem(str: string): pstr;

  function  ascUnPack(s, d: pchar; l: WORD): WORD;
  function  ascPack(s, d: pchar; l: WORD): WORD;
  function  strPack(s: string): string;
  function  strUnPack(s: str85): string;

  function  strToNum(s: string): longint;
  procedure stradd(var sd: string; ss: string; del: char);
  function  NToHex(n: dword; chars: byte): str15;
  function  NumberToStr(n: longint; chars, BASE: byte): str33;
  function  NToStr(n: longint): str15;
  function  byteTobin(n: byte): str15;

  function PARS(VAR LS: LONGSTR): word;
  function PARScnt(newLS: LONGSTR): word;
  FUNCTION ADDptr(ptr: POINTER; sz: integer): POINTER;
  function MKSTR(var s; B: BYTE) : string;
  function MKSTROF(C: CHAR; B: BYTE) : string;

  function cutStr(var s: string; del: char): string;
  function GETOKEN(var s: string) : string;
  function bytetohex(b: byte) : str5;
  function wordToHex(W: WORD) : str5;
  function DwordToHex(L: DWORD) : str15;

IMPLEMENTATION

  procedure stradd(var sd: string; ss: string; del: char);
  begin
    if sd = ''
      then sd := ss
      else sd := sd + del + ss;
  end;

  function strToNum(s: string): longint;
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

  function strPack(s: string): string;
  var c: byte;
  begin
    c := ascPack(@s[1], @s[1], length(s));
    s[0] := char(c);
    STRPACK := S;
  end;

  function strUnPack(s: str85): string;
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

  function strToMem(str: string): pstr;
  var mem: pstr;  sz: word;
  begin sz := succ(length(str));
    GETMEM (MEM,SZ);
    mem^ := str;
    strToMem := mem;
  end;

  function boolTxt(cond: boolean): str5;
    const strbul: array[boolean] of str5
          = ('False','True');
  begin
    booltxt := strBul[cond];
  end;

  function bytetohex(b: byte) : str5;
  BEGIN
    BYTETOHEX := digchar(B SHR 4) + digchar(B);
  END;

  function wordToHex(W: WORD) : str5;
  BEGIN  WITH WORDREC(W) DO
    wordToHex := BYTETOHEX(HI) + BYTETOHEX(LO);
  END;

  function DwordToHex(L: DWORD) : str15;
  BEGIN  WITH LONGREC(L) DO
    DwordToHex := wordToHex(HI) + wordToHex(LO);
  END;

  PROCEDURE REVERT(Data: PCHAR; LEN: Word); ASSEMBLER;
  ASM
    PUSH DS
    CLD
    LDS SI,DATA
    MOV  BX,LEN
    ADD BX,SI
    JC  @@OVER
@@LOOP:
    DEC  BX
    CMP  SI,BX
    JNC  @@OVER
    LODSB
    XCHG AL,BYTE PTR [BX]
    MOV  [SI-1],AL
    JMP  @@LOOP
@@OVER:         {FLOW}
    POP  DS
  END;

  PROCEDURE ONPLACE(Data: PCHAR; LEN1, LEN2: Word);
  VAR AFTEREND: LONGINT;
  BEGIN
    afterend := LONGREC(DATA).lo + LEN1 + LEN2;
    IF (LEN1 = 0) OR (LEN2 = 0) or (LONGREC(afterend).HI <> 0)
      THEN EXIT;
    REVERT(DATA,LEN1);
    REVERT(DATA+LEN1,LEN2);
    REVERT(DATA,AFTEREND);
  END;

  function PARS(VAR LS: LONGSTR): word;
  VAR RES: LONGSTR; len: word;
  begin
    RES := LS;
    asm
  LES     DI,[RES.CP]
  mov CX,RES.REM
  mov AL,' '
  inc CX
@@1:
  DEC CX
  JZ @@SKIPX
  SCASB
  JAE @@1       { SPACE IS ABOVE OR EQUAL TO }
  DEC     DI
@@SKIPX:
  push    di    {;  START OF THE WORD}
  JCXZ @@WEX
  inc CX
@@3:
  DEC CX
  JZ @@WEX
  SCASB           { SPACE IS BELOW THEN}
  JB @@3
  DEC     DI
@@WEX:          {; END OF THE WORD  IN DI}
  POP AX      {; START OF THE WORD}
  mov WORD PTR [RES.CP],DI
  SUB     DI,ax   {; LENGTH OF THE WORD}
  mov WORD PTR [LEN],DI
  mov WORD PTR [RES.REM],CX
  END;
    LS := RES;
    pars := LEN;
  END;

  FUNCTION ADDptr(ptr: POINTER; sz: integer): POINTER;
  VAR  CP: LONGREC ABSOLUTE PTR;
  BEGIN  WITH CP DO  LO := LO + SZ;
    ADDPTR := PTR;
  END;

  { count tokens in memory block on parsing}
  function PARScnt(newLS: LONGSTR): word;
  var cnt, size: word;
  begin  cnt := 0;
    repeat
      size := pars(newls);
      if size <> 0 then inc(cnt);
    until size = 0;
    parscnt := cnt;
  end;

  function long_str(ls: longstr; len: word): string;
  begin
    WITH LS DO
      long_str := MKSTR(ADDPTR(CP,-LEN)^ ,LEN);
  end;

  function nthToken(ls: longstr; idx: word):string;
  var len, size: word;
  begin  nthtoken := ''; inc(idx);
    repeat
      size := pars(ls);
      dec(idx);
    until (idx = 0) or (size = 0);
    nthToken :=  long_str(ls,size);
  end;

  function MKSTR(var s; B: BYTE) : string;
  VAR TS: STRING;
  BEGIN
    TS[0] := CHAR(B);
    MOVE(S,TS[1],B);
    MKSTR := TS;
  END;

  function MKSTROF(C: CHAR; B: BYTE) : string;
  VAR TS: STRING;
  BEGIN
    TS[0] := CHAR(B);
    FILLCHAR(TS[1],B,C);
    MKSTROF := TS;
  END;

  procedure str_long(s: string; var ls: longstr);
  begin
    with ls do begin
      cp := @s[1];
      rem:= byte(s[0]);
    end;
  end;

  function GETOKEN(var s: string) : string;
  var LS: LONGSTR;   LEN: WORD;  RES: STRING;
  BEGIN  str_long(s,ls);  LEN := PARS(LS);
    res := long_str(ls,len);
    WITH LS DO   S := MKSTR(CP^,REM);
    GETOKEN := RES;
  END;

  procedure ShowStr(s:string);
    var l, i: integer;
    procedure printc(c: char);
      var b: byte absolute c;
    begin
        if b < 32 then begin write('^'); b := b+ord('@'); end;
        write(char(c));
    end;
  begin
    l := length(s);
    for i := 1 to length(s) do
      printc(s[i]);
    writeln('|');
  end;

  function TokenCnt(s: string) : word;
  var ls: longstr;
  begin str_long(s,ls);
    tokenCnt := ParsCnt(ls);
  end;

{
  FUNCTION trimleft(s: string): string;
  var len, next: integer;
  begin len := length(s);
    next := firstNonBlank(@s[1],len);
    trimleft := copy(s,len-next+1,next);
  end;

  FUNCTION SKIPleft(s: string; C: CHAR): INTEGER;
  var len, next: integer;
  begin len := length(s);
    FOR NEXT := 1 TO LEN DO BEGIN
      IF S[NEXT] <> C THEN BEGIN
        SKIPLEFT := NEXT-1;
        EXIT;
      END;
    END;
    SKIPLEFT := LEN;
  end;
  }

  function fixblanks(s: string): STRING;
  var p: integer;
  begin
    for p := length(s) downto 1 do begin
      if s[p] < ' ' then s[p] := ' ';
    end;
    FIXBLANKS := S;
  end;

  FUNCTION upcase(s: string): STRING;
  var p: integer; bcod: byte;
  begin
    for p := length(s) downto 1 do begin
      bcod := byte(s[p]);
      if (bcod <= byte('z')) and (bcod >= byte('a')) then
      s[p] := char(bcod-32);
    end;
    UPCASE := S;
  end;

  function cutStr(var s: string; del: char): string;
  var p: integer;
  begin
    p := pos(del,s);
    if p = 0 then begin
      cutstr := s;
      s := '';
      exit;
    end;
    cutstr := copy(s,1,p-1);
    delete(s,1,p);
  end;

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

BEGIN
END.