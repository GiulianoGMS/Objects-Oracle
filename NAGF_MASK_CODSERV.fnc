CREATE OR REPLACE FUNCTION NAGF_MASK_CODSERV(psCodServ IN VARCHAR2,
                                                      psCidade  IN VARCHAR2)
       RETURN VARCHAR2 IS
       vsCidade   VARCHAR2(30);
       Qtde       NUMBER;
       vsMask     VARCHAR2(30);
       vsRetorno  VARCHAR2(30);
       psServTrat VARCHAR2(30);

BEGIN
       psServTrat := REPLACE(psCodServ, '.','');

       SELECT LENGTH(REPLACE(psServTrat, ' ', ''))
         INTO Qtde
         FROM DUAL;

          IF Qtde = 3
        THEN vsMask := SUBSTR(REPLACE(psServTrat, ' ', ''), 1, 1) || '.' ||
                       SUBSTR(REPLACE(psServTrat, ' ', ''), 2, 2);
       ELSIF Qtde = 4
        THEN vsMask := SUBSTR(REPLACE(psServTrat, ' ', ''), 1, 2) || '.' ||
                       SUBSTR(REPLACE(psServTrat, ' ', ''), 3, 2);
        ELSE vsMask := REPLACE(psCodServ, ' ', '');

       END IF;
       IF psCidade IN ('GUARULHOS', '...')
         THEN
           vsRetorno := psServTrat;
       ELSE
           vsRetorno := vsMask;
       END IF;

       RETURN(vsRetorno);
EXCEPTION
       WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20200, SQLERRM);

END;
