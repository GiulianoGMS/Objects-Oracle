CREATE OR REPLACE VIEW NAGV_FALCONI_HIST_MOVTO AS

SELECT CD, SEQPRODUTO, INDENTRADASAIDA, ENDERECO, TIPO_MOVIMENTO, QTD_MOVTO, EMB, DTAHORMOVTO, ORIGEM_DESTINO

  FROM (

SELECT DISTINCT X.CODDEPOSITANTE CD,
       X.SEQPRODUTO,
       INDENTRADASAIDA,
       SubStr( 'End. ' || fc5SelecionaEndereco(X.SEQENDERECO, 'N'), 1, 250 )||' '||S.DESCESPECIE ENDERECO,
       M.DESCRICAO TIPO_MOVIMENTO,
       X.QTDMOVTO / X.QTDEMBALAGEM QTD_MOVTO,
       E.EMBALAGEM||' '||X.QTDEMBALAGEM EMB,
       DTAHORMOVTO,
       CASE WHEN X.TIPMOVTO IN ('R','M') THEN 'End. '||fc5SelecionaEndereco(X.SEQENDERECOORIDEST, 'N')
            WHEN X.TIPMOVTO = 'T' THEN NULL
              
            ELSE 'Carga '||X.NROCARGA END Origem_Destino, X.SEQENDERECOMOVTO

  FROM MLO_ENDERECOMOVTO X INNER JOIN MLO_PRODUTO P ON X.SEQPRODUTO = P.SEQPRODUTO AND X.CODDEPOSITANTE = P.NROEMPRESA
                           INNER JOIN MLO_TIPOMOVIMENTO M ON M.TIPMOVTO = X.TIPMOVTO
                           INNER JOIN MLO_PRODEMBALAGEM E ON E.SEQPRODUTO = X.SEQPRODUTO AND E.QTDEMBALAGEM = X.QTDEMBALAGEM AND E.NROEMPRESA = P.NROEMPRESA
                           INNER JOIN MLO_ENDERECO ED     ON ED.SEQENDERECO = X.SEQENDERECO
                           INNER JOIN MLO_ESPECIEENDERECO S ON S.ESPECIEENDERECO = ED.ESPECIEENDERECO

 WHERE 1=1

)
