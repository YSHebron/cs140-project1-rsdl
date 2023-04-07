
_ln:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	8b 59 04             	mov    0x4(%ecx),%ebx
  if(argc != 3){
  12:	83 39 03             	cmpl   $0x3,(%ecx)
  15:	74 14                	je     2b <main+0x2b>
    printf(2, "Usage: ln old new\n");
  17:	83 ec 08             	sub    $0x8,%esp
  1a:	68 30 03 00 00       	push   $0x330
  1f:	6a 02                	push   $0x2
  21:	e8 a3 01 00 00       	call   1c9 <printf>
    exit();
  26:	e8 39 00 00 00       	call   64 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  2b:	83 ec 08             	sub    $0x8,%esp
  2e:	ff 73 08             	push   0x8(%ebx)
  31:	ff 73 04             	push   0x4(%ebx)
  34:	e8 8b 00 00 00       	call   c4 <link>
  39:	83 c4 10             	add    $0x10,%esp
  3c:	85 c0                	test   %eax,%eax
  3e:	78 05                	js     45 <main+0x45>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit();
  40:	e8 1f 00 00 00       	call   64 <exit>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  45:	ff 73 08             	push   0x8(%ebx)
  48:	ff 73 04             	push   0x4(%ebx)
  4b:	68 43 03 00 00       	push   $0x343
  50:	6a 02                	push   $0x2
  52:	e8 72 01 00 00       	call   1c9 <printf>
  57:	83 c4 10             	add    $0x10,%esp
  5a:	eb e4                	jmp    40 <main+0x40>

0000005c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  5c:	b8 01 00 00 00       	mov    $0x1,%eax
  61:	cd 40                	int    $0x40
  63:	c3                   	ret    

00000064 <exit>:
SYSCALL(exit)
  64:	b8 02 00 00 00       	mov    $0x2,%eax
  69:	cd 40                	int    $0x40
  6b:	c3                   	ret    

0000006c <wait>:
SYSCALL(wait)
  6c:	b8 03 00 00 00       	mov    $0x3,%eax
  71:	cd 40                	int    $0x40
  73:	c3                   	ret    

00000074 <pipe>:
SYSCALL(pipe)
  74:	b8 04 00 00 00       	mov    $0x4,%eax
  79:	cd 40                	int    $0x40
  7b:	c3                   	ret    

0000007c <read>:
SYSCALL(read)
  7c:	b8 05 00 00 00       	mov    $0x5,%eax
  81:	cd 40                	int    $0x40
  83:	c3                   	ret    

00000084 <write>:
SYSCALL(write)
  84:	b8 10 00 00 00       	mov    $0x10,%eax
  89:	cd 40                	int    $0x40
  8b:	c3                   	ret    

0000008c <close>:
SYSCALL(close)
  8c:	b8 15 00 00 00       	mov    $0x15,%eax
  91:	cd 40                	int    $0x40
  93:	c3                   	ret    

00000094 <kill>:
SYSCALL(kill)
  94:	b8 06 00 00 00       	mov    $0x6,%eax
  99:	cd 40                	int    $0x40
  9b:	c3                   	ret    

0000009c <exec>:
SYSCALL(exec)
  9c:	b8 07 00 00 00       	mov    $0x7,%eax
  a1:	cd 40                	int    $0x40
  a3:	c3                   	ret    

000000a4 <open>:
SYSCALL(open)
  a4:	b8 0f 00 00 00       	mov    $0xf,%eax
  a9:	cd 40                	int    $0x40
  ab:	c3                   	ret    

000000ac <mknod>:
SYSCALL(mknod)
  ac:	b8 11 00 00 00       	mov    $0x11,%eax
  b1:	cd 40                	int    $0x40
  b3:	c3                   	ret    

000000b4 <unlink>:
SYSCALL(unlink)
  b4:	b8 12 00 00 00       	mov    $0x12,%eax
  b9:	cd 40                	int    $0x40
  bb:	c3                   	ret    

000000bc <fstat>:
SYSCALL(fstat)
  bc:	b8 08 00 00 00       	mov    $0x8,%eax
  c1:	cd 40                	int    $0x40
  c3:	c3                   	ret    

000000c4 <link>:
SYSCALL(link)
  c4:	b8 13 00 00 00       	mov    $0x13,%eax
  c9:	cd 40                	int    $0x40
  cb:	c3                   	ret    

000000cc <mkdir>:
SYSCALL(mkdir)
  cc:	b8 14 00 00 00       	mov    $0x14,%eax
  d1:	cd 40                	int    $0x40
  d3:	c3                   	ret    

000000d4 <chdir>:
SYSCALL(chdir)
  d4:	b8 09 00 00 00       	mov    $0x9,%eax
  d9:	cd 40                	int    $0x40
  db:	c3                   	ret    

000000dc <dup>:
SYSCALL(dup)
  dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  e1:	cd 40                	int    $0x40
  e3:	c3                   	ret    

000000e4 <getpid>:
SYSCALL(getpid)
  e4:	b8 0b 00 00 00       	mov    $0xb,%eax
  e9:	cd 40                	int    $0x40
  eb:	c3                   	ret    

000000ec <sbrk>:
SYSCALL(sbrk)
  ec:	b8 0c 00 00 00       	mov    $0xc,%eax
  f1:	cd 40                	int    $0x40
  f3:	c3                   	ret    

000000f4 <sleep>:
SYSCALL(sleep)
  f4:	b8 0d 00 00 00       	mov    $0xd,%eax
  f9:	cd 40                	int    $0x40
  fb:	c3                   	ret    

000000fc <uptime>:
SYSCALL(uptime)
  fc:	b8 0e 00 00 00       	mov    $0xe,%eax
 101:	cd 40                	int    $0x40
 103:	c3                   	ret    

00000104 <yield>:
SYSCALL(yield)
 104:	b8 16 00 00 00       	mov    $0x16,%eax
 109:	cd 40                	int    $0x40
 10b:	c3                   	ret    

0000010c <shutdown>:
SYSCALL(shutdown)
 10c:	b8 17 00 00 00       	mov    $0x17,%eax
 111:	cd 40                	int    $0x40
 113:	c3                   	ret    

00000114 <schedlog>:
SYSCALL(schedlog)
 114:	b8 18 00 00 00       	mov    $0x18,%eax
 119:	cd 40                	int    $0x40
 11b:	c3                   	ret    

0000011c <priofork>:
SYSCALL(priofork)
 11c:	b8 19 00 00 00       	mov    $0x19,%eax
 121:	cd 40                	int    $0x40
 123:	c3                   	ret    

00000124 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 124:	55                   	push   %ebp
 125:	89 e5                	mov    %esp,%ebp
 127:	83 ec 1c             	sub    $0x1c,%esp
 12a:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 12d:	6a 01                	push   $0x1
 12f:	8d 55 f4             	lea    -0xc(%ebp),%edx
 132:	52                   	push   %edx
 133:	50                   	push   %eax
 134:	e8 4b ff ff ff       	call   84 <write>
}
 139:	83 c4 10             	add    $0x10,%esp
 13c:	c9                   	leave  
 13d:	c3                   	ret    

