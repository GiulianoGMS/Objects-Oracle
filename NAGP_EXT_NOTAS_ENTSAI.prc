CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_EXT_NOTAS_ENTSAI (vsDtaInicial DATE, vsDtaFinal DATE, psNroEmpresa NUMBER) IS

    v_file UTL_FILE.file_type;
    v_line VARCHAR2(32767);
    v_Targetcharset varchar2(40 BYTE);
    v_Dbcharset varchar2(40 BYTE);
    v_Cabecalho VARCHAR2(4000);
    v_LineConteudo VARCHAR2(4000);
    v_Periodo VARCHAR2(10);
    v_buffer CLOB;
    v_chunk_size CONSTANT PLS_INTEGER := 32000; -- Ajuste conforme necessário
    v_emparq VARCHAR2(10);

BEGIN
  
    v_emparq := LPAD(psNroEmpresa,3,0);
    
    FOR t IN (SELECT X.ANOMESDESCRICAO,
                     MIN(TO_DATE(LAST_DAY(ADD_MONTHS(X.DTA, -1)) + 1, 'DD/MM/RRRR')) DTA_INICIAL,
                     MAX(TO_DATE(LAST_DAY(X.DTA), 'DD/MM/RRRR')) DTA_FINAL
                FROM DIM_TEMPO X
               WHERE X.DTA BETWEEN vsDtaInicial AND vsDtaFinal
               GROUP BY X.ANOMESDESCRICAO
               ORDER BY 2)
               
    LOOP
    
    V_Periodo := REPLACE(t.ANOMESDESCRICAO, '/','_');
    -- Abre o arquivo para escrita
    v_file := UTL_FILE.fopen('EXT_XML_GERAL', 'Ext_Nag_EntSaida_'||v_emparq||'_'||V_Periodo||'.csv', 'w', 32767);

    -- Pega o nome das colunas para inserir no cabecalho pq tenho preguica
    SELECT 'CNPJ_EMITENTE; CNPJ_DESTINATARIO;COD_ITEM;DESC_ITEM;COD_FAMILIA;DESC_FAMILIA;NCM;CFOP;CST_ICMS;CST_IPI;CST_PIS;CST_COFINS;VALOR_PROD; VALOR_ICMS;VALOR_ICMSST;VALOR_IPI;VALOR_PIS;VALOR_COFINS;VALOR_TOTAL_NF'
      INTO v_Cabecalho
      FROM DUAL A;
    
    -- Escreve o cabe¿alho do CSV
    UTL_FILE.put_line(v_file, v_Cabecalho);

    -- Executa a query e escreve os resultados

      FOR bs IN (SELECT X.CNPJ_EMITENTE, X.CHAVE, LPAD(G.NROCGCCPF,12,0)||LPAD(G.DIGCGCCPF,2,0) CNPJ_DESTINATARIO, X.CODIGO_ITEM COD_ITEM,
       X.DESC_ITEM, P.SEQFAMILIA COD_FAMILIA, FAMILIA DESC_FAMILIA, X.NCM, X.CFOP, X.ORIGEM_ICMS||X.CST_ICMS CST_ICMS, X.SITUACAONFIPI CST_IPI, X.CST_PIS, X.CST_COFINS,
       X.VLR_TOTAL_PRODUTOS, X.VLR_TOTAL_ICMS VLRICMS, X.VLRICMSST, X.VLRIPI, X.VLR_TOTAL_PIS VLRPIS, X.VLR_TOTAL_COFINS VLRCOFINS,
       FVALORTOTALNF(X.ID, 'N') VALOR_TOTAL_NF
       
  FROM NAGV_ENTRADAS X INNER JOIN MAP_PRODUTO P ON P.SEQPRODUTO = X.CODIGO_ITEM 
                           INNER JOIN MAP_FAMDIVISAO F ON F.SEQFAMILIA = P.SEQFAMILIA AND F.FINALIDADEFAMILIA = 'R'
                           INNER JOIN MAP_FAMILIA FA ON FA.SEQFAMILIA = P.SEQFAMILIA
                           INNER JOIN GE_PESSOA G ON G.SEQPESSOA = X.NROEMPRESA
                           
 WHERE X.PERIODO BETWEEN t.DTA_INICIAL AND t.DTA_FINAL
   AND X.NROEMPRESA = psNroEmpresa 
                                
UNION ALL

SELECT X.CNPJ_EMITENTE, X.CHAVE, LPAD(G.NROCGCCPF,12,0)||LPAD(G.DIGCGCCPF,2,0) CNPJ_DESTINATARIO, X.CODIGO_ITEM COD_ITEM,
       X.DESC_ITEM, P.SEQFAMILIA COD_FAMILIA, FAMILIA DESC_FAMILIA, X.NCM, X.CFOP, X.ORIGEM_ICMS||X.CST_ICMS CST_ICMS, X.SITUACAONFIPI CST_IPI, X.CST_PIS, X.CST_COFINS,
       X.VLR_TOTAL_PRODUTOS, X.VLR_TOTAL_ICMS VLRICMS, X.VLRICMSST, X.VLRIPI, X.VLR_TOTAL_PIS VLRPIS, X.VLR_TOTAL_COFINS VLRCOFINS,
       FVALORTOTALNF(X.ID, X.TP) VALOR_TOTAL_NF
       
  FROM NAGV_SAIDAS   X INNER JOIN MAP_PRODUTO P ON P.SEQPRODUTO = X.CODIGO_ITEM 
                           INNER JOIN MAP_FAMDIVISAO F ON F.SEQFAMILIA = P.SEQFAMILIA AND F.FINALIDADEFAMILIA = 'R'
                           INNER JOIN MAP_FAMILIA FA ON FA.SEQFAMILIA = P.SEQFAMILIA
                           INNER JOIN GE_PESSOA G ON G.SEQPESSOA = X.NROEMPRESA
                           
 WHERE X.PERIODO BETWEEN t.DTA_INICIAL AND t.DTA_FINAL
   AND X.NROEMPRESA = psNroEmpresa

)

      LOOP
 
         v_line :=  bs.CNPJ_EMITENTE||';'||bs.CHAVE||';'||bs.CNPJ_DESTINATARIO||';'||bs.COD_ITEM||';'||bs.DESC_ITEM||';'||bs.COD_FAMILIA||';'||bs.DESC_FAMILIA||';'||bs.NCM||';'||bs.CFOP||';'||bs.CST_ICMS||';'||bs.CST_IPI||';'||bs.CST_PIS||';'||bs.CST_COFINS||';'||bs.VLR_TOTAL_PRODUTOS||';'||bs.VLRICMS||';'||bs.VLRICMSST||';'||bs.VLRIPI||';'||bs.VLRPIS||';'||bs.VLRCOFINS||';'||bs.VALOR_TOTAL_NF;
                  
        v_buffer := v_buffer || v_line || CHR(10); -- Adiciona nova linha ao buffer        
        
        IF LENGTH(v_buffer) > v_chunk_size THEN
            UTL_FILE.put_line(v_file, v_buffer); -- Escreve o buffer no arquivo
            v_buffer := ''; -- Limpe o buffer
            
        END IF;
        
    END LOOP;
    
    -- Grava o restante do buffer no final (burro esqueceu)
    IF v_buffer IS NOT NULL THEN
        UTL_FILE.put_line(v_file, v_buffer);
        v_buffer := '';
    END IF;
    
    -- Fecha o arquivo
    UTL_FILE.fclose(v_file);

COMMIT;
     END LOOP;

    EXCEPTION

    WHEN OTHERS THEN
        IF UTL_FILE.is_open(v_file) THEN
            UTL_FILE.fclose(v_file);
        END IF;
        RAISE;
        
        

END;
