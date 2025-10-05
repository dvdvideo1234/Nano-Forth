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
    tproc   = procedure;

    ppary   = ^pary;
    pary    = array[0..2047] of pointer;
    parbyte = ^arbyte;
    arbyte  = array[0..65535-256] of byte;

{  var aMethod: procedure of object;  in lazarus}
  procedure perform( selfp, method: pointer);


  PROCEDURE mygetmem(var p: POINTER; sz:word);
  function  strToMem(str: string): pstr;
  procedure FreeString(ps: pstr);
  function  now: dword;

  function  boolstr(cond: boolean): str7;
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
  function  avg(a, b: WORD): WORD;

{CONST CDIGTBL: STRING[64] =
  '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz@_';}

  function  ITOA(d: longint; base: word): str35;
  PROCEDURE ATOI(s:string;VAR RES:DWORD; VAR ERR:word);

implementation

  var zstr: byte; {do not assign anithing to it}

  procedure perform( selfp, method: pointer); assembler;
  asm
    les  di,selfp
    push es
    push di
    call method
  end;

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

  PROCEDURE ATOI(s:string;VAR RES:DWORD; VAR err: word);
  var p, LCVT, len, ind: word; B: byte; c: char absolute b;
      DD: DWORD; BASE:WORD; tonum: word; sign: boolean;
    procedure incri; begin inc(ind); dec(len); end;
    procedure dincri; begin dd := DD * base + tonum;  INCri; end;
    procedure convert; begin
      WHILE LEN > 0 DO BEGIN  c := S[IND]; tonum := b - ord('0');
        if c > '9' then dec(tonum,7); IF NOT ( tonum < BASE) THEN BREAK;
      dINCri; end;  end;
  begin IND := 1; LEN := BYTE(S[0]); DD := 0; base := 10; err := 0;
    sign := s[ind] ='-' ; if sign then incri;
    convert;
    while len > 0 do begin
      if (len > 1) and (c in ['$','%','#','^','''']) then begin incri;
        case c of
        '$' : base := 16;
        '%' : base := 2;
        '#' : begin base := ((dd-2) and 255)+2; dd := 0; end;
        '^' : begin c := S[IND]; tonum:= b and 31; dincri; end;
        '''': begin c := S[IND]; tonum:= b; dincri; end;
        end;
      end else break;
      convert;
    end;
    if len <> 0 then ERR := ind;
    if sign then dd := - dd;
    RES := DD;
  end;

  function ITOA(d: longint; base: word): str35;
  var i: INTEGER; C : CHAR; RES: STR35;
  begin  i := pred(sizeof(str35)); base := ((base-2) and 255)+2;
    repeat
      RES[i] := digChar(divmod(d, base));
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
  var h,m,s,hs: word; d: dword;
  begin
    gettime(h,m,s,hs);  d := h;
    now := ((d * 60 + m) * 60 + s) * 100 + hs;
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
    res := res + itoa(n,10);
    NTOSTR := RES;
  end;

  function  NToHex(n: dword; chars: byte): str15;
    var res: str15;
    begin
      res := LongToHex(n);
      if (chars in [1..7]) then res[0] := char(chars);
      NToHex := res;
    end;

  function boolStr(cond: boolean): str7;
    const strbul: array[boolean] of str7
          = ('False','True');
  begin
    boolStr := strBul[cond];
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
  function  avg(a, b: WORD): WORD;               EXTERNAL;
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