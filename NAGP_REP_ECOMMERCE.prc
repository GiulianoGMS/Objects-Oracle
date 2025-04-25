CREATE OR REPLACE PROCEDURE NAGP_REP_ECOMMERCE (psCodPromocao NUMBER DEFAULT NULL) AS

BEGIN
  ---////////// LOOP CAPA
  ---////////// Insere a capa da promocao ///////////
  DECLARE codErro VARCHAR2(100);
  
  BEGIN
    
  FOR capa IN (SELECT S_SEQPROMOCPDV.NEXTVAL SEQPROMOCPDV, CODPROMOCAO, DTINICIO, DTFIM
                 FROM (SELECT DISTINCT CODPROMOCAO, T.DTINICIO, T.DTFIM
                         FROM NAGT_REMARCAPROMOCOES T 
                        WHERE 1=1 AND T.CODPROMOCAO = NVL(psCodPromocao, T.CODPROMOCAO)
                          AND T.TIPODESCONTO  = 4
                          AND T.PROMOCAOLIVRE = 0
                          AND TRUNC(T.DTINICIO) = TRUNC(SYSDATE) 
                          AND EXISTS (SELECT 1 FROM MAX_EMPRESA A WHERE A.NROEMPRESA = CODLOJA)
                          -- Este not exists evita duplicidades
                          AND NOT EXISTS(SELECT 1 FROM MFL_PROMOCAOPDV X WHERE X.DESCRICAO LIKE '%'||T.CODPROMOCAO||'%')))
               
  LOOP
  codErro := capa.CODPROMOCAO;
  
  INSERT INTO MFL_PROMOCAOPDV X (SEQPROMOCPDV,
                                 DESCRICAO,
                                 STATUS,
                                 DTAINICIO,
                                 DTAFIM,
                                 DTAALTERACAO,
                                 USUALTERACAO,
                                 NROBASEEXPORTACAO,
                                 TIPOPROMOCAO,
                                 TIPOQUANTIDADE,
                                 INDTIPOQTDCARGAPDV,
                                 INDCONTROLAVERBAPDV,
                                 CODPARCEIRO)

  VALUES (capa.SEQPROMOCPDV,
         'MEU NAGUMO - '||capa.CODPROMOCAO,
         'A',
          capa.DTINICIO,
          capa.DTFIM,
          SYSDATE,
         'REP_AUTO',
          0,
         'I',
         'I',
         'A',
         'N',
          700);
          
  ---////////// Loop ITEM
  ---////////// Insere os itens da promocao de acordo com o codpromocao da capa ///////////
  
  FOR item IN (SELECT CODPROMOCAO, SEQPRODUTO, SEQFAMILIA, ROWNUM SEQITEMPROMOC
                 FROM ( SELECT DISTINCT CODPROMOCAO, PC.SEQPRODUTO, PC.SEQFAMILIA
                          FROM NAGT_REMARCAPROMOCOES T INNER JOIN MAP_PRODCODIGO PC ON LPAD(PC.CODACESSO,14,0) = T.CODIGOPRODUTO AND PC.TIPCODIGO IN ('E','B') AND QTDEMBALAGEM = 1
                         WHERE CODPROMOCAO = capa.CODPROMOCAO
                           AND T.TIPODESCONTO  = 4
                           AND T.PROMOCAOLIVRE = 0
                           AND EXISTS (SELECT 1 FROM MAX_EMPRESA A WHERE A.NROEMPRESA = CODLOJA)))
  
  LOOP
 
  INSERT INTO MFL_PROMOCPDVITEM XI (SEQPROMOCPDV,
                                   SEQITEMPROMOC,
                                   SEQPRODUTO,
                                   QTDEMBALAGEM,
                                   QUANTIDADE,
                                   TIPOITEMPROMOC,
                                   PRECOITEM,
                                   PERCDESCONTO,
                                   STATUS,
                                   DTAALTERACAO,
                                   USUALTERACAO,
                                   SEQFAMILIA,
                                   PROMOCPORFAMILIA,
                                   NROBASEEXPORTACAO,
                                   SEQGRUPO,
                                   INDVLRREFACORDPROM)
                                  
   
  VALUES (capa.SEQPROMOCPDV,
          item.SEQITEMPROMOC,
          item.SEQPRODUTO,
          1,
          1,
         'P',
          0,
          0,
         'A',
          SYSDATE,
         'REP_AUTO',
          item.SEQFAMILIA,
         'N',
          0,
          0,
          2);
         
  END LOOP; -- Loop Item
    
  ---////////// Loop ITEM e LOJA
  ---////////// Insere os itens por loja de  acordo com o codpromocao da capa ///////////
      
  FOR item_loja IN (SELECT DISTINCT CODPROMOCAO, CODLOJA, PRECOPPROMOCIONAL, item_Base.SEQITEMPROMOC,
                           NVL(NULLIF(S.PRECOVALIDPROMOC,0), S.PRECOVALIDNORMAL) PRECO_NORMAL, 
                           NVL(NULLIF(S.PRECOVALIDPROMOC,0), S.PRECOVALIDNORMAL) - PRECOPPROMOCIONAL VLRDESCONTO,
                           ROUND(((NVL(NULLIF(S.PRECOVALIDPROMOC,0), S.PRECOVALIDNORMAL) - PRECOPPROMOCIONAL) / NVL(NULLIF(S.PRECOVALIDPROMOC,0), S.PRECOVALIDNORMAL)) * 100 ,2) PERCDESCONTO,
                           CASE WHEN F.PESAVEL = 'S' THEN 0.01 ELSE 1 END APARTIRDE -- Pesavel insere 0.01
                           
                      FROM NAGT_REMARCAPROMOCOES T INNER JOIN MAP_PRODCODIGO PC ON LPAD(PC.CODACESSO,14,0) = T.CODIGOPRODUTO AND PC.TIPCODIGO IN ('E','B') AND QTDEMBALAGEM = 1
                                                   INNER JOIN MAX_EMPRESA M ON M.NROEMPRESA = T.CODLOJA
                                                   INNER JOIN MRL_PRODEMPSEG S ON S.NROEMPRESA = M.NROEMPRESA AND S.NROSEGMENTO = M.NROSEGMENTOPRINC AND  S.SEQPRODUTO = PC.SEQPRODUTO AND S.QTDEMBALAGEM = PC.QTDEMBALAGEM
                                                   INNER JOIN MFL_PROMOCAOPDV cp ON cp.DESCRICAO = 'MEU NAGUMO - '||T.CODPROMOCAO -- pra descobrir o seqpromocpdv novo e fazer o prox join
                                                   INNER JOIN MFL_PROMOCPDVITEM item_base ON item_base.SEQPROMOCPDV = cp.Seqpromocpdv AND item_base.SEQPRODUTO = PC.SEQPRODUTO
                                                   INNER JOIN MAP_PRODUTO P ON P.SEQPRODUTO = PC.SEQPRODUTO
                                                   INNER JOIN MAP_FAMILIA F ON F.SEQFAMILIA = P.SEQFAMILIA
                                                   
                     WHERE T.CODPROMOCAO = capa.CODPROMOCAO
                       AND T.TIPODESCONTO  = 4
                       AND T.PROMOCAOLIVRE = 0
                       AND EXISTS (SELECT 1 FROM MAX_EMPRESA A WHERE A.NROEMPRESA = CODLOJA)
                       AND NVL(NULLIF(S.PRECOVALIDPROMOC,0), S.PRECOVALIDNORMAL) > 0)
                       
  LOOP
    
  INSERT INTO MFL_PROMOCPDVDESCAPARTDE XE (SEQDESCONTO,
                                           TIPODESCONTO,
                                           SEQPROMOCPDV,
                                           SEQITEMPROMOC,
                                           VLRDESCONTO,
                                           PERCDESCONTO,
                                           PRECOPROMOCAO,
                                           QTDAPARTIRDE,
                                           NROEMPRESA,
                                           TIPOPRECO)
      
  VALUES (1,
          1,
          capa.SEQPROMOCPDV,
          item_loja.SEQITEMPROMOC,
          item_loja.VLRDESCONTO,
          item_loja.PERCDESCONTO,
          item_loja.PRECOPPROMOCIONAL,
          item_loja.APARTIRDE, -- Pesavel insere 0.01
          item_loja.CODLOJA,
          1);
 
   END LOOP; -- Loop Item_Loja
   
   ---////////// Loop ITEM e LOJA
   ---////////// Insere os itens por loja de  acordo com o codpromocao da capa ///////////
   
   FOR emp IN (SELECT DISTINCT CODPROMOCAO, CODLOJA
                 FROM NAGT_REMARCAPROMOCOES T
                WHERE T.CODPROMOCAO = capa.CODPROMOCAO
                  AND T.TIPODESCONTO  = 4
                  AND T.PROMOCAOLIVRE = 0
                  AND EXISTS (SELECT 1 FROM MAX_EMPRESA A WHERE A.NROEMPRESA = CODLOJA))
                  
   LOOP
    
   INSERT INTO MFL_PROMOCPDVEMP (SEQPROMOCPDV,
                                 NROEMPRESA,
                                 STATUS,
                                 DTAALTERACAO,
                                 USUALTERACAO,
                                 NROBASEEXPORTACAO)
                          
   VALUES(capa.SEQPROMOCPDV,
          emp.CODLOJA,
          'A',
          SYSDATE,
         'REP_AUTO',
          0);
                       
   END LOOP; -- Loop Empresa
   
   codErro := NULL;
   
   COMMIT;
   END LOOP; -- Loop Capa
   
   --COMMIT;
   EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Promoc com Erro: ' || codErro);
        DBMS_OUTPUT.PUT_LINE('Error Code: '      || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Message: '   || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error Stack: '     || DBMS_UTILITY.FORMAT_ERROR_STACK);
        DBMS_OUTPUT.PUT_LINE('Error Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        DBMS_OUTPUT.PUT_LINE('Call Stack: '      || DBMS_UTILITY.FORMAT_CALL_STACK);
        RAISE;
   
END;
END;
