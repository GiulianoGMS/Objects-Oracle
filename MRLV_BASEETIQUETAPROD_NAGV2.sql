create or replace view consinco.mrlv_baseetiquetaprod_nagv2 as
select/*+optimizer_features_enable('11.2.0.4') */ a.seqproduto,
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
       nvl(a.qtdetiqueta, e.qtdetiqueta) qtdetiquetarf,
       case when marca like '%NAGUMO%' then 2 else 1 end MP
from   mrl_prodempseg a,
       map_produto b,
       map_familia c,
       map_famembalagem d,
       mrl_produtoempresa e,
       mad_famsegmento f,
       mrl_prodlocal g,
       mrlx_prodempsegdata h,
       map_marca i
where  b.seqproduto             =            a.seqproduto
and    c.seqfamilia             =            b.seqfamilia
and    d.seqfamilia             =            b.seqfamilia
and    e.seqproduto             =            a.seqproduto
and    e.nroempresa             =            a.nroempresa
and    f.seqfamilia             =            b.seqfamilia
and    f.nrosegmento            =            a.nrosegmento
/* RC 53352 - Pagotto - refeito este join em 59799*/
/* RC 65207 - Adicionado valor 'M' para o parametro ('M' ou 'S' retornar d.qtdembalagem) */
/* Req. 66287 -  Ao definir o valor [M] para o parametro [EMISSAO_ETIQUETA], deve ser utilizada a maior embalagem de venda ativa.*/
and    d.qtdembalagem           =            d.qtdembalagem
and    d.qtdembalagem           =            a.qtdembalagem
and    g.seqproduto(+)          =            e.seqproduto
and    g.seqlocal(+)            =            e.locsaida
and    g.nroempresa(+)          =            e.nroempresa
and    a.seqproduto             =            h.seqproduto(+)
and    a.qtdembalagem           =            h.qtdembalagem(+)
and    a.nroempresa             =            h.nroempresa(+)
and    a.nrosegmento            =            h.nrosegmento(+)
and    c.seqmarca = i.seqmarca
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
       a.qtdetiqueta,marca;
