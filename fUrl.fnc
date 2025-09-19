CREATE OR REPLACE FUNCTION fUrl (psSeqproduto NUMBER) 

  RETURN VARCHAR2 IS 
  vsURL VARCHAR2(4000);
  
  BEGIN
    
  SELECT 'https://assetsmn.s3.us-east-1.amazonaws.com/assets/ofertas/'||psSeqproduto||'.jpg' URL
    INTO vsUrl 
    FROM dual;
  
  RETURN vsUrl;
  
  END;
