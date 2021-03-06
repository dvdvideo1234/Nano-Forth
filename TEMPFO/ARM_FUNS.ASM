; arm_funs 13/6/1995
; ������ ������ ���������� ��� ArM, ����� ����� �� �� ��������
; � ����� � ����

; � � � � � � �
; ================
; 23.7.1995 - �������� �� ��� ���� ������   Shared / Prived
;		 ��������� OPEN
;=================
; 3.12.1995 - arm_state  - ��������� �� ����������� �� ArM
; ��� ��������� �� ��� ������
;
; share_state - ������ ��  ������� ���� � �������
;
;0 - read/write
;1 - read only
;2 - not in memory
;
;===============================================================
; ������� �� ��������	�����	  ��� �� �-���

     dw      stk_full	; -2	  ������ - ����� ����
     dw      ill_fun	; -1	  ������ - ��������� �-���
table	  dw	  present    ; 0       ������� ArM � �������
     dw      self_instal; 1	  ��������������� �� ������ �����
     dw      self_quit	; 2	  ���������� �� ArM �� �������
     dw      open	; 3	  ������ � ����� - �����
     dw      lmove	; 4	  ������� �� �����
     dw      read_file	; 5	  ������ �� �����
     dw      write_file ; 6	  ������ ����� �����
     dw      copy_file	; 7	  �������� ����� �����
     dw      rdblk	; 8	  ������    �� ����
     dw      wrblk	; 9	  ������ ����� ����
     dw      defdom	; 10	  �-��� �� ������ � �������
     dw      prevnext	; 11	  �-��� ��������-�������  �������-������
     dw      ins_mem	; insert  ������ � �����
     dw      ins_file	; icopy   �������� � �����
     dw      get_path	; 14	  ����� ��� �� �����
     dw      setlen	; 15	  ��������� �� ������� - ���� ���������
     dw      copy_domain; 16	  �������� �� ������
     dw      copy_arch	; 17	  �������� �� �����
     dw      info_arch	; 18	  ���������� ��  �����
     dw      l4read	; 19	  ������������ ������ �� 4 �����
     dw      movelement ; 20	  ������� �� ������� � ���� ������
     dw      arm_state	; 21	  ��������� �� ArM
     dw      share_state; 22	  ��������� �� �������-����
     dw      commit	; 23	  ���������� �� ����������� DOS ������
     dw      read_mult	;     read multiple  Rmulty_cod   =  24
     dw      write_mul	;     write multiple Wmulty_cod   =  25
     dw      lock_dom	;
     dw      lock_arch	;
tablen = $-table	;

;================================================
; ��������� �� ������������� ����������
; es:bx  �������� ��� ���������� �� ����
; si:di  �������� ��� ����������  -  ����� ��������
; dx:cx  �������� ��� ����������  -  ���� ��������

lock_dom:
     ;�������� �� ���� ���� �������
     ; ����� ��������� �� ������  ��� ���������� �� ������

     call    find_ipt
     jc      lock_dom_err
     les     di,[bp].dword1
     mov     ch,-1		; create domain if it does not exist
     call    find_domz		;bx - start of dom_buffer
     jc      lock_dom_err
     je      try2lock		;not locked yet

     les     di,[bp].dword2	;
     call    lock_chk
     je      try2lock		;locked, but lock check passed
     jmp     domain_locked	;bad check
try2lock:
     call    release_dom
     les     ax,pd [bx].tp_selfp; number of domain

lock_area:
     call    block_es
     jc      lock_dom_err

     lea     di,[bx].lock_offs
     push    ds
     pop     es
     lds     ax,[bp].dword3	;address of new lock sequence
     mov     cx,16
     call    rcv_memz
     xor     ax,ax
     xchg    ax,dx
     sub     di,ax
     mov     al,es:[di] ; ���� ������� �� ��������
     call    save_buf	; ����� �� ���������� ���� �����

     ; ��� ���������� �� ������
     ; �������� �� ���� ���� �������
     ; ����� ��������� �� ������
lock_dom_err:  ;      dlock_cod   =  26
     ret
;================================================
uni_lock     db   15,0f0h,01fh,001h,0f0h,01fh,001h,0f0h,01fh,01h
	     db      0f0h,01fh,001h,0f0h,01fh,001h
lock_chk:
     mov     dx,offset uni_lock
     call    lock_chk2
     je      lock_chk3
     lea     dx,[bx].lock_offs
lock_chk2:
     mov     ch,15
     push    si
     push    di
     cld
     mov     si,dx
     mov     cl,[si]
     cmp     cl,ch
     jbe     lock_chk25
     mov     cl,ch
lock_chk25:
     xor     ch,ch
     inc     cx
     rep     cmpsb
     pop     di
     pop     si
lock_chk3:
     ret
;================================================
lock_arch:

     ;�������� �� ���� ���� ������
     ; ����� ��������� �� ������

     call    find_ipt
     jc      lock_arch5 	;
     mov     bx,[si].dom_root
     or      bx,bx
     jne     lock_arch2 	;	main index of domains exist
     xchg    ax,bx
     mov     dx,ax
     mov     ch,-1
     call    find_domain	;bx - start of dom_buffer
     jnc     lock_arch1

     call    get_stat		;error handler - below
     xchg    ax,di
     xor     ax,arm_err*2+arch_locked
     stc
     jne      lock_arch5	 ;
     mov     bx,ax
     call    set_err		; clear old error number !!!

