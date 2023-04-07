
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	8b 75 08             	mov    0x8(%ebp),%esi
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
   8:	83 ec 04             	sub    $0x4,%esp
   b:	68 00 02 00 00       	push   $0x200
  10:	68 80 04 00 00       	push   $0x480
  15:	56                   	push   %esi
  16:	e8 fd 00 00 00       	call   118 <read>
  1b:	89 c3                	mov    %eax,%ebx
  1d:	83 c4 10             	add    $0x10,%esp
  20:	85 c0                	test   %eax,%eax
  22:	7e 2b                	jle    4f <cat+0x4f>
    if (write(1, buf, n) != n) {
  24:	83 ec 04             	sub    $0x4,%esp
  27:	53                   	push   %ebx
  28:	68 80 04 00 00       	push   $0x480
  2d:	6a 01                	push   $0x1
  2f:	e8 ec 00 00 00       	call   120 <write>
  34:	83 c4 10             	add    $0x10,%esp
  37:	39 d8                	cmp    %ebx,%eax
  39:	74 cd                	je     8 <cat+0x8>
      printf(1, "cat: write error\n");
  3b:	83 ec 08             	sub    $0x8,%esp
  3e:	68 cc 03 00 00       	push   $0x3cc
  43:	6a 01                	push   $0x1
  45:	e8 1b 02 00 00       	call   265 <printf>
      exit();
  4a:	e8 b1 00 00 00       	call   100 <exit>
    }
  }
  if(n < 0){
  4f:	78 07                	js     58 <cat+0x58>
    printf(1, "cat: read error\n");
    exit();
  }
}
  51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  54:	5b                   	pop    %ebx
  55:	5e                   	pop    %esi
  56:	5d                   	pop    %ebp
  57:	c3                   	ret    
    printf(1, "cat: read error\n");
  58:	83 ec 08             	sub    $0x8,%esp
  5b:	68 de 03 00 00       	push   $0x3de
  60:	6a 01                	push   $0x1
  62:	e8 fe 01 00 00       	call   265 <printf>
    exit();
  67:	e8 94 00 00 00       	call   100 <exit>

0000006c <main>:

