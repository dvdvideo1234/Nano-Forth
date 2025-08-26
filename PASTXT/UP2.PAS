program UP2(input,aotput);

USES STRLIB;


  procedure perform;
  var orgstr, RES, CUT1, CUT2, CUT3 : string;
    P1, P2, P3: INTEGER;
  begin
    while not eof(input) do begin
      readln(INPUT,orgstr);
      RES := UPCASE(fixblanks(ORGSTR));
      IF (RES<>'') AND (RES[1] IN ['@'..'Z'])
        THEN BEGIN
          P1 := POS('WORD', RES);
          P2 := POS('NEAR', RES);
          IF (P2 <> 0) OR (P1 <> 0)
            THEN writeln(OUTPUT,RES);
        END;
    end;
  end;

begin
    {TEST;}
    perform;
end.