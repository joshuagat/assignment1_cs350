
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
80100028:	bc 00 51 11 80       	mov    $0x80115100,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 af 38 10 80       	mov    $0x801038af,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 2c 86 10 80       	push   $0x8010862c
80100042:	68 a0 b5 10 80       	push   $0x8010b5a0
80100047:	e8 14 50 00 00       	call   80105060 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 b0 f4 10 80 a4 	movl   $0x8010f4a4,0x8010f4b0
80100056:	f4 10 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 b4 f4 10 80 a4 	movl   $0x8010f4a4,0x8010f4b4
80100060:	f4 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 d4 b5 10 80 	movl   $0x8010b5d4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 b4 f4 10 80    	mov    0x8010f4b4,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c a4 f4 10 80 	movl   $0x8010f4a4,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 b4 f4 10 80       	mov    0x8010f4b4,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 b4 f4 10 80       	mov    %eax,0x8010f4b4
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 a4 f4 10 80       	mov    $0x8010f4a4,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
  }
}
801000b0:	90                   	nop
801000b1:	90                   	nop
801000b2:	c9                   	leave  
801000b3:	c3                   	ret    

801000b4 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b4:	55                   	push   %ebp
801000b5:	89 e5                	mov    %esp,%ebp
801000b7:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000ba:	83 ec 0c             	sub    $0xc,%esp
801000bd:	68 a0 b5 10 80       	push   $0x8010b5a0
801000c2:	e8 bb 4f 00 00       	call   80105082 <acquire>
801000c7:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ca:	a1 b4 f4 10 80       	mov    0x8010f4b4,%eax
801000cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d2:	eb 67                	jmp    8010013b <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d7:	8b 40 04             	mov    0x4(%eax),%eax
801000da:	39 45 08             	cmp    %eax,0x8(%ebp)
801000dd:	75 53                	jne    80100132 <bget+0x7e>
801000df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e2:	8b 40 08             	mov    0x8(%eax),%eax
801000e5:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000e8:	75 48                	jne    80100132 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ed:	8b 00                	mov    (%eax),%eax
801000ef:	83 e0 01             	and    $0x1,%eax
801000f2:	85 c0                	test   %eax,%eax
801000f4:	75 27                	jne    8010011d <bget+0x69>
        b->flags |= B_BUSY;
801000f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f9:	8b 00                	mov    (%eax),%eax
801000fb:	83 c8 01             	or     $0x1,%eax
801000fe:	89 c2                	mov    %eax,%edx
80100100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100103:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100105:	83 ec 0c             	sub    $0xc,%esp
80100108:	68 a0 b5 10 80       	push   $0x8010b5a0
8010010d:	e8 d7 4f 00 00       	call   801050e9 <release>
80100112:	83 c4 10             	add    $0x10,%esp
        return b;
80100115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100118:	e9 98 00 00 00       	jmp    801001b5 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011d:	83 ec 08             	sub    $0x8,%esp
80100120:	68 a0 b5 10 80       	push   $0x8010b5a0
80100125:	ff 75 f4             	pushl  -0xc(%ebp)
80100128:	e8 5a 4c 00 00       	call   80104d87 <sleep>
8010012d:	83 c4 10             	add    $0x10,%esp
      goto loop;
80100130:	eb 98                	jmp    801000ca <bget+0x16>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	8b 40 10             	mov    0x10(%eax),%eax
80100138:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013b:	81 7d f4 a4 f4 10 80 	cmpl   $0x8010f4a4,-0xc(%ebp)
80100142:	75 90                	jne    801000d4 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100144:	a1 b0 f4 10 80       	mov    0x8010f4b0,%eax
80100149:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014c:	eb 51                	jmp    8010019f <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 01             	and    $0x1,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 3c                	jne    80100196 <bget+0xe2>
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 00                	mov    (%eax),%eax
8010015f:	83 e0 04             	and    $0x4,%eax
80100162:	85 c0                	test   %eax,%eax
80100164:	75 30                	jne    80100196 <bget+0xe2>
      b->dev = dev;
80100166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100169:	8b 55 08             	mov    0x8(%ebp),%edx
8010016c:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100172:	8b 55 0c             	mov    0xc(%ebp),%edx
80100175:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100181:	83 ec 0c             	sub    $0xc,%esp
80100184:	68 a0 b5 10 80       	push   $0x8010b5a0
80100189:	e8 5b 4f 00 00       	call   801050e9 <release>
8010018e:	83 c4 10             	add    $0x10,%esp
      return b;
80100191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100194:	eb 1f                	jmp    801001b5 <bget+0x101>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100199:	8b 40 0c             	mov    0xc(%eax),%eax
8010019c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019f:	81 7d f4 a4 f4 10 80 	cmpl   $0x8010f4a4,-0xc(%ebp)
801001a6:	75 a6                	jne    8010014e <bget+0x9a>
    }
  }
  panic("bget: no buffers");
801001a8:	83 ec 0c             	sub    $0xc,%esp
801001ab:	68 33 86 10 80       	push   $0x80108633
801001b0:	e8 c6 03 00 00       	call   8010057b <panic>
}
801001b5:	c9                   	leave  
801001b6:	c3                   	ret    

801001b7 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b7:	55                   	push   %ebp
801001b8:	89 e5                	mov    %esp,%ebp
801001ba:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bd:	83 ec 08             	sub    $0x8,%esp
801001c0:	ff 75 0c             	pushl  0xc(%ebp)
801001c3:	ff 75 08             	pushl  0x8(%ebp)
801001c6:	e8 e9 fe ff ff       	call   801000b4 <bget>
801001cb:	83 c4 10             	add    $0x10,%esp
801001ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	8b 00                	mov    (%eax),%eax
801001d6:	83 e0 02             	and    $0x2,%eax
801001d9:	85 c0                	test   %eax,%eax
801001db:	75 0e                	jne    801001eb <bread+0x34>
    iderw(b);
801001dd:	83 ec 0c             	sub    $0xc,%esp
801001e0:	ff 75 f4             	pushl  -0xc(%ebp)
801001e3:	e8 47 27 00 00       	call   8010292f <iderw>
801001e8:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ee:	c9                   	leave  
801001ef:	c3                   	ret    

801001f0 <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001f0:	55                   	push   %ebp
801001f1:	89 e5                	mov    %esp,%ebp
801001f3:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f6:	8b 45 08             	mov    0x8(%ebp),%eax
801001f9:	8b 00                	mov    (%eax),%eax
801001fb:	83 e0 01             	and    $0x1,%eax
801001fe:	85 c0                	test   %eax,%eax
80100200:	75 0d                	jne    8010020f <bwrite+0x1f>
    panic("bwrite");
80100202:	83 ec 0c             	sub    $0xc,%esp
80100205:	68 44 86 10 80       	push   $0x80108644
8010020a:	e8 6c 03 00 00       	call   8010057b <panic>
  b->flags |= B_DIRTY;
8010020f:	8b 45 08             	mov    0x8(%ebp),%eax
80100212:	8b 00                	mov    (%eax),%eax
80100214:	83 c8 04             	or     $0x4,%eax
80100217:	89 c2                	mov    %eax,%edx
80100219:	8b 45 08             	mov    0x8(%ebp),%eax
8010021c:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021e:	83 ec 0c             	sub    $0xc,%esp
80100221:	ff 75 08             	pushl  0x8(%ebp)
80100224:	e8 06 27 00 00       	call   8010292f <iderw>
80100229:	83 c4 10             	add    $0x10,%esp
}
8010022c:	90                   	nop
8010022d:	c9                   	leave  
8010022e:	c3                   	ret    

8010022f <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022f:	55                   	push   %ebp
80100230:	89 e5                	mov    %esp,%ebp
80100232:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100235:	8b 45 08             	mov    0x8(%ebp),%eax
80100238:	8b 00                	mov    (%eax),%eax
8010023a:	83 e0 01             	and    $0x1,%eax
8010023d:	85 c0                	test   %eax,%eax
8010023f:	75 0d                	jne    8010024e <brelse+0x1f>
    panic("brelse");
80100241:	83 ec 0c             	sub    $0xc,%esp
80100244:	68 4b 86 10 80       	push   $0x8010864b
80100249:	e8 2d 03 00 00       	call   8010057b <panic>

  acquire(&bcache.lock);
8010024e:	83 ec 0c             	sub    $0xc,%esp
80100251:	68 a0 b5 10 80       	push   $0x8010b5a0
80100256:	e8 27 4e 00 00       	call   80105082 <acquire>
8010025b:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025e:	8b 45 08             	mov    0x8(%ebp),%eax
80100261:	8b 40 10             	mov    0x10(%eax),%eax
80100264:	8b 55 08             	mov    0x8(%ebp),%edx
80100267:	8b 52 0c             	mov    0xc(%edx),%edx
8010026a:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	8b 40 0c             	mov    0xc(%eax),%eax
80100273:	8b 55 08             	mov    0x8(%ebp),%edx
80100276:	8b 52 10             	mov    0x10(%edx),%edx
80100279:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027c:	8b 15 b4 f4 10 80    	mov    0x8010f4b4,%edx
80100282:	8b 45 08             	mov    0x8(%ebp),%eax
80100285:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	c7 40 0c a4 f4 10 80 	movl   $0x8010f4a4,0xc(%eax)
  bcache.head.next->prev = b;
80100292:	a1 b4 f4 10 80       	mov    0x8010f4b4,%eax
80100297:	8b 55 08             	mov    0x8(%ebp),%edx
8010029a:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029d:	8b 45 08             	mov    0x8(%ebp),%eax
801002a0:	a3 b4 f4 10 80       	mov    %eax,0x8010f4b4

  b->flags &= ~B_BUSY;
801002a5:	8b 45 08             	mov    0x8(%ebp),%eax
801002a8:	8b 00                	mov    (%eax),%eax
801002aa:	83 e0 fe             	and    $0xfffffffe,%eax
801002ad:	89 c2                	mov    %eax,%edx
801002af:	8b 45 08             	mov    0x8(%ebp),%eax
801002b2:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b4:	83 ec 0c             	sub    $0xc,%esp
801002b7:	ff 75 08             	pushl  0x8(%ebp)
801002ba:	e8 b4 4b 00 00       	call   80104e73 <wakeup>
801002bf:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c2:	83 ec 0c             	sub    $0xc,%esp
801002c5:	68 a0 b5 10 80       	push   $0x8010b5a0
801002ca:	e8 1a 4e 00 00       	call   801050e9 <release>
801002cf:	83 c4 10             	add    $0x10,%esp
}
801002d2:	90                   	nop
801002d3:	c9                   	leave  
801002d4:	c3                   	ret    

801002d5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d5:	55                   	push   %ebp
801002d6:	89 e5                	mov    %esp,%ebp
801002d8:	83 ec 14             	sub    $0x14,%esp
801002db:	8b 45 08             	mov    0x8(%ebp),%eax
801002de:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e6:	89 c2                	mov    %eax,%edx
801002e8:	ec                   	in     (%dx),%al
801002e9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ec:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002f0:	c9                   	leave  
801002f1:	c3                   	ret    

801002f2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f2:	55                   	push   %ebp
801002f3:	89 e5                	mov    %esp,%ebp
801002f5:	83 ec 08             	sub    $0x8,%esp
801002f8:	8b 45 08             	mov    0x8(%ebp),%eax
801002fb:	8b 55 0c             	mov    0xc(%ebp),%edx
801002fe:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100302:	89 d0                	mov    %edx,%eax
80100304:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100307:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010030b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030f:	ee                   	out    %al,(%dx)
}
80100310:	90                   	nop
80100311:	c9                   	leave  
80100312:	c3                   	ret    

80100313 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100313:	55                   	push   %ebp
80100314:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100316:	fa                   	cli    
}
80100317:	90                   	nop
80100318:	5d                   	pop    %ebp
80100319:	c3                   	ret    

8010031a <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
8010031a:	55                   	push   %ebp
8010031b:	89 e5                	mov    %esp,%ebp
8010031d:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100320:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100324:	74 1c                	je     80100342 <printint+0x28>
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	c1 e8 1f             	shr    $0x1f,%eax
8010032c:	0f b6 c0             	movzbl %al,%eax
8010032f:	89 45 10             	mov    %eax,0x10(%ebp)
80100332:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100336:	74 0a                	je     80100342 <printint+0x28>
    x = -xx;
80100338:	8b 45 08             	mov    0x8(%ebp),%eax
8010033b:	f7 d8                	neg    %eax
8010033d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100340:	eb 06                	jmp    80100348 <printint+0x2e>
  else
    x = xx;
80100342:	8b 45 08             	mov    0x8(%ebp),%eax
80100345:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100348:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100352:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100355:	ba 00 00 00 00       	mov    $0x0,%edx
8010035a:	f7 f1                	div    %ecx
8010035c:	89 d1                	mov    %edx,%ecx
8010035e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100361:	8d 50 01             	lea    0x1(%eax),%edx
80100364:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100367:	0f b6 91 04 90 10 80 	movzbl -0x7fef6ffc(%ecx),%edx
8010036e:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
80100372:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100375:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100378:	ba 00 00 00 00       	mov    $0x0,%edx
8010037d:	f7 f1                	div    %ecx
8010037f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100382:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100386:	75 c7                	jne    8010034f <printint+0x35>

  if(sign)
80100388:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038c:	74 2a                	je     801003b8 <printint+0x9e>
    buf[i++] = '-';
8010038e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100391:	8d 50 01             	lea    0x1(%eax),%edx
80100394:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100397:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039c:	eb 1a                	jmp    801003b8 <printint+0x9e>
    consputc(buf[i]);
8010039e:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a4:	01 d0                	add    %edx,%eax
801003a6:	0f b6 00             	movzbl (%eax),%eax
801003a9:	0f be c0             	movsbl %al,%eax
801003ac:	83 ec 0c             	sub    $0xc,%esp
801003af:	50                   	push   %eax
801003b0:	e8 00 04 00 00       	call   801007b5 <consputc>
801003b5:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003b8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003c0:	79 dc                	jns    8010039e <printint+0x84>
}
801003c2:	90                   	nop
801003c3:	90                   	nop
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 94 f7 10 80       	mov    0x8010f794,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 60 f7 10 80       	push   $0x8010f760
801003e2:	e8 9b 4c 00 00       	call   80105082 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 52 86 10 80       	push   $0x80108652
801003f9:	e8 7d 01 00 00       	call   8010057b <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 2f 01 00 00       	jmp    8010053f <cprintf+0x179>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 94 03 00 00       	call   801007b5 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 12 01 00 00       	jmp    8010053b <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 14 01 00 00    	je     80100561 <cprintf+0x19b>
      break;
    switch(c){
8010044d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100451:	74 5e                	je     801004b1 <cprintf+0xeb>
80100453:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100457:	0f 8f c2 00 00 00    	jg     8010051f <cprintf+0x159>
8010045d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100461:	74 6b                	je     801004ce <cprintf+0x108>
80100463:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100467:	0f 8f b2 00 00 00    	jg     8010051f <cprintf+0x159>
8010046d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
80100471:	74 3e                	je     801004b1 <cprintf+0xeb>
80100473:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
80100477:	0f 8f a2 00 00 00    	jg     8010051f <cprintf+0x159>
8010047d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100481:	0f 84 89 00 00 00    	je     80100510 <cprintf+0x14a>
80100487:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
8010048b:	0f 85 8e 00 00 00    	jne    8010051f <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
80100491:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100494:	8d 50 04             	lea    0x4(%eax),%edx
80100497:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010049a:	8b 00                	mov    (%eax),%eax
8010049c:	83 ec 04             	sub    $0x4,%esp
8010049f:	6a 01                	push   $0x1
801004a1:	6a 0a                	push   $0xa
801004a3:	50                   	push   %eax
801004a4:	e8 71 fe ff ff       	call   8010031a <printint>
801004a9:	83 c4 10             	add    $0x10,%esp
      break;
801004ac:	e9 8a 00 00 00       	jmp    8010053b <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004b4:	8d 50 04             	lea    0x4(%eax),%edx
801004b7:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004ba:	8b 00                	mov    (%eax),%eax
801004bc:	83 ec 04             	sub    $0x4,%esp
801004bf:	6a 00                	push   $0x0
801004c1:	6a 10                	push   $0x10
801004c3:	50                   	push   %eax
801004c4:	e8 51 fe ff ff       	call   8010031a <printint>
801004c9:	83 c4 10             	add    $0x10,%esp
      break;
801004cc:	eb 6d                	jmp    8010053b <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004d1:	8d 50 04             	lea    0x4(%eax),%edx
801004d4:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004d7:	8b 00                	mov    (%eax),%eax
801004d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004dc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004e0:	75 22                	jne    80100504 <cprintf+0x13e>
        s = "(null)";
801004e2:	c7 45 ec 5b 86 10 80 	movl   $0x8010865b,-0x14(%ebp)
      for(; *s; s++)
801004e9:	eb 19                	jmp    80100504 <cprintf+0x13e>
        consputc(*s);
801004eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004ee:	0f b6 00             	movzbl (%eax),%eax
801004f1:	0f be c0             	movsbl %al,%eax
801004f4:	83 ec 0c             	sub    $0xc,%esp
801004f7:	50                   	push   %eax
801004f8:	e8 b8 02 00 00       	call   801007b5 <consputc>
801004fd:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
80100500:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100504:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100507:	0f b6 00             	movzbl (%eax),%eax
8010050a:	84 c0                	test   %al,%al
8010050c:	75 dd                	jne    801004eb <cprintf+0x125>
      break;
8010050e:	eb 2b                	jmp    8010053b <cprintf+0x175>
    case '%':
      consputc('%');
80100510:	83 ec 0c             	sub    $0xc,%esp
80100513:	6a 25                	push   $0x25
80100515:	e8 9b 02 00 00       	call   801007b5 <consputc>
8010051a:	83 c4 10             	add    $0x10,%esp
      break;
8010051d:	eb 1c                	jmp    8010053b <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010051f:	83 ec 0c             	sub    $0xc,%esp
80100522:	6a 25                	push   $0x25
80100524:	e8 8c 02 00 00       	call   801007b5 <consputc>
80100529:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010052c:	83 ec 0c             	sub    $0xc,%esp
8010052f:	ff 75 e4             	pushl  -0x1c(%ebp)
80100532:	e8 7e 02 00 00       	call   801007b5 <consputc>
80100537:	83 c4 10             	add    $0x10,%esp
      break;
8010053a:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010053b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010053f:	8b 55 08             	mov    0x8(%ebp),%edx
80100542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100545:	01 d0                	add    %edx,%eax
80100547:	0f b6 00             	movzbl (%eax),%eax
8010054a:	0f be c0             	movsbl %al,%eax
8010054d:	25 ff 00 00 00       	and    $0xff,%eax
80100552:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100555:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100559:	0f 85 b1 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010055f:	eb 01                	jmp    80100562 <cprintf+0x19c>
      break;
80100561:	90                   	nop
    }
  }

  if(locking)
80100562:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100566:	74 10                	je     80100578 <cprintf+0x1b2>
    release(&cons.lock);
80100568:	83 ec 0c             	sub    $0xc,%esp
8010056b:	68 60 f7 10 80       	push   $0x8010f760
80100570:	e8 74 4b 00 00       	call   801050e9 <release>
80100575:	83 c4 10             	add    $0x10,%esp
}
80100578:	90                   	nop
80100579:	c9                   	leave  
8010057a:	c3                   	ret    

8010057b <panic>:

void
panic(char *s)
{
8010057b:	55                   	push   %ebp
8010057c:	89 e5                	mov    %esp,%ebp
8010057e:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
80100581:	e8 8d fd ff ff       	call   80100313 <cli>
  cons.locking = 0;
80100586:	c7 05 94 f7 10 80 00 	movl   $0x0,0x8010f794
8010058d:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100590:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100596:	0f b6 00             	movzbl (%eax),%eax
80100599:	0f b6 c0             	movzbl %al,%eax
8010059c:	83 ec 08             	sub    $0x8,%esp
8010059f:	50                   	push   %eax
801005a0:	68 62 86 10 80       	push   $0x80108662
801005a5:	e8 1c fe ff ff       	call   801003c6 <cprintf>
801005aa:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005ad:	8b 45 08             	mov    0x8(%ebp),%eax
801005b0:	83 ec 0c             	sub    $0xc,%esp
801005b3:	50                   	push   %eax
801005b4:	e8 0d fe ff ff       	call   801003c6 <cprintf>
801005b9:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005bc:	83 ec 0c             	sub    $0xc,%esp
801005bf:	68 71 86 10 80       	push   $0x80108671
801005c4:	e8 fd fd ff ff       	call   801003c6 <cprintf>
801005c9:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005cc:	83 ec 08             	sub    $0x8,%esp
801005cf:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005d2:	50                   	push   %eax
801005d3:	8d 45 08             	lea    0x8(%ebp),%eax
801005d6:	50                   	push   %eax
801005d7:	e8 5f 4b 00 00       	call   8010513b <getcallerpcs>
801005dc:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005e6:	eb 1c                	jmp    80100604 <panic+0x89>
    cprintf(" %p", pcs[i]);
801005e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005eb:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005ef:	83 ec 08             	sub    $0x8,%esp
801005f2:	50                   	push   %eax
801005f3:	68 73 86 10 80       	push   $0x80108673
801005f8:	e8 c9 fd ff ff       	call   801003c6 <cprintf>
801005fd:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100600:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100604:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100608:	7e de                	jle    801005e8 <panic+0x6d>
  panicked = 1; // freeze other CPU
8010060a:	c7 05 4c f7 10 80 01 	movl   $0x1,0x8010f74c
80100611:	00 00 00 
  for(;;)
80100614:	eb fe                	jmp    80100614 <panic+0x99>

80100616 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100616:	55                   	push   %ebp
80100617:	89 e5                	mov    %esp,%ebp
80100619:	53                   	push   %ebx
8010061a:	83 ec 14             	sub    $0x14,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
8010061d:	6a 0e                	push   $0xe
8010061f:	68 d4 03 00 00       	push   $0x3d4
80100624:	e8 c9 fc ff ff       	call   801002f2 <outb>
80100629:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
8010062c:	68 d5 03 00 00       	push   $0x3d5
80100631:	e8 9f fc ff ff       	call   801002d5 <inb>
80100636:	83 c4 04             	add    $0x4,%esp
80100639:	0f b6 c0             	movzbl %al,%eax
8010063c:	c1 e0 08             	shl    $0x8,%eax
8010063f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100642:	6a 0f                	push   $0xf
80100644:	68 d4 03 00 00       	push   $0x3d4
80100649:	e8 a4 fc ff ff       	call   801002f2 <outb>
8010064e:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
80100651:	68 d5 03 00 00       	push   $0x3d5
80100656:	e8 7a fc ff ff       	call   801002d5 <inb>
8010065b:	83 c4 04             	add    $0x4,%esp
8010065e:	0f b6 c0             	movzbl %al,%eax
80100661:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100664:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100668:	75 34                	jne    8010069e <cgaputc+0x88>
    pos += 80 - pos%80;
8010066a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010066d:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100672:	89 c8                	mov    %ecx,%eax
80100674:	f7 ea                	imul   %edx
80100676:	89 d0                	mov    %edx,%eax
80100678:	c1 f8 05             	sar    $0x5,%eax
8010067b:	89 cb                	mov    %ecx,%ebx
8010067d:	c1 fb 1f             	sar    $0x1f,%ebx
80100680:	29 d8                	sub    %ebx,%eax
80100682:	89 c2                	mov    %eax,%edx
80100684:	89 d0                	mov    %edx,%eax
80100686:	c1 e0 02             	shl    $0x2,%eax
80100689:	01 d0                	add    %edx,%eax
8010068b:	c1 e0 04             	shl    $0x4,%eax
8010068e:	29 c1                	sub    %eax,%ecx
80100690:	89 ca                	mov    %ecx,%edx
80100692:	b8 50 00 00 00       	mov    $0x50,%eax
80100697:	29 d0                	sub    %edx,%eax
80100699:	01 45 f4             	add    %eax,-0xc(%ebp)
8010069c:	eb 38                	jmp    801006d6 <cgaputc+0xc0>
  else if(c == BACKSPACE){
8010069e:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006a5:	75 0c                	jne    801006b3 <cgaputc+0x9d>
    if(pos > 0) --pos;
801006a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006ab:	7e 29                	jle    801006d6 <cgaputc+0xc0>
801006ad:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006b1:	eb 23                	jmp    801006d6 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006b3:	8b 45 08             	mov    0x8(%ebp),%eax
801006b6:	0f b6 c0             	movzbl %al,%eax
801006b9:	80 cc 07             	or     $0x7,%ah
801006bc:	89 c1                	mov    %eax,%ecx
801006be:	8b 1d 00 90 10 80    	mov    0x80109000,%ebx
801006c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006c7:	8d 50 01             	lea    0x1(%eax),%edx
801006ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006cd:	01 c0                	add    %eax,%eax
801006cf:	01 d8                	add    %ebx,%eax
801006d1:	89 ca                	mov    %ecx,%edx
801006d3:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006da:	78 09                	js     801006e5 <cgaputc+0xcf>
801006dc:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006e3:	7e 0d                	jle    801006f2 <cgaputc+0xdc>
    panic("pos under/overflow");
801006e5:	83 ec 0c             	sub    $0xc,%esp
801006e8:	68 77 86 10 80       	push   $0x80108677
801006ed:	e8 89 fe ff ff       	call   8010057b <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006f2:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006f9:	7e 4d                	jle    80100748 <cgaputc+0x132>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006fb:	a1 00 90 10 80       	mov    0x80109000,%eax
80100700:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100706:	a1 00 90 10 80       	mov    0x80109000,%eax
8010070b:	83 ec 04             	sub    $0x4,%esp
8010070e:	68 60 0e 00 00       	push   $0xe60
80100713:	52                   	push   %edx
80100714:	50                   	push   %eax
80100715:	e8 8a 4c 00 00       	call   801053a4 <memmove>
8010071a:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
8010071d:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100721:	b8 80 07 00 00       	mov    $0x780,%eax
80100726:	2b 45 f4             	sub    -0xc(%ebp),%eax
80100729:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010072c:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100735:	01 c0                	add    %eax,%eax
80100737:	01 c8                	add    %ecx,%eax
80100739:	83 ec 04             	sub    $0x4,%esp
8010073c:	52                   	push   %edx
8010073d:	6a 00                	push   $0x0
8010073f:	50                   	push   %eax
80100740:	e8 a0 4b 00 00       	call   801052e5 <memset>
80100745:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100748:	83 ec 08             	sub    $0x8,%esp
8010074b:	6a 0e                	push   $0xe
8010074d:	68 d4 03 00 00       	push   $0x3d4
80100752:	e8 9b fb ff ff       	call   801002f2 <outb>
80100757:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010075d:	c1 f8 08             	sar    $0x8,%eax
80100760:	0f b6 c0             	movzbl %al,%eax
80100763:	83 ec 08             	sub    $0x8,%esp
80100766:	50                   	push   %eax
80100767:	68 d5 03 00 00       	push   $0x3d5
8010076c:	e8 81 fb ff ff       	call   801002f2 <outb>
80100771:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100774:	83 ec 08             	sub    $0x8,%esp
80100777:	6a 0f                	push   $0xf
80100779:	68 d4 03 00 00       	push   $0x3d4
8010077e:	e8 6f fb ff ff       	call   801002f2 <outb>
80100783:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100789:	0f b6 c0             	movzbl %al,%eax
8010078c:	83 ec 08             	sub    $0x8,%esp
8010078f:	50                   	push   %eax
80100790:	68 d5 03 00 00       	push   $0x3d5
80100795:	e8 58 fb ff ff       	call   801002f2 <outb>
8010079a:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010079d:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801007a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007a6:	01 c0                	add    %eax,%eax
801007a8:	01 d0                	add    %edx,%eax
801007aa:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007af:	90                   	nop
801007b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801007b3:	c9                   	leave  
801007b4:	c3                   	ret    

801007b5 <consputc>:

void
consputc(int c)
{
801007b5:	55                   	push   %ebp
801007b6:	89 e5                	mov    %esp,%ebp
801007b8:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007bb:	a1 4c f7 10 80       	mov    0x8010f74c,%eax
801007c0:	85 c0                	test   %eax,%eax
801007c2:	74 07                	je     801007cb <consputc+0x16>
    cli();
801007c4:	e8 4a fb ff ff       	call   80100313 <cli>
    for(;;)
801007c9:	eb fe                	jmp    801007c9 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
801007cb:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007d2:	75 29                	jne    801007fd <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007d4:	83 ec 0c             	sub    $0xc,%esp
801007d7:	6a 08                	push   $0x8
801007d9:	e8 d8 64 00 00       	call   80106cb6 <uartputc>
801007de:	83 c4 10             	add    $0x10,%esp
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	6a 20                	push   $0x20
801007e6:	e8 cb 64 00 00       	call   80106cb6 <uartputc>
801007eb:	83 c4 10             	add    $0x10,%esp
801007ee:	83 ec 0c             	sub    $0xc,%esp
801007f1:	6a 08                	push   $0x8
801007f3:	e8 be 64 00 00       	call   80106cb6 <uartputc>
801007f8:	83 c4 10             	add    $0x10,%esp
801007fb:	eb 0e                	jmp    8010080b <consputc+0x56>
  } else
    uartputc(c);
801007fd:	83 ec 0c             	sub    $0xc,%esp
80100800:	ff 75 08             	pushl  0x8(%ebp)
80100803:	e8 ae 64 00 00       	call   80106cb6 <uartputc>
80100808:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010080b:	83 ec 0c             	sub    $0xc,%esp
8010080e:	ff 75 08             	pushl  0x8(%ebp)
80100811:	e8 00 fe ff ff       	call   80100616 <cgaputc>
80100816:	83 c4 10             	add    $0x10,%esp
}
80100819:	90                   	nop
8010081a:	c9                   	leave  
8010081b:	c3                   	ret    

8010081c <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
8010081c:	55                   	push   %ebp
8010081d:	89 e5                	mov    %esp,%ebp
8010081f:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
80100822:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100829:	83 ec 0c             	sub    $0xc,%esp
8010082c:	68 60 f7 10 80       	push   $0x8010f760
80100831:	e8 4c 48 00 00       	call   80105082 <acquire>
80100836:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100839:	e9 50 01 00 00       	jmp    8010098e <consoleintr+0x172>
    switch(c){
8010083e:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100842:	0f 84 81 00 00 00    	je     801008c9 <consoleintr+0xad>
80100848:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010084c:	0f 8f ac 00 00 00    	jg     801008fe <consoleintr+0xe2>
80100852:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100856:	74 43                	je     8010089b <consoleintr+0x7f>
80100858:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010085c:	0f 8f 9c 00 00 00    	jg     801008fe <consoleintr+0xe2>
80100862:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100866:	74 61                	je     801008c9 <consoleintr+0xad>
80100868:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
8010086c:	0f 85 8c 00 00 00    	jne    801008fe <consoleintr+0xe2>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100872:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100879:	e9 10 01 00 00       	jmp    8010098e <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010087e:	a1 48 f7 10 80       	mov    0x8010f748,%eax
80100883:	83 e8 01             	sub    $0x1,%eax
80100886:	a3 48 f7 10 80       	mov    %eax,0x8010f748
        consputc(BACKSPACE);
8010088b:	83 ec 0c             	sub    $0xc,%esp
8010088e:	68 00 01 00 00       	push   $0x100
80100893:	e8 1d ff ff ff       	call   801007b5 <consputc>
80100898:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010089b:	8b 15 48 f7 10 80    	mov    0x8010f748,%edx
801008a1:	a1 44 f7 10 80       	mov    0x8010f744,%eax
801008a6:	39 c2                	cmp    %eax,%edx
801008a8:	0f 84 e0 00 00 00    	je     8010098e <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008ae:	a1 48 f7 10 80       	mov    0x8010f748,%eax
801008b3:	83 e8 01             	sub    $0x1,%eax
801008b6:	83 e0 7f             	and    $0x7f,%eax
801008b9:	0f b6 80 c0 f6 10 80 	movzbl -0x7fef0940(%eax),%eax
      while(input.e != input.w &&
801008c0:	3c 0a                	cmp    $0xa,%al
801008c2:	75 ba                	jne    8010087e <consoleintr+0x62>
      }
      break;
801008c4:	e9 c5 00 00 00       	jmp    8010098e <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008c9:	8b 15 48 f7 10 80    	mov    0x8010f748,%edx
801008cf:	a1 44 f7 10 80       	mov    0x8010f744,%eax
801008d4:	39 c2                	cmp    %eax,%edx
801008d6:	0f 84 b2 00 00 00    	je     8010098e <consoleintr+0x172>
        input.e--;
801008dc:	a1 48 f7 10 80       	mov    0x8010f748,%eax
801008e1:	83 e8 01             	sub    $0x1,%eax
801008e4:	a3 48 f7 10 80       	mov    %eax,0x8010f748
        consputc(BACKSPACE);
801008e9:	83 ec 0c             	sub    $0xc,%esp
801008ec:	68 00 01 00 00       	push   $0x100
801008f1:	e8 bf fe ff ff       	call   801007b5 <consputc>
801008f6:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008f9:	e9 90 00 00 00       	jmp    8010098e <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100902:	0f 84 85 00 00 00    	je     8010098d <consoleintr+0x171>
80100908:	a1 48 f7 10 80       	mov    0x8010f748,%eax
8010090d:	8b 15 40 f7 10 80    	mov    0x8010f740,%edx
80100913:	29 d0                	sub    %edx,%eax
80100915:	83 f8 7f             	cmp    $0x7f,%eax
80100918:	77 73                	ja     8010098d <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
8010091a:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010091e:	74 05                	je     80100925 <consoleintr+0x109>
80100920:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100923:	eb 05                	jmp    8010092a <consoleintr+0x10e>
80100925:	b8 0a 00 00 00       	mov    $0xa,%eax
8010092a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010092d:	a1 48 f7 10 80       	mov    0x8010f748,%eax
80100932:	8d 50 01             	lea    0x1(%eax),%edx
80100935:	89 15 48 f7 10 80    	mov    %edx,0x8010f748
8010093b:	83 e0 7f             	and    $0x7f,%eax
8010093e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100941:	88 90 c0 f6 10 80    	mov    %dl,-0x7fef0940(%eax)
        consputc(c);
80100947:	83 ec 0c             	sub    $0xc,%esp
8010094a:	ff 75 f0             	pushl  -0x10(%ebp)
8010094d:	e8 63 fe ff ff       	call   801007b5 <consputc>
80100952:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100955:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100959:	74 18                	je     80100973 <consoleintr+0x157>
8010095b:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
8010095f:	74 12                	je     80100973 <consoleintr+0x157>
80100961:	a1 48 f7 10 80       	mov    0x8010f748,%eax
80100966:	8b 15 40 f7 10 80    	mov    0x8010f740,%edx
8010096c:	83 ea 80             	sub    $0xffffff80,%edx
8010096f:	39 d0                	cmp    %edx,%eax
80100971:	75 1a                	jne    8010098d <consoleintr+0x171>
          input.w = input.e;
80100973:	a1 48 f7 10 80       	mov    0x8010f748,%eax
80100978:	a3 44 f7 10 80       	mov    %eax,0x8010f744
          wakeup(&input.r);
8010097d:	83 ec 0c             	sub    $0xc,%esp
80100980:	68 40 f7 10 80       	push   $0x8010f740
80100985:	e8 e9 44 00 00       	call   80104e73 <wakeup>
8010098a:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010098d:	90                   	nop
  while((c = getc()) >= 0){
8010098e:	8b 45 08             	mov    0x8(%ebp),%eax
80100991:	ff d0                	call   *%eax
80100993:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100996:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010099a:	0f 89 9e fe ff ff    	jns    8010083e <consoleintr+0x22>
    }
  }
  release(&cons.lock);
801009a0:	83 ec 0c             	sub    $0xc,%esp
801009a3:	68 60 f7 10 80       	push   $0x8010f760
801009a8:	e8 3c 47 00 00       	call   801050e9 <release>
801009ad:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b4:	74 05                	je     801009bb <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
801009b6:	e8 73 45 00 00       	call   80104f2e <procdump>
  }
}
801009bb:	90                   	nop
801009bc:	c9                   	leave  
801009bd:	c3                   	ret    

801009be <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009be:	55                   	push   %ebp
801009bf:	89 e5                	mov    %esp,%ebp
801009c1:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009c4:	83 ec 0c             	sub    $0xc,%esp
801009c7:	ff 75 08             	pushl  0x8(%ebp)
801009ca:	e8 26 11 00 00       	call   80101af5 <iunlock>
801009cf:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d2:	8b 45 10             	mov    0x10(%ebp),%eax
801009d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009d8:	83 ec 0c             	sub    $0xc,%esp
801009db:	68 60 f7 10 80       	push   $0x8010f760
801009e0:	e8 9d 46 00 00       	call   80105082 <acquire>
801009e5:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009e8:	e9 ac 00 00 00       	jmp    80100a99 <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009f3:	8b 40 24             	mov    0x24(%eax),%eax
801009f6:	85 c0                	test   %eax,%eax
801009f8:	74 28                	je     80100a22 <consoleread+0x64>
        release(&cons.lock);
801009fa:	83 ec 0c             	sub    $0xc,%esp
801009fd:	68 60 f7 10 80       	push   $0x8010f760
80100a02:	e8 e2 46 00 00       	call   801050e9 <release>
80100a07:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a0a:	83 ec 0c             	sub    $0xc,%esp
80100a0d:	ff 75 08             	pushl  0x8(%ebp)
80100a10:	e8 82 0f 00 00       	call   80101997 <ilock>
80100a15:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a1d:	e9 a9 00 00 00       	jmp    80100acb <consoleread+0x10d>
      }
      sleep(&input.r, &cons.lock);
80100a22:	83 ec 08             	sub    $0x8,%esp
80100a25:	68 60 f7 10 80       	push   $0x8010f760
80100a2a:	68 40 f7 10 80       	push   $0x8010f740
80100a2f:	e8 53 43 00 00       	call   80104d87 <sleep>
80100a34:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a37:	8b 15 40 f7 10 80    	mov    0x8010f740,%edx
80100a3d:	a1 44 f7 10 80       	mov    0x8010f744,%eax
80100a42:	39 c2                	cmp    %eax,%edx
80100a44:	74 a7                	je     801009ed <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a46:	a1 40 f7 10 80       	mov    0x8010f740,%eax
80100a4b:	8d 50 01             	lea    0x1(%eax),%edx
80100a4e:	89 15 40 f7 10 80    	mov    %edx,0x8010f740
80100a54:	83 e0 7f             	and    $0x7f,%eax
80100a57:	0f b6 80 c0 f6 10 80 	movzbl -0x7fef0940(%eax),%eax
80100a5e:	0f be c0             	movsbl %al,%eax
80100a61:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a64:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a68:	75 17                	jne    80100a81 <consoleread+0xc3>
      if(n < target){
80100a6a:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a70:	76 2f                	jbe    80100aa1 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a72:	a1 40 f7 10 80       	mov    0x8010f740,%eax
80100a77:	83 e8 01             	sub    $0x1,%eax
80100a7a:	a3 40 f7 10 80       	mov    %eax,0x8010f740
      }
      break;
80100a7f:	eb 20                	jmp    80100aa1 <consoleread+0xe3>
    }
    *dst++ = c;
80100a81:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a84:	8d 50 01             	lea    0x1(%eax),%edx
80100a87:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a8d:	88 10                	mov    %dl,(%eax)
    --n;
80100a8f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a93:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a97:	74 0b                	je     80100aa4 <consoleread+0xe6>
  while(n > 0){
80100a99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a9d:	7f 98                	jg     80100a37 <consoleread+0x79>
80100a9f:	eb 04                	jmp    80100aa5 <consoleread+0xe7>
      break;
80100aa1:	90                   	nop
80100aa2:	eb 01                	jmp    80100aa5 <consoleread+0xe7>
      break;
80100aa4:	90                   	nop
  }
  release(&cons.lock);
80100aa5:	83 ec 0c             	sub    $0xc,%esp
80100aa8:	68 60 f7 10 80       	push   $0x8010f760
80100aad:	e8 37 46 00 00       	call   801050e9 <release>
80100ab2:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ab5:	83 ec 0c             	sub    $0xc,%esp
80100ab8:	ff 75 08             	pushl  0x8(%ebp)
80100abb:	e8 d7 0e 00 00       	call   80101997 <ilock>
80100ac0:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100ac3:	8b 55 10             	mov    0x10(%ebp),%edx
80100ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ac9:	29 d0                	sub    %edx,%eax
}
80100acb:	c9                   	leave  
80100acc:	c3                   	ret    

80100acd <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100acd:	55                   	push   %ebp
80100ace:	89 e5                	mov    %esp,%ebp
80100ad0:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100ad3:	83 ec 0c             	sub    $0xc,%esp
80100ad6:	ff 75 08             	pushl  0x8(%ebp)
80100ad9:	e8 17 10 00 00       	call   80101af5 <iunlock>
80100ade:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ae1:	83 ec 0c             	sub    $0xc,%esp
80100ae4:	68 60 f7 10 80       	push   $0x8010f760
80100ae9:	e8 94 45 00 00       	call   80105082 <acquire>
80100aee:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100af1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100af8:	eb 21                	jmp    80100b1b <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100afa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100afd:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b00:	01 d0                	add    %edx,%eax
80100b02:	0f b6 00             	movzbl (%eax),%eax
80100b05:	0f be c0             	movsbl %al,%eax
80100b08:	0f b6 c0             	movzbl %al,%eax
80100b0b:	83 ec 0c             	sub    $0xc,%esp
80100b0e:	50                   	push   %eax
80100b0f:	e8 a1 fc ff ff       	call   801007b5 <consputc>
80100b14:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b1e:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b21:	7c d7                	jl     80100afa <consolewrite+0x2d>
  release(&cons.lock);
80100b23:	83 ec 0c             	sub    $0xc,%esp
80100b26:	68 60 f7 10 80       	push   $0x8010f760
80100b2b:	e8 b9 45 00 00       	call   801050e9 <release>
80100b30:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b33:	83 ec 0c             	sub    $0xc,%esp
80100b36:	ff 75 08             	pushl  0x8(%ebp)
80100b39:	e8 59 0e 00 00       	call   80101997 <ilock>
80100b3e:	83 c4 10             	add    $0x10,%esp

  return n;
80100b41:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b44:	c9                   	leave  
80100b45:	c3                   	ret    

80100b46 <consoleinit>:

void
consoleinit(void)
{
80100b46:	55                   	push   %ebp
80100b47:	89 e5                	mov    %esp,%ebp
80100b49:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b4c:	83 ec 08             	sub    $0x8,%esp
80100b4f:	68 8a 86 10 80       	push   $0x8010868a
80100b54:	68 60 f7 10 80       	push   $0x8010f760
80100b59:	e8 02 45 00 00       	call   80105060 <initlock>
80100b5e:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b61:	c7 05 ac f7 10 80 cd 	movl   $0x80100acd,0x8010f7ac
80100b68:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6b:	c7 05 a8 f7 10 80 be 	movl   $0x801009be,0x8010f7a8
80100b72:	09 10 80 
  cons.locking = 1;
80100b75:	c7 05 94 f7 10 80 01 	movl   $0x1,0x8010f794
80100b7c:	00 00 00 

  picenable(IRQ_KBD);
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	6a 01                	push   $0x1
80100b84:	e8 df 33 00 00       	call   80103f68 <picenable>
80100b89:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b8c:	83 ec 08             	sub    $0x8,%esp
80100b8f:	6a 00                	push   $0x0
80100b91:	6a 01                	push   $0x1
80100b93:	e8 64 1f 00 00       	call   80102afc <ioapicenable>
80100b98:	83 c4 10             	add    $0x10,%esp
}
80100b9b:	90                   	nop
80100b9c:	c9                   	leave  
80100b9d:	c3                   	ret    

80100b9e <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b9e:	55                   	push   %ebp
80100b9f:	89 e5                	mov    %esp,%ebp
80100ba1:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100ba7:	e8 c0 29 00 00       	call   8010356c <begin_op>
  if((ip = namei(path)) == 0){
80100bac:	83 ec 0c             	sub    $0xc,%esp
80100baf:	ff 75 08             	pushl  0x8(%ebp)
80100bb2:	e8 91 19 00 00       	call   80102548 <namei>
80100bb7:	83 c4 10             	add    $0x10,%esp
80100bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bbd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc1:	75 0f                	jne    80100bd2 <exec+0x34>
    end_op();
80100bc3:	e8 30 2a 00 00       	call   801035f8 <end_op>
    return -1;
80100bc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bcd:	e9 ce 03 00 00       	jmp    80100fa0 <exec+0x402>
  }
  ilock(ip);
80100bd2:	83 ec 0c             	sub    $0xc,%esp
80100bd5:	ff 75 d8             	pushl  -0x28(%ebp)
80100bd8:	e8 ba 0d 00 00       	call   80101997 <ilock>
80100bdd:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100be0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100be7:	6a 34                	push   $0x34
80100be9:	6a 00                	push   $0x0
80100beb:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bf1:	50                   	push   %eax
80100bf2:	ff 75 d8             	pushl  -0x28(%ebp)
80100bf5:	e8 06 13 00 00       	call   80101f00 <readi>
80100bfa:	83 c4 10             	add    $0x10,%esp
80100bfd:	83 f8 33             	cmp    $0x33,%eax
80100c00:	0f 86 49 03 00 00    	jbe    80100f4f <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c06:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c0c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c11:	0f 85 3b 03 00 00    	jne    80100f52 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c17:	e8 ef 71 00 00       	call   80107e0b <setupkvm>
80100c1c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c1f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c23:	0f 84 2c 03 00 00    	je     80100f55 <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c29:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c30:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c37:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c3d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c40:	e9 ab 00 00 00       	jmp    80100cf0 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c45:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c48:	6a 20                	push   $0x20
80100c4a:	50                   	push   %eax
80100c4b:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c51:	50                   	push   %eax
80100c52:	ff 75 d8             	pushl  -0x28(%ebp)
80100c55:	e8 a6 12 00 00       	call   80101f00 <readi>
80100c5a:	83 c4 10             	add    $0x10,%esp
80100c5d:	83 f8 20             	cmp    $0x20,%eax
80100c60:	0f 85 f2 02 00 00    	jne    80100f58 <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c66:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c6c:	83 f8 01             	cmp    $0x1,%eax
80100c6f:	75 71                	jne    80100ce2 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c71:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c77:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c7d:	39 c2                	cmp    %eax,%edx
80100c7f:	0f 82 d6 02 00 00    	jb     80100f5b <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c85:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c8b:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c91:	01 d0                	add    %edx,%eax
80100c93:	83 ec 04             	sub    $0x4,%esp
80100c96:	50                   	push   %eax
80100c97:	ff 75 e0             	pushl  -0x20(%ebp)
80100c9a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c9d:	e8 11 75 00 00       	call   801081b3 <allocuvm>
80100ca2:	83 c4 10             	add    $0x10,%esp
80100ca5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ca8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cac:	0f 84 ac 02 00 00    	je     80100f5e <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cb2:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cb8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cbe:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100cc4:	83 ec 0c             	sub    $0xc,%esp
80100cc7:	52                   	push   %edx
80100cc8:	50                   	push   %eax
80100cc9:	ff 75 d8             	pushl  -0x28(%ebp)
80100ccc:	51                   	push   %ecx
80100ccd:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cd0:	e8 07 74 00 00       	call   801080dc <loaduvm>
80100cd5:	83 c4 20             	add    $0x20,%esp
80100cd8:	85 c0                	test   %eax,%eax
80100cda:	0f 88 81 02 00 00    	js     80100f61 <exec+0x3c3>
80100ce0:	eb 01                	jmp    80100ce3 <exec+0x145>
      continue;
80100ce2:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ce3:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100ce7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cea:	83 c0 20             	add    $0x20,%eax
80100ced:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cf0:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cf7:	0f b7 c0             	movzwl %ax,%eax
80100cfa:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100cfd:	0f 8c 42 ff ff ff    	jl     80100c45 <exec+0xa7>
      goto bad;
  }
  iunlockput(ip);
80100d03:	83 ec 0c             	sub    $0xc,%esp
80100d06:	ff 75 d8             	pushl  -0x28(%ebp)
80100d09:	e8 49 0f 00 00       	call   80101c57 <iunlockput>
80100d0e:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d11:	e8 e2 28 00 00       	call   801035f8 <end_op>
  ip = 0;
80100d16:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d20:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d2a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d30:	05 00 20 00 00       	add    $0x2000,%eax
80100d35:	83 ec 04             	sub    $0x4,%esp
80100d38:	50                   	push   %eax
80100d39:	ff 75 e0             	pushl  -0x20(%ebp)
80100d3c:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d3f:	e8 6f 74 00 00       	call   801081b3 <allocuvm>
80100d44:	83 c4 10             	add    $0x10,%esp
80100d47:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d4a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d4e:	0f 84 10 02 00 00    	je     80100f64 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d57:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d5c:	83 ec 08             	sub    $0x8,%esp
80100d5f:	50                   	push   %eax
80100d60:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d63:	e8 6f 76 00 00       	call   801083d7 <clearpteu>
80100d68:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d6e:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d71:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d78:	e9 96 00 00 00       	jmp    80100e13 <exec+0x275>
    if(argc >= MAXARG)
80100d7d:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d81:	0f 87 e0 01 00 00    	ja     80100f67 <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d94:	01 d0                	add    %edx,%eax
80100d96:	8b 00                	mov    (%eax),%eax
80100d98:	83 ec 0c             	sub    $0xc,%esp
80100d9b:	50                   	push   %eax
80100d9c:	e8 91 47 00 00       	call   80105532 <strlen>
80100da1:	83 c4 10             	add    $0x10,%esp
80100da4:	89 c2                	mov    %eax,%edx
80100da6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100da9:	29 d0                	sub    %edx,%eax
80100dab:	83 e8 01             	sub    $0x1,%eax
80100dae:	83 e0 fc             	and    $0xfffffffc,%eax
80100db1:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	8b 00                	mov    (%eax),%eax
80100dc5:	83 ec 0c             	sub    $0xc,%esp
80100dc8:	50                   	push   %eax
80100dc9:	e8 64 47 00 00       	call   80105532 <strlen>
80100dce:	83 c4 10             	add    $0x10,%esp
80100dd1:	83 c0 01             	add    $0x1,%eax
80100dd4:	89 c2                	mov    %eax,%edx
80100dd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100de0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100de3:	01 c8                	add    %ecx,%eax
80100de5:	8b 00                	mov    (%eax),%eax
80100de7:	52                   	push   %edx
80100de8:	50                   	push   %eax
80100de9:	ff 75 dc             	pushl  -0x24(%ebp)
80100dec:	ff 75 d4             	pushl  -0x2c(%ebp)
80100def:	e8 99 77 00 00       	call   8010858d <copyout>
80100df4:	83 c4 10             	add    $0x10,%esp
80100df7:	85 c0                	test   %eax,%eax
80100df9:	0f 88 6b 01 00 00    	js     80100f6a <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	8d 50 03             	lea    0x3(%eax),%edx
80100e05:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e08:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e0f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e20:	01 d0                	add    %edx,%eax
80100e22:	8b 00                	mov    (%eax),%eax
80100e24:	85 c0                	test   %eax,%eax
80100e26:	0f 85 51 ff ff ff    	jne    80100d7d <exec+0x1df>
  }
  ustack[3+argc] = 0;
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	83 c0 03             	add    $0x3,%eax
80100e32:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e39:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e3d:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e44:	ff ff ff 
  ustack[1] = argc;
80100e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4a:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e53:	83 c0 01             	add    $0x1,%eax
80100e56:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e5d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e60:	29 d0                	sub    %edx,%eax
80100e62:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6b:	83 c0 04             	add    $0x4,%eax
80100e6e:	c1 e0 02             	shl    $0x2,%eax
80100e71:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	83 c0 04             	add    $0x4,%eax
80100e7a:	c1 e0 02             	shl    $0x2,%eax
80100e7d:	50                   	push   %eax
80100e7e:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e84:	50                   	push   %eax
80100e85:	ff 75 dc             	pushl  -0x24(%ebp)
80100e88:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e8b:	e8 fd 76 00 00       	call   8010858d <copyout>
80100e90:	83 c4 10             	add    $0x10,%esp
80100e93:	85 c0                	test   %eax,%eax
80100e95:	0f 88 d2 00 00 00    	js     80100f6d <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80100e9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ea4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ea7:	eb 17                	jmp    80100ec0 <exec+0x322>
    if(*s == '/')
80100ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eac:	0f b6 00             	movzbl (%eax),%eax
80100eaf:	3c 2f                	cmp    $0x2f,%al
80100eb1:	75 09                	jne    80100ebc <exec+0x31e>
      last = s+1;
80100eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eb6:	83 c0 01             	add    $0x1,%eax
80100eb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ebc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ec3:	0f b6 00             	movzbl (%eax),%eax
80100ec6:	84 c0                	test   %al,%al
80100ec8:	75 df                	jne    80100ea9 <exec+0x30b>
  safestrcpy(proc->name, last, sizeof(proc->name));
80100eca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed0:	83 c0 6c             	add    $0x6c,%eax
80100ed3:	83 ec 04             	sub    $0x4,%esp
80100ed6:	6a 10                	push   $0x10
80100ed8:	ff 75 f0             	pushl  -0x10(%ebp)
80100edb:	50                   	push   %eax
80100edc:	e8 07 46 00 00       	call   801054e8 <safestrcpy>
80100ee1:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100ee4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eea:	8b 40 04             	mov    0x4(%eax),%eax
80100eed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ef0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ef6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ef9:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100efc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f02:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f05:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f0d:	8b 40 18             	mov    0x18(%eax),%eax
80100f10:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f16:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f1f:	8b 40 18             	mov    0x18(%eax),%eax
80100f22:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f25:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f2e:	83 ec 0c             	sub    $0xc,%esp
80100f31:	50                   	push   %eax
80100f32:	e8 bb 6f 00 00       	call   80107ef2 <switchuvm>
80100f37:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f3a:	83 ec 0c             	sub    $0xc,%esp
80100f3d:	ff 75 d0             	pushl  -0x30(%ebp)
80100f40:	e8 f2 73 00 00       	call   80108337 <freevm>
80100f45:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f48:	b8 00 00 00 00       	mov    $0x0,%eax
80100f4d:	eb 51                	jmp    80100fa0 <exec+0x402>
    goto bad;
80100f4f:	90                   	nop
80100f50:	eb 1c                	jmp    80100f6e <exec+0x3d0>
    goto bad;
80100f52:	90                   	nop
80100f53:	eb 19                	jmp    80100f6e <exec+0x3d0>
    goto bad;
80100f55:	90                   	nop
80100f56:	eb 16                	jmp    80100f6e <exec+0x3d0>
      goto bad;
80100f58:	90                   	nop
80100f59:	eb 13                	jmp    80100f6e <exec+0x3d0>
      goto bad;
80100f5b:	90                   	nop
80100f5c:	eb 10                	jmp    80100f6e <exec+0x3d0>
      goto bad;
80100f5e:	90                   	nop
80100f5f:	eb 0d                	jmp    80100f6e <exec+0x3d0>
      goto bad;
80100f61:	90                   	nop
80100f62:	eb 0a                	jmp    80100f6e <exec+0x3d0>
    goto bad;
80100f64:	90                   	nop
80100f65:	eb 07                	jmp    80100f6e <exec+0x3d0>
      goto bad;
80100f67:	90                   	nop
80100f68:	eb 04                	jmp    80100f6e <exec+0x3d0>
      goto bad;
80100f6a:	90                   	nop
80100f6b:	eb 01                	jmp    80100f6e <exec+0x3d0>
    goto bad;
80100f6d:	90                   	nop

 bad:
  if(pgdir)
80100f6e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f72:	74 0e                	je     80100f82 <exec+0x3e4>
    freevm(pgdir);
80100f74:	83 ec 0c             	sub    $0xc,%esp
80100f77:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f7a:	e8 b8 73 00 00       	call   80108337 <freevm>
80100f7f:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f82:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f86:	74 13                	je     80100f9b <exec+0x3fd>
    iunlockput(ip);
80100f88:	83 ec 0c             	sub    $0xc,%esp
80100f8b:	ff 75 d8             	pushl  -0x28(%ebp)
80100f8e:	e8 c4 0c 00 00       	call   80101c57 <iunlockput>
80100f93:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f96:	e8 5d 26 00 00       	call   801035f8 <end_op>
  }
  return -1;
80100f9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fa0:	c9                   	leave  
80100fa1:	c3                   	ret    

80100fa2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fa2:	55                   	push   %ebp
80100fa3:	89 e5                	mov    %esp,%ebp
80100fa5:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fa8:	83 ec 08             	sub    $0x8,%esp
80100fab:	68 92 86 10 80       	push   $0x80108692
80100fb0:	68 00 f8 10 80       	push   $0x8010f800
80100fb5:	e8 a6 40 00 00       	call   80105060 <initlock>
80100fba:	83 c4 10             	add    $0x10,%esp
}
80100fbd:	90                   	nop
80100fbe:	c9                   	leave  
80100fbf:	c3                   	ret    

80100fc0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fc0:	55                   	push   %ebp
80100fc1:	89 e5                	mov    %esp,%ebp
80100fc3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fc6:	83 ec 0c             	sub    $0xc,%esp
80100fc9:	68 00 f8 10 80       	push   $0x8010f800
80100fce:	e8 af 40 00 00       	call   80105082 <acquire>
80100fd3:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fd6:	c7 45 f4 34 f8 10 80 	movl   $0x8010f834,-0xc(%ebp)
80100fdd:	eb 2d                	jmp    8010100c <filealloc+0x4c>
    if(f->ref == 0){
80100fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fe2:	8b 40 04             	mov    0x4(%eax),%eax
80100fe5:	85 c0                	test   %eax,%eax
80100fe7:	75 1f                	jne    80101008 <filealloc+0x48>
      f->ref = 1;
80100fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fec:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100ff3:	83 ec 0c             	sub    $0xc,%esp
80100ff6:	68 00 f8 10 80       	push   $0x8010f800
80100ffb:	e8 e9 40 00 00       	call   801050e9 <release>
80101000:	83 c4 10             	add    $0x10,%esp
      return f;
80101003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101006:	eb 23                	jmp    8010102b <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101008:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010100c:	b8 94 01 11 80       	mov    $0x80110194,%eax
80101011:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101014:	72 c9                	jb     80100fdf <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101016:	83 ec 0c             	sub    $0xc,%esp
80101019:	68 00 f8 10 80       	push   $0x8010f800
8010101e:	e8 c6 40 00 00       	call   801050e9 <release>
80101023:	83 c4 10             	add    $0x10,%esp
  return 0;
80101026:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010102b:	c9                   	leave  
8010102c:	c3                   	ret    

8010102d <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010102d:	55                   	push   %ebp
8010102e:	89 e5                	mov    %esp,%ebp
80101030:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	68 00 f8 10 80       	push   $0x8010f800
8010103b:	e8 42 40 00 00       	call   80105082 <acquire>
80101040:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101043:	8b 45 08             	mov    0x8(%ebp),%eax
80101046:	8b 40 04             	mov    0x4(%eax),%eax
80101049:	85 c0                	test   %eax,%eax
8010104b:	7f 0d                	jg     8010105a <filedup+0x2d>
    panic("filedup");
8010104d:	83 ec 0c             	sub    $0xc,%esp
80101050:	68 99 86 10 80       	push   $0x80108699
80101055:	e8 21 f5 ff ff       	call   8010057b <panic>
  f->ref++;
8010105a:	8b 45 08             	mov    0x8(%ebp),%eax
8010105d:	8b 40 04             	mov    0x4(%eax),%eax
80101060:	8d 50 01             	lea    0x1(%eax),%edx
80101063:	8b 45 08             	mov    0x8(%ebp),%eax
80101066:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101069:	83 ec 0c             	sub    $0xc,%esp
8010106c:	68 00 f8 10 80       	push   $0x8010f800
80101071:	e8 73 40 00 00       	call   801050e9 <release>
80101076:	83 c4 10             	add    $0x10,%esp
  return f;
80101079:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010107c:	c9                   	leave  
8010107d:	c3                   	ret    

8010107e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010107e:	55                   	push   %ebp
8010107f:	89 e5                	mov    %esp,%ebp
80101081:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101084:	83 ec 0c             	sub    $0xc,%esp
80101087:	68 00 f8 10 80       	push   $0x8010f800
8010108c:	e8 f1 3f 00 00       	call   80105082 <acquire>
80101091:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101094:	8b 45 08             	mov    0x8(%ebp),%eax
80101097:	8b 40 04             	mov    0x4(%eax),%eax
8010109a:	85 c0                	test   %eax,%eax
8010109c:	7f 0d                	jg     801010ab <fileclose+0x2d>
    panic("fileclose");
8010109e:	83 ec 0c             	sub    $0xc,%esp
801010a1:	68 a1 86 10 80       	push   $0x801086a1
801010a6:	e8 d0 f4 ff ff       	call   8010057b <panic>
  if(--f->ref > 0){
801010ab:	8b 45 08             	mov    0x8(%ebp),%eax
801010ae:	8b 40 04             	mov    0x4(%eax),%eax
801010b1:	8d 50 ff             	lea    -0x1(%eax),%edx
801010b4:	8b 45 08             	mov    0x8(%ebp),%eax
801010b7:	89 50 04             	mov    %edx,0x4(%eax)
801010ba:	8b 45 08             	mov    0x8(%ebp),%eax
801010bd:	8b 40 04             	mov    0x4(%eax),%eax
801010c0:	85 c0                	test   %eax,%eax
801010c2:	7e 15                	jle    801010d9 <fileclose+0x5b>
    release(&ftable.lock);
801010c4:	83 ec 0c             	sub    $0xc,%esp
801010c7:	68 00 f8 10 80       	push   $0x8010f800
801010cc:	e8 18 40 00 00       	call   801050e9 <release>
801010d1:	83 c4 10             	add    $0x10,%esp
801010d4:	e9 8b 00 00 00       	jmp    80101164 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010d9:	8b 45 08             	mov    0x8(%ebp),%eax
801010dc:	8b 10                	mov    (%eax),%edx
801010de:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010e1:	8b 50 04             	mov    0x4(%eax),%edx
801010e4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010e7:	8b 50 08             	mov    0x8(%eax),%edx
801010ea:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010ed:	8b 50 0c             	mov    0xc(%eax),%edx
801010f0:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010f3:	8b 50 10             	mov    0x10(%eax),%edx
801010f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010f9:	8b 40 14             	mov    0x14(%eax),%eax
801010fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101102:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101109:	8b 45 08             	mov    0x8(%ebp),%eax
8010110c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101112:	83 ec 0c             	sub    $0xc,%esp
80101115:	68 00 f8 10 80       	push   $0x8010f800
8010111a:	e8 ca 3f 00 00       	call   801050e9 <release>
8010111f:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
80101122:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101125:	83 f8 01             	cmp    $0x1,%eax
80101128:	75 19                	jne    80101143 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010112a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010112e:	0f be d0             	movsbl %al,%edx
80101131:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101134:	83 ec 08             	sub    $0x8,%esp
80101137:	52                   	push   %edx
80101138:	50                   	push   %eax
80101139:	e8 92 30 00 00       	call   801041d0 <pipeclose>
8010113e:	83 c4 10             	add    $0x10,%esp
80101141:	eb 21                	jmp    80101164 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101143:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101146:	83 f8 02             	cmp    $0x2,%eax
80101149:	75 19                	jne    80101164 <fileclose+0xe6>
    begin_op();
8010114b:	e8 1c 24 00 00       	call   8010356c <begin_op>
    iput(ff.ip);
80101150:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101153:	83 ec 0c             	sub    $0xc,%esp
80101156:	50                   	push   %eax
80101157:	e8 0b 0a 00 00       	call   80101b67 <iput>
8010115c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010115f:	e8 94 24 00 00       	call   801035f8 <end_op>
  }
}
80101164:	c9                   	leave  
80101165:	c3                   	ret    

80101166 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101166:	55                   	push   %ebp
80101167:	89 e5                	mov    %esp,%ebp
80101169:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010116c:	8b 45 08             	mov    0x8(%ebp),%eax
8010116f:	8b 00                	mov    (%eax),%eax
80101171:	83 f8 02             	cmp    $0x2,%eax
80101174:	75 40                	jne    801011b6 <filestat+0x50>
    ilock(f->ip);
80101176:	8b 45 08             	mov    0x8(%ebp),%eax
80101179:	8b 40 10             	mov    0x10(%eax),%eax
8010117c:	83 ec 0c             	sub    $0xc,%esp
8010117f:	50                   	push   %eax
80101180:	e8 12 08 00 00       	call   80101997 <ilock>
80101185:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101188:	8b 45 08             	mov    0x8(%ebp),%eax
8010118b:	8b 40 10             	mov    0x10(%eax),%eax
8010118e:	83 ec 08             	sub    $0x8,%esp
80101191:	ff 75 0c             	pushl  0xc(%ebp)
80101194:	50                   	push   %eax
80101195:	e8 20 0d 00 00       	call   80101eba <stati>
8010119a:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010119d:	8b 45 08             	mov    0x8(%ebp),%eax
801011a0:	8b 40 10             	mov    0x10(%eax),%eax
801011a3:	83 ec 0c             	sub    $0xc,%esp
801011a6:	50                   	push   %eax
801011a7:	e8 49 09 00 00       	call   80101af5 <iunlock>
801011ac:	83 c4 10             	add    $0x10,%esp
    return 0;
801011af:	b8 00 00 00 00       	mov    $0x0,%eax
801011b4:	eb 05                	jmp    801011bb <filestat+0x55>
  }
  return -1;
801011b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011bb:	c9                   	leave  
801011bc:	c3                   	ret    

801011bd <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011bd:	55                   	push   %ebp
801011be:	89 e5                	mov    %esp,%ebp
801011c0:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011c3:	8b 45 08             	mov    0x8(%ebp),%eax
801011c6:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011ca:	84 c0                	test   %al,%al
801011cc:	75 0a                	jne    801011d8 <fileread+0x1b>
    return -1;
801011ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011d3:	e9 9b 00 00 00       	jmp    80101273 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011d8:	8b 45 08             	mov    0x8(%ebp),%eax
801011db:	8b 00                	mov    (%eax),%eax
801011dd:	83 f8 01             	cmp    $0x1,%eax
801011e0:	75 1a                	jne    801011fc <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011e2:	8b 45 08             	mov    0x8(%ebp),%eax
801011e5:	8b 40 0c             	mov    0xc(%eax),%eax
801011e8:	83 ec 04             	sub    $0x4,%esp
801011eb:	ff 75 10             	pushl  0x10(%ebp)
801011ee:	ff 75 0c             	pushl  0xc(%ebp)
801011f1:	50                   	push   %eax
801011f2:	e8 87 31 00 00       	call   8010437e <piperead>
801011f7:	83 c4 10             	add    $0x10,%esp
801011fa:	eb 77                	jmp    80101273 <fileread+0xb6>
  if(f->type == FD_INODE){
801011fc:	8b 45 08             	mov    0x8(%ebp),%eax
801011ff:	8b 00                	mov    (%eax),%eax
80101201:	83 f8 02             	cmp    $0x2,%eax
80101204:	75 60                	jne    80101266 <fileread+0xa9>
    ilock(f->ip);
80101206:	8b 45 08             	mov    0x8(%ebp),%eax
80101209:	8b 40 10             	mov    0x10(%eax),%eax
8010120c:	83 ec 0c             	sub    $0xc,%esp
8010120f:	50                   	push   %eax
80101210:	e8 82 07 00 00       	call   80101997 <ilock>
80101215:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101218:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010121b:	8b 45 08             	mov    0x8(%ebp),%eax
8010121e:	8b 50 14             	mov    0x14(%eax),%edx
80101221:	8b 45 08             	mov    0x8(%ebp),%eax
80101224:	8b 40 10             	mov    0x10(%eax),%eax
80101227:	51                   	push   %ecx
80101228:	52                   	push   %edx
80101229:	ff 75 0c             	pushl  0xc(%ebp)
8010122c:	50                   	push   %eax
8010122d:	e8 ce 0c 00 00       	call   80101f00 <readi>
80101232:	83 c4 10             	add    $0x10,%esp
80101235:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101238:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010123c:	7e 11                	jle    8010124f <fileread+0x92>
      f->off += r;
8010123e:	8b 45 08             	mov    0x8(%ebp),%eax
80101241:	8b 50 14             	mov    0x14(%eax),%edx
80101244:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101247:	01 c2                	add    %eax,%edx
80101249:	8b 45 08             	mov    0x8(%ebp),%eax
8010124c:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010124f:	8b 45 08             	mov    0x8(%ebp),%eax
80101252:	8b 40 10             	mov    0x10(%eax),%eax
80101255:	83 ec 0c             	sub    $0xc,%esp
80101258:	50                   	push   %eax
80101259:	e8 97 08 00 00       	call   80101af5 <iunlock>
8010125e:	83 c4 10             	add    $0x10,%esp
    return r;
80101261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101264:	eb 0d                	jmp    80101273 <fileread+0xb6>
  }
  panic("fileread");
80101266:	83 ec 0c             	sub    $0xc,%esp
80101269:	68 ab 86 10 80       	push   $0x801086ab
8010126e:	e8 08 f3 ff ff       	call   8010057b <panic>
}
80101273:	c9                   	leave  
80101274:	c3                   	ret    

80101275 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101275:	55                   	push   %ebp
80101276:	89 e5                	mov    %esp,%ebp
80101278:	53                   	push   %ebx
80101279:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010127c:	8b 45 08             	mov    0x8(%ebp),%eax
8010127f:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101283:	84 c0                	test   %al,%al
80101285:	75 0a                	jne    80101291 <filewrite+0x1c>
    return -1;
80101287:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010128c:	e9 1b 01 00 00       	jmp    801013ac <filewrite+0x137>
  if(f->type == FD_PIPE)
80101291:	8b 45 08             	mov    0x8(%ebp),%eax
80101294:	8b 00                	mov    (%eax),%eax
80101296:	83 f8 01             	cmp    $0x1,%eax
80101299:	75 1d                	jne    801012b8 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010129b:	8b 45 08             	mov    0x8(%ebp),%eax
8010129e:	8b 40 0c             	mov    0xc(%eax),%eax
801012a1:	83 ec 04             	sub    $0x4,%esp
801012a4:	ff 75 10             	pushl  0x10(%ebp)
801012a7:	ff 75 0c             	pushl  0xc(%ebp)
801012aa:	50                   	push   %eax
801012ab:	e8 cb 2f 00 00       	call   8010427b <pipewrite>
801012b0:	83 c4 10             	add    $0x10,%esp
801012b3:	e9 f4 00 00 00       	jmp    801013ac <filewrite+0x137>
  if(f->type == FD_INODE){
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 00                	mov    (%eax),%eax
801012bd:	83 f8 02             	cmp    $0x2,%eax
801012c0:	0f 85 d9 00 00 00    	jne    8010139f <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801012c6:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012d4:	e9 a3 00 00 00       	jmp    8010137c <filewrite+0x107>
      int n1 = n - i;
801012d9:	8b 45 10             	mov    0x10(%ebp),%eax
801012dc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012df:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012e5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012e8:	7e 06                	jle    801012f0 <filewrite+0x7b>
        n1 = max;
801012ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012ed:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012f0:	e8 77 22 00 00       	call   8010356c <begin_op>
      ilock(f->ip);
801012f5:	8b 45 08             	mov    0x8(%ebp),%eax
801012f8:	8b 40 10             	mov    0x10(%eax),%eax
801012fb:	83 ec 0c             	sub    $0xc,%esp
801012fe:	50                   	push   %eax
801012ff:	e8 93 06 00 00       	call   80101997 <ilock>
80101304:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101307:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010130a:	8b 45 08             	mov    0x8(%ebp),%eax
8010130d:	8b 50 14             	mov    0x14(%eax),%edx
80101310:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101313:	8b 45 0c             	mov    0xc(%ebp),%eax
80101316:	01 c3                	add    %eax,%ebx
80101318:	8b 45 08             	mov    0x8(%ebp),%eax
8010131b:	8b 40 10             	mov    0x10(%eax),%eax
8010131e:	51                   	push   %ecx
8010131f:	52                   	push   %edx
80101320:	53                   	push   %ebx
80101321:	50                   	push   %eax
80101322:	e8 2e 0d 00 00       	call   80102055 <writei>
80101327:	83 c4 10             	add    $0x10,%esp
8010132a:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010132d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101331:	7e 11                	jle    80101344 <filewrite+0xcf>
        f->off += r;
80101333:	8b 45 08             	mov    0x8(%ebp),%eax
80101336:	8b 50 14             	mov    0x14(%eax),%edx
80101339:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010133c:	01 c2                	add    %eax,%edx
8010133e:	8b 45 08             	mov    0x8(%ebp),%eax
80101341:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101344:	8b 45 08             	mov    0x8(%ebp),%eax
80101347:	8b 40 10             	mov    0x10(%eax),%eax
8010134a:	83 ec 0c             	sub    $0xc,%esp
8010134d:	50                   	push   %eax
8010134e:	e8 a2 07 00 00       	call   80101af5 <iunlock>
80101353:	83 c4 10             	add    $0x10,%esp
      end_op();
80101356:	e8 9d 22 00 00       	call   801035f8 <end_op>

      if(r < 0)
8010135b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010135f:	78 29                	js     8010138a <filewrite+0x115>
        break;
      if(r != n1)
80101361:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101364:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101367:	74 0d                	je     80101376 <filewrite+0x101>
        panic("short filewrite");
80101369:	83 ec 0c             	sub    $0xc,%esp
8010136c:	68 b4 86 10 80       	push   $0x801086b4
80101371:	e8 05 f2 ff ff       	call   8010057b <panic>
      i += r;
80101376:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101379:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
8010137c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010137f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101382:	0f 8c 51 ff ff ff    	jl     801012d9 <filewrite+0x64>
80101388:	eb 01                	jmp    8010138b <filewrite+0x116>
        break;
8010138a:	90                   	nop
    }
    return i == n ? n : -1;
8010138b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138e:	3b 45 10             	cmp    0x10(%ebp),%eax
80101391:	75 05                	jne    80101398 <filewrite+0x123>
80101393:	8b 45 10             	mov    0x10(%ebp),%eax
80101396:	eb 14                	jmp    801013ac <filewrite+0x137>
80101398:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010139d:	eb 0d                	jmp    801013ac <filewrite+0x137>
  }
  panic("filewrite");
8010139f:	83 ec 0c             	sub    $0xc,%esp
801013a2:	68 c4 86 10 80       	push   $0x801086c4
801013a7:	e8 cf f1 ff ff       	call   8010057b <panic>
}
801013ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013af:	c9                   	leave  
801013b0:	c3                   	ret    

801013b1 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013b1:	55                   	push   %ebp
801013b2:	89 e5                	mov    %esp,%ebp
801013b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801013b7:	8b 45 08             	mov    0x8(%ebp),%eax
801013ba:	83 ec 08             	sub    $0x8,%esp
801013bd:	6a 01                	push   $0x1
801013bf:	50                   	push   %eax
801013c0:	e8 f2 ed ff ff       	call   801001b7 <bread>
801013c5:	83 c4 10             	add    $0x10,%esp
801013c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ce:	83 c0 18             	add    $0x18,%eax
801013d1:	83 ec 04             	sub    $0x4,%esp
801013d4:	6a 1c                	push   $0x1c
801013d6:	50                   	push   %eax
801013d7:	ff 75 0c             	pushl  0xc(%ebp)
801013da:	e8 c5 3f 00 00       	call   801053a4 <memmove>
801013df:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013e2:	83 ec 0c             	sub    $0xc,%esp
801013e5:	ff 75 f4             	pushl  -0xc(%ebp)
801013e8:	e8 42 ee ff ff       	call   8010022f <brelse>
801013ed:	83 c4 10             	add    $0x10,%esp
}
801013f0:	90                   	nop
801013f1:	c9                   	leave  
801013f2:	c3                   	ret    

801013f3 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013f3:	55                   	push   %ebp
801013f4:	89 e5                	mov    %esp,%ebp
801013f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013f9:	8b 55 0c             	mov    0xc(%ebp),%edx
801013fc:	8b 45 08             	mov    0x8(%ebp),%eax
801013ff:	83 ec 08             	sub    $0x8,%esp
80101402:	52                   	push   %edx
80101403:	50                   	push   %eax
80101404:	e8 ae ed ff ff       	call   801001b7 <bread>
80101409:	83 c4 10             	add    $0x10,%esp
8010140c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010140f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101412:	83 c0 18             	add    $0x18,%eax
80101415:	83 ec 04             	sub    $0x4,%esp
80101418:	68 00 02 00 00       	push   $0x200
8010141d:	6a 00                	push   $0x0
8010141f:	50                   	push   %eax
80101420:	e8 c0 3e 00 00       	call   801052e5 <memset>
80101425:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101428:	83 ec 0c             	sub    $0xc,%esp
8010142b:	ff 75 f4             	pushl  -0xc(%ebp)
8010142e:	e8 72 23 00 00       	call   801037a5 <log_write>
80101433:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101436:	83 ec 0c             	sub    $0xc,%esp
80101439:	ff 75 f4             	pushl  -0xc(%ebp)
8010143c:	e8 ee ed ff ff       	call   8010022f <brelse>
80101441:	83 c4 10             	add    $0x10,%esp
}
80101444:	90                   	nop
80101445:	c9                   	leave  
80101446:	c3                   	ret    

80101447 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101447:	55                   	push   %ebp
80101448:	89 e5                	mov    %esp,%ebp
8010144a:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010144d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101454:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010145b:	e9 13 01 00 00       	jmp    80101573 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
80101460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101463:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101469:	85 c0                	test   %eax,%eax
8010146b:	0f 48 c2             	cmovs  %edx,%eax
8010146e:	c1 f8 0c             	sar    $0xc,%eax
80101471:	89 c2                	mov    %eax,%edx
80101473:	a1 b8 01 11 80       	mov    0x801101b8,%eax
80101478:	01 d0                	add    %edx,%eax
8010147a:	83 ec 08             	sub    $0x8,%esp
8010147d:	50                   	push   %eax
8010147e:	ff 75 08             	pushl  0x8(%ebp)
80101481:	e8 31 ed ff ff       	call   801001b7 <bread>
80101486:	83 c4 10             	add    $0x10,%esp
80101489:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010148c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101493:	e9 a6 00 00 00       	jmp    8010153e <balloc+0xf7>
      m = 1 << (bi % 8);
80101498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010149b:	99                   	cltd   
8010149c:	c1 ea 1d             	shr    $0x1d,%edx
8010149f:	01 d0                	add    %edx,%eax
801014a1:	83 e0 07             	and    $0x7,%eax
801014a4:	29 d0                	sub    %edx,%eax
801014a6:	ba 01 00 00 00       	mov    $0x1,%edx
801014ab:	89 c1                	mov    %eax,%ecx
801014ad:	d3 e2                	shl    %cl,%edx
801014af:	89 d0                	mov    %edx,%eax
801014b1:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b7:	8d 50 07             	lea    0x7(%eax),%edx
801014ba:	85 c0                	test   %eax,%eax
801014bc:	0f 48 c2             	cmovs  %edx,%eax
801014bf:	c1 f8 03             	sar    $0x3,%eax
801014c2:	89 c2                	mov    %eax,%edx
801014c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014c7:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801014cc:	0f b6 c0             	movzbl %al,%eax
801014cf:	23 45 e8             	and    -0x18(%ebp),%eax
801014d2:	85 c0                	test   %eax,%eax
801014d4:	75 64                	jne    8010153a <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
801014d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d9:	8d 50 07             	lea    0x7(%eax),%edx
801014dc:	85 c0                	test   %eax,%eax
801014de:	0f 48 c2             	cmovs  %edx,%eax
801014e1:	c1 f8 03             	sar    $0x3,%eax
801014e4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014e7:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014ec:	89 d1                	mov    %edx,%ecx
801014ee:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014f1:	09 ca                	or     %ecx,%edx
801014f3:	89 d1                	mov    %edx,%ecx
801014f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014f8:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014fc:	83 ec 0c             	sub    $0xc,%esp
801014ff:	ff 75 ec             	pushl  -0x14(%ebp)
80101502:	e8 9e 22 00 00       	call   801037a5 <log_write>
80101507:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010150a:	83 ec 0c             	sub    $0xc,%esp
8010150d:	ff 75 ec             	pushl  -0x14(%ebp)
80101510:	e8 1a ed ff ff       	call   8010022f <brelse>
80101515:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101518:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010151b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010151e:	01 c2                	add    %eax,%edx
80101520:	8b 45 08             	mov    0x8(%ebp),%eax
80101523:	83 ec 08             	sub    $0x8,%esp
80101526:	52                   	push   %edx
80101527:	50                   	push   %eax
80101528:	e8 c6 fe ff ff       	call   801013f3 <bzero>
8010152d:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101530:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101533:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101536:	01 d0                	add    %edx,%eax
80101538:	eb 57                	jmp    80101591 <balloc+0x14a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010153a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010153e:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101545:	7f 17                	jg     8010155e <balloc+0x117>
80101547:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010154a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154d:	01 d0                	add    %edx,%eax
8010154f:	89 c2                	mov    %eax,%edx
80101551:	a1 a0 01 11 80       	mov    0x801101a0,%eax
80101556:	39 c2                	cmp    %eax,%edx
80101558:	0f 82 3a ff ff ff    	jb     80101498 <balloc+0x51>
      }
    }
    brelse(bp);
8010155e:	83 ec 0c             	sub    $0xc,%esp
80101561:	ff 75 ec             	pushl  -0x14(%ebp)
80101564:	e8 c6 ec ff ff       	call   8010022f <brelse>
80101569:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010156c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101573:	8b 15 a0 01 11 80    	mov    0x801101a0,%edx
80101579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010157c:	39 c2                	cmp    %eax,%edx
8010157e:	0f 87 dc fe ff ff    	ja     80101460 <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101584:	83 ec 0c             	sub    $0xc,%esp
80101587:	68 d0 86 10 80       	push   $0x801086d0
8010158c:	e8 ea ef ff ff       	call   8010057b <panic>
}
80101591:	c9                   	leave  
80101592:	c3                   	ret    

80101593 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101593:	55                   	push   %ebp
80101594:	89 e5                	mov    %esp,%ebp
80101596:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101599:	83 ec 08             	sub    $0x8,%esp
8010159c:	68 a0 01 11 80       	push   $0x801101a0
801015a1:	ff 75 08             	pushl  0x8(%ebp)
801015a4:	e8 08 fe ff ff       	call   801013b1 <readsb>
801015a9:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801015af:	c1 e8 0c             	shr    $0xc,%eax
801015b2:	89 c2                	mov    %eax,%edx
801015b4:	a1 b8 01 11 80       	mov    0x801101b8,%eax
801015b9:	01 c2                	add    %eax,%edx
801015bb:	8b 45 08             	mov    0x8(%ebp),%eax
801015be:	83 ec 08             	sub    $0x8,%esp
801015c1:	52                   	push   %edx
801015c2:	50                   	push   %eax
801015c3:	e8 ef eb ff ff       	call   801001b7 <bread>
801015c8:	83 c4 10             	add    $0x10,%esp
801015cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801015d1:	25 ff 0f 00 00       	and    $0xfff,%eax
801015d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015dc:	99                   	cltd   
801015dd:	c1 ea 1d             	shr    $0x1d,%edx
801015e0:	01 d0                	add    %edx,%eax
801015e2:	83 e0 07             	and    $0x7,%eax
801015e5:	29 d0                	sub    %edx,%eax
801015e7:	ba 01 00 00 00       	mov    $0x1,%edx
801015ec:	89 c1                	mov    %eax,%ecx
801015ee:	d3 e2                	shl    %cl,%edx
801015f0:	89 d0                	mov    %edx,%eax
801015f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f8:	8d 50 07             	lea    0x7(%eax),%edx
801015fb:	85 c0                	test   %eax,%eax
801015fd:	0f 48 c2             	cmovs  %edx,%eax
80101600:	c1 f8 03             	sar    $0x3,%eax
80101603:	89 c2                	mov    %eax,%edx
80101605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101608:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010160d:	0f b6 c0             	movzbl %al,%eax
80101610:	23 45 ec             	and    -0x14(%ebp),%eax
80101613:	85 c0                	test   %eax,%eax
80101615:	75 0d                	jne    80101624 <bfree+0x91>
    panic("freeing free block");
80101617:	83 ec 0c             	sub    $0xc,%esp
8010161a:	68 e6 86 10 80       	push   $0x801086e6
8010161f:	e8 57 ef ff ff       	call   8010057b <panic>
  bp->data[bi/8] &= ~m;
80101624:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101627:	8d 50 07             	lea    0x7(%eax),%edx
8010162a:	85 c0                	test   %eax,%eax
8010162c:	0f 48 c2             	cmovs  %edx,%eax
8010162f:	c1 f8 03             	sar    $0x3,%eax
80101632:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101635:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010163a:	89 d1                	mov    %edx,%ecx
8010163c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010163f:	f7 d2                	not    %edx
80101641:	21 ca                	and    %ecx,%edx
80101643:	89 d1                	mov    %edx,%ecx
80101645:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101648:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010164c:	83 ec 0c             	sub    $0xc,%esp
8010164f:	ff 75 f4             	pushl  -0xc(%ebp)
80101652:	e8 4e 21 00 00       	call   801037a5 <log_write>
80101657:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010165a:	83 ec 0c             	sub    $0xc,%esp
8010165d:	ff 75 f4             	pushl  -0xc(%ebp)
80101660:	e8 ca eb ff ff       	call   8010022f <brelse>
80101665:	83 c4 10             	add    $0x10,%esp
}
80101668:	90                   	nop
80101669:	c9                   	leave  
8010166a:	c3                   	ret    

8010166b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010166b:	55                   	push   %ebp
8010166c:	89 e5                	mov    %esp,%ebp
8010166e:	57                   	push   %edi
8010166f:	56                   	push   %esi
80101670:	53                   	push   %ebx
80101671:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101674:	83 ec 08             	sub    $0x8,%esp
80101677:	68 f9 86 10 80       	push   $0x801086f9
8010167c:	68 c0 01 11 80       	push   $0x801101c0
80101681:	e8 da 39 00 00       	call   80105060 <initlock>
80101686:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80101689:	83 ec 08             	sub    $0x8,%esp
8010168c:	68 a0 01 11 80       	push   $0x801101a0
80101691:	ff 75 08             	pushl  0x8(%ebp)
80101694:	e8 18 fd ff ff       	call   801013b1 <readsb>
80101699:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
8010169c:	a1 b8 01 11 80       	mov    0x801101b8,%eax
801016a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801016a4:	8b 3d b4 01 11 80    	mov    0x801101b4,%edi
801016aa:	8b 35 b0 01 11 80    	mov    0x801101b0,%esi
801016b0:	8b 1d ac 01 11 80    	mov    0x801101ac,%ebx
801016b6:	8b 0d a8 01 11 80    	mov    0x801101a8,%ecx
801016bc:	8b 15 a4 01 11 80    	mov    0x801101a4,%edx
801016c2:	a1 a0 01 11 80       	mov    0x801101a0,%eax
801016c7:	ff 75 e4             	pushl  -0x1c(%ebp)
801016ca:	57                   	push   %edi
801016cb:	56                   	push   %esi
801016cc:	53                   	push   %ebx
801016cd:	51                   	push   %ecx
801016ce:	52                   	push   %edx
801016cf:	50                   	push   %eax
801016d0:	68 00 87 10 80       	push   $0x80108700
801016d5:	e8 ec ec ff ff       	call   801003c6 <cprintf>
801016da:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801016dd:	90                   	nop
801016de:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016e1:	5b                   	pop    %ebx
801016e2:	5e                   	pop    %esi
801016e3:	5f                   	pop    %edi
801016e4:	5d                   	pop    %ebp
801016e5:	c3                   	ret    

801016e6 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016e6:	55                   	push   %ebp
801016e7:	89 e5                	mov    %esp,%ebp
801016e9:	83 ec 28             	sub    $0x28,%esp
801016ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ef:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016f3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016fa:	e9 9e 00 00 00       	jmp    8010179d <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101702:	c1 e8 03             	shr    $0x3,%eax
80101705:	89 c2                	mov    %eax,%edx
80101707:	a1 b4 01 11 80       	mov    0x801101b4,%eax
8010170c:	01 d0                	add    %edx,%eax
8010170e:	83 ec 08             	sub    $0x8,%esp
80101711:	50                   	push   %eax
80101712:	ff 75 08             	pushl  0x8(%ebp)
80101715:	e8 9d ea ff ff       	call   801001b7 <bread>
8010171a:	83 c4 10             	add    $0x10,%esp
8010171d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101720:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101723:	8d 50 18             	lea    0x18(%eax),%edx
80101726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101729:	83 e0 07             	and    $0x7,%eax
8010172c:	c1 e0 06             	shl    $0x6,%eax
8010172f:	01 d0                	add    %edx,%eax
80101731:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101734:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101737:	0f b7 00             	movzwl (%eax),%eax
8010173a:	66 85 c0             	test   %ax,%ax
8010173d:	75 4c                	jne    8010178b <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010173f:	83 ec 04             	sub    $0x4,%esp
80101742:	6a 40                	push   $0x40
80101744:	6a 00                	push   $0x0
80101746:	ff 75 ec             	pushl  -0x14(%ebp)
80101749:	e8 97 3b 00 00       	call   801052e5 <memset>
8010174e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101751:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101754:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101758:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010175b:	83 ec 0c             	sub    $0xc,%esp
8010175e:	ff 75 f0             	pushl  -0x10(%ebp)
80101761:	e8 3f 20 00 00       	call   801037a5 <log_write>
80101766:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101769:	83 ec 0c             	sub    $0xc,%esp
8010176c:	ff 75 f0             	pushl  -0x10(%ebp)
8010176f:	e8 bb ea ff ff       	call   8010022f <brelse>
80101774:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177a:	83 ec 08             	sub    $0x8,%esp
8010177d:	50                   	push   %eax
8010177e:	ff 75 08             	pushl  0x8(%ebp)
80101781:	e8 f8 00 00 00       	call   8010187e <iget>
80101786:	83 c4 10             	add    $0x10,%esp
80101789:	eb 30                	jmp    801017bb <ialloc+0xd5>
    }
    brelse(bp);
8010178b:	83 ec 0c             	sub    $0xc,%esp
8010178e:	ff 75 f0             	pushl  -0x10(%ebp)
80101791:	e8 99 ea ff ff       	call   8010022f <brelse>
80101796:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101799:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010179d:	8b 15 a8 01 11 80    	mov    0x801101a8,%edx
801017a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a6:	39 c2                	cmp    %eax,%edx
801017a8:	0f 87 51 ff ff ff    	ja     801016ff <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017ae:	83 ec 0c             	sub    $0xc,%esp
801017b1:	68 53 87 10 80       	push   $0x80108753
801017b6:	e8 c0 ed ff ff       	call   8010057b <panic>
}
801017bb:	c9                   	leave  
801017bc:	c3                   	ret    

801017bd <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801017bd:	55                   	push   %ebp
801017be:	89 e5                	mov    %esp,%ebp
801017c0:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017c3:	8b 45 08             	mov    0x8(%ebp),%eax
801017c6:	8b 40 04             	mov    0x4(%eax),%eax
801017c9:	c1 e8 03             	shr    $0x3,%eax
801017cc:	89 c2                	mov    %eax,%edx
801017ce:	a1 b4 01 11 80       	mov    0x801101b4,%eax
801017d3:	01 c2                	add    %eax,%edx
801017d5:	8b 45 08             	mov    0x8(%ebp),%eax
801017d8:	8b 00                	mov    (%eax),%eax
801017da:	83 ec 08             	sub    $0x8,%esp
801017dd:	52                   	push   %edx
801017de:	50                   	push   %eax
801017df:	e8 d3 e9 ff ff       	call   801001b7 <bread>
801017e4:	83 c4 10             	add    $0x10,%esp
801017e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ed:	8d 50 18             	lea    0x18(%eax),%edx
801017f0:	8b 45 08             	mov    0x8(%ebp),%eax
801017f3:	8b 40 04             	mov    0x4(%eax),%eax
801017f6:	83 e0 07             	and    $0x7,%eax
801017f9:	c1 e0 06             	shl    $0x6,%eax
801017fc:	01 d0                	add    %edx,%eax
801017fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101801:	8b 45 08             	mov    0x8(%ebp),%eax
80101804:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101808:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010180b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010180e:	8b 45 08             	mov    0x8(%ebp),%eax
80101811:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101815:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101818:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010181c:	8b 45 08             	mov    0x8(%ebp),%eax
8010181f:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101823:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101826:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010182a:	8b 45 08             	mov    0x8(%ebp),%eax
8010182d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101831:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101834:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101838:	8b 45 08             	mov    0x8(%ebp),%eax
8010183b:	8b 50 18             	mov    0x18(%eax),%edx
8010183e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101841:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101844:	8b 45 08             	mov    0x8(%ebp),%eax
80101847:	8d 50 1c             	lea    0x1c(%eax),%edx
8010184a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010184d:	83 c0 0c             	add    $0xc,%eax
80101850:	83 ec 04             	sub    $0x4,%esp
80101853:	6a 34                	push   $0x34
80101855:	52                   	push   %edx
80101856:	50                   	push   %eax
80101857:	e8 48 3b 00 00       	call   801053a4 <memmove>
8010185c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010185f:	83 ec 0c             	sub    $0xc,%esp
80101862:	ff 75 f4             	pushl  -0xc(%ebp)
80101865:	e8 3b 1f 00 00       	call   801037a5 <log_write>
8010186a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010186d:	83 ec 0c             	sub    $0xc,%esp
80101870:	ff 75 f4             	pushl  -0xc(%ebp)
80101873:	e8 b7 e9 ff ff       	call   8010022f <brelse>
80101878:	83 c4 10             	add    $0x10,%esp
}
8010187b:	90                   	nop
8010187c:	c9                   	leave  
8010187d:	c3                   	ret    

8010187e <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010187e:	55                   	push   %ebp
8010187f:	89 e5                	mov    %esp,%ebp
80101881:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101884:	83 ec 0c             	sub    $0xc,%esp
80101887:	68 c0 01 11 80       	push   $0x801101c0
8010188c:	e8 f1 37 00 00       	call   80105082 <acquire>
80101891:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101894:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010189b:	c7 45 f4 f4 01 11 80 	movl   $0x801101f4,-0xc(%ebp)
801018a2:	eb 5d                	jmp    80101901 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a7:	8b 40 08             	mov    0x8(%eax),%eax
801018aa:	85 c0                	test   %eax,%eax
801018ac:	7e 39                	jle    801018e7 <iget+0x69>
801018ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b1:	8b 00                	mov    (%eax),%eax
801018b3:	39 45 08             	cmp    %eax,0x8(%ebp)
801018b6:	75 2f                	jne    801018e7 <iget+0x69>
801018b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018bb:	8b 40 04             	mov    0x4(%eax),%eax
801018be:	39 45 0c             	cmp    %eax,0xc(%ebp)
801018c1:	75 24                	jne    801018e7 <iget+0x69>
      ip->ref++;
801018c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c6:	8b 40 08             	mov    0x8(%eax),%eax
801018c9:	8d 50 01             	lea    0x1(%eax),%edx
801018cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018cf:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018d2:	83 ec 0c             	sub    $0xc,%esp
801018d5:	68 c0 01 11 80       	push   $0x801101c0
801018da:	e8 0a 38 00 00       	call   801050e9 <release>
801018df:	83 c4 10             	add    $0x10,%esp
      return ip;
801018e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e5:	eb 74                	jmp    8010195b <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018eb:	75 10                	jne    801018fd <iget+0x7f>
801018ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f0:	8b 40 08             	mov    0x8(%eax),%eax
801018f3:	85 c0                	test   %eax,%eax
801018f5:	75 06                	jne    801018fd <iget+0x7f>
      empty = ip;
801018f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018fd:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101901:	81 7d f4 94 11 11 80 	cmpl   $0x80111194,-0xc(%ebp)
80101908:	72 9a                	jb     801018a4 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010190a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010190e:	75 0d                	jne    8010191d <iget+0x9f>
    panic("iget: no inodes");
80101910:	83 ec 0c             	sub    $0xc,%esp
80101913:	68 65 87 10 80       	push   $0x80108765
80101918:	e8 5e ec ff ff       	call   8010057b <panic>

  ip = empty;
8010191d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101920:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101926:	8b 55 08             	mov    0x8(%ebp),%edx
80101929:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101931:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101937:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010193e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101941:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101948:	83 ec 0c             	sub    $0xc,%esp
8010194b:	68 c0 01 11 80       	push   $0x801101c0
80101950:	e8 94 37 00 00       	call   801050e9 <release>
80101955:	83 c4 10             	add    $0x10,%esp

  return ip;
80101958:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010195b:	c9                   	leave  
8010195c:	c3                   	ret    

8010195d <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010195d:	55                   	push   %ebp
8010195e:	89 e5                	mov    %esp,%ebp
80101960:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101963:	83 ec 0c             	sub    $0xc,%esp
80101966:	68 c0 01 11 80       	push   $0x801101c0
8010196b:	e8 12 37 00 00       	call   80105082 <acquire>
80101970:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101973:	8b 45 08             	mov    0x8(%ebp),%eax
80101976:	8b 40 08             	mov    0x8(%eax),%eax
80101979:	8d 50 01             	lea    0x1(%eax),%edx
8010197c:	8b 45 08             	mov    0x8(%ebp),%eax
8010197f:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101982:	83 ec 0c             	sub    $0xc,%esp
80101985:	68 c0 01 11 80       	push   $0x801101c0
8010198a:	e8 5a 37 00 00       	call   801050e9 <release>
8010198f:	83 c4 10             	add    $0x10,%esp
  return ip;
80101992:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101995:	c9                   	leave  
80101996:	c3                   	ret    

80101997 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101997:	55                   	push   %ebp
80101998:	89 e5                	mov    %esp,%ebp
8010199a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010199d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019a1:	74 0a                	je     801019ad <ilock+0x16>
801019a3:	8b 45 08             	mov    0x8(%ebp),%eax
801019a6:	8b 40 08             	mov    0x8(%eax),%eax
801019a9:	85 c0                	test   %eax,%eax
801019ab:	7f 0d                	jg     801019ba <ilock+0x23>
    panic("ilock");
801019ad:	83 ec 0c             	sub    $0xc,%esp
801019b0:	68 75 87 10 80       	push   $0x80108775
801019b5:	e8 c1 eb ff ff       	call   8010057b <panic>

  acquire(&icache.lock);
801019ba:	83 ec 0c             	sub    $0xc,%esp
801019bd:	68 c0 01 11 80       	push   $0x801101c0
801019c2:	e8 bb 36 00 00       	call   80105082 <acquire>
801019c7:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019ca:	eb 13                	jmp    801019df <ilock+0x48>
    sleep(ip, &icache.lock);
801019cc:	83 ec 08             	sub    $0x8,%esp
801019cf:	68 c0 01 11 80       	push   $0x801101c0
801019d4:	ff 75 08             	pushl  0x8(%ebp)
801019d7:	e8 ab 33 00 00       	call   80104d87 <sleep>
801019dc:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019df:	8b 45 08             	mov    0x8(%ebp),%eax
801019e2:	8b 40 0c             	mov    0xc(%eax),%eax
801019e5:	83 e0 01             	and    $0x1,%eax
801019e8:	85 c0                	test   %eax,%eax
801019ea:	75 e0                	jne    801019cc <ilock+0x35>
  ip->flags |= I_BUSY;
801019ec:	8b 45 08             	mov    0x8(%ebp),%eax
801019ef:	8b 40 0c             	mov    0xc(%eax),%eax
801019f2:	83 c8 01             	or     $0x1,%eax
801019f5:	89 c2                	mov    %eax,%edx
801019f7:	8b 45 08             	mov    0x8(%ebp),%eax
801019fa:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019fd:	83 ec 0c             	sub    $0xc,%esp
80101a00:	68 c0 01 11 80       	push   $0x801101c0
80101a05:	e8 df 36 00 00       	call   801050e9 <release>
80101a0a:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	8b 40 0c             	mov    0xc(%eax),%eax
80101a13:	83 e0 02             	and    $0x2,%eax
80101a16:	85 c0                	test   %eax,%eax
80101a18:	0f 85 d4 00 00 00    	jne    80101af2 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a21:	8b 40 04             	mov    0x4(%eax),%eax
80101a24:	c1 e8 03             	shr    $0x3,%eax
80101a27:	89 c2                	mov    %eax,%edx
80101a29:	a1 b4 01 11 80       	mov    0x801101b4,%eax
80101a2e:	01 c2                	add    %eax,%edx
80101a30:	8b 45 08             	mov    0x8(%ebp),%eax
80101a33:	8b 00                	mov    (%eax),%eax
80101a35:	83 ec 08             	sub    $0x8,%esp
80101a38:	52                   	push   %edx
80101a39:	50                   	push   %eax
80101a3a:	e8 78 e7 ff ff       	call   801001b7 <bread>
80101a3f:	83 c4 10             	add    $0x10,%esp
80101a42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a48:	8d 50 18             	lea    0x18(%eax),%edx
80101a4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4e:	8b 40 04             	mov    0x4(%eax),%eax
80101a51:	83 e0 07             	and    $0x7,%eax
80101a54:	c1 e0 06             	shl    $0x6,%eax
80101a57:	01 d0                	add    %edx,%eax
80101a59:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5f:	0f b7 10             	movzwl (%eax),%edx
80101a62:	8b 45 08             	mov    0x8(%ebp),%eax
80101a65:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6c:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a70:	8b 45 08             	mov    0x8(%ebp),%eax
80101a73:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a88:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8f:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a96:	8b 50 08             	mov    0x8(%eax),%edx
80101a99:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9c:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa2:	8d 50 0c             	lea    0xc(%eax),%edx
80101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa8:	83 c0 1c             	add    $0x1c,%eax
80101aab:	83 ec 04             	sub    $0x4,%esp
80101aae:	6a 34                	push   $0x34
80101ab0:	52                   	push   %edx
80101ab1:	50                   	push   %eax
80101ab2:	e8 ed 38 00 00       	call   801053a4 <memmove>
80101ab7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101aba:	83 ec 0c             	sub    $0xc,%esp
80101abd:	ff 75 f4             	pushl  -0xc(%ebp)
80101ac0:	e8 6a e7 ff ff       	call   8010022f <brelse>
80101ac5:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101ac8:	8b 45 08             	mov    0x8(%ebp),%eax
80101acb:	8b 40 0c             	mov    0xc(%eax),%eax
80101ace:	83 c8 02             	or     $0x2,%eax
80101ad1:	89 c2                	mov    %eax,%edx
80101ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad6:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101ad9:	8b 45 08             	mov    0x8(%ebp),%eax
80101adc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ae0:	66 85 c0             	test   %ax,%ax
80101ae3:	75 0d                	jne    80101af2 <ilock+0x15b>
      panic("ilock: no type");
80101ae5:	83 ec 0c             	sub    $0xc,%esp
80101ae8:	68 7b 87 10 80       	push   $0x8010877b
80101aed:	e8 89 ea ff ff       	call   8010057b <panic>
  }
}
80101af2:	90                   	nop
80101af3:	c9                   	leave  
80101af4:	c3                   	ret    

80101af5 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101af5:	55                   	push   %ebp
80101af6:	89 e5                	mov    %esp,%ebp
80101af8:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101afb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101aff:	74 17                	je     80101b18 <iunlock+0x23>
80101b01:	8b 45 08             	mov    0x8(%ebp),%eax
80101b04:	8b 40 0c             	mov    0xc(%eax),%eax
80101b07:	83 e0 01             	and    $0x1,%eax
80101b0a:	85 c0                	test   %eax,%eax
80101b0c:	74 0a                	je     80101b18 <iunlock+0x23>
80101b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b11:	8b 40 08             	mov    0x8(%eax),%eax
80101b14:	85 c0                	test   %eax,%eax
80101b16:	7f 0d                	jg     80101b25 <iunlock+0x30>
    panic("iunlock");
80101b18:	83 ec 0c             	sub    $0xc,%esp
80101b1b:	68 8a 87 10 80       	push   $0x8010878a
80101b20:	e8 56 ea ff ff       	call   8010057b <panic>

  acquire(&icache.lock);
80101b25:	83 ec 0c             	sub    $0xc,%esp
80101b28:	68 c0 01 11 80       	push   $0x801101c0
80101b2d:	e8 50 35 00 00       	call   80105082 <acquire>
80101b32:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101b35:	8b 45 08             	mov    0x8(%ebp),%eax
80101b38:	8b 40 0c             	mov    0xc(%eax),%eax
80101b3b:	83 e0 fe             	and    $0xfffffffe,%eax
80101b3e:	89 c2                	mov    %eax,%edx
80101b40:	8b 45 08             	mov    0x8(%ebp),%eax
80101b43:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b46:	83 ec 0c             	sub    $0xc,%esp
80101b49:	ff 75 08             	pushl  0x8(%ebp)
80101b4c:	e8 22 33 00 00       	call   80104e73 <wakeup>
80101b51:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b54:	83 ec 0c             	sub    $0xc,%esp
80101b57:	68 c0 01 11 80       	push   $0x801101c0
80101b5c:	e8 88 35 00 00       	call   801050e9 <release>
80101b61:	83 c4 10             	add    $0x10,%esp
}
80101b64:	90                   	nop
80101b65:	c9                   	leave  
80101b66:	c3                   	ret    

80101b67 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b67:	55                   	push   %ebp
80101b68:	89 e5                	mov    %esp,%ebp
80101b6a:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b6d:	83 ec 0c             	sub    $0xc,%esp
80101b70:	68 c0 01 11 80       	push   $0x801101c0
80101b75:	e8 08 35 00 00       	call   80105082 <acquire>
80101b7a:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b80:	8b 40 08             	mov    0x8(%eax),%eax
80101b83:	83 f8 01             	cmp    $0x1,%eax
80101b86:	0f 85 a9 00 00 00    	jne    80101c35 <iput+0xce>
80101b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8f:	8b 40 0c             	mov    0xc(%eax),%eax
80101b92:	83 e0 02             	and    $0x2,%eax
80101b95:	85 c0                	test   %eax,%eax
80101b97:	0f 84 98 00 00 00    	je     80101c35 <iput+0xce>
80101b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101ba4:	66 85 c0             	test   %ax,%ax
80101ba7:	0f 85 88 00 00 00    	jne    80101c35 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101bad:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb0:	8b 40 0c             	mov    0xc(%eax),%eax
80101bb3:	83 e0 01             	and    $0x1,%eax
80101bb6:	85 c0                	test   %eax,%eax
80101bb8:	74 0d                	je     80101bc7 <iput+0x60>
      panic("iput busy");
80101bba:	83 ec 0c             	sub    $0xc,%esp
80101bbd:	68 92 87 10 80       	push   $0x80108792
80101bc2:	e8 b4 e9 ff ff       	call   8010057b <panic>
    ip->flags |= I_BUSY;
80101bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bca:	8b 40 0c             	mov    0xc(%eax),%eax
80101bcd:	83 c8 01             	or     $0x1,%eax
80101bd0:	89 c2                	mov    %eax,%edx
80101bd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd5:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101bd8:	83 ec 0c             	sub    $0xc,%esp
80101bdb:	68 c0 01 11 80       	push   $0x801101c0
80101be0:	e8 04 35 00 00       	call   801050e9 <release>
80101be5:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101be8:	83 ec 0c             	sub    $0xc,%esp
80101beb:	ff 75 08             	pushl  0x8(%ebp)
80101bee:	e8 a3 01 00 00       	call   80101d96 <itrunc>
80101bf3:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf9:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bff:	83 ec 0c             	sub    $0xc,%esp
80101c02:	ff 75 08             	pushl  0x8(%ebp)
80101c05:	e8 b3 fb ff ff       	call   801017bd <iupdate>
80101c0a:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101c0d:	83 ec 0c             	sub    $0xc,%esp
80101c10:	68 c0 01 11 80       	push   $0x801101c0
80101c15:	e8 68 34 00 00       	call   80105082 <acquire>
80101c1a:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c1d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c20:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c27:	83 ec 0c             	sub    $0xc,%esp
80101c2a:	ff 75 08             	pushl  0x8(%ebp)
80101c2d:	e8 41 32 00 00       	call   80104e73 <wakeup>
80101c32:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101c35:	8b 45 08             	mov    0x8(%ebp),%eax
80101c38:	8b 40 08             	mov    0x8(%eax),%eax
80101c3b:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c41:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c44:	83 ec 0c             	sub    $0xc,%esp
80101c47:	68 c0 01 11 80       	push   $0x801101c0
80101c4c:	e8 98 34 00 00       	call   801050e9 <release>
80101c51:	83 c4 10             	add    $0x10,%esp
}
80101c54:	90                   	nop
80101c55:	c9                   	leave  
80101c56:	c3                   	ret    

80101c57 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c57:	55                   	push   %ebp
80101c58:	89 e5                	mov    %esp,%ebp
80101c5a:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c5d:	83 ec 0c             	sub    $0xc,%esp
80101c60:	ff 75 08             	pushl  0x8(%ebp)
80101c63:	e8 8d fe ff ff       	call   80101af5 <iunlock>
80101c68:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c6b:	83 ec 0c             	sub    $0xc,%esp
80101c6e:	ff 75 08             	pushl  0x8(%ebp)
80101c71:	e8 f1 fe ff ff       	call   80101b67 <iput>
80101c76:	83 c4 10             	add    $0x10,%esp
}
80101c79:	90                   	nop
80101c7a:	c9                   	leave  
80101c7b:	c3                   	ret    

80101c7c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c7c:	55                   	push   %ebp
80101c7d:	89 e5                	mov    %esp,%ebp
80101c7f:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c82:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c86:	77 42                	ja     80101cca <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c88:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c8e:	83 c2 04             	add    $0x4,%edx
80101c91:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c95:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c98:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c9c:	75 24                	jne    80101cc2 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca1:	8b 00                	mov    (%eax),%eax
80101ca3:	83 ec 0c             	sub    $0xc,%esp
80101ca6:	50                   	push   %eax
80101ca7:	e8 9b f7 ff ff       	call   80101447 <balloc>
80101cac:	83 c4 10             	add    $0x10,%esp
80101caf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb5:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cb8:	8d 4a 04             	lea    0x4(%edx),%ecx
80101cbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cbe:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cc5:	e9 ca 00 00 00       	jmp    80101d94 <bmap+0x118>
  }
  bn -= NDIRECT;
80101cca:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101cce:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101cd2:	0f 87 af 00 00 00    	ja     80101d87 <bmap+0x10b>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdb:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cde:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ce1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ce5:	75 1d                	jne    80101d04 <bmap+0x88>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cea:	8b 00                	mov    (%eax),%eax
80101cec:	83 ec 0c             	sub    $0xc,%esp
80101cef:	50                   	push   %eax
80101cf0:	e8 52 f7 ff ff       	call   80101447 <balloc>
80101cf5:	83 c4 10             	add    $0x10,%esp
80101cf8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d01:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101d04:	8b 45 08             	mov    0x8(%ebp),%eax
80101d07:	8b 00                	mov    (%eax),%eax
80101d09:	83 ec 08             	sub    $0x8,%esp
80101d0c:	ff 75 f4             	pushl  -0xc(%ebp)
80101d0f:	50                   	push   %eax
80101d10:	e8 a2 e4 ff ff       	call   801001b7 <bread>
80101d15:	83 c4 10             	add    $0x10,%esp
80101d18:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d1e:	83 c0 18             	add    $0x18,%eax
80101d21:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d31:	01 d0                	add    %edx,%eax
80101d33:	8b 00                	mov    (%eax),%eax
80101d35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d3c:	75 36                	jne    80101d74 <bmap+0xf8>
      a[bn] = addr = balloc(ip->dev);
80101d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d41:	8b 00                	mov    (%eax),%eax
80101d43:	83 ec 0c             	sub    $0xc,%esp
80101d46:	50                   	push   %eax
80101d47:	e8 fb f6 ff ff       	call   80101447 <balloc>
80101d4c:	83 c4 10             	add    $0x10,%esp
80101d4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d52:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d55:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d5f:	01 c2                	add    %eax,%edx
80101d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d64:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d66:	83 ec 0c             	sub    $0xc,%esp
80101d69:	ff 75 f0             	pushl  -0x10(%ebp)
80101d6c:	e8 34 1a 00 00       	call   801037a5 <log_write>
80101d71:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d74:	83 ec 0c             	sub    $0xc,%esp
80101d77:	ff 75 f0             	pushl  -0x10(%ebp)
80101d7a:	e8 b0 e4 ff ff       	call   8010022f <brelse>
80101d7f:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d85:	eb 0d                	jmp    80101d94 <bmap+0x118>
  }

  panic("bmap: out of range");
80101d87:	83 ec 0c             	sub    $0xc,%esp
80101d8a:	68 9c 87 10 80       	push   $0x8010879c
80101d8f:	e8 e7 e7 ff ff       	call   8010057b <panic>
}
80101d94:	c9                   	leave  
80101d95:	c3                   	ret    

80101d96 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d96:	55                   	push   %ebp
80101d97:	89 e5                	mov    %esp,%ebp
80101d99:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101da3:	eb 45                	jmp    80101dea <itrunc+0x54>
    if(ip->addrs[i]){
80101da5:	8b 45 08             	mov    0x8(%ebp),%eax
80101da8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dab:	83 c2 04             	add    $0x4,%edx
80101dae:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101db2:	85 c0                	test   %eax,%eax
80101db4:	74 30                	je     80101de6 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101db6:	8b 45 08             	mov    0x8(%ebp),%eax
80101db9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dbc:	83 c2 04             	add    $0x4,%edx
80101dbf:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dc3:	8b 55 08             	mov    0x8(%ebp),%edx
80101dc6:	8b 12                	mov    (%edx),%edx
80101dc8:	83 ec 08             	sub    $0x8,%esp
80101dcb:	50                   	push   %eax
80101dcc:	52                   	push   %edx
80101dcd:	e8 c1 f7 ff ff       	call   80101593 <bfree>
80101dd2:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ddb:	83 c2 04             	add    $0x4,%edx
80101dde:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101de5:	00 
  for(i = 0; i < NDIRECT; i++){
80101de6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dea:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dee:	7e b5                	jle    80101da5 <itrunc+0xf>
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101df0:	8b 45 08             	mov    0x8(%ebp),%eax
80101df3:	8b 40 4c             	mov    0x4c(%eax),%eax
80101df6:	85 c0                	test   %eax,%eax
80101df8:	0f 84 a1 00 00 00    	je     80101e9f <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101e01:	8b 50 4c             	mov    0x4c(%eax),%edx
80101e04:	8b 45 08             	mov    0x8(%ebp),%eax
80101e07:	8b 00                	mov    (%eax),%eax
80101e09:	83 ec 08             	sub    $0x8,%esp
80101e0c:	52                   	push   %edx
80101e0d:	50                   	push   %eax
80101e0e:	e8 a4 e3 ff ff       	call   801001b7 <bread>
80101e13:	83 c4 10             	add    $0x10,%esp
80101e16:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e1c:	83 c0 18             	add    $0x18,%eax
80101e1f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e22:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e29:	eb 3c                	jmp    80101e67 <itrunc+0xd1>
      if(a[j])
80101e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e2e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e38:	01 d0                	add    %edx,%eax
80101e3a:	8b 00                	mov    (%eax),%eax
80101e3c:	85 c0                	test   %eax,%eax
80101e3e:	74 23                	je     80101e63 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e4d:	01 d0                	add    %edx,%eax
80101e4f:	8b 00                	mov    (%eax),%eax
80101e51:	8b 55 08             	mov    0x8(%ebp),%edx
80101e54:	8b 12                	mov    (%edx),%edx
80101e56:	83 ec 08             	sub    $0x8,%esp
80101e59:	50                   	push   %eax
80101e5a:	52                   	push   %edx
80101e5b:	e8 33 f7 ff ff       	call   80101593 <bfree>
80101e60:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e63:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e6a:	83 f8 7f             	cmp    $0x7f,%eax
80101e6d:	76 bc                	jbe    80101e2b <itrunc+0x95>
    }
    brelse(bp);
80101e6f:	83 ec 0c             	sub    $0xc,%esp
80101e72:	ff 75 ec             	pushl  -0x14(%ebp)
80101e75:	e8 b5 e3 ff ff       	call   8010022f <brelse>
80101e7a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e80:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e83:	8b 55 08             	mov    0x8(%ebp),%edx
80101e86:	8b 12                	mov    (%edx),%edx
80101e88:	83 ec 08             	sub    $0x8,%esp
80101e8b:	50                   	push   %eax
80101e8c:	52                   	push   %edx
80101e8d:	e8 01 f7 ff ff       	call   80101593 <bfree>
80101e92:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e95:	8b 45 08             	mov    0x8(%ebp),%eax
80101e98:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea2:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101ea9:	83 ec 0c             	sub    $0xc,%esp
80101eac:	ff 75 08             	pushl  0x8(%ebp)
80101eaf:	e8 09 f9 ff ff       	call   801017bd <iupdate>
80101eb4:	83 c4 10             	add    $0x10,%esp
}
80101eb7:	90                   	nop
80101eb8:	c9                   	leave  
80101eb9:	c3                   	ret    

80101eba <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101eba:	55                   	push   %ebp
80101ebb:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101ebd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec0:	8b 00                	mov    (%eax),%eax
80101ec2:	89 c2                	mov    %eax,%edx
80101ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec7:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101eca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecd:	8b 50 04             	mov    0x4(%eax),%edx
80101ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed3:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed9:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101edd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ee0:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee6:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101eea:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eed:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	8b 50 18             	mov    0x18(%eax),%edx
80101ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101efa:	89 50 10             	mov    %edx,0x10(%eax)
}
80101efd:	90                   	nop
80101efe:	5d                   	pop    %ebp
80101eff:	c3                   	ret    

80101f00 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f00:	55                   	push   %ebp
80101f01:	89 e5                	mov    %esp,%ebp
80101f03:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f06:	8b 45 08             	mov    0x8(%ebp),%eax
80101f09:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f0d:	66 83 f8 03          	cmp    $0x3,%ax
80101f11:	75 5c                	jne    80101f6f <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f13:	8b 45 08             	mov    0x8(%ebp),%eax
80101f16:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f1a:	66 85 c0             	test   %ax,%ax
80101f1d:	78 20                	js     80101f3f <readi+0x3f>
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f26:	66 83 f8 09          	cmp    $0x9,%ax
80101f2a:	7f 13                	jg     80101f3f <readi+0x3f>
80101f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f33:	98                   	cwtl   
80101f34:	8b 04 c5 a0 f7 10 80 	mov    -0x7fef0860(,%eax,8),%eax
80101f3b:	85 c0                	test   %eax,%eax
80101f3d:	75 0a                	jne    80101f49 <readi+0x49>
      return -1;
80101f3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f44:	e9 0a 01 00 00       	jmp    80102053 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f49:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f50:	98                   	cwtl   
80101f51:	8b 04 c5 a0 f7 10 80 	mov    -0x7fef0860(,%eax,8),%eax
80101f58:	8b 55 14             	mov    0x14(%ebp),%edx
80101f5b:	83 ec 04             	sub    $0x4,%esp
80101f5e:	52                   	push   %edx
80101f5f:	ff 75 0c             	pushl  0xc(%ebp)
80101f62:	ff 75 08             	pushl  0x8(%ebp)
80101f65:	ff d0                	call   *%eax
80101f67:	83 c4 10             	add    $0x10,%esp
80101f6a:	e9 e4 00 00 00       	jmp    80102053 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 40 18             	mov    0x18(%eax),%eax
80101f75:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f78:	77 0d                	ja     80101f87 <readi+0x87>
80101f7a:	8b 55 10             	mov    0x10(%ebp),%edx
80101f7d:	8b 45 14             	mov    0x14(%ebp),%eax
80101f80:	01 d0                	add    %edx,%eax
80101f82:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f85:	76 0a                	jbe    80101f91 <readi+0x91>
    return -1;
80101f87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f8c:	e9 c2 00 00 00       	jmp    80102053 <readi+0x153>
  if(off + n > ip->size)
80101f91:	8b 55 10             	mov    0x10(%ebp),%edx
80101f94:	8b 45 14             	mov    0x14(%ebp),%eax
80101f97:	01 c2                	add    %eax,%edx
80101f99:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9c:	8b 40 18             	mov    0x18(%eax),%eax
80101f9f:	39 c2                	cmp    %eax,%edx
80101fa1:	76 0c                	jbe    80101faf <readi+0xaf>
    n = ip->size - off;
80101fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa6:	8b 40 18             	mov    0x18(%eax),%eax
80101fa9:	2b 45 10             	sub    0x10(%ebp),%eax
80101fac:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101faf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fb6:	e9 89 00 00 00       	jmp    80102044 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fbb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbe:	c1 e8 09             	shr    $0x9,%eax
80101fc1:	83 ec 08             	sub    $0x8,%esp
80101fc4:	50                   	push   %eax
80101fc5:	ff 75 08             	pushl  0x8(%ebp)
80101fc8:	e8 af fc ff ff       	call   80101c7c <bmap>
80101fcd:	83 c4 10             	add    $0x10,%esp
80101fd0:	8b 55 08             	mov    0x8(%ebp),%edx
80101fd3:	8b 12                	mov    (%edx),%edx
80101fd5:	83 ec 08             	sub    $0x8,%esp
80101fd8:	50                   	push   %eax
80101fd9:	52                   	push   %edx
80101fda:	e8 d8 e1 ff ff       	call   801001b7 <bread>
80101fdf:	83 c4 10             	add    $0x10,%esp
80101fe2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fe5:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe8:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fed:	ba 00 02 00 00       	mov    $0x200,%edx
80101ff2:	29 c2                	sub    %eax,%edx
80101ff4:	8b 45 14             	mov    0x14(%ebp),%eax
80101ff7:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101ffa:	39 c2                	cmp    %eax,%edx
80101ffc:	0f 46 c2             	cmovbe %edx,%eax
80101fff:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102002:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102005:	8d 50 18             	lea    0x18(%eax),%edx
80102008:	8b 45 10             	mov    0x10(%ebp),%eax
8010200b:	25 ff 01 00 00       	and    $0x1ff,%eax
80102010:	01 d0                	add    %edx,%eax
80102012:	83 ec 04             	sub    $0x4,%esp
80102015:	ff 75 ec             	pushl  -0x14(%ebp)
80102018:	50                   	push   %eax
80102019:	ff 75 0c             	pushl  0xc(%ebp)
8010201c:	e8 83 33 00 00       	call   801053a4 <memmove>
80102021:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102024:	83 ec 0c             	sub    $0xc,%esp
80102027:	ff 75 f0             	pushl  -0x10(%ebp)
8010202a:	e8 00 e2 ff ff       	call   8010022f <brelse>
8010202f:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102032:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102035:	01 45 f4             	add    %eax,-0xc(%ebp)
80102038:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010203b:	01 45 10             	add    %eax,0x10(%ebp)
8010203e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102041:	01 45 0c             	add    %eax,0xc(%ebp)
80102044:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102047:	3b 45 14             	cmp    0x14(%ebp),%eax
8010204a:	0f 82 6b ff ff ff    	jb     80101fbb <readi+0xbb>
  }
  return n;
80102050:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102053:	c9                   	leave  
80102054:	c3                   	ret    

80102055 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102055:	55                   	push   %ebp
80102056:	89 e5                	mov    %esp,%ebp
80102058:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010205b:	8b 45 08             	mov    0x8(%ebp),%eax
8010205e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102062:	66 83 f8 03          	cmp    $0x3,%ax
80102066:	75 5c                	jne    801020c4 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102068:	8b 45 08             	mov    0x8(%ebp),%eax
8010206b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010206f:	66 85 c0             	test   %ax,%ax
80102072:	78 20                	js     80102094 <writei+0x3f>
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010207b:	66 83 f8 09          	cmp    $0x9,%ax
8010207f:	7f 13                	jg     80102094 <writei+0x3f>
80102081:	8b 45 08             	mov    0x8(%ebp),%eax
80102084:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102088:	98                   	cwtl   
80102089:	8b 04 c5 a4 f7 10 80 	mov    -0x7fef085c(,%eax,8),%eax
80102090:	85 c0                	test   %eax,%eax
80102092:	75 0a                	jne    8010209e <writei+0x49>
      return -1;
80102094:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102099:	e9 3b 01 00 00       	jmp    801021d9 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010209e:	8b 45 08             	mov    0x8(%ebp),%eax
801020a1:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020a5:	98                   	cwtl   
801020a6:	8b 04 c5 a4 f7 10 80 	mov    -0x7fef085c(,%eax,8),%eax
801020ad:	8b 55 14             	mov    0x14(%ebp),%edx
801020b0:	83 ec 04             	sub    $0x4,%esp
801020b3:	52                   	push   %edx
801020b4:	ff 75 0c             	pushl  0xc(%ebp)
801020b7:	ff 75 08             	pushl  0x8(%ebp)
801020ba:	ff d0                	call   *%eax
801020bc:	83 c4 10             	add    $0x10,%esp
801020bf:	e9 15 01 00 00       	jmp    801021d9 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020c4:	8b 45 08             	mov    0x8(%ebp),%eax
801020c7:	8b 40 18             	mov    0x18(%eax),%eax
801020ca:	39 45 10             	cmp    %eax,0x10(%ebp)
801020cd:	77 0d                	ja     801020dc <writei+0x87>
801020cf:	8b 55 10             	mov    0x10(%ebp),%edx
801020d2:	8b 45 14             	mov    0x14(%ebp),%eax
801020d5:	01 d0                	add    %edx,%eax
801020d7:	39 45 10             	cmp    %eax,0x10(%ebp)
801020da:	76 0a                	jbe    801020e6 <writei+0x91>
    return -1;
801020dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020e1:	e9 f3 00 00 00       	jmp    801021d9 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020e6:	8b 55 10             	mov    0x10(%ebp),%edx
801020e9:	8b 45 14             	mov    0x14(%ebp),%eax
801020ec:	01 d0                	add    %edx,%eax
801020ee:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020f3:	76 0a                	jbe    801020ff <writei+0xaa>
    return -1;
801020f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020fa:	e9 da 00 00 00       	jmp    801021d9 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102106:	e9 97 00 00 00       	jmp    801021a2 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010210b:	8b 45 10             	mov    0x10(%ebp),%eax
8010210e:	c1 e8 09             	shr    $0x9,%eax
80102111:	83 ec 08             	sub    $0x8,%esp
80102114:	50                   	push   %eax
80102115:	ff 75 08             	pushl  0x8(%ebp)
80102118:	e8 5f fb ff ff       	call   80101c7c <bmap>
8010211d:	83 c4 10             	add    $0x10,%esp
80102120:	8b 55 08             	mov    0x8(%ebp),%edx
80102123:	8b 12                	mov    (%edx),%edx
80102125:	83 ec 08             	sub    $0x8,%esp
80102128:	50                   	push   %eax
80102129:	52                   	push   %edx
8010212a:	e8 88 e0 ff ff       	call   801001b7 <bread>
8010212f:	83 c4 10             	add    $0x10,%esp
80102132:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102135:	8b 45 10             	mov    0x10(%ebp),%eax
80102138:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213d:	ba 00 02 00 00       	mov    $0x200,%edx
80102142:	29 c2                	sub    %eax,%edx
80102144:	8b 45 14             	mov    0x14(%ebp),%eax
80102147:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010214a:	39 c2                	cmp    %eax,%edx
8010214c:	0f 46 c2             	cmovbe %edx,%eax
8010214f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102155:	8d 50 18             	lea    0x18(%eax),%edx
80102158:	8b 45 10             	mov    0x10(%ebp),%eax
8010215b:	25 ff 01 00 00       	and    $0x1ff,%eax
80102160:	01 d0                	add    %edx,%eax
80102162:	83 ec 04             	sub    $0x4,%esp
80102165:	ff 75 ec             	pushl  -0x14(%ebp)
80102168:	ff 75 0c             	pushl  0xc(%ebp)
8010216b:	50                   	push   %eax
8010216c:	e8 33 32 00 00       	call   801053a4 <memmove>
80102171:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102174:	83 ec 0c             	sub    $0xc,%esp
80102177:	ff 75 f0             	pushl  -0x10(%ebp)
8010217a:	e8 26 16 00 00       	call   801037a5 <log_write>
8010217f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102182:	83 ec 0c             	sub    $0xc,%esp
80102185:	ff 75 f0             	pushl  -0x10(%ebp)
80102188:	e8 a2 e0 ff ff       	call   8010022f <brelse>
8010218d:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102190:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102193:	01 45 f4             	add    %eax,-0xc(%ebp)
80102196:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102199:	01 45 10             	add    %eax,0x10(%ebp)
8010219c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010219f:	01 45 0c             	add    %eax,0xc(%ebp)
801021a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021a5:	3b 45 14             	cmp    0x14(%ebp),%eax
801021a8:	0f 82 5d ff ff ff    	jb     8010210b <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
801021ae:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801021b2:	74 22                	je     801021d6 <writei+0x181>
801021b4:	8b 45 08             	mov    0x8(%ebp),%eax
801021b7:	8b 40 18             	mov    0x18(%eax),%eax
801021ba:	39 45 10             	cmp    %eax,0x10(%ebp)
801021bd:	76 17                	jbe    801021d6 <writei+0x181>
    ip->size = off;
801021bf:	8b 45 08             	mov    0x8(%ebp),%eax
801021c2:	8b 55 10             	mov    0x10(%ebp),%edx
801021c5:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801021c8:	83 ec 0c             	sub    $0xc,%esp
801021cb:	ff 75 08             	pushl  0x8(%ebp)
801021ce:	e8 ea f5 ff ff       	call   801017bd <iupdate>
801021d3:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021d6:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021d9:	c9                   	leave  
801021da:	c3                   	ret    

801021db <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021db:	55                   	push   %ebp
801021dc:	89 e5                	mov    %esp,%ebp
801021de:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021e1:	83 ec 04             	sub    $0x4,%esp
801021e4:	6a 0e                	push   $0xe
801021e6:	ff 75 0c             	pushl  0xc(%ebp)
801021e9:	ff 75 08             	pushl  0x8(%ebp)
801021ec:	e8 49 32 00 00       	call   8010543a <strncmp>
801021f1:	83 c4 10             	add    $0x10,%esp
}
801021f4:	c9                   	leave  
801021f5:	c3                   	ret    

801021f6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021f6:	55                   	push   %ebp
801021f7:	89 e5                	mov    %esp,%ebp
801021f9:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021fc:	8b 45 08             	mov    0x8(%ebp),%eax
801021ff:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102203:	66 83 f8 01          	cmp    $0x1,%ax
80102207:	74 0d                	je     80102216 <dirlookup+0x20>
    panic("dirlookup not DIR");
80102209:	83 ec 0c             	sub    $0xc,%esp
8010220c:	68 af 87 10 80       	push   $0x801087af
80102211:	e8 65 e3 ff ff       	call   8010057b <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102216:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010221d:	eb 7b                	jmp    8010229a <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010221f:	6a 10                	push   $0x10
80102221:	ff 75 f4             	pushl  -0xc(%ebp)
80102224:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102227:	50                   	push   %eax
80102228:	ff 75 08             	pushl  0x8(%ebp)
8010222b:	e8 d0 fc ff ff       	call   80101f00 <readi>
80102230:	83 c4 10             	add    $0x10,%esp
80102233:	83 f8 10             	cmp    $0x10,%eax
80102236:	74 0d                	je     80102245 <dirlookup+0x4f>
      panic("dirlink read");
80102238:	83 ec 0c             	sub    $0xc,%esp
8010223b:	68 c1 87 10 80       	push   $0x801087c1
80102240:	e8 36 e3 ff ff       	call   8010057b <panic>
    if(de.inum == 0)
80102245:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102249:	66 85 c0             	test   %ax,%ax
8010224c:	74 47                	je     80102295 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010224e:	83 ec 08             	sub    $0x8,%esp
80102251:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102254:	83 c0 02             	add    $0x2,%eax
80102257:	50                   	push   %eax
80102258:	ff 75 0c             	pushl  0xc(%ebp)
8010225b:	e8 7b ff ff ff       	call   801021db <namecmp>
80102260:	83 c4 10             	add    $0x10,%esp
80102263:	85 c0                	test   %eax,%eax
80102265:	75 2f                	jne    80102296 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102267:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010226b:	74 08                	je     80102275 <dirlookup+0x7f>
        *poff = off;
8010226d:	8b 45 10             	mov    0x10(%ebp),%eax
80102270:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102273:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102275:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102279:	0f b7 c0             	movzwl %ax,%eax
8010227c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010227f:	8b 45 08             	mov    0x8(%ebp),%eax
80102282:	8b 00                	mov    (%eax),%eax
80102284:	83 ec 08             	sub    $0x8,%esp
80102287:	ff 75 f0             	pushl  -0x10(%ebp)
8010228a:	50                   	push   %eax
8010228b:	e8 ee f5 ff ff       	call   8010187e <iget>
80102290:	83 c4 10             	add    $0x10,%esp
80102293:	eb 19                	jmp    801022ae <dirlookup+0xb8>
      continue;
80102295:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102296:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010229a:	8b 45 08             	mov    0x8(%ebp),%eax
8010229d:	8b 40 18             	mov    0x18(%eax),%eax
801022a0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801022a3:	0f 82 76 ff ff ff    	jb     8010221f <dirlookup+0x29>
    }
  }

  return 0;
801022a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022ae:	c9                   	leave  
801022af:	c3                   	ret    

801022b0 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022b0:	55                   	push   %ebp
801022b1:	89 e5                	mov    %esp,%ebp
801022b3:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022b6:	83 ec 04             	sub    $0x4,%esp
801022b9:	6a 00                	push   $0x0
801022bb:	ff 75 0c             	pushl  0xc(%ebp)
801022be:	ff 75 08             	pushl  0x8(%ebp)
801022c1:	e8 30 ff ff ff       	call   801021f6 <dirlookup>
801022c6:	83 c4 10             	add    $0x10,%esp
801022c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022d0:	74 18                	je     801022ea <dirlink+0x3a>
    iput(ip);
801022d2:	83 ec 0c             	sub    $0xc,%esp
801022d5:	ff 75 f0             	pushl  -0x10(%ebp)
801022d8:	e8 8a f8 ff ff       	call   80101b67 <iput>
801022dd:	83 c4 10             	add    $0x10,%esp
    return -1;
801022e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022e5:	e9 9c 00 00 00       	jmp    80102386 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022f1:	eb 39                	jmp    8010232c <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f6:	6a 10                	push   $0x10
801022f8:	50                   	push   %eax
801022f9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022fc:	50                   	push   %eax
801022fd:	ff 75 08             	pushl  0x8(%ebp)
80102300:	e8 fb fb ff ff       	call   80101f00 <readi>
80102305:	83 c4 10             	add    $0x10,%esp
80102308:	83 f8 10             	cmp    $0x10,%eax
8010230b:	74 0d                	je     8010231a <dirlink+0x6a>
      panic("dirlink read");
8010230d:	83 ec 0c             	sub    $0xc,%esp
80102310:	68 c1 87 10 80       	push   $0x801087c1
80102315:	e8 61 e2 ff ff       	call   8010057b <panic>
    if(de.inum == 0)
8010231a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010231e:	66 85 c0             	test   %ax,%ax
80102321:	74 18                	je     8010233b <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102323:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102326:	83 c0 10             	add    $0x10,%eax
80102329:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010232c:	8b 45 08             	mov    0x8(%ebp),%eax
8010232f:	8b 50 18             	mov    0x18(%eax),%edx
80102332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102335:	39 c2                	cmp    %eax,%edx
80102337:	77 ba                	ja     801022f3 <dirlink+0x43>
80102339:	eb 01                	jmp    8010233c <dirlink+0x8c>
      break;
8010233b:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010233c:	83 ec 04             	sub    $0x4,%esp
8010233f:	6a 0e                	push   $0xe
80102341:	ff 75 0c             	pushl  0xc(%ebp)
80102344:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102347:	83 c0 02             	add    $0x2,%eax
8010234a:	50                   	push   %eax
8010234b:	e8 40 31 00 00       	call   80105490 <strncpy>
80102350:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102353:	8b 45 10             	mov    0x10(%ebp),%eax
80102356:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010235a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010235d:	6a 10                	push   $0x10
8010235f:	50                   	push   %eax
80102360:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102363:	50                   	push   %eax
80102364:	ff 75 08             	pushl  0x8(%ebp)
80102367:	e8 e9 fc ff ff       	call   80102055 <writei>
8010236c:	83 c4 10             	add    $0x10,%esp
8010236f:	83 f8 10             	cmp    $0x10,%eax
80102372:	74 0d                	je     80102381 <dirlink+0xd1>
    panic("dirlink");
80102374:	83 ec 0c             	sub    $0xc,%esp
80102377:	68 ce 87 10 80       	push   $0x801087ce
8010237c:	e8 fa e1 ff ff       	call   8010057b <panic>
  
  return 0;
80102381:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102386:	c9                   	leave  
80102387:	c3                   	ret    

80102388 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102388:	55                   	push   %ebp
80102389:	89 e5                	mov    %esp,%ebp
8010238b:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010238e:	eb 04                	jmp    80102394 <skipelem+0xc>
    path++;
80102390:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102394:	8b 45 08             	mov    0x8(%ebp),%eax
80102397:	0f b6 00             	movzbl (%eax),%eax
8010239a:	3c 2f                	cmp    $0x2f,%al
8010239c:	74 f2                	je     80102390 <skipelem+0x8>
  if(*path == 0)
8010239e:	8b 45 08             	mov    0x8(%ebp),%eax
801023a1:	0f b6 00             	movzbl (%eax),%eax
801023a4:	84 c0                	test   %al,%al
801023a6:	75 07                	jne    801023af <skipelem+0x27>
    return 0;
801023a8:	b8 00 00 00 00       	mov    $0x0,%eax
801023ad:	eb 77                	jmp    80102426 <skipelem+0x9e>
  s = path;
801023af:	8b 45 08             	mov    0x8(%ebp),%eax
801023b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023b5:	eb 04                	jmp    801023bb <skipelem+0x33>
    path++;
801023b7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801023bb:	8b 45 08             	mov    0x8(%ebp),%eax
801023be:	0f b6 00             	movzbl (%eax),%eax
801023c1:	3c 2f                	cmp    $0x2f,%al
801023c3:	74 0a                	je     801023cf <skipelem+0x47>
801023c5:	8b 45 08             	mov    0x8(%ebp),%eax
801023c8:	0f b6 00             	movzbl (%eax),%eax
801023cb:	84 c0                	test   %al,%al
801023cd:	75 e8                	jne    801023b7 <skipelem+0x2f>
  len = path - s;
801023cf:	8b 45 08             	mov    0x8(%ebp),%eax
801023d2:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023d8:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023dc:	7e 15                	jle    801023f3 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023de:	83 ec 04             	sub    $0x4,%esp
801023e1:	6a 0e                	push   $0xe
801023e3:	ff 75 f4             	pushl  -0xc(%ebp)
801023e6:	ff 75 0c             	pushl  0xc(%ebp)
801023e9:	e8 b6 2f 00 00       	call   801053a4 <memmove>
801023ee:	83 c4 10             	add    $0x10,%esp
801023f1:	eb 26                	jmp    80102419 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023f6:	83 ec 04             	sub    $0x4,%esp
801023f9:	50                   	push   %eax
801023fa:	ff 75 f4             	pushl  -0xc(%ebp)
801023fd:	ff 75 0c             	pushl  0xc(%ebp)
80102400:	e8 9f 2f 00 00       	call   801053a4 <memmove>
80102405:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102408:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010240b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010240e:	01 d0                	add    %edx,%eax
80102410:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102413:	eb 04                	jmp    80102419 <skipelem+0x91>
    path++;
80102415:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102419:	8b 45 08             	mov    0x8(%ebp),%eax
8010241c:	0f b6 00             	movzbl (%eax),%eax
8010241f:	3c 2f                	cmp    $0x2f,%al
80102421:	74 f2                	je     80102415 <skipelem+0x8d>
  return path;
80102423:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102426:	c9                   	leave  
80102427:	c3                   	ret    

80102428 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102428:	55                   	push   %ebp
80102429:	89 e5                	mov    %esp,%ebp
8010242b:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010242e:	8b 45 08             	mov    0x8(%ebp),%eax
80102431:	0f b6 00             	movzbl (%eax),%eax
80102434:	3c 2f                	cmp    $0x2f,%al
80102436:	75 17                	jne    8010244f <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102438:	83 ec 08             	sub    $0x8,%esp
8010243b:	6a 01                	push   $0x1
8010243d:	6a 01                	push   $0x1
8010243f:	e8 3a f4 ff ff       	call   8010187e <iget>
80102444:	83 c4 10             	add    $0x10,%esp
80102447:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010244a:	e9 bb 00 00 00       	jmp    8010250a <namex+0xe2>
  else
    ip = idup(proc->cwd);
8010244f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102455:	8b 40 68             	mov    0x68(%eax),%eax
80102458:	83 ec 0c             	sub    $0xc,%esp
8010245b:	50                   	push   %eax
8010245c:	e8 fc f4 ff ff       	call   8010195d <idup>
80102461:	83 c4 10             	add    $0x10,%esp
80102464:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102467:	e9 9e 00 00 00       	jmp    8010250a <namex+0xe2>
    ilock(ip);
8010246c:	83 ec 0c             	sub    $0xc,%esp
8010246f:	ff 75 f4             	pushl  -0xc(%ebp)
80102472:	e8 20 f5 ff ff       	call   80101997 <ilock>
80102477:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010247a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010247d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102481:	66 83 f8 01          	cmp    $0x1,%ax
80102485:	74 18                	je     8010249f <namex+0x77>
      iunlockput(ip);
80102487:	83 ec 0c             	sub    $0xc,%esp
8010248a:	ff 75 f4             	pushl  -0xc(%ebp)
8010248d:	e8 c5 f7 ff ff       	call   80101c57 <iunlockput>
80102492:	83 c4 10             	add    $0x10,%esp
      return 0;
80102495:	b8 00 00 00 00       	mov    $0x0,%eax
8010249a:	e9 a7 00 00 00       	jmp    80102546 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
8010249f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024a3:	74 20                	je     801024c5 <namex+0x9d>
801024a5:	8b 45 08             	mov    0x8(%ebp),%eax
801024a8:	0f b6 00             	movzbl (%eax),%eax
801024ab:	84 c0                	test   %al,%al
801024ad:	75 16                	jne    801024c5 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
801024af:	83 ec 0c             	sub    $0xc,%esp
801024b2:	ff 75 f4             	pushl  -0xc(%ebp)
801024b5:	e8 3b f6 ff ff       	call   80101af5 <iunlock>
801024ba:	83 c4 10             	add    $0x10,%esp
      return ip;
801024bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c0:	e9 81 00 00 00       	jmp    80102546 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024c5:	83 ec 04             	sub    $0x4,%esp
801024c8:	6a 00                	push   $0x0
801024ca:	ff 75 10             	pushl  0x10(%ebp)
801024cd:	ff 75 f4             	pushl  -0xc(%ebp)
801024d0:	e8 21 fd ff ff       	call   801021f6 <dirlookup>
801024d5:	83 c4 10             	add    $0x10,%esp
801024d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024df:	75 15                	jne    801024f6 <namex+0xce>
      iunlockput(ip);
801024e1:	83 ec 0c             	sub    $0xc,%esp
801024e4:	ff 75 f4             	pushl  -0xc(%ebp)
801024e7:	e8 6b f7 ff ff       	call   80101c57 <iunlockput>
801024ec:	83 c4 10             	add    $0x10,%esp
      return 0;
801024ef:	b8 00 00 00 00       	mov    $0x0,%eax
801024f4:	eb 50                	jmp    80102546 <namex+0x11e>
    }
    iunlockput(ip);
801024f6:	83 ec 0c             	sub    $0xc,%esp
801024f9:	ff 75 f4             	pushl  -0xc(%ebp)
801024fc:	e8 56 f7 ff ff       	call   80101c57 <iunlockput>
80102501:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102504:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102507:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
8010250a:	83 ec 08             	sub    $0x8,%esp
8010250d:	ff 75 10             	pushl  0x10(%ebp)
80102510:	ff 75 08             	pushl  0x8(%ebp)
80102513:	e8 70 fe ff ff       	call   80102388 <skipelem>
80102518:	83 c4 10             	add    $0x10,%esp
8010251b:	89 45 08             	mov    %eax,0x8(%ebp)
8010251e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102522:	0f 85 44 ff ff ff    	jne    8010246c <namex+0x44>
  }
  if(nameiparent){
80102528:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010252c:	74 15                	je     80102543 <namex+0x11b>
    iput(ip);
8010252e:	83 ec 0c             	sub    $0xc,%esp
80102531:	ff 75 f4             	pushl  -0xc(%ebp)
80102534:	e8 2e f6 ff ff       	call   80101b67 <iput>
80102539:	83 c4 10             	add    $0x10,%esp
    return 0;
8010253c:	b8 00 00 00 00       	mov    $0x0,%eax
80102541:	eb 03                	jmp    80102546 <namex+0x11e>
  }
  return ip;
80102543:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102546:	c9                   	leave  
80102547:	c3                   	ret    

80102548 <namei>:

struct inode*
namei(char *path)
{
80102548:	55                   	push   %ebp
80102549:	89 e5                	mov    %esp,%ebp
8010254b:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010254e:	83 ec 04             	sub    $0x4,%esp
80102551:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102554:	50                   	push   %eax
80102555:	6a 00                	push   $0x0
80102557:	ff 75 08             	pushl  0x8(%ebp)
8010255a:	e8 c9 fe ff ff       	call   80102428 <namex>
8010255f:	83 c4 10             	add    $0x10,%esp
}
80102562:	c9                   	leave  
80102563:	c3                   	ret    

80102564 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102564:	55                   	push   %ebp
80102565:	89 e5                	mov    %esp,%ebp
80102567:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010256a:	83 ec 04             	sub    $0x4,%esp
8010256d:	ff 75 0c             	pushl  0xc(%ebp)
80102570:	6a 01                	push   $0x1
80102572:	ff 75 08             	pushl  0x8(%ebp)
80102575:	e8 ae fe ff ff       	call   80102428 <namex>
8010257a:	83 c4 10             	add    $0x10,%esp
}
8010257d:	c9                   	leave  
8010257e:	c3                   	ret    

8010257f <inb>:
{
8010257f:	55                   	push   %ebp
80102580:	89 e5                	mov    %esp,%ebp
80102582:	83 ec 14             	sub    $0x14,%esp
80102585:	8b 45 08             	mov    0x8(%ebp),%eax
80102588:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010258c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102590:	89 c2                	mov    %eax,%edx
80102592:	ec                   	in     (%dx),%al
80102593:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102596:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010259a:	c9                   	leave  
8010259b:	c3                   	ret    

8010259c <insl>:
{
8010259c:	55                   	push   %ebp
8010259d:	89 e5                	mov    %esp,%ebp
8010259f:	57                   	push   %edi
801025a0:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801025a1:	8b 55 08             	mov    0x8(%ebp),%edx
801025a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025a7:	8b 45 10             	mov    0x10(%ebp),%eax
801025aa:	89 cb                	mov    %ecx,%ebx
801025ac:	89 df                	mov    %ebx,%edi
801025ae:	89 c1                	mov    %eax,%ecx
801025b0:	fc                   	cld    
801025b1:	f3 6d                	rep insl (%dx),%es:(%edi)
801025b3:	89 c8                	mov    %ecx,%eax
801025b5:	89 fb                	mov    %edi,%ebx
801025b7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025ba:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025bd:	90                   	nop
801025be:	5b                   	pop    %ebx
801025bf:	5f                   	pop    %edi
801025c0:	5d                   	pop    %ebp
801025c1:	c3                   	ret    

801025c2 <outb>:
{
801025c2:	55                   	push   %ebp
801025c3:	89 e5                	mov    %esp,%ebp
801025c5:	83 ec 08             	sub    $0x8,%esp
801025c8:	8b 45 08             	mov    0x8(%ebp),%eax
801025cb:	8b 55 0c             	mov    0xc(%ebp),%edx
801025ce:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801025d2:	89 d0                	mov    %edx,%eax
801025d4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025d7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025db:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025df:	ee                   	out    %al,(%dx)
}
801025e0:	90                   	nop
801025e1:	c9                   	leave  
801025e2:	c3                   	ret    

801025e3 <outsl>:
{
801025e3:	55                   	push   %ebp
801025e4:	89 e5                	mov    %esp,%ebp
801025e6:	56                   	push   %esi
801025e7:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025e8:	8b 55 08             	mov    0x8(%ebp),%edx
801025eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025ee:	8b 45 10             	mov    0x10(%ebp),%eax
801025f1:	89 cb                	mov    %ecx,%ebx
801025f3:	89 de                	mov    %ebx,%esi
801025f5:	89 c1                	mov    %eax,%ecx
801025f7:	fc                   	cld    
801025f8:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025fa:	89 c8                	mov    %ecx,%eax
801025fc:	89 f3                	mov    %esi,%ebx
801025fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102601:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102604:	90                   	nop
80102605:	5b                   	pop    %ebx
80102606:	5e                   	pop    %esi
80102607:	5d                   	pop    %ebp
80102608:	c3                   	ret    

80102609 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102609:	55                   	push   %ebp
8010260a:	89 e5                	mov    %esp,%ebp
8010260c:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
8010260f:	90                   	nop
80102610:	68 f7 01 00 00       	push   $0x1f7
80102615:	e8 65 ff ff ff       	call   8010257f <inb>
8010261a:	83 c4 04             	add    $0x4,%esp
8010261d:	0f b6 c0             	movzbl %al,%eax
80102620:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102623:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102626:	25 c0 00 00 00       	and    $0xc0,%eax
8010262b:	83 f8 40             	cmp    $0x40,%eax
8010262e:	75 e0                	jne    80102610 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102630:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102634:	74 11                	je     80102647 <idewait+0x3e>
80102636:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102639:	83 e0 21             	and    $0x21,%eax
8010263c:	85 c0                	test   %eax,%eax
8010263e:	74 07                	je     80102647 <idewait+0x3e>
    return -1;
80102640:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102645:	eb 05                	jmp    8010264c <idewait+0x43>
  return 0;
80102647:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010264c:	c9                   	leave  
8010264d:	c3                   	ret    

8010264e <ideinit>:

void
ideinit(void)
{
8010264e:	55                   	push   %ebp
8010264f:	89 e5                	mov    %esp,%ebp
80102651:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102654:	83 ec 08             	sub    $0x8,%esp
80102657:	68 d6 87 10 80       	push   $0x801087d6
8010265c:	68 a0 11 11 80       	push   $0x801111a0
80102661:	e8 fa 29 00 00       	call   80105060 <initlock>
80102666:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102669:	83 ec 0c             	sub    $0xc,%esp
8010266c:	6a 0e                	push   $0xe
8010266e:	e8 f5 18 00 00       	call   80103f68 <picenable>
80102673:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102676:	a1 04 19 11 80       	mov    0x80111904,%eax
8010267b:	83 e8 01             	sub    $0x1,%eax
8010267e:	83 ec 08             	sub    $0x8,%esp
80102681:	50                   	push   %eax
80102682:	6a 0e                	push   $0xe
80102684:	e8 73 04 00 00       	call   80102afc <ioapicenable>
80102689:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010268c:	83 ec 0c             	sub    $0xc,%esp
8010268f:	6a 00                	push   $0x0
80102691:	e8 73 ff ff ff       	call   80102609 <idewait>
80102696:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102699:	83 ec 08             	sub    $0x8,%esp
8010269c:	68 f0 00 00 00       	push   $0xf0
801026a1:	68 f6 01 00 00       	push   $0x1f6
801026a6:	e8 17 ff ff ff       	call   801025c2 <outb>
801026ab:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
801026ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026b5:	eb 24                	jmp    801026db <ideinit+0x8d>
    if(inb(0x1f7) != 0){
801026b7:	83 ec 0c             	sub    $0xc,%esp
801026ba:	68 f7 01 00 00       	push   $0x1f7
801026bf:	e8 bb fe ff ff       	call   8010257f <inb>
801026c4:	83 c4 10             	add    $0x10,%esp
801026c7:	84 c0                	test   %al,%al
801026c9:	74 0c                	je     801026d7 <ideinit+0x89>
      havedisk1 = 1;
801026cb:	c7 05 d8 11 11 80 01 	movl   $0x1,0x801111d8
801026d2:	00 00 00 
      break;
801026d5:	eb 0d                	jmp    801026e4 <ideinit+0x96>
  for(i=0; i<1000; i++){
801026d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026db:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026e2:	7e d3                	jle    801026b7 <ideinit+0x69>
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026e4:	83 ec 08             	sub    $0x8,%esp
801026e7:	68 e0 00 00 00       	push   $0xe0
801026ec:	68 f6 01 00 00       	push   $0x1f6
801026f1:	e8 cc fe ff ff       	call   801025c2 <outb>
801026f6:	83 c4 10             	add    $0x10,%esp
}
801026f9:	90                   	nop
801026fa:	c9                   	leave  
801026fb:	c3                   	ret    

801026fc <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026fc:	55                   	push   %ebp
801026fd:	89 e5                	mov    %esp,%ebp
801026ff:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102702:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102706:	75 0d                	jne    80102715 <idestart+0x19>
    panic("idestart");
80102708:	83 ec 0c             	sub    $0xc,%esp
8010270b:	68 da 87 10 80       	push   $0x801087da
80102710:	e8 66 de ff ff       	call   8010057b <panic>
  if(b->blockno >= FSSIZE)
80102715:	8b 45 08             	mov    0x8(%ebp),%eax
80102718:	8b 40 08             	mov    0x8(%eax),%eax
8010271b:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102720:	76 0d                	jbe    8010272f <idestart+0x33>
    panic("incorrect blockno");
80102722:	83 ec 0c             	sub    $0xc,%esp
80102725:	68 e3 87 10 80       	push   $0x801087e3
8010272a:	e8 4c de ff ff       	call   8010057b <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010272f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102736:	8b 45 08             	mov    0x8(%ebp),%eax
80102739:	8b 50 08             	mov    0x8(%eax),%edx
8010273c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010273f:	0f af c2             	imul   %edx,%eax
80102742:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102745:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102749:	7e 0d                	jle    80102758 <idestart+0x5c>
8010274b:	83 ec 0c             	sub    $0xc,%esp
8010274e:	68 da 87 10 80       	push   $0x801087da
80102753:	e8 23 de ff ff       	call   8010057b <panic>
  
  idewait(0);
80102758:	83 ec 0c             	sub    $0xc,%esp
8010275b:	6a 00                	push   $0x0
8010275d:	e8 a7 fe ff ff       	call   80102609 <idewait>
80102762:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102765:	83 ec 08             	sub    $0x8,%esp
80102768:	6a 00                	push   $0x0
8010276a:	68 f6 03 00 00       	push   $0x3f6
8010276f:	e8 4e fe ff ff       	call   801025c2 <outb>
80102774:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277a:	0f b6 c0             	movzbl %al,%eax
8010277d:	83 ec 08             	sub    $0x8,%esp
80102780:	50                   	push   %eax
80102781:	68 f2 01 00 00       	push   $0x1f2
80102786:	e8 37 fe ff ff       	call   801025c2 <outb>
8010278b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010278e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102791:	0f b6 c0             	movzbl %al,%eax
80102794:	83 ec 08             	sub    $0x8,%esp
80102797:	50                   	push   %eax
80102798:	68 f3 01 00 00       	push   $0x1f3
8010279d:	e8 20 fe ff ff       	call   801025c2 <outb>
801027a2:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
801027a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027a8:	c1 f8 08             	sar    $0x8,%eax
801027ab:	0f b6 c0             	movzbl %al,%eax
801027ae:	83 ec 08             	sub    $0x8,%esp
801027b1:	50                   	push   %eax
801027b2:	68 f4 01 00 00       	push   $0x1f4
801027b7:	e8 06 fe ff ff       	call   801025c2 <outb>
801027bc:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027c2:	c1 f8 10             	sar    $0x10,%eax
801027c5:	0f b6 c0             	movzbl %al,%eax
801027c8:	83 ec 08             	sub    $0x8,%esp
801027cb:	50                   	push   %eax
801027cc:	68 f5 01 00 00       	push   $0x1f5
801027d1:	e8 ec fd ff ff       	call   801025c2 <outb>
801027d6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027d9:	8b 45 08             	mov    0x8(%ebp),%eax
801027dc:	8b 40 04             	mov    0x4(%eax),%eax
801027df:	c1 e0 04             	shl    $0x4,%eax
801027e2:	83 e0 10             	and    $0x10,%eax
801027e5:	89 c2                	mov    %eax,%edx
801027e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027ea:	c1 f8 18             	sar    $0x18,%eax
801027ed:	83 e0 0f             	and    $0xf,%eax
801027f0:	09 d0                	or     %edx,%eax
801027f2:	83 c8 e0             	or     $0xffffffe0,%eax
801027f5:	0f b6 c0             	movzbl %al,%eax
801027f8:	83 ec 08             	sub    $0x8,%esp
801027fb:	50                   	push   %eax
801027fc:	68 f6 01 00 00       	push   $0x1f6
80102801:	e8 bc fd ff ff       	call   801025c2 <outb>
80102806:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102809:	8b 45 08             	mov    0x8(%ebp),%eax
8010280c:	8b 00                	mov    (%eax),%eax
8010280e:	83 e0 04             	and    $0x4,%eax
80102811:	85 c0                	test   %eax,%eax
80102813:	74 30                	je     80102845 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102815:	83 ec 08             	sub    $0x8,%esp
80102818:	6a 30                	push   $0x30
8010281a:	68 f7 01 00 00       	push   $0x1f7
8010281f:	e8 9e fd ff ff       	call   801025c2 <outb>
80102824:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102827:	8b 45 08             	mov    0x8(%ebp),%eax
8010282a:	83 c0 18             	add    $0x18,%eax
8010282d:	83 ec 04             	sub    $0x4,%esp
80102830:	68 80 00 00 00       	push   $0x80
80102835:	50                   	push   %eax
80102836:	68 f0 01 00 00       	push   $0x1f0
8010283b:	e8 a3 fd ff ff       	call   801025e3 <outsl>
80102840:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102843:	eb 12                	jmp    80102857 <idestart+0x15b>
    outb(0x1f7, IDE_CMD_READ);
80102845:	83 ec 08             	sub    $0x8,%esp
80102848:	6a 20                	push   $0x20
8010284a:	68 f7 01 00 00       	push   $0x1f7
8010284f:	e8 6e fd ff ff       	call   801025c2 <outb>
80102854:	83 c4 10             	add    $0x10,%esp
}
80102857:	90                   	nop
80102858:	c9                   	leave  
80102859:	c3                   	ret    

8010285a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010285a:	55                   	push   %ebp
8010285b:	89 e5                	mov    %esp,%ebp
8010285d:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102860:	83 ec 0c             	sub    $0xc,%esp
80102863:	68 a0 11 11 80       	push   $0x801111a0
80102868:	e8 15 28 00 00       	call   80105082 <acquire>
8010286d:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102870:	a1 d4 11 11 80       	mov    0x801111d4,%eax
80102875:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102878:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010287c:	75 15                	jne    80102893 <ideintr+0x39>
    release(&idelock);
8010287e:	83 ec 0c             	sub    $0xc,%esp
80102881:	68 a0 11 11 80       	push   $0x801111a0
80102886:	e8 5e 28 00 00       	call   801050e9 <release>
8010288b:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010288e:	e9 9a 00 00 00       	jmp    8010292d <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102896:	8b 40 14             	mov    0x14(%eax),%eax
80102899:	a3 d4 11 11 80       	mov    %eax,0x801111d4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010289e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a1:	8b 00                	mov    (%eax),%eax
801028a3:	83 e0 04             	and    $0x4,%eax
801028a6:	85 c0                	test   %eax,%eax
801028a8:	75 2d                	jne    801028d7 <ideintr+0x7d>
801028aa:	83 ec 0c             	sub    $0xc,%esp
801028ad:	6a 01                	push   $0x1
801028af:	e8 55 fd ff ff       	call   80102609 <idewait>
801028b4:	83 c4 10             	add    $0x10,%esp
801028b7:	85 c0                	test   %eax,%eax
801028b9:	78 1c                	js     801028d7 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028be:	83 c0 18             	add    $0x18,%eax
801028c1:	83 ec 04             	sub    $0x4,%esp
801028c4:	68 80 00 00 00       	push   $0x80
801028c9:	50                   	push   %eax
801028ca:	68 f0 01 00 00       	push   $0x1f0
801028cf:	e8 c8 fc ff ff       	call   8010259c <insl>
801028d4:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028da:	8b 00                	mov    (%eax),%eax
801028dc:	83 c8 02             	or     $0x2,%eax
801028df:	89 c2                	mov    %eax,%edx
801028e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e4:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e9:	8b 00                	mov    (%eax),%eax
801028eb:	83 e0 fb             	and    $0xfffffffb,%eax
801028ee:	89 c2                	mov    %eax,%edx
801028f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f3:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028f5:	83 ec 0c             	sub    $0xc,%esp
801028f8:	ff 75 f4             	pushl  -0xc(%ebp)
801028fb:	e8 73 25 00 00       	call   80104e73 <wakeup>
80102900:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102903:	a1 d4 11 11 80       	mov    0x801111d4,%eax
80102908:	85 c0                	test   %eax,%eax
8010290a:	74 11                	je     8010291d <ideintr+0xc3>
    idestart(idequeue);
8010290c:	a1 d4 11 11 80       	mov    0x801111d4,%eax
80102911:	83 ec 0c             	sub    $0xc,%esp
80102914:	50                   	push   %eax
80102915:	e8 e2 fd ff ff       	call   801026fc <idestart>
8010291a:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010291d:	83 ec 0c             	sub    $0xc,%esp
80102920:	68 a0 11 11 80       	push   $0x801111a0
80102925:	e8 bf 27 00 00       	call   801050e9 <release>
8010292a:	83 c4 10             	add    $0x10,%esp
}
8010292d:	c9                   	leave  
8010292e:	c3                   	ret    

8010292f <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010292f:	55                   	push   %ebp
80102930:	89 e5                	mov    %esp,%ebp
80102932:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102935:	8b 45 08             	mov    0x8(%ebp),%eax
80102938:	8b 00                	mov    (%eax),%eax
8010293a:	83 e0 01             	and    $0x1,%eax
8010293d:	85 c0                	test   %eax,%eax
8010293f:	75 0d                	jne    8010294e <iderw+0x1f>
    panic("iderw: buf not busy");
80102941:	83 ec 0c             	sub    $0xc,%esp
80102944:	68 f5 87 10 80       	push   $0x801087f5
80102949:	e8 2d dc ff ff       	call   8010057b <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010294e:	8b 45 08             	mov    0x8(%ebp),%eax
80102951:	8b 00                	mov    (%eax),%eax
80102953:	83 e0 06             	and    $0x6,%eax
80102956:	83 f8 02             	cmp    $0x2,%eax
80102959:	75 0d                	jne    80102968 <iderw+0x39>
    panic("iderw: nothing to do");
8010295b:	83 ec 0c             	sub    $0xc,%esp
8010295e:	68 09 88 10 80       	push   $0x80108809
80102963:	e8 13 dc ff ff       	call   8010057b <panic>
  if(b->dev != 0 && !havedisk1)
80102968:	8b 45 08             	mov    0x8(%ebp),%eax
8010296b:	8b 40 04             	mov    0x4(%eax),%eax
8010296e:	85 c0                	test   %eax,%eax
80102970:	74 16                	je     80102988 <iderw+0x59>
80102972:	a1 d8 11 11 80       	mov    0x801111d8,%eax
80102977:	85 c0                	test   %eax,%eax
80102979:	75 0d                	jne    80102988 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
8010297b:	83 ec 0c             	sub    $0xc,%esp
8010297e:	68 1e 88 10 80       	push   $0x8010881e
80102983:	e8 f3 db ff ff       	call   8010057b <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102988:	83 ec 0c             	sub    $0xc,%esp
8010298b:	68 a0 11 11 80       	push   $0x801111a0
80102990:	e8 ed 26 00 00       	call   80105082 <acquire>
80102995:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102998:	8b 45 08             	mov    0x8(%ebp),%eax
8010299b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029a2:	c7 45 f4 d4 11 11 80 	movl   $0x801111d4,-0xc(%ebp)
801029a9:	eb 0b                	jmp    801029b6 <iderw+0x87>
801029ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ae:	8b 00                	mov    (%eax),%eax
801029b0:	83 c0 14             	add    $0x14,%eax
801029b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b9:	8b 00                	mov    (%eax),%eax
801029bb:	85 c0                	test   %eax,%eax
801029bd:	75 ec                	jne    801029ab <iderw+0x7c>
    ;
  *pp = b;
801029bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029c2:	8b 55 08             	mov    0x8(%ebp),%edx
801029c5:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801029c7:	a1 d4 11 11 80       	mov    0x801111d4,%eax
801029cc:	39 45 08             	cmp    %eax,0x8(%ebp)
801029cf:	75 23                	jne    801029f4 <iderw+0xc5>
    idestart(b);
801029d1:	83 ec 0c             	sub    $0xc,%esp
801029d4:	ff 75 08             	pushl  0x8(%ebp)
801029d7:	e8 20 fd ff ff       	call   801026fc <idestart>
801029dc:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029df:	eb 13                	jmp    801029f4 <iderw+0xc5>
    sleep(b, &idelock);
801029e1:	83 ec 08             	sub    $0x8,%esp
801029e4:	68 a0 11 11 80       	push   $0x801111a0
801029e9:	ff 75 08             	pushl  0x8(%ebp)
801029ec:	e8 96 23 00 00       	call   80104d87 <sleep>
801029f1:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029f4:	8b 45 08             	mov    0x8(%ebp),%eax
801029f7:	8b 00                	mov    (%eax),%eax
801029f9:	83 e0 06             	and    $0x6,%eax
801029fc:	83 f8 02             	cmp    $0x2,%eax
801029ff:	75 e0                	jne    801029e1 <iderw+0xb2>
  }

  release(&idelock);
80102a01:	83 ec 0c             	sub    $0xc,%esp
80102a04:	68 a0 11 11 80       	push   $0x801111a0
80102a09:	e8 db 26 00 00       	call   801050e9 <release>
80102a0e:	83 c4 10             	add    $0x10,%esp
}
80102a11:	90                   	nop
80102a12:	c9                   	leave  
80102a13:	c3                   	ret    

80102a14 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a14:	55                   	push   %ebp
80102a15:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a17:	a1 dc 11 11 80       	mov    0x801111dc,%eax
80102a1c:	8b 55 08             	mov    0x8(%ebp),%edx
80102a1f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a21:	a1 dc 11 11 80       	mov    0x801111dc,%eax
80102a26:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a29:	5d                   	pop    %ebp
80102a2a:	c3                   	ret    

80102a2b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a2b:	55                   	push   %ebp
80102a2c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a2e:	a1 dc 11 11 80       	mov    0x801111dc,%eax
80102a33:	8b 55 08             	mov    0x8(%ebp),%edx
80102a36:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a38:	a1 dc 11 11 80       	mov    0x801111dc,%eax
80102a3d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a40:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a43:	90                   	nop
80102a44:	5d                   	pop    %ebp
80102a45:	c3                   	ret    

80102a46 <ioapicinit>:

void
ioapicinit(void)
{
80102a46:	55                   	push   %ebp
80102a47:	89 e5                	mov    %esp,%ebp
80102a49:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102a4c:	a1 00 19 11 80       	mov    0x80111900,%eax
80102a51:	85 c0                	test   %eax,%eax
80102a53:	0f 84 a0 00 00 00    	je     80102af9 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a59:	c7 05 dc 11 11 80 00 	movl   $0xfec00000,0x801111dc
80102a60:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a63:	6a 01                	push   $0x1
80102a65:	e8 aa ff ff ff       	call   80102a14 <ioapicread>
80102a6a:	83 c4 04             	add    $0x4,%esp
80102a6d:	c1 e8 10             	shr    $0x10,%eax
80102a70:	25 ff 00 00 00       	and    $0xff,%eax
80102a75:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a78:	6a 00                	push   $0x0
80102a7a:	e8 95 ff ff ff       	call   80102a14 <ioapicread>
80102a7f:	83 c4 04             	add    $0x4,%esp
80102a82:	c1 e8 18             	shr    $0x18,%eax
80102a85:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a88:	0f b6 05 08 19 11 80 	movzbl 0x80111908,%eax
80102a8f:	0f b6 c0             	movzbl %al,%eax
80102a92:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102a95:	74 10                	je     80102aa7 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a97:	83 ec 0c             	sub    $0xc,%esp
80102a9a:	68 3c 88 10 80       	push   $0x8010883c
80102a9f:	e8 22 d9 ff ff       	call   801003c6 <cprintf>
80102aa4:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102aa7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102aae:	eb 3f                	jmp    80102aef <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab3:	83 c0 20             	add    $0x20,%eax
80102ab6:	0d 00 00 01 00       	or     $0x10000,%eax
80102abb:	89 c2                	mov    %eax,%edx
80102abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac0:	83 c0 08             	add    $0x8,%eax
80102ac3:	01 c0                	add    %eax,%eax
80102ac5:	83 ec 08             	sub    $0x8,%esp
80102ac8:	52                   	push   %edx
80102ac9:	50                   	push   %eax
80102aca:	e8 5c ff ff ff       	call   80102a2b <ioapicwrite>
80102acf:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad5:	83 c0 08             	add    $0x8,%eax
80102ad8:	01 c0                	add    %eax,%eax
80102ada:	83 c0 01             	add    $0x1,%eax
80102add:	83 ec 08             	sub    $0x8,%esp
80102ae0:	6a 00                	push   $0x0
80102ae2:	50                   	push   %eax
80102ae3:	e8 43 ff ff ff       	call   80102a2b <ioapicwrite>
80102ae8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102aeb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102af5:	7e b9                	jle    80102ab0 <ioapicinit+0x6a>
80102af7:	eb 01                	jmp    80102afa <ioapicinit+0xb4>
    return;
80102af9:	90                   	nop
  }
}
80102afa:	c9                   	leave  
80102afb:	c3                   	ret    

80102afc <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102afc:	55                   	push   %ebp
80102afd:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102aff:	a1 00 19 11 80       	mov    0x80111900,%eax
80102b04:	85 c0                	test   %eax,%eax
80102b06:	74 39                	je     80102b41 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b08:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0b:	83 c0 20             	add    $0x20,%eax
80102b0e:	89 c2                	mov    %eax,%edx
80102b10:	8b 45 08             	mov    0x8(%ebp),%eax
80102b13:	83 c0 08             	add    $0x8,%eax
80102b16:	01 c0                	add    %eax,%eax
80102b18:	52                   	push   %edx
80102b19:	50                   	push   %eax
80102b1a:	e8 0c ff ff ff       	call   80102a2b <ioapicwrite>
80102b1f:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b22:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b25:	c1 e0 18             	shl    $0x18,%eax
80102b28:	89 c2                	mov    %eax,%edx
80102b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2d:	83 c0 08             	add    $0x8,%eax
80102b30:	01 c0                	add    %eax,%eax
80102b32:	83 c0 01             	add    $0x1,%eax
80102b35:	52                   	push   %edx
80102b36:	50                   	push   %eax
80102b37:	e8 ef fe ff ff       	call   80102a2b <ioapicwrite>
80102b3c:	83 c4 08             	add    $0x8,%esp
80102b3f:	eb 01                	jmp    80102b42 <ioapicenable+0x46>
    return;
80102b41:	90                   	nop
}
80102b42:	c9                   	leave  
80102b43:	c3                   	ret    

80102b44 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b44:	55                   	push   %ebp
80102b45:	89 e5                	mov    %esp,%ebp
80102b47:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4a:	05 00 00 00 80       	add    $0x80000000,%eax
80102b4f:	5d                   	pop    %ebp
80102b50:	c3                   	ret    

80102b51 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b51:	55                   	push   %ebp
80102b52:	89 e5                	mov    %esp,%ebp
80102b54:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b57:	83 ec 08             	sub    $0x8,%esp
80102b5a:	68 6e 88 10 80       	push   $0x8010886e
80102b5f:	68 e0 11 11 80       	push   $0x801111e0
80102b64:	e8 f7 24 00 00       	call   80105060 <initlock>
80102b69:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b6c:	c7 05 14 12 11 80 00 	movl   $0x0,0x80111214
80102b73:	00 00 00 
  freerange(vstart, vend);
80102b76:	83 ec 08             	sub    $0x8,%esp
80102b79:	ff 75 0c             	pushl  0xc(%ebp)
80102b7c:	ff 75 08             	pushl  0x8(%ebp)
80102b7f:	e8 2a 00 00 00       	call   80102bae <freerange>
80102b84:	83 c4 10             	add    $0x10,%esp
}
80102b87:	90                   	nop
80102b88:	c9                   	leave  
80102b89:	c3                   	ret    

80102b8a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b8a:	55                   	push   %ebp
80102b8b:	89 e5                	mov    %esp,%ebp
80102b8d:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b90:	83 ec 08             	sub    $0x8,%esp
80102b93:	ff 75 0c             	pushl  0xc(%ebp)
80102b96:	ff 75 08             	pushl  0x8(%ebp)
80102b99:	e8 10 00 00 00       	call   80102bae <freerange>
80102b9e:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102ba1:	c7 05 14 12 11 80 01 	movl   $0x1,0x80111214
80102ba8:	00 00 00 
}
80102bab:	90                   	nop
80102bac:	c9                   	leave  
80102bad:	c3                   	ret    

80102bae <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bae:	55                   	push   %ebp
80102baf:	89 e5                	mov    %esp,%ebp
80102bb1:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb7:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bc4:	eb 15                	jmp    80102bdb <freerange+0x2d>
    kfree(p);
80102bc6:	83 ec 0c             	sub    $0xc,%esp
80102bc9:	ff 75 f4             	pushl  -0xc(%ebp)
80102bcc:	e8 1b 00 00 00       	call   80102bec <kfree>
80102bd1:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bd4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bde:	05 00 10 00 00       	add    $0x1000,%eax
80102be3:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102be6:	73 de                	jae    80102bc6 <freerange+0x18>
}
80102be8:	90                   	nop
80102be9:	90                   	nop
80102bea:	c9                   	leave  
80102beb:	c3                   	ret    

80102bec <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bec:	55                   	push   %ebp
80102bed:	89 e5                	mov    %esp,%ebp
80102bef:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf5:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bfa:	85 c0                	test   %eax,%eax
80102bfc:	75 1b                	jne    80102c19 <kfree+0x2d>
80102bfe:	81 7d 08 00 51 11 80 	cmpl   $0x80115100,0x8(%ebp)
80102c05:	72 12                	jb     80102c19 <kfree+0x2d>
80102c07:	ff 75 08             	pushl  0x8(%ebp)
80102c0a:	e8 35 ff ff ff       	call   80102b44 <v2p>
80102c0f:	83 c4 04             	add    $0x4,%esp
80102c12:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c17:	76 0d                	jbe    80102c26 <kfree+0x3a>
    panic("kfree");
80102c19:	83 ec 0c             	sub    $0xc,%esp
80102c1c:	68 73 88 10 80       	push   $0x80108873
80102c21:	e8 55 d9 ff ff       	call   8010057b <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c26:	83 ec 04             	sub    $0x4,%esp
80102c29:	68 00 10 00 00       	push   $0x1000
80102c2e:	6a 01                	push   $0x1
80102c30:	ff 75 08             	pushl  0x8(%ebp)
80102c33:	e8 ad 26 00 00       	call   801052e5 <memset>
80102c38:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c3b:	a1 14 12 11 80       	mov    0x80111214,%eax
80102c40:	85 c0                	test   %eax,%eax
80102c42:	74 10                	je     80102c54 <kfree+0x68>
    acquire(&kmem.lock);
80102c44:	83 ec 0c             	sub    $0xc,%esp
80102c47:	68 e0 11 11 80       	push   $0x801111e0
80102c4c:	e8 31 24 00 00       	call   80105082 <acquire>
80102c51:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c54:	8b 45 08             	mov    0x8(%ebp),%eax
80102c57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c5a:	8b 15 18 12 11 80    	mov    0x80111218,%edx
80102c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c63:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c68:	a3 18 12 11 80       	mov    %eax,0x80111218
  if(kmem.use_lock)
80102c6d:	a1 14 12 11 80       	mov    0x80111214,%eax
80102c72:	85 c0                	test   %eax,%eax
80102c74:	74 10                	je     80102c86 <kfree+0x9a>
    release(&kmem.lock);
80102c76:	83 ec 0c             	sub    $0xc,%esp
80102c79:	68 e0 11 11 80       	push   $0x801111e0
80102c7e:	e8 66 24 00 00       	call   801050e9 <release>
80102c83:	83 c4 10             	add    $0x10,%esp
}
80102c86:	90                   	nop
80102c87:	c9                   	leave  
80102c88:	c3                   	ret    

80102c89 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c89:	55                   	push   %ebp
80102c8a:	89 e5                	mov    %esp,%ebp
80102c8c:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c8f:	a1 14 12 11 80       	mov    0x80111214,%eax
80102c94:	85 c0                	test   %eax,%eax
80102c96:	74 10                	je     80102ca8 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c98:	83 ec 0c             	sub    $0xc,%esp
80102c9b:	68 e0 11 11 80       	push   $0x801111e0
80102ca0:	e8 dd 23 00 00       	call   80105082 <acquire>
80102ca5:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102ca8:	a1 18 12 11 80       	mov    0x80111218,%eax
80102cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cb4:	74 0a                	je     80102cc0 <kalloc+0x37>
    kmem.freelist = r->next;
80102cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb9:	8b 00                	mov    (%eax),%eax
80102cbb:	a3 18 12 11 80       	mov    %eax,0x80111218
  if(kmem.use_lock)
80102cc0:	a1 14 12 11 80       	mov    0x80111214,%eax
80102cc5:	85 c0                	test   %eax,%eax
80102cc7:	74 10                	je     80102cd9 <kalloc+0x50>
    release(&kmem.lock);
80102cc9:	83 ec 0c             	sub    $0xc,%esp
80102ccc:	68 e0 11 11 80       	push   $0x801111e0
80102cd1:	e8 13 24 00 00       	call   801050e9 <release>
80102cd6:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cdc:	c9                   	leave  
80102cdd:	c3                   	ret    

80102cde <inb>:
{
80102cde:	55                   	push   %ebp
80102cdf:	89 e5                	mov    %esp,%ebp
80102ce1:	83 ec 14             	sub    $0x14,%esp
80102ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ceb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cef:	89 c2                	mov    %eax,%edx
80102cf1:	ec                   	in     (%dx),%al
80102cf2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cf5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cf9:	c9                   	leave  
80102cfa:	c3                   	ret    

80102cfb <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cfb:	55                   	push   %ebp
80102cfc:	89 e5                	mov    %esp,%ebp
80102cfe:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d01:	6a 64                	push   $0x64
80102d03:	e8 d6 ff ff ff       	call   80102cde <inb>
80102d08:	83 c4 04             	add    $0x4,%esp
80102d0b:	0f b6 c0             	movzbl %al,%eax
80102d0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d14:	83 e0 01             	and    $0x1,%eax
80102d17:	85 c0                	test   %eax,%eax
80102d19:	75 0a                	jne    80102d25 <kbdgetc+0x2a>
    return -1;
80102d1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d20:	e9 23 01 00 00       	jmp    80102e48 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d25:	6a 60                	push   $0x60
80102d27:	e8 b2 ff ff ff       	call   80102cde <inb>
80102d2c:	83 c4 04             	add    $0x4,%esp
80102d2f:	0f b6 c0             	movzbl %al,%eax
80102d32:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d35:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d3c:	75 17                	jne    80102d55 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d3e:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102d43:	83 c8 40             	or     $0x40,%eax
80102d46:	a3 1c 12 11 80       	mov    %eax,0x8011121c
    return 0;
80102d4b:	b8 00 00 00 00       	mov    $0x0,%eax
80102d50:	e9 f3 00 00 00       	jmp    80102e48 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d55:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d58:	25 80 00 00 00       	and    $0x80,%eax
80102d5d:	85 c0                	test   %eax,%eax
80102d5f:	74 45                	je     80102da6 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d61:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102d66:	83 e0 40             	and    $0x40,%eax
80102d69:	85 c0                	test   %eax,%eax
80102d6b:	75 08                	jne    80102d75 <kbdgetc+0x7a>
80102d6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d70:	83 e0 7f             	and    $0x7f,%eax
80102d73:	eb 03                	jmp    80102d78 <kbdgetc+0x7d>
80102d75:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d78:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d7e:	05 20 90 10 80       	add    $0x80109020,%eax
80102d83:	0f b6 00             	movzbl (%eax),%eax
80102d86:	83 c8 40             	or     $0x40,%eax
80102d89:	0f b6 c0             	movzbl %al,%eax
80102d8c:	f7 d0                	not    %eax
80102d8e:	89 c2                	mov    %eax,%edx
80102d90:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102d95:	21 d0                	and    %edx,%eax
80102d97:	a3 1c 12 11 80       	mov    %eax,0x8011121c
    return 0;
80102d9c:	b8 00 00 00 00       	mov    $0x0,%eax
80102da1:	e9 a2 00 00 00       	jmp    80102e48 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102da6:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102dab:	83 e0 40             	and    $0x40,%eax
80102dae:	85 c0                	test   %eax,%eax
80102db0:	74 14                	je     80102dc6 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102db2:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102db9:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102dbe:	83 e0 bf             	and    $0xffffffbf,%eax
80102dc1:	a3 1c 12 11 80       	mov    %eax,0x8011121c
  }

  shift |= shiftcode[data];
80102dc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc9:	05 20 90 10 80       	add    $0x80109020,%eax
80102dce:	0f b6 00             	movzbl (%eax),%eax
80102dd1:	0f b6 d0             	movzbl %al,%edx
80102dd4:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102dd9:	09 d0                	or     %edx,%eax
80102ddb:	a3 1c 12 11 80       	mov    %eax,0x8011121c
  shift ^= togglecode[data];
80102de0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102de3:	05 20 91 10 80       	add    $0x80109120,%eax
80102de8:	0f b6 00             	movzbl (%eax),%eax
80102deb:	0f b6 d0             	movzbl %al,%edx
80102dee:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102df3:	31 d0                	xor    %edx,%eax
80102df5:	a3 1c 12 11 80       	mov    %eax,0x8011121c
  c = charcode[shift & (CTL | SHIFT)][data];
80102dfa:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102dff:	83 e0 03             	and    $0x3,%eax
80102e02:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102e09:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e0c:	01 d0                	add    %edx,%eax
80102e0e:	0f b6 00             	movzbl (%eax),%eax
80102e11:	0f b6 c0             	movzbl %al,%eax
80102e14:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e17:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102e1c:	83 e0 08             	and    $0x8,%eax
80102e1f:	85 c0                	test   %eax,%eax
80102e21:	74 22                	je     80102e45 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e23:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e27:	76 0c                	jbe    80102e35 <kbdgetc+0x13a>
80102e29:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e2d:	77 06                	ja     80102e35 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e2f:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e33:	eb 10                	jmp    80102e45 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e35:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e39:	76 0a                	jbe    80102e45 <kbdgetc+0x14a>
80102e3b:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e3f:	77 04                	ja     80102e45 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e41:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e45:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e48:	c9                   	leave  
80102e49:	c3                   	ret    

80102e4a <kbdintr>:

void
kbdintr(void)
{
80102e4a:	55                   	push   %ebp
80102e4b:	89 e5                	mov    %esp,%ebp
80102e4d:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e50:	83 ec 0c             	sub    $0xc,%esp
80102e53:	68 fb 2c 10 80       	push   $0x80102cfb
80102e58:	e8 bf d9 ff ff       	call   8010081c <consoleintr>
80102e5d:	83 c4 10             	add    $0x10,%esp
}
80102e60:	90                   	nop
80102e61:	c9                   	leave  
80102e62:	c3                   	ret    

80102e63 <inb>:
{
80102e63:	55                   	push   %ebp
80102e64:	89 e5                	mov    %esp,%ebp
80102e66:	83 ec 14             	sub    $0x14,%esp
80102e69:	8b 45 08             	mov    0x8(%ebp),%eax
80102e6c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e70:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e74:	89 c2                	mov    %eax,%edx
80102e76:	ec                   	in     (%dx),%al
80102e77:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e7a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e7e:	c9                   	leave  
80102e7f:	c3                   	ret    

80102e80 <outb>:
{
80102e80:	55                   	push   %ebp
80102e81:	89 e5                	mov    %esp,%ebp
80102e83:	83 ec 08             	sub    $0x8,%esp
80102e86:	8b 45 08             	mov    0x8(%ebp),%eax
80102e89:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e8c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e90:	89 d0                	mov    %edx,%eax
80102e92:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e95:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e99:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e9d:	ee                   	out    %al,(%dx)
}
80102e9e:	90                   	nop
80102e9f:	c9                   	leave  
80102ea0:	c3                   	ret    

80102ea1 <readeflags>:
{
80102ea1:	55                   	push   %ebp
80102ea2:	89 e5                	mov    %esp,%ebp
80102ea4:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102ea7:	9c                   	pushf  
80102ea8:	58                   	pop    %eax
80102ea9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102eac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102eaf:	c9                   	leave  
80102eb0:	c3                   	ret    

80102eb1 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102eb1:	55                   	push   %ebp
80102eb2:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102eb4:	8b 15 20 12 11 80    	mov    0x80111220,%edx
80102eba:	8b 45 08             	mov    0x8(%ebp),%eax
80102ebd:	c1 e0 02             	shl    $0x2,%eax
80102ec0:	01 c2                	add    %eax,%edx
80102ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ec5:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ec7:	a1 20 12 11 80       	mov    0x80111220,%eax
80102ecc:	83 c0 20             	add    $0x20,%eax
80102ecf:	8b 00                	mov    (%eax),%eax
}
80102ed1:	90                   	nop
80102ed2:	5d                   	pop    %ebp
80102ed3:	c3                   	ret    

80102ed4 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102ed4:	55                   	push   %ebp
80102ed5:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102ed7:	a1 20 12 11 80       	mov    0x80111220,%eax
80102edc:	85 c0                	test   %eax,%eax
80102ede:	0f 84 0c 01 00 00    	je     80102ff0 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ee4:	68 3f 01 00 00       	push   $0x13f
80102ee9:	6a 3c                	push   $0x3c
80102eeb:	e8 c1 ff ff ff       	call   80102eb1 <lapicw>
80102ef0:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ef3:	6a 0b                	push   $0xb
80102ef5:	68 f8 00 00 00       	push   $0xf8
80102efa:	e8 b2 ff ff ff       	call   80102eb1 <lapicw>
80102eff:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f02:	68 20 00 02 00       	push   $0x20020
80102f07:	68 c8 00 00 00       	push   $0xc8
80102f0c:	e8 a0 ff ff ff       	call   80102eb1 <lapicw>
80102f11:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102f14:	68 80 96 98 00       	push   $0x989680
80102f19:	68 e0 00 00 00       	push   $0xe0
80102f1e:	e8 8e ff ff ff       	call   80102eb1 <lapicw>
80102f23:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f26:	68 00 00 01 00       	push   $0x10000
80102f2b:	68 d4 00 00 00       	push   $0xd4
80102f30:	e8 7c ff ff ff       	call   80102eb1 <lapicw>
80102f35:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f38:	68 00 00 01 00       	push   $0x10000
80102f3d:	68 d8 00 00 00       	push   $0xd8
80102f42:	e8 6a ff ff ff       	call   80102eb1 <lapicw>
80102f47:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f4a:	a1 20 12 11 80       	mov    0x80111220,%eax
80102f4f:	83 c0 30             	add    $0x30,%eax
80102f52:	8b 00                	mov    (%eax),%eax
80102f54:	c1 e8 10             	shr    $0x10,%eax
80102f57:	25 fc 00 00 00       	and    $0xfc,%eax
80102f5c:	85 c0                	test   %eax,%eax
80102f5e:	74 12                	je     80102f72 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f60:	68 00 00 01 00       	push   $0x10000
80102f65:	68 d0 00 00 00       	push   $0xd0
80102f6a:	e8 42 ff ff ff       	call   80102eb1 <lapicw>
80102f6f:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f72:	6a 33                	push   $0x33
80102f74:	68 dc 00 00 00       	push   $0xdc
80102f79:	e8 33 ff ff ff       	call   80102eb1 <lapicw>
80102f7e:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f81:	6a 00                	push   $0x0
80102f83:	68 a0 00 00 00       	push   $0xa0
80102f88:	e8 24 ff ff ff       	call   80102eb1 <lapicw>
80102f8d:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f90:	6a 00                	push   $0x0
80102f92:	68 a0 00 00 00       	push   $0xa0
80102f97:	e8 15 ff ff ff       	call   80102eb1 <lapicw>
80102f9c:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f9f:	6a 00                	push   $0x0
80102fa1:	6a 2c                	push   $0x2c
80102fa3:	e8 09 ff ff ff       	call   80102eb1 <lapicw>
80102fa8:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102fab:	6a 00                	push   $0x0
80102fad:	68 c4 00 00 00       	push   $0xc4
80102fb2:	e8 fa fe ff ff       	call   80102eb1 <lapicw>
80102fb7:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fba:	68 00 85 08 00       	push   $0x88500
80102fbf:	68 c0 00 00 00       	push   $0xc0
80102fc4:	e8 e8 fe ff ff       	call   80102eb1 <lapicw>
80102fc9:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fcc:	90                   	nop
80102fcd:	a1 20 12 11 80       	mov    0x80111220,%eax
80102fd2:	05 00 03 00 00       	add    $0x300,%eax
80102fd7:	8b 00                	mov    (%eax),%eax
80102fd9:	25 00 10 00 00       	and    $0x1000,%eax
80102fde:	85 c0                	test   %eax,%eax
80102fe0:	75 eb                	jne    80102fcd <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fe2:	6a 00                	push   $0x0
80102fe4:	6a 20                	push   $0x20
80102fe6:	e8 c6 fe ff ff       	call   80102eb1 <lapicw>
80102feb:	83 c4 08             	add    $0x8,%esp
80102fee:	eb 01                	jmp    80102ff1 <lapicinit+0x11d>
    return;
80102ff0:	90                   	nop
}
80102ff1:	c9                   	leave  
80102ff2:	c3                   	ret    

80102ff3 <cpunum>:

int
cpunum(void)
{
80102ff3:	55                   	push   %ebp
80102ff4:	89 e5                	mov    %esp,%ebp
80102ff6:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102ff9:	e8 a3 fe ff ff       	call   80102ea1 <readeflags>
80102ffe:	25 00 02 00 00       	and    $0x200,%eax
80103003:	85 c0                	test   %eax,%eax
80103005:	74 26                	je     8010302d <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80103007:	a1 24 12 11 80       	mov    0x80111224,%eax
8010300c:	8d 50 01             	lea    0x1(%eax),%edx
8010300f:	89 15 24 12 11 80    	mov    %edx,0x80111224
80103015:	85 c0                	test   %eax,%eax
80103017:	75 14                	jne    8010302d <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103019:	8b 45 04             	mov    0x4(%ebp),%eax
8010301c:	83 ec 08             	sub    $0x8,%esp
8010301f:	50                   	push   %eax
80103020:	68 7c 88 10 80       	push   $0x8010887c
80103025:	e8 9c d3 ff ff       	call   801003c6 <cprintf>
8010302a:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
8010302d:	a1 20 12 11 80       	mov    0x80111220,%eax
80103032:	85 c0                	test   %eax,%eax
80103034:	74 0f                	je     80103045 <cpunum+0x52>
    return lapic[ID]>>24;
80103036:	a1 20 12 11 80       	mov    0x80111220,%eax
8010303b:	83 c0 20             	add    $0x20,%eax
8010303e:	8b 00                	mov    (%eax),%eax
80103040:	c1 e8 18             	shr    $0x18,%eax
80103043:	eb 05                	jmp    8010304a <cpunum+0x57>
  return 0;
80103045:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010304a:	c9                   	leave  
8010304b:	c3                   	ret    

8010304c <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010304c:	55                   	push   %ebp
8010304d:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010304f:	a1 20 12 11 80       	mov    0x80111220,%eax
80103054:	85 c0                	test   %eax,%eax
80103056:	74 0c                	je     80103064 <lapiceoi+0x18>
    lapicw(EOI, 0);
80103058:	6a 00                	push   $0x0
8010305a:	6a 2c                	push   $0x2c
8010305c:	e8 50 fe ff ff       	call   80102eb1 <lapicw>
80103061:	83 c4 08             	add    $0x8,%esp
}
80103064:	90                   	nop
80103065:	c9                   	leave  
80103066:	c3                   	ret    

80103067 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103067:	55                   	push   %ebp
80103068:	89 e5                	mov    %esp,%ebp
}
8010306a:	90                   	nop
8010306b:	5d                   	pop    %ebp
8010306c:	c3                   	ret    

8010306d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010306d:	55                   	push   %ebp
8010306e:	89 e5                	mov    %esp,%ebp
80103070:	83 ec 14             	sub    $0x14,%esp
80103073:	8b 45 08             	mov    0x8(%ebp),%eax
80103076:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103079:	6a 0f                	push   $0xf
8010307b:	6a 70                	push   $0x70
8010307d:	e8 fe fd ff ff       	call   80102e80 <outb>
80103082:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103085:	6a 0a                	push   $0xa
80103087:	6a 71                	push   $0x71
80103089:	e8 f2 fd ff ff       	call   80102e80 <outb>
8010308e:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103091:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103098:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010309b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801030a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801030a3:	c1 e8 04             	shr    $0x4,%eax
801030a6:	89 c2                	mov    %eax,%edx
801030a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030ab:	83 c0 02             	add    $0x2,%eax
801030ae:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801030b1:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030b5:	c1 e0 18             	shl    $0x18,%eax
801030b8:	50                   	push   %eax
801030b9:	68 c4 00 00 00       	push   $0xc4
801030be:	e8 ee fd ff ff       	call   80102eb1 <lapicw>
801030c3:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030c6:	68 00 c5 00 00       	push   $0xc500
801030cb:	68 c0 00 00 00       	push   $0xc0
801030d0:	e8 dc fd ff ff       	call   80102eb1 <lapicw>
801030d5:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030d8:	68 c8 00 00 00       	push   $0xc8
801030dd:	e8 85 ff ff ff       	call   80103067 <microdelay>
801030e2:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030e5:	68 00 85 00 00       	push   $0x8500
801030ea:	68 c0 00 00 00       	push   $0xc0
801030ef:	e8 bd fd ff ff       	call   80102eb1 <lapicw>
801030f4:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030f7:	6a 64                	push   $0x64
801030f9:	e8 69 ff ff ff       	call   80103067 <microdelay>
801030fe:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103101:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103108:	eb 3d                	jmp    80103147 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
8010310a:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010310e:	c1 e0 18             	shl    $0x18,%eax
80103111:	50                   	push   %eax
80103112:	68 c4 00 00 00       	push   $0xc4
80103117:	e8 95 fd ff ff       	call   80102eb1 <lapicw>
8010311c:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
8010311f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103122:	c1 e8 0c             	shr    $0xc,%eax
80103125:	80 cc 06             	or     $0x6,%ah
80103128:	50                   	push   %eax
80103129:	68 c0 00 00 00       	push   $0xc0
8010312e:	e8 7e fd ff ff       	call   80102eb1 <lapicw>
80103133:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103136:	68 c8 00 00 00       	push   $0xc8
8010313b:	e8 27 ff ff ff       	call   80103067 <microdelay>
80103140:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103143:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103147:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010314b:	7e bd                	jle    8010310a <lapicstartap+0x9d>
  }
}
8010314d:	90                   	nop
8010314e:	90                   	nop
8010314f:	c9                   	leave  
80103150:	c3                   	ret    

80103151 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103151:	55                   	push   %ebp
80103152:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103154:	8b 45 08             	mov    0x8(%ebp),%eax
80103157:	0f b6 c0             	movzbl %al,%eax
8010315a:	50                   	push   %eax
8010315b:	6a 70                	push   $0x70
8010315d:	e8 1e fd ff ff       	call   80102e80 <outb>
80103162:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103165:	68 c8 00 00 00       	push   $0xc8
8010316a:	e8 f8 fe ff ff       	call   80103067 <microdelay>
8010316f:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103172:	6a 71                	push   $0x71
80103174:	e8 ea fc ff ff       	call   80102e63 <inb>
80103179:	83 c4 04             	add    $0x4,%esp
8010317c:	0f b6 c0             	movzbl %al,%eax
}
8010317f:	c9                   	leave  
80103180:	c3                   	ret    

80103181 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103181:	55                   	push   %ebp
80103182:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103184:	6a 00                	push   $0x0
80103186:	e8 c6 ff ff ff       	call   80103151 <cmos_read>
8010318b:	83 c4 04             	add    $0x4,%esp
8010318e:	8b 55 08             	mov    0x8(%ebp),%edx
80103191:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103193:	6a 02                	push   $0x2
80103195:	e8 b7 ff ff ff       	call   80103151 <cmos_read>
8010319a:	83 c4 04             	add    $0x4,%esp
8010319d:	8b 55 08             	mov    0x8(%ebp),%edx
801031a0:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801031a3:	6a 04                	push   $0x4
801031a5:	e8 a7 ff ff ff       	call   80103151 <cmos_read>
801031aa:	83 c4 04             	add    $0x4,%esp
801031ad:	8b 55 08             	mov    0x8(%ebp),%edx
801031b0:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801031b3:	6a 07                	push   $0x7
801031b5:	e8 97 ff ff ff       	call   80103151 <cmos_read>
801031ba:	83 c4 04             	add    $0x4,%esp
801031bd:	8b 55 08             	mov    0x8(%ebp),%edx
801031c0:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801031c3:	6a 08                	push   $0x8
801031c5:	e8 87 ff ff ff       	call   80103151 <cmos_read>
801031ca:	83 c4 04             	add    $0x4,%esp
801031cd:	8b 55 08             	mov    0x8(%ebp),%edx
801031d0:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801031d3:	6a 09                	push   $0x9
801031d5:	e8 77 ff ff ff       	call   80103151 <cmos_read>
801031da:	83 c4 04             	add    $0x4,%esp
801031dd:	8b 55 08             	mov    0x8(%ebp),%edx
801031e0:	89 42 14             	mov    %eax,0x14(%edx)
}
801031e3:	90                   	nop
801031e4:	c9                   	leave  
801031e5:	c3                   	ret    

801031e6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031e6:	55                   	push   %ebp
801031e7:	89 e5                	mov    %esp,%ebp
801031e9:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031ec:	6a 0b                	push   $0xb
801031ee:	e8 5e ff ff ff       	call   80103151 <cmos_read>
801031f3:	83 c4 04             	add    $0x4,%esp
801031f6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031fc:	83 e0 04             	and    $0x4,%eax
801031ff:	85 c0                	test   %eax,%eax
80103201:	0f 94 c0             	sete   %al
80103204:	0f b6 c0             	movzbl %al,%eax
80103207:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010320a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010320d:	50                   	push   %eax
8010320e:	e8 6e ff ff ff       	call   80103181 <fill_rtcdate>
80103213:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103216:	6a 0a                	push   $0xa
80103218:	e8 34 ff ff ff       	call   80103151 <cmos_read>
8010321d:	83 c4 04             	add    $0x4,%esp
80103220:	25 80 00 00 00       	and    $0x80,%eax
80103225:	85 c0                	test   %eax,%eax
80103227:	75 27                	jne    80103250 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103229:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010322c:	50                   	push   %eax
8010322d:	e8 4f ff ff ff       	call   80103181 <fill_rtcdate>
80103232:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103235:	83 ec 04             	sub    $0x4,%esp
80103238:	6a 18                	push   $0x18
8010323a:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010323d:	50                   	push   %eax
8010323e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103241:	50                   	push   %eax
80103242:	e8 05 21 00 00       	call   8010534c <memcmp>
80103247:	83 c4 10             	add    $0x10,%esp
8010324a:	85 c0                	test   %eax,%eax
8010324c:	74 05                	je     80103253 <cmostime+0x6d>
8010324e:	eb ba                	jmp    8010320a <cmostime+0x24>
        continue;
80103250:	90                   	nop
    fill_rtcdate(&t1);
80103251:	eb b7                	jmp    8010320a <cmostime+0x24>
      break;
80103253:	90                   	nop
  }

  // convert
  if (bcd) {
80103254:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103258:	0f 84 b4 00 00 00    	je     80103312 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010325e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103261:	c1 e8 04             	shr    $0x4,%eax
80103264:	89 c2                	mov    %eax,%edx
80103266:	89 d0                	mov    %edx,%eax
80103268:	c1 e0 02             	shl    $0x2,%eax
8010326b:	01 d0                	add    %edx,%eax
8010326d:	01 c0                	add    %eax,%eax
8010326f:	89 c2                	mov    %eax,%edx
80103271:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103274:	83 e0 0f             	and    $0xf,%eax
80103277:	01 d0                	add    %edx,%eax
80103279:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010327c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010327f:	c1 e8 04             	shr    $0x4,%eax
80103282:	89 c2                	mov    %eax,%edx
80103284:	89 d0                	mov    %edx,%eax
80103286:	c1 e0 02             	shl    $0x2,%eax
80103289:	01 d0                	add    %edx,%eax
8010328b:	01 c0                	add    %eax,%eax
8010328d:	89 c2                	mov    %eax,%edx
8010328f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103292:	83 e0 0f             	and    $0xf,%eax
80103295:	01 d0                	add    %edx,%eax
80103297:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010329a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010329d:	c1 e8 04             	shr    $0x4,%eax
801032a0:	89 c2                	mov    %eax,%edx
801032a2:	89 d0                	mov    %edx,%eax
801032a4:	c1 e0 02             	shl    $0x2,%eax
801032a7:	01 d0                	add    %edx,%eax
801032a9:	01 c0                	add    %eax,%eax
801032ab:	89 c2                	mov    %eax,%edx
801032ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032b0:	83 e0 0f             	and    $0xf,%eax
801032b3:	01 d0                	add    %edx,%eax
801032b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801032b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032bb:	c1 e8 04             	shr    $0x4,%eax
801032be:	89 c2                	mov    %eax,%edx
801032c0:	89 d0                	mov    %edx,%eax
801032c2:	c1 e0 02             	shl    $0x2,%eax
801032c5:	01 d0                	add    %edx,%eax
801032c7:	01 c0                	add    %eax,%eax
801032c9:	89 c2                	mov    %eax,%edx
801032cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032ce:	83 e0 0f             	and    $0xf,%eax
801032d1:	01 d0                	add    %edx,%eax
801032d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032d9:	c1 e8 04             	shr    $0x4,%eax
801032dc:	89 c2                	mov    %eax,%edx
801032de:	89 d0                	mov    %edx,%eax
801032e0:	c1 e0 02             	shl    $0x2,%eax
801032e3:	01 d0                	add    %edx,%eax
801032e5:	01 c0                	add    %eax,%eax
801032e7:	89 c2                	mov    %eax,%edx
801032e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032ec:	83 e0 0f             	and    $0xf,%eax
801032ef:	01 d0                	add    %edx,%eax
801032f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032f7:	c1 e8 04             	shr    $0x4,%eax
801032fa:	89 c2                	mov    %eax,%edx
801032fc:	89 d0                	mov    %edx,%eax
801032fe:	c1 e0 02             	shl    $0x2,%eax
80103301:	01 d0                	add    %edx,%eax
80103303:	01 c0                	add    %eax,%eax
80103305:	89 c2                	mov    %eax,%edx
80103307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010330a:	83 e0 0f             	and    $0xf,%eax
8010330d:	01 d0                	add    %edx,%eax
8010330f:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103312:	8b 45 08             	mov    0x8(%ebp),%eax
80103315:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103318:	89 10                	mov    %edx,(%eax)
8010331a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010331d:	89 50 04             	mov    %edx,0x4(%eax)
80103320:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103323:	89 50 08             	mov    %edx,0x8(%eax)
80103326:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103329:	89 50 0c             	mov    %edx,0xc(%eax)
8010332c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010332f:	89 50 10             	mov    %edx,0x10(%eax)
80103332:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103335:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103338:	8b 45 08             	mov    0x8(%ebp),%eax
8010333b:	8b 40 14             	mov    0x14(%eax),%eax
8010333e:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103344:	8b 45 08             	mov    0x8(%ebp),%eax
80103347:	89 50 14             	mov    %edx,0x14(%eax)
}
8010334a:	90                   	nop
8010334b:	c9                   	leave  
8010334c:	c3                   	ret    

8010334d <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010334d:	55                   	push   %ebp
8010334e:	89 e5                	mov    %esp,%ebp
80103350:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103353:	83 ec 08             	sub    $0x8,%esp
80103356:	68 a8 88 10 80       	push   $0x801088a8
8010335b:	68 40 12 11 80       	push   $0x80111240
80103360:	e8 fb 1c 00 00       	call   80105060 <initlock>
80103365:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103368:	83 ec 08             	sub    $0x8,%esp
8010336b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010336e:	50                   	push   %eax
8010336f:	ff 75 08             	pushl  0x8(%ebp)
80103372:	e8 3a e0 ff ff       	call   801013b1 <readsb>
80103377:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010337a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010337d:	a3 74 12 11 80       	mov    %eax,0x80111274
  log.size = sb.nlog;
80103382:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103385:	a3 78 12 11 80       	mov    %eax,0x80111278
  log.dev = dev;
8010338a:	8b 45 08             	mov    0x8(%ebp),%eax
8010338d:	a3 84 12 11 80       	mov    %eax,0x80111284
  recover_from_log();
80103392:	e8 b3 01 00 00       	call   8010354a <recover_from_log>
}
80103397:	90                   	nop
80103398:	c9                   	leave  
80103399:	c3                   	ret    

8010339a <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010339a:	55                   	push   %ebp
8010339b:	89 e5                	mov    %esp,%ebp
8010339d:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033a7:	e9 95 00 00 00       	jmp    80103441 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033ac:	8b 15 74 12 11 80    	mov    0x80111274,%edx
801033b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b5:	01 d0                	add    %edx,%eax
801033b7:	83 c0 01             	add    $0x1,%eax
801033ba:	89 c2                	mov    %eax,%edx
801033bc:	a1 84 12 11 80       	mov    0x80111284,%eax
801033c1:	83 ec 08             	sub    $0x8,%esp
801033c4:	52                   	push   %edx
801033c5:	50                   	push   %eax
801033c6:	e8 ec cd ff ff       	call   801001b7 <bread>
801033cb:	83 c4 10             	add    $0x10,%esp
801033ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033d4:	83 c0 10             	add    $0x10,%eax
801033d7:	8b 04 85 4c 12 11 80 	mov    -0x7feeedb4(,%eax,4),%eax
801033de:	89 c2                	mov    %eax,%edx
801033e0:	a1 84 12 11 80       	mov    0x80111284,%eax
801033e5:	83 ec 08             	sub    $0x8,%esp
801033e8:	52                   	push   %edx
801033e9:	50                   	push   %eax
801033ea:	e8 c8 cd ff ff       	call   801001b7 <bread>
801033ef:	83 c4 10             	add    $0x10,%esp
801033f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033f8:	8d 50 18             	lea    0x18(%eax),%edx
801033fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033fe:	83 c0 18             	add    $0x18,%eax
80103401:	83 ec 04             	sub    $0x4,%esp
80103404:	68 00 02 00 00       	push   $0x200
80103409:	52                   	push   %edx
8010340a:	50                   	push   %eax
8010340b:	e8 94 1f 00 00       	call   801053a4 <memmove>
80103410:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103413:	83 ec 0c             	sub    $0xc,%esp
80103416:	ff 75 ec             	pushl  -0x14(%ebp)
80103419:	e8 d2 cd ff ff       	call   801001f0 <bwrite>
8010341e:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103421:	83 ec 0c             	sub    $0xc,%esp
80103424:	ff 75 f0             	pushl  -0x10(%ebp)
80103427:	e8 03 ce ff ff       	call   8010022f <brelse>
8010342c:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010342f:	83 ec 0c             	sub    $0xc,%esp
80103432:	ff 75 ec             	pushl  -0x14(%ebp)
80103435:	e8 f5 cd ff ff       	call   8010022f <brelse>
8010343a:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010343d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103441:	a1 88 12 11 80       	mov    0x80111288,%eax
80103446:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103449:	0f 8c 5d ff ff ff    	jl     801033ac <install_trans+0x12>
  }
}
8010344f:	90                   	nop
80103450:	90                   	nop
80103451:	c9                   	leave  
80103452:	c3                   	ret    

80103453 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103453:	55                   	push   %ebp
80103454:	89 e5                	mov    %esp,%ebp
80103456:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103459:	a1 74 12 11 80       	mov    0x80111274,%eax
8010345e:	89 c2                	mov    %eax,%edx
80103460:	a1 84 12 11 80       	mov    0x80111284,%eax
80103465:	83 ec 08             	sub    $0x8,%esp
80103468:	52                   	push   %edx
80103469:	50                   	push   %eax
8010346a:	e8 48 cd ff ff       	call   801001b7 <bread>
8010346f:	83 c4 10             	add    $0x10,%esp
80103472:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103478:	83 c0 18             	add    $0x18,%eax
8010347b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010347e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103481:	8b 00                	mov    (%eax),%eax
80103483:	a3 88 12 11 80       	mov    %eax,0x80111288
  for (i = 0; i < log.lh.n; i++) {
80103488:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010348f:	eb 1b                	jmp    801034ac <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103491:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103494:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103497:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010349b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010349e:	83 c2 10             	add    $0x10,%edx
801034a1:	89 04 95 4c 12 11 80 	mov    %eax,-0x7feeedb4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034a8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034ac:	a1 88 12 11 80       	mov    0x80111288,%eax
801034b1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034b4:	7c db                	jl     80103491 <read_head+0x3e>
  }
  brelse(buf);
801034b6:	83 ec 0c             	sub    $0xc,%esp
801034b9:	ff 75 f0             	pushl  -0x10(%ebp)
801034bc:	e8 6e cd ff ff       	call   8010022f <brelse>
801034c1:	83 c4 10             	add    $0x10,%esp
}
801034c4:	90                   	nop
801034c5:	c9                   	leave  
801034c6:	c3                   	ret    

801034c7 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034c7:	55                   	push   %ebp
801034c8:	89 e5                	mov    %esp,%ebp
801034ca:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034cd:	a1 74 12 11 80       	mov    0x80111274,%eax
801034d2:	89 c2                	mov    %eax,%edx
801034d4:	a1 84 12 11 80       	mov    0x80111284,%eax
801034d9:	83 ec 08             	sub    $0x8,%esp
801034dc:	52                   	push   %edx
801034dd:	50                   	push   %eax
801034de:	e8 d4 cc ff ff       	call   801001b7 <bread>
801034e3:	83 c4 10             	add    $0x10,%esp
801034e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ec:	83 c0 18             	add    $0x18,%eax
801034ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034f2:	8b 15 88 12 11 80    	mov    0x80111288,%edx
801034f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034fb:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103504:	eb 1b                	jmp    80103521 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103509:	83 c0 10             	add    $0x10,%eax
8010350c:	8b 0c 85 4c 12 11 80 	mov    -0x7feeedb4(,%eax,4),%ecx
80103513:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103516:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103519:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010351d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103521:	a1 88 12 11 80       	mov    0x80111288,%eax
80103526:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103529:	7c db                	jl     80103506 <write_head+0x3f>
  }
  bwrite(buf);
8010352b:	83 ec 0c             	sub    $0xc,%esp
8010352e:	ff 75 f0             	pushl  -0x10(%ebp)
80103531:	e8 ba cc ff ff       	call   801001f0 <bwrite>
80103536:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103539:	83 ec 0c             	sub    $0xc,%esp
8010353c:	ff 75 f0             	pushl  -0x10(%ebp)
8010353f:	e8 eb cc ff ff       	call   8010022f <brelse>
80103544:	83 c4 10             	add    $0x10,%esp
}
80103547:	90                   	nop
80103548:	c9                   	leave  
80103549:	c3                   	ret    

8010354a <recover_from_log>:

static void
recover_from_log(void)
{
8010354a:	55                   	push   %ebp
8010354b:	89 e5                	mov    %esp,%ebp
8010354d:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103550:	e8 fe fe ff ff       	call   80103453 <read_head>
  install_trans(); // if committed, copy from log to disk
80103555:	e8 40 fe ff ff       	call   8010339a <install_trans>
  log.lh.n = 0;
8010355a:	c7 05 88 12 11 80 00 	movl   $0x0,0x80111288
80103561:	00 00 00 
  write_head(); // clear the log
80103564:	e8 5e ff ff ff       	call   801034c7 <write_head>
}
80103569:	90                   	nop
8010356a:	c9                   	leave  
8010356b:	c3                   	ret    

8010356c <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010356c:	55                   	push   %ebp
8010356d:	89 e5                	mov    %esp,%ebp
8010356f:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103572:	83 ec 0c             	sub    $0xc,%esp
80103575:	68 40 12 11 80       	push   $0x80111240
8010357a:	e8 03 1b 00 00       	call   80105082 <acquire>
8010357f:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103582:	a1 80 12 11 80       	mov    0x80111280,%eax
80103587:	85 c0                	test   %eax,%eax
80103589:	74 17                	je     801035a2 <begin_op+0x36>
      sleep(&log, &log.lock);
8010358b:	83 ec 08             	sub    $0x8,%esp
8010358e:	68 40 12 11 80       	push   $0x80111240
80103593:	68 40 12 11 80       	push   $0x80111240
80103598:	e8 ea 17 00 00       	call   80104d87 <sleep>
8010359d:	83 c4 10             	add    $0x10,%esp
801035a0:	eb e0                	jmp    80103582 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801035a2:	8b 0d 88 12 11 80    	mov    0x80111288,%ecx
801035a8:	a1 7c 12 11 80       	mov    0x8011127c,%eax
801035ad:	8d 50 01             	lea    0x1(%eax),%edx
801035b0:	89 d0                	mov    %edx,%eax
801035b2:	c1 e0 02             	shl    $0x2,%eax
801035b5:	01 d0                	add    %edx,%eax
801035b7:	01 c0                	add    %eax,%eax
801035b9:	01 c8                	add    %ecx,%eax
801035bb:	83 f8 1e             	cmp    $0x1e,%eax
801035be:	7e 17                	jle    801035d7 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035c0:	83 ec 08             	sub    $0x8,%esp
801035c3:	68 40 12 11 80       	push   $0x80111240
801035c8:	68 40 12 11 80       	push   $0x80111240
801035cd:	e8 b5 17 00 00       	call   80104d87 <sleep>
801035d2:	83 c4 10             	add    $0x10,%esp
801035d5:	eb ab                	jmp    80103582 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801035d7:	a1 7c 12 11 80       	mov    0x8011127c,%eax
801035dc:	83 c0 01             	add    $0x1,%eax
801035df:	a3 7c 12 11 80       	mov    %eax,0x8011127c
      release(&log.lock);
801035e4:	83 ec 0c             	sub    $0xc,%esp
801035e7:	68 40 12 11 80       	push   $0x80111240
801035ec:	e8 f8 1a 00 00       	call   801050e9 <release>
801035f1:	83 c4 10             	add    $0x10,%esp
      break;
801035f4:	90                   	nop
    }
  }
}
801035f5:	90                   	nop
801035f6:	c9                   	leave  
801035f7:	c3                   	ret    

801035f8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035f8:	55                   	push   %ebp
801035f9:	89 e5                	mov    %esp,%ebp
801035fb:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103605:	83 ec 0c             	sub    $0xc,%esp
80103608:	68 40 12 11 80       	push   $0x80111240
8010360d:	e8 70 1a 00 00       	call   80105082 <acquire>
80103612:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103615:	a1 7c 12 11 80       	mov    0x8011127c,%eax
8010361a:	83 e8 01             	sub    $0x1,%eax
8010361d:	a3 7c 12 11 80       	mov    %eax,0x8011127c
  if(log.committing)
80103622:	a1 80 12 11 80       	mov    0x80111280,%eax
80103627:	85 c0                	test   %eax,%eax
80103629:	74 0d                	je     80103638 <end_op+0x40>
    panic("log.committing");
8010362b:	83 ec 0c             	sub    $0xc,%esp
8010362e:	68 ac 88 10 80       	push   $0x801088ac
80103633:	e8 43 cf ff ff       	call   8010057b <panic>
  if(log.outstanding == 0){
80103638:	a1 7c 12 11 80       	mov    0x8011127c,%eax
8010363d:	85 c0                	test   %eax,%eax
8010363f:	75 13                	jne    80103654 <end_op+0x5c>
    do_commit = 1;
80103641:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103648:	c7 05 80 12 11 80 01 	movl   $0x1,0x80111280
8010364f:	00 00 00 
80103652:	eb 10                	jmp    80103664 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103654:	83 ec 0c             	sub    $0xc,%esp
80103657:	68 40 12 11 80       	push   $0x80111240
8010365c:	e8 12 18 00 00       	call   80104e73 <wakeup>
80103661:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103664:	83 ec 0c             	sub    $0xc,%esp
80103667:	68 40 12 11 80       	push   $0x80111240
8010366c:	e8 78 1a 00 00       	call   801050e9 <release>
80103671:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103674:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103678:	74 3f                	je     801036b9 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010367a:	e8 f6 00 00 00       	call   80103775 <commit>
    acquire(&log.lock);
8010367f:	83 ec 0c             	sub    $0xc,%esp
80103682:	68 40 12 11 80       	push   $0x80111240
80103687:	e8 f6 19 00 00       	call   80105082 <acquire>
8010368c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010368f:	c7 05 80 12 11 80 00 	movl   $0x0,0x80111280
80103696:	00 00 00 
    wakeup(&log);
80103699:	83 ec 0c             	sub    $0xc,%esp
8010369c:	68 40 12 11 80       	push   $0x80111240
801036a1:	e8 cd 17 00 00       	call   80104e73 <wakeup>
801036a6:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801036a9:	83 ec 0c             	sub    $0xc,%esp
801036ac:	68 40 12 11 80       	push   $0x80111240
801036b1:	e8 33 1a 00 00       	call   801050e9 <release>
801036b6:	83 c4 10             	add    $0x10,%esp
  }
}
801036b9:	90                   	nop
801036ba:	c9                   	leave  
801036bb:	c3                   	ret    

801036bc <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801036bc:	55                   	push   %ebp
801036bd:	89 e5                	mov    %esp,%ebp
801036bf:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036c9:	e9 95 00 00 00       	jmp    80103763 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036ce:	8b 15 74 12 11 80    	mov    0x80111274,%edx
801036d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036d7:	01 d0                	add    %edx,%eax
801036d9:	83 c0 01             	add    $0x1,%eax
801036dc:	89 c2                	mov    %eax,%edx
801036de:	a1 84 12 11 80       	mov    0x80111284,%eax
801036e3:	83 ec 08             	sub    $0x8,%esp
801036e6:	52                   	push   %edx
801036e7:	50                   	push   %eax
801036e8:	e8 ca ca ff ff       	call   801001b7 <bread>
801036ed:	83 c4 10             	add    $0x10,%esp
801036f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036f6:	83 c0 10             	add    $0x10,%eax
801036f9:	8b 04 85 4c 12 11 80 	mov    -0x7feeedb4(,%eax,4),%eax
80103700:	89 c2                	mov    %eax,%edx
80103702:	a1 84 12 11 80       	mov    0x80111284,%eax
80103707:	83 ec 08             	sub    $0x8,%esp
8010370a:	52                   	push   %edx
8010370b:	50                   	push   %eax
8010370c:	e8 a6 ca ff ff       	call   801001b7 <bread>
80103711:	83 c4 10             	add    $0x10,%esp
80103714:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103717:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010371a:	8d 50 18             	lea    0x18(%eax),%edx
8010371d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103720:	83 c0 18             	add    $0x18,%eax
80103723:	83 ec 04             	sub    $0x4,%esp
80103726:	68 00 02 00 00       	push   $0x200
8010372b:	52                   	push   %edx
8010372c:	50                   	push   %eax
8010372d:	e8 72 1c 00 00       	call   801053a4 <memmove>
80103732:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103735:	83 ec 0c             	sub    $0xc,%esp
80103738:	ff 75 f0             	pushl  -0x10(%ebp)
8010373b:	e8 b0 ca ff ff       	call   801001f0 <bwrite>
80103740:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103743:	83 ec 0c             	sub    $0xc,%esp
80103746:	ff 75 ec             	pushl  -0x14(%ebp)
80103749:	e8 e1 ca ff ff       	call   8010022f <brelse>
8010374e:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103751:	83 ec 0c             	sub    $0xc,%esp
80103754:	ff 75 f0             	pushl  -0x10(%ebp)
80103757:	e8 d3 ca ff ff       	call   8010022f <brelse>
8010375c:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010375f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103763:	a1 88 12 11 80       	mov    0x80111288,%eax
80103768:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010376b:	0f 8c 5d ff ff ff    	jl     801036ce <write_log+0x12>
  }
}
80103771:	90                   	nop
80103772:	90                   	nop
80103773:	c9                   	leave  
80103774:	c3                   	ret    

80103775 <commit>:

static void
commit()
{
80103775:	55                   	push   %ebp
80103776:	89 e5                	mov    %esp,%ebp
80103778:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010377b:	a1 88 12 11 80       	mov    0x80111288,%eax
80103780:	85 c0                	test   %eax,%eax
80103782:	7e 1e                	jle    801037a2 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103784:	e8 33 ff ff ff       	call   801036bc <write_log>
    write_head();    // Write header to disk -- the real commit
80103789:	e8 39 fd ff ff       	call   801034c7 <write_head>
    install_trans(); // Now install writes to home locations
8010378e:	e8 07 fc ff ff       	call   8010339a <install_trans>
    log.lh.n = 0; 
80103793:	c7 05 88 12 11 80 00 	movl   $0x0,0x80111288
8010379a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010379d:	e8 25 fd ff ff       	call   801034c7 <write_head>
  }
}
801037a2:	90                   	nop
801037a3:	c9                   	leave  
801037a4:	c3                   	ret    

801037a5 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801037a5:	55                   	push   %ebp
801037a6:	89 e5                	mov    %esp,%ebp
801037a8:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801037ab:	a1 88 12 11 80       	mov    0x80111288,%eax
801037b0:	83 f8 1d             	cmp    $0x1d,%eax
801037b3:	7f 12                	jg     801037c7 <log_write+0x22>
801037b5:	a1 88 12 11 80       	mov    0x80111288,%eax
801037ba:	8b 15 78 12 11 80    	mov    0x80111278,%edx
801037c0:	83 ea 01             	sub    $0x1,%edx
801037c3:	39 d0                	cmp    %edx,%eax
801037c5:	7c 0d                	jl     801037d4 <log_write+0x2f>
    panic("too big a transaction");
801037c7:	83 ec 0c             	sub    $0xc,%esp
801037ca:	68 bb 88 10 80       	push   $0x801088bb
801037cf:	e8 a7 cd ff ff       	call   8010057b <panic>
  if (log.outstanding < 1)
801037d4:	a1 7c 12 11 80       	mov    0x8011127c,%eax
801037d9:	85 c0                	test   %eax,%eax
801037db:	7f 0d                	jg     801037ea <log_write+0x45>
    panic("log_write outside of trans");
801037dd:	83 ec 0c             	sub    $0xc,%esp
801037e0:	68 d1 88 10 80       	push   $0x801088d1
801037e5:	e8 91 cd ff ff       	call   8010057b <panic>

  acquire(&log.lock);
801037ea:	83 ec 0c             	sub    $0xc,%esp
801037ed:	68 40 12 11 80       	push   $0x80111240
801037f2:	e8 8b 18 00 00       	call   80105082 <acquire>
801037f7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103801:	eb 1d                	jmp    80103820 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103806:	83 c0 10             	add    $0x10,%eax
80103809:	8b 04 85 4c 12 11 80 	mov    -0x7feeedb4(,%eax,4),%eax
80103810:	89 c2                	mov    %eax,%edx
80103812:	8b 45 08             	mov    0x8(%ebp),%eax
80103815:	8b 40 08             	mov    0x8(%eax),%eax
80103818:	39 c2                	cmp    %eax,%edx
8010381a:	74 10                	je     8010382c <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
8010381c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103820:	a1 88 12 11 80       	mov    0x80111288,%eax
80103825:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103828:	7c d9                	jl     80103803 <log_write+0x5e>
8010382a:	eb 01                	jmp    8010382d <log_write+0x88>
      break;
8010382c:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
8010382d:	8b 45 08             	mov    0x8(%ebp),%eax
80103830:	8b 40 08             	mov    0x8(%eax),%eax
80103833:	89 c2                	mov    %eax,%edx
80103835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103838:	83 c0 10             	add    $0x10,%eax
8010383b:	89 14 85 4c 12 11 80 	mov    %edx,-0x7feeedb4(,%eax,4)
  if (i == log.lh.n)
80103842:	a1 88 12 11 80       	mov    0x80111288,%eax
80103847:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010384a:	75 0d                	jne    80103859 <log_write+0xb4>
    log.lh.n++;
8010384c:	a1 88 12 11 80       	mov    0x80111288,%eax
80103851:	83 c0 01             	add    $0x1,%eax
80103854:	a3 88 12 11 80       	mov    %eax,0x80111288
  b->flags |= B_DIRTY; // prevent eviction
80103859:	8b 45 08             	mov    0x8(%ebp),%eax
8010385c:	8b 00                	mov    (%eax),%eax
8010385e:	83 c8 04             	or     $0x4,%eax
80103861:	89 c2                	mov    %eax,%edx
80103863:	8b 45 08             	mov    0x8(%ebp),%eax
80103866:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103868:	83 ec 0c             	sub    $0xc,%esp
8010386b:	68 40 12 11 80       	push   $0x80111240
80103870:	e8 74 18 00 00       	call   801050e9 <release>
80103875:	83 c4 10             	add    $0x10,%esp
}
80103878:	90                   	nop
80103879:	c9                   	leave  
8010387a:	c3                   	ret    

8010387b <v2p>:
8010387b:	55                   	push   %ebp
8010387c:	89 e5                	mov    %esp,%ebp
8010387e:	8b 45 08             	mov    0x8(%ebp),%eax
80103881:	05 00 00 00 80       	add    $0x80000000,%eax
80103886:	5d                   	pop    %ebp
80103887:	c3                   	ret    

80103888 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103888:	55                   	push   %ebp
80103889:	89 e5                	mov    %esp,%ebp
8010388b:	8b 45 08             	mov    0x8(%ebp),%eax
8010388e:	05 00 00 00 80       	add    $0x80000000,%eax
80103893:	5d                   	pop    %ebp
80103894:	c3                   	ret    

80103895 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103895:	55                   	push   %ebp
80103896:	89 e5                	mov    %esp,%ebp
80103898:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010389b:	8b 55 08             	mov    0x8(%ebp),%edx
8010389e:	8b 45 0c             	mov    0xc(%ebp),%eax
801038a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801038a4:	f0 87 02             	lock xchg %eax,(%edx)
801038a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801038aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801038ad:	c9                   	leave  
801038ae:	c3                   	ret    

801038af <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801038af:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801038b3:	83 e4 f0             	and    $0xfffffff0,%esp
801038b6:	ff 71 fc             	pushl  -0x4(%ecx)
801038b9:	55                   	push   %ebp
801038ba:	89 e5                	mov    %esp,%ebp
801038bc:	51                   	push   %ecx
801038bd:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038c0:	83 ec 08             	sub    $0x8,%esp
801038c3:	68 00 00 40 80       	push   $0x80400000
801038c8:	68 00 51 11 80       	push   $0x80115100
801038cd:	e8 7f f2 ff ff       	call   80102b51 <kinit1>
801038d2:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038d5:	e8 e3 45 00 00       	call   80107ebd <kvmalloc>
  mpinit();        // collect info about this machine
801038da:	e8 3a 04 00 00       	call   80103d19 <mpinit>
  lapicinit();
801038df:	e8 f0 f5 ff ff       	call   80102ed4 <lapicinit>
  seginit();       // set up segments
801038e4:	e8 7d 3f 00 00       	call   80107866 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801038e9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038ef:	0f b6 00             	movzbl (%eax),%eax
801038f2:	0f b6 c0             	movzbl %al,%eax
801038f5:	83 ec 08             	sub    $0x8,%esp
801038f8:	50                   	push   %eax
801038f9:	68 ec 88 10 80       	push   $0x801088ec
801038fe:	e8 c3 ca ff ff       	call   801003c6 <cprintf>
80103903:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103906:	e8 8a 06 00 00       	call   80103f95 <picinit>
  ioapicinit();    // another interrupt controller
8010390b:	e8 36 f1 ff ff       	call   80102a46 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103910:	e8 31 d2 ff ff       	call   80100b46 <consoleinit>
  uartinit();      // serial port
80103915:	e8 a8 32 00 00       	call   80106bc2 <uartinit>
  pinit();         // process table
8010391a:	e8 7a 0b 00 00       	call   80104499 <pinit>
  tvinit();        // trap vectors
8010391f:	e8 65 2e 00 00       	call   80106789 <tvinit>
  binit();         // buffer cache
80103924:	e8 0b c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103929:	e8 74 d6 ff ff       	call   80100fa2 <fileinit>
  ideinit();       // disk
8010392e:	e8 1b ed ff ff       	call   8010264e <ideinit>
  if(!ismp)
80103933:	a1 00 19 11 80       	mov    0x80111900,%eax
80103938:	85 c0                	test   %eax,%eax
8010393a:	75 05                	jne    80103941 <main+0x92>
    timerinit();   // uniprocessor timer
8010393c:	e8 a5 2d 00 00       	call   801066e6 <timerinit>
  startothers();   // start other processors
80103941:	e8 7f 00 00 00       	call   801039c5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103946:	83 ec 08             	sub    $0x8,%esp
80103949:	68 00 00 00 8e       	push   $0x8e000000
8010394e:	68 00 00 40 80       	push   $0x80400000
80103953:	e8 32 f2 ff ff       	call   80102b8a <kinit2>
80103958:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010395b:	e8 5b 0c 00 00       	call   801045bb <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103960:	e8 1a 00 00 00       	call   8010397f <mpmain>

80103965 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103965:	55                   	push   %ebp
80103966:	89 e5                	mov    %esp,%ebp
80103968:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010396b:	e8 65 45 00 00       	call   80107ed5 <switchkvm>
  seginit();
80103970:	e8 f1 3e 00 00       	call   80107866 <seginit>
  lapicinit();
80103975:	e8 5a f5 ff ff       	call   80102ed4 <lapicinit>
  mpmain();
8010397a:	e8 00 00 00 00       	call   8010397f <mpmain>

8010397f <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103985:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010398b:	0f b6 00             	movzbl (%eax),%eax
8010398e:	0f b6 c0             	movzbl %al,%eax
80103991:	83 ec 08             	sub    $0x8,%esp
80103994:	50                   	push   %eax
80103995:	68 03 89 10 80       	push   $0x80108903
8010399a:	e8 27 ca ff ff       	call   801003c6 <cprintf>
8010399f:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801039a2:	e8 58 2f 00 00       	call   801068ff <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801039a7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801039ad:	05 a8 00 00 00       	add    $0xa8,%eax
801039b2:	83 ec 08             	sub    $0x8,%esp
801039b5:	6a 01                	push   $0x1
801039b7:	50                   	push   %eax
801039b8:	e8 d8 fe ff ff       	call   80103895 <xchg>
801039bd:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039c0:	e8 99 11 00 00       	call   80104b5e <scheduler>

801039c5 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039c5:	55                   	push   %ebp
801039c6:	89 e5                	mov    %esp,%ebp
801039c8:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801039cb:	68 00 70 00 00       	push   $0x7000
801039d0:	e8 b3 fe ff ff       	call   80103888 <p2v>
801039d5:	83 c4 04             	add    $0x4,%esp
801039d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039db:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039e0:	83 ec 04             	sub    $0x4,%esp
801039e3:	50                   	push   %eax
801039e4:	68 0c b5 10 80       	push   $0x8010b50c
801039e9:	ff 75 f0             	pushl  -0x10(%ebp)
801039ec:	e8 b3 19 00 00       	call   801053a4 <memmove>
801039f1:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039f4:	c7 45 f4 20 13 11 80 	movl   $0x80111320,-0xc(%ebp)
801039fb:	e9 8e 00 00 00       	jmp    80103a8e <startothers+0xc9>
    if(c == cpus+cpunum())  // We've started already.
80103a00:	e8 ee f5 ff ff       	call   80102ff3 <cpunum>
80103a05:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a0b:	05 20 13 11 80       	add    $0x80111320,%eax
80103a10:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a13:	74 71                	je     80103a86 <startothers+0xc1>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a15:	e8 6f f2 ff ff       	call   80102c89 <kalloc>
80103a1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a20:	83 e8 04             	sub    $0x4,%eax
80103a23:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a26:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a2c:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a31:	83 e8 08             	sub    $0x8,%eax
80103a34:	c7 00 65 39 10 80    	movl   $0x80103965,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a3a:	83 ec 0c             	sub    $0xc,%esp
80103a3d:	68 00 a0 10 80       	push   $0x8010a000
80103a42:	e8 34 fe ff ff       	call   8010387b <v2p>
80103a47:	83 c4 10             	add    $0x10,%esp
80103a4a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103a4d:	83 ea 0c             	sub    $0xc,%edx
80103a50:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->id, v2p(code));
80103a52:	83 ec 0c             	sub    $0xc,%esp
80103a55:	ff 75 f0             	pushl  -0x10(%ebp)
80103a58:	e8 1e fe ff ff       	call   8010387b <v2p>
80103a5d:	83 c4 10             	add    $0x10,%esp
80103a60:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a63:	0f b6 12             	movzbl (%edx),%edx
80103a66:	0f b6 d2             	movzbl %dl,%edx
80103a69:	83 ec 08             	sub    $0x8,%esp
80103a6c:	50                   	push   %eax
80103a6d:	52                   	push   %edx
80103a6e:	e8 fa f5 ff ff       	call   8010306d <lapicstartap>
80103a73:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a76:	90                   	nop
80103a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a80:	85 c0                	test   %eax,%eax
80103a82:	74 f3                	je     80103a77 <startothers+0xb2>
80103a84:	eb 01                	jmp    80103a87 <startothers+0xc2>
      continue;
80103a86:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103a87:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a8e:	a1 04 19 11 80       	mov    0x80111904,%eax
80103a93:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a99:	05 20 13 11 80       	add    $0x80111320,%eax
80103a9e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103aa1:	0f 82 59 ff ff ff    	jb     80103a00 <startothers+0x3b>
      ;
  }
}
80103aa7:	90                   	nop
80103aa8:	90                   	nop
80103aa9:	c9                   	leave  
80103aaa:	c3                   	ret    

80103aab <p2v>:
80103aab:	55                   	push   %ebp
80103aac:	89 e5                	mov    %esp,%ebp
80103aae:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab1:	05 00 00 00 80       	add    $0x80000000,%eax
80103ab6:	5d                   	pop    %ebp
80103ab7:	c3                   	ret    

80103ab8 <inb>:
{
80103ab8:	55                   	push   %ebp
80103ab9:	89 e5                	mov    %esp,%ebp
80103abb:	83 ec 14             	sub    $0x14,%esp
80103abe:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103ac5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103ac9:	89 c2                	mov    %eax,%edx
80103acb:	ec                   	in     (%dx),%al
80103acc:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103acf:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103ad3:	c9                   	leave  
80103ad4:	c3                   	ret    

80103ad5 <outb>:
{
80103ad5:	55                   	push   %ebp
80103ad6:	89 e5                	mov    %esp,%ebp
80103ad8:	83 ec 08             	sub    $0x8,%esp
80103adb:	8b 45 08             	mov    0x8(%ebp),%eax
80103ade:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ae1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103ae5:	89 d0                	mov    %edx,%eax
80103ae7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103aea:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103aee:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103af2:	ee                   	out    %al,(%dx)
}
80103af3:	90                   	nop
80103af4:	c9                   	leave  
80103af5:	c3                   	ret    

80103af6 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103af6:	55                   	push   %ebp
80103af7:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103af9:	a1 0c 19 11 80       	mov    0x8011190c,%eax
80103afe:	2d 20 13 11 80       	sub    $0x80111320,%eax
80103b03:	c1 f8 02             	sar    $0x2,%eax
80103b06:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103b0c:	5d                   	pop    %ebp
80103b0d:	c3                   	ret    

80103b0e <sum>:

static uchar
sum(uchar *addr, int len)
{
80103b0e:	55                   	push   %ebp
80103b0f:	89 e5                	mov    %esp,%ebp
80103b11:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103b14:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b1b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b22:	eb 15                	jmp    80103b39 <sum+0x2b>
    sum += addr[i];
80103b24:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b27:	8b 45 08             	mov    0x8(%ebp),%eax
80103b2a:	01 d0                	add    %edx,%eax
80103b2c:	0f b6 00             	movzbl (%eax),%eax
80103b2f:	0f b6 c0             	movzbl %al,%eax
80103b32:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b35:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b39:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b3c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b3f:	7c e3                	jl     80103b24 <sum+0x16>
  return sum;
80103b41:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b44:	c9                   	leave  
80103b45:	c3                   	ret    

80103b46 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b46:	55                   	push   %ebp
80103b47:	89 e5                	mov    %esp,%ebp
80103b49:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b4c:	ff 75 08             	pushl  0x8(%ebp)
80103b4f:	e8 57 ff ff ff       	call   80103aab <p2v>
80103b54:	83 c4 04             	add    $0x4,%esp
80103b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b5a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b60:	01 d0                	add    %edx,%eax
80103b62:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b68:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b6b:	eb 36                	jmp    80103ba3 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b6d:	83 ec 04             	sub    $0x4,%esp
80103b70:	6a 04                	push   $0x4
80103b72:	68 14 89 10 80       	push   $0x80108914
80103b77:	ff 75 f4             	pushl  -0xc(%ebp)
80103b7a:	e8 cd 17 00 00       	call   8010534c <memcmp>
80103b7f:	83 c4 10             	add    $0x10,%esp
80103b82:	85 c0                	test   %eax,%eax
80103b84:	75 19                	jne    80103b9f <mpsearch1+0x59>
80103b86:	83 ec 08             	sub    $0x8,%esp
80103b89:	6a 10                	push   $0x10
80103b8b:	ff 75 f4             	pushl  -0xc(%ebp)
80103b8e:	e8 7b ff ff ff       	call   80103b0e <sum>
80103b93:	83 c4 10             	add    $0x10,%esp
80103b96:	84 c0                	test   %al,%al
80103b98:	75 05                	jne    80103b9f <mpsearch1+0x59>
      return (struct mp*)p;
80103b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9d:	eb 11                	jmp    80103bb0 <mpsearch1+0x6a>
  for(p = addr; p < e; p += sizeof(struct mp))
80103b9f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ba9:	72 c2                	jb     80103b6d <mpsearch1+0x27>
  return 0;
80103bab:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103bb0:	c9                   	leave  
80103bb1:	c3                   	ret    

80103bb2 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103bb2:	55                   	push   %ebp
80103bb3:	89 e5                	mov    %esp,%ebp
80103bb5:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103bb8:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc2:	83 c0 0f             	add    $0xf,%eax
80103bc5:	0f b6 00             	movzbl (%eax),%eax
80103bc8:	0f b6 c0             	movzbl %al,%eax
80103bcb:	c1 e0 08             	shl    $0x8,%eax
80103bce:	89 c2                	mov    %eax,%edx
80103bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd3:	83 c0 0e             	add    $0xe,%eax
80103bd6:	0f b6 00             	movzbl (%eax),%eax
80103bd9:	0f b6 c0             	movzbl %al,%eax
80103bdc:	09 d0                	or     %edx,%eax
80103bde:	c1 e0 04             	shl    $0x4,%eax
80103be1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103be4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103be8:	74 21                	je     80103c0b <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bea:	83 ec 08             	sub    $0x8,%esp
80103bed:	68 00 04 00 00       	push   $0x400
80103bf2:	ff 75 f0             	pushl  -0x10(%ebp)
80103bf5:	e8 4c ff ff ff       	call   80103b46 <mpsearch1>
80103bfa:	83 c4 10             	add    $0x10,%esp
80103bfd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c00:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c04:	74 51                	je     80103c57 <mpsearch+0xa5>
      return mp;
80103c06:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c09:	eb 61                	jmp    80103c6c <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0e:	83 c0 14             	add    $0x14,%eax
80103c11:	0f b6 00             	movzbl (%eax),%eax
80103c14:	0f b6 c0             	movzbl %al,%eax
80103c17:	c1 e0 08             	shl    $0x8,%eax
80103c1a:	89 c2                	mov    %eax,%edx
80103c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1f:	83 c0 13             	add    $0x13,%eax
80103c22:	0f b6 00             	movzbl (%eax),%eax
80103c25:	0f b6 c0             	movzbl %al,%eax
80103c28:	09 d0                	or     %edx,%eax
80103c2a:	c1 e0 0a             	shl    $0xa,%eax
80103c2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c33:	2d 00 04 00 00       	sub    $0x400,%eax
80103c38:	83 ec 08             	sub    $0x8,%esp
80103c3b:	68 00 04 00 00       	push   $0x400
80103c40:	50                   	push   %eax
80103c41:	e8 00 ff ff ff       	call   80103b46 <mpsearch1>
80103c46:	83 c4 10             	add    $0x10,%esp
80103c49:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c4c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c50:	74 05                	je     80103c57 <mpsearch+0xa5>
      return mp;
80103c52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c55:	eb 15                	jmp    80103c6c <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c57:	83 ec 08             	sub    $0x8,%esp
80103c5a:	68 00 00 01 00       	push   $0x10000
80103c5f:	68 00 00 0f 00       	push   $0xf0000
80103c64:	e8 dd fe ff ff       	call   80103b46 <mpsearch1>
80103c69:	83 c4 10             	add    $0x10,%esp
}
80103c6c:	c9                   	leave  
80103c6d:	c3                   	ret    

80103c6e <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c6e:	55                   	push   %ebp
80103c6f:	89 e5                	mov    %esp,%ebp
80103c71:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c74:	e8 39 ff ff ff       	call   80103bb2 <mpsearch>
80103c79:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c7c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c80:	74 0a                	je     80103c8c <mpconfig+0x1e>
80103c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c85:	8b 40 04             	mov    0x4(%eax),%eax
80103c88:	85 c0                	test   %eax,%eax
80103c8a:	75 0a                	jne    80103c96 <mpconfig+0x28>
    return 0;
80103c8c:	b8 00 00 00 00       	mov    $0x0,%eax
80103c91:	e9 81 00 00 00       	jmp    80103d17 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c99:	8b 40 04             	mov    0x4(%eax),%eax
80103c9c:	83 ec 0c             	sub    $0xc,%esp
80103c9f:	50                   	push   %eax
80103ca0:	e8 06 fe ff ff       	call   80103aab <p2v>
80103ca5:	83 c4 10             	add    $0x10,%esp
80103ca8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103cab:	83 ec 04             	sub    $0x4,%esp
80103cae:	6a 04                	push   $0x4
80103cb0:	68 19 89 10 80       	push   $0x80108919
80103cb5:	ff 75 f0             	pushl  -0x10(%ebp)
80103cb8:	e8 8f 16 00 00       	call   8010534c <memcmp>
80103cbd:	83 c4 10             	add    $0x10,%esp
80103cc0:	85 c0                	test   %eax,%eax
80103cc2:	74 07                	je     80103ccb <mpconfig+0x5d>
    return 0;
80103cc4:	b8 00 00 00 00       	mov    $0x0,%eax
80103cc9:	eb 4c                	jmp    80103d17 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cce:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cd2:	3c 01                	cmp    $0x1,%al
80103cd4:	74 12                	je     80103ce8 <mpconfig+0x7a>
80103cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd9:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cdd:	3c 04                	cmp    $0x4,%al
80103cdf:	74 07                	je     80103ce8 <mpconfig+0x7a>
    return 0;
80103ce1:	b8 00 00 00 00       	mov    $0x0,%eax
80103ce6:	eb 2f                	jmp    80103d17 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ceb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cef:	0f b7 c0             	movzwl %ax,%eax
80103cf2:	83 ec 08             	sub    $0x8,%esp
80103cf5:	50                   	push   %eax
80103cf6:	ff 75 f0             	pushl  -0x10(%ebp)
80103cf9:	e8 10 fe ff ff       	call   80103b0e <sum>
80103cfe:	83 c4 10             	add    $0x10,%esp
80103d01:	84 c0                	test   %al,%al
80103d03:	74 07                	je     80103d0c <mpconfig+0x9e>
    return 0;
80103d05:	b8 00 00 00 00       	mov    $0x0,%eax
80103d0a:	eb 0b                	jmp    80103d17 <mpconfig+0xa9>
  *pmp = mp;
80103d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d12:	89 10                	mov    %edx,(%eax)
  return conf;
80103d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d17:	c9                   	leave  
80103d18:	c3                   	ret    

80103d19 <mpinit>:

void
mpinit(void)
{
80103d19:	55                   	push   %ebp
80103d1a:	89 e5                	mov    %esp,%ebp
80103d1c:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d1f:	c7 05 0c 19 11 80 20 	movl   $0x80111320,0x8011190c
80103d26:	13 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d29:	83 ec 0c             	sub    $0xc,%esp
80103d2c:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d2f:	50                   	push   %eax
80103d30:	e8 39 ff ff ff       	call   80103c6e <mpconfig>
80103d35:	83 c4 10             	add    $0x10,%esp
80103d38:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d3f:	0f 84 ba 01 00 00    	je     80103eff <mpinit+0x1e6>
    return;
  ismp = 1;
80103d45:	c7 05 00 19 11 80 01 	movl   $0x1,0x80111900
80103d4c:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d52:	8b 40 24             	mov    0x24(%eax),%eax
80103d55:	a3 20 12 11 80       	mov    %eax,0x80111220
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d5d:	83 c0 2c             	add    $0x2c,%eax
80103d60:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d66:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d6a:	0f b7 d0             	movzwl %ax,%edx
80103d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d70:	01 d0                	add    %edx,%eax
80103d72:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d75:	e9 16 01 00 00       	jmp    80103e90 <mpinit+0x177>
    switch(*p){
80103d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7d:	0f b6 00             	movzbl (%eax),%eax
80103d80:	0f b6 c0             	movzbl %al,%eax
80103d83:	83 f8 04             	cmp    $0x4,%eax
80103d86:	0f 8f e0 00 00 00    	jg     80103e6c <mpinit+0x153>
80103d8c:	83 f8 03             	cmp    $0x3,%eax
80103d8f:	0f 8d d1 00 00 00    	jge    80103e66 <mpinit+0x14d>
80103d95:	83 f8 02             	cmp    $0x2,%eax
80103d98:	0f 84 b0 00 00 00    	je     80103e4e <mpinit+0x135>
80103d9e:	83 f8 02             	cmp    $0x2,%eax
80103da1:	0f 8f c5 00 00 00    	jg     80103e6c <mpinit+0x153>
80103da7:	85 c0                	test   %eax,%eax
80103da9:	74 0e                	je     80103db9 <mpinit+0xa0>
80103dab:	83 f8 01             	cmp    $0x1,%eax
80103dae:	0f 84 b2 00 00 00    	je     80103e66 <mpinit+0x14d>
80103db4:	e9 b3 00 00 00       	jmp    80103e6c <mpinit+0x153>
    case MPPROC:
      proc = (struct mpproc*)p;
80103db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu != proc->apicid){
80103dbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103dc2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103dc6:	0f b6 d0             	movzbl %al,%edx
80103dc9:	a1 04 19 11 80       	mov    0x80111904,%eax
80103dce:	39 c2                	cmp    %eax,%edx
80103dd0:	74 2b                	je     80103dfd <mpinit+0xe4>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103dd5:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103dd9:	0f b6 d0             	movzbl %al,%edx
80103ddc:	a1 04 19 11 80       	mov    0x80111904,%eax
80103de1:	83 ec 04             	sub    $0x4,%esp
80103de4:	52                   	push   %edx
80103de5:	50                   	push   %eax
80103de6:	68 1e 89 10 80       	push   $0x8010891e
80103deb:	e8 d6 c5 ff ff       	call   801003c6 <cprintf>
80103df0:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103df3:	c7 05 00 19 11 80 00 	movl   $0x0,0x80111900
80103dfa:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103dfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e00:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103e04:	0f b6 c0             	movzbl %al,%eax
80103e07:	83 e0 02             	and    $0x2,%eax
80103e0a:	85 c0                	test   %eax,%eax
80103e0c:	74 15                	je     80103e23 <mpinit+0x10a>
        bcpu = &cpus[ncpu];
80103e0e:	a1 04 19 11 80       	mov    0x80111904,%eax
80103e13:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e19:	05 20 13 11 80       	add    $0x80111320,%eax
80103e1e:	a3 0c 19 11 80       	mov    %eax,0x8011190c
      cpus[ncpu].id = ncpu;
80103e23:	8b 15 04 19 11 80    	mov    0x80111904,%edx
80103e29:	a1 04 19 11 80       	mov    0x80111904,%eax
80103e2e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e34:	05 20 13 11 80       	add    $0x80111320,%eax
80103e39:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e3b:	a1 04 19 11 80       	mov    0x80111904,%eax
80103e40:	83 c0 01             	add    $0x1,%eax
80103e43:	a3 04 19 11 80       	mov    %eax,0x80111904
      p += sizeof(struct mpproc);
80103e48:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e4c:	eb 42                	jmp    80103e90 <mpinit+0x177>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e51:	89 45 e8             	mov    %eax,-0x18(%ebp)
      ioapicid = ioapic->apicno;
80103e54:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e57:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e5b:	a2 08 19 11 80       	mov    %al,0x80111908
      p += sizeof(struct mpioapic);
80103e60:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e64:	eb 2a                	jmp    80103e90 <mpinit+0x177>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e66:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e6a:	eb 24                	jmp    80103e90 <mpinit+0x177>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e6f:	0f b6 00             	movzbl (%eax),%eax
80103e72:	0f b6 c0             	movzbl %al,%eax
80103e75:	83 ec 08             	sub    $0x8,%esp
80103e78:	50                   	push   %eax
80103e79:	68 3c 89 10 80       	push   $0x8010893c
80103e7e:	e8 43 c5 ff ff       	call   801003c6 <cprintf>
80103e83:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103e86:	c7 05 00 19 11 80 00 	movl   $0x0,0x80111900
80103e8d:	00 00 00 
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e93:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e96:	0f 82 de fe ff ff    	jb     80103d7a <mpinit+0x61>
    }
  }
  if(!ismp){
80103e9c:	a1 00 19 11 80       	mov    0x80111900,%eax
80103ea1:	85 c0                	test   %eax,%eax
80103ea3:	75 1d                	jne    80103ec2 <mpinit+0x1a9>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103ea5:	c7 05 04 19 11 80 01 	movl   $0x1,0x80111904
80103eac:	00 00 00 
    lapic = 0;
80103eaf:	c7 05 20 12 11 80 00 	movl   $0x0,0x80111220
80103eb6:	00 00 00 
    ioapicid = 0;
80103eb9:	c6 05 08 19 11 80 00 	movb   $0x0,0x80111908
    return;
80103ec0:	eb 3e                	jmp    80103f00 <mpinit+0x1e7>
  }

  if(mp->imcrp){
80103ec2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ec5:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103ec9:	84 c0                	test   %al,%al
80103ecb:	74 33                	je     80103f00 <mpinit+0x1e7>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103ecd:	83 ec 08             	sub    $0x8,%esp
80103ed0:	6a 70                	push   $0x70
80103ed2:	6a 22                	push   $0x22
80103ed4:	e8 fc fb ff ff       	call   80103ad5 <outb>
80103ed9:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103edc:	83 ec 0c             	sub    $0xc,%esp
80103edf:	6a 23                	push   $0x23
80103ee1:	e8 d2 fb ff ff       	call   80103ab8 <inb>
80103ee6:	83 c4 10             	add    $0x10,%esp
80103ee9:	83 c8 01             	or     $0x1,%eax
80103eec:	0f b6 c0             	movzbl %al,%eax
80103eef:	83 ec 08             	sub    $0x8,%esp
80103ef2:	50                   	push   %eax
80103ef3:	6a 23                	push   $0x23
80103ef5:	e8 db fb ff ff       	call   80103ad5 <outb>
80103efa:	83 c4 10             	add    $0x10,%esp
80103efd:	eb 01                	jmp    80103f00 <mpinit+0x1e7>
    return;
80103eff:	90                   	nop
  }
}
80103f00:	c9                   	leave  
80103f01:	c3                   	ret    

80103f02 <outb>:
{
80103f02:	55                   	push   %ebp
80103f03:	89 e5                	mov    %esp,%ebp
80103f05:	83 ec 08             	sub    $0x8,%esp
80103f08:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0b:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f0e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103f12:	89 d0                	mov    %edx,%eax
80103f14:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f17:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f1b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f1f:	ee                   	out    %al,(%dx)
}
80103f20:	90                   	nop
80103f21:	c9                   	leave  
80103f22:	c3                   	ret    

80103f23 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f23:	55                   	push   %ebp
80103f24:	89 e5                	mov    %esp,%ebp
80103f26:	83 ec 04             	sub    $0x4,%esp
80103f29:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103f30:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f34:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103f3a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f3e:	0f b6 c0             	movzbl %al,%eax
80103f41:	50                   	push   %eax
80103f42:	6a 21                	push   $0x21
80103f44:	e8 b9 ff ff ff       	call   80103f02 <outb>
80103f49:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103f4c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f50:	66 c1 e8 08          	shr    $0x8,%ax
80103f54:	0f b6 c0             	movzbl %al,%eax
80103f57:	50                   	push   %eax
80103f58:	68 a1 00 00 00       	push   $0xa1
80103f5d:	e8 a0 ff ff ff       	call   80103f02 <outb>
80103f62:	83 c4 08             	add    $0x8,%esp
}
80103f65:	90                   	nop
80103f66:	c9                   	leave  
80103f67:	c3                   	ret    

80103f68 <picenable>:

void
picenable(int irq)
{
80103f68:	55                   	push   %ebp
80103f69:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6e:	ba 01 00 00 00       	mov    $0x1,%edx
80103f73:	89 c1                	mov    %eax,%ecx
80103f75:	d3 e2                	shl    %cl,%edx
80103f77:	89 d0                	mov    %edx,%eax
80103f79:	f7 d0                	not    %eax
80103f7b:	89 c2                	mov    %eax,%edx
80103f7d:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f84:	21 d0                	and    %edx,%eax
80103f86:	0f b7 c0             	movzwl %ax,%eax
80103f89:	50                   	push   %eax
80103f8a:	e8 94 ff ff ff       	call   80103f23 <picsetmask>
80103f8f:	83 c4 04             	add    $0x4,%esp
}
80103f92:	90                   	nop
80103f93:	c9                   	leave  
80103f94:	c3                   	ret    

80103f95 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f95:	55                   	push   %ebp
80103f96:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f98:	68 ff 00 00 00       	push   $0xff
80103f9d:	6a 21                	push   $0x21
80103f9f:	e8 5e ff ff ff       	call   80103f02 <outb>
80103fa4:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103fa7:	68 ff 00 00 00       	push   $0xff
80103fac:	68 a1 00 00 00       	push   $0xa1
80103fb1:	e8 4c ff ff ff       	call   80103f02 <outb>
80103fb6:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103fb9:	6a 11                	push   $0x11
80103fbb:	6a 20                	push   $0x20
80103fbd:	e8 40 ff ff ff       	call   80103f02 <outb>
80103fc2:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103fc5:	6a 20                	push   $0x20
80103fc7:	6a 21                	push   $0x21
80103fc9:	e8 34 ff ff ff       	call   80103f02 <outb>
80103fce:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103fd1:	6a 04                	push   $0x4
80103fd3:	6a 21                	push   $0x21
80103fd5:	e8 28 ff ff ff       	call   80103f02 <outb>
80103fda:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103fdd:	6a 03                	push   $0x3
80103fdf:	6a 21                	push   $0x21
80103fe1:	e8 1c ff ff ff       	call   80103f02 <outb>
80103fe6:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103fe9:	6a 11                	push   $0x11
80103feb:	68 a0 00 00 00       	push   $0xa0
80103ff0:	e8 0d ff ff ff       	call   80103f02 <outb>
80103ff5:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103ff8:	6a 28                	push   $0x28
80103ffa:	68 a1 00 00 00       	push   $0xa1
80103fff:	e8 fe fe ff ff       	call   80103f02 <outb>
80104004:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104007:	6a 02                	push   $0x2
80104009:	68 a1 00 00 00       	push   $0xa1
8010400e:	e8 ef fe ff ff       	call   80103f02 <outb>
80104013:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104016:	6a 03                	push   $0x3
80104018:	68 a1 00 00 00       	push   $0xa1
8010401d:	e8 e0 fe ff ff       	call   80103f02 <outb>
80104022:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104025:	6a 68                	push   $0x68
80104027:	6a 20                	push   $0x20
80104029:	e8 d4 fe ff ff       	call   80103f02 <outb>
8010402e:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104031:	6a 0a                	push   $0xa
80104033:	6a 20                	push   $0x20
80104035:	e8 c8 fe ff ff       	call   80103f02 <outb>
8010403a:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
8010403d:	6a 68                	push   $0x68
8010403f:	68 a0 00 00 00       	push   $0xa0
80104044:	e8 b9 fe ff ff       	call   80103f02 <outb>
80104049:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
8010404c:	6a 0a                	push   $0xa
8010404e:	68 a0 00 00 00       	push   $0xa0
80104053:	e8 aa fe ff ff       	call   80103f02 <outb>
80104058:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
8010405b:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104062:	66 83 f8 ff          	cmp    $0xffff,%ax
80104066:	74 13                	je     8010407b <picinit+0xe6>
    picsetmask(irqmask);
80104068:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
8010406f:	0f b7 c0             	movzwl %ax,%eax
80104072:	50                   	push   %eax
80104073:	e8 ab fe ff ff       	call   80103f23 <picsetmask>
80104078:	83 c4 04             	add    $0x4,%esp
}
8010407b:	90                   	nop
8010407c:	c9                   	leave  
8010407d:	c3                   	ret    

8010407e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010407e:	55                   	push   %ebp
8010407f:	89 e5                	mov    %esp,%ebp
80104081:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104084:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010408b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104094:	8b 45 0c             	mov    0xc(%ebp),%eax
80104097:	8b 10                	mov    (%eax),%edx
80104099:	8b 45 08             	mov    0x8(%ebp),%eax
8010409c:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010409e:	e8 1d cf ff ff       	call   80100fc0 <filealloc>
801040a3:	8b 55 08             	mov    0x8(%ebp),%edx
801040a6:	89 02                	mov    %eax,(%edx)
801040a8:	8b 45 08             	mov    0x8(%ebp),%eax
801040ab:	8b 00                	mov    (%eax),%eax
801040ad:	85 c0                	test   %eax,%eax
801040af:	0f 84 c8 00 00 00    	je     8010417d <pipealloc+0xff>
801040b5:	e8 06 cf ff ff       	call   80100fc0 <filealloc>
801040ba:	8b 55 0c             	mov    0xc(%ebp),%edx
801040bd:	89 02                	mov    %eax,(%edx)
801040bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c2:	8b 00                	mov    (%eax),%eax
801040c4:	85 c0                	test   %eax,%eax
801040c6:	0f 84 b1 00 00 00    	je     8010417d <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801040cc:	e8 b8 eb ff ff       	call   80102c89 <kalloc>
801040d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801040d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040d8:	0f 84 a2 00 00 00    	je     80104180 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801040de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e1:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040e8:	00 00 00 
  p->writeopen = 1;
801040eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ee:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040f5:	00 00 00 
  p->nwrite = 0;
801040f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fb:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104102:	00 00 00 
  p->nread = 0;
80104105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104108:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010410f:	00 00 00 
  initlock(&p->lock, "pipe");
80104112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104115:	83 ec 08             	sub    $0x8,%esp
80104118:	68 5c 89 10 80       	push   $0x8010895c
8010411d:	50                   	push   %eax
8010411e:	e8 3d 0f 00 00       	call   80105060 <initlock>
80104123:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104126:	8b 45 08             	mov    0x8(%ebp),%eax
80104129:	8b 00                	mov    (%eax),%eax
8010412b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104131:	8b 45 08             	mov    0x8(%ebp),%eax
80104134:	8b 00                	mov    (%eax),%eax
80104136:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010413a:	8b 45 08             	mov    0x8(%ebp),%eax
8010413d:	8b 00                	mov    (%eax),%eax
8010413f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104143:	8b 45 08             	mov    0x8(%ebp),%eax
80104146:	8b 00                	mov    (%eax),%eax
80104148:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010414b:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010414e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104151:	8b 00                	mov    (%eax),%eax
80104153:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104159:	8b 45 0c             	mov    0xc(%ebp),%eax
8010415c:	8b 00                	mov    (%eax),%eax
8010415e:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104162:	8b 45 0c             	mov    0xc(%ebp),%eax
80104165:	8b 00                	mov    (%eax),%eax
80104167:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010416b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010416e:	8b 00                	mov    (%eax),%eax
80104170:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104173:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104176:	b8 00 00 00 00       	mov    $0x0,%eax
8010417b:	eb 51                	jmp    801041ce <pipealloc+0x150>
    goto bad;
8010417d:	90                   	nop
8010417e:	eb 01                	jmp    80104181 <pipealloc+0x103>
    goto bad;
80104180:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80104181:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104185:	74 0e                	je     80104195 <pipealloc+0x117>
    kfree((char*)p);
80104187:	83 ec 0c             	sub    $0xc,%esp
8010418a:	ff 75 f4             	pushl  -0xc(%ebp)
8010418d:	e8 5a ea ff ff       	call   80102bec <kfree>
80104192:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104195:	8b 45 08             	mov    0x8(%ebp),%eax
80104198:	8b 00                	mov    (%eax),%eax
8010419a:	85 c0                	test   %eax,%eax
8010419c:	74 11                	je     801041af <pipealloc+0x131>
    fileclose(*f0);
8010419e:	8b 45 08             	mov    0x8(%ebp),%eax
801041a1:	8b 00                	mov    (%eax),%eax
801041a3:	83 ec 0c             	sub    $0xc,%esp
801041a6:	50                   	push   %eax
801041a7:	e8 d2 ce ff ff       	call   8010107e <fileclose>
801041ac:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801041af:	8b 45 0c             	mov    0xc(%ebp),%eax
801041b2:	8b 00                	mov    (%eax),%eax
801041b4:	85 c0                	test   %eax,%eax
801041b6:	74 11                	je     801041c9 <pipealloc+0x14b>
    fileclose(*f1);
801041b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801041bb:	8b 00                	mov    (%eax),%eax
801041bd:	83 ec 0c             	sub    $0xc,%esp
801041c0:	50                   	push   %eax
801041c1:	e8 b8 ce ff ff       	call   8010107e <fileclose>
801041c6:	83 c4 10             	add    $0x10,%esp
  return -1;
801041c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041ce:	c9                   	leave  
801041cf:	c3                   	ret    

801041d0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801041d0:	55                   	push   %ebp
801041d1:	89 e5                	mov    %esp,%ebp
801041d3:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801041d6:	8b 45 08             	mov    0x8(%ebp),%eax
801041d9:	83 ec 0c             	sub    $0xc,%esp
801041dc:	50                   	push   %eax
801041dd:	e8 a0 0e 00 00       	call   80105082 <acquire>
801041e2:	83 c4 10             	add    $0x10,%esp
  if(writable){
801041e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041e9:	74 23                	je     8010420e <pipeclose+0x3e>
    p->writeopen = 0;
801041eb:	8b 45 08             	mov    0x8(%ebp),%eax
801041ee:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041f5:	00 00 00 
    wakeup(&p->nread);
801041f8:	8b 45 08             	mov    0x8(%ebp),%eax
801041fb:	05 34 02 00 00       	add    $0x234,%eax
80104200:	83 ec 0c             	sub    $0xc,%esp
80104203:	50                   	push   %eax
80104204:	e8 6a 0c 00 00       	call   80104e73 <wakeup>
80104209:	83 c4 10             	add    $0x10,%esp
8010420c:	eb 21                	jmp    8010422f <pipeclose+0x5f>
  } else {
    p->readopen = 0;
8010420e:	8b 45 08             	mov    0x8(%ebp),%eax
80104211:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104218:	00 00 00 
    wakeup(&p->nwrite);
8010421b:	8b 45 08             	mov    0x8(%ebp),%eax
8010421e:	05 38 02 00 00       	add    $0x238,%eax
80104223:	83 ec 0c             	sub    $0xc,%esp
80104226:	50                   	push   %eax
80104227:	e8 47 0c 00 00       	call   80104e73 <wakeup>
8010422c:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010422f:	8b 45 08             	mov    0x8(%ebp),%eax
80104232:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104238:	85 c0                	test   %eax,%eax
8010423a:	75 2c                	jne    80104268 <pipeclose+0x98>
8010423c:	8b 45 08             	mov    0x8(%ebp),%eax
8010423f:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104245:	85 c0                	test   %eax,%eax
80104247:	75 1f                	jne    80104268 <pipeclose+0x98>
    release(&p->lock);
80104249:	8b 45 08             	mov    0x8(%ebp),%eax
8010424c:	83 ec 0c             	sub    $0xc,%esp
8010424f:	50                   	push   %eax
80104250:	e8 94 0e 00 00       	call   801050e9 <release>
80104255:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104258:	83 ec 0c             	sub    $0xc,%esp
8010425b:	ff 75 08             	pushl  0x8(%ebp)
8010425e:	e8 89 e9 ff ff       	call   80102bec <kfree>
80104263:	83 c4 10             	add    $0x10,%esp
80104266:	eb 10                	jmp    80104278 <pipeclose+0xa8>
  } else
    release(&p->lock);
80104268:	8b 45 08             	mov    0x8(%ebp),%eax
8010426b:	83 ec 0c             	sub    $0xc,%esp
8010426e:	50                   	push   %eax
8010426f:	e8 75 0e 00 00       	call   801050e9 <release>
80104274:	83 c4 10             	add    $0x10,%esp
}
80104277:	90                   	nop
80104278:	90                   	nop
80104279:	c9                   	leave  
8010427a:	c3                   	ret    

8010427b <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010427b:	55                   	push   %ebp
8010427c:	89 e5                	mov    %esp,%ebp
8010427e:	53                   	push   %ebx
8010427f:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104282:	8b 45 08             	mov    0x8(%ebp),%eax
80104285:	83 ec 0c             	sub    $0xc,%esp
80104288:	50                   	push   %eax
80104289:	e8 f4 0d 00 00       	call   80105082 <acquire>
8010428e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104291:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104298:	e9 ae 00 00 00       	jmp    8010434b <pipewrite+0xd0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010429d:	8b 45 08             	mov    0x8(%ebp),%eax
801042a0:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042a6:	85 c0                	test   %eax,%eax
801042a8:	74 0d                	je     801042b7 <pipewrite+0x3c>
801042aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042b0:	8b 40 24             	mov    0x24(%eax),%eax
801042b3:	85 c0                	test   %eax,%eax
801042b5:	74 19                	je     801042d0 <pipewrite+0x55>
        release(&p->lock);
801042b7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ba:	83 ec 0c             	sub    $0xc,%esp
801042bd:	50                   	push   %eax
801042be:	e8 26 0e 00 00       	call   801050e9 <release>
801042c3:	83 c4 10             	add    $0x10,%esp
        return -1;
801042c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042cb:	e9 a9 00 00 00       	jmp    80104379 <pipewrite+0xfe>
      }
      wakeup(&p->nread);
801042d0:	8b 45 08             	mov    0x8(%ebp),%eax
801042d3:	05 34 02 00 00       	add    $0x234,%eax
801042d8:	83 ec 0c             	sub    $0xc,%esp
801042db:	50                   	push   %eax
801042dc:	e8 92 0b 00 00       	call   80104e73 <wakeup>
801042e1:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042e4:	8b 45 08             	mov    0x8(%ebp),%eax
801042e7:	8b 55 08             	mov    0x8(%ebp),%edx
801042ea:	81 c2 38 02 00 00    	add    $0x238,%edx
801042f0:	83 ec 08             	sub    $0x8,%esp
801042f3:	50                   	push   %eax
801042f4:	52                   	push   %edx
801042f5:	e8 8d 0a 00 00       	call   80104d87 <sleep>
801042fa:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104300:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104306:	8b 45 08             	mov    0x8(%ebp),%eax
80104309:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010430f:	05 00 02 00 00       	add    $0x200,%eax
80104314:	39 c2                	cmp    %eax,%edx
80104316:	74 85                	je     8010429d <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104318:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010431b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010431e:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104321:	8b 45 08             	mov    0x8(%ebp),%eax
80104324:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010432a:	8d 48 01             	lea    0x1(%eax),%ecx
8010432d:	8b 55 08             	mov    0x8(%ebp),%edx
80104330:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104336:	25 ff 01 00 00       	and    $0x1ff,%eax
8010433b:	89 c1                	mov    %eax,%ecx
8010433d:	0f b6 13             	movzbl (%ebx),%edx
80104340:	8b 45 08             	mov    0x8(%ebp),%eax
80104343:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80104347:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010434b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104351:	7c aa                	jl     801042fd <pipewrite+0x82>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104353:	8b 45 08             	mov    0x8(%ebp),%eax
80104356:	05 34 02 00 00       	add    $0x234,%eax
8010435b:	83 ec 0c             	sub    $0xc,%esp
8010435e:	50                   	push   %eax
8010435f:	e8 0f 0b 00 00       	call   80104e73 <wakeup>
80104364:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104367:	8b 45 08             	mov    0x8(%ebp),%eax
8010436a:	83 ec 0c             	sub    $0xc,%esp
8010436d:	50                   	push   %eax
8010436e:	e8 76 0d 00 00       	call   801050e9 <release>
80104373:	83 c4 10             	add    $0x10,%esp
  return n;
80104376:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010437c:	c9                   	leave  
8010437d:	c3                   	ret    

8010437e <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010437e:	55                   	push   %ebp
8010437f:	89 e5                	mov    %esp,%ebp
80104381:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104384:	8b 45 08             	mov    0x8(%ebp),%eax
80104387:	83 ec 0c             	sub    $0xc,%esp
8010438a:	50                   	push   %eax
8010438b:	e8 f2 0c 00 00       	call   80105082 <acquire>
80104390:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104393:	eb 3f                	jmp    801043d4 <piperead+0x56>
    if(proc->killed){
80104395:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010439b:	8b 40 24             	mov    0x24(%eax),%eax
8010439e:	85 c0                	test   %eax,%eax
801043a0:	74 19                	je     801043bb <piperead+0x3d>
      release(&p->lock);
801043a2:	8b 45 08             	mov    0x8(%ebp),%eax
801043a5:	83 ec 0c             	sub    $0xc,%esp
801043a8:	50                   	push   %eax
801043a9:	e8 3b 0d 00 00       	call   801050e9 <release>
801043ae:	83 c4 10             	add    $0x10,%esp
      return -1;
801043b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043b6:	e9 be 00 00 00       	jmp    80104479 <piperead+0xfb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801043bb:	8b 45 08             	mov    0x8(%ebp),%eax
801043be:	8b 55 08             	mov    0x8(%ebp),%edx
801043c1:	81 c2 34 02 00 00    	add    $0x234,%edx
801043c7:	83 ec 08             	sub    $0x8,%esp
801043ca:	50                   	push   %eax
801043cb:	52                   	push   %edx
801043cc:	e8 b6 09 00 00       	call   80104d87 <sleep>
801043d1:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043d4:	8b 45 08             	mov    0x8(%ebp),%eax
801043d7:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043dd:	8b 45 08             	mov    0x8(%ebp),%eax
801043e0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043e6:	39 c2                	cmp    %eax,%edx
801043e8:	75 0d                	jne    801043f7 <piperead+0x79>
801043ea:	8b 45 08             	mov    0x8(%ebp),%eax
801043ed:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043f3:	85 c0                	test   %eax,%eax
801043f5:	75 9e                	jne    80104395 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043fe:	eb 48                	jmp    80104448 <piperead+0xca>
    if(p->nread == p->nwrite)
80104400:	8b 45 08             	mov    0x8(%ebp),%eax
80104403:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104409:	8b 45 08             	mov    0x8(%ebp),%eax
8010440c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104412:	39 c2                	cmp    %eax,%edx
80104414:	74 3c                	je     80104452 <piperead+0xd4>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104416:	8b 45 08             	mov    0x8(%ebp),%eax
80104419:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010441f:	8d 48 01             	lea    0x1(%eax),%ecx
80104422:	8b 55 08             	mov    0x8(%ebp),%edx
80104425:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010442b:	25 ff 01 00 00       	and    $0x1ff,%eax
80104430:	89 c1                	mov    %eax,%ecx
80104432:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104435:	8b 45 0c             	mov    0xc(%ebp),%eax
80104438:	01 c2                	add    %eax,%edx
8010443a:	8b 45 08             	mov    0x8(%ebp),%eax
8010443d:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104442:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104444:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010444e:	7c b0                	jl     80104400 <piperead+0x82>
80104450:	eb 01                	jmp    80104453 <piperead+0xd5>
      break;
80104452:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104453:	8b 45 08             	mov    0x8(%ebp),%eax
80104456:	05 38 02 00 00       	add    $0x238,%eax
8010445b:	83 ec 0c             	sub    $0xc,%esp
8010445e:	50                   	push   %eax
8010445f:	e8 0f 0a 00 00       	call   80104e73 <wakeup>
80104464:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104467:	8b 45 08             	mov    0x8(%ebp),%eax
8010446a:	83 ec 0c             	sub    $0xc,%esp
8010446d:	50                   	push   %eax
8010446e:	e8 76 0c 00 00       	call   801050e9 <release>
80104473:	83 c4 10             	add    $0x10,%esp
  return i;
80104476:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104479:	c9                   	leave  
8010447a:	c3                   	ret    

8010447b <readeflags>:
{
8010447b:	55                   	push   %ebp
8010447c:	89 e5                	mov    %esp,%ebp
8010447e:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104481:	9c                   	pushf  
80104482:	58                   	pop    %eax
80104483:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104486:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104489:	c9                   	leave  
8010448a:	c3                   	ret    

8010448b <sti>:
{
8010448b:	55                   	push   %ebp
8010448c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010448e:	fb                   	sti    
}
8010448f:	90                   	nop
80104490:	5d                   	pop    %ebp
80104491:	c3                   	ret    

80104492 <halt>:
}

// CS550: to solve the 100%-CPU-utilization-when-idling problem - "hlt" instruction puts CPU to sleep
static inline void
halt()
{
80104492:	55                   	push   %ebp
80104493:	89 e5                	mov    %esp,%ebp
    asm volatile("hlt" : : :"memory");
80104495:	f4                   	hlt    
}
80104496:	90                   	nop
80104497:	5d                   	pop    %ebp
80104498:	c3                   	ret    

80104499 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104499:	55                   	push   %ebp
8010449a:	89 e5                	mov    %esp,%ebp
8010449c:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010449f:	83 ec 08             	sub    $0x8,%esp
801044a2:	68 61 89 10 80       	push   $0x80108961
801044a7:	68 20 19 11 80       	push   $0x80111920
801044ac:	e8 af 0b 00 00       	call   80105060 <initlock>
801044b1:	83 c4 10             	add    $0x10,%esp
}
801044b4:	90                   	nop
801044b5:	c9                   	leave  
801044b6:	c3                   	ret    

801044b7 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801044b7:	55                   	push   %ebp
801044b8:	89 e5                	mov    %esp,%ebp
801044ba:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044bd:	83 ec 0c             	sub    $0xc,%esp
801044c0:	68 20 19 11 80       	push   $0x80111920
801044c5:	e8 b8 0b 00 00       	call   80105082 <acquire>
801044ca:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044cd:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
801044d4:	eb 0e                	jmp    801044e4 <allocproc+0x2d>
    if(p->state == UNUSED)
801044d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d9:	8b 40 0c             	mov    0xc(%eax),%eax
801044dc:	85 c0                	test   %eax,%eax
801044de:	74 27                	je     80104507 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044e0:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801044e4:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
801044eb:	72 e9                	jb     801044d6 <allocproc+0x1f>
      goto found;
  release(&ptable.lock);
801044ed:	83 ec 0c             	sub    $0xc,%esp
801044f0:	68 20 19 11 80       	push   $0x80111920
801044f5:	e8 ef 0b 00 00       	call   801050e9 <release>
801044fa:	83 c4 10             	add    $0x10,%esp
  return 0;
801044fd:	b8 00 00 00 00       	mov    $0x0,%eax
80104502:	e9 b2 00 00 00       	jmp    801045b9 <allocproc+0x102>
      goto found;
80104507:	90                   	nop

found:
  p->state = EMBRYO;
80104508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450b:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104512:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104517:	8d 50 01             	lea    0x1(%eax),%edx
8010451a:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
80104520:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104523:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104526:	83 ec 0c             	sub    $0xc,%esp
80104529:	68 20 19 11 80       	push   $0x80111920
8010452e:	e8 b6 0b 00 00       	call   801050e9 <release>
80104533:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104536:	e8 4e e7 ff ff       	call   80102c89 <kalloc>
8010453b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010453e:	89 42 08             	mov    %eax,0x8(%edx)
80104541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104544:	8b 40 08             	mov    0x8(%eax),%eax
80104547:	85 c0                	test   %eax,%eax
80104549:	75 11                	jne    8010455c <allocproc+0xa5>
    p->state = UNUSED;
8010454b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104555:	b8 00 00 00 00       	mov    $0x0,%eax
8010455a:	eb 5d                	jmp    801045b9 <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
8010455c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455f:	8b 40 08             	mov    0x8(%eax),%eax
80104562:	05 00 10 00 00       	add    $0x1000,%eax
80104567:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010456a:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010456e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104571:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104574:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104577:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010457b:	ba 43 67 10 80       	mov    $0x80106743,%edx
80104580:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104583:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104585:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010458f:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104592:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104595:	8b 40 1c             	mov    0x1c(%eax),%eax
80104598:	83 ec 04             	sub    $0x4,%esp
8010459b:	6a 14                	push   $0x14
8010459d:	6a 00                	push   $0x0
8010459f:	50                   	push   %eax
801045a0:	e8 40 0d 00 00       	call   801052e5 <memset>
801045a5:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801045a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ab:	8b 40 1c             	mov    0x1c(%eax),%eax
801045ae:	ba 41 4d 10 80       	mov    $0x80104d41,%edx
801045b3:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801045b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045b9:	c9                   	leave  
801045ba:	c3                   	ret    

801045bb <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045bb:	55                   	push   %ebp
801045bc:	89 e5                	mov    %esp,%ebp
801045be:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801045c1:	e8 f1 fe ff ff       	call   801044b7 <allocproc>
801045c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801045c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045cc:	a3 58 38 11 80       	mov    %eax,0x80113858
  if((p->pgdir = setupkvm()) == 0)
801045d1:	e8 35 38 00 00       	call   80107e0b <setupkvm>
801045d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d9:	89 42 04             	mov    %eax,0x4(%edx)
801045dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045df:	8b 40 04             	mov    0x4(%eax),%eax
801045e2:	85 c0                	test   %eax,%eax
801045e4:	75 0d                	jne    801045f3 <userinit+0x38>
    panic("userinit: out of memory?");
801045e6:	83 ec 0c             	sub    $0xc,%esp
801045e9:	68 68 89 10 80       	push   $0x80108968
801045ee:	e8 88 bf ff ff       	call   8010057b <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045f3:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fb:	8b 40 04             	mov    0x4(%eax),%eax
801045fe:	83 ec 04             	sub    $0x4,%esp
80104601:	52                   	push   %edx
80104602:	68 e0 b4 10 80       	push   $0x8010b4e0
80104607:	50                   	push   %eax
80104608:	e8 59 3a 00 00       	call   80108066 <inituvm>
8010460d:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104613:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461c:	8b 40 18             	mov    0x18(%eax),%eax
8010461f:	83 ec 04             	sub    $0x4,%esp
80104622:	6a 4c                	push   $0x4c
80104624:	6a 00                	push   $0x0
80104626:	50                   	push   %eax
80104627:	e8 b9 0c 00 00       	call   801052e5 <memset>
8010462c:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010462f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104632:	8b 40 18             	mov    0x18(%eax),%eax
80104635:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010463b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463e:	8b 40 18             	mov    0x18(%eax),%eax
80104641:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464a:	8b 50 18             	mov    0x18(%eax),%edx
8010464d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104650:	8b 40 18             	mov    0x18(%eax),%eax
80104653:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104657:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010465b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465e:	8b 50 18             	mov    0x18(%eax),%edx
80104661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104664:	8b 40 18             	mov    0x18(%eax),%eax
80104667:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010466b:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010466f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104672:	8b 40 18             	mov    0x18(%eax),%eax
80104675:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010467c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467f:	8b 40 18             	mov    0x18(%eax),%eax
80104682:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468c:	8b 40 18             	mov    0x18(%eax),%eax
8010468f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104699:	83 c0 6c             	add    $0x6c,%eax
8010469c:	83 ec 04             	sub    $0x4,%esp
8010469f:	6a 10                	push   $0x10
801046a1:	68 81 89 10 80       	push   $0x80108981
801046a6:	50                   	push   %eax
801046a7:	e8 3c 0e 00 00       	call   801054e8 <safestrcpy>
801046ac:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801046af:	83 ec 0c             	sub    $0xc,%esp
801046b2:	68 8a 89 10 80       	push   $0x8010898a
801046b7:	e8 8c de ff ff       	call   80102548 <namei>
801046bc:	83 c4 10             	add    $0x10,%esp
801046bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046c2:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801046c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801046cf:	90                   	nop
801046d0:	c9                   	leave  
801046d1:	c3                   	ret    

801046d2 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046d2:	55                   	push   %ebp
801046d3:	89 e5                	mov    %esp,%ebp
801046d5:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801046d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046de:	8b 00                	mov    (%eax),%eax
801046e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046e7:	7e 31                	jle    8010471a <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046e9:	8b 55 08             	mov    0x8(%ebp),%edx
801046ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ef:	01 c2                	add    %eax,%edx
801046f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046f7:	8b 40 04             	mov    0x4(%eax),%eax
801046fa:	83 ec 04             	sub    $0x4,%esp
801046fd:	52                   	push   %edx
801046fe:	ff 75 f4             	pushl  -0xc(%ebp)
80104701:	50                   	push   %eax
80104702:	e8 ac 3a 00 00       	call   801081b3 <allocuvm>
80104707:	83 c4 10             	add    $0x10,%esp
8010470a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010470d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104711:	75 3e                	jne    80104751 <growproc+0x7f>
      return -1;
80104713:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104718:	eb 59                	jmp    80104773 <growproc+0xa1>
  } else if(n < 0){
8010471a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010471e:	79 31                	jns    80104751 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104720:	8b 55 08             	mov    0x8(%ebp),%edx
80104723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104726:	01 c2                	add    %eax,%edx
80104728:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472e:	8b 40 04             	mov    0x4(%eax),%eax
80104731:	83 ec 04             	sub    $0x4,%esp
80104734:	52                   	push   %edx
80104735:	ff 75 f4             	pushl  -0xc(%ebp)
80104738:	50                   	push   %eax
80104739:	e8 3c 3b 00 00       	call   8010827a <deallocuvm>
8010473e:	83 c4 10             	add    $0x10,%esp
80104741:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104744:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104748:	75 07                	jne    80104751 <growproc+0x7f>
      return -1;
8010474a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010474f:	eb 22                	jmp    80104773 <growproc+0xa1>
  }
  proc->sz = sz;
80104751:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104757:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010475a:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010475c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104762:	83 ec 0c             	sub    $0xc,%esp
80104765:	50                   	push   %eax
80104766:	e8 87 37 00 00       	call   80107ef2 <switchuvm>
8010476b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010476e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104773:	c9                   	leave  
80104774:	c3                   	ret    

80104775 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104775:	55                   	push   %ebp
80104776:	89 e5                	mov    %esp,%ebp
80104778:	57                   	push   %edi
80104779:	56                   	push   %esi
8010477a:	53                   	push   %ebx
8010477b:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010477e:	e8 34 fd ff ff       	call   801044b7 <allocproc>
80104783:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104786:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010478a:	75 0a                	jne    80104796 <fork+0x21>
    return -1;
8010478c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104791:	e9 64 01 00 00       	jmp    801048fa <fork+0x185>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104796:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010479c:	8b 10                	mov    (%eax),%edx
8010479e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047a4:	8b 40 04             	mov    0x4(%eax),%eax
801047a7:	83 ec 08             	sub    $0x8,%esp
801047aa:	52                   	push   %edx
801047ab:	50                   	push   %eax
801047ac:	e8 67 3c 00 00       	call   80108418 <copyuvm>
801047b1:	83 c4 10             	add    $0x10,%esp
801047b4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801047b7:	89 42 04             	mov    %eax,0x4(%edx)
801047ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047bd:	8b 40 04             	mov    0x4(%eax),%eax
801047c0:	85 c0                	test   %eax,%eax
801047c2:	75 30                	jne    801047f4 <fork+0x7f>
    kfree(np->kstack);
801047c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c7:	8b 40 08             	mov    0x8(%eax),%eax
801047ca:	83 ec 0c             	sub    $0xc,%esp
801047cd:	50                   	push   %eax
801047ce:	e8 19 e4 ff ff       	call   80102bec <kfree>
801047d3:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801047d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047ef:	e9 06 01 00 00       	jmp    801048fa <fork+0x185>
  }
  np->sz = proc->sz;
801047f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047fa:	8b 10                	mov    (%eax),%edx
801047fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ff:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104801:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104808:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010480b:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
8010480e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104814:	8b 48 18             	mov    0x18(%eax),%ecx
80104817:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010481a:	8b 40 18             	mov    0x18(%eax),%eax
8010481d:	89 c2                	mov    %eax,%edx
8010481f:	89 cb                	mov    %ecx,%ebx
80104821:	b8 13 00 00 00       	mov    $0x13,%eax
80104826:	89 d7                	mov    %edx,%edi
80104828:	89 de                	mov    %ebx,%esi
8010482a:	89 c1                	mov    %eax,%ecx
8010482c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010482e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104831:	8b 40 18             	mov    0x18(%eax),%eax
80104834:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010483b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104842:	eb 41                	jmp    80104885 <fork+0x110>
    if(proc->ofile[i])
80104844:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010484a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010484d:	83 c2 08             	add    $0x8,%edx
80104850:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104854:	85 c0                	test   %eax,%eax
80104856:	74 29                	je     80104881 <fork+0x10c>
      np->ofile[i] = filedup(proc->ofile[i]);
80104858:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010485e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104861:	83 c2 08             	add    $0x8,%edx
80104864:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104868:	83 ec 0c             	sub    $0xc,%esp
8010486b:	50                   	push   %eax
8010486c:	e8 bc c7 ff ff       	call   8010102d <filedup>
80104871:	83 c4 10             	add    $0x10,%esp
80104874:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104877:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010487a:	83 c1 08             	add    $0x8,%ecx
8010487d:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104881:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104885:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104889:	7e b9                	jle    80104844 <fork+0xcf>
  np->cwd = idup(proc->cwd);
8010488b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104891:	8b 40 68             	mov    0x68(%eax),%eax
80104894:	83 ec 0c             	sub    $0xc,%esp
80104897:	50                   	push   %eax
80104898:	e8 c0 d0 ff ff       	call   8010195d <idup>
8010489d:	83 c4 10             	add    $0x10,%esp
801048a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048a3:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801048a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ac:	8d 50 6c             	lea    0x6c(%eax),%edx
801048af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048b2:	83 c0 6c             	add    $0x6c,%eax
801048b5:	83 ec 04             	sub    $0x4,%esp
801048b8:	6a 10                	push   $0x10
801048ba:	52                   	push   %edx
801048bb:	50                   	push   %eax
801048bc:	e8 27 0c 00 00       	call   801054e8 <safestrcpy>
801048c1:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801048c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048c7:	8b 40 10             	mov    0x10(%eax),%eax
801048ca:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048cd:	83 ec 0c             	sub    $0xc,%esp
801048d0:	68 20 19 11 80       	push   $0x80111920
801048d5:	e8 a8 07 00 00       	call   80105082 <acquire>
801048da:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801048dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801048e7:	83 ec 0c             	sub    $0xc,%esp
801048ea:	68 20 19 11 80       	push   $0x80111920
801048ef:	e8 f5 07 00 00       	call   801050e9 <release>
801048f4:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801048f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048fd:	5b                   	pop    %ebx
801048fe:	5e                   	pop    %esi
801048ff:	5f                   	pop    %edi
80104900:	5d                   	pop    %ebp
80104901:	c3                   	ret    

80104902 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104902:	55                   	push   %ebp
80104903:	89 e5                	mov    %esp,%ebp
80104905:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104908:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010490f:	a1 58 38 11 80       	mov    0x80113858,%eax
80104914:	39 c2                	cmp    %eax,%edx
80104916:	75 0d                	jne    80104925 <exit+0x23>
    panic("init exiting");
80104918:	83 ec 0c             	sub    $0xc,%esp
8010491b:	68 8c 89 10 80       	push   $0x8010898c
80104920:	e8 56 bc ff ff       	call   8010057b <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104925:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010492c:	eb 48                	jmp    80104976 <exit+0x74>
    if(proc->ofile[fd]){
8010492e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104934:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104937:	83 c2 08             	add    $0x8,%edx
8010493a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010493e:	85 c0                	test   %eax,%eax
80104940:	74 30                	je     80104972 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104942:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104948:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010494b:	83 c2 08             	add    $0x8,%edx
8010494e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104952:	83 ec 0c             	sub    $0xc,%esp
80104955:	50                   	push   %eax
80104956:	e8 23 c7 ff ff       	call   8010107e <fileclose>
8010495b:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
8010495e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104964:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104967:	83 c2 08             	add    $0x8,%edx
8010496a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104971:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104972:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104976:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010497a:	7e b2                	jle    8010492e <exit+0x2c>
    }
  }

  begin_op();
8010497c:	e8 eb eb ff ff       	call   8010356c <begin_op>
  iput(proc->cwd);
80104981:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104987:	8b 40 68             	mov    0x68(%eax),%eax
8010498a:	83 ec 0c             	sub    $0xc,%esp
8010498d:	50                   	push   %eax
8010498e:	e8 d4 d1 ff ff       	call   80101b67 <iput>
80104993:	83 c4 10             	add    $0x10,%esp
  end_op();
80104996:	e8 5d ec ff ff       	call   801035f8 <end_op>
  proc->cwd = 0;
8010499b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a1:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801049a8:	83 ec 0c             	sub    $0xc,%esp
801049ab:	68 20 19 11 80       	push   $0x80111920
801049b0:	e8 cd 06 00 00       	call   80105082 <acquire>
801049b5:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801049b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049be:	8b 40 14             	mov    0x14(%eax),%eax
801049c1:	83 ec 0c             	sub    $0xc,%esp
801049c4:	50                   	push   %eax
801049c5:	e8 69 04 00 00       	call   80104e33 <wakeup1>
801049ca:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049cd:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
801049d4:	eb 3c                	jmp    80104a12 <exit+0x110>
    if(p->parent == proc){
801049d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d9:	8b 50 14             	mov    0x14(%eax),%edx
801049dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049e2:	39 c2                	cmp    %eax,%edx
801049e4:	75 28                	jne    80104a0e <exit+0x10c>
      p->parent = initproc;
801049e6:	8b 15 58 38 11 80    	mov    0x80113858,%edx
801049ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ef:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f5:	8b 40 0c             	mov    0xc(%eax),%eax
801049f8:	83 f8 05             	cmp    $0x5,%eax
801049fb:	75 11                	jne    80104a0e <exit+0x10c>
        wakeup1(initproc);
801049fd:	a1 58 38 11 80       	mov    0x80113858,%eax
80104a02:	83 ec 0c             	sub    $0xc,%esp
80104a05:	50                   	push   %eax
80104a06:	e8 28 04 00 00       	call   80104e33 <wakeup1>
80104a0b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a0e:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a12:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
80104a19:	72 bb                	jb     801049d6 <exit+0xd4>
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104a1b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a21:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a28:	e8 fa 01 00 00       	call   80104c27 <sched>
  panic("zombie exit");
80104a2d:	83 ec 0c             	sub    $0xc,%esp
80104a30:	68 99 89 10 80       	push   $0x80108999
80104a35:	e8 41 bb ff ff       	call   8010057b <panic>

80104a3a <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a3a:	55                   	push   %ebp
80104a3b:	89 e5                	mov    %esp,%ebp
80104a3d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a40:	83 ec 0c             	sub    $0xc,%esp
80104a43:	68 20 19 11 80       	push   $0x80111920
80104a48:	e8 35 06 00 00       	call   80105082 <acquire>
80104a4d:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a50:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a57:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
80104a5e:	e9 a6 00 00 00       	jmp    80104b09 <wait+0xcf>
      if(p->parent != proc)
80104a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a66:	8b 50 14             	mov    0x14(%eax),%edx
80104a69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a6f:	39 c2                	cmp    %eax,%edx
80104a71:	0f 85 8d 00 00 00    	jne    80104b04 <wait+0xca>
        continue;
      havekids = 1;
80104a77:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a81:	8b 40 0c             	mov    0xc(%eax),%eax
80104a84:	83 f8 05             	cmp    $0x5,%eax
80104a87:	75 7c                	jne    80104b05 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8c:	8b 40 10             	mov    0x10(%eax),%eax
80104a8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a95:	8b 40 08             	mov    0x8(%eax),%eax
80104a98:	83 ec 0c             	sub    $0xc,%esp
80104a9b:	50                   	push   %eax
80104a9c:	e8 4b e1 ff ff       	call   80102bec <kfree>
80104aa1:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab1:	8b 40 04             	mov    0x4(%eax),%eax
80104ab4:	83 ec 0c             	sub    $0xc,%esp
80104ab7:	50                   	push   %eax
80104ab8:	e8 7a 38 00 00       	call   80108337 <freevm>
80104abd:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104acd:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae1:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae8:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104aef:	83 ec 0c             	sub    $0xc,%esp
80104af2:	68 20 19 11 80       	push   $0x80111920
80104af7:	e8 ed 05 00 00       	call   801050e9 <release>
80104afc:	83 c4 10             	add    $0x10,%esp
        return pid;
80104aff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b02:	eb 58                	jmp    80104b5c <wait+0x122>
        continue;
80104b04:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b05:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b09:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
80104b10:	0f 82 4d ff ff ff    	jb     80104a63 <wait+0x29>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b1a:	74 0d                	je     80104b29 <wait+0xef>
80104b1c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b22:	8b 40 24             	mov    0x24(%eax),%eax
80104b25:	85 c0                	test   %eax,%eax
80104b27:	74 17                	je     80104b40 <wait+0x106>
      release(&ptable.lock);
80104b29:	83 ec 0c             	sub    $0xc,%esp
80104b2c:	68 20 19 11 80       	push   $0x80111920
80104b31:	e8 b3 05 00 00       	call   801050e9 <release>
80104b36:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b3e:	eb 1c                	jmp    80104b5c <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b40:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b46:	83 ec 08             	sub    $0x8,%esp
80104b49:	68 20 19 11 80       	push   $0x80111920
80104b4e:	50                   	push   %eax
80104b4f:	e8 33 02 00 00       	call   80104d87 <sleep>
80104b54:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104b57:	e9 f4 fe ff ff       	jmp    80104a50 <wait+0x16>
  }
}
80104b5c:	c9                   	leave  
80104b5d:	c3                   	ret    

80104b5e <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b5e:	55                   	push   %ebp
80104b5f:	89 e5                	mov    %esp,%ebp
80104b61:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int ran = 0; // CS550: to solve the 100%-CPU-utilization-when-idling problem
80104b64:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b6b:	e8 1b f9 ff ff       	call   8010448b <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b70:	83 ec 0c             	sub    $0xc,%esp
80104b73:	68 20 19 11 80       	push   $0x80111920
80104b78:	e8 05 05 00 00       	call   80105082 <acquire>
80104b7d:	83 c4 10             	add    $0x10,%esp
    ran = 0;
80104b80:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b87:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
80104b8e:	eb 6a                	jmp    80104bfa <scheduler+0x9c>
      if(p->state != RUNNABLE)
80104b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b93:	8b 40 0c             	mov    0xc(%eax),%eax
80104b96:	83 f8 03             	cmp    $0x3,%eax
80104b99:	75 5a                	jne    80104bf5 <scheduler+0x97>
        continue;

      ran = 1;
80104b9b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba5:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104bab:	83 ec 0c             	sub    $0xc,%esp
80104bae:	ff 75 f4             	pushl  -0xc(%ebp)
80104bb1:	e8 3c 33 00 00       	call   80107ef2 <switchuvm>
80104bb6:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbc:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104bc3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bc9:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bcc:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104bd3:	83 c2 04             	add    $0x4,%edx
80104bd6:	83 ec 08             	sub    $0x8,%esp
80104bd9:	50                   	push   %eax
80104bda:	52                   	push   %edx
80104bdb:	e8 79 09 00 00       	call   80105559 <swtch>
80104be0:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104be3:	e8 ed 32 00 00       	call   80107ed5 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104be8:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104bef:	00 00 00 00 
80104bf3:	eb 01                	jmp    80104bf6 <scheduler+0x98>
        continue;
80104bf5:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bf6:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104bfa:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
80104c01:	72 8d                	jb     80104b90 <scheduler+0x32>
    }
    release(&ptable.lock);
80104c03:	83 ec 0c             	sub    $0xc,%esp
80104c06:	68 20 19 11 80       	push   $0x80111920
80104c0b:	e8 d9 04 00 00       	call   801050e9 <release>
80104c10:	83 c4 10             	add    $0x10,%esp

    if (ran == 0){
80104c13:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c17:	0f 85 4e ff ff ff    	jne    80104b6b <scheduler+0xd>
        halt();
80104c1d:	e8 70 f8 ff ff       	call   80104492 <halt>
    sti();
80104c22:	e9 44 ff ff ff       	jmp    80104b6b <scheduler+0xd>

80104c27 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c27:	55                   	push   %ebp
80104c28:	89 e5                	mov    %esp,%ebp
80104c2a:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c2d:	83 ec 0c             	sub    $0xc,%esp
80104c30:	68 20 19 11 80       	push   $0x80111920
80104c35:	e8 7c 05 00 00       	call   801051b6 <holding>
80104c3a:	83 c4 10             	add    $0x10,%esp
80104c3d:	85 c0                	test   %eax,%eax
80104c3f:	75 0d                	jne    80104c4e <sched+0x27>
    panic("sched ptable.lock");
80104c41:	83 ec 0c             	sub    $0xc,%esp
80104c44:	68 a5 89 10 80       	push   $0x801089a5
80104c49:	e8 2d b9 ff ff       	call   8010057b <panic>
  if(cpu->ncli != 1)
80104c4e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c54:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c5a:	83 f8 01             	cmp    $0x1,%eax
80104c5d:	74 0d                	je     80104c6c <sched+0x45>
    panic("sched locks");
80104c5f:	83 ec 0c             	sub    $0xc,%esp
80104c62:	68 b7 89 10 80       	push   $0x801089b7
80104c67:	e8 0f b9 ff ff       	call   8010057b <panic>
  if(proc->state == RUNNING)
80104c6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c72:	8b 40 0c             	mov    0xc(%eax),%eax
80104c75:	83 f8 04             	cmp    $0x4,%eax
80104c78:	75 0d                	jne    80104c87 <sched+0x60>
    panic("sched running");
80104c7a:	83 ec 0c             	sub    $0xc,%esp
80104c7d:	68 c3 89 10 80       	push   $0x801089c3
80104c82:	e8 f4 b8 ff ff       	call   8010057b <panic>
  if(readeflags()&FL_IF)
80104c87:	e8 ef f7 ff ff       	call   8010447b <readeflags>
80104c8c:	25 00 02 00 00       	and    $0x200,%eax
80104c91:	85 c0                	test   %eax,%eax
80104c93:	74 0d                	je     80104ca2 <sched+0x7b>
    panic("sched interruptible");
80104c95:	83 ec 0c             	sub    $0xc,%esp
80104c98:	68 d1 89 10 80       	push   $0x801089d1
80104c9d:	e8 d9 b8 ff ff       	call   8010057b <panic>
  intena = cpu->intena;
80104ca2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ca8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104cae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104cb1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cb7:	8b 40 04             	mov    0x4(%eax),%eax
80104cba:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cc1:	83 c2 1c             	add    $0x1c,%edx
80104cc4:	83 ec 08             	sub    $0x8,%esp
80104cc7:	50                   	push   %eax
80104cc8:	52                   	push   %edx
80104cc9:	e8 8b 08 00 00       	call   80105559 <swtch>
80104cce:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104cd1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cd7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cda:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104ce0:	90                   	nop
80104ce1:	c9                   	leave  
80104ce2:	c3                   	ret    

80104ce3 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104ce3:	55                   	push   %ebp
80104ce4:	89 e5                	mov    %esp,%ebp
80104ce6:	83 ec 08             	sub    $0x8,%esp
  if (sched_trace_enabled)
80104ce9:	a1 54 38 11 80       	mov    0x80113854,%eax
80104cee:	85 c0                	test   %eax,%eax
80104cf0:	74 1a                	je     80104d0c <yield+0x29>
  {
    cprintf("[%d]", proc->pid);
80104cf2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cf8:	8b 40 10             	mov    0x10(%eax),%eax
80104cfb:	83 ec 08             	sub    $0x8,%esp
80104cfe:	50                   	push   %eax
80104cff:	68 e5 89 10 80       	push   $0x801089e5
80104d04:	e8 bd b6 ff ff       	call   801003c6 <cprintf>
80104d09:	83 c4 10             	add    $0x10,%esp
  }

  acquire(&ptable.lock);  //DOC: yieldlock
80104d0c:	83 ec 0c             	sub    $0xc,%esp
80104d0f:	68 20 19 11 80       	push   $0x80111920
80104d14:	e8 69 03 00 00       	call   80105082 <acquire>
80104d19:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104d1c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d22:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d29:	e8 f9 fe ff ff       	call   80104c27 <sched>
  release(&ptable.lock);
80104d2e:	83 ec 0c             	sub    $0xc,%esp
80104d31:	68 20 19 11 80       	push   $0x80111920
80104d36:	e8 ae 03 00 00       	call   801050e9 <release>
80104d3b:	83 c4 10             	add    $0x10,%esp
}
80104d3e:	90                   	nop
80104d3f:	c9                   	leave  
80104d40:	c3                   	ret    

80104d41 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d41:	55                   	push   %ebp
80104d42:	89 e5                	mov    %esp,%ebp
80104d44:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d47:	83 ec 0c             	sub    $0xc,%esp
80104d4a:	68 20 19 11 80       	push   $0x80111920
80104d4f:	e8 95 03 00 00       	call   801050e9 <release>
80104d54:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104d57:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104d5c:	85 c0                	test   %eax,%eax
80104d5e:	74 24                	je     80104d84 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d60:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104d67:	00 00 00 
    iinit(ROOTDEV);
80104d6a:	83 ec 0c             	sub    $0xc,%esp
80104d6d:	6a 01                	push   $0x1
80104d6f:	e8 f7 c8 ff ff       	call   8010166b <iinit>
80104d74:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104d77:	83 ec 0c             	sub    $0xc,%esp
80104d7a:	6a 01                	push   $0x1
80104d7c:	e8 cc e5 ff ff       	call   8010334d <initlog>
80104d81:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d84:	90                   	nop
80104d85:	c9                   	leave  
80104d86:	c3                   	ret    

80104d87 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d87:	55                   	push   %ebp
80104d88:	89 e5                	mov    %esp,%ebp
80104d8a:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104d8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d93:	85 c0                	test   %eax,%eax
80104d95:	75 0d                	jne    80104da4 <sleep+0x1d>
    panic("sleep");
80104d97:	83 ec 0c             	sub    $0xc,%esp
80104d9a:	68 ea 89 10 80       	push   $0x801089ea
80104d9f:	e8 d7 b7 ff ff       	call   8010057b <panic>

  if(lk == 0)
80104da4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104da8:	75 0d                	jne    80104db7 <sleep+0x30>
    panic("sleep without lk");
80104daa:	83 ec 0c             	sub    $0xc,%esp
80104dad:	68 f0 89 10 80       	push   $0x801089f0
80104db2:	e8 c4 b7 ff ff       	call   8010057b <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104db7:	81 7d 0c 20 19 11 80 	cmpl   $0x80111920,0xc(%ebp)
80104dbe:	74 1e                	je     80104dde <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104dc0:	83 ec 0c             	sub    $0xc,%esp
80104dc3:	68 20 19 11 80       	push   $0x80111920
80104dc8:	e8 b5 02 00 00       	call   80105082 <acquire>
80104dcd:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104dd0:	83 ec 0c             	sub    $0xc,%esp
80104dd3:	ff 75 0c             	pushl  0xc(%ebp)
80104dd6:	e8 0e 03 00 00       	call   801050e9 <release>
80104ddb:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104dde:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104de4:	8b 55 08             	mov    0x8(%ebp),%edx
80104de7:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104dea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104df0:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104df7:	e8 2b fe ff ff       	call   80104c27 <sched>

  // Tidy up.
  proc->chan = 0;
80104dfc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e02:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e09:	81 7d 0c 20 19 11 80 	cmpl   $0x80111920,0xc(%ebp)
80104e10:	74 1e                	je     80104e30 <sleep+0xa9>
    release(&ptable.lock);
80104e12:	83 ec 0c             	sub    $0xc,%esp
80104e15:	68 20 19 11 80       	push   $0x80111920
80104e1a:	e8 ca 02 00 00       	call   801050e9 <release>
80104e1f:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104e22:	83 ec 0c             	sub    $0xc,%esp
80104e25:	ff 75 0c             	pushl  0xc(%ebp)
80104e28:	e8 55 02 00 00       	call   80105082 <acquire>
80104e2d:	83 c4 10             	add    $0x10,%esp
  }
}
80104e30:	90                   	nop
80104e31:	c9                   	leave  
80104e32:	c3                   	ret    

80104e33 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e33:	55                   	push   %ebp
80104e34:	89 e5                	mov    %esp,%ebp
80104e36:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e39:	c7 45 fc 54 19 11 80 	movl   $0x80111954,-0x4(%ebp)
80104e40:	eb 24                	jmp    80104e66 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104e42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e45:	8b 40 0c             	mov    0xc(%eax),%eax
80104e48:	83 f8 02             	cmp    $0x2,%eax
80104e4b:	75 15                	jne    80104e62 <wakeup1+0x2f>
80104e4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e50:	8b 40 20             	mov    0x20(%eax),%eax
80104e53:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e56:	75 0a                	jne    80104e62 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e58:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e5b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e62:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104e66:	81 7d fc 54 38 11 80 	cmpl   $0x80113854,-0x4(%ebp)
80104e6d:	72 d3                	jb     80104e42 <wakeup1+0xf>
}
80104e6f:	90                   	nop
80104e70:	90                   	nop
80104e71:	c9                   	leave  
80104e72:	c3                   	ret    

80104e73 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e73:	55                   	push   %ebp
80104e74:	89 e5                	mov    %esp,%ebp
80104e76:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104e79:	83 ec 0c             	sub    $0xc,%esp
80104e7c:	68 20 19 11 80       	push   $0x80111920
80104e81:	e8 fc 01 00 00       	call   80105082 <acquire>
80104e86:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104e89:	83 ec 0c             	sub    $0xc,%esp
80104e8c:	ff 75 08             	pushl  0x8(%ebp)
80104e8f:	e8 9f ff ff ff       	call   80104e33 <wakeup1>
80104e94:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104e97:	83 ec 0c             	sub    $0xc,%esp
80104e9a:	68 20 19 11 80       	push   $0x80111920
80104e9f:	e8 45 02 00 00       	call   801050e9 <release>
80104ea4:	83 c4 10             	add    $0x10,%esp
}
80104ea7:	90                   	nop
80104ea8:	c9                   	leave  
80104ea9:	c3                   	ret    

80104eaa <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104eaa:	55                   	push   %ebp
80104eab:	89 e5                	mov    %esp,%ebp
80104ead:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104eb0:	83 ec 0c             	sub    $0xc,%esp
80104eb3:	68 20 19 11 80       	push   $0x80111920
80104eb8:	e8 c5 01 00 00       	call   80105082 <acquire>
80104ebd:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ec0:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
80104ec7:	eb 45                	jmp    80104f0e <kill+0x64>
    if(p->pid == pid){
80104ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ecc:	8b 40 10             	mov    0x10(%eax),%eax
80104ecf:	39 45 08             	cmp    %eax,0x8(%ebp)
80104ed2:	75 36                	jne    80104f0a <kill+0x60>
      p->killed = 1;
80104ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee1:	8b 40 0c             	mov    0xc(%eax),%eax
80104ee4:	83 f8 02             	cmp    $0x2,%eax
80104ee7:	75 0a                	jne    80104ef3 <kill+0x49>
        p->state = RUNNABLE;
80104ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eec:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104ef3:	83 ec 0c             	sub    $0xc,%esp
80104ef6:	68 20 19 11 80       	push   $0x80111920
80104efb:	e8 e9 01 00 00       	call   801050e9 <release>
80104f00:	83 c4 10             	add    $0x10,%esp
      return 0;
80104f03:	b8 00 00 00 00       	mov    $0x0,%eax
80104f08:	eb 22                	jmp    80104f2c <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f0a:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104f0e:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
80104f15:	72 b2                	jb     80104ec9 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104f17:	83 ec 0c             	sub    $0xc,%esp
80104f1a:	68 20 19 11 80       	push   $0x80111920
80104f1f:	e8 c5 01 00 00       	call   801050e9 <release>
80104f24:	83 c4 10             	add    $0x10,%esp
  return -1;
80104f27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f2c:	c9                   	leave  
80104f2d:	c3                   	ret    

80104f2e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f2e:	55                   	push   %ebp
80104f2f:	89 e5                	mov    %esp,%ebp
80104f31:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f34:	c7 45 f0 54 19 11 80 	movl   $0x80111954,-0x10(%ebp)
80104f3b:	e9 d7 00 00 00       	jmp    80105017 <procdump+0xe9>
    if(p->state == UNUSED)
80104f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f43:	8b 40 0c             	mov    0xc(%eax),%eax
80104f46:	85 c0                	test   %eax,%eax
80104f48:	0f 84 c4 00 00 00    	je     80105012 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f51:	8b 40 0c             	mov    0xc(%eax),%eax
80104f54:	83 f8 05             	cmp    $0x5,%eax
80104f57:	77 23                	ja     80104f7c <procdump+0x4e>
80104f59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f5c:	8b 40 0c             	mov    0xc(%eax),%eax
80104f5f:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f66:	85 c0                	test   %eax,%eax
80104f68:	74 12                	je     80104f7c <procdump+0x4e>
      state = states[p->state];
80104f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f6d:	8b 40 0c             	mov    0xc(%eax),%eax
80104f70:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f77:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f7a:	eb 07                	jmp    80104f83 <procdump+0x55>
    else
      state = "???";
80104f7c:	c7 45 ec 01 8a 10 80 	movl   $0x80108a01,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f86:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f8c:	8b 40 10             	mov    0x10(%eax),%eax
80104f8f:	52                   	push   %edx
80104f90:	ff 75 ec             	pushl  -0x14(%ebp)
80104f93:	50                   	push   %eax
80104f94:	68 05 8a 10 80       	push   $0x80108a05
80104f99:	e8 28 b4 ff ff       	call   801003c6 <cprintf>
80104f9e:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa4:	8b 40 0c             	mov    0xc(%eax),%eax
80104fa7:	83 f8 02             	cmp    $0x2,%eax
80104faa:	75 54                	jne    80105000 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104faf:	8b 40 1c             	mov    0x1c(%eax),%eax
80104fb2:	8b 40 0c             	mov    0xc(%eax),%eax
80104fb5:	83 c0 08             	add    $0x8,%eax
80104fb8:	89 c2                	mov    %eax,%edx
80104fba:	83 ec 08             	sub    $0x8,%esp
80104fbd:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104fc0:	50                   	push   %eax
80104fc1:	52                   	push   %edx
80104fc2:	e8 74 01 00 00       	call   8010513b <getcallerpcs>
80104fc7:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104fca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fd1:	eb 1c                	jmp    80104fef <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fda:	83 ec 08             	sub    $0x8,%esp
80104fdd:	50                   	push   %eax
80104fde:	68 0e 8a 10 80       	push   $0x80108a0e
80104fe3:	e8 de b3 ff ff       	call   801003c6 <cprintf>
80104fe8:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104feb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104fef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104ff3:	7f 0b                	jg     80105000 <procdump+0xd2>
80104ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff8:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104ffc:	85 c0                	test   %eax,%eax
80104ffe:	75 d3                	jne    80104fd3 <procdump+0xa5>
    }
    cprintf("\n");
80105000:	83 ec 0c             	sub    $0xc,%esp
80105003:	68 12 8a 10 80       	push   $0x80108a12
80105008:	e8 b9 b3 ff ff       	call   801003c6 <cprintf>
8010500d:	83 c4 10             	add    $0x10,%esp
80105010:	eb 01                	jmp    80105013 <procdump+0xe5>
      continue;
80105012:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105013:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80105017:	81 7d f0 54 38 11 80 	cmpl   $0x80113854,-0x10(%ebp)
8010501e:	0f 82 1c ff ff ff    	jb     80104f40 <procdump+0x12>
  }
}
80105024:	90                   	nop
80105025:	90                   	nop
80105026:	c9                   	leave  
80105027:	c3                   	ret    

80105028 <readeflags>:
{
80105028:	55                   	push   %ebp
80105029:	89 e5                	mov    %esp,%ebp
8010502b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010502e:	9c                   	pushf  
8010502f:	58                   	pop    %eax
80105030:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105033:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105036:	c9                   	leave  
80105037:	c3                   	ret    

80105038 <cli>:
{
80105038:	55                   	push   %ebp
80105039:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010503b:	fa                   	cli    
}
8010503c:	90                   	nop
8010503d:	5d                   	pop    %ebp
8010503e:	c3                   	ret    

8010503f <sti>:
{
8010503f:	55                   	push   %ebp
80105040:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105042:	fb                   	sti    
}
80105043:	90                   	nop
80105044:	5d                   	pop    %ebp
80105045:	c3                   	ret    

80105046 <xchg>:
{
80105046:	55                   	push   %ebp
80105047:	89 e5                	mov    %esp,%ebp
80105049:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010504c:	8b 55 08             	mov    0x8(%ebp),%edx
8010504f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105052:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105055:	f0 87 02             	lock xchg %eax,(%edx)
80105058:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010505b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010505e:	c9                   	leave  
8010505f:	c3                   	ret    

80105060 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105060:	55                   	push   %ebp
80105061:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105063:	8b 45 08             	mov    0x8(%ebp),%eax
80105066:	8b 55 0c             	mov    0xc(%ebp),%edx
80105069:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010506c:	8b 45 08             	mov    0x8(%ebp),%eax
8010506f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105075:	8b 45 08             	mov    0x8(%ebp),%eax
80105078:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010507f:	90                   	nop
80105080:	5d                   	pop    %ebp
80105081:	c3                   	ret    

80105082 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105082:	55                   	push   %ebp
80105083:	89 e5                	mov    %esp,%ebp
80105085:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105088:	e8 53 01 00 00       	call   801051e0 <pushcli>
  if(holding(lk))
8010508d:	8b 45 08             	mov    0x8(%ebp),%eax
80105090:	83 ec 0c             	sub    $0xc,%esp
80105093:	50                   	push   %eax
80105094:	e8 1d 01 00 00       	call   801051b6 <holding>
80105099:	83 c4 10             	add    $0x10,%esp
8010509c:	85 c0                	test   %eax,%eax
8010509e:	74 0d                	je     801050ad <acquire+0x2b>
    panic("acquire");
801050a0:	83 ec 0c             	sub    $0xc,%esp
801050a3:	68 3e 8a 10 80       	push   $0x80108a3e
801050a8:	e8 ce b4 ff ff       	call   8010057b <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801050ad:	90                   	nop
801050ae:	8b 45 08             	mov    0x8(%ebp),%eax
801050b1:	83 ec 08             	sub    $0x8,%esp
801050b4:	6a 01                	push   $0x1
801050b6:	50                   	push   %eax
801050b7:	e8 8a ff ff ff       	call   80105046 <xchg>
801050bc:	83 c4 10             	add    $0x10,%esp
801050bf:	85 c0                	test   %eax,%eax
801050c1:	75 eb                	jne    801050ae <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801050c3:	8b 45 08             	mov    0x8(%ebp),%eax
801050c6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801050cd:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801050d0:	8b 45 08             	mov    0x8(%ebp),%eax
801050d3:	83 c0 0c             	add    $0xc,%eax
801050d6:	83 ec 08             	sub    $0x8,%esp
801050d9:	50                   	push   %eax
801050da:	8d 45 08             	lea    0x8(%ebp),%eax
801050dd:	50                   	push   %eax
801050de:	e8 58 00 00 00       	call   8010513b <getcallerpcs>
801050e3:	83 c4 10             	add    $0x10,%esp
}
801050e6:	90                   	nop
801050e7:	c9                   	leave  
801050e8:	c3                   	ret    

801050e9 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801050e9:	55                   	push   %ebp
801050ea:	89 e5                	mov    %esp,%ebp
801050ec:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801050ef:	83 ec 0c             	sub    $0xc,%esp
801050f2:	ff 75 08             	pushl  0x8(%ebp)
801050f5:	e8 bc 00 00 00       	call   801051b6 <holding>
801050fa:	83 c4 10             	add    $0x10,%esp
801050fd:	85 c0                	test   %eax,%eax
801050ff:	75 0d                	jne    8010510e <release+0x25>
    panic("release");
80105101:	83 ec 0c             	sub    $0xc,%esp
80105104:	68 46 8a 10 80       	push   $0x80108a46
80105109:	e8 6d b4 ff ff       	call   8010057b <panic>

  lk->pcs[0] = 0;
8010510e:	8b 45 08             	mov    0x8(%ebp),%eax
80105111:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105118:	8b 45 08             	mov    0x8(%ebp),%eax
8010511b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105122:	8b 45 08             	mov    0x8(%ebp),%eax
80105125:	83 ec 08             	sub    $0x8,%esp
80105128:	6a 00                	push   $0x0
8010512a:	50                   	push   %eax
8010512b:	e8 16 ff ff ff       	call   80105046 <xchg>
80105130:	83 c4 10             	add    $0x10,%esp

  popcli();
80105133:	e8 ec 00 00 00       	call   80105224 <popcli>
}
80105138:	90                   	nop
80105139:	c9                   	leave  
8010513a:	c3                   	ret    

8010513b <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010513b:	55                   	push   %ebp
8010513c:	89 e5                	mov    %esp,%ebp
8010513e:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105141:	8b 45 08             	mov    0x8(%ebp),%eax
80105144:	83 e8 08             	sub    $0x8,%eax
80105147:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010514a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105151:	eb 38                	jmp    8010518b <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105153:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105157:	74 53                	je     801051ac <getcallerpcs+0x71>
80105159:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105160:	76 4a                	jbe    801051ac <getcallerpcs+0x71>
80105162:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105166:	74 44                	je     801051ac <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105168:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010516b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105172:	8b 45 0c             	mov    0xc(%ebp),%eax
80105175:	01 c2                	add    %eax,%edx
80105177:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010517a:	8b 40 04             	mov    0x4(%eax),%eax
8010517d:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010517f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105182:	8b 00                	mov    (%eax),%eax
80105184:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105187:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010518b:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010518f:	7e c2                	jle    80105153 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80105191:	eb 19                	jmp    801051ac <getcallerpcs+0x71>
    pcs[i] = 0;
80105193:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105196:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010519d:	8b 45 0c             	mov    0xc(%ebp),%eax
801051a0:	01 d0                	add    %edx,%eax
801051a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801051a8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051ac:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051b0:	7e e1                	jle    80105193 <getcallerpcs+0x58>
}
801051b2:	90                   	nop
801051b3:	90                   	nop
801051b4:	c9                   	leave  
801051b5:	c3                   	ret    

801051b6 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801051b6:	55                   	push   %ebp
801051b7:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801051b9:	8b 45 08             	mov    0x8(%ebp),%eax
801051bc:	8b 00                	mov    (%eax),%eax
801051be:	85 c0                	test   %eax,%eax
801051c0:	74 17                	je     801051d9 <holding+0x23>
801051c2:	8b 45 08             	mov    0x8(%ebp),%eax
801051c5:	8b 50 08             	mov    0x8(%eax),%edx
801051c8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051ce:	39 c2                	cmp    %eax,%edx
801051d0:	75 07                	jne    801051d9 <holding+0x23>
801051d2:	b8 01 00 00 00       	mov    $0x1,%eax
801051d7:	eb 05                	jmp    801051de <holding+0x28>
801051d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051de:	5d                   	pop    %ebp
801051df:	c3                   	ret    

801051e0 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801051e0:	55                   	push   %ebp
801051e1:	89 e5                	mov    %esp,%ebp
801051e3:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801051e6:	e8 3d fe ff ff       	call   80105028 <readeflags>
801051eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801051ee:	e8 45 fe ff ff       	call   80105038 <cli>
  if(cpu->ncli++ == 0)
801051f3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051f9:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801051ff:	8d 4a 01             	lea    0x1(%edx),%ecx
80105202:	89 88 ac 00 00 00    	mov    %ecx,0xac(%eax)
80105208:	85 d2                	test   %edx,%edx
8010520a:	75 15                	jne    80105221 <pushcli+0x41>
    cpu->intena = eflags & FL_IF;
8010520c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105212:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105215:	81 e2 00 02 00 00    	and    $0x200,%edx
8010521b:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105221:	90                   	nop
80105222:	c9                   	leave  
80105223:	c3                   	ret    

80105224 <popcli>:

void
popcli(void)
{
80105224:	55                   	push   %ebp
80105225:	89 e5                	mov    %esp,%ebp
80105227:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010522a:	e8 f9 fd ff ff       	call   80105028 <readeflags>
8010522f:	25 00 02 00 00       	and    $0x200,%eax
80105234:	85 c0                	test   %eax,%eax
80105236:	74 0d                	je     80105245 <popcli+0x21>
    panic("popcli - interruptible");
80105238:	83 ec 0c             	sub    $0xc,%esp
8010523b:	68 4e 8a 10 80       	push   $0x80108a4e
80105240:	e8 36 b3 ff ff       	call   8010057b <panic>
  if(--cpu->ncli < 0)
80105245:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010524b:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105251:	83 ea 01             	sub    $0x1,%edx
80105254:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010525a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105260:	85 c0                	test   %eax,%eax
80105262:	79 0d                	jns    80105271 <popcli+0x4d>
    panic("popcli");
80105264:	83 ec 0c             	sub    $0xc,%esp
80105267:	68 65 8a 10 80       	push   $0x80108a65
8010526c:	e8 0a b3 ff ff       	call   8010057b <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105271:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105277:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010527d:	85 c0                	test   %eax,%eax
8010527f:	75 15                	jne    80105296 <popcli+0x72>
80105281:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105287:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010528d:	85 c0                	test   %eax,%eax
8010528f:	74 05                	je     80105296 <popcli+0x72>
    sti();
80105291:	e8 a9 fd ff ff       	call   8010503f <sti>
}
80105296:	90                   	nop
80105297:	c9                   	leave  
80105298:	c3                   	ret    

80105299 <stosb>:
{
80105299:	55                   	push   %ebp
8010529a:	89 e5                	mov    %esp,%ebp
8010529c:	57                   	push   %edi
8010529d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010529e:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052a1:	8b 55 10             	mov    0x10(%ebp),%edx
801052a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a7:	89 cb                	mov    %ecx,%ebx
801052a9:	89 df                	mov    %ebx,%edi
801052ab:	89 d1                	mov    %edx,%ecx
801052ad:	fc                   	cld    
801052ae:	f3 aa                	rep stos %al,%es:(%edi)
801052b0:	89 ca                	mov    %ecx,%edx
801052b2:	89 fb                	mov    %edi,%ebx
801052b4:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052b7:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052ba:	90                   	nop
801052bb:	5b                   	pop    %ebx
801052bc:	5f                   	pop    %edi
801052bd:	5d                   	pop    %ebp
801052be:	c3                   	ret    

801052bf <stosl>:
{
801052bf:	55                   	push   %ebp
801052c0:	89 e5                	mov    %esp,%ebp
801052c2:	57                   	push   %edi
801052c3:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052c7:	8b 55 10             	mov    0x10(%ebp),%edx
801052ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801052cd:	89 cb                	mov    %ecx,%ebx
801052cf:	89 df                	mov    %ebx,%edi
801052d1:	89 d1                	mov    %edx,%ecx
801052d3:	fc                   	cld    
801052d4:	f3 ab                	rep stos %eax,%es:(%edi)
801052d6:	89 ca                	mov    %ecx,%edx
801052d8:	89 fb                	mov    %edi,%ebx
801052da:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052dd:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052e0:	90                   	nop
801052e1:	5b                   	pop    %ebx
801052e2:	5f                   	pop    %edi
801052e3:	5d                   	pop    %ebp
801052e4:	c3                   	ret    

801052e5 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801052e5:	55                   	push   %ebp
801052e6:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801052e8:	8b 45 08             	mov    0x8(%ebp),%eax
801052eb:	83 e0 03             	and    $0x3,%eax
801052ee:	85 c0                	test   %eax,%eax
801052f0:	75 43                	jne    80105335 <memset+0x50>
801052f2:	8b 45 10             	mov    0x10(%ebp),%eax
801052f5:	83 e0 03             	and    $0x3,%eax
801052f8:	85 c0                	test   %eax,%eax
801052fa:	75 39                	jne    80105335 <memset+0x50>
    c &= 0xFF;
801052fc:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105303:	8b 45 10             	mov    0x10(%ebp),%eax
80105306:	c1 e8 02             	shr    $0x2,%eax
80105309:	89 c2                	mov    %eax,%edx
8010530b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010530e:	c1 e0 18             	shl    $0x18,%eax
80105311:	89 c1                	mov    %eax,%ecx
80105313:	8b 45 0c             	mov    0xc(%ebp),%eax
80105316:	c1 e0 10             	shl    $0x10,%eax
80105319:	09 c1                	or     %eax,%ecx
8010531b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010531e:	c1 e0 08             	shl    $0x8,%eax
80105321:	09 c8                	or     %ecx,%eax
80105323:	0b 45 0c             	or     0xc(%ebp),%eax
80105326:	52                   	push   %edx
80105327:	50                   	push   %eax
80105328:	ff 75 08             	pushl  0x8(%ebp)
8010532b:	e8 8f ff ff ff       	call   801052bf <stosl>
80105330:	83 c4 0c             	add    $0xc,%esp
80105333:	eb 12                	jmp    80105347 <memset+0x62>
  } else
    stosb(dst, c, n);
80105335:	8b 45 10             	mov    0x10(%ebp),%eax
80105338:	50                   	push   %eax
80105339:	ff 75 0c             	pushl  0xc(%ebp)
8010533c:	ff 75 08             	pushl  0x8(%ebp)
8010533f:	e8 55 ff ff ff       	call   80105299 <stosb>
80105344:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105347:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010534a:	c9                   	leave  
8010534b:	c3                   	ret    

8010534c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010534c:	55                   	push   %ebp
8010534d:	89 e5                	mov    %esp,%ebp
8010534f:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105352:	8b 45 08             	mov    0x8(%ebp),%eax
80105355:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105358:	8b 45 0c             	mov    0xc(%ebp),%eax
8010535b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010535e:	eb 30                	jmp    80105390 <memcmp+0x44>
    if(*s1 != *s2)
80105360:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105363:	0f b6 10             	movzbl (%eax),%edx
80105366:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105369:	0f b6 00             	movzbl (%eax),%eax
8010536c:	38 c2                	cmp    %al,%dl
8010536e:	74 18                	je     80105388 <memcmp+0x3c>
      return *s1 - *s2;
80105370:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105373:	0f b6 00             	movzbl (%eax),%eax
80105376:	0f b6 d0             	movzbl %al,%edx
80105379:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010537c:	0f b6 00             	movzbl (%eax),%eax
8010537f:	0f b6 c8             	movzbl %al,%ecx
80105382:	89 d0                	mov    %edx,%eax
80105384:	29 c8                	sub    %ecx,%eax
80105386:	eb 1a                	jmp    801053a2 <memcmp+0x56>
    s1++, s2++;
80105388:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010538c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105390:	8b 45 10             	mov    0x10(%ebp),%eax
80105393:	8d 50 ff             	lea    -0x1(%eax),%edx
80105396:	89 55 10             	mov    %edx,0x10(%ebp)
80105399:	85 c0                	test   %eax,%eax
8010539b:	75 c3                	jne    80105360 <memcmp+0x14>
  }

  return 0;
8010539d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053a2:	c9                   	leave  
801053a3:	c3                   	ret    

801053a4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801053a4:	55                   	push   %ebp
801053a5:	89 e5                	mov    %esp,%ebp
801053a7:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801053aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801053b0:	8b 45 08             	mov    0x8(%ebp),%eax
801053b3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801053b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053b9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053bc:	73 54                	jae    80105412 <memmove+0x6e>
801053be:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053c1:	8b 45 10             	mov    0x10(%ebp),%eax
801053c4:	01 d0                	add    %edx,%eax
801053c6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801053c9:	73 47                	jae    80105412 <memmove+0x6e>
    s += n;
801053cb:	8b 45 10             	mov    0x10(%ebp),%eax
801053ce:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801053d1:	8b 45 10             	mov    0x10(%ebp),%eax
801053d4:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801053d7:	eb 13                	jmp    801053ec <memmove+0x48>
      *--d = *--s;
801053d9:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801053dd:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801053e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053e4:	0f b6 10             	movzbl (%eax),%edx
801053e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053ea:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801053ec:	8b 45 10             	mov    0x10(%ebp),%eax
801053ef:	8d 50 ff             	lea    -0x1(%eax),%edx
801053f2:	89 55 10             	mov    %edx,0x10(%ebp)
801053f5:	85 c0                	test   %eax,%eax
801053f7:	75 e0                	jne    801053d9 <memmove+0x35>
  if(s < d && s + n > d){
801053f9:	eb 24                	jmp    8010541f <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
801053fb:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053fe:	8d 42 01             	lea    0x1(%edx),%eax
80105401:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105404:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105407:	8d 48 01             	lea    0x1(%eax),%ecx
8010540a:	89 4d f8             	mov    %ecx,-0x8(%ebp)
8010540d:	0f b6 12             	movzbl (%edx),%edx
80105410:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105412:	8b 45 10             	mov    0x10(%ebp),%eax
80105415:	8d 50 ff             	lea    -0x1(%eax),%edx
80105418:	89 55 10             	mov    %edx,0x10(%ebp)
8010541b:	85 c0                	test   %eax,%eax
8010541d:	75 dc                	jne    801053fb <memmove+0x57>

  return dst;
8010541f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105422:	c9                   	leave  
80105423:	c3                   	ret    

80105424 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105424:	55                   	push   %ebp
80105425:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105427:	ff 75 10             	pushl  0x10(%ebp)
8010542a:	ff 75 0c             	pushl  0xc(%ebp)
8010542d:	ff 75 08             	pushl  0x8(%ebp)
80105430:	e8 6f ff ff ff       	call   801053a4 <memmove>
80105435:	83 c4 0c             	add    $0xc,%esp
}
80105438:	c9                   	leave  
80105439:	c3                   	ret    

8010543a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010543a:	55                   	push   %ebp
8010543b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010543d:	eb 0c                	jmp    8010544b <strncmp+0x11>
    n--, p++, q++;
8010543f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105443:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105447:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
8010544b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010544f:	74 1a                	je     8010546b <strncmp+0x31>
80105451:	8b 45 08             	mov    0x8(%ebp),%eax
80105454:	0f b6 00             	movzbl (%eax),%eax
80105457:	84 c0                	test   %al,%al
80105459:	74 10                	je     8010546b <strncmp+0x31>
8010545b:	8b 45 08             	mov    0x8(%ebp),%eax
8010545e:	0f b6 10             	movzbl (%eax),%edx
80105461:	8b 45 0c             	mov    0xc(%ebp),%eax
80105464:	0f b6 00             	movzbl (%eax),%eax
80105467:	38 c2                	cmp    %al,%dl
80105469:	74 d4                	je     8010543f <strncmp+0x5>
  if(n == 0)
8010546b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010546f:	75 07                	jne    80105478 <strncmp+0x3e>
    return 0;
80105471:	b8 00 00 00 00       	mov    $0x0,%eax
80105476:	eb 16                	jmp    8010548e <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105478:	8b 45 08             	mov    0x8(%ebp),%eax
8010547b:	0f b6 00             	movzbl (%eax),%eax
8010547e:	0f b6 d0             	movzbl %al,%edx
80105481:	8b 45 0c             	mov    0xc(%ebp),%eax
80105484:	0f b6 00             	movzbl (%eax),%eax
80105487:	0f b6 c8             	movzbl %al,%ecx
8010548a:	89 d0                	mov    %edx,%eax
8010548c:	29 c8                	sub    %ecx,%eax
}
8010548e:	5d                   	pop    %ebp
8010548f:	c3                   	ret    

80105490 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105490:	55                   	push   %ebp
80105491:	89 e5                	mov    %esp,%ebp
80105493:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105496:	8b 45 08             	mov    0x8(%ebp),%eax
80105499:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010549c:	90                   	nop
8010549d:	8b 45 10             	mov    0x10(%ebp),%eax
801054a0:	8d 50 ff             	lea    -0x1(%eax),%edx
801054a3:	89 55 10             	mov    %edx,0x10(%ebp)
801054a6:	85 c0                	test   %eax,%eax
801054a8:	7e 2c                	jle    801054d6 <strncpy+0x46>
801054aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801054ad:	8d 42 01             	lea    0x1(%edx),%eax
801054b0:	89 45 0c             	mov    %eax,0xc(%ebp)
801054b3:	8b 45 08             	mov    0x8(%ebp),%eax
801054b6:	8d 48 01             	lea    0x1(%eax),%ecx
801054b9:	89 4d 08             	mov    %ecx,0x8(%ebp)
801054bc:	0f b6 12             	movzbl (%edx),%edx
801054bf:	88 10                	mov    %dl,(%eax)
801054c1:	0f b6 00             	movzbl (%eax),%eax
801054c4:	84 c0                	test   %al,%al
801054c6:	75 d5                	jne    8010549d <strncpy+0xd>
    ;
  while(n-- > 0)
801054c8:	eb 0c                	jmp    801054d6 <strncpy+0x46>
    *s++ = 0;
801054ca:	8b 45 08             	mov    0x8(%ebp),%eax
801054cd:	8d 50 01             	lea    0x1(%eax),%edx
801054d0:	89 55 08             	mov    %edx,0x8(%ebp)
801054d3:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801054d6:	8b 45 10             	mov    0x10(%ebp),%eax
801054d9:	8d 50 ff             	lea    -0x1(%eax),%edx
801054dc:	89 55 10             	mov    %edx,0x10(%ebp)
801054df:	85 c0                	test   %eax,%eax
801054e1:	7f e7                	jg     801054ca <strncpy+0x3a>
  return os;
801054e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054e6:	c9                   	leave  
801054e7:	c3                   	ret    

801054e8 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054e8:	55                   	push   %ebp
801054e9:	89 e5                	mov    %esp,%ebp
801054eb:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054ee:	8b 45 08             	mov    0x8(%ebp),%eax
801054f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801054f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054f8:	7f 05                	jg     801054ff <safestrcpy+0x17>
    return os;
801054fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054fd:	eb 31                	jmp    80105530 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801054ff:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105503:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105507:	7e 1e                	jle    80105527 <safestrcpy+0x3f>
80105509:	8b 55 0c             	mov    0xc(%ebp),%edx
8010550c:	8d 42 01             	lea    0x1(%edx),%eax
8010550f:	89 45 0c             	mov    %eax,0xc(%ebp)
80105512:	8b 45 08             	mov    0x8(%ebp),%eax
80105515:	8d 48 01             	lea    0x1(%eax),%ecx
80105518:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010551b:	0f b6 12             	movzbl (%edx),%edx
8010551e:	88 10                	mov    %dl,(%eax)
80105520:	0f b6 00             	movzbl (%eax),%eax
80105523:	84 c0                	test   %al,%al
80105525:	75 d8                	jne    801054ff <safestrcpy+0x17>
    ;
  *s = 0;
80105527:	8b 45 08             	mov    0x8(%ebp),%eax
8010552a:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010552d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105530:	c9                   	leave  
80105531:	c3                   	ret    

80105532 <strlen>:

int
strlen(const char *s)
{
80105532:	55                   	push   %ebp
80105533:	89 e5                	mov    %esp,%ebp
80105535:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105538:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010553f:	eb 04                	jmp    80105545 <strlen+0x13>
80105541:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105545:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105548:	8b 45 08             	mov    0x8(%ebp),%eax
8010554b:	01 d0                	add    %edx,%eax
8010554d:	0f b6 00             	movzbl (%eax),%eax
80105550:	84 c0                	test   %al,%al
80105552:	75 ed                	jne    80105541 <strlen+0xf>
    ;
  return n;
80105554:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105557:	c9                   	leave  
80105558:	c3                   	ret    

80105559 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105559:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010555d:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105561:	55                   	push   %ebp
  pushl %ebx
80105562:	53                   	push   %ebx
  pushl %esi
80105563:	56                   	push   %esi
  pushl %edi
80105564:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105565:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105567:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105569:	5f                   	pop    %edi
  popl %esi
8010556a:	5e                   	pop    %esi
  popl %ebx
8010556b:	5b                   	pop    %ebx
  popl %ebp
8010556c:	5d                   	pop    %ebp
  ret
8010556d:	c3                   	ret    

8010556e <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010556e:	55                   	push   %ebp
8010556f:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105571:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105577:	8b 00                	mov    (%eax),%eax
80105579:	39 45 08             	cmp    %eax,0x8(%ebp)
8010557c:	73 12                	jae    80105590 <fetchint+0x22>
8010557e:	8b 45 08             	mov    0x8(%ebp),%eax
80105581:	8d 50 04             	lea    0x4(%eax),%edx
80105584:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010558a:	8b 00                	mov    (%eax),%eax
8010558c:	39 c2                	cmp    %eax,%edx
8010558e:	76 07                	jbe    80105597 <fetchint+0x29>
    return -1;
80105590:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105595:	eb 0f                	jmp    801055a6 <fetchint+0x38>
  *ip = *(int*)(addr);
80105597:	8b 45 08             	mov    0x8(%ebp),%eax
8010559a:	8b 10                	mov    (%eax),%edx
8010559c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010559f:	89 10                	mov    %edx,(%eax)
  return 0;
801055a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055a6:	5d                   	pop    %ebp
801055a7:	c3                   	ret    

801055a8 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801055a8:	55                   	push   %ebp
801055a9:	89 e5                	mov    %esp,%ebp
801055ab:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801055ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055b4:	8b 00                	mov    (%eax),%eax
801055b6:	39 45 08             	cmp    %eax,0x8(%ebp)
801055b9:	72 07                	jb     801055c2 <fetchstr+0x1a>
    return -1;
801055bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055c0:	eb 44                	jmp    80105606 <fetchstr+0x5e>
  *pp = (char*)addr;
801055c2:	8b 55 08             	mov    0x8(%ebp),%edx
801055c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801055c8:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801055ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055d0:	8b 00                	mov    (%eax),%eax
801055d2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801055d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d8:	8b 00                	mov    (%eax),%eax
801055da:	89 45 fc             	mov    %eax,-0x4(%ebp)
801055dd:	eb 1a                	jmp    801055f9 <fetchstr+0x51>
    if(*s == 0)
801055df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055e2:	0f b6 00             	movzbl (%eax),%eax
801055e5:	84 c0                	test   %al,%al
801055e7:	75 0c                	jne    801055f5 <fetchstr+0x4d>
      return s - *pp;
801055e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ec:	8b 10                	mov    (%eax),%edx
801055ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055f1:	29 d0                	sub    %edx,%eax
801055f3:	eb 11                	jmp    80105606 <fetchstr+0x5e>
  for(s = *pp; s < ep; s++)
801055f5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055fc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055ff:	72 de                	jb     801055df <fetchstr+0x37>
  return -1;
80105601:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105606:	c9                   	leave  
80105607:	c3                   	ret    

80105608 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105608:	55                   	push   %ebp
80105609:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010560b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105611:	8b 40 18             	mov    0x18(%eax),%eax
80105614:	8b 50 44             	mov    0x44(%eax),%edx
80105617:	8b 45 08             	mov    0x8(%ebp),%eax
8010561a:	c1 e0 02             	shl    $0x2,%eax
8010561d:	01 d0                	add    %edx,%eax
8010561f:	83 c0 04             	add    $0x4,%eax
80105622:	ff 75 0c             	pushl  0xc(%ebp)
80105625:	50                   	push   %eax
80105626:	e8 43 ff ff ff       	call   8010556e <fetchint>
8010562b:	83 c4 08             	add    $0x8,%esp
}
8010562e:	c9                   	leave  
8010562f:	c3                   	ret    

80105630 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105630:	55                   	push   %ebp
80105631:	89 e5                	mov    %esp,%ebp
80105633:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105636:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105639:	50                   	push   %eax
8010563a:	ff 75 08             	pushl  0x8(%ebp)
8010563d:	e8 c6 ff ff ff       	call   80105608 <argint>
80105642:	83 c4 08             	add    $0x8,%esp
80105645:	85 c0                	test   %eax,%eax
80105647:	79 07                	jns    80105650 <argptr+0x20>
    return -1;
80105649:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010564e:	eb 3b                	jmp    8010568b <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105650:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105656:	8b 00                	mov    (%eax),%eax
80105658:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010565b:	39 d0                	cmp    %edx,%eax
8010565d:	76 16                	jbe    80105675 <argptr+0x45>
8010565f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105662:	89 c2                	mov    %eax,%edx
80105664:	8b 45 10             	mov    0x10(%ebp),%eax
80105667:	01 c2                	add    %eax,%edx
80105669:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010566f:	8b 00                	mov    (%eax),%eax
80105671:	39 c2                	cmp    %eax,%edx
80105673:	76 07                	jbe    8010567c <argptr+0x4c>
    return -1;
80105675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010567a:	eb 0f                	jmp    8010568b <argptr+0x5b>
  *pp = (char*)i;
8010567c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010567f:	89 c2                	mov    %eax,%edx
80105681:	8b 45 0c             	mov    0xc(%ebp),%eax
80105684:	89 10                	mov    %edx,(%eax)
  return 0;
80105686:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010568b:	c9                   	leave  
8010568c:	c3                   	ret    

8010568d <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010568d:	55                   	push   %ebp
8010568e:	89 e5                	mov    %esp,%ebp
80105690:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105693:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105696:	50                   	push   %eax
80105697:	ff 75 08             	pushl  0x8(%ebp)
8010569a:	e8 69 ff ff ff       	call   80105608 <argint>
8010569f:	83 c4 08             	add    $0x8,%esp
801056a2:	85 c0                	test   %eax,%eax
801056a4:	79 07                	jns    801056ad <argstr+0x20>
    return -1;
801056a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ab:	eb 0f                	jmp    801056bc <argstr+0x2f>
  return fetchstr(addr, pp);
801056ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056b0:	ff 75 0c             	pushl  0xc(%ebp)
801056b3:	50                   	push   %eax
801056b4:	e8 ef fe ff ff       	call   801055a8 <fetchstr>
801056b9:	83 c4 08             	add    $0x8,%esp
}
801056bc:	c9                   	leave  
801056bd:	c3                   	ret    

801056be <syscall>:

};

void
syscall(void)
{
801056be:	55                   	push   %ebp
801056bf:	89 e5                	mov    %esp,%ebp
801056c1:	83 ec 18             	sub    $0x18,%esp
  int num;

  num = proc->tf->eax;
801056c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ca:	8b 40 18             	mov    0x18(%eax),%eax
801056cd:	8b 40 1c             	mov    0x1c(%eax),%eax
801056d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801056d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056d7:	7e 32                	jle    8010570b <syscall+0x4d>
801056d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056dc:	83 f8 17             	cmp    $0x17,%eax
801056df:	77 2a                	ja     8010570b <syscall+0x4d>
801056e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e4:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056eb:	85 c0                	test   %eax,%eax
801056ed:	74 1c                	je     8010570b <syscall+0x4d>
    proc->tf->eax = syscalls[num]();
801056ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f2:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056f9:	ff d0                	call   *%eax
801056fb:	89 c2                	mov    %eax,%edx
801056fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105703:	8b 40 18             	mov    0x18(%eax),%eax
80105706:	89 50 1c             	mov    %edx,0x1c(%eax)
80105709:	eb 35                	jmp    80105740 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010570b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105711:	8d 50 6c             	lea    0x6c(%eax),%edx
80105714:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("%d %s: unknown sys call %d\n",
8010571a:	8b 40 10             	mov    0x10(%eax),%eax
8010571d:	ff 75 f4             	pushl  -0xc(%ebp)
80105720:	52                   	push   %edx
80105721:	50                   	push   %eax
80105722:	68 6c 8a 10 80       	push   $0x80108a6c
80105727:	e8 9a ac ff ff       	call   801003c6 <cprintf>
8010572c:	83 c4 10             	add    $0x10,%esp
    proc->tf->eax = -1;
8010572f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105735:	8b 40 18             	mov    0x18(%eax),%eax
80105738:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010573f:	90                   	nop
80105740:	90                   	nop
80105741:	c9                   	leave  
80105742:	c3                   	ret    

80105743 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105743:	55                   	push   %ebp
80105744:	89 e5                	mov    %esp,%ebp
80105746:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105749:	83 ec 08             	sub    $0x8,%esp
8010574c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010574f:	50                   	push   %eax
80105750:	ff 75 08             	pushl  0x8(%ebp)
80105753:	e8 b0 fe ff ff       	call   80105608 <argint>
80105758:	83 c4 10             	add    $0x10,%esp
8010575b:	85 c0                	test   %eax,%eax
8010575d:	79 07                	jns    80105766 <argfd+0x23>
    return -1;
8010575f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105764:	eb 50                	jmp    801057b6 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105766:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105769:	85 c0                	test   %eax,%eax
8010576b:	78 21                	js     8010578e <argfd+0x4b>
8010576d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105770:	83 f8 0f             	cmp    $0xf,%eax
80105773:	7f 19                	jg     8010578e <argfd+0x4b>
80105775:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010577b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010577e:	83 c2 08             	add    $0x8,%edx
80105781:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105785:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105788:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010578c:	75 07                	jne    80105795 <argfd+0x52>
    return -1;
8010578e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105793:	eb 21                	jmp    801057b6 <argfd+0x73>
  if(pfd)
80105795:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105799:	74 08                	je     801057a3 <argfd+0x60>
    *pfd = fd;
8010579b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010579e:	8b 45 0c             	mov    0xc(%ebp),%eax
801057a1:	89 10                	mov    %edx,(%eax)
  if(pf)
801057a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057a7:	74 08                	je     801057b1 <argfd+0x6e>
    *pf = f;
801057a9:	8b 45 10             	mov    0x10(%ebp),%eax
801057ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057af:	89 10                	mov    %edx,(%eax)
  return 0;
801057b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057b6:	c9                   	leave  
801057b7:	c3                   	ret    

801057b8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801057b8:	55                   	push   %ebp
801057b9:	89 e5                	mov    %esp,%ebp
801057bb:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057be:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057c5:	eb 30                	jmp    801057f7 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801057c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057cd:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057d0:	83 c2 08             	add    $0x8,%edx
801057d3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057d7:	85 c0                	test   %eax,%eax
801057d9:	75 18                	jne    801057f3 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801057db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057e1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057e4:	8d 4a 08             	lea    0x8(%edx),%ecx
801057e7:	8b 55 08             	mov    0x8(%ebp),%edx
801057ea:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057f1:	eb 0f                	jmp    80105802 <fdalloc+0x4a>
  for(fd = 0; fd < NOFILE; fd++){
801057f3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057f7:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801057fb:	7e ca                	jle    801057c7 <fdalloc+0xf>
    }
  }
  return -1;
801057fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105802:	c9                   	leave  
80105803:	c3                   	ret    

80105804 <sys_dup>:

int
sys_dup(void)
{
80105804:	55                   	push   %ebp
80105805:	89 e5                	mov    %esp,%ebp
80105807:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010580a:	83 ec 04             	sub    $0x4,%esp
8010580d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105810:	50                   	push   %eax
80105811:	6a 00                	push   $0x0
80105813:	6a 00                	push   $0x0
80105815:	e8 29 ff ff ff       	call   80105743 <argfd>
8010581a:	83 c4 10             	add    $0x10,%esp
8010581d:	85 c0                	test   %eax,%eax
8010581f:	79 07                	jns    80105828 <sys_dup+0x24>
    return -1;
80105821:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105826:	eb 31                	jmp    80105859 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105828:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010582b:	83 ec 0c             	sub    $0xc,%esp
8010582e:	50                   	push   %eax
8010582f:	e8 84 ff ff ff       	call   801057b8 <fdalloc>
80105834:	83 c4 10             	add    $0x10,%esp
80105837:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010583a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010583e:	79 07                	jns    80105847 <sys_dup+0x43>
    return -1;
80105840:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105845:	eb 12                	jmp    80105859 <sys_dup+0x55>
  filedup(f);
80105847:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010584a:	83 ec 0c             	sub    $0xc,%esp
8010584d:	50                   	push   %eax
8010584e:	e8 da b7 ff ff       	call   8010102d <filedup>
80105853:	83 c4 10             	add    $0x10,%esp
  return fd;
80105856:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105859:	c9                   	leave  
8010585a:	c3                   	ret    

8010585b <sys_read>:

int
sys_read(void)
{
8010585b:	55                   	push   %ebp
8010585c:	89 e5                	mov    %esp,%ebp
8010585e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105861:	83 ec 04             	sub    $0x4,%esp
80105864:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105867:	50                   	push   %eax
80105868:	6a 00                	push   $0x0
8010586a:	6a 00                	push   $0x0
8010586c:	e8 d2 fe ff ff       	call   80105743 <argfd>
80105871:	83 c4 10             	add    $0x10,%esp
80105874:	85 c0                	test   %eax,%eax
80105876:	78 2e                	js     801058a6 <sys_read+0x4b>
80105878:	83 ec 08             	sub    $0x8,%esp
8010587b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010587e:	50                   	push   %eax
8010587f:	6a 02                	push   $0x2
80105881:	e8 82 fd ff ff       	call   80105608 <argint>
80105886:	83 c4 10             	add    $0x10,%esp
80105889:	85 c0                	test   %eax,%eax
8010588b:	78 19                	js     801058a6 <sys_read+0x4b>
8010588d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105890:	83 ec 04             	sub    $0x4,%esp
80105893:	50                   	push   %eax
80105894:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105897:	50                   	push   %eax
80105898:	6a 01                	push   $0x1
8010589a:	e8 91 fd ff ff       	call   80105630 <argptr>
8010589f:	83 c4 10             	add    $0x10,%esp
801058a2:	85 c0                	test   %eax,%eax
801058a4:	79 07                	jns    801058ad <sys_read+0x52>
    return -1;
801058a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ab:	eb 17                	jmp    801058c4 <sys_read+0x69>
  return fileread(f, p, n);
801058ad:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058b0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b6:	83 ec 04             	sub    $0x4,%esp
801058b9:	51                   	push   %ecx
801058ba:	52                   	push   %edx
801058bb:	50                   	push   %eax
801058bc:	e8 fc b8 ff ff       	call   801011bd <fileread>
801058c1:	83 c4 10             	add    $0x10,%esp
}
801058c4:	c9                   	leave  
801058c5:	c3                   	ret    

801058c6 <sys_write>:

int
sys_write(void)
{
801058c6:	55                   	push   %ebp
801058c7:	89 e5                	mov    %esp,%ebp
801058c9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058cc:	83 ec 04             	sub    $0x4,%esp
801058cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058d2:	50                   	push   %eax
801058d3:	6a 00                	push   $0x0
801058d5:	6a 00                	push   $0x0
801058d7:	e8 67 fe ff ff       	call   80105743 <argfd>
801058dc:	83 c4 10             	add    $0x10,%esp
801058df:	85 c0                	test   %eax,%eax
801058e1:	78 2e                	js     80105911 <sys_write+0x4b>
801058e3:	83 ec 08             	sub    $0x8,%esp
801058e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058e9:	50                   	push   %eax
801058ea:	6a 02                	push   $0x2
801058ec:	e8 17 fd ff ff       	call   80105608 <argint>
801058f1:	83 c4 10             	add    $0x10,%esp
801058f4:	85 c0                	test   %eax,%eax
801058f6:	78 19                	js     80105911 <sys_write+0x4b>
801058f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fb:	83 ec 04             	sub    $0x4,%esp
801058fe:	50                   	push   %eax
801058ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105902:	50                   	push   %eax
80105903:	6a 01                	push   $0x1
80105905:	e8 26 fd ff ff       	call   80105630 <argptr>
8010590a:	83 c4 10             	add    $0x10,%esp
8010590d:	85 c0                	test   %eax,%eax
8010590f:	79 07                	jns    80105918 <sys_write+0x52>
    return -1;
80105911:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105916:	eb 17                	jmp    8010592f <sys_write+0x69>
  return filewrite(f, p, n);
80105918:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010591b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010591e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105921:	83 ec 04             	sub    $0x4,%esp
80105924:	51                   	push   %ecx
80105925:	52                   	push   %edx
80105926:	50                   	push   %eax
80105927:	e8 49 b9 ff ff       	call   80101275 <filewrite>
8010592c:	83 c4 10             	add    $0x10,%esp
}
8010592f:	c9                   	leave  
80105930:	c3                   	ret    

80105931 <sys_close>:

int
sys_close(void)
{
80105931:	55                   	push   %ebp
80105932:	89 e5                	mov    %esp,%ebp
80105934:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105937:	83 ec 04             	sub    $0x4,%esp
8010593a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010593d:	50                   	push   %eax
8010593e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105941:	50                   	push   %eax
80105942:	6a 00                	push   $0x0
80105944:	e8 fa fd ff ff       	call   80105743 <argfd>
80105949:	83 c4 10             	add    $0x10,%esp
8010594c:	85 c0                	test   %eax,%eax
8010594e:	79 07                	jns    80105957 <sys_close+0x26>
    return -1;
80105950:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105955:	eb 28                	jmp    8010597f <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105957:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010595d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105960:	83 c2 08             	add    $0x8,%edx
80105963:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010596a:	00 
  fileclose(f);
8010596b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010596e:	83 ec 0c             	sub    $0xc,%esp
80105971:	50                   	push   %eax
80105972:	e8 07 b7 ff ff       	call   8010107e <fileclose>
80105977:	83 c4 10             	add    $0x10,%esp
  return 0;
8010597a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010597f:	c9                   	leave  
80105980:	c3                   	ret    

80105981 <sys_fstat>:

int
sys_fstat(void)
{
80105981:	55                   	push   %ebp
80105982:	89 e5                	mov    %esp,%ebp
80105984:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105987:	83 ec 04             	sub    $0x4,%esp
8010598a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010598d:	50                   	push   %eax
8010598e:	6a 00                	push   $0x0
80105990:	6a 00                	push   $0x0
80105992:	e8 ac fd ff ff       	call   80105743 <argfd>
80105997:	83 c4 10             	add    $0x10,%esp
8010599a:	85 c0                	test   %eax,%eax
8010599c:	78 17                	js     801059b5 <sys_fstat+0x34>
8010599e:	83 ec 04             	sub    $0x4,%esp
801059a1:	6a 14                	push   $0x14
801059a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059a6:	50                   	push   %eax
801059a7:	6a 01                	push   $0x1
801059a9:	e8 82 fc ff ff       	call   80105630 <argptr>
801059ae:	83 c4 10             	add    $0x10,%esp
801059b1:	85 c0                	test   %eax,%eax
801059b3:	79 07                	jns    801059bc <sys_fstat+0x3b>
    return -1;
801059b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ba:	eb 13                	jmp    801059cf <sys_fstat+0x4e>
  return filestat(f, st);
801059bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c2:	83 ec 08             	sub    $0x8,%esp
801059c5:	52                   	push   %edx
801059c6:	50                   	push   %eax
801059c7:	e8 9a b7 ff ff       	call   80101166 <filestat>
801059cc:	83 c4 10             	add    $0x10,%esp
}
801059cf:	c9                   	leave  
801059d0:	c3                   	ret    

801059d1 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059d1:	55                   	push   %ebp
801059d2:	89 e5                	mov    %esp,%ebp
801059d4:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059d7:	83 ec 08             	sub    $0x8,%esp
801059da:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059dd:	50                   	push   %eax
801059de:	6a 00                	push   $0x0
801059e0:	e8 a8 fc ff ff       	call   8010568d <argstr>
801059e5:	83 c4 10             	add    $0x10,%esp
801059e8:	85 c0                	test   %eax,%eax
801059ea:	78 15                	js     80105a01 <sys_link+0x30>
801059ec:	83 ec 08             	sub    $0x8,%esp
801059ef:	8d 45 dc             	lea    -0x24(%ebp),%eax
801059f2:	50                   	push   %eax
801059f3:	6a 01                	push   $0x1
801059f5:	e8 93 fc ff ff       	call   8010568d <argstr>
801059fa:	83 c4 10             	add    $0x10,%esp
801059fd:	85 c0                	test   %eax,%eax
801059ff:	79 0a                	jns    80105a0b <sys_link+0x3a>
    return -1;
80105a01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a06:	e9 68 01 00 00       	jmp    80105b73 <sys_link+0x1a2>

  begin_op();
80105a0b:	e8 5c db ff ff       	call   8010356c <begin_op>
  if((ip = namei(old)) == 0){
80105a10:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a13:	83 ec 0c             	sub    $0xc,%esp
80105a16:	50                   	push   %eax
80105a17:	e8 2c cb ff ff       	call   80102548 <namei>
80105a1c:	83 c4 10             	add    $0x10,%esp
80105a1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a22:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a26:	75 0f                	jne    80105a37 <sys_link+0x66>
    end_op();
80105a28:	e8 cb db ff ff       	call   801035f8 <end_op>
    return -1;
80105a2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a32:	e9 3c 01 00 00       	jmp    80105b73 <sys_link+0x1a2>
  }

  ilock(ip);
80105a37:	83 ec 0c             	sub    $0xc,%esp
80105a3a:	ff 75 f4             	pushl  -0xc(%ebp)
80105a3d:	e8 55 bf ff ff       	call   80101997 <ilock>
80105a42:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a48:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a4c:	66 83 f8 01          	cmp    $0x1,%ax
80105a50:	75 1d                	jne    80105a6f <sys_link+0x9e>
    iunlockput(ip);
80105a52:	83 ec 0c             	sub    $0xc,%esp
80105a55:	ff 75 f4             	pushl  -0xc(%ebp)
80105a58:	e8 fa c1 ff ff       	call   80101c57 <iunlockput>
80105a5d:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a60:	e8 93 db ff ff       	call   801035f8 <end_op>
    return -1;
80105a65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a6a:	e9 04 01 00 00       	jmp    80105b73 <sys_link+0x1a2>
  }

  ip->nlink++;
80105a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a72:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a76:	83 c0 01             	add    $0x1,%eax
80105a79:	89 c2                	mov    %eax,%edx
80105a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7e:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105a82:	83 ec 0c             	sub    $0xc,%esp
80105a85:	ff 75 f4             	pushl  -0xc(%ebp)
80105a88:	e8 30 bd ff ff       	call   801017bd <iupdate>
80105a8d:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105a90:	83 ec 0c             	sub    $0xc,%esp
80105a93:	ff 75 f4             	pushl  -0xc(%ebp)
80105a96:	e8 5a c0 ff ff       	call   80101af5 <iunlock>
80105a9b:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105a9e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105aa1:	83 ec 08             	sub    $0x8,%esp
80105aa4:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105aa7:	52                   	push   %edx
80105aa8:	50                   	push   %eax
80105aa9:	e8 b6 ca ff ff       	call   80102564 <nameiparent>
80105aae:	83 c4 10             	add    $0x10,%esp
80105ab1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ab4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ab8:	74 71                	je     80105b2b <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105aba:	83 ec 0c             	sub    $0xc,%esp
80105abd:	ff 75 f0             	pushl  -0x10(%ebp)
80105ac0:	e8 d2 be ff ff       	call   80101997 <ilock>
80105ac5:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105acb:	8b 10                	mov    (%eax),%edx
80105acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad0:	8b 00                	mov    (%eax),%eax
80105ad2:	39 c2                	cmp    %eax,%edx
80105ad4:	75 1d                	jne    80105af3 <sys_link+0x122>
80105ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad9:	8b 40 04             	mov    0x4(%eax),%eax
80105adc:	83 ec 04             	sub    $0x4,%esp
80105adf:	50                   	push   %eax
80105ae0:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ae3:	50                   	push   %eax
80105ae4:	ff 75 f0             	pushl  -0x10(%ebp)
80105ae7:	e8 c4 c7 ff ff       	call   801022b0 <dirlink>
80105aec:	83 c4 10             	add    $0x10,%esp
80105aef:	85 c0                	test   %eax,%eax
80105af1:	79 10                	jns    80105b03 <sys_link+0x132>
    iunlockput(dp);
80105af3:	83 ec 0c             	sub    $0xc,%esp
80105af6:	ff 75 f0             	pushl  -0x10(%ebp)
80105af9:	e8 59 c1 ff ff       	call   80101c57 <iunlockput>
80105afe:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105b01:	eb 29                	jmp    80105b2c <sys_link+0x15b>
  }
  iunlockput(dp);
80105b03:	83 ec 0c             	sub    $0xc,%esp
80105b06:	ff 75 f0             	pushl  -0x10(%ebp)
80105b09:	e8 49 c1 ff ff       	call   80101c57 <iunlockput>
80105b0e:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105b11:	83 ec 0c             	sub    $0xc,%esp
80105b14:	ff 75 f4             	pushl  -0xc(%ebp)
80105b17:	e8 4b c0 ff ff       	call   80101b67 <iput>
80105b1c:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b1f:	e8 d4 da ff ff       	call   801035f8 <end_op>

  return 0;
80105b24:	b8 00 00 00 00       	mov    $0x0,%eax
80105b29:	eb 48                	jmp    80105b73 <sys_link+0x1a2>
    goto bad;
80105b2b:	90                   	nop

bad:
  ilock(ip);
80105b2c:	83 ec 0c             	sub    $0xc,%esp
80105b2f:	ff 75 f4             	pushl  -0xc(%ebp)
80105b32:	e8 60 be ff ff       	call   80101997 <ilock>
80105b37:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b3d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b41:	83 e8 01             	sub    $0x1,%eax
80105b44:	89 c2                	mov    %eax,%edx
80105b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b49:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b4d:	83 ec 0c             	sub    $0xc,%esp
80105b50:	ff 75 f4             	pushl  -0xc(%ebp)
80105b53:	e8 65 bc ff ff       	call   801017bd <iupdate>
80105b58:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b5b:	83 ec 0c             	sub    $0xc,%esp
80105b5e:	ff 75 f4             	pushl  -0xc(%ebp)
80105b61:	e8 f1 c0 ff ff       	call   80101c57 <iunlockput>
80105b66:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b69:	e8 8a da ff ff       	call   801035f8 <end_op>
  return -1;
80105b6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b73:	c9                   	leave  
80105b74:	c3                   	ret    

80105b75 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b75:	55                   	push   %ebp
80105b76:	89 e5                	mov    %esp,%ebp
80105b78:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b7b:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b82:	eb 40                	jmp    80105bc4 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b87:	6a 10                	push   $0x10
80105b89:	50                   	push   %eax
80105b8a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b8d:	50                   	push   %eax
80105b8e:	ff 75 08             	pushl  0x8(%ebp)
80105b91:	e8 6a c3 ff ff       	call   80101f00 <readi>
80105b96:	83 c4 10             	add    $0x10,%esp
80105b99:	83 f8 10             	cmp    $0x10,%eax
80105b9c:	74 0d                	je     80105bab <isdirempty+0x36>
      panic("isdirempty: readi");
80105b9e:	83 ec 0c             	sub    $0xc,%esp
80105ba1:	68 88 8a 10 80       	push   $0x80108a88
80105ba6:	e8 d0 a9 ff ff       	call   8010057b <panic>
    if(de.inum != 0)
80105bab:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105baf:	66 85 c0             	test   %ax,%ax
80105bb2:	74 07                	je     80105bbb <isdirempty+0x46>
      return 0;
80105bb4:	b8 00 00 00 00       	mov    $0x0,%eax
80105bb9:	eb 1b                	jmp    80105bd6 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bbe:	83 c0 10             	add    $0x10,%eax
80105bc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80105bc7:	8b 50 18             	mov    0x18(%eax),%edx
80105bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bcd:	39 c2                	cmp    %eax,%edx
80105bcf:	77 b3                	ja     80105b84 <isdirempty+0xf>
  }
  return 1;
80105bd1:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bd6:	c9                   	leave  
80105bd7:	c3                   	ret    

80105bd8 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105bd8:	55                   	push   %ebp
80105bd9:	89 e5                	mov    %esp,%ebp
80105bdb:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bde:	83 ec 08             	sub    $0x8,%esp
80105be1:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105be4:	50                   	push   %eax
80105be5:	6a 00                	push   $0x0
80105be7:	e8 a1 fa ff ff       	call   8010568d <argstr>
80105bec:	83 c4 10             	add    $0x10,%esp
80105bef:	85 c0                	test   %eax,%eax
80105bf1:	79 0a                	jns    80105bfd <sys_unlink+0x25>
    return -1;
80105bf3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf8:	e9 bf 01 00 00       	jmp    80105dbc <sys_unlink+0x1e4>

  begin_op();
80105bfd:	e8 6a d9 ff ff       	call   8010356c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c02:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c05:	83 ec 08             	sub    $0x8,%esp
80105c08:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c0b:	52                   	push   %edx
80105c0c:	50                   	push   %eax
80105c0d:	e8 52 c9 ff ff       	call   80102564 <nameiparent>
80105c12:	83 c4 10             	add    $0x10,%esp
80105c15:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c18:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c1c:	75 0f                	jne    80105c2d <sys_unlink+0x55>
    end_op();
80105c1e:	e8 d5 d9 ff ff       	call   801035f8 <end_op>
    return -1;
80105c23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c28:	e9 8f 01 00 00       	jmp    80105dbc <sys_unlink+0x1e4>
  }

  ilock(dp);
80105c2d:	83 ec 0c             	sub    $0xc,%esp
80105c30:	ff 75 f4             	pushl  -0xc(%ebp)
80105c33:	e8 5f bd ff ff       	call   80101997 <ilock>
80105c38:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c3b:	83 ec 08             	sub    $0x8,%esp
80105c3e:	68 9a 8a 10 80       	push   $0x80108a9a
80105c43:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c46:	50                   	push   %eax
80105c47:	e8 8f c5 ff ff       	call   801021db <namecmp>
80105c4c:	83 c4 10             	add    $0x10,%esp
80105c4f:	85 c0                	test   %eax,%eax
80105c51:	0f 84 49 01 00 00    	je     80105da0 <sys_unlink+0x1c8>
80105c57:	83 ec 08             	sub    $0x8,%esp
80105c5a:	68 9c 8a 10 80       	push   $0x80108a9c
80105c5f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c62:	50                   	push   %eax
80105c63:	e8 73 c5 ff ff       	call   801021db <namecmp>
80105c68:	83 c4 10             	add    $0x10,%esp
80105c6b:	85 c0                	test   %eax,%eax
80105c6d:	0f 84 2d 01 00 00    	je     80105da0 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c73:	83 ec 04             	sub    $0x4,%esp
80105c76:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c79:	50                   	push   %eax
80105c7a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c7d:	50                   	push   %eax
80105c7e:	ff 75 f4             	pushl  -0xc(%ebp)
80105c81:	e8 70 c5 ff ff       	call   801021f6 <dirlookup>
80105c86:	83 c4 10             	add    $0x10,%esp
80105c89:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c8c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c90:	0f 84 0d 01 00 00    	je     80105da3 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105c96:	83 ec 0c             	sub    $0xc,%esp
80105c99:	ff 75 f0             	pushl  -0x10(%ebp)
80105c9c:	e8 f6 bc ff ff       	call   80101997 <ilock>
80105ca1:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105cab:	66 85 c0             	test   %ax,%ax
80105cae:	7f 0d                	jg     80105cbd <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105cb0:	83 ec 0c             	sub    $0xc,%esp
80105cb3:	68 9f 8a 10 80       	push   $0x80108a9f
80105cb8:	e8 be a8 ff ff       	call   8010057b <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105cbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105cc4:	66 83 f8 01          	cmp    $0x1,%ax
80105cc8:	75 25                	jne    80105cef <sys_unlink+0x117>
80105cca:	83 ec 0c             	sub    $0xc,%esp
80105ccd:	ff 75 f0             	pushl  -0x10(%ebp)
80105cd0:	e8 a0 fe ff ff       	call   80105b75 <isdirempty>
80105cd5:	83 c4 10             	add    $0x10,%esp
80105cd8:	85 c0                	test   %eax,%eax
80105cda:	75 13                	jne    80105cef <sys_unlink+0x117>
    iunlockput(ip);
80105cdc:	83 ec 0c             	sub    $0xc,%esp
80105cdf:	ff 75 f0             	pushl  -0x10(%ebp)
80105ce2:	e8 70 bf ff ff       	call   80101c57 <iunlockput>
80105ce7:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105cea:	e9 b5 00 00 00       	jmp    80105da4 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105cef:	83 ec 04             	sub    $0x4,%esp
80105cf2:	6a 10                	push   $0x10
80105cf4:	6a 00                	push   $0x0
80105cf6:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cf9:	50                   	push   %eax
80105cfa:	e8 e6 f5 ff ff       	call   801052e5 <memset>
80105cff:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d02:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d05:	6a 10                	push   $0x10
80105d07:	50                   	push   %eax
80105d08:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d0b:	50                   	push   %eax
80105d0c:	ff 75 f4             	pushl  -0xc(%ebp)
80105d0f:	e8 41 c3 ff ff       	call   80102055 <writei>
80105d14:	83 c4 10             	add    $0x10,%esp
80105d17:	83 f8 10             	cmp    $0x10,%eax
80105d1a:	74 0d                	je     80105d29 <sys_unlink+0x151>
    panic("unlink: writei");
80105d1c:	83 ec 0c             	sub    $0xc,%esp
80105d1f:	68 b1 8a 10 80       	push   $0x80108ab1
80105d24:	e8 52 a8 ff ff       	call   8010057b <panic>
  if(ip->type == T_DIR){
80105d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d2c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d30:	66 83 f8 01          	cmp    $0x1,%ax
80105d34:	75 21                	jne    80105d57 <sys_unlink+0x17f>
    dp->nlink--;
80105d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d39:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d3d:	83 e8 01             	sub    $0x1,%eax
80105d40:	89 c2                	mov    %eax,%edx
80105d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d45:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d49:	83 ec 0c             	sub    $0xc,%esp
80105d4c:	ff 75 f4             	pushl  -0xc(%ebp)
80105d4f:	e8 69 ba ff ff       	call   801017bd <iupdate>
80105d54:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105d57:	83 ec 0c             	sub    $0xc,%esp
80105d5a:	ff 75 f4             	pushl  -0xc(%ebp)
80105d5d:	e8 f5 be ff ff       	call   80101c57 <iunlockput>
80105d62:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105d65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d68:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d6c:	83 e8 01             	sub    $0x1,%eax
80105d6f:	89 c2                	mov    %eax,%edx
80105d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d74:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d78:	83 ec 0c             	sub    $0xc,%esp
80105d7b:	ff 75 f0             	pushl  -0x10(%ebp)
80105d7e:	e8 3a ba ff ff       	call   801017bd <iupdate>
80105d83:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d86:	83 ec 0c             	sub    $0xc,%esp
80105d89:	ff 75 f0             	pushl  -0x10(%ebp)
80105d8c:	e8 c6 be ff ff       	call   80101c57 <iunlockput>
80105d91:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d94:	e8 5f d8 ff ff       	call   801035f8 <end_op>

  return 0;
80105d99:	b8 00 00 00 00       	mov    $0x0,%eax
80105d9e:	eb 1c                	jmp    80105dbc <sys_unlink+0x1e4>
    goto bad;
80105da0:	90                   	nop
80105da1:	eb 01                	jmp    80105da4 <sys_unlink+0x1cc>
    goto bad;
80105da3:	90                   	nop

bad:
  iunlockput(dp);
80105da4:	83 ec 0c             	sub    $0xc,%esp
80105da7:	ff 75 f4             	pushl  -0xc(%ebp)
80105daa:	e8 a8 be ff ff       	call   80101c57 <iunlockput>
80105daf:	83 c4 10             	add    $0x10,%esp
  end_op();
80105db2:	e8 41 d8 ff ff       	call   801035f8 <end_op>
  return -1;
80105db7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105dbc:	c9                   	leave  
80105dbd:	c3                   	ret    

80105dbe <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105dbe:	55                   	push   %ebp
80105dbf:	89 e5                	mov    %esp,%ebp
80105dc1:	83 ec 38             	sub    $0x38,%esp
80105dc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105dc7:	8b 55 10             	mov    0x10(%ebp),%edx
80105dca:	8b 45 14             	mov    0x14(%ebp),%eax
80105dcd:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105dd1:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105dd5:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105dd9:	83 ec 08             	sub    $0x8,%esp
80105ddc:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ddf:	50                   	push   %eax
80105de0:	ff 75 08             	pushl  0x8(%ebp)
80105de3:	e8 7c c7 ff ff       	call   80102564 <nameiparent>
80105de8:	83 c4 10             	add    $0x10,%esp
80105deb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105df2:	75 0a                	jne    80105dfe <create+0x40>
    return 0;
80105df4:	b8 00 00 00 00       	mov    $0x0,%eax
80105df9:	e9 90 01 00 00       	jmp    80105f8e <create+0x1d0>
  ilock(dp);
80105dfe:	83 ec 0c             	sub    $0xc,%esp
80105e01:	ff 75 f4             	pushl  -0xc(%ebp)
80105e04:	e8 8e bb ff ff       	call   80101997 <ilock>
80105e09:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105e0c:	83 ec 04             	sub    $0x4,%esp
80105e0f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e12:	50                   	push   %eax
80105e13:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e16:	50                   	push   %eax
80105e17:	ff 75 f4             	pushl  -0xc(%ebp)
80105e1a:	e8 d7 c3 ff ff       	call   801021f6 <dirlookup>
80105e1f:	83 c4 10             	add    $0x10,%esp
80105e22:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e29:	74 50                	je     80105e7b <create+0xbd>
    iunlockput(dp);
80105e2b:	83 ec 0c             	sub    $0xc,%esp
80105e2e:	ff 75 f4             	pushl  -0xc(%ebp)
80105e31:	e8 21 be ff ff       	call   80101c57 <iunlockput>
80105e36:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105e39:	83 ec 0c             	sub    $0xc,%esp
80105e3c:	ff 75 f0             	pushl  -0x10(%ebp)
80105e3f:	e8 53 bb ff ff       	call   80101997 <ilock>
80105e44:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105e47:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e4c:	75 15                	jne    80105e63 <create+0xa5>
80105e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e51:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e55:	66 83 f8 02          	cmp    $0x2,%ax
80105e59:	75 08                	jne    80105e63 <create+0xa5>
      return ip;
80105e5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e5e:	e9 2b 01 00 00       	jmp    80105f8e <create+0x1d0>
    iunlockput(ip);
80105e63:	83 ec 0c             	sub    $0xc,%esp
80105e66:	ff 75 f0             	pushl  -0x10(%ebp)
80105e69:	e8 e9 bd ff ff       	call   80101c57 <iunlockput>
80105e6e:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e71:	b8 00 00 00 00       	mov    $0x0,%eax
80105e76:	e9 13 01 00 00       	jmp    80105f8e <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e7b:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e82:	8b 00                	mov    (%eax),%eax
80105e84:	83 ec 08             	sub    $0x8,%esp
80105e87:	52                   	push   %edx
80105e88:	50                   	push   %eax
80105e89:	e8 58 b8 ff ff       	call   801016e6 <ialloc>
80105e8e:	83 c4 10             	add    $0x10,%esp
80105e91:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e94:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e98:	75 0d                	jne    80105ea7 <create+0xe9>
    panic("create: ialloc");
80105e9a:	83 ec 0c             	sub    $0xc,%esp
80105e9d:	68 c0 8a 10 80       	push   $0x80108ac0
80105ea2:	e8 d4 a6 ff ff       	call   8010057b <panic>

  ilock(ip);
80105ea7:	83 ec 0c             	sub    $0xc,%esp
80105eaa:	ff 75 f0             	pushl  -0x10(%ebp)
80105ead:	e8 e5 ba ff ff       	call   80101997 <ilock>
80105eb2:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb8:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105ebc:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec3:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105ec7:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ece:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105ed4:	83 ec 0c             	sub    $0xc,%esp
80105ed7:	ff 75 f0             	pushl  -0x10(%ebp)
80105eda:	e8 de b8 ff ff       	call   801017bd <iupdate>
80105edf:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105ee2:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105ee7:	75 6a                	jne    80105f53 <create+0x195>
    dp->nlink++;  // for ".."
80105ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eec:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ef0:	83 c0 01             	add    $0x1,%eax
80105ef3:	89 c2                	mov    %eax,%edx
80105ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef8:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105efc:	83 ec 0c             	sub    $0xc,%esp
80105eff:	ff 75 f4             	pushl  -0xc(%ebp)
80105f02:	e8 b6 b8 ff ff       	call   801017bd <iupdate>
80105f07:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105f0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0d:	8b 40 04             	mov    0x4(%eax),%eax
80105f10:	83 ec 04             	sub    $0x4,%esp
80105f13:	50                   	push   %eax
80105f14:	68 9a 8a 10 80       	push   $0x80108a9a
80105f19:	ff 75 f0             	pushl  -0x10(%ebp)
80105f1c:	e8 8f c3 ff ff       	call   801022b0 <dirlink>
80105f21:	83 c4 10             	add    $0x10,%esp
80105f24:	85 c0                	test   %eax,%eax
80105f26:	78 1e                	js     80105f46 <create+0x188>
80105f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2b:	8b 40 04             	mov    0x4(%eax),%eax
80105f2e:	83 ec 04             	sub    $0x4,%esp
80105f31:	50                   	push   %eax
80105f32:	68 9c 8a 10 80       	push   $0x80108a9c
80105f37:	ff 75 f0             	pushl  -0x10(%ebp)
80105f3a:	e8 71 c3 ff ff       	call   801022b0 <dirlink>
80105f3f:	83 c4 10             	add    $0x10,%esp
80105f42:	85 c0                	test   %eax,%eax
80105f44:	79 0d                	jns    80105f53 <create+0x195>
      panic("create dots");
80105f46:	83 ec 0c             	sub    $0xc,%esp
80105f49:	68 cf 8a 10 80       	push   $0x80108acf
80105f4e:	e8 28 a6 ff ff       	call   8010057b <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f56:	8b 40 04             	mov    0x4(%eax),%eax
80105f59:	83 ec 04             	sub    $0x4,%esp
80105f5c:	50                   	push   %eax
80105f5d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f60:	50                   	push   %eax
80105f61:	ff 75 f4             	pushl  -0xc(%ebp)
80105f64:	e8 47 c3 ff ff       	call   801022b0 <dirlink>
80105f69:	83 c4 10             	add    $0x10,%esp
80105f6c:	85 c0                	test   %eax,%eax
80105f6e:	79 0d                	jns    80105f7d <create+0x1bf>
    panic("create: dirlink");
80105f70:	83 ec 0c             	sub    $0xc,%esp
80105f73:	68 db 8a 10 80       	push   $0x80108adb
80105f78:	e8 fe a5 ff ff       	call   8010057b <panic>

  iunlockput(dp);
80105f7d:	83 ec 0c             	sub    $0xc,%esp
80105f80:	ff 75 f4             	pushl  -0xc(%ebp)
80105f83:	e8 cf bc ff ff       	call   80101c57 <iunlockput>
80105f88:	83 c4 10             	add    $0x10,%esp

  return ip;
80105f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f8e:	c9                   	leave  
80105f8f:	c3                   	ret    

80105f90 <sys_open>:

int
sys_open(void)
{
80105f90:	55                   	push   %ebp
80105f91:	89 e5                	mov    %esp,%ebp
80105f93:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f96:	83 ec 08             	sub    $0x8,%esp
80105f99:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f9c:	50                   	push   %eax
80105f9d:	6a 00                	push   $0x0
80105f9f:	e8 e9 f6 ff ff       	call   8010568d <argstr>
80105fa4:	83 c4 10             	add    $0x10,%esp
80105fa7:	85 c0                	test   %eax,%eax
80105fa9:	78 15                	js     80105fc0 <sys_open+0x30>
80105fab:	83 ec 08             	sub    $0x8,%esp
80105fae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fb1:	50                   	push   %eax
80105fb2:	6a 01                	push   $0x1
80105fb4:	e8 4f f6 ff ff       	call   80105608 <argint>
80105fb9:	83 c4 10             	add    $0x10,%esp
80105fbc:	85 c0                	test   %eax,%eax
80105fbe:	79 0a                	jns    80105fca <sys_open+0x3a>
    return -1;
80105fc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc5:	e9 61 01 00 00       	jmp    8010612b <sys_open+0x19b>

  begin_op();
80105fca:	e8 9d d5 ff ff       	call   8010356c <begin_op>

  if(omode & O_CREATE){
80105fcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fd2:	25 00 02 00 00       	and    $0x200,%eax
80105fd7:	85 c0                	test   %eax,%eax
80105fd9:	74 2a                	je     80106005 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105fdb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fde:	6a 00                	push   $0x0
80105fe0:	6a 00                	push   $0x0
80105fe2:	6a 02                	push   $0x2
80105fe4:	50                   	push   %eax
80105fe5:	e8 d4 fd ff ff       	call   80105dbe <create>
80105fea:	83 c4 10             	add    $0x10,%esp
80105fed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105ff0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ff4:	75 75                	jne    8010606b <sys_open+0xdb>
      end_op();
80105ff6:	e8 fd d5 ff ff       	call   801035f8 <end_op>
      return -1;
80105ffb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106000:	e9 26 01 00 00       	jmp    8010612b <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106005:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106008:	83 ec 0c             	sub    $0xc,%esp
8010600b:	50                   	push   %eax
8010600c:	e8 37 c5 ff ff       	call   80102548 <namei>
80106011:	83 c4 10             	add    $0x10,%esp
80106014:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106017:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010601b:	75 0f                	jne    8010602c <sys_open+0x9c>
      end_op();
8010601d:	e8 d6 d5 ff ff       	call   801035f8 <end_op>
      return -1;
80106022:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106027:	e9 ff 00 00 00       	jmp    8010612b <sys_open+0x19b>
    }
    ilock(ip);
8010602c:	83 ec 0c             	sub    $0xc,%esp
8010602f:	ff 75 f4             	pushl  -0xc(%ebp)
80106032:	e8 60 b9 ff ff       	call   80101997 <ilock>
80106037:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010603a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106041:	66 83 f8 01          	cmp    $0x1,%ax
80106045:	75 24                	jne    8010606b <sys_open+0xdb>
80106047:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010604a:	85 c0                	test   %eax,%eax
8010604c:	74 1d                	je     8010606b <sys_open+0xdb>
      iunlockput(ip);
8010604e:	83 ec 0c             	sub    $0xc,%esp
80106051:	ff 75 f4             	pushl  -0xc(%ebp)
80106054:	e8 fe bb ff ff       	call   80101c57 <iunlockput>
80106059:	83 c4 10             	add    $0x10,%esp
      end_op();
8010605c:	e8 97 d5 ff ff       	call   801035f8 <end_op>
      return -1;
80106061:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106066:	e9 c0 00 00 00       	jmp    8010612b <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010606b:	e8 50 af ff ff       	call   80100fc0 <filealloc>
80106070:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106073:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106077:	74 17                	je     80106090 <sys_open+0x100>
80106079:	83 ec 0c             	sub    $0xc,%esp
8010607c:	ff 75 f0             	pushl  -0x10(%ebp)
8010607f:	e8 34 f7 ff ff       	call   801057b8 <fdalloc>
80106084:	83 c4 10             	add    $0x10,%esp
80106087:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010608a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010608e:	79 2e                	jns    801060be <sys_open+0x12e>
    if(f)
80106090:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106094:	74 0e                	je     801060a4 <sys_open+0x114>
      fileclose(f);
80106096:	83 ec 0c             	sub    $0xc,%esp
80106099:	ff 75 f0             	pushl  -0x10(%ebp)
8010609c:	e8 dd af ff ff       	call   8010107e <fileclose>
801060a1:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801060a4:	83 ec 0c             	sub    $0xc,%esp
801060a7:	ff 75 f4             	pushl  -0xc(%ebp)
801060aa:	e8 a8 bb ff ff       	call   80101c57 <iunlockput>
801060af:	83 c4 10             	add    $0x10,%esp
    end_op();
801060b2:	e8 41 d5 ff ff       	call   801035f8 <end_op>
    return -1;
801060b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060bc:	eb 6d                	jmp    8010612b <sys_open+0x19b>
  }
  iunlock(ip);
801060be:	83 ec 0c             	sub    $0xc,%esp
801060c1:	ff 75 f4             	pushl  -0xc(%ebp)
801060c4:	e8 2c ba ff ff       	call   80101af5 <iunlock>
801060c9:	83 c4 10             	add    $0x10,%esp
  end_op();
801060cc:	e8 27 d5 ff ff       	call   801035f8 <end_op>

  f->type = FD_INODE;
801060d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d4:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801060da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060e0:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060f0:	83 e0 01             	and    $0x1,%eax
801060f3:	85 c0                	test   %eax,%eax
801060f5:	0f 94 c0             	sete   %al
801060f8:	89 c2                	mov    %eax,%edx
801060fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060fd:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106100:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106103:	83 e0 01             	and    $0x1,%eax
80106106:	85 c0                	test   %eax,%eax
80106108:	75 0a                	jne    80106114 <sys_open+0x184>
8010610a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010610d:	83 e0 02             	and    $0x2,%eax
80106110:	85 c0                	test   %eax,%eax
80106112:	74 07                	je     8010611b <sys_open+0x18b>
80106114:	b8 01 00 00 00       	mov    $0x1,%eax
80106119:	eb 05                	jmp    80106120 <sys_open+0x190>
8010611b:	b8 00 00 00 00       	mov    $0x0,%eax
80106120:	89 c2                	mov    %eax,%edx
80106122:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106125:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106128:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010612b:	c9                   	leave  
8010612c:	c3                   	ret    

8010612d <sys_mkdir>:

int
sys_mkdir(void)
{
8010612d:	55                   	push   %ebp
8010612e:	89 e5                	mov    %esp,%ebp
80106130:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106133:	e8 34 d4 ff ff       	call   8010356c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106138:	83 ec 08             	sub    $0x8,%esp
8010613b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010613e:	50                   	push   %eax
8010613f:	6a 00                	push   $0x0
80106141:	e8 47 f5 ff ff       	call   8010568d <argstr>
80106146:	83 c4 10             	add    $0x10,%esp
80106149:	85 c0                	test   %eax,%eax
8010614b:	78 1b                	js     80106168 <sys_mkdir+0x3b>
8010614d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106150:	6a 00                	push   $0x0
80106152:	6a 00                	push   $0x0
80106154:	6a 01                	push   $0x1
80106156:	50                   	push   %eax
80106157:	e8 62 fc ff ff       	call   80105dbe <create>
8010615c:	83 c4 10             	add    $0x10,%esp
8010615f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106162:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106166:	75 0c                	jne    80106174 <sys_mkdir+0x47>
    end_op();
80106168:	e8 8b d4 ff ff       	call   801035f8 <end_op>
    return -1;
8010616d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106172:	eb 18                	jmp    8010618c <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106174:	83 ec 0c             	sub    $0xc,%esp
80106177:	ff 75 f4             	pushl  -0xc(%ebp)
8010617a:	e8 d8 ba ff ff       	call   80101c57 <iunlockput>
8010617f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106182:	e8 71 d4 ff ff       	call   801035f8 <end_op>
  return 0;
80106187:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010618c:	c9                   	leave  
8010618d:	c3                   	ret    

8010618e <sys_mknod>:

int
sys_mknod(void)
{
8010618e:	55                   	push   %ebp
8010618f:	89 e5                	mov    %esp,%ebp
80106191:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106194:	e8 d3 d3 ff ff       	call   8010356c <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106199:	83 ec 08             	sub    $0x8,%esp
8010619c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010619f:	50                   	push   %eax
801061a0:	6a 00                	push   $0x0
801061a2:	e8 e6 f4 ff ff       	call   8010568d <argstr>
801061a7:	83 c4 10             	add    $0x10,%esp
801061aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061b1:	78 4f                	js     80106202 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
801061b3:	83 ec 08             	sub    $0x8,%esp
801061b6:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061b9:	50                   	push   %eax
801061ba:	6a 01                	push   $0x1
801061bc:	e8 47 f4 ff ff       	call   80105608 <argint>
801061c1:	83 c4 10             	add    $0x10,%esp
  if((len=argstr(0, &path)) < 0 ||
801061c4:	85 c0                	test   %eax,%eax
801061c6:	78 3a                	js     80106202 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
801061c8:	83 ec 08             	sub    $0x8,%esp
801061cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061ce:	50                   	push   %eax
801061cf:	6a 02                	push   $0x2
801061d1:	e8 32 f4 ff ff       	call   80105608 <argint>
801061d6:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801061d9:	85 c0                	test   %eax,%eax
801061db:	78 25                	js     80106202 <sys_mknod+0x74>
     (ip = create(path, T_DEV, major, minor)) == 0){
801061dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061e0:	0f bf c8             	movswl %ax,%ecx
801061e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061e6:	0f bf d0             	movswl %ax,%edx
801061e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061ec:	51                   	push   %ecx
801061ed:	52                   	push   %edx
801061ee:	6a 03                	push   $0x3
801061f0:	50                   	push   %eax
801061f1:	e8 c8 fb ff ff       	call   80105dbe <create>
801061f6:	83 c4 10             	add    $0x10,%esp
801061f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
     argint(2, &minor) < 0 ||
801061fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106200:	75 0c                	jne    8010620e <sys_mknod+0x80>
    end_op();
80106202:	e8 f1 d3 ff ff       	call   801035f8 <end_op>
    return -1;
80106207:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010620c:	eb 18                	jmp    80106226 <sys_mknod+0x98>
  }
  iunlockput(ip);
8010620e:	83 ec 0c             	sub    $0xc,%esp
80106211:	ff 75 f0             	pushl  -0x10(%ebp)
80106214:	e8 3e ba ff ff       	call   80101c57 <iunlockput>
80106219:	83 c4 10             	add    $0x10,%esp
  end_op();
8010621c:	e8 d7 d3 ff ff       	call   801035f8 <end_op>
  return 0;
80106221:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106226:	c9                   	leave  
80106227:	c3                   	ret    

80106228 <sys_chdir>:

int
sys_chdir(void)
{
80106228:	55                   	push   %ebp
80106229:	89 e5                	mov    %esp,%ebp
8010622b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010622e:	e8 39 d3 ff ff       	call   8010356c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106233:	83 ec 08             	sub    $0x8,%esp
80106236:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106239:	50                   	push   %eax
8010623a:	6a 00                	push   $0x0
8010623c:	e8 4c f4 ff ff       	call   8010568d <argstr>
80106241:	83 c4 10             	add    $0x10,%esp
80106244:	85 c0                	test   %eax,%eax
80106246:	78 18                	js     80106260 <sys_chdir+0x38>
80106248:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010624b:	83 ec 0c             	sub    $0xc,%esp
8010624e:	50                   	push   %eax
8010624f:	e8 f4 c2 ff ff       	call   80102548 <namei>
80106254:	83 c4 10             	add    $0x10,%esp
80106257:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010625a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010625e:	75 0c                	jne    8010626c <sys_chdir+0x44>
    end_op();
80106260:	e8 93 d3 ff ff       	call   801035f8 <end_op>
    return -1;
80106265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010626a:	eb 6e                	jmp    801062da <sys_chdir+0xb2>
  }
  ilock(ip);
8010626c:	83 ec 0c             	sub    $0xc,%esp
8010626f:	ff 75 f4             	pushl  -0xc(%ebp)
80106272:	e8 20 b7 ff ff       	call   80101997 <ilock>
80106277:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010627a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106281:	66 83 f8 01          	cmp    $0x1,%ax
80106285:	74 1a                	je     801062a1 <sys_chdir+0x79>
    iunlockput(ip);
80106287:	83 ec 0c             	sub    $0xc,%esp
8010628a:	ff 75 f4             	pushl  -0xc(%ebp)
8010628d:	e8 c5 b9 ff ff       	call   80101c57 <iunlockput>
80106292:	83 c4 10             	add    $0x10,%esp
    end_op();
80106295:	e8 5e d3 ff ff       	call   801035f8 <end_op>
    return -1;
8010629a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010629f:	eb 39                	jmp    801062da <sys_chdir+0xb2>
  }
  iunlock(ip);
801062a1:	83 ec 0c             	sub    $0xc,%esp
801062a4:	ff 75 f4             	pushl  -0xc(%ebp)
801062a7:	e8 49 b8 ff ff       	call   80101af5 <iunlock>
801062ac:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
801062af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062b5:	8b 40 68             	mov    0x68(%eax),%eax
801062b8:	83 ec 0c             	sub    $0xc,%esp
801062bb:	50                   	push   %eax
801062bc:	e8 a6 b8 ff ff       	call   80101b67 <iput>
801062c1:	83 c4 10             	add    $0x10,%esp
  end_op();
801062c4:	e8 2f d3 ff ff       	call   801035f8 <end_op>
  proc->cwd = ip;
801062c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062d2:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801062d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062da:	c9                   	leave  
801062db:	c3                   	ret    

801062dc <sys_exec>:

int
sys_exec(void)
{
801062dc:	55                   	push   %ebp
801062dd:	89 e5                	mov    %esp,%ebp
801062df:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062e5:	83 ec 08             	sub    $0x8,%esp
801062e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062eb:	50                   	push   %eax
801062ec:	6a 00                	push   $0x0
801062ee:	e8 9a f3 ff ff       	call   8010568d <argstr>
801062f3:	83 c4 10             	add    $0x10,%esp
801062f6:	85 c0                	test   %eax,%eax
801062f8:	78 18                	js     80106312 <sys_exec+0x36>
801062fa:	83 ec 08             	sub    $0x8,%esp
801062fd:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106303:	50                   	push   %eax
80106304:	6a 01                	push   $0x1
80106306:	e8 fd f2 ff ff       	call   80105608 <argint>
8010630b:	83 c4 10             	add    $0x10,%esp
8010630e:	85 c0                	test   %eax,%eax
80106310:	79 0a                	jns    8010631c <sys_exec+0x40>
    return -1;
80106312:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106317:	e9 c6 00 00 00       	jmp    801063e2 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010631c:	83 ec 04             	sub    $0x4,%esp
8010631f:	68 80 00 00 00       	push   $0x80
80106324:	6a 00                	push   $0x0
80106326:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010632c:	50                   	push   %eax
8010632d:	e8 b3 ef ff ff       	call   801052e5 <memset>
80106332:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106335:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010633c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633f:	83 f8 1f             	cmp    $0x1f,%eax
80106342:	76 0a                	jbe    8010634e <sys_exec+0x72>
      return -1;
80106344:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106349:	e9 94 00 00 00       	jmp    801063e2 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010634e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106351:	c1 e0 02             	shl    $0x2,%eax
80106354:	89 c2                	mov    %eax,%edx
80106356:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010635c:	01 c2                	add    %eax,%edx
8010635e:	83 ec 08             	sub    $0x8,%esp
80106361:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106367:	50                   	push   %eax
80106368:	52                   	push   %edx
80106369:	e8 00 f2 ff ff       	call   8010556e <fetchint>
8010636e:	83 c4 10             	add    $0x10,%esp
80106371:	85 c0                	test   %eax,%eax
80106373:	79 07                	jns    8010637c <sys_exec+0xa0>
      return -1;
80106375:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637a:	eb 66                	jmp    801063e2 <sys_exec+0x106>
    if(uarg == 0){
8010637c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106382:	85 c0                	test   %eax,%eax
80106384:	75 27                	jne    801063ad <sys_exec+0xd1>
      argv[i] = 0;
80106386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106389:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106390:	00 00 00 00 
      break;
80106394:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106395:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106398:	83 ec 08             	sub    $0x8,%esp
8010639b:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801063a1:	52                   	push   %edx
801063a2:	50                   	push   %eax
801063a3:	e8 f6 a7 ff ff       	call   80100b9e <exec>
801063a8:	83 c4 10             	add    $0x10,%esp
801063ab:	eb 35                	jmp    801063e2 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
801063ad:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801063b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b6:	c1 e0 02             	shl    $0x2,%eax
801063b9:	01 c2                	add    %eax,%edx
801063bb:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063c1:	83 ec 08             	sub    $0x8,%esp
801063c4:	52                   	push   %edx
801063c5:	50                   	push   %eax
801063c6:	e8 dd f1 ff ff       	call   801055a8 <fetchstr>
801063cb:	83 c4 10             	add    $0x10,%esp
801063ce:	85 c0                	test   %eax,%eax
801063d0:	79 07                	jns    801063d9 <sys_exec+0xfd>
      return -1;
801063d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d7:	eb 09                	jmp    801063e2 <sys_exec+0x106>
  for(i=0;; i++){
801063d9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801063dd:	e9 5a ff ff ff       	jmp    8010633c <sys_exec+0x60>
}
801063e2:	c9                   	leave  
801063e3:	c3                   	ret    

801063e4 <sys_pipe>:

int
sys_pipe(void)
{
801063e4:	55                   	push   %ebp
801063e5:	89 e5                	mov    %esp,%ebp
801063e7:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063ea:	83 ec 04             	sub    $0x4,%esp
801063ed:	6a 08                	push   $0x8
801063ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063f2:	50                   	push   %eax
801063f3:	6a 00                	push   $0x0
801063f5:	e8 36 f2 ff ff       	call   80105630 <argptr>
801063fa:	83 c4 10             	add    $0x10,%esp
801063fd:	85 c0                	test   %eax,%eax
801063ff:	79 0a                	jns    8010640b <sys_pipe+0x27>
    return -1;
80106401:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106406:	e9 af 00 00 00       	jmp    801064ba <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
8010640b:	83 ec 08             	sub    $0x8,%esp
8010640e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106411:	50                   	push   %eax
80106412:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106415:	50                   	push   %eax
80106416:	e8 63 dc ff ff       	call   8010407e <pipealloc>
8010641b:	83 c4 10             	add    $0x10,%esp
8010641e:	85 c0                	test   %eax,%eax
80106420:	79 0a                	jns    8010642c <sys_pipe+0x48>
    return -1;
80106422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106427:	e9 8e 00 00 00       	jmp    801064ba <sys_pipe+0xd6>
  fd0 = -1;
8010642c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106433:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106436:	83 ec 0c             	sub    $0xc,%esp
80106439:	50                   	push   %eax
8010643a:	e8 79 f3 ff ff       	call   801057b8 <fdalloc>
8010643f:	83 c4 10             	add    $0x10,%esp
80106442:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106445:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106449:	78 18                	js     80106463 <sys_pipe+0x7f>
8010644b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010644e:	83 ec 0c             	sub    $0xc,%esp
80106451:	50                   	push   %eax
80106452:	e8 61 f3 ff ff       	call   801057b8 <fdalloc>
80106457:	83 c4 10             	add    $0x10,%esp
8010645a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010645d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106461:	79 3f                	jns    801064a2 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106463:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106467:	78 14                	js     8010647d <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106469:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010646f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106472:	83 c2 08             	add    $0x8,%edx
80106475:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010647c:	00 
    fileclose(rf);
8010647d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106480:	83 ec 0c             	sub    $0xc,%esp
80106483:	50                   	push   %eax
80106484:	e8 f5 ab ff ff       	call   8010107e <fileclose>
80106489:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010648c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010648f:	83 ec 0c             	sub    $0xc,%esp
80106492:	50                   	push   %eax
80106493:	e8 e6 ab ff ff       	call   8010107e <fileclose>
80106498:	83 c4 10             	add    $0x10,%esp
    return -1;
8010649b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064a0:	eb 18                	jmp    801064ba <sys_pipe+0xd6>
  }
  fd[0] = fd0;
801064a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064a8:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801064aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064ad:	8d 50 04             	lea    0x4(%eax),%edx
801064b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064b3:	89 02                	mov    %eax,(%edx)
  return 0;
801064b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064ba:	c9                   	leave  
801064bb:	c3                   	ret    

801064bc <outw>:
{
801064bc:	55                   	push   %ebp
801064bd:	89 e5                	mov    %esp,%ebp
801064bf:	83 ec 08             	sub    $0x8,%esp
801064c2:	8b 55 08             	mov    0x8(%ebp),%edx
801064c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801064c8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801064cc:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801064d0:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
801064d4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801064d8:	66 ef                	out    %ax,(%dx)
}
801064da:	90                   	nop
801064db:	c9                   	leave  
801064dc:	c3                   	ret    

801064dd <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801064dd:	55                   	push   %ebp
801064de:	89 e5                	mov    %esp,%ebp
801064e0:	83 ec 08             	sub    $0x8,%esp
  return fork();
801064e3:	e8 8d e2 ff ff       	call   80104775 <fork>
}
801064e8:	c9                   	leave  
801064e9:	c3                   	ret    

801064ea <sys_exit>:

int
sys_exit(void)
{
801064ea:	55                   	push   %ebp
801064eb:	89 e5                	mov    %esp,%ebp
801064ed:	83 ec 08             	sub    $0x8,%esp
  exit();
801064f0:	e8 0d e4 ff ff       	call   80104902 <exit>
  return 0;  // not reached
801064f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064fa:	c9                   	leave  
801064fb:	c3                   	ret    

801064fc <sys_wait>:

int
sys_wait(void)
{
801064fc:	55                   	push   %ebp
801064fd:	89 e5                	mov    %esp,%ebp
801064ff:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106502:	e8 33 e5 ff ff       	call   80104a3a <wait>
}
80106507:	c9                   	leave  
80106508:	c3                   	ret    

80106509 <sys_kill>:

int
sys_kill(void)
{
80106509:	55                   	push   %ebp
8010650a:	89 e5                	mov    %esp,%ebp
8010650c:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010650f:	83 ec 08             	sub    $0x8,%esp
80106512:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106515:	50                   	push   %eax
80106516:	6a 00                	push   $0x0
80106518:	e8 eb f0 ff ff       	call   80105608 <argint>
8010651d:	83 c4 10             	add    $0x10,%esp
80106520:	85 c0                	test   %eax,%eax
80106522:	79 07                	jns    8010652b <sys_kill+0x22>
    return -1;
80106524:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106529:	eb 0f                	jmp    8010653a <sys_kill+0x31>
  return kill(pid);
8010652b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010652e:	83 ec 0c             	sub    $0xc,%esp
80106531:	50                   	push   %eax
80106532:	e8 73 e9 ff ff       	call   80104eaa <kill>
80106537:	83 c4 10             	add    $0x10,%esp
}
8010653a:	c9                   	leave  
8010653b:	c3                   	ret    

8010653c <sys_getpid>:

int
sys_getpid(void)
{
8010653c:	55                   	push   %ebp
8010653d:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010653f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106545:	8b 40 10             	mov    0x10(%eax),%eax
}
80106548:	5d                   	pop    %ebp
80106549:	c3                   	ret    

8010654a <sys_sbrk>:

int
sys_sbrk(void)
{
8010654a:	55                   	push   %ebp
8010654b:	89 e5                	mov    %esp,%ebp
8010654d:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106550:	83 ec 08             	sub    $0x8,%esp
80106553:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106556:	50                   	push   %eax
80106557:	6a 00                	push   $0x0
80106559:	e8 aa f0 ff ff       	call   80105608 <argint>
8010655e:	83 c4 10             	add    $0x10,%esp
80106561:	85 c0                	test   %eax,%eax
80106563:	79 07                	jns    8010656c <sys_sbrk+0x22>
    return -1;
80106565:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010656a:	eb 28                	jmp    80106594 <sys_sbrk+0x4a>
  addr = proc->sz;
8010656c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106572:	8b 00                	mov    (%eax),%eax
80106574:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106577:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010657a:	83 ec 0c             	sub    $0xc,%esp
8010657d:	50                   	push   %eax
8010657e:	e8 4f e1 ff ff       	call   801046d2 <growproc>
80106583:	83 c4 10             	add    $0x10,%esp
80106586:	85 c0                	test   %eax,%eax
80106588:	79 07                	jns    80106591 <sys_sbrk+0x47>
    return -1;
8010658a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010658f:	eb 03                	jmp    80106594 <sys_sbrk+0x4a>
  return addr;
80106591:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106594:	c9                   	leave  
80106595:	c3                   	ret    

80106596 <sys_sleep>:

int
sys_sleep(void)
{
80106596:	55                   	push   %ebp
80106597:	89 e5                	mov    %esp,%ebp
80106599:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010659c:	83 ec 08             	sub    $0x8,%esp
8010659f:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065a2:	50                   	push   %eax
801065a3:	6a 00                	push   $0x0
801065a5:	e8 5e f0 ff ff       	call   80105608 <argint>
801065aa:	83 c4 10             	add    $0x10,%esp
801065ad:	85 c0                	test   %eax,%eax
801065af:	79 07                	jns    801065b8 <sys_sleep+0x22>
    return -1;
801065b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b6:	eb 77                	jmp    8010662f <sys_sleep+0x99>
  acquire(&tickslock);
801065b8:	83 ec 0c             	sub    $0xc,%esp
801065bb:	68 60 40 11 80       	push   $0x80114060
801065c0:	e8 bd ea ff ff       	call   80105082 <acquire>
801065c5:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801065c8:	a1 94 40 11 80       	mov    0x80114094,%eax
801065cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801065d0:	eb 39                	jmp    8010660b <sys_sleep+0x75>
    if(proc->killed){
801065d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065d8:	8b 40 24             	mov    0x24(%eax),%eax
801065db:	85 c0                	test   %eax,%eax
801065dd:	74 17                	je     801065f6 <sys_sleep+0x60>
      release(&tickslock);
801065df:	83 ec 0c             	sub    $0xc,%esp
801065e2:	68 60 40 11 80       	push   $0x80114060
801065e7:	e8 fd ea ff ff       	call   801050e9 <release>
801065ec:	83 c4 10             	add    $0x10,%esp
      return -1;
801065ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f4:	eb 39                	jmp    8010662f <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801065f6:	83 ec 08             	sub    $0x8,%esp
801065f9:	68 60 40 11 80       	push   $0x80114060
801065fe:	68 94 40 11 80       	push   $0x80114094
80106603:	e8 7f e7 ff ff       	call   80104d87 <sleep>
80106608:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010660b:	a1 94 40 11 80       	mov    0x80114094,%eax
80106610:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106613:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106616:	39 d0                	cmp    %edx,%eax
80106618:	72 b8                	jb     801065d2 <sys_sleep+0x3c>
  }
  release(&tickslock);
8010661a:	83 ec 0c             	sub    $0xc,%esp
8010661d:	68 60 40 11 80       	push   $0x80114060
80106622:	e8 c2 ea ff ff       	call   801050e9 <release>
80106627:	83 c4 10             	add    $0x10,%esp
  return 0;
8010662a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010662f:	c9                   	leave  
80106630:	c3                   	ret    

80106631 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106631:	55                   	push   %ebp
80106632:	89 e5                	mov    %esp,%ebp
80106634:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80106637:	83 ec 0c             	sub    $0xc,%esp
8010663a:	68 60 40 11 80       	push   $0x80114060
8010663f:	e8 3e ea ff ff       	call   80105082 <acquire>
80106644:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106647:	a1 94 40 11 80       	mov    0x80114094,%eax
8010664c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010664f:	83 ec 0c             	sub    $0xc,%esp
80106652:	68 60 40 11 80       	push   $0x80114060
80106657:	e8 8d ea ff ff       	call   801050e9 <release>
8010665c:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010665f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106662:	c9                   	leave  
80106663:	c3                   	ret    

80106664 <sys_enable_sched_trace>:

extern int sched_trace_enabled;
int sys_enable_sched_trace(void)
{
80106664:	55                   	push   %ebp
80106665:	89 e5                	mov    %esp,%ebp
80106667:	83 ec 08             	sub    $0x8,%esp
  if (argint(0, &sched_trace_enabled) < 0)
8010666a:	83 ec 08             	sub    $0x8,%esp
8010666d:	68 54 38 11 80       	push   $0x80113854
80106672:	6a 00                	push   $0x0
80106674:	e8 8f ef ff ff       	call   80105608 <argint>
80106679:	83 c4 10             	add    $0x10,%esp
8010667c:	85 c0                	test   %eax,%eax
8010667e:	79 10                	jns    80106690 <sys_enable_sched_trace+0x2c>
  {
    cprintf("enable_sched_trace() failed!\n");
80106680:	83 ec 0c             	sub    $0xc,%esp
80106683:	68 eb 8a 10 80       	push   $0x80108aeb
80106688:	e8 39 9d ff ff       	call   801003c6 <cprintf>
8010668d:	83 c4 10             	add    $0x10,%esp
  }

  return 0;
80106690:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106695:	c9                   	leave  
80106696:	c3                   	ret    

80106697 <sys_uprog_shut>:

int sys_uprog_shut(void){
80106697:	55                   	push   %ebp
80106698:	89 e5                	mov    %esp,%ebp
  outw(0xB004, 0x0|0x2000);
8010669a:	68 00 20 00 00       	push   $0x2000
8010669f:	68 04 b0 00 00       	push   $0xb004
801066a4:	e8 13 fe ff ff       	call   801064bc <outw>
801066a9:	83 c4 08             	add    $0x8,%esp
  outw(0x604, 0x0|0x2000);
801066ac:	68 00 20 00 00       	push   $0x2000
801066b1:	68 04 06 00 00       	push   $0x604
801066b6:	e8 01 fe ff ff       	call   801064bc <outw>
801066bb:	83 c4 08             	add    $0x8,%esp

  return 0;
801066be:	b8 00 00 00 00       	mov    $0x0,%eax
801066c3:	c9                   	leave  
801066c4:	c3                   	ret    

801066c5 <outb>:
{
801066c5:	55                   	push   %ebp
801066c6:	89 e5                	mov    %esp,%ebp
801066c8:	83 ec 08             	sub    $0x8,%esp
801066cb:	8b 45 08             	mov    0x8(%ebp),%eax
801066ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801066d1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801066d5:	89 d0                	mov    %edx,%eax
801066d7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066da:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066de:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801066e2:	ee                   	out    %al,(%dx)
}
801066e3:	90                   	nop
801066e4:	c9                   	leave  
801066e5:	c3                   	ret    

801066e6 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801066e6:	55                   	push   %ebp
801066e7:	89 e5                	mov    %esp,%ebp
801066e9:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801066ec:	6a 34                	push   $0x34
801066ee:	6a 43                	push   $0x43
801066f0:	e8 d0 ff ff ff       	call   801066c5 <outb>
801066f5:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801066f8:	68 9c 00 00 00       	push   $0x9c
801066fd:	6a 40                	push   $0x40
801066ff:	e8 c1 ff ff ff       	call   801066c5 <outb>
80106704:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106707:	6a 2e                	push   $0x2e
80106709:	6a 40                	push   $0x40
8010670b:	e8 b5 ff ff ff       	call   801066c5 <outb>
80106710:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106713:	83 ec 0c             	sub    $0xc,%esp
80106716:	6a 00                	push   $0x0
80106718:	e8 4b d8 ff ff       	call   80103f68 <picenable>
8010671d:	83 c4 10             	add    $0x10,%esp
}
80106720:	90                   	nop
80106721:	c9                   	leave  
80106722:	c3                   	ret    

80106723 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106723:	1e                   	push   %ds
  pushl %es
80106724:	06                   	push   %es
  pushl %fs
80106725:	0f a0                	push   %fs
  pushl %gs
80106727:	0f a8                	push   %gs
  pushal
80106729:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010672a:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010672e:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106730:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106732:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106736:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106738:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010673a:	54                   	push   %esp
  call trap
8010673b:	e8 d7 01 00 00       	call   80106917 <trap>
  addl $4, %esp
80106740:	83 c4 04             	add    $0x4,%esp

80106743 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106743:	61                   	popa   
  popl %gs
80106744:	0f a9                	pop    %gs
  popl %fs
80106746:	0f a1                	pop    %fs
  popl %es
80106748:	07                   	pop    %es
  popl %ds
80106749:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010674a:	83 c4 08             	add    $0x8,%esp
  iret
8010674d:	cf                   	iret   

8010674e <lidt>:
{
8010674e:	55                   	push   %ebp
8010674f:	89 e5                	mov    %esp,%ebp
80106751:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106754:	8b 45 0c             	mov    0xc(%ebp),%eax
80106757:	83 e8 01             	sub    $0x1,%eax
8010675a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010675e:	8b 45 08             	mov    0x8(%ebp),%eax
80106761:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106765:	8b 45 08             	mov    0x8(%ebp),%eax
80106768:	c1 e8 10             	shr    $0x10,%eax
8010676b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010676f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106772:	0f 01 18             	lidtl  (%eax)
}
80106775:	90                   	nop
80106776:	c9                   	leave  
80106777:	c3                   	ret    

80106778 <rcr2>:
{
80106778:	55                   	push   %ebp
80106779:	89 e5                	mov    %esp,%ebp
8010677b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010677e:	0f 20 d0             	mov    %cr2,%eax
80106781:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106784:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106787:	c9                   	leave  
80106788:	c3                   	ret    

80106789 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106789:	55                   	push   %ebp
8010678a:	89 e5                	mov    %esp,%ebp
8010678c:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010678f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106796:	e9 c3 00 00 00       	jmp    8010685e <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010679b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010679e:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
801067a5:	89 c2                	mov    %eax,%edx
801067a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067aa:	66 89 14 c5 60 38 11 	mov    %dx,-0x7feec7a0(,%eax,8)
801067b1:	80 
801067b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b5:	66 c7 04 c5 62 38 11 	movw   $0x8,-0x7feec79e(,%eax,8)
801067bc:	80 08 00 
801067bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c2:	0f b6 14 c5 64 38 11 	movzbl -0x7feec79c(,%eax,8),%edx
801067c9:	80 
801067ca:	83 e2 e0             	and    $0xffffffe0,%edx
801067cd:	88 14 c5 64 38 11 80 	mov    %dl,-0x7feec79c(,%eax,8)
801067d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d7:	0f b6 14 c5 64 38 11 	movzbl -0x7feec79c(,%eax,8),%edx
801067de:	80 
801067df:	83 e2 1f             	and    $0x1f,%edx
801067e2:	88 14 c5 64 38 11 80 	mov    %dl,-0x7feec79c(,%eax,8)
801067e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ec:	0f b6 14 c5 65 38 11 	movzbl -0x7feec79b(,%eax,8),%edx
801067f3:	80 
801067f4:	83 e2 f0             	and    $0xfffffff0,%edx
801067f7:	83 ca 0e             	or     $0xe,%edx
801067fa:	88 14 c5 65 38 11 80 	mov    %dl,-0x7feec79b(,%eax,8)
80106801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106804:	0f b6 14 c5 65 38 11 	movzbl -0x7feec79b(,%eax,8),%edx
8010680b:	80 
8010680c:	83 e2 ef             	and    $0xffffffef,%edx
8010680f:	88 14 c5 65 38 11 80 	mov    %dl,-0x7feec79b(,%eax,8)
80106816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106819:	0f b6 14 c5 65 38 11 	movzbl -0x7feec79b(,%eax,8),%edx
80106820:	80 
80106821:	83 e2 9f             	and    $0xffffff9f,%edx
80106824:	88 14 c5 65 38 11 80 	mov    %dl,-0x7feec79b(,%eax,8)
8010682b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010682e:	0f b6 14 c5 65 38 11 	movzbl -0x7feec79b(,%eax,8),%edx
80106835:	80 
80106836:	83 ca 80             	or     $0xffffff80,%edx
80106839:	88 14 c5 65 38 11 80 	mov    %dl,-0x7feec79b(,%eax,8)
80106840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106843:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
8010684a:	c1 e8 10             	shr    $0x10,%eax
8010684d:	89 c2                	mov    %eax,%edx
8010684f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106852:	66 89 14 c5 66 38 11 	mov    %dx,-0x7feec79a(,%eax,8)
80106859:	80 
  for(i = 0; i < 256; i++)
8010685a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010685e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106865:	0f 8e 30 ff ff ff    	jle    8010679b <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010686b:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106870:	66 a3 60 3a 11 80    	mov    %ax,0x80113a60
80106876:	66 c7 05 62 3a 11 80 	movw   $0x8,0x80113a62
8010687d:	08 00 
8010687f:	0f b6 05 64 3a 11 80 	movzbl 0x80113a64,%eax
80106886:	83 e0 e0             	and    $0xffffffe0,%eax
80106889:	a2 64 3a 11 80       	mov    %al,0x80113a64
8010688e:	0f b6 05 64 3a 11 80 	movzbl 0x80113a64,%eax
80106895:	83 e0 1f             	and    $0x1f,%eax
80106898:	a2 64 3a 11 80       	mov    %al,0x80113a64
8010689d:	0f b6 05 65 3a 11 80 	movzbl 0x80113a65,%eax
801068a4:	83 c8 0f             	or     $0xf,%eax
801068a7:	a2 65 3a 11 80       	mov    %al,0x80113a65
801068ac:	0f b6 05 65 3a 11 80 	movzbl 0x80113a65,%eax
801068b3:	83 e0 ef             	and    $0xffffffef,%eax
801068b6:	a2 65 3a 11 80       	mov    %al,0x80113a65
801068bb:	0f b6 05 65 3a 11 80 	movzbl 0x80113a65,%eax
801068c2:	83 c8 60             	or     $0x60,%eax
801068c5:	a2 65 3a 11 80       	mov    %al,0x80113a65
801068ca:	0f b6 05 65 3a 11 80 	movzbl 0x80113a65,%eax
801068d1:	83 c8 80             	or     $0xffffff80,%eax
801068d4:	a2 65 3a 11 80       	mov    %al,0x80113a65
801068d9:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
801068de:	c1 e8 10             	shr    $0x10,%eax
801068e1:	66 a3 66 3a 11 80    	mov    %ax,0x80113a66
  
  initlock(&tickslock, "time");
801068e7:	83 ec 08             	sub    $0x8,%esp
801068ea:	68 0c 8b 10 80       	push   $0x80108b0c
801068ef:	68 60 40 11 80       	push   $0x80114060
801068f4:	e8 67 e7 ff ff       	call   80105060 <initlock>
801068f9:	83 c4 10             	add    $0x10,%esp
}
801068fc:	90                   	nop
801068fd:	c9                   	leave  
801068fe:	c3                   	ret    

801068ff <idtinit>:

void
idtinit(void)
{
801068ff:	55                   	push   %ebp
80106900:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106902:	68 00 08 00 00       	push   $0x800
80106907:	68 60 38 11 80       	push   $0x80113860
8010690c:	e8 3d fe ff ff       	call   8010674e <lidt>
80106911:	83 c4 08             	add    $0x8,%esp
}
80106914:	90                   	nop
80106915:	c9                   	leave  
80106916:	c3                   	ret    

80106917 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106917:	55                   	push   %ebp
80106918:	89 e5                	mov    %esp,%ebp
8010691a:	57                   	push   %edi
8010691b:	56                   	push   %esi
8010691c:	53                   	push   %ebx
8010691d:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106920:	8b 45 08             	mov    0x8(%ebp),%eax
80106923:	8b 40 30             	mov    0x30(%eax),%eax
80106926:	83 f8 40             	cmp    $0x40,%eax
80106929:	75 3e                	jne    80106969 <trap+0x52>
    if(proc->killed)
8010692b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106931:	8b 40 24             	mov    0x24(%eax),%eax
80106934:	85 c0                	test   %eax,%eax
80106936:	74 05                	je     8010693d <trap+0x26>
      exit();
80106938:	e8 c5 df ff ff       	call   80104902 <exit>
    proc->tf = tf;
8010693d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106943:	8b 55 08             	mov    0x8(%ebp),%edx
80106946:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106949:	e8 70 ed ff ff       	call   801056be <syscall>
    if(proc->killed)
8010694e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106954:	8b 40 24             	mov    0x24(%eax),%eax
80106957:	85 c0                	test   %eax,%eax
80106959:	0f 84 1c 02 00 00    	je     80106b7b <trap+0x264>
      exit();
8010695f:	e8 9e df ff ff       	call   80104902 <exit>
    return;
80106964:	e9 12 02 00 00       	jmp    80106b7b <trap+0x264>
  }

  switch(tf->trapno){
80106969:	8b 45 08             	mov    0x8(%ebp),%eax
8010696c:	8b 40 30             	mov    0x30(%eax),%eax
8010696f:	83 e8 20             	sub    $0x20,%eax
80106972:	83 f8 1f             	cmp    $0x1f,%eax
80106975:	0f 87 c0 00 00 00    	ja     80106a3b <trap+0x124>
8010697b:	8b 04 85 b4 8b 10 80 	mov    -0x7fef744c(,%eax,4),%eax
80106982:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106984:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010698a:	0f b6 00             	movzbl (%eax),%eax
8010698d:	84 c0                	test   %al,%al
8010698f:	75 3d                	jne    801069ce <trap+0xb7>
      acquire(&tickslock);
80106991:	83 ec 0c             	sub    $0xc,%esp
80106994:	68 60 40 11 80       	push   $0x80114060
80106999:	e8 e4 e6 ff ff       	call   80105082 <acquire>
8010699e:	83 c4 10             	add    $0x10,%esp
      ticks++;
801069a1:	a1 94 40 11 80       	mov    0x80114094,%eax
801069a6:	83 c0 01             	add    $0x1,%eax
801069a9:	a3 94 40 11 80       	mov    %eax,0x80114094
      wakeup(&ticks);
801069ae:	83 ec 0c             	sub    $0xc,%esp
801069b1:	68 94 40 11 80       	push   $0x80114094
801069b6:	e8 b8 e4 ff ff       	call   80104e73 <wakeup>
801069bb:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801069be:	83 ec 0c             	sub    $0xc,%esp
801069c1:	68 60 40 11 80       	push   $0x80114060
801069c6:	e8 1e e7 ff ff       	call   801050e9 <release>
801069cb:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801069ce:	e8 79 c6 ff ff       	call   8010304c <lapiceoi>
    break;
801069d3:	e9 1d 01 00 00       	jmp    80106af5 <trap+0x1de>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801069d8:	e8 7d be ff ff       	call   8010285a <ideintr>
    lapiceoi();
801069dd:	e8 6a c6 ff ff       	call   8010304c <lapiceoi>
    break;
801069e2:	e9 0e 01 00 00       	jmp    80106af5 <trap+0x1de>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801069e7:	e8 5e c4 ff ff       	call   80102e4a <kbdintr>
    lapiceoi();
801069ec:	e8 5b c6 ff ff       	call   8010304c <lapiceoi>
    break;
801069f1:	e9 ff 00 00 00       	jmp    80106af5 <trap+0x1de>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801069f6:	e8 63 03 00 00       	call   80106d5e <uartintr>
    lapiceoi();
801069fb:	e8 4c c6 ff ff       	call   8010304c <lapiceoi>
    break;
80106a00:	e9 f0 00 00 00       	jmp    80106af5 <trap+0x1de>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a05:	8b 45 08             	mov    0x8(%ebp),%eax
80106a08:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106a0b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a0e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a12:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106a15:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a1b:	0f b6 00             	movzbl (%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a1e:	0f b6 c0             	movzbl %al,%eax
80106a21:	51                   	push   %ecx
80106a22:	52                   	push   %edx
80106a23:	50                   	push   %eax
80106a24:	68 14 8b 10 80       	push   $0x80108b14
80106a29:	e8 98 99 ff ff       	call   801003c6 <cprintf>
80106a2e:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106a31:	e8 16 c6 ff ff       	call   8010304c <lapiceoi>
    break;
80106a36:	e9 ba 00 00 00       	jmp    80106af5 <trap+0x1de>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106a3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a41:	85 c0                	test   %eax,%eax
80106a43:	74 11                	je     80106a56 <trap+0x13f>
80106a45:	8b 45 08             	mov    0x8(%ebp),%eax
80106a48:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a4c:	0f b7 c0             	movzwl %ax,%eax
80106a4f:	83 e0 03             	and    $0x3,%eax
80106a52:	85 c0                	test   %eax,%eax
80106a54:	75 3f                	jne    80106a95 <trap+0x17e>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a56:	e8 1d fd ff ff       	call   80106778 <rcr2>
80106a5b:	8b 55 08             	mov    0x8(%ebp),%edx
80106a5e:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106a61:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106a68:	0f b6 12             	movzbl (%edx),%edx
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a6b:	0f b6 ca             	movzbl %dl,%ecx
80106a6e:	8b 55 08             	mov    0x8(%ebp),%edx
80106a71:	8b 52 30             	mov    0x30(%edx),%edx
80106a74:	83 ec 0c             	sub    $0xc,%esp
80106a77:	50                   	push   %eax
80106a78:	53                   	push   %ebx
80106a79:	51                   	push   %ecx
80106a7a:	52                   	push   %edx
80106a7b:	68 38 8b 10 80       	push   $0x80108b38
80106a80:	e8 41 99 ff ff       	call   801003c6 <cprintf>
80106a85:	83 c4 20             	add    $0x20,%esp
      panic("trap");
80106a88:	83 ec 0c             	sub    $0xc,%esp
80106a8b:	68 6a 8b 10 80       	push   $0x80108b6a
80106a90:	e8 e6 9a ff ff       	call   8010057b <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a95:	e8 de fc ff ff       	call   80106778 <rcr2>
80106a9a:	89 c2                	mov    %eax,%edx
80106a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9f:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106aa2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106aa8:	0f b6 00             	movzbl (%eax),%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106aab:	0f b6 f0             	movzbl %al,%esi
80106aae:	8b 45 08             	mov    0x8(%ebp),%eax
80106ab1:	8b 58 34             	mov    0x34(%eax),%ebx
80106ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80106ab7:	8b 48 30             	mov    0x30(%eax),%ecx
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106aba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ac0:	83 c0 6c             	add    $0x6c,%eax
80106ac3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106ac6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106acc:	8b 40 10             	mov    0x10(%eax),%eax
80106acf:	52                   	push   %edx
80106ad0:	57                   	push   %edi
80106ad1:	56                   	push   %esi
80106ad2:	53                   	push   %ebx
80106ad3:	51                   	push   %ecx
80106ad4:	ff 75 e4             	pushl  -0x1c(%ebp)
80106ad7:	50                   	push   %eax
80106ad8:	68 70 8b 10 80       	push   $0x80108b70
80106add:	e8 e4 98 ff ff       	call   801003c6 <cprintf>
80106ae2:	83 c4 20             	add    $0x20,%esp
            rcr2());
    proc->killed = 1;
80106ae5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aeb:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106af2:	eb 01                	jmp    80106af5 <trap+0x1de>
    break;
80106af4:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106af5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106afb:	85 c0                	test   %eax,%eax
80106afd:	74 24                	je     80106b23 <trap+0x20c>
80106aff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b05:	8b 40 24             	mov    0x24(%eax),%eax
80106b08:	85 c0                	test   %eax,%eax
80106b0a:	74 17                	je     80106b23 <trap+0x20c>
80106b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80106b0f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b13:	0f b7 c0             	movzwl %ax,%eax
80106b16:	83 e0 03             	and    $0x3,%eax
80106b19:	83 f8 03             	cmp    $0x3,%eax
80106b1c:	75 05                	jne    80106b23 <trap+0x20c>
    exit();
80106b1e:	e8 df dd ff ff       	call   80104902 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106b23:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b29:	85 c0                	test   %eax,%eax
80106b2b:	74 1e                	je     80106b4b <trap+0x234>
80106b2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b33:	8b 40 0c             	mov    0xc(%eax),%eax
80106b36:	83 f8 04             	cmp    $0x4,%eax
80106b39:	75 10                	jne    80106b4b <trap+0x234>
80106b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80106b3e:	8b 40 30             	mov    0x30(%eax),%eax
80106b41:	83 f8 20             	cmp    $0x20,%eax
80106b44:	75 05                	jne    80106b4b <trap+0x234>
    yield();
80106b46:	e8 98 e1 ff ff       	call   80104ce3 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106b4b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b51:	85 c0                	test   %eax,%eax
80106b53:	74 27                	je     80106b7c <trap+0x265>
80106b55:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b5b:	8b 40 24             	mov    0x24(%eax),%eax
80106b5e:	85 c0                	test   %eax,%eax
80106b60:	74 1a                	je     80106b7c <trap+0x265>
80106b62:	8b 45 08             	mov    0x8(%ebp),%eax
80106b65:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b69:	0f b7 c0             	movzwl %ax,%eax
80106b6c:	83 e0 03             	and    $0x3,%eax
80106b6f:	83 f8 03             	cmp    $0x3,%eax
80106b72:	75 08                	jne    80106b7c <trap+0x265>
    exit();
80106b74:	e8 89 dd ff ff       	call   80104902 <exit>
80106b79:	eb 01                	jmp    80106b7c <trap+0x265>
    return;
80106b7b:	90                   	nop
}
80106b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b7f:	5b                   	pop    %ebx
80106b80:	5e                   	pop    %esi
80106b81:	5f                   	pop    %edi
80106b82:	5d                   	pop    %ebp
80106b83:	c3                   	ret    

80106b84 <inb>:
{
80106b84:	55                   	push   %ebp
80106b85:	89 e5                	mov    %esp,%ebp
80106b87:	83 ec 14             	sub    $0x14,%esp
80106b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b8d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106b91:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106b95:	89 c2                	mov    %eax,%edx
80106b97:	ec                   	in     (%dx),%al
80106b98:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106b9b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106b9f:	c9                   	leave  
80106ba0:	c3                   	ret    

80106ba1 <outb>:
{
80106ba1:	55                   	push   %ebp
80106ba2:	89 e5                	mov    %esp,%ebp
80106ba4:	83 ec 08             	sub    $0x8,%esp
80106ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80106baa:	8b 55 0c             	mov    0xc(%ebp),%edx
80106bad:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106bb1:	89 d0                	mov    %edx,%eax
80106bb3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106bb6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106bba:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106bbe:	ee                   	out    %al,(%dx)
}
80106bbf:	90                   	nop
80106bc0:	c9                   	leave  
80106bc1:	c3                   	ret    

80106bc2 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106bc2:	55                   	push   %ebp
80106bc3:	89 e5                	mov    %esp,%ebp
80106bc5:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106bc8:	6a 00                	push   $0x0
80106bca:	68 fa 03 00 00       	push   $0x3fa
80106bcf:	e8 cd ff ff ff       	call   80106ba1 <outb>
80106bd4:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106bd7:	68 80 00 00 00       	push   $0x80
80106bdc:	68 fb 03 00 00       	push   $0x3fb
80106be1:	e8 bb ff ff ff       	call   80106ba1 <outb>
80106be6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106be9:	6a 0c                	push   $0xc
80106beb:	68 f8 03 00 00       	push   $0x3f8
80106bf0:	e8 ac ff ff ff       	call   80106ba1 <outb>
80106bf5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106bf8:	6a 00                	push   $0x0
80106bfa:	68 f9 03 00 00       	push   $0x3f9
80106bff:	e8 9d ff ff ff       	call   80106ba1 <outb>
80106c04:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106c07:	6a 03                	push   $0x3
80106c09:	68 fb 03 00 00       	push   $0x3fb
80106c0e:	e8 8e ff ff ff       	call   80106ba1 <outb>
80106c13:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106c16:	6a 00                	push   $0x0
80106c18:	68 fc 03 00 00       	push   $0x3fc
80106c1d:	e8 7f ff ff ff       	call   80106ba1 <outb>
80106c22:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106c25:	6a 01                	push   $0x1
80106c27:	68 f9 03 00 00       	push   $0x3f9
80106c2c:	e8 70 ff ff ff       	call   80106ba1 <outb>
80106c31:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106c34:	68 fd 03 00 00       	push   $0x3fd
80106c39:	e8 46 ff ff ff       	call   80106b84 <inb>
80106c3e:	83 c4 04             	add    $0x4,%esp
80106c41:	3c ff                	cmp    $0xff,%al
80106c43:	74 6e                	je     80106cb3 <uartinit+0xf1>
    return;
  uart = 1;
80106c45:	c7 05 98 40 11 80 01 	movl   $0x1,0x80114098
80106c4c:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106c4f:	68 fa 03 00 00       	push   $0x3fa
80106c54:	e8 2b ff ff ff       	call   80106b84 <inb>
80106c59:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106c5c:	68 f8 03 00 00       	push   $0x3f8
80106c61:	e8 1e ff ff ff       	call   80106b84 <inb>
80106c66:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106c69:	83 ec 0c             	sub    $0xc,%esp
80106c6c:	6a 04                	push   $0x4
80106c6e:	e8 f5 d2 ff ff       	call   80103f68 <picenable>
80106c73:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106c76:	83 ec 08             	sub    $0x8,%esp
80106c79:	6a 00                	push   $0x0
80106c7b:	6a 04                	push   $0x4
80106c7d:	e8 7a be ff ff       	call   80102afc <ioapicenable>
80106c82:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c85:	c7 45 f4 34 8c 10 80 	movl   $0x80108c34,-0xc(%ebp)
80106c8c:	eb 19                	jmp    80106ca7 <uartinit+0xe5>
    uartputc(*p);
80106c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c91:	0f b6 00             	movzbl (%eax),%eax
80106c94:	0f be c0             	movsbl %al,%eax
80106c97:	83 ec 0c             	sub    $0xc,%esp
80106c9a:	50                   	push   %eax
80106c9b:	e8 16 00 00 00       	call   80106cb6 <uartputc>
80106ca0:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106ca3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106caa:	0f b6 00             	movzbl (%eax),%eax
80106cad:	84 c0                	test   %al,%al
80106caf:	75 dd                	jne    80106c8e <uartinit+0xcc>
80106cb1:	eb 01                	jmp    80106cb4 <uartinit+0xf2>
    return;
80106cb3:	90                   	nop
}
80106cb4:	c9                   	leave  
80106cb5:	c3                   	ret    

80106cb6 <uartputc>:

void
uartputc(int c)
{
80106cb6:	55                   	push   %ebp
80106cb7:	89 e5                	mov    %esp,%ebp
80106cb9:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106cbc:	a1 98 40 11 80       	mov    0x80114098,%eax
80106cc1:	85 c0                	test   %eax,%eax
80106cc3:	74 53                	je     80106d18 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106cc5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ccc:	eb 11                	jmp    80106cdf <uartputc+0x29>
    microdelay(10);
80106cce:	83 ec 0c             	sub    $0xc,%esp
80106cd1:	6a 0a                	push   $0xa
80106cd3:	e8 8f c3 ff ff       	call   80103067 <microdelay>
80106cd8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106cdb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106cdf:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106ce3:	7f 1a                	jg     80106cff <uartputc+0x49>
80106ce5:	83 ec 0c             	sub    $0xc,%esp
80106ce8:	68 fd 03 00 00       	push   $0x3fd
80106ced:	e8 92 fe ff ff       	call   80106b84 <inb>
80106cf2:	83 c4 10             	add    $0x10,%esp
80106cf5:	0f b6 c0             	movzbl %al,%eax
80106cf8:	83 e0 20             	and    $0x20,%eax
80106cfb:	85 c0                	test   %eax,%eax
80106cfd:	74 cf                	je     80106cce <uartputc+0x18>
  outb(COM1+0, c);
80106cff:	8b 45 08             	mov    0x8(%ebp),%eax
80106d02:	0f b6 c0             	movzbl %al,%eax
80106d05:	83 ec 08             	sub    $0x8,%esp
80106d08:	50                   	push   %eax
80106d09:	68 f8 03 00 00       	push   $0x3f8
80106d0e:	e8 8e fe ff ff       	call   80106ba1 <outb>
80106d13:	83 c4 10             	add    $0x10,%esp
80106d16:	eb 01                	jmp    80106d19 <uartputc+0x63>
    return;
80106d18:	90                   	nop
}
80106d19:	c9                   	leave  
80106d1a:	c3                   	ret    

80106d1b <uartgetc>:

static int
uartgetc(void)
{
80106d1b:	55                   	push   %ebp
80106d1c:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106d1e:	a1 98 40 11 80       	mov    0x80114098,%eax
80106d23:	85 c0                	test   %eax,%eax
80106d25:	75 07                	jne    80106d2e <uartgetc+0x13>
    return -1;
80106d27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d2c:	eb 2e                	jmp    80106d5c <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106d2e:	68 fd 03 00 00       	push   $0x3fd
80106d33:	e8 4c fe ff ff       	call   80106b84 <inb>
80106d38:	83 c4 04             	add    $0x4,%esp
80106d3b:	0f b6 c0             	movzbl %al,%eax
80106d3e:	83 e0 01             	and    $0x1,%eax
80106d41:	85 c0                	test   %eax,%eax
80106d43:	75 07                	jne    80106d4c <uartgetc+0x31>
    return -1;
80106d45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d4a:	eb 10                	jmp    80106d5c <uartgetc+0x41>
  return inb(COM1+0);
80106d4c:	68 f8 03 00 00       	push   $0x3f8
80106d51:	e8 2e fe ff ff       	call   80106b84 <inb>
80106d56:	83 c4 04             	add    $0x4,%esp
80106d59:	0f b6 c0             	movzbl %al,%eax
}
80106d5c:	c9                   	leave  
80106d5d:	c3                   	ret    

80106d5e <uartintr>:

void
uartintr(void)
{
80106d5e:	55                   	push   %ebp
80106d5f:	89 e5                	mov    %esp,%ebp
80106d61:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106d64:	83 ec 0c             	sub    $0xc,%esp
80106d67:	68 1b 6d 10 80       	push   $0x80106d1b
80106d6c:	e8 ab 9a ff ff       	call   8010081c <consoleintr>
80106d71:	83 c4 10             	add    $0x10,%esp
}
80106d74:	90                   	nop
80106d75:	c9                   	leave  
80106d76:	c3                   	ret    

80106d77 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $0
80106d79:	6a 00                	push   $0x0
  jmp alltraps
80106d7b:	e9 a3 f9 ff ff       	jmp    80106723 <alltraps>

80106d80 <vector1>:
.globl vector1
vector1:
  pushl $0
80106d80:	6a 00                	push   $0x0
  pushl $1
80106d82:	6a 01                	push   $0x1
  jmp alltraps
80106d84:	e9 9a f9 ff ff       	jmp    80106723 <alltraps>

80106d89 <vector2>:
.globl vector2
vector2:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $2
80106d8b:	6a 02                	push   $0x2
  jmp alltraps
80106d8d:	e9 91 f9 ff ff       	jmp    80106723 <alltraps>

80106d92 <vector3>:
.globl vector3
vector3:
  pushl $0
80106d92:	6a 00                	push   $0x0
  pushl $3
80106d94:	6a 03                	push   $0x3
  jmp alltraps
80106d96:	e9 88 f9 ff ff       	jmp    80106723 <alltraps>

80106d9b <vector4>:
.globl vector4
vector4:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $4
80106d9d:	6a 04                	push   $0x4
  jmp alltraps
80106d9f:	e9 7f f9 ff ff       	jmp    80106723 <alltraps>

80106da4 <vector5>:
.globl vector5
vector5:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $5
80106da6:	6a 05                	push   $0x5
  jmp alltraps
80106da8:	e9 76 f9 ff ff       	jmp    80106723 <alltraps>

80106dad <vector6>:
.globl vector6
vector6:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $6
80106daf:	6a 06                	push   $0x6
  jmp alltraps
80106db1:	e9 6d f9 ff ff       	jmp    80106723 <alltraps>

80106db6 <vector7>:
.globl vector7
vector7:
  pushl $0
80106db6:	6a 00                	push   $0x0
  pushl $7
80106db8:	6a 07                	push   $0x7
  jmp alltraps
80106dba:	e9 64 f9 ff ff       	jmp    80106723 <alltraps>

80106dbf <vector8>:
.globl vector8
vector8:
  pushl $8
80106dbf:	6a 08                	push   $0x8
  jmp alltraps
80106dc1:	e9 5d f9 ff ff       	jmp    80106723 <alltraps>

80106dc6 <vector9>:
.globl vector9
vector9:
  pushl $0
80106dc6:	6a 00                	push   $0x0
  pushl $9
80106dc8:	6a 09                	push   $0x9
  jmp alltraps
80106dca:	e9 54 f9 ff ff       	jmp    80106723 <alltraps>

80106dcf <vector10>:
.globl vector10
vector10:
  pushl $10
80106dcf:	6a 0a                	push   $0xa
  jmp alltraps
80106dd1:	e9 4d f9 ff ff       	jmp    80106723 <alltraps>

80106dd6 <vector11>:
.globl vector11
vector11:
  pushl $11
80106dd6:	6a 0b                	push   $0xb
  jmp alltraps
80106dd8:	e9 46 f9 ff ff       	jmp    80106723 <alltraps>

80106ddd <vector12>:
.globl vector12
vector12:
  pushl $12
80106ddd:	6a 0c                	push   $0xc
  jmp alltraps
80106ddf:	e9 3f f9 ff ff       	jmp    80106723 <alltraps>

80106de4 <vector13>:
.globl vector13
vector13:
  pushl $13
80106de4:	6a 0d                	push   $0xd
  jmp alltraps
80106de6:	e9 38 f9 ff ff       	jmp    80106723 <alltraps>

80106deb <vector14>:
.globl vector14
vector14:
  pushl $14
80106deb:	6a 0e                	push   $0xe
  jmp alltraps
80106ded:	e9 31 f9 ff ff       	jmp    80106723 <alltraps>

80106df2 <vector15>:
.globl vector15
vector15:
  pushl $0
80106df2:	6a 00                	push   $0x0
  pushl $15
80106df4:	6a 0f                	push   $0xf
  jmp alltraps
80106df6:	e9 28 f9 ff ff       	jmp    80106723 <alltraps>

80106dfb <vector16>:
.globl vector16
vector16:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $16
80106dfd:	6a 10                	push   $0x10
  jmp alltraps
80106dff:	e9 1f f9 ff ff       	jmp    80106723 <alltraps>

80106e04 <vector17>:
.globl vector17
vector17:
  pushl $17
80106e04:	6a 11                	push   $0x11
  jmp alltraps
80106e06:	e9 18 f9 ff ff       	jmp    80106723 <alltraps>

80106e0b <vector18>:
.globl vector18
vector18:
  pushl $0
80106e0b:	6a 00                	push   $0x0
  pushl $18
80106e0d:	6a 12                	push   $0x12
  jmp alltraps
80106e0f:	e9 0f f9 ff ff       	jmp    80106723 <alltraps>

80106e14 <vector19>:
.globl vector19
vector19:
  pushl $0
80106e14:	6a 00                	push   $0x0
  pushl $19
80106e16:	6a 13                	push   $0x13
  jmp alltraps
80106e18:	e9 06 f9 ff ff       	jmp    80106723 <alltraps>

80106e1d <vector20>:
.globl vector20
vector20:
  pushl $0
80106e1d:	6a 00                	push   $0x0
  pushl $20
80106e1f:	6a 14                	push   $0x14
  jmp alltraps
80106e21:	e9 fd f8 ff ff       	jmp    80106723 <alltraps>

80106e26 <vector21>:
.globl vector21
vector21:
  pushl $0
80106e26:	6a 00                	push   $0x0
  pushl $21
80106e28:	6a 15                	push   $0x15
  jmp alltraps
80106e2a:	e9 f4 f8 ff ff       	jmp    80106723 <alltraps>

80106e2f <vector22>:
.globl vector22
vector22:
  pushl $0
80106e2f:	6a 00                	push   $0x0
  pushl $22
80106e31:	6a 16                	push   $0x16
  jmp alltraps
80106e33:	e9 eb f8 ff ff       	jmp    80106723 <alltraps>

80106e38 <vector23>:
.globl vector23
vector23:
  pushl $0
80106e38:	6a 00                	push   $0x0
  pushl $23
80106e3a:	6a 17                	push   $0x17
  jmp alltraps
80106e3c:	e9 e2 f8 ff ff       	jmp    80106723 <alltraps>

80106e41 <vector24>:
.globl vector24
vector24:
  pushl $0
80106e41:	6a 00                	push   $0x0
  pushl $24
80106e43:	6a 18                	push   $0x18
  jmp alltraps
80106e45:	e9 d9 f8 ff ff       	jmp    80106723 <alltraps>

80106e4a <vector25>:
.globl vector25
vector25:
  pushl $0
80106e4a:	6a 00                	push   $0x0
  pushl $25
80106e4c:	6a 19                	push   $0x19
  jmp alltraps
80106e4e:	e9 d0 f8 ff ff       	jmp    80106723 <alltraps>

80106e53 <vector26>:
.globl vector26
vector26:
  pushl $0
80106e53:	6a 00                	push   $0x0
  pushl $26
80106e55:	6a 1a                	push   $0x1a
  jmp alltraps
80106e57:	e9 c7 f8 ff ff       	jmp    80106723 <alltraps>

80106e5c <vector27>:
.globl vector27
vector27:
  pushl $0
80106e5c:	6a 00                	push   $0x0
  pushl $27
80106e5e:	6a 1b                	push   $0x1b
  jmp alltraps
80106e60:	e9 be f8 ff ff       	jmp    80106723 <alltraps>

80106e65 <vector28>:
.globl vector28
vector28:
  pushl $0
80106e65:	6a 00                	push   $0x0
  pushl $28
80106e67:	6a 1c                	push   $0x1c
  jmp alltraps
80106e69:	e9 b5 f8 ff ff       	jmp    80106723 <alltraps>

80106e6e <vector29>:
.globl vector29
vector29:
  pushl $0
80106e6e:	6a 00                	push   $0x0
  pushl $29
80106e70:	6a 1d                	push   $0x1d
  jmp alltraps
80106e72:	e9 ac f8 ff ff       	jmp    80106723 <alltraps>

80106e77 <vector30>:
.globl vector30
vector30:
  pushl $0
80106e77:	6a 00                	push   $0x0
  pushl $30
80106e79:	6a 1e                	push   $0x1e
  jmp alltraps
80106e7b:	e9 a3 f8 ff ff       	jmp    80106723 <alltraps>

80106e80 <vector31>:
.globl vector31
vector31:
  pushl $0
80106e80:	6a 00                	push   $0x0
  pushl $31
80106e82:	6a 1f                	push   $0x1f
  jmp alltraps
80106e84:	e9 9a f8 ff ff       	jmp    80106723 <alltraps>

80106e89 <vector32>:
.globl vector32
vector32:
  pushl $0
80106e89:	6a 00                	push   $0x0
  pushl $32
80106e8b:	6a 20                	push   $0x20
  jmp alltraps
80106e8d:	e9 91 f8 ff ff       	jmp    80106723 <alltraps>

80106e92 <vector33>:
.globl vector33
vector33:
  pushl $0
80106e92:	6a 00                	push   $0x0
  pushl $33
80106e94:	6a 21                	push   $0x21
  jmp alltraps
80106e96:	e9 88 f8 ff ff       	jmp    80106723 <alltraps>

80106e9b <vector34>:
.globl vector34
vector34:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $34
80106e9d:	6a 22                	push   $0x22
  jmp alltraps
80106e9f:	e9 7f f8 ff ff       	jmp    80106723 <alltraps>

80106ea4 <vector35>:
.globl vector35
vector35:
  pushl $0
80106ea4:	6a 00                	push   $0x0
  pushl $35
80106ea6:	6a 23                	push   $0x23
  jmp alltraps
80106ea8:	e9 76 f8 ff ff       	jmp    80106723 <alltraps>

80106ead <vector36>:
.globl vector36
vector36:
  pushl $0
80106ead:	6a 00                	push   $0x0
  pushl $36
80106eaf:	6a 24                	push   $0x24
  jmp alltraps
80106eb1:	e9 6d f8 ff ff       	jmp    80106723 <alltraps>

80106eb6 <vector37>:
.globl vector37
vector37:
  pushl $0
80106eb6:	6a 00                	push   $0x0
  pushl $37
80106eb8:	6a 25                	push   $0x25
  jmp alltraps
80106eba:	e9 64 f8 ff ff       	jmp    80106723 <alltraps>

80106ebf <vector38>:
.globl vector38
vector38:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $38
80106ec1:	6a 26                	push   $0x26
  jmp alltraps
80106ec3:	e9 5b f8 ff ff       	jmp    80106723 <alltraps>

80106ec8 <vector39>:
.globl vector39
vector39:
  pushl $0
80106ec8:	6a 00                	push   $0x0
  pushl $39
80106eca:	6a 27                	push   $0x27
  jmp alltraps
80106ecc:	e9 52 f8 ff ff       	jmp    80106723 <alltraps>

80106ed1 <vector40>:
.globl vector40
vector40:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $40
80106ed3:	6a 28                	push   $0x28
  jmp alltraps
80106ed5:	e9 49 f8 ff ff       	jmp    80106723 <alltraps>

80106eda <vector41>:
.globl vector41
vector41:
  pushl $0
80106eda:	6a 00                	push   $0x0
  pushl $41
80106edc:	6a 29                	push   $0x29
  jmp alltraps
80106ede:	e9 40 f8 ff ff       	jmp    80106723 <alltraps>

80106ee3 <vector42>:
.globl vector42
vector42:
  pushl $0
80106ee3:	6a 00                	push   $0x0
  pushl $42
80106ee5:	6a 2a                	push   $0x2a
  jmp alltraps
80106ee7:	e9 37 f8 ff ff       	jmp    80106723 <alltraps>

80106eec <vector43>:
.globl vector43
vector43:
  pushl $0
80106eec:	6a 00                	push   $0x0
  pushl $43
80106eee:	6a 2b                	push   $0x2b
  jmp alltraps
80106ef0:	e9 2e f8 ff ff       	jmp    80106723 <alltraps>

80106ef5 <vector44>:
.globl vector44
vector44:
  pushl $0
80106ef5:	6a 00                	push   $0x0
  pushl $44
80106ef7:	6a 2c                	push   $0x2c
  jmp alltraps
80106ef9:	e9 25 f8 ff ff       	jmp    80106723 <alltraps>

80106efe <vector45>:
.globl vector45
vector45:
  pushl $0
80106efe:	6a 00                	push   $0x0
  pushl $45
80106f00:	6a 2d                	push   $0x2d
  jmp alltraps
80106f02:	e9 1c f8 ff ff       	jmp    80106723 <alltraps>

80106f07 <vector46>:
.globl vector46
vector46:
  pushl $0
80106f07:	6a 00                	push   $0x0
  pushl $46
80106f09:	6a 2e                	push   $0x2e
  jmp alltraps
80106f0b:	e9 13 f8 ff ff       	jmp    80106723 <alltraps>

80106f10 <vector47>:
.globl vector47
vector47:
  pushl $0
80106f10:	6a 00                	push   $0x0
  pushl $47
80106f12:	6a 2f                	push   $0x2f
  jmp alltraps
80106f14:	e9 0a f8 ff ff       	jmp    80106723 <alltraps>

80106f19 <vector48>:
.globl vector48
vector48:
  pushl $0
80106f19:	6a 00                	push   $0x0
  pushl $48
80106f1b:	6a 30                	push   $0x30
  jmp alltraps
80106f1d:	e9 01 f8 ff ff       	jmp    80106723 <alltraps>

80106f22 <vector49>:
.globl vector49
vector49:
  pushl $0
80106f22:	6a 00                	push   $0x0
  pushl $49
80106f24:	6a 31                	push   $0x31
  jmp alltraps
80106f26:	e9 f8 f7 ff ff       	jmp    80106723 <alltraps>

80106f2b <vector50>:
.globl vector50
vector50:
  pushl $0
80106f2b:	6a 00                	push   $0x0
  pushl $50
80106f2d:	6a 32                	push   $0x32
  jmp alltraps
80106f2f:	e9 ef f7 ff ff       	jmp    80106723 <alltraps>

80106f34 <vector51>:
.globl vector51
vector51:
  pushl $0
80106f34:	6a 00                	push   $0x0
  pushl $51
80106f36:	6a 33                	push   $0x33
  jmp alltraps
80106f38:	e9 e6 f7 ff ff       	jmp    80106723 <alltraps>

80106f3d <vector52>:
.globl vector52
vector52:
  pushl $0
80106f3d:	6a 00                	push   $0x0
  pushl $52
80106f3f:	6a 34                	push   $0x34
  jmp alltraps
80106f41:	e9 dd f7 ff ff       	jmp    80106723 <alltraps>

80106f46 <vector53>:
.globl vector53
vector53:
  pushl $0
80106f46:	6a 00                	push   $0x0
  pushl $53
80106f48:	6a 35                	push   $0x35
  jmp alltraps
80106f4a:	e9 d4 f7 ff ff       	jmp    80106723 <alltraps>

80106f4f <vector54>:
.globl vector54
vector54:
  pushl $0
80106f4f:	6a 00                	push   $0x0
  pushl $54
80106f51:	6a 36                	push   $0x36
  jmp alltraps
80106f53:	e9 cb f7 ff ff       	jmp    80106723 <alltraps>

80106f58 <vector55>:
.globl vector55
vector55:
  pushl $0
80106f58:	6a 00                	push   $0x0
  pushl $55
80106f5a:	6a 37                	push   $0x37
  jmp alltraps
80106f5c:	e9 c2 f7 ff ff       	jmp    80106723 <alltraps>

80106f61 <vector56>:
.globl vector56
vector56:
  pushl $0
80106f61:	6a 00                	push   $0x0
  pushl $56
80106f63:	6a 38                	push   $0x38
  jmp alltraps
80106f65:	e9 b9 f7 ff ff       	jmp    80106723 <alltraps>

80106f6a <vector57>:
.globl vector57
vector57:
  pushl $0
80106f6a:	6a 00                	push   $0x0
  pushl $57
80106f6c:	6a 39                	push   $0x39
  jmp alltraps
80106f6e:	e9 b0 f7 ff ff       	jmp    80106723 <alltraps>

80106f73 <vector58>:
.globl vector58
vector58:
  pushl $0
80106f73:	6a 00                	push   $0x0
  pushl $58
80106f75:	6a 3a                	push   $0x3a
  jmp alltraps
80106f77:	e9 a7 f7 ff ff       	jmp    80106723 <alltraps>

80106f7c <vector59>:
.globl vector59
vector59:
  pushl $0
80106f7c:	6a 00                	push   $0x0
  pushl $59
80106f7e:	6a 3b                	push   $0x3b
  jmp alltraps
80106f80:	e9 9e f7 ff ff       	jmp    80106723 <alltraps>

80106f85 <vector60>:
.globl vector60
vector60:
  pushl $0
80106f85:	6a 00                	push   $0x0
  pushl $60
80106f87:	6a 3c                	push   $0x3c
  jmp alltraps
80106f89:	e9 95 f7 ff ff       	jmp    80106723 <alltraps>

80106f8e <vector61>:
.globl vector61
vector61:
  pushl $0
80106f8e:	6a 00                	push   $0x0
  pushl $61
80106f90:	6a 3d                	push   $0x3d
  jmp alltraps
80106f92:	e9 8c f7 ff ff       	jmp    80106723 <alltraps>

80106f97 <vector62>:
.globl vector62
vector62:
  pushl $0
80106f97:	6a 00                	push   $0x0
  pushl $62
80106f99:	6a 3e                	push   $0x3e
  jmp alltraps
80106f9b:	e9 83 f7 ff ff       	jmp    80106723 <alltraps>

80106fa0 <vector63>:
.globl vector63
vector63:
  pushl $0
80106fa0:	6a 00                	push   $0x0
  pushl $63
80106fa2:	6a 3f                	push   $0x3f
  jmp alltraps
80106fa4:	e9 7a f7 ff ff       	jmp    80106723 <alltraps>

80106fa9 <vector64>:
.globl vector64
vector64:
  pushl $0
80106fa9:	6a 00                	push   $0x0
  pushl $64
80106fab:	6a 40                	push   $0x40
  jmp alltraps
80106fad:	e9 71 f7 ff ff       	jmp    80106723 <alltraps>

80106fb2 <vector65>:
.globl vector65
vector65:
  pushl $0
80106fb2:	6a 00                	push   $0x0
  pushl $65
80106fb4:	6a 41                	push   $0x41
  jmp alltraps
80106fb6:	e9 68 f7 ff ff       	jmp    80106723 <alltraps>

80106fbb <vector66>:
.globl vector66
vector66:
  pushl $0
80106fbb:	6a 00                	push   $0x0
  pushl $66
80106fbd:	6a 42                	push   $0x42
  jmp alltraps
80106fbf:	e9 5f f7 ff ff       	jmp    80106723 <alltraps>

80106fc4 <vector67>:
.globl vector67
vector67:
  pushl $0
80106fc4:	6a 00                	push   $0x0
  pushl $67
80106fc6:	6a 43                	push   $0x43
  jmp alltraps
80106fc8:	e9 56 f7 ff ff       	jmp    80106723 <alltraps>

80106fcd <vector68>:
.globl vector68
vector68:
  pushl $0
80106fcd:	6a 00                	push   $0x0
  pushl $68
80106fcf:	6a 44                	push   $0x44
  jmp alltraps
80106fd1:	e9 4d f7 ff ff       	jmp    80106723 <alltraps>

80106fd6 <vector69>:
.globl vector69
vector69:
  pushl $0
80106fd6:	6a 00                	push   $0x0
  pushl $69
80106fd8:	6a 45                	push   $0x45
  jmp alltraps
80106fda:	e9 44 f7 ff ff       	jmp    80106723 <alltraps>

80106fdf <vector70>:
.globl vector70
vector70:
  pushl $0
80106fdf:	6a 00                	push   $0x0
  pushl $70
80106fe1:	6a 46                	push   $0x46
  jmp alltraps
80106fe3:	e9 3b f7 ff ff       	jmp    80106723 <alltraps>

80106fe8 <vector71>:
.globl vector71
vector71:
  pushl $0
80106fe8:	6a 00                	push   $0x0
  pushl $71
80106fea:	6a 47                	push   $0x47
  jmp alltraps
80106fec:	e9 32 f7 ff ff       	jmp    80106723 <alltraps>

80106ff1 <vector72>:
.globl vector72
vector72:
  pushl $0
80106ff1:	6a 00                	push   $0x0
  pushl $72
80106ff3:	6a 48                	push   $0x48
  jmp alltraps
80106ff5:	e9 29 f7 ff ff       	jmp    80106723 <alltraps>

80106ffa <vector73>:
.globl vector73
vector73:
  pushl $0
80106ffa:	6a 00                	push   $0x0
  pushl $73
80106ffc:	6a 49                	push   $0x49
  jmp alltraps
80106ffe:	e9 20 f7 ff ff       	jmp    80106723 <alltraps>

80107003 <vector74>:
.globl vector74
vector74:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $74
80107005:	6a 4a                	push   $0x4a
  jmp alltraps
80107007:	e9 17 f7 ff ff       	jmp    80106723 <alltraps>

8010700c <vector75>:
.globl vector75
vector75:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $75
8010700e:	6a 4b                	push   $0x4b
  jmp alltraps
80107010:	e9 0e f7 ff ff       	jmp    80106723 <alltraps>

80107015 <vector76>:
.globl vector76
vector76:
  pushl $0
80107015:	6a 00                	push   $0x0
  pushl $76
80107017:	6a 4c                	push   $0x4c
  jmp alltraps
80107019:	e9 05 f7 ff ff       	jmp    80106723 <alltraps>

8010701e <vector77>:
.globl vector77
vector77:
  pushl $0
8010701e:	6a 00                	push   $0x0
  pushl $77
80107020:	6a 4d                	push   $0x4d
  jmp alltraps
80107022:	e9 fc f6 ff ff       	jmp    80106723 <alltraps>

80107027 <vector78>:
.globl vector78
vector78:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $78
80107029:	6a 4e                	push   $0x4e
  jmp alltraps
8010702b:	e9 f3 f6 ff ff       	jmp    80106723 <alltraps>

80107030 <vector79>:
.globl vector79
vector79:
  pushl $0
80107030:	6a 00                	push   $0x0
  pushl $79
80107032:	6a 4f                	push   $0x4f
  jmp alltraps
80107034:	e9 ea f6 ff ff       	jmp    80106723 <alltraps>

80107039 <vector80>:
.globl vector80
vector80:
  pushl $0
80107039:	6a 00                	push   $0x0
  pushl $80
8010703b:	6a 50                	push   $0x50
  jmp alltraps
8010703d:	e9 e1 f6 ff ff       	jmp    80106723 <alltraps>

80107042 <vector81>:
.globl vector81
vector81:
  pushl $0
80107042:	6a 00                	push   $0x0
  pushl $81
80107044:	6a 51                	push   $0x51
  jmp alltraps
80107046:	e9 d8 f6 ff ff       	jmp    80106723 <alltraps>

8010704b <vector82>:
.globl vector82
vector82:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $82
8010704d:	6a 52                	push   $0x52
  jmp alltraps
8010704f:	e9 cf f6 ff ff       	jmp    80106723 <alltraps>

80107054 <vector83>:
.globl vector83
vector83:
  pushl $0
80107054:	6a 00                	push   $0x0
  pushl $83
80107056:	6a 53                	push   $0x53
  jmp alltraps
80107058:	e9 c6 f6 ff ff       	jmp    80106723 <alltraps>

8010705d <vector84>:
.globl vector84
vector84:
  pushl $0
8010705d:	6a 00                	push   $0x0
  pushl $84
8010705f:	6a 54                	push   $0x54
  jmp alltraps
80107061:	e9 bd f6 ff ff       	jmp    80106723 <alltraps>

80107066 <vector85>:
.globl vector85
vector85:
  pushl $0
80107066:	6a 00                	push   $0x0
  pushl $85
80107068:	6a 55                	push   $0x55
  jmp alltraps
8010706a:	e9 b4 f6 ff ff       	jmp    80106723 <alltraps>

8010706f <vector86>:
.globl vector86
vector86:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $86
80107071:	6a 56                	push   $0x56
  jmp alltraps
80107073:	e9 ab f6 ff ff       	jmp    80106723 <alltraps>

80107078 <vector87>:
.globl vector87
vector87:
  pushl $0
80107078:	6a 00                	push   $0x0
  pushl $87
8010707a:	6a 57                	push   $0x57
  jmp alltraps
8010707c:	e9 a2 f6 ff ff       	jmp    80106723 <alltraps>

80107081 <vector88>:
.globl vector88
vector88:
  pushl $0
80107081:	6a 00                	push   $0x0
  pushl $88
80107083:	6a 58                	push   $0x58
  jmp alltraps
80107085:	e9 99 f6 ff ff       	jmp    80106723 <alltraps>

8010708a <vector89>:
.globl vector89
vector89:
  pushl $0
8010708a:	6a 00                	push   $0x0
  pushl $89
8010708c:	6a 59                	push   $0x59
  jmp alltraps
8010708e:	e9 90 f6 ff ff       	jmp    80106723 <alltraps>

80107093 <vector90>:
.globl vector90
vector90:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $90
80107095:	6a 5a                	push   $0x5a
  jmp alltraps
80107097:	e9 87 f6 ff ff       	jmp    80106723 <alltraps>

8010709c <vector91>:
.globl vector91
vector91:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $91
8010709e:	6a 5b                	push   $0x5b
  jmp alltraps
801070a0:	e9 7e f6 ff ff       	jmp    80106723 <alltraps>

801070a5 <vector92>:
.globl vector92
vector92:
  pushl $0
801070a5:	6a 00                	push   $0x0
  pushl $92
801070a7:	6a 5c                	push   $0x5c
  jmp alltraps
801070a9:	e9 75 f6 ff ff       	jmp    80106723 <alltraps>

801070ae <vector93>:
.globl vector93
vector93:
  pushl $0
801070ae:	6a 00                	push   $0x0
  pushl $93
801070b0:	6a 5d                	push   $0x5d
  jmp alltraps
801070b2:	e9 6c f6 ff ff       	jmp    80106723 <alltraps>

801070b7 <vector94>:
.globl vector94
vector94:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $94
801070b9:	6a 5e                	push   $0x5e
  jmp alltraps
801070bb:	e9 63 f6 ff ff       	jmp    80106723 <alltraps>

801070c0 <vector95>:
.globl vector95
vector95:
  pushl $0
801070c0:	6a 00                	push   $0x0
  pushl $95
801070c2:	6a 5f                	push   $0x5f
  jmp alltraps
801070c4:	e9 5a f6 ff ff       	jmp    80106723 <alltraps>

801070c9 <vector96>:
.globl vector96
vector96:
  pushl $0
801070c9:	6a 00                	push   $0x0
  pushl $96
801070cb:	6a 60                	push   $0x60
  jmp alltraps
801070cd:	e9 51 f6 ff ff       	jmp    80106723 <alltraps>

801070d2 <vector97>:
.globl vector97
vector97:
  pushl $0
801070d2:	6a 00                	push   $0x0
  pushl $97
801070d4:	6a 61                	push   $0x61
  jmp alltraps
801070d6:	e9 48 f6 ff ff       	jmp    80106723 <alltraps>

801070db <vector98>:
.globl vector98
vector98:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $98
801070dd:	6a 62                	push   $0x62
  jmp alltraps
801070df:	e9 3f f6 ff ff       	jmp    80106723 <alltraps>

801070e4 <vector99>:
.globl vector99
vector99:
  pushl $0
801070e4:	6a 00                	push   $0x0
  pushl $99
801070e6:	6a 63                	push   $0x63
  jmp alltraps
801070e8:	e9 36 f6 ff ff       	jmp    80106723 <alltraps>

801070ed <vector100>:
.globl vector100
vector100:
  pushl $0
801070ed:	6a 00                	push   $0x0
  pushl $100
801070ef:	6a 64                	push   $0x64
  jmp alltraps
801070f1:	e9 2d f6 ff ff       	jmp    80106723 <alltraps>

801070f6 <vector101>:
.globl vector101
vector101:
  pushl $0
801070f6:	6a 00                	push   $0x0
  pushl $101
801070f8:	6a 65                	push   $0x65
  jmp alltraps
801070fa:	e9 24 f6 ff ff       	jmp    80106723 <alltraps>

801070ff <vector102>:
.globl vector102
vector102:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $102
80107101:	6a 66                	push   $0x66
  jmp alltraps
80107103:	e9 1b f6 ff ff       	jmp    80106723 <alltraps>

80107108 <vector103>:
.globl vector103
vector103:
  pushl $0
80107108:	6a 00                	push   $0x0
  pushl $103
8010710a:	6a 67                	push   $0x67
  jmp alltraps
8010710c:	e9 12 f6 ff ff       	jmp    80106723 <alltraps>

80107111 <vector104>:
.globl vector104
vector104:
  pushl $0
80107111:	6a 00                	push   $0x0
  pushl $104
80107113:	6a 68                	push   $0x68
  jmp alltraps
80107115:	e9 09 f6 ff ff       	jmp    80106723 <alltraps>

8010711a <vector105>:
.globl vector105
vector105:
  pushl $0
8010711a:	6a 00                	push   $0x0
  pushl $105
8010711c:	6a 69                	push   $0x69
  jmp alltraps
8010711e:	e9 00 f6 ff ff       	jmp    80106723 <alltraps>

80107123 <vector106>:
.globl vector106
vector106:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $106
80107125:	6a 6a                	push   $0x6a
  jmp alltraps
80107127:	e9 f7 f5 ff ff       	jmp    80106723 <alltraps>

8010712c <vector107>:
.globl vector107
vector107:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $107
8010712e:	6a 6b                	push   $0x6b
  jmp alltraps
80107130:	e9 ee f5 ff ff       	jmp    80106723 <alltraps>

80107135 <vector108>:
.globl vector108
vector108:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $108
80107137:	6a 6c                	push   $0x6c
  jmp alltraps
80107139:	e9 e5 f5 ff ff       	jmp    80106723 <alltraps>

8010713e <vector109>:
.globl vector109
vector109:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $109
80107140:	6a 6d                	push   $0x6d
  jmp alltraps
80107142:	e9 dc f5 ff ff       	jmp    80106723 <alltraps>

80107147 <vector110>:
.globl vector110
vector110:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $110
80107149:	6a 6e                	push   $0x6e
  jmp alltraps
8010714b:	e9 d3 f5 ff ff       	jmp    80106723 <alltraps>

80107150 <vector111>:
.globl vector111
vector111:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $111
80107152:	6a 6f                	push   $0x6f
  jmp alltraps
80107154:	e9 ca f5 ff ff       	jmp    80106723 <alltraps>

80107159 <vector112>:
.globl vector112
vector112:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $112
8010715b:	6a 70                	push   $0x70
  jmp alltraps
8010715d:	e9 c1 f5 ff ff       	jmp    80106723 <alltraps>

80107162 <vector113>:
.globl vector113
vector113:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $113
80107164:	6a 71                	push   $0x71
  jmp alltraps
80107166:	e9 b8 f5 ff ff       	jmp    80106723 <alltraps>

8010716b <vector114>:
.globl vector114
vector114:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $114
8010716d:	6a 72                	push   $0x72
  jmp alltraps
8010716f:	e9 af f5 ff ff       	jmp    80106723 <alltraps>

80107174 <vector115>:
.globl vector115
vector115:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $115
80107176:	6a 73                	push   $0x73
  jmp alltraps
80107178:	e9 a6 f5 ff ff       	jmp    80106723 <alltraps>

8010717d <vector116>:
.globl vector116
vector116:
  pushl $0
8010717d:	6a 00                	push   $0x0
  pushl $116
8010717f:	6a 74                	push   $0x74
  jmp alltraps
80107181:	e9 9d f5 ff ff       	jmp    80106723 <alltraps>

80107186 <vector117>:
.globl vector117
vector117:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $117
80107188:	6a 75                	push   $0x75
  jmp alltraps
8010718a:	e9 94 f5 ff ff       	jmp    80106723 <alltraps>

8010718f <vector118>:
.globl vector118
vector118:
  pushl $0
8010718f:	6a 00                	push   $0x0
  pushl $118
80107191:	6a 76                	push   $0x76
  jmp alltraps
80107193:	e9 8b f5 ff ff       	jmp    80106723 <alltraps>

80107198 <vector119>:
.globl vector119
vector119:
  pushl $0
80107198:	6a 00                	push   $0x0
  pushl $119
8010719a:	6a 77                	push   $0x77
  jmp alltraps
8010719c:	e9 82 f5 ff ff       	jmp    80106723 <alltraps>

801071a1 <vector120>:
.globl vector120
vector120:
  pushl $0
801071a1:	6a 00                	push   $0x0
  pushl $120
801071a3:	6a 78                	push   $0x78
  jmp alltraps
801071a5:	e9 79 f5 ff ff       	jmp    80106723 <alltraps>

801071aa <vector121>:
.globl vector121
vector121:
  pushl $0
801071aa:	6a 00                	push   $0x0
  pushl $121
801071ac:	6a 79                	push   $0x79
  jmp alltraps
801071ae:	e9 70 f5 ff ff       	jmp    80106723 <alltraps>

801071b3 <vector122>:
.globl vector122
vector122:
  pushl $0
801071b3:	6a 00                	push   $0x0
  pushl $122
801071b5:	6a 7a                	push   $0x7a
  jmp alltraps
801071b7:	e9 67 f5 ff ff       	jmp    80106723 <alltraps>

801071bc <vector123>:
.globl vector123
vector123:
  pushl $0
801071bc:	6a 00                	push   $0x0
  pushl $123
801071be:	6a 7b                	push   $0x7b
  jmp alltraps
801071c0:	e9 5e f5 ff ff       	jmp    80106723 <alltraps>

801071c5 <vector124>:
.globl vector124
vector124:
  pushl $0
801071c5:	6a 00                	push   $0x0
  pushl $124
801071c7:	6a 7c                	push   $0x7c
  jmp alltraps
801071c9:	e9 55 f5 ff ff       	jmp    80106723 <alltraps>

801071ce <vector125>:
.globl vector125
vector125:
  pushl $0
801071ce:	6a 00                	push   $0x0
  pushl $125
801071d0:	6a 7d                	push   $0x7d
  jmp alltraps
801071d2:	e9 4c f5 ff ff       	jmp    80106723 <alltraps>

801071d7 <vector126>:
.globl vector126
vector126:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $126
801071d9:	6a 7e                	push   $0x7e
  jmp alltraps
801071db:	e9 43 f5 ff ff       	jmp    80106723 <alltraps>

801071e0 <vector127>:
.globl vector127
vector127:
  pushl $0
801071e0:	6a 00                	push   $0x0
  pushl $127
801071e2:	6a 7f                	push   $0x7f
  jmp alltraps
801071e4:	e9 3a f5 ff ff       	jmp    80106723 <alltraps>

801071e9 <vector128>:
.globl vector128
vector128:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $128
801071eb:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801071f0:	e9 2e f5 ff ff       	jmp    80106723 <alltraps>

801071f5 <vector129>:
.globl vector129
vector129:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $129
801071f7:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801071fc:	e9 22 f5 ff ff       	jmp    80106723 <alltraps>

80107201 <vector130>:
.globl vector130
vector130:
  pushl $0
80107201:	6a 00                	push   $0x0
  pushl $130
80107203:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107208:	e9 16 f5 ff ff       	jmp    80106723 <alltraps>

8010720d <vector131>:
.globl vector131
vector131:
  pushl $0
8010720d:	6a 00                	push   $0x0
  pushl $131
8010720f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107214:	e9 0a f5 ff ff       	jmp    80106723 <alltraps>

80107219 <vector132>:
.globl vector132
vector132:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $132
8010721b:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107220:	e9 fe f4 ff ff       	jmp    80106723 <alltraps>

80107225 <vector133>:
.globl vector133
vector133:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $133
80107227:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010722c:	e9 f2 f4 ff ff       	jmp    80106723 <alltraps>

80107231 <vector134>:
.globl vector134
vector134:
  pushl $0
80107231:	6a 00                	push   $0x0
  pushl $134
80107233:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107238:	e9 e6 f4 ff ff       	jmp    80106723 <alltraps>

8010723d <vector135>:
.globl vector135
vector135:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $135
8010723f:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107244:	e9 da f4 ff ff       	jmp    80106723 <alltraps>

80107249 <vector136>:
.globl vector136
vector136:
  pushl $0
80107249:	6a 00                	push   $0x0
  pushl $136
8010724b:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107250:	e9 ce f4 ff ff       	jmp    80106723 <alltraps>

80107255 <vector137>:
.globl vector137
vector137:
  pushl $0
80107255:	6a 00                	push   $0x0
  pushl $137
80107257:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010725c:	e9 c2 f4 ff ff       	jmp    80106723 <alltraps>

80107261 <vector138>:
.globl vector138
vector138:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $138
80107263:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107268:	e9 b6 f4 ff ff       	jmp    80106723 <alltraps>

8010726d <vector139>:
.globl vector139
vector139:
  pushl $0
8010726d:	6a 00                	push   $0x0
  pushl $139
8010726f:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107274:	e9 aa f4 ff ff       	jmp    80106723 <alltraps>

80107279 <vector140>:
.globl vector140
vector140:
  pushl $0
80107279:	6a 00                	push   $0x0
  pushl $140
8010727b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107280:	e9 9e f4 ff ff       	jmp    80106723 <alltraps>

80107285 <vector141>:
.globl vector141
vector141:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $141
80107287:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010728c:	e9 92 f4 ff ff       	jmp    80106723 <alltraps>

80107291 <vector142>:
.globl vector142
vector142:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $142
80107293:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107298:	e9 86 f4 ff ff       	jmp    80106723 <alltraps>

8010729d <vector143>:
.globl vector143
vector143:
  pushl $0
8010729d:	6a 00                	push   $0x0
  pushl $143
8010729f:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801072a4:	e9 7a f4 ff ff       	jmp    80106723 <alltraps>

801072a9 <vector144>:
.globl vector144
vector144:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $144
801072ab:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801072b0:	e9 6e f4 ff ff       	jmp    80106723 <alltraps>

801072b5 <vector145>:
.globl vector145
vector145:
  pushl $0
801072b5:	6a 00                	push   $0x0
  pushl $145
801072b7:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801072bc:	e9 62 f4 ff ff       	jmp    80106723 <alltraps>

801072c1 <vector146>:
.globl vector146
vector146:
  pushl $0
801072c1:	6a 00                	push   $0x0
  pushl $146
801072c3:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801072c8:	e9 56 f4 ff ff       	jmp    80106723 <alltraps>

801072cd <vector147>:
.globl vector147
vector147:
  pushl $0
801072cd:	6a 00                	push   $0x0
  pushl $147
801072cf:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801072d4:	e9 4a f4 ff ff       	jmp    80106723 <alltraps>

801072d9 <vector148>:
.globl vector148
vector148:
  pushl $0
801072d9:	6a 00                	push   $0x0
  pushl $148
801072db:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801072e0:	e9 3e f4 ff ff       	jmp    80106723 <alltraps>

801072e5 <vector149>:
.globl vector149
vector149:
  pushl $0
801072e5:	6a 00                	push   $0x0
  pushl $149
801072e7:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801072ec:	e9 32 f4 ff ff       	jmp    80106723 <alltraps>

801072f1 <vector150>:
.globl vector150
vector150:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $150
801072f3:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801072f8:	e9 26 f4 ff ff       	jmp    80106723 <alltraps>

801072fd <vector151>:
.globl vector151
vector151:
  pushl $0
801072fd:	6a 00                	push   $0x0
  pushl $151
801072ff:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107304:	e9 1a f4 ff ff       	jmp    80106723 <alltraps>

80107309 <vector152>:
.globl vector152
vector152:
  pushl $0
80107309:	6a 00                	push   $0x0
  pushl $152
8010730b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107310:	e9 0e f4 ff ff       	jmp    80106723 <alltraps>

80107315 <vector153>:
.globl vector153
vector153:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $153
80107317:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010731c:	e9 02 f4 ff ff       	jmp    80106723 <alltraps>

80107321 <vector154>:
.globl vector154
vector154:
  pushl $0
80107321:	6a 00                	push   $0x0
  pushl $154
80107323:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107328:	e9 f6 f3 ff ff       	jmp    80106723 <alltraps>

8010732d <vector155>:
.globl vector155
vector155:
  pushl $0
8010732d:	6a 00                	push   $0x0
  pushl $155
8010732f:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107334:	e9 ea f3 ff ff       	jmp    80106723 <alltraps>

80107339 <vector156>:
.globl vector156
vector156:
  pushl $0
80107339:	6a 00                	push   $0x0
  pushl $156
8010733b:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107340:	e9 de f3 ff ff       	jmp    80106723 <alltraps>

80107345 <vector157>:
.globl vector157
vector157:
  pushl $0
80107345:	6a 00                	push   $0x0
  pushl $157
80107347:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010734c:	e9 d2 f3 ff ff       	jmp    80106723 <alltraps>

80107351 <vector158>:
.globl vector158
vector158:
  pushl $0
80107351:	6a 00                	push   $0x0
  pushl $158
80107353:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107358:	e9 c6 f3 ff ff       	jmp    80106723 <alltraps>

8010735d <vector159>:
.globl vector159
vector159:
  pushl $0
8010735d:	6a 00                	push   $0x0
  pushl $159
8010735f:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107364:	e9 ba f3 ff ff       	jmp    80106723 <alltraps>

80107369 <vector160>:
.globl vector160
vector160:
  pushl $0
80107369:	6a 00                	push   $0x0
  pushl $160
8010736b:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107370:	e9 ae f3 ff ff       	jmp    80106723 <alltraps>

80107375 <vector161>:
.globl vector161
vector161:
  pushl $0
80107375:	6a 00                	push   $0x0
  pushl $161
80107377:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010737c:	e9 a2 f3 ff ff       	jmp    80106723 <alltraps>

80107381 <vector162>:
.globl vector162
vector162:
  pushl $0
80107381:	6a 00                	push   $0x0
  pushl $162
80107383:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107388:	e9 96 f3 ff ff       	jmp    80106723 <alltraps>

8010738d <vector163>:
.globl vector163
vector163:
  pushl $0
8010738d:	6a 00                	push   $0x0
  pushl $163
8010738f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107394:	e9 8a f3 ff ff       	jmp    80106723 <alltraps>

80107399 <vector164>:
.globl vector164
vector164:
  pushl $0
80107399:	6a 00                	push   $0x0
  pushl $164
8010739b:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801073a0:	e9 7e f3 ff ff       	jmp    80106723 <alltraps>

801073a5 <vector165>:
.globl vector165
vector165:
  pushl $0
801073a5:	6a 00                	push   $0x0
  pushl $165
801073a7:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801073ac:	e9 72 f3 ff ff       	jmp    80106723 <alltraps>

801073b1 <vector166>:
.globl vector166
vector166:
  pushl $0
801073b1:	6a 00                	push   $0x0
  pushl $166
801073b3:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801073b8:	e9 66 f3 ff ff       	jmp    80106723 <alltraps>

801073bd <vector167>:
.globl vector167
vector167:
  pushl $0
801073bd:	6a 00                	push   $0x0
  pushl $167
801073bf:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801073c4:	e9 5a f3 ff ff       	jmp    80106723 <alltraps>

801073c9 <vector168>:
.globl vector168
vector168:
  pushl $0
801073c9:	6a 00                	push   $0x0
  pushl $168
801073cb:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801073d0:	e9 4e f3 ff ff       	jmp    80106723 <alltraps>

801073d5 <vector169>:
.globl vector169
vector169:
  pushl $0
801073d5:	6a 00                	push   $0x0
  pushl $169
801073d7:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801073dc:	e9 42 f3 ff ff       	jmp    80106723 <alltraps>

801073e1 <vector170>:
.globl vector170
vector170:
  pushl $0
801073e1:	6a 00                	push   $0x0
  pushl $170
801073e3:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801073e8:	e9 36 f3 ff ff       	jmp    80106723 <alltraps>

801073ed <vector171>:
.globl vector171
vector171:
  pushl $0
801073ed:	6a 00                	push   $0x0
  pushl $171
801073ef:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801073f4:	e9 2a f3 ff ff       	jmp    80106723 <alltraps>

801073f9 <vector172>:
.globl vector172
vector172:
  pushl $0
801073f9:	6a 00                	push   $0x0
  pushl $172
801073fb:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107400:	e9 1e f3 ff ff       	jmp    80106723 <alltraps>

80107405 <vector173>:
.globl vector173
vector173:
  pushl $0
80107405:	6a 00                	push   $0x0
  pushl $173
80107407:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010740c:	e9 12 f3 ff ff       	jmp    80106723 <alltraps>

80107411 <vector174>:
.globl vector174
vector174:
  pushl $0
80107411:	6a 00                	push   $0x0
  pushl $174
80107413:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107418:	e9 06 f3 ff ff       	jmp    80106723 <alltraps>

8010741d <vector175>:
.globl vector175
vector175:
  pushl $0
8010741d:	6a 00                	push   $0x0
  pushl $175
8010741f:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107424:	e9 fa f2 ff ff       	jmp    80106723 <alltraps>

80107429 <vector176>:
.globl vector176
vector176:
  pushl $0
80107429:	6a 00                	push   $0x0
  pushl $176
8010742b:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107430:	e9 ee f2 ff ff       	jmp    80106723 <alltraps>

80107435 <vector177>:
.globl vector177
vector177:
  pushl $0
80107435:	6a 00                	push   $0x0
  pushl $177
80107437:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010743c:	e9 e2 f2 ff ff       	jmp    80106723 <alltraps>

80107441 <vector178>:
.globl vector178
vector178:
  pushl $0
80107441:	6a 00                	push   $0x0
  pushl $178
80107443:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107448:	e9 d6 f2 ff ff       	jmp    80106723 <alltraps>

8010744d <vector179>:
.globl vector179
vector179:
  pushl $0
8010744d:	6a 00                	push   $0x0
  pushl $179
8010744f:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107454:	e9 ca f2 ff ff       	jmp    80106723 <alltraps>

80107459 <vector180>:
.globl vector180
vector180:
  pushl $0
80107459:	6a 00                	push   $0x0
  pushl $180
8010745b:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107460:	e9 be f2 ff ff       	jmp    80106723 <alltraps>

80107465 <vector181>:
.globl vector181
vector181:
  pushl $0
80107465:	6a 00                	push   $0x0
  pushl $181
80107467:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010746c:	e9 b2 f2 ff ff       	jmp    80106723 <alltraps>

80107471 <vector182>:
.globl vector182
vector182:
  pushl $0
80107471:	6a 00                	push   $0x0
  pushl $182
80107473:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107478:	e9 a6 f2 ff ff       	jmp    80106723 <alltraps>

8010747d <vector183>:
.globl vector183
vector183:
  pushl $0
8010747d:	6a 00                	push   $0x0
  pushl $183
8010747f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107484:	e9 9a f2 ff ff       	jmp    80106723 <alltraps>

80107489 <vector184>:
.globl vector184
vector184:
  pushl $0
80107489:	6a 00                	push   $0x0
  pushl $184
8010748b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107490:	e9 8e f2 ff ff       	jmp    80106723 <alltraps>

80107495 <vector185>:
.globl vector185
vector185:
  pushl $0
80107495:	6a 00                	push   $0x0
  pushl $185
80107497:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010749c:	e9 82 f2 ff ff       	jmp    80106723 <alltraps>

801074a1 <vector186>:
.globl vector186
vector186:
  pushl $0
801074a1:	6a 00                	push   $0x0
  pushl $186
801074a3:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801074a8:	e9 76 f2 ff ff       	jmp    80106723 <alltraps>

801074ad <vector187>:
.globl vector187
vector187:
  pushl $0
801074ad:	6a 00                	push   $0x0
  pushl $187
801074af:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801074b4:	e9 6a f2 ff ff       	jmp    80106723 <alltraps>

801074b9 <vector188>:
.globl vector188
vector188:
  pushl $0
801074b9:	6a 00                	push   $0x0
  pushl $188
801074bb:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801074c0:	e9 5e f2 ff ff       	jmp    80106723 <alltraps>

801074c5 <vector189>:
.globl vector189
vector189:
  pushl $0
801074c5:	6a 00                	push   $0x0
  pushl $189
801074c7:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801074cc:	e9 52 f2 ff ff       	jmp    80106723 <alltraps>

801074d1 <vector190>:
.globl vector190
vector190:
  pushl $0
801074d1:	6a 00                	push   $0x0
  pushl $190
801074d3:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801074d8:	e9 46 f2 ff ff       	jmp    80106723 <alltraps>

801074dd <vector191>:
.globl vector191
vector191:
  pushl $0
801074dd:	6a 00                	push   $0x0
  pushl $191
801074df:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801074e4:	e9 3a f2 ff ff       	jmp    80106723 <alltraps>

801074e9 <vector192>:
.globl vector192
vector192:
  pushl $0
801074e9:	6a 00                	push   $0x0
  pushl $192
801074eb:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801074f0:	e9 2e f2 ff ff       	jmp    80106723 <alltraps>

801074f5 <vector193>:
.globl vector193
vector193:
  pushl $0
801074f5:	6a 00                	push   $0x0
  pushl $193
801074f7:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801074fc:	e9 22 f2 ff ff       	jmp    80106723 <alltraps>

80107501 <vector194>:
.globl vector194
vector194:
  pushl $0
80107501:	6a 00                	push   $0x0
  pushl $194
80107503:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107508:	e9 16 f2 ff ff       	jmp    80106723 <alltraps>

8010750d <vector195>:
.globl vector195
vector195:
  pushl $0
8010750d:	6a 00                	push   $0x0
  pushl $195
8010750f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107514:	e9 0a f2 ff ff       	jmp    80106723 <alltraps>

80107519 <vector196>:
.globl vector196
vector196:
  pushl $0
80107519:	6a 00                	push   $0x0
  pushl $196
8010751b:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107520:	e9 fe f1 ff ff       	jmp    80106723 <alltraps>

80107525 <vector197>:
.globl vector197
vector197:
  pushl $0
80107525:	6a 00                	push   $0x0
  pushl $197
80107527:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010752c:	e9 f2 f1 ff ff       	jmp    80106723 <alltraps>

80107531 <vector198>:
.globl vector198
vector198:
  pushl $0
80107531:	6a 00                	push   $0x0
  pushl $198
80107533:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107538:	e9 e6 f1 ff ff       	jmp    80106723 <alltraps>

8010753d <vector199>:
.globl vector199
vector199:
  pushl $0
8010753d:	6a 00                	push   $0x0
  pushl $199
8010753f:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107544:	e9 da f1 ff ff       	jmp    80106723 <alltraps>

80107549 <vector200>:
.globl vector200
vector200:
  pushl $0
80107549:	6a 00                	push   $0x0
  pushl $200
8010754b:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107550:	e9 ce f1 ff ff       	jmp    80106723 <alltraps>

80107555 <vector201>:
.globl vector201
vector201:
  pushl $0
80107555:	6a 00                	push   $0x0
  pushl $201
80107557:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010755c:	e9 c2 f1 ff ff       	jmp    80106723 <alltraps>

80107561 <vector202>:
.globl vector202
vector202:
  pushl $0
80107561:	6a 00                	push   $0x0
  pushl $202
80107563:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107568:	e9 b6 f1 ff ff       	jmp    80106723 <alltraps>

8010756d <vector203>:
.globl vector203
vector203:
  pushl $0
8010756d:	6a 00                	push   $0x0
  pushl $203
8010756f:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107574:	e9 aa f1 ff ff       	jmp    80106723 <alltraps>

80107579 <vector204>:
.globl vector204
vector204:
  pushl $0
80107579:	6a 00                	push   $0x0
  pushl $204
8010757b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107580:	e9 9e f1 ff ff       	jmp    80106723 <alltraps>

80107585 <vector205>:
.globl vector205
vector205:
  pushl $0
80107585:	6a 00                	push   $0x0
  pushl $205
80107587:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010758c:	e9 92 f1 ff ff       	jmp    80106723 <alltraps>

80107591 <vector206>:
.globl vector206
vector206:
  pushl $0
80107591:	6a 00                	push   $0x0
  pushl $206
80107593:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107598:	e9 86 f1 ff ff       	jmp    80106723 <alltraps>

8010759d <vector207>:
.globl vector207
vector207:
  pushl $0
8010759d:	6a 00                	push   $0x0
  pushl $207
8010759f:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801075a4:	e9 7a f1 ff ff       	jmp    80106723 <alltraps>

801075a9 <vector208>:
.globl vector208
vector208:
  pushl $0
801075a9:	6a 00                	push   $0x0
  pushl $208
801075ab:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801075b0:	e9 6e f1 ff ff       	jmp    80106723 <alltraps>

801075b5 <vector209>:
.globl vector209
vector209:
  pushl $0
801075b5:	6a 00                	push   $0x0
  pushl $209
801075b7:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801075bc:	e9 62 f1 ff ff       	jmp    80106723 <alltraps>

801075c1 <vector210>:
.globl vector210
vector210:
  pushl $0
801075c1:	6a 00                	push   $0x0
  pushl $210
801075c3:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801075c8:	e9 56 f1 ff ff       	jmp    80106723 <alltraps>

801075cd <vector211>:
.globl vector211
vector211:
  pushl $0
801075cd:	6a 00                	push   $0x0
  pushl $211
801075cf:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801075d4:	e9 4a f1 ff ff       	jmp    80106723 <alltraps>

801075d9 <vector212>:
.globl vector212
vector212:
  pushl $0
801075d9:	6a 00                	push   $0x0
  pushl $212
801075db:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801075e0:	e9 3e f1 ff ff       	jmp    80106723 <alltraps>

801075e5 <vector213>:
.globl vector213
vector213:
  pushl $0
801075e5:	6a 00                	push   $0x0
  pushl $213
801075e7:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801075ec:	e9 32 f1 ff ff       	jmp    80106723 <alltraps>

801075f1 <vector214>:
.globl vector214
vector214:
  pushl $0
801075f1:	6a 00                	push   $0x0
  pushl $214
801075f3:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801075f8:	e9 26 f1 ff ff       	jmp    80106723 <alltraps>

801075fd <vector215>:
.globl vector215
vector215:
  pushl $0
801075fd:	6a 00                	push   $0x0
  pushl $215
801075ff:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107604:	e9 1a f1 ff ff       	jmp    80106723 <alltraps>

80107609 <vector216>:
.globl vector216
vector216:
  pushl $0
80107609:	6a 00                	push   $0x0
  pushl $216
8010760b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107610:	e9 0e f1 ff ff       	jmp    80106723 <alltraps>

80107615 <vector217>:
.globl vector217
vector217:
  pushl $0
80107615:	6a 00                	push   $0x0
  pushl $217
80107617:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010761c:	e9 02 f1 ff ff       	jmp    80106723 <alltraps>

80107621 <vector218>:
.globl vector218
vector218:
  pushl $0
80107621:	6a 00                	push   $0x0
  pushl $218
80107623:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107628:	e9 f6 f0 ff ff       	jmp    80106723 <alltraps>

8010762d <vector219>:
.globl vector219
vector219:
  pushl $0
8010762d:	6a 00                	push   $0x0
  pushl $219
8010762f:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107634:	e9 ea f0 ff ff       	jmp    80106723 <alltraps>

80107639 <vector220>:
.globl vector220
vector220:
  pushl $0
80107639:	6a 00                	push   $0x0
  pushl $220
8010763b:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107640:	e9 de f0 ff ff       	jmp    80106723 <alltraps>

80107645 <vector221>:
.globl vector221
vector221:
  pushl $0
80107645:	6a 00                	push   $0x0
  pushl $221
80107647:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010764c:	e9 d2 f0 ff ff       	jmp    80106723 <alltraps>

80107651 <vector222>:
.globl vector222
vector222:
  pushl $0
80107651:	6a 00                	push   $0x0
  pushl $222
80107653:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107658:	e9 c6 f0 ff ff       	jmp    80106723 <alltraps>

8010765d <vector223>:
.globl vector223
vector223:
  pushl $0
8010765d:	6a 00                	push   $0x0
  pushl $223
8010765f:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107664:	e9 ba f0 ff ff       	jmp    80106723 <alltraps>

80107669 <vector224>:
.globl vector224
vector224:
  pushl $0
80107669:	6a 00                	push   $0x0
  pushl $224
8010766b:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107670:	e9 ae f0 ff ff       	jmp    80106723 <alltraps>

80107675 <vector225>:
.globl vector225
vector225:
  pushl $0
80107675:	6a 00                	push   $0x0
  pushl $225
80107677:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010767c:	e9 a2 f0 ff ff       	jmp    80106723 <alltraps>

80107681 <vector226>:
.globl vector226
vector226:
  pushl $0
80107681:	6a 00                	push   $0x0
  pushl $226
80107683:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107688:	e9 96 f0 ff ff       	jmp    80106723 <alltraps>

8010768d <vector227>:
.globl vector227
vector227:
  pushl $0
8010768d:	6a 00                	push   $0x0
  pushl $227
8010768f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107694:	e9 8a f0 ff ff       	jmp    80106723 <alltraps>

80107699 <vector228>:
.globl vector228
vector228:
  pushl $0
80107699:	6a 00                	push   $0x0
  pushl $228
8010769b:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801076a0:	e9 7e f0 ff ff       	jmp    80106723 <alltraps>

801076a5 <vector229>:
.globl vector229
vector229:
  pushl $0
801076a5:	6a 00                	push   $0x0
  pushl $229
801076a7:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801076ac:	e9 72 f0 ff ff       	jmp    80106723 <alltraps>

801076b1 <vector230>:
.globl vector230
vector230:
  pushl $0
801076b1:	6a 00                	push   $0x0
  pushl $230
801076b3:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801076b8:	e9 66 f0 ff ff       	jmp    80106723 <alltraps>

801076bd <vector231>:
.globl vector231
vector231:
  pushl $0
801076bd:	6a 00                	push   $0x0
  pushl $231
801076bf:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801076c4:	e9 5a f0 ff ff       	jmp    80106723 <alltraps>

801076c9 <vector232>:
.globl vector232
vector232:
  pushl $0
801076c9:	6a 00                	push   $0x0
  pushl $232
801076cb:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801076d0:	e9 4e f0 ff ff       	jmp    80106723 <alltraps>

801076d5 <vector233>:
.globl vector233
vector233:
  pushl $0
801076d5:	6a 00                	push   $0x0
  pushl $233
801076d7:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801076dc:	e9 42 f0 ff ff       	jmp    80106723 <alltraps>

801076e1 <vector234>:
.globl vector234
vector234:
  pushl $0
801076e1:	6a 00                	push   $0x0
  pushl $234
801076e3:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801076e8:	e9 36 f0 ff ff       	jmp    80106723 <alltraps>

801076ed <vector235>:
.globl vector235
vector235:
  pushl $0
801076ed:	6a 00                	push   $0x0
  pushl $235
801076ef:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801076f4:	e9 2a f0 ff ff       	jmp    80106723 <alltraps>

801076f9 <vector236>:
.globl vector236
vector236:
  pushl $0
801076f9:	6a 00                	push   $0x0
  pushl $236
801076fb:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107700:	e9 1e f0 ff ff       	jmp    80106723 <alltraps>

80107705 <vector237>:
.globl vector237
vector237:
  pushl $0
80107705:	6a 00                	push   $0x0
  pushl $237
80107707:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010770c:	e9 12 f0 ff ff       	jmp    80106723 <alltraps>

80107711 <vector238>:
.globl vector238
vector238:
  pushl $0
80107711:	6a 00                	push   $0x0
  pushl $238
80107713:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107718:	e9 06 f0 ff ff       	jmp    80106723 <alltraps>

8010771d <vector239>:
.globl vector239
vector239:
  pushl $0
8010771d:	6a 00                	push   $0x0
  pushl $239
8010771f:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107724:	e9 fa ef ff ff       	jmp    80106723 <alltraps>

80107729 <vector240>:
.globl vector240
vector240:
  pushl $0
80107729:	6a 00                	push   $0x0
  pushl $240
8010772b:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107730:	e9 ee ef ff ff       	jmp    80106723 <alltraps>

80107735 <vector241>:
.globl vector241
vector241:
  pushl $0
80107735:	6a 00                	push   $0x0
  pushl $241
80107737:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010773c:	e9 e2 ef ff ff       	jmp    80106723 <alltraps>

80107741 <vector242>:
.globl vector242
vector242:
  pushl $0
80107741:	6a 00                	push   $0x0
  pushl $242
80107743:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107748:	e9 d6 ef ff ff       	jmp    80106723 <alltraps>

8010774d <vector243>:
.globl vector243
vector243:
  pushl $0
8010774d:	6a 00                	push   $0x0
  pushl $243
8010774f:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107754:	e9 ca ef ff ff       	jmp    80106723 <alltraps>

80107759 <vector244>:
.globl vector244
vector244:
  pushl $0
80107759:	6a 00                	push   $0x0
  pushl $244
8010775b:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107760:	e9 be ef ff ff       	jmp    80106723 <alltraps>

80107765 <vector245>:
.globl vector245
vector245:
  pushl $0
80107765:	6a 00                	push   $0x0
  pushl $245
80107767:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010776c:	e9 b2 ef ff ff       	jmp    80106723 <alltraps>

80107771 <vector246>:
.globl vector246
vector246:
  pushl $0
80107771:	6a 00                	push   $0x0
  pushl $246
80107773:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107778:	e9 a6 ef ff ff       	jmp    80106723 <alltraps>

8010777d <vector247>:
.globl vector247
vector247:
  pushl $0
8010777d:	6a 00                	push   $0x0
  pushl $247
8010777f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107784:	e9 9a ef ff ff       	jmp    80106723 <alltraps>

80107789 <vector248>:
.globl vector248
vector248:
  pushl $0
80107789:	6a 00                	push   $0x0
  pushl $248
8010778b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107790:	e9 8e ef ff ff       	jmp    80106723 <alltraps>

80107795 <vector249>:
.globl vector249
vector249:
  pushl $0
80107795:	6a 00                	push   $0x0
  pushl $249
80107797:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010779c:	e9 82 ef ff ff       	jmp    80106723 <alltraps>

801077a1 <vector250>:
.globl vector250
vector250:
  pushl $0
801077a1:	6a 00                	push   $0x0
  pushl $250
801077a3:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801077a8:	e9 76 ef ff ff       	jmp    80106723 <alltraps>

801077ad <vector251>:
.globl vector251
vector251:
  pushl $0
801077ad:	6a 00                	push   $0x0
  pushl $251
801077af:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801077b4:	e9 6a ef ff ff       	jmp    80106723 <alltraps>

801077b9 <vector252>:
.globl vector252
vector252:
  pushl $0
801077b9:	6a 00                	push   $0x0
  pushl $252
801077bb:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801077c0:	e9 5e ef ff ff       	jmp    80106723 <alltraps>

801077c5 <vector253>:
.globl vector253
vector253:
  pushl $0
801077c5:	6a 00                	push   $0x0
  pushl $253
801077c7:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801077cc:	e9 52 ef ff ff       	jmp    80106723 <alltraps>

801077d1 <vector254>:
.globl vector254
vector254:
  pushl $0
801077d1:	6a 00                	push   $0x0
  pushl $254
801077d3:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801077d8:	e9 46 ef ff ff       	jmp    80106723 <alltraps>

801077dd <vector255>:
.globl vector255
vector255:
  pushl $0
801077dd:	6a 00                	push   $0x0
  pushl $255
801077df:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801077e4:	e9 3a ef ff ff       	jmp    80106723 <alltraps>

801077e9 <lgdt>:
{
801077e9:	55                   	push   %ebp
801077ea:	89 e5                	mov    %esp,%ebp
801077ec:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801077ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801077f2:	83 e8 01             	sub    $0x1,%eax
801077f5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801077f9:	8b 45 08             	mov    0x8(%ebp),%eax
801077fc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107800:	8b 45 08             	mov    0x8(%ebp),%eax
80107803:	c1 e8 10             	shr    $0x10,%eax
80107806:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010780a:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010780d:	0f 01 10             	lgdtl  (%eax)
}
80107810:	90                   	nop
80107811:	c9                   	leave  
80107812:	c3                   	ret    

80107813 <ltr>:
{
80107813:	55                   	push   %ebp
80107814:	89 e5                	mov    %esp,%ebp
80107816:	83 ec 04             	sub    $0x4,%esp
80107819:	8b 45 08             	mov    0x8(%ebp),%eax
8010781c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107820:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107824:	0f 00 d8             	ltr    %ax
}
80107827:	90                   	nop
80107828:	c9                   	leave  
80107829:	c3                   	ret    

8010782a <loadgs>:
{
8010782a:	55                   	push   %ebp
8010782b:	89 e5                	mov    %esp,%ebp
8010782d:	83 ec 04             	sub    $0x4,%esp
80107830:	8b 45 08             	mov    0x8(%ebp),%eax
80107833:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107837:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010783b:	8e e8                	mov    %eax,%gs
}
8010783d:	90                   	nop
8010783e:	c9                   	leave  
8010783f:	c3                   	ret    

80107840 <lcr3>:
{
80107840:	55                   	push   %ebp
80107841:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107843:	8b 45 08             	mov    0x8(%ebp),%eax
80107846:	0f 22 d8             	mov    %eax,%cr3
}
80107849:	90                   	nop
8010784a:	5d                   	pop    %ebp
8010784b:	c3                   	ret    

8010784c <v2p>:
static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010784c:	55                   	push   %ebp
8010784d:	89 e5                	mov    %esp,%ebp
8010784f:	8b 45 08             	mov    0x8(%ebp),%eax
80107852:	05 00 00 00 80       	add    $0x80000000,%eax
80107857:	5d                   	pop    %ebp
80107858:	c3                   	ret    

80107859 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107859:	55                   	push   %ebp
8010785a:	89 e5                	mov    %esp,%ebp
8010785c:	8b 45 08             	mov    0x8(%ebp),%eax
8010785f:	05 00 00 00 80       	add    $0x80000000,%eax
80107864:	5d                   	pop    %ebp
80107865:	c3                   	ret    

80107866 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107866:	55                   	push   %ebp
80107867:	89 e5                	mov    %esp,%ebp
80107869:	53                   	push   %ebx
8010786a:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010786d:	e8 81 b7 ff ff       	call   80102ff3 <cpunum>
80107872:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107878:	05 20 13 11 80       	add    $0x80111320,%eax
8010787d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107883:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788c:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107895:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078a0:	83 e2 f0             	and    $0xfffffff0,%edx
801078a3:	83 ca 0a             	or     $0xa,%edx
801078a6:	88 50 7d             	mov    %dl,0x7d(%eax)
801078a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ac:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078b0:	83 ca 10             	or     $0x10,%edx
801078b3:	88 50 7d             	mov    %dl,0x7d(%eax)
801078b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078bd:	83 e2 9f             	and    $0xffffff9f,%edx
801078c0:	88 50 7d             	mov    %dl,0x7d(%eax)
801078c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c6:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078ca:	83 ca 80             	or     $0xffffff80,%edx
801078cd:	88 50 7d             	mov    %dl,0x7d(%eax)
801078d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078d7:	83 ca 0f             	or     $0xf,%edx
801078da:	88 50 7e             	mov    %dl,0x7e(%eax)
801078dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078e4:	83 e2 ef             	and    $0xffffffef,%edx
801078e7:	88 50 7e             	mov    %dl,0x7e(%eax)
801078ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ed:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078f1:	83 e2 df             	and    $0xffffffdf,%edx
801078f4:	88 50 7e             	mov    %dl,0x7e(%eax)
801078f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fa:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078fe:	83 ca 40             	or     $0x40,%edx
80107901:	88 50 7e             	mov    %dl,0x7e(%eax)
80107904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107907:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010790b:	83 ca 80             	or     $0xffffff80,%edx
8010790e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107914:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791b:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107922:	ff ff 
80107924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107927:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010792e:	00 00 
80107930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107933:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010793a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107944:	83 e2 f0             	and    $0xfffffff0,%edx
80107947:	83 ca 02             	or     $0x2,%edx
8010794a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107953:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010795a:	83 ca 10             	or     $0x10,%edx
8010795d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107966:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010796d:	83 e2 9f             	and    $0xffffff9f,%edx
80107970:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107979:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107980:	83 ca 80             	or     $0xffffff80,%edx
80107983:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107993:	83 ca 0f             	or     $0xf,%edx
80107996:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010799c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079a6:	83 e2 ef             	and    $0xffffffef,%edx
801079a9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079b9:	83 e2 df             	and    $0xffffffdf,%edx
801079bc:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079cc:	83 ca 40             	or     $0x40,%edx
801079cf:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079df:	83 ca 80             	or     $0xffffff80,%edx
801079e2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079eb:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801079f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f5:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801079fc:	ff ff 
801079fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a01:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107a08:	00 00 
80107a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0d:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a17:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a1e:	83 e2 f0             	and    $0xfffffff0,%edx
80107a21:	83 ca 0a             	or     $0xa,%edx
80107a24:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a34:	83 ca 10             	or     $0x10,%edx
80107a37:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a40:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a47:	83 ca 60             	or     $0x60,%edx
80107a4a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a53:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a5a:	83 ca 80             	or     $0xffffff80,%edx
80107a5d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a66:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a6d:	83 ca 0f             	or     $0xf,%edx
80107a70:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a79:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a80:	83 e2 ef             	and    $0xffffffef,%edx
80107a83:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a93:	83 e2 df             	and    $0xffffffdf,%edx
80107a96:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107aa6:	83 ca 40             	or     $0x40,%edx
80107aa9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ab9:	83 ca 80             	or     $0xffffff80,%edx
80107abc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac5:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acf:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107ad6:	ff ff 
80107ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adb:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107ae2:	00 00 
80107ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae7:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107af8:	83 e2 f0             	and    $0xfffffff0,%edx
80107afb:	83 ca 02             	or     $0x2,%edx
80107afe:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b07:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b0e:	83 ca 10             	or     $0x10,%edx
80107b11:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b21:	83 ca 60             	or     $0x60,%edx
80107b24:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b34:	83 ca 80             	or     $0xffffff80,%edx
80107b37:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b40:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b47:	83 ca 0f             	or     $0xf,%edx
80107b4a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b53:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b5a:	83 e2 ef             	and    $0xffffffef,%edx
80107b5d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b66:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b6d:	83 e2 df             	and    $0xffffffdf,%edx
80107b70:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b79:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b80:	83 ca 40             	or     $0x40,%edx
80107b83:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b93:	83 ca 80             	or     $0xffffff80,%edx
80107b96:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9f:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba9:	05 b4 00 00 00       	add    $0xb4,%eax
80107bae:	89 c3                	mov    %eax,%ebx
80107bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb3:	05 b4 00 00 00       	add    $0xb4,%eax
80107bb8:	c1 e8 10             	shr    $0x10,%eax
80107bbb:	89 c2                	mov    %eax,%edx
80107bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc0:	05 b4 00 00 00       	add    $0xb4,%eax
80107bc5:	c1 e8 18             	shr    $0x18,%eax
80107bc8:	89 c1                	mov    %eax,%ecx
80107bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcd:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107bd4:	00 00 
80107bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd9:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be3:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bec:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bf3:	83 e2 f0             	and    $0xfffffff0,%edx
80107bf6:	83 ca 02             	or     $0x2,%edx
80107bf9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c02:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c09:	83 ca 10             	or     $0x10,%edx
80107c0c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c15:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c1c:	83 e2 9f             	and    $0xffffff9f,%edx
80107c1f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c28:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c2f:	83 ca 80             	or     $0xffffff80,%edx
80107c32:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c42:	83 e2 f0             	and    $0xfffffff0,%edx
80107c45:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c55:	83 e2 ef             	and    $0xffffffef,%edx
80107c58:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c61:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c68:	83 e2 df             	and    $0xffffffdf,%edx
80107c6b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c74:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c7b:	83 ca 40             	or     $0x40,%edx
80107c7e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c87:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c8e:	83 ca 80             	or     $0xffffff80,%edx
80107c91:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9a:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca3:	83 c0 70             	add    $0x70,%eax
80107ca6:	83 ec 08             	sub    $0x8,%esp
80107ca9:	6a 38                	push   $0x38
80107cab:	50                   	push   %eax
80107cac:	e8 38 fb ff ff       	call   801077e9 <lgdt>
80107cb1:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107cb4:	83 ec 0c             	sub    $0xc,%esp
80107cb7:	6a 18                	push   $0x18
80107cb9:	e8 6c fb ff ff       	call   8010782a <loadgs>
80107cbe:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc4:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107cca:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107cd1:	00 00 00 00 
}
80107cd5:	90                   	nop
80107cd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107cd9:	c9                   	leave  
80107cda:	c3                   	ret    

80107cdb <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107cdb:	55                   	push   %ebp
80107cdc:	89 e5                	mov    %esp,%ebp
80107cde:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ce4:	c1 e8 16             	shr    $0x16,%eax
80107ce7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107cee:	8b 45 08             	mov    0x8(%ebp),%eax
80107cf1:	01 d0                	add    %edx,%eax
80107cf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107cf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cf9:	8b 00                	mov    (%eax),%eax
80107cfb:	83 e0 01             	and    $0x1,%eax
80107cfe:	85 c0                	test   %eax,%eax
80107d00:	74 18                	je     80107d1a <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107d02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d05:	8b 00                	mov    (%eax),%eax
80107d07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d0c:	50                   	push   %eax
80107d0d:	e8 47 fb ff ff       	call   80107859 <p2v>
80107d12:	83 c4 04             	add    $0x4,%esp
80107d15:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d18:	eb 48                	jmp    80107d62 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107d1a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107d1e:	74 0e                	je     80107d2e <walkpgdir+0x53>
80107d20:	e8 64 af ff ff       	call   80102c89 <kalloc>
80107d25:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107d2c:	75 07                	jne    80107d35 <walkpgdir+0x5a>
      return 0;
80107d2e:	b8 00 00 00 00       	mov    $0x0,%eax
80107d33:	eb 44                	jmp    80107d79 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107d35:	83 ec 04             	sub    $0x4,%esp
80107d38:	68 00 10 00 00       	push   $0x1000
80107d3d:	6a 00                	push   $0x0
80107d3f:	ff 75 f4             	pushl  -0xc(%ebp)
80107d42:	e8 9e d5 ff ff       	call   801052e5 <memset>
80107d47:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107d4a:	83 ec 0c             	sub    $0xc,%esp
80107d4d:	ff 75 f4             	pushl  -0xc(%ebp)
80107d50:	e8 f7 fa ff ff       	call   8010784c <v2p>
80107d55:	83 c4 10             	add    $0x10,%esp
80107d58:	83 c8 07             	or     $0x7,%eax
80107d5b:	89 c2                	mov    %eax,%edx
80107d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d60:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107d62:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d65:	c1 e8 0c             	shr    $0xc,%eax
80107d68:	25 ff 03 00 00       	and    $0x3ff,%eax
80107d6d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d77:	01 d0                	add    %edx,%eax
}
80107d79:	c9                   	leave  
80107d7a:	c3                   	ret    

80107d7b <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107d7b:	55                   	push   %ebp
80107d7c:	89 e5                	mov    %esp,%ebp
80107d7e:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107d81:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d84:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107d8c:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d8f:	8b 45 10             	mov    0x10(%ebp),%eax
80107d92:	01 d0                	add    %edx,%eax
80107d94:	83 e8 01             	sub    $0x1,%eax
80107d97:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107d9f:	83 ec 04             	sub    $0x4,%esp
80107da2:	6a 01                	push   $0x1
80107da4:	ff 75 f4             	pushl  -0xc(%ebp)
80107da7:	ff 75 08             	pushl  0x8(%ebp)
80107daa:	e8 2c ff ff ff       	call   80107cdb <walkpgdir>
80107daf:	83 c4 10             	add    $0x10,%esp
80107db2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107db5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107db9:	75 07                	jne    80107dc2 <mappages+0x47>
      return -1;
80107dbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107dc0:	eb 47                	jmp    80107e09 <mappages+0x8e>
    if(*pte & PTE_P)
80107dc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107dc5:	8b 00                	mov    (%eax),%eax
80107dc7:	83 e0 01             	and    $0x1,%eax
80107dca:	85 c0                	test   %eax,%eax
80107dcc:	74 0d                	je     80107ddb <mappages+0x60>
      panic("remap");
80107dce:	83 ec 0c             	sub    $0xc,%esp
80107dd1:	68 3c 8c 10 80       	push   $0x80108c3c
80107dd6:	e8 a0 87 ff ff       	call   8010057b <panic>
    *pte = pa | perm | PTE_P;
80107ddb:	8b 45 18             	mov    0x18(%ebp),%eax
80107dde:	0b 45 14             	or     0x14(%ebp),%eax
80107de1:	83 c8 01             	or     $0x1,%eax
80107de4:	89 c2                	mov    %eax,%edx
80107de6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107de9:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dee:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107df1:	74 10                	je     80107e03 <mappages+0x88>
      break;
    a += PGSIZE;
80107df3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107dfa:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e01:	eb 9c                	jmp    80107d9f <mappages+0x24>
      break;
80107e03:	90                   	nop
  }
  return 0;
80107e04:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e09:	c9                   	leave  
80107e0a:	c3                   	ret    

80107e0b <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107e0b:	55                   	push   %ebp
80107e0c:	89 e5                	mov    %esp,%ebp
80107e0e:	53                   	push   %ebx
80107e0f:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107e12:	e8 72 ae ff ff       	call   80102c89 <kalloc>
80107e17:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e1a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e1e:	75 0a                	jne    80107e2a <setupkvm+0x1f>
    return 0;
80107e20:	b8 00 00 00 00       	mov    $0x0,%eax
80107e25:	e9 8e 00 00 00       	jmp    80107eb8 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107e2a:	83 ec 04             	sub    $0x4,%esp
80107e2d:	68 00 10 00 00       	push   $0x1000
80107e32:	6a 00                	push   $0x0
80107e34:	ff 75 f0             	pushl  -0x10(%ebp)
80107e37:	e8 a9 d4 ff ff       	call   801052e5 <memset>
80107e3c:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107e3f:	83 ec 0c             	sub    $0xc,%esp
80107e42:	68 00 00 00 0e       	push   $0xe000000
80107e47:	e8 0d fa ff ff       	call   80107859 <p2v>
80107e4c:	83 c4 10             	add    $0x10,%esp
80107e4f:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107e54:	76 0d                	jbe    80107e63 <setupkvm+0x58>
    panic("PHYSTOP too high");
80107e56:	83 ec 0c             	sub    $0xc,%esp
80107e59:	68 42 8c 10 80       	push   $0x80108c42
80107e5e:	e8 18 87 ff ff       	call   8010057b <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e63:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107e6a:	eb 40                	jmp    80107eac <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6f:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e75:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7b:	8b 58 08             	mov    0x8(%eax),%ebx
80107e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e81:	8b 40 04             	mov    0x4(%eax),%eax
80107e84:	29 c3                	sub    %eax,%ebx
80107e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e89:	8b 00                	mov    (%eax),%eax
80107e8b:	83 ec 0c             	sub    $0xc,%esp
80107e8e:	51                   	push   %ecx
80107e8f:	52                   	push   %edx
80107e90:	53                   	push   %ebx
80107e91:	50                   	push   %eax
80107e92:	ff 75 f0             	pushl  -0x10(%ebp)
80107e95:	e8 e1 fe ff ff       	call   80107d7b <mappages>
80107e9a:	83 c4 20             	add    $0x20,%esp
80107e9d:	85 c0                	test   %eax,%eax
80107e9f:	79 07                	jns    80107ea8 <setupkvm+0x9d>
      return 0;
80107ea1:	b8 00 00 00 00       	mov    $0x0,%eax
80107ea6:	eb 10                	jmp    80107eb8 <setupkvm+0xad>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ea8:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107eac:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107eb3:	72 b7                	jb     80107e6c <setupkvm+0x61>
  return pgdir;
80107eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107eb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107ebb:	c9                   	leave  
80107ebc:	c3                   	ret    

80107ebd <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107ebd:	55                   	push   %ebp
80107ebe:	89 e5                	mov    %esp,%ebp
80107ec0:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107ec3:	e8 43 ff ff ff       	call   80107e0b <setupkvm>
80107ec8:	a3 a0 40 11 80       	mov    %eax,0x801140a0
  switchkvm();
80107ecd:	e8 03 00 00 00       	call   80107ed5 <switchkvm>
}
80107ed2:	90                   	nop
80107ed3:	c9                   	leave  
80107ed4:	c3                   	ret    

80107ed5 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107ed5:	55                   	push   %ebp
80107ed6:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107ed8:	a1 a0 40 11 80       	mov    0x801140a0,%eax
80107edd:	50                   	push   %eax
80107ede:	e8 69 f9 ff ff       	call   8010784c <v2p>
80107ee3:	83 c4 04             	add    $0x4,%esp
80107ee6:	50                   	push   %eax
80107ee7:	e8 54 f9 ff ff       	call   80107840 <lcr3>
80107eec:	83 c4 04             	add    $0x4,%esp
}
80107eef:	90                   	nop
80107ef0:	c9                   	leave  
80107ef1:	c3                   	ret    

80107ef2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107ef2:	55                   	push   %ebp
80107ef3:	89 e5                	mov    %esp,%ebp
80107ef5:	56                   	push   %esi
80107ef6:	53                   	push   %ebx
  pushcli();
80107ef7:	e8 e4 d2 ff ff       	call   801051e0 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107efc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f02:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107f09:	83 c2 08             	add    $0x8,%edx
80107f0c:	89 d6                	mov    %edx,%esi
80107f0e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107f15:	83 c2 08             	add    $0x8,%edx
80107f18:	c1 ea 10             	shr    $0x10,%edx
80107f1b:	89 d3                	mov    %edx,%ebx
80107f1d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107f24:	83 c2 08             	add    $0x8,%edx
80107f27:	c1 ea 18             	shr    $0x18,%edx
80107f2a:	89 d1                	mov    %edx,%ecx
80107f2c:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107f33:	67 00 
80107f35:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80107f3c:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107f42:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f49:	83 e2 f0             	and    $0xfffffff0,%edx
80107f4c:	83 ca 09             	or     $0x9,%edx
80107f4f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f55:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f5c:	83 ca 10             	or     $0x10,%edx
80107f5f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f65:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f6c:	83 e2 9f             	and    $0xffffff9f,%edx
80107f6f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f75:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f7c:	83 ca 80             	or     $0xffffff80,%edx
80107f7f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f85:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f8c:	83 e2 f0             	and    $0xfffffff0,%edx
80107f8f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f95:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f9c:	83 e2 ef             	and    $0xffffffef,%edx
80107f9f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107fa5:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107fac:	83 e2 df             	and    $0xffffffdf,%edx
80107faf:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107fb5:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107fbc:	83 ca 40             	or     $0x40,%edx
80107fbf:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107fc5:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107fcc:	83 e2 7f             	and    $0x7f,%edx
80107fcf:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107fd5:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107fdb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107fe1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107fe8:	83 e2 ef             	and    $0xffffffef,%edx
80107feb:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107ff1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ff7:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107ffd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108003:	8b 40 08             	mov    0x8(%eax),%eax
80108006:	89 c2                	mov    %eax,%edx
80108008:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010800e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108014:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108017:	83 ec 0c             	sub    $0xc,%esp
8010801a:	6a 30                	push   $0x30
8010801c:	e8 f2 f7 ff ff       	call   80107813 <ltr>
80108021:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108024:	8b 45 08             	mov    0x8(%ebp),%eax
80108027:	8b 40 04             	mov    0x4(%eax),%eax
8010802a:	85 c0                	test   %eax,%eax
8010802c:	75 0d                	jne    8010803b <switchuvm+0x149>
    panic("switchuvm: no pgdir");
8010802e:	83 ec 0c             	sub    $0xc,%esp
80108031:	68 53 8c 10 80       	push   $0x80108c53
80108036:	e8 40 85 ff ff       	call   8010057b <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010803b:	8b 45 08             	mov    0x8(%ebp),%eax
8010803e:	8b 40 04             	mov    0x4(%eax),%eax
80108041:	83 ec 0c             	sub    $0xc,%esp
80108044:	50                   	push   %eax
80108045:	e8 02 f8 ff ff       	call   8010784c <v2p>
8010804a:	83 c4 10             	add    $0x10,%esp
8010804d:	83 ec 0c             	sub    $0xc,%esp
80108050:	50                   	push   %eax
80108051:	e8 ea f7 ff ff       	call   80107840 <lcr3>
80108056:	83 c4 10             	add    $0x10,%esp
  popcli();
80108059:	e8 c6 d1 ff ff       	call   80105224 <popcli>
}
8010805e:	90                   	nop
8010805f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108062:	5b                   	pop    %ebx
80108063:	5e                   	pop    %esi
80108064:	5d                   	pop    %ebp
80108065:	c3                   	ret    

80108066 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108066:	55                   	push   %ebp
80108067:	89 e5                	mov    %esp,%ebp
80108069:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010806c:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108073:	76 0d                	jbe    80108082 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108075:	83 ec 0c             	sub    $0xc,%esp
80108078:	68 67 8c 10 80       	push   $0x80108c67
8010807d:	e8 f9 84 ff ff       	call   8010057b <panic>
  mem = kalloc();
80108082:	e8 02 ac ff ff       	call   80102c89 <kalloc>
80108087:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010808a:	83 ec 04             	sub    $0x4,%esp
8010808d:	68 00 10 00 00       	push   $0x1000
80108092:	6a 00                	push   $0x0
80108094:	ff 75 f4             	pushl  -0xc(%ebp)
80108097:	e8 49 d2 ff ff       	call   801052e5 <memset>
8010809c:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010809f:	83 ec 0c             	sub    $0xc,%esp
801080a2:	ff 75 f4             	pushl  -0xc(%ebp)
801080a5:	e8 a2 f7 ff ff       	call   8010784c <v2p>
801080aa:	83 c4 10             	add    $0x10,%esp
801080ad:	83 ec 0c             	sub    $0xc,%esp
801080b0:	6a 06                	push   $0x6
801080b2:	50                   	push   %eax
801080b3:	68 00 10 00 00       	push   $0x1000
801080b8:	6a 00                	push   $0x0
801080ba:	ff 75 08             	pushl  0x8(%ebp)
801080bd:	e8 b9 fc ff ff       	call   80107d7b <mappages>
801080c2:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801080c5:	83 ec 04             	sub    $0x4,%esp
801080c8:	ff 75 10             	pushl  0x10(%ebp)
801080cb:	ff 75 0c             	pushl  0xc(%ebp)
801080ce:	ff 75 f4             	pushl  -0xc(%ebp)
801080d1:	e8 ce d2 ff ff       	call   801053a4 <memmove>
801080d6:	83 c4 10             	add    $0x10,%esp
}
801080d9:	90                   	nop
801080da:	c9                   	leave  
801080db:	c3                   	ret    

801080dc <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801080dc:	55                   	push   %ebp
801080dd:	89 e5                	mov    %esp,%ebp
801080df:	53                   	push   %ebx
801080e0:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801080e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801080e6:	25 ff 0f 00 00       	and    $0xfff,%eax
801080eb:	85 c0                	test   %eax,%eax
801080ed:	74 0d                	je     801080fc <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801080ef:	83 ec 0c             	sub    $0xc,%esp
801080f2:	68 84 8c 10 80       	push   $0x80108c84
801080f7:	e8 7f 84 ff ff       	call   8010057b <panic>
  for(i = 0; i < sz; i += PGSIZE){
801080fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108103:	e9 95 00 00 00       	jmp    8010819d <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108108:	8b 55 0c             	mov    0xc(%ebp),%edx
8010810b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810e:	01 d0                	add    %edx,%eax
80108110:	83 ec 04             	sub    $0x4,%esp
80108113:	6a 00                	push   $0x0
80108115:	50                   	push   %eax
80108116:	ff 75 08             	pushl  0x8(%ebp)
80108119:	e8 bd fb ff ff       	call   80107cdb <walkpgdir>
8010811e:	83 c4 10             	add    $0x10,%esp
80108121:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108124:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108128:	75 0d                	jne    80108137 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
8010812a:	83 ec 0c             	sub    $0xc,%esp
8010812d:	68 a7 8c 10 80       	push   $0x80108ca7
80108132:	e8 44 84 ff ff       	call   8010057b <panic>
    pa = PTE_ADDR(*pte);
80108137:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010813a:	8b 00                	mov    (%eax),%eax
8010813c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108141:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108144:	8b 45 18             	mov    0x18(%ebp),%eax
80108147:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010814a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010814f:	77 0b                	ja     8010815c <loaduvm+0x80>
      n = sz - i;
80108151:	8b 45 18             	mov    0x18(%ebp),%eax
80108154:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108157:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010815a:	eb 07                	jmp    80108163 <loaduvm+0x87>
    else
      n = PGSIZE;
8010815c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108163:	8b 55 14             	mov    0x14(%ebp),%edx
80108166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108169:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010816c:	83 ec 0c             	sub    $0xc,%esp
8010816f:	ff 75 e8             	pushl  -0x18(%ebp)
80108172:	e8 e2 f6 ff ff       	call   80107859 <p2v>
80108177:	83 c4 10             	add    $0x10,%esp
8010817a:	ff 75 f0             	pushl  -0x10(%ebp)
8010817d:	53                   	push   %ebx
8010817e:	50                   	push   %eax
8010817f:	ff 75 10             	pushl  0x10(%ebp)
80108182:	e8 79 9d ff ff       	call   80101f00 <readi>
80108187:	83 c4 10             	add    $0x10,%esp
8010818a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010818d:	74 07                	je     80108196 <loaduvm+0xba>
      return -1;
8010818f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108194:	eb 18                	jmp    801081ae <loaduvm+0xd2>
  for(i = 0; i < sz; i += PGSIZE){
80108196:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010819d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a0:	3b 45 18             	cmp    0x18(%ebp),%eax
801081a3:	0f 82 5f ff ff ff    	jb     80108108 <loaduvm+0x2c>
  }
  return 0;
801081a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801081ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801081b1:	c9                   	leave  
801081b2:	c3                   	ret    

801081b3 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801081b3:	55                   	push   %ebp
801081b4:	89 e5                	mov    %esp,%ebp
801081b6:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801081b9:	8b 45 10             	mov    0x10(%ebp),%eax
801081bc:	85 c0                	test   %eax,%eax
801081be:	79 0a                	jns    801081ca <allocuvm+0x17>
    return 0;
801081c0:	b8 00 00 00 00       	mov    $0x0,%eax
801081c5:	e9 ae 00 00 00       	jmp    80108278 <allocuvm+0xc5>
  if(newsz < oldsz)
801081ca:	8b 45 10             	mov    0x10(%ebp),%eax
801081cd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081d0:	73 08                	jae    801081da <allocuvm+0x27>
    return oldsz;
801081d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801081d5:	e9 9e 00 00 00       	jmp    80108278 <allocuvm+0xc5>

  a = PGROUNDUP(oldsz);
801081da:	8b 45 0c             	mov    0xc(%ebp),%eax
801081dd:	05 ff 0f 00 00       	add    $0xfff,%eax
801081e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801081ea:	eb 7d                	jmp    80108269 <allocuvm+0xb6>
    mem = kalloc();
801081ec:	e8 98 aa ff ff       	call   80102c89 <kalloc>
801081f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801081f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081f8:	75 2b                	jne    80108225 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
801081fa:	83 ec 0c             	sub    $0xc,%esp
801081fd:	68 c5 8c 10 80       	push   $0x80108cc5
80108202:	e8 bf 81 ff ff       	call   801003c6 <cprintf>
80108207:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010820a:	83 ec 04             	sub    $0x4,%esp
8010820d:	ff 75 0c             	pushl  0xc(%ebp)
80108210:	ff 75 10             	pushl  0x10(%ebp)
80108213:	ff 75 08             	pushl  0x8(%ebp)
80108216:	e8 5f 00 00 00       	call   8010827a <deallocuvm>
8010821b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010821e:	b8 00 00 00 00       	mov    $0x0,%eax
80108223:	eb 53                	jmp    80108278 <allocuvm+0xc5>
    }
    memset(mem, 0, PGSIZE);
80108225:	83 ec 04             	sub    $0x4,%esp
80108228:	68 00 10 00 00       	push   $0x1000
8010822d:	6a 00                	push   $0x0
8010822f:	ff 75 f0             	pushl  -0x10(%ebp)
80108232:	e8 ae d0 ff ff       	call   801052e5 <memset>
80108237:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010823a:	83 ec 0c             	sub    $0xc,%esp
8010823d:	ff 75 f0             	pushl  -0x10(%ebp)
80108240:	e8 07 f6 ff ff       	call   8010784c <v2p>
80108245:	83 c4 10             	add    $0x10,%esp
80108248:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010824b:	83 ec 0c             	sub    $0xc,%esp
8010824e:	6a 06                	push   $0x6
80108250:	50                   	push   %eax
80108251:	68 00 10 00 00       	push   $0x1000
80108256:	52                   	push   %edx
80108257:	ff 75 08             	pushl  0x8(%ebp)
8010825a:	e8 1c fb ff ff       	call   80107d7b <mappages>
8010825f:	83 c4 20             	add    $0x20,%esp
  for(; a < newsz; a += PGSIZE){
80108262:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108269:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010826f:	0f 82 77 ff ff ff    	jb     801081ec <allocuvm+0x39>
  }
  return newsz;
80108275:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108278:	c9                   	leave  
80108279:	c3                   	ret    

8010827a <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010827a:	55                   	push   %ebp
8010827b:	89 e5                	mov    %esp,%ebp
8010827d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108280:	8b 45 10             	mov    0x10(%ebp),%eax
80108283:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108286:	72 08                	jb     80108290 <deallocuvm+0x16>
    return oldsz;
80108288:	8b 45 0c             	mov    0xc(%ebp),%eax
8010828b:	e9 a5 00 00 00       	jmp    80108335 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108290:	8b 45 10             	mov    0x10(%ebp),%eax
80108293:	05 ff 0f 00 00       	add    $0xfff,%eax
80108298:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010829d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801082a0:	e9 81 00 00 00       	jmp    80108326 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
801082a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a8:	83 ec 04             	sub    $0x4,%esp
801082ab:	6a 00                	push   $0x0
801082ad:	50                   	push   %eax
801082ae:	ff 75 08             	pushl  0x8(%ebp)
801082b1:	e8 25 fa ff ff       	call   80107cdb <walkpgdir>
801082b6:	83 c4 10             	add    $0x10,%esp
801082b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801082bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082c0:	75 09                	jne    801082cb <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
801082c2:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801082c9:	eb 54                	jmp    8010831f <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
801082cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082ce:	8b 00                	mov    (%eax),%eax
801082d0:	83 e0 01             	and    $0x1,%eax
801082d3:	85 c0                	test   %eax,%eax
801082d5:	74 48                	je     8010831f <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
801082d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082da:	8b 00                	mov    (%eax),%eax
801082dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801082e4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082e8:	75 0d                	jne    801082f7 <deallocuvm+0x7d>
        panic("kfree");
801082ea:	83 ec 0c             	sub    $0xc,%esp
801082ed:	68 dd 8c 10 80       	push   $0x80108cdd
801082f2:	e8 84 82 ff ff       	call   8010057b <panic>
      char *v = p2v(pa);
801082f7:	83 ec 0c             	sub    $0xc,%esp
801082fa:	ff 75 ec             	pushl  -0x14(%ebp)
801082fd:	e8 57 f5 ff ff       	call   80107859 <p2v>
80108302:	83 c4 10             	add    $0x10,%esp
80108305:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108308:	83 ec 0c             	sub    $0xc,%esp
8010830b:	ff 75 e8             	pushl  -0x18(%ebp)
8010830e:	e8 d9 a8 ff ff       	call   80102bec <kfree>
80108313:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108316:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108319:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010831f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108329:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010832c:	0f 82 73 ff ff ff    	jb     801082a5 <deallocuvm+0x2b>
    }
  }
  return newsz;
80108332:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108335:	c9                   	leave  
80108336:	c3                   	ret    

80108337 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108337:	55                   	push   %ebp
80108338:	89 e5                	mov    %esp,%ebp
8010833a:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010833d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108341:	75 0d                	jne    80108350 <freevm+0x19>
    panic("freevm: no pgdir");
80108343:	83 ec 0c             	sub    $0xc,%esp
80108346:	68 e3 8c 10 80       	push   $0x80108ce3
8010834b:	e8 2b 82 ff ff       	call   8010057b <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108350:	83 ec 04             	sub    $0x4,%esp
80108353:	6a 00                	push   $0x0
80108355:	68 00 00 00 80       	push   $0x80000000
8010835a:	ff 75 08             	pushl  0x8(%ebp)
8010835d:	e8 18 ff ff ff       	call   8010827a <deallocuvm>
80108362:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108365:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010836c:	eb 4f                	jmp    801083bd <freevm+0x86>
    if(pgdir[i] & PTE_P){
8010836e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108371:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108378:	8b 45 08             	mov    0x8(%ebp),%eax
8010837b:	01 d0                	add    %edx,%eax
8010837d:	8b 00                	mov    (%eax),%eax
8010837f:	83 e0 01             	and    $0x1,%eax
80108382:	85 c0                	test   %eax,%eax
80108384:	74 33                	je     801083b9 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108389:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108390:	8b 45 08             	mov    0x8(%ebp),%eax
80108393:	01 d0                	add    %edx,%eax
80108395:	8b 00                	mov    (%eax),%eax
80108397:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010839c:	83 ec 0c             	sub    $0xc,%esp
8010839f:	50                   	push   %eax
801083a0:	e8 b4 f4 ff ff       	call   80107859 <p2v>
801083a5:	83 c4 10             	add    $0x10,%esp
801083a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801083ab:	83 ec 0c             	sub    $0xc,%esp
801083ae:	ff 75 f0             	pushl  -0x10(%ebp)
801083b1:	e8 36 a8 ff ff       	call   80102bec <kfree>
801083b6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801083b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801083bd:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801083c4:	76 a8                	jbe    8010836e <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
801083c6:	83 ec 0c             	sub    $0xc,%esp
801083c9:	ff 75 08             	pushl  0x8(%ebp)
801083cc:	e8 1b a8 ff ff       	call   80102bec <kfree>
801083d1:	83 c4 10             	add    $0x10,%esp
}
801083d4:	90                   	nop
801083d5:	c9                   	leave  
801083d6:	c3                   	ret    

801083d7 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801083d7:	55                   	push   %ebp
801083d8:	89 e5                	mov    %esp,%ebp
801083da:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801083dd:	83 ec 04             	sub    $0x4,%esp
801083e0:	6a 00                	push   $0x0
801083e2:	ff 75 0c             	pushl  0xc(%ebp)
801083e5:	ff 75 08             	pushl  0x8(%ebp)
801083e8:	e8 ee f8 ff ff       	call   80107cdb <walkpgdir>
801083ed:	83 c4 10             	add    $0x10,%esp
801083f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801083f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801083f7:	75 0d                	jne    80108406 <clearpteu+0x2f>
    panic("clearpteu");
801083f9:	83 ec 0c             	sub    $0xc,%esp
801083fc:	68 f4 8c 10 80       	push   $0x80108cf4
80108401:	e8 75 81 ff ff       	call   8010057b <panic>
  *pte &= ~PTE_U;
80108406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108409:	8b 00                	mov    (%eax),%eax
8010840b:	83 e0 fb             	and    $0xfffffffb,%eax
8010840e:	89 c2                	mov    %eax,%edx
80108410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108413:	89 10                	mov    %edx,(%eax)
}
80108415:	90                   	nop
80108416:	c9                   	leave  
80108417:	c3                   	ret    

80108418 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108418:	55                   	push   %ebp
80108419:	89 e5                	mov    %esp,%ebp
8010841b:	53                   	push   %ebx
8010841c:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010841f:	e8 e7 f9 ff ff       	call   80107e0b <setupkvm>
80108424:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108427:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010842b:	75 0a                	jne    80108437 <copyuvm+0x1f>
    return 0;
8010842d:	b8 00 00 00 00       	mov    $0x0,%eax
80108432:	e9 f6 00 00 00       	jmp    8010852d <copyuvm+0x115>
  for(i = 0; i < sz; i += PGSIZE){
80108437:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010843e:	e9 c2 00 00 00       	jmp    80108505 <copyuvm+0xed>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108443:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108446:	83 ec 04             	sub    $0x4,%esp
80108449:	6a 00                	push   $0x0
8010844b:	50                   	push   %eax
8010844c:	ff 75 08             	pushl  0x8(%ebp)
8010844f:	e8 87 f8 ff ff       	call   80107cdb <walkpgdir>
80108454:	83 c4 10             	add    $0x10,%esp
80108457:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010845a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010845e:	75 0d                	jne    8010846d <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80108460:	83 ec 0c             	sub    $0xc,%esp
80108463:	68 fe 8c 10 80       	push   $0x80108cfe
80108468:	e8 0e 81 ff ff       	call   8010057b <panic>
    if(!(*pte & PTE_P))
8010846d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108470:	8b 00                	mov    (%eax),%eax
80108472:	83 e0 01             	and    $0x1,%eax
80108475:	85 c0                	test   %eax,%eax
80108477:	75 0d                	jne    80108486 <copyuvm+0x6e>
      panic("copyuvm: page not present");
80108479:	83 ec 0c             	sub    $0xc,%esp
8010847c:	68 18 8d 10 80       	push   $0x80108d18
80108481:	e8 f5 80 ff ff       	call   8010057b <panic>
    pa = PTE_ADDR(*pte);
80108486:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108489:	8b 00                	mov    (%eax),%eax
8010848b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108490:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108493:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108496:	8b 00                	mov    (%eax),%eax
80108498:	25 ff 0f 00 00       	and    $0xfff,%eax
8010849d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801084a0:	e8 e4 a7 ff ff       	call   80102c89 <kalloc>
801084a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801084a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801084ac:	74 68                	je     80108516 <copyuvm+0xfe>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801084ae:	83 ec 0c             	sub    $0xc,%esp
801084b1:	ff 75 e8             	pushl  -0x18(%ebp)
801084b4:	e8 a0 f3 ff ff       	call   80107859 <p2v>
801084b9:	83 c4 10             	add    $0x10,%esp
801084bc:	83 ec 04             	sub    $0x4,%esp
801084bf:	68 00 10 00 00       	push   $0x1000
801084c4:	50                   	push   %eax
801084c5:	ff 75 e0             	pushl  -0x20(%ebp)
801084c8:	e8 d7 ce ff ff       	call   801053a4 <memmove>
801084cd:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801084d0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801084d3:	83 ec 0c             	sub    $0xc,%esp
801084d6:	ff 75 e0             	pushl  -0x20(%ebp)
801084d9:	e8 6e f3 ff ff       	call   8010784c <v2p>
801084de:	83 c4 10             	add    $0x10,%esp
801084e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084e4:	83 ec 0c             	sub    $0xc,%esp
801084e7:	53                   	push   %ebx
801084e8:	50                   	push   %eax
801084e9:	68 00 10 00 00       	push   $0x1000
801084ee:	52                   	push   %edx
801084ef:	ff 75 f0             	pushl  -0x10(%ebp)
801084f2:	e8 84 f8 ff ff       	call   80107d7b <mappages>
801084f7:	83 c4 20             	add    $0x20,%esp
801084fa:	85 c0                	test   %eax,%eax
801084fc:	78 1b                	js     80108519 <copyuvm+0x101>
  for(i = 0; i < sz; i += PGSIZE){
801084fe:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108508:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010850b:	0f 82 32 ff ff ff    	jb     80108443 <copyuvm+0x2b>
      goto bad;
  }
  return d;
80108511:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108514:	eb 17                	jmp    8010852d <copyuvm+0x115>
      goto bad;
80108516:	90                   	nop
80108517:	eb 01                	jmp    8010851a <copyuvm+0x102>
      goto bad;
80108519:	90                   	nop

bad:
  freevm(d);
8010851a:	83 ec 0c             	sub    $0xc,%esp
8010851d:	ff 75 f0             	pushl  -0x10(%ebp)
80108520:	e8 12 fe ff ff       	call   80108337 <freevm>
80108525:	83 c4 10             	add    $0x10,%esp
  return 0;
80108528:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010852d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108530:	c9                   	leave  
80108531:	c3                   	ret    

80108532 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108532:	55                   	push   %ebp
80108533:	89 e5                	mov    %esp,%ebp
80108535:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108538:	83 ec 04             	sub    $0x4,%esp
8010853b:	6a 00                	push   $0x0
8010853d:	ff 75 0c             	pushl  0xc(%ebp)
80108540:	ff 75 08             	pushl  0x8(%ebp)
80108543:	e8 93 f7 ff ff       	call   80107cdb <walkpgdir>
80108548:	83 c4 10             	add    $0x10,%esp
8010854b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010854e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108551:	8b 00                	mov    (%eax),%eax
80108553:	83 e0 01             	and    $0x1,%eax
80108556:	85 c0                	test   %eax,%eax
80108558:	75 07                	jne    80108561 <uva2ka+0x2f>
    return 0;
8010855a:	b8 00 00 00 00       	mov    $0x0,%eax
8010855f:	eb 2a                	jmp    8010858b <uva2ka+0x59>
  if((*pte & PTE_U) == 0)
80108561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108564:	8b 00                	mov    (%eax),%eax
80108566:	83 e0 04             	and    $0x4,%eax
80108569:	85 c0                	test   %eax,%eax
8010856b:	75 07                	jne    80108574 <uva2ka+0x42>
    return 0;
8010856d:	b8 00 00 00 00       	mov    $0x0,%eax
80108572:	eb 17                	jmp    8010858b <uva2ka+0x59>
  return (char*)p2v(PTE_ADDR(*pte));
80108574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108577:	8b 00                	mov    (%eax),%eax
80108579:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010857e:	83 ec 0c             	sub    $0xc,%esp
80108581:	50                   	push   %eax
80108582:	e8 d2 f2 ff ff       	call   80107859 <p2v>
80108587:	83 c4 10             	add    $0x10,%esp
8010858a:	90                   	nop
}
8010858b:	c9                   	leave  
8010858c:	c3                   	ret    

8010858d <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010858d:	55                   	push   %ebp
8010858e:	89 e5                	mov    %esp,%ebp
80108590:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108593:	8b 45 10             	mov    0x10(%ebp),%eax
80108596:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108599:	eb 7f                	jmp    8010861a <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010859b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010859e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801085a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085a9:	83 ec 08             	sub    $0x8,%esp
801085ac:	50                   	push   %eax
801085ad:	ff 75 08             	pushl  0x8(%ebp)
801085b0:	e8 7d ff ff ff       	call   80108532 <uva2ka>
801085b5:	83 c4 10             	add    $0x10,%esp
801085b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801085bb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801085bf:	75 07                	jne    801085c8 <copyout+0x3b>
      return -1;
801085c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801085c6:	eb 61                	jmp    80108629 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801085c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085cb:	2b 45 0c             	sub    0xc(%ebp),%eax
801085ce:	05 00 10 00 00       	add    $0x1000,%eax
801085d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801085d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085d9:	3b 45 14             	cmp    0x14(%ebp),%eax
801085dc:	76 06                	jbe    801085e4 <copyout+0x57>
      n = len;
801085de:	8b 45 14             	mov    0x14(%ebp),%eax
801085e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801085e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801085e7:	2b 45 ec             	sub    -0x14(%ebp),%eax
801085ea:	89 c2                	mov    %eax,%edx
801085ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085ef:	01 d0                	add    %edx,%eax
801085f1:	83 ec 04             	sub    $0x4,%esp
801085f4:	ff 75 f0             	pushl  -0x10(%ebp)
801085f7:	ff 75 f4             	pushl  -0xc(%ebp)
801085fa:	50                   	push   %eax
801085fb:	e8 a4 cd ff ff       	call   801053a4 <memmove>
80108600:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108606:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108609:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010860c:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010860f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108612:	05 00 10 00 00       	add    $0x1000,%eax
80108617:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010861a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010861e:	0f 85 77 ff ff ff    	jne    8010859b <copyout+0xe>
  }
  return 0;
80108624:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108629:	c9                   	leave  
8010862a:	c3                   	ret    
