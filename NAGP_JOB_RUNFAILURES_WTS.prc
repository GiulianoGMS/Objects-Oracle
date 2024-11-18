CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_JOB_RUNFAILURES_WTS AS

-- Criado por Giuliano em 10/11/2024
-- Chamado pelo job NAGJ_JOB_RUN_FAILURES quando ocorre erro na execucao de alguma rotina
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
      
      SELECT 
        REPLACE(TO_CHAR(XP.LOG_DATE, 'DD-MON-YYYY HH24:MI:SS'), ' ', '%20') AS DATA,
        REPLACE(SUBSTR(XP.JOB_NAME, 1, 100), ' ', '%20') AS JOB_NAME,
        REPLACE(REGEXP_REPLACE(REPLACE(XP.ERRORS, '-','x'), '[^a-zA-Z0-9\-]', ' '), ' ', '%20')||'...' AS ERROR,
        REPLACE(TO_CHAR(XP.INSTANCE_ID), ' ', '%20') AS INSTANCE
        
      FROM ALL_SCHEDULER_JOB_RUN_DETAILS XP
     WHERE TO_DATE(TO_CHAR(LOG_DATE, 'DD/MM/YYYY HH24:MI'), 'DD/MM/YYYY HH24:MI') 
        >=  SYSDATE - (10/1440) AND STATUS = 'FAILED' ORDER BY 1 DESC
        
    )
    LOOP
      BEGIN
        -- Montar o texto da mensagem
        VTEXT := '*Aviso:%20Houve%20falha%20de%20execução%20na(s)%20rotina(s)%20abaixo:*%0A%0A' ||
                 'Log_Date:%20'    || msg.DATA || '%0A' ||
                 'Job_Name:%20'    || msg.JOB_NAME || '%0A' ||
                 'Error:%20'       || msg.ERROR || '%0A' ||
                 'Instance_ID:%20' || msg.INSTANCE;

        -- Construir a URL
        VURL := 'http://api.callmebot.com/whatsapp.php?phone=#########&text=' || VTEXT || '&apikey=#####'; -- Whatsapp 
        --VURLT:= 'https://api.callmebot.com/telegram/group.php?apikey=############&text=' || VTEXT; -- Telegram

        -- Enviar a mensagem
        SELECT UTL_HTTP.REQUEST(VURL)  INTO VNLIXO  FROM DUAL;
        --SELECT UTL_HTTP.REQUEST(VURLT) INTO VNLIXOT FROM DUAL;

        DBMS_OUTPUT.PUT_LINE('Mensagem enviada com sucesso para o Job: ' || msg.JOB_NAME);

      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Erro ao enviar mensagem para o Job: ' || msg.JOB_NAME || ' - ' || SQLERRM||' - '|| vText);
      END;
    END LOOP;
  END;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro geral na execução do procedimento: ' || SQLERRM);
    
END;
