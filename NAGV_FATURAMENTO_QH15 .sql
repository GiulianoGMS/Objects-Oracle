ALTER SESSION SET CURRENT_SCHEMA = CONSINCO;
  
CREATE OR REPLACE VIEW CONSINCO.NAGV_FATURAMENTO_QH15 AS

SELECT 
 NROEMPRESA LJ, NROCHECKOUT NRO_PDV, DTAOPERACAO DATA_VENDA,
 
 TO_CHAR(TRUNC(TO_DATE(TO_CHAR(DTAOPERACAO, 'DD/MM/RRRR') || ' ' ||
                        HORAOPERACAO || ':' || MINUTOOPERACAO,
                        'DD/MM/RRRR HH24:MI'),
                'HH') + INTERVAL '15'
          MINUTE *
          FLOOR(TO_NUMBER(TO_CHAR(TO_DATE(TO_CHAR(DTAOPERACAO, 'DD/MM/RRRR') || ' ' ||
                                          HORAOPERACAO || ':' ||
                                          MINUTOOPERACAO,
                                          'DD/MM/RRRR HH24:MI'),
                                  'MI')) / 15),
          'HH24:MI') || ' - ' ||
  TO_CHAR((TRUNC(TO_DATE(TO_CHAR(DTAOPERACAO, 'DD/MM/RRRR') || ' ' ||
                         HORAOPERACAO || ':' || MINUTOOPERACAO,
                         'DD/MM/RRRR HH24:MI'),
                 'HH') + INTERVAL '15'
           MINUTE *
           FLOOR(TO_NUMBER(TO_CHAR(TO_DATE(TO_CHAR(DTAOPERACAO, 'DD/MM/RRRR') || ' ' ||
                                           HORAOPERACAO || ':' ||
                                           MINUTOOPERACAO,
                                           'DD/MM/RRRR HH24:MI'),
                                   'MI')) / 15) + '0.011'),
          'HH24:MI') AS QUARTO_DE_HORA, 
          
 SUM(X.QTDOPERACAO) QTDITEM,
 TO_CHAR(SUM(X.VLROPERACAO),
          'FM999G999G999D90',
          'NLS_NUMERIC_CHARACTERS='',.''') FATURAMENTO,
 COUNT(DISTINCT SEQNF) QTD_CUPONS

  FROM CONSINCO.FATO_VENDA X

 WHERE 1 = 1
   
   AND CODGERALOPER IN (37,48,123,610,615,613,810,916,910,911)

 GROUP BY TRUNC(TO_DATE(TO_CHAR(DTAOPERACAO, 'DD/MM/RRRR') || ' ' ||
                         HORAOPERACAO || ':' || MINUTOOPERACAO,
                         'DD/MM/RRRR HH24:MI'),
                 'HH') + INTERVAL '15' MINUTE * FLOOR(TO_NUMBER(TO_CHAR(TO_DATE(TO_CHAR(DTAOPERACAO, 'DD/MM/RRRR') || ' ' || HORAOPERACAO || ':' || MINUTOOPERACAO, 'DD/MM/RRRR HH24:MI'), 'MI')) / 15),
          DTAOPERACAO, NROEMPRESA, NROCHECKOUT

 ORDER BY NROEMPRESA, 4, NROCHECKOUT,
          TRUNC(TO_DATE(TO_CHAR(DTAOPERACAO, 'DD/MM/RRRR') || ' ' ||
                         HORAOPERACAO || ':' || MINUTOOPERACAO,
                         'DD/MM/RRRR HH24:MI'),
                 'HH') + INTERVAL '15' MINUTE * FLOOR(TO_NUMBER(TO_CHAR(TO_DATE(TO_CHAR(DTAOPERACAO, 'DD/MM/RRRR') || ' ' || HORAOPERACAO || ':' || MINUTOOPERACAO, 'DD/MM/RRRR HH24:MI'), 'MI')) / 15);

