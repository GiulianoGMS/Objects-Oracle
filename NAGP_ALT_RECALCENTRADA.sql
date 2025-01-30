-- Chamada

BEGIN
-- Se precisar retornar, passar 'S' na variavel
  NAGP_ALT_RECALCENTRADA(vsIndRetornaPD => 'N');
  END;

-- Validando se deu bom
SELECT X.INDRECALCTRIBNFTRANSF, X.* FROM MAX_CODGERALOPER X WHERE  X.TIPDOCFISCAL IN ('T','D')AND TIPCGO = 'E';
SELECT * FROM MAX_PARAMETRO X WHERE PARAMETRO = 'FORMA_RECALC_TRIBUT';

CREATE OR REPLACE PROCEDURE NAGP_ALT_RECALCENTRADA (vsIndRetornaPD IN VARCHAR2) AS

-- Giuliano em 30/01/2025
-- Ticket 508223
-- Para retornar passar 'S' na variavel

BEGIN
  FOR t IN (SELECT * FROM MAX_CODGERALOPER X WHERE X.TIPDOCFISCAL IN ('T','D') AND X.TIPCGO = 'E')
    LOOP                                
        UPDATE MAX_CODGERALOPER X SET X.INDRECALCTRIBNFTRANSF = CASE WHEN vsIndRetornaPD = 'S' THEN NULL ELSE 'N' END
                                WHERE X.CODGERALOPER = T.CODGERALOPER;
    COMMIT;
    END LOOP;
  FOR t2 IN (SELECT * FROM MAX_PARAMETRO Z WHERE Z.PARAMETRO = 'FORMA_RECALC_TRIBUT')
    LOOP
      UPDATE MAX_PARAMETRO Z SET Z.VALOR = CASE WHEN vsIndRetornaPD = 'S' THEN 'P' ELSE 'C' END
                           WHERE Z.PARAMETRO  = T2.PARAMETRO
                             AND Z.NROEMPRESA = T2.NROEMPRESA
                             AND Z.GRUPO      = T2.GRUPO;
    COMMIT;
    END LOOP;
END;
                                
