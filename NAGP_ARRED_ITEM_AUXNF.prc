CREATE OR REPLACE PROCEDURE NAGP_ARRED_ITEM_AUXNF (psNumeroNF NUMBER, psNroEmpresa NUMBER)

  IS
  
  vlTotalNF  NUMBER(30,8);
  vlTotalXML NUMBER(30,8);
  vlrDif     NUMBER(30,8);
  vlLimite   NUMBER := 0.05;
  psSeqAuxNF NUMBER(30);
  psChaveNF  VARCHAR2(300);
  psRowid    VARCHAR2(300);
  psVlrItem  NUMBER(30,8);
  psTipoCGO  VARCHAR2(1);
  
  BEGIN
   
-- Pega SeqAuxNotaFiscal e Chave de Acesso para selects posteriores
  
  SELECT SEQAUXNOTAFISCAL, N.NFECHAVEACESSO, C.TIPDOCFISCAL
    INTO psSeqAuxNF, psChaveNF, psTipoCGO
    FROM MLF_AUXNOTAFISCAL N INNER JOIN MAX_CODGERALOPER C ON C.CODGERALOPER = N.CODGERALOPER
   WHERE N.NUMERONF = psNumeroNF AND NROEMPRESA = psNroEmpresa;
   
-- Se for nota de compra, comeca o tratamento

  IF psTipoCGO = 'C' THEN
  
-- Pega o valor total da nota para comparacao com o valor do XML

   SELECT SUM(CASE
                     WHEN NVL(A.INDIMPORTEXPORT, 'N') = 'S'
                          AND NVL(A.INDTOTNFIGUALBICMS, 'N') = 'S' THEN
                      NVL(B.BASCALCICMS, 0) + NVL(B.VLRTOTISENTO, 0) +
                      NVL(B.VLRTOTOUTRA, 0)
                     WHEN NVL(A.INDIMPORTEXPORT, 'N') = 'S'
                          AND NVL(A.INDTOTNFIGUALBICMS, 'N') = 'N' THEN
                      CASE
                             WHEN NVL(B.INDSUBICMSDIFDI, 'S') = 'S' THEN
                              (B.VLRITEM +
                              DECODE(A.INDCONSIDFRETEDESPTRIB,
                                      'N',
                                      NVL(B.VLRDESPTRIBUTITEM, 0) + NVL(B.VLRFRETENANF, 0),
                                      NVL(B.VLRDESPTRIBUTITEM, 0)) +
                              NVL(B.VLRDESPNTRIBUTITEM, 0) + NVL(B.VLRIPI, 0) +
                              NVL(B.VLRICMSRETIDO, 0) +
                              DECODE(NVL(B.LANCAMENTOST, 'C'),
                                      'O',
                                      0,
                                      'S',
                                      0,
                                      NVL(B.VLRICMSST, 0)) - NVL(B.VLRABATIMENTO, 0) -
                              NVL(B.VLRDESCITEM, 0) - NVL(B.VLRDESCSUFRAMA, 0) +
                              (ABS(NVL(B.VLRICMS, 0) -
                                    ((NVL(B.BASCALCICMS, 0) * NVL(B.PERALIQICMSORIG, 0)) / 100))) +
                              DECODE(NVL(B.LANCAMENTOST, 'C'),
                                      'O',
                                      0,
                                      'S',
                                      0,
                                      NVL(B.VLRFCPST, 0)))
                             ELSE
                              (B.VLRITEM +
                              DECODE(A.INDCONSIDFRETEDESPTRIB,
                                      'N',
                                      NVL(B.VLRDESPTRIBUTITEM, 0) + NVL(B.VLRFRETENANF, 0),
                                      NVL(B.VLRDESPTRIBUTITEM, 0)) +
                              NVL(B.VLRDESPNTRIBUTITEM, 0) + NVL(B.VLRIPI, 0) +
                              NVL(B.VLRICMSRETIDO, 0) +
                              DECODE(NVL(B.LANCAMENTOST, 'C'),
                                      'O',
                                      0,
                                      'S',
                                      0,
                                      NVL(B.VLRICMSST, 0)) - NVL(B.VLRABATIMENTO, 0) -
                              NVL(B.VLRDESCITEM, 0) - NVL(B.VLRDESCSUFRAMA, 0) +
                              ABS(NVL(B.VLRICMS, 0)) +
                              DECODE(NVL(B.LANCAMENTOST, 'C'),
                                      'O',
                                      0,
                                      'S',
                                      0,
                                      NVL(B.VLRFCPST, 0)))
                      END
                      ELSE 
                              CASE WHEN NVL(B.INDCOMPTOTNFREMESSA,'S') = 'N' THEN 0
                              ELSE
                                (B.VLRITEM + DECODE(A.INDCONSIDFRETEDESPTRIB,
                                                    'N', NVL(B.VLRDESPTRIBUTITEM,0) + NVL(B.VLRFRETENANF,0),
                                                    NVL(B.VLRDESPTRIBUTITEM,0))
                                           + NVL(B.VLRDESPNTRIBUTITEM,0) + NVL(B.VLRIPI,0) +
                                     NVL(B.VLRICMSRETIDO,0) +
                                     DECODE(NVL(B.LANCAMENTOST, 'C'), 'O', 0, 'S', 0, NVL(B.VLRICMSST,0)) -
                                     NVL(B.VLRABATIMENTO,0) - NVL(B.VLRDESCITEM,0)
                                      - NVL(B.VLRDESCSUFRAMA, 0) +
                                     DECODE(NVL(B.LANCAMENTOST, 'C'), 'O', 0, 'S', 0, NVL(B.VLRFCPST, 0)))
                              END
              END), SUM(VLRITEM)
     INTO VlTotalNF, psVlrItem
     FROM MLF_AUXNFITEM B INNER JOIN MLF_AUXNOTAFISCAL A ON A.SEQAUXNOTAFISCAL = B.SEQAUXNOTAFISCAL
    WHERE A.SEQAUXNOTAFISCAL = PSSEQAUXNF;
    
