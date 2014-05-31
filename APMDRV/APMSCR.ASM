INCLUDE D:\MASM611\BIOS.INC
.model tiny
.286
.data
intro1  db  10,13,'APM Power Management Driver And ScreenSaver for MS-DOS',10,13,'Version 1.0B',10,13,'$'
intro2  db  'Developed By : Srideep Prasad',10,13,'$'
intro3  db  'To suspend press CTRL+ALT+S; To switch to standby mode press CTRL+ALT+T',10,13,10,13,'$'
intro4  db  'To resume press any key or move the mouse',10,13,'$'

apmsucc   db  'APM Services Enabled',10,13,'$'
scrmsg    db  'Monitor will be turned off after x minute(s) of inactivity',10,13,'$'
apmfail   db  'APM Services could not be enabled !',10,13,'$'
abortmsg  db  'APM Not found !',10,13,'$'
mcstart   db  10,13,'Searching for Mouse Driver...$'
mcend     db  'Done',10,13,'$'
mcfound   db  'Mouse Driver Found - Mouse Int 33h Function 0 will be emulated',10,13,'$'
mcnfound  db  'No Mouse Driver found',10,13,'$'
drvfound  db  'APM Driver alreay installed !',10,13,'$'
invparam  db  'Invalid Parameter - Please specify a parameter between 1 and 9 and without',10,13, 'leading (or trailing) spaces.A default delay of 2 min will be used',10,13,'$'
DSuccMsg  db  'Successfully disabled APM ScreenSaver',10,13,'$'
DFailMsg  db  'Unable to disble APM ScreenSaver',10,13,'$'
ESuccMsg  db  'Successfully enabled APM ScreenSaver',10,13,'$'
EFailMsg  db  'Unable to enable APM ScreenSaver',10,13,'$'

NotInst   db  'APM ScreenSaver/Driver not installed',10,13,'$'
.code
           org  100h
start:     jmp  Install

BIOSTimer  dw 00h,00h
BIOSKeyb   dw 00h,00h
Flag       dw 00h,00h
count      dw 00h,00h
Sus        dw 00h,00h
intfac     dw 00h,00h
cparam     db 2h
suscount   dw 00h,00h
msuspend   dw 00h,00h
mcount     dw 00h,00h
InDOSseg   dw 00h,00h
InDOSoff   dw 00h,00h
defCOM1    dw 00h,00h
defCOM2    dw 00h,00h
mAX        dw 00h,00h
mBX        dw 00h,00h
dMouse     dw 00h,00h
mFlag      db 0
disable    db 0



MonitorOff:  push ax
             push bx
             push cx
             call ApmConnect
             mov ax,5307h
             mov bx,01ffh
             mov cx,0003h
             int 15h
             call ApmDisconn
             pop cx
             pop bx
             pop ax
             ret

MonitorOn:   push ax
             push bx
             push cx
             call APMConnect
             mov ax,5307h
             mov bx,01ffh
             mov cx,000h
             int 15h
             call APMDisconn
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


TimerInt:   CLI
            push bx
            pushf

            .if (cs:disable==0)
            .if (cs:msuspend !=1)
            inc cs:mcount
            .if (cs:mcount>=182)
            inc cs:suscount
            mov cs:mcount,0
            .endif
            mov bx,cs:intfac
            .if (cs:suscount >=bx)
            Call MonitorOff
            mov cs:msuspend,1
            .endif
            .endif
            .endif
            popf
            pop bx

            cmp cs:flag,1
            JE TimerInt_1
            sti
            jmp dword ptr cs:BIOSTimer        ; jmp to old interrupt

TimerInt_1: inc cs:count
            cmp cs:count,19
            je TimerInt_2
            sti
            jmp dword ptr cs:BIOSTimer        ; jmp to old interrupt

TimerInt_2: cmp cs:sus,1
            je Suspend
            cmp cs:sus,2
            je StandBy
            mov cs:sus,0
            mov cs:flag,0
            mov cs:count,0
            sti
            jmp dword ptr cs:BIOSTimer        ; jmp to old interrupt