lock_arch1:
     mov     cx,[si].dom_root
     jcxz    lock_arch5 	; some error on creation
     mov     bx,cx
     ; ��� ���������� �� �����
     ; �������� �� ���� ���� ������
lock_arch2:
     mov     bx,[bx].handle	; offset of the main index path
     test    pb [bx].lock_offs,0ffh
     je      lock_arch3
     les     di,[bp].dword2	;
     call    lock_chk
     je      lock_arch3
     jmp     ar_locked
lock_arch3:
     les     ax,pd [bx].tp_selfp; number of domain
     push    es
     push    ax
     call    del_dom_list
     pop     ax
     pop     es
     call    lock_area

lock_arch5:
     ret
;================================================
; commit  file - flush DOS buffers & save them on disk

commit:
     les     ax,[bp].dword1
     call    f_search_es		; ������� ��� ��
     jc      commit_z			; �� � ������� � �������
     mov     si,bx	;si -  ������ ��������

     call    dos_f1
     dw      6800h,lr1		;
commit_z:
     xor     ax,ax
     xor     dx,dx
     ret

share_state:
     les     ax,[bp].dword1
     call    f_search_es		; ������� ��� ��
     mov     al,2
     jc      not_in_mem
     dec     ax 		; ax=1	- mask
     and     al,[bx].handle
not_in_mem:
     cbw     ; byte to word
     cwd     ; word to dword
     ret

arch_inf:
     mov     ax,[bx].item_key
     or      ax,ax	; ��������� 0
     je      arch_s

     mov     ax,[bx].item_key+2
     or      ax,ax	; �������   0
     je      arch_s

     mov     ax,[bx].handle  ; ������ ��� 1  - ���� �� ������
     and     ax,1
     je      arch_s	; �������� �� ���� ��������� �� ������
			; �������� ���� �� ������

     mov     ax,[bx].item_key
     stosw
     mov     ax,[bx].item_key+2
     stosw
     inc     cx
     ret

arm_state:
     les     di,pd [bp].dword2
     mov     dx,offset arch_inf
     xor     cx,cx	;counter
     call    file_num?z2
     xchg    ax,cx
     cwd		; dword FileCount  in dx:AX
arch_s:
     ret

getl:
     les     bx,[bp].dword1	; first parametter
     mov     cx,-1		; ��������� �� 0
     db      0b8h		; mov ax,#
setl_0:
     xor     cx,cx		; ��������� �� 0
     mov     dx,cx
     mov     ax,setlen_cod

; �������� �� ���������� 2F, ��� ���� �� � ��������
;
emul_2f:			; ��������� ����� � �����
     push    bx
     push    si
     push    di 		; ����� �� ����������
     push    dx
     push    cx
     mov     cx,es		; ���������� �� ES �� �����
     mov     di,sp
     xchg    cx,ss:[di+10]	; ���������� � ������� �������
     push    cs 		;\
     push    cx 		; ����� ����� �� �������
     jmp     intro

;================================================
;  ������� �� ������� � ���� ������
;
movelement:
     call    getl
     ; SI  ���� �������� ��������
     ; ����� �������� ��������� �� �������� �� ������
     jc      move_errors

     or      ax,dx
     mov     [bp].dword3,ax
     les     di,[bp].dword1
     call    find_domr
     jc      move_errors
     mov     di,bx
     mov     cx,[bp].dword3
     jcxz    del_dest	; ��������� � ������
     les     bx,[bp].dword1
     les     bx,es:[bx].parm_y
     push    es 	; ����� �� �������� ��������
     push    bx
     les     bx,[bp].dword2
     push    es 	; ����� �� �������� ��������
     push    bx
     push    ds
     push    di 	; ����� �� ��������� �� ���� �� ��������
     call    indexel_move

move_errors?:
     jc      move_errors
del_dest_num:
     les     ax,[bp].dword2
     mov     dx,es
     ret
move_errors:
     jmp     not_el

del_dest:    ; erase destination element

     call    del_dest_num
     call    delement
     jmp     short move_errors?

;================================================

l4read:
     les     ax,[bp].dword1
     call    find_file_es	; �������� �� �����
     jc      move_errors
     les     ax,[bp].dword2
     call    block_es		;�������� �� ����
     jc      move_errors
     mov     di,blk_len-1
     and     di,[bp].dword3
     les     ax,[bx+di] 	; ��������� �� 4 �����
     mov     dx,es
     ret

; ���������� ��  �����
; ����,����� �� �����,
info_arch:
     les     ax,[bp].dword1
     call    find_file_es	; �������� �� �����
     mov     cx,0
     mov     ax,cx
     mov     dx,cx
     jc      info_ex
     call    fseq_len
     mov     cx,1
info_ex:
     xchg    [bp].dword1,ax
     xchg    [bp+2].dword1,dx
     les     di,[bp].dword2
     mov     bx,es
     or      bx,di
     je      info_exn

     jcxz    no_name

     mov     cx,offset item_srch
     call    with_names
     xor     ax,ax
     mov     ds,cx	; ds - segment of name
     mov     al,DS:[bx]
     inc     ax
     xchg    ax,cx	;cx - len
     xchg    ax,bx	; ax offset
     les     di,[bp].dword2
     call    rcv_memz	; ds := cs
     jmp     short info_exn

no_name:
     XOR     AL,AL
     stosB
info_exn:
     les     ax,[bp].dword1
     mov     dx,es
     ret

