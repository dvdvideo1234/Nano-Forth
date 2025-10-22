unit c4thlib;

interface

uses baselib, FILIB, strLib, hashlib;

  type
    tstack= object
      fdata: ppary;
      fedge: word;    {after last element of stack}
      fstkp: word;
      constructor create(sz: word); {in elements}
      destructor  done;
      procedure reset;                    virtual;
      function  push(L: dword): boolean;
      function  pop:  longint;
      function  depth:  word;
    end;

    tFileStack= object(tstack)
      procedure reset;                    virtual;
      function  add(name: string): BOOLEAN;
      function  top: ptext;
    end;


    ptc4th = ^tc4th;
    tc4th = object
      fcomph: hash;
      finteh: hash;
      ffwdbr,         {count of branches forward & backward}
      fbwdbr,
      fstack: tstack;
      ftxtst: tfileStack;
      fstate: pointer;
      fmem  : parbyte;
      fsize : word;
      fhp   : word;   {pointer in compiler memory == here pointer}
      fToken: str85;    {last token}
      FPARAM: STR85;
      fLine:  string;   {last line  when in main loop}
      fls:    longstr;  {current position in text buffer}
      fprpnt: tprgPnt;
      fSAVEP: word;
      FDEBUG: BOOLEAN;

      constructor create(stksz, fbsz, sz: word);
      destructor  done;
      procedure   forth(FNAME: STRING);  {main loop}

      {compiler intro}
      procedure   eval(p: pchar; l: word);
      procedure   getToken(chk: boolean);
      function    getParam(chk: boolean): string;
      procedure   macro(s: string);
      procedure   error(cond: boolean; s: string);
      FUNCTION    FIND(AWORD: STR85): PEL;
      PROCEDURE   FIX(AWORD: STR85; W: WORD);
      function    strcomp: boolean;
      function    execute(p: pel): boolean;
      function    compile(p: pel): boolean;
      procedure   getNum;
      procedure   compNum;
      procedure   IntSearch;
      procedure   compSearch;
      procedure   drop2(var d1, d2: dword);
      FUNCTION    MEMADR(A: WORD): POINTER;
      procedure   push(L: dword);
      function    pop: dword;
      procedure   STRCOMMA(STR: STRING);

      {common commands}
      procedure   bye;
      procedure   toInter;
      procedure   toComp;
      procedure   align;
      procedure   comma;
      procedure   bcomma;
      PROCEDURE   reMARK;
      procedure   ALLOT;
      procedure   SAVE;
      procedure   UNLINKED;
      procedure   TRON;
      procedure   TROFF;
      procedure   DEBUG;

      {create commands}
      procedure   Colon;
      procedure   Semi;
      procedure   newDEA; {dictionary equ here address}
      procedure   equColon; {dictionary established address}
      PROCEDURE   MAC2VAR; {CREATE VAR VALUE ...}
      PROCEDURE   MACDEF; {IF REPEAT UNTIL ...}

      {compiling control commands}
      PROCEDURE   FWDMARK;
      PROCEDURE   BWDMARK;
      PROCEDURE   FWDRELS;
      PROCEDURE   BWDRELS;
      PROCEDURE   BWDswap;
      PROCEDURE   FWDswap;
      {PROCEDURE   MCOLON;   USED BY MAC2VAR}

      {interpretter commands}
      procedure   here;
      procedure   Locate;
      procedure   dup;      {stack}
      procedure   drop;
      procedure   swap;
      procedure   over;
      PROCEDURE   STOREW;   {memory}
      PROCEDURE   STOREB;
      PROCEDURE   FETCHW;
      PROCEDURE   FETCHB;
      procedure   include;
      procedure   plus;     {math & logic}
      procedure   minus;
      procedure   orw;
      procedure   xorw;
      procedure   andw;
      procedure   notw;
      procedure   negw;
      procedure   dot;      {io }
      procedure   Hdot;
      procedure   cr;
    end;

implementation

