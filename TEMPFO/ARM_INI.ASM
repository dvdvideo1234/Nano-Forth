; arm_ini - 6/6/1995

;*******************************************************
;*          о▒новни па░аме▓░и на ArM                   *
;*            п░и а▒ембли░ане▓о м│                     *
;*******************************************************

pb  equ  byte   ptr
pw  equ  word   ptr
pd  equ  dword  ptr

; inc(dx:ax) инк░емен▓а╢и┐ на двойна д│ма

dwinc macro
     local ninc_dx
     inc     ax
     jne     ninc_dx
     inc     dx
ninc_dx:
     endm

untofs       =  16

prvdem_unt   =  0       ; обла▒▓  п░еди╕на п░азна
prvdom_unt   =  1       ; обла▒▓  п░еди╕на п║лна
nxtdem_unt   =  2       ; обла▒▓  ▒ледва╣а п░азна
nxtdom_unt   =  3       ; обла▒▓  ▒ледва╣а п║лна
prvemp_unt   =  4       ; елемен▓ п░еди╕ен п░азен
prvelm_unt   =  5       ; елемен▓ п░еди╕ен п║лен
nxtemp_unt   =  6       ; елемен▓ ▒ледва╣  п░азен
nxtelm_unt   =  7       ; елемен▓ ▒ледва╣  п║лен


; ┤│нк╢ии к║м доп║лни▓елен ╛ни▓  (ARM_Unit)

status_unt   =   0+untofs  ;get_status
archiv_unt   =   1+untofs  ;assignarchive
arch_unt     =   2+untofs  ;assignarch
makedsc_unt  =   3+untofs  ;make_dsc
filenum_unt  =   4+untofs  ;file_num?
flabels_unt  =   5+untofs  ;all_files_info
readel_unt   =   6+untofs  ;readelm
writel_unt   =   7+untofs  ;writelm
bscan_unt    =   8+untofs  ;byte_scan
wscan_unt    =   9+untofs  ;word_scan
bfill_unt    =  10+untofs  ;byte_fill
wfill_unt    =  11+untofs  ;word_fill
getlen_unt   =  12+untofs  ;getlen1
setlen_unt   =  13+untofs  ;setlen1
memdwn_unt   =  14+untofs  ;
memup_unt    =  15+untofs  ;
memswp_unt   =  16+untofs  ;
memcmp_unt   =  17+untofs  ;
defdom1_unt  =  18+untofs  ;
mergedom_unt =  19+untofs  ;
upcase_unt   =  20+untofs  ; upcase memory
defdom2_unt  =  21+untofs  ;
insel_unt    =  22+untofs
sarchive_unt =  23+untofs
sarch_unt    =  24+untofs
cntbit_unt   =  25+untofs
aflags_unt   =  26+untofs

; кодове на ┤│нк╢ии▓е
;
present_cod  =  0       ; ArM present ?
instal_cod   =  1       ; instals into UNIT some points
quit_cod     =  2       ; quits ArM
open_cod     =  3       ; assign archive
lmove_cod    =  4       ; move long block of memory
read_cod     =  5       ; read from archive
write_cod    =  6       ; overwrite on the archive
copy_cod     =  7       ; from arch to arch
rdblk_cod    =  8       ; block operation
wrblk_cod    =  9       ; block operation
defdom_cod   =  10      ; create / change / copy domain  command
prvnxt_cod   =  11      ; multifuncs entry
INSERT_COD   =  12      ; inserts or appends to element from memory
ICOPY_COD    =  13      ; inserts or appends to element from archive
gpath_cod    =  14      ; full path of the file_name
setlen_cod   =  15      ; get set len
copydom_cod  =  16      ; element by element copy (insert) (interval copy)
arcopy_cod   =  17      ; (rectangular copy)
info_cod     =  18      ; (get info of the archive)
lread_cod    =  19      ; 4-bytes read from archive
movel_cod    =  20      ; move element in same domain (change number of el.)
armst_cod    =  21      ; arm_state
share_cod    =  22      ; share_state
commit_cod   =  23      ; commit file
Rmulty_cod   =  24      ; read multiple
Wmulty_cod   =  25      ; write multiple
dlock_cod    =  26      ; domain lock
alock_cod    =  27      ; archive lock

id_sender1   =  0
id_sender2   =  3
id_buffer    =  2
id_receiver  =  1


