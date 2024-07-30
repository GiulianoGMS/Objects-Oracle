CREATE OR REPLACE FUNCTION CONSINCO.NAGF_BUSCAULTALTPRECO (psSeqproduto  IN NUMBER,
                                                           psNroEmpresa  IN NUMBER,
                                                           psNroSegmento IN NUMBER,
                                                           psQtdEmbalagem IN NUMBER)

      RETURN DATE AS
      vsData DATE;
      
      BEGIN
        SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4')*/
           MAX(X.DTAHORALTERACAO)
          INTO vsData
          FROM MAD_PRODLOGPRECO X
         WHERE X.SEQPRODUTO = psSeqproduto
           AND X.NROEMPRESA = psNroEmpresa
           AND X.NROSEGMENTO = psNroSegmento
           AND X.QTDEMBALAGEM = psQtdEMbalagem
           -- Corta pra nao buscar muita coisa
           AND X.DTAHORALTERACAO >= SYSDATE - 3;
           
           IF vsData IS NULL 
             THEN
              vsData :=  DATE '1990-01-01';
           END IF;
           
           RETURN vsData;
END;

       
