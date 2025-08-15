CREATE OR REPLACE PROCEDURE NAGP_EXT_XML_DIA (psDta DATE, psNroEmpresa NUMBER) AS

  vSQLERRM   VARCHAR2(4000);
  vNomeView  VARCHAR2(200);
  vDiretorio VARCHAR2(200);
  vDescricao VARCHAR2(200);
  vChaveNfe  VARCHAR2(200);
  vEmp       NUMBER;
  
BEGIN
  
  FOR nfe IN (
             SELECT 'NAGV_EXTRACAO_XML' NomeView,
                    'BLB'               Diretorio,
                    'Ent'               DescricaoNF,
                    X.NFECHAVEACESSO    ChaveNfe, 
                    NROEMPRESA          Emp
                    
               FROM MLF_NOTAFISCAL X 
              WHERE X.DTAENTRADA = psDta
                AND X.STATUSNF != 'C'
                AND X.MODELONF = 55
                AND X.NROEMPRESA = psNroEmpresa
                     
             UNION
             SELECT 'NAGV_EXTRACAO_XML' NomeView,
                    'BLB'               Diretorio,
                    'Saida'             DescricaoNF,
                    Z.NFECHAVEACESSO    ChaveNfe,
                    NROEMPRESA          Emp
                    
               FROM MFL_DOCTOFISCAL Z
              WHERE Z.DTAMOVIMENTO = psDta
                AND Z.STATUSDF != 'C'
                AND Z.STATUSNFE = 4
                AND Z.MODELODF = 55
                AND Z.NROEMPRESA = psNroEmpresa
                     
             UNION
             SELECT 'NAGV_EXTRACAO_XML_PDVTOTVS' NomeView,
                    'BLB'                        Diretorio,
                    'NFCe'                       DescricaoNF,
                     Y.CHAVENF                   ChaveNfe,
                     Y.NROEMPRESA                Emp
               FROM MONITORPDV.TB_DOCTONFE Y 
              WHERE TRUNC(Y.DTAHORRECEBIMENTO) = psDta
                AND Y.STATUS != 'C'
                AND Y.NROEMPRESA = psNroEmpresa
             )

 LOOP
    vNomeView  := nfe.NomeView;
    vDiretorio := nfe.Diretorio;
    vDescricao := nfe.DescricaoNF;
    vChaveNfe  := nfe.ChaveNfe;
    vEmp       := nfe.Emp;

    BEGIN
      NAGP_EXT_XML(
        psChave       => vChaveNfe,
        psDescricaoNF => vDescricao,
        psDiretorio   => vDiretorio,
        psNoveView    => vNomeView
      );

      INSERT INTO NAGT_XML_EXTRAIDO VALUES (vNomeView, vDiretorio, vDescricao, vChaveNfe, vEmp, psDta, SYSDATE, 'OK');
      COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        vSQLERRM := SQLERRM;
        INSERT INTO NAGT_XML_EXTRAIDO VALUES (vNomeView, vDiretorio, vDescricao, vChaveNfe, vEmp, psDta, SYSDATE, vSQLERRM);
        COMMIT;
    END;
    
  END LOOP;
END;
