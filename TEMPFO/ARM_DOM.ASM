; arm_dom.asm -  ░або▓а ▒ обла▒▓и
; 6/01/1995

; о▒вобождаване на елемен▓ о▓ ▒пи▒║ка на обла▒▓и▓е
;
release_dom:
     push    si         ; release dom_item in memory
     mov     si,[si].dom_root
     call    item_release
     mov     di,[si].handle     ; main index offset
     pop     si
domf_ex:
     ret

;time record in files  {паке▓и░ане на в░еме▓о}
;
ful_time:
     call    date?
     push    ax
     call    time?
     pop     dx
     retf
; вземане на да▓а▓а ка▓о паке▓и░ана д│ма
;
date?:
     mov     ah,2ah
     int     21h
     mov     al,4
     xchg    ax,cx
     sub     ax,1980
     jmp     short tm_dt

; вземане на ╖а▒а ка▓о паке▓и░ана д│ма
;
time?:
     mov     ah,2ch
     int     21h
     shr     dh,1
     mov     dl,dh      ; sec / 2
     mov     dh,cl      ; min
     mov     al,ch      ; hour
     mov     cl,6
tm_dt:
     shl     ax,cl
     or      al,dh
     mov     cl,5
     shl     ax,cl
     or      al,dl
     ret
;     retf


sdomf_test:
     mov     cl,-1      ; test_domain
sdomf:
     les     di,[bp].dword1
     jmp     short domf

erase_dom?:  ; destination
     xchg    cl,[bp+1].dword3
     or      cl,cl
     je      domf_ex
erase_dom:
     mov     cl,0
     jmp     short domfd

; п░еде┤ини░ане на обла▒▓
;
redefine:
     call    erase_dom?
     jc      domf_ex

; де┤ини░ане на обла▒▓ ▒ даден ░азме░ елемен▓и
;
define_dom:
     mov     cl,[bp].dword3
     db      0bfh       ; mov di,#

; ░азме░ на елемен▓и▓е о▓ обла▒▓▓а
;
test_dom:
     mov     cl,-1
domfd:
     les     di,[bp].dword2
domf:
     xor     bx,bx      ;
     xor     dx,dx      ;
domf4_6:
     xor     ah,ah
defdfz:
     mov     al,defdom_cod
     pop     si         ; вземане на в║зв░а▓ен ад░е▒ - к║▒
     push    dx         ; nil
     push    bx         ;
     push    es
     push    di
     xchg    ax,cx
     cbw
     cwd
     push    dx         ; д║лжина на елемен▓
     push    ax         ;
     xchg    ax,cx
     push    cs         ; кодов ▒егмен▓ в ▒▓ека
     push    si         ; в║зв░а▓ен ад░е▒ в ▒▓ека  - д║л║г
     jmp     intro

; п░о╢ед│░а за изп║лн┐ване на ┤│нк╢ии▓е над обла▒▓и
;
defdom:
     call    find_opt   ; ▓║░▒ене на п░иемника
     jc      deld_ex

     les     ax,[bp].dword3     ; нова д║лжина на елемен▓ ?
     mov     dx,es
     dwinc                      ; пл╛▒ 1
     or      dx,dx
     jne     setelsize
     cmp     ax,128             ; >= 128
     jbe     f_dom              ; не
setelsize:
     mov     ax,7               ; д║лжина по под░азби░ане
f_dom:
     cmp     al,1               ; <= 1  ▓е▒▓ване/▓░иене на обла▒▓
     mov     cx,ax
     jbe     f_dom2             ; да
     mov     al,2               ; ина╖е 2
     mov     ch,80h             ; евен▓│ално ▒║здаване на обла▒▓
f_dom2:
     shl     ax,1       ; index to a domfunc
     mov     [bp+2].dword3,ax
     mov     al,cl      ; al = new size

     mov     di,[bp+2].dword1   ; из▓о╖ник ?
     or      di,[bp].dword1     ;
     je      f_dom3
     inc     ah         ;=1     ; ┤лаг, ╖е има из▓о╖ник
f_dom3:
     mov     [bp].dword3,ax     ; ░еги▒▓░и░ане

     les     di,[bp].dword2     ; ад░е▒ на опи▒а▓ел
     call    find_domz
     mov     cx,di
     jcxz    f_dom4
     jmp     domain_locked
f_dom4:
     mov     cx,[bp].dword3
     dec     ch
     je      movdomfuncs        ; дв│обла▒▓ни опе░а╢ии
     dec     cl
     jc      get_stat
     je      del_dom            ; из▓░иване на обла▒▓
