UNIT BaseLib;

interface

  uses dos;

  TYPE
    DWORD = LONGINT;
    Pbyte   = ^BYTE;
    Pword   = ^WORD;
    Plong   = ^dWORD;
    PSTR    = ^STRING;
    wordREC = record lo, hi:  BYTE; end;
    LONGREC = record lo, hi:  word; end;
    str7    = string[7];      {256/37}
    str15   = string[15];     {256/17}
    str35   = string[35];     {256/7}
    str85   = string[85];     {256/3}
    LONGSTR = RECORD CP: pChaR; REM: WORD; END;

    tshow   = function (l: longint): string;

    ppary   = ^pary;
    pary    = array[0..2047] of pointer;


  PROCEDURE mygetmem(var p: POINTER; sz:word);
  function  strToMem(str: string): pstr;
  procedure FreeString(ps: pstr);
  function  now: dword;

  function  boolTxt(cond: boolean): str7;
  function  strToNum(s: string): longint;
  procedure stradd(var sd: string; ss: string; del: char);
  function  NToHex(n: dword; chars: byte): str15;
  function  NToStr(n: longint): str15;
  function  byteTobin(n: byte): str15;
  function  bytetohex(b: byte) : str7;
  function  wordToHex(W: WORD) : str7;
  function  LongToHex(L: DWORD) : str15;
  function  ltos(l: longint): str7;
  function  stol(s: str15): longint;

  FUNCTION  AFTERSTR(P: POINTER): POINTER;
  FUNCTION  ADDPTR(P:POINTER; I:INTEGER): POINTER;
  function  RelADR(inw, Mask: WORD): WORD;
  function  divmod(var w: dword; d: word): word;
  FUNCTION  FREG: POINTER;
  FUNCTION  CALRETADR: POINTER;
  function  getc(var where: pchar): char;
  procedure putc(what: char; var where: pchar);
  function  DigChar(n: byte): char;

CONST CDIGTBL: STRING[64] =
  '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz@_';

  function  ITOA(d: longint; cvt: pstr; base: word): str35;
  PROCEDURE ATOI(s:string;VAR RES:DWORD;cvt:pstr;VAR ERR:word;BASE:WORD);

