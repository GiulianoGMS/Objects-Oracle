CREATE OR REPLACE VIEW CONSINCO.MRLV_BASEETIQUETAPROD AS
SELECT/*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/
       DISTINCT "SEQPRODUTO","NROEMPRESA","NROSEGMENTO","DESCCOMPLETA","DESCREDUZIDA","SEQFAMILIA","LOCENTRADA","LOCSAIDA","NRORUA","NROPREDIO",
      "NROVAO","NROSALA","LOCALTURA","LOCLARGURA","LOCPROFUNDIDADE","EMBALAGEM","FAMILIA","PESAVEL","PMTDECIMAL","PMTMULTIPLICACAO","STATUSVENDA",
      "QTDEMBALAGEM","PRECOBASENORMAL","PRECOGERNORMAL","PRECOGERPROMOC","PRECOVALIDNORMAL","PRECOVALIDPROMOC","INDEMIETIQUETA","QTDETIQUETA","NROGONDOLA",
      "ESTQLOJA","ESTQDEPOSITO","ESTQTROCA","ESTQALMOXARIFADO","ESTQOUTRO","QTDRESERVADAVDA","QTDRESERVADARECEB","QTDRESERVADAFIXA","DTAGERACAOPRECO","DTAVALIDACAOPRECO",
      "DTABASEEXPORTACAO","MULTEQPEMB","MULTEQPEMBALAGEM","NRODEPARTAMENTO","INDETIQUETARF","DTAGERACAOPRECOPROG","ETIQUETAPADRAO","QTDETIQUETARF"

 FROM (

-- Select normal da aplicacao

select  a.seqproduto,
       a.nroempresa,
       a.nrosegmento,
       b.desccompleta,
       b.descreduzida,
       b.seqfamilia,
       e.locentrada,
       e.locsaida,
       g.nrorua,
       g.nropredio,
       g.nrovao,
       g.nrosala,
       g.localtura,
       g.loclargura,
       g.locprofundidade,
       d.embalagem || ' ' || d.qtdembalagem embalagem,
       c.familia,
       c.pesavel,
       c.pmtdecimal,
       c.pmtmultiplicacao,
       a.statusvenda,
       d.qtdembalagem,
       max(round(nvl(h.precovalidnormal, a.precobasenormal) / a.qtdembalagem * d.qtdembalagem, 2)) precobasenormal,
       max(round(nvl(h.precovalidnormal, a.precogernormal) / a.qtdembalagem * d.qtdembalagem, 2)) precogernormal,
       max(round(nvl(h.precovalidpromoc, a.precogerpromoc) / a.qtdembalagem * d.qtdembalagem, 2)) precogerpromoc,
       max(round(a.precovalidnormal / a.qtdembalagem * d.qtdembalagem, 2)) precovalidnormal,
       max(round(a.precovalidpromoc / a.qtdembalagem * d.qtdembalagem, 2)) precovalidpromoc,
       a.indemietiqueta,
       nvl(e.qtdetiqueta, 1) qtdetiqueta,
       e.nrogondola,
       e.estqloja,
       e.estqdeposito,
       e.estqtroca,
       e.estqalmoxarifado,
       e.estqoutro,
       e.qtdreservadavda,
       e.qtdreservadareceb,
       e.qtdreservadafixa,
       max(nvl(h.dtaprogalteracao, a.dtageracaopreco)) dtageracaopreco,
       max(nvl(h.dtaprogalteracao, a.dtavalidacaopreco)) dtavalidacaopreco,
       max(a.dtabaseexportacao) dtabaseexportacao,
       /*RC 51219 - RP 51582 - PAGOTTO*/
       d.multeqpemb,
       d.multeqpembalagem,
       E.NRODEPARTAMENTO,
       a.indetiquetarf,
       max(a.dtageracaoprecoprog) dtageracaoprecoprog,
       e.etiquetapadrao,
       nvl(a.qtdetiqueta, e.qtdetiqueta) qtdetiquetarf
