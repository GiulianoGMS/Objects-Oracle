CREATE OR REPLACE PROCEDURE NAGP_ATUALIZA_SUGESTAO (psSeqGerCompra NUMBER)

AS

BEGIN
  FOR t IN (SELECT G.SEQGERCOMPRA, GI.SEQPRODUTO, GI.NROEMPRESA,
                   NAGF_CALC_SUGEST_COMPRA(pdSeqFornecedor => GF.SEQFORNECEDOR,
                                           pdNroEmpresa    => GI.NROEMPRESA,
                                           pdSeqProduto    => GI.SEQPRODUTO,
                                           pdPeriodoCalc   => G.QTDMEDVDA,
                                           pdSeqGerCompra  => G.SEQGERCOMPRA,
                                           pdIndTipoMedVda => G.INDTIPOMEDVDA) SUGEST_CALC,
                   GI.QTDEMBALAGEM,
                   -- Cálculo de caixas (arredondado para cima) 
                   CASE WHEN NVL(FORMAARREDSUGABAST, 'E') = 'E' THEN -- Embalagem Normal
                   CEIL(
                     NAGF_CALC_SUGEST_COMPRA(
                       pdSeqFornecedor => GF.SEQFORNECEDOR,
                       pdNroEmpresa    => GI.NROEMPRESA,
                       pdSeqProduto    => GI.SEQPRODUTO,
                       pdPeriodoCalc   => G.QTDMEDVDA,
                       pdSeqGerCompra  => G.SEQGERCOMPRA,
                       pdIndTipoMedVda => G.INDTIPOMEDVDA
                     ) / GI.QTDEMBALAGEM) * QTDEMBALAGEM 
                     
                       ELSE
                  (CEIL(CEIL(
                     NAGF_CALC_SUGEST_COMPRA(
                       pdSeqFornecedor => GF.SEQFORNECEDOR,
                       pdNroEmpresa    => GI.NROEMPRESA,
                       pdSeqProduto    => GI.SEQPRODUTO,
                       pdPeriodoCalc   => G.QTDMEDVDA,
                       pdSeqGerCompra  => G.SEQGERCOMPRA,
                       pdIndTipoMedVda => G.INDTIPOMEDVDA
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
                     SUGEST_ARRED
                   
                   
              FROM MAC_GERCOMPRA G INNER JOIN MAC_GERCOMPRAITEM GI ON G.SEQGERCOMPRA = GI.SEQGERCOMPRA
                                   INNER JOIN MAC_GERCOMPRAFORN GF ON GF.SEQGERCOMPRA = G.SEQGERCOMPRA
                                   INNER JOIN MRL_PRODUTOEMPRESA P ON P.SEQPRODUTO = GI.SEQPRODUTO AND P.NROEMPRESA = GI.NROEMPRESA
                                    LEFT JOIN MRL_PRODEMPRESAWM  W ON W.SEQPRODUTO = GI.SEQPRODUTO AND W.NROEMPRESA = GI.NROEMPRESA
                                   
                                   WHERE G.SEQGERCOMPRA  = psSeqGerCompra
                                     AND G.SITUACAOLOTE  = 'A'
                                     AND G.TIPOSUGCOMPRA = 'M'
                                     --AND G.SEQGERMODELOCOMPRA IS NOT NULL
           )
  LOOP
    
                               
                               UPDATE MAC_GERCOMPRAITEM XI SET XI.QTDSUGERIDAORIGINAL = T.SUGEST_ARRED,
                                                               XI.QTDPEDIDA           = T.SUGEST_ARRED
                                                         WHERE XI.NROEMPRESA   = T.NROEMPRESA
                                                           AND XI.SEQPRODUTO   = T.SEQPRODUTO
                                                           AND XI.SEQGERCOMPRA = T.SEQGERCOMPRA;
                                                           
  END LOOP;
  
  COMMIT;
  
  END;
