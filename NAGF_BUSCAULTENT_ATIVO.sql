CREATE OR REPLACE FUNCTION CONSINCO.NAGF_BUSCAULTENT_ATIVO (psNroEmpresa NUMBER,
                                                            psSeqProduto NUMBER)
                                                            
RETURN NUMBER IS
 vsRetorno  NUMBER(2);
 
 BEGIN
   
 SELECT CASE WHEN NVL(MAX(X.DTAENTRADA),  DATE '2000-01-01') <= SYSDATE - 365 THEN 10 ELSE 78 END CGO
  INTO vsRetorno
  FROM OR_NFDESPESA X INNER JOIN OR_NFITENSDESPESA XI ON XI.SEQNOTA = X.SEQNOTA
 WHERE X.NROEMPRESA  = psNroEmpresa
   AND XI.CODPRODUTO = psSeqProduto;
  
 -- Se a ultima entrada no orc for ha mais de 365 dias (1 ano) entao olho se teve entrada por transferencia
 
 IF vsRetorno = 10 THEN
   
 vsRetorno := NULL;
   
 SELECT CASE WHEN NVL(MAX(Z.DTAHORLANCTO), DATE '2000-01-01') <= SYSDATE - 365 THEN 10 ELSE 78 END CGO_FINAL
   INTO vsRetorno
   FROM MLF_NOTAFISCAL Z
  INNER JOIN MLF_NFITEM ZI
     ON ZI.SEQNF = Z.SEQNF
  WHERE Z.SEQPESSOA < 999
   AND Z.NROEMPRESA = psNroEmpresa
   AND ZI.SEQPRODUTO = psSeqProduto;
 
 END IF;
 
RETURN vsRetorno;

END;
