CREATE OR REPLACE PROCEDURE NAGP_EXT_XML_DIA (psDta DATE) AS

BEGIN
  
  FOR nfe IN (
             SELECT 'NAGV_EXTRACAO_XML' NomeView,
                    'BLB'               Diretorio,
                    'Ent'               DescricaoNF,
                    X.NFECHAVEACESSO    ChaveNfe
               FROM MLF_NOTAFISCAL X 
              WHERE X.DTAENTRADA = psDta
                AND X.STATUSNF != 'C'
                     
             UNION
             SELECT 'NAGV_EXTRACAO_XML' NomeView,
                    'BLB'               Diretorio,
                    'Saida'            DescricaoNF,
                    Z.NFECHAVEACESSO    ChaveNfe
               FROM MFL_DOCTOFISCAL Z
              WHERE Z.DTAMOVIMENTO = psDta
                AND Z.STATUSDF != 'C'
                     
             UNION
             SELECT 'NAGV_EXTRACAO_XML_PDVTOTVS' NomeView,
                    'BLB'                        Diretorio,
                    'NFCe'                       DescricaoNF,
                     Y.CHAVENF                   ChaveNfe
               FROM MONITORPDV.TB_DOCTONFE Y 
              WHERE TRUNC(Y.DTAHORRECEBIMENTO) = psDta
                AND Y.STATUS != 'C'
             )

  LOOP
      NAGP_EXT_XML(psChave       => nfe.Chavenfe,
                   psDescricaoNF => nfe.DescricaoNF,
                   psDiretorio   => nfe.Diretorio,
                   psNoveView    => nfe.NomeView);
  END LOOP;

END;
