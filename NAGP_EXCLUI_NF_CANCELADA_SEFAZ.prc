CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_EXCLUI_NF_CANCELADA_SEFAZ AS
   -- Criado por Giuliano em 09/01/2024 - Tkt 339919
   -- Exclui notas canecladas pela Sefaz que estão na Primeira e Segunda Tela
      psSeqAuxNF NUMBER;
      psExistePrimTela NUMBER;
      
  BEGIN
        FOR emp IN (SELECT NROEMPRESA FROM CONSINCO.MAX_EMPRESA M WHERE M.STATUS = 'A')
   LOOP
      
  BEGIN
        FOR t IN (SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4')*/ DISTINCT A.CHAVEACESSO, A.SEQNOTAFISCAL, INSTR(A.SEQNOTAFISCAL,1) SEQUENCIAL, AUX.SEQAUXNOTAFISCAL
                    FROM CONSINCO.MRLV_NFEIMPORTACAO A LEFT JOIN CONSINCO.MRL_NFEIMPORT_CANCREJ B    ON A.CHAVEACESSO = B.NFECHAVEACESSO
                                                       LEFT JOIN CONSINCO.TMP_M000_NF I              ON I.M000_NR_CHAVE_ACESSO = A.CHAVEACESSO
                                                       LEFT JOIN CONSINCO.MRL_NFEINCONSISTENCIA NI   ON NI.SEQNOTAFISCAL = A.SEQNOTAFISCAL
                                                       LEFT JOIN CONSINCO.MLF_AUXNOTAFISCAL AUX      ON AUX.NFECHAVEACESSO = A.CHAVEACESSO
                                                       LEFT JOIN CONSINCO.MLF_AUXNFINCONSISTENCIA NX ON NX.SEQAUXNOTAFISCAL = AUX.SEQAUXNOTAFISCAL
                   WHERE 1=1
                     AND (B.INDCANCELREJEICAO = 'C' OR NI.TIPOINCONSIST = 'N' AND NI.CODINCONSIST = 14 OR NX.TIPOINCONSIST = 'N' AND NX.CODINCONSIST = 182)
                     AND I.M000_DT_EMISSAO > SYSDATE - 10
                     AND A.NROEMPRESA = emp.NROEMPRESA)
          
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
    
   -- Deleta da Primeira Tela
   
   END IF;
   
   SELECT COUNT(1) 
     INTO psExistePrimTela
     FROM CONSINCO.MLF_NFE_EXCLUIDA EX
    WHERE EX.NFECHAVEACESSO = T.CHAVEACESSO;
     
   IF psExistePrimTela = 0 THEN
      
    INSERT INTO CONSINCO.MLF_NFE_EXCLUIDA VALUES (T.CHAVEACESSO, T.SEQUENCIAL, SYSDATE, 'AUTOMATICO');
    COMMIT;
    
   END IF;
   
    BEGIN 
     CONSINCO.PKG_MLF_IMPNFERECEBIMENTO.SP_EXCLUI_TMP(T.SEQNOTAFISCAL); 
    END;
    
   END;
  END LOOP;
  COMMIT;
 END;

 END LOOP;
 COMMIT;
END;
