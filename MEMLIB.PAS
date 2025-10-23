UNIT MEMLIB;

interface

USES BASELIB;

  TYPE

  TMEM = OBJECT

    fmem  : parbyte;
    fsize : word;
    fhp   : word;   {here pointer = WHERE TO STORE NEXT}
    fOFST : word;   {OFFSET TO HERE = BY ADDING WE GET COMPILED ADDRESS}

    constructor create(START, sz: word);
    destructor  done;
    FUNCTION    MEMADR(A: WORD): POINTER;
    FUNCTION    ADREL(A: WORD): WORD;
    PROCEDURE   DUMPB(ADR, LEN:  WORD);
    procedure   error(cond: boolean; s: string); VIRTUAL;
    procedure   STRCOMMA(STR: STRING);
    PROCEDURE   TOMEMB(A: WORD; B: BYTE);
    PROCEDURE   TOMEMW(A, B: WORD);   {memory}
    PROCEDURE   TOMEML(A: WORD; L: DWORD);
    FUNCTION    FROMEMB(A: WORD): BYTE;
    FUNCTION    FROMEMW(A: WORD): WORD;
    FUNCTION    FROMEML(A: WORD): DWORD;
    procedure   commaB(B: BYTE);
    procedure   commaW(W: WORD);
    procedure   commaL(L: DWORD);
  END;


implementation


  procedure   tMEM.error(cond: boolean; s: string);
  begin
  end;

  FUNCTION    tMEM.ADREL(A: WORD): WORD;
  begin
    DEC(A,FOFST); ADREL := A;
  end;

  PROCEDURE   tMEM.DUMPB(ADR, LEN:  WORD);
  VAR O: WORD ABSOLUTE ADR; CNT: WORD;
      C: CHAR; B: BYTE ABSOLUTE C; RES: STR35;
  BEGIN CNT := 0;
    FOR LEN := LEN DOWNTO 1 DO BEGIN
      IF (CNT AND 15) = 0 THEN BEGIN
        WRITE(WORDTOHEX(ADR),':'); RES := ' [';
      END;
      B := FROMEMB(ADR);
      WRITE(BYTETOHEX(B),' ');
      IF B IN [0..31,127,255] THEN C := '.';
      RES := RES + C;
      IF (CNT AND 15) = 15 THEN WRITELN(RES,']');
      INC(CNT); INC(O);
    END;
    IF (CNT AND 15) <> 0 THEN WRITELN(RES,']');
  END;

  constructor tMEM.create(START, sz: word);
  begin
    MYgetmem(POINTER(fmem),sz);         {memory}
    fsize := sz;
    fhp   := START;
    fOFST := START;
  end;

  destructor  tMEM.done;
  begin
    freeMem(fmem,fsize);
  end;

  PROCEDURE   tMEM.TOMEMB(A: WORD; B: BYTE);
  BEGIN PBYTE(MEMADR(A))^ := B;  END;

  PROCEDURE   tMEM.TOMEMW(A, B: WORD);
  BEGIN PWORD(MEMADR(A))^ := B;  END;

  PROCEDURE   tMEM.TOMEML(A: WORD; L: DWORD);
  BEGIN PLONG(MEMADR(A))^ := L;  END;

  FUNCTION    tMEM.MEMADR(A: WORD): POINTER;
  CONST CERR = 'ADDRES OUT OF RANGE';
  BEGIN
    ERROR(A < FOFST, '< ' + CERR);
                     DEC(A,FOFST);
    ERROR(A >= FSIZE, CERR + ' >=');
    MEMADR := @fmem^[A];
  END;

  FUNCTION    tMEM.FROMEMB(A: WORD): BYTE;
  begin
    FROMEMB := PBYTE(MEMADR(A))^;
  end;

  FUNCTION    tMEM.FROMEMW(A: WORD): WORD;
  begin
    FROMEMW := PWORD(MEMADR(A))^;
  end;

  FUNCTION    tMEM.FROMEML(A: WORD): DWORD;
  begin
    FROMEML := PLONG(MEMADR(A))^;
  end;

  procedure   tMEM.commaB(B: BYTE);
  begin MEMADR(fhp+1);
    TOMEMB(fhp,B);
    inc(fhp,1);
  end;

  procedure   tMEM.commaW(W: WORD);
  begin MEMADR(fhp+2);
    TOMEMW(fhp,W);
    inc(fhp,2);
  end;

  procedure   tMEM.commaL(L: DWORD);
  begin MEMADR(fhp+4);
    TOMEML(fhp,L);
    inc(fhp,4);
  end;

  procedure   tMEM.STRCOMMA(STR: STRING);
  VAR SZ: BYTE ABSOLUTE STR;
  begin MEMADR(fhp+SZ);
    move(STR[1],MEMADR(fhp)^,SZ);
    inc(fhp,SZ);
  end;

BEGIN
END.
