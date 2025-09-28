UNIT BaseLib;

interface

  uses dos;

  TYPE
    DWORD = LONGINT;
    Pbyte   = ^BYTE;
    Pword   = ^WORD;
    PSTR    = ^STRING;
    wordREC = record lo, hi:  BYTE; end;
    LONGREC = record lo, hi:  word; end;
    str5    = string[5];
    str15   = string[15];
    str33   = string[33];
    str85   = string[85];
    str8C   = string[140];
    LONGSTR = RECORD CP: pChaR; REM: WORD; END;

    tbl32 = array[byte] of dword;
    tbl16 = array[byte] of word;
    tbl8  = array[byte] of byte;

    Thfunc = function(key: string): Dword;
    ppary= ^pary;
    pary = array[0..2047] of pointer;

{    PtrNODE = ^TUPNODE;
    TUPNODE =
      RECORD
        NEXT: PtrNODE;
        VALUE: pSTR;
        KEY: byte;
      END;

    Ptuple = ^aTUPle;
    atuple =
      RECORD
        NEXT: Ptuple;
        VALUE: pSTR;
        KEY: string;
      END;
}

  PROCEDURE mygetmem(var p: POINTER; sz:word);
  function  strToMem(str: string): pstr;
  procedure FreeString(ps: pstr);
{
  procedure pushTuple(tuple: ptrNode; var whereTo: ptrNode);
  function  popTuple(var From: ptrNode) : ptrNode;
  function  makeTuple(tkey, tvalue: string): ptrnode;
  function  findTuple(tkey: string; fnd: ptrnode): ptrnode;
  procedure freeTuple(tuple: ptrNode);
}
  function  now: dword;
{  function  MemHash(Data: PCHAR; len, CRC, POLY: word) : word;
  FUNCTION  DOHASH(S: STRING): DWORD;}

  function  boolTxt(cond: boolean): str5;
  function  strToNum(s: string): longint;
  procedure stradd(var sd: string; ss: string; del: char);
  function  NToHex(n: dword; chars: byte): str15;
  function  NumberToStr(n: longint; chars, BASE: WORD): str33;
  function  NToStr(n: longint): str15;
  function  byteTobin(n: byte): str15;
  function  bytetohex(b: byte) : str5;
  function  wordToHex(W: WORD) : str5;
  function  LongToHex(L: DWORD) : str15;

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

  function  ITOA(d: longint; cvt: pstr; base: word): str33;
  PROCEDURE ATOI(s:string;VAR RES:DWORD;cvt:pstr;VAR ERR:word;BASE:WORD);

implementation

  var zstr: byte; {do not assign anithing to it}

  PROCEDURE FIXBASE(VAR BASE: WORD; VAR CVT: PSTR);
  VAR LCVT: WORD;  CONST NEWCVT: STRING [2] = '01';
  BEGIN
    IF BASE < 2 THEN BASE := 2 ELSE IF BASE > 94 THEN BASE := 94;
    if cvt <> nil THEN BEGIN LCVT := LENGTH(CVT^);
      IF LCVT < 2 THEN BEGIN CVT := @NEWCVT; LCVT := 2; END;
      IF LCVT < BASE THEN BASE := LCVT;
    END;
  END;

  PROCEDURE ATOI(s:string;VAR RES:DWORD; cvt:pstr; VAR ERR:word; BASE: WORD);
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

  function ITOA(d: longint; cvt: pstr; base: word): str33;
  var i: INTEGER; MODUL: BYTE; C : CHAR ABSOLUTE MODUL; RES: STR33;
  begin  i := 33; FIXBASE(BASE,CVT);
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

{
  FUNCTION DOHASH(S: STRING): DWORD;
  BEGIN
    DOHASH := MEMHASH(@S[1],BYTE(S[0]),$FFFF,$CB67);
  END;

  function MemHash(Data: PCHAR; len, CRC, POLY: word) : word; assembler;
  asm
    push ds
    lds si,data
    mov dx,crc
    mov bx,poly
    mov cx,len
    xor di,di
    xor ax,ax
@@skip0:
    jcxz @@skip

@@loop:
    lodsb
    xor  di,bx  POLY
    rol  di,1
    adc  di,ax  crc
    loop @@loop
@@skip:
    xor  di,dx
    xchg ax,di
    pop ds
end;
}

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

  function  NumberToStr(n: longint; chars, base: WORD): str33;
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
        else  NToHex := LongToHex(n);
    end;

  function boolTxt(cond: boolean): str5;
    const strbul: array[boolean] of str5
          = ('False','True');
  begin
    booltxt := strBul[cond];
  end;

  function bytetohex(b: byte) : str5;
  BEGIN
    BYTETOHEX := digchar(B SHR 4) + digchar(B and 15);
  END;

  function wordToHex(W: WORD) : str5;
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

{
  function  findTuple(tkey: string; fnd: ptrnode): ptrnode;
  var fndptr: ptuple absolute fnd;
  begin
    while fnd <> nil do begin
      if fndptr^.key = tkey then begin
        findTuple := fnd;
        exit;
      end;
      fnd := fnd^.next;
    end;
    findTuple := nil;
  end;

  function makeTuple(tkey, tvalue: string): ptrnode;
  var fnd:  ptuple;
  begin
    getmem(fnd,sizeof(tupnode)+length(tkey));
    with fnd^ do begin
      next := nil;
      value := strToMem(tvalue);
      key := tkey;
    end;
    makeTuple := ptrNode(fnd);
  end;

  procedure freeTuple(tuple: ptrNode);
  begin
    if tuple = nil then exit;
    with tuple^ do begin
      freeString(value);
      freeMem(tuple,sizeof(tupnode)+key);
    end;
  end;


  procedure pushTuple(tuple: ptrNode; var whereTo: ptrNode);
  begin
    tuple^.next := whereTo;
    whereTo := tuple;
  end;

  function popTuple(var From: ptrNode) : ptrNode;
  var fnd: ptrNode;
  begin
    popTuple := nil;
    fnd := From;
    if fnd = nil then exit;
    from := fnd^.next;
    fnd^.next := nil;
    popTuple := fnd;
  end;
}

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