PROGRAM TESTER(input,output);  {TESTING UNITS}

USES baselib, filib, strlib, hashlib;


BEGIN
  if not getuples(paramstr(1)+'.tup',tps) then begin
    writeln('such file not present : ', paramstr(1));
    exit;
  end;
END.