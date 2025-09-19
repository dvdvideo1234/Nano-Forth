function CRC32T(
    CRC: LongWord;
    Data:array of byte;
    DataSize: LongWord): LongWord;

    const poly=$EDB88320;
    var i,j:integer;
        tmp1,tmp2:longword;

  BEGIN

    i:=0;
    while i<=DataSize-1 do begin
      tmp1:=0;
      tmp2:=crc and poly;
      for j:=0 to 31 do
        tmp1:=tmp1 xor ((tmp2 shr j) and 1);
      crc:=Data[i] xor ((crc shl 1) or tmp1);
      i:=i+1;
    end;
    CRC32T:=crc;

  END;
