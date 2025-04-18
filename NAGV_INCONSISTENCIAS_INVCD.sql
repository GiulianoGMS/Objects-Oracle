CREATE OR REPLACE VIEW CONSINCO.NAGV_INCONSISTENCIAS_INVCD AS
SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4')*/ MLOV_PRODEMPESTQLOCAL.SEQPRODUTO, ( 0 - MLOV_PRODEMPESTQLOCAL.ESTQ ) / MLO_PRODUTO.PADRAOEMBVENDA DIVERGENCIA,
       MLOV_PRODEMPESTQLOCAL.NROEMPRESA NROEMPRESA


FROM CONSINCO.MLOV_PRODEMPESTQLOCAL, CONSINCO.MLO_PRODUTO,
     CONSINCO.MLO_DEPOSITANTE, CONSINCO.MLO_PRODEMBALAGEM, CONSINCO.MRL_LOCAL

WHERE MLOV_PRODEMPESTQLOCAL.NROEMPRESA  = MLO_PRODUTO.NROEMPRESA
  AND MLOV_PRODEMPESTQLOCAL.SEQPRODUTO  = MLO_PRODUTO.SEQPRODUTO
  AND MLO_DEPOSITANTE.CODDEPOSITANTE  = MLO_PRODUTO.NROEMPRESA
  AND MLO_PRODEMBALAGEM.SEQPRODUTO  = MLO_PRODUTO.SEQPRODUTO
  AND MLO_PRODEMBALAGEM.QTDEMBALAGEM  = MLO_PRODUTO.PADRAOEMBVENDA
  AND MLO_PRODEMBALAGEM.NROEMPRESA  = MLO_PRODUTO.NROEMPRESA
  AND MLOV_PRODEMPESTQLOCAL.SEQLOCAL  = MRL_LOCAL.SEQLOCAL
  AND MLOV_PRODEMPESTQLOCAL.NROEMPRESA  = MRL_LOCAL.NROEMPRESA
  --AND MLOV_PRODEMPESTQLOCAL.ESTQ    != 0
  AND MRL_LOCAL.STATUS      = 'A'

AND EXISTS(
  SELECT  1
  FROM  MLO_TIPESPECIE
  WHERE MRL_LOCAL.SEQLOCAL    = MLO_TIPESPECIE.SEQLOCAL
  AND MRL_LOCAL.NROEMPRESA    = MLO_TIPESPECIE.NROEMPRESA
  )
AND NOT EXISTS(
  SELECT  1
  FROM  MLO_ENDERECO AX,
    MLO_TIPESPECIE BX
  WHERE AX.NROEMPRESA     = MLOV_PRODEMPESTQLOCAL.NROEMPRESA
  AND AX.SEQPRODUTO     = MLOV_PRODEMPESTQLOCAL.SEQPRODUTO
  AND MRL_LOCAL.SEQLOCAL    = BX.SEQLOCAL
  AND MRL_LOCAL.NROEMPRESA    = BX.NROEMPRESA
  AND BX.TIPESPECIE     = AX.TIPESPECIE
  AND BX.NROEMPRESA     = AX.NROEMPRESA
  )
  AND MLOV_PRODEMPESTQLOCAL.NROEMPRESA  > 500
  AND MRL_LOCAL.LOCAL LIKE '%DEPOSITO%'

UNION

SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4')*/
 MLO_PRODUTO.SEQPRODUTO,
 (SUM(MLOV_PRODESTOQUE.QTDATUAL) -
 DECODE(MRL_LOCAL.TIPLOCAL,
         'T',
         MLOV_PRODEMPESTOQUE.ESTQTROCA,
         'O',
         MLOV_PRODEMPESTOQUE.ESTQOUTRO,
         MLOV_PRODEMPESTOQUE.ESTQFISICO)) / MLO_PRODUTO.PADRAOEMBVENDA DIVERGENCIA,
 MLOV_PRODEMPESTOQUE.NROEMPRESA NROEMPRESA

  FROM MLOV_PRODEMPESTOQUE,
       MLOV_PRODESTOQUE,
       MLO_PRODUTO,
       MRL_LOCAL,
       MLO_DEPOSITANTE

 WHERE MLOV_PRODEMPESTOQUE.SEQPRODUTO = MLOV_PRODESTOQUE.SEQPRODUTO
       AND MLOV_PRODEMPESTOQUE.NROEMPRESA = MLOV_PRODESTOQUE.CODDEPOSITANTE
       AND MLOV_PRODEMPESTOQUE.SEQPRODUTO = MLO_PRODUTO.SEQPRODUTO
       AND MLOV_PRODEMPESTOQUE.NROEMPRESA = MLO_PRODUTO.NROEMPRESA
       AND MLOV_PRODESTOQUE.SEQLOCAL = MRL_LOCAL.SEQLOCAL
       AND MLOV_PRODESTOQUE.CODDEPOSITANTE = MRL_LOCAL.NROEMPRESA
       AND MLOV_PRODESTOQUE.CODDEPOSITANTE = MLO_DEPOSITANTE.CODDEPOSITANTE
       AND MLOV_PRODESTOQUE.NROEMPRESA = MLO_PRODUTO.NROEMPRESA
       AND MRL_LOCAL.LOCAL LIKE '%DEPOSITO%'
       AND 2=2 
       AND MLO_PRODUTO.NROEMPRESA > 500
       AND MLOV_PRODESTOQUE.QTDATUAL >= 0

 GROUP BY MLO_PRODUTO.PADRAOEMBVENDA,
          MLOV_PRODESTOQUE.SEQLOCAL,
          MLOV_PRODEMPESTOQUE.NROEMPRESA,
          MLOV_PRODESTOQUE.CODDEPOSITANTE,
          MLO_PRODUTO.SEQPRODUTO,
          MLO_PRODUTO.DESCCOMPLETA,
          MRL_LOCAL.LOCAL,
          MRL_LOCAL.TIPLOCAL,
          MLOV_PRODESTOQUE.NROEMPRESA,
          MLO_DEPOSITANTE.NOMEREDUZIDO,
          DECODE(MRL_LOCAL.TIPLOCAL,
                 'T',
                 MLOV_PRODEMPESTOQUE.ESTQTROCA,
                 'O',
                 MLOV_PRODEMPESTOQUE.ESTQOUTRO,
                 MLOV_PRODEMPESTOQUE.ESTQFISICO)
HAVING SUM(MLOV_PRODESTOQUE.QTDATUAL) != DECODE(MRL_LOCAL.TIPLOCAL, 'T', MLOV_PRODEMPESTOQUE.ESTQTROCA, 'O', MLOV_PRODEMPESTOQUE.ESTQOUTRO, MLOV_PRODEMPESTOQUE.ESTQFISICO)
;
