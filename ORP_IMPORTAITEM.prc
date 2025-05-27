-- Na PKG_OR_IMPORTACAOXMLNF
-- Correcao por Giuliano | Solic Lucineia
-- Joga valor de ICMS para ICMS Outras quando CST = 060

PROCEDURE ORP_IMPORTAITEM(pnIDNFe         IN NUMBER,
                          pnNatDesp       IN OR_NFDESPESA.CODHISTORICO%TYPE,
                          pnNroEmpresa    IN NUMBER,
                          pnNroEmpresaOrc IN NUMBER,
                          pnSeqNota       IN NUMBER,
                          pnNroMatriz     IN NUMBER,
                          psTipoImp       IN VARCHAR2)
IS
 vnCFOPEstado           NUMBER;
 vnCFOPForaEstado       NUMBER;
 vnCFOPExterior         NUMBER;
 vsTipoTributacao       OR_NFDESPESA.TIPOTRIBUTACAO%TYPE;
 vsTributIcms           OR_NFDESPESA.TRIBUTICMS%TYPE;
 vsTributPis            OR_NFDESPESA.TRIBUTPIS%TYPE;
 vsTributCofins         OR_NFDESPESA.TRIBUTCOFINS%TYPE;
 vsTipoTributacaoIpi    OR_NFDESPESA.TIPOTRIBUTACAOIPI%TYPE;
 vsRetencaoPisNFDesp    OR_NFDESPESA.RETENCAOPISNFDESP%TYPE;
 vsRetencaoCofinsNFDesp OR_NFDESPESA.RETENCAOCOFINSNFDESP%TYPE;
 vnAliqIssQn            OR_NFDESPESA.ALIQISS%TYPE;
 vnAliqIssSt            OR_NFDESPESA.ALIQISSST%TYPE;
 vsIntegraDomini        RF_PARAMNATNFDESP.INTEGRADOMINI%TYPE;
 vsGeraCiap             RF_PARAMNATNFDESP.GERACIAP%TYPE;
