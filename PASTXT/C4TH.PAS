program c4th;

uses c4thlib, BASElIB;

  var fth: tc4th;

begin
  fth.create(100,20,$100,WORD(-$100));
  with fth do begin
    forth('');
  end;
  {WRITELN(ITOA(-1,10));}
end.