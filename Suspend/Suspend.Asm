.MODEL TINY
.CODE
START:
;      Clear Interruts.
       cli
;      Enable APM BIOS Services
       mov ax,5308h
       mov bx,0001h
       mov cx,0002h
       int 15h
;      Enter suspend mode
       mov ax,5307h
       mov cx,0001h
       mov bx,0001h
       int 15h
;      Re-Enable interrupts
       sti
;      Terminate program
       mov ah,4ch               
       int 21h                  
END START
END