-- Pega o valor total do XML para comparar se vai somar ou subtrair centavos do lancamento

   SELECT M000_VL_NF
     INTO vlTotalXML
     FROM TMP_M000_NF F WHERE F.M000_NR_CHAVE_ACESSO = psChaveNF;
     
-- Calcula para somar ou subtrair da auxiliar
     
   vlrDif := vlTotalXML - vlTotalNF;
   
-- Faz o update se a diferenca for menor que o valor limite
   IF vlrDif BETWEEN vlLimite * -1 AND vlLimite AND vlrDif <> 0 THEN

-- Descobre o item de maior valor da nota para update
     
   SELECT X.ROWID
     INTO psRowid
     FROM MLF_AUXNFITEM X WHERE SEQAUXNOTAFISCAL = psSeqAuxNF
    ORDER BY VLRITEM DESC FETCH FIRST 1 ROWS ONLY;
    
  -- Updates no item e no valor do item na capa da nota 
    
   UPDATE MLF_AUXNFITEM XI 
      SET XI.VLRITEM = XI.VLRITEM + vlrDif
    WHERE XI.ROWID = psRowid;
    
   UPDATE MLF_AUXNOTAFISCAL X
      SET X.VLRPRODUTOS = VLRPRODUTOS + vlrDif
    WHERE X.SEQAUXNOTAFISCAL = psSeqAuxNF;

  -- Valida inconsistencias e recalcula arredondamento nos impostos

   BEGIN PKG_MLF_RECEBIMENTO.SP_CONSISTEAUXNOTAFISCAL(psSeqAuxNF,'0'); END; 
    
   END IF;
   
   COMMIT;
   END IF;
   
END;
     
