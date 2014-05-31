#include <stdio.h>
#include <conio.h>
void main()
{
char m,n;
asm{
   mov ax,0x1600
   int 0x2f
   mov m,al
   mov n,ah
   }
switch (m)
   {
   case 0: printf("Windows not detected \n"); break ;
   case 0x1:printf("Windows 386/2.x is running \n"); break;
   case 0x80: printf("An obselete XMS 1.0 Driver is installed\n");break;
   case 0xff:printf("Windows 386/2.x is running \n"); break;
   default:printf("Windows Major version:%i\n",m);
	   printf("Windows Minor version:%i\n",n);
	   break;
   }
}






