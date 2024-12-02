CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_GERA_ARQ_CD_TODEP2 (EMPRESA NUMBER) AS

    V_RAW1 RAW(20000);
    V_TARGETCHARSET VARCHAR2(40 BYTE);
    V_DBCHARSET VARCHAR2(40 BYTE);
    SAIDA UTL_FILE.FILE_TYPE;

    CURSOR CUR_LINHA IS
        SELECT X.LOCAL AS LOCAL,
               X.COD_COMPLETO AS LINHA,
               0,
               X.NROEMPRESA
          FROM CONSINCO.NAGV_COMPCD_TODEP X
         WHERE X.NROEMPRESA = EMPRESA;

    V_ATUAL_LOCAL VARCHAR2(100); -- Armazena o LOCAL atual
BEGIN
    V_DBCHARSET := 'AMERICAN_AMERICA.AL32UTF8';
    V_TARGETCHARSET := 'AMERICAN_AMERICA.WE8MSWIN1252';

    FOR REG_LINHA IN CUR_LINHA LOOP
        -- Verifica se mudou de LOCAL para criar novo arquivo
        IF V_ATUAL_LOCAL IS NULL OR V_ATUAL_LOCAL != REG_LINHA.LOCAL THEN
            -- Fecha o arquivo anterior se já estava aberto
            IF V_ATUAL_LOCAL IS NOT NULL THEN
                UTL_FILE.FCLOSE(SAIDA);
            END IF;

            -- Abre novo arquivo para o LOCAL atual
            SAIDA := UTL_FILE.FOPEN(
                '/u02/app_acfs/arquivos/ocorrencias/Inventario_CD/Movimentacoes_Finais/Pos',
                EMPRESA||' DE_OCORRENCIAS_PARA_' || EMPRESA || '.TXT',
                'W'
            );

            V_ATUAL_LOCAL := REG_LINHA.LOCAL;
        END IF;

        -- Converte e grava a linha no arquivo atual
        V_RAW1 := UTL_RAW.CAST_TO_RAW(REG_LINHA.LINHA);
        V_RAW1 := UTL_RAW.CONVERT(V_RAW1, V_DBCHARSET, V_TARGETCHARSET);
        UTL_FILE.PUT_LINE(SAIDA, UTL_RAW.CAST_TO_VARCHAR2(V_RAW1));
    END LOOP;

    -- Fecha o último arquivo aberto
    IF V_ATUAL_LOCAL IS NOT NULL THEN
        UTL_FILE.FCLOSE(SAIDA);
    END IF;

    DBMS_OUTPUT.PUT_LINE('Arquivos gerados com sucesso!');

END;
