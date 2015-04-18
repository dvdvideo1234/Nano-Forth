


Scr#      0
  0    KERNEL.SCR                   CAN'T REMOVE CURRENT DIRECTORY  
  1 INVALID FUNCTION NUMBER         NOT SAME DEVICE                 
  2 FILE NOT FOUND                  NO MORE MATCHING FILES          
  3 PATH NOT FOUND                  WRITE-PROTECTED DISK            
  4 TOO MANY OPEN FILES             UNIT ID UNKNOWN                 
  5 ACCESS DENIED                   DISK DRIVE NOT READY            
  6 INVALID HANDLE                  UNKNOWN COMMAND                 
  7 MEM-CTRL-BLK DESTROYED          CRC ERROR                       
  8 INSUFFICIENT MEMORY             BAD LENGTH                      
  9 MEM-CTRL-BLK INVALID            DISK SEEK ERROR                 
 10 ENVIROMENT INVALID              UNKNOWN DISK MEDIA TYPE         
 11 FORMAT INVALID                  DISK SECTOR NOT FOUND           
 12 ACCESS CODE INVALID             PRINTER OUT OF PAPER            
 13 DATA INVALID                    WRITE FAULT                     
 14 ( NOT USED )                    READ FAULT                      
 15 DRIVE SPECIFIED INVALID         GENERAL FAILURE                 
Scr#      1
  0                                                                 
  1                                                                 
  2                                                                 
  3                                                                 
  4                                                                 
  5   4 35 THRU                                                     
  6                                                                 
  7    L: _TOP                                                      
  8                                                                 
  9                                                                 
 10                                                                 
 11                                                                 
 12                                                                 
 13                                                                 
 14                                                                 
 15                                                                 
Scr#      2
  0                                                                 
  1                                                                 
  2                                                                 
  3                                                                 
  4                                                                 
  5                                                                 
  6                                                                 
  7                                                                 
  8                                                                 
  9                                                                 
 10                                                                 
 11                                                                 
 12                                                                 
 13                                                                 
 14                                                                 
 15                                                                 
Scr#      3
  0                                                                 
  1                                                                 
  2                                                                 
  3                                                                 
  4                                                                 
  5                                                                 
  6                                                                 
  7                                                                 
  8                                                                 
  9                                                                 
 10                                                                 
 11                                                                 
 12                                                                 
 13                                                                 
 14                                                                 
 15                                                                 
Scr#      4
  0  \  USER VARIABLE'S OFFSETS  :=: CONSTANTS                      
  1  \  EASY  TO CHANGE OFFSETS                                     
  2                                                                 
  3 MAC: >NEXT,  <MAIN JMP,;    MAC: >PUSH,  <PUSH JMP,;            
  4 MAC: >SWAP,  <SWAP JMP,;    MAC: >DROP,  <DROP JMP,;            
  5 MAC: CRY@ _CRRY /// AX MOV, 1 #, AX SHL, ;                      
  6 MAC: CRY! 1 #, AX RCR, AX _CRRY /// MOV, ;                      
  7  0                                                              
  8  +C: ->TASK     +C: -<TASK     +C: ->SP       +C: >S0           
  9  +C: >R0        +C: >FRAME     +C: >SELF      +C: >HDR          
 10  +C: >RPTR      +C: >TIB       +C: >BASE      +C: >HOLD         
 11  +C: >H         +C: >STATE     +C: >CURRENT   +C: >CONTEXT      
 12  +C: >VLINK     +C: >>IN       +C: >OUT       +C: >BLK          
 13  +C: >SCR       +C: >CSP       +C: >DBL       +C: >SPAN         
 14  +C: >SCRH       DROP                                           
 15                                                                 
Scr#      5
  0  \  FORWARD DEFINITIONS CONTINUE ...                            
  1  ASM   256 T-ALIGNED \ KERNEL SOURCE IN ASSEMBLER               
  2   L: START/   -?, IF,   L: _BOOT 0 DW,   L: _COLD 0 DW,         
  3   L: _WARM 0 DW,      L: _USER _ORIG1 DW, L: _CRRY 0 DW,        
  4   L: _DSTEP <TRONX DW,  0 DW,  _JUMP DW, _DSTEP DW,  \ DEBUG    
  5   L: FSTAT  <VAR DW, L: _AX   0 DW,  L: _SI   _DSTEP 2+ DW,     
  6   THEN,   CLD,     CALL,F 1                                     
  7 <%                                                              
  8   T-: DROP, BX POP, T-;                                         
  9   T-: SCASW,2 SCASW, SCASW, T-;                                 
 10   T-: SCASW,3 SCASW,2 SCASW, T-;                                
 11   T-: DUP, BX PUSH, T-;                                         
 12 %>                                                              
 13                                                                 
 14                                                                 
 15                                                                 
Scr#      6
  0 L: _ORIG  <WARY DW, ( USER VARS  128 BYTES   IN THIS BLOCK)     
  1 L: _ORIG1 \ +C: ->TASK  +C: -<TASK  +C: ->SP   +C: >S0          
  2  0 DW, $ FF00 DW, $ FF00 DW, $ FA00 DW, $ FA00 DW,              
  3 \ +C: >R0        +C: >FRAME     +C: >SELF      +C: >HDR         
  4    $ FE00 DW,        0 DW,           0 DW,         0 DW,        
  5 \ +C: >RPTR      +C: >TIB       +C: >BASE      +C: >HOLD        
  6      92 DW,     $ FE80  DW,     10 DW,         0 DW,            
  7 \ +C: >H         +C: >STATE     +C: >CURRENT   +C: >CONTEXT     
  8     _TOP DW,         0 DW,           0 DW,         0 DW,        
  9 \ +C: >VLINK     +C: >>IN       +C: >OUT       +C: >BLK         
 10        0 DW,         0 DW,           0 DW,         0 DW,        
 11 \ +C: >SCR       +C: >CSP       +C: >DBL      \ +C: >SPAN       
 12  29   [[  0 DW, ]]    1 DW, 2 DW, 3 DW, 4 DW, 5 DW,             
 13   9   [[  0 DW, ]]                                              
 14                                                                 
 15                                                                 
