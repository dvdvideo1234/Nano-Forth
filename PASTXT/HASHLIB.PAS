UNIT hashlib;

INTERFACE

USES baselib;

type
  tbl32   = array [byte] of dword;
  tbl16   = array [byte] of word;
  tbl8    = array [byte] of byte;

  Thfunc  = function (key: string): Dword;
  tblhash = function (var b; msk: longint): longint;

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
    tprev,
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
    procedure   Remove(key: string);

    function    ValueToStr(p: pel): string;       virtual;
    procedure   SetValue(key, newValue: string);  virtual;
    procedure   Add(key, value: string);          virtual;
    function    GetKey(p: pel): pstr;             virtual;
    function    GetValue(p: pel): pstr;           virtual;
    procedure   elFree(p: pel);                   virtual;
  end;


  pnumel  = ^numel;
  numel   = record
    tnext  : pel;
    tnum   : dword;
    t1     : byte;
  end;

  nhash = object(hash)
    procedure   SetNum(key: string; num: dword);
    function    Getnum(key: string; var num: dword): boolean;
    function    ValueToStr(p: pel): string;       virtual;
    function    GetKey(p: pel): pstr;             virtual;
    procedure   elFree(p: pel);                   virtual;
  end;

  function CRC32t(var s; LEN: Word; CRC: DWord): DWord;
  function CRC16t(var s; LEN,       crc: Word):  Word;
  function CRC8t( var s; LEN: WORD; crc: BYTE):  BYTE;

  function CRC32(var s; LEN: Word; CRC, POLY: DWord): DWord;
  function CRC16(var s; len, CRC, POLY: word) : WORD;
  function CRC8( var s; len, CRC, POLY: WORD) : BYTE;

  function GETh32( var s; len:word; CRC:DWORD; POLY: word) : Dword;
  function GEThash(var s; len,      CRC,       POLY: word) : word;
  function GEThw(  var s; len,      CRC,       POLY: word) : word;
  function GEThw2( var s; len,      CRC,       POLY: word) : word;

  function CRC8t2( var Data, TABLE; LEN: WORD; crc: BYTE): BYTE;
  function CRC16t2(var Data, TABLE; LEN,       crc: WORD): WORD;
  function CRC32t2(var Data, TABLE; LEN:word;  crc:dWORD): dWORD;

  procedure genTable(bits: word; showp, hashp: pointer; mask: longint);

{$i hashinc}

  function h32t(s: string): Dword;
  function h16t(s: string): word;
  function h8t(s: string): BYTE;

  function h32(s: string): Dword;
  function h16(s: string): word;
  function h8(s: string): word;

  function h32H(s: string): DWORD;
  function hghw(s: string): word;
  function hgh(s: string): WORD;
  function hgh2(s: string): WORD;

  function h32t2(s: string): dword;
  function h16t2(s: string): word;
  function h8t2( s: string): BYTE;

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

  constructor hash.create(Count: word; Func: pointer);
  begin
    tcount  := count;
    thash   := func;
    tunused := nil;
    tprev   := nil;
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
    var i: integer; p: pel; cnt, line: word;

    procedure  lp(s: string; del:char);  {line plus & print}
    var sz: byte absolute s;
    begin
      if line > 64 then begin
        writeln; write('  '); line := 2;
      end;
      line := line + sz + 1;
      write(s,del);
    end;

  begin
    for i := tcount-1 downto 0 do begin
      p := pel(tels^[i]);
      if p = nil
        then continue;
      cnt := 0; line := 0;

      lp(ntostr(i),' ');
      while p <> nil do begin
        lp(getkey(p)^,','); lp(valueToStr(p),' ');
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
      elFree(pop(tunused));
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
  var prev, p: pel;
  begin search := nil;  p := whereTo(key)^;
    repeat prev := p; p := prev^.tnext;
      if p = nil then exit;
    until getkey(p)^ = key;
    tprev  := prev;
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

  function    hash.ValueToStr(p: pel): string;
  begin
    ValueToStr := getValue(p)^;
  end;

  procedure    hash.SetValue(key, newValue: string);
  begin Remove(key);
    add(key,newvalue);
  end;

  procedure   hash.elFree(p: pel);
    var sz: word;
  begin
    sz := length(GetValue(p)^)+sizeof(el)+p^.t1;
    freemem(p,sz);
  end;

  procedure   hash.Remove(key: string);
  var p: pel;
  begin
    p := search(key);
    if p = nil then exit; {if exist then unlink and destroy}
    tprev^.tnext := p^.tnext;
    elFree(p);
  end;

