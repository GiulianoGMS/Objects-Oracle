CREATE OR REPLACE VIEW CONSINCO.NAGV_DDA_EMPINVERTIDA AS 

SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/
DISTINCT FORNECEDOR,
         CNPJSAC     EMP_ERRADA,
         EMPC        EMP_CERTA,
         EMPRESA     DIV,
         DIVERGENCIA,
         DOCTO_DDA,
         DOC_C5,
         VALOR,
         VENCIMENTO,
         SEQDDA, CGC_CERTO, DIG_CERTO

  FROM (
        
        SELECT GE.NROEMPRESA EMPC,
                CNPJSAC EMP_CORRETA,
                FORNECEDOR,
                GE.NROCGC CGC_CERTO,
                GE.DIGCGC DIG_CERTO,
                SEQIMPORTACAO SEQDDA,
                GE.FANTASIA || CASE
                  WHEN CNPJSAC IS NULL THEN
                   NULL
                  ELSE
                   ' - Arquivo DDA na LJ ' || CNPJSAC
                END
                
                EMPRESA,
                X.CODESPECIE,
                
                CASE
                  WHEN (DOC_C5) = TIT_C5 THEN
                   (DOC_C5)
                  ELSE
                    TIT_C5
                END DOC_C5,
                
                CASE
                  WHEN DIVERGENCIA IS NULL
                       AND DOCTO IS NULL THEN
                   'Titulo não encontrado'
                
                  WHEN DIVERGENCIA IS NULL
                       AND DOCTO IS NOT NULL THEN
                   'Título encontrado - ' || CASE
                     WHEN LPAD(X.NROCNPJCPF, 12, 0) =
                          (SELECT MAX(LPAD(D.NROCGCCPF, 12, 0))
                             FROM GE_PESSOA D
                            WHERE D.NROCGCCPF = X.NROCNPJCPF
                                  AND D.STATUS = 'A')
                         
                          OR LPAD(X.NROCNPJCPF, 12, 0) || LPAD(X.DIGCNPJCPF, 2, 0) IN
                         
                          (SELECT LPAD(FR.NROCNPJCPF, 12, 0) ||
                                     LPAD(FR.DIGCNPJCPF, 2, 0)
                                FROM FI_DDAREGRADETALHE FR
                               WHERE FR.NROCNPJCPF = X.NROCNPJCPF)
                     
                      THEN
                      'Diverg Não Identificada'
                     ELSE
                      'CNPJ Não Cadastrado!'
                   END
                
                  ELSE
                   DIVERGENCIA || CASE
                     WHEN LPAD(X.NROCNPJCPF, 12, 0) || LPAD(X.DIGCNPJCPF, 2, 0) IN
                         
                          (SELECT LPAD(FR.NROCNPJCPF, 12, 0) ||
                                  LPAD(FR.DIGCNPJCPF, 2, 0)
                             FROM FI_DDAREGRADETALHE FR
                            WHERE FR.NROCNPJCPF = X.NROCNPJCPF)
                         
                          OR LPAD(X.NROCNPJCPF, 12, 0) =
                          (SELECT MAX(LPAD(D.NROCGCCPF, 12, 0))
                                FROM GE_PESSOA D
                               WHERE D.NROCGCCPF = X.NROCNPJCPF
                                     AND D.STATUS = 'A')
                     
                      THEN
                      NULL
                     ELSE
                      ' - CNPJ Não Cadastrado!'
                   END
                END DIVERGENCIA,
                
                DOCTO           DOCTO_DDA,
                EMISSAO,
                VENCIMENTO,
                VALOR,
                DESCONTO1,
                DATADESCONTO1,
                DESCONTO2,
                DATADESCONTO2,
                VALORABATIMENTO,
                CODIGODEBARRAS,
                SEQ,
                CNPJSAC,
                EMP, SEQIMPORTACAO
        
          FROM (
                 
                 SELECT SEQIMPORTACAO, GM.NROCGC, GM.DIGCGC, CASE
                           WHEN LPAD(DDA2.NROCNPJCPFSACADO, 12, 0) ||
                                LPAD(DDA2.DIGCNPJCPFSACADO, 2, 0) NOT IN
                                (SELECT DISTINCT LPAD(GE.NROCGCCPF, 12, 0) ||
                                                 LPAD(GE.DIGCGCCPF, 2, 0)
                                   FROM GE_PESSOA GE
                                  WHERE GE.SEQPESSOA IN (GM.NROEMPRESA)) THEN
                            (SELECT DISTINCT SEQPESSOA
                               FROM GE_PESSOA GE
                              WHERE LPAD(GE.NROCGCCPF, 12, 0) ||
                                    LPAD(GE.DIGCGCCPF, 2, 0) =
                                    LPAD(DDA2.NROCNPJCPFSACADO, 12, 0) ||
                                    LPAD(DDA2.DIGCNPJCPFSACADO, 2, 0)
                                    AND SEQPESSOA < 1000)
                           ELSE
                            NULL
                         END CNPJSAC,
                         
                         GE.NOMERAZAO || ' - ' || GE.SEQPESSOA FORNECEDOR,
                         DDA2.DESCFORNECEDOR,
                         GE.SEQPESSOA SEQ,
                         DDA2.NRODOCUMENTO DOCTO,
                         F.NRODOCUMENTO DOC_C5,
                         F.NROTITULO TIT_C5,
                         F.CODESPECIE,
                         DDA2.NRODOCUMENTO,
                         
                         TO_CHAR(DDA2.DTAEMISSAO, 'DD/MM/YYYY') EMISSAO,
                         TO_CHAR(DDA2.DTAVENCIMENTO, 'DD/MM/YYYY') VENCIMENTO,
                         DDA2.VALORDOCUMENTO VALOR,
                         DDA2.VALORDESCONTO1 DESCONTO1,
                         TO_CHAR(DDA2.DTADESCONTO1, 'DD/MM/YYYY') DATADESCONTO1,
                         DDA2.VALORDESCONTO2 DESCONTO2,
                         TO_CHAR(DDA2.DTADESCONTO2, 'DD/MM/YYYY') DATADESCONTO2,
                         DDA2.VALORABATIMENTO,
                         DDA2.CODBARRAS CODIGODEBARRAS,
                         
                         NULL            DIVERGENCIA,
                         DDA2.NROCNPJCPF,
                         DDA2.DIGCNPJCPF,
                         GM.NROEMPRESA   EMP
                 
                   FROM FI_TITULO F
                 
                  INNER JOIN FI_ESPECIE FI
                     ON F.CODESPECIE = FI.CODESPECIE
                        AND F.NROEMPRESAMAE = FI.NROEMPRESAMAE
                 
                  INNER JOIN GE_PESSOA GE
                     ON F.SEQPESSOA = GE.SEQPESSOA
                 
                  INNER JOIN FI_COMPLTITULO FC
                     ON F.SEQTITULO = FC.SEQTITULO
                 
                  INNER JOIN GE_EMPRESA GM
                     ON F.NROEMPRESA = GM.NROEMPRESA
                 
                   LEFT JOIN FIV_DDATITULOSBUSCA DDA2
                 
                     ON (LPAD(DDA2.NROCNPJCPFSACADO, 12, 0) ||
                        LPAD(DDA2.DIGCNPJCPFSACADO, 2, 0)) IN
                        (SELECT LPAD(GEE.NROCGC, 12, 0) || LPAD(GEE.DIGCGC, 2, 0)
                           FROM GE_EMPRESA GEE
                          WHERE GEE.NROEMPRESA IN
                                (SELECT A.MATRIZ
                                   FROM GE_EMPRESA A
                                  WHERE A.NROEMPRESA IN (GM.NROEMPRESA)
                                 UNION
                                 SELECT A.NROEMPRESA
                                   FROM GE_EMPRESA A
                                  WHERE A.NROEMPRESA IN (GM.NROEMPRESA)))
                        AND (F.VLRORIGINAL) = (DDA2.VALORDOCUMENTO)
                        AND
                        GE.NOMERAZAO LIKE
                        ('%' || REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)') || '%')
                        AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND
                        (F.DTAVENCIMENTO + 20)
                        AND
                        DDA2.NRODOCUMENTO LIKE ('%' || F.NRODOCUMENTO || '%')
                        AND NVL(DDA2.ACEITO, 'N') = 'N'
                       
                        OR
                        (F.VLRORIGINAL) = (DDA2.VALORDOCUMENTO)
                        AND
                        GE.NOMERAZAO LIKE
                        ('%' || REGEXP_SUBSTR(DDA2.DESCFORNECEDOR, '(\S*)(\s)') || '%')
                        AND DDA2.DTAVENCIMENTO BETWEEN (F.DTAVENCIMENTO - 20) AND
                        (F.DTAVENCIMENTO + 20)
                        AND
                        (LPAD(DDA2.NROCNPJCPFSACADO, 12, 0) ||
                        LPAD(DDA2.DIGCNPJCPFSACADO, 2, 0)) IN
                        (SELECT LPAD(GEE.NROCGC, 12, 0) || LPAD(GEE.DIGCGC, 2, 0)
                           FROM GE_EMPRESA GEE
                          WHERE GEE.NROEMPRESA IN
                                (SELECT A.MATRIZ
                                   FROM GE_EMPRESA A
                                  WHERE A.NROEMPRESA IN (GM.NROEMPRESA)
                                 UNION
                                 SELECT A.NROEMPRESA
                                   FROM GE_EMPRESA A
                                  WHERE A.NROEMPRESA IN (GM.NROEMPRESA)))
                        AND NVL(DDA2.ACEITO, 'N') = 'N'
                 
                  WHERE F.OBRIGDIREITO = 'O'
                        AND F.ABERTOQUITADO = 'A'
                        AND FI.TIPOESPECIE = 'T'
                        AND F.SITUACAO != 'S'
                        AND NVL(F.SUSPLIB, 'L') = 'L'
                        AND FC.CODBARRA IS NULL
                        AND F.DTAVENCIMENTO BETWEEN SYSDATE - 10 AND
                        SYSDATE + 60
                       
                        AND NVL(DDA2.ACEITO, 'N') = 'N'
                        AND DDA2.SEQTITULO IS NULL
                 
                 ) X,
                GE_EMPRESA GE
        
         WHERE GE.NROEMPRESA = X.EMP
              
             --  AND GE.NROEMPRESA IN (41, 57)
        
         ORDER BY 1, 5, 6) XX
 WHERE EMPRESA LIKE '%Arquivo DDA na LJ%'
 --AND DOC_C5 = 130663
