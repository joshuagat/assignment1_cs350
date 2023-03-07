
_sleep-echo:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 10             	sub    $0x10,%esp
  12:	89 cb                	mov    %ecx,%ebx
    int i = 0;
  14:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	sleep(500);
  1b:	83 ec 0c             	sub    $0xc,%esp
  1e:	68 f4 01 00 00       	push   $0x1f4
  23:	e8 46 03 00 00       	call   36e <sleep>
  28:	83 c4 10             	add    $0x10,%esp
    
    for (i = 1; i < argc; i++)
  2b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  32:	eb 35                	jmp    69 <main+0x69>
    {
        printf(1, argv[i]);
  34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  3e:	8b 43 04             	mov    0x4(%ebx),%eax
  41:	01 d0                	add    %edx,%eax
  43:	8b 00                	mov    (%eax),%eax
  45:	83 ec 08             	sub    $0x8,%esp
  48:	50                   	push   %eax
  49:	6a 01                	push   $0x1
  4b:	e8 12 04 00 00       	call   462 <printf>
  50:	83 c4 10             	add    $0x10,%esp
        printf(1, " ");
  53:	83 ec 08             	sub    $0x8,%esp
  56:	68 19 08 00 00       	push   $0x819
  5b:	6a 01                	push   $0x1
  5d:	e8 00 04 00 00       	call   462 <printf>
  62:	83 c4 10             	add    $0x10,%esp
    for (i = 1; i < argc; i++)
  65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6c:	3b 03                	cmp    (%ebx),%eax
  6e:	7c c4                	jl     34 <main+0x34>
    }

    printf(1, "\n");
  70:	83 ec 08             	sub    $0x8,%esp
  73:	68 1b 08 00 00       	push   $0x81b
  78:	6a 01                	push   $0x1
  7a:	e8 e3 03 00 00       	call   462 <printf>
  7f:	83 c4 10             	add    $0x10,%esp
    
    exit();
  82:	e8 57 02 00 00       	call   2de <exit>

00000087 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  87:	55                   	push   %ebp
  88:	89 e5                	mov    %esp,%ebp
  8a:	57                   	push   %edi
  8b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8f:	8b 55 10             	mov    0x10(%ebp),%edx
  92:	8b 45 0c             	mov    0xc(%ebp),%eax
  95:	89 cb                	mov    %ecx,%ebx
  97:	89 df                	mov    %ebx,%edi
  99:	89 d1                	mov    %edx,%ecx
  9b:	fc                   	cld    
  9c:	f3 aa                	rep stos %al,%es:(%edi)
  9e:	89 ca                	mov    %ecx,%edx
  a0:	89 fb                	mov    %edi,%ebx
  a2:	89 5d 08             	mov    %ebx,0x8(%ebp)
  a5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  a8:	90                   	nop
  a9:	5b                   	pop    %ebx
  aa:	5f                   	pop    %edi
  ab:	5d                   	pop    %ebp
  ac:	c3                   	ret    

000000ad <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  ad:	55                   	push   %ebp
  ae:	89 e5                	mov    %esp,%ebp
  b0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  b3:	8b 45 08             	mov    0x8(%ebp),%eax
  b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  b9:	90                   	nop
  ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  bd:	8d 42 01             	lea    0x1(%edx),%eax
  c0:	89 45 0c             	mov    %eax,0xc(%ebp)
  c3:	8b 45 08             	mov    0x8(%ebp),%eax
  c6:	8d 48 01             	lea    0x1(%eax),%ecx
  c9:	89 4d 08             	mov    %ecx,0x8(%ebp)
  cc:	0f b6 12             	movzbl (%edx),%edx
  cf:	88 10                	mov    %dl,(%eax)
  d1:	0f b6 00             	movzbl (%eax),%eax
  d4:	84 c0                	test   %al,%al
  d6:	75 e2                	jne    ba <strcpy+0xd>
    ;
  return os;
  d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  db:	c9                   	leave  
  dc:	c3                   	ret    

