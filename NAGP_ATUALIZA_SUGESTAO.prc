CREATE OR REPLACE PROCEDURE NAGP_ATUALIZA_SUGESTAO (psSeqGerCompra NUMBER)

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
                     SUGEST_ARRED,
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
                                     
             ORDER BY GI.NROEMPRESA ASC -- Nao remover
             
                                     --AND G.SEQGERMODELOCOMPRA IS NOT NULL
           )
  LOOP
    vsQtdTotalCalc := vsQtdTotalCalc + T.SUGEST_ARRED;
    -- Aqui vai entrar a regra para arredondar a compra completa em paletes
    -- O arredondamento sera accrecentado no CD abastecedor
    IF 1=1 AND t.TIPO = 'CD' THEN -- Aqui deve entrar o PD que indica se arredonda ou nao
    vcQtdTotalUpd := ((CEIL((vsQtdTotalCalc / t.QTDEMBALAGEM) / t.qtdPALETE) * t.qtdPALETE) * t.qtdEmb) - vsQtdTotalCalc + t.SUGEST_ARRED;
    END IF;
    
     UPDATE MAC_GERCOMPRAITEM XI SET XI.QTDSUGERIDAORIGINAL = CASE WHEN t.TIPO = 'LOJA' THEN t.SUGEST_ARRED ELSE vcQtdTotalUpd END,
                                     XI.QTDPEDIDA           = CASE WHEN t.TIPO = 'LOJA' THEN t.SUGEST_ARRED ELSE vcQtdTotalUpd END
                               WHERE XI.NROEMPRESA   = T.NROEMPRESA
                                 AND XI.SEQPRODUTO   = T.SEQPRODUTO
                                 AND XI.SEQGERCOMPRA = T.SEQGERCOMPRA;
                                                           
  END LOOP;
  
  COMMIT;
  
  END;
