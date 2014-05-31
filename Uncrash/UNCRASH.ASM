Include D:\Masm611\BIOS.INC
.286
.model tiny
.data
Inst  db 'System Fault Protection program already installed',10,13,'$'

Logo1 db 10,13,'System Fault Protection Program Version 1.00 By Srideep Prasad',10,13,'$'
Logo2 db '--------------------------------------------------------------',10,13,10,13,'$'
Intro1 db 'Programmed In Assembly language',10,13,'$'
Intro2 db 'To terminate ANY program press CTRL-BREAK.',10,13,'$'
Intro3 db '(Even programs that normally do not respond to the keystroke will be terminated)',10,13,'$' 


.code
           org  100h
start:     jmp Install
TLogo1 db 10,13,'System Fault Protection Program Version 1.00 By Srideep Prasad',10,13,'$'
TLogo2 db '--------------------------------------------------------------',10,13,10,13,'$'

term1  db 'Your program has been terminated due to the CTRL-BREAK keystroke.',10,13,'$'
Term2  db 'Your program has been terminated due to a division by zero error,',10,13,'$'
Term3  db 'Your program has been terminated due to an arithmetic overflow error,',10,13,'$'
Term4  db 'Your program has attempted to perform an illegal operation and has been',10,13,'terminated',10,13,'$'
Term5  db 'Your program has caused a bound range exception and has been terminated',10,13,'$'
Term6  db 'Your program has attempted to issue a FPU call when there is no FPU',10,13,'It therefore has been terminated',10,13,'$'
Term7  db 'Your progam has caused a General Protection Fault and will be terminated',10,13,'$'

Wait1  db 'It may take a few moments for your system to start responding(esp under Windows)',10,13,'$'
Wait2  db 'If you system does not respond for some time, reboot your PC',10,13,'$'
defMsg db 1
msgEA  dw 0h,0h
eCount dw 1
bES dw 00h,00h
bBX dw 00h,00h
fCS dw 00h,00h
fIP dw 00h,00h
fault dw 00h,00h

olddosint  dw 00h,00h
olde00 dw 00h,00h
olde04 dw 00h,00h
olde05 dw 00h,00h
olde06 dw 00h,00h
olde07 dw 00h,00h
olde0d dw 00h,00h

IVT  DB 256*4 DUP (0)
defVMode   db 0h 




newDOSInt: pushf
           cmp ax,251bh
           je bypass
           cmp ah,4bh
           je Exec
           popf
           .if (ah==4ch) || (ah==00h) || (ah==31h)
           dec cs:ECount
           .endif
           jmp dword ptr cs:olddosint        ; jmp to old interrupt

bypass:    popf
           iret

Exec:       PUSH AX
            PUSH BX
            PUSH CX

            PUSH DS
            PUSH ES
            PUSH SI
            PUSH DI
        
            MOV AX, 0000H
            MOV DS, AX
            MOV SI, AX
            MOV AX, CS
            MOV ES, AX
            MOV DI, OFFSET IVT
            CLD
            MOV CX, 256*4
            REP MOVSB

            @GetMode
            mov cs:defVMode,al

      
            POP DI
            POP SI
            POP ES
            POP DS
            POP CX
            POP BX
            POP AX

           popf
           inc cs:ECount
           jmp dword ptr cs:olddosint

new00h:    ;Get fault address
           mov cs:bES,es
           mov cs:bBX,bx
           pop bx
           pop es

           mov cs:fIP,bx
           mov cs:fCS,es

           push es
           push bx
           mov es,cs:bES 
           mov bx,cs:bBX
           ;End proc

           ;Is it really a fault ?
           push es
           push bx
           push ax
           mov es,cs:fCS
           mov bx,cs:fIP
           sub bx,2
           mov ah, byte ptr es:[bx]
           mov al, byte ptr es:[bx+1]
           cmp ax,0CD00h
           pop ax
           pop bx
           pop es

           je ExitExcep00
           mov cs:DefMsg,0
           mov cs:msgEA,offset Term2 
           jmp cs:new1bh

