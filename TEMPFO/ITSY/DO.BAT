\tasm  /C /LA %1.asm >\err
IF NOT EXIST   %1.obj GOTO KRAY
  \tlink /x /t %1.obj >>\err
  \UP3  %1 >>\err
  \fsort <%1.up >\srt
  COPY %1.COM F1.COM
  TYPE \SRT >>F1.COM
  TYPE \_END_ >>F1.COM
  type \err
  del %1.obj
:KRAY