{-------------------------------------------}

  constructor tstack.create(sz: word);
  begin
      fstkp:= sz;  {empty stack ON START}
      fedge:= sz;
      getmem(fdata,sz * SIZEOF(POINTER));
  end;

  destructor tstack.done;
  begin
      reset;
      freemem(fdata,fedge * SIZEOF(POINTER));
  end;

  procedure tstack.reset;
  begin
    fstkp := fedge;
  end;

  function tstack.push(L: dword): boolean;
  begin push := fstkp <> 0;
    if fstkp = 0 then exit;
    dec(fstkp);
    fdata^[fstkp] := pointer(l);
  end;

  function  tstack.pop: longint;
  begin
    if fstkp = fedge then begin pop := -1; exit; end;
    pop := dword(fdata^[fstkp]);
    inc(fstkp);
  end;

  function  tstack.depth:  word;
  begin
    depth := fedge - fstkp ;
  end;

{-------------------------------------------}

  procedure tFileStack.reset;
  var fptr: pTEXT;
  begin
    while depth > 0 do begin
      fptr := PTEXT(pointer(pop));
      close(fptr^);
      DISPOSE(fptr);
    end;
  end;

  function  tFileStack.add(name: string): BOOLEAN;
  var fptr: ptext; ok:  boolean;
  begin
    fptr := new(ptext);
    ok := OPENTEXT(NAME,FPTR^, FALSE);
    ADD := OK;
    IF NOT OK THEN BEGIN DISPOSE(FPTR); EXIT; END;
    push(longint(fptr));
  end;

  function tFileStack.top: ptext;
  begin top := nil; if depth = 0 then exit;
    top :=  fdata^[fstkp];
  end;

