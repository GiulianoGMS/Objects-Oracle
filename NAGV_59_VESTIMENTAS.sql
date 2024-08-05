ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

CREATE OR REPLACE VIEW CONSINCO.NAGV_59_VESTIMENTAS AS

-- Criado por Giuliano em 05/08/2024
-- Ticket 430626
-- Replica da base 59 - GMD - Com produtos da depara NAGT_DEPARA_VESTRH

SELECT TO_CHAR(E2.DTAENTRADA, 'YYYY') ANO, TO_CHAR(E2.DTAENTRADA, 'MM') MES,
       E2.DTAENTRADA DTA_ENTRADA, E2.NROEMPRESA LOJA,
       E2.CODGERALOPER CGO,
       (SELECT Y.DESCRICAO
           FROM CONSINCO.GE_CGO Y
          WHERE Y.CGO = E2.CODGERALOPER) OPERACAO, NULL NATDESPESA,
       NULL DESCRICAONATDESPESA, TO_CHAR(A.SEQPRODUTO) AS CODIGOPRODUTO,
       A.DESCCOMPLETA AS PRODUTO,
       K.EMBALAGEM || ' ' || K.QTDEMBALAGEM AS EMBALAGEM,
       SUM(E2.QTDITEM / K.QTDEMBALAGEM) AS QUANTIDADE,
       SUM(E2.VLRITEM + E2.VLRIPI + E2.VLRDESPTRIBUTITEM +
            E2.VLRDESPNTRIBUTITEM + E2.VLRDESPFORANF + E2.VLRICMSST +
            E2.VLRFCPST - E2.VLRDESCITEM) AS VLRENTRADA,
       E2.SEQPESSOA CODFORNECEDOR,
       (SELECT J.NOMERAZAO
           FROM CONSINCO.GE_PESSOA J
          WHERE J.SEQPESSOA = E2.SEQPESSOA) DESCFORNECEDOR, NULL AUTORIZADOR,
       E2.NRODOCTO NOTA, NULL REQUISICAO, NULL OBSNOTA, NULL OBSREQUISICAO,
       NULL AUTORIZADORNOME, SUM(E2.VLRITEM) VLRITEM,
       SUM(E2.VLRIPI + E2.VLRDESPTRIBUTITEM + E2.VLRDESPNTRIBUTITEM +
            E2.VLRDESPFORANF + E2.VLRICMSST + E2.VLRFCPST - E2.VLRDESCITEM) AS VLRIMPOSTOS,
       NULL COMPRADOR,
       DECODE(D.FINALIDADEFAMILIA,
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
               'Mercadoria para Revenda') FINALIDADE

  FROM CONSINCO.MAXV_ABCENTRADABASE E2, CONSINCO.MAP_PRODUTO A,
       CONSINCO.MAP_FAMDIVISAO D, CONSINCO.MAD_FAMSEGMENTO H,
       CONSINCO.MAP_FAMEMBALAGEM K, CONSINCO.MAX_DIVISAO DV,
       CONSINCO.MRL_PRODUTOEMPRESA C
 WHERE D.SEQFAMILIA = A.SEQFAMILIA
   AND E2.SEQPRODUTO = A.SEQPRODUTO
   AND E2.NRODIVISAO = D.NRODIVISAO
   AND E2.NROSEGMENTOPRINC = H.NROSEGMENTO
   AND D.SEQFAMILIA = H.SEQFAMILIA
   AND K.SEQFAMILIA = A.SEQFAMILIA
   AND E2.SEQPRODUTO IN
       (SELECT ZZ.SEQPRODUTO FROM CONSINCO.NAGT_DEPARA_VESTRH ZZ)
   AND DV.NRODIVISAO = E2.NRODIVISAO
   AND K.QTDEMBALAGEM =
       NVL((SELECT MIN(NVL(X.PADRAOEMBCOMPRAFORNEC, D.PADRAOEMBCOMPRA))
             FROM CONSINCO.MAP_FAMFORNEC X
            WHERE X.SEQFAMILIA = D.SEQFAMILIA
              AND X.SEQFORNECEDOR = E2.SEQPESSOA),
           D.PADRAOEMBCOMPRA)
   AND C.SEQPRODUTO = E2.SEQPRODUTO
   AND C.NROEMPRESA = E2.NROEMPRESA
      
   AND E2.QTDITEM != 0
 GROUP BY A.SEQPRODUTO, A.DESCCOMPLETA, E2.CODGERALOPER, E2.DTAENTRADA,
          D.FINALIDADEFAMILIA, TO_CHAR(E2.DTAENTRADA, 'YYYY'), E2.SEQPESSOA,
          TO_CHAR(E2.DTAENTRADA, 'MM'), E2.NRODOCTO, E2.NROEMPRESA,
          K.EMBALAGEM, K.QTDEMBALAGEM, A.SEQFAMILIA
