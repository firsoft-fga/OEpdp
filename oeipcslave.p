DEFINE VARIABLE iResult AS INTEGER NO-UNDO.
DEF VAR myid AS INT NO-UNDO.
DEF VAR mypid AS INT NO-UNDO.
DEF VAR myuserid AS INT NO-UNDO.
DEF VAR myname AS CHAR NO-UNDO.
DEF VAR res AS INT NO-UNDO.
DEF VAR res1 AS INT NO-UNDO.
DEF VAR ipcname AS CHAR NO-UNDO.
DEF VAR ipcnum AS INT NO-UNDO.
DEF VAR i AS INT NO-UNDO.
DEF VAR ii AS INT NO-UNDO.
DEF VAR i64 AS INT64 NO-UNDO.
DEF VAR str AS CHAR NO-UNDO.
DEF VAR ret_code AS INT NO-UNDO.
DEF VAR ret_buffer AS CHAR NO-UNDO.
// DEF VAR ss AS CHAR NO-UNDO.


ETIME(YES).
// OUTPUT TO VALUE("oeipc.log") UNBUFFERED APPEND.

FIND demo._MyConnection .
mypid = _MyConnection._MyConn-Pid.
myuserid = _MyConnection._MyConn-UserId.

myname = 'SLAVE'.
myid = 1.
SESSION:DATE-FORMAT = "dmy".

ret_buffer = OS-GETENV("ipcnum").
ipcnum = INT(ret_buffer).
IF ipcnum = ? OR ipcnum < 1 THEN
DO:
  MESSAGE NOW mypid 'SLAVE ### bad or absent os-env ipcnum' ipcnum. 
  RETURN.
END.
myid = ipcnum.
myname = myname + STRING(ipcnum,'99').

ipcname = OS-GETENV("ipcname").
IF ipcname = '' OR ipcname = ? THEN
DO:
  MESSAGE NOW mypid  myname '### bad or absent os-env ipcname'  ipcname. 
  RETURN.
END.

MESSAGE  NOW mypid myname 'start'  'ipcname=' ipcname ipcnum .
RUN ipc_init1(ipcname,myid,OUTPUT ret_code).

RUN shm_get(OUTPUT ret_code).
IF ret_code NE 0 THEN
DO:
  MESSAGE  NOW mypid myname '### shared memory with error=' ret_code.
  RETURN.
END.

RUN sem_get(OUTPUT ret_code).
IF ret_code NE 0 THEN
DO:
  MESSAGE  NOW mypid  myname '### semaphore with error=' ret_code.
  RETURN.
END.

RUN shm_read(OUTPUT ii,INPUT myid,INPUT 0,OUTPUT ret_code).
RUN sys_testpid(INPUT ii  ,OUTPUT ret_code).

IF  ret_code = 0 AND mypid NE ii THEN
DO:
   RUN shm_read(OUTPUT i,INPUT myid,INPUT 1,OUTPUT ret_code).
   FIND  _Connect WHERE  _Connect._Connect-Id = i + 1 NO-LOCK NO-ERROR  .
   IF AVAILABLE _Connect AND _Connect-Pid = ii THEN
   DO:
     MESSAGE  NOW mypid myname '### already exist with pid=' ii.
     RETURN.
   END.  
END.


RUN shm_write(INPUT mypid,INPUT myid,INPUT 0,OUTPUT ret_code).
RUN shm_write(INPUT myuserid,INPUT myid,INPUT 1,OUTPUT ret_code).
RUN shm_writes(INPUT STRING(TODAY) + ' ' + STRING(TIME,'hh:mm:ss') ,INPUT myid,INPUT 40,OUTPUT ret_code).
RUN shm_write(INPUT TIME,INPUT myid,INPUT 15,OUTPUT ret_code).

REPEAT:
 RUN sem_wait(INPUT myid,OUTPUT ii)    .
 str=FILL(' ',64).
 RUN shm_reads(OUTPUT str,INPUT myid,INPUT 16,OUTPUT ret_code).
 IF ret_code < 1 THEN
 DO:
   PAUSE 10.
   NEXT.
 END.
 str=SUBSTR(str,1,ret_code).
 //  MESSAGE '##'  length(str) str TRANSACTION  .
 IF str = 'STOP' THEN
 DO:
   MESSAGE  NOW mypid myname 'receive STOP signal !'  . 
   RETURN.  
 END.
 IF str = 'done' THEN
 DO:
   PAUSE 10.
   NEXT.
 END.
 RUN doit.
 // MESSAGE '## after doit' TRANSACTION  .
 RUN sem_red(INPUT myid,OUTPUT ret_code).
END.

PROCEDURE doit:
DO TRANSACTION :

  RUN shm_write(INPUT TIME,INPUT myid,INPUT 15,OUTPUT ret_code).
  RUN shm_writes(INPUT str,INPUT myid,INPUT 40,OUTPUT ret_code).
  // MESSAGE length(str) str '#'  .
  FIND order WHERE ROWID(order) = TO-ROWID(str) EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
  IF AVAILABLE order AND order.shipped = 'k' THEN
  DO:
    RUN shm_writes(INPUT 'done',INPUT myid,INPUT 16,OUTPUT ret_code).
    MESSAGE  NOW mypid myname '### receive'  str 'NTD'. 
  END.  
  IF AVAILABLE order AND order.shipped = '' THEN
  DO:
    order.shipped = 'k' .  
    RUN shm_writes(INPUT 'done',INPUT myid,INPUT 16,OUTPUT ret_code).
    MESSAGE  NOW mypid myname '$$$ receive'  str 'DONE'. 
  END.
  IF LOCKED order THEN
  DO:
    MESSAGE  NOW mypid myname '### receive'  str 'locked' .
    RUN shm_writes(INPUT 'done',INPUT myid,INPUT 16,OUTPUT ret_code).
  END.
  IF NOT AVAILABLE order AND NOT LOCKED order THEN
  DO:
    MESSAGE  NOW mypid myname '### receive'  str 'N/A' .
    RUN shm_writes(INPUT 'done',INPUT myid,INPUT 16,OUTPUT ret_code). 
  END.
 // MESSAGE  NOW mypid myname 'receive'  str IF AVAILABLE order AND  order.shipped = 'k' THEN 'DONE' ELSE 'lock'.
  RELEASE order NO-ERROR.
  END .
  // MESSAGE 'doit' TRANSACTION.
 
 END PROCEDURE.



FINALLY: 
 RUN shm_rm(OUTPUT res).
 RUN sem_rm1(OUTPUT res).
 RELEASE EXTERNAL PROCEDURE "c:\fga\bin\debug\my1dll.dll".
 MESSAGE  NOW mypid  myname 'ENDED !' .
END. 
 
{"c:\oepdp\includes\proipc.i"}