0000013e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 13e:	55                   	push   %ebp
 13f:	89 e5                	mov    %esp,%ebp
 141:	57                   	push   %edi
 142:	56                   	push   %esi
 143:	53                   	push   %ebx
 144:	83 ec 2c             	sub    $0x2c,%esp
 147:	89 45 d0             	mov    %eax,-0x30(%ebp)
 14a:	89 d0                	mov    %edx,%eax
 14c:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 14e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 152:	0f 95 c1             	setne  %cl
 155:	c1 ea 1f             	shr    $0x1f,%edx
 158:	84 d1                	test   %dl,%cl
 15a:	74 44                	je     1a0 <printint+0x62>
    neg = 1;
    x = -xx;
 15c:	f7 d8                	neg    %eax
 15e:	89 c1                	mov    %eax,%ecx
    neg = 1;
 160:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 167:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 16c:	89 c8                	mov    %ecx,%eax
 16e:	ba 00 00 00 00       	mov    $0x0,%edx
 173:	f7 f6                	div    %esi
 175:	89 df                	mov    %ebx,%edi
 177:	83 c3 01             	add    $0x1,%ebx
 17a:	0f b6 92 b8 03 00 00 	movzbl 0x3b8(%edx),%edx
 181:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 185:	89 ca                	mov    %ecx,%edx
 187:	89 c1                	mov    %eax,%ecx
 189:	39 d6                	cmp    %edx,%esi
 18b:	76 df                	jbe    16c <printint+0x2e>
  if(neg)
 18d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 191:	74 31                	je     1c4 <printint+0x86>
    buf[i++] = '-';
 193:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 198:	8d 5f 02             	lea    0x2(%edi),%ebx
 19b:	8b 75 d0             	mov    -0x30(%ebp),%esi
 19e:	eb 17                	jmp    1b7 <printint+0x79>
    x = xx;
 1a0:	89 c1                	mov    %eax,%ecx
  neg = 0;
 1a2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 1a9:	eb bc                	jmp    167 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 1ab:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1b0:	89 f0                	mov    %esi,%eax
 1b2:	e8 6d ff ff ff       	call   124 <putc>
  while(--i >= 0)
 1b7:	83 eb 01             	sub    $0x1,%ebx
 1ba:	79 ef                	jns    1ab <printint+0x6d>
}
 1bc:	83 c4 2c             	add    $0x2c,%esp
 1bf:	5b                   	pop    %ebx
 1c0:	5e                   	pop    %esi
 1c1:	5f                   	pop    %edi
 1c2:	5d                   	pop    %ebp
 1c3:	c3                   	ret    
 1c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1c7:	eb ee                	jmp    1b7 <printint+0x79>