000000dd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  dd:	55                   	push   %ebp
  de:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  e0:	eb 08                	jmp    ea <strcmp+0xd>
    p++, q++;
  e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  e6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  ea:	8b 45 08             	mov    0x8(%ebp),%eax
  ed:	0f b6 00             	movzbl (%eax),%eax
  f0:	84 c0                	test   %al,%al
  f2:	74 10                	je     104 <strcmp+0x27>
  f4:	8b 45 08             	mov    0x8(%ebp),%eax
  f7:	0f b6 10             	movzbl (%eax),%edx
  fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  fd:	0f b6 00             	movzbl (%eax),%eax
 100:	38 c2                	cmp    %al,%dl
 102:	74 de                	je     e2 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 104:	8b 45 08             	mov    0x8(%ebp),%eax
 107:	0f b6 00             	movzbl (%eax),%eax
 10a:	0f b6 d0             	movzbl %al,%edx
 10d:	8b 45 0c             	mov    0xc(%ebp),%eax
 110:	0f b6 00             	movzbl (%eax),%eax
 113:	0f b6 c8             	movzbl %al,%ecx
 116:	89 d0                	mov    %edx,%eax
 118:	29 c8                	sub    %ecx,%eax
}
 11a:	5d                   	pop    %ebp
 11b:	c3                   	ret    

0000011c <strlen>:

