CREATE OR REPLACE FUNCTION NAGF_AFRMM_RATEADO (psNumeroDI IN MAD_ADICAOITEM.NUMERODI%TYPE,
                                               psSeqProduto IN NUMBER) 

RETURN NUMBER IS
  vlrAfrmmDeduzir MAD_ADICAOITEM.VLRAFRMM%TYPE;
  
 BEGIN

  SELECT VLRAFRMM
    INTO vlrAfrmmDeduzir
    FROM MAD_ADICAOITEM A
   WHERE A.NUMERODI   = psNumeroDI
     AND A.SEQPRODUTO = psSeqProduto;

 
 RETURN vlrAfrmmDeduzir;
 
 END;