{-------------------------------------------}

  constructor tc4th.create(stksz, fbsz, sz: word);
  begin
    fcomph.create(101,@h32h);     {hashes}
    finteh.create(101,@h32h);

    fstack.create(stksz);  {stecks}
    ffwdbr.create(fbsz);
    fbwdbr.create(fbsz);
    ftxtst.create(8);

    getmem(fmem,sz);         {memory}
    fsize := sz;
    fhp := 0;
  end;

  destructor  tc4th.done;
  begin
    fcomph.done;
    finteh.done;
    fstack.done;
    ftxtst.done;
    ffwdbr.done;
    fbwdbr.done;
    freeMem(fmem,fsize);
  end;

  procedure   tc4th.toInter;  begin fstate := @tc4th.IntSearch;  end;

  procedure   tc4th.toComp;  begin fstate := @tc4th.compSearch;  end;

  procedure tc4th.Colon; begin newDEA;toComp;macro('(:'); end;

  procedure   tc4th.Semi; begin macro('(;');
    if (ffwdbr.depth or fbwdbr.depth) = 0 then toInter;
  end;

  procedure   tc4th.equColon; { =: dictionary established address}
  var p: pel; OLD: DWORD; D, ADR: WORD;
  begin getToken(true);
    p :=  fcomph.search(ftoken);
    IF P<> NIL THEN WITH P^ DO BEGIN
      ERROR(FTYPE<>1, 'ILLEGAL TYPE');
      OLD := DWORD(FVALUE);
      error(LONGREC(OLD).HI = 0,'duplicated');
      D := POP; ADR := LONGREC(OLD).LO;
      WHILE ADR <> 0 DO BEGIN OLD := PWORD(MEMADR(ADR))^;
        PWORD(MEMADR(ADR))^ := D; ADR := OLD;
      END;
      DWORD(FVALUE) := D;
      EXIT;
    END;
    fcomph.addNum(ftoken,pop);
  end;

  procedure   tc4th.newDEA;
  begin here; equColon; {=h}
  end;

  procedure   tc4th.compNum;  begin
    getnum;
    macro('(#'); comma;   {compile literal}
  end;

  procedure   tc4th.eval(p: pchar; l: word);
  var ls: longstr;
  begin  ls := fls; setLstr(fls,p,l);
    repeat getToken(false);
      if ftoken <> ''
        then perform(@self,fstate);
      DEBUG;
    until (fls.rem = 0);
    fls := ls;
  end;

  procedure   tc4th.macro(s: string);
  begin eval(@s[1],byte(s[0])); end;

  procedure   tc4th.DEBUG;
  VAR I: WORD;
  begin
    IF NOT FDEBUG THEN EXIT;
    WITH FLS DO WRITE(MKSTR(CP^,REM),' "',FTOKEN,'"');
    I := FSTACK.DEPTH;
    IF I <> 0 THEN BEGIN WRITELN;
      WRITE('STK: '); IF I > 6 THEN I := 6;
      WITH FSTACK DO WHILE I > 0 DO BEGIN DEC(I);
        WRITE(DWORD(FDATA^[I+FSTKP]),' '); END;
    END;
    READLN;
  end;

  function    tc4th.compile(p: pel): boolean;
  VAR OLD: DWORD; ADR: WORD;
  begin COMPILE := FALSE;
    if (p = nil) OR (P^.FTYPE <> 1) then  exit;
    OLD := dword(p^.fvalue);
    ADR := FHP;
    push(OLD); comma;
    IF LONGREC(OLD).HI <> 0 THEN LONGREC(P^.FVALUE).LO := ADR;
    COMPILE := TRUE;
  end;

  function   tc4th.execute(p: pel): boolean;
  var fi: boolean; kp: pstr;
  begin
    if (p = nil) OR (P^.FTYPE=1)
      then BEGIN execute := FALSE; exit; END;
    with p^ do case ftype of
      0:  perform(@self,fvalue);
      2:  begin kp := @ft1; fi := kp^[ft1] <> '`';
            if fi then tocomp;
            macro(pstr(fvalue)^);
            if fi then begin
              tointer;  {PROCEDURE   TC4TH.MCOLON;}
              GETTOKEN(TRUE); HERE; PUSH(2); MINUS; EQUCOLON; COMMA;
            end;
          end;
    end;
    EXECUTE := TRUE;
  end;

  procedure   tc4th.here;
  begin
    push(fhp + $100);
  end;

  procedure   tc4th.IntSearch;
  var p: pel; len: word;
  begin
    p := finteh.search(fToken);
    if execute(p)    {if found}
      then exit;
    if strcomp
      then exit;
    getnum;
  end;

  procedure   tc4th.compSearch;
  var p: pel;
  begin ftoken := ftoken + '`';
    p := fcomph.search(fToken);
    dec(byte(ftoken[0]));
    if execute(p)    {if found}
      then  exit;
    p := fcomph.search(fToken);
    if compile(p)    {if found}
      then exit;
    compNum;
  end;

  PROCEDURE   tc4th.FIX(AWORD: STR85; W: WORD);
  var p: pel; D: DWORD;
  BEGIN P := FIND(AWORD); D := DWORD(P^.FVALUE);
    ERROR(LONGREC(D).HI <> 0, 'NOT DEFINED YET');
    PWORD(MEMADR(D+2))^ := W;
  END;

  FUNCTION    tc4th.FIND(AWORD: STR85): PEL;
  var p: pel;
  BEGIN FTOKEN := AWORD;  {ZARADI ERROR}
    p := fcomph.search(AWORD);
    error((p = nil) OR (P^.FTYPE<>1), 'not found');
    FIND := P;
  END;

  procedure   tc4th.Locate;
  begin getToken(true); push(dword(FIND(FTOKEN)^.fvalue));  end;

  procedure   tc4th.bye;
  begin
    writeln;
    writeln('Shutting down');
    done;
    halt;
  end;

  procedure   tc4th.error(cond: boolean; s: string);
  begin if not cond then exit;
    writeln;
    writeln(ftoken,':  ',s);
    gotoPoint(fprpnt);
  end;


  procedure   tc4th.forth(FNAME: STRING);
  begin  {initialization of interpretter dictionary}
    WITH finteh DO BEGIN
      add('\'      ,@TC4TH.reMARK);
      add('BYE'    ,@tc4th.bye);
      add('>,'     ,@tc4th.toComp);
      add(':'      ,@tc4th.Colon);
      add('C,'     ,@tc4th.bcomma);
      add(','      ,@tc4th.comma);
      add('=:'     ,@tc4th.equColon);
      add('=H'     ,@tc4th.newDEA);
      add('HERE'   ,@tc4th.here);
      add(''''     ,@tc4th.Locate);
      add('ALIGN'  ,@tc4th.align);
      add('DUP'    ,@tc4th.dup);
      add('DROP'   ,@tc4th.drop);
      add('SWAP'   ,@tc4th.swap);
      add('OVER'   ,@tc4th.over);
      add('+'      ,@tc4th.plus);
      add('-'      ,@tc4th.minus);
      add('OR'     ,@tc4th.orw);
      add('XOR'    ,@tc4th.xorw);
      add('AND'    ,@tc4th.andw);
      add('NOT'    ,@tc4th.notw);
      add('NEG'    ,@tc4th.negw);
      add('.'      ,@tc4th.dot);
      add('H.'     ,@tc4th.Hdot);
      add('CR'     ,@tc4th.cr);
      add('!'      ,@tc4th.STOREW);
      add('C!'     ,@tc4th.STOREB);
      add('@'      ,@tc4th.FETCHW);
      add('C@'     ,@tc4th.FETCHB);
      add('INCLUDE',@TC4TH.include);
      add('ALLOT'  ,@TC4TH.ALLOT);
      add('SAVE'   ,@TC4TH.SAVE);
      add('TRON'   ,@TC4TH.TRON);
      add('TROFF'  ,@TC4TH.TROFF);
      add('=!'     ,@TC4TH.UNLINKED);
      add('V:'     ,@TC4TH.MAC2VAR);
      add('M:'     ,@TC4TH.MACDEF);
    END;


         {initialization of compiler dictionary}
    WITH fCOMPh DO BEGIN
      add(';`'     ,@tc4th.Semi);
      add('\`'     ,@TC4TH.reMARK);
      add('<CSWAP`',@TC4TH.BWDswap);
      add('CSWAP>`',@TC4TH.FWDswap);
      add(',<`'    ,@tc4th.toInter);
      add(':`'     ,@tc4th.Colon); {COMPILE VERSION}
      add('MARK>`' ,@tc4th.FWDMARK);
      add('BEGIN`' ,@tc4th.BWDMARK);
      add('THEN`'  ,@tc4th.FWDRELS);
      add('RELS>`' ,@tc4th.BWDRELS);
    END;

    savePoint(fprpnt); {program state reset point - on error}

    toInter;     {interpretter}
    ftxtst.reset; {close all open files}
    fstack.reset; {}
    ffwdbr.reset;
    fbwdbr.reset;

    writeln;

    IF FNAME <> '' THEN
      BEGIN fline := FNAME; TRON; FNAME := ''; macro(fline); END;
    TROFF;

    repeat
      write('=> ');
      readln(fline);
      macro(fline);
      write(' Ok');
      writeln;
    until false;
  end;


  procedure   tc4th.align;
  VAR NUM: BYTE;
  begin NUM := POP;
    IF NOT (NUM IN [0,2,4,8,16,32,64,128])
      THEN EXIT;
    DEC(NUM);
    IF (FHP AND NUM) = 0
      THEN EXIT;
      {ON OTHER VERSIONS HERE MUST BE SOMETHING}
    STRCOMMA(MKSTROF(#0, SUCC(FHP OR NUM) - FHP));
  end;

  procedure tc4th.STRCOMMA(STR: STRING);
  begin
    move(STR[1],fmem^[fhp],byte(STR[0]));
    inc(fhp,byte(STR[0]));
  end;

  function  tc4th.getParam(chk: boolean): string;
  begin getParam := fparam;
    if chk then error(fparam='','string parametter expected');
    fparam := '';
  end;

  procedure tc4th.getToken(chk: boolean);
  begin
    Ftoken := lextract(fls);
    if chk then error(fToken = '', 'empty token');
  end;

  function tc4th.strcomp: boolean;
  var temp: string; cmd: char;
  begin temp := TokenPACK(ftoken,cmd);
    strcomp := cmd <> #0; if cmd = #0 then exit;
    case cmd of
      ',':  STRCOMMA(temp);
      '.':  write(temp);
      '"':  FPARAM := temp;
      '?': push(pos(char(pop),temp));
      '!': begin ftoken := ''; error(true, temp); end;
    end;
  end;

  procedure   tc4th.getnum;
  var dd: dword; err: word;
  begin
    ATOI(ftoken, dd, err);
    error(err <> 0 , 'not a number');
    push(dd);
  end;

  function    tc4th.pop: dword;   begin
    ERROR(FSTACK.DEPTH=0,'EMPTY STACK'); pop := fstack.pop; end;

  procedure   tc4th.push(L: dword);  begin
    ERROR(FSTACK.FSTKP=0,'STACK FULL');  fstack.push(l);  end;

  procedure   tc4th.dup;  var dd: dword;
  begin dd := pop; push(dd);  push(dd);  end;

  procedure   tc4th.drop;  begin   pop;  end;

  procedure   tc4th.swap;  var d1, d2: dword;
  begin drop2(d1, d2); push(d1); push(d2);  end;

  procedure   tc4th.over;  var d1, d2: dword;
  begin drop2(d1, d2); push(d2); push(d1); push(d2);  end;

  procedure   tc4th.drop2(var d1, d2: dword);
  begin d1 := pop; d2 := pop ;   end;

  procedure   tc4th.plus;  var d1, d2: dword;
  begin drop2(d1, d2); push(d2+d1);  end;

  procedure   tc4th.minus;  var d1, d2: dword;
  begin drop2(d1, d2); push(d2-d1);  end;

  procedure   tc4th.orw;  var d1, d2: dword;
  begin drop2(d1, d2); push(d2 or d1);  end;

  procedure   tc4th.xorw;  var d1, d2: dword;
  begin drop2(d1, d2); push(d2 xor d1);  end;

  procedure   tc4th.andw; var d1, d2: dword;
  begin drop2(d1, d2); push(d2 and d1);  end;

  procedure   tc4th.notw;  begin push(not pop); end;

  procedure   tc4th.negw;  begin push(- pop); end;

  procedure   tc4th.dot; begin write(ntostr(pop)+' '); end;

  procedure   tc4th.Hdot; begin write(ItoA(pop,16)+' '); end;

  procedure   tc4th.cr; begin writeln; end;

  {----------------COMPILER--------------------}

  PROCEDURE   TC4TH.FWDMARK;  BEGIN
    error( not fFwdBr.PUSH(FHP), 'fwd stack full'); PUSH(0); COMMA;  END;

  PROCEDURE   TC4TH.BWDMARK;  BEGIN HERE;
    error(not fBwdBr.PUSH(POP),'bwd stack full');  END;

  PROCEDURE   TC4TH.FWDRELS;  var fwd: dword; BEGIN HERE; fwd := fFwdBr.POP;
    error(fwd=-1, 'fwd stack empty');  PUSH(fwd); STOREW;  END;

  PROCEDURE   TC4TH.BWDRELS; var bwd: dword; BEGIN bwd := fBwdBr.POP;
    error(bwd=-1, 'bwd stack empty');  PUSH(bwd); COMMA;  END;

  PROCEDURE   TC4TH.STOREW;  var d1, d2: dword;
  BEGIN DROP2(D1,D2);  PWORD(MEMADR(D1))^ := D2;  END;

  PROCEDURE   TC4TH.STOREB;  var d1, d2: dword;
  BEGIN DROP2(D1,D2);  PBYTE(MEMADR(D1))^ := D2;  END;

  FUNCTION    TC4TH.MEMADR(A: WORD): POINTER;
  BEGIN ERROR(A >= FSIZE,'MEMORY RANGE'); MEMADR := @fmem^[A]; END;

  PROCEDURE   TC4TH.FETCHW;  BEGIN PUSH(PWORD(MEMADR(POP))^);  END;

  PROCEDURE   TC4TH.FETCHB;  BEGIN PUSH(PBYTE(MEMADR(POP))^);  END;

  procedure   tc4th.bcomma;  begin PUSH(fhp); STOREB; inc(fhp); end;

  procedure   tc4th.comma; begin PUSH(fhp); STOREW; inc(fhp,2); end;

  PROCEDURE   TC4TH.reMARK;  BEGIN fls.rem := 0; END;

  PROCEDURE   TC4TH.FWDswap;    var f1, f2: dword; BEGIN
    error(fFwdBr.depth < 2, 'fwd stack empty');
    f1 := fFwdBr.POP;  f2 := fFwdBr.POP;  fFwdBr.Push(f1);
    fFwdBr.Push(f2);    END;

  PROCEDURE   TC4TH.BWDswap;    var b1, b2: dword; BEGIN
    error(fbwdBr.depth < 2, 'bwd stack empty');
    b1 := fbwdBr.POP;  b2 := fbwdBr.POP;  fbwdBr.Push(b1);
    fbwdBr.Push(b2);
  END;

  procedure TC4TH.include;
  VAR ALINE: STR85;
  begin
    WITH ftxtst DO BEGIN ERROR(FSTKP=0, 'TOO MANY OPEN FILES');
      ERROR(NOT ADD(FPARAM), 'CAN''T OPEN FILE "'+FPARAM+'"');
      REMARK; FPARAM := ''; {SKIP REMAINING TOKEMS IN CALLING LINE}
      WHILE NOT EOF(TOP^) DO BEGIN READLN(TOP^,ALINE);  MACRO(ALINE); END;
    CLOSE(TOP^); END;
  end;

  PROCEDURE   TC4TH.MACDEF;  {DEFINE CONTROLS USED IN COMP MODE}
  var par: str85;
  BEGIN GETTOKEN(TRUE); par := getParam(true);
    fcomph.addstr(ftoken + '`', Par);  END;

  PROCEDURE   TC4TH.MAC2VAR; {DEFINE DEFINERS ON INTERP MODE }
  var par: str85;
  BEGIN GETTOKEN(TRUE); par := getParam(true);
    finteh.addstr(ftoken, par);
  END;

  procedure TC4TH.ALLOT;  BEGIN INC(FHP,POP);  END;

  procedure TC4TH.UNLINKED;  BEGIN PUSH(-65536); EQUCOLON;  END;

  procedure TC4TH.SAVE;
  VAR I: INTEGER; KEY: STR15; P: PEL; HIADR, SIZE, ERR: WORD; D: DWORD;
      FNAME: STR85; FOUT: FILE;    {SPACE FOR VOCABULARY SIZE}
  BEGIN FSAVEP := FHP; INC(FHP,2);     ERR := 0; WRITELN;
    WITH fcomph DO FOR I := FCOUNT-1 DOWNTO 0 DO BEGIN  P := FPELS^[I];
        WHILE P <> NIL DO WITH P^ DO IF FTYPE = 1 THEN BEGIN
          KEY := GETKEY(P)^; D := DWORD(FVALUE); HIADR := LONGREC(D).HI;
          IF HIADR <> 0 THEN BEGIN INC(ERR); WRITE(' =! ',KEY);  END;
          IF NOT ((KEY[1] = '`') OR (HIADR <> 0 )) THEN BEGIN
          STRCOMMA(KEY); PLONG(MEMADR(FHP))^ := D; INC(FHP,4); END;
        P := P^.FNEXT; END;
    END;  WRITELN; WRITELN;  STRCOMMA(#0); PUSH(FHP-2-FSAVEP);
    PUSH(FSAVEP); STOREW; FNAME := GETPARAM(TRUE); SIZE := FHP;
    FHP := FSAVEP;    IF ERR <> 0 THEN EXIT;
    FIX('H',FHP+$100);  ERROR( NOT WRITEbin(FNAME,MEMADR(0)^, SIZE),
      'UNCOMPLETED WRITING A FILE '+FNAME);
  END;

      procedure   TC4TH.TRON;
      BEGIN
        FDEBUG := TRUE;
      END;

      procedure   TC4TH.TROFF;
      BEGIN
        FDEBUG := FALSE;
      END;

begin
end.