Scr#      7
  0                                                                 
  1                                                                 
  2                                                                 
  3                                                                 
  4                                                                 
  5                                                                 
  6                                                                 
  7                                                                 
  8                                                                 
  9                                                                 
 10                                                                 
 11                                                                 
 12                                                                 
 13                                                                 
 14                                                                 
 15                                                                 
Scr#      8
  0                                                                 
  1                                                                 
  2                                                                 
  3                                                                 
  4                                                                 
  5                                                                 
  6                                                                 
  7                                                                 
  8                                                                 
  9                                                                 
 10                                                                 
 11                                                                 
 12                                                                 
 13                                                                 
 14                                                                 
 15                                                                 
Scr#      9
  0     FL! 1                      SI POP,                          
  1    -2 /SI CX MOV,        2 /SI DI MOV,           DI BX MOV,     
  2 DI _USER /// MOV,        REP, AL MOVS,           AX AX XOR,     
  3   $ 80 #, SI MOV,     >TIB /BX DI MOV,             AL LODS,     
  4        AX BX MOV,        AH 0 X/S MOV,        1 /BX CX LEA,     
  5    REP,  AL MOVS,    $ 1000 #, BX MOV,                          
  6   $ 4A #, AH MOV,       33 INT,                                 
  7                                                                 
  8 L: END_INIT                                                     
  9                                                                 
 10  256 T-ALIGNED                                                  
 11                                                                 
 12  L: OP_TABLE     128 [[  0 DW, ]]                               
 13  OP_TABLE END_INIT - CR . ( BYTES BEFORE OP_TABLE !)            
 14  \ KERNEL SOURCE IN ASSEMBLER                                   
 15                                                                 
Scr#     10
  0                                                                 
  1                                                                 
  2                                                                 
  3                                                                 
  4                                                                 
  5                                                                 
  6                                                                 
  7                                                                 
  8                                                                 
  9                                                                 
 10                                                                 
 11                                                                 
 12                                                                 
 13                                                                 
 14                                                                 
 15                                                                 
Scr#     11
  0       \ Arithmetic                                              
  1  L: +*# 1 #, DL TEST, 0=, NOT, IF, AX POP,    AX BX ADD,        
  2    AX PUSH, THEN, 1 #, BX RCR, 1 #, DX RCR, -?, IF,             
  3  L: +?#  CRY@ AX POP, AX BX ADC,   -?, IF, ( 14  + )            
  4  L: ;#    0 /BP SI MOV,                                         
  5  L: <RDROP   BP INC,   BP INC,        -?, FB, 0   ( 0 ; )       
  6  L: POP#     DUP, 0 /BP BX MOV,  <RDROP JMP,    ( 19  pop)      
  7  L: JUMP# LODSW,         -?, FB, 2   ( 2 JUMP v)                
  8  L: OF#        AX POP,  AX BX XCHG,                             
  9        BX AX  XOR, JUMP# JNZ,  DROP,  LODSW, -?, FB, 62         
 10  L: DUP#  DUP,        -?, FB,  18    ( 18  dup)                 
 11  L: 2*# 1 #, BX SHL,       -?, FB,  11    ( 11  2*)             
 12  L: 2/# 1 #, BX SAR,       -?, FB,  12    ( 12  2/)             
 13  L: INV#     BX COM,       -?, FB,  13    ( 13  - )             
 14  L: IF# LODSW, BX BX OR, 0=, NOT, FB, 6  -?, FB, 36  ( 6 IF)    
 15                                                                 
