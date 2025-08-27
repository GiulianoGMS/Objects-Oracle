CREATE OR REPLACE PROCEDURE NAGP_TB_LOGFALHACARGAMONITOR_WTS AS

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

      SELECT DISTINCT
             X.SEQLOG,
             X.TABELA,
             X.DTAHOREMISSAO,
             X.TIPOCARGA,
             X.MENSAGEM,
             X.REPLICACAO
        FROM MONITORPDV.TB_LOGFALHACARGAMONITOR X
    )
    LOOP
      BEGIN
        -- Montar o texto da mensagem
        VTEXT := '%F0%9F%9A%A8%20*Report:%20Existem%20Erros%20na%20Carga%20Monitor:*%0A%0A' ||
                 '*SeqLog:*%20'     || msg.SEQLOG        || '%0A' ||
                 '*Tabela:*%20'     || msg.TABELA        || '%0A' ||
                 '*Data:*%20'       || msg.DTAHOREMISSAO || '%0A' ||
                 '*TipoCarga:*%20'  || msg.TIPOCARGA     || '%0A' ||
                 '*Mensagem:*%20'   || msg.MENSAGEM      || '%0A' ||
                 '*Replicacao:*%20' || msg.REPLICACAO;

        -- Construir a URL
        VURL := 'http://api.callmebot.com/whatsapp.php?phone=5511986260031text=' || REPLACE(VTEXT, ' ','%20') || 'apikey='; -- Whatsapp
        --VURLT:= 'https://api.callmebot.com/telegram/group.php?apikey=############&text=' || VTEXT; -- Telegram

        -- Enviar a mensagem
        SELECT UTL_HTTP.REQUEST(VURL)  INTO VNLIXO  FROM DUAL;
        --SELECT UTL_HTTP.REQUEST(VURLT) INTO VNLIXOT FROM DUAL;

        DBMS_OUTPUT.PUT_LINE('Mensagem enviada com sucesso para o Objeto: ' || msg.SEQLOG);

      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Erro ao enviar mensagem para o Objeto: ' || msg.SEQLOG || ' - ' || SQLERRM||' - '|| vText);
      END;
    END LOOP;
  END;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro geral na execução do procedimento: ' || SQLERRM);

END;
