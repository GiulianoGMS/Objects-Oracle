CREATE OR REPLACE PROCEDURE SP_GRAVAULTENTRADACODORIGTRIB(
                  PSSITUACAONF     MLF_NFITEM.SITUACAONF%TYPE,
                  PNSEQPESSOA      MLF_NFITEM.SEQPESSOA%TYPE,
                  PNSEQPRODUTO     MRL_PRODUTOEMPRESA.SEQPRODUTO%TYPE,
                  PNNROEMPRESA     MRL_PRODUTOEMPRESA.NROEMPRESA%TYPE
                  )
       IS
         VNCODORIGEM          INTEGER;
         VSUFFORN             GE_PESSOA.UF%TYPE;
BEGIN
     VNCODORIGEM := SUBSTR(PSSITUACAONF, 1, 1);
     -- Valida se CST inicia com 1 ( Estrangeira - Importação direta )
     -- ou 6 ( Estrangeira - Importação direta, sem similar nacional, constante em lista de Resolução CAMEX (vide Resolução Camex 79/2012); )
     IF VNCODORIGEM = 1 OR VNCODORIGEM = 6 THEN
        --Busca UF do fornecedor
        SELECT UF
        INTO   VSUFFORN
        FROM   GE_PESSOA A
        WHERE  A.SEQPESSOA = PNSEQPESSOA;
        --Se UF é do Brasil, altera codigo de origem CST ( 1 -> 2 e 6 -> 7)
        IF VSUFFORN <> 'EX' THEN
           VNCODORIGEM := VNCODORIGEM + 1;
        END IF;
       --Atualiza ultima entrada do campo orgiem de tributacao
       UPDATE MRL_PRODUTOEMPRESA A
       SET    A.CODORIGEMTRIBULTENT = VNCODORIGEM
       WHERE  A.SEQPRODUTO          = PNSEQPRODUTO
       AND    A.NROEMPRESA          = PNNROEMPRESA;
     ELSE
       /*--Atualiza NULL ultima entrada do campo orgiem de tributacao
       UPDATE MRL_PRODUTOEMPRESA A
       SET    A.CODORIGEMTRIBULTENT = NULL
       WHERE  A.SEQPRODUTO          = PNSEQPRODUTO
       AND    A.NROEMPRESA          = PNNROEMPRESA;*/

-- Giuliano 10/07/2025
-- Gravar Origem pois o PD solicita que controle na entrada

       UPDATE MRL_PRODUTOEMPRESA A
       SET    A.CODORIGEMTRIBULTENT = VNCODORIGEM
       WHERE  A.SEQPRODUTO          = PNSEQPRODUTO
       AND    A.NROEMPRESA          = PNNROEMPRESA;
     END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20200, 'SP_GRAVAULTENTRADACODORIGTRIB - ' || SQLERRM);
END SP_GRAVAULTENTRADACODORIGTRIB;
