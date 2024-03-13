CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_ATUALIZADTAMOVTO_ST AS
BEGIN
DECLARE
      i INTEGER := 0;
      vCount NUMBER;
      
      BEGIN
        vCount := 0;
        
      SELECT COUNT(1) 
        INTO vCount
        FROM CONSINCO.ESP_CORAL_MOVSUPERTROCO AA WHERE AA.DTAMOVIMENTO IS NULL;
        
      IF vCount > 0 
      THEN
        
        FOR t IN (SELECT Y.DTAMOVIMENTO DTADOCTO, X.* 
                    FROM CONSINCO.ESP_CORAL_MOVSUPERTROCO X INNER JOIN CONSINCO.PDV_DOCTOPAGTO Y ON X.NROLOJA = Y.NROEMPRESA 
                                                                                                AND X.NROCUPOM = Y.NRODOCUMENTO 
                                                                                                AND Y.DTAMOVIMENTO > DATE '2024-01-01'
                   WHERE X.DTAMOVIMENTO IS NULL)
          
      LOOP
        UPDATE CONSINCO.ESP_CORAL_MOVSUPERTROCO A SET A.DTAMOVIMENTO = T.DTADOCTO
                                                WHERE A.COO = T.COO
                                                  AND A.NROPDV = T.NROPDV
                                                  AND A.NROLOJA = T.NROLOJA
                                                  AND A.NROCUPOM = T.NROCUPOM
                                                  AND A.DTAMOVIMENTO IS NULL
                                                  AND A.ARQUIVO = T.ARQUIVO;
      IF i = 10 THEN COMMIT;
         i:= 0;
         
      END IF;

     END LOOP;
    COMMIT;
     END IF;
     
    END;
    END;
