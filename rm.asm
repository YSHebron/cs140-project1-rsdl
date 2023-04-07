
_rm:     file format elf32-i386


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
  11:	83 ec 18             	sub    $0x18,%esp
  14:	8b 39                	mov    (%ecx),%edi
  16:	8b 41 04             	mov    0x4(%ecx),%eax
  19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int i;

  if(argc < 2){
  1c:	83 ff 01             	cmp    $0x1,%edi
  1f:	7e 07                	jle    28 <main+0x28>
    printf(2, "Usage: rm files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
  21:	bb 01 00 00 00       	mov    $0x1,%ebx
  26:	eb 17                	jmp    3f <main+0x3f>
    printf(2, "Usage: rm files...\n");
  28:	83 ec 08             	sub    $0x8,%esp
  2b:	68 48 03 00 00       	push   $0x348
  30:	6a 02                	push   $0x2
  32:	e8 a9 01 00 00       	call   1e0 <printf>
    exit();
  37:	e8 3f 00 00 00       	call   7b <exit>
  for(i = 1; i < argc; i++){
  3c:	83 c3 01             	add    $0x1,%ebx
  3f:	39 fb                	cmp    %edi,%ebx
  41:	7d 2b                	jge    6e <main+0x6e>
    if(unlink(argv[i]) < 0){
  43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  46:	8d 34 98             	lea    (%eax,%ebx,4),%esi
  49:	83 ec 0c             	sub    $0xc,%esp
  4c:	ff 36                	push   (%esi)
  4e:	e8 78 00 00 00       	call   cb <unlink>
  53:	83 c4 10             	add    $0x10,%esp
  56:	85 c0                	test   %eax,%eax
  58:	79 e2                	jns    3c <main+0x3c>
      printf(2, "rm: %s failed to delete\n", argv[i]);
  5a:	83 ec 04             	sub    $0x4,%esp
  5d:	ff 36                	push   (%esi)
  5f:	68 5c 03 00 00       	push   $0x35c
  64:	6a 02                	push   $0x2
  66:	e8 75 01 00 00       	call   1e0 <printf>
      break;
  6b:	83 c4 10             	add    $0x10,%esp
    }
  }

  exit();
  6e:	e8 08 00 00 00       	call   7b <exit>

00000073 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  73:	b8 01 00 00 00       	mov    $0x1,%eax
  78:	cd 40                	int    $0x40
  7a:	c3                   	ret    

0000007b <exit>:
SYSCALL(exit)
  7b:	b8 02 00 00 00       	mov    $0x2,%eax
  80:	cd 40                	int    $0x40
  82:	c3                   	ret    

00000083 <wait>:
SYSCALL(wait)
  83:	b8 03 00 00 00       	mov    $0x3,%eax
  88:	cd 40                	int    $0x40
  8a:	c3                   	ret    

0000008b <pipe>:
SYSCALL(pipe)
  8b:	b8 04 00 00 00       	mov    $0x4,%eax
  90:	cd 40                	int    $0x40
  92:	c3                   	ret    

00000093 <read>:
SYSCALL(read)
  93:	b8 05 00 00 00       	mov    $0x5,%eax
  98:	cd 40                	int    $0x40
  9a:	c3                   	ret    

0000009b <write>:
SYSCALL(write)
  9b:	b8 10 00 00 00       	mov    $0x10,%eax
  a0:	cd 40                	int    $0x40
  a2:	c3                   	ret    

000000a3 <close>:
SYSCALL(close)
  a3:	b8 15 00 00 00       	mov    $0x15,%eax
  a8:	cd 40                	int    $0x40
  aa:	c3                   	ret    

000000ab <kill>:
SYSCALL(kill)
  ab:	b8 06 00 00 00       	mov    $0x6,%eax
  b0:	cd 40                	int    $0x40
  b2:	c3                   	ret    

000000b3 <exec>:
SYSCALL(exec)
  b3:	b8 07 00 00 00       	mov    $0x7,%eax
  b8:	cd 40                	int    $0x40
  ba:	c3                   	ret    

000000bb <open>:
SYSCALL(open)
  bb:	b8 0f 00 00 00       	mov    $0xf,%eax
  c0:	cd 40                	int    $0x40
  c2:	c3                   	ret    

000000c3 <mknod>:
SYSCALL(mknod)
  c3:	b8 11 00 00 00       	mov    $0x11,%eax
  c8:	cd 40                	int    $0x40
  ca:	c3                   	ret    

000000cb <unlink>:
SYSCALL(unlink)
  cb:	b8 12 00 00 00       	mov    $0x12,%eax
  d0:	cd 40                	int    $0x40
  d2:	c3                   	ret    

000000d3 <fstat>:
SYSCALL(fstat)
  d3:	b8 08 00 00 00       	mov    $0x8,%eax
  d8:	cd 40                	int    $0x40
  da:	c3                   	ret    

000000db <link>:
SYSCALL(link)
  db:	b8 13 00 00 00       	mov    $0x13,%eax
  e0:	cd 40                	int    $0x40
  e2:	c3                   	ret    

000000e3 <mkdir>:
SYSCALL(mkdir)
  e3:	b8 14 00 00 00       	mov    $0x14,%eax
  e8:	cd 40                	int    $0x40
  ea:	c3                   	ret    

000000eb <chdir>:
SYSCALL(chdir)
  eb:	b8 09 00 00 00       	mov    $0x9,%eax
  f0:	cd 40                	int    $0x40
  f2:	c3                   	ret    

000000f3 <dup>:
SYSCALL(dup)
  f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  f8:	cd 40                	int    $0x40
  fa:	c3                   	ret    

000000fb <getpid>:
SYSCALL(getpid)
  fb:	b8 0b 00 00 00       	mov    $0xb,%eax
 100:	cd 40                	int    $0x40
 102:	c3                   	ret    

00000103 <sbrk>:
SYSCALL(sbrk)
 103:	b8 0c 00 00 00       	mov    $0xc,%eax
 108:	cd 40                	int    $0x40
 10a:	c3                   	ret    

0000010b <sleep>:
SYSCALL(sleep)
 10b:	b8 0d 00 00 00       	mov    $0xd,%eax
 110:	cd 40                	int    $0x40
 112:	c3                   	ret    

00000113 <uptime>:
SYSCALL(uptime)
 113:	b8 0e 00 00 00       	mov    $0xe,%eax
 118:	cd 40                	int    $0x40
 11a:	c3                   	ret    

0000011b <yield>:
SYSCALL(yield)
 11b:	b8 16 00 00 00       	mov    $0x16,%eax
 120:	cd 40                	int    $0x40
 122:	c3                   	ret    

00000123 <shutdown>:
SYSCALL(shutdown)
 123:	b8 17 00 00 00       	mov    $0x17,%eax
 128:	cd 40                	int    $0x40
 12a:	c3                   	ret    

0000012b <schedlog>:
SYSCALL(schedlog)
 12b:	b8 18 00 00 00       	mov    $0x18,%eax
 130:	cd 40                	int    $0x40
 132:	c3                   	ret    

00000133 <priofork>:
SYSCALL(priofork)
 133:	b8 19 00 00 00       	mov    $0x19,%eax
 138:	cd 40                	int    $0x40
 13a:	c3                   	ret    

0000013b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 13b:	55                   	push   %ebp
 13c:	89 e5                	mov    %esp,%ebp
 13e:	83 ec 1c             	sub    $0x1c,%esp
 141:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 144:	6a 01                	push   $0x1
 146:	8d 55 f4             	lea    -0xc(%ebp),%edx
 149:	52                   	push   %edx
 14a:	50                   	push   %eax
 14b:	e8 4b ff ff ff       	call   9b <write>
}
 150:	83 c4 10             	add    $0x10,%esp
 153:	c9                   	leave  
 154:	c3                   	ret    

00000155 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 155:	55                   	push   %ebp
 156:	89 e5                	mov    %esp,%ebp
 158:	57                   	push   %edi
 159:	56                   	push   %esi
 15a:	53                   	push   %ebx
 15b:	83 ec 2c             	sub    $0x2c,%esp
 15e:	89 45 d0             	mov    %eax,-0x30(%ebp)
 161:	89 d0                	mov    %edx,%eax
 163:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 165:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 169:	0f 95 c1             	setne  %cl
 16c:	c1 ea 1f             	shr    $0x1f,%edx
 16f:	84 d1                	test   %dl,%cl
 171:	74 44                	je     1b7 <printint+0x62>
    neg = 1;
    x = -xx;
 173:	f7 d8                	neg    %eax
 175:	89 c1                	mov    %eax,%ecx
    neg = 1;
 177:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 17e:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 183:	89 c8                	mov    %ecx,%eax
 185:	ba 00 00 00 00       	mov    $0x0,%edx
 18a:	f7 f6                	div    %esi
 18c:	89 df                	mov    %ebx,%edi
 18e:	83 c3 01             	add    $0x1,%ebx
 191:	0f b6 92 d4 03 00 00 	movzbl 0x3d4(%edx),%edx
 198:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 19c:	89 ca                	mov    %ecx,%edx
 19e:	89 c1                	mov    %eax,%ecx
 1a0:	39 d6                	cmp    %edx,%esi
 1a2:	76 df                	jbe    183 <printint+0x2e>
  if(neg)
 1a4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 1a8:	74 31                	je     1db <printint+0x86>
    buf[i++] = '-';
 1aa:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1af:	8d 5f 02             	lea    0x2(%edi),%ebx
 1b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1b5:	eb 17                	jmp    1ce <printint+0x79>
    x = xx;
 1b7:	89 c1                	mov    %eax,%ecx
  neg = 0;
 1b9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 1c0:	eb bc                	jmp    17e <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 1c2:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1c7:	89 f0                	mov    %esi,%eax
 1c9:	e8 6d ff ff ff       	call   13b <putc>
  while(--i >= 0)
 1ce:	83 eb 01             	sub    $0x1,%ebx
 1d1:	79 ef                	jns    1c2 <printint+0x6d>
}
 1d3:	83 c4 2c             	add    $0x2c,%esp
 1d6:	5b                   	pop    %ebx
 1d7:	5e                   	pop    %esi
 1d8:	5f                   	pop    %edi
 1d9:	5d                   	pop    %ebp
 1da:	c3                   	ret    
 1db:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1de:	eb ee                	jmp    1ce <printint+0x79>

