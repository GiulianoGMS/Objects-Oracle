CREATE OR REPLACE PROCEDURE NAGP_PALIATIVO_CCT_CENARIOCONDITEM_PDV AS

BEGIN
  FOR bsErro IN (SELECT * FROM MONITORPDV.TBE_CCTCENARIOCONDICAOITEM)
    LOOP
      UPDATE MONITORPDV.TB_CCTCENARIOCONDICAOITEM C SET C.SEQCENARIOCONDICAOITEM = bsErro.Seqcenariocondicaoitem  
                                                  WHERE C.VALOR                  = bsErro.Valor 
                                                    AND C.SEQCENARIO             = bsErro.Seqcenario
                                                    AND C.SEQCENARIOCONDICAO     = bsErro.Seqcenariocondicao;
    COMMIT;
    END LOOP;
END;

