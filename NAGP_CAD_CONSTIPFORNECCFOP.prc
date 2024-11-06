CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_CAD_CONSTIPFORNECCFOP AS

-- Criado por Giuliano em 06/11/24
-- Solic Flaviane - Ticket 440031
-- Ajustar o cadastro do fornec para marcar a opcao 'Considera Tipo Fornec Conforme CFOP/XML'

BEGIN
  DECLARE
    i INTEGER := 0;
    
  BEGIN
    FOR t IN (SELECT DISTINCT SEQFAMILIA, Z.SEQFORNECEDOR
                FROM CONSINCO.MAP_FAMFORNEC Z
               WHERE NVL(Z.INDCONSIDTIPFORNCGO, 'N') = 'N')
    LOOP
      BEGIN
        i := i + 1;

        UPDATE CONSINCO.MAP_FAMFORNEC X
           SET INDCONSIDTIPFORNCGO = 'S',
               X.USUARIOALTERACAO = 'TKT440031'
         WHERE X.SEQFAMILIA = t.SEQFAMILIA
           AND X.SEQFORNECEDOR = t.SEQFORNECEDOR
           AND NVL(X.INDCONSIDTIPFORNCGO, 'N') = 'N';

        IF i = 1 THEN -- Commit por linha pois existe trigger na MAP_FAMFORNEC que valida cada alteração
          COMMIT;
          i := 0;
        END IF;

        COMMIT;
        
      EXCEPTION
        WHEN OTHERS THEN
          -- Tratamento de erro para cada linha
          DBMS_OUTPUT.PUT_LINE('Erro ao atualizar SEQFAMILIA: ' || t.SEQFAMILIA || 
                               ', SEQFORNECEDOR: ' || t.SEQFORNECEDOR || 
                               SQLERRM);
      END;
    END LOOP;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      -- Tratamento de erro geral
      DBMS_OUTPUT.PUT_LINE('Erro ao executar a procedure: ' || SQLERRM);

  END;
END;
