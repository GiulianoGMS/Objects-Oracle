CREATE OR REPLACE FUNCTION NAGF_PALIATIVO_CCLASSTRIB_DEV (psSeqNFRef MLF_NOTAFISCAL.SEQNFREF%TYPE)

 RETURN VARCHAR2 IS

  pdcClassFixo  VARCHAR2(30);
  pdDtaFixa     VARCHAR2(10);
  pdCampoDta    VARCHAR2(1);
  psDtaemissao  DATE;
  psDtarecebto  DATE;
  psDataRetorno DATE;
  psRetorno     NUMBER(30);  
  
  BEGIN
    
  -- Giuliano 02/01/2026
  -- Proc para fixar o cClasstrib na emissoa de devolucoes de notas referenciadas ate uma data limite
  
  -- Busca valor dos parametros dinamicos
    
  SP_BUSCAPARAMDINAMICO('NAGUMO',0,'DEV_CLASSTRIB_FIXO','S', NULL,
                        'cClasstrib fixo para preenchimento das emissoes de devolucoes ate a data definida no PD DEV_DATA_FIXA_CCLASSTRIB',  pdcClassFixo);
  SP_BUSCAPARAMDINAMICO('NAGUMO',0,'DEV_DATA_FIXA_CCLASSTRIB','D', NULL,
                        'Data fixa para preenchimento do campo cClasstrib de acordo com PD DEV_CLASSTRIB_FIXO. A emissao de devolucao ira emitir a informacao do PD ate a data limite considerando a data da nota referenciada',  pdDtaFixa);
  SP_BUSCAPARAMDINAMICO('NAGUMO',0,'DEV_CAMPO_NFREF_CCLASSTRIB','S', NULL,
                        'Campo que sera validado na parametrizacao do PD DEV_DATA_FIXA_CCLASSTRIB - E = Emissao, R = Recebimento',  pdCampoDta);
  
  -- Busca a data da nota de entrada referenciada
  SELECT DTAEMISSAO, DTARECEBIMENTO
    INTO psDtaemissao, psDtarecebto
    FROM MLF_NOTAFISCAL X
   WHERE X.SEQNF = psSeqNFRef;
   
  -- Descobre qual campo vai utilizar no criterio
  IF pdCampoDTA = 'E' THEN
     psDataRetorno := psDtaemissao;
     ELSE
     psDataRetorno := psDtarecebto;
  END IF;
  
  -- Valida se a data que retornou é menor que a data configurada no PD 
  IF psDataRetorno <= TO_DATE(pdDtaFixa, 'DD/MM/YYYY') THEN
     psRetorno := pdcClassFixo;
  ELSE
     psRetorno := NULL;
  END IF;
  
  RETURN psRetorno; 
  
END;