000001c9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1c9:	55                   	push   %ebp
 1ca:	89 e5                	mov    %esp,%ebp
 1cc:	57                   	push   %edi
 1cd:	56                   	push   %esi
 1ce:	53                   	push   %ebx
 1cf:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1d2:	8d 45 10             	lea    0x10(%ebp),%eax
 1d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1d8:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1dd:	bb 00 00 00 00       	mov    $0x0,%ebx
 1e2:	eb 14                	jmp    1f8 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1e4:	89 fa                	mov    %edi,%edx
 1e6:	8b 45 08             	mov    0x8(%ebp),%eax
 1e9:	e8 36 ff ff ff       	call   124 <putc>
 1ee:	eb 05                	jmp    1f5 <printf+0x2c>
      }
    } else if(state == '%'){
 1f0:	83 fe 25             	cmp    $0x25,%esi
 1f3:	74 25                	je     21a <printf+0x51>
  for(i = 0; fmt[i]; i++){
 1f5:	83 c3 01             	add    $0x1,%ebx
 1f8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fb:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 1ff:	84 c0                	test   %al,%al
 201:	0f 84 20 01 00 00    	je     327 <printf+0x15e>
    c = fmt[i] & 0xff;
 207:	0f be f8             	movsbl %al,%edi
 20a:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 20d:	85 f6                	test   %esi,%esi
 20f:	75 df                	jne    1f0 <printf+0x27>
      if(c == '%'){
 211:	83 f8 25             	cmp    $0x25,%eax
 214:	75 ce                	jne    1e4 <printf+0x1b>
        state = '%';
 216:	89 c6                	mov    %eax,%esi
 218:	eb db                	jmp    1f5 <printf+0x2c>
      if(c == 'd'){
 21a:	83 f8 25             	cmp    $0x25,%eax
 21d:	0f 84 cf 00 00 00    	je     2f2 <printf+0x129>
 223:	0f 8c dd 00 00 00    	jl     306 <printf+0x13d>
 229:	83 f8 78             	cmp    $0x78,%eax
 22c:	0f 8f d4 00 00 00    	jg     306 <printf+0x13d>
 232:	83 f8 63             	cmp    $0x63,%eax
 235:	0f 8c cb 00 00 00    	jl     306 <printf+0x13d>
 23b:	83 e8 63             	sub    $0x63,%eax
 23e:	83 f8 15             	cmp    $0x15,%eax
 241:	0f 87 bf 00 00 00    	ja     306 <printf+0x13d>
 247:	ff 24 85 60 03 00 00 	jmp    *0x360(,%eax,4)
        printint(fd, *ap, 10, 1);
 24e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 251:	8b 17                	mov    (%edi),%edx
 253:	83 ec 0c             	sub    $0xc,%esp
 256:	6a 01                	push   $0x1
 258:	b9 0a 00 00 00       	mov    $0xa,%ecx
 25d:	8b 45 08             	mov    0x8(%ebp),%eax
 260:	e8 d9 fe ff ff       	call   13e <printint>
        ap++;
 265:	83 c7 04             	add    $0x4,%edi
 268:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 26b:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 26e:	be 00 00 00 00       	mov    $0x0,%esi
 273:	eb 80                	jmp    1f5 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 275:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 278:	8b 17                	mov    (%edi),%edx
 27a:	83 ec 0c             	sub    $0xc,%esp
 27d:	6a 00                	push   $0x0
 27f:	b9 10 00 00 00       	mov    $0x10,%ecx
 284:	8b 45 08             	mov    0x8(%ebp),%eax
 287:	e8 b2 fe ff ff       	call   13e <printint>
        ap++;
 28c:	83 c7 04             	add    $0x4,%edi
 28f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 292:	83 c4 10             	add    $0x10,%esp
      state = 0;
 295:	be 00 00 00 00       	mov    $0x0,%esi
 29a:	e9 56 ff ff ff       	jmp    1f5 <printf+0x2c>
        s = (char*)*ap;
 29f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2a2:	8b 30                	mov    (%eax),%esi
        ap++;
 2a4:	83 c0 04             	add    $0x4,%eax
 2a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2aa:	85 f6                	test   %esi,%esi
 2ac:	75 15                	jne    2c3 <printf+0xfa>
          s = "(null)";
 2ae:	be 57 03 00 00       	mov    $0x357,%esi
 2b3:	eb 0e                	jmp    2c3 <printf+0xfa>
          putc(fd, *s);
 2b5:	0f be d2             	movsbl %dl,%edx
 2b8:	8b 45 08             	mov    0x8(%ebp),%eax
 2bb:	e8 64 fe ff ff       	call   124 <putc>
          s++;
 2c0:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 2c3:	0f b6 16             	movzbl (%esi),%edx
 2c6:	84 d2                	test   %dl,%dl
 2c8:	75 eb                	jne    2b5 <printf+0xec>
      state = 0;
 2ca:	be 00 00 00 00       	mov    $0x0,%esi
 2cf:	e9 21 ff ff ff       	jmp    1f5 <printf+0x2c>
        putc(fd, *ap);
 2d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2d7:	0f be 17             	movsbl (%edi),%edx
 2da:	8b 45 08             	mov    0x8(%ebp),%eax
 2dd:	e8 42 fe ff ff       	call   124 <putc>
        ap++;
 2e2:	83 c7 04             	add    $0x4,%edi
 2e5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2e8:	be 00 00 00 00       	mov    $0x0,%esi
 2ed:	e9 03 ff ff ff       	jmp    1f5 <printf+0x2c>
        putc(fd, c);
 2f2:	89 fa                	mov    %edi,%edx
 2f4:	8b 45 08             	mov    0x8(%ebp),%eax
 2f7:	e8 28 fe ff ff       	call   124 <putc>
      state = 0;
 2fc:	be 00 00 00 00       	mov    $0x0,%esi
 301:	e9 ef fe ff ff       	jmp    1f5 <printf+0x2c>
        putc(fd, '%');
 306:	ba 25 00 00 00       	mov    $0x25,%edx
 30b:	8b 45 08             	mov    0x8(%ebp),%eax
 30e:	e8 11 fe ff ff       	call   124 <putc>
        putc(fd, c);
 313:	89 fa                	mov    %edi,%edx
 315:	8b 45 08             	mov    0x8(%ebp),%eax
 318:	e8 07 fe ff ff       	call   124 <putc>
      state = 0;
 31d:	be 00 00 00 00       	mov    $0x0,%esi
 322:	e9 ce fe ff ff       	jmp    1f5 <printf+0x2c>
    }
  }
}
 327:	8d 65 f4             	lea    -0xc(%ebp),%esp
 32a:	5b                   	pop    %ebx
 32b:	5e                   	pop    %esi
 32c:	5f                   	pop    %edi
 32d:	5d                   	pop    %ebp
 32e:	c3                   	ret    
