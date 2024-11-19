CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_INVALIDOBJECTS_WTS AS

-- Criado por Giuliano em 19/11/2024
-- Capta objetos invalidos e envia notificação pelo wts
-- Whats: Envia msg pelo whatsapp pela API CallMeBot

BEGIN
  DECLARE
    VNLIXO  VARCHAR2(5000);
    --VNLIXOT VARCHAR2(5000);
    VTEXT   VARCHAR2(4000);
    VURL    VARCHAR2(4000);
    --VURLT   VARCHAR2(4000);
  BEGIN
    FOR msg IN (
      
      SELECT OWNER, OBJECT_NAME, OBJECT_TYPE, CREATED, LAST_DDL_TIME, STATUS
        FROM NAGV_INVALID_OBJECTS
    )
    LOOP
      BEGIN
        -- Montar o texto da mensagem
        VTEXT := '%F0%9F%9A%A8%20*Report:%20Existem%20objetos%20invalidos%20no%20banco:*%0A%0A' ||
                 '*Owner:*%20'         || msg.OWNER         || '%0A' ||
                 '*Object Name:*%20'   || msg.OBJECT_NAME   || '%0A' ||
                 '*Object Type:*%20'   || msg.OBJECT_TYPE   || '%0A' ||
                 '*Created:*%20'       || msg.CREATED       || '%0A' ||
                 '*Last DDL Time:*%20' || msg.LAST_DDL_TIME || '%0A' ||
                 '*Status:*%20'        || msg.STATUS;

        -- Construir a URL
        VURL := 'http://api.callmebot.com/whatsapp.php?phone=####&text=' || REPLACE(VTEXT, ' ','%20') || '&apikey=#####'; -- Whatsapp 
        --VURLT:= 'https://api.callmebot.com/telegram/group.php?apikey=############&text=' || VTEXT; -- Telegram

        -- Enviar a mensagem
        SELECT UTL_HTTP.REQUEST(VURL)  INTO VNLIXO  FROM DUAL;
        --SELECT UTL_HTTP.REQUEST(VURLT) INTO VNLIXOT FROM DUAL;

        DBMS_OUTPUT.PUT_LINE('Mensagem enviada com sucesso para o Objeto: ' || msg.OBJECT_NAME);

      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Erro ao enviar mensagem para o Objeto: ' || msg.OBJECT_NAME || ' - ' || SQLERRM||' - '|| vText);
      END;
    END LOOP;
  END;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro geral na execução do procedimento: ' || SQLERRM);
    
END;
