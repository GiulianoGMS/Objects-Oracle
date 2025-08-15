CREATE OR REPLACE PROCEDURE NAGP_EXT_XML_DIA (psDta DATE) AS

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
                AND X.SEQPESSOA != X.NROEMPRESA
                AND ROWNUM = 1
                     
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
                AND ROWNUM = 1
                     
             UNION
             SELECT 'NAGV_EXTRACAO_XML_PDVTOTVS' NomeView,
                    'BLB'                        Diretorio,
                    'NFCe'                       DescricaoNF,
                     Y.CHAVENF                   ChaveNfe,
                     Y.NROEMPRESA                Emp
               FROM MONITORPDV.TB_DOCTONFE Y 
              WHERE TRUNC(Y.DTAHORRECEBIMENTO) = psDta
                AND Y.STATUS != 'C'
                AND ROWNUM = 1
             )

  LOOP
      NAGP_EXT_XML(psChave       => nfe.Chavenfe,
                   psDescricaoNF => nfe.DescricaoNF,
                   psDiretorio   => nfe.Diretorio,
                   psNoveView    => nfe.NomeView);
      INSERT INTO NAGT_XML_EXTRAIDO VALUES (nfe.NomeView, nfe.Diretorio, nfe.DescricaoNF, nfe.ChaveNfe, nfe.Emp, psDta, SYSDATE);
      COMMIT;
  END LOOP;

END;
