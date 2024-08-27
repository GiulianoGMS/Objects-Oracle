CREATE OR REPLACE FUNCTION CONSINCO.NAGF_BUSCAVLRDEV (vsSeqNF      NUMBER,
                                                      vsSeqProduto NUMBER)
                                                      
 RETURN NUMBER AS
 vsVlrDev NUMBER(5);
 
 BEGIN 
   SELECT DI.VLRITEM
     INTO vsVlrDev
     FROM MFL_DFITEM DI@LINK_C5
    WHERE DI.CODGERALOPER IN (38,124,612,614,616,917,68,260,267,268,618,922,852) 
      AND DI.SEQNFREF = vsSeqNf
      AND DI.SEQPRODUTO = vsSeqProduto;
      
   EXCEPTION
     WHEN NO_DATA_FOUND 
       THEN
         vsVlrDev := 0;
      
 RETURN vsVlrDev;
 
 END;