{----------------------------------------------}

  function    nhash.ValueToStr(p: pel): string;
  begin
    ValueToStr := '$'+longtohex(pnumel(p)^.tnum);
  end;

  procedure   nhash.SetNum(key: string; num: dword);
  var p: pel; szk: byte absolute key;
  begin p := search(key);
    if p <> nil then begin
      pnumel(p)^.tnum := num;
      exit;
    end;  {else}
    myGetMem(pointer(P),sizeof(numel)+szk);
    with pnumel(p)^ do begin
      getkey(P)^ := key;  {describes where value is}
      tnum := num;
    end;
    push(P,whereTo(key)^);
  end;

  function    nhash.Getnum(key: string; var num: dword): boolean;
  var p: pel;
  begin
    getNum := false; p := search(key);
    if p = nil
      then exit;
    num := pnumel(p)^.tnum;
  end;

  function    nhash.GetKey(p: pel): pstr;
  begin
    getKey := pstr(@pnumel(p)^.t1);
  end;

  procedure   nhash.elFree(p: pel);
    var sz: word;
  begin
    sz := sizeof(numel)+pnumel(p)^.t1;
    freemem(p,sz);
  end;

{----------------------------------------------}


  function h32H(s: string): DWORD;
  begin
    H32H := GETh32(s[1], 0, byte(s[0]), 94);
  end;

  function h32t(s: string): Dword;
  begin
    h32t :=  CRC32t(s[1],byte(s[0]), -1);
  end;

  function h32(s: string): Dword;
  begin
    h32 :=  CRC32(s[1],byte(s[0]), -1, $EDB88320);
  end;

  function h16t(s: string): word;
  begin
    h16t := CRC16t(s[1],byte(s[0]), $ffff);
  end;

  function h8t(s: string): BYTE;
  begin
    h8t := CRC8t(s[1],byte(s[0]), $ff);
  end;

  function h32t2(s: string): dword;
  begin
    h32t2 := CRC32t2(s[1],tcrc32,byte(s[0]), -1);
  end;

  function h16t2(s: string): word;
  begin
    h16t2 := CRC16t2(s[1],tcrc16,byte(s[0]), $ffff);
  end;

  function h8t2(s: string): BYTE;
  begin
    h8t2 := CRC8t2(s[1],tcrc8,byte(s[0]), $ff);
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
    hgh := GEThw(s[1],byte(s[0]), $ffff, $c867);
  end;

  function hgh2(s: string): WORD;
  begin
    hgh2 := GEThw2(s[1],byte(s[0]), $ffff, $c867);
  end;

  function CRC8(var s; len, CRC, POLY: WORD) : BYTE; ASSEMBLER;
  asm
    push ds
    lds si,s
    mov cx,len
    mov bx,CRC
    mov dx,POLY
    mov di,cx
    jcxz @@skip
@@loop:
    lodsb
    mov  cx,8
    xor  bl,al
@@loop2:
    rol bL,1
    JNC @@LOOP3
    xor bL,dL
@@LOOP3:
    loop @@loop2
    dec  di
    jne  @@loop
