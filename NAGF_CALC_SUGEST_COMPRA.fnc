CREATE OR REPLACE FUNCTION NAGF_CALC_SUGEST_COMPRA (pdSeqFornecedor IN MAF_FORNECEDOR.SEQFORNECEDOR%TYPE,
                                                    pdNroEmpresa    IN MAX_EMPRESA.NROEMPRESA%TYPE,
                                                    pdSeqProduto    IN MAP_PRODUTO.SEQPRODUTO%TYPE,
                                                    pdPeriodoCalc   IN MAC_GERCOMPRA.QTDMEDVDA%TYPE,
                                                    pdSeqGerCompra  IN MAC_GERCOMPRA.SEQGERCOMPRA%TYPE,
                                                    pdIndTipoMedVda IN MAC_GERCOMPRA.INDTIPOMEDVDA%TYPE)
                                                    
   RETURN NUMBER IS
 
      vsSugestaoFinal NUMBER(10);
      pcEstoque       MRL_PRODUTOEMPRESA.ESTQLOJA%TYPE;
      pcMediaVendaFim NUMBER(10);
      pcEstqmin       MRL_PRODUTOEMPRESA.ESTQMINIMODV%TYPE;
      pcEstqmax       MRL_PRODUTOEMPRESA.ESTQMAXIMODV%TYPE;
      pcPrevEstq      NUMBER(10);
      pcPrevOrig      NUMBER(10);
      pcPrevLim       NUMBER(10);
      pcPrevExtraLim  NUMBER(10);
      pdTipoEmp       VARCHAR2(10);
      pdDiasAtraso    MAF_FORNECDIVISAO.PZOMEDATRASO%TYPE;
     

       
   BEGIN
         
   -- Pega os dias de atraso para utilizar na formula
         
      SELECT MAX(F.PZOMEDATRASO)
        INTO pdDiasAtraso
        FROM MAF_FORNECDIVISAO F
       WHERE SEQFORNECEDOR = pdSeqFornecedor;
       
   -- Valida se a empresa que esta entrando na variavel é LOJA ou CD para utilizar na formula
   
      SELECT TIPO 
        INTO pdTipoEmp
        FROM DWNAGT_DADOSEMPRESA E
       WHERE E.NROEMPRESA = pdNroEmpresa;
        
   -- Formula do Calculo para Sugestao
   -- Se a empresa for CD, calcula o excedente do limite (Parametrizado em estoque max odv)
   
    pcEstoque         := 0;
    pcMediaVendaFim   := 0;
    pcEstqmin         := 0;
    pcEstqmax         := 0;
    pcPrevEstq        := 0;
    pcPrevOrig        := 0;
    pcPrevLim         := 0;
    pcPrevExtraLim    := 0;

    FOR emp IN ( SELECT NROEMPRESA FROM DWNAGT_DADOSEMPRESA X WHERE (X.NROEMPRESA = pdNroEmpresa AND pdTipoEmp = 'LOJA')
                                                                 OR (X.TIPO = 'LOJA' AND pdTipoEmp = 'CD')
               )
    LOOP
      
      DECLARE
        vEstoque        NUMBER := 0;
        vMediaVendaFim  NUMBER := 0;
        vEstqmin        NUMBER := 0;
        vEstqmax        NUMBER := 0;
        vPrevEstq       NUMBER := 0;
        vPrevOrig       NUMBER := 0;
        vPrevLim        NUMBER := 0;
        vPrevExtraLim   NUMBER := 0;
        
      BEGIN
        SELECT NVL(ESTQ,0), NVL(MED_PREV_VDA_FIM,0), NVL(ESTQMIN,0), NVL(ESTQMAX,0), NVL(PREV_ESTQ,0),
               NVL((ESTQMIN - PREV_ESTQ),0) PREV_ORIGINAL,
               NVL(CASE WHEN ESTQMAX > (ESTQMIN - PREV_ESTQ) THEN (ESTQMIN - PREV_ESTQ) ELSE ESTQMAX END,0)     PREV_SUG_LIM,
               NVL(CASE WHEN ESTQMAX < (ESTQMIN - PREV_ESTQ) THEN (ESTQMIN - PREV_ESTQ) - ESTQMAX ELSE 0 END,0) PREV_EXTRA_LIM
                 
          INTO vEstoque, vMediaVendaFim, vEstqmin, vEstqmax, vPrevEstq, vPrevOrig, vPrevLim, vPrevExtraLim
               
          FROM (
          
            SELECT FC5ESTOQUEDISPONIVEL(pdSeqProduto, emp.NROEMPRESA) ESTQ, 
                   MAX(PREVISAO)                   MED_PREV_VDA_FIM,
                   AVG(ESTQMINIMODV)               ESTQMIN, 
                   AVG(ESTQMAXIMODV)               ESTQMAX,
                   MIN(PREV_ESTQ)                  PREV_ESTQ
              FROM (
                SELECT X.DTA, P.NROEMPRESA, 
                       ROUND(
                       -- Pega a media de acordo com o param da capa do lote
                       CASE WHEN pdIndTipoMedVda = 'N' THEN P.MEDVDIAGERAL
                            WHEN pdIndTipoMedVda = 'P' THEN NVL(NULLIF(P.MEDVDIAPROMOC,0),P.MEDVDIAGERAL)
                            WHEN pdIndTipoMedVda = 'E' THEN NVL(NULLIF(P.MEDVDIAFORAPROMOC,0),P.MEDVDIAGERAL) END
                        * ROWNUM) PREVISAO,
                       --
                       P.ESTQMINIMODV,
                       P.ESTQMAXIMODV,
                       FC5ESTOQUEDISPONIVEL(P.SEQPRODUTO, P.NROEMPRESA) ESTQ,
                       FC5ESTOQUEDISPONIVEL(P.SEQPRODUTO, P.NROEMPRESA) - 
                       -- Pega a media de acordo com o param da capa do lote
                 ROUND(CASE WHEN pdIndTipoMedVda = 'N' THEN P.MEDVDIAGERAL
                            WHEN pdIndTipoMedVda = 'P' THEN NVL(NULLIF(P.MEDVDIAPROMOC,0),P.MEDVDIAGERAL)
                            WHEN pdIndTipoMedVda = 'E' THEN NVL(NULLIF(P.MEDVDIAFORAPROMOC,0),P.MEDVDIAGERAL) END
                       --
                       * ROWNUM) PREV_ESTQ
                  FROM DIM_TEMPO X 
                       INNER JOIN MRL_PRODUTOEMPRESA P ON 1=1
                 WHERE X.DTA BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) - 1 + NVL(pdPeriodoCalc,0) + NVL(pdDiasAtraso,0)
                   AND P.NROEMPRESA = emp.NROEMPRESA
                   AND P.SEQPRODUTO = pdSeqProduto
                   AND P.ESTQMINIMODV > 0
                   AND P.ESTQMAXIMODV > 0
                   AND EXISTS (SELECT 1 FROM MAC_GERCOMPRAEMP EM WHERE EM.SEQGERCOMPRA = pdSeqGerCompra AND EM.NROEMPRESA = P.NROEMPRESA)
              )
          );

        -- Soma acumulada nas variáveis principais
        pcEstoque        := pcEstoque        + vEstoque;
        pcMediaVendaFim  := pcMediaVendaFim  + vMediaVendaFim;
        pcEstqmin        := pcEstqmin        + vEstqmin;
        pcEstqmax        := pcEstqmax        + vEstqmax;
        pcPrevEstq       := pcPrevEstq       + vPrevEstq;
        pcPrevOrig       := pcPrevOrig       + vPrevOrig;
        pcPrevLim        := pcPrevLim        + vPrevLim;
        pcPrevExtraLim   := pcPrevExtraLim   + vPrevExtraLim;
        
       END;
       
      END LOOP;
        
     -- Se é Loja, retorna a sugestao ate o limite da loja
        IF pdTipoEmp = 'LOJA' THEN
     vsSugestaoFinal := pcPrevLim;
     
     -- Se for CD, retorna o extra calculado para as lojas
     ELSIF pdTIpoEmp = 'CD'   THEN
     vsSugestaoFinal := pcPrevExtraLim;
     
    END IF;
    
    RETURN vsSugestaoFinal;
    
    END;
          
