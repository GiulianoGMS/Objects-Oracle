CREATE OR REPLACE VIEW CONSINCO.NAGV_EMITENTEITWORKS AS
SELECT DISTINCT X."CNPJCPF", X."PRODUTOEMITENTE", X."PRODUTO",
                X."UNIDADECOMPRA", X."FATORCONVESTOQUE", X."USONFENTRADA",
                X."DTAHORINCLUSAO", X."DTAHORALTERACAO"
  FROM (

         SELECT LPAD(C.NROCGCCPF, 12, 0) || LPAD(C.DIGCGCCPF, 2, 0) CNPJCPF,
                 A.CODACESSO PRODUTOEMITENTE, A.SEQPRODUTO PRODUTO,
                 -- Giuliano em 06/08/24
                 CASE
                   WHEN EXISTS
                    (SELECT 1
                           FROM CONSINCO.NAGT_TKT436061 X
                          WHERE X.SEQPRODUTO = A.SEQPRODUTO
                            AND X.CGCFORNEC  = A.CGCFORNEC
                            AND X.CODACESSO  = A.CODACESSO
                            AND X.TIPCODIGO  = A.TIPCODIGO
                     UNION
                     SELECT 2
                          FROM CONSINCO.NAGT_TKT_441375 X2
                         WHERE X2.SEQPRODUTO = A.SEQPRODUTO
                           AND X2.CGCFORNEC  = A.CGCFORNEC
                           AND X2.CODACESSO  = A.CODACESSO
                           AND X2.TIPCODIGO  = A.TIPCODIGO
                     UNION
                     SELECT 3
                          FROM CONSINCO.NAGT_TKT431411BKP X3
                         WHERE X3.SEQPRODUTO = A.SEQPRODUTO
                           AND X3.CGCFORNEC  = A.CGCFORNEC
                           AND X3.CODACESSO  = A.CODACESSO
                           AND X3.TIPCODIGO  = A.TIPCODIGO
                           
                           ) AND A.QTDEMBALAGEM = 1 THEN
                    'UN'
                   ELSE

                    (SELECT Y.EMBALAGEM
                       FROM MAP_FAMDIVISAO X, MAP_FAMEMBALAGEM Y
                      WHERE X.SEQFAMILIA = Y.SEQFAMILIA
                        AND X.SEQFAMILIA = B.SEQFAMILIA
                        AND X.PADRAOEMBCOMPRA = Y.QTDEMBALAGEM)
                 END UNIDADECOMPRA, A.QTDEMBALAGEM FATORCONVESTOQUE,
                 -- (select x.padraoembcompra from map_famdivisao x where x.seqfamilia = b.seqfamilia and x.nrodivisao = 1) ,
                 (SELECT DECODE(K.FINALIDADEFAMILIA,
                                  'R',
                                  '1',
                                  'E',
                                  '2',
                                  'U',
                                  '3',
                                  'A',
                                  '4',
                                  'H',
                                  '5',
                                  'D',
                                  '7',
                                  'O',
                                  '7',
                                  'P',
                                  '2',
                                  '1')
                     FROM MAP_FAMDIVISAO K
                    WHERE K.SEQFAMILIA = B.SEQFAMILIA
                      AND K.NRODIVISAO = 1) USONFENTRADA, PRO.DTAHORINCLUSAO,
                 --pro.dtahoralteracao
                 -- Alterado por Giuliano em 04/05/24 pois nao estava pegando a data que a api insere o codigo de referencia
                 /*(SELECT MAX(Z.DTAHORAUDITORIA) FROM CONSINCO.MAP_AUDITORIA Z
                       WHERE Z.SEQIDENTIFICA = A.SEQPRODUTO
                         AND CAMPO IN( 'CODACESSO','QTDEMBALAGEM')) DTAHORALTERACAO*/
                 -- Alterado por Giuliano em 20/06/24 pois a tabela acima e lenta pra carambaaaa
                 GREATEST(NVL(PRO.DTAHORALTERACAO, PRO.DTAHORINCLUSAO),
                           NVL(A.DATAHORAALTERACAO, PRO.DTAHORINCLUSAO)) DTAHORALTERACAO

         --  (select pro.dtahorinclusao from map_produto pro where pro.seqfamilia = b.seqfamilia and pro.seqproduto = a.seqproduto) dtahorinclusao,
         --      (select pro.dtahoralteracao from map_produto pro where pro.seqfamilia = b.seqfamilia and pro.seqproduto = a.seqproduto) dtahoralteracao

           FROM MAP_PRODCODIGO A
          INNER JOIN MAP_FAMILIA B
             ON (A.SEQFAMILIA = B.SEQFAMILIA)
          INNER JOIN GE_PESSOA C
             ON (RPAD(A.CGCFORNEC, 6, 0) = RPAD(C.NROCGCCPF, 6) AND
                C.STATUS = 'A')
          INNER JOIN CONSINCO.MAP_PRODUTO PRO
             ON (PRO.SEQPRODUTO = A.SEQPRODUTO)

          WHERE A.TIPCODIGO IN ('F')
            AND C.FISICAJURIDICA = 'J' -- Ticket 164553
         -- and c.seqpessoa in (Select MAP_FAMFORNEC.SEQFORNECEDOR From MAP_FAMFORNEC Where SEQFAMILIA = b.seqfamilia)

         UNION ALL -- Alterac?o para atender fornecedores que possuem apenas CPF + 0 a esquerda

         SELECT LPAD(C.NROCGCCPF, 9, 0) || LPAD(C.DIGCGCCPF, 2, 0) CNPJCPF,
                 A.CODACESSO PRODUTOEMITENTE, A.SEQPRODUTO PRODUTO,
                 (SELECT Y.EMBALAGEM
                     FROM MAP_FAMDIVISAO X, MAP_FAMEMBALAGEM Y
                    WHERE X.SEQFAMILIA = Y.SEQFAMILIA
                      AND X.SEQFAMILIA = B.SEQFAMILIA
                      AND X.PADRAOEMBCOMPRA = Y.QTDEMBALAGEM) UNIDADECOMPRA,
                 A.QTDEMBALAGEM FATORCONVESTOQUE,
                 (SELECT DECODE(K.FINALIDADEFAMILIA,
                                  'R',
                                  '1',
                                  'E',
                                  '2',
                                  'U',
                                  '3',
                                  'A',
                                  '4',
                                  'H',
                                  '5',
                                  'D',
                                  '7',
                                  'O',
                                  '7',
                                  'P',
                                  '2',
                                  '1')
                     FROM MAP_FAMDIVISAO K
                    WHERE K.SEQFAMILIA = B.SEQFAMILIA
                      AND K.NRODIVISAO = 1) USONFENTRADA, PRO.DTAHORINCLUSAO,
                 --pro.dtahoralteracao
                 /*(SELECT MAX(Z.DTAHORAUDITORIA) FROM CONSINCO.MAP_AUDITORIA Z
                       WHERE Z.SEQIDENTIFICA = A.SEQPRODUTO
                         AND CAMPO IN( 'CODACESSO','QTDEMBALAGEM')) DTAHORALTERACAO*/
                 -- Alterado por Giuliano em 20/06/24 pois a tabela acima e lenta pra carambaaaa
                 GREATEST(NVL(PRO.DTAHORALTERACAO, PRO.DTAHORINCLUSAO),
                           NVL(A.DATAHORAALTERACAO, PRO.DTAHORINCLUSAO)) DTAHORALTERACAO

           FROM MAP_PRODCODIGO A
          INNER JOIN MAP_FAMILIA B
             ON (A.SEQFAMILIA = B.SEQFAMILIA)
          INNER JOIN GE_PESSOA C
             ON (LPAD(A.CGCFORNEC, 5, 0) = LPAD(LPAD(C.NROCGCCPF, 9, 0), 5, 0) AND
                C.STATUS = 'A')
            AND LENGTH(A.CGCFORNEC) = 4
          INNER JOIN CONSINCO.MAP_PRODUTO PRO
             ON (PRO.SEQPRODUTO = A.SEQPRODUTO)

          WHERE A.TIPCODIGO IN ('F')
            AND C.SEQPESSOA IN
                (SELECT F.SEQFORNECEDOR
                   FROM CONSINCO.MAP_FAMFORNEC F
                  WHERE F.SEQFAMILIA = A.SEQFAMILIA)
            AND C.FISICAJURIDICA = 'F'
           
         ) X -- WHERE UNIDADECOMPRA IS NOT NULL

 ORDER BY 2
;