uint
strlen(char *s)
{
 11c:	55                   	push   %ebp
 11d:	89 e5                	mov    %esp,%ebp
 11f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 122:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 129:	eb 04                	jmp    12f <strlen+0x13>
 12b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 12f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 132:	8b 45 08             	mov    0x8(%ebp),%eax
 135:	01 d0                	add    %edx,%eax
 137:	0f b6 00             	movzbl (%eax),%eax
 13a:	84 c0                	test   %al,%al
 13c:	75 ed                	jne    12b <strlen+0xf>
    ;
  return n;
 13e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 141:	c9                   	leave  
 142:	c3                   	ret    

00000143 <memset>:

void*
memset(void *dst, int c, uint n)
{
 143:	55                   	push   %ebp
 144:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 146:	8b 45 10             	mov    0x10(%ebp),%eax
 149:	50                   	push   %eax
 14a:	ff 75 0c             	pushl  0xc(%ebp)
 14d:	ff 75 08             	pushl  0x8(%ebp)
 150:	e8 32 ff ff ff       	call   87 <stosb>
 155:	83 c4 0c             	add    $0xc,%esp
  return dst;
 158:	8b 45 08             	mov    0x8(%ebp),%eax
}
 15b:	c9                   	leave  
 15c:	c3                   	ret    

0000015d <strchr>:

char*
strchr(const char *s, char c)
{
 15d:	55                   	push   %ebp
 15e:	89 e5                	mov    %esp,%ebp
 160:	83 ec 04             	sub    $0x4,%esp
 163:	8b 45 0c             	mov    0xc(%ebp),%eax
 166:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 169:	eb 14                	jmp    17f <strchr+0x22>
    if(*s == c)
 16b:	8b 45 08             	mov    0x8(%ebp),%eax
 16e:	0f b6 00             	movzbl (%eax),%eax
 171:	38 45 fc             	cmp    %al,-0x4(%ebp)
 174:	75 05                	jne    17b <strchr+0x1e>
      return (char*)s;
 176:	8b 45 08             	mov    0x8(%ebp),%eax
 179:	eb 13                	jmp    18e <strchr+0x31>
  for(; *s; s++)
 17b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17f:	8b 45 08             	mov    0x8(%ebp),%eax
 182:	0f b6 00             	movzbl (%eax),%eax
 185:	84 c0                	test   %al,%al
 187:	75 e2                	jne    16b <strchr+0xe>
  return 0;
 189:	b8 00 00 00 00       	mov    $0x0,%eax
}
 18e:	c9                   	leave  
 18f:	c3                   	ret    

00000190 <gets>:

char*
gets(char *buf, int max)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
 193:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 196:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 19d:	eb 42                	jmp    1e1 <gets+0x51>
    cc = read(0, &c, 1);
 19f:	83 ec 04             	sub    $0x4,%esp
 1a2:	6a 01                	push   $0x1
 1a4:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1a7:	50                   	push   %eax
 1a8:	6a 00                	push   $0x0
 1aa:	e8 47 01 00 00       	call   2f6 <read>
 1af:	83 c4 10             	add    $0x10,%esp
 1b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1b9:	7e 33                	jle    1ee <gets+0x5e>
      break;
    buf[i++] = c;
 1bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1be:	8d 50 01             	lea    0x1(%eax),%edx
 1c1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1c4:	89 c2                	mov    %eax,%edx
 1c6:	8b 45 08             	mov    0x8(%ebp),%eax
 1c9:	01 c2                	add    %eax,%edx
 1cb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1cf:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1d1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d5:	3c 0a                	cmp    $0xa,%al
 1d7:	74 16                	je     1ef <gets+0x5f>
 1d9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1dd:	3c 0d                	cmp    $0xd,%al
 1df:	74 0e                	je     1ef <gets+0x5f>
  for(i=0; i+1 < max; ){
 1e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e4:	83 c0 01             	add    $0x1,%eax
 1e7:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1ea:	7f b3                	jg     19f <gets+0xf>
 1ec:	eb 01                	jmp    1ef <gets+0x5f>
      break;
 1ee:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
 1f5:	01 d0                	add    %edx,%eax
 1f7:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1fd:	c9                   	leave  
 1fe:	c3                   	ret    

000001ff <stat>:

int
stat(char *n, struct stat *st)
{
 1ff:	55                   	push   %ebp
 200:	89 e5                	mov    %esp,%ebp
 202:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 205:	83 ec 08             	sub    $0x8,%esp
 208:	6a 00                	push   $0x0
 20a:	ff 75 08             	pushl  0x8(%ebp)
 20d:	e8 0c 01 00 00       	call   31e <open>
 212:	83 c4 10             	add    $0x10,%esp
 215:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 218:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 21c:	79 07                	jns    225 <stat+0x26>
    return -1;
 21e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 223:	eb 25                	jmp    24a <stat+0x4b>
  r = fstat(fd, st);
 225:	83 ec 08             	sub    $0x8,%esp
 228:	ff 75 0c             	pushl  0xc(%ebp)
 22b:	ff 75 f4             	pushl  -0xc(%ebp)
 22e:	e8 03 01 00 00       	call   336 <fstat>
 233:	83 c4 10             	add    $0x10,%esp
 236:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 239:	83 ec 0c             	sub    $0xc,%esp
 23c:	ff 75 f4             	pushl  -0xc(%ebp)
 23f:	e8 c2 00 00 00       	call   306 <close>
 244:	83 c4 10             	add    $0x10,%esp
  return r;
 247:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 24a:	c9                   	leave  
 24b:	c3                   	ret    

0000024c <atoi>:

int
atoi(const char *s)
{
 24c:	55                   	push   %ebp
 24d:	89 e5                	mov    %esp,%ebp
 24f:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 252:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 259:	eb 25                	jmp    280 <atoi+0x34>
    n = n*10 + *s++ - '0';
 25b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 25e:	89 d0                	mov    %edx,%eax
 260:	c1 e0 02             	shl    $0x2,%eax
 263:	01 d0                	add    %edx,%eax
 265:	01 c0                	add    %eax,%eax
 267:	89 c1                	mov    %eax,%ecx
 269:	8b 45 08             	mov    0x8(%ebp),%eax
 26c:	8d 50 01             	lea    0x1(%eax),%edx
 26f:	89 55 08             	mov    %edx,0x8(%ebp)
 272:	0f b6 00             	movzbl (%eax),%eax
 275:	0f be c0             	movsbl %al,%eax
 278:	01 c8                	add    %ecx,%eax
 27a:	83 e8 30             	sub    $0x30,%eax
 27d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 280:	8b 45 08             	mov    0x8(%ebp),%eax
 283:	0f b6 00             	movzbl (%eax),%eax
 286:	3c 2f                	cmp    $0x2f,%al
 288:	7e 0a                	jle    294 <atoi+0x48>
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	0f b6 00             	movzbl (%eax),%eax
 290:	3c 39                	cmp    $0x39,%al
 292:	7e c7                	jle    25b <atoi+0xf>
  return n;
 294:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 297:	c9                   	leave  
 298:	c3                   	ret    

00000299 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 299:	55                   	push   %ebp
 29a:	89 e5                	mov    %esp,%ebp
 29c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 29f:	8b 45 08             	mov    0x8(%ebp),%eax
 2a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2a5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2ab:	eb 17                	jmp    2c4 <memmove+0x2b>
    *dst++ = *src++;
 2ad:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2b0:	8d 42 01             	lea    0x1(%edx),%eax
 2b3:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2b9:	8d 48 01             	lea    0x1(%eax),%ecx
 2bc:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2bf:	0f b6 12             	movzbl (%edx),%edx
 2c2:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2c4:	8b 45 10             	mov    0x10(%ebp),%eax
 2c7:	8d 50 ff             	lea    -0x1(%eax),%edx
 2ca:	89 55 10             	mov    %edx,0x10(%ebp)
 2cd:	85 c0                	test   %eax,%eax
 2cf:	7f dc                	jg     2ad <memmove+0x14>
  return vdst;
 2d1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2d4:	c9                   	leave  
 2d5:	c3                   	ret    

000002d6 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2d6:	b8 01 00 00 00       	mov    $0x1,%eax
 2db:	cd 40                	int    $0x40
 2dd:	c3                   	ret    

000002de <exit>:
SYSCALL(exit)
 2de:	b8 02 00 00 00       	mov    $0x2,%eax
 2e3:	cd 40                	int    $0x40
 2e5:	c3                   	ret    

000002e6 <wait>:
SYSCALL(wait)
 2e6:	b8 03 00 00 00       	mov    $0x3,%eax
 2eb:	cd 40                	int    $0x40
 2ed:	c3                   	ret    

000002ee <pipe>:
SYSCALL(pipe)
 2ee:	b8 04 00 00 00       	mov    $0x4,%eax
 2f3:	cd 40                	int    $0x40
 2f5:	c3                   	ret    

000002f6 <read>:
SYSCALL(read)
 2f6:	b8 05 00 00 00       	mov    $0x5,%eax
 2fb:	cd 40                	int    $0x40
 2fd:	c3                   	ret    

000002fe <write>:
SYSCALL(write)
 2fe:	b8 10 00 00 00       	mov    $0x10,%eax
 303:	cd 40                	int    $0x40
 305:	c3                   	ret    

00000306 <close>:
SYSCALL(close)
 306:	b8 15 00 00 00       	mov    $0x15,%eax
 30b:	cd 40                	int    $0x40
 30d:	c3                   	ret    

0000030e <kill>:
SYSCALL(kill)
 30e:	b8 06 00 00 00       	mov    $0x6,%eax
 313:	cd 40                	int    $0x40
 315:	c3                   	ret    

00000316 <exec>:
SYSCALL(exec)
 316:	b8 07 00 00 00       	mov    $0x7,%eax
 31b:	cd 40                	int    $0x40
 31d:	c3                   	ret    

0000031e <open>:
SYSCALL(open)
 31e:	b8 0f 00 00 00       	mov    $0xf,%eax
 323:	cd 40                	int    $0x40
 325:	c3                   	ret    

00000326 <mknod>:
SYSCALL(mknod)
 326:	b8 11 00 00 00       	mov    $0x11,%eax
 32b:	cd 40                	int    $0x40
 32d:	c3                   	ret    

0000032e <unlink>:
SYSCALL(unlink)
 32e:	b8 12 00 00 00       	mov    $0x12,%eax
 333:	cd 40                	int    $0x40
 335:	c3                   	ret    

00000336 <fstat>:
SYSCALL(fstat)
 336:	b8 08 00 00 00       	mov    $0x8,%eax
 33b:	cd 40                	int    $0x40
 33d:	c3                   	ret    

0000033e <link>:
SYSCALL(link)
 33e:	b8 13 00 00 00       	mov    $0x13,%eax
 343:	cd 40                	int    $0x40
 345:	c3                   	ret    

00000346 <mkdir>:
SYSCALL(mkdir)
 346:	b8 14 00 00 00       	mov    $0x14,%eax
 34b:	cd 40                	int    $0x40
 34d:	c3                   	ret    

0000034e <chdir>:
SYSCALL(chdir)
 34e:	b8 09 00 00 00       	mov    $0x9,%eax
 353:	cd 40                	int    $0x40
 355:	c3                   	ret    

00000356 <dup>:
SYSCALL(dup)
 356:	b8 0a 00 00 00       	mov    $0xa,%eax
 35b:	cd 40                	int    $0x40
 35d:	c3                   	ret    

0000035e <getpid>:
SYSCALL(getpid)
 35e:	b8 0b 00 00 00       	mov    $0xb,%eax
 363:	cd 40                	int    $0x40
 365:	c3                   	ret    

00000366 <sbrk>:
SYSCALL(sbrk)
 366:	b8 0c 00 00 00       	mov    $0xc,%eax
 36b:	cd 40                	int    $0x40
 36d:	c3                   	ret    

0000036e <sleep>:
SYSCALL(sleep)
 36e:	b8 0d 00 00 00       	mov    $0xd,%eax
 373:	cd 40                	int    $0x40
 375:	c3                   	ret    

00000376 <uptime>:
SYSCALL(uptime)
 376:	b8 0e 00 00 00       	mov    $0xe,%eax
 37b:	cd 40                	int    $0x40
 37d:	c3                   	ret    

0000037e <enable_sched_trace>:
SYSCALL(enable_sched_trace)
 37e:	b8 16 00 00 00       	mov    $0x16,%eax
 383:	cd 40                	int    $0x40
 385:	c3                   	ret    

00000386 <uprog_shut>:
SYSCALL(uprog_shut)
 386:	b8 17 00 00 00       	mov    $0x17,%eax
 38b:	cd 40                	int    $0x40
 38d:	c3                   	ret    

0000038e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 38e:	55                   	push   %ebp
 38f:	89 e5                	mov    %esp,%ebp
 391:	83 ec 18             	sub    $0x18,%esp
 394:	8b 45 0c             	mov    0xc(%ebp),%eax
 397:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 39a:	83 ec 04             	sub    $0x4,%esp
 39d:	6a 01                	push   $0x1
 39f:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3a2:	50                   	push   %eax
 3a3:	ff 75 08             	pushl  0x8(%ebp)
 3a6:	e8 53 ff ff ff       	call   2fe <write>
 3ab:	83 c4 10             	add    $0x10,%esp
}
 3ae:	90                   	nop
 3af:	c9                   	leave  
 3b0:	c3                   	ret    

000003b1 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b1:	55                   	push   %ebp
 3b2:	89 e5                	mov    %esp,%ebp
 3b4:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3b7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3be:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3c2:	74 17                	je     3db <printint+0x2a>
 3c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3c8:	79 11                	jns    3db <printint+0x2a>
    neg = 1;
 3ca:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d4:	f7 d8                	neg    %eax
 3d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3d9:	eb 06                	jmp    3e1 <printint+0x30>
  } else {
    x = xx;
 3db:	8b 45 0c             	mov    0xc(%ebp),%eax
 3de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ee:	ba 00 00 00 00       	mov    $0x0,%edx
 3f3:	f7 f1                	div    %ecx
 3f5:	89 d1                	mov    %edx,%ecx
 3f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3fa:	8d 50 01             	lea    0x1(%eax),%edx
 3fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 400:	0f b6 91 6c 0a 00 00 	movzbl 0xa6c(%ecx),%edx
 407:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 40b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 40e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 411:	ba 00 00 00 00       	mov    $0x0,%edx
 416:	f7 f1                	div    %ecx
 418:	89 45 ec             	mov    %eax,-0x14(%ebp)
 41b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 41f:	75 c7                	jne    3e8 <printint+0x37>
  if(neg)
 421:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 425:	74 2d                	je     454 <printint+0xa3>
    buf[i++] = '-';
 427:	8b 45 f4             	mov    -0xc(%ebp),%eax
 42a:	8d 50 01             	lea    0x1(%eax),%edx
 42d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 430:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 435:	eb 1d                	jmp    454 <printint+0xa3>
    putc(fd, buf[i]);
 437:	8d 55 dc             	lea    -0x24(%ebp),%edx
 43a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 43d:	01 d0                	add    %edx,%eax
 43f:	0f b6 00             	movzbl (%eax),%eax
 442:	0f be c0             	movsbl %al,%eax
 445:	83 ec 08             	sub    $0x8,%esp
 448:	50                   	push   %eax
 449:	ff 75 08             	pushl  0x8(%ebp)
 44c:	e8 3d ff ff ff       	call   38e <putc>
 451:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 454:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 458:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 45c:	79 d9                	jns    437 <printint+0x86>
}
 45e:	90                   	nop
 45f:	90                   	nop
 460:	c9                   	leave  
 461:	c3                   	ret    

00000462 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 462:	55                   	push   %ebp
 463:	89 e5                	mov    %esp,%ebp
 465:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 468:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 46f:	8d 45 0c             	lea    0xc(%ebp),%eax
 472:	83 c0 04             	add    $0x4,%eax
 475:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 478:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 47f:	e9 59 01 00 00       	jmp    5dd <printf+0x17b>
    c = fmt[i] & 0xff;
 484:	8b 55 0c             	mov    0xc(%ebp),%edx
 487:	8b 45 f0             	mov    -0x10(%ebp),%eax
 48a:	01 d0                	add    %edx,%eax
 48c:	0f b6 00             	movzbl (%eax),%eax
 48f:	0f be c0             	movsbl %al,%eax
 492:	25 ff 00 00 00       	and    $0xff,%eax
 497:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 49a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 49e:	75 2c                	jne    4cc <printf+0x6a>
      if(c == '%'){
 4a0:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4a4:	75 0c                	jne    4b2 <printf+0x50>
        state = '%';
 4a6:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4ad:	e9 27 01 00 00       	jmp    5d9 <printf+0x177>
      } else {
        putc(fd, c);
 4b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4b5:	0f be c0             	movsbl %al,%eax
 4b8:	83 ec 08             	sub    $0x8,%esp
 4bb:	50                   	push   %eax
 4bc:	ff 75 08             	pushl  0x8(%ebp)
 4bf:	e8 ca fe ff ff       	call   38e <putc>
 4c4:	83 c4 10             	add    $0x10,%esp
 4c7:	e9 0d 01 00 00       	jmp    5d9 <printf+0x177>
      }
    } else if(state == '%'){
 4cc:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4d0:	0f 85 03 01 00 00    	jne    5d9 <printf+0x177>
      if(c == 'd'){
 4d6:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4da:	75 1e                	jne    4fa <printf+0x98>
        printint(fd, *ap, 10, 1);
 4dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4df:	8b 00                	mov    (%eax),%eax
 4e1:	6a 01                	push   $0x1
 4e3:	6a 0a                	push   $0xa
 4e5:	50                   	push   %eax
 4e6:	ff 75 08             	pushl  0x8(%ebp)
 4e9:	e8 c3 fe ff ff       	call   3b1 <printint>
 4ee:	83 c4 10             	add    $0x10,%esp
        ap++;
 4f1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4f5:	e9 d8 00 00 00       	jmp    5d2 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4fa:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4fe:	74 06                	je     506 <printf+0xa4>
 500:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 504:	75 1e                	jne    524 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 506:	8b 45 e8             	mov    -0x18(%ebp),%eax
 509:	8b 00                	mov    (%eax),%eax
 50b:	6a 00                	push   $0x0
 50d:	6a 10                	push   $0x10
 50f:	50                   	push   %eax
 510:	ff 75 08             	pushl  0x8(%ebp)
 513:	e8 99 fe ff ff       	call   3b1 <printint>
 518:	83 c4 10             	add    $0x10,%esp
        ap++;
 51b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 51f:	e9 ae 00 00 00       	jmp    5d2 <printf+0x170>
      } else if(c == 's'){
 524:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 528:	75 43                	jne    56d <printf+0x10b>
        s = (char*)*ap;
 52a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 52d:	8b 00                	mov    (%eax),%eax
 52f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 532:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 536:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 53a:	75 25                	jne    561 <printf+0xff>
          s = "(null)";
 53c:	c7 45 f4 1d 08 00 00 	movl   $0x81d,-0xc(%ebp)
        while(*s != 0){
 543:	eb 1c                	jmp    561 <printf+0xff>
          putc(fd, *s);
 545:	8b 45 f4             	mov    -0xc(%ebp),%eax
 548:	0f b6 00             	movzbl (%eax),%eax
 54b:	0f be c0             	movsbl %al,%eax
 54e:	83 ec 08             	sub    $0x8,%esp
 551:	50                   	push   %eax
 552:	ff 75 08             	pushl  0x8(%ebp)
 555:	e8 34 fe ff ff       	call   38e <putc>
 55a:	83 c4 10             	add    $0x10,%esp
          s++;
 55d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 561:	8b 45 f4             	mov    -0xc(%ebp),%eax
 564:	0f b6 00             	movzbl (%eax),%eax
 567:	84 c0                	test   %al,%al
 569:	75 da                	jne    545 <printf+0xe3>
 56b:	eb 65                	jmp    5d2 <printf+0x170>
        }
      } else if(c == 'c'){
 56d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 571:	75 1d                	jne    590 <printf+0x12e>
        putc(fd, *ap);
 573:	8b 45 e8             	mov    -0x18(%ebp),%eax
 576:	8b 00                	mov    (%eax),%eax
 578:	0f be c0             	movsbl %al,%eax
 57b:	83 ec 08             	sub    $0x8,%esp
 57e:	50                   	push   %eax
 57f:	ff 75 08             	pushl  0x8(%ebp)
 582:	e8 07 fe ff ff       	call   38e <putc>
 587:	83 c4 10             	add    $0x10,%esp
        ap++;
 58a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 58e:	eb 42                	jmp    5d2 <printf+0x170>
      } else if(c == '%'){
 590:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 594:	75 17                	jne    5ad <printf+0x14b>
        putc(fd, c);
 596:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 599:	0f be c0             	movsbl %al,%eax
 59c:	83 ec 08             	sub    $0x8,%esp
 59f:	50                   	push   %eax
 5a0:	ff 75 08             	pushl  0x8(%ebp)
 5a3:	e8 e6 fd ff ff       	call   38e <putc>
 5a8:	83 c4 10             	add    $0x10,%esp
 5ab:	eb 25                	jmp    5d2 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ad:	83 ec 08             	sub    $0x8,%esp
 5b0:	6a 25                	push   $0x25
 5b2:	ff 75 08             	pushl  0x8(%ebp)
 5b5:	e8 d4 fd ff ff       	call   38e <putc>
 5ba:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c0:	0f be c0             	movsbl %al,%eax
 5c3:	83 ec 08             	sub    $0x8,%esp
 5c6:	50                   	push   %eax
 5c7:	ff 75 08             	pushl  0x8(%ebp)
 5ca:	e8 bf fd ff ff       	call   38e <putc>
 5cf:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5d2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5d9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5dd:	8b 55 0c             	mov    0xc(%ebp),%edx
 5e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5e3:	01 d0                	add    %edx,%eax
 5e5:	0f b6 00             	movzbl (%eax),%eax
 5e8:	84 c0                	test   %al,%al
 5ea:	0f 85 94 fe ff ff    	jne    484 <printf+0x22>
    }
  }
}
 5f0:	90                   	nop
 5f1:	90                   	nop
 5f2:	c9                   	leave  
 5f3:	c3                   	ret    