get_file_name:		; ������� �� ����� �� ���� ��  ��������� ��������
     call    free_name	; ����� �� ������� �� �������
			; BX - ����������,  CX - �������
     pop     si 	; ret adr
     les     di,[bp].dword1	;old address of the name
     inc     bx
     xchg    ax,cx
     mov     [bp].dword1,bx
     mov     [bp+2].dword1,ax	; ax:bx - new_adr

     mov     dx,name_size
     mov     cx,es
     or      cx,di
     jne     move_name	; ����� � � �������
	     ; read first  if element is in sys_arch
     push    cx 	; =0
     push    cx 	; offset in element
     push    cx 	;
     push    [bp+2].dword2	; elem num
     push    cx
     push    [bp].dword2	; elem dom
     push    cx
     push    cx 	; sys arch
     push    ax
     push    bx 	; address new
     push    cx
     push    dx 	; length
     mov     ah,0	; self func
     push    cs 	; self codseg
     push    si
     jmp     readelm	; ������ �������� �� �������
move_name:
     push    es
     push    di 	; from adr
     push    ax
     push    bx 	; to adr
     xor     ax,ax
     push    ax 	;=0
     push    [bp].dword3; len
     mov     al,gpath_cod	; ��� � ��� - ���� �� ������� �� ����
     cmp     pb es:[di],drv_type	; ������� ?
     jne     is_a_path
     mov     al,lmove_cod	; ��� � �������  - �����������
is_a_path:
     push    cs
     push    si
     jmp     intro		; ����������

f_search_es:		   ; ������� ��� ��
     mov     dx,es
f_search:		; ������� ��� ��
     call    af_search	; �������
     jnc     close_it	; �� - �� �� �������
     call    uf_search	; ���������
close_it:
     ret

; ������ � ����� - �����
;
open:
     les     ax,[bp].dword2 ; file label
     call    f_search_es    ; ������� ��� ��
     jc      not_open_yet
     or      ax,dx	; ��������
     pushf
     call    close_file
     popf		;
     jne     not_open_yet
     call    close_sys	; �� - �� �� �������� ������ ����������� ������
not_open_yet:
     call    pre_chk	;  try if nessesary to close 1 sysarch chiled
			; ��� � ���������� ������� 1 �����������
     jnc     not_too_many
     mov     al,too_many_fil   ; ������ ����� �������������
     db      0b9h
not_fullpt:
     mov     al,path_not_full
     db      0b9h
such_names:
     mov     al,duplicates
     jmp     set_err2

exit_only:
     ret
; ���� 2 ������ � ����� �� ��������
not_too_many:
     mov     cx,[bp].dword3
     jcxz    exit_only	; ��� ��������� �� ����� � =0 - ��������� �� �����

     call    get_file_name	; ���� ��������� �� ����
     jc      exit_only	; ��� ��� ������
     or      ax,ax
     jz      exit_only	; ��������� �� ����� � 0��

     les     di,[bp].dword1	; ��� ����� �� �����
     dec     di
     stosb		; inc di  ����� �� ���������
     mov     si,di
     mov     bx,ax
     mov     es:[bx+di],ah ; asciiz string   - 0 ������ ������ ���
     mov     ax,'\:'            ; �������� �� ������� �� �����-��������
     inc     di
     scasw		   ; cmp ax,es:[di]
     jne     not_fullpt
     call    name_srch	; �������� �� ��������� �� �����
     je      such_names
     call    open_arch
     jc      exit_only

     xor     cx,cx
     cmp     cx,[bp+2].dword3	; cf if cx <> 0
     les     di,[bp].dword2 ; file label
     mov     dx,es
     rcl     ax,1	; handle*2 + shared_flag
     xchg    ax,di
     call    uf_push	; �������� ��� ������� �� ����������� �������

     mov     cx,offset item_ins
     push    cx 	; �������� ��� ������� ������ ��� �� ����
with_names_cx:
     pop     cx
with_names:
     push    ds
     push    si
     lds     si,pd names_ptr
     call    CX
     mov     cx,ds
     pop     si
     pop     ds
     ret

open_arch:
	 ; or driver
     mov     ax,-1	; driver's handle  �� ������������
     push    ds
     push    es
     pop     ds
     cmp     pb [si],drv_type	;  �������� �� � ����������
     je      open_arch3 	 ; ������� �� �
	     ;	�� � - ����� � ����

     mov     cx,[bp+2].dword3	; cx=0 ��� � �� ������ � ������
     jcxz    open_arch2

     mov     dx,0001h	; ��� ������ �� ���������� - ������
     xor     cx,cx	;  =0  ������ !!!
     mov     bx,0010000000100000b      ; share - deny none
	     ;	fedcba9876543210
     call    dos_f
     dw      6c00h+8000h,lr1  ; share - deny none
     jnc     open_arch3

     mov     dx,si
     call    dos_f
     dw      8000h+3d00h+00100000b,lr1	; share - deny none
					; read only
     jmp     open_arch3

open_arch2:
     mov     dx,0011h		;
     mov     bx,0010000000100010b      ; share - deny none
	     ;	fedcba9876543210       ; read & write
     call    dos_f
     dw      6c00h+8000h,lr1		; create & open & autoflush
     jnc     open_arch3

     mov     dx,si
     call    dos_f
     dw      5b00h+8000h,lr1		; create & open
     jnc     open_arch3

     mov     dx,si
     xor     cx,cx
     call    dos_f
     dw      3d02h+8000h,lr1		; open

