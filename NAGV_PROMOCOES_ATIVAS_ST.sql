CREATE OR REPLACE VIEW NAGV_PROMOCOES_ATIVAS_ST AS
SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4')*/
       DISTINCT B.SEQPRODUTO                                                                SKU,
                A.NROEMPRESA                                                                storeReference,
               'Desconto DePor Tabloide'                                                    Description,
                TO_CHAR(TO_DATE(B.DTAINICIOPROM, 'DD/MM/YY'), 'YYYY-MM-DD"T"HH24:MI:SS"Z"') startDateTime,
                B.DTAINICIOPROM                                                             startDateTime_Date,
                TO_CHAR(TO_DATE(B.DTAFIMPROM, 'DD/MM/YY'),    'YYYY-MM-DD"T"HH24:MI:SS"Z"') endDateTime,
                B.DTAFIMPROM                                                                endDateTime_Date,
                DECODE(B.STATUS, 'A', 'TRUE', 'I', 'INACTIVE')                              isActive,
                B.PRECOPROMOCIONAL                                                          Price

  FROM CONSINCO.MRL_PROMOCAO A INNER JOIN CONSINCO.MRL_PROMOCAOITEM B ON A.SEQPROMOCAO = B.SEQPROMOCAO
                                                                     AND A.NROEMPRESA  = B.NROEMPRESA
                                                                     AND A.NROSEGMENTO = B.NROSEGMENTO
                                                                     AND A.CENTRALLOJA = B.CENTRALLOJA
                                                                     AND QTDEMBALAGEM  = 1

 WHERE B.QTDEMBALAGEM = 1
   AND A.CENTRALLOJA = 'M'
   AND B.STATUS != 'I'
   AND TRUNC(SYSDATE) BETWEEN B.DTAINICIOPROM AND B.DTAFIMPROM

UNION ALL

-- Ativaveis

SELECT DISTINCT B.SEQPRODUTO                                                                SKU,
                E.NROEMPRESA                                                                storeReference,
               'DescontoDePor Ativavel'                                                     Description,
                TO_CHAR(TO_DATE(NVL(B.DTAVIGENCIAINI, A.DTAINICIO), 'DD/MM/YY'), 'YYYY-MM-DD"T"HH24:MI:SS"Z"') startDateTime,
                NVL(B.DTAVIGENCIAINI, A.DTAINICIO)                                          startDateTime_Date,
                TO_CHAR(TO_DATE(NVL(B.DTAVIGENCIAFIM, A.DTAFIM), 'DD/MM/YY'),    'YYYY-MM-DD"T"HH24:MI:SS"Z"') endDateTime,
                NVL(B.DTAVIGENCIAFIM, A.DTAFIM)                                             endDateTime_Date,
                DECODE('A', 'A', 'TRUE', 'I', 'INACTIVE')                                   isActive,
                B.PRECOPROMOCIONAL                                                          Price

  FROM CONSINCO.MRL_ENCARTE A INNER JOIN CONSINCO.MRL_ENCARTEPRODUTO B ON A.SEQENCARTE = B.SEQENCARTE
                              INNER JOIN CONSINCO.MAP_PRODUTO C        ON B.SEQPRODUTO = C.SEQPRODUTO
                              INNER JOIN MRL_ENCARTEEMP E ON E.SEQENCARTE = A.SEQENCARTE

 WHERE B.PRECOPROMOCIONAL > 0
   AND QTDEMBALAGEM = 1
   AND DESCRICAO LIKE 'MEU NAGUMO%'
   AND TRUNC(SYSDATE) BETWEEN NVL(B.DTAVIGENCIAINI, A.DTAINICIO) AND NVL(B.DTAVIGENCIAFIM, A.DTAFIM)

UNION ALL

-- Meu Nagumo

SELECT DISTINCT A.SEQPRODUTO                                                                SKU,
                A.NROEMPRESA                                                                storeReference,
               'DescontoDePor MeuNagumo'                                                    Description,
                TO_CHAR(TO_DATE(A.DTAINICIO, 'DD/MM/YY'),  'YYYY-MM-DD"T"HH24:MI:SS"Z"')    startDateTime,
                DTAINICIO                                                                   startDateTime_Date,
                TO_CHAR(TO_DATE(A.DTAFIM, 'DD/MM/YY'),    'YYYY-MM-DD"T"HH24:MI:SS"Z"')     endDateTime,
                DTAFIM                                                                      endDateTime_Date,
                DECODE('A', 'A', 'TRUE', 'I', 'INACTIVE')                                   isActive,
                A.PRECOPROMOCAO                                                             Price

  FROM CONSINCO.NAGV_BASE_PROMOC_PDV A

 WHERE 1=1
   AND CODPARCEIRO = 700

UNION ALL

-- Personalizada

SELECT DISTINCT B.SEQPRODUTO                                                                SKU,
                E.NROEMPRESA                                                                storeReference,
               'DescontoDePor Ativavel'                                                     Description,
                TO_CHAR(TO_DATE(NVL(B.DTAVIGENCIAINI, A.DTAINICIO), 'DD/MM/YY'), 'YYYY-MM-DD"T"HH24:MI:SS"Z"') startDateTime,
                NVL(B.DTAVIGENCIAINI, A.DTAINICIO)                                          startDateTime_Date,
                TO_CHAR(TO_DATE(NVL(B.DTAVIGENCIAFIM, A.DTAFIM), 'DD/MM/YY'),    'YYYY-MM-DD"T"HH24:MI:SS"Z"') endDateTime,
                NVL(B.DTAVIGENCIAFIM, A.DTAFIM)                                             endDateTime_Date,
                DECODE('A', 'A', 'TRUE', 'I', 'INACTIVE')                                   isActive,
                B.PRECOPROMOCIONAL                                                          Price

  FROM CONSINCO.MRL_ENCARTE A INNER JOIN CONSINCO.MRL_ENCARTEPRODUTO B ON A.SEQENCARTE = B.SEQENCARTE
                              INNER JOIN CONSINCO.MAP_PRODUTO C        ON B.SEQPRODUTO = C.SEQPRODUTO
                               LEFT JOIN MAX_EMPRESA E                 ON 1=1 AND E.NROEMPRESA < 300

 WHERE QTDEMBALAGEM = 1
   AND DESCRICAO LIKE 'MN PERSONALIZADA%'
   AND TRUNC(SYSDATE) BETWEEN NVL(B.DTAVIGENCIAINI, A.DTAINICIO) AND NVL(B.DTAVIGENCIAFIM, A.DTAFIM)
;
