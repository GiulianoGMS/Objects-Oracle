CREATE OR REPLACE PROCEDURE NAGP_RECOMPILA_OBJ AS

BEGIN
    FOR obj IN (

      SELECT DISTINCT 'NAGUMO PROD' DB, OWNER, OBJECT_NAME, OBJECT_TYPE
        FROM NAGV_INVALID_OBJECTS

      UNION ALL

      SELECT DISTINCT 'DW/BI' DB, OWNER, OBJECT_NAME, OBJECT_TYPE
        FROM NAGV_INVALID_OBJECTS_DW
    )
    LOOP
        BEGIN
          -- Dependendo do banco
          -- Se for Nag Prod
          IF obj.DB = 'NAGUMO PROD' THEN
            EXECUTE IMMEDIATE
                'ALTER ' || obj.object_type ||
                ' "' || obj.owner || '"."' || obj.object_name ||
                '" COMPILE';
          ELSE
          -- Sef or DW/BI
          DW_RECOMPILA_OBJ@CONSINCODW(obj.OWNER, obj.Object_Name, obj.object_type);
          END IF;
        END;
    END LOOP;
END;