from   mrl_prodempseg a,
       map_produto b,
       map_familia c,
       map_famembalagem d,
       mrl_produtoempresa e,
       mad_famsegmento f,
       mrl_prodlocal g,
       mrlx_prodempsegdata h

where  b.seqproduto             =            a.seqproduto
and    c.seqfamilia             =            b.seqfamilia
and    d.seqfamilia             =            b.seqfamilia
and    e.seqproduto             =            a.seqproduto
and    e.nroempresa             =            a.nroempresa
and    f.seqfamilia             =            b.seqfamilia
and    f.nrosegmento            =            a.nrosegmento
/* RC 53352 - Pagotto - refeito este join em 59799*/
/* RC 65207 - Adicionado valor 'M' para o parâmetro ('M' ou 'S' retornar d.qtdembalagem) */
/* Req. 66287 -  Ao definir o valor [M] para o parâmetro [EMISSAO_ETIQUETA], deve ser utilizada a maior embalagem de venda ativa.*/

   -- Alterar o AND abaixo na view MRLV_BASEETIQUETAPROD_NAG para formação das etiquetas

   -- AND D.QTDEMGALAGEM = D.QTDEMBALAGEM
and    d.qtdembalagem           =            decode( nvl(fc5maxparametro('EMISSAO_ETIQUETA', a.nroempresa, 'EMITE_ETIQ_PRECO_DIF'),'N'),
                                                     'N', f.padraoembvenda, 'M', fRetQtdEmbBaseEtiqProd(b.seqproduto, e.nroempresa, f.nrosegmento)/*fMaiorEmbVendaAtiva(b.seqproduto, e.nroempresa, f.nrosegmento) - COMENTADO NO RC 66994*/,
                                                          d.qtdembalagem)

and    d.qtdembalagem           =            a.qtdembalagem
and    g.seqproduto(+)          =            e.seqproduto
and    g.seqlocal(+)            =            e.locsaida
and    g.nroempresa(+)          =            e.nroempresa
and    a.seqproduto             =            h.seqproduto(+)
and    a.qtdembalagem           =            h.qtdembalagem(+)
and    a.nroempresa             =            h.nroempresa(+)
and    a.nrosegmento            =            h.nrosegmento(+)



group  by
       a.seqproduto,
       a.nroempresa,
       a.nrosegmento,
       b.desccompleta,
       b.descreduzida,
       b.seqfamilia,
       e.locentrada,
       e.locsaida,
       g.nrorua,
       g.nropredio,
       g.nrovao,
       g.nrosala,
       g.localtura,
       g.loclargura,
       g.locprofundidade,
       d.embalagem || ' ' || d.qtdembalagem,
       c.familia,
       c.pesavel,
       c.pmtdecimal,
       c.pmtmultiplicacao,
       a.statusvenda,
       d.qtdembalagem,
/*       round(a.precobasenormal / a.qtdembalagem * d.qtdembalagem, 2) ,
       round(a.precogernormal / a.qtdembalagem * d.qtdembalagem, 2) ,
       round(a.precogerpromoc / a.qtdembalagem * d.qtdembalagem, 2) ,
       round(a.precovalidnormal / a.qtdembalagem * d.qtdembalagem, 2) ,
       round(a.precovalidpromoc / a.qtdembalagem * d.qtdembalagem, 2) ,*/
       a.indemietiqueta,
       e.qtdetiqueta,
       e.nrogondola,
       e.estqloja,
       e.estqdeposito,
       e.estqtroca,
       e.estqalmoxarifado,
       e.estqoutro,
       e.qtdreservadavda,
       e.qtdreservadareceb,
       e.qtdreservadafixa,
       /*RC 51219 - RP 51582 - PAGOTTO*/
       d.multeqpemb,
       d.multeqpembalagem,
       E.NRODEPARTAMENTO,
       a.indetiquetarf,
       e.etiquetapadrao,
       a.qtdetiqueta

