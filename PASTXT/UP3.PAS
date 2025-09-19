program UP3;

USES STRLIB, FILIB;

  VAR TF, OK: BOOLEAN;
      TPLS: LONGSTR;
      IFILE, OFILE, TUPLEF: TEXT;
      FNAME: STRING;

  procedure perform;
  var
    orgstr, RES, CUT1, CUT2, CUT3 : string;
    ln: word; f1, f2: byte;
  begin ln := 0;
    while not eof(IFILE) do begin
      readln(IFILE,orgstr);
      f1 :=  ord(orgstr[1] IN ['_','@','?']);
      f2 :=  ord(orgstr[2] IN ['_','@','?']);
      IF (LENGTH(orgstr) >2)
         AND (orgstr[1] IN ['_','?','@'..'Z','a'..'z'])
         AND ((f1 + f2) < 2 )
      THEN BEGIN
        inc(ln);
        res := UPCASE(fixblanks(orgstr));
        CUT1 := cutstr(RES,' ');
        if cut1[1] = '@' then cut1[1] := '`';
        CUT2 := GETOKEN(RES);
        CUT3 := GETOKEN(RES);
        RES := CUTSTR(CUT3,':');
        cut3 := '$' + cut3;
        IF ((CUT2 = 'WORD') OR (CUT2 = 'NEAR')) AND (RES='MYCSEG') THEN
        BEGIN cut2 := copy(cut1,1,3);
         if NOT ((cut2 = 'AT_') OR (CUT2 = 'TO_')) THEN BEGIN
          IF TF THEN BEGIN
            RES := FINDTUPLE(CUT1,TPLS);
            IF RES <> '' THEN CUT1 := RES;
          END ELSE WRITELN(TUPLEF,CUT1+','+CUT1);
          writeln(OFILE,cut3 + ' =: ' + CUT1);
         END;
        END;
      END;
    end;
  end;

begin
    IF PARAMCOUNT = 0 THEN BEGIN
      WRITELN('NO PARAMS');
      EXIT;
    END;
    FNAME := PARAMSTR(1);
    IF NOT FILEXIST(FNAME+'.LST') THEN BEGIN
      WRITELN(FNAME+'.LST NOT EXIST');
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
    END;
    OPENTEXT(FNAME+'.LST',IFILE,FALSE);         { FOR READING}
    OK := OPENTEXT(FNAME+'.UP',OFILE,TRUE);     { FOR WRITING}
    IF NOT OK THEN BEGIN
      WRITELN('CAN''T OPEN FILE '+FNAME+'.UP');
      EXIT;
    END;

    perform;
    {FINDTUPLE('ABORT',TPLS);}

    IF NOT TF
      THEN CLOSE(TUPLEF)
      ELSE WITH TPLS DO FREEMEM(CP,REM);
    CLOSE(IFILE);
    CLOSE(OFILE);
end.