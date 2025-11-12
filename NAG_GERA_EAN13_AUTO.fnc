CREATE OR REPLACE FUNCTION NAG_GERA_EAN13_AUTO (psEmp NUMBER)
-- Giuliano 12/11/25
-- Gera Ean para contrle de datas

/*CREATE SEQUENCE NAG_S_EAN_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;*/

RETURN VARCHAR2
IS
    v_seq    NUMBER;
    v_base   VARCHAR2(12);
    v_sum_odd  NUMBER := 0;
    v_sum_even NUMBER := 0;
    v_dv     NUMBER;
    v_ean13  VARCHAR2(13);
BEGIN
    -- 1Pega o próximo número da sequence
    SELECT NAG_S_EAN_SEQ.NEXTVAL INTO v_seq FROM DUAL;

    -- 2Monta os 12 primeiros dígitos: prefixo fixo '80' + sequência com 10 dígitos
    v_base := '8' ||LPAD(psEmp,2,0)||LPAD(v_seq, 9, '0');

    --  Calcula o dígito verificador EAN-13
    --    Posições contam da esquerda (1 a 12)
    --    Soma dos dígitos em posições ímpares
    --    Soma dos dígitos em posições pares * 3
    FOR i IN 1 .. 12 LOOP
        IF MOD(i, 2) = 1 THEN
            v_sum_odd  := v_sum_odd  + TO_NUMBER(SUBSTR(v_base, i, 1));
        ELSE
            v_sum_even := v_sum_even + TO_NUMBER(SUBSTR(v_base, i, 1));
        END IF;
    END LOOP;

    v_dv := MOD(10 - MOD(v_sum_odd + (v_sum_even * 3), 10), 10);

    -- 4Monta o EAN completo
    v_ean13 := v_base || v_dv;

    RETURN v_ean13;
END;