open_arch3:
     pop     ds
     jc      open_arch4
     ret

open_arch4:
     jmp     set_err1		; dos error

free_name:
     call    with_names_cx
     mov     bx,[si].free_listp
     ret

; �������� �� 0 ���������
; ��� ���������� - ����� �� �-�
chk0:
     mov     dx,[bp].dword3+2
     mov     ax,[bp].dword3
chkz:
     or      ax,ax
     jne     chk_ex
     or      dx,dx
     jne     chk_ex
chk_ex0:
     lea     sp,end_adr+2
chk_ex:
     ret

upcase_name:
     xor     ch,ch
upcase_namez:
     jcxz    chk_ex
upcased:
     lodsb
     cmp     al,'z'
     jbe     lat_ltr
     cmp     al,'�'
     ja      no_ltr
     cmp     al,'�'
     jb      no_ltr
     jmp     short yes_ltr
lat_ltr:
     cmp     al,'a'
     jb      no_ltr
yes_ltr:
     and     al,0dfh
no_ltr:
     stosb
     loop    upcased
     ret

; ������� �� ��� � ������� �� �������
;
name_srch:
     lea     di,[si-1]
     call    with_names_cx

     xor     ch,ch
     mov     bx,[si].first_itemp
     jmp     short next_namez
next_name:
     mov     si,bx
     mov     cl,[si]
     inc     cx
     push    DI
     repe    cmpsb
     pop     di
     je      same_names
     mov     bx,[bx].next_itemp
next_namez:
     or      bx,bx
     jne     next_name
     inc     bx
same_names:
     ret

; ����� ��� �� �����
;
get_path:
     mov     di,offset start-1
     mov     cx,name_size
     cmp     cx,[bp].dword3
     jb      is_shorter
     mov     cx,[bp].dword3
is_shorter:
     sub     di,cx
     push    di
     push    ds
     push    ds
     pop     es
     lds     si,[bp].dword1
     call    upcase_name
     pop     ds
     pop     si
     xchg    ax,cx	; cx = 0   on exit upcase_name
     stosb		; end of asciiz string
     mov     di,offset temp_name
skip_one:
     lodsw
     or      al,al
     je      no_drv_let 	; get current
     cmp     ax,'\.'
     je      skip_one
     cmp     al,'\'
     je      no_drv_let1
     cmp     al,'A'
     jb      no_drv_let
     cmp     al,'Z'
     ja      no_drv_let
     cmp     ah,':'
     jne     no_drv_let
     stosw
     mov     al,'\'
     stosb
     lodsb
     cmp     al,'\'
     je      copy_path
     dec     si
     jmp     short path_empty?

no_drv_let:
     dec     si
no_drv_let1:
     dec     si
     push    ax
     mov     ah,19h
     int     21h
     add     al,'A'
     stosb
     mov     ax,'\:'
     stosw
     pop     ax
path_empty?:
     cmp     al,'\'
     je      copy_path
     push    si
     mov     si,di
     mov     dl,temp_name
     sub     dl,'A'-1
     mov     ah,47h
     int     21h
     mov     al,[si]
     or      al,al
     je      empth
     call    zcopy
     mov     al,'\'
     stosb
empth:
     pop     si
copy_path:
     call    zcopy
     mov     ax,offset temp_name
     mov     cx,ax
     xchg    cx,di
     sub     cx,di
     les     di,[bp].dword2
movemem:
     call    rcv_memz
     xor     ax,ax
     xchg    ax,dx
     ret

; �������� �� ASCIIZ ������
zcopy:
     lodsb
     stosb
     or      al,al
     jne     zcopy
     dec     di
     ret

;===============================================================
; closes all open files and set old vector for int2f
; ������������� �� ���������� �������
; � ������� ��� � �������� �� ������� �������
;
self_quit:
     mov     ax,cs
     call    close_sysz ;
     dec     ax 	;
     call    close_sysz ; ��������� �� ���������
     call    close_sys	;
     mov     ax,offset try
     mov     dx,cs
     xor     bx,bx
     mov     es,bx
     les     bx,es:my_int*4
     mov     di,es
     call    cmp2z	; �������� �������� �� �
     jne     not_on_top ; ��
     push    ds       ; prepare for release memory
     push    ds       ; prepare for release memory
     lds     dx,pd cs:v_old
     db      0b8h	; skip2 =[mov ax,]
set_int2f:
     push    ds
     push    ax
     mov     ax,2500h+my_int
     int     21h
my_return:
     pop     ax
     pop     ds
     ret
not_on_top:		; �� � ��������
     mov     al,non_removable
     jmp     set_err2

;===============================================================
prev_rec:
     mov     cx,[bp].dword2
     jcxz    prvnxt_end
ill_fun:
     mov     al,ill_function
     jmp     set_err2

;===============================================================
; �-��� ��������-�������
;
prevnext:
     mov     Ax,[bp+2].dword2
     cmp     Ax,8	; ���� �� 8
     jae     ill_fun

     push    ds
     lds     di,[bp].dword1
     and     AL,4	;4 element	0 - domain
     mov     [bp].dword2,AX
     XCHG    AX,BX
     les     cx,[di+bx].parm_x
     mov     bx,es
     mov     al,2	; 2 next	0 -  previous
     and     ax,[bp+2].dword2
     dec     ax
     cwd
     add     ax,cx	; ������ � ����������� ������
     adc     dx,bx
     mov     [bp].dword3,ax	; number searching for
     mov     [bp+2].dword3,dx	; element or domain
     and     dx,ax
     les     ax,[di]		; file label
     pop     ds
     cmc
     inc     dx
     mov     cx,offset not_el?
     push    cx 	; if an error  => return(nel)
     je      yes_nel
     call    find_file_es  ; find file label
