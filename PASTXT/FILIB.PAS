UNIT FILIB;

INTERFACE

  USES baselib, STRLIB;

  TYPE BFILE = FILE;

  FUNCTION FILEXIST(FNAM: STRING): boolean;
  FUNCTION readbin(FNAM: STRING; VAR LS: LONGSTR): BOOLEAN;
  FUNCTION OPENTEXT(FNAM: STRING; VAR FI: TEXT; WRFL: BOOLEAN): BOOLEAN;

IMPLEMENTATION

  FUNCTION FILEXIST(FNAM: STRING): boolean;
  VAR TF: BFILE; SUCCESS: BOOLEAN; sz: longint;
  BEGIN
    ASSIGN(TF,FNAM);
    {$I-}
    RESET(Tf,1);
    {$I+}
    SUCCESS := IORESULT = 0 ;
    FILEXIST := false;
    if not success then exit;
    SZ := FILESIZE(tF);
    CLOSE(TF);
    if sz = 0 then exit;
    FILEXIST := true;
  END;

  FUNCTION OPENTEXT(FNAM: STRING; VAR FI: TEXT; WRFL: BOOLEAN): BOOLEAN;
  BEGIN
    ASSIGN(FI,FNAM);
    {$I-}
    IF WRFL
      THEN REWRITE(FI)
      ELSE  RESET(FI);
    {$I+}
    OPENTEXT := IORESULT = 0 ;
  END;

  FUNCTION readbin(FNAM: STRING; VAR LS: LONGSTR): BOOLEAN;
  VAR     FTS: BFILE;    MEM: Pchar;    SZ: WORD;
  BEGIN
    readbin := FALSE;
    IF not FILEXIST(FNAM) THEN EXIT;
    ASSIGN(Fts,FNAM);
    RESET(Fts,1);
    SZ := FILESIZE(FTS);
    GETMEM (MEM,SZ);
    BLOCKREAD(FTS,MEM^,SZ);
    CLOSE(FTS);
    setLstr(ls,mem,sz);
    readbin := TRUE;
  END;

BEGIN
END.