000005f4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5f4:	55                   	push   %ebp
 5f5:	89 e5                	mov    %esp,%ebp
 5f7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5fa:	8b 45 08             	mov    0x8(%ebp),%eax
 5fd:	83 e8 08             	sub    $0x8,%eax
 600:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 603:	a1 88 0a 00 00       	mov    0xa88,%eax
 608:	89 45 fc             	mov    %eax,-0x4(%ebp)
 60b:	eb 24                	jmp    631 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 60d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 610:	8b 00                	mov    (%eax),%eax
 612:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 615:	72 12                	jb     629 <free+0x35>
 617:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 61d:	77 24                	ja     643 <free+0x4f>
 61f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 622:	8b 00                	mov    (%eax),%eax
 624:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 627:	72 1a                	jb     643 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 629:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62c:	8b 00                	mov    (%eax),%eax
 62e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 631:	8b 45 f8             	mov    -0x8(%ebp),%eax
 634:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 637:	76 d4                	jbe    60d <free+0x19>
 639:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63c:	8b 00                	mov    (%eax),%eax
 63e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 641:	73 ca                	jae    60d <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 643:	8b 45 f8             	mov    -0x8(%ebp),%eax
 646:	8b 40 04             	mov    0x4(%eax),%eax
 649:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 650:	8b 45 f8             	mov    -0x8(%ebp),%eax
 653:	01 c2                	add    %eax,%edx
 655:	8b 45 fc             	mov    -0x4(%ebp),%eax
 658:	8b 00                	mov    (%eax),%eax
 65a:	39 c2                	cmp    %eax,%edx
 65c:	75 24                	jne    682 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 65e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 661:	8b 50 04             	mov    0x4(%eax),%edx
 664:	8b 45 fc             	mov    -0x4(%ebp),%eax
 667:	8b 00                	mov    (%eax),%eax
 669:	8b 40 04             	mov    0x4(%eax),%eax
 66c:	01 c2                	add    %eax,%edx
 66e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 671:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 674:	8b 45 fc             	mov    -0x4(%ebp),%eax
 677:	8b 00                	mov    (%eax),%eax
 679:	8b 10                	mov    (%eax),%edx
 67b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67e:	89 10                	mov    %edx,(%eax)
 680:	eb 0a                	jmp    68c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 682:	8b 45 fc             	mov    -0x4(%ebp),%eax
 685:	8b 10                	mov    (%eax),%edx
 687:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 68c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68f:	8b 40 04             	mov    0x4(%eax),%eax
 692:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 699:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69c:	01 d0                	add    %edx,%eax
 69e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6a1:	75 20                	jne    6c3 <free+0xcf>
    p->s.size += bp->s.size;
 6a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a6:	8b 50 04             	mov    0x4(%eax),%edx
 6a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ac:	8b 40 04             	mov    0x4(%eax),%eax
 6af:	01 c2                	add    %eax,%edx
 6b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ba:	8b 10                	mov    (%eax),%edx
 6bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bf:	89 10                	mov    %edx,(%eax)
 6c1:	eb 08                	jmp    6cb <free+0xd7>
  } else
    p->s.ptr = bp;
 6c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6c9:	89 10                	mov    %edx,(%eax)
  freep = p;
 6cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ce:	a3 88 0a 00 00       	mov    %eax,0xa88
}
 6d3:	90                   	nop
 6d4:	c9                   	leave  
 6d5:	c3                   	ret    

