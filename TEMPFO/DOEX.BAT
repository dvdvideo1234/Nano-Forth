del %1.lst > err
..\tasm %1.asm /la /zi /C >> err
..\tlink /x /t %1.obj     >> err
del %1.obj                >> err
type err
