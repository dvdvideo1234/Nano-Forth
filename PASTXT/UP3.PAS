program UP3;

USES BASELIB, STRLIB, FILIB, HASHLIB;

  type
    tchkname  = procedure (var name: string);
    tproc     = procedure;

  VAR TPLS: LONGSTR;
      IFILE, OFILE, TUPLEF: TEXT;
      FNAME: STRING;
      PH: PHASH;
      chkproc, finish: pointer;

  FUNCTION FIND(KEY: STRING): STRING;
    VAR P: PEL;
  BEGIN
    FIND := '';
    P   := PH^.SEARCH(KEY);
    IF  P <> NIL
      THEN FIND := PH^.VALUEtoStr(P);
  END;

  {$f+}
  procedure TuplefOut(var name: string);
  begin
    WRITELN(TUPLEF,NAME + ',' + NAME);
  end;

  procedure ChkName(var name: string);
  var str: string;
  begin
    STR := FIND(NAME);
    IF STR <> '' THEN NAME := STR;
  end;

  procedure Close2;
  begin
    CLOSE(IFILE);
    CLOSE(OFILE);
    PH^.DONE;
  end;

  procedure Close3;
  begin
    CLOSE2;
    CLOSE(TUPLEF);
  end;

  {$f-}

  procedure writeBody;
  var ls: longstr; fo_bdy: text;
  begin
    IF not readbin(FNAME+'.com',tpls) THEN BEGIN
      WRITELN(FNAME+'.com NOT EXIST OR EMPTY');
      EXIT;
    END;
    IF NOT OPENTEXT(FNAME+'.bdy',fo_bdy,TRUE) THEN BEGIN   { FOR WRITING}
      WRITELN('CAN''T OPEN FILE '+FNAME+'.bdy');
      with tpLs do
        freeMem(cp,rem);
      EXIT;
    END;

    ls := tpls;
    while ls.rem > 0 do
      writeln(fo_bdy,',"' + edgeUnpack(ls,60) + '"');

    close(fo_bdy);
    with tpLs do
      freeMem(cp,rem);
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
      PH^.ADDstr(TKEY,TOKEN);
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
    IF NOT OPENTEXT(FNAME+'.UP',OFILE,TRUE) THEN BEGIN { FOR WRITING}
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
        tchkname(chkproc)(name);
        writeln(OFILE,ADRS + ' =: ' + NAME);
      END;
    end;
    tproc(finish);
  end;

begin
    IF PARAMCOUNT = 0 THEN BEGIN
      WRITELN('NO PARAMS');
      EXIT;
    END;
    FNAME := PARAMSTR(1);
    IF not FILEXIST(FNAME+'.LST') THEN BEGIN
      WRITELN(FNAME+'.LST NOT EXIST OR EMPTY');
      EXIT;
    END;

    ph := new(phash,create(251,@H32H));
    IF NOT readbin(FNAME+'.TUP',TPLS) THEN BEGIN
      IF NOT OPENTEXT(FNAME+'.UP1',TUPLEF,TRUE) THEN BEGIN
        WRITELN('CAN''T OPEN FILE '+FNAME+'.UP1');
        PH^.DONE;
        EXIT;
      END;
      chkproc := @TuplefOut;    finish := @Close3;
    END ELSE begin
      SETTUPLES;
      writeBody;
      chkproc := @ChkName;      finish := @Close2;
    end;

    perform;

end.