-- Proc criada pela Consinco, Loop por Giuliano - 03/12/2024 - Ticket XXXXXXXX

BEGIN
  FOR t IN (SELECT NROEMPRESA FROM CONSINCO.MAX_EMPRESA X WHERE NROEMPRESA = 41)
    LOOP
  CONSINCO.NAGP_IMPTESOURARIA(T.NROEMPRESA);
    END LOOP;
END;

-- Proc

CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_IMPTESOURARIA (Vnempresa IN NUMBER) AS

BEGIN
DECLARE
  Vnsucesso NUMBER(1);
  Vserro VARCHAR2(400);
  --Vnempresa NUMBER(6) := 41; ---- USAR ESSE WHERE QUANDO FOR DEIXAR FIXO SÓ UMA EMPRESA
BEGIN

  FOR t IN (SELECT DISTINCT a.Nrocheckout, a.Dtaabertura, a.Nroempresa,
                            b.Nroempresamae
              FROM Mfl_Financeiro a, Fi_Parametro b
             WHERE a.Nroempresa = b.Nroempresa
               AND a.Nroempresa = Nvl(Vnempresa, a.Nroempresa)
               AND a.Dtaabertura = Trunc(SYSDATE) - 1 ---remover -1 para pegar a DTA do dia
             GROUP BY a.Nrocheckout, a.Dtaabertura, a.Nroempresa,
                      b.Nroempresamae
             ORDER BY 2, 3, 1)
  LOOP
    Pkg_Novatesouraria.Fip_Tsn_Importacaofrentes(t.Dtaabertura,
                                                 t.Nrocheckout, t.Nroempresa,
                                                 t.Nroempresamae,
                                                 'CONSINCO', 's',
                                                 'N', 'ACRUX-PDV',
                                                 'Impautomatica',
                                                 Vnsucesso, Vserro);

    IF Vnsucesso = 1 THEN
      COMMIT;
    ELSE
      ROLLBACK;
    END IF;
  END LOOP;
END;
END;
