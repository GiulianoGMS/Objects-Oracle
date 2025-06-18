BEGIN
  NAGP_KILL_SESSIONS_ADM('nome.sobrenome');
  END;

CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_KILL_SESSIONS_ADM ( psOSUSER VARCHAR2)  AS
                                                               
BEGIN

    FOR t IN (SELECT SID, SERIAL#, INST_ID
              FROM GV$SESSION
             WHERE OSUSER = psOSUSER)
    LOOP
      BEGIN
        EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION '''||t.SID||', '||t.SERIAL#||', @'||t.INST_ID||''' IMMEDIATE';
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('ERRO: ' || t.SID);
      END;
    END LOOP;

 
END;
