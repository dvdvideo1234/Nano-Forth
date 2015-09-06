@echo on
..\VD
..\ARM_R /M
echo SET HELPFILE=I:\tools\tempfo\HELPFILE.DAT
echo D:\USB\tools\mini4th\HELPFILE.DAT
..\HELP!  /X
call edt.bat  nf70.asm
