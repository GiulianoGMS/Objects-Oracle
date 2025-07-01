CREATE OR REPLACE PROCEDURE NAGP_ATUALIZA_ENCARTE (psSeqEncarteOrig NUMBER,
                                                   psSeqEncarteCop  NUMBER)
                                                   
    AS
    
BEGIN
  FOR orig IN (SELECT X.SEQENCARTE, PRECOPROMOC, PRECOCARTAO, SEQPRODUTO, NROAGRUPAMENTO
                 FROM MRL_ENCARTE X INNER JOIN MRL_ENCARTEPRODUTOPRECO Z ON Z.SEQENCARTE = X.SEQENCARTE
                WHERE X.SEQENCARTE = psSeqEncarteOrig
                  AND Z.NROAGRUPAMENTO = 2
                  AND X.SEQPROMOCAOGERADO IS NULL
                  AND X.INDPRECODIF = 'S'
                  AND psSeqEncarteOrig < psSeqEncarteCop) -- Evita o inverso
  LOOP
    UPDATE MRL_ENCARTEPRODUTOPRECO Z SET Z.PRECOPROMOC = orig.PRECOPROMOC,
                                         Z.PRECOCARTAO = orig.PRECOCARTA
                                   WHERE Z.SEQENCARTE  = orig.SEQENCARTE
                                     AND Z.NROAGRUPAMENTO = 7 -- Joga SP para Hibrido
                                     AND Z.SEQPRODUTO = orig.SEQPRODUTO;
  END LOOP;
  
  FOR cop IN (SELECT  X.SEQENCARTE, PRECOPROMOC, PRECOCARTAO, SEQPRODUTO, NROAGRUPAMENTO
                FROM MRL_ENCARTE X INNER JOIN MRL_ENCARTEPRODUTOPRECO Z ON Z.SEQENCARTE = X.SEQENCARTE
               WHERE X.SEQENCARTE = psSeqEncarteCop
                 AND Z.NROAGRUPAMENTO = 7
                 AND X.SEQPROMOCAOGERADO IS NULL
                 AND X.INDPRECODIF = 'S'
                 AND psSeqEncarteOrig < psSeqEncarteCop) -- Evita o inverso
  LOOP
    UPDATE MRL_ENCARTEPRODUTOPRECO Z SET Z.PRECOPROMOC = cop.PRECOPROMOC,
                                         Z.PRECOCARTAO = cop.PRECOCARTAO
                                   WHERE Z.SEQENCARTE  = cop.SEQENCARTE
                                     AND Z.NROAGRUPAMENTO = 2 -- Joga Hibrido para SP
                                     AND Z.SEQPRODUTO = cop.SEQPRODUTO;
                                     
    UPDATE MRL_ENCARTE X SET X.DESCRICAO = REPLACE(UPPER(X.DESCRICAO), '(CÓPIA)', ' - EXCECOES')
                       WHERE X.SEQENCARTE = psSeqEncarteCop;
                       
    DELETE FROM MRL_ENCARTESEG S WHERE S.SEQENCARTE = psSeqEncarteCop AND NROSEGMENTO != 2;
    
  END LOOP;
  
  COMMIT;
  
END;
