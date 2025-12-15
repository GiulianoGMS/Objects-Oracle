CREATE OR REPLACE PROCEDURE NAGP_DEL_LOG_EXT_XML (psDiasLimite NUMBER) IS
  
  i INTEGER := 0;
  
BEGIN
  FOR dl IN (SELECT * FROM NAGT_LOG_EXT_XML X WHERE X.DTA_PROCESSO < TRUNC(SYSDATE) - psDiasLimite)
    LOOP
      i := i+1;
      DELETE FROM NAGT_LOG_EXT_XML X WHERE X.CHAVENFE = dl.Chavenfe
                                       AND X.EMP = dl.Emp
                                       AND X.NROCHECKOUT = dl.Nrocheckout;
     IF i = 10 THEN COMMIT;
            i := 0;
     END IF;
    END LOOP;
END;


BEGIN
  NAGP_DEL_LOG_EXT_XML(7);
  END;
