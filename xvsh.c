#include "types.h"
#include "fcntl.h"
#include "user.h"
#include <sys/types.h>


#define SH_PROMPT "xvsh> "
#define NULL (void *)0


char *strtok(char *s, const char *delim);

int process_one_cmd(char *);
int pip_pos;
int red_pos;

#define MAXLINE 256

int main(int argc, char *argv[])
{
    char buf[MAXLINE];
    int i;
    int n;
    printf(1, SH_PROMPT);  /* print prompt (printf requires %% to print %) */

    while ( (n = read(0, buf, MAXLINE)) != 0) 
    {
        if (n == 1)                           /* no input at all, we should skip */
        {
            printf(1, SH_PROMPT);
            continue;
        }
        buf[i = (strlen(buf) - 1)] = 0;       /* replace newline with null */

        process_one_cmd(buf);
        
        printf(1, SH_PROMPT);
      
        memset(buf, 0, sizeof(buf));
    }
    
    
    exit();
}
// When I try to exit I have to type it twice.
// Is it because after process_one_cmd it goes to printf(1, SH_PROMPT)?

// When running &, there is no xvsh>, but you can still run commands

// When I add #include <unistd.h> I start getting more errors

int exit_check(char **tok, int num_tok)
{
    int strret = strcmp(tok[0], "exit");
    if(strret == 0){
        return 1;
    }
    return 0;
}


int process_pipe(char **tok){
    int fds[2];
    pid_t pid1, pid2;

    // Create a pipe
    if(pipe(fds) == -1){
        exit();
    }

    // Fork first child
    if((pid1 = fork()) < 0){
        exit();
    }

    if(pid1 == 0){
        close(1);
        dup(fds[1]);
        close(fds[0]);

        if(exec(tok[0], tok)){
            exit();
        }
    }

    // Fork second child
    if((pid2 = fork()) < 0){
        exit();
    }

    if(pid2 == 0){
        close(0);
        dup(fds[0]);
        close(fds[1]);

        if(exec(tok[pip_pos], tok)){
            exit();
        }
    }

    close(fds[0]);
    close(fds[1]);

    // Parent waits for children to complete
    
    for(int z = 0; z < 2; z++){
        wait();
    }
    
    return 0;
}

int process_normal(char **tok, int bg)
{
    int PID = fork();
    if(PID == 0){
        int PIDE = exec(*tok, tok);
        if(PIDE < 0){
            printf(1, "Cannot run this command: %s\n", *tok);
        }
    }
    if(bg == 0){
        if(PID > 0){
            wait();
        }
    }
    if(bg != 0){
        // can add return 0;
    }


    // your implementation here
    // note that exec(*tok, tok) is the right way to invoke exec in xv6
    return 0;
}

// When I run it, it leaves xvsh, but when I run a command
// that isn't accepted then run it, it doens't leave it.
int process_redirect(char** tok){

    int rc = fork();
    if(rc < 0){
        exit();
    }
    else if(rc == 0){
        close(1);
        open(tok[red_pos], O_CREATE|O_WRONLY);
        exec(tok[0], tok);
    }
    else{
        wait();
    }

    return 0;
}


int process_one_cmd(char* buf)
{
    int i, num_tok;
    char **tok;
    int bg;
    int pip;
    int red;
    i = (strlen(buf) - 1);
    num_tok = 1;

    while (i)
    {
        if (buf[i--] == ' ')
            num_tok++;
    }

    if (!(tok = malloc( (num_tok + 1) *   sizeof (char *)))) 
    {
        printf(1, "malloc failed\n");
        exit();
    }        


    i = bg = pip = red = 0;
    tok[i++] = strtok(buf, " ");

    /* check special symbols */
    while ((tok[i] = strtok(NULL, " "))) 
    {
        switch (*tok[i]) 
        {
            case '&':
                bg = i;
                tok[i] = NULL;
                break;
            case '|':
                pip = 2;
                tok[i] = NULL;
                pip_pos = i + 1;
                break;
            case '>':
                red = 3;
                tok[i] = NULL;
                red_pos = i + 1;
                break;
            default:
                // do nothing
                break;
        }   
        i++;
    }

    /*Check buid-in exit command */
    if (exit_check(tok, num_tok))
    {
        /*some code here to wait till all children exit() before exit*/
	// your implementation here
        while(wait() > 0){
            
        }
        exit();
    }

    // your code to check NOT implemented cases
    
    /* to process one command */
    if(pip == 2){
        process_pipe(tok);
        free(tok);
        return 0;
    }
    if(red == 3){
        process_redirect(tok);
        free(tok);
        return 0;
    }
    process_normal(tok, bg);

    free(tok);
    return 0;
}



char *
strtok(s, delim)
    register char *s;
    register const char *delim;
{
    register char *spanp;
    register int c, sc;
    char *tok;
    static char *last;


    if (s == NULL && (s = last) == NULL)
        return (NULL);

    /*
     * Skip (span) leading delimiters (s += strspn(s, delim), sort of).
     */
cont:
    c = *s++;
    for (spanp = (char *)delim; (sc = *spanp++) != 0;) {
        if (c == sc)
            goto cont;
    }

    if (c == 0) {        /* no non-delimiter characters */
        last = NULL;
        return (NULL);
    }
    tok = s - 1;

    /*
     * Scan token (scan for delimiters: s += strcspn(s, delim), sort of).
     * Note that delim must have one NUL; we stop if we see that, too.
     */
    for (;;) {
        c = *s++;
        spanp = (char *)delim;
        do {
            if ((sc = *spanp++) == c) {
                if (c == 0)
                    s = NULL;
                else
                    s[-1] = 0;
                last = s;
                return (tok);
            }
        } while (sc != 0);
    }
    /* NOTREACHED */
}

