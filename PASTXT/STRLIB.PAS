UNIT STRLIB;

INTERFACE

  type 
	cptr	= ^char;
        WPTR    = ^WORD;
	PSTR	= ^STRING;
    wordREC	= record lo, hi:  BYTE; end;
    LONGREC	= record lo, hi:  word; end;
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
  
  function PARS(VAR LS: LONGSTR): word;
  FUNCTION ADDptr(ptr: POINTER; sz: integer): POINTER;
  function MKSTR(var s; B: BYTE) : string;
  function MKSTROF(C: CHAR; B: BYTE) : string;

  function cutStr(var s: string; del: char): string;
  function GETOKEN(var s: string) : string;

IMPLEMENTATION


  function boolTxt(cond: boolean): str5;
    const strbul: array[boolean] of str5
          = ('False','True');
  begin
    booltxt := strBul[cond];
  end;

  function PARS(VAR LS: LONGSTR): word;
	VAR RES: LONGSTR; len: word;
  begin
    RES := LS;
    asm
	LES     DI,[RES.CP]
	mov	CX,RES.REM
	mov	AL,' '
	inc CX
@@1:
	DEC	CX
	JZ @@SKIPX
	SCASB
	JAE @@1       { SPACE IS ABOVE OR EQUAL TO }
	DEC     DI
@@SKIPX:
	push    di    {;  START OF THE WORD}
	JCXZ @@WEX
	inc CX
@@3:
	DEC	CX
	JZ @@WEX
	SCASB           { SPACE IS BELOW THEN}
	JB @@3
	DEC     DI
@@WEX:          {; END OF THE WORD  IN DI}
	POP	AX      {; START OF THE WORD}
	mov	WORD PTR [RES.CP],DI
	SUB     DI,ax   {; LENGTH OF THE WORD}
	mov	WORD PTR [LEN],DI
	mov	WORD PTR [RES.REM],CX
	END;
    LS := RES;
    pars := LEN;
  END;

  FUNCTION ADDptr(ptr: POINTER; sz: integer): POINTER;
  VAR  CP: LONGREC ABSOLUTE PTR;
  BEGIN  WITH CP DO  LO := LO + SZ;
    ADDPTR := PTR;
  END;

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