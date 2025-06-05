
PROCEDURE ipc_int EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:    // get initial values for master process
  DEFINE OUTPUT PARAMETER result AS LONG.
  DEFINE RETURN PARAMETER ipcslot AS LONG.
END. 

PROCEDURE ipc_init EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:   // set initial values for master process
  DEFINE INPUT PARAMETER ipcname AS CHAR.                          // oepdp name
  DEFINE INPUT PARAMETER ipcnum AS LONG.                           // number of slave processes
  DEFINE INPUT PARAMETER ipcslot AS LONG.                          // memory slot size 
  DEFINE RETURN PARAMETER nn AS LONG.                              // ipcnum * ipcslot (full oepdp memory size)
END. 

PROCEDURE ipc_init1 EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:  // set initial values for slave process
  DEFINE INPUT PARAMETER ipcname AS CHAR.                          // oepdp name ( same as for master) 
  DEFINE INPUT PARAMETER ipcnum AS LONG.                           // number of slave process
  DEFINE RETURN PARAMETER nn AS LONG.
END. 

PROCEDURE ipc_get EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:     // get oepdp name and current process number ( 0 for master)
  DEFINE INPUT-OUTPUT PARAMETER ipcname AS CHAR.
  DEFINE RETURN PARAMETER ipcnum AS LONG.
END. 

PROCEDURE sys_getpid EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:   // get pid of current process
  DEFINE RETURN PARAMETER result AS LONG.
END. 

PROCEDURE sys_testpid EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:  // check pid  
  DEFINE INPUT PARAMETER oid AS LONG.
  DEFINE RETURN PARAMETER result AS LONG.
END. 

PROCEDURE sys_kill EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:     // kill process with oid pid
  DEFINE INPUT PARAMETER oid AS LONG.
  DEFINE RETURN PARAMETER result AS LONG.
END. 

PROCEDURE shm_set EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:      // master allocate oepdp memory  
  DEFINE RETURN PARAMETER result AS LONG.
END. 

PROCEDURE shm_get EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:     // slave get oepdp memory 
  DEFINE RETURN PARAMETER result AS LONG.
END. 

PROCEDURE shm_write EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:   // write int value to oepdp memory 
  DEFINE INPUT PARAMETER ival AS LONG.                              // int value
  DEFINE INPUT PARAMETER bufnum  AS LONG.                           // slave number 
  DEFINE INPUT PARAMETER offset AS LONG.                            // word number ( 0 from 0 byte, 1 from 4 byte and etc ) 
  DEFINE RETURN PARAMETER nn AS LONG.
END. 

PROCEDURE shm_read EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:     // read int value from oepdp memory
  DEFINE OUTPUT PARAMETER ival AS LONG.
  DEFINE INPUT PARAMETER bufnum  AS LONG.
  DEFINE INPUT PARAMETER offset AS LONG.
  DEFINE RETURN PARAMETER nn AS LONG.
END. 

PROCEDURE shm_write64 EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:  // write int64 value to oepdp memory
  DEFINE INPUT PARAMETER ival AS INT64.
  DEFINE INPUT PARAMETER bufnum  AS LONG.
  DEFINE INPUT PARAMETER offset AS LONG.
  DEFINE RETURN PARAMETER nn AS LONG.
END. 

PROCEDURE shm_read64 EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:   // read int64 value from oepdp memory
  DEFINE OUTPUT PARAMETER ival AS INT64.
  DEFINE INPUT PARAMETER bufnum  AS LONG.
  DEFINE INPUT PARAMETER offset AS LONG.                             // double word number  ( 0 from 0 byte, 1 from 8 byte and etc ) 
  DEFINE RETURN PARAMETER nn AS LONG.
 END. 
 
 PROCEDURE shm_writes EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:   // write string to oepdp memory
  DEFINE INPUT PARAMETER chval AS CHAR.
  DEFINE INPUT PARAMETER bufnum  AS LONG.
  DEFINE INPUT PARAMETER offset AS LONG.                              // in bytes
  DEFINE RETURN PARAMETER nn AS LONG.
END. 

PROCEDURE shm_reads EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:     // read string from oepdp memory
  DEFINE OUTPUT PARAMETER chval AS CHAR.
  DEFINE INPUT PARAMETER bufnum  AS LONG.
  DEFINE INPUT PARAMETER offset AS LONG.
  DEFINE RETURN PARAMETER nn AS LONG.
END. 

PROCEDURE shm_handle EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:    // get windows handle number for oepdp memory
  DEFINE OUTPUT PARAMETER chval AS CHAR.
  DEFINE RETURN PARAMETER nn AS LONG.
END. 

PROCEDURE shm_rm EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:       //  free oepdp memory
  DEFINE RETURN PARAMETER result AS LONG.
END. 

PROCEDURE sem_set EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:      // master allocate oepdp semaphores  
  DEFINE RETURN PARAMETER result AS LONG.
END. 

PROCEDURE sem_get EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:      //  slave get oepdp semaphore
  DEFINE RETURN PARAMETER result AS LONG.
END.

PROCEDURE sem_rm EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:       // master delete oepdp semaphores
  DEFINE RETURN PARAMETER result AS LONG.
END. 

PROCEDURE sem_rm1 EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:      // slave release oepdp semaphore 
  DEFINE RETURN PARAMETER result AS LONG.
END. 

PROCEDURE sem_sta EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:      // return oepdp semaphore status 
  DEFINE INPUT PARAM num AS LONG.
  DEFINE RETURN PARAMETER result AS LONG.
END. 

PROCEDURE sem_green EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:    // set oepdp semaphore as green
  DEFINE INPUT PARAM num AS LONG.
  DEFINE RETURN PARAMETER result AS LONG.
END. 

PROCEDURE sem_red EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:      // set oepdp semaphore as red 
  DEFINE INPUT PARAM num AS LONG.
  DEFINE RETURN PARAMETER result AS LONG.
END. 

PROCEDURE sem_wait EXTERNAL "c:\oepdp\lib\oeipc.dll" PERSISTENT:      // wait behind red oepdp semaphore 
  DEFINE INPUT PARAM num AS LONG.
  DEFINE RETURN PARAMETER result AS LONG.
END. 
