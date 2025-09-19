PROGRAM PRIME;
  TYPE PRISET = SET OF BYTE;
     wordREC	= record lo, hi:  BYTE; end;

  VAR {SPRIM : PRISET;}
    AP: ARRAY[BYTE] OF PRISET;

  CONST TOP = 65535-256;

  PROCEDURE EXCL(P: WORD);
  BEGIN
    WITH WORDREC(P) DO
      AP[HI] := AP[HI] - [LO];
  END;

  FUNCTION INPR(P: WORD): BOOLEAN;
  BEGIN
    WITH WORDREC(P) DO
      INPR := LO IN AP[HI];
  END;

  PROCEDURE INCL(P: WORD);
  BEGIN
    WITH WORDREC(P) DO
      AP[HI] := AP[HI] + [LO];
  END;

  PROCEDURE ERATO;
    VAR I, J, S, C: WORD;
    BEGIN
      FOR I := 0 TO 255 DO AP[0] := AP[0] + [I];
      FOR I := 1 TO 255 DO AP[I] := AP[0];
      EXCL(0); EXCL(1);

      FOR I := 2 TO 255 DO BEGIN
        IF INPR(I) THEN BEGIN
          S := I;
          J := S + S;
          WHILE J <= TOP DO BEGIN EXCL(J); J := J + S; END;
        END;
      END;
      C := 0;
      FOR I := 0 TO 1200 DO
        IF INPR(I) THEN BEGIN
          INC(C);
          IF C MOD 15 = 0
            THEN WRITELN(I)
            ELSE WRITE(I,' ');
        END;
      WRITELN;
    END;

  BEGIN
    ERATO;
  END.