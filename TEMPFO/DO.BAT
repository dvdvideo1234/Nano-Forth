..\tasm  %1.asm >err
..\tlink /x /t %1.obj >>err
type err
del %1.obj
