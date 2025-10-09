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
    fnext  : pel;
    fvalue : pointer;
    ftype  : byte;
    ft1    : byte;
  end;

  phash = ^hash;  {BASE HASH}
  hash  = object
    fPels    : ppary;
    fHash   : pointer;
    fPrev,
    fUnused : pel;
    fCount  : word;
    fUnicate: boolean;

    constructor create(Count: word; Func: pointer);
    destructor  done;
    procedure   show(newlin: boolean);
    function    search(key: string): pel;
    function    whereTo(key: string): ppel;
    procedure   push(p: pel; var toWhere: pel);
    function    pop(var From: pel) : pel;
    function    preRehash: word;
    function    rehash(newCount: word; newFunc: pointer): word;
    procedure   Remove(key: string);
    PROCEDURE   setUnicate(UNI: BOOLEAN);
    function    getUnicate: BOOLEAN;
    function    ValueToStr(p: pel): string;
    function    GetKey(p: pel): pstr;
    procedure   Free(p: pel);
    procedure   Add(key: string; value: pointer);
    procedure   AddStr(key, value: string);
    procedure   addNum(key: string; num: dword);
  end;

  function CRC32t(var s; LEN: Word; CRC: DWord): DWord;
  function CRC16t(var s; LEN,       crc: Word):  Word;
  function CRC8t( var s; LEN: WORD; crc: BYTE):  BYTE;

  function CRC32t2(var Data, TABLE; LEN:word;  crc:dWORD): dWORD;
  function CRC16t2(var Data, TABLE; LEN,       crc: WORD): WORD;
  function CRC8t2( var Data, TABLE; LEN: WORD; crc: BYTE): BYTE;

  function CRC32(var s; LEN: Word; CRC, POLY: DWord): DWord;
  function CRC16(var s; len, CRC, POLY: word) : WORD;
  function CRC8( var s; len, CRC, POLY: WORD) : BYTE;

  function GETh32( var s; len:word; CRC:DWORD; POLY: word) : Dword;
  function GEThash(var s; len,      CRC,       POLY: word) : word;
  function GEThw(  var s; len,      CRC,       POLY: word) : word;
  function GEThw2( var s; len,      CRC,       POLY: word) : word;

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

  procedure   hash.Free(p: pel);
    var sz: word;
  begin
    sz := sizeof(el)+p^.ft1;
    if p^.ftype = 2 then FreeString(pstr(p^.fValue));
    freemem(p,sz);
  end;

  procedure   hash.Remove(key: string);
  var p: pel;
  begin
    p := search(key);
    if p = nil then exit; {if exist then unlink and destroy}
    fPrev^.fnext := p^.fnext;
    Free(p);
  end;

  function  MakEl(k: string): pel;
  var p: pel; szk: byte absolute k;
  begin
    myGetMem(POINTER(P),sizeof(el)+szk);
    pstr(@P^.ft1)^ := k;  {describes where value is}
    makel := p;
  end;

  procedure   hash.add(key: string; value: pointer);
  var p: pel;
  begin if fUnicate then Remove(key);
    p := MakEl(key);
    with p^ do begin
      Fvalue := value;
      ftype := 0;
    end;
    push(P,whereTo(key)^);
  end;

  procedure   hash.addnum(key: string; num: dword);
  var p: pel;
  begin if fUnicate then Remove(key);
    p := MakEl(key);
    with p^ do begin
      Fvalue := pointer(num);
      ftype := 1;
    end;
    push(P,whereTo(key)^);
  end;

  procedure   hash.AddStr(key, value: string);
  var P: pel;
  begin if fUnicate then Remove(key);
    p := MakEl(key);
    with p^ do begin
      Fvalue := strToMem(Value);
      ftype := 2;
    end;
    push(P,whereTo(key)^);
  end;

  function    hash.ValueToStr(p: pel): string;
  begin     ValueToStr := '';  if p = nil then exit;
    with p^ do case ftype of
      0: ValueToStr := '$'+LongToHex(dword(fvalue));
      1: ValueToStr := ntostr(dword(fvalue));
      2: ValueToStr := pstr(fvalue)^;
    end;
  end;

  PROCEDURE   hash.setUnicate(UNI: BOOLEAN);
  begin
    fUnicate := uni;
  end;

  function    hash.getUnicate: BOOLEAN;
  begin
    getUnicate := fUnicate;
  end;

  procedure   hash.push(p: pel; var ToWhere: pel);
  begin
    p^.fnext := Towhere;
    Towhere := p;
  end;

  function    hash.pop(var From: pel) : pel;
  var p: pel;
  begin
    pop := nil;
    p := From;
    if p = nil then exit;
    from := p^.fnext;
    p^.fnext := nil;
    pop := p;
  end;

  constructor hash.create(Count: word; Func: pointer);
  begin
    fcount  := count;
    fhash   := func;
    funused := nil;
    fprev   := nil;
    fUnicate:= true;
    myGetMem(POINTER(fpels),fcount * sizeof(pointer));
  end;

  function    HASH.whereTo(key: string): ppel;
  VAR I: DWORD;
  begin
    I := Thfunc(fHASH)(key);
    I := DIVMOD(I,fcount);
    whereTo := ppel(@fPels^[I]);
  end;

  procedure   hash.show(newlin: boolean);
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
    for i := fCount-1 downto 0 do begin
      p := pel(fPels^[i]);
      if p = nil
        then continue;
      cnt := 0; line := 0;
      if newlin then lp(ntostr(i),' ');
      while p <> nil do begin
        lp(getkey(p)^,','); lp(valueToStr(p),' ');
        p := p^.fnext;
        inc(cnt);
      end;
      if newlin then writeln(cnt);
    end;
  end;

  destructor  hash.done;
  begin
    preRehash;
    freemem(fPels,fCount * sizeof(pointer));
    while fUnused <> nil do
      Free(pop(fUnused));
  end;

  function hash.preRehash: word;
  var i: integer; p, P1: pel; cnt: word;
  begin  {free buckets}  cnt := 0;
    for i := fCount-1 downto 0 do
      if fPels^[i] <> nil then begin
        p := pel(fPels^[i]);
        while p <> nil do begin
          push(pOP(P),fUnused);
          inc(cnt);
        end;
        fPels^[i] := NIL;
      end;
    preRehash := cnt;
  end;

  function  hash.search(key: string): pel;
  var prev, p: pel;
  begin search := nil;  p := pel(whereTo(key));
    repeat prev := p; p := prev^.fnext;
      if p = nil then exit;
    until getkey(p)^ = key;
    fPrev  := prev;
    search := p;
  end;

  function hash.rehash(newCount: word; newFunc: pointer): word;
  var e1 : pel;  change: boolean;
  begin ReHash := preRehash;  change := newCount <> fcount;
    if change then freemem(fPels,fCount * sizeof(pointer));
    fCount := newCount;
    fHash  := newFunc;
    if change then getmem(fPels,fCount * sizeof(pointer));
    while fUnused <> nil do begin
      e1 := pop(fUnused);
      push(e1,whereTo(getkey(e1)^)^);
    end;
  end;

  function    hash.GetKey(p: pel): pstr;
  begin
    getKey := pstr(@p^.ft1);
  end;

{----------------------------------------------}

  function h32H(s: string): DWORD;
  begin
    H32H := GETh32(s[1], byte(s[0]), -$1ffff, 3);
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
  begin tabmod := 76 div ((bits div 4) + 2);
    for b := 0 to 255 do begin
      if (b mod tabmod) = 0 then writeln;
      write('$'+tshow(showp)(tblhash(hashp)(b,mask))+',');
    end;
  end;

begin
end.