yes_nel:
     call    selectz
     dw      prev_rec
     dw      prvnxt_arm

prvnxt_end:
     les     ax,[bp].dword3	; result num  dom/elm
     mov     dx,es
     jmp     short prvnxt_endz

prv_dom?:
     les     ax,[bp].dword3	; no creating  cx=0
     call    find_dom_es	; domain index
     mov     cx,[si].dom_root
     jcxz    nxt_err		; cf = 1  on this way
     mov     bx,cx
     mov     cx,[bx].handle	; offset of the main index path
     jcxz    nxt_err1		; ������� � ������ !!!!!
     mov     di,cx
     mov     bx,[bp+2].dword2	; in BX tree_func_num
do_prvnxt:
     mov     cx,ds
     les     ax,[bp].dword3
     mov     dx,es
     call    tree_func		; ����������� �� 1 �� 4�� �-���
     jc      nxt_err
prvnxt_endz:
     les     di,[bp].dword1	; dsc_addr
     mov     bx,[bp].dword2	; bx = 0 / 4
     mov     es:[di+bx].parm_x,ax	; ������� �� ��������� � ��������
     mov     es:[di+bx+2].parm_x,dx
nxt_err:
     ret

nxt_err1:    ; if domain does not exist
	     ; but we searsh for empty elements / domains
	     ; ����� ���� �� ������
     mov     al,[bp+2].dword2
     shr     al,1
     jnc     prvnxt_end
     ret

prvnxt_arm:
     mov     cx,[bp].dword2
     jcxz    prv_dom?
     les     di,[bp].dword1	; element index
     call    find_domr
     jc      nxt_err1
     mov     di,bx
     mov     bl,3
     and     bx,[bp+2].dword2
     jmp     short do_prvnxt

;===============================================================
; ����������� �� ������ �����
;
self_instal:
     les     di,[bp].dword1	; ����� ���������
     mov     ax,offset intro
     stosw
     mov     ax,cs
     stosw
     les     di,[bp].dword2	; �����
     mov     ax,offset unit_funcs
     stosw
     mov     ax,cs
     stosw
     ret

;===============================================================
; ��������� �� ������� �� ������� �� ���������� ��������
;
get_status:
     mov     al,0
get_status2:
     cbw
     add     ax,cs:error_ptr
     xchg    ax,di
     les     ax,cs:[di]
     mov     dx,es
     sub     di,offset errors_addr
     cmp     ax,1
     cmc
     retf

bad_write:
     mov     ax,file_shared+arm_err
     stc		; cf = 1
     retf
;===============================================================
; �������� �� ��������� � �������
;
present:
     mov     si,cs
     mov     es,si
     mov     bx,offset try
     mov     cx,version
;    mov     dx,dom_bufs
     mov     ax,0ffffh	  ; flag present
     jmp     set_err

;===============================================================
; ��������� �� �������� ���� ������� � ��� � ���������
; ��� ������ ������  ������� ������
;
chk_end:
     mov     bx,dsc_ofs
chk_endZ:
     les     di,[bp].dword3
same_chk:
     cmp     dx,es:[bx+di+2]	; chkhi
     jne     chk_endx
     cmp     ax,es:[bx+di]	; chklo
chk_endx:
     ret

samedom?:
     mov     bx,4
     call    sameitem
     jne     chk_endx
samefile?:
     xor     bx,bx
sameitem:
     les     di,[bp].dword1
     les     ax,es:[bx+di]
     mov     dx,es
     les     di,[bp].dword2
     jmp     short same_chk

; ��������� �� �������� ���� ������� � ��� � ���������
; ��� ������ �����  ������ ������
;
chk_begin:
     call    chk_end
     cmc
     ret

spr_fn_ex =  [bp-4]	; ��������� �� �����
spr_init  =  spr_fn_ex-2; ��������� �� �������������
copy_func =  spr_init-2 ; ��������� �� �������� �� ���������������
step_func =  copy_func-2; ��������� �� �������� �� �������/� �������/������
temp_dsc  = step_func-16; �������� ���������� - ��� �� ������

copy_fn   =  temp_dsc-2 ; ����� �� �-���, ����� ������ ���������������
dsc_ofs   =  copy_fn-2	; ���������� � �����������
elem_cnt  =  dsc_ofs-4	; ����� �� ����������
step_fn   =  elem_cnt-2 ; ����� �� �-���, ����� ����� �������
chk_v	  =  step_fn-2	; ������������� ��� ���������
temp_pnt  =  chk_v-4	; �������� ��������� �� ��������� ���������

copy_arch:
     mov     ax,copydom_cod
     mov     bx,parm_x
     mov     cx,offset init_ac	;archive copy
     jmp     short copy_it
copy_domain:
     mov     ax,icopy_cod
     mov     bx,parm_y
     mov     cx,offset init_dc	;domain copy
copy_it:
     lea     sp,temp_dsc
;    int     3


     push    ax 	; copy_fn	����� �� �������
     push    bx 	; dsc_ofs
     call    cx 	; initialize  all slots

     xor     cx,cx
     push    cx 	; zero
     push    cx 	; counter