Scr#     12
  0  L: -IF#   LODSW,  BX BX OR,   0<, FB, 7  -?, FB, 37 ( 7 -IF)   
  1  L: NEXT#  LODSW,   -1 #, CX MOV, CX W/ 0 /BP ADD,              
  2         <RDROP JNB,   -?, FB, 5  ( 5 NEXT )                     
  3  L: AND# AX POP,  AX BX AND, -?, FB, 15   ( 15  AND)            
  4  L: XOR#  AX POP,  AX BX XOR, -?, FB, 16   ( 16  XOR )          
  5  L: OR#  AX POP,  AX BX OR, -?, FB, 17   ( 17  OR )             
  6  L: NIP#  AX POP,  -?, FB, 19   ( 19  OR )                      
  7  L: -#   BX NEG,                                                
  8  L: +#   AX POP,   AX BX ADD,                                   
  9    THEN, THEN,  CRY!   -?, FB,  14    ( 14  + )                 
 10  L: RPUSH#   AX POP,   AX BX XCHG,   SKIP1,  ( 1d puSH)         
 11  L: CALL#    LODSW,  L: <RPUSH   AX SI XCHG,  ( 3 CALL )        
 12  L: <PCPUSH  BP  DEC,  BP DEC, SI 0 /BP MOV,                    
 13       FB! 2  FB! 6  FB! 7  FB! 5  ( JUMP#  IF  -IF )            
 14  L: <JUMP    AX SI XCHG, -?,  IF,                               
 15                                                                 
Scr#     13
  0  L: <STOR-3 SCASW,  L: <STOR-2 SCASW,  L: <STOR-1  SCASW,       
  1  L: <STOR    BX 0 /DI MOV,                                      
  2  L: <DROP    DROP,   SKIP2,                                     
  3  L: <PUSH    DUP,                                               
  4  L: <SWAP    AX BX XCHG,        THEN,                           
  5 FB! 17 FB! 11 FB! 12  FB! 13  FB! 15 FB! 16  FB! 37             
  6     FB! 14 FB! 0   FB! 62  FB! 18   FB! 36  FB! 19              
  7  L: <MAIN  AX LODS,                                             
  8  L: <EX        AX DI XCHG, 0 /DI JMP,   <DBG  JMP,              
  9  L: RCOD>F#   AX POP,    <PCPUSH JMP,                           
 10  L: CODE>F#   AX POP,     <JUMP JMP,                            
 11  L: SP@#   DUP,  SP BX MOV,   >NEXT,    (  SP@   )              
 12  L: SWAP#  AX POP,            >PUSH,                            
 13  L: RP@#   BP AX MOV,         >PUSH,    (  RP@   )              
 14  L: A@#    DX AX MOV,         >PUSH,    (   A@   )              
 15                                                                 
Scr#     14
  0  L: @IP#       LODSW,       >PUSH,    (   @P+ LIT  )            
  1  L: @P#   AX IN,       >PUSH,                                   
  2  L: <0=    BX BX OR, 0=, NOT, IF, BX BX XOR, SKIP2,             
  3  L: <2-    BX DEC,  THEN,  L: <1-    BX DEC,  >NEXT,            
  4  L: OVER#  AX POP,   AX PUSH, >PUSH,    ( 1a oveR)              
  5  L: C@IP#     AL LODS,                  ( BLIT )                
  6  L: <BPUSH 0 #, AH MOV, >PUSH,                                  
  7  L: C@P#   AL IN,       <BPUSH JMP,                             
  8  L: !#      BX DX MOV,  DROP,         ( 1e b!)                  
  9  L: !A#      DX DI MOV,       -?, IF,   ( 0f ! )                
 10  L: !A+#     DX DI MOV,  DX INC, DX INC,   ( 0D !+)             
 11       THEN,   <STOR  JMP,                                       
 12  L: C@A+#  DX DI MOV,  DX INC,  0 /DI AL MOV, <BPUSH JMP,       
 13                                                                 
 14                                                                 
 15                                                                 
Scr#     15
  0  L: <DOES-3 SCASW, L: <DOES-2 SCASW,  L: <DOES-1  SCASW,        
  1  L: <DOES AX POP,   DUP, DI BX MOV,  <PCPUSH JMP,               
  2  L: <VAR-3 SCASW,  L: <VAR-2  SCASW,   L: <VAR-1  SCASW,        
  3  L: <VAR AX DI XCHG, >PUSH,                                     
  4  L: <JSR-5  SCASW,  L: <JSR-4 SCASW,   L: <JSR-3  SCASW,        
  5  L: <JSR-2  SCASW,  L: <JSR-1 2 /DI AX LEA, <PCPUSH JMP,        
  6  L: @R#   0 /BP DI MOV,     -?, IF,     ( 08 @R)                
  7  L: @A+#  DX DI MOV,  DX INC, DX INC,   -?, IF,   ( 09 @+)      
  8  L: @#   BX DX MOV,  DROP,                        ( 1e b!)      
  9  L: @A#   DX DI MOV,     -?, IF,                  ( 0b @ )      
 10  L: <CNST-3 SCASW, L: <CNST-2 SCASW,  L: <CNST-1 SCASW,         
 11            THEN, THEN, THEN,                                    
 12  L: <CNST   DUP, 0 /DI BX MOV,  >NEXT,                          
 13  L: SP!#   BX SP MOV,       >DROP,                              
 14  L: RP!#   BX BP MOV,       >DROP,    ( 1F   A!)                
 15                                                                 
Scr#     16
  0  L:  A!#    BX DX MOV,             >DROP,    ( 1F   A!)         
  1  L: C!P#    BX AX MOV,    AL OUT,  >DROP,                       
  2  L:  !P#    BX AX MOV,    AX OUT,  >DROP,                       
  3  L: <USER!   _USER DI MOV, <STOR JMP,                           
  4  L: C!A+#   DX DI MOV,  BL 0 /DI MOV,     DX INC, >DROP,        
  5  L: C@T+#   0 /BX AL MOV,  BX INC,           <BPUSH JMP,        
  6  L:  @T+#   BX SI XCHG,     LODSW,    BX SI XCHG, >PUSH,        
  7                                                                 
  8 \ DEBUGGER INTERFACE                                            
  9  L: <TROFF LODSW, -?, FB, 63                                    
 10  L: <TRONX LODSW,                                               
 11  L: <DBG $ 2E #, <EX /// XOR,  FB! 63                           
 12      _AX #,  DI  MOV,  AX 2 /DI XCHG,                           
 13       SI 4  /DI XCHG,     AX DI XCHG, 0 /DI JMP,                
 14                                                                 
 15                                                                 
Scr#     17
  0 L: <REUSE CX POP,   0 /BP SI XCHG,   CX CALL,                   
  1 L: ;:#    0 /BP SI XCHG,    >NEXT,                 (  1 ;:)     
  2 L: @R+#     <REUSE #, CALL,                                     
  3            CX POP, LODSW, DUP, AX BX XCHG, CX JMP,              
  4 L: !R+#     <REUSE #, CALL,                        ( 0C !R)     
  5 L: <!PC+   BL BH XCHG,  BH 0 /SI MOV,   SI INC,                 
  6 L: <C!PC+  CX POP,  BL 0 /SI MOV, DROP, SI INC, CX JMP,         
  7 L: C!R+#   <REUSE #, CALL,  <C!PC+  JMP,                        
  8 L: (B"#    <REUSE  #, CALL,                                     
  9 L: <BPC+   SI DI MOV, AL LODS, AH AH XOR,                       
 10 L: <BPC+Z  CX POP, DUP, DI BX MOV, AX SI ADD, CX JMP,           
 11 L: ("#     <REUSE  #, CALL,                                     
 12 L: <WPC+   SI DI MOV, LODSW, <BPC+Z JMP,                        
 13                                                                 
 14                                                                 
 15                                                                 
Scr#     18
  0  L: <LBL-3 SCASW,     L: <LBL-2 SCASW,                          
  1  L: <LBL-1 SCASW, AX DI XCHG, <JUMP JMP,                        
  2  L: <USER   <VAR   #, CX MOV,                                   
  3  L: XUSER    2 /DI DI MOV,  _USER /// DI ADD,     CX JMP,       
  4        L: <@USER-2 SCASW,      L: <@USER-1 SCASW,               
  5  L: <@USER  <CNST  #, CX MOV,  XUSER JMP,                       
  6        L: <!USER-1 SCASW,                                       
  7  L: <!USER  <STOR  #, CX MOV,  XUSER JMP,                       
  8  L: <@REG  <CNST  #, CX MOV,   SCASW, -?, IF,                   
  9  L: <!REG  <STOR  #, CX MOV,  THEN, 2 /DI AX MOV,               
 10    _USER /// DI MOV,  >RPTR /DI DI MOV, AX DI ADD,   CX JMP,    
 11  L: <@VAR  <CNST  #, CX MOV,    -?, IF,                         
 12  L: <!VAR  <STOR  #, CX MOV, -?, IF,  L: <LVAR <VAR #, CX MOV,  
 13      THEN, THEN,  AX POP,  AX BX XCHG, AX COM, 1 #, AX SHL,     
 14    _USER /// DI MOV,  >FRAME /DI DI MOV, AX DI ADD, CX JMP,     
 15                                                                 
Scr#     19
  0  \ DOS INTERFACE   ( A!)  PRESERVE AREG                         
  1  L: <DOS  DX DI MOV, AX BX XCHG,  DROP,  CX POP,  DX POP,       
  2    DI PUSH,  $ 21 INT, AX PUSH,  LAHF,  1 #, AX  RCR,           
  3    _USER /// DI MOV,  >RPTR /DI DI MOV,  STOSW, AX POP, STOSW,  
  4     AX BX XCHG, STOSW,    AX CX XCHG, STOSW,                    
  5     AX DX XCHG, STOSW,   HERE TO ADR   DX POP,  >DROP,          
  6                                                                 
  7 L: <BIO_K   0  #, AH  MOV,   22  INT,  >PUSH,                   
  8 L: ?BIO_K   1  #, AH  MOV,   22  INT,  0=, NOT, IF,             
  9         0 #, AX MOV, T-RECOVER   THEN,  AX AX XOR, >PUSH,       
 10 L: <BIO_E  14 #, AH MOV, BL AL MOV, 16 INT, >DROP,              
 11 L: ?DOS_K   11 #, AH MOV,  33 INT, CBW,  >PUSH,                 
 12 L: <DOS_E   2 #, AH MOV, DX PUSH, BL DL MOV,  33 INT, ADR JMP,  
 13 L: <DOS_K   8 #, AH MOV, 33 INT, AL AL OR,  0=, IF,             
 14               33 INT, AL AH MOV, AL AL XOR, THEN,  >PUSH,       
 15                                                                 
Scr#     20
  0 L: <-/# AX POP,  1 #, BX SHL, 1 #, DX RCL,  AX BX CMP,          
  1       U<, NOT, IF,  AX BX SUB,   DX INC, THEN, AX PUSH, >NEXT,  
  2                                                                 
  3 L: EXEC#     AX BX XCHG,  DROP,   HERE TO ADR  <EX JMP,         
  4 L: ?ALIAS?    AX  POP,   DI POP,   DI  PUSH,  SCASW,            
  5             0=, IF,  AX POP,  0 /DI PUSH,  -?, IF,              
  6 L: ?ALIAS  BX BX  OR,  0=, NOT, IF,   ?ALIAS?  #, CALL,         
  7 L: <ALI  SKIP2,  L: <@EXEC-3  SCASW, L: <@EXEC-2  SCASW,        
  8 L: <@EXEC-1  SCASW,                                             
  9 L: <@EXEC  0 /DI AX MOV,  AX AX OR, ADR JNZ,                    
 10                    THEN, THEN, THEN, >NEXT,                     
 11 L: <PERFORM   BX DI MOV,  DROP,       <@EXEC JMP,               
 12 L: <BLKASE   BX INC,  0=, NOT,   IF,   SCASW,                   
 13          BX DEC,  <@EXEC-2 JNZ,  THEN,  DROP,  <@EXEC-1 JMP,    
 14                                                                 
 15                                                                 
Scr#     21
  0  \  ARRAYS                                                      
  1  L: _IND   DUP, 0 /BP BX MOV, >NEXT,     ( R@ )                 
  2  L: _TARY  1 #, BX SHL,                                         
  3  L: _5ARY    BX DI ADD,                                         
  4  L: _QARY  1 #, BX SHL,                                         
  5  L: <WARY  1 #, BX SHL,                                         
  6  L: _BARY    DI BX ADD,                                         
  7  L: _2+      BX    INC,                                         
  8  L: _1+      BX    INC,   >NEXT,                                
  9                                                                 
 10   (  1 8 +THRU HERE START/ - . )   END-CODE                     
 11      TCOMP   TO KERNEL                                          
 12                                                                 
 13                                                                 
 14                                                                 
 15                                                                 
Scr#     22
  0       +*#  CODE, +*          +?#  CODE, +?                      
  1      AND#  CODE, AND          +#  CODE, +                       
  2       XOR#  CODE, XOR          -#  CODE, -                      
  3       OR#  CODE, OR        NIP#  CODE, NIP                      
  4       2*#  CODE, 2*          2/#  CODE, 2/                      
  5      INV#  CODE, INV       OVER#  CODE, OVER                    
  6     CALL#  CODE, CALL(     ;:#   CODE, ;:                       
  7                                                                 
  8    <RDROP  CODE, RDROP      POP#  CODE, POP                     
  9     C@IP#  CODE, BLIT                                           
 10     SWAP#  CODE, SWAP       DUP#  CODE, DUP                     
 11                                                                 
 12  0 T-QUAN FHAND  32 T-ALLOT                                     
 13  0 T-VECTOR ERROR                                               
 14                                                                 
 15                                                                 
Scr#     23
  0     (B"#   CODE, (B"        ("#   CODE, (W"                     
  1      <-/#  CODE, -/                                             
  2      @A+#  CODE, @A+     @A#  CODE, @A                          
  3     C@A+#  CODE, C@A+                                           
  4        @#  CODE, @        !#  CODE, !                           
  5     C@T+#  CODE, C@+    @T+#  CODE, @+                          
  6      <DOS  CODE, (DOS                                           
  7                                                                 
  8     <0=    CODE, 0=      <1-  CODE, 1-     <2-  CODE, 2-        
  9                                                                 
 10        _IND RP!# RP@#  TRIO, RP                                 
 11  ?BIO_K <BIO_K <BIO_E  TRIO, BIO-K                              
 12  ?DOS_K <DOS_K <DOS_E  TRIO, DOS-K                              
 13                                                                 
 14                                                                 
 15                                                                 
Scr#     24
  0                                                                 
  1           SP!#  SP@#  DUO, SP                                   
  2       <TROFF  <TRONX  DUO, TRON                                 
  3           C!P#  C@P#  DUO, BPORT                                
  4             !P#  @P#  DUO, PORT                                 
  5                                                                 
  6       A!#  CODE, A!          A@#  CODE, A                       
  7       !A#  CODE, !A        C!R+#  CODE, C!R+                    
  8       @R#  CODE, @R         !R+#  CODE, !R+                     
  9      !A+#  CODE, !A+       C!A+#  CODE, C!A+                    
 10  <PERFORM  CODE, PERFORM    @R+#  CODE, @R+                     
 11                                                                 
 12 : C@ C@+ NIP ;    : ;DROP ;: DROP ;                             
 13 : C! A! C!A+ ;    : 0; IF ;THEN DROP POP DROP ;                 
 14                                                                 
 15                                                                 
Scr#     25
  0 ASM T-HEADER  EXIT     L: _EXIT     ;# DW,                      
  1     T-HEADER  IF(     L: _IF      IF# DW,                       
  2     T-HEADER  OF(     L: _OF      OF# DW,                       
  3     T-HEADER  JMP(    L: _JUMP  JUMP# DW,                       
  4     T-HEADER  -IF(    L: _-IF    -IF# DW,                       
  5     T-HEADER  LIT(     L: _LIT    @IP# DW,                      
  6     T-HEADER  NEXT(   L: _NEXT  NEXT# DW,                       
  7     T-HEADER  EXEC(   L: _EXEC  EXEC# DW,                       
  8     T-HEADER  PUSH     L: _PUSH RPUSH# DW,                      
  9     T-HEADER  DROP     L: _DROP  <DROP DW,                      
 10 END-CODE                                                        
 11             ' EXIT  <MAIN  DUO, NOP                             
 12 \ <% T-: NEWTC LIT LIT LIT [ ' [LIT] 2+ T-, ] T-! T-; %>        
 13           _LIT ' [LIT] 2+ T-!    \ VERI SPECIAL                 
 14                                                                 
 15                                                                 
Scr#     26
  0  ->TASK  T-VUSER >TASK    -<TASK T-VUSER <TASK                  
  1     >S0  T-VUSER S0         ->SP T-VUSER >SP                    
  2     >R0  T-VUSER R0       >FRAME T-VUSER FRAME                  
  3   >SELF  T-QUSER SELF       >HDR T-VUSER HDR                    
  4   >RPTR  T-VUSER RPTR       >TIB T-VUSER TIB                    
  5                                                                 
  6    >BASE T-VUSER BASE         >H T-QUSER HERE                   
  7     >OUT T-QUSER OUT>       >>IN T-VUSER >IN                    
  8     >BLK T-VUSER BLK       >SPAN T-VUSER SPAN                   
  9   >STATE T-VUSER STATE     >HOLD T-QUSER HOLD                   
 10     >SCR T-VUSER SCR        >CSP T-VUSER CSP                    
 11                                                                 
 12       >DBL T-VUSER DPL          >VLINK T-VUSER VLINK            
 13  >CONTEXT  T-VUSER CONTEXT    >CURRENT T-VUSER CURRENT          
 14                             >SCRH T-VUSER SCRH                  
 15                                                                 
Scr#     27
  0   0 T-VALUE MPTR    0 T-VALUE MTOP   0 T-QUAN SPTR              
  1   0 T-VALUE CFA                                                 
  2                       0 T-CONSTANT 0     1  T-CONSTANT 1        
  3  -1 T-CONSTANT -1    2  T-CONSTANT 2                            
  4                                                                 
  5   0  T-RVALUE ER_R   2  T-RVALUE AX_R   4  T-RVALUE BX_R        
  6   6  T-RVALUE CX_R   8  T-RVALUE DX_R                           
  7      _2+  CODE,  2+              _1+  CODE,  1+                 
  8 : 1+!@ @ 1+ DUP !A ;  : +!  @ + !A ;   : 1+! @ 1+ !A ;          
  9 : @1-! @ DUP 1- !A ;  : [! 2* A + ! ; : >! 1+!@ [! ;            
 10 : >BYTE 255 AND ;     : [@ 2* A + @ ; : C[! A + A! C!A+ ;       
 11 : '+C 1+!@ >BYTE C[! ;  : "+C 1+! @A+ C[! ;                     
 12 : ^@  @ [@ ;  : @< @1-! [@ ;  : C[@ A + A! @A >BYTE ;           
 13 : -1=  INV 0= ;  : = XOR 0= ;                                   
 14 : 0< -IF DUP XOR INV ;THEN DUP XOR ;  : < - 0< ;                
 15                                                                 
Scr#     28
  0   15 T-CONSTANT HMASK   16 T-CONSTANT 1H                        
  1  : RESULT PUSH DROP  A POP ;                                    
  2  : *M  A! 0 HMASK FOR +* NEXT RESULT ;                          
  3  : U?  DUP XOR DUP +? 1- ;   : U< - U? ;                        
  4  : WITHIN OVER - PUSH - POP U< ;                                
  5  : /MOD# PUSH SWAP A! POP HMASK FOR -/ NEXT RESULT ;            
  6  : /MOD 0 /MOD# ;  : MOD /MOD NIP ;  : / /MOD DROP ;            
  7  : D0 0 0 ;  \ IO KERNEL FUNCTIONS                              
  8  : D_ERR  ER_R -IF 4  ERROR  THEN DROP ;                        
  9  : DO_HANDLE PUSH  AT FHAND ^@ POP (DOS D_ERR ;                 
 10  : HFSIZE D0 $ 4202 DO_HANDLE ; : HCLOSE D0 $ 3E00 DO_HANDLE ;  
 11  : HREAD $ 3F00 DO_HANDLE ;     : HWRITE $ 4000 DO_HANDLE ;     
 12  : FOPEN  D0 $ 3D02 (DOS D_ERR ;                                
 13 : (HANDLE   EXECUTE AT FHAND @< DROP ;                          
 14 : >HANDLE   AT FHAND >! @R+ (HANDLE ;                           
 15                                                                 
Scr#     29
  0   1024  T-CONSTANT 1K      <DOES T-CONSTANT #DOES               
  1   ' BIO-K       T-VECTOR  EMIT                                  
  2   ' BIO-K 2+    T-VECTOR  KEY                                   
  3 : RESET-KEY [ ' BIO-K 2+ ] T-LITERAL TO KEY ;                   
  4   ' BIO-K 2+ 2+ T-VECTOR  ?KEY                                  
  5 : ?TYPE INV -IF INV IF 1- ;THEN THEN DROP DROP RDROP ;          
  6 : TYPE ?TYPE FOR C@+ EMIT NEXT DROP ;  : ID. C@+ 31 AND TYPE ;  
  7 : BLKPOS 1K *M $ 4200 DO_HANDLE ;                               
  8 : RBLK BLKPOS 1K HREAD ;  : WBLK BLKPOS 1K HWRITE ;             
  9 : ;S ;DROP AT FHAND @ IF [ ' HCLOSE ] T-LITERAL (HANDLE         
 10     1- IF ;THEN RESET-KEY THEN ;                                
 11 : F_KEY ;DROP 0 SP 1 HREAD AX_R IF DROP DUP 32 U<               
 12      IF 32 SWAP ;THEN ;THEN  ;S 13 SWAP ;      \ CHK EOF !!!    
 13 : F_EMIT SP 1 HWRITE DROP ;                                     
 14                                                                 
 15                                                                 
Scr#     30
  0 : CHARS ?TYPE FOR DUP EMIT NEXT DROP ; : SPACES 32 SWAP CHARS ; 
  1 : BACK 8 EMIT ; : SPACE 1 SPACES ;                              
  2 : DO-K 32 - -IF 19 + ( -CR) IF 5 + ( -BS) IF ( 0<>)   ;THEN     
  3   ( BS) INV PUSH PUSH IF 1- BACK SPACE  BACK THEN POP POP ;THEN 
  4   ( CR)  ;THEN  32 + A! PUSH OVER OVER + PUSH 1+ A DUP EMIT     
  5      POP  A!  C!A+  POP OVER OVER U< ;                          
  6 : EXPECT ?TYPE 1+ PUSH 0 POP BEGIN KEY 255 AND DO-K             
  7        IF DROP AGAIN THEN   DROP DROP ;                         
  8 : DIG?  C" A  -  -IF  7 +  INV -IF  ;THEN INV THEN  10 + ;      
  9 : -ROT SWAP PUSH SWAP POP ;                                     
 10 : /STR DUP A! + PUSH A - POP ;                                  
 11 : CONVERT IF BEGIN 1- PUSH C@+  SWAP PUSH  DIG? DUP BASE U<     
 12   -IF DROP -ROT BASE *M DROP PUSH BASE *M  A!                   
 13             + A POP +? POP POP IF AGAIN THEN  ;THEN             
 14          DROP DROP POP POP 1 /STR THEN ;                        
 15                                                                 
Scr#     31
  0 \              LIT"          (".             ".                 
  1 T-HEADER (" ] L: _"1 <JSR-3  L: _"2  <JSR-4  L: _"3 <JSR-4      
  2               (B" EXIT       (B"             C@+ TYPE  EXIT [   
  3 : BSRCH DUP PUSH PUSH A! BEGIN C@A+ OVER XOR IF DROP  NEXT      
  4          RDROP DUP XOR INV  ;THEN DROP DROP POP POP SWAP - ;    
  5 : HEX 16 TO BASE ; : DECIMAL 10 TO BASE ; : BINARY 2 TO BASE ;  
  6 : D+  PUSH A! PUSH A + POP POP +? ;                             
  7 : ROT PUSH SWAP POP SWAP ;  : ;ROT ;: ROT ;  : D0 0 0 ;         
  8 : DNEGATE A! INV 1 + A INV 0 +? ;  : 2SWAP PUSH -ROT POP -ROT ; 
  9 : ?NEG OVER C@ C" - = IF /STR IF ;: DNEGATE THEN ;THEN DROP ;   
 10 : ?HEX OVER C@ C" $ " !" = IF /STR IF POP  A! BASE PUSH A PUSH  
 11       16 TO BASE ;:      POP TO BASE THEN ;THEN DROP ;          
 12 : ?NUMBER ;ROT ?NEG ?HEX 0 TO DPL  D0 2SWAP CONVERT             
 13    BEGIN IF OVER C@ DUP C" : = SWAP  C" ,  C" 0  WITHIN OR      
 14    WHILE DUP TO DPL /STR CONVERT REPEAT DROP THEN NIP -ROT ;    
 15                                                                 
Scr#     32
  0 : MOVE SWAP A! ?TYPE FOR C@+ C!A+ NEXT DROP ;                   
  1 : FILL SWAP A! ?TYPE FOR DUP C!A+  NEXT DROP ;                  
  2 : #V INV 2* FRAME + ;   \ LOCAL VARIABLE ADDRESS                
  3 T-' #V  <@EXEC-1   0 NM: EXEC( ! ;M  1 NM: EXEC( @ ;M           
  4 T-HEADER LV T-, T-, T-, T-,                                     
  5 ' LV T-HEADER ORIG @+ T-, @+ T-, @+ T-, _ORIG T-, DROP          
  6 : LOCALS OVER OVER + 1+ A! POP FRAME PUSH RP TO FRAME A #V      
  7   DUP TO RP  A!  SWAP FOR !A+ 0 NEXT  SWAP  FOR !A+ NEXT ;:     
  8 L: 'RETURN       FRAME TO RP  POP  TO FRAME ;                   
  9 : SRCH DUP PUSH PUSH A! BEGIN @A+ OVER XOR   IF DROP  NEXT      
 10          RDROP DUP XOR INV  ;THEN DROP DROP POP POP SWAP - ;    
 11                                                                 
 12 MAC: SH 0 AT NBUFS 20 DUMP;                                     
 13                                                                 
 14                                                                 
 15                                                                 
Scr#     33
  0 ' LV T-HEADER NBUFS @+ T-, @+ T-, DROP <WARY T-, 32 T-ALLOT     
  1 3 T-VALUE #BUFS   #BUFS 1+ T-VALUE FBUFS    0 T-VALUE BUFP      
  2  #BUFS    T-VALUE USE  #BUFS T-VALUE PREV \ INDEX OF BUFFERS    
  3 : SRCH-B 0 AT NBUFS #BUFS SRCH ; : -BUFS 0 AT NBUFS 32 -1 FILL ;
  4   : +BUF #BUFS USE 1+ AND DUP TO USE ;                          
  5 : GETBUF +BUF PREV XOR IF USE EXIT THEN +BUF ; \ NOT LAST USED  
  6 : FBUF PREV FBUFS + AT NBUFS ; : DISCARD -1 FBUF ! ;            
  7 : ^BUF PREV 1K *M DROP BUFP + ;    : UPDATE 0 FBUF ! ;          
  8 : ?SAVE TO PREV FBUF @ IF DROP ;THEN DROP                       
  9                ^BUF PREV NBUFS SCRH >HANDLE WBLK DISCARD ;      
 10 : BUFFER -1 SRCH-B  -IF DROP GETBUF ?SAVE DROP PREV THEN        
 11      DUP TO PREV TO NBUFS ^BUF ;   \ REGISTER BLKNUM            
 12 : BLOCK DUP SRCH-B   -IF DROP BUFFER DUP PREV NBUFS SCRH        
 13      >HANDLE RBLK  ;THEN TO PREV DROP ^BUF ;                    
 14 : !BUFS #BUFS FOR AT RP ?SAVE NEXT ;  : FLUSH !BUFS -BUFS ;     
 15                                                                 
Scr#     34
  0 T-HEADER ?TIB <BLKASE T-, ] TIB TIB BLOCK [                     
  1 : WORD 1 HERE ! 255 AND A! HERE  SPAN >IN -                     
  2    IF 1- PUSH A BLK ?TIB >IN + A!                               
  3      BEGIN  C@A+ OVER XOR 0=                                    
  4        IF   DROP                                                
  5        NEXT   SPAN TO >IN DROP                                  
  6      ;THEN  DROP A 1- PUSH 0 HERE ! POP A!  \ INIT STRING       
  7      BEGIN  C@A+ OVER XOR                       \ INCRMENT      
  8        IF  OVER XOR  HERE A PUSH '+C  POP A!                    
  9        NEXT  SPAN TO >IN  DROP                                  
 10      ;THEN DROP SPAN POP INV + TO >IN                           
 11    THEN DROP ;                                                  
 12 : BLWORD 32 WORD C@+ TYPE ;                                     
 13                                                                 
 14                                                                 
 15                                                                 
Scr#     35
  0 : 0-DROP SKIP BEGIN DROP THEN UNTIL ;                           
  1 : #-1DROP SKIP BEGIN DROP THEN 1+ 0= UNTIL DROP ;               
  2 : =DROP SKIP BEGIN DROP THEN OVER XOR UNTIL OVER XOR ;          
  3 : FIND( PUSH   \ WHAT TO SEARCH  -  ADDRESS OF WORD             
  4     BEGIN 0-DROP  =DROP INV  WHILE  INV       \ -1  çÖ Ö ãà     
  5       BEGIN @ 128 AND -1 + DROP @A 32 AND     \ CARRY           
  6         C@A+ 31 AND SWAP 0=                                     
  7         IF DROP AT RP SWAP PUSH C@+ AT RP BEGIN                 
  8            XOR 1- -IF DROP C@+ C@A+ NEXT  C@A+ POP     \ FOUND  
  9            #-1DROP A 0 DUP +? 2* 1-  ;THEN DROP POP SWAP        
 10         THEN DROP A + @                                         
 11       WHILE REPEAT DROP                                         
 12     REPEAT DROP POP 0 ;  \ NOT FOUND                            
 13 : FIND PUSH -1  CONTEXT @ POP FIND( ;                           
 14                                                                 
 15                                                                 
Scr#     36
  0                                                                 
  1 KERNEL                                                          
  2                                                                 
  3 -BUFS                                                           
  4         PAD  60 - TO HERE                                       
  5         PAD  1K + TO BUFP                                       
  6         AT KERNEL TO CONTEXT                                    
  7         1K        TO SPAN                                       
  8         0         TO >IN                                        
  9 =" TEMP.SCR"                                                    
 10 PAD  C!                                                         
 11 PAD  C@+ MOVE                                                   
 12 0 PAD  '+C                                                      
 13 PAD 1+ FOPEN  AX_R TO SCRH                                      
 14     0 BLOCK TO TIB                                              
 15                                                                 
Scr#     37
  0 : FIND( PUSH   \ WHAT TO SEARCH  -  ADDRESS OF WORD             
  1     BEGIN 0-DROP  =DROP INV        \ -1  çÖ Ö ãà                
  2     WHILE  INV                                                  
  3       BEGIN @ 128 AND -1 + DROP @A 32 AND      \ CARRY          
  4         IF DROP C@A+ 31 AND ELSE DROP                           
  5            AT RP C@+ C@A 31 AND DUP                 \ FOUND     
  6            FOR XOR 1- -IF DROP C@+ C@A+ NEXT                    
  7                     @A+ POP 1-DROP AR 0 DUP +? 2* 1-            
  8                  ;THEN DROP POP                                 
  9         THEN AR + @                                             
 10       WHILE REPEAT DROP                                         
 11     REPEAT DROP POP 0 ;  \ NOT FOUND                            
 12                                                                 
 13 : FIND PUSH -1 ORDER# @+ IF 1- FOR @+ @ SWAP NEXT THEN          
 14         DROP CONTEXT @ POP  FIND( TO ?, ;                       
 15                                                                 
Scr#     38
  0 \ : PROBA  0 LOCALS  5 FOR AT RP #V @ . NEXT ;                  
  1 \ : PROBA2 0 LOCALS 0 LV . 1 LV . 2 LV . 3 LV . 4 LV . 5 LV . ; 
  2 \ T-VARIABLE PROBA  : #. AR PUSH 1 PROBA +!                     
  3 \        S. R. PROBA @ . KEY DROP POP TO AR ;                   
  4 \ <% T-: S. S. BLK . KEY DROP T-; %>                            
  5 : NPSH #. DUP TO AR  POP #. RP AR 2* -  #.                      
  6               DUP TO RP  TO AR    #.  PUSH                      
  7     1- #.  FOR !A+ #. NEXT #. ;                                 
  8 : NPOP  2+ DUP PUSH FOR RP AT RP 2* + @ NEXT  DROP ( 0)         
  9            RP 2* + TO RP PUSH ;                                 
 10 : ZPSH TO AR  POP RP AR 2* - DUP TO RP AR 1- PUSH TO AR         
 11       BEGIN 0 !A+ NEXT PUSH ;                                   
 12 : WCOMP  PUSH TO AR   BEGIN  @+ @A+ XOR                         
 13           IF DROP DUP XOR RDROP ;THEN DROP NEXT DUP XOR INV ;   
 14 : COMP  PUSH TO AR   BEGIN  C@+ C@A+ XOR                        
 15           IF DROP DUP XOR RDROP ;THEN DROP NEXT DUP XOR INV ;   
Scr#     39
  0  : USING FLUSH -USE FOPEN TO SCRH ;                             
  1  : LIST DUP TO SCR  BLOCK .BLOCK ;                              
  2  | : ?LD BLK 0= A" LOADING?" ;                                  
  3  : --> ?LD 0 TO >IN BLK 1+ TO BLK ; IMMEDIATE                   
  4  : COPY  SWAP BLOCK SWAP BLOCK 1K CMOVE UPDATE FLUSH ;          
  5  : THRU  1+ SWAP  DO I LOAD LOOP ;                              
  6  : +THRU BLK DUP D+ THRU ;                                      
  7  : -USE SCRH 1+ IF SCRH CLOSE DROP -1 TO SCRH THEN ;            
  8                                                                 
  9 \ : D1+ TO AR 1+ IF AR ;THEN AR 1+ ;                            
 10 \ : NUMBER ?NUMBER ROT ABORT" ?" ;                              
 11 T-VARIABLE PROBA                                                
 12 : #. CR 1 PROBA +!  DUP . PROBA @ . ;                           
 13         : FIND          : ABORT : ERROR                         
 14 : COMP PUSH TO AR BEGIN  OVER AT RP + C@ OVER AT RP + C@ =      
 15    IF DROP NEXT DROP DROP 0 ;THEN DROP DROP DROP POP INV ;      
Scr#     40
  0 \ 10 [[ 9 R@ - 10 * DUP 4 .R                                    
  1 \      9 [[ 9 R@ - OVER + 4 .R ]] CR ]]                         
  2 \ MAC: TEN # 10 ;                                               
  3 CR TEN [[ TEN R@ - TEN  [[ DUP TEN R@ - * 4 .R ]] DROP CR ]]    
  4 MAC: POP R> ;  MAC: PUSH >R ;                                   
  5 TO MAC: ! ;THEN EXIT THEN !                                     
  6 MAC: RDROP  AT DROP ;                                           
  7 : [[ POP >IN PUSH SWAP DUP IF 1- THEN PUSH PUSH ;               
  8 : ]] POP POP ?DUP IF 1- R@ TO >IN PUSH PUSH ;THEN RDROP PUSH ;  
  9 : ?CR -IF CR THEN ;                                             
 10 \ 256 [[ 255 R@ - 15 AND ?CR 255 R@ -  4 .R ]]                  
 11  10 [[ 9 R@ - 10 * DUP 4 .R                                     
 12       9 [[ 8 R@ - OVER + 4 .R ]] CR ]]                          
 13                                                                 
 14                                                                 
 15                                                                 
Scr#     41
  0 : M+ S>D D+ ;                                                   
  1 : B_ADR 2DUP 1K UM/MOD DROP BLOCK + PUSH 1 M+ POP ;             
  2 : BPEEK B_ADR C@ ;  : BPOKE PUSH B_ADR POP SWAP C! UPDATE ;     
  3 FUNC: BLKREAD ( NBYTEL NBYTEH ADDRS BYTES / NBLOCK REMAIN )     
  4    1K NBYTEL 1K 1- AND - BYTES MIN TO REMAIN                    
  5    NBYTEL NBYTEH 1K UM/MOD DROP NIP TO NBLOCK                   
  6   BEGIN BYTES WHILE                                             
  7    NBLOCK BLOCK NBYTEL 1K 1- AND + ADDRS REMAIN CMOVE           
  8    REMAIN  AT ADDRS +!      NBLOCK 1+ TO NBLOCK                 
  9    NBYTEL NBYTEH REMAIN M+ TO NBYTEH TO NBYTEL                  
 10    BYTES REMAIN - DUP TO BYTES 1K MIN TO REMAIN                 
 11   REPEAT  ;                                                     
 12 : HV ( BYTE POSITION IN SCR FILE ) M+ 2DUP  PAD 256             
 13    BLKREAD   PAD   256    DUMP ;  : SV 0 HV ;                   
 14 : PV -256 HV ;   : NV 256 HV ;                                  
 15                                                                 
Scr#     42
  0                                                                 
  1                                                                 
  2                                                                 
  3                                                                 
  4                                                                 
  5                                                                 
  6                                                                 
  7                                                                 
  8                                                                 
  9                                                                 
 10                                                                 
 11                                                                 
 12                                                                 
 13                                                                 
 14                                                                 
 15                                                                 