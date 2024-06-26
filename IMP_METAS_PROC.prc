CREATE OR REPLACE PROCEDURE IMP_METAS_PROC (t IN NUMBER) AS
-- Adicionei a variavel 't number' só pra chamada na query view dar certo  
BEGIN

 DECLARE
 ctDup NUMBER(10);

BEGIN

 DELETE FROM IMP_METAS_TEMP WHERE 1=1;
 INSERT INTO IMP_METAS_TEMP SELECT * FROM IMPV_METAS;

 COMMIT;
 
 SELECT COUNT(1) 
   INTO ctDup
   FROM IMPV_METAS_DUP;
   
 IF ctDup = 0 THEN
 
MERGE INTO DWNAGT_METAVENDA_NIVEIS tgt

USING IMP_METAS_TEMP src
   ON (tgt."DATA" = src."DATA"
  AND  tgt.NRO_EMPRESA = src.NRO_EMPRESA
  AND  tgt.CATEGORIA_NIVEL_1 = src.CATEGORIA_NIVEL_1
  AND  tgt.CATEGORIA_NIVEL_2 = src.CATEGORIA_NIVEL_2
  AND  tgt.CATEGORIA_NIVEL_3 = src.CATEGORIA_NIVEL_3
  AND  tgt.SEGMENTO          = src.SEGMENTO
  )

WHEN NOT MATCHED THEN

  INSERT (
    "DATA",
    NRO_EMPRESA,
    CATEGORIA_NIVEL_1,
    CATEGORIA_NIVEL_2,
    CATEGORIA_NIVEL_3,
    "META DE FATURAMENTO",
    "META DE LUCRATIVIDADE",
 -- "META DE MARGEM",
 -- "META DE PERDAS",
    SEGMENTO
  )
  VALUES (
    src."DATA",
    src.NRO_EMPRESA,
    src.CATEGORIA_NIVEL_1,
    src.CATEGORIA_NIVEL_2,
    src.CATEGORIA_NIVEL_3,
    src."META DE FATURAMENTO",
    src."META DE LUCRATIVIDADE",
 -- src."META DE MARGEM",
 -- src."META DE PERDAS",
    src.SEGMENTO
  );
  COMMIT;
  END IF;
  
 END;
END IMP_METAS_PROC;
