CREATE OR REPLACE PROCEDURE NAGP_ATUALIZA_CTO_PED (psNroPedido  NUMBER,
                                                   psNroEmpresa NUMBER,
                                                   psSeqProduto NUMBER) AS

BEGIN

 INSERT INTO MSUX_ATU_PSITEMRECEBER 
 VALUES (psNroPedido, psNroEmpresa, 'C', psSeqProduto, NULL, 'I', NULL);

 BEGIN sp_msu_atuprecofornec_Nag('CONSINCO','601'); END; 
 
 DELETE FROM MSUX_ATU_PSITEMRECEBER 
  WHERE NROPEDIDOSUPRIM = psNroPedido 
    AND NROEMPRESA = psNroEmpresa
    AND SEQPRODUTO = psSeqProduto;

COMMIT;

END;
 
