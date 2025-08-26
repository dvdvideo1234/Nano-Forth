program UP1(input,aotput);

USES STRLIB;


  procedure perform;
  var orgstr, RES: string;
  begin
    while not eof(input) do begin
      readln(INPUT,orgstr);
      RES := UPCASE(ORGSTR);
      IF (RES<>'') AND (RES[1] IN ['@'..'Z'])
        THEN writeln(OUTPUT,RES);
    end;
  end;

begin
    {TEST;}
    perform;
end.