CREATE OR REPLACE PROCEDURE NAGP_EXT_XML_DIA (psDtaIni DATE, psDtaFim DATE, psNroEmpresa NUMBER, indReproc VARCHAR2 DEFAULT 'N') AS

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
  
BEGIN
  
  SELECT D.directory_name
    INTO pDiretorio
    FROM ALL_DIRECTORIES D
   WHERE D.directory_name = 'EXT_XML_LOJA_'||LPAD(psNroEmpresa,3,0);
  
  FOR nfe IN (
             SELECT 'NAGV_EXTRACAO_XML' NomeView,
                    pDiretorio          Diretorio,
                    'Ent'               DescricaoNF,
                    X.NFECHAVEACESSO    ChaveNfe, 
                    NROEMPRESA          Emp,
                    NULL                Checkout,
                    DTAEMISSAO          Dta
                    
               FROM MLF_NOTAFISCAL X 
              WHERE X.DTAEMISSAO BETWEEN psDtaIni AND psDtaFim
                AND X.STATUSNF != 'C'
                AND X.MODELONF = 55
                AND X.NROEMPRESA = psNroEmpresa
                     
             UNION
             SELECT 'NAGV_EXTRACAO_XML' NomeView,
                    pDiretorio          Diretorio,
                    'Saida'             DescricaoNF,
                    Z.NFECHAVEACESSO    ChaveNfe,
                    NROEMPRESA          Emp,
                    NULL                Checkout,
                    DTAMOVIMENTO        Dta
                    
               FROM MFL_DOCTOFISCAL Z
              WHERE Z.DTAMOVIMENTO BETWEEN psDtaIni AND psDtaFim
                AND Z.STATUSDF != 'C'
                AND Z.STATUSNFE = 4
                AND Z.MODELODF = 55
                AND Z.NROEMPRESA = psNroEmpresa
                     
             UNION
             SELECT 'NAGV_EXTRACAO_XML_PDVTOTVS' NomeView,
                    pDiretorio                   Diretorio,
                    'NFCe'                       DescricaoNF,
                     Y.CHAVENF                   ChaveNfe,
                     Y.NROEMPRESA                Emp,
                     Y.NROCHECKOUT               Checkout,
                     TRUNC(DTAHORRECEBIMENTO)    Dta
                     
               FROM MONITORPDV.TB_DOCTONFE Y 
              WHERE TRUNC(Y.DTAHORRECEBIMENTO) BETWEEN psDtaIni AND psDtaFim
                AND Y.STATUS != 'C'
                AND Y.NROEMPRESA = psNroEmpresa
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
      FROM NAGT_XML_EXTRAIDO N 
     WHERE N.CHAVENFE           = vChaveNfe
       AND N.EMP                = vEmp
       AND NVL(N.NROCHECKOUT,0) = NVL(vCheckout,0);
       
    IF indReproc = 'S' OR NVL(vExiste,0) = 0 THEN
    
    BEGIN
      NAGP_EXT_XML(
        psChave       => vChaveNfe,
        psDescricaoNF => vDescricao,
        psDiretorio   => vDiretorio,
        psNoveView    => vNomeView
      );

      INSERT INTO NAGT_XML_EXTRAIDO VALUES (vNomeView, vDiretorio, vDescricao, vChaveNfe, vEmp, vDta, SYSDATE, 'OK', vCheckout);
      COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        vSQLERRM := SQLERRM;
        INSERT INTO NAGT_XML_EXTRAIDO VALUES (vNomeView, vDiretorio, vDescricao, vChaveNfe, vEmp, vDta, SYSDATE, vSQLERRM, vCheckout);
        COMMIT;
    END;
    
    END IF;
    
  END LOOP;
END;
