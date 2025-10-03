program UP3;

USES BASELIB, STRLIB, FILIB, HASHLIB;

  VAR TF, OK: BOOLEAN;
      TPLS: LONGSTR;
      IFILE, OFILE, TUPLEF: TEXT;
      FNAME: STRING;
      PH: PHASH;

  FUNCTION FIND(KEY: STRING): STRING;
    VAR P: PEL;
  BEGIN
    FIND := '';
    P   := PH^.SEARCH(KEY);
    IF  P <> NIL
      THEN FIND := PH^.GETVALUE(P)^;
  END;

  procedure prepout(var str: string);
  begin
  end;

  procedure setTuples;
  var token, tkey: string;
      ls: longstr; p: peL;
      IDX: WORD;
  begin ls := tpLs;
    REPEAT  token := lextract(ls);
      IF TOKEN = ''
        THEN BREAK;
      tkey := cutstr(token,',');
      if tkey = ''
         then continue;
      if find(tkey) <> '' then begin
         writeln('Duplicate key : "',tkey,'"');
         continue;
      end;
      PH^.ADD(TKEY,TOKEN);
    UNTIL FALSE;
    with tpLs do
      freeMem(cp,rem);
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
    ph := new(phash,create(251,@H32H));

    IF PARAMCOUNT = 0 THEN BEGIN
      WRITELN('NO PARAMS');
      EXIT;
    END;
    FNAME := PARAMSTR(1);
    IF not FILEXIST(FNAME+'.LST') THEN BEGIN
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
    END ELSE begin
      SETTUPLES;
      IF not FILEXIST(FNAME+'.com') THEN BEGIN
        WRITELN(FNAME+'.com NOT EXIST OR EMPTY');
        EXIT;
      END;

      writeBody;
    end;

    perform;

    IF NOT TF
      THEN CLOSE(TUPLEF);

    PH^.DONE;
end.