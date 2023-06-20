CREATE OR REPLACE FUNCTION NAGF_BUSCAULTDTAPEDIDO (p_Seqfornecedor NUMBER) RETURN DATE IS
                                                                           v_proxped DATE;
                                                                           v_diasconfig NUMBER;
                                                                           v_diasemana VARCHAR2(10);
                                                                           v_diahoje VARCHAR(10);
 BEGIN
  -- Valida Parametrizacoes na NAGT_ABASTECIMENTOCONFIG
  SELECT DIASCONFIG, DECODE(UPPER(DIASEMANA),  'SEGUNDA' , 'MONDAY',
                                               'TERCA'   , 'TUESDAY',
                                               'QUARTA'  , 'WEDNESDAY',
                                               'QUINTA'  , 'THURSDAY',
                                               'SEXTA'   , 'FRIDAY',
                                               'SABADO ' , 'SATURDAY',
                                               'DOMINGO' , 'SUNDAY')
    INTO v_diasconfig, v_diasemana
    FROM NAGT_ABASTECIMENTOCONFIG X
   WHERE X.SEQFORNECEDOR = p_Seqfornecedor;

  SELECT TRIM(TO_CHAR(MAX(DTAGERPEDIDO) + v_diasconfig,'DAY'))
    INTO v_diahoje
    FROM CONSINCO.MAC_GERCOMPRA A INNER JOIN CONSINCO.MAC_GERCOMPRAFORN C ON A.SEQGERCOMPRA = C.SEQGERCOMPRA
   WHERE 1=1
     AND C.SEQFORNECEDOR = p_Seqfornecedor
     AND A.SITUACAOLOTE = 'F';
  --
  -- Se o dia da semana for igual hoje, retorna hoje
   IF v_diasemana = v_diahoje

   THEN
     SELECT TRUNC(SYSDATE)
       INTO v_proxped
       FROM DUAL;
       
   DBMS_OUTPUT.PUT_LINE(v_diahoje||'-'||v_diasemana); -- Teste
  -- Caso contrário, próximo dia da semana que está parametrizado
   ELSE

  SELECT NEXT_DAY((SELECT MAX(DTAGERPEDIDO)
    FROM CONSINCO.MAC_GERCOMPRA A INNER JOIN CONSINCO.MAC_GERCOMPRAFORN C ON A.SEQGERCOMPRA = C.SEQGERCOMPRA
   WHERE 1=1
     AND C.SEQFORNECEDOR = p_Seqfornecedor
     AND A.SITUACAOLOTE = 'F')
   + v_diasconfig, v_diasemana)
   INTO v_proxped
   FROM DUAL;

   END IF;

 RETURN v_proxped;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN TRUNC(SYSDATE) -1;
END;
