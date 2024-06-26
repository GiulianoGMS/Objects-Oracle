CREATE OR REPLACE VIEW CONSINCO.NAGV_LOCKS AS
SELECT "SO","SID","SERIAL#","DURACAO","INST_ID","AMBIENTE","SID_LOCKED","LOCKING_INFO","STATUS","OSUSER","MACHINE","PROGRAMA","OBJETO","LOGON_TIME","MIN_ACTIVE" FROM (

SELECT INITCAP(NVL(GV$SESSION.USERNAME, '{Oracle}')) SO, GV$SESSION.SID, GV$SESSION.SERIAL#,
       TRIM(TO_CHAR(TRUNC(GV$SESSION.LAST_CALL_ET / 60 / 60))) || ':' ||
       TRIM(TO_CHAR(TRUNC(MOD(GV$SESSION.LAST_CALL_ET, 3600) / 60), '00')) || ':' ||
       TRIM(TO_CHAR(MOD(MOD(GV$SESSION.LAST_CALL_ET, 3600), 60), '00')) DURACAO,
       GV$INSTANCE.INST_ID, INITCAP(GV$INSTANCE.INSTANCE_NAME) AMBIENTE,
       DECODE(GV$SESSION.BLOCKING_SESSION, NULL, NULL, 'SID ' || GV$SESSION.BLOCKING_SESSION) SID_LOCKED,

       CASE WHEN GV$SESSION.BLOCKING_SESSION IS NULL THEN NULL ELSE TRIM(TO_CHAR(TRUNC(X.LAST_CALL_ET / 60 / 60))) || ':' ||
       TRIM(TO_CHAR(TRUNC(MOD(X.LAST_CALL_ET, 3600) / 60), '00')) || ':' ||
       TRIM(TO_CHAR(MOD(MOD(X.LAST_CALL_ET, 3600), 60), '00')) ||' - Status: '||INITCAP(X.STATUS)||' - User: '||INITCAP(X.OSUSER)||' - Programa: '||INITCAP(X.PROGRAM)
       END LOCKING_INFO,

       INITCAP(GV$SESSION.STATUS)  STATUS,
       INITCAP(GV$SESSION.OSUSER)  OSUSER,
       INITCAP(GV$SESSION.MACHINE) MACHINE,
       INITCAP(GV$SESSION.PROGRAM) PROGRAMA,
       INITCAP(DECODE(DBA_SCHEDULER_RUNNING_JOBS.JOB_NAME, NULL,
       DECODE(DBA_JOBS_RUNNING.JOB, NULL, GV$SESSION.MODULE, 'Job ' || DBA_JOBS_RUNNING.JOB), 'Sch ' || DBA_SCHEDULER_RUNNING_JOBS.JOB_NAME)) OBJETO,
       GV$SESSION.LOGON_TIME,
       TO_CHAR(TRUNC((SYSDATE - GV$SESSION.LOGON_TIME) * 24)) || 'h' ||
       TO_CHAR(TRUNC(MOD((SYSDATE - GV$SESSION.LOGON_TIME) * 24 * 60, 60)), '00')||'m' MIN_ACTIVE

  FROM GV$SESSION LEFT JOIN GV$SESS_IO ON GV$SESS_IO.SID = GV$SESSION.SID AND GV$SESS_IO.INST_ID = GV$SESSION.INST_ID
                  LEFT JOIN GV$PROCESS ON GV$PROCESS.ADDR = GV$SESSION.PADDR AND GV$PROCESS.INST_ID = GV$SESSION.INST_ID
                  INNER JOIN GV$INSTANCE ON GV$INSTANCE.INST_ID = GV$SESSION.INST_ID
                  LEFT JOIN DBA_JOBS_RUNNING ON DBA_JOBS_RUNNING.SID = GV$SESSION.SID
                  LEFT JOIN DBA_SCHEDULER_RUNNING_JOBS ON DBA_SCHEDULER_RUNNING_JOBS.SESSION_ID = GV$SESSION.SID
                  LEFT JOIN GV$SESSION X ON GV$SESSION.BLOCKING_SESSION = X.SID AND X.schemaname != 'SYS' --AND X.STATUS = 'ACTIVE'

 WHERE GV$SESSION.USERNAME IS NOT NULL
  AND EXISTS (SELECT X.BLOCKING_SESSION FROM GV$SESSION X WHERE DECODE(X.BLOCKING_SESSION, NULL, NULL, 'SID ' || X.BLOCKING_SESSION)  IS NOT NULL AND X.BLOCKING_SESSION = GV$SESSION.SID)

ORDER  BY DURACAO DESC);
