PROGRAM hashTEST;  {TESTING UNIT hashlib}

USES baselib, filib, strlib, hashlib;

  var tpls: longstr;
      PH: PHASH;
      used_buckets: word;
      tuples_count: word;
  const top = 101;

  FUNCTION FIND(KEY: STRING): STRING;
    VAR P: PEL;
  BEGIN
    FIND := '';
    P   := PH^.SEARCH(KEY);
    IF  P <> NIL
      THEN FIND := PH^.VALUEtoStr(P);
  END;

  procedure setTuples;
  var token, tkey: string;
      ls: longstr; p: peL;
      IDX: WORD;
  begin ls := tpLs;
    REPEAT  token := lextract(ls);
      IF TOKEN = ''
        THEN BREAK;
      tkey := cutstr(token,',');
      if tkey = ''
         then continue;
      if find(tkey) <> '' then begin
         writeln('Duplicate key : "',tkey,'"');
         continue;
      end;
      PH^.ADDstr(TKEY,TOKEN);
    UNTIL FALSE;
    with tpLs do
      freeMem(cp,rem);
  end;

  procedure rhash(MyHash: pointer; msg: string);
  var i: integer; tuple: pel;
      w, tot, maxind, maxdeep, total: word;
      start, _END_: dword; buckets: ppary;
  begin  buckets := ph^.fpels;
    start := now;

    FOR TOT := 1 TO 1000 DO
      total := ph^.REHASH(top,MyHash);

    tot := total; _END_ := NOW;
    {count new buckets & and chk deep}
    used_buckets := 0;  maxdeep := 0;
    for i := top-1 downto 0 do
      if buckets^[i] <> nil then begin
        inc(used_buckets);
        tuple := buckets^[i];
        w := 0;
        while tuple <> nil do begin
          inc(w);
          tuple := tuple^.fnext;
          dec(total);
        end;
        if maxdeep < w then begin
          maxdeep := w;
          maxind  := i;
        end;
      end;

    {view stats}
    writeln(msg,'ms:',_END_ - start,
      '  maxd-i:',  maxdeep,'.',maxind,
      '  used:',  used_buckets,
      '  dups:',tot-used_buckets,'.',total,
      '  perc:',(used_buckets*100) div tot,
      ' ',(used_buckets*100) div top,
      '  avg_dp:', (tot*100) div used_buckets);

        tuple := buckets^[maxind];
        while tuple <> nil do begin
          write(pstr(@tuple^.ft1)^,' ');
          tuple := tuple^.fnext;
        end;
        writeln;
  end;

BEGIN
  ph := new(phash,create(101,@hgh));
  if not readbin(paramstr(1)+'.tup',tpls) then begin
    writeln('such file not present : ', paramstr(1));
    exit;
  end;
  used_buckets:= 0;
  tuples_count:= 0;
  setTuples;

writeln('  tuples : ',tuples_count);
  rhash(@hgh  ,'hgh    ');
  rhash(@hghw ,'hghw   ');
  rhash(@h8   ,'h8     ');
  rhash(@h16  ,'h16    ');
  rhash(@h32  ,'h32    ');
  rhash(@h8t  ,'h8t    ');
  rhash(@h8t2 ,'h8t2   ');
  rhash(@h16t ,'h16t   ');
  rhash(@h32t ,'h32t   ');
  RHASH(@h32H ,'h32H   ');
  rhash(@hgh2 ,'hgh2   ');

  readln;
END.