CREATE OR REPLACE PACKAGE NAGPKG_SUGESTAO_COMPRA AS

  FUNCTION NAGF_CALC_SUGEST_COMPRA (
    pdSeqFornecedor IN MAF_FORNECEDOR.SEQFORNECEDOR%TYPE,
    pdNroEmpresa    IN MAX_EMPRESA.NROEMPRESA%TYPE,
    pdSeqProduto    IN MAP_PRODUTO.SEQPRODUTO%TYPE,
    pdPeriodoCalc   IN MAC_GERCOMPRA.QTDMEDVDA%TYPE,
    pdSeqGerCompra  IN MAC_GERCOMPRA.SEQGERCOMPRA%TYPE,
    pdIndTipoMedVda IN MAC_GERCOMPRA.INDTIPOMEDVDA%TYPE,
    pdTipoRetorno   IN VARCHAR2
  ) RETURN NUMBER;

  PROCEDURE NAGP_ATUALIZA_SUGESTAO (
    psSeqGerCompra IN NUMBER,
    psTipoAt       IN VARCHAR2
  );

END NAGPKG_SUGESTAO_COMPRA;

--

CREATE OR REPLACE PACKAGE BODY NAGPKG_SUGESTAO_COMPRA AS

FUNCTION NAGF_CALC_SUGEST_COMPRA (pdSeqFornecedor IN MAF_FORNECEDOR.SEQFORNECEDOR%TYPE,
                                                    pdNroEmpresa    IN MAX_EMPRESA.NROEMPRESA%TYPE,
                                                    pdSeqProduto    IN MAP_PRODUTO.SEQPRODUTO%TYPE,
                                                    pdPeriodoCalc   IN MAC_GERCOMPRA.QTDMEDVDA%TYPE,
                                                    pdSeqGerCompra  IN MAC_GERCOMPRA.SEQGERCOMPRA%TYPE,
                                                    pdIndTipoMedVda IN MAC_GERCOMPRA.INDTIPOMEDVDA%TYPE,
                                                    pdTipoRetorno   IN VARCHAR2)
                                                    
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
      pdConsEmpAbast  VARCHAR(1);
      pdReturn        NUMBER(10);
      
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
       
   -- Valida se considera estoque da empresa abatecedora no calculo
      
      SELECT NVL(INDCONSESTOQUECENTRALSUG, 'N')
        INTO pdConsEmpAbast
        FROM MAC_GERCOMPRA GER
       WHERE GER.SEQGERCOMPRA = pdSeqGerCompra;
        
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
                       -- Pega o estoque da Loja para calculo
                       (FC5ESTOQUEDISPONIVEL(P.SEQPRODUTO, P.NROEMPRESA) + 
                       -- Informa se considera estoque da empresa abatecedora no calculo
                       CASE WHEN pdConsEmpAbast = 'S' AND P.NROEMPRESA < 500 THEN
                       FC5ESTOQUEDISPONIVEL(P.SEQPRODUTO, M.NROEMPRESAABASTEC)
                       ELSE 0 END) -
                       -- Pega a media de acordo com o param da capa do lote
                 ROUND(CASE WHEN pdIndTipoMedVda = 'N' THEN P.MEDVDIAGERAL
                            WHEN pdIndTipoMedVda = 'P' THEN NVL(NULLIF(P.MEDVDIAPROMOC,0),P.MEDVDIAGERAL)
                            WHEN pdIndTipoMedVda = 'E' THEN NVL(NULLIF(P.MEDVDIAFORAPROMOC,0),P.MEDVDIAGERAL) END
                       --
                       * ROWNUM) PREV_ESTQ
                  FROM DIM_TEMPO X 
                       INNER JOIN MRL_PRODUTOEMPRESA P ON 1=1
                       INNER JOIN MAX_EMPRESA M ON M.NROEMPRESA = P.NROEMPRESA
                       
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
    
    IF pdTipoRetorno = 'S' -- Sugestao
    THEN pdReturn := vsSugestaoFinal;
    
    ELSIF pdTipoRetorno = 'T' -- Total
    THEN pdReturn := pcPrevOrig;
    
    END IF;
    
    RETURN pdReturn;
    
    END NAGF_CALC_SUGEST_COMPRA;
    
PROCEDURE NAGP_ATUALIZA_SUGESTAO (psSeqGerCompra IN NUMBER,
                                                    psTipoAt       IN VARCHAR2)

  IS vsQtdTotalCalc  NUMBER(38);
     vcQtdTotalUpd   NUMBER(38);
     vsPercSugestao  NUMBER(38);
     vcEmbCalc       NUMBER(38);

