CREATE OR REPLACE PROCEDURE NAGP_REMOVE_BLOQ_CANC (psNumeroNF NUMBER, psEmpresaEmitente NUMBER, psEmpRecebimento NUMBER)

 IS 
 psSeqNF NUMBER(30);

 BEGIN
   SELECT MAX(X.SEQNF)
     INTO psSeqNF
     FROM MFL_DOCTOFISCAL X WHERE NUMERODF = psNumeroNF AND NROEMPRESA = psEmpresaEmitente AND SEQPESSOA = psEmpRecebimento;

  IF psSeqNF IS NOT NULL THEN
    DELETE FROM MLF_NFCONTROLABLOQUEIO X 
      WHERE X.SEQNF = psSeqNF;
  END IF;

 COMMIT;

  END;
  

-- Veja se a nota ainda existe: 
SELECT * FROM MLF_NFCONTROLABLOQUEIO A INNER JOIN MFL_DOCTOFISCAL X ON X.SEQNF = A.SEQNF
 WHERE X.NUMERODF = 14706 
   AND X.NROEMPRESA = 53;

-- Execute para excluir a critica da nota:
BEGIN
  NAGP_REMOVE_BLOQ_CANC(psNumeroNF        =>  158939,
                        psEmpresaEmitente =>  506,
                        psEmpRecebimento  =>  24
                       );
 END;


