CREATE OR REPLACE VIEW CONSINCO.MRLV_BASEETIQUETAPROD AS
SELECT DISTINCT "SEQPRODUTO","NROEMPRESA","NROSEGMENTO","DESCCOMPLETA","DESCREDUZIDA","SEQFAMILIA","LOCENTRADA","LOCSAIDA","NRORUA","NROPREDIO","NROVAO","NROSALA","LOCALTURA","LOCLARGURA","LOCPROFUNDIDADE","EMBALAGEM","FAMILIA","PESAVEL","PMTDECIMAL","PMTMULTIPLICACAO","STATUSVENDA","QTDEMBALAGEM","PRECOBASENORMAL","PRECOGERNORMAL","PRECOGERPROMOC","PRECOVALIDNORMAL","PRECOVALIDPROMOC","INDEMIETIQUETA","QTDETIQUETA","NROGONDOLA","ESTQLOJA","ESTQDEPOSITO","ESTQTROCA","ESTQALMOXARIFADO","ESTQOUTRO","QTDRESERVADAVDA","QTDRESERVADARECEB","QTDRESERVADAFIXA","DTAGERACAOPRECO","DTAVALIDACAOPRECO","DTABASEEXPORTACAO","MULTEQPEMB","MULTEQPEMBALAGEM","NRODEPARTAMENTO","INDETIQUETARF","DTAGERACAOPRECOPROG","ETIQUETAPADRAO","QTDETIQUETARF" FROM (

-- Select normal da aplicacao

select  /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ a.seqproduto,
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

UNION ALL

select /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/  a.seqproduto,
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
       MAX(round(a.precobasenormal  / a.qtdembalagem * d.qtdembalagem, 2)) ,
       MAX(round(a.precogernormal   / a.qtdembalagem * d.qtdembalagem, 2)) ,
       MAX(round(a.precogerpromoc   / a.qtdembalagem * d.qtdembalagem, 2)) ,
       MAX(round(a.precovalidnormal / a.qtdembalagem * d.qtdembalagem, 2)) ,
       MAX(round(a.precovalidpromoc / a.qtdembalagem * d.qtdembalagem, 2)) ,
       'N' INDEMIETIQUETA,
       /*CASE
        WHEN TO_CHAR(SYSDATE, 'HH24:MI') <= '09:00' THEN 1
        ELSE 0 -- Se a hora atual não for maior que 09:00, retorna 0 - Só irá emitir pela manha*/
          1
        qtdetiqueta,
       e.nrogondola,
       e.estqloja,
       e.estqdeposito,
       e.estqtroca,
       e.estqalmoxarifado,
       e.estqoutro,
       e.qtdreservadavda,
       e.qtdreservadareceb,
       e.qtdreservadafixa,
       SYSDATE dtageracaopreco,
       SYSDATE dtavalidacaopreco,
       max(a.dtabaseexportacao) dtabaseexportacao,
       d.multeqpemb,
       d.multeqpembalagem,
       E.NRODEPARTAMENTO,
       a.indetiquetarf,
       max(a.dtageracaoprecoprog) dtageracaoprecoprog,
       e.etiquetapadrao,
       nvl(a.qtdetiqueta, e.qtdetiqueta) qtdetiquetarf

FROM MRL_PRODEMPSEG A INNER JOIN MAP_PRODUTO B ON A.SEQPRODUTO = B.SEQPRODUTO
                      INNER JOIN MAP_FAMILIA C ON C.SEQFAMILIA = B.SEQFAMILIA
                      INNER JOIN MAP_FAMEMBALAGEM D   ON D.SEQFAMILIA = B.SEQFAMILIA AND D.QTDEMBALAGEM = A.QTDEMBALAGEM
                      INNER JOIN MRL_PRODUTOEMPRESA E ON E.SEQPRODUTO = A.SEQPRODUTO AND E.NROEMPRESA = A.NROEMPRESA
                      INNER JOIN MAD_FAMSEGMENTO F    ON F.SEQFAMILIA = B.SEQFAMILIA AND F.NROSEGMENTO = A.NROSEGMENTO
                      INNER JOIN MRL_PRODLOCAL G      ON G.SEQPRODUTO = A.SEQPRODUTO AND G.SEQLOCAL = E.LOCSAIDA AND G.NROEMPRESA = A.NROEMPRESA
                      INNER JOIN MAX_EMPRESA EMP      ON EMP.NROEMPRESA = A.NROEMPRESA

-- Começa o tratamento para retorno dos produtos dentro dos encartes (Meu Nagumo)
-- Busca Similares

WHERE EXISTS     (SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ 1 FROM MRL_ENCARTE X INNER JOIN MRL_ENCARTEPRODUTO XI      ON XI.SEQENCARTE = X.SEQENCARTE
                                              INNER JOIN CONSINCO.MRL_ENCARTEEMP XE ON XE.SEQENCARTE = X.SEQENCARTE
                                              INNER JOIN CONSINCO.MRL_ENCARTEPRODUTOPRECO PP ON PP.SEQENCARTE = X.SEQENCARTE AND PP.SEQPRODUTO = XI.SEQPRODUTO
                                              INNER JOIN MAP_PRODSIMILAR S          ON S.SEQPRODUTO  = XI.SEQPRODUTO
                                              INNER JOIN MAP_PRODSIMILAR SF         ON SF.SEQSIMILARIDADE = S.SEQSIMILARIDADE

                           WHERE 1=1

                             AND X.SEQGRUPOPROMOC NOT IN (7,9)      -- Retira PROPZ / VALIDADE
                             AND NVL(PP.PRECOCARTAO,0) > 0          -- Apenas os que possuem preco meu nagumo
                             AND (NVL(XI.DTAVIGENCIAFIM,DTAFIM)        = TRUNC(SYSDATE) - 1 -- Retornando as saidas do dia anterior
                             -- Retirado Solic Raquel pois esta antecipando
                              OR /*NVL(*/XI.DTAVIGENCIAINI/*,X.DTAINICIO)*/   = TRUNC(SYSDATE))    -- (ou) Retorna os que iniciarem hoje
                             AND XE.NROEMPRESA = A.NROEMPRESA       -- Join da empresa
                             AND SF.SEQPRODUTO = A.SEQPRODUTO       -- Join do produto similar

-- Busca Familiares

    UNION         SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ 2 FROM MRL_ENCARTE X INNER JOIN MRL_ENCARTEPRODUTO XI      ON XI.SEQENCARTE = X.SEQENCARTE
                                              INNER JOIN CONSINCO.MRL_ENCARTEEMP XE ON XE.SEQENCARTE = X.SEQENCARTE
                                              INNER JOIN CONSINCO.MRL_ENCARTEPRODUTOPRECO PP ON PP.SEQENCARTE = X.SEQENCARTE AND PP.SEQPRODUTO = XI.SEQPRODUTO
                                              INNER JOIN MAP_PRODUTO P              ON P.SEQPRODUTO  = XI.SEQPRODUTO
                                              INNER JOIN MAP_PRODUTO PF             ON PF.SEQFAMILIA = P.SEQFAMILIA

                           WHERE 2=2

                             AND X.SEQGRUPOPROMOC NOT IN (7,9)      -- Retira PROPZ / VALIDADE
                             AND NVL(PP.PRECOCARTAO,0) > 0          -- Apenas os que possuem preco meu nagumo
                             AND (NVL(XI.DTAVIGENCIAFIM,DTAFIM)        = TRUNC(SYSDATE) - 1 -- Retornando as saidas do dia anterior
                             -- Retirado Solic Raquel pois esta antecipando
                              OR /*NVL(*/XI.DTAVIGENCIAINI/*,X.DTAINICIO)*/   = TRUNC(SYSDATE))    -- (ou) Retorna os que iniciarem hoje
                             AND XE.NROEMPRESA = A.NROEMPRESA       -- Join da empresa
                             AND PF.SEQPRODUTO = A.SEQPRODUTO)      -- Join do produto familiar

   -- Alterar o AND abaixo na view MRLV_BASEETIQUETAPROD_NAG para formação das etiquetas

   -- AND D.QTDEMGALAGEM = D.QTDEMBALAGEM

   AND d.qtdembalagem           =            decode( nvl(fc5maxparametro('EMISSAO_ETIQUETA', a.nroempresa, 'EMITE_ETIQ_PRECO_DIF'),'N'),
                                                     'N', f.padraoembvenda, 'M', fRetQtdEmbBaseEtiqProd(b.seqproduto, e.nroempresa, f.nrosegmento)/*fMaiorEmbVendaAtiva(b.seqproduto, e.nroempresa, f.nrosegmento) - COMENTADO NO RC 66994*/,
                                                          d.qtdembalagem)
AND A.NROSEGMENTO = EMP.NROSEGMENTOPRINC

-- Corta ja emitidos (De acordo com data de alteracao)

AND NOT EXISTS (SELECT 1 FROM CONSINCO.NAGT_CONTROLEIMPRESSAO XX WHERE XX.SEQPRODUTO = A.SEQPRODUTO
                                                                   AND XX.NROEMPRESA = A.NROEMPRESA
                                                                   AND TRUNC(XX.DTAIMPRESSAO) = TRUNC(SYSDATE))

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
       d.multeqpemb,
       d.multeqpembalagem,
       E.NRODEPARTAMENTO,
       a.indetiquetarf,
       e.etiquetapadrao,
       a.qtdetiqueta

)
;