; ░азп░еделение на о▓ме▒▓вани┐▓а в ▒▓░│к▓│░а▓а ▒пи▒║к (о▓ б│┤е░и)
; next_itemp  о▓ме▒▓ване в ▒егмен▓а о▓ данни на ▒ледва╣  елемен▓
; prev_itemp  о▓ме▒▓ване в ▒егмен▓а о▓ данни на п░еди╕ен елемен▓
; item_key    кл╛╖ на елемен▓а 4-бай▓ов
; bdata       данни  (на б│┤е░а)
; u_flag      ┤лаг за п░оменен б│┤е░

u_flag       = -9 ;  { if data was changed}
next_itemp   =  -8 ;  { pointer to next_itemfer}
prev_itemp   =  -6 ;  pointer to previous buffer
item_key     =  -4 ;  { number label of block}
bdata        =   0 ;  : array[1..blk_len] of byte;

free_listp  = 4

; ░азп░еделение на о▓ме▒▓вани┐▓а в ▒▓░│к▓│░а▓а ▒пи▒║к (о▓ б│┤е░и)
;f_rec   record
handle       = -10
next_filep   = next_itemp
prev_filep   = prev_itemp
el_app       = item_key       ; element in application
appl         = item_key+2     ; application number in sys file
first_bufp   = bdata    ; pointer to first buffer of the file
last_bufp    = bdata+2  ; pointer to last buffer of the file
read_vect    = 04       ; procedure whitch reads a block
write_vect   = 08       ; procedure whitch writes a block
first_free   = 12       ;
end_ofs      = 16
end_blk      = 18  ; blocks  possible are 2^23
last_time    = 22  ; longint timer tick
name_vect    = 26       ; address of driver or name of the file
dom_root     = 30       ; word ptr to dombufs list
frec_siz     = dom_root+2-handle  ; file record size = 30 bytes
ufrec_siz    = 0-handle

; кон▒▓ан▓и
max_bufn     = 128
max_filn     = 32
stack_gap    = 256;
stack_size   = 900h
blk_len      = 512;
buf_len      = blk_len+ufrec_siz;
name_size    = 90;
drv_type     = 1
my_int       = 02Fh          ; номе░ на п░ек║▒ване▓о
version      = 70h           ; ▓ек│╣а ве░▒и┐
;my_process   = 0f1h          ; номе░ на п░о╢е▒а

last_itemp   = last_bufp
first_itemp  = first_bufp


parm_x       =  4
parm_y       =  8
parm_o       = 12

dword1       =  16
dword2       =  dword1-4
dword3       =  dword2-4

; кодове на г░е╕ки      и ▒║об╣ени┐
;
ill_function =  1       ; невалиден номе░ на ┤│нк╢и┐ или под┤│нк╢и┐
stack_full   =  2       ; п║лен в║▓░е╕ен ▒▓ек
non_removable=  3       ; п░оменени ▒а век▓о░и▓е на п░ек║▒ване - INT 2F
index_err    =  4       ; г░е╕ка в д║░во▓о-индек▒{невалиден номе░ на блок}
too_many_fil =  5       ; ▓в║░де много неав▓ома▓и╖ни ┤айлове
num_too_big  =  6       ; ▓в║░де гол┐мо ╖и▒ло
no_auto      =  7       ; не ▒а ав▓ома▓и╖ни а░╡иви
not_arm_arch =  8       ; не е ArM- а░╡ив
ArM_busy     =  9       ; ArM-║▓ е зае▓ (нап░авен е опи▓ за пов▓о░но влизане)
no_buffs     =  10      ; н┐ма ▒вободни б│┤е░и (г░е╕ка в паме▓▓а)
path_not_full=  11      ; п║▓┐▓ не е п║лен до а░╡ив
duplicates   =  12      ; опи▓ за ░або▓а п░и д░│ги коо░дина▓и
mismatch_dom =  13      ; обла▒▓▓а п░иемник е подмноже▒▓во на и▒▓о╖ника
;-------   г░е╕ки дадена о▓ п░о╢ед│░и▓е за ╖е▓ене и запи▒
uncompl      =  14      ; неп║лен запи▒ на блок  {п║лен ди▒к може би?}
file_shared  =  15      ; а░╡ив║▓ е ░аз░е╕ен ▒амо за ╖е▓ене
arch_locked  =  16      ; а░╡ив║▓ е закл╛╖ен
dom_locked   =  17      ; обла▒▓▓а е закл╛╖ена
arm_err      =  256     ; добав┐ ▒е за пол│╖аване на п║лни┐ набо░ г░е╕ки

