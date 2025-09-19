CREATE OR REPLACE TRIGGER NAGTR_MAP_PRODDESCESP_AUD
       AFTER INSERT OR UPDATE OR DELETE ON MAP_PRODDESCESP
       FOR EACH ROW
         
       -- Giuliano em 18/09/2025
       -- Log da ProdDescEsp - Descricao Especial  
       
DECLARE
       vnLoteAuditoria NUMBER;
       vsPDAudProduto  VARCHAR2(1);

       PROCEDURE PRC_AUDITORIA(PCAMPO     VARCHAR2,
                               PDESCCAMPO VARCHAR2,
                               POLDVALUE  VARCHAR2,
                               PNEWVALUE  VARCHAR2) IS
       BEGIN
              INSERT INTO MAP_AUDITORIA
                     (SEQAUDITORIA,
                      DTAHORAUDITORIA,
                      DTAAUDITORIA,
                      USUAUDITORIA,
                      SEQIDENTIFICA,
                      TABELA,
                      ORIGEM,
                      CAMPO,
                      DESCCAMPO,
                      VLRANTERIOR,
                      VLRATUAL,
                      LOTEAUDITORIA,
                      IDENTIFICADOR)
              VALUES
                     (S_SEQAUDITORIA.NEXTVAL,
                      SYSDATE,
                      TRUNC(SYSDATE),
                      NVL(:NEW.USUARIOALTERACAO, :OLD.USUARIOALTERACAO),
                      NVL(:NEW.SEQPRODUTO, :OLD.SEQPRODUTO),
                      'MAP_PRODDESCESP',
                      'PRODUTO',
                      PCAMPO,
                      PDESCCAMPO,
                      POLDVALUE,
                      PNEWVALUE,
                      VNLOTEAUDITORIA,
                      'Produto');
       END;
BEGIN
       -- Verifica parâmetro de auditoria
       SP_BUSCAPARAMDINAMICO('PRODUTO',
                             0,
                             'UTIL_AUD_PRODUTO',
                             'S',
                             'N',
                             'UTILIZA CONTROLE DE ALTERAÇÕES NO CADASTRO DE PRODUTO ?',
                             vsPDAudProduto);

       IF vsPDAudProduto = 'S'
       THEN
              SELECT S_LOTEAUDITORIA.NEXTVAL INTO VNLOTEAUDITORIA FROM DUAL;
       
              -- INSERT
              IF INSERTING
              THEN
                     PRC_AUDITORIA('TIPO',
                                   'Aplicação/Especial\Tipo Descrição Especial',
                                   NULL,
                                   :NEW.TIPO);
                     PRC_AUDITORIA('CODIGO',
                                   'Aplicação/Especial\Código Descrição Especial',
                                   NULL,
                                   :NEW.CODIGO);
              
                     -- DELETE
              ELSIF DELETING
              THEN
                     PRC_AUDITORIA('TIPO',
                                   'Aplicação/Especial\Tipo Descrição Especial',
                                   :OLD.TIPO,
                                   NULL);
                     PRC_AUDITORIA('CODIGO',
                                   'Aplicação/Especial\Código Descrição Especial',
                                   :OLD.CODIGO,
                                   NULL);
              
                     -- UPDATE
              ELSIF UPDATING
              THEN
                     IF NVL(:OLD.TIPO, '#') <> NVL(:NEW.TIPO, '#')
                     THEN
                            PRC_AUDITORIA('TIPO',
                                          'Aplicação/Especial\Tipo Descrição Especial',
                                          :OLD.TIPO,
                                          :NEW.TIPO);
                     END IF;
              
                     IF NVL(:OLD.CODIGO, '#') <> NVL(:NEW.CODIGO, '#')
                     THEN
                            PRC_AUDITORIA('CODIGO',
                                          'Aplicação/Especial\Código Descrição Especial',
                                          :OLD.CODIGO,
                                          :NEW.CODIGO);
                     END IF;
              END IF;
       END IF;

EXCEPTION
       WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20200, SQLERRM);
END;

