-- Criando a Tabela

CREATE TABLE CONSINCO.NAGT_CURVAABC_SEG (NROSEGMENTO NUMBER(2),
                                         SEQPRODUTO  NUMBER(20),
                                         CURVAABC    VARCHAR2(1));

-- Proc

CREATE OR REPLACE PROCEDURE NAGP_CURVAABC_SEG 

(
       vDataInicial DATE,
       vDataFinal   DATE
)
--- Giuliano em 04/07/2024
--- Copiei do Cipolla nagp_curvaabc_atualizacao
--- CRIAR LISTA ABC DOS PRODUTOS MAIS VENDIDOS POR RANK POR SEGMENTO

IS

  I INTEGER := 0;

BEGIN

    --- LIMPA A TABELA PARA RECEBER OS NOVOS DADOS
    DELETE  NAGT_CURVAABC_SEG@LINK_C5; COMMIT;

    FOR t IN ( SELECT NROSEGMENTO, SEQPRODUTO,

                       CASE WHEN RANK_VENDAS BETWEEN 1 AND 200 THEN 'A'
                            WHEN RANK_VENDAS  BETWEEN 201 AND 500 THEN 'B'
                            WHEN RANK_VENDAS  BETWEEN 500 AND 1000 THEN 'C'
                             END AS CURVAABC

                           /* CASE WHEN RANK_VENDAS BETWEEN 1 AND 200 THEN 1
                                    WHEN RANK_VENDAS  BETWEEN 201 AND 500 THEN 7
                                    WHEN RANK_VENDAS  BETWEEN 500 AND 1000 THEN 30
                                      END AS PERIODO*/

                       FROM (SELECT X.NROSEGMENTO,
                                    X.SEQPRODUTO,
                                    SUM(X.QTDOPERACAO) QTDE,
                                    RANK() OVER (ORDER BY SUM(X.QTDOPERACAO) DESC ) RANK_QTDE,
                                    SUM(X.VLROPERACAO) VLR_VENDAS,
                                    RANK() OVER (ORDER BY SUM(X.VLROPERACAO) DESC) RANK_VENDAS

                FROM FATO_VENDA X INNER JOIN DIM_PRODUTO Y   ON X.SEQPRODUTO = Y.SEQPRODUTO
                                   LEFT JOIN DIM_CATEGORIA Z ON Z.SEQFAMILIA = Y.SEQFAMILIA

                WHERE X.DTAOPERACAO BETWEEN vDataInicial AND vDataFinal
                  AND X.CODGERALOPER IN (37,48,123,610,615,613,810,916,910,911)

                  AND Z.CATEGORIAN1 NOT IN ('AÇOUGUE','PADARIA','HORTIFRUTI','FRIOS E LATICINIOS','ROTISSERIE','PEIXARIA')
                GROUP BY X.NROSEGMENTO, X.SEQPRODUTO ) X
                WHERE RANK_VENDAS <= 200 -- So precido da Curva A
 )
       LOOP

         BEGIN
           I := I + 1;       

            INSERT INTO NAGT_CURVAABC_SEG@LINK_C5
              (  NROSEGMENTO,   SEQPRODUTO,  CURVAABC)
            VALUES
              (t.NROSEGMENTO, t.SEQPRODUTO, t.CURVAABC);

            IF I = 100
                 THEN COMMIT;
                   I := 0;
            END IF;

          END;
        END LOOP;
COMMIT;

END;
