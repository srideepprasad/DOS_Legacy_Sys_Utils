
#include <stdio.h>
#include <conio.h>
void IncInDOS()
{
char *c;
_asm mov ah,0x34
_asm int 0x21
_asm mov c,es
*c=(*c)+1;
}

void DecInDOS()
{
char *c;
_asm mov ah,0x34
_asm int 0x21
_asm mov c,es
*c=(*c)-1;
}

void EnterCriticalSection()
{
asm{
   mov ax,0x1681
   int 0x2f
   }
}

void LeaveCriticalSection()
{
asm{
   mov ax,0x1682
   int 0x2f
   }
}
void MakeExclusive()
{
 EnterCriticalSection();
 IncInDOS();
}
void MakeNormal()
{
 LeaveCriticalSection();
 DecInDOS();
}

void main()
{
 EnterCriticalSection();
 IncInDOS();
 printf("Entered Critical Section\n");
 getch();
 LeaveCriticalSection();
 DecInDOS();
}
