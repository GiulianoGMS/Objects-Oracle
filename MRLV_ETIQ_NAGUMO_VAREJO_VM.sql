CREATE OR REPLACE VIEW CONSINCO.MRLV_ETIQ_NAGUMO_VAREJO_VM AS
select  /*+optimizer_features_enable('11.2.0.4') */  d.marca, a."NROEMPRESA",a."SEQPRODUTO",a."DTABASEPRECO",a."CODACESSO",a."QTDETIQUETA",a."DTAPROMINICIO",
       a."DTAPROMFIM",a."CODACESSOPADRAO",a."EMBALAGEMPADRAO",a."PADRAOEMBVENDA",a."PRECOEMBPADRAO",a.precovalidnormal,a.precovalidpromoc,a."MULTEQPEMBPADRAO",
       a."QTDUNIDEMBPADRAO",a."TIPOETIQUETA",a."TIPOPRECO",a."DESCCOMPLETA",a."DESCREDUZIDA",a."QTDEMBALAGEM1",a."MULTEQPEMB1",
       a."QTDUNIDEMB1",a."QTDEMBALAGEM2",a."MULTEQPEMB2",a."QTDUNIDEMB2",a."QTDEMBALAGEM3",a."MULTEQPEMB3",a."QTDUNIDEMB3",
       a."QTDEMBALAGEM4",a."MULTEQPEMB4",a."QTDUNIDEMB4",a."QTDEMBALAGEM5",a."MULTEQPEMB5",a."QTDUNIDEMB5",a."CODACESSO1",a."CODACESSO2",
       a."CODACESSO3",a."CODACESSO4",a."CODACESSO5",a."PRECO1",a."PRECO2",a."PRECO3",a."PRECO4",a."PRECO5",a."PRECOMIN",a."PRECOMAX",
       a."EMBALAGEM1",a."EMBALAGEM2",a."EMBALAGEM3",a."EMBALAGEM4",a."EMBALAGEM5",a."TIPOCODIGO", a.qtdembcodacesso,

---Etiqueta V2

       '^XA' || '^PRA^FS' || '^LH00,00^FS'|| '^BY2^FS' || '^PQ' || nvl(a.qtdetiqueta, 1) || '^FS'
       || case


