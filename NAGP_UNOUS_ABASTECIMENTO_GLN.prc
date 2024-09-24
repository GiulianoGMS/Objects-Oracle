CREATE OR REPLACE PROCEDURE NAGP_UNOUS_ABASTECIMENTO_GLN AS

  OBJ_PARAM_SMTP C5_TP_PARAM_SMTP;
  
  -- Nova Versao por Giuliano em 23/09/2024 - Loop e Faturamento por empresa adicionado na Proc

BEGIN

  --- Criado por Cipolla em 16/09/2024 para enviar os dados que vêm da Unous para sugestão de Abastecimento automático para as lojas.
  --- Essa proc será executada ao termino da inserção dos dados da API, a rotina do Leonardo vai chamar a proc no final do insert na tabela de origem NAGT_UNOUS_ABASTECIMENTO
  
  -- Comeca o Loop de Empresa conforme disponivel na sugestao e ainda nao utilizada
  
  FOR emp IN (SELECT DISTINCT T.NRO_EMPRESA_ORIGEM EMP_ABASTEC 
                FROM NAGT_UNOUS_ABASTECIMENTO T
               WHERE NVL(T.PROCESSADO, 'N') = 'N'
                 AND T.DATA_INTEGRACAOERP IS NULL)
                 
      LOOP

  FOR H IN (SELECT T.ROWID ID,
                   T.ID_PEDIDO,
                   T.NRO_EMPRESA_DESTINO,
                   T.DATA_EMISSAO,
                   T.DATA_RECEBIMENTO,
                   T.NRO_EMPRESA_ORIGEM,
                   T.SEQITEM,
                   T.SEQPRODUTO,
                   T.QTDE,
                   T.PROCESSADO,
                   T.DATA_INTEGRACAOERP
              FROM NAGT_UNOUS_ABASTECIMENTO T
             WHERE NVL(T.PROCESSADO, 'N') = 'N'
                   AND T.DATA_INTEGRACAOERP IS NULL
                   AND T.NRO_EMPRESA_ORIGEM = emp.EMP_ABASTEC)
  LOOP
  
    BEGIN
    
      INSERT INTO MAC_AUXGERCOMPRASUGESTAO
        (SEQPRODUTO,
         SEQFORNECEDOR,
         NROEMPRESA,
         SUGESTAOLOTE,
         DTAHORAPROCESSAMENTO,
         DTAHORAPEDIDO,
         TIPOLOTE,
         IDCONTROLEINTERNO,
         QTDEMBALAGEM,
         INDUTILIZADA)
      VALUES
        (H.SEQPRODUTO,
         H.NRO_EMPRESA_ORIGEM,
         H.NRO_EMPRESA_DESTINO,
         H.QTDE,
         SYSDATE,
         H.DATA_RECEBIMENTO,
         'A',
         REPLACE(H.ID_PEDIDO, '-'),
         NVL(FPADRAOEMBCOMPRAPROD(H.SEQPRODUTO, 1), 1),
         'N');
    
    COMMIT;
      --- qtdembalagem - chama a proc FPADRAOEMBCOMPRAPROD para retornar a embalagem padrão de compra, senão existir retorno 1
    
      UPDATE NAGT_UNOUS_ABASTECIMENTO Z
         SET Z.PROCESSADO = 'S',
             Z.DATA_INTEGRACAOERP = SYSDATE
       WHERE Z.ROWID = H.ID;
           
       
       
    END;
  
  END LOOP;
  
  -- Cai denovo no loop de Empresa e comeca o faturamento apos insercao na oficial da C5
  
    NAGP_MAC_PROCLOTEMODELOABASTEC(emp.EMP_ABASTEC);
    
  COMMIT; -- Commita apenas se o faturamento tiver sucesso, caso contrario envia e-mail e PROCESSADO se mantem 'N'
  END LOOP;
  
  
  
  EXCEPTION
      WHEN OTHERS THEN
           
        --- Se apresentar erro na rotina, dispara e-mail
      
        SP_ENVIA_EMAIL(OBJ_PARAM      => OBJ_PARAM_SMTP,
                       PSDESTINATARIO => 'marcel.cipolla@nagumo.com.br;giuliano.gomes@nagumo.com.br',
                       PSASSUNTO      => 'Erro ao gerar rotina de retorno da Unous para Consinco (Abastecimento).',
                       PSMENSAGEM     => 'Erro ao gerar rotina de retorno da Unous para Consinco (Abastecimento).',
                       PSINDUSAHTML   => 'N');
                         
                       
                       
END NAGP_UNOUS_ABASTECIMENTO_GLN;
