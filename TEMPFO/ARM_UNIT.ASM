; 16.3.1996 arm_unit   │ле▒нени┐ за в░║зка ▒ Па▒кал-╛ни▓а
;
; добавени - share_arch,  share_archive
;
; добавени - count_bits,  arm_flags
;


unitable     dw      get_status ;0  16
     dw      assignarchive    ;
     dw      assignarch       ;
     dw      make_dsc         ;
     dw      file_num?        ;
     dw      all_files_info   ;  5  21
     dw      readelm          ;
     dw      writelm          ;
     dw      byte_scan        ;
     dw      word_scan        ;
     dw      byte_fill        ; 10  26
     dw      word_fill        ;
     dw      getlen1          ;
     dw      setlen1          ;
     dw      movemem_dn       ;
     dw      movemem_up       ; 15  31
     dw      swapmem          ; 16 32
     dw      compare_mem      ;
     dw      defdom1          ;
     dw      mergedomf        ;
     dw      upcase_it        ; 20  36
     dw      defdom2          ; with parametters
     dw      insrtelm         ;
     dw      share_archive    ;23
     dw      share_arch       ;24
     dw      count_bits       ;25   41
     dw      ArM_Flags        ;26
unisize      = $-unitable     ;

Arm_Flags    proc       far
     mov     di,sp
     pushf
     cli
     les     ax,ss:[di+4]
     xor     pw cs:a_flags,ax
     mov     ax,es
     xor     pw cs:a_flags+2,ax
     les     ax,cs:a_flags
     mov     dx,es
     popf
     ret     4
Arm_Flags    endp


; п░еб░о┐ване на би▓ове▓е в едини╢а в обла▒▓ о▓ паме▓▓а
;
;     ds:si  ад░е▒ на б│┤е░
;     cx     ░азме░ на б│┤е░а в бай▓ове
;     dx:di  б░о┐╖ п░еди повикване
;
;     dx:ax  б░о┐╖а ▒лед повикване

count_free:
     shr     cx,1
     jnc     cnt_lp
     lodsb
     xor     ah,ah
     inc     cx
     db      03ch       ;cmp al,#
cnt_lp:
     lodsw
     jmp     short cnt_lp2
cnt_lp1:
     inc     di
     jnz     cnt_lp2
     inc     dx
cnt_lp2:
     shr     ax,1
     jc      cnt_lp1
     jne     cnt_lp2
     loop    cnt_lp
     xchg    ax,di
     ret



share_arch:
     stc
assignarch:
     pop     cx
     pop     dx
     jmp     short  arch_func

share_archive:
     stc
assignarchive:
     pop     cx
     pop     dx
     pop     bx         ; descr addr
     pop     es         ;
     les     di,es:[bx] ; file label
     push    es
     push    di

arch_func:
     mov     bx,bp
     mov     bp,sp
     les     di,[bp+4]  ;file_name pointer - Pascal
     inc     pw [bp+4]  ; first char
     mov     bp,bx
     mov     bx,0       ; bh := 0
     rcl     bx,1       ; BL := share_flag
     push    bx
     mov     bl,es:[di]
     push    bx
     mov     al,open_cod
     jmp     short do_arm

setlen1:
     db      0b9h       ;mov cx,

getlen1:
     xor     cx,cx
     pop     di
     pop     dx
     or      cx,cx
     jnz     setlength
     dec     cx
     mov     es,cx
     db      03dh       ;cmp ax,
setlength:
     pop     cx
     pop     es

     mov     bx,sp
     push    dx         ;return address
     push    di

     mov     al,setlen_cod
     push    ss         ;descr addr
     push    bx
     sub     sp,4       ; place reserved for unused parametter
     push    es         ; new length
     push    cx
     push    cs
     call    intro
     retf    12

unit_funcs:
     mov     ah,pb cs:my_process
unit_funcz:
     xor     bh,bh
     sub     al,16
     jb      uni_prevn
     mov     bl,al
     shl     bx,1
     jmp     pw CS:uniTABLE[BX]

param_pr_nx:
     mov     di,sp
     xchg    al,bl
     test    al,4       ; element function
     jne     pr_nx2     ; yes
     push    dx         ; duplicate return
     push    cx         ; address if domain functions
pr_nx2:
     push    dx         ; push return address
     push    cx

     push    ss         ; descriptor address of the domain/element
     push    di
     push    cs         ; extend to far pointer
     call    unit_funcz
     retf    12

uni_prevn:              ;
     mov     bl,7
     and     bl,al
     test    al,8

     pop     cx
     pop     dx
     jne     param_pr_nx

     mov     al,prvnxt_cod
     push    bx         ; NUMBER OF SUBFUNCTION  - prev/next/domain/el
     sub     sp,6       ;
do_arm:
     push    dx
     push    cx

intro:                  ; MAIN ENTRY POINT
     cli
     push    ds
     push    bp
     mov     cx,cs
     mov     ds,cx
     or      ah,ah      ; REENTRY FLAG CHK ?
     je      arm_self

     call    busy       ; loop until busy

     mov     error_ptr,offset errors_addr

