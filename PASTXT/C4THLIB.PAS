unit c4thlib;

interface

uses baselib, strLib, hashlib;

  type
    tstack= object
      ftop : word; {end of stack}
      fstkp: word;
      fsize: word; {in bytes}
      fdata: ppary;
      constructor create(sz: word); {in elements}
      destructor  done;
      procedure error(fe: boolean); {full or empty}
      procedure push(l: dword);
      function  pop:  longint;
      function  sp:   word;
      function  size: word;

    end;


    ptc4th = ^tc4th;
    tproc4th = procedure ( selfp: ptc4th; method: pointer);
    tc4th = object
      fcomph: nhash;
      finteh: nhash;
      fstack: tstack;
      fstate: pointer;
      fproc : tproc4th;
      fsize : word;
      fmem  : parbyte;
      ffwdbr,         {count of branches forward & backward}
      fbwdbr: word;
      falign: word;
      fToken: str85;    {last token}
      fLine:  string;   {last line}
      fls:    longstr;  {current position in text buffer}
      fhp   : word;   {pointer in compiler memory == here pointer}
      fbye  : boolean;
      ferr  : boolean;
      constructor create(stksz, sz: word; aproc: tproc4th);
      destructor  done;
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
      procedure   forth;
      procedure   push(L: dword);
      procedure   getToken;
      procedure   newDEA; {dictionary (enabled) address}
      procedure   equColon; {dictionary established address}
      procedure   macro(s: string);
      procedure   error(s: string);
      procedure   strcomp;
      procedure   execute(p: pel);
      procedure   compile(p: pel);
      procedure   getNum;
      procedure   compNum;
      procedure   IntSearch;
      procedure   compSearch;
      procedure   bye;
    end;

implementation

{-------------------------------------------}

  constructor tstack.create(sz: word);
  begin
      fstkp:= sz;  {empty stack}
      ftop := sz;
      fsize:= sz * 4; {in bytes}
      getmem(fdata,fsize);
  end;

  destructor tstack.done;
  begin
      fsize:= 0; {in bytes}
      freemem(fdata,fsize);
  end;

  procedure tstack.push(L: dword);
  begin
    if fstkp = 0 then error(true);
    dec(fstkp);
    fdata^[fstkp] := pointer(l);
  end;

  function  tstack.pop: longint;
  begin
    if fstkp = ftop then error(false);
    pop := dword(fdata^[fstkp]);
    inc(fstkp);
  end;

  procedure tstack.error(fe: boolean); {full or empty}
  const msg: array[boolean] of str7 = ('empty','full');
  begin
    writeln('Stack ',msg[fe]);
    if fe
      then  fstkp := ftop
      else  fstkp := 0;
  end;

  function  tstack.sp:   word;
  begin
    sp :=  fstkp;
  end;

  function  tstack.size: word;
  begin
    size := ftop; {in elements}
  end;

{-------------------------------------------}

  constructor tc4th.create(stksz, sz: word; aproc: tproc4th);
  begin
    fcomph.create(101,@h32h);
    finteh.create(101,@h32h);
    fstack.create(stksz);
    getmem(fmem,sz);
    fsize := sz;
    fhp := 0;
    fstate:= @tc4th.toInter;
    ffwdbr:= 0; {no branches on start}
    fbwdbr:= 0;
  end;

  destructor  tc4th.done;
  begin
    fcomph.done;
    finteh.done;
    fstack.done;
    freeMem(fmem,fsize);
  end;

  procedure   tc4th.toInter;  begin fstate := @tc4th.IntSearch;  end;

  procedure   tc4th.toComp;  begin fstate := @tc4th.compSearch;  end;

  procedure tc4th.Colon; begin newDEA;toComp;macro('(:'); end;

  procedure   tc4th.Semi; begin macro('(;');
    if (ffwdbr or fbwdbr) = 0 then toInter;
  end;

  procedure   tc4th.bcomma; begin fmem^[fhp] := pop; inc(fhp); end;

  procedure   tc4th.comma;  var p: pword;
  begin p := @fmem^[fhp]; p^ := pop; inc(fhp,2); end;

  function    tc4th.pop: dword;   begin pop := fstack.pop; end;

  procedure   tc4th.push(L: dword);  begin fstack.push(l);  end;

  procedure   tc4th.equColon; { =: dictionary established address}
  var p: pel;
  begin getToken;
    if fToken = '' then begin error('empty token'); exit; end;
    p :=  fcomph.search(ftoken);
    if p <> nil then begin error('duplicated'); exit; end;
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
    repeat getToken;
      if ftoken <> ''
        then perform(@self,fstate);
    until (fls.rem = 0) or ferr;
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

  procedure   tc4th.bye;  begin fbye := true; end;

  procedure   tc4th.error(s: string);
  begin ferr := true; writeln; writeln(ftoken,' ',s);   end;


  procedure   tc4th.forth;
  begin  {initialization of interpretter dictionary}
    WITH finteh DO BEGIN
      add('BYE',DWORD(@tc4th.bye));
    END;

         {initialization of compiler dictionary}
    WITH fCOMPh DO BEGIN
      add(',<`',DWORD(@tc4th.toInter));
    END;

    writeln;
    repeat ferr := false;  write('=> ');
      readln(fline); macro(fline);
    until fbye;
    halt;
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

  procedure   tc4th.getToken;  begin  Ftoken := lextract(fls);  end;

  procedure   tc4th.strcomp;
  var temp: string; cmd, endc: char;
  begin temp := ftoken; dec(temp[0]); cmd := temp[1];
    repeat endc := temp[1]; delete(temp,1,1);
    until endc = '"';
    case cmd of
      ',':  move(temp[1],fmem^[fhp],byte(temp[0]));
      '.':  write(temp);
      '!': begin ftoken := ''; error(temp); end;
    end;
  end;

  procedure   tc4th.getnum;
  var dd: dword; err: word;
  begin   ATOI(ftoken, dd, err);
    if err <> 0 then begin error('not found'); exit; end;
    push(dd);
  end;

begin
end.
