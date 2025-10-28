CREATE OR REPLACE PROCEDURE NAGP_WTS_V2_INVALIDOBJECTS (psNroTelefone NUMBER, psAPIKey VARCHAR2)

 AS
 
    vnLixo  VARCHAR2(5000);
    vText   VARCHAR2(4000);
    vUrl    VARCHAR2(4000);

    -- Criado por Giuliano em 10/09/2025
    -- Capta objetos invalidos e envia notificação pelo wts
    -- Whats: Envia msg pelo whatsapp pela API TextMeBot
    
    BEGIN
    FOR msg IN (
      
      SELECT DISTINCT 'NAGUMO PROD' DB, OWNER, OBJECT_NAME, OBJECT_TYPE, CREATED, LAST_DDL_TIME, STATUS
        FROM NAGV_INVALID_OBJECTS
        
      UNION ALL
        
      SELECT DISTINCT 'DW/BI' DB, OWNER, OBJECT_NAME, OBJECT_TYPE, CREATED, LAST_DDL_TIME, STATUS
        FROM NAGV_INVALID_OBJECTS_DW
    )
    LOOP
      
        -- Montar o texto da mensagem
        vText := '%F0%9F%9A%A8%20*Report:%20Existem%20objetos%20invalidos%20no%20banco:*%0A%0A' ||
                 '*Data Base:*%20'     || msg.DB || '%0A' ||
                 '*Owner:*%20'         || msg.OWNER         || '%0A' ||
                 '*Object Name:*%20'   || msg.OBJECT_NAME   || '%0A' ||
                 '*Object Type:*%20'   || msg.OBJECT_TYPE   || '%0A' ||
                 '*Created:*%20'       || msg.CREATED       || '%0A' ||
                 '*Last DDL Time:*%20' || msg.LAST_DDL_TIME || '%0A' ||
                 '*Status:*%20'        || msg.STATUS;

        -- Construir a URL
        vUrl := 'http://api.textmebot.com/send.php?recipient=+'||psNroTelefone||'&text=' || REPLACE(vText, ' ','%20') || '&apikey='||psAPIKey; -- Whatsapp 

        -- Enviar a mensagem
        SELECT UTL_HTTP.REQUEST(vUrl)  INTO vnLixo  FROM DUAL;

        DBMS_SESSION.SLEEP(10); -- Segura 10 segundos pra nao dar pau na API (nao considerar spam)        
        
    END LOOP;
    
END;
