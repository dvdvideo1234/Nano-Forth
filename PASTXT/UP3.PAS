program UP3;

USES BASELIB, STRLIB, FILIB;

  VAR TF, OK: BOOLEAN;
      TPLS: LONGSTR;
      IFILE, OFILE, TUPLEF: TEXT;
      FNAME: STRING;
      buckets: array[0..top-1] of  ptrnode;

  function HASH(s: string): integer;
  begin
    HASH := MEMHASH(@s[1],byte(s[0]), $ffff, $c867) mod top ;
  end;

  FUNCTION FIND(KEY: STRING): STRING;
    VAR P: PTUPLE;
  BEGIN
    FIND := '';
    P   := PTUPLE(FINDTUPLE(KEY,buckets[HASH(KEY)]));
    IF  P <> NIL
      THEN FIND := P^.VALUE^;
  END;

{
  PROCEDURE DUMPHASH;
  VAR FO: TEXT; P: PTRNODE; IDX: WORD;

    PROCEDURE DMPBK(PBK: PTRNODE);
      var fndptr: ptuple absolute PBK;
    BEGIN IF PBK = NIL THEN EXIT;
      while PBK <> nil do begin
        WITH FNDPTR^ DO
          WRITE(FO,KEY+','+VALUE^+' ');
        PBK := PBK^.next;
      end;
      WRITELN(FO);
    END;

  BEGIN
    OPENTEXT(FNAME+'.DMP',FO,TRUE);
    FOR IDX := 0 TO TOP-1 DO
      DMPBK(BUCKETS[IDX]);
    CLOSE(FO);
  END;
}

  procedure setTuples;
  var token, tkey: string;
      ls: longstr; tuple: ptrNode;
      IDX: WORD;
  begin ls := tpLs;
    token := lextract(ls);
    while token <> '' do begin
      tkey := cutstr(token,',');
      if tkey = ''
         then continue;
      IDX := HASH(TKEY);
      if findTuple(tkey, buckets[IDX]) <> nil then begin
         writeln('Duplicate key : ',tkey);
         continue;
      end;
      tuple := makeTuple(tkey,token);
      pushTuple(tuple, buckets[IDX]);
      token := lextract(ls);
    end;
    with tpLs do
      freeMem(cp,rem);
    {DUMPHASH;}
  end;

  FUNCTION filter(line: string; var adrs, name: string) : boolean;
  var  CUT1, CUT2, CUT3 : string;
  begin  filter := false;
    if length(line) < 13
      then exit;
    if not (line[1] in ['_','?','@'..'Z','a'..'z'])
      then exit;
    if (line[1] in ['_','@','?']) and (line[2] in ['_','@','?'])
      then exit;
    line := upcase(line);
    cut1 := getoken(line);
    cut2 := copy(cut1,1,3);
    IF (cut2 = 'AT_') OR (CUT2 = 'TO_')
      THEN EXIT;
    cut2 := getoken(line);
    if (cut2 = '') or (not ((CUT2 = 'WORD') OR (CUT2 = 'NEAR')))
      then exit;
    cut3 := getoken(line);
    if cut3 = ''
      then exit;
    line := CUTSTR(CUT3,':');
    if line <> 'MYCSEG'
      THEN EXIT;
    ADRS := cut3;
    NAME := CUT1;
    FILTER := TRUE;
  end;

  procedure perform;
  var
    str, ADRS, NAME, RES : string;
  begin
    OK := OPENTEXT(FNAME+'.UP',OFILE,TRUE);     { FOR WRITING}
    IF NOT OK THEN BEGIN
      WRITELN('CAN''T OPEN FILE '+FNAME+'.UP');
      EXIT;
    END;
    OPENTEXT(FNAME+'.LST',IFILE,FALSE);         { FOR READING}
    while not eof(IFILE) do begin
      readln(IFILE,str);
      IF FILTER(STR,ADRS,NAME) THEN BEGIN
        ADRS := '$'+ADRS;
        IF NAME[1] = '@'
          THEN NAME[1] := '`';
        IF TF THEN BEGIN
          STR := FIND(NAME);
          IF STR <> '' THEN NAME := STR;
        END ELSE WRITELN(TUPLEF,NAME + ',' + NAME);
        writeln(OFILE,ADRS + ' =: ' + NAME);
      END;
    end;
    CLOSE(IFILE);
    CLOSE(OFILE);
  end;

begin
    IF PARAMCOUNT = 0 THEN BEGIN
      WRITELN('NO PARAMS');
      EXIT;
    END;
    FNAME := PARAMSTR(1);
    IF FILEXIST(FNAME+'.LST') < 2 THEN BEGIN
      WRITELN(FNAME+'.LST NOT EXIST OR EMPTY');
      EXIT;
    END;

    {TEST;}
    TF := GETUPLES(FNAME+'.TUP',TPLS);
    IF NOT TF THEN BEGIN
      OK := OPENTEXT(FNAME+'.UP1',TUPLEF,TRUE);
      IF NOT OK THEN BEGIN
        WRITELN('CAN''T OPEN FILE '+FNAME+'.UP1');
        EXIT;
      END;
    END ELSE SETTUPLES;

    perform;

    IF NOT TF
      THEN CLOSE(TUPLEF);
end.