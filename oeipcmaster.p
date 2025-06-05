DEF VAR myid AS INT NO-UNDO.
DEF VAR mypid AS INT NO-UNDO.
DEF VAR myuserid AS INT NO-UNDO.
DEF VAR myname AS CHAR NO-UNDO.
DEF VAR ipcname AS CHAR NO-UNDO.
DEF VAR cc AS CHAR NO-UNDO.
DEF VAR ii AS INT NO-UNDO.
DEF VAR ret_code AS INT NO-UNDO.
DEF VAR ret_buffer AS CHAR NO-UNDO.
DEF VAR maxslave AS INT NO-UNDO.
DEF VAR ipcslot  AS INT NO-UNDO.
DEF VAR gettime AS INT64 NO-UNDO INIT 500.
DEF VAR nww AS INT NO-UNDO.
DEF VAR nreq AS INT NO-UNDO.
DEF VAR i AS INT NO-UNDO.
DEF VAR t1 AS INT64 NO-UNDO.
DEF VAR t2 AS INT NO-UNDO.
DEF VAR t3 AS INT NO-UNDO.
DEF VAR t4 AS INT NO-UNDO.
DEF VAR i1 AS INT NO-UNDO.
DEF VAR i2 AS INT NO-UNDO.
DEF VAR str AS CHAR NO-UNDO.
DEF VAR flag AS LOGICAL NO-UNDO.
DEF VAR fl1 AS LOGICAL NO-UNDO.
DEF VAR fl2 AS LOGICAL NO-UNDO.

DEF TEMP-TABLE ttREQ NO-UNDO
 FIELD ckey  AS CHAR FORMAT 'x(20)'
 FIELD bunch AS CHAR
 FIELD prior AS INT
 FIELD phase AS INT 
 INDEX ckey1 AS UNIQUE ckey
 INDEX prior1 prior
 INDEX bunch1 bunch prior.
 
DEF TEMP-TABLE ww NO-UNDO
 FIELD bunch AS CHAR
 FIELD nslave AS INT
 FIELD prior AS INT
 INDEX bunch1 AS UNIQUE bunch 
 Index bunch2 AS PRIMARY prior bunch  
 INDEX nslave1 nslave .
            
DEF TEMP-TABLE ttslave NO-UNDO
 FIELD bunch    AS CHAR 
 FIELD nslave AS INT 
 FIELD tim1     AS INT 
 FIELD tim2     AS INT
 FIELD ckey     AS CHAR FORMAT 'x(20)'
 INDEX bunch1  bunch
 INDEX nslave1 AS UNIQUE nslave.

// OUTPUT TO VALUE("oeipc.log") UNBUFFERED APPEND.

ETIME(YES).
myname = 'MASTER'.
myid = 0.
SESSION:DATE-FORMAT = "dmy".


FIND demo._MyConnection .
mypid = _MyConnection._MyConn-Pid.
myuserid = _MyConnection._MyConn-UserId.

ipcname = OS-GETENV("ipcname").
IF ipcname = '' OR ipcname = ? THEN
DO:
  MESSAGE NOW mypid 'MASTER ### bad or absent os-env ipcname'  ipcname. 
  RETURN.
END.

ret_buffer = OS-GETENV("maxslave").
maxslave = INT(ret_buffer).
IF maxslave < 2 OR maxslave = ? THEN
DO:
  MESSAGE NOW mypid 'MASTER ### bad or absent os-env maxslave' maxslave. 
  RETURN.
END.

ret_buffer = OS-GETENV("ipcslot").
ipcslot = INT(ret_buffer).
IF ipcslot < 64 OR ipcslot = ? THEN
DO:
  MESSAGE NOW mypid 'MASTER ### bad or absent os-env ipcslot' ipcslot. 
  RETURN.
END.

 REPEAT i = 1 TO maxslave :
    CREATE ttslave .
    ASSIGN
       ttslave.nslave = i .
 END.


MESSAGE  NOW mypid 'MASTER start'  'ipcname=' ipcname 'nslave=' maxslave 'ipcslot=' ipcslot.

RUN ipc_init(INPUT ipcname,INPUT maxslave,INPUT ipcslot,OUTPUT ret_code).

RUN shm_set(OUTPUT ret_code).
IF ret_code NE 0 THEN
DO:
  MESSAGE  NOW mypid 'MASTER ### shared memory with error=' ret_code.
  RETURN.
END.

RUN sem_set(OUTPUT ret_code).
IF ret_code NE 0 THEN
DO:
  MESSAGE  NOW mypid 'MASTER ### semaphore with error=' ret_code.
  RETURN.
END.

RUN shm_read(OUTPUT ii,INPUT 0,INPUT 0,OUTPUT ret_code).
RUN sys_testpid(INPUT ii  ,OUTPUT ret_code).