000006d6 <morecore>:

static Header*
morecore(uint nu)
{
 6d6:	55                   	push   %ebp
 6d7:	89 e5                	mov    %esp,%ebp
 6d9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6dc:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6e3:	77 07                	ja     6ec <morecore+0x16>
    nu = 4096;
 6e5:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6ec:	8b 45 08             	mov    0x8(%ebp),%eax
 6ef:	c1 e0 03             	shl    $0x3,%eax
 6f2:	83 ec 0c             	sub    $0xc,%esp
 6f5:	50                   	push   %eax
 6f6:	e8 6b fc ff ff       	call   366 <sbrk>
 6fb:	83 c4 10             	add    $0x10,%esp
 6fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 701:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 705:	75 07                	jne    70e <morecore+0x38>
    return 0;
 707:	b8 00 00 00 00       	mov    $0x0,%eax
 70c:	eb 26                	jmp    734 <morecore+0x5e>
  hp = (Header*)p;
 70e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 711:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 714:	8b 45 f0             	mov    -0x10(%ebp),%eax
 717:	8b 55 08             	mov    0x8(%ebp),%edx
 71a:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 71d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 720:	83 c0 08             	add    $0x8,%eax
 723:	83 ec 0c             	sub    $0xc,%esp
 726:	50                   	push   %eax
 727:	e8 c8 fe ff ff       	call   5f4 <free>
 72c:	83 c4 10             	add    $0x10,%esp
  return freep;
 72f:	a1 88 0a 00 00       	mov    0xa88,%eax
}
 734:	c9                   	leave  
 735:	c3                   	ret    