int
main(int argc, char *argv[])
{
  6c:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  70:	83 e4 f0             	and    $0xfffffff0,%esp
  73:	ff 71 fc             	push   -0x4(%ecx)
  76:	55                   	push   %ebp
  77:	89 e5                	mov    %esp,%ebp
  79:	57                   	push   %edi
  7a:	56                   	push   %esi
  7b:	53                   	push   %ebx
  7c:	51                   	push   %ecx
  7d:	83 ec 18             	sub    $0x18,%esp
  80:	8b 01                	mov    (%ecx),%eax
  82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  85:	8b 51 04             	mov    0x4(%ecx),%edx
  88:	89 55 e0             	mov    %edx,-0x20(%ebp)
  int fd, i;

  if(argc <= 1){
  8b:	83 f8 01             	cmp    $0x1,%eax
  8e:	7e 07                	jle    97 <main+0x2b>
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
  90:	be 01 00 00 00       	mov    $0x1,%esi
  95:	eb 26                	jmp    bd <main+0x51>
    cat(0);
  97:	83 ec 0c             	sub    $0xc,%esp
  9a:	6a 00                	push   $0x0
  9c:	e8 5f ff ff ff       	call   0 <cat>
    exit();
  a1:	e8 5a 00 00 00       	call   100 <exit>
    if((fd = open(argv[i], 0)) < 0){
      printf(1, "cat: cannot open %s\n", argv[i]);
      exit();
    }
    cat(fd);
  a6:	83 ec 0c             	sub    $0xc,%esp
  a9:	50                   	push   %eax
  aa:	e8 51 ff ff ff       	call   0 <cat>
    close(fd);
  af:	89 1c 24             	mov    %ebx,(%esp)
  b2:	e8 71 00 00 00       	call   128 <close>
  for(i = 1; i < argc; i++){
  b7:	83 c6 01             	add    $0x1,%esi
  ba:	83 c4 10             	add    $0x10,%esp
  bd:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
  c0:	7d 31                	jge    f3 <main+0x87>
    if((fd = open(argv[i], 0)) < 0){
  c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  c5:	8d 3c b0             	lea    (%eax,%esi,4),%edi
  c8:	83 ec 08             	sub    $0x8,%esp
  cb:	6a 00                	push   $0x0
  cd:	ff 37                	push   (%edi)
  cf:	e8 6c 00 00 00       	call   140 <open>
  d4:	89 c3                	mov    %eax,%ebx
  d6:	83 c4 10             	add    $0x10,%esp
  d9:	85 c0                	test   %eax,%eax
  db:	79 c9                	jns    a6 <main+0x3a>
      printf(1, "cat: cannot open %s\n", argv[i]);
  dd:	83 ec 04             	sub    $0x4,%esp
  e0:	ff 37                	push   (%edi)
  e2:	68 ef 03 00 00       	push   $0x3ef
  e7:	6a 01                	push   $0x1
  e9:	e8 77 01 00 00       	call   265 <printf>
      exit();
  ee:	e8 0d 00 00 00       	call   100 <exit>
  }
  exit();
  f3:	e8 08 00 00 00       	call   100 <exit>

000000f8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  f8:	b8 01 00 00 00       	mov    $0x1,%eax
  fd:	cd 40                	int    $0x40
  ff:	c3                   	ret    

00000100 <exit>:
SYSCALL(exit)
 100:	b8 02 00 00 00       	mov    $0x2,%eax
 105:	cd 40                	int    $0x40
 107:	c3                   	ret    

00000108 <wait>:
SYSCALL(wait)
 108:	b8 03 00 00 00       	mov    $0x3,%eax
 10d:	cd 40                	int    $0x40
 10f:	c3                   	ret    

00000110 <pipe>:
SYSCALL(pipe)
 110:	b8 04 00 00 00       	mov    $0x4,%eax
 115:	cd 40                	int    $0x40
 117:	c3                   	ret    

00000118 <read>:
SYSCALL(read)
 118:	b8 05 00 00 00       	mov    $0x5,%eax
 11d:	cd 40                	int    $0x40
 11f:	c3                   	ret    

00000120 <write>:
SYSCALL(write)
 120:	b8 10 00 00 00       	mov    $0x10,%eax
 125:	cd 40                	int    $0x40
 127:	c3                   	ret    

00000128 <close>:
SYSCALL(close)
 128:	b8 15 00 00 00       	mov    $0x15,%eax
 12d:	cd 40                	int    $0x40
 12f:	c3                   	ret    

00000130 <kill>:
SYSCALL(kill)
 130:	b8 06 00 00 00       	mov    $0x6,%eax
 135:	cd 40                	int    $0x40
 137:	c3                   	ret    

00000138 <exec>:
SYSCALL(exec)
 138:	b8 07 00 00 00       	mov    $0x7,%eax
 13d:	cd 40                	int    $0x40
 13f:	c3                   	ret    

00000140 <open>:
SYSCALL(open)
 140:	b8 0f 00 00 00       	mov    $0xf,%eax
 145:	cd 40                	int    $0x40
 147:	c3                   	ret    

00000148 <mknod>:
SYSCALL(mknod)
 148:	b8 11 00 00 00       	mov    $0x11,%eax
 14d:	cd 40                	int    $0x40
 14f:	c3                   	ret    

00000150 <unlink>:
SYSCALL(unlink)
 150:	b8 12 00 00 00       	mov    $0x12,%eax
 155:	cd 40                	int    $0x40
 157:	c3                   	ret    

00000158 <fstat>:
SYSCALL(fstat)
 158:	b8 08 00 00 00       	mov    $0x8,%eax
 15d:	cd 40                	int    $0x40
 15f:	c3                   	ret    

00000160 <link>:
SYSCALL(link)
 160:	b8 13 00 00 00       	mov    $0x13,%eax
 165:	cd 40                	int    $0x40
 167:	c3                   	ret    

00000168 <mkdir>:
SYSCALL(mkdir)
 168:	b8 14 00 00 00       	mov    $0x14,%eax
 16d:	cd 40                	int    $0x40
 16f:	c3                   	ret    

00000170 <chdir>:
SYSCALL(chdir)
 170:	b8 09 00 00 00       	mov    $0x9,%eax
 175:	cd 40                	int    $0x40
 177:	c3                   	ret    

00000178 <dup>:
SYSCALL(dup)
 178:	b8 0a 00 00 00       	mov    $0xa,%eax
 17d:	cd 40                	int    $0x40
 17f:	c3                   	ret    

00000180 <getpid>:
SYSCALL(getpid)
 180:	b8 0b 00 00 00       	mov    $0xb,%eax
 185:	cd 40                	int    $0x40
 187:	c3                   	ret    

00000188 <sbrk>:
SYSCALL(sbrk)
 188:	b8 0c 00 00 00       	mov    $0xc,%eax
 18d:	cd 40                	int    $0x40
 18f:	c3                   	ret    

00000190 <sleep>:
SYSCALL(sleep)
 190:	b8 0d 00 00 00       	mov    $0xd,%eax
 195:	cd 40                	int    $0x40
 197:	c3                   	ret    

00000198 <uptime>:
SYSCALL(uptime)
 198:	b8 0e 00 00 00       	mov    $0xe,%eax
 19d:	cd 40                	int    $0x40
 19f:	c3                   	ret    

000001a0 <yield>:
SYSCALL(yield)
 1a0:	b8 16 00 00 00       	mov    $0x16,%eax
 1a5:	cd 40                	int    $0x40
 1a7:	c3                   	ret    

000001a8 <shutdown>:
SYSCALL(shutdown)
 1a8:	b8 17 00 00 00       	mov    $0x17,%eax
 1ad:	cd 40                	int    $0x40
 1af:	c3                   	ret    

000001b0 <schedlog>:
SYSCALL(schedlog)
 1b0:	b8 18 00 00 00       	mov    $0x18,%eax
 1b5:	cd 40                	int    $0x40
 1b7:	c3                   	ret    

000001b8 <priofork>:
SYSCALL(priofork)
 1b8:	b8 19 00 00 00       	mov    $0x19,%eax
 1bd:	cd 40                	int    $0x40
 1bf:	c3                   	ret    

000001c0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 1c0:	55                   	push   %ebp
 1c1:	89 e5                	mov    %esp,%ebp
 1c3:	83 ec 1c             	sub    $0x1c,%esp
 1c6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 1c9:	6a 01                	push   $0x1
 1cb:	8d 55 f4             	lea    -0xc(%ebp),%edx
 1ce:	52                   	push   %edx
 1cf:	50                   	push   %eax
 1d0:	e8 4b ff ff ff       	call   120 <write>
}
 1d5:	83 c4 10             	add    $0x10,%esp
 1d8:	c9                   	leave  
 1d9:	c3                   	ret    

000001da <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 1da:	55                   	push   %ebp
 1db:	89 e5                	mov    %esp,%ebp
 1dd:	57                   	push   %edi
 1de:	56                   	push   %esi
 1df:	53                   	push   %ebx
 1e0:	83 ec 2c             	sub    $0x2c,%esp
 1e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
 1e6:	89 d0                	mov    %edx,%eax
 1e8:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 1ea:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1ee:	0f 95 c1             	setne  %cl
 1f1:	c1 ea 1f             	shr    $0x1f,%edx
 1f4:	84 d1                	test   %dl,%cl
 1f6:	74 44                	je     23c <printint+0x62>
    neg = 1;
    x = -xx;
 1f8:	f7 d8                	neg    %eax
 1fa:	89 c1                	mov    %eax,%ecx
    neg = 1;
 1fc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 203:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 208:	89 c8                	mov    %ecx,%eax
 20a:	ba 00 00 00 00       	mov    $0x0,%edx
 20f:	f7 f6                	div    %esi
 211:	89 df                	mov    %ebx,%edi
 213:	83 c3 01             	add    $0x1,%ebx
 216:	0f b6 92 64 04 00 00 	movzbl 0x464(%edx),%edx
 21d:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 221:	89 ca                	mov    %ecx,%edx
 223:	89 c1                	mov    %eax,%ecx
 225:	39 d6                	cmp    %edx,%esi
 227:	76 df                	jbe    208 <printint+0x2e>
  if(neg)
 229:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 22d:	74 31                	je     260 <printint+0x86>
    buf[i++] = '-';
 22f:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 234:	8d 5f 02             	lea    0x2(%edi),%ebx
 237:	8b 75 d0             	mov    -0x30(%ebp),%esi
 23a:	eb 17                	jmp    253 <printint+0x79>
    x = xx;
 23c:	89 c1                	mov    %eax,%ecx
  neg = 0;
 23e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 245:	eb bc                	jmp    203 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 247:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 24c:	89 f0                	mov    %esi,%eax
 24e:	e8 6d ff ff ff       	call   1c0 <putc>
  while(--i >= 0)
 253:	83 eb 01             	sub    $0x1,%ebx
 256:	79 ef                	jns    247 <printint+0x6d>
}
 258:	83 c4 2c             	add    $0x2c,%esp
 25b:	5b                   	pop    %ebx
 25c:	5e                   	pop    %esi
 25d:	5f                   	pop    %edi
 25e:	5d                   	pop    %ebp
 25f:	c3                   	ret    
 260:	8b 75 d0             	mov    -0x30(%ebp),%esi
 263:	eb ee                	jmp    253 <printint+0x79>

00000265 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 265:	55                   	push   %ebp
 266:	89 e5                	mov    %esp,%ebp
 268:	57                   	push   %edi
 269:	56                   	push   %esi
 26a:	53                   	push   %ebx
 26b:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 26e:	8d 45 10             	lea    0x10(%ebp),%eax
 271:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 274:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 279:	bb 00 00 00 00       	mov    $0x0,%ebx
 27e:	eb 14                	jmp    294 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 280:	89 fa                	mov    %edi,%edx
 282:	8b 45 08             	mov    0x8(%ebp),%eax
 285:	e8 36 ff ff ff       	call   1c0 <putc>
 28a:	eb 05                	jmp    291 <printf+0x2c>
      }
    } else if(state == '%'){
 28c:	83 fe 25             	cmp    $0x25,%esi
 28f:	74 25                	je     2b6 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 291:	83 c3 01             	add    $0x1,%ebx
 294:	8b 45 0c             	mov    0xc(%ebp),%eax
 297:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 29b:	84 c0                	test   %al,%al
 29d:	0f 84 20 01 00 00    	je     3c3 <printf+0x15e>
    c = fmt[i] & 0xff;
 2a3:	0f be f8             	movsbl %al,%edi
 2a6:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 2a9:	85 f6                	test   %esi,%esi
 2ab:	75 df                	jne    28c <printf+0x27>
      if(c == '%'){
 2ad:	83 f8 25             	cmp    $0x25,%eax
 2b0:	75 ce                	jne    280 <printf+0x1b>
        state = '%';
 2b2:	89 c6                	mov    %eax,%esi
 2b4:	eb db                	jmp    291 <printf+0x2c>
      if(c == 'd'){
 2b6:	83 f8 25             	cmp    $0x25,%eax
 2b9:	0f 84 cf 00 00 00    	je     38e <printf+0x129>
 2bf:	0f 8c dd 00 00 00    	jl     3a2 <printf+0x13d>
 2c5:	83 f8 78             	cmp    $0x78,%eax
 2c8:	0f 8f d4 00 00 00    	jg     3a2 <printf+0x13d>
 2ce:	83 f8 63             	cmp    $0x63,%eax
 2d1:	0f 8c cb 00 00 00    	jl     3a2 <printf+0x13d>
 2d7:	83 e8 63             	sub    $0x63,%eax
 2da:	83 f8 15             	cmp    $0x15,%eax
 2dd:	0f 87 bf 00 00 00    	ja     3a2 <printf+0x13d>
 2e3:	ff 24 85 0c 04 00 00 	jmp    *0x40c(,%eax,4)
        printint(fd, *ap, 10, 1);
 2ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2ed:	8b 17                	mov    (%edi),%edx
 2ef:	83 ec 0c             	sub    $0xc,%esp
 2f2:	6a 01                	push   $0x1
 2f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2f9:	8b 45 08             	mov    0x8(%ebp),%eax
 2fc:	e8 d9 fe ff ff       	call   1da <printint>
        ap++;
 301:	83 c7 04             	add    $0x4,%edi
 304:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 307:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 30a:	be 00 00 00 00       	mov    $0x0,%esi
 30f:	eb 80                	jmp    291 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 314:	8b 17                	mov    (%edi),%edx
 316:	83 ec 0c             	sub    $0xc,%esp
 319:	6a 00                	push   $0x0
 31b:	b9 10 00 00 00       	mov    $0x10,%ecx
 320:	8b 45 08             	mov    0x8(%ebp),%eax
 323:	e8 b2 fe ff ff       	call   1da <printint>
        ap++;
 328:	83 c7 04             	add    $0x4,%edi
 32b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 32e:	83 c4 10             	add    $0x10,%esp
      state = 0;
 331:	be 00 00 00 00       	mov    $0x0,%esi
 336:	e9 56 ff ff ff       	jmp    291 <printf+0x2c>
        s = (char*)*ap;
 33b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 33e:	8b 30                	mov    (%eax),%esi
        ap++;
 340:	83 c0 04             	add    $0x4,%eax
 343:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 346:	85 f6                	test   %esi,%esi
 348:	75 15                	jne    35f <printf+0xfa>
          s = "(null)";
 34a:	be 04 04 00 00       	mov    $0x404,%esi
 34f:	eb 0e                	jmp    35f <printf+0xfa>
          putc(fd, *s);
 351:	0f be d2             	movsbl %dl,%edx
 354:	8b 45 08             	mov    0x8(%ebp),%eax
 357:	e8 64 fe ff ff       	call   1c0 <putc>
          s++;
 35c:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 35f:	0f b6 16             	movzbl (%esi),%edx
 362:	84 d2                	test   %dl,%dl
 364:	75 eb                	jne    351 <printf+0xec>
      state = 0;
 366:	be 00 00 00 00       	mov    $0x0,%esi
 36b:	e9 21 ff ff ff       	jmp    291 <printf+0x2c>
        putc(fd, *ap);
 370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 373:	0f be 17             	movsbl (%edi),%edx
 376:	8b 45 08             	mov    0x8(%ebp),%eax
 379:	e8 42 fe ff ff       	call   1c0 <putc>
        ap++;
 37e:	83 c7 04             	add    $0x4,%edi
 381:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 384:	be 00 00 00 00       	mov    $0x0,%esi
 389:	e9 03 ff ff ff       	jmp    291 <printf+0x2c>
        putc(fd, c);
 38e:	89 fa                	mov    %edi,%edx
 390:	8b 45 08             	mov    0x8(%ebp),%eax
 393:	e8 28 fe ff ff       	call   1c0 <putc>
      state = 0;
 398:	be 00 00 00 00       	mov    $0x0,%esi
 39d:	e9 ef fe ff ff       	jmp    291 <printf+0x2c>
        putc(fd, '%');
 3a2:	ba 25 00 00 00       	mov    $0x25,%edx
 3a7:	8b 45 08             	mov    0x8(%ebp),%eax
 3aa:	e8 11 fe ff ff       	call   1c0 <putc>
        putc(fd, c);
 3af:	89 fa                	mov    %edi,%edx
 3b1:	8b 45 08             	mov    0x8(%ebp),%eax
 3b4:	e8 07 fe ff ff       	call   1c0 <putc>
      state = 0;
 3b9:	be 00 00 00 00       	mov    $0x0,%esi
 3be:	e9 ce fe ff ff       	jmp    291 <printf+0x2c>
    }
  }
}
 3c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3c6:	5b                   	pop    %ebx
 3c7:	5e                   	pop    %esi
 3c8:	5f                   	pop    %edi
 3c9:	5d                   	pop    %ebp
 3ca:	c3                   	ret    
