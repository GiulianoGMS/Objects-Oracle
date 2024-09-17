ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

CREATE OR REPLACE VIEW CONSINCO.NAGV_70_HIBRIDA AS

-- Criado por Giuliano em 05/08/2024
-- Ticket 430626
-- Replica da base 70 - GMD

SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/
       TO_CHAR(K.DTAENTRADA, 'YYYY') ANO, TO_CHAR(K.DTAENTRADA, 'MM') MES,
       K.DTAENTRADA DTA_ENTRADA, K.NROEMPRESA LOJA, K.CGO CGO,
       (SELECT Y.DESCRICAO FROM CONSINCO.GE_CGO Y WHERE Y.CGO = K.CGO) OPERACAO,
       K.CODHISTORICO NATDESPESA,
       (SELECT ZZ.DESCRICAO
           FROM CONSINCO.ABA_HISTORICO ZZ
          WHERE ZZ.SEQHISTORICO = K.CODHISTORICO) DESCRICAONATDESPESA,
       L.CENTROCUSTODB CENTRO_RESULTADO,
       (SELECT X.DESCRICAO
           FROM CONSINCO.ABA_CENTRORESULTADO X
          WHERE LPAD(X.CODREDUZIDO, 8, 0) = LPAD(L.CENTROCUSTODB, 8, 0)) CENTRODESCRICAO,
       KK.CODPRODUTO CODIGOPRODUTO, J.DESCCOMPLETA PRODUTO, KK.UNIDADE EMBALAGEM, SUM(KK.QUANTIDADE) QUANTIDADE,
       SUM(KK.VLRITEM) VLRENTRADA,
       CASE
         WHEN K.SEQPESSOA IN (1519227,
                              1061300,
                              128452,
                              115770,
                              1692742,
                              1693609,
                              1602925,
                              1698985,
                              1887281,
                              2036551) THEN
          K.SEQPESSOA * 1234
         ELSE
          K.SEQPESSOA
       END CODFORNECEDOR,
       CASE
         WHEN K.SEQPESSOA IN (1519227,
                              1061300,
                              128452,
                              115770,
                              1692742,
                              1693609,
                              1602925,
                              1698985,
                              1887281,
                              2036551) THEN
          'PAGAMENTO PJ MATRIZ'
         ELSE
          (SELECT J.NOMERAZAO
             FROM CONSINCO.GE_PESSOA J
            WHERE J.SEQPESSOA = K.SEQPESSOA)
       END DESCRICAOFORNECEDOR,
       (SELECT G.USUAUTORIZACAO
           FROM CONSINCO.OR_REQUISICAO G
          WHERE G.SEQREQUISICAO IN
                ((SELECT Z.SEQREQUISICAO
                   FROM CONSINCO.OR_NFDESPESAREQ Z
                  WHERE Z.SEQNOTA = K.SEQNOTA))) AUTORIZADOR, K.NRONOTA NOTA,
       (SELECT G.NROREQUISICAO
           FROM CONSINCO.OR_REQUISICAO G
          WHERE G.SEQREQUISICAO IN
                ((SELECT Z.SEQREQUISICAO
                   FROM CONSINCO.OR_NFDESPESAREQ Z
                  WHERE Z.SEQNOTA = K.SEQNOTA))) REQUISICAO,
       REPLACE(REPLACE(REPLACE(REPLACE(K.OBSERVACAO, CHR(10), ' '),
                                CHR(13),
                                ' '),
                        '"',
                        ''),
                '~',
                '') OBS_NOTA,
       (SELECT REPLACE(REPLACE(REPLACE(REPLACE(G.OBSERVACAO, CHR(10), ' '),
                                         CHR(13),
                                         ' '),
                                 '"',
                                 ''),
                         '~',
                         '')
           FROM CONSINCO.OR_REQUISICAO G
          WHERE G.SEQREQUISICAO IN
                ((SELECT Z.SEQREQUISICAO
                   FROM CONSINCO.OR_NFDESPESAREQ Z
                  WHERE Z.SEQNOTA = K.SEQNOTA))) OBS_REQUISICAO,
       (SELECT H.NOME
           FROM CONSINCO.GE_USUARIO H
          WHERE H.CODUSUARIO IN
                ((SELECT G.USUAUTORIZACAO
                   FROM CONSINCO.OR_REQUISICAO G
                  WHERE G.SEQREQUISICAO IN
                        ((SELECT Z.SEQREQUISICAO
                           FROM CONSINCO.OR_NFDESPESAREQ Z
                          WHERE Z.SEQNOTA = K.SEQNOTA))))) AUTORIZADORNOME,
       SUM(KK.VLRITEM) VLRITEM,
       SUM(NVL(KK.VLRICMS, 0) + NVL(KK.VLRIPI, 0)) VLRIMPOSTOS,
       (SELECT U.COMPRADOR
           FROM CONSINCO.MAX_COMPRADOR U
          WHERE U.SEQCOMPRADOR IN
                ((SELECT G.SEQCOMPRADOR
                   FROM CONSINCO.OR_REQUISICAO G
                  WHERE G.SEQREQUISICAO IN
                        ((SELECT Z.SEQREQUISICAO
                           FROM CONSINCO.OR_NFDESPESAREQ Z
                          WHERE Z.SEQNOTA = K.SEQNOTA))))) COMPRADOR,

       L.CONTADEBITO CONTA,
       (SELECT X.DESCRICAO
           FROM CONSINCO.ABA_PLANOCONTA X
          INNER JOIN CONSINCO.ABA_PLANOCONTAEMPRESA Y
             ON (X.SEQPLANOCONTA = Y.SEQPLANOCONTA)
          WHERE X.CONTA = L.CONTADEBITO
            AND Y.NROEMPRESA = K.NROEMPRESA) CONTADESCRICAO

  FROM CONSINCO.OR_NFDESPESA K
 INNER JOIN CONSINCO.OR_NFITENSDESPESA KK
    ON (K.SEQNOTA = KK.SEQNOTA)
  LEFT JOIN CONSINCO.OR_NFPLANILHALANCTO L
    ON (L.SEQNOTA = K.SEQNOTA)
 INNER JOIN CONSINCO.MAP_PRODUTO J
    ON (J.SEQPRODUTO = KK.CODPRODUTO)

   AND K.SITUACAO = 'I'
   AND L.TIPOCONTAB = 'D'
   AND L.VLRLANCAMENTO <> 0
   --AND K.CODHISTORICO IN (844)
   --AND L.CENTROCUSTODB IN (40401,41101,80601,100201,424010)
   AND (L.CENTROCUSTODB = 80601  AND K.CODHISTORICO IN (571,4927)
     OR L.CENTROCUSTODB = 424010 AND K.CODHISTORICO IN (571,1365)
     OR L.CENTROCUSTODB = 100201 AND K.CODHISTORICO IN (571)
     OR L.CENTROCUSTODB = 40401  AND K.CODHISTORICO IN (571,1365)
     OR L.CENTROCUSTODB = 41101  AND K.CODHISTORICO IN (571))
   
 GROUP BY TO_CHAR(K.DTAENTRADA, 'YYYY'), TO_CHAR(K.DTAENTRADA, 'MM'),
          K.NROEMPRESA, J.SEQFAMILIA, K.NRONOTA, K.CODHISTORICO,
          L.CENTROCUSTODB, KK.CODPRODUTO, K.CGO, K.SEQPESSOA, K.OBSERVACAO,
          J.DESCCOMPLETA, K.DTAENTRADA, KK.UNIDADE, K.SEQNOTA, L.CONTADEBITO

