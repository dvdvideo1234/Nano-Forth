UNIT PRIMLIB;

INTERFACE

  uses baselib;

  TYPE p48 = set of 0..47;
    PRISET = SET OF BYTE;  {wordREC	= record lo, hi:  BYTE; end;}
    PARSET = ^ARSET;
    ARSET  = ARRAY[BYTE] OF PRISET;
    TCANDI = FUNCTION: BOOLEAN;

  pbits  = ^bits;
  BITS   = OBJECT
    FBITPTR:  PARSET;
    FMAXBIT: WORD;
    FSIZE  : WORD;
    CONSTRUCTOR CREATE(MAXBIT: WORD);
    CONSTRUCTOR VIEW(ADR: POINTER; MAXBIT: WORD);
    DESTRUCTOR  DONE;
    PROCEDURE EXCL(P: WORD);
    FUNCTION INSET(P: WORD): BOOLEAN;
    PROCEDURE INCL(P: WORD);
    PROCEDURE SETBITS(FROMBIT, TOBIT: WORD; STATE: BOOLEAN);
    PROCEDURE INVERTBITS(FROMBIT, TOBIT: WORD);
    PROCEDURE ERATO;
    PROCEDURE PRINT;
  END;

  const
    PRTOP = WORD(-1);

  function   isPrime(n: longint): boolean;
  PROCEDURE  PrimesIn(n1, n2: longint);
  function   mymod(n: dword; m: word): word;
  function   usqr(a: word): dword;

