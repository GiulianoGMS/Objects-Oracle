CREATE OR REPLACE PROCEDURE NAGP_EXT_XML (psChave       VARCHAR2,
                                          psDescricaoNF VARCHAR2 DEFAULT 'NFe',
                                          psDiretorio   VARCHAR2,
                                          psNoveView    VARCHAR2)
                                          
 -- Criado por Cipolla, extração de XML para pasta, mediante ID da Nota.
 -- Alt Giuliano 14/08/2025 -- Inclui Diretorio e View como parametros dinamicos pra nao ficar criando varios objetos
 AS
    psChave_Acesso  VARCHAR2(1000);
    psXML           CLOB;
    psSQL           VARCHAR2(32767);
    
BEGIN
    psSQL := 'SELECT CHAVE_ACESSO, XML ' ||
             'FROM ' || psNoveView || ' WHERE CHAVE_ACESSO = :chave FETCH FIRST 1 ROWS ONLY';

    EXECUTE IMMEDIATE psSQL
        INTO psChave_Acesso, psXML
        USING psChave;

    DBMS_XSLPROCESSOR.CLOB2FILE(
        psXML,
        psDiretorio,
        psDescricaoNF||'_'||psChave_Acesso || '.xml'
    );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum registro encontrado para ID ' || psChave);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Problemas na geração do arquivo: ' || SQLERRM);
END;
