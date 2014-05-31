
.model tiny
.286
.data
intro1  db  10,13,'APM Power Management Driver For MS-DOS Version 1.00',10,13,'$'
intro2  db  'Developed By : Srideep Prasad',10,13,'$'
intro3  db  'To suspend press CTRL+ALT+S; To switch to standby mode press CTRL+ALT+T',10,13,10,13,'$'
intro4  db  'To resume press any key or move the mouse',10,13,'$'

apmsucc   db  'APM Services Enabled',10,13,'$'
apmfail   db  'APM Services could not be enabled !',10,13,'$'
abortmsg  db  'APM Not found !',10,13,'$'

.code
           org  100h
start:     jmp  Install

BIOSTimer  dw 00h,00h
BIOSKeyb   dw 00h,00h
Flag       dw 00h,00h
count      dw 00h,00h
Sus        dw 00h,00h 

MonitorOff:  push ax
             push bx
             push cx
             mov ax,5307h
             mov bx,01ffh
             mov cx,0003h
             int 15h
             pop cx
             pop bx
             pop ax
             ret

MonitorOn:   push ax
             push bx
             push cx
             mov ax,5307h
             mov bx,01ffh
             mov cx,000h
             int 15h
             pop cx
             pop bx
             pop ax
             ret



APMConnect:  mov ax,5301h
             mov bx,0000h
             int 015h
             ret

APMDisconn:  mov ax,05304h
             mov bx,00000h
             int 015h
             ret

APMEnable:   mov ax,5308h
             mov bx,0FFFFh
             mov cx,01h
             int 15h
             ret

Suspend: pushf
         pusha
         call APMConnect
         mov ax,05307h
         mov cx,00002h
         mov bx,00001h
         int 015h
         call APMDisconn
         mov cs:sus,0
         mov cs:flag,0
         mov cs:count,0
         popa
         popf
         jmp dword ptr cs:BIOSKeyb        ; jmp to old interrupt


StandBy: pushf
         pusha
         Call APMConnect
         mov ax,05307h
         mov cx,00002h
         mov bx,00001h
         int 015h
         Call APMDisconn
         mov cs:sus,0
         mov cs:flag,0
         mov cs:count,0
         popa
         popf
         jmp dword ptr cs:BIOSKeyb        ; jmp to old interrupt


TimerInt:   
            cmp cs:flag,1
            JE TimerInt_1
            jmp dword ptr cs:BIOSTimer        ; jmp to old interrupt

TimerInt_1: inc cs:count
            cmp cs:count,19
            je TimerInt_2
            jmp dword ptr cs:BIOSTimer        ; jmp to old interrupt

TimerInt_2: cmp cs:sus,1
            je Suspend
            cmp cs:sus,2
            je StandBy
            mov cs:sus,0
            mov cs:flag,0
            mov cs:count,0
            jmp dword ptr cs:BIOSTimer        ; jmp to old interrupt


KeybInt:    

            push ds
            push ax
            mov ax,0    
            mov ds,ax
            mov al,byte ptr ds:[0417h]
            AND AL, 00001100B
            CMP AL, 00001100B
            pop ax
            pop ds
            JE KeybInt_1;
            jmp dword ptr cs:BIOSKeyb

KeybInt_1:           
            in al,60h
            cmp al,31
            je KeybSusp
            cmp al,20
            je KeybStnd
            jmp dword ptr cs:BIOSKeyb

KeybSusp:   mov cs:flag,1
            mov cs:sus,1
            jmp dword ptr cs:BIOSKeyb

KeybStnd:   mov cs:flag,1
            mov cs:sus,2
            jmp dword ptr cs:BIOSKeyb

Intro:      lea dx,intro1
            mov ah,9
            int 21h
            lea dx,intro2
            mov ah,9
            int 21h
            lea dx,intro3
            mov ah,9
            int 21h
            lea dx,intro4
            mov ah,9
            int 21h
            mov ax,5300h
            mov bx,0
            int 15h

            .IF (ah==0)
            lea dx,abortmsg
            mov ah,9
            int 21h
            mov ah,4ch
            int 21h
            .ENDIF

            pushf
            mov ah,0
            sahf
            Call APMConnect
            jc Abort

            mov ah,0
            sahf
            call APMEnable
            jc abort

            mov ah,0
            Sahf
            Call APMDisconn
            jc Abort
            popf

            lea dx,apmsucc
            mov ah,9
            int 21h
            ret

Abort:     popf
           lea dx,apmfail
           mov ah,9
           int 21h
           mov ah,4ch
           int 21h

Install:   call Intro
           mov  ax,3509h                ; get old interrupt vector (keyb)
           int  21h

           mov  [BIOSKeyb],bx
           mov  [BIOSKeyb+2],es

           mov  ax,3508h                ; get old interrupt vector (Timer)
           int  21h

           mov  [BIOSTimer],bx
           mov  [BIOSTimer+2],es


           push cs
           pop  ds

           mov  dx,offset cs:KeybInt  ; set new interrupt vector (Keyb)
           mov  ax,2509h
           int  21h

           mov  dx,offset cs:TimerInt  ; set new interrupt vector (Timer)
           mov  ax,2508h
           int  21h


           mov  es,cs:[002Ch]           ; free evironment block
           mov  ah,49h
           int  21h

           mov  dx,offset cs:Install     ; get paragraphs needed
           sub  dx,offset cs:Start
           shr  dx,04
           add  dx,17                   ; add 16 paras for PSP + 1 extra
           mov  ax,3100h                ; termination and stay resident
           int  21h

end        start
           END
