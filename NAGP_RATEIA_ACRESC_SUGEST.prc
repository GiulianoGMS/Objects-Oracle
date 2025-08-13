ROCEDURE NAGP_RATEIA_ACRESC_SUGEST (
    psSeqGerCompra  IN NUMBER,
    psSeqProduto    IN NUMBER,
    psQtdEmb        IN NUMBER,
    psQtdUnidade    IN NUMBER,
    pdIndTipoMedVda IN VARCHAR2
) 
IS
    -- Caixas arredondadas para evitar diferenças de precisão
    pcQtdCxs NUMBER := ROUND(psQtdUnidade / psQtdEmb, 6);
BEGIN
    FOR t IN (
        WITH BASE AS (
            SELECT 
                NROEMPRESA,
                MEDIA,
                MEDIA / SUM(MEDIA) OVER() PERC,
                FLOOR(TO_NUMBER(ROUND(psQtdUnidade / psQtdEmb, 6)) * MEDIA / SUM(MEDIA) OVER()) CX,
                ( (TO_NUMBER(ROUND(psQtdUnidade / psQtdEmb, 6)) * MEDIA / SUM(MEDIA) OVER())
                  - FLOOR(TO_NUMBER(ROUND(psQtdUnidade / psQtdEmb, 6)) * MEDIA / SUM(MEDIA) OVER()) ) FRACAO,
                SEQPRODUTO
            FROM (
                SELECT 
                    A.NROEMPRESA,
                    CASE 
                        WHEN pdIndTipoMedVda = 'N' THEN A.MEDVDIAGERAL
                        WHEN pdIndTipoMedVda = 'P' THEN NVL(NULLIF(A.MEDVDIAPROMOC,0), A.MEDVDIAGERAL)
                        WHEN pdIndTipoMedVda = 'E' THEN NVL(NULLIF(A.MEDVDIAFORAPROMOC,0), A.MEDVDIAGERAL)
                    END MEDIA,
                    A.SEQPRODUTO
                FROM MRL_PRODUTOEMPRESA A
                WHERE SEQPRODUTO = psSeqProduto
                  AND CASE 
                        WHEN pdIndTipoMedVda = 'N' THEN A.MEDVDIAGERAL
                        WHEN pdIndTipoMedVda = 'P' THEN NVL(NULLIF(A.MEDVDIAPROMOC,0), A.MEDVDIAGERAL)
                        WHEN pdIndTipoMedVda = 'E' THEN NVL(NULLIF(A.MEDVDIAFORAPROMOC,0), A.MEDVDIAGERAL)
                      END > 0
                  AND A.NROEMPRESA < 100
                ORDER BY CASE 
                            WHEN pdIndTipoMedVda = 'N' THEN A.MEDVDIAGERAL
                            WHEN pdIndTipoMedVda = 'P' THEN NVL(NULLIF(A.MEDVDIAPROMOC,0), A.MEDVDIAGERAL)
                            WHEN pdIndTipoMedVda = 'E' THEN NVL(NULLIF(A.MEDVDIAFORAPROMOC,0), A.MEDVDIAGERAL)
                         END DESC
                FETCH FIRST 3 ROWS ONLY
            )
        ),
        COM_SOBRA AS (
            SELECT 
                BASE.*,
                ROW_NUMBER() OVER(ORDER BY FRACAO DESC) RANK_SOBRA,
                (TO_NUMBER(ROUND(psQtdUnidade / psQtdEmb, 6)) - SUM(CX) OVER()) SOBRAM
            FROM BASE
        )
        SELECT 
            NROEMPRESA,
            MEDIA,
            SEQPRODUTO,
            (CX + CASE WHEN RANK_SOBRA <= SOBRAM THEN 1 ELSE 0 END) 
                * psQtdEmb AS QtdCalculada
        FROM COM_SOBRA
        ORDER BY MEDIA DESC
    )
    LOOP
        UPDATE MAC_GERCOMPRAITEM XI
        SET XI.QTDPEDIDA = COALESCE((
            SELECT QTDPEDIDA 
            FROM MAC_GERCOMPRAITEM 
            WHERE NROEMPRESA   = t.NROEMPRESA
              AND SEQPRODUTO   = t.SEQPRODUTO
              AND SEQGERCOMPRA = psSeqGerCompra
        ), 0) + t.QtdCalculada
        WHERE XI.NROEMPRESA   = t.NROEMPRESA
          AND XI.SEQPRODUTO   = t.SEQPRODUTO
          AND XI.SEQGERCOMPRA = psSeqGerCompra;
    END LOOP;

    COMMIT;
END;
