CREATE OR REPLACE FUNCTION CONSINCO.NAGF_BUSCAULTENT_ATIVO (psNroEmpresa NUMBER,
                                                            psSeqProduto NUMBER)
                                                            
RETURN VARCHAR2 IS
 vsRetorno VARCHAR2(1);
 
 BEGIN
 
 SELECT CASE WHEN MAX(NVL(Z.DTAHORLANCTO, SYSDATE)) > SYSDATE - 365 THEN 1 ELSE 0 END INDICADOR
   INTO vsRetorno
   FROM MLF_NOTAFISCAL Z
  INNER JOIN MLF_NFITEM ZI
     ON ZI.SEQNF = Z.SEQNF
  WHERE Z.NROEMPRESA = psNroEmpresa
   AND ZI.SEQPRODUTO = psSeqProduto;
   
   IF vsRetorno IS NULL THEN
     vsRetorno := 0;
     
   END IF;
   
RETURN vsRetorno;

END;
