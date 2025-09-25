UNIT BaseLib;

interface

  uses dos;

  CONST TOP = 251;

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

    PtrNODE = ^TUPNODE;
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

  function  strToMem(str: string): pstr;
  procedure FreeString(ps: pstr);
  procedure pushTuple(tuple: ptrNode; var whereTo: ptrNode);
  function  popTuple(var From: ptrNode) : ptrNode;
  function  makeTuple(tkey, tvalue: string): ptrnode;
  function  findTuple(tkey: string; fnd: ptrnode): ptrnode;
  procedure freeTuple(tuple: ptrNode);

  function  now: dword;
  function  MemHash(Data: PCHAR; len, CRC, POLY: word) : word;

  function  boolTxt(cond: boolean): str5;
  function  strToNum(s: string): longint;
  procedure stradd(var sd: string; ss: string; del: char);
  function  NToHex(n: dword; chars: byte): str15;
  function  NumberToStr(n: longint; chars, BASE: byte): str33;
  function  NToStr(n: longint): str15;
  function  byteTobin(n: byte): str15;
  function  bytetohex(b: byte) : str5;
  function  wordToHex(W: WORD) : str5;
  function  LongToHex(L: DWORD) : str15;

  function  RelADR(inw, Mask: WORD): WORD;
  function  divmod(var w: dword; d: word): word;
  FUNCTION  FREG: POINTER;
  FUNCTION  CALRETADR: POINTER;
  function  getc(var where: pchar): char;
  procedure putc(what: char; var where: pchar);
  function  DigChar(n: byte): char;

implementation

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
    xor  di,bx  {POLY}
    rol  di,1
    adc  di,ax  {crc}
    loop @@loop
@@skip:
    xor  di,dx
    xchg ax,di
    pop ds
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
  begin sz := succ(length(str));
    GETMEM (MEM,SZ);
    mem^ := str;
    strToMem := mem;
  end;

  procedure FreeString(ps: pstr);
  var mem: pstr;  sz: word;
  begin
    if ps = nil then exit;
    sz := succ(length(ps^));
    freeMEM (ps,SZ);
  end;

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


  function  RelADR(inw, Mask: WORD): WORD;       EXTERNAL;
  function  divmod(var w: dword; d: word): word; EXTERNAL;
  FUNCTION  FREG: POINTER;                       EXTERNAL;
  FUNCTION  CALRETADR: POINTER;                  EXTERNAL;
  function  getc(var where: pchar): char;        EXTERNAL;
  procedure putc(what: char; var where: pchar);  EXTERNAL;
  function  DigChar(n: byte): char;              EXTERNAL;

{$L ASMLIB.OBJ}

begin
END.