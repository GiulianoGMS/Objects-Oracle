CREATE OR REPLACE FUNCTION CONSINCO.NAGF_PRECO_DIA_X
(
    vNroEmpresa  IN NUMBER,
    vSeqProduto  IN NUMBER,
    vNroSegmento IN NUMBER,
    vQtdEmb      IN NUMBER,
    vDta         IN DATE
) 
RETURN NUMBER IS
    vPrecoNormal NUMBER;
    vPrecoPromoc NUMBER;
    vPrecoFinal  NUMBER;
BEGIN
    BEGIN 
      -- Pego primeiro o preco promocional ate a data informada
        SELECT PRECO
        INTO vPrecoPromoc
        FROM 
        (
            SELECT P.PRECO
            FROM MAD_PRODLOGPRECO P
            INNER JOIN
            (
                SELECT SEQPRODUTO, NROEMPRESA, NROSEGMENTO, QTDEMBALAGEM, MAX(DTAHORALTERACAO) DTA_ALT
                FROM CONSINCO.MAD_PRODLOGPRECO L
                WHERE TRUNC(L.DTAHORALTERACAO) <= vDta
                  AND NROEMPRESA   = vNroempresa
                  AND SEQPRODUTO   = vSeqProduto
                  AND NROSEGMENTO  = vNroSegmento
                  AND QTDEMBALAGEM = vQtdEmb 
                  AND TIPOALTPRECO = 'P'
                GROUP BY SEQPRODUTO, NROEMPRESA, NROSEGMENTO, QTDEMBALAGEM
            ) BS1
            ON BS1.SEQPRODUTO   = P.SEQPRODUTO
           AND BS1.NROEMPRESA   = P.NROEMPRESA
           AND BS1.NROSEGMENTO  = P.NROSEGMENTO
           AND BS1.QTDEMBALAGEM = P.QTDEMBALAGEM
           AND BS1.DTA_ALT      = P.DTAHORALTERACAO
           WHERE P.NROEMPRESA   = vNroempresa
             AND P.SEQPRODUTO   = vSeqProduto
             AND P.NROSEGMENTO  = vNroSegmento
             AND P.QTDEMBALAGEM = vQtdEmb
            ORDER BY P.DTAHORALTERACAO DESC
        )
        WHERE ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            vPrecoPromoc := 0;
    END;

    BEGIN
      -- Depois pego o ultimo preco normal ate a data informada
        SELECT PRECO
        INTO vPrecoNormal
        FROM 
        (
            SELECT P2.PRECO
            FROM MAD_PRODLOGPRECO P2
            INNER JOIN
            (
                SELECT SEQPRODUTO, NROEMPRESA, NROSEGMENTO, QTDEMBALAGEM, MAX(DTAHORALTERACAO) DTA_ALT
                FROM CONSINCO.MAD_PRODLOGPRECO L2
                WHERE TRUNC(L2.DTAHORALTERACAO) <= vDta
                  AND NROEMPRESA   = vNroempresa
                  AND SEQPRODUTO   = vSeqProduto
                  AND NROSEGMENTO  = vNroSegmento
                  AND QTDEMBALAGEM = vQtdEmb 
                  AND TIPOALTPRECO = 'N'
                GROUP BY SEQPRODUTO, NROEMPRESA, NROSEGMENTO, QTDEMBALAGEM
            ) BS2
            ON BS2.SEQPRODUTO   = P2.SEQPRODUTO
           AND BS2.NROEMPRESA   = P2.NROEMPRESA
           AND BS2.NROSEGMENTO  = P2.NROSEGMENTO
           AND BS2.QTDEMBALAGEM = P2.QTDEMBALAGEM
           AND BS2.DTA_ALT      = P2.DTAHORALTERACAO
           WHERE P2.NROEMPRESA   = vNroempresa
             AND P2.SEQPRODUTO   = vSeqProduto
             AND P2.NROSEGMENTO  = vNroSegmento
             AND P2.QTDEMBALAGEM = vQtdEmb
            ORDER BY P2.DTAHORALTERACAO DESC
        )
        WHERE ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            vPrecoNormal := 0;
    END;

    -- Aqui trato o preco, pois o preco promocional saindo retorna preco = 0
    -- Entao, se precopromoc for nulo ou igual a 0, retorna o ultimo preco normal pego anteriormente
    -- NULLIF se PRECOPROMOC = 0 retorna NULO e cai no COALESCE
    vPrecoFinal := COALESCE(NULLIF(vPrecoPromoc, 0), vPrecoNormal);

    RETURN vPrecoFinal;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
