ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;

CREATE OR REPLACE VIEW CONSINCO.NAGV_HELPVINO AS

/*
 Criado por Giuliano em 12/08/2024
 Solicitacao Leonardo Tadanory - Ticket 439326
 */
 
SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/
       M.NROEMPRESA STOREID, C.CODACESSO GTIN, X.SEQPRODUTO EXTERNALID, 
       REGEXP_REPLACE(DESCCOMPLETA, '^\d+', '') DESCRIPTION,
       X.COMPLEMENTO COMPLEMENT, 
       COALESCE(NULLIF(E.PRECOVALIDNORMAL,0), NULLIF(E.PRECOGERNORMAL,0),NVL(PRECOBASENORMAL,0)) PRICE, 
       NVL(NULLIF(E.PRECOVALIDPROMOC,0),  NVL(NULLIF(E.PRECOGERPROMOC,0),0)) PROMOTIONALPRICE,-- NULL COMPLEMENTARYPRICES,
       CASE WHEN MN.PRECOPPROMOCIONAL IS NULL THEN NULL ELSE 'MEU NAGUMO' END CP_PRICELABEL,
       NVL(MN.PRECOPPROMOCIONAL,0) CP_PRICEVALUE,
       M.ESTQLOJA STOCKQUANTITY,
       DECODE(E.STATUSVENDA, 'A', 1, 'I', 0) ACTIVE 
       
  FROM CONSINCO.MAP_PRODUTO X  LEFT JOIN CONSINCO.MAP_PRODCODIGO C         ON C.SEQPRODUTO     = X.SEQPRODUTO AND C.TIPCODIGO = 'E'
                              INNER JOIN CONSINCO.ETLV_CATEGORIA_V2 CATEG  ON CATEG.SEQFAMILIA = X.SEQFAMILIA AND CATEG.NRODIVISAO = 1 -- V2 > Giuliano - a original estava lenta
                              INNER JOIN CONSINCO.MRL_PRODUTOEMPRESA M     ON M.SEQPRODUTO     = X.SEQPRODUTO
                              INNER JOIN CONSINCO.MRL_PRODEMPSEG E         ON E.SEQPRODUTO     = X.SEQPRODUTO AND E.NROEMPRESA = M.NROEMPRESA 
                                                                                                              AND E.QTDEMBALAGEM = C.QTDEMBALAGEM 
                                                                                                              AND NROSEGMENTO IN (2,3,4,7)
                                                                                                              
                               LEFT JOIN REMARCAPROMOCOES@INFOPROCMSSQL MN ON MN.CODLOJA = M.NROEMPRESA       AND CODIGOPRODUTO = LPAD(C.CODACESSO,14,0)
                                                                                                              AND SYSDATE BETWEEN DTHRINICIO AND DTHRFIM
                                                                                                              AND MN.TIPODESCONTO  = 4
                                                                                                              AND MN.PROMOCAOLIVRE = 0
                                                                                                              
 WHERE CATEGORIAN3 IN ('VINHO','ESPUMANTE')
   AND E.QTDEMBALAGEM = 1
   AND E.STATUSVENDA = 'A'
