
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
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
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
80100028:	bc 70 73 11 80       	mov    $0x80117370,%esp

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
80100041:	68 20 b5 10 80       	push   $0x8010b520
80100046:	e8 73 45 00 00       	call   801045be <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 70 fc 10 80    	mov    0x8010fc70,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
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
80100077:	68 20 b5 10 80       	push   $0x8010b520
8010007c:	e8 a2 45 00 00       	call   80104623 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 1e 43 00 00       	call   801043aa <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 6c fc 10 80    	mov    0x8010fc6c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
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
801000c5:	68 20 b5 10 80       	push   $0x8010b520
801000ca:	e8 54 45 00 00       	call   80104623 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 d0 42 00 00       	call   801043aa <acquiresleep>
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
801000ea:	68 a0 71 10 80       	push   $0x801071a0
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 b1 71 10 80       	push   $0x801071b1
80100100:	68 20 b5 10 80       	push   $0x8010b520
80100105:	e8 78 43 00 00       	call   80104482 <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 6c fc 10 80 1c 	movl   $0x8010fc1c,0x8010fc6c
80100111:	fc 10 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 70 fc 10 80 1c 	movl   $0x8010fc1c,0x8010fc70
8010011b:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb 54 b5 10 80       	mov    $0x8010b554,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 1c fc 10 80 	movl   $0x8010fc1c,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 b8 71 10 80       	push   $0x801071b8
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 2f 42 00 00       	call   80104377 <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 70 fc 10 80    	mov    %ebx,0x8010fc70
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
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
801001a8:	e8 87 42 00 00       	call   80104434 <holdingsleep>
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
801001cb:	68 bf 71 10 80       	push   $0x801071bf
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
801001e4:	e8 4b 42 00 00       	call   80104434 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 00 42 00 00       	call   801043f9 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
80100200:	e8 b9 43 00 00       	call   801045be <acquire>
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
80100227:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 1c fc 10 80 	movl   $0x8010fc1c,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 70 fc 10 80    	mov    %ebx,0x8010fc70
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 20 b5 10 80       	push   $0x8010b520
8010024c:	e8 d2 43 00 00       	call   80104623 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 c6 71 10 80       	push   $0x801071c6
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
80100283:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010028a:	e8 2f 43 00 00       	call   801045be <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
8010029f:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
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
801002b5:	68 20 ff 10 80       	push   $0x8010ff20
801002ba:	68 00 ff 10 80       	push   $0x8010ff00
801002bf:	e8 f7 3d 00 00       	call   801040bb <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 ff 10 80       	push   $0x8010ff20
801002d1:	e8 4d 43 00 00       	call   80104623 <release>
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
801002f1:	89 15 00 ff 10 80    	mov    %edx,0x8010ff00
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 92 80 fe 10 80 	movzbl -0x7fef0180(%edx),%edx
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
80100324:	a3 00 ff 10 80       	mov    %eax,0x8010ff00
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 ff 10 80       	push   $0x8010ff20
80100331:	e8 ed 42 00 00       	call   80104623 <release>
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
80100350:	c7 05 54 ff 10 80 00 	movl   $0x0,0x8010ff54
80100357:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
8010035a:	e8 33 20 00 00       	call   80102392 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 cd 71 10 80       	push   $0x801071cd
80100368:	e8 9a 02 00 00       	call   80100607 <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	push   0x8(%ebp)
80100373:	e8 8f 02 00 00       	call   80100607 <cprintf>
  cprintf("\n");
80100378:	c7 04 24 9b 7f 10 80 	movl   $0x80107f9b,(%esp)
8010037f:	e8 83 02 00 00       	call   80100607 <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 09 41 00 00       	call   8010449d <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	push   -0x30(%ebp,%ebx,4)
801003a5:	68 e1 71 10 80       	push   $0x801071e1
801003aa:	e8 58 02 00 00       	call   80100607 <cprintf>
  for(i=0; i<10; i++)
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
  panicked = 1; // freeze other CPU
801003ba:	c7 05 58 ff 10 80 01 	movl   $0x1,0x8010ff58
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
80100492:	68 e5 71 10 80       	push   $0x801071e5
80100497:	e8 ac fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010049c:	83 ec 04             	sub    $0x4,%esp
8010049f:	68 60 0e 00 00       	push   $0xe60
801004a4:	68 a0 80 0b 80       	push   $0x800b80a0
801004a9:	68 00 80 0b 80       	push   $0x800b8000
801004ae:	e8 2f 42 00 00       	call   801046e2 <memmove>
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
801004cd:	e8 98 41 00 00       	call   8010466a <memset>
801004d2:	83 c4 10             	add    $0x10,%esp
801004d5:	e9 50 ff ff ff       	jmp    8010042a <cgaputc+0x64>

801004da <consputc>:
  if(panicked){
801004da:	83 3d 58 ff 10 80 00 	cmpl   $0x0,0x8010ff58
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
801004fa:	e8 10 56 00 00       	call   80105b0f <uartputc>
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
80100513:	e8 f7 55 00 00       	call   80105b0f <uartputc>
80100518:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010051f:	e8 eb 55 00 00       	call   80105b0f <uartputc>
80100524:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010052b:	e8 df 55 00 00       	call   80105b0f <uartputc>
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
80100568:	0f b6 92 10 72 10 80 	movzbl -0x7fef8df0(%edx),%edx
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
801005bf:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801005c6:	e8 f3 3f 00 00       	call   801045be <acquire>
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
801005e8:	68 20 ff 10 80       	push   $0x8010ff20
801005ed:	e8 31 40 00 00       	call   80104623 <release>
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
80100610:	a1 54 ff 10 80       	mov    0x8010ff54,%eax
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
8010062f:	68 20 ff 10 80       	push   $0x8010ff20
80100634:	e8 85 3f 00 00       	call   801045be <acquire>
80100639:	83 c4 10             	add    $0x10,%esp
8010063c:	eb de                	jmp    8010061c <cprintf+0x15>
    panic("null fmt");
8010063e:	83 ec 0c             	sub    $0xc,%esp
80100641:	68 ff 71 10 80       	push   $0x801071ff
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
801006cd:	bb f8 71 10 80       	mov    $0x801071f8,%ebx
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
80100724:	68 20 ff 10 80       	push   $0x8010ff20
80100729:	e8 f5 3e 00 00       	call   80104623 <release>
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
8010073f:	68 20 ff 10 80       	push   $0x8010ff20
80100744:	e8 75 3e 00 00       	call   801045be <acquire>
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
8010078a:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
8010078f:	89 c2                	mov    %eax,%edx
80100791:	2b 15 00 ff 10 80    	sub    0x8010ff00,%edx
80100797:	83 fa 7f             	cmp    $0x7f,%edx
8010079a:	77 ca                	ja     80100766 <consoleintr+0x33>
        c = (c == '\r') ? '\n' : c;
8010079c:	83 ff 0d             	cmp    $0xd,%edi
8010079f:	0f 84 b8 00 00 00    	je     8010085d <consoleintr+0x12a>
        input.buf[input.e++ % INPUT_BUF] = c;
801007a5:	8d 50 01             	lea    0x1(%eax),%edx
801007a8:	89 15 08 ff 10 80    	mov    %edx,0x8010ff08
801007ae:	83 e0 7f             	and    $0x7f,%eax
801007b1:	89 f9                	mov    %edi,%ecx
801007b3:	88 88 80 fe 10 80    	mov    %cl,-0x7fef0180(%eax)
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
801007d0:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801007d5:	83 e8 80             	sub    $0xffffff80,%eax
801007d8:	39 05 08 ff 10 80    	cmp    %eax,0x8010ff08
801007de:	75 86                	jne    80100766 <consoleintr+0x33>
          input.w = input.e;
801007e0:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
801007e5:	a3 04 ff 10 80       	mov    %eax,0x8010ff04
          wakeup(&input.r);
801007ea:	83 ec 0c             	sub    $0xc,%esp
801007ed:	68 00 ff 10 80       	push   $0x8010ff00
801007f2:	e8 2c 3a 00 00       	call   80104223 <wakeup>
801007f7:	83 c4 10             	add    $0x10,%esp
801007fa:	e9 67 ff ff ff       	jmp    80100766 <consoleintr+0x33>
        input.e--;
801007ff:	a3 08 ff 10 80       	mov    %eax,0x8010ff08
        consputc(BACKSPACE);
80100804:	b8 00 01 00 00       	mov    $0x100,%eax
80100809:	e8 cc fc ff ff       	call   801004da <consputc>
      while(input.e != input.w &&
8010080e:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100813:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
80100819:	0f 84 47 ff ff ff    	je     80100766 <consoleintr+0x33>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010081f:	83 e8 01             	sub    $0x1,%eax
80100822:	89 c2                	mov    %eax,%edx
80100824:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100827:	80 ba 80 fe 10 80 0a 	cmpb   $0xa,-0x7fef0180(%edx)
8010082e:	75 cf                	jne    801007ff <consoleintr+0xcc>
80100830:	e9 31 ff ff ff       	jmp    80100766 <consoleintr+0x33>
      if(input.e != input.w){
80100835:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
8010083a:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
80100840:	0f 84 20 ff ff ff    	je     80100766 <consoleintr+0x33>
        input.e--;
80100846:	83 e8 01             	sub    $0x1,%eax
80100849:	a3 08 ff 10 80       	mov    %eax,0x8010ff08
        consputc(BACKSPACE);
8010084e:	b8 00 01 00 00       	mov    $0x100,%eax
80100853:	e8 82 fc ff ff       	call   801004da <consputc>
80100858:	e9 09 ff ff ff       	jmp    80100766 <consoleintr+0x33>
        c = (c == '\r') ? '\n' : c;
8010085d:	bf 0a 00 00 00       	mov    $0xa,%edi
80100862:	e9 3e ff ff ff       	jmp    801007a5 <consoleintr+0x72>
  release(&cons.lock);
80100867:	83 ec 0c             	sub    $0xc,%esp
8010086a:	68 20 ff 10 80       	push   $0x8010ff20
8010086f:	e8 af 3d 00 00       	call   80104623 <release>
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
80100883:	e8 3a 3a 00 00       	call   801042c2 <procdump>
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
80100890:	68 08 72 10 80       	push   $0x80107208
80100895:	68 20 ff 10 80       	push   $0x8010ff20
8010089a:	e8 e3 3b 00 00       	call   80104482 <initlock>

  devsw[CONSOLE].write = consolewrite;
8010089f:	c7 05 0c 09 11 80 a8 	movl   $0x801005a8,0x8011090c
801008a6:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008a9:	c7 05 08 09 11 80 68 	movl   $0x80100268,0x80110908
801008b0:	02 10 80 
  cons.locking = 1;
801008b3:	c7 05 54 ff 10 80 01 	movl   $0x1,0x8010ff54
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
8010095a:	68 21 72 10 80       	push   $0x80107221
8010095f:	e8 a3 fc ff ff       	call   80100607 <cprintf>
    return -1;
80100964:	83 c4 10             	add    $0x10,%esp
80100967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096c:	eb dc                	jmp    8010094a <exec+0x7c>
  if((pgdir = setupkvm()) == 0)
8010096e:	e8 83 65 00 00       	call   80106ef6 <setupkvm>
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
80100a02:	e8 6b 63 00 00       	call   80106d72 <allocuvm>
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
80100a34:	e8 e4 61 00 00       	call   80106c1d <loaduvm>
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
80100a71:	e8 fc 62 00 00       	call   80106d72 <allocuvm>
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
80100a9c:	e8 d3 63 00 00       	call   80106e74 <freevm>
80100aa1:	83 c4 10             	add    $0x10,%esp
80100aa4:	e9 83 fe ff ff       	jmp    8010092c <exec+0x5e>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aa9:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100aaf:	83 ec 08             	sub    $0x8,%esp
80100ab2:	50                   	push   %eax
80100ab3:	57                   	push   %edi
80100ab4:	e8 c2 64 00 00       	call   80106f7b <clearpteu>
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
80100ae6:	e8 28 3d 00 00       	call   80104813 <strlen>
80100aeb:	29 c6                	sub    %eax,%esi
80100aed:	83 ee 01             	sub    $0x1,%esi
80100af0:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100af3:	83 c4 04             	add    $0x4,%esp
80100af6:	ff 33                	push   (%ebx)
80100af8:	e8 16 3d 00 00       	call   80104813 <strlen>
80100afd:	83 c0 01             	add    $0x1,%eax
80100b00:	50                   	push   %eax
80100b01:	ff 33                	push   (%ebx)
80100b03:	56                   	push   %esi
80100b04:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100b0a:	e8 fc 65 00 00       	call   8010710b <copyout>
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
80100b6a:	e8 9c 65 00 00       	call   8010710b <copyout>
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
80100ba7:	e8 2a 3c 00 00       	call   801047d6 <safestrcpy>
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
80100bd5:	e8 4e 5e 00 00       	call   80106a28 <switchuvm>
  freevm(oldpgdir);
80100bda:	89 1c 24             	mov    %ebx,(%esp)
80100bdd:	e8 92 62 00 00       	call   80106e74 <freevm>
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
80100c09:	68 2d 72 10 80       	push   $0x8010722d
80100c0e:	68 60 ff 10 80       	push   $0x8010ff60
80100c13:	e8 6a 38 00 00       	call   80104482 <initlock>
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
80100c24:	68 60 ff 10 80       	push   $0x8010ff60
80100c29:	e8 90 39 00 00       	call   801045be <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c2e:	83 c4 10             	add    $0x10,%esp
80100c31:	bb 94 ff 10 80       	mov    $0x8010ff94,%ebx
80100c36:	81 fb f4 08 11 80    	cmp    $0x801108f4,%ebx
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
80100c53:	68 60 ff 10 80       	push   $0x8010ff60
80100c58:	e8 c6 39 00 00       	call   80104623 <release>
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
80100c6a:	68 60 ff 10 80       	push   $0x8010ff60
80100c6f:	e8 af 39 00 00       	call   80104623 <release>
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
80100c88:	68 60 ff 10 80       	push   $0x8010ff60
80100c8d:	e8 2c 39 00 00       	call   801045be <acquire>
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
80100ca5:	68 60 ff 10 80       	push   $0x8010ff60
80100caa:	e8 74 39 00 00       	call   80104623 <release>
  return f;
}
80100caf:	89 d8                	mov    %ebx,%eax
80100cb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cb4:	c9                   	leave  
80100cb5:	c3                   	ret    
    panic("filedup");
80100cb6:	83 ec 0c             	sub    $0xc,%esp
80100cb9:	68 34 72 10 80       	push   $0x80107234
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
80100ccd:	68 60 ff 10 80       	push   $0x8010ff60
80100cd2:	e8 e7 38 00 00       	call   801045be <acquire>
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
80100d1e:	68 60 ff 10 80       	push   $0x8010ff60
80100d23:	e8 fb 38 00 00       	call   80104623 <release>

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
80100d55:	68 3c 72 10 80       	push   $0x8010723c
80100d5a:	e8 e9 f5 ff ff       	call   80100348 <panic>
    release(&ftable.lock);
80100d5f:	83 ec 0c             	sub    $0xc,%esp
80100d62:	68 60 ff 10 80       	push   $0x8010ff60
80100d67:	e8 b7 38 00 00       	call   80104623 <release>
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
80100e44:	68 46 72 10 80       	push   $0x80107246
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
80100f0a:	68 4f 72 10 80       	push   $0x8010724f
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
80100f31:	68 55 72 10 80       	push   $0x80107255
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
80100f81:	e8 5c 37 00 00       	call   801046e2 <memmove>
80100f86:	83 c4 10             	add    $0x10,%esp
80100f89:	eb 17                	jmp    80100fa2 <skipelem+0x60>
  else {
    memmove(name, s, len);
80100f8b:	83 ec 04             	sub    $0x4,%esp
80100f8e:	57                   	push   %edi
80100f8f:	50                   	push   %eax
80100f90:	56                   	push   %esi
80100f91:	e8 4c 37 00 00       	call   801046e2 <memmove>
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
80100fd6:	e8 8f 36 00 00       	call   8010466a <memset>
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
80101004:	03 05 cc 25 11 80    	add    0x801125cc,%eax
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
8010105f:	68 5f 72 10 80       	push   $0x8010725f
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
80101096:	39 05 b4 25 11 80    	cmp    %eax,0x801125b4
8010109c:	76 75                	jbe    80101113 <balloc+0xaa>
    bp = bread(dev, BBLOCK(b, sb));
8010109e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801010a1:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
801010a7:	85 db                	test   %ebx,%ebx
801010a9:	0f 49 c3             	cmovns %ebx,%eax
801010ac:	c1 f8 0c             	sar    $0xc,%eax
801010af:	83 ec 08             	sub    $0x8,%esp
801010b2:	03 05 cc 25 11 80    	add    0x801125cc,%eax
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
801010d9:	3b 1d b4 25 11 80    	cmp    0x801125b4,%ebx
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
80101116:	68 72 72 10 80       	push   $0x80107272
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
801011ed:	68 88 72 10 80       	push   $0x80107288
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
80101205:	68 60 09 11 80       	push   $0x80110960
8010120a:	e8 af 33 00 00       	call   801045be <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010120f:	83 c4 10             	add    $0x10,%esp
  empty = 0;
80101212:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101217:	bb 94 09 11 80       	mov    $0x80110994,%ebx
8010121c:	eb 0a                	jmp    80101228 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010121e:	85 f6                	test   %esi,%esi
80101220:	74 3b                	je     8010125d <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101222:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101228:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
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
8010124c:	68 60 09 11 80       	push   $0x80110960
80101251:	e8 cd 33 00 00       	call   80104623 <release>
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
80101282:	68 60 09 11 80       	push   $0x80110960
80101287:	e8 97 33 00 00       	call   80104623 <release>
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
8010129c:	68 9b 72 10 80       	push   $0x8010729b
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
801012c5:	e8 18 34 00 00       	call   801046e2 <memmove>
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
801012e1:	68 ab 72 10 80       	push   $0x801072ab
801012e6:	68 60 09 11 80       	push   $0x80110960
801012eb:	e8 92 31 00 00       	call   80104482 <initlock>
  for(i = 0; i < NINODE; i++) {
801012f0:	83 c4 10             	add    $0x10,%esp
801012f3:	bb 00 00 00 00       	mov    $0x0,%ebx
801012f8:	eb 21                	jmp    8010131b <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
801012fa:	83 ec 08             	sub    $0x8,%esp
801012fd:	68 b2 72 10 80       	push   $0x801072b2
80101302:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101305:	89 d0                	mov    %edx,%eax
80101307:	c1 e0 04             	shl    $0x4,%eax
8010130a:	05 a0 09 11 80       	add    $0x801109a0,%eax
8010130f:	50                   	push   %eax
80101310:	e8 62 30 00 00       	call   80104377 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101315:	83 c3 01             	add    $0x1,%ebx
80101318:	83 c4 10             	add    $0x10,%esp
8010131b:	83 fb 31             	cmp    $0x31,%ebx
8010131e:	7e da                	jle    801012fa <iinit+0x20>
  readsb(dev, &sb);
80101320:	83 ec 08             	sub    $0x8,%esp
80101323:	68 b4 25 11 80       	push   $0x801125b4
80101328:	ff 75 08             	push   0x8(%ebp)
8010132b:	e8 76 ff ff ff       	call   801012a6 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101330:	ff 35 cc 25 11 80    	push   0x801125cc
80101336:	ff 35 c8 25 11 80    	push   0x801125c8
8010133c:	ff 35 c4 25 11 80    	push   0x801125c4
80101342:	ff 35 c0 25 11 80    	push   0x801125c0
80101348:	ff 35 bc 25 11 80    	push   0x801125bc
8010134e:	ff 35 b8 25 11 80    	push   0x801125b8
80101354:	ff 35 b4 25 11 80    	push   0x801125b4
8010135a:	68 18 73 10 80       	push   $0x80107318
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
80101383:	39 1d bc 25 11 80    	cmp    %ebx,0x801125bc
80101389:	76 3f                	jbe    801013ca <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
8010138b:	89 d8                	mov    %ebx,%eax
8010138d:	c1 e8 03             	shr    $0x3,%eax
80101390:	83 ec 08             	sub    $0x8,%esp
80101393:	03 05 c8 25 11 80    	add    0x801125c8,%eax
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
801013cd:	68 b8 72 10 80       	push   $0x801072b8
801013d2:	e8 71 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013d7:	83 ec 04             	sub    $0x4,%esp
801013da:	6a 40                	push   $0x40
801013dc:	6a 00                	push   $0x0
801013de:	57                   	push   %edi
801013df:	e8 86 32 00 00       	call   8010466a <memset>
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
8010141f:	03 05 c8 25 11 80    	add    0x801125c8,%eax
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
8010146e:	e8 6f 32 00 00       	call   801046e2 <memmove>
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
80101549:	68 60 09 11 80       	push   $0x80110960
8010154e:	e8 6b 30 00 00       	call   801045be <acquire>
  ip->ref++;
80101553:	8b 43 08             	mov    0x8(%ebx),%eax
80101556:	83 c0 01             	add    $0x1,%eax
80101559:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010155c:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
80101563:	e8 bb 30 00 00       	call   80104623 <release>
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
80101588:	e8 1d 2e 00 00       	call   801043aa <acquiresleep>
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
801015a0:	68 ca 72 10 80       	push   $0x801072ca
801015a5:	e8 9e ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015aa:	8b 43 04             	mov    0x4(%ebx),%eax
801015ad:	c1 e8 03             	shr    $0x3,%eax
801015b0:	83 ec 08             	sub    $0x8,%esp
801015b3:	03 05 c8 25 11 80    	add    0x801125c8,%eax
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
80101602:	e8 db 30 00 00       	call   801046e2 <memmove>
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
80101627:	68 d0 72 10 80       	push   $0x801072d0
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
80101644:	e8 eb 2d 00 00       	call   80104434 <holdingsleep>
80101649:	83 c4 10             	add    $0x10,%esp
8010164c:	85 c0                	test   %eax,%eax
8010164e:	74 19                	je     80101669 <iunlock+0x38>
80101650:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101654:	7e 13                	jle    80101669 <iunlock+0x38>
  releasesleep(&ip->lock);
80101656:	83 ec 0c             	sub    $0xc,%esp
80101659:	56                   	push   %esi
8010165a:	e8 9a 2d 00 00       	call   801043f9 <releasesleep>
}
8010165f:	83 c4 10             	add    $0x10,%esp
80101662:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101665:	5b                   	pop    %ebx
80101666:	5e                   	pop    %esi
80101667:	5d                   	pop    %ebp
80101668:	c3                   	ret    
    panic("iunlock");
80101669:	83 ec 0c             	sub    $0xc,%esp
8010166c:	68 df 72 10 80       	push   $0x801072df
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
80101686:	e8 1f 2d 00 00       	call   801043aa <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010168b:	83 c4 10             	add    $0x10,%esp
8010168e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101692:	74 07                	je     8010169b <iput+0x25>
80101694:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101699:	74 35                	je     801016d0 <iput+0x5a>
  releasesleep(&ip->lock);
8010169b:	83 ec 0c             	sub    $0xc,%esp
8010169e:	56                   	push   %esi
8010169f:	e8 55 2d 00 00       	call   801043f9 <releasesleep>
  acquire(&icache.lock);
801016a4:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
801016ab:	e8 0e 2f 00 00       	call   801045be <acquire>
  ip->ref--;
801016b0:	8b 43 08             	mov    0x8(%ebx),%eax
801016b3:	83 e8 01             	sub    $0x1,%eax
801016b6:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016b9:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
801016c0:	e8 5e 2f 00 00       	call   80104623 <release>
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
801016d3:	68 60 09 11 80       	push   $0x80110960
801016d8:	e8 e1 2e 00 00       	call   801045be <acquire>
    int r = ip->ref;
801016dd:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016e0:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
801016e7:	e8 37 2f 00 00       	call   80104623 <release>
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
801017b2:	8b 04 c5 00 09 11 80 	mov    -0x7feef700(,%eax,8),%eax
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
80101818:	e8 c5 2e 00 00       	call   801046e2 <memmove>
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
801018b1:	8b 04 c5 04 09 11 80 	mov    -0x7feef6fc(,%eax,8),%eax
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
80101915:	e8 c8 2d 00 00       	call   801046e2 <memmove>
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
80101998:	e8 b1 2d 00 00       	call   8010474e <strncmp>
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
801019bf:	68 e7 72 10 80       	push   $0x801072e7
801019c4:	e8 7f e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019c9:	83 ec 0c             	sub    $0xc,%esp
801019cc:	68 f9 72 10 80       	push   $0x801072f9
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
80101b7e:	68 08 73 10 80       	push   $0x80107308
80101b83:	e8 c0 e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b88:	83 ec 04             	sub    $0x4,%esp
80101b8b:	6a 0e                	push   $0xe
80101b8d:	57                   	push   %edi
80101b8e:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b91:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b94:	50                   	push   %eax
80101b95:	e8 f3 2b 00 00       	call   8010478d <strncpy>
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
80101bc3:	68 60 7d 10 80       	push   $0x80107d60
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
80101cc5:	68 6b 73 10 80       	push   $0x8010736b
80101cca:	e8 79 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101ccf:	83 ec 0c             	sub    $0xc,%esp
80101cd2:	68 74 73 10 80       	push   $0x80107374
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
80101cef:	68 86 73 10 80       	push   $0x80107386
80101cf4:	68 00 26 11 80       	push   $0x80112600
80101cf9:	e8 84 27 00 00       	call   80104482 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101cfe:	83 c4 08             	add    $0x8,%esp
80101d01:	a1 84 27 11 80       	mov    0x80112784,%eax
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
80101d45:	c7 05 e0 25 11 80 01 	movl   $0x1,0x801125e0
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
80101d64:	68 00 26 11 80       	push   $0x80112600
80101d69:	e8 50 28 00 00       	call   801045be <acquire>

  if((b = idequeue) == 0){
80101d6e:	8b 1d e4 25 11 80    	mov    0x801125e4,%ebx
80101d74:	83 c4 10             	add    $0x10,%esp
80101d77:	85 db                	test   %ebx,%ebx
80101d79:	74 4a                	je     80101dc5 <ideintr+0x69>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d7b:	8b 43 58             	mov    0x58(%ebx),%eax
80101d7e:	a3 e4 25 11 80       	mov    %eax,0x801125e4

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
80101d98:	e8 86 24 00 00       	call   80104223 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101d9d:	a1 e4 25 11 80       	mov    0x801125e4,%eax
80101da2:	83 c4 10             	add    $0x10,%esp
80101da5:	85 c0                	test   %eax,%eax
80101da7:	74 05                	je     80101dae <ideintr+0x52>
    idestart(idequeue);
80101da9:	e8 78 fe ff ff       	call   80101c26 <idestart>

  release(&idelock);
80101dae:	83 ec 0c             	sub    $0xc,%esp
80101db1:	68 00 26 11 80       	push   $0x80112600
80101db6:	e8 68 28 00 00       	call   80104623 <release>
80101dbb:	83 c4 10             	add    $0x10,%esp
}
80101dbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101dc1:	5b                   	pop    %ebx
80101dc2:	5f                   	pop    %edi
80101dc3:	5d                   	pop    %ebp
80101dc4:	c3                   	ret    
    release(&idelock);
80101dc5:	83 ec 0c             	sub    $0xc,%esp
80101dc8:	68 00 26 11 80       	push   $0x80112600
80101dcd:	e8 51 28 00 00       	call   80104623 <release>
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
80101e05:	e8 2a 26 00 00       	call   80104434 <holdingsleep>
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
80101e21:	83 3d e0 25 11 80 00 	cmpl   $0x0,0x801125e0
80101e28:	74 38                	je     80101e62 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e2a:	83 ec 0c             	sub    $0xc,%esp
80101e2d:	68 00 26 11 80       	push   $0x80112600
80101e32:	e8 87 27 00 00       	call   801045be <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e37:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e3e:	83 c4 10             	add    $0x10,%esp
80101e41:	ba e4 25 11 80       	mov    $0x801125e4,%edx
80101e46:	eb 2a                	jmp    80101e72 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e48:	83 ec 0c             	sub    $0xc,%esp
80101e4b:	68 8a 73 10 80       	push   $0x8010738a
80101e50:	e8 f3 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e55:	83 ec 0c             	sub    $0xc,%esp
80101e58:	68 a0 73 10 80       	push   $0x801073a0
80101e5d:	e8 e6 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e62:	83 ec 0c             	sub    $0xc,%esp
80101e65:	68 b5 73 10 80       	push   $0x801073b5
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
80101e7a:	39 1d e4 25 11 80    	cmp    %ebx,0x801125e4
80101e80:	75 1a                	jne    80101e9c <iderw+0xa5>
    idestart(b);
80101e82:	89 d8                	mov    %ebx,%eax
80101e84:	e8 9d fd ff ff       	call   80101c26 <idestart>
80101e89:	eb 11                	jmp    80101e9c <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101e8b:	83 ec 08             	sub    $0x8,%esp
80101e8e:	68 00 26 11 80       	push   $0x80112600
80101e93:	53                   	push   %ebx
80101e94:	e8 22 22 00 00       	call   801040bb <sleep>
80101e99:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101e9c:	8b 03                	mov    (%ebx),%eax
80101e9e:	83 e0 06             	and    $0x6,%eax
80101ea1:	83 f8 02             	cmp    $0x2,%eax
80101ea4:	75 e5                	jne    80101e8b <iderw+0x94>
  }


  release(&idelock);
80101ea6:	83 ec 0c             	sub    $0xc,%esp
80101ea9:	68 00 26 11 80       	push   $0x80112600
80101eae:	e8 70 27 00 00       	call   80104623 <release>
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
80101ebb:	8b 15 34 26 11 80    	mov    0x80112634,%edx
80101ec1:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101ec3:	a1 34 26 11 80       	mov    0x80112634,%eax
80101ec8:	8b 40 10             	mov    0x10(%eax),%eax
}
80101ecb:	c3                   	ret    

80101ecc <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80101ecc:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80101ed2:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101ed4:	a1 34 26 11 80       	mov    0x80112634,%eax
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
80101ee6:	c7 05 34 26 11 80 00 	movl   $0xfec00000,0x80112634
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
80101f0d:	0f b6 15 80 27 11 80 	movzbl 0x80112780,%edx
80101f14:	39 c2                	cmp    %eax,%edx
80101f16:	75 07                	jne    80101f1f <ioapicinit+0x42>
{
80101f18:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f1d:	eb 36                	jmp    80101f55 <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f1f:	83 ec 0c             	sub    $0xc,%esp
80101f22:	68 d4 73 10 80       	push   $0x801073d4
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
80101f9e:	81 fb 70 73 11 80    	cmp    $0x80117370,%ebx
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
80101fc6:	e8 9f 26 00 00       	call   8010466a <memset>

  if(kmem.use_lock)
80101fcb:	83 c4 10             	add    $0x10,%esp
80101fce:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80101fd5:	75 35                	jne    8010200c <kfree+0x80>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80101fd7:	a1 78 26 11 80       	mov    0x80112678,%eax
80101fdc:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101fde:	89 1d 78 26 11 80    	mov    %ebx,0x80112678
  if(kmem.use_lock)
80101fe4:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80101feb:	75 31                	jne    8010201e <kfree+0x92>
    release(&kmem.lock);
}
80101fed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101ff0:	c9                   	leave  
80101ff1:	c3                   	ret    
        panic("V2P on address < KERNBASE "
80101ff2:	83 ec 0c             	sub    $0xc,%esp
80101ff5:	68 08 74 10 80       	push   $0x80107408
80101ffa:	e8 49 e3 ff ff       	call   80100348 <panic>
    panic("kfree");
80101fff:	83 ec 0c             	sub    $0xc,%esp
80102002:	68 96 74 10 80       	push   $0x80107496
80102007:	e8 3c e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200c:	83 ec 0c             	sub    $0xc,%esp
8010200f:	68 40 26 11 80       	push   $0x80112640
80102014:	e8 a5 25 00 00       	call   801045be <acquire>
80102019:	83 c4 10             	add    $0x10,%esp
8010201c:	eb b9                	jmp    80101fd7 <kfree+0x4b>
    release(&kmem.lock);
8010201e:	83 ec 0c             	sub    $0xc,%esp
80102021:	68 40 26 11 80       	push   $0x80112640
80102026:	e8 f8 25 00 00       	call   80104623 <release>
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
8010204e:	68 9c 74 10 80       	push   $0x8010749c
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
8010207d:	68 a6 74 10 80       	push   $0x801074a6
80102082:	68 40 26 11 80       	push   $0x80112640
80102087:	e8 f6 23 00 00       	call   80104482 <initlock>
  kmem.use_lock = 0;
8010208c:	c7 05 74 26 11 80 00 	movl   $0x0,0x80112674
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
801020ba:	c7 05 74 26 11 80 01 	movl   $0x1,0x80112674
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
801020d0:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
801020d7:	75 21                	jne    801020fa <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
801020d9:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx
  if(r)
801020df:	85 db                	test   %ebx,%ebx
801020e1:	74 07                	je     801020ea <kalloc+0x21>
    kmem.freelist = r->next;
801020e3:	8b 03                	mov    (%ebx),%eax
801020e5:	a3 78 26 11 80       	mov    %eax,0x80112678
  if(kmem.use_lock)
801020ea:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
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
801020fd:	68 40 26 11 80       	push   $0x80112640
80102102:	e8 b7 24 00 00       	call   801045be <acquire>
80102107:	83 c4 10             	add    $0x10,%esp
8010210a:	eb cd                	jmp    801020d9 <kalloc+0x10>
    release(&kmem.lock);
8010210c:	83 ec 0c             	sub    $0xc,%esp
8010210f:	68 40 26 11 80       	push   $0x80112640
80102114:	e8 0a 25 00 00       	call   80104623 <release>
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
8010213d:	8b 15 7c 26 11 80    	mov    0x8011267c,%edx
80102143:	f6 c2 40             	test   $0x40,%dl
80102146:	74 0f                	je     80102157 <kbdgetc+0x39>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102148:	83 c8 80             	or     $0xffffff80,%eax
8010214b:	0f b6 c8             	movzbl %al,%ecx
    shift &= ~E0ESC;
8010214e:	83 e2 bf             	and    $0xffffffbf,%edx
80102151:	89 15 7c 26 11 80    	mov    %edx,0x8011267c
  }

  shift |= shiftcode[data];
80102157:	0f b6 91 e0 75 10 80 	movzbl -0x7fef8a20(%ecx),%edx
8010215e:	0b 15 7c 26 11 80    	or     0x8011267c,%edx
80102164:	89 15 7c 26 11 80    	mov    %edx,0x8011267c
  shift ^= togglecode[data];
8010216a:	0f b6 81 e0 74 10 80 	movzbl -0x7fef8b20(%ecx),%eax
80102171:	31 c2                	xor    %eax,%edx
80102173:	89 15 7c 26 11 80    	mov    %edx,0x8011267c
  c = charcode[shift & (CTL | SHIFT)][data];
80102179:	89 d0                	mov    %edx,%eax
8010217b:	83 e0 03             	and    $0x3,%eax
8010217e:	8b 04 85 c0 74 10 80 	mov    -0x7fef8b40(,%eax,4),%eax
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
8010219a:	83 0d 7c 26 11 80 40 	orl    $0x40,0x8011267c
    return 0;
801021a1:	b8 00 00 00 00       	mov    $0x0,%eax
801021a6:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801021a7:	8b 15 7c 26 11 80    	mov    0x8011267c,%edx
801021ad:	f6 c2 40             	test   $0x40,%dl
801021b0:	75 05                	jne    801021b7 <kbdgetc+0x99>
801021b2:	89 c1                	mov    %eax,%ecx
801021b4:	83 e1 7f             	and    $0x7f,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
801021b7:	0f b6 81 e0 75 10 80 	movzbl -0x7fef8a20(%ecx),%eax
801021be:	83 c8 40             	or     $0x40,%eax
801021c1:	0f b6 c0             	movzbl %al,%eax
801021c4:	f7 d0                	not    %eax
801021c6:	21 c2                	and    %eax,%edx
801021c8:	89 15 7c 26 11 80    	mov    %edx,0x8011267c
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
80102207:	8b 0d 80 26 11 80    	mov    0x80112680,%ecx
8010220d:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102210:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102212:	a1 80 26 11 80       	mov    0x80112680,%eax
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
80102286:	83 3d 80 26 11 80 00 	cmpl   $0x0,0x80112680
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
801022f3:	a1 80 26 11 80       	mov    0x80112680,%eax
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
8010235c:	a1 80 26 11 80       	mov    0x80112680,%eax
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
80102392:	a1 80 26 11 80       	mov    0x80112680,%eax
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
801023a8:	83 3d 80 26 11 80 00 	cmpl   $0x0,0x80112680
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
801024aa:	e8 fe 21 00 00       	call   801046ad <memcmp>
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
8010256b:	ff 35 d4 26 11 80    	push   0x801126d4
80102571:	ff 35 e4 26 11 80    	push   0x801126e4
80102577:	e8 f0 db ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
8010257c:	8b 58 5c             	mov    0x5c(%eax),%ebx
8010257f:	89 1d e8 26 11 80    	mov    %ebx,0x801126e8
  for (i = 0; i < log.lh.n; i++) {
80102585:	83 c4 10             	add    $0x10,%esp
80102588:	ba 00 00 00 00       	mov    $0x0,%edx
8010258d:	eb 0e                	jmp    8010259d <read_head+0x39>
    log.lh.block[i] = lh->block[i];
8010258f:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102593:	89 0c 95 ec 26 11 80 	mov    %ecx,-0x7feed914(,%edx,4)
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
801025c4:	03 05 d4 26 11 80    	add    0x801126d4,%eax
801025ca:	83 c0 01             	add    $0x1,%eax
801025cd:	83 ec 08             	sub    $0x8,%esp
801025d0:	50                   	push   %eax
801025d1:	ff 35 e4 26 11 80    	push   0x801126e4
801025d7:	e8 90 db ff ff       	call   8010016c <bread>
801025dc:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801025de:	83 c4 08             	add    $0x8,%esp
801025e1:	ff 34 b5 ec 26 11 80 	push   -0x7feed914(,%esi,4)
801025e8:	ff 35 e4 26 11 80    	push   0x801126e4
801025ee:	e8 79 db ff ff       	call   8010016c <bread>
801025f3:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801025f5:	8d 57 5c             	lea    0x5c(%edi),%edx
801025f8:	8d 40 5c             	lea    0x5c(%eax),%eax
801025fb:	83 c4 0c             	add    $0xc,%esp
801025fe:	68 00 02 00 00       	push   $0x200
80102603:	52                   	push   %edx
80102604:	50                   	push   %eax
80102605:	e8 d8 20 00 00       	call   801046e2 <memmove>
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
80102628:	39 35 e8 26 11 80    	cmp    %esi,0x801126e8
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
8010263f:	ff 35 d4 26 11 80    	push   0x801126d4
80102645:	ff 35 e4 26 11 80    	push   0x801126e4
8010264b:	e8 1c db ff ff       	call   8010016c <bread>
80102650:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102652:	8b 0d e8 26 11 80    	mov    0x801126e8,%ecx
80102658:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010265b:	83 c4 10             	add    $0x10,%esp
8010265e:	b8 00 00 00 00       	mov    $0x0,%eax
80102663:	eb 0e                	jmp    80102673 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
80102665:	8b 14 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%edx
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
801026a0:	c7 05 e8 26 11 80 00 	movl   $0x0,0x801126e8
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
801026c3:	03 05 d4 26 11 80    	add    0x801126d4,%eax
801026c9:	83 c0 01             	add    $0x1,%eax
801026cc:	83 ec 08             	sub    $0x8,%esp
801026cf:	50                   	push   %eax
801026d0:	ff 35 e4 26 11 80    	push   0x801126e4
801026d6:	e8 91 da ff ff       	call   8010016c <bread>
801026db:	89 c3                	mov    %eax,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801026dd:	83 c4 08             	add    $0x8,%esp
801026e0:	ff 34 b5 ec 26 11 80 	push   -0x7feed914(,%esi,4)
801026e7:	ff 35 e4 26 11 80    	push   0x801126e4
801026ed:	e8 7a da ff ff       	call   8010016c <bread>
801026f2:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
801026f4:	8d 50 5c             	lea    0x5c(%eax),%edx
801026f7:	8d 43 5c             	lea    0x5c(%ebx),%eax
801026fa:	83 c4 0c             	add    $0xc,%esp
801026fd:	68 00 02 00 00       	push   $0x200
80102702:	52                   	push   %edx
80102703:	50                   	push   %eax
80102704:	e8 d9 1f 00 00       	call   801046e2 <memmove>
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
80102727:	39 35 e8 26 11 80    	cmp    %esi,0x801126e8
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
80102737:	83 3d e8 26 11 80 00 	cmpl   $0x0,0x801126e8
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
80102756:	c7 05 e8 26 11 80 00 	movl   $0x0,0x801126e8
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
80102771:	68 e0 76 10 80       	push   $0x801076e0
80102776:	68 a0 26 11 80       	push   $0x801126a0
8010277b:	e8 02 1d 00 00       	call   80104482 <initlock>
  readsb(dev, &sb);
80102780:	83 c4 08             	add    $0x8,%esp
80102783:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102786:	50                   	push   %eax
80102787:	53                   	push   %ebx
80102788:	e8 19 eb ff ff       	call   801012a6 <readsb>
  log.start = sb.logstart;
8010278d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102790:	a3 d4 26 11 80       	mov    %eax,0x801126d4
  log.size = sb.nlog;
80102795:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102798:	a3 d8 26 11 80       	mov    %eax,0x801126d8
  log.dev = dev;
8010279d:	89 1d e4 26 11 80    	mov    %ebx,0x801126e4
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
801027b6:	68 a0 26 11 80       	push   $0x801126a0
801027bb:	e8 fe 1d 00 00       	call   801045be <acquire>
801027c0:	83 c4 10             	add    $0x10,%esp
801027c3:	eb 15                	jmp    801027da <begin_op+0x2a>
      sleep(&log, &log.lock);
801027c5:	83 ec 08             	sub    $0x8,%esp
801027c8:	68 a0 26 11 80       	push   $0x801126a0
801027cd:	68 a0 26 11 80       	push   $0x801126a0
801027d2:	e8 e4 18 00 00       	call   801040bb <sleep>
801027d7:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
801027da:	83 3d e0 26 11 80 00 	cmpl   $0x0,0x801126e0
801027e1:	75 e2                	jne    801027c5 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801027e3:	a1 dc 26 11 80       	mov    0x801126dc,%eax
801027e8:	83 c0 01             	add    $0x1,%eax
801027eb:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801027ee:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
801027f1:	03 15 e8 26 11 80    	add    0x801126e8,%edx
801027f7:	83 fa 1e             	cmp    $0x1e,%edx
801027fa:	7e 17                	jle    80102813 <begin_op+0x63>
      sleep(&log, &log.lock);
801027fc:	83 ec 08             	sub    $0x8,%esp
801027ff:	68 a0 26 11 80       	push   $0x801126a0
80102804:	68 a0 26 11 80       	push   $0x801126a0
80102809:	e8 ad 18 00 00       	call   801040bb <sleep>
8010280e:	83 c4 10             	add    $0x10,%esp
80102811:	eb c7                	jmp    801027da <begin_op+0x2a>
      log.outstanding += 1;
80102813:	a3 dc 26 11 80       	mov    %eax,0x801126dc
      release(&log.lock);
80102818:	83 ec 0c             	sub    $0xc,%esp
8010281b:	68 a0 26 11 80       	push   $0x801126a0
80102820:	e8 fe 1d 00 00       	call   80104623 <release>
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
80102831:	68 a0 26 11 80       	push   $0x801126a0
80102836:	e8 83 1d 00 00       	call   801045be <acquire>
  log.outstanding -= 1;
8010283b:	a1 dc 26 11 80       	mov    0x801126dc,%eax
80102840:	83 e8 01             	sub    $0x1,%eax
80102843:	a3 dc 26 11 80       	mov    %eax,0x801126dc
  if(log.committing)
80102848:	8b 1d e0 26 11 80    	mov    0x801126e0,%ebx
8010284e:	83 c4 10             	add    $0x10,%esp
80102851:	85 db                	test   %ebx,%ebx
80102853:	75 2c                	jne    80102881 <end_op+0x57>
  if(log.outstanding == 0){
80102855:	85 c0                	test   %eax,%eax
80102857:	75 35                	jne    8010288e <end_op+0x64>
    log.committing = 1;
80102859:	c7 05 e0 26 11 80 01 	movl   $0x1,0x801126e0
80102860:	00 00 00 
    do_commit = 1;
80102863:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102868:	83 ec 0c             	sub    $0xc,%esp
8010286b:	68 a0 26 11 80       	push   $0x801126a0
80102870:	e8 ae 1d 00 00       	call   80104623 <release>
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
80102884:	68 e4 76 10 80       	push   $0x801076e4
80102889:	e8 ba da ff ff       	call   80100348 <panic>
    wakeup(&log);
8010288e:	83 ec 0c             	sub    $0xc,%esp
80102891:	68 a0 26 11 80       	push   $0x801126a0
80102896:	e8 88 19 00 00       	call   80104223 <wakeup>
8010289b:	83 c4 10             	add    $0x10,%esp
8010289e:	eb c8                	jmp    80102868 <end_op+0x3e>
    commit();
801028a0:	e8 92 fe ff ff       	call   80102737 <commit>
    acquire(&log.lock);
801028a5:	83 ec 0c             	sub    $0xc,%esp
801028a8:	68 a0 26 11 80       	push   $0x801126a0
801028ad:	e8 0c 1d 00 00       	call   801045be <acquire>
    log.committing = 0;
801028b2:	c7 05 e0 26 11 80 00 	movl   $0x0,0x801126e0
801028b9:	00 00 00 
    wakeup(&log);
801028bc:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
801028c3:	e8 5b 19 00 00       	call   80104223 <wakeup>
    release(&log.lock);
801028c8:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
801028cf:	e8 4f 1d 00 00       	call   80104623 <release>
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
801028e3:	8b 15 e8 26 11 80    	mov    0x801126e8,%edx
801028e9:	83 fa 1d             	cmp    $0x1d,%edx
801028ec:	7f 2c                	jg     8010291a <log_write+0x41>
801028ee:	a1 d8 26 11 80       	mov    0x801126d8,%eax
801028f3:	83 e8 01             	sub    $0x1,%eax
801028f6:	39 c2                	cmp    %eax,%edx
801028f8:	7d 20                	jge    8010291a <log_write+0x41>
    panic("too big a transaction");
  if (log.outstanding < 1)
801028fa:	83 3d dc 26 11 80 00 	cmpl   $0x0,0x801126dc
80102901:	7e 24                	jle    80102927 <log_write+0x4e>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102903:	83 ec 0c             	sub    $0xc,%esp
80102906:	68 a0 26 11 80       	push   $0x801126a0
8010290b:	e8 ae 1c 00 00       	call   801045be <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102910:	83 c4 10             	add    $0x10,%esp
80102913:	b8 00 00 00 00       	mov    $0x0,%eax
80102918:	eb 1d                	jmp    80102937 <log_write+0x5e>
    panic("too big a transaction");
8010291a:	83 ec 0c             	sub    $0xc,%esp
8010291d:	68 f3 76 10 80       	push   $0x801076f3
80102922:	e8 21 da ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102927:	83 ec 0c             	sub    $0xc,%esp
8010292a:	68 09 77 10 80       	push   $0x80107709
8010292f:	e8 14 da ff ff       	call   80100348 <panic>
  for (i = 0; i < log.lh.n; i++) {
80102934:	83 c0 01             	add    $0x1,%eax
80102937:	8b 15 e8 26 11 80    	mov    0x801126e8,%edx
8010293d:	39 c2                	cmp    %eax,%edx
8010293f:	7e 0c                	jle    8010294d <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102941:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102944:	39 0c 85 ec 26 11 80 	cmp    %ecx,-0x7feed914(,%eax,4)
8010294b:	75 e7                	jne    80102934 <log_write+0x5b>
      break;
  }
  log.lh.block[i] = b->blockno;
8010294d:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102950:	89 0c 85 ec 26 11 80 	mov    %ecx,-0x7feed914(,%eax,4)
  if (i == log.lh.n)
80102957:	39 c2                	cmp    %eax,%edx
80102959:	74 18                	je     80102973 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
8010295b:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
8010295e:	83 ec 0c             	sub    $0xc,%esp
80102961:	68 a0 26 11 80       	push   $0x801126a0
80102966:	e8 b8 1c 00 00       	call   80104623 <release>
}
8010296b:	83 c4 10             	add    $0x10,%esp
8010296e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102971:	c9                   	leave  
80102972:	c3                   	ret    
    log.lh.n++;
80102973:	83 c2 01             	add    $0x1,%edx
80102976:	89 15 e8 26 11 80    	mov    %edx,0x801126e8
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
8010298a:	68 8c b4 10 80       	push   $0x8010b48c
8010298f:	68 00 70 00 80       	push   $0x80007000
80102994:	e8 49 1d 00 00       	call   801046e2 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102999:	83 c4 10             	add    $0x10,%esp
8010299c:	bb a0 27 11 80       	mov    $0x801127a0,%ebx
801029a1:	eb 13                	jmp    801029b6 <startothers+0x38>
801029a3:	83 ec 0c             	sub    $0xc,%esp
801029a6:	68 08 74 10 80       	push   $0x80107408
801029ab:	e8 98 d9 ff ff       	call   80100348 <panic>
801029b0:	81 c3 b4 00 00 00    	add    $0xb4,%ebx
801029b6:	69 05 84 27 11 80 b4 	imul   $0xb4,0x80112784,%eax
801029bd:	00 00 00 
801029c0:	05 a0 27 11 80       	add    $0x801127a0,%eax
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
801029eb:	b8 00 a0 10 80       	mov    $0x8010a000,%eax
801029f0:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
801029f5:	76 ac                	jbe    801029a3 <startothers+0x25>
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801029f7:	c7 05 f4 6f 00 80 00 	movl   $0x10a000,0x80006ff4
801029fe:	a0 10 00 

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
80102a3e:	68 24 77 10 80       	push   $0x80107724
80102a43:	e8 bf db ff ff       	call   80100607 <cprintf>
  idtinit();       // load idt register
80102a48:	e8 11 2e 00 00       	call   8010585e <idtinit>
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
80102a60:	e8 de 0f 00 00       	call   80103a43 <scheduler>

80102a65 <mpenter>:
{
80102a65:	55                   	push   %ebp
80102a66:	89 e5                	mov    %esp,%ebp
80102a68:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a6b:	e8 93 3f 00 00       	call   80106a03 <switchkvm>
  seginit();
80102a70:	e8 19 3d 00 00       	call   8010678e <seginit>
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
80102a95:	68 70 73 11 80       	push   $0x80117370
80102a9a:	e8 d8 f5 ff ff       	call   80102077 <kinit1>
  kvmalloc();      // kernel page table
80102a9f:	e8 c0 44 00 00       	call   80106f64 <kvmalloc>
  mpinit();        // detect other processors
80102aa4:	e8 db 01 00 00       	call   80102c84 <mpinit>
  lapicinit();     // interrupt controller
80102aa9:	e8 d8 f7 ff ff       	call   80102286 <lapicinit>
  seginit();       // segment descriptors
80102aae:	e8 db 3c 00 00       	call   8010678e <seginit>
  picinit();       // disable pic
80102ab3:	e8 a2 02 00 00       	call   80102d5a <picinit>
  ioapicinit();    // another interrupt controller
80102ab8:	e8 20 f4 ff ff       	call   80101edd <ioapicinit>
  consoleinit();   // console hardware
80102abd:	e8 c8 dd ff ff       	call   8010088a <consoleinit>
  uartinit();      // serial port
80102ac2:	e8 8d 30 00 00       	call   80105b54 <uartinit>
  pinit();         // process table
80102ac7:	e8 34 08 00 00       	call   80103300 <pinit>
  tvinit();        // trap vectors
80102acc:	e8 88 2c 00 00       	call   80105759 <tvinit>
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
80102b3f:	68 38 77 10 80       	push   $0x80107738
80102b44:	e8 ff d7 ff ff       	call   80100348 <panic>
80102b49:	83 c3 10             	add    $0x10,%ebx
80102b4c:	39 f3                	cmp    %esi,%ebx
80102b4e:	73 29                	jae    80102b79 <mpsearch1+0x54>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b50:	83 ec 04             	sub    $0x4,%esp
80102b53:	6a 04                	push   $0x4
80102b55:	68 52 77 10 80       	push   $0x80107752
80102b5a:	53                   	push   %ebx
80102b5b:	e8 4d 1b 00 00       	call   801046ad <memcmp>
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
80102c1f:	68 57 77 10 80       	push   $0x80107757
80102c24:	53                   	push   %ebx
80102c25:	e8 83 1a 00 00       	call   801046ad <memcmp>
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
80102c61:	68 38 77 10 80       	push   $0x80107738
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
80102c9c:	89 15 80 26 11 80    	mov    %edx,0x80112680
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
80102cb5:	68 5c 77 10 80       	push   $0x8010775c
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
80102cec:	8b 35 84 27 11 80    	mov    0x80112784,%esi
80102cf2:	83 fe 07             	cmp    $0x7,%esi
80102cf5:	7f 19                	jg     80102d10 <mpinit+0x8c>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102cf7:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102cfb:	69 fe b4 00 00 00    	imul   $0xb4,%esi,%edi
80102d01:	88 87 a0 27 11 80    	mov    %al,-0x7feed860(%edi)
        ncpu++;
80102d07:	83 c6 01             	add    $0x1,%esi
80102d0a:	89 35 84 27 11 80    	mov    %esi,0x80112784
      p += sizeof(struct mpproc);
80102d10:	83 c2 14             	add    $0x14,%edx
      continue;
80102d13:	eb bd                	jmp    80102cd2 <mpinit+0x4e>
      ioapicid = ioapic->apicno;
80102d15:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102d19:	a2 80 27 11 80       	mov    %al,0x80112780
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
80102d50:	68 74 77 10 80       	push   $0x80107774
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
80102dd7:	68 93 77 10 80       	push   $0x80107793
80102ddc:	50                   	push   %eax
80102ddd:	e8 a0 16 00 00       	call   80104482 <initlock>
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
80102e61:	e8 58 17 00 00       	call   801045be <acquire>
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
80102e83:	e8 9b 13 00 00       	call   80104223 <wakeup>
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
80102ea1:	e8 7d 17 00 00       	call   80104623 <release>
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
80102ec2:	e8 5c 13 00 00       	call   80104223 <wakeup>
80102ec7:	83 c4 10             	add    $0x10,%esp
80102eca:	eb bf                	jmp    80102e8b <pipeclose+0x35>
    release(&p->lock);
80102ecc:	83 ec 0c             	sub    $0xc,%esp
80102ecf:	53                   	push   %ebx
80102ed0:	e8 4e 17 00 00       	call   80104623 <release>
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
80102ef2:	e8 c7 16 00 00       	call   801045be <acquire>
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
80102f0d:	e8 11 13 00 00       	call   80104223 <wakeup>
  release(&p->lock);
80102f12:	89 1c 24             	mov    %ebx,(%esp)
80102f15:	e8 09 17 00 00       	call   80104623 <release>
  return n;
80102f1a:	83 c4 10             	add    $0x10,%esp
80102f1d:	89 f0                	mov    %esi,%eax
80102f1f:	eb 5c                	jmp    80102f7d <pipewrite+0x9b>
      wakeup(&p->nread);
80102f21:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f27:	83 ec 0c             	sub    $0xc,%esp
80102f2a:	50                   	push   %eax
80102f2b:	e8 f3 12 00 00       	call   80104223 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f30:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f36:	83 c4 08             	add    $0x8,%esp
80102f39:	53                   	push   %ebx
80102f3a:	50                   	push   %eax
80102f3b:	e8 7b 11 00 00       	call   801040bb <sleep>
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
80102f70:	e8 ae 16 00 00       	call   80104623 <release>
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
80102fb7:	e8 02 16 00 00       	call   801045be <acquire>
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
80102fcc:	e8 ea 10 00 00       	call   801040bb <sleep>
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
80102ffb:	e8 23 16 00 00       	call   80104623 <release>
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
80103040:	e8 de 11 00 00       	call   80104223 <wakeup>
  release(&p->lock);
80103045:	89 1c 24             	mov    %ebx,(%esp)
80103048:	e8 d6 15 00 00       	call   80104623 <release>
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
80103061:	ba 94 2d 11 80       	mov    $0x80112d94,%edx
80103066:	eb 06                	jmp    8010306e <wakeup1+0xd>
80103068:	81 c2 84 00 00 00    	add    $0x84,%edx
8010306e:	81 fa 94 4e 11 80    	cmp    $0x80114e94,%edx
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
80103092:	68 60 2d 11 80       	push   $0x80112d60
80103097:	e8 22 15 00 00       	call   801045be <acquire>
  for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
8010309c:	83 c4 10             	add    $0x10,%esp
8010309f:	bb 94 2d 11 80       	mov    $0x80112d94,%ebx
801030a4:	eb 06                	jmp    801030ac <allocproc+0x21>
801030a6:	81 c3 84 00 00 00    	add    $0x84,%ebx
801030ac:	81 fb 94 4e 11 80    	cmp    $0x80114e94,%ebx
801030b2:	0f 83 87 00 00 00    	jae    8010313f <allocproc+0xb4>
    if(p->state == UNUSED)
801030b8:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
801030bc:	75 e8                	jne    801030a6 <allocproc+0x1b>
  p->state = EMBRYO;
801030be:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
801030c5:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801030ca:	8d 50 01             	lea    0x1(%eax),%edx
801030cd:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801030d3:	89 43 10             	mov    %eax,0x10(%ebx)
  p->ticks_left = RSDL_PROC_QUANTUM;
801030d6:	c7 43 7c 14 00 00 00 	movl   $0x14,0x7c(%ebx)
  p->default_level = RSDL_STARTING_LEVEL;
801030dd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
801030e4:	00 00 00 
  release(&ptable.lock);
801030e7:	83 ec 0c             	sub    $0xc,%esp
801030ea:	68 60 2d 11 80       	push   $0x80112d60
801030ef:	e8 2f 15 00 00       	call   80104623 <release>
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
8010310c:	c7 80 b0 0f 00 00 4e 	movl   $0x8010574e,0xfb0(%eax)
80103113:	57 10 80 
  sp -= sizeof *p->context;
80103116:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
8010311b:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
8010311e:	83 ec 04             	sub    $0x4,%esp
80103121:	6a 14                	push   $0x14
80103123:	6a 00                	push   $0x0
80103125:	50                   	push   %eax
80103126:	e8 3f 15 00 00       	call   8010466a <memset>
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
80103142:	68 60 2d 11 80       	push   $0x80112d60
80103147:	e8 d7 14 00 00       	call   80104623 <release>
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
80103167:	68 60 2d 11 80       	push   $0x80112d60
8010316c:	e8 b2 14 00 00       	call   80104623 <release>
  if (first) {
80103171:	83 c4 10             	add    $0x10,%esp
80103174:	83 3d 00 b0 10 80 00 	cmpl   $0x0,0x8010b000
8010317b:	75 02                	jne    8010317f <forkret+0x1e>
}
8010317d:	c9                   	leave  
8010317e:	c3                   	ret    
    first = 0;
8010317f:	c7 05 00 b0 10 80 00 	movl   $0x0,0x8010b000
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
801031aa:	a1 94 4e 11 80       	mov    0x80114e94,%eax
         && q < &ptable.active[RSDL_LEVELS];
801031af:	39 d0                	cmp    %edx,%eax
801031b1:	77 10                	ja     801031c3 <is_active_set+0x1f>
801031b3:	05 2c 06 00 00       	add    $0x62c,%eax
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
801031ef:	c7 05 44 2d 11 80 01 	movl   $0x1,0x80112d44
801031f6:	00 00 00 
  schedlog_lasttick = ticks + n;
801031f9:	a1 00 5b 11 80       	mov    0x80115b00,%eax
801031fe:	03 45 08             	add    0x8(%ebp),%eax
80103201:	a3 40 2d 11 80       	mov    %eax,0x80112d40
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
80103211:	a1 94 4e 11 80       	mov    0x80114e94,%eax
80103216:	89 45 e0             	mov    %eax,-0x20(%ebp)
80103219:	a1 98 4e 11 80       	mov    0x80114e98,%eax
8010321e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for (int s = 0; s < 2; ++s) {
80103221:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
80103228:	e9 99 00 00 00       	jmp    801032c6 <print_schedlog+0xbe>
    char *set_name = (is_active_set(&set[s][0])) ? "active" : "expired";
8010322d:	c7 45 d0 9f 77 10 80 	movl   $0x8010779f,-0x30(%ebp)
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
8010325a:	68 b4 77 10 80       	push   $0x801077b4
8010325f:	e8 a3 d3 ff ff       	call   80100607 <cprintf>
80103264:	83 c4 20             	add    $0x20,%esp
80103267:	eb d0                	jmp    80103239 <print_schedlog+0x31>
      release(&qq->lock);
80103269:	83 ec 0c             	sub    $0xc,%esp
8010326c:	56                   	push   %esi
8010326d:	e8 b1 13 00 00       	call   80104623 <release>
      cprintf("\n");
80103272:	c7 04 24 9b 7f 10 80 	movl   $0x80107f9b,(%esp)
80103279:	e8 89 d3 ff ff       	call   80100607 <cprintf>
    for (int k = 0; k < RSDL_LEVELS; ++k) {
8010327e:	83 c7 01             	add    $0x1,%edi
80103281:	83 c4 10             	add    $0x10,%esp
80103284:	83 ff 04             	cmp    $0x4,%edi
80103287:	7f 39                	jg     801032c2 <print_schedlog+0xba>
      qq = &set[s][k];
80103289:	69 f7 3c 01 00 00    	imul   $0x13c,%edi,%esi
8010328f:	03 75 d4             	add    -0x2c(%ebp),%esi
      acquire(&qq->lock);
80103292:	83 ec 0c             	sub    $0xc,%esp
80103295:	56                   	push   %esi
80103296:	e8 23 13 00 00       	call   801045be <acquire>
      cprintf("%d|%s|%d(%d)", ticks, set_name, k, qq->ticks_left);
8010329b:	83 c4 04             	add    $0x4,%esp
8010329e:	ff 76 38             	push   0x38(%esi)
801032a1:	57                   	push   %edi
801032a2:	ff 75 d0             	push   -0x30(%ebp)
801032a5:	ff 35 00 5b 11 80    	push   0x80115b00
801032ab:	68 a7 77 10 80       	push   $0x801077a7
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
801032ea:	c7 45 d0 98 77 10 80 	movl   $0x80107798,-0x30(%ebp)
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
80103309:	68 c3 77 10 80       	push   $0x801077c3
8010330e:	68 60 2d 11 80       	push   $0x80112d60
80103313:	e8 6a 11 00 00       	call   80104482 <initlock>
  acquire(&ptable.lock);
80103318:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
8010331f:	e8 9a 12 00 00       	call   801045be <acquire>
  for (int s = 0; s < 2; ++s) {
80103324:	83 c4 10             	add    $0x10,%esp
80103327:	be 00 00 00 00       	mov    $0x0,%esi
8010332c:	e9 8a 00 00 00       	jmp    801033bb <pinit+0xbb>
        lq->proc[i] = NULL;
80103331:	6b d3 4f             	imul   $0x4f,%ebx,%edx
80103334:	69 ce 8b 01 00 00    	imul   $0x18b,%esi,%ecx
8010333a:	01 ca                	add    %ecx,%edx
8010333c:	8d 94 10 58 08 00 00 	lea    0x858(%eax,%edx,1),%edx
80103343:	c7 04 95 78 2d 11 80 	movl   $0x0,-0x7feed288(,%edx,4)
8010334a:	00 00 00 00 
      for (int i = 0; i < NPROC; ++i){
8010334e:	83 c0 01             	add    $0x1,%eax
80103351:	83 f8 3f             	cmp    $0x3f,%eax
80103354:	7e db                	jle    80103331 <pinit+0x31>
      release(&lq->lock);
80103356:	83 ec 0c             	sub    $0xc,%esp
80103359:	57                   	push   %edi
8010335a:	e8 c4 12 00 00       	call   80104623 <release>
    for (int k = 0; k < RSDL_LEVELS; ++k){
8010335f:	83 c3 01             	add    $0x1,%ebx
80103362:	83 c4 10             	add    $0x10,%esp
80103365:	83 fb 04             	cmp    $0x4,%ebx
80103368:	7f 4e                	jg     801033b8 <pinit+0xb8>
      initlock(&lq->lock, "level queue");
8010336a:	69 d3 3c 01 00 00    	imul   $0x13c,%ebx,%edx
80103370:	69 c6 2c 06 00 00    	imul   $0x62c,%esi,%eax
80103376:	01 d0                	add    %edx,%eax
80103378:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010337b:	8d b8 9c 4e 11 80    	lea    -0x7feeb164(%eax),%edi
80103381:	83 ec 08             	sub    $0x8,%esp
80103384:	68 ca 77 10 80       	push   $0x801077ca
80103389:	57                   	push   %edi
8010338a:	e8 f3 10 00 00       	call   80104482 <initlock>
      acquire(&lq->lock);
8010338f:	89 3c 24             	mov    %edi,(%esp)
80103392:	e8 27 12 00 00       	call   801045be <acquire>
      lq->numproc = 0;
80103397:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010339a:	c7 80 d0 4e 11 80 00 	movl   $0x0,-0x7feeb130(%eax)
801033a1:	00 00 00 
      lq->ticks_left = RSDL_LEVEL_QUANTUM;
801033a4:	c7 80 d4 4e 11 80 37 	movl   $0x37,-0x7feeb12c(%eax)
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
801033c7:	c7 05 94 4e 11 80 9c 	movl   $0x80114e9c,0x80114e94
801033ce:	4e 11 80 
  ptable.expired = ptable.level[1];
801033d1:	c7 05 98 4e 11 80 c8 	movl   $0x801154c8,0x80114e98
801033d8:	54 11 80 
  release(&ptable.lock);
801033db:	83 ec 0c             	sub    $0xc,%esp
801033de:	68 60 2d 11 80       	push   $0x80112d60
801033e3:	e8 3b 12 00 00       	call   80104623 <release>
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
8010340a:	39 15 84 27 11 80    	cmp    %edx,0x80112784
80103410:	7e 23                	jle    80103435 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
80103412:	69 ca b4 00 00 00    	imul   $0xb4,%edx,%ecx
80103418:	0f b6 89 a0 27 11 80 	movzbl -0x7feed860(%ecx),%ecx
8010341f:	39 c1                	cmp    %eax,%ecx
80103421:	74 1f                	je     80103442 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
80103423:	83 c2 01             	add    $0x1,%edx
80103426:	eb e2                	jmp    8010340a <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
80103428:	83 ec 0c             	sub    $0xc,%esp
8010342b:	68 78 79 10 80       	push   $0x80107978
80103430:	e8 13 cf ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103435:	83 ec 0c             	sub    $0xc,%esp
80103438:	68 d6 77 10 80       	push   $0x801077d6
8010343d:	e8 06 cf ff ff       	call   80100348 <panic>
      return &cpus[i];
80103442:	69 c2 b4 00 00 00    	imul   $0xb4,%edx,%eax
80103448:	05 a0 27 11 80       	add    $0x801127a0,%eax
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
8010345a:	2d a0 27 11 80       	sub    $0x801127a0,%eax
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
80103471:	e8 6d 10 00 00       	call   801044e3 <pushcli>
  c = mycpu();
80103476:	e8 78 ff ff ff       	call   801033f3 <mycpu>
  p = c->proc;
8010347b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103481:	e8 99 10 00 00       	call   8010451f <popcli>
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
801034a4:	e8 15 11 00 00       	call   801045be <acquire>
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
801034c2:	e8 5c 11 00 00       	call   80104623 <release>
801034c7:	83 c4 10             	add    $0x10,%esp
}
801034ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
801034cd:	5b                   	pop    %ebx
801034ce:	5e                   	pop    %esi
801034cf:	5d                   	pop    %ebp
801034d0:	c3                   	ret    
    panic("enqueue of NULL proc node");
801034d1:	83 ec 0c             	sub    $0xc,%esp
801034d4:	68 e6 77 10 80       	push   $0x801077e6
801034d9:	e8 6a ce ff ff       	call   80100348 <panic>
    panic("enqueue in NULL queue");
801034de:	83 ec 0c             	sub    $0xc,%esp
801034e1:	68 00 78 10 80       	push   $0x80107800
801034e6:	e8 5d ce ff ff       	call   80100348 <panic>
    panic("enqueue in full level");
801034eb:	83 ec 0c             	sub    $0xc,%esp
801034ee:	68 16 78 10 80       	push   $0x80107816
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
80103529:	68 2c 78 10 80       	push   $0x8010782c
8010352e:	e8 15 ce ff ff       	call   80100348 <panic>
      panic("unqueue on empty level");
80103533:	83 ec 0c             	sub    $0xc,%esp
80103536:	68 42 78 10 80       	push   $0x80107842
8010353b:	e8 08 ce ff ff       	call   80100348 <panic>
  acquire(&q->lock);
80103540:	83 ec 0c             	sub    $0xc,%esp
80103543:	56                   	push   %esi
80103544:	e8 75 10 00 00       	call   801045be <acquire>
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
80103591:	e8 8d 10 00 00       	call   80104623 <release>
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
801035b4:	68 a0 79 10 80       	push   $0x801079a0
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
8010361c:	83 fb 04             	cmp    $0x4,%ebx
8010361f:	7f e8                	jg     80103609 <remove_proc_from_levels+0x21>
      q = &ptable.level[s][k];
80103621:	69 d3 3c 01 00 00    	imul   $0x13c,%ebx,%edx
80103627:	69 c6 2c 06 00 00    	imul   $0x62c,%esi,%eax
8010362d:	8d 84 02 9c 4e 11 80 	lea    -0x7feeb164(%edx,%eax,1),%eax
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
80103671:	8b 0d 98 4e 11 80    	mov    0x80114e98,%ecx
  if (start < 0)
80103677:	85 c0                	test   %eax,%eax
80103679:	79 12                	jns    8010368d <next_level+0x28>
    return -1;
8010367b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103680:	eb 29                	jmp    801036ab <next_level+0x46>
  const struct level_queue *set = (use_expired) ? ptable.expired : ptable.active;
80103682:	8b 0d 94 4e 11 80    	mov    0x80114e94,%ecx
80103688:	eb ed                	jmp    80103677 <next_level+0x12>
  for ( ; k < RSDL_LEVELS; ++k) {
8010368a:	83 c0 01             	add    $0x1,%eax
8010368d:	83 f8 04             	cmp    $0x4,%eax
80103690:	7f 14                	jg     801036a6 <next_level+0x41>
    if (set[k].ticks_left > 0 && set[k].numproc < NPROC) {
80103692:	69 d0 3c 01 00 00    	imul   $0x13c,%eax,%edx
80103698:	01 ca                	add    %ecx,%edx
8010369a:	83 7a 38 00          	cmpl   $0x0,0x38(%edx)
8010369e:	7e ea                	jle    8010368a <next_level+0x25>
801036a0:	83 7a 34 3f          	cmpl   $0x3f,0x34(%edx)
801036a4:	7f e4                	jg     8010368a <next_level+0x25>
  if (k < RSDL_LEVELS) {
801036a6:	83 f8 04             	cmp    $0x4,%eax
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
801036fa:	03 05 94 4e 11 80    	add    0x80114e94,%eax
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
8010371b:	03 05 98 4e 11 80    	add    0x80114e98,%eax
80103721:	eb dd                	jmp    80103700 <find_available_queue+0x22>
      panic("No free level in expired and active set, too many procs");
80103723:	83 ec 0c             	sub    $0xc,%esp
80103726:	68 c8 79 10 80       	push   $0x801079c8
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
8010373e:	a3 f4 5a 11 80       	mov    %eax,0x80115af4
  if((p->pgdir = setupkvm()) == 0)
80103743:	e8 ae 37 00 00       	call   80106ef6 <setupkvm>
80103748:	89 43 04             	mov    %eax,0x4(%ebx)
8010374b:	85 c0                	test   %eax,%eax
8010374d:	0f 84 d2 00 00 00    	je     80103825 <userinit+0xf5>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103753:	83 ec 04             	sub    $0x4,%esp
80103756:	68 2c 00 00 00       	push   $0x2c
8010375b:	68 60 b4 10 80       	push   $0x8010b460
80103760:	50                   	push   %eax
80103761:	e8 36 34 00 00       	call   80106b9c <inituvm>
  p->sz = PGSIZE;
80103766:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010376c:	8b 43 18             	mov    0x18(%ebx),%eax
8010376f:	83 c4 0c             	add    $0xc,%esp
80103772:	6a 4c                	push   $0x4c
80103774:	6a 00                	push   $0x0
80103776:	50                   	push   %eax
80103777:	e8 ee 0e 00 00       	call   8010466a <memset>
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
801037ca:	68 72 78 10 80       	push   $0x80107872
801037cf:	50                   	push   %eax
801037d0:	e8 01 10 00 00       	call   801047d6 <safestrcpy>
  p->cwd = namei("/");
801037d5:	c7 04 24 7b 78 10 80 	movl   $0x8010787b,(%esp)
801037dc:	e8 ec e3 ff ff       	call   80101bcd <namei>
801037e1:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
801037e4:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
801037eb:	e8 ce 0d 00 00       	call   801045be <acquire>
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
80103811:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80103818:	e8 06 0e 00 00       	call   80104623 <release>
}
8010381d:	83 c4 10             	add    $0x10,%esp
80103820:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103823:	c9                   	leave  
80103824:	c3                   	ret    
    panic("userinit: out of memory?");
80103825:	83 ec 0c             	sub    $0xc,%esp
80103828:	68 59 78 10 80       	push   $0x80107859
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
8010384f:	e8 d4 31 00 00       	call   80106a28 <switchuvm>
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
8010386d:	e8 00 35 00 00       	call   80106d72 <allocuvm>
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
8010388a:	e8 3d 34 00 00       	call   80106ccc <deallocuvm>
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
801038ab:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
801038af:	0f 8f 6a 01 00 00    	jg     80103a1f <priofork+0x182>
801038b5:	89 c3                	mov    %eax,%ebx
  if (default_level < 0) {
801038b7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801038bb:	0f 88 65 01 00 00    	js     80103a26 <priofork+0x189>
  if((np = allocproc()) == 0){
801038c1:	e8 c5 f7 ff ff       	call   8010308b <allocproc>
801038c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801038c9:	85 c0                	test   %eax,%eax
801038cb:	0f 84 5c 01 00 00    	je     80103a2d <priofork+0x190>
  if (schedlog_active)
801038d1:	83 3d 44 2d 11 80 00 	cmpl   $0x0,0x80112d44
801038d8:	75 46                	jne    80103920 <priofork+0x83>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801038da:	83 ec 08             	sub    $0x8,%esp
801038dd:	ff 33                	push   (%ebx)
801038df:	ff 73 04             	push   0x4(%ebx)
801038e2:	e8 c0 36 00 00       	call   80106fa7 <copyuvm>
801038e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801038ea:	89 42 04             	mov    %eax,0x4(%edx)
801038ed:	83 c4 10             	add    $0x10,%esp
801038f0:	85 c0                	test   %eax,%eax
801038f2:	74 44                	je     80103938 <priofork+0x9b>
  np->sz = curproc->sz;
801038f4:	8b 03                	mov    (%ebx),%eax
801038f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801038f9:	89 07                	mov    %eax,(%edi)
  np->parent = curproc;
801038fb:	89 f8                	mov    %edi,%eax
801038fd:	89 5f 14             	mov    %ebx,0x14(%edi)
  *np->tf = *curproc->tf;
80103900:	8b 73 18             	mov    0x18(%ebx),%esi
80103903:	8b 7f 18             	mov    0x18(%edi),%edi
80103906:	b9 13 00 00 00       	mov    $0x13,%ecx
8010390b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
8010390d:	89 c7                	mov    %eax,%edi
8010390f:	8b 40 18             	mov    0x18(%eax),%eax
80103912:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103919:	be 00 00 00 00       	mov    $0x0,%esi
8010391e:	eb 53                	jmp    80103973 <priofork+0xd6>
  cprintf("At priofork after allocproc, np->pid = %d, curproc->pid = %d\n", np->pid, curproc->pid);
80103920:	83 ec 04             	sub    $0x4,%esp
80103923:	ff 73 10             	push   0x10(%ebx)
80103926:	ff 70 10             	push   0x10(%eax)
80103929:	68 00 7a 10 80       	push   $0x80107a00
8010392e:	e8 d4 cc ff ff       	call   80100607 <cprintf>
80103933:	83 c4 10             	add    $0x10,%esp
80103936:	eb a2                	jmp    801038da <priofork+0x3d>
    kfree(np->kstack);
80103938:	83 ec 0c             	sub    $0xc,%esp
8010393b:	89 d3                	mov    %edx,%ebx
8010393d:	ff 72 08             	push   0x8(%edx)
80103940:	e8 47 e6 ff ff       	call   80101f8c <kfree>
    np->kstack = 0;
80103945:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
8010394c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103953:	83 c4 10             	add    $0x10,%esp
80103956:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010395b:	e9 9c 00 00 00       	jmp    801039fc <priofork+0x15f>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103960:	83 ec 0c             	sub    $0xc,%esp
80103963:	50                   	push   %eax
80103964:	e8 15 d3 ff ff       	call   80100c7e <filedup>
80103969:	89 44 b7 28          	mov    %eax,0x28(%edi,%esi,4)
8010396d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NOFILE; i++)
80103970:	83 c6 01             	add    $0x1,%esi
80103973:	83 fe 0f             	cmp    $0xf,%esi
80103976:	7f 0a                	jg     80103982 <priofork+0xe5>
    if(curproc->ofile[i])
80103978:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
8010397c:	85 c0                	test   %eax,%eax
8010397e:	75 e0                	jne    80103960 <priofork+0xc3>
80103980:	eb ee                	jmp    80103970 <priofork+0xd3>
  np->cwd = idup(curproc->cwd);
80103982:	83 ec 0c             	sub    $0xc,%esp
80103985:	ff 73 68             	push   0x68(%ebx)
80103988:	e8 b2 db ff ff       	call   8010153f <idup>
8010398d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103990:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103993:	83 c3 6c             	add    $0x6c,%ebx
80103996:	8d 47 6c             	lea    0x6c(%edi),%eax
80103999:	83 c4 0c             	add    $0xc,%esp
8010399c:	6a 10                	push   $0x10
8010399e:	53                   	push   %ebx
8010399f:	50                   	push   %eax
801039a0:	e8 31 0e 00 00       	call   801047d6 <safestrcpy>
  pid = np->pid;
801039a5:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
801039a8:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
801039af:	e8 0a 0c 00 00       	call   801045be <acquire>
  np->default_level = default_level;  // set priority level
801039b4:	8b 45 08             	mov    0x8(%ebp),%eax
801039b7:	89 87 80 00 00 00    	mov    %eax,0x80(%edi)
  np->state = RUNNABLE;
801039bd:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  if (schedlog_active)
801039c4:	83 c4 10             	add    $0x10,%esp
801039c7:	83 3d 44 2d 11 80 00 	cmpl   $0x0,0x80112d44
801039ce:	75 36                	jne    80103a06 <priofork+0x169>
  struct level_queue *q = find_available_queue(np->default_level, np->default_level);
801039d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801039d3:	8b 87 80 00 00 00    	mov    0x80(%edi),%eax
801039d9:	83 ec 08             	sub    $0x8,%esp
801039dc:	50                   	push   %eax
801039dd:	50                   	push   %eax
801039de:	e8 fb fc ff ff       	call   801036de <find_available_queue>
801039e3:	83 c4 08             	add    $0x8,%esp
  enqueue_proc(np, q);
801039e6:	50                   	push   %eax
801039e7:	57                   	push   %edi
801039e8:	e8 a0 fa ff ff       	call   8010348d <enqueue_proc>
  release(&ptable.lock);
801039ed:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
801039f4:	e8 2a 0c 00 00       	call   80104623 <release>
  return pid;
801039f9:	83 c4 10             	add    $0x10,%esp
}
801039fc:	89 d8                	mov    %ebx,%eax
801039fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103a01:	5b                   	pop    %ebx
80103a02:	5e                   	pop    %esi
80103a03:	5f                   	pop    %edi
80103a04:	5d                   	pop    %ebp
80103a05:	c3                   	ret    
  cprintf("Enqueue np->pid = %d to its default_level = %d\n", np->pid, np->default_level);
80103a06:	83 ec 04             	sub    $0x4,%esp
80103a09:	50                   	push   %eax
80103a0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103a0d:	ff 70 10             	push   0x10(%eax)
80103a10:	68 40 7a 10 80       	push   $0x80107a40
80103a15:	e8 ed cb ff ff       	call   80100607 <cprintf>
80103a1a:	83 c4 10             	add    $0x10,%esp
80103a1d:	eb b1                	jmp    801039d0 <priofork+0x133>
    return -1;
80103a1f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103a24:	eb d6                	jmp    801039fc <priofork+0x15f>
    return -1;
80103a26:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103a2b:	eb cf                	jmp    801039fc <priofork+0x15f>
    return -1;
80103a2d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103a32:	eb c8                	jmp    801039fc <priofork+0x15f>

80103a34 <fork>:
{
80103a34:	55                   	push   %ebp
80103a35:	89 e5                	mov    %esp,%ebp
80103a37:	83 ec 14             	sub    $0x14,%esp
  return priofork(RSDL_STARTING_LEVEL);
80103a3a:	6a 00                	push   $0x0
80103a3c:	e8 5c fe ff ff       	call   8010389d <priofork>
}
80103a41:	c9                   	leave  
80103a42:	c3                   	ret    

80103a43 <scheduler>:
{
80103a43:	55                   	push   %ebp
80103a44:	89 e5                	mov    %esp,%ebp
80103a46:	57                   	push   %edi
80103a47:	56                   	push   %esi
80103a48:	53                   	push   %ebx
80103a49:	83 ec 1c             	sub    $0x1c,%esp
  struct cpu *c = mycpu();
80103a4c:	e8 a2 f9 ff ff       	call   801033f3 <mycpu>
80103a51:	89 45 dc             	mov    %eax,-0x24(%ebp)
  c->proc = 0;
80103a54:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103a5b:	00 00 00 
  struct level_queue *q = NULL;
80103a5e:	bf 00 00 00 00       	mov    $0x0,%edi
  struct proc *p = NULL;
80103a63:	bb 00 00 00 00       	mov    $0x0,%ebx
80103a68:	e9 a9 03 00 00       	jmp    80103e16 <scheduler+0x3d3>
      for (i = 0; i < q->numproc; ++i ) {
80103a6d:	83 c0 01             	add    $0x1,%eax
80103a70:	39 47 34             	cmp    %eax,0x34(%edi)
80103a73:	7e 17                	jle    80103a8c <scheduler+0x49>
        p = q->proc[i];
80103a75:	8b 5c 87 3c          	mov    0x3c(%edi,%eax,4),%ebx
        if(p->state == RUNNABLE && p->ticks_left > 0) {
80103a79:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103a7d:	75 ee                	jne    80103a6d <scheduler+0x2a>
80103a7f:	83 7b 7c 00          	cmpl   $0x0,0x7c(%ebx)
80103a83:	7e e8                	jle    80103a6d <scheduler+0x2a>
          found = 1;
80103a85:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
      release(&q->lock);
80103a8c:	83 ec 0c             	sub    $0xc,%esp
80103a8f:	ff 75 e0             	push   -0x20(%ebp)
80103a92:	e8 8c 0b 00 00       	call   80104623 <release>
      if (found) {
80103a97:	83 c4 10             	add    $0x10,%esp
80103a9a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80103a9e:	75 30                	jne    80103ad0 <scheduler+0x8d>
    for (k = 0; k < RSDL_LEVELS; ++k) {
80103aa0:	83 c6 01             	add    $0x1,%esi
80103aa3:	83 fe 04             	cmp    $0x4,%esi
80103aa6:	7f 35                	jg     80103add <scheduler+0x9a>
      q = &ptable.active[k];
80103aa8:	69 fe 3c 01 00 00    	imul   $0x13c,%esi,%edi
80103aae:	03 3d 94 4e 11 80    	add    0x80114e94,%edi
      if (q->ticks_left <= 0)
80103ab4:	83 7f 38 00          	cmpl   $0x0,0x38(%edi)
80103ab8:	7e e6                	jle    80103aa0 <scheduler+0x5d>
      acquire(&q->lock);
80103aba:	89 7d e0             	mov    %edi,-0x20(%ebp)
80103abd:	83 ec 0c             	sub    $0xc,%esp
80103ac0:	57                   	push   %edi
80103ac1:	e8 f8 0a 00 00       	call   801045be <acquire>
      for (i = 0; i < q->numproc; ++i ) {
80103ac6:	83 c4 10             	add    $0x10,%esp
80103ac9:	b8 00 00 00 00       	mov    $0x0,%eax
80103ace:	eb a0                	jmp    80103a70 <scheduler+0x2d>
        if (schedlog_active) cprintf("%d|Scheduled PID %d in level %d\n", ticks, p->pid, k);
80103ad0:	83 3d 44 2d 11 80 00 	cmpl   $0x0,0x80112d44
80103ad7:	0f 85 ce 00 00 00    	jne    80103bab <scheduler+0x168>
    if (schedlog_active && ticks > schedlog_lasttick) {
80103add:	83 3d 44 2d 11 80 00 	cmpl   $0x0,0x80112d44
80103ae4:	74 11                	je     80103af7 <scheduler+0xb4>
80103ae6:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80103aeb:	39 05 00 5b 11 80    	cmp    %eax,0x80115b00
80103af1:	0f 87 d0 00 00 00    	ja     80103bc7 <scheduler+0x184>
    if (found) {
80103af7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80103afb:	0f 84 62 03 00 00    	je     80103e63 <scheduler+0x420>
      c->proc = p;
80103b01:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103b04:	89 98 ac 00 00 00    	mov    %ebx,0xac(%eax)
      c->queue = q;
80103b0a:	89 b8 b0 00 00 00    	mov    %edi,0xb0(%eax)
      switchuvm(p);
80103b10:	83 ec 0c             	sub    $0xc,%esp
80103b13:	53                   	push   %ebx
80103b14:	e8 0f 2f 00 00       	call   80106a28 <switchuvm>
      p->state = RUNNING;
80103b19:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      if (schedlog_active && ticks <= schedlog_lasttick) {
80103b20:	83 c4 10             	add    $0x10,%esp
80103b23:	83 3d 44 2d 11 80 00 	cmpl   $0x0,0x80112d44
80103b2a:	74 11                	je     80103b3d <scheduler+0xfa>
80103b2c:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80103b31:	39 05 00 5b 11 80    	cmp    %eax,0x80115b00
80103b37:	0f 86 a9 00 00 00    	jbe    80103be6 <scheduler+0x1a3>
      swtch(&(c->scheduler), p->context);
80103b3d:	83 ec 08             	sub    $0x8,%esp
80103b40:	ff 73 1c             	push   0x1c(%ebx)
80103b43:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103b46:	83 c0 04             	add    $0x4,%eax
80103b49:	50                   	push   %eax
80103b4a:	e8 dc 0c 00 00       	call   8010482b <swtch>
      if (schedlog_active) cprintf("%d|PID %d returned from swtch, select next!\n", ticks, p->pid);
80103b4f:	83 c4 10             	add    $0x10,%esp
80103b52:	83 3d 44 2d 11 80 00 	cmpl   $0x0,0x80112d44
80103b59:	0f 85 a1 00 00 00    	jne    80103c00 <scheduler+0x1bd>
      switchkvm();
80103b5f:	e8 9f 2e 00 00       	call   80106a03 <switchkvm>
      if (q->ticks_left <= 0) {
80103b64:	83 7f 38 00          	cmpl   $0x0,0x38(%edi)
80103b68:	0f 8e b0 00 00 00    	jle    80103c1e <scheduler+0x1db>
        if (p->ticks_left <= 0) {
80103b6e:	83 7b 7c 00          	cmpl   $0x0,0x7c(%ebx)
80103b72:	0f 8e 04 02 00 00    	jle    80103d7c <scheduler+0x339>
          if (schedlog_active  && p->state != ZOMBIE) cprintf("%d|Curproc (PID %d) still have quantum, enqueue to same lvl %d\n", ticks, p->pid, k);
80103b78:	83 3d 44 2d 11 80 00 	cmpl   $0x0,0x80112d44
80103b7f:	0f 84 14 02 00 00    	je     80103d99 <scheduler+0x356>
80103b85:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103b89:	0f 84 0a 02 00 00    	je     80103d99 <scheduler+0x356>
80103b8f:	56                   	push   %esi
80103b90:	ff 73 10             	push   0x10(%ebx)
80103b93:	ff 35 00 5b 11 80    	push   0x80115b00
80103b99:	68 a0 7b 10 80       	push   $0x80107ba0
80103b9e:	e8 64 ca ff ff       	call   80100607 <cprintf>
80103ba3:	83 c4 10             	add    $0x10,%esp
80103ba6:	e9 ee 01 00 00       	jmp    80103d99 <scheduler+0x356>
        if (schedlog_active) cprintf("%d|Scheduled PID %d in level %d\n", ticks, p->pid, k);
80103bab:	56                   	push   %esi
80103bac:	ff 73 10             	push   0x10(%ebx)
80103baf:	ff 35 00 5b 11 80    	push   0x80115b00
80103bb5:	68 70 7a 10 80       	push   $0x80107a70
80103bba:	e8 48 ca ff ff       	call   80100607 <cprintf>
80103bbf:	83 c4 10             	add    $0x10,%esp
80103bc2:	e9 16 ff ff ff       	jmp    80103add <scheduler+0x9a>
        schedlog_active = 0;
80103bc7:	c7 05 44 2d 11 80 00 	movl   $0x0,0x80112d44
80103bce:	00 00 00 
        cprintf("DEACTIVATE schedlog\n");
80103bd1:	83 ec 0c             	sub    $0xc,%esp
80103bd4:	68 7d 78 10 80       	push   $0x8010787d
80103bd9:	e8 29 ca ff ff       	call   80100607 <cprintf>
80103bde:	83 c4 10             	add    $0x10,%esp
80103be1:	e9 11 ff ff ff       	jmp    80103af7 <scheduler+0xb4>
        print_schedlog();
80103be6:	e8 1d f6 ff ff       	call   80103208 <print_schedlog>
        cprintf("-----\n");
80103beb:	83 ec 0c             	sub    $0xc,%esp
80103bee:	68 92 78 10 80       	push   $0x80107892
80103bf3:	e8 0f ca ff ff       	call   80100607 <cprintf>
80103bf8:	83 c4 10             	add    $0x10,%esp
80103bfb:	e9 3d ff ff ff       	jmp    80103b3d <scheduler+0xfa>
      if (schedlog_active) cprintf("%d|PID %d returned from swtch, select next!\n", ticks, p->pid);
80103c00:	83 ec 04             	sub    $0x4,%esp
80103c03:	ff 73 10             	push   0x10(%ebx)
80103c06:	ff 35 00 5b 11 80    	push   0x80115b00
80103c0c:	68 94 7a 10 80       	push   $0x80107a94
80103c11:	e8 f1 c9 ff ff       	call   80100607 <cprintf>
80103c16:	83 c4 10             	add    $0x10,%esp
80103c19:	e9 41 ff ff ff       	jmp    80103b5f <scheduler+0x11c>
        if (schedlog_active) cprintf("%d|Level %d quantum depleted\n", ticks, k);
80103c1e:	83 3d 44 2d 11 80 00 	cmpl   $0x0,0x80112d44
80103c25:	75 05                	jne    80103c2c <scheduler+0x1e9>
80103c27:	89 75 e0             	mov    %esi,-0x20(%ebp)
80103c2a:	eb 5a                	jmp    80103c86 <scheduler+0x243>
80103c2c:	83 ec 04             	sub    $0x4,%esp
80103c2f:	56                   	push   %esi
80103c30:	ff 35 00 5b 11 80    	push   0x80115b00
80103c36:	68 99 78 10 80       	push   $0x80107899
80103c3b:	e8 c7 c9 ff ff       	call   80100607 <cprintf>
80103c40:	83 c4 10             	add    $0x10,%esp
80103c43:	89 75 e0             	mov    %esi,-0x20(%ebp)
80103c46:	eb 3e                	jmp    80103c86 <scheduler+0x243>
              cprintf("%d|Move PID %d from level %d to active level %d\n", ticks, np->pid, k, nq-ptable.active);
80103c48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c4b:	2b 05 94 4e 11 80    	sub    0x80114e94,%eax
80103c51:	83 ec 0c             	sub    $0xc,%esp
80103c54:	c1 f8 02             	sar    $0x2,%eax
80103c57:	69 c0 af 16 37 61    	imul   $0x613716af,%eax,%eax
80103c5d:	50                   	push   %eax
80103c5e:	ff 75 e0             	push   -0x20(%ebp)
80103c61:	ff 76 10             	push   0x10(%esi)
80103c64:	ff 35 00 5b 11 80    	push   0x80115b00
80103c6a:	68 c4 7a 10 80       	push   $0x80107ac4
80103c6f:	e8 93 c9 ff ff       	call   80100607 <cprintf>
80103c74:	83 c4 20             	add    $0x20,%esp
          enqueue_proc(np, nq);
80103c77:	83 ec 08             	sub    $0x8,%esp
80103c7a:	ff 75 e4             	push   -0x1c(%ebp)
80103c7d:	56                   	push   %esi
80103c7e:	e8 0a f8 ff ff       	call   8010348d <enqueue_proc>
80103c83:	83 c4 10             	add    $0x10,%esp
        while (q->numproc > 0) {
80103c86:	83 7f 34 00          	cmpl   $0x0,0x34(%edi)
80103c8a:	0f 8e 99 00 00 00    	jle    80103d29 <scheduler+0x2e6>
          np = q->proc[0];
80103c90:	8b 77 3c             	mov    0x3c(%edi),%esi
          np->ticks_left = RSDL_PROC_QUANTUM;
80103c93:	c7 46 7c 14 00 00 00 	movl   $0x14,0x7c(%esi)
          unqueue_proc(np, q);
80103c9a:	83 ec 08             	sub    $0x8,%esp
80103c9d:	57                   	push   %edi
80103c9e:	56                   	push   %esi
80103c9f:	e8 1a f9 ff ff       	call   801035be <unqueue_proc>
          if (np == p) {
80103ca4:	83 c4 10             	add    $0x10,%esp
80103ca7:	39 f3                	cmp    %esi,%ebx
80103ca9:	74 db                	je     80103c86 <scheduler+0x243>
          nq = find_available_queue(k+1, np->default_level);
80103cab:	83 ec 08             	sub    $0x8,%esp
80103cae:	ff b6 80 00 00 00    	push   0x80(%esi)
80103cb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103cb7:	83 c0 01             	add    $0x1,%eax
80103cba:	50                   	push   %eax
80103cbb:	e8 1e fa ff ff       	call   801036de <find_available_queue>
80103cc0:	83 c4 10             	add    $0x10,%esp
80103cc3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          if (schedlog_active) {
80103cc6:	83 3d 44 2d 11 80 00 	cmpl   $0x0,0x80112d44
80103ccd:	74 a8                	je     80103c77 <scheduler+0x234>
            if (is_active_set(nq)) {
80103ccf:	83 ec 0c             	sub    $0xc,%esp
80103cd2:	50                   	push   %eax
80103cd3:	e8 cc f4 ff ff       	call   801031a4 <is_active_set>
80103cd8:	83 c4 10             	add    $0x10,%esp
80103cdb:	85 c0                	test   %eax,%eax
80103cdd:	0f 85 65 ff ff ff    	jne    80103c48 <scheduler+0x205>
            } else if (is_expired_set(nq)) {
80103ce3:	83 ec 0c             	sub    $0xc,%esp
80103ce6:	ff 75 e4             	push   -0x1c(%ebp)
80103ce9:	e8 e3 f4 ff ff       	call   801031d1 <is_expired_set>
80103cee:	83 c4 10             	add    $0x10,%esp
80103cf1:	85 c0                	test   %eax,%eax
80103cf3:	74 82                	je     80103c77 <scheduler+0x234>
              cprintf("%d|Move PID %d from level %d to expired level %d\n", ticks, np->pid, k, nq-ptable.expired);
80103cf5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cf8:	2b 05 98 4e 11 80    	sub    0x80114e98,%eax
80103cfe:	83 ec 0c             	sub    $0xc,%esp
80103d01:	c1 f8 02             	sar    $0x2,%eax
80103d04:	69 c0 af 16 37 61    	imul   $0x613716af,%eax,%eax
80103d0a:	50                   	push   %eax
80103d0b:	ff 75 e0             	push   -0x20(%ebp)
80103d0e:	ff 76 10             	push   0x10(%esi)
80103d11:	ff 35 00 5b 11 80    	push   0x80115b00
80103d17:	68 f8 7a 10 80       	push   $0x80107af8
80103d1c:	e8 e6 c8 ff ff       	call   80100607 <cprintf>
80103d21:	83 c4 20             	add    $0x20,%esp
80103d24:	e9 4e ff ff ff       	jmp    80103c77 <scheduler+0x234>
        if (p->state != ZOMBIE) {
80103d29:	8b 75 e0             	mov    -0x20(%ebp),%esi
80103d2c:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103d30:	0f 84 b9 00 00 00    	je     80103def <scheduler+0x3ac>
          if (schedlog_active) cprintf("%d|Move curproc PID %d from level %d to lower level\n", ticks, p->pid, k);
80103d36:	83 3d 44 2d 11 80 00 	cmpl   $0x0,0x80112d44
80103d3d:	75 24                	jne    80103d63 <scheduler+0x320>
          nq = find_available_queue(k+1, p->default_level);
80103d3f:	83 ec 08             	sub    $0x8,%esp
80103d42:	ff b3 80 00 00 00    	push   0x80(%ebx)
80103d48:	8d 46 01             	lea    0x1(%esi),%eax
80103d4b:	50                   	push   %eax
80103d4c:	e8 8d f9 ff ff       	call   801036de <find_available_queue>
80103d51:	83 c4 08             	add    $0x8,%esp
          enqueue_proc(p, nq);
80103d54:	50                   	push   %eax
80103d55:	53                   	push   %ebx
80103d56:	e8 32 f7 ff ff       	call   8010348d <enqueue_proc>
80103d5b:	83 c4 10             	add    $0x10,%esp
80103d5e:	e9 8c 00 00 00       	jmp    80103def <scheduler+0x3ac>
          if (schedlog_active) cprintf("%d|Move curproc PID %d from level %d to lower level\n", ticks, p->pid, k);
80103d63:	56                   	push   %esi
80103d64:	ff 73 10             	push   0x10(%ebx)
80103d67:	ff 35 00 5b 11 80    	push   0x80115b00
80103d6d:	68 2c 7b 10 80       	push   $0x80107b2c
80103d72:	e8 90 c8 ff ff       	call   80100607 <cprintf>
80103d77:	83 c4 10             	add    $0x10,%esp
80103d7a:	eb c3                	jmp    80103d3f <scheduler+0x2fc>
          if (schedlog_active  && p->state != ZOMBIE) cprintf("%d|Curproc (PID %d) used up quantum, enqueue to lower lvl\n", ticks, p->pid);
80103d7c:	83 3d 44 2d 11 80 00 	cmpl   $0x0,0x80112d44
80103d83:	74 0a                	je     80103d8f <scheduler+0x34c>
80103d85:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103d89:	0f 85 a9 00 00 00    	jne    80103e38 <scheduler+0x3f5>
          p->ticks_left = RSDL_PROC_QUANTUM;
80103d8f:	c7 43 7c 14 00 00 00 	movl   $0x14,0x7c(%ebx)
          nk = k + 1;
80103d96:	83 c6 01             	add    $0x1,%esi
        if (q->numproc > 0 && p->state != ZOMBIE) {
80103d99:	83 7f 34 00          	cmpl   $0x0,0x34(%edi)
80103d9d:	7e 50                	jle    80103def <scheduler+0x3ac>
80103d9f:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103da3:	74 4a                	je     80103def <scheduler+0x3ac>
          prev_idx = unqueue_proc(p, q);
80103da5:	83 ec 08             	sub    $0x8,%esp
80103da8:	57                   	push   %edi
80103da9:	53                   	push   %ebx
80103daa:	e8 0f f8 ff ff       	call   801035be <unqueue_proc>
          if (prev_idx == -1) {
80103daf:	83 c4 10             	add    $0x10,%esp
80103db2:	83 f8 ff             	cmp    $0xffffffff,%eax
80103db5:	0f 84 9b 00 00 00    	je     80103e56 <scheduler+0x413>
          nq = find_available_queue(nk, p->default_level);
80103dbb:	83 ec 08             	sub    $0x8,%esp
80103dbe:	ff b3 80 00 00 00    	push   0x80(%ebx)
80103dc4:	56                   	push   %esi
80103dc5:	e8 14 f9 ff ff       	call   801036de <find_available_queue>
80103dca:	89 c6                	mov    %eax,%esi
          if (is_expired_set(nq)) {
80103dcc:	89 04 24             	mov    %eax,(%esp)
80103dcf:	e8 fd f3 ff ff       	call   801031d1 <is_expired_set>
80103dd4:	83 c4 10             	add    $0x10,%esp
80103dd7:	85 c0                	test   %eax,%eax
80103dd9:	74 07                	je     80103de2 <scheduler+0x39f>
            p->ticks_left = RSDL_PROC_QUANTUM;
80103ddb:	c7 43 7c 14 00 00 00 	movl   $0x14,0x7c(%ebx)
          enqueue_proc(p, nq);
80103de2:	83 ec 08             	sub    $0x8,%esp
80103de5:	56                   	push   %esi
80103de6:	53                   	push   %ebx
80103de7:	e8 a1 f6 ff ff       	call   8010348d <enqueue_proc>
80103dec:	83 c4 10             	add    $0x10,%esp
      c->proc = 0;
80103def:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103df2:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103df9:	00 00 00 
      c->queue = NULL;
80103dfc:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80103e03:	00 00 00 
    release(&ptable.lock);
80103e06:	83 ec 0c             	sub    $0xc,%esp
80103e09:	68 60 2d 11 80       	push   $0x80112d60
80103e0e:	e8 10 08 00 00       	call   80104623 <release>
  for(;;){
80103e13:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103e16:	fb                   	sti    
    acquire(&ptable.lock);
80103e17:	83 ec 0c             	sub    $0xc,%esp
80103e1a:	68 60 2d 11 80       	push   $0x80112d60
80103e1f:	e8 9a 07 00 00       	call   801045be <acquire>
    for (k = 0; k < RSDL_LEVELS; ++k) {
80103e24:	83 c4 10             	add    $0x10,%esp
    int found = 0;
80103e27:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    for (k = 0; k < RSDL_LEVELS; ++k) {
80103e2e:	be 00 00 00 00       	mov    $0x0,%esi
80103e33:	e9 6b fc ff ff       	jmp    80103aa3 <scheduler+0x60>
          if (schedlog_active  && p->state != ZOMBIE) cprintf("%d|Curproc (PID %d) used up quantum, enqueue to lower lvl\n", ticks, p->pid);
80103e38:	83 ec 04             	sub    $0x4,%esp
80103e3b:	ff 73 10             	push   0x10(%ebx)
80103e3e:	ff 35 00 5b 11 80    	push   0x80115b00
80103e44:	68 64 7b 10 80       	push   $0x80107b64
80103e49:	e8 b9 c7 ff ff       	call   80100607 <cprintf>
80103e4e:	83 c4 10             	add    $0x10,%esp
80103e51:	e9 39 ff ff ff       	jmp    80103d8f <scheduler+0x34c>
            panic("re-enqueue of proc failed");
80103e56:	83 ec 0c             	sub    $0xc,%esp
80103e59:	68 b7 78 10 80       	push   $0x801078b7
80103e5e:	e8 e5 c4 ff ff       	call   80100348 <panic>
      if (schedlog_active) {
80103e63:	83 3d 44 2d 11 80 00 	cmpl   $0x0,0x80112d44
80103e6a:	75 1b                	jne    80103e87 <scheduler+0x444>
      nq = ptable.active;
80103e6c:	a1 94 4e 11 80       	mov    0x80114e94,%eax
      ptable.active = ptable.expired;
80103e71:	8b 15 98 4e 11 80    	mov    0x80114e98,%edx
80103e77:	89 15 94 4e 11 80    	mov    %edx,0x80114e94
      ptable.expired = nq;
80103e7d:	a3 98 4e 11 80       	mov    %eax,0x80114e98
      for (k = 0; k < RSDL_LEVELS; ++k) {
80103e82:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80103e85:	eb 52                	jmp    80103ed9 <scheduler+0x496>
        cprintf("%d|No RUNNABLE proc found, SWAP SETS!\n", ticks);
80103e87:	83 ec 08             	sub    $0x8,%esp
80103e8a:	ff 35 00 5b 11 80    	push   0x80115b00
80103e90:	68 e0 7b 10 80       	push   $0x80107be0
80103e95:	e8 6d c7 ff ff       	call   80100607 <cprintf>
80103e9a:	83 c4 10             	add    $0x10,%esp
80103e9d:	eb cd                	jmp    80103e6c <scheduler+0x429>
          p = q->proc[0];
80103e9f:	8b 5f 3c             	mov    0x3c(%edi),%ebx
          p->ticks_left = RSDL_PROC_QUANTUM;
80103ea2:	c7 43 7c 14 00 00 00 	movl   $0x14,0x7c(%ebx)
          unqueue_proc(p, q);
80103ea9:	83 ec 08             	sub    $0x8,%esp
80103eac:	57                   	push   %edi
80103ead:	53                   	push   %ebx
80103eae:	e8 0b f7 ff ff       	call   801035be <unqueue_proc>
          nk = p->default_level;
80103eb3:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
          nq = find_available_queue(nk, nk);
80103eb9:	83 c4 08             	add    $0x8,%esp
80103ebc:	50                   	push   %eax
80103ebd:	50                   	push   %eax
80103ebe:	e8 1b f8 ff ff       	call   801036de <find_available_queue>
80103ec3:	83 c4 08             	add    $0x8,%esp
          enqueue_proc(p, nq);
80103ec6:	50                   	push   %eax
80103ec7:	53                   	push   %ebx
80103ec8:	e8 c0 f5 ff ff       	call   8010348d <enqueue_proc>
80103ecd:	83 c4 10             	add    $0x10,%esp
        while (q->numproc > 0) {
80103ed0:	83 7f 34 00          	cmpl   $0x0,0x34(%edi)
80103ed4:	7f c9                	jg     80103e9f <scheduler+0x45c>
      for (k = 0; k < RSDL_LEVELS; ++k) {
80103ed6:	83 c6 01             	add    $0x1,%esi
80103ed9:	83 fe 04             	cmp    $0x4,%esi
80103edc:	0f 8f 24 ff ff ff    	jg     80103e06 <scheduler+0x3c3>
        q = &ptable.expired[k];
80103ee2:	69 fe 3c 01 00 00    	imul   $0x13c,%esi,%edi
80103ee8:	03 3d 98 4e 11 80    	add    0x80114e98,%edi
        q->ticks_left = RSDL_LEVEL_QUANTUM; // replenish level-local quantum
80103eee:	c7 47 38 37 00 00 00 	movl   $0x37,0x38(%edi)
        while (q->numproc > 0) {
80103ef5:	eb d9                	jmp    80103ed0 <scheduler+0x48d>

80103ef7 <sched>:
{
80103ef7:	55                   	push   %ebp
80103ef8:	89 e5                	mov    %esp,%ebp
80103efa:	56                   	push   %esi
80103efb:	53                   	push   %ebx
  struct proc *p = myproc();
80103efc:	e8 69 f5 ff ff       	call   8010346a <myproc>
80103f01:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
80103f03:	83 ec 0c             	sub    $0xc,%esp
80103f06:	68 60 2d 11 80       	push   $0x80112d60
80103f0b:	e8 6f 06 00 00       	call   8010457f <holding>
80103f10:	83 c4 10             	add    $0x10,%esp
80103f13:	85 c0                	test   %eax,%eax
80103f15:	74 4f                	je     80103f66 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103f17:	e8 d7 f4 ff ff       	call   801033f3 <mycpu>
80103f1c:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103f23:	75 4e                	jne    80103f73 <sched+0x7c>
  if(p->state == RUNNING)
80103f25:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103f29:	74 55                	je     80103f80 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103f2b:	9c                   	pushf  
80103f2c:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103f2d:	f6 c4 02             	test   $0x2,%ah
80103f30:	75 5b                	jne    80103f8d <sched+0x96>
  intena = mycpu()->intena;
80103f32:	e8 bc f4 ff ff       	call   801033f3 <mycpu>
80103f37:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103f3d:	e8 b1 f4 ff ff       	call   801033f3 <mycpu>
80103f42:	83 ec 08             	sub    $0x8,%esp
80103f45:	ff 70 04             	push   0x4(%eax)
80103f48:	83 c3 1c             	add    $0x1c,%ebx
80103f4b:	53                   	push   %ebx
80103f4c:	e8 da 08 00 00       	call   8010482b <swtch>
  mycpu()->intena = intena;
80103f51:	e8 9d f4 ff ff       	call   801033f3 <mycpu>
80103f56:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103f5c:	83 c4 10             	add    $0x10,%esp
80103f5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103f62:	5b                   	pop    %ebx
80103f63:	5e                   	pop    %esi
80103f64:	5d                   	pop    %ebp
80103f65:	c3                   	ret    
    panic("sched ptable.lock");
80103f66:	83 ec 0c             	sub    $0xc,%esp
80103f69:	68 d1 78 10 80       	push   $0x801078d1
80103f6e:	e8 d5 c3 ff ff       	call   80100348 <panic>
    panic("sched locks");
80103f73:	83 ec 0c             	sub    $0xc,%esp
80103f76:	68 e3 78 10 80       	push   $0x801078e3
80103f7b:	e8 c8 c3 ff ff       	call   80100348 <panic>
    panic("sched running");
80103f80:	83 ec 0c             	sub    $0xc,%esp
80103f83:	68 ef 78 10 80       	push   $0x801078ef
80103f88:	e8 bb c3 ff ff       	call   80100348 <panic>
    panic("sched interruptible");
80103f8d:	83 ec 0c             	sub    $0xc,%esp
80103f90:	68 fd 78 10 80       	push   $0x801078fd
80103f95:	e8 ae c3 ff ff       	call   80100348 <panic>

80103f9a <exit>:
{
80103f9a:	55                   	push   %ebp
80103f9b:	89 e5                	mov    %esp,%ebp
80103f9d:	56                   	push   %esi
80103f9e:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103f9f:	e8 c6 f4 ff ff       	call   8010346a <myproc>
  if(curproc == initproc)
80103fa4:	39 05 f4 5a 11 80    	cmp    %eax,0x80115af4
80103faa:	74 09                	je     80103fb5 <exit+0x1b>
80103fac:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
80103fae:	bb 00 00 00 00       	mov    $0x0,%ebx
80103fb3:	eb 24                	jmp    80103fd9 <exit+0x3f>
    panic("init exiting");
80103fb5:	83 ec 0c             	sub    $0xc,%esp
80103fb8:	68 11 79 10 80       	push   $0x80107911
80103fbd:	e8 86 c3 ff ff       	call   80100348 <panic>
      fileclose(curproc->ofile[fd]);
80103fc2:	83 ec 0c             	sub    $0xc,%esp
80103fc5:	50                   	push   %eax
80103fc6:	e8 f8 cc ff ff       	call   80100cc3 <fileclose>
      curproc->ofile[fd] = 0;
80103fcb:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103fd2:	00 
80103fd3:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80103fd6:	83 c3 01             	add    $0x1,%ebx
80103fd9:	83 fb 0f             	cmp    $0xf,%ebx
80103fdc:	7f 0a                	jg     80103fe8 <exit+0x4e>
    if(curproc->ofile[fd]){
80103fde:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103fe2:	85 c0                	test   %eax,%eax
80103fe4:	75 dc                	jne    80103fc2 <exit+0x28>
80103fe6:	eb ee                	jmp    80103fd6 <exit+0x3c>
  begin_op();
80103fe8:	e8 c3 e7 ff ff       	call   801027b0 <begin_op>
  iput(curproc->cwd);
80103fed:	83 ec 0c             	sub    $0xc,%esp
80103ff0:	ff 76 68             	push   0x68(%esi)
80103ff3:	e8 7e d6 ff ff       	call   80101676 <iput>
  end_op();
80103ff8:	e8 2d e8 ff ff       	call   8010282a <end_op>
  curproc->cwd = 0;
80103ffd:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80104004:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
8010400b:	e8 ae 05 00 00       	call   801045be <acquire>
  wakeup1(curproc->parent);
80104010:	8b 46 14             	mov    0x14(%esi),%eax
80104013:	e8 49 f0 ff ff       	call   80103061 <wakeup1>
  for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
80104018:	83 c4 10             	add    $0x10,%esp
8010401b:	bb 94 2d 11 80       	mov    $0x80112d94,%ebx
80104020:	eb 06                	jmp    80104028 <exit+0x8e>
80104022:	81 c3 84 00 00 00    	add    $0x84,%ebx
80104028:	81 fb 94 4e 11 80    	cmp    $0x80114e94,%ebx
8010402e:	73 1a                	jae    8010404a <exit+0xb0>
    if(p->parent == curproc){
80104030:	39 73 14             	cmp    %esi,0x14(%ebx)
80104033:	75 ed                	jne    80104022 <exit+0x88>
      p->parent = initproc;
80104035:	a1 f4 5a 11 80       	mov    0x80115af4,%eax
8010403a:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
8010403d:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80104041:	75 df                	jne    80104022 <exit+0x88>
        wakeup1(initproc);
80104043:	e8 19 f0 ff ff       	call   80103061 <wakeup1>
80104048:	eb d8                	jmp    80104022 <exit+0x88>
  if (schedlog_active) cprintf("PID %d exited, removing from active set\n", curproc->pid);
8010404a:	83 3d 44 2d 11 80 00 	cmpl   $0x0,0x80112d44
80104051:	75 21                	jne    80104074 <exit+0xda>
  remove_proc_from_levels(curproc);
80104053:	83 ec 0c             	sub    $0xc,%esp
80104056:	56                   	push   %esi
80104057:	e8 8c f5 ff ff       	call   801035e8 <remove_proc_from_levels>
  curproc->state = ZOMBIE;
8010405c:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80104063:	e8 8f fe ff ff       	call   80103ef7 <sched>
  panic("zombie exit");
80104068:	c7 04 24 1e 79 10 80 	movl   $0x8010791e,(%esp)
8010406f:	e8 d4 c2 ff ff       	call   80100348 <panic>
  if (schedlog_active) cprintf("PID %d exited, removing from active set\n", curproc->pid);
80104074:	83 ec 08             	sub    $0x8,%esp
80104077:	ff 76 10             	push   0x10(%esi)
8010407a:	68 08 7c 10 80       	push   $0x80107c08
8010407f:	e8 83 c5 ff ff       	call   80100607 <cprintf>
80104084:	83 c4 10             	add    $0x10,%esp
80104087:	eb ca                	jmp    80104053 <exit+0xb9>

80104089 <yield>:
{
80104089:	55                   	push   %ebp
8010408a:	89 e5                	mov    %esp,%ebp
8010408c:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010408f:	68 60 2d 11 80       	push   $0x80112d60
80104094:	e8 25 05 00 00       	call   801045be <acquire>
  myproc()->state = RUNNABLE;
80104099:	e8 cc f3 ff ff       	call   8010346a <myproc>
8010409e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801040a5:	e8 4d fe ff ff       	call   80103ef7 <sched>
  release(&ptable.lock);
801040aa:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
801040b1:	e8 6d 05 00 00       	call   80104623 <release>
}
801040b6:	83 c4 10             	add    $0x10,%esp
801040b9:	c9                   	leave  
801040ba:	c3                   	ret    

801040bb <sleep>:
{
801040bb:	55                   	push   %ebp
801040bc:	89 e5                	mov    %esp,%ebp
801040be:	56                   	push   %esi
801040bf:	53                   	push   %ebx
801040c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p = myproc();
801040c3:	e8 a2 f3 ff ff       	call   8010346a <myproc>
  if(p == 0)
801040c8:	85 c0                	test   %eax,%eax
801040ca:	74 66                	je     80104132 <sleep+0x77>
801040cc:	89 c3                	mov    %eax,%ebx
  if(lk == 0)
801040ce:	85 f6                	test   %esi,%esi
801040d0:	74 6d                	je     8010413f <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801040d2:	81 fe 60 2d 11 80    	cmp    $0x80112d60,%esi
801040d8:	74 18                	je     801040f2 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
801040da:	83 ec 0c             	sub    $0xc,%esp
801040dd:	68 60 2d 11 80       	push   $0x80112d60
801040e2:	e8 d7 04 00 00       	call   801045be <acquire>
    release(lk);
801040e7:	89 34 24             	mov    %esi,(%esp)
801040ea:	e8 34 05 00 00       	call   80104623 <release>
801040ef:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
801040f2:	8b 45 08             	mov    0x8(%ebp),%eax
801040f5:	89 43 20             	mov    %eax,0x20(%ebx)
  p->state = SLEEPING;
801040f8:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
801040ff:	e8 f3 fd ff ff       	call   80103ef7 <sched>
  p->chan = 0;
80104104:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010410b:	81 fe 60 2d 11 80    	cmp    $0x80112d60,%esi
80104111:	74 18                	je     8010412b <sleep+0x70>
    release(&ptable.lock);
80104113:	83 ec 0c             	sub    $0xc,%esp
80104116:	68 60 2d 11 80       	push   $0x80112d60
8010411b:	e8 03 05 00 00       	call   80104623 <release>
    acquire(lk);
80104120:	89 34 24             	mov    %esi,(%esp)
80104123:	e8 96 04 00 00       	call   801045be <acquire>
80104128:	83 c4 10             	add    $0x10,%esp
}
8010412b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010412e:	5b                   	pop    %ebx
8010412f:	5e                   	pop    %esi
80104130:	5d                   	pop    %ebp
80104131:	c3                   	ret    
    panic("sleep");
80104132:	83 ec 0c             	sub    $0xc,%esp
80104135:	68 2a 79 10 80       	push   $0x8010792a
8010413a:	e8 09 c2 ff ff       	call   80100348 <panic>
    panic("sleep without lk");
8010413f:	83 ec 0c             	sub    $0xc,%esp
80104142:	68 30 79 10 80       	push   $0x80107930
80104147:	e8 fc c1 ff ff       	call   80100348 <panic>

8010414c <wait>:
{
8010414c:	55                   	push   %ebp
8010414d:	89 e5                	mov    %esp,%ebp
8010414f:	56                   	push   %esi
80104150:	53                   	push   %ebx
  struct proc *curproc = myproc();
80104151:	e8 14 f3 ff ff       	call   8010346a <myproc>
80104156:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80104158:	83 ec 0c             	sub    $0xc,%esp
8010415b:	68 60 2d 11 80       	push   $0x80112d60
80104160:	e8 59 04 00 00       	call   801045be <acquire>
80104165:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104168:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
8010416d:	bb 94 2d 11 80       	mov    $0x80112d94,%ebx
80104172:	eb 5e                	jmp    801041d2 <wait+0x86>
        pid = p->pid;
80104174:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80104177:	83 ec 0c             	sub    $0xc,%esp
8010417a:	ff 73 08             	push   0x8(%ebx)
8010417d:	e8 0a de ff ff       	call   80101f8c <kfree>
        p->kstack = 0;
80104182:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80104189:	83 c4 04             	add    $0x4,%esp
8010418c:	ff 73 04             	push   0x4(%ebx)
8010418f:	e8 e0 2c 00 00       	call   80106e74 <freevm>
        p->pid = 0;
80104194:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
8010419b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801041a2:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801041a6:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801041ad:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
801041b4:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
801041bb:	e8 63 04 00 00       	call   80104623 <release>
        return pid;
801041c0:	83 c4 10             	add    $0x10,%esp
}
801041c3:	89 f0                	mov    %esi,%eax
801041c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041c8:	5b                   	pop    %ebx
801041c9:	5e                   	pop    %esi
801041ca:	5d                   	pop    %ebp
801041cb:	c3                   	ret    
    for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
801041cc:	81 c3 84 00 00 00    	add    $0x84,%ebx
801041d2:	81 fb 94 4e 11 80    	cmp    $0x80114e94,%ebx
801041d8:	73 12                	jae    801041ec <wait+0xa0>
      if(p->parent != curproc)
801041da:	39 73 14             	cmp    %esi,0x14(%ebx)
801041dd:	75 ed                	jne    801041cc <wait+0x80>
      if(p->state == ZOMBIE){
801041df:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801041e3:	74 8f                	je     80104174 <wait+0x28>
      havekids = 1;
801041e5:	b8 01 00 00 00       	mov    $0x1,%eax
801041ea:	eb e0                	jmp    801041cc <wait+0x80>
    if(!havekids || curproc->killed){
801041ec:	85 c0                	test   %eax,%eax
801041ee:	74 06                	je     801041f6 <wait+0xaa>
801041f0:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
801041f4:	74 17                	je     8010420d <wait+0xc1>
      release(&ptable.lock);
801041f6:	83 ec 0c             	sub    $0xc,%esp
801041f9:	68 60 2d 11 80       	push   $0x80112d60
801041fe:	e8 20 04 00 00       	call   80104623 <release>
      return -1;
80104203:	83 c4 10             	add    $0x10,%esp
80104206:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010420b:	eb b6                	jmp    801041c3 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010420d:	83 ec 08             	sub    $0x8,%esp
80104210:	68 60 2d 11 80       	push   $0x80112d60
80104215:	56                   	push   %esi
80104216:	e8 a0 fe ff ff       	call   801040bb <sleep>
    havekids = 0;
8010421b:	83 c4 10             	add    $0x10,%esp
8010421e:	e9 45 ff ff ff       	jmp    80104168 <wait+0x1c>

80104223 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104223:	55                   	push   %ebp
80104224:	89 e5                	mov    %esp,%ebp
80104226:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80104229:	68 60 2d 11 80       	push   $0x80112d60
8010422e:	e8 8b 03 00 00       	call   801045be <acquire>
  wakeup1(chan);
80104233:	8b 45 08             	mov    0x8(%ebp),%eax
80104236:	e8 26 ee ff ff       	call   80103061 <wakeup1>
  release(&ptable.lock);
8010423b:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80104242:	e8 dc 03 00 00       	call   80104623 <release>
}
80104247:	83 c4 10             	add    $0x10,%esp
8010424a:	c9                   	leave  
8010424b:	c3                   	ret    

8010424c <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010424c:	55                   	push   %ebp
8010424d:	89 e5                	mov    %esp,%ebp
8010424f:	53                   	push   %ebx
80104250:	83 ec 10             	sub    $0x10,%esp
80104253:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80104256:	68 60 2d 11 80       	push   $0x80112d60
8010425b:	e8 5e 03 00 00       	call   801045be <acquire>
  for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
80104260:	83 c4 10             	add    $0x10,%esp
80104263:	b8 94 2d 11 80       	mov    $0x80112d94,%eax
80104268:	eb 0e                	jmp    80104278 <kill+0x2c>
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
8010426a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80104271:	eb 1e                	jmp    80104291 <kill+0x45>
  for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
80104273:	05 84 00 00 00       	add    $0x84,%eax
80104278:	3d 94 4e 11 80       	cmp    $0x80114e94,%eax
8010427d:	73 2c                	jae    801042ab <kill+0x5f>
    if(p->pid == pid){
8010427f:	39 58 10             	cmp    %ebx,0x10(%eax)
80104282:	75 ef                	jne    80104273 <kill+0x27>
      p->killed = 1;
80104284:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      if(p->state == SLEEPING)
8010428b:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
8010428f:	74 d9                	je     8010426a <kill+0x1e>
      release(&ptable.lock);
80104291:	83 ec 0c             	sub    $0xc,%esp
80104294:	68 60 2d 11 80       	push   $0x80112d60
80104299:	e8 85 03 00 00       	call   80104623 <release>
      return 0;
8010429e:	83 c4 10             	add    $0x10,%esp
801042a1:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801042a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042a9:	c9                   	leave  
801042aa:	c3                   	ret    
  release(&ptable.lock);
801042ab:	83 ec 0c             	sub    $0xc,%esp
801042ae:	68 60 2d 11 80       	push   $0x80112d60
801042b3:	e8 6b 03 00 00       	call   80104623 <release>
  return -1;
801042b8:	83 c4 10             	add    $0x10,%esp
801042bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042c0:	eb e4                	jmp    801042a6 <kill+0x5a>

801042c2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801042c2:	55                   	push   %ebp
801042c3:	89 e5                	mov    %esp,%ebp
801042c5:	56                   	push   %esi
801042c6:	53                   	push   %ebx
801042c7:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
801042ca:	bb 94 2d 11 80       	mov    $0x80112d94,%ebx
801042cf:	eb 36                	jmp    80104307 <procdump+0x45>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
801042d1:	b8 41 79 10 80       	mov    $0x80107941,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
801042d6:	8d 53 6c             	lea    0x6c(%ebx),%edx
801042d9:	52                   	push   %edx
801042da:	50                   	push   %eax
801042db:	ff 73 10             	push   0x10(%ebx)
801042de:	68 45 79 10 80       	push   $0x80107945
801042e3:	e8 1f c3 ff ff       	call   80100607 <cprintf>
    if(p->state == SLEEPING){
801042e8:	83 c4 10             	add    $0x10,%esp
801042eb:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
801042ef:	74 3c                	je     8010432d <procdump+0x6b>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801042f1:	83 ec 0c             	sub    $0xc,%esp
801042f4:	68 9b 7f 10 80       	push   $0x80107f9b
801042f9:	e8 09 c3 ff ff       	call   80100607 <cprintf>
801042fe:	83 c4 10             	add    $0x10,%esp
  for(p = &ptable.proc[0]; p < &ptable.proc[NPROC]; p++){
80104301:	81 c3 84 00 00 00    	add    $0x84,%ebx
80104307:	81 fb 94 4e 11 80    	cmp    $0x80114e94,%ebx
8010430d:	73 61                	jae    80104370 <procdump+0xae>
    if(p->state == UNUSED)
8010430f:	8b 43 0c             	mov    0xc(%ebx),%eax
80104312:	85 c0                	test   %eax,%eax
80104314:	74 eb                	je     80104301 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104316:	83 f8 05             	cmp    $0x5,%eax
80104319:	77 b6                	ja     801042d1 <procdump+0xf>
8010431b:	8b 04 85 34 7c 10 80 	mov    -0x7fef83cc(,%eax,4),%eax
80104322:	85 c0                	test   %eax,%eax
80104324:	75 b0                	jne    801042d6 <procdump+0x14>
      state = "???";
80104326:	b8 41 79 10 80       	mov    $0x80107941,%eax
8010432b:	eb a9                	jmp    801042d6 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010432d:	8b 43 1c             	mov    0x1c(%ebx),%eax
80104330:	8b 40 0c             	mov    0xc(%eax),%eax
80104333:	83 c0 08             	add    $0x8,%eax
80104336:	83 ec 08             	sub    $0x8,%esp
80104339:	8d 55 d0             	lea    -0x30(%ebp),%edx
8010433c:	52                   	push   %edx
8010433d:	50                   	push   %eax
8010433e:	e8 5a 01 00 00       	call   8010449d <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104343:	83 c4 10             	add    $0x10,%esp
80104346:	be 00 00 00 00       	mov    $0x0,%esi
8010434b:	eb 14                	jmp    80104361 <procdump+0x9f>
        cprintf(" %p", pc[i]);
8010434d:	83 ec 08             	sub    $0x8,%esp
80104350:	50                   	push   %eax
80104351:	68 e1 71 10 80       	push   $0x801071e1
80104356:	e8 ac c2 ff ff       	call   80100607 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
8010435b:	83 c6 01             	add    $0x1,%esi
8010435e:	83 c4 10             	add    $0x10,%esp
80104361:	83 fe 09             	cmp    $0x9,%esi
80104364:	7f 8b                	jg     801042f1 <procdump+0x2f>
80104366:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
8010436a:	85 c0                	test   %eax,%eax
8010436c:	75 df                	jne    8010434d <procdump+0x8b>
8010436e:	eb 81                	jmp    801042f1 <procdump+0x2f>
  }
}
80104370:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104373:	5b                   	pop    %ebx
80104374:	5e                   	pop    %esi
80104375:	5d                   	pop    %ebp
80104376:	c3                   	ret    

80104377 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104377:	55                   	push   %ebp
80104378:	89 e5                	mov    %esp,%ebp
8010437a:	53                   	push   %ebx
8010437b:	83 ec 0c             	sub    $0xc,%esp
8010437e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80104381:	68 4c 7c 10 80       	push   $0x80107c4c
80104386:	8d 43 04             	lea    0x4(%ebx),%eax
80104389:	50                   	push   %eax
8010438a:	e8 f3 00 00 00       	call   80104482 <initlock>
  lk->name = name;
8010438f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104392:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80104395:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010439b:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
801043a2:	83 c4 10             	add    $0x10,%esp
801043a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043a8:	c9                   	leave  
801043a9:	c3                   	ret    

801043aa <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801043aa:	55                   	push   %ebp
801043ab:	89 e5                	mov    %esp,%ebp
801043ad:	56                   	push   %esi
801043ae:	53                   	push   %ebx
801043af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801043b2:	8d 73 04             	lea    0x4(%ebx),%esi
801043b5:	83 ec 0c             	sub    $0xc,%esp
801043b8:	56                   	push   %esi
801043b9:	e8 00 02 00 00       	call   801045be <acquire>
  while (lk->locked) {
801043be:	83 c4 10             	add    $0x10,%esp
801043c1:	eb 0d                	jmp    801043d0 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
801043c3:	83 ec 08             	sub    $0x8,%esp
801043c6:	56                   	push   %esi
801043c7:	53                   	push   %ebx
801043c8:	e8 ee fc ff ff       	call   801040bb <sleep>
801043cd:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801043d0:	83 3b 00             	cmpl   $0x0,(%ebx)
801043d3:	75 ee                	jne    801043c3 <acquiresleep+0x19>
  }
  lk->locked = 1;
801043d5:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
801043db:	e8 8a f0 ff ff       	call   8010346a <myproc>
801043e0:	8b 40 10             	mov    0x10(%eax),%eax
801043e3:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
801043e6:	83 ec 0c             	sub    $0xc,%esp
801043e9:	56                   	push   %esi
801043ea:	e8 34 02 00 00       	call   80104623 <release>
}
801043ef:	83 c4 10             	add    $0x10,%esp
801043f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801043f5:	5b                   	pop    %ebx
801043f6:	5e                   	pop    %esi
801043f7:	5d                   	pop    %ebp
801043f8:	c3                   	ret    

801043f9 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801043f9:	55                   	push   %ebp
801043fa:	89 e5                	mov    %esp,%ebp
801043fc:	56                   	push   %esi
801043fd:	53                   	push   %ebx
801043fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104401:	8d 73 04             	lea    0x4(%ebx),%esi
80104404:	83 ec 0c             	sub    $0xc,%esp
80104407:	56                   	push   %esi
80104408:	e8 b1 01 00 00       	call   801045be <acquire>
  lk->locked = 0;
8010440d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80104413:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
8010441a:	89 1c 24             	mov    %ebx,(%esp)
8010441d:	e8 01 fe ff ff       	call   80104223 <wakeup>
  release(&lk->lk);
80104422:	89 34 24             	mov    %esi,(%esp)
80104425:	e8 f9 01 00 00       	call   80104623 <release>
}
8010442a:	83 c4 10             	add    $0x10,%esp
8010442d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104430:	5b                   	pop    %ebx
80104431:	5e                   	pop    %esi
80104432:	5d                   	pop    %ebp
80104433:	c3                   	ret    

80104434 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104434:	55                   	push   %ebp
80104435:	89 e5                	mov    %esp,%ebp
80104437:	56                   	push   %esi
80104438:	53                   	push   %ebx
80104439:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
8010443c:	8d 73 04             	lea    0x4(%ebx),%esi
8010443f:	83 ec 0c             	sub    $0xc,%esp
80104442:	56                   	push   %esi
80104443:	e8 76 01 00 00       	call   801045be <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80104448:	83 c4 10             	add    $0x10,%esp
8010444b:	83 3b 00             	cmpl   $0x0,(%ebx)
8010444e:	75 17                	jne    80104467 <holdingsleep+0x33>
80104450:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80104455:	83 ec 0c             	sub    $0xc,%esp
80104458:	56                   	push   %esi
80104459:	e8 c5 01 00 00       	call   80104623 <release>
  return r;
}
8010445e:	89 d8                	mov    %ebx,%eax
80104460:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104463:	5b                   	pop    %ebx
80104464:	5e                   	pop    %esi
80104465:	5d                   	pop    %ebp
80104466:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80104467:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
8010446a:	e8 fb ef ff ff       	call   8010346a <myproc>
8010446f:	3b 58 10             	cmp    0x10(%eax),%ebx
80104472:	74 07                	je     8010447b <holdingsleep+0x47>
80104474:	bb 00 00 00 00       	mov    $0x0,%ebx
80104479:	eb da                	jmp    80104455 <holdingsleep+0x21>
8010447b:	bb 01 00 00 00       	mov    $0x1,%ebx
80104480:	eb d3                	jmp    80104455 <holdingsleep+0x21>

80104482 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104482:	55                   	push   %ebp
80104483:	89 e5                	mov    %esp,%ebp
80104485:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80104488:	8b 55 0c             	mov    0xc(%ebp),%edx
8010448b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010448e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104494:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010449b:	5d                   	pop    %ebp
8010449c:	c3                   	ret    

8010449d <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010449d:	55                   	push   %ebp
8010449e:	89 e5                	mov    %esp,%ebp
801044a0:	53                   	push   %ebx
801044a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801044a4:	8b 45 08             	mov    0x8(%ebp),%eax
801044a7:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
801044aa:	b8 00 00 00 00       	mov    $0x0,%eax
801044af:	83 f8 09             	cmp    $0x9,%eax
801044b2:	7f 25                	jg     801044d9 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801044b4:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
801044ba:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
801044c0:	77 17                	ja     801044d9 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
801044c2:	8b 5a 04             	mov    0x4(%edx),%ebx
801044c5:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
801044c8:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
801044ca:	83 c0 01             	add    $0x1,%eax
801044cd:	eb e0                	jmp    801044af <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
801044cf:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
801044d6:	83 c0 01             	add    $0x1,%eax
801044d9:	83 f8 09             	cmp    $0x9,%eax
801044dc:	7e f1                	jle    801044cf <getcallerpcs+0x32>
}
801044de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044e1:	c9                   	leave  
801044e2:	c3                   	ret    

801044e3 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801044e3:	55                   	push   %ebp
801044e4:	89 e5                	mov    %esp,%ebp
801044e6:	53                   	push   %ebx
801044e7:	83 ec 04             	sub    $0x4,%esp
801044ea:	9c                   	pushf  
801044eb:	5b                   	pop    %ebx
  asm volatile("cli");
801044ec:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
801044ed:	e8 01 ef ff ff       	call   801033f3 <mycpu>
801044f2:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
801044f9:	74 11                	je     8010450c <pushcli+0x29>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
801044fb:	e8 f3 ee ff ff       	call   801033f3 <mycpu>
80104500:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80104507:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010450a:	c9                   	leave  
8010450b:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
8010450c:	e8 e2 ee ff ff       	call   801033f3 <mycpu>
80104511:	81 e3 00 02 00 00    	and    $0x200,%ebx
80104517:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
8010451d:	eb dc                	jmp    801044fb <pushcli+0x18>

8010451f <popcli>:

void
popcli(void)
{
8010451f:	55                   	push   %ebp
80104520:	89 e5                	mov    %esp,%ebp
80104522:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104525:	9c                   	pushf  
80104526:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104527:	f6 c4 02             	test   $0x2,%ah
8010452a:	75 28                	jne    80104554 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
8010452c:	e8 c2 ee ff ff       	call   801033f3 <mycpu>
80104531:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80104537:	8d 51 ff             	lea    -0x1(%ecx),%edx
8010453a:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104540:	85 d2                	test   %edx,%edx
80104542:	78 1d                	js     80104561 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104544:	e8 aa ee ff ff       	call   801033f3 <mycpu>
80104549:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80104550:	74 1c                	je     8010456e <popcli+0x4f>
    sti();
}
80104552:	c9                   	leave  
80104553:	c3                   	ret    
    panic("popcli - interruptible");
80104554:	83 ec 0c             	sub    $0xc,%esp
80104557:	68 57 7c 10 80       	push   $0x80107c57
8010455c:	e8 e7 bd ff ff       	call   80100348 <panic>
    panic("popcli");
80104561:	83 ec 0c             	sub    $0xc,%esp
80104564:	68 6e 7c 10 80       	push   $0x80107c6e
80104569:	e8 da bd ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010456e:	e8 80 ee ff ff       	call   801033f3 <mycpu>
80104573:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
8010457a:	74 d6                	je     80104552 <popcli+0x33>
  asm volatile("sti");
8010457c:	fb                   	sti    
}
8010457d:	eb d3                	jmp    80104552 <popcli+0x33>

8010457f <holding>:
{
8010457f:	55                   	push   %ebp
80104580:	89 e5                	mov    %esp,%ebp
80104582:	53                   	push   %ebx
80104583:	83 ec 04             	sub    $0x4,%esp
80104586:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80104589:	e8 55 ff ff ff       	call   801044e3 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010458e:	83 3b 00             	cmpl   $0x0,(%ebx)
80104591:	75 11                	jne    801045a4 <holding+0x25>
80104593:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80104598:	e8 82 ff ff ff       	call   8010451f <popcli>
}
8010459d:	89 d8                	mov    %ebx,%eax
8010459f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801045a2:	c9                   	leave  
801045a3:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
801045a4:	8b 5b 08             	mov    0x8(%ebx),%ebx
801045a7:	e8 47 ee ff ff       	call   801033f3 <mycpu>
801045ac:	39 c3                	cmp    %eax,%ebx
801045ae:	74 07                	je     801045b7 <holding+0x38>
801045b0:	bb 00 00 00 00       	mov    $0x0,%ebx
801045b5:	eb e1                	jmp    80104598 <holding+0x19>
801045b7:	bb 01 00 00 00       	mov    $0x1,%ebx
801045bc:	eb da                	jmp    80104598 <holding+0x19>

801045be <acquire>:
{
801045be:	55                   	push   %ebp
801045bf:	89 e5                	mov    %esp,%ebp
801045c1:	53                   	push   %ebx
801045c2:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801045c5:	e8 19 ff ff ff       	call   801044e3 <pushcli>
  if(holding(lk))
801045ca:	83 ec 0c             	sub    $0xc,%esp
801045cd:	ff 75 08             	push   0x8(%ebp)
801045d0:	e8 aa ff ff ff       	call   8010457f <holding>
801045d5:	83 c4 10             	add    $0x10,%esp
801045d8:	85 c0                	test   %eax,%eax
801045da:	75 3a                	jne    80104616 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
801045dc:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
801045df:	b8 01 00 00 00       	mov    $0x1,%eax
801045e4:	f0 87 02             	lock xchg %eax,(%edx)
801045e7:	85 c0                	test   %eax,%eax
801045e9:	75 f1                	jne    801045dc <acquire+0x1e>
  __sync_synchronize();
801045eb:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
801045f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
801045f3:	e8 fb ed ff ff       	call   801033f3 <mycpu>
801045f8:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801045fb:	8b 45 08             	mov    0x8(%ebp),%eax
801045fe:	83 c0 0c             	add    $0xc,%eax
80104601:	83 ec 08             	sub    $0x8,%esp
80104604:	50                   	push   %eax
80104605:	8d 45 08             	lea    0x8(%ebp),%eax
80104608:	50                   	push   %eax
80104609:	e8 8f fe ff ff       	call   8010449d <getcallerpcs>
}
8010460e:	83 c4 10             	add    $0x10,%esp
80104611:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104614:	c9                   	leave  
80104615:	c3                   	ret    
    panic("acquire");
80104616:	83 ec 0c             	sub    $0xc,%esp
80104619:	68 75 7c 10 80       	push   $0x80107c75
8010461e:	e8 25 bd ff ff       	call   80100348 <panic>

80104623 <release>:
{
80104623:	55                   	push   %ebp
80104624:	89 e5                	mov    %esp,%ebp
80104626:	53                   	push   %ebx
80104627:	83 ec 10             	sub    $0x10,%esp
8010462a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
8010462d:	53                   	push   %ebx
8010462e:	e8 4c ff ff ff       	call   8010457f <holding>
80104633:	83 c4 10             	add    $0x10,%esp
80104636:	85 c0                	test   %eax,%eax
80104638:	74 23                	je     8010465d <release+0x3a>
  lk->pcs[0] = 0;
8010463a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80104641:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80104648:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010464d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80104653:	e8 c7 fe ff ff       	call   8010451f <popcli>
}
80104658:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010465b:	c9                   	leave  
8010465c:	c3                   	ret    
    panic("release");
8010465d:	83 ec 0c             	sub    $0xc,%esp
80104660:	68 7d 7c 10 80       	push   $0x80107c7d
80104665:	e8 de bc ff ff       	call   80100348 <panic>

8010466a <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010466a:	55                   	push   %ebp
8010466b:	89 e5                	mov    %esp,%ebp
8010466d:	57                   	push   %edi
8010466e:	53                   	push   %ebx
8010466f:	8b 55 08             	mov    0x8(%ebp),%edx
80104672:	8b 45 0c             	mov    0xc(%ebp),%eax
80104675:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80104678:	f6 c2 03             	test   $0x3,%dl
8010467b:	75 25                	jne    801046a2 <memset+0x38>
8010467d:	f6 c1 03             	test   $0x3,%cl
80104680:	75 20                	jne    801046a2 <memset+0x38>
    c &= 0xFF;
80104682:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104685:	c1 e9 02             	shr    $0x2,%ecx
80104688:	c1 e0 18             	shl    $0x18,%eax
8010468b:	89 fb                	mov    %edi,%ebx
8010468d:	c1 e3 10             	shl    $0x10,%ebx
80104690:	09 d8                	or     %ebx,%eax
80104692:	89 fb                	mov    %edi,%ebx
80104694:	c1 e3 08             	shl    $0x8,%ebx
80104697:	09 d8                	or     %ebx,%eax
80104699:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
8010469b:	89 d7                	mov    %edx,%edi
8010469d:	fc                   	cld    
8010469e:	f3 ab                	rep stos %eax,%es:(%edi)
}
801046a0:	eb 05                	jmp    801046a7 <memset+0x3d>
  asm volatile("cld; rep stosb" :
801046a2:	89 d7                	mov    %edx,%edi
801046a4:	fc                   	cld    
801046a5:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
801046a7:	89 d0                	mov    %edx,%eax
801046a9:	5b                   	pop    %ebx
801046aa:	5f                   	pop    %edi
801046ab:	5d                   	pop    %ebp
801046ac:	c3                   	ret    

801046ad <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801046ad:	55                   	push   %ebp
801046ae:	89 e5                	mov    %esp,%ebp
801046b0:	56                   	push   %esi
801046b1:	53                   	push   %ebx
801046b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801046b5:	8b 55 0c             	mov    0xc(%ebp),%edx
801046b8:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801046bb:	eb 08                	jmp    801046c5 <memcmp+0x18>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
801046bd:	83 c1 01             	add    $0x1,%ecx
801046c0:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
801046c3:	89 f0                	mov    %esi,%eax
801046c5:	8d 70 ff             	lea    -0x1(%eax),%esi
801046c8:	85 c0                	test   %eax,%eax
801046ca:	74 12                	je     801046de <memcmp+0x31>
    if(*s1 != *s2)
801046cc:	0f b6 01             	movzbl (%ecx),%eax
801046cf:	0f b6 1a             	movzbl (%edx),%ebx
801046d2:	38 d8                	cmp    %bl,%al
801046d4:	74 e7                	je     801046bd <memcmp+0x10>
      return *s1 - *s2;
801046d6:	0f b6 c0             	movzbl %al,%eax
801046d9:	0f b6 db             	movzbl %bl,%ebx
801046dc:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
801046de:	5b                   	pop    %ebx
801046df:	5e                   	pop    %esi
801046e0:	5d                   	pop    %ebp
801046e1:	c3                   	ret    

801046e2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801046e2:	55                   	push   %ebp
801046e3:	89 e5                	mov    %esp,%ebp
801046e5:	56                   	push   %esi
801046e6:	53                   	push   %ebx
801046e7:	8b 75 08             	mov    0x8(%ebp),%esi
801046ea:	8b 55 0c             	mov    0xc(%ebp),%edx
801046ed:	8b 45 10             	mov    0x10(%ebp),%eax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801046f0:	39 f2                	cmp    %esi,%edx
801046f2:	73 3c                	jae    80104730 <memmove+0x4e>
801046f4:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801046f7:	39 f1                	cmp    %esi,%ecx
801046f9:	76 39                	jbe    80104734 <memmove+0x52>
    s += n;
    d += n;
801046fb:	8d 14 06             	lea    (%esi,%eax,1),%edx
    while(n-- > 0)
801046fe:	eb 0d                	jmp    8010470d <memmove+0x2b>
      *--d = *--s;
80104700:	83 e9 01             	sub    $0x1,%ecx
80104703:	83 ea 01             	sub    $0x1,%edx
80104706:	0f b6 01             	movzbl (%ecx),%eax
80104709:	88 02                	mov    %al,(%edx)
    while(n-- > 0)
8010470b:	89 d8                	mov    %ebx,%eax
8010470d:	8d 58 ff             	lea    -0x1(%eax),%ebx
80104710:	85 c0                	test   %eax,%eax
80104712:	75 ec                	jne    80104700 <memmove+0x1e>
80104714:	eb 14                	jmp    8010472a <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104716:	0f b6 02             	movzbl (%edx),%eax
80104719:	88 01                	mov    %al,(%ecx)
8010471b:	8d 49 01             	lea    0x1(%ecx),%ecx
8010471e:	8d 52 01             	lea    0x1(%edx),%edx
    while(n-- > 0)
80104721:	89 d8                	mov    %ebx,%eax
80104723:	8d 58 ff             	lea    -0x1(%eax),%ebx
80104726:	85 c0                	test   %eax,%eax
80104728:	75 ec                	jne    80104716 <memmove+0x34>

  return dst;
}
8010472a:	89 f0                	mov    %esi,%eax
8010472c:	5b                   	pop    %ebx
8010472d:	5e                   	pop    %esi
8010472e:	5d                   	pop    %ebp
8010472f:	c3                   	ret    
80104730:	89 f1                	mov    %esi,%ecx
80104732:	eb ef                	jmp    80104723 <memmove+0x41>
80104734:	89 f1                	mov    %esi,%ecx
80104736:	eb eb                	jmp    80104723 <memmove+0x41>

80104738 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104738:	55                   	push   %ebp
80104739:	89 e5                	mov    %esp,%ebp
8010473b:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010473e:	ff 75 10             	push   0x10(%ebp)
80104741:	ff 75 0c             	push   0xc(%ebp)
80104744:	ff 75 08             	push   0x8(%ebp)
80104747:	e8 96 ff ff ff       	call   801046e2 <memmove>
}
8010474c:	c9                   	leave  
8010474d:	c3                   	ret    

8010474e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010474e:	55                   	push   %ebp
8010474f:	89 e5                	mov    %esp,%ebp
80104751:	53                   	push   %ebx
80104752:	8b 55 08             	mov    0x8(%ebp),%edx
80104755:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104758:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
8010475b:	eb 09                	jmp    80104766 <strncmp+0x18>
    n--, p++, q++;
8010475d:	83 e8 01             	sub    $0x1,%eax
80104760:	83 c2 01             	add    $0x1,%edx
80104763:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104766:	85 c0                	test   %eax,%eax
80104768:	74 0b                	je     80104775 <strncmp+0x27>
8010476a:	0f b6 1a             	movzbl (%edx),%ebx
8010476d:	84 db                	test   %bl,%bl
8010476f:	74 04                	je     80104775 <strncmp+0x27>
80104771:	3a 19                	cmp    (%ecx),%bl
80104773:	74 e8                	je     8010475d <strncmp+0xf>
  if(n == 0)
80104775:	85 c0                	test   %eax,%eax
80104777:	74 0d                	je     80104786 <strncmp+0x38>
    return 0;
  return (uchar)*p - (uchar)*q;
80104779:	0f b6 02             	movzbl (%edx),%eax
8010477c:	0f b6 11             	movzbl (%ecx),%edx
8010477f:	29 d0                	sub    %edx,%eax
}
80104781:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104784:	c9                   	leave  
80104785:	c3                   	ret    
    return 0;
80104786:	b8 00 00 00 00       	mov    $0x0,%eax
8010478b:	eb f4                	jmp    80104781 <strncmp+0x33>

8010478d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010478d:	55                   	push   %ebp
8010478e:	89 e5                	mov    %esp,%ebp
80104790:	57                   	push   %edi
80104791:	56                   	push   %esi
80104792:	53                   	push   %ebx
80104793:	8b 7d 08             	mov    0x8(%ebp),%edi
80104796:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104799:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
8010479c:	89 fa                	mov    %edi,%edx
8010479e:	eb 04                	jmp    801047a4 <strncpy+0x17>
801047a0:	89 f1                	mov    %esi,%ecx
801047a2:	89 da                	mov    %ebx,%edx
801047a4:	89 c3                	mov    %eax,%ebx
801047a6:	83 e8 01             	sub    $0x1,%eax
801047a9:	85 db                	test   %ebx,%ebx
801047ab:	7e 11                	jle    801047be <strncpy+0x31>
801047ad:	8d 71 01             	lea    0x1(%ecx),%esi
801047b0:	8d 5a 01             	lea    0x1(%edx),%ebx
801047b3:	0f b6 09             	movzbl (%ecx),%ecx
801047b6:	88 0a                	mov    %cl,(%edx)
801047b8:	84 c9                	test   %cl,%cl
801047ba:	75 e4                	jne    801047a0 <strncpy+0x13>
801047bc:	89 da                	mov    %ebx,%edx
    ;
  while(n-- > 0)
801047be:	8d 48 ff             	lea    -0x1(%eax),%ecx
801047c1:	85 c0                	test   %eax,%eax
801047c3:	7e 0a                	jle    801047cf <strncpy+0x42>
    *s++ = 0;
801047c5:	c6 02 00             	movb   $0x0,(%edx)
  while(n-- > 0)
801047c8:	89 c8                	mov    %ecx,%eax
    *s++ = 0;
801047ca:	8d 52 01             	lea    0x1(%edx),%edx
801047cd:	eb ef                	jmp    801047be <strncpy+0x31>
  return os;
}
801047cf:	89 f8                	mov    %edi,%eax
801047d1:	5b                   	pop    %ebx
801047d2:	5e                   	pop    %esi
801047d3:	5f                   	pop    %edi
801047d4:	5d                   	pop    %ebp
801047d5:	c3                   	ret    

801047d6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801047d6:	55                   	push   %ebp
801047d7:	89 e5                	mov    %esp,%ebp
801047d9:	57                   	push   %edi
801047da:	56                   	push   %esi
801047db:	53                   	push   %ebx
801047dc:	8b 7d 08             	mov    0x8(%ebp),%edi
801047df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801047e2:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
801047e5:	85 c0                	test   %eax,%eax
801047e7:	7e 23                	jle    8010480c <safestrcpy+0x36>
801047e9:	89 fa                	mov    %edi,%edx
801047eb:	eb 04                	jmp    801047f1 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
801047ed:	89 f1                	mov    %esi,%ecx
801047ef:	89 da                	mov    %ebx,%edx
801047f1:	83 e8 01             	sub    $0x1,%eax
801047f4:	85 c0                	test   %eax,%eax
801047f6:	7e 11                	jle    80104809 <safestrcpy+0x33>
801047f8:	8d 71 01             	lea    0x1(%ecx),%esi
801047fb:	8d 5a 01             	lea    0x1(%edx),%ebx
801047fe:	0f b6 09             	movzbl (%ecx),%ecx
80104801:	88 0a                	mov    %cl,(%edx)
80104803:	84 c9                	test   %cl,%cl
80104805:	75 e6                	jne    801047ed <safestrcpy+0x17>
80104807:	89 da                	mov    %ebx,%edx
    ;
  *s = 0;
80104809:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
8010480c:	89 f8                	mov    %edi,%eax
8010480e:	5b                   	pop    %ebx
8010480f:	5e                   	pop    %esi
80104810:	5f                   	pop    %edi
80104811:	5d                   	pop    %ebp
80104812:	c3                   	ret    

80104813 <strlen>:

int
strlen(const char *s)
{
80104813:	55                   	push   %ebp
80104814:	89 e5                	mov    %esp,%ebp
80104816:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80104819:	b8 00 00 00 00       	mov    $0x0,%eax
8010481e:	eb 03                	jmp    80104823 <strlen+0x10>
80104820:	83 c0 01             	add    $0x1,%eax
80104823:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104827:	75 f7                	jne    80104820 <strlen+0xd>
    ;
  return n;
}
80104829:	5d                   	pop    %ebp
8010482a:	c3                   	ret    

8010482b <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010482b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010482f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104833:	55                   	push   %ebp
  pushl %ebx
80104834:	53                   	push   %ebx
  pushl %esi
80104835:	56                   	push   %esi
  pushl %edi
80104836:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104837:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104839:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010483b:	5f                   	pop    %edi
  popl %esi
8010483c:	5e                   	pop    %esi
  popl %ebx
8010483d:	5b                   	pop    %ebx
  popl %ebp
8010483e:	5d                   	pop    %ebp
  ret
8010483f:	c3                   	ret    

80104840 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104840:	55                   	push   %ebp
80104841:	89 e5                	mov    %esp,%ebp
80104843:	53                   	push   %ebx
80104844:	83 ec 04             	sub    $0x4,%esp
80104847:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
8010484a:	e8 1b ec ff ff       	call   8010346a <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010484f:	8b 00                	mov    (%eax),%eax
80104851:	39 d8                	cmp    %ebx,%eax
80104853:	76 18                	jbe    8010486d <fetchint+0x2d>
80104855:	8d 53 04             	lea    0x4(%ebx),%edx
80104858:	39 d0                	cmp    %edx,%eax
8010485a:	72 18                	jb     80104874 <fetchint+0x34>
    return -1;
  *ip = *(int*)(addr);
8010485c:	8b 13                	mov    (%ebx),%edx
8010485e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104861:	89 10                	mov    %edx,(%eax)
  return 0;
80104863:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104868:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010486b:	c9                   	leave  
8010486c:	c3                   	ret    
    return -1;
8010486d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104872:	eb f4                	jmp    80104868 <fetchint+0x28>
80104874:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104879:	eb ed                	jmp    80104868 <fetchint+0x28>

8010487b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010487b:	55                   	push   %ebp
8010487c:	89 e5                	mov    %esp,%ebp
8010487e:	53                   	push   %ebx
8010487f:	83 ec 04             	sub    $0x4,%esp
80104882:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104885:	e8 e0 eb ff ff       	call   8010346a <myproc>

  if(addr >= curproc->sz)
8010488a:	39 18                	cmp    %ebx,(%eax)
8010488c:	76 25                	jbe    801048b3 <fetchstr+0x38>
    return -1;
  *pp = (char*)addr;
8010488e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104891:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104893:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104895:	89 d8                	mov    %ebx,%eax
80104897:	eb 03                	jmp    8010489c <fetchstr+0x21>
80104899:	83 c0 01             	add    $0x1,%eax
8010489c:	39 d0                	cmp    %edx,%eax
8010489e:	73 09                	jae    801048a9 <fetchstr+0x2e>
    if(*s == 0)
801048a0:	80 38 00             	cmpb   $0x0,(%eax)
801048a3:	75 f4                	jne    80104899 <fetchstr+0x1e>
      return s - *pp;
801048a5:	29 d8                	sub    %ebx,%eax
801048a7:	eb 05                	jmp    801048ae <fetchstr+0x33>
  }
  return -1;
801048a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801048ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048b1:	c9                   	leave  
801048b2:	c3                   	ret    
    return -1;
801048b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048b8:	eb f4                	jmp    801048ae <fetchstr+0x33>

801048ba <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801048ba:	55                   	push   %ebp
801048bb:	89 e5                	mov    %esp,%ebp
801048bd:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801048c0:	e8 a5 eb ff ff       	call   8010346a <myproc>
801048c5:	8b 50 18             	mov    0x18(%eax),%edx
801048c8:	8b 45 08             	mov    0x8(%ebp),%eax
801048cb:	c1 e0 02             	shl    $0x2,%eax
801048ce:	03 42 44             	add    0x44(%edx),%eax
801048d1:	83 ec 08             	sub    $0x8,%esp
801048d4:	ff 75 0c             	push   0xc(%ebp)
801048d7:	83 c0 04             	add    $0x4,%eax
801048da:	50                   	push   %eax
801048db:	e8 60 ff ff ff       	call   80104840 <fetchint>
}
801048e0:	c9                   	leave  
801048e1:	c3                   	ret    

801048e2 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801048e2:	55                   	push   %ebp
801048e3:	89 e5                	mov    %esp,%ebp
801048e5:	56                   	push   %esi
801048e6:	53                   	push   %ebx
801048e7:	83 ec 10             	sub    $0x10,%esp
801048ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
801048ed:	e8 78 eb ff ff       	call   8010346a <myproc>
801048f2:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
801048f4:	83 ec 08             	sub    $0x8,%esp
801048f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801048fa:	50                   	push   %eax
801048fb:	ff 75 08             	push   0x8(%ebp)
801048fe:	e8 b7 ff ff ff       	call   801048ba <argint>
80104903:	83 c4 10             	add    $0x10,%esp
80104906:	85 c0                	test   %eax,%eax
80104908:	78 24                	js     8010492e <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010490a:	85 db                	test   %ebx,%ebx
8010490c:	78 27                	js     80104935 <argptr+0x53>
8010490e:	8b 16                	mov    (%esi),%edx
80104910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104913:	39 c2                	cmp    %eax,%edx
80104915:	76 25                	jbe    8010493c <argptr+0x5a>
80104917:	01 c3                	add    %eax,%ebx
80104919:	39 da                	cmp    %ebx,%edx
8010491b:	72 26                	jb     80104943 <argptr+0x61>
    return -1;
  *pp = (char*)i;
8010491d:	8b 55 0c             	mov    0xc(%ebp),%edx
80104920:	89 02                	mov    %eax,(%edx)
  return 0;
80104922:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104927:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010492a:	5b                   	pop    %ebx
8010492b:	5e                   	pop    %esi
8010492c:	5d                   	pop    %ebp
8010492d:	c3                   	ret    
    return -1;
8010492e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104933:	eb f2                	jmp    80104927 <argptr+0x45>
    return -1;
80104935:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010493a:	eb eb                	jmp    80104927 <argptr+0x45>
8010493c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104941:	eb e4                	jmp    80104927 <argptr+0x45>
80104943:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104948:	eb dd                	jmp    80104927 <argptr+0x45>

8010494a <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010494a:	55                   	push   %ebp
8010494b:	89 e5                	mov    %esp,%ebp
8010494d:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104950:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104953:	50                   	push   %eax
80104954:	ff 75 08             	push   0x8(%ebp)
80104957:	e8 5e ff ff ff       	call   801048ba <argint>
8010495c:	83 c4 10             	add    $0x10,%esp
8010495f:	85 c0                	test   %eax,%eax
80104961:	78 13                	js     80104976 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80104963:	83 ec 08             	sub    $0x8,%esp
80104966:	ff 75 0c             	push   0xc(%ebp)
80104969:	ff 75 f4             	push   -0xc(%ebp)
8010496c:	e8 0a ff ff ff       	call   8010487b <fetchstr>
80104971:	83 c4 10             	add    $0x10,%esp
}
80104974:	c9                   	leave  
80104975:	c3                   	ret    
    return -1;
80104976:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010497b:	eb f7                	jmp    80104974 <argstr+0x2a>

8010497d <syscall>:
[SYS_priofork] sys_priofork,
};

void
syscall(void)
{
8010497d:	55                   	push   %ebp
8010497e:	89 e5                	mov    %esp,%ebp
80104980:	53                   	push   %ebx
80104981:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104984:	e8 e1 ea ff ff       	call   8010346a <myproc>
80104989:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
8010498b:	8b 40 18             	mov    0x18(%eax),%eax
8010498e:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104991:	8d 50 ff             	lea    -0x1(%eax),%edx
80104994:	83 fa 18             	cmp    $0x18,%edx
80104997:	77 17                	ja     801049b0 <syscall+0x33>
80104999:	8b 14 85 c0 7c 10 80 	mov    -0x7fef8340(,%eax,4),%edx
801049a0:	85 d2                	test   %edx,%edx
801049a2:	74 0c                	je     801049b0 <syscall+0x33>
    curproc->tf->eax = syscalls[num]();
801049a4:	ff d2                	call   *%edx
801049a6:	89 c2                	mov    %eax,%edx
801049a8:	8b 43 18             	mov    0x18(%ebx),%eax
801049ab:	89 50 1c             	mov    %edx,0x1c(%eax)
801049ae:	eb 1f                	jmp    801049cf <syscall+0x52>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801049b0:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
801049b3:	50                   	push   %eax
801049b4:	52                   	push   %edx
801049b5:	ff 73 10             	push   0x10(%ebx)
801049b8:	68 85 7c 10 80       	push   $0x80107c85
801049bd:	e8 45 bc ff ff       	call   80100607 <cprintf>
    curproc->tf->eax = -1;
801049c2:	8b 43 18             	mov    0x18(%ebx),%eax
801049c5:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
801049cc:	83 c4 10             	add    $0x10,%esp
  }
}
801049cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049d2:	c9                   	leave  
801049d3:	c3                   	ret    

801049d4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801049d4:	55                   	push   %ebp
801049d5:	89 e5                	mov    %esp,%ebp
801049d7:	56                   	push   %esi
801049d8:	53                   	push   %ebx
801049d9:	83 ec 18             	sub    $0x18,%esp
801049dc:	89 d6                	mov    %edx,%esi
801049de:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801049e0:	8d 55 f4             	lea    -0xc(%ebp),%edx
801049e3:	52                   	push   %edx
801049e4:	50                   	push   %eax
801049e5:	e8 d0 fe ff ff       	call   801048ba <argint>
801049ea:	83 c4 10             	add    $0x10,%esp
801049ed:	85 c0                	test   %eax,%eax
801049ef:	78 35                	js     80104a26 <argfd+0x52>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801049f1:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801049f5:	77 28                	ja     80104a1f <argfd+0x4b>
801049f7:	e8 6e ea ff ff       	call   8010346a <myproc>
801049fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049ff:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104a03:	85 c0                	test   %eax,%eax
80104a05:	74 18                	je     80104a1f <argfd+0x4b>
    return -1;
  if(pfd)
80104a07:	85 f6                	test   %esi,%esi
80104a09:	74 02                	je     80104a0d <argfd+0x39>
    *pfd = fd;
80104a0b:	89 16                	mov    %edx,(%esi)
  if(pf)
80104a0d:	85 db                	test   %ebx,%ebx
80104a0f:	74 1c                	je     80104a2d <argfd+0x59>
    *pf = f;
80104a11:	89 03                	mov    %eax,(%ebx)
  return 0;
80104a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a18:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a1b:	5b                   	pop    %ebx
80104a1c:	5e                   	pop    %esi
80104a1d:	5d                   	pop    %ebp
80104a1e:	c3                   	ret    
    return -1;
80104a1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a24:	eb f2                	jmp    80104a18 <argfd+0x44>
    return -1;
80104a26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a2b:	eb eb                	jmp    80104a18 <argfd+0x44>
  return 0;
80104a2d:	b8 00 00 00 00       	mov    $0x0,%eax
80104a32:	eb e4                	jmp    80104a18 <argfd+0x44>

80104a34 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104a34:	55                   	push   %ebp
80104a35:	89 e5                	mov    %esp,%ebp
80104a37:	53                   	push   %ebx
80104a38:	83 ec 04             	sub    $0x4,%esp
80104a3b:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80104a3d:	e8 28 ea ff ff       	call   8010346a <myproc>
80104a42:	89 c2                	mov    %eax,%edx

  for(fd = 0; fd < NOFILE; fd++){
80104a44:	b8 00 00 00 00       	mov    $0x0,%eax
80104a49:	83 f8 0f             	cmp    $0xf,%eax
80104a4c:	7f 12                	jg     80104a60 <fdalloc+0x2c>
    if(curproc->ofile[fd] == 0){
80104a4e:	83 7c 82 28 00       	cmpl   $0x0,0x28(%edx,%eax,4)
80104a53:	74 05                	je     80104a5a <fdalloc+0x26>
  for(fd = 0; fd < NOFILE; fd++){
80104a55:	83 c0 01             	add    $0x1,%eax
80104a58:	eb ef                	jmp    80104a49 <fdalloc+0x15>
      curproc->ofile[fd] = f;
80104a5a:	89 5c 82 28          	mov    %ebx,0x28(%edx,%eax,4)
      return fd;
80104a5e:	eb 05                	jmp    80104a65 <fdalloc+0x31>
    }
  }
  return -1;
80104a60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104a65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a68:	c9                   	leave  
80104a69:	c3                   	ret    

80104a6a <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80104a6a:	55                   	push   %ebp
80104a6b:	89 e5                	mov    %esp,%ebp
80104a6d:	56                   	push   %esi
80104a6e:	53                   	push   %ebx
80104a6f:	83 ec 10             	sub    $0x10,%esp
80104a72:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104a74:	b8 20 00 00 00       	mov    $0x20,%eax
80104a79:	89 c6                	mov    %eax,%esi
80104a7b:	39 43 58             	cmp    %eax,0x58(%ebx)
80104a7e:	76 2e                	jbe    80104aae <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104a80:	6a 10                	push   $0x10
80104a82:	50                   	push   %eax
80104a83:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104a86:	50                   	push   %eax
80104a87:	53                   	push   %ebx
80104a88:	e8 d4 cc ff ff       	call   80101761 <readi>
80104a8d:	83 c4 10             	add    $0x10,%esp
80104a90:	83 f8 10             	cmp    $0x10,%eax
80104a93:	75 0c                	jne    80104aa1 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104a95:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104a9a:	75 1e                	jne    80104aba <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104a9c:	8d 46 10             	lea    0x10(%esi),%eax
80104a9f:	eb d8                	jmp    80104a79 <isdirempty+0xf>
      panic("isdirempty: readi");
80104aa1:	83 ec 0c             	sub    $0xc,%esp
80104aa4:	68 28 7d 10 80       	push   $0x80107d28
80104aa9:	e8 9a b8 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104aae:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104ab3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104ab6:	5b                   	pop    %ebx
80104ab7:	5e                   	pop    %esi
80104ab8:	5d                   	pop    %ebp
80104ab9:	c3                   	ret    
      return 0;
80104aba:	b8 00 00 00 00       	mov    $0x0,%eax
80104abf:	eb f2                	jmp    80104ab3 <isdirempty+0x49>

80104ac1 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104ac1:	55                   	push   %ebp
80104ac2:	89 e5                	mov    %esp,%ebp
80104ac4:	57                   	push   %edi
80104ac5:	56                   	push   %esi
80104ac6:	53                   	push   %ebx
80104ac7:	83 ec 34             	sub    $0x34,%esp
80104aca:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80104acd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104ad0:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104ad3:	8d 55 da             	lea    -0x26(%ebp),%edx
80104ad6:	52                   	push   %edx
80104ad7:	50                   	push   %eax
80104ad8:	e8 08 d1 ff ff       	call   80101be5 <nameiparent>
80104add:	89 c6                	mov    %eax,%esi
80104adf:	83 c4 10             	add    $0x10,%esp
80104ae2:	85 c0                	test   %eax,%eax
80104ae4:	0f 84 33 01 00 00    	je     80104c1d <create+0x15c>
    return 0;
  ilock(dp);
80104aea:	83 ec 0c             	sub    $0xc,%esp
80104aed:	50                   	push   %eax
80104aee:	e8 7c ca ff ff       	call   8010156f <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104af3:	83 c4 0c             	add    $0xc,%esp
80104af6:	6a 00                	push   $0x0
80104af8:	8d 45 da             	lea    -0x26(%ebp),%eax
80104afb:	50                   	push   %eax
80104afc:	56                   	push   %esi
80104afd:	e8 9d ce ff ff       	call   8010199f <dirlookup>
80104b02:	89 c3                	mov    %eax,%ebx
80104b04:	83 c4 10             	add    $0x10,%esp
80104b07:	85 c0                	test   %eax,%eax
80104b09:	74 3d                	je     80104b48 <create+0x87>
    iunlockput(dp);
80104b0b:	83 ec 0c             	sub    $0xc,%esp
80104b0e:	56                   	push   %esi
80104b0f:	e8 02 cc ff ff       	call   80101716 <iunlockput>
    ilock(ip);
80104b14:	89 1c 24             	mov    %ebx,(%esp)
80104b17:	e8 53 ca ff ff       	call   8010156f <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104b1c:	83 c4 10             	add    $0x10,%esp
80104b1f:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80104b24:	75 07                	jne    80104b2d <create+0x6c>
80104b26:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104b2b:	74 11                	je     80104b3e <create+0x7d>
      return ip;
    iunlockput(ip);
80104b2d:	83 ec 0c             	sub    $0xc,%esp
80104b30:	53                   	push   %ebx
80104b31:	e8 e0 cb ff ff       	call   80101716 <iunlockput>
    return 0;
80104b36:	83 c4 10             	add    $0x10,%esp
80104b39:	bb 00 00 00 00       	mov    $0x0,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104b3e:	89 d8                	mov    %ebx,%eax
80104b40:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104b43:	5b                   	pop    %ebx
80104b44:	5e                   	pop    %esi
80104b45:	5f                   	pop    %edi
80104b46:	5d                   	pop    %ebp
80104b47:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
80104b48:	83 ec 08             	sub    $0x8,%esp
80104b4b:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80104b4f:	50                   	push   %eax
80104b50:	ff 36                	push   (%esi)
80104b52:	e8 15 c8 ff ff       	call   8010136c <ialloc>
80104b57:	89 c3                	mov    %eax,%ebx
80104b59:	83 c4 10             	add    $0x10,%esp
80104b5c:	85 c0                	test   %eax,%eax
80104b5e:	74 52                	je     80104bb2 <create+0xf1>
  ilock(ip);
80104b60:	83 ec 0c             	sub    $0xc,%esp
80104b63:	50                   	push   %eax
80104b64:	e8 06 ca ff ff       	call   8010156f <ilock>
  ip->major = major;
80104b69:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80104b6d:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104b71:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
80104b75:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104b7b:	89 1c 24             	mov    %ebx,(%esp)
80104b7e:	e8 8b c8 ff ff       	call   8010140e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104b83:	83 c4 10             	add    $0x10,%esp
80104b86:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80104b8b:	74 32                	je     80104bbf <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
80104b8d:	83 ec 04             	sub    $0x4,%esp
80104b90:	ff 73 04             	push   0x4(%ebx)
80104b93:	8d 45 da             	lea    -0x26(%ebp),%eax
80104b96:	50                   	push   %eax
80104b97:	56                   	push   %esi
80104b98:	e8 7f cf ff ff       	call   80101b1c <dirlink>
80104b9d:	83 c4 10             	add    $0x10,%esp
80104ba0:	85 c0                	test   %eax,%eax
80104ba2:	78 6c                	js     80104c10 <create+0x14f>
  iunlockput(dp);
80104ba4:	83 ec 0c             	sub    $0xc,%esp
80104ba7:	56                   	push   %esi
80104ba8:	e8 69 cb ff ff       	call   80101716 <iunlockput>
  return ip;
80104bad:	83 c4 10             	add    $0x10,%esp
80104bb0:	eb 8c                	jmp    80104b3e <create+0x7d>
    panic("create: ialloc");
80104bb2:	83 ec 0c             	sub    $0xc,%esp
80104bb5:	68 3a 7d 10 80       	push   $0x80107d3a
80104bba:	e8 89 b7 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104bbf:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104bc3:	83 c0 01             	add    $0x1,%eax
80104bc6:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104bca:	83 ec 0c             	sub    $0xc,%esp
80104bcd:	56                   	push   %esi
80104bce:	e8 3b c8 ff ff       	call   8010140e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104bd3:	83 c4 0c             	add    $0xc,%esp
80104bd6:	ff 73 04             	push   0x4(%ebx)
80104bd9:	68 4a 7d 10 80       	push   $0x80107d4a
80104bde:	53                   	push   %ebx
80104bdf:	e8 38 cf ff ff       	call   80101b1c <dirlink>
80104be4:	83 c4 10             	add    $0x10,%esp
80104be7:	85 c0                	test   %eax,%eax
80104be9:	78 18                	js     80104c03 <create+0x142>
80104beb:	83 ec 04             	sub    $0x4,%esp
80104bee:	ff 76 04             	push   0x4(%esi)
80104bf1:	68 49 7d 10 80       	push   $0x80107d49
80104bf6:	53                   	push   %ebx
80104bf7:	e8 20 cf ff ff       	call   80101b1c <dirlink>
80104bfc:	83 c4 10             	add    $0x10,%esp
80104bff:	85 c0                	test   %eax,%eax
80104c01:	79 8a                	jns    80104b8d <create+0xcc>
      panic("create dots");
80104c03:	83 ec 0c             	sub    $0xc,%esp
80104c06:	68 4c 7d 10 80       	push   $0x80107d4c
80104c0b:	e8 38 b7 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
80104c10:	83 ec 0c             	sub    $0xc,%esp
80104c13:	68 58 7d 10 80       	push   $0x80107d58
80104c18:	e8 2b b7 ff ff       	call   80100348 <panic>
    return 0;
80104c1d:	89 c3                	mov    %eax,%ebx
80104c1f:	e9 1a ff ff ff       	jmp    80104b3e <create+0x7d>

80104c24 <sys_dup>:
{
80104c24:	55                   	push   %ebp
80104c25:	89 e5                	mov    %esp,%ebp
80104c27:	53                   	push   %ebx
80104c28:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
80104c2b:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104c2e:	ba 00 00 00 00       	mov    $0x0,%edx
80104c33:	b8 00 00 00 00       	mov    $0x0,%eax
80104c38:	e8 97 fd ff ff       	call   801049d4 <argfd>
80104c3d:	85 c0                	test   %eax,%eax
80104c3f:	78 23                	js     80104c64 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
80104c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c44:	e8 eb fd ff ff       	call   80104a34 <fdalloc>
80104c49:	89 c3                	mov    %eax,%ebx
80104c4b:	85 c0                	test   %eax,%eax
80104c4d:	78 1c                	js     80104c6b <sys_dup+0x47>
  filedup(f);
80104c4f:	83 ec 0c             	sub    $0xc,%esp
80104c52:	ff 75 f4             	push   -0xc(%ebp)
80104c55:	e8 24 c0 ff ff       	call   80100c7e <filedup>
  return fd;
80104c5a:	83 c4 10             	add    $0x10,%esp
}
80104c5d:	89 d8                	mov    %ebx,%eax
80104c5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c62:	c9                   	leave  
80104c63:	c3                   	ret    
    return -1;
80104c64:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104c69:	eb f2                	jmp    80104c5d <sys_dup+0x39>
    return -1;
80104c6b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104c70:	eb eb                	jmp    80104c5d <sys_dup+0x39>

80104c72 <sys_read>:
{
80104c72:	55                   	push   %ebp
80104c73:	89 e5                	mov    %esp,%ebp
80104c75:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104c78:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104c7b:	ba 00 00 00 00       	mov    $0x0,%edx
80104c80:	b8 00 00 00 00       	mov    $0x0,%eax
80104c85:	e8 4a fd ff ff       	call   801049d4 <argfd>
80104c8a:	85 c0                	test   %eax,%eax
80104c8c:	78 43                	js     80104cd1 <sys_read+0x5f>
80104c8e:	83 ec 08             	sub    $0x8,%esp
80104c91:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104c94:	50                   	push   %eax
80104c95:	6a 02                	push   $0x2
80104c97:	e8 1e fc ff ff       	call   801048ba <argint>
80104c9c:	83 c4 10             	add    $0x10,%esp
80104c9f:	85 c0                	test   %eax,%eax
80104ca1:	78 2e                	js     80104cd1 <sys_read+0x5f>
80104ca3:	83 ec 04             	sub    $0x4,%esp
80104ca6:	ff 75 f0             	push   -0x10(%ebp)
80104ca9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104cac:	50                   	push   %eax
80104cad:	6a 01                	push   $0x1
80104caf:	e8 2e fc ff ff       	call   801048e2 <argptr>
80104cb4:	83 c4 10             	add    $0x10,%esp
80104cb7:	85 c0                	test   %eax,%eax
80104cb9:	78 16                	js     80104cd1 <sys_read+0x5f>
  return fileread(f, p, n);
80104cbb:	83 ec 04             	sub    $0x4,%esp
80104cbe:	ff 75 f0             	push   -0x10(%ebp)
80104cc1:	ff 75 ec             	push   -0x14(%ebp)
80104cc4:	ff 75 f4             	push   -0xc(%ebp)
80104cc7:	e8 04 c1 ff ff       	call   80100dd0 <fileread>
80104ccc:	83 c4 10             	add    $0x10,%esp
}
80104ccf:	c9                   	leave  
80104cd0:	c3                   	ret    
    return -1;
80104cd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cd6:	eb f7                	jmp    80104ccf <sys_read+0x5d>

80104cd8 <sys_write>:
{
80104cd8:	55                   	push   %ebp
80104cd9:	89 e5                	mov    %esp,%ebp
80104cdb:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104cde:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104ce1:	ba 00 00 00 00       	mov    $0x0,%edx
80104ce6:	b8 00 00 00 00       	mov    $0x0,%eax
80104ceb:	e8 e4 fc ff ff       	call   801049d4 <argfd>
80104cf0:	85 c0                	test   %eax,%eax
80104cf2:	78 43                	js     80104d37 <sys_write+0x5f>
80104cf4:	83 ec 08             	sub    $0x8,%esp
80104cf7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104cfa:	50                   	push   %eax
80104cfb:	6a 02                	push   $0x2
80104cfd:	e8 b8 fb ff ff       	call   801048ba <argint>
80104d02:	83 c4 10             	add    $0x10,%esp
80104d05:	85 c0                	test   %eax,%eax
80104d07:	78 2e                	js     80104d37 <sys_write+0x5f>
80104d09:	83 ec 04             	sub    $0x4,%esp
80104d0c:	ff 75 f0             	push   -0x10(%ebp)
80104d0f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104d12:	50                   	push   %eax
80104d13:	6a 01                	push   $0x1
80104d15:	e8 c8 fb ff ff       	call   801048e2 <argptr>
80104d1a:	83 c4 10             	add    $0x10,%esp
80104d1d:	85 c0                	test   %eax,%eax
80104d1f:	78 16                	js     80104d37 <sys_write+0x5f>
  return filewrite(f, p, n);
80104d21:	83 ec 04             	sub    $0x4,%esp
80104d24:	ff 75 f0             	push   -0x10(%ebp)
80104d27:	ff 75 ec             	push   -0x14(%ebp)
80104d2a:	ff 75 f4             	push   -0xc(%ebp)
80104d2d:	e8 23 c1 ff ff       	call   80100e55 <filewrite>
80104d32:	83 c4 10             	add    $0x10,%esp
}
80104d35:	c9                   	leave  
80104d36:	c3                   	ret    
    return -1;
80104d37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d3c:	eb f7                	jmp    80104d35 <sys_write+0x5d>

80104d3e <sys_close>:
{
80104d3e:	55                   	push   %ebp
80104d3f:	89 e5                	mov    %esp,%ebp
80104d41:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104d44:	8d 4d f0             	lea    -0x10(%ebp),%ecx
80104d47:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104d4a:	b8 00 00 00 00       	mov    $0x0,%eax
80104d4f:	e8 80 fc ff ff       	call   801049d4 <argfd>
80104d54:	85 c0                	test   %eax,%eax
80104d56:	78 25                	js     80104d7d <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
80104d58:	e8 0d e7 ff ff       	call   8010346a <myproc>
80104d5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d60:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104d67:	00 
  fileclose(f);
80104d68:	83 ec 0c             	sub    $0xc,%esp
80104d6b:	ff 75 f0             	push   -0x10(%ebp)
80104d6e:	e8 50 bf ff ff       	call   80100cc3 <fileclose>
  return 0;
80104d73:	83 c4 10             	add    $0x10,%esp
80104d76:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d7b:	c9                   	leave  
80104d7c:	c3                   	ret    
    return -1;
80104d7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d82:	eb f7                	jmp    80104d7b <sys_close+0x3d>

80104d84 <sys_fstat>:
{
80104d84:	55                   	push   %ebp
80104d85:	89 e5                	mov    %esp,%ebp
80104d87:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104d8a:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104d8d:	ba 00 00 00 00       	mov    $0x0,%edx
80104d92:	b8 00 00 00 00       	mov    $0x0,%eax
80104d97:	e8 38 fc ff ff       	call   801049d4 <argfd>
80104d9c:	85 c0                	test   %eax,%eax
80104d9e:	78 2a                	js     80104dca <sys_fstat+0x46>
80104da0:	83 ec 04             	sub    $0x4,%esp
80104da3:	6a 14                	push   $0x14
80104da5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104da8:	50                   	push   %eax
80104da9:	6a 01                	push   $0x1
80104dab:	e8 32 fb ff ff       	call   801048e2 <argptr>
80104db0:	83 c4 10             	add    $0x10,%esp
80104db3:	85 c0                	test   %eax,%eax
80104db5:	78 13                	js     80104dca <sys_fstat+0x46>
  return filestat(f, st);
80104db7:	83 ec 08             	sub    $0x8,%esp
80104dba:	ff 75 f0             	push   -0x10(%ebp)
80104dbd:	ff 75 f4             	push   -0xc(%ebp)
80104dc0:	e8 c4 bf ff ff       	call   80100d89 <filestat>
80104dc5:	83 c4 10             	add    $0x10,%esp
}
80104dc8:	c9                   	leave  
80104dc9:	c3                   	ret    
    return -1;
80104dca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dcf:	eb f7                	jmp    80104dc8 <sys_fstat+0x44>

80104dd1 <sys_link>:
{
80104dd1:	55                   	push   %ebp
80104dd2:	89 e5                	mov    %esp,%ebp
80104dd4:	56                   	push   %esi
80104dd5:	53                   	push   %ebx
80104dd6:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104dd9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104ddc:	50                   	push   %eax
80104ddd:	6a 00                	push   $0x0
80104ddf:	e8 66 fb ff ff       	call   8010494a <argstr>
80104de4:	83 c4 10             	add    $0x10,%esp
80104de7:	85 c0                	test   %eax,%eax
80104de9:	0f 88 d3 00 00 00    	js     80104ec2 <sys_link+0xf1>
80104def:	83 ec 08             	sub    $0x8,%esp
80104df2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104df5:	50                   	push   %eax
80104df6:	6a 01                	push   $0x1
80104df8:	e8 4d fb ff ff       	call   8010494a <argstr>
80104dfd:	83 c4 10             	add    $0x10,%esp
80104e00:	85 c0                	test   %eax,%eax
80104e02:	0f 88 ba 00 00 00    	js     80104ec2 <sys_link+0xf1>
  begin_op();
80104e08:	e8 a3 d9 ff ff       	call   801027b0 <begin_op>
  if((ip = namei(old)) == 0){
80104e0d:	83 ec 0c             	sub    $0xc,%esp
80104e10:	ff 75 e0             	push   -0x20(%ebp)
80104e13:	e8 b5 cd ff ff       	call   80101bcd <namei>
80104e18:	89 c3                	mov    %eax,%ebx
80104e1a:	83 c4 10             	add    $0x10,%esp
80104e1d:	85 c0                	test   %eax,%eax
80104e1f:	0f 84 a4 00 00 00    	je     80104ec9 <sys_link+0xf8>
  ilock(ip);
80104e25:	83 ec 0c             	sub    $0xc,%esp
80104e28:	50                   	push   %eax
80104e29:	e8 41 c7 ff ff       	call   8010156f <ilock>
  if(ip->type == T_DIR){
80104e2e:	83 c4 10             	add    $0x10,%esp
80104e31:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104e36:	0f 84 99 00 00 00    	je     80104ed5 <sys_link+0x104>
  ip->nlink++;
80104e3c:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104e40:	83 c0 01             	add    $0x1,%eax
80104e43:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104e47:	83 ec 0c             	sub    $0xc,%esp
80104e4a:	53                   	push   %ebx
80104e4b:	e8 be c5 ff ff       	call   8010140e <iupdate>
  iunlock(ip);
80104e50:	89 1c 24             	mov    %ebx,(%esp)
80104e53:	e8 d9 c7 ff ff       	call   80101631 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104e58:	83 c4 08             	add    $0x8,%esp
80104e5b:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104e5e:	50                   	push   %eax
80104e5f:	ff 75 e4             	push   -0x1c(%ebp)
80104e62:	e8 7e cd ff ff       	call   80101be5 <nameiparent>
80104e67:	89 c6                	mov    %eax,%esi
80104e69:	83 c4 10             	add    $0x10,%esp
80104e6c:	85 c0                	test   %eax,%eax
80104e6e:	0f 84 85 00 00 00    	je     80104ef9 <sys_link+0x128>
  ilock(dp);
80104e74:	83 ec 0c             	sub    $0xc,%esp
80104e77:	50                   	push   %eax
80104e78:	e8 f2 c6 ff ff       	call   8010156f <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104e7d:	83 c4 10             	add    $0x10,%esp
80104e80:	8b 03                	mov    (%ebx),%eax
80104e82:	39 06                	cmp    %eax,(%esi)
80104e84:	75 67                	jne    80104eed <sys_link+0x11c>
80104e86:	83 ec 04             	sub    $0x4,%esp
80104e89:	ff 73 04             	push   0x4(%ebx)
80104e8c:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104e8f:	50                   	push   %eax
80104e90:	56                   	push   %esi
80104e91:	e8 86 cc ff ff       	call   80101b1c <dirlink>
80104e96:	83 c4 10             	add    $0x10,%esp
80104e99:	85 c0                	test   %eax,%eax
80104e9b:	78 50                	js     80104eed <sys_link+0x11c>
  iunlockput(dp);
80104e9d:	83 ec 0c             	sub    $0xc,%esp
80104ea0:	56                   	push   %esi
80104ea1:	e8 70 c8 ff ff       	call   80101716 <iunlockput>
  iput(ip);
80104ea6:	89 1c 24             	mov    %ebx,(%esp)
80104ea9:	e8 c8 c7 ff ff       	call   80101676 <iput>
  end_op();
80104eae:	e8 77 d9 ff ff       	call   8010282a <end_op>
  return 0;
80104eb3:	83 c4 10             	add    $0x10,%esp
80104eb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ebb:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104ebe:	5b                   	pop    %ebx
80104ebf:	5e                   	pop    %esi
80104ec0:	5d                   	pop    %ebp
80104ec1:	c3                   	ret    
    return -1;
80104ec2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ec7:	eb f2                	jmp    80104ebb <sys_link+0xea>
    end_op();
80104ec9:	e8 5c d9 ff ff       	call   8010282a <end_op>
    return -1;
80104ece:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ed3:	eb e6                	jmp    80104ebb <sys_link+0xea>
    iunlockput(ip);
80104ed5:	83 ec 0c             	sub    $0xc,%esp
80104ed8:	53                   	push   %ebx
80104ed9:	e8 38 c8 ff ff       	call   80101716 <iunlockput>
    end_op();
80104ede:	e8 47 d9 ff ff       	call   8010282a <end_op>
    return -1;
80104ee3:	83 c4 10             	add    $0x10,%esp
80104ee6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eeb:	eb ce                	jmp    80104ebb <sys_link+0xea>
    iunlockput(dp);
80104eed:	83 ec 0c             	sub    $0xc,%esp
80104ef0:	56                   	push   %esi
80104ef1:	e8 20 c8 ff ff       	call   80101716 <iunlockput>
    goto bad;
80104ef6:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104ef9:	83 ec 0c             	sub    $0xc,%esp
80104efc:	53                   	push   %ebx
80104efd:	e8 6d c6 ff ff       	call   8010156f <ilock>
  ip->nlink--;
80104f02:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104f06:	83 e8 01             	sub    $0x1,%eax
80104f09:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104f0d:	89 1c 24             	mov    %ebx,(%esp)
80104f10:	e8 f9 c4 ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
80104f15:	89 1c 24             	mov    %ebx,(%esp)
80104f18:	e8 f9 c7 ff ff       	call   80101716 <iunlockput>
  end_op();
80104f1d:	e8 08 d9 ff ff       	call   8010282a <end_op>
  return -1;
80104f22:	83 c4 10             	add    $0x10,%esp
80104f25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f2a:	eb 8f                	jmp    80104ebb <sys_link+0xea>

80104f2c <sys_unlink>:
{
80104f2c:	55                   	push   %ebp
80104f2d:	89 e5                	mov    %esp,%ebp
80104f2f:	57                   	push   %edi
80104f30:	56                   	push   %esi
80104f31:	53                   	push   %ebx
80104f32:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104f35:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104f38:	50                   	push   %eax
80104f39:	6a 00                	push   $0x0
80104f3b:	e8 0a fa ff ff       	call   8010494a <argstr>
80104f40:	83 c4 10             	add    $0x10,%esp
80104f43:	85 c0                	test   %eax,%eax
80104f45:	0f 88 83 01 00 00    	js     801050ce <sys_unlink+0x1a2>
  begin_op();
80104f4b:	e8 60 d8 ff ff       	call   801027b0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104f50:	83 ec 08             	sub    $0x8,%esp
80104f53:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104f56:	50                   	push   %eax
80104f57:	ff 75 c4             	push   -0x3c(%ebp)
80104f5a:	e8 86 cc ff ff       	call   80101be5 <nameiparent>
80104f5f:	89 c6                	mov    %eax,%esi
80104f61:	83 c4 10             	add    $0x10,%esp
80104f64:	85 c0                	test   %eax,%eax
80104f66:	0f 84 ed 00 00 00    	je     80105059 <sys_unlink+0x12d>
  ilock(dp);
80104f6c:	83 ec 0c             	sub    $0xc,%esp
80104f6f:	50                   	push   %eax
80104f70:	e8 fa c5 ff ff       	call   8010156f <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104f75:	83 c4 08             	add    $0x8,%esp
80104f78:	68 4a 7d 10 80       	push   $0x80107d4a
80104f7d:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104f80:	50                   	push   %eax
80104f81:	e8 04 ca ff ff       	call   8010198a <namecmp>
80104f86:	83 c4 10             	add    $0x10,%esp
80104f89:	85 c0                	test   %eax,%eax
80104f8b:	0f 84 fc 00 00 00    	je     8010508d <sys_unlink+0x161>
80104f91:	83 ec 08             	sub    $0x8,%esp
80104f94:	68 49 7d 10 80       	push   $0x80107d49
80104f99:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104f9c:	50                   	push   %eax
80104f9d:	e8 e8 c9 ff ff       	call   8010198a <namecmp>
80104fa2:	83 c4 10             	add    $0x10,%esp
80104fa5:	85 c0                	test   %eax,%eax
80104fa7:	0f 84 e0 00 00 00    	je     8010508d <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104fad:	83 ec 04             	sub    $0x4,%esp
80104fb0:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104fb3:	50                   	push   %eax
80104fb4:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104fb7:	50                   	push   %eax
80104fb8:	56                   	push   %esi
80104fb9:	e8 e1 c9 ff ff       	call   8010199f <dirlookup>
80104fbe:	89 c3                	mov    %eax,%ebx
80104fc0:	83 c4 10             	add    $0x10,%esp
80104fc3:	85 c0                	test   %eax,%eax
80104fc5:	0f 84 c2 00 00 00    	je     8010508d <sys_unlink+0x161>
  ilock(ip);
80104fcb:	83 ec 0c             	sub    $0xc,%esp
80104fce:	50                   	push   %eax
80104fcf:	e8 9b c5 ff ff       	call   8010156f <ilock>
  if(ip->nlink < 1)
80104fd4:	83 c4 10             	add    $0x10,%esp
80104fd7:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104fdc:	0f 8e 83 00 00 00    	jle    80105065 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104fe2:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104fe7:	0f 84 85 00 00 00    	je     80105072 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
80104fed:	83 ec 04             	sub    $0x4,%esp
80104ff0:	6a 10                	push   $0x10
80104ff2:	6a 00                	push   $0x0
80104ff4:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104ff7:	57                   	push   %edi
80104ff8:	e8 6d f6 ff ff       	call   8010466a <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104ffd:	6a 10                	push   $0x10
80104fff:	ff 75 c0             	push   -0x40(%ebp)
80105002:	57                   	push   %edi
80105003:	56                   	push   %esi
80105004:	e8 55 c8 ff ff       	call   8010185e <writei>
80105009:	83 c4 20             	add    $0x20,%esp
8010500c:	83 f8 10             	cmp    $0x10,%eax
8010500f:	0f 85 90 00 00 00    	jne    801050a5 <sys_unlink+0x179>
  if(ip->type == T_DIR){
80105015:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010501a:	0f 84 92 00 00 00    	je     801050b2 <sys_unlink+0x186>
  iunlockput(dp);
80105020:	83 ec 0c             	sub    $0xc,%esp
80105023:	56                   	push   %esi
80105024:	e8 ed c6 ff ff       	call   80101716 <iunlockput>
  ip->nlink--;
80105029:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010502d:	83 e8 01             	sub    $0x1,%eax
80105030:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80105034:	89 1c 24             	mov    %ebx,(%esp)
80105037:	e8 d2 c3 ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
8010503c:	89 1c 24             	mov    %ebx,(%esp)
8010503f:	e8 d2 c6 ff ff       	call   80101716 <iunlockput>
  end_op();
80105044:	e8 e1 d7 ff ff       	call   8010282a <end_op>
  return 0;
80105049:	83 c4 10             	add    $0x10,%esp
8010504c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105051:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105054:	5b                   	pop    %ebx
80105055:	5e                   	pop    %esi
80105056:	5f                   	pop    %edi
80105057:	5d                   	pop    %ebp
80105058:	c3                   	ret    
    end_op();
80105059:	e8 cc d7 ff ff       	call   8010282a <end_op>
    return -1;
8010505e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105063:	eb ec                	jmp    80105051 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80105065:	83 ec 0c             	sub    $0xc,%esp
80105068:	68 68 7d 10 80       	push   $0x80107d68
8010506d:	e8 d6 b2 ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105072:	89 d8                	mov    %ebx,%eax
80105074:	e8 f1 f9 ff ff       	call   80104a6a <isdirempty>
80105079:	85 c0                	test   %eax,%eax
8010507b:	0f 85 6c ff ff ff    	jne    80104fed <sys_unlink+0xc1>
    iunlockput(ip);
80105081:	83 ec 0c             	sub    $0xc,%esp
80105084:	53                   	push   %ebx
80105085:	e8 8c c6 ff ff       	call   80101716 <iunlockput>
    goto bad;
8010508a:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010508d:	83 ec 0c             	sub    $0xc,%esp
80105090:	56                   	push   %esi
80105091:	e8 80 c6 ff ff       	call   80101716 <iunlockput>
  end_op();
80105096:	e8 8f d7 ff ff       	call   8010282a <end_op>
  return -1;
8010509b:	83 c4 10             	add    $0x10,%esp
8010509e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050a3:	eb ac                	jmp    80105051 <sys_unlink+0x125>
    panic("unlink: writei");
801050a5:	83 ec 0c             	sub    $0xc,%esp
801050a8:	68 7a 7d 10 80       	push   $0x80107d7a
801050ad:	e8 96 b2 ff ff       	call   80100348 <panic>
    dp->nlink--;
801050b2:	0f b7 46 56          	movzwl 0x56(%esi),%eax
801050b6:	83 e8 01             	sub    $0x1,%eax
801050b9:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801050bd:	83 ec 0c             	sub    $0xc,%esp
801050c0:	56                   	push   %esi
801050c1:	e8 48 c3 ff ff       	call   8010140e <iupdate>
801050c6:	83 c4 10             	add    $0x10,%esp
801050c9:	e9 52 ff ff ff       	jmp    80105020 <sys_unlink+0xf4>
    return -1;
801050ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050d3:	e9 79 ff ff ff       	jmp    80105051 <sys_unlink+0x125>

801050d8 <sys_open>:

int
sys_open(void)
{
801050d8:	55                   	push   %ebp
801050d9:	89 e5                	mov    %esp,%ebp
801050db:	57                   	push   %edi
801050dc:	56                   	push   %esi
801050dd:	53                   	push   %ebx
801050de:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801050e1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801050e4:	50                   	push   %eax
801050e5:	6a 00                	push   $0x0
801050e7:	e8 5e f8 ff ff       	call   8010494a <argstr>
801050ec:	83 c4 10             	add    $0x10,%esp
801050ef:	85 c0                	test   %eax,%eax
801050f1:	0f 88 a0 00 00 00    	js     80105197 <sys_open+0xbf>
801050f7:	83 ec 08             	sub    $0x8,%esp
801050fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801050fd:	50                   	push   %eax
801050fe:	6a 01                	push   $0x1
80105100:	e8 b5 f7 ff ff       	call   801048ba <argint>
80105105:	83 c4 10             	add    $0x10,%esp
80105108:	85 c0                	test   %eax,%eax
8010510a:	0f 88 87 00 00 00    	js     80105197 <sys_open+0xbf>
    return -1;

  begin_op();
80105110:	e8 9b d6 ff ff       	call   801027b0 <begin_op>

  if(omode & O_CREATE){
80105115:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80105119:	0f 84 8b 00 00 00    	je     801051aa <sys_open+0xd2>
    ip = create(path, T_FILE, 0, 0);
8010511f:	83 ec 0c             	sub    $0xc,%esp
80105122:	6a 00                	push   $0x0
80105124:	b9 00 00 00 00       	mov    $0x0,%ecx
80105129:	ba 02 00 00 00       	mov    $0x2,%edx
8010512e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105131:	e8 8b f9 ff ff       	call   80104ac1 <create>
80105136:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80105138:	83 c4 10             	add    $0x10,%esp
8010513b:	85 c0                	test   %eax,%eax
8010513d:	74 5f                	je     8010519e <sys_open+0xc6>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010513f:	e8 d9 ba ff ff       	call   80100c1d <filealloc>
80105144:	89 c3                	mov    %eax,%ebx
80105146:	85 c0                	test   %eax,%eax
80105148:	0f 84 b5 00 00 00    	je     80105203 <sys_open+0x12b>
8010514e:	e8 e1 f8 ff ff       	call   80104a34 <fdalloc>
80105153:	89 c7                	mov    %eax,%edi
80105155:	85 c0                	test   %eax,%eax
80105157:	0f 88 a6 00 00 00    	js     80105203 <sys_open+0x12b>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010515d:	83 ec 0c             	sub    $0xc,%esp
80105160:	56                   	push   %esi
80105161:	e8 cb c4 ff ff       	call   80101631 <iunlock>
  end_op();
80105166:	e8 bf d6 ff ff       	call   8010282a <end_op>

  f->type = FD_INODE;
8010516b:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80105171:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80105174:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
8010517b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010517e:	83 c4 10             	add    $0x10,%esp
80105181:	a8 01                	test   $0x1,%al
80105183:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105187:	a8 03                	test   $0x3,%al
80105189:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
8010518d:	89 f8                	mov    %edi,%eax
8010518f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105192:	5b                   	pop    %ebx
80105193:	5e                   	pop    %esi
80105194:	5f                   	pop    %edi
80105195:	5d                   	pop    %ebp
80105196:	c3                   	ret    
    return -1;
80105197:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010519c:	eb ef                	jmp    8010518d <sys_open+0xb5>
      end_op();
8010519e:	e8 87 d6 ff ff       	call   8010282a <end_op>
      return -1;
801051a3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801051a8:	eb e3                	jmp    8010518d <sys_open+0xb5>
    if((ip = namei(path)) == 0){
801051aa:	83 ec 0c             	sub    $0xc,%esp
801051ad:	ff 75 e4             	push   -0x1c(%ebp)
801051b0:	e8 18 ca ff ff       	call   80101bcd <namei>
801051b5:	89 c6                	mov    %eax,%esi
801051b7:	83 c4 10             	add    $0x10,%esp
801051ba:	85 c0                	test   %eax,%eax
801051bc:	74 39                	je     801051f7 <sys_open+0x11f>
    ilock(ip);
801051be:	83 ec 0c             	sub    $0xc,%esp
801051c1:	50                   	push   %eax
801051c2:	e8 a8 c3 ff ff       	call   8010156f <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801051c7:	83 c4 10             	add    $0x10,%esp
801051ca:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801051cf:	0f 85 6a ff ff ff    	jne    8010513f <sys_open+0x67>
801051d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801051d9:	0f 84 60 ff ff ff    	je     8010513f <sys_open+0x67>
      iunlockput(ip);
801051df:	83 ec 0c             	sub    $0xc,%esp
801051e2:	56                   	push   %esi
801051e3:	e8 2e c5 ff ff       	call   80101716 <iunlockput>
      end_op();
801051e8:	e8 3d d6 ff ff       	call   8010282a <end_op>
      return -1;
801051ed:	83 c4 10             	add    $0x10,%esp
801051f0:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801051f5:	eb 96                	jmp    8010518d <sys_open+0xb5>
      end_op();
801051f7:	e8 2e d6 ff ff       	call   8010282a <end_op>
      return -1;
801051fc:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80105201:	eb 8a                	jmp    8010518d <sys_open+0xb5>
    if(f)
80105203:	85 db                	test   %ebx,%ebx
80105205:	74 0c                	je     80105213 <sys_open+0x13b>
      fileclose(f);
80105207:	83 ec 0c             	sub    $0xc,%esp
8010520a:	53                   	push   %ebx
8010520b:	e8 b3 ba ff ff       	call   80100cc3 <fileclose>
80105210:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105213:	83 ec 0c             	sub    $0xc,%esp
80105216:	56                   	push   %esi
80105217:	e8 fa c4 ff ff       	call   80101716 <iunlockput>
    end_op();
8010521c:	e8 09 d6 ff ff       	call   8010282a <end_op>
    return -1;
80105221:	83 c4 10             	add    $0x10,%esp
80105224:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80105229:	e9 5f ff ff ff       	jmp    8010518d <sys_open+0xb5>

8010522e <sys_mkdir>:

int
sys_mkdir(void)
{
8010522e:	55                   	push   %ebp
8010522f:	89 e5                	mov    %esp,%ebp
80105231:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105234:	e8 77 d5 ff ff       	call   801027b0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105239:	83 ec 08             	sub    $0x8,%esp
8010523c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010523f:	50                   	push   %eax
80105240:	6a 00                	push   $0x0
80105242:	e8 03 f7 ff ff       	call   8010494a <argstr>
80105247:	83 c4 10             	add    $0x10,%esp
8010524a:	85 c0                	test   %eax,%eax
8010524c:	78 36                	js     80105284 <sys_mkdir+0x56>
8010524e:	83 ec 0c             	sub    $0xc,%esp
80105251:	6a 00                	push   $0x0
80105253:	b9 00 00 00 00       	mov    $0x0,%ecx
80105258:	ba 01 00 00 00       	mov    $0x1,%edx
8010525d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105260:	e8 5c f8 ff ff       	call   80104ac1 <create>
80105265:	83 c4 10             	add    $0x10,%esp
80105268:	85 c0                	test   %eax,%eax
8010526a:	74 18                	je     80105284 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010526c:	83 ec 0c             	sub    $0xc,%esp
8010526f:	50                   	push   %eax
80105270:	e8 a1 c4 ff ff       	call   80101716 <iunlockput>
  end_op();
80105275:	e8 b0 d5 ff ff       	call   8010282a <end_op>
  return 0;
8010527a:	83 c4 10             	add    $0x10,%esp
8010527d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105282:	c9                   	leave  
80105283:	c3                   	ret    
    end_op();
80105284:	e8 a1 d5 ff ff       	call   8010282a <end_op>
    return -1;
80105289:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010528e:	eb f2                	jmp    80105282 <sys_mkdir+0x54>

80105290 <sys_mknod>:

int
sys_mknod(void)
{
80105290:	55                   	push   %ebp
80105291:	89 e5                	mov    %esp,%ebp
80105293:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105296:	e8 15 d5 ff ff       	call   801027b0 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010529b:	83 ec 08             	sub    $0x8,%esp
8010529e:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052a1:	50                   	push   %eax
801052a2:	6a 00                	push   $0x0
801052a4:	e8 a1 f6 ff ff       	call   8010494a <argstr>
801052a9:	83 c4 10             	add    $0x10,%esp
801052ac:	85 c0                	test   %eax,%eax
801052ae:	78 62                	js     80105312 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
801052b0:	83 ec 08             	sub    $0x8,%esp
801052b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052b6:	50                   	push   %eax
801052b7:	6a 01                	push   $0x1
801052b9:	e8 fc f5 ff ff       	call   801048ba <argint>
  if((argstr(0, &path)) < 0 ||
801052be:	83 c4 10             	add    $0x10,%esp
801052c1:	85 c0                	test   %eax,%eax
801052c3:	78 4d                	js     80105312 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
801052c5:	83 ec 08             	sub    $0x8,%esp
801052c8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801052cb:	50                   	push   %eax
801052cc:	6a 02                	push   $0x2
801052ce:	e8 e7 f5 ff ff       	call   801048ba <argint>
     argint(1, &major) < 0 ||
801052d3:	83 c4 10             	add    $0x10,%esp
801052d6:	85 c0                	test   %eax,%eax
801052d8:	78 38                	js     80105312 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
801052da:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
801052de:	83 ec 0c             	sub    $0xc,%esp
801052e1:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
801052e5:	50                   	push   %eax
801052e6:	ba 03 00 00 00       	mov    $0x3,%edx
801052eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ee:	e8 ce f7 ff ff       	call   80104ac1 <create>
     argint(2, &minor) < 0 ||
801052f3:	83 c4 10             	add    $0x10,%esp
801052f6:	85 c0                	test   %eax,%eax
801052f8:	74 18                	je     80105312 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
801052fa:	83 ec 0c             	sub    $0xc,%esp
801052fd:	50                   	push   %eax
801052fe:	e8 13 c4 ff ff       	call   80101716 <iunlockput>
  end_op();
80105303:	e8 22 d5 ff ff       	call   8010282a <end_op>
  return 0;
80105308:	83 c4 10             	add    $0x10,%esp
8010530b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105310:	c9                   	leave  
80105311:	c3                   	ret    
    end_op();
80105312:	e8 13 d5 ff ff       	call   8010282a <end_op>
    return -1;
80105317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010531c:	eb f2                	jmp    80105310 <sys_mknod+0x80>

8010531e <sys_chdir>:

int
sys_chdir(void)
{
8010531e:	55                   	push   %ebp
8010531f:	89 e5                	mov    %esp,%ebp
80105321:	56                   	push   %esi
80105322:	53                   	push   %ebx
80105323:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105326:	e8 3f e1 ff ff       	call   8010346a <myproc>
8010532b:	89 c6                	mov    %eax,%esi
  
  begin_op();
8010532d:	e8 7e d4 ff ff       	call   801027b0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105332:	83 ec 08             	sub    $0x8,%esp
80105335:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105338:	50                   	push   %eax
80105339:	6a 00                	push   $0x0
8010533b:	e8 0a f6 ff ff       	call   8010494a <argstr>
80105340:	83 c4 10             	add    $0x10,%esp
80105343:	85 c0                	test   %eax,%eax
80105345:	78 52                	js     80105399 <sys_chdir+0x7b>
80105347:	83 ec 0c             	sub    $0xc,%esp
8010534a:	ff 75 f4             	push   -0xc(%ebp)
8010534d:	e8 7b c8 ff ff       	call   80101bcd <namei>
80105352:	89 c3                	mov    %eax,%ebx
80105354:	83 c4 10             	add    $0x10,%esp
80105357:	85 c0                	test   %eax,%eax
80105359:	74 3e                	je     80105399 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
8010535b:	83 ec 0c             	sub    $0xc,%esp
8010535e:	50                   	push   %eax
8010535f:	e8 0b c2 ff ff       	call   8010156f <ilock>
  if(ip->type != T_DIR){
80105364:	83 c4 10             	add    $0x10,%esp
80105367:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010536c:	75 37                	jne    801053a5 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010536e:	83 ec 0c             	sub    $0xc,%esp
80105371:	53                   	push   %ebx
80105372:	e8 ba c2 ff ff       	call   80101631 <iunlock>
  iput(curproc->cwd);
80105377:	83 c4 04             	add    $0x4,%esp
8010537a:	ff 76 68             	push   0x68(%esi)
8010537d:	e8 f4 c2 ff ff       	call   80101676 <iput>
  end_op();
80105382:	e8 a3 d4 ff ff       	call   8010282a <end_op>
  curproc->cwd = ip;
80105387:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
8010538a:	83 c4 10             	add    $0x10,%esp
8010538d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105392:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105395:	5b                   	pop    %ebx
80105396:	5e                   	pop    %esi
80105397:	5d                   	pop    %ebp
80105398:	c3                   	ret    
    end_op();
80105399:	e8 8c d4 ff ff       	call   8010282a <end_op>
    return -1;
8010539e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053a3:	eb ed                	jmp    80105392 <sys_chdir+0x74>
    iunlockput(ip);
801053a5:	83 ec 0c             	sub    $0xc,%esp
801053a8:	53                   	push   %ebx
801053a9:	e8 68 c3 ff ff       	call   80101716 <iunlockput>
    end_op();
801053ae:	e8 77 d4 ff ff       	call   8010282a <end_op>
    return -1;
801053b3:	83 c4 10             	add    $0x10,%esp
801053b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053bb:	eb d5                	jmp    80105392 <sys_chdir+0x74>

801053bd <sys_exec>:

int
sys_exec(void)
{
801053bd:	55                   	push   %ebp
801053be:	89 e5                	mov    %esp,%ebp
801053c0:	53                   	push   %ebx
801053c1:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801053c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053ca:	50                   	push   %eax
801053cb:	6a 00                	push   $0x0
801053cd:	e8 78 f5 ff ff       	call   8010494a <argstr>
801053d2:	83 c4 10             	add    $0x10,%esp
801053d5:	85 c0                	test   %eax,%eax
801053d7:	78 38                	js     80105411 <sys_exec+0x54>
801053d9:	83 ec 08             	sub    $0x8,%esp
801053dc:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801053e2:	50                   	push   %eax
801053e3:	6a 01                	push   $0x1
801053e5:	e8 d0 f4 ff ff       	call   801048ba <argint>
801053ea:	83 c4 10             	add    $0x10,%esp
801053ed:	85 c0                	test   %eax,%eax
801053ef:	78 20                	js     80105411 <sys_exec+0x54>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
801053f1:	83 ec 04             	sub    $0x4,%esp
801053f4:	68 80 00 00 00       	push   $0x80
801053f9:	6a 00                	push   $0x0
801053fb:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80105401:	50                   	push   %eax
80105402:	e8 63 f2 ff ff       	call   8010466a <memset>
80105407:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010540a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010540f:	eb 2c                	jmp    8010543d <sys_exec+0x80>
    return -1;
80105411:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105416:	eb 78                	jmp    80105490 <sys_exec+0xd3>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
80105418:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
8010541f:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105423:	83 ec 08             	sub    $0x8,%esp
80105426:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
8010542c:	50                   	push   %eax
8010542d:	ff 75 f4             	push   -0xc(%ebp)
80105430:	e8 99 b4 ff ff       	call   801008ce <exec>
80105435:	83 c4 10             	add    $0x10,%esp
80105438:	eb 56                	jmp    80105490 <sys_exec+0xd3>
  for(i=0;; i++){
8010543a:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
8010543d:	83 fb 1f             	cmp    $0x1f,%ebx
80105440:	77 49                	ja     8010548b <sys_exec+0xce>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105442:	83 ec 08             	sub    $0x8,%esp
80105445:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010544b:	50                   	push   %eax
8010544c:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80105452:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80105455:	50                   	push   %eax
80105456:	e8 e5 f3 ff ff       	call   80104840 <fetchint>
8010545b:	83 c4 10             	add    $0x10,%esp
8010545e:	85 c0                	test   %eax,%eax
80105460:	78 33                	js     80105495 <sys_exec+0xd8>
    if(uarg == 0){
80105462:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105468:	85 c0                	test   %eax,%eax
8010546a:	74 ac                	je     80105418 <sys_exec+0x5b>
    if(fetchstr(uarg, &argv[i]) < 0)
8010546c:	83 ec 08             	sub    $0x8,%esp
8010546f:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80105476:	52                   	push   %edx
80105477:	50                   	push   %eax
80105478:	e8 fe f3 ff ff       	call   8010487b <fetchstr>
8010547d:	83 c4 10             	add    $0x10,%esp
80105480:	85 c0                	test   %eax,%eax
80105482:	79 b6                	jns    8010543a <sys_exec+0x7d>
      return -1;
80105484:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105489:	eb 05                	jmp    80105490 <sys_exec+0xd3>
      return -1;
8010548b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105490:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105493:	c9                   	leave  
80105494:	c3                   	ret    
      return -1;
80105495:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010549a:	eb f4                	jmp    80105490 <sys_exec+0xd3>

8010549c <sys_pipe>:

int
sys_pipe(void)
{
8010549c:	55                   	push   %ebp
8010549d:	89 e5                	mov    %esp,%ebp
8010549f:	53                   	push   %ebx
801054a0:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801054a3:	6a 08                	push   $0x8
801054a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054a8:	50                   	push   %eax
801054a9:	6a 00                	push   $0x0
801054ab:	e8 32 f4 ff ff       	call   801048e2 <argptr>
801054b0:	83 c4 10             	add    $0x10,%esp
801054b3:	85 c0                	test   %eax,%eax
801054b5:	78 79                	js     80105530 <sys_pipe+0x94>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
801054b7:	83 ec 08             	sub    $0x8,%esp
801054ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
801054bd:	50                   	push   %eax
801054be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054c1:	50                   	push   %eax
801054c2:	e8 a5 d8 ff ff       	call   80102d6c <pipealloc>
801054c7:	83 c4 10             	add    $0x10,%esp
801054ca:	85 c0                	test   %eax,%eax
801054cc:	78 69                	js     80105537 <sys_pipe+0x9b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801054ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054d1:	e8 5e f5 ff ff       	call   80104a34 <fdalloc>
801054d6:	89 c3                	mov    %eax,%ebx
801054d8:	85 c0                	test   %eax,%eax
801054da:	78 21                	js     801054fd <sys_pipe+0x61>
801054dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054df:	e8 50 f5 ff ff       	call   80104a34 <fdalloc>
801054e4:	85 c0                	test   %eax,%eax
801054e6:	78 15                	js     801054fd <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
801054e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054eb:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
801054ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054f0:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
801054f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801054fb:	c9                   	leave  
801054fc:	c3                   	ret    
    if(fd0 >= 0)
801054fd:	85 db                	test   %ebx,%ebx
801054ff:	79 20                	jns    80105521 <sys_pipe+0x85>
    fileclose(rf);
80105501:	83 ec 0c             	sub    $0xc,%esp
80105504:	ff 75 f0             	push   -0x10(%ebp)
80105507:	e8 b7 b7 ff ff       	call   80100cc3 <fileclose>
    fileclose(wf);
8010550c:	83 c4 04             	add    $0x4,%esp
8010550f:	ff 75 ec             	push   -0x14(%ebp)
80105512:	e8 ac b7 ff ff       	call   80100cc3 <fileclose>
    return -1;
80105517:	83 c4 10             	add    $0x10,%esp
8010551a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010551f:	eb d7                	jmp    801054f8 <sys_pipe+0x5c>
      myproc()->ofile[fd0] = 0;
80105521:	e8 44 df ff ff       	call   8010346a <myproc>
80105526:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
8010552d:	00 
8010552e:	eb d1                	jmp    80105501 <sys_pipe+0x65>
    return -1;
80105530:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105535:	eb c1                	jmp    801054f8 <sys_pipe+0x5c>
    return -1;
80105537:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010553c:	eb ba                	jmp    801054f8 <sys_pipe+0x5c>

8010553e <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010553e:	55                   	push   %ebp
8010553f:	89 e5                	mov    %esp,%ebp
80105541:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105544:	e8 eb e4 ff ff       	call   80103a34 <fork>
}
80105549:	c9                   	leave  
8010554a:	c3                   	ret    

8010554b <sys_priofork>:

int
sys_priofork(void)
{
8010554b:	55                   	push   %ebp
8010554c:	89 e5                	mov    %esp,%ebp
8010554e:	83 ec 20             	sub    $0x20,%esp
  int default_level;
  if(argint(0, &default_level) < 0)
80105551:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105554:	50                   	push   %eax
80105555:	6a 00                	push   $0x0
80105557:	e8 5e f3 ff ff       	call   801048ba <argint>
8010555c:	83 c4 10             	add    $0x10,%esp
8010555f:	85 c0                	test   %eax,%eax
80105561:	78 10                	js     80105573 <sys_priofork+0x28>
    return -1;
  return priofork(default_level);
80105563:	83 ec 0c             	sub    $0xc,%esp
80105566:	ff 75 f4             	push   -0xc(%ebp)
80105569:	e8 2f e3 ff ff       	call   8010389d <priofork>
8010556e:	83 c4 10             	add    $0x10,%esp
}
80105571:	c9                   	leave  
80105572:	c3                   	ret    
    return -1;
80105573:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105578:	eb f7                	jmp    80105571 <sys_priofork+0x26>

8010557a <sys_exit>:

int
sys_exit(void)
{
8010557a:	55                   	push   %ebp
8010557b:	89 e5                	mov    %esp,%ebp
8010557d:	83 ec 08             	sub    $0x8,%esp
  exit();
80105580:	e8 15 ea ff ff       	call   80103f9a <exit>
  return 0;  // not reached
}
80105585:	b8 00 00 00 00       	mov    $0x0,%eax
8010558a:	c9                   	leave  
8010558b:	c3                   	ret    

8010558c <sys_wait>:

int
sys_wait(void)
{
8010558c:	55                   	push   %ebp
8010558d:	89 e5                	mov    %esp,%ebp
8010558f:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105592:	e8 b5 eb ff ff       	call   8010414c <wait>
}
80105597:	c9                   	leave  
80105598:	c3                   	ret    

80105599 <sys_kill>:

int
sys_kill(void)
{
80105599:	55                   	push   %ebp
8010559a:	89 e5                	mov    %esp,%ebp
8010559c:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010559f:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055a2:	50                   	push   %eax
801055a3:	6a 00                	push   $0x0
801055a5:	e8 10 f3 ff ff       	call   801048ba <argint>
801055aa:	83 c4 10             	add    $0x10,%esp
801055ad:	85 c0                	test   %eax,%eax
801055af:	78 10                	js     801055c1 <sys_kill+0x28>
    return -1;
  return kill(pid);
801055b1:	83 ec 0c             	sub    $0xc,%esp
801055b4:	ff 75 f4             	push   -0xc(%ebp)
801055b7:	e8 90 ec ff ff       	call   8010424c <kill>
801055bc:	83 c4 10             	add    $0x10,%esp
}
801055bf:	c9                   	leave  
801055c0:	c3                   	ret    
    return -1;
801055c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055c6:	eb f7                	jmp    801055bf <sys_kill+0x26>

801055c8 <sys_getpid>:

int
sys_getpid(void)
{
801055c8:	55                   	push   %ebp
801055c9:	89 e5                	mov    %esp,%ebp
801055cb:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801055ce:	e8 97 de ff ff       	call   8010346a <myproc>
801055d3:	8b 40 10             	mov    0x10(%eax),%eax
}
801055d6:	c9                   	leave  
801055d7:	c3                   	ret    

801055d8 <sys_sbrk>:

int
sys_sbrk(void)
{
801055d8:	55                   	push   %ebp
801055d9:	89 e5                	mov    %esp,%ebp
801055db:	53                   	push   %ebx
801055dc:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801055df:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055e2:	50                   	push   %eax
801055e3:	6a 00                	push   $0x0
801055e5:	e8 d0 f2 ff ff       	call   801048ba <argint>
801055ea:	83 c4 10             	add    $0x10,%esp
801055ed:	85 c0                	test   %eax,%eax
801055ef:	78 20                	js     80105611 <sys_sbrk+0x39>
    return -1;
  addr = myproc()->sz;
801055f1:	e8 74 de ff ff       	call   8010346a <myproc>
801055f6:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
801055f8:	83 ec 0c             	sub    $0xc,%esp
801055fb:	ff 75 f4             	push   -0xc(%ebp)
801055fe:	e8 2f e2 ff ff       	call   80103832 <growproc>
80105603:	83 c4 10             	add    $0x10,%esp
80105606:	85 c0                	test   %eax,%eax
80105608:	78 0e                	js     80105618 <sys_sbrk+0x40>
    return -1;
  return addr;
}
8010560a:	89 d8                	mov    %ebx,%eax
8010560c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010560f:	c9                   	leave  
80105610:	c3                   	ret    
    return -1;
80105611:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105616:	eb f2                	jmp    8010560a <sys_sbrk+0x32>
    return -1;
80105618:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010561d:	eb eb                	jmp    8010560a <sys_sbrk+0x32>

8010561f <sys_sleep>:

int
sys_sleep(void)
{
8010561f:	55                   	push   %ebp
80105620:	89 e5                	mov    %esp,%ebp
80105622:	53                   	push   %ebx
80105623:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105626:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105629:	50                   	push   %eax
8010562a:	6a 00                	push   $0x0
8010562c:	e8 89 f2 ff ff       	call   801048ba <argint>
80105631:	83 c4 10             	add    $0x10,%esp
80105634:	85 c0                	test   %eax,%eax
80105636:	78 75                	js     801056ad <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80105638:	83 ec 0c             	sub    $0xc,%esp
8010563b:	68 20 5b 11 80       	push   $0x80115b20
80105640:	e8 79 ef ff ff       	call   801045be <acquire>
  ticks0 = ticks;
80105645:	8b 1d 00 5b 11 80    	mov    0x80115b00,%ebx
  while(ticks - ticks0 < n){
8010564b:	83 c4 10             	add    $0x10,%esp
8010564e:	a1 00 5b 11 80       	mov    0x80115b00,%eax
80105653:	29 d8                	sub    %ebx,%eax
80105655:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105658:	73 39                	jae    80105693 <sys_sleep+0x74>
    if(myproc()->killed){
8010565a:	e8 0b de ff ff       	call   8010346a <myproc>
8010565f:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105663:	75 17                	jne    8010567c <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105665:	83 ec 08             	sub    $0x8,%esp
80105668:	68 20 5b 11 80       	push   $0x80115b20
8010566d:	68 00 5b 11 80       	push   $0x80115b00
80105672:	e8 44 ea ff ff       	call   801040bb <sleep>
80105677:	83 c4 10             	add    $0x10,%esp
8010567a:	eb d2                	jmp    8010564e <sys_sleep+0x2f>
      release(&tickslock);
8010567c:	83 ec 0c             	sub    $0xc,%esp
8010567f:	68 20 5b 11 80       	push   $0x80115b20
80105684:	e8 9a ef ff ff       	call   80104623 <release>
      return -1;
80105689:	83 c4 10             	add    $0x10,%esp
8010568c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105691:	eb 15                	jmp    801056a8 <sys_sleep+0x89>
  }
  release(&tickslock);
80105693:	83 ec 0c             	sub    $0xc,%esp
80105696:	68 20 5b 11 80       	push   $0x80115b20
8010569b:	e8 83 ef ff ff       	call   80104623 <release>
  return 0;
801056a0:	83 c4 10             	add    $0x10,%esp
801056a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801056ab:	c9                   	leave  
801056ac:	c3                   	ret    
    return -1;
801056ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056b2:	eb f4                	jmp    801056a8 <sys_sleep+0x89>

801056b4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801056b4:	55                   	push   %ebp
801056b5:	89 e5                	mov    %esp,%ebp
801056b7:	53                   	push   %ebx
801056b8:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
801056bb:	68 20 5b 11 80       	push   $0x80115b20
801056c0:	e8 f9 ee ff ff       	call   801045be <acquire>
  xticks = ticks;
801056c5:	8b 1d 00 5b 11 80    	mov    0x80115b00,%ebx
  release(&tickslock);
801056cb:	c7 04 24 20 5b 11 80 	movl   $0x80115b20,(%esp)
801056d2:	e8 4c ef ff ff       	call   80104623 <release>
  return xticks;
}
801056d7:	89 d8                	mov    %ebx,%eax
801056d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801056dc:	c9                   	leave  
801056dd:	c3                   	ret    

801056de <sys_yield>:

int
sys_yield(void)
{
801056de:	55                   	push   %ebp
801056df:	89 e5                	mov    %esp,%ebp
801056e1:	83 ec 08             	sub    $0x8,%esp
  yield();
801056e4:	e8 a0 e9 ff ff       	call   80104089 <yield>
  return 0;
}
801056e9:	b8 00 00 00 00       	mov    $0x0,%eax
801056ee:	c9                   	leave  
801056ef:	c3                   	ret    

801056f0 <sys_shutdown>:

int sys_shutdown(void)
{
801056f0:	55                   	push   %ebp
801056f1:	89 e5                	mov    %esp,%ebp
801056f3:	83 ec 08             	sub    $0x8,%esp
  shutdown();
801056f6:	e8 00 cb ff ff       	call   801021fb <shutdown>
  return 0;
}
801056fb:	b8 00 00 00 00       	mov    $0x0,%eax
80105700:	c9                   	leave  
80105701:	c3                   	ret    

80105702 <sys_schedlog>:

int sys_schedlog(void)
{
80105702:	55                   	push   %ebp
80105703:	89 e5                	mov    %esp,%ebp
80105705:	83 ec 20             	sub    $0x20,%esp
  int n;

  if(argint(0, &n) < 0)
80105708:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010570b:	50                   	push   %eax
8010570c:	6a 00                	push   $0x0
8010570e:	e8 a7 f1 ff ff       	call   801048ba <argint>
80105713:	83 c4 10             	add    $0x10,%esp
80105716:	85 c0                	test   %eax,%eax
80105718:	78 15                	js     8010572f <sys_schedlog+0x2d>
    return -1;

  schedlog(n);
8010571a:	83 ec 0c             	sub    $0xc,%esp
8010571d:	ff 75 f4             	push   -0xc(%ebp)
80105720:	e8 c7 da ff ff       	call   801031ec <schedlog>
  return 0;
80105725:	83 c4 10             	add    $0x10,%esp
80105728:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010572d:	c9                   	leave  
8010572e:	c3                   	ret    
    return -1;
8010572f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105734:	eb f7                	jmp    8010572d <sys_schedlog+0x2b>

80105736 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105736:	1e                   	push   %ds
  pushl %es
80105737:	06                   	push   %es
  pushl %fs
80105738:	0f a0                	push   %fs
  pushl %gs
8010573a:	0f a8                	push   %gs
  pushal
8010573c:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010573d:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105741:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105743:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105745:	54                   	push   %esp
  call trap
80105746:	e8 37 01 00 00       	call   80105882 <trap>
  addl $4, %esp
8010574b:	83 c4 04             	add    $0x4,%esp

8010574e <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010574e:	61                   	popa   
  popl %gs
8010574f:	0f a9                	pop    %gs
  popl %fs
80105751:	0f a1                	pop    %fs
  popl %es
80105753:	07                   	pop    %es
  popl %ds
80105754:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105755:	83 c4 08             	add    $0x8,%esp
  iret
80105758:	cf                   	iret   

80105759 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105759:	55                   	push   %ebp
8010575a:	89 e5                	mov    %esp,%ebp
8010575c:	53                   	push   %ebx
8010575d:	83 ec 04             	sub    $0x4,%esp
  int i;

  for(i = 0; i < 256; i++)
80105760:	b8 00 00 00 00       	mov    $0x0,%eax
80105765:	eb 76                	jmp    801057dd <tvinit+0x84>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105767:	8b 0c 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%ecx
8010576e:	66 89 0c c5 60 5b 11 	mov    %cx,-0x7feea4a0(,%eax,8)
80105775:	80 
80105776:	66 c7 04 c5 62 5b 11 	movw   $0x8,-0x7feea49e(,%eax,8)
8010577d:	80 08 00 
80105780:	0f b6 14 c5 64 5b 11 	movzbl -0x7feea49c(,%eax,8),%edx
80105787:	80 
80105788:	83 e2 e0             	and    $0xffffffe0,%edx
8010578b:	88 14 c5 64 5b 11 80 	mov    %dl,-0x7feea49c(,%eax,8)
80105792:	c6 04 c5 64 5b 11 80 	movb   $0x0,-0x7feea49c(,%eax,8)
80105799:	00 
8010579a:	0f b6 14 c5 65 5b 11 	movzbl -0x7feea49b(,%eax,8),%edx
801057a1:	80 
801057a2:	83 e2 f0             	and    $0xfffffff0,%edx
801057a5:	83 ca 0e             	or     $0xe,%edx
801057a8:	88 14 c5 65 5b 11 80 	mov    %dl,-0x7feea49b(,%eax,8)
801057af:	89 d3                	mov    %edx,%ebx
801057b1:	83 e3 ef             	and    $0xffffffef,%ebx
801057b4:	88 1c c5 65 5b 11 80 	mov    %bl,-0x7feea49b(,%eax,8)
801057bb:	83 e2 8f             	and    $0xffffff8f,%edx
801057be:	88 14 c5 65 5b 11 80 	mov    %dl,-0x7feea49b(,%eax,8)
801057c5:	83 ca 80             	or     $0xffffff80,%edx
801057c8:	88 14 c5 65 5b 11 80 	mov    %dl,-0x7feea49b(,%eax,8)
801057cf:	c1 e9 10             	shr    $0x10,%ecx
801057d2:	66 89 0c c5 66 5b 11 	mov    %cx,-0x7feea49a(,%eax,8)
801057d9:	80 
  for(i = 0; i < 256; i++)
801057da:	83 c0 01             	add    $0x1,%eax
801057dd:	3d ff 00 00 00       	cmp    $0xff,%eax
801057e2:	7e 83                	jle    80105767 <tvinit+0xe>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801057e4:	8b 15 08 b1 10 80    	mov    0x8010b108,%edx
801057ea:	66 89 15 60 5d 11 80 	mov    %dx,0x80115d60
801057f1:	66 c7 05 62 5d 11 80 	movw   $0x8,0x80115d62
801057f8:	08 00 
801057fa:	0f b6 05 64 5d 11 80 	movzbl 0x80115d64,%eax
80105801:	83 e0 e0             	and    $0xffffffe0,%eax
80105804:	a2 64 5d 11 80       	mov    %al,0x80115d64
80105809:	c6 05 64 5d 11 80 00 	movb   $0x0,0x80115d64
80105810:	0f b6 05 65 5d 11 80 	movzbl 0x80115d65,%eax
80105817:	83 c8 0f             	or     $0xf,%eax
8010581a:	a2 65 5d 11 80       	mov    %al,0x80115d65
8010581f:	83 e0 ef             	and    $0xffffffef,%eax
80105822:	a2 65 5d 11 80       	mov    %al,0x80115d65
80105827:	89 c1                	mov    %eax,%ecx
80105829:	83 c9 60             	or     $0x60,%ecx
8010582c:	88 0d 65 5d 11 80    	mov    %cl,0x80115d65
80105832:	83 c8 e0             	or     $0xffffffe0,%eax
80105835:	a2 65 5d 11 80       	mov    %al,0x80115d65
8010583a:	c1 ea 10             	shr    $0x10,%edx
8010583d:	66 89 15 66 5d 11 80 	mov    %dx,0x80115d66

  initlock(&tickslock, "time");
80105844:	83 ec 08             	sub    $0x8,%esp
80105847:	68 89 7d 10 80       	push   $0x80107d89
8010584c:	68 20 5b 11 80       	push   $0x80115b20
80105851:	e8 2c ec ff ff       	call   80104482 <initlock>
}
80105856:	83 c4 10             	add    $0x10,%esp
80105859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010585c:	c9                   	leave  
8010585d:	c3                   	ret    

8010585e <idtinit>:

void
idtinit(void)
{
8010585e:	55                   	push   %ebp
8010585f:	89 e5                	mov    %esp,%ebp
80105861:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105864:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
8010586a:	b8 60 5b 11 80       	mov    $0x80115b60,%eax
8010586f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105873:	c1 e8 10             	shr    $0x10,%eax
80105876:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010587a:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010587d:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105880:	c9                   	leave  
80105881:	c3                   	ret    

80105882 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105882:	55                   	push   %ebp
80105883:	89 e5                	mov    %esp,%ebp
80105885:	57                   	push   %edi
80105886:	56                   	push   %esi
80105887:	53                   	push   %ebx
80105888:	83 ec 1c             	sub    $0x1c,%esp
8010588b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
8010588e:	8b 43 30             	mov    0x30(%ebx),%eax
80105891:	83 f8 40             	cmp    $0x40,%eax
80105894:	74 13                	je     801058a9 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105896:	83 e8 20             	sub    $0x20,%eax
80105899:	83 f8 1f             	cmp    $0x1f,%eax
8010589c:	0f 87 3a 01 00 00    	ja     801059dc <trap+0x15a>
801058a2:	ff 24 85 64 7e 10 80 	jmp    *-0x7fef819c(,%eax,4)
    if(myproc()->killed)
801058a9:	e8 bc db ff ff       	call   8010346a <myproc>
801058ae:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801058b2:	75 1f                	jne    801058d3 <trap+0x51>
    myproc()->tf = tf;
801058b4:	e8 b1 db ff ff       	call   8010346a <myproc>
801058b9:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
801058bc:	e8 bc f0 ff ff       	call   8010497d <syscall>
    if(myproc()->killed)
801058c1:	e8 a4 db ff ff       	call   8010346a <myproc>
801058c6:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801058ca:	74 7e                	je     8010594a <trap+0xc8>
      exit();
801058cc:	e8 c9 e6 ff ff       	call   80103f9a <exit>
    return;
801058d1:	eb 77                	jmp    8010594a <trap+0xc8>
      exit();
801058d3:	e8 c2 e6 ff ff       	call   80103f9a <exit>
801058d8:	eb da                	jmp    801058b4 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801058da:	e8 70 db ff ff       	call   8010344f <cpuid>
801058df:	85 c0                	test   %eax,%eax
801058e1:	74 6f                	je     80105952 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
801058e3:	e8 c0 ca ff ff       	call   801023a8 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801058e8:	e8 7d db ff ff       	call   8010346a <myproc>
801058ed:	85 c0                	test   %eax,%eax
801058ef:	74 1c                	je     8010590d <trap+0x8b>
801058f1:	e8 74 db ff ff       	call   8010346a <myproc>
801058f6:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801058fa:	74 11                	je     8010590d <trap+0x8b>
801058fc:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105900:	83 e0 03             	and    $0x3,%eax
80105903:	66 83 f8 03          	cmp    $0x3,%ax
80105907:	0f 84 62 01 00 00    	je     80105a6f <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010590d:	e8 58 db ff ff       	call   8010346a <myproc>
80105912:	85 c0                	test   %eax,%eax
80105914:	74 0f                	je     80105925 <trap+0xa3>
80105916:	e8 4f db ff ff       	call   8010346a <myproc>
8010591b:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
8010591f:	0f 84 54 01 00 00    	je     80105a79 <trap+0x1f7>
      yield();
    }
  }

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105925:	e8 40 db ff ff       	call   8010346a <myproc>
8010592a:	85 c0                	test   %eax,%eax
8010592c:	74 1c                	je     8010594a <trap+0xc8>
8010592e:	e8 37 db ff ff       	call   8010346a <myproc>
80105933:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105937:	74 11                	je     8010594a <trap+0xc8>
80105939:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010593d:	83 e0 03             	and    $0x3,%eax
80105940:	66 83 f8 03          	cmp    $0x3,%ax
80105944:	0f 84 92 01 00 00    	je     80105adc <trap+0x25a>
    exit();
}
8010594a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010594d:	5b                   	pop    %ebx
8010594e:	5e                   	pop    %esi
8010594f:	5f                   	pop    %edi
80105950:	5d                   	pop    %ebp
80105951:	c3                   	ret    
      acquire(&tickslock);
80105952:	83 ec 0c             	sub    $0xc,%esp
80105955:	68 20 5b 11 80       	push   $0x80115b20
8010595a:	e8 5f ec ff ff       	call   801045be <acquire>
      ticks++;
8010595f:	83 05 00 5b 11 80 01 	addl   $0x1,0x80115b00
      wakeup(&ticks);
80105966:	c7 04 24 00 5b 11 80 	movl   $0x80115b00,(%esp)
8010596d:	e8 b1 e8 ff ff       	call   80104223 <wakeup>
      release(&tickslock);
80105972:	c7 04 24 20 5b 11 80 	movl   $0x80115b20,(%esp)
80105979:	e8 a5 ec ff ff       	call   80104623 <release>
8010597e:	83 c4 10             	add    $0x10,%esp
80105981:	e9 5d ff ff ff       	jmp    801058e3 <trap+0x61>
    ideintr();
80105986:	e8 d1 c3 ff ff       	call   80101d5c <ideintr>
    lapiceoi();
8010598b:	e8 18 ca ff ff       	call   801023a8 <lapiceoi>
    break;
80105990:	e9 53 ff ff ff       	jmp    801058e8 <trap+0x66>
    kbdintr();
80105995:	e8 4c c8 ff ff       	call   801021e6 <kbdintr>
    lapiceoi();
8010599a:	e8 09 ca ff ff       	call   801023a8 <lapiceoi>
    break;
8010599f:	e9 44 ff ff ff       	jmp    801058e8 <trap+0x66>
    uartintr();
801059a4:	e8 4d 02 00 00       	call   80105bf6 <uartintr>
    lapiceoi();
801059a9:	e8 fa c9 ff ff       	call   801023a8 <lapiceoi>
    break;
801059ae:	e9 35 ff ff ff       	jmp    801058e8 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801059b3:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
801059b6:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801059ba:	e8 90 da ff ff       	call   8010344f <cpuid>
801059bf:	57                   	push   %edi
801059c0:	0f b7 f6             	movzwl %si,%esi
801059c3:	56                   	push   %esi
801059c4:	50                   	push   %eax
801059c5:	68 94 7d 10 80       	push   $0x80107d94
801059ca:	e8 38 ac ff ff       	call   80100607 <cprintf>
    lapiceoi();
801059cf:	e8 d4 c9 ff ff       	call   801023a8 <lapiceoi>
    break;
801059d4:	83 c4 10             	add    $0x10,%esp
801059d7:	e9 0c ff ff ff       	jmp    801058e8 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
801059dc:	e8 89 da ff ff       	call   8010346a <myproc>
801059e1:	85 c0                	test   %eax,%eax
801059e3:	74 5f                	je     80105a44 <trap+0x1c2>
801059e5:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801059e9:	74 59                	je     80105a44 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801059eb:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801059ee:	8b 43 38             	mov    0x38(%ebx),%eax
801059f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801059f4:	e8 56 da ff ff       	call   8010344f <cpuid>
801059f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
801059fc:	8b 4b 34             	mov    0x34(%ebx),%ecx
801059ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80105a02:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105a05:	e8 60 da ff ff       	call   8010346a <myproc>
80105a0a:	8d 50 6c             	lea    0x6c(%eax),%edx
80105a0d:	89 55 d8             	mov    %edx,-0x28(%ebp)
80105a10:	e8 55 da ff ff       	call   8010346a <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105a15:	57                   	push   %edi
80105a16:	ff 75 e4             	push   -0x1c(%ebp)
80105a19:	ff 75 e0             	push   -0x20(%ebp)
80105a1c:	ff 75 dc             	push   -0x24(%ebp)
80105a1f:	56                   	push   %esi
80105a20:	ff 75 d8             	push   -0x28(%ebp)
80105a23:	ff 70 10             	push   0x10(%eax)
80105a26:	68 ec 7d 10 80       	push   $0x80107dec
80105a2b:	e8 d7 ab ff ff       	call   80100607 <cprintf>
    myproc()->killed = 1;
80105a30:	83 c4 20             	add    $0x20,%esp
80105a33:	e8 32 da ff ff       	call   8010346a <myproc>
80105a38:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105a3f:	e9 a4 fe ff ff       	jmp    801058e8 <trap+0x66>
80105a44:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105a47:	8b 73 38             	mov    0x38(%ebx),%esi
80105a4a:	e8 00 da ff ff       	call   8010344f <cpuid>
80105a4f:	83 ec 0c             	sub    $0xc,%esp
80105a52:	57                   	push   %edi
80105a53:	56                   	push   %esi
80105a54:	50                   	push   %eax
80105a55:	ff 73 30             	push   0x30(%ebx)
80105a58:	68 b8 7d 10 80       	push   $0x80107db8
80105a5d:	e8 a5 ab ff ff       	call   80100607 <cprintf>
      panic("trap");
80105a62:	83 c4 14             	add    $0x14,%esp
80105a65:	68 8e 7d 10 80       	push   $0x80107d8e
80105a6a:	e8 d9 a8 ff ff       	call   80100348 <panic>
    exit();
80105a6f:	e8 26 e5 ff ff       	call   80103f9a <exit>
80105a74:	e9 94 fe ff ff       	jmp    8010590d <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
80105a79:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105a7d:	0f 85 a2 fe ff ff    	jne    80105925 <trap+0xa3>
    if (!mycpu()->queue)
80105a83:	e8 6b d9 ff ff       	call   801033f3 <mycpu>
80105a88:	83 b8 b0 00 00 00 00 	cmpl   $0x0,0xb0(%eax)
80105a8f:	74 3e                	je     80105acf <trap+0x24d>
    int proc_ticks = --myproc()->ticks_left;
80105a91:	e8 d4 d9 ff ff       	call   8010346a <myproc>
80105a96:	8b 48 7c             	mov    0x7c(%eax),%ecx
80105a99:	8d 71 ff             	lea    -0x1(%ecx),%esi
80105a9c:	89 70 7c             	mov    %esi,0x7c(%eax)
    int level_ticks = --mycpu()->queue->ticks_left;
80105a9f:	e8 4f d9 ff ff       	call   801033f3 <mycpu>
80105aa4:	8b 90 b0 00 00 00    	mov    0xb0(%eax),%edx
80105aaa:	8b 42 38             	mov    0x38(%edx),%eax
80105aad:	83 e8 01             	sub    $0x1,%eax
80105ab0:	89 42 38             	mov    %eax,0x38(%edx)
    if (proc_ticks <= 0 || level_ticks <= 0){
80105ab3:	85 f6                	test   %esi,%esi
80105ab5:	0f 9e c2             	setle  %dl
80105ab8:	85 c0                	test   %eax,%eax
80105aba:	0f 9e c0             	setle  %al
80105abd:	08 c2                	or     %al,%dl
80105abf:	0f 84 60 fe ff ff    	je     80105925 <trap+0xa3>
      yield();
80105ac5:	e8 bf e5 ff ff       	call   80104089 <yield>
80105aca:	e9 56 fe ff ff       	jmp    80105925 <trap+0xa3>
      panic("Running process located outside active/expired set.");
80105acf:	83 ec 0c             	sub    $0xc,%esp
80105ad2:	68 30 7e 10 80       	push   $0x80107e30
80105ad7:	e8 6c a8 ff ff       	call   80100348 <panic>
    exit();
80105adc:	e8 b9 e4 ff ff       	call   80103f9a <exit>
80105ae1:	e9 64 fe ff ff       	jmp    8010594a <trap+0xc8>

80105ae6 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105ae6:	83 3d 60 63 11 80 00 	cmpl   $0x0,0x80116360
80105aed:	74 14                	je     80105b03 <uartgetc+0x1d>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105aef:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105af4:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105af5:	a8 01                	test   $0x1,%al
80105af7:	74 10                	je     80105b09 <uartgetc+0x23>
80105af9:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105afe:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105aff:	0f b6 c0             	movzbl %al,%eax
80105b02:	c3                   	ret    
    return -1;
80105b03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b08:	c3                   	ret    
    return -1;
80105b09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b0e:	c3                   	ret    

80105b0f <uartputc>:
  if(!uart)
80105b0f:	83 3d 60 63 11 80 00 	cmpl   $0x0,0x80116360
80105b16:	74 3b                	je     80105b53 <uartputc+0x44>
{
80105b18:	55                   	push   %ebp
80105b19:	89 e5                	mov    %esp,%ebp
80105b1b:	53                   	push   %ebx
80105b1c:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105b1f:	bb 00 00 00 00       	mov    $0x0,%ebx
80105b24:	eb 10                	jmp    80105b36 <uartputc+0x27>
    microdelay(10);
80105b26:	83 ec 0c             	sub    $0xc,%esp
80105b29:	6a 0a                	push   $0xa
80105b2b:	e8 99 c8 ff ff       	call   801023c9 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105b30:	83 c3 01             	add    $0x1,%ebx
80105b33:	83 c4 10             	add    $0x10,%esp
80105b36:	83 fb 7f             	cmp    $0x7f,%ebx
80105b39:	7f 0a                	jg     80105b45 <uartputc+0x36>
80105b3b:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105b40:	ec                   	in     (%dx),%al
80105b41:	a8 20                	test   $0x20,%al
80105b43:	74 e1                	je     80105b26 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105b45:	8b 45 08             	mov    0x8(%ebp),%eax
80105b48:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105b4d:	ee                   	out    %al,(%dx)
}
80105b4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105b51:	c9                   	leave  
80105b52:	c3                   	ret    
80105b53:	c3                   	ret    

80105b54 <uartinit>:
{
80105b54:	55                   	push   %ebp
80105b55:	89 e5                	mov    %esp,%ebp
80105b57:	56                   	push   %esi
80105b58:	53                   	push   %ebx
80105b59:	b9 00 00 00 00       	mov    $0x0,%ecx
80105b5e:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105b63:	89 c8                	mov    %ecx,%eax
80105b65:	ee                   	out    %al,(%dx)
80105b66:	be fb 03 00 00       	mov    $0x3fb,%esi
80105b6b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105b70:	89 f2                	mov    %esi,%edx
80105b72:	ee                   	out    %al,(%dx)
80105b73:	b8 0c 00 00 00       	mov    $0xc,%eax
80105b78:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105b7d:	ee                   	out    %al,(%dx)
80105b7e:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105b83:	89 c8                	mov    %ecx,%eax
80105b85:	89 da                	mov    %ebx,%edx
80105b87:	ee                   	out    %al,(%dx)
80105b88:	b8 03 00 00 00       	mov    $0x3,%eax
80105b8d:	89 f2                	mov    %esi,%edx
80105b8f:	ee                   	out    %al,(%dx)
80105b90:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105b95:	89 c8                	mov    %ecx,%eax
80105b97:	ee                   	out    %al,(%dx)
80105b98:	b8 01 00 00 00       	mov    $0x1,%eax
80105b9d:	89 da                	mov    %ebx,%edx
80105b9f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105ba0:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105ba5:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105ba6:	3c ff                	cmp    $0xff,%al
80105ba8:	74 45                	je     80105bef <uartinit+0x9b>
  uart = 1;
80105baa:	c7 05 60 63 11 80 01 	movl   $0x1,0x80116360
80105bb1:	00 00 00 
80105bb4:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105bb9:	ec                   	in     (%dx),%al
80105bba:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105bbf:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105bc0:	83 ec 08             	sub    $0x8,%esp
80105bc3:	6a 00                	push   $0x0
80105bc5:	6a 04                	push   $0x4
80105bc7:	e8 95 c3 ff ff       	call   80101f61 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105bcc:	83 c4 10             	add    $0x10,%esp
80105bcf:	bb e4 7e 10 80       	mov    $0x80107ee4,%ebx
80105bd4:	eb 12                	jmp    80105be8 <uartinit+0x94>
    uartputc(*p);
80105bd6:	83 ec 0c             	sub    $0xc,%esp
80105bd9:	0f be c0             	movsbl %al,%eax
80105bdc:	50                   	push   %eax
80105bdd:	e8 2d ff ff ff       	call   80105b0f <uartputc>
  for(p="xv6...\n"; *p; p++)
80105be2:	83 c3 01             	add    $0x1,%ebx
80105be5:	83 c4 10             	add    $0x10,%esp
80105be8:	0f b6 03             	movzbl (%ebx),%eax
80105beb:	84 c0                	test   %al,%al
80105bed:	75 e7                	jne    80105bd6 <uartinit+0x82>
}
80105bef:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105bf2:	5b                   	pop    %ebx
80105bf3:	5e                   	pop    %esi
80105bf4:	5d                   	pop    %ebp
80105bf5:	c3                   	ret    

80105bf6 <uartintr>:

void
uartintr(void)
{
80105bf6:	55                   	push   %ebp
80105bf7:	89 e5                	mov    %esp,%ebp
80105bf9:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105bfc:	68 e6 5a 10 80       	push   $0x80105ae6
80105c01:	e8 2d ab ff ff       	call   80100733 <consoleintr>
}
80105c06:	83 c4 10             	add    $0x10,%esp
80105c09:	c9                   	leave  
80105c0a:	c3                   	ret    

80105c0b <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105c0b:	6a 00                	push   $0x0
  pushl $0
80105c0d:	6a 00                	push   $0x0
  jmp alltraps
80105c0f:	e9 22 fb ff ff       	jmp    80105736 <alltraps>

80105c14 <vector1>:
.globl vector1
vector1:
  pushl $0
80105c14:	6a 00                	push   $0x0
  pushl $1
80105c16:	6a 01                	push   $0x1
  jmp alltraps
80105c18:	e9 19 fb ff ff       	jmp    80105736 <alltraps>

80105c1d <vector2>:
.globl vector2
vector2:
  pushl $0
80105c1d:	6a 00                	push   $0x0
  pushl $2
80105c1f:	6a 02                	push   $0x2
  jmp alltraps
80105c21:	e9 10 fb ff ff       	jmp    80105736 <alltraps>

80105c26 <vector3>:
.globl vector3
vector3:
  pushl $0
80105c26:	6a 00                	push   $0x0
  pushl $3
80105c28:	6a 03                	push   $0x3
  jmp alltraps
80105c2a:	e9 07 fb ff ff       	jmp    80105736 <alltraps>

80105c2f <vector4>:
.globl vector4
vector4:
  pushl $0
80105c2f:	6a 00                	push   $0x0
  pushl $4
80105c31:	6a 04                	push   $0x4
  jmp alltraps
80105c33:	e9 fe fa ff ff       	jmp    80105736 <alltraps>

80105c38 <vector5>:
.globl vector5
vector5:
  pushl $0
80105c38:	6a 00                	push   $0x0
  pushl $5
80105c3a:	6a 05                	push   $0x5
  jmp alltraps
80105c3c:	e9 f5 fa ff ff       	jmp    80105736 <alltraps>

80105c41 <vector6>:
.globl vector6
vector6:
  pushl $0
80105c41:	6a 00                	push   $0x0
  pushl $6
80105c43:	6a 06                	push   $0x6
  jmp alltraps
80105c45:	e9 ec fa ff ff       	jmp    80105736 <alltraps>

80105c4a <vector7>:
.globl vector7
vector7:
  pushl $0
80105c4a:	6a 00                	push   $0x0
  pushl $7
80105c4c:	6a 07                	push   $0x7
  jmp alltraps
80105c4e:	e9 e3 fa ff ff       	jmp    80105736 <alltraps>

80105c53 <vector8>:
.globl vector8
vector8:
  pushl $8
80105c53:	6a 08                	push   $0x8
  jmp alltraps
80105c55:	e9 dc fa ff ff       	jmp    80105736 <alltraps>

80105c5a <vector9>:
.globl vector9
vector9:
  pushl $0
80105c5a:	6a 00                	push   $0x0
  pushl $9
80105c5c:	6a 09                	push   $0x9
  jmp alltraps
80105c5e:	e9 d3 fa ff ff       	jmp    80105736 <alltraps>

80105c63 <vector10>:
.globl vector10
vector10:
  pushl $10
80105c63:	6a 0a                	push   $0xa
  jmp alltraps
80105c65:	e9 cc fa ff ff       	jmp    80105736 <alltraps>

80105c6a <vector11>:
.globl vector11
vector11:
  pushl $11
80105c6a:	6a 0b                	push   $0xb
  jmp alltraps
80105c6c:	e9 c5 fa ff ff       	jmp    80105736 <alltraps>

80105c71 <vector12>:
.globl vector12
vector12:
  pushl $12
80105c71:	6a 0c                	push   $0xc
  jmp alltraps
80105c73:	e9 be fa ff ff       	jmp    80105736 <alltraps>

80105c78 <vector13>:
.globl vector13
vector13:
  pushl $13
80105c78:	6a 0d                	push   $0xd
  jmp alltraps
80105c7a:	e9 b7 fa ff ff       	jmp    80105736 <alltraps>

80105c7f <vector14>:
.globl vector14
vector14:
  pushl $14
80105c7f:	6a 0e                	push   $0xe
  jmp alltraps
80105c81:	e9 b0 fa ff ff       	jmp    80105736 <alltraps>

80105c86 <vector15>:
.globl vector15
vector15:
  pushl $0
80105c86:	6a 00                	push   $0x0
  pushl $15
80105c88:	6a 0f                	push   $0xf
  jmp alltraps
80105c8a:	e9 a7 fa ff ff       	jmp    80105736 <alltraps>

80105c8f <vector16>:
.globl vector16
vector16:
  pushl $0
80105c8f:	6a 00                	push   $0x0
  pushl $16
80105c91:	6a 10                	push   $0x10
  jmp alltraps
80105c93:	e9 9e fa ff ff       	jmp    80105736 <alltraps>

80105c98 <vector17>:
.globl vector17
vector17:
  pushl $17
80105c98:	6a 11                	push   $0x11
  jmp alltraps
80105c9a:	e9 97 fa ff ff       	jmp    80105736 <alltraps>

80105c9f <vector18>:
.globl vector18
vector18:
  pushl $0
80105c9f:	6a 00                	push   $0x0
  pushl $18
80105ca1:	6a 12                	push   $0x12
  jmp alltraps
80105ca3:	e9 8e fa ff ff       	jmp    80105736 <alltraps>

80105ca8 <vector19>:
.globl vector19
vector19:
  pushl $0
80105ca8:	6a 00                	push   $0x0
  pushl $19
80105caa:	6a 13                	push   $0x13
  jmp alltraps
80105cac:	e9 85 fa ff ff       	jmp    80105736 <alltraps>

80105cb1 <vector20>:
.globl vector20
vector20:
  pushl $0
80105cb1:	6a 00                	push   $0x0
  pushl $20
80105cb3:	6a 14                	push   $0x14
  jmp alltraps
80105cb5:	e9 7c fa ff ff       	jmp    80105736 <alltraps>

80105cba <vector21>:
.globl vector21
vector21:
  pushl $0
80105cba:	6a 00                	push   $0x0
  pushl $21
80105cbc:	6a 15                	push   $0x15
  jmp alltraps
80105cbe:	e9 73 fa ff ff       	jmp    80105736 <alltraps>

80105cc3 <vector22>:
.globl vector22
vector22:
  pushl $0
80105cc3:	6a 00                	push   $0x0
  pushl $22
80105cc5:	6a 16                	push   $0x16
  jmp alltraps
80105cc7:	e9 6a fa ff ff       	jmp    80105736 <alltraps>

80105ccc <vector23>:
.globl vector23
vector23:
  pushl $0
80105ccc:	6a 00                	push   $0x0
  pushl $23
80105cce:	6a 17                	push   $0x17
  jmp alltraps
80105cd0:	e9 61 fa ff ff       	jmp    80105736 <alltraps>

80105cd5 <vector24>:
.globl vector24
vector24:
  pushl $0
80105cd5:	6a 00                	push   $0x0
  pushl $24
80105cd7:	6a 18                	push   $0x18
  jmp alltraps
80105cd9:	e9 58 fa ff ff       	jmp    80105736 <alltraps>

80105cde <vector25>:
.globl vector25
vector25:
  pushl $0
80105cde:	6a 00                	push   $0x0
  pushl $25
80105ce0:	6a 19                	push   $0x19
  jmp alltraps
80105ce2:	e9 4f fa ff ff       	jmp    80105736 <alltraps>

80105ce7 <vector26>:
.globl vector26
vector26:
  pushl $0
80105ce7:	6a 00                	push   $0x0
  pushl $26
80105ce9:	6a 1a                	push   $0x1a
  jmp alltraps
80105ceb:	e9 46 fa ff ff       	jmp    80105736 <alltraps>

80105cf0 <vector27>:
.globl vector27
vector27:
  pushl $0
80105cf0:	6a 00                	push   $0x0
  pushl $27
80105cf2:	6a 1b                	push   $0x1b
  jmp alltraps
80105cf4:	e9 3d fa ff ff       	jmp    80105736 <alltraps>

80105cf9 <vector28>:
.globl vector28
vector28:
  pushl $0
80105cf9:	6a 00                	push   $0x0
  pushl $28
80105cfb:	6a 1c                	push   $0x1c
  jmp alltraps
80105cfd:	e9 34 fa ff ff       	jmp    80105736 <alltraps>

80105d02 <vector29>:
.globl vector29
vector29:
  pushl $0
80105d02:	6a 00                	push   $0x0
  pushl $29
80105d04:	6a 1d                	push   $0x1d
  jmp alltraps
80105d06:	e9 2b fa ff ff       	jmp    80105736 <alltraps>

80105d0b <vector30>:
.globl vector30
vector30:
  pushl $0
80105d0b:	6a 00                	push   $0x0
  pushl $30
80105d0d:	6a 1e                	push   $0x1e
  jmp alltraps
80105d0f:	e9 22 fa ff ff       	jmp    80105736 <alltraps>

80105d14 <vector31>:
.globl vector31
vector31:
  pushl $0
80105d14:	6a 00                	push   $0x0
  pushl $31
80105d16:	6a 1f                	push   $0x1f
  jmp alltraps
80105d18:	e9 19 fa ff ff       	jmp    80105736 <alltraps>

80105d1d <vector32>:
.globl vector32
vector32:
  pushl $0
80105d1d:	6a 00                	push   $0x0
  pushl $32
80105d1f:	6a 20                	push   $0x20
  jmp alltraps
80105d21:	e9 10 fa ff ff       	jmp    80105736 <alltraps>

80105d26 <vector33>:
.globl vector33
vector33:
  pushl $0
80105d26:	6a 00                	push   $0x0
  pushl $33
80105d28:	6a 21                	push   $0x21
  jmp alltraps
80105d2a:	e9 07 fa ff ff       	jmp    80105736 <alltraps>

80105d2f <vector34>:
.globl vector34
vector34:
  pushl $0
80105d2f:	6a 00                	push   $0x0
  pushl $34
80105d31:	6a 22                	push   $0x22
  jmp alltraps
80105d33:	e9 fe f9 ff ff       	jmp    80105736 <alltraps>

80105d38 <vector35>:
.globl vector35
vector35:
  pushl $0
80105d38:	6a 00                	push   $0x0
  pushl $35
80105d3a:	6a 23                	push   $0x23
  jmp alltraps
80105d3c:	e9 f5 f9 ff ff       	jmp    80105736 <alltraps>

80105d41 <vector36>:
.globl vector36
vector36:
  pushl $0
80105d41:	6a 00                	push   $0x0
  pushl $36
80105d43:	6a 24                	push   $0x24
  jmp alltraps
80105d45:	e9 ec f9 ff ff       	jmp    80105736 <alltraps>

80105d4a <vector37>:
.globl vector37
vector37:
  pushl $0
80105d4a:	6a 00                	push   $0x0
  pushl $37
80105d4c:	6a 25                	push   $0x25
  jmp alltraps
80105d4e:	e9 e3 f9 ff ff       	jmp    80105736 <alltraps>

80105d53 <vector38>:
.globl vector38
vector38:
  pushl $0
80105d53:	6a 00                	push   $0x0
  pushl $38
80105d55:	6a 26                	push   $0x26
  jmp alltraps
80105d57:	e9 da f9 ff ff       	jmp    80105736 <alltraps>

80105d5c <vector39>:
.globl vector39
vector39:
  pushl $0
80105d5c:	6a 00                	push   $0x0
  pushl $39
80105d5e:	6a 27                	push   $0x27
  jmp alltraps
80105d60:	e9 d1 f9 ff ff       	jmp    80105736 <alltraps>

80105d65 <vector40>:
.globl vector40
vector40:
  pushl $0
80105d65:	6a 00                	push   $0x0
  pushl $40
80105d67:	6a 28                	push   $0x28
  jmp alltraps
80105d69:	e9 c8 f9 ff ff       	jmp    80105736 <alltraps>

80105d6e <vector41>:
.globl vector41
vector41:
  pushl $0
80105d6e:	6a 00                	push   $0x0
  pushl $41
80105d70:	6a 29                	push   $0x29
  jmp alltraps
80105d72:	e9 bf f9 ff ff       	jmp    80105736 <alltraps>

80105d77 <vector42>:
.globl vector42
vector42:
  pushl $0
80105d77:	6a 00                	push   $0x0
  pushl $42
80105d79:	6a 2a                	push   $0x2a
  jmp alltraps
80105d7b:	e9 b6 f9 ff ff       	jmp    80105736 <alltraps>

80105d80 <vector43>:
.globl vector43
vector43:
  pushl $0
80105d80:	6a 00                	push   $0x0
  pushl $43
80105d82:	6a 2b                	push   $0x2b
  jmp alltraps
80105d84:	e9 ad f9 ff ff       	jmp    80105736 <alltraps>

80105d89 <vector44>:
.globl vector44
vector44:
  pushl $0
80105d89:	6a 00                	push   $0x0
  pushl $44
80105d8b:	6a 2c                	push   $0x2c
  jmp alltraps
80105d8d:	e9 a4 f9 ff ff       	jmp    80105736 <alltraps>

80105d92 <vector45>:
.globl vector45
vector45:
  pushl $0
80105d92:	6a 00                	push   $0x0
  pushl $45
80105d94:	6a 2d                	push   $0x2d
  jmp alltraps
80105d96:	e9 9b f9 ff ff       	jmp    80105736 <alltraps>

80105d9b <vector46>:
.globl vector46
vector46:
  pushl $0
80105d9b:	6a 00                	push   $0x0
  pushl $46
80105d9d:	6a 2e                	push   $0x2e
  jmp alltraps
80105d9f:	e9 92 f9 ff ff       	jmp    80105736 <alltraps>

80105da4 <vector47>:
.globl vector47
vector47:
  pushl $0
80105da4:	6a 00                	push   $0x0
  pushl $47
80105da6:	6a 2f                	push   $0x2f
  jmp alltraps
80105da8:	e9 89 f9 ff ff       	jmp    80105736 <alltraps>

80105dad <vector48>:
.globl vector48
vector48:
  pushl $0
80105dad:	6a 00                	push   $0x0
  pushl $48
80105daf:	6a 30                	push   $0x30
  jmp alltraps
80105db1:	e9 80 f9 ff ff       	jmp    80105736 <alltraps>

80105db6 <vector49>:
.globl vector49
vector49:
  pushl $0
80105db6:	6a 00                	push   $0x0
  pushl $49
80105db8:	6a 31                	push   $0x31
  jmp alltraps
80105dba:	e9 77 f9 ff ff       	jmp    80105736 <alltraps>

80105dbf <vector50>:
.globl vector50
vector50:
  pushl $0
80105dbf:	6a 00                	push   $0x0
  pushl $50
80105dc1:	6a 32                	push   $0x32
  jmp alltraps
80105dc3:	e9 6e f9 ff ff       	jmp    80105736 <alltraps>

80105dc8 <vector51>:
.globl vector51
vector51:
  pushl $0
80105dc8:	6a 00                	push   $0x0
  pushl $51
80105dca:	6a 33                	push   $0x33
  jmp alltraps
80105dcc:	e9 65 f9 ff ff       	jmp    80105736 <alltraps>

80105dd1 <vector52>:
.globl vector52
vector52:
  pushl $0
80105dd1:	6a 00                	push   $0x0
  pushl $52
80105dd3:	6a 34                	push   $0x34
  jmp alltraps
80105dd5:	e9 5c f9 ff ff       	jmp    80105736 <alltraps>

80105dda <vector53>:
.globl vector53
vector53:
  pushl $0
80105dda:	6a 00                	push   $0x0
  pushl $53
80105ddc:	6a 35                	push   $0x35
  jmp alltraps
80105dde:	e9 53 f9 ff ff       	jmp    80105736 <alltraps>

80105de3 <vector54>:
.globl vector54
vector54:
  pushl $0
80105de3:	6a 00                	push   $0x0
  pushl $54
80105de5:	6a 36                	push   $0x36
  jmp alltraps
80105de7:	e9 4a f9 ff ff       	jmp    80105736 <alltraps>

80105dec <vector55>:
.globl vector55
vector55:
  pushl $0
80105dec:	6a 00                	push   $0x0
  pushl $55
80105dee:	6a 37                	push   $0x37
  jmp alltraps
80105df0:	e9 41 f9 ff ff       	jmp    80105736 <alltraps>

80105df5 <vector56>:
.globl vector56
vector56:
  pushl $0
80105df5:	6a 00                	push   $0x0
  pushl $56
80105df7:	6a 38                	push   $0x38
  jmp alltraps
80105df9:	e9 38 f9 ff ff       	jmp    80105736 <alltraps>

80105dfe <vector57>:
.globl vector57
vector57:
  pushl $0
80105dfe:	6a 00                	push   $0x0
  pushl $57
80105e00:	6a 39                	push   $0x39
  jmp alltraps
80105e02:	e9 2f f9 ff ff       	jmp    80105736 <alltraps>

80105e07 <vector58>:
.globl vector58
vector58:
  pushl $0
80105e07:	6a 00                	push   $0x0
  pushl $58
80105e09:	6a 3a                	push   $0x3a
  jmp alltraps
80105e0b:	e9 26 f9 ff ff       	jmp    80105736 <alltraps>

80105e10 <vector59>:
.globl vector59
vector59:
  pushl $0
80105e10:	6a 00                	push   $0x0
  pushl $59
80105e12:	6a 3b                	push   $0x3b
  jmp alltraps
80105e14:	e9 1d f9 ff ff       	jmp    80105736 <alltraps>

80105e19 <vector60>:
.globl vector60
vector60:
  pushl $0
80105e19:	6a 00                	push   $0x0
  pushl $60
80105e1b:	6a 3c                	push   $0x3c
  jmp alltraps
80105e1d:	e9 14 f9 ff ff       	jmp    80105736 <alltraps>

80105e22 <vector61>:
.globl vector61
vector61:
  pushl $0
80105e22:	6a 00                	push   $0x0
  pushl $61
80105e24:	6a 3d                	push   $0x3d
  jmp alltraps
80105e26:	e9 0b f9 ff ff       	jmp    80105736 <alltraps>

80105e2b <vector62>:
.globl vector62
vector62:
  pushl $0
80105e2b:	6a 00                	push   $0x0
  pushl $62
80105e2d:	6a 3e                	push   $0x3e
  jmp alltraps
80105e2f:	e9 02 f9 ff ff       	jmp    80105736 <alltraps>

80105e34 <vector63>:
.globl vector63
vector63:
  pushl $0
80105e34:	6a 00                	push   $0x0
  pushl $63
80105e36:	6a 3f                	push   $0x3f
  jmp alltraps
80105e38:	e9 f9 f8 ff ff       	jmp    80105736 <alltraps>

80105e3d <vector64>:
.globl vector64
vector64:
  pushl $0
80105e3d:	6a 00                	push   $0x0
  pushl $64
80105e3f:	6a 40                	push   $0x40
  jmp alltraps
80105e41:	e9 f0 f8 ff ff       	jmp    80105736 <alltraps>

80105e46 <vector65>:
.globl vector65
vector65:
  pushl $0
80105e46:	6a 00                	push   $0x0
  pushl $65
80105e48:	6a 41                	push   $0x41
  jmp alltraps
80105e4a:	e9 e7 f8 ff ff       	jmp    80105736 <alltraps>

80105e4f <vector66>:
.globl vector66
vector66:
  pushl $0
80105e4f:	6a 00                	push   $0x0
  pushl $66
80105e51:	6a 42                	push   $0x42
  jmp alltraps
80105e53:	e9 de f8 ff ff       	jmp    80105736 <alltraps>

80105e58 <vector67>:
.globl vector67
vector67:
  pushl $0
80105e58:	6a 00                	push   $0x0
  pushl $67
80105e5a:	6a 43                	push   $0x43
  jmp alltraps
80105e5c:	e9 d5 f8 ff ff       	jmp    80105736 <alltraps>

80105e61 <vector68>:
.globl vector68
vector68:
  pushl $0
80105e61:	6a 00                	push   $0x0
  pushl $68
80105e63:	6a 44                	push   $0x44
  jmp alltraps
80105e65:	e9 cc f8 ff ff       	jmp    80105736 <alltraps>

80105e6a <vector69>:
.globl vector69
vector69:
  pushl $0
80105e6a:	6a 00                	push   $0x0
  pushl $69
80105e6c:	6a 45                	push   $0x45
  jmp alltraps
80105e6e:	e9 c3 f8 ff ff       	jmp    80105736 <alltraps>

80105e73 <vector70>:
.globl vector70
vector70:
  pushl $0
80105e73:	6a 00                	push   $0x0
  pushl $70
80105e75:	6a 46                	push   $0x46
  jmp alltraps
80105e77:	e9 ba f8 ff ff       	jmp    80105736 <alltraps>

80105e7c <vector71>:
.globl vector71
vector71:
  pushl $0
80105e7c:	6a 00                	push   $0x0
  pushl $71
80105e7e:	6a 47                	push   $0x47
  jmp alltraps
80105e80:	e9 b1 f8 ff ff       	jmp    80105736 <alltraps>

80105e85 <vector72>:
.globl vector72
vector72:
  pushl $0
80105e85:	6a 00                	push   $0x0
  pushl $72
80105e87:	6a 48                	push   $0x48
  jmp alltraps
80105e89:	e9 a8 f8 ff ff       	jmp    80105736 <alltraps>

80105e8e <vector73>:
.globl vector73
vector73:
  pushl $0
80105e8e:	6a 00                	push   $0x0
  pushl $73
80105e90:	6a 49                	push   $0x49
  jmp alltraps
80105e92:	e9 9f f8 ff ff       	jmp    80105736 <alltraps>

80105e97 <vector74>:
.globl vector74
vector74:
  pushl $0
80105e97:	6a 00                	push   $0x0
  pushl $74
80105e99:	6a 4a                	push   $0x4a
  jmp alltraps
80105e9b:	e9 96 f8 ff ff       	jmp    80105736 <alltraps>

80105ea0 <vector75>:
.globl vector75
vector75:
  pushl $0
80105ea0:	6a 00                	push   $0x0
  pushl $75
80105ea2:	6a 4b                	push   $0x4b
  jmp alltraps
80105ea4:	e9 8d f8 ff ff       	jmp    80105736 <alltraps>

80105ea9 <vector76>:
.globl vector76
vector76:
  pushl $0
80105ea9:	6a 00                	push   $0x0
  pushl $76
80105eab:	6a 4c                	push   $0x4c
  jmp alltraps
80105ead:	e9 84 f8 ff ff       	jmp    80105736 <alltraps>

80105eb2 <vector77>:
.globl vector77
vector77:
  pushl $0
80105eb2:	6a 00                	push   $0x0
  pushl $77
80105eb4:	6a 4d                	push   $0x4d
  jmp alltraps
80105eb6:	e9 7b f8 ff ff       	jmp    80105736 <alltraps>

80105ebb <vector78>:
.globl vector78
vector78:
  pushl $0
80105ebb:	6a 00                	push   $0x0
  pushl $78
80105ebd:	6a 4e                	push   $0x4e
  jmp alltraps
80105ebf:	e9 72 f8 ff ff       	jmp    80105736 <alltraps>

80105ec4 <vector79>:
.globl vector79
vector79:
  pushl $0
80105ec4:	6a 00                	push   $0x0
  pushl $79
80105ec6:	6a 4f                	push   $0x4f
  jmp alltraps
80105ec8:	e9 69 f8 ff ff       	jmp    80105736 <alltraps>

80105ecd <vector80>:
.globl vector80
vector80:
  pushl $0
80105ecd:	6a 00                	push   $0x0
  pushl $80
80105ecf:	6a 50                	push   $0x50
  jmp alltraps
80105ed1:	e9 60 f8 ff ff       	jmp    80105736 <alltraps>

80105ed6 <vector81>:
.globl vector81
vector81:
  pushl $0
80105ed6:	6a 00                	push   $0x0
  pushl $81
80105ed8:	6a 51                	push   $0x51
  jmp alltraps
80105eda:	e9 57 f8 ff ff       	jmp    80105736 <alltraps>

80105edf <vector82>:
.globl vector82
vector82:
  pushl $0
80105edf:	6a 00                	push   $0x0
  pushl $82
80105ee1:	6a 52                	push   $0x52
  jmp alltraps
80105ee3:	e9 4e f8 ff ff       	jmp    80105736 <alltraps>

80105ee8 <vector83>:
.globl vector83
vector83:
  pushl $0
80105ee8:	6a 00                	push   $0x0
  pushl $83
80105eea:	6a 53                	push   $0x53
  jmp alltraps
80105eec:	e9 45 f8 ff ff       	jmp    80105736 <alltraps>

80105ef1 <vector84>:
.globl vector84
vector84:
  pushl $0
80105ef1:	6a 00                	push   $0x0
  pushl $84
80105ef3:	6a 54                	push   $0x54
  jmp alltraps
80105ef5:	e9 3c f8 ff ff       	jmp    80105736 <alltraps>

80105efa <vector85>:
.globl vector85
vector85:
  pushl $0
80105efa:	6a 00                	push   $0x0
  pushl $85
80105efc:	6a 55                	push   $0x55
  jmp alltraps
80105efe:	e9 33 f8 ff ff       	jmp    80105736 <alltraps>

80105f03 <vector86>:
.globl vector86
vector86:
  pushl $0
80105f03:	6a 00                	push   $0x0
  pushl $86
80105f05:	6a 56                	push   $0x56
  jmp alltraps
80105f07:	e9 2a f8 ff ff       	jmp    80105736 <alltraps>

80105f0c <vector87>:
.globl vector87
vector87:
  pushl $0
80105f0c:	6a 00                	push   $0x0
  pushl $87
80105f0e:	6a 57                	push   $0x57
  jmp alltraps
80105f10:	e9 21 f8 ff ff       	jmp    80105736 <alltraps>

80105f15 <vector88>:
.globl vector88
vector88:
  pushl $0
80105f15:	6a 00                	push   $0x0
  pushl $88
80105f17:	6a 58                	push   $0x58
  jmp alltraps
80105f19:	e9 18 f8 ff ff       	jmp    80105736 <alltraps>

80105f1e <vector89>:
.globl vector89
vector89:
  pushl $0
80105f1e:	6a 00                	push   $0x0
  pushl $89
80105f20:	6a 59                	push   $0x59
  jmp alltraps
80105f22:	e9 0f f8 ff ff       	jmp    80105736 <alltraps>

80105f27 <vector90>:
.globl vector90
vector90:
  pushl $0
80105f27:	6a 00                	push   $0x0
  pushl $90
80105f29:	6a 5a                	push   $0x5a
  jmp alltraps
80105f2b:	e9 06 f8 ff ff       	jmp    80105736 <alltraps>

80105f30 <vector91>:
.globl vector91
vector91:
  pushl $0
80105f30:	6a 00                	push   $0x0
  pushl $91
80105f32:	6a 5b                	push   $0x5b
  jmp alltraps
80105f34:	e9 fd f7 ff ff       	jmp    80105736 <alltraps>

80105f39 <vector92>:
.globl vector92
vector92:
  pushl $0
80105f39:	6a 00                	push   $0x0
  pushl $92
80105f3b:	6a 5c                	push   $0x5c
  jmp alltraps
80105f3d:	e9 f4 f7 ff ff       	jmp    80105736 <alltraps>

80105f42 <vector93>:
.globl vector93
vector93:
  pushl $0
80105f42:	6a 00                	push   $0x0
  pushl $93
80105f44:	6a 5d                	push   $0x5d
  jmp alltraps
80105f46:	e9 eb f7 ff ff       	jmp    80105736 <alltraps>

80105f4b <vector94>:
.globl vector94
vector94:
  pushl $0
80105f4b:	6a 00                	push   $0x0
  pushl $94
80105f4d:	6a 5e                	push   $0x5e
  jmp alltraps
80105f4f:	e9 e2 f7 ff ff       	jmp    80105736 <alltraps>

80105f54 <vector95>:
.globl vector95
vector95:
  pushl $0
80105f54:	6a 00                	push   $0x0
  pushl $95
80105f56:	6a 5f                	push   $0x5f
  jmp alltraps
80105f58:	e9 d9 f7 ff ff       	jmp    80105736 <alltraps>

80105f5d <vector96>:
.globl vector96
vector96:
  pushl $0
80105f5d:	6a 00                	push   $0x0
  pushl $96
80105f5f:	6a 60                	push   $0x60
  jmp alltraps
80105f61:	e9 d0 f7 ff ff       	jmp    80105736 <alltraps>

80105f66 <vector97>:
.globl vector97
vector97:
  pushl $0
80105f66:	6a 00                	push   $0x0
  pushl $97
80105f68:	6a 61                	push   $0x61
  jmp alltraps
80105f6a:	e9 c7 f7 ff ff       	jmp    80105736 <alltraps>

80105f6f <vector98>:
.globl vector98
vector98:
  pushl $0
80105f6f:	6a 00                	push   $0x0
  pushl $98
80105f71:	6a 62                	push   $0x62
  jmp alltraps
80105f73:	e9 be f7 ff ff       	jmp    80105736 <alltraps>

80105f78 <vector99>:
.globl vector99
vector99:
  pushl $0
80105f78:	6a 00                	push   $0x0
  pushl $99
80105f7a:	6a 63                	push   $0x63
  jmp alltraps
80105f7c:	e9 b5 f7 ff ff       	jmp    80105736 <alltraps>

80105f81 <vector100>:
.globl vector100
vector100:
  pushl $0
80105f81:	6a 00                	push   $0x0
  pushl $100
80105f83:	6a 64                	push   $0x64
  jmp alltraps
80105f85:	e9 ac f7 ff ff       	jmp    80105736 <alltraps>

80105f8a <vector101>:
.globl vector101
vector101:
  pushl $0
80105f8a:	6a 00                	push   $0x0
  pushl $101
80105f8c:	6a 65                	push   $0x65
  jmp alltraps
80105f8e:	e9 a3 f7 ff ff       	jmp    80105736 <alltraps>

80105f93 <vector102>:
.globl vector102
vector102:
  pushl $0
80105f93:	6a 00                	push   $0x0
  pushl $102
80105f95:	6a 66                	push   $0x66
  jmp alltraps
80105f97:	e9 9a f7 ff ff       	jmp    80105736 <alltraps>

80105f9c <vector103>:
.globl vector103
vector103:
  pushl $0
80105f9c:	6a 00                	push   $0x0
  pushl $103
80105f9e:	6a 67                	push   $0x67
  jmp alltraps
80105fa0:	e9 91 f7 ff ff       	jmp    80105736 <alltraps>

80105fa5 <vector104>:
.globl vector104
vector104:
  pushl $0
80105fa5:	6a 00                	push   $0x0
  pushl $104
80105fa7:	6a 68                	push   $0x68
  jmp alltraps
80105fa9:	e9 88 f7 ff ff       	jmp    80105736 <alltraps>

80105fae <vector105>:
.globl vector105
vector105:
  pushl $0
80105fae:	6a 00                	push   $0x0
  pushl $105
80105fb0:	6a 69                	push   $0x69
  jmp alltraps
80105fb2:	e9 7f f7 ff ff       	jmp    80105736 <alltraps>

80105fb7 <vector106>:
.globl vector106
vector106:
  pushl $0
80105fb7:	6a 00                	push   $0x0
  pushl $106
80105fb9:	6a 6a                	push   $0x6a
  jmp alltraps
80105fbb:	e9 76 f7 ff ff       	jmp    80105736 <alltraps>

80105fc0 <vector107>:
.globl vector107
vector107:
  pushl $0
80105fc0:	6a 00                	push   $0x0
  pushl $107
80105fc2:	6a 6b                	push   $0x6b
  jmp alltraps
80105fc4:	e9 6d f7 ff ff       	jmp    80105736 <alltraps>

80105fc9 <vector108>:
.globl vector108
vector108:
  pushl $0
80105fc9:	6a 00                	push   $0x0
  pushl $108
80105fcb:	6a 6c                	push   $0x6c
  jmp alltraps
80105fcd:	e9 64 f7 ff ff       	jmp    80105736 <alltraps>

80105fd2 <vector109>:
.globl vector109
vector109:
  pushl $0
80105fd2:	6a 00                	push   $0x0
  pushl $109
80105fd4:	6a 6d                	push   $0x6d
  jmp alltraps
80105fd6:	e9 5b f7 ff ff       	jmp    80105736 <alltraps>

80105fdb <vector110>:
.globl vector110
vector110:
  pushl $0
80105fdb:	6a 00                	push   $0x0
  pushl $110
80105fdd:	6a 6e                	push   $0x6e
  jmp alltraps
80105fdf:	e9 52 f7 ff ff       	jmp    80105736 <alltraps>

80105fe4 <vector111>:
.globl vector111
vector111:
  pushl $0
80105fe4:	6a 00                	push   $0x0
  pushl $111
80105fe6:	6a 6f                	push   $0x6f
  jmp alltraps
80105fe8:	e9 49 f7 ff ff       	jmp    80105736 <alltraps>

80105fed <vector112>:
.globl vector112
vector112:
  pushl $0
80105fed:	6a 00                	push   $0x0
  pushl $112
80105fef:	6a 70                	push   $0x70
  jmp alltraps
80105ff1:	e9 40 f7 ff ff       	jmp    80105736 <alltraps>

80105ff6 <vector113>:
.globl vector113
vector113:
  pushl $0
80105ff6:	6a 00                	push   $0x0
  pushl $113
80105ff8:	6a 71                	push   $0x71
  jmp alltraps
80105ffa:	e9 37 f7 ff ff       	jmp    80105736 <alltraps>

80105fff <vector114>:
.globl vector114
vector114:
  pushl $0
80105fff:	6a 00                	push   $0x0
  pushl $114
80106001:	6a 72                	push   $0x72
  jmp alltraps
80106003:	e9 2e f7 ff ff       	jmp    80105736 <alltraps>

80106008 <vector115>:
.globl vector115
vector115:
  pushl $0
80106008:	6a 00                	push   $0x0
  pushl $115
8010600a:	6a 73                	push   $0x73
  jmp alltraps
8010600c:	e9 25 f7 ff ff       	jmp    80105736 <alltraps>

80106011 <vector116>:
.globl vector116
vector116:
  pushl $0
80106011:	6a 00                	push   $0x0
  pushl $116
80106013:	6a 74                	push   $0x74
  jmp alltraps
80106015:	e9 1c f7 ff ff       	jmp    80105736 <alltraps>

8010601a <vector117>:
.globl vector117
vector117:
  pushl $0
8010601a:	6a 00                	push   $0x0
  pushl $117
8010601c:	6a 75                	push   $0x75
  jmp alltraps
8010601e:	e9 13 f7 ff ff       	jmp    80105736 <alltraps>

80106023 <vector118>:
.globl vector118
vector118:
  pushl $0
80106023:	6a 00                	push   $0x0
  pushl $118
80106025:	6a 76                	push   $0x76
  jmp alltraps
80106027:	e9 0a f7 ff ff       	jmp    80105736 <alltraps>

8010602c <vector119>:
.globl vector119
vector119:
  pushl $0
8010602c:	6a 00                	push   $0x0
  pushl $119
8010602e:	6a 77                	push   $0x77
  jmp alltraps
80106030:	e9 01 f7 ff ff       	jmp    80105736 <alltraps>

80106035 <vector120>:
.globl vector120
vector120:
  pushl $0
80106035:	6a 00                	push   $0x0
  pushl $120
80106037:	6a 78                	push   $0x78
  jmp alltraps
80106039:	e9 f8 f6 ff ff       	jmp    80105736 <alltraps>

8010603e <vector121>:
.globl vector121
vector121:
  pushl $0
8010603e:	6a 00                	push   $0x0
  pushl $121
80106040:	6a 79                	push   $0x79
  jmp alltraps
80106042:	e9 ef f6 ff ff       	jmp    80105736 <alltraps>

80106047 <vector122>:
.globl vector122
vector122:
  pushl $0
80106047:	6a 00                	push   $0x0
  pushl $122
80106049:	6a 7a                	push   $0x7a
  jmp alltraps
8010604b:	e9 e6 f6 ff ff       	jmp    80105736 <alltraps>

80106050 <vector123>:
.globl vector123
vector123:
  pushl $0
80106050:	6a 00                	push   $0x0
  pushl $123
80106052:	6a 7b                	push   $0x7b
  jmp alltraps
80106054:	e9 dd f6 ff ff       	jmp    80105736 <alltraps>

80106059 <vector124>:
.globl vector124
vector124:
  pushl $0
80106059:	6a 00                	push   $0x0
  pushl $124
8010605b:	6a 7c                	push   $0x7c
  jmp alltraps
8010605d:	e9 d4 f6 ff ff       	jmp    80105736 <alltraps>

80106062 <vector125>:
.globl vector125
vector125:
  pushl $0
80106062:	6a 00                	push   $0x0
  pushl $125
80106064:	6a 7d                	push   $0x7d
  jmp alltraps
80106066:	e9 cb f6 ff ff       	jmp    80105736 <alltraps>

8010606b <vector126>:
.globl vector126
vector126:
  pushl $0
8010606b:	6a 00                	push   $0x0
  pushl $126
8010606d:	6a 7e                	push   $0x7e
  jmp alltraps
8010606f:	e9 c2 f6 ff ff       	jmp    80105736 <alltraps>

80106074 <vector127>:
.globl vector127
vector127:
  pushl $0
80106074:	6a 00                	push   $0x0
  pushl $127
80106076:	6a 7f                	push   $0x7f
  jmp alltraps
80106078:	e9 b9 f6 ff ff       	jmp    80105736 <alltraps>

8010607d <vector128>:
.globl vector128
vector128:
  pushl $0
8010607d:	6a 00                	push   $0x0
  pushl $128
8010607f:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106084:	e9 ad f6 ff ff       	jmp    80105736 <alltraps>

80106089 <vector129>:
.globl vector129
vector129:
  pushl $0
80106089:	6a 00                	push   $0x0
  pushl $129
8010608b:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106090:	e9 a1 f6 ff ff       	jmp    80105736 <alltraps>

80106095 <vector130>:
.globl vector130
vector130:
  pushl $0
80106095:	6a 00                	push   $0x0
  pushl $130
80106097:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010609c:	e9 95 f6 ff ff       	jmp    80105736 <alltraps>

801060a1 <vector131>:
.globl vector131
vector131:
  pushl $0
801060a1:	6a 00                	push   $0x0
  pushl $131
801060a3:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801060a8:	e9 89 f6 ff ff       	jmp    80105736 <alltraps>

801060ad <vector132>:
.globl vector132
vector132:
  pushl $0
801060ad:	6a 00                	push   $0x0
  pushl $132
801060af:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801060b4:	e9 7d f6 ff ff       	jmp    80105736 <alltraps>

801060b9 <vector133>:
.globl vector133
vector133:
  pushl $0
801060b9:	6a 00                	push   $0x0
  pushl $133
801060bb:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801060c0:	e9 71 f6 ff ff       	jmp    80105736 <alltraps>

801060c5 <vector134>:
.globl vector134
vector134:
  pushl $0
801060c5:	6a 00                	push   $0x0
  pushl $134
801060c7:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801060cc:	e9 65 f6 ff ff       	jmp    80105736 <alltraps>

801060d1 <vector135>:
.globl vector135
vector135:
  pushl $0
801060d1:	6a 00                	push   $0x0
  pushl $135
801060d3:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801060d8:	e9 59 f6 ff ff       	jmp    80105736 <alltraps>

801060dd <vector136>:
.globl vector136
vector136:
  pushl $0
801060dd:	6a 00                	push   $0x0
  pushl $136
801060df:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801060e4:	e9 4d f6 ff ff       	jmp    80105736 <alltraps>

801060e9 <vector137>:
.globl vector137
vector137:
  pushl $0
801060e9:	6a 00                	push   $0x0
  pushl $137
801060eb:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801060f0:	e9 41 f6 ff ff       	jmp    80105736 <alltraps>

801060f5 <vector138>:
.globl vector138
vector138:
  pushl $0
801060f5:	6a 00                	push   $0x0
  pushl $138
801060f7:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801060fc:	e9 35 f6 ff ff       	jmp    80105736 <alltraps>

80106101 <vector139>:
.globl vector139
vector139:
  pushl $0
80106101:	6a 00                	push   $0x0
  pushl $139
80106103:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106108:	e9 29 f6 ff ff       	jmp    80105736 <alltraps>

8010610d <vector140>:
.globl vector140
vector140:
  pushl $0
8010610d:	6a 00                	push   $0x0
  pushl $140
8010610f:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106114:	e9 1d f6 ff ff       	jmp    80105736 <alltraps>

80106119 <vector141>:
.globl vector141
vector141:
  pushl $0
80106119:	6a 00                	push   $0x0
  pushl $141
8010611b:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106120:	e9 11 f6 ff ff       	jmp    80105736 <alltraps>

80106125 <vector142>:
.globl vector142
vector142:
  pushl $0
80106125:	6a 00                	push   $0x0
  pushl $142
80106127:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010612c:	e9 05 f6 ff ff       	jmp    80105736 <alltraps>

80106131 <vector143>:
.globl vector143
vector143:
  pushl $0
80106131:	6a 00                	push   $0x0
  pushl $143
80106133:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106138:	e9 f9 f5 ff ff       	jmp    80105736 <alltraps>

8010613d <vector144>:
.globl vector144
vector144:
  pushl $0
8010613d:	6a 00                	push   $0x0
  pushl $144
8010613f:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106144:	e9 ed f5 ff ff       	jmp    80105736 <alltraps>

80106149 <vector145>:
.globl vector145
vector145:
  pushl $0
80106149:	6a 00                	push   $0x0
  pushl $145
8010614b:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106150:	e9 e1 f5 ff ff       	jmp    80105736 <alltraps>

80106155 <vector146>:
.globl vector146
vector146:
  pushl $0
80106155:	6a 00                	push   $0x0
  pushl $146
80106157:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010615c:	e9 d5 f5 ff ff       	jmp    80105736 <alltraps>

80106161 <vector147>:
.globl vector147
vector147:
  pushl $0
80106161:	6a 00                	push   $0x0
  pushl $147
80106163:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106168:	e9 c9 f5 ff ff       	jmp    80105736 <alltraps>

8010616d <vector148>:
.globl vector148
vector148:
  pushl $0
8010616d:	6a 00                	push   $0x0
  pushl $148
8010616f:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106174:	e9 bd f5 ff ff       	jmp    80105736 <alltraps>

80106179 <vector149>:
.globl vector149
vector149:
  pushl $0
80106179:	6a 00                	push   $0x0
  pushl $149
8010617b:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106180:	e9 b1 f5 ff ff       	jmp    80105736 <alltraps>

80106185 <vector150>:
.globl vector150
vector150:
  pushl $0
80106185:	6a 00                	push   $0x0
  pushl $150
80106187:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010618c:	e9 a5 f5 ff ff       	jmp    80105736 <alltraps>

80106191 <vector151>:
.globl vector151
vector151:
  pushl $0
80106191:	6a 00                	push   $0x0
  pushl $151
80106193:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106198:	e9 99 f5 ff ff       	jmp    80105736 <alltraps>

8010619d <vector152>:
.globl vector152
vector152:
  pushl $0
8010619d:	6a 00                	push   $0x0
  pushl $152
8010619f:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801061a4:	e9 8d f5 ff ff       	jmp    80105736 <alltraps>

801061a9 <vector153>:
.globl vector153
vector153:
  pushl $0
801061a9:	6a 00                	push   $0x0
  pushl $153
801061ab:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801061b0:	e9 81 f5 ff ff       	jmp    80105736 <alltraps>

801061b5 <vector154>:
.globl vector154
vector154:
  pushl $0
801061b5:	6a 00                	push   $0x0
  pushl $154
801061b7:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801061bc:	e9 75 f5 ff ff       	jmp    80105736 <alltraps>

801061c1 <vector155>:
.globl vector155
vector155:
  pushl $0
801061c1:	6a 00                	push   $0x0
  pushl $155
801061c3:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801061c8:	e9 69 f5 ff ff       	jmp    80105736 <alltraps>

801061cd <vector156>:
.globl vector156
vector156:
  pushl $0
801061cd:	6a 00                	push   $0x0
  pushl $156
801061cf:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801061d4:	e9 5d f5 ff ff       	jmp    80105736 <alltraps>

801061d9 <vector157>:
.globl vector157
vector157:
  pushl $0
801061d9:	6a 00                	push   $0x0
  pushl $157
801061db:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801061e0:	e9 51 f5 ff ff       	jmp    80105736 <alltraps>

801061e5 <vector158>:
.globl vector158
vector158:
  pushl $0
801061e5:	6a 00                	push   $0x0
  pushl $158
801061e7:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801061ec:	e9 45 f5 ff ff       	jmp    80105736 <alltraps>

801061f1 <vector159>:
.globl vector159
vector159:
  pushl $0
801061f1:	6a 00                	push   $0x0
  pushl $159
801061f3:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801061f8:	e9 39 f5 ff ff       	jmp    80105736 <alltraps>

801061fd <vector160>:
.globl vector160
vector160:
  pushl $0
801061fd:	6a 00                	push   $0x0
  pushl $160
801061ff:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106204:	e9 2d f5 ff ff       	jmp    80105736 <alltraps>

80106209 <vector161>:
.globl vector161
vector161:
  pushl $0
80106209:	6a 00                	push   $0x0
  pushl $161
8010620b:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106210:	e9 21 f5 ff ff       	jmp    80105736 <alltraps>

80106215 <vector162>:
.globl vector162
vector162:
  pushl $0
80106215:	6a 00                	push   $0x0
  pushl $162
80106217:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010621c:	e9 15 f5 ff ff       	jmp    80105736 <alltraps>

80106221 <vector163>:
.globl vector163
vector163:
  pushl $0
80106221:	6a 00                	push   $0x0
  pushl $163
80106223:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106228:	e9 09 f5 ff ff       	jmp    80105736 <alltraps>

8010622d <vector164>:
.globl vector164
vector164:
  pushl $0
8010622d:	6a 00                	push   $0x0
  pushl $164
8010622f:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106234:	e9 fd f4 ff ff       	jmp    80105736 <alltraps>

80106239 <vector165>:
.globl vector165
vector165:
  pushl $0
80106239:	6a 00                	push   $0x0
  pushl $165
8010623b:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106240:	e9 f1 f4 ff ff       	jmp    80105736 <alltraps>

80106245 <vector166>:
.globl vector166
vector166:
  pushl $0
80106245:	6a 00                	push   $0x0
  pushl $166
80106247:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010624c:	e9 e5 f4 ff ff       	jmp    80105736 <alltraps>

80106251 <vector167>:
.globl vector167
vector167:
  pushl $0
80106251:	6a 00                	push   $0x0
  pushl $167
80106253:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106258:	e9 d9 f4 ff ff       	jmp    80105736 <alltraps>

8010625d <vector168>:
.globl vector168
vector168:
  pushl $0
8010625d:	6a 00                	push   $0x0
  pushl $168
8010625f:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106264:	e9 cd f4 ff ff       	jmp    80105736 <alltraps>

80106269 <vector169>:
.globl vector169
vector169:
  pushl $0
80106269:	6a 00                	push   $0x0
  pushl $169
8010626b:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106270:	e9 c1 f4 ff ff       	jmp    80105736 <alltraps>

80106275 <vector170>:
.globl vector170
vector170:
  pushl $0
80106275:	6a 00                	push   $0x0
  pushl $170
80106277:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010627c:	e9 b5 f4 ff ff       	jmp    80105736 <alltraps>

80106281 <vector171>:
.globl vector171
vector171:
  pushl $0
80106281:	6a 00                	push   $0x0
  pushl $171
80106283:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106288:	e9 a9 f4 ff ff       	jmp    80105736 <alltraps>

8010628d <vector172>:
.globl vector172
vector172:
  pushl $0
8010628d:	6a 00                	push   $0x0
  pushl $172
8010628f:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106294:	e9 9d f4 ff ff       	jmp    80105736 <alltraps>

80106299 <vector173>:
.globl vector173
vector173:
  pushl $0
80106299:	6a 00                	push   $0x0
  pushl $173
8010629b:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801062a0:	e9 91 f4 ff ff       	jmp    80105736 <alltraps>

801062a5 <vector174>:
.globl vector174
vector174:
  pushl $0
801062a5:	6a 00                	push   $0x0
  pushl $174
801062a7:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801062ac:	e9 85 f4 ff ff       	jmp    80105736 <alltraps>

801062b1 <vector175>:
.globl vector175
vector175:
  pushl $0
801062b1:	6a 00                	push   $0x0
  pushl $175
801062b3:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801062b8:	e9 79 f4 ff ff       	jmp    80105736 <alltraps>

801062bd <vector176>:
.globl vector176
vector176:
  pushl $0
801062bd:	6a 00                	push   $0x0
  pushl $176
801062bf:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801062c4:	e9 6d f4 ff ff       	jmp    80105736 <alltraps>

801062c9 <vector177>:
.globl vector177
vector177:
  pushl $0
801062c9:	6a 00                	push   $0x0
  pushl $177
801062cb:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801062d0:	e9 61 f4 ff ff       	jmp    80105736 <alltraps>

801062d5 <vector178>:
.globl vector178
vector178:
  pushl $0
801062d5:	6a 00                	push   $0x0
  pushl $178
801062d7:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801062dc:	e9 55 f4 ff ff       	jmp    80105736 <alltraps>

801062e1 <vector179>:
.globl vector179
vector179:
  pushl $0
801062e1:	6a 00                	push   $0x0
  pushl $179
801062e3:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801062e8:	e9 49 f4 ff ff       	jmp    80105736 <alltraps>

801062ed <vector180>:
.globl vector180
vector180:
  pushl $0
801062ed:	6a 00                	push   $0x0
  pushl $180
801062ef:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801062f4:	e9 3d f4 ff ff       	jmp    80105736 <alltraps>

801062f9 <vector181>:
.globl vector181
vector181:
  pushl $0
801062f9:	6a 00                	push   $0x0
  pushl $181
801062fb:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106300:	e9 31 f4 ff ff       	jmp    80105736 <alltraps>

80106305 <vector182>:
.globl vector182
vector182:
  pushl $0
80106305:	6a 00                	push   $0x0
  pushl $182
80106307:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010630c:	e9 25 f4 ff ff       	jmp    80105736 <alltraps>

80106311 <vector183>:
.globl vector183
vector183:
  pushl $0
80106311:	6a 00                	push   $0x0
  pushl $183
80106313:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106318:	e9 19 f4 ff ff       	jmp    80105736 <alltraps>

8010631d <vector184>:
.globl vector184
vector184:
  pushl $0
8010631d:	6a 00                	push   $0x0
  pushl $184
8010631f:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106324:	e9 0d f4 ff ff       	jmp    80105736 <alltraps>

80106329 <vector185>:
.globl vector185
vector185:
  pushl $0
80106329:	6a 00                	push   $0x0
  pushl $185
8010632b:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106330:	e9 01 f4 ff ff       	jmp    80105736 <alltraps>

80106335 <vector186>:
.globl vector186
vector186:
  pushl $0
80106335:	6a 00                	push   $0x0
  pushl $186
80106337:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010633c:	e9 f5 f3 ff ff       	jmp    80105736 <alltraps>

80106341 <vector187>:
.globl vector187
vector187:
  pushl $0
80106341:	6a 00                	push   $0x0
  pushl $187
80106343:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106348:	e9 e9 f3 ff ff       	jmp    80105736 <alltraps>

8010634d <vector188>:
.globl vector188
vector188:
  pushl $0
8010634d:	6a 00                	push   $0x0
  pushl $188
8010634f:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106354:	e9 dd f3 ff ff       	jmp    80105736 <alltraps>

80106359 <vector189>:
.globl vector189
vector189:
  pushl $0
80106359:	6a 00                	push   $0x0
  pushl $189
8010635b:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106360:	e9 d1 f3 ff ff       	jmp    80105736 <alltraps>

80106365 <vector190>:
.globl vector190
vector190:
  pushl $0
80106365:	6a 00                	push   $0x0
  pushl $190
80106367:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010636c:	e9 c5 f3 ff ff       	jmp    80105736 <alltraps>

80106371 <vector191>:
.globl vector191
vector191:
  pushl $0
80106371:	6a 00                	push   $0x0
  pushl $191
80106373:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106378:	e9 b9 f3 ff ff       	jmp    80105736 <alltraps>

8010637d <vector192>:
.globl vector192
vector192:
  pushl $0
8010637d:	6a 00                	push   $0x0
  pushl $192
8010637f:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106384:	e9 ad f3 ff ff       	jmp    80105736 <alltraps>

80106389 <vector193>:
.globl vector193
vector193:
  pushl $0
80106389:	6a 00                	push   $0x0
  pushl $193
8010638b:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106390:	e9 a1 f3 ff ff       	jmp    80105736 <alltraps>

80106395 <vector194>:
.globl vector194
vector194:
  pushl $0
80106395:	6a 00                	push   $0x0
  pushl $194
80106397:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010639c:	e9 95 f3 ff ff       	jmp    80105736 <alltraps>

801063a1 <vector195>:
.globl vector195
vector195:
  pushl $0
801063a1:	6a 00                	push   $0x0
  pushl $195
801063a3:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801063a8:	e9 89 f3 ff ff       	jmp    80105736 <alltraps>

801063ad <vector196>:
.globl vector196
vector196:
  pushl $0
801063ad:	6a 00                	push   $0x0
  pushl $196
801063af:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801063b4:	e9 7d f3 ff ff       	jmp    80105736 <alltraps>

801063b9 <vector197>:
.globl vector197
vector197:
  pushl $0
801063b9:	6a 00                	push   $0x0
  pushl $197
801063bb:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801063c0:	e9 71 f3 ff ff       	jmp    80105736 <alltraps>

801063c5 <vector198>:
.globl vector198
vector198:
  pushl $0
801063c5:	6a 00                	push   $0x0
  pushl $198
801063c7:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801063cc:	e9 65 f3 ff ff       	jmp    80105736 <alltraps>

801063d1 <vector199>:
.globl vector199
vector199:
  pushl $0
801063d1:	6a 00                	push   $0x0
  pushl $199
801063d3:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801063d8:	e9 59 f3 ff ff       	jmp    80105736 <alltraps>

801063dd <vector200>:
.globl vector200
vector200:
  pushl $0
801063dd:	6a 00                	push   $0x0
  pushl $200
801063df:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801063e4:	e9 4d f3 ff ff       	jmp    80105736 <alltraps>

801063e9 <vector201>:
.globl vector201
vector201:
  pushl $0
801063e9:	6a 00                	push   $0x0
  pushl $201
801063eb:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801063f0:	e9 41 f3 ff ff       	jmp    80105736 <alltraps>

801063f5 <vector202>:
.globl vector202
vector202:
  pushl $0
801063f5:	6a 00                	push   $0x0
  pushl $202
801063f7:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801063fc:	e9 35 f3 ff ff       	jmp    80105736 <alltraps>

80106401 <vector203>:
.globl vector203
vector203:
  pushl $0
80106401:	6a 00                	push   $0x0
  pushl $203
80106403:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106408:	e9 29 f3 ff ff       	jmp    80105736 <alltraps>

8010640d <vector204>:
.globl vector204
vector204:
  pushl $0
8010640d:	6a 00                	push   $0x0
  pushl $204
8010640f:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106414:	e9 1d f3 ff ff       	jmp    80105736 <alltraps>

80106419 <vector205>:
.globl vector205
vector205:
  pushl $0
80106419:	6a 00                	push   $0x0
  pushl $205
8010641b:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106420:	e9 11 f3 ff ff       	jmp    80105736 <alltraps>

80106425 <vector206>:
.globl vector206
vector206:
  pushl $0
80106425:	6a 00                	push   $0x0
  pushl $206
80106427:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010642c:	e9 05 f3 ff ff       	jmp    80105736 <alltraps>

80106431 <vector207>:
.globl vector207
vector207:
  pushl $0
80106431:	6a 00                	push   $0x0
  pushl $207
80106433:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106438:	e9 f9 f2 ff ff       	jmp    80105736 <alltraps>

8010643d <vector208>:
.globl vector208
vector208:
  pushl $0
8010643d:	6a 00                	push   $0x0
  pushl $208
8010643f:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106444:	e9 ed f2 ff ff       	jmp    80105736 <alltraps>

80106449 <vector209>:
.globl vector209
vector209:
  pushl $0
80106449:	6a 00                	push   $0x0
  pushl $209
8010644b:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106450:	e9 e1 f2 ff ff       	jmp    80105736 <alltraps>

80106455 <vector210>:
.globl vector210
vector210:
  pushl $0
80106455:	6a 00                	push   $0x0
  pushl $210
80106457:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010645c:	e9 d5 f2 ff ff       	jmp    80105736 <alltraps>

80106461 <vector211>:
.globl vector211
vector211:
  pushl $0
80106461:	6a 00                	push   $0x0
  pushl $211
80106463:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106468:	e9 c9 f2 ff ff       	jmp    80105736 <alltraps>

8010646d <vector212>:
.globl vector212
vector212:
  pushl $0
8010646d:	6a 00                	push   $0x0
  pushl $212
8010646f:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106474:	e9 bd f2 ff ff       	jmp    80105736 <alltraps>

80106479 <vector213>:
.globl vector213
vector213:
  pushl $0
80106479:	6a 00                	push   $0x0
  pushl $213
8010647b:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106480:	e9 b1 f2 ff ff       	jmp    80105736 <alltraps>

80106485 <vector214>:
.globl vector214
vector214:
  pushl $0
80106485:	6a 00                	push   $0x0
  pushl $214
80106487:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010648c:	e9 a5 f2 ff ff       	jmp    80105736 <alltraps>

80106491 <vector215>:
.globl vector215
vector215:
  pushl $0
80106491:	6a 00                	push   $0x0
  pushl $215
80106493:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106498:	e9 99 f2 ff ff       	jmp    80105736 <alltraps>

8010649d <vector216>:
.globl vector216
vector216:
  pushl $0
8010649d:	6a 00                	push   $0x0
  pushl $216
8010649f:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801064a4:	e9 8d f2 ff ff       	jmp    80105736 <alltraps>

801064a9 <vector217>:
.globl vector217
vector217:
  pushl $0
801064a9:	6a 00                	push   $0x0
  pushl $217
801064ab:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801064b0:	e9 81 f2 ff ff       	jmp    80105736 <alltraps>

801064b5 <vector218>:
.globl vector218
vector218:
  pushl $0
801064b5:	6a 00                	push   $0x0
  pushl $218
801064b7:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801064bc:	e9 75 f2 ff ff       	jmp    80105736 <alltraps>

801064c1 <vector219>:
.globl vector219
vector219:
  pushl $0
801064c1:	6a 00                	push   $0x0
  pushl $219
801064c3:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801064c8:	e9 69 f2 ff ff       	jmp    80105736 <alltraps>

801064cd <vector220>:
.globl vector220
vector220:
  pushl $0
801064cd:	6a 00                	push   $0x0
  pushl $220
801064cf:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801064d4:	e9 5d f2 ff ff       	jmp    80105736 <alltraps>

801064d9 <vector221>:
.globl vector221
vector221:
  pushl $0
801064d9:	6a 00                	push   $0x0
  pushl $221
801064db:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801064e0:	e9 51 f2 ff ff       	jmp    80105736 <alltraps>

801064e5 <vector222>:
.globl vector222
vector222:
  pushl $0
801064e5:	6a 00                	push   $0x0
  pushl $222
801064e7:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801064ec:	e9 45 f2 ff ff       	jmp    80105736 <alltraps>

801064f1 <vector223>:
.globl vector223
vector223:
  pushl $0
801064f1:	6a 00                	push   $0x0
  pushl $223
801064f3:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801064f8:	e9 39 f2 ff ff       	jmp    80105736 <alltraps>

801064fd <vector224>:
.globl vector224
vector224:
  pushl $0
801064fd:	6a 00                	push   $0x0
  pushl $224
801064ff:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106504:	e9 2d f2 ff ff       	jmp    80105736 <alltraps>

80106509 <vector225>:
.globl vector225
vector225:
  pushl $0
80106509:	6a 00                	push   $0x0
  pushl $225
8010650b:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106510:	e9 21 f2 ff ff       	jmp    80105736 <alltraps>

80106515 <vector226>:
.globl vector226
vector226:
  pushl $0
80106515:	6a 00                	push   $0x0
  pushl $226
80106517:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010651c:	e9 15 f2 ff ff       	jmp    80105736 <alltraps>

80106521 <vector227>:
.globl vector227
vector227:
  pushl $0
80106521:	6a 00                	push   $0x0
  pushl $227
80106523:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106528:	e9 09 f2 ff ff       	jmp    80105736 <alltraps>

8010652d <vector228>:
.globl vector228
vector228:
  pushl $0
8010652d:	6a 00                	push   $0x0
  pushl $228
8010652f:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106534:	e9 fd f1 ff ff       	jmp    80105736 <alltraps>

80106539 <vector229>:
.globl vector229
vector229:
  pushl $0
80106539:	6a 00                	push   $0x0
  pushl $229
8010653b:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106540:	e9 f1 f1 ff ff       	jmp    80105736 <alltraps>

80106545 <vector230>:
.globl vector230
vector230:
  pushl $0
80106545:	6a 00                	push   $0x0
  pushl $230
80106547:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010654c:	e9 e5 f1 ff ff       	jmp    80105736 <alltraps>

80106551 <vector231>:
.globl vector231
vector231:
  pushl $0
80106551:	6a 00                	push   $0x0
  pushl $231
80106553:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106558:	e9 d9 f1 ff ff       	jmp    80105736 <alltraps>

8010655d <vector232>:
.globl vector232
vector232:
  pushl $0
8010655d:	6a 00                	push   $0x0
  pushl $232
8010655f:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106564:	e9 cd f1 ff ff       	jmp    80105736 <alltraps>

80106569 <vector233>:
.globl vector233
vector233:
  pushl $0
80106569:	6a 00                	push   $0x0
  pushl $233
8010656b:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106570:	e9 c1 f1 ff ff       	jmp    80105736 <alltraps>

80106575 <vector234>:
.globl vector234
vector234:
  pushl $0
80106575:	6a 00                	push   $0x0
  pushl $234
80106577:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010657c:	e9 b5 f1 ff ff       	jmp    80105736 <alltraps>

80106581 <vector235>:
.globl vector235
vector235:
  pushl $0
80106581:	6a 00                	push   $0x0
  pushl $235
80106583:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106588:	e9 a9 f1 ff ff       	jmp    80105736 <alltraps>

8010658d <vector236>:
.globl vector236
vector236:
  pushl $0
8010658d:	6a 00                	push   $0x0
  pushl $236
8010658f:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106594:	e9 9d f1 ff ff       	jmp    80105736 <alltraps>

80106599 <vector237>:
.globl vector237
vector237:
  pushl $0
80106599:	6a 00                	push   $0x0
  pushl $237
8010659b:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801065a0:	e9 91 f1 ff ff       	jmp    80105736 <alltraps>

801065a5 <vector238>:
.globl vector238
vector238:
  pushl $0
801065a5:	6a 00                	push   $0x0
  pushl $238
801065a7:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801065ac:	e9 85 f1 ff ff       	jmp    80105736 <alltraps>

801065b1 <vector239>:
.globl vector239
vector239:
  pushl $0
801065b1:	6a 00                	push   $0x0
  pushl $239
801065b3:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801065b8:	e9 79 f1 ff ff       	jmp    80105736 <alltraps>

801065bd <vector240>:
.globl vector240
vector240:
  pushl $0
801065bd:	6a 00                	push   $0x0
  pushl $240
801065bf:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801065c4:	e9 6d f1 ff ff       	jmp    80105736 <alltraps>

801065c9 <vector241>:
.globl vector241
vector241:
  pushl $0
801065c9:	6a 00                	push   $0x0
  pushl $241
801065cb:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801065d0:	e9 61 f1 ff ff       	jmp    80105736 <alltraps>

801065d5 <vector242>:
.globl vector242
vector242:
  pushl $0
801065d5:	6a 00                	push   $0x0
  pushl $242
801065d7:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801065dc:	e9 55 f1 ff ff       	jmp    80105736 <alltraps>

801065e1 <vector243>:
.globl vector243
vector243:
  pushl $0
801065e1:	6a 00                	push   $0x0
  pushl $243
801065e3:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801065e8:	e9 49 f1 ff ff       	jmp    80105736 <alltraps>

801065ed <vector244>:
.globl vector244
vector244:
  pushl $0
801065ed:	6a 00                	push   $0x0
  pushl $244
801065ef:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801065f4:	e9 3d f1 ff ff       	jmp    80105736 <alltraps>

801065f9 <vector245>:
.globl vector245
vector245:
  pushl $0
801065f9:	6a 00                	push   $0x0
  pushl $245
801065fb:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106600:	e9 31 f1 ff ff       	jmp    80105736 <alltraps>

80106605 <vector246>:
.globl vector246
vector246:
  pushl $0
80106605:	6a 00                	push   $0x0
  pushl $246
80106607:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010660c:	e9 25 f1 ff ff       	jmp    80105736 <alltraps>

80106611 <vector247>:
.globl vector247
vector247:
  pushl $0
80106611:	6a 00                	push   $0x0
  pushl $247
80106613:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106618:	e9 19 f1 ff ff       	jmp    80105736 <alltraps>

8010661d <vector248>:
.globl vector248
vector248:
  pushl $0
8010661d:	6a 00                	push   $0x0
  pushl $248
8010661f:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106624:	e9 0d f1 ff ff       	jmp    80105736 <alltraps>

80106629 <vector249>:
.globl vector249
vector249:
  pushl $0
80106629:	6a 00                	push   $0x0
  pushl $249
8010662b:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106630:	e9 01 f1 ff ff       	jmp    80105736 <alltraps>

80106635 <vector250>:
.globl vector250
vector250:
  pushl $0
80106635:	6a 00                	push   $0x0
  pushl $250
80106637:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010663c:	e9 f5 f0 ff ff       	jmp    80105736 <alltraps>

80106641 <vector251>:
.globl vector251
vector251:
  pushl $0
80106641:	6a 00                	push   $0x0
  pushl $251
80106643:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106648:	e9 e9 f0 ff ff       	jmp    80105736 <alltraps>

8010664d <vector252>:
.globl vector252
vector252:
  pushl $0
8010664d:	6a 00                	push   $0x0
  pushl $252
8010664f:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106654:	e9 dd f0 ff ff       	jmp    80105736 <alltraps>

80106659 <vector253>:
.globl vector253
vector253:
  pushl $0
80106659:	6a 00                	push   $0x0
  pushl $253
8010665b:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106660:	e9 d1 f0 ff ff       	jmp    80105736 <alltraps>

80106665 <vector254>:
.globl vector254
vector254:
  pushl $0
80106665:	6a 00                	push   $0x0
  pushl $254
80106667:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010666c:	e9 c5 f0 ff ff       	jmp    80105736 <alltraps>

80106671 <vector255>:
.globl vector255
vector255:
  pushl $0
80106671:	6a 00                	push   $0x0
  pushl $255
80106673:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106678:	e9 b9 f0 ff ff       	jmp    80105736 <alltraps>

8010667d <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010667d:	55                   	push   %ebp
8010667e:	89 e5                	mov    %esp,%ebp
80106680:	57                   	push   %edi
80106681:	56                   	push   %esi
80106682:	53                   	push   %ebx
80106683:	83 ec 0c             	sub    $0xc,%esp
80106686:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106688:	c1 ea 16             	shr    $0x16,%edx
8010668b:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
8010668e:	8b 37                	mov    (%edi),%esi
80106690:	f7 c6 01 00 00 00    	test   $0x1,%esi
80106696:	74 35                	je     801066cd <walkpgdir+0x50>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80106698:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    if (a > KERNBASE)
8010669e:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
801066a4:	77 1a                	ja     801066c0 <walkpgdir+0x43>
    return (char*)a + KERNBASE;
801066a6:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
801066ac:	c1 eb 0c             	shr    $0xc,%ebx
801066af:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
801066b5:	8d 04 9e             	lea    (%esi,%ebx,4),%eax
}
801066b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066bb:	5b                   	pop    %ebx
801066bc:	5e                   	pop    %esi
801066bd:	5f                   	pop    %edi
801066be:	5d                   	pop    %ebp
801066bf:	c3                   	ret    
        panic("P2V on address > KERNBASE");
801066c0:	83 ec 0c             	sub    $0xc,%esp
801066c3:	68 38 77 10 80       	push   $0x80107738
801066c8:	e8 7b 9c ff ff       	call   80100348 <panic>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801066cd:	85 c9                	test   %ecx,%ecx
801066cf:	74 33                	je     80106704 <walkpgdir+0x87>
801066d1:	e8 f3 b9 ff ff       	call   801020c9 <kalloc>
801066d6:	89 c6                	mov    %eax,%esi
801066d8:	85 c0                	test   %eax,%eax
801066da:	74 28                	je     80106704 <walkpgdir+0x87>
    memset(pgtab, 0, PGSIZE);
801066dc:	83 ec 04             	sub    $0x4,%esp
801066df:	68 00 10 00 00       	push   $0x1000
801066e4:	6a 00                	push   $0x0
801066e6:	50                   	push   %eax
801066e7:	e8 7e df ff ff       	call   8010466a <memset>
    if (a < (void*) KERNBASE)
801066ec:	83 c4 10             	add    $0x10,%esp
801066ef:	81 fe ff ff ff 7f    	cmp    $0x7fffffff,%esi
801066f5:	76 14                	jbe    8010670b <walkpgdir+0x8e>
    return (uint)a - KERNBASE;
801066f7:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801066fd:	83 c8 07             	or     $0x7,%eax
80106700:	89 07                	mov    %eax,(%edi)
80106702:	eb a8                	jmp    801066ac <walkpgdir+0x2f>
      return 0;
80106704:	b8 00 00 00 00       	mov    $0x0,%eax
80106709:	eb ad                	jmp    801066b8 <walkpgdir+0x3b>
        panic("V2P on address < KERNBASE "
8010670b:	83 ec 0c             	sub    $0xc,%esp
8010670e:	68 08 74 10 80       	push   $0x80107408
80106713:	e8 30 9c ff ff       	call   80100348 <panic>

80106718 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106718:	55                   	push   %ebp
80106719:	89 e5                	mov    %esp,%ebp
8010671b:	57                   	push   %edi
8010671c:	56                   	push   %esi
8010671d:	53                   	push   %ebx
8010671e:	83 ec 1c             	sub    $0x1c,%esp
80106721:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106724:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80106727:	89 d3                	mov    %edx,%ebx
80106729:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010672f:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80106733:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106739:	b9 01 00 00 00       	mov    $0x1,%ecx
8010673e:	89 da                	mov    %ebx,%edx
80106740:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106743:	e8 35 ff ff ff       	call   8010667d <walkpgdir>
80106748:	85 c0                	test   %eax,%eax
8010674a:	74 2e                	je     8010677a <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
8010674c:	f6 00 01             	testb  $0x1,(%eax)
8010674f:	75 1c                	jne    8010676d <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80106751:	89 f2                	mov    %esi,%edx
80106753:	0b 55 0c             	or     0xc(%ebp),%edx
80106756:	83 ca 01             	or     $0x1,%edx
80106759:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010675b:	39 fb                	cmp    %edi,%ebx
8010675d:	74 28                	je     80106787 <mappages+0x6f>
      break;
    a += PGSIZE;
8010675f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80106765:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010676b:	eb cc                	jmp    80106739 <mappages+0x21>
      panic("remap");
8010676d:	83 ec 0c             	sub    $0xc,%esp
80106770:	68 ec 7e 10 80       	push   $0x80107eec
80106775:	e8 ce 9b ff ff       	call   80100348 <panic>
      return -1;
8010677a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010677f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106782:	5b                   	pop    %ebx
80106783:	5e                   	pop    %esi
80106784:	5f                   	pop    %edi
80106785:	5d                   	pop    %ebp
80106786:	c3                   	ret    
  return 0;
80106787:	b8 00 00 00 00       	mov    $0x0,%eax
8010678c:	eb f1                	jmp    8010677f <mappages+0x67>

8010678e <seginit>:
{
8010678e:	55                   	push   %ebp
8010678f:	89 e5                	mov    %esp,%ebp
80106791:	57                   	push   %edi
80106792:	56                   	push   %esi
80106793:	53                   	push   %ebx
80106794:	83 ec 1c             	sub    $0x1c,%esp
  c = &cpus[cpuid()];
80106797:	e8 b3 cc ff ff       	call   8010344f <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010679c:	69 f8 b4 00 00 00    	imul   $0xb4,%eax,%edi
801067a2:	66 c7 87 18 28 11 80 	movw   $0xffff,-0x7feed7e8(%edi)
801067a9:	ff ff 
801067ab:	66 c7 87 1a 28 11 80 	movw   $0x0,-0x7feed7e6(%edi)
801067b2:	00 00 
801067b4:	c6 87 1c 28 11 80 00 	movb   $0x0,-0x7feed7e4(%edi)
801067bb:	0f b6 8f 1d 28 11 80 	movzbl -0x7feed7e3(%edi),%ecx
801067c2:	83 e1 f0             	and    $0xfffffff0,%ecx
801067c5:	89 ce                	mov    %ecx,%esi
801067c7:	83 ce 0a             	or     $0xa,%esi
801067ca:	89 f2                	mov    %esi,%edx
801067cc:	88 97 1d 28 11 80    	mov    %dl,-0x7feed7e3(%edi)
801067d2:	83 c9 1a             	or     $0x1a,%ecx
801067d5:	88 8f 1d 28 11 80    	mov    %cl,-0x7feed7e3(%edi)
801067db:	83 e1 9f             	and    $0xffffff9f,%ecx
801067de:	88 8f 1d 28 11 80    	mov    %cl,-0x7feed7e3(%edi)
801067e4:	83 c9 80             	or     $0xffffff80,%ecx
801067e7:	88 8f 1d 28 11 80    	mov    %cl,-0x7feed7e3(%edi)
801067ed:	0f b6 8f 1e 28 11 80 	movzbl -0x7feed7e2(%edi),%ecx
801067f4:	83 c9 0f             	or     $0xf,%ecx
801067f7:	88 8f 1e 28 11 80    	mov    %cl,-0x7feed7e2(%edi)
801067fd:	89 ce                	mov    %ecx,%esi
801067ff:	83 e6 ef             	and    $0xffffffef,%esi
80106802:	89 f2                	mov    %esi,%edx
80106804:	88 97 1e 28 11 80    	mov    %dl,-0x7feed7e2(%edi)
8010680a:	83 e1 cf             	and    $0xffffffcf,%ecx
8010680d:	88 8f 1e 28 11 80    	mov    %cl,-0x7feed7e2(%edi)
80106813:	89 ce                	mov    %ecx,%esi
80106815:	83 ce 40             	or     $0x40,%esi
80106818:	89 f2                	mov    %esi,%edx
8010681a:	88 97 1e 28 11 80    	mov    %dl,-0x7feed7e2(%edi)
80106820:	83 c9 c0             	or     $0xffffffc0,%ecx
80106823:	88 8f 1e 28 11 80    	mov    %cl,-0x7feed7e2(%edi)
80106829:	c6 87 1f 28 11 80 00 	movb   $0x0,-0x7feed7e1(%edi)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106830:	66 c7 87 20 28 11 80 	movw   $0xffff,-0x7feed7e0(%edi)
80106837:	ff ff 
80106839:	66 c7 87 22 28 11 80 	movw   $0x0,-0x7feed7de(%edi)
80106840:	00 00 
80106842:	c6 87 24 28 11 80 00 	movb   $0x0,-0x7feed7dc(%edi)
80106849:	0f b6 8f 25 28 11 80 	movzbl -0x7feed7db(%edi),%ecx
80106850:	83 e1 f0             	and    $0xfffffff0,%ecx
80106853:	89 ce                	mov    %ecx,%esi
80106855:	83 ce 02             	or     $0x2,%esi
80106858:	89 f2                	mov    %esi,%edx
8010685a:	88 97 25 28 11 80    	mov    %dl,-0x7feed7db(%edi)
80106860:	83 c9 12             	or     $0x12,%ecx
80106863:	88 8f 25 28 11 80    	mov    %cl,-0x7feed7db(%edi)
80106869:	83 e1 9f             	and    $0xffffff9f,%ecx
8010686c:	88 8f 25 28 11 80    	mov    %cl,-0x7feed7db(%edi)
80106872:	83 c9 80             	or     $0xffffff80,%ecx
80106875:	88 8f 25 28 11 80    	mov    %cl,-0x7feed7db(%edi)
8010687b:	0f b6 8f 26 28 11 80 	movzbl -0x7feed7da(%edi),%ecx
80106882:	83 c9 0f             	or     $0xf,%ecx
80106885:	88 8f 26 28 11 80    	mov    %cl,-0x7feed7da(%edi)
8010688b:	89 ce                	mov    %ecx,%esi
8010688d:	83 e6 ef             	and    $0xffffffef,%esi
80106890:	89 f2                	mov    %esi,%edx
80106892:	88 97 26 28 11 80    	mov    %dl,-0x7feed7da(%edi)
80106898:	83 e1 cf             	and    $0xffffffcf,%ecx
8010689b:	88 8f 26 28 11 80    	mov    %cl,-0x7feed7da(%edi)
801068a1:	89 ce                	mov    %ecx,%esi
801068a3:	83 ce 40             	or     $0x40,%esi
801068a6:	89 f2                	mov    %esi,%edx
801068a8:	88 97 26 28 11 80    	mov    %dl,-0x7feed7da(%edi)
801068ae:	83 c9 c0             	or     $0xffffffc0,%ecx
801068b1:	88 8f 26 28 11 80    	mov    %cl,-0x7feed7da(%edi)
801068b7:	c6 87 27 28 11 80 00 	movb   $0x0,-0x7feed7d9(%edi)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801068be:	66 c7 87 28 28 11 80 	movw   $0xffff,-0x7feed7d8(%edi)
801068c5:	ff ff 
801068c7:	66 c7 87 2a 28 11 80 	movw   $0x0,-0x7feed7d6(%edi)
801068ce:	00 00 
801068d0:	c6 87 2c 28 11 80 00 	movb   $0x0,-0x7feed7d4(%edi)
801068d7:	0f b6 9f 2d 28 11 80 	movzbl -0x7feed7d3(%edi),%ebx
801068de:	83 e3 f0             	and    $0xfffffff0,%ebx
801068e1:	89 de                	mov    %ebx,%esi
801068e3:	83 ce 0a             	or     $0xa,%esi
801068e6:	89 f2                	mov    %esi,%edx
801068e8:	88 97 2d 28 11 80    	mov    %dl,-0x7feed7d3(%edi)
801068ee:	89 de                	mov    %ebx,%esi
801068f0:	83 ce 1a             	or     $0x1a,%esi
801068f3:	89 f2                	mov    %esi,%edx
801068f5:	88 97 2d 28 11 80    	mov    %dl,-0x7feed7d3(%edi)
801068fb:	83 cb 7a             	or     $0x7a,%ebx
801068fe:	88 9f 2d 28 11 80    	mov    %bl,-0x7feed7d3(%edi)
80106904:	c6 87 2d 28 11 80 fa 	movb   $0xfa,-0x7feed7d3(%edi)
8010690b:	0f b6 9f 2e 28 11 80 	movzbl -0x7feed7d2(%edi),%ebx
80106912:	83 cb 0f             	or     $0xf,%ebx
80106915:	88 9f 2e 28 11 80    	mov    %bl,-0x7feed7d2(%edi)
8010691b:	89 de                	mov    %ebx,%esi
8010691d:	83 e6 ef             	and    $0xffffffef,%esi
80106920:	89 f2                	mov    %esi,%edx
80106922:	88 97 2e 28 11 80    	mov    %dl,-0x7feed7d2(%edi)
80106928:	83 e3 cf             	and    $0xffffffcf,%ebx
8010692b:	88 9f 2e 28 11 80    	mov    %bl,-0x7feed7d2(%edi)
80106931:	89 de                	mov    %ebx,%esi
80106933:	83 ce 40             	or     $0x40,%esi
80106936:	89 f2                	mov    %esi,%edx
80106938:	88 97 2e 28 11 80    	mov    %dl,-0x7feed7d2(%edi)
8010693e:	83 cb c0             	or     $0xffffffc0,%ebx
80106941:	88 9f 2e 28 11 80    	mov    %bl,-0x7feed7d2(%edi)
80106947:	c6 87 2f 28 11 80 00 	movb   $0x0,-0x7feed7d1(%edi)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010694e:	66 c7 87 30 28 11 80 	movw   $0xffff,-0x7feed7d0(%edi)
80106955:	ff ff 
80106957:	66 c7 87 32 28 11 80 	movw   $0x0,-0x7feed7ce(%edi)
8010695e:	00 00 
80106960:	c6 87 34 28 11 80 00 	movb   $0x0,-0x7feed7cc(%edi)
80106967:	0f b6 9f 35 28 11 80 	movzbl -0x7feed7cb(%edi),%ebx
8010696e:	83 e3 f0             	and    $0xfffffff0,%ebx
80106971:	89 de                	mov    %ebx,%esi
80106973:	83 ce 02             	or     $0x2,%esi
80106976:	89 f2                	mov    %esi,%edx
80106978:	88 97 35 28 11 80    	mov    %dl,-0x7feed7cb(%edi)
8010697e:	89 de                	mov    %ebx,%esi
80106980:	83 ce 12             	or     $0x12,%esi
80106983:	89 f2                	mov    %esi,%edx
80106985:	88 97 35 28 11 80    	mov    %dl,-0x7feed7cb(%edi)
8010698b:	83 cb 72             	or     $0x72,%ebx
8010698e:	88 9f 35 28 11 80    	mov    %bl,-0x7feed7cb(%edi)
80106994:	c6 87 35 28 11 80 f2 	movb   $0xf2,-0x7feed7cb(%edi)
8010699b:	0f b6 9f 36 28 11 80 	movzbl -0x7feed7ca(%edi),%ebx
801069a2:	83 cb 0f             	or     $0xf,%ebx
801069a5:	88 9f 36 28 11 80    	mov    %bl,-0x7feed7ca(%edi)
801069ab:	89 de                	mov    %ebx,%esi
801069ad:	83 e6 ef             	and    $0xffffffef,%esi
801069b0:	89 f2                	mov    %esi,%edx
801069b2:	88 97 36 28 11 80    	mov    %dl,-0x7feed7ca(%edi)
801069b8:	83 e3 cf             	and    $0xffffffcf,%ebx
801069bb:	88 9f 36 28 11 80    	mov    %bl,-0x7feed7ca(%edi)
801069c1:	89 de                	mov    %ebx,%esi
801069c3:	83 ce 40             	or     $0x40,%esi
801069c6:	89 f2                	mov    %esi,%edx
801069c8:	88 97 36 28 11 80    	mov    %dl,-0x7feed7ca(%edi)
801069ce:	83 cb c0             	or     $0xffffffc0,%ebx
801069d1:	88 9f 36 28 11 80    	mov    %bl,-0x7feed7ca(%edi)
801069d7:	c6 87 37 28 11 80 00 	movb   $0x0,-0x7feed7c9(%edi)
  lgdt(c->gdt, sizeof(c->gdt));
801069de:	8d 97 10 28 11 80    	lea    -0x7feed7f0(%edi),%edx
  pd[0] = size-1;
801069e4:	66 c7 45 e2 2f 00    	movw   $0x2f,-0x1e(%ebp)
  pd[1] = (uint)p;
801069ea:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
  pd[2] = (uint)p >> 16;
801069ee:	c1 ea 10             	shr    $0x10,%edx
801069f1:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801069f5:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801069f8:	0f 01 10             	lgdtl  (%eax)
}
801069fb:	83 c4 1c             	add    $0x1c,%esp
801069fe:	5b                   	pop    %ebx
801069ff:	5e                   	pop    %esi
80106a00:	5f                   	pop    %edi
80106a01:	5d                   	pop    %ebp
80106a02:	c3                   	ret    

80106a03 <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106a03:	a1 64 63 11 80       	mov    0x80116364,%eax
    if (a < (void*) KERNBASE)
80106a08:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80106a0d:	76 09                	jbe    80106a18 <switchkvm+0x15>
    return (uint)a - KERNBASE;
80106a0f:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106a14:	0f 22 d8             	mov    %eax,%cr3
80106a17:	c3                   	ret    
{
80106a18:	55                   	push   %ebp
80106a19:	89 e5                	mov    %esp,%ebp
80106a1b:	83 ec 14             	sub    $0x14,%esp
        panic("V2P on address < KERNBASE "
80106a1e:	68 08 74 10 80       	push   $0x80107408
80106a23:	e8 20 99 ff ff       	call   80100348 <panic>

80106a28 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80106a28:	55                   	push   %ebp
80106a29:	89 e5                	mov    %esp,%ebp
80106a2b:	57                   	push   %edi
80106a2c:	56                   	push   %esi
80106a2d:	53                   	push   %ebx
80106a2e:	83 ec 1c             	sub    $0x1c,%esp
80106a31:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106a34:	85 f6                	test   %esi,%esi
80106a36:	0f 84 2c 01 00 00    	je     80106b68 <switchuvm+0x140>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106a3c:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80106a40:	0f 84 2f 01 00 00    	je     80106b75 <switchuvm+0x14d>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80106a46:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80106a4a:	0f 84 32 01 00 00    	je     80106b82 <switchuvm+0x15a>
    panic("switchuvm: no pgdir");

  pushcli();
80106a50:	e8 8e da ff ff       	call   801044e3 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106a55:	e8 99 c9 ff ff       	call   801033f3 <mycpu>
80106a5a:	89 c3                	mov    %eax,%ebx
80106a5c:	e8 92 c9 ff ff       	call   801033f3 <mycpu>
80106a61:	8d 78 08             	lea    0x8(%eax),%edi
80106a64:	e8 8a c9 ff ff       	call   801033f3 <mycpu>
80106a69:	83 c0 08             	add    $0x8,%eax
80106a6c:	c1 e8 10             	shr    $0x10,%eax
80106a6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106a72:	e8 7c c9 ff ff       	call   801033f3 <mycpu>
80106a77:	83 c0 08             	add    $0x8,%eax
80106a7a:	c1 e8 18             	shr    $0x18,%eax
80106a7d:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106a84:	67 00 
80106a86:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106a8d:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80106a91:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106a97:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80106a9e:	83 e2 f0             	and    $0xfffffff0,%edx
80106aa1:	89 d1                	mov    %edx,%ecx
80106aa3:	83 c9 09             	or     $0x9,%ecx
80106aa6:	88 8b 9d 00 00 00    	mov    %cl,0x9d(%ebx)
80106aac:	83 ca 19             	or     $0x19,%edx
80106aaf:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106ab5:	83 e2 9f             	and    $0xffffff9f,%edx
80106ab8:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106abe:	83 ca 80             	or     $0xffffff80,%edx
80106ac1:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106ac7:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80106ace:	89 d1                	mov    %edx,%ecx
80106ad0:	83 e1 f0             	and    $0xfffffff0,%ecx
80106ad3:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
80106ad9:	89 d1                	mov    %edx,%ecx
80106adb:	83 e1 e0             	and    $0xffffffe0,%ecx
80106ade:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
80106ae4:	83 e2 c0             	and    $0xffffffc0,%edx
80106ae7:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80106aed:	83 ca 40             	or     $0x40,%edx
80106af0:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80106af6:	83 e2 7f             	and    $0x7f,%edx
80106af9:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80106aff:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106b05:	e8 e9 c8 ff ff       	call   801033f3 <mycpu>
80106b0a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80106b11:	83 e2 ef             	and    $0xffffffef,%edx
80106b14:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106b1a:	e8 d4 c8 ff ff       	call   801033f3 <mycpu>
80106b1f:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106b25:	8b 5e 08             	mov    0x8(%esi),%ebx
80106b28:	e8 c6 c8 ff ff       	call   801033f3 <mycpu>
80106b2d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106b33:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106b36:	e8 b8 c8 ff ff       	call   801033f3 <mycpu>
80106b3b:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106b41:	b8 28 00 00 00       	mov    $0x28,%eax
80106b46:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106b49:	8b 46 04             	mov    0x4(%esi),%eax
    if (a < (void*) KERNBASE)
80106b4c:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80106b51:	76 3c                	jbe    80106b8f <switchuvm+0x167>
    return (uint)a - KERNBASE;
80106b53:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106b58:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80106b5b:	e8 bf d9 ff ff       	call   8010451f <popcli>
}
80106b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b63:	5b                   	pop    %ebx
80106b64:	5e                   	pop    %esi
80106b65:	5f                   	pop    %edi
80106b66:	5d                   	pop    %ebp
80106b67:	c3                   	ret    
    panic("switchuvm: no process");
80106b68:	83 ec 0c             	sub    $0xc,%esp
80106b6b:	68 f2 7e 10 80       	push   $0x80107ef2
80106b70:	e8 d3 97 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
80106b75:	83 ec 0c             	sub    $0xc,%esp
80106b78:	68 08 7f 10 80       	push   $0x80107f08
80106b7d:	e8 c6 97 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
80106b82:	83 ec 0c             	sub    $0xc,%esp
80106b85:	68 1d 7f 10 80       	push   $0x80107f1d
80106b8a:	e8 b9 97 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
80106b8f:	83 ec 0c             	sub    $0xc,%esp
80106b92:	68 08 74 10 80       	push   $0x80107408
80106b97:	e8 ac 97 ff ff       	call   80100348 <panic>

80106b9c <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80106b9c:	55                   	push   %ebp
80106b9d:	89 e5                	mov    %esp,%ebp
80106b9f:	56                   	push   %esi
80106ba0:	53                   	push   %ebx
80106ba1:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80106ba4:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106baa:	77 57                	ja     80106c03 <inituvm+0x67>
    panic("inituvm: more than a page");
  mem = kalloc();
80106bac:	e8 18 b5 ff ff       	call   801020c9 <kalloc>
80106bb1:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106bb3:	83 ec 04             	sub    $0x4,%esp
80106bb6:	68 00 10 00 00       	push   $0x1000
80106bbb:	6a 00                	push   $0x0
80106bbd:	50                   	push   %eax
80106bbe:	e8 a7 da ff ff       	call   8010466a <memset>
    if (a < (void*) KERNBASE)
80106bc3:	83 c4 10             	add    $0x10,%esp
80106bc6:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106bcc:	76 42                	jbe    80106c10 <inituvm+0x74>
    return (uint)a - KERNBASE;
80106bce:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106bd4:	83 ec 08             	sub    $0x8,%esp
80106bd7:	6a 06                	push   $0x6
80106bd9:	50                   	push   %eax
80106bda:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106bdf:	ba 00 00 00 00       	mov    $0x0,%edx
80106be4:	8b 45 08             	mov    0x8(%ebp),%eax
80106be7:	e8 2c fb ff ff       	call   80106718 <mappages>
  memmove(mem, init, sz);
80106bec:	83 c4 0c             	add    $0xc,%esp
80106bef:	56                   	push   %esi
80106bf0:	ff 75 0c             	push   0xc(%ebp)
80106bf3:	53                   	push   %ebx
80106bf4:	e8 e9 da ff ff       	call   801046e2 <memmove>
}
80106bf9:	83 c4 10             	add    $0x10,%esp
80106bfc:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106bff:	5b                   	pop    %ebx
80106c00:	5e                   	pop    %esi
80106c01:	5d                   	pop    %ebp
80106c02:	c3                   	ret    
    panic("inituvm: more than a page");
80106c03:	83 ec 0c             	sub    $0xc,%esp
80106c06:	68 31 7f 10 80       	push   $0x80107f31
80106c0b:	e8 38 97 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
80106c10:	83 ec 0c             	sub    $0xc,%esp
80106c13:	68 08 74 10 80       	push   $0x80107408
80106c18:	e8 2b 97 ff ff       	call   80100348 <panic>

80106c1d <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106c1d:	55                   	push   %ebp
80106c1e:	89 e5                	mov    %esp,%ebp
80106c20:	57                   	push   %edi
80106c21:	56                   	push   %esi
80106c22:	53                   	push   %ebx
80106c23:	83 ec 0c             	sub    $0xc,%esp
80106c26:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106c29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80106c2c:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
80106c32:	74 43                	je     80106c77 <loaduvm+0x5a>
    panic("loaduvm: addr must be page aligned");
80106c34:	83 ec 0c             	sub    $0xc,%esp
80106c37:	68 ec 7f 10 80       	push   $0x80107fec
80106c3c:	e8 07 97 ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106c41:	83 ec 0c             	sub    $0xc,%esp
80106c44:	68 4b 7f 10 80       	push   $0x80107f4b
80106c49:	e8 fa 96 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106c4e:	89 da                	mov    %ebx,%edx
80106c50:	03 55 14             	add    0x14(%ebp),%edx
    if (a > KERNBASE)
80106c53:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106c58:	77 51                	ja     80106cab <loaduvm+0x8e>
    return (char*)a + KERNBASE;
80106c5a:	05 00 00 00 80       	add    $0x80000000,%eax
80106c5f:	56                   	push   %esi
80106c60:	52                   	push   %edx
80106c61:	50                   	push   %eax
80106c62:	ff 75 10             	push   0x10(%ebp)
80106c65:	e8 f7 aa ff ff       	call   80101761 <readi>
80106c6a:	83 c4 10             	add    $0x10,%esp
80106c6d:	39 f0                	cmp    %esi,%eax
80106c6f:	75 54                	jne    80106cc5 <loaduvm+0xa8>
  for(i = 0; i < sz; i += PGSIZE){
80106c71:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106c77:	39 fb                	cmp    %edi,%ebx
80106c79:	73 3d                	jae    80106cb8 <loaduvm+0x9b>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106c7b:	89 da                	mov    %ebx,%edx
80106c7d:	03 55 0c             	add    0xc(%ebp),%edx
80106c80:	b9 00 00 00 00       	mov    $0x0,%ecx
80106c85:	8b 45 08             	mov    0x8(%ebp),%eax
80106c88:	e8 f0 f9 ff ff       	call   8010667d <walkpgdir>
80106c8d:	85 c0                	test   %eax,%eax
80106c8f:	74 b0                	je     80106c41 <loaduvm+0x24>
    pa = PTE_ADDR(*pte);
80106c91:	8b 00                	mov    (%eax),%eax
80106c93:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106c98:	89 fe                	mov    %edi,%esi
80106c9a:	29 de                	sub    %ebx,%esi
80106c9c:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106ca2:	76 aa                	jbe    80106c4e <loaduvm+0x31>
      n = PGSIZE;
80106ca4:	be 00 10 00 00       	mov    $0x1000,%esi
80106ca9:	eb a3                	jmp    80106c4e <loaduvm+0x31>
        panic("P2V on address > KERNBASE");
80106cab:	83 ec 0c             	sub    $0xc,%esp
80106cae:	68 38 77 10 80       	push   $0x80107738
80106cb3:	e8 90 96 ff ff       	call   80100348 <panic>
      return -1;
  }
  return 0;
80106cb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106cc0:	5b                   	pop    %ebx
80106cc1:	5e                   	pop    %esi
80106cc2:	5f                   	pop    %edi
80106cc3:	5d                   	pop    %ebp
80106cc4:	c3                   	ret    
      return -1;
80106cc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cca:	eb f1                	jmp    80106cbd <loaduvm+0xa0>

80106ccc <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106ccc:	55                   	push   %ebp
80106ccd:	89 e5                	mov    %esp,%ebp
80106ccf:	57                   	push   %edi
80106cd0:	56                   	push   %esi
80106cd1:	53                   	push   %ebx
80106cd2:	83 ec 0c             	sub    $0xc,%esp
80106cd5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106cd8:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106cdb:	73 11                	jae    80106cee <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106cdd:	8b 45 10             	mov    0x10(%ebp),%eax
80106ce0:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106ce6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106cec:	eb 19                	jmp    80106d07 <deallocuvm+0x3b>
    return oldsz;
80106cee:	89 f8                	mov    %edi,%eax
80106cf0:	eb 78                	jmp    80106d6a <deallocuvm+0x9e>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106cf2:	c1 eb 16             	shr    $0x16,%ebx
80106cf5:	83 c3 01             	add    $0x1,%ebx
80106cf8:	c1 e3 16             	shl    $0x16,%ebx
80106cfb:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106d01:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106d07:	39 fb                	cmp    %edi,%ebx
80106d09:	73 5c                	jae    80106d67 <deallocuvm+0x9b>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106d0b:	b9 00 00 00 00       	mov    $0x0,%ecx
80106d10:	89 da                	mov    %ebx,%edx
80106d12:	8b 45 08             	mov    0x8(%ebp),%eax
80106d15:	e8 63 f9 ff ff       	call   8010667d <walkpgdir>
80106d1a:	89 c6                	mov    %eax,%esi
    if(!pte)
80106d1c:	85 c0                	test   %eax,%eax
80106d1e:	74 d2                	je     80106cf2 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106d20:	8b 00                	mov    (%eax),%eax
80106d22:	a8 01                	test   $0x1,%al
80106d24:	74 db                	je     80106d01 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106d26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106d2b:	74 20                	je     80106d4d <deallocuvm+0x81>
    if (a > KERNBASE)
80106d2d:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106d32:	77 26                	ja     80106d5a <deallocuvm+0x8e>
    return (char*)a + KERNBASE;
80106d34:	05 00 00 00 80       	add    $0x80000000,%eax
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
80106d39:	83 ec 0c             	sub    $0xc,%esp
80106d3c:	50                   	push   %eax
80106d3d:	e8 4a b2 ff ff       	call   80101f8c <kfree>
      *pte = 0;
80106d42:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106d48:	83 c4 10             	add    $0x10,%esp
80106d4b:	eb b4                	jmp    80106d01 <deallocuvm+0x35>
        panic("kfree");
80106d4d:	83 ec 0c             	sub    $0xc,%esp
80106d50:	68 96 74 10 80       	push   $0x80107496
80106d55:	e8 ee 95 ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
80106d5a:	83 ec 0c             	sub    $0xc,%esp
80106d5d:	68 38 77 10 80       	push   $0x80107738
80106d62:	e8 e1 95 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106d67:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106d6d:	5b                   	pop    %ebx
80106d6e:	5e                   	pop    %esi
80106d6f:	5f                   	pop    %edi
80106d70:	5d                   	pop    %ebp
80106d71:	c3                   	ret    

80106d72 <allocuvm>:
{
80106d72:	55                   	push   %ebp
80106d73:	89 e5                	mov    %esp,%ebp
80106d75:	57                   	push   %edi
80106d76:	56                   	push   %esi
80106d77:	53                   	push   %ebx
80106d78:	83 ec 1c             	sub    $0x1c,%esp
80106d7b:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
80106d7e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106d81:	85 ff                	test   %edi,%edi
80106d83:	0f 88 d9 00 00 00    	js     80106e62 <allocuvm+0xf0>
  if(newsz < oldsz)
80106d89:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106d8c:	72 67                	jb     80106df5 <allocuvm+0x83>
  a = PGROUNDUP(oldsz);
80106d8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d91:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
80106d97:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80106d9d:	39 fe                	cmp    %edi,%esi
80106d9f:	0f 83 c4 00 00 00    	jae    80106e69 <allocuvm+0xf7>
    mem = kalloc();
80106da5:	e8 1f b3 ff ff       	call   801020c9 <kalloc>
80106daa:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106dac:	85 c0                	test   %eax,%eax
80106dae:	74 4d                	je     80106dfd <allocuvm+0x8b>
    memset(mem, 0, PGSIZE);
80106db0:	83 ec 04             	sub    $0x4,%esp
80106db3:	68 00 10 00 00       	push   $0x1000
80106db8:	6a 00                	push   $0x0
80106dba:	50                   	push   %eax
80106dbb:	e8 aa d8 ff ff       	call   8010466a <memset>
    if (a < (void*) KERNBASE)
80106dc0:	83 c4 10             	add    $0x10,%esp
80106dc3:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106dc9:	76 5a                	jbe    80106e25 <allocuvm+0xb3>
    return (uint)a - KERNBASE;
80106dcb:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106dd1:	83 ec 08             	sub    $0x8,%esp
80106dd4:	6a 06                	push   $0x6
80106dd6:	50                   	push   %eax
80106dd7:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106ddc:	89 f2                	mov    %esi,%edx
80106dde:	8b 45 08             	mov    0x8(%ebp),%eax
80106de1:	e8 32 f9 ff ff       	call   80106718 <mappages>
80106de6:	83 c4 10             	add    $0x10,%esp
80106de9:	85 c0                	test   %eax,%eax
80106deb:	78 45                	js     80106e32 <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
80106ded:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106df3:	eb a8                	jmp    80106d9d <allocuvm+0x2b>
    return oldsz;
80106df5:	8b 45 0c             	mov    0xc(%ebp),%eax
80106df8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106dfb:	eb 6c                	jmp    80106e69 <allocuvm+0xf7>
      cprintf("allocuvm out of memory\n");
80106dfd:	83 ec 0c             	sub    $0xc,%esp
80106e00:	68 69 7f 10 80       	push   $0x80107f69
80106e05:	e8 fd 97 ff ff       	call   80100607 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106e0a:	83 c4 0c             	add    $0xc,%esp
80106e0d:	ff 75 0c             	push   0xc(%ebp)
80106e10:	57                   	push   %edi
80106e11:	ff 75 08             	push   0x8(%ebp)
80106e14:	e8 b3 fe ff ff       	call   80106ccc <deallocuvm>
      return 0;
80106e19:	83 c4 10             	add    $0x10,%esp
80106e1c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106e23:	eb 44                	jmp    80106e69 <allocuvm+0xf7>
        panic("V2P on address < KERNBASE "
80106e25:	83 ec 0c             	sub    $0xc,%esp
80106e28:	68 08 74 10 80       	push   $0x80107408
80106e2d:	e8 16 95 ff ff       	call   80100348 <panic>
      cprintf("allocuvm out of memory (2)\n");
80106e32:	83 ec 0c             	sub    $0xc,%esp
80106e35:	68 81 7f 10 80       	push   $0x80107f81
80106e3a:	e8 c8 97 ff ff       	call   80100607 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106e3f:	83 c4 0c             	add    $0xc,%esp
80106e42:	ff 75 0c             	push   0xc(%ebp)
80106e45:	57                   	push   %edi
80106e46:	ff 75 08             	push   0x8(%ebp)
80106e49:	e8 7e fe ff ff       	call   80106ccc <deallocuvm>
      kfree(mem);
80106e4e:	89 1c 24             	mov    %ebx,(%esp)
80106e51:	e8 36 b1 ff ff       	call   80101f8c <kfree>
      return 0;
80106e56:	83 c4 10             	add    $0x10,%esp
80106e59:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106e60:	eb 07                	jmp    80106e69 <allocuvm+0xf7>
    return 0;
80106e62:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106e69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106e6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e6f:	5b                   	pop    %ebx
80106e70:	5e                   	pop    %esi
80106e71:	5f                   	pop    %edi
80106e72:	5d                   	pop    %ebp
80106e73:	c3                   	ret    

80106e74 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106e74:	55                   	push   %ebp
80106e75:	89 e5                	mov    %esp,%ebp
80106e77:	56                   	push   %esi
80106e78:	53                   	push   %ebx
80106e79:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106e7c:	85 f6                	test   %esi,%esi
80106e7e:	74 1a                	je     80106e9a <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
80106e80:	83 ec 04             	sub    $0x4,%esp
80106e83:	6a 00                	push   $0x0
80106e85:	68 00 00 00 80       	push   $0x80000000
80106e8a:	56                   	push   %esi
80106e8b:	e8 3c fe ff ff       	call   80106ccc <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80106e90:	83 c4 10             	add    $0x10,%esp
80106e93:	bb 00 00 00 00       	mov    $0x0,%ebx
80106e98:	eb 21                	jmp    80106ebb <freevm+0x47>
    panic("freevm: no pgdir");
80106e9a:	83 ec 0c             	sub    $0xc,%esp
80106e9d:	68 9d 7f 10 80       	push   $0x80107f9d
80106ea2:	e8 a1 94 ff ff       	call   80100348 <panic>
    return (char*)a + KERNBASE;
80106ea7:	05 00 00 00 80       	add    $0x80000000,%eax
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
80106eac:	83 ec 0c             	sub    $0xc,%esp
80106eaf:	50                   	push   %eax
80106eb0:	e8 d7 b0 ff ff       	call   80101f8c <kfree>
80106eb5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80106eb8:	83 c3 01             	add    $0x1,%ebx
80106ebb:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106ec1:	77 20                	ja     80106ee3 <freevm+0x6f>
    if(pgdir[i] & PTE_P){
80106ec3:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106ec6:	a8 01                	test   $0x1,%al
80106ec8:	74 ee                	je     80106eb8 <freevm+0x44>
80106eca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
80106ecf:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106ed4:	76 d1                	jbe    80106ea7 <freevm+0x33>
        panic("P2V on address > KERNBASE");
80106ed6:	83 ec 0c             	sub    $0xc,%esp
80106ed9:	68 38 77 10 80       	push   $0x80107738
80106ede:	e8 65 94 ff ff       	call   80100348 <panic>
    }
  }
  kfree((char*)pgdir);
80106ee3:	83 ec 0c             	sub    $0xc,%esp
80106ee6:	56                   	push   %esi
80106ee7:	e8 a0 b0 ff ff       	call   80101f8c <kfree>
}
80106eec:	83 c4 10             	add    $0x10,%esp
80106eef:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106ef2:	5b                   	pop    %ebx
80106ef3:	5e                   	pop    %esi
80106ef4:	5d                   	pop    %ebp
80106ef5:	c3                   	ret    

80106ef6 <setupkvm>:
{
80106ef6:	55                   	push   %ebp
80106ef7:	89 e5                	mov    %esp,%ebp
80106ef9:	56                   	push   %esi
80106efa:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106efb:	e8 c9 b1 ff ff       	call   801020c9 <kalloc>
80106f00:	89 c6                	mov    %eax,%esi
80106f02:	85 c0                	test   %eax,%eax
80106f04:	74 55                	je     80106f5b <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
80106f06:	83 ec 04             	sub    $0x4,%esp
80106f09:	68 00 10 00 00       	push   $0x1000
80106f0e:	6a 00                	push   $0x0
80106f10:	50                   	push   %eax
80106f11:	e8 54 d7 ff ff       	call   8010466a <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106f16:	83 c4 10             	add    $0x10,%esp
80106f19:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
80106f1e:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
80106f24:	73 35                	jae    80106f5b <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
80106f26:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106f29:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106f2c:	29 c1                	sub    %eax,%ecx
80106f2e:	83 ec 08             	sub    $0x8,%esp
80106f31:	ff 73 0c             	push   0xc(%ebx)
80106f34:	50                   	push   %eax
80106f35:	8b 13                	mov    (%ebx),%edx
80106f37:	89 f0                	mov    %esi,%eax
80106f39:	e8 da f7 ff ff       	call   80106718 <mappages>
80106f3e:	83 c4 10             	add    $0x10,%esp
80106f41:	85 c0                	test   %eax,%eax
80106f43:	78 05                	js     80106f4a <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106f45:	83 c3 10             	add    $0x10,%ebx
80106f48:	eb d4                	jmp    80106f1e <setupkvm+0x28>
      freevm(pgdir);
80106f4a:	83 ec 0c             	sub    $0xc,%esp
80106f4d:	56                   	push   %esi
80106f4e:	e8 21 ff ff ff       	call   80106e74 <freevm>
      return 0;
80106f53:	83 c4 10             	add    $0x10,%esp
80106f56:	be 00 00 00 00       	mov    $0x0,%esi
}
80106f5b:	89 f0                	mov    %esi,%eax
80106f5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106f60:	5b                   	pop    %ebx
80106f61:	5e                   	pop    %esi
80106f62:	5d                   	pop    %ebp
80106f63:	c3                   	ret    

80106f64 <kvmalloc>:
{
80106f64:	55                   	push   %ebp
80106f65:	89 e5                	mov    %esp,%ebp
80106f67:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106f6a:	e8 87 ff ff ff       	call   80106ef6 <setupkvm>
80106f6f:	a3 64 63 11 80       	mov    %eax,0x80116364
  switchkvm();
80106f74:	e8 8a fa ff ff       	call   80106a03 <switchkvm>
}
80106f79:	c9                   	leave  
80106f7a:	c3                   	ret    

80106f7b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106f7b:	55                   	push   %ebp
80106f7c:	89 e5                	mov    %esp,%ebp
80106f7e:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106f81:	b9 00 00 00 00       	mov    $0x0,%ecx
80106f86:	8b 55 0c             	mov    0xc(%ebp),%edx
80106f89:	8b 45 08             	mov    0x8(%ebp),%eax
80106f8c:	e8 ec f6 ff ff       	call   8010667d <walkpgdir>
  if(pte == 0)
80106f91:	85 c0                	test   %eax,%eax
80106f93:	74 05                	je     80106f9a <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106f95:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106f98:	c9                   	leave  
80106f99:	c3                   	ret    
    panic("clearpteu");
80106f9a:	83 ec 0c             	sub    $0xc,%esp
80106f9d:	68 ae 7f 10 80       	push   $0x80107fae
80106fa2:	e8 a1 93 ff ff       	call   80100348 <panic>

80106fa7 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106fa7:	55                   	push   %ebp
80106fa8:	89 e5                	mov    %esp,%ebp
80106faa:	57                   	push   %edi
80106fab:	56                   	push   %esi
80106fac:	53                   	push   %ebx
80106fad:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106fb0:	e8 41 ff ff ff       	call   80106ef6 <setupkvm>
80106fb5:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106fb8:	85 c0                	test   %eax,%eax
80106fba:	0f 84 f2 00 00 00    	je     801070b2 <copyuvm+0x10b>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106fc0:	bf 00 00 00 00       	mov    $0x0,%edi
80106fc5:	eb 3a                	jmp    80107001 <copyuvm+0x5a>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
80106fc7:	83 ec 0c             	sub    $0xc,%esp
80106fca:	68 b8 7f 10 80       	push   $0x80107fb8
80106fcf:	e8 74 93 ff ff       	call   80100348 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
80106fd4:	83 ec 0c             	sub    $0xc,%esp
80106fd7:	68 d2 7f 10 80       	push   $0x80107fd2
80106fdc:	e8 67 93 ff ff       	call   80100348 <panic>
80106fe1:	83 ec 0c             	sub    $0xc,%esp
80106fe4:	68 38 77 10 80       	push   $0x80107738
80106fe9:	e8 5a 93 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
80106fee:	83 ec 0c             	sub    $0xc,%esp
80106ff1:	68 08 74 10 80       	push   $0x80107408
80106ff6:	e8 4d 93 ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80106ffb:	81 c7 00 10 00 00    	add    $0x1000,%edi
80107001:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80107004:	0f 83 a8 00 00 00    	jae    801070b2 <copyuvm+0x10b>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010700a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010700d:	b9 00 00 00 00       	mov    $0x0,%ecx
80107012:	89 fa                	mov    %edi,%edx
80107014:	8b 45 08             	mov    0x8(%ebp),%eax
80107017:	e8 61 f6 ff ff       	call   8010667d <walkpgdir>
8010701c:	85 c0                	test   %eax,%eax
8010701e:	74 a7                	je     80106fc7 <copyuvm+0x20>
    if(!(*pte & PTE_P))
80107020:	8b 00                	mov    (%eax),%eax
80107022:	a8 01                	test   $0x1,%al
80107024:	74 ae                	je     80106fd4 <copyuvm+0x2d>
80107026:	89 c6                	mov    %eax,%esi
80107028:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
static inline uint PTE_FLAGS(uint pte) { return pte & 0xFFF; }
8010702e:	25 ff 0f 00 00       	and    $0xfff,%eax
80107033:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
80107036:	e8 8e b0 ff ff       	call   801020c9 <kalloc>
8010703b:	89 c3                	mov    %eax,%ebx
8010703d:	85 c0                	test   %eax,%eax
8010703f:	74 5c                	je     8010709d <copyuvm+0xf6>
    if (a > KERNBASE)
80107041:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
80107047:	77 98                	ja     80106fe1 <copyuvm+0x3a>
    return (char*)a + KERNBASE;
80107049:	81 c6 00 00 00 80    	add    $0x80000000,%esi
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010704f:	83 ec 04             	sub    $0x4,%esp
80107052:	68 00 10 00 00       	push   $0x1000
80107057:	56                   	push   %esi
80107058:	50                   	push   %eax
80107059:	e8 84 d6 ff ff       	call   801046e2 <memmove>
    if (a < (void*) KERNBASE)
8010705e:	83 c4 10             	add    $0x10,%esp
80107061:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80107067:	76 85                	jbe    80106fee <copyuvm+0x47>
    return (uint)a - KERNBASE;
80107069:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010706f:	83 ec 08             	sub    $0x8,%esp
80107072:	ff 75 e0             	push   -0x20(%ebp)
80107075:	50                   	push   %eax
80107076:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010707b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010707e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80107081:	e8 92 f6 ff ff       	call   80106718 <mappages>
80107086:	83 c4 10             	add    $0x10,%esp
80107089:	85 c0                	test   %eax,%eax
8010708b:	0f 89 6a ff ff ff    	jns    80106ffb <copyuvm+0x54>
      kfree(mem);
80107091:	83 ec 0c             	sub    $0xc,%esp
80107094:	53                   	push   %ebx
80107095:	e8 f2 ae ff ff       	call   80101f8c <kfree>
      goto bad;
8010709a:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
8010709d:	83 ec 0c             	sub    $0xc,%esp
801070a0:	ff 75 dc             	push   -0x24(%ebp)
801070a3:	e8 cc fd ff ff       	call   80106e74 <freevm>
  return 0;
801070a8:	83 c4 10             	add    $0x10,%esp
801070ab:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
801070b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801070b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801070b8:	5b                   	pop    %ebx
801070b9:	5e                   	pop    %esi
801070ba:	5f                   	pop    %edi
801070bb:	5d                   	pop    %ebp
801070bc:	c3                   	ret    

801070bd <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801070bd:	55                   	push   %ebp
801070be:	89 e5                	mov    %esp,%ebp
801070c0:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801070c3:	b9 00 00 00 00       	mov    $0x0,%ecx
801070c8:	8b 55 0c             	mov    0xc(%ebp),%edx
801070cb:	8b 45 08             	mov    0x8(%ebp),%eax
801070ce:	e8 aa f5 ff ff       	call   8010667d <walkpgdir>
  if((*pte & PTE_P) == 0)
801070d3:	8b 00                	mov    (%eax),%eax
801070d5:	a8 01                	test   $0x1,%al
801070d7:	74 24                	je     801070fd <uva2ka+0x40>
    return 0;
  if((*pte & PTE_U) == 0)
801070d9:	a8 04                	test   $0x4,%al
801070db:	74 27                	je     80107104 <uva2ka+0x47>
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
801070dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
801070e2:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801070e7:	77 07                	ja     801070f0 <uva2ka+0x33>
    return (char*)a + KERNBASE;
801070e9:	05 00 00 00 80       	add    $0x80000000,%eax
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
801070ee:	c9                   	leave  
801070ef:	c3                   	ret    
        panic("P2V on address > KERNBASE");
801070f0:	83 ec 0c             	sub    $0xc,%esp
801070f3:	68 38 77 10 80       	push   $0x80107738
801070f8:	e8 4b 92 ff ff       	call   80100348 <panic>
    return 0;
801070fd:	b8 00 00 00 00       	mov    $0x0,%eax
80107102:	eb ea                	jmp    801070ee <uva2ka+0x31>
    return 0;
80107104:	b8 00 00 00 00       	mov    $0x0,%eax
80107109:	eb e3                	jmp    801070ee <uva2ka+0x31>

8010710b <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010710b:	55                   	push   %ebp
8010710c:	89 e5                	mov    %esp,%ebp
8010710e:	57                   	push   %edi
8010710f:	56                   	push   %esi
80107110:	53                   	push   %ebx
80107111:	83 ec 0c             	sub    $0xc,%esp
80107114:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80107117:	eb 25                	jmp    8010713e <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80107119:	8b 55 0c             	mov    0xc(%ebp),%edx
8010711c:	29 f2                	sub    %esi,%edx
8010711e:	01 d0                	add    %edx,%eax
80107120:	83 ec 04             	sub    $0x4,%esp
80107123:	53                   	push   %ebx
80107124:	ff 75 10             	push   0x10(%ebp)
80107127:	50                   	push   %eax
80107128:	e8 b5 d5 ff ff       	call   801046e2 <memmove>
    len -= n;
8010712d:	29 df                	sub    %ebx,%edi
    buf += n;
8010712f:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80107132:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80107138:	89 45 0c             	mov    %eax,0xc(%ebp)
8010713b:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
8010713e:	85 ff                	test   %edi,%edi
80107140:	74 2f                	je     80107171 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80107142:	8b 75 0c             	mov    0xc(%ebp),%esi
80107145:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
8010714b:	83 ec 08             	sub    $0x8,%esp
8010714e:	56                   	push   %esi
8010714f:	ff 75 08             	push   0x8(%ebp)
80107152:	e8 66 ff ff ff       	call   801070bd <uva2ka>
    if(pa0 == 0)
80107157:	83 c4 10             	add    $0x10,%esp
8010715a:	85 c0                	test   %eax,%eax
8010715c:	74 20                	je     8010717e <copyout+0x73>
    n = PGSIZE - (va - va0);
8010715e:	89 f3                	mov    %esi,%ebx
80107160:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80107163:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80107169:	39 df                	cmp    %ebx,%edi
8010716b:	73 ac                	jae    80107119 <copyout+0xe>
      n = len;
8010716d:	89 fb                	mov    %edi,%ebx
8010716f:	eb a8                	jmp    80107119 <copyout+0xe>
  }
  return 0;
80107171:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107176:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107179:	5b                   	pop    %ebx
8010717a:	5e                   	pop    %esi
8010717b:	5f                   	pop    %edi
8010717c:	5d                   	pop    %ebp
8010717d:	c3                   	ret    
      return -1;
8010717e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107183:	eb f1                	jmp    80107176 <copyout+0x6b>
