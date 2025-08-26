..\tasm  /C /LA %1.asm >err
..\tlink /x /t %1.obj >>err
type err
