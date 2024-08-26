CREATE OR REPLACE VIEW CONSINCO.MRLV_PROMOCAOESPECIAL AS

-- SELECT ORIGINAL:
/*
SELECT A.SEQPRODUTO,
       A.QTDEMBALAGEM,
       A.NROEMPRESA,
       A.CODACESSOESPECIAL,
       A.VLRPRECOPROMOC,
       A.QTDESOLICITADA,
       A.DTAINICIO,
       A.DTAFIM,
       NVL(A.INDEMIETIQUETA,'N') AS INDEMIETIQUETA,
       A.SEQPROMOCESPECIAL,
       A.MOTIVOACAOPROMOC
FROM MRL_PROMOCESPECIALHIST A
WHERE A.STATUS = 'A';*/

-- NOVO:

CREATE OR REPLACE VIEW MRLV_PROMOCAOESPECIAL AS
SELECT A.SEQPRODUTO,
       A.QTDEMBALAGEM,
       A.NROEMPRESA,
       A.CODACESSOESPECIAL,
       A.VLRPRECOPROMOC,
       -- Alt. Giuliano - 26/08/24
       -- Divide sempre por 2 pois a etiqueta é dupla
       -- CEIL arredonda pra cima pois se for solicitado 11, irá impimir 6 etiquetas (resultando em 12 duplas)
       -- Traz apenas a quantidade nao emitida
       CEIL((A.QTDESOLICITADA - A.QTDEETIQEMITIDA)/2) QTDESOLICITADA,
       A.DTAINICIO,
       A.DTAFIM,
       NVL(A.INDEMIETIQUETA,'N') AS INDEMIETIQUETA,
       A.SEQPROMOCESPECIAL,
       A.MOTIVOACAOPROMOC
FROM MRL_PROMOCESPECIALHIST A
WHERE A.STATUS = 'A'

 -- Alterado por Giuliano -- Controle de emissão
 -- Retornar apenas se a quantidade impressa for menor que a solicitada
 
  AND A.QTDEETIQEMITIDA < A.QTDESOLICITADA
