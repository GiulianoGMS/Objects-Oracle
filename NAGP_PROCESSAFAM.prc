CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_PROCESSAFAM AS

BEGIN
  DECLARE
   pnInseriuInconsist INTEGER;
  BEGIN
   pnInseriuInconsist := 0; -- Saida por causa da proc

FOR t IN (SELECT SEQFAMILIA FROM MAP_FAMILIA X WHERE TRUNC(X.DTAHORALTERACAO) = TRUNC(SYSDATE))
  
    LOOP
      PKG_INCONSISTENCIAS.SP_INICIAPROCESSO_FAM(psTipoGeracao      => 'L', -- Lista de Familias, possivel utilizar L = Familia, D = Alteracoes do dia ou T = Tudo
                                                psListaSeqFamilia  => T.SEQFAMILIA,
                                                pdDtaBase          => SYSDATE,
                                                psUsuAlteracao     => 'AUTO',
                                                pnDiasValidadeNCM  => 9999,
                                                pnInseriuInconsist => pnInseriuInconsist);
     COMMIT;
     END LOOP;
     
  END;
END;
