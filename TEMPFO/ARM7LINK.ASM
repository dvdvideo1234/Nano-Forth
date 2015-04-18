data segment 'DATA'
     assume  ds: data
my_func1     db         0 ; process number
my_func      db         0 ; process number
data ends

code segment 'CODE'
     assume  cs: code

     include arm_ini.asm

     public  shell
shell        proc far
_shell:
     push    ds
     push    bp
     mov     dx,ss
     mov     bp,sp
     lea     ax,[bp-4]
     cli
     xchg    dx,pw cs:old_ss    ; save old vars to stack
     xchg    ax,pw cs:old_sp    ;
     push    dx                 ;
     push    ax                 ;
     sti
     xor     bx,bx
     lds     si,[bp+8]
     mov     bl,[si]
     lea     cx,[bx+4]  ; ¯°¨£®²¢¿­¥  ­  CX = ¤º«¦¨­ ²  + 4
     and     cl,0feh    ; ¯®¤° ¢­¿¢ ­¥ ¯® ·¥²¥­  ¤°¥±
     sub     sp,cx      ; § ¤¥«¿­¥ ­  ¬¿±²® ¢ ±²¥ª  §  ¯ ° ¬¥²°¨²¥
     lea     cx,[bx+1]  ; °¥ «­  ¤º«¦¨­  ­  ¯ ° ¬¥²°¨²¥
     cld
     mov     ax,ss      ; copy line to stack
     mov     di,sp
     mov     es,ax
     rep     movsb
     mov     ds,ax
     mov     al,13      ; CR to end of line
     stosb
     mov     si,sp      ; DS:si points to line

     int     2eh        ; dos line executor
     cli
     mov     ax,0
old_ss       =  $-2     ; restore ss:sp
     mov     ss,ax      ;
     mov     sp,0       ;
old_sp       =  $-2     ;
     pop     pw cs:old_sp       ;
     pop     pw cs:old_ss       ;
     sti
     mov     ah,4dh     ;
     int     21h        ; dos extended Error number
     pop     bp
     pop     ds
     ret     4
shell  endp

my_proc     label   near
     mov     al,present_cod
my_int_proc     label   near
     mov     ah,my_func
     int     2fh
     ret
;------------------------------------------------
     public  present
present         proc       far
     mov     ax,0f100h
     mov     pw my_func1,ax
_prsnt2:
     clc
     call    my_proc
;    jnc     _prsnt
     jc      _prsnt3
     mov     ah,my_func
     or      al,my_func1
     jne     _prsnt
     mov     my_func1,ah
     jmp     short _prsnt

_prsnt3:
     inc     di
     jne     _prsnt
     inc     ax
     jne     _prsnt
     mov     ax,es
     cmp     si,ax
     jne     _prsnt
     mov     dx,cx
     jmp     short  _present
_prsnt:
     add     my_func,8
     jnc     _prsnt2
     mov     ah,my_func1
     mov     my_func,ah
not_installed:
not_present:
     mov     al,0
     ret
present         endp

     public  connect
connect      proc       far
     call    my_proc
     or      al,al
     je      not_installed
     mov     si,cs      ; addresses in code segment
     mov     es,si
     mov     bx,offset  arm_ptr
     mov     di,offset unit_eptr
     mov     al,instal_cod
     call    my_int_proc
_present:
     mov     al,1
     ret
connect      endp

     public  quit_arm
quit_arm     proc       far
     call    my_proc
     or      al,al
     je      not_installed
     mov     al,quit_cod
     call    my_int_proc
     jc      not_present    ; on top
     mov     es,ax
     mov     ah,49h
     int     21h
     jc      not_present
     jmp     short  _present
quit_arm     endp

;-------------------------------------
     public   savearm
savearm      proc       far
     pop      cx
     pop      dx
     pop      ax        ; 1¢¨ ¯ ° ¬¥²º°
     pop      bx
     sub      sp,4      ; ¯°®¯³±ª ­¥ ­  ¯ ° ¬¥²º°
     push     bx
     push     ax        ; ¯ ° ¬¥²º°
     sub      sp,4      ; ¯°®¯³±ª ­¥ ­  ¯ ° ¬¥²º°
     push     dx
     push     cx
     mov      al,armst_cod
     jmp      func_adr
savearm      endp

     public   archstate
