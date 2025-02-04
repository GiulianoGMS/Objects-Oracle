CREATE OR REPLACE FUNCTION CONSINCO.NAGF_ECOMM_CANALVENDA (vsNroEmpresa  NUMBER,
                                                           vsNumeroDF    NUMBER,
                                                           vsDta         DATE)
 RETURN VARCHAR2 IS
 vnCanalVenda VARCHAR2(20);

BEGIN

SELECT X.PEDIDOID
  INTO vnCanalVenda
  FROM ECOMM_PDV_VENDA X
 WHERE X.NROEMPRESA = vsNroEmpresa
   AND X.NROPEDVENDA = vsNumeroDF
   AND X.DTAINCLUSAO BETWEEN vsDta - 17 AND vsDta + 3;
       
 RETURN vnCanalVenda;
 
END;
