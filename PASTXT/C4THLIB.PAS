unit c4thlib;

interface

uses baselib, strLib, hashlib;

  type
    tstack= object
      fdata: ppary;
      fedge: word;    {after last element of stack}
      fstkp: word;
      fsize: word; {in bytes}
      constructor create(sz: word); {in elements}
      destructor  done;
      procedure error(fe: boolean); {full or empty}
      procedure reset;                    virtual;
      procedure push(l: dword);
      function  pop:  longint;
      function  depth:  word;
    end;

    tFileStack= object(tstack)
      procedure reset;                    virtual;
      procedure add;
      function  top: ptext;
    end;


    ptc4th = ^tc4th;
    tproc4th = procedure ( selfp: ptc4th; method: pointer);
    tc4th = object
      fcomph: nhash;
      finteh: nhash;
      ffwdbr,         {count of branches forward & backward}
      fbwdbr,
      fstack: tstack;
      ftxtst: tfileStack;
      fstate: pointer;
      {fproc : tproc4th;}
      fmem  : parbyte;
      fsize : word;
      fhp   : word;   {pointer in compiler memory == here pointer}
      fToken: str85;    {last token}
      fLine:  string;   {last line}
      fls:    longstr;  {current position in text buffer}
      fprpnt: tprgPnt;
      falign: word;

      constructor create(stksz, fbsz, sz: word);
      destructor  done;
      procedure   forth;
      procedure   bye;

      procedure   toInter;
      procedure   toComp;
      procedure   Colon;
      procedure   Semi;
      procedure   align;
      procedure   comma;
      procedure   eval(p: pchar; l: word);
      procedure   bcomma;
      function    pop: dword;
      procedure   here;
      procedure   push(L: dword);

      procedure   Locate;
      procedure   getToken(chk: boolean);
      procedure   newDEA; {dictionary (enabled) address}
      procedure   equColon; {dictionary established address}
      procedure   macro(s: string);
      procedure   error(cond: boolean; s: string);
      procedure   strcomp;
      procedure   execute(p: pel);
      procedure   compile(p: pel);
      procedure   getNum;
      procedure   compNum;
      procedure   IntSearch;
      procedure   compSearch;

      procedure   dup;
      procedure   drop;
      procedure   swap;
      procedure   over;

      procedure   drop2(var d1, d2: dword);
      procedure   plus;
      procedure   minus;
      procedure   orw;
      procedure   xorw;
      procedure   andw;
      procedure   notw;
      procedure   negw;
      procedure   dot;
      procedure   cr;
    end;

implementation

{-------------------------------------------}

  constructor tstack.create(sz: word);
  begin
      fstkp:= sz;  {empty stack}
      fedge:= sz;
      fsize:= sz * 4; {in bytes}
      getmem(fdata,fsize);
  end;

  destructor tstack.done;
  begin
      reset;
      freemem(fdata,fsize);
      fsize:= 0; {in bytes}
  end;

  procedure tstack.reset;
  begin
    fstkp := fedge;
  end;

  procedure tstack.push(L: dword);
  begin
    if fstkp = 0 then error(true);
    dec(fstkp);
    fdata^[fstkp] := pointer(l);
  end;

  function  tstack.pop: longint;
  begin
    if fstkp = fedge then error(false);
    pop := dword(fdata^[fstkp]);
    inc(fstkp);
  end;

  procedure tstack.error(fe: boolean); {full or empty}
  const msg: array[boolean] of str7 = ('empty','full');
  begin
    writeln('Warning - Stack: ',msg[fe]);
    if fe
      then  fstkp := fedge
      else  fstkp := 0;
  end;

  function  tstack.depth:  word;
  begin
    depth := fedge - fstkp ;
  end;