testdomain:
     mov     al,[bx].tp_sizel
     dec     ax
     cbw
     ret

del_dom:
     les     cx,[bx].tp_selfp
     push    es         ; start index block number
     push    cx         ; блок-опи▒а▓ел на индек▒ за обла▒▓▓а
     les     cx,[bx].tp_sublv
     push    es         ; same of the sublevel
     push    cx         ; блок-опи▒а▓ел на индек▒ за п░еп║лване▓о
     mov     ax,[bx].item_key   ; low word of domnum
     call    deldomel   ;
     jc      deld_ex
     pop     ax
     pop     dx
     call    del_index
     pop     ax
     pop     dx
     call    del_index
     call    flush_file ; ░еги▒▓░и░ане на о▒вободени▓е блокове в би▓мапи▓е
deld_ex:
     stc
check_err:
     jc      get_stat_ex
     ret
get_stat_ex:
     lea     sp,[bp-2]
get_stat:
     mov     al,-4
     push    cs
     call    get_status2
     jnc     ex_stat
     xchg    ax,di
     mov     ax,0
ex_stat:
     ret

movdomfuncs:
     call    testdomain ; ░азме░ на елемен▓а ?
     jnc     movdomf1
     call    get_stat
     jc      ex_stat    ; if no err then ax := 0
movdomf1:
     mov     [bp+1].dword3,al
     call    sdomf_test
     call    check_err  ;???

     or      ax,ax
     jne     src_exist

     call    branch3
     dw      ex_stat    ;-1
     dw      erase_dom  ; 0
     dw      redefine   ; else

src_exist:
     xchg    ax,cx      ;save dom-type
     call    samedom?
     jne     movedomfuncs

     call    branch3
     dw      xccx
     dw      condense
     dw      condense_par

movedomfuncs:
     call    branch3
     dw      appendomf
     dw      movedomfunc
     dw      redefdomf

end_mark     dw      8 dup(-1)  ;-1,-1,-1,-1,-1,-1,-1,-1

movedomfunc:
     call    erase_dom?
     call    check_err
     call    samefile?
     jne     other_file

     ;move only pointer to
     call    sdomf_test
     call    check_err

     mov     ax,[bx].item_key
     call    release_dom; from memory
             ; di points to main_ind_path_rec
     push    dx         ; number of sdom
     push    ax         ;
     les     bx,[bp].dword2
     les     bx,es:[bx].parm_x  ; domain
     push    es
     push    bx
     push    ds
     push    di
     call    indexel_move
     call    check_err

     jmp     test_dom

other_file:
     mov     cl,[bp+1].dword3
     CALL    domfd      ; create domain of type N% = cl
     call    check_err

     call    full_copydom
     call    check_err
erase_sdom:
     mov     cl,0
     jmp     sdomf

;-----------------------------------

branch3:
     pop     di
     add     di,[bp+2].dword3
     jmp     cs:[di]

xccx:
     xchg    cx,ax      ; returns domain type
apdomf3:
     ret

chk_domtyp:
     mov     cx,[bp].dword3
chk_domtypz:
     cmp     cl,6       ; destyp >= 7
     jae     apdomf3    ; yes
     cmp     cl,ch      ; destyp >= srctyp
     jae     apdomf3    ; yes
     mov     al,mismatch_dom    ; error
     jmp     set_err2

appendomf:
     mov     ch,[bp+1].dword3
     or      ch,ch      ; dest exist ?
     jne     appdomf2   ; yes
     call    domfd      ; no -> create
     jmp     short appdomf3

appdomf2:
     xchg    cl,ch
     call    chk_domtypz
appdomf3:
     call    check_err

full_copydom:    ; copy all elements
             ; till the end of domain
     mov     ax,copydom_cod
     pop     bx         ; near return address
     call    push_domdsc1
     les     di,[bp].dword2
     call    push_domdsc
     push    cs         ; far return
     push    bx         ; address
     jmp     mergedomf

push_domdsc1:
     les     di,[bp].dword1
push_domdsc:
     pop     cx
     push    es:[di+2].parm_x
     push    es:[di].parm_x
     les     di,es:[di]
     push    es
     push    di
     jmp     cx

redefdomf:
     call    erase_dom?
     call    chk_domtyp
     call    check_err
     mov     cl,[bp+1].dword3
     call    domfd
     call    check_err
     jmp     short full_copydom

condense:
     mov     [bp].dword3,cl     ; same type
