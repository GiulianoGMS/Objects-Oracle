CREATE OR REPLACE PROCEDURE NAGP_ATUALIZA_SUGESTAO (psSeqGerCompra IN NUMBER,
                                                    psTipoAt       IN VARCHAR2)

  IS vsQtdTotalCalc  NUMBER(38);
     vcQtdTotalUpd   NUMBER(38);

BEGIN
  vsQtdTotalCalc := 0;
  vcQtdTotalUpd  := 0;
  
  FOR t IN (SELECT G.SEQGERCOMPRA, GI.SEQPRODUTO, GI.NROEMPRESA,
                   NAGF_CALC_SUGEST_COMPRA(pdSeqFornecedor => GF.SEQFORNECEDOR,
                                           pdNroEmpresa    => GI.NROEMPRESA,
                                           pdSeqProduto    => GI.SEQPRODUTO,
                                           pdPeriodoCalc   => G.QTDMEDVDA,
                                           pdSeqGerCompra  => G.SEQGERCOMPRA,
                                           pdIndTipoMedVda => G.INDTIPOMEDVDA,
                                           pdTipoRetorno   => 'S') SUGEST_CALC,
                   GI.QTDEMBALAGEM,
                   -- De acordo com o PD psTipoAt
                   -- QP - Arredonda a compra final no CD conforme sem alterar nas lojas.
                   -- CA - Utiliza o calculo de MIN MAX desenvolvido internamente pelo Nagumo, arredondando a compra final on CD
                   -- CN - Utiliza o calculo de MIN MAX desenvolvido internamente pelo Nagumo, SEM arredondar a compra final on CD
                   CASE WHEN psTipoAt = 'QP' THEN GI.QTDPEDIDA 
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
                     END QTY_FINAL,
                     QTDEMBALAGEM qtdEmb,
                     w.PALETELASTRO * w.PALETEALTURA qtdPALETE,
                     TIPO
                   
                   
              FROM MAC_GERCOMPRA G INNER JOIN MAC_GERCOMPRAITEM GI  ON G.SEQGERCOMPRA = GI.SEQGERCOMPRA
                                   INNER JOIN MAC_GERCOMPRAFORN GF  ON GF.SEQGERCOMPRA = G.SEQGERCOMPRA
                                   INNER JOIN MRL_PRODUTOEMPRESA P  ON P.SEQPRODUTO = GI.SEQPRODUTO AND P.NROEMPRESA = GI.NROEMPRESA
                                    LEFT JOIN MRL_PRODEMPRESAWM  W  ON W.SEQPRODUTO = GI.SEQPRODUTO AND W.NROEMPRESA = GI.NROEMPRESA
                                   INNER JOIN DWNAGT_DADOSEMPRESA D ON D.NROEMPRESA = GI.NROEMPRESA
                                   
                                   WHERE G.SEQGERCOMPRA  = psSeqGerCompra
                                     AND G.SITUACAOLOTE  = 'A'
                                     AND G.TIPOSUGCOMPRA = 'M'
                                     
             ORDER BY GI.SEQPRODUTO, GI.NROEMPRESA ASC -- Nao remover
             
                                     --AND G.SEQGERMODELOCOMPRA IS NOT NULL
           )
  LOOP
    vsQtdTotalCalc := vsQtdTotalCalc + T.QTY_FINAL;
    -- Aqui vai entrar a regra para arredondar a compra completa em paletes
    -- O arredondamento sera accrecentado no CD abastecedor
    IF psTipoAt = 'CA' AND t.TIPO = 'CD' THEN -- Aqui deve entrar o PD que indica se arredonda ou nao
    vcQtdTotalUpd := ((CEIL((vsQtdTotalCalc / t.QTDEMBALAGEM) / t.qtdPALETE) * t.qtdPALETE) * t.qtdEmb) - vsQtdTotalCalc + t.QTY_FINAL;
    ELSE vcQtdTotalUpd := t.QTY_FINAL;
    END IF;
    
     UPDATE MAC_GERCOMPRAITEM XI SET XI.QTDSUGERIDAORIGINAL = vcQtdTotalUpd,
                                     XI.QTDPEDIDA           = vcQtdTotalUpd
                               WHERE XI.NROEMPRESA   = T.NROEMPRESA
                                 AND XI.SEQPRODUTO   = T.SEQPRODUTO
                                 AND XI.SEQGERCOMPRA = T.SEQGERCOMPRA
                                 AND XI.NROEMPRESA = CASE WHEN psTipoAt = 'QP' THEN 507 
                                                          WHEN psTipoAt IN ('CN','CA') THEN t.NROEMPRESA END;
                                 
    -- Reseta os valores após atualizar o valor do primeiro CD e primeiro Produto
    IF 1=1 AND t.TIPO = 'CD' THEN  
     vsQtdTotalCalc := 0;
     vcQtdTotalUpd  := 0;
    END IF;
     
  END LOOP;
  
  COMMIT;
  
  END;