{-------------------------------------------}

  procedure tFileStack.reset;
  var fptr: pointer;
  begin
    while depth > 0 do begin
      fptr := pointer(pop);
      close(ptext(fptr)^);
      freeMem(fptr,sizeof(text));
    end;
  end;

  procedure tFileStack.add;
  var fptr: ptext;
  begin
    fptr := new(ptext);
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
    fstate:= @tc4th.toInter;
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

  procedure   tc4th.bcomma; begin fmem^[fhp] := pop; inc(fhp); end;

  procedure   tc4th.comma;  var p: pword;
  begin p := @fmem^[fhp]; p^ := pop; inc(fhp,2); end;

  function    tc4th.pop: dword;   begin pop := fstack.pop; end;

  procedure   tc4th.push(L: dword);  begin fstack.push(l);  end;

  procedure   tc4th.equColon; { =: dictionary established address}
  var p: pel;
  begin getToken(true);
    p :=  fcomph.search(ftoken);
    error(p <> nil,'duplicated');
    fcomph.add(ftoken,pop);
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
    until (fls.rem = 0);
    fls := ls;
  end;

  procedure   tc4th.macro(s: string);
  begin eval(@s[1],byte(s[0])); end;

  procedure   tc4th.compile(p: pel);
  begin push(pnumel(p)^.tnum); comma;  end;

  procedure   tc4th.execute(p: pel);
  var q: pointer;
  begin q := pointer(pnumel(p)^.tnum); perform(@self,q);  end;

  procedure   tc4th.here;
  begin
    push(fhp + $100);
  end;

  procedure   tc4th.IntSearch;
  var p: pel; len: word;
  begin
    p := finteh.search(fToken);
    if p <> nil then begin
      execute(p);
      exit;
    end;
    len := length(ftoken);
    if (len > 3) and (ftoken[len] = '"') and
       (ftoken[1] in [',','.','!']) and (ftoken[2] = '"') then begin
       strcomp;
      exit;
    end;
    getnum;
  end;

  procedure   tc4th.compSearch;
  var p: pel;
  begin ftoken := ftoken + '`';
    p := fcomph.search(fToken);
    dec(byte(ftoken[0]));
    if p <> nil then begin
      execute(p);
      exit;
    end;
    p := fcomph.search(fToken);
    if p <> nil then begin
      compile(p);
      exit;
    end;
    compNum;
  end;

  procedure   tc4th.Locate;
  var p: pel;
  begin getToken(true);
    p := fcomph.search(fToken);
    error(p = nil, 'not found');
    push(pnumel(p)^.tnum);
  end;

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
    writeln(ftoken,' ',s);
    gotoPoint(fprpnt);
  end;


  procedure   tc4th.forth;
  begin  {initialization of interpretter dictionary}
    WITH finteh DO BEGIN
      add('BYE'    ,DWORD(@tc4th.bye));
      add('>,'     ,DWORD(@tc4th.toComp));
      add(':'      ,DWORD(@tc4th.Colon));
      add(';`'     ,DWORD(@tc4th.Semi));
      add('C,'     ,DWORD(@tc4th.bcomma));
      add(','      ,DWORD(@tc4th.comma));
      add('=:'     ,DWORD(@tc4th.equColon));
      add('=H'     ,DWORD(@tc4th.newDEA));
      add('HERE'   ,DWORD(@tc4th.here));
      add(''''     ,DWORD(@tc4th.Locate));
      add('ALIGN'  ,DWORD(@tc4th.align));
      add('DUP'    ,DWORD(@tc4th.dup));
      add('DROP'   ,DWORD(@tc4th.drop));
      add('SWAP'   ,DWORD(@tc4th.swap));
      add('OVER'   ,DWORD(@tc4th.over));
      add('+'      ,DWORD(@tc4th.plus));
      add('-'      ,DWORD(@tc4th.minus));
      add('OR'     ,DWORD(@tc4th.orw));
      add('XOR'    ,DWORD(@tc4th.xorw));
      add('AND'    ,DWORD(@tc4th.andw));
      add('NOT'    ,DWORD(@tc4th.notw));
      add('NEG'    ,DWORD(@tc4th.negw));
      add('.'      ,DWORD(@tc4th.dot));
      add('CR'     ,DWORD(@tc4th.cr));
    END;

         {initialization of compiler dictionary}
    WITH fCOMPh DO BEGIN
      add(',<`',DWORD(@tc4th.toInter));
      add(':`',DWORD(@tc4th.Colon)); {COMPILE VERSION}
    END;

    savePoint(fprpnt); {program state reset point - on error}

    ftxtst.reset; {close all open files}
    fstack.reset; {}
    ffwdbr.reset;
    fbwdbr.reset;

    writeln;
    repeat
      write('=> ');
      readln(fline); macro(fline);
      writeln(' Ok');
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
    FHP := SUCC(FHP OR NUM);
  end;

  procedure tc4th.getToken(chk: boolean);
  begin
    Ftoken := lextract(fls);
    if not chk then exit;
    error(fToken = '', 'empty token');
  end;

  procedure   tc4th.strcomp;
  var temp: string; cmd, endc: char;
  begin temp := ftoken; dec(temp[0]); cmd := temp[1];
    repeat endc := temp[1]; delete(temp,1,1);   until endc = '"';
    temp := strpack(temp);
    case cmd of
      ',':  begin move(temp[1],fmem^[fhp],byte(temp[0]));
              inc(fhp,byte(temp[0])); end;
      '.':  write(temp);
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

  procedure   tc4th.dup;  var dd: dword;
  begin dd := pop; push(dd);  push(dd);  end;

  procedure   tc4th.drop;  begin pop;  end;

  procedure   tc4th.swap;  var d1, d2: dword;
  begin drop2(d1, d2); push(d1); push(d2);  end;

  procedure   tc4th.over;  var d1, d2: dword;
  begin drop2(d1, d2); push(d2); push(d1); push(d2);  end;

  procedure   tc4th.drop2(var d1, d2: dword);
  begin d1 := pop; d2 := pop ;   end;

  procedure   tc4th.plus;  var d1, d2: dword;
  begin drop2(d1, d2); push(d2-d1);  end;

  procedure   tc4th.minus;  var d1, d2: dword;
  begin drop2(d1, d2); push(d2+d1);  end;

  procedure   tc4th.orw;  var d1, d2: dword;
  begin drop2(d1, d2); push(d2 or d1);  end;

  procedure   tc4th.xorw;  var d1, d2: dword;
  begin drop2(d1, d2); push(d2 xor d1);  end;

  procedure   tc4th.andw; var d1, d2: dword;
  begin drop2(d1, d2); push(d2 and d1);  end;

  procedure   tc4th.notw;  begin push(not pop); end;

  procedure   tc4th.negw;  begin push(- pop); end;

  procedure   tc4th.dot; begin write(ntostr(pop)+' '); end;

  procedure   tc4th.cr; begin writeln; end;

begin
end.
