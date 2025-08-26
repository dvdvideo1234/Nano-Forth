program TESTLS(input,aotput);

USES STRLIB;


  procedure TEST;
  var orgstr: string;
    LS: LONGSTR;
    LEN: WORD;
    CUT1, CUT2, CUT3, RES: STRING;
  begin
    CUT2 := ''; CUT3 := ''; RES := '|';
      orgstr := '   1!!   2??   3##   4&&   ';
      RES := ORGSTR;
      CUT1 := GETOKEN(RES);
      CUT2 := GETOKEN(RES);
      CUT3 := GETOKEN(RES);
      WRITELN(ORGSTR,' ',CUT1,' ',CUT2,' ',CUT3,' ',RES);
      READLN;
  end;

begin
    TEST;
    {perform;}
end.