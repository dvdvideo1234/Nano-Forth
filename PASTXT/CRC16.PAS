function CRC8(data: PByte; len: Byte): Byte;
var
  crc     : byte;
  extract : byte;
  tempI   : integer;
  sum     : byte;
begin
  crc := 00;
  while (len > 0) do
  begin
    extract := data^;
    inc(data);
    for tempI := 8 downto 1 do
    begin
      sum := (crc xor extract) and $01;
      crc := crc shr 1;
      if (sum <> 0) then
      begin
        crc := crc xor $8C;
      end;
      extract := extract shr 1;
    end;
    dec(len);
  end; 
  CRC8 := crc;
end;

function CRC8(const data: array of byte): byte;
const
  Poly = $8c;
var
  crc : byte;
  i,j : integer;
begin
  crc := 0;
  for i := low(data) to high(data) do
  begin
    crc := crc xor data[i];
    for j := 1 to 8 do
    begin
      if odd(crc)
      then crc := (crc shr 1) xor Poly
      else crc := crc shr 1;
    end;
  end;
  CRC8 := crc;
end;


program test_multicrc16;

type
  TDataOrderProc       = function(value: byte): byte;
  TRemainderOrderProc  = function(value: word): word;


function straight_16(value: word): word;
begin
  exit(value);
end;


function reverse_16(value: word): word;
var
  reversed : word = 0;
  i        : integer;
begin
  for i := 0 to 15 do
  begin
    reversed := reversed shl 1;
    reversed := reversed or value and $1;
    value := value shr 1;
  end;
  exit(reversed);
end;


function straight_8(value: byte): byte;
begin
  exit(value);
end;


function reverse_8(value: byte): byte;
var
  reversed : byte = 0;
  i        : integer;
begin
  for i := 0 to 7 do
  begin
    reversed := reversed shl 1;
    reversed := reversed or value and $1;
    value := value shr 1;
  end;
  exit(reversed);
end;


function CRC16(data: PByte; nBytes: Integer; data_order: TDataOrderProc; remainder_order: TRemainderOrderProc; remainder: Word; polynomial: word): word;
var
  b   : Integer;
  bit : integer;
begin
  b := 0;
  while b < nBytes do
  begin
    remainder := remainder xor (data_order(data[b]) shl 8);
    for bit := 8 downto 1 do
    begin
      if (remainder and $8000) <> 0
      then remainder := (remainder shl 1) xor polynomial
      else remainder := (remainder shl 1);
    end;

    inc(b);
  end;
 
  CRC16 := remainder_order(remainder);
end;


function crc16ccitt(const data: PByte; nBytes: integer): Word;
begin
  exit(crc16(data, nBytes, @straight_8, @straight_16, $ffff, $1021));
end;


function crc16ccitt_xmodem(const data: PByte; nBytes: integer): Word;
begin
  exit(crc16(data, nBytes, @straight_8, @straight_16, $0000, $1021));
end;


function crc16ccitt_kermit(const data: PByte; nBytes: integer): Word;
var
  swapper : word;
begin
  swapper := crc16(data, nBytes, @reverse_8, @reverse_16, $0000, $1021);
  exit((swapper shl 8) or (swapper shr 8));
end;


function crc16ccitt_1d0f(const data: PByte; nBytes: integer): Word;
begin
  exit(crc16(data, nBytes, @straight_8, @straight_16, $1d0f, $1021));
end;


function crc16ibm(const data: PByte; nBytes: integer): Word;
begin
  exit(crc16(data, nBytes, @reverse_8, @reverse_16, $0000, $8005));
end;


function crc16normal(const data: PByte; nBytes: integer): Word;
begin
  exit(crc16(data, nBytes, @straight_8, @straight_16, $0000, $8005));
end;


function crc16maxim(const data: PByte; nBytes: integer): Word;
var
  xorvalue: word;
begin
  xorvalue := crc16(data, nBytes, @reverse_8, @reverse_16, $0000, $8005);
  exit(xorvalue xor $FFFF);
