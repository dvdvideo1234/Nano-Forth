UNIT hashlib;

INTERFACE

USES baselib, STRLIB;


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

IMPLEMENTATION

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
    SUB SP,64
    push ds
    push Es
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
    pOP Es
    pop ds
    xchg  ax,DI
    MOV   DX,CX
    ADD SP,64
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