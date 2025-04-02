-- Adicionar na PKG_MAD_DI > SP_CONSISTENFIMPORT, apos excluir inconsistencias

    -- Customizazao Nagumo
    -- Giuliano 02/04/25
    -- Critica DI caso existam despesas que nao geraram financeiro
    NAGP_CONSIST_DESP_IMP(pnNumeroDI);

-- Proc

CREATE OR REPLACE PROCEDURE NAGP_CONSIST_DESP_IMP (psNumeroDI IN MAD_DI.NUMERODI%TYPE) AS

BEGIN

DECLARE
  
  psNroProcesso MAD_DI.NROPROCIMPORTACAO%TYPE;
  psCountExiste NUMBER(10); 
  psAdiantamentos VARCHAR2(4000);
  
  BEGIN

  SELECT COUNT(1), MAX(X.NROPROCIMPORTACAO), LISTAGG(A.DESCTIPOADIANT, ', ') WITHIN GROUP (ORDER BY X.NROPROCIMPORTACAO) ADIANTAMENTOS
  INTO psCountExiste, psNroProcesso, psAdiantamentos
  FROM MAD_DI X INNER JOIN MAD_PILANCTOPAGTODESP P ON P.NROEMPRESA = X.NROEMPRESA AND P.NROPROCIMPORTACAO = X.NROPROCIMPORTACAO
                INNER JOIN MAD_PITIPOADIANTAMENTO A ON A.SEQTIPOADIANT = P.SEQTIPOADIANT
                
 WHERE NUMERODI = psNumeroDI
   AND VLRPAGTODESP > 0
   AND INDCREDITODEBITO = 'D'
   AND INDSITUACAO != 'T';

  IF psCountExiste > 0 THEN
  PKG_MAD_DI.SP_GRAVAINCONSISTIMPORT(psNumeroDI, 0, 0, 'N', 100, 'B','Existem despesas não lançadas no financeiro ( '
                                                                     ||psAdiantamentos||' ). Verifique!');
  END IF;
  
  END;
END;
