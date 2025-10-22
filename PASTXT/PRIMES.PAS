PROGRAM PRIME;

  uses primlib, baselib;

  var t: boolean; i, j, cnt: word; p: pbits; n: dword;

begin
  writeln('Start 0');
  primesIn(1650000001,1650000535);
  writeln('End');
end.



  const nums: array [0..65] of word =(
  44521 , 47053 ,47897 , 48319 , 49163 , 49729 , 50429 , 50621 , 50851 , 51067 ,
51529 , 51959 , 51983 , 52441 , 52891 , 52961 , 53297 , 53357 , 53743 , 54227 ,
54253 , 54289 , 54707 , 54731 , 55189 ,55493 , 55687 , 55973 , 56153 , 56759 ,
56977 , 57121 , 57181 , 57311 , 57479 , 57599 , 58081 , 58339 , 58447 , 58483 ,
58649 , 58853 , 59291 , 59701 , 59713 , 59881 , 59987 , 59989 , 60227 , 60433 ,
60491 , 61063 , 61279 , 61423 , 61517 , 61601 , 61771 , 61823 , 61937 , 62059 ,
62663 , 63001 , 63109 , 64507 , 64777 , 65339 );

  isPrime(47053);   cnt := 0;  writeln;
  for j := 50 to 65 do begin n := nums[j];
    if isPrime(n) then begin writeln; write(n,',',sqrl(n),' '); end;
    for i := 2 to 255 do begin
      if mymod(n,i) = 0 then write(i,' is divider ');
    end;
  end;

  p := new(pbits,create(65535));
  p^.erato;
  {p^.print;}
  writeln('Start 0');
  for i := 0 to 65535 do
    if isPrime(i) <> p^.inset(i) then begin write(i,' ');
      if p^.inset(i) then write('e ') else write ('p ');
      inc(cnt);
      if cnt mod 10 = 0 then writeln;
    end;
  writeln('End');
  {primesIn(-99,-1);}
