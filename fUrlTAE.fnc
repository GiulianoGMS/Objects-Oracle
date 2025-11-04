CREATE OR REPLACE FUNCTION fUrlTAE

  RETURN VARCHAR2  AS
  retorno VARCHAR2(300);
  
  BEGIN
    retorno := 'https://totvssign.totvs.app/webapptotvssign/auth/sign-in';
  
  RETURN retorno;
  
  END;