IMPLEMENTATION

  CONST
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
     ARL: ARRAY[0..PRED(1884 DIV 4)] OF DWORD = (
$B3D7F5FA,$5EEE9BB7,$EF5EB1BB,$7D6AB9DE,$1E78F653,$B79AEAEB,$D98D7E2E,$DFF08F6A,
$BBE51A81,$ECFCA4FE,$ACB8E85F,$FC4A574D,$BF70CC54,$AF8CF325,$6DCB9B08,$EABF97C2,
$43E62074,$BBFBA8E6,$7B27D266,$C1D84B54,$468734DA,$178B6738,$318E67BC,$CFD947E4,
$73A5BA4E,$2C58D0B5,$086FE4D7,$95B1C3DC,$EDB608E7,$5135A076,$8F56370C,$6BF22D19,
$67E14D92,$BBAC5502,$D62437B3,$78956A0D,$C0D471C4,$DC74BCF6,$FE205D43,$DC0F1568,
$5852DF9A,$A9746284,$7E14AD46,$EAD64F51,$158C306D,$2463EE24,$CC18B6AE,$5A2E9F16,
$2C73B7B0,$3224D305,$34D20B6F,$E6918822,$99DADB55,$E4737C38,$CF527060,$43882674,
$9C42DEAC,$33DC3DA2,$99E0CB21,$C523B881,$F57B6338,$1CB6618A,$3E0E5D05,$734C82AC,
$2E12539A,$F738C5DA,$80F294DC,$C2B2A7A8,$D39A763C,$814AE31A,$E16CD0C1,$3B6248FA,
$84893D4C,$418A49E3,$18796AE1,$B02A88EA,$62B0A71E,$E16DA215,$7C111DA2,$688C9C96,
$0A3E6352,$62131A82,$B4F024CD,$A766A30F,$E18F0616,$D1503B07,$E06614F6,$BAF19966,
$762EAA3C,$94331962,$4EF8092C,$08D8F1B6,$C07B62BC,$86D982A4,$52D61CC8,$2B18A854,
$4E8EDFA0,$BC781615,$518D8306,$A33C021E,$9C4A0708,$84DB7621,$C187F888,$77582267,
$5ACA785B,$130456A8,$24B6556A,$AADF1A4D,$DC52B9A2,$8CA64462,$F80377A9,$E4057654,
$150C09B9,$064AEFC4,$4158F078,$3702B2A4,$2D450AC7,$0D93CC98,$09C44199,$2E22F1BA,
$2A710B76,$0224E714,$C5F15ACE,$1429F62A,$0CB062CF,$C84E1665,$F62EE50A,$C292F021,
$71B95437,$64D24F30,$CE4A1DB2,$94108B04,$0B5164C6,$503C0284,$0F88CC8C,$35C63184,
$E0089235,$0CBEBFD3,$400D34CE,$A26C4AD8,$4B0C398C,$18CE9CCC,$445AE379,$ED60A4A6,
$8E0686E0,$D1282729,$33E9A890,$4E714030,$C17E3195,$3AB712A1,$CF054216,$90085DC0,
$76D785DF,$B6522930,$25661992,$D9389162,$175CCCDA,$197C4203,$2D04D630,$01CE850C,
$D6B485CE,$5700E362,$F9163114,$491055ED,$728825E5,$9220D0D6,$9EB48824,$80DE0F3C,
$21F24B5C,$A7108EB7,$65FAD539,$40EC31A2,$F12C0A40,$19551C18,$3AA0A442,$84AA6221,
$D923A44B,$F2511C40,$BAA0A730,$11571780,$6800FA8A,$726AB3C8,$870B3854,$1DB44A34,
$480A99C9,$48A6D88F,$9263581E,$26A08D56,$0D40C8C8,$4A21FDDC,$144E32AA,$6E28CA8F,
$12A0223A,$82803CAC,$0E14E641,$928605B0,$79F81E22,$C520637E,$30E3235C,$8C4426D9,
$02D7802A,$2878EA02,$DB2CD866,$B0AAA5F3,$44E51A62,$3E801239,$A95E1058,$9A48A536,
$2AC6E116,$8DC0E094,$4A04E162,$F918220E,$30A122C0,$473DC490,$21AA2559,$182C229D,
$27295C30,$3A96AC02,$B6961941,$0A8B8446,$4C06A4A6,$5BDB0DCF,$03E11B90,$1D1C9A00,
$88762295,$8230C53C,$AA004525,$C2B7C632,$7314E88C,$87EA73C0,$707921B6,$8152E2EC,
$0EE480F2,$471C241E,$999968DA,$09661606,$43ECD601,$496B026A,$16FADB13,$51DD1908,
$7898B432,$062C0818,$7029B700,$D2772BC2,$D9909109,$116E054E,$4E6A2AD2,$6254F090,
$B06011A8,$40BA56AC,$5B064C18,$04D33894,$2B983F32,$71800C00,$C2A9C5C2,$23F5644A,
$0514C938,$AB165463,$B100684C,$5966E067,$859AC961,$B2524F94,$EA2867AC,$8230A0E8,
$831431A6,$8890B8CB,$BCD4FD11,$25856892,$B10C3010,$7878026A,$05044A82,$A4341B53,
$01184ED9,$E80201F2,$638C8721,$A42A2677,$35172456,$7AA07182,$17D551CC,$29E63940,
$85E01585,$9A0B20B2,$C4AA4AA8,$22826B5D,$A821CC3A,$71196C3A,$07400342,$8B690F01,
$0649B08A,$916402E0,$A8332EBC,$62E58844,$ACF2B460,$55011557,$94540CB4,$97D8038E,
$561502AB,$9B64E064,$887832F8,$6E9140B6,$3876109C,$3F58ECA5,$109C882B,$9A6F722C,
$C06A9072,$43253970,$2491281A,$E1460919,$544BC002,$B7061094,$07049633,$09001FCC,
$E2DEA842,$41E6C4A9,$27F413AA,$020E9400,$48DC5D03,$1660F9C1,$9C295C44,$19684A34,
$DE029805,$4C501584,$28923AD3,$6522D00D,$B36288B0,$BE006C40,$93A00A34,$0D92C300,
$82A0743A,$840CA68E,$08E99782,$C8E81635,$D80CE313,$21225342,$30360860,$4444177A,
$C9A17AA2,$B70014D1,$E2A55515,$B6071D84,$63428945,$A08680F3,$436505A2,$260C1494,
$5F248E52,$8C98A1D8,$D70C00E9,$08ADA1E9,$2BACC850,$E3903B09,$B0519813,$6C99CC38,
$2A00CF04,$4E48970D,$1294A738,$2C2C09DC,$434F5A67,$50D60710,$C454698B,$BC0F2940,
$48448610,$32AA0272,$058CC526,$3388059A,$185289E1,$DF4217A1,$68A3A3C4,$E1684C36,
$A2D2A620,$138A4AC2,$1442CC19,$0B9215D5,$00EE0146,$AC968062,$5141641B,$23445256,
$BB10338C,$65D46058,$85834D30,$8628628D,$086108CB,$433DDC22,$615804C6,$9271F0E2,
$58290D50,$020A64A8,$5C4B4A62,$6F0871EC,$11D2399C,$8B483C0D,$46434460,$678291A5,
$EC0A2270,$1F9080A8,$9092048A,$B6A502A2,$8813955C,$8E84ABF6,$2606A227,$A4C8A9D4,
$2120E2C1,$E9389968,$16882EAC,$130E5583,$71123E1D,$E03C352E,$68E44A64,$046D5196,
$A0516A32,$B130C130,$5B952CC0,$45686F42,$2118614C,$388D0AF3,$0085D6E2,$D34CE04B,
$A8B040C6,$9563044C,$0100C54A,$52629EE0,$4D556C2E,$A86AC915,$CB55D800,$E4190E5C,
$61E4DC08,$20994B31,$528A0288,$1DD01A64,$D03406AD,$29159062,$54980B12,$86DAF400,
$51371A88,$AA7AC280,$901A6280,$18804D24,$CA6C0D0A,$996E1070,$BADC21D8,$0414A91A,
$2881514C,$5361A794,$75843E84,$186B8804,$EB603108,$725622A0,$252A130C,$CA1A8286,
$4180F605,$C204694D,$B3A30302,$38628E5A,$5ED11A8D,$4A6DC6B0,$805A23AA,$63508425,
$93844518,$4C640D41,$33031805,$565008A8,$0288703B,$D180C991,$9A089386,$14E68523,
$28D1091F,$AD529818,$00020881,$00000000,$00000000,$00000000,$00000000
     );


  VAR  {AP: ARRAY[BYTE] OF PRISET;}
       ap4: array[1..SUCC(dword(65536+209) div 210)] of p48 ABSOLUTE ARL;

  VAR
       ind,  {IN P48                GLOBAL VARIABLES}
       qrt,  { SQRT OF NUMBER TO TEST}
       SIB,  {IN I48  I38}
       base, { IND * 210}
       psbl: word; {POSIBLE CANDIDATE}
       FINDNEXT: POINTER;

  CONSTRUCTOR BITS.CREATE(MAXBIT: WORD);
  VAR TEMP: DWORD;
  BEGIN
    TEMP    := MAXBIT; {BITS}
    IF (MAXBIT AND 7) <> 0 THEN BEGIN
      TEMP    :=  MAXBIT OR 7; INC(TEMP);
    END;
    FSIZE   := TEMP SHR 3;  {BYTES}
    MYGETMEM(POINTER(FBITPTR),FSIZE);
    FMAXBIT := MAXBIT;
  END;

  CONSTRUCTOR BITS.VIEW(ADR: POINTER; MAXBIT: WORD);
  BEGIN
    FSIZE   := 0;
    FBITPTR := ADR;
    FMAXBIT := MAXBIT;
  END;

  DESTRUCTOR BITS.DONE;
  BEGIN
    IF FSIZE <> 0 THEN FREEMEM(FBITPTR,FSIZE);
  END;


  PROCEDURE BITS.EXCL(P: WORD);
  BEGIN
    IF P <= FMAXBIT THEN
    WITH WORDREC(P) DO  FBITPTR^[HI] := FBITPTR^[HI] - [LO];
  END;

  FUNCTION BITS.INSET(P: WORD): BOOLEAN;
  BEGIN
    IF P <= FMAXBIT THEN BEGIN
      WITH WORDREC(P) DO  INSET := LO IN FBITPTR^[HI];
    END ELSE INSET := FALSE;
  END;

  PROCEDURE BITS.INCL(P: WORD);
  BEGIN
    IF P <= FMAXBIT THEN  WITH WORDREC(P) DO
      FBITPTR^[HI] := FBITPTR^[HI] + [LO];
  END;

  PROCEDURE BITS.ERATO;
    VAR I, J, S, LAST: WORD;
    BEGIN
      FOR I := 0 TO 255 DO INCL(I);
      FOR I := 1 TO 255 DO FBITPTR^[I] := FBITPTR^[0];
      EXCL(0); EXCL(1);

      FOR I := 2 TO 255 DO BEGIN
        IF INSET(I) THEN BEGIN
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

  PROCEDURE BITS.PRINT;
    VAR I, C: WORD;
  BEGIN
    C := 0;
    FOR I := 0 TO FMAXBIT DO
      IF INSET(I) THEN BEGIN
        INC(C);
        IF C MOD 10 = 0
          THEN WRITELN(I)
          ELSE WRITE(I,' ');
      END;
    WRITELN;
  END;

  PROCEDURE BITS.SETBITS(FROMBIT, TOBIT: WORD; STATE: BOOLEAN);
  VAR I, FBYTE, TBYTE: WORD; RES : DWORD;
  begin RES := SUCC(TOBIT); DEC(RES,FROMBIT);
    IF  RES <= 0 THEN EXIT;
    IF STATE
      THEN for i := FROMBIT to TOBIT do INCL(i)
      ELSE for i := FROMBIT to TOBIT do EXCL(i);
  end;

  PROCEDURE BITS.INVERTBITS(FROMBIT, TOBIT: WORD);
  VAR I, FBYTE, TBYTE: WORD; RES : DWORD;
  begin RES := SUCC(TOBIT); DEC(RES,FROMBIT);
    IF  RES <= 0 THEN EXIT;
    for i := FROMBIT to TOBIT do
      if INSET(i)
        then EXCL(i)
        else INCL(i);
  end;

  function mymod(n: dword; m: word): word;
  begin
    mymod := divmod(n,m);
  end;

  function usqr(a: word): dword;
  begin usqr := mul(a,a);
  end;


  {$F+}
  FUNCTION LONG_NEXT: BOOLEAN;
  VAR T: DWORD;
  BEGIN
    REPEAT
      T := BASE;  INC(T,i48[SIB]);
      IF (T > QRT)
        THEN BEGIN LONG_NEXT := FALSE; EXIT; END;
      INC(SIB);
      if SIB = 48 then begin SIB:= 0; inc(ind); inc(base,210); end;
      PSBL := T;
    UNTIL SIB IN AP4[IND];
    LONG_NEXT := TRUE;
  END;

  FUNCTION SHORT_NEXT: BOOLEAN;
  BEGIN  INC(SIB);
    PSBL := I38[SIB];
    IF SIB = 37 THEN BEGIN INC(IND); SIB := 47; FINDNEXT := @LONG_NEXT; END;
    SHORT_NEXT := PSBL <= QRT;
  END;

  {$F-}

  function isPrime(n: longint): boolean;
  begin  isPrime := false;
    if (n < 256) then  begin  isPrime := n in p256; exit; END;
    if not (mymod(n,210) in pm210) then exit; {2, 3, 5, 7}
    if     mymod(n,209)  in pm209  then exit; {11, 19}
    if     mymod(n,221)  in pm221  then exit; {13, 17}
    if n < 19*19 then begin isPrime := true; exit; end;
    qrt := sqrl(n);
    if usqr(qrt) = n then exit;
    SIB := prtop; BASE := 0; IND := PRTOP;
    FINDNEXT := @SHORT_NEXT;
    WHILE TCANDI(FINDNEXT) DO BEGIN
      IF MYMOD(N,PSBL) = 0 THEN EXIT;
    END;
    isPrime := true;
  end;

  PROCEDURE PrimesIn(n1, n2: longint);
  var count: word;
  BEGIN writeln;  count := 0;
    while n1 <= n2 do begin
      if isPrime(n1) then begin write(n1,' '); inc(count); end;
      inc(n1);
    end;
    writeln;
    writeln(count);
  END;

  PROCEDURE PrimesCnt(n: longint; cnt: word);
  var count: word;
  BEGIN writeln;  count := 0;
    repeat
      if isPrime(n) then begin write(n);
        inc(count);

        if (count mod  7) = 0 then writeln else write(' ');
      end;
      inc(n);
    until (n = 0) or (cnt = 0);
    writeln;
    writeln(count);
  END;

  begin
  end.

  {^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}

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
      {if inpr(t)
        then  ap4[ind] := ap4[ind] + [SIB];
        }
    until false;
    {DUMP(@AP4,SIZEOF(AP4) DIV SIZEOF(POINTER));}
    writeln(SIZEOF(AP4));
    writeln(ind,' ',ind*210,' ',t, ' ',SIB,' ',I48[SIB]);
  end;

  PROCEDURE CONVERT_TEST;
  BEGIN
  END;

    erato;
    convert;
    show(pm210);
    {CONVERT_TEST;
    show(p256-[0..22,210..255]);
    show(pM210-[0..22,210..255]);}

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

