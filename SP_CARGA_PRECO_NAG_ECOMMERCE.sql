CREATE OR REPLACE PROCEDURE SP_CARGA_PRECO_NAG_ECOMMERCE(pnNROJOB     IN   NUMBER,
                                                                  pnMODEMPRESA IN   NUMBER   ) IS
  vsSoft           varchar2(50);
  vsHora           varchar2(2);
  vsTipoCarga      varchar2(10);
  obj_param_smtp   c5_tp_param_smtp;

BEGIN

     FOR dados IN (SELECT NROSEGMENTO, NROEMPRESA FROM CONSINCO.NAGV_EMPSEG_ECOMMERCE)
   
     LOOP
    BEGIN
             --Gerando promocao
             PKG_MAD_ADMPRECO.SP_GeraPromocao(dados.Nrosegmento, dados.Nroempresa, trunc(sysdate), 'AUTOMATICO');
             --Validando precos
             PKG_MAD_ADMPRECO.SP_ValidaPreco (dados.Nrosegmento, dados.Nroempresa, 'AUTOMATICO', 'T');
             
     COMMIT;
         EXCEPTION
            WHEN OTHERS THEN
     
              CONSINCO.SP_ENVIA_EMAIL(obj_param      => obj_param_smtp,
                             psDestinatario => 'giuliano.gomes@nagumo.com.br;bruna.macedo@nagumo.com.br;marcel.cipolla@nagumo.com.br',
                             psAssunto      => 'Erro ao gerar a carga de preços Ecommerce ' || to_char(dados.Nroempresa),
                             psMensagem     => 'Erro ao gerar a carga de preços Ecommerce ' || to_char(dados.Nroempresa)||' - '|| TO_CHAR(SYSDATE),
                             psindusahtml   => 'N');
    END;
     END LOOP;
     
END;

-- View de/para Empresa x Segmento Ecommerce

CREATE OR REPLACE VIEW CONSINCO.NAGV_EMPSEG_ECOMMERCE AS

SELECT NROSEGMENTO, NROEMPRESA 
  FROM CONSINCO.MAX_EMPRESASEG
 WHERE 1=1
   AND NROSEGMENTO IN (5,8)
   AND STATUS = 'A'
   
  ORDER BY 2
  
--

SELECT * FROM CONSINCO.NAGV_EMPSEG_ECOMMERCE
