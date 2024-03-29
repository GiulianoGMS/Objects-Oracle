CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_APAGA_DOCTOPAGTO (ps IN VARCHAR2) AS

-- Criado por Giuliano | 21/03/24
-- Solic Vinicius Automacao

BEGIN
       
  DECLARE
  i INTEGER := 0;

  BEGIN
  
  FOR t IN (SELECT * FROM CONSINCO.PDV_DOCTO Y WHERE Y.DTAMOVIMENTO >= TRUNC(SYSDATE)-5)
  
   LOOP
  BEGIN
    
  i := i+1;
  
  DELETE FROM CONSINCO.PDV_DOCTOPAGTO X
        WHERE X.SEQDOCTO = T.SEQDOCTO
          AND X.TIPOPAGTO = 'CB'
          AND X.TIPOEVENTO IN ('R','P')
          AND X.NROFORMAPAGTO = '7'
          AND X.BINCARTAO  IN ('608831','637526','637795', '000000','000001','000002', '000003','000004', '000005','000006','000007', '000008','000009');
          
  IF i  = 10 THEN COMMIT;
     i := 0;
  END IF;
  COMMIT;
  
  END;
  
   END LOOP;
  COMMIT;
  
  END;
  
END;
