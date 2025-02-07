CREATE OR REPLACE PROCEDURE NAGP_GERATITFIN (psTipoDocto  VARCHAR2,
                                             psNumeroNF   NUMBER,
                                             psNroEmpresa NUMBER,
                                             psCGO        NUMBER,
                                             psEspecie    VARCHAR2) IS
-- Para Nota Fiscal 

BEGIN
  DECLARE 
  vRowIdNF VARCHAR2(100);
  vRowIdDF VARCHAR2(100);
  vExiste  NUMBER(7);

 BEGIN
  SELECT COUNT(1)
    INTO vExiste
    FROM FI_TITULO F WHERE F.NROTITULO = psNumeroNF AND F.NROEMPRESA = psNroEmpresa AND CODESPECIE = psEspecie;
    
    IF vExiste = 0 THEN

 BEGIN
      SELECT MAX(Z.ROWID)
        INTO vRowIdNF
        FROM MLF_NOTAFISCAL Z
       WHERE NUMERONF = psNumeroNF
         AND NROEMPRESA = psNroEmpresa
         AND CODGERALOPER = psCGO;
             
      SELECT MAX(Z.ROWID)
        INTO vRowIdDF
        FROM MFL_DOCTOFISCAL Z
       WHERE NUMERODF = psNumeroNF
         AND NROEMPRESA = psNroEmpresa 
         AND CODGERALOPER = psCGO;

    PKG_MAD_FATURAMENTO.SP_GERA_MRL_TITULOFIN(CASE WHEN psTipoDocto = 'DF' THEN vRowIdDF WHEN psTipoDocto = 'NF' THEN vRowIDNF END, 
                                              CASE WHEN psTIpoDocto = 'DF' THEN 'X'      WHEN psTipoDocto = 'NF' THEN 'E'      END, 'I');
    UPDATE MRL_TITULOFIN T SET INDREPLICACAO = 'X'
                         WHERE T.NROEMPRESA = psNroEmpresa
                           AND T.NROTITULO  = psNumeroNF;
    
    COMMIT;
    
--- Integração de Títulos
UPDATE FI_INTEGRAR SET INTEGRAR = INTEGRAR;
COMMIT;

--- Integração de Títulos de Direito (A receber)
BEGIN
  PKG_ADM_INTEGRACAO.SP_GERA_C5CORP_FINANCE(NULL);
END;

--- Integração de Títulos de Obrigação (A Pagar)   
BEGIN
  PKG_ADM_INTEGRACAO.SP_GERA_CORPFINANCE_TITPAG(NULL);
END;

 END;
 
 END IF;
 
END;
END;