IF  ret_code = 0 AND mypid NE ii THEN
DO:
   RUN shm_read(OUTPUT i,INPUT 0,INPUT 1,OUTPUT ret_code).
   FIND  _Connect WHERE  _Connect._Connect-Id = i + 1 NO-LOCK NO-ERROR  .
   IF AVAILABLE _Connect AND _Connect-Pid = ii THEN
   DO:
     MESSAGE  NOW mypid 'MASTER ### already exist with pid=' ii.
     RETURN.
   END.  
END.


RUN shm_write(INPUT mypid,INPUT myid,INPUT 0,OUTPUT ret_code).
RUN shm_write(INPUT myuserid,INPUT myid,INPUT 1,OUTPUT ret_code).
str = 'START ' + string(NOW) .
RUN shm_writes(INPUT str,INPUT myid,INPUT 16,OUTPUT ret_code).

// MESSAGE 'etime=' ETIME .
{"c:\oepdp\includes\proipc.i"}

REPEAT:
 PAUSE gettime / 1000.
 str=FILL(' ',64).
 RUN shm_reads(OUTPUT str,INPUT myid,INPUT 16,OUTPUT ret_code).
 str=SUBSTR(str,1,ret_code).
 IF str = 'STOP' THEN
 DO:
   MESSAGE  NOW mypid 'MASTER receive STOP signal !' . 
   RUN stopall .
   RETURN.  
 END.
 IF str = 'STAT'  THEN
 DO:
   RUN stat.
   RUN shm_writes(INPUT 'done',INPUT myid,INPUT 16,OUTPUT ret_code).
 END.
 RUN getreq.
 RUN checkreq.
END.

FINALLY: 
 RUN shm_rm(OUTPUT ret_code).
 RUN sem_rm(OUTPUT ret_code).
 RELEASE EXTERNAL PROCEDURE "c:\oepdp\lib\oeipc.dll".
 MESSAGE  NOW mypid 'MASTER ENDED !' .
END.


PROCEDURE stopall :
  str = 'STOP'.
  REPEAT i=1 TO maxslave :
    RUN shm_writes(INPUT str,INPUT i,INPUT 16,OUTPUT ret_code).
    RUN sem_green(INPUT i,OUTPUT ret_code).
  END.
END PROCEDURE.  

 PROCEDURE getreq :
   t1=etime.
   FOR EACH order WHERE shipped = '' NO-LOCK:
       // DISP order.cust-num .
       IF ETIME - t1 >  gettime THEN LEAVE.
       // IF nww > maxslave * 1.2 THEN LEAVE.
       FIND FIRST ttreq WHERE ttreq.ckey=string(ROWID(order)) NO-LOCK NO-ERROR.
       IF AVAILABLE ttreq THEN NEXT.
       CREATE ttreq.
       nreq=nreq + 1.
       ASSIGN
         ttreq.phase = 1
         ttreq.ckey = STRING(ROWID(order))
         ttreq.prior = 1
         ttreq.bunch = STRING(order.cust-num) .
       FIND FIRST ww WHERE ww.bunch = ttreq.bunch NO-LOCK NO-ERROR. 
       IF NOT AVAILABLE ww THEN
       DO:
         CREATE ww .
           ww.bunch = ttreq.bunch.
           nww = nww + 1.
       END.
       ww.prior = MIN(ww.prior,ttreq.prior).
       FIND FIRST ttslave WHERE ttslave.bunch = ttreq.bunch NO-LOCK NO-ERROR.
       // IF AVAILABLE ttslave  THEN NEXT.
       IF NOT AVAILABLE ttslave THEN
        DO:
         FIND FIRST ttslave WHERE ttslave.bunch = '' NO-LOCK NO-ERROR.
         IF NOT AVAILABLE ttslave  THEN  NEXT . // LEAVE.
        END. 
        ASSIGN
         ttreq.phase = 2
         ww.bunch = ttreq.bunch
         ww.nslave = ttslave.nslave
         ttslave.bunch = ttreq.bunch
         ttslave.ckey=ttreq.ckey.
         RUN setreq.
    END.   
 END PROCEDURE.
 
PROCEDURE setreq:
/*
 FIELD bunch    AS CHAR 
 FIELD nslave AS INT 
 FIELD tim1     AS INT 
 FIELD ckey     AS CHAR
*/
  RUN shm_writes(INPUT ttslave.ckey,INPUT ttslave.nslave,INPUT 16,OUTPUT ret_code).
  RUN shm_write(INPUT TIME,INPUT ttslave.nslave,INPUT 9,OUTPUT ret_code).
  ttslave.tim1 = TIME.
  RUN sem_green(INPUT ttslave.nslave,OUTPUT ret_code).

END PROCEDURE.

