#include <dos.h>
#include <iostream.h>
#include <math.h>
#include <conio.h>
#include <stdio.h>
#include <process.h>
#include <stdlib.h>

#ifdef __cplusplus
    #define __CPPARGS ...
#else
    #define __CPPARGS
#endif
extern unsigned _heaplen = 200;
extern unsigned _stklen  = 200;
int suspend=1;
int standby=2;
int sus;
int del;

int mdel;
int mdelreg;


char GetKeybStat()
{
char retcode;
_asm{
    push ds
    push ax
    mov ax,0
    mov ds,ax
    mov al,byte ptr ds:[0x0417]
    mov retcode,al
    pop ax
    pop ds
    }
    return retcode;
}


void interrupt (*BIOSTimer)(__CPPARGS);
void interrupt NewTimer(__CPPARGS)
{
 if (sus!=0)del++;
 if (del > 19)
 {
 del=0;
 if (sus==suspend)
 {
 _asm{
	 mov ax,0x5301
	 mov bx,0x0000
	 int 0x15


	 mov ax,0x5307
	 mov cx,0x0002
	 mov bx,0x0001
	 int 0x15
	 mov ax,0x5304
	 mov bx,0x0000
	 int 0x15
     }
 }
 if (sus==standby)
 {
 _asm{
	 mov ax,0x5301
	 mov bx,0x0000
	 int 0x15

	 mov ax,0x5307
	 mov cx,0x0001
	 mov bx,0x0001
	 int 0x15
	 mov ax,0x5304
	 mov bx,0x0000
	 int 0x15
     }
 }
 sus=0;
 }
 BIOSTimer();
}




void interrupt (*OldKeyb)(__CPPARGS);

void interrupt NewKeyb(__CPPARGS)
{
 char kstat,ret,temp;
 char key;
 mdel=0;
 kstat=GetKeybStat();
 temp=12;
 kstat = kstat & temp;
 if (kstat == 12)
  {
    _asm{
	 in al,0x60
	 mov key,al
	 }
    if (key==31)
    {
     sus=suspend;
    }
    if (key==20)
    {
     sus=standby;
    }
  }

 OldKeyb();

}




char ConnectAPM()
{
char retcode;
_asm{
    mov ax,0x5301
    mov bx,0x0000
    int 0x15
    mov retcode,ah
    }
    return retcode;
}

char DisConnectAPM()
{
char retcode;
_asm{
    mov ax,0x5304
    mov bx,0x0000
    int 0x15
    mov retcode,ah
    }
    return retcode;
}


void main()
{
char maj,min;
int flags;
OldKeyb=getvect(0x09);

//APM Check
textcolor(14);
cprintf("APM Power Management Driver for MS-DOS Version 1.00\r\n");
cprintf("Developed by : Srideep Prasad\r\n");
textcolor(LIGHTBLUE);
cprintf("\r\n");
cprintf("To switch to standby mode press [LEFT ALT] + [LEFT CTRL] + [T]\r\n");
cprintf("To switch to suspend mode press [LEFT ALT] + [LEFT CTRL] + [S]\r\n");
cprintf("To resume MOVE your mouse !\r\n");
textcolor(LIGHTGRAY);

_asm{
    mov ax,0x5300
    mov bx,0
    int 0x15
    mov maj,ah
    mov min,al
    mov flags,cx
    }
    if (maj==0)
    {
    cprintf("APM Problem ! Cannot continue");
	_asm mov ah,0x4c
	_asm int 0x21
    }
    cprintf("APM Version:%i.%i\r\n",maj,min);
    if (0x00000001 & flags)
    {
    cprintf("16 bit PM APM Interface supported\r\n");
    }else cprintf("16 bit PM APM Interface not supported\r\n");

    if(0x00000010 & flags)
    {
    cprintf("32 bit PM APM Interface supported\r\n");
    }else cprintf("32 bit PM APM Interface not supported\r\n");
    if (0x00000100 & flags)
    {
    cprintf("CPU Speed Reduction:On\r\n");
    }else cprintf("CPU Speed Reduction:Off\r\n");

    if (ConnectAPM() != 0x53)
    {
    cprintf("Problem connecting to APM real-mode interface\r\n");
	setvect(0x9,OldKeyb);
	exit (EXIT_FAILURE);
    }

    if (DisConnectAPM() != 0x53)
    {
    cprintf("Problem disconnecting from APM real-mode interface\r\n");
	setvect(0x9,OldKeyb);
	exit (EXIT_FAILURE);
    }

    setvect(0x09,NewKeyb);
    BIOSTimer=getvect(0x1c);
    setvect(0x1c,NewTimer);
    keep(0, (_SS + (_SP/16) - _psp));

}