BEGIN
  vsQtdTotalCalc := 0;
  vcQtdTotalUpd  := 0;
  vsPercSugestao := 0;
  
  FOR t IN (SELECT G.SEQGERCOMPRA, GI.SEQPRODUTO, GI.NROEMPRESA,
                   -- De acordo com o PD psTipoAt
                   -- QP - Arredonda a compra final no CD com o que ja esta populado no lote, sem alterar nas lojas.
                   -- AP - Arredonda a compra final no CD com o que ja esta populado no lote, sem alterar nas lojas, de acordo com o percentual (Apontando se e mais prox de LASTRO ou PALETE)
                   -- para AP, a FormaArredSugAbast no CD precisa ser diferente de 'E', se for E nao entrará na regra
                   -- CA - Utiliza o calculo de MIN MAX desenvolvido internamente pelo Nagumo, arredondando a compra final no CD (Altera Lojas e CD)
                   -- CN - Utiliza o calculo de MIN MAX desenvolvido internamente pelo Nagumo, SEM arredondar a compra final on CD (Altera Lojas e CD)
                   NVL(CASE WHEN psTipoAt IN ('QP','AP') THEN GI.QTDPEDIDA 
                        WHEN psTipoAt IN ('CN','CA') THEN
                   -- Cálculo de caixas (arredondado para cima) 
                   CASE WHEN NVL(FORMAARREDSUGABAST, 'E') = 'E' OR TIPO = 'CD' THEN -- Embalagem Normal
                   CEIL(
                     NAGF_CALC_SUGEST_COMPRA(
                       pdSeqFornecedor => GF.SEQFORNECEDOR,
                       pdNroEmpresa    => GI.NROEMPRESA,
                       pdSeqProduto    => GI.SEQPRODUTO,
                       pdPeriodoCalc   => G.QTDMEDVDA,
                       pdSeqGerCompra  => G.SEQGERCOMPRA,
                       pdIndTipoMedVda => G.INDTIPOMEDVDA,
                       pdTipoRetorno   => 'S'
                     ) / GI.QTDEMBALAGEM) * QTDEMBALAGEM 
                     
                   ELSE
                  (CEIL(CEIL(
                     NAGF_CALC_SUGEST_COMPRA(
                       pdSeqFornecedor => GF.SEQFORNECEDOR,
                       pdNroEmpresa    => GI.NROEMPRESA,
                       pdSeqProduto    => GI.SEQPRODUTO,
                       pdPeriodoCalc   => G.QTDMEDVDA,
                       pdSeqGerCompra  => G.SEQGERCOMPRA,
                       pdIndTipoMedVda => G.INDTIPOMEDVDA,
                       pdTipoRetorno   => 'S'
                     ) / GI.QTDEMBALAGEM) / --< Descobre Qtd de Caixas
                     -- Arredonda embalagem palete ou lastro
                     -- Descobre se o total de caixas é igual ao palete ou lastro
                     (CASE WHEN P.FORMAARREDSUGABAST = 'L' THEN W.PALETELASTRO
                           WHEN P.FORMAARREDSUGABAST = 'P' THEN W.PALETELASTRO * W.PALETEALTURA
                           ELSE GI.QTDEMBALAGEM END)) *
                     (CASE WHEN P.FORMAARREDSUGABAST = 'L' THEN W.PALETELASTRO
                           WHEN P.FORMAARREDSUGABAST = 'P' THEN W.PALETELASTRO * W.PALETEALTURA
                           ELSE GI.QTDEMBALAGEM END)) *
                             
                     QTDEMBALAGEM -- Multiplica para ter o total de unidades
                     END
                     END,0) QTY_FINAL,
                     QTDEMBALAGEM qtdEmb,
                     CASE WHEN P.FORMAARREDSUGABAST = 'E' THEN GI.QTDEMBALAGEM 
                          WHEN P.FORMAARREDSUGABAST = 'L' THEN w.PALETELASTRO 
                          WHEN P.FORMAARREDSUGABAST = 'P' THEN w.PALETELASTRO * w.PALETEALTURA END qtdArred,
                     TIPO,
                     P.PERCVARIACAOSUG,
                     w.PALETELASTRO QTY_LASTRO,
                     w.PALETELASTRO * w.PALETEALTURA QTY_PALETE
                     
                   
                   
              FROM MAC_GERCOMPRA G INNER JOIN MAC_GERCOMPRAITEM GI  ON G.SEQGERCOMPRA = GI.SEQGERCOMPRA
                                   INNER JOIN MAC_GERCOMPRAFORN GF  ON GF.SEQGERCOMPRA = G.SEQGERCOMPRA
                                   INNER JOIN MRL_PRODUTOEMPRESA P  ON P.SEQPRODUTO = GI.SEQPRODUTO AND P.NROEMPRESA = GI.NROEMPRESA
                                    LEFT JOIN MRL_PRODEMPRESAWM  W  ON W.SEQPRODUTO = GI.SEQPRODUTO AND W.NROEMPRESA = GI.NROEMPRESA
                                   INNER JOIN DWNAGT_DADOSEMPRESA D ON D.NROEMPRESA = GI.NROEMPRESA
                                   
                                   WHERE G.SEQGERCOMPRA  = psSeqGerCompra
                                     --AND G.SITUACAOLOTE  = 'A'
                                     --AND G.TIPOSUGCOMPRA = 'M'
                                     
             ORDER BY GI.SEQPRODUTO, GI.NROEMPRESA ASC -- Nao remover
             
                                     --AND G.SEQGERMODELOCOMPRA IS NOT NULL
           )
  LOOP
    vsQtdTotalCalc := vsQtdTotalCalc + T.QTY_FINAL;
    
    -- Aqui vai entrar a regra para arredondar a compra completa em paletes
    -- O arredondamento sera accrecentado no CD abastecedor
    -- Apenas arredonda nos PDs 'CA', 'QP' e 'AP'
    
    IF t.TIPO = 'CD' THEN
   -- Arredonda de acordo com percentual para definir se calcula Palete ou Lastro, apenas se FormaArredSugAbast for L ou P
   -- Exemplo: Se o total nas lojas passa de 80% do perc de sugestao, sobe o arredondamento para palete, se nao mantem lastro
      IF psTipoAt = 'AP' THEN 
    vsPercSugestao := t.PERCVARIACAOSUG;
      IF (vsQtdTotalCalc / t.QTY_PALETE) * 100 >= vsPercSugestao AND vsPercSugestao > 0 THEN
    vcEmbCalc := t.QTY_PALETE;
      ELSE
    vcEmbCalc := T.QTY_LASTRO;
      END IF;
    vcQtdTotalUpd := ((CEIL((vsQtdTotalCalc / t.qtdEmb) / vcEmbCalc) * vcEmbCalc) * t.qtdEmb) - vsQtdTotalCalc + t.QTY_FINAL;
    --Arredonda de acordo com a config no CD (Palete/Lastro)
      ELSIF psTipoAt IN('CA','QP') THEN 
    vcQtdTotalUpd := ((CEIL((vsQtdTotalCalc / t.qtdEmb) / t.qtdArred) * t.qtdArred) * t.qtdEmb) - vsQtdTotalCalc + t.QTY_FINAL;
   -- Nao Arredonda
      ELSIF psTipoAt = 'CN' THEN vcQtdTotalUpd := t.QTY_FINAL;
      END IF;
  
    ELSIF t.TIPO = 'LOJA' THEN
    vcQtdTotalUpd := t.QTY_FINAL; 
  END IF;
    
     UPDATE MAC_GERCOMPRAITEM XI SET XI.QTDSUGERIDAORIGINAL = vcQtdTotalUpd,
                                     XI.QTDPEDIDA           = vcQtdTotalUpd
                               WHERE XI.NROEMPRESA   = T.NROEMPRESA
                                 AND XI.SEQPRODUTO   = T.SEQPRODUTO
                                 AND XI.SEQGERCOMPRA = T.SEQGERCOMPRA
                                 -- Este Case é para arredonrar apenas o CD quando for informado o PD psTipoAlt como 'QP'
                                 AND XI.NROEMPRESA = CASE WHEN psTipoAt IN ('QP','AP') THEN 507 
                                                          WHEN psTipoAt IN ('CN','CA') THEN t.NROEMPRESA END;
                                 
    -- Reseta os valores após atualizar o valor do primeiro CD e primeiro Produto
    IF 1=1 AND t.TIPO = 'CD' THEN  
      
     vsQtdTotalCalc := 0;
     vcQtdTotalUpd  := 0;
     vsPercSugestao := 0;
     
    END IF;
     
  END LOOP;
  
  COMMIT;
  
  END NAGP_ATUALIZA_SUGESTAO;
  
END NAGPKG_SUGESTAO_COMPRA;

          
