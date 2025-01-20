CREATE OR REPLACE FUNCTION CONSINCO.NAGF_ESTQLOCAL_CD (psCD NUMBER,
                                                       psSeqProduto NUMBER,
                                                       vsTipoRetorno VARCHAR2)
   RETURN INTEGER AS
   vsRetorno      INTEGER(10);
   vsEstqOutro    INTEGER(10);
   vsEstqDeposito INTEGER(10);
   
   BEGIN
     SELECT ESTQDEPOSITO, ESTQOUTRO 
       INTO vsEstqDeposito, vsEstqOutro
       FROM MRL_PRODUTOEMPRESA X 
      WHERE X.NROEMPRESA = psCD
        AND X.SEQPRODUTO = psSeqProduto;
        
   IF vsTipoRetorno = 'D'
     THEN vsRetorno := vsEstqDeposito;
   ELSIF vsTipoRetorno = 'O'
     THEN vsRetorno := vsEstqOutro;
   END IF;
   
RETURN vsRetorno;

END;

