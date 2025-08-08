CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_SUPERTROCO_SALES_IMP (t IN NUMBER) AS

BEGIN

MERGE INTO CONSINCO.NAGT_SUPERTROCO_SALES tgt

USING NAGV_SUPERTROCO_SALES_IMP src
   ON (tgt."DTA_HORA"              = src."DTA_HORA"
  AND  tgt.PDV                 = src.PDV
  AND  tgt.OPERADOR            = src.OPERADOR
  AND  tgt.MEIO_DE_PAGAMENTO   = src.MEIO_DE_PAGAMENTO
  AND  tgt.NSU_ST              = src.NSU_ST
  AND  tgt.NSU_PDV             = src.NSU_PDV
  AND  tgt.LOJA                = src.LOJA
  AND  tgt.CNPJ                = src.CNPJ
  )

WHEN MATCHED THEN
  UPDATE SET
  tgt.VALOR = src.VALOR

WHEN NOT MATCHED THEN

  INSERT (
    "DATA"              ,
    HORA                ,
    DTA_HORA            ,
    PDV                 ,
    OPERADOR            ,
    MEIO_DE_PAGAMENTO   ,
    NSU_ST              ,
    NSU_PDV             ,
    VALOR               ,
    LOJA                ,
    CNPJ
  )
  VALUES (
    src.DATA,
    src.HORA,
    src.DTA_HORA,
    src.PDV,
    src.OPERADOR,
    src.MEIO_DE_PAGAMENTO,
    src.NSU_ST,
    src.NSU_PDV,
    src.VALOR,
    src.LOJA,
    src.CNPJ
  );

  COMMIT;

  /*BEGIN
    CONSINCO.NAGP_MOVEARQ_SUPERTROCO_MANUAl;
    END;*/

 END;
