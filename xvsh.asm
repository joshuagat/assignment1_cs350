
_xvsh:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
int red_pos;

#define MAXLINE 256

int main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	81 ec 14 01 00 00    	sub    $0x114,%esp
    char buf[MAXLINE];
    int i;
    int n;
    printf(1, SH_PROMPT);  /* print prompt (printf requires %% to print %) */
  14:	83 ec 08             	sub    $0x8,%esp
  17:	68 72 0d 00 00       	push   $0xd72
  1c:	6a 01                	push   $0x1
  1e:	e8 98 09 00 00       	call   9bb <printf>
  23:	83 c4 10             	add    $0x10,%esp

    while ( (n = read(0, buf, MAXLINE)) != 0) 
  26:	eb 7d                	jmp    a5 <main+0xa5>
    {
        if (n == 1)                           /* no input at all, we should skip */
  28:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  2c:	75 14                	jne    42 <main+0x42>
        {
            printf(1, SH_PROMPT);
  2e:	83 ec 08             	sub    $0x8,%esp
  31:	68 72 0d 00 00       	push   $0xd72
  36:	6a 01                	push   $0x1
  38:	e8 7e 09 00 00       	call   9bb <printf>
  3d:	83 c4 10             	add    $0x10,%esp
            continue;
  40:	eb 63                	jmp    a5 <main+0xa5>
        }
        buf[i = (strlen(buf) - 1)] = 0;       /* replace newline with null */
  42:	83 ec 0c             	sub    $0xc,%esp
  45:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  4b:	50                   	push   %eax
  4c:	e8 24 06 00 00       	call   675 <strlen>
  51:	83 c4 10             	add    $0x10,%esp
  54:	83 e8 01             	sub    $0x1,%eax
  57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  5a:	8d 95 f0 fe ff ff    	lea    -0x110(%ebp),%edx
  60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  63:	01 d0                	add    %edx,%eax
  65:	c6 00 00             	movb   $0x0,(%eax)

        process_one_cmd(buf);
  68:	83 ec 0c             	sub    $0xc,%esp
  6b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  71:	50                   	push   %eax
  72:	e8 90 02 00 00       	call   307 <process_one_cmd>
  77:	83 c4 10             	add    $0x10,%esp
        
        printf(1, SH_PROMPT);
  7a:	83 ec 08             	sub    $0x8,%esp
  7d:	68 72 0d 00 00       	push   $0xd72
  82:	6a 01                	push   $0x1
  84:	e8 32 09 00 00       	call   9bb <printf>
  89:	83 c4 10             	add    $0x10,%esp
      
        memset(buf, 0, sizeof(buf));
  8c:	83 ec 04             	sub    $0x4,%esp
  8f:	68 00 01 00 00       	push   $0x100
  94:	6a 00                	push   $0x0
  96:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  9c:	50                   	push   %eax
  9d:	e8 fa 05 00 00       	call   69c <memset>
  a2:	83 c4 10             	add    $0x10,%esp
    while ( (n = read(0, buf, MAXLINE)) != 0) 
  a5:	83 ec 04             	sub    $0x4,%esp
  a8:	68 00 01 00 00       	push   $0x100
  ad:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  b3:	50                   	push   %eax
  b4:	6a 00                	push   $0x0
  b6:	e8 94 07 00 00       	call   84f <read>
  bb:	83 c4 10             	add    $0x10,%esp
  be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  c5:	0f 85 5d ff ff ff    	jne    28 <main+0x28>
    }
    
    
    exit();
  cb:	e8 67 07 00 00       	call   837 <exit>

000000d0 <exit_check>:
// When running &, there is no xvsh>, but you can still run commands

// When I add #include <unistd.h> I start getting more errors