ExitExcep00:call dword ptr cs:olde00

new04h:    ;Get fault address
           mov cs:bES,es
           mov cs:bBX,bx
           pop bx
           pop es

           mov cs:fIP,bx
           mov cs:fCS,es

           push es
           push bx
           mov es,cs:bES 
           mov bx,cs:bBX
           ;End proc

           ;Is it really a fault ?
           push es
           push bx
           push ax
           mov es,cs:fCS
           mov bx,cs:fIP
           sub bx,2
           mov ah, byte ptr es:[bx]
           mov al, byte ptr es:[bx+1]
           cmp ax,0CD04h
           pop ax
           pop bx
           pop es

           je ExitExcep04
           mov cs:DefMsg,0
           mov cs:msgEA,offset Term3 
           jmp cs:new1bh

ExitExcep04:call dword ptr cs:olde04

new05h:    ;Get fault address
           mov cs:bES,es
           mov cs:bBX,bx
           pop bx
           pop es

           mov cs:fIP,bx
           mov cs:fCS,es

           push es
           push bx
           mov es,cs:bES 
           mov bx,cs:bBX
           ;End proc

           ;Is it really a fault ?
           push es
           push bx
           push ax
           mov es,cs:fCS
           mov bx,cs:fIP
           sub bx,2
           mov ah, byte ptr es:[bx]
           mov al, byte ptr es:[bx+1]
           cmp ax,0CD05h
           pop ax
           pop bx
           pop es

           je ExitExcep05
           mov cs:DefMsg,0
           mov cs:msgEA,offset Term5
           jmp cs:new1bh
           
ExitExcep05:call dword ptr cs:olde05

new06h:    ;Get fault address
           mov cs:bES,es
           mov cs:bBX,bx
           pop bx
           pop es

           mov cs:fIP,bx
           mov cs:fCS,es

           push es
           push bx
           mov es,cs:bES 
           mov bx,cs:bBX
           ;End proc

           ;Is it really a fault ?
           push es
           push bx
           push ax
           mov es,cs:fCS
           mov bx,cs:fIP
           sub bx,2
           mov ah, byte ptr es:[bx]
           mov al, byte ptr es:[bx+1]
           cmp ax,0CD06h
           pop ax
           pop bx
           pop es

           je ExitExcep06
            
           mov cs:DefMsg,0
           mov cs:msgEA,offset Term4
           jmp cs:new1bh

ExitExcep06:call dword ptr cs:olde06

new07h:    ;Get fault address
           mov cs:bES,es
           mov cs:bBX,bx
           pop bx
           pop es

           mov cs:fIP,bx
           mov cs:fCS,es

           push es
           push bx
           mov es,cs:bES 
           mov bx,cs:bBX
           ;End proc

           ;Is it really a fault ?
           push es
           push bx
           push ax
           mov es,cs:fCS
           mov bx,cs:fIP
           sub bx,2
           mov ah, byte ptr es:[bx]
           mov al, byte ptr es:[bx+1]
           cmp ax,0CD07h
           pop ax
           pop bx
           pop es

           je ExitExcep07
            
           mov cs:DefMsg,0
           mov cs:msgEA,offset Term6
           jmp cs:new1bh

ExitExcep07:call dword ptr cs:olde07

New0Dh:    push ax
           mov al,0Bh
           out 20h,al
           in al,20h
           and al,00100000b
           .if(al==00100000b)
                pop ax
                jmp ExitExcep0D
           .ENDIF
           pop ax 
           mov cs:DefMsg,0
           mov cs:msgEA,offset Term7
           jmp cs:new1bh

ExitExcep0D:call dword ptr cs:olde0D

