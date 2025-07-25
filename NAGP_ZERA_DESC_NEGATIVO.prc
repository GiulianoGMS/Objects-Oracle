CREATE OR REPLACE PROCEDURE NAGP_ZERA_DESC_NEGATIVO (psSeqProduto IN NUMBER) AS

-- Tabelas
/*
CREATE TABLE NAGT_BKP_MRL_PRODUTOEMPRESA_CMDF_NEG AS
SELECT X.NROEMPRESA, X.SEQPRODUTO, X.CMULTDCTOFORANF, SYSDATE DATA_PROCESS
  FROM MRL_PRODUTOEMPRESA X WHERE CMULTDCTOFORANF < 0 AND SEQPRODUTO = 259978 AND NROEMPRESA = 1;
TRUNCATE TABLE NAGT_BKP_MRL_PRODUTOEMPRESA_CMDF_NEG;

CREATE TABLE NAGT_BKP_MRL_CUSTODIA_CMDF_NEG AS
SELECT C.DTAENTRADASAIDA, NROEMPRESA, SEQPRODUTO, CENTRDCTOFORANF, CMDIADCTOFORANF, SYSDATE DATA_PROCESS
  FROM MRL_CUSTODIA C       WHERE C.NROEMPRESA = 1 AND SEQPRODUTO = 259978;
TRUNCATE TABLE NAGT_BKP_MRL_CUSTODIA_CMDF_NEG;

CREATE TABLE NAGT_BKP_MRL_CUSTODIAFAM_CMDF_NEG AS
SELECT F.DTAENTRADASAIDA, NROEMPRESA, SEQFAMILIA, CENTRDCTOFORANF, CMDIADCTOFORANF, SYSDATE DATA_PROCESS
  FROM MRL_CUSTODIAFAM F    WHERE SEQFAMILIA = 108691 AND NROEMPRESA = 1; 
TRUNCATE TABLE NAGT_BKP_MRL_CUSTODIAFAM_CMDF_NEG;
*/

BEGIN
  FOR emp IN (SELECT NROEMPRESA FROM MAX_EMPRESA WHERE NROEMPRESA < 100)
    LOOP
     FOR prodemp IN (SELECT X.NROEMPRESA, X.SEQPRODUTO, X.CMULTDCTOFORANF, P.SEQFAMILIA
                       FROM MRL_PRODUTOEMPRESA X INNER JOIN MAP_PRODUTO P ON P.SEQPRODUTO = X.SEQPRODUTO
                      WHERE CMULTDCTOFORANF < 0
                        AND X.SEQPRODUTO = psSeqProduto 
                        AND X.NROEMPRESA = emp.NROEMPRESA)
                     
     LOOP -- Produto Empresa
       INSERT INTO NAGT_BKP_MRL_PRODUTOEMPRESA_CMDF_NEG VALUES (prodemp.NROEMPRESA, prodemp.SEQPRODUTO, prodemp.CMULTDCTOFORANF, SYSDATE);
       UPDATE MRL_PRODUTOEMPRESA X SET X.CMULTDCTOFORANF = 0
                                 WHERE X.SEQPRODUTO      = prodemp.SEQPRODUTO
                                   AND X.NROEMPRESA      = prodemp.NROEMPRESA
                                   AND X.CMULTDCTOFORANF < 0;       
     FOR ctodia IN (SELECT C.DTAENTRADASAIDA, NROEMPRESA, SEQPRODUTO, CENTRDCTOFORANF, C.CMDIADCTOFORANF
                      FROM MRL_CUSTODIA C
                     WHERE C.NROEMPRESA = prodemp.NROEMPRESA
                       AND C.SEQPRODUTO = prodemp.SEQPRODUTO
                       AND C.CMDIADCTOFORANF < 0)
                       
     LOOP -- Custo Dia Produto
       INSERT INTO NAGT_BKP_MRL_CUSTODIA_CMDF_NEG VALUES (ctodia.DTAENTRADASAIDA, ctodia.NROEMPRESA, ctodia.SEQPRODUTO, ctodia.CENTRDCTOFORANF, ctodia.CMDIADCTOFORANF, SYSDATE);
       UPDATE MRL_CUSTODIA C SET C.CENTRDCTOFORANF = 0,
                                 C.CMDIADCTOFORANF = 0
                           WHERE C.NROEMPRESA      = ctodia.NROEMPRESA
                             AND C.SEQPRODUTO      = ctodia.SEQPRODUTO
                             AND C.DTAENTRADASAIDA = ctodia.DTAENTRADASAIDA;
     END LOOP; -- Custo Dia Prod
     -- Custo Dia Familia
     FOR ctodiafam IN (SELECT F.DTAENTRADASAIDA, NROEMPRESA, SEQFAMILIA, CENTRDCTOFORANF, F.CMDIADCTOFORANF
                          FROM MRL_CUSTODIAFAM F
                         WHERE F.NROEMPRESA = prodemp.NROEMPRESA
                           AND F.SEQFAMILIA = prodemp.SEQFAMILIA
                           AND F.CMDIADCTOFORANF < 0)
                       
     LOOP -- Custo Dia Familia
       INSERT INTO NAGT_BKP_MRL_CUSTODIAFAM_CMDF_NEG VALUES (ctodiafam.DTAENTRADASAIDA, ctodiafam.NROEMPRESA, ctodiafam.SEQFAMILIA, ctodiafam.CENTRDCTOFORANF, ctodiafam.CMDIADCTOFORANF, SYSDATE);
       UPDATE MRL_CUSTODIAFAM F SET F.CENTRDCTOFORANF = 0,
                                    F.CMDIADCTOFORANF = 0
                              WHERE F.NROEMPRESA      = ctodiafam.NROEMPRESA
                                AND F.SEQFAMILIA      = ctodiafam.SEQFAMILIA
                                AND F.DTAENTRADASAIDA = ctodiafam.DTAENTRADASAIDA;
     END LOOP; -- Custo Dia Familia
     END LOOP; -- Produto Empresa   
     
    END LOOP; -- Loop Empresa
    
    COMMIT;
 
END;
