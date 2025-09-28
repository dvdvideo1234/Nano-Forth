UNIT hashlib;

INTERFACE

USES baselib, STRLIB;

type
  ppel = ^pel;
  pel  = ^el;
  el   = record
    tnext  : pel;
    t1     : byte;
    t2     : byte;
  end;

  phash = ^hash;
  hash  = object
    tcount  : word;
    tels    : ppary;
    tHash   : pointer;
    tunused : pel;
    constructor create(Count: word; Func: pointer);
    destructor  done;
    procedure   show;
    function    search(key: string): pel;
    function    whereTo(key: string): ppel;
    procedure   push(p: pel; var toWhere: pel);
    function    pop(var From: pel) : pel;
    procedure   preRehash;
    procedure   Rehash(newCount: word; newFunc: pointer);

    procedure   Add(key, value: string);          virtual;
    function    GetKey(p: pel): pstr;             virtual;
    function    GetValue(p: pel): pstr;           virtual;
    procedure   elDone(p: pel);                   virtual;
  end;

  function CRC32t(Data: PCHAR; LEN: Word; CRC: DWord): DWord;
  function GETh32(var s; CRC: DWORD; len, POLY: word) : Dword;
  function CRC32(Data: PCHAR; LEN: Word; CRC, POLY: DWord): DWord;
  function CRC8t(Data: PCHAR; LEN: WORD; crc: BYTE): BYTE;
  function CRC8t2(Data, TABLE: PCHAR; LEN: WORD; crc: BYTE): BYTE;
  function CRC8(var s; len: WORD; CRC, POLY: BYTE) : BYTE;
  function CRC16t(Data: PCHAR; LEN, crc: Word): Word;
  function CRC16(var s; len, CRC, POLY: word) : WORD;
  function GEThash(var s; len, CRC, POLY: word) : word;
  function GEThw(Data: PCHAR; len, CRC, POLY: word) : word;
  function GEThw2(Data: PCHAR; len, CRC, POLY: word) : word;

{$i hashinc}

  function h32H(s: string): DWORD;
  function h32t(s: string): Dword;
  function h32(s: string): Dword;
  function h16t(s: string): word;
  function h16(s: string): word;
  function h8t2(s: string): BYTE;
  function h8t(s: string): BYTE;
  function h8(s: string): word;
  function hghw(s: string): word;
  function hgh(s: string): WORD;
  function hgh2(s: string): WORD;

IMPLEMENTATION

  procedure   hash.push(p: pel; var ToWhere: pel);
  begin
    p^.tnext := Towhere;
    Towhere := p;
  end;

  function    hash.pop(var From: pel) : pel;
  var fnd: pel;
  begin
    pop := nil;
    fnd := From;
    if fnd = nil then exit;
    from := fnd^.tnext;
    fnd^.tnext := nil;
    pop := fnd;
  end;

  procedure   hash.Add(key, value: string);
  var szk: byte absolute key; szv: byte absolute value;
    P: pel;
  begin
    myGetMem(POINTER(P),sizeof(el)+szk+szv);
    getkey(P)^ := key;  {describes where value is}
    getValue(P)^ := value;
    push(P,whereTo(key)^);
  end;

  function    hash.GetKey(p: pel): pstr;
  begin
    getKey := pstr(@p^.t1);
  end;

  function    hash.GetValue(p: pel): pstr;
  begin
    getValue := pstr(addptr(@p^.t2,p^.t1));
  end;

  procedure   hash.elDone(p: pel);
    var sz: word;
  begin
    sz := length(GetValue(p)^)+sizeof(el)+p^.t1;
    freemem(p,sz);
  end;

  constructor hash.create(Count: word; Func: pointer);
  begin
    tcount := count;
    thash  := func;
    myGetMem(POINTER(tels),tcount * sizeof(pointer));
  end;

  function    HASH.whereTo(key: string): ppel;
  VAR I: DWORD;
  begin
    I := Thfunc(THASH)(key);
    I := DIVMOD(I,tcount);
    whereTo := ppel(@tels^[I]);
  end;

  procedure   hash.show;
  var i: integer; p: pel; cnt: word;
  begin
    for i := tcount-1 downto 0 do begin
      p := pel(tels^[i]);
      if p = nil  then continue;
      WRITELN(LONGTOHEX(DWORD(P)));
      write(i,' ');  cnt := 0;
      while p <> nil do begin
        write(getkey(p)^,',',getvalue(p)^,' ');
        p := p^.tnext;
        inc(cnt);
      end;
      writeln(cnt);
    end;
  end;

  destructor  hash.done;
  begin
    preRehash;
    while tunused <> nil do
      eldone(pop(tunused));
  end;

  procedure hash.preRehash;
  var i: integer; p, P1: pel;
  begin  {free buckets}
    for i := tcount-1 downto 0 do
      if tels^[i] <> nil then begin
        p := pel(tels^[i]);
        while p <> nil do begin
          push(pOP(P),tunused);
        end;
        tels^[i] := NIL;
      end;
    freemem(tels,tcount * sizeof(pointer));
  end;

  function  hash.search(key: string): pel;
  var p: pel;
  label skip1;
  begin search := nil;  p := whereTo(key)^;
    goto skip1;
    repeat p := p^.tnext;