KeybInt:    CLI
            .IF (cs:msuspend==1)
            call MonitorOn
            mov cs:msuspend,0
            .ENDIF

            mov cs:mcount,0
            mov cs:suscount,0

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
            STI
            jmp dword ptr cs:BIOSKeyb

NewCOM1:    CLI
            .IF (cs:msuspend==1)
            call MonitorOn
            mov cs:msuspend,0
            .ENDIF
            mov cs:mcount,0
            mov cs:suscount,0
            STI
            jmp dword ptr cs:defCOM1
NewCOM2:    CLI
            .IF (cs:msuspend==1)
            call MonitorOn
            mov cs:msuspend,0
            .ENDIF
            mov cs:mcount,0
            mov cs:suscount,0
            STI
            jmp dword ptr cs:defCOM2


NewMouse:   cmp ax,0
            je NBypass
            jmp dword ptr cs:dMouse

NBypass:    mov ax,cs:mAX
            mov bx,cs:mBX
            iret



KeybInt_1:           
            in al,60h
            cmp al,31
            je KeybSusp
            cmp al,20
            je KeybStnd
            STI
            jmp dword ptr cs:BIOSKeyb

KeybSusp:   mov cs:flag,1
            mov cs:sus,1
            STI
            jmp dword ptr cs:BIOSKeyb

KeybStnd:   mov cs:flag,1
            mov cs:sus,2
            STI
            jmp dword ptr cs:BIOSKeyb

IsINST:     mov ax,35fAh
            int 21h
            mov dx,es
            .IF (dx !=0) || (bx !=0)
            mov ax,01h
            int 0FAh
           
            .ENDIF
            ret

Intro:      lea dx,intro1
            mov ah,9
            int 21h
            lea dx,intro2
            mov ah,9
            int 21h
            
            Call IsInst
            .if (ax == 0ffh) && (bx == 0ffh) && (cx == 0ffh) && (dx == 0ffh)
            lea dx,drvfound
            mov ah,9
            int 21h
            
            mov ah,4ch
            int 21h
            .ENDIF


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

            call APMConnect

            mov ah,0
            Sahf
            Call APMDisconn
            jc Abort
            popf

            lea dx,apmsucc
            mov ah,9
            int 21h

            lea dx,scrmsg
            mov bx,dx
            mov cx,0
            mov ch,cs:cparam
            mov byte ptr[bx+33],ch
            mov ah,9
            int 21h

            ret

Abort:     popf
           lea dx,apmfail
           mov ah,9
           int 21h
           mov ah,4ch
           int 21h

InstChkInt: .if (ax==01)
            mov ax,0ffh
            mov bx,0ffh
            mov cx,0ffh
            mov dx,0ffh
            .ENDIF
            .if (ax==02h)
            .if (bx==0h)
                mov cs:disable,1
                mov cs:suscount,0
                mov cs:mcount,0
                mov cs:msuspend,0
            .endif
            .if (bx==01h)
                mov cs:disable,0
                mov cs:suscount,0
                mov cs:mcount,0
                mov cs:msuspend,0
            .endif
            mov cx,01h
            .endif
            iret