00000736 <malloc>:

void*
malloc(uint nbytes)
{
 736:	55                   	push   %ebp
 737:	89 e5                	mov    %esp,%ebp
 739:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 73c:	8b 45 08             	mov    0x8(%ebp),%eax
 73f:	83 c0 07             	add    $0x7,%eax
 742:	c1 e8 03             	shr    $0x3,%eax
 745:	83 c0 01             	add    $0x1,%eax
 748:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 74b:	a1 88 0a 00 00       	mov    0xa88,%eax
 750:	89 45 f0             	mov    %eax,-0x10(%ebp)
 753:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 757:	75 23                	jne    77c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 759:	c7 45 f0 80 0a 00 00 	movl   $0xa80,-0x10(%ebp)
 760:	8b 45 f0             	mov    -0x10(%ebp),%eax
 763:	a3 88 0a 00 00       	mov    %eax,0xa88
 768:	a1 88 0a 00 00       	mov    0xa88,%eax
 76d:	a3 80 0a 00 00       	mov    %eax,0xa80
    base.s.size = 0;
 772:	c7 05 84 0a 00 00 00 	movl   $0x0,0xa84
 779:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 77c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77f:	8b 00                	mov    (%eax),%eax
 781:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 784:	8b 45 f4             	mov    -0xc(%ebp),%eax
 787:	8b 40 04             	mov    0x4(%eax),%eax
 78a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 78d:	77 4d                	ja     7dc <malloc+0xa6>
      if(p->s.size == nunits)
 78f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 792:	8b 40 04             	mov    0x4(%eax),%eax
 795:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 798:	75 0c                	jne    7a6 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 79a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79d:	8b 10                	mov    (%eax),%edx
 79f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a2:	89 10                	mov    %edx,(%eax)
 7a4:	eb 26                	jmp    7cc <malloc+0x96>
      else {
        p->s.size -= nunits;
 7a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a9:	8b 40 04             	mov    0x4(%eax),%eax
 7ac:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7af:	89 c2                	mov    %eax,%edx
 7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b4:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ba:	8b 40 04             	mov    0x4(%eax),%eax
 7bd:	c1 e0 03             	shl    $0x3,%eax
 7c0:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c6:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7c9:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cf:	a3 88 0a 00 00       	mov    %eax,0xa88
      return (void*)(p + 1);
 7d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d7:	83 c0 08             	add    $0x8,%eax
 7da:	eb 3b                	jmp    817 <malloc+0xe1>
    }
    if(p == freep)
 7dc:	a1 88 0a 00 00       	mov    0xa88,%eax
 7e1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7e4:	75 1e                	jne    804 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7e6:	83 ec 0c             	sub    $0xc,%esp
 7e9:	ff 75 ec             	pushl  -0x14(%ebp)
 7ec:	e8 e5 fe ff ff       	call   6d6 <morecore>
 7f1:	83 c4 10             	add    $0x10,%esp
 7f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7fb:	75 07                	jne    804 <malloc+0xce>
        return 0;
 7fd:	b8 00 00 00 00       	mov    $0x0,%eax
 802:	eb 13                	jmp    817 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 804:	8b 45 f4             	mov    -0xc(%ebp),%eax
 807:	89 45 f0             	mov    %eax,-0x10(%ebp)
 80a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80d:	8b 00                	mov    (%eax),%eax
 80f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 812:	e9 6d ff ff ff       	jmp    784 <malloc+0x4e>
  }
}
 817:	c9                   	leave  
 818:	c3                   	ret    
