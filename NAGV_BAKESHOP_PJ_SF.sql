CREATE OR REPLACE VIEW CONSINCO.NAGV_BAKESHOP_PJ_SF AS
SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/
       DISTINCT Z.CODACESSO COD_PRODUTO, Z.SEQPRODUTO PLU, DESCCOMPLETA, F.CODNBMSH COD_NCM, F.CODCEST COD_CEST,
       NVL(UC.CFOPESTADO,(SELECT CGO.CFOPESTADO FROM MAX_CODGERALOPER CGO WHERE CGO.CODGERALOPER = 610)) CFOP,
       U.SITUACAONF CST_ICMS, F.SITUACAONFPISSAI CST_PIS, F.SITUACAONFCOFINSSAI CST_COFINS,
       F.SITUACAONFIPISAI CST_IPI, NULL CST_ISS, U.PERALIQUOTA ALIQ_ICMS, U.PERISENTO PERREDUCAO,
       CASE WHEN F.SITUACAONFPISSAI = '01' THEN 1.65 ELSE 0 END ALIQ_PIS,
       CASE WHEN F.SITUACAONFCOFINSSAI = '01' THEN 7.60 ELSE 0 END ALIQ_COFINS,
       NVL(F.PERALIQUOTAIPI,0) ALIQ_IPI,
       NVL(NULLIF(PRECOVALIDPROMOC,0), PRECOVALIDNORMAL) PRECO_VDA, CATEGORIAN3 CATEGORIA,
       
       /* */
       NVL(N.BASCALCICMSST,NVL(ESP_FCALCVALORICMSULTENTRADA(Z.SEQPRODUTO, S.NROEMPRESA,'B', TRUNC(SYSDATE),810), 0))        vBSCTRet,
       NVL(N.PERALIQUOTAICMSST,NVL(ESP_FCALCVALORICMSULTENTRADA(Z.SEQPRODUTO, S.NROEMPRESA,'AS',TRUNC(SYSDATE),810), 0))    pST,
       NVL(ESP_FCALCVALORICMSULTENTRADA(Z.SEQPRODUTO, S.NROEMPRESA,'V', TRUNC(SYSDATE),810), 0)                             vICMSSubstituto,
       NVL(N.VLRICMSST,NVL(ESP_FCALCVALORICMSULTENTRADA(Z.SEQPRODUTO, S.NROEMPRESA,'V', TRUNC(SYSDATE),810), 0))            vICMSSTRet,
       U.PERREDBCICMSEFET                                                                                                   pRedBCEfet,
      (SELECT ALIQPADRAOICMS FROM MAP_FAMALIQPADRAOUF WHERE SEQFAMILIA = P.SEQFAMILIA AND UF = 'SP')                        pICMSEfet
       

  FROM MAP_PRODCODIGO Z INNER JOIN MAP_PRODUTO P       ON P.SEQPRODUTO = Z.SEQPRODUTO
                        INNER JOIN MAP_FAMILIA F       ON F.SEQFAMILIA = P.SEQFAMILIA
                        INNER JOIN MAP_FAMDIVISAO D    ON D.SEQFAMILIA = F.SEQFAMILIA
                        INNER JOIN MAP_TRIBUTACAOUF U  ON U.NROTRIBUTACAO = D.NROTRIBUTACAO
                         LEFT JOIN MAX_CODGERALCFOP UC ON UC.NROTRIBUTACAO = D.NROTRIBUTACAO AND UC.CODGERALOPER = 610
                        INNER JOIN MRL_PRODEMPSEG S    ON S.SEQPRODUTO = Z.SEQPRODUTO AND NROSEGMENTO = 2 AND S.QTDEMBALAGEM = 1 AND S.NROEMPRESA = 14
                        INNER JOIN DIM_CATEGORIA@CONSINCODW CT ON CT.SEQFAMILIA = P.SEQFAMILIA
                        INNER JOIN MAX_COMPRADOR CP    ON  CP.SEQCOMPRADOR = D.SEQCOMPRADOR
                        
                        /**/
                        LEFT JOIN  MRL_NFCE_ENTRADA N  ON N.SEQPRODUTO = P.SEQPRODUTO AND N.NROEMPRESA = S.NROEMPRESA
                        

 WHERE /*(EXISTS ( SELECT 'T' FROM NAGT_BAKE50 T WHERE T.CODACESSO = Z.CODACESSO)
       -- Desconsidera o De/Para e usa os filtros do Thoome via Teams
       OR TIPCODIGO = 'E'
           AND Z.INDUTILVENDA     = 'S'
           AND Z.INDEANTRIBNFE    = 'S'
           AND EXISTS (SELECT 1 FROM MRL_PRODUTOEMPRESA AA WHERE AA.DTAULTVENDA > SYSDATE - 70 AND AA.NROEMPRESA = S.NROEMPRESA AND AA.SEQPRODUTO = Z.SEQPRODUTO)
           AND (   CT.CATEGORIAN4 = 'PICOLE'
                OR CT.CATEGORIAN1 = 'PADARIA' -- Solic Luiz
                OR COMPRADOR      IN ('DEBORAH','REBECA','EVELLYN NUNES', 'LUCIANO')))*/

  1=1 
  
  AND CATEGORIAN1         != 'PET SHOP' -- Solic Thome
  AND U.UFEMPRESA          = 'SP'
  AND U.UFCLIENTEFORNEC    = 'SP'
  AND U.NROREGTRIBUTACAO   = 0
  AND U.TIPTRIBUTACAO      = 'SN'

  -- Solic Thome - Soncidera apenas vendas nos checkouts 101,102 e 103 da Loja 51

 /* AND EXISTS (SELECT 1 FROM PDV_DOCTO X INNER JOIN PDV_DOCTOITEM XI ON X.SEQDOCTO = XI.SEQDOCTO
                      WHERE NROEMPRESA = 51
                        AND X.DTAMOVIMENTO >= SYSDATE - 60
                        AND X.NROCHECKOUT IN (101,102,103)
                        AND XI.SEQPRODUTO = Z.SEQPRODUTO)*/
                        
  --AND Z.CODACESSO = '7894900027013'
  
  ORDER BY 3
;