new1bh:     .IF (CS:ECOUNT !=0)
            cli
            PUSH AX
            PUSH BX
            PUSH CX
            PUSH DX
            PUSH SI
            PUSH DI
            PUSH DS
            PUSH ES
            PUSH BP

            @SetMode cs:defVMode
            MOV AL, 20H
            OUT 20H, AL             ;EOI signal
        
            MOV AX, 0000H
            MOV DI, AX
            MOV ES, AX
            MOV AX, CS
            MOV DS, AX
            MOV SI, OFFSET IVT
            CLD
            MOV CX, 256*4
            REP MOVSB

            lea dx,cs:TLogo1
            mov ah,9
            int 21h

            lea dx,cs:TLogo2
            mov ah,9
            int 21h

            .IF (cs:defmsg==1)
            mov ah,9
            lea dx,cs:Term1
            int 21h

            mov ah,9
            lea dx,cs:Wait1
            int 21h

            mov ah,9
            lea dx,cs:Wait2
            int 21h
            .ELSE
            mov ah,9
            mov dx,cs:msgEA
            int 21h

            mov ah,9
            lea dx,cs:Wait1
            int 21h

            mov ah,9
            lea dx,cs:Wait2
            int 21h
            .ENDIF


            mov cs:defmsg,1
            
            POP BP
            POP ES
            POP DS
            POP DI
            POP SI
            POP DX
            POP CX
            POP BX
            POP AX
            POPF

           
           sti
           popf
           mov ah,4ch
           int 21h
           iret
           .ELSE
           sti
           iret
           .ENDIF

Install:   
           mov  ax,3521h                ; get old interrupt vector(int 21)
           int  21h
           mov  [olddosint],bx
           mov  [olddosint+2],es

           mov  ax,3500h                ; get old interrupt vector(Int 00)
           int  21h
           mov  [olde00],bx
           mov  [olde00+2],es

           mov  ax,3504h                ; get old interrupt vector(Int 04)
           int  21h
           mov  [olde04],bx
           mov  [olde04+2],es

           mov  ax,3505h                ; get old interrupt vector(Int 05)
           int  21h
           mov  [olde05],bx
           mov  [olde05+2],es


           mov  ax,3506h                ; get old interrupt vector(Int 06)
           int  21h
           mov  [olde06],bx
           mov  [olde06+2],es

           mov  ax,3507h                ; get old interrupt vector(Int 07)
           int  21h
           mov  [olde07],bx
           mov  [olde07+2],es


           mov  ax,350Dh                ; get old interrupt vector(Int 0D)
           int  21h
           mov  [olde0D],bx
           mov  [olde0D+2],es

           push cs
           pop  ds

           mov dx,offset cs:new1bh
           mov ax,251bh
           int 21h

           mov  dx,offset cs:newdosint  ; set new interrupt vector
           mov  ax,2521h
           int  21h

           push es
           push bx
           mov ax,0
           mov es,ax
           mov bx,0
           mov word ptr es:[bx],offset cs:new00h
           mov word ptr es:[bx+2],seg cs:new00h
           pop bx
           pop es

           mov  dx,offset cs:new00h  ; set new interrupt vector
           mov  ax,2500h
           int  21h

           mov  dx,offset cs:new04h  ; set new interrupt vector
           mov  ax,2504h
           int  21h

           mov  dx,offset cs:new05h  ; set new interrupt vector
           mov  ax,2505h
           int  21h

           mov  dx,offset cs:new06h  ; set new interrupt vector
           mov  ax,2506h
           int  21h

           mov  dx,offset cs:new07h  ; set new interrupt vector
           mov  ax,2507h
           int  21h

           mov  dx,offset cs:new0Dh  ; set new interrupt vector
           mov  ax,250Dh
           int  21h


           mov  es,cs:[002Ch]           ; free evironment block
           mov  ah,49h
           int  21h

           lea dx,Logo1
           mov ah,9
           int 21h

           lea dx,Logo2
           mov ah,9
           int 21h


           lea dx,Intro1
           mov ah,9
           int 21h

           lea dx,Intro2
           mov ah,9
           int 21h

           lea dx,Intro3
           mov ah,9
           int 21h


           mov  dx,offset cs:Install     ; get paragraphs needed
           sub  dx,offset cs:Start
           shr  dx,04
           add  dx,17                   ; add 16 paras for PSP + 1 extra
           mov  ax,3100h                ; termination and stay resident
           int  21h
end        START
           END 