UNION -- Comeca Select das Exclusivas MN

SELECT DISTINCT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/  A.SEQPRODUTO,
       A.NROEMPRESA,
       A.NROSEGMENTO,
       B.DESCCOMPLETA,
       B.DESCREDUZIDA,
       B.SEQFAMILIA,
       E.LOCENTRADA,
       E.LOCSAIDA,
       G.NRORUA,
       G.NROPREDIO,
       G.NROVAO,
       G.NROSALA,
       G.LOCALTURA,
       G.LOCLARGURA,
       G.LOCPROFUNDIDADE,
       D.EMBALAGEM || ' ' || D.QTDEMBALAGEM EMBALAGEM,
       C.FAMILIA,
       C.PESAVEL,
       C.PMTDECIMAL,
       C.PMTMULTIPLICACAO,
       A.STATUSVENDA,
       D.QTDEMBALAGEM,
       MAX(ROUND(A.PRECOBASENORMAL  / A.QTDEMBALAGEM * D.QTDEMBALAGEM, 2)) ,
       MAX(ROUND(A.PRECOGERNORMAL   / A.QTDEMBALAGEM * D.QTDEMBALAGEM, 2)) ,
       MAX(ROUND(A.PRECOGERPROMOC   / A.QTDEMBALAGEM * D.QTDEMBALAGEM, 2)) ,
       MAX(ROUND(A.PRECOVALIDNORMAL / A.QTDEMBALAGEM * D.QTDEMBALAGEM, 2)) ,
       MAX(ROUND(A.PRECOVALIDPROMOC / A.QTDEMBALAGEM * D.QTDEMBALAGEM, 2)) ,
       'N' INDEMIETIQUETA,
       /*CASE
        WHEN TO_CHAR(SYSDATE, 'HH24:MI') <= '09:00' THEN 1
        ELSE 0 -- SE A HORA ATUAL NÃO FOR MAIOR QUE 09:00, RETORNA 0 - SÓ IRÁ EMITIR PELA MANHA*/
          1
        QTDETIQUETA,
       E.NROGONDOLA,
       E.ESTQLOJA,
       E.ESTQDEPOSITO,
       E.ESTQTROCA,
       E.ESTQALMOXARIFADO,
       E.ESTQOUTRO,
       E.QTDRESERVADAVDA,
       E.QTDRESERVADARECEB,
       E.QTDRESERVADAFIXA,
       SYSDATE DTAGERACAOPRECO,
       SYSDATE DTAVALIDACAOPRECO,
       MAX(A.DTABASEEXPORTACAO) DTABASEEXPORTACAO,
       D.MULTEQPEMB,
       D.MULTEQPEMBALAGEM,
       E.NRODEPARTAMENTO,
       A.INDETIQUETARF,
       MAX(A.DTAGERACAOPRECOPROG) DTAGERACAOPRECOPROG,
       E.ETIQUETAPADRAO,
       NVL(A.QTDETIQUETA, E.QTDETIQUETA) QTDETIQUETARF

