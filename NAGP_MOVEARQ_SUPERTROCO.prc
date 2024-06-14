CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_MOVEARQ_SUPERTROCO AS

BEGIN
  
DECLARE
  src_file  UTL_FILE.FILE_TYPE;
  dest_file UTL_FILE.FILE_TYPE;
  buffer    VARCHAR2(32767);
  vDta VARCHAR2(50);
BEGIN
  vDta := REPLACE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'),'/','');
  -- Abrir o arquivo original para leitura
  src_file := UTL_FILE.FOPEN('SUPERTROCO', 'salesasync.csv', 'R');

  -- Abrir um novo arquivo para escrita com o novo nome
  dest_file := UTL_FILE.FOPEN('/u02/dados/SUPERTROCO/Sales/BKP', 'SalesAsync_'||vDta||'.csv', 'W');

  -- Loop para ler cada linha do arquivo original e escrever no novo arquivo
  LOOP
    BEGIN
      UTL_FILE.GET_LINE(src_file, buffer);
      UTL_FILE.PUT_LINE(dest_file, buffer);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        EXIT;
    END;
  END LOOP;

  -- Fechar ambos os arquivos
  UTL_FILE.FCLOSE(src_file);
  UTL_FILE.FCLOSE(dest_file);

  -- Remover o arquivo original
  UTL_FILE.FREMOVE('SUPERTROCO', 'salesasync.csv');

END;
END;


-- Manual

CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_MOVEARQ_SUPERTROCO_MANUAL (t NUMBER) AS

BEGIN
  
DECLARE
  src_file  UTL_FILE.FILE_TYPE;
  dest_file UTL_FILE.FILE_TYPE;
  buffer    VARCHAR2(32767);
  vDta VARCHAR2(50);
BEGIN
  vDta := REPLACE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'),'/','');
  -- Abrir o arquivo original para leitura
  src_file := UTL_FILE.FOPEN('SUPERTROCO', 'salesasync.csv', 'R');

  -- Abrir um novo arquivo para escrita com o novo nome
  dest_file := UTL_FILE.FOPEN('/u02/dados/SUPERTROCO/Sales/BKP', 'SalesAsync_Manual.csv', 'W');

  -- Loop para ler cada linha do arquivo original e escrever no novo arquivo
  LOOP
    BEGIN
      UTL_FILE.GET_LINE(src_file, buffer);
      UTL_FILE.PUT_LINE(dest_file, buffer);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        EXIT;
    END;
  END LOOP;

  -- Fechar ambos os arquivos
  UTL_FILE.FCLOSE(src_file);
  UTL_FILE.FCLOSE(dest_file);

  -- Remover o arquivo original
  UTL_FILE.FREMOVE('SUPERTROCO', 'salesasync.csv');

END;
END;
