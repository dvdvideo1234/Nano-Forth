program c4th;

uses c4thlib, BASElIB;

  var fth: tc4th;

begin
  fth.create(100,20,65535);
  with fth do begin
    forth('1 , 2 ,  3 , ');
  end;
  {WRITELN(ITOA(-1,10));}
end.