000001e0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1e0:	55                   	push   %ebp
 1e1:	89 e5                	mov    %esp,%ebp
 1e3:	57                   	push   %edi
 1e4:	56                   	push   %esi
 1e5:	53                   	push   %ebx
 1e6:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1e9:	8d 45 10             	lea    0x10(%ebp),%eax
 1ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1ef:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1f4:	bb 00 00 00 00       	mov    $0x0,%ebx
 1f9:	eb 14                	jmp    20f <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1fb:	89 fa                	mov    %edi,%edx
 1fd:	8b 45 08             	mov    0x8(%ebp),%eax
 200:	e8 36 ff ff ff       	call   13b <putc>
 205:	eb 05                	jmp    20c <printf+0x2c>
      }
    } else if(state == '%'){
 207:	83 fe 25             	cmp    $0x25,%esi
 20a:	74 25                	je     231 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 20c:	83 c3 01             	add    $0x1,%ebx
 20f:	8b 45 0c             	mov    0xc(%ebp),%eax
 212:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 216:	84 c0                	test   %al,%al
 218:	0f 84 20 01 00 00    	je     33e <printf+0x15e>
    c = fmt[i] & 0xff;
 21e:	0f be f8             	movsbl %al,%edi
 221:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 224:	85 f6                	test   %esi,%esi
 226:	75 df                	jne    207 <printf+0x27>
      if(c == '%'){
 228:	83 f8 25             	cmp    $0x25,%eax
 22b:	75 ce                	jne    1fb <printf+0x1b>
        state = '%';
 22d:	89 c6                	mov    %eax,%esi
 22f:	eb db                	jmp    20c <printf+0x2c>
      if(c == 'd'){
 231:	83 f8 25             	cmp    $0x25,%eax
 234:	0f 84 cf 00 00 00    	je     309 <printf+0x129>
 23a:	0f 8c dd 00 00 00    	jl     31d <printf+0x13d>
 240:	83 f8 78             	cmp    $0x78,%eax
 243:	0f 8f d4 00 00 00    	jg     31d <printf+0x13d>
 249:	83 f8 63             	cmp    $0x63,%eax
 24c:	0f 8c cb 00 00 00    	jl     31d <printf+0x13d>
 252:	83 e8 63             	sub    $0x63,%eax
 255:	83 f8 15             	cmp    $0x15,%eax
 258:	0f 87 bf 00 00 00    	ja     31d <printf+0x13d>
 25e:	ff 24 85 7c 03 00 00 	jmp    *0x37c(,%eax,4)
        printint(fd, *ap, 10, 1);
 265:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 268:	8b 17                	mov    (%edi),%edx
 26a:	83 ec 0c             	sub    $0xc,%esp
 26d:	6a 01                	push   $0x1
 26f:	b9 0a 00 00 00       	mov    $0xa,%ecx
 274:	8b 45 08             	mov    0x8(%ebp),%eax
 277:	e8 d9 fe ff ff       	call   155 <printint>
        ap++;
 27c:	83 c7 04             	add    $0x4,%edi
 27f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 282:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 285:	be 00 00 00 00       	mov    $0x0,%esi
 28a:	eb 80                	jmp    20c <printf+0x2c>
        printint(fd, *ap, 16, 0);
 28c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 28f:	8b 17                	mov    (%edi),%edx
 291:	83 ec 0c             	sub    $0xc,%esp
 294:	6a 00                	push   $0x0
 296:	b9 10 00 00 00       	mov    $0x10,%ecx
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	e8 b2 fe ff ff       	call   155 <printint>
        ap++;
 2a3:	83 c7 04             	add    $0x4,%edi
 2a6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2a9:	83 c4 10             	add    $0x10,%esp
      state = 0;
 2ac:	be 00 00 00 00       	mov    $0x0,%esi
 2b1:	e9 56 ff ff ff       	jmp    20c <printf+0x2c>
        s = (char*)*ap;
 2b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2b9:	8b 30                	mov    (%eax),%esi
        ap++;
 2bb:	83 c0 04             	add    $0x4,%eax
 2be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2c1:	85 f6                	test   %esi,%esi
 2c3:	75 15                	jne    2da <printf+0xfa>
          s = "(null)";
 2c5:	be 75 03 00 00       	mov    $0x375,%esi
 2ca:	eb 0e                	jmp    2da <printf+0xfa>
          putc(fd, *s);
 2cc:	0f be d2             	movsbl %dl,%edx
 2cf:	8b 45 08             	mov    0x8(%ebp),%eax
 2d2:	e8 64 fe ff ff       	call   13b <putc>
          s++;
 2d7:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 2da:	0f b6 16             	movzbl (%esi),%edx
 2dd:	84 d2                	test   %dl,%dl
 2df:	75 eb                	jne    2cc <printf+0xec>
      state = 0;
 2e1:	be 00 00 00 00       	mov    $0x0,%esi
 2e6:	e9 21 ff ff ff       	jmp    20c <printf+0x2c>
        putc(fd, *ap);
 2eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2ee:	0f be 17             	movsbl (%edi),%edx
 2f1:	8b 45 08             	mov    0x8(%ebp),%eax
 2f4:	e8 42 fe ff ff       	call   13b <putc>
        ap++;
 2f9:	83 c7 04             	add    $0x4,%edi
 2fc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2ff:	be 00 00 00 00       	mov    $0x0,%esi
 304:	e9 03 ff ff ff       	jmp    20c <printf+0x2c>
        putc(fd, c);
 309:	89 fa                	mov    %edi,%edx
 30b:	8b 45 08             	mov    0x8(%ebp),%eax
 30e:	e8 28 fe ff ff       	call   13b <putc>
      state = 0;
 313:	be 00 00 00 00       	mov    $0x0,%esi
 318:	e9 ef fe ff ff       	jmp    20c <printf+0x2c>
        putc(fd, '%');
 31d:	ba 25 00 00 00       	mov    $0x25,%edx
 322:	8b 45 08             	mov    0x8(%ebp),%eax
 325:	e8 11 fe ff ff       	call   13b <putc>
        putc(fd, c);
 32a:	89 fa                	mov    %edi,%edx
 32c:	8b 45 08             	mov    0x8(%ebp),%eax
 32f:	e8 07 fe ff ff       	call   13b <putc>
      state = 0;
 334:	be 00 00 00 00       	mov    $0x0,%esi
 339:	e9 ce fe ff ff       	jmp    20c <printf+0x2c>
    }
  }
}
 33e:	8d 65 f4             	lea    -0xc(%ebp),%esp
 341:	5b                   	pop    %ebx
 342:	5e                   	pop    %esi
 343:	5f                   	pop    %edi
 344:	5d                   	pop    %ebp
 345:	c3                   	ret    
