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
   -- Arredonda de acordo com percentual para definir se calcula Palete ou Lastro
      IF psTipoAt = 'AP' THEN 
    vsPercSugestao := t.PERCVARIACAOSUG;
      IF (vsQtdTotalCalc / t.QTY_PALETE) * 100 >= vsPercSugestao THEN
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
