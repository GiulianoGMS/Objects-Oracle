CREATE OR REPLACE PROCEDURE NAGP_INSERECATEG_SELOS (vSeqFamilia IN NUMBER)

AS

BEGIN
  FOR t IN (SELECT *
  FROM MAP_FAMILIA F WHERE SEQFAMILIA IN (vSeqFamilia)
 
 AND NOT EXISTS(SELECT 1 FROM MAP_FAMDIVCATEG ZZ WHERE ZZ.SEQFAMILIA = F.SEQFAMILIA AND ZZ.SEQCATEGORIA = 46747))   
  LOOP
      INSERT INTO MAP_FAMDIVCATEG V  (SELECT T.SEQFAMILIA,
                                                   VL.SEQCATEGORIA,
                                                   VL.NRODIVISAO,
                                                   'A',
                                                   VL.INDREPLICACAO,
                                                   VL.INDGEROUREPLICACAO,
                                                   VL.DTABASEEXPORTACAO,
                                                   VL.NROBASEEXPORTACAO,
                                                   VL.DATAHORAALTERACAO,
                                                   VL.DATAHORAINTEGRAECOMMERCE,
                                                   'SELOS',
                                                   VL.SEQCORRESPONDENCIA, NULL FROM MAP_FAMDIVCATEG VL WHERE VL.SEQCATEGORIA = 46747 AND VL.SEQFAMILIA = 20407); -- Base
     COMMIT;
     END LOOP;
END;

