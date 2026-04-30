Plan: Build a Forth Parser on top of Nano-Forth

     Context

     itsy.asm has a working kernel with primitives and a basic INTERPRET loop, but the outer interpreter is incomplete:
     - No negative number parsing (-10 triggers ABORT)
     - No base-prefix numbers ($FF, %1010)
     - No comments (( and \ undefined)
     - No base-switching words (HEX, DECIMAL)
     - No string output (TYPE, .()
     - Error just ABORTs with no message
     - Several primitives needed for Forth-level parser code are missing (c@, -, and, over, >r, r>, etc.)

     Goal: Add ~10 small primitives to itsy.asm, then write a PARSER.SCR screen file that defines the full text interpreter in Forth.

     ---
     Step 1 — Add Primitives to itsy.asm

     Where: Insert between line 371 (constant definition ends) and line 376 (final: label).
     The final: label must remain at the interpret colon word header — it seeds variable 'last',last,final.

     Note: The primitive macro chains dictionary links in assembly order; inserting before final: correctly puts new entries into the linked list.

     ; -----------------------
     ; Parser Extension Primitives
     ; -----------------------

             primitive 'negate',negate
             neg bx
             jmp next

             primitive '-',minus
             pop ax
             sub ax,bx
             xchg ax,bx
             jmp next

             primitive 'and',and_op
             pop ax
             and bx,ax
             jmp next

             primitive 'or',or_op
             pop ax
             or bx,ax
             jmp next

             primitive '0<',zero_less
             xchg ax,bx          ; move TOS to AX for CWD
             cwd                  ; sign-extend AX into DX
             xchg bx,dx           ; BX = 0xFFFF (-1) if negative, 0 if not
             jmp next

             primitive 'c@',c_fetch
             mov bl,byte[bx]
             mov bh,0
             jmp next

             primitive 'c!',c_store
             pop ax
             mov byte[bx],al
             pop bx
             jmp next

             primitive 'over',over
             push bx
             mov bx,word[sp+2]    ; second item (after push, sp moved by 2)
             jmp next

             primitive '>r',to_r
             dec bp
             dec bp
             mov word[bp],bx
             pop bx
             jmp next

             primitive 'r>',r_from
             push bx
             mov bx,word[bp]
             inc bp
             inc bp
             jmp next

             variable "'interpret",tick_interpret,xt_interpret+2

     Also patch abort (line 34): replace the hardcoded interpreter jump with the new vector:

     ; old:  mov si,xt_interpret+2
             mov si,word[val_tick_interpret]   ; use vector so Forth can replace interpret

     xt_interpret+2 is a valid forward reference for TASM (2-pass). The variable initialises to the kernel interpret's thread start address.

     ---
     Step 2 — Create mini/PARSER.SCR (4 screens × 1024 bytes)

     Classic Forth block format: 16 lines × 64 chars, space-padded, NO line terminators.

     Screen 0 — Bootstrap: Compilation Helpers + Arithmetic

     These words MUST come first because later screens use if/then/else.

     ( PARSER.SCR  scr 0 - bootstrap                 )
     : here  dp @ ;
     : [']   32 word find drop ; immediate
     : if    ['] 0branch ,  here  0 , ; immediate
     : then  here swap ! ; immediate
     : else  ['] branch ,  here  0 ,  swap here swap ! ; immediate
     : begin  here ; immediate
     : until  ['] 0branch , ; immediate
     : again  ['] branch  , ; immediate
     : 1+  1 + ;
     : 1-  1 - ;
     : 2dup  over over ;
     : nip   swap drop ;
     : 0=  0 = ;
     : 0>  negate 0< ;
     : <   - 0< ;
     : >   swap < ;
     : max  2dup < if swap then drop ;
     : min  2dup > if swap then drop ;
     : ?dup  dup if dup then ;
     : +!  dup @ rot + swap ! ;
     : true  -1 ;
     : false  0 ;
     : cr  13 emit  10 emit ;
     : space  32 emit ;
     : bl  32 ;

     Screen 1 — Number Parsing: NUMBER?

     NUMBER? wraps the kernel >number primitive and adds:
     - Leading - sign handling
     - Single-char base prefix: $=hex, %=binary, #=decimal

     ( PARSER.SCR  scr 1 - number parsing            )
     variable #sign   variable #base2
     : +str  swap 1+ swap 1- ;    ( advance c-addr/len by 1 )
     : sign?   over c@ 45 = ;     ( '-' = 45 )
     : pfx?    over c@             ( base-prefix char? )
         dup 36 = if drop 16 true exit then   ( $ hex )
         dup 37 = if drop  2 true exit then   ( % binary )
         dup 35 = if drop 10 true exit then   ( # decimal )
         drop false ;
     : number? ( addr -- n true | addr false )
         dup >r
         count                    ( c-addr len )
         dup 0= if drop r> false exit then
         false #sign !
         sign? if  true #sign !  +str  dup 0= if drop r> false exit then  then
         pfx? if  base @ #base2 !  base !  +str
                   dup 0= if #base2 @ base !  drop r> false  exit then
              else  0 #base2 !  then
         0 0 rot rot              ( ud_lo=0 ud_hi=0 c-addr len )
         >number                  ( ud_lo ud_hi c-addr' len' )
         0= if                    ( len'=0: full parse )
             drop drop drop       ( -- ud_lo )
             #sign @ if negate then
             #base2 @ if #base2 @ base ! then
             r> drop  true
         else
             drop drop drop drop
             #base2 @ if #base2 @ base ! then
             r>  false
         then ;

     Screen 2 — Output Words + Comments

     ( PARSER.SCR  scr 2 - output + comments         )
     : type ( c-addr n -- )
         begin dup while
             over c@ emit  swap 1+ swap 1-
         repeat  drop drop ;
     : .( ( print to ) )
         41 word  count  type ; immediate
     : (   41 word drop ; immediate
     : \   #tib @ >in ! ; immediate
     : hex      16 base ! ;
     : decimal  10 base ! ;
     : binary    2 base ! ;
     : octal     8 base ! ;
     : char  32 word  count drop  c@ ;
     : [char]  char  ['] lit ,  , ; immediate

     Key insight: 41 WORD DROP for ( works for any multi-word comment — WORD with delimiter ) scans forward through the TIB to the next ) and advances >in past it.

     Screen 3 — New INTERPRET + Setup

     The new interpret extends the kernel version: uses NUMBER? instead of raw >NUMBER, prints the unknown token before ABORTing, and increases line length to 80.

     ( PARSER.SCR  scr 3 - new interpret             )
     : .err  ( c-addr n -- )
         34 emit  type  34 emit  [char] ?  emit  cr ;
     : interpret
         begin
             #tib @ >in @ = if
                 tib 80 accept  #tib !  0 >in !
             then
             32 word
             find dup if
                 state @ = if , else execute then
             else
                 drop
                 number? if
                     state @ if  ['] lit ,  ,  then
                 else
                     count .err  abort
                 then
             then
         again ;
     : setup   ['] interpret  2+  'interpret ! ;
     setup

     ['] interpret 2+ gets the XT of the new interpret and adds 2 to skip past the code field to the thread body — this is what si must point to when entering a colon word.

     ---
     Step 3 — Loading Sequence

     After assembling and running the new itsy.com, load the parser at the Forth prompt:

     1 LOAD   ( bootstrap: if/then/else, arithmetic, control flow )
     2 LOAD   ( number parsing: NUMBER? )
     3 LOAD   ( output, comments )
     4 LOAD   ( new interpret + setup )

     Or if THRU is available: 1 4 THRU

     After 4 LOAD, setup runs automatically, wiring the new interpret into the 'interpret vector so ABORT resets into the new interpreter.

     ---
     Critical Files

     ┌─────────────────┬──────────────────────────────────────────────────────────────────────────────────────────┐
     │      File       │                                          Change                                          │
     ├─────────────────┼──────────────────────────────────────────────────────────────────────────────────────────┤
     │ itsy.asm        │ Insert 10 primitives + 'interpret variable before final: (line 376); patch abort line 34 │
     ├─────────────────┼──────────────────────────────────────────────────────────────────────────────────────────┤
     │ mini/PARSER.SCR │ New file, 4 × 1024 bytes                                                                 │
     └─────────────────┴──────────────────────────────────────────────────────────────────────────────────────────┘

     ---
     Verification

     \ After 1 4 THRU:
     5 3 - .          \ expect: 2
     -10 .            \ expect: -10  (sign parsing)
     $FF .            \ expect: 255  (hex prefix)
     %1010 .          \ expect: 10   (binary prefix)
     hex  FF .        \ expect: 255  (base switch)
     decimal
     ( this is a comment ) 1 2 + .   \ expect: 3
     BADWORD          \ expect: "BADWORD" ? then abort (not silent crash)