FROM MRL_PRODEMPSEG A INNER JOIN MAP_PRODUTO B ON A.SEQPRODUTO = B.SEQPRODUTO
                      INNER JOIN MAP_FAMILIA C ON C.SEQFAMILIA = B.SEQFAMILIA
                      INNER JOIN MAP_FAMEMBALAGEM D   ON D.SEQFAMILIA = B.SEQFAMILIA AND D.QTDEMBALAGEM = A.QTDEMBALAGEM
                      INNER JOIN MRL_PRODUTOEMPRESA E ON E.SEQPRODUTO = A.SEQPRODUTO AND E.NROEMPRESA = A.NROEMPRESA
                      INNER JOIN MRL_PRODLOCAL G      ON G.SEQPRODUTO = A.SEQPRODUTO AND G.SEQLOCAL = E.LOCSAIDA AND G.NROEMPRESA = A.NROEMPRESA
                      INNER JOIN MAX_EMPRESA EMP      ON EMP.NROEMPRESA = A.NROEMPRESA
                      INNER JOIN MAD_FAMSEGMENTO F    ON F.SEQFAMILIA = B.SEQFAMILIA AND F.NROSEGMENTO = A.NROSEGMENTO
                       -- Join nas Exclusivas
                      INNER JOIN (SELECT SEQPRODUTO, CODLOJA NROEMPRESA
                                    FROM CONSINCO.NAGT_REMARCAPROMOCOES RP INNER JOIN MAP_PRODCODIGO CC ON RP.CODIGOPRODUTO = LPAD(CC.CODACESSO,14,0)
                                                                             AND CC.TIPCODIGO = 'E'
                                                                             AND CC.QTDEMBALAGEM = 1
                                   WHERE 1=1
                                     AND RP.TIPODESCONTO = 4
                                     AND RP.PROMOCAOLIVRE = 0
                                      AND (TRUNC (SYSDATE) = TRUNC (RP.DTHRINICIO)  -- Comecando hoje
                                       OR  TRUNC (SYSDATE) - 1 = TRUNC(RP.DTHRFIM)) -- Ou terminando ontem)
                                   )  RPM ON RPM.NROEMPRESA = A.NROEMPRESA AND RPM.SEQPRODUTO = A.SEQPRODUTO

WHERE D.QTDEMBALAGEM = DECODE(NVL(FC5MAXPARAMETRO('EMISSAO_ETIQUETA',
                                                       A.NROEMPRESA,
                                                       'EMITE_ETIQ_PRECO_DIF'),
                                   'N'), 'N', F.PADRAOEMBVENDA, 'M',
                                   FRETQTDEMBBASEETIQPROD(B.SEQPRODUTO,
                                                          E.NROEMPRESA,
                                                          F.NROSEGMENTO) /*fMaiorEmbVendaAtiva(b.seqproduto, e.nroempresa, f.nrosegmento) - COMENTADO NO RC 66994*/,
                                   D.QTDEMBALAGEM)
       AND A.NROSEGMENTO = EMP.NROSEGMENTOPRINC

      -- Corta ja emitidos (De acordo com data de alteracao)

       AND NOT EXISTS

       (SELECT 1
          FROM CONSINCO.NAGT_CONTROLEIMPRESSAO XX
         WHERE XX.SEQPRODUTO = A.SEQPRODUTO
               AND XX.NROEMPRESA = A.NROEMPRESA
               AND TRUNC(XX.DTAIMPRESSAO) = TRUNC(SYSDATE))

 GROUP BY A.SEQPRODUTO,
          A.NROEMPRESA,
          A.NROSEGMENTO,
          B.DESCCOMPLETA,
          B.DESCREDUZIDA,
          B.SEQFAMILIA,
          E.LOCENTRADA,
          E.LOCSAIDA,
          G.NRORUA,
          G.NROPREDIO,
          G.NROVAO,
          G.NROSALA,
          G.LOCALTURA,
          G.LOCLARGURA,
          G.LOCPROFUNDIDADE,
          D.EMBALAGEM || ' ' || D.QTDEMBALAGEM,
          C.FAMILIA,
          C.PESAVEL,
          C.PMTDECIMAL,
          C.PMTMULTIPLICACAO,
          A.STATUSVENDA,
          D.QTDEMBALAGEM,
          A.INDEMIETIQUETA,
          E.QTDETIQUETA,
          E.NROGONDOLA,
          E.ESTQLOJA,
          E.ESTQDEPOSITO,
          E.ESTQTROCA,
          E.ESTQALMOXARIFADO,
          E.ESTQOUTRO,
          E.QTDRESERVADAVDA,
          E.QTDRESERVADARECEB,
          E.QTDRESERVADAFIXA,
          D.MULTEQPEMB,
          D.MULTEQPEMBALAGEM,
          E.NRODEPARTAMENTO,
          A.INDETIQUETARF,
          E.ETIQUETAPADRAO,
          A.QTDETIQUETA

