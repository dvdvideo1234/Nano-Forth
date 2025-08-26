program UP(input,aotput);

USES STRLIB;


  procedure perform;
  var orgstr: string;
  begin
    while not eof(input) do begin
      readln(INPUT,orgstr);
      writeln(OUTPUT,UPCASE(ORGSTR));
    end;
  end;

begin
    {TEST;}
    perform;
end.