skip1:
      if p = nil then exit;
    until getkey(p)^ = key;
    search := p;
  end;

  procedure hash.rehash(newCount: word; newFunc: pointer);
  var e1 : pel;
  begin preRehash;
    tcount := newCount;
    thash  := newFunc;
    getmem(tels,tcount * sizeof(pointer));
    while tunused <> nil do begin
      e1 := pop(tunused);
      push(e1,whereTo(getkey(e1)^)^);
    end;
  end;

{----------------------------------------------}


  function h32H(s: string): DWORD;
  begin
    H32H := GETh32(s[1], 0, byte(s[0]), 94);
  end;

  function h32t(s: string): Dword;
  begin
    h32t :=  CRC32t(@s[1],byte(s[0]), -1);
  end;

  function h32(s: string): Dword;
  begin
    h32 :=  CRC32(@s[1],byte(s[0]), -1, $EDB88320);
  end;

  function h16t(s: string): word;
  begin
    h16t := CRC16t(@s[1],byte(s[0]), $ffff);
  end;

  function h8t(s: string): BYTE;
  begin
    h8t := CRC8t(@s[1],byte(s[0]), $ff);
  end;

  function h8t2(s: string): BYTE;
  begin
    h8t2 := CRC8t2(@s[1],@tcrc8,byte(s[0]), $ff);
  end;

  function h16(s: string): word;
  begin
    h16 := CRC16(s[1],byte(s[0]), $ffff, $c867);
  end;

  function h8(s: string): word;
  begin
    h8 := CRC8(s[1],byte(s[0]), $ff, $67);
  end;

  function hghw(s: string): word;
  begin
    hghw := GEThash(s[1],byte(s[0]), $ffff, $c867);
  end;

  function hgh(s: string): WORD;
  begin
    hgh := GEThw(@s[1],byte(s[0]), $ffff, $c867);
  end;

  function hgh2(s: string): WORD;
  begin
    hgh2 := GEThw2(@s[1],byte(s[0]), $ffff, $c867);
  end;

  function CRC8(var s; len: WORD; CRC, POLY: BYTE) : BYTE; ASSEMBLER;
  asm
    push ds
    lds si,s
    mov cx,len
    mov dL,CRC
    mov bL,POLY
    jcxz @@skip
    mov di,cx
@@loop:
    lodsb
    mov  cx,8
    xor  dl,al
@@loop2:
    rol dL,1
    JNC @@LOOP3
    xor dL,bL
@@LOOP3:
    loop @@loop2
    dec  di
    jne  @@loop
@@skip:
    xchg ax,dx
    pop ds
  END;

  function CRC32(Data: PCHAR; LEN: Word; CRC, POLY: DWord): DWord;
    {const poly=$EDB88320;}
    var i,j:WORD;
  BEGIN
    while LEN>0 do begin
      crc:=BYTE(Data^) xor crc;
      for j:=0 to 31 do BEGIN
        asm
          MOV AX,WORD PTR CRC+2
          SHL AX,1
          RCL WORD PTR crc,1
          RCL WORD PTR CRC+2,1
        END;
        IF ODD(CRC) THEN CRC := CRC XOR POLY;
      END;
      DATA := DATA + 1;
      LEN := LEN - 1;
    end;
    CRC32:=crc;
  END;

  function CRC32t(Data: PCHAR; LEN: Word; CRC: DWord): DWord;
  BEGIN
    while LEN>0 do begin
      crc:=tcrc32[BYTE(Data^)] xor crc;
      DATA := DATA + 1;      LEN := LEN - 1;
    end;
    CRC32t:=crc;
  END;

  function CRC16t(Data: PCHAR; LEN, crc: Word): Word;
  BEGIN
    while LEN>0 do begin
      crc:=tcrc16[BYTE(Data^)] xor crc;
      DATA := DATA + 1;      LEN := LEN - 1;
    end;
    CRC16t:=crc;
  END;

  function CRC8t(Data: PCHAR; LEN: WORD; crc: BYTE): BYTE;
  BEGIN
    while LEN>0 do begin
      crc:=tcrc8[BYTE(Data^)] xor crc;
      DATA := DATA + 1;      LEN := LEN - 1;
    end;
    CRC8t:=crc;
  END;

  function CRC16(var s; len, CRC, POLY: word) : WORD;    assembler;
  asm
    push ds
    lds si,s
    mov cx,len
    mov dx,CRC
    mov bx,POLY
    jcxz @@skip
    mov di,cx
