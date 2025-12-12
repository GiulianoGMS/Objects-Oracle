CREATE OR REPLACE PROCEDURE NAGP_EXT_XML_PDV (psDtaIni DATE, psDtaFim DATE, psNroEmpresa NUMBER, indReproc VARCHAR2 DEFAULT 'N', psChave VARCHAR2 DEFAULT NULL) AS

  -- Giuliano 10/12/2025 -- Obg pelo presente Alan
  
  -- indReproc indica se extrai o XML novamente
  -- Se for N, confere na tabela de log NAGT_XML_EXTRAIDO se ja foi extraido e nao faz a nova extracao
  -- Default N

  vSQLERRM   VARCHAR2(4000);
  vNomeView  VARCHAR2(200);
  vDiretorio VARCHAR2(200);
  vDescricao VARCHAR2(200);
  vChaveNfe  VARCHAR2(200);
  vEmp       NUMBER;
  vCheckout  NUMBER(30);
  vDta       DATE;
  vExiste    NUMBER(30);
  pDiretorio VARCHAR2(200);
  -- pDirLoja   VARCHAR2(200);
  
BEGIN
  
  SELECT D.directory_name
    INTO pDiretorio
    FROM ALL_DIRECTORIES D
   WHERE D.directory_name = 'EXT_XML_PDV_'||LPAD(psNroEmpresa,3,0);
  
  FOR nfe IN (SELECT 'EXT_AUTORIZADAS'            NomeView,
                     pDiretorio                   Diretorio,
                    'NFe'                         DescricaoNF,
                     N.CHAVENF                    ChaveNfe,
                     Y.NROEMPRESA                 Emp,
                     Y.NROCHECKOUT                Checkout,
                     TRUNC(DTAHORRECEBIMENTO)     Dta,
                     X.XML                        XML
                     
               FROM MONITORPDV.tb_docto  Y INNER JOIN MONITORPDV.TB_DOCTONFEXML X ON X.NROEMPRESA = Y.NROEMPRESA AND X.NROCHECKOUT = Y.NROCHECKOUT AND X.SEQDOCTO = Y.SEQDOCTO  
                                           INNER JOIN MONITORPDV.TB_DOCTONFE N ON N.NROEMPRESA = X.NROEMPRESA AND N.NROCHECKOUT = X.NROCHECKOUT AND N.SEQDOCTO = Y.SEQDOCTO
              WHERE Y.DTAMOVIMENTO BETWEEN psDtaIni AND psDtaFim
                -- AND N.STATUS != 'C'
                AND Y.NROEMPRESA = psNroEmpresa
                AND N.CHAVENF = NVL(psChave, N.CHAVENF)
                
             UNION ALL -- Union Inutilizadas
             
             SELECT 'EXT_INUTILIZADAS'            NopmeView,
                    pDiretorio                    Diretorio,
                   'Inut'                         DescricaoNF,
                   A.CHAVEINUTILIZACAO            ChaveNfe,
                   A.NROEMPRESA                   Emp,
                   A.NROCHECKOUT                  Checkout,
                   A.DTAHORINUTILIZACAO           Dta,
                   A.XMLINUTILIZACAO              XML
                  
              FROM MONITORPDV.TB_DOCTOINUTNFE A
             WHERE TRUNC(A.DTAHORINUTILIZACAO) BETWEEN psDtaIni AND psDtaFim
               AND A.NROEMPRESA = psNroEmpresa
               AND A.CHAVEINUTILIZACAO = NVL(psChave, A.CHAVEINUTILIZACAO)
               AND A.CODRETORNO = 102
               AND 1=2
             )

 LOOP
    vNomeView  := nfe.NomeView;
    vDiretorio := nfe.Diretorio;
    vDescricao := nfe.DescricaoNF;
    vChaveNfe  := nfe.ChaveNfe;
    vEmp       := nfe.Emp;
    vCheckout  := nfe.Checkout;
    vDta       := nfe.Dta;
    
    SELECT COUNT(1)
      INTO vExiste
      FROM NAGT_LOG_EXT_XML N 
     WHERE N.CHAVENFE           = vChaveNfe
       AND N.EMP                = vEmp
       AND NVL(N.NROCHECKOUT,0) = NVL(vCheckout,0);
       
    IF indReproc = 'S' OR NVL(vExiste,0) = 0 AND nfe.Chavenfe IS NOT NULL THEN
    
    BEGIN
     DBMS_XSLPROCESSOR.CLOB2FILE(
        nfe.XML,
        nfe.Diretorio,
        Nfe.DescricaoNF||'_'||nfe.ChaveNfe|| '.xml'
     );

      INSERT INTO NAGT_LOG_EXT_XML VALUES (vNomeView, vDiretorio, vDescricao, vChaveNfe, vEmp, vDta, SYSDATE, 'OK', vCheckout);
      COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        vSQLERRM := SQLERRM;
        INSERT INTO NAGT_LOG_EXT_XML VALUES (vNomeView, vDiretorio, vDescricao, vChaveNfe, vEmp, vDta, SYSDATE, vSQLERRM, vCheckout);
        COMMIT;
    END;
    
    END IF;
    
  END LOOP;
END;
