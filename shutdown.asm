
_shutdown:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
  shutdown();
   6:	e8 b5 00 00 00       	call   c0 <shutdown>
  exit();
   b:	e8 08 00 00 00       	call   18 <exit>

00000010 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  10:	b8 01 00 00 00       	mov    $0x1,%eax
  15:	cd 40                	int    $0x40
  17:	c3                   	ret    

00000018 <exit>:
SYSCALL(exit)
  18:	b8 02 00 00 00       	mov    $0x2,%eax
  1d:	cd 40                	int    $0x40
  1f:	c3                   	ret    

00000020 <wait>:
SYSCALL(wait)
  20:	b8 03 00 00 00       	mov    $0x3,%eax
  25:	cd 40                	int    $0x40
  27:	c3                   	ret    

00000028 <pipe>:
SYSCALL(pipe)
  28:	b8 04 00 00 00       	mov    $0x4,%eax
  2d:	cd 40                	int    $0x40
  2f:	c3                   	ret    

00000030 <read>:
SYSCALL(read)
  30:	b8 05 00 00 00       	mov    $0x5,%eax
  35:	cd 40                	int    $0x40
  37:	c3                   	ret    

00000038 <write>:
SYSCALL(write)
  38:	b8 10 00 00 00       	mov    $0x10,%eax
  3d:	cd 40                	int    $0x40
  3f:	c3                   	ret    

00000040 <close>:
SYSCALL(close)
  40:	b8 15 00 00 00       	mov    $0x15,%eax
  45:	cd 40                	int    $0x40
  47:	c3                   	ret    

00000048 <kill>:
SYSCALL(kill)
  48:	b8 06 00 00 00       	mov    $0x6,%eax
  4d:	cd 40                	int    $0x40
  4f:	c3                   	ret    

00000050 <exec>:
SYSCALL(exec)
  50:	b8 07 00 00 00       	mov    $0x7,%eax
  55:	cd 40                	int    $0x40
  57:	c3                   	ret    

00000058 <open>:
SYSCALL(open)
  58:	b8 0f 00 00 00       	mov    $0xf,%eax
  5d:	cd 40                	int    $0x40
  5f:	c3                   	ret    

00000060 <mknod>:
SYSCALL(mknod)
  60:	b8 11 00 00 00       	mov    $0x11,%eax
  65:	cd 40                	int    $0x40
  67:	c3                   	ret    

00000068 <unlink>:
SYSCALL(unlink)
  68:	b8 12 00 00 00       	mov    $0x12,%eax
  6d:	cd 40                	int    $0x40
  6f:	c3                   	ret    

00000070 <fstat>:
SYSCALL(fstat)
  70:	b8 08 00 00 00       	mov    $0x8,%eax
  75:	cd 40                	int    $0x40
  77:	c3                   	ret    

00000078 <link>:
SYSCALL(link)
  78:	b8 13 00 00 00       	mov    $0x13,%eax
  7d:	cd 40                	int    $0x40
  7f:	c3                   	ret    

00000080 <mkdir>:
SYSCALL(mkdir)
  80:	b8 14 00 00 00       	mov    $0x14,%eax
  85:	cd 40                	int    $0x40
  87:	c3                   	ret    

00000088 <chdir>:
SYSCALL(chdir)
  88:	b8 09 00 00 00       	mov    $0x9,%eax
  8d:	cd 40                	int    $0x40
  8f:	c3                   	ret    

00000090 <dup>:
SYSCALL(dup)
  90:	b8 0a 00 00 00       	mov    $0xa,%eax
  95:	cd 40                	int    $0x40
  97:	c3                   	ret    

00000098 <getpid>:
SYSCALL(getpid)
  98:	b8 0b 00 00 00       	mov    $0xb,%eax
  9d:	cd 40                	int    $0x40
  9f:	c3                   	ret    

000000a0 <sbrk>:
SYSCALL(sbrk)
  a0:	b8 0c 00 00 00       	mov    $0xc,%eax
  a5:	cd 40                	int    $0x40
  a7:	c3                   	ret    

000000a8 <sleep>:
SYSCALL(sleep)
  a8:	b8 0d 00 00 00       	mov    $0xd,%eax
  ad:	cd 40                	int    $0x40
  af:	c3                   	ret    

000000b0 <uptime>:
SYSCALL(uptime)
  b0:	b8 0e 00 00 00       	mov    $0xe,%eax
  b5:	cd 40                	int    $0x40
  b7:	c3                   	ret    

000000b8 <yield>:
SYSCALL(yield)
  b8:	b8 16 00 00 00       	mov    $0x16,%eax
  bd:	cd 40                	int    $0x40
  bf:	c3                   	ret    

000000c0 <shutdown>:
SYSCALL(shutdown)
  c0:	b8 17 00 00 00       	mov    $0x17,%eax
  c5:	cd 40                	int    $0x40
  c7:	c3                   	ret    

000000c8 <schedlog>:
SYSCALL(schedlog)
  c8:	b8 18 00 00 00       	mov    $0x18,%eax
  cd:	cd 40                	int    $0x40
  cf:	c3                   	ret    

000000d0 <priofork>:
SYSCALL(priofork)
  d0:	b8 19 00 00 00       	mov    $0x19,%eax
  d5:	cd 40                	int    $0x40
  d7:	c3                   	ret    