implementation

  var zstr: byte; {do not assign anithing to it}

  function ltos(l: longint): str7;
  var res: str7; p: plong;
  begin
    res[0] := #4;
    p := @res[1];
    p^ := l;
    ltos := res;
  end;

  function  stol(s: str15): longint;
  var sz: byte absolute s;
  begin
    if sz < sizeof(longint)
      then fillchar(s[sz+1],4,#0);
    {sz := 4;}
    stol := plong(@s[1])^;
  end;

  PROCEDURE FIXBASE(VAR BASE: WORD; VAR CVT: PSTR);
  VAR LCVT: WORD;  CONST NEWCVT: STRING [2] = '01';
  BEGIN
    IF BASE < 2 THEN BASE := 2 ELSE IF BASE > 94 THEN BASE := 94;
    if cvt <> nil THEN BEGIN LCVT := LENGTH(CVT^);
      IF LCVT < 2 THEN BEGIN CVT := @NEWCVT; LCVT := 2; END;
      IF LCVT < BASE THEN BASE := LCVT;
    END;
  END;

  PROCEDURE ATOI(s:string;VAR RES:DWORD;cvt:pstr;VAR ERR:word;BASE:WORD);
  var p, LCVT, len, ind: word; B: INTEGER;  DD: DWORD;
  begin IND := 1; LEN := BYTE(S[0]); DD := 0; ERR := 0; FIXBASE(BASE,CVT);
    WHILE LEN > 0 DO BEGIN  B := BYTE(S[IND]);
      if cvt = nil THEN BEGIN  B := B - ORD('!');
        IF NOT ( B IN [0..PRED(BASE)]) THEN BREAK;
      END ELSE BEGIN
        p := pos(CHAR(B),cvt^); if p = 0 then BREAK; B := PRED(P);
      end;
      res := DD * base + B;     dec(len); INC(IND);
    end;
    RES := DD; if LEN <> 0 then ERR := ind;
  end;

  function ITOA(d: longint; cvt: pstr; base: word): str35;
  var i: INTEGER; MODUL: BYTE; C : CHAR ABSOLUTE MODUL; RES: STR35;
  begin  i := pred(sizeof(str35)); FIXBASE(BASE,CVT);
    repeat  MODUL := divmod(d, base);
      if cvt = nil
        THEN MODUL := MODUL + byte('!')
        ELSE C := cvt^[succ(MODUL)];
      RES[i] := C;
      dec(i);
    until d=0;
    RES[i] := char(33-i);
    ITOA := pstr(@RES[i])^;
  end;

  PROCEDURE mygetmem(var p: POINTER; sz:word);
  begin
    getmem(p,sz);
    fillchar(p^,sz,#0);
  end;

  function  now: dword;
  var h,m,s,hs: word;
  begin
    gettime(h,m,s,hs);
    now := ((h * 60 + m) * 60 + s) * 100 + hs;
  end;

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
    STRTONUM := RES;
  end;

  function  byteTobin(n: byte): str15;
  VAR RES : STR15; i: integer;
  const boolary: array[boolean] of char = ('0','1');
  begin res[0] := #8;
    for i :=  8 to 1 do begin
      res[i] := boolary[odd(n)];
      n := n shr 1;
    end;
    byteTobin := RES;
  end;

  function  NToStr(n: longint): str15;
  VAR RES: STR15;
  begin res := '';
    if n < 0 then begin n := -n; res := '-'; end;
    res := res + itoa(n,@CDIGTBL,10);
    NTOSTR := RES;
  end;

  function  NToHex(n: dword; chars: byte): str15;
    var res: str15;
    begin
      res := LongToHex(n);
      if (chars in [1..7]) then res[0] := char(chars);
      NToHex := res;
    end;

  function boolTxt(cond: boolean): str7;
    const strbul: array[boolean] of str7
          = ('False','True');
  begin
    booltxt := strBul[cond];
  end;

  function bytetohex(b: byte) : str7;
  BEGIN
    BYTETOHEX := digchar(B SHR 4) + digchar(B and 15);
  END;

  function wordToHex(W: WORD) : str7;
  BEGIN  WITH WORDREC(W) DO
    wordToHex := BYTETOHEX(HI) + BYTETOHEX(LO);
  END;

  function LongToHex(L: DWORD) : str15;
  BEGIN  WITH LONGREC(L) DO
    LongToHex := wordToHex(HI) + wordToHex(LO);
  END;

  function strToMem(str: string): pstr;
  var mem: pstr;  sz: word;
  begin sz := length(str);
    strToMem := @zstr;
    if sz = 0
      then exit;
    GETMEM (MEM,succ(SZ));
    mem^ := str;
    strToMem := mem;
  end;

  procedure FreeString(ps: pstr);
  begin
    if (ps = nil) or (ps=(@zstr))
      then exit;
    freeMEM (ps,succ(length(ps^)));
  end;


  function  RelADR(inw, Mask: WORD): WORD;       EXTERNAL;
  function  divmod(var w: dword; d: word): word; EXTERNAL;
  FUNCTION  FREG: POINTER;                       EXTERNAL;
  FUNCTION  CALRETADR: POINTER;                  EXTERNAL;
  function  getc(var where: pchar): char;        EXTERNAL;
  procedure putc(what: char; var where: pchar);  EXTERNAL;
  function  DigChar(n: byte): char;              EXTERNAL;
  FUNCTION  ADDPTR(P:POINTER;I:INTEGER):POINTER; EXTERNAL;
  FUNCTION  AFTERSTR(P: POINTER): POINTER;       EXTERNAL;

{$L ASMLIB.OBJ}

begin
END.