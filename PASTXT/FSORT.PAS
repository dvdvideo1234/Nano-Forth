program FSORT(INPUT,OUTPUT);

uses baselib;

  var strcnt: integer;
    sar: array[0..15000] of pstr;

  PROCEDURE fread;
  var line: string;
      ps: pstr;
  begin
    strcnt := 0;
    while not eof(input) do begin
      readln(input,line);
      ps := strtomem(line);
      sar[strcnt] := ps;
      inc(strcnt);
    end;
  end;

  PROCEDURE fwrite;
  var i: integer;
  begin
    for i := 0 to pred(strcnt) do
      writeln(output,sar[i]^);
  end;

  function partition(start: integer; _end: integer):integer;
  var
    pivot, temp: pstr;
    i, j: integer;
  begin
    pivot := sar[(start + _end) div 2];
    i := start;
    j := _end;

    while i <= j do
    begin
        while sar[i]^ < pivot^ do
            inc(i);
        while sar[j]^ > pivot^ do
            dec(j);
        if i <= j then
        begin
            temp := sar[i];
            sar[i] := sar[j];
            sar[j] := temp;

            inc(i);
            dec(j);
        end;
    end;

    partition := i;
  end;

  procedure qSort(start: integer; _end: integer);
  var
    temp: integer;
  begin
    if start < _end then
    begin
        temp := partition(start, _end);

        qSort(start, temp - 1);
        qSort(temp, _end);
    end;
  end;

  procedure sort;
  begin
    qsort(0, pred(strcnt));
  end;


BEGIN
  fread;
  sort;
  fwrite;
END.