archstate    proc       far
     pop      cx
     pop      dx
     sub      sp,8      ; ¯°®¯³±ª ­¥ ­  ¤¢  ¯ ° ¬¥²º° 
     push     dx
     push     cx
     mov      al,share_cod
     jmp      func_adr
archstate    endp

;---------------------------
     public  nextelement
nextelement      proc    far
     mov     al,nxtelm_unt+8
     jmp     short stat_adr
nextelement      endp

     public  prevelement
prevelement      proc    far
     mov     al,prvelm_unt+8
     jmp     short stat_adr
prevelement      endp

     public  nextemptyelement
nextemptyelement      proc    far
     mov     al,nxtemp_unt+8
     jmp     short stat_adr
nextemptyelement      endp

     public  prevemptyelement
prevemptyelement      proc    far
     mov     al,prvemp_unt+8
     jmp     short stat_adr
prevemptyelement  endp

     public  nextdomain
nextdomain      proc    far
     mov     al,nxtdom_unt+8
     jmp     short stat_adr
nextdomain      endp

     public  prevdomain
prevdomain      proc    far
     mov     al,prvdom_unt+8
     jmp     short stat_adr
prevdomain      endp

     public  nextemptydomain
nextemptydomain      proc    far
     mov     al,nxtdem_unt+8
     jmp     short stat_adr
nextemptydomain      endp

     public  prevemptydomain
prevemptydomain      proc    far
     mov     al,prvdem_unt+8
     jmp     short stat_adr
prevemptydomain      endp

     public  nextel
nextel      proc    far
     mov     al,nxtelm_unt
     jmp     short stat_adr
nextel      endp

     public  prevel
prevel      proc    far
     mov     al,prvelm_unt
     jmp     short stat_adr
prevel      endp

     public  nextemptyel
nextemptyel      proc    far
     mov     al,nxtemp_unt
     jmp     short stat_adr
nextemptyel      endp

     public  prevemptyel
prevemptyel      proc    far
     mov     al,prvemp_unt
     jmp     short stat_adr
prevemptyel  endp

     public  nextdom
nextdom      proc    far
     mov     al,nxtdom_unt
     jmp     short stat_adr
nextdom      endp

     public  prevdom
prevdom      proc    far
     mov     al,prvdom_unt
     jmp     short stat_adr
prevdom      endp

     public  nextemptydom
nextemptydom      proc    far
     mov     al,nxtdem_unt
     jmp     short stat_adr
nextemptydom      endp

     public  prevemptydom
prevemptydom      proc    far
     mov     al,prvdem_unt
     jmp     short stat_adr
prevemptydom      endp

     public  sharearchive
sharearchive    proc       far
     mov     al,sarch_unt
     jmp     short stat_adr
sharearchive    endp

;---------------------------
     public   sharearch
sharearch    proc       far
     mov      al,sarchive_unt
     jmp      short stat_adr
sharearch    endp

;---------------------------

     public   assignarchive
assignarchive    proc       far
     mov      al,arch_unt
     jmp      short stat_adr
assignarchive    endp

     public   assignarch
assignarch    proc       far
     mov      al,archiv_unt
     jmp      short stat_adr
assignarch    endp

     public   fillbyte
fillbyte      proc       far
     mov      al,bfill_unt
     jmp      short stat_adr
fillbyte      endp

     public  scanbyte
scanbyte    proc       far
     mov     al,bscan_unt
     jmp     short stat_adr
scanbyte    endp

     public  scanword
scanword    proc       far
     mov     al,wscan_unt
     jmp     short stat_adr
scanword    endp

     public  upcaser
upcaser    proc       far
     mov     al,upcase_unt
     jmp     short stat_adr
upcaser    endp

     public  makedsc
makedsc    proc       far
     mov     al,makedsc_unt
     jmp     short stat_adr
makedsc    endp

     public  filenum
filenum    proc       far
     mov     al,filenum_unt
     jmp     short stat_adr
filenum    endp

     public  flabels
flabels    proc       far
     mov     al,flabels_unt
     jmp     short stat_adr
flabels    endp

     public  getlength
getlength proc  far
     mov     al,getlen_unt
     jmp     short  stat_adr
getlength endp

     public  setlength
setlength proc  far
     mov     al,setlen_unt
     jmp     short  stat_adr
setlength endp

     public  fillword
fillword    proc       far
     mov     al,wfill_unt
     jmp     short stat_adr
fillword    endp

     public  longstat
longstat     proc       far
     public  status
