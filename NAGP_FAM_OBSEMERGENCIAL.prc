CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_FAM_OBSEMERGENCIAL AS

-- Criado por Giuliano em 20/01/2025
-- TIcket 519384

BEGIN
  -- Acrescenta nas familias das tributacoes do De/Para que ainda não possuem a informacao
  FOR t IN (SELECT Z.SEQFAMILIA, Z.OBSEMERGENCIAL 
              FROM MAP_FAMILIA Z INNER JOIN MAP_FAMDIVISAO F ON F.SEQFAMILIA = Z.SEQFAMILIA
                                 INNER JOIN NAGT_DEPARA_519384_TRIB T ON T.NROTRIBUTACAO = F.NROTRIBUTACAO
             WHERE TRIM(Z.OBSEMERGENCIAL) IS NULL)
  LOOP 
    UPDATE MAP_FAMILIA Z SET Z.OBSEMERGENCIAL   = 'Mercadoria enquadrada no inciso I do parágrafo único do art. 22 da Lei 11 2.6571/96',
                             Z.USUARIOALTERACAO = 'TKT519384',
                             Z.DTAHORALTERACAO  = SYSDATE
                       WHERE Z.SEQFAMILIA       = T.SEQFAMILIA;
  COMMIT;
  END LOOP;
  -- Remove das familias que nao estão com as tributações do De/Para
  FOR t2 IN (SELECT Z.SEQFAMILIA, Z.OBSEMERGENCIAL 
               FROM MAP_FAMILIA Z INNER JOIN MAP_FAMDIVISAO F ON F.SEQFAMILIA = Z.SEQFAMILIA
              WHERE Z.OBSEMERGENCIAL IS NOT NULL
                AND NOT EXISTS (SELECT 1 FROM NAGT_DEPARA_519384_TRIB X WHERE X.NROTRIBUTACAO = F.NROTRIBUTACAO))
  LOOP
    UPDATE MAP_FAMILIA Z SET Z.OBSEMERGENCIAL   = NULL,
                             Z.USUARIOALTERACAO = 'TKT519384',
                             Z.DTAHORALTERACAO  = SYSDATE
                       WHERE Z.SEQFAMILIA       = T2.SEQFAMILIA;
  COMMIT;
  END LOOP;
  
END;
