CREATE OR REPLACE VIEW MRLV_CARGATOLEDO_ITENSMGV2 AS
SELECT
       E.NROEMPRESA, P.SOFTPDV,
       B.SEQPRODUTO,
       F_SUBSTDESCPRODMINUSC(B.DESCCOMPLETA) DESCCOMPLETA,
       J.NROGONDOLA,
       J.ESTQLOJA + J.ESTQDEPOSITO + J.ESTQOUTRO + J.ESTQALMOXARIFADO ESTOQUE,
       J.ESTQLOJA, J.ESTQDEPOSITO,
       A.CODACESSO,
       A.TIPCODIGO,
       DECODE(C.PESAVEL, 'S', 'S', NVL(H.EMBPESAVEL, C.PESAVEL)) PESAVEL,
       C.PMTDECIMAL, C.PMTMULTIPLICACAO,
       D.QTDEMBALAGEM, D.NROSEGMENTO,
       D.STATUSVENDA,
       Y.SEQCOMPOSICAO,
       N.SEQCOMPEXTRA,
       ROUND(DECODE(D.PRECOVALIDPROMOC, 0, D.PRECOVALIDNORMAL, D.PRECOVALIDPROMOC) / D.QTDEMBALAGEM * A.QTDEMBALAGEM, 2) PRECO,
       DECODE(DECODE(D.PROCESSOALTERACAO, 'A', 'R', D.PROCESSOALTERACAO ), 'R', 'S', 'N') ALTPRECORECTONF,
       DECODE(D.PROCESSOALTERACAO, 'M', 'S', 'N') ALTPRECOMANUAL,
       DECODE(D.PROCESSOALTERACAO, 'E', 'S', 'N') ALTPRECOEQUIPAR,
       DECODE(D.PROCESSOALTERACAO, 'C', 'S', 'N') ALTPRECOSUGCENT,
       DECODE(D.PROCESSOALTERACAO, 'P', 'S', 'N') ALTPRECOPROMOCAO,
       DECODE(D.PROCESSOALTERACAO, 'O', 'S', 'N') ALTPRECOOUTMOT,
       D.DTABASEEXPORTACAO,
       B.DTAHORALTERACAO,
       'itensmgv.txt' ARQUIVO,
       'itensmgv.txt' ARQUIVOPARCIAL,
---------
    LPAD(DECODE(NVL(P.INDDESCBALANCA, 'P'), 'D', NVL(J.NRODEPARTAMENTO, 0), 'G', NVL(J.NROGONDOLA, 0), NVL(J.NRODEPARTAMENTO, J.NROGONDOLA)), 2, 0)
||  RPAD(DECODE(C.PMTDECIMAL || NVL(C.INDUSAPESODRENADO, 'N'), 'SS', 4,
                                                               'SN', 0, 1), 1, ' ')
||  LPAD(DECODE(NVL(P.INDCORTADIGBALANCA, 'N'), 'S', SUBSTR(A.CODACESSO, 0, LENGTH(A.CODACESSO) - 1), A.CODACESSO), 6, 0)
||  LPAD(ROUND(CASE WHEN NVL(EMPSEG.INDPRECOZEROBALANCA, 'N') = 'S' THEN
                         0
                    ELSE
                         DECODE(J.INDPRECONORMALBALANCA,'S', DECODE(D.PRECOVALIDPROMOC, 0, D.PRECOVALIDNORMAL, D.PRECOVALIDPROMOC),
                                DECODE(B.INDPRECOZEROBALANCA, 'S', 0,
                                       DECODE(D.PRECOVALIDPROMOC, 0, D.PRECOVALIDNORMAL, D.PRECOVALIDPROMOC)))
               END / D.QTDEMBALAGEM * A.QTDEMBALAGEM, 2 ) * 100, 6, 0)
||  LPAD(NVL(B.PZOVALIDADEDIASAIDA, 0), 3, 0)
||  RPAD(F_SUBSTDESCPRODMINUSC(B.DESCREDUZIDA), 25, ' ')
|| RPAD(NVL(DECODE(NVL(FC5MAXPARAMETRO('CARGA_PDV', 0, 'USA_DESCPROD_EXTRA_TOLEDO'),'N'),'S',(SELECT F_SUBSTDESCPRODMINUSC(NVL(DESEMP.DESCRICAO, DES.DESCRICAO))
                                                                                                FROM (SELECT NVL(MIN(N.DESCRICAO),'') DESCRICAO, M.SEQPRODUTO
                                                                                                        FROM MAP_PRODDESCESP M,
                                                                                                             MAP_DESCESPITEM N
                                                                                                       WHERE M.TIPO = N.TIPO
                                                                                                         AND M.CODIGO = N.CODIGO
                                                                                                         AND M.TIPO = 'DESCRICAO1'
                                                                                                         AND N.NROITEM = 1
                                                                                                       GROUP BY M.SEQPRODUTO) DES,
                                                                                                     (SELECT DISTINCT P.DESCRICAO, Q.SEQPRODUTO, Q.NROEMPRESA
                                                                                                        FROM MAP_DESCESP P,
                                                                                                             MAP_PRODDESCESPEMP Q
                                                                                                       WHERE P.TIPO = 'DESCRICAO1'
                                                                                                         AND P.TIPO = Q.TIPO
                                                                                                         AND P.CODIGO = Q.CODIGO) DESEMP,
                                                                                                     MRL_PRODUTOEMPRESA PROD
                                                                                               WHERE DES.SEQPRODUTO = PROD.SEQPRODUTO
                                                                                                 AND DESEMP.SEQPRODUTO(+) = PROD.SEQPRODUTO
                                                                                                 AND DESEMP.NROEMPRESA(+) = PROD.NROEMPRESA
                                                                                                 AND PROD.NROEMPRESA = E.NROEMPRESA
                                                                                                 AND PROD.SEQPRODUTO = B.SEQPRODUTO
                                                                                             ),' '),' '), 25, ' ')  -- DESCRICAO 2 --REQ52424
