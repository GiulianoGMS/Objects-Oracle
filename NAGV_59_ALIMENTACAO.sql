ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

CREATE OR REPLACE VIEW CONSINCO.NAGV_59_ALIMENTACAO AS

-- Criado por Giuliano em 05/08/2024
-- Ticket 430626
-- Replica da base 59 - GMD - Apenas Desp 844

SELECT TO_CHAR(K.DTAENTRADA, 'YYYY') ANO, TO_CHAR(K.DTAENTRADA, 'MM') MES,
       K.DTAENTRADA DTA_ENTRADA, K.NROEMPRESA LOJA, K.CGO,
       (SELECT Y.DESCRICAO FROM CONSINCO.GE_CGO Y WHERE Y.CGO = K.CGO) OPERACAO,
       K.CODHISTORICO NATDESPESA, 
       (SELECT ZZ.DESCRICAO
           FROM CONSINCO.ABA_HISTORICO ZZ
          WHERE ZZ.SEQHISTORICO = K.CODHISTORICO) DESCRICAONATDESPESA, KK.CODPRODUTO CODIGOPRODUTO,
       J.DESCCOMPLETA PRODUTO, KK.UNIDADE EMBALAGEM, SUM(KK.QUANTIDADE) QUANTIDADE, SUM(KK.VLRITEM) VLRENTRADA,
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
        END COD_FORNECEDOR,
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
       END DESCFORNECEDOR,
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
                '') OBSNOTA,
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
                  WHERE Z.SEQNOTA = K.SEQNOTA))) OBSREQUISICAO,
       
       (SELECT H.NOME
           FROM CONSINCO.GE_USUARIO H
          WHERE H.CODUSUARIO IN
                ((SELECT G.USUAUTORIZACAO
                   FROM CONSINCO.OR_REQUISICAO G
                  WHERE G.SEQREQUISICAO IN
                        ((SELECT Z.SEQREQUISICAO
                           FROM CONSINCO.OR_NFDESPESAREQ Z
                          WHERE Z.SEQNOTA = K.SEQNOTA))))) AUTORIZADORNOME,
       SUM(KK.VLRITEM) VLRITEM, SUM(NVL(KK.VLRICMS, 0) + NVL(KK.VLRIPI, 0)) VLRIMPOSTOS,
       (SELECT U.COMPRADOR
           FROM CONSINCO.MAX_COMPRADOR U
          WHERE U.SEQCOMPRADOR IN
                ((SELECT G.SEQCOMPRADOR
                   FROM CONSINCO.OR_REQUISICAO G
                  WHERE G.SEQREQUISICAO IN
                        ((SELECT Z.SEQREQUISICAO
                           FROM CONSINCO.OR_NFDESPESAREQ Z
                          WHERE Z.SEQNOTA = K.SEQNOTA))))) COMPRADOR,
       
       (SELECT DECODE(W.FINALIDADEFAMILIA,
                        'P',
                        'Matéria-Prima',
                        'B',
                        'Brinde',
                        'U',
                        'Material de Uso e Consumo',
                        'A',
                        'Ativo Imobilizado',
                        'S',
                        'Serviços',
                        'G',
                        'Seguro',
                        'F',
                        'Frete',
                        'D',
                        'Despesas',
                        'V',
                        'Aproveitamento',
                        'L',
                        'Vale/Recibo',
                        'E',
                        'Embalagem',
                        'C',
                        'Produto em Processo',
                        'Q',
                        'Produto Acabado',
                        'T',
                        'Subproduto',
                        'I',
                        'Produto Intermediário',
                        'O',
                        'Outros insumos',
                        'J',
                        'Adjudicação Cred ICMS',
                        'N',
                        'Rest Cred Trib',
                        'M',
                        'Complemento Antecipado',
                        'X',
                        'Garantia Estendida',
                        'Z',
                        'Vale Recibo',
                        'R',
                        'Mercadoria para Revenda',
                        'H',
                        'Complemento de Imposto',
                        ' ',
                        'Mercadoria para Revenda')
           FROM CONSINCO.MAP_FAMDIVISAO W
          WHERE W.SEQFAMILIA = J.SEQFAMILIA) FINALIDADE

  FROM CONSINCO.OR_NFDESPESA K
 INNER JOIN CONSINCO.OR_NFITENSDESPESA KK
    ON (K.SEQNOTA = KK.SEQNOTA)
 INNER JOIN CONSINCO.MAP_PRODUTO J
    ON (J.SEQPRODUTO = KK.CODPRODUTO)
      
   AND K.SITUACAO = 'I'
   AND K.CODHISTORICO  IN (844)
 GROUP BY TO_CHAR(K.DTAENTRADA, 'YYYY'), TO_CHAR(K.DTAENTRADA, 'MM'),
          K.NROEMPRESA, J.SEQFAMILIA, K.NRONOTA, K.CODHISTORICO,
          KK.CODPRODUTO, K.CGO, K.SEQPESSOA, K.OBSERVACAO, J.DESCCOMPLETA,
          K.DTAENTRADA, KK.UNIDADE, K.SEQNOTA
