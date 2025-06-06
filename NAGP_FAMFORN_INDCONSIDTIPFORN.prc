CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_FAMFORN_INDCONSIDTIPFORN AS

-- Criado por Giuliano em 20/01/2025
-- TIcket 518422

BEGIN
  
  FOR t IN (SELECT SEQFAMILIA, SEQFORNECEDOR FROM MAP_FAMFORNEC Z WHERE NVL(Z.INDCONSIDTIPFORNCGO,'N') = 'N' AND LENGTH(SEQFAMILIA) < 10)
  LOOP 
    UPDATE MAP_FAMFORNEC Z SET Z.INDCONSIDTIPFORNCGO = 'S',
                               Z.USUARIOALTERACAO    = 'TKT518422',
                               Z.DATAHORAALTERACAO   = SYSDATE
                         WHERE Z.SEQFAMILIA          = T.SEQFAMILIA
                           AND Z.SEQFORNECEDOR       = T.SEQFORNECEDOR;
  COMMIT;
  END LOOP;
  
END;