condense_par:                   ; other ? may be
     call    chk_domtyp
     call    check_err
     mov     cx,-1
     push    cx         ;nel domain
     push    cx
     mov     di,dword2  ;???
     call    push_dscf  ; duplicate destination descriptor file

     mov     di,sp
     push    ss
     push    di
     mov     ax,nxtdem_unt
     push    cs
     call    unit_funcz ; first empty domain search
     call    check_err  ;????????

     call    define_dom
     call    check_err  ;????????

     call    full_copydom
     call    check_err  ;????????

     les     bx,[bp].dword2
     mov     dx,es
     les     di,[bp].dword1
     mov     cl,0
     call    domf4_6    ; move domain in same file
     jmp     deld_ex

; ▓║░▒ене на обла▒▓ без ▒║здаване
;
find_domr:
     mov     ch,0
find_domz:
     les     ax,es:[di].parm_x

find_dom_es:
     mov     dx,es
find_domain:
     push    si
     push    bp
     mov     bp,sp
     push    cx         ; flags writting/creating while <0
     mov     cx,[si].dom_root   ; flags main index present
     jcxz    no_dombufs
y_dombufs:
     mov     si,cx
     call    item_srch
     jc      no_domnum  ; not present now  try read/create
yes_domnum:
     jc      yes_domnum2
     mov     di,255
     and     di,[bx].lock_offs
yes_domnum2:
     mov     sp,bp
     pop     bp
     pop     si
     ret

no_dombufs:
     push    dx
     push    ax
;    inc     cx         ; one_buffer
     mov     cx,domain_bufs  ;????????
     call    create_dom_list
     mov     si,cx
     jnc     no_domnumz
err_domnum:
     lea     sp,[bp-6]
     pop     ax
     pop     dx
     jmp     short yes_domnum

no_domnumz:             ; try to read / create domain
     pop     ax         ; when not found
     pop     dx
no_domnum:
     push    dx         ; -4
     push    ax         ; -6
     xor     di,di
     call    item_pushz         ; space for tree_dsc
     mov     cx,[si].handle     ; is there any main index ?
     push    si         ; -8  domain list addr
     push    bx         ; -10 domain item addr in memory
     lea     dx,[si+10]
     push    ds         ; -12
     push    dx         ; -14 address of main path
     mov     si,[bp+2]
     jcxz    create_it?
     mov     di,cx
armf_exist:             ; di offset of path_rec
     mov     cx,ds      ; segment of path_rec
     mov     bx,[bp-2]  ; enable flag

     test    pb [di].lock_offs,255
     jnz     ar_locked
     les     ax,[bp-6]  ; domain number
     call    tree_path_es
     les     ax,[bx].item_key
     jc      find_dom_err
     je      dom_not_exist
     jns     find_dom_err
dom_not_exist:
     push    ds         ; segment
     push    [bp-10]    ; offset of domain index in memory
     mov     di,cx
     mov     cx,[bp-2]  ; read path/ or make it

     call    make_index?_es
     jc      find_dom_err
     mov     bx,di
     jmp     err_domnum

ar_locked:
     xor     bx,bx
     mov     al,arch_locked
     call    set_err2
find_dom_err:
     mov     si,[bp-8]
     mov     bx,[si].first_itemp
     call    item_release
     stc
     jmp     err_domnum

create_it?:    ; arm file ?
     call    fseq_len
     mov     cx,dx
     or      cx,ax
     jne     read_main_ind?     ; created yet ?
     test    pb [bp-1],80h
     je      find_dom_err
     push    cs
     call    ful_time
     push    dx         ;date
     push    ax         ;time

     call    get_block  ; 0+1 block
     jc      find_dom_err
     mov     di,4
     mov     cx,8003h   ; elem_size
     les     bx,[bp-14]
     push    es
     push    bx
     call    make_index? ; main create
     jc      find_dom_err
     call    block1     ; 1st block
     jc      find_dom_err
     pop     [bx+ 8]    ; time
     pop     [bx+10]    ; date
     mov     [bx+12],version+256*'V'
     call    chk_sum2
     mov     [bx+14],cx
     call    chk_sum
     mov     [bx-4].blk_len,di
     add     dx,di
     neg     dx
     mov     [bx-2].blk_len,dx
     call    save_buf
     pop     di
     push    di
main_ind_exist?:
     jc      find_dom_err
     mov     [di-10].handle,di
     jmp     armf_exist
not_arm:
     mov     ax,offset find_dom_err
     push    ax
     mov     al,not_arm_arch
     jmp     set_err2
