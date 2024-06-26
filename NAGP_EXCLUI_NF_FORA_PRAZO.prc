CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_EXCLUI_NF_FORA_PRAZO AS
   -- Criado por Giuliano em 05/06/2024 - Tkt 339922
   -- Exclui da segunda tela notas fora do prazo de recebimento - Validacao por UF
   -- Regra: Mesma UF: 18 dias
   --        UF Diferente: 32 dias
   
      psSeqAuxNF NUMBER;
      
  BEGIN
        FOR t IN (SELECT DISTINCT A.SEQAUXNOTAFISCAL
                    FROM MLF_AUXNOTAFISCAL A, GE_PESSOA B, MAX_EMPRESA C
                   WHERE A.NROEMPRESA = C.NROEMPRESA
                     AND A.SEQPESSOA  = B.SEQPESSOA
                     AND (B.UF  = NVL(C.UF, 'X') AND A.DTAEMISSAO <= (A.DTARECEBIMENTO - 18) OR -- Mesma UF > 18
                          B.UF != NVL(C.UF, 'X') AND A.DTAEMISSAO <= (A.DTARECEBIMENTO - 32))   -- UF Dif   > 32
                     AND NOT EXISTS (SELECT 1 FROM CONSINCO.MLF_AUXNFINCONSISTENCIA INC 
                                      WHERE INC.SEQAUXNOTAFISCAL =  A.SEQAUXNOTAFISCAL
                                        AND INC.AUTORIZADA = 'S')
                  )
  LOOP
   BEGIN
     
   -- Pega o SeqAUxNotaFiscal para deletar da Segunda Tela, caso esteja na segunda
   
   psSeqAuxNF := T.SEQAUXNOTAFISCAL;

   IF psSeqAuxNF IS NOT NULL 
     THEN
          
   -- Caso a NF esteja na segunda tela, deleta e retorna para a primeira
    
    DELETE FROM CONSINCO.MLF_AUXNFITEM              WHERE SEQAUXNOTAFISCAL = psSeqAuxNF;
    DELETE FROM CONSINCO.MLF_AUXNFVENCIMENTO        WHERE SEQAUXNOTAFISCAL = psSeqAuxNF;
    DELETE FROM CONSINCO.MLF_AUXNFVENCIMENTOCONSIST WHERE SEQAUXNOTAFISCAL = psSeqAuxNF;
    DELETE FROM CONSINCO.MLF_AUXNFINCONSISTENCIA    WHERE SEQAUXNOTAFISCAL = psSeqAuxNF;
    DELETE FROM CONSINCO.MLF_NFITEMLOTE             WHERE SEQAUXNOTAFISCAL = psSeqAuxNF;
    DELETE FROM CONSINCO.MLF_CONHECIMENTONOTAS      WHERE SEQAUXNOTAFISCAL = psSeqAuxNF;
    DELETE FROM CONSINCO.MLF_SERVICONOTAS           WHERE SEQAUXNOTAFISCAL = psSeqAuxNF;
    DELETE FROM CONSINCO.MLF_GNRE                   WHERE SEQAUXNOTAFISCAL = psSeqAuxNF;
    DELETE FROM CONSINCO.MLF_AUXNFVENCTITDIREITO    WHERE SEQAUXNOTAFISCAL = psSeqAuxNF;
    DELETE FROM CONSINCO.MLF_AUXNOTAFISCAL          WHERE SEQAUXNOTAFISCAL = psSeqAuxNF;
    COMMIT;
       
   END IF;
  
   END;
   COMMIT;
  END LOOP;
 END;