||  DECODE(NVL(FC5MAXPARAMETRO('CARGA_PDV', 0, 'USA_COMPOSICAO_PROD'), 'S'), 'N', LPAD(DECODE(NVL(J.COMPOSICAOEMPRESA, B.DESCCOMPOSICAO), NULL, 000000,
                                            NVL(LPAD(DECODE(NVL(P.INDCORTADIGBALANCA, 'N'), 'S', SUBSTR(A.CODACESSO, 0, LENGTH(A.CODACESSO) - 1), A.CODACESSO), 6, 0), 0))  , 6, 0), LPAD(NVL(Y.SEQCOMPOSICAO, 0), 6, 0))
||  LPAD(NVL(B.CODIMAGEM,'0'),4,'0')
||  LPAD(NVL(C.SEQINFNUTRIC, 0), 6, 0) -- PENATTI (ALTERADO DE 4 PARA 6 BYTES)
||  DECODE(B.IMPDATAVALIDADEBALANC,'N',0,1)
||  DECODE(B.IMPDATAEMBBALANC,'N',0,1)
||  LPAD(NVL(N.SEQCOMPEXTRA, 0), 4, 0)
||  LPAD(LPAD(A.SEQPRODUTO, 6, 0) || TO_CHAR(SYSDATE, 'J'), 12, 0)
||  LPAD(0, 11, 0)
||  '0'
||  '0000' --CS CÓDIGO DO SOM"0000"  = NÃO HAVERÁ ASSOCIAÇÃO (4 BYTES)
||  LPAD(NVL(O.CODTARA, 0), 4, 0) --CT CÓDIGO DA TARA"0000"  = NÃO HAVERÁ ASSOCIAÇÃO (4 BYTES)
--||  '0000' --FRAC CÓDIGO DO FRACINADOR"0000"  = NÃO HAVERÁ ASSOCIAÇÃO (4 BYTES)
||  DECODE(NVL(FC5MAXPARAMETRO('CARGA_PDV', 0, 'USA_ENTREPOSTO_TOLEDO'),'N'),'S',    ( SELECT LPAD(NVL(MIN(M.CODIGO),'0'),4,'0') FROM MAP_PRODDESCESP M
                                                                                       WHERE  M.SEQPRODUTO = B.SEQPRODUTO
                                                                                       AND    M.TIPO = 'DESCRICAO3'),'0000')
--||  '0000' --CE1 CÓDIGO DO CAMPO EXTRA 1"0000"  = NÃO HAVERÁ ASSOCIAÇÃO (4 BYTES)
||  DECODE(NVL(FC5MAXPARAMETRO('CARGA_PDV', 0, 'USA_DESCPROD_EXTRA_TOLEDO'),'N'),'S',( SELECT LPAD(NVL(MIN(M.CODIGO),'0'),4,'0') FROM MAP_PRODDESCESP M
                                                                                       WHERE  M.SEQPRODUTO = B.SEQPRODUTO
                                                                                       AND    M.TIPO = 'DESCRICAO2'),'0000')
||  '0000' --CE2 CÓDIGO DO CAMPO EXTRA 2"0000"  = NÃO HAVERÁ ASSOCIAÇÃO (4 BYTES)
||  LPAD(NVL(C.SEQINFCONSERVDOMEST, 0), 4, 0) --CONS CÓDIGO DA CONSERVAÇÃO  = NÃO HAVERÁ ASSOCIAÇÃO (4 BYTES)
||  LPAD(0, 12, 0) --EAN(12) EAN-13, QUANDO UTILIZADO TIPO DE PRODUTO EAN-13 (12 BYTES)
 LINHA
