program UPCASE(input,aotput);

USES STRLIB;


  procedure perform;
  var orgstr, ares: string;
      cnt, suc: integer;
  begin cnt := 0; suc := 0;
    while not eof(input) do begin
      readln(INPUT,orgstr);
      writeln(OUTPUT,UPCASE(ORGSTR));
    end;
  end;

begin
    {TEST;}
    perform;
end.