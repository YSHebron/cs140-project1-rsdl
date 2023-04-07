
_echo:     file format elf32-i386


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
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 08             	sub    $0x8,%esp
  14:	8b 31                	mov    (%ecx),%esi
  16:	8b 79 04             	mov    0x4(%ecx),%edi
  int i;

  for(i = 1; i < argc; i++)
  19:	b8 01 00 00 00       	mov    $0x1,%eax
  1e:	eb 1a                	jmp    3a <main+0x3a>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  20:	ba 26 03 00 00       	mov    $0x326,%edx
  25:	52                   	push   %edx
  26:	ff 34 87             	push   (%edi,%eax,4)
  29:	68 28 03 00 00       	push   $0x328
  2e:	6a 01                	push   $0x1
  30:	e8 89 01 00 00       	call   1be <printf>
  35:	83 c4 10             	add    $0x10,%esp
  for(i = 1; i < argc; i++)
  38:	89 d8                	mov    %ebx,%eax
  3a:	39 f0                	cmp    %esi,%eax
  3c:	7d 0e                	jge    4c <main+0x4c>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  3e:	8d 58 01             	lea    0x1(%eax),%ebx
  41:	39 f3                	cmp    %esi,%ebx
  43:	7d db                	jge    20 <main+0x20>
  45:	ba 24 03 00 00       	mov    $0x324,%edx
  4a:	eb d9                	jmp    25 <main+0x25>
  exit();
  4c:	e8 08 00 00 00       	call   59 <exit>

00000051 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  51:	b8 01 00 00 00       	mov    $0x1,%eax
  56:	cd 40                	int    $0x40
  58:	c3                   	ret    

00000059 <exit>:
SYSCALL(exit)
  59:	b8 02 00 00 00       	mov    $0x2,%eax
  5e:	cd 40                	int    $0x40
  60:	c3                   	ret    

00000061 <wait>:
SYSCALL(wait)
  61:	b8 03 00 00 00       	mov    $0x3,%eax
  66:	cd 40                	int    $0x40
  68:	c3                   	ret    

00000069 <pipe>:
SYSCALL(pipe)
  69:	b8 04 00 00 00       	mov    $0x4,%eax
  6e:	cd 40                	int    $0x40
  70:	c3                   	ret    

00000071 <read>:
SYSCALL(read)
  71:	b8 05 00 00 00       	mov    $0x5,%eax
  76:	cd 40                	int    $0x40
  78:	c3                   	ret    

00000079 <write>:
SYSCALL(write)
  79:	b8 10 00 00 00       	mov    $0x10,%eax
  7e:	cd 40                	int    $0x40
  80:	c3                   	ret    

00000081 <close>:
SYSCALL(close)
  81:	b8 15 00 00 00       	mov    $0x15,%eax
  86:	cd 40                	int    $0x40
  88:	c3                   	ret    

00000089 <kill>:
SYSCALL(kill)
  89:	b8 06 00 00 00       	mov    $0x6,%eax
  8e:	cd 40                	int    $0x40
  90:	c3                   	ret    

00000091 <exec>:
SYSCALL(exec)
  91:	b8 07 00 00 00       	mov    $0x7,%eax
  96:	cd 40                	int    $0x40
  98:	c3                   	ret    

00000099 <open>:
SYSCALL(open)
  99:	b8 0f 00 00 00       	mov    $0xf,%eax
  9e:	cd 40                	int    $0x40
  a0:	c3                   	ret    

000000a1 <mknod>:
SYSCALL(mknod)
  a1:	b8 11 00 00 00       	mov    $0x11,%eax
  a6:	cd 40                	int    $0x40
  a8:	c3                   	ret    

000000a9 <unlink>:
SYSCALL(unlink)
  a9:	b8 12 00 00 00       	mov    $0x12,%eax
  ae:	cd 40                	int    $0x40
  b0:	c3                   	ret    

000000b1 <fstat>:
SYSCALL(fstat)
  b1:	b8 08 00 00 00       	mov    $0x8,%eax
  b6:	cd 40                	int    $0x40
  b8:	c3                   	ret    

