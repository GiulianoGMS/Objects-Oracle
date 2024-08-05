ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

CREATE OR REPLACE VIEW CONSINCO.NAGV_49_VESTIMENTAS AS

-- Criado por Giuliano em 05/08/2024
-- Ticket 430626
-- Replica da base 49 - GMD - Com produtos da depara NAGT_DEPARA_VESTRH

SELECT V.NROEMPRESA LOJA_ORIGEM, V.SEQPESSOA LOJA_DESTINO,
       TO_CHAR(V.DTAVDA, 'YYYY') ANO, TO_CHAR(V.DTAVDA, 'MM') MES,
       V.DTAVDA DTAVDA,
       V.CODGERALOPER CGO,
       (SELECT Z.DESCRICAO
           FROM CONSINCO.MAX_CODGERALOPER Z
          WHERE Z.CODGERALOPER = V.CODGERALOPER) CGO_DESCRICAO, V.SEQPRODUTO,
       A.DESCCOMPLETA AS PRODUTO,
       SUM(ROUND((V.QTDITEM - V.QTDDEVOLITEM) / K.QTDEMBALAGEM, 6)) AS QUANTIDADE,
       
       SUM((ROUND(V.VLRITEM, 2)) - (ROUND(V.VLRDEVOLITEM, 2) - (0))) AS VALOR

  FROM CONSINCO.MRL_CUSTODIA Y, CONSINCO.MAXV_ABCDISTRIBBASE V,
       CONSINCO.MAP_PRODUTO A, CONSINCO.MAP_PRODUTO PB,
       CONSINCO.MAP_FAMDIVISAO D, CONSINCO.MAP_FAMEMBALAGEM K,
       CONSINCO.MAX_EMPRESA E, CONSINCO.MAX_DIVISAO DV,
       CONSINCO.MAP_PRODACRESCCUSTORELAC PR
 WHERE D.SEQFAMILIA = A.SEQFAMILIA
   AND D.NRODIVISAO = V.NRODIVISAO
   AND V.SEQPRODUTO = A.SEQPRODUTO
   AND V.SEQPRODUTOCUSTO = PB.SEQPRODUTO
   AND V.NRODIVISAO = D.NRODIVISAO
   AND V.SEQPRODUTO IN (SELECT ZZ.SEQPRODUTO FROM CONSINCO.NAGT_DEPARA_VESTRH ZZ)
   AND E.NROEMPRESA = V.NROEMPRESA
   AND E.NRODIVISAO = DV.NRODIVISAO
   AND V.SEQPRODUTO = PR.SEQPRODUTO(+)
   AND V.DTAVDA = PR.DTAMOVIMENTACAO(+)
   AND Y.NROEMPRESA = NVL(E.NROEMPCUSTOABC, E.NROEMPRESA)
   AND Y.DTAENTRADASAIDA = V.DTAVDA
   AND K.SEQFAMILIA = A.SEQFAMILIA
   AND K.QTDEMBALAGEM = 1
   AND Y.SEQPRODUTO = PB.SEQPRODUTO
      
   AND V.CODGERALOPER IN (60,
                          93,
                          914,
                          64,
                          102,
                          949,
                          210,
                          57,
                          948,
                          10,
                          941,
                          1,
                          927,
                          211,
                          814,
                          802,
                          801,
                          944,
                          811,
                          850,
                          942,
                          95,
                          261,
                          931,
                          240)

 GROUP BY V.NROEMPRESA, V.SEQPESSOA, TO_CHAR(V.DTAVDA, 'YYYY'),
          TO_CHAR(V.DTAVDA, 'MM'), V.CODGERALOPER, V.SEQPRODUTO,
          A.DESCCOMPLETA, DTAVDA

 ORDER BY 1, 2, 4, 5
