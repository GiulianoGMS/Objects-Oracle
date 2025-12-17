CREATE OR REPLACE PROCEDURE NAGP_PALIATIVO_ZERA_IBSCBS_RECEBTO (psSeqAuxNotaFiscal MLF_AUXNOTAFISCAL.SEQAUXNOTAFISCAL%TYPE) IS
-- Paliativo Giuliano para reforma
  psSeqPessoa NUMBER(7);
  psStatusNT  VARCHAR2(1);
BEGIN
  -- Se o emissor (do grupo) nao emite impostos, zera a entrada)
  -- Descobre o SEQ
  SELECT SEQPESSOA 
    INTO psSeqPessoa
   FROM MLF_AUXNOTAFISCAL X WHERE X.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal;
   
  -- Valida se a NT 2025002 esta ativa para o seq
  SELECT MAX(STATUS)
    INTO psStatusNT
    FROM MAX_EMPRESANOTATECNICA T WHERE T.NRONOTATECNICA = 2025002 AND T.NROEMPRESA = psSeqPessoa;
  
  IF NVL(psStatusNT,'N') != 'A' AND psSeqPessoa < 999 THEN
  
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
  END IF;
  
 EXCEPTION 
   WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE(SQLERRM); -- DBMS para nao estourar erro SQL caso outro problema surja ao rodar essa proc, nao para o processo

END;