000000b9 <link>:
SYSCALL(link)
  b9:	b8 13 00 00 00       	mov    $0x13,%eax
  be:	cd 40                	int    $0x40
  c0:	c3                   	ret    

000000c1 <mkdir>:
SYSCALL(mkdir)
  c1:	b8 14 00 00 00       	mov    $0x14,%eax
  c6:	cd 40                	int    $0x40
  c8:	c3                   	ret    

000000c9 <chdir>:
SYSCALL(chdir)
  c9:	b8 09 00 00 00       	mov    $0x9,%eax
  ce:	cd 40                	int    $0x40
  d0:	c3                   	ret    

000000d1 <dup>:
SYSCALL(dup)
  d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  d6:	cd 40                	int    $0x40
  d8:	c3                   	ret    

000000d9 <getpid>:
SYSCALL(getpid)
  d9:	b8 0b 00 00 00       	mov    $0xb,%eax
  de:	cd 40                	int    $0x40
  e0:	c3                   	ret    

000000e1 <sbrk>:
SYSCALL(sbrk)
  e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  e6:	cd 40                	int    $0x40
  e8:	c3                   	ret    

000000e9 <sleep>:
SYSCALL(sleep)
  e9:	b8 0d 00 00 00       	mov    $0xd,%eax
  ee:	cd 40                	int    $0x40
  f0:	c3                   	ret    

000000f1 <uptime>:
SYSCALL(uptime)
  f1:	b8 0e 00 00 00       	mov    $0xe,%eax
  f6:	cd 40                	int    $0x40
  f8:	c3                   	ret    

000000f9 <yield>:
SYSCALL(yield)
  f9:	b8 16 00 00 00       	mov    $0x16,%eax
  fe:	cd 40                	int    $0x40
 100:	c3                   	ret    

00000101 <shutdown>:
SYSCALL(shutdown)
 101:	b8 17 00 00 00       	mov    $0x17,%eax
 106:	cd 40                	int    $0x40
 108:	c3                   	ret    

00000109 <schedlog>:
SYSCALL(schedlog)
 109:	b8 18 00 00 00       	mov    $0x18,%eax
 10e:	cd 40                	int    $0x40
 110:	c3                   	ret    

00000111 <priofork>:
SYSCALL(priofork)
 111:	b8 19 00 00 00       	mov    $0x19,%eax
 116:	cd 40                	int    $0x40
 118:	c3                   	ret    

00000119 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 119:	55                   	push   %ebp
 11a:	89 e5                	mov    %esp,%ebp
 11c:	83 ec 1c             	sub    $0x1c,%esp
 11f:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 122:	6a 01                	push   $0x1
 124:	8d 55 f4             	lea    -0xc(%ebp),%edx
 127:	52                   	push   %edx
 128:	50                   	push   %eax
 129:	e8 4b ff ff ff       	call   79 <write>
}
 12e:	83 c4 10             	add    $0x10,%esp
 131:	c9                   	leave  
 132:	c3                   	ret    

