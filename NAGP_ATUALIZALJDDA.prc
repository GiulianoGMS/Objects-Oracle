CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_ATUALIZALJDDA (pnEmpresa IN NUMBER) AS
  BEGIN
  DECLARE i INTEGER := 0;
  
  BEGIN
  FOR t IN (SELECT *
              FROM NAGV_DDA_EMPINVERTIDA A
             WHERE A.EMP_CERTA = pnEmpresa
               )
     LOOP
       UPDATE CONSINCO.FI_DDAARQTITULO X SET X.NROCNPJCPFSACADO = T.CGC_CERTO,
                                             X.DIGCNPJCPFSACADO = T.DIG_CERTO,
                                             X.USUALTERACAO     = 'G-C'||TO_CHAR(T.EMP_CERTA)||'E'||TO_CHAR(T.EMP_ERRADA)
                                       WHERE X.SEQIMPORTACAO    = T.SEQDDA
                                         AND X.NRODOCUMENTO     = T.DOCTO_DDA;
      IF i = 10 THEN COMMIT;
         i:= 0;
         
      END IF;

     END LOOP;
    
    COMMIT;
  END;
     
END;
