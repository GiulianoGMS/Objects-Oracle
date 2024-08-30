CREATE OR REPLACE VIEW CONSINCO.MRLV_ETIQ_VALIDADE AS
SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4')*/           
        -- Novo modelo criado por Giuliano | 29/08/2024

       NULL MARCA, A."NROEMPRESA",A."SEQPRODUTO",A."DTABASEPRECO",A."CODACESSO",A."QTDETIQUETA",A."DTAPROMINICIO",
       A."DTAPROMFIM",A."CODACESSOPADRAO",A."EMBALAGEMPADRAO",A."PADRAOEMBVENDA",A."PRECOEMBPADRAO",A.PRECOVALIDNORMAL,A.PRECOVALIDPROMOC,A."MULTEQPEMBPADRAO",
       A."QTDUNIDEMBPADRAO",A."TIPOETIQUETA",A."TIPOPRECO",A."DESCCOMPLETA",A."DESCREDUZIDA",A."QTDEMBALAGEM1",A."MULTEQPEMB1",
       A."QTDUNIDEMB1",A."QTDEMBALAGEM2",A."MULTEQPEMB2",A."QTDUNIDEMB2",A."QTDEMBALAGEM3",A."MULTEQPEMB3",A."QTDUNIDEMB3",
       A."QTDEMBALAGEM4",A."MULTEQPEMB4",A."QTDUNIDEMB4",A."QTDEMBALAGEM5",A."MULTEQPEMB5",A."QTDUNIDEMB5",A."CODACESSO1",A."CODACESSO2",
       A."CODACESSO3",A."CODACESSO4",A."CODACESSO5",A."PRECO1",A."PRECO2",A."PRECO3",A."PRECO4",A."PRECO5",A."PRECOMIN",A."PRECOMAX",
       A."EMBALAGEM1",A."EMBALAGEM2",A."EMBALAGEM3",A."EMBALAGEM4",A."EMBALAGEM5",A."TIPOCODIGO", A.QTDEMBCODACESSO,


       '^XA' || '^PRA^FS' || '^LH00,00^FS'|| '^BY2^FS' || '^PQ' || NVL(A.QTDETIQUETA, 1) || '^FS'
       
                                                      || CHR(13) || CHR(10) ||
      '^FO180,65^BY1.8^BY2^BY2,2.0,2.0^BEN,100,Y,N^FD'||B.CODACESSOESPECIAL||'^FS' || CHR(13) || CHR(10) || -- EAN
      '^FO35,30^A0N,18,18^FD'||SUBSTR(A.DESCCOMPLETA,0,37) ||' '||CASE WHEN J.QTDEMBALAGEM > 1 THEN J.EMBALAGEM ELSE NULL END||'^FS' || CHR(13) || CHR(10) || -- DESC
      '^FO123,255^A0N,14,14^FDIMP '||TO_CHAR(SYSDATE, 'DD/MM/YY HH24:MI')||'- VALIDADE: '||TO_CHAR(B.DTAFIM, 'DD/MM/YY')||'^FS'|| CHR(13) || CHR(10) ||
      '^FO35,125^A0N,20,20^FD^FS'                                                     || CHR(13) || CHR(10) ||
      '^FO8,110^A0N,55,55^FD'||LPAD(TRUNC(B.VLRPRECOPROMOC), 4, ' ' ) || ',' || LPAD((B.VLRPRECOPROMOC - TRUNC(B.VLRPRECOPROMOC)) * 100, 2, 0)||'^FS' || CHR(13) || CHR(10) || -- PROMOC
      '^FO115,200^A0N,18,18^FD*PRODUTO PROXIMO DA VALIDADE^FS'                        || CHR(13) || CHR(10) ||
      '^FO115,228^A0N,18,18^FD*SEM TROCA^FS'                                          || CHR(13) || CHR(10) ||
      '^FO45,75^A0N,15,15^FDPOR^FS'                                                   || CHR(13) || CHR(10) ||
      '^FO45,92^A0N,15,15^FDR$^FS'                                                    || CHR(13) || CHR(10) ||
      '^FO35,65^GB130,100,80^FR^FS '                                                  || CHR(13) || CHR(10) ||
      '^FO595,65^BY1.8^BY2^BY2,2.0,2.0^BEN,100,Y,N^FD'||B.CODACESSOESPECIAL||'^FS' || CHR(13) || CHR(10) || -- EAN
      '^FO450,30^A0N,18,18^FD'||SUBSTR(A.DESCCOMPLETA,0,37) ||' '||CASE WHEN J.QTDEMBALAGEM > 1 THEN J.EMBALAGEM ELSE NULL END||'^FS' || CHR(13) || CHR(10) || -- DESC
      '^FO538,255^A0N,14,14^FDIMP: '||TO_CHAR(SYSDATE, 'DD/MM/YY HH24:MI')||'- VALIDADE: '||TO_CHAR(B.DTAFIM, 'DD/MM/YY')||'^FS'|| CHR(13) || CHR(10) ||
      '^FO450,125^A0N,20,20^FD^FS'                                                    || CHR(13) || CHR(10) ||
      '^FO424,110^A0N,55,55^FD'||LPAD(TRUNC(B.VLRPRECOPROMOC), 4, ' ' ) || ',' || LPAD((B.VLRPRECOPROMOC - TRUNC(B.VLRPRECOPROMOC)) * 100, 2, 0)||'^FS' || CHR(13) || CHR(10) || -- PROMOC
      '^FO530,200^A0N,18,18^FD*PRODUTO PROXIMO DA VALIDADE^FS'                        || CHR(13) || CHR(10) ||
      '^FO530,228^A0N,18,18^FD*SEM TROCA^FS'                                          || CHR(13) || CHR(10) ||  
      '^FO460,75^A0N,15,15^FDPOR^FS'                                                  || CHR(13) || CHR(10) ||
      '^FO460,92^A0N,15,15^FDR$^FS'                                                   || CHR(13) || CHR(10) ||
      '^FO450,65^GB130,100,80^FR^FS'                                                  || CHR(13) || CHR(10) ||
      
      -- Imagens
      
      '^FO25,185' ||(SELECT LT_IMG FROM NAGT_LT_IMG3 X WHERE X.TIPO = 3) /* Esquerda  */                 || CHR(13) || CHR(10) ||
      '^FO440,185'||(SELECT LT_IMG FROM NAGT_LT_IMG3 X WHERE X.TIPO = 3) -- Direita


--FIM DA ETIQUETA
|| CHR(13) || CHR(10) || '^XZ'
|| CHR(13) || CHR(10) LINHA

FROM  CONSINCO.MRLX_BASEETIQUETAPROD A INNER JOIN MRLV_PROMOCAOESPECIAL B ON A.SEQPRODUTO = B.SEQPRODUTO AND A.NROEMPRESA = B.NROEMPRESA
                                       INNER JOIN CONSINCO.MRLV_BASEETIQUETAPROD_NAGV2 J ON J.NROEMPRESA  = A.NROEMPRESA AND J.SEQPRODUTO = A.SEQPRODUTO AND J.NROSEGMENTO = A.NROSEGMENTO AND J.QTDEMBALAGEM = A.QTDEMBCODACESSO
      
                                    
  ORDER BY LINHA
;