UNION ALL

SELECT TO_CHAR(K.DTAENTRADA, 'YYYY'), TO_CHAR(K.DTAENTRADA, 'MM'),
       K.DTAENTRADA, K.NROEMPRESA LOJA, K.CGO CGO,
       (SELECT Y.DESCRICAO FROM CONSINCO.GE_CGO Y WHERE Y.CGO = K.CGO) OPERACAO,
       K.CODHISTORICO,
       (SELECT ZZ.DESCRICAO
           FROM CONSINCO.ABA_HISTORICO ZZ
          WHERE ZZ.SEQHISTORICO = K.CODHISTORICO),
       L.CENTROCUSTODB CENTRO_RESULTADO,
       (SELECT X.DESCRICAO
           FROM CONSINCO.ABA_CENTRORESULTADO X
          WHERE LPAD(X.CODREDUZIDO, 8, 0) = LPAD(L.CENTROCUSTODB, 8, 0)),
       NULL, NULL, NULL, 0 QTD, SUM(K.VALOR) VLRENTRADA,
       CASE
          WHEN K.SEQPESSOA IN (1519227,
                               1061300,
                               128452,
                               115770,
                               1692742,
                               1693609,
                               1602925,
                               1698985,
                               1887281,
                               2036551) THEN
           K.SEQPESSOA * 1234
          ELSE
           K.SEQPESSOA
        END CODFORNECEDOR,
       CASE
         WHEN K.SEQPESSOA IN (1519227,
                              1061300,
                              128452,
                              115770,
                              1692742,
                              1693609,
                              1602925,
                              1698985,
                              1887281,
                              2036551) THEN
          'PAGAMENTO PJ MATRIZ'
         ELSE
          (SELECT J.NOMERAZAO
             FROM CONSINCO.GE_PESSOA J
            WHERE J.SEQPESSOA = K.SEQPESSOA)
       END,
       (SELECT G.USUAUTORIZACAO
           FROM CONSINCO.OR_REQUISICAO G
          WHERE G.SEQREQUISICAO IN
                ((SELECT Z.SEQREQUISICAO
                   FROM CONSINCO.OR_NFDESPESAREQ Z
                  WHERE Z.SEQNOTA = K.SEQNOTA))) AUTORIZADOR, K.NRONOTA NOTA,
       (SELECT G.NROREQUISICAO
           FROM CONSINCO.OR_REQUISICAO G
          WHERE G.SEQREQUISICAO IN
                ((SELECT Z.SEQREQUISICAO
                   FROM CONSINCO.OR_NFDESPESAREQ Z
                  WHERE Z.SEQNOTA = K.SEQNOTA))) NROREQUISICAO,
       REPLACE(REPLACE(REPLACE(REPLACE(K.OBSERVACAO, CHR(10), ' '),
                                CHR(13),
                                ' '),
                        '"',
                        ''),
                '~',
                '') OBSERVACAO,
       (SELECT REPLACE(REPLACE(REPLACE(REPLACE(G.OBSERVACAO, CHR(10), ' '),
                                         CHR(13),
                                         ' '),
                                 '"',
                                 ''),
                         '~',
                         '')
           FROM CONSINCO.OR_REQUISICAO G
          WHERE G.SEQREQUISICAO IN
                ((SELECT Z.SEQREQUISICAO
                   FROM CONSINCO.OR_NFDESPESAREQ Z
                  WHERE Z.SEQNOTA = K.SEQNOTA))) OBS_REQUISICAO,
       (SELECT H.NOME
           FROM CONSINCO.GE_USUARIO H
          WHERE H.CODUSUARIO IN
                ((SELECT G.USUAUTORIZACAO
                   FROM CONSINCO.OR_REQUISICAO G
                  WHERE G.SEQREQUISICAO IN
                        ((SELECT Z.SEQREQUISICAO
                           FROM CONSINCO.OR_NFDESPESAREQ Z
                          WHERE Z.SEQNOTA = K.SEQNOTA))))) AUTORIZADORNOME,
       SUM(K.VALOR) VLR_ITEM,
       SUM(NVL(K.VLRICMS, 0) + NVL(K.VLRINSS, 0)) VLRIMPOSTOS,

       (SELECT U.COMPRADOR
           FROM CONSINCO.MAX_COMPRADOR U
          WHERE U.SEQCOMPRADOR IN
                ((SELECT G.SEQCOMPRADOR
                   FROM CONSINCO.OR_REQUISICAO G
                  WHERE G.SEQREQUISICAO IN
                        ((SELECT Z.SEQREQUISICAO
                           FROM CONSINCO.OR_NFDESPESAREQ Z
                          WHERE Z.SEQNOTA = K.SEQNOTA))))) COMPRADOR,

       L.CONTADEBITO CONTA,
       (SELECT X.DESCRICAO
           FROM CONSINCO.ABA_PLANOCONTA X
          INNER JOIN CONSINCO.ABA_PLANOCONTAEMPRESA Y
             ON (X.SEQPLANOCONTA = Y.SEQPLANOCONTA)
          WHERE X.CONTA = L.CONTADEBITO
            AND Y.NROEMPRESA = K.NROEMPRESA) CONTADESCRICAO
  FROM CONSINCO.OR_NFDESPESA K
  LEFT JOIN CONSINCO.OR_NFPLANILHALANCTO L
    ON (L.SEQNOTA = K.SEQNOTA)

 WHERE 1=1
   AND NOT EXISTS (SELECT *
          FROM CONSINCO.OR_NFITENSDESPESA P
         WHERE P.SEQNOTA = K.SEQNOTA)
   --AND K.CODHISTORICO IN (844)
   --AND L.CENTROCUSTODB IN (40401,41101,80601,100201,424010)
   AND (L.CENTROCUSTODB = 80601  AND K.CODHISTORICO IN (571,4927)
     OR L.CENTROCUSTODB = 424010 AND K.CODHISTORICO IN (571,1365)
     OR L.CENTROCUSTODB = 100201 AND K.CODHISTORICO IN (571)
     OR L.CENTROCUSTODB = 40401  AND K.CODHISTORICO IN (571,1365)
     OR L.CENTROCUSTODB = 41101  AND K.CODHISTORICO IN (571))
    
   AND K.SITUACAO = 'I'
   AND L.TIPOCONTAB = 'D'
   AND L.VLRLANCAMENTO <> 0
 GROUP BY TO_CHAR(K.DTAENTRADA, 'YYYY'), TO_CHAR(K.DTAENTRADA, 'MM'),
          K.NROEMPRESA, K.NRONOTA, K.CODHISTORICO, L.CENTROCUSTODB, K.CGO,
          K.SEQPESSOA, K.OBSERVACAO, K.DTAENTRADA, K.SEQNOTA, L.CONTADEBITO
-- ORDER BY 1, 2, 3, 4, 9
;

