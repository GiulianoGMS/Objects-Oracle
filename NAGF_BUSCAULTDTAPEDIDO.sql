CREATE OR REPLACE FUNCTION CONSINCO.NAGF_BUSCAULTDTAPEDIDO (p_SeqLoteModelo NUMBER) RETURN DATE IS
  /* Criado por Giuliano | 07/07/2023 */                                   v_proxped    DATE;
                                                                           v_diasconfig NUMBER;
                                                                           v_diasemana  VARCHAR2(10);
                                                                           v_dia        VARCHAR2(10);
                                                                           v_dta        DATE;
                                                                           v_tp         VARCHAR2(1);
 BEGIN
  -- Valida Parametrizacoes na NAGT_CONTROLELOTECOMPRA
  -- Tradur o dia configurado pra utilizar no Next_Day
  
  SELECT DIASCONFIG, DECODE(UPPER(DIASEMANA),  'SEGUNDA' , 'MONDAY',
                                               'TERCA'   , 'TUESDAY',
                                               'QUARTA'  , 'WEDNESDAY',
                                               'QUINTA'  , 'THURSDAY',
                                               'SEXTA'   , 'FRIDAY',
                                               'SABADO'  , 'SATURDAY',
                                               'DOMINGO' , 'SUNDAY')
  --
    INTO v_diasconfig, v_diasemana
    FROM CONSINCO.NAGT_CONTROLELOTECOMPRA X
   WHERE X.SEQLOTEMODELO = p_SeqLoteModelo;
  --
  -- Primeiro resultado para validar se o dia semana é igual ao dia atual
  -- GREATEST pega a maior data entre Inclusão ou Fechamento
  SELECT TRIM(TO_CHAR(TRUNC(GREATEST(MAX(DTAHORINCLUSAO), NVL(MAX(DTAHORFECHAMENTO),MAX(DTAHORINCLUSAO))) + v_diasconfig),'DAY')), 
  --
  -- Segundo resultado para validar se o dia inteiro é igual ao dia atual
         TRUNC(GREATEST(MAX(DTAHORINCLUSAO), NVL(MAX(DTAHORFECHAMENTO),MAX(DTAHORINCLUSAO))) + v_diasconfig),
  -- Pega o tipo lote para diferenciar o tratamento para lote modelo inicial
         MIN(TIPOLOTE)
  --
  -- Insere nas variaveis
    INTO v_dia, v_dta, v_tp
  --
    FROM CONSINCO.MAC_GERCOMPRA A
   WHERE 1=1
     AND A.SEQGERMODELOCOMPRA = p_SeqLoteModelo AND USUINCLUSAO = 'JOBGERALOTE'
      OR A.SEQGERCOMPRA = p_SeqLoteModelo AND TIPOLOTE = 'M';
  --
  -- Tratamento para Lote Modelo, valida apenas dia da semana programado e retorna hoje
       IF 
             v_tp = 'M'
         AND v_diasemana = TRIM(TO_CHAR(SYSDATE, 'DAY'))
          OR
  --
  -- Para lotes normais | Se o dia retorno do calculo for igual hoje, retorna hoje  
             v_diasemana = v_dia 
         AND v_dta = TRUNC(SYSDATE)
         AND v_tp != 'M' -- Tira Modelo
          
        THEN
      SELECT TRUNC(SYSDATE)
        INTO v_proxped
        FROM DUAL;
  --
  -- Busca a próxima data valida para lotes modelos que não possuem o dia atual = diasemana config
   ELSIF
             v_tp = 'M'
         AND v_diasemana != TRIM(TO_CHAR(SYSDATE, 'DAY'))
         
        THEN
      SELECT NEXT_DAY(SYSDATE, v_diasemana)
        INTO v_proxped
        FROM DUAL;
  --
  -- Caso contrário, próximo dia da semana que está parametrizado
   ELSE

      SELECT NEXT_DAY((SELECT GREATEST(MAX(DTAHORINCLUSAO), NVL(MAX(DTAHORFECHAMENTO),MAX(DTAHORINCLUSAO))) -1
        FROM CONSINCO.MAC_GERCOMPRA A 
       WHERE 1=1
         AND A.SEQGERMODELOCOMPRA = p_SeqLoteModelo 
          OR A.SEQGERCOMPRA = p_SeqLoteModelo AND TIPOLOTE = 'M')
           + v_diasconfig, v_diasemana)
        INTO v_proxped
        FROM DUAL;

   END IF;

 RETURN v_proxped;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN NULL; --TRUNC(SYSDATE) + 100;
     WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE(p_SeqLoteModelo);
END;
