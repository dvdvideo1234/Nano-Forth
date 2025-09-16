program UP1(input,aotput);

USES STRLIB;


  procedure perform;
  var orgstr, RES, cut1: string;
     c : char;
  begin
    while not eof(input) do begin
      readln(INPUT,orgstr);
      res := orgstr;
      cut1 := cutstr(res,',');
      cut1 := UPCASE(cut1);
      c := gethash(cut1);
      writeln(OUTPUT,c,cut1,',',RES);
    end;
  end;

begin
    {TEST;}
    perform;
end.