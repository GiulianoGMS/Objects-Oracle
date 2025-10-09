CREATE OR REPLACE VIEW NAGV_TAE_USU_MSG AS

SELECT 'Você possui '||COUNT(DISTINCT CASE WHEN X.STATUS = 'Aguardando assinatura do envelope' THEN NRO_ACORDO ELSE NULL END) ||' Acordos aguardando assinatura, '||
       COUNT(DISTINCT CASE WHEN X.STATUS = 'Envelope rejeitado' THEN NRO_ACORDO ELSE NULL END) ||' Rejeitados, ' ||
       COUNT(DISTINCT CASE WHEN X.STATUS = 'Fornecedor sem e-mail cadastrado.' THEN NRO_ACORDO ELSE NULL END) ||' sem Email' MSG,
       X.USUARIO_INCLUSAO 
  FROM NAGV_TAE_ACORDOS_V2 X 
  GROUP BY USUARIO_INCLUSAO

-- Select na config do alerta

SELECT NVL(MAX(MSG), 'Você não possui acordos pendentes :)') FROM NAGV_TAE_USU_MSG X WHERE X.USUARIO_INCLUSAO = (SELECT SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') FROM DUAL)
