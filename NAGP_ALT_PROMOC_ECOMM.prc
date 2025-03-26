CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_ALT_PROMOC_ECOMM (psCodPromocao IN NUMBER,
                                                            psComando IN VARCHAR2)  AS
                                                            
   BEGIN

       DECLARE vrCodPromocao VARCHAR2(100);
               vSeqPromocPDV NUMBER(38); 

   BEGIN
  
  vrCodPromocao := TO_CHAR(psCodPromocao);
  
  SELECT NVL(MAX(SEQPROMOCPDV),0) 
    INTO vSeqPromocPDV 
    FROM MFL_PROMOCAOPDV X  WHERE X.DESCRICAO LIKE '%'||psCodPromocao||'%';
  
  IF vSeqPromocPDV > 0 THEN
  
  IF psComando = 'I' THEN
  
  UPDATE MFL_PROMOCAOPDV X SET X.STATUS = 'I' WHERE X.SEQPROMOCPDV = vSeqPromocPDV;
  
  ELSIF psComando = 'D' THEN
  
  DELETE FROM MFL_PROMOCPDVDESCAPARTDE A WHERE A.SEQPROMOCPDV = vSeqPromocPDV;
  DELETE FROM MFL_PROMOCPDVEMP B WHERE B.SEQPROMOCPDV = vSeqPromocPDV;
  DELETE FROM MFL_PROMOCPDVITEM C WHERE C.SEQPROMOCPDV = vSeqPromocPDV;
  DELETE FROM MFL_PROMOCAOPDV D WHERE D.SEQPROMOCPDV = vSeqPromocPDV;
  
  END IF;
  
    COMMIT;

  END IF;
  
  END;
END;