00000133 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 133:	55                   	push   %ebp
 134:	89 e5                	mov    %esp,%ebp
 136:	57                   	push   %edi
 137:	56                   	push   %esi
 138:	53                   	push   %ebx
 139:	83 ec 2c             	sub    $0x2c,%esp
 13c:	89 45 d0             	mov    %eax,-0x30(%ebp)
 13f:	89 d0                	mov    %edx,%eax
 141:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 143:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 147:	0f 95 c1             	setne  %cl
 14a:	c1 ea 1f             	shr    $0x1f,%edx
 14d:	84 d1                	test   %dl,%cl
 14f:	74 44                	je     195 <printint+0x62>
    neg = 1;
    x = -xx;
 151:	f7 d8                	neg    %eax
 153:	89 c1                	mov    %eax,%ecx
    neg = 1;
 155:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 15c:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 161:	89 c8                	mov    %ecx,%eax
 163:	ba 00 00 00 00       	mov    $0x0,%edx
 168:	f7 f6                	div    %esi
 16a:	89 df                	mov    %ebx,%edi
 16c:	83 c3 01             	add    $0x1,%ebx
 16f:	0f b6 92 8c 03 00 00 	movzbl 0x38c(%edx),%edx
 176:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 17a:	89 ca                	mov    %ecx,%edx
 17c:	89 c1                	mov    %eax,%ecx
 17e:	39 d6                	cmp    %edx,%esi
 180:	76 df                	jbe    161 <printint+0x2e>
  if(neg)
 182:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 186:	74 31                	je     1b9 <printint+0x86>
    buf[i++] = '-';
 188:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 18d:	8d 5f 02             	lea    0x2(%edi),%ebx
 190:	8b 75 d0             	mov    -0x30(%ebp),%esi
 193:	eb 17                	jmp    1ac <printint+0x79>
    x = xx;
 195:	89 c1                	mov    %eax,%ecx
  neg = 0;
 197:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 19e:	eb bc                	jmp    15c <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 1a0:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1a5:	89 f0                	mov    %esi,%eax
 1a7:	e8 6d ff ff ff       	call   119 <putc>
  while(--i >= 0)
 1ac:	83 eb 01             	sub    $0x1,%ebx
 1af:	79 ef                	jns    1a0 <printint+0x6d>
}
 1b1:	83 c4 2c             	add    $0x2c,%esp
 1b4:	5b                   	pop    %ebx
 1b5:	5e                   	pop    %esi
 1b6:	5f                   	pop    %edi
 1b7:	5d                   	pop    %ebp
 1b8:	c3                   	ret    
 1b9:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1bc:	eb ee                	jmp    1ac <printint+0x79>

