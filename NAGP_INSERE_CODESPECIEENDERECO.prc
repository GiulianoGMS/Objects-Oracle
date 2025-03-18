-- Tabela de Logs

CREATE TABLE CONSINCO.NAGT_LOG_MAD_PRODESPENDERECO 
       (SEQPRODUTO    INTEGER,
        QTDEMBALAGEM  NUMBER(12,6),
        PALETELASTRO  NUMBER(5),
        PALETEALTURA  NUMBER(5),
        USUARIOALTERACAO  VARCHAR2(12),
        ERRO          VARCHAR2(4000),
        DATA          DATE

SELECT * FROM NAGT_LOG_MAD_PRODESPENDERECO;

-- Procedure

CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_INSERE_CODESPECIEENDERECO (psSeqProduto   IN MAD_PRODESPENDERECO.SEQPRODUTO%TYPE, 
                                                                     psQtdEmbalagem IN MAD_PRODESPENDERECO.QTDEMBALAGEM%TYPE,
                                                                     psPaleteLastro IN MAD_PRODESPENDERECO.PALETELASTRO%TYPE,
                                                                     psPaleteAltura IN MAD_PRODESPENDERECO.PALETEALTURA%TYPE,
                                                                     psUsuAlteracao IN MAD_PRODESPENDERECO.USUARIOALTERACAO%TYPE)
                                                                                                                                                                                                             
       AS vlrERRO VARCHAR2(4000);
          vlrLoop VARCHAR2(4000);
                 
       BEGIN
         
       FOR t IN (SELECT X.NROEMPRESA, X.CODESPECENDERECO

                    FROM MAD_ESPECIEENDERECO X
                   WHERE X.STATUS = 'A'
                     AND EXISTS     (SELECT 1 FROM DWNAGT_DADOSEMPRESA G
                                      WHERE G.TIPO = 'CD'
                                        AND G.OPERACAOINICIADA = 'S'
                                        AND G.NROEMPRESA NOT IN (504, 505, 506)
                                        AND G.NROEMPRESA = X.NROEMPRESA)
                     AND NOT EXISTS (SELECT 2 FROM MAD_PRODESPENDERECO E
                                      WHERE E.SEQPRODUTO = psSeqProduto
                                        AND E.NROEMPRESA = X.NROEMPRESA
                                        AND E.QTDEMBALAGEM = psQtdEmbalagem
                                        AND E.CODESPECENDERECO = X.CODESPECENDERECO)
                    ) -- Evita duplicidade se ja existis o produto

    LOOP
        vlrLoop := 'Emp.: ' || t.NROEMPRESA || ' - Especie: ' || t.CODESPECENDERECO;
        
        BEGIN
            INSERT INTO MAD_PRODESPENDERECO VALUES (psSeqProduto,
                                               t.NROEMPRESA,
                                               t.CODESPECENDERECO,
                                               psQtdEmbalagem,
                                               psPaleteLastro,
                                               psPaleteAltura,
                                               NULL,
                                               psUsuAlteracao,
                                               'N');
            

        EXCEPTION 
          WHEN OTHERS THEN
              vlrErro := SQLERRM;
                INSERT INTO NAGT_LOG_MAD_PRODESPENDERECO VALUES (psSeqProduto,
                                               psQtdEmbalagem,
                                               psPaleteLastro,
                                               psPaleteAltura,
                                               psUsuAlteracao,
                                               vlrLoop||' - '||vlrErro, SYSDATE);
        END;
        
        vlrLoop := NULL;
        
    END LOOP;

    COMMIT;
    
END;