@@skip:
    xchg ax,bx
    pop ds
  END;

  function CRC32(var s; LEN: Word; CRC, POLY: DWord): DWord; assembler;
  asm
    push ds
    lds si,s
    les bx,crc
    mov dx,es
    mov cx,len
    mov di,cx
    jcxz @@skip
@@loop:
    lodsb
    xor bl,al
    mov  cx,32
@@loop2:
    shl bx,1     {emulate rol32}
    rol dx,1
    JNC @@LOOP3
    inc bx       {on carry}
    xor bx,word ptr poly
    xor dx,word ptr poly+2
@@LOOP3:
    loop @@loop2
    dec  di
    jne  @@loop
@@skip:
    xchg ax,bx
    pop ds
  END;

  function CRC32t(var s; LEN: Word; CRC: DWord): DWord;
  var data: pchar;
  BEGIN data := @s;
    while LEN>0 do begin
      crc:=tcrc32[BYTE(data^)] xor crc;
      inc(word(data));
      LEN := LEN - 1;
    end;
    CRC32t:=crc;
  END;

  function CRC16t(var s; LEN, crc: Word): Word;
  var data: pchar;
  BEGIN data := @s;
    while LEN>0 do begin
      crc:=tcrc16[BYTE(data^)] xor crc;
      inc(word(data));
      LEN := LEN - 1;
    end;
    CRC16t:=crc;
  END;

  function CRC8t(var s; LEN: WORD; crc: BYTE): BYTE;
  var data: pchar;
  BEGIN data := @s;
    while LEN>0 do begin
      crc:=tcrc8[BYTE(data^)] xor crc;
      inc(word(data));
      LEN := LEN - 1;
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
    mov di,cx
    jcxz @@skip
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

  function CRC8t2(var Data, TABLE; LEN: WORD; crc: BYTE): BYTE; assembler;
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

  function CRC16t2(var Data, TABLE; LEN, crc: WORD): WORD; assembler;
  asm
    push ds
    lds si,DATA
    LES BX,TABLE
    mov dx,crc
    mov cx,len
    xor ax,ax
    jcxz @@skip
@@loop:
    lodsb
    mov  di,ax
    add  di,ax
    XOR  dx,es:[di+bx]
    loop @@loop
@@skip:
    xchg  ax,dx
    pop ds
  end;

  function CRC32t2(var Data,TABLE; LEN:word; crc:dWORD): dWORD; assembler;
  asm
    push ds
    lds si,DATA
    LES cX,crc
    mov dx,es
    LES BX,TABLE
    mov di,len
    xor ax,ax
    inc di
    jmp @@loopx
@@loop:
    push di
    lodsb
    mov  di,ax
    add  di,di    {di *2}
    add  di,di    {di *4}
    XOR  cx,es:[di+bx]
    XOR  dx,es:[di+bx+2]
    pop  di
@@loopx:
    dec  di
    jne  @@loop
    xchg  ax,cx
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

  function GETh32(var s; len:word; CRC:DWORD; POLY:word) : Dword; ASSEMBLER;
  asm
    push ds
    lds si,s
    LES DI,CRC
    MOV CX,ES
    MOV BX,POLY
    xor ax,ax
    mov Dx,len
    inc DX
    jmp @@loopx
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
@@loopx:
    DEC  DX
    JNE  @@loop
    pop ds
    xchg  ax,DI
    MOV   DX,CX
  END;

  function GEThw(var s; len, CRC, POLY: word) : word; assembler;
  asm
    push ds
    lds si,s
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

  function GEThw2(var s; len, CRC, POLY: word) : word; assembler;
  asm
    push ds
    lds si,s
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

  procedure genTable(bits: word; showp, hashp: pointer; mask: longint);
  var b: byte; tabmod: word;
  begin tabmod := 78 div ((bits div 4) + 2);
    for b := 0 to 255 do begin
      if (b mod tabmod) = 0 then writeln;
      write('$'+tshow(showp)(tblhash(hashp)(b,mask))+',');
    end;
  end;

begin
end.
