CREATE OR REPLACE FUNCTION CONSINCO.NAGF_EAN13(P_CODIGO_BARRA IN VARCHAR2) RETURN VARCHAR2 IS
 -- Criado por Giuliano para obter o EAN com Dig Verificador para Cadastro de Cestas
  V_SOMA     NUMBER;
  V_MULTIPLO NUMBER;
  V_TEMP     VARCHAR2(18); -- Declare a local variable to store the modified value
BEGIN
  IF LENGTH(P_CODIGO_BARRA) != 6 THEN  -- deve ter 6 caracteres
    RETURN 'N';
  END IF;

  -- Concatenar '9' + p_codigo_barra + p_codigo_barra
  V_TEMP := '9' || P_CODIGO_BARRA || P_CODIGO_BARRA;

  FOR I IN 1..12 LOOP  -- soma o que é par e ímpar
    IF MOD(I, 2) = 0 THEN
      V_MULTIPLO := 3;
    ELSE
      V_MULTIPLO := 1;
    END IF;
    V_SOMA := NVL(V_SOMA, 0) + TO_NUMBER(SUBSTR(V_TEMP, I, 1)) * V_MULTIPLO;
  END LOOP;

  IF MOD(V_SOMA, 10) = 0 THEN
    V_SOMA := 0;
  ELSE
    V_SOMA := 10 - MOD(V_SOMA, 10);
  END IF;

  RETURN SUBSTR(V_TEMP, 1, 12) || TO_CHAR(V_SOMA);
END;
