..\tasm  /C /LA %1.asm >err
..\tlink /x %1.obj >>err
type err
