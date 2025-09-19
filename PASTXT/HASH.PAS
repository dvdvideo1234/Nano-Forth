UNIT hashTuple;

INTERFACE

USES STRLIB;

CONST TOP = 251;

TYPE
     PtrNODE = ^TUPNODE;
     TUPNODE =
       RECORD
         KEY: STRING;
         VALUE: STRING;
         NEXT: PtrNODE;
       END;

var hashstat: array[0..TOP-1] of PtrNODE;


IMPLEMENTATION

  procedure perform;
  var orgstr, RES, cut1: string;
     c, TOT,  cnt, i: integer;
  begin TOT := 0;
    while not eof(input) do begin
      readln(INPUT,orgstr);
      res := orgstr;
      cut1 := cutstr(res,',');
      IF RES <> '' THEN BEGIN
         TOT := TOT + 1;
         cut1 := UPCASE(cut1);
         {C := CRC32T(PCHAR(@CUT1), byte(cut1[0])+1, $FFFFFFFF, $EDB88320) MOD TOP;}
         C := crc16(cut1,byte(cut1[0])+1,$FFFF,$C867) MOD TOP;
         {C := crc8(cut1,byte(cut1[0])+1,$FF,$67) MOD TOP;}
         inc(hashstat[c]);
         writeln(OUTPUT,BYTETOHEX(C),cut1,',',RES);
      END;
    end;
    cnt := 0; TOT := TOT + 1;
    for i := 0 to TOP-1 do
      if hashstat[i] <> 0 then inc(cnt);
    writeln(output,cnt,' ',TOT,'  % ',CNT * 100 DIV TOT );
  end;

begin
    {TEST;}
    perform;
end.