;    mov     bx,dsc_ofs ;??? !!!
     mov     cx,offset chk_end
     les     di,[bp].dword1
     les     ax,es:[di+bx]
     mov     dx,es
     push    ax
     mov     si,es

     dwinc
     call    cx 	; ������
     les     di,[bp].dword2
     les     di,es:[di+bx]	; ������� ���������
     jbe     non_dn	; ������
     dec     bx
     dec     bx 	; �����
     mov     cx,offset chk_begin
non_dn:
     dec     bx 	; ����� ��������  �� �� ������
     pop     ax
     push    bx 	; step_fn
     push    cx 	; chk_v
     push    si 	; temp_pnt+2  \ ���� ���� � dsc1\
     push    ax 	; temp_pnt    /������� ������	/
     push    si 	;  \ ������� ��������� �� ���� � dsc1
     push    ax 	;  /
     push    es 	; \��������� �������� �� ��������� ���������
     push    di 	; /				� dsc2

copy_lp:
     call    step_func		; ������ �� ������� �����
     jc      end_copy
     mov     cx,ax
     and     cx,dx
     inc     cx 		; ���  ?=-1
     je      end_copy1		; ��
     call    chk_v		; ����� ���������
     jae     end_copy1		; ��
     mov     cx,ax
     mov     si,dx		; si:cx := dx:ax
     xchg    cx,temp_pnt
     xchg    si,temp_pnt+2
     sub     ax,cx
     xchg    ax,cx
     sbb     dx,si
     call    copy_func

     pushf
     add     elem_cnt,ax	; ��������� ���� �� �������������
     adc     elem_cnt+2,dx	; ��������
     popf
     jc      end_copy
     jmp     short copy_lp

end_copy1:
     mov     bx,dsc_ofs 	;
     les     di,[bp].dword2	; �������������� �� �������������
     pop     es:[di+bx] 	;
     pop     es:[di+bx+2]	;
     les     di,[bp].dword1	;
     pop     es:[di+bx] 	;
     pop     es:[di+bx+2]	;
;    call    spr_fn_ex		; ��������� �� ����������� �� ����� V

end_copy:			; � �������� ������ � ���� �����
     les     ax,elem_cnt
     mov     dx,es
     lea     sp,spr_fn_ex+2
     ret

;-----------------------------------------------------------
init_AC:
     mov     step_func,offset step_funcN
;    mov     spr_fn_ex,offset end_copy	; ��������� �� ����������� �� ����� V
     mov     copy_func,offset copy_funcN
     ret
;-----------------------------------------------------------
init_dc:
     mov     step_func,offset step_funcN
;    mov     spr_fn_ex,offset end_copy	; ��������� �� ����������� �� ����� V
     mov     copy_func,offset copy_func1
     ret
;-----------------------------------------------------------
copy_funcN:
     pop     si
     les     di,[bp].dword1
     push    es
     push    di
     les     di,[bp].dword2
     add     es:[di+bx],cx
     adc     es:[di+bx+2],dx
     push    es
     push    di
     les     di,[bp].dword3
     mov     ax,copy_fn
     cmp     al,icopy_cod
     jne     copydomel2
     les     di,es:[di].parm_o
copydomel2:
     push    es
     push    di
     push    cs
     push    si
     jmp     intro
;-----------------------------------------------------------
copy_func1:  ; copy element
     call    copy_funcN
     mov     ax,1
     mov     dx,0
     jnc     copy_func_ok
     dec     ax 	; =0
copy_func_ok:
     ret
;-----------------------------------------------------------
step_funcN:
     mov     ax,step_fn 	; ��� �� ��������

step_funcZ:
     les     di,[bp].dword1
step_funcZ_:
     pop     bx
     push    es
     push    di
     push    cs
     push    bx
     jmp     unit_funcz 	; ������ �� ������� �����
;-----------------------------------------------------------
; read_mult:			  ;	read multiple  Rmulty_cod   =  24
;1. �������� �� �������� ������ 			  1111111
;2. �������� �� ��������� �� ���������
;    ��� �� � ������� - ���� �� �����������
;3. ����������� �� ����������-������
;   ��������� �� ������������ � ������
;4.  �������� �� ������� �������		444444
;5.  �������� �� ��������� �� ���������
;    ��� �� � ������� - ������ ��� ����� 1		  1111111
;6.  ����������� �� ����������-�������
;    ��������� �� ������������ � ������
;7.  �������� ��������� �� �������
;    ��������� �� ��������� � ������
;8.  ��������� �� ������� �� �������� � ������
;		      - ������ ��� ����� 4	444444
;
;
;
dsc_size	=	16

wrm_tmp_ofsbuf	=	[bp-2]
old_elnum	=	wrm_tmp_ofsbuf-4
dom_offs	=	wrm_tmp_ofsbuf-dsc_size ; add to elem num
elem_offs	=	dom_offs+4     ; add to dom num
wrm_dsc 	=	dom_offs-dsc_size
buf_posi	=	wrm_dsc-4
elem_len	=	buf_posi-4

write_mul:			;     write multiple Wmulty_cod   =  25
; 1. ��������� �� ������ ��� ����

     les     bx,[bp].dword2

     call    push2_inc

;     LES     BX,[BP].DWORD2
     mov     di,dword2
     call    push_dsc_s

     LES     BX,[BP].DWORD1	;CBB address
     mov     ax,es:[bx].parm_o
     mov     es:[bx+2].parm_o,ax	;maximum size
     mov     es:[bx+2],ax		;empty buffer
     sub     sp,8	;locals
     push    es
     push    bx 	;cbb adr on top
