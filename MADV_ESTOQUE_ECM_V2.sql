CREATE OR REPLACE VIEW CONSINCO.MADV_ESTOQUE_ECM_V2 AS
SELECT /*+optimizer_features_enable('11.2.0.4') */
       NROEMPRESA, SEQPRODUTO,
       --DECODE(SIGN(QTDESTOQUE), -1, 0, QTDESTOQUE) QTDESTOQUE,
       -- Alterado por Giuliano em 13/08/2024 para trazer estoque nos produtos que existem na de/para
       -- Quando a hora for par, retorna 10, impar retorna 5
       CASE WHEN SEQPRODUTO_BS IS NOT NULL AND QTDESTOQUE <= 0 THEN
         CASE WHEN MOD(TO_NUMBER(TO_CHAR(SYSDATE, 'HH')),2) = 0 THEN 10 ELSE 5 END
           ELSE DECODE(SIGN(QTDESTOQUE), -1, 0, QTDESTOQUE) END QTDESTOQUE,
       -----------------------------------------------------
       QTDESTOQUEMIN,
       -- Alt 06/01/2025 - Giuliano
       -- Se o Prod esta na view depara, retorna a data de ontem
       CASE WHEN SEQPRODUTO_BS IS NOT NULL THEN SYSDATE - 1 ELSE DTAHORULTMOVTOESTQ END DTAHORULTMOVTOESTQ
       -- DTAHORULTMOVTOESTQ

  FROM (SELECT B.NROEMPRESA, B.SEQPRODUTO,
                CASE
                  WHEN A.SEQPRODUTOBASE > 0 THEN
                   (SELECT CONSINCO.FESTOQUEDIASECOMMERCE(B2.NROEMPRESA,
                                                           B2.ESTQDEPOSITO,
                                                           B2.ESTQLOJA,
                                                           B2.QTDRESERVADAVDA,
                                                           B2.QTDRESERVADARECEB,
                                                           B2.QTDRESERVADAFIXA,
                                                           B2.MEDVDIAPROMOC,
                                                           B2.MEDVDIAFORAPROMOC,
                                                           B2.MEDVDIAGERAL,
                                                           B2.ESTQSEGURANCAECOMMERCE,
                                                           CONSINCO.FNROESTQDIASECOMMERCECATEG(E.NRODIVISAO,
                                                                                               A.SEQFAMILIA))
                      FROM MAP_PRODUTO A2, CONSINCO.MRL_PRODUTOEMPRESA B2
                     WHERE A2.SEQPRODUTO = B2.SEQPRODUTO
                       AND A2.SEQPRODUTO = A.SEQPRODUTOBASE
                       AND B2.NROEMPRESA = B.NROEMPRESA)
                  ELSE
                   CONSINCO.FESTOQUEDIASECOMMERCE(B.NROEMPRESA,
                                                  B.ESTQDEPOSITO,
                                                  B.ESTQLOJA,
                                                  B.QTDRESERVADAVDA,
                                                  B.QTDRESERVADARECEB,
                                                  B.QTDRESERVADAFIXA,
                                                  B.MEDVDIAPROMOC,
                                                  B.MEDVDIAFORAPROMOC,
                                                  B.MEDVDIAGERAL,
                                                  B.ESTQSEGURANCAECOMMERCE,
                                                  CONSINCO.FNROESTQDIASECOMMERCECATEG(E.NRODIVISAO,
                                                                                      A.SEQFAMILIA))
                END QTDESTOQUE, B.ESTQMINIMOLOJA QTDESTOQUEMIN,
                CASE WHEN R.SEQPRODUTO IS NOT NULL AND A.SEQPRODUTOBASE IS NOT NULL
                  THEN B2.DTAHORULTMOVTOESTQ ELSE B.DTAHORULTMOVTOESTQ END DTAHORULTMOVTOESTQ, R.SEQPRODUTO SEQPRODUTO_BS

           FROM CONSINCO.MAP_PRODUTO A INNER JOIN CONSINCO.MRL_PRODUTOEMPRESA B ON A.SEQPRODUTO = B.SEQPRODUTO
                                        LEFT JOIN CONSINCO.MRL_PRODUTOEMPRESA B2 ON A.SEQPRODUTOBASE = B2.SEQPRODUTO AND B2.NROEMPRESA = B.NROEMPRESA
                                       INNER JOIN CONSINCO.MAX_EMPRESA E ON B.NROEMPRESA = E.NROEMPRESA
                                        LEFT JOIN CONSINCO.NAGV_ECOMM_BASERELAC R ON R.SEQPRODUTO = A.SEQPRODUTO

          WHERE 1=1
            AND A.INDINTEGRAECOMMERCE = 'S')
;