Install:    mov bx,80h
            mov cl,[bx]
           .IF (cl ==2)
            mov bx,82h
            mov cl,[bx]
            mov cs:cparam,cl
           .ELSEIF (cl >2)
            mov cs:cparam,2
            add cs:cparam,48
            lea dx,invparam
            mov ah,9
            int 21h
           .ELSEIF (cl == 1)
            mov cs:cparam,2
            add cs:cparam,48
            lea dx,invparam
            mov ah,9
            int 21h
           .ELSEIF (cl == 0)
            mov cs:cparam,2
            add cs:cparam,48
           .endif

           .if (cs:cparam == 68) || (cs:cparam==100)
            Call IsInst
            .if (ax != 0ffh) && (bx != 0ffh) && (cx != 0ffh) && (dx != 0ffh)
                lea dx,NotInst
                mov ah,9
                int 21h
                mov ah,4ch
                int 21h
            .ENDIF

            xor cx,cx
            mov ax,02h
            mov bx,0
            int 0fAh
            .if (cx==01)
                lea dx,DSuccMsg
                mov ah,9
                int 21h
                mov ah,4ch
                int 21h
            .ELSEIF (cx==0)
                lea dx,DFailMsg
                mov ah,9
                int 21h
                mov ah,4ch
                int 21h
            .ENDIF
           .ENDIF

           .if (cs:cparam == 69) || (cs:cparam==101)
            Call IsInst
            .if (ax != 0ffh) && (bx != 0ffh) && (cx != 0ffh) && (dx != 0ffh)
                lea dx,NotInst
                mov ah,9
                int 21h
                mov ah,4ch
                int 21h
            .ENDIF

            xor cx,cx
            mov ax,02h
            mov bx,01
            int 0fAh
            .if (cx==01)
                lea dx,ESuccMsg
                mov ah,9
                int 21h
                mov ah,4ch
                int 21h
            .ELSEIF (cx==0)
                lea dx,EFailMsg
                mov ah,9
                int 21h
                mov ah,4ch
                int 21h
            .ENDIF
           .ENDIF


           .if ((cs:cparam < 49) || (cs:cparam >57)) && (cs:cparam !=32)
            mov cs:cparam,2
            lea dx,invparam
            mov ah,9
            int 21h
           .ENDIF
        
           CALL INTRO
           xor ax,ax
           mov cl,cs:cparam
           mov ch,48
           sub cl,ch 
           mov al, 60
           mul cl
           xor dx,dx 
           mov bx,10
           div bx
           mov cs:intfac,ax

           mov ah,34h
           int 21h
           mov cs:InDOSoff,bx
           mov cs:InDOSseg,es

           mov  ax,3509h                ; get old interrupt vector (keyb)
           int  21h

           mov  [BIOSKeyb],bx
           mov  [BIOSKeyb+2],es

           mov  ax,3508h                ; get old interrupt vector (Timer)
           int  21h

           mov  [BIOSTimer],bx
           mov  [BIOSTimer+2],es

           lea dx,mcstart
           mov ah,9
           int 21h

           mov ax,3533h
           int 21h
           mov  [dMouse],bx
           mov  [dMouse+2],es           ; get old interrupt vector(Int33h)

           mov cx,es

           lea dx,mcend
           mov ah,9
           int 21h

           .if (cs:dMouse !=0)
           
           mov ax,0h
           int 33h
           mov cs:mAX,ax
           mov cs:mBX,bx

           .IF (cs:mAX !=0)
            
           lea dx,mcfound
           mov ah,9
           int 21h
           mov cs:mflag,1
           .ELSE
           lea dx,mcnfound
           mov ah,9
           int 21h
           .ENDIF


           .ELSE

           lea dx,mcnfound
           mov ah,9
           int 21h

           .ENDIF


           mov ax,350bh
           int 21h
           mov  [defCOM2],bx
           mov  [defCOM2+2],es           ; get old interrupt vector (COM2)

           mov ax,350Ch
           int 21h
           mov  [defCOM1],bx
           mov  [defCOM1+2],es           ; get old interrupt vector (COM1)

        


           push cs
           pop  ds

           lea  dx,cs:KeybInt  ; set new interrupt vector (Keyb)
           mov  ax,2509h
           int  21h

           lea  dx,cs:TimerInt  ; set new interrupt vector (Timer)
           mov  ax,2508h
           int  21h

           lea dx,cs:NewCOM1    ; set new interrupt vector (COM1)
           mov ax,250ch
           int 21h

           lea dx,cs:NewCOM2    ; set new interrupt vector (COM2)
           mov ax,250Bh
           int 21h


           .if (cs:mflag !=0)
           lea dx, cs:NewMouse   ; set new interrupt vector (Int 33h)
           mov ax,2533h
           int 21h
           .ENDIF

           lea dx,cs:InstChkInt  ; set new interrupt vector (Int FAh)
           mov ax,25FAh
           int 21h


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
