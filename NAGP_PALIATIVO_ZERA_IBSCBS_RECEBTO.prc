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
  
  psCGORegra     MAX_CODGERALOPER.CODGERALOPER%TYPE;
  pdCGO          VARCHAR2(4000);
  
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
  OR (NVL(psCBS,0) = 0 OR NVL(psIBS,0) = 0) AND TRUNC(SYSDATE) < DATE '2026-02-01' THEN
  
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
  
  -- Se for nota do grupo, atualiza de acordo com XML pois ao alterar o CGO ele vai recalcular CBS IBS

  ELSIF psSeqPessoa < 999 THEN
    
  SP_BUSCAPARAMDINAMICO('NAGUMO',0,'CGO_REP_XML_REFORMA','S', NULL,
                        'Lista de CGOs que mantem as informacoes do XML sobre os novos impostos da Reforma Tributária no lançamento entre lojas do grupo', pdCGO);
    
    SELECT MAX(COLUMN_VALUE)
      INTO psCGORegra
      FROM TABLE(CAST(C5_COMPLEXIN.C5INTABLE(NVL(TRIM(pdCGO), 0)) AS C5INSTRTABLE))
     WHERE COLUMN_VALUE = psCGO AND COLUMN_VALUE IS NOT NULL;
 
  IF psCGORegra IS NOT NULL THEN -- Encontrou CGO no parametro dinamico
    
  -- Item Rateado
  FOR item IN (
  SELECT Y.M014_NR_ITEM, Y.M014_VL_VLRBASECBS / Y.M014_VL_QTDE_COM BaseCBS, ROUND(Y.M014_VL_VLRIMPOSTOCBS / Y.M014_VL_QTDE_COM,4) VlrCBS, 
                         Y.M014_VL_VLRBASEIBSUF / Y.M014_VL_QTDE_COM BaseIBS, Y.M014_VL_VLRIMPOSTOIBS / Y.M014_VL_QTDE_COM VlrIBS, Y.M014_CD_PRODUTO COD 
       
    FROM TMP_M000_NF X INNER JOIN TMP_M014_ITEM Y ON X.M000_ID_NF = Y.M000_ID_NF
   WHERE X.M000_NR_CHAVE_ACESSO = psChave)
   
  LOOP
    psBaseCBSItem := item.BaseCBS;
    psVlrCBSItem  := item.VlrCBS;
    psBaseIBSItem := item.BaseIBS;
    psVlrIBSItem  := item.VlrIBS;
    psCodProd     := item.COD;
 
  UPDATE MLF_AUXNFITEM XI SET XI.VLRBASECBS       = psBaseCBSItem * (XI.QUANTIDADE/XI.QTDEMBALAGEM),
                              XI.VLRIMPOSTOCBS    = psVlrCBSItem  * (XI.QUANTIDADE/XI.QTDEMBALAGEM),
                              XI.VLRBASEIBSUF     = psBaseIBSItem * (XI.QUANTIDADE/XI.QTDEMBALAGEM),
                              XI.VLRIMPOSTOIBSUF  = psVlrIBSItem  * (XI.QUANTIDADE/XI.QTDEMBALAGEM)
                        WHERE XI.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal
                          AND XI.SEQPRODUTO   = psCodProd;
    
  END LOOP;
  -- Atualiza Capa     
  FOR capa IN (   
  SELECT X.M000_VL_VLRBASECBS BaseCBSItemCheio, X.M000_VL_VLRIMPOSTOCBS VlrCBSItemCheio, X.M000_VL_VLRBASEIBSUF BaseIBSItemCheio, X.M000_VL_VLRIMPOSTOIBS VlrIBSItemCheio
    FROM TMP_M000_NF X
   WHERE X.M000_NR_CHAVE_ACESSO = psChave)
   
  LOOP
                          
  UPDATE MLF_AUXNOTAFISCAL X SET X.VLRBASECBS       = capa.BaseCBSItemCheio,
                                 X.VLRIMPOSTOCBS    = capa.VlrCBSItemCheio,
                                 X.VLRBASEIBSUF     = capa.BaseIBSItemCheio,
                                 X.VLRIMPOSTOIBSUF  = capa.VlrIBSItemCheio
                           WHERE X.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal;
    END LOOP;
   END IF;
  END IF;
  COMMIT;
  
 EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error Stack: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
        DBMS_OUTPUT.PUT_LINE('Error Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        DBMS_OUTPUT.PUT_LINE('Call Stack: ' || DBMS_UTILITY.FORMAT_CALL_STACK);
     -- DBMS para nao estourar erro SQL caso outro problema surja ao rodar essa proc, nao para o processo

END;
