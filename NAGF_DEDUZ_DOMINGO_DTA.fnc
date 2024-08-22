CREATE OR REPLACE FUNCTION CONSINCO.NAGF_DEDUZ_DOMINGO_DTA (vsDta1 DATE,
                                                             vsDta2 DATE)
 RETURN VARCHAR2 IS
  vQtdDomingos NUMBER(3);
 BEGIN
   SELECT CASE WHEN TO_NUMBER(TO_CHAR(vsDta1, 'D')) < TO_NUMBER(TO_CHAR(vsDta2, 'D')) THEN
          CEIL((vsDta1 - vsDta2) / 7) ELSE 0 END QTD_DOMINGOS
     INTO vQtdDomingos
   FROM DUAL;
   
  RETURN vQtdDomingos; 
  
END;