----------- Quando estiver na oferta e quando oferta foi MENOR que pre¿¿o normal
             when (nvl(h.precovalidpromoc,0) > 0) and (nvl(h.precovalidpromoc,0))  < trunc((a.precovalidnormal * a.padraoembvenda),2)
               then
       -- Alterado por Giuliano | Tratamento Preco Meu Nagumo
       CASE WHEN CONSINCO.NAGF_PRECOMN(A.CODACESSOPADRAO,A.NROEMPRESA) > 0 

       THEN                                   CHR(13) || CHR(10) ||
        '^FO90,115^GB150,4,4^FS'           || CHR(13) || CHR(10) || -- Risco
        '^FO050,190^BY2.4^BEN,25,Y,N^FD'||A.CODACESSOPADRAO||'^FS' || CHR(13) || CHR(10) || -- EAN
        '^FO50,20^A0N,40,40^FD'||SUBSTR(A.DESCCOMPLETA,0,40) ||' '||CASE WHEN J.QTDEMBALAGEM > 1 THEN J.EMBALAGEM ELSE NULL END||'^FS' || CHR(13) || CHR(10) || -- Desc
        '^FO30,251^A0N,20,20^FD'||TO_CHAR(SYSDATE, 'DD/MM/YY HH24:MI')||'   Produto: '||A.SEQPRODUTO||'   Val. Prom.: '||
                                TO_CHAR(NAGF_INICIOPROMETIQUETA(A.NROEMPRESA, A.SEQPRODUTO, H.PRECOVALIDPROMOC), 'DD/MM/YY')||' a ' ||
                                TO_CHAR(NAGF_FIMPROMETIQUETA   (A.NROEMPRESA, A.SEQPRODUTO, H.PRECOVALIDPROMOC), 'DD/MM/YY')|| '   LJ: ' || G.NOMEREDUZIDO||'^FS' || CHR(13) || CHR(10) || 
        '^FO275,90^A0N,35,35^FDOFERTA^FS'  || CHR(13) || CHR(10) ||
        '^FO490,100^A0N,30,30^FD  R$  ^FS' || CHR(13) || CHR(10) ||
        '^FO495,76^A0N,20,20^FD  POR  ^FS' || CHR(13) || CHR(10) ||
        '^FO580,73^A0N,58,58^FD'||LPAD(TRUNC(H.PRECOVALIDPROMOC), 4, ' ' ) || ',' || LPAD((H.PRECOVALIDPROMOC - TRUNC(H.PRECOVALIDPROMOC)) * 100, 2, 0)||'^FS' || CHR(13) || CHR(10) || -- Promoc
        (CASE WHEN J.MULTEQPEMB IS NOT NULL  OR J.MULTEQPEMBALAGEM IS NOT NULL THEN
        '^FO590,128^A0N,15,15^FDNesta Embalagem '||
                                CASE WHEN J.MULTEQPEMBALAGEM = 'LI' THEN 'L' when  J.MULTEQPEMBALAGEM = 'GR' THEN '100g' ELSE J.MULTEQPEMBALAGEM END ||' R$ ' ||
                                DECODE(SIGN(J.PRECOGERPROMOC),+1,
                                TRANSLATE(TO_CHAR(ROUND((J.PRECOGERPROMOC/(J.MULTEQPEMB*1000))*1000 ,2),'FM9990.00'), '.', ','),
                                TRANSLATE(TO_CHAR(ROUND((J.PRECOGERNORMAL/(J.MULTEQPEMB*1000))*1000 ,2),'FM9990.00'), '.', ','))  END )||'^FS' || CHR(13) || CHR(10) ||
        '^FO690,85^A0N,090,40^FD  ^FS'     || CHR(13) || CHR(10) ||
        '^FO50,95^A0N,25,25^FDR$^FS'       || CHR(13) || CHR(10) ||
        '^FO51,125^A0N,20,20^FDDE^FS'      || CHR(13) || CHR(10) ||
        '^FO70,92^A0N,60,60^^FD'||LPAD(TRUNC(H.PRECOVALIDNORMAL), 4, ' ' ) || ',' || LPAD((H.PRECOVALIDNORMAL - TRUNC(H.PRECOVALIDNORMAL)) * 100, 2, '0')|| '^FS' || CHR(13) || CHR(10) || -- PRECO NORMAL
        '^FO260,60^GB230,85,1^FS'          || CHR(13) || CHR(10) ||
        '^FO260,155^GB530,85,1^FS'         || CHR(13) || CHR(10) ||
        '^FO490,195^A0N,30,30^FD  R$  ^FS' || CHR(13) || CHR(10) ||
        '^FO495,175^A0N,20,20^FD  POR  ^FS'|| CHR(13) || CHR(10) ||
        '^FO275,170^A0N,35,35^FDMeu Nagumo^FS' || CHR(13) || CHR(10) ||
        '^FO275,205^A0N,20,20^FDExclusivo ^FS' || CHR(13) || CHR(10) ||
        '^FO580,167^A0N,58,58^FD'||LPAD(TRUNC(CONSINCO.NAGF_PRECOMN(A.CODACESSOPADRAO,A.NROEMPRESA)), 4, ' ' ) || ','||
                                   LPAD((CONSINCO.NAGF_PRECOMN(A.CODACESSOPADRAO,A.NROEMPRESA) -
                                   TRUNC(CONSINCO.NAGF_PRECOMN(A.CODACESSOPADRAO,A.NROEMPRESA))) * 100, 2, 0)||'^FR^FS'|| CHR(13) || CHR(10) ||
        (CASE WHEN J.MULTEQPEMB IS NOT NULL  OR J.MULTEQPEMBALAGEM IS NOT NULL THEN
        '^FO590,221^A0N,15,15^FDNesta Embalagem '||
                                CASE WHEN J.MULTEQPEMBALAGEM = 'LI' THEN 'L' when  J.MULTEQPEMBALAGEM = 'GR' THEN '100g' ELSE J.MULTEQPEMBALAGEM END ||' R$ ' ||
                                DECODE(SIGN(CONSINCO.NAGF_PRECOMN(A.CODACESSOPADRAO,A.NROEMPRESA)),+1,
                                TRANSLATE(TO_CHAR(ROUND((CONSINCO.NAGF_PRECOMN(A.CODACESSOPADRAO,A.NROEMPRESA)/(J.MULTEQPEMB*1000))*1000 ,2),'FM9990.00'), '.', ','),
                                TRANSLATE(TO_CHAR(ROUND((CONSINCO.NAGF_PRECOMN(A.CODACESSOPADRAO,A.NROEMPRESA)/(J.MULTEQPEMB*1000))*1000 ,2),'FM9990.00'), '.', ',')) END)||'^FS'|| CHR(13) || CHR(10) ||
        '^FO490,155^GB300,86,51^FR^FS'     || CHR(13) || CHR(10) ||
        '^FO490,60^GB300,85,50^FR^FS'

       -- Final Preco Meu Nagumo
       ELSE
                                             CHR(13) || CHR(10) || 
        '^FO90,115^GB150,4,4^FS'          || CHR(13) || CHR(10) ||-- RISCO
        '^FO050,170^BY2.4^BEN,25,Y,N^FD'||A.CODACESSOPADRAO||'^FS'|| CHR(13) || CHR(10) ||
        '^FO50,20^A0N,40,40^FD'||SUBSTR(A.DESCCOMPLETA,0,40) ||' '||CASE WHEN J.QTDEMBALAGEM > 1 THEN J.EMBALAGEM ELSE NULL END||'^FS' || CHR(13) || CHR(10) ||
        '^FO50,251^A0N,20,20^FD'||TO_CHAR(SYSDATE, 'DD/MM/YY HH24:MI')||'   Produto: '||A.SEQPRODUTO||'   Val. Prom.: '||
                                TO_CHAR(NAGF_INICIOPROMETIQUETA(A.NROEMPRESA, A.SEQPRODUTO, H.PRECOVALIDPROMOC), 'DD/MM/YY')||' a ' ||
                                TO_CHAR(NAGF_FIMPROMETIQUETA   (A.NROEMPRESA, A.SEQPRODUTO, H.PRECOVALIDPROMOC), 'DD/MM/YY')|| '   LJ: ' || G.NOMEREDUZIDO||'^FS' || CHR(13) || CHR(10) || 
        '^FO275,120^A0N,80,60^FDOFERTA^FS'|| CHR(13) || CHR(10) ||
        '^FO490,100^A0N,30,30^FD  R$  ^FS'|| CHR(13) || CHR(10) ||
        '^FO495,76^A0N,20,20^FD  POR  ^FS'|| CHR(13) || CHR(10) ||
        '^FO470,80^A0N,150,110^FD'||LPAD(TRUNC(H.PRECOVALIDPROMOC), 4, ' ' ) || ',' || LPAD((H.PRECOVALIDPROMOC - TRUNC(H.PRECOVALIDPROMOC)) * 100, 2, 0)||'^FS' || CHR(13) || CHR(10) || -- Promoc
        (CASE WHEN J.MULTEQPEMB IS NOT NULL  OR J.MULTEQPEMBALAGEM IS NOT NULL THEN
        '^FO590,215^A0N,15,15^FDNesta Embalagem '||
                                CASE WHEN J.MULTEQPEMBALAGEM = 'LI' THEN 'L' when  J.MULTEQPEMBALAGEM = 'GR' THEN '100g' ELSE J.MULTEQPEMBALAGEM END ||' R$ ' ||
                                DECODE(SIGN(J.PRECOGERPROMOC),+1,
                                TRANSLATE(TO_CHAR(ROUND((J.PRECOGERPROMOC/(J.MULTEQPEMB*1000))*1000 ,2),'FM9990.00'), '.', ','),
                                TRANSLATE(TO_CHAR(ROUND((J.PRECOGERNORMAL/(J.MULTEQPEMB*1000))*1000 ,2),'FM9990.00'), '.', ','))END )||'^FS' || CHR(13) || CHR(10) ||
        '^FO690,85^A0N,090,40^FD  ^FS'    || CHR(13) || CHR(10) ||
        '^FO50,95^A0N,25,25^FDR$^FS'      || CHR(13) || CHR(10) ||
        '^FO51,125^A0N,20,20^FDDE^FS'     || CHR(13) || CHR(10) ||
        '^FO70,92^A0N,60,60^FD'||LPAD(TRUNC(H.PRECOVALIDNORMAL), 4, ' ' ) || ',' || LPAD((H.PRECOVALIDNORMAL - TRUNC(H.PRECOVALIDNORMAL)) * 100, 2, '0')|| '^FS' || CHR(13) || CHR(10) || -- PRECO NORMAL
        '^FO260,60^GB230,180,1^FS'        || CHR(13) || CHR(10) ||
        '^FO490,60^GB300,180,100^FR^FS'

       END -- Final do case para meu nagumo

