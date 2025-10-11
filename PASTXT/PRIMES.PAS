PROGRAM PRIME;

  uses baselib;

  TYPE p48 = set of 0..47;
    PRISET = SET OF BYTE;  {wordREC	= record lo, hi:  BYTE; end;}
  const
    PRTOP = WORD(-1);
    pm210: priset = [1,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,
           79,83,89,97,101,103,107,109,113,121,127,131,137,139,143,149,151,
           157,163,167,169,173,179,181,187,191,193,197,199,209
           ];
    pm209: priset = [0,11,19,22,33,38,44,55,57,66,76,77,88,95,99,110,114,
           121,132,133,143,152,154,165,171,176,187,190,198
           ];
    pm221: priset = [0,13,17,26,34,39,51,52,65,68,78,85,91,102,104,117,119,
           130,136,143,153,156,169,170,182,187,195,204,208
           ];
    p256:  priset = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,
           71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,
           157,163,167,173,179,181,191,193,197,199,211,223,227,229,233,239,
           241,251
           ];
    r210: array[0..37] of byte = ( 23, 29, 31, 37, 41, 43, 47, 53, 59, 61,
           67, 71, 73, 79, 83, 89, 97,101,103,107,109,113,127,131,137,139,
           149,151,157,163,167,173,179,181,191,193,197,199
           );
    i48: array[0..47] of byte = (1,11,13,17,19,23,29,31,37,41,43,47,53,59,
         61,67,71,73,79,83,89,97,101,103,107,109,113,121,127,131,137,139,
         143,149,151,157,163,167,169,173,179,181,187,191,193,197,199,209
         );
    I38: array[0..37] of byte = (23,29,31,37,41,43,47,53,59,61,67,
           71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,
           157,163,167,173,179,181,191,193,197,199
         );
  VAR  AP: ARRAY[BYTE] OF PRISET;
       ap4: array[1..SUCC(dword(65536+209) div 210)] of p48;
       ind,  {IN P48                GLOBAL VARIABLES}
       SIB,  {IN I48  I38}
       base, { IND * 210}
       psbl: word; {POSIBLE CANDIDATE}



  function  mul(a,b:word):dword; inline($58/$5a/$f7/$e2);

  function usqr(a: word): dword;
  begin usqr := mul(a,a);
  end;

  {posible primes in modulo}
  procedure merat(ps: priset; var res: priset);
  var inr: priset; i, s, e: word;
  begin e := 1; inr := [];
    for i := 0 to 255 do if i in ps then e := e * i;
    for i := 0 to 19 do if i in ps then begin s := 0;
      while s < e do begin
        inr := inr + [s];
        s := s + i;
      end;
    end;
    res := inr;
  end;

  procedure show(ps: priset);
  var i, c: byte;
  begin  c := 0; writeln;
    for i := 0 to 255 do if i in ps
      then begin inc(c); write(i,' '); end;
    writeln('  ',c);
  end;

  procedure invert(var ps: priset; limit: word);
  var i: word;
  begin
    for i := 0 to limit do
      if i in ps
        then ps := ps - [i]
        else ps := ps + [i];
  end;

  PROCEDURE EXCL(P: WORD);
  BEGIN
    WITH WORDREC(P) DO
      AP[HI] := AP[HI] - [LO];
  END;

  FUNCTION INPR(P: WORD): BOOLEAN;
  BEGIN
    WITH WORDREC(P) DO
      INPR := LO IN AP[HI];
  END;

  PROCEDURE INCL(P: WORD);
  BEGIN
    WITH WORDREC(P) DO
      AP[HI] := AP[HI] + [LO];
  END;

  PROCEDURE ERATO;
    VAR I, J, S, LAST: WORD;
    BEGIN
      FOR I := 0 TO 255 DO AP[0] := AP[0] + [I];
      FOR I := 1 TO 255 DO AP[I] := AP[0];
      EXCL(0); EXCL(1);

      FOR I := 2 TO 255 DO BEGIN
        IF INPR(I) THEN BEGIN
          S := I;
          J := S + S;   LAST := S;
          WHILE J > LAST DO BEGIN
            EXCL(J);
            LAST := J;
            J := J + S;
          END;
        END;
      END;
    END;

  PROCEDURE PRINT;
    VAR I, C: WORD;
  BEGIN
    C := 0;
    FOR I := 0 TO PRTOP DO
      IF INPR(I) THEN BEGIN
        INC(C);
        IF C MOD 10 = 0
          THEN WRITELN(I)
          ELSE WRITE(I,' ');
      END;
    WRITELN;
  END;

  function mymod(n: dword; m: word): word;
  begin
    mymod := divmod(n,m);
  end;

  procedure convert; {ind in }
  var t: dword;
  begin ind := 1;
    for SIB := 0 to 47 do ap4[1] := ap4[1] - [SIB]; {CLEAR FIRST}
    for SIB := 2 to SUCC(dword(65536+209) div 210) do
      ap4[SIB] := ap4[1]; {clear all}
    base := 0; ind := 0; SIB := 48;
    repeat if SIB = 48 then begin SIB := 0; inc(ind); inc(base,210); end;
      t := base; INC(T,i48[SIB]);  inc(SIB);
      if t > 65535 then break;
      if inpr(t)
        then  ap4[ind] := ap4[ind] + [SIB];
    until false;
    DUMP(@AP4,SIZEOF(AP4) DIV SIZEOF(POINTER));
    writeln(SIZEOF(AP4));
    writeln(ind,' ',ind*210,' ',t, ' ',SIB,' ',I48[SIB]);
  end;

  PROCEDURE CONVERT_TEST;
  BEGIN
  END;

  function isPrime(n: longint): boolean;
  var qrt, ind, j, base, psbl: word;
    PROCEDURE NEXT;    BEGIN
      IF IND = WORD(-1) THEN BEGIN PSBL := I38[J];
        IF J = 38 THEN BEGIN INC(IND); J := 46; END;
        INC(J); EXIT;
      END;
      REPEAT INC(J);
        if j = 48 then begin j := 0; inc(ind); inc(base,210); end;
        PSBL := BASE + i48[j];
      UNTIL J IN AP4[IND];
    END;
  begin  isPrime := false;
    if (n < 256) and (n in p256) then BEGIN isPrime := true; exit; END;
    if not (mymod(n,210) in pm210) then exit; {2, 3, 5, 7}
    if     mymod(n,209)  in pm209  then exit; {11, 19}
    if     mymod(n,221)  in pm221  then exit; {13, 17}
    if n < 19*19 then begin isPrime := true; exit; end;
    qrt := sqrl(n);
    J := 0; BASE := 0; IND := WORD(-1);
    repeat
      NEXT;
      IF MYMOD(N,PSBL) = 0 THEN EXIT;
    until psbl = qrt;
    isPrime := true;
  end;

  BEGIN
    erato;
    convert;
    show(pm210);
    {CONVERT_TEST;
    show(p256-[0..22,210..255]);
    show(pM210-[0..22,210..255]);}

  END.

    {hlp := n;
    rest := divmod(hlp,210); divmod(hlp,sizeof(p48));
    ind := hlp;}

  procedure pl(n: dword);
  begin
    write(n:11,' ',sqrl(n):5,' '{,sqrt(abs(n)):11:3,' '}); readln;
  end;

  procedure testsqrt;
  var n1: longint;
  begin n1 := 1;
    repeat pl(n1); n1 := n1 * 2;
    until n1 < 0;
    repeat pl(n1); n1 := n1 div 2;
    until n1 = 0;
  end;

    writeln(sizeof(ap4));
    t2 := pm210; t := t2 - p256;
    t2 := t2 - t;
    show(t2);
    show(pm210);
    show(p256);
   { ERATO;
    merat([11,19], pm209 );
    merat([2,3,5,7], pm210);
    merat([13,17], pm221);
    p256 := ap[0];}
    show(p256);
    show(pm209);
    show(pm221);
  {  invert(pm210,209);}
    show(pm210);
    {PRINT;}