000001be <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1be:	55                   	push   %ebp
 1bf:	89 e5                	mov    %esp,%ebp
 1c1:	57                   	push   %edi
 1c2:	56                   	push   %esi
 1c3:	53                   	push   %ebx
 1c4:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1c7:	8d 45 10             	lea    0x10(%ebp),%eax
 1ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1cd:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1d2:	bb 00 00 00 00       	mov    $0x0,%ebx
 1d7:	eb 14                	jmp    1ed <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1d9:	89 fa                	mov    %edi,%edx
 1db:	8b 45 08             	mov    0x8(%ebp),%eax
 1de:	e8 36 ff ff ff       	call   119 <putc>
 1e3:	eb 05                	jmp    1ea <printf+0x2c>
      }
    } else if(state == '%'){
 1e5:	83 fe 25             	cmp    $0x25,%esi
 1e8:	74 25                	je     20f <printf+0x51>
  for(i = 0; fmt[i]; i++){
 1ea:	83 c3 01             	add    $0x1,%ebx
 1ed:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f0:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 1f4:	84 c0                	test   %al,%al
 1f6:	0f 84 20 01 00 00    	je     31c <printf+0x15e>
    c = fmt[i] & 0xff;
 1fc:	0f be f8             	movsbl %al,%edi
 1ff:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 202:	85 f6                	test   %esi,%esi
 204:	75 df                	jne    1e5 <printf+0x27>
      if(c == '%'){
 206:	83 f8 25             	cmp    $0x25,%eax
 209:	75 ce                	jne    1d9 <printf+0x1b>
        state = '%';
 20b:	89 c6                	mov    %eax,%esi
 20d:	eb db                	jmp    1ea <printf+0x2c>
      if(c == 'd'){
 20f:	83 f8 25             	cmp    $0x25,%eax
 212:	0f 84 cf 00 00 00    	je     2e7 <printf+0x129>
 218:	0f 8c dd 00 00 00    	jl     2fb <printf+0x13d>
 21e:	83 f8 78             	cmp    $0x78,%eax
 221:	0f 8f d4 00 00 00    	jg     2fb <printf+0x13d>
 227:	83 f8 63             	cmp    $0x63,%eax
 22a:	0f 8c cb 00 00 00    	jl     2fb <printf+0x13d>
 230:	83 e8 63             	sub    $0x63,%eax
 233:	83 f8 15             	cmp    $0x15,%eax
 236:	0f 87 bf 00 00 00    	ja     2fb <printf+0x13d>
 23c:	ff 24 85 34 03 00 00 	jmp    *0x334(,%eax,4)
        printint(fd, *ap, 10, 1);
 243:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 246:	8b 17                	mov    (%edi),%edx
 248:	83 ec 0c             	sub    $0xc,%esp
 24b:	6a 01                	push   $0x1
 24d:	b9 0a 00 00 00       	mov    $0xa,%ecx
 252:	8b 45 08             	mov    0x8(%ebp),%eax
 255:	e8 d9 fe ff ff       	call   133 <printint>
        ap++;
 25a:	83 c7 04             	add    $0x4,%edi
 25d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 260:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 263:	be 00 00 00 00       	mov    $0x0,%esi
 268:	eb 80                	jmp    1ea <printf+0x2c>
        printint(fd, *ap, 16, 0);
 26a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 26d:	8b 17                	mov    (%edi),%edx
 26f:	83 ec 0c             	sub    $0xc,%esp
 272:	6a 00                	push   $0x0
 274:	b9 10 00 00 00       	mov    $0x10,%ecx
 279:	8b 45 08             	mov    0x8(%ebp),%eax
 27c:	e8 b2 fe ff ff       	call   133 <printint>
        ap++;
 281:	83 c7 04             	add    $0x4,%edi
 284:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 287:	83 c4 10             	add    $0x10,%esp
      state = 0;
 28a:	be 00 00 00 00       	mov    $0x0,%esi
 28f:	e9 56 ff ff ff       	jmp    1ea <printf+0x2c>
        s = (char*)*ap;
 294:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 297:	8b 30                	mov    (%eax),%esi
        ap++;
 299:	83 c0 04             	add    $0x4,%eax
 29c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 29f:	85 f6                	test   %esi,%esi
 2a1:	75 15                	jne    2b8 <printf+0xfa>
          s = "(null)";
 2a3:	be 2d 03 00 00       	mov    $0x32d,%esi
 2a8:	eb 0e                	jmp    2b8 <printf+0xfa>
          putc(fd, *s);
 2aa:	0f be d2             	movsbl %dl,%edx
 2ad:	8b 45 08             	mov    0x8(%ebp),%eax
 2b0:	e8 64 fe ff ff       	call   119 <putc>
          s++;
 2b5:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 2b8:	0f b6 16             	movzbl (%esi),%edx
 2bb:	84 d2                	test   %dl,%dl
 2bd:	75 eb                	jne    2aa <printf+0xec>
      state = 0;
 2bf:	be 00 00 00 00       	mov    $0x0,%esi
 2c4:	e9 21 ff ff ff       	jmp    1ea <printf+0x2c>
        putc(fd, *ap);
 2c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2cc:	0f be 17             	movsbl (%edi),%edx
 2cf:	8b 45 08             	mov    0x8(%ebp),%eax
 2d2:	e8 42 fe ff ff       	call   119 <putc>
        ap++;
 2d7:	83 c7 04             	add    $0x4,%edi
 2da:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2dd:	be 00 00 00 00       	mov    $0x0,%esi
 2e2:	e9 03 ff ff ff       	jmp    1ea <printf+0x2c>
        putc(fd, c);
 2e7:	89 fa                	mov    %edi,%edx
 2e9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ec:	e8 28 fe ff ff       	call   119 <putc>
      state = 0;
 2f1:	be 00 00 00 00       	mov    $0x0,%esi
 2f6:	e9 ef fe ff ff       	jmp    1ea <printf+0x2c>
        putc(fd, '%');
 2fb:	ba 25 00 00 00       	mov    $0x25,%edx
 300:	8b 45 08             	mov    0x8(%ebp),%eax
 303:	e8 11 fe ff ff       	call   119 <putc>
        putc(fd, c);
 308:	89 fa                	mov    %edi,%edx
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	e8 07 fe ff ff       	call   119 <putc>
      state = 0;
 312:	be 00 00 00 00       	mov    $0x0,%esi
 317:	e9 ce fe ff ff       	jmp    1ea <printf+0x2c>
    }
  }
}
 31c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 31f:	5b                   	pop    %ebx
 320:	5e                   	pop    %esi
 321:	5f                   	pop    %edi
 322:	5d                   	pop    %ebp
 323:	c3                   	ret    