---------------INICIO PRECO UNICO normal ou promo¿¿¿¿o for MAIOR que Normal
         when /*round (a.preco1/a.qtdembalagem1,2) = trunc((a.precoembpadrao/a.padraoembvenda),2) or*/
           (nvl(a.precovalidpromoc,0) >= trunc((a.precovalidnormal/a.padraoembvenda),2))
           then
         chr(13) || chr(10) || '^FO18,007^ATN,5,5^FD'|| substr(a.Desccompleta,0,40) ||' '||case when j.qtdembalagem > 1 then j.embalagem else null end|| '^FS'
      || chr(13) || chr(10) || '^FO050,200^BY2.4^BEN,30,Y,N^FD' || a.codacessopadrao ||'^FS' --ean cod barras
      --- QR CODE Etiquera Normal
      || chr(13) || chr(10) || '^FO050,075^BQ,2,4^FDLA,:p:' || (select distinct(r.codigo || ':vp:' || r.codigo_preco)
                                                                        from rub.rub_produto r
                                                                        where R.id_loja = g.nroempresa
                                                                        AND R.codigo = a.seqproduto) || '^FS'
      || chr(13) || chr(10) ||'^FO180,100^A0N,110,60^FDR$^FS' ||'^FS' -- R$
      || chr(13) || chr(10) ||'^FO350,90^A0N,170,130^FD'|| lpad(trunc(a.precoembpadrao), 4, ' ' ) || ',' || --preco normal
                                                           lpad((a.precoembpadrao - trunc(a.precoembpadrao)) * 100, 2, '0')|| '^FS'