;
; 2. ������� �� ����� �� �������
;     ��� =-1  ��  ������� ���� ���� � ����� �� ������ + ����������
;		������ ����� 2
get_dom_num:
     call    getnumber
     inc     di
     je      no_more_data2write
     dec     di
     add     ax,dom_offs[di]
     adc     dx,dom_offs[di+2]
     mov     [di].wrm_dsc.parm_x,ax  ;element or domain was read
     mov     [di+2].wrm_dsc.parm_x,dx
     or      di,di
     je      get_dom_num	;elem_num read to continue
;    int     3
; 3. ��������� �� ������� �� �������
;
; 4. ����� �� �������

     call    getnumber
     inc     di
     je      no_more_data2write
     dec     di
     je      error_dom_xxxx
     mov     elem_len,ax
     mov     elem_len+2,dx

; ������������� ��������� �� ��������
     les     bx,[bp].dword2	; first parametter - address of element
     call    setl_0
     jc      error_dom_xxxx

;
; 5. ������ �� ������� �� ��������

     les     bx,[bp].dword1
     push    es
     push    bx
     les     bx,[bp].dword2
     push    es
     push    bx
     push    elem_len+2
     push    elem_len
     mov     bx,offset r_cbb
     call    rw_cbb
     jc      error_dom_xxxx
     jmp     short get_dom_num	      ;elem_num read to continue

no_more_data2write:
error_dom_xxxx:
     lea     sp,[bp-2]
     ret

sendbuf:
     call    do_back_start
     call    do_back
do_back_end:
     les     bx,[bp+4]
     mov     dx,es:[bx+2]	; temp pos in  buffer
     mov     di,es:[bx+2].parm_o; temp size of buffer
     les     bx,es:[bx].parm_y	; address of the  buffer
     lea     di,[di+bx] 	; offset of end_buf
     xchg    di,bx
     add     di,dx
     ret

do_back_start:
     les     bx,[bp+4]
     sub     di,es:[bx].parm_y
do_back_start2:
     mov     es:[bx+2],di	;buffer position
     cld
     ret

push2_inc:
     pop     dx
     mov     cx,2
pushi3:
     mov     di,parm_y
pushi4:
     dec     di
     dec     di
     push    es:[bx+di].parm_x
     jnz     pushi4
     loop    pushi3
     mov     di,sp
     mov     cx,2
pushi5:
     add     pw ss:[di],1
     adc     pw ss:[di+2],0
     lea     di,[di+4]
     loop    pushi5
     jmp     dx

offset_calc:		; si=0 for domain's offset -  si=4 for element's
     mov     ax,[si].wrm_dsc.parm_x
     sub     ax,[si].dom_offs
     mov     dx,[si+2].wrm_dsc.parm_x
     sub     dx,[si+2].dom_offs
     ret
;-----------------------------------------------------------
;
read_mult:			;     read multiple  Rmulty_cod   =  24
     LES     BX,[BP].DWORD2

     MOV     ax,pw ES:[BX].PARM_O	; size of BUFFER
     MOV     pw ES:[BX+2].PARM_O,ax	; end of BUFFER
     MOV     pw ES:[BX+2],0000H  ; EMPTY BUFFER

;0. ��������� �� �������� ������ � �����
     les     bx,[bp].dword1
     call    push2_inc	 ;  push(el,dom,el+1,dom+1)

;    LES     BX,[BP].DWORD1
     mov     di,dword1
     call    push_dsc_s
     sub     sp,8	; temp variables

     LES     BX,[BP].DWORD2
     push    es
     push    bx 		;address of the cbb_dsc on stack's top

;1. �������� �� �������� ������ 			  1111111
     jmp     next_dom_2

next_dom_:
     mov     ax,old_elnum
     mov     dx,old_elnum+2
     mov     wrm_dsc.parm_y,ax
     mov     wrm_dsc.parm_y+2,dx

;3. ����������� �� ����������-������
;   ��������� �� ������������ � ������
     call    send_domain_num

;4.  �������� �� ������� �������		444444
next_ele_:
     mov     ax,7		; ��� �� �������� - ������� �������
     call    step_funcz 	; ������ �� ������� �����
     jc      some_error 	;
     mov     cx,ax
     and     cx,dx
     inc     cx
     je      next_dom_2

;5.  �������� �� ��������� �� ���������
;    ��� �� � ������� - ������ ��� ����� 1		  1111111
     mov     bx,parm_y
     call    chk_endz
     jae     next_dom_2

;6.  ����������� �� ����������-�������
;    ��������� �� ������������ � ������
     call    send_element_num

;7.  �������� ��������� �� �������
;    ��������� �� ��������� � ������
     call    getl
     jc      some_error

     mov     elem_len,ax
     mov     elem_len+2,dx
     call    len2cbb

;8.  ��������� �� ������� �� �������� � ������
     les     bx,[bp].dword1
     push    es
     push    bx
     les     bx,[bp].dword2
     push    es
     push    bx
     les     bx,elem_len
     push    es
     push    bx
     mov     bx,offset w_cbb
     call    rw_cbb
     jc      some_error
;    les     di,[bp].dword1
;    xor     ax,ax
;    lea     di,[di].parm_o
;    stosw
;    stosw
     jmp     next_ele_
;		      - ������ ��� ����� 4	444444