FROM   (SELECT *
        FROM   MAP_PRODCODIGO A
        WHERE  A.TIPCODIGO    =      'B') A, MAP_PRODUTO B,
       (SELECT A.SEQFAMILIA, A.PESAVEL, A.PMTDECIMAL, A.INDUSAPESODRENADO,
               A.PMTMULTIPLICACAO, B.SEQINFNUTRIC, A.SEQINFCONSERVDOMEST,
               B.SEQPRODUTO
        FROM   MAP_FAMILIA A, MAPV_INFNUTRIC B
        WHERE  B.SEQFAMILIA(+)     =           A.SEQFAMILIA) C,
       MRL_PRODEMPSEG D,
       MAX_EMPRESA E, MAP_FAMDIVISAO F,
       MAP_FAMEMBALAGEM H,
       MRL_PRODUTOEMPRESA J, MAD_FAMSEGMENTO K,
       MAP_FAMFORNEC L, GE_PESSOA M,
       MRLX_BASECARGACOMPEXTRA N, MRL_FAMEMBEMPRESA O,
       MRL_EMPSOFTPDV P,
       (SELECT DISTINCT A.SEQPRODUTO, A.NROEMPRESA, B.SEQCOMPOSICAO
        FROM   MRLV_COMPOSICAOPRODEMP A,
               (SELECT COMPOSICAO, MIN(SEQCOMPOSICAO) SEQCOMPOSICAO
                FROM   MRLX_BASECARGACOMPOSICAO
                GROUP  BY
                       COMPOSICAO) B
        WHERE  A.COMPOSICAO           =  B.COMPOSICAO) Y,
        MAX_EMPRESASEG EMPSEG, MAX_PARAMETRO PD
WHERE  B.SEQPRODUTO              =        A.SEQPRODUTO
AND    B.SEQPRODUTO              =        NVL(C.SEQPRODUTO, B.SEQPRODUTO)
AND    C.SEQFAMILIA              =        B.SEQFAMILIA
AND    D.SEQPRODUTO              =        A.SEQPRODUTO
AND    E.NROEMPRESA              =        D.NROEMPRESA
AND    F.NRODIVISAO              =        E.NRODIVISAO
AND    F.SEQFAMILIA              =        C.SEQFAMILIA
AND    H.SEQFAMILIA              =        C.SEQFAMILIA
AND    H.QTDEMBALAGEM            =        A.QTDEMBALAGEM
AND    J.SEQPRODUTO              =        B.SEQPRODUTO
AND    J.NROEMPRESA              =        E.NROEMPRESA
AND    D.NROSEGMENTO             =        E.NROSEGMENTOPRINC
AND    K.SEQFAMILIA              =        C.SEQFAMILIA
AND    K.NROSEGMENTO             =        D.NROSEGMENTO
AND    K.PADRAOEMBVENDA          =        D.QTDEMBALAGEM
AND    L.SEQFAMILIA              =        C.SEQFAMILIA
AND    M.SEQPESSOA               =        L.SEQFORNECEDOR
AND    Y.SEQPRODUTO(+)           =        D.SEQPRODUTO
AND    Y.NROEMPRESA(+)           =        D.NROEMPRESA
AND    N.SEQPRODUTO(+)           =        D.SEQPRODUTO
AND    N.NROEMPRESA(+)           =        D.NROEMPRESA
AND    O.SEQFAMILIA              =        B.SEQFAMILIA
AND    O.QTDEMBALAGEM            =        A.QTDEMBALAGEM
AND    O.NROEMPRESA              =        D.NROEMPRESA
AND    E.NROEMPRESA              =        P.NROEMPRESA
--AND    A.CODACESSO               <        10000
AND    LENGTH(A.CODACESSO)       <=        6
AND    L.PRINCIPAL               =        'S'
AND    A.TIPCODIGO               IN       ('B')
AND    NVL(A.INDUTILVENDA, 'S')  =        'S'
AND    H.STATUS                  =        'A'
AND    PD.GRUPO                  =       'CARGA_PDV'
AND    PD.NROEMPRESA             =       E.NROEMPRESA
AND    PD.PARAMETRO              =       'CONSID_ESTOQUE_DISP_PROD'
AND    (((FSTATUSVENDAPRODUTO(J.SEQPRODUTO, J.NROEMPRESA, E.NROSEGMENTOPRINC) = 'A'
          OR (FSTATUSVENDAPRODUTO(J.SEQPRODUTO, J.NROEMPRESA, E.NROSEGMENTOPRINC) = 'I'
              AND J.ESTQLOJA + J.ESTQDEPOSITO > 0)
         ) AND NVL(PD.VALOR, 'N') = 'N')
        OR (J.ESTQLOJA + J.ESTQDEPOSITO > 0 AND NVL(PD.VALOR, 'N') = 'S')
       )
AND    E.STATUS                  =       'A'
AND    DECODE(C.PESAVEL, 'S', 'S', NVL(H.EMBPESAVEL, C.PESAVEL))  = 'S'
AND    EMPSEG.NROEMPRESA         =      E.NROEMPRESA
AND    EMPSEG.NROSEGMENTO        =      E.NROSEGMENTOPRINC
-- ALT GIULIANO - REMOVE PROD COM PRECOS ZERADOS
AND  ROUND(DECODE(D.PRECOVALIDPROMOC, 0, D.PRECOVALIDNORMAL, D.PRECOVALIDPROMOC) / D.QTDEMBALAGEM * A.QTDEMBALAGEM, 2) > 0
AND  NVL(J.NRODEPARTAMENTO,0) != 0
;
