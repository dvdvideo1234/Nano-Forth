
\  _+*:    TEST DI,1 ; IF ; ADD AX,[SI] ; THEN ; 2/C ; A2/C ;
\  _-/:    A2* ; 2*C ; U< ; IFC ; SUB AX,[SI] ; A1+ ; THEN ;

 0100 0 8 xFAMILY|R [BX+SI] [BX+DI] [BP+SI] [BP+DI] [SI] [DI] [BP] [BX]
 0100 0 8 xFAMILY|R AX| CX| DX| BX| SP| BP| SI| DI|
 0100 0 8 xFAMILY|R AL| CL| DL| BL| AH| CH| DH| BH|

0000 xFIR D0|
0600 xFIR MEM|
4000 xFIR DB|
8000 xFIR DW|
C000 xFIR R|

 0800 0 8 xFAMILY|R AX'| CX'| DX'| BX'| SP'| BP'| SI'| DI'|
 0800 0 8 xFAMILY|R AL'| CL'| DL'| BL'| AH'| CH'| DH'| BH'|

0002 0 2 xFAMILY|R F| T|
0  xFIR B|
1  xFIR W|
0000 xFIR B'|
0100 xFIR W'|
0800 0  4 xFAMILY|R ES| CS| SS| DS|
0100 0  2 xFAMILY|R Y| N|
0200 0  8 xFAMILY|R O| C| Z| CZ| S| P| L| LE|
