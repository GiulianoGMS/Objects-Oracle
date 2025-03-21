CREATE OR REPLACE VIEW NAGV_BASE_MRL_PROMOCESPECIAL2 AS
SELECT (SELECT MAX(C.SEQPROMOCESPECIAL) FROM MRL_PROMOCESPECIALHIST C) + ROWNUM SEQPROMOCESPECIAL,
       B.SEQPRODUTO,
       1 QTDEMBALAGEM,
       TO_NUMBER(SUBSTR(A.USUARIO,5,2)) NROEMPRESA,
       CODIGO_BARRAS CODACESSOESPECIAL,
       A.PRECO_REBAIXA VLRPRECOPROMOC,
       A.QUANTIDADE QTDESOLICITADA,
       A.QUANTIDADE QTDEETIQEMITIDA,
       TRUNC(SYSDATE) DTAINICIO,
       TO_DATE(TO_CHAR(A.DATA_VENCIMENTO, 'DD-MON-YY')) DTAFIM,
       'A' STATUS,
       'REPLICACAO CONTROLEDATAS SATELITSKY' MOTIVOACAOPROMOC,
       TO_DATE(TO_CHAR(A.DATA_INCLUSAO, 'DD-MON-YY')) DTAHORALTERACAO,
       'AUTOMATICO' USUALTERACAO,
       SYSDATE DTAHORAPROVACAO,
       'AUTOMATICO' USUAPROVACAO,
       NULL MOTIVOREPROVA,
       NULL INDLIBERACAO,
       NULL USULIBERACAO,
       NULL DTAHORALIBERACAO,
       NULL INDEMIETIQUETA,
       NULL SEQPROMOCESPECIALORIGEM,
       NULL INDREPLICAFAMILIA,
       NULL INDREPLICAASSOCIADO,
       NULL INDREPLICARELACIONADO

       FROM PRODUTO_VENCIMENTO@SATELITSKY A INNER JOIN MAP_PRODCODIGO B ON TO_CHAR(A.EAN) = B.CODACESSO

 WHERE 1=1

   AND TO_DATE(TO_CHAR(A.DATA_VENCIMENTO, 'DD-MON-YY')) >= SYSDATE
   AND TO_DATE(TO_CHAR(A.DATA_VENCIMENTO, 'DD-MON-YY')) < SYSDATE + 100
   AND FL_RECUSADO   = 0
   AND PRECO_REBAIXA > 0
   AND JUSTIICATIVA  IS NULL
   AND DATA_RECUSA   IS NULL
   AND B.SEQPRODUTO IS NOT NULL;