----PREÇO POR KG ou LI ou etc...
||    (CASE WHEN
       J.MULTEQPEMB IS NOT NULL  OR J.MULTEQPEMBALAGEM IS NOT NULL
       THEN
CHR(13) || CHR(10) || '^FO550,255^A0N,20,19^FD' ||/* '*PRECO PAGO POR ' || J.MULTEQPEMBALAGEM ||' R$   '*/'Nesta Embalagem ' || CASE WHEN J.MULTEQPEMBALAGEM = 'LI' THEN 'L'
                                                                                                                                                                                                                                                                    when  J.MULTEQPEMBALAGEM = 'GR' THEN '100g'
                                                                                                                                                                                                                                                                     ELSE J.MULTEQPEMBALAGEM END ||' R$ '
      || DECODE(SIGN(J.PRECOGERPROMOC/*J.PRECOGERNORMAL*/),+1,
       TRANSLATE(TO_CHAR(ROUND((J.PRECOGERPROMOC/(J.MULTEQPEMB*1000))*1000 ,2),'FM9990.00'), '.', ','),
       TRANSLATE(TO_CHAR(ROUND((J.PRECOGERNORMAL/(J.MULTEQPEMB*1000))*1000 ,2),'FM9990.00'), '.', ','))
|| CHR(13) || CHR(10) || ''
END)||'^FR^FS'

      || chr(13) || chr(10) || '^FO03,265^A0N,13,16^FD'||'LOJA:'|| g.nomereduzido || '^FS'
      || chr(13) || chr(10) || '^FO160,265^A0N,13,16^FD' ||  to_char(sysdate, 'dd/mm/yy hh24:mi') || '^FS'
      || chr(13) || chr(10) || '^FO260,265^A0N,13,16^FD'  || 'PROD:'|| a.seqproduto ||'^FS' -- COD INTERNO


 ------------INICIO PRECO UNICO Caso NAO esteja em oferta e tenha precos dif por embalagens
         when trunc(a.preco1/a.qtdembalagem1,2) = trunc((a.precoembpadrao/a.padraoembvenda),2) and (nvl(a.precovalidpromoc,0) = 0)
           then
         chr(13) || chr(10) || '^FO18,007^ATN,5,5^FD'|| substr(a.Desccompleta,0,40)||' '||case when j.qtdembalagem > 1 then j.embalagem else null end || '^FS'
    --  || chr(13) || chr(10) || '^FO050,200^BY2.4^BEN,30,Y,N^FD' || a.codacessopadrao ||'^FS' --ean cod barras
       || chr(13) || chr(10) ||decode(length(i.codacesso),13, '^FO050,200^BY2.4^BEN,30,Y,N^FD', '^FO050,200^BY2.4^BCN,30,Y,N^FD' ) || i.codacesso ||'^FS' --ean cod barras barras
        --- QR CODE Etiquera Normal
      || chr(13) || chr(10) || '^FO050,075^BQ,2,4^FDLA,:p:' || (select distinct(r.codigo || ':vp:' || r.codigo_preco)
                                                                        from rub.rub_produto r
                                                                        where R.id_loja = g.nroempresa
                                                                        AND R.codigo = a.seqproduto) || '^FS'
      || chr(13) || chr(10) ||'^FO180,100^A0N,110,60^FDR$^FS' ||'^FS' -- R$
      || chr(13) || chr(10) ||'^FO350,90^A0N,170,130^FD'|| lpad(trunc(a.precoembpadrao), 4, ' ' ) || ',' || --preco normal
                                                           lpad((a.precoembpadrao - trunc(a.precoembpadrao)) * 100, 2, '0')|| '^FS'

