program UP3(input,oUtput);

USES STRLIB, FILIB;

  VAR TF: BOOLEAN;
      TPLS: LONGSTR;
      TUPLEF: TEXT;

  procedure perform;
  var
    orgstr, RES, CUT1, CUT2, CUT3 : string;
    ln: word;
  begin ln := 0;
    while not eof(input) do begin
      readln(INPUT,orgstr);
      IF (LENGTH(orgstr) >2)
         AND (orgstr[1] IN ['@'..'Z','a'..'z'])
         AND (orgstr[2] <> '@')
      THEN BEGIN
        inc(ln);
        res := UPCASE(fixblanks(orgstr));
        CUT1 := cutstr(RES,' ');
        if cut1[1] = '@' then cut1[1] := '`';
        CUT2 := GETOKEN(RES);
        CUT3 := GETOKEN(RES);
        RES := CUTSTR(CUT3,':');
        cut3[1] := '$';
        IF ((CUT2 = 'WORD') OR (CUT2 = 'NEAR')) AND (RES='MYCSEG') THEN
        BEGIN
          IF TF THEN BEGIN
            RES := FINDTUPLE(CUT1,TPLS);
            IF RES <> '' THEN CUT1 := RES;
          END ELSE WRITELN(TUPLEF,CUT1+','+CUT1);
          writeln(OUTPUT,cut3 + ' =: ' + CUT1);
        END;
      END;
    end;
  end;

begin
    {TEST;}
    TF := GETUPLES('NF01.UP2',TPLS);
    IF NOT TF THEN BEGIN
      ASSIGN(TUPLEF,'NF01.UP1');
      REWRITE(TUPLEF);
    END;

    perform;
    {FINDTUPLE('ABORT',TPLS);}

    IF NOT TF
    THEN CLOSE(TUPLEF)
    ELSE WITH TPLS DO
       FREEMEM(CP,REM);
end.