CREATE OR REPLACE FUNCTION NAGF_VALIDA_EAN13(ean IN VARCHAR2) RETURN VARCHAR2 IS
    -- Variáveis para armazenar a soma e o dígito verificador
    soma      NUMBER := 0;
    digito_verificador NUMBER;
BEGIN
    -- Validar o comprimento do EAN
    IF LENGTH(ean) != 13 THEN
        RETURN 'EAN Inválido - Deve ter 13 dígitos';
    END IF;
    
    -- Calcular a soma com base nas posições
    FOR i IN 1..12 LOOP
        IF MOD(i, 2) = 0 THEN
            -- Se posição par, multiplica o dígito por 3
            soma := soma + TO_NUMBER(SUBSTR(ean, i, 1)) * 3;
        ELSE
            -- Se posição ímpar, adiciona o dígito diretamente
            soma := soma + TO_NUMBER(SUBSTR(ean, i, 1));
        END IF;
    END LOOP;

    -- Calcular o dígito verificador
    digito_verificador := (10 - MOD(soma, 10)) MOD 10;

    -- Verificar se o dígito verificador coincide com o último dígito do EAN
    IF digito_verificador = TO_NUMBER(SUBSTR(ean, 13, 1)) THEN
        RETURN 'EAN Válido';
    ELSE
        RETURN 'EAN Inválido';
    END IF;
END;

