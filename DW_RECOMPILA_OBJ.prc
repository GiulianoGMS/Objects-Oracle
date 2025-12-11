CREATE OR REPLACE PROCEDURE DW_RECOMPILA_OBJ (
   p_owner  VARCHAR2,
   p_name   VARCHAR2,
   p_type   VARCHAR2
) AS
BEGIN
    EXECUTE IMMEDIATE 
         'ALTER ' || p_type ||
         ' "' || p_owner || '"."' || p_name || '" COMPILE';
END;