next_dom_2:
     mov     ax,3		; ��� �� �������� - �������� ������
     call    step_funcz 	; ������ �� ������� �����
     jc      some_error 	;
     mov     cx,ax
     and     cx,dx
     inc     cx
     je      no_more_dom

;2. �������� �� ��������� �� ���������
;    ��� �� � ������� - ���� �� �����������
     mov     bx,parm_x
     call    chk_endz
     jb      next_dom_
No_More_dom:
     LES     BX,[BP].DWORD2
     call    do_back
Some_Error:
     lea     sp,[bp-2]
     ret

;  es:bx points CBB_dsc
;

send_element_num:
     mov     si,4
     call    offset_calc
     jmp     short len2CBB

send_domain_num:
     mov     si,0
     call    offset_calc
     mov     si,0fd00h
     db      03dh	;si<>0
len2CBB:
     xor     si,si	;si=0
     push    bp
     mov     bp,sp
     push    si
     push    dx
     push    ax
     mov     si,4
wh_len:
     mov     al,[bp+si-7]
     or      al,al
     je      wh_len2	;
     cmp     al,63
     jae     wh_len3	;
wh_len2:
     dec     si
     jb      wh_len3	;
     jne     wh_len
wh_len3:
     rcl     si,1	; store cf
     call    do_back_end
     mov     al,[bp-1]
     or      al,al
     je      wh_len4_1
     call    al2buf	;fd
wh_len4_1:
     xor     dx,dx
     shr     si,1	; restore cf
     mov     al,[bp+si-6]
     xchg    dx,si
     jnc     wh_len4	; c=1  =>  al<63
     shl     al,1
     shl     al,1
     or      al,dl	;0..3=cl
     jmp     short  wh_len5
wh_len4:
     mov     al,0ffh	; flag four
     cmp     dl,4
     jz      wh_len5	; ��� ��������� ������� - �� � ����� �� ������
     mov     al,dl
     jmp     short  wh_len5

wh_len5_1:
     mov     al,[bp+si-6]
     inc     si
     dec     dx
wh_len5:
     call    al2buf
     or      dx,dx
     jne     wh_len5_1

     call    do_back_start

     mov     sp,bp
     pop     bp
     ret
;
;
;pak_len:
;
al_to_buf2:
     push    ax
     push    dx
     call    sendbuf
     pop     dx
     pop     ax
al2buf:
     cmp     di,bx
     je      al_to_buf2
     stosb
     ret

gb_readbuf:
     push    es
     push    di
     push    dx
     mov     di,si
     call    sendbuf	;receave buffer
     mov     si,di
     jcxz    gn_err	; end of data flag  zf=1
     pop     dx
     pop     di
     pop     es
gb:	     ;getbyte from callback
     cmp     si,bx
     je      gb_readbuf
     lodsb
     ret

;4 bytes to es:di

getnumber:
     push    bp
     mov     bp,sp
     push    ds
     mov     ax,04	;assume element number
     push    ax
     mov     al,0
     push    ax
     push    ax

     call    do_back_end
     mov     si,di
     push    es
     pop     ds
     push    ss
     pop     es
     mov     di,sp

     call    gtnmb
     mov     di,si
     call    do_back_start
     pop     ax
     pop     dx
     pop     di 	; [bp-4]
     pop     ds
     pop     bp
     ret

gn_err:
     lea     sp,[bp-10]  ;if no more data in CBB
     mov     [bp-4],0ffffh	; end flag
     ret

gtnmb:
     call    gb
     cmp     al,0fdh
     jne     gn_l1
     mov     pw [bp-4],0   ;domain number
     call    gb
gn_l1:
     mov     dx,4
     cmp     al,0ffh	;four	bytes
     jne     gn_l3
gn_l4:
     call    gb
     stosb
gn_l5:
     dec     dx
     jne     gn_l4
     ret
gn_l3:
     cmp     al,0fch
     jae     gn_err
     dec     dx 	;dx=3
     and     dl,al	;
     shr     al,1
     shr     al,1
     push    di
     add     di,dx
     stosb
     pop     di
     inc     dx
     jmp     short gn_l5

; call do_back	with
;   es:bx points to cbb_dsc
;
do_back      proc	near
;    local   noerr_exit
     push    es
     push    bx
     push    dx
     push    ds
     push    si
     push    bp
     push    es
     push    cs
     xor     dx,dx		;old word of buflen
     xor     cx,cx
     xchg    cx,pw es:[bx+2]		;current buff_ptr
;    mov     pw es:[bx+2].parm_o,cx	;current buff_len
     les     di,pd es:[bx].parm_y	;buffer
     mov     si,es
     pop     ds
     pop     es

     mov     pw back_ss,ss   ; save stack
     mov     pw back_sp,sp
     mov     ss,pw old_ss	; old  stack
     mov     sp,pw old_sp

     mov     bp,sp
     lds     bp,[bp+8]	  ;from first stack frame
     push    si
     push    di
     push    dx
     push    cx

     call    pd es:[bx].parm_x
     mov     bx,0
back_ss = $-2
     mov     ss,bx
     mov     sp,0
back_sp = $-2
     pop     bp
     pop     si
     pop     ds
     pop     dx
     pop     bx
     pop     es
     mov     es:[bx+2].parm_o,cx
     mov     es:[bx],ax
     ret

do_back      endp

rw_cbb:
     push    bp
     push    bp
     push    bp
     mov     bp,sp
     call    bx
     lea     sp,[bp+4]
     pop     bp
     ret     12