UNION -- Comeca Select das Ativaveis

SELECT DISTINCT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/  A.SEQPRODUTO,
       A.NROEMPRESA,
       A.NROSEGMENTO,
       B.DESCCOMPLETA,
       B.DESCREDUZIDA,
       B.SEQFAMILIA,
       E.LOCENTRADA,
       E.LOCSAIDA,
       G.NRORUA,
       G.NROPREDIO,
       G.NROVAO,
       G.NROSALA,
       G.LOCALTURA,
       G.LOCLARGURA,
       G.LOCPROFUNDIDADE,
       D.EMBALAGEM || ' ' || D.QTDEMBALAGEM EMBALAGEM,
       C.FAMILIA,
       C.PESAVEL,
       C.PMTDECIMAL,
       C.PMTMULTIPLICACAO,
       A.STATUSVENDA,
       D.QTDEMBALAGEM,
       MAX(ROUND(A.PRECOBASENORMAL  / A.QTDEMBALAGEM * D.QTDEMBALAGEM, 2)) ,
       MAX(ROUND(A.PRECOGERNORMAL   / A.QTDEMBALAGEM * D.QTDEMBALAGEM, 2)) ,
       MAX(ROUND(A.PRECOGERPROMOC   / A.QTDEMBALAGEM * D.QTDEMBALAGEM, 2)) ,
       MAX(ROUND(A.PRECOVALIDNORMAL / A.QTDEMBALAGEM * D.QTDEMBALAGEM, 2)) ,
       MAX(ROUND(A.PRECOVALIDPROMOC / A.QTDEMBALAGEM * D.QTDEMBALAGEM, 2)) ,
       'N' INDEMIETIQUETA,
       /*CASE
        WHEN TO_CHAR(SYSDATE, 'HH24:MI') <= '09:00' THEN 1
        ELSE 0 -- SE A HORA ATUAL NÃO FOR MAIOR QUE 09:00, RETORNA 0 - SÓ IRÁ EMITIR PELA MANHA*/
          1
        QTDETIQUETA,
       E.NROGONDOLA,
       E.ESTQLOJA,
       E.ESTQDEPOSITO,
       E.ESTQTROCA,
       E.ESTQALMOXARIFADO,
       E.ESTQOUTRO,
       E.QTDRESERVADAVDA,
       E.QTDRESERVADARECEB,
       E.QTDRESERVADAFIXA,
       SYSDATE DTAGERACAOPRECO,
       SYSDATE DTAVALIDACAOPRECO,
       MAX(A.DTABASEEXPORTACAO) DTABASEEXPORTACAO,
       D.MULTEQPEMB,
       D.MULTEQPEMBALAGEM,
       E.NRODEPARTAMENTO,
       A.INDETIQUETARF,
       MAX(A.DTAGERACAOPRECOPROG) DTAGERACAOPRECOPROG,
       E.ETIQUETAPADRAO,
       NVL(A.QTDETIQUETA, E.QTDETIQUETA) QTDETIQUETARF

