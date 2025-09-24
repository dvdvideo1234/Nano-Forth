PROGRAM TESTER(input,output);  {TESTING UNITS}

USES baselib, filib, strlib, hashlib;

  type {pfunc= ^func;}
       TMyFunc = function(s: string): word;

  var tps: longstr;
      buckets: array[0..top-1] of  ptrnode;
      unused: ptrnode;

      {statistics}
      used_buckets: word;
      tuples_count: word;

  procedure setTuples;
  var token, tkey: string;
      ls: longstr; tuple: ptrNode;
  begin ls := tps; unused := nil;  {prepare for rehash}
    token := lextract(ls);
    while token <> '' do begin
      tkey := cutstr(token,',');
      if tkey = ''
         then continue;
      tuple := makeTuple(tkey,token);
      {idx := hash(tkey);}
      if findTuple(tkey, unused) <> nil then begin
         writeln('Duplicate key : ',tkey);
         freetuple(tuple);
         continue;
      end;
      inc(tuples_count);
      pushTuple(tuple, unused);
      token := lextract(ls);
    end;
    with tps do
      freeMem(cp,rem);
  end;

{$f+}
  function h32t(s: string): word;
  var res: dword;
  begin
    res := CRC32t(@s[1],byte(s[0]), -1);
    with longrec(res) do lo := lo xor hi;
    h32t := res mod top ;
  end;

  function h16t(s: string): word;
  var res : word;
  begin
    res := CRC16t(@s[1],byte(s[0]), $ffff);
    h16t := res mod top ;
  end;

  function h8t(s: string): word;
  var res : word;
  begin
    res := CRC8t(@s[1],byte(s[0]), $ff);
    h8t := res mod top ;
  end;

  function h32(s: string): word;
  var res : dword;
  begin    {const poly=$EDB88320;}
    res := CRC32(@s[1],byte(s[0]), -1, $EDB88320);
    with longrec(res) do lo := lo xor hi;
    h32 := res mod top ;
  end;

  function h16(s: string): word;
  var res : word;
  begin
    res := CRC16(s[1],byte(s[0]), $ffff, $c867);
    h16 := res mod top ;
  end;

  function h8(s: string): word;
  var res : word;
  begin
    res := CRC8(s[1],byte(s[0]), $ff, $67);
    h8 := res mod top ;
  end;

  function hghw(s: string): word;
  var res : word;
  begin
    res := GEThash(s[1],byte(s[0]), $ffff, $c867);
    hghw := res mod top ;
  end;

  function hgh(s: string): integer;
  var res : word;
  begin
    res := GEThw(@s[1],byte(s[0]), $ffff, $c867);
    hgh := res mod top ;
  end;

  function hgh2(s: string): integer;
  var res : word;
  begin
    res := GEThw2(@s[1],byte(s[0]), $ffff, $c867);
    hgh2 := res mod top ;
  end;
{$f-}

  procedure rehash(MyHash: pointer; msg: string);
  var i: integer; bucket, tuple: ptrNode;
      w, tot, maxind, maxdeep, total: word;
      start: dword;
  begin
    start := now;
    {free buckets}
    for i := top-1 downto 0 do begin
      bucket := buckets[i];
      buckets[i] := nil ;
      while bucket <> nil do begin
        pushTuple(poptuple(bucket), unused);
      end;
    end;

    total := 0;
    {real rehash}
    while unused <> nil do begin
      tuple := popTuple(unused);
      w := tMyFunc(MyHash)(ptuple(tuple)^.key);
      pushTuple(tuple,buckets[w]);
      inc(total);
    end;

    tot := total;
    {count new buckets & and chk deep}
    used_buckets := 0;  maxdeep := 0;
    for i := top-1 downto 0 do
      if buckets[i] <> nil then begin
        inc(used_buckets);
        tuple := buckets[i];
        w := 0;
        while tuple <> nil do begin
          inc(w);
          tuple := tuple^.next;
          dec(total);
        end;
        if maxdeep < w then begin
          maxdeep := w;
          maxind  := i;
        end;
      end;

    {view stats}
    writeln(msg,'ms: ',now - start,
      '  maxd-i: ',  maxdeep,' ',maxind,
      '  used: ',  used_buckets,
      '  dups: ',tot-used_buckets,
      '  perc: ',(used_buckets*100) div tot,
      '  total: ', total);

        tuple := buckets[maxind];
        while tuple <> nil do begin
          write(ptuple(tuple)^.key,' ');
          tuple := tuple^.next;
        end;
        writeln;
  end;

BEGIN
  if not getuples(paramstr(1)+'.tup',tps) then begin
    writeln('such file not present : ', paramstr(1));
    exit;
  end;
  used_buckets:= 0;
  tuples_count:= 0;
  setTuples;

writeln('  tuples : ',tuples_count);
  rehash(@hgh  ,'hgh    ');
  rehash(@hghw ,'hghw   ');
  rehash(@h8   ,'h8     ');
  rehash(@h16  ,'h16    ');
  {rehash(@h32  ,'h32    ');}
  rehash(@h8t  ,'h8t    ');
  rehash(@h16t ,'h16t   ');
  {rehash(@h32t ,'h32t   ');}
  rehash(@hgh2 ,'hgh2   ');

  readln;
END.