int exit_check(char **tok, int num_tok)
{
  d0:	55                   	push   %ebp
  d1:	89 e5                	mov    %esp,%ebp
  d3:	83 ec 18             	sub    $0x18,%esp
    int strret = strcmp(tok[0], "exit");
  d6:	8b 45 08             	mov    0x8(%ebp),%eax
  d9:	8b 00                	mov    (%eax),%eax
  db:	83 ec 08             	sub    $0x8,%esp
  de:	68 79 0d 00 00       	push   $0xd79
  e3:	50                   	push   %eax
  e4:	e8 4d 05 00 00       	call   636 <strcmp>
  e9:	83 c4 10             	add    $0x10,%esp
  ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(strret == 0){
  ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  f3:	75 07                	jne    fc <exit_check+0x2c>
        return 1;
  f5:	b8 01 00 00 00       	mov    $0x1,%eax
  fa:	eb 05                	jmp    101 <exit_check+0x31>
    }
    return 0;
  fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
 101:	c9                   	leave  
 102:	c3                   	ret    

00000103 <process_pipe>:


int process_pipe(char **tok){
 103:	55                   	push   %ebp
 104:	89 e5                	mov    %esp,%ebp
 106:	83 ec 28             	sub    $0x28,%esp
    int fds[2];
    pid_t pid1, pid2;

    // Create a pipe
    if(pipe(fds) == -1){
 109:	83 ec 0c             	sub    $0xc,%esp
 10c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 10f:	50                   	push   %eax
 110:	e8 32 07 00 00       	call   847 <pipe>
 115:	83 c4 10             	add    $0x10,%esp
 118:	83 f8 ff             	cmp    $0xffffffff,%eax
 11b:	75 05                	jne    122 <process_pipe+0x1f>
        exit();
 11d:	e8 15 07 00 00       	call   837 <exit>
    }

    // Fork first child
    if((pid1 = fork()) < 0){
 122:	e8 08 07 00 00       	call   82f <fork>
 127:	89 45 f0             	mov    %eax,-0x10(%ebp)
 12a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 12e:	79 05                	jns    135 <process_pipe+0x32>
        exit();
 130:	e8 02 07 00 00       	call   837 <exit>
    }

    if(pid1 == 0){
 135:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 139:	75 48                	jne    183 <process_pipe+0x80>
        close(1);
 13b:	83 ec 0c             	sub    $0xc,%esp
 13e:	6a 01                	push   $0x1
 140:	e8 1a 07 00 00       	call   85f <close>
 145:	83 c4 10             	add    $0x10,%esp
        dup(fds[1]);
 148:	8b 45 e8             	mov    -0x18(%ebp),%eax
 14b:	83 ec 0c             	sub    $0xc,%esp
 14e:	50                   	push   %eax
 14f:	e8 5b 07 00 00       	call   8af <dup>
 154:	83 c4 10             	add    $0x10,%esp
        close(fds[0]);
 157:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 15a:	83 ec 0c             	sub    $0xc,%esp
 15d:	50                   	push   %eax
 15e:	e8 fc 06 00 00       	call   85f <close>
 163:	83 c4 10             	add    $0x10,%esp

        if(exec(tok[0], tok)){
 166:	8b 45 08             	mov    0x8(%ebp),%eax
 169:	8b 00                	mov    (%eax),%eax
 16b:	83 ec 08             	sub    $0x8,%esp
 16e:	ff 75 08             	pushl  0x8(%ebp)
 171:	50                   	push   %eax
 172:	e8 f8 06 00 00       	call   86f <exec>
 177:	83 c4 10             	add    $0x10,%esp
 17a:	85 c0                	test   %eax,%eax
 17c:	74 05                	je     183 <process_pipe+0x80>
            exit();
 17e:	e8 b4 06 00 00       	call   837 <exit>
        }
    }

    // Fork second child
    if((pid2 = fork()) < 0){
 183:	e8 a7 06 00 00       	call   82f <fork>
 188:	89 45 ec             	mov    %eax,-0x14(%ebp)
 18b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 18f:	79 05                	jns    196 <process_pipe+0x93>
        exit();
 191:	e8 a1 06 00 00       	call   837 <exit>
    }

    if(pid2 == 0){
 196:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 19a:	75 56                	jne    1f2 <process_pipe+0xef>
        close(0);
 19c:	83 ec 0c             	sub    $0xc,%esp
 19f:	6a 00                	push   $0x0
 1a1:	e8 b9 06 00 00       	call   85f <close>
 1a6:	83 c4 10             	add    $0x10,%esp
        dup(fds[0]);
 1a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1ac:	83 ec 0c             	sub    $0xc,%esp
 1af:	50                   	push   %eax
 1b0:	e8 fa 06 00 00       	call   8af <dup>
 1b5:	83 c4 10             	add    $0x10,%esp
        close(fds[1]);
 1b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1bb:	83 ec 0c             	sub    $0xc,%esp
 1be:	50                   	push   %eax
 1bf:	e8 9b 06 00 00       	call   85f <close>
 1c4:	83 c4 10             	add    $0x10,%esp

        if(exec(tok[pip_pos], tok)){
 1c7:	a1 dc 10 00 00       	mov    0x10dc,%eax
 1cc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 1d3:	8b 45 08             	mov    0x8(%ebp),%eax
 1d6:	01 d0                	add    %edx,%eax
 1d8:	8b 00                	mov    (%eax),%eax
 1da:	83 ec 08             	sub    $0x8,%esp
 1dd:	ff 75 08             	pushl  0x8(%ebp)
 1e0:	50                   	push   %eax
 1e1:	e8 89 06 00 00       	call   86f <exec>
 1e6:	83 c4 10             	add    $0x10,%esp
 1e9:	85 c0                	test   %eax,%eax
 1eb:	74 05                	je     1f2 <process_pipe+0xef>
            exit();
 1ed:	e8 45 06 00 00       	call   837 <exit>
        }
    }

    close(fds[0]);
 1f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1f5:	83 ec 0c             	sub    $0xc,%esp
 1f8:	50                   	push   %eax
 1f9:	e8 61 06 00 00       	call   85f <close>
 1fe:	83 c4 10             	add    $0x10,%esp
    close(fds[1]);
 201:	8b 45 e8             	mov    -0x18(%ebp),%eax
 204:	83 ec 0c             	sub    $0xc,%esp
 207:	50                   	push   %eax
 208:	e8 52 06 00 00       	call   85f <close>
 20d:	83 c4 10             	add    $0x10,%esp

    // Parent waits for children to complete
    
    for(int z = 0; z < 2; z++){
 210:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 217:	eb 09                	jmp    222 <process_pipe+0x11f>
        wait();
 219:	e8 21 06 00 00       	call   83f <wait>
    for(int z = 0; z < 2; z++){
 21e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 222:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
 226:	7e f1                	jle    219 <process_pipe+0x116>
    }
    
    return 0;
 228:	b8 00 00 00 00       	mov    $0x0,%eax
}
 22d:	c9                   	leave  
 22e:	c3                   	ret    

0000022f <process_normal>:

int process_normal(char **tok, int bg)
{
 22f:	55                   	push   %ebp
 230:	89 e5                	mov    %esp,%ebp
 232:	83 ec 18             	sub    $0x18,%esp
    int PID = fork();
 235:	e8 f5 05 00 00       	call   82f <fork>
 23a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(PID == 0){
 23d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 241:	75 3a                	jne    27d <process_normal+0x4e>
        int PIDE = exec(*tok, tok);
 243:	8b 45 08             	mov    0x8(%ebp),%eax
 246:	8b 00                	mov    (%eax),%eax
 248:	83 ec 08             	sub    $0x8,%esp
 24b:	ff 75 08             	pushl  0x8(%ebp)
 24e:	50                   	push   %eax
 24f:	e8 1b 06 00 00       	call   86f <exec>
 254:	83 c4 10             	add    $0x10,%esp
 257:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if(PIDE < 0){
 25a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 25e:	79 1d                	jns    27d <process_normal+0x4e>
            printf(1, "Cannot run this command: %s\n", *tok);
 260:	8b 45 08             	mov    0x8(%ebp),%eax
 263:	8b 00                	mov    (%eax),%eax
 265:	83 ec 04             	sub    $0x4,%esp
 268:	50                   	push   %eax
 269:	68 7e 0d 00 00       	push   $0xd7e
 26e:	6a 01                	push   $0x1
 270:	e8 46 07 00 00       	call   9bb <printf>
 275:	83 c4 10             	add    $0x10,%esp
            exit();
 278:	e8 ba 05 00 00       	call   837 <exit>
        }
    }
    if(bg == 0){
 27d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 281:	75 0b                	jne    28e <process_normal+0x5f>
        if(PID > 0){
 283:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 287:	7e 05                	jle    28e <process_normal+0x5f>
            wait();
 289:	e8 b1 05 00 00       	call   83f <wait>
    }


    // your implementation here
    // note that exec(*tok, tok) is the right way to invoke exec in xv6
    return 0;
 28e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 293:	c9                   	leave  
 294:	c3                   	ret    

00000295 <process_redirect>:

// When I run it, it leaves xvsh, but when I run a command
// that isn't accepted then run it, it doens't leave it.
int process_redirect(char** tok){
 295:	55                   	push   %ebp
 296:	89 e5                	mov    %esp,%ebp
 298:	83 ec 18             	sub    $0x18,%esp

    int rc = fork();
 29b:	e8 8f 05 00 00       	call   82f <fork>
 2a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(rc < 0){
 2a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2a7:	79 05                	jns    2ae <process_redirect+0x19>
        exit();
 2a9:	e8 89 05 00 00       	call   837 <exit>
    }
    else if(rc == 0){
 2ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b2:	75 47                	jne    2fb <process_redirect+0x66>
        close(1);
 2b4:	83 ec 0c             	sub    $0xc,%esp
 2b7:	6a 01                	push   $0x1
 2b9:	e8 a1 05 00 00       	call   85f <close>
 2be:	83 c4 10             	add    $0x10,%esp
        open(tok[red_pos], O_CREATE|O_WRONLY);
 2c1:	a1 e0 10 00 00       	mov    0x10e0,%eax
 2c6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 2cd:	8b 45 08             	mov    0x8(%ebp),%eax
 2d0:	01 d0                	add    %edx,%eax
 2d2:	8b 00                	mov    (%eax),%eax
 2d4:	83 ec 08             	sub    $0x8,%esp
 2d7:	68 01 02 00 00       	push   $0x201
 2dc:	50                   	push   %eax
 2dd:	e8 95 05 00 00       	call   877 <open>
 2e2:	83 c4 10             	add    $0x10,%esp
        exec(tok[0], tok);
 2e5:	8b 45 08             	mov    0x8(%ebp),%eax
 2e8:	8b 00                	mov    (%eax),%eax
 2ea:	83 ec 08             	sub    $0x8,%esp
 2ed:	ff 75 08             	pushl  0x8(%ebp)
 2f0:	50                   	push   %eax
 2f1:	e8 79 05 00 00       	call   86f <exec>
 2f6:	83 c4 10             	add    $0x10,%esp
 2f9:	eb 05                	jmp    300 <process_redirect+0x6b>
    }
    else{
        wait();
 2fb:	e8 3f 05 00 00       	call   83f <wait>
    }

    return 0;
 300:	b8 00 00 00 00       	mov    $0x0,%eax
}
 305:	c9                   	leave  
 306:	c3                   	ret    

00000307 <process_one_cmd>:


int process_one_cmd(char* buf)
{
 307:	55                   	push   %ebp
 308:	89 e5                	mov    %esp,%ebp
 30a:	53                   	push   %ebx
 30b:	83 ec 24             	sub    $0x24,%esp
    int i, num_tok;
    char **tok;
    int bg;
    int pip;
    int red;
    i = (strlen(buf) - 1);
 30e:	83 ec 0c             	sub    $0xc,%esp
 311:	ff 75 08             	pushl  0x8(%ebp)
 314:	e8 5c 03 00 00       	call   675 <strlen>
 319:	83 c4 10             	add    $0x10,%esp
 31c:	83 e8 01             	sub    $0x1,%eax
 31f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    num_tok = 1;
 322:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

    while (i)
 329:	eb 1b                	jmp    346 <process_one_cmd+0x3f>
    {
        if (buf[i--] == ' ')
 32b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 32e:	8d 50 ff             	lea    -0x1(%eax),%edx
 331:	89 55 f4             	mov    %edx,-0xc(%ebp)
 334:	89 c2                	mov    %eax,%edx
 336:	8b 45 08             	mov    0x8(%ebp),%eax
 339:	01 d0                	add    %edx,%eax
 33b:	0f b6 00             	movzbl (%eax),%eax
 33e:	3c 20                	cmp    $0x20,%al
 340:	75 04                	jne    346 <process_one_cmd+0x3f>
            num_tok++;
 342:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    while (i)
 346:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 34a:	75 df                	jne    32b <process_one_cmd+0x24>
    }

    if (!(tok = malloc( (num_tok + 1) *   sizeof (char *)))) 
 34c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 34f:	83 c0 01             	add    $0x1,%eax
 352:	c1 e0 02             	shl    $0x2,%eax
 355:	83 ec 0c             	sub    $0xc,%esp
 358:	50                   	push   %eax
 359:	e8 31 09 00 00       	call   c8f <malloc>
 35e:	83 c4 10             	add    $0x10,%esp
 361:	89 45 e0             	mov    %eax,-0x20(%ebp)
 364:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
 368:	75 17                	jne    381 <process_one_cmd+0x7a>
    {
        printf(1, "malloc failed\n");
 36a:	83 ec 08             	sub    $0x8,%esp
 36d:	68 9b 0d 00 00       	push   $0xd9b
 372:	6a 01                	push   $0x1
 374:	e8 42 06 00 00       	call   9bb <printf>
 379:	83 c4 10             	add    $0x10,%esp
        exit();
 37c:	e8 b6 04 00 00       	call   837 <exit>
    }        


    i = bg = pip = red = 0;
 381:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 388:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 38b:	89 45 e8             	mov    %eax,-0x18(%ebp)
 38e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 391:	89 45 ec             	mov    %eax,-0x14(%ebp)
 394:	8b 45 ec             	mov    -0x14(%ebp),%eax
 397:	89 45 f4             	mov    %eax,-0xc(%ebp)
    tok[i++] = strtok(buf, " ");
 39a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39d:	8d 50 01             	lea    0x1(%eax),%edx
 3a0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3a3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 3aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
 3ad:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
 3b0:	83 ec 08             	sub    $0x8,%esp
 3b3:	68 aa 0d 00 00       	push   $0xdaa
 3b8:	ff 75 08             	pushl  0x8(%ebp)
 3bb:	e8 78 01 00 00       	call   538 <strtok>
 3c0:	83 c4 10             	add    $0x10,%esp
 3c3:	89 03                	mov    %eax,(%ebx)

    /* check special symbols */
    while ((tok[i] = strtok(NULL, " "))) 
 3c5:	e9 a1 00 00 00       	jmp    46b <process_one_cmd+0x164>
    {
        switch (*tok[i]) 
 3ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 3d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
 3d7:	01 d0                	add    %edx,%eax
 3d9:	8b 00                	mov    (%eax),%eax
 3db:	0f b6 00             	movzbl (%eax),%eax
 3de:	0f be c0             	movsbl %al,%eax
 3e1:	83 f8 7c             	cmp    $0x7c,%eax
 3e4:	74 2e                	je     414 <process_one_cmd+0x10d>
 3e6:	83 f8 7c             	cmp    $0x7c,%eax
 3e9:	7f 7b                	jg     466 <process_one_cmd+0x15f>
 3eb:	83 f8 26             	cmp    $0x26,%eax
 3ee:	74 07                	je     3f7 <process_one_cmd+0xf0>
 3f0:	83 f8 3e             	cmp    $0x3e,%eax
 3f3:	74 48                	je     43d <process_one_cmd+0x136>
                tok[i] = NULL;
                red_pos = i + 1;
                break;
            default:
                // do nothing
                break;
 3f5:	eb 6f                	jmp    466 <process_one_cmd+0x15f>
                bg = i;
 3f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
                tok[i] = NULL;
 3fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 400:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 407:	8b 45 e0             	mov    -0x20(%ebp),%eax
 40a:	01 d0                	add    %edx,%eax
 40c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                break;
 412:	eb 53                	jmp    467 <process_one_cmd+0x160>
                pip = 2;
 414:	c7 45 e8 02 00 00 00 	movl   $0x2,-0x18(%ebp)
                tok[i] = NULL;
 41b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 41e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 425:	8b 45 e0             	mov    -0x20(%ebp),%eax
 428:	01 d0                	add    %edx,%eax
 42a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                pip_pos = i + 1;
 430:	8b 45 f4             	mov    -0xc(%ebp),%eax
 433:	83 c0 01             	add    $0x1,%eax
 436:	a3 dc 10 00 00       	mov    %eax,0x10dc
                break;
 43b:	eb 2a                	jmp    467 <process_one_cmd+0x160>
                red = 3;
 43d:	c7 45 e4 03 00 00 00 	movl   $0x3,-0x1c(%ebp)
                tok[i] = NULL;
 444:	8b 45 f4             	mov    -0xc(%ebp),%eax
 447:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 44e:	8b 45 e0             	mov    -0x20(%ebp),%eax
 451:	01 d0                	add    %edx,%eax
 453:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                red_pos = i + 1;
 459:	8b 45 f4             	mov    -0xc(%ebp),%eax
 45c:	83 c0 01             	add    $0x1,%eax
 45f:	a3 e0 10 00 00       	mov    %eax,0x10e0
                break;
 464:	eb 01                	jmp    467 <process_one_cmd+0x160>
                break;
 466:	90                   	nop
        }   
        i++;
 467:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    while ((tok[i] = strtok(NULL, " "))) 
 46b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 475:	8b 45 e0             	mov    -0x20(%ebp),%eax
 478:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
 47b:	83 ec 08             	sub    $0x8,%esp
 47e:	68 aa 0d 00 00       	push   $0xdaa
 483:	6a 00                	push   $0x0
 485:	e8 ae 00 00 00       	call   538 <strtok>
 48a:	83 c4 10             	add    $0x10,%esp
 48d:	89 03                	mov    %eax,(%ebx)
 48f:	8b 03                	mov    (%ebx),%eax
 491:	85 c0                	test   %eax,%eax
 493:	0f 85 31 ff ff ff    	jne    3ca <process_one_cmd+0xc3>
    }

    /*Check buid-in exit command */
    if (exit_check(tok, num_tok))
 499:	83 ec 08             	sub    $0x8,%esp
 49c:	ff 75 f0             	pushl  -0x10(%ebp)
 49f:	ff 75 e0             	pushl  -0x20(%ebp)
 4a2:	e8 29 fc ff ff       	call   d0 <exit_check>
 4a7:	83 c4 10             	add    $0x10,%esp
 4aa:	85 c0                	test   %eax,%eax
 4ac:	74 0f                	je     4bd <process_one_cmd+0x1b6>
    {
        /*some code here to wait till all children exit() before exit*/
	// your implementation here
        while(wait() > 0){
 4ae:	90                   	nop
 4af:	e8 8b 03 00 00       	call   83f <wait>
 4b4:	85 c0                	test   %eax,%eax
 4b6:	7f f7                	jg     4af <process_one_cmd+0x1a8>
            
        }
        exit();
 4b8:	e8 7a 03 00 00       	call   837 <exit>
    }

    // your code to check NOT implemented cases
    
    /* to process one command */
    if(pip == 2){
 4bd:	83 7d e8 02          	cmpl   $0x2,-0x18(%ebp)
 4c1:	75 23                	jne    4e6 <process_one_cmd+0x1df>
        process_pipe(tok);
 4c3:	83 ec 0c             	sub    $0xc,%esp
 4c6:	ff 75 e0             	pushl  -0x20(%ebp)
 4c9:	e8 35 fc ff ff       	call   103 <process_pipe>
 4ce:	83 c4 10             	add    $0x10,%esp
        free(tok);
 4d1:	83 ec 0c             	sub    $0xc,%esp
 4d4:	ff 75 e0             	pushl  -0x20(%ebp)
 4d7:	e8 71 06 00 00       	call   b4d <free>
 4dc:	83 c4 10             	add    $0x10,%esp
        return 0;
 4df:	b8 00 00 00 00       	mov    $0x0,%eax
 4e4:	eb 4d                	jmp    533 <process_one_cmd+0x22c>
    }
    if(red == 3){
 4e6:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
 4ea:	75 23                	jne    50f <process_one_cmd+0x208>
        process_redirect(tok);
 4ec:	83 ec 0c             	sub    $0xc,%esp
 4ef:	ff 75 e0             	pushl  -0x20(%ebp)
 4f2:	e8 9e fd ff ff       	call   295 <process_redirect>
 4f7:	83 c4 10             	add    $0x10,%esp
        free(tok);
 4fa:	83 ec 0c             	sub    $0xc,%esp
 4fd:	ff 75 e0             	pushl  -0x20(%ebp)
 500:	e8 48 06 00 00       	call   b4d <free>
 505:	83 c4 10             	add    $0x10,%esp
        return 0;
 508:	b8 00 00 00 00       	mov    $0x0,%eax
 50d:	eb 24                	jmp    533 <process_one_cmd+0x22c>
    }
    process_normal(tok, bg);
 50f:	83 ec 08             	sub    $0x8,%esp
 512:	ff 75 ec             	pushl  -0x14(%ebp)
 515:	ff 75 e0             	pushl  -0x20(%ebp)
 518:	e8 12 fd ff ff       	call   22f <process_normal>
 51d:	83 c4 10             	add    $0x10,%esp

    free(tok);
 520:	83 ec 0c             	sub    $0xc,%esp
 523:	ff 75 e0             	pushl  -0x20(%ebp)
 526:	e8 22 06 00 00       	call   b4d <free>
 52b:	83 c4 10             	add    $0x10,%esp
    return 0;
 52e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 533:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 536:	c9                   	leave  
 537:	c3                   	ret    

00000538 <strtok>:

char *
strtok(s, delim)
    register char *s;
    register const char *delim;
{
 538:	55                   	push   %ebp
 539:	89 e5                	mov    %esp,%ebp
 53b:	57                   	push   %edi
 53c:	56                   	push   %esi
 53d:	53                   	push   %ebx
 53e:	83 ec 10             	sub    $0x10,%esp
 541:	8b 45 08             	mov    0x8(%ebp),%eax
 544:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    register int c, sc;
    char *tok;
    static char *last;


    if (s == NULL && (s = last) == NULL)
 547:	85 c0                	test   %eax,%eax
 549:	75 10                	jne    55b <strtok+0x23>
 54b:	a1 e4 10 00 00       	mov    0x10e4,%eax
 550:	85 c0                	test   %eax,%eax
 552:	75 07                	jne    55b <strtok+0x23>
        return (NULL);
 554:	b8 00 00 00 00       	mov    $0x0,%eax
 559:	eb 7d                	jmp    5d8 <strtok+0xa0>

    /*
     * Skip (span) leading delimiters (s += strspn(s, delim), sort of).
     */
cont:
 55b:	90                   	nop
    c = *s++;
 55c:	89 c2                	mov    %eax,%edx
 55e:	8d 42 01             	lea    0x1(%edx),%eax
 561:	0f b6 12             	movzbl (%edx),%edx
 564:	0f be f2             	movsbl %dl,%esi
    for (spanp = (char *)delim; (sc = *spanp++) != 0;) {
 567:	89 cf                	mov    %ecx,%edi
 569:	eb 06                	jmp    571 <strtok+0x39>
        if (c == sc)
 56b:	39 de                	cmp    %ebx,%esi
 56d:	75 02                	jne    571 <strtok+0x39>
            goto cont;
 56f:	eb eb                	jmp    55c <strtok+0x24>
    for (spanp = (char *)delim; (sc = *spanp++) != 0;) {
 571:	89 fa                	mov    %edi,%edx
 573:	8d 7a 01             	lea    0x1(%edx),%edi
 576:	0f b6 12             	movzbl (%edx),%edx
 579:	0f be da             	movsbl %dl,%ebx
 57c:	85 db                	test   %ebx,%ebx
 57e:	75 eb                	jne    56b <strtok+0x33>
    }

    if (c == 0) {        /* no non-delimiter characters */
 580:	85 f6                	test   %esi,%esi
 582:	75 11                	jne    595 <strtok+0x5d>
        last = NULL;
 584:	c7 05 e4 10 00 00 00 	movl   $0x0,0x10e4
 58b:	00 00 00 
        return (NULL);
 58e:	b8 00 00 00 00       	mov    $0x0,%eax
 593:	eb 43                	jmp    5d8 <strtok+0xa0>
    }
    tok = s - 1;
 595:	8d 50 ff             	lea    -0x1(%eax),%edx
 598:	89 55 f0             	mov    %edx,-0x10(%ebp)
    /*
     * Scan token (scan for delimiters: s += strcspn(s, delim), sort of).
     * Note that delim must have one NUL; we stop if we see that, too.
     */
    for (;;) {
        c = *s++;
 59b:	89 c2                	mov    %eax,%edx
 59d:	8d 42 01             	lea    0x1(%edx),%eax
 5a0:	0f b6 12             	movzbl (%edx),%edx
 5a3:	0f be f2             	movsbl %dl,%esi
        spanp = (char *)delim;
 5a6:	89 cf                	mov    %ecx,%edi
        do {
            if ((sc = *spanp++) == c) {
 5a8:	89 fa                	mov    %edi,%edx
 5aa:	8d 7a 01             	lea    0x1(%edx),%edi
 5ad:	0f b6 12             	movzbl (%edx),%edx
 5b0:	0f be da             	movsbl %dl,%ebx
 5b3:	39 f3                	cmp    %esi,%ebx
 5b5:	75 1b                	jne    5d2 <strtok+0x9a>
                if (c == 0)
 5b7:	85 f6                	test   %esi,%esi
 5b9:	75 07                	jne    5c2 <strtok+0x8a>
                    s = NULL;
 5bb:	b8 00 00 00 00       	mov    $0x0,%eax
 5c0:	eb 06                	jmp    5c8 <strtok+0x90>
                else
                    s[-1] = 0;
 5c2:	8d 50 ff             	lea    -0x1(%eax),%edx
 5c5:	c6 02 00             	movb   $0x0,(%edx)
                last = s;
 5c8:	a3 e4 10 00 00       	mov    %eax,0x10e4
                return (tok);
 5cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5d0:	eb 06                	jmp    5d8 <strtok+0xa0>
            }
        } while (sc != 0);
 5d2:	85 db                	test   %ebx,%ebx
 5d4:	75 d2                	jne    5a8 <strtok+0x70>
        c = *s++;
 5d6:	eb c3                	jmp    59b <strtok+0x63>
    }
    /* NOTREACHED */
}
 5d8:	83 c4 10             	add    $0x10,%esp
 5db:	5b                   	pop    %ebx
 5dc:	5e                   	pop    %esi
 5dd:	5f                   	pop    %edi
 5de:	5d                   	pop    %ebp
 5df:	c3                   	ret    

000005e0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 5e0:	55                   	push   %ebp
 5e1:	89 e5                	mov    %esp,%ebp
 5e3:	57                   	push   %edi
 5e4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 5e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
 5e8:	8b 55 10             	mov    0x10(%ebp),%edx
 5eb:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ee:	89 cb                	mov    %ecx,%ebx
 5f0:	89 df                	mov    %ebx,%edi
 5f2:	89 d1                	mov    %edx,%ecx
 5f4:	fc                   	cld    
 5f5:	f3 aa                	rep stos %al,%es:(%edi)
 5f7:	89 ca                	mov    %ecx,%edx
 5f9:	89 fb                	mov    %edi,%ebx
 5fb:	89 5d 08             	mov    %ebx,0x8(%ebp)
 5fe:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 601:	90                   	nop
 602:	5b                   	pop    %ebx
 603:	5f                   	pop    %edi
 604:	5d                   	pop    %ebp
 605:	c3                   	ret    

00000606 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 606:	55                   	push   %ebp
 607:	89 e5                	mov    %esp,%ebp
 609:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 60c:	8b 45 08             	mov    0x8(%ebp),%eax
 60f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 612:	90                   	nop
 613:	8b 55 0c             	mov    0xc(%ebp),%edx
 616:	8d 42 01             	lea    0x1(%edx),%eax
 619:	89 45 0c             	mov    %eax,0xc(%ebp)
 61c:	8b 45 08             	mov    0x8(%ebp),%eax
 61f:	8d 48 01             	lea    0x1(%eax),%ecx
 622:	89 4d 08             	mov    %ecx,0x8(%ebp)
 625:	0f b6 12             	movzbl (%edx),%edx
 628:	88 10                	mov    %dl,(%eax)
 62a:	0f b6 00             	movzbl (%eax),%eax
 62d:	84 c0                	test   %al,%al
 62f:	75 e2                	jne    613 <strcpy+0xd>
    ;
  return os;
 631:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 634:	c9                   	leave  
 635:	c3                   	ret    

00000636 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 636:	55                   	push   %ebp
 637:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 639:	eb 08                	jmp    643 <strcmp+0xd>
    p++, q++;
 63b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 63f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 643:	8b 45 08             	mov    0x8(%ebp),%eax
 646:	0f b6 00             	movzbl (%eax),%eax
 649:	84 c0                	test   %al,%al
 64b:	74 10                	je     65d <strcmp+0x27>
 64d:	8b 45 08             	mov    0x8(%ebp),%eax
 650:	0f b6 10             	movzbl (%eax),%edx
 653:	8b 45 0c             	mov    0xc(%ebp),%eax
 656:	0f b6 00             	movzbl (%eax),%eax
 659:	38 c2                	cmp    %al,%dl
 65b:	74 de                	je     63b <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 65d:	8b 45 08             	mov    0x8(%ebp),%eax
 660:	0f b6 00             	movzbl (%eax),%eax
 663:	0f b6 d0             	movzbl %al,%edx
 666:	8b 45 0c             	mov    0xc(%ebp),%eax
 669:	0f b6 00             	movzbl (%eax),%eax
 66c:	0f b6 c8             	movzbl %al,%ecx
 66f:	89 d0                	mov    %edx,%eax
 671:	29 c8                	sub    %ecx,%eax
}
 673:	5d                   	pop    %ebp
 674:	c3                   	ret    

00000675 <strlen>:

uint
strlen(char *s)
{
 675:	55                   	push   %ebp
 676:	89 e5                	mov    %esp,%ebp
 678:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 67b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 682:	eb 04                	jmp    688 <strlen+0x13>
 684:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 688:	8b 55 fc             	mov    -0x4(%ebp),%edx
 68b:	8b 45 08             	mov    0x8(%ebp),%eax
 68e:	01 d0                	add    %edx,%eax
 690:	0f b6 00             	movzbl (%eax),%eax
 693:	84 c0                	test   %al,%al
 695:	75 ed                	jne    684 <strlen+0xf>
    ;
  return n;
 697:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 69a:	c9                   	leave  
 69b:	c3                   	ret    

0000069c <memset>:

void*
memset(void *dst, int c, uint n)
{
 69c:	55                   	push   %ebp
 69d:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 69f:	8b 45 10             	mov    0x10(%ebp),%eax
 6a2:	50                   	push   %eax
 6a3:	ff 75 0c             	pushl  0xc(%ebp)
 6a6:	ff 75 08             	pushl  0x8(%ebp)
 6a9:	e8 32 ff ff ff       	call   5e0 <stosb>
 6ae:	83 c4 0c             	add    $0xc,%esp
  return dst;
 6b1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6b4:	c9                   	leave  
 6b5:	c3                   	ret    

000006b6 <strchr>:

char*
strchr(const char *s, char c)
{
 6b6:	55                   	push   %ebp
 6b7:	89 e5                	mov    %esp,%ebp
 6b9:	83 ec 04             	sub    $0x4,%esp
 6bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 6bf:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 6c2:	eb 14                	jmp    6d8 <strchr+0x22>
    if(*s == c)
 6c4:	8b 45 08             	mov    0x8(%ebp),%eax
 6c7:	0f b6 00             	movzbl (%eax),%eax
 6ca:	38 45 fc             	cmp    %al,-0x4(%ebp)
 6cd:	75 05                	jne    6d4 <strchr+0x1e>
      return (char*)s;
 6cf:	8b 45 08             	mov    0x8(%ebp),%eax
 6d2:	eb 13                	jmp    6e7 <strchr+0x31>
  for(; *s; s++)
 6d4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 6d8:	8b 45 08             	mov    0x8(%ebp),%eax
 6db:	0f b6 00             	movzbl (%eax),%eax
 6de:	84 c0                	test   %al,%al
 6e0:	75 e2                	jne    6c4 <strchr+0xe>
  return 0;
 6e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
 6e7:	c9                   	leave  
 6e8:	c3                   	ret    

000006e9 <gets>:

char*
gets(char *buf, int max)
{
 6e9:	55                   	push   %ebp
 6ea:	89 e5                	mov    %esp,%ebp
 6ec:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 6ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 6f6:	eb 42                	jmp    73a <gets+0x51>
    cc = read(0, &c, 1);
 6f8:	83 ec 04             	sub    $0x4,%esp
 6fb:	6a 01                	push   $0x1
 6fd:	8d 45 ef             	lea    -0x11(%ebp),%eax
 700:	50                   	push   %eax
 701:	6a 00                	push   $0x0
 703:	e8 47 01 00 00       	call   84f <read>
 708:	83 c4 10             	add    $0x10,%esp
 70b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 70e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 712:	7e 33                	jle    747 <gets+0x5e>
      break;
    buf[i++] = c;
 714:	8b 45 f4             	mov    -0xc(%ebp),%eax
 717:	8d 50 01             	lea    0x1(%eax),%edx
 71a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 71d:	89 c2                	mov    %eax,%edx
 71f:	8b 45 08             	mov    0x8(%ebp),%eax
 722:	01 c2                	add    %eax,%edx
 724:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 728:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 72a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 72e:	3c 0a                	cmp    $0xa,%al
 730:	74 16                	je     748 <gets+0x5f>
 732:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 736:	3c 0d                	cmp    $0xd,%al
 738:	74 0e                	je     748 <gets+0x5f>
  for(i=0; i+1 < max; ){
 73a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73d:	83 c0 01             	add    $0x1,%eax
 740:	39 45 0c             	cmp    %eax,0xc(%ebp)
 743:	7f b3                	jg     6f8 <gets+0xf>
 745:	eb 01                	jmp    748 <gets+0x5f>
      break;
 747:	90                   	nop
      break;
  }
  buf[i] = '\0';
 748:	8b 55 f4             	mov    -0xc(%ebp),%edx
 74b:	8b 45 08             	mov    0x8(%ebp),%eax
 74e:	01 d0                	add    %edx,%eax
 750:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 753:	8b 45 08             	mov    0x8(%ebp),%eax
}
 756:	c9                   	leave  
 757:	c3                   	ret    

00000758 <stat>:

int
stat(char *n, struct stat *st)
{
 758:	55                   	push   %ebp
 759:	89 e5                	mov    %esp,%ebp
 75b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 75e:	83 ec 08             	sub    $0x8,%esp
 761:	6a 00                	push   $0x0
 763:	ff 75 08             	pushl  0x8(%ebp)
 766:	e8 0c 01 00 00       	call   877 <open>
 76b:	83 c4 10             	add    $0x10,%esp
 76e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 771:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 775:	79 07                	jns    77e <stat+0x26>
    return -1;
 777:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 77c:	eb 25                	jmp    7a3 <stat+0x4b>
  r = fstat(fd, st);
 77e:	83 ec 08             	sub    $0x8,%esp
 781:	ff 75 0c             	pushl  0xc(%ebp)
 784:	ff 75 f4             	pushl  -0xc(%ebp)
 787:	e8 03 01 00 00       	call   88f <fstat>
 78c:	83 c4 10             	add    $0x10,%esp
 78f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 792:	83 ec 0c             	sub    $0xc,%esp
 795:	ff 75 f4             	pushl  -0xc(%ebp)
 798:	e8 c2 00 00 00       	call   85f <close>
 79d:	83 c4 10             	add    $0x10,%esp
  return r;
 7a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 7a3:	c9                   	leave  
 7a4:	c3                   	ret    

000007a5 <atoi>:

int
atoi(const char *s)
{
 7a5:	55                   	push   %ebp
 7a6:	89 e5                	mov    %esp,%ebp
 7a8:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 7ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 7b2:	eb 25                	jmp    7d9 <atoi+0x34>
    n = n*10 + *s++ - '0';
 7b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 7b7:	89 d0                	mov    %edx,%eax
 7b9:	c1 e0 02             	shl    $0x2,%eax
 7bc:	01 d0                	add    %edx,%eax
 7be:	01 c0                	add    %eax,%eax
 7c0:	89 c1                	mov    %eax,%ecx
 7c2:	8b 45 08             	mov    0x8(%ebp),%eax
 7c5:	8d 50 01             	lea    0x1(%eax),%edx
 7c8:	89 55 08             	mov    %edx,0x8(%ebp)
 7cb:	0f b6 00             	movzbl (%eax),%eax
 7ce:	0f be c0             	movsbl %al,%eax
 7d1:	01 c8                	add    %ecx,%eax
 7d3:	83 e8 30             	sub    $0x30,%eax
 7d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 7d9:	8b 45 08             	mov    0x8(%ebp),%eax
 7dc:	0f b6 00             	movzbl (%eax),%eax
 7df:	3c 2f                	cmp    $0x2f,%al
 7e1:	7e 0a                	jle    7ed <atoi+0x48>
 7e3:	8b 45 08             	mov    0x8(%ebp),%eax
 7e6:	0f b6 00             	movzbl (%eax),%eax
 7e9:	3c 39                	cmp    $0x39,%al
 7eb:	7e c7                	jle    7b4 <atoi+0xf>
  return n;
 7ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 7f0:	c9                   	leave  
 7f1:	c3                   	ret    

000007f2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 7f2:	55                   	push   %ebp
 7f3:	89 e5                	mov    %esp,%ebp
 7f5:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 7f8:	8b 45 08             	mov    0x8(%ebp),%eax
 7fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 7fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 801:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 804:	eb 17                	jmp    81d <memmove+0x2b>
    *dst++ = *src++;
 806:	8b 55 f8             	mov    -0x8(%ebp),%edx
 809:	8d 42 01             	lea    0x1(%edx),%eax
 80c:	89 45 f8             	mov    %eax,-0x8(%ebp)
 80f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 812:	8d 48 01             	lea    0x1(%eax),%ecx
 815:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 818:	0f b6 12             	movzbl (%edx),%edx
 81b:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 81d:	8b 45 10             	mov    0x10(%ebp),%eax
 820:	8d 50 ff             	lea    -0x1(%eax),%edx
 823:	89 55 10             	mov    %edx,0x10(%ebp)
 826:	85 c0                	test   %eax,%eax
 828:	7f dc                	jg     806 <memmove+0x14>
  return vdst;
 82a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 82d:	c9                   	leave  
 82e:	c3                   	ret    

0000082f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 82f:	b8 01 00 00 00       	mov    $0x1,%eax
 834:	cd 40                	int    $0x40
 836:	c3                   	ret    

00000837 <exit>:
SYSCALL(exit)
 837:	b8 02 00 00 00       	mov    $0x2,%eax
 83c:	cd 40                	int    $0x40
 83e:	c3                   	ret    

0000083f <wait>:
SYSCALL(wait)
 83f:	b8 03 00 00 00       	mov    $0x3,%eax
 844:	cd 40                	int    $0x40
 846:	c3                   	ret    

00000847 <pipe>:
SYSCALL(pipe)
 847:	b8 04 00 00 00       	mov    $0x4,%eax
 84c:	cd 40                	int    $0x40
 84e:	c3                   	ret    

0000084f <read>:
SYSCALL(read)
 84f:	b8 05 00 00 00       	mov    $0x5,%eax
 854:	cd 40                	int    $0x40
 856:	c3                   	ret    

00000857 <write>:
SYSCALL(write)
 857:	b8 10 00 00 00       	mov    $0x10,%eax
 85c:	cd 40                	int    $0x40
 85e:	c3                   	ret    

0000085f <close>:
SYSCALL(close)
 85f:	b8 15 00 00 00       	mov    $0x15,%eax
 864:	cd 40                	int    $0x40
 866:	c3                   	ret    

00000867 <kill>:
SYSCALL(kill)
 867:	b8 06 00 00 00       	mov    $0x6,%eax
 86c:	cd 40                	int    $0x40
 86e:	c3                   	ret    

0000086f <exec>:
SYSCALL(exec)
 86f:	b8 07 00 00 00       	mov    $0x7,%eax
 874:	cd 40                	int    $0x40
 876:	c3                   	ret    

00000877 <open>:
SYSCALL(open)
 877:	b8 0f 00 00 00       	mov    $0xf,%eax
 87c:	cd 40                	int    $0x40
 87e:	c3                   	ret    

0000087f <mknod>:
SYSCALL(mknod)
 87f:	b8 11 00 00 00       	mov    $0x11,%eax
 884:	cd 40                	int    $0x40
 886:	c3                   	ret    

00000887 <unlink>:
SYSCALL(unlink)
 887:	b8 12 00 00 00       	mov    $0x12,%eax
 88c:	cd 40                	int    $0x40
 88e:	c3                   	ret    

0000088f <fstat>:
SYSCALL(fstat)
 88f:	b8 08 00 00 00       	mov    $0x8,%eax
 894:	cd 40                	int    $0x40
 896:	c3                   	ret    

00000897 <link>:
SYSCALL(link)
 897:	b8 13 00 00 00       	mov    $0x13,%eax
 89c:	cd 40                	int    $0x40
 89e:	c3                   	ret    

0000089f <mkdir>:
SYSCALL(mkdir)
 89f:	b8 14 00 00 00       	mov    $0x14,%eax
 8a4:	cd 40                	int    $0x40
 8a6:	c3                   	ret    

000008a7 <chdir>:
SYSCALL(chdir)
 8a7:	b8 09 00 00 00       	mov    $0x9,%eax
 8ac:	cd 40                	int    $0x40
 8ae:	c3                   	ret    

000008af <dup>:
SYSCALL(dup)
 8af:	b8 0a 00 00 00       	mov    $0xa,%eax
 8b4:	cd 40                	int    $0x40
 8b6:	c3                   	ret    

000008b7 <getpid>:
SYSCALL(getpid)
 8b7:	b8 0b 00 00 00       	mov    $0xb,%eax
 8bc:	cd 40                	int    $0x40
 8be:	c3                   	ret    

000008bf <sbrk>:
SYSCALL(sbrk)
 8bf:	b8 0c 00 00 00       	mov    $0xc,%eax
 8c4:	cd 40                	int    $0x40
 8c6:	c3                   	ret    

000008c7 <sleep>:
SYSCALL(sleep)
 8c7:	b8 0d 00 00 00       	mov    $0xd,%eax
 8cc:	cd 40                	int    $0x40
 8ce:	c3                   	ret    

000008cf <uptime>:
SYSCALL(uptime)
 8cf:	b8 0e 00 00 00       	mov    $0xe,%eax
 8d4:	cd 40                	int    $0x40
 8d6:	c3                   	ret    

000008d7 <enable_sched_trace>:
SYSCALL(enable_sched_trace)
 8d7:	b8 16 00 00 00       	mov    $0x16,%eax
 8dc:	cd 40                	int    $0x40
 8de:	c3                   	ret    

000008df <uprog_shut>:
SYSCALL(uprog_shut)
 8df:	b8 17 00 00 00       	mov    $0x17,%eax
 8e4:	cd 40                	int    $0x40
 8e6:	c3                   	ret    

000008e7 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 8e7:	55                   	push   %ebp
 8e8:	89 e5                	mov    %esp,%ebp
 8ea:	83 ec 18             	sub    $0x18,%esp
 8ed:	8b 45 0c             	mov    0xc(%ebp),%eax
 8f0:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 8f3:	83 ec 04             	sub    $0x4,%esp
 8f6:	6a 01                	push   $0x1
 8f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 8fb:	50                   	push   %eax
 8fc:	ff 75 08             	pushl  0x8(%ebp)
 8ff:	e8 53 ff ff ff       	call   857 <write>
 904:	83 c4 10             	add    $0x10,%esp
}
 907:	90                   	nop
 908:	c9                   	leave  
 909:	c3                   	ret    

0000090a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 90a:	55                   	push   %ebp
 90b:	89 e5                	mov    %esp,%ebp
 90d:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 910:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 917:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 91b:	74 17                	je     934 <printint+0x2a>
 91d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 921:	79 11                	jns    934 <printint+0x2a>
    neg = 1;
 923:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 92a:	8b 45 0c             	mov    0xc(%ebp),%eax
 92d:	f7 d8                	neg    %eax
 92f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 932:	eb 06                	jmp    93a <printint+0x30>
  } else {
    x = xx;
 934:	8b 45 0c             	mov    0xc(%ebp),%eax
 937:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 93a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 941:	8b 4d 10             	mov    0x10(%ebp),%ecx
 944:	8b 45 ec             	mov    -0x14(%ebp),%eax
 947:	ba 00 00 00 00       	mov    $0x0,%edx
 94c:	f7 f1                	div    %ecx
 94e:	89 d1                	mov    %edx,%ecx
 950:	8b 45 f4             	mov    -0xc(%ebp),%eax
 953:	8d 50 01             	lea    0x1(%eax),%edx
 956:	89 55 f4             	mov    %edx,-0xc(%ebp)
 959:	0f b6 91 c8 10 00 00 	movzbl 0x10c8(%ecx),%edx
 960:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 964:	8b 4d 10             	mov    0x10(%ebp),%ecx
 967:	8b 45 ec             	mov    -0x14(%ebp),%eax
 96a:	ba 00 00 00 00       	mov    $0x0,%edx
 96f:	f7 f1                	div    %ecx
 971:	89 45 ec             	mov    %eax,-0x14(%ebp)
 974:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 978:	75 c7                	jne    941 <printint+0x37>
  if(neg)
 97a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 97e:	74 2d                	je     9ad <printint+0xa3>
    buf[i++] = '-';
 980:	8b 45 f4             	mov    -0xc(%ebp),%eax
 983:	8d 50 01             	lea    0x1(%eax),%edx
 986:	89 55 f4             	mov    %edx,-0xc(%ebp)
 989:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 98e:	eb 1d                	jmp    9ad <printint+0xa3>
    putc(fd, buf[i]);
 990:	8d 55 dc             	lea    -0x24(%ebp),%edx
 993:	8b 45 f4             	mov    -0xc(%ebp),%eax
 996:	01 d0                	add    %edx,%eax
 998:	0f b6 00             	movzbl (%eax),%eax
 99b:	0f be c0             	movsbl %al,%eax
 99e:	83 ec 08             	sub    $0x8,%esp
 9a1:	50                   	push   %eax
 9a2:	ff 75 08             	pushl  0x8(%ebp)
 9a5:	e8 3d ff ff ff       	call   8e7 <putc>
 9aa:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 9ad:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 9b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9b5:	79 d9                	jns    990 <printint+0x86>
}
 9b7:	90                   	nop
 9b8:	90                   	nop
 9b9:	c9                   	leave  
 9ba:	c3                   	ret    

000009bb <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 9bb:	55                   	push   %ebp
 9bc:	89 e5                	mov    %esp,%ebp
 9be:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 9c1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 9c8:	8d 45 0c             	lea    0xc(%ebp),%eax
 9cb:	83 c0 04             	add    $0x4,%eax
 9ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 9d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 9d8:	e9 59 01 00 00       	jmp    b36 <printf+0x17b>
    c = fmt[i] & 0xff;
 9dd:	8b 55 0c             	mov    0xc(%ebp),%edx
 9e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e3:	01 d0                	add    %edx,%eax
 9e5:	0f b6 00             	movzbl (%eax),%eax
 9e8:	0f be c0             	movsbl %al,%eax
 9eb:	25 ff 00 00 00       	and    $0xff,%eax
 9f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 9f3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 9f7:	75 2c                	jne    a25 <printf+0x6a>
      if(c == '%'){
 9f9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 9fd:	75 0c                	jne    a0b <printf+0x50>
        state = '%';
 9ff:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 a06:	e9 27 01 00 00       	jmp    b32 <printf+0x177>
      } else {
        putc(fd, c);
 a0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a0e:	0f be c0             	movsbl %al,%eax
 a11:	83 ec 08             	sub    $0x8,%esp
 a14:	50                   	push   %eax
 a15:	ff 75 08             	pushl  0x8(%ebp)
 a18:	e8 ca fe ff ff       	call   8e7 <putc>
 a1d:	83 c4 10             	add    $0x10,%esp
 a20:	e9 0d 01 00 00       	jmp    b32 <printf+0x177>
      }
    } else if(state == '%'){
 a25:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 a29:	0f 85 03 01 00 00    	jne    b32 <printf+0x177>
      if(c == 'd'){
 a2f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 a33:	75 1e                	jne    a53 <printf+0x98>
        printint(fd, *ap, 10, 1);
 a35:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a38:	8b 00                	mov    (%eax),%eax
 a3a:	6a 01                	push   $0x1
 a3c:	6a 0a                	push   $0xa
 a3e:	50                   	push   %eax
 a3f:	ff 75 08             	pushl  0x8(%ebp)
 a42:	e8 c3 fe ff ff       	call   90a <printint>
 a47:	83 c4 10             	add    $0x10,%esp
        ap++;
 a4a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a4e:	e9 d8 00 00 00       	jmp    b2b <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 a53:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 a57:	74 06                	je     a5f <printf+0xa4>
 a59:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 a5d:	75 1e                	jne    a7d <printf+0xc2>
        printint(fd, *ap, 16, 0);
 a5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a62:	8b 00                	mov    (%eax),%eax
 a64:	6a 00                	push   $0x0
 a66:	6a 10                	push   $0x10
 a68:	50                   	push   %eax
 a69:	ff 75 08             	pushl  0x8(%ebp)
 a6c:	e8 99 fe ff ff       	call   90a <printint>
 a71:	83 c4 10             	add    $0x10,%esp
        ap++;
 a74:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a78:	e9 ae 00 00 00       	jmp    b2b <printf+0x170>
      } else if(c == 's'){
 a7d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 a81:	75 43                	jne    ac6 <printf+0x10b>
        s = (char*)*ap;
 a83:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a86:	8b 00                	mov    (%eax),%eax
 a88:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 a8b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 a8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a93:	75 25                	jne    aba <printf+0xff>
          s = "(null)";
 a95:	c7 45 f4 ac 0d 00 00 	movl   $0xdac,-0xc(%ebp)
        while(*s != 0){
 a9c:	eb 1c                	jmp    aba <printf+0xff>
          putc(fd, *s);
 a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa1:	0f b6 00             	movzbl (%eax),%eax
 aa4:	0f be c0             	movsbl %al,%eax
 aa7:	83 ec 08             	sub    $0x8,%esp
 aaa:	50                   	push   %eax
 aab:	ff 75 08             	pushl  0x8(%ebp)
 aae:	e8 34 fe ff ff       	call   8e7 <putc>
 ab3:	83 c4 10             	add    $0x10,%esp
          s++;
 ab6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abd:	0f b6 00             	movzbl (%eax),%eax
 ac0:	84 c0                	test   %al,%al
 ac2:	75 da                	jne    a9e <printf+0xe3>
 ac4:	eb 65                	jmp    b2b <printf+0x170>
        }
      } else if(c == 'c'){
 ac6:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 aca:	75 1d                	jne    ae9 <printf+0x12e>
        putc(fd, *ap);
 acc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 acf:	8b 00                	mov    (%eax),%eax
 ad1:	0f be c0             	movsbl %al,%eax
 ad4:	83 ec 08             	sub    $0x8,%esp
 ad7:	50                   	push   %eax
 ad8:	ff 75 08             	pushl  0x8(%ebp)
 adb:	e8 07 fe ff ff       	call   8e7 <putc>
 ae0:	83 c4 10             	add    $0x10,%esp
        ap++;
 ae3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 ae7:	eb 42                	jmp    b2b <printf+0x170>
      } else if(c == '%'){
 ae9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 aed:	75 17                	jne    b06 <printf+0x14b>
        putc(fd, c);
 aef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 af2:	0f be c0             	movsbl %al,%eax
 af5:	83 ec 08             	sub    $0x8,%esp
 af8:	50                   	push   %eax
 af9:	ff 75 08             	pushl  0x8(%ebp)
 afc:	e8 e6 fd ff ff       	call   8e7 <putc>
 b01:	83 c4 10             	add    $0x10,%esp
 b04:	eb 25                	jmp    b2b <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b06:	83 ec 08             	sub    $0x8,%esp
 b09:	6a 25                	push   $0x25
 b0b:	ff 75 08             	pushl  0x8(%ebp)
 b0e:	e8 d4 fd ff ff       	call   8e7 <putc>
 b13:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 b16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b19:	0f be c0             	movsbl %al,%eax
 b1c:	83 ec 08             	sub    $0x8,%esp
 b1f:	50                   	push   %eax
 b20:	ff 75 08             	pushl  0x8(%ebp)
 b23:	e8 bf fd ff ff       	call   8e7 <putc>
 b28:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 b2b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 b32:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 b36:	8b 55 0c             	mov    0xc(%ebp),%edx
 b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b3c:	01 d0                	add    %edx,%eax
 b3e:	0f b6 00             	movzbl (%eax),%eax
 b41:	84 c0                	test   %al,%al
 b43:	0f 85 94 fe ff ff    	jne    9dd <printf+0x22>
    }
  }
}
 b49:	90                   	nop
 b4a:	90                   	nop
 b4b:	c9                   	leave  
 b4c:	c3                   	ret    

00000b4d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b4d:	55                   	push   %ebp
 b4e:	89 e5                	mov    %esp,%ebp
 b50:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b53:	8b 45 08             	mov    0x8(%ebp),%eax
 b56:	83 e8 08             	sub    $0x8,%eax
 b59:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b5c:	a1 f0 10 00 00       	mov    0x10f0,%eax
 b61:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b64:	eb 24                	jmp    b8a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b66:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b69:	8b 00                	mov    (%eax),%eax
 b6b:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 b6e:	72 12                	jb     b82 <free+0x35>
 b70:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b73:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b76:	77 24                	ja     b9c <free+0x4f>
 b78:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b7b:	8b 00                	mov    (%eax),%eax
 b7d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b80:	72 1a                	jb     b9c <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b82:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b85:	8b 00                	mov    (%eax),%eax
 b87:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b8a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b8d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b90:	76 d4                	jbe    b66 <free+0x19>
 b92:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b95:	8b 00                	mov    (%eax),%eax
 b97:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b9a:	73 ca                	jae    b66 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 b9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b9f:	8b 40 04             	mov    0x4(%eax),%eax
 ba2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 ba9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bac:	01 c2                	add    %eax,%edx
 bae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bb1:	8b 00                	mov    (%eax),%eax
 bb3:	39 c2                	cmp    %eax,%edx
 bb5:	75 24                	jne    bdb <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 bb7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bba:	8b 50 04             	mov    0x4(%eax),%edx
 bbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bc0:	8b 00                	mov    (%eax),%eax
 bc2:	8b 40 04             	mov    0x4(%eax),%eax
 bc5:	01 c2                	add    %eax,%edx
 bc7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bca:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 bcd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bd0:	8b 00                	mov    (%eax),%eax
 bd2:	8b 10                	mov    (%eax),%edx
 bd4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bd7:	89 10                	mov    %edx,(%eax)
 bd9:	eb 0a                	jmp    be5 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 bdb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bde:	8b 10                	mov    (%eax),%edx
 be0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 be3:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 be5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 be8:	8b 40 04             	mov    0x4(%eax),%eax
 beb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 bf2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bf5:	01 d0                	add    %edx,%eax
 bf7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 bfa:	75 20                	jne    c1c <free+0xcf>
    p->s.size += bp->s.size;
 bfc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bff:	8b 50 04             	mov    0x4(%eax),%edx
 c02:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c05:	8b 40 04             	mov    0x4(%eax),%eax
 c08:	01 c2                	add    %eax,%edx
 c0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c0d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 c10:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c13:	8b 10                	mov    (%eax),%edx
 c15:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c18:	89 10                	mov    %edx,(%eax)
 c1a:	eb 08                	jmp    c24 <free+0xd7>
  } else
    p->s.ptr = bp;
 c1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c1f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 c22:	89 10                	mov    %edx,(%eax)
  freep = p;
 c24:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c27:	a3 f0 10 00 00       	mov    %eax,0x10f0
}
 c2c:	90                   	nop
 c2d:	c9                   	leave  
 c2e:	c3                   	ret    

00000c2f <morecore>:

static Header*
morecore(uint nu)
{
 c2f:	55                   	push   %ebp
 c30:	89 e5                	mov    %esp,%ebp
 c32:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 c35:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 c3c:	77 07                	ja     c45 <morecore+0x16>
    nu = 4096;
 c3e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 c45:	8b 45 08             	mov    0x8(%ebp),%eax
 c48:	c1 e0 03             	shl    $0x3,%eax
 c4b:	83 ec 0c             	sub    $0xc,%esp
 c4e:	50                   	push   %eax
 c4f:	e8 6b fc ff ff       	call   8bf <sbrk>
 c54:	83 c4 10             	add    $0x10,%esp
 c57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 c5a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 c5e:	75 07                	jne    c67 <morecore+0x38>
    return 0;
 c60:	b8 00 00 00 00       	mov    $0x0,%eax
 c65:	eb 26                	jmp    c8d <morecore+0x5e>
  hp = (Header*)p;
 c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 c6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c70:	8b 55 08             	mov    0x8(%ebp),%edx
 c73:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c79:	83 c0 08             	add    $0x8,%eax
 c7c:	83 ec 0c             	sub    $0xc,%esp
 c7f:	50                   	push   %eax
 c80:	e8 c8 fe ff ff       	call   b4d <free>
 c85:	83 c4 10             	add    $0x10,%esp
  return freep;
 c88:	a1 f0 10 00 00       	mov    0x10f0,%eax
}
 c8d:	c9                   	leave  
 c8e:	c3                   	ret    

00000c8f <malloc>:

void*
malloc(uint nbytes)
{
 c8f:	55                   	push   %ebp
 c90:	89 e5                	mov    %esp,%ebp
 c92:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c95:	8b 45 08             	mov    0x8(%ebp),%eax
 c98:	83 c0 07             	add    $0x7,%eax
 c9b:	c1 e8 03             	shr    $0x3,%eax
 c9e:	83 c0 01             	add    $0x1,%eax
 ca1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 ca4:	a1 f0 10 00 00       	mov    0x10f0,%eax
 ca9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 cb0:	75 23                	jne    cd5 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 cb2:	c7 45 f0 e8 10 00 00 	movl   $0x10e8,-0x10(%ebp)
 cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cbc:	a3 f0 10 00 00       	mov    %eax,0x10f0
 cc1:	a1 f0 10 00 00       	mov    0x10f0,%eax
 cc6:	a3 e8 10 00 00       	mov    %eax,0x10e8
    base.s.size = 0;
 ccb:	c7 05 ec 10 00 00 00 	movl   $0x0,0x10ec
 cd2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cd8:	8b 00                	mov    (%eax),%eax
 cda:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ce0:	8b 40 04             	mov    0x4(%eax),%eax
 ce3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 ce6:	77 4d                	ja     d35 <malloc+0xa6>
      if(p->s.size == nunits)
 ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ceb:	8b 40 04             	mov    0x4(%eax),%eax
 cee:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 cf1:	75 0c                	jne    cff <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cf6:	8b 10                	mov    (%eax),%edx
 cf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cfb:	89 10                	mov    %edx,(%eax)
 cfd:	eb 26                	jmp    d25 <malloc+0x96>
      else {
        p->s.size -= nunits;
 cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d02:	8b 40 04             	mov    0x4(%eax),%eax
 d05:	2b 45 ec             	sub    -0x14(%ebp),%eax
 d08:	89 c2                	mov    %eax,%edx
 d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d0d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d13:	8b 40 04             	mov    0x4(%eax),%eax
 d16:	c1 e0 03             	shl    $0x3,%eax
 d19:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d1f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 d22:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d28:	a3 f0 10 00 00       	mov    %eax,0x10f0
      return (void*)(p + 1);
 d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d30:	83 c0 08             	add    $0x8,%eax
 d33:	eb 3b                	jmp    d70 <malloc+0xe1>
    }
    if(p == freep)
 d35:	a1 f0 10 00 00       	mov    0x10f0,%eax
 d3a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 d3d:	75 1e                	jne    d5d <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 d3f:	83 ec 0c             	sub    $0xc,%esp
 d42:	ff 75 ec             	pushl  -0x14(%ebp)
 d45:	e8 e5 fe ff ff       	call   c2f <morecore>
 d4a:	83 c4 10             	add    $0x10,%esp
 d4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 d50:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 d54:	75 07                	jne    d5d <malloc+0xce>
        return 0;
 d56:	b8 00 00 00 00       	mov    $0x0,%eax
 d5b:	eb 13                	jmp    d70 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d60:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d66:	8b 00                	mov    (%eax),%eax
 d68:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 d6b:	e9 6d ff ff ff       	jmp    cdd <malloc+0x4e>
  }
}
 d70:	c9                   	leave  
 d71:	c3                   	ret    
