
#include <stdio.h>
#include <conio.h>


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

void main()
{
 printf("This DOS Prompt will now return to Normal Mode...\n");
 printf("Press any key to continue...");
 getch();
 LeaveCriticalSection();
}