status       proc       far
     mov     al,status_unt
status       endp
longstat     endp

stat_adr:
     mov     ah,my_func
;    jmp     [unit_eptr]
     db      0eah
unit_eptr    dd         0

     public  Count_bits
Count_bits        proc       far
     mov     al,cntbit_unt
     jmp     short stat_adr
Count_bits        endp

     public  arm_flags
arm_flags         proc       far
     mov     al,aflags_unt
     jmp     short stat_adr
arm_flags         endp

     public  overelement
overelement       proc       far
     mov     al,writel_unt
     jmp     short stat_adr
overelement       endp

     public  readelement
readelement       proc       far
     mov     al,readel_unt
     jmp     short stat_adr
readelement       endp

     public  movedown
movedown     proc       far
     mov     al,memdwn_unt
     jmp     short stat_adr
movedown     endp

     public  swapmem
swapmem      proc       far
     mov     al,memswp_unt
     jmp     short stat_adr
swapmem      endp

     public  compmem
compmem      proc       far
     mov     al,memup_unt
     jmp     short stat_adr
compmem      endp

     public  moveup
moveup       proc       far
     mov     al,memup_unt
     jmp     short stat_adr
moveup       endp

     public  lmove
lmove        proc       far
     mov     al,lmove_cod
     jmp     short  func_adr
lmove        endp

     public  overcopyel
overcopyel  proc       far

     mov     al,copy_cod
     jmp     short  func_adr
overcopyel  endp

     public  overel
overel  proc       far
     mov     al,write_cod
     jmp     short  func_adr
overel  endp

     public  readel
readel  proc       far
     mov     al,read_cod
     jmp     short  func_adr
readel  endp

     public  insertel
insertel  proc       far
     mov     al,insert_cod
     jmp     short  func_adr
insertel  endp

     public  inscopyel
inscopyel  proc       far
     mov     al,icopy_cod
     jmp     short  func_adr
inscopyel  endp

     public  full_name
full_name  proc       far
     mov     al,gpath_cod
     jmp     short  func_adr
full_name  endp

     public  arm_func
arm_func     proc       far
     pop     cx
     pop     dx
     pop     ax
     push    dx
     push    cx
;    xor     ah,ah      no emulation  of  the arm_super_func
;    db      0b9h       ; mov cx,#
arm_func     endp

func_adr:
     mov     ah,my_func
;    jmp     [arm_ptr]
     db      0eah
arm_ptr      dd         0

     public  setlen
setlen proc  far
     mov     al,setlen_cod
     jmp     short  func_adr
setlen endp

     public  archive7
archive7     proc  far
     mov     al,open_cod
     jmp     short  func_adr
archive7     endp

     public  info_arch
info_arch  proc       far
     mov     al,info_cod
     jmp     short  func_adr
info_arch  endp

     public  definedomain
definedomain  proc       far
     mov     al,defdom2_unt
     jmp     short  stat_adr
definedomain  endp

     public  defdomain
defdomain  proc       far
     mov     al,defdom1_unt
     jmp     short  stat_adr
defdomain  endp

     public  insertelement
insertelement  proc       far
     mov     al,insel_unt
     jmp     short  stat_adr
insertelement  endp

     public  defdom
defdom  proc       far
     mov     al,defdom_cod
     jmp     short  func_adr
defdom  endp

     public  wblock
wblock  proc       far
     mov     al,wrblk_cod
     jmp     short  func_adr
wblock  endp

     public  rblock
rblock  proc       far
     mov     al,rdblk_cod
     jmp     short  func_adr
rblock  endp

     public  lockdom
lockdom proc       far
     mov     al,dlock_cod
     jmp     short  func_adr
lockdom endp

     public  lockarch
lockarch proc       far
     mov     al,alock_cod
     jmp     short  func_adr
lockarch endp

     public  multyRead
multyRead proc       far
     mov     al,rmulty_cod
     jmp     short  func_adr
multyRead endp

     public  multyWrite
multyWrite proc       far
     mov     al,wmulty_cod
     jmp     short  func_adr
multyWrite endp

     public  movelem
movelem  proc       far
     mov     al,movel_cod
     jmp     short  func_adr
movelem  endp

     public  lread
lread  proc       far
     mov     al,lread_cod
     jmp     short  func_adr
lread  endp

     public  commit
commit proc       far
     mov     al,commit_cod
     jmp     short  func_adr
commit endp

code ends
     end
