\..\..\tasm  /C /LA %1.asm >\..\..\err
IF NOT EXIST   %1.obj GOTO KRAY
  \..\..\tlink /x /t %1.obj >>\..\..\err
  \..\..\UP3  %1 >>\..\..\err
  type \..\..\err
  del %1.obj
:KRAY

