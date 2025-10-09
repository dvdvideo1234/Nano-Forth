

{CONST CDIGTBL: STRING[64] =
  '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz@_';}


{  DIVMOD PURE PASCAL

  function dvmd(d: dword; w: word): dword ;
  inline($5b/$58/$5a/$f7/$f3);

  function newdm(var d: dword; w: word): word;
  var dd: dword absolute d; d1, res: dword;
  begin d1 := longrec(dd).hi; res := dvmd(d1,w);
     longrec(dd).hi := longrec(res).lo;  d1 := res; hi
     longrec(d1).lo := longrec(dd).lo;  res := dvmd(d1,w);
     longrec(dd).lo := longrec(res).lo;
     newdm := longrec(res).hi;
  end;
}

{
VAR PH: PHASH;
    I: WORD;
    P: PEL;
begin
  WRITELN('GAGA');
  ph := new(phash,create(19,@H32H));
  I  := H32H('A');
  ph^.ADD('A','B');
  PH^.SHOW;
  ph^.ADD('B','C');
  PH^.SHOW;
  ph^.ADD('C','D');
  PH^.SHOW;
  ph^.ADD('D','E');
  PH^.SHOW;
  P := PH^.SEARCH('B');
  WRITELN(PH^.GETVALUE(P)^);
  readln;
  PH^.DONE;
}

{
  FUNCTION  STKPTR: WORD;
  VAR P: WORD;
  BEGIN
    ASM
      LEA AX,[BP+4]
      MOV P,AX
    END;
    STKPTR := P;
  END;
}
{
  PROCEDURE TEST;
  VAR SRS, DST: STRING;
  DD: DWORD; DELTA: INTEGER; DVD: WORD;
  CH: CHAR;  PC: PCHAR;
  BEGIN
    SRS := ^A^B^C'4~_^"';
    WRITELN('function  DigChar(n: byte): char;',CHAR($6E));
    CH := DigChar(11);
    WRITELN('DigChar ',11,' = ',CH);

    WRITELN('DST := STRUNPACK(SRS)');
    DST := STRUNPACK(SRS);
    WRITELN(DST,BOOLTXT(STRPACK(DST)=SRS));
\    TESTPARAM(SRS,3);
\    WRITELN(VA,' ',VB,' ',VC);

  WRITELN('function  getc(var where: pchar): char');
  PC := @CH;
  WRITELN('getc = ',GETC(PC),' ',BOOLTXT((PC-1)=(@CH)));


  WRITELN('procedure putc(what: char; var where: pchar)');
  PC := @CH;
  PUTC('A',PC);
  WRITELN('PUTc = ',BOOLTXT(CH='A'),' ',BOOLTXT((PC-1)=(@CH)));

  WRITELN('function  divmod(var w: dword; d: word): word');
  DD := 70;
  DVD := divmod(DD, 17);
  WRITELN('DIVMOD = ',BOOLTXT(DVD=(70 MOD 17)),' ',BOOLTXT(DD=(70 DIV 17)));

  function  strToNum(s: shortstring): longint;
  procedure stradd(var sd: shortstring; ss: shortstring; del: char);
  function  NToHex(n: dword; chars: byte): str15;
  function  LongToHex(n: dword): str15;
  function  NumberToStr(n: longint; chars, BASE: byte): str33;
  function  byteTohex(n: byte): str5;
  function  NToStr(n: longint): str15;
  function  byteTobin(n: byte): str15;
  function  WordTohex(n: word): str15;

  function  RelADR(inw, Mask: WORD): WORD;

    READLN;
  END;
}
