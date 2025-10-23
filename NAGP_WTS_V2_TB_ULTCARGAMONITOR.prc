CREATE OR REPLACE PROCEDURE NAGP_WTS_V2_TB_ULTCARGAMONITOR (psNroTelefone NUMBER, psAPIKey VARCHAR2)

 AS
 
    vnLixo  VARCHAR2(5000);
    vText   VARCHAR2(4000);
    vUrl    VARCHAR2(4000);

    -- Criado por Giuliano em 10/09/2025
    -- Valida se a ultima execucao de carga monitor foi à mais de 30 minutos
    -- Whats: Envia msg pelo whatsapp pela API TextMeBot
    
    BEGIN
    FOR msg IN (

    SELECT CASE WHEN (SYSDATE - MAX(DTAHOREMISSAO)) * 24 * 60 > 30 THEN 1 ELSE 0 END VALIDADOR,
           TO_CHAR(MAX(DTAHOREMISSAO), 'DD/MM/YYYY HH24:MI:SS') ULT_DTAHOREMISSAO,
           ROUND((SYSDATE - MAX(DTAHOREMISSAO)) * 24 * 60) COUNT_MIN
      FROM MONITORPDV.TB_ULTCARGAMONITOR
    HAVING ROUND((SYSDATE - MAX(DTAHOREMISSAO)) * 24 * 60) >= 30
    )
    LOOP
        -- Montar o texto da mensagem
        VTEXT := '%F0%9F%9A%A8%20*Report:%20Ultima%20Carga%20Monitor%20enviada%20a%20mais%20de%20'||msg.COUNT_MIN||'%20minutos.*%0A%0A' ||
                 '*Ultima Execucao:*%20'         || msg.ULT_DTAHOREMISSAO || '%0A' ||
                 '*Tabela:*%20TB_ULTCARGAMONITOR';

        -- Construir a URL
        vUrl := 'http://api.textmebot.com/send.php?recipient=+'||psNroTelefone||'&text=' || REPLACE(vText, ' ','%20') || '&apikey='||psAPIKey; -- Whatsapp 

        -- Enviar a mensagem
        SELECT UTL_HTTP.REQUEST(VURL)  INTO vnLixo  FROM DUAL;
        
        DBMS_SESSION.SLEEP(10); -- Segura 10 segundos pra nao dar pau na API (nao considerar spam)
      
    END LOOP;
  
END;
