CREATE OR REPLACE VIEW NAGV_FALCONI_BASE_PED AS

SELECT X.NROEMPRESA CD, X.NROCARGA CARGA, X.NROPEDVENDA, X.SEQPESSOA DESTINO,  XI.SEQPRODUTO, 
       QTDEMBALAGEM EMB_CX, NVL(NULLIF(XI.QTDATENDIDA,0), XI.QTDPEDIDA) /  XI.QTDEMBALAGEM VOLUME_CXS, 
       NVL(NULLIF(XI.QTDATENDIDA,0), XI.QTDPEDIDA) UNID,
       ROUND(NVL(NULLIF(XI.QTDATENDIDA,0), XI.QTDPEDIDA) /  XI.QTDEMBALAGEM * XI.VLREMBINFORMADO,2) VLR_ATENDIDO,
       TO_CHAR(X.DTAINCLUSAO, 'DD/MM/YYYY') DATA_INCLUSAO,
       X.DTAINCLUSAO DTA,
       SUBSTR(OBSPEDIDO, INSTR(OBSPEDIDO, 'Ped:') + 5,8) PEDIDO_ABASTEC, 
       DECODE(X.SITUACAOPED, 'D', 'Digitacao',
                             'A', 'Analise',
                             'L', 'Liberado', 
                             'C', 'Cancelado',
                             'S', 'Separacao',
                             'P', 'Pre-separacao', 
                             'R', 'Roteirizacao',
                             'W', 'Separado',
                             'F', 'Faturado') SITUACAO_PED

  FROM MAD_PEDVENDA X INNER JOIN MAD_PEDVENDAITEM XI ON X.NROPEDVENDA = XI.NROPEDVENDA
                      INNER JOIN MAP_PRODUTO P ON P.SEQPRODUTO = XI.SEQPRODUTO
                      INNER JOIN MSU_PEDIDOSUPRIM S ON TO_CHAR(S.NROPEDIDOSUPRIM) = SUBSTR(OBSPEDIDO, INSTR(OBSPEDIDO, 'Ped:') + 5,8) AND S.SITUACAOPED != 'C'
                      
 WHERE X.NROEMPRESA > 500 
   AND X.SITUACAOPED != 'C'
   AND XI.STATUSITEM != 'C'
   AND X.SEQPESSOA != X.NROEMPRESA
   AND X.SEQPESSOA < 999;