FROM MRL_PRODEMPSEG A INNER JOIN MAP_PRODUTO B ON A.SEQPRODUTO = B.SEQPRODUTO
                      INNER JOIN MAP_FAMILIA C ON C.SEQFAMILIA = B.SEQFAMILIA
                      INNER JOIN MAP_FAMEMBALAGEM D   ON D.SEQFAMILIA = B.SEQFAMILIA AND D.QTDEMBALAGEM = A.QTDEMBALAGEM
                      INNER JOIN MRL_PRODUTOEMPRESA E ON E.SEQPRODUTO = A.SEQPRODUTO AND E.NROEMPRESA = A.NROEMPRESA
                      INNER JOIN MRL_PRODLOCAL G      ON G.SEQPRODUTO = A.SEQPRODUTO AND G.SEQLOCAL = E.LOCSAIDA AND G.NROEMPRESA = A.NROEMPRESA
                      INNER JOIN MAX_EMPRESA EMP      ON EMP.NROEMPRESA = A.NROEMPRESA
                      INNER JOIN MAD_FAMSEGMENTO F    ON F.SEQFAMILIA = B.SEQFAMILIA AND F.NROSEGMENTO = A.NROSEGMENTO
                      -- Join nas Ativaveis
                      INNER JOIN (SELECT SEQPRODUTO
                                    FROM CONSINCO.MRL_ENCARTE AA INNER JOIN CONSINCO.MRL_ENCARTEPRODUTO BB ON AA.SEQENCARTE = BB.SEQENCARTE
                                   WHERE BB.PRECOPROMOCIONAL > 0
                                     AND BB.QTDEMBALAGEM = 1
                                     AND DESCRICAO LIKE 'MEU NAGUMO%'
                                     AND (TRUNC(SYSDATE) = DTAINICIO  -- Comecando hoje
                                      OR  TRUNC(SYSDATE) -1 = DTAFIM) -- Ou terminando ontem) -- Ou terminando ontem)
                                  ) AT ON AT.SEQPRODUTO = A.SEQPRODUTO

WHERE D.QTDEMBALAGEM = DECODE(NVL(FC5MAXPARAMETRO('EMISSAO_ETIQUETA',
                                                       A.NROEMPRESA,
                                                       'EMITE_ETIQ_PRECO_DIF'),
                                   'N'), 'N', F.PADRAOEMBVENDA, 'M',
                                   FRETQTDEMBBASEETIQPROD(B.SEQPRODUTO,
                                                          E.NROEMPRESA,
                                                          F.NROSEGMENTO) /*fMaiorEmbVendaAtiva(b.seqproduto, e.nroempresa, f.nrosegmento) - COMENTADO NO RC 66994*/,
                                   D.QTDEMBALAGEM)
       AND A.NROSEGMENTO = EMP.NROSEGMENTOPRINC

      -- Corta ja emitidos (De acordo com data de alteracao)

       AND NOT EXISTS

       (SELECT 1
          FROM CONSINCO.NAGT_CONTROLEIMPRESSAO XX
         WHERE XX.SEQPRODUTO = A.SEQPRODUTO
               AND XX.NROEMPRESA = A.NROEMPRESA
               AND TRUNC(XX.DTAIMPRESSAO) = TRUNC(SYSDATE))

 GROUP BY A.SEQPRODUTO,
          A.NROEMPRESA,
          A.NROSEGMENTO,
          B.DESCCOMPLETA,
          B.DESCREDUZIDA,
          B.SEQFAMILIA,
          E.LOCENTRADA,
          E.LOCSAIDA,
          G.NRORUA,
          G.NROPREDIO,
          G.NROVAO,
          G.NROSALA,
          G.LOCALTURA,
          G.LOCLARGURA,
          G.LOCPROFUNDIDADE,
          D.EMBALAGEM || ' ' || D.QTDEMBALAGEM,
          C.FAMILIA,
          C.PESAVEL,
          C.PMTDECIMAL,
          C.PMTMULTIPLICACAO,
          A.STATUSVENDA,
          D.QTDEMBALAGEM,
          A.INDEMIETIQUETA,
          E.QTDETIQUETA,
          E.NROGONDOLA,
          E.ESTQLOJA,
          E.ESTQDEPOSITO,
          E.ESTQTROCA,
          E.ESTQALMOXARIFADO,
          E.ESTQOUTRO,
          E.QTDRESERVADAVDA,
          E.QTDRESERVADARECEB,
          E.QTDRESERVADAFIXA,
          D.MULTEQPEMB,
          D.MULTEQPEMBALAGEM,
          E.NRODEPARTAMENTO,
          A.INDETIQUETARF,
          E.ETIQUETAPADRAO,
          A.QTDETIQUETA

)
;
