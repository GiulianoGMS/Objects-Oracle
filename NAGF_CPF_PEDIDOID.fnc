CREATE OR REPLACE FUNCTION NAGF_CPF_PEDIDOID (vsSeqNF      NUMBER, 
                                              vsNroEmpresa NUMBER, 
                                              vsDta        DATE,
                                              vsTipRetorno VARCHAR2)
  RETURN VARCHAR2 IS 
  
 -- vsTipoRetorno: 'C' = CPF, 'P' = Pedido ID
 
    vsRetorno  VARCHAR2(20); 
    vsNCPF     VARCHAR2(20);
    vsPedidoID VARCHAR2(20);
    
 ---- Função Criada por Cipolla para buscar os CPFs que são identificados no Meu Nagumo.
   -- Alterado por Giuliano em 06/02/2025, retornar também o PEDIDOID
 
BEGIN
 BEGIN 
   --- Identificação PDV Remarca
        SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4')*/  
               Z.CPFCNPJ, 
               NVL(NAGF_ECOMM_CANALVENDA@LINK_C5(X.NROEMPRESA, X.NUMERODF, X.DTAMOVIMENTO), P.PEDIDOID) PEDIDOID
          INTO vsNCPF, vsPedidoID
          FROM MFL_DOCTOFISCAL@LINK_C5 X INNER JOIN PDV_DOCTO@LINK_C5 Y ON (X.NFECHAVEACESSO = Y.CHAVEACESSO)
                                         INNER JOIN PDV_DESCONTO@LINK_C5 Z ON (Z.SEQDOCTO = Y.SEQDOCTO)
                                          LEFT JOIN MAD_PEDVENDA@LINK_C5 P ON P.NROPEDVENDA = X.NROPEDIDOVENDA
                                          
         WHERE X.CODGERALOPER IN (37,48,123,610,615,613,810,916,910,911,76)
           AND X.SEQNF = vsSeqNF
           AND X.NROEMPRESA = vsNroEmpresa
           AND Y.DTAMOVIMENTO = vsDta;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          vsNCPF     := NULL;
          vsPedidoId := NULL;
          
        IF vsNCPF IS NULL THEN
          
        BEGIN           
     --- Identificação PDV Consinco
      SELECT X.CNPJCPF, 
             NVL(NAGF_ECOMM_CANALVENDA@LINK_C5(X.NROEMPRESA, A.NUMERODF, A.DTAMOVIMENTO), P.PEDIDOID) PEDIDOID
        INTO vsNCPF, vsPedidoID
        FROM MFL_DOCTOFISCAL@LINK_C5 A INNER JOIN MFL_DOCTOFIDELIDADE@LINK_C5 x ON A.SEQNF = X.SEQNF
                                        LEFT JOIN MAD_PEDVENDA@LINK_C5 P ON P.NROPEDVENDA = A.NROPEDIDOVENDA
                                        
       WHERE A.CODGERALOPER IN (37,48,123,610,615,613,810,916,910,911,76)
         AND X.SEQNF = vsSeqNF
         AND X.NROEMPRESA = VSNROEMPRESA;
  
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              vsNCPF := null;
              
          END;          
          
        IF vsNCPF IS NULL THEN
          
       SELECT TO_NUMBER(G.NROCGCCPF||G.DIGCGCCPF) CPF, PEDIDOID
         INTO vsNCPF, vsPedidoID
         FROM MFL_DOCTOFISCAL@LINK_C5 X INNER JOIN GE_PESSOA@LINK_C5 G ON G.SEQPESSOA = X.SEQPESSOA
                                INNER JOIN MAD_PEDVENDA@LINK_C5 P ON P.NROPEDVENDA = X.NROPEDIDOVENDA
        
        WHERE X.SEQNF = vsSeqNF
          AND X.CODGERALOPER IN (37,48,123,610,615,613,810,916,910,911,76);
          
        END IF;
        END IF;
          END;
 
 IF    vsTipRetorno = 'C' THEN
    vsRetorno := vsNCPF;
    
 ELSIF vsTipRetorno = 'P' THEN
    vsRetorno := vsPedidoId;
 END IF;
 
 RETURN vsRetorno;
 
END NAGF_CPF_PEDIDOID;

