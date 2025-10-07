UNIT STRLIB;

INTERFACE

uses baselib;

  procedure ShowStr(s:string);
  function  fixblanks(s: string): STRING;
  function  upcase(s: string): STRING;
  PROCEDURE REVERT(Data: PCHAR; LEN: Word);
  PROCEDURE ONPLACE(Data: PCHAR; LEN1, LEN2: Word);

  function  TokenPack(s: string; VAR CMD: CHAR): string;
  function  ascUnPack(s, d: pchar; l: WORD): WORD;
  function  ascPack(s, d: pchar; l: WORD): WORD;
  function  strPack(s: string): string;
  function  strUnPack(s: str85): string;

  procedure setLstr(var ls: longstr; ptr: pointer; len: word);
  function  PARS(VAR LS: LONGSTR): word;
  function  PARScnt(newLS: LONGSTR): word;
  function  MKSTR(var s; B: BYTE) : string;
  function  MKSTROF(C: CHAR; B: BYTE) : string;
  FUNCTION  trimleft(s: string): string;
  function  lextract(var ls: longstr): string;

  function  cutStr(var s: string; del: char): string;
  function  GETOKEN(var s: string) : string;

IMPLEMENTATION

  function  TokenPack(s: string; VAR CMD: CHAR): string;
  VAR P: PSTR; C: CHAR; L: BYTE ABSOLUTE S; IND: WORD;
  BEGIN CMD := #0; TokenPACK := '';
    IF (L < 2) OR (S[L]<>'"') THEN EXIT;
    C := S[1]; IND := 1; DEC(L,2);
    IF (C <> '"') THEN
      IF (L=0)
        THEN EXIT
        ELSE BEGIN INC(IND); DEC(L); END;
    IF NOT (C IN ['"', ',', '.', '!', '?']) THEN EXIT;
    P := @S[IND]; S[IND] := S[0];
    CMD := C; TokenPACK := STRpACK(P^);
  END;

  function lextract(var ls: longstr): string;
  var sz: word;
  begin lextract := '';   SZ := PARS(LS);
    IF SZ = 0  THEN EXIT;
    WITH LS DO lextract := MKSTR(ADDPTR(CP,-SZ)^ ,SZ);
  end;

  PROCEDURE DUMP(VAR SRS; LEN: WORD);
  VAR AR: ARRAY[0..255] OF BYTE ABSOLUTE SRS;
      I, T: INTEGER;  RES, TXT: STR85;  C : CHAR;
  BEGIN  LEN := (LEN AND 255) OR 15;  WRITELN;
    FOR I := 0 TO LEN DO BEGIN
      IF (I AND 15) = 0 THEN BEGIN
        RES := LongTOHEX(DWORD(@AR[I]))+' ';
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
    procedure put(chr: char); begin d^ := chr; d := d + 1; end;
  begin  oldd := d;
    while l > 0 do begin  ch := s^; inc(s); dec(l);
      hibit := c > 127; c :=  c and 127;
      case ch of
        #0..#31: begin put('^');  c := c or ord('@'); end;
        '~','"','^','_':  put('"');
        ' ': ch := '_';
      end;
      put(ch);
      if hibit then put('~');
    end;
    ascUnPack := d - oldd;
  end;

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

  procedure setLstr(var ls: longstr; ptr: pointer; len: word);
  begin
    with ls do begin
      cp := ptr;
      rem:= len;
    end;
  end;

  function GETOKEN(var s: string) : string;
  var LS: LONGSTR;   LEN: WORD;  RES: STRING;
  BEGIN  setLstr(ls,@s[1],byte(s[0]));  LEN := PARS(LS);
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
  begin setLstr(ls,@s[1],byte(s[0]));
    tokenCnt := ParsCnt(ls);
  end;

  FUNCTION trimleft(s: string): string;
  var ls: longstr;  start, len: word;
  begin setLstr(ls,@s[1],byte(s[0]));
    len := pars(ls);
    WITH LS DO
      trimleft := MKSTR(ADDPTR(CP,-LEN)^ ,LEN+rem);
  end;

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