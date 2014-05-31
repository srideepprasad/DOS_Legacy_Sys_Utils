#include <iostream.h>
#include <dos.h>
void main()
{
cout << "Putting system on Standby Mode....\n";

_asm cli

//Enable APM BIOS Services
_asm mov ax,0x5308
_asm mov bx,0x0001
_asm mov cx,0x0002
_asm int 0x15


// Enter Standby Mode
_asm mov ax,0x5307
_asm mov cx,0x0001
_asm mov bx,0x0001
_asm int 0x15

_asm sti

}

