CREATE OR REPLACE PROCEDURE NAGP_PRECODIA (dtaINI DATE, dtaFIM DATE) AS

    i INTEGER := 0;
BEGIN
  FOR emp IN (SELECT NROEMPRESA FROM MAX_EMPRESA X WHERE NROEMPRESA BETWEEN 1 AND 100)
    LOOP
      FOR dia IN (SELECT DTA DIA FROM DIM_TEMPO X WHERE DTA BETWEEN dtaINI AND dtaFIM)
        LOOP
          FOR insr IN (SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4')*/
                                X.DTAESTOQUE DTA,
                                X.NROEMPRESA LOJA, SEQPRODUTO SKU, 
                                NAGF_PRECO_DIA_X_TIPO(X.NROEMPRESA, X.SEQPRODUTO, E.NROSEGMENTOPRINC, 1, X.DTAESTOQUE, 'N') PRECO_DE,
                                NAGF_PRECO_DIA_X_TIPO(X.NROEMPRESA, X.SEQPRODUTO, E.NROSEGMENTOPRINC, 1, X.DTAESTOQUE, 'P') PRECO_PARA
                              
                           FROM FATO_ESTOQUE X INNER JOIN MAX_EMPRESA E ON E.NROEMPRESA = X.NROEMPRESA
                          WHERE X.NROEMPRESA = emp.NROEMPRESA
                            AND DTAESTOQUE = dia.DIA
                            AND NAGF_PRECO_DIA_X_TIPO(X.NROEMPRESA, X.SEQPRODUTO, E.NROSEGMENTOPRINC, 1, X.DTAESTOQUE, 'P') > 0
                            
                            AND NOT EXISTS (SELECT 1 FROM NAGT_BASE_PRECODIA@CONSINCODW Z WHERE Z.DTA = X.DTAESTOQUE AND Z.LOJA = X.NROEMPRESA AND Z.SKU = X.SEQPRODUTO))
            LOOP
               i := i + 1;
              INSERT INTO NAGT_BASE_PRECODIA@CONSINCODW VALUES (insr.DTA, insr.LOJA, insr.SKU, insr.PRECO_DE, insr.PRECO_PARA);
            IF i = 500 THEN -- Define o Commit por quantidade de linhas
              COMMIT;
               i := 0;
            END IF;
            
            END LOOP;
            COMMIT;
         
         END LOOP;
         COMMIT;
         
       END LOOP;
     COMMIT;
     
   END;
