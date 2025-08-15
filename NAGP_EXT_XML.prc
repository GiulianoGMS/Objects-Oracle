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
    
    -- Erros serao tratados na NAGP_EXT_XML_DIA no registro de logs

END;
