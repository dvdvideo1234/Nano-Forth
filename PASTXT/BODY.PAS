program body; {generate text from com file}

USES BASELIB, STRLIB, FILIB, HASHLIB;

  VAR
      OFILE: TEXT;
      FNAME: STRING;

  procedure perform;
  var
    str: string;
    ifile: file;

    function readfile(sz: word): string;
    var buf: string; res: word;
    begin
      readfile := '';
      if eof(ifile) then exit;
      blockread(ifile,buf[1],sz,res);
      buf[0] := char(res);
      readfile := buf;
    end;

  begin
    IF NOT OPENTEXT(FNAME+'.bdy',OFILE,TRUE) THEN BEGIN   { FOR WRITING}
      WRITELN('CAN''T OPEN FILE '+FNAME+'.bdy');
      EXIT;
    END;
    assign(IFILE,FNAME+'.com');
    reset(ifile,1);  { FOR READING}
    while not eof(IFILE) do begin
      str := readfile(20);
      writeln(OFILE,',"' + strunpack(str)+'"');
    end;
    CLOSE(IFILE);
    CLOSE(OFILE);
  end;

begin
    IF PARAMCOUNT = 0 THEN BEGIN
      WRITELN('NO PARAMS');
      EXIT;
    END;
    FNAME := PARAMSTR(1);
    IF not FILEXIST(FNAME+'.com') THEN BEGIN
      WRITELN(FNAME+'.com NOT EXIST OR EMPTY');
      EXIT;
    END;

    perform;

end.