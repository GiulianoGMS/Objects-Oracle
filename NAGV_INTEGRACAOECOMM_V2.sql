CREATE OR REPLACE VIEW CONSINCO.NAGV_INTEGRACAOECOMM_V2 AS
(

SELECT  /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4') */
            X.NROEMPRESA AS ID_LOJA,
            --NVL(CONSINCO.FBUSCAEANECOMMERCEMIN(X.SEQPRODUTO),LPAD(X.SEQPRODUTO,6,'0')) AS CODIGO_BARRA,
            NVL(C.CODACESSO, LPAD(X.SEQPRODUTO,6,0)) CODIGO_BARRA,
            INITCAP(Y.NOMEPRODUTO) AS NOME,
            ROUND(ROUND(NVL(X.PRECOVALIDNORMAL, X.PRECOGERNORMAL) / X.QTDEMBALAGEM * X.QTDEMBALAGEM, 2),2) VLR_PRODUTO,
            ROUND(ROUND(NVL(X.PRECOVALIDPROMOC, X.PRECOGERPROMOC) / X.QTDEMBALAGEM * X.QTDEMBALAGEM, 2),2) VLR_PROMOCAO,
            --ROUND(NVL(W.PRECOPPROMOCIONAL,0),2)  PRECO_DOIS,
            NVL(CONSINCO.NAGF_PRECOMN(NVL(C.CODACESSO,LPAD(X.SEQPRODUTO,14,0)), X.NROEMPRESA),0) PRECO_DOIS,
            Y.SEQPRODUTO AS PLU, S.SEGMENTO

FROM CONSINCO.MRL_PRODEMPSEG X INNER JOIN CONSINCO.MADV_PRODUTO_ECM      Y ON X.SEQPRODUTO = Y.SEQPRODUTO
                                LEFT JOIN CONSINCO.MAP_PRODCODIGO        C ON C.SEQPRODUTO = X.SEQPRODUTO AND C.TIPCODIGO = 'E' -- Só Tipo EAN
                               /* LEFT JOIN REMARCAPROMOCOES@INFOPROCMSSQL W ON W.CODLOJA = X.NROEMPRESA
                                                                          AND LPAD(C.CODACESSO,14,0) =  W.CODIGOPRODUTO
                                                                          AND SYSDATE BETWEEN DTHRINICIO AND DTHRFIM*/
                               INNER JOIN CONSINCO.MON_EMPRESASEGMENTO  ES ON ES.nroempresa = X.NROEMPRESA AND X.NROSEGMENTO = ES.nrosegmento
                               INNER JOIN CONSINCO.MON_SEGMENTO          S ON S.nrosegmento = X.NROSEGMENTO
WHERE 1=1
  AND X.STATUSVENDA != 'I'
  AND X.QTDEMBALAGEM = 1
  AND ES.ATIVO = 'S'

)
;
