PROCEDURE NAGP_RATEIA_ACRESC_SUGEST (psSeqGerCompra  IN NUMBER,
                                     psSeqProduto    IN NUMBER,
                                     psQtdEmb        IN NUMBER,
                                     psQtdUnidade    IN NUMBER,
                                     pdIndTipoMedVda IN VARCHAR2
                                     ) 
  IS pcQtdCxs NUMBER(38);
  -- Este objeto faz o rateio para as lojas proporcionalmente à media de venda do item
BEGIN
  
  pcQtdCxs := psQtdUnidade / psQtdEmb; -- Transforma unid em caixas apra o rateio correto (por cxs)

  FOR t IN (WITH -- Ctes para calcular o rateio das caixas
  
    BASE AS
     (SELECT NROEMPRESA,
             MEDIA,
             MEDIA / SUM(MEDIA) OVER() PERC,
             FLOOR(pcQtdCxs * MEDIA / SUM(MEDIA) OVER()) CX,
                  (pcQtdCxs * MEDIA / SUM(MEDIA) OVER()) -
             FLOOR(pcQtdCxs * MEDIA / SUM(MEDIA) OVER()) FRACAO, SEQPRODUTO
             
        FROM (SELECT A.NROEMPRESA, 
                     CASE WHEN pdIndTipoMedVda = 'N' THEN A.MEDVDIAGERAL
                          WHEN pdIndTipoMedVda = 'P' THEN NVL(NULLIF(A.MEDVDIAPROMOC,0),A.MEDVDIAGERAL)
                          WHEN pdIndTipoMedVda = 'E' THEN NVL(NULLIF(A.MEDVDIAFORAPROMOC,0),A.MEDVDIAGERAL) END MEDIA, A.SEQPRODUTO
                FROM MRL_PRODUTOEMPRESA A
               WHERE SEQPRODUTO = psSeqProduto
                 AND CASE WHEN pdIndTipoMedVda = 'N' THEN A.MEDVDIAGERAL
                          WHEN pdIndTipoMedVda = 'P' THEN NVL(NULLIF(A.MEDVDIAPROMOC,0),A.MEDVDIAGERAL)
                          WHEN pdIndTipoMedVda = 'E' THEN NVL(NULLIF(A.MEDVDIAFORAPROMOC,0),A.MEDVDIAGERAL) END > 0
                 AND A.NROEMPRESA < 500 -- Exceto CDs
            ORDER BY CASE WHEN pdIndTipoMedVda = 'N' THEN A.MEDVDIAGERAL
                          WHEN pdIndTipoMedVda = 'P' THEN NVL(NULLIF(A.MEDVDIAPROMOC,0),A.MEDVDIAGERAL)
                          WHEN pdIndTipoMedVda = 'E' THEN NVL(NULLIF(A.MEDVDIAFORAPROMOC,0),A.MEDVDIAGERAL) END DESC)
       WHERE 1=1
       FETCH FIRST 3 ROWS ONLY), -- Aqui pego só as 3 maiores lojas por media de venda do rank
       
    COM_SOBRA AS
     (SELECT BASE.*,
             ROW_NUMBER() OVER(ORDER BY FRACAO DESC) RANK_SOBRA, -- Rankeia pra descobrir onde vai a caixa que sobrar
             (pcQtdCxs - SUM(CX) OVER()) SOBRAM
        FROM BASE)
            
    SELECT NROEMPRESA,
           MEDIA, SEQPRODUTO,
          (CX + CASE WHEN RANK_SOBRA <= SOBRAM THEN 1 ELSE 0 END) * psQtdEmb QtdCalculada -- Volta pra unidades pra usar no update
      FROM COM_SOBRA

     ORDER BY 2 DESC)
     
     LOOP
        UPDATE MAC_GERCOMPRAITEM XI SET XI.QTDPEDIDA    = NVL(XI.QTDPEDIDA,0) + NVL(t.QtdCalculada,0)
                                  WHERE XI.NROEMPRESA   = t.NROEMPRESA
                                    AND XI.SEQPRODUTO   = t.SEQPRODUTO
                                    AND XI.SEQGERCOMPRA = psSeqGerCompra;
     END LOOP;
      
END;
