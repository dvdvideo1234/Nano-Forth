UNIT STRLIB;

INTERFACE

  type
      cptr    = ^char;
      BPTR    = ^BYTE;
      WPTR    = ^WORD;
      PSTR    = ^STRING;
      DWORD   = LONGINT;
      wordREC = record lo, hi:  BYTE; end;
      LONGREC = record lo, hi:  word; end;
      str5    = string[5];
      str15   = string[15];
      str33   = string[33];
      str85   = string[85];
      str8C   = string[140];
      LONGSTR = RECORD CP: CPTR; REM: WORD; END;

  function boolTxt(cond: boolean): str5;
  procedure ShowStr(s:string);
  function fixblanks(s: string): STRING;
  function upcase(s: string): STRING;
  PROCEDURE REVERT(Data: PCHAR; LEN: Word);
  PROCEDURE ONPLACE(Data: PCHAR; LEN1, LEN2: Word);
  function strToMem(str: string): pstr;

  function PARS(VAR LS: LONGSTR): word;
  function PARScnt(VAR LS: LONGSTR): word;
  FUNCTION ADDptr(ptr: POINTER; sz: integer): POINTER;
  function MKSTR(var s; B: BYTE) : string;
  function MKSTROF(C: CHAR; B: BYTE) : string;

  function cutStr(var s: string; del: char): string;
  function GETOKEN(var s: string) : string;
  function nibtohex(b: byte) : char;
  function bytetohex(b: byte) : str5;
  function wordToHex(W: WORD) : str5;
  function DwordToHex(L: DWORD) : str15;

IMPLEMENTATION

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

  function nibtohex(b: byte) : char;
    const asc: array[0..15] of char = (
      '0','1','2','3','4','5','6','7',
      '8','9','A','B','C','D','E','F'
    );
  begin
    NIBTOHEX := ASC[B AND 15];
  end;

  function bytetohex(b: byte) : str5;
  BEGIN
    BYTETOHEX := NIBTOHEX(B SHR 4) + NIBTOHEX(B);
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
    IF (LEN1 = 0) OR (LEN2 = 0)
      THEN EXIT;
    WITH LONGREC(DATA) DO AFTEREND := LO;
    AFTEREND := AFTEREND + LEN1 + LEN2;
    WITH LONGREC(AFTEREND) DO
      IF HI <> 0 THEN EXIT;
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
  function PARScnt(VAR LS: LONGSTR): word;
  var newls: longstr;  cnt, size: word;
  begin newls := ls;  cnt := 0;
    repeat
      size := pars(newls);
      if size <> 0 then inc(cnt);
    until size = 0;
    parscnt := cnt;
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

  function GETOKEN(var s: string) : string;
  var
    LS: LONGSTR;   LEN: WORD;  RES: STRING;
  BEGIN
    WITH LS DO
      BEGIN   CP := @S[1];  REM:= LENGTH(S);   END;
        LEN := PARS(LS);
        WITH LS DO BEGIN
          RES := MKSTR(ADDPTR(CP,-LEN)^ ,LEN);
          S := MKSTR(CP^,REM);
        END;
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

  {
  function TokenCnt(s: string):integer;
  var len, prev, next, cnt: integer;
  begin prev := 1;  cnt := 0; len := length(s); next := len;
    while next <> 0 do begin
      prev := len-next+prev;
      next := firstNonBlank(@s[prev],next);
      inc(cnt);
      prev := len-next+prev;
      next := firstBlank(@s[prev],next);
    end;
    tokenCnt := cnt;
  end;

  function nthToken(s: string; cnt: integer):string;
  var len, oldprev, prev, next: integer;
  begin prev := 1;  cnt := 0; len := length(s); next := len;
    while (next <> 0) and (cnt>0) do begin
      prev := len-next+prev;
      oldprev := prev;
      next := firstNonBlank(@s[prev],next);
      dec(cnt);
      prev := len-next+prev;
      next := firstBlank(@s[prev],next);
    end;
    if cnt <> 0 then begin nthToken := ''; exit; end;
    nthToken := copy(s,oldprev,prev-oldprev);
  end;

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

BEGIN
END.