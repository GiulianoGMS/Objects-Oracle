CREATE OR REPLACE TRIGGER NAGTR_CONTROLELOTECOMPRA_LOG
AFTER INSERT OR UPDATE OR DELETE
ON CONSINCO.NAGT_CONTROLELOTECOMPRA
FOR EACH ROW
DECLARE
    V_USUALTERACAO VARCHAR2(100);
BEGIN
    -- pega o usuário que fez a alteração
    SELECT USER INTO V_USUALTERACAO FROM DUAL;

    IF INSERTING THEN
        INSERT INTO CONSINCO.NAGT_CONTROLELOTECOMPRA_LOG (
            SEQLOTEMODELO,
            DIASEMANA,
            DIASCONFIG,
            HORAMIN,
            DATAINICIO,
            ASSISTENTE,
            EMAIL_FORNEC,
            DTA_ALTERACAO,
            V_USUALTERACAO,
            DIA_FIXO
        ) VALUES (
            :NEW.SEQLOTEMODELO,
            :NEW.DIASEMANA,
            :NEW.DIASCONFIG,
            :NEW.HORAMIN,
            :NEW.DATAINICIO,
            :NEW.ASSISTENTE,
            :NEW.EMAIL_FORNEC,
            SYSDATE,
            V_USUALTERACAO,
            :NEW.DIA_FIXO
        );

    ELSIF UPDATING THEN
        INSERT INTO CONSINCO.NAGT_CONTROLELOTECOMPRA_LOG (
            SEQLOTEMODELO,
            DIASEMANA,
            DIASCONFIG,
            HORAMIN,
            DATAINICIO,
            ASSISTENTE,
            EMAIL_FORNEC,
            DTA_ALTERACAO,
            V_USUALTERACAO,
            DIA_FIXO
        ) VALUES (
            :NEW.SEQLOTEMODELO,
            :NEW.DIASEMANA,
            :NEW.DIASCONFIG,
            :NEW.HORAMIN,
            :NEW.DATAINICIO,
            :NEW.ASSISTENTE,
            :NEW.EMAIL_FORNEC,
            SYSDATE,
            V_USUALTERACAO,
            :NEW.DIA_FIXO
        );
      

    ELSIF DELETING THEN
        INSERT INTO CONSINCO.NAGT_CONTROLELOTECOMPRA_LOG (
            SEQLOTEMODELO,
            DIASEMANA,
            DIASCONFIG,
            HORAMIN,
            DATAINICIO,
            ASSISTENTE,
            EMAIL_FORNEC,
            DTA_ALTERACAO,
            V_USUALTERACAO,
            DIA_FIXO
        ) VALUES (
            :OLD.SEQLOTEMODELO,
            :OLD.DIASEMANA,
            :OLD.DIASCONFIG,
            :OLD.HORAMIN,
            :OLD.DATAINICIO,
            :OLD.ASSISTENTE,
            :OLD.EMAIL_FORNEC,
            SYSDATE,
            V_USUALTERACAO,
            :OLD.DIA_FIXO
        );
    END IF;
END;

