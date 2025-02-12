CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_SITUACAOACORDO (
-- Criado por Giuliano em 12/02/25
-- Atualiza para Pendente os acordos (passando acordo ou pedidosuprim)
-- Para o update, é preciso inativar a trigger (a proc inativa, roda update e em seguida ativa novamente)
  
    psNroAcordo       NUMBER DEFAULT NULL,
    psNroPedidoSuprim NUMBER DEFAULT NULL,
    psNovaSituacao    VARCHAR2 DEFAULT 'P') AS
    
   BEGIN
     DECLARE vSQL   VARCHAR2(200);
             vWhere VARCHAR2(100);
   
BEGIN
    -- Desativando a trigger
    EXECUTE IMMEDIATE 'ALTER TRIGGER TBU_MSU_ACORDOPROMOC DISABLE';
    
    vWhere := NULL;
    IF psNroAcordo IS NOT NULL THEN
    vWhere := 'X.NROACORDO = '||psNroAcordo;
    
    ELSIF psNroPedidoSuprim IS NOT NULL THEN
    vWhere := 'X.NROPEDIDOSUPRIM = '||psNroPedidoSuprim;
    
    END IF;
    
    vSQL := 'UPDATE MSU_ACORDOPROMOC X SET SITUACAOACORDO = '''||psNovaSituacao||''' WHERE '||vWhere;
             
    IF psNroacordo IS NOT NULL OR psNroPedidoSuprim IS NOT NULL THEN 
      
    EXECUTE IMMEDIATE vSql;
    
    END IF;

    -- Reativando a trigger
    EXECUTE IMMEDIATE 'ALTER TRIGGER TBU_MSU_ACORDOPROMOC ENABLE';
    
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(vSQL);
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error Stack: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
        DBMS_OUTPUT.PUT_LINE('Error Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        DBMS_OUTPUT.PUT_LINE('Call Stack: ' || DBMS_UTILITY.FORMAT_CALL_STACK);
        RAISE;
    
END;
END;
