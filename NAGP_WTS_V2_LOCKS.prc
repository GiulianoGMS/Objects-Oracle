CREATE OR REPLACE PROCEDURE NAGP_WTS_V2_LOCKS (psNroTelefone NUMBER, psAPIKey VARCHAR2)

 AS
 
    vnLixo  VARCHAR2(5000);
    vText   VARCHAR2(4000);
    vUrl    VARCHAR2(4000);

    -- Criado por Giuliano em 10/09/2025
    -- Capta objetos invalidos e envia notificação pelo wts
    -- Whats: Envia msg pelo whatsapp pela API TextMeBot
    
  BEGIN
    FOR msg IN (
       SELECT DISTINCT
       'NAGUMO PROD' AMBIENTE,
       REPLACE(TO_CHAR(W.INST_ID), ' ', '%20')    INST_ID_BLOQUEADO,
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
  
  WHERE w.last_call_et >= 600 -- Filtra sessões bloqueadas por mais de 10 minutos ( 600 segundos )
    AND ROWNUM < 20
    AND W.PROGRAM  NOT LIKE '%sqlplus%'
    
    UNION ALL
    
       SELECT DISTINCT
       'DW/BI' AMBIENTE,
       REPLACE(TO_CHAR(W.INST_ID), ' ', '%20')    INST_ID_BLOQUEADO,
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
       
  FROM GV$SESSION@CONSINCODW W INNER JOIN GV$SESSION@CONSINCODW B ON W.BLOCKING_SESSION = B.SID
  
  WHERE w.last_call_et >= 300 -- Filtra sessões bloqueadas por mais de 5 minutos ( 300 segundos )
    AND ROWNUM < 20
    AND W.PROGRAM  NOT LIKE '%sqlplus%'
  
    )
    LOOP
        -- Montar o texto da mensagem
        VTEXT := '%F0%9F%9A%A8%20*Report:%20Sess%C3%A3o%20bloqueada%20detectada:*%0A%0A' ||
              
                     '*Ambiente:*%20'   || msg.AMBIENTE || '%0A' ||
                     '*Sess%C3%A3o%20bloqueadora:*%20' || msg.SESSAO_BLOQUEADORA || 
                     '%20(User:%20' || msg.USUARIO_BLOQUEADOR || ')%0A' ||
                     '*Serial:*%20' || msg.SERIAL_BLOQUEADORA ||' - Instance ID: '||msg.INST_ID_BLOQUEADORA || '%0A' ||
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
                     '*Evento%20bloqueador:*%20' || msg.EVENTO_BLOQUEADOR|| '%0A%0A' ||
                     
                     '*Para%20encerrar%20sessao:*'|| '%0A' ||
                     'NAGP_KILL_SESSION('|| msg.SESSAO_BLOQUEADORA ||',%20'||msg.SERIAL_BLOQUEADORA||',%20'||msg.INST_ID_BLOQUEADORA||')';

        -- Construir a URL
        vUrl := 'http://api.textmebot.com/send.php?recipient=+'||psNroTelefone||'&text=' || REPLACE(vText, ' ','%20') || '&apikey='||psAPIKey; -- Whatsapp 

        -- Enviar a mensagem
        SELECT UTL_HTTP.REQUEST(VURL)  INTO vnLixo  FROM DUAL;
        
        DBMS_SESSION.SLEEP(10); -- Segura 10 segundos pra nao dar pau na API (nao considerar spam)
      
    END LOOP;
  
END;
