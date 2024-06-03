CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_EXTDBMONITOR_INV_OBJ as
  -- Importa sessoes ativas
  v_file      UTL_FILE.file_type;
  v_line      VARCHAR2(32767);
  v_Cabecalho VARCHAR2(4000);

BEGIN
  -- Abre o arquivo para escrita
  v_file := UTL_FILE.fopen('/u02/app_acfs/arquivos/dbmonitor',
                           'db_invalid_objects.csv',
                           'w',
                           32767);

  SELECT LISTAGG(COLUMN_NAME, ';') WITHIN GROUP(ORDER BY COLUMN_ID)
    INTO v_Cabecalho
    FROM ALL_TAB_COLUMNS A
   WHERE A.table_name = 'NAGV_INVALID_OBJECTS';

  -- Dados para extracao
  FOR rec IN (SELECT OWNER,
                     OBJECT_NAME,
                     SUBOBJECT_NAME,
                     OBJECT_ID,
                     DATA_OBJECT_ID,
                     OBJECT_TYPE,
                     CREATED,
                     LAST_DDL_TIME,
                     TIMESTAMP,
                     STATUS,
                     TEMPORARY,
                     GENERATED,
                     SECONDARY,
                     NAMESPACE,
                     EDITION_NAME,
                     SHARING,
                     EDITIONABLE,
                     ORACLE_MAINTAINED,
                     APPLICATION,
                     DEFAULT_COLLATION,
                     DUPLICATED,
                     SHARDED,
                     CREATED_APPID,
                     CREATED_VSNID,
                     MODIFIED_APPID,
                     MODIFIED_VSNID
                FROM CONSINCO.NAGV_INVALID_OBJECTS Z) LOOP
    -- Constrói a linha de texto a ser gravada no arquivo
    v_line := rec.OWNER||';'||
                     rec.OBJECT_NAME||';'||
                     rec.SUBOBJECT_NAME||';'||
                     rec.OBJECT_ID||';'||
                     rec.DATA_OBJECT_ID||';'||
                     rec.OBJECT_TYPE||';'||
                     rec.CREATED||';'||
                     rec.LAST_DDL_TIME||';'||
                     rec.TIMESTAMP||';'||
                     rec.STATUS||';'||
                     rec.TEMPORARY||';'||
                     rec.GENERATED||';'||
                     rec.SECONDARY||';'||
                     rec.NAMESPACE||';'||
                     rec.EDITION_NAME||';'||
                     rec.SHARING||';'||
                     rec.EDITIONABLE||';'||
                     rec.ORACLE_MAINTAINED||';'||
                     rec.APPLICATION||';'||
                     rec.DEFAULT_COLLATION||';'||
                     rec.DUPLICATED||';'||
                     rec.SHARDED||';'||
                     rec.CREATED_APPID||';'||
                     rec.CREATED_VSNID||';'||
                     rec.MODIFIED_APPID||';'||
                     rec.MODIFIED_VSNID;
  
    -- Escreve a linha no arquivo
    UTL_FILE.put_line(v_file, v_line);
  END LOOP;

  -- Fecha o arquivo
  UTL_FILE.fclose(v_file);
EXCEPTION
  WHEN OTHERS THEN
  
    DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
    IF UTL_FILE.is_open(v_file) THEN
      UTL_FILE.fclose(v_file);
    END IF;
END;
