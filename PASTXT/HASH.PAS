UNIT hashTuple;

INTERFACE

USES STRLIB;

CONST TOP = 251;

TYPE
     PtrNODE = ^TUPNODE;
     TUPNODE =
       RECORD
         KEY: pSTR;
         VALUE: pSTR;
         NEXT: PtrNODE;
       END;

     tbl32 = array[byte] of dword;
     tbl16 = array[byte] of word;
     tbl8  = array[byte] of byte;
{
    const
      tcrc32 : tbl32 = (
        );
      tcrc16 : tbl16 = (
        );
      tcrc8  : tbl8 = (
        );
}

var hashstat: array[0..TOP-1] of PtrNODE;

  function CRC32(Data: PCHAR; LEN: Word; CRC, POLY: DWord): DWord;
  function CRC16(var s; len, CRC, POLY: word) : WORD;
  function CRC8(var s; len: WORD; CRC, POLY: BYTE) : BYTE;
  function GEThash(var s; len, CRC, POLY: word) : word;

  procedure pushTuple(tkey, tvalue: string);
  function  chkTuple(tkey: string; index: wptr): ptrnode;
  procedure perform;


IMPLEMENTATION


  function  chkTuple(tkey: string; index: wptr): ptrnode;
  var whash: word; fnd: ptrNode;
  begin
    whash := crc16(tkey,byte(tkey[0])+1,$FFFF,$C867) MOD TOP;
    if index <> nil then index^ := whash;
    fnd  := hashStat[whash];
    while fnd <> nil do begin
      if fnd^.key^ = tkey then begin
        chkTuple := fnd;
        exit;
      end;
      fnd := fnd^.next;
    end;
    chkTuple := fnd;
  end;

  procedure pushTuple(tkey, tvalue: string);
  var fnd: ptrNode;  putNode: tupNode;
      index: word; {in hash table}
  begin
    if tkey = '' then exit;
    fnd := chkTuple(tkey, @index);
    if fnd <> nil then begin
       writeln('Duplicate key : ',tkey);
       exit;
    end;
    with putNode do begin
      key := strToMem(tkey);
      value := strToMem(tvalue);
      next  := hashStat[index];
    end;
    new(fnd);
    fnd^ := putNode;
    hashStat[index] := fnd;
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

  function GEThash(var s; len, CRC, POLY: word) : word; assembler;
  var res: word;
  asm
    push ds
    lds si,s
    mov di,127
    xor ax,ax
    lodsb
    mov cx,ax
    dec si
    inc cx
    mov bx,97

@@loop:
    lodsb
    xchg ax,di
    mul  bx
    xchg ax,di
    add  di,ax
    loop @@loop

    mov dx,0
    xchg ax,di
    mov bx,126-'!'
    div bx
    mov al,dl
    add al,'!'
    cmp al,','
    jb  @@skip
    inc ax
@@skip:
    pop ds
end;

{C := CRC32T(PCHAR(@CUT1), byte(cut1[0])+1, $FFFFFFFF, $EDB88320) MOD TOP;}

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

begin
end.