end;


Function Hex16(value: word): String;
begin
  Hex16 := HexStr(value, 4);
end;


Var
  data1 : array[0..4] of byte =
  (
    $AA, $06, $00, $00, $00
  );

  data2 : array[0..9] of byte =
  (
    $00, $01, $02, $03, $04, $05, $06, $07, $08, $09
  );


begin
  WriteLn('crc16normal of data1       = $', Hex16(crc16normal       (@data1[0], Length(data1)) ));
  WriteLn('crc16ibm of data1          = $', Hex16(crc16ibm          (@data1[0], Length(data1)) ));
  WriteLn('crc16ccitt of data1        = $', Hex16(crc16ccitt        (@data1[0], Length(data1)) ));
  WriteLn('crc16ccitt_1d0f of data1   = $', Hex16(crc16ccitt_1d0f   (@data1[0], Length(data1)) ));
  WriteLn('crc16ccitt_xmodem of data1 = $', Hex16(crc16ccitt_xmodem (@data1[0], Length(data1)) ));
  WriteLn('crc16ccitt_kermit of data1 = $', Hex16(crc16ccitt_kermit (@data1[0], Length(data1)) ));

  WriteLn('crc16maxim of data1        = $', Hex16(crc16maxim        (@data1[0], Length(data1)) ));
  WriteLn('crc16maxim of data2        = $', Hex16(crc16maxim        (@data2[0], Length(data2)) ));
end.


{
The following polynomial are used:
Normal   Inverted/reversed/reflected
$07   $e0
$31   $8C
CRC8 bit, normal
}

function crc8(Buffer:String;Polynom,Initial:Cardinal):Cardinal;
var
  i,j                   : Integer;
begin
Result:=Initial;
for i:=1 to Length(Buffer) do begin
  Result:=Result xor ord(buffer);
  for j:=0 to 7 do begin
    if (Result and $80)<>0 then Result:=(Result shl 1) xor Polynom
    else Result:=Result shl 1;
    end;
  end;
Result:=Result and $ff;
end;
{CRC8 bit, inverted/reversed/reflected}

{Remember to use corresponding polynomial values.}
function crc8reverse(Buffer:String;Polynom,Initial:Cardinal):Cardinal;
var
  i,j                   : Integer;
begin
Result:=Initial;
for i:=1 to Length(Buffer) do begin
  Result:=Result xor ord(buffer);
  for j:=0 to 7 do begin
    if (Result and $01)<>0 then Result:=(Result shr 1) xor Polynom
    else Result:=Result shr 1;
    end;
  end;
end;


CRC8 byte, normal

var
  CrcTable              : Array[0..255] of Cardinal;

function GenerateTableCrc8(Poly:Cardinal):Cardinal;
var
  i                     : Cardinal;
begin
for i:=0 to 255 do CrcTable:=Crc8(chr(i),Poly,0);
end;

function Crc8Byte(Buffer:String;Initial:Cardinal):Cardinal;
var
  i                     : Cardinal;
begin
Result:=Initial;
for i:=1 to Length(Buffer) do begin
  Result:=(Result shl 8) xor CrcTable[(ord(Buffer) xor (Result)) and $ff];
  end;
Result:=Result and $ff;
end;
CRC8 byte, inverted/reversed/reflected

var
  CrcTable              : Array[0..255] of Cardinal;

function GenerateTableCrc8Reverse(Poly:Cardinal):Cardinal;
var
  i                     : Cardinal;
begin
for i:=0 to 255 do CrcTable:=Crc8Reverse(chr(i),Poly,0);
end;

function Crc8ByteReverse(Buffer:String;Initial:Cardinal):Cardinal;
var
  i                     : Cardinal;
begin
Result:=Initial;
for i:=1 to Length(Buffer) do begin
  Result:=(Result shr 8) xor CrcTable[(ord(Buffer) xor Result) and $ff];
  end;
end;