@@loop:
    lodsb
    mov  cx,16
    xor  dl,al
@@loop2:
    rol dx,1
    JNC @@LOOP3
    xor dx,bx
@@LOOP3:
    loop @@loop2
    dec  di
    jne  @@loop
@@skip:
    xchg ax,dx
    pop ds
  end;

  function CRC8t2(Data, TABLE: PCHAR; LEN: WORD; crc: BYTE): BYTE; assembler;
  asm
    push ds
    lds si,DATA
    LES BX,TABLE
    mov AH,crc
    mov cx,len
    jcxz @@skip
@@loop:
    lodsb
    XLAT
    XOR  AH,aL
    loop @@loop
@@skip:
    xchg  aL,AH
    pop ds
  end;


  function GEThash(var s; len, CRC, POLY: word) : word; assembler;
  asm
    push ds
    lds si,s
    mov di,crc
    xor ax,ax
    mov cx,len
    mov bx,poly
    jcxz @@skip
@@loop:
    lodsb
    xchg ax,di
    mul  bx
    xchg ax,di
    add  di,ax
    loop @@loop
@@skip:
    xchg  ax,di
    pop ds
  end;

  function GETh32(var s; CRC: DWORD; len, POLY: word) : Dword; ASSEMBLER;
  asm
    push ds
    lds si,s
    LES DI,CRC
    MOV CX,ES
    MOV BX,POLY
    xor ax,ax
    mov Dx,len
    OR  DX,DX
    jz @@skip
@@loop:
    PUSH DX
    lodsb
    SUB  AL,'!'
    XCHG AX,CX
    MUL  BX
    XCHG AX,CX
    XCHG AX,DI
    MUL  BX
    XCHG AX,DI
    ADD  DI,AX
    ADC  CX,DX
    POP  DX
    DEC  DX
    JNE  @@loop
@@skip:
    pop ds
    xchg  ax,DI
    MOV   DX,CX
  END;

  function GEThw(Data: PCHAR; len, CRC, POLY: word) : word; assembler;
  asm
    push ds
    lds si,data
    mov dx,crc
    mov bx,poly
    mov cx,len
    mov di,dx
    xor ax,ax
@@skip0:
    jcxz @@skip

@@loop:
    lodsb
    xchg ax,di
    mul  bx
    xchg ax,di
    add  di,ax
    xor  di,bx
    add  di,dx
    loop @@loop
@@skip:
    xchg ax,di
    pop ds
end;

  function GEThw2(Data: PCHAR; len, CRC, POLY: word) : word; assembler;
  asm
    push ds
    lds si,data
    mov dx,crc
    mov bx,poly
    mov cx,len
    xor di,di
    xor ax,ax
@@skip0:
    jcxz @@skip

@@loop:
    lodsb
    xor  di,bx  {POLY}
    rol  di,1
    adc  di,ax  {crc}
    loop @@loop
@@skip:
    xor  di,dx
    xchg ax,di
    pop ds
end;

{C := CRC32T(PCHAR(@CUT1), byte(cut1[0])+1, $FFFFFFFF, $EDB88320) MOD TOP;}
{
  procedure perform;
    procedure gen8;
    var b: byte;
    begin
      for b := 0 to 255 do begin
        if (b and 7) = 0 then writeln;
        write('$'+bytetohex(crc8(b,1,0,$67))+',');
      end;
    end;

    procedure gen16;
    var b: byte;
    begin
      for b := 0 to 255 do begin
        if (b and 7) = 0 then writeln;
        write('$'+wordtohex(crc16(b,1,0,$C867))+',');
      end;
    end;

    procedure gen32;
    var b: byte;
    begin
      for b := 0 to 255 do begin
        if (b and 7) = 0 then writeln;
        write('$'+dwordtohex(crc32(@b,1,0,$EDB88320))+',');
      end;
    end;

  begin
    gen8;  writeln;
    gen16; writeln;
    gen32; writeln;
  end;
}

begin
end.