PROCEDURE checkreq :
  FOR EACH ttslave WHERE ttslave.ckey NE '' :
    FIND ttreq WHERE ttreq.ckey = ttslave.ckey.
    RUN shm_reads(OUTPUT str,INPUT ttslave.nslave,INPUT 16,OUTPUT ret_code).
    str=SUBSTR(str,1,ret_code).
    IF str = 'done' THEN
    DO:
      DELETE ttreq.
      nreq = nreq - 1.
        ASSIGN ttslave.ckey = '' .
        FIND FIRST ttreq WHERE ttreq.bunch = ttslave.bunch NO-LOCK NO-ERROR.
        IF NOT AVAILABLE ttreq THEN
        DO:
          FIND FIRST ww WHERE ww.bunch = ttslave.bunch NO-LOCK NO-ERROR.
          IF AVAILABLE ww THEN 
          DO:
            DELETE ww.
            nww = nww - 1.
          END.
          ELSE
          DO:
              
          END.
          ttslave.bunch = ''.
        END.   
         ELSE DO:
           ttslave.ckey = ttreq.ckey.
           RUN setreq .
         END.  
    END.
    ELSE 
    DO:
       RUN sem_sta(INPUT ttslave.nslave,OUTPUT ret_code).
       IF ret_code = 258 THEN
       DO:
         RUN sem_green(INPUT ttslave.nslave,OUTPUT ret_code).
         NEXT.
       END.
       IF ABSOLUTE(TIME - ttslave.tim1) > 10 THEN
       DO:
         IF ABSOLUTE(TIME - ttslave.tim2) > 300 THEN
         DO:
           ttslave.tim2 = TIME.
           flag = YES.
           RUN shm_read(OUTPUT ii,INPUT ttslave.nslave,INPUT 0,OUTPUT ret_code).
           RUN sys_testpid(INPUT ii  ,OUTPUT ret_code).
           IF  ret_code = 0 THEN
              DO:
                RUN shm_read(OUTPUT i,INPUT 0,INPUT 1,OUTPUT ret_code).
                FIND  _Connect WHERE  _Connect._Connect-Id = i + 1 NO-LOCK NO-ERROR  .
                IF AVAILABLE _Connect AND _Connect-Pid = ii THEN
                  DO:
                    MESSAGE  NOW mypid 'MASTER ### ABSENT slave' ttslave.nslave.
                    flag = NO.
              END.  
           END.
           ELSE
               DO:
                  MESSAGE  NOW mypid 'MASTER ### ABSENT slave !' ttslave.nslave.
                  flag = NO.
               END.
           IF flag THEN
           DO:
              MESSAGE NOW mypid 'MASTER ### what it do ?' ttslave.nslave . 
            END.
            ELSE 
            DO:
              ttslave.tim1 = TIME .
              ttslave.tim2 = TIME .
              cc="jvmStart -p newconsole c:/oepdp/workdir/oeipc1.bat " + string(ttslave.nslave).
              MESSAGE 'start slave'  ttslave.nslave .
              OS-COMMAND NO-WAIT  VALUE(cc).
              MESSAGE 'END start' .
              LEAVE.
            END.
          END.  
       END.
    END.
  END.  
   FOR EACH ttslave WHERE ttslave.bunch = '':
        FIND FIRST ww WHERE ww.nslave = 0 NO-LOCK NO-ERROR .
        IF NOT AVAILABLE ww THEN LEAVE.
        FIND FIRST ttreq WHERE ttreq.bunch = ww.bunch AND phase = 1 NO-LOCK NO-ERROR.
        IF AVAILABLE ttreq THEN
          DO:
             ASSIGN 
               ttreq.phase = 2
               ww.nslave = ttslave.nslave 
               ttslave.bunch = ww.bunch
               ttslave.ckey = ttreq.ckey.
             RUN setreq.  
           END.
   END.
  
END PROCEDURE .

PROCEDURE stat:
 MESSAGE  NOW mypid 'MASTER ### statistics' nww nreq.
 FOR EACH ttslave:
    RUN shm_read(OUTPUT ii,INPUT ttslave.nslave,INPUT 0,OUTPUT ret_code).
    RUN sys_testpid(INPUT ii  ,OUTPUT i).
    RUN sem_sta(INPUT ttslave.nslave,OUTPUT ret_code).
    DISP ttslave.nslave 'semsta=' IF i = 0 THEN (IF ret_code = 258 THEN 'wait' ELSE 'work') ELSE 'absent' 'PID=' ii FORMAT 'zzzz99'.
 END.
 FOR EACH ttslave:
   DISP ttslave.
 END.
 FOR EACH ww:
    DISP ww.
 END.
 FOR EACH ttreq:
  DISP ttreq.
 END.
END PROCEDURE.
