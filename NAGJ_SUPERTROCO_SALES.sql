DECLARE
  vPassou VARCHAR2(1);
  vErro   VARCHAR2(400);
BEGIN
  -- Importa o arquivo salesasyc.csv para a tabela
  vPassou := 'N';
  BEGIN
  CONSINCO.NAGP_SUPERTROCO_SALES_IMP(1);
  vPassou := 'S';
  
  EXCEPTION
    WHEN OTHERS THEN
  vPassou := 'N';
  vErro   := SQLERRM;
    INSERT INTO CONSINCO.NAGT_SUPERTROCO_SALES_IMP_LOG VALUES(SYSDATE, vErro);
  END;
  
  IF vPassou = 'S' THEN
  -- Se a importação der certo, movimenta o arquivo
  -- Movimenta o arquivo ajustado para a pasta de bkp
  CONSINCO.NAGP_MOVEARQ_SUPERTROCO;
  END IF;
  
END;