read_main_ind?:
     mov     cx,blk_len-1
     and     cx,ax
     jne     not_arm
     or      dx,dx
     jne     main_ind?
     cmp     ax,blk_len*3       ; ArM-а░╡иви▓е ▒а поне (1536) бай▓а или (0)
     jb      not_arm
main_ind?:
     call    block1
     jc      main_ind_exist?
     call    chk_sum
     or      di,dx
     or      cx,di
     jne     not_arm
     cmp     ax,version+256*'V'
     jne     not_arm
read_main_ind:
     mov     ax,1
     xor     dx,dx
     mov     di,4
     mov     cx,ax
     call    make_index?
     jmp     short  main_ind_exist?

; п░о╢ед│░а - п░ове░ка за ко░ек▓но▒▓ на ARM а░╡ив
;
chk_sum:
     mov     cx,255
     push    si
     mov     si,bx
     xor     dx,dx
     mov     di,0ffffh
chk_sum_lp:
     lodsw
     add     dx,ax
     xor     di,ax
     loop    chk_sum_lp
     lodsw
     add     dx,ax
     pop     si
chk_sum2:
     les     ax,[bx+12]
     mov     cx,es
     xor     cx,ax
     xor     cx,[bx+8]
     xor     cx,[bx+10]
     or      cx,[bx]
     or      cx,[bx+2]
     ret

make_dom_list:
     call    init_list
     dw      dom_bufs,-tp_bodysz,temp
;
; п░о╢ед│░а за на╖ално │▒▓анов┐ване на ▒пи▒║к
;
init_list:
     pop     di
     mov     cx,cs:[di]
     mov     dx,cs:[di+2]
     mov     di,cs:[di+4]
     mov     ax,[di]
     add     bx,ufrec_siz       ; make list of ???????
plusbuf:
     mov     [bx].next_itemp,ax
     mov     ax,bx
     add     bx,dx
     loop    plusbuf
     sub     bx,ufrec_siz       ; make list of ???????
     mov     [di],ax
     ret

; б░ой на блокове▓е в║в ┤айл
;
blocks:
     mov     bx,offset carry_z
     push    bx
to_block:
     mov     bx,blk_len
div_mod:                        ; DX:AX /= BX
     xor     cx,cx              ; CX    := DX:AX mod BX
     cmp     dx,bx
     jb      div_once
     xchg    ax,cx
     xchg    ax,dx
     div     bx
     xchg    ax,cx
div_once:
     div     bx
     xchg    cx,dx
     ret

chk_free:
     mov     bx,first_free
chk_key:
     cmp     [si+bx+2],dx
     je      chk_low
     ret
chk_low:
     cmp     [si+bx],ax
chk_key_exit:
     ret
chk_path_key:
     call    chk_key
     jne     chk_key_exit
     xor     si,si
     jmp     short chk_key

carry_z:
     clc
     mov     bx,end_blk
     mov     [si+bx-2],cx
set_key:
     mov     [si+bx+2],dx
     mov     [si+bx],ax
     ret

no_buf:
     pop     cx
del_dom_list:
             ; о▒вобождаване на б│┤е░и▓е, зае▓и о▓ ак▓ивни обла▒▓и
     pushf
     mov     cx,[si].dom_root
     jcxz    ex_del_dom
     mov     bx,cx
     mov     cx,[bx].next_itemp
     mov     [si].dom_root,cx
     call    push_buf
     jmp     short      del_dom_list+1

create_dom_list:
     call    get_file_key
     call    file_chkz  ; is it arm ?
     jnc     no_ill_fun
     jmp     ill_fun    ; no
no_ill_fun:
     XOR     ax,ax
     mov     temp,ax

more_dom:
     push    cx         ; number of  domain_bufs
     call    get_buffer
     jc      no_buf
     call    item_delete
     mov     cx,bx
     xchg    cx,[si].dom_root
     mov     [bx].next_itemp,cx

     add     bx,dom_bufs*tp_bodysz-tp_bodysz
     call    make_dom_list
     pop     cx
     loop    more_dom

     pushf
     neg     dx
     mov     di,dx
     lea     ax,[bx+di]
     mov     di,ax
     xchg    ax,cx      ; cx = 0
     push    cs
     pop     es
     stosw
     stosw
     xchg    ax,temp    ; zeroing temp
     add     ax,dx
     stosw
     mov     ax,offset release_it
     stosw
ex_del_dom:
     popf
     ret

