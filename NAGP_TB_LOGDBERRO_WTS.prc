CREATE OR REPLACE PROCEDURE NAGP_TB_LOGDBERRO_WTS AS

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

      SELECT Y.DTAHOREVENTO,
             Y.USERNAME,
             Y.NLSLANG,
             Y.IPCLIENT,
             Y.OSUSER,
             Y.TERMINAL,
             Y.MODULO,
             Y.IDENTIFIER,
             Y.MSGERRO,
             Y.ACTION,
             Y.SQLERRO 
        FROM MONITORPDV.TB_LOGDBERRO Y
    )
    LOOP
      BEGIN
        -- Montar o texto da mensagem
        VTEXT := '%F0%9F%9A%A8%20*Report:%20Existem%20Erros%20na%20Carga%20Monitor:*%0A%0A' ||
                 '*Data Evento:*%20' || msg.DTAHOREVENTO || '%0A' ||
                 '*Username:*%20'    || msg.USERNAME     || '%0A' ||
                 '*NlsLang:*%20'     || msg.NLSLANG      || '%0A' ||
                 '*IpcClient:*%20'   || msg.IPCLIENT     || '%0A' ||
                 '*OsUser:*%20'      || msg.OSUSER       || '%0A' ||
                 '*Terminal:*%20'    || msg.TERMINAL     || '%0A' ||
                 '*Modulo:*%20'      || msg.MODULO       || '%0A' ||
                 '*Identifier:*%20'  || msg.IDENTIFIER   || '%0A' ||
                 '*MsgErro:*%20'     || msg.MSGERRO      || '%0A' ||
                 '*Action:*%20'      || msg.ACTION       || '%0A' ||
                 '*SqlErro:*%20'     || msg.SQLERRO;

        -- Construir a URL
        VURL := 'http://api.callmebot.com/whatsapp.php?phone=5511986260031text=' || REPLACE(VTEXT, ' ','%20') || 'apikey='; -- Whatsapp
        --VURLT:= 'https://api.callmebot.com/telegram/group.php?apikey=############&text=' || VTEXT; -- Telegram

        -- Enviar a mensagem
        SELECT UTL_HTTP.REQUEST(VURL)  INTO VNLIXO  FROM DUAL;
        --SELECT UTL_HTTP.REQUEST(VURLT) INTO VNLIXOT FROM DUAL;

        DBMS_OUTPUT.PUT_LINE('Mensagem enviada com sucesso para o Objeto: ' || msg.IDENTIFIER);

      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Erro ao enviar mensagem para o Objeto: ' || msg.IDENTIFIER || ' - ' || SQLERRM||' - '|| vText);
      END;
    END LOOP;
  END;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro geral na execução do procedimento: ' || SQLERRM);

END;
