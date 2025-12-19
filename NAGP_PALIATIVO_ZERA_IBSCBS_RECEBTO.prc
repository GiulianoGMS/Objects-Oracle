CREATE OR REPLACE PROCEDURE NAGP_PALIATIVO_ZERA_IBSCBS_RECEBTO (psSeqAuxNotaFiscal MLF_AUXNOTAFISCAL.SEQAUXNOTAFISCAL%TYPE) IS
-- Paliativo Giuliano para reforma
  psSeqPessoa NUMBER(7);
  psStatusNT  VARCHAR2(1);
  psNumeroNF  NUMBER(30);
  psChave     MLF_AUXNOTAFISCAL.NFECHAVEACESSO%TYPE;
  psCBS       TMP_M000_NF.M000_VL_VLRBASECBS%TYPE;
  psIBS       TMP_M000_NF.M000_VL_VLRBASEIBSUF%TYPE;
  psCGO       MAX_CODGERALOPER.CODGERALOPER%TYPE;
  
  -- Variaveis por Item
  psBaseCBSItem  NUMBER(10,4);
  psBaseIBSItem  NUMBER(10,4);
  psVlrCBSItem   NUMBER(10,4);
  psVlrIBSItem   NUMBER(10,4);
  psIDItem       NUMBER(10);
  psCodProd      TMP_M014_ITEM.M014_CD_PRODUTO%TYPE;
  --psQtdCom       TMP_M014_ITEM.M014_VL_QTDE_COM%TYPE;
  
BEGIN
  -- Se o emissor (do grupo) nao emite impostos, zera a entrada)
  -- Descobre o SEQ
  SELECT SEQPESSOA, NUMERONF, X.NFECHAVEACESSO, X.CODGERALOPER
    INTO psSeqPessoa, psNumeroNF, psChave, psCGO
   FROM MLF_AUXNOTAFISCAL X WHERE X.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal;
   
  -- Valida se a NT 2025002 esta ativa para o seq
  SELECT MAX(STATUS)
    INTO psStatusNT
    FROM MAX_EMPRESANOTATECNICA T WHERE T.NRONOTATECNICA = 2025002 AND T.NROEMPRESA = psSeqPessoa;
    
  -- Se o fornecedor nao emitiu no XML entao tambem zera, pois a obrigacao é em 02/2026
  SELECT MAX(X.M000_VL_VLRBASECBS), MAX(X.M000_VL_VLRBASEIBSUF)
    INTO psCBS, psIBS
    FROM TMP_M000_NF X 
   WHERE X.M000_NR_CHAVE_ACESSO = psChave;
  
  -- Se estiver ativa para o emissor do grupo, não deve zerar na entrada
  -- ou se o fornec nao enviou no XML e ainda nao passou da data de obrigatoriedade
  
  IF psSeqPessoa < 999 AND NVL(psStatusNT,'N') != 'A'
  OR /*psSeqPessoa > 999 AND */ (NVL(psCBS,0) = 0 OR NVL(psIBS,0) = 0) AND TRUNC(SYSDATE) < DATE '2026-02-01' THEN
  
  -- Zera itens
  UPDATE MLF_AUXNFITEM XI SET XI.VLRBASECBS         = 0,
                              XI.VLRIMPOSTOCBS      = 0,
                              XI.VLRBASEIBSUF       = 0,
                              XI.VLRIMPOSTOIBSUF    = 0
                        WHERE XI.SEQAUXNOTAFISCAL   = psSeqAuxNotaFiscal;
  -- Zera capa
  UPDATE MLF_AUXNOTAFISCAL X SET X.VLRBASECBS       = 0,
                                 X.VLRIMPOSTOCBS    = 0,
                                 X.VLRBASEIBSUF     = 0,
                                 X.VLRIMPOSTOIBSUF  = 0
                           WHERE X.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal;
                           
  COMMIT;
  
  -- Se forn ota do grupo, atualiza de acordo com XML pois ao alterar o CGO ele vai recalcular CBS IBS
  ELSIF psCGO IN (59) THEN
  
  SELECT Y.M014_NR_ITEM, Y.M014_VL_VLRBASECBS / Y.M014_VL_QTDE_COM, ROUND(Y.M014_VL_VLRIMPOSTOCBS / Y.M014_VL_QTDE_COM,4), 
                         Y.M014_VL_VLRBASEIBSUF / Y.M014_VL_QTDE_COM, Y.M014_VL_VLRIMPOSTOIBS / Y.M014_VL_QTDE_COM, Y.M014_CD_PRODUTO
   
    INTO psIDItem, psBaseCBSItem, psVlrCBSItem, psBaseIBSItem, psVlrIBSItem, psCodProd
       
    FROM TMP_M000_NF X INNER JOIN TMP_M014_ITEM Y ON X.M000_ID_NF = Y.M000_ID_NF
   WHERE X.M000_NR_CHAVE_ACESSO = psChave;
 
  UPDATE MLF_AUXNFITEM XI SET XI.VLRBASECBS       = psBaseCBSItem * (XI.QUANTIDADE/XI.QTDEMBALAGEM),
                              XI.VLRIMPOSTOCBS    = psVlrCBSItem  * (XI.QUANTIDADE/XI.QTDEMBALAGEM),
                              XI.VLRBASEIBSUF     = psBaseIBSItem * (XI.QUANTIDADE/XI.QTDEMBALAGEM),
                              XI.VLRIMPOSTOIBSUF  = psVlrIBSItem  * (XI.QUANTIDADE/XI.QTDEMBALAGEM)
                        WHERE XI.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal
                          AND XI.SEQPRODUTO   = psCodProd;
  COMMIT;
  
  END IF;
  
 EXCEPTION 
   WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE(SQLERRM); -- DBMS para nao estourar erro SQL caso outro problema surja ao rodar essa proc, nao para o processo

END;
