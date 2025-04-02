CREATE OR REPLACE PROCEDURE NAGP_LOCKS_WTS AS

-- Criado por Giuliano em 01/04/2025
-- Chamado pelo job NAGJ_JOB_RUN_FAILURES quando ocorre erro na execucao de alguma rotina
-- Envia msg pelo whatsapp pela API CallMeBot

BEGIN
  DECLARE
    VNLIXO  VARCHAR2(5000);
    --VNLIXOT VARCHAR2(5000);
    VTEXT   VARCHAR2(4000);
    VURL    VARCHAR2(4000);
    l_response VARCHAR2(4000);
    --VURLT   VARCHAR2(4000);
  BEGIN
    FOR msg IN (
       SELECT REPLACE(TO_CHAR(W.INST_ID), ' ', '%20')    INST_ID_BLOQUEADO,
       REPLACE(TO_CHAR(W.SID), ' ', '%20')               SESSAO_BLOQUEADA,
       REPLACE(TO_CHAR(W.SERIAL#), ' ', '%20')           SERIAL_BLOQUEADA,
       REPLACE(W.USERNAME, ' ', '%20')                   USUARIO_BLOQUEADO,
       REPLACE(W.STATUS, ' ', '%20')                     STATUS_BLOQUEADO,
       REPLACE(W.OSUSER, ' ', '%20')                     OSUSER_BLOQUEADO,
       REPLACE(W.MACHINE, ' ', '%20')                    MAQUINA_BLOQUEADA,
       REPLACE(W.PROGRAM, ' ', '%20')                    PROGRAMA_BLOQUEADO,
       REPLACE(TO_CHAR(TRUNC((SYSDATE - W.SQL_EXEC_START) * 1440)) || ' min', ' ', '%20') DURACAO_BLOQUEADO,       
       REPLACE(TO_CHAR(B.INST_ID), ' ', '%20')           INST_ID_BLOQUEADORA,
       REPLACE(TO_CHAR(B.SID), ' ', '%20')               SESSAO_BLOQUEADORA,
       REPLACE(TO_CHAR(B.SERIAL#), ' ', '%20')           SERIAL_BLOQUEADORA,
       REPLACE(B.USERNAME, ' ', '%20')                   USUARIO_BLOQUEADOR,
       REPLACE(B.STATUS, ' ', '%20')                     STATUS_BLOQUEADOR,
       REPLACE(B.OSUSER, ' ', '%20')                     OSUSER_BLOQUEADOR,
       REPLACE(B.MACHINE, ' ', '%20')                    MAQUINA_BLOQUEADORA,
       REPLACE(B.PROGRAM, ' ', '%20')                    PROGRAMA_BLOQUEADOR,
       REPLACE(TO_CHAR(B.LOGON_TIME, 'DD/MM/YYYY HH24:MI:SS'), ' ', '%20') LOGON_TIME_BLOQUEADOR,
       REPLACE(W.EVENT, ' ', '%20')                      EVENTO_ESPERA_BLOQUEADO,
       REPLACE(B.EVENT, ' ', '%20')                      EVENTO_BLOQUEADOR
       
  FROM GV$SESSION W INNER JOIN GV$SESSION B ON W.BLOCKING_SESSION = B.SID
  
  WHERE w.last_call_et >= 1800 -- Filtra sessões bloqueadas por mais de 30 minutos
  
 ORDER BY W.LAST_CALL_ET DESC

    )
    LOOP
      BEGIN
        -- Montar o texto da mensagem
        VTEXT := '%F0%9F%9A%A8%20*Report:%20Sess%C3%A3o%20bloqueada%20detectada:*%0A%0A' ||

                     '*Sess%C3%A3o%20bloqueadora:*%20' || msg.SESSAO_BLOQUEADORA || 
                     '%20(User:%20' || msg.USUARIO_BLOQUEADOR || ')%0A' ||
                     '*Serial:*%20' || msg.SERIAL_BLOQUEADORA || '%0A' ||
                     '*Status:*%20' || msg.STATUS_BLOQUEADOR || '%0A' ||
                     '*OSUser:*%20' || msg.OSUSER_BLOQUEADOR || '%0A' ||
                     '*M%C3%A1quina:*%20' || msg.MAQUINA_BLOQUEADORA || '%0A' ||
                     '*Programa:*%20' || msg.PROGRAMA_BLOQUEADOR || '%0A' ||
                     '*Logon:*%20' || msg.LOGON_TIME_BLOQUEADOR || '%0A%0A' ||

                     '*Sess%C3%A3o%20bloqueada:*%20' || msg.SESSAO_BLOQUEADA || 
                     '%20(User:%20' || msg.USUARIO_BLOQUEADO || ')%0A' ||
                     '*Serial:*%20' || msg.SERIAL_BLOQUEADA || '%0A' ||
                     '*Status:*%20' || msg.STATUS_BLOQUEADO || '%0A' ||
                     '*OSUser:*%20' || msg.OSUSER_BLOQUEADO || '%0A' ||
                     '*M%C3%A1quina:*%20' || msg.MAQUINA_BLOQUEADA || '%0A' ||
                     '*Programa:*%20' || msg.PROGRAMA_BLOQUEADO || '%0A' ||
                     '*Dura%C3%A7%C3%A3o:*%20' || msg.DURACAO_BLOQUEADO || '%0A' ||
                     '*Evento%20de%20espera:*%20' || msg.EVENTO_ESPERA_BLOQUEADO || '%0A' ||
                     '*Evento%20bloqueador:*%20' || msg.EVENTO_BLOQUEADOR;

        -- Construir a URL
        VURL := 'http://api.callmebot.com/whatsapp.php?phone=5511986260031&text=' || REPLACE(VTEXT, ' ','%20') || '&apikey=7143296'; -- Whatsapp 
        --VURLT:= 'https://api.callmebot.com/telegram/group.php?apikey=############&text=' || VTEXT; -- Telegram

        -- Enviar a mensagem
        SELECT UTL_HTTP.REQUEST(VURL)  INTO VNLIXO  FROM DUAL;
        --SELECT UTL_HTTP.REQUEST(VURLT) INTO VNLIXOT FROM DUAL;

      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Erro ao enviar mensagem para o Objeto: '|| ' - ' || SQLERRM||' - '|| vText);
      END;
    END LOOP;
  END;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro geral na execução do procedimento: ' || SQLERRM);
    
END;
