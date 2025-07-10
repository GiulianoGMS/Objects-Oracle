CREATE OR REPLACE FUNCTION NAGF_BUSCAUFULTENTRADA (pnNroEmpresa IN NUMBER, 
                                                   pnSeqProduto IN NUMBER,
                                                   pnApenasCDI VARCHAR2 DEFAULT 'N')

 RETURN VARCHAR2 IS
 
   psUF VARCHAR2(2);
   psIndImportadora VARCHAR2(1);
   psRetorno VARCHAR2(2);

BEGIN
  
   SELECT MAX(UF)
     INTO psUF
     FROM GE_PESSOA G
    WHERE SEQPESSOA = (SELECT SEQPESSOA
                                FROM MLF_NOTAFISCAL N
                               WHERE N.SEQNF = (SELECT FMLF_SEQNFULTENTRADA(pnNroEmpresa, pnSeqProduto,'C')
                                                           
                                                  FROM DUAL));
   SELECT NVL(INDIMPORTADORA, 'N')
     INTO psIndImportadora
     FROM MAX_EMPRESA E 
    WHERE E.NROEMPRESA = pnNroEmpresa;
           
       IF pnApenasCDI = 'S' -- Apenas cd importador no retorno       
         THEN IF psIndImportadora = 'I'
           THEN psRetorno := psUF;
             END IF;
    ELSIF pnApenasCDI = 'N'
         THEN psRetorno := psUF;
       END IF;
      
    RETURN psRetorno;
    
END;
