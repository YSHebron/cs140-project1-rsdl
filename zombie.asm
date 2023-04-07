
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 04             	sub    $0x4,%esp
  if(fork() > 0)
  11:	e8 18 00 00 00       	call   2e <fork>
  16:	85 c0                	test   %eax,%eax
  18:	7f 05                	jg     1f <main+0x1f>
    sleep(5);  // Let child exit before parent.
  exit();
  1a:	e8 17 00 00 00       	call   36 <exit>
    sleep(5);  // Let child exit before parent.
  1f:	83 ec 0c             	sub    $0xc,%esp
  22:	6a 05                	push   $0x5
  24:	e8 9d 00 00 00       	call   c6 <sleep>
  29:	83 c4 10             	add    $0x10,%esp
  2c:	eb ec                	jmp    1a <main+0x1a>

0000002e <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  2e:	b8 01 00 00 00       	mov    $0x1,%eax
  33:	cd 40                	int    $0x40
  35:	c3                   	ret    

00000036 <exit>:
SYSCALL(exit)
  36:	b8 02 00 00 00       	mov    $0x2,%eax
  3b:	cd 40                	int    $0x40
  3d:	c3                   	ret    

0000003e <wait>:
SYSCALL(wait)
  3e:	b8 03 00 00 00       	mov    $0x3,%eax
  43:	cd 40                	int    $0x40
  45:	c3                   	ret    

00000046 <pipe>:
SYSCALL(pipe)
  46:	b8 04 00 00 00       	mov    $0x4,%eax
  4b:	cd 40                	int    $0x40
  4d:	c3                   	ret    

0000004e <read>:
SYSCALL(read)
  4e:	b8 05 00 00 00       	mov    $0x5,%eax
  53:	cd 40                	int    $0x40
  55:	c3                   	ret    

00000056 <write>:
SYSCALL(write)
  56:	b8 10 00 00 00       	mov    $0x10,%eax
  5b:	cd 40                	int    $0x40
  5d:	c3                   	ret    

0000005e <close>:
SYSCALL(close)
  5e:	b8 15 00 00 00       	mov    $0x15,%eax
  63:	cd 40                	int    $0x40
  65:	c3                   	ret    

00000066 <kill>:
SYSCALL(kill)
  66:	b8 06 00 00 00       	mov    $0x6,%eax
  6b:	cd 40                	int    $0x40
  6d:	c3                   	ret    

0000006e <exec>:
SYSCALL(exec)
  6e:	b8 07 00 00 00       	mov    $0x7,%eax
  73:	cd 40                	int    $0x40
  75:	c3                   	ret    

00000076 <open>:
SYSCALL(open)
  76:	b8 0f 00 00 00       	mov    $0xf,%eax
  7b:	cd 40                	int    $0x40
  7d:	c3                   	ret    

0000007e <mknod>:
SYSCALL(mknod)
  7e:	b8 11 00 00 00       	mov    $0x11,%eax
  83:	cd 40                	int    $0x40
  85:	c3                   	ret    

00000086 <unlink>:
SYSCALL(unlink)
  86:	b8 12 00 00 00       	mov    $0x12,%eax
  8b:	cd 40                	int    $0x40
  8d:	c3                   	ret    

0000008e <fstat>:
SYSCALL(fstat)
  8e:	b8 08 00 00 00       	mov    $0x8,%eax
  93:	cd 40                	int    $0x40
  95:	c3                   	ret    

00000096 <link>:
SYSCALL(link)
  96:	b8 13 00 00 00       	mov    $0x13,%eax
  9b:	cd 40                	int    $0x40
  9d:	c3                   	ret    

0000009e <mkdir>:
SYSCALL(mkdir)
  9e:	b8 14 00 00 00       	mov    $0x14,%eax
  a3:	cd 40                	int    $0x40
  a5:	c3                   	ret    

000000a6 <chdir>:
SYSCALL(chdir)
  a6:	b8 09 00 00 00       	mov    $0x9,%eax
  ab:	cd 40                	int    $0x40
  ad:	c3                   	ret    

000000ae <dup>:
SYSCALL(dup)
  ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  b3:	cd 40                	int    $0x40
  b5:	c3                   	ret    

000000b6 <getpid>:
SYSCALL(getpid)
  b6:	b8 0b 00 00 00       	mov    $0xb,%eax
  bb:	cd 40                	int    $0x40
  bd:	c3                   	ret    

000000be <sbrk>:
SYSCALL(sbrk)
  be:	b8 0c 00 00 00       	mov    $0xc,%eax
  c3:	cd 40                	int    $0x40
  c5:	c3                   	ret    

000000c6 <sleep>:
SYSCALL(sleep)
  c6:	b8 0d 00 00 00       	mov    $0xd,%eax
  cb:	cd 40                	int    $0x40
  cd:	c3                   	ret    

000000ce <uptime>:
SYSCALL(uptime)
  ce:	b8 0e 00 00 00       	mov    $0xe,%eax
  d3:	cd 40                	int    $0x40
  d5:	c3                   	ret    

000000d6 <yield>:
SYSCALL(yield)
  d6:	b8 16 00 00 00       	mov    $0x16,%eax
  db:	cd 40                	int    $0x40
  dd:	c3                   	ret    

000000de <shutdown>:
SYSCALL(shutdown)
  de:	b8 17 00 00 00       	mov    $0x17,%eax
  e3:	cd 40                	int    $0x40
  e5:	c3                   	ret    

000000e6 <schedlog>:
SYSCALL(schedlog)
  e6:	b8 18 00 00 00       	mov    $0x18,%eax
  eb:	cd 40                	int    $0x40
  ed:	c3                   	ret    

000000ee <priofork>:
SYSCALL(priofork)
  ee:	b8 19 00 00 00       	mov    $0x19,%eax
  f3:	cd 40                	int    $0x40
  f5:	c3                   	ret    