----PREÇO POR KG
||    (CASE WHEN
       J.MULTEQPEMB IS NOT NULL  OR J.MULTEQPEMBALAGEM IS NOT NULL
       THEN
CHR(13) || CHR(10) || '^FO550,255^A0N,20,19^FD' || /*'*PRECO PAGO POR ' || J.MULTEQPEMBALAGEM ||' R$   '*/ 'Nesta Embalagem ' || CASE WHEN J.MULTEQPEMBALAGEM = 'LI' THEN 'L'
                                                                                                                                                                                                                                                                    when  J.MULTEQPEMBALAGEM = 'GR' THEN '100g'
                                                                                                                                                                                                                                                                     ELSE J.MULTEQPEMBALAGEM END ||' R$ '
      || DECODE(SIGN(J.PRECOGERPROMOC/*J.PRECOGERNORMAL*/),+1,
       TRANSLATE(TO_CHAR(ROUND((J.PRECOGERPROMOC/(J.MULTEQPEMB*1000))*1000 ,2),'FM9990.00'), '.', ','),
       TRANSLATE(TO_CHAR(ROUND((J.PRECOGERNORMAL/(J.MULTEQPEMB*1000))*1000 ,2),'FM9990.00'), '.', ','))
|| CHR(13) || CHR(10) || ''
END)||'^FR^FS'

      || chr(13) || chr(10) || '^FO03,265^A0N,13,16^FD'||'LOJA:'|| g.nomereduzido || '^FS'
      || chr(13) || chr(10) || '^FO160,265^A0N,13,16^FD' ||  to_char(sysdate, 'dd/mm/yy hh24:mi') || '^FS'
      || chr(13) || chr(10) || '^FO260,265^A0N,13,16^FD'  || 'PROD:'|| a.seqproduto ||'^FS' -- COD INTERNO
      ---FO645,265^A0N,13,16^FD



end


--Fim da Etiqueta
|| chr(13) || chr(10) || '^XZ'
|| chr(13) || chr(10) linha


from  consinco.mrlx_baseetiquetaprod a,
      consinco.map_produto b,
      consinco.map_familia c,
      consinco.map_marca d,
      consinco.MRL_PRODUTOEMPRESA E,
      consinco.mrl_gondola f,
      consinco.ge_empresa g,
      consinco.mrl_prodempseg h,
      consinco.map_prodcodigo i,
      consinco.mrlv_baseetiquetaprod_nag j,
      consinco.map_famembalagem m

where a.seqproduto = b.seqproduto
  and c.seqfamilia = b.seqfamilia
  and a.seqproduto = h.seqproduto
  and a.nroempresa = h.nroempresa
  and a.nrosegmento = h.nrosegmento
  and g.nroempresa = e.nroempresa
  and d.seqmarca(+) = c.seqmarca
  AND E.SEQPRODUTO = A.SEQPRODUTO
  AND E.NROEMPRESA = A.NROEMPRESA
  and e.nrogondola = f.nrogondola
  and e.nroempresa = f.nroempresa
  and a.codacesso = i.codacesso
  and i.qtdembalagem = h.qtdembalagem

  and i.qtdembalagem = m.qtdembalagem
  and i.seqfamilia = m.seqfamilia
  and i.qtdembalagem = a.qtdembcodacesso
  ------------------------------------
  and a.nroempresa = j.nroempresa
  and a.seqproduto = j.seqproduto
  and a.nrosegmento = j.nrosegmento
  and b.seqproduto = j.seqproduto
  and b.seqfamilia = j.seqfamilia
  and c.seqfamilia = j.seqfamilia
  and e.seqproduto = j.seqproduto
  and e.nroempresa = j.nroempresa
  and e.nrogondola = j.nrogondola
  and f.nrogondola = j.nrogondola
  and f.nroempresa = j.nroempresa
  and g.nroempresa = j.nroempresa
  and h.seqproduto = j.seqproduto
  and h.nrosegmento = j.nrosegmento
  and h.nroempresa = j.nroempresa
  and h.qtdembalagem = j.qtdembalagem
  and i.seqfamilia = j.seqfamilia
  and i.seqproduto = j.seqproduto



  order by linha
;