arm_self:
     les     di,pd error_ptr

     xor     ah,ah      ; NO ERRORS FLAG
     mov     bx,ax
     mov     al,ah
     cld
     stosw
     stosw
     xchg    ax,cx
     mov     error_ptr,di
     mov     dx,0
stack_seg    = $-2
     mov     cx,ss
     cmp     sp,stack_gap
     jb      stack_err
     cmp     bl,tablen/2
     jb      ok_fnum

stack_err:
     mov     bx,0ffffh
     jnb     OK_FNUM
     dec     bx
ok_fnum:
     add     bx,bx
     cmp     dx,cx
     jne     adj_ss

     mov     bp,sp
     sti

     call    pw table[bx]

     call    ex_intro   ; prepare to EXIT ARM

     pop     bp
     pop     ds
     retf    12

ex_intro:               ; EXIT ARM
     mov     di,error_ptr
     lea     di,[di-4]
     cmp     pw [di],1
     jc      no_er_intro
     push    [di]
     push    [di+2]
     pop     [di-2]
     pop     [di-4]
no_er_intro:
     mov     error_ptr,di
     mov     di,[di]
     cmc
     ret

adj_ss:
     xor     di,di
     mov     ds,di
     mov     bp,cs
     xchg    bp,[92h+di]
     push    bp
     mov     bp,offset int24_handl
     xchg    bp,[90h+di]
     push    bp
     mov     bp,cs
     xchg    bp,[8eh+di]
     push    bp
     mov     bp,offset ign_break
     xchg    bp,[8ch+di]
     push    bp
     mov     di,sp
     mov     ds,cx

     mov     pw cs:old_ss,ss
     mov     pw cs:old_sp,di
     mov     ss,dx
     mov     sp,stack_size
stack_offs   = $-2
     sti
                ; копи░ане на па░аме▓░и▓е
                ; в ▒об▒▓вени┐ ▒▓ек
     les     cx,[di].dword1+8
     push    es
     push    cx
     les     cx,[di].dword2+8
     push    es
     push    cx
     les     cx,[di].dword3+8
     push    es
     push    cx
     mov     ds,ax
     sub     sp,dword3
     mov     bp,sp

     call    pw table[bx]

     cli
     mov     di,0
old_ss       = $-2
     mov     ss,di
     mov     sp,0
old_sp       = $-2
     mov     bp,ds
     xor     di,di
     mov     ds,di
     pop     [8ch+di]
     pop     [8eh+di]   ;int 23h vector   restore
     pop     [90h+di]
     pop     [92h+di]   ;int 24h vector   restore
     mov     ds,bp
     sti
     test    pb pid+1,0ffh
     jz      ex_i
     push    bx
     push    ax
     xor     bx,bx
     xchg    pid,bx     ; ds = cs
     mov     ah,50h
     int     21h
     pop     ax
     pop     bx
ex_i:
     call    ex_intro   ; prepare to EXIT ARM

     dec     pw cs:semafor      ; semafor is open

     pop     bp
     pop     ds
     retf    12

busy:
     push    cx
     xor     cx,cx
busy_loop:
     xchg    cx,cs:semafor
     jcxz    busy_loop  ; loop until semafor is busy
     pop     cx
     ret

int24_handl:
     add     sp,8
     mov     ax,di
     mov     bp,sp
     or      pb [bp+20],1  ; set carry

     pop     bx
     pop     cx
     pop     dx
     pop     si
     pop     di
     pop     bp
     pop     ds
     pop     es

ign_break:
     iret

scan_pars:
     pop     bx
     mov     di,sp
     les     cx,ss:[di+4]
     mov     ax,es
     mov     dx,cx
     les     di,ss:[di+8]
     cld
     jmp     bx

counter:
     inc     ax
stop_count:
     ret

labeler:
     mov     ax,[bx].item_key
     stosw
     mov     ax,[bx+2].item_key
     stosw
     ret

count_files:
     mov     bx,[si].first_itemp
count_up:
     or      bx,bx
     je      stop_count
     call    dx
     mov     bx,[bx].next_itemp
     jmp     short count_up

byte_scan:
     call    scan_pars
     jcxz    sc_nok
     repne   scasb
     je      sc_ok
sc_nok:
     mov     cx,dx
sc_ok:
     inc     cx
     sub     dx,cx
     xchg    ax,dx
sc_ex:
     retf    8

word_scan:
     call    scan_pars
     jcxz    sc_nok
     repne   scasw
     je      sc_ok
     jmp     short sc_nok

byte_fill:
     call    scan_pars
     mov     ah,al
     shr     cx,1
     rep     stosw
     jnc     sc_ex
     stosb
     retf    8

move_pars:
     pop     dx
     mov     bx,sp
     push    ds
     push    si
     lds     si,ss:[bx+10]
     les     di,ss:[bx+6]
     mov     cx,ss:[bx+4]
     cld
     jmp     dx

