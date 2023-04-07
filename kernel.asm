
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 90 5e 11 80       	mov    $0x80115e90,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 7f 2a 10 80       	mov    $0x80102a7f,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 18             	sub    $0x18,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
  struct buf *b;

  acquire(&bcache.lock);
80100041:	68 20 a5 10 80       	push   $0x8010a520
80100046:	e8 24 43 00 00       	call   8010436f <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 70 ec 10 80    	mov    0x8010ec70,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb 1c ec 10 80    	cmp    $0x8010ec1c,%ebx
8010005f:	74 30                	je     80100091 <bget+0x5d>
    if(b->dev == dev && b->blockno == blockno){
80100061:	39 73 04             	cmp    %esi,0x4(%ebx)
80100064:	75 f0                	jne    80100056 <bget+0x22>
80100066:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100069:	75 eb                	jne    80100056 <bget+0x22>
      b->refcnt++;
8010006b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010006e:	83 c0 01             	add    $0x1,%eax
80100071:	89 43 4c             	mov    %eax,0x4c(%ebx)
      release(&bcache.lock);
80100074:	83 ec 0c             	sub    $0xc,%esp
80100077:	68 20 a5 10 80       	push   $0x8010a520
8010007c:	e8 53 43 00 00       	call   801043d4 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 cf 40 00 00       	call   8010415b <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 6c ec 10 80    	mov    0x8010ec6c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb 1c ec 10 80    	cmp    $0x8010ec1c,%ebx
801000a2:	74 43                	je     801000e7 <bget+0xb3>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000a4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801000a8:	75 ef                	jne    80100099 <bget+0x65>
801000aa:	f6 03 04             	testb  $0x4,(%ebx)
801000ad:	75 ea                	jne    80100099 <bget+0x65>
      b->dev = dev;
801000af:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000b2:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000bb:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000c2:	83 ec 0c             	sub    $0xc,%esp
801000c5:	68 20 a5 10 80       	push   $0x8010a520
801000ca:	e8 05 43 00 00       	call   801043d4 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 81 40 00 00       	call   8010415b <acquiresleep>
      return b;
801000da:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000dd:	89 d8                	mov    %ebx,%eax
801000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e2:	5b                   	pop    %ebx
801000e3:	5e                   	pop    %esi
801000e4:	5f                   	pop    %edi
801000e5:	5d                   	pop    %ebp
801000e6:	c3                   	ret    
  panic("bget: no buffers");
801000e7:	83 ec 0c             	sub    $0xc,%esp
801000ea:	68 40 6f 10 80       	push   $0x80106f40
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 51 6f 10 80       	push   $0x80106f51
80100100:	68 20 a5 10 80       	push   $0x8010a520
80100105:	e8 29 41 00 00       	call   80104233 <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 6c ec 10 80 1c 	movl   $0x8010ec1c,0x8010ec6c
80100111:	ec 10 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 70 ec 10 80 1c 	movl   $0x8010ec1c,0x8010ec70
8010011b:	ec 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb 54 a5 10 80       	mov    $0x8010a554,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 1c ec 10 80 	movl   $0x8010ec1c,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 58 6f 10 80       	push   $0x80106f58
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 e0 3f 00 00       	call   80104128 <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 70 ec 10 80    	mov    %ebx,0x8010ec70
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb 1c ec 10 80    	cmp    $0x8010ec1c,%ebx
80100165:	72 c1                	jb     80100128 <binit+0x34>
}
80100167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010016a:	c9                   	leave  
8010016b:	c3                   	ret    

8010016c <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
8010016c:	55                   	push   %ebp
8010016d:	89 e5                	mov    %esp,%ebp
8010016f:	53                   	push   %ebx
80100170:	83 ec 04             	sub    $0x4,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100173:	8b 55 0c             	mov    0xc(%ebp),%edx
80100176:	8b 45 08             	mov    0x8(%ebp),%eax
80100179:	e8 b6 fe ff ff       	call   80100034 <bget>
8010017e:	89 c3                	mov    %eax,%ebx
  if((b->flags & B_VALID) == 0) {
80100180:	f6 00 02             	testb  $0x2,(%eax)
80100183:	74 07                	je     8010018c <bread+0x20>
    iderw(b);
  }
  return b;
}
80100185:	89 d8                	mov    %ebx,%eax
80100187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010018a:	c9                   	leave  
8010018b:	c3                   	ret    
    iderw(b);
8010018c:	83 ec 0c             	sub    $0xc,%esp
8010018f:	50                   	push   %eax
80100190:	e8 62 1c 00 00       	call   80101df7 <iderw>
80100195:	83 c4 10             	add    $0x10,%esp
  return b;
80100198:	eb eb                	jmp    80100185 <bread+0x19>

8010019a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010019a:	55                   	push   %ebp
8010019b:	89 e5                	mov    %esp,%ebp
8010019d:	53                   	push   %ebx
8010019e:	83 ec 10             	sub    $0x10,%esp
801001a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001a4:	8d 43 0c             	lea    0xc(%ebx),%eax
801001a7:	50                   	push   %eax
801001a8:	e8 38 40 00 00       	call   801041e5 <holdingsleep>
801001ad:	83 c4 10             	add    $0x10,%esp
801001b0:	85 c0                	test   %eax,%eax
801001b2:	74 14                	je     801001c8 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b4:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b7:	83 ec 0c             	sub    $0xc,%esp
801001ba:	53                   	push   %ebx
801001bb:	e8 37 1c 00 00       	call   80101df7 <iderw>
}
801001c0:	83 c4 10             	add    $0x10,%esp
801001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c6:	c9                   	leave  
801001c7:	c3                   	ret    
    panic("bwrite");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 5f 6f 10 80       	push   $0x80106f5f
801001d0:	e8 73 01 00 00       	call   80100348 <panic>

801001d5 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001d5:	55                   	push   %ebp
801001d6:	89 e5                	mov    %esp,%ebp
801001d8:	56                   	push   %esi
801001d9:	53                   	push   %ebx
801001da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001dd:	8d 73 0c             	lea    0xc(%ebx),%esi
801001e0:	83 ec 0c             	sub    $0xc,%esp
801001e3:	56                   	push   %esi
801001e4:	e8 fc 3f 00 00       	call   801041e5 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 b1 3f 00 00       	call   801041aa <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100200:	e8 6a 41 00 00       	call   8010436f <acquire>
  b->refcnt--;
80100205:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100208:	83 e8 01             	sub    $0x1,%eax
8010020b:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010020e:	83 c4 10             	add    $0x10,%esp
80100211:	85 c0                	test   %eax,%eax
80100213:	75 2f                	jne    80100244 <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100215:	8b 43 54             	mov    0x54(%ebx),%eax
80100218:	8b 53 50             	mov    0x50(%ebx),%edx
8010021b:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010021e:	8b 43 50             	mov    0x50(%ebx),%eax
80100221:	8b 53 54             	mov    0x54(%ebx),%edx
80100224:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100227:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 1c ec 10 80 	movl   $0x8010ec1c,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 70 ec 10 80    	mov    %ebx,0x8010ec70
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 20 a5 10 80       	push   $0x8010a520
8010024c:	e8 83 41 00 00       	call   801043d4 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 66 6f 10 80       	push   $0x80106f66
80100263:	e8 e0 00 00 00       	call   80100348 <panic>

80100268 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100268:	55                   	push   %ebp
80100269:	89 e5                	mov    %esp,%ebp
8010026b:	57                   	push   %edi
8010026c:	56                   	push   %esi
8010026d:	53                   	push   %ebx
8010026e:	83 ec 28             	sub    $0x28,%esp
80100271:	8b 7d 08             	mov    0x8(%ebp),%edi
80100274:	8b 75 0c             	mov    0xc(%ebp),%esi
80100277:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010027a:	57                   	push   %edi
8010027b:	e8 b1 13 00 00       	call   80101631 <iunlock>
  target = n;
80100280:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
80100283:	c7 04 24 20 ef 10 80 	movl   $0x8010ef20,(%esp)
8010028a:	e8 e0 40 00 00       	call   8010436f <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
8010029f:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 be 31 00 00       	call   8010346a <myproc>
801002ac:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 ef 10 80       	push   $0x8010ef20
801002ba:	68 00 ef 10 80       	push   $0x8010ef00
801002bf:	e8 a8 3b 00 00       	call   80103e6c <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 ef 10 80       	push   $0x8010ef20
801002d1:	e8 fe 40 00 00       	call   801043d4 <release>
        ilock(ip);
801002d6:	89 3c 24             	mov    %edi,(%esp)
801002d9:	e8 91 12 00 00       	call   8010156f <ilock>
        return -1;
801002de:	83 c4 10             	add    $0x10,%esp
801002e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002e9:	5b                   	pop    %ebx
801002ea:	5e                   	pop    %esi
801002eb:	5f                   	pop    %edi
801002ec:	5d                   	pop    %ebp
801002ed:	c3                   	ret    
    c = input.buf[input.r++ % INPUT_BUF];
801002ee:	8d 50 01             	lea    0x1(%eax),%edx
801002f1:	89 15 00 ef 10 80    	mov    %edx,0x8010ef00
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 92 80 ee 10 80 	movzbl -0x7fef1180(%edx),%edx
80100303:	0f be ca             	movsbl %dl,%ecx
    if(c == C('D')){  // EOF
80100306:	80 fa 04             	cmp    $0x4,%dl
80100309:	74 14                	je     8010031f <consoleread+0xb7>
    *dst++ = c;
8010030b:	8d 46 01             	lea    0x1(%esi),%eax
8010030e:	88 16                	mov    %dl,(%esi)
    --n;
80100310:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
80100313:	83 f9 0a             	cmp    $0xa,%ecx
80100316:	74 11                	je     80100329 <consoleread+0xc1>
    *dst++ = c;
80100318:	89 c6                	mov    %eax,%esi
8010031a:	e9 73 ff ff ff       	jmp    80100292 <consoleread+0x2a>
      if(n < target){
8010031f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100322:	73 05                	jae    80100329 <consoleread+0xc1>
        input.r--;
80100324:	a3 00 ef 10 80       	mov    %eax,0x8010ef00
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 ef 10 80       	push   $0x8010ef20
80100331:	e8 9e 40 00 00       	call   801043d4 <release>
  ilock(ip);
80100336:	89 3c 24             	mov    %edi,(%esp)
80100339:	e8 31 12 00 00       	call   8010156f <ilock>
  return target - n;
8010033e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100341:	29 d8                	sub    %ebx,%eax
80100343:	83 c4 10             	add    $0x10,%esp
80100346:	eb 9e                	jmp    801002e6 <consoleread+0x7e>

80100348 <panic>:
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	53                   	push   %ebx
8010034c:	83 ec 34             	sub    $0x34,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
8010034f:	fa                   	cli    
  cons.locking = 0;
80100350:	c7 05 54 ef 10 80 00 	movl   $0x0,0x8010ef54
80100357:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
8010035a:	e8 33 20 00 00       	call   80102392 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 6d 6f 10 80       	push   $0x80106f6d
80100368:	e8 9a 02 00 00       	call   80100607 <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	push   0x8(%ebp)
80100373:	e8 8f 02 00 00       	call   80100607 <cprintf>
  cprintf("\n");
80100378:	c7 04 24 bb 7a 10 80 	movl   $0x80107abb,(%esp)
8010037f:	e8 83 02 00 00       	call   80100607 <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 ba 3e 00 00       	call   8010424e <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	push   -0x30(%ebp,%ebx,4)
801003a5:	68 81 6f 10 80       	push   $0x80106f81
801003aa:	e8 58 02 00 00       	call   80100607 <cprintf>
  for(i=0; i<10; i++)
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
  panicked = 1; // freeze other CPU
801003ba:	c7 05 58 ef 10 80 01 	movl   $0x1,0x8010ef58
801003c1:	00 00 00 
  for(;;)
801003c4:	eb fe                	jmp    801003c4 <panic+0x7c>

801003c6 <cgaputc>:
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	57                   	push   %edi
801003ca:	56                   	push   %esi
801003cb:	53                   	push   %ebx
801003cc:	83 ec 0c             	sub    $0xc,%esp
801003cf:	89 c3                	mov    %eax,%ebx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003d1:	bf d4 03 00 00       	mov    $0x3d4,%edi
801003d6:	b8 0e 00 00 00       	mov    $0xe,%eax
801003db:	89 fa                	mov    %edi,%edx
801003dd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003de:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
801003e3:	89 ca                	mov    %ecx,%edx
801003e5:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003e6:	0f b6 f0             	movzbl %al,%esi
801003e9:	c1 e6 08             	shl    $0x8,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003ec:	b8 0f 00 00 00       	mov    $0xf,%eax
801003f1:	89 fa                	mov    %edi,%edx
801003f3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003f4:	89 ca                	mov    %ecx,%edx
801003f6:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
801003f7:	0f b6 c8             	movzbl %al,%ecx
801003fa:	09 f1                	or     %esi,%ecx
  if(c == '\n')
801003fc:	83 fb 0a             	cmp    $0xa,%ebx
801003ff:	74 60                	je     80100461 <cgaputc+0x9b>
  else if(c == BACKSPACE){
80100401:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
80100407:	74 79                	je     80100482 <cgaputc+0xbc>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100409:	0f b6 c3             	movzbl %bl,%eax
8010040c:	8d 59 01             	lea    0x1(%ecx),%ebx
8010040f:	80 cc 07             	or     $0x7,%ah
80100412:	66 89 84 09 00 80 0b 	mov    %ax,-0x7ff48000(%ecx,%ecx,1)
80100419:	80 
  if(pos < 0 || pos > 25*80)
8010041a:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100420:	77 6d                	ja     8010048f <cgaputc+0xc9>
  if((pos/80) >= 24){  // Scroll up.
80100422:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100428:	7f 72                	jg     8010049c <cgaputc+0xd6>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010042a:	be d4 03 00 00       	mov    $0x3d4,%esi
8010042f:	b8 0e 00 00 00       	mov    $0xe,%eax
80100434:	89 f2                	mov    %esi,%edx
80100436:	ee                   	out    %al,(%dx)
  outb(CRTPORT+1, pos>>8);
80100437:	0f b6 c7             	movzbl %bh,%eax
8010043a:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
8010043f:	89 ca                	mov    %ecx,%edx
80100441:	ee                   	out    %al,(%dx)
80100442:	b8 0f 00 00 00       	mov    $0xf,%eax
80100447:	89 f2                	mov    %esi,%edx
80100449:	ee                   	out    %al,(%dx)
8010044a:	89 d8                	mov    %ebx,%eax
8010044c:	89 ca                	mov    %ecx,%edx
8010044e:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
8010044f:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
80100456:	80 20 07 
}
80100459:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010045c:	5b                   	pop    %ebx
8010045d:	5e                   	pop    %esi
8010045e:	5f                   	pop    %edi
8010045f:	5d                   	pop    %ebp
80100460:	c3                   	ret    
    pos += 80 - pos%80;
80100461:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100466:	89 c8                	mov    %ecx,%eax
80100468:	f7 ea                	imul   %edx
8010046a:	c1 fa 05             	sar    $0x5,%edx
8010046d:	8d 04 92             	lea    (%edx,%edx,4),%eax
80100470:	c1 e0 04             	shl    $0x4,%eax
80100473:	89 ca                	mov    %ecx,%edx
80100475:	29 c2                	sub    %eax,%edx
80100477:	bb 50 00 00 00       	mov    $0x50,%ebx
8010047c:	29 d3                	sub    %edx,%ebx
8010047e:	01 cb                	add    %ecx,%ebx
80100480:	eb 98                	jmp    8010041a <cgaputc+0x54>
    if(pos > 0) --pos;
80100482:	85 c9                	test   %ecx,%ecx
80100484:	7e 05                	jle    8010048b <cgaputc+0xc5>
80100486:	8d 59 ff             	lea    -0x1(%ecx),%ebx
80100489:	eb 8f                	jmp    8010041a <cgaputc+0x54>
  pos |= inb(CRTPORT+1);
8010048b:	89 cb                	mov    %ecx,%ebx
8010048d:	eb 8b                	jmp    8010041a <cgaputc+0x54>
    panic("pos under/overflow");
8010048f:	83 ec 0c             	sub    $0xc,%esp
80100492:	68 85 6f 10 80       	push   $0x80106f85
80100497:	e8 ac fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010049c:	83 ec 04             	sub    $0x4,%esp
8010049f:	68 60 0e 00 00       	push   $0xe60
801004a4:	68 a0 80 0b 80       	push   $0x800b80a0
801004a9:	68 00 80 0b 80       	push   $0x800b8000
801004ae:	e8 e0 3f 00 00       	call   80104493 <memmove>
    pos -= 80;
801004b3:	83 eb 50             	sub    $0x50,%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004b6:	b8 80 07 00 00       	mov    $0x780,%eax
801004bb:	29 d8                	sub    %ebx,%eax
801004bd:	8d 94 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edx
801004c4:	83 c4 0c             	add    $0xc,%esp
801004c7:	01 c0                	add    %eax,%eax
801004c9:	50                   	push   %eax
801004ca:	6a 00                	push   $0x0
801004cc:	52                   	push   %edx
801004cd:	e8 49 3f 00 00       	call   8010441b <memset>
801004d2:	83 c4 10             	add    $0x10,%esp
801004d5:	e9 50 ff ff ff       	jmp    8010042a <cgaputc+0x64>

801004da <consputc>:
  if(panicked){
801004da:	83 3d 58 ef 10 80 00 	cmpl   $0x0,0x8010ef58
801004e1:	74 03                	je     801004e6 <consputc+0xc>
  asm volatile("cli");
801004e3:	fa                   	cli    
    for(;;)
801004e4:	eb fe                	jmp    801004e4 <consputc+0xa>
{
801004e6:	55                   	push   %ebp
801004e7:	89 e5                	mov    %esp,%ebp
801004e9:	53                   	push   %ebx
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	89 c3                	mov    %eax,%ebx
  if(c == BACKSPACE){
801004ef:	3d 00 01 00 00       	cmp    $0x100,%eax
801004f4:	74 18                	je     8010050e <consputc+0x34>
    uartputc(c);
801004f6:	83 ec 0c             	sub    $0xc,%esp
801004f9:	50                   	push   %eax
801004fa:	e8 c1 53 00 00       	call   801058c0 <uartputc>
801004ff:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100502:	89 d8                	mov    %ebx,%eax
80100504:	e8 bd fe ff ff       	call   801003c6 <cgaputc>
}
80100509:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010050c:	c9                   	leave  
8010050d:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010050e:	83 ec 0c             	sub    $0xc,%esp
80100511:	6a 08                	push   $0x8
80100513:	e8 a8 53 00 00       	call   801058c0 <uartputc>
80100518:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010051f:	e8 9c 53 00 00       	call   801058c0 <uartputc>
80100524:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010052b:	e8 90 53 00 00       	call   801058c0 <uartputc>
80100530:	83 c4 10             	add    $0x10,%esp
80100533:	eb cd                	jmp    80100502 <consputc+0x28>

80100535 <printint>:
{
80100535:	55                   	push   %ebp
80100536:	89 e5                	mov    %esp,%ebp
80100538:	57                   	push   %edi
80100539:	56                   	push   %esi
8010053a:	53                   	push   %ebx
8010053b:	83 ec 2c             	sub    $0x2c,%esp
8010053e:	89 d6                	mov    %edx,%esi
80100540:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  if(sign && (sign = xx < 0))
80100543:	85 c9                	test   %ecx,%ecx
80100545:	74 0c                	je     80100553 <printint+0x1e>
80100547:	89 c7                	mov    %eax,%edi
80100549:	c1 ef 1f             	shr    $0x1f,%edi
8010054c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
8010054f:	85 c0                	test   %eax,%eax
80100551:	78 38                	js     8010058b <printint+0x56>
    x = xx;
80100553:	89 c1                	mov    %eax,%ecx
  i = 0;
80100555:	bb 00 00 00 00       	mov    $0x0,%ebx
    buf[i++] = digits[x % base];
8010055a:	89 c8                	mov    %ecx,%eax
8010055c:	ba 00 00 00 00       	mov    $0x0,%edx
80100561:	f7 f6                	div    %esi
80100563:	89 df                	mov    %ebx,%edi
80100565:	83 c3 01             	add    $0x1,%ebx
80100568:	0f b6 92 b0 6f 10 80 	movzbl -0x7fef9050(%edx),%edx
8010056f:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
80100573:	89 ca                	mov    %ecx,%edx
80100575:	89 c1                	mov    %eax,%ecx
80100577:	39 d6                	cmp    %edx,%esi
80100579:	76 df                	jbe    8010055a <printint+0x25>
  if(sign)
8010057b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010057f:	74 1a                	je     8010059b <printint+0x66>
    buf[i++] = '-';
80100581:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
80100586:	8d 5f 02             	lea    0x2(%edi),%ebx
80100589:	eb 10                	jmp    8010059b <printint+0x66>
    x = -xx;
8010058b:	f7 d8                	neg    %eax
8010058d:	89 c1                	mov    %eax,%ecx
8010058f:	eb c4                	jmp    80100555 <printint+0x20>
    consputc(buf[i]);
80100591:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
80100596:	e8 3f ff ff ff       	call   801004da <consputc>
  while(--i >= 0)
8010059b:	83 eb 01             	sub    $0x1,%ebx
8010059e:	79 f1                	jns    80100591 <printint+0x5c>
}
801005a0:	83 c4 2c             	add    $0x2c,%esp
801005a3:	5b                   	pop    %ebx
801005a4:	5e                   	pop    %esi
801005a5:	5f                   	pop    %edi
801005a6:	5d                   	pop    %ebp
801005a7:	c3                   	ret    

801005a8 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005a8:	55                   	push   %ebp
801005a9:	89 e5                	mov    %esp,%ebp
801005ab:	57                   	push   %edi
801005ac:	56                   	push   %esi
801005ad:	53                   	push   %ebx
801005ae:	83 ec 18             	sub    $0x18,%esp
801005b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
801005b4:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005b7:	ff 75 08             	push   0x8(%ebp)
801005ba:	e8 72 10 00 00       	call   80101631 <iunlock>
  acquire(&cons.lock);
801005bf:	c7 04 24 20 ef 10 80 	movl   $0x8010ef20,(%esp)
801005c6:	e8 a4 3d 00 00       	call   8010436f <acquire>
  for(i = 0; i < n; i++)
801005cb:	83 c4 10             	add    $0x10,%esp
801005ce:	bb 00 00 00 00       	mov    $0x0,%ebx
801005d3:	eb 0c                	jmp    801005e1 <consolewrite+0x39>
    consputc(buf[i] & 0xff);
801005d5:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801005d9:	e8 fc fe ff ff       	call   801004da <consputc>
  for(i = 0; i < n; i++)
801005de:	83 c3 01             	add    $0x1,%ebx
801005e1:	39 f3                	cmp    %esi,%ebx
801005e3:	7c f0                	jl     801005d5 <consolewrite+0x2d>
  release(&cons.lock);
801005e5:	83 ec 0c             	sub    $0xc,%esp
801005e8:	68 20 ef 10 80       	push   $0x8010ef20
801005ed:	e8 e2 3d 00 00       	call   801043d4 <release>
  ilock(ip);
801005f2:	83 c4 04             	add    $0x4,%esp
801005f5:	ff 75 08             	push   0x8(%ebp)
801005f8:	e8 72 0f 00 00       	call   8010156f <ilock>

  return n;
}
801005fd:	89 f0                	mov    %esi,%eax
801005ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100602:	5b                   	pop    %ebx
80100603:	5e                   	pop    %esi
80100604:	5f                   	pop    %edi
80100605:	5d                   	pop    %ebp
80100606:	c3                   	ret    

80100607 <cprintf>:
{
80100607:	55                   	push   %ebp
80100608:	89 e5                	mov    %esp,%ebp
8010060a:	57                   	push   %edi
8010060b:	56                   	push   %esi
8010060c:	53                   	push   %ebx
8010060d:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100610:	a1 54 ef 10 80       	mov    0x8010ef54,%eax
80100615:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(locking)
80100618:	85 c0                	test   %eax,%eax
8010061a:	75 10                	jne    8010062c <cprintf+0x25>
  if (fmt == 0)
8010061c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80100620:	74 1c                	je     8010063e <cprintf+0x37>
  argp = (uint*)(void*)(&fmt + 1);
80100622:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100625:	be 00 00 00 00       	mov    $0x0,%esi
8010062a:	eb 27                	jmp    80100653 <cprintf+0x4c>
    acquire(&cons.lock);
8010062c:	83 ec 0c             	sub    $0xc,%esp
8010062f:	68 20 ef 10 80       	push   $0x8010ef20
80100634:	e8 36 3d 00 00       	call   8010436f <acquire>
80100639:	83 c4 10             	add    $0x10,%esp
8010063c:	eb de                	jmp    8010061c <cprintf+0x15>
    panic("null fmt");
8010063e:	83 ec 0c             	sub    $0xc,%esp
80100641:	68 9f 6f 10 80       	push   $0x80106f9f
80100646:	e8 fd fc ff ff       	call   80100348 <panic>
      consputc(c);
8010064b:	e8 8a fe ff ff       	call   801004da <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100650:	83 c6 01             	add    $0x1,%esi
80100653:	8b 55 08             	mov    0x8(%ebp),%edx
80100656:	0f b6 04 32          	movzbl (%edx,%esi,1),%eax
8010065a:	85 c0                	test   %eax,%eax
8010065c:	0f 84 b1 00 00 00    	je     80100713 <cprintf+0x10c>
    if(c != '%'){
80100662:	83 f8 25             	cmp    $0x25,%eax
80100665:	75 e4                	jne    8010064b <cprintf+0x44>
    c = fmt[++i] & 0xff;
80100667:	83 c6 01             	add    $0x1,%esi
8010066a:	0f b6 1c 32          	movzbl (%edx,%esi,1),%ebx
    if(c == 0)
8010066e:	85 db                	test   %ebx,%ebx
80100670:	0f 84 9d 00 00 00    	je     80100713 <cprintf+0x10c>
    switch(c){
80100676:	83 fb 70             	cmp    $0x70,%ebx
80100679:	74 2e                	je     801006a9 <cprintf+0xa2>
8010067b:	7f 22                	jg     8010069f <cprintf+0x98>
8010067d:	83 fb 25             	cmp    $0x25,%ebx
80100680:	74 6c                	je     801006ee <cprintf+0xe7>
80100682:	83 fb 64             	cmp    $0x64,%ebx
80100685:	75 76                	jne    801006fd <cprintf+0xf6>
      printint(*argp++, 10, 1);
80100687:	8d 5f 04             	lea    0x4(%edi),%ebx
8010068a:	8b 07                	mov    (%edi),%eax
8010068c:	b9 01 00 00 00       	mov    $0x1,%ecx
80100691:	ba 0a 00 00 00       	mov    $0xa,%edx
80100696:	e8 9a fe ff ff       	call   80100535 <printint>
8010069b:	89 df                	mov    %ebx,%edi
      break;
8010069d:	eb b1                	jmp    80100650 <cprintf+0x49>
    switch(c){
8010069f:	83 fb 73             	cmp    $0x73,%ebx
801006a2:	74 1d                	je     801006c1 <cprintf+0xba>
801006a4:	83 fb 78             	cmp    $0x78,%ebx
801006a7:	75 54                	jne    801006fd <cprintf+0xf6>
      printint(*argp++, 16, 0);
801006a9:	8d 5f 04             	lea    0x4(%edi),%ebx
801006ac:	8b 07                	mov    (%edi),%eax
801006ae:	b9 00 00 00 00       	mov    $0x0,%ecx
801006b3:	ba 10 00 00 00       	mov    $0x10,%edx
801006b8:	e8 78 fe ff ff       	call   80100535 <printint>
801006bd:	89 df                	mov    %ebx,%edi
      break;
801006bf:	eb 8f                	jmp    80100650 <cprintf+0x49>
      if((s = (char*)*argp++) == 0)
801006c1:	8d 47 04             	lea    0x4(%edi),%eax
801006c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801006c7:	8b 1f                	mov    (%edi),%ebx
801006c9:	85 db                	test   %ebx,%ebx
801006cb:	75 12                	jne    801006df <cprintf+0xd8>
        s = "(null)";
801006cd:	bb 98 6f 10 80       	mov    $0x80106f98,%ebx
801006d2:	eb 0b                	jmp    801006df <cprintf+0xd8>
        consputc(*s);
801006d4:	0f be c0             	movsbl %al,%eax
801006d7:	e8 fe fd ff ff       	call   801004da <consputc>
      for(; *s; s++)
801006dc:	83 c3 01             	add    $0x1,%ebx
801006df:	0f b6 03             	movzbl (%ebx),%eax
801006e2:	84 c0                	test   %al,%al
801006e4:	75 ee                	jne    801006d4 <cprintf+0xcd>
      if((s = (char*)*argp++) == 0)
801006e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801006e9:	e9 62 ff ff ff       	jmp    80100650 <cprintf+0x49>
      consputc('%');
801006ee:	b8 25 00 00 00       	mov    $0x25,%eax
801006f3:	e8 e2 fd ff ff       	call   801004da <consputc>
      break;
801006f8:	e9 53 ff ff ff       	jmp    80100650 <cprintf+0x49>
      consputc('%');
801006fd:	b8 25 00 00 00       	mov    $0x25,%eax
80100702:	e8 d3 fd ff ff       	call   801004da <consputc>
      consputc(c);
80100707:	89 d8                	mov    %ebx,%eax
80100709:	e8 cc fd ff ff       	call   801004da <consputc>
      break;
8010070e:	e9 3d ff ff ff       	jmp    80100650 <cprintf+0x49>
  if(locking)
80100713:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100717:	75 08                	jne    80100721 <cprintf+0x11a>
}
80100719:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010071c:	5b                   	pop    %ebx
8010071d:	5e                   	pop    %esi
8010071e:	5f                   	pop    %edi
8010071f:	5d                   	pop    %ebp
80100720:	c3                   	ret    
    release(&cons.lock);
80100721:	83 ec 0c             	sub    $0xc,%esp
80100724:	68 20 ef 10 80       	push   $0x8010ef20
80100729:	e8 a6 3c 00 00       	call   801043d4 <release>
8010072e:	83 c4 10             	add    $0x10,%esp
}
80100731:	eb e6                	jmp    80100719 <cprintf+0x112>

80100733 <consoleintr>:
{
80100733:	55                   	push   %ebp
80100734:	89 e5                	mov    %esp,%ebp
80100736:	57                   	push   %edi
80100737:	56                   	push   %esi
80100738:	53                   	push   %ebx
80100739:	83 ec 18             	sub    $0x18,%esp
8010073c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
8010073f:	68 20 ef 10 80       	push   $0x8010ef20
80100744:	e8 26 3c 00 00       	call   8010436f <acquire>
  while((c = getc()) >= 0){
80100749:	83 c4 10             	add    $0x10,%esp
  int c, doprocdump = 0;
8010074c:	be 00 00 00 00       	mov    $0x0,%esi
  while((c = getc()) >= 0){
80100751:	eb 13                	jmp    80100766 <consoleintr+0x33>
    switch(c){
80100753:	83 ff 08             	cmp    $0x8,%edi
80100756:	0f 84 d9 00 00 00    	je     80100835 <consoleintr+0x102>
8010075c:	83 ff 10             	cmp    $0x10,%edi
8010075f:	75 25                	jne    80100786 <consoleintr+0x53>
80100761:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100766:	ff d3                	call   *%ebx
80100768:	89 c7                	mov    %eax,%edi
8010076a:	85 c0                	test   %eax,%eax
8010076c:	0f 88 f5 00 00 00    	js     80100867 <consoleintr+0x134>
    switch(c){
80100772:	83 ff 15             	cmp    $0x15,%edi
80100775:	0f 84 93 00 00 00    	je     8010080e <consoleintr+0xdb>
8010077b:	7e d6                	jle    80100753 <consoleintr+0x20>
8010077d:	83 ff 7f             	cmp    $0x7f,%edi
80100780:	0f 84 af 00 00 00    	je     80100835 <consoleintr+0x102>
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100786:	85 ff                	test   %edi,%edi
80100788:	74 dc                	je     80100766 <consoleintr+0x33>
8010078a:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
8010078f:	89 c2                	mov    %eax,%edx
80100791:	2b 15 00 ef 10 80    	sub    0x8010ef00,%edx
80100797:	83 fa 7f             	cmp    $0x7f,%edx
8010079a:	77 ca                	ja     80100766 <consoleintr+0x33>
        c = (c == '\r') ? '\n' : c;
8010079c:	83 ff 0d             	cmp    $0xd,%edi
8010079f:	0f 84 b8 00 00 00    	je     8010085d <consoleintr+0x12a>
        input.buf[input.e++ % INPUT_BUF] = c;
801007a5:	8d 50 01             	lea    0x1(%eax),%edx
801007a8:	89 15 08 ef 10 80    	mov    %edx,0x8010ef08
801007ae:	83 e0 7f             	and    $0x7f,%eax
801007b1:	89 f9                	mov    %edi,%ecx
801007b3:	88 88 80 ee 10 80    	mov    %cl,-0x7fef1180(%eax)
        consputc(c);
801007b9:	89 f8                	mov    %edi,%eax
801007bb:	e8 1a fd ff ff       	call   801004da <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801007c0:	83 ff 0a             	cmp    $0xa,%edi
801007c3:	0f 94 c0             	sete   %al
801007c6:	83 ff 04             	cmp    $0x4,%edi
801007c9:	0f 94 c2             	sete   %dl
801007cc:	08 d0                	or     %dl,%al
801007ce:	75 10                	jne    801007e0 <consoleintr+0xad>
801007d0:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
801007d5:	83 e8 80             	sub    $0xffffff80,%eax
801007d8:	39 05 08 ef 10 80    	cmp    %eax,0x8010ef08
801007de:	75 86                	jne    80100766 <consoleintr+0x33>
          input.w = input.e;
801007e0:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
801007e5:	a3 04 ef 10 80       	mov    %eax,0x8010ef04
          wakeup(&input.r);
801007ea:	83 ec 0c             	sub    $0xc,%esp
801007ed:	68 00 ef 10 80       	push   $0x8010ef00
801007f2:	e8 dd 37 00 00       	call   80103fd4 <wakeup>
801007f7:	83 c4 10             	add    $0x10,%esp
801007fa:	e9 67 ff ff ff       	jmp    80100766 <consoleintr+0x33>
        input.e--;
801007ff:	a3 08 ef 10 80       	mov    %eax,0x8010ef08
        consputc(BACKSPACE);
80100804:	b8 00 01 00 00       	mov    $0x100,%eax
80100809:	e8 cc fc ff ff       	call   801004da <consputc>
      while(input.e != input.w &&
8010080e:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
80100813:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
80100819:	0f 84 47 ff ff ff    	je     80100766 <consoleintr+0x33>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010081f:	83 e8 01             	sub    $0x1,%eax
80100822:	89 c2                	mov    %eax,%edx
80100824:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100827:	80 ba 80 ee 10 80 0a 	cmpb   $0xa,-0x7fef1180(%edx)
8010082e:	75 cf                	jne    801007ff <consoleintr+0xcc>
80100830:	e9 31 ff ff ff       	jmp    80100766 <consoleintr+0x33>
      if(input.e != input.w){
80100835:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
8010083a:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
80100840:	0f 84 20 ff ff ff    	je     80100766 <consoleintr+0x33>
        input.e--;
80100846:	83 e8 01             	sub    $0x1,%eax
80100849:	a3 08 ef 10 80       	mov    %eax,0x8010ef08
        consputc(BACKSPACE);
8010084e:	b8 00 01 00 00       	mov    $0x100,%eax
80100853:	e8 82 fc ff ff       	call   801004da <consputc>
80100858:	e9 09 ff ff ff       	jmp    80100766 <consoleintr+0x33>
        c = (c == '\r') ? '\n' : c;
8010085d:	bf 0a 00 00 00       	mov    $0xa,%edi
80100862:	e9 3e ff ff ff       	jmp    801007a5 <consoleintr+0x72>
  release(&cons.lock);
80100867:	83 ec 0c             	sub    $0xc,%esp
8010086a:	68 20 ef 10 80       	push   $0x8010ef20
8010086f:	e8 60 3b 00 00       	call   801043d4 <release>
  if(doprocdump) {
80100874:	83 c4 10             	add    $0x10,%esp
80100877:	85 f6                	test   %esi,%esi
80100879:	75 08                	jne    80100883 <consoleintr+0x150>
}
8010087b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010087e:	5b                   	pop    %ebx
8010087f:	5e                   	pop    %esi
80100880:	5f                   	pop    %edi
80100881:	5d                   	pop    %ebp
80100882:	c3                   	ret    
    procdump();  // now call procdump() wo. cons.lock held
80100883:	e8 eb 37 00 00       	call   80104073 <procdump>
}
80100888:	eb f1                	jmp    8010087b <consoleintr+0x148>

8010088a <consoleinit>:

void
consoleinit(void)
{
8010088a:	55                   	push   %ebp
8010088b:	89 e5                	mov    %esp,%ebp
8010088d:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100890:	68 a8 6f 10 80       	push   $0x80106fa8
80100895:	68 20 ef 10 80       	push   $0x8010ef20
8010089a:	e8 94 39 00 00       	call   80104233 <initlock>

  devsw[CONSOLE].write = consolewrite;
8010089f:	c7 05 0c f9 10 80 a8 	movl   $0x801005a8,0x8010f90c
801008a6:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008a9:	c7 05 08 f9 10 80 68 	movl   $0x80100268,0x8010f908
801008b0:	02 10 80 
  cons.locking = 1;
801008b3:	c7 05 54 ef 10 80 01 	movl   $0x1,0x8010ef54
801008ba:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801008bd:	83 c4 08             	add    $0x8,%esp
801008c0:	6a 00                	push   $0x0
801008c2:	6a 01                	push   $0x1
801008c4:	e8 98 16 00 00       	call   80101f61 <ioapicenable>
}
801008c9:	83 c4 10             	add    $0x10,%esp
801008cc:	c9                   	leave  
801008cd:	c3                   	ret    

801008ce <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801008ce:	55                   	push   %ebp
801008cf:	89 e5                	mov    %esp,%ebp
801008d1:	57                   	push   %edi
801008d2:	56                   	push   %esi
801008d3:	53                   	push   %ebx
801008d4:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
801008da:	e8 8b 2b 00 00       	call   8010346a <myproc>
801008df:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
801008e5:	e8 c6 1e 00 00       	call   801027b0 <begin_op>

  if((ip = namei(path)) == 0){
801008ea:	83 ec 0c             	sub    $0xc,%esp
801008ed:	ff 75 08             	push   0x8(%ebp)
801008f0:	e8 d8 12 00 00       	call   80101bcd <namei>
801008f5:	83 c4 10             	add    $0x10,%esp
801008f8:	85 c0                	test   %eax,%eax
801008fa:	74 56                	je     80100952 <exec+0x84>
801008fc:	89 c3                	mov    %eax,%ebx
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
801008fe:	83 ec 0c             	sub    $0xc,%esp
80100901:	50                   	push   %eax
80100902:	e8 68 0c 00 00       	call   8010156f <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100907:	6a 34                	push   $0x34
80100909:	6a 00                	push   $0x0
8010090b:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100911:	50                   	push   %eax
80100912:	53                   	push   %ebx
80100913:	e8 49 0e 00 00       	call   80101761 <readi>
80100918:	83 c4 20             	add    $0x20,%esp
8010091b:	83 f8 34             	cmp    $0x34,%eax
8010091e:	75 0c                	jne    8010092c <exec+0x5e>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100920:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100927:	45 4c 46 
8010092a:	74 42                	je     8010096e <exec+0xa0>
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
8010092c:	85 db                	test   %ebx,%ebx
8010092e:	0f 84 c5 02 00 00    	je     80100bf9 <exec+0x32b>
    iunlockput(ip);
80100934:	83 ec 0c             	sub    $0xc,%esp
80100937:	53                   	push   %ebx
80100938:	e8 d9 0d 00 00       	call   80101716 <iunlockput>
    end_op();
8010093d:	e8 e8 1e 00 00       	call   8010282a <end_op>
80100942:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100945:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010094a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010094d:	5b                   	pop    %ebx
8010094e:	5e                   	pop    %esi
8010094f:	5f                   	pop    %edi
80100950:	5d                   	pop    %ebp
80100951:	c3                   	ret    
    end_op();
80100952:	e8 d3 1e 00 00       	call   8010282a <end_op>
    cprintf("exec: fail\n");
80100957:	83 ec 0c             	sub    $0xc,%esp
8010095a:	68 c1 6f 10 80       	push   $0x80106fc1
8010095f:	e8 a3 fc ff ff       	call   80100607 <cprintf>
    return -1;
80100964:	83 c4 10             	add    $0x10,%esp
80100967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096c:	eb dc                	jmp    8010094a <exec+0x7c>
  if((pgdir = setupkvm()) == 0)
8010096e:	e8 34 63 00 00       	call   80106ca7 <setupkvm>
80100973:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100979:	85 c0                	test   %eax,%eax
8010097b:	0f 84 09 01 00 00    	je     80100a8a <exec+0x1bc>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100981:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
80100987:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
8010098c:	be 00 00 00 00       	mov    $0x0,%esi
80100991:	eb 0c                	jmp    8010099f <exec+0xd1>
80100993:	83 c6 01             	add    $0x1,%esi
80100996:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
8010099c:	83 c0 20             	add    $0x20,%eax
8010099f:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
801009a6:	39 f2                	cmp    %esi,%edx
801009a8:	0f 8e 98 00 00 00    	jle    80100a46 <exec+0x178>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801009ae:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
801009b4:	6a 20                	push   $0x20
801009b6:	50                   	push   %eax
801009b7:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
801009bd:	50                   	push   %eax
801009be:	53                   	push   %ebx
801009bf:	e8 9d 0d 00 00       	call   80101761 <readi>
801009c4:	83 c4 10             	add    $0x10,%esp
801009c7:	83 f8 20             	cmp    $0x20,%eax
801009ca:	0f 85 ba 00 00 00    	jne    80100a8a <exec+0x1bc>
    if(ph.type != ELF_PROG_LOAD)
801009d0:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
801009d7:	75 ba                	jne    80100993 <exec+0xc5>
    if(ph.memsz < ph.filesz)
801009d9:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
801009df:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
801009e5:	0f 82 9f 00 00 00    	jb     80100a8a <exec+0x1bc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
801009eb:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
801009f1:	0f 82 93 00 00 00    	jb     80100a8a <exec+0x1bc>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
801009f7:	83 ec 04             	sub    $0x4,%esp
801009fa:	50                   	push   %eax
801009fb:	57                   	push   %edi
801009fc:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100a02:	e8 1c 61 00 00       	call   80106b23 <allocuvm>
80100a07:	89 c7                	mov    %eax,%edi
80100a09:	83 c4 10             	add    $0x10,%esp
80100a0c:	85 c0                	test   %eax,%eax
80100a0e:	74 7a                	je     80100a8a <exec+0x1bc>
    if(ph.vaddr % PGSIZE != 0)
80100a10:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a16:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a1b:	75 6d                	jne    80100a8a <exec+0x1bc>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a1d:	83 ec 0c             	sub    $0xc,%esp
80100a20:	ff b5 14 ff ff ff    	push   -0xec(%ebp)
80100a26:	ff b5 08 ff ff ff    	push   -0xf8(%ebp)
80100a2c:	53                   	push   %ebx
80100a2d:	50                   	push   %eax
80100a2e:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100a34:	e8 95 5f 00 00       	call   801069ce <loaduvm>
80100a39:	83 c4 20             	add    $0x20,%esp
80100a3c:	85 c0                	test   %eax,%eax
80100a3e:	0f 89 4f ff ff ff    	jns    80100993 <exec+0xc5>
80100a44:	eb 44                	jmp    80100a8a <exec+0x1bc>
  iunlockput(ip);
80100a46:	83 ec 0c             	sub    $0xc,%esp
80100a49:	53                   	push   %ebx
80100a4a:	e8 c7 0c 00 00       	call   80101716 <iunlockput>
  end_op();
80100a4f:	e8 d6 1d 00 00       	call   8010282a <end_op>
  sz = PGROUNDUP(sz);
80100a54:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a5f:	83 c4 0c             	add    $0xc,%esp
80100a62:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a68:	52                   	push   %edx
80100a69:	50                   	push   %eax
80100a6a:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100a70:	57                   	push   %edi
80100a71:	e8 ad 60 00 00       	call   80106b23 <allocuvm>
80100a76:	89 c6                	mov    %eax,%esi
80100a78:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100a7e:	83 c4 10             	add    $0x10,%esp
80100a81:	85 c0                	test   %eax,%eax
80100a83:	75 24                	jne    80100aa9 <exec+0x1db>
  ip = 0;
80100a85:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100a8a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100a90:	85 c0                	test   %eax,%eax
80100a92:	0f 84 94 fe ff ff    	je     8010092c <exec+0x5e>
    freevm(pgdir);
80100a98:	83 ec 0c             	sub    $0xc,%esp
80100a9b:	50                   	push   %eax
80100a9c:	e8 84 61 00 00       	call   80106c25 <freevm>
80100aa1:	83 c4 10             	add    $0x10,%esp
80100aa4:	e9 83 fe ff ff       	jmp    8010092c <exec+0x5e>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aa9:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100aaf:	83 ec 08             	sub    $0x8,%esp
80100ab2:	50                   	push   %eax
80100ab3:	57                   	push   %edi
80100ab4:	e8 73 62 00 00       	call   80106d2c <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100ab9:	83 c4 10             	add    $0x10,%esp
80100abc:	bf 00 00 00 00       	mov    $0x0,%edi
80100ac1:	eb 0a                	jmp    80100acd <exec+0x1ff>
    ustack[3+argc] = sp;
80100ac3:	89 b4 bd 64 ff ff ff 	mov    %esi,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100aca:	83 c7 01             	add    $0x1,%edi
80100acd:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad0:	8d 1c b8             	lea    (%eax,%edi,4),%ebx
80100ad3:	8b 03                	mov    (%ebx),%eax
80100ad5:	85 c0                	test   %eax,%eax
80100ad7:	74 47                	je     80100b20 <exec+0x252>
    if(argc >= MAXARG)
80100ad9:	83 ff 1f             	cmp    $0x1f,%edi
80100adc:	0f 87 0d 01 00 00    	ja     80100bef <exec+0x321>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ae2:	83 ec 0c             	sub    $0xc,%esp
80100ae5:	50                   	push   %eax
80100ae6:	e8 d9 3a 00 00       	call   801045c4 <strlen>
80100aeb:	29 c6                	sub    %eax,%esi
80100aed:	83 ee 01             	sub    $0x1,%esi
80100af0:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100af3:	83 c4 04             	add    $0x4,%esp
80100af6:	ff 33                	push   (%ebx)
80100af8:	e8 c7 3a 00 00       	call   801045c4 <strlen>
80100afd:	83 c0 01             	add    $0x1,%eax
80100b00:	50                   	push   %eax
80100b01:	ff 33                	push   (%ebx)
80100b03:	56                   	push   %esi
80100b04:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100b0a:	e8 ad 63 00 00       	call   80106ebc <copyout>
80100b0f:	83 c4 20             	add    $0x20,%esp
80100b12:	85 c0                	test   %eax,%eax
80100b14:	79 ad                	jns    80100ac3 <exec+0x1f5>
  ip = 0;
80100b16:	bb 00 00 00 00       	mov    $0x0,%ebx
80100b1b:	e9 6a ff ff ff       	jmp    80100a8a <exec+0x1bc>
  ustack[3+argc] = 0;
80100b20:	89 f1                	mov    %esi,%ecx
80100b22:	89 c3                	mov    %eax,%ebx
80100b24:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100b2b:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b2f:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b36:	ff ff ff 
  ustack[1] = argc;
80100b39:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b3f:	8d 14 bd 04 00 00 00 	lea    0x4(,%edi,4),%edx
80100b46:	89 f0                	mov    %esi,%eax
80100b48:	29 d0                	sub    %edx,%eax
80100b4a:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b50:	8d 04 bd 10 00 00 00 	lea    0x10(,%edi,4),%eax
80100b57:	29 c1                	sub    %eax,%ecx
80100b59:	89 ce                	mov    %ecx,%esi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b5b:	50                   	push   %eax
80100b5c:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b62:	50                   	push   %eax
80100b63:	51                   	push   %ecx
80100b64:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100b6a:	e8 4d 63 00 00       	call   80106ebc <copyout>
80100b6f:	83 c4 10             	add    $0x10,%esp
80100b72:	85 c0                	test   %eax,%eax
80100b74:	0f 88 10 ff ff ff    	js     80100a8a <exec+0x1bc>
  for(last=s=path; *s; s++)
80100b7a:	8b 55 08             	mov    0x8(%ebp),%edx
80100b7d:	89 d0                	mov    %edx,%eax
80100b7f:	eb 03                	jmp    80100b84 <exec+0x2b6>
80100b81:	83 c0 01             	add    $0x1,%eax
80100b84:	0f b6 08             	movzbl (%eax),%ecx
80100b87:	84 c9                	test   %cl,%cl
80100b89:	74 0a                	je     80100b95 <exec+0x2c7>
    if(*s == '/')
80100b8b:	80 f9 2f             	cmp    $0x2f,%cl
80100b8e:	75 f1                	jne    80100b81 <exec+0x2b3>
      last = s+1;
80100b90:	8d 50 01             	lea    0x1(%eax),%edx
80100b93:	eb ec                	jmp    80100b81 <exec+0x2b3>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100b95:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
80100b9b:	89 f8                	mov    %edi,%eax
80100b9d:	83 c0 6c             	add    $0x6c,%eax
80100ba0:	83 ec 04             	sub    $0x4,%esp
80100ba3:	6a 10                	push   $0x10
80100ba5:	52                   	push   %edx
80100ba6:	50                   	push   %eax
80100ba7:	e8 db 39 00 00       	call   80104587 <safestrcpy>
  oldpgdir = curproc->pgdir;
80100bac:	8b 5f 04             	mov    0x4(%edi),%ebx
  curproc->pgdir = pgdir;
80100baf:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100bb5:	89 4f 04             	mov    %ecx,0x4(%edi)
  curproc->sz = sz;
80100bb8:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100bbe:	89 0f                	mov    %ecx,(%edi)
  curproc->tf->eip = elf.entry;  // main
80100bc0:	8b 47 18             	mov    0x18(%edi),%eax
80100bc3:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bc9:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100bcc:	8b 47 18             	mov    0x18(%edi),%eax
80100bcf:	89 70 44             	mov    %esi,0x44(%eax)
  switchuvm(curproc);
80100bd2:	89 3c 24             	mov    %edi,(%esp)
80100bd5:	e8 ff 5b 00 00       	call   801067d9 <switchuvm>
  freevm(oldpgdir);
80100bda:	89 1c 24             	mov    %ebx,(%esp)
80100bdd:	e8 43 60 00 00       	call   80106c25 <freevm>
  return 0;
80100be2:	83 c4 10             	add    $0x10,%esp
80100be5:	b8 00 00 00 00       	mov    $0x0,%eax
80100bea:	e9 5b fd ff ff       	jmp    8010094a <exec+0x7c>
  ip = 0;
80100bef:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bf4:	e9 91 fe ff ff       	jmp    80100a8a <exec+0x1bc>
  return -1;
80100bf9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bfe:	e9 47 fd ff ff       	jmp    8010094a <exec+0x7c>

80100c03 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c03:	55                   	push   %ebp
80100c04:	89 e5                	mov    %esp,%ebp
80100c06:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100c09:	68 cd 6f 10 80       	push   $0x80106fcd
80100c0e:	68 60 ef 10 80       	push   $0x8010ef60
80100c13:	e8 1b 36 00 00       	call   80104233 <initlock>
}
80100c18:	83 c4 10             	add    $0x10,%esp
80100c1b:	c9                   	leave  
80100c1c:	c3                   	ret    

80100c1d <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c1d:	55                   	push   %ebp
80100c1e:	89 e5                	mov    %esp,%ebp
80100c20:	53                   	push   %ebx
80100c21:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c24:	68 60 ef 10 80       	push   $0x8010ef60
80100c29:	e8 41 37 00 00       	call   8010436f <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c2e:	83 c4 10             	add    $0x10,%esp
80100c31:	bb 94 ef 10 80       	mov    $0x8010ef94,%ebx
80100c36:	81 fb f4 f8 10 80    	cmp    $0x8010f8f4,%ebx
80100c3c:	73 29                	jae    80100c67 <filealloc+0x4a>
    if(f->ref == 0){
80100c3e:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c42:	74 05                	je     80100c49 <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c44:	83 c3 18             	add    $0x18,%ebx
80100c47:	eb ed                	jmp    80100c36 <filealloc+0x19>
      f->ref = 1;
80100c49:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c50:	83 ec 0c             	sub    $0xc,%esp
80100c53:	68 60 ef 10 80       	push   $0x8010ef60
80100c58:	e8 77 37 00 00       	call   801043d4 <release>
      return f;
80100c5d:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c60:	89 d8                	mov    %ebx,%eax
80100c62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c65:	c9                   	leave  
80100c66:	c3                   	ret    
  release(&ftable.lock);
80100c67:	83 ec 0c             	sub    $0xc,%esp
80100c6a:	68 60 ef 10 80       	push   $0x8010ef60
80100c6f:	e8 60 37 00 00       	call   801043d4 <release>
  return 0;
80100c74:	83 c4 10             	add    $0x10,%esp
80100c77:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c7c:	eb e2                	jmp    80100c60 <filealloc+0x43>

80100c7e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100c7e:	55                   	push   %ebp
80100c7f:	89 e5                	mov    %esp,%ebp
80100c81:	53                   	push   %ebx
80100c82:	83 ec 10             	sub    $0x10,%esp
80100c85:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100c88:	68 60 ef 10 80       	push   $0x8010ef60
80100c8d:	e8 dd 36 00 00       	call   8010436f <acquire>
  if(f->ref < 1)
80100c92:	8b 43 04             	mov    0x4(%ebx),%eax
80100c95:	83 c4 10             	add    $0x10,%esp
80100c98:	85 c0                	test   %eax,%eax
80100c9a:	7e 1a                	jle    80100cb6 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100c9c:	83 c0 01             	add    $0x1,%eax
80100c9f:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100ca2:	83 ec 0c             	sub    $0xc,%esp
80100ca5:	68 60 ef 10 80       	push   $0x8010ef60
80100caa:	e8 25 37 00 00       	call   801043d4 <release>
  return f;
}
80100caf:	89 d8                	mov    %ebx,%eax
80100cb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cb4:	c9                   	leave  
80100cb5:	c3                   	ret    
    panic("filedup");
80100cb6:	83 ec 0c             	sub    $0xc,%esp
80100cb9:	68 d4 6f 10 80       	push   $0x80106fd4
80100cbe:	e8 85 f6 ff ff       	call   80100348 <panic>

80100cc3 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100cc3:	55                   	push   %ebp
80100cc4:	89 e5                	mov    %esp,%ebp
80100cc6:	53                   	push   %ebx
80100cc7:	83 ec 30             	sub    $0x30,%esp
80100cca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100ccd:	68 60 ef 10 80       	push   $0x8010ef60
80100cd2:	e8 98 36 00 00       	call   8010436f <acquire>
  if(f->ref < 1)
80100cd7:	8b 43 04             	mov    0x4(%ebx),%eax
80100cda:	83 c4 10             	add    $0x10,%esp
80100cdd:	85 c0                	test   %eax,%eax
80100cdf:	7e 71                	jle    80100d52 <fileclose+0x8f>
    panic("fileclose");
  if(--f->ref > 0){
80100ce1:	83 e8 01             	sub    $0x1,%eax
80100ce4:	89 43 04             	mov    %eax,0x4(%ebx)
80100ce7:	85 c0                	test   %eax,%eax
80100ce9:	7f 74                	jg     80100d5f <fileclose+0x9c>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100ceb:	8b 03                	mov    (%ebx),%eax
80100ced:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cf0:	8b 43 04             	mov    0x4(%ebx),%eax
80100cf3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100cf6:	8b 43 08             	mov    0x8(%ebx),%eax
80100cf9:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cfc:	8b 43 0c             	mov    0xc(%ebx),%eax
80100cff:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d02:	8b 43 10             	mov    0x10(%ebx),%eax
80100d05:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100d08:	8b 43 14             	mov    0x14(%ebx),%eax
80100d0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80100d0e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d15:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d1b:	83 ec 0c             	sub    $0xc,%esp
80100d1e:	68 60 ef 10 80       	push   $0x8010ef60
80100d23:	e8 ac 36 00 00       	call   801043d4 <release>

  if(ff.type == FD_PIPE)
80100d28:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d2b:	83 c4 10             	add    $0x10,%esp
80100d2e:	83 f8 01             	cmp    $0x1,%eax
80100d31:	74 41                	je     80100d74 <fileclose+0xb1>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100d33:	83 f8 02             	cmp    $0x2,%eax
80100d36:	75 37                	jne    80100d6f <fileclose+0xac>
    begin_op();
80100d38:	e8 73 1a 00 00       	call   801027b0 <begin_op>
    iput(ff.ip);
80100d3d:	83 ec 0c             	sub    $0xc,%esp
80100d40:	ff 75 f0             	push   -0x10(%ebp)
80100d43:	e8 2e 09 00 00       	call   80101676 <iput>
    end_op();
80100d48:	e8 dd 1a 00 00       	call   8010282a <end_op>
80100d4d:	83 c4 10             	add    $0x10,%esp
80100d50:	eb 1d                	jmp    80100d6f <fileclose+0xac>
    panic("fileclose");
80100d52:	83 ec 0c             	sub    $0xc,%esp
80100d55:	68 dc 6f 10 80       	push   $0x80106fdc
80100d5a:	e8 e9 f5 ff ff       	call   80100348 <panic>
    release(&ftable.lock);
80100d5f:	83 ec 0c             	sub    $0xc,%esp
80100d62:	68 60 ef 10 80       	push   $0x8010ef60
80100d67:	e8 68 36 00 00       	call   801043d4 <release>
    return;
80100d6c:	83 c4 10             	add    $0x10,%esp
  }
}
80100d6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d72:	c9                   	leave  
80100d73:	c3                   	ret    
    pipeclose(ff.pipe, ff.writable);
80100d74:	83 ec 08             	sub    $0x8,%esp
80100d77:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7b:	50                   	push   %eax
80100d7c:	ff 75 ec             	push   -0x14(%ebp)
80100d7f:	e8 d2 20 00 00       	call   80102e56 <pipeclose>
80100d84:	83 c4 10             	add    $0x10,%esp
80100d87:	eb e6                	jmp    80100d6f <fileclose+0xac>

80100d89 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100d89:	55                   	push   %ebp
80100d8a:	89 e5                	mov    %esp,%ebp
80100d8c:	53                   	push   %ebx
80100d8d:	83 ec 04             	sub    $0x4,%esp
80100d90:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100d93:	83 3b 02             	cmpl   $0x2,(%ebx)
80100d96:	75 31                	jne    80100dc9 <filestat+0x40>
    ilock(f->ip);
80100d98:	83 ec 0c             	sub    $0xc,%esp
80100d9b:	ff 73 10             	push   0x10(%ebx)
80100d9e:	e8 cc 07 00 00       	call   8010156f <ilock>
    stati(f->ip, st);
80100da3:	83 c4 08             	add    $0x8,%esp
80100da6:	ff 75 0c             	push   0xc(%ebp)
80100da9:	ff 73 10             	push   0x10(%ebx)
80100dac:	e8 85 09 00 00       	call   80101736 <stati>
    iunlock(f->ip);
80100db1:	83 c4 04             	add    $0x4,%esp
80100db4:	ff 73 10             	push   0x10(%ebx)
80100db7:	e8 75 08 00 00       	call   80101631 <iunlock>
    return 0;
80100dbc:	83 c4 10             	add    $0x10,%esp
80100dbf:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100dc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100dc7:	c9                   	leave  
80100dc8:	c3                   	ret    
  return -1;
80100dc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100dce:	eb f4                	jmp    80100dc4 <filestat+0x3b>

80100dd0 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100dd0:	55                   	push   %ebp
80100dd1:	89 e5                	mov    %esp,%ebp
80100dd3:	56                   	push   %esi
80100dd4:	53                   	push   %ebx
80100dd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100dd8:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100ddc:	74 70                	je     80100e4e <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100dde:	8b 03                	mov    (%ebx),%eax
80100de0:	83 f8 01             	cmp    $0x1,%eax
80100de3:	74 44                	je     80100e29 <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100de5:	83 f8 02             	cmp    $0x2,%eax
80100de8:	75 57                	jne    80100e41 <fileread+0x71>
    ilock(f->ip);
80100dea:	83 ec 0c             	sub    $0xc,%esp
80100ded:	ff 73 10             	push   0x10(%ebx)
80100df0:	e8 7a 07 00 00       	call   8010156f <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100df5:	ff 75 10             	push   0x10(%ebp)
80100df8:	ff 73 14             	push   0x14(%ebx)
80100dfb:	ff 75 0c             	push   0xc(%ebp)
80100dfe:	ff 73 10             	push   0x10(%ebx)
80100e01:	e8 5b 09 00 00       	call   80101761 <readi>
80100e06:	89 c6                	mov    %eax,%esi
80100e08:	83 c4 20             	add    $0x20,%esp
80100e0b:	85 c0                	test   %eax,%eax
80100e0d:	7e 03                	jle    80100e12 <fileread+0x42>
      f->off += r;
80100e0f:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e12:	83 ec 0c             	sub    $0xc,%esp
80100e15:	ff 73 10             	push   0x10(%ebx)
80100e18:	e8 14 08 00 00       	call   80101631 <iunlock>
    return r;
80100e1d:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100e20:	89 f0                	mov    %esi,%eax
80100e22:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e25:	5b                   	pop    %ebx
80100e26:	5e                   	pop    %esi
80100e27:	5d                   	pop    %ebp
80100e28:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100e29:	83 ec 04             	sub    $0x4,%esp
80100e2c:	ff 75 10             	push   0x10(%ebp)
80100e2f:	ff 75 0c             	push   0xc(%ebp)
80100e32:	ff 73 0c             	push   0xc(%ebx)
80100e35:	e8 6d 21 00 00       	call   80102fa7 <piperead>
80100e3a:	89 c6                	mov    %eax,%esi
80100e3c:	83 c4 10             	add    $0x10,%esp
80100e3f:	eb df                	jmp    80100e20 <fileread+0x50>
  panic("fileread");
80100e41:	83 ec 0c             	sub    $0xc,%esp
80100e44:	68 e6 6f 10 80       	push   $0x80106fe6
80100e49:	e8 fa f4 ff ff       	call   80100348 <panic>
    return -1;
80100e4e:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e53:	eb cb                	jmp    80100e20 <fileread+0x50>

80100e55 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e55:	55                   	push   %ebp
80100e56:	89 e5                	mov    %esp,%ebp
80100e58:	57                   	push   %edi
80100e59:	56                   	push   %esi
80100e5a:	53                   	push   %ebx
80100e5b:	83 ec 1c             	sub    $0x1c,%esp
80100e5e:	8b 75 08             	mov    0x8(%ebp),%esi
  int r;

  if(f->writable == 0)
80100e61:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)
80100e65:	0f 84 d0 00 00 00    	je     80100f3b <filewrite+0xe6>
    return -1;
  if(f->type == FD_PIPE)
80100e6b:	8b 06                	mov    (%esi),%eax
80100e6d:	83 f8 01             	cmp    $0x1,%eax
80100e70:	74 12                	je     80100e84 <filewrite+0x2f>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e72:	83 f8 02             	cmp    $0x2,%eax
80100e75:	0f 85 b3 00 00 00    	jne    80100f2e <filewrite+0xd9>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e7b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e82:	eb 66                	jmp    80100eea <filewrite+0x95>
    return pipewrite(f->pipe, addr, n);
80100e84:	83 ec 04             	sub    $0x4,%esp
80100e87:	ff 75 10             	push   0x10(%ebp)
80100e8a:	ff 75 0c             	push   0xc(%ebp)
80100e8d:	ff 76 0c             	push   0xc(%esi)
80100e90:	e8 4d 20 00 00       	call   80102ee2 <pipewrite>
80100e95:	83 c4 10             	add    $0x10,%esp
80100e98:	e9 84 00 00 00       	jmp    80100f21 <filewrite+0xcc>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100e9d:	e8 0e 19 00 00       	call   801027b0 <begin_op>
      ilock(f->ip);
80100ea2:	83 ec 0c             	sub    $0xc,%esp
80100ea5:	ff 76 10             	push   0x10(%esi)
80100ea8:	e8 c2 06 00 00       	call   8010156f <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100ead:	57                   	push   %edi
80100eae:	ff 76 14             	push   0x14(%esi)
80100eb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb4:	03 45 0c             	add    0xc(%ebp),%eax
80100eb7:	50                   	push   %eax
80100eb8:	ff 76 10             	push   0x10(%esi)
80100ebb:	e8 9e 09 00 00       	call   8010185e <writei>
80100ec0:	89 c3                	mov    %eax,%ebx
80100ec2:	83 c4 20             	add    $0x20,%esp
80100ec5:	85 c0                	test   %eax,%eax
80100ec7:	7e 03                	jle    80100ecc <filewrite+0x77>
        f->off += r;
80100ec9:	01 46 14             	add    %eax,0x14(%esi)
      iunlock(f->ip);
80100ecc:	83 ec 0c             	sub    $0xc,%esp
80100ecf:	ff 76 10             	push   0x10(%esi)
80100ed2:	e8 5a 07 00 00       	call   80101631 <iunlock>
      end_op();
80100ed7:	e8 4e 19 00 00       	call   8010282a <end_op>

      if(r < 0)
80100edc:	83 c4 10             	add    $0x10,%esp
80100edf:	85 db                	test   %ebx,%ebx
80100ee1:	78 31                	js     80100f14 <filewrite+0xbf>
        break;
      if(r != n1)
80100ee3:	39 df                	cmp    %ebx,%edi
80100ee5:	75 20                	jne    80100f07 <filewrite+0xb2>
        panic("short filewrite");
      i += r;
80100ee7:	01 5d e4             	add    %ebx,-0x1c(%ebp)
    while(i < n){
80100eea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eed:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ef0:	7d 22                	jge    80100f14 <filewrite+0xbf>
      int n1 = n - i;
80100ef2:	8b 7d 10             	mov    0x10(%ebp),%edi
80100ef5:	2b 7d e4             	sub    -0x1c(%ebp),%edi
      if(n1 > max)
80100ef8:	81 ff 00 06 00 00    	cmp    $0x600,%edi
80100efe:	7e 9d                	jle    80100e9d <filewrite+0x48>
        n1 = max;
80100f00:	bf 00 06 00 00       	mov    $0x600,%edi
80100f05:	eb 96                	jmp    80100e9d <filewrite+0x48>
        panic("short filewrite");
80100f07:	83 ec 0c             	sub    $0xc,%esp
80100f0a:	68 ef 6f 10 80       	push   $0x80106fef
80100f0f:	e8 34 f4 ff ff       	call   80100348 <panic>
    }
    return i == n ? n : -1;
80100f14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f17:	3b 45 10             	cmp    0x10(%ebp),%eax
80100f1a:	74 0d                	je     80100f29 <filewrite+0xd4>
80100f1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
80100f21:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f24:	5b                   	pop    %ebx
80100f25:	5e                   	pop    %esi
80100f26:	5f                   	pop    %edi
80100f27:	5d                   	pop    %ebp
80100f28:	c3                   	ret    
    return i == n ? n : -1;
80100f29:	8b 45 10             	mov    0x10(%ebp),%eax
80100f2c:	eb f3                	jmp    80100f21 <filewrite+0xcc>
  panic("filewrite");
80100f2e:	83 ec 0c             	sub    $0xc,%esp
80100f31:	68 f5 6f 10 80       	push   $0x80106ff5
80100f36:	e8 0d f4 ff ff       	call   80100348 <panic>
    return -1;
80100f3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f40:	eb df                	jmp    80100f21 <filewrite+0xcc>

80100f42 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f42:	55                   	push   %ebp
80100f43:	89 e5                	mov    %esp,%ebp
80100f45:	57                   	push   %edi
80100f46:	56                   	push   %esi
80100f47:	53                   	push   %ebx
80100f48:	83 ec 0c             	sub    $0xc,%esp
80100f4b:	89 d6                	mov    %edx,%esi
  char *s;
  int len;

  while(*path == '/')
80100f4d:	eb 03                	jmp    80100f52 <skipelem+0x10>
    path++;
80100f4f:	83 c0 01             	add    $0x1,%eax
  while(*path == '/')
80100f52:	0f b6 10             	movzbl (%eax),%edx
80100f55:	80 fa 2f             	cmp    $0x2f,%dl
80100f58:	74 f5                	je     80100f4f <skipelem+0xd>
  if(*path == 0)
80100f5a:	84 d2                	test   %dl,%dl
80100f5c:	74 53                	je     80100fb1 <skipelem+0x6f>
80100f5e:	89 c3                	mov    %eax,%ebx
80100f60:	eb 03                	jmp    80100f65 <skipelem+0x23>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f62:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80100f65:	0f b6 13             	movzbl (%ebx),%edx
80100f68:	80 fa 2f             	cmp    $0x2f,%dl
80100f6b:	74 04                	je     80100f71 <skipelem+0x2f>
80100f6d:	84 d2                	test   %dl,%dl
80100f6f:	75 f1                	jne    80100f62 <skipelem+0x20>
  len = path - s;
80100f71:	89 df                	mov    %ebx,%edi
80100f73:	29 c7                	sub    %eax,%edi
  if(len >= DIRSIZ)
80100f75:	83 ff 0d             	cmp    $0xd,%edi
80100f78:	7e 11                	jle    80100f8b <skipelem+0x49>
    memmove(name, s, DIRSIZ);
80100f7a:	83 ec 04             	sub    $0x4,%esp
80100f7d:	6a 0e                	push   $0xe
80100f7f:	50                   	push   %eax
80100f80:	56                   	push   %esi
80100f81:	e8 0d 35 00 00       	call   80104493 <memmove>
80100f86:	83 c4 10             	add    $0x10,%esp
80100f89:	eb 17                	jmp    80100fa2 <skipelem+0x60>
  else {
    memmove(name, s, len);
80100f8b:	83 ec 04             	sub    $0x4,%esp
80100f8e:	57                   	push   %edi
80100f8f:	50                   	push   %eax
80100f90:	56                   	push   %esi
80100f91:	e8 fd 34 00 00       	call   80104493 <memmove>
    name[len] = 0;
80100f96:	c6 04 3e 00          	movb   $0x0,(%esi,%edi,1)
80100f9a:	83 c4 10             	add    $0x10,%esp
80100f9d:	eb 03                	jmp    80100fa2 <skipelem+0x60>
  }
  while(*path == '/')
    path++;
80100f9f:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80100fa2:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100fa5:	74 f8                	je     80100f9f <skipelem+0x5d>
  return path;
}
80100fa7:	89 d8                	mov    %ebx,%eax
80100fa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fac:	5b                   	pop    %ebx
80100fad:	5e                   	pop    %esi
80100fae:	5f                   	pop    %edi
80100faf:	5d                   	pop    %ebp
80100fb0:	c3                   	ret    
    return 0;
80100fb1:	bb 00 00 00 00       	mov    $0x0,%ebx
80100fb6:	eb ef                	jmp    80100fa7 <skipelem+0x65>

80100fb8 <bzero>:
{
80100fb8:	55                   	push   %ebp
80100fb9:	89 e5                	mov    %esp,%ebp
80100fbb:	53                   	push   %ebx
80100fbc:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100fbf:	52                   	push   %edx
80100fc0:	50                   	push   %eax
80100fc1:	e8 a6 f1 ff ff       	call   8010016c <bread>
80100fc6:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100fc8:	8d 40 5c             	lea    0x5c(%eax),%eax
80100fcb:	83 c4 0c             	add    $0xc,%esp
80100fce:	68 00 02 00 00       	push   $0x200
80100fd3:	6a 00                	push   $0x0
80100fd5:	50                   	push   %eax
80100fd6:	e8 40 34 00 00       	call   8010441b <memset>
  log_write(bp);
80100fdb:	89 1c 24             	mov    %ebx,(%esp)
80100fde:	e8 f6 18 00 00       	call   801028d9 <log_write>
  brelse(bp);
80100fe3:	89 1c 24             	mov    %ebx,(%esp)
80100fe6:	e8 ea f1 ff ff       	call   801001d5 <brelse>
}
80100feb:	83 c4 10             	add    $0x10,%esp
80100fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ff1:	c9                   	leave  
80100ff2:	c3                   	ret    

80100ff3 <bfree>:
{
80100ff3:	55                   	push   %ebp
80100ff4:	89 e5                	mov    %esp,%ebp
80100ff6:	56                   	push   %esi
80100ff7:	53                   	push   %ebx
80100ff8:	89 c3                	mov    %eax,%ebx
80100ffa:	89 d6                	mov    %edx,%esi
  bp = bread(dev, BBLOCK(b, sb));
80100ffc:	89 d0                	mov    %edx,%eax
80100ffe:	c1 e8 0c             	shr    $0xc,%eax
80101001:	83 ec 08             	sub    $0x8,%esp
80101004:	03 05 cc 15 11 80    	add    0x801115cc,%eax
8010100a:	50                   	push   %eax
8010100b:	53                   	push   %ebx
8010100c:	e8 5b f1 ff ff       	call   8010016c <bread>
80101011:	89 c3                	mov    %eax,%ebx
  bi = b % BPB;
80101013:	89 f2                	mov    %esi,%edx
80101015:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  m = 1 << (bi % 8);
8010101b:	89 f1                	mov    %esi,%ecx
8010101d:	83 e1 07             	and    $0x7,%ecx
80101020:	b8 01 00 00 00       	mov    $0x1,%eax
80101025:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101027:	83 c4 10             	add    $0x10,%esp
8010102a:	c1 fa 03             	sar    $0x3,%edx
8010102d:	0f b6 4c 13 5c       	movzbl 0x5c(%ebx,%edx,1),%ecx
80101032:	0f b6 f1             	movzbl %cl,%esi
80101035:	85 c6                	test   %eax,%esi
80101037:	74 23                	je     8010105c <bfree+0x69>
  bp->data[bi/8] &= ~m;
80101039:	f7 d0                	not    %eax
8010103b:	21 c8                	and    %ecx,%eax
8010103d:	88 44 13 5c          	mov    %al,0x5c(%ebx,%edx,1)
  log_write(bp);
80101041:	83 ec 0c             	sub    $0xc,%esp
80101044:	53                   	push   %ebx
80101045:	e8 8f 18 00 00       	call   801028d9 <log_write>
  brelse(bp);
8010104a:	89 1c 24             	mov    %ebx,(%esp)
8010104d:	e8 83 f1 ff ff       	call   801001d5 <brelse>
}
80101052:	83 c4 10             	add    $0x10,%esp
80101055:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101058:	5b                   	pop    %ebx
80101059:	5e                   	pop    %esi
8010105a:	5d                   	pop    %ebp
8010105b:	c3                   	ret    
    panic("freeing free block");
8010105c:	83 ec 0c             	sub    $0xc,%esp
8010105f:	68 ff 6f 10 80       	push   $0x80106fff
80101064:	e8 df f2 ff ff       	call   80100348 <panic>

80101069 <balloc>:
{
80101069:	55                   	push   %ebp
8010106a:	89 e5                	mov    %esp,%ebp
8010106c:	57                   	push   %edi
8010106d:	56                   	push   %esi
8010106e:	53                   	push   %ebx
8010106f:	83 ec 1c             	sub    $0x1c,%esp
80101072:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101075:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010107c:	eb 15                	jmp    80101093 <balloc+0x2a>
    brelse(bp);
8010107e:	83 ec 0c             	sub    $0xc,%esp
80101081:	ff 75 e0             	push   -0x20(%ebp)
80101084:	e8 4c f1 ff ff       	call   801001d5 <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101089:	81 45 e4 00 10 00 00 	addl   $0x1000,-0x1c(%ebp)
80101090:	83 c4 10             	add    $0x10,%esp
80101093:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101096:	39 05 b4 15 11 80    	cmp    %eax,0x801115b4
8010109c:	76 75                	jbe    80101113 <balloc+0xaa>
    bp = bread(dev, BBLOCK(b, sb));
8010109e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801010a1:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
801010a7:	85 db                	test   %ebx,%ebx
801010a9:	0f 49 c3             	cmovns %ebx,%eax
801010ac:	c1 f8 0c             	sar    $0xc,%eax
801010af:	83 ec 08             	sub    $0x8,%esp
801010b2:	03 05 cc 15 11 80    	add    0x801115cc,%eax
801010b8:	50                   	push   %eax
801010b9:	ff 75 d8             	push   -0x28(%ebp)
801010bc:	e8 ab f0 ff ff       	call   8010016c <bread>
801010c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801010c4:	83 c4 10             	add    $0x10,%esp
801010c7:	b8 00 00 00 00       	mov    $0x0,%eax
801010cc:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801010d1:	7f ab                	jg     8010107e <balloc+0x15>
801010d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801010d6:	8d 1c 07             	lea    (%edi,%eax,1),%ebx
801010d9:	3b 1d b4 15 11 80    	cmp    0x801115b4,%ebx
801010df:	73 9d                	jae    8010107e <balloc+0x15>
      m = 1 << (bi % 8);
801010e1:	89 c1                	mov    %eax,%ecx
801010e3:	83 e1 07             	and    $0x7,%ecx
801010e6:	ba 01 00 00 00       	mov    $0x1,%edx
801010eb:	d3 e2                	shl    %cl,%edx
801010ed:	89 d1                	mov    %edx,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801010ef:	8d 50 07             	lea    0x7(%eax),%edx
801010f2:	85 c0                	test   %eax,%eax
801010f4:	0f 49 d0             	cmovns %eax,%edx
801010f7:	c1 fa 03             	sar    $0x3,%edx
801010fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
801010fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
80101100:	0f b6 74 16 5c       	movzbl 0x5c(%esi,%edx,1),%esi
80101105:	89 f2                	mov    %esi,%edx
80101107:	0f b6 fa             	movzbl %dl,%edi
8010110a:	85 cf                	test   %ecx,%edi
8010110c:	74 12                	je     80101120 <balloc+0xb7>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010110e:	83 c0 01             	add    $0x1,%eax
80101111:	eb b9                	jmp    801010cc <balloc+0x63>
  panic("balloc: out of blocks");
80101113:	83 ec 0c             	sub    $0xc,%esp
80101116:	68 12 70 10 80       	push   $0x80107012
8010111b:	e8 28 f2 ff ff       	call   80100348 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
80101120:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101123:	09 f1                	or     %esi,%ecx
80101125:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101128:	88 4c 17 5c          	mov    %cl,0x5c(%edi,%edx,1)
        log_write(bp);
8010112c:	83 ec 0c             	sub    $0xc,%esp
8010112f:	57                   	push   %edi
80101130:	e8 a4 17 00 00       	call   801028d9 <log_write>
        brelse(bp);
80101135:	89 3c 24             	mov    %edi,(%esp)
80101138:	e8 98 f0 ff ff       	call   801001d5 <brelse>
        bzero(dev, b + bi);
8010113d:	89 da                	mov    %ebx,%edx
8010113f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101142:	e8 71 fe ff ff       	call   80100fb8 <bzero>
}
80101147:	89 d8                	mov    %ebx,%eax
80101149:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010114c:	5b                   	pop    %ebx
8010114d:	5e                   	pop    %esi
8010114e:	5f                   	pop    %edi
8010114f:	5d                   	pop    %ebp
80101150:	c3                   	ret    

80101151 <bmap>:
{
80101151:	55                   	push   %ebp
80101152:	89 e5                	mov    %esp,%ebp
80101154:	57                   	push   %edi
80101155:	56                   	push   %esi
80101156:	53                   	push   %ebx
80101157:	83 ec 1c             	sub    $0x1c,%esp
8010115a:	89 c3                	mov    %eax,%ebx
8010115c:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
8010115e:	83 fa 0b             	cmp    $0xb,%edx
80101161:	76 45                	jbe    801011a8 <bmap+0x57>
  bn -= NDIRECT;
80101163:	8d 72 f4             	lea    -0xc(%edx),%esi
  if(bn < NINDIRECT){
80101166:	83 fe 7f             	cmp    $0x7f,%esi
80101169:	77 7f                	ja     801011ea <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
8010116b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101171:	85 c0                	test   %eax,%eax
80101173:	74 4a                	je     801011bf <bmap+0x6e>
    bp = bread(ip->dev, addr);
80101175:	83 ec 08             	sub    $0x8,%esp
80101178:	50                   	push   %eax
80101179:	ff 33                	push   (%ebx)
8010117b:	e8 ec ef ff ff       	call   8010016c <bread>
80101180:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
80101182:	8d 44 b0 5c          	lea    0x5c(%eax,%esi,4),%eax
80101186:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101189:	8b 30                	mov    (%eax),%esi
8010118b:	83 c4 10             	add    $0x10,%esp
8010118e:	85 f6                	test   %esi,%esi
80101190:	74 3c                	je     801011ce <bmap+0x7d>
    brelse(bp);
80101192:	83 ec 0c             	sub    $0xc,%esp
80101195:	57                   	push   %edi
80101196:	e8 3a f0 ff ff       	call   801001d5 <brelse>
    return addr;
8010119b:	83 c4 10             	add    $0x10,%esp
}
8010119e:	89 f0                	mov    %esi,%eax
801011a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011a3:	5b                   	pop    %ebx
801011a4:	5e                   	pop    %esi
801011a5:	5f                   	pop    %edi
801011a6:	5d                   	pop    %ebp
801011a7:	c3                   	ret    
    if((addr = ip->addrs[bn]) == 0)
801011a8:	8b 74 90 5c          	mov    0x5c(%eax,%edx,4),%esi
801011ac:	85 f6                	test   %esi,%esi
801011ae:	75 ee                	jne    8010119e <bmap+0x4d>
      ip->addrs[bn] = addr = balloc(ip->dev);
801011b0:	8b 00                	mov    (%eax),%eax
801011b2:	e8 b2 fe ff ff       	call   80101069 <balloc>
801011b7:	89 c6                	mov    %eax,%esi
801011b9:	89 44 bb 5c          	mov    %eax,0x5c(%ebx,%edi,4)
    return addr;
801011bd:	eb df                	jmp    8010119e <bmap+0x4d>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801011bf:	8b 03                	mov    (%ebx),%eax
801011c1:	e8 a3 fe ff ff       	call   80101069 <balloc>
801011c6:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
801011cc:	eb a7                	jmp    80101175 <bmap+0x24>
      a[bn] = addr = balloc(ip->dev);
801011ce:	8b 03                	mov    (%ebx),%eax
801011d0:	e8 94 fe ff ff       	call   80101069 <balloc>
801011d5:	89 c6                	mov    %eax,%esi
801011d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801011da:	89 30                	mov    %esi,(%eax)
      log_write(bp);
801011dc:	83 ec 0c             	sub    $0xc,%esp
801011df:	57                   	push   %edi
801011e0:	e8 f4 16 00 00       	call   801028d9 <log_write>
801011e5:	83 c4 10             	add    $0x10,%esp
801011e8:	eb a8                	jmp    80101192 <bmap+0x41>
  panic("bmap: out of range");
801011ea:	83 ec 0c             	sub    $0xc,%esp
801011ed:	68 28 70 10 80       	push   $0x80107028
801011f2:	e8 51 f1 ff ff       	call   80100348 <panic>

801011f7 <iget>:
{
801011f7:	55                   	push   %ebp
801011f8:	89 e5                	mov    %esp,%ebp
801011fa:	57                   	push   %edi
801011fb:	56                   	push   %esi
801011fc:	53                   	push   %ebx
801011fd:	83 ec 28             	sub    $0x28,%esp
80101200:	89 c7                	mov    %eax,%edi
80101202:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101205:	68 60 f9 10 80       	push   $0x8010f960
8010120a:	e8 60 31 00 00       	call   8010436f <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010120f:	83 c4 10             	add    $0x10,%esp
  empty = 0;
80101212:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101217:	bb 94 f9 10 80       	mov    $0x8010f994,%ebx
8010121c:	eb 0a                	jmp    80101228 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010121e:	85 f6                	test   %esi,%esi
80101220:	74 3b                	je     8010125d <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101222:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101228:	81 fb b4 15 11 80    	cmp    $0x801115b4,%ebx
8010122e:	73 35                	jae    80101265 <iget+0x6e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101230:	8b 43 08             	mov    0x8(%ebx),%eax
80101233:	85 c0                	test   %eax,%eax
80101235:	7e e7                	jle    8010121e <iget+0x27>
80101237:	39 3b                	cmp    %edi,(%ebx)
80101239:	75 e3                	jne    8010121e <iget+0x27>
8010123b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010123e:	39 4b 04             	cmp    %ecx,0x4(%ebx)
80101241:	75 db                	jne    8010121e <iget+0x27>
      ip->ref++;
80101243:	83 c0 01             	add    $0x1,%eax
80101246:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101249:	83 ec 0c             	sub    $0xc,%esp
8010124c:	68 60 f9 10 80       	push   $0x8010f960
80101251:	e8 7e 31 00 00       	call   801043d4 <release>
      return ip;
80101256:	83 c4 10             	add    $0x10,%esp
80101259:	89 de                	mov    %ebx,%esi
8010125b:	eb 32                	jmp    8010128f <iget+0x98>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010125d:	85 c0                	test   %eax,%eax
8010125f:	75 c1                	jne    80101222 <iget+0x2b>
      empty = ip;
80101261:	89 de                	mov    %ebx,%esi
80101263:	eb bd                	jmp    80101222 <iget+0x2b>
  if(empty == 0)
80101265:	85 f6                	test   %esi,%esi
80101267:	74 30                	je     80101299 <iget+0xa2>
  ip->dev = dev;
80101269:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
8010126b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010126e:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
80101271:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
80101278:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
8010127f:	83 ec 0c             	sub    $0xc,%esp
80101282:	68 60 f9 10 80       	push   $0x8010f960
80101287:	e8 48 31 00 00       	call   801043d4 <release>
  return ip;
8010128c:	83 c4 10             	add    $0x10,%esp
}
8010128f:	89 f0                	mov    %esi,%eax
80101291:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101294:	5b                   	pop    %ebx
80101295:	5e                   	pop    %esi
80101296:	5f                   	pop    %edi
80101297:	5d                   	pop    %ebp
80101298:	c3                   	ret    
    panic("iget: no inodes");
80101299:	83 ec 0c             	sub    $0xc,%esp
8010129c:	68 3b 70 10 80       	push   $0x8010703b
801012a1:	e8 a2 f0 ff ff       	call   80100348 <panic>

801012a6 <readsb>:
{
801012a6:	55                   	push   %ebp
801012a7:	89 e5                	mov    %esp,%ebp
801012a9:	53                   	push   %ebx
801012aa:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
801012ad:	6a 01                	push   $0x1
801012af:	ff 75 08             	push   0x8(%ebp)
801012b2:	e8 b5 ee ff ff       	call   8010016c <bread>
801012b7:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801012b9:	8d 40 5c             	lea    0x5c(%eax),%eax
801012bc:	83 c4 0c             	add    $0xc,%esp
801012bf:	6a 1c                	push   $0x1c
801012c1:	50                   	push   %eax
801012c2:	ff 75 0c             	push   0xc(%ebp)
801012c5:	e8 c9 31 00 00       	call   80104493 <memmove>
  brelse(bp);
801012ca:	89 1c 24             	mov    %ebx,(%esp)
801012cd:	e8 03 ef ff ff       	call   801001d5 <brelse>
}
801012d2:	83 c4 10             	add    $0x10,%esp
801012d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801012d8:	c9                   	leave  
801012d9:	c3                   	ret    

801012da <iinit>:
{
801012da:	55                   	push   %ebp
801012db:	89 e5                	mov    %esp,%ebp
801012dd:	53                   	push   %ebx
801012de:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012e1:	68 4b 70 10 80       	push   $0x8010704b
801012e6:	68 60 f9 10 80       	push   $0x8010f960
801012eb:	e8 43 2f 00 00       	call   80104233 <initlock>
  for(i = 0; i < NINODE; i++) {
801012f0:	83 c4 10             	add    $0x10,%esp
801012f3:	bb 00 00 00 00       	mov    $0x0,%ebx
801012f8:	eb 21                	jmp    8010131b <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
801012fa:	83 ec 08             	sub    $0x8,%esp
801012fd:	68 52 70 10 80       	push   $0x80107052
80101302:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101305:	89 d0                	mov    %edx,%eax
80101307:	c1 e0 04             	shl    $0x4,%eax
8010130a:	05 a0 f9 10 80       	add    $0x8010f9a0,%eax
8010130f:	50                   	push   %eax
80101310:	e8 13 2e 00 00       	call   80104128 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101315:	83 c3 01             	add    $0x1,%ebx
80101318:	83 c4 10             	add    $0x10,%esp
8010131b:	83 fb 31             	cmp    $0x31,%ebx
8010131e:	7e da                	jle    801012fa <iinit+0x20>
  readsb(dev, &sb);
80101320:	83 ec 08             	sub    $0x8,%esp
80101323:	68 b4 15 11 80       	push   $0x801115b4
80101328:	ff 75 08             	push   0x8(%ebp)
8010132b:	e8 76 ff ff ff       	call   801012a6 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101330:	ff 35 cc 15 11 80    	push   0x801115cc
80101336:	ff 35 c8 15 11 80    	push   0x801115c8
8010133c:	ff 35 c4 15 11 80    	push   0x801115c4
80101342:	ff 35 c0 15 11 80    	push   0x801115c0
80101348:	ff 35 bc 15 11 80    	push   0x801115bc
8010134e:	ff 35 b8 15 11 80    	push   0x801115b8
80101354:	ff 35 b4 15 11 80    	push   0x801115b4
8010135a:	68 b8 70 10 80       	push   $0x801070b8
8010135f:	e8 a3 f2 ff ff       	call   80100607 <cprintf>
}
80101364:	83 c4 30             	add    $0x30,%esp
80101367:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010136a:	c9                   	leave  
8010136b:	c3                   	ret    

8010136c <ialloc>:
{
8010136c:	55                   	push   %ebp
8010136d:	89 e5                	mov    %esp,%ebp
8010136f:	57                   	push   %edi
80101370:	56                   	push   %esi
80101371:	53                   	push   %ebx
80101372:	83 ec 1c             	sub    $0x1c,%esp
80101375:	8b 45 0c             	mov    0xc(%ebp),%eax
80101378:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
8010137b:	bb 01 00 00 00       	mov    $0x1,%ebx
80101380:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80101383:	39 1d bc 15 11 80    	cmp    %ebx,0x801115bc
80101389:	76 3f                	jbe    801013ca <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
8010138b:	89 d8                	mov    %ebx,%eax
8010138d:	c1 e8 03             	shr    $0x3,%eax
80101390:	83 ec 08             	sub    $0x8,%esp
80101393:	03 05 c8 15 11 80    	add    0x801115c8,%eax
80101399:	50                   	push   %eax
8010139a:	ff 75 08             	push   0x8(%ebp)
8010139d:	e8 ca ed ff ff       	call   8010016c <bread>
801013a2:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
801013a4:	89 d8                	mov    %ebx,%eax
801013a6:	83 e0 07             	and    $0x7,%eax
801013a9:	c1 e0 06             	shl    $0x6,%eax
801013ac:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
801013b0:	83 c4 10             	add    $0x10,%esp
801013b3:	66 83 3f 00          	cmpw   $0x0,(%edi)
801013b7:	74 1e                	je     801013d7 <ialloc+0x6b>
    brelse(bp);
801013b9:	83 ec 0c             	sub    $0xc,%esp
801013bc:	56                   	push   %esi
801013bd:	e8 13 ee ff ff       	call   801001d5 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801013c2:	83 c3 01             	add    $0x1,%ebx
801013c5:	83 c4 10             	add    $0x10,%esp
801013c8:	eb b6                	jmp    80101380 <ialloc+0x14>
  panic("ialloc: no inodes");
801013ca:	83 ec 0c             	sub    $0xc,%esp
801013cd:	68 58 70 10 80       	push   $0x80107058
801013d2:	e8 71 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013d7:	83 ec 04             	sub    $0x4,%esp
801013da:	6a 40                	push   $0x40
801013dc:	6a 00                	push   $0x0
801013de:	57                   	push   %edi
801013df:	e8 37 30 00 00       	call   8010441b <memset>
      dip->type = type;
801013e4:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013e8:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013eb:	89 34 24             	mov    %esi,(%esp)
801013ee:	e8 e6 14 00 00       	call   801028d9 <log_write>
      brelse(bp);
801013f3:	89 34 24             	mov    %esi,(%esp)
801013f6:	e8 da ed ff ff       	call   801001d5 <brelse>
      return iget(dev, inum);
801013fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801013fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101401:	e8 f1 fd ff ff       	call   801011f7 <iget>
}
80101406:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101409:	5b                   	pop    %ebx
8010140a:	5e                   	pop    %esi
8010140b:	5f                   	pop    %edi
8010140c:	5d                   	pop    %ebp
8010140d:	c3                   	ret    

8010140e <iupdate>:
{
8010140e:	55                   	push   %ebp
8010140f:	89 e5                	mov    %esp,%ebp
80101411:	56                   	push   %esi
80101412:	53                   	push   %ebx
80101413:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101416:	8b 43 04             	mov    0x4(%ebx),%eax
80101419:	c1 e8 03             	shr    $0x3,%eax
8010141c:	83 ec 08             	sub    $0x8,%esp
8010141f:	03 05 c8 15 11 80    	add    0x801115c8,%eax
80101425:	50                   	push   %eax
80101426:	ff 33                	push   (%ebx)
80101428:	e8 3f ed ff ff       	call   8010016c <bread>
8010142d:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010142f:	8b 43 04             	mov    0x4(%ebx),%eax
80101432:	83 e0 07             	and    $0x7,%eax
80101435:	c1 e0 06             	shl    $0x6,%eax
80101438:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
8010143c:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
80101440:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101443:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
80101447:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010144b:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
8010144f:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101453:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
80101457:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010145b:	8b 53 58             	mov    0x58(%ebx),%edx
8010145e:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101461:	83 c3 5c             	add    $0x5c,%ebx
80101464:	83 c0 0c             	add    $0xc,%eax
80101467:	83 c4 0c             	add    $0xc,%esp
8010146a:	6a 34                	push   $0x34
8010146c:	53                   	push   %ebx
8010146d:	50                   	push   %eax
8010146e:	e8 20 30 00 00       	call   80104493 <memmove>
  log_write(bp);
80101473:	89 34 24             	mov    %esi,(%esp)
80101476:	e8 5e 14 00 00       	call   801028d9 <log_write>
  brelse(bp);
8010147b:	89 34 24             	mov    %esi,(%esp)
8010147e:	e8 52 ed ff ff       	call   801001d5 <brelse>
}
80101483:	83 c4 10             	add    $0x10,%esp
80101486:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101489:	5b                   	pop    %ebx
8010148a:	5e                   	pop    %esi
8010148b:	5d                   	pop    %ebp
8010148c:	c3                   	ret    

8010148d <itrunc>:
{
8010148d:	55                   	push   %ebp
8010148e:	89 e5                	mov    %esp,%ebp
80101490:	57                   	push   %edi
80101491:	56                   	push   %esi
80101492:	53                   	push   %ebx
80101493:	83 ec 1c             	sub    $0x1c,%esp
80101496:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
80101498:	bb 00 00 00 00       	mov    $0x0,%ebx
8010149d:	eb 03                	jmp    801014a2 <itrunc+0x15>
8010149f:	83 c3 01             	add    $0x1,%ebx
801014a2:	83 fb 0b             	cmp    $0xb,%ebx
801014a5:	7f 19                	jg     801014c0 <itrunc+0x33>
    if(ip->addrs[i]){
801014a7:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
801014ab:	85 d2                	test   %edx,%edx
801014ad:	74 f0                	je     8010149f <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
801014af:	8b 06                	mov    (%esi),%eax
801014b1:	e8 3d fb ff ff       	call   80100ff3 <bfree>
      ip->addrs[i] = 0;
801014b6:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
801014bd:	00 
801014be:	eb df                	jmp    8010149f <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
801014c0:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
801014c6:	85 c0                	test   %eax,%eax
801014c8:	75 1b                	jne    801014e5 <itrunc+0x58>
  ip->size = 0;
801014ca:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
801014d1:	83 ec 0c             	sub    $0xc,%esp
801014d4:	56                   	push   %esi
801014d5:	e8 34 ff ff ff       	call   8010140e <iupdate>
}
801014da:	83 c4 10             	add    $0x10,%esp
801014dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014e0:	5b                   	pop    %ebx
801014e1:	5e                   	pop    %esi
801014e2:	5f                   	pop    %edi
801014e3:	5d                   	pop    %ebp
801014e4:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801014e5:	83 ec 08             	sub    $0x8,%esp
801014e8:	50                   	push   %eax
801014e9:	ff 36                	push   (%esi)
801014eb:	e8 7c ec ff ff       	call   8010016c <bread>
801014f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
801014f3:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
801014f6:	83 c4 10             	add    $0x10,%esp
801014f9:	bb 00 00 00 00       	mov    $0x0,%ebx
801014fe:	eb 03                	jmp    80101503 <itrunc+0x76>
80101500:	83 c3 01             	add    $0x1,%ebx
80101503:	83 fb 7f             	cmp    $0x7f,%ebx
80101506:	77 10                	ja     80101518 <itrunc+0x8b>
      if(a[j])
80101508:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
8010150b:	85 d2                	test   %edx,%edx
8010150d:	74 f1                	je     80101500 <itrunc+0x73>
        bfree(ip->dev, a[j]);
8010150f:	8b 06                	mov    (%esi),%eax
80101511:	e8 dd fa ff ff       	call   80100ff3 <bfree>
80101516:	eb e8                	jmp    80101500 <itrunc+0x73>
    brelse(bp);
80101518:	83 ec 0c             	sub    $0xc,%esp
8010151b:	ff 75 e4             	push   -0x1c(%ebp)
8010151e:	e8 b2 ec ff ff       	call   801001d5 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101523:	8b 06                	mov    (%esi),%eax
80101525:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
8010152b:	e8 c3 fa ff ff       	call   80100ff3 <bfree>
    ip->addrs[NDIRECT] = 0;
80101530:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
80101537:	00 00 00 
8010153a:	83 c4 10             	add    $0x10,%esp
8010153d:	eb 8b                	jmp    801014ca <itrunc+0x3d>

8010153f <idup>:
{
8010153f:	55                   	push   %ebp
80101540:	89 e5                	mov    %esp,%ebp
80101542:	53                   	push   %ebx
80101543:	83 ec 10             	sub    $0x10,%esp
80101546:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
80101549:	68 60 f9 10 80       	push   $0x8010f960
8010154e:	e8 1c 2e 00 00       	call   8010436f <acquire>
  ip->ref++;
80101553:	8b 43 08             	mov    0x8(%ebx),%eax
80101556:	83 c0 01             	add    $0x1,%eax
80101559:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010155c:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101563:	e8 6c 2e 00 00       	call   801043d4 <release>
}
80101568:	89 d8                	mov    %ebx,%eax
8010156a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010156d:	c9                   	leave  
8010156e:	c3                   	ret    

8010156f <ilock>:
{
8010156f:	55                   	push   %ebp
80101570:	89 e5                	mov    %esp,%ebp
80101572:	56                   	push   %esi
80101573:	53                   	push   %ebx
80101574:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101577:	85 db                	test   %ebx,%ebx
80101579:	74 22                	je     8010159d <ilock+0x2e>
8010157b:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
8010157f:	7e 1c                	jle    8010159d <ilock+0x2e>
  acquiresleep(&ip->lock);
80101581:	83 ec 0c             	sub    $0xc,%esp
80101584:	8d 43 0c             	lea    0xc(%ebx),%eax
80101587:	50                   	push   %eax
80101588:	e8 ce 2b 00 00       	call   8010415b <acquiresleep>
  if(ip->valid == 0){
8010158d:	83 c4 10             	add    $0x10,%esp
80101590:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101594:	74 14                	je     801015aa <ilock+0x3b>
}
80101596:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101599:	5b                   	pop    %ebx
8010159a:	5e                   	pop    %esi
8010159b:	5d                   	pop    %ebp
8010159c:	c3                   	ret    
    panic("ilock");
8010159d:	83 ec 0c             	sub    $0xc,%esp
801015a0:	68 6a 70 10 80       	push   $0x8010706a
801015a5:	e8 9e ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015aa:	8b 43 04             	mov    0x4(%ebx),%eax
801015ad:	c1 e8 03             	shr    $0x3,%eax
801015b0:	83 ec 08             	sub    $0x8,%esp
801015b3:	03 05 c8 15 11 80    	add    0x801115c8,%eax
801015b9:	50                   	push   %eax
801015ba:	ff 33                	push   (%ebx)
801015bc:	e8 ab eb ff ff       	call   8010016c <bread>
801015c1:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801015c3:	8b 43 04             	mov    0x4(%ebx),%eax
801015c6:	83 e0 07             	and    $0x7,%eax
801015c9:	c1 e0 06             	shl    $0x6,%eax
801015cc:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801015d0:	0f b7 10             	movzwl (%eax),%edx
801015d3:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801015d7:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801015db:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801015df:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801015e3:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
801015e7:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801015eb:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
801015ef:	8b 50 08             	mov    0x8(%eax),%edx
801015f2:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801015f5:	83 c0 0c             	add    $0xc,%eax
801015f8:	8d 53 5c             	lea    0x5c(%ebx),%edx
801015fb:	83 c4 0c             	add    $0xc,%esp
801015fe:	6a 34                	push   $0x34
80101600:	50                   	push   %eax
80101601:	52                   	push   %edx
80101602:	e8 8c 2e 00 00       	call   80104493 <memmove>
    brelse(bp);
80101607:	89 34 24             	mov    %esi,(%esp)
8010160a:	e8 c6 eb ff ff       	call   801001d5 <brelse>
    ip->valid = 1;
8010160f:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101616:	83 c4 10             	add    $0x10,%esp
80101619:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
8010161e:	0f 85 72 ff ff ff    	jne    80101596 <ilock+0x27>
      panic("ilock: no type");
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	68 70 70 10 80       	push   $0x80107070
8010162c:	e8 17 ed ff ff       	call   80100348 <panic>

80101631 <iunlock>:
{
80101631:	55                   	push   %ebp
80101632:	89 e5                	mov    %esp,%ebp
80101634:	56                   	push   %esi
80101635:	53                   	push   %ebx
80101636:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101639:	85 db                	test   %ebx,%ebx
8010163b:	74 2c                	je     80101669 <iunlock+0x38>
8010163d:	8d 73 0c             	lea    0xc(%ebx),%esi
80101640:	83 ec 0c             	sub    $0xc,%esp
80101643:	56                   	push   %esi
80101644:	e8 9c 2b 00 00       	call   801041e5 <holdingsleep>
80101649:	83 c4 10             	add    $0x10,%esp
8010164c:	85 c0                	test   %eax,%eax
8010164e:	74 19                	je     80101669 <iunlock+0x38>
80101650:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101654:	7e 13                	jle    80101669 <iunlock+0x38>
  releasesleep(&ip->lock);
80101656:	83 ec 0c             	sub    $0xc,%esp
80101659:	56                   	push   %esi
8010165a:	e8 4b 2b 00 00       	call   801041aa <releasesleep>
}
8010165f:	83 c4 10             	add    $0x10,%esp
80101662:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101665:	5b                   	pop    %ebx
80101666:	5e                   	pop    %esi
80101667:	5d                   	pop    %ebp
80101668:	c3                   	ret    
    panic("iunlock");
80101669:	83 ec 0c             	sub    $0xc,%esp
8010166c:	68 7f 70 10 80       	push   $0x8010707f
80101671:	e8 d2 ec ff ff       	call   80100348 <panic>

80101676 <iput>:
{
80101676:	55                   	push   %ebp
80101677:	89 e5                	mov    %esp,%ebp
80101679:	57                   	push   %edi
8010167a:	56                   	push   %esi
8010167b:	53                   	push   %ebx
8010167c:	83 ec 18             	sub    $0x18,%esp
8010167f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101682:	8d 73 0c             	lea    0xc(%ebx),%esi
80101685:	56                   	push   %esi
80101686:	e8 d0 2a 00 00       	call   8010415b <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010168b:	83 c4 10             	add    $0x10,%esp
8010168e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101692:	74 07                	je     8010169b <iput+0x25>
80101694:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101699:	74 35                	je     801016d0 <iput+0x5a>
  releasesleep(&ip->lock);
8010169b:	83 ec 0c             	sub    $0xc,%esp
8010169e:	56                   	push   %esi
8010169f:	e8 06 2b 00 00       	call   801041aa <releasesleep>
  acquire(&icache.lock);
801016a4:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016ab:	e8 bf 2c 00 00       	call   8010436f <acquire>
  ip->ref--;
801016b0:	8b 43 08             	mov    0x8(%ebx),%eax
801016b3:	83 e8 01             	sub    $0x1,%eax
801016b6:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016b9:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016c0:	e8 0f 2d 00 00       	call   801043d4 <release>
}
801016c5:	83 c4 10             	add    $0x10,%esp
801016c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016cb:	5b                   	pop    %ebx
801016cc:	5e                   	pop    %esi
801016cd:	5f                   	pop    %edi
801016ce:	5d                   	pop    %ebp
801016cf:	c3                   	ret    
    acquire(&icache.lock);
801016d0:	83 ec 0c             	sub    $0xc,%esp
801016d3:	68 60 f9 10 80       	push   $0x8010f960
801016d8:	e8 92 2c 00 00       	call   8010436f <acquire>
    int r = ip->ref;
801016dd:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016e0:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016e7:	e8 e8 2c 00 00       	call   801043d4 <release>
    if(r == 1){
801016ec:	83 c4 10             	add    $0x10,%esp
801016ef:	83 ff 01             	cmp    $0x1,%edi
801016f2:	75 a7                	jne    8010169b <iput+0x25>
      itrunc(ip);
801016f4:	89 d8                	mov    %ebx,%eax
801016f6:	e8 92 fd ff ff       	call   8010148d <itrunc>
      ip->type = 0;
801016fb:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
80101701:	83 ec 0c             	sub    $0xc,%esp
80101704:	53                   	push   %ebx
80101705:	e8 04 fd ff ff       	call   8010140e <iupdate>
      ip->valid = 0;
8010170a:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101711:	83 c4 10             	add    $0x10,%esp
80101714:	eb 85                	jmp    8010169b <iput+0x25>

80101716 <iunlockput>:
{
80101716:	55                   	push   %ebp
80101717:	89 e5                	mov    %esp,%ebp
80101719:	53                   	push   %ebx
8010171a:	83 ec 10             	sub    $0x10,%esp
8010171d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101720:	53                   	push   %ebx
80101721:	e8 0b ff ff ff       	call   80101631 <iunlock>
  iput(ip);
80101726:	89 1c 24             	mov    %ebx,(%esp)
80101729:	e8 48 ff ff ff       	call   80101676 <iput>
}
8010172e:	83 c4 10             	add    $0x10,%esp
80101731:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101734:	c9                   	leave  
80101735:	c3                   	ret    

80101736 <stati>:
{
80101736:	55                   	push   %ebp
80101737:	89 e5                	mov    %esp,%ebp
80101739:	8b 55 08             	mov    0x8(%ebp),%edx
8010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
8010173f:	8b 0a                	mov    (%edx),%ecx
80101741:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101744:	8b 4a 04             	mov    0x4(%edx),%ecx
80101747:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
8010174a:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
8010174e:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101751:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101755:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101759:	8b 52 58             	mov    0x58(%edx),%edx
8010175c:	89 50 10             	mov    %edx,0x10(%eax)
}
8010175f:	5d                   	pop    %ebp
80101760:	c3                   	ret    

80101761 <readi>:
{
80101761:	55                   	push   %ebp
80101762:	89 e5                	mov    %esp,%ebp
80101764:	57                   	push   %edi
80101765:	56                   	push   %esi
80101766:	53                   	push   %ebx
80101767:	83 ec 1c             	sub    $0x1c,%esp
8010176a:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
8010176d:	8b 45 08             	mov    0x8(%ebp),%eax
80101770:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101775:	74 2c                	je     801017a3 <readi+0x42>
  if(off > ip->size || off + n < off)
80101777:	8b 45 08             	mov    0x8(%ebp),%eax
8010177a:	8b 40 58             	mov    0x58(%eax),%eax
8010177d:	39 f8                	cmp    %edi,%eax
8010177f:	0f 82 cb 00 00 00    	jb     80101850 <readi+0xef>
80101785:	89 fa                	mov    %edi,%edx
80101787:	03 55 14             	add    0x14(%ebp),%edx
8010178a:	0f 82 c7 00 00 00    	jb     80101857 <readi+0xf6>
  if(off + n > ip->size)
80101790:	39 d0                	cmp    %edx,%eax
80101792:	73 05                	jae    80101799 <readi+0x38>
    n = ip->size - off;
80101794:	29 f8                	sub    %edi,%eax
80101796:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101799:	be 00 00 00 00       	mov    $0x0,%esi
8010179e:	e9 8f 00 00 00       	jmp    80101832 <readi+0xd1>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801017a3:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801017a7:	66 83 f8 09          	cmp    $0x9,%ax
801017ab:	0f 87 91 00 00 00    	ja     80101842 <readi+0xe1>
801017b1:	98                   	cwtl   
801017b2:	8b 04 c5 00 f9 10 80 	mov    -0x7fef0700(,%eax,8),%eax
801017b9:	85 c0                	test   %eax,%eax
801017bb:	0f 84 88 00 00 00    	je     80101849 <readi+0xe8>
    return devsw[ip->major].read(ip, dst, n);
801017c1:	83 ec 04             	sub    $0x4,%esp
801017c4:	ff 75 14             	push   0x14(%ebp)
801017c7:	ff 75 0c             	push   0xc(%ebp)
801017ca:	ff 75 08             	push   0x8(%ebp)
801017cd:	ff d0                	call   *%eax
801017cf:	83 c4 10             	add    $0x10,%esp
801017d2:	eb 66                	jmp    8010183a <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801017d4:	89 fa                	mov    %edi,%edx
801017d6:	c1 ea 09             	shr    $0x9,%edx
801017d9:	8b 45 08             	mov    0x8(%ebp),%eax
801017dc:	e8 70 f9 ff ff       	call   80101151 <bmap>
801017e1:	83 ec 08             	sub    $0x8,%esp
801017e4:	50                   	push   %eax
801017e5:	8b 45 08             	mov    0x8(%ebp),%eax
801017e8:	ff 30                	push   (%eax)
801017ea:	e8 7d e9 ff ff       	call   8010016c <bread>
801017ef:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
801017f1:	89 f8                	mov    %edi,%eax
801017f3:	25 ff 01 00 00       	and    $0x1ff,%eax
801017f8:	bb 00 02 00 00       	mov    $0x200,%ebx
801017fd:	29 c3                	sub    %eax,%ebx
801017ff:	8b 55 14             	mov    0x14(%ebp),%edx
80101802:	29 f2                	sub    %esi,%edx
80101804:	39 d3                	cmp    %edx,%ebx
80101806:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101809:	83 c4 0c             	add    $0xc,%esp
8010180c:	53                   	push   %ebx
8010180d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101810:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101814:	50                   	push   %eax
80101815:	ff 75 0c             	push   0xc(%ebp)
80101818:	e8 76 2c 00 00       	call   80104493 <memmove>
    brelse(bp);
8010181d:	83 c4 04             	add    $0x4,%esp
80101820:	ff 75 e4             	push   -0x1c(%ebp)
80101823:	e8 ad e9 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101828:	01 de                	add    %ebx,%esi
8010182a:	01 df                	add    %ebx,%edi
8010182c:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010182f:	83 c4 10             	add    $0x10,%esp
80101832:	39 75 14             	cmp    %esi,0x14(%ebp)
80101835:	77 9d                	ja     801017d4 <readi+0x73>
  return n;
80101837:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010183a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010183d:	5b                   	pop    %ebx
8010183e:	5e                   	pop    %esi
8010183f:	5f                   	pop    %edi
80101840:	5d                   	pop    %ebp
80101841:	c3                   	ret    
      return -1;
80101842:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101847:	eb f1                	jmp    8010183a <readi+0xd9>
80101849:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010184e:	eb ea                	jmp    8010183a <readi+0xd9>
    return -1;
80101850:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101855:	eb e3                	jmp    8010183a <readi+0xd9>
80101857:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010185c:	eb dc                	jmp    8010183a <readi+0xd9>

8010185e <writei>:
{
8010185e:	55                   	push   %ebp
8010185f:	89 e5                	mov    %esp,%ebp
80101861:	57                   	push   %edi
80101862:	56                   	push   %esi
80101863:	53                   	push   %ebx
80101864:	83 ec 1c             	sub    $0x1c,%esp
80101867:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
8010186a:	8b 45 08             	mov    0x8(%ebp),%eax
8010186d:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101872:	74 2e                	je     801018a2 <writei+0x44>
  if(off > ip->size || off + n < off)
80101874:	8b 45 08             	mov    0x8(%ebp),%eax
80101877:	39 78 58             	cmp    %edi,0x58(%eax)
8010187a:	0f 82 f5 00 00 00    	jb     80101975 <writei+0x117>
80101880:	89 f8                	mov    %edi,%eax
80101882:	03 45 14             	add    0x14(%ebp),%eax
80101885:	0f 82 f1 00 00 00    	jb     8010197c <writei+0x11e>
  if(off + n > MAXFILE*BSIZE)
8010188b:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101890:	0f 87 ed 00 00 00    	ja     80101983 <writei+0x125>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101896:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010189d:	e9 93 00 00 00       	jmp    80101935 <writei+0xd7>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801018a2:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801018a6:	66 83 f8 09          	cmp    $0x9,%ax
801018aa:	0f 87 b7 00 00 00    	ja     80101967 <writei+0x109>
801018b0:	98                   	cwtl   
801018b1:	8b 04 c5 04 f9 10 80 	mov    -0x7fef06fc(,%eax,8),%eax
801018b8:	85 c0                	test   %eax,%eax
801018ba:	0f 84 ae 00 00 00    	je     8010196e <writei+0x110>
    return devsw[ip->major].write(ip, src, n);
801018c0:	83 ec 04             	sub    $0x4,%esp
801018c3:	ff 75 14             	push   0x14(%ebp)
801018c6:	ff 75 0c             	push   0xc(%ebp)
801018c9:	ff 75 08             	push   0x8(%ebp)
801018cc:	ff d0                	call   *%eax
801018ce:	83 c4 10             	add    $0x10,%esp
801018d1:	eb 7b                	jmp    8010194e <writei+0xf0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801018d3:	89 fa                	mov    %edi,%edx
801018d5:	c1 ea 09             	shr    $0x9,%edx
801018d8:	8b 45 08             	mov    0x8(%ebp),%eax
801018db:	e8 71 f8 ff ff       	call   80101151 <bmap>
801018e0:	83 ec 08             	sub    $0x8,%esp
801018e3:	50                   	push   %eax
801018e4:	8b 45 08             	mov    0x8(%ebp),%eax
801018e7:	ff 30                	push   (%eax)
801018e9:	e8 7e e8 ff ff       	call   8010016c <bread>
801018ee:	89 c6                	mov    %eax,%esi
    m = min(n - tot, BSIZE - off%BSIZE);
801018f0:	89 f8                	mov    %edi,%eax
801018f2:	25 ff 01 00 00       	and    $0x1ff,%eax
801018f7:	bb 00 02 00 00       	mov    $0x200,%ebx
801018fc:	29 c3                	sub    %eax,%ebx
801018fe:	8b 55 14             	mov    0x14(%ebp),%edx
80101901:	2b 55 e4             	sub    -0x1c(%ebp),%edx
80101904:	39 d3                	cmp    %edx,%ebx
80101906:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101909:	83 c4 0c             	add    $0xc,%esp
8010190c:	53                   	push   %ebx
8010190d:	ff 75 0c             	push   0xc(%ebp)
80101910:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
80101914:	50                   	push   %eax
80101915:	e8 79 2b 00 00       	call   80104493 <memmove>
    log_write(bp);
8010191a:	89 34 24             	mov    %esi,(%esp)
8010191d:	e8 b7 0f 00 00       	call   801028d9 <log_write>
    brelse(bp);
80101922:	89 34 24             	mov    %esi,(%esp)
80101925:	e8 ab e8 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010192a:	01 5d e4             	add    %ebx,-0x1c(%ebp)
8010192d:	01 df                	add    %ebx,%edi
8010192f:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101932:	83 c4 10             	add    $0x10,%esp
80101935:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101938:	3b 45 14             	cmp    0x14(%ebp),%eax
8010193b:	72 96                	jb     801018d3 <writei+0x75>
  if(n > 0 && off > ip->size){
8010193d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80101941:	74 08                	je     8010194b <writei+0xed>
80101943:	8b 45 08             	mov    0x8(%ebp),%eax
80101946:	39 78 58             	cmp    %edi,0x58(%eax)
80101949:	72 0b                	jb     80101956 <writei+0xf8>
  return n;
8010194b:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010194e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101951:	5b                   	pop    %ebx
80101952:	5e                   	pop    %esi
80101953:	5f                   	pop    %edi
80101954:	5d                   	pop    %ebp
80101955:	c3                   	ret    
    ip->size = off;
80101956:	89 78 58             	mov    %edi,0x58(%eax)
    iupdate(ip);
80101959:	83 ec 0c             	sub    $0xc,%esp
8010195c:	50                   	push   %eax
8010195d:	e8 ac fa ff ff       	call   8010140e <iupdate>
80101962:	83 c4 10             	add    $0x10,%esp
80101965:	eb e4                	jmp    8010194b <writei+0xed>
      return -1;
80101967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010196c:	eb e0                	jmp    8010194e <writei+0xf0>
8010196e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101973:	eb d9                	jmp    8010194e <writei+0xf0>
    return -1;
80101975:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010197a:	eb d2                	jmp    8010194e <writei+0xf0>
8010197c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101981:	eb cb                	jmp    8010194e <writei+0xf0>
    return -1;
80101983:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101988:	eb c4                	jmp    8010194e <writei+0xf0>

8010198a <namecmp>:
{
8010198a:	55                   	push   %ebp
8010198b:	89 e5                	mov    %esp,%ebp
8010198d:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101990:	6a 0e                	push   $0xe
80101992:	ff 75 0c             	push   0xc(%ebp)
80101995:	ff 75 08             	push   0x8(%ebp)
80101998:	e8 62 2b 00 00       	call   801044ff <strncmp>
}
8010199d:	c9                   	leave  
8010199e:	c3                   	ret    

8010199f <dirlookup>:
{
8010199f:	55                   	push   %ebp
801019a0:	89 e5                	mov    %esp,%ebp
801019a2:	57                   	push   %edi
801019a3:	56                   	push   %esi
801019a4:	53                   	push   %ebx
801019a5:	83 ec 1c             	sub    $0x1c,%esp
801019a8:	8b 75 08             	mov    0x8(%ebp),%esi
801019ab:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
801019ae:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801019b3:	75 07                	jne    801019bc <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019b5:	bb 00 00 00 00       	mov    $0x0,%ebx
801019ba:	eb 1d                	jmp    801019d9 <dirlookup+0x3a>
    panic("dirlookup not DIR");
801019bc:	83 ec 0c             	sub    $0xc,%esp
801019bf:	68 87 70 10 80       	push   $0x80107087
801019c4:	e8 7f e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019c9:	83 ec 0c             	sub    $0xc,%esp
801019cc:	68 99 70 10 80       	push   $0x80107099
801019d1:	e8 72 e9 ff ff       	call   80100348 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019d6:	83 c3 10             	add    $0x10,%ebx
801019d9:	39 5e 58             	cmp    %ebx,0x58(%esi)
801019dc:	76 48                	jbe    80101a26 <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801019de:	6a 10                	push   $0x10
801019e0:	53                   	push   %ebx
801019e1:	8d 45 d8             	lea    -0x28(%ebp),%eax
801019e4:	50                   	push   %eax
801019e5:	56                   	push   %esi
801019e6:	e8 76 fd ff ff       	call   80101761 <readi>
801019eb:	83 c4 10             	add    $0x10,%esp
801019ee:	83 f8 10             	cmp    $0x10,%eax
801019f1:	75 d6                	jne    801019c9 <dirlookup+0x2a>
    if(de.inum == 0)
801019f3:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801019f8:	74 dc                	je     801019d6 <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
801019fa:	83 ec 08             	sub    $0x8,%esp
801019fd:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a00:	50                   	push   %eax
80101a01:	57                   	push   %edi
80101a02:	e8 83 ff ff ff       	call   8010198a <namecmp>
80101a07:	83 c4 10             	add    $0x10,%esp
80101a0a:	85 c0                	test   %eax,%eax
80101a0c:	75 c8                	jne    801019d6 <dirlookup+0x37>
      if(poff)
80101a0e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a12:	74 05                	je     80101a19 <dirlookup+0x7a>
        *poff = off;
80101a14:	8b 45 10             	mov    0x10(%ebp),%eax
80101a17:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101a19:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101a1d:	8b 06                	mov    (%esi),%eax
80101a1f:	e8 d3 f7 ff ff       	call   801011f7 <iget>
80101a24:	eb 05                	jmp    80101a2b <dirlookup+0x8c>
  return 0;
80101a26:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101a2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a2e:	5b                   	pop    %ebx
80101a2f:	5e                   	pop    %esi
80101a30:	5f                   	pop    %edi
80101a31:	5d                   	pop    %ebp
80101a32:	c3                   	ret    

80101a33 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101a33:	55                   	push   %ebp
80101a34:	89 e5                	mov    %esp,%ebp
80101a36:	57                   	push   %edi
80101a37:	56                   	push   %esi
80101a38:	53                   	push   %ebx
80101a39:	83 ec 1c             	sub    $0x1c,%esp
80101a3c:	89 c3                	mov    %eax,%ebx
80101a3e:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101a41:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101a44:	80 38 2f             	cmpb   $0x2f,(%eax)
80101a47:	74 17                	je     80101a60 <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101a49:	e8 1c 1a 00 00       	call   8010346a <myproc>
80101a4e:	83 ec 0c             	sub    $0xc,%esp
80101a51:	ff 70 68             	push   0x68(%eax)
80101a54:	e8 e6 fa ff ff       	call   8010153f <idup>
80101a59:	89 c6                	mov    %eax,%esi
80101a5b:	83 c4 10             	add    $0x10,%esp
80101a5e:	eb 53                	jmp    80101ab3 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101a60:	ba 01 00 00 00       	mov    $0x1,%edx
80101a65:	b8 01 00 00 00       	mov    $0x1,%eax
80101a6a:	e8 88 f7 ff ff       	call   801011f7 <iget>
80101a6f:	89 c6                	mov    %eax,%esi
80101a71:	eb 40                	jmp    80101ab3 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a73:	83 ec 0c             	sub    $0xc,%esp
80101a76:	56                   	push   %esi
80101a77:	e8 9a fc ff ff       	call   80101716 <iunlockput>
      return 0;
80101a7c:	83 c4 10             	add    $0x10,%esp
80101a7f:	be 00 00 00 00       	mov    $0x0,%esi
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a84:	89 f0                	mov    %esi,%eax
80101a86:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a89:	5b                   	pop    %ebx
80101a8a:	5e                   	pop    %esi
80101a8b:	5f                   	pop    %edi
80101a8c:	5d                   	pop    %ebp
80101a8d:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101a8e:	83 ec 04             	sub    $0x4,%esp
80101a91:	6a 00                	push   $0x0
80101a93:	ff 75 e4             	push   -0x1c(%ebp)
80101a96:	56                   	push   %esi
80101a97:	e8 03 ff ff ff       	call   8010199f <dirlookup>
80101a9c:	89 c7                	mov    %eax,%edi
80101a9e:	83 c4 10             	add    $0x10,%esp
80101aa1:	85 c0                	test   %eax,%eax
80101aa3:	74 4a                	je     80101aef <namex+0xbc>
    iunlockput(ip);
80101aa5:	83 ec 0c             	sub    $0xc,%esp
80101aa8:	56                   	push   %esi
80101aa9:	e8 68 fc ff ff       	call   80101716 <iunlockput>
80101aae:	83 c4 10             	add    $0x10,%esp
    ip = next;
80101ab1:	89 fe                	mov    %edi,%esi
  while((path = skipelem(path, name)) != 0){
80101ab3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101ab6:	89 d8                	mov    %ebx,%eax
80101ab8:	e8 85 f4 ff ff       	call   80100f42 <skipelem>
80101abd:	89 c3                	mov    %eax,%ebx
80101abf:	85 c0                	test   %eax,%eax
80101ac1:	74 3c                	je     80101aff <namex+0xcc>
    ilock(ip);
80101ac3:	83 ec 0c             	sub    $0xc,%esp
80101ac6:	56                   	push   %esi
80101ac7:	e8 a3 fa ff ff       	call   8010156f <ilock>
    if(ip->type != T_DIR){
80101acc:	83 c4 10             	add    $0x10,%esp
80101acf:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101ad4:	75 9d                	jne    80101a73 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101ad6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101ada:	74 b2                	je     80101a8e <namex+0x5b>
80101adc:	80 3b 00             	cmpb   $0x0,(%ebx)
80101adf:	75 ad                	jne    80101a8e <namex+0x5b>
      iunlock(ip);
80101ae1:	83 ec 0c             	sub    $0xc,%esp
80101ae4:	56                   	push   %esi
80101ae5:	e8 47 fb ff ff       	call   80101631 <iunlock>
      return ip;
80101aea:	83 c4 10             	add    $0x10,%esp
80101aed:	eb 95                	jmp    80101a84 <namex+0x51>
      iunlockput(ip);
80101aef:	83 ec 0c             	sub    $0xc,%esp
80101af2:	56                   	push   %esi
80101af3:	e8 1e fc ff ff       	call   80101716 <iunlockput>
      return 0;
80101af8:	83 c4 10             	add    $0x10,%esp
80101afb:	89 fe                	mov    %edi,%esi
80101afd:	eb 85                	jmp    80101a84 <namex+0x51>
  if(nameiparent){
80101aff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b03:	0f 84 7b ff ff ff    	je     80101a84 <namex+0x51>
    iput(ip);
80101b09:	83 ec 0c             	sub    $0xc,%esp
80101b0c:	56                   	push   %esi
80101b0d:	e8 64 fb ff ff       	call   80101676 <iput>
    return 0;
80101b12:	83 c4 10             	add    $0x10,%esp
80101b15:	89 de                	mov    %ebx,%esi
80101b17:	e9 68 ff ff ff       	jmp    80101a84 <namex+0x51>

80101b1c <dirlink>:
{
80101b1c:	55                   	push   %ebp
80101b1d:	89 e5                	mov    %esp,%ebp
80101b1f:	57                   	push   %edi
80101b20:	56                   	push   %esi
80101b21:	53                   	push   %ebx
80101b22:	83 ec 20             	sub    $0x20,%esp
80101b25:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101b28:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101b2b:	6a 00                	push   $0x0
80101b2d:	57                   	push   %edi
80101b2e:	53                   	push   %ebx
80101b2f:	e8 6b fe ff ff       	call   8010199f <dirlookup>
80101b34:	83 c4 10             	add    $0x10,%esp
80101b37:	85 c0                	test   %eax,%eax
80101b39:	75 2d                	jne    80101b68 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b3b:	b8 00 00 00 00       	mov    $0x0,%eax
80101b40:	89 c6                	mov    %eax,%esi
80101b42:	39 43 58             	cmp    %eax,0x58(%ebx)
80101b45:	76 41                	jbe    80101b88 <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b47:	6a 10                	push   $0x10
80101b49:	50                   	push   %eax
80101b4a:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b4d:	50                   	push   %eax
80101b4e:	53                   	push   %ebx
80101b4f:	e8 0d fc ff ff       	call   80101761 <readi>
80101b54:	83 c4 10             	add    $0x10,%esp
80101b57:	83 f8 10             	cmp    $0x10,%eax
80101b5a:	75 1f                	jne    80101b7b <dirlink+0x5f>
    if(de.inum == 0)
80101b5c:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b61:	74 25                	je     80101b88 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b63:	8d 46 10             	lea    0x10(%esi),%eax
80101b66:	eb d8                	jmp    80101b40 <dirlink+0x24>
    iput(ip);
80101b68:	83 ec 0c             	sub    $0xc,%esp
80101b6b:	50                   	push   %eax
80101b6c:	e8 05 fb ff ff       	call   80101676 <iput>
    return -1;
80101b71:	83 c4 10             	add    $0x10,%esp
80101b74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b79:	eb 3d                	jmp    80101bb8 <dirlink+0x9c>
      panic("dirlink read");
80101b7b:	83 ec 0c             	sub    $0xc,%esp
80101b7e:	68 a8 70 10 80       	push   $0x801070a8
80101b83:	e8 c0 e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b88:	83 ec 04             	sub    $0x4,%esp
80101b8b:	6a 0e                	push   $0xe
80101b8d:	57                   	push   %edi
80101b8e:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b91:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b94:	50                   	push   %eax
80101b95:	e8 a4 29 00 00       	call   8010453e <strncpy>
  de.inum = inum;
80101b9a:	8b 45 10             	mov    0x10(%ebp),%eax
80101b9d:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101ba1:	6a 10                	push   $0x10
80101ba3:	56                   	push   %esi
80101ba4:	57                   	push   %edi
80101ba5:	53                   	push   %ebx
80101ba6:	e8 b3 fc ff ff       	call   8010185e <writei>
80101bab:	83 c4 20             	add    $0x20,%esp
80101bae:	83 f8 10             	cmp    $0x10,%eax
80101bb1:	75 0d                	jne    80101bc0 <dirlink+0xa4>
  return 0;
80101bb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101bbb:	5b                   	pop    %ebx
80101bbc:	5e                   	pop    %esi
80101bbd:	5f                   	pop    %edi
80101bbe:	5d                   	pop    %ebp
80101bbf:	c3                   	ret    
    panic("dirlink");
80101bc0:	83 ec 0c             	sub    $0xc,%esp
80101bc3:	68 80 78 10 80       	push   $0x80107880
80101bc8:	e8 7b e7 ff ff       	call   80100348 <panic>

80101bcd <namei>:

struct inode*
namei(char *path)
{
80101bcd:	55                   	push   %ebp
80101bce:	89 e5                	mov    %esp,%ebp
80101bd0:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101bd3:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101bd6:	ba 00 00 00 00       	mov    $0x0,%edx
80101bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bde:	e8 50 fe ff ff       	call   80101a33 <namex>
}
80101be3:	c9                   	leave  
80101be4:	c3                   	ret    

80101be5 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101be5:	55                   	push   %ebp
80101be6:	89 e5                	mov    %esp,%ebp
80101be8:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101bee:	ba 01 00 00 00       	mov    $0x1,%edx
80101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf6:	e8 38 fe ff ff       	call   80101a33 <namex>
}
80101bfb:	c9                   	leave  
80101bfc:	c3                   	ret    

80101bfd <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101bfd:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101bff:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c04:	ec                   	in     (%dx),%al
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101c05:	89 c2                	mov    %eax,%edx
80101c07:	83 e2 c0             	and    $0xffffffc0,%edx
80101c0a:	80 fa 40             	cmp    $0x40,%dl
80101c0d:	75 f0                	jne    80101bff <idewait+0x2>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101c0f:	85 c9                	test   %ecx,%ecx
80101c11:	74 09                	je     80101c1c <idewait+0x1f>
80101c13:	a8 21                	test   $0x21,%al
80101c15:	75 08                	jne    80101c1f <idewait+0x22>
    return -1;
  return 0;
80101c17:	b9 00 00 00 00       	mov    $0x0,%ecx
}
80101c1c:	89 c8                	mov    %ecx,%eax
80101c1e:	c3                   	ret    
    return -1;
80101c1f:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
80101c24:	eb f6                	jmp    80101c1c <idewait+0x1f>

80101c26 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101c26:	55                   	push   %ebp
80101c27:	89 e5                	mov    %esp,%ebp
80101c29:	56                   	push   %esi
80101c2a:	53                   	push   %ebx
  if(b == 0)
80101c2b:	85 c0                	test   %eax,%eax
80101c2d:	0f 84 8f 00 00 00    	je     80101cc2 <idestart+0x9c>
80101c33:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101c35:	8b 58 08             	mov    0x8(%eax),%ebx
80101c38:	81 fb cf 07 00 00    	cmp    $0x7cf,%ebx
80101c3e:	0f 87 8b 00 00 00    	ja     80101ccf <idestart+0xa9>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101c44:	b8 00 00 00 00       	mov    $0x0,%eax
80101c49:	e8 af ff ff ff       	call   80101bfd <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c4e:	b8 00 00 00 00       	mov    $0x0,%eax
80101c53:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101c58:	ee                   	out    %al,(%dx)
80101c59:	b8 01 00 00 00       	mov    $0x1,%eax
80101c5e:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c63:	ee                   	out    %al,(%dx)
80101c64:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c69:	89 d8                	mov    %ebx,%eax
80101c6b:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c6c:	0f b6 c7             	movzbl %bh,%eax
80101c6f:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c74:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101c75:	89 d8                	mov    %ebx,%eax
80101c77:	c1 f8 10             	sar    $0x10,%eax
80101c7a:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101c7f:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101c80:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101c84:	c1 e0 04             	shl    $0x4,%eax
80101c87:	83 e0 10             	and    $0x10,%eax
80101c8a:	c1 fb 18             	sar    $0x18,%ebx
80101c8d:	83 e3 0f             	and    $0xf,%ebx
80101c90:	09 d8                	or     %ebx,%eax
80101c92:	83 c8 e0             	or     $0xffffffe0,%eax
80101c95:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101c9a:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101c9b:	f6 06 04             	testb  $0x4,(%esi)
80101c9e:	74 3c                	je     80101cdc <idestart+0xb6>
80101ca0:	b8 30 00 00 00       	mov    $0x30,%eax
80101ca5:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101caa:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
80101cab:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101cae:	b9 80 00 00 00       	mov    $0x80,%ecx
80101cb3:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101cb8:	fc                   	cld    
80101cb9:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101cbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101cbe:	5b                   	pop    %ebx
80101cbf:	5e                   	pop    %esi
80101cc0:	5d                   	pop    %ebp
80101cc1:	c3                   	ret    
    panic("idestart");
80101cc2:	83 ec 0c             	sub    $0xc,%esp
80101cc5:	68 0b 71 10 80       	push   $0x8010710b
80101cca:	e8 79 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101ccf:	83 ec 0c             	sub    $0xc,%esp
80101cd2:	68 14 71 10 80       	push   $0x80107114
80101cd7:	e8 6c e6 ff ff       	call   80100348 <panic>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101cdc:	b8 20 00 00 00       	mov    $0x20,%eax
80101ce1:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ce6:	ee                   	out    %al,(%dx)
}
80101ce7:	eb d2                	jmp    80101cbb <idestart+0x95>

80101ce9 <ideinit>:
{
80101ce9:	55                   	push   %ebp
80101cea:	89 e5                	mov    %esp,%ebp
80101cec:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101cef:	68 26 71 10 80       	push   $0x80107126
80101cf4:	68 00 16 11 80       	push   $0x80111600
80101cf9:	e8 35 25 00 00       	call   80104233 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101cfe:	83 c4 08             	add    $0x8,%esp
80101d01:	a1 84 17 11 80       	mov    0x80111784,%eax
80101d06:	83 e8 01             	sub    $0x1,%eax
80101d09:	50                   	push   %eax
80101d0a:	6a 0e                	push   $0xe
80101d0c:	e8 50 02 00 00       	call   80101f61 <ioapicenable>
  idewait(0);
80101d11:	b8 00 00 00 00       	mov    $0x0,%eax
80101d16:	e8 e2 fe ff ff       	call   80101bfd <idewait>
80101d1b:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101d20:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d25:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101d26:	83 c4 10             	add    $0x10,%esp
80101d29:	b9 00 00 00 00       	mov    $0x0,%ecx
80101d2e:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101d34:	7f 19                	jg     80101d4f <ideinit+0x66>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d36:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d3b:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101d3c:	84 c0                	test   %al,%al
80101d3e:	75 05                	jne    80101d45 <ideinit+0x5c>
  for(i=0; i<1000; i++){
80101d40:	83 c1 01             	add    $0x1,%ecx
80101d43:	eb e9                	jmp    80101d2e <ideinit+0x45>
      havedisk1 = 1;
80101d45:	c7 05 e0 15 11 80 01 	movl   $0x1,0x801115e0
80101d4c:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d4f:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101d54:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d59:	ee                   	out    %al,(%dx)
}
80101d5a:	c9                   	leave  
80101d5b:	c3                   	ret    

80101d5c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101d5c:	55                   	push   %ebp
80101d5d:	89 e5                	mov    %esp,%ebp
80101d5f:	57                   	push   %edi
80101d60:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101d61:	83 ec 0c             	sub    $0xc,%esp
80101d64:	68 00 16 11 80       	push   $0x80111600
80101d69:	e8 01 26 00 00       	call   8010436f <acquire>

  if((b = idequeue) == 0){
80101d6e:	8b 1d e4 15 11 80    	mov    0x801115e4,%ebx
80101d74:	83 c4 10             	add    $0x10,%esp
80101d77:	85 db                	test   %ebx,%ebx
80101d79:	74 4a                	je     80101dc5 <ideintr+0x69>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d7b:	8b 43 58             	mov    0x58(%ebx),%eax
80101d7e:	a3 e4 15 11 80       	mov    %eax,0x801115e4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d83:	f6 03 04             	testb  $0x4,(%ebx)
80101d86:	74 4f                	je     80101dd7 <ideintr+0x7b>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101d88:	8b 03                	mov    (%ebx),%eax
80101d8a:	83 c8 02             	or     $0x2,%eax
80101d8d:	89 03                	mov    %eax,(%ebx)
  b->flags &= ~B_DIRTY;
80101d8f:	83 e0 fb             	and    $0xfffffffb,%eax
80101d92:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101d94:	83 ec 0c             	sub    $0xc,%esp
80101d97:	53                   	push   %ebx
80101d98:	e8 37 22 00 00       	call   80103fd4 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101d9d:	a1 e4 15 11 80       	mov    0x801115e4,%eax
80101da2:	83 c4 10             	add    $0x10,%esp
80101da5:	85 c0                	test   %eax,%eax
80101da7:	74 05                	je     80101dae <ideintr+0x52>
    idestart(idequeue);
80101da9:	e8 78 fe ff ff       	call   80101c26 <idestart>

  release(&idelock);
80101dae:	83 ec 0c             	sub    $0xc,%esp
80101db1:	68 00 16 11 80       	push   $0x80111600
80101db6:	e8 19 26 00 00       	call   801043d4 <release>
80101dbb:	83 c4 10             	add    $0x10,%esp
}
80101dbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101dc1:	5b                   	pop    %ebx
80101dc2:	5f                   	pop    %edi
80101dc3:	5d                   	pop    %ebp
80101dc4:	c3                   	ret    
    release(&idelock);
80101dc5:	83 ec 0c             	sub    $0xc,%esp
80101dc8:	68 00 16 11 80       	push   $0x80111600
80101dcd:	e8 02 26 00 00       	call   801043d4 <release>
    return;
80101dd2:	83 c4 10             	add    $0x10,%esp
80101dd5:	eb e7                	jmp    80101dbe <ideintr+0x62>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101dd7:	b8 01 00 00 00       	mov    $0x1,%eax
80101ddc:	e8 1c fe ff ff       	call   80101bfd <idewait>
80101de1:	85 c0                	test   %eax,%eax
80101de3:	78 a3                	js     80101d88 <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101de5:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101de8:	b9 80 00 00 00       	mov    $0x80,%ecx
80101ded:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101df2:	fc                   	cld    
80101df3:	f3 6d                	rep insl (%dx),%es:(%edi)
}
80101df5:	eb 91                	jmp    80101d88 <ideintr+0x2c>

80101df7 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101df7:	55                   	push   %ebp
80101df8:	89 e5                	mov    %esp,%ebp
80101dfa:	53                   	push   %ebx
80101dfb:	83 ec 10             	sub    $0x10,%esp
80101dfe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101e01:	8d 43 0c             	lea    0xc(%ebx),%eax
80101e04:	50                   	push   %eax
80101e05:	e8 db 23 00 00       	call   801041e5 <holdingsleep>
80101e0a:	83 c4 10             	add    $0x10,%esp
80101e0d:	85 c0                	test   %eax,%eax
80101e0f:	74 37                	je     80101e48 <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101e11:	8b 03                	mov    (%ebx),%eax
80101e13:	83 e0 06             	and    $0x6,%eax
80101e16:	83 f8 02             	cmp    $0x2,%eax
80101e19:	74 3a                	je     80101e55 <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101e1b:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101e1f:	74 09                	je     80101e2a <iderw+0x33>
80101e21:	83 3d e0 15 11 80 00 	cmpl   $0x0,0x801115e0
80101e28:	74 38                	je     80101e62 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e2a:	83 ec 0c             	sub    $0xc,%esp
80101e2d:	68 00 16 11 80       	push   $0x80111600
80101e32:	e8 38 25 00 00       	call   8010436f <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e37:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e3e:	83 c4 10             	add    $0x10,%esp
80101e41:	ba e4 15 11 80       	mov    $0x801115e4,%edx
80101e46:	eb 2a                	jmp    80101e72 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e48:	83 ec 0c             	sub    $0xc,%esp
80101e4b:	68 2a 71 10 80       	push   $0x8010712a
80101e50:	e8 f3 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e55:	83 ec 0c             	sub    $0xc,%esp
80101e58:	68 40 71 10 80       	push   $0x80107140
80101e5d:	e8 e6 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e62:	83 ec 0c             	sub    $0xc,%esp
80101e65:	68 55 71 10 80       	push   $0x80107155
80101e6a:	e8 d9 e4 ff ff       	call   80100348 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e6f:	8d 50 58             	lea    0x58(%eax),%edx
80101e72:	8b 02                	mov    (%edx),%eax
80101e74:	85 c0                	test   %eax,%eax
80101e76:	75 f7                	jne    80101e6f <iderw+0x78>
    ;
  *pp = b;
80101e78:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101e7a:	39 1d e4 15 11 80    	cmp    %ebx,0x801115e4
80101e80:	75 1a                	jne    80101e9c <iderw+0xa5>
    idestart(b);
80101e82:	89 d8                	mov    %ebx,%eax
80101e84:	e8 9d fd ff ff       	call   80101c26 <idestart>
80101e89:	eb 11                	jmp    80101e9c <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101e8b:	83 ec 08             	sub    $0x8,%esp
80101e8e:	68 00 16 11 80       	push   $0x80111600
80101e93:	53                   	push   %ebx
80101e94:	e8 d3 1f 00 00       	call   80103e6c <sleep>
80101e99:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101e9c:	8b 03                	mov    (%ebx),%eax
80101e9e:	83 e0 06             	and    $0x6,%eax
80101ea1:	83 f8 02             	cmp    $0x2,%eax
80101ea4:	75 e5                	jne    80101e8b <iderw+0x94>
  }


  release(&idelock);
80101ea6:	83 ec 0c             	sub    $0xc,%esp
80101ea9:	68 00 16 11 80       	push   $0x80111600
80101eae:	e8 21 25 00 00       	call   801043d4 <release>
}
80101eb3:	83 c4 10             	add    $0x10,%esp
80101eb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101eb9:	c9                   	leave  
80101eba:	c3                   	ret    

80101ebb <ioapicread>:
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
80101ebb:	8b 15 34 16 11 80    	mov    0x80111634,%edx
80101ec1:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101ec3:	a1 34 16 11 80       	mov    0x80111634,%eax
80101ec8:	8b 40 10             	mov    0x10(%eax),%eax
}
80101ecb:	c3                   	ret    

80101ecc <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80101ecc:	8b 0d 34 16 11 80    	mov    0x80111634,%ecx
80101ed2:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101ed4:	a1 34 16 11 80       	mov    0x80111634,%eax
80101ed9:	89 50 10             	mov    %edx,0x10(%eax)
}
80101edc:	c3                   	ret    

80101edd <ioapicinit>:

void
ioapicinit(void)
{
80101edd:	55                   	push   %ebp
80101ede:	89 e5                	mov    %esp,%ebp
80101ee0:	57                   	push   %edi
80101ee1:	56                   	push   %esi
80101ee2:	53                   	push   %ebx
80101ee3:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101ee6:	c7 05 34 16 11 80 00 	movl   $0xfec00000,0x80111634
80101eed:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101ef0:	b8 01 00 00 00       	mov    $0x1,%eax
80101ef5:	e8 c1 ff ff ff       	call   80101ebb <ioapicread>
80101efa:	c1 e8 10             	shr    $0x10,%eax
80101efd:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101f00:	b8 00 00 00 00       	mov    $0x0,%eax
80101f05:	e8 b1 ff ff ff       	call   80101ebb <ioapicread>
80101f0a:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101f0d:	0f b6 15 80 17 11 80 	movzbl 0x80111780,%edx
80101f14:	39 c2                	cmp    %eax,%edx
80101f16:	75 07                	jne    80101f1f <ioapicinit+0x42>
{
80101f18:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f1d:	eb 36                	jmp    80101f55 <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f1f:	83 ec 0c             	sub    $0xc,%esp
80101f22:	68 74 71 10 80       	push   $0x80107174
80101f27:	e8 db e6 ff ff       	call   80100607 <cprintf>
80101f2c:	83 c4 10             	add    $0x10,%esp
80101f2f:	eb e7                	jmp    80101f18 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101f31:	8d 53 20             	lea    0x20(%ebx),%edx
80101f34:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101f3a:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101f3e:	89 f0                	mov    %esi,%eax
80101f40:	e8 87 ff ff ff       	call   80101ecc <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101f45:	8d 46 01             	lea    0x1(%esi),%eax
80101f48:	ba 00 00 00 00       	mov    $0x0,%edx
80101f4d:	e8 7a ff ff ff       	call   80101ecc <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101f52:	83 c3 01             	add    $0x1,%ebx
80101f55:	39 fb                	cmp    %edi,%ebx
80101f57:	7e d8                	jle    80101f31 <ioapicinit+0x54>
  }
}
80101f59:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f5c:	5b                   	pop    %ebx
80101f5d:	5e                   	pop    %esi
80101f5e:	5f                   	pop    %edi
80101f5f:	5d                   	pop    %ebp
80101f60:	c3                   	ret    

80101f61 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101f61:	55                   	push   %ebp
80101f62:	89 e5                	mov    %esp,%ebp
80101f64:	53                   	push   %ebx
80101f65:	83 ec 04             	sub    $0x4,%esp
80101f68:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101f6b:	8d 50 20             	lea    0x20(%eax),%edx
80101f6e:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101f72:	89 d8                	mov    %ebx,%eax
80101f74:	e8 53 ff ff ff       	call   80101ecc <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f79:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f7c:	c1 e2 18             	shl    $0x18,%edx
80101f7f:	8d 43 01             	lea    0x1(%ebx),%eax
80101f82:	e8 45 ff ff ff       	call   80101ecc <ioapicwrite>
}
80101f87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f8a:	c9                   	leave  
80101f8b:	c3                   	ret    

80101f8c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101f8c:	55                   	push   %ebp
80101f8d:	89 e5                	mov    %esp,%ebp
80101f8f:	53                   	push   %ebx
80101f90:	83 ec 04             	sub    $0x4,%esp
80101f93:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101f96:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101f9c:	75 61                	jne    80101fff <kfree+0x73>
80101f9e:	81 fb 90 5e 11 80    	cmp    $0x80115e90,%ebx
80101fa4:	72 59                	jb     80101fff <kfree+0x73>

// Convert kernel virtual address to physical address
static inline uint V2P(void *a) {
    // define panic() here because memlayout.h is included before defs.h
    extern void panic(char*) __attribute__((noreturn));
    if (a < (void*) KERNBASE)
80101fa6:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80101fac:	76 44                	jbe    80101ff2 <kfree+0x66>
        panic("V2P on address < KERNBASE "
              "(not a kernel virtual address; consider walking page "
              "table to determine physical address of a user virtual address)");
    return (uint)a - KERNBASE;
80101fae:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101fb4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101fb9:	77 44                	ja     80101fff <kfree+0x73>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101fbb:	83 ec 04             	sub    $0x4,%esp
80101fbe:	68 00 10 00 00       	push   $0x1000
80101fc3:	6a 01                	push   $0x1
80101fc5:	53                   	push   %ebx
80101fc6:	e8 50 24 00 00       	call   8010441b <memset>

  if(kmem.use_lock)
80101fcb:	83 c4 10             	add    $0x10,%esp
80101fce:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80101fd5:	75 35                	jne    8010200c <kfree+0x80>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80101fd7:	a1 78 16 11 80       	mov    0x80111678,%eax
80101fdc:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101fde:	89 1d 78 16 11 80    	mov    %ebx,0x80111678
  if(kmem.use_lock)
80101fe4:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80101feb:	75 31                	jne    8010201e <kfree+0x92>
    release(&kmem.lock);
}
80101fed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101ff0:	c9                   	leave  
80101ff1:	c3                   	ret    
        panic("V2P on address < KERNBASE "
80101ff2:	83 ec 0c             	sub    $0xc,%esp
80101ff5:	68 a8 71 10 80       	push   $0x801071a8
80101ffa:	e8 49 e3 ff ff       	call   80100348 <panic>
    panic("kfree");
80101fff:	83 ec 0c             	sub    $0xc,%esp
80102002:	68 36 72 10 80       	push   $0x80107236
80102007:	e8 3c e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200c:	83 ec 0c             	sub    $0xc,%esp
8010200f:	68 40 16 11 80       	push   $0x80111640
80102014:	e8 56 23 00 00       	call   8010436f <acquire>
80102019:	83 c4 10             	add    $0x10,%esp
8010201c:	eb b9                	jmp    80101fd7 <kfree+0x4b>
    release(&kmem.lock);
8010201e:	83 ec 0c             	sub    $0xc,%esp
80102021:	68 40 16 11 80       	push   $0x80111640
80102026:	e8 a9 23 00 00       	call   801043d4 <release>
8010202b:	83 c4 10             	add    $0x10,%esp
}
8010202e:	eb bd                	jmp    80101fed <kfree+0x61>

80102030 <freerange>:
{
80102030:	55                   	push   %ebp
80102031:	89 e5                	mov    %esp,%ebp
80102033:	56                   	push   %esi
80102034:	53                   	push   %ebx
80102035:	8b 45 08             	mov    0x8(%ebp),%eax
80102038:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if (vend < vstart) panic("freerange");
8010203b:	39 c3                	cmp    %eax,%ebx
8010203d:	72 0c                	jb     8010204b <freerange+0x1b>
  p = (char*)PGROUNDUP((uint)vstart);
8010203f:	05 ff 0f 00 00       	add    $0xfff,%eax
80102044:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102049:	eb 1b                	jmp    80102066 <freerange+0x36>
  if (vend < vstart) panic("freerange");
8010204b:	83 ec 0c             	sub    $0xc,%esp
8010204e:	68 3c 72 10 80       	push   $0x8010723c
80102053:	e8 f0 e2 ff ff       	call   80100348 <panic>
    kfree(p);
80102058:	83 ec 0c             	sub    $0xc,%esp
8010205b:	50                   	push   %eax
8010205c:	e8 2b ff ff ff       	call   80101f8c <kfree>
80102061:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102064:	89 f0                	mov    %esi,%eax
80102066:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
8010206c:	39 de                	cmp    %ebx,%esi
8010206e:	76 e8                	jbe    80102058 <freerange+0x28>
}
80102070:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102073:	5b                   	pop    %ebx
80102074:	5e                   	pop    %esi
80102075:	5d                   	pop    %ebp
80102076:	c3                   	ret    

80102077 <kinit1>:
{
80102077:	55                   	push   %ebp
80102078:	89 e5                	mov    %esp,%ebp
8010207a:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
8010207d:	68 46 72 10 80       	push   $0x80107246
80102082:	68 40 16 11 80       	push   $0x80111640
80102087:	e8 a7 21 00 00       	call   80104233 <initlock>
  kmem.use_lock = 0;
8010208c:	c7 05 74 16 11 80 00 	movl   $0x0,0x80111674
80102093:	00 00 00 
  freerange(vstart, vend);
80102096:	83 c4 08             	add    $0x8,%esp
80102099:	ff 75 0c             	push   0xc(%ebp)
8010209c:	ff 75 08             	push   0x8(%ebp)
8010209f:	e8 8c ff ff ff       	call   80102030 <freerange>
}
801020a4:	83 c4 10             	add    $0x10,%esp
801020a7:	c9                   	leave  
801020a8:	c3                   	ret    

801020a9 <kinit2>:
{
801020a9:	55                   	push   %ebp
801020aa:	89 e5                	mov    %esp,%ebp
801020ac:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
801020af:	ff 75 0c             	push   0xc(%ebp)
801020b2:	ff 75 08             	push   0x8(%ebp)
801020b5:	e8 76 ff ff ff       	call   80102030 <freerange>
  kmem.use_lock = 1;
801020ba:	c7 05 74 16 11 80 01 	movl   $0x1,0x80111674
801020c1:	00 00 00 
}
801020c4:	83 c4 10             	add    $0x10,%esp
801020c7:	c9                   	leave  
801020c8:	c3                   	ret    

801020c9 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801020c9:	55                   	push   %ebp
801020ca:	89 e5                	mov    %esp,%ebp
801020cc:	53                   	push   %ebx
801020cd:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
801020d0:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
801020d7:	75 21                	jne    801020fa <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
801020d9:	8b 1d 78 16 11 80    	mov    0x80111678,%ebx
  if(r)
801020df:	85 db                	test   %ebx,%ebx
801020e1:	74 07                	je     801020ea <kalloc+0x21>
    kmem.freelist = r->next;
801020e3:	8b 03                	mov    (%ebx),%eax
801020e5:	a3 78 16 11 80       	mov    %eax,0x80111678
  if(kmem.use_lock)
801020ea:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
801020f1:	75 19                	jne    8010210c <kalloc+0x43>
    release(&kmem.lock);
  return (char*)r;
}
801020f3:	89 d8                	mov    %ebx,%eax
801020f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801020f8:	c9                   	leave  
801020f9:	c3                   	ret    
    acquire(&kmem.lock);
801020fa:	83 ec 0c             	sub    $0xc,%esp
801020fd:	68 40 16 11 80       	push   $0x80111640
80102102:	e8 68 22 00 00       	call   8010436f <acquire>
80102107:	83 c4 10             	add    $0x10,%esp
8010210a:	eb cd                	jmp    801020d9 <kalloc+0x10>
    release(&kmem.lock);
8010210c:	83 ec 0c             	sub    $0xc,%esp
8010210f:	68 40 16 11 80       	push   $0x80111640
80102114:	e8 bb 22 00 00       	call   801043d4 <release>
80102119:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010211c:	eb d5                	jmp    801020f3 <kalloc+0x2a>

8010211e <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010211e:	ba 64 00 00 00       	mov    $0x64,%edx
80102123:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102124:	a8 01                	test   $0x1,%al
80102126:	0f 84 b4 00 00 00    	je     801021e0 <kbdgetc+0xc2>
8010212c:	ba 60 00 00 00       	mov    $0x60,%edx
80102131:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102132:	0f b6 c8             	movzbl %al,%ecx

  if(data == 0xE0){
80102135:	3c e0                	cmp    $0xe0,%al
80102137:	74 61                	je     8010219a <kbdgetc+0x7c>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102139:	84 c0                	test   %al,%al
8010213b:	78 6a                	js     801021a7 <kbdgetc+0x89>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
8010213d:	8b 15 7c 16 11 80    	mov    0x8011167c,%edx
80102143:	f6 c2 40             	test   $0x40,%dl
80102146:	74 0f                	je     80102157 <kbdgetc+0x39>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102148:	83 c8 80             	or     $0xffffff80,%eax
8010214b:	0f b6 c8             	movzbl %al,%ecx
    shift &= ~E0ESC;
8010214e:	83 e2 bf             	and    $0xffffffbf,%edx
80102151:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  }

  shift |= shiftcode[data];
80102157:	0f b6 91 80 73 10 80 	movzbl -0x7fef8c80(%ecx),%edx
8010215e:	0b 15 7c 16 11 80    	or     0x8011167c,%edx
80102164:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  shift ^= togglecode[data];
8010216a:	0f b6 81 80 72 10 80 	movzbl -0x7fef8d80(%ecx),%eax
80102171:	31 c2                	xor    %eax,%edx
80102173:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  c = charcode[shift & (CTL | SHIFT)][data];
80102179:	89 d0                	mov    %edx,%eax
8010217b:	83 e0 03             	and    $0x3,%eax
8010217e:	8b 04 85 60 72 10 80 	mov    -0x7fef8da0(,%eax,4),%eax
80102185:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
80102189:	f6 c2 08             	test   $0x8,%dl
8010218c:	74 57                	je     801021e5 <kbdgetc+0xc7>
    if('a' <= c && c <= 'z')
8010218e:	8d 50 9f             	lea    -0x61(%eax),%edx
80102191:	83 fa 19             	cmp    $0x19,%edx
80102194:	77 3e                	ja     801021d4 <kbdgetc+0xb6>
      c += 'A' - 'a';
80102196:	83 e8 20             	sub    $0x20,%eax
80102199:	c3                   	ret    
    shift |= E0ESC;
8010219a:	83 0d 7c 16 11 80 40 	orl    $0x40,0x8011167c
    return 0;
801021a1:	b8 00 00 00 00       	mov    $0x0,%eax
801021a6:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801021a7:	8b 15 7c 16 11 80    	mov    0x8011167c,%edx
801021ad:	f6 c2 40             	test   $0x40,%dl
801021b0:	75 05                	jne    801021b7 <kbdgetc+0x99>
801021b2:	89 c1                	mov    %eax,%ecx
801021b4:	83 e1 7f             	and    $0x7f,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
801021b7:	0f b6 81 80 73 10 80 	movzbl -0x7fef8c80(%ecx),%eax
801021be:	83 c8 40             	or     $0x40,%eax
801021c1:	0f b6 c0             	movzbl %al,%eax
801021c4:	f7 d0                	not    %eax
801021c6:	21 c2                	and    %eax,%edx
801021c8:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
    return 0;
801021ce:	b8 00 00 00 00       	mov    $0x0,%eax
801021d3:	c3                   	ret    
    else if('A' <= c && c <= 'Z')
801021d4:	8d 50 bf             	lea    -0x41(%eax),%edx
801021d7:	83 fa 19             	cmp    $0x19,%edx
801021da:	77 09                	ja     801021e5 <kbdgetc+0xc7>
      c += 'a' - 'A';
801021dc:	83 c0 20             	add    $0x20,%eax
  }
  return c;
801021df:	c3                   	ret    
    return -1;
801021e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801021e5:	c3                   	ret    

801021e6 <kbdintr>:

void
kbdintr(void)
{
801021e6:	55                   	push   %ebp
801021e7:	89 e5                	mov    %esp,%ebp
801021e9:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801021ec:	68 1e 21 10 80       	push   $0x8010211e
801021f1:	e8 3d e5 ff ff       	call   80100733 <consoleintr>
}
801021f6:	83 c4 10             	add    $0x10,%esp
801021f9:	c9                   	leave  
801021fa:	c3                   	ret    

801021fb <shutdown>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801021fb:	b8 00 00 00 00       	mov    $0x0,%eax
80102200:	ba 01 05 00 00       	mov    $0x501,%edx
80102205:	ee                   	out    %al,(%dx)
  /*
     This only works in QEMU and assumes QEMU was run 
     with -device isa-debug-exit
   */
  outb(0x501, 0x0);
}
80102206:	c3                   	ret    

80102207 <lapicw>:

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102207:	8b 0d 80 16 11 80    	mov    0x80111680,%ecx
8010220d:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102210:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102212:	a1 80 16 11 80       	mov    0x80111680,%eax
80102217:	8b 40 20             	mov    0x20(%eax),%eax
}
8010221a:	c3                   	ret    

8010221b <cmos_read>:
8010221b:	ba 70 00 00 00       	mov    $0x70,%edx
80102220:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102221:	ba 71 00 00 00       	mov    $0x71,%edx
80102226:	ec                   	in     (%dx),%al
cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
80102227:	0f b6 c0             	movzbl %al,%eax
}
8010222a:	c3                   	ret    

8010222b <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010222b:	55                   	push   %ebp
8010222c:	89 e5                	mov    %esp,%ebp
8010222e:	53                   	push   %ebx
8010222f:	83 ec 04             	sub    $0x4,%esp
80102232:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
80102234:	b8 00 00 00 00       	mov    $0x0,%eax
80102239:	e8 dd ff ff ff       	call   8010221b <cmos_read>
8010223e:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
80102240:	b8 02 00 00 00       	mov    $0x2,%eax
80102245:	e8 d1 ff ff ff       	call   8010221b <cmos_read>
8010224a:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
8010224d:	b8 04 00 00 00       	mov    $0x4,%eax
80102252:	e8 c4 ff ff ff       	call   8010221b <cmos_read>
80102257:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
8010225a:	b8 07 00 00 00       	mov    $0x7,%eax
8010225f:	e8 b7 ff ff ff       	call   8010221b <cmos_read>
80102264:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
80102267:	b8 08 00 00 00       	mov    $0x8,%eax
8010226c:	e8 aa ff ff ff       	call   8010221b <cmos_read>
80102271:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102274:	b8 09 00 00 00       	mov    $0x9,%eax
80102279:	e8 9d ff ff ff       	call   8010221b <cmos_read>
8010227e:	89 43 14             	mov    %eax,0x14(%ebx)
}
80102281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <lapicinit>:
  if(!lapic)
80102286:	83 3d 80 16 11 80 00 	cmpl   $0x0,0x80111680
8010228d:	0f 84 fe 00 00 00    	je     80102391 <lapicinit+0x10b>
{
80102293:	55                   	push   %ebp
80102294:	89 e5                	mov    %esp,%ebp
80102296:	83 ec 08             	sub    $0x8,%esp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102299:	ba 3f 01 00 00       	mov    $0x13f,%edx
8010229e:	b8 3c 00 00 00       	mov    $0x3c,%eax
801022a3:	e8 5f ff ff ff       	call   80102207 <lapicw>
  lapicw(TDCR, X1);
801022a8:	ba 0b 00 00 00       	mov    $0xb,%edx
801022ad:	b8 f8 00 00 00       	mov    $0xf8,%eax
801022b2:	e8 50 ff ff ff       	call   80102207 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801022b7:	ba 20 00 02 00       	mov    $0x20020,%edx
801022bc:	b8 c8 00 00 00       	mov    $0xc8,%eax
801022c1:	e8 41 ff ff ff       	call   80102207 <lapicw>
  lapicw(TICR, 10000000);
801022c6:	ba 80 96 98 00       	mov    $0x989680,%edx
801022cb:	b8 e0 00 00 00       	mov    $0xe0,%eax
801022d0:	e8 32 ff ff ff       	call   80102207 <lapicw>
  lapicw(LINT0, MASKED);
801022d5:	ba 00 00 01 00       	mov    $0x10000,%edx
801022da:	b8 d4 00 00 00       	mov    $0xd4,%eax
801022df:	e8 23 ff ff ff       	call   80102207 <lapicw>
  lapicw(LINT1, MASKED);
801022e4:	ba 00 00 01 00       	mov    $0x10000,%edx
801022e9:	b8 d8 00 00 00       	mov    $0xd8,%eax
801022ee:	e8 14 ff ff ff       	call   80102207 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801022f3:	a1 80 16 11 80       	mov    0x80111680,%eax
801022f8:	8b 40 30             	mov    0x30(%eax),%eax
801022fb:	c1 e8 10             	shr    $0x10,%eax
801022fe:	a8 fc                	test   $0xfc,%al
80102300:	75 7b                	jne    8010237d <lapicinit+0xf7>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102302:	ba 33 00 00 00       	mov    $0x33,%edx
80102307:	b8 dc 00 00 00       	mov    $0xdc,%eax
8010230c:	e8 f6 fe ff ff       	call   80102207 <lapicw>
  lapicw(ESR, 0);
80102311:	ba 00 00 00 00       	mov    $0x0,%edx
80102316:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010231b:	e8 e7 fe ff ff       	call   80102207 <lapicw>
  lapicw(ESR, 0);
80102320:	ba 00 00 00 00       	mov    $0x0,%edx
80102325:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010232a:	e8 d8 fe ff ff       	call   80102207 <lapicw>
  lapicw(EOI, 0);
8010232f:	ba 00 00 00 00       	mov    $0x0,%edx
80102334:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102339:	e8 c9 fe ff ff       	call   80102207 <lapicw>
  lapicw(ICRHI, 0);
8010233e:	ba 00 00 00 00       	mov    $0x0,%edx
80102343:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102348:	e8 ba fe ff ff       	call   80102207 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010234d:	ba 00 85 08 00       	mov    $0x88500,%edx
80102352:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102357:	e8 ab fe ff ff       	call   80102207 <lapicw>
  while(lapic[ICRLO] & DELIVS)
8010235c:	a1 80 16 11 80       	mov    0x80111680,%eax
80102361:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102367:	f6 c4 10             	test   $0x10,%ah
8010236a:	75 f0                	jne    8010235c <lapicinit+0xd6>
  lapicw(TPR, 0);
8010236c:	ba 00 00 00 00       	mov    $0x0,%edx
80102371:	b8 20 00 00 00       	mov    $0x20,%eax
80102376:	e8 8c fe ff ff       	call   80102207 <lapicw>
}
8010237b:	c9                   	leave  
8010237c:	c3                   	ret    
    lapicw(PCINT, MASKED);
8010237d:	ba 00 00 01 00       	mov    $0x10000,%edx
80102382:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102387:	e8 7b fe ff ff       	call   80102207 <lapicw>
8010238c:	e9 71 ff ff ff       	jmp    80102302 <lapicinit+0x7c>
80102391:	c3                   	ret    

80102392 <lapicid>:
  if (!lapic)
80102392:	a1 80 16 11 80       	mov    0x80111680,%eax
80102397:	85 c0                	test   %eax,%eax
80102399:	74 07                	je     801023a2 <lapicid+0x10>
  return lapic[ID] >> 24;
8010239b:	8b 40 20             	mov    0x20(%eax),%eax
8010239e:	c1 e8 18             	shr    $0x18,%eax
801023a1:	c3                   	ret    
    return 0;
801023a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023a7:	c3                   	ret    

801023a8 <lapiceoi>:
  if(lapic)
801023a8:	83 3d 80 16 11 80 00 	cmpl   $0x0,0x80111680
801023af:	74 17                	je     801023c8 <lapiceoi+0x20>
{
801023b1:	55                   	push   %ebp
801023b2:	89 e5                	mov    %esp,%ebp
801023b4:	83 ec 08             	sub    $0x8,%esp
    lapicw(EOI, 0);
801023b7:	ba 00 00 00 00       	mov    $0x0,%edx
801023bc:	b8 2c 00 00 00       	mov    $0x2c,%eax
801023c1:	e8 41 fe ff ff       	call   80102207 <lapicw>
}
801023c6:	c9                   	leave  
801023c7:	c3                   	ret    
801023c8:	c3                   	ret    

801023c9 <microdelay>:
}
801023c9:	c3                   	ret    

801023ca <lapicstartap>:
{
801023ca:	55                   	push   %ebp
801023cb:	89 e5                	mov    %esp,%ebp
801023cd:	57                   	push   %edi
801023ce:	56                   	push   %esi
801023cf:	53                   	push   %ebx
801023d0:	83 ec 0c             	sub    $0xc,%esp
801023d3:	8b 75 08             	mov    0x8(%ebp),%esi
801023d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801023d9:	b8 0f 00 00 00       	mov    $0xf,%eax
801023de:	ba 70 00 00 00       	mov    $0x70,%edx
801023e3:	ee                   	out    %al,(%dx)
801023e4:	b8 0a 00 00 00       	mov    $0xa,%eax
801023e9:	ba 71 00 00 00       	mov    $0x71,%edx
801023ee:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
801023ef:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
801023f6:	00 00 
  wrv[1] = addr >> 4;
801023f8:	89 f8                	mov    %edi,%eax
801023fa:	c1 e8 04             	shr    $0x4,%eax
801023fd:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102403:	c1 e6 18             	shl    $0x18,%esi
80102406:	89 f2                	mov    %esi,%edx
80102408:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010240d:	e8 f5 fd ff ff       	call   80102207 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102412:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102417:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010241c:	e8 e6 fd ff ff       	call   80102207 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102421:	ba 00 85 00 00       	mov    $0x8500,%edx
80102426:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010242b:	e8 d7 fd ff ff       	call   80102207 <lapicw>
  for(i = 0; i < 2; i++){
80102430:	bb 00 00 00 00       	mov    $0x0,%ebx
80102435:	eb 21                	jmp    80102458 <lapicstartap+0x8e>
    lapicw(ICRHI, apicid<<24);
80102437:	89 f2                	mov    %esi,%edx
80102439:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010243e:	e8 c4 fd ff ff       	call   80102207 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102443:	89 fa                	mov    %edi,%edx
80102445:	c1 ea 0c             	shr    $0xc,%edx
80102448:	80 ce 06             	or     $0x6,%dh
8010244b:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102450:	e8 b2 fd ff ff       	call   80102207 <lapicw>
  for(i = 0; i < 2; i++){
80102455:	83 c3 01             	add    $0x1,%ebx
80102458:	83 fb 01             	cmp    $0x1,%ebx
8010245b:	7e da                	jle    80102437 <lapicstartap+0x6d>
}
8010245d:	83 c4 0c             	add    $0xc,%esp
80102460:	5b                   	pop    %ebx
80102461:	5e                   	pop    %esi
80102462:	5f                   	pop    %edi
80102463:	5d                   	pop    %ebp
80102464:	c3                   	ret    

80102465 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102465:	55                   	push   %ebp
80102466:	89 e5                	mov    %esp,%ebp
80102468:	57                   	push   %edi
80102469:	56                   	push   %esi
8010246a:	53                   	push   %ebx
8010246b:	83 ec 3c             	sub    $0x3c,%esp
8010246e:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102471:	b8 0b 00 00 00       	mov    $0xb,%eax
80102476:	e8 a0 fd ff ff       	call   8010221b <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
8010247b:	83 e0 04             	and    $0x4,%eax
8010247e:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102480:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102483:	e8 a3 fd ff ff       	call   8010222b <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102488:	b8 0a 00 00 00       	mov    $0xa,%eax
8010248d:	e8 89 fd ff ff       	call   8010221b <cmos_read>
80102492:	a8 80                	test   $0x80,%al
80102494:	75 ea                	jne    80102480 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
80102496:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102499:	89 d8                	mov    %ebx,%eax
8010249b:	e8 8b fd ff ff       	call   8010222b <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801024a0:	83 ec 04             	sub    $0x4,%esp
801024a3:	6a 18                	push   $0x18
801024a5:	53                   	push   %ebx
801024a6:	8d 45 d0             	lea    -0x30(%ebp),%eax
801024a9:	50                   	push   %eax
801024aa:	e8 af 1f 00 00       	call   8010445e <memcmp>
801024af:	83 c4 10             	add    $0x10,%esp
801024b2:	85 c0                	test   %eax,%eax
801024b4:	75 ca                	jne    80102480 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
801024b6:	85 ff                	test   %edi,%edi
801024b8:	75 78                	jne    80102532 <cmostime+0xcd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801024ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
801024bd:	89 c2                	mov    %eax,%edx
801024bf:	c1 ea 04             	shr    $0x4,%edx
801024c2:	8d 14 92             	lea    (%edx,%edx,4),%edx
801024c5:	83 e0 0f             	and    $0xf,%eax
801024c8:	8d 04 50             	lea    (%eax,%edx,2),%eax
801024cb:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
801024ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801024d1:	89 c2                	mov    %eax,%edx
801024d3:	c1 ea 04             	shr    $0x4,%edx
801024d6:	8d 14 92             	lea    (%edx,%edx,4),%edx
801024d9:	83 e0 0f             	and    $0xf,%eax
801024dc:	8d 04 50             	lea    (%eax,%edx,2),%eax
801024df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
801024e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801024e5:	89 c2                	mov    %eax,%edx
801024e7:	c1 ea 04             	shr    $0x4,%edx
801024ea:	8d 14 92             	lea    (%edx,%edx,4),%edx
801024ed:	83 e0 0f             	and    $0xf,%eax
801024f0:	8d 04 50             	lea    (%eax,%edx,2),%eax
801024f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
801024f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801024f9:	89 c2                	mov    %eax,%edx
801024fb:	c1 ea 04             	shr    $0x4,%edx
801024fe:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102501:	83 e0 0f             	and    $0xf,%eax
80102504:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102507:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
8010250a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010250d:	89 c2                	mov    %eax,%edx
8010250f:	c1 ea 04             	shr    $0x4,%edx
80102512:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102515:	83 e0 0f             	and    $0xf,%eax
80102518:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010251b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
8010251e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102521:	89 c2                	mov    %eax,%edx
80102523:	c1 ea 04             	shr    $0x4,%edx
80102526:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102529:	83 e0 0f             	and    $0xf,%eax
8010252c:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010252f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102532:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102535:	89 06                	mov    %eax,(%esi)
80102537:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010253a:	89 46 04             	mov    %eax,0x4(%esi)
8010253d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102540:	89 46 08             	mov    %eax,0x8(%esi)
80102543:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102546:	89 46 0c             	mov    %eax,0xc(%esi)
80102549:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010254c:	89 46 10             	mov    %eax,0x10(%esi)
8010254f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102552:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102555:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
8010255c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010255f:	5b                   	pop    %ebx
80102560:	5e                   	pop    %esi
80102561:	5f                   	pop    %edi
80102562:	5d                   	pop    %ebp
80102563:	c3                   	ret    

80102564 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102564:	55                   	push   %ebp
80102565:	89 e5                	mov    %esp,%ebp
80102567:	53                   	push   %ebx
80102568:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010256b:	ff 35 d4 16 11 80    	push   0x801116d4
80102571:	ff 35 e4 16 11 80    	push   0x801116e4
80102577:	e8 f0 db ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
8010257c:	8b 58 5c             	mov    0x5c(%eax),%ebx
8010257f:	89 1d e8 16 11 80    	mov    %ebx,0x801116e8
  for (i = 0; i < log.lh.n; i++) {
80102585:	83 c4 10             	add    $0x10,%esp
80102588:	ba 00 00 00 00       	mov    $0x0,%edx
8010258d:	eb 0e                	jmp    8010259d <read_head+0x39>
    log.lh.block[i] = lh->block[i];
8010258f:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102593:	89 0c 95 ec 16 11 80 	mov    %ecx,-0x7feee914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010259a:	83 c2 01             	add    $0x1,%edx
8010259d:	39 d3                	cmp    %edx,%ebx
8010259f:	7f ee                	jg     8010258f <read_head+0x2b>
  }
  brelse(buf);
801025a1:	83 ec 0c             	sub    $0xc,%esp
801025a4:	50                   	push   %eax
801025a5:	e8 2b dc ff ff       	call   801001d5 <brelse>
}
801025aa:	83 c4 10             	add    $0x10,%esp
801025ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025b0:	c9                   	leave  
801025b1:	c3                   	ret    

801025b2 <install_trans>:
{
801025b2:	55                   	push   %ebp
801025b3:	89 e5                	mov    %esp,%ebp
801025b5:	57                   	push   %edi
801025b6:	56                   	push   %esi
801025b7:	53                   	push   %ebx
801025b8:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801025bb:	be 00 00 00 00       	mov    $0x0,%esi
801025c0:	eb 66                	jmp    80102628 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801025c2:	89 f0                	mov    %esi,%eax
801025c4:	03 05 d4 16 11 80    	add    0x801116d4,%eax
801025ca:	83 c0 01             	add    $0x1,%eax
801025cd:	83 ec 08             	sub    $0x8,%esp
801025d0:	50                   	push   %eax
801025d1:	ff 35 e4 16 11 80    	push   0x801116e4
801025d7:	e8 90 db ff ff       	call   8010016c <bread>
801025dc:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801025de:	83 c4 08             	add    $0x8,%esp
801025e1:	ff 34 b5 ec 16 11 80 	push   -0x7feee914(,%esi,4)
801025e8:	ff 35 e4 16 11 80    	push   0x801116e4
801025ee:	e8 79 db ff ff       	call   8010016c <bread>
801025f3:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801025f5:	8d 57 5c             	lea    0x5c(%edi),%edx
801025f8:	8d 40 5c             	lea    0x5c(%eax),%eax
801025fb:	83 c4 0c             	add    $0xc,%esp
801025fe:	68 00 02 00 00       	push   $0x200
80102603:	52                   	push   %edx
80102604:	50                   	push   %eax
80102605:	e8 89 1e 00 00       	call   80104493 <memmove>
    bwrite(dbuf);  // write dst to disk
8010260a:	89 1c 24             	mov    %ebx,(%esp)
8010260d:	e8 88 db ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
80102612:	89 3c 24             	mov    %edi,(%esp)
80102615:	e8 bb db ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
8010261a:	89 1c 24             	mov    %ebx,(%esp)
8010261d:	e8 b3 db ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102622:	83 c6 01             	add    $0x1,%esi
80102625:	83 c4 10             	add    $0x10,%esp
80102628:	39 35 e8 16 11 80    	cmp    %esi,0x801116e8
8010262e:	7f 92                	jg     801025c2 <install_trans+0x10>
}
80102630:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102633:	5b                   	pop    %ebx
80102634:	5e                   	pop    %esi
80102635:	5f                   	pop    %edi
80102636:	5d                   	pop    %ebp
80102637:	c3                   	ret    

80102638 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102638:	55                   	push   %ebp
80102639:	89 e5                	mov    %esp,%ebp
8010263b:	53                   	push   %ebx
8010263c:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010263f:	ff 35 d4 16 11 80    	push   0x801116d4
80102645:	ff 35 e4 16 11 80    	push   0x801116e4
8010264b:	e8 1c db ff ff       	call   8010016c <bread>
80102650:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102652:	8b 0d e8 16 11 80    	mov    0x801116e8,%ecx
80102658:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010265b:	83 c4 10             	add    $0x10,%esp
8010265e:	b8 00 00 00 00       	mov    $0x0,%eax
80102663:	eb 0e                	jmp    80102673 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
80102665:	8b 14 85 ec 16 11 80 	mov    -0x7feee914(,%eax,4),%edx
8010266c:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
80102670:	83 c0 01             	add    $0x1,%eax
80102673:	39 c1                	cmp    %eax,%ecx
80102675:	7f ee                	jg     80102665 <write_head+0x2d>
  }
  bwrite(buf);
80102677:	83 ec 0c             	sub    $0xc,%esp
8010267a:	53                   	push   %ebx
8010267b:	e8 1a db ff ff       	call   8010019a <bwrite>
  brelse(buf);
80102680:	89 1c 24             	mov    %ebx,(%esp)
80102683:	e8 4d db ff ff       	call   801001d5 <brelse>
}
80102688:	83 c4 10             	add    $0x10,%esp
8010268b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010268e:	c9                   	leave  
8010268f:	c3                   	ret    

80102690 <recover_from_log>:

static void
recover_from_log(void)
{
80102690:	55                   	push   %ebp
80102691:	89 e5                	mov    %esp,%ebp
80102693:	83 ec 08             	sub    $0x8,%esp
  read_head();
80102696:	e8 c9 fe ff ff       	call   80102564 <read_head>
  install_trans(); // if committed, copy from log to disk
8010269b:	e8 12 ff ff ff       	call   801025b2 <install_trans>
  log.lh.n = 0;
801026a0:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
801026a7:	00 00 00 
  write_head(); // clear the log
801026aa:	e8 89 ff ff ff       	call   80102638 <write_head>
}
801026af:	c9                   	leave  
801026b0:	c3                   	ret    

801026b1 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801026b1:	55                   	push   %ebp
801026b2:	89 e5                	mov    %esp,%ebp
801026b4:	57                   	push   %edi
801026b5:	56                   	push   %esi
801026b6:	53                   	push   %ebx
801026b7:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801026ba:	be 00 00 00 00       	mov    $0x0,%esi
801026bf:	eb 66                	jmp    80102727 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801026c1:	89 f0                	mov    %esi,%eax
801026c3:	03 05 d4 16 11 80    	add    0x801116d4,%eax
801026c9:	83 c0 01             	add    $0x1,%eax
801026cc:	83 ec 08             	sub    $0x8,%esp
801026cf:	50                   	push   %eax
801026d0:	ff 35 e4 16 11 80    	push   0x801116e4
801026d6:	e8 91 da ff ff       	call   8010016c <bread>
801026db:	89 c3                	mov    %eax,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801026dd:	83 c4 08             	add    $0x8,%esp
801026e0:	ff 34 b5 ec 16 11 80 	push   -0x7feee914(,%esi,4)
801026e7:	ff 35 e4 16 11 80    	push   0x801116e4
801026ed:	e8 7a da ff ff       	call   8010016c <bread>
801026f2:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
801026f4:	8d 50 5c             	lea    0x5c(%eax),%edx
801026f7:	8d 43 5c             	lea    0x5c(%ebx),%eax
801026fa:	83 c4 0c             	add    $0xc,%esp
801026fd:	68 00 02 00 00       	push   $0x200
80102702:	52                   	push   %edx
80102703:	50                   	push   %eax
80102704:	e8 8a 1d 00 00       	call   80104493 <memmove>
    bwrite(to);  // write the log
80102709:	89 1c 24             	mov    %ebx,(%esp)
8010270c:	e8 89 da ff ff       	call   8010019a <bwrite>
    brelse(from);
80102711:	89 3c 24             	mov    %edi,(%esp)
80102714:	e8 bc da ff ff       	call   801001d5 <brelse>
    brelse(to);
80102719:	89 1c 24             	mov    %ebx,(%esp)
8010271c:	e8 b4 da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102721:	83 c6 01             	add    $0x1,%esi
80102724:	83 c4 10             	add    $0x10,%esp
80102727:	39 35 e8 16 11 80    	cmp    %esi,0x801116e8
8010272d:	7f 92                	jg     801026c1 <write_log+0x10>
  }
}
8010272f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102732:	5b                   	pop    %ebx
80102733:	5e                   	pop    %esi
80102734:	5f                   	pop    %edi
80102735:	5d                   	pop    %ebp
80102736:	c3                   	ret    

80102737 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102737:	83 3d e8 16 11 80 00 	cmpl   $0x0,0x801116e8
8010273e:	7f 01                	jg     80102741 <commit+0xa>
80102740:	c3                   	ret    
{
80102741:	55                   	push   %ebp
80102742:	89 e5                	mov    %esp,%ebp
80102744:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102747:	e8 65 ff ff ff       	call   801026b1 <write_log>
    write_head();    // Write header to disk -- the real commit
8010274c:	e8 e7 fe ff ff       	call   80102638 <write_head>
    install_trans(); // Now install writes to home locations
80102751:	e8 5c fe ff ff       	call   801025b2 <install_trans>
    log.lh.n = 0;
80102756:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
8010275d:	00 00 00 
    write_head();    // Erase the transaction from the log
80102760:	e8 d3 fe ff ff       	call   80102638 <write_head>
  }
}
80102765:	c9                   	leave  
80102766:	c3                   	ret    

80102767 <initlog>:
{
80102767:	55                   	push   %ebp
80102768:	89 e5                	mov    %esp,%ebp
8010276a:	53                   	push   %ebx
8010276b:	83 ec 2c             	sub    $0x2c,%esp
8010276e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102771:	68 80 74 10 80       	push   $0x80107480
80102776:	68 a0 16 11 80       	push   $0x801116a0
8010277b:	e8 b3 1a 00 00       	call   80104233 <initlock>
  readsb(dev, &sb);
80102780:	83 c4 08             	add    $0x8,%esp
80102783:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102786:	50                   	push   %eax
80102787:	53                   	push   %ebx
80102788:	e8 19 eb ff ff       	call   801012a6 <readsb>
  log.start = sb.logstart;
8010278d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102790:	a3 d4 16 11 80       	mov    %eax,0x801116d4
  log.size = sb.nlog;
80102795:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102798:	a3 d8 16 11 80       	mov    %eax,0x801116d8
  log.dev = dev;
8010279d:	89 1d e4 16 11 80    	mov    %ebx,0x801116e4
  recover_from_log();
801027a3:	e8 e8 fe ff ff       	call   80102690 <recover_from_log>
}
801027a8:	83 c4 10             	add    $0x10,%esp
801027ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027ae:	c9                   	leave  
801027af:	c3                   	ret    

801027b0 <begin_op>:
{
801027b0:	55                   	push   %ebp
801027b1:	89 e5                	mov    %esp,%ebp
801027b3:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801027b6:	68 a0 16 11 80       	push   $0x801116a0
801027bb:	e8 af 1b 00 00       	call   8010436f <acquire>
801027c0:	83 c4 10             	add    $0x10,%esp
801027c3:	eb 15                	jmp    801027da <begin_op+0x2a>
      sleep(&log, &log.lock);
801027c5:	83 ec 08             	sub    $0x8,%esp
801027c8:	68 a0 16 11 80       	push   $0x801116a0
801027cd:	68 a0 16 11 80       	push   $0x801116a0
801027d2:	e8 95 16 00 00       	call   80103e6c <sleep>
801027d7:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
801027da:	83 3d e0 16 11 80 00 	cmpl   $0x0,0x801116e0
801027e1:	75 e2                	jne    801027c5 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801027e3:	a1 dc 16 11 80       	mov    0x801116dc,%eax
801027e8:	83 c0 01             	add    $0x1,%eax
801027eb:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801027ee:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
801027f1:	03 15 e8 16 11 80    	add    0x801116e8,%edx
801027f7:	83 fa 1e             	cmp    $0x1e,%edx
801027fa:	7e 17                	jle    80102813 <begin_op+0x63>
      sleep(&log, &log.lock);
801027fc:	83 ec 08             	sub    $0x8,%esp
801027ff:	68 a0 16 11 80       	push   $0x801116a0
80102804:	68 a0 16 11 80       	push   $0x801116a0
80102809:	e8 5e 16 00 00       	call   80103e6c <sleep>
8010280e:	83 c4 10             	add    $0x10,%esp
80102811:	eb c7                	jmp    801027da <begin_op+0x2a>
      log.outstanding += 1;
80102813:	a3 dc 16 11 80       	mov    %eax,0x801116dc
      release(&log.lock);
80102818:	83 ec 0c             	sub    $0xc,%esp
8010281b:	68 a0 16 11 80       	push   $0x801116a0
80102820:	e8 af 1b 00 00       	call   801043d4 <release>
}
80102825:	83 c4 10             	add    $0x10,%esp
80102828:	c9                   	leave  
80102829:	c3                   	ret    

8010282a <end_op>:
{
8010282a:	55                   	push   %ebp
8010282b:	89 e5                	mov    %esp,%ebp
8010282d:	53                   	push   %ebx
8010282e:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102831:	68 a0 16 11 80       	push   $0x801116a0
80102836:	e8 34 1b 00 00       	call   8010436f <acquire>
  log.outstanding -= 1;
8010283b:	a1 dc 16 11 80       	mov    0x801116dc,%eax
80102840:	83 e8 01             	sub    $0x1,%eax
80102843:	a3 dc 16 11 80       	mov    %eax,0x801116dc
  if(log.committing)
80102848:	8b 1d e0 16 11 80    	mov    0x801116e0,%ebx
8010284e:	83 c4 10             	add    $0x10,%esp
80102851:	85 db                	test   %ebx,%ebx
80102853:	75 2c                	jne    80102881 <end_op+0x57>
  if(log.outstanding == 0){
80102855:	85 c0                	test   %eax,%eax
80102857:	75 35                	jne    8010288e <end_op+0x64>
    log.committing = 1;
80102859:	c7 05 e0 16 11 80 01 	movl   $0x1,0x801116e0
80102860:	00 00 00 
    do_commit = 1;
80102863:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102868:	83 ec 0c             	sub    $0xc,%esp
8010286b:	68 a0 16 11 80       	push   $0x801116a0
80102870:	e8 5f 1b 00 00       	call   801043d4 <release>
  if(do_commit){
80102875:	83 c4 10             	add    $0x10,%esp
80102878:	85 db                	test   %ebx,%ebx
8010287a:	75 24                	jne    801028a0 <end_op+0x76>
}
8010287c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010287f:	c9                   	leave  
80102880:	c3                   	ret    
    panic("log.committing");
80102881:	83 ec 0c             	sub    $0xc,%esp
80102884:	68 84 74 10 80       	push   $0x80107484
80102889:	e8 ba da ff ff       	call   80100348 <panic>
    wakeup(&log);
8010288e:	83 ec 0c             	sub    $0xc,%esp
80102891:	68 a0 16 11 80       	push   $0x801116a0
80102896:	e8 39 17 00 00       	call   80103fd4 <wakeup>
8010289b:	83 c4 10             	add    $0x10,%esp
8010289e:	eb c8                	jmp    80102868 <end_op+0x3e>
    commit();
801028a0:	e8 92 fe ff ff       	call   80102737 <commit>
    acquire(&log.lock);
801028a5:	83 ec 0c             	sub    $0xc,%esp
801028a8:	68 a0 16 11 80       	push   $0x801116a0
801028ad:	e8 bd 1a 00 00       	call   8010436f <acquire>
    log.committing = 0;
801028b2:	c7 05 e0 16 11 80 00 	movl   $0x0,0x801116e0
801028b9:	00 00 00 
    wakeup(&log);
801028bc:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
801028c3:	e8 0c 17 00 00       	call   80103fd4 <wakeup>
    release(&log.lock);
801028c8:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
801028cf:	e8 00 1b 00 00       	call   801043d4 <release>
801028d4:	83 c4 10             	add    $0x10,%esp
}
801028d7:	eb a3                	jmp    8010287c <end_op+0x52>

801028d9 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801028d9:	55                   	push   %ebp
801028da:	89 e5                	mov    %esp,%ebp
801028dc:	53                   	push   %ebx
801028dd:	83 ec 04             	sub    $0x4,%esp
801028e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801028e3:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
801028e9:	83 fa 1d             	cmp    $0x1d,%edx
801028ec:	7f 2c                	jg     8010291a <log_write+0x41>
801028ee:	a1 d8 16 11 80       	mov    0x801116d8,%eax
801028f3:	83 e8 01             	sub    $0x1,%eax
801028f6:	39 c2                	cmp    %eax,%edx
801028f8:	7d 20                	jge    8010291a <log_write+0x41>
    panic("too big a transaction");
  if (log.outstanding < 1)
801028fa:	83 3d dc 16 11 80 00 	cmpl   $0x0,0x801116dc
80102901:	7e 24                	jle    80102927 <log_write+0x4e>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102903:	83 ec 0c             	sub    $0xc,%esp
80102906:	68 a0 16 11 80       	push   $0x801116a0
8010290b:	e8 5f 1a 00 00       	call   8010436f <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102910:	83 c4 10             	add    $0x10,%esp
80102913:	b8 00 00 00 00       	mov    $0x0,%eax
80102918:	eb 1d                	jmp    80102937 <log_write+0x5e>
    panic("too big a transaction");
8010291a:	83 ec 0c             	sub    $0xc,%esp
8010291d:	68 93 74 10 80       	push   $0x80107493
80102922:	e8 21 da ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102927:	83 ec 0c             	sub    $0xc,%esp
8010292a:	68 a9 74 10 80       	push   $0x801074a9
8010292f:	e8 14 da ff ff       	call   80100348 <panic>
  for (i = 0; i < log.lh.n; i++) {
80102934:	83 c0 01             	add    $0x1,%eax
80102937:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
8010293d:	39 c2                	cmp    %eax,%edx
8010293f:	7e 0c                	jle    8010294d <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102941:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102944:	39 0c 85 ec 16 11 80 	cmp    %ecx,-0x7feee914(,%eax,4)
8010294b:	75 e7                	jne    80102934 <log_write+0x5b>
      break;
  }
  log.lh.block[i] = b->blockno;
8010294d:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102950:	89 0c 85 ec 16 11 80 	mov    %ecx,-0x7feee914(,%eax,4)
  if (i == log.lh.n)
80102957:	39 c2                	cmp    %eax,%edx
80102959:	74 18                	je     80102973 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
8010295b:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
8010295e:	83 ec 0c             	sub    $0xc,%esp
80102961:	68 a0 16 11 80       	push   $0x801116a0
80102966:	e8 69 1a 00 00       	call   801043d4 <release>
}
8010296b:	83 c4 10             	add    $0x10,%esp
8010296e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102971:	c9                   	leave  
80102972:	c3                   	ret    
    log.lh.n++;
80102973:	83 c2 01             	add    $0x1,%edx
80102976:	89 15 e8 16 11 80    	mov    %edx,0x801116e8
8010297c:	eb dd                	jmp    8010295b <log_write+0x82>

8010297e <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010297e:	55                   	push   %ebp
8010297f:	89 e5                	mov    %esp,%ebp
80102981:	53                   	push   %ebx
80102982:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102985:	68 8a 00 00 00       	push   $0x8a
8010298a:	68 8c a4 10 80       	push   $0x8010a48c
8010298f:	68 00 70 00 80       	push   $0x80007000
80102994:	e8 fa 1a 00 00       	call   80104493 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102999:	83 c4 10             	add    $0x10,%esp
8010299c:	bb a0 17 11 80       	mov    $0x801117a0,%ebx
801029a1:	eb 13                	jmp    801029b6 <startothers+0x38>
801029a3:	83 ec 0c             	sub    $0xc,%esp
801029a6:	68 a8 71 10 80       	push   $0x801071a8
801029ab:	e8 98 d9 ff ff       	call   80100348 <panic>
801029b0:	81 c3 b4 00 00 00    	add    $0xb4,%ebx
801029b6:	69 05 84 17 11 80 b4 	imul   $0xb4,0x80111784,%eax
801029bd:	00 00 00 
801029c0:	05 a0 17 11 80       	add    $0x801117a0,%eax
801029c5:	39 d8                	cmp    %ebx,%eax
801029c7:	76 58                	jbe    80102a21 <startothers+0xa3>
    if(c == mycpu())  // We've started already.
801029c9:	e8 25 0a 00 00       	call   801033f3 <mycpu>
801029ce:	39 c3                	cmp    %eax,%ebx
801029d0:	74 de                	je     801029b0 <startothers+0x32>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801029d2:	e8 f2 f6 ff ff       	call   801020c9 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
801029d7:	05 00 10 00 00       	add    $0x1000,%eax
801029dc:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
801029e1:	c7 05 f8 6f 00 80 65 	movl   $0x80102a65,0x80006ff8
801029e8:	2a 10 80 
    if (a < (void*) KERNBASE)
801029eb:	b8 00 90 10 80       	mov    $0x80109000,%eax
801029f0:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
801029f5:	76 ac                	jbe    801029a3 <startothers+0x25>
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801029f7:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
801029fe:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102a01:	83 ec 08             	sub    $0x8,%esp
80102a04:	68 00 70 00 00       	push   $0x7000
80102a09:	0f b6 03             	movzbl (%ebx),%eax
80102a0c:	50                   	push   %eax
80102a0d:	e8 b8 f9 ff ff       	call   801023ca <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102a12:	83 c4 10             	add    $0x10,%esp
80102a15:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102a1b:	85 c0                	test   %eax,%eax
80102a1d:	74 f6                	je     80102a15 <startothers+0x97>
80102a1f:	eb 8f                	jmp    801029b0 <startothers+0x32>
      ;
  }
}
80102a21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a24:	c9                   	leave  
80102a25:	c3                   	ret    

80102a26 <mpmain>:
{
80102a26:	55                   	push   %ebp
80102a27:	89 e5                	mov    %esp,%ebp
80102a29:	53                   	push   %ebx
80102a2a:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102a2d:	e8 1d 0a 00 00       	call   8010344f <cpuid>
80102a32:	89 c3                	mov    %eax,%ebx
80102a34:	e8 16 0a 00 00       	call   8010344f <cpuid>
80102a39:	83 ec 04             	sub    $0x4,%esp
80102a3c:	53                   	push   %ebx
80102a3d:	50                   	push   %eax
80102a3e:	68 c4 74 10 80       	push   $0x801074c4
80102a43:	e8 bf db ff ff       	call   80100607 <cprintf>
  idtinit();       // load idt register
80102a48:	e8 c2 2b 00 00       	call   8010560f <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102a4d:	e8 a1 09 00 00       	call   801033f3 <mycpu>
80102a52:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102a54:	b8 01 00 00 00       	mov    $0x1,%eax
80102a59:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102a60:	e8 8f 0f 00 00       	call   801039f4 <scheduler>

80102a65 <mpenter>:
{
80102a65:	55                   	push   %ebp
80102a66:	89 e5                	mov    %esp,%ebp
80102a68:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a6b:	e8 44 3d 00 00       	call   801067b4 <switchkvm>
  seginit();
80102a70:	e8 ca 3a 00 00       	call   8010653f <seginit>
  lapicinit();
80102a75:	e8 0c f8 ff ff       	call   80102286 <lapicinit>
  mpmain();
80102a7a:	e8 a7 ff ff ff       	call   80102a26 <mpmain>

80102a7f <main>:
{
80102a7f:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102a83:	83 e4 f0             	and    $0xfffffff0,%esp
80102a86:	ff 71 fc             	push   -0x4(%ecx)
80102a89:	55                   	push   %ebp
80102a8a:	89 e5                	mov    %esp,%ebp
80102a8c:	51                   	push   %ecx
80102a8d:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102a90:	68 00 00 40 80       	push   $0x80400000
80102a95:	68 90 5e 11 80       	push   $0x80115e90
80102a9a:	e8 d8 f5 ff ff       	call   80102077 <kinit1>
  kvmalloc();      // kernel page table
80102a9f:	e8 71 42 00 00       	call   80106d15 <kvmalloc>
  mpinit();        // detect other processors
80102aa4:	e8 db 01 00 00       	call   80102c84 <mpinit>
  lapicinit();     // interrupt controller
80102aa9:	e8 d8 f7 ff ff       	call   80102286 <lapicinit>
  seginit();       // segment descriptors
80102aae:	e8 8c 3a 00 00       	call   8010653f <seginit>
  picinit();       // disable pic
80102ab3:	e8 a2 02 00 00       	call   80102d5a <picinit>
  ioapicinit();    // another interrupt controller
80102ab8:	e8 20 f4 ff ff       	call   80101edd <ioapicinit>
  consoleinit();   // console hardware
80102abd:	e8 c8 dd ff ff       	call   8010088a <consoleinit>
  uartinit();      // serial port
80102ac2:	e8 3e 2e 00 00       	call   80105905 <uartinit>
  pinit();         // process table
80102ac7:	e8 34 08 00 00       	call   80103300 <pinit>
  tvinit();        // trap vectors
80102acc:	e8 39 2a 00 00       	call   8010550a <tvinit>
  binit();         // buffer cache
80102ad1:	e8 1e d6 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102ad6:	e8 28 e1 ff ff       	call   80100c03 <fileinit>
  ideinit();       // disk 
80102adb:	e8 09 f2 ff ff       	call   80101ce9 <ideinit>
  startothers();   // start other processors
80102ae0:	e8 99 fe ff ff       	call   8010297e <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102ae5:	83 c4 08             	add    $0x8,%esp
80102ae8:	68 00 00 00 8e       	push   $0x8e000000
80102aed:	68 00 00 40 80       	push   $0x80400000
80102af2:	e8 b2 f5 ff ff       	call   801020a9 <kinit2>
  userinit();      // first user process
80102af7:	e8 34 0c 00 00       	call   80103730 <userinit>
  mpmain();        // finish this processor's setup
80102afc:	e8 25 ff ff ff       	call   80102a26 <mpmain>

80102b01 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102b01:	55                   	push   %ebp
80102b02:	89 e5                	mov    %esp,%ebp
80102b04:	56                   	push   %esi
80102b05:	53                   	push   %ebx
80102b06:	89 c6                	mov    %eax,%esi
  int i, sum;

  sum = 0;
80102b08:	b8 00 00 00 00       	mov    $0x0,%eax
  for(i=0; i<len; i++)
80102b0d:	b9 00 00 00 00       	mov    $0x0,%ecx
80102b12:	eb 09                	jmp    80102b1d <sum+0x1c>
    sum += addr[i];
80102b14:	0f b6 1c 0e          	movzbl (%esi,%ecx,1),%ebx
80102b18:	01 d8                	add    %ebx,%eax
  for(i=0; i<len; i++)
80102b1a:	83 c1 01             	add    $0x1,%ecx
80102b1d:	39 d1                	cmp    %edx,%ecx
80102b1f:	7c f3                	jl     80102b14 <sum+0x13>
  return sum;
}
80102b21:	5b                   	pop    %ebx
80102b22:	5e                   	pop    %esi
80102b23:	5d                   	pop    %ebp
80102b24:	c3                   	ret    

80102b25 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102b25:	55                   	push   %ebp
80102b26:	89 e5                	mov    %esp,%ebp
80102b28:	56                   	push   %esi
80102b29:	53                   	push   %ebx
}

// Convert physical address to kernel virtual address
static inline void *P2V(uint a) {
    extern void panic(char*) __attribute__((noreturn));
    if (a > KERNBASE)
80102b2a:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80102b2f:	77 0b                	ja     80102b3c <mpsearch1+0x17>
        panic("P2V on address > KERNBASE");
    return (char*)a + KERNBASE;
80102b31:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
80102b37:	8d 34 13             	lea    (%ebx,%edx,1),%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102b3a:	eb 10                	jmp    80102b4c <mpsearch1+0x27>
        panic("P2V on address > KERNBASE");
80102b3c:	83 ec 0c             	sub    $0xc,%esp
80102b3f:	68 d8 74 10 80       	push   $0x801074d8
80102b44:	e8 ff d7 ff ff       	call   80100348 <panic>
80102b49:	83 c3 10             	add    $0x10,%ebx
80102b4c:	39 f3                	cmp    %esi,%ebx
80102b4e:	73 29                	jae    80102b79 <mpsearch1+0x54>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b50:	83 ec 04             	sub    $0x4,%esp
80102b53:	6a 04                	push   $0x4
80102b55:	68 f2 74 10 80       	push   $0x801074f2
80102b5a:	53                   	push   %ebx
80102b5b:	e8 fe 18 00 00       	call   8010445e <memcmp>
80102b60:	83 c4 10             	add    $0x10,%esp
80102b63:	85 c0                	test   %eax,%eax
80102b65:	75 e2                	jne    80102b49 <mpsearch1+0x24>
80102b67:	ba 10 00 00 00       	mov    $0x10,%edx
80102b6c:	89 d8                	mov    %ebx,%eax
80102b6e:	e8 8e ff ff ff       	call   80102b01 <sum>
80102b73:	84 c0                	test   %al,%al
80102b75:	75 d2                	jne    80102b49 <mpsearch1+0x24>
80102b77:	eb 05                	jmp    80102b7e <mpsearch1+0x59>
      return (struct mp*)p;
  return 0;
80102b79:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102b7e:	89 d8                	mov    %ebx,%eax
80102b80:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102b83:	5b                   	pop    %ebx
80102b84:	5e                   	pop    %esi
80102b85:	5d                   	pop    %ebp
80102b86:	c3                   	ret    

80102b87 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102b87:	55                   	push   %ebp
80102b88:	89 e5                	mov    %esp,%ebp
80102b8a:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102b8d:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102b94:	c1 e0 08             	shl    $0x8,%eax
80102b97:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102b9e:	09 d0                	or     %edx,%eax
80102ba0:	c1 e0 04             	shl    $0x4,%eax
80102ba3:	74 1f                	je     80102bc4 <mpsearch+0x3d>
    if((mp = mpsearch1(p, 1024)))
80102ba5:	ba 00 04 00 00       	mov    $0x400,%edx
80102baa:	e8 76 ff ff ff       	call   80102b25 <mpsearch1>
80102baf:	85 c0                	test   %eax,%eax
80102bb1:	75 0f                	jne    80102bc2 <mpsearch+0x3b>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102bb3:	ba 00 00 01 00       	mov    $0x10000,%edx
80102bb8:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102bbd:	e8 63 ff ff ff       	call   80102b25 <mpsearch1>
}
80102bc2:	c9                   	leave  
80102bc3:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102bc4:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102bcb:	c1 e0 08             	shl    $0x8,%eax
80102bce:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102bd5:	09 d0                	or     %edx,%eax
80102bd7:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102bda:	2d 00 04 00 00       	sub    $0x400,%eax
80102bdf:	ba 00 04 00 00       	mov    $0x400,%edx
80102be4:	e8 3c ff ff ff       	call   80102b25 <mpsearch1>
80102be9:	85 c0                	test   %eax,%eax
80102beb:	75 d5                	jne    80102bc2 <mpsearch+0x3b>
80102bed:	eb c4                	jmp    80102bb3 <mpsearch+0x2c>

80102bef <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102bef:	55                   	push   %ebp
80102bf0:	89 e5                	mov    %esp,%ebp
80102bf2:	57                   	push   %edi
80102bf3:	56                   	push   %esi
80102bf4:	53                   	push   %ebx
80102bf5:	83 ec 0c             	sub    $0xc,%esp
80102bf8:	89 c7                	mov    %eax,%edi
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102bfa:	e8 88 ff ff ff       	call   80102b87 <mpsearch>
80102bff:	89 c6                	mov    %eax,%esi
80102c01:	85 c0                	test   %eax,%eax
80102c03:	74 66                	je     80102c6b <mpconfig+0x7c>
80102c05:	8b 58 04             	mov    0x4(%eax),%ebx
80102c08:	85 db                	test   %ebx,%ebx
80102c0a:	74 48                	je     80102c54 <mpconfig+0x65>
    if (a > KERNBASE)
80102c0c:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80102c12:	77 4a                	ja     80102c5e <mpconfig+0x6f>
    return (char*)a + KERNBASE;
80102c14:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
  if(memcmp(conf, "PCMP", 4) != 0)
80102c1a:	83 ec 04             	sub    $0x4,%esp
80102c1d:	6a 04                	push   $0x4
80102c1f:	68 f7 74 10 80       	push   $0x801074f7
80102c24:	53                   	push   %ebx
80102c25:	e8 34 18 00 00       	call   8010445e <memcmp>
80102c2a:	83 c4 10             	add    $0x10,%esp
80102c2d:	85 c0                	test   %eax,%eax
80102c2f:	75 3e                	jne    80102c6f <mpconfig+0x80>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102c31:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
80102c35:	3c 01                	cmp    $0x1,%al
80102c37:	0f 95 c2             	setne  %dl
80102c3a:	3c 04                	cmp    $0x4,%al
80102c3c:	0f 95 c0             	setne  %al
80102c3f:	84 c2                	test   %al,%dl
80102c41:	75 33                	jne    80102c76 <mpconfig+0x87>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102c43:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
80102c47:	89 d8                	mov    %ebx,%eax
80102c49:	e8 b3 fe ff ff       	call   80102b01 <sum>
80102c4e:	84 c0                	test   %al,%al
80102c50:	75 2b                	jne    80102c7d <mpconfig+0x8e>
    return 0;
  *pmp = mp;
80102c52:	89 37                	mov    %esi,(%edi)
  return conf;
}
80102c54:	89 d8                	mov    %ebx,%eax
80102c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c59:	5b                   	pop    %ebx
80102c5a:	5e                   	pop    %esi
80102c5b:	5f                   	pop    %edi
80102c5c:	5d                   	pop    %ebp
80102c5d:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80102c5e:	83 ec 0c             	sub    $0xc,%esp
80102c61:	68 d8 74 10 80       	push   $0x801074d8
80102c66:	e8 dd d6 ff ff       	call   80100348 <panic>
    return 0;
80102c6b:	89 c3                	mov    %eax,%ebx
80102c6d:	eb e5                	jmp    80102c54 <mpconfig+0x65>
    return 0;
80102c6f:	bb 00 00 00 00       	mov    $0x0,%ebx
80102c74:	eb de                	jmp    80102c54 <mpconfig+0x65>
    return 0;
80102c76:	bb 00 00 00 00       	mov    $0x0,%ebx
80102c7b:	eb d7                	jmp    80102c54 <mpconfig+0x65>
    return 0;
80102c7d:	bb 00 00 00 00       	mov    $0x0,%ebx
80102c82:	eb d0                	jmp    80102c54 <mpconfig+0x65>

80102c84 <mpinit>:

void
mpinit(void)
{
80102c84:	55                   	push   %ebp
80102c85:	89 e5                	mov    %esp,%ebp
80102c87:	57                   	push   %edi
80102c88:	56                   	push   %esi
80102c89:	53                   	push   %ebx
80102c8a:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102c8d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102c90:	e8 5a ff ff ff       	call   80102bef <mpconfig>
80102c95:	85 c0                	test   %eax,%eax
80102c97:	74 19                	je     80102cb2 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102c99:	8b 50 24             	mov    0x24(%eax),%edx
80102c9c:	89 15 80 16 11 80    	mov    %edx,0x80111680
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102ca2:	8d 50 2c             	lea    0x2c(%eax),%edx
80102ca5:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102ca9:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102cab:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102cb0:	eb 20                	jmp    80102cd2 <mpinit+0x4e>
    panic("Expect to run on an SMP");
80102cb2:	83 ec 0c             	sub    $0xc,%esp
80102cb5:	68 fc 74 10 80       	push   $0x801074fc
80102cba:	e8 89 d6 ff ff       	call   80100348 <panic>
    switch(*p){
80102cbf:	bb 00 00 00 00       	mov    $0x0,%ebx
80102cc4:	eb 0c                	jmp    80102cd2 <mpinit+0x4e>
80102cc6:	83 e8 03             	sub    $0x3,%eax
80102cc9:	3c 01                	cmp    $0x1,%al
80102ccb:	76 1a                	jbe    80102ce7 <mpinit+0x63>
80102ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102cd2:	39 ca                	cmp    %ecx,%edx
80102cd4:	73 4d                	jae    80102d23 <mpinit+0x9f>
    switch(*p){
80102cd6:	0f b6 02             	movzbl (%edx),%eax
80102cd9:	3c 02                	cmp    $0x2,%al
80102cdb:	74 38                	je     80102d15 <mpinit+0x91>
80102cdd:	77 e7                	ja     80102cc6 <mpinit+0x42>
80102cdf:	84 c0                	test   %al,%al
80102ce1:	74 09                	je     80102cec <mpinit+0x68>
80102ce3:	3c 01                	cmp    $0x1,%al
80102ce5:	75 d8                	jne    80102cbf <mpinit+0x3b>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102ce7:	83 c2 08             	add    $0x8,%edx
      continue;
80102cea:	eb e6                	jmp    80102cd2 <mpinit+0x4e>
      if(ncpu < NCPU) {
80102cec:	8b 35 84 17 11 80    	mov    0x80111784,%esi
80102cf2:	83 fe 07             	cmp    $0x7,%esi
80102cf5:	7f 19                	jg     80102d10 <mpinit+0x8c>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102cf7:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102cfb:	69 fe b4 00 00 00    	imul   $0xb4,%esi,%edi
80102d01:	88 87 a0 17 11 80    	mov    %al,-0x7feee860(%edi)
        ncpu++;
80102d07:	83 c6 01             	add    $0x1,%esi
80102d0a:	89 35 84 17 11 80    	mov    %esi,0x80111784
      p += sizeof(struct mpproc);
80102d10:	83 c2 14             	add    $0x14,%edx
      continue;
80102d13:	eb bd                	jmp    80102cd2 <mpinit+0x4e>
      ioapicid = ioapic->apicno;
80102d15:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102d19:	a2 80 17 11 80       	mov    %al,0x80111780
      p += sizeof(struct mpioapic);
80102d1e:	83 c2 08             	add    $0x8,%edx
      continue;
80102d21:	eb af                	jmp    80102cd2 <mpinit+0x4e>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80102d23:	85 db                	test   %ebx,%ebx
80102d25:	74 26                	je     80102d4d <mpinit+0xc9>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102d27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d2a:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102d2e:	74 15                	je     80102d45 <mpinit+0xc1>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d30:	b8 70 00 00 00       	mov    $0x70,%eax
80102d35:	ba 22 00 00 00       	mov    $0x22,%edx
80102d3a:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d3b:	ba 23 00 00 00       	mov    $0x23,%edx
80102d40:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102d41:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d44:	ee                   	out    %al,(%dx)
  }
}
80102d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d48:	5b                   	pop    %ebx
80102d49:	5e                   	pop    %esi
80102d4a:	5f                   	pop    %edi
80102d4b:	5d                   	pop    %ebp
80102d4c:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102d4d:	83 ec 0c             	sub    $0xc,%esp
80102d50:	68 14 75 10 80       	push   $0x80107514
80102d55:	e8 ee d5 ff ff       	call   80100348 <panic>

80102d5a <picinit>:
80102d5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d5f:	ba 21 00 00 00       	mov    $0x21,%edx
80102d64:	ee                   	out    %al,(%dx)
80102d65:	ba a1 00 00 00       	mov    $0xa1,%edx
80102d6a:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102d6b:	c3                   	ret    

80102d6c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102d6c:	55                   	push   %ebp
80102d6d:	89 e5                	mov    %esp,%ebp
80102d6f:	57                   	push   %edi
80102d70:	56                   	push   %esi
80102d71:	53                   	push   %ebx
80102d72:	83 ec 0c             	sub    $0xc,%esp
80102d75:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102d78:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102d7b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102d81:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102d87:	e8 91 de ff ff       	call   80100c1d <filealloc>
80102d8c:	89 03                	mov    %eax,(%ebx)
80102d8e:	85 c0                	test   %eax,%eax
80102d90:	0f 84 88 00 00 00    	je     80102e1e <pipealloc+0xb2>
80102d96:	e8 82 de ff ff       	call   80100c1d <filealloc>
80102d9b:	89 06                	mov    %eax,(%esi)
80102d9d:	85 c0                	test   %eax,%eax
80102d9f:	74 7d                	je     80102e1e <pipealloc+0xb2>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102da1:	e8 23 f3 ff ff       	call   801020c9 <kalloc>
80102da6:	89 c7                	mov    %eax,%edi
80102da8:	85 c0                	test   %eax,%eax
80102daa:	74 72                	je     80102e1e <pipealloc+0xb2>
    goto bad;
  p->readopen = 1;
80102dac:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102db3:	00 00 00 
  p->writeopen = 1;
80102db6:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102dbd:	00 00 00 
  p->nwrite = 0;
80102dc0:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102dc7:	00 00 00 
  p->nread = 0;
80102dca:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102dd1:	00 00 00 
  initlock(&p->lock, "pipe");
80102dd4:	83 ec 08             	sub    $0x8,%esp
80102dd7:	68 33 75 10 80       	push   $0x80107533
80102ddc:	50                   	push   %eax
80102ddd:	e8 51 14 00 00       	call   80104233 <initlock>
  (*f0)->type = FD_PIPE;
80102de2:	8b 03                	mov    (%ebx),%eax
80102de4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102dea:	8b 03                	mov    (%ebx),%eax
80102dec:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102df0:	8b 03                	mov    (%ebx),%eax
80102df2:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102df6:	8b 03                	mov    (%ebx),%eax
80102df8:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102dfb:	8b 06                	mov    (%esi),%eax
80102dfd:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102e03:	8b 06                	mov    (%esi),%eax
80102e05:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102e09:	8b 06                	mov    (%esi),%eax
80102e0b:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102e0f:	8b 06                	mov    (%esi),%eax
80102e11:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102e14:	83 c4 10             	add    $0x10,%esp
80102e17:	b8 00 00 00 00       	mov    $0x0,%eax
80102e1c:	eb 29                	jmp    80102e47 <pipealloc+0xdb>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102e1e:	8b 03                	mov    (%ebx),%eax
80102e20:	85 c0                	test   %eax,%eax
80102e22:	74 0c                	je     80102e30 <pipealloc+0xc4>
    fileclose(*f0);
80102e24:	83 ec 0c             	sub    $0xc,%esp
80102e27:	50                   	push   %eax
80102e28:	e8 96 de ff ff       	call   80100cc3 <fileclose>
80102e2d:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102e30:	8b 06                	mov    (%esi),%eax
80102e32:	85 c0                	test   %eax,%eax
80102e34:	74 19                	je     80102e4f <pipealloc+0xe3>
    fileclose(*f1);
80102e36:	83 ec 0c             	sub    $0xc,%esp
80102e39:	50                   	push   %eax
80102e3a:	e8 84 de ff ff       	call   80100cc3 <fileclose>
80102e3f:	83 c4 10             	add    $0x10,%esp
  return -1;
80102e42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102e47:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e4a:	5b                   	pop    %ebx
80102e4b:	5e                   	pop    %esi
80102e4c:	5f                   	pop    %edi
80102e4d:	5d                   	pop    %ebp
80102e4e:	c3                   	ret    
  return -1;
80102e4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e54:	eb f1                	jmp    80102e47 <pipealloc+0xdb>

80102e56 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102e56:	55                   	push   %ebp
80102e57:	89 e5                	mov    %esp,%ebp
80102e59:	53                   	push   %ebx
80102e5a:	83 ec 10             	sub    $0x10,%esp
80102e5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102e60:	53                   	push   %ebx
80102e61:	e8 09 15 00 00       	call   8010436f <acquire>
  if(writable){
80102e66:	83 c4 10             	add    $0x10,%esp
80102e69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102e6d:	74 3f                	je     80102eae <pipeclose+0x58>
    p->writeopen = 0;
80102e6f:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102e76:	00 00 00 
    wakeup(&p->nread);
80102e79:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e7f:	83 ec 0c             	sub    $0xc,%esp
80102e82:	50                   	push   %eax
80102e83:	e8 4c 11 00 00       	call   80103fd4 <wakeup>
80102e88:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102e8b:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102e92:	75 09                	jne    80102e9d <pipeclose+0x47>
80102e94:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102e9b:	74 2f                	je     80102ecc <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102e9d:	83 ec 0c             	sub    $0xc,%esp
80102ea0:	53                   	push   %ebx
80102ea1:	e8 2e 15 00 00       	call   801043d4 <release>
80102ea6:	83 c4 10             	add    $0x10,%esp
}
80102ea9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102eac:	c9                   	leave  
80102ead:	c3                   	ret    
    p->readopen = 0;
80102eae:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102eb5:	00 00 00 
    wakeup(&p->nwrite);
80102eb8:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102ebe:	83 ec 0c             	sub    $0xc,%esp
80102ec1:	50                   	push   %eax
80102ec2:	e8 0d 11 00 00       	call   80103fd4 <wakeup>
80102ec7:	83 c4 10             	add    $0x10,%esp
80102eca:	eb bf                	jmp    80102e8b <pipeclose+0x35>
    release(&p->lock);
80102ecc:	83 ec 0c             	sub    $0xc,%esp
80102ecf:	53                   	push   %ebx
80102ed0:	e8 ff 14 00 00       	call   801043d4 <release>
    kfree((char*)p);
80102ed5:	89 1c 24             	mov    %ebx,(%esp)
80102ed8:	e8 af f0 ff ff       	call   80101f8c <kfree>
80102edd:	83 c4 10             	add    $0x10,%esp
80102ee0:	eb c7                	jmp    80102ea9 <pipeclose+0x53>

80102ee2 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102ee2:	55                   	push   %ebp
80102ee3:	89 e5                	mov    %esp,%ebp
80102ee5:	57                   	push   %edi
80102ee6:	56                   	push   %esi
80102ee7:	53                   	push   %ebx
80102ee8:	83 ec 18             	sub    $0x18,%esp
80102eeb:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102eee:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  acquire(&p->lock);
80102ef1:	53                   	push   %ebx
80102ef2:	e8 78 14 00 00       	call   8010436f <acquire>
  for(i = 0; i < n; i++){
80102ef7:	83 c4 10             	add    $0x10,%esp
80102efa:	bf 00 00 00 00       	mov    $0x0,%edi
80102eff:	39 f7                	cmp    %esi,%edi
80102f01:	7c 40                	jl     80102f43 <pipewrite+0x61>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102f03:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f09:	83 ec 0c             	sub    $0xc,%esp
80102f0c:	50                   	push   %eax
80102f0d:	e8 c2 10 00 00       	call   80103fd4 <wakeup>
  release(&p->lock);
80102f12:	89 1c 24             	mov    %ebx,(%esp)
80102f15:	e8 ba 14 00 00       	call   801043d4 <release>
  return n;
80102f1a:	83 c4 10             	add    $0x10,%esp
80102f1d:	89 f0                	mov    %esi,%eax
80102f1f:	eb 5c                	jmp    80102f7d <pipewrite+0x9b>
      wakeup(&p->nread);
80102f21:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f27:	83 ec 0c             	sub    $0xc,%esp
80102f2a:	50                   	push   %eax
80102f2b:	e8 a4 10 00 00       	call   80103fd4 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f30:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f36:	83 c4 08             	add    $0x8,%esp
80102f39:	53                   	push   %ebx
80102f3a:	50                   	push   %eax
80102f3b:	e8 2c 0f 00 00       	call   80103e6c <sleep>
80102f40:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102f43:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102f49:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102f4f:	05 00 02 00 00       	add    $0x200,%eax
80102f54:	39 c2                	cmp    %eax,%edx
80102f56:	75 2d                	jne    80102f85 <pipewrite+0xa3>
      if(p->readopen == 0 || myproc()->killed){
80102f58:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102f5f:	74 0b                	je     80102f6c <pipewrite+0x8a>
80102f61:	e8 04 05 00 00       	call   8010346a <myproc>
80102f66:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102f6a:	74 b5                	je     80102f21 <pipewrite+0x3f>
        release(&p->lock);
80102f6c:	83 ec 0c             	sub    $0xc,%esp
80102f6f:	53                   	push   %ebx
80102f70:	e8 5f 14 00 00       	call   801043d4 <release>
        return -1;
80102f75:	83 c4 10             	add    $0x10,%esp
80102f78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102f7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f80:	5b                   	pop    %ebx
80102f81:	5e                   	pop    %esi
80102f82:	5f                   	pop    %edi
80102f83:	5d                   	pop    %ebp
80102f84:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102f85:	8d 42 01             	lea    0x1(%edx),%eax
80102f88:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80102f8e:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102f94:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f97:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80102f9b:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80102f9f:	83 c7 01             	add    $0x1,%edi
80102fa2:	e9 58 ff ff ff       	jmp    80102eff <pipewrite+0x1d>

80102fa7 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80102fa7:	55                   	push   %ebp
80102fa8:	89 e5                	mov    %esp,%ebp
80102faa:	57                   	push   %edi
80102fab:	56                   	push   %esi
80102fac:	53                   	push   %ebx
80102fad:	83 ec 18             	sub    $0x18,%esp
80102fb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102fb3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
80102fb6:	53                   	push   %ebx
80102fb7:	e8 b3 13 00 00       	call   8010436f <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102fbc:	83 c4 10             	add    $0x10,%esp
80102fbf:	eb 13                	jmp    80102fd4 <piperead+0x2d>
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80102fc1:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fc7:	83 ec 08             	sub    $0x8,%esp
80102fca:	53                   	push   %ebx
80102fcb:	50                   	push   %eax
80102fcc:	e8 9b 0e 00 00       	call   80103e6c <sleep>
80102fd1:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102fd4:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102fda:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102fe0:	75 78                	jne    8010305a <piperead+0xb3>
80102fe2:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102fe8:	85 f6                	test   %esi,%esi
80102fea:	74 37                	je     80103023 <piperead+0x7c>
    if(myproc()->killed){
80102fec:	e8 79 04 00 00       	call   8010346a <myproc>
80102ff1:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102ff5:	74 ca                	je     80102fc1 <piperead+0x1a>
      release(&p->lock);
80102ff7:	83 ec 0c             	sub    $0xc,%esp
80102ffa:	53                   	push   %ebx
80102ffb:	e8 d4 13 00 00       	call   801043d4 <release>
      return -1;
80103000:	83 c4 10             	add    $0x10,%esp
80103003:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103008:	eb 46                	jmp    80103050 <piperead+0xa9>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010300a:	8d 50 01             	lea    0x1(%eax),%edx
8010300d:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80103013:	25 ff 01 00 00       	and    $0x1ff,%eax
80103018:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
8010301d:	88 04 37             	mov    %al,(%edi,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103020:	83 c6 01             	add    $0x1,%esi
80103023:	3b 75 10             	cmp    0x10(%ebp),%esi
80103026:	7d 0e                	jge    80103036 <piperead+0x8f>
    if(p->nread == p->nwrite)
80103028:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010302e:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80103034:	75 d4                	jne    8010300a <piperead+0x63>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103036:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010303c:	83 ec 0c             	sub    $0xc,%esp
8010303f:	50                   	push   %eax
80103040:	e8 8f 0f 00 00       	call   80103fd4 <wakeup>
  release(&p->lock);
80103045:	89 1c 24             	mov    %ebx,(%esp)
80103048:	e8 87 13 00 00       	call   801043d4 <release>
  return i;
8010304d:	83 c4 10             	add    $0x10,%esp
}
80103050:	89 f0                	mov    %esi,%eax
80103052:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103055:	5b                   	pop    %ebx
80103056:	5e                   	pop    %esi
80103057:	5f                   	pop    %edi
80103058:	5d                   	pop    %ebp
80103059:	c3                   	ret    
8010305a:	be 00 00 00 00       	mov    $0x0,%esi
8010305f:	eb c2                	jmp    80103023 <piperead+0x7c>

80103061 <wakeup1>:
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
80103061:	ba 94 1d 11 80       	mov    $0x80111d94,%edx
80103066:	eb 06                	jmp    8010306e <wakeup1+0xd>
80103068:	81 c2 84 00 00 00    	add    $0x84,%edx
8010306e:	81 fa 94 3e 11 80    	cmp    $0x80113e94,%edx
80103074:	73 14                	jae    8010308a <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
80103076:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
8010307a:	75 ec                	jne    80103068 <wakeup1+0x7>
8010307c:	39 42 20             	cmp    %eax,0x20(%edx)
8010307f:	75 e7                	jne    80103068 <wakeup1+0x7>
      p->state = RUNNABLE;
80103081:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
80103088:	eb de                	jmp    80103068 <wakeup1+0x7>
  }
}
8010308a:	c3                   	ret    

8010308b <allocproc>:
{
8010308b:	55                   	push   %ebp
8010308c:	89 e5                	mov    %esp,%ebp
8010308e:	53                   	push   %ebx
8010308f:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103092:	68 60 1d 11 80       	push   $0x80111d60
80103097:	e8 d3 12 00 00       	call   8010436f <acquire>
  for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
8010309c:	83 c4 10             	add    $0x10,%esp
8010309f:	bb 94 1d 11 80       	mov    $0x80111d94,%ebx
801030a4:	eb 06                	jmp    801030ac <allocproc+0x21>
801030a6:	81 c3 84 00 00 00    	add    $0x84,%ebx
801030ac:	81 fb 94 3e 11 80    	cmp    $0x80113e94,%ebx
801030b2:	0f 83 87 00 00 00    	jae    8010313f <allocproc+0xb4>
    if(p->state == UNUSED)
801030b8:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
801030bc:	75 e8                	jne    801030a6 <allocproc+0x1b>
  p->state = EMBRYO;
801030be:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
801030c5:	a1 04 a0 10 80       	mov    0x8010a004,%eax
801030ca:	8d 50 01             	lea    0x1(%eax),%edx
801030cd:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
801030d3:	89 43 10             	mov    %eax,0x10(%ebx)
  p->ticks_left = RSDL_PROC_QUANTUM;
801030d6:	c7 43 7c 14 00 00 00 	movl   $0x14,0x7c(%ebx)
  p->default_level = RSDL_STARTING_LEVEL;
801030dd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
801030e4:	00 00 00 
  release(&ptable.lock);
801030e7:	83 ec 0c             	sub    $0xc,%esp
801030ea:	68 60 1d 11 80       	push   $0x80111d60
801030ef:	e8 e0 12 00 00       	call   801043d4 <release>
  if((p->kstack = kalloc()) == 0){
801030f4:	e8 d0 ef ff ff       	call   801020c9 <kalloc>
801030f9:	89 43 08             	mov    %eax,0x8(%ebx)
801030fc:	83 c4 10             	add    $0x10,%esp
801030ff:	85 c0                	test   %eax,%eax
80103101:	74 53                	je     80103156 <allocproc+0xcb>
  sp -= sizeof *p->tf;
80103103:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80103109:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
8010310c:	c7 80 b0 0f 00 00 ff 	movl   $0x801054ff,0xfb0(%eax)
80103113:	54 10 80 
  sp -= sizeof *p->context;
80103116:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
8010311b:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
8010311e:	83 ec 04             	sub    $0x4,%esp
80103121:	6a 14                	push   $0x14
80103123:	6a 00                	push   $0x0
80103125:	50                   	push   %eax
80103126:	e8 f0 12 00 00       	call   8010441b <memset>
  p->context->eip = (uint)forkret;
8010312b:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010312e:	c7 40 10 61 31 10 80 	movl   $0x80103161,0x10(%eax)
  return p;
80103135:	83 c4 10             	add    $0x10,%esp
}
80103138:	89 d8                	mov    %ebx,%eax
8010313a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010313d:	c9                   	leave  
8010313e:	c3                   	ret    
  release(&ptable.lock);
8010313f:	83 ec 0c             	sub    $0xc,%esp
80103142:	68 60 1d 11 80       	push   $0x80111d60
80103147:	e8 88 12 00 00       	call   801043d4 <release>
  return 0;
8010314c:	83 c4 10             	add    $0x10,%esp
8010314f:	bb 00 00 00 00       	mov    $0x0,%ebx
80103154:	eb e2                	jmp    80103138 <allocproc+0xad>
    p->state = UNUSED;
80103156:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
8010315d:	89 c3                	mov    %eax,%ebx
8010315f:	eb d7                	jmp    80103138 <allocproc+0xad>

80103161 <forkret>:
{
80103161:	55                   	push   %ebp
80103162:	89 e5                	mov    %esp,%ebp
80103164:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
80103167:	68 60 1d 11 80       	push   $0x80111d60
8010316c:	e8 63 12 00 00       	call   801043d4 <release>
  if (first) {
80103171:	83 c4 10             	add    $0x10,%esp
80103174:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
8010317b:	75 02                	jne    8010317f <forkret+0x1e>
}
8010317d:	c9                   	leave  
8010317e:	c3                   	ret    
    first = 0;
8010317f:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103186:	00 00 00 
    iinit(ROOTDEV);
80103189:	83 ec 0c             	sub    $0xc,%esp
8010318c:	6a 01                	push   $0x1
8010318e:	e8 47 e1 ff ff       	call   801012da <iinit>
    initlog(ROOTDEV);
80103193:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010319a:	e8 c8 f5 ff ff       	call   80102767 <initlog>
8010319f:	83 c4 10             	add    $0x10,%esp
}
801031a2:	eb d9                	jmp    8010317d <forkret+0x1c>

801031a4 <is_active_set>:
{
801031a4:	55                   	push   %ebp
801031a5:	89 e5                	mov    %esp,%ebp
801031a7:	8b 55 08             	mov    0x8(%ebp),%edx
  return ptable.active <= q
801031aa:	a1 94 3e 11 80       	mov    0x80113e94,%eax
         && q < &ptable.active[RSDL_LEVELS];
801031af:	39 d0                	cmp    %edx,%eax
801031b1:	77 10                	ja     801031c3 <is_active_set+0x1f>
801031b3:	05 b4 03 00 00       	add    $0x3b4,%eax
801031b8:	39 d0                	cmp    %edx,%eax
801031ba:	77 0e                	ja     801031ca <is_active_set+0x26>
801031bc:	b8 00 00 00 00       	mov    $0x0,%eax
801031c1:	eb 05                	jmp    801031c8 <is_active_set+0x24>
801031c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801031c8:	5d                   	pop    %ebp
801031c9:	c3                   	ret    
         && q < &ptable.active[RSDL_LEVELS];
801031ca:	b8 01 00 00 00       	mov    $0x1,%eax
801031cf:	eb f7                	jmp    801031c8 <is_active_set+0x24>

801031d1 <is_expired_set>:
{
801031d1:	55                   	push   %ebp
801031d2:	89 e5                	mov    %esp,%ebp
801031d4:	83 ec 14             	sub    $0x14,%esp
  return !is_active_set(q);
801031d7:	ff 75 08             	push   0x8(%ebp)
801031da:	e8 c5 ff ff ff       	call   801031a4 <is_active_set>
801031df:	83 c4 10             	add    $0x10,%esp
801031e2:	85 c0                	test   %eax,%eax
801031e4:	0f 94 c0             	sete   %al
801031e7:	0f b6 c0             	movzbl %al,%eax
}
801031ea:	c9                   	leave  
801031eb:	c3                   	ret    

801031ec <schedlog>:
void schedlog(int n) {
801031ec:	55                   	push   %ebp
801031ed:	89 e5                	mov    %esp,%ebp
  schedlog_active = 1;
801031ef:	c7 05 44 1d 11 80 01 	movl   $0x1,0x80111d44
801031f6:	00 00 00 
  schedlog_lasttick = ticks + n;
801031f9:	a1 20 46 11 80       	mov    0x80114620,%eax
801031fe:	03 45 08             	add    0x8(%ebp),%eax
80103201:	a3 40 1d 11 80       	mov    %eax,0x80111d40
}
80103206:	5d                   	pop    %ebp
80103207:	c3                   	ret    

80103208 <print_schedlog>:
void print_schedlog(void) {
80103208:	55                   	push   %ebp
80103209:	89 e5                	mov    %esp,%ebp
8010320b:	57                   	push   %edi
8010320c:	56                   	push   %esi
8010320d:	53                   	push   %ebx
8010320e:	83 ec 2c             	sub    $0x2c,%esp
  struct level_queue *set[] = {ptable.active, ptable.expired};
80103211:	a1 94 3e 11 80       	mov    0x80113e94,%eax
80103216:	89 45 e0             	mov    %eax,-0x20(%ebp)
80103219:	a1 98 3e 11 80       	mov    0x80113e98,%eax
8010321e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for (int s = 0; s < 2; ++s) {
80103221:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
80103228:	e9 99 00 00 00       	jmp    801032c6 <print_schedlog+0xbe>
    char *set_name = (is_active_set(&set[s][0])) ? "active" : "expired";
8010322d:	c7 45 d0 3f 75 10 80 	movl   $0x8010753f,-0x30(%ebp)
80103234:	e9 b8 00 00 00       	jmp    801032f1 <print_schedlog+0xe9>
      for(int i = 0; i < qq->numproc; ++i) {
80103239:	83 c3 01             	add    $0x1,%ebx
8010323c:	39 5e 34             	cmp    %ebx,0x34(%esi)
8010323f:	7e 28                	jle    80103269 <print_schedlog+0x61>
        pp = qq->proc[i];
80103241:	8b 44 9e 3c          	mov    0x3c(%esi,%ebx,4),%eax
        if (pp->state == UNUSED) continue;
80103245:	8b 50 0c             	mov    0xc(%eax),%edx
80103248:	85 d2                	test   %edx,%edx
8010324a:	74 ed                	je     80103239 <print_schedlog+0x31>
        else cprintf(",[%d]%s:%d(%d)", pp->pid, pp->name, pp->state, pp->ticks_left);
8010324c:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010324f:	83 ec 0c             	sub    $0xc,%esp
80103252:	ff 70 7c             	push   0x7c(%eax)
80103255:	52                   	push   %edx
80103256:	51                   	push   %ecx
80103257:	ff 70 10             	push   0x10(%eax)
8010325a:	68 54 75 10 80       	push   $0x80107554
8010325f:	e8 a3 d3 ff ff       	call   80100607 <cprintf>
80103264:	83 c4 20             	add    $0x20,%esp
80103267:	eb d0                	jmp    80103239 <print_schedlog+0x31>
      release(&qq->lock);
80103269:	83 ec 0c             	sub    $0xc,%esp
8010326c:	56                   	push   %esi
8010326d:	e8 62 11 00 00       	call   801043d4 <release>
      cprintf("\n");
80103272:	c7 04 24 bb 7a 10 80 	movl   $0x80107abb,(%esp)
80103279:	e8 89 d3 ff ff       	call   80100607 <cprintf>
    for (int k = 0; k < RSDL_LEVELS; ++k) {
8010327e:	83 c7 01             	add    $0x1,%edi
80103281:	83 c4 10             	add    $0x10,%esp
80103284:	83 ff 02             	cmp    $0x2,%edi
80103287:	7f 39                	jg     801032c2 <print_schedlog+0xba>
      qq = &set[s][k];
80103289:	69 f7 3c 01 00 00    	imul   $0x13c,%edi,%esi
8010328f:	03 75 d4             	add    -0x2c(%ebp),%esi
      acquire(&qq->lock);
80103292:	83 ec 0c             	sub    $0xc,%esp
80103295:	56                   	push   %esi
80103296:	e8 d4 10 00 00       	call   8010436f <acquire>
      cprintf("%d|%s|%d(%d)", ticks, set_name, k, qq->ticks_left);
8010329b:	83 c4 04             	add    $0x4,%esp
8010329e:	ff 76 38             	push   0x38(%esi)
801032a1:	57                   	push   %edi
801032a2:	ff 75 d0             	push   -0x30(%ebp)
801032a5:	ff 35 20 46 11 80    	push   0x80114620
801032ab:	68 47 75 10 80       	push   $0x80107547
801032b0:	e8 52 d3 ff ff       	call   80100607 <cprintf>
      for(int i = 0; i < qq->numproc; ++i) {
801032b5:	83 c4 20             	add    $0x20,%esp
801032b8:	bb 00 00 00 00       	mov    $0x0,%ebx
801032bd:	e9 7a ff ff ff       	jmp    8010323c <print_schedlog+0x34>
  for (int s = 0; s < 2; ++s) {
801032c2:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
801032c6:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
801032ca:	7f 2c                	jg     801032f8 <print_schedlog+0xf0>
    char *set_name = (is_active_set(&set[s][0])) ? "active" : "expired";
801032cc:	8b 45 cc             	mov    -0x34(%ebp),%eax
801032cf:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
801032d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801032d6:	83 ec 0c             	sub    $0xc,%esp
801032d9:	50                   	push   %eax
801032da:	e8 c5 fe ff ff       	call   801031a4 <is_active_set>
801032df:	83 c4 10             	add    $0x10,%esp
801032e2:	85 c0                	test   %eax,%eax
801032e4:	0f 84 43 ff ff ff    	je     8010322d <print_schedlog+0x25>
801032ea:	c7 45 d0 38 75 10 80 	movl   $0x80107538,-0x30(%ebp)
    for (int k = 0; k < RSDL_LEVELS; ++k) {
801032f1:	bf 00 00 00 00       	mov    $0x0,%edi
801032f6:	eb 8c                	jmp    80103284 <print_schedlog+0x7c>
}
801032f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801032fb:	5b                   	pop    %ebx
801032fc:	5e                   	pop    %esi
801032fd:	5f                   	pop    %edi
801032fe:	5d                   	pop    %ebp
801032ff:	c3                   	ret    

80103300 <pinit>:
{
80103300:	55                   	push   %ebp
80103301:	89 e5                	mov    %esp,%ebp
80103303:	57                   	push   %edi
80103304:	56                   	push   %esi
80103305:	53                   	push   %ebx
80103306:	83 ec 24             	sub    $0x24,%esp
  initlock(&ptable.lock, "ptable");
80103309:	68 63 75 10 80       	push   $0x80107563
8010330e:	68 60 1d 11 80       	push   $0x80111d60
80103313:	e8 1b 0f 00 00       	call   80104233 <initlock>
  acquire(&ptable.lock);
80103318:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
8010331f:	e8 4b 10 00 00       	call   8010436f <acquire>
  for (int s = 0; s < 2; ++s) {
80103324:	83 c4 10             	add    $0x10,%esp
80103327:	be 00 00 00 00       	mov    $0x0,%esi
8010332c:	e9 8a 00 00 00       	jmp    801033bb <pinit+0xbb>
        lq->proc[i] = NULL;
80103331:	6b d3 4f             	imul   $0x4f,%ebx,%edx
80103334:	69 ce ed 00 00 00    	imul   $0xed,%esi,%ecx
8010333a:	01 ca                	add    %ecx,%edx
8010333c:	8d 94 10 58 08 00 00 	lea    0x858(%eax,%edx,1),%edx
80103343:	c7 04 95 78 1d 11 80 	movl   $0x0,-0x7feee288(,%edx,4)
8010334a:	00 00 00 00 
      for (int i = 0; i < NPROC; ++i){
8010334e:	83 c0 01             	add    $0x1,%eax
80103351:	83 f8 3f             	cmp    $0x3f,%eax
80103354:	7e db                	jle    80103331 <pinit+0x31>
      release(&lq->lock);
80103356:	83 ec 0c             	sub    $0xc,%esp
80103359:	57                   	push   %edi
8010335a:	e8 75 10 00 00       	call   801043d4 <release>
    for (int k = 0; k < RSDL_LEVELS; ++k){
8010335f:	83 c3 01             	add    $0x1,%ebx
80103362:	83 c4 10             	add    $0x10,%esp
80103365:	83 fb 02             	cmp    $0x2,%ebx
80103368:	7f 4e                	jg     801033b8 <pinit+0xb8>
      initlock(&lq->lock, "level queue");
8010336a:	69 d3 3c 01 00 00    	imul   $0x13c,%ebx,%edx
80103370:	69 c6 b4 03 00 00    	imul   $0x3b4,%esi,%eax
80103376:	01 d0                	add    %edx,%eax
80103378:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010337b:	8d b8 9c 3e 11 80    	lea    -0x7feec164(%eax),%edi
80103381:	83 ec 08             	sub    $0x8,%esp
80103384:	68 6a 75 10 80       	push   $0x8010756a
80103389:	57                   	push   %edi
8010338a:	e8 a4 0e 00 00       	call   80104233 <initlock>
      acquire(&lq->lock);
8010338f:	89 3c 24             	mov    %edi,(%esp)
80103392:	e8 d8 0f 00 00       	call   8010436f <acquire>
      lq->numproc = 0;
80103397:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010339a:	c7 80 d0 3e 11 80 00 	movl   $0x0,-0x7feec130(%eax)
801033a1:	00 00 00 
      lq->ticks_left = RSDL_LEVEL_QUANTUM;
801033a4:	c7 80 d4 3e 11 80 64 	movl   $0x64,-0x7feec12c(%eax)
801033ab:	00 00 00 
      for (int i = 0; i < NPROC; ++i){
801033ae:	83 c4 10             	add    $0x10,%esp
801033b1:	b8 00 00 00 00       	mov    $0x0,%eax
801033b6:	eb 99                	jmp    80103351 <pinit+0x51>
  for (int s = 0; s < 2; ++s) {
801033b8:	83 c6 01             	add    $0x1,%esi
801033bb:	83 fe 01             	cmp    $0x1,%esi
801033be:	7f 07                	jg     801033c7 <pinit+0xc7>
    for (int k = 0; k < RSDL_LEVELS; ++k){
801033c0:	bb 00 00 00 00       	mov    $0x0,%ebx
801033c5:	eb 9e                	jmp    80103365 <pinit+0x65>
  ptable.active = ptable.level[0];
801033c7:	c7 05 94 3e 11 80 9c 	movl   $0x80113e9c,0x80113e94
801033ce:	3e 11 80 
  ptable.expired = ptable.level[1];
801033d1:	c7 05 98 3e 11 80 50 	movl   $0x80114250,0x80113e98
801033d8:	42 11 80 
  release(&ptable.lock);
801033db:	83 ec 0c             	sub    $0xc,%esp
801033de:	68 60 1d 11 80       	push   $0x80111d60
801033e3:	e8 ec 0f 00 00       	call   801043d4 <release>
}
801033e8:	83 c4 10             	add    $0x10,%esp
801033eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801033ee:	5b                   	pop    %ebx
801033ef:	5e                   	pop    %esi
801033f0:	5f                   	pop    %edi
801033f1:	5d                   	pop    %ebp
801033f2:	c3                   	ret    

801033f3 <mycpu>:
{
801033f3:	55                   	push   %ebp
801033f4:	89 e5                	mov    %esp,%ebp
801033f6:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801033f9:	9c                   	pushf  
801033fa:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801033fb:	f6 c4 02             	test   $0x2,%ah
801033fe:	75 28                	jne    80103428 <mycpu+0x35>
  apicid = lapicid();
80103400:	e8 8d ef ff ff       	call   80102392 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103405:	ba 00 00 00 00       	mov    $0x0,%edx
8010340a:	39 15 84 17 11 80    	cmp    %edx,0x80111784
80103410:	7e 23                	jle    80103435 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
80103412:	69 ca b4 00 00 00    	imul   $0xb4,%edx,%ecx
80103418:	0f b6 89 a0 17 11 80 	movzbl -0x7feee860(%ecx),%ecx
8010341f:	39 c1                	cmp    %eax,%ecx
80103421:	74 1f                	je     80103442 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
80103423:	83 c2 01             	add    $0x1,%edx
80103426:	eb e2                	jmp    8010340a <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
80103428:	83 ec 0c             	sub    $0xc,%esp
8010342b:	68 e0 76 10 80       	push   $0x801076e0
80103430:	e8 13 cf ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103435:	83 ec 0c             	sub    $0xc,%esp
80103438:	68 76 75 10 80       	push   $0x80107576
8010343d:	e8 06 cf ff ff       	call   80100348 <panic>
      return &cpus[i];
80103442:	69 c2 b4 00 00 00    	imul   $0xb4,%edx,%eax
80103448:	05 a0 17 11 80       	add    $0x801117a0,%eax
}
8010344d:	c9                   	leave  
8010344e:	c3                   	ret    

8010344f <cpuid>:
cpuid() {
8010344f:	55                   	push   %ebp
80103450:	89 e5                	mov    %esp,%ebp
80103452:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103455:	e8 99 ff ff ff       	call   801033f3 <mycpu>
8010345a:	2d a0 17 11 80       	sub    $0x801117a0,%eax
8010345f:	c1 f8 02             	sar    $0x2,%eax
80103462:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
}
80103468:	c9                   	leave  
80103469:	c3                   	ret    

8010346a <myproc>:
myproc(void) {
8010346a:	55                   	push   %ebp
8010346b:	89 e5                	mov    %esp,%ebp
8010346d:	53                   	push   %ebx
8010346e:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103471:	e8 1e 0e 00 00       	call   80104294 <pushcli>
  c = mycpu();
80103476:	e8 78 ff ff ff       	call   801033f3 <mycpu>
  p = c->proc;
8010347b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103481:	e8 4a 0e 00 00       	call   801042d0 <popcli>
}
80103486:	89 d8                	mov    %ebx,%eax
80103488:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010348b:	c9                   	leave  
8010348c:	c3                   	ret    

8010348d <enqueue_proc>:
{
8010348d:	55                   	push   %ebp
8010348e:	89 e5                	mov    %esp,%ebp
80103490:	56                   	push   %esi
80103491:	53                   	push   %ebx
80103492:	8b 75 08             	mov    0x8(%ebp),%esi
80103495:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if (p == NULL) {
80103498:	85 f6                	test   %esi,%esi
8010349a:	74 35                	je     801034d1 <enqueue_proc+0x44>
  if (q == NULL) {
8010349c:	85 db                	test   %ebx,%ebx
8010349e:	74 3e                	je     801034de <enqueue_proc+0x51>
  acquire(&q->lock);
801034a0:	83 ec 0c             	sub    $0xc,%esp
801034a3:	53                   	push   %ebx
801034a4:	e8 c6 0e 00 00       	call   8010436f <acquire>
  if (q->numproc >= NPROC) {
801034a9:	8b 43 34             	mov    0x34(%ebx),%eax
801034ac:	83 c4 10             	add    $0x10,%esp
801034af:	83 f8 3f             	cmp    $0x3f,%eax
801034b2:	7f 37                	jg     801034eb <enqueue_proc+0x5e>
    q->proc[q->numproc++] = p;
801034b4:	8d 50 01             	lea    0x1(%eax),%edx
801034b7:	89 53 34             	mov    %edx,0x34(%ebx)
801034ba:	89 74 83 3c          	mov    %esi,0x3c(%ebx,%eax,4)
  release(&q->lock);
801034be:	83 ec 0c             	sub    $0xc,%esp
801034c1:	53                   	push   %ebx
801034c2:	e8 0d 0f 00 00       	call   801043d4 <release>
801034c7:	83 c4 10             	add    $0x10,%esp
}
801034ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
801034cd:	5b                   	pop    %ebx
801034ce:	5e                   	pop    %esi
801034cf:	5d                   	pop    %ebp
801034d0:	c3                   	ret    
    panic("enqueue of NULL proc node");
801034d1:	83 ec 0c             	sub    $0xc,%esp
801034d4:	68 86 75 10 80       	push   $0x80107586
801034d9:	e8 6a ce ff ff       	call   80100348 <panic>
    panic("enqueue in NULL queue");
801034de:	83 ec 0c             	sub    $0xc,%esp
801034e1:	68 a0 75 10 80       	push   $0x801075a0
801034e6:	e8 5d ce ff ff       	call   80100348 <panic>
    panic("enqueue in full level");
801034eb:	83 ec 0c             	sub    $0xc,%esp
801034ee:	68 b6 75 10 80       	push   $0x801075b6
801034f3:	e8 50 ce ff ff       	call   80100348 <panic>

801034f8 <unqueue_proc_full>:
{
801034f8:	55                   	push   %ebp
801034f9:	89 e5                	mov    %esp,%ebp
801034fb:	57                   	push   %edi
801034fc:	56                   	push   %esi
801034fd:	53                   	push   %ebx
801034fe:	83 ec 0c             	sub    $0xc,%esp
80103501:	8b 7d 08             	mov    0x8(%ebp),%edi
80103504:	8b 75 0c             	mov    0xc(%ebp),%esi
  if (q == NULL) {
80103507:	85 f6                	test   %esi,%esi
80103509:	74 1b                	je     80103526 <unqueue_proc_full+0x2e>
  if (q->numproc == 0) {
8010350b:	83 7e 34 00          	cmpl   $0x0,0x34(%esi)
8010350f:	75 2f                	jne    80103540 <unqueue_proc_full+0x48>
    if (!isTry) {
80103511:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80103515:	74 1c                	je     80103533 <unqueue_proc_full+0x3b>
    return -1;
80103517:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
8010351c:	89 d8                	mov    %ebx,%eax
8010351e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103521:	5b                   	pop    %ebx
80103522:	5e                   	pop    %esi
80103523:	5f                   	pop    %edi
80103524:	5d                   	pop    %ebp
80103525:	c3                   	ret    
    panic("unqueue in NULL queue");
80103526:	83 ec 0c             	sub    $0xc,%esp
80103529:	68 cc 75 10 80       	push   $0x801075cc
8010352e:	e8 15 ce ff ff       	call   80100348 <panic>
      panic("unqueue on empty level");
80103533:	83 ec 0c             	sub    $0xc,%esp
80103536:	68 e2 75 10 80       	push   $0x801075e2
8010353b:	e8 08 ce ff ff       	call   80100348 <panic>
  acquire(&q->lock);
80103540:	83 ec 0c             	sub    $0xc,%esp
80103543:	56                   	push   %esi
80103544:	e8 26 0e 00 00       	call   8010436f <acquire>
  for (i = 0; i < q->numproc; ++i) {
80103549:	83 c4 10             	add    $0x10,%esp
8010354c:	bb 00 00 00 00       	mov    $0x0,%ebx
80103551:	8b 46 34             	mov    0x34(%esi),%eax
80103554:	39 d8                	cmp    %ebx,%eax
80103556:	7e 0b                	jle    80103563 <unqueue_proc_full+0x6b>
    if (q->proc[i] == p) {
80103558:	39 7c 9e 3c          	cmp    %edi,0x3c(%esi,%ebx,4)
8010355c:	74 13                	je     80103571 <unqueue_proc_full+0x79>
  for (i = 0; i < q->numproc; ++i) {
8010355e:	83 c3 01             	add    $0x1,%ebx
80103561:	eb ee                	jmp    80103551 <unqueue_proc_full+0x59>
  int found = 0;
80103563:	bf 00 00 00 00       	mov    $0x0,%edi
  if (found) {
80103568:	85 ff                	test   %edi,%edi
8010356a:	74 21                	je     8010358d <unqueue_proc_full+0x95>
    for (j = i+1; j < q->numproc; ++j) {
8010356c:	8d 53 01             	lea    0x1(%ebx),%edx
8010356f:	eb 12                	jmp    80103583 <unqueue_proc_full+0x8b>
      found = 1;
80103571:	bf 01 00 00 00       	mov    $0x1,%edi
80103576:	eb f0                	jmp    80103568 <unqueue_proc_full+0x70>
      q->proc[j-1] = q->proc[j];
80103578:	8b 4c 96 3c          	mov    0x3c(%esi,%edx,4),%ecx
8010357c:	89 4c 96 38          	mov    %ecx,0x38(%esi,%edx,4)
    for (j = i+1; j < q->numproc; ++j) {
80103580:	83 c2 01             	add    $0x1,%edx
80103583:	39 d0                	cmp    %edx,%eax
80103585:	7f f1                	jg     80103578 <unqueue_proc_full+0x80>
    q->numproc--;   // decrement number of procs in this level
80103587:	83 e8 01             	sub    $0x1,%eax
8010358a:	89 46 34             	mov    %eax,0x34(%esi)
  release(&q->lock);
8010358d:	83 ec 0c             	sub    $0xc,%esp
80103590:	56                   	push   %esi
80103591:	e8 3e 0e 00 00       	call   801043d4 <release>
  if (!found) {
80103596:	83 c4 10             	add    $0x10,%esp
80103599:	85 ff                	test   %edi,%edi
8010359b:	0f 85 7b ff ff ff    	jne    8010351c <unqueue_proc_full+0x24>
    if (!isTry) {
801035a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801035a5:	74 0a                	je     801035b1 <unqueue_proc_full+0xb9>
    return -1;
801035a7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801035ac:	e9 6b ff ff ff       	jmp    8010351c <unqueue_proc_full+0x24>
      panic("unqueue of node not belonging to level");
801035b1:	83 ec 0c             	sub    $0xc,%esp
801035b4:	68 08 77 10 80       	push   $0x80107708
801035b9:	e8 8a cd ff ff       	call   80100348 <panic>

801035be <unqueue_proc>:
{
801035be:	55                   	push   %ebp
801035bf:	89 e5                	mov    %esp,%ebp
801035c1:	83 ec 0c             	sub    $0xc,%esp
  return unqueue_proc_full(p, q, 0);
801035c4:	6a 00                	push   $0x0
801035c6:	ff 75 0c             	push   0xc(%ebp)
801035c9:	ff 75 08             	push   0x8(%ebp)
801035cc:	e8 27 ff ff ff       	call   801034f8 <unqueue_proc_full>
}
801035d1:	c9                   	leave  
801035d2:	c3                   	ret    

801035d3 <try_unqueue_proc>:
{
801035d3:	55                   	push   %ebp
801035d4:	89 e5                	mov    %esp,%ebp
801035d6:	83 ec 0c             	sub    $0xc,%esp
  return unqueue_proc_full(p, q, 1);
801035d9:	6a 01                	push   $0x1
801035db:	ff 75 0c             	push   0xc(%ebp)
801035de:	ff 75 08             	push   0x8(%ebp)
801035e1:	e8 12 ff ff ff       	call   801034f8 <unqueue_proc_full>
}
801035e6:	c9                   	leave  
801035e7:	c3                   	ret    

801035e8 <remove_proc_from_levels>:
{
801035e8:	55                   	push   %ebp
801035e9:	89 e5                	mov    %esp,%ebp
801035eb:	57                   	push   %edi
801035ec:	56                   	push   %esi
801035ed:	53                   	push   %ebx
801035ee:	83 ec 1c             	sub    $0x1c,%esp
801035f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  for (int s = 0; s < 2; ++s) {
801035f4:	be 00 00 00 00       	mov    $0x0,%esi
  int found = 0;
801035f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  for (int s = 0; s < 2; ++s) {
80103600:	eb 10                	jmp    80103612 <remove_proc_from_levels+0x2a>
        found = 1;
80103602:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
    if (found)
80103609:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010360d:	75 3c                	jne    8010364b <remove_proc_from_levels+0x63>
  for (int s = 0; s < 2; ++s) {
8010360f:	83 c6 01             	add    $0x1,%esi
80103612:	83 fe 01             	cmp    $0x1,%esi
80103615:	7f 34                	jg     8010364b <remove_proc_from_levels+0x63>
    for (int k = 0; k < RSDL_LEVELS; ++k){
80103617:	bb 00 00 00 00       	mov    $0x0,%ebx
8010361c:	83 fb 02             	cmp    $0x2,%ebx
8010361f:	7f e8                	jg     80103609 <remove_proc_from_levels+0x21>
      q = &ptable.level[s][k];
80103621:	69 d3 3c 01 00 00    	imul   $0x13c,%ebx,%edx
80103627:	69 c6 b4 03 00 00    	imul   $0x3b4,%esi,%eax
8010362d:	8d 84 02 9c 3e 11 80 	lea    -0x7feec164(%edx,%eax,1),%eax
      if (try_unqueue_proc(p, q) != -1) {
80103634:	83 ec 08             	sub    $0x8,%esp
80103637:	50                   	push   %eax
80103638:	57                   	push   %edi
80103639:	e8 95 ff ff ff       	call   801035d3 <try_unqueue_proc>
8010363e:	83 c4 10             	add    $0x10,%esp
80103641:	83 f8 ff             	cmp    $0xffffffff,%eax
80103644:	75 bc                	jne    80103602 <remove_proc_from_levels+0x1a>
    for (int k = 0; k < RSDL_LEVELS; ++k){
80103646:	83 c3 01             	add    $0x1,%ebx
80103649:	eb d1                	jmp    8010361c <remove_proc_from_levels+0x34>
  if (!found) {
8010364b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010364f:	74 0d                	je     8010365e <remove_proc_from_levels+0x76>
  return 0;
80103651:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103656:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103659:	5b                   	pop    %ebx
8010365a:	5e                   	pop    %esi
8010365b:	5f                   	pop    %edi
8010365c:	5d                   	pop    %ebp
8010365d:	c3                   	ret    
    return -1;
8010365e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103663:	eb f1                	jmp    80103656 <remove_proc_from_levels+0x6e>

80103665 <next_level>:
{
80103665:	55                   	push   %ebp
80103666:	89 e5                	mov    %esp,%ebp
80103668:	8b 45 08             	mov    0x8(%ebp),%eax
  const struct level_queue *set = (use_expired) ? ptable.expired : ptable.active;
8010366b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010366f:	74 11                	je     80103682 <next_level+0x1d>
80103671:	8b 0d 98 3e 11 80    	mov    0x80113e98,%ecx
  if (start < 0)
80103677:	85 c0                	test   %eax,%eax
80103679:	79 12                	jns    8010368d <next_level+0x28>
    return -1;
8010367b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103680:	eb 29                	jmp    801036ab <next_level+0x46>
  const struct level_queue *set = (use_expired) ? ptable.expired : ptable.active;
80103682:	8b 0d 94 3e 11 80    	mov    0x80113e94,%ecx
80103688:	eb ed                	jmp    80103677 <next_level+0x12>
  for ( ; k < RSDL_LEVELS; ++k) {
8010368a:	83 c0 01             	add    $0x1,%eax
8010368d:	83 f8 02             	cmp    $0x2,%eax
80103690:	7f 14                	jg     801036a6 <next_level+0x41>
    if (set[k].ticks_left > 0 && set[k].numproc < NPROC) {
80103692:	69 d0 3c 01 00 00    	imul   $0x13c,%eax,%edx
80103698:	01 ca                	add    %ecx,%edx
8010369a:	83 7a 38 00          	cmpl   $0x0,0x38(%edx)
8010369e:	7e ea                	jle    8010368a <next_level+0x25>
801036a0:	83 7a 34 3f          	cmpl   $0x3f,0x34(%edx)
801036a4:	7f e4                	jg     8010368a <next_level+0x25>
  if (k < RSDL_LEVELS) {
801036a6:	83 f8 02             	cmp    $0x2,%eax
801036a9:	7f 02                	jg     801036ad <next_level+0x48>
}
801036ab:	5d                   	pop    %ebp
801036ac:	c3                   	ret    
    return -1;
801036ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801036b2:	eb f7                	jmp    801036ab <next_level+0x46>

801036b4 <next_active_level>:
{
801036b4:	55                   	push   %ebp
801036b5:	89 e5                	mov    %esp,%ebp
801036b7:	83 ec 10             	sub    $0x10,%esp
  return next_level(start, 0);
801036ba:	6a 00                	push   $0x0
801036bc:	ff 75 08             	push   0x8(%ebp)
801036bf:	e8 a1 ff ff ff       	call   80103665 <next_level>
801036c4:	83 c4 10             	add    $0x10,%esp
}
801036c7:	c9                   	leave  
801036c8:	c3                   	ret    

801036c9 <next_expired_level>:
{
801036c9:	55                   	push   %ebp
801036ca:	89 e5                	mov    %esp,%ebp
801036cc:	83 ec 10             	sub    $0x10,%esp
  return next_level(start, 1);
801036cf:	6a 01                	push   $0x1
801036d1:	ff 75 08             	push   0x8(%ebp)
801036d4:	e8 8c ff ff ff       	call   80103665 <next_level>
801036d9:	83 c4 10             	add    $0x10,%esp
}
801036dc:	c9                   	leave  
801036dd:	c3                   	ret    

801036de <find_available_queue>:
{
801036de:	55                   	push   %ebp
801036df:	89 e5                	mov    %esp,%ebp
801036e1:	83 ec 14             	sub    $0x14,%esp
  int level = next_active_level(active_start);
801036e4:	ff 75 08             	push   0x8(%ebp)
801036e7:	e8 c8 ff ff ff       	call   801036b4 <next_active_level>
801036ec:	83 c4 10             	add    $0x10,%esp
  if (level == -1) {  // no lower prio level available
801036ef:	83 f8 ff             	cmp    $0xffffffff,%eax
801036f2:	74 0e                	je     80103702 <find_available_queue+0x24>
  return &ptable.active[level];
801036f4:	69 c0 3c 01 00 00    	imul   $0x13c,%eax,%eax
801036fa:	03 05 94 3e 11 80    	add    0x80113e94,%eax
}
80103700:	c9                   	leave  
80103701:	c3                   	ret    
    level = next_expired_level(expired_start);
80103702:	83 ec 0c             	sub    $0xc,%esp
80103705:	ff 75 0c             	push   0xc(%ebp)
80103708:	e8 bc ff ff ff       	call   801036c9 <next_expired_level>
8010370d:	83 c4 10             	add    $0x10,%esp
    if (level == -1) {
80103710:	83 f8 ff             	cmp    $0xffffffff,%eax
80103713:	74 0e                	je     80103723 <find_available_queue+0x45>
    return &ptable.expired[level];
80103715:	69 c0 3c 01 00 00    	imul   $0x13c,%eax,%eax
8010371b:	03 05 98 3e 11 80    	add    0x80113e98,%eax
80103721:	eb dd                	jmp    80103700 <find_available_queue+0x22>
      panic("No free level in expired and active set, too many procs");
80103723:	83 ec 0c             	sub    $0xc,%esp
80103726:	68 30 77 10 80       	push   $0x80107730
8010372b:	e8 18 cc ff ff       	call   80100348 <panic>

80103730 <userinit>:
{
80103730:	55                   	push   %ebp
80103731:	89 e5                	mov    %esp,%ebp
80103733:	53                   	push   %ebx
80103734:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103737:	e8 4f f9 ff ff       	call   8010308b <allocproc>
8010373c:	89 c3                	mov    %eax,%ebx
  initproc = p;
8010373e:	a3 04 46 11 80       	mov    %eax,0x80114604
  if((p->pgdir = setupkvm()) == 0)
80103743:	e8 5f 35 00 00       	call   80106ca7 <setupkvm>
80103748:	89 43 04             	mov    %eax,0x4(%ebx)
8010374b:	85 c0                	test   %eax,%eax
8010374d:	0f 84 d2 00 00 00    	je     80103825 <userinit+0xf5>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103753:	83 ec 04             	sub    $0x4,%esp
80103756:	68 2c 00 00 00       	push   $0x2c
8010375b:	68 60 a4 10 80       	push   $0x8010a460
80103760:	50                   	push   %eax
80103761:	e8 e7 31 00 00       	call   8010694d <inituvm>
  p->sz = PGSIZE;
80103766:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010376c:	8b 43 18             	mov    0x18(%ebx),%eax
8010376f:	83 c4 0c             	add    $0xc,%esp
80103772:	6a 4c                	push   $0x4c
80103774:	6a 00                	push   $0x0
80103776:	50                   	push   %eax
80103777:	e8 9f 0c 00 00       	call   8010441b <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010377c:	8b 43 18             	mov    0x18(%ebx),%eax
8010377f:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103785:	8b 43 18             	mov    0x18(%ebx),%eax
80103788:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010378e:	8b 43 18             	mov    0x18(%ebx),%eax
80103791:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103795:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103799:	8b 43 18             	mov    0x18(%ebx),%eax
8010379c:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801037a0:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801037a4:	8b 43 18             	mov    0x18(%ebx),%eax
801037a7:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801037ae:	8b 43 18             	mov    0x18(%ebx),%eax
801037b1:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801037b8:	8b 43 18             	mov    0x18(%ebx),%eax
801037bb:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801037c2:	8d 43 6c             	lea    0x6c(%ebx),%eax
801037c5:	83 c4 0c             	add    $0xc,%esp
801037c8:	6a 10                	push   $0x10
801037ca:	68 12 76 10 80       	push   $0x80107612
801037cf:	50                   	push   %eax
801037d0:	e8 b2 0d 00 00       	call   80104587 <safestrcpy>
  p->cwd = namei("/");
801037d5:	c7 04 24 1b 76 10 80 	movl   $0x8010761b,(%esp)
801037dc:	e8 ec e3 ff ff       	call   80101bcd <namei>
801037e1:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
801037e4:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
801037eb:	e8 7f 0b 00 00       	call   8010436f <acquire>
  p->state = RUNNABLE;
801037f0:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  struct level_queue *q = find_available_queue(p->default_level, p->default_level);
801037f7:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
801037fd:	83 c4 08             	add    $0x8,%esp
80103800:	50                   	push   %eax
80103801:	50                   	push   %eax
80103802:	e8 d7 fe ff ff       	call   801036de <find_available_queue>
80103807:	83 c4 08             	add    $0x8,%esp
  enqueue_proc(p, q);
8010380a:	50                   	push   %eax
8010380b:	53                   	push   %ebx
8010380c:	e8 7c fc ff ff       	call   8010348d <enqueue_proc>
  release(&ptable.lock);
80103811:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
80103818:	e8 b7 0b 00 00       	call   801043d4 <release>
}
8010381d:	83 c4 10             	add    $0x10,%esp
80103820:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103823:	c9                   	leave  
80103824:	c3                   	ret    
    panic("userinit: out of memory?");
80103825:	83 ec 0c             	sub    $0xc,%esp
80103828:	68 f9 75 10 80       	push   $0x801075f9
8010382d:	e8 16 cb ff ff       	call   80100348 <panic>

80103832 <growproc>:
{
80103832:	55                   	push   %ebp
80103833:	89 e5                	mov    %esp,%ebp
80103835:	56                   	push   %esi
80103836:	53                   	push   %ebx
80103837:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
8010383a:	e8 2b fc ff ff       	call   8010346a <myproc>
8010383f:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
80103841:	8b 00                	mov    (%eax),%eax
  if(n > 0){
80103843:	85 f6                	test   %esi,%esi
80103845:	7f 1c                	jg     80103863 <growproc+0x31>
  } else if(n < 0){
80103847:	78 37                	js     80103880 <growproc+0x4e>
  curproc->sz = sz;
80103849:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
8010384b:	83 ec 0c             	sub    $0xc,%esp
8010384e:	53                   	push   %ebx
8010384f:	e8 85 2f 00 00       	call   801067d9 <switchuvm>
  return 0;
80103854:	83 c4 10             	add    $0x10,%esp
80103857:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010385c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010385f:	5b                   	pop    %ebx
80103860:	5e                   	pop    %esi
80103861:	5d                   	pop    %ebp
80103862:	c3                   	ret    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103863:	83 ec 04             	sub    $0x4,%esp
80103866:	01 c6                	add    %eax,%esi
80103868:	56                   	push   %esi
80103869:	50                   	push   %eax
8010386a:	ff 73 04             	push   0x4(%ebx)
8010386d:	e8 b1 32 00 00       	call   80106b23 <allocuvm>
80103872:	83 c4 10             	add    $0x10,%esp
80103875:	85 c0                	test   %eax,%eax
80103877:	75 d0                	jne    80103849 <growproc+0x17>
      return -1;
80103879:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010387e:	eb dc                	jmp    8010385c <growproc+0x2a>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103880:	83 ec 04             	sub    $0x4,%esp
80103883:	01 c6                	add    %eax,%esi
80103885:	56                   	push   %esi
80103886:	50                   	push   %eax
80103887:	ff 73 04             	push   0x4(%ebx)
8010388a:	e8 ee 31 00 00       	call   80106a7d <deallocuvm>
8010388f:	83 c4 10             	add    $0x10,%esp
80103892:	85 c0                	test   %eax,%eax
80103894:	75 b3                	jne    80103849 <growproc+0x17>
      return -1;
80103896:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010389b:	eb bf                	jmp    8010385c <growproc+0x2a>

8010389d <priofork>:
{
8010389d:	55                   	push   %ebp
8010389e:	89 e5                	mov    %esp,%ebp
801038a0:	57                   	push   %edi
801038a1:	56                   	push   %esi
801038a2:	53                   	push   %ebx
801038a3:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801038a6:	e8 bf fb ff ff       	call   8010346a <myproc>
  if (default_level >= RSDL_LEVELS) {
801038ab:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
801038af:	0f 8f 1b 01 00 00    	jg     801039d0 <priofork+0x133>
801038b5:	89 c3                	mov    %eax,%ebx
  if (default_level < 0) {
801038b7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801038bb:	0f 88 16 01 00 00    	js     801039d7 <priofork+0x13a>
  if((np = allocproc()) == 0){
801038c1:	e8 c5 f7 ff ff       	call   8010308b <allocproc>
801038c6:	89 c7                	mov    %eax,%edi
801038c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801038cb:	85 c0                	test   %eax,%eax
801038cd:	0f 84 0b 01 00 00    	je     801039de <priofork+0x141>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801038d3:	83 ec 08             	sub    $0x8,%esp
801038d6:	ff 33                	push   (%ebx)
801038d8:	ff 73 04             	push   0x4(%ebx)
801038db:	e8 78 34 00 00       	call   80106d58 <copyuvm>
801038e0:	89 47 04             	mov    %eax,0x4(%edi)
801038e3:	83 c4 10             	add    $0x10,%esp
801038e6:	85 c0                	test   %eax,%eax
801038e8:	74 2c                	je     80103916 <priofork+0x79>
  np->sz = curproc->sz;
801038ea:	8b 03                	mov    (%ebx),%eax
801038ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801038ef:	89 07                	mov    %eax,(%edi)
  np->parent = curproc;
801038f1:	89 f8                	mov    %edi,%eax
801038f3:	89 5f 14             	mov    %ebx,0x14(%edi)
  *np->tf = *curproc->tf;
801038f6:	8b 73 18             	mov    0x18(%ebx),%esi
801038f9:	8b 7f 18             	mov    0x18(%edi),%edi
801038fc:	b9 13 00 00 00       	mov    $0x13,%ecx
80103901:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
80103903:	89 c7                	mov    %eax,%edi
80103905:	8b 40 18             	mov    0x18(%eax),%eax
80103908:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
8010390f:	be 00 00 00 00       	mov    $0x0,%esi
80103914:	eb 3c                	jmp    80103952 <priofork+0xb5>
    kfree(np->kstack);
80103916:	83 ec 0c             	sub    $0xc,%esp
80103919:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010391c:	ff 73 08             	push   0x8(%ebx)
8010391f:	e8 68 e6 ff ff       	call   80101f8c <kfree>
    np->kstack = 0;
80103924:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
8010392b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103932:	83 c4 10             	add    $0x10,%esp
80103935:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010393a:	e9 87 00 00 00       	jmp    801039c6 <priofork+0x129>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010393f:	83 ec 0c             	sub    $0xc,%esp
80103942:	50                   	push   %eax
80103943:	e8 36 d3 ff ff       	call   80100c7e <filedup>
80103948:	89 44 b7 28          	mov    %eax,0x28(%edi,%esi,4)
8010394c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NOFILE; i++)
8010394f:	83 c6 01             	add    $0x1,%esi
80103952:	83 fe 0f             	cmp    $0xf,%esi
80103955:	7f 0a                	jg     80103961 <priofork+0xc4>
    if(curproc->ofile[i])
80103957:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
8010395b:	85 c0                	test   %eax,%eax
8010395d:	75 e0                	jne    8010393f <priofork+0xa2>
8010395f:	eb ee                	jmp    8010394f <priofork+0xb2>
  np->cwd = idup(curproc->cwd);
80103961:	83 ec 0c             	sub    $0xc,%esp
80103964:	ff 73 68             	push   0x68(%ebx)
80103967:	e8 d3 db ff ff       	call   8010153f <idup>
8010396c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010396f:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103972:	83 c3 6c             	add    $0x6c,%ebx
80103975:	8d 47 6c             	lea    0x6c(%edi),%eax
80103978:	83 c4 0c             	add    $0xc,%esp
8010397b:	6a 10                	push   $0x10
8010397d:	53                   	push   %ebx
8010397e:	50                   	push   %eax
8010397f:	e8 03 0c 00 00       	call   80104587 <safestrcpy>
  pid = np->pid;
80103984:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
80103987:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
8010398e:	e8 dc 09 00 00       	call   8010436f <acquire>
  np->default_level = default_level;  // set priority level
80103993:	8b 45 08             	mov    0x8(%ebp),%eax
80103996:	89 87 80 00 00 00    	mov    %eax,0x80(%edi)
  np->state = RUNNABLE;
8010399c:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  struct level_queue *q = find_available_queue(np->default_level, np->default_level);
801039a3:	83 c4 08             	add    $0x8,%esp
801039a6:	50                   	push   %eax
801039a7:	50                   	push   %eax
801039a8:	e8 31 fd ff ff       	call   801036de <find_available_queue>
801039ad:	83 c4 08             	add    $0x8,%esp
  enqueue_proc(np, q);
801039b0:	50                   	push   %eax
801039b1:	57                   	push   %edi
801039b2:	e8 d6 fa ff ff       	call   8010348d <enqueue_proc>
  release(&ptable.lock);
801039b7:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
801039be:	e8 11 0a 00 00       	call   801043d4 <release>
  return pid;
801039c3:	83 c4 10             	add    $0x10,%esp
}
801039c6:	89 d8                	mov    %ebx,%eax
801039c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801039cb:	5b                   	pop    %ebx
801039cc:	5e                   	pop    %esi
801039cd:	5f                   	pop    %edi
801039ce:	5d                   	pop    %ebp
801039cf:	c3                   	ret    
    return -1;
801039d0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801039d5:	eb ef                	jmp    801039c6 <priofork+0x129>
    return -1;
801039d7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801039dc:	eb e8                	jmp    801039c6 <priofork+0x129>
    return -1;
801039de:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801039e3:	eb e1                	jmp    801039c6 <priofork+0x129>

801039e5 <fork>:
{
801039e5:	55                   	push   %ebp
801039e6:	89 e5                	mov    %esp,%ebp
801039e8:	83 ec 14             	sub    $0x14,%esp
  return priofork(RSDL_STARTING_LEVEL);
801039eb:	6a 00                	push   $0x0
801039ed:	e8 ab fe ff ff       	call   8010389d <priofork>
}
801039f2:	c9                   	leave  
801039f3:	c3                   	ret    

801039f4 <scheduler>:
{
801039f4:	55                   	push   %ebp
801039f5:	89 e5                	mov    %esp,%ebp
801039f7:	57                   	push   %edi
801039f8:	56                   	push   %esi
801039f9:	53                   	push   %ebx
801039fa:	83 ec 1c             	sub    $0x1c,%esp
  struct cpu *c = mycpu();
801039fd:	e8 f1 f9 ff ff       	call   801033f3 <mycpu>
80103a02:	89 45 e0             	mov    %eax,-0x20(%ebp)
  c->proc = 0;
80103a05:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103a0c:	00 00 00 
  struct level_queue *q = NULL;
80103a0f:	bf 00 00 00 00       	mov    $0x0,%edi
  struct proc *p = NULL;
80103a14:	bb 00 00 00 00       	mov    $0x0,%ebx
80103a19:	e9 74 01 00 00       	jmp    80103b92 <scheduler+0x19e>
      for (i = 0; i < q->numproc; ++i ) {
80103a1e:	83 c0 01             	add    $0x1,%eax
80103a21:	39 47 34             	cmp    %eax,0x34(%edi)
80103a24:	7e 17                	jle    80103a3d <scheduler+0x49>
        p = q->proc[i];
80103a26:	8b 5c 87 3c          	mov    0x3c(%edi,%eax,4),%ebx
        if(p->state == RUNNABLE && p->ticks_left > 0) {
80103a2a:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103a2e:	75 ee                	jne    80103a1e <scheduler+0x2a>
80103a30:	83 7b 7c 00          	cmpl   $0x0,0x7c(%ebx)
80103a34:	7e e8                	jle    80103a1e <scheduler+0x2a>
          found = 1;
80103a36:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
      release(&q->lock);
80103a3d:	83 ec 0c             	sub    $0xc,%esp
80103a40:	ff 75 dc             	push   -0x24(%ebp)
80103a43:	e8 8c 09 00 00       	call   801043d4 <release>
      if (found)
80103a48:	83 c4 10             	add    $0x10,%esp
80103a4b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80103a4f:	75 30                	jne    80103a81 <scheduler+0x8d>
    for (k = 0; k < RSDL_LEVELS; ++k) {
80103a51:	83 c6 01             	add    $0x1,%esi
80103a54:	83 fe 02             	cmp    $0x2,%esi
80103a57:	7f 28                	jg     80103a81 <scheduler+0x8d>
      q = &ptable.active[k];
80103a59:	69 fe 3c 01 00 00    	imul   $0x13c,%esi,%edi
80103a5f:	03 3d 94 3e 11 80    	add    0x80113e94,%edi
      if (q->ticks_left <= 0)
80103a65:	83 7f 38 00          	cmpl   $0x0,0x38(%edi)
80103a69:	7e e6                	jle    80103a51 <scheduler+0x5d>
      acquire(&q->lock);
80103a6b:	89 7d dc             	mov    %edi,-0x24(%ebp)
80103a6e:	83 ec 0c             	sub    $0xc,%esp
80103a71:	57                   	push   %edi
80103a72:	e8 f8 08 00 00       	call   8010436f <acquire>
      for (i = 0; i < q->numproc; ++i ) {
80103a77:	83 c4 10             	add    $0x10,%esp
80103a7a:	b8 00 00 00 00       	mov    $0x0,%eax
80103a7f:	eb a0                	jmp    80103a21 <scheduler+0x2d>
    if (schedlog_active && ticks > schedlog_lasttick) {
80103a81:	83 3d 44 1d 11 80 00 	cmpl   $0x0,0x80111d44
80103a88:	74 17                	je     80103aa1 <scheduler+0xad>
80103a8a:	a1 40 1d 11 80       	mov    0x80111d40,%eax
80103a8f:	39 05 20 46 11 80    	cmp    %eax,0x80114620
80103a95:	76 0a                	jbe    80103aa1 <scheduler+0xad>
        schedlog_active = 0;
80103a97:	c7 05 44 1d 11 80 00 	movl   $0x0,0x80111d44
80103a9e:	00 00 00 
    if (found) {
80103aa1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80103aa5:	0f 84 a8 01 00 00    	je     80103c53 <scheduler+0x25f>
      c->proc = p;
80103aab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103aae:	89 98 ac 00 00 00    	mov    %ebx,0xac(%eax)
      c->queue = q;
80103ab4:	89 b8 b0 00 00 00    	mov    %edi,0xb0(%eax)
      switchuvm(p);
80103aba:	83 ec 0c             	sub    $0xc,%esp
80103abd:	53                   	push   %ebx
80103abe:	e8 16 2d 00 00       	call   801067d9 <switchuvm>
      p->state = RUNNING;
80103ac3:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      if (schedlog_active && ticks <= schedlog_lasttick) {
80103aca:	83 c4 10             	add    $0x10,%esp
80103acd:	83 3d 44 1d 11 80 00 	cmpl   $0x0,0x80111d44
80103ad4:	74 11                	je     80103ae7 <scheduler+0xf3>
80103ad6:	a1 40 1d 11 80       	mov    0x80111d40,%eax
80103adb:	39 05 20 46 11 80    	cmp    %eax,0x80114620
80103ae1:	0f 86 cd 00 00 00    	jbe    80103bb4 <scheduler+0x1c0>
      swtch(&(c->scheduler), p->context);
80103ae7:	83 ec 08             	sub    $0x8,%esp
80103aea:	ff 73 1c             	push   0x1c(%ebx)
80103aed:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103af0:	83 c0 04             	add    $0x4,%eax
80103af3:	50                   	push   %eax
80103af4:	e8 e3 0a 00 00       	call   801045dc <swtch>
      switchkvm();
80103af9:	e8 b6 2c 00 00       	call   801067b4 <switchkvm>
      if (q->ticks_left <= 0) {
80103afe:	83 c4 10             	add    $0x10,%esp
80103b01:	83 7f 38 00          	cmpl   $0x0,0x38(%edi)
80103b05:	0f 8e b3 00 00 00    	jle    80103bbe <scheduler+0x1ca>
        if (p->ticks_left <= 0) {
80103b0b:	83 7b 7c 00          	cmpl   $0x0,0x7c(%ebx)
80103b0f:	0f 8e 22 01 00 00    	jle    80103c37 <scheduler+0x243>
        if (q->numproc > 0 && p->state != ZOMBIE) {
80103b15:	83 7f 34 00          	cmpl   $0x0,0x34(%edi)
80103b19:	7e 50                	jle    80103b6b <scheduler+0x177>
80103b1b:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103b1f:	74 4a                	je     80103b6b <scheduler+0x177>
          prev_idx = unqueue_proc(p, q);
80103b21:	83 ec 08             	sub    $0x8,%esp
80103b24:	57                   	push   %edi
80103b25:	53                   	push   %ebx
80103b26:	e8 93 fa ff ff       	call   801035be <unqueue_proc>
          if (prev_idx == -1) {
80103b2b:	83 c4 10             	add    $0x10,%esp
80103b2e:	83 f8 ff             	cmp    $0xffffffff,%eax
80103b31:	0f 84 0f 01 00 00    	je     80103c46 <scheduler+0x252>
          nq = find_available_queue(nk, p->default_level);
80103b37:	83 ec 08             	sub    $0x8,%esp
80103b3a:	ff b3 80 00 00 00    	push   0x80(%ebx)
80103b40:	56                   	push   %esi
80103b41:	e8 98 fb ff ff       	call   801036de <find_available_queue>
80103b46:	89 c6                	mov    %eax,%esi
          if (is_expired_set(nq)) {
80103b48:	89 04 24             	mov    %eax,(%esp)
80103b4b:	e8 81 f6 ff ff       	call   801031d1 <is_expired_set>
80103b50:	83 c4 10             	add    $0x10,%esp
80103b53:	85 c0                	test   %eax,%eax
80103b55:	74 07                	je     80103b5e <scheduler+0x16a>
            p->ticks_left = RSDL_PROC_QUANTUM;
80103b57:	c7 43 7c 14 00 00 00 	movl   $0x14,0x7c(%ebx)
          enqueue_proc(p, nq);
80103b5e:	83 ec 08             	sub    $0x8,%esp
80103b61:	56                   	push   %esi
80103b62:	53                   	push   %ebx
80103b63:	e8 25 f9 ff ff       	call   8010348d <enqueue_proc>
80103b68:	83 c4 10             	add    $0x10,%esp
      c->proc = 0;
80103b6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103b6e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103b75:	00 00 00 
      c->queue = NULL;
80103b78:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80103b7f:	00 00 00 
    release(&ptable.lock);
80103b82:	83 ec 0c             	sub    $0xc,%esp
80103b85:	68 60 1d 11 80       	push   $0x80111d60
80103b8a:	e8 45 08 00 00       	call   801043d4 <release>
  for(;;){
80103b8f:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103b92:	fb                   	sti    
    acquire(&ptable.lock);
80103b93:	83 ec 0c             	sub    $0xc,%esp
80103b96:	68 60 1d 11 80       	push   $0x80111d60
80103b9b:	e8 cf 07 00 00       	call   8010436f <acquire>
    for (k = 0; k < RSDL_LEVELS; ++k) {
80103ba0:	83 c4 10             	add    $0x10,%esp
    int found = 0;
80103ba3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    for (k = 0; k < RSDL_LEVELS; ++k) {
80103baa:	be 00 00 00 00       	mov    $0x0,%esi
80103baf:	e9 a0 fe ff ff       	jmp    80103a54 <scheduler+0x60>
        print_schedlog();
80103bb4:	e8 4f f6 ff ff       	call   80103208 <print_schedlog>
80103bb9:	e9 29 ff ff ff       	jmp    80103ae7 <scheduler+0xf3>
80103bbe:	89 75 e4             	mov    %esi,-0x1c(%ebp)
        while (q->numproc > 0) {
80103bc1:	83 7f 34 00          	cmpl   $0x0,0x34(%edi)
80103bc5:	7e 3f                	jle    80103c06 <scheduler+0x212>
          np = q->proc[0];
80103bc7:	8b 77 3c             	mov    0x3c(%edi),%esi
          np->ticks_left = RSDL_PROC_QUANTUM;
80103bca:	c7 46 7c 14 00 00 00 	movl   $0x14,0x7c(%esi)
          unqueue_proc(np, q);
80103bd1:	83 ec 08             	sub    $0x8,%esp
80103bd4:	57                   	push   %edi
80103bd5:	56                   	push   %esi
80103bd6:	e8 e3 f9 ff ff       	call   801035be <unqueue_proc>
          if (np == p) {
80103bdb:	83 c4 10             	add    $0x10,%esp
80103bde:	39 f3                	cmp    %esi,%ebx
80103be0:	74 df                	je     80103bc1 <scheduler+0x1cd>
          nq = find_available_queue(k+1, np->default_level);
80103be2:	83 ec 08             	sub    $0x8,%esp
80103be5:	ff b6 80 00 00 00    	push   0x80(%esi)
80103beb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103bee:	83 c0 01             	add    $0x1,%eax
80103bf1:	50                   	push   %eax
80103bf2:	e8 e7 fa ff ff       	call   801036de <find_available_queue>
80103bf7:	83 c4 08             	add    $0x8,%esp
          enqueue_proc(np, nq);
80103bfa:	50                   	push   %eax
80103bfb:	56                   	push   %esi
80103bfc:	e8 8c f8 ff ff       	call   8010348d <enqueue_proc>
80103c01:	83 c4 10             	add    $0x10,%esp
80103c04:	eb bb                	jmp    80103bc1 <scheduler+0x1cd>
        if (p->state != ZOMBIE) {
80103c06:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80103c09:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103c0d:	0f 84 58 ff ff ff    	je     80103b6b <scheduler+0x177>
          nq = find_available_queue(k+1, p->default_level);
80103c13:	83 ec 08             	sub    $0x8,%esp
80103c16:	ff b3 80 00 00 00    	push   0x80(%ebx)
80103c1c:	8d 46 01             	lea    0x1(%esi),%eax
80103c1f:	50                   	push   %eax
80103c20:	e8 b9 fa ff ff       	call   801036de <find_available_queue>
80103c25:	83 c4 08             	add    $0x8,%esp
          enqueue_proc(p, nq);
80103c28:	50                   	push   %eax
80103c29:	53                   	push   %ebx
80103c2a:	e8 5e f8 ff ff       	call   8010348d <enqueue_proc>
80103c2f:	83 c4 10             	add    $0x10,%esp
80103c32:	e9 34 ff ff ff       	jmp    80103b6b <scheduler+0x177>
          p->ticks_left = RSDL_PROC_QUANTUM;
80103c37:	c7 43 7c 14 00 00 00 	movl   $0x14,0x7c(%ebx)
          nk = k + 1;
80103c3e:	83 c6 01             	add    $0x1,%esi
80103c41:	e9 cf fe ff ff       	jmp    80103b15 <scheduler+0x121>
            panic("re-enqueue of proc failed");
80103c46:	83 ec 0c             	sub    $0xc,%esp
80103c49:	68 1d 76 10 80       	push   $0x8010761d
80103c4e:	e8 f5 c6 ff ff       	call   80100348 <panic>
      nq = ptable.active;
80103c53:	a1 94 3e 11 80       	mov    0x80113e94,%eax
      ptable.active = ptable.expired;
80103c58:	8b 15 98 3e 11 80    	mov    0x80113e98,%edx
80103c5e:	89 15 94 3e 11 80    	mov    %edx,0x80113e94
      ptable.expired = nq;
80103c64:	a3 98 3e 11 80       	mov    %eax,0x80113e98
      for (k = 0; k < RSDL_LEVELS; ++k) {
80103c69:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80103c6c:	eb 03                	jmp    80103c71 <scheduler+0x27d>
80103c6e:	83 c6 01             	add    $0x1,%esi
80103c71:	83 fe 02             	cmp    $0x2,%esi
80103c74:	0f 8f 08 ff ff ff    	jg     80103b82 <scheduler+0x18e>
        q = &ptable.expired[k];
80103c7a:	69 fe 3c 01 00 00    	imul   $0x13c,%esi,%edi
80103c80:	03 3d 98 3e 11 80    	add    0x80113e98,%edi
        q->ticks_left = RSDL_LEVEL_QUANTUM; // replenish level-local quantum
80103c86:	c7 47 38 64 00 00 00 	movl   $0x64,0x38(%edi)
        while (q->numproc > 0) {
80103c8d:	83 7f 34 00          	cmpl   $0x0,0x34(%edi)
80103c91:	7e db                	jle    80103c6e <scheduler+0x27a>
          p = q->proc[0];
80103c93:	8b 5f 3c             	mov    0x3c(%edi),%ebx
          p->ticks_left = RSDL_PROC_QUANTUM;
80103c96:	c7 43 7c 14 00 00 00 	movl   $0x14,0x7c(%ebx)
          unqueue_proc(p, q);
80103c9d:	83 ec 08             	sub    $0x8,%esp
80103ca0:	57                   	push   %edi
80103ca1:	53                   	push   %ebx
80103ca2:	e8 17 f9 ff ff       	call   801035be <unqueue_proc>
          nk = p->default_level;
80103ca7:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
          nq = find_available_queue(nk, nk);
80103cad:	83 c4 08             	add    $0x8,%esp
80103cb0:	50                   	push   %eax
80103cb1:	50                   	push   %eax
80103cb2:	e8 27 fa ff ff       	call   801036de <find_available_queue>
80103cb7:	83 c4 08             	add    $0x8,%esp
          enqueue_proc(p, nq);
80103cba:	50                   	push   %eax
80103cbb:	53                   	push   %ebx
80103cbc:	e8 cc f7 ff ff       	call   8010348d <enqueue_proc>
80103cc1:	83 c4 10             	add    $0x10,%esp
80103cc4:	eb c7                	jmp    80103c8d <scheduler+0x299>

80103cc6 <sched>:
{
80103cc6:	55                   	push   %ebp
80103cc7:	89 e5                	mov    %esp,%ebp
80103cc9:	56                   	push   %esi
80103cca:	53                   	push   %ebx
  struct proc *p = myproc();
80103ccb:	e8 9a f7 ff ff       	call   8010346a <myproc>
80103cd0:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
80103cd2:	83 ec 0c             	sub    $0xc,%esp
80103cd5:	68 60 1d 11 80       	push   $0x80111d60
80103cda:	e8 51 06 00 00       	call   80104330 <holding>
80103cdf:	83 c4 10             	add    $0x10,%esp
80103ce2:	85 c0                	test   %eax,%eax
80103ce4:	74 4f                	je     80103d35 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103ce6:	e8 08 f7 ff ff       	call   801033f3 <mycpu>
80103ceb:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103cf2:	75 4e                	jne    80103d42 <sched+0x7c>
  if(p->state == RUNNING)
80103cf4:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103cf8:	74 55                	je     80103d4f <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103cfa:	9c                   	pushf  
80103cfb:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103cfc:	f6 c4 02             	test   $0x2,%ah
80103cff:	75 5b                	jne    80103d5c <sched+0x96>
  intena = mycpu()->intena;
80103d01:	e8 ed f6 ff ff       	call   801033f3 <mycpu>
80103d06:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103d0c:	e8 e2 f6 ff ff       	call   801033f3 <mycpu>
80103d11:	83 ec 08             	sub    $0x8,%esp
80103d14:	ff 70 04             	push   0x4(%eax)
80103d17:	83 c3 1c             	add    $0x1c,%ebx
80103d1a:	53                   	push   %ebx
80103d1b:	e8 bc 08 00 00       	call   801045dc <swtch>
  mycpu()->intena = intena;
80103d20:	e8 ce f6 ff ff       	call   801033f3 <mycpu>
80103d25:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103d2b:	83 c4 10             	add    $0x10,%esp
80103d2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103d31:	5b                   	pop    %ebx
80103d32:	5e                   	pop    %esi
80103d33:	5d                   	pop    %ebp
80103d34:	c3                   	ret    
    panic("sched ptable.lock");
80103d35:	83 ec 0c             	sub    $0xc,%esp
80103d38:	68 37 76 10 80       	push   $0x80107637
80103d3d:	e8 06 c6 ff ff       	call   80100348 <panic>
    panic("sched locks");
80103d42:	83 ec 0c             	sub    $0xc,%esp
80103d45:	68 49 76 10 80       	push   $0x80107649
80103d4a:	e8 f9 c5 ff ff       	call   80100348 <panic>
    panic("sched running");
80103d4f:	83 ec 0c             	sub    $0xc,%esp
80103d52:	68 55 76 10 80       	push   $0x80107655
80103d57:	e8 ec c5 ff ff       	call   80100348 <panic>
    panic("sched interruptible");
80103d5c:	83 ec 0c             	sub    $0xc,%esp
80103d5f:	68 63 76 10 80       	push   $0x80107663
80103d64:	e8 df c5 ff ff       	call   80100348 <panic>

80103d69 <exit>:
{
80103d69:	55                   	push   %ebp
80103d6a:	89 e5                	mov    %esp,%ebp
80103d6c:	56                   	push   %esi
80103d6d:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103d6e:	e8 f7 f6 ff ff       	call   8010346a <myproc>
  if(curproc == initproc)
80103d73:	39 05 04 46 11 80    	cmp    %eax,0x80114604
80103d79:	74 09                	je     80103d84 <exit+0x1b>
80103d7b:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
80103d7d:	bb 00 00 00 00       	mov    $0x0,%ebx
80103d82:	eb 24                	jmp    80103da8 <exit+0x3f>
    panic("init exiting");
80103d84:	83 ec 0c             	sub    $0xc,%esp
80103d87:	68 77 76 10 80       	push   $0x80107677
80103d8c:	e8 b7 c5 ff ff       	call   80100348 <panic>
      fileclose(curproc->ofile[fd]);
80103d91:	83 ec 0c             	sub    $0xc,%esp
80103d94:	50                   	push   %eax
80103d95:	e8 29 cf ff ff       	call   80100cc3 <fileclose>
      curproc->ofile[fd] = 0;
80103d9a:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103da1:	00 
80103da2:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80103da5:	83 c3 01             	add    $0x1,%ebx
80103da8:	83 fb 0f             	cmp    $0xf,%ebx
80103dab:	7f 0a                	jg     80103db7 <exit+0x4e>
    if(curproc->ofile[fd]){
80103dad:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103db1:	85 c0                	test   %eax,%eax
80103db3:	75 dc                	jne    80103d91 <exit+0x28>
80103db5:	eb ee                	jmp    80103da5 <exit+0x3c>
  begin_op();
80103db7:	e8 f4 e9 ff ff       	call   801027b0 <begin_op>
  iput(curproc->cwd);
80103dbc:	83 ec 0c             	sub    $0xc,%esp
80103dbf:	ff 76 68             	push   0x68(%esi)
80103dc2:	e8 af d8 ff ff       	call   80101676 <iput>
  end_op();
80103dc7:	e8 5e ea ff ff       	call   8010282a <end_op>
  curproc->cwd = 0;
80103dcc:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103dd3:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
80103dda:	e8 90 05 00 00       	call   8010436f <acquire>
  wakeup1(curproc->parent);
80103ddf:	8b 46 14             	mov    0x14(%esi),%eax
80103de2:	e8 7a f2 ff ff       	call   80103061 <wakeup1>
  for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
80103de7:	83 c4 10             	add    $0x10,%esp
80103dea:	bb 94 1d 11 80       	mov    $0x80111d94,%ebx
80103def:	eb 06                	jmp    80103df7 <exit+0x8e>
80103df1:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103df7:	81 fb 94 3e 11 80    	cmp    $0x80113e94,%ebx
80103dfd:	73 1a                	jae    80103e19 <exit+0xb0>
    if(p->parent == curproc){
80103dff:	39 73 14             	cmp    %esi,0x14(%ebx)
80103e02:	75 ed                	jne    80103df1 <exit+0x88>
      p->parent = initproc;
80103e04:	a1 04 46 11 80       	mov    0x80114604,%eax
80103e09:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
80103e0c:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103e10:	75 df                	jne    80103df1 <exit+0x88>
        wakeup1(initproc);
80103e12:	e8 4a f2 ff ff       	call   80103061 <wakeup1>
80103e17:	eb d8                	jmp    80103df1 <exit+0x88>
  remove_proc_from_levels(curproc);
80103e19:	83 ec 0c             	sub    $0xc,%esp
80103e1c:	56                   	push   %esi
80103e1d:	e8 c6 f7 ff ff       	call   801035e8 <remove_proc_from_levels>
  curproc->state = ZOMBIE;
80103e22:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103e29:	e8 98 fe ff ff       	call   80103cc6 <sched>
  panic("zombie exit");
80103e2e:	c7 04 24 84 76 10 80 	movl   $0x80107684,(%esp)
80103e35:	e8 0e c5 ff ff       	call   80100348 <panic>

80103e3a <yield>:
{
80103e3a:	55                   	push   %ebp
80103e3b:	89 e5                	mov    %esp,%ebp
80103e3d:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103e40:	68 60 1d 11 80       	push   $0x80111d60
80103e45:	e8 25 05 00 00       	call   8010436f <acquire>
  myproc()->state = RUNNABLE;
80103e4a:	e8 1b f6 ff ff       	call   8010346a <myproc>
80103e4f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103e56:	e8 6b fe ff ff       	call   80103cc6 <sched>
  release(&ptable.lock);
80103e5b:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
80103e62:	e8 6d 05 00 00       	call   801043d4 <release>
}
80103e67:	83 c4 10             	add    $0x10,%esp
80103e6a:	c9                   	leave  
80103e6b:	c3                   	ret    

80103e6c <sleep>:
{
80103e6c:	55                   	push   %ebp
80103e6d:	89 e5                	mov    %esp,%ebp
80103e6f:	56                   	push   %esi
80103e70:	53                   	push   %ebx
80103e71:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p = myproc();
80103e74:	e8 f1 f5 ff ff       	call   8010346a <myproc>
  if(p == 0)
80103e79:	85 c0                	test   %eax,%eax
80103e7b:	74 66                	je     80103ee3 <sleep+0x77>
80103e7d:	89 c3                	mov    %eax,%ebx
  if(lk == 0)
80103e7f:	85 f6                	test   %esi,%esi
80103e81:	74 6d                	je     80103ef0 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103e83:	81 fe 60 1d 11 80    	cmp    $0x80111d60,%esi
80103e89:	74 18                	je     80103ea3 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103e8b:	83 ec 0c             	sub    $0xc,%esp
80103e8e:	68 60 1d 11 80       	push   $0x80111d60
80103e93:	e8 d7 04 00 00       	call   8010436f <acquire>
    release(lk);
80103e98:	89 34 24             	mov    %esi,(%esp)
80103e9b:	e8 34 05 00 00       	call   801043d4 <release>
80103ea0:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
80103ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea6:	89 43 20             	mov    %eax,0x20(%ebx)
  p->state = SLEEPING;
80103ea9:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80103eb0:	e8 11 fe ff ff       	call   80103cc6 <sched>
  p->chan = 0;
80103eb5:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103ebc:	81 fe 60 1d 11 80    	cmp    $0x80111d60,%esi
80103ec2:	74 18                	je     80103edc <sleep+0x70>
    release(&ptable.lock);
80103ec4:	83 ec 0c             	sub    $0xc,%esp
80103ec7:	68 60 1d 11 80       	push   $0x80111d60
80103ecc:	e8 03 05 00 00       	call   801043d4 <release>
    acquire(lk);
80103ed1:	89 34 24             	mov    %esi,(%esp)
80103ed4:	e8 96 04 00 00       	call   8010436f <acquire>
80103ed9:	83 c4 10             	add    $0x10,%esp
}
80103edc:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103edf:	5b                   	pop    %ebx
80103ee0:	5e                   	pop    %esi
80103ee1:	5d                   	pop    %ebp
80103ee2:	c3                   	ret    
    panic("sleep");
80103ee3:	83 ec 0c             	sub    $0xc,%esp
80103ee6:	68 90 76 10 80       	push   $0x80107690
80103eeb:	e8 58 c4 ff ff       	call   80100348 <panic>
    panic("sleep without lk");
80103ef0:	83 ec 0c             	sub    $0xc,%esp
80103ef3:	68 96 76 10 80       	push   $0x80107696
80103ef8:	e8 4b c4 ff ff       	call   80100348 <panic>

80103efd <wait>:
{
80103efd:	55                   	push   %ebp
80103efe:	89 e5                	mov    %esp,%ebp
80103f00:	56                   	push   %esi
80103f01:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103f02:	e8 63 f5 ff ff       	call   8010346a <myproc>
80103f07:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103f09:	83 ec 0c             	sub    $0xc,%esp
80103f0c:	68 60 1d 11 80       	push   $0x80111d60
80103f11:	e8 59 04 00 00       	call   8010436f <acquire>
80103f16:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103f19:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
80103f1e:	bb 94 1d 11 80       	mov    $0x80111d94,%ebx
80103f23:	eb 5e                	jmp    80103f83 <wait+0x86>
        pid = p->pid;
80103f25:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103f28:	83 ec 0c             	sub    $0xc,%esp
80103f2b:	ff 73 08             	push   0x8(%ebx)
80103f2e:	e8 59 e0 ff ff       	call   80101f8c <kfree>
        p->kstack = 0;
80103f33:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103f3a:	83 c4 04             	add    $0x4,%esp
80103f3d:	ff 73 04             	push   0x4(%ebx)
80103f40:	e8 e0 2c 00 00       	call   80106c25 <freevm>
        p->pid = 0;
80103f45:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103f4c:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103f53:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103f57:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103f5e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103f65:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
80103f6c:	e8 63 04 00 00       	call   801043d4 <release>
        return pid;
80103f71:	83 c4 10             	add    $0x10,%esp
}
80103f74:	89 f0                	mov    %esi,%eax
80103f76:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103f79:	5b                   	pop    %ebx
80103f7a:	5e                   	pop    %esi
80103f7b:	5d                   	pop    %ebp
80103f7c:	c3                   	ret    
    for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
80103f7d:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103f83:	81 fb 94 3e 11 80    	cmp    $0x80113e94,%ebx
80103f89:	73 12                	jae    80103f9d <wait+0xa0>
      if(p->parent != curproc)
80103f8b:	39 73 14             	cmp    %esi,0x14(%ebx)
80103f8e:	75 ed                	jne    80103f7d <wait+0x80>
      if(p->state == ZOMBIE){
80103f90:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103f94:	74 8f                	je     80103f25 <wait+0x28>
      havekids = 1;
80103f96:	b8 01 00 00 00       	mov    $0x1,%eax
80103f9b:	eb e0                	jmp    80103f7d <wait+0x80>
    if(!havekids || curproc->killed){
80103f9d:	85 c0                	test   %eax,%eax
80103f9f:	74 06                	je     80103fa7 <wait+0xaa>
80103fa1:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103fa5:	74 17                	je     80103fbe <wait+0xc1>
      release(&ptable.lock);
80103fa7:	83 ec 0c             	sub    $0xc,%esp
80103faa:	68 60 1d 11 80       	push   $0x80111d60
80103faf:	e8 20 04 00 00       	call   801043d4 <release>
      return -1;
80103fb4:	83 c4 10             	add    $0x10,%esp
80103fb7:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103fbc:	eb b6                	jmp    80103f74 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103fbe:	83 ec 08             	sub    $0x8,%esp
80103fc1:	68 60 1d 11 80       	push   $0x80111d60
80103fc6:	56                   	push   %esi
80103fc7:	e8 a0 fe ff ff       	call   80103e6c <sleep>
    havekids = 0;
80103fcc:	83 c4 10             	add    $0x10,%esp
80103fcf:	e9 45 ff ff ff       	jmp    80103f19 <wait+0x1c>

80103fd4 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103fd4:	55                   	push   %ebp
80103fd5:	89 e5                	mov    %esp,%ebp
80103fd7:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103fda:	68 60 1d 11 80       	push   $0x80111d60
80103fdf:	e8 8b 03 00 00       	call   8010436f <acquire>
  wakeup1(chan);
80103fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe7:	e8 75 f0 ff ff       	call   80103061 <wakeup1>
  release(&ptable.lock);
80103fec:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
80103ff3:	e8 dc 03 00 00       	call   801043d4 <release>
}
80103ff8:	83 c4 10             	add    $0x10,%esp
80103ffb:	c9                   	leave  
80103ffc:	c3                   	ret    

80103ffd <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103ffd:	55                   	push   %ebp
80103ffe:	89 e5                	mov    %esp,%ebp
80104000:	53                   	push   %ebx
80104001:	83 ec 10             	sub    $0x10,%esp
80104004:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80104007:	68 60 1d 11 80       	push   $0x80111d60
8010400c:	e8 5e 03 00 00       	call   8010436f <acquire>
  for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
80104011:	83 c4 10             	add    $0x10,%esp
80104014:	b8 94 1d 11 80       	mov    $0x80111d94,%eax
80104019:	eb 0e                	jmp    80104029 <kill+0x2c>
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
8010401b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80104022:	eb 1e                	jmp    80104042 <kill+0x45>
  for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
80104024:	05 84 00 00 00       	add    $0x84,%eax
80104029:	3d 94 3e 11 80       	cmp    $0x80113e94,%eax
8010402e:	73 2c                	jae    8010405c <kill+0x5f>
    if(p->pid == pid){
80104030:	39 58 10             	cmp    %ebx,0x10(%eax)
80104033:	75 ef                	jne    80104024 <kill+0x27>
      p->killed = 1;
80104035:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      if(p->state == SLEEPING)
8010403c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80104040:	74 d9                	je     8010401b <kill+0x1e>
      release(&ptable.lock);
80104042:	83 ec 0c             	sub    $0xc,%esp
80104045:	68 60 1d 11 80       	push   $0x80111d60
8010404a:	e8 85 03 00 00       	call   801043d4 <release>
      return 0;
8010404f:	83 c4 10             	add    $0x10,%esp
80104052:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80104057:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010405a:	c9                   	leave  
8010405b:	c3                   	ret    
  release(&ptable.lock);
8010405c:	83 ec 0c             	sub    $0xc,%esp
8010405f:	68 60 1d 11 80       	push   $0x80111d60
80104064:	e8 6b 03 00 00       	call   801043d4 <release>
  return -1;
80104069:	83 c4 10             	add    $0x10,%esp
8010406c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104071:	eb e4                	jmp    80104057 <kill+0x5a>

80104073 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104073:	55                   	push   %ebp
80104074:	89 e5                	mov    %esp,%ebp
80104076:	56                   	push   %esi
80104077:	53                   	push   %ebx
80104078:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
8010407b:	bb 94 1d 11 80       	mov    $0x80111d94,%ebx
80104080:	eb 36                	jmp    801040b8 <procdump+0x45>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80104082:	b8 a7 76 10 80       	mov    $0x801076a7,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80104087:	8d 53 6c             	lea    0x6c(%ebx),%edx
8010408a:	52                   	push   %edx
8010408b:	50                   	push   %eax
8010408c:	ff 73 10             	push   0x10(%ebx)
8010408f:	68 ab 76 10 80       	push   $0x801076ab
80104094:	e8 6e c5 ff ff       	call   80100607 <cprintf>
    if(p->state == SLEEPING){
80104099:	83 c4 10             	add    $0x10,%esp
8010409c:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
801040a0:	74 3c                	je     801040de <procdump+0x6b>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801040a2:	83 ec 0c             	sub    $0xc,%esp
801040a5:	68 bb 7a 10 80       	push   $0x80107abb
801040aa:	e8 58 c5 ff ff       	call   80100607 <cprintf>
801040af:	83 c4 10             	add    $0x10,%esp
  for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
801040b2:	81 c3 84 00 00 00    	add    $0x84,%ebx
801040b8:	81 fb 94 3e 11 80    	cmp    $0x80113e94,%ebx
801040be:	73 61                	jae    80104121 <procdump+0xae>
    if(p->state == UNUSED)
801040c0:	8b 43 0c             	mov    0xc(%ebx),%eax
801040c3:	85 c0                	test   %eax,%eax
801040c5:	74 eb                	je     801040b2 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801040c7:	83 f8 05             	cmp    $0x5,%eax
801040ca:	77 b6                	ja     80104082 <procdump+0xf>
801040cc:	8b 04 85 68 77 10 80 	mov    -0x7fef8898(,%eax,4),%eax
801040d3:	85 c0                	test   %eax,%eax
801040d5:	75 b0                	jne    80104087 <procdump+0x14>
      state = "???";
801040d7:	b8 a7 76 10 80       	mov    $0x801076a7,%eax
801040dc:	eb a9                	jmp    80104087 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801040de:	8b 43 1c             	mov    0x1c(%ebx),%eax
801040e1:	8b 40 0c             	mov    0xc(%eax),%eax
801040e4:	83 c0 08             	add    $0x8,%eax
801040e7:	83 ec 08             	sub    $0x8,%esp
801040ea:	8d 55 d0             	lea    -0x30(%ebp),%edx
801040ed:	52                   	push   %edx
801040ee:	50                   	push   %eax
801040ef:	e8 5a 01 00 00       	call   8010424e <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801040f4:	83 c4 10             	add    $0x10,%esp
801040f7:	be 00 00 00 00       	mov    $0x0,%esi
801040fc:	eb 14                	jmp    80104112 <procdump+0x9f>
        cprintf(" %p", pc[i]);
801040fe:	83 ec 08             	sub    $0x8,%esp
80104101:	50                   	push   %eax
80104102:	68 81 6f 10 80       	push   $0x80106f81
80104107:	e8 fb c4 ff ff       	call   80100607 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
8010410c:	83 c6 01             	add    $0x1,%esi
8010410f:	83 c4 10             	add    $0x10,%esp
80104112:	83 fe 09             	cmp    $0x9,%esi
80104115:	7f 8b                	jg     801040a2 <procdump+0x2f>
80104117:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
8010411b:	85 c0                	test   %eax,%eax
8010411d:	75 df                	jne    801040fe <procdump+0x8b>
8010411f:	eb 81                	jmp    801040a2 <procdump+0x2f>
  }
}
80104121:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104124:	5b                   	pop    %ebx
80104125:	5e                   	pop    %esi
80104126:	5d                   	pop    %ebp
80104127:	c3                   	ret    

80104128 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104128:	55                   	push   %ebp
80104129:	89 e5                	mov    %esp,%ebp
8010412b:	53                   	push   %ebx
8010412c:	83 ec 0c             	sub    $0xc,%esp
8010412f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80104132:	68 80 77 10 80       	push   $0x80107780
80104137:	8d 43 04             	lea    0x4(%ebx),%eax
8010413a:	50                   	push   %eax
8010413b:	e8 f3 00 00 00       	call   80104233 <initlock>
  lk->name = name;
80104140:	8b 45 0c             	mov    0xc(%ebp),%eax
80104143:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80104146:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010414c:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80104153:	83 c4 10             	add    $0x10,%esp
80104156:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104159:	c9                   	leave  
8010415a:	c3                   	ret    

8010415b <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010415b:	55                   	push   %ebp
8010415c:	89 e5                	mov    %esp,%ebp
8010415e:	56                   	push   %esi
8010415f:	53                   	push   %ebx
80104160:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104163:	8d 73 04             	lea    0x4(%ebx),%esi
80104166:	83 ec 0c             	sub    $0xc,%esp
80104169:	56                   	push   %esi
8010416a:	e8 00 02 00 00       	call   8010436f <acquire>
  while (lk->locked) {
8010416f:	83 c4 10             	add    $0x10,%esp
80104172:	eb 0d                	jmp    80104181 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80104174:	83 ec 08             	sub    $0x8,%esp
80104177:	56                   	push   %esi
80104178:	53                   	push   %ebx
80104179:	e8 ee fc ff ff       	call   80103e6c <sleep>
8010417e:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104181:	83 3b 00             	cmpl   $0x0,(%ebx)
80104184:	75 ee                	jne    80104174 <acquiresleep+0x19>
  }
  lk->locked = 1;
80104186:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
8010418c:	e8 d9 f2 ff ff       	call   8010346a <myproc>
80104191:	8b 40 10             	mov    0x10(%eax),%eax
80104194:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80104197:	83 ec 0c             	sub    $0xc,%esp
8010419a:	56                   	push   %esi
8010419b:	e8 34 02 00 00       	call   801043d4 <release>
}
801041a0:	83 c4 10             	add    $0x10,%esp
801041a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041a6:	5b                   	pop    %ebx
801041a7:	5e                   	pop    %esi
801041a8:	5d                   	pop    %ebp
801041a9:	c3                   	ret    

801041aa <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801041aa:	55                   	push   %ebp
801041ab:	89 e5                	mov    %esp,%ebp
801041ad:	56                   	push   %esi
801041ae:	53                   	push   %ebx
801041af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801041b2:	8d 73 04             	lea    0x4(%ebx),%esi
801041b5:	83 ec 0c             	sub    $0xc,%esp
801041b8:	56                   	push   %esi
801041b9:	e8 b1 01 00 00       	call   8010436f <acquire>
  lk->locked = 0;
801041be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
801041c4:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
801041cb:	89 1c 24             	mov    %ebx,(%esp)
801041ce:	e8 01 fe ff ff       	call   80103fd4 <wakeup>
  release(&lk->lk);
801041d3:	89 34 24             	mov    %esi,(%esp)
801041d6:	e8 f9 01 00 00       	call   801043d4 <release>
}
801041db:	83 c4 10             	add    $0x10,%esp
801041de:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041e1:	5b                   	pop    %ebx
801041e2:	5e                   	pop    %esi
801041e3:	5d                   	pop    %ebp
801041e4:	c3                   	ret    

801041e5 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801041e5:	55                   	push   %ebp
801041e6:	89 e5                	mov    %esp,%ebp
801041e8:	56                   	push   %esi
801041e9:	53                   	push   %ebx
801041ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
801041ed:	8d 73 04             	lea    0x4(%ebx),%esi
801041f0:	83 ec 0c             	sub    $0xc,%esp
801041f3:	56                   	push   %esi
801041f4:	e8 76 01 00 00       	call   8010436f <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
801041f9:	83 c4 10             	add    $0x10,%esp
801041fc:	83 3b 00             	cmpl   $0x0,(%ebx)
801041ff:	75 17                	jne    80104218 <holdingsleep+0x33>
80104201:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80104206:	83 ec 0c             	sub    $0xc,%esp
80104209:	56                   	push   %esi
8010420a:	e8 c5 01 00 00       	call   801043d4 <release>
  return r;
}
8010420f:	89 d8                	mov    %ebx,%eax
80104211:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104214:	5b                   	pop    %ebx
80104215:	5e                   	pop    %esi
80104216:	5d                   	pop    %ebp
80104217:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80104218:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
8010421b:	e8 4a f2 ff ff       	call   8010346a <myproc>
80104220:	3b 58 10             	cmp    0x10(%eax),%ebx
80104223:	74 07                	je     8010422c <holdingsleep+0x47>
80104225:	bb 00 00 00 00       	mov    $0x0,%ebx
8010422a:	eb da                	jmp    80104206 <holdingsleep+0x21>
8010422c:	bb 01 00 00 00       	mov    $0x1,%ebx
80104231:	eb d3                	jmp    80104206 <holdingsleep+0x21>

80104233 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104233:	55                   	push   %ebp
80104234:	89 e5                	mov    %esp,%ebp
80104236:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80104239:	8b 55 0c             	mov    0xc(%ebp),%edx
8010423c:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010423f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104245:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010424c:	5d                   	pop    %ebp
8010424d:	c3                   	ret    

8010424e <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010424e:	55                   	push   %ebp
8010424f:	89 e5                	mov    %esp,%ebp
80104251:	53                   	push   %ebx
80104252:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104255:	8b 45 08             	mov    0x8(%ebp),%eax
80104258:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
8010425b:	b8 00 00 00 00       	mov    $0x0,%eax
80104260:	83 f8 09             	cmp    $0x9,%eax
80104263:	7f 25                	jg     8010428a <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104265:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
8010426b:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104271:	77 17                	ja     8010428a <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104273:	8b 5a 04             	mov    0x4(%edx),%ebx
80104276:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80104279:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
8010427b:	83 c0 01             	add    $0x1,%eax
8010427e:	eb e0                	jmp    80104260 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80104280:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80104287:	83 c0 01             	add    $0x1,%eax
8010428a:	83 f8 09             	cmp    $0x9,%eax
8010428d:	7e f1                	jle    80104280 <getcallerpcs+0x32>
}
8010428f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104292:	c9                   	leave  
80104293:	c3                   	ret    

80104294 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104294:	55                   	push   %ebp
80104295:	89 e5                	mov    %esp,%ebp
80104297:	53                   	push   %ebx
80104298:	83 ec 04             	sub    $0x4,%esp
8010429b:	9c                   	pushf  
8010429c:	5b                   	pop    %ebx
  asm volatile("cli");
8010429d:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
8010429e:	e8 50 f1 ff ff       	call   801033f3 <mycpu>
801042a3:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
801042aa:	74 11                	je     801042bd <pushcli+0x29>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
801042ac:	e8 42 f1 ff ff       	call   801033f3 <mycpu>
801042b1:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
801042b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042bb:	c9                   	leave  
801042bc:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
801042bd:	e8 31 f1 ff ff       	call   801033f3 <mycpu>
801042c2:	81 e3 00 02 00 00    	and    $0x200,%ebx
801042c8:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
801042ce:	eb dc                	jmp    801042ac <pushcli+0x18>

801042d0 <popcli>:

void
popcli(void)
{
801042d0:	55                   	push   %ebp
801042d1:	89 e5                	mov    %esp,%ebp
801042d3:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801042d6:	9c                   	pushf  
801042d7:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801042d8:	f6 c4 02             	test   $0x2,%ah
801042db:	75 28                	jne    80104305 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
801042dd:	e8 11 f1 ff ff       	call   801033f3 <mycpu>
801042e2:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
801042e8:	8d 51 ff             	lea    -0x1(%ecx),%edx
801042eb:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801042f1:	85 d2                	test   %edx,%edx
801042f3:	78 1d                	js     80104312 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
801042f5:	e8 f9 f0 ff ff       	call   801033f3 <mycpu>
801042fa:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80104301:	74 1c                	je     8010431f <popcli+0x4f>
    sti();
}
80104303:	c9                   	leave  
80104304:	c3                   	ret    
    panic("popcli - interruptible");
80104305:	83 ec 0c             	sub    $0xc,%esp
80104308:	68 8b 77 10 80       	push   $0x8010778b
8010430d:	e8 36 c0 ff ff       	call   80100348 <panic>
    panic("popcli");
80104312:	83 ec 0c             	sub    $0xc,%esp
80104315:	68 a2 77 10 80       	push   $0x801077a2
8010431a:	e8 29 c0 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010431f:	e8 cf f0 ff ff       	call   801033f3 <mycpu>
80104324:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
8010432b:	74 d6                	je     80104303 <popcli+0x33>
  asm volatile("sti");
8010432d:	fb                   	sti    
}
8010432e:	eb d3                	jmp    80104303 <popcli+0x33>

80104330 <holding>:
{
80104330:	55                   	push   %ebp
80104331:	89 e5                	mov    %esp,%ebp
80104333:	53                   	push   %ebx
80104334:	83 ec 04             	sub    $0x4,%esp
80104337:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
8010433a:	e8 55 ff ff ff       	call   80104294 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010433f:	83 3b 00             	cmpl   $0x0,(%ebx)
80104342:	75 11                	jne    80104355 <holding+0x25>
80104344:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80104349:	e8 82 ff ff ff       	call   801042d0 <popcli>
}
8010434e:	89 d8                	mov    %ebx,%eax
80104350:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104353:	c9                   	leave  
80104354:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80104355:	8b 5b 08             	mov    0x8(%ebx),%ebx
80104358:	e8 96 f0 ff ff       	call   801033f3 <mycpu>
8010435d:	39 c3                	cmp    %eax,%ebx
8010435f:	74 07                	je     80104368 <holding+0x38>
80104361:	bb 00 00 00 00       	mov    $0x0,%ebx
80104366:	eb e1                	jmp    80104349 <holding+0x19>
80104368:	bb 01 00 00 00       	mov    $0x1,%ebx
8010436d:	eb da                	jmp    80104349 <holding+0x19>

8010436f <acquire>:
{
8010436f:	55                   	push   %ebp
80104370:	89 e5                	mov    %esp,%ebp
80104372:	53                   	push   %ebx
80104373:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104376:	e8 19 ff ff ff       	call   80104294 <pushcli>
  if(holding(lk))
8010437b:	83 ec 0c             	sub    $0xc,%esp
8010437e:	ff 75 08             	push   0x8(%ebp)
80104381:	e8 aa ff ff ff       	call   80104330 <holding>
80104386:	83 c4 10             	add    $0x10,%esp
80104389:	85 c0                	test   %eax,%eax
8010438b:	75 3a                	jne    801043c7 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
8010438d:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80104390:	b8 01 00 00 00       	mov    $0x1,%eax
80104395:	f0 87 02             	lock xchg %eax,(%edx)
80104398:	85 c0                	test   %eax,%eax
8010439a:	75 f1                	jne    8010438d <acquire+0x1e>
  __sync_synchronize();
8010439c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
801043a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
801043a4:	e8 4a f0 ff ff       	call   801033f3 <mycpu>
801043a9:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801043ac:	8b 45 08             	mov    0x8(%ebp),%eax
801043af:	83 c0 0c             	add    $0xc,%eax
801043b2:	83 ec 08             	sub    $0x8,%esp
801043b5:	50                   	push   %eax
801043b6:	8d 45 08             	lea    0x8(%ebp),%eax
801043b9:	50                   	push   %eax
801043ba:	e8 8f fe ff ff       	call   8010424e <getcallerpcs>
}
801043bf:	83 c4 10             	add    $0x10,%esp
801043c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043c5:	c9                   	leave  
801043c6:	c3                   	ret    
    panic("acquire");
801043c7:	83 ec 0c             	sub    $0xc,%esp
801043ca:	68 a9 77 10 80       	push   $0x801077a9
801043cf:	e8 74 bf ff ff       	call   80100348 <panic>

801043d4 <release>:
{
801043d4:	55                   	push   %ebp
801043d5:	89 e5                	mov    %esp,%ebp
801043d7:	53                   	push   %ebx
801043d8:	83 ec 10             	sub    $0x10,%esp
801043db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
801043de:	53                   	push   %ebx
801043df:	e8 4c ff ff ff       	call   80104330 <holding>
801043e4:	83 c4 10             	add    $0x10,%esp
801043e7:	85 c0                	test   %eax,%eax
801043e9:	74 23                	je     8010440e <release+0x3a>
  lk->pcs[0] = 0;
801043eb:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
801043f2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
801043f9:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801043fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80104404:	e8 c7 fe ff ff       	call   801042d0 <popcli>
}
80104409:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010440c:	c9                   	leave  
8010440d:	c3                   	ret    
    panic("release");
8010440e:	83 ec 0c             	sub    $0xc,%esp
80104411:	68 b1 77 10 80       	push   $0x801077b1
80104416:	e8 2d bf ff ff       	call   80100348 <panic>

8010441b <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010441b:	55                   	push   %ebp
8010441c:	89 e5                	mov    %esp,%ebp
8010441e:	57                   	push   %edi
8010441f:	53                   	push   %ebx
80104420:	8b 55 08             	mov    0x8(%ebp),%edx
80104423:	8b 45 0c             	mov    0xc(%ebp),%eax
80104426:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80104429:	f6 c2 03             	test   $0x3,%dl
8010442c:	75 25                	jne    80104453 <memset+0x38>
8010442e:	f6 c1 03             	test   $0x3,%cl
80104431:	75 20                	jne    80104453 <memset+0x38>
    c &= 0xFF;
80104433:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104436:	c1 e9 02             	shr    $0x2,%ecx
80104439:	c1 e0 18             	shl    $0x18,%eax
8010443c:	89 fb                	mov    %edi,%ebx
8010443e:	c1 e3 10             	shl    $0x10,%ebx
80104441:	09 d8                	or     %ebx,%eax
80104443:	89 fb                	mov    %edi,%ebx
80104445:	c1 e3 08             	shl    $0x8,%ebx
80104448:	09 d8                	or     %ebx,%eax
8010444a:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
8010444c:	89 d7                	mov    %edx,%edi
8010444e:	fc                   	cld    
8010444f:	f3 ab                	rep stos %eax,%es:(%edi)
}
80104451:	eb 05                	jmp    80104458 <memset+0x3d>
  asm volatile("cld; rep stosb" :
80104453:	89 d7                	mov    %edx,%edi
80104455:	fc                   	cld    
80104456:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80104458:	89 d0                	mov    %edx,%eax
8010445a:	5b                   	pop    %ebx
8010445b:	5f                   	pop    %edi
8010445c:	5d                   	pop    %ebp
8010445d:	c3                   	ret    

8010445e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010445e:	55                   	push   %ebp
8010445f:	89 e5                	mov    %esp,%ebp
80104461:	56                   	push   %esi
80104462:	53                   	push   %ebx
80104463:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104466:	8b 55 0c             	mov    0xc(%ebp),%edx
80104469:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010446c:	eb 08                	jmp    80104476 <memcmp+0x18>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
8010446e:	83 c1 01             	add    $0x1,%ecx
80104471:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80104474:	89 f0                	mov    %esi,%eax
80104476:	8d 70 ff             	lea    -0x1(%eax),%esi
80104479:	85 c0                	test   %eax,%eax
8010447b:	74 12                	je     8010448f <memcmp+0x31>
    if(*s1 != *s2)
8010447d:	0f b6 01             	movzbl (%ecx),%eax
80104480:	0f b6 1a             	movzbl (%edx),%ebx
80104483:	38 d8                	cmp    %bl,%al
80104485:	74 e7                	je     8010446e <memcmp+0x10>
      return *s1 - *s2;
80104487:	0f b6 c0             	movzbl %al,%eax
8010448a:	0f b6 db             	movzbl %bl,%ebx
8010448d:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
8010448f:	5b                   	pop    %ebx
80104490:	5e                   	pop    %esi
80104491:	5d                   	pop    %ebp
80104492:	c3                   	ret    

80104493 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104493:	55                   	push   %ebp
80104494:	89 e5                	mov    %esp,%ebp
80104496:	56                   	push   %esi
80104497:	53                   	push   %ebx
80104498:	8b 75 08             	mov    0x8(%ebp),%esi
8010449b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010449e:	8b 45 10             	mov    0x10(%ebp),%eax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801044a1:	39 f2                	cmp    %esi,%edx
801044a3:	73 3c                	jae    801044e1 <memmove+0x4e>
801044a5:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801044a8:	39 f1                	cmp    %esi,%ecx
801044aa:	76 39                	jbe    801044e5 <memmove+0x52>
    s += n;
    d += n;
801044ac:	8d 14 06             	lea    (%esi,%eax,1),%edx
    while(n-- > 0)
801044af:	eb 0d                	jmp    801044be <memmove+0x2b>
      *--d = *--s;
801044b1:	83 e9 01             	sub    $0x1,%ecx
801044b4:	83 ea 01             	sub    $0x1,%edx
801044b7:	0f b6 01             	movzbl (%ecx),%eax
801044ba:	88 02                	mov    %al,(%edx)
    while(n-- > 0)
801044bc:	89 d8                	mov    %ebx,%eax
801044be:	8d 58 ff             	lea    -0x1(%eax),%ebx
801044c1:	85 c0                	test   %eax,%eax
801044c3:	75 ec                	jne    801044b1 <memmove+0x1e>
801044c5:	eb 14                	jmp    801044db <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
801044c7:	0f b6 02             	movzbl (%edx),%eax
801044ca:	88 01                	mov    %al,(%ecx)
801044cc:	8d 49 01             	lea    0x1(%ecx),%ecx
801044cf:	8d 52 01             	lea    0x1(%edx),%edx
    while(n-- > 0)
801044d2:	89 d8                	mov    %ebx,%eax
801044d4:	8d 58 ff             	lea    -0x1(%eax),%ebx
801044d7:	85 c0                	test   %eax,%eax
801044d9:	75 ec                	jne    801044c7 <memmove+0x34>

  return dst;
}
801044db:	89 f0                	mov    %esi,%eax
801044dd:	5b                   	pop    %ebx
801044de:	5e                   	pop    %esi
801044df:	5d                   	pop    %ebp
801044e0:	c3                   	ret    
801044e1:	89 f1                	mov    %esi,%ecx
801044e3:	eb ef                	jmp    801044d4 <memmove+0x41>
801044e5:	89 f1                	mov    %esi,%ecx
801044e7:	eb eb                	jmp    801044d4 <memmove+0x41>

801044e9 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801044e9:	55                   	push   %ebp
801044ea:	89 e5                	mov    %esp,%ebp
801044ec:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801044ef:	ff 75 10             	push   0x10(%ebp)
801044f2:	ff 75 0c             	push   0xc(%ebp)
801044f5:	ff 75 08             	push   0x8(%ebp)
801044f8:	e8 96 ff ff ff       	call   80104493 <memmove>
}
801044fd:	c9                   	leave  
801044fe:	c3                   	ret    

801044ff <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801044ff:	55                   	push   %ebp
80104500:	89 e5                	mov    %esp,%ebp
80104502:	53                   	push   %ebx
80104503:	8b 55 08             	mov    0x8(%ebp),%edx
80104506:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104509:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
8010450c:	eb 09                	jmp    80104517 <strncmp+0x18>
    n--, p++, q++;
8010450e:	83 e8 01             	sub    $0x1,%eax
80104511:	83 c2 01             	add    $0x1,%edx
80104514:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104517:	85 c0                	test   %eax,%eax
80104519:	74 0b                	je     80104526 <strncmp+0x27>
8010451b:	0f b6 1a             	movzbl (%edx),%ebx
8010451e:	84 db                	test   %bl,%bl
80104520:	74 04                	je     80104526 <strncmp+0x27>
80104522:	3a 19                	cmp    (%ecx),%bl
80104524:	74 e8                	je     8010450e <strncmp+0xf>
  if(n == 0)
80104526:	85 c0                	test   %eax,%eax
80104528:	74 0d                	je     80104537 <strncmp+0x38>
    return 0;
  return (uchar)*p - (uchar)*q;
8010452a:	0f b6 02             	movzbl (%edx),%eax
8010452d:	0f b6 11             	movzbl (%ecx),%edx
80104530:	29 d0                	sub    %edx,%eax
}
80104532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104535:	c9                   	leave  
80104536:	c3                   	ret    
    return 0;
80104537:	b8 00 00 00 00       	mov    $0x0,%eax
8010453c:	eb f4                	jmp    80104532 <strncmp+0x33>

8010453e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010453e:	55                   	push   %ebp
8010453f:	89 e5                	mov    %esp,%ebp
80104541:	57                   	push   %edi
80104542:	56                   	push   %esi
80104543:	53                   	push   %ebx
80104544:	8b 7d 08             	mov    0x8(%ebp),%edi
80104547:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010454a:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
8010454d:	89 fa                	mov    %edi,%edx
8010454f:	eb 04                	jmp    80104555 <strncpy+0x17>
80104551:	89 f1                	mov    %esi,%ecx
80104553:	89 da                	mov    %ebx,%edx
80104555:	89 c3                	mov    %eax,%ebx
80104557:	83 e8 01             	sub    $0x1,%eax
8010455a:	85 db                	test   %ebx,%ebx
8010455c:	7e 11                	jle    8010456f <strncpy+0x31>
8010455e:	8d 71 01             	lea    0x1(%ecx),%esi
80104561:	8d 5a 01             	lea    0x1(%edx),%ebx
80104564:	0f b6 09             	movzbl (%ecx),%ecx
80104567:	88 0a                	mov    %cl,(%edx)
80104569:	84 c9                	test   %cl,%cl
8010456b:	75 e4                	jne    80104551 <strncpy+0x13>
8010456d:	89 da                	mov    %ebx,%edx
    ;
  while(n-- > 0)
8010456f:	8d 48 ff             	lea    -0x1(%eax),%ecx
80104572:	85 c0                	test   %eax,%eax
80104574:	7e 0a                	jle    80104580 <strncpy+0x42>
    *s++ = 0;
80104576:	c6 02 00             	movb   $0x0,(%edx)
  while(n-- > 0)
80104579:	89 c8                	mov    %ecx,%eax
    *s++ = 0;
8010457b:	8d 52 01             	lea    0x1(%edx),%edx
8010457e:	eb ef                	jmp    8010456f <strncpy+0x31>
  return os;
}
80104580:	89 f8                	mov    %edi,%eax
80104582:	5b                   	pop    %ebx
80104583:	5e                   	pop    %esi
80104584:	5f                   	pop    %edi
80104585:	5d                   	pop    %ebp
80104586:	c3                   	ret    

80104587 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104587:	55                   	push   %ebp
80104588:	89 e5                	mov    %esp,%ebp
8010458a:	57                   	push   %edi
8010458b:	56                   	push   %esi
8010458c:	53                   	push   %ebx
8010458d:	8b 7d 08             	mov    0x8(%ebp),%edi
80104590:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104593:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
80104596:	85 c0                	test   %eax,%eax
80104598:	7e 23                	jle    801045bd <safestrcpy+0x36>
8010459a:	89 fa                	mov    %edi,%edx
8010459c:	eb 04                	jmp    801045a2 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
8010459e:	89 f1                	mov    %esi,%ecx
801045a0:	89 da                	mov    %ebx,%edx
801045a2:	83 e8 01             	sub    $0x1,%eax
801045a5:	85 c0                	test   %eax,%eax
801045a7:	7e 11                	jle    801045ba <safestrcpy+0x33>
801045a9:	8d 71 01             	lea    0x1(%ecx),%esi
801045ac:	8d 5a 01             	lea    0x1(%edx),%ebx
801045af:	0f b6 09             	movzbl (%ecx),%ecx
801045b2:	88 0a                	mov    %cl,(%edx)
801045b4:	84 c9                	test   %cl,%cl
801045b6:	75 e6                	jne    8010459e <safestrcpy+0x17>
801045b8:	89 da                	mov    %ebx,%edx
    ;
  *s = 0;
801045ba:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
801045bd:	89 f8                	mov    %edi,%eax
801045bf:	5b                   	pop    %ebx
801045c0:	5e                   	pop    %esi
801045c1:	5f                   	pop    %edi
801045c2:	5d                   	pop    %ebp
801045c3:	c3                   	ret    

801045c4 <strlen>:

int
strlen(const char *s)
{
801045c4:	55                   	push   %ebp
801045c5:	89 e5                	mov    %esp,%ebp
801045c7:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
801045ca:	b8 00 00 00 00       	mov    $0x0,%eax
801045cf:	eb 03                	jmp    801045d4 <strlen+0x10>
801045d1:	83 c0 01             	add    $0x1,%eax
801045d4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
801045d8:	75 f7                	jne    801045d1 <strlen+0xd>
    ;
  return n;
}
801045da:	5d                   	pop    %ebp
801045db:	c3                   	ret    

801045dc <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801045dc:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801045e0:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801045e4:	55                   	push   %ebp
  pushl %ebx
801045e5:	53                   	push   %ebx
  pushl %esi
801045e6:	56                   	push   %esi
  pushl %edi
801045e7:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801045e8:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801045ea:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801045ec:	5f                   	pop    %edi
  popl %esi
801045ed:	5e                   	pop    %esi
  popl %ebx
801045ee:	5b                   	pop    %ebx
  popl %ebp
801045ef:	5d                   	pop    %ebp
  ret
801045f0:	c3                   	ret    

801045f1 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801045f1:	55                   	push   %ebp
801045f2:	89 e5                	mov    %esp,%ebp
801045f4:	53                   	push   %ebx
801045f5:	83 ec 04             	sub    $0x4,%esp
801045f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801045fb:	e8 6a ee ff ff       	call   8010346a <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104600:	8b 00                	mov    (%eax),%eax
80104602:	39 d8                	cmp    %ebx,%eax
80104604:	76 18                	jbe    8010461e <fetchint+0x2d>
80104606:	8d 53 04             	lea    0x4(%ebx),%edx
80104609:	39 d0                	cmp    %edx,%eax
8010460b:	72 18                	jb     80104625 <fetchint+0x34>
    return -1;
  *ip = *(int*)(addr);
8010460d:	8b 13                	mov    (%ebx),%edx
8010460f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104612:	89 10                	mov    %edx,(%eax)
  return 0;
80104614:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104619:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010461c:	c9                   	leave  
8010461d:	c3                   	ret    
    return -1;
8010461e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104623:	eb f4                	jmp    80104619 <fetchint+0x28>
80104625:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010462a:	eb ed                	jmp    80104619 <fetchint+0x28>

8010462c <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010462c:	55                   	push   %ebp
8010462d:	89 e5                	mov    %esp,%ebp
8010462f:	53                   	push   %ebx
80104630:	83 ec 04             	sub    $0x4,%esp
80104633:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104636:	e8 2f ee ff ff       	call   8010346a <myproc>

  if(addr >= curproc->sz)
8010463b:	39 18                	cmp    %ebx,(%eax)
8010463d:	76 25                	jbe    80104664 <fetchstr+0x38>
    return -1;
  *pp = (char*)addr;
8010463f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104642:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104644:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104646:	89 d8                	mov    %ebx,%eax
80104648:	eb 03                	jmp    8010464d <fetchstr+0x21>
8010464a:	83 c0 01             	add    $0x1,%eax
8010464d:	39 d0                	cmp    %edx,%eax
8010464f:	73 09                	jae    8010465a <fetchstr+0x2e>
    if(*s == 0)
80104651:	80 38 00             	cmpb   $0x0,(%eax)
80104654:	75 f4                	jne    8010464a <fetchstr+0x1e>
      return s - *pp;
80104656:	29 d8                	sub    %ebx,%eax
80104658:	eb 05                	jmp    8010465f <fetchstr+0x33>
  }
  return -1;
8010465a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010465f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104662:	c9                   	leave  
80104663:	c3                   	ret    
    return -1;
80104664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104669:	eb f4                	jmp    8010465f <fetchstr+0x33>

8010466b <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010466b:	55                   	push   %ebp
8010466c:	89 e5                	mov    %esp,%ebp
8010466e:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104671:	e8 f4 ed ff ff       	call   8010346a <myproc>
80104676:	8b 50 18             	mov    0x18(%eax),%edx
80104679:	8b 45 08             	mov    0x8(%ebp),%eax
8010467c:	c1 e0 02             	shl    $0x2,%eax
8010467f:	03 42 44             	add    0x44(%edx),%eax
80104682:	83 ec 08             	sub    $0x8,%esp
80104685:	ff 75 0c             	push   0xc(%ebp)
80104688:	83 c0 04             	add    $0x4,%eax
8010468b:	50                   	push   %eax
8010468c:	e8 60 ff ff ff       	call   801045f1 <fetchint>
}
80104691:	c9                   	leave  
80104692:	c3                   	ret    

80104693 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104693:	55                   	push   %ebp
80104694:	89 e5                	mov    %esp,%ebp
80104696:	56                   	push   %esi
80104697:	53                   	push   %ebx
80104698:	83 ec 10             	sub    $0x10,%esp
8010469b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
8010469e:	e8 c7 ed ff ff       	call   8010346a <myproc>
801046a3:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
801046a5:	83 ec 08             	sub    $0x8,%esp
801046a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801046ab:	50                   	push   %eax
801046ac:	ff 75 08             	push   0x8(%ebp)
801046af:	e8 b7 ff ff ff       	call   8010466b <argint>
801046b4:	83 c4 10             	add    $0x10,%esp
801046b7:	85 c0                	test   %eax,%eax
801046b9:	78 24                	js     801046df <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801046bb:	85 db                	test   %ebx,%ebx
801046bd:	78 27                	js     801046e6 <argptr+0x53>
801046bf:	8b 16                	mov    (%esi),%edx
801046c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c4:	39 c2                	cmp    %eax,%edx
801046c6:	76 25                	jbe    801046ed <argptr+0x5a>
801046c8:	01 c3                	add    %eax,%ebx
801046ca:	39 da                	cmp    %ebx,%edx
801046cc:	72 26                	jb     801046f4 <argptr+0x61>
    return -1;
  *pp = (char*)i;
801046ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801046d1:	89 02                	mov    %eax,(%edx)
  return 0;
801046d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801046db:	5b                   	pop    %ebx
801046dc:	5e                   	pop    %esi
801046dd:	5d                   	pop    %ebp
801046de:	c3                   	ret    
    return -1;
801046df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046e4:	eb f2                	jmp    801046d8 <argptr+0x45>
    return -1;
801046e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046eb:	eb eb                	jmp    801046d8 <argptr+0x45>
801046ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046f2:	eb e4                	jmp    801046d8 <argptr+0x45>
801046f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046f9:	eb dd                	jmp    801046d8 <argptr+0x45>

801046fb <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801046fb:	55                   	push   %ebp
801046fc:	89 e5                	mov    %esp,%ebp
801046fe:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104701:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104704:	50                   	push   %eax
80104705:	ff 75 08             	push   0x8(%ebp)
80104708:	e8 5e ff ff ff       	call   8010466b <argint>
8010470d:	83 c4 10             	add    $0x10,%esp
80104710:	85 c0                	test   %eax,%eax
80104712:	78 13                	js     80104727 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80104714:	83 ec 08             	sub    $0x8,%esp
80104717:	ff 75 0c             	push   0xc(%ebp)
8010471a:	ff 75 f4             	push   -0xc(%ebp)
8010471d:	e8 0a ff ff ff       	call   8010462c <fetchstr>
80104722:	83 c4 10             	add    $0x10,%esp
}
80104725:	c9                   	leave  
80104726:	c3                   	ret    
    return -1;
80104727:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010472c:	eb f7                	jmp    80104725 <argstr+0x2a>

8010472e <syscall>:
[SYS_priofork] sys_priofork,
};

void
syscall(void)
{
8010472e:	55                   	push   %ebp
8010472f:	89 e5                	mov    %esp,%ebp
80104731:	53                   	push   %ebx
80104732:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104735:	e8 30 ed ff ff       	call   8010346a <myproc>
8010473a:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
8010473c:	8b 40 18             	mov    0x18(%eax),%eax
8010473f:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104742:	8d 50 ff             	lea    -0x1(%eax),%edx
80104745:	83 fa 18             	cmp    $0x18,%edx
80104748:	77 17                	ja     80104761 <syscall+0x33>
8010474a:	8b 14 85 e0 77 10 80 	mov    -0x7fef8820(,%eax,4),%edx
80104751:	85 d2                	test   %edx,%edx
80104753:	74 0c                	je     80104761 <syscall+0x33>
    curproc->tf->eax = syscalls[num]();
80104755:	ff d2                	call   *%edx
80104757:	89 c2                	mov    %eax,%edx
80104759:	8b 43 18             	mov    0x18(%ebx),%eax
8010475c:	89 50 1c             	mov    %edx,0x1c(%eax)
8010475f:	eb 1f                	jmp    80104780 <syscall+0x52>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104761:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104764:	50                   	push   %eax
80104765:	52                   	push   %edx
80104766:	ff 73 10             	push   0x10(%ebx)
80104769:	68 b9 77 10 80       	push   $0x801077b9
8010476e:	e8 94 be ff ff       	call   80100607 <cprintf>
    curproc->tf->eax = -1;
80104773:	8b 43 18             	mov    0x18(%ebx),%eax
80104776:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010477d:	83 c4 10             	add    $0x10,%esp
  }
}
80104780:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104783:	c9                   	leave  
80104784:	c3                   	ret    

80104785 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104785:	55                   	push   %ebp
80104786:	89 e5                	mov    %esp,%ebp
80104788:	56                   	push   %esi
80104789:	53                   	push   %ebx
8010478a:	83 ec 18             	sub    $0x18,%esp
8010478d:	89 d6                	mov    %edx,%esi
8010478f:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104791:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104794:	52                   	push   %edx
80104795:	50                   	push   %eax
80104796:	e8 d0 fe ff ff       	call   8010466b <argint>
8010479b:	83 c4 10             	add    $0x10,%esp
8010479e:	85 c0                	test   %eax,%eax
801047a0:	78 35                	js     801047d7 <argfd+0x52>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801047a2:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801047a6:	77 28                	ja     801047d0 <argfd+0x4b>
801047a8:	e8 bd ec ff ff       	call   8010346a <myproc>
801047ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047b0:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
801047b4:	85 c0                	test   %eax,%eax
801047b6:	74 18                	je     801047d0 <argfd+0x4b>
    return -1;
  if(pfd)
801047b8:	85 f6                	test   %esi,%esi
801047ba:	74 02                	je     801047be <argfd+0x39>
    *pfd = fd;
801047bc:	89 16                	mov    %edx,(%esi)
  if(pf)
801047be:	85 db                	test   %ebx,%ebx
801047c0:	74 1c                	je     801047de <argfd+0x59>
    *pf = f;
801047c2:	89 03                	mov    %eax,(%ebx)
  return 0;
801047c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801047c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801047cc:	5b                   	pop    %ebx
801047cd:	5e                   	pop    %esi
801047ce:	5d                   	pop    %ebp
801047cf:	c3                   	ret    
    return -1;
801047d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047d5:	eb f2                	jmp    801047c9 <argfd+0x44>
    return -1;
801047d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047dc:	eb eb                	jmp    801047c9 <argfd+0x44>
  return 0;
801047de:	b8 00 00 00 00       	mov    $0x0,%eax
801047e3:	eb e4                	jmp    801047c9 <argfd+0x44>

801047e5 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801047e5:	55                   	push   %ebp
801047e6:	89 e5                	mov    %esp,%ebp
801047e8:	53                   	push   %ebx
801047e9:	83 ec 04             	sub    $0x4,%esp
801047ec:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801047ee:	e8 77 ec ff ff       	call   8010346a <myproc>
801047f3:	89 c2                	mov    %eax,%edx

  for(fd = 0; fd < NOFILE; fd++){
801047f5:	b8 00 00 00 00       	mov    $0x0,%eax
801047fa:	83 f8 0f             	cmp    $0xf,%eax
801047fd:	7f 12                	jg     80104811 <fdalloc+0x2c>
    if(curproc->ofile[fd] == 0){
801047ff:	83 7c 82 28 00       	cmpl   $0x0,0x28(%edx,%eax,4)
80104804:	74 05                	je     8010480b <fdalloc+0x26>
  for(fd = 0; fd < NOFILE; fd++){
80104806:	83 c0 01             	add    $0x1,%eax
80104809:	eb ef                	jmp    801047fa <fdalloc+0x15>
      curproc->ofile[fd] = f;
8010480b:	89 5c 82 28          	mov    %ebx,0x28(%edx,%eax,4)
      return fd;
8010480f:	eb 05                	jmp    80104816 <fdalloc+0x31>
    }
  }
  return -1;
80104811:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104816:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104819:	c9                   	leave  
8010481a:	c3                   	ret    

8010481b <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010481b:	55                   	push   %ebp
8010481c:	89 e5                	mov    %esp,%ebp
8010481e:	56                   	push   %esi
8010481f:	53                   	push   %ebx
80104820:	83 ec 10             	sub    $0x10,%esp
80104823:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104825:	b8 20 00 00 00       	mov    $0x20,%eax
8010482a:	89 c6                	mov    %eax,%esi
8010482c:	39 43 58             	cmp    %eax,0x58(%ebx)
8010482f:	76 2e                	jbe    8010485f <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104831:	6a 10                	push   $0x10
80104833:	50                   	push   %eax
80104834:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104837:	50                   	push   %eax
80104838:	53                   	push   %ebx
80104839:	e8 23 cf ff ff       	call   80101761 <readi>
8010483e:	83 c4 10             	add    $0x10,%esp
80104841:	83 f8 10             	cmp    $0x10,%eax
80104844:	75 0c                	jne    80104852 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104846:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
8010484b:	75 1e                	jne    8010486b <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010484d:	8d 46 10             	lea    0x10(%esi),%eax
80104850:	eb d8                	jmp    8010482a <isdirempty+0xf>
      panic("isdirempty: readi");
80104852:	83 ec 0c             	sub    $0xc,%esp
80104855:	68 48 78 10 80       	push   $0x80107848
8010485a:	e8 e9 ba ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
8010485f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104864:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104867:	5b                   	pop    %ebx
80104868:	5e                   	pop    %esi
80104869:	5d                   	pop    %ebp
8010486a:	c3                   	ret    
      return 0;
8010486b:	b8 00 00 00 00       	mov    $0x0,%eax
80104870:	eb f2                	jmp    80104864 <isdirempty+0x49>

80104872 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104872:	55                   	push   %ebp
80104873:	89 e5                	mov    %esp,%ebp
80104875:	57                   	push   %edi
80104876:	56                   	push   %esi
80104877:	53                   	push   %ebx
80104878:	83 ec 34             	sub    $0x34,%esp
8010487b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010487e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104881:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104884:	8d 55 da             	lea    -0x26(%ebp),%edx
80104887:	52                   	push   %edx
80104888:	50                   	push   %eax
80104889:	e8 57 d3 ff ff       	call   80101be5 <nameiparent>
8010488e:	89 c6                	mov    %eax,%esi
80104890:	83 c4 10             	add    $0x10,%esp
80104893:	85 c0                	test   %eax,%eax
80104895:	0f 84 33 01 00 00    	je     801049ce <create+0x15c>
    return 0;
  ilock(dp);
8010489b:	83 ec 0c             	sub    $0xc,%esp
8010489e:	50                   	push   %eax
8010489f:	e8 cb cc ff ff       	call   8010156f <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
801048a4:	83 c4 0c             	add    $0xc,%esp
801048a7:	6a 00                	push   $0x0
801048a9:	8d 45 da             	lea    -0x26(%ebp),%eax
801048ac:	50                   	push   %eax
801048ad:	56                   	push   %esi
801048ae:	e8 ec d0 ff ff       	call   8010199f <dirlookup>
801048b3:	89 c3                	mov    %eax,%ebx
801048b5:	83 c4 10             	add    $0x10,%esp
801048b8:	85 c0                	test   %eax,%eax
801048ba:	74 3d                	je     801048f9 <create+0x87>
    iunlockput(dp);
801048bc:	83 ec 0c             	sub    $0xc,%esp
801048bf:	56                   	push   %esi
801048c0:	e8 51 ce ff ff       	call   80101716 <iunlockput>
    ilock(ip);
801048c5:	89 1c 24             	mov    %ebx,(%esp)
801048c8:	e8 a2 cc ff ff       	call   8010156f <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801048cd:	83 c4 10             	add    $0x10,%esp
801048d0:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801048d5:	75 07                	jne    801048de <create+0x6c>
801048d7:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801048dc:	74 11                	je     801048ef <create+0x7d>
      return ip;
    iunlockput(ip);
801048de:	83 ec 0c             	sub    $0xc,%esp
801048e1:	53                   	push   %ebx
801048e2:	e8 2f ce ff ff       	call   80101716 <iunlockput>
    return 0;
801048e7:	83 c4 10             	add    $0x10,%esp
801048ea:	bb 00 00 00 00       	mov    $0x0,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801048ef:	89 d8                	mov    %ebx,%eax
801048f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048f4:	5b                   	pop    %ebx
801048f5:	5e                   	pop    %esi
801048f6:	5f                   	pop    %edi
801048f7:	5d                   	pop    %ebp
801048f8:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
801048f9:	83 ec 08             	sub    $0x8,%esp
801048fc:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80104900:	50                   	push   %eax
80104901:	ff 36                	push   (%esi)
80104903:	e8 64 ca ff ff       	call   8010136c <ialloc>
80104908:	89 c3                	mov    %eax,%ebx
8010490a:	83 c4 10             	add    $0x10,%esp
8010490d:	85 c0                	test   %eax,%eax
8010490f:	74 52                	je     80104963 <create+0xf1>
  ilock(ip);
80104911:	83 ec 0c             	sub    $0xc,%esp
80104914:	50                   	push   %eax
80104915:	e8 55 cc ff ff       	call   8010156f <ilock>
  ip->major = major;
8010491a:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
8010491e:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104922:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
80104926:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
8010492c:	89 1c 24             	mov    %ebx,(%esp)
8010492f:	e8 da ca ff ff       	call   8010140e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104934:	83 c4 10             	add    $0x10,%esp
80104937:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010493c:	74 32                	je     80104970 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
8010493e:	83 ec 04             	sub    $0x4,%esp
80104941:	ff 73 04             	push   0x4(%ebx)
80104944:	8d 45 da             	lea    -0x26(%ebp),%eax
80104947:	50                   	push   %eax
80104948:	56                   	push   %esi
80104949:	e8 ce d1 ff ff       	call   80101b1c <dirlink>
8010494e:	83 c4 10             	add    $0x10,%esp
80104951:	85 c0                	test   %eax,%eax
80104953:	78 6c                	js     801049c1 <create+0x14f>
  iunlockput(dp);
80104955:	83 ec 0c             	sub    $0xc,%esp
80104958:	56                   	push   %esi
80104959:	e8 b8 cd ff ff       	call   80101716 <iunlockput>
  return ip;
8010495e:	83 c4 10             	add    $0x10,%esp
80104961:	eb 8c                	jmp    801048ef <create+0x7d>
    panic("create: ialloc");
80104963:	83 ec 0c             	sub    $0xc,%esp
80104966:	68 5a 78 10 80       	push   $0x8010785a
8010496b:	e8 d8 b9 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104970:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104974:	83 c0 01             	add    $0x1,%eax
80104977:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010497b:	83 ec 0c             	sub    $0xc,%esp
8010497e:	56                   	push   %esi
8010497f:	e8 8a ca ff ff       	call   8010140e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104984:	83 c4 0c             	add    $0xc,%esp
80104987:	ff 73 04             	push   0x4(%ebx)
8010498a:	68 6a 78 10 80       	push   $0x8010786a
8010498f:	53                   	push   %ebx
80104990:	e8 87 d1 ff ff       	call   80101b1c <dirlink>
80104995:	83 c4 10             	add    $0x10,%esp
80104998:	85 c0                	test   %eax,%eax
8010499a:	78 18                	js     801049b4 <create+0x142>
8010499c:	83 ec 04             	sub    $0x4,%esp
8010499f:	ff 76 04             	push   0x4(%esi)
801049a2:	68 69 78 10 80       	push   $0x80107869
801049a7:	53                   	push   %ebx
801049a8:	e8 6f d1 ff ff       	call   80101b1c <dirlink>
801049ad:	83 c4 10             	add    $0x10,%esp
801049b0:	85 c0                	test   %eax,%eax
801049b2:	79 8a                	jns    8010493e <create+0xcc>
      panic("create dots");
801049b4:	83 ec 0c             	sub    $0xc,%esp
801049b7:	68 6c 78 10 80       	push   $0x8010786c
801049bc:	e8 87 b9 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
801049c1:	83 ec 0c             	sub    $0xc,%esp
801049c4:	68 78 78 10 80       	push   $0x80107878
801049c9:	e8 7a b9 ff ff       	call   80100348 <panic>
    return 0;
801049ce:	89 c3                	mov    %eax,%ebx
801049d0:	e9 1a ff ff ff       	jmp    801048ef <create+0x7d>

801049d5 <sys_dup>:
{
801049d5:	55                   	push   %ebp
801049d6:	89 e5                	mov    %esp,%ebp
801049d8:	53                   	push   %ebx
801049d9:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801049dc:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801049df:	ba 00 00 00 00       	mov    $0x0,%edx
801049e4:	b8 00 00 00 00       	mov    $0x0,%eax
801049e9:	e8 97 fd ff ff       	call   80104785 <argfd>
801049ee:	85 c0                	test   %eax,%eax
801049f0:	78 23                	js     80104a15 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801049f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f5:	e8 eb fd ff ff       	call   801047e5 <fdalloc>
801049fa:	89 c3                	mov    %eax,%ebx
801049fc:	85 c0                	test   %eax,%eax
801049fe:	78 1c                	js     80104a1c <sys_dup+0x47>
  filedup(f);
80104a00:	83 ec 0c             	sub    $0xc,%esp
80104a03:	ff 75 f4             	push   -0xc(%ebp)
80104a06:	e8 73 c2 ff ff       	call   80100c7e <filedup>
  return fd;
80104a0b:	83 c4 10             	add    $0x10,%esp
}
80104a0e:	89 d8                	mov    %ebx,%eax
80104a10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a13:	c9                   	leave  
80104a14:	c3                   	ret    
    return -1;
80104a15:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104a1a:	eb f2                	jmp    80104a0e <sys_dup+0x39>
    return -1;
80104a1c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104a21:	eb eb                	jmp    80104a0e <sys_dup+0x39>

80104a23 <sys_read>:
{
80104a23:	55                   	push   %ebp
80104a24:	89 e5                	mov    %esp,%ebp
80104a26:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104a29:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104a2c:	ba 00 00 00 00       	mov    $0x0,%edx
80104a31:	b8 00 00 00 00       	mov    $0x0,%eax
80104a36:	e8 4a fd ff ff       	call   80104785 <argfd>
80104a3b:	85 c0                	test   %eax,%eax
80104a3d:	78 43                	js     80104a82 <sys_read+0x5f>
80104a3f:	83 ec 08             	sub    $0x8,%esp
80104a42:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a45:	50                   	push   %eax
80104a46:	6a 02                	push   $0x2
80104a48:	e8 1e fc ff ff       	call   8010466b <argint>
80104a4d:	83 c4 10             	add    $0x10,%esp
80104a50:	85 c0                	test   %eax,%eax
80104a52:	78 2e                	js     80104a82 <sys_read+0x5f>
80104a54:	83 ec 04             	sub    $0x4,%esp
80104a57:	ff 75 f0             	push   -0x10(%ebp)
80104a5a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104a5d:	50                   	push   %eax
80104a5e:	6a 01                	push   $0x1
80104a60:	e8 2e fc ff ff       	call   80104693 <argptr>
80104a65:	83 c4 10             	add    $0x10,%esp
80104a68:	85 c0                	test   %eax,%eax
80104a6a:	78 16                	js     80104a82 <sys_read+0x5f>
  return fileread(f, p, n);
80104a6c:	83 ec 04             	sub    $0x4,%esp
80104a6f:	ff 75 f0             	push   -0x10(%ebp)
80104a72:	ff 75 ec             	push   -0x14(%ebp)
80104a75:	ff 75 f4             	push   -0xc(%ebp)
80104a78:	e8 53 c3 ff ff       	call   80100dd0 <fileread>
80104a7d:	83 c4 10             	add    $0x10,%esp
}
80104a80:	c9                   	leave  
80104a81:	c3                   	ret    
    return -1;
80104a82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a87:	eb f7                	jmp    80104a80 <sys_read+0x5d>

80104a89 <sys_write>:
{
80104a89:	55                   	push   %ebp
80104a8a:	89 e5                	mov    %esp,%ebp
80104a8c:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104a8f:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104a92:	ba 00 00 00 00       	mov    $0x0,%edx
80104a97:	b8 00 00 00 00       	mov    $0x0,%eax
80104a9c:	e8 e4 fc ff ff       	call   80104785 <argfd>
80104aa1:	85 c0                	test   %eax,%eax
80104aa3:	78 43                	js     80104ae8 <sys_write+0x5f>
80104aa5:	83 ec 08             	sub    $0x8,%esp
80104aa8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104aab:	50                   	push   %eax
80104aac:	6a 02                	push   $0x2
80104aae:	e8 b8 fb ff ff       	call   8010466b <argint>
80104ab3:	83 c4 10             	add    $0x10,%esp
80104ab6:	85 c0                	test   %eax,%eax
80104ab8:	78 2e                	js     80104ae8 <sys_write+0x5f>
80104aba:	83 ec 04             	sub    $0x4,%esp
80104abd:	ff 75 f0             	push   -0x10(%ebp)
80104ac0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104ac3:	50                   	push   %eax
80104ac4:	6a 01                	push   $0x1
80104ac6:	e8 c8 fb ff ff       	call   80104693 <argptr>
80104acb:	83 c4 10             	add    $0x10,%esp
80104ace:	85 c0                	test   %eax,%eax
80104ad0:	78 16                	js     80104ae8 <sys_write+0x5f>
  return filewrite(f, p, n);
80104ad2:	83 ec 04             	sub    $0x4,%esp
80104ad5:	ff 75 f0             	push   -0x10(%ebp)
80104ad8:	ff 75 ec             	push   -0x14(%ebp)
80104adb:	ff 75 f4             	push   -0xc(%ebp)
80104ade:	e8 72 c3 ff ff       	call   80100e55 <filewrite>
80104ae3:	83 c4 10             	add    $0x10,%esp
}
80104ae6:	c9                   	leave  
80104ae7:	c3                   	ret    
    return -1;
80104ae8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aed:	eb f7                	jmp    80104ae6 <sys_write+0x5d>

80104aef <sys_close>:
{
80104aef:	55                   	push   %ebp
80104af0:	89 e5                	mov    %esp,%ebp
80104af2:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104af5:	8d 4d f0             	lea    -0x10(%ebp),%ecx
80104af8:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104afb:	b8 00 00 00 00       	mov    $0x0,%eax
80104b00:	e8 80 fc ff ff       	call   80104785 <argfd>
80104b05:	85 c0                	test   %eax,%eax
80104b07:	78 25                	js     80104b2e <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
80104b09:	e8 5c e9 ff ff       	call   8010346a <myproc>
80104b0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b11:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104b18:	00 
  fileclose(f);
80104b19:	83 ec 0c             	sub    $0xc,%esp
80104b1c:	ff 75 f0             	push   -0x10(%ebp)
80104b1f:	e8 9f c1 ff ff       	call   80100cc3 <fileclose>
  return 0;
80104b24:	83 c4 10             	add    $0x10,%esp
80104b27:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b2c:	c9                   	leave  
80104b2d:	c3                   	ret    
    return -1;
80104b2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b33:	eb f7                	jmp    80104b2c <sys_close+0x3d>

80104b35 <sys_fstat>:
{
80104b35:	55                   	push   %ebp
80104b36:	89 e5                	mov    %esp,%ebp
80104b38:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104b3b:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104b3e:	ba 00 00 00 00       	mov    $0x0,%edx
80104b43:	b8 00 00 00 00       	mov    $0x0,%eax
80104b48:	e8 38 fc ff ff       	call   80104785 <argfd>
80104b4d:	85 c0                	test   %eax,%eax
80104b4f:	78 2a                	js     80104b7b <sys_fstat+0x46>
80104b51:	83 ec 04             	sub    $0x4,%esp
80104b54:	6a 14                	push   $0x14
80104b56:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b59:	50                   	push   %eax
80104b5a:	6a 01                	push   $0x1
80104b5c:	e8 32 fb ff ff       	call   80104693 <argptr>
80104b61:	83 c4 10             	add    $0x10,%esp
80104b64:	85 c0                	test   %eax,%eax
80104b66:	78 13                	js     80104b7b <sys_fstat+0x46>
  return filestat(f, st);
80104b68:	83 ec 08             	sub    $0x8,%esp
80104b6b:	ff 75 f0             	push   -0x10(%ebp)
80104b6e:	ff 75 f4             	push   -0xc(%ebp)
80104b71:	e8 13 c2 ff ff       	call   80100d89 <filestat>
80104b76:	83 c4 10             	add    $0x10,%esp
}
80104b79:	c9                   	leave  
80104b7a:	c3                   	ret    
    return -1;
80104b7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b80:	eb f7                	jmp    80104b79 <sys_fstat+0x44>

80104b82 <sys_link>:
{
80104b82:	55                   	push   %ebp
80104b83:	89 e5                	mov    %esp,%ebp
80104b85:	56                   	push   %esi
80104b86:	53                   	push   %ebx
80104b87:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104b8a:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104b8d:	50                   	push   %eax
80104b8e:	6a 00                	push   $0x0
80104b90:	e8 66 fb ff ff       	call   801046fb <argstr>
80104b95:	83 c4 10             	add    $0x10,%esp
80104b98:	85 c0                	test   %eax,%eax
80104b9a:	0f 88 d3 00 00 00    	js     80104c73 <sys_link+0xf1>
80104ba0:	83 ec 08             	sub    $0x8,%esp
80104ba3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104ba6:	50                   	push   %eax
80104ba7:	6a 01                	push   $0x1
80104ba9:	e8 4d fb ff ff       	call   801046fb <argstr>
80104bae:	83 c4 10             	add    $0x10,%esp
80104bb1:	85 c0                	test   %eax,%eax
80104bb3:	0f 88 ba 00 00 00    	js     80104c73 <sys_link+0xf1>
  begin_op();
80104bb9:	e8 f2 db ff ff       	call   801027b0 <begin_op>
  if((ip = namei(old)) == 0){
80104bbe:	83 ec 0c             	sub    $0xc,%esp
80104bc1:	ff 75 e0             	push   -0x20(%ebp)
80104bc4:	e8 04 d0 ff ff       	call   80101bcd <namei>
80104bc9:	89 c3                	mov    %eax,%ebx
80104bcb:	83 c4 10             	add    $0x10,%esp
80104bce:	85 c0                	test   %eax,%eax
80104bd0:	0f 84 a4 00 00 00    	je     80104c7a <sys_link+0xf8>
  ilock(ip);
80104bd6:	83 ec 0c             	sub    $0xc,%esp
80104bd9:	50                   	push   %eax
80104bda:	e8 90 c9 ff ff       	call   8010156f <ilock>
  if(ip->type == T_DIR){
80104bdf:	83 c4 10             	add    $0x10,%esp
80104be2:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104be7:	0f 84 99 00 00 00    	je     80104c86 <sys_link+0x104>
  ip->nlink++;
80104bed:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104bf1:	83 c0 01             	add    $0x1,%eax
80104bf4:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104bf8:	83 ec 0c             	sub    $0xc,%esp
80104bfb:	53                   	push   %ebx
80104bfc:	e8 0d c8 ff ff       	call   8010140e <iupdate>
  iunlock(ip);
80104c01:	89 1c 24             	mov    %ebx,(%esp)
80104c04:	e8 28 ca ff ff       	call   80101631 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104c09:	83 c4 08             	add    $0x8,%esp
80104c0c:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104c0f:	50                   	push   %eax
80104c10:	ff 75 e4             	push   -0x1c(%ebp)
80104c13:	e8 cd cf ff ff       	call   80101be5 <nameiparent>
80104c18:	89 c6                	mov    %eax,%esi
80104c1a:	83 c4 10             	add    $0x10,%esp
80104c1d:	85 c0                	test   %eax,%eax
80104c1f:	0f 84 85 00 00 00    	je     80104caa <sys_link+0x128>
  ilock(dp);
80104c25:	83 ec 0c             	sub    $0xc,%esp
80104c28:	50                   	push   %eax
80104c29:	e8 41 c9 ff ff       	call   8010156f <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104c2e:	83 c4 10             	add    $0x10,%esp
80104c31:	8b 03                	mov    (%ebx),%eax
80104c33:	39 06                	cmp    %eax,(%esi)
80104c35:	75 67                	jne    80104c9e <sys_link+0x11c>
80104c37:	83 ec 04             	sub    $0x4,%esp
80104c3a:	ff 73 04             	push   0x4(%ebx)
80104c3d:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104c40:	50                   	push   %eax
80104c41:	56                   	push   %esi
80104c42:	e8 d5 ce ff ff       	call   80101b1c <dirlink>
80104c47:	83 c4 10             	add    $0x10,%esp
80104c4a:	85 c0                	test   %eax,%eax
80104c4c:	78 50                	js     80104c9e <sys_link+0x11c>
  iunlockput(dp);
80104c4e:	83 ec 0c             	sub    $0xc,%esp
80104c51:	56                   	push   %esi
80104c52:	e8 bf ca ff ff       	call   80101716 <iunlockput>
  iput(ip);
80104c57:	89 1c 24             	mov    %ebx,(%esp)
80104c5a:	e8 17 ca ff ff       	call   80101676 <iput>
  end_op();
80104c5f:	e8 c6 db ff ff       	call   8010282a <end_op>
  return 0;
80104c64:	83 c4 10             	add    $0x10,%esp
80104c67:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104c6f:	5b                   	pop    %ebx
80104c70:	5e                   	pop    %esi
80104c71:	5d                   	pop    %ebp
80104c72:	c3                   	ret    
    return -1;
80104c73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c78:	eb f2                	jmp    80104c6c <sys_link+0xea>
    end_op();
80104c7a:	e8 ab db ff ff       	call   8010282a <end_op>
    return -1;
80104c7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c84:	eb e6                	jmp    80104c6c <sys_link+0xea>
    iunlockput(ip);
80104c86:	83 ec 0c             	sub    $0xc,%esp
80104c89:	53                   	push   %ebx
80104c8a:	e8 87 ca ff ff       	call   80101716 <iunlockput>
    end_op();
80104c8f:	e8 96 db ff ff       	call   8010282a <end_op>
    return -1;
80104c94:	83 c4 10             	add    $0x10,%esp
80104c97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c9c:	eb ce                	jmp    80104c6c <sys_link+0xea>
    iunlockput(dp);
80104c9e:	83 ec 0c             	sub    $0xc,%esp
80104ca1:	56                   	push   %esi
80104ca2:	e8 6f ca ff ff       	call   80101716 <iunlockput>
    goto bad;
80104ca7:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104caa:	83 ec 0c             	sub    $0xc,%esp
80104cad:	53                   	push   %ebx
80104cae:	e8 bc c8 ff ff       	call   8010156f <ilock>
  ip->nlink--;
80104cb3:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104cb7:	83 e8 01             	sub    $0x1,%eax
80104cba:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104cbe:	89 1c 24             	mov    %ebx,(%esp)
80104cc1:	e8 48 c7 ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
80104cc6:	89 1c 24             	mov    %ebx,(%esp)
80104cc9:	e8 48 ca ff ff       	call   80101716 <iunlockput>
  end_op();
80104cce:	e8 57 db ff ff       	call   8010282a <end_op>
  return -1;
80104cd3:	83 c4 10             	add    $0x10,%esp
80104cd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cdb:	eb 8f                	jmp    80104c6c <sys_link+0xea>

80104cdd <sys_unlink>:
{
80104cdd:	55                   	push   %ebp
80104cde:	89 e5                	mov    %esp,%ebp
80104ce0:	57                   	push   %edi
80104ce1:	56                   	push   %esi
80104ce2:	53                   	push   %ebx
80104ce3:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104ce6:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104ce9:	50                   	push   %eax
80104cea:	6a 00                	push   $0x0
80104cec:	e8 0a fa ff ff       	call   801046fb <argstr>
80104cf1:	83 c4 10             	add    $0x10,%esp
80104cf4:	85 c0                	test   %eax,%eax
80104cf6:	0f 88 83 01 00 00    	js     80104e7f <sys_unlink+0x1a2>
  begin_op();
80104cfc:	e8 af da ff ff       	call   801027b0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104d01:	83 ec 08             	sub    $0x8,%esp
80104d04:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104d07:	50                   	push   %eax
80104d08:	ff 75 c4             	push   -0x3c(%ebp)
80104d0b:	e8 d5 ce ff ff       	call   80101be5 <nameiparent>
80104d10:	89 c6                	mov    %eax,%esi
80104d12:	83 c4 10             	add    $0x10,%esp
80104d15:	85 c0                	test   %eax,%eax
80104d17:	0f 84 ed 00 00 00    	je     80104e0a <sys_unlink+0x12d>
  ilock(dp);
80104d1d:	83 ec 0c             	sub    $0xc,%esp
80104d20:	50                   	push   %eax
80104d21:	e8 49 c8 ff ff       	call   8010156f <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104d26:	83 c4 08             	add    $0x8,%esp
80104d29:	68 6a 78 10 80       	push   $0x8010786a
80104d2e:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104d31:	50                   	push   %eax
80104d32:	e8 53 cc ff ff       	call   8010198a <namecmp>
80104d37:	83 c4 10             	add    $0x10,%esp
80104d3a:	85 c0                	test   %eax,%eax
80104d3c:	0f 84 fc 00 00 00    	je     80104e3e <sys_unlink+0x161>
80104d42:	83 ec 08             	sub    $0x8,%esp
80104d45:	68 69 78 10 80       	push   $0x80107869
80104d4a:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104d4d:	50                   	push   %eax
80104d4e:	e8 37 cc ff ff       	call   8010198a <namecmp>
80104d53:	83 c4 10             	add    $0x10,%esp
80104d56:	85 c0                	test   %eax,%eax
80104d58:	0f 84 e0 00 00 00    	je     80104e3e <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104d5e:	83 ec 04             	sub    $0x4,%esp
80104d61:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104d64:	50                   	push   %eax
80104d65:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104d68:	50                   	push   %eax
80104d69:	56                   	push   %esi
80104d6a:	e8 30 cc ff ff       	call   8010199f <dirlookup>
80104d6f:	89 c3                	mov    %eax,%ebx
80104d71:	83 c4 10             	add    $0x10,%esp
80104d74:	85 c0                	test   %eax,%eax
80104d76:	0f 84 c2 00 00 00    	je     80104e3e <sys_unlink+0x161>
  ilock(ip);
80104d7c:	83 ec 0c             	sub    $0xc,%esp
80104d7f:	50                   	push   %eax
80104d80:	e8 ea c7 ff ff       	call   8010156f <ilock>
  if(ip->nlink < 1)
80104d85:	83 c4 10             	add    $0x10,%esp
80104d88:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104d8d:	0f 8e 83 00 00 00    	jle    80104e16 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104d93:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104d98:	0f 84 85 00 00 00    	je     80104e23 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
80104d9e:	83 ec 04             	sub    $0x4,%esp
80104da1:	6a 10                	push   $0x10
80104da3:	6a 00                	push   $0x0
80104da5:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104da8:	57                   	push   %edi
80104da9:	e8 6d f6 ff ff       	call   8010441b <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104dae:	6a 10                	push   $0x10
80104db0:	ff 75 c0             	push   -0x40(%ebp)
80104db3:	57                   	push   %edi
80104db4:	56                   	push   %esi
80104db5:	e8 a4 ca ff ff       	call   8010185e <writei>
80104dba:	83 c4 20             	add    $0x20,%esp
80104dbd:	83 f8 10             	cmp    $0x10,%eax
80104dc0:	0f 85 90 00 00 00    	jne    80104e56 <sys_unlink+0x179>
  if(ip->type == T_DIR){
80104dc6:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104dcb:	0f 84 92 00 00 00    	je     80104e63 <sys_unlink+0x186>
  iunlockput(dp);
80104dd1:	83 ec 0c             	sub    $0xc,%esp
80104dd4:	56                   	push   %esi
80104dd5:	e8 3c c9 ff ff       	call   80101716 <iunlockput>
  ip->nlink--;
80104dda:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104dde:	83 e8 01             	sub    $0x1,%eax
80104de1:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104de5:	89 1c 24             	mov    %ebx,(%esp)
80104de8:	e8 21 c6 ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
80104ded:	89 1c 24             	mov    %ebx,(%esp)
80104df0:	e8 21 c9 ff ff       	call   80101716 <iunlockput>
  end_op();
80104df5:	e8 30 da ff ff       	call   8010282a <end_op>
  return 0;
80104dfa:	83 c4 10             	add    $0x10,%esp
80104dfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104e05:	5b                   	pop    %ebx
80104e06:	5e                   	pop    %esi
80104e07:	5f                   	pop    %edi
80104e08:	5d                   	pop    %ebp
80104e09:	c3                   	ret    
    end_op();
80104e0a:	e8 1b da ff ff       	call   8010282a <end_op>
    return -1;
80104e0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e14:	eb ec                	jmp    80104e02 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104e16:	83 ec 0c             	sub    $0xc,%esp
80104e19:	68 88 78 10 80       	push   $0x80107888
80104e1e:	e8 25 b5 ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104e23:	89 d8                	mov    %ebx,%eax
80104e25:	e8 f1 f9 ff ff       	call   8010481b <isdirempty>
80104e2a:	85 c0                	test   %eax,%eax
80104e2c:	0f 85 6c ff ff ff    	jne    80104d9e <sys_unlink+0xc1>
    iunlockput(ip);
80104e32:	83 ec 0c             	sub    $0xc,%esp
80104e35:	53                   	push   %ebx
80104e36:	e8 db c8 ff ff       	call   80101716 <iunlockput>
    goto bad;
80104e3b:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104e3e:	83 ec 0c             	sub    $0xc,%esp
80104e41:	56                   	push   %esi
80104e42:	e8 cf c8 ff ff       	call   80101716 <iunlockput>
  end_op();
80104e47:	e8 de d9 ff ff       	call   8010282a <end_op>
  return -1;
80104e4c:	83 c4 10             	add    $0x10,%esp
80104e4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e54:	eb ac                	jmp    80104e02 <sys_unlink+0x125>
    panic("unlink: writei");
80104e56:	83 ec 0c             	sub    $0xc,%esp
80104e59:	68 9a 78 10 80       	push   $0x8010789a
80104e5e:	e8 e5 b4 ff ff       	call   80100348 <panic>
    dp->nlink--;
80104e63:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104e67:	83 e8 01             	sub    $0x1,%eax
80104e6a:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104e6e:	83 ec 0c             	sub    $0xc,%esp
80104e71:	56                   	push   %esi
80104e72:	e8 97 c5 ff ff       	call   8010140e <iupdate>
80104e77:	83 c4 10             	add    $0x10,%esp
80104e7a:	e9 52 ff ff ff       	jmp    80104dd1 <sys_unlink+0xf4>
    return -1;
80104e7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e84:	e9 79 ff ff ff       	jmp    80104e02 <sys_unlink+0x125>

80104e89 <sys_open>:

int
sys_open(void)
{
80104e89:	55                   	push   %ebp
80104e8a:	89 e5                	mov    %esp,%ebp
80104e8c:	57                   	push   %edi
80104e8d:	56                   	push   %esi
80104e8e:	53                   	push   %ebx
80104e8f:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104e92:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104e95:	50                   	push   %eax
80104e96:	6a 00                	push   $0x0
80104e98:	e8 5e f8 ff ff       	call   801046fb <argstr>
80104e9d:	83 c4 10             	add    $0x10,%esp
80104ea0:	85 c0                	test   %eax,%eax
80104ea2:	0f 88 a0 00 00 00    	js     80104f48 <sys_open+0xbf>
80104ea8:	83 ec 08             	sub    $0x8,%esp
80104eab:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104eae:	50                   	push   %eax
80104eaf:	6a 01                	push   $0x1
80104eb1:	e8 b5 f7 ff ff       	call   8010466b <argint>
80104eb6:	83 c4 10             	add    $0x10,%esp
80104eb9:	85 c0                	test   %eax,%eax
80104ebb:	0f 88 87 00 00 00    	js     80104f48 <sys_open+0xbf>
    return -1;

  begin_op();
80104ec1:	e8 ea d8 ff ff       	call   801027b0 <begin_op>

  if(omode & O_CREATE){
80104ec6:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104eca:	0f 84 8b 00 00 00    	je     80104f5b <sys_open+0xd2>
    ip = create(path, T_FILE, 0, 0);
80104ed0:	83 ec 0c             	sub    $0xc,%esp
80104ed3:	6a 00                	push   $0x0
80104ed5:	b9 00 00 00 00       	mov    $0x0,%ecx
80104eda:	ba 02 00 00 00       	mov    $0x2,%edx
80104edf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ee2:	e8 8b f9 ff ff       	call   80104872 <create>
80104ee7:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104ee9:	83 c4 10             	add    $0x10,%esp
80104eec:	85 c0                	test   %eax,%eax
80104eee:	74 5f                	je     80104f4f <sys_open+0xc6>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104ef0:	e8 28 bd ff ff       	call   80100c1d <filealloc>
80104ef5:	89 c3                	mov    %eax,%ebx
80104ef7:	85 c0                	test   %eax,%eax
80104ef9:	0f 84 b5 00 00 00    	je     80104fb4 <sys_open+0x12b>
80104eff:	e8 e1 f8 ff ff       	call   801047e5 <fdalloc>
80104f04:	89 c7                	mov    %eax,%edi
80104f06:	85 c0                	test   %eax,%eax
80104f08:	0f 88 a6 00 00 00    	js     80104fb4 <sys_open+0x12b>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104f0e:	83 ec 0c             	sub    $0xc,%esp
80104f11:	56                   	push   %esi
80104f12:	e8 1a c7 ff ff       	call   80101631 <iunlock>
  end_op();
80104f17:	e8 0e d9 ff ff       	call   8010282a <end_op>

  f->type = FD_INODE;
80104f1c:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104f22:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104f25:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104f2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f2f:	83 c4 10             	add    $0x10,%esp
80104f32:	a8 01                	test   $0x1,%al
80104f34:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104f38:	a8 03                	test   $0x3,%al
80104f3a:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104f3e:	89 f8                	mov    %edi,%eax
80104f40:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f43:	5b                   	pop    %ebx
80104f44:	5e                   	pop    %esi
80104f45:	5f                   	pop    %edi
80104f46:	5d                   	pop    %ebp
80104f47:	c3                   	ret    
    return -1;
80104f48:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104f4d:	eb ef                	jmp    80104f3e <sys_open+0xb5>
      end_op();
80104f4f:	e8 d6 d8 ff ff       	call   8010282a <end_op>
      return -1;
80104f54:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104f59:	eb e3                	jmp    80104f3e <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104f5b:	83 ec 0c             	sub    $0xc,%esp
80104f5e:	ff 75 e4             	push   -0x1c(%ebp)
80104f61:	e8 67 cc ff ff       	call   80101bcd <namei>
80104f66:	89 c6                	mov    %eax,%esi
80104f68:	83 c4 10             	add    $0x10,%esp
80104f6b:	85 c0                	test   %eax,%eax
80104f6d:	74 39                	je     80104fa8 <sys_open+0x11f>
    ilock(ip);
80104f6f:	83 ec 0c             	sub    $0xc,%esp
80104f72:	50                   	push   %eax
80104f73:	e8 f7 c5 ff ff       	call   8010156f <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104f78:	83 c4 10             	add    $0x10,%esp
80104f7b:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104f80:	0f 85 6a ff ff ff    	jne    80104ef0 <sys_open+0x67>
80104f86:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104f8a:	0f 84 60 ff ff ff    	je     80104ef0 <sys_open+0x67>
      iunlockput(ip);
80104f90:	83 ec 0c             	sub    $0xc,%esp
80104f93:	56                   	push   %esi
80104f94:	e8 7d c7 ff ff       	call   80101716 <iunlockput>
      end_op();
80104f99:	e8 8c d8 ff ff       	call   8010282a <end_op>
      return -1;
80104f9e:	83 c4 10             	add    $0x10,%esp
80104fa1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104fa6:	eb 96                	jmp    80104f3e <sys_open+0xb5>
      end_op();
80104fa8:	e8 7d d8 ff ff       	call   8010282a <end_op>
      return -1;
80104fad:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104fb2:	eb 8a                	jmp    80104f3e <sys_open+0xb5>
    if(f)
80104fb4:	85 db                	test   %ebx,%ebx
80104fb6:	74 0c                	je     80104fc4 <sys_open+0x13b>
      fileclose(f);
80104fb8:	83 ec 0c             	sub    $0xc,%esp
80104fbb:	53                   	push   %ebx
80104fbc:	e8 02 bd ff ff       	call   80100cc3 <fileclose>
80104fc1:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104fc4:	83 ec 0c             	sub    $0xc,%esp
80104fc7:	56                   	push   %esi
80104fc8:	e8 49 c7 ff ff       	call   80101716 <iunlockput>
    end_op();
80104fcd:	e8 58 d8 ff ff       	call   8010282a <end_op>
    return -1;
80104fd2:	83 c4 10             	add    $0x10,%esp
80104fd5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104fda:	e9 5f ff ff ff       	jmp    80104f3e <sys_open+0xb5>

80104fdf <sys_mkdir>:

int
sys_mkdir(void)
{
80104fdf:	55                   	push   %ebp
80104fe0:	89 e5                	mov    %esp,%ebp
80104fe2:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104fe5:	e8 c6 d7 ff ff       	call   801027b0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104fea:	83 ec 08             	sub    $0x8,%esp
80104fed:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ff0:	50                   	push   %eax
80104ff1:	6a 00                	push   $0x0
80104ff3:	e8 03 f7 ff ff       	call   801046fb <argstr>
80104ff8:	83 c4 10             	add    $0x10,%esp
80104ffb:	85 c0                	test   %eax,%eax
80104ffd:	78 36                	js     80105035 <sys_mkdir+0x56>
80104fff:	83 ec 0c             	sub    $0xc,%esp
80105002:	6a 00                	push   $0x0
80105004:	b9 00 00 00 00       	mov    $0x0,%ecx
80105009:	ba 01 00 00 00       	mov    $0x1,%edx
8010500e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105011:	e8 5c f8 ff ff       	call   80104872 <create>
80105016:	83 c4 10             	add    $0x10,%esp
80105019:	85 c0                	test   %eax,%eax
8010501b:	74 18                	je     80105035 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010501d:	83 ec 0c             	sub    $0xc,%esp
80105020:	50                   	push   %eax
80105021:	e8 f0 c6 ff ff       	call   80101716 <iunlockput>
  end_op();
80105026:	e8 ff d7 ff ff       	call   8010282a <end_op>
  return 0;
8010502b:	83 c4 10             	add    $0x10,%esp
8010502e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105033:	c9                   	leave  
80105034:	c3                   	ret    
    end_op();
80105035:	e8 f0 d7 ff ff       	call   8010282a <end_op>
    return -1;
8010503a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010503f:	eb f2                	jmp    80105033 <sys_mkdir+0x54>

80105041 <sys_mknod>:

int
sys_mknod(void)
{
80105041:	55                   	push   %ebp
80105042:	89 e5                	mov    %esp,%ebp
80105044:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105047:	e8 64 d7 ff ff       	call   801027b0 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010504c:	83 ec 08             	sub    $0x8,%esp
8010504f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105052:	50                   	push   %eax
80105053:	6a 00                	push   $0x0
80105055:	e8 a1 f6 ff ff       	call   801046fb <argstr>
8010505a:	83 c4 10             	add    $0x10,%esp
8010505d:	85 c0                	test   %eax,%eax
8010505f:	78 62                	js     801050c3 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80105061:	83 ec 08             	sub    $0x8,%esp
80105064:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105067:	50                   	push   %eax
80105068:	6a 01                	push   $0x1
8010506a:	e8 fc f5 ff ff       	call   8010466b <argint>
  if((argstr(0, &path)) < 0 ||
8010506f:	83 c4 10             	add    $0x10,%esp
80105072:	85 c0                	test   %eax,%eax
80105074:	78 4d                	js     801050c3 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80105076:	83 ec 08             	sub    $0x8,%esp
80105079:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010507c:	50                   	push   %eax
8010507d:	6a 02                	push   $0x2
8010507f:	e8 e7 f5 ff ff       	call   8010466b <argint>
     argint(1, &major) < 0 ||
80105084:	83 c4 10             	add    $0x10,%esp
80105087:	85 c0                	test   %eax,%eax
80105089:	78 38                	js     801050c3 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010508b:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
8010508f:	83 ec 0c             	sub    $0xc,%esp
80105092:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80105096:	50                   	push   %eax
80105097:	ba 03 00 00 00       	mov    $0x3,%edx
8010509c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010509f:	e8 ce f7 ff ff       	call   80104872 <create>
     argint(2, &minor) < 0 ||
801050a4:	83 c4 10             	add    $0x10,%esp
801050a7:	85 c0                	test   %eax,%eax
801050a9:	74 18                	je     801050c3 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
801050ab:	83 ec 0c             	sub    $0xc,%esp
801050ae:	50                   	push   %eax
801050af:	e8 62 c6 ff ff       	call   80101716 <iunlockput>
  end_op();
801050b4:	e8 71 d7 ff ff       	call   8010282a <end_op>
  return 0;
801050b9:	83 c4 10             	add    $0x10,%esp
801050bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050c1:	c9                   	leave  
801050c2:	c3                   	ret    
    end_op();
801050c3:	e8 62 d7 ff ff       	call   8010282a <end_op>
    return -1;
801050c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050cd:	eb f2                	jmp    801050c1 <sys_mknod+0x80>

801050cf <sys_chdir>:

int
sys_chdir(void)
{
801050cf:	55                   	push   %ebp
801050d0:	89 e5                	mov    %esp,%ebp
801050d2:	56                   	push   %esi
801050d3:	53                   	push   %ebx
801050d4:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801050d7:	e8 8e e3 ff ff       	call   8010346a <myproc>
801050dc:	89 c6                	mov    %eax,%esi
  
  begin_op();
801050de:	e8 cd d6 ff ff       	call   801027b0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801050e3:	83 ec 08             	sub    $0x8,%esp
801050e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050e9:	50                   	push   %eax
801050ea:	6a 00                	push   $0x0
801050ec:	e8 0a f6 ff ff       	call   801046fb <argstr>
801050f1:	83 c4 10             	add    $0x10,%esp
801050f4:	85 c0                	test   %eax,%eax
801050f6:	78 52                	js     8010514a <sys_chdir+0x7b>
801050f8:	83 ec 0c             	sub    $0xc,%esp
801050fb:	ff 75 f4             	push   -0xc(%ebp)
801050fe:	e8 ca ca ff ff       	call   80101bcd <namei>
80105103:	89 c3                	mov    %eax,%ebx
80105105:	83 c4 10             	add    $0x10,%esp
80105108:	85 c0                	test   %eax,%eax
8010510a:	74 3e                	je     8010514a <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
8010510c:	83 ec 0c             	sub    $0xc,%esp
8010510f:	50                   	push   %eax
80105110:	e8 5a c4 ff ff       	call   8010156f <ilock>
  if(ip->type != T_DIR){
80105115:	83 c4 10             	add    $0x10,%esp
80105118:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010511d:	75 37                	jne    80105156 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010511f:	83 ec 0c             	sub    $0xc,%esp
80105122:	53                   	push   %ebx
80105123:	e8 09 c5 ff ff       	call   80101631 <iunlock>
  iput(curproc->cwd);
80105128:	83 c4 04             	add    $0x4,%esp
8010512b:	ff 76 68             	push   0x68(%esi)
8010512e:	e8 43 c5 ff ff       	call   80101676 <iput>
  end_op();
80105133:	e8 f2 d6 ff ff       	call   8010282a <end_op>
  curproc->cwd = ip;
80105138:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
8010513b:	83 c4 10             	add    $0x10,%esp
8010513e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105143:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105146:	5b                   	pop    %ebx
80105147:	5e                   	pop    %esi
80105148:	5d                   	pop    %ebp
80105149:	c3                   	ret    
    end_op();
8010514a:	e8 db d6 ff ff       	call   8010282a <end_op>
    return -1;
8010514f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105154:	eb ed                	jmp    80105143 <sys_chdir+0x74>
    iunlockput(ip);
80105156:	83 ec 0c             	sub    $0xc,%esp
80105159:	53                   	push   %ebx
8010515a:	e8 b7 c5 ff ff       	call   80101716 <iunlockput>
    end_op();
8010515f:	e8 c6 d6 ff ff       	call   8010282a <end_op>
    return -1;
80105164:	83 c4 10             	add    $0x10,%esp
80105167:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010516c:	eb d5                	jmp    80105143 <sys_chdir+0x74>

8010516e <sys_exec>:

int
sys_exec(void)
{
8010516e:	55                   	push   %ebp
8010516f:	89 e5                	mov    %esp,%ebp
80105171:	53                   	push   %ebx
80105172:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105178:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010517b:	50                   	push   %eax
8010517c:	6a 00                	push   $0x0
8010517e:	e8 78 f5 ff ff       	call   801046fb <argstr>
80105183:	83 c4 10             	add    $0x10,%esp
80105186:	85 c0                	test   %eax,%eax
80105188:	78 38                	js     801051c2 <sys_exec+0x54>
8010518a:	83 ec 08             	sub    $0x8,%esp
8010518d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105193:	50                   	push   %eax
80105194:	6a 01                	push   $0x1
80105196:	e8 d0 f4 ff ff       	call   8010466b <argint>
8010519b:	83 c4 10             	add    $0x10,%esp
8010519e:	85 c0                	test   %eax,%eax
801051a0:	78 20                	js     801051c2 <sys_exec+0x54>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
801051a2:	83 ec 04             	sub    $0x4,%esp
801051a5:	68 80 00 00 00       	push   $0x80
801051aa:	6a 00                	push   $0x0
801051ac:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
801051b2:	50                   	push   %eax
801051b3:	e8 63 f2 ff ff       	call   8010441b <memset>
801051b8:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801051bb:	bb 00 00 00 00       	mov    $0x0,%ebx
801051c0:	eb 2c                	jmp    801051ee <sys_exec+0x80>
    return -1;
801051c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051c7:	eb 78                	jmp    80105241 <sys_exec+0xd3>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
801051c9:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
801051d0:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801051d4:	83 ec 08             	sub    $0x8,%esp
801051d7:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
801051dd:	50                   	push   %eax
801051de:	ff 75 f4             	push   -0xc(%ebp)
801051e1:	e8 e8 b6 ff ff       	call   801008ce <exec>
801051e6:	83 c4 10             	add    $0x10,%esp
801051e9:	eb 56                	jmp    80105241 <sys_exec+0xd3>
  for(i=0;; i++){
801051eb:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
801051ee:	83 fb 1f             	cmp    $0x1f,%ebx
801051f1:	77 49                	ja     8010523c <sys_exec+0xce>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801051f3:	83 ec 08             	sub    $0x8,%esp
801051f6:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801051fc:	50                   	push   %eax
801051fd:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80105203:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80105206:	50                   	push   %eax
80105207:	e8 e5 f3 ff ff       	call   801045f1 <fetchint>
8010520c:	83 c4 10             	add    $0x10,%esp
8010520f:	85 c0                	test   %eax,%eax
80105211:	78 33                	js     80105246 <sys_exec+0xd8>
    if(uarg == 0){
80105213:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105219:	85 c0                	test   %eax,%eax
8010521b:	74 ac                	je     801051c9 <sys_exec+0x5b>
    if(fetchstr(uarg, &argv[i]) < 0)
8010521d:	83 ec 08             	sub    $0x8,%esp
80105220:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80105227:	52                   	push   %edx
80105228:	50                   	push   %eax
80105229:	e8 fe f3 ff ff       	call   8010462c <fetchstr>
8010522e:	83 c4 10             	add    $0x10,%esp
80105231:	85 c0                	test   %eax,%eax
80105233:	79 b6                	jns    801051eb <sys_exec+0x7d>
      return -1;
80105235:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010523a:	eb 05                	jmp    80105241 <sys_exec+0xd3>
      return -1;
8010523c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105241:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105244:	c9                   	leave  
80105245:	c3                   	ret    
      return -1;
80105246:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010524b:	eb f4                	jmp    80105241 <sys_exec+0xd3>

8010524d <sys_pipe>:

int
sys_pipe(void)
{
8010524d:	55                   	push   %ebp
8010524e:	89 e5                	mov    %esp,%ebp
80105250:	53                   	push   %ebx
80105251:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105254:	6a 08                	push   $0x8
80105256:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105259:	50                   	push   %eax
8010525a:	6a 00                	push   $0x0
8010525c:	e8 32 f4 ff ff       	call   80104693 <argptr>
80105261:	83 c4 10             	add    $0x10,%esp
80105264:	85 c0                	test   %eax,%eax
80105266:	78 79                	js     801052e1 <sys_pipe+0x94>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105268:	83 ec 08             	sub    $0x8,%esp
8010526b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010526e:	50                   	push   %eax
8010526f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105272:	50                   	push   %eax
80105273:	e8 f4 da ff ff       	call   80102d6c <pipealloc>
80105278:	83 c4 10             	add    $0x10,%esp
8010527b:	85 c0                	test   %eax,%eax
8010527d:	78 69                	js     801052e8 <sys_pipe+0x9b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010527f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105282:	e8 5e f5 ff ff       	call   801047e5 <fdalloc>
80105287:	89 c3                	mov    %eax,%ebx
80105289:	85 c0                	test   %eax,%eax
8010528b:	78 21                	js     801052ae <sys_pipe+0x61>
8010528d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105290:	e8 50 f5 ff ff       	call   801047e5 <fdalloc>
80105295:	85 c0                	test   %eax,%eax
80105297:	78 15                	js     801052ae <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80105299:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010529c:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
8010529e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052a1:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
801052a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052ac:	c9                   	leave  
801052ad:	c3                   	ret    
    if(fd0 >= 0)
801052ae:	85 db                	test   %ebx,%ebx
801052b0:	79 20                	jns    801052d2 <sys_pipe+0x85>
    fileclose(rf);
801052b2:	83 ec 0c             	sub    $0xc,%esp
801052b5:	ff 75 f0             	push   -0x10(%ebp)
801052b8:	e8 06 ba ff ff       	call   80100cc3 <fileclose>
    fileclose(wf);
801052bd:	83 c4 04             	add    $0x4,%esp
801052c0:	ff 75 ec             	push   -0x14(%ebp)
801052c3:	e8 fb b9 ff ff       	call   80100cc3 <fileclose>
    return -1;
801052c8:	83 c4 10             	add    $0x10,%esp
801052cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052d0:	eb d7                	jmp    801052a9 <sys_pipe+0x5c>
      myproc()->ofile[fd0] = 0;
801052d2:	e8 93 e1 ff ff       	call   8010346a <myproc>
801052d7:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
801052de:	00 
801052df:	eb d1                	jmp    801052b2 <sys_pipe+0x65>
    return -1;
801052e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052e6:	eb c1                	jmp    801052a9 <sys_pipe+0x5c>
    return -1;
801052e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ed:	eb ba                	jmp    801052a9 <sys_pipe+0x5c>

801052ef <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801052ef:	55                   	push   %ebp
801052f0:	89 e5                	mov    %esp,%ebp
801052f2:	83 ec 08             	sub    $0x8,%esp
  return fork();
801052f5:	e8 eb e6 ff ff       	call   801039e5 <fork>
}
801052fa:	c9                   	leave  
801052fb:	c3                   	ret    

801052fc <sys_priofork>:

int
sys_priofork(void)
{
801052fc:	55                   	push   %ebp
801052fd:	89 e5                	mov    %esp,%ebp
801052ff:	83 ec 20             	sub    $0x20,%esp
  int default_level;
  if(argint(0, &default_level) < 0)
80105302:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105305:	50                   	push   %eax
80105306:	6a 00                	push   $0x0
80105308:	e8 5e f3 ff ff       	call   8010466b <argint>
8010530d:	83 c4 10             	add    $0x10,%esp
80105310:	85 c0                	test   %eax,%eax
80105312:	78 10                	js     80105324 <sys_priofork+0x28>
    return -1;
  return priofork(default_level);
80105314:	83 ec 0c             	sub    $0xc,%esp
80105317:	ff 75 f4             	push   -0xc(%ebp)
8010531a:	e8 7e e5 ff ff       	call   8010389d <priofork>
8010531f:	83 c4 10             	add    $0x10,%esp
}
80105322:	c9                   	leave  
80105323:	c3                   	ret    
    return -1;
80105324:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105329:	eb f7                	jmp    80105322 <sys_priofork+0x26>

8010532b <sys_exit>:

int
sys_exit(void)
{
8010532b:	55                   	push   %ebp
8010532c:	89 e5                	mov    %esp,%ebp
8010532e:	83 ec 08             	sub    $0x8,%esp
  exit();
80105331:	e8 33 ea ff ff       	call   80103d69 <exit>
  return 0;  // not reached
}
80105336:	b8 00 00 00 00       	mov    $0x0,%eax
8010533b:	c9                   	leave  
8010533c:	c3                   	ret    

8010533d <sys_wait>:

int
sys_wait(void)
{
8010533d:	55                   	push   %ebp
8010533e:	89 e5                	mov    %esp,%ebp
80105340:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105343:	e8 b5 eb ff ff       	call   80103efd <wait>
}
80105348:	c9                   	leave  
80105349:	c3                   	ret    

8010534a <sys_kill>:

int
sys_kill(void)
{
8010534a:	55                   	push   %ebp
8010534b:	89 e5                	mov    %esp,%ebp
8010534d:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105350:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105353:	50                   	push   %eax
80105354:	6a 00                	push   $0x0
80105356:	e8 10 f3 ff ff       	call   8010466b <argint>
8010535b:	83 c4 10             	add    $0x10,%esp
8010535e:	85 c0                	test   %eax,%eax
80105360:	78 10                	js     80105372 <sys_kill+0x28>
    return -1;
  return kill(pid);
80105362:	83 ec 0c             	sub    $0xc,%esp
80105365:	ff 75 f4             	push   -0xc(%ebp)
80105368:	e8 90 ec ff ff       	call   80103ffd <kill>
8010536d:	83 c4 10             	add    $0x10,%esp
}
80105370:	c9                   	leave  
80105371:	c3                   	ret    
    return -1;
80105372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105377:	eb f7                	jmp    80105370 <sys_kill+0x26>

80105379 <sys_getpid>:

int
sys_getpid(void)
{
80105379:	55                   	push   %ebp
8010537a:	89 e5                	mov    %esp,%ebp
8010537c:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010537f:	e8 e6 e0 ff ff       	call   8010346a <myproc>
80105384:	8b 40 10             	mov    0x10(%eax),%eax
}
80105387:	c9                   	leave  
80105388:	c3                   	ret    

80105389 <sys_sbrk>:

int
sys_sbrk(void)
{
80105389:	55                   	push   %ebp
8010538a:	89 e5                	mov    %esp,%ebp
8010538c:	53                   	push   %ebx
8010538d:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105390:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105393:	50                   	push   %eax
80105394:	6a 00                	push   $0x0
80105396:	e8 d0 f2 ff ff       	call   8010466b <argint>
8010539b:	83 c4 10             	add    $0x10,%esp
8010539e:	85 c0                	test   %eax,%eax
801053a0:	78 20                	js     801053c2 <sys_sbrk+0x39>
    return -1;
  addr = myproc()->sz;
801053a2:	e8 c3 e0 ff ff       	call   8010346a <myproc>
801053a7:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
801053a9:	83 ec 0c             	sub    $0xc,%esp
801053ac:	ff 75 f4             	push   -0xc(%ebp)
801053af:	e8 7e e4 ff ff       	call   80103832 <growproc>
801053b4:	83 c4 10             	add    $0x10,%esp
801053b7:	85 c0                	test   %eax,%eax
801053b9:	78 0e                	js     801053c9 <sys_sbrk+0x40>
    return -1;
  return addr;
}
801053bb:	89 d8                	mov    %ebx,%eax
801053bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801053c0:	c9                   	leave  
801053c1:	c3                   	ret    
    return -1;
801053c2:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801053c7:	eb f2                	jmp    801053bb <sys_sbrk+0x32>
    return -1;
801053c9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801053ce:	eb eb                	jmp    801053bb <sys_sbrk+0x32>

801053d0 <sys_sleep>:

int
sys_sleep(void)
{
801053d0:	55                   	push   %ebp
801053d1:	89 e5                	mov    %esp,%ebp
801053d3:	53                   	push   %ebx
801053d4:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801053d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053da:	50                   	push   %eax
801053db:	6a 00                	push   $0x0
801053dd:	e8 89 f2 ff ff       	call   8010466b <argint>
801053e2:	83 c4 10             	add    $0x10,%esp
801053e5:	85 c0                	test   %eax,%eax
801053e7:	78 75                	js     8010545e <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
801053e9:	83 ec 0c             	sub    $0xc,%esp
801053ec:	68 40 46 11 80       	push   $0x80114640
801053f1:	e8 79 ef ff ff       	call   8010436f <acquire>
  ticks0 = ticks;
801053f6:	8b 1d 20 46 11 80    	mov    0x80114620,%ebx
  while(ticks - ticks0 < n){
801053fc:	83 c4 10             	add    $0x10,%esp
801053ff:	a1 20 46 11 80       	mov    0x80114620,%eax
80105404:	29 d8                	sub    %ebx,%eax
80105406:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105409:	73 39                	jae    80105444 <sys_sleep+0x74>
    if(myproc()->killed){
8010540b:	e8 5a e0 ff ff       	call   8010346a <myproc>
80105410:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105414:	75 17                	jne    8010542d <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105416:	83 ec 08             	sub    $0x8,%esp
80105419:	68 40 46 11 80       	push   $0x80114640
8010541e:	68 20 46 11 80       	push   $0x80114620
80105423:	e8 44 ea ff ff       	call   80103e6c <sleep>
80105428:	83 c4 10             	add    $0x10,%esp
8010542b:	eb d2                	jmp    801053ff <sys_sleep+0x2f>
      release(&tickslock);
8010542d:	83 ec 0c             	sub    $0xc,%esp
80105430:	68 40 46 11 80       	push   $0x80114640
80105435:	e8 9a ef ff ff       	call   801043d4 <release>
      return -1;
8010543a:	83 c4 10             	add    $0x10,%esp
8010543d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105442:	eb 15                	jmp    80105459 <sys_sleep+0x89>
  }
  release(&tickslock);
80105444:	83 ec 0c             	sub    $0xc,%esp
80105447:	68 40 46 11 80       	push   $0x80114640
8010544c:	e8 83 ef ff ff       	call   801043d4 <release>
  return 0;
80105451:	83 c4 10             	add    $0x10,%esp
80105454:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105459:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010545c:	c9                   	leave  
8010545d:	c3                   	ret    
    return -1;
8010545e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105463:	eb f4                	jmp    80105459 <sys_sleep+0x89>

80105465 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105465:	55                   	push   %ebp
80105466:	89 e5                	mov    %esp,%ebp
80105468:	53                   	push   %ebx
80105469:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
8010546c:	68 40 46 11 80       	push   $0x80114640
80105471:	e8 f9 ee ff ff       	call   8010436f <acquire>
  xticks = ticks;
80105476:	8b 1d 20 46 11 80    	mov    0x80114620,%ebx
  release(&tickslock);
8010547c:	c7 04 24 40 46 11 80 	movl   $0x80114640,(%esp)
80105483:	e8 4c ef ff ff       	call   801043d4 <release>
  return xticks;
}
80105488:	89 d8                	mov    %ebx,%eax
8010548a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010548d:	c9                   	leave  
8010548e:	c3                   	ret    

8010548f <sys_yield>:

int
sys_yield(void)
{
8010548f:	55                   	push   %ebp
80105490:	89 e5                	mov    %esp,%ebp
80105492:	83 ec 08             	sub    $0x8,%esp
  yield();
80105495:	e8 a0 e9 ff ff       	call   80103e3a <yield>
  return 0;
}
8010549a:	b8 00 00 00 00       	mov    $0x0,%eax
8010549f:	c9                   	leave  
801054a0:	c3                   	ret    

801054a1 <sys_shutdown>:

int sys_shutdown(void)
{
801054a1:	55                   	push   %ebp
801054a2:	89 e5                	mov    %esp,%ebp
801054a4:	83 ec 08             	sub    $0x8,%esp
  shutdown();
801054a7:	e8 4f cd ff ff       	call   801021fb <shutdown>
  return 0;
}
801054ac:	b8 00 00 00 00       	mov    $0x0,%eax
801054b1:	c9                   	leave  
801054b2:	c3                   	ret    

801054b3 <sys_schedlog>:

int sys_schedlog(void)
{
801054b3:	55                   	push   %ebp
801054b4:	89 e5                	mov    %esp,%ebp
801054b6:	83 ec 20             	sub    $0x20,%esp
  int n;

  if(argint(0, &n) < 0)
801054b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054bc:	50                   	push   %eax
801054bd:	6a 00                	push   $0x0
801054bf:	e8 a7 f1 ff ff       	call   8010466b <argint>
801054c4:	83 c4 10             	add    $0x10,%esp
801054c7:	85 c0                	test   %eax,%eax
801054c9:	78 15                	js     801054e0 <sys_schedlog+0x2d>
    return -1;

  schedlog(n);
801054cb:	83 ec 0c             	sub    $0xc,%esp
801054ce:	ff 75 f4             	push   -0xc(%ebp)
801054d1:	e8 16 dd ff ff       	call   801031ec <schedlog>
  return 0;
801054d6:	83 c4 10             	add    $0x10,%esp
801054d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054de:	c9                   	leave  
801054df:	c3                   	ret    
    return -1;
801054e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054e5:	eb f7                	jmp    801054de <sys_schedlog+0x2b>

801054e7 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801054e7:	1e                   	push   %ds
  pushl %es
801054e8:	06                   	push   %es
  pushl %fs
801054e9:	0f a0                	push   %fs
  pushl %gs
801054eb:	0f a8                	push   %gs
  pushal
801054ed:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801054ee:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801054f2:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801054f4:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801054f6:	54                   	push   %esp
  call trap
801054f7:	e8 37 01 00 00       	call   80105633 <trap>
  addl $4, %esp
801054fc:	83 c4 04             	add    $0x4,%esp

801054ff <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801054ff:	61                   	popa   
  popl %gs
80105500:	0f a9                	pop    %gs
  popl %fs
80105502:	0f a1                	pop    %fs
  popl %es
80105504:	07                   	pop    %es
  popl %ds
80105505:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105506:	83 c4 08             	add    $0x8,%esp
  iret
80105509:	cf                   	iret   

8010550a <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010550a:	55                   	push   %ebp
8010550b:	89 e5                	mov    %esp,%ebp
8010550d:	53                   	push   %ebx
8010550e:	83 ec 04             	sub    $0x4,%esp
  int i;

  for(i = 0; i < 256; i++)
80105511:	b8 00 00 00 00       	mov    $0x0,%eax
80105516:	eb 76                	jmp    8010558e <tvinit+0x84>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105518:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
8010551f:	66 89 0c c5 80 46 11 	mov    %cx,-0x7feeb980(,%eax,8)
80105526:	80 
80105527:	66 c7 04 c5 82 46 11 	movw   $0x8,-0x7feeb97e(,%eax,8)
8010552e:	80 08 00 
80105531:	0f b6 14 c5 84 46 11 	movzbl -0x7feeb97c(,%eax,8),%edx
80105538:	80 
80105539:	83 e2 e0             	and    $0xffffffe0,%edx
8010553c:	88 14 c5 84 46 11 80 	mov    %dl,-0x7feeb97c(,%eax,8)
80105543:	c6 04 c5 84 46 11 80 	movb   $0x0,-0x7feeb97c(,%eax,8)
8010554a:	00 
8010554b:	0f b6 14 c5 85 46 11 	movzbl -0x7feeb97b(,%eax,8),%edx
80105552:	80 
80105553:	83 e2 f0             	and    $0xfffffff0,%edx
80105556:	83 ca 0e             	or     $0xe,%edx
80105559:	88 14 c5 85 46 11 80 	mov    %dl,-0x7feeb97b(,%eax,8)
80105560:	89 d3                	mov    %edx,%ebx
80105562:	83 e3 ef             	and    $0xffffffef,%ebx
80105565:	88 1c c5 85 46 11 80 	mov    %bl,-0x7feeb97b(,%eax,8)
8010556c:	83 e2 8f             	and    $0xffffff8f,%edx
8010556f:	88 14 c5 85 46 11 80 	mov    %dl,-0x7feeb97b(,%eax,8)
80105576:	83 ca 80             	or     $0xffffff80,%edx
80105579:	88 14 c5 85 46 11 80 	mov    %dl,-0x7feeb97b(,%eax,8)
80105580:	c1 e9 10             	shr    $0x10,%ecx
80105583:	66 89 0c c5 86 46 11 	mov    %cx,-0x7feeb97a(,%eax,8)
8010558a:	80 
  for(i = 0; i < 256; i++)
8010558b:	83 c0 01             	add    $0x1,%eax
8010558e:	3d ff 00 00 00       	cmp    $0xff,%eax
80105593:	7e 83                	jle    80105518 <tvinit+0xe>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105595:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
8010559b:	66 89 15 80 48 11 80 	mov    %dx,0x80114880
801055a2:	66 c7 05 82 48 11 80 	movw   $0x8,0x80114882
801055a9:	08 00 
801055ab:	0f b6 05 84 48 11 80 	movzbl 0x80114884,%eax
801055b2:	83 e0 e0             	and    $0xffffffe0,%eax
801055b5:	a2 84 48 11 80       	mov    %al,0x80114884
801055ba:	c6 05 84 48 11 80 00 	movb   $0x0,0x80114884
801055c1:	0f b6 05 85 48 11 80 	movzbl 0x80114885,%eax
801055c8:	83 c8 0f             	or     $0xf,%eax
801055cb:	a2 85 48 11 80       	mov    %al,0x80114885
801055d0:	83 e0 ef             	and    $0xffffffef,%eax
801055d3:	a2 85 48 11 80       	mov    %al,0x80114885
801055d8:	89 c1                	mov    %eax,%ecx
801055da:	83 c9 60             	or     $0x60,%ecx
801055dd:	88 0d 85 48 11 80    	mov    %cl,0x80114885
801055e3:	83 c8 e0             	or     $0xffffffe0,%eax
801055e6:	a2 85 48 11 80       	mov    %al,0x80114885
801055eb:	c1 ea 10             	shr    $0x10,%edx
801055ee:	66 89 15 86 48 11 80 	mov    %dx,0x80114886

  initlock(&tickslock, "time");
801055f5:	83 ec 08             	sub    $0x8,%esp
801055f8:	68 a9 78 10 80       	push   $0x801078a9
801055fd:	68 40 46 11 80       	push   $0x80114640
80105602:	e8 2c ec ff ff       	call   80104233 <initlock>
}
80105607:	83 c4 10             	add    $0x10,%esp
8010560a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010560d:	c9                   	leave  
8010560e:	c3                   	ret    

8010560f <idtinit>:

void
idtinit(void)
{
8010560f:	55                   	push   %ebp
80105610:	89 e5                	mov    %esp,%ebp
80105612:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105615:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
8010561b:	b8 80 46 11 80       	mov    $0x80114680,%eax
80105620:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105624:	c1 e8 10             	shr    $0x10,%eax
80105627:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010562b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010562e:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105631:	c9                   	leave  
80105632:	c3                   	ret    

80105633 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105633:	55                   	push   %ebp
80105634:	89 e5                	mov    %esp,%ebp
80105636:	57                   	push   %edi
80105637:	56                   	push   %esi
80105638:	53                   	push   %ebx
80105639:	83 ec 1c             	sub    $0x1c,%esp
8010563c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
8010563f:	8b 43 30             	mov    0x30(%ebx),%eax
80105642:	83 f8 40             	cmp    $0x40,%eax
80105645:	74 13                	je     8010565a <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105647:	83 e8 20             	sub    $0x20,%eax
8010564a:	83 f8 1f             	cmp    $0x1f,%eax
8010564d:	0f 87 3a 01 00 00    	ja     8010578d <trap+0x15a>
80105653:	ff 24 85 84 79 10 80 	jmp    *-0x7fef867c(,%eax,4)
    if(myproc()->killed)
8010565a:	e8 0b de ff ff       	call   8010346a <myproc>
8010565f:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105663:	75 1f                	jne    80105684 <trap+0x51>
    myproc()->tf = tf;
80105665:	e8 00 de ff ff       	call   8010346a <myproc>
8010566a:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
8010566d:	e8 bc f0 ff ff       	call   8010472e <syscall>
    if(myproc()->killed)
80105672:	e8 f3 dd ff ff       	call   8010346a <myproc>
80105677:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010567b:	74 7e                	je     801056fb <trap+0xc8>
      exit();
8010567d:	e8 e7 e6 ff ff       	call   80103d69 <exit>
    return;
80105682:	eb 77                	jmp    801056fb <trap+0xc8>
      exit();
80105684:	e8 e0 e6 ff ff       	call   80103d69 <exit>
80105689:	eb da                	jmp    80105665 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010568b:	e8 bf dd ff ff       	call   8010344f <cpuid>
80105690:	85 c0                	test   %eax,%eax
80105692:	74 6f                	je     80105703 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80105694:	e8 0f cd ff ff       	call   801023a8 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105699:	e8 cc dd ff ff       	call   8010346a <myproc>
8010569e:	85 c0                	test   %eax,%eax
801056a0:	74 1c                	je     801056be <trap+0x8b>
801056a2:	e8 c3 dd ff ff       	call   8010346a <myproc>
801056a7:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801056ab:	74 11                	je     801056be <trap+0x8b>
801056ad:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801056b1:	83 e0 03             	and    $0x3,%eax
801056b4:	66 83 f8 03          	cmp    $0x3,%ax
801056b8:	0f 84 62 01 00 00    	je     80105820 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801056be:	e8 a7 dd ff ff       	call   8010346a <myproc>
801056c3:	85 c0                	test   %eax,%eax
801056c5:	74 0f                	je     801056d6 <trap+0xa3>
801056c7:	e8 9e dd ff ff       	call   8010346a <myproc>
801056cc:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
801056d0:	0f 84 54 01 00 00    	je     8010582a <trap+0x1f7>
      yield();
    }
  }

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801056d6:	e8 8f dd ff ff       	call   8010346a <myproc>
801056db:	85 c0                	test   %eax,%eax
801056dd:	74 1c                	je     801056fb <trap+0xc8>
801056df:	e8 86 dd ff ff       	call   8010346a <myproc>
801056e4:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801056e8:	74 11                	je     801056fb <trap+0xc8>
801056ea:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801056ee:	83 e0 03             	and    $0x3,%eax
801056f1:	66 83 f8 03          	cmp    $0x3,%ax
801056f5:	0f 84 92 01 00 00    	je     8010588d <trap+0x25a>
    exit();
}
801056fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801056fe:	5b                   	pop    %ebx
801056ff:	5e                   	pop    %esi
80105700:	5f                   	pop    %edi
80105701:	5d                   	pop    %ebp
80105702:	c3                   	ret    
      acquire(&tickslock);
80105703:	83 ec 0c             	sub    $0xc,%esp
80105706:	68 40 46 11 80       	push   $0x80114640
8010570b:	e8 5f ec ff ff       	call   8010436f <acquire>
      ticks++;
80105710:	83 05 20 46 11 80 01 	addl   $0x1,0x80114620
      wakeup(&ticks);
80105717:	c7 04 24 20 46 11 80 	movl   $0x80114620,(%esp)
8010571e:	e8 b1 e8 ff ff       	call   80103fd4 <wakeup>
      release(&tickslock);
80105723:	c7 04 24 40 46 11 80 	movl   $0x80114640,(%esp)
8010572a:	e8 a5 ec ff ff       	call   801043d4 <release>
8010572f:	83 c4 10             	add    $0x10,%esp
80105732:	e9 5d ff ff ff       	jmp    80105694 <trap+0x61>
    ideintr();
80105737:	e8 20 c6 ff ff       	call   80101d5c <ideintr>
    lapiceoi();
8010573c:	e8 67 cc ff ff       	call   801023a8 <lapiceoi>
    break;
80105741:	e9 53 ff ff ff       	jmp    80105699 <trap+0x66>
    kbdintr();
80105746:	e8 9b ca ff ff       	call   801021e6 <kbdintr>
    lapiceoi();
8010574b:	e8 58 cc ff ff       	call   801023a8 <lapiceoi>
    break;
80105750:	e9 44 ff ff ff       	jmp    80105699 <trap+0x66>
    uartintr();
80105755:	e8 4d 02 00 00       	call   801059a7 <uartintr>
    lapiceoi();
8010575a:	e8 49 cc ff ff       	call   801023a8 <lapiceoi>
    break;
8010575f:	e9 35 ff ff ff       	jmp    80105699 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105764:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80105767:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010576b:	e8 df dc ff ff       	call   8010344f <cpuid>
80105770:	57                   	push   %edi
80105771:	0f b7 f6             	movzwl %si,%esi
80105774:	56                   	push   %esi
80105775:	50                   	push   %eax
80105776:	68 b4 78 10 80       	push   $0x801078b4
8010577b:	e8 87 ae ff ff       	call   80100607 <cprintf>
    lapiceoi();
80105780:	e8 23 cc ff ff       	call   801023a8 <lapiceoi>
    break;
80105785:	83 c4 10             	add    $0x10,%esp
80105788:	e9 0c ff ff ff       	jmp    80105699 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
8010578d:	e8 d8 dc ff ff       	call   8010346a <myproc>
80105792:	85 c0                	test   %eax,%eax
80105794:	74 5f                	je     801057f5 <trap+0x1c2>
80105796:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010579a:	74 59                	je     801057f5 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010579c:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010579f:	8b 43 38             	mov    0x38(%ebx),%eax
801057a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801057a5:	e8 a5 dc ff ff       	call   8010344f <cpuid>
801057aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
801057ad:	8b 4b 34             	mov    0x34(%ebx),%ecx
801057b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
801057b3:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
801057b6:	e8 af dc ff ff       	call   8010346a <myproc>
801057bb:	8d 50 6c             	lea    0x6c(%eax),%edx
801057be:	89 55 d8             	mov    %edx,-0x28(%ebp)
801057c1:	e8 a4 dc ff ff       	call   8010346a <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801057c6:	57                   	push   %edi
801057c7:	ff 75 e4             	push   -0x1c(%ebp)
801057ca:	ff 75 e0             	push   -0x20(%ebp)
801057cd:	ff 75 dc             	push   -0x24(%ebp)
801057d0:	56                   	push   %esi
801057d1:	ff 75 d8             	push   -0x28(%ebp)
801057d4:	ff 70 10             	push   0x10(%eax)
801057d7:	68 0c 79 10 80       	push   $0x8010790c
801057dc:	e8 26 ae ff ff       	call   80100607 <cprintf>
    myproc()->killed = 1;
801057e1:	83 c4 20             	add    $0x20,%esp
801057e4:	e8 81 dc ff ff       	call   8010346a <myproc>
801057e9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801057f0:	e9 a4 fe ff ff       	jmp    80105699 <trap+0x66>
801057f5:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801057f8:	8b 73 38             	mov    0x38(%ebx),%esi
801057fb:	e8 4f dc ff ff       	call   8010344f <cpuid>
80105800:	83 ec 0c             	sub    $0xc,%esp
80105803:	57                   	push   %edi
80105804:	56                   	push   %esi
80105805:	50                   	push   %eax
80105806:	ff 73 30             	push   0x30(%ebx)
80105809:	68 d8 78 10 80       	push   $0x801078d8
8010580e:	e8 f4 ad ff ff       	call   80100607 <cprintf>
      panic("trap");
80105813:	83 c4 14             	add    $0x14,%esp
80105816:	68 ae 78 10 80       	push   $0x801078ae
8010581b:	e8 28 ab ff ff       	call   80100348 <panic>
    exit();
80105820:	e8 44 e5 ff ff       	call   80103d69 <exit>
80105825:	e9 94 fe ff ff       	jmp    801056be <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
8010582a:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
8010582e:	0f 85 a2 fe ff ff    	jne    801056d6 <trap+0xa3>
    if (!mycpu()->queue)
80105834:	e8 ba db ff ff       	call   801033f3 <mycpu>
80105839:	83 b8 b0 00 00 00 00 	cmpl   $0x0,0xb0(%eax)
80105840:	74 3e                	je     80105880 <trap+0x24d>
    int proc_ticks = --myproc()->ticks_left;
80105842:	e8 23 dc ff ff       	call   8010346a <myproc>
80105847:	8b 48 7c             	mov    0x7c(%eax),%ecx
8010584a:	8d 71 ff             	lea    -0x1(%ecx),%esi
8010584d:	89 70 7c             	mov    %esi,0x7c(%eax)
    int level_ticks = --mycpu()->queue->ticks_left;
80105850:	e8 9e db ff ff       	call   801033f3 <mycpu>
80105855:	8b 90 b0 00 00 00    	mov    0xb0(%eax),%edx
8010585b:	8b 42 38             	mov    0x38(%edx),%eax
8010585e:	83 e8 01             	sub    $0x1,%eax
80105861:	89 42 38             	mov    %eax,0x38(%edx)
    if (proc_ticks <= 0 || level_ticks <= 0){
80105864:	85 f6                	test   %esi,%esi
80105866:	0f 9e c2             	setle  %dl
80105869:	85 c0                	test   %eax,%eax
8010586b:	0f 9e c0             	setle  %al
8010586e:	08 c2                	or     %al,%dl
80105870:	0f 84 60 fe ff ff    	je     801056d6 <trap+0xa3>
      yield();
80105876:	e8 bf e5 ff ff       	call   80103e3a <yield>
8010587b:	e9 56 fe ff ff       	jmp    801056d6 <trap+0xa3>
      panic("Running process located outside active/expired set.");
80105880:	83 ec 0c             	sub    $0xc,%esp
80105883:	68 50 79 10 80       	push   $0x80107950
80105888:	e8 bb aa ff ff       	call   80100348 <panic>
    exit();
8010588d:	e8 d7 e4 ff ff       	call   80103d69 <exit>
80105892:	e9 64 fe ff ff       	jmp    801056fb <trap+0xc8>

80105897 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105897:	83 3d 80 4e 11 80 00 	cmpl   $0x0,0x80114e80
8010589e:	74 14                	je     801058b4 <uartgetc+0x1d>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801058a0:	ba fd 03 00 00       	mov    $0x3fd,%edx
801058a5:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801058a6:	a8 01                	test   $0x1,%al
801058a8:	74 10                	je     801058ba <uartgetc+0x23>
801058aa:	ba f8 03 00 00       	mov    $0x3f8,%edx
801058af:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801058b0:	0f b6 c0             	movzbl %al,%eax
801058b3:	c3                   	ret    
    return -1;
801058b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b9:	c3                   	ret    
    return -1;
801058ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058bf:	c3                   	ret    

801058c0 <uartputc>:
  if(!uart)
801058c0:	83 3d 80 4e 11 80 00 	cmpl   $0x0,0x80114e80
801058c7:	74 3b                	je     80105904 <uartputc+0x44>
{
801058c9:	55                   	push   %ebp
801058ca:	89 e5                	mov    %esp,%ebp
801058cc:	53                   	push   %ebx
801058cd:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801058d0:	bb 00 00 00 00       	mov    $0x0,%ebx
801058d5:	eb 10                	jmp    801058e7 <uartputc+0x27>
    microdelay(10);
801058d7:	83 ec 0c             	sub    $0xc,%esp
801058da:	6a 0a                	push   $0xa
801058dc:	e8 e8 ca ff ff       	call   801023c9 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801058e1:	83 c3 01             	add    $0x1,%ebx
801058e4:	83 c4 10             	add    $0x10,%esp
801058e7:	83 fb 7f             	cmp    $0x7f,%ebx
801058ea:	7f 0a                	jg     801058f6 <uartputc+0x36>
801058ec:	ba fd 03 00 00       	mov    $0x3fd,%edx
801058f1:	ec                   	in     (%dx),%al
801058f2:	a8 20                	test   $0x20,%al
801058f4:	74 e1                	je     801058d7 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801058f6:	8b 45 08             	mov    0x8(%ebp),%eax
801058f9:	ba f8 03 00 00       	mov    $0x3f8,%edx
801058fe:	ee                   	out    %al,(%dx)
}
801058ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105902:	c9                   	leave  
80105903:	c3                   	ret    
80105904:	c3                   	ret    

80105905 <uartinit>:
{
80105905:	55                   	push   %ebp
80105906:	89 e5                	mov    %esp,%ebp
80105908:	56                   	push   %esi
80105909:	53                   	push   %ebx
8010590a:	b9 00 00 00 00       	mov    $0x0,%ecx
8010590f:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105914:	89 c8                	mov    %ecx,%eax
80105916:	ee                   	out    %al,(%dx)
80105917:	be fb 03 00 00       	mov    $0x3fb,%esi
8010591c:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105921:	89 f2                	mov    %esi,%edx
80105923:	ee                   	out    %al,(%dx)
80105924:	b8 0c 00 00 00       	mov    $0xc,%eax
80105929:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010592e:	ee                   	out    %al,(%dx)
8010592f:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105934:	89 c8                	mov    %ecx,%eax
80105936:	89 da                	mov    %ebx,%edx
80105938:	ee                   	out    %al,(%dx)
80105939:	b8 03 00 00 00       	mov    $0x3,%eax
8010593e:	89 f2                	mov    %esi,%edx
80105940:	ee                   	out    %al,(%dx)
80105941:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105946:	89 c8                	mov    %ecx,%eax
80105948:	ee                   	out    %al,(%dx)
80105949:	b8 01 00 00 00       	mov    $0x1,%eax
8010594e:	89 da                	mov    %ebx,%edx
80105950:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105951:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105956:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105957:	3c ff                	cmp    $0xff,%al
80105959:	74 45                	je     801059a0 <uartinit+0x9b>
  uart = 1;
8010595b:	c7 05 80 4e 11 80 01 	movl   $0x1,0x80114e80
80105962:	00 00 00 
80105965:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010596a:	ec                   	in     (%dx),%al
8010596b:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105970:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105971:	83 ec 08             	sub    $0x8,%esp
80105974:	6a 00                	push   $0x0
80105976:	6a 04                	push   $0x4
80105978:	e8 e4 c5 ff ff       	call   80101f61 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
8010597d:	83 c4 10             	add    $0x10,%esp
80105980:	bb 04 7a 10 80       	mov    $0x80107a04,%ebx
80105985:	eb 12                	jmp    80105999 <uartinit+0x94>
    uartputc(*p);
80105987:	83 ec 0c             	sub    $0xc,%esp
8010598a:	0f be c0             	movsbl %al,%eax
8010598d:	50                   	push   %eax
8010598e:	e8 2d ff ff ff       	call   801058c0 <uartputc>
  for(p="xv6...\n"; *p; p++)
80105993:	83 c3 01             	add    $0x1,%ebx
80105996:	83 c4 10             	add    $0x10,%esp
80105999:	0f b6 03             	movzbl (%ebx),%eax
8010599c:	84 c0                	test   %al,%al
8010599e:	75 e7                	jne    80105987 <uartinit+0x82>
}
801059a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801059a3:	5b                   	pop    %ebx
801059a4:	5e                   	pop    %esi
801059a5:	5d                   	pop    %ebp
801059a6:	c3                   	ret    

801059a7 <uartintr>:

void
uartintr(void)
{
801059a7:	55                   	push   %ebp
801059a8:	89 e5                	mov    %esp,%ebp
801059aa:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801059ad:	68 97 58 10 80       	push   $0x80105897
801059b2:	e8 7c ad ff ff       	call   80100733 <consoleintr>
}
801059b7:	83 c4 10             	add    $0x10,%esp
801059ba:	c9                   	leave  
801059bb:	c3                   	ret    

801059bc <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801059bc:	6a 00                	push   $0x0
  pushl $0
801059be:	6a 00                	push   $0x0
  jmp alltraps
801059c0:	e9 22 fb ff ff       	jmp    801054e7 <alltraps>

801059c5 <vector1>:
.globl vector1
vector1:
  pushl $0
801059c5:	6a 00                	push   $0x0
  pushl $1
801059c7:	6a 01                	push   $0x1
  jmp alltraps
801059c9:	e9 19 fb ff ff       	jmp    801054e7 <alltraps>

801059ce <vector2>:
.globl vector2
vector2:
  pushl $0
801059ce:	6a 00                	push   $0x0
  pushl $2
801059d0:	6a 02                	push   $0x2
  jmp alltraps
801059d2:	e9 10 fb ff ff       	jmp    801054e7 <alltraps>

801059d7 <vector3>:
.globl vector3
vector3:
  pushl $0
801059d7:	6a 00                	push   $0x0
  pushl $3
801059d9:	6a 03                	push   $0x3
  jmp alltraps
801059db:	e9 07 fb ff ff       	jmp    801054e7 <alltraps>

801059e0 <vector4>:
.globl vector4
vector4:
  pushl $0
801059e0:	6a 00                	push   $0x0
  pushl $4
801059e2:	6a 04                	push   $0x4
  jmp alltraps
801059e4:	e9 fe fa ff ff       	jmp    801054e7 <alltraps>

801059e9 <vector5>:
.globl vector5
vector5:
  pushl $0
801059e9:	6a 00                	push   $0x0
  pushl $5
801059eb:	6a 05                	push   $0x5
  jmp alltraps
801059ed:	e9 f5 fa ff ff       	jmp    801054e7 <alltraps>

801059f2 <vector6>:
.globl vector6
vector6:
  pushl $0
801059f2:	6a 00                	push   $0x0
  pushl $6
801059f4:	6a 06                	push   $0x6
  jmp alltraps
801059f6:	e9 ec fa ff ff       	jmp    801054e7 <alltraps>

801059fb <vector7>:
.globl vector7
vector7:
  pushl $0
801059fb:	6a 00                	push   $0x0
  pushl $7
801059fd:	6a 07                	push   $0x7
  jmp alltraps
801059ff:	e9 e3 fa ff ff       	jmp    801054e7 <alltraps>

80105a04 <vector8>:
.globl vector8
vector8:
  pushl $8
80105a04:	6a 08                	push   $0x8
  jmp alltraps
80105a06:	e9 dc fa ff ff       	jmp    801054e7 <alltraps>

80105a0b <vector9>:
.globl vector9
vector9:
  pushl $0
80105a0b:	6a 00                	push   $0x0
  pushl $9
80105a0d:	6a 09                	push   $0x9
  jmp alltraps
80105a0f:	e9 d3 fa ff ff       	jmp    801054e7 <alltraps>

80105a14 <vector10>:
.globl vector10
vector10:
  pushl $10
80105a14:	6a 0a                	push   $0xa
  jmp alltraps
80105a16:	e9 cc fa ff ff       	jmp    801054e7 <alltraps>

80105a1b <vector11>:
.globl vector11
vector11:
  pushl $11
80105a1b:	6a 0b                	push   $0xb
  jmp alltraps
80105a1d:	e9 c5 fa ff ff       	jmp    801054e7 <alltraps>

80105a22 <vector12>:
.globl vector12
vector12:
  pushl $12
80105a22:	6a 0c                	push   $0xc
  jmp alltraps
80105a24:	e9 be fa ff ff       	jmp    801054e7 <alltraps>

80105a29 <vector13>:
.globl vector13
vector13:
  pushl $13
80105a29:	6a 0d                	push   $0xd
  jmp alltraps
80105a2b:	e9 b7 fa ff ff       	jmp    801054e7 <alltraps>

80105a30 <vector14>:
.globl vector14
vector14:
  pushl $14
80105a30:	6a 0e                	push   $0xe
  jmp alltraps
80105a32:	e9 b0 fa ff ff       	jmp    801054e7 <alltraps>

80105a37 <vector15>:
.globl vector15
vector15:
  pushl $0
80105a37:	6a 00                	push   $0x0
  pushl $15
80105a39:	6a 0f                	push   $0xf
  jmp alltraps
80105a3b:	e9 a7 fa ff ff       	jmp    801054e7 <alltraps>

80105a40 <vector16>:
.globl vector16
vector16:
  pushl $0
80105a40:	6a 00                	push   $0x0
  pushl $16
80105a42:	6a 10                	push   $0x10
  jmp alltraps
80105a44:	e9 9e fa ff ff       	jmp    801054e7 <alltraps>

80105a49 <vector17>:
.globl vector17
vector17:
  pushl $17
80105a49:	6a 11                	push   $0x11
  jmp alltraps
80105a4b:	e9 97 fa ff ff       	jmp    801054e7 <alltraps>

80105a50 <vector18>:
.globl vector18
vector18:
  pushl $0
80105a50:	6a 00                	push   $0x0
  pushl $18
80105a52:	6a 12                	push   $0x12
  jmp alltraps
80105a54:	e9 8e fa ff ff       	jmp    801054e7 <alltraps>

80105a59 <vector19>:
.globl vector19
vector19:
  pushl $0
80105a59:	6a 00                	push   $0x0
  pushl $19
80105a5b:	6a 13                	push   $0x13
  jmp alltraps
80105a5d:	e9 85 fa ff ff       	jmp    801054e7 <alltraps>

80105a62 <vector20>:
.globl vector20
vector20:
  pushl $0
80105a62:	6a 00                	push   $0x0
  pushl $20
80105a64:	6a 14                	push   $0x14
  jmp alltraps
80105a66:	e9 7c fa ff ff       	jmp    801054e7 <alltraps>

80105a6b <vector21>:
.globl vector21
vector21:
  pushl $0
80105a6b:	6a 00                	push   $0x0
  pushl $21
80105a6d:	6a 15                	push   $0x15
  jmp alltraps
80105a6f:	e9 73 fa ff ff       	jmp    801054e7 <alltraps>

80105a74 <vector22>:
.globl vector22
vector22:
  pushl $0
80105a74:	6a 00                	push   $0x0
  pushl $22
80105a76:	6a 16                	push   $0x16
  jmp alltraps
80105a78:	e9 6a fa ff ff       	jmp    801054e7 <alltraps>

80105a7d <vector23>:
.globl vector23
vector23:
  pushl $0
80105a7d:	6a 00                	push   $0x0
  pushl $23
80105a7f:	6a 17                	push   $0x17
  jmp alltraps
80105a81:	e9 61 fa ff ff       	jmp    801054e7 <alltraps>

80105a86 <vector24>:
.globl vector24
vector24:
  pushl $0
80105a86:	6a 00                	push   $0x0
  pushl $24
80105a88:	6a 18                	push   $0x18
  jmp alltraps
80105a8a:	e9 58 fa ff ff       	jmp    801054e7 <alltraps>

80105a8f <vector25>:
.globl vector25
vector25:
  pushl $0
80105a8f:	6a 00                	push   $0x0
  pushl $25
80105a91:	6a 19                	push   $0x19
  jmp alltraps
80105a93:	e9 4f fa ff ff       	jmp    801054e7 <alltraps>

80105a98 <vector26>:
.globl vector26
vector26:
  pushl $0
80105a98:	6a 00                	push   $0x0
  pushl $26
80105a9a:	6a 1a                	push   $0x1a
  jmp alltraps
80105a9c:	e9 46 fa ff ff       	jmp    801054e7 <alltraps>

80105aa1 <vector27>:
.globl vector27
vector27:
  pushl $0
80105aa1:	6a 00                	push   $0x0
  pushl $27
80105aa3:	6a 1b                	push   $0x1b
  jmp alltraps
80105aa5:	e9 3d fa ff ff       	jmp    801054e7 <alltraps>

80105aaa <vector28>:
.globl vector28
vector28:
  pushl $0
80105aaa:	6a 00                	push   $0x0
  pushl $28
80105aac:	6a 1c                	push   $0x1c
  jmp alltraps
80105aae:	e9 34 fa ff ff       	jmp    801054e7 <alltraps>

80105ab3 <vector29>:
.globl vector29
vector29:
  pushl $0
80105ab3:	6a 00                	push   $0x0
  pushl $29
80105ab5:	6a 1d                	push   $0x1d
  jmp alltraps
80105ab7:	e9 2b fa ff ff       	jmp    801054e7 <alltraps>

80105abc <vector30>:
.globl vector30
vector30:
  pushl $0
80105abc:	6a 00                	push   $0x0
  pushl $30
80105abe:	6a 1e                	push   $0x1e
  jmp alltraps
80105ac0:	e9 22 fa ff ff       	jmp    801054e7 <alltraps>

80105ac5 <vector31>:
.globl vector31
vector31:
  pushl $0
80105ac5:	6a 00                	push   $0x0
  pushl $31
80105ac7:	6a 1f                	push   $0x1f
  jmp alltraps
80105ac9:	e9 19 fa ff ff       	jmp    801054e7 <alltraps>

80105ace <vector32>:
.globl vector32
vector32:
  pushl $0
80105ace:	6a 00                	push   $0x0
  pushl $32
80105ad0:	6a 20                	push   $0x20
  jmp alltraps
80105ad2:	e9 10 fa ff ff       	jmp    801054e7 <alltraps>

80105ad7 <vector33>:
.globl vector33
vector33:
  pushl $0
80105ad7:	6a 00                	push   $0x0
  pushl $33
80105ad9:	6a 21                	push   $0x21
  jmp alltraps
80105adb:	e9 07 fa ff ff       	jmp    801054e7 <alltraps>

80105ae0 <vector34>:
.globl vector34
vector34:
  pushl $0
80105ae0:	6a 00                	push   $0x0
  pushl $34
80105ae2:	6a 22                	push   $0x22
  jmp alltraps
80105ae4:	e9 fe f9 ff ff       	jmp    801054e7 <alltraps>

80105ae9 <vector35>:
.globl vector35
vector35:
  pushl $0
80105ae9:	6a 00                	push   $0x0
  pushl $35
80105aeb:	6a 23                	push   $0x23
  jmp alltraps
80105aed:	e9 f5 f9 ff ff       	jmp    801054e7 <alltraps>

80105af2 <vector36>:
.globl vector36
vector36:
  pushl $0
80105af2:	6a 00                	push   $0x0
  pushl $36
80105af4:	6a 24                	push   $0x24
  jmp alltraps
80105af6:	e9 ec f9 ff ff       	jmp    801054e7 <alltraps>

80105afb <vector37>:
.globl vector37
vector37:
  pushl $0
80105afb:	6a 00                	push   $0x0
  pushl $37
80105afd:	6a 25                	push   $0x25
  jmp alltraps
80105aff:	e9 e3 f9 ff ff       	jmp    801054e7 <alltraps>

80105b04 <vector38>:
.globl vector38
vector38:
  pushl $0
80105b04:	6a 00                	push   $0x0
  pushl $38
80105b06:	6a 26                	push   $0x26
  jmp alltraps
80105b08:	e9 da f9 ff ff       	jmp    801054e7 <alltraps>

80105b0d <vector39>:
.globl vector39
vector39:
  pushl $0
80105b0d:	6a 00                	push   $0x0
  pushl $39
80105b0f:	6a 27                	push   $0x27
  jmp alltraps
80105b11:	e9 d1 f9 ff ff       	jmp    801054e7 <alltraps>

80105b16 <vector40>:
.globl vector40
vector40:
  pushl $0
80105b16:	6a 00                	push   $0x0
  pushl $40
80105b18:	6a 28                	push   $0x28
  jmp alltraps
80105b1a:	e9 c8 f9 ff ff       	jmp    801054e7 <alltraps>

80105b1f <vector41>:
.globl vector41
vector41:
  pushl $0
80105b1f:	6a 00                	push   $0x0
  pushl $41
80105b21:	6a 29                	push   $0x29
  jmp alltraps
80105b23:	e9 bf f9 ff ff       	jmp    801054e7 <alltraps>

80105b28 <vector42>:
.globl vector42
vector42:
  pushl $0
80105b28:	6a 00                	push   $0x0
  pushl $42
80105b2a:	6a 2a                	push   $0x2a
  jmp alltraps
80105b2c:	e9 b6 f9 ff ff       	jmp    801054e7 <alltraps>

80105b31 <vector43>:
.globl vector43
vector43:
  pushl $0
80105b31:	6a 00                	push   $0x0
  pushl $43
80105b33:	6a 2b                	push   $0x2b
  jmp alltraps
80105b35:	e9 ad f9 ff ff       	jmp    801054e7 <alltraps>

80105b3a <vector44>:
.globl vector44
vector44:
  pushl $0
80105b3a:	6a 00                	push   $0x0
  pushl $44
80105b3c:	6a 2c                	push   $0x2c
  jmp alltraps
80105b3e:	e9 a4 f9 ff ff       	jmp    801054e7 <alltraps>

80105b43 <vector45>:
.globl vector45
vector45:
  pushl $0
80105b43:	6a 00                	push   $0x0
  pushl $45
80105b45:	6a 2d                	push   $0x2d
  jmp alltraps
80105b47:	e9 9b f9 ff ff       	jmp    801054e7 <alltraps>

80105b4c <vector46>:
.globl vector46
vector46:
  pushl $0
80105b4c:	6a 00                	push   $0x0
  pushl $46
80105b4e:	6a 2e                	push   $0x2e
  jmp alltraps
80105b50:	e9 92 f9 ff ff       	jmp    801054e7 <alltraps>

80105b55 <vector47>:
.globl vector47
vector47:
  pushl $0
80105b55:	6a 00                	push   $0x0
  pushl $47
80105b57:	6a 2f                	push   $0x2f
  jmp alltraps
80105b59:	e9 89 f9 ff ff       	jmp    801054e7 <alltraps>

80105b5e <vector48>:
.globl vector48
vector48:
  pushl $0
80105b5e:	6a 00                	push   $0x0
  pushl $48
80105b60:	6a 30                	push   $0x30
  jmp alltraps
80105b62:	e9 80 f9 ff ff       	jmp    801054e7 <alltraps>

80105b67 <vector49>:
.globl vector49
vector49:
  pushl $0
80105b67:	6a 00                	push   $0x0
  pushl $49
80105b69:	6a 31                	push   $0x31
  jmp alltraps
80105b6b:	e9 77 f9 ff ff       	jmp    801054e7 <alltraps>

80105b70 <vector50>:
.globl vector50
vector50:
  pushl $0
80105b70:	6a 00                	push   $0x0
  pushl $50
80105b72:	6a 32                	push   $0x32
  jmp alltraps
80105b74:	e9 6e f9 ff ff       	jmp    801054e7 <alltraps>

80105b79 <vector51>:
.globl vector51
vector51:
  pushl $0
80105b79:	6a 00                	push   $0x0
  pushl $51
80105b7b:	6a 33                	push   $0x33
  jmp alltraps
80105b7d:	e9 65 f9 ff ff       	jmp    801054e7 <alltraps>

80105b82 <vector52>:
.globl vector52
vector52:
  pushl $0
80105b82:	6a 00                	push   $0x0
  pushl $52
80105b84:	6a 34                	push   $0x34
  jmp alltraps
80105b86:	e9 5c f9 ff ff       	jmp    801054e7 <alltraps>

80105b8b <vector53>:
.globl vector53
vector53:
  pushl $0
80105b8b:	6a 00                	push   $0x0
  pushl $53
80105b8d:	6a 35                	push   $0x35
  jmp alltraps
80105b8f:	e9 53 f9 ff ff       	jmp    801054e7 <alltraps>

80105b94 <vector54>:
.globl vector54
vector54:
  pushl $0
80105b94:	6a 00                	push   $0x0
  pushl $54
80105b96:	6a 36                	push   $0x36
  jmp alltraps
80105b98:	e9 4a f9 ff ff       	jmp    801054e7 <alltraps>

80105b9d <vector55>:
.globl vector55
vector55:
  pushl $0
80105b9d:	6a 00                	push   $0x0
  pushl $55
80105b9f:	6a 37                	push   $0x37
  jmp alltraps
80105ba1:	e9 41 f9 ff ff       	jmp    801054e7 <alltraps>

80105ba6 <vector56>:
.globl vector56
vector56:
  pushl $0
80105ba6:	6a 00                	push   $0x0
  pushl $56
80105ba8:	6a 38                	push   $0x38
  jmp alltraps
80105baa:	e9 38 f9 ff ff       	jmp    801054e7 <alltraps>

80105baf <vector57>:
.globl vector57
vector57:
  pushl $0
80105baf:	6a 00                	push   $0x0
  pushl $57
80105bb1:	6a 39                	push   $0x39
  jmp alltraps
80105bb3:	e9 2f f9 ff ff       	jmp    801054e7 <alltraps>

80105bb8 <vector58>:
.globl vector58
vector58:
  pushl $0
80105bb8:	6a 00                	push   $0x0
  pushl $58
80105bba:	6a 3a                	push   $0x3a
  jmp alltraps
80105bbc:	e9 26 f9 ff ff       	jmp    801054e7 <alltraps>

80105bc1 <vector59>:
.globl vector59
vector59:
  pushl $0
80105bc1:	6a 00                	push   $0x0
  pushl $59
80105bc3:	6a 3b                	push   $0x3b
  jmp alltraps
80105bc5:	e9 1d f9 ff ff       	jmp    801054e7 <alltraps>

80105bca <vector60>:
.globl vector60
vector60:
  pushl $0
80105bca:	6a 00                	push   $0x0
  pushl $60
80105bcc:	6a 3c                	push   $0x3c
  jmp alltraps
80105bce:	e9 14 f9 ff ff       	jmp    801054e7 <alltraps>

80105bd3 <vector61>:
.globl vector61
vector61:
  pushl $0
80105bd3:	6a 00                	push   $0x0
  pushl $61
80105bd5:	6a 3d                	push   $0x3d
  jmp alltraps
80105bd7:	e9 0b f9 ff ff       	jmp    801054e7 <alltraps>

80105bdc <vector62>:
.globl vector62
vector62:
  pushl $0
80105bdc:	6a 00                	push   $0x0
  pushl $62
80105bde:	6a 3e                	push   $0x3e
  jmp alltraps
80105be0:	e9 02 f9 ff ff       	jmp    801054e7 <alltraps>

80105be5 <vector63>:
.globl vector63
vector63:
  pushl $0
80105be5:	6a 00                	push   $0x0
  pushl $63
80105be7:	6a 3f                	push   $0x3f
  jmp alltraps
80105be9:	e9 f9 f8 ff ff       	jmp    801054e7 <alltraps>

80105bee <vector64>:
.globl vector64
vector64:
  pushl $0
80105bee:	6a 00                	push   $0x0
  pushl $64
80105bf0:	6a 40                	push   $0x40
  jmp alltraps
80105bf2:	e9 f0 f8 ff ff       	jmp    801054e7 <alltraps>

80105bf7 <vector65>:
.globl vector65
vector65:
  pushl $0
80105bf7:	6a 00                	push   $0x0
  pushl $65
80105bf9:	6a 41                	push   $0x41
  jmp alltraps
80105bfb:	e9 e7 f8 ff ff       	jmp    801054e7 <alltraps>

80105c00 <vector66>:
.globl vector66
vector66:
  pushl $0
80105c00:	6a 00                	push   $0x0
  pushl $66
80105c02:	6a 42                	push   $0x42
  jmp alltraps
80105c04:	e9 de f8 ff ff       	jmp    801054e7 <alltraps>

80105c09 <vector67>:
.globl vector67
vector67:
  pushl $0
80105c09:	6a 00                	push   $0x0
  pushl $67
80105c0b:	6a 43                	push   $0x43
  jmp alltraps
80105c0d:	e9 d5 f8 ff ff       	jmp    801054e7 <alltraps>

80105c12 <vector68>:
.globl vector68
vector68:
  pushl $0
80105c12:	6a 00                	push   $0x0
  pushl $68
80105c14:	6a 44                	push   $0x44
  jmp alltraps
80105c16:	e9 cc f8 ff ff       	jmp    801054e7 <alltraps>

80105c1b <vector69>:
.globl vector69
vector69:
  pushl $0
80105c1b:	6a 00                	push   $0x0
  pushl $69
80105c1d:	6a 45                	push   $0x45
  jmp alltraps
80105c1f:	e9 c3 f8 ff ff       	jmp    801054e7 <alltraps>

80105c24 <vector70>:
.globl vector70
vector70:
  pushl $0
80105c24:	6a 00                	push   $0x0
  pushl $70
80105c26:	6a 46                	push   $0x46
  jmp alltraps
80105c28:	e9 ba f8 ff ff       	jmp    801054e7 <alltraps>

80105c2d <vector71>:
.globl vector71
vector71:
  pushl $0
80105c2d:	6a 00                	push   $0x0
  pushl $71
80105c2f:	6a 47                	push   $0x47
  jmp alltraps
80105c31:	e9 b1 f8 ff ff       	jmp    801054e7 <alltraps>

80105c36 <vector72>:
.globl vector72
vector72:
  pushl $0
80105c36:	6a 00                	push   $0x0
  pushl $72
80105c38:	6a 48                	push   $0x48
  jmp alltraps
80105c3a:	e9 a8 f8 ff ff       	jmp    801054e7 <alltraps>

80105c3f <vector73>:
.globl vector73
vector73:
  pushl $0
80105c3f:	6a 00                	push   $0x0
  pushl $73
80105c41:	6a 49                	push   $0x49
  jmp alltraps
80105c43:	e9 9f f8 ff ff       	jmp    801054e7 <alltraps>

80105c48 <vector74>:
.globl vector74
vector74:
  pushl $0
80105c48:	6a 00                	push   $0x0
  pushl $74
80105c4a:	6a 4a                	push   $0x4a
  jmp alltraps
80105c4c:	e9 96 f8 ff ff       	jmp    801054e7 <alltraps>

80105c51 <vector75>:
.globl vector75
vector75:
  pushl $0
80105c51:	6a 00                	push   $0x0
  pushl $75
80105c53:	6a 4b                	push   $0x4b
  jmp alltraps
80105c55:	e9 8d f8 ff ff       	jmp    801054e7 <alltraps>

80105c5a <vector76>:
.globl vector76
vector76:
  pushl $0
80105c5a:	6a 00                	push   $0x0
  pushl $76
80105c5c:	6a 4c                	push   $0x4c
  jmp alltraps
80105c5e:	e9 84 f8 ff ff       	jmp    801054e7 <alltraps>

80105c63 <vector77>:
.globl vector77
vector77:
  pushl $0
80105c63:	6a 00                	push   $0x0
  pushl $77
80105c65:	6a 4d                	push   $0x4d
  jmp alltraps
80105c67:	e9 7b f8 ff ff       	jmp    801054e7 <alltraps>

80105c6c <vector78>:
.globl vector78
vector78:
  pushl $0
80105c6c:	6a 00                	push   $0x0
  pushl $78
80105c6e:	6a 4e                	push   $0x4e
  jmp alltraps
80105c70:	e9 72 f8 ff ff       	jmp    801054e7 <alltraps>

80105c75 <vector79>:
.globl vector79
vector79:
  pushl $0
80105c75:	6a 00                	push   $0x0
  pushl $79
80105c77:	6a 4f                	push   $0x4f
  jmp alltraps
80105c79:	e9 69 f8 ff ff       	jmp    801054e7 <alltraps>

80105c7e <vector80>:
.globl vector80
vector80:
  pushl $0
80105c7e:	6a 00                	push   $0x0
  pushl $80
80105c80:	6a 50                	push   $0x50
  jmp alltraps
80105c82:	e9 60 f8 ff ff       	jmp    801054e7 <alltraps>

80105c87 <vector81>:
.globl vector81
vector81:
  pushl $0
80105c87:	6a 00                	push   $0x0
  pushl $81
80105c89:	6a 51                	push   $0x51
  jmp alltraps
80105c8b:	e9 57 f8 ff ff       	jmp    801054e7 <alltraps>

80105c90 <vector82>:
.globl vector82
vector82:
  pushl $0
80105c90:	6a 00                	push   $0x0
  pushl $82
80105c92:	6a 52                	push   $0x52
  jmp alltraps
80105c94:	e9 4e f8 ff ff       	jmp    801054e7 <alltraps>

80105c99 <vector83>:
.globl vector83
vector83:
  pushl $0
80105c99:	6a 00                	push   $0x0
  pushl $83
80105c9b:	6a 53                	push   $0x53
  jmp alltraps
80105c9d:	e9 45 f8 ff ff       	jmp    801054e7 <alltraps>

80105ca2 <vector84>:
.globl vector84
vector84:
  pushl $0
80105ca2:	6a 00                	push   $0x0
  pushl $84
80105ca4:	6a 54                	push   $0x54
  jmp alltraps
80105ca6:	e9 3c f8 ff ff       	jmp    801054e7 <alltraps>

80105cab <vector85>:
.globl vector85
vector85:
  pushl $0
80105cab:	6a 00                	push   $0x0
  pushl $85
80105cad:	6a 55                	push   $0x55
  jmp alltraps
80105caf:	e9 33 f8 ff ff       	jmp    801054e7 <alltraps>

80105cb4 <vector86>:
.globl vector86
vector86:
  pushl $0
80105cb4:	6a 00                	push   $0x0
  pushl $86
80105cb6:	6a 56                	push   $0x56
  jmp alltraps
80105cb8:	e9 2a f8 ff ff       	jmp    801054e7 <alltraps>

80105cbd <vector87>:
.globl vector87
vector87:
  pushl $0
80105cbd:	6a 00                	push   $0x0
  pushl $87
80105cbf:	6a 57                	push   $0x57
  jmp alltraps
80105cc1:	e9 21 f8 ff ff       	jmp    801054e7 <alltraps>

80105cc6 <vector88>:
.globl vector88
vector88:
  pushl $0
80105cc6:	6a 00                	push   $0x0
  pushl $88
80105cc8:	6a 58                	push   $0x58
  jmp alltraps
80105cca:	e9 18 f8 ff ff       	jmp    801054e7 <alltraps>

80105ccf <vector89>:
.globl vector89
vector89:
  pushl $0
80105ccf:	6a 00                	push   $0x0
  pushl $89
80105cd1:	6a 59                	push   $0x59
  jmp alltraps
80105cd3:	e9 0f f8 ff ff       	jmp    801054e7 <alltraps>

80105cd8 <vector90>:
.globl vector90
vector90:
  pushl $0
80105cd8:	6a 00                	push   $0x0
  pushl $90
80105cda:	6a 5a                	push   $0x5a
  jmp alltraps
80105cdc:	e9 06 f8 ff ff       	jmp    801054e7 <alltraps>

80105ce1 <vector91>:
.globl vector91
vector91:
  pushl $0
80105ce1:	6a 00                	push   $0x0
  pushl $91
80105ce3:	6a 5b                	push   $0x5b
  jmp alltraps
80105ce5:	e9 fd f7 ff ff       	jmp    801054e7 <alltraps>

80105cea <vector92>:
.globl vector92
vector92:
  pushl $0
80105cea:	6a 00                	push   $0x0
  pushl $92
80105cec:	6a 5c                	push   $0x5c
  jmp alltraps
80105cee:	e9 f4 f7 ff ff       	jmp    801054e7 <alltraps>

80105cf3 <vector93>:
.globl vector93
vector93:
  pushl $0
80105cf3:	6a 00                	push   $0x0
  pushl $93
80105cf5:	6a 5d                	push   $0x5d
  jmp alltraps
80105cf7:	e9 eb f7 ff ff       	jmp    801054e7 <alltraps>

80105cfc <vector94>:
.globl vector94
vector94:
  pushl $0
80105cfc:	6a 00                	push   $0x0
  pushl $94
80105cfe:	6a 5e                	push   $0x5e
  jmp alltraps
80105d00:	e9 e2 f7 ff ff       	jmp    801054e7 <alltraps>

80105d05 <vector95>:
.globl vector95
vector95:
  pushl $0
80105d05:	6a 00                	push   $0x0
  pushl $95
80105d07:	6a 5f                	push   $0x5f
  jmp alltraps
80105d09:	e9 d9 f7 ff ff       	jmp    801054e7 <alltraps>

80105d0e <vector96>:
.globl vector96
vector96:
  pushl $0
80105d0e:	6a 00                	push   $0x0
  pushl $96
80105d10:	6a 60                	push   $0x60
  jmp alltraps
80105d12:	e9 d0 f7 ff ff       	jmp    801054e7 <alltraps>

80105d17 <vector97>:
.globl vector97
vector97:
  pushl $0
80105d17:	6a 00                	push   $0x0
  pushl $97
80105d19:	6a 61                	push   $0x61
  jmp alltraps
80105d1b:	e9 c7 f7 ff ff       	jmp    801054e7 <alltraps>

80105d20 <vector98>:
.globl vector98
vector98:
  pushl $0
80105d20:	6a 00                	push   $0x0
  pushl $98
80105d22:	6a 62                	push   $0x62
  jmp alltraps
80105d24:	e9 be f7 ff ff       	jmp    801054e7 <alltraps>

80105d29 <vector99>:
.globl vector99
vector99:
  pushl $0
80105d29:	6a 00                	push   $0x0
  pushl $99
80105d2b:	6a 63                	push   $0x63
  jmp alltraps
80105d2d:	e9 b5 f7 ff ff       	jmp    801054e7 <alltraps>

80105d32 <vector100>:
.globl vector100
vector100:
  pushl $0
80105d32:	6a 00                	push   $0x0
  pushl $100
80105d34:	6a 64                	push   $0x64
  jmp alltraps
80105d36:	e9 ac f7 ff ff       	jmp    801054e7 <alltraps>

80105d3b <vector101>:
.globl vector101
vector101:
  pushl $0
80105d3b:	6a 00                	push   $0x0
  pushl $101
80105d3d:	6a 65                	push   $0x65
  jmp alltraps
80105d3f:	e9 a3 f7 ff ff       	jmp    801054e7 <alltraps>

80105d44 <vector102>:
.globl vector102
vector102:
  pushl $0
80105d44:	6a 00                	push   $0x0
  pushl $102
80105d46:	6a 66                	push   $0x66
  jmp alltraps
80105d48:	e9 9a f7 ff ff       	jmp    801054e7 <alltraps>

80105d4d <vector103>:
.globl vector103
vector103:
  pushl $0
80105d4d:	6a 00                	push   $0x0
  pushl $103
80105d4f:	6a 67                	push   $0x67
  jmp alltraps
80105d51:	e9 91 f7 ff ff       	jmp    801054e7 <alltraps>

80105d56 <vector104>:
.globl vector104
vector104:
  pushl $0
80105d56:	6a 00                	push   $0x0
  pushl $104
80105d58:	6a 68                	push   $0x68
  jmp alltraps
80105d5a:	e9 88 f7 ff ff       	jmp    801054e7 <alltraps>

80105d5f <vector105>:
.globl vector105
vector105:
  pushl $0
80105d5f:	6a 00                	push   $0x0
  pushl $105
80105d61:	6a 69                	push   $0x69
  jmp alltraps
80105d63:	e9 7f f7 ff ff       	jmp    801054e7 <alltraps>

80105d68 <vector106>:
.globl vector106
vector106:
  pushl $0
80105d68:	6a 00                	push   $0x0
  pushl $106
80105d6a:	6a 6a                	push   $0x6a
  jmp alltraps
80105d6c:	e9 76 f7 ff ff       	jmp    801054e7 <alltraps>

80105d71 <vector107>:
.globl vector107
vector107:
  pushl $0
80105d71:	6a 00                	push   $0x0
  pushl $107
80105d73:	6a 6b                	push   $0x6b
  jmp alltraps
80105d75:	e9 6d f7 ff ff       	jmp    801054e7 <alltraps>

80105d7a <vector108>:
.globl vector108
vector108:
  pushl $0
80105d7a:	6a 00                	push   $0x0
  pushl $108
80105d7c:	6a 6c                	push   $0x6c
  jmp alltraps
80105d7e:	e9 64 f7 ff ff       	jmp    801054e7 <alltraps>

80105d83 <vector109>:
.globl vector109
vector109:
  pushl $0
80105d83:	6a 00                	push   $0x0
  pushl $109
80105d85:	6a 6d                	push   $0x6d
  jmp alltraps
80105d87:	e9 5b f7 ff ff       	jmp    801054e7 <alltraps>

80105d8c <vector110>:
.globl vector110
vector110:
  pushl $0
80105d8c:	6a 00                	push   $0x0
  pushl $110
80105d8e:	6a 6e                	push   $0x6e
  jmp alltraps
80105d90:	e9 52 f7 ff ff       	jmp    801054e7 <alltraps>

80105d95 <vector111>:
.globl vector111
vector111:
  pushl $0
80105d95:	6a 00                	push   $0x0
  pushl $111
80105d97:	6a 6f                	push   $0x6f
  jmp alltraps
80105d99:	e9 49 f7 ff ff       	jmp    801054e7 <alltraps>

80105d9e <vector112>:
.globl vector112
vector112:
  pushl $0
80105d9e:	6a 00                	push   $0x0
  pushl $112
80105da0:	6a 70                	push   $0x70
  jmp alltraps
80105da2:	e9 40 f7 ff ff       	jmp    801054e7 <alltraps>

80105da7 <vector113>:
.globl vector113
vector113:
  pushl $0
80105da7:	6a 00                	push   $0x0
  pushl $113
80105da9:	6a 71                	push   $0x71
  jmp alltraps
80105dab:	e9 37 f7 ff ff       	jmp    801054e7 <alltraps>

80105db0 <vector114>:
.globl vector114
vector114:
  pushl $0
80105db0:	6a 00                	push   $0x0
  pushl $114
80105db2:	6a 72                	push   $0x72
  jmp alltraps
80105db4:	e9 2e f7 ff ff       	jmp    801054e7 <alltraps>

80105db9 <vector115>:
.globl vector115
vector115:
  pushl $0
80105db9:	6a 00                	push   $0x0
  pushl $115
80105dbb:	6a 73                	push   $0x73
  jmp alltraps
80105dbd:	e9 25 f7 ff ff       	jmp    801054e7 <alltraps>

80105dc2 <vector116>:
.globl vector116
vector116:
  pushl $0
80105dc2:	6a 00                	push   $0x0
  pushl $116
80105dc4:	6a 74                	push   $0x74
  jmp alltraps
80105dc6:	e9 1c f7 ff ff       	jmp    801054e7 <alltraps>

80105dcb <vector117>:
.globl vector117
vector117:
  pushl $0
80105dcb:	6a 00                	push   $0x0
  pushl $117
80105dcd:	6a 75                	push   $0x75
  jmp alltraps
80105dcf:	e9 13 f7 ff ff       	jmp    801054e7 <alltraps>

80105dd4 <vector118>:
.globl vector118
vector118:
  pushl $0
80105dd4:	6a 00                	push   $0x0
  pushl $118
80105dd6:	6a 76                	push   $0x76
  jmp alltraps
80105dd8:	e9 0a f7 ff ff       	jmp    801054e7 <alltraps>

80105ddd <vector119>:
.globl vector119
vector119:
  pushl $0
80105ddd:	6a 00                	push   $0x0
  pushl $119
80105ddf:	6a 77                	push   $0x77
  jmp alltraps
80105de1:	e9 01 f7 ff ff       	jmp    801054e7 <alltraps>

80105de6 <vector120>:
.globl vector120
vector120:
  pushl $0
80105de6:	6a 00                	push   $0x0
  pushl $120
80105de8:	6a 78                	push   $0x78
  jmp alltraps
80105dea:	e9 f8 f6 ff ff       	jmp    801054e7 <alltraps>

80105def <vector121>:
.globl vector121
vector121:
  pushl $0
80105def:	6a 00                	push   $0x0
  pushl $121
80105df1:	6a 79                	push   $0x79
  jmp alltraps
80105df3:	e9 ef f6 ff ff       	jmp    801054e7 <alltraps>

80105df8 <vector122>:
.globl vector122
vector122:
  pushl $0
80105df8:	6a 00                	push   $0x0
  pushl $122
80105dfa:	6a 7a                	push   $0x7a
  jmp alltraps
80105dfc:	e9 e6 f6 ff ff       	jmp    801054e7 <alltraps>

80105e01 <vector123>:
.globl vector123
vector123:
  pushl $0
80105e01:	6a 00                	push   $0x0
  pushl $123
80105e03:	6a 7b                	push   $0x7b
  jmp alltraps
80105e05:	e9 dd f6 ff ff       	jmp    801054e7 <alltraps>

80105e0a <vector124>:
.globl vector124
vector124:
  pushl $0
80105e0a:	6a 00                	push   $0x0
  pushl $124
80105e0c:	6a 7c                	push   $0x7c
  jmp alltraps
80105e0e:	e9 d4 f6 ff ff       	jmp    801054e7 <alltraps>

80105e13 <vector125>:
.globl vector125
vector125:
  pushl $0
80105e13:	6a 00                	push   $0x0
  pushl $125
80105e15:	6a 7d                	push   $0x7d
  jmp alltraps
80105e17:	e9 cb f6 ff ff       	jmp    801054e7 <alltraps>

80105e1c <vector126>:
.globl vector126
vector126:
  pushl $0
80105e1c:	6a 00                	push   $0x0
  pushl $126
80105e1e:	6a 7e                	push   $0x7e
  jmp alltraps
80105e20:	e9 c2 f6 ff ff       	jmp    801054e7 <alltraps>

80105e25 <vector127>:
.globl vector127
vector127:
  pushl $0
80105e25:	6a 00                	push   $0x0
  pushl $127
80105e27:	6a 7f                	push   $0x7f
  jmp alltraps
80105e29:	e9 b9 f6 ff ff       	jmp    801054e7 <alltraps>

80105e2e <vector128>:
.globl vector128
vector128:
  pushl $0
80105e2e:	6a 00                	push   $0x0
  pushl $128
80105e30:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105e35:	e9 ad f6 ff ff       	jmp    801054e7 <alltraps>

80105e3a <vector129>:
.globl vector129
vector129:
  pushl $0
80105e3a:	6a 00                	push   $0x0
  pushl $129
80105e3c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105e41:	e9 a1 f6 ff ff       	jmp    801054e7 <alltraps>

80105e46 <vector130>:
.globl vector130
vector130:
  pushl $0
80105e46:	6a 00                	push   $0x0
  pushl $130
80105e48:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105e4d:	e9 95 f6 ff ff       	jmp    801054e7 <alltraps>

80105e52 <vector131>:
.globl vector131
vector131:
  pushl $0
80105e52:	6a 00                	push   $0x0
  pushl $131
80105e54:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105e59:	e9 89 f6 ff ff       	jmp    801054e7 <alltraps>

80105e5e <vector132>:
.globl vector132
vector132:
  pushl $0
80105e5e:	6a 00                	push   $0x0
  pushl $132
80105e60:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105e65:	e9 7d f6 ff ff       	jmp    801054e7 <alltraps>

80105e6a <vector133>:
.globl vector133
vector133:
  pushl $0
80105e6a:	6a 00                	push   $0x0
  pushl $133
80105e6c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105e71:	e9 71 f6 ff ff       	jmp    801054e7 <alltraps>

80105e76 <vector134>:
.globl vector134
vector134:
  pushl $0
80105e76:	6a 00                	push   $0x0
  pushl $134
80105e78:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105e7d:	e9 65 f6 ff ff       	jmp    801054e7 <alltraps>

80105e82 <vector135>:
.globl vector135
vector135:
  pushl $0
80105e82:	6a 00                	push   $0x0
  pushl $135
80105e84:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105e89:	e9 59 f6 ff ff       	jmp    801054e7 <alltraps>

80105e8e <vector136>:
.globl vector136
vector136:
  pushl $0
80105e8e:	6a 00                	push   $0x0
  pushl $136
80105e90:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105e95:	e9 4d f6 ff ff       	jmp    801054e7 <alltraps>

80105e9a <vector137>:
.globl vector137
vector137:
  pushl $0
80105e9a:	6a 00                	push   $0x0
  pushl $137
80105e9c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105ea1:	e9 41 f6 ff ff       	jmp    801054e7 <alltraps>

80105ea6 <vector138>:
.globl vector138
vector138:
  pushl $0
80105ea6:	6a 00                	push   $0x0
  pushl $138
80105ea8:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105ead:	e9 35 f6 ff ff       	jmp    801054e7 <alltraps>

80105eb2 <vector139>:
.globl vector139
vector139:
  pushl $0
80105eb2:	6a 00                	push   $0x0
  pushl $139
80105eb4:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105eb9:	e9 29 f6 ff ff       	jmp    801054e7 <alltraps>

80105ebe <vector140>:
.globl vector140
vector140:
  pushl $0
80105ebe:	6a 00                	push   $0x0
  pushl $140
80105ec0:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105ec5:	e9 1d f6 ff ff       	jmp    801054e7 <alltraps>

80105eca <vector141>:
.globl vector141
vector141:
  pushl $0
80105eca:	6a 00                	push   $0x0
  pushl $141
80105ecc:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105ed1:	e9 11 f6 ff ff       	jmp    801054e7 <alltraps>

80105ed6 <vector142>:
.globl vector142
vector142:
  pushl $0
80105ed6:	6a 00                	push   $0x0
  pushl $142
80105ed8:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105edd:	e9 05 f6 ff ff       	jmp    801054e7 <alltraps>

80105ee2 <vector143>:
.globl vector143
vector143:
  pushl $0
80105ee2:	6a 00                	push   $0x0
  pushl $143
80105ee4:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105ee9:	e9 f9 f5 ff ff       	jmp    801054e7 <alltraps>

80105eee <vector144>:
.globl vector144
vector144:
  pushl $0
80105eee:	6a 00                	push   $0x0
  pushl $144
80105ef0:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105ef5:	e9 ed f5 ff ff       	jmp    801054e7 <alltraps>

80105efa <vector145>:
.globl vector145
vector145:
  pushl $0
80105efa:	6a 00                	push   $0x0
  pushl $145
80105efc:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105f01:	e9 e1 f5 ff ff       	jmp    801054e7 <alltraps>

80105f06 <vector146>:
.globl vector146
vector146:
  pushl $0
80105f06:	6a 00                	push   $0x0
  pushl $146
80105f08:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105f0d:	e9 d5 f5 ff ff       	jmp    801054e7 <alltraps>

80105f12 <vector147>:
.globl vector147
vector147:
  pushl $0
80105f12:	6a 00                	push   $0x0
  pushl $147
80105f14:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105f19:	e9 c9 f5 ff ff       	jmp    801054e7 <alltraps>

80105f1e <vector148>:
.globl vector148
vector148:
  pushl $0
80105f1e:	6a 00                	push   $0x0
  pushl $148
80105f20:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105f25:	e9 bd f5 ff ff       	jmp    801054e7 <alltraps>

80105f2a <vector149>:
.globl vector149
vector149:
  pushl $0
80105f2a:	6a 00                	push   $0x0
  pushl $149
80105f2c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105f31:	e9 b1 f5 ff ff       	jmp    801054e7 <alltraps>

80105f36 <vector150>:
.globl vector150
vector150:
  pushl $0
80105f36:	6a 00                	push   $0x0
  pushl $150
80105f38:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105f3d:	e9 a5 f5 ff ff       	jmp    801054e7 <alltraps>

80105f42 <vector151>:
.globl vector151
vector151:
  pushl $0
80105f42:	6a 00                	push   $0x0
  pushl $151
80105f44:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105f49:	e9 99 f5 ff ff       	jmp    801054e7 <alltraps>

80105f4e <vector152>:
.globl vector152
vector152:
  pushl $0
80105f4e:	6a 00                	push   $0x0
  pushl $152
80105f50:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105f55:	e9 8d f5 ff ff       	jmp    801054e7 <alltraps>

80105f5a <vector153>:
.globl vector153
vector153:
  pushl $0
80105f5a:	6a 00                	push   $0x0
  pushl $153
80105f5c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105f61:	e9 81 f5 ff ff       	jmp    801054e7 <alltraps>

80105f66 <vector154>:
.globl vector154
vector154:
  pushl $0
80105f66:	6a 00                	push   $0x0
  pushl $154
80105f68:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105f6d:	e9 75 f5 ff ff       	jmp    801054e7 <alltraps>

80105f72 <vector155>:
.globl vector155
vector155:
  pushl $0
80105f72:	6a 00                	push   $0x0
  pushl $155
80105f74:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105f79:	e9 69 f5 ff ff       	jmp    801054e7 <alltraps>

80105f7e <vector156>:
.globl vector156
vector156:
  pushl $0
80105f7e:	6a 00                	push   $0x0
  pushl $156
80105f80:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105f85:	e9 5d f5 ff ff       	jmp    801054e7 <alltraps>

80105f8a <vector157>:
.globl vector157
vector157:
  pushl $0
80105f8a:	6a 00                	push   $0x0
  pushl $157
80105f8c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105f91:	e9 51 f5 ff ff       	jmp    801054e7 <alltraps>

80105f96 <vector158>:
.globl vector158
vector158:
  pushl $0
80105f96:	6a 00                	push   $0x0
  pushl $158
80105f98:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105f9d:	e9 45 f5 ff ff       	jmp    801054e7 <alltraps>

80105fa2 <vector159>:
.globl vector159
vector159:
  pushl $0
80105fa2:	6a 00                	push   $0x0
  pushl $159
80105fa4:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105fa9:	e9 39 f5 ff ff       	jmp    801054e7 <alltraps>

80105fae <vector160>:
.globl vector160
vector160:
  pushl $0
80105fae:	6a 00                	push   $0x0
  pushl $160
80105fb0:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105fb5:	e9 2d f5 ff ff       	jmp    801054e7 <alltraps>

80105fba <vector161>:
.globl vector161
vector161:
  pushl $0
80105fba:	6a 00                	push   $0x0
  pushl $161
80105fbc:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105fc1:	e9 21 f5 ff ff       	jmp    801054e7 <alltraps>

80105fc6 <vector162>:
.globl vector162
vector162:
  pushl $0
80105fc6:	6a 00                	push   $0x0
  pushl $162
80105fc8:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105fcd:	e9 15 f5 ff ff       	jmp    801054e7 <alltraps>

80105fd2 <vector163>:
.globl vector163
vector163:
  pushl $0
80105fd2:	6a 00                	push   $0x0
  pushl $163
80105fd4:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105fd9:	e9 09 f5 ff ff       	jmp    801054e7 <alltraps>

80105fde <vector164>:
.globl vector164
vector164:
  pushl $0
80105fde:	6a 00                	push   $0x0
  pushl $164
80105fe0:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105fe5:	e9 fd f4 ff ff       	jmp    801054e7 <alltraps>

80105fea <vector165>:
.globl vector165
vector165:
  pushl $0
80105fea:	6a 00                	push   $0x0
  pushl $165
80105fec:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105ff1:	e9 f1 f4 ff ff       	jmp    801054e7 <alltraps>

80105ff6 <vector166>:
.globl vector166
vector166:
  pushl $0
80105ff6:	6a 00                	push   $0x0
  pushl $166
80105ff8:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105ffd:	e9 e5 f4 ff ff       	jmp    801054e7 <alltraps>

80106002 <vector167>:
.globl vector167
vector167:
  pushl $0
80106002:	6a 00                	push   $0x0
  pushl $167
80106004:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106009:	e9 d9 f4 ff ff       	jmp    801054e7 <alltraps>

8010600e <vector168>:
.globl vector168
vector168:
  pushl $0
8010600e:	6a 00                	push   $0x0
  pushl $168
80106010:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106015:	e9 cd f4 ff ff       	jmp    801054e7 <alltraps>

8010601a <vector169>:
.globl vector169
vector169:
  pushl $0
8010601a:	6a 00                	push   $0x0
  pushl $169
8010601c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106021:	e9 c1 f4 ff ff       	jmp    801054e7 <alltraps>

80106026 <vector170>:
.globl vector170
vector170:
  pushl $0
80106026:	6a 00                	push   $0x0
  pushl $170
80106028:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010602d:	e9 b5 f4 ff ff       	jmp    801054e7 <alltraps>

80106032 <vector171>:
.globl vector171
vector171:
  pushl $0
80106032:	6a 00                	push   $0x0
  pushl $171
80106034:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106039:	e9 a9 f4 ff ff       	jmp    801054e7 <alltraps>

8010603e <vector172>:
.globl vector172
vector172:
  pushl $0
8010603e:	6a 00                	push   $0x0
  pushl $172
80106040:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106045:	e9 9d f4 ff ff       	jmp    801054e7 <alltraps>

8010604a <vector173>:
.globl vector173
vector173:
  pushl $0
8010604a:	6a 00                	push   $0x0
  pushl $173
8010604c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106051:	e9 91 f4 ff ff       	jmp    801054e7 <alltraps>

80106056 <vector174>:
.globl vector174
vector174:
  pushl $0
80106056:	6a 00                	push   $0x0
  pushl $174
80106058:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010605d:	e9 85 f4 ff ff       	jmp    801054e7 <alltraps>

80106062 <vector175>:
.globl vector175
vector175:
  pushl $0
80106062:	6a 00                	push   $0x0
  pushl $175
80106064:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106069:	e9 79 f4 ff ff       	jmp    801054e7 <alltraps>

8010606e <vector176>:
.globl vector176
vector176:
  pushl $0
8010606e:	6a 00                	push   $0x0
  pushl $176
80106070:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106075:	e9 6d f4 ff ff       	jmp    801054e7 <alltraps>

8010607a <vector177>:
.globl vector177
vector177:
  pushl $0
8010607a:	6a 00                	push   $0x0
  pushl $177
8010607c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106081:	e9 61 f4 ff ff       	jmp    801054e7 <alltraps>

80106086 <vector178>:
.globl vector178
vector178:
  pushl $0
80106086:	6a 00                	push   $0x0
  pushl $178
80106088:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010608d:	e9 55 f4 ff ff       	jmp    801054e7 <alltraps>

80106092 <vector179>:
.globl vector179
vector179:
  pushl $0
80106092:	6a 00                	push   $0x0
  pushl $179
80106094:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106099:	e9 49 f4 ff ff       	jmp    801054e7 <alltraps>

8010609e <vector180>:
.globl vector180
vector180:
  pushl $0
8010609e:	6a 00                	push   $0x0
  pushl $180
801060a0:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801060a5:	e9 3d f4 ff ff       	jmp    801054e7 <alltraps>

801060aa <vector181>:
.globl vector181
vector181:
  pushl $0
801060aa:	6a 00                	push   $0x0
  pushl $181
801060ac:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801060b1:	e9 31 f4 ff ff       	jmp    801054e7 <alltraps>

801060b6 <vector182>:
.globl vector182
vector182:
  pushl $0
801060b6:	6a 00                	push   $0x0
  pushl $182
801060b8:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801060bd:	e9 25 f4 ff ff       	jmp    801054e7 <alltraps>

801060c2 <vector183>:
.globl vector183
vector183:
  pushl $0
801060c2:	6a 00                	push   $0x0
  pushl $183
801060c4:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801060c9:	e9 19 f4 ff ff       	jmp    801054e7 <alltraps>

801060ce <vector184>:
.globl vector184
vector184:
  pushl $0
801060ce:	6a 00                	push   $0x0
  pushl $184
801060d0:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801060d5:	e9 0d f4 ff ff       	jmp    801054e7 <alltraps>

801060da <vector185>:
.globl vector185
vector185:
  pushl $0
801060da:	6a 00                	push   $0x0
  pushl $185
801060dc:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801060e1:	e9 01 f4 ff ff       	jmp    801054e7 <alltraps>

801060e6 <vector186>:
.globl vector186
vector186:
  pushl $0
801060e6:	6a 00                	push   $0x0
  pushl $186
801060e8:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801060ed:	e9 f5 f3 ff ff       	jmp    801054e7 <alltraps>

801060f2 <vector187>:
.globl vector187
vector187:
  pushl $0
801060f2:	6a 00                	push   $0x0
  pushl $187
801060f4:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801060f9:	e9 e9 f3 ff ff       	jmp    801054e7 <alltraps>

801060fe <vector188>:
.globl vector188
vector188:
  pushl $0
801060fe:	6a 00                	push   $0x0
  pushl $188
80106100:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106105:	e9 dd f3 ff ff       	jmp    801054e7 <alltraps>

8010610a <vector189>:
.globl vector189
vector189:
  pushl $0
8010610a:	6a 00                	push   $0x0
  pushl $189
8010610c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106111:	e9 d1 f3 ff ff       	jmp    801054e7 <alltraps>

80106116 <vector190>:
.globl vector190
vector190:
  pushl $0
80106116:	6a 00                	push   $0x0
  pushl $190
80106118:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010611d:	e9 c5 f3 ff ff       	jmp    801054e7 <alltraps>

80106122 <vector191>:
.globl vector191
vector191:
  pushl $0
80106122:	6a 00                	push   $0x0
  pushl $191
80106124:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106129:	e9 b9 f3 ff ff       	jmp    801054e7 <alltraps>

8010612e <vector192>:
.globl vector192
vector192:
  pushl $0
8010612e:	6a 00                	push   $0x0
  pushl $192
80106130:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106135:	e9 ad f3 ff ff       	jmp    801054e7 <alltraps>

8010613a <vector193>:
.globl vector193
vector193:
  pushl $0
8010613a:	6a 00                	push   $0x0
  pushl $193
8010613c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106141:	e9 a1 f3 ff ff       	jmp    801054e7 <alltraps>

80106146 <vector194>:
.globl vector194
vector194:
  pushl $0
80106146:	6a 00                	push   $0x0
  pushl $194
80106148:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010614d:	e9 95 f3 ff ff       	jmp    801054e7 <alltraps>

80106152 <vector195>:
.globl vector195
vector195:
  pushl $0
80106152:	6a 00                	push   $0x0
  pushl $195
80106154:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106159:	e9 89 f3 ff ff       	jmp    801054e7 <alltraps>

8010615e <vector196>:
.globl vector196
vector196:
  pushl $0
8010615e:	6a 00                	push   $0x0
  pushl $196
80106160:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106165:	e9 7d f3 ff ff       	jmp    801054e7 <alltraps>

8010616a <vector197>:
.globl vector197
vector197:
  pushl $0
8010616a:	6a 00                	push   $0x0
  pushl $197
8010616c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106171:	e9 71 f3 ff ff       	jmp    801054e7 <alltraps>

80106176 <vector198>:
.globl vector198
vector198:
  pushl $0
80106176:	6a 00                	push   $0x0
  pushl $198
80106178:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010617d:	e9 65 f3 ff ff       	jmp    801054e7 <alltraps>

80106182 <vector199>:
.globl vector199
vector199:
  pushl $0
80106182:	6a 00                	push   $0x0
  pushl $199
80106184:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106189:	e9 59 f3 ff ff       	jmp    801054e7 <alltraps>

8010618e <vector200>:
.globl vector200
vector200:
  pushl $0
8010618e:	6a 00                	push   $0x0
  pushl $200
80106190:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106195:	e9 4d f3 ff ff       	jmp    801054e7 <alltraps>

8010619a <vector201>:
.globl vector201
vector201:
  pushl $0
8010619a:	6a 00                	push   $0x0
  pushl $201
8010619c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801061a1:	e9 41 f3 ff ff       	jmp    801054e7 <alltraps>

801061a6 <vector202>:
.globl vector202
vector202:
  pushl $0
801061a6:	6a 00                	push   $0x0
  pushl $202
801061a8:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801061ad:	e9 35 f3 ff ff       	jmp    801054e7 <alltraps>

801061b2 <vector203>:
.globl vector203
vector203:
  pushl $0
801061b2:	6a 00                	push   $0x0
  pushl $203
801061b4:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801061b9:	e9 29 f3 ff ff       	jmp    801054e7 <alltraps>

801061be <vector204>:
.globl vector204
vector204:
  pushl $0
801061be:	6a 00                	push   $0x0
  pushl $204
801061c0:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801061c5:	e9 1d f3 ff ff       	jmp    801054e7 <alltraps>

801061ca <vector205>:
.globl vector205
vector205:
  pushl $0
801061ca:	6a 00                	push   $0x0
  pushl $205
801061cc:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801061d1:	e9 11 f3 ff ff       	jmp    801054e7 <alltraps>

801061d6 <vector206>:
.globl vector206
vector206:
  pushl $0
801061d6:	6a 00                	push   $0x0
  pushl $206
801061d8:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801061dd:	e9 05 f3 ff ff       	jmp    801054e7 <alltraps>

801061e2 <vector207>:
.globl vector207
vector207:
  pushl $0
801061e2:	6a 00                	push   $0x0
  pushl $207
801061e4:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801061e9:	e9 f9 f2 ff ff       	jmp    801054e7 <alltraps>

801061ee <vector208>:
.globl vector208
vector208:
  pushl $0
801061ee:	6a 00                	push   $0x0
  pushl $208
801061f0:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801061f5:	e9 ed f2 ff ff       	jmp    801054e7 <alltraps>

801061fa <vector209>:
.globl vector209
vector209:
  pushl $0
801061fa:	6a 00                	push   $0x0
  pushl $209
801061fc:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106201:	e9 e1 f2 ff ff       	jmp    801054e7 <alltraps>

80106206 <vector210>:
.globl vector210
vector210:
  pushl $0
80106206:	6a 00                	push   $0x0
  pushl $210
80106208:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010620d:	e9 d5 f2 ff ff       	jmp    801054e7 <alltraps>

80106212 <vector211>:
.globl vector211
vector211:
  pushl $0
80106212:	6a 00                	push   $0x0
  pushl $211
80106214:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106219:	e9 c9 f2 ff ff       	jmp    801054e7 <alltraps>

8010621e <vector212>:
.globl vector212
vector212:
  pushl $0
8010621e:	6a 00                	push   $0x0
  pushl $212
80106220:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106225:	e9 bd f2 ff ff       	jmp    801054e7 <alltraps>

8010622a <vector213>:
.globl vector213
vector213:
  pushl $0
8010622a:	6a 00                	push   $0x0
  pushl $213
8010622c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106231:	e9 b1 f2 ff ff       	jmp    801054e7 <alltraps>

80106236 <vector214>:
.globl vector214
vector214:
  pushl $0
80106236:	6a 00                	push   $0x0
  pushl $214
80106238:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010623d:	e9 a5 f2 ff ff       	jmp    801054e7 <alltraps>

80106242 <vector215>:
.globl vector215
vector215:
  pushl $0
80106242:	6a 00                	push   $0x0
  pushl $215
80106244:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106249:	e9 99 f2 ff ff       	jmp    801054e7 <alltraps>

8010624e <vector216>:
.globl vector216
vector216:
  pushl $0
8010624e:	6a 00                	push   $0x0
  pushl $216
80106250:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106255:	e9 8d f2 ff ff       	jmp    801054e7 <alltraps>

8010625a <vector217>:
.globl vector217
vector217:
  pushl $0
8010625a:	6a 00                	push   $0x0
  pushl $217
8010625c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106261:	e9 81 f2 ff ff       	jmp    801054e7 <alltraps>

80106266 <vector218>:
.globl vector218
vector218:
  pushl $0
80106266:	6a 00                	push   $0x0
  pushl $218
80106268:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010626d:	e9 75 f2 ff ff       	jmp    801054e7 <alltraps>

80106272 <vector219>:
.globl vector219
vector219:
  pushl $0
80106272:	6a 00                	push   $0x0
  pushl $219
80106274:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106279:	e9 69 f2 ff ff       	jmp    801054e7 <alltraps>

8010627e <vector220>:
.globl vector220
vector220:
  pushl $0
8010627e:	6a 00                	push   $0x0
  pushl $220
80106280:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106285:	e9 5d f2 ff ff       	jmp    801054e7 <alltraps>

8010628a <vector221>:
.globl vector221
vector221:
  pushl $0
8010628a:	6a 00                	push   $0x0
  pushl $221
8010628c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106291:	e9 51 f2 ff ff       	jmp    801054e7 <alltraps>

80106296 <vector222>:
.globl vector222
vector222:
  pushl $0
80106296:	6a 00                	push   $0x0
  pushl $222
80106298:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010629d:	e9 45 f2 ff ff       	jmp    801054e7 <alltraps>

801062a2 <vector223>:
.globl vector223
vector223:
  pushl $0
801062a2:	6a 00                	push   $0x0
  pushl $223
801062a4:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801062a9:	e9 39 f2 ff ff       	jmp    801054e7 <alltraps>

801062ae <vector224>:
.globl vector224
vector224:
  pushl $0
801062ae:	6a 00                	push   $0x0
  pushl $224
801062b0:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801062b5:	e9 2d f2 ff ff       	jmp    801054e7 <alltraps>

801062ba <vector225>:
.globl vector225
vector225:
  pushl $0
801062ba:	6a 00                	push   $0x0
  pushl $225
801062bc:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801062c1:	e9 21 f2 ff ff       	jmp    801054e7 <alltraps>

801062c6 <vector226>:
.globl vector226
vector226:
  pushl $0
801062c6:	6a 00                	push   $0x0
  pushl $226
801062c8:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801062cd:	e9 15 f2 ff ff       	jmp    801054e7 <alltraps>

801062d2 <vector227>:
.globl vector227
vector227:
  pushl $0
801062d2:	6a 00                	push   $0x0
  pushl $227
801062d4:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801062d9:	e9 09 f2 ff ff       	jmp    801054e7 <alltraps>

801062de <vector228>:
.globl vector228
vector228:
  pushl $0
801062de:	6a 00                	push   $0x0
  pushl $228
801062e0:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801062e5:	e9 fd f1 ff ff       	jmp    801054e7 <alltraps>

801062ea <vector229>:
.globl vector229
vector229:
  pushl $0
801062ea:	6a 00                	push   $0x0
  pushl $229
801062ec:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801062f1:	e9 f1 f1 ff ff       	jmp    801054e7 <alltraps>

801062f6 <vector230>:
.globl vector230
vector230:
  pushl $0
801062f6:	6a 00                	push   $0x0
  pushl $230
801062f8:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801062fd:	e9 e5 f1 ff ff       	jmp    801054e7 <alltraps>

80106302 <vector231>:
.globl vector231
vector231:
  pushl $0
80106302:	6a 00                	push   $0x0
  pushl $231
80106304:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106309:	e9 d9 f1 ff ff       	jmp    801054e7 <alltraps>

8010630e <vector232>:
.globl vector232
vector232:
  pushl $0
8010630e:	6a 00                	push   $0x0
  pushl $232
80106310:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106315:	e9 cd f1 ff ff       	jmp    801054e7 <alltraps>

8010631a <vector233>:
.globl vector233
vector233:
  pushl $0
8010631a:	6a 00                	push   $0x0
  pushl $233
8010631c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106321:	e9 c1 f1 ff ff       	jmp    801054e7 <alltraps>

80106326 <vector234>:
.globl vector234
vector234:
  pushl $0
80106326:	6a 00                	push   $0x0
  pushl $234
80106328:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010632d:	e9 b5 f1 ff ff       	jmp    801054e7 <alltraps>

80106332 <vector235>:
.globl vector235
vector235:
  pushl $0
80106332:	6a 00                	push   $0x0
  pushl $235
80106334:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106339:	e9 a9 f1 ff ff       	jmp    801054e7 <alltraps>

8010633e <vector236>:
.globl vector236
vector236:
  pushl $0
8010633e:	6a 00                	push   $0x0
  pushl $236
80106340:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106345:	e9 9d f1 ff ff       	jmp    801054e7 <alltraps>

8010634a <vector237>:
.globl vector237
vector237:
  pushl $0
8010634a:	6a 00                	push   $0x0
  pushl $237
8010634c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106351:	e9 91 f1 ff ff       	jmp    801054e7 <alltraps>

80106356 <vector238>:
.globl vector238
vector238:
  pushl $0
80106356:	6a 00                	push   $0x0
  pushl $238
80106358:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010635d:	e9 85 f1 ff ff       	jmp    801054e7 <alltraps>

80106362 <vector239>:
.globl vector239
vector239:
  pushl $0
80106362:	6a 00                	push   $0x0
  pushl $239
80106364:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106369:	e9 79 f1 ff ff       	jmp    801054e7 <alltraps>

8010636e <vector240>:
.globl vector240
vector240:
  pushl $0
8010636e:	6a 00                	push   $0x0
  pushl $240
80106370:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106375:	e9 6d f1 ff ff       	jmp    801054e7 <alltraps>

8010637a <vector241>:
.globl vector241
vector241:
  pushl $0
8010637a:	6a 00                	push   $0x0
  pushl $241
8010637c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106381:	e9 61 f1 ff ff       	jmp    801054e7 <alltraps>

80106386 <vector242>:
.globl vector242
vector242:
  pushl $0
80106386:	6a 00                	push   $0x0
  pushl $242
80106388:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010638d:	e9 55 f1 ff ff       	jmp    801054e7 <alltraps>

80106392 <vector243>:
.globl vector243
vector243:
  pushl $0
80106392:	6a 00                	push   $0x0
  pushl $243
80106394:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106399:	e9 49 f1 ff ff       	jmp    801054e7 <alltraps>

8010639e <vector244>:
.globl vector244
vector244:
  pushl $0
8010639e:	6a 00                	push   $0x0
  pushl $244
801063a0:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801063a5:	e9 3d f1 ff ff       	jmp    801054e7 <alltraps>

801063aa <vector245>:
.globl vector245
vector245:
  pushl $0
801063aa:	6a 00                	push   $0x0
  pushl $245
801063ac:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801063b1:	e9 31 f1 ff ff       	jmp    801054e7 <alltraps>

801063b6 <vector246>:
.globl vector246
vector246:
  pushl $0
801063b6:	6a 00                	push   $0x0
  pushl $246
801063b8:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801063bd:	e9 25 f1 ff ff       	jmp    801054e7 <alltraps>

801063c2 <vector247>:
.globl vector247
vector247:
  pushl $0
801063c2:	6a 00                	push   $0x0
  pushl $247
801063c4:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801063c9:	e9 19 f1 ff ff       	jmp    801054e7 <alltraps>

801063ce <vector248>:
.globl vector248
vector248:
  pushl $0
801063ce:	6a 00                	push   $0x0
  pushl $248
801063d0:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801063d5:	e9 0d f1 ff ff       	jmp    801054e7 <alltraps>

801063da <vector249>:
.globl vector249
vector249:
  pushl $0
801063da:	6a 00                	push   $0x0
  pushl $249
801063dc:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801063e1:	e9 01 f1 ff ff       	jmp    801054e7 <alltraps>

801063e6 <vector250>:
.globl vector250
vector250:
  pushl $0
801063e6:	6a 00                	push   $0x0
  pushl $250
801063e8:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801063ed:	e9 f5 f0 ff ff       	jmp    801054e7 <alltraps>

801063f2 <vector251>:
.globl vector251
vector251:
  pushl $0
801063f2:	6a 00                	push   $0x0
  pushl $251
801063f4:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801063f9:	e9 e9 f0 ff ff       	jmp    801054e7 <alltraps>

801063fe <vector252>:
.globl vector252
vector252:
  pushl $0
801063fe:	6a 00                	push   $0x0
  pushl $252
80106400:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106405:	e9 dd f0 ff ff       	jmp    801054e7 <alltraps>

8010640a <vector253>:
.globl vector253
vector253:
  pushl $0
8010640a:	6a 00                	push   $0x0
  pushl $253
8010640c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106411:	e9 d1 f0 ff ff       	jmp    801054e7 <alltraps>

80106416 <vector254>:
.globl vector254
vector254:
  pushl $0
80106416:	6a 00                	push   $0x0
  pushl $254
80106418:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010641d:	e9 c5 f0 ff ff       	jmp    801054e7 <alltraps>

80106422 <vector255>:
.globl vector255
vector255:
  pushl $0
80106422:	6a 00                	push   $0x0
  pushl $255
80106424:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106429:	e9 b9 f0 ff ff       	jmp    801054e7 <alltraps>

8010642e <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010642e:	55                   	push   %ebp
8010642f:	89 e5                	mov    %esp,%ebp
80106431:	57                   	push   %edi
80106432:	56                   	push   %esi
80106433:	53                   	push   %ebx
80106434:	83 ec 0c             	sub    $0xc,%esp
80106437:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106439:	c1 ea 16             	shr    $0x16,%edx
8010643c:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
8010643f:	8b 37                	mov    (%edi),%esi
80106441:	f7 c6 01 00 00 00    	test   $0x1,%esi
80106447:	74 35                	je     8010647e <walkpgdir+0x50>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80106449:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    if (a > KERNBASE)
8010644f:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
80106455:	77 1a                	ja     80106471 <walkpgdir+0x43>
    return (char*)a + KERNBASE;
80106457:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
8010645d:	c1 eb 0c             	shr    $0xc,%ebx
80106460:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
80106466:	8d 04 9e             	lea    (%esi,%ebx,4),%eax
}
80106469:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010646c:	5b                   	pop    %ebx
8010646d:	5e                   	pop    %esi
8010646e:	5f                   	pop    %edi
8010646f:	5d                   	pop    %ebp
80106470:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80106471:	83 ec 0c             	sub    $0xc,%esp
80106474:	68 d8 74 10 80       	push   $0x801074d8
80106479:	e8 ca 9e ff ff       	call   80100348 <panic>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010647e:	85 c9                	test   %ecx,%ecx
80106480:	74 33                	je     801064b5 <walkpgdir+0x87>
80106482:	e8 42 bc ff ff       	call   801020c9 <kalloc>
80106487:	89 c6                	mov    %eax,%esi
80106489:	85 c0                	test   %eax,%eax
8010648b:	74 28                	je     801064b5 <walkpgdir+0x87>
    memset(pgtab, 0, PGSIZE);
8010648d:	83 ec 04             	sub    $0x4,%esp
80106490:	68 00 10 00 00       	push   $0x1000
80106495:	6a 00                	push   $0x0
80106497:	50                   	push   %eax
80106498:	e8 7e df ff ff       	call   8010441b <memset>
    if (a < (void*) KERNBASE)
8010649d:	83 c4 10             	add    $0x10,%esp
801064a0:	81 fe ff ff ff 7f    	cmp    $0x7fffffff,%esi
801064a6:	76 14                	jbe    801064bc <walkpgdir+0x8e>
    return (uint)a - KERNBASE;
801064a8:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801064ae:	83 c8 07             	or     $0x7,%eax
801064b1:	89 07                	mov    %eax,(%edi)
801064b3:	eb a8                	jmp    8010645d <walkpgdir+0x2f>
      return 0;
801064b5:	b8 00 00 00 00       	mov    $0x0,%eax
801064ba:	eb ad                	jmp    80106469 <walkpgdir+0x3b>
        panic("V2P on address < KERNBASE "
801064bc:	83 ec 0c             	sub    $0xc,%esp
801064bf:	68 a8 71 10 80       	push   $0x801071a8
801064c4:	e8 7f 9e ff ff       	call   80100348 <panic>

801064c9 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801064c9:	55                   	push   %ebp
801064ca:	89 e5                	mov    %esp,%ebp
801064cc:	57                   	push   %edi
801064cd:	56                   	push   %esi
801064ce:	53                   	push   %ebx
801064cf:	83 ec 1c             	sub    $0x1c,%esp
801064d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801064d5:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801064d8:	89 d3                	mov    %edx,%ebx
801064da:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801064e0:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
801064e4:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801064ea:	b9 01 00 00 00       	mov    $0x1,%ecx
801064ef:	89 da                	mov    %ebx,%edx
801064f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064f4:	e8 35 ff ff ff       	call   8010642e <walkpgdir>
801064f9:	85 c0                	test   %eax,%eax
801064fb:	74 2e                	je     8010652b <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
801064fd:	f6 00 01             	testb  $0x1,(%eax)
80106500:	75 1c                	jne    8010651e <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80106502:	89 f2                	mov    %esi,%edx
80106504:	0b 55 0c             	or     0xc(%ebp),%edx
80106507:	83 ca 01             	or     $0x1,%edx
8010650a:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010650c:	39 fb                	cmp    %edi,%ebx
8010650e:	74 28                	je     80106538 <mappages+0x6f>
      break;
    a += PGSIZE;
80106510:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80106516:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010651c:	eb cc                	jmp    801064ea <mappages+0x21>
      panic("remap");
8010651e:	83 ec 0c             	sub    $0xc,%esp
80106521:	68 0c 7a 10 80       	push   $0x80107a0c
80106526:	e8 1d 9e ff ff       	call   80100348 <panic>
      return -1;
8010652b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80106530:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106533:	5b                   	pop    %ebx
80106534:	5e                   	pop    %esi
80106535:	5f                   	pop    %edi
80106536:	5d                   	pop    %ebp
80106537:	c3                   	ret    
  return 0;
80106538:	b8 00 00 00 00       	mov    $0x0,%eax
8010653d:	eb f1                	jmp    80106530 <mappages+0x67>

8010653f <seginit>:
{
8010653f:	55                   	push   %ebp
80106540:	89 e5                	mov    %esp,%ebp
80106542:	57                   	push   %edi
80106543:	56                   	push   %esi
80106544:	53                   	push   %ebx
80106545:	83 ec 1c             	sub    $0x1c,%esp
  c = &cpus[cpuid()];
80106548:	e8 02 cf ff ff       	call   8010344f <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010654d:	69 f8 b4 00 00 00    	imul   $0xb4,%eax,%edi
80106553:	66 c7 87 18 18 11 80 	movw   $0xffff,-0x7feee7e8(%edi)
8010655a:	ff ff 
8010655c:	66 c7 87 1a 18 11 80 	movw   $0x0,-0x7feee7e6(%edi)
80106563:	00 00 
80106565:	c6 87 1c 18 11 80 00 	movb   $0x0,-0x7feee7e4(%edi)
8010656c:	0f b6 8f 1d 18 11 80 	movzbl -0x7feee7e3(%edi),%ecx
80106573:	83 e1 f0             	and    $0xfffffff0,%ecx
80106576:	89 ce                	mov    %ecx,%esi
80106578:	83 ce 0a             	or     $0xa,%esi
8010657b:	89 f2                	mov    %esi,%edx
8010657d:	88 97 1d 18 11 80    	mov    %dl,-0x7feee7e3(%edi)
80106583:	83 c9 1a             	or     $0x1a,%ecx
80106586:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
8010658c:	83 e1 9f             	and    $0xffffff9f,%ecx
8010658f:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
80106595:	83 c9 80             	or     $0xffffff80,%ecx
80106598:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
8010659e:	0f b6 8f 1e 18 11 80 	movzbl -0x7feee7e2(%edi),%ecx
801065a5:	83 c9 0f             	or     $0xf,%ecx
801065a8:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
801065ae:	89 ce                	mov    %ecx,%esi
801065b0:	83 e6 ef             	and    $0xffffffef,%esi
801065b3:	89 f2                	mov    %esi,%edx
801065b5:	88 97 1e 18 11 80    	mov    %dl,-0x7feee7e2(%edi)
801065bb:	83 e1 cf             	and    $0xffffffcf,%ecx
801065be:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
801065c4:	89 ce                	mov    %ecx,%esi
801065c6:	83 ce 40             	or     $0x40,%esi
801065c9:	89 f2                	mov    %esi,%edx
801065cb:	88 97 1e 18 11 80    	mov    %dl,-0x7feee7e2(%edi)
801065d1:	83 c9 c0             	or     $0xffffffc0,%ecx
801065d4:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
801065da:	c6 87 1f 18 11 80 00 	movb   $0x0,-0x7feee7e1(%edi)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801065e1:	66 c7 87 20 18 11 80 	movw   $0xffff,-0x7feee7e0(%edi)
801065e8:	ff ff 
801065ea:	66 c7 87 22 18 11 80 	movw   $0x0,-0x7feee7de(%edi)
801065f1:	00 00 
801065f3:	c6 87 24 18 11 80 00 	movb   $0x0,-0x7feee7dc(%edi)
801065fa:	0f b6 8f 25 18 11 80 	movzbl -0x7feee7db(%edi),%ecx
80106601:	83 e1 f0             	and    $0xfffffff0,%ecx
80106604:	89 ce                	mov    %ecx,%esi
80106606:	83 ce 02             	or     $0x2,%esi
80106609:	89 f2                	mov    %esi,%edx
8010660b:	88 97 25 18 11 80    	mov    %dl,-0x7feee7db(%edi)
80106611:	83 c9 12             	or     $0x12,%ecx
80106614:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
8010661a:	83 e1 9f             	and    $0xffffff9f,%ecx
8010661d:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
80106623:	83 c9 80             	or     $0xffffff80,%ecx
80106626:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
8010662c:	0f b6 8f 26 18 11 80 	movzbl -0x7feee7da(%edi),%ecx
80106633:	83 c9 0f             	or     $0xf,%ecx
80106636:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
8010663c:	89 ce                	mov    %ecx,%esi
8010663e:	83 e6 ef             	and    $0xffffffef,%esi
80106641:	89 f2                	mov    %esi,%edx
80106643:	88 97 26 18 11 80    	mov    %dl,-0x7feee7da(%edi)
80106649:	83 e1 cf             	and    $0xffffffcf,%ecx
8010664c:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
80106652:	89 ce                	mov    %ecx,%esi
80106654:	83 ce 40             	or     $0x40,%esi
80106657:	89 f2                	mov    %esi,%edx
80106659:	88 97 26 18 11 80    	mov    %dl,-0x7feee7da(%edi)
8010665f:	83 c9 c0             	or     $0xffffffc0,%ecx
80106662:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
80106668:	c6 87 27 18 11 80 00 	movb   $0x0,-0x7feee7d9(%edi)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010666f:	66 c7 87 28 18 11 80 	movw   $0xffff,-0x7feee7d8(%edi)
80106676:	ff ff 
80106678:	66 c7 87 2a 18 11 80 	movw   $0x0,-0x7feee7d6(%edi)
8010667f:	00 00 
80106681:	c6 87 2c 18 11 80 00 	movb   $0x0,-0x7feee7d4(%edi)
80106688:	0f b6 9f 2d 18 11 80 	movzbl -0x7feee7d3(%edi),%ebx
8010668f:	83 e3 f0             	and    $0xfffffff0,%ebx
80106692:	89 de                	mov    %ebx,%esi
80106694:	83 ce 0a             	or     $0xa,%esi
80106697:	89 f2                	mov    %esi,%edx
80106699:	88 97 2d 18 11 80    	mov    %dl,-0x7feee7d3(%edi)
8010669f:	89 de                	mov    %ebx,%esi
801066a1:	83 ce 1a             	or     $0x1a,%esi
801066a4:	89 f2                	mov    %esi,%edx
801066a6:	88 97 2d 18 11 80    	mov    %dl,-0x7feee7d3(%edi)
801066ac:	83 cb 7a             	or     $0x7a,%ebx
801066af:	88 9f 2d 18 11 80    	mov    %bl,-0x7feee7d3(%edi)
801066b5:	c6 87 2d 18 11 80 fa 	movb   $0xfa,-0x7feee7d3(%edi)
801066bc:	0f b6 9f 2e 18 11 80 	movzbl -0x7feee7d2(%edi),%ebx
801066c3:	83 cb 0f             	or     $0xf,%ebx
801066c6:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
801066cc:	89 de                	mov    %ebx,%esi
801066ce:	83 e6 ef             	and    $0xffffffef,%esi
801066d1:	89 f2                	mov    %esi,%edx
801066d3:	88 97 2e 18 11 80    	mov    %dl,-0x7feee7d2(%edi)
801066d9:	83 e3 cf             	and    $0xffffffcf,%ebx
801066dc:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
801066e2:	89 de                	mov    %ebx,%esi
801066e4:	83 ce 40             	or     $0x40,%esi
801066e7:	89 f2                	mov    %esi,%edx
801066e9:	88 97 2e 18 11 80    	mov    %dl,-0x7feee7d2(%edi)
801066ef:	83 cb c0             	or     $0xffffffc0,%ebx
801066f2:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
801066f8:	c6 87 2f 18 11 80 00 	movb   $0x0,-0x7feee7d1(%edi)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801066ff:	66 c7 87 30 18 11 80 	movw   $0xffff,-0x7feee7d0(%edi)
80106706:	ff ff 
80106708:	66 c7 87 32 18 11 80 	movw   $0x0,-0x7feee7ce(%edi)
8010670f:	00 00 
80106711:	c6 87 34 18 11 80 00 	movb   $0x0,-0x7feee7cc(%edi)
80106718:	0f b6 9f 35 18 11 80 	movzbl -0x7feee7cb(%edi),%ebx
8010671f:	83 e3 f0             	and    $0xfffffff0,%ebx
80106722:	89 de                	mov    %ebx,%esi
80106724:	83 ce 02             	or     $0x2,%esi
80106727:	89 f2                	mov    %esi,%edx
80106729:	88 97 35 18 11 80    	mov    %dl,-0x7feee7cb(%edi)
8010672f:	89 de                	mov    %ebx,%esi
80106731:	83 ce 12             	or     $0x12,%esi
80106734:	89 f2                	mov    %esi,%edx
80106736:	88 97 35 18 11 80    	mov    %dl,-0x7feee7cb(%edi)
8010673c:	83 cb 72             	or     $0x72,%ebx
8010673f:	88 9f 35 18 11 80    	mov    %bl,-0x7feee7cb(%edi)
80106745:	c6 87 35 18 11 80 f2 	movb   $0xf2,-0x7feee7cb(%edi)
8010674c:	0f b6 9f 36 18 11 80 	movzbl -0x7feee7ca(%edi),%ebx
80106753:	83 cb 0f             	or     $0xf,%ebx
80106756:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
8010675c:	89 de                	mov    %ebx,%esi
8010675e:	83 e6 ef             	and    $0xffffffef,%esi
80106761:	89 f2                	mov    %esi,%edx
80106763:	88 97 36 18 11 80    	mov    %dl,-0x7feee7ca(%edi)
80106769:	83 e3 cf             	and    $0xffffffcf,%ebx
8010676c:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
80106772:	89 de                	mov    %ebx,%esi
80106774:	83 ce 40             	or     $0x40,%esi
80106777:	89 f2                	mov    %esi,%edx
80106779:	88 97 36 18 11 80    	mov    %dl,-0x7feee7ca(%edi)
8010677f:	83 cb c0             	or     $0xffffffc0,%ebx
80106782:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
80106788:	c6 87 37 18 11 80 00 	movb   $0x0,-0x7feee7c9(%edi)
  lgdt(c->gdt, sizeof(c->gdt));
8010678f:	8d 97 10 18 11 80    	lea    -0x7feee7f0(%edi),%edx
  pd[0] = size-1;
80106795:	66 c7 45 e2 2f 00    	movw   $0x2f,-0x1e(%ebp)
  pd[1] = (uint)p;
8010679b:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
  pd[2] = (uint)p >> 16;
8010679f:	c1 ea 10             	shr    $0x10,%edx
801067a2:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801067a6:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801067a9:	0f 01 10             	lgdtl  (%eax)
}
801067ac:	83 c4 1c             	add    $0x1c,%esp
801067af:	5b                   	pop    %ebx
801067b0:	5e                   	pop    %esi
801067b1:	5f                   	pop    %edi
801067b2:	5d                   	pop    %ebp
801067b3:	c3                   	ret    

801067b4 <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801067b4:	a1 84 4e 11 80       	mov    0x80114e84,%eax
    if (a < (void*) KERNBASE)
801067b9:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
801067be:	76 09                	jbe    801067c9 <switchkvm+0x15>
    return (uint)a - KERNBASE;
801067c0:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801067c5:	0f 22 d8             	mov    %eax,%cr3
801067c8:	c3                   	ret    
{
801067c9:	55                   	push   %ebp
801067ca:	89 e5                	mov    %esp,%ebp
801067cc:	83 ec 14             	sub    $0x14,%esp
        panic("V2P on address < KERNBASE "
801067cf:	68 a8 71 10 80       	push   $0x801071a8
801067d4:	e8 6f 9b ff ff       	call   80100348 <panic>

801067d9 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801067d9:	55                   	push   %ebp
801067da:	89 e5                	mov    %esp,%ebp
801067dc:	57                   	push   %edi
801067dd:	56                   	push   %esi
801067de:	53                   	push   %ebx
801067df:	83 ec 1c             	sub    $0x1c,%esp
801067e2:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801067e5:	85 f6                	test   %esi,%esi
801067e7:	0f 84 2c 01 00 00    	je     80106919 <switchuvm+0x140>
    panic("switchuvm: no process");
  if(p->kstack == 0)
801067ed:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
801067f1:	0f 84 2f 01 00 00    	je     80106926 <switchuvm+0x14d>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
801067f7:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
801067fb:	0f 84 32 01 00 00    	je     80106933 <switchuvm+0x15a>
    panic("switchuvm: no pgdir");

  pushcli();
80106801:	e8 8e da ff ff       	call   80104294 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106806:	e8 e8 cb ff ff       	call   801033f3 <mycpu>
8010680b:	89 c3                	mov    %eax,%ebx
8010680d:	e8 e1 cb ff ff       	call   801033f3 <mycpu>
80106812:	8d 78 08             	lea    0x8(%eax),%edi
80106815:	e8 d9 cb ff ff       	call   801033f3 <mycpu>
8010681a:	83 c0 08             	add    $0x8,%eax
8010681d:	c1 e8 10             	shr    $0x10,%eax
80106820:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106823:	e8 cb cb ff ff       	call   801033f3 <mycpu>
80106828:	83 c0 08             	add    $0x8,%eax
8010682b:	c1 e8 18             	shr    $0x18,%eax
8010682e:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106835:	67 00 
80106837:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
8010683e:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80106842:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106848:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
8010684f:	83 e2 f0             	and    $0xfffffff0,%edx
80106852:	89 d1                	mov    %edx,%ecx
80106854:	83 c9 09             	or     $0x9,%ecx
80106857:	88 8b 9d 00 00 00    	mov    %cl,0x9d(%ebx)
8010685d:	83 ca 19             	or     $0x19,%edx
80106860:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106866:	83 e2 9f             	and    $0xffffff9f,%edx
80106869:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010686f:	83 ca 80             	or     $0xffffff80,%edx
80106872:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106878:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
8010687f:	89 d1                	mov    %edx,%ecx
80106881:	83 e1 f0             	and    $0xfffffff0,%ecx
80106884:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
8010688a:	89 d1                	mov    %edx,%ecx
8010688c:	83 e1 e0             	and    $0xffffffe0,%ecx
8010688f:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
80106895:	83 e2 c0             	and    $0xffffffc0,%edx
80106898:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010689e:	83 ca 40             	or     $0x40,%edx
801068a1:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801068a7:	83 e2 7f             	and    $0x7f,%edx
801068aa:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801068b0:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801068b6:	e8 38 cb ff ff       	call   801033f3 <mycpu>
801068bb:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801068c2:	83 e2 ef             	and    $0xffffffef,%edx
801068c5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801068cb:	e8 23 cb ff ff       	call   801033f3 <mycpu>
801068d0:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801068d6:	8b 5e 08             	mov    0x8(%esi),%ebx
801068d9:	e8 15 cb ff ff       	call   801033f3 <mycpu>
801068de:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801068e4:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801068e7:	e8 07 cb ff ff       	call   801033f3 <mycpu>
801068ec:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801068f2:	b8 28 00 00 00       	mov    $0x28,%eax
801068f7:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801068fa:	8b 46 04             	mov    0x4(%esi),%eax
    if (a < (void*) KERNBASE)
801068fd:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80106902:	76 3c                	jbe    80106940 <switchuvm+0x167>
    return (uint)a - KERNBASE;
80106904:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106909:	0f 22 d8             	mov    %eax,%cr3
  popcli();
8010690c:	e8 bf d9 ff ff       	call   801042d0 <popcli>
}
80106911:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106914:	5b                   	pop    %ebx
80106915:	5e                   	pop    %esi
80106916:	5f                   	pop    %edi
80106917:	5d                   	pop    %ebp
80106918:	c3                   	ret    
    panic("switchuvm: no process");
80106919:	83 ec 0c             	sub    $0xc,%esp
8010691c:	68 12 7a 10 80       	push   $0x80107a12
80106921:	e8 22 9a ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
80106926:	83 ec 0c             	sub    $0xc,%esp
80106929:	68 28 7a 10 80       	push   $0x80107a28
8010692e:	e8 15 9a ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
80106933:	83 ec 0c             	sub    $0xc,%esp
80106936:	68 3d 7a 10 80       	push   $0x80107a3d
8010693b:	e8 08 9a ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
80106940:	83 ec 0c             	sub    $0xc,%esp
80106943:	68 a8 71 10 80       	push   $0x801071a8
80106948:	e8 fb 99 ff ff       	call   80100348 <panic>

8010694d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010694d:	55                   	push   %ebp
8010694e:	89 e5                	mov    %esp,%ebp
80106950:	56                   	push   %esi
80106951:	53                   	push   %ebx
80106952:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80106955:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010695b:	77 57                	ja     801069b4 <inituvm+0x67>
    panic("inituvm: more than a page");
  mem = kalloc();
8010695d:	e8 67 b7 ff ff       	call   801020c9 <kalloc>
80106962:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106964:	83 ec 04             	sub    $0x4,%esp
80106967:	68 00 10 00 00       	push   $0x1000
8010696c:	6a 00                	push   $0x0
8010696e:	50                   	push   %eax
8010696f:	e8 a7 da ff ff       	call   8010441b <memset>
    if (a < (void*) KERNBASE)
80106974:	83 c4 10             	add    $0x10,%esp
80106977:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
8010697d:	76 42                	jbe    801069c1 <inituvm+0x74>
    return (uint)a - KERNBASE;
8010697f:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106985:	83 ec 08             	sub    $0x8,%esp
80106988:	6a 06                	push   $0x6
8010698a:	50                   	push   %eax
8010698b:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106990:	ba 00 00 00 00       	mov    $0x0,%edx
80106995:	8b 45 08             	mov    0x8(%ebp),%eax
80106998:	e8 2c fb ff ff       	call   801064c9 <mappages>
  memmove(mem, init, sz);
8010699d:	83 c4 0c             	add    $0xc,%esp
801069a0:	56                   	push   %esi
801069a1:	ff 75 0c             	push   0xc(%ebp)
801069a4:	53                   	push   %ebx
801069a5:	e8 e9 da ff ff       	call   80104493 <memmove>
}
801069aa:	83 c4 10             	add    $0x10,%esp
801069ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
801069b0:	5b                   	pop    %ebx
801069b1:	5e                   	pop    %esi
801069b2:	5d                   	pop    %ebp
801069b3:	c3                   	ret    
    panic("inituvm: more than a page");
801069b4:	83 ec 0c             	sub    $0xc,%esp
801069b7:	68 51 7a 10 80       	push   $0x80107a51
801069bc:	e8 87 99 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
801069c1:	83 ec 0c             	sub    $0xc,%esp
801069c4:	68 a8 71 10 80       	push   $0x801071a8
801069c9:	e8 7a 99 ff ff       	call   80100348 <panic>

801069ce <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801069ce:	55                   	push   %ebp
801069cf:	89 e5                	mov    %esp,%ebp
801069d1:	57                   	push   %edi
801069d2:	56                   	push   %esi
801069d3:	53                   	push   %ebx
801069d4:	83 ec 0c             	sub    $0xc,%esp
801069d7:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801069da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801069dd:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801069e3:	74 43                	je     80106a28 <loaduvm+0x5a>
    panic("loaduvm: addr must be page aligned");
801069e5:	83 ec 0c             	sub    $0xc,%esp
801069e8:	68 0c 7b 10 80       	push   $0x80107b0c
801069ed:	e8 56 99 ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
801069f2:	83 ec 0c             	sub    $0xc,%esp
801069f5:	68 6b 7a 10 80       	push   $0x80107a6b
801069fa:	e8 49 99 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801069ff:	89 da                	mov    %ebx,%edx
80106a01:	03 55 14             	add    0x14(%ebp),%edx
    if (a > KERNBASE)
80106a04:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106a09:	77 51                	ja     80106a5c <loaduvm+0x8e>
    return (char*)a + KERNBASE;
80106a0b:	05 00 00 00 80       	add    $0x80000000,%eax
80106a10:	56                   	push   %esi
80106a11:	52                   	push   %edx
80106a12:	50                   	push   %eax
80106a13:	ff 75 10             	push   0x10(%ebp)
80106a16:	e8 46 ad ff ff       	call   80101761 <readi>
80106a1b:	83 c4 10             	add    $0x10,%esp
80106a1e:	39 f0                	cmp    %esi,%eax
80106a20:	75 54                	jne    80106a76 <loaduvm+0xa8>
  for(i = 0; i < sz; i += PGSIZE){
80106a22:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106a28:	39 fb                	cmp    %edi,%ebx
80106a2a:	73 3d                	jae    80106a69 <loaduvm+0x9b>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106a2c:	89 da                	mov    %ebx,%edx
80106a2e:	03 55 0c             	add    0xc(%ebp),%edx
80106a31:	b9 00 00 00 00       	mov    $0x0,%ecx
80106a36:	8b 45 08             	mov    0x8(%ebp),%eax
80106a39:	e8 f0 f9 ff ff       	call   8010642e <walkpgdir>
80106a3e:	85 c0                	test   %eax,%eax
80106a40:	74 b0                	je     801069f2 <loaduvm+0x24>
    pa = PTE_ADDR(*pte);
80106a42:	8b 00                	mov    (%eax),%eax
80106a44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106a49:	89 fe                	mov    %edi,%esi
80106a4b:	29 de                	sub    %ebx,%esi
80106a4d:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106a53:	76 aa                	jbe    801069ff <loaduvm+0x31>
      n = PGSIZE;
80106a55:	be 00 10 00 00       	mov    $0x1000,%esi
80106a5a:	eb a3                	jmp    801069ff <loaduvm+0x31>
        panic("P2V on address > KERNBASE");
80106a5c:	83 ec 0c             	sub    $0xc,%esp
80106a5f:	68 d8 74 10 80       	push   $0x801074d8
80106a64:	e8 df 98 ff ff       	call   80100348 <panic>
      return -1;
  }
  return 0;
80106a69:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106a71:	5b                   	pop    %ebx
80106a72:	5e                   	pop    %esi
80106a73:	5f                   	pop    %edi
80106a74:	5d                   	pop    %ebp
80106a75:	c3                   	ret    
      return -1;
80106a76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a7b:	eb f1                	jmp    80106a6e <loaduvm+0xa0>

80106a7d <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106a7d:	55                   	push   %ebp
80106a7e:	89 e5                	mov    %esp,%ebp
80106a80:	57                   	push   %edi
80106a81:	56                   	push   %esi
80106a82:	53                   	push   %ebx
80106a83:	83 ec 0c             	sub    $0xc,%esp
80106a86:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106a89:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106a8c:	73 11                	jae    80106a9f <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106a8e:	8b 45 10             	mov    0x10(%ebp),%eax
80106a91:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106a97:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106a9d:	eb 19                	jmp    80106ab8 <deallocuvm+0x3b>
    return oldsz;
80106a9f:	89 f8                	mov    %edi,%eax
80106aa1:	eb 78                	jmp    80106b1b <deallocuvm+0x9e>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106aa3:	c1 eb 16             	shr    $0x16,%ebx
80106aa6:	83 c3 01             	add    $0x1,%ebx
80106aa9:	c1 e3 16             	shl    $0x16,%ebx
80106aac:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106ab2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106ab8:	39 fb                	cmp    %edi,%ebx
80106aba:	73 5c                	jae    80106b18 <deallocuvm+0x9b>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106abc:	b9 00 00 00 00       	mov    $0x0,%ecx
80106ac1:	89 da                	mov    %ebx,%edx
80106ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ac6:	e8 63 f9 ff ff       	call   8010642e <walkpgdir>
80106acb:	89 c6                	mov    %eax,%esi
    if(!pte)
80106acd:	85 c0                	test   %eax,%eax
80106acf:	74 d2                	je     80106aa3 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106ad1:	8b 00                	mov    (%eax),%eax
80106ad3:	a8 01                	test   $0x1,%al
80106ad5:	74 db                	je     80106ab2 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106ad7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106adc:	74 20                	je     80106afe <deallocuvm+0x81>
    if (a > KERNBASE)
80106ade:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106ae3:	77 26                	ja     80106b0b <deallocuvm+0x8e>
    return (char*)a + KERNBASE;
80106ae5:	05 00 00 00 80       	add    $0x80000000,%eax
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
80106aea:	83 ec 0c             	sub    $0xc,%esp
80106aed:	50                   	push   %eax
80106aee:	e8 99 b4 ff ff       	call   80101f8c <kfree>
      *pte = 0;
80106af3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106af9:	83 c4 10             	add    $0x10,%esp
80106afc:	eb b4                	jmp    80106ab2 <deallocuvm+0x35>
        panic("kfree");
80106afe:	83 ec 0c             	sub    $0xc,%esp
80106b01:	68 36 72 10 80       	push   $0x80107236
80106b06:	e8 3d 98 ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
80106b0b:	83 ec 0c             	sub    $0xc,%esp
80106b0e:	68 d8 74 10 80       	push   $0x801074d8
80106b13:	e8 30 98 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106b18:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b1e:	5b                   	pop    %ebx
80106b1f:	5e                   	pop    %esi
80106b20:	5f                   	pop    %edi
80106b21:	5d                   	pop    %ebp
80106b22:	c3                   	ret    

80106b23 <allocuvm>:
{
80106b23:	55                   	push   %ebp
80106b24:	89 e5                	mov    %esp,%ebp
80106b26:	57                   	push   %edi
80106b27:	56                   	push   %esi
80106b28:	53                   	push   %ebx
80106b29:	83 ec 1c             	sub    $0x1c,%esp
80106b2c:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
80106b2f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106b32:	85 ff                	test   %edi,%edi
80106b34:	0f 88 d9 00 00 00    	js     80106c13 <allocuvm+0xf0>
  if(newsz < oldsz)
80106b3a:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106b3d:	72 67                	jb     80106ba6 <allocuvm+0x83>
  a = PGROUNDUP(oldsz);
80106b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b42:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
80106b48:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80106b4e:	39 fe                	cmp    %edi,%esi
80106b50:	0f 83 c4 00 00 00    	jae    80106c1a <allocuvm+0xf7>
    mem = kalloc();
80106b56:	e8 6e b5 ff ff       	call   801020c9 <kalloc>
80106b5b:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106b5d:	85 c0                	test   %eax,%eax
80106b5f:	74 4d                	je     80106bae <allocuvm+0x8b>
    memset(mem, 0, PGSIZE);
80106b61:	83 ec 04             	sub    $0x4,%esp
80106b64:	68 00 10 00 00       	push   $0x1000
80106b69:	6a 00                	push   $0x0
80106b6b:	50                   	push   %eax
80106b6c:	e8 aa d8 ff ff       	call   8010441b <memset>
    if (a < (void*) KERNBASE)
80106b71:	83 c4 10             	add    $0x10,%esp
80106b74:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106b7a:	76 5a                	jbe    80106bd6 <allocuvm+0xb3>
    return (uint)a - KERNBASE;
80106b7c:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106b82:	83 ec 08             	sub    $0x8,%esp
80106b85:	6a 06                	push   $0x6
80106b87:	50                   	push   %eax
80106b88:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106b8d:	89 f2                	mov    %esi,%edx
80106b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80106b92:	e8 32 f9 ff ff       	call   801064c9 <mappages>
80106b97:	83 c4 10             	add    $0x10,%esp
80106b9a:	85 c0                	test   %eax,%eax
80106b9c:	78 45                	js     80106be3 <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
80106b9e:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106ba4:	eb a8                	jmp    80106b4e <allocuvm+0x2b>
    return oldsz;
80106ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ba9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106bac:	eb 6c                	jmp    80106c1a <allocuvm+0xf7>
      cprintf("allocuvm out of memory\n");
80106bae:	83 ec 0c             	sub    $0xc,%esp
80106bb1:	68 89 7a 10 80       	push   $0x80107a89
80106bb6:	e8 4c 9a ff ff       	call   80100607 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106bbb:	83 c4 0c             	add    $0xc,%esp
80106bbe:	ff 75 0c             	push   0xc(%ebp)
80106bc1:	57                   	push   %edi
80106bc2:	ff 75 08             	push   0x8(%ebp)
80106bc5:	e8 b3 fe ff ff       	call   80106a7d <deallocuvm>
      return 0;
80106bca:	83 c4 10             	add    $0x10,%esp
80106bcd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106bd4:	eb 44                	jmp    80106c1a <allocuvm+0xf7>
        panic("V2P on address < KERNBASE "
80106bd6:	83 ec 0c             	sub    $0xc,%esp
80106bd9:	68 a8 71 10 80       	push   $0x801071a8
80106bde:	e8 65 97 ff ff       	call   80100348 <panic>
      cprintf("allocuvm out of memory (2)\n");
80106be3:	83 ec 0c             	sub    $0xc,%esp
80106be6:	68 a1 7a 10 80       	push   $0x80107aa1
80106beb:	e8 17 9a ff ff       	call   80100607 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106bf0:	83 c4 0c             	add    $0xc,%esp
80106bf3:	ff 75 0c             	push   0xc(%ebp)
80106bf6:	57                   	push   %edi
80106bf7:	ff 75 08             	push   0x8(%ebp)
80106bfa:	e8 7e fe ff ff       	call   80106a7d <deallocuvm>
      kfree(mem);
80106bff:	89 1c 24             	mov    %ebx,(%esp)
80106c02:	e8 85 b3 ff ff       	call   80101f8c <kfree>
      return 0;
80106c07:	83 c4 10             	add    $0x10,%esp
80106c0a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106c11:	eb 07                	jmp    80106c1a <allocuvm+0xf7>
    return 0;
80106c13:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106c1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106c20:	5b                   	pop    %ebx
80106c21:	5e                   	pop    %esi
80106c22:	5f                   	pop    %edi
80106c23:	5d                   	pop    %ebp
80106c24:	c3                   	ret    

80106c25 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106c25:	55                   	push   %ebp
80106c26:	89 e5                	mov    %esp,%ebp
80106c28:	56                   	push   %esi
80106c29:	53                   	push   %ebx
80106c2a:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106c2d:	85 f6                	test   %esi,%esi
80106c2f:	74 1a                	je     80106c4b <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
80106c31:	83 ec 04             	sub    $0x4,%esp
80106c34:	6a 00                	push   $0x0
80106c36:	68 00 00 00 80       	push   $0x80000000
80106c3b:	56                   	push   %esi
80106c3c:	e8 3c fe ff ff       	call   80106a7d <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80106c41:	83 c4 10             	add    $0x10,%esp
80106c44:	bb 00 00 00 00       	mov    $0x0,%ebx
80106c49:	eb 21                	jmp    80106c6c <freevm+0x47>
    panic("freevm: no pgdir");
80106c4b:	83 ec 0c             	sub    $0xc,%esp
80106c4e:	68 bd 7a 10 80       	push   $0x80107abd
80106c53:	e8 f0 96 ff ff       	call   80100348 <panic>
    return (char*)a + KERNBASE;
80106c58:	05 00 00 00 80       	add    $0x80000000,%eax
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
80106c5d:	83 ec 0c             	sub    $0xc,%esp
80106c60:	50                   	push   %eax
80106c61:	e8 26 b3 ff ff       	call   80101f8c <kfree>
80106c66:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80106c69:	83 c3 01             	add    $0x1,%ebx
80106c6c:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106c72:	77 20                	ja     80106c94 <freevm+0x6f>
    if(pgdir[i] & PTE_P){
80106c74:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106c77:	a8 01                	test   $0x1,%al
80106c79:	74 ee                	je     80106c69 <freevm+0x44>
80106c7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
80106c80:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106c85:	76 d1                	jbe    80106c58 <freevm+0x33>
        panic("P2V on address > KERNBASE");
80106c87:	83 ec 0c             	sub    $0xc,%esp
80106c8a:	68 d8 74 10 80       	push   $0x801074d8
80106c8f:	e8 b4 96 ff ff       	call   80100348 <panic>
    }
  }
  kfree((char*)pgdir);
80106c94:	83 ec 0c             	sub    $0xc,%esp
80106c97:	56                   	push   %esi
80106c98:	e8 ef b2 ff ff       	call   80101f8c <kfree>
}
80106c9d:	83 c4 10             	add    $0x10,%esp
80106ca0:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106ca3:	5b                   	pop    %ebx
80106ca4:	5e                   	pop    %esi
80106ca5:	5d                   	pop    %ebp
80106ca6:	c3                   	ret    

80106ca7 <setupkvm>:
{
80106ca7:	55                   	push   %ebp
80106ca8:	89 e5                	mov    %esp,%ebp
80106caa:	56                   	push   %esi
80106cab:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106cac:	e8 18 b4 ff ff       	call   801020c9 <kalloc>
80106cb1:	89 c6                	mov    %eax,%esi
80106cb3:	85 c0                	test   %eax,%eax
80106cb5:	74 55                	je     80106d0c <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
80106cb7:	83 ec 04             	sub    $0x4,%esp
80106cba:	68 00 10 00 00       	push   $0x1000
80106cbf:	6a 00                	push   $0x0
80106cc1:	50                   	push   %eax
80106cc2:	e8 54 d7 ff ff       	call   8010441b <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106cc7:	83 c4 10             	add    $0x10,%esp
80106cca:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106ccf:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106cd5:	73 35                	jae    80106d0c <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
80106cd7:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106cda:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106cdd:	29 c1                	sub    %eax,%ecx
80106cdf:	83 ec 08             	sub    $0x8,%esp
80106ce2:	ff 73 0c             	push   0xc(%ebx)
80106ce5:	50                   	push   %eax
80106ce6:	8b 13                	mov    (%ebx),%edx
80106ce8:	89 f0                	mov    %esi,%eax
80106cea:	e8 da f7 ff ff       	call   801064c9 <mappages>
80106cef:	83 c4 10             	add    $0x10,%esp
80106cf2:	85 c0                	test   %eax,%eax
80106cf4:	78 05                	js     80106cfb <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106cf6:	83 c3 10             	add    $0x10,%ebx
80106cf9:	eb d4                	jmp    80106ccf <setupkvm+0x28>
      freevm(pgdir);
80106cfb:	83 ec 0c             	sub    $0xc,%esp
80106cfe:	56                   	push   %esi
80106cff:	e8 21 ff ff ff       	call   80106c25 <freevm>
      return 0;
80106d04:	83 c4 10             	add    $0x10,%esp
80106d07:	be 00 00 00 00       	mov    $0x0,%esi
}
80106d0c:	89 f0                	mov    %esi,%eax
80106d0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106d11:	5b                   	pop    %ebx
80106d12:	5e                   	pop    %esi
80106d13:	5d                   	pop    %ebp
80106d14:	c3                   	ret    

80106d15 <kvmalloc>:
{
80106d15:	55                   	push   %ebp
80106d16:	89 e5                	mov    %esp,%ebp
80106d18:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106d1b:	e8 87 ff ff ff       	call   80106ca7 <setupkvm>
80106d20:	a3 84 4e 11 80       	mov    %eax,0x80114e84
  switchkvm();
80106d25:	e8 8a fa ff ff       	call   801067b4 <switchkvm>
}
80106d2a:	c9                   	leave  
80106d2b:	c3                   	ret    

80106d2c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106d2c:	55                   	push   %ebp
80106d2d:	89 e5                	mov    %esp,%ebp
80106d2f:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106d32:	b9 00 00 00 00       	mov    $0x0,%ecx
80106d37:	8b 55 0c             	mov    0xc(%ebp),%edx
80106d3a:	8b 45 08             	mov    0x8(%ebp),%eax
80106d3d:	e8 ec f6 ff ff       	call   8010642e <walkpgdir>
  if(pte == 0)
80106d42:	85 c0                	test   %eax,%eax
80106d44:	74 05                	je     80106d4b <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106d46:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106d49:	c9                   	leave  
80106d4a:	c3                   	ret    
    panic("clearpteu");
80106d4b:	83 ec 0c             	sub    $0xc,%esp
80106d4e:	68 ce 7a 10 80       	push   $0x80107ace
80106d53:	e8 f0 95 ff ff       	call   80100348 <panic>

80106d58 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106d58:	55                   	push   %ebp
80106d59:	89 e5                	mov    %esp,%ebp
80106d5b:	57                   	push   %edi
80106d5c:	56                   	push   %esi
80106d5d:	53                   	push   %ebx
80106d5e:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106d61:	e8 41 ff ff ff       	call   80106ca7 <setupkvm>
80106d66:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106d69:	85 c0                	test   %eax,%eax
80106d6b:	0f 84 f2 00 00 00    	je     80106e63 <copyuvm+0x10b>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106d71:	bf 00 00 00 00       	mov    $0x0,%edi
80106d76:	eb 3a                	jmp    80106db2 <copyuvm+0x5a>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
80106d78:	83 ec 0c             	sub    $0xc,%esp
80106d7b:	68 d8 7a 10 80       	push   $0x80107ad8
80106d80:	e8 c3 95 ff ff       	call   80100348 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
80106d85:	83 ec 0c             	sub    $0xc,%esp
80106d88:	68 f2 7a 10 80       	push   $0x80107af2
80106d8d:	e8 b6 95 ff ff       	call   80100348 <panic>
80106d92:	83 ec 0c             	sub    $0xc,%esp
80106d95:	68 d8 74 10 80       	push   $0x801074d8
80106d9a:	e8 a9 95 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
80106d9f:	83 ec 0c             	sub    $0xc,%esp
80106da2:	68 a8 71 10 80       	push   $0x801071a8
80106da7:	e8 9c 95 ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80106dac:	81 c7 00 10 00 00    	add    $0x1000,%edi
80106db2:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106db5:	0f 83 a8 00 00 00    	jae    80106e63 <copyuvm+0x10b>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106dbb:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106dbe:	b9 00 00 00 00       	mov    $0x0,%ecx
80106dc3:	89 fa                	mov    %edi,%edx
80106dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80106dc8:	e8 61 f6 ff ff       	call   8010642e <walkpgdir>
80106dcd:	85 c0                	test   %eax,%eax
80106dcf:	74 a7                	je     80106d78 <copyuvm+0x20>
    if(!(*pte & PTE_P))
80106dd1:	8b 00                	mov    (%eax),%eax
80106dd3:	a8 01                	test   $0x1,%al
80106dd5:	74 ae                	je     80106d85 <copyuvm+0x2d>
80106dd7:	89 c6                	mov    %eax,%esi
80106dd9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
static inline uint PTE_FLAGS(uint pte) { return pte & 0xFFF; }
80106ddf:	25 ff 0f 00 00       	and    $0xfff,%eax
80106de4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
80106de7:	e8 dd b2 ff ff       	call   801020c9 <kalloc>
80106dec:	89 c3                	mov    %eax,%ebx
80106dee:	85 c0                	test   %eax,%eax
80106df0:	74 5c                	je     80106e4e <copyuvm+0xf6>
    if (a > KERNBASE)
80106df2:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
80106df8:	77 98                	ja     80106d92 <copyuvm+0x3a>
    return (char*)a + KERNBASE;
80106dfa:	81 c6 00 00 00 80    	add    $0x80000000,%esi
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106e00:	83 ec 04             	sub    $0x4,%esp
80106e03:	68 00 10 00 00       	push   $0x1000
80106e08:	56                   	push   %esi
80106e09:	50                   	push   %eax
80106e0a:	e8 84 d6 ff ff       	call   80104493 <memmove>
    if (a < (void*) KERNBASE)
80106e0f:	83 c4 10             	add    $0x10,%esp
80106e12:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106e18:	76 85                	jbe    80106d9f <copyuvm+0x47>
    return (uint)a - KERNBASE;
80106e1a:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106e20:	83 ec 08             	sub    $0x8,%esp
80106e23:	ff 75 e0             	push   -0x20(%ebp)
80106e26:	50                   	push   %eax
80106e27:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106e2c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106e2f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106e32:	e8 92 f6 ff ff       	call   801064c9 <mappages>
80106e37:	83 c4 10             	add    $0x10,%esp
80106e3a:	85 c0                	test   %eax,%eax
80106e3c:	0f 89 6a ff ff ff    	jns    80106dac <copyuvm+0x54>
      kfree(mem);
80106e42:	83 ec 0c             	sub    $0xc,%esp
80106e45:	53                   	push   %ebx
80106e46:	e8 41 b1 ff ff       	call   80101f8c <kfree>
      goto bad;
80106e4b:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106e4e:	83 ec 0c             	sub    $0xc,%esp
80106e51:	ff 75 dc             	push   -0x24(%ebp)
80106e54:	e8 cc fd ff ff       	call   80106c25 <freevm>
  return 0;
80106e59:	83 c4 10             	add    $0x10,%esp
80106e5c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106e63:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106e66:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e69:	5b                   	pop    %ebx
80106e6a:	5e                   	pop    %esi
80106e6b:	5f                   	pop    %edi
80106e6c:	5d                   	pop    %ebp
80106e6d:	c3                   	ret    

80106e6e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106e6e:	55                   	push   %ebp
80106e6f:	89 e5                	mov    %esp,%ebp
80106e71:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106e74:	b9 00 00 00 00       	mov    $0x0,%ecx
80106e79:	8b 55 0c             	mov    0xc(%ebp),%edx
80106e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e7f:	e8 aa f5 ff ff       	call   8010642e <walkpgdir>
  if((*pte & PTE_P) == 0)
80106e84:	8b 00                	mov    (%eax),%eax
80106e86:	a8 01                	test   $0x1,%al
80106e88:	74 24                	je     80106eae <uva2ka+0x40>
    return 0;
  if((*pte & PTE_U) == 0)
80106e8a:	a8 04                	test   $0x4,%al
80106e8c:	74 27                	je     80106eb5 <uva2ka+0x47>
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80106e8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
80106e93:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106e98:	77 07                	ja     80106ea1 <uva2ka+0x33>
    return (char*)a + KERNBASE;
80106e9a:	05 00 00 00 80       	add    $0x80000000,%eax
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80106e9f:	c9                   	leave  
80106ea0:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80106ea1:	83 ec 0c             	sub    $0xc,%esp
80106ea4:	68 d8 74 10 80       	push   $0x801074d8
80106ea9:	e8 9a 94 ff ff       	call   80100348 <panic>
    return 0;
80106eae:	b8 00 00 00 00       	mov    $0x0,%eax
80106eb3:	eb ea                	jmp    80106e9f <uva2ka+0x31>
    return 0;
80106eb5:	b8 00 00 00 00       	mov    $0x0,%eax
80106eba:	eb e3                	jmp    80106e9f <uva2ka+0x31>

80106ebc <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106ebc:	55                   	push   %ebp
80106ebd:	89 e5                	mov    %esp,%ebp
80106ebf:	57                   	push   %edi
80106ec0:	56                   	push   %esi
80106ec1:	53                   	push   %ebx
80106ec2:	83 ec 0c             	sub    $0xc,%esp
80106ec5:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106ec8:	eb 25                	jmp    80106eef <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106eca:	8b 55 0c             	mov    0xc(%ebp),%edx
80106ecd:	29 f2                	sub    %esi,%edx
80106ecf:	01 d0                	add    %edx,%eax
80106ed1:	83 ec 04             	sub    $0x4,%esp
80106ed4:	53                   	push   %ebx
80106ed5:	ff 75 10             	push   0x10(%ebp)
80106ed8:	50                   	push   %eax
80106ed9:	e8 b5 d5 ff ff       	call   80104493 <memmove>
    len -= n;
80106ede:	29 df                	sub    %ebx,%edi
    buf += n;
80106ee0:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106ee3:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106ee9:	89 45 0c             	mov    %eax,0xc(%ebp)
80106eec:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106eef:	85 ff                	test   %edi,%edi
80106ef1:	74 2f                	je     80106f22 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106ef3:	8b 75 0c             	mov    0xc(%ebp),%esi
80106ef6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106efc:	83 ec 08             	sub    $0x8,%esp
80106eff:	56                   	push   %esi
80106f00:	ff 75 08             	push   0x8(%ebp)
80106f03:	e8 66 ff ff ff       	call   80106e6e <uva2ka>
    if(pa0 == 0)
80106f08:	83 c4 10             	add    $0x10,%esp
80106f0b:	85 c0                	test   %eax,%eax
80106f0d:	74 20                	je     80106f2f <copyout+0x73>
    n = PGSIZE - (va - va0);
80106f0f:	89 f3                	mov    %esi,%ebx
80106f11:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106f14:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106f1a:	39 df                	cmp    %ebx,%edi
80106f1c:	73 ac                	jae    80106eca <copyout+0xe>
      n = len;
80106f1e:	89 fb                	mov    %edi,%ebx
80106f20:	eb a8                	jmp    80106eca <copyout+0xe>
  }
  return 0;
80106f22:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f27:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f2a:	5b                   	pop    %ebx
80106f2b:	5e                   	pop    %esi
80106f2c:	5f                   	pop    %edi
80106f2d:	5d                   	pop    %ebp
80106f2e:	c3                   	ret    
      return -1;
80106f2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f34:	eb f1                	jmp    80106f27 <copyout+0x6b>
