program UP3(input,aotput);

USES STRLIB;


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
        IF ((CUT2 = 'WORD') OR (CUT2 = 'NEAR')) AND (RES='MYCSEG')
            THEN   writeln(OUTPUT,cut3 + ' =: ' + CUT1);
      END;
    end;
    {writeln(ln);}
  end;

begin
    {TEST;}
    perform;
end.