swapmem:
     call    move_pars
     shr     cx,1
     jcxz    swapmem1
swapmem0:
     lodsw
     mov     dx,es:[di]
     mov     [si-2],dx
     stosw
     loop    swapmem0
swapmem1:
     jnc     swapmem2
     mov     ah,es:[di]
     lodsb
     mov     [si-1],ah
     stosb
     jmp     short swapmem2

compare_mem:
     call    move_pars
     mov     dx,cx
     xor     ax,ax
     repe    cmpsb
     je      cmp_okmem
     inc     cx
     sub     dx,cx
     dec     si
     lodsb
     sub     al,es:[di-1]
     cbw
cmp_okmem:
     jmp     short swapmem2

upcase_it:
     call    move_pars
     call    upcase_namez
     jmp     short swapmem2

movemem_dn:
     call    move_pars
     call    rcv_memz2
swapmem2:
     pop     si
     pop     ds
     retf    10

movemem_up:
     call    move_pars
     add     si,cx
     add     di,cx
     dec     di
     dec     si
     std
     shr     cx,1
     jnc     movememup1
     movsb
movememup1:
     dec     di
     dec     si
     rep     movsw
     cld
     jmp     short swapmem2

count_bits:
     call    move_pars
     mov     dx,es
     call    count_free
     jmp     short swapmem2

word_fill:
     call    scan_pars
     rep     stosw
     retf    8

and_mem:
     call    move_pars
     shr     cx,1
     jnc     skip_and1
     lodsb
     and     al,es:[di]
     stosb
skip_and1:
     jcxz    and_end
skip_and2:
     lodsw
     and     ax,es:[di]
     stosw
     loop    skip_and2
and_end:
     jmp     short swapmem2

or_mem:
     call    move_pars
     shr     cx,1
     jnc     skip_or1
     lodsb
     or      al,es:[di]
     stosb
skip_or1:
     jcxz    or_end
skip_or2:
     lodsw
     or      ax,es:[di]
     stosw
     loop    skip_or2
or_end:
     jmp     short swapmem2

NOT_mem:
     call    move_pars
     shr     cx,1
     jnc     skip_NOT1
     lodsb
     NOT     al
     stosb
skip_NoT1:
     jcxz    NoT_end
skip_NoT2:
     lodsw
     NoT     AX
     stosw
     loop    skip_NoT2
NoT_end:
     jmp     short swapmem2

make_dsc:
     mov     cx,8
     pop     bx
     pop     dx
     pop     di
     pop     es
     cld
make_dscz:
     pop     ax
     stosw
     loop    make_dscz
     push    dx
     push    bx
     retf

file_num?:
     mov     dx,offset counter

file_num?z1:
     call    busy       ;semafor ? close
     call    file_num?z2
     dec     pw cs:semafor      ; semafor is open
     retf

file_num?z2:
     push    ds
     push    cs
     pop     ds

     xor     ax,ax
     mov     si,offset afiles_list
     call    count_files
     mov     si,offset ufiles_list
     call    count_files
     pop     ds
     ret

all_files_info:
     mov     bx,sp
     les     di,ss:[bx+4]
     mov     dx,offset labeler
     cld
     push    cs
     call    file_num?z1
     retf    4

insrtelm:
     mov     al,insert_cod
     db      0b9h       ; mov cx,#
writelm:
     mov     al,write_cod
     mov     di,sp
     lea     cx,[di+8]
     les     dx,ss:[di+24]
     mov     bx,ss
     push    es
     jmp     short rw_el

readelm:
     mov     al,read_cod
     mov     di,sp
     lea     dx,[di+12]
     les     cx,ss:[di+8]
     mov     bx,es
     push    ss
rw_el:
     push    dx
     push    bx
     push    cx
     les     cx,ss:[di+4]
     push    es
     push    cx
     push    cs
     call    intro
     retf    24

defdom1:     ; proc far
     mov     di,sp
     mov     cx,ss:[di+4]       ; how
     add     di,6       ; src
     push    ss
     pop     es
     xor     dx,dx
     xor     bx,bx
     call    defdfz
     retf    10

defdom2:     ; proc far
     mov     di,sp
     lea     bx,[di+14] ; dest !
     mov     cx,ss:[di+4]       ; how
     add     di,6       ; src
     mov     dx,ss
     mov     es,dx
     call    defdfz
     retf    18

mergedomf:
     push    bp
     mov     bp,sp
     xor     bx,bx
     push    bx
     push    bx
     dec     bx
     push    bx
     push    bx
     mov     cx,4
     mov     di,22
pushelofs:
     dec     di
     dec     di
     push    [bp+di]
     mov     [bp+di],bx
     loop    pushelofs
     mov     cx,sp
     lea     di,[bp+6]
     push    ss         ;src
     push    cx
     push    ss         ;dst
     push    di
     mov     di,offset end_mark
     push    cs
     push    di
     mov     al,copydom_cod
     push    cs
     call    intro
     mov     sp,bp
     pop     bp
     retf    16