BEGIN
  --Obtém os CFOPs e campos da Nat Desp
  SELECT P.CFOPESTADO,
         P.CFOPFORAESTADO,
         P.CFOPEXTERIOR,
         P.TIPTRIBUTACAO,
         P.TRIBUTICMS,
         P.TRIBUTPIS,
         P.TRIBUTCOFINS,
         P.TIPOTRIBUTACAOIPI,
         P.RETENCAOPISNFDESP,
         P.RETENCAOCOFINSNFDESP,
         NVL(P.ALIQISSQN, 0),
         NVL(P.ALIQISSST, 0),
         P.INTEGRADOMINI,
         P.GERACIAP
  INTO   vnCFOPEstado,
         vnCFOPForaEstado,
         vnCFOPExterior,
         vsTipoTributacao,
         vsTributIcms,
         vsTributPis,
         vsTributCofins,
         vsTipoTributacaoIpi,
         vsRetencaoPisNFDesp,
         vsRetencaoCofinsNFDesp,
         vnAliqIssQn,
         vnAliqIssSt,
         vsIntegraDomini,
         vsGeraCiap
  FROM   RFV_PARAMNATNFDESP P
  WHERE  P.CODHISTORICO = pnNatDesp
  AND    P.NROEMPRESA = pnNroMatriz;
  INSERT INTO OR_NFITENSDESPESA(SEQNOTA,
                                NROITEM,
                                NROEMPRESA,
                                NROEMPRESAORC,
                                CODPRODUTO,
                                VERSAOPROD,
                                DESCRICAO,
                                CFOP,
                                UNIDADEPADRAO,
                                UNIDADE,
                                QUANTIDADE,
                                VLRTOTAL,
                                VLRDESCONTO,
                                VLRISENTO,
                                VLROUTRAS,
                                VLRBASEICMSPROP,
                                VLRICMS,
                                ALIQICMS,
                                VLRBASEPIS,
                                ALIQPIS,
                                VLRPIS,
                                VLRBASECOFINS,
                                ALIQCOFINS,
                                VLRCOFINS,
                                VLRBASEISS,
                                ALIQISS,
                                VLRISS,
                                PERCREDBASEICMS,
                                VLRBASICMSSTPRO,
                                CODNCM,
                                VLRITEM,
                                INDFINANCEIRO,
                                ALIQIPI,
                                VLRBASEIPI,
                                VLRIPI,
                                VLROUTROSIPI,
                                VLRISENTOIPI,
                                VLRICMSDIF,
                                TIPOTRIBUTACAO,
                                TRIBUTAICMSNFDESP,
                                TRIBUTAPISNFDESP,
                                TRIBUTACOFINSNFDESP,
                                TIPOTRIBUTACAOIPI,
                                RETENCAOPISNFDESP,
                                RETENCAOCOFINSNFDESP,
                                VLRBASEISSST,
                                ALIQISSST,
                                VLRISSST,
                                INDGERADOMINI,
                                INDGERACIAP
                               )
  SELECT pnSeqNota,
         ROWNUM, --nroitem
         pnNroEmpresa,
         pnNroEmpresaOrc,
         X.CODPRODUTO, --codProdutoFiscal (item xml X fornecedor)
         X.VERSAO, --versao do produto já com o depara
         X.DESCRICAO,
         CASE WHEN X.CFOPDESTINO IS NULL THEN
             (CASE WHEN vsUFFornecedor = vsUFEmpresa THEN
                         vnCFOPEstado
                  WHEN vsUFFornecedor = 'EX' THEN
                         vnCFOPExterior
                  ELSE
                         vnCFOPForaEstado
              END)
         ELSE X.CFOPDESTINO END, --CFOP
         SUBSTR(I.UNIDADEPADRAO, 1, 3),
         SUBSTR(I.UNIDADE, 1, 3),
         I.QUANTIDADE,
         I.VLRTOTAL,
         I.VLRDESCONTO,
         (CASE WHEN (I.ALIQICMS IS NULL AND I.VLRBASEICMS IS NULL) OR (I.ALIQICMS = 0 AND I.VLRBASEICMS = 0) THEN
                   NULL
              ELSE
                   0
         END), --VLR ISENTO ICMS
         --///////////////// Tratativas TipTributacao Giuliano 31/03/2025
         CASE WHEN NVL(vsTipoTributacao,'X') = 'O' THEN NVL(I.VLRTOTAL, 0) ELSE 
         (CASE WHEN (I.ALIQICMS IS NULL AND I.VLRBASEICMS IS NULL) OR (I.ALIQICMS = 0 AND I.VLRBASEICMS = 0) THEN
                   NULL
              ELSE
                   0
         END)
         END, --VLR OUTRAS ICMS
         
         CASE WHEN NVL(vsTipoTributacao,'X') = 'O' THEN NULL ELSE 
         (CASE WHEN I.VLRBASEICMS IS NULL OR I.VLRBASEICMS = 0 THEN
                     NULL
               ELSE
                    I.VLRBASEICMS
         END)
         END,
         
         CASE WHEN NVL(vsTipoTributacao,'X') = 'O' THEN NULL ELSE 
         (CASE WHEN (I.ALIQICMS IS NULL AND I.VLRBASEICMS IS NULL) OR (I.ALIQICMS = 0 AND I.VLRBASEICMS = 0) THEN
                   NULL
              ELSE
                   NVL(I.VLRICMS, 0)
         END)
         END,
         
         CASE WHEN NVL(vsTipoTributacao,'X') = 'O' THEN 0 ELSE 
         (CASE WHEN I.ALIQICMS IS NULL OR I.ALIQICMS = 0 THEN
                    NULL
               ELSE
                  I.ALIQICMS
          END)
         END,
          
         --///////////////////////////////////////////////////////// Termina ICMS
         (CASE WHEN I.ALIQPIS IS NULL OR I.ALIQPIS = 0 THEN
                    NULL
               ELSE
                    NVL(I.VLRBASEPIS, 0)
         END),
         (CASE WHEN I.ALIQPIS IS NULL OR I.ALIQPIS = 0 THEN
                      NULL
               ELSE
                      I.ALIQPIS
          END),
         (CASE WHEN I.ALIQPIS IS NULL OR I.ALIQPIS = 0 THEN
                    NULL
               ELSE
                   NVL(I.VLRPIS, 0)
         END),
         (CASE WHEN I.ALIQCOFINS IS NULL OR I.ALIQCOFINS = 0 THEN
                    NULL
               ELSE
                    NVL(I.VLRBASECOFINS, 0)
         END),
         (CASE WHEN I.ALIQCOFINS IS NULL OR I.ALIQCOFINS = 0 THEN
                      NULL
               ELSE
                      I.ALIQCOFINS
          END),
         (CASE WHEN I.ALIQCOFINS IS NULL OR I.ALIQCOFINS = 0 THEN
                    NULL
               ELSE
                    NVL(I.VLRCOFINS, 0)
         END),
         (CASE WHEN I.ALIQISSQN IS NULL OR I.ALIQISSQN = 0 THEN
                    NULL
               WHEN vnAliqIssQn = 0 THEN
                    NULL
               ELSE
                    NVL(I.VLRBASEISSQN, 0)
         END),
         (CASE WHEN I.ALIQISSQN IS NULL OR I.ALIQISSQN = 0 THEN
                    NULL
               WHEN vnAliqIssQn = 0 THEN
                    NULL
               ELSE
                      I.ALIQISSQN
         END),
         (CASE WHEN I.ALIQISSQN IS NULL OR I.ALIQISSQN = 0 THEN
                    NULL
               WHEN vnAliqIssQn = 0 THEN
                    NULL
               ELSE
                   NVL(I.VLRISSQN, 0)
         END),
         I.PERCREDBASEICMS,
         I.VLRBASEICMSST,
         I.CODNCM,
         I.QUANTIDADE * I.VLRITEM, --Na aplicação precisa informar o vlr total do item
         'S', --INDFINANCEIRO
         (CASE WHEN I.ALIQIPI IS NULL OR I.ALIQIPI = 0 THEN
                       NULL
               ELSE
                   I.ALIQIPI
         END),
         (CASE WHEN I.VLRBASEIPI IS NULL OR I.VLRBASEIPI = 0 THEN
                      NULL
               ELSE
                      I.VLRBASEIPI
         END),
         (CASE WHEN (I.ALIQIPI IS NULL AND I.VLRBASEIPI IS NULL) OR (I.ALIQIPI = 0 AND I.VLRBASEIPI = 0) THEN
                    NULL
               ELSE
                    NVL(I.VLRIPI, 0)
          END),
         (CASE WHEN (I.ALIQIPI IS NULL AND I.VLRBASEIPI IS NULL) OR (I.ALIQIPI = 0 AND I.VLRBASEIPI = 0) THEN
                   NULL
              ELSE
                  0
         END), --VLROUTROSIPI
         (CASE WHEN (I.ALIQIPI IS NULL AND I.VLRBASEIPI IS NULL) OR (I.ALIQIPI = 0 AND I.VLRBASEIPI = 0) THEN
                   NULL
              ELSE
                  0
         END), --VLRISENTOIPI
         I.VLRICMSDIF,
         vsTipoTributacao,
         vsTributIcms,
         vsTributPis,
         vsTributCofins,
         vsTipoTributacaoIpi,
         vsRetencaoPisNFDesp,
         vsRetencaoCofinsNFDesp,
         (CASE WHEN I.ALIQISSQN IS NULL OR I.ALIQISSQN = 0 THEN
                    NULL
               WHEN vnAliqIssSt = 0 THEN
                    NULL
               ELSE
                    NVL(I.VLRBASEISSQN, 0)
         END),
         (CASE WHEN I.ALIQISSQN IS NULL OR I.ALIQISSQN = 0 THEN
                    NULL
               WHEN vnAliqIssSt = 0 THEN
                    NULL
               ELSE
                    I.ALIQISSQN
         END),
         (CASE WHEN I.ALIQISSQN IS NULL OR I.ALIQISSQN = 0 THEN
                    NULL
               WHEN vnAliqIssSt = 0 THEN
                    NULL
               ELSE
                   NVL(I.VLRISSQN, 0)
         END),
         vsIntegraDomini,
         vsGeraCiap
  FROM   ORV_IMPORTACAO_ITEM_XML I,
         ORX_IMPNFEPRODUTOITEM X
  WHERE  I.IDNF = X.IDNF
    AND  I.IDITEM = X.IDITEMNF
    AND  I.TIPOIMP = X.TIPOIMPORTACAO
    AND  I.IDNF = pnIDNFe
    AND  NVL(I.TIPOIMP,'X') = psTipoImp;
  -- Ponto de entrada preencher ICMS, PIS/COFINS e ICMSST de acordo com a natureza de despesa
  ORP_IMPITEMORCCUST(TP_OR_IMPITEMORC(pnSeqNota, pnNatDesp, pnNroEmpresa));
  commit;
END ORP_IMPORTAITEM;
