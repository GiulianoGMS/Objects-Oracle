CREATE OR REPLACE VIEW CONSINCO.NAGV_PRODEXCLUSAOITWORKS_ATM AS
SELECT X.SEQIDENTIFICA PRODUTO,
      'Exclusão do vínculo do produto' DECRICAO,
       X.VLRANTERIOR PRODUTO_ATOMICO,
       X.DTAHORAUDITORIA DTAHORAEXCLUSAO

  FROM CONSINCO.MAP_AUDITORIA X
 WHERE X.DTAAUDITORIA >= TRUNC(SYSDATE)
   AND DESCCAMPO = 'Produto Base'
   AND X.VLRANTERIOR IS NOT NULL
   AND REGEXP_REPLACE(TRIM(SUBSTR(VLRATUAL,0,10)),'[^0-9]', '') IS NULL;
