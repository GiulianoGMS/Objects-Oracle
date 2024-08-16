CREATE OR REPLACE VIEW CONSINCO.MAXV_ABCDISTRIBBASE_NAG_VEST AS
select /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/
/*1.000*/ 1 idsql,
/*1.001*/ nvl( a.dtahorlancto, a.dtaemissao ) dtahorlancto,
/*1.002*/ a.dtaemissao dtavda,
/*1.003*/ a.nroempresa,
/*1.004*/ a.numeronf nrodocto,
/*1.005*/ a.serienf seriedocto,
/*1.006*/ case when a.apporigem = 26 then
               nvl( a.seqpessoatomadornfse, a.seqpessoa )
          else
               a.seqpessoa
          end seqPESSOA,
/*1.007*/ nvl( a.enderecoentrega, 0 ) seqpessoaend,
/*1.008*/ a.versaopessoa,
/*1.009*/ a.usulancto operador,
/*1.010*/ ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( min( g.sequsuario ), 0 )
            from ge_usuario g
            where g.codusuario = a.USULANCTO
          ) seqoperador,
/*1.011*/ 0 checkout,
/*1.012*/ b.seqproduto,
/*1.013*/ nvl( b.seqprodutobase, b.seqproduto ) seqprodutocusto,
/*1.014*/ b.seqitemnf seqitem,
/*1.015*/ b.qtdembalagem qtdembalitem,
/*1.016*/ b.quantidade qtditem,
/*1.017*/ 0 qtddevolitem,
/*1.018*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrdescitem, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
            + nvl( b.vlricmsst, 0 )
            + nvl( b.vlrfcpst, 0 )
          ) vlritem,
/*1.019*/ nvl( b.vlripi, 0 ) vlripiitem,
/*1.020*/ nvl( b.vlrdescitem, 0 ) + nvl( b.vlrfunruralitem, 0 ) vlrdesconto,
/*1.021*/ 0 vlracrescimo,
/*1.022*/ 0 vlrdevolitem,
/*1.023*/ 0 vlripidevolitem,
/*1.024*/ case when ( ( substr(b.situacaonf, -2) = '90' or b.tipocalcicmsfisci = 26 ) and e.uf = 'CE' ) then
            0
          else
            greatest( 0,
              nvl( b.vlricms, (
              decode( nvl( nvl( b.vlricmscalc, b.bascalcicms * b.peraliquotaicms / 100 ), 0 ),
                      0,
                      nvl( b.vlricmsvpe, 0 ),
                      nvl( b.vlricmscalc, b.bascalcicms * b.peraliquotaicms / 100 )
              )
              -
              ( case when b.tipocalcicmsfisci = 25 then
                    round( ( b.bascalcicms * b.peraliquotaicms / 100 * nvl( b.peraliqicmsdif, 0 ) / 100 ), 2 )
                when e.uf = 'RJ' and substr(b.situacaonf, -2) = '51' then
                     nvl( b.vlricmsdiferido, 0 )
                else
                    0
                end
              )
              -
              (
              case when PD1.VALOR = 'N' then
                   0
              else
                   nvl( b.vlricmspresumido, 0 )
              end
              )
              ) ) ) end icmsitem,
/*1.025*/ 0 icmsdevolitem,
/*1.026*/ nvl( b.vlrpis, 0 ) pisitem,
/*1.027*/ 0 pisdevolitem,
/*1.028*/ nvl( b.vlrcofins, 0 ) cofinsitem,
/*1.029*/ 0 cofinsdevolitem,
/*1.030*/ 0 vlrrestornoitem,
/*1.031*/ 0 vlrrestornodevolitem,
/*1.032*/ nvl( b.vlrtotiss, 0 ) issitem,
/*1.033*/ 0 issdevolitem,
/*1.034*/ 'NF' tipdocto,
/*1.035*/ nvl( b.nrorepresentante, nvl( p.nroreppadrao, 0 ) ) nrorepresentante,
/*1.036*/ decode( nvl( b.nrorepresentante, nvl( p.nroreppadrao, 0 ) ),
                    0, nvl( b.nrosegitem, e.nrosegmentoprinc ),
                    coalesce( b.nrosegitem, ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( max( r.nrosegmento ), e.nrosegmentoprinc )
                                              from mad_representante r
                                              where r.nrorepresentante = nvl( b.nrorepresentante, nvl( p.nroreppadrao, 0 ) ) )
                    )
          ) nrosegmento,
/*1.037*/ nvl( a.nroformapagto, p.formapagtopadrao ) nroformapagto,
/*1.038*/ a.dtaemissao dtavencimento,
/*1.039*/ a.pzomediopagamento nrodiasprazomedio,
/*1.040*/ d.acmcompravenda,
/*1.041*/ e.perpis,
/*1.042*/ e.percofins,
/*1.043*/ e.percpmf,
/*1.044*/ e.perir,
/*1.045*/ e.pericmsestimativa,
/*1.046*/ e.peroutroimposto,
/*1.047*/ 0 vlrtotcomissaoitem,
/*1.048*/ 0 vlrtotcomissaoitemdevol,
/*1.049*/ to_number( null ) nrocarga,
/*1.050*/ a.nrocondpagto nrocondicaopagto,
/*1.051*/ a.codgeraloper,
/*1.052*/ null origempedido, -- ou 'X' sem pedido
/*1.053*/ s.indprecoembalagem,
/*1.054*/ rowidtochar( a.rowid ) rowiddocto,
/*1.055*/ b.seqproduto seqprodutovda,
/*1.056*/ to_number( null ) seqprodutodevol,
/*1.057*/ a.seqpessoa seqpessoavda,
/*1.058*/ to_number( null ) seqpessoadevol,
/*1.059*/ rowidtochar( a.rowid ) rowiddoctovda,
/*1.060*/ null rowiddoctodevol,
/*1.061*/ b.seqloteestoque,
/*1.062*/ to_number( null ) seqpromocpdv,
/*1.063*/ b.classifabcfamseg,
/*1.064*/ 0 vlrdescforanf,
/*1.065*/ 'VENDA' ocorrenciadev,
/*1.066*/ '*** VENDA ***' descocorrenciadev,
/*1.067*/ case when a.seqpessoatomadornfse = a.nroempresa or a.seqpessoatomadornfse = e.seqpessoaemp then
                         ( + b.vlritem
                         + nvl( b.vlrdescsf, 0 )
                         - nvl( b.vlrdescitem, 0 )
                         - nvl( b.vlrfunruralitem, 0 )
                         + case when a.indconsidfretedesptrib = 'N' then
                                nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
                           else
                                nvl( b.vlrdesptributitem, 0 )
                           end
                         + nvl( b.vlrdespntributitem, 0 )
                         - nvl( b.vlrdescsuframa, 0 )
                         + nvl( b.vlripi, 0 )  )
               else
                   nvl( b.vlrdespoperacionalitem, 0 ) end vlrdespoperacionalitem,
/*1.068*/ 0 vlrdespoperacionalitemdevol,
/*1.069*/ to_number( null ) vlritemsemst,
/*1.070*/ to_number( null ) vlrdevolitemsemst,
/*1.071*/ nvl( b.vlricmsst, 0 ) vlricmsst,
/*1.072*/ 0 vlrdevolicmsst,
/*1.073*/ 0 vlrfrete,
/*1.074*/ null nroserieecf,
/*1.075*/ 'N' tiptabela,
/*1.076*/ d.acmcompravenda cgoacmcompravenda,
/*1.077*/ a.seqauxnotafiscal,
/*1.078*/ ( + b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
          ) vlritemsemdesc,
/*1.079*/ b.vlrdescitem,
/*1.080*/ 0 vlrdevolitemsemdesc,
/*1.081*/ 0 vlrdescdevolitem,
/*1.082*/ b.vlrtotcomissaotele,
/*1.083*/ null nrotelevenda,
/*1.084*/ b.vlrcompror,
/*1.085*/ b.vlrembdescressarcst,
/*1.086*/ 0 vlrembdescressarcstdevol,
/*1.087*/ a.nropromotor,
/*1.088*/ a.tipnotafiscal,
/*1.089*/ 0 vlricmsstemporig,
/*1.090*/ 0 vlrcustobrutoemporig,
/*1.091*/ nvl( b.vlrfreteabc, 0 ) vlrfreteabc,
/*1.092*/ e.nrodivisao,
/*1.093*/ null nroequipe,
/*1.094*/ case when nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) < 0 then
                 0
          else
                 nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 )
          end custofiscalunit,
/*1.095*/ case when ( nvl( M.CMULTCUSLIQUIDOEMP, 0 ) - nvl( M.CMULTDCTOFORANFEMP, 0 ) ) * nvl( m.estqempresa, 0 ) < 0 then
                 0
          else
                 ( nvl( M.CMULTCUSLIQUIDOEMP, 0 ) - nvl( M.CMULTDCTOFORANFEMP, 0 ) ) * nvl( m.estqempresa, 0 )
          end custofiscaltotal,
/*1.096*/ pe.uf ufpessoa,
/*1.097*/ null codareageograficavda,
/*1.098*/ null codsubareageograficavda,
/*1.099*/ null vlrvendapromoc,
/*1.100*/ a.seqtransportador,
/*1.101*/ null nrotabvenda,
/*1.102*/ a.seqnf,
/*1.103*/ nvl( b.vlrverbacompra, 0 ) vlrverbacompra,
/*1.104*/ nvl( b.vlrverbabonifincid, 0 ) vlrverbabonifincid,
/*1.105*/ nvl( b.vlrverbabonifsemincid, 0 ) vlrverbabonifsemincid,
/*1.106*/ 0 vlrverbacompradev,
/*1.107*/ 0 vlrverbabonifinciddev,
/*1.108*/ 0 vlrverbabonifseminciddev,
/*1.109*/ b.seqproduto seqprodutofinal,
/*1.110*/ b.quantidade qtditemprodfinal,
/*1.111*/ 0 qtditemdevprodfinal,
/*1.112*/ m.cmultvlrdespfixa,
/*1.113*/ m.cmultvlrdescfixo,
/*1.114*/ b.vlrdescverbatransf,
/*1.115*/ b.vlrdesclucrotransf,
/*1.116*/ null dtanfref,
/*1.117*/ nvl( b.vlrverbavda, 0 ) vlrverbavda,
/*1.118*/ nvl( b.qtdverbavda, 0 ) qtdverbavda,
/*1.119*/ 0 vlrverbavdadevol,
/*1.120*/ 0 qtdverbavdadevol,
/*1.121*/ null seqpromocao,
/*1.122*/ nvl( b.qtdverbapdv, 0 ) qtdverbapdv,
/*1.123*/ nvl( b.vlrverbapdv, 0 ) vlrverbapdv,
/*1.124*/ 0 qtdverbadevol,
/*1.125*/ 0 vlrverbapdvdevol,
/*1.126*/ nvl( b.vlrpiscofinsverbapdv, 0 ) vlrpiscofinsverbapdv,
/*1.127*/ 0 vlrpiscofinsverbapdvdevol,
/*1.128*/ 0 vlrdescmedalha,
/*1.129*/ m.vlrgmroi,
/*1.130*/ m.indposicaocateg,
/*1.131*/ 0 vlrdescfornec,
/*1.132*/ 0 vlrdescfornecdevol,
/*1.133*/ null tipopromocpdv,
/*1.134*/ nvl( b.vlrfreteitemrateio, 0 ) vlrfreteitemrateio,
/*1.135*/ 0 vlrfreteitemrateiodev,
/*1.136*/ nvl( b.vlricmsstembutprod, 0 ) vlricmsstembutprod,
/*1.137*/ 0 vlricmsstembutproddev,
/*1.138*/ b.seqcluster,
/*1.139*/ nvl( b.nfreferencianro, a.nfreferencianro ) nfreferencianro,
/*1.140*/ nvl( b.nfreferenciaserie, a.nfreferenciaserie ) nfreferenciaserie,
/*1.141*/ 'N' indpromocao,
/*1.142*/ 0 vlrdescacordoverbapdv,
/*1.143*/ 0 vlrdifcampanhapreco,
/*1.144*/ 0 vlrdifcampanhaprecodevol,
/*1.145*/ 0 vlrcustonfprecocamp,
/*1.146*/ null seqcampanha,
/*1.147*/ b.vlrprecomargemzero,
/*1.148*/ 0 qtddotznormal,
/*1.149*/ 0 vlrvendadotznormal,
/*1.150*/ 0 qtddotzextra,
/*1.151*/ 0 vlrvendadotzextra,
/*1.152*/ 0 qtddotztotal,
/*1.153*/ 0 vlrvendadotztotal,
/*1.154*/ 0 seqzonavenda,
/*1.155*/ 0 vlrdesccomercial,
/*1.156*/ pe.grupo grupocliente,
/*1.157*/ 0 vlritemrateiocte,
/*1.158*/ null ctenro,
/*1.159*/ null cteserie,
/*1.160*/ 0 vlrverbavdasemicus,
/*1.161*/ nvl(b.vlrfcpst, 0) vlrfcpst,
/*1.162*/ nvl(b.vlrfcpicms, 0) vlrfcpicms,
/*1.163*/ nvl(b.vlrfcpdistrib, 0) vlrfcpdistrib,
/*1.164*/ nvl(b.vlrfcpstsubst, 0) vlrfcpstsubst,
/*1.165*/ 0 dvlrfcpst,
/*1.166*/ 0 dvlrfcpicms,
/*1.167*/ 0 dvlrfcpdistrib,
/*1.168*/ 0 dvlrfcpstsubst,
/*1.169*/ nvl(b.vlricmsefet, 0) icmsefetivoitem,
/*1.170*/ 0 icmsefetivodevolitem,
/*1.171*/ pe.indcontribicms,
/*1.172*/ pe.fisicajuridica,
/*1.173*/ nvl(d.indconsumidorfinal, 'N') B,
/*1.174*/ d.tipdocfiscal tipdocfiscalcgo,
/*1.175*/ null nropedidovenda,
/*1.176*/ d.tipcgo tipcgo,
/*1.177*/ 0 vlripiprecovda,
/*1.178*/ 0 vlripiprecodevol,
/*1.179*/ 0 vlrdescmedalhadevol
/* Quando implementar nova coluna, tratar tambem na view "MAXV_ABCFORMAPAGTO". Manter comentario apos a ultima coluna. */
from   mlf_notafiscal     a,   mlf_nfitem    b,
       max_codgeraloper   d,   max_empresa   e,
       mad_segmento       s,   mad_parametro p,
       mrl_produtoempresa m,   ge_pessoa     pe,
       max_divisao        v,
       (SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ NVL(MAX(X.VALOR), 'N') VALOR
          FROM MAX_PARAMETRO X
         WHERE X.NROEMPRESA = 0
           AND X.GRUPO = 'ABC_DISTRIB'
           AND X.PARAMETRO = 'CONSID_ICMS_PRESUMIDO') PD1
where  a.numeronf        = b.numeronf
and    a.seqpessoa       = b.seqpessoa
and    a.serienf         = b.serienf
and    a.tipnotafiscal   = b.tipnotafiscal
and    a.nroempresa      = b.nroempresa
and    nvl( a.seqnf, 0 ) = nvl( b.seqnf, nvl( a.seqnf, 0 ) )
and    a.codgeraloper    = d.codgeraloper
and    a.nroempresa      = e.nroempresa
and    s.nrosegmento     = nvl( b.nrosegitem, e.nrosegmentoprinc )
and    p.nroempresa      = a.nroempresa
and    m.seqproduto      = nvl( b.seqprodutobase, b.seqproduto )
and    m.nroempresa      = nvl( e.nroempcustoabc, e.nroempresa )
and    a.statusnf        = 'V'
and    a.tipnotafiscal   = 'S'
and    b.tipitem         = 'E'
and    d.tipcgo          = 'S'
and    b.quantidade      != 0
and    ( coalesce( a.geralteracaoestq, d.geralteracaoestq ) = 'S'
         or d.acmcompravenda in ( 'S', 'I' ) )
and    a.seqpessoa       = pe.seqpessoa
and    e.nrodivisao      = v.nrodivisao
AND    nvl( a.dtahorlancto, a.dtaemissao ) >= SYSDATE - 150
AND EXISTS (SELECT 1 FROM CONSINCO.NAGT_DEPARA_VESTRH ZZ WHERE ZZ.SEQPRODUTO = B.SEQPRODUTO)
AND A.CODGERALOPER IN (60,923,914,64,102,949,210,57,948,10,941,1,927,211,814,802,801,944,811,850,942,95,261,931,240)
union all
-- VENDAS NORMAIS DO ATACADO - GRAVADAS NA MFL_DOCTOFISCAL
select
/*2.000*/ 2 idsql,
/*2.001*/ a.dtahoremissao dtahorlancto,
/*2.002*/ a.dtamovimento dtavda,
/*2.003*/ a.nroempresa,
/*2.004*/ a.numerodf nrodocto,
/*2.005*/ a.seriedf seriedocto,
/*2.006*/ a.seqpessoa,
/*2.007*/ nvl( a.seqpessoaend, 0 ) seqpessoaend,
/*2.008*/ a.versaopessoa,
/*2.009*/ coalesce( a.codoperador, ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ min( g.codusuario)
                                     from ge_usuario g
                                     where g.sequsuario = a.seqoperador )
          ) operador,
/*2.010*/ case when a.codoperador is not null then
             ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ min( g.sequsuario )
                 from ge_usuario g
                where g.codusuario = a.codoperador )
          else
             a.seqoperador
          end seqoperador,
/*2.011*/ nvl( a.nrocheckout, 0 ) checkout,
/*2.012*/ b.seqproduto,
/*2.013*/ nvl( b.seqprodutobase, b.seqproduto ) seqprodutocusto,
/*2.014*/ b.seqitemdf seqitem,
/*2.015*/ qtdembalagem qtdembalitem,
/*2.016*/ b.quantidade qtditem,
/*2.017*/ 0 qtddevolitem,
/*2.018*/ ( b.vlritem
            - ( nvl( b.vlrdesconto,0 ) - nvl( b.vlrdescbonifabc,0 ) )
            + nvl( b.vlracrescimo, 0 )
          ) vlritem,
/*2.019*/ nvl( b.vlripi, 0 ) vlripiitem,
/*2.020*/ nvl( b.vlrdesconto, 0 ) - nvl( b.vlrdescbonifabc, 0 ) vlrdesconto,
/*2.021*/ nvl( b.vlracrescimo, 0 ) vlracrescimo,
/*2.022*/ 0 vlrdevolitem,
/*2.023*/ 0 vlripidevolitem,
/*2.024*/ case when ( ( substr(b.situacaonf, -2) = '90' or b.tipocalcicmsfisci = 26 ) and e.uf = 'CE' ) then
            0
          else
            greatest( 0,
            nvl( b.vlricms, (
            round( decode( coalesce( decode( pg.indutilicmstaresugprabc, 'S', b.vlricmssolicit, null ),
                                     b.vlricmscalc,
                                     b.bascalcicms * b.peraliquotaicms / 100,
                                     0
                                   ), 0,
                                       nvl( b.vlricmsvpe, 0 ),
                                       coalesce( decode( pg.indutilicmstaresugprabc, 'S', b.vlricmssolicit, null ),
                                                 b.vlricmscalc,
                                                 b.bascalcicms * b.peraliquotaicms / 100,
                                                 0 )
                         )
            , 2 )
            -
            ( case when b.tipocalcicmsfisci = 25 then
                  round( ( b.bascalcicms * b.peraliquotaicms / 100 * nvl( b.peraliqicmsdif, 0 ) / 100 ), 2 )
              when e.uf = 'RJ' and substr(b.situacaonf, -2) = '51' then
                   nvl( b.vlricmsdiferido, 0 )
              else
                  0
              end
            )
            -
            (
            case when PD7.VALOR = 'N' then
                 0
            else
                 nvl( b.vlricmspresumido, 0 )
            end
            )
            ) ) ) end icmsitem,
/*2.025*/ 0 icmsdevolitem,
/*2.026*/ nvl( b.vlrpis, 0 ) pisitem,
/*2.027*/ 0 pisdevolitem,
/*2.028*/ nvl( b.vlrcofins, 0 ) cofinsitem,
/*2.029*/ 0 cofinsdevolitem,
/*c.030*/ nvl( b.vlrrestorno, 0 ) vlrrestornoitem,
/*c.031*/ 0 vlrrestornodevolitem,
/*c.032*/ nvl( b.vlrtotiss, 0 ) issitem,
/*2.033*/ 0 issdevolitem,
/*2.034*/ 'DF' tipdocto,
/*2.035*/ decode( nvl( b.nrorepitem, 0 ),
               0,
               nvl( decode( pd6.valor, 'P', to_number( null ), a.seqvendedor ), nvl( x.nroreppadrao, 0 ) ),
               nvl( b.nrorepitem, 0 )
          ) nrorepresentante,
/*2.036*/ nvl( nvl( b.nrosegitem, a.nrosegmento ), e.nrosegmentoprinc ) nrosegmento,
/*2.037*/ nvl( a.nroformapagto, x.formapagtopadrao ) nroformapagto,
/*2.038*/ a.dtavencimento,
/*2.039*/ a.prazomediovencto nrodiasprazomedio,
/*2.040*/ d.acmcompravenda,
/*2.041*/ e.perpis,
/*2.042*/ e.percofins,
/*2.043*/ e.percpmf,
/*2.044*/ e.perir,
/*2.045*/ e.pericmsestimativa,
/*2.046*/ e.peroutroimposto,
/*2.047*/ nvl( b.vlrtotcomissao, 0 ) vlrtotcomissaoitem,
/*2.048*/ 0 vlrtotcomissaoitemdevol,
/*2.049*/ a.nrocarga,
/*2.050*/ a.nrocondicaopagto,
/*2.051*/ a.codgeraloper,
/*2.052*/ nvl( a.origempedido, 'R' ) origempedido,
/*2.053*/ s.indprecoembalagem,
/*2.054*/ rowidtochar( a.rowid ) rowiddocto,
/*2.055*/ b.seqproduto seqprodutovda,
/*2.056*/ to_number( null ) seqprodutodevol,
/*2.057*/ a.seqpessoa seqpessoavda,
/*2.058*/ to_number( null ) seqpessoadevol,
/*2.059*/ rowidtochar( a.rowid ) rowiddoctovda,
/*2.060*/ null rowiddoctodevol,
/*2.061*/ b.seqloteestoque,
/*2.062*/ b.seqpromocpdv,
/*2.063*/ b.classifabcfamseg,
/*2.064*/ nvl( b.vlrdescforanf, 0 ) vlrdescforanf,
/*2.065*/ 'VENDA' ocorrenciadev,
/*2.066*/ '*** VENDA ***' descocorrenciadev,
/*2.067*/ b.vlrdespoperacionalitem vlrdespoperacionalitem,
/*2.068*/ to_number( null ) vlrdespoperacionalitemdevol,
/*2.069*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - ( nvl( b.vlrdesconto, 0 ) - nvl( b.vlrdescbonifabc, 0 ) )
            + nvl( b.vlracrescimo, 0 )
            - nvl( b.vlricmsst, 0 )
            - nvl( b.vlrfcpst, 0 )
          ) vlritemsemst,
/*2.070*/ 0 vlrdevolitemsemst,
/*2.071*/ nvl( b.vlricmsst, 0 ) vlricmsst,
/*2.072*/ 0 vlrdevolicmsst,
/*2.073*/ nvl( b.vlrfretetransp, 0 ) vlrfrete,
/*2.074*/ a.nroserieecf,
/*2.075*/ 'D' tiptabela,
/*2.076*/ d.acmcompravenda cgoacmcompravenda,
/*2.077*/ null seqauxnotafiscal,
/*2.078*/ ( b.vlritem
            + nvl( b.vlracrescimo, 0 )
            /* - nvl( b.vlricmsst, 0 )*/
          ) vlritemsemdesc,
/*2.079*/ ( nvl( b.vlrdesconto, 0 ) - nvl( b.vlrdescbonifabc, 0 ) ) vlrdescitem,
/*2.080*/ 0 vlrdevolitemsemdesc,
/*2.081*/ 0 vlrdescdevolitem,
/*2.082*/ b.vlrtotcomissaotele,
/*2.083*/ ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ max(x.nrotelevenda)
              from mad_pedvendaitem y, mad_pedvenda x
             where y.nropedvenda  = x.nropedvenda
               and y.nroempresa   = x.nroempresa
               and y.numerodf     = a.numerodf
               and y.seriedf      = a.seriedf
               and y.nroempresadf = a.nroempresa
               and y.seqproduto   = b.seqproduto
               and y.qtdembalagem = nvl( b.qtdembalagem, y.qtdembalagem ) ) nrotelevenda,
               /*fNroTeleVendaPed(a.numerodf, a.seriedf, a.nroempresa, b.seqproduto, b.qtdembalagem) */
               /*essa func?o nao pode ser removida devido aos problemas do rc 69429*/
/*2.084*/ null vlrcompror,
/*2.085*/ nvl( b.vlrembdescressarcst, 0 ) vlrembdescressarcst,
/*2.086*/ 0 vlrembdescressarcstdevol,
/*2.087*/ a.nropromotor,
/*2.088*/ 'S' tipnotafiscal,
/*2.089*/ b.vlricmsstemporig,
/*2.090*/ b.vlrcustobrutoemporig,
/*2.091*/ nvl( b.vlrfreteabc, 0 ) vlrfreteabc,
/*2.092*/ e.nrodivisao,
/*2.093*/ decode( pd1.valor, 'S', null, nvl( b.nroequiperepitemdtamovto, a.nroequiperepdtamovto ) ) nroequipe,
/*2.094*/ case when ( nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) ) < 0 then
                 0
          else
                 nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 )
          end custofiscalunit,
/*2.095*/ case when ( nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) ) * nvl( m.estqempresa, 0 ) < 0 then
                 0
          else
                 ( nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) ) * nvl( m.estqempresa, 0 )
          end custofiscaltotal,
/*2.096*/ pe.uf ufpessoa,
/*2.097*/ a.codareageograficavda,
/*2.098*/ a.codsubareageograficavda,
/*2.099*/ decode( b.indpromocao, 'S', b.vlritem, 'N', 0, null, null ) vlrvendapromoc,
/*2.100*/ a.seqtransportador,
/*2.101*/ case when pd2.valor = 'S' then
              ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ max( nvl( y.nrotabvenda, x.nrotabvenda ) )
                from   mad_pedvendaitem y, mad_pedvenda x
                where  y.nropedvenda  = x.nropedvenda
                and    y.nroempresa   = x.nroempresa
                and    y.numerodf     = a.numerodf
                and    y.seriedf      = a.seriedf
                and    y.nroempresadf = a.nroempresa
                and    y.seqproduto   = b.seqproduto
                and    y.qtdembalagem = nvl( b.qtdembalagem, y.qtdembalagem ) )
          else
              null
          end nrotabvenda,
/*2.102*/ a.seqnf,
/*2.103*/ nvl( b.vlrverbacompra, 0 ) vlrverbacompra,
/*2.104*/ nvl( b.vlrverbabonifincid, 0 ) vlrverbabonifincid,
/*2.105*/ nvl( b.vlrverbabonifsemincid, 0 ) vlrverbabonifsemincid,
/*2.106*/ 0 vlrverbacompradev,
/*2.107*/ 0 vlrverbabonifinciddev,
/*2.108*/ 0 vlrverbabonifseminciddev,
/*2.109*/ nvl( b.seqprodutofinal, b.seqproduto ) seqprodutofinal,
/*2.110*/ nvl( b.quantidadeprodfinal, b.quantidade ) qtditemprodfinal,
/*2.111*/ 0 qtditemdevprodfinal,
/*2.112*/ m.cmultvlrdespfixa,
/*2.113*/ m.cmultvlrdescfixo,
/*2.114*/ b.vlrdescverbatransf,
/*2.115*/ b.vlrdesclucrotransf,
/*2.116*/ null dtanfref,
/*2.117*/ nvl( b.vlrverbavda,0 ) vlrverbavda,
/*2.118*/ nvl( b.qtdverbavda,0 ) qtdverbavda,
/*2.119*/ 0 vlrverbavdadevol,
/*2.120*/ 0 qtdverbavdadevol,
/*2.121*/ b.seqpromocao,
/*2.122*/ nvl( b.qtdverbapdv, 0 ) qtdverbapdv,
/*2.123*/ nvl( b.vlrverbapdv, 0 ) vlrverbapdv,
/*2.124*/ 0 qtdverbapdvdevol,
/*2.125*/ 0 vlrverbapdvdevol,
/*2.126*/ nvl( b.vlrpiscofinsverbapdv, 0 ) vlrpiscofinsverbapdv,
/*2.127*/ 0 vlrpiscofinsverbapdvdevol,
/*2.128*/ nvl( b.vlrdescmedalha, 0 ),
/*2.129*/ m.vlrgmroi,
/*2.130*/ m.indposicaocateg,
/*2.131*/ nvl( b.vlrdescfornec, 0 ) vlrdescfornec,
/*2.132*/ 0 vlrdescfornecdevol,
/*2.133*/ b.tipopromocpdv,
/*2.134*/ nvl( b.vlrfreteitemrateio, 0 ) vlrfreteitemrateio,
/*2.135*/ 0 vlrfreteitemrateiodev,
/*2.136*/ nvl( b.vlricmsstembutprod,0 ) vlricmsstembutprod,
/*2.137*/ 0 vlricmsstembutproddev,
/*2.138*/ b.seqcluster,
/*2.139*/ nvl( b.nfreferencianro, a.nfreferencianro ) nfreferencianro,
/*2.140*/ nvl( b.nfreferenciaserie, a.nfreferenciaserie ) nfreferenciaserie,
/*2.141*/ nvl( b.indpromocao, 'N' ) indpromocao,
/*2.142*/ case when pd3.valor = 'S'
                    and ( pd4.valor = 'S' or b.tipopromocpdv in ( 'A', 'L' ) )
                    and nvl( b.vlrverbapdv, 0 ) > 0 then
                                 nvl( b.vlrverbapdv, 0 )
               when b.tipopromocpdv = 'L'
                    and b.seqpromocpdv > 0
                    and pd5.valor = 'S'
                    and b.seqregraincentivo is null
                    and nvl( pdv.indcontrolaverbapdv, 'N' ) = 'S' then
                                 b.vlrdesconto
          else
            0
          end vlrdescacordoverbapdv,
/*2.143*/ b.vlrdifcampanhapreco,
/*2.144*/ 0 vlrdifcampanhaprecodevol,
/*2.145*/ b.vlrcustonfprecocamp,
/*2.146*/ b.seqcampanha,
/*2.147*/ b.vlrprecomargemzero,
/*2.148*/ b.qtddotznormal,
/*2.149*/ b.vlrvendadotznormal,
/*2.150*/ b.qtddotzextra,
/*2.151*/ b.vlrvendadotzextra,
/*2.152*/ b.qtddotztotal,
/*2.153*/ b.vlrvendadotztotal,
/*2.154*/ a.seqzonavenda,
/*2.155*/ nvl( b.vlrdesccomercial, 0 ) vlrdesccomercial,
/*2.156*/ nvl( a.grupocliente, pe.grupo ) grupocliente,
/*2.157*/ b.vlritemrateiocte,
/*2.158*/ a.ctenro,
/*2.159*/ a.cteserie,
/*2.160*/ nvl( b.vlrverbavdasemicus, 0 ) vlrverbavdasemicus,
/*2.161*/ nvl(b.vlrfcpst, 0) vlrfcpst,
/*2.162*/ nvl(b.vlrfcpicms, 0) vlrfcpicms,
/*2.163*/ nvl(b.vlrfcpdistrib, 0) vlrfcpdistrib,
/*2.164*/ nvl(b.vlrfcpstsubst, 0) vlrfcpstsubst,
/*2.165*/ 0 dvlrfcpst,
/*2.166*/ 0 dvlrfcpicms,
/*2.167*/ 0 dvlrfcpdistrib,
/*2.168*/ 0 dvlrfcpstsubst,
/*2.169*/ nvl(b.vlricmsefet, 0) icmsefetivoitem,
/*2.170*/ 0 icmsefetivodevolitem,
/*2.171*/ pe.indcontribicms,
/*2.172*/ pe.fisicajuridica,
/*2.173*/ nvl(d.indconsumidorfinal, 'N'),
/*2.174*/ d.tipdocfiscal tipdocfiscalcgo,
/*2.175*/ a.nropedidovenda nropedidovenda,
/*2.176*/ d.tipcgo tipcgo,
/*2.177*/ nvl(b.vlripiprecovda, 0) vlripiprecovda,
/*2.178*/ 0 vlripiprecodevol,
/*2.179*/ 0 vlrdescmedalhadevol
/* Quando implementar nova coluna, tratar tambem na view "MAXV_ABCFORMAPAGTO". Manter comentario apos a ultima coluna. */
from   mfl_doctofiscal   a,
       mfl_dfitem        b,
       max_codgeraloper  d,
       max_empresa       e,
       mad_segmento      s,
       mad_parametro     x,
       /*(SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4') NROEMPRESA, NVL(fc5maxparametro('PED_VENDA', NROEMPRESA, 'EXIG_TELEVENDAS_PEDIDO'), 'N') VALOR
          FROM MAX_EMPRESA) PD,*/
       mrl_produtoempresa m,
       ge_pessoa         pe,
       ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl(max(X.VALOR), 'N') VALOR
         from   MAX_PARAMETRO X
         where  X.NROEMPRESA = 0
         and    X.GRUPO = 'ABC_DISTRIB'
         and    X.PARAMETRO = 'EXIBE_VDA_EQUIPE_ATUAL_REP' ) PD1,
       ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl(max(X.VALOR), 'N') VALOR
         from   MAX_PARAMETRO X
         where  X.NROEMPRESA(+) = 0
         and    X.GRUPO(+) = 'ABC_DISTRIB'
         and    X.PARAMETRO(+) = 'UTIL_DETALHE_TABELA_VENDA' ) PD2,
       ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl(max(X.VALOR), 'N') VALOR
         from   MAX_PARAMETRO X
         where  X.NROEMPRESA(+) = 0
         and    X.GRUPO(+) = 'ACORDO_EST_PDV'
         and    X.PARAMETRO(+) = 'UTIL_NOVO_CALC_APURACAO' ) PD3,
       ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl(max(X.VALOR), 'N') VALOR
         from   MAX_PARAMETRO X
         where  X.NROEMPRESA(+) = 0
         and    X.GRUPO(+) = 'ACORDO_EST_PDV'
         and    X.PARAMETRO(+) = 'VISUALIZA_TODAS_PROMOCOES' ) PD4,
       ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl(max(X.VALOR), 'N') VALOR
         from   MAX_PARAMETRO X
         where  X.NROEMPRESA(+) = 0
         and    X.GRUPO(+) = 'ABC_DISTRIB'
         and    X.PARAMETRO(+) = 'SUBTRAI_DESC_ACORDO_VERBA_PDV' ) PD5,
       ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl(max(X.VALOR), 'T') VALOR
         from   MAX_PARAMETRO X
         where  X.NROEMPRESA(+) = 0
         and    X.GRUPO(+) = 'ABC_DISTRIB'
         and    X.PARAMETRO(+) = 'TIPO_REPRESENTANTE_NULO_ITEM' ) PD6,
       ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ NVL(MAX(X.VALOR), 'N') VALOR
          FROM MAX_PARAMETRO X
         WHERE X.NROEMPRESA = 0
           AND X.GRUPO = 'ABC_DISTRIB'
           AND X.PARAMETRO = 'CONSID_ICMS_PRESUMIDO' ) PD7,
       max_divisao v,
       max_paramgeral pg,
       mfl_promocaopdv pdv
where a.numerodf        = b.numerodf
and   a.seriedf         = b.seriedf
and   a.nroserieecf     = b.nroserieecf
and   a.nroempresa      = b.nroempresa
and   nvl(a.seqnf, 0)   = nvl(b.seqnf, nvl(a.seqnf, 0))
and   a.codgeraloper    = d.codgeraloper
and   a.nroempresa      = e.nroempresa
and   s.nrosegmento     = nvl( nvl( b.nrosegitem, a.nrosegmento ), e.nrosegmentoprinc )
and   x.nroempresa      = a.nroempresa
and   m.seqproduto      = nvl( b.seqprodutobase, b.seqproduto )
and   m.nroempresa      = nvl( e.nroempcustoabc, e.nroempresa )
and   a.statusdf        = 'V'
and   b.statusitem      = 'V'
and   d.tipcgo          = 'S'
and   b.quantidade      != 0
/*req 45446*/
and   nvl( b.indtipodescbonif, 'I' ) != 'T'
and   ( coalesce (a.geralteracaoestq, d.geralteracaoestq ) = 'S'
        or d.acmcompravenda in ( 'S', 'I' ) )
and   a.seqpessoa       = pe.seqpessoa
and   e.nrodivisao      = v.nrodivisao
and   b.seqpromocpdv    = pdv.seqpromocpdv(+)
AND dtahoremissao >= SYSDATE - 150
AND EXISTS (SELECT 1 FROM CONSINCO.NAGT_DEPARA_VESTRH ZZ WHERE ZZ.SEQPRODUTO = B.SEQPRODUTO)
AND A.CODGERALOPER IN (60,923,914,64,102,949,210,57,948,10,941,1,927,211,814,802,801,944,811,850,942,95,261,931,240)


union all
-- DEVOLUCOES DE VENDAS (COM NF DE REFERENCIA)
SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ distinct
/*3.000*/ 3 idsql,
/*3.001*/ nvl( a.dtahorlancto, a.dtaentrada ) dtahorlancto,
/*3.002*/ a.dtaentrada dtavda,
/*3.003*/ a.nroempresa,
/*3.004*/ a.numeronf nrodocto,
/*3.005*/ a.serienf seriedocto,
/*3.006*/ a.seqpessoa,
/*3.007*/ nvl( a.enderecoentrega, 0 ) seqpessoaend,
/*3.008*/ a.versaopessoa,
/*3.009*/ coalesce( c.codoperador, ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ min( g.codusuario )
                                     from ge_usuario g
                                     where g.sequsuario = c.seqoperador ) ) operador,
/*3.010*/ case when c.codoperador is not null then
            ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ min( g.sequsuario )
                from ge_usuario g
               where g.codusuario = c.codoperador )
          else
            c.seqoperador
          end seqoperador,
/*3.011*/ 0 checkout,
/*3.012*/ b.seqproduto,
/*3.013*/ nvl( b.seqprodutobase, b.seqproduto ) seqprodutocusto,
/*3.014*/ b.seqitemnf seqitem,
/*3.015*/ b.qtdembalagem qtdembalitem,
/*3.016*/ 0 qtditem,
/*3.017*/ b.quantidade qtddevolitem,
/*3.018*/ 0 vlritem,
/*3.019*/ 0 vlripiitem,
/*3.020*/ 0 vlrdesconto,
/*3.021*/ 0 vlracrescimo,
/*3.022*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrdescitem, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
            + nvl( b.vlricmsst, 0 )
            + nvl( b.vlrfcpst, 0 )
          ) vlrdevolitem,
/*3.023*/ nvl( b.vlripi, 0 ) vlripidevolitem,
/*3.024*/ 0 icmsitem,
/*3.025*/ case when ( ( substr(b.situacaonf, -2) = '90' or b.tipocalcicmsfisci = 26 ) and e.uf = 'CE' ) then
            0
          else
            decode( coalesce( decode( pg.indutilicmstaresugprabc, 'S', ( t.vlricmssolicit / t.quantidade ) * b.quantidade, null ),
                           b.vlricmscalc,
                           b.bascalcicms * b.peraliquotaicms / 100,
                           0 ),
                  0,
                  nvl( b.vlricmsvpe, 0 ),
                  coalesce( decode( pg.indutilicmstaresugprabc, 'S', ( t.vlricmssolicit / t.quantidade) * b.quantidade, null ),
                            b.vlricmscalc,
                            b.bascalcicms * b.peraliquotaicms / 100,
                            0 )
            )
            -
            ( case when b.tipocalcicmsfisci = 25 then
                  round( ( b.bascalcicms * b.peraliquotaicms / 100 * nvl( b.peraliqicmsdif, 0 ) / 100 ), 2 )
              else
                  0
              end
            ) end
          icmsdevolitem,
/*3.026*/ 0 pisitem,
/*3.027*/ nvl( b.vlrpis, 0 ) pisdevolitem,
/*3.028*/ 0 cofinsitem,
/*3.029*/ nvl( b.vlrcofins, 0 ),
/*3.030*/ 0 vlrrestornoitem,
/*3.031*/ 0 vlrrestornodevolitem,
/*3.032*/ 0 issitem,
/*3.033*/ nvl( b.vlrtotiss, 0 ) issdevolitem,
/*3.034*/ 'NFE' tipdocto,
/*3.035*/ nvl( b.nrorepresentante, nvl( c.seqvendedor, nvl( x.nroreppadrao, 0 ) ) ) nrorepresentante,
/*3.036*/ decode( nvl( c.seqvendedor, nvl( b.nrorepresentante, nvl( x.nroreppadrao, 0 ) ) ), 0,
                    nvl( b.nrosegitem, e.nrosegmentoprinc ),
                    nvl( b.nrosegitem, ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( max( r.nrosegmento ), e.nrosegmentoprinc )
                                         from mad_representante r
                                         where r.nrorepresentante = nvl( c.seqvendedor, nvl( b.nrorepresentante, nvl( x.nroreppadrao, 0 ) ) ) )
                    )
          ) nrosegmento,
/*3.037*/ nvl( c.nroformapagto, x.formapagtopadrao ) nroformapagto,
/*3.038*/ a.dtaentrada + ( c.dtavencimento - c.dtamovimento ) dtavencimento,
/*3.039*/ c.prazomediovencto nrodiasprazomedio,
/*3.040*/ f.acmcompravenda,
/*3.041*/ e.perpis,
/*3.042*/ e.percofins,
/*3.043*/ e.percpmf,
/*3.044*/ e.perir,
/*3.045*/ e.pericmsestimativa,
/*3.046*/ e.peroutroimposto,
/*3.047*/ 0 vlrtotcomissaoitem,
/*3.048*/ coalesce( b.vlrtotcomissao, fvlrcomissaodfitem( c.numerodf, c.seriedf, c.seqpessoa, b.seqproduto, b.quantidade ) ) vlrtotcomissaoitemdevol,
/*3.049*/ c.nrocarga,
/*3.050*/ c.nrocondicaopagto,
/*3.051*/ a.codgeraloper,
/*3.052*/ nvl( c.origempedido, 'R' ) origempedido,
/*3.053*/ s.indprecoembalagem,
/*3.054*/ rowidtochar( a.rowid ) rowiddocto,
/*3.055*/ to_number( null ) seqprodutovda,
/*3.056*/ b.seqproduto seqprodutodevol,
/*3.057*/ to_number( null ) seqpessoavda,
/*3.058*/ a.seqpessoa seqpessoadevol,
/*3.059*/ null rowiddoctovda,
/*3.060*/ rowidtochar( a.rowid ) rowiddoctodevol,
/*3.061*/ b.seqloteestoque,
/*3.062*/ to_number( null ) seqpromocpdv,
/*3.063*/ b.classifabcfamseg classifabcfamseg,
/*3.064*/ 0 vlrdescforanf,
/*3.065*/ nvl( b.ocorrenciadevitem, a.ocorrenciadev ) ocorrenciadev,
/*3.066*/ ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( max( z.descricao ), '*** N?O ENCONTRADO: ' || nvl( b.ocorrenciadevitem, a.ocorrenciadev ) || ' ***' )
            from max_atributofixo  z
            where z.tipatributofixo = 'OCORRENCIA DEVOL'
            and z.lista = nvl( b.ocorrenciadevitem, a.ocorrenciadev )
          ) descocorrenciadev,
/*3.067*/ to_number( null ) vlrdespoperacionalitem,
/*3.068*/ nvl( b.vlrdespoperacionalitem, 0 ) vlrdespoperacionalitemdevol,
/*3.069*/ 0 vlritemsemst,
/*3.070*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrdescitem, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
          ) vlrdevolitemsemst,
/*3.071*/ 0 vlricmsst,
/*3.072*/ nvl( b.vlricmsst, 0 ) vlrdevolicmsst,
/*3.073*/ 0 vlrfrete,
/*3.074*/ null nroserieecf,
/*3.075*/ 'R' tiptabela,
/*3.076*/ d.acmcompravenda cgoacmcompravenda,
/*3.077*/ a.seqauxnotafiscal,
/*3.078*/ 0 vlritemsemdesc,
/*3.079*/ 0 vlrdescitem,
/*3.080*/ b.vlritem
          + nvl( b.vlrdescsf, 0 )
          - nvl( b.vlrfunruralitem, 0 )
          + case when a.indconsidfretedesptrib = 'N' then
                 nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
            else
                 nvl( b.vlrdesptributitem, 0 )
            end
          + nvl( b.vlrdespntributitem, 0 )
          - nvl( b.vlrdescsuframa, 0 )
          + nvl( b.vlripi, 0 )
          + nvl( b.vlricmsst, 0 )
          + nvl( b.vlrfcpst, 0 )
          vlrdevolitemsemdesc,
/*3.081*/ b.vlrdescitem vlrdescdevolitem,
/*3.082*/ ( b.vlrtotcomissaotele * -1 ) vlrtotcomissaotele,
/*3.083*/ ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ max( x.nrotelevenda )
              from mad_pedvendaitem y, mad_pedvenda x
             where y.nropedvenda  = x.nropedvenda
               and y.nroempresa   = x.nroempresa
               and y.numerodf     = c.numerodf
               and y.seriedf      = c.seriedf
               and y.nroempresadf = a.nroempresa
               and y.seqproduto   = b.seqproduto
               and y.qtdembalagem = nvl( b.qtdembalagem,y.qtdembalagem ) ) nrotelevenda,
              /*fnrotelevendaped(a.numerodf, a.seriedf, a.nroempresa, b.seqproduto, b.qtdembalagem) */
              /*essa func?o nao pode ser removida devido aos problemas do rc 69429*/
/*3.084*/ b.vlrcompror,
/*3.085*/ 0 vlrembdescressarcst,
/*3.086*/ nvl( b.vlrembdescressarcst, 0 ) vlrembdescressarcstdevol,
/*3.087*/ a.nropromotor,
/*3.088*/ a.tipnotafiscal,
/*3.089*/ t.vlricmsstemporig,
/*3.090*/ t.vlrcustobrutoemporig,
/*3.091*/ nvl( b.vlrfreteabc, 0 ) vlrfreteabc,
/*3.091*/ e.nrodivisao,
/*3.093*/ decode( pd2.valor, 'S', null, nvl( t.nroequiperepitemdtamovto, c.nroequiperepdtamovto ) ) nroequipe,
/*3.094*/ case when nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) < 0 then
               0
          else
              nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 )
          end custofiscalunit,
/*3.095*/ case when ( nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) ) * nvl( m.estqempresa, 0 ) < 0 then
               0
          else
               ( nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) ) * nvl( m.estqempresa, 0 )
          end custofiscaltotal,
/*3.096*/ pe.uf ufpessoa,
/*3.097*/ c.codareageograficavda,
/*3.098*/ c.codsubareageograficavda,
  --rc 132583 - verifica se a nota de referencia estava com o item em promoc?o para que seja verificado corretamente.
/*3.099*/ decode( ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ max( pr.indpromocao )
                    from mfl_dfitem pr
                    where nvl( pr.seqnf, nvl( c.seqnf,0 ) ) = nvl( b.seqnfref, nvl( t.seqnf, nvl( c.seqnf,0 ) ) )
                    and pr.numerodf    = c.numerodf
                    and pr.seriedf     = c.seriedf
                    and pr.nroempresa  = c.nroempresa
                    and pr.nroserieecf = c.nroserieecf
                    and pr.seqproduto  = b.seqproduto ),
                'S', b.vlritem,
                'N', 0,
                null, null )
          vlrvendapromoc,
/*3.100*/ a.seqtransportador,
/*3.101*/ case when pd1.valor = 'S' then
                 ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ max( nvl( y.nrotabvenda, x.nrotabvenda ) )
                   from mad_pedvendaitem y, mad_pedvenda x
                   where y.nropedvenda = x.nropedvenda
                   and y.nroempresa    = x.nroempresa
                   and y.numerodf      = c.numerodf
                   and y.seriedf       = c.seriedf
                   and y.nroempresadf  = a.nroempresa
                   and y.seqproduto    = b.seqproduto
                   and y.qtdembalagem  = nvl( b.qtdembalagem, y.qtdembalagem ) )
          else
             null
          end nrotabvenda,
/*3.102*/ a.seqnf,
/*3.103*/ 0 vlrverbacompra,
/*3.104*/ 0 vlrverbabonifincid,
/*3.105*/ 0 vlrverbabonifsemincid,
/*3.106*/ nvl( b.vlrverbacompra, 0 ) vlrverbacompradev,
/*3.107*/ nvl( b.vlrverbabonifincid, 0 ) vlrverbabonifinciddev,
/*3.108*/ nvl( b.vlrverbabonifsemincid, 0 ) vlrverbabonifseminciddev,
/*3.109*/ nvl( b.seqprodutofinal, b.seqproduto ) seqprodutofinal,
/*3.110*/ 0 qtditemprodfinal,
/*3.111*/ nvl( b.quantidadeprodfinal, b.quantidade ) qtditemdevprodfinal,
/*3.112*/ m.cmultvlrdespfixa,
/*3.113*/ m.cmultvlrdescfixo,
/*3.114*/ b.vlrdescverbatransf,
/*3.115*/ b.vlrdesclucrotransf,
/*3.116*/ c.dtamovimento dtanfref,
/*3.117*/ 0 vlrverbavda,
/*3.118*/ 0 qtdverbavda,
/*3.119*/ nvl( b.vlrverbavda, 0 ) vlrverbavdadevol,
/*3.120*/ nvl( b.qtdverbavda, 0 ) qtdverbavdadevol,
/*3.121*/ null seqpromocao,
/*3.122*/ 0 qtdverbapdv,
/*3.123*/ 0 vlrverbapdv,
/*3.124*/ nvl( b.qtdverbapdv, 0 ) qtdverbapdvdevol,
/*3.125*/ nvl( b.vlrverbapdv, 0 ) vlrverbapdvdevol,
/*3.126*/ 0 vlrpiscofinsverbapdv,
/*3.127*/ nvl( b.vlrpiscofinsverbapdv, 0 ) vlrpiscofinsverbapdvdevol,
/*3.128*/ 0 vlrdescmedalha,
/*3.129*/ m.vlrgmroi,
/*3.130*/ m.indposicaocateg,
/*3.131*/ 0 vlrdescfornec,
/*3.132*/ nvl( b.vlrdescfornec, 0 ) vlrdescfornecdevol,
/*3.133*/ null tipopromocpdv,
/*3.134*/ 0 vlrfreteitemrateio,
/*3.135*/ nvl( b.vlrfreteitemrateio, 0 ) vlrfreteitemrateiodev,
/*3.136*/ 0 vlricmsstembutprod,
/*3.137*/ nvl( b.vlricmsstembutprod, 0 ) vlricmsstembutproddev,
/*3.138*/ b.seqcluster,
/*3.139*/ nvl( b.nfreferencianro, a.nfreferencianro ) nfreferencianro,
/*3.140*/ nvl( b.nfreferenciaserie, a.nfreferenciaserie ) nfreferenciaserie,
/*3.141*/ 'N' indpromocao,
/*3.142*/ 0 vlrdescacordoverbapdv,
/*3.143*/ 0 vlrdifcampanhapreco,
/*3.144*/ t.vlrdifcampanhapreco * ( nvl( b.quantidadeprodfinal, b.quantidade ) / t.quantidade ) vlrdifcampanhaprecodevol,
/*3.145*/ t.vlrcustonfprecocamp vlrcustonfprecocamp,
/*3.146*/ t.seqcampanha,
/*3.147*/ b.vlrprecomargemzero,
/*3.148*/ 0 qtddotznormal,
/*3.149*/ 0 vlrvendadotznormal,
/*3.150*/ 0 qtddotzextra,
/*3.151*/ 0 vlrvendadotzextra,
/*3.152*/ 0 qtddotztotal,
/*3.153*/ 0 vlrvendadotztotal,
/*3.154*/ 0 seqzonavenda,
/*3.155*/ -- nvl( t.vlrdesccomercial, 0 ) vlrdesccomercial,
/*3.155*/ (SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ sum( nvl( t1.vlrdesccomercial, 0 ) ) / sum( t1.quantidade )
                  from mfl_dfitem t1
                  where t.numerodf = t1.Numerodf
                   and t.nroempresa = t1.nroempresa
                   and t.seriedf = t1.seriedf
                   and t.seqproduto = t1.seqproduto
                   and t.nroserieecf = t1.nroserieecf
                   ) * b.quantidade * -1 vlrdesccomercial,
/*3.156*/ nvl( c.grupocliente, pe.grupo ) grupocliente,
/*3.157*/ 0 vlritemrateiocte,
/*3.158*/ null ctenro,
/*3.159*/ null cteserie,
/*3.160*/ 0 vlrverbavdasemicus,
/*3.161*/ 0 vlrfcpst,
/*3.162*/ 0 vlrfcpicms,
/*3.163*/ 0 vlrfcpdistrib,
/*3.164*/ 0 vlrfcpstsubst,
/*3.165*/ nvl(b.vlrfcpst, 0) dvlrfcpst,
/*3.166*/ nvl(b.vlrfcpicms, 0) dvlrfcpicms,
/*3.167*/ nvl(b.vlrfcpdistrib, 0) dvlrfcpdistrib,
/*3.168*/ nvl(b.vlrfcpstsubst, 0) dvlrfcpstsubst,
/*3.169*/ 0 icmsefetivoitem,
/*3.170*/ nvl(b.vlricmsefet, 0) icmsefetivodevolitem,
/*3.171*/ pe.indcontribicms,
/*3.172*/ pe.fisicajuridica,
/*3.173*/ nvl(d.indconsumidorfinal, 'N'),
/*3.174*/ d.tipdocfiscal tipdocfiscalcgo,
/*3.175*/ c.nropedidovenda nropedidovenda,
/*3.176*/ d.tipcgo tipcgo,
/*3.177*/ 0 vlripiprecovda,
/*3.178*/ nvl(t.vlripiprecovda, 0) vlripiprecodevol,
/*3.179*/ nvl(b.vlrdescmedalha, 0) vlrdescmedalhadevol
/* quando implementar nova coluna, tratar tambem na view "maxv_abcformapagto". manter comentario apos a ultima coluna. */
from mlf_notafiscal     a,
     mlf_nfitem         b,
     -- mfl_doctofiscal substituida - req 63038 -- voltou a ser como antes no rc 71668, com adic?o da coluna seqnf no where
     mfl_doctofiscal    c,
     /*(
     table(fc_ret_doctofiscal_dev( nvl(b.nfreferencianro, a.nfreferencianro),
                                   nvl(b.nfreferenciaserie, a.nfreferenciaserie),
                                   a.nroempresa))
     )  c,*/
     /*o tratamento acima foi comentado devido a problemas de performance do rc 69755, porem ja existe um rc na versao 65635 para
     corrigir este problema.*/
     max_codgeraloper   d,
     max_empresa        e,
     max_empresa        er,
     max_codgeraloper   f,
     mad_segmento       s,
     mad_parametro      x,
     mfl_dfitem         t,
     mrl_produtoempresa m,
     ge_pessoa          pe,
     ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl(x.valor, 'N') valor
         from max_parametro x
        where x.nroempresa(+) = 0
          and x.grupo(+) = 'ABC_DISTRIB'
          and x.parametro(+) = 'UTIL_DETALHE_TABELA_VENDA' ) pd1,
      ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl(max(x.valor), 'N') valor
          from max_parametro x
         where x.nroempresa = 0
           and x.grupo = 'ABC_DISTRIB'
           and x.parametro = 'EXIBE_VDA_EQUIPE_ATUAL_REP' ) pd2,
      ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl(max(x.valor), 'S') valor
           from max_parametro x
          where x.nroempresa = 0
            and x.grupo = 'ABC_DISTRIB'
            and x.parametro = 'COMPARA_EMB_DEVOL') pd3,
    max_divisao         v,
    max_paramgeral      pg
where b.numeronf         = a.numeronf
and   b.seqpessoa        = a.seqpessoa
and   b.serienf          = a.serienf
and   b.tipnotafiscal    = a.tipnotafiscal
and   b.nroempresa       = a.nroempresa
and   nvl( a.seqnf, 0 )  = nvl( b.seqnf, nvl( a.seqnf, 0 ) )
and   nvl( t.seqnf, nvl( c.seqnf,0 ) ) = nvl( b.seqnfref, nvl( t.seqnf, nvl( c.seqnf, 0 ) ) )
and   t.numerodf   =     c.numerodf
and   t.seriedf    =     c.seriedf
and   t.nroempresa =     c.nroempresa
and   t.nroserieecf =    c.nroserieecf
and   t.seqproduto =     b.seqproduto
--- jota - RC 195070 tarefa 22330
and T.STATUSITEM = 'V'
and ( ( pd3.valor = 'S' and t.qtdembalagem = b.qtdembalagem ) or ( PD3.VALOR = 'N') )
--- RC 201518 -- AND t.Qtdembalagem = b.Qtdembalagem
--- fim - RC 195070 tarefa 22330
and   nvl( t.nroequiperepitemdtamovto,0 ) = coalesce( b.nroequiperepitemdtamovto, t.nroequiperepitemdtamovto, 0 )
/*rc 13517*/
/*and    nvl(c.nrocheckout,1) =    nvl(b.nrocheckout,nvl(c.nrocheckout,1)) */
and   c.numerodf         = nvl( b.nfreferencianro, a.nfreferencianro )
and   c.seriedf          = nvl( b.nfreferenciaserie, a.nfreferenciaserie )
and   a.codgeraloper     = d.codgeraloper
and   a.nroempresa       = e.nroempresa
and   c.nroempresa       = er.nroempresa
and   (
      (a.numeronf = nvl( b.nfreferencianro, a.nfreferencianro ) and
       a.serienf = nvl( b.nfreferenciaserie, a.nfreferenciaserie ) and
       a.seqpessoa = er.seqpessoaemp)
   or ((a.numeronf != nvl( b.nfreferencianro, a.nfreferencianro ) or
        a.serienf != nvl( b.nfreferenciaserie, a.nfreferenciaserie )) and
       c.nroempresa  = a.nroempresa)
      )
and   f.codgeraloper     = c.codgeraloper
and   s.nrosegmento      = nvl( nvl( b.nrosegitem, a.nrosegmento ), e.nrosegmentoprinc )
and   x.nroempresa       = e.nroempresa
and   m.seqproduto       = nvl( b.seqprodutobase, b.seqproduto )
and   m.nroempresa       = nvl( e.nroempcustoabc, e.nroempresa )
and   a.tipnotafiscal    = 'E'
and   b.tipitem          = 'R'
/* rc 144980 and    d.exgrefdevolucao != 'N'  */
and   d.tipcgo           = 'E'
and   d.tipdocfiscal     != 'C'
--and    c.nroserieecf      = 'NF'
and   b.quantidade      != 0
and   a.statusnf         = 'V'
and   nvl( x.utilrefdoctodevol, 'S' ) in ( 'S', 'A' )
/*and    (f.geralteracaoestq = 'S' or f.acmcompravenda in ('S', 'I'))*/
and   ( coalesce( a.geralteracaoestq, d.geralteracaoestq ) = 'S'
        or d.acmcompravenda in ( 'S', 'I' ) )
and   a.seqpessoa         = pe.seqpessoa
and   e.nrodivisao        = v.nrodivisao
and   nvl( b.indtipodescbonif, 'I') != 'T'
and   ( d.indgeracargarecebcanc != 'S' or d.indgeracargarecebcanc is null )
and   nvl( d.indnfrefprodrural, 'N' ) != 'S'
AND nvl( a.dtahorlancto, a.dtaentrada ) >= SYSDATE - 150
AND EXISTS (SELECT 1 FROM CONSINCO.NAGT_DEPARA_VESTRH ZZ WHERE ZZ.SEQPRODUTO = B.SEQPRODUTO)
AND A.CODGERALOPER IN (60,923,914,64,102,949,210,57,948,10,941,1,927,211,814,802,801,944,811,850,942,95,261,931,240)


/*rp 59104 - comentado and    c.nroserieecf      = 'NF' */
union all
-- DEVOLUCOES DE VENDAS (BASEANO APENAS NO TIPO DE DOCTO DO CGO, IGONORANDO SE TEM OU NAO REFERENCIA)
select
/*4.000*/ 4 idsql,
/*4.001*/ nvl( a.dtahorlancto, a.dtaentrada ) dtahorlancto,
/*4.002*/ a.dtaentrada dtavda,
/*4.003*/ a.nroempresa,
/*4.004*/ a.numeronf nrodocto,
/*4.005*/ a.serienf seriedocto,
/*4.006*/ a.seqpessoa,
/*4.007*/ nvl( a.enderecoentrega, 0 ) seqpessoaend,
/*4.008*/ a.versaopessoa,
/*4.009*/ a.usulancto operador,
/*4.010*/ ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( min( g.sequsuario ), 0 )
            from ge_usuario g
            where g.codusuario = a.usulancto ) seqoperador,
/*4.011*/ 0 checkout,
/*4.012*/ b.seqproduto,
/*4.013*/ nvl( b.seqprodutobase, b.seqproduto ) seqprodutocusto,
/*4.014*/ b.seqitemnf seqitem,
/*4.015*/ b.qtdembalagem qtdembalitem,
/*4.016*/ 0 qtditem,
/*4.017*/ b.quantidade qtddevolitem,
/*4.018*/ 0 vlritem,
/*4.019*/ 0 vlripiitem,
/*4.020*/ 0 vlrdesconto,
/*4.021*/ 0 vlracrescimo,
/*4.022*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrdescitem, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
            + nvl( b.vlricmsst, 0 )
            + nvl( b.vlrfcpst, 0 )
          ) vlrdevolitem,
/*4.023*/ nvl( b.vlripi, 0 ) vlripidevolitem,
/*4.024*/ 0 icmsitem,
/*4.025*/ case when ( ( substr(b.situacaonf, -2) = '90' or b.tipocalcicmsfisci = 26 ) and e.uf = 'CE' ) then
             0
          else
            round( decode( nvl( nvl( b.vlricmscalc, b.bascalcicms * b.peraliquotaicms / 100 ), 0 ),
                      0, nvl( b.vlricmsvpe, 0 ),
                      nvl( b.vlricmscalc, b.bascalcicms * b.peraliquotaicms / 100 )
            ), 2 )
            -
            ( case when b.tipocalcicmsfisci = 25 then
                  round( ( b.bascalcicms * b.peraliquotaicms / 100 * nvl( b.peraliqicmsdif, 0 ) / 100 ), 2 )
              else
                  0
              end
            ) end
            icmsdevolitem,
/*4.026*/ 0 pisitem,
/*4.027*/ nvl( b.vlrpis, 0 ) pisdevolitem,
/*4.028*/ 0 cofinsitem,
/*4.029*/ nvl( b.vlrcofins, 0 ) cofinsdevolitem,
/*4.030*/ 0 vlrrestornoitem,
/*4.031*/ 0 vlrrestornodevolitem,
/*4.032*/ 0 issitem,
/*4.033*/ nvl( b.vlrtotiss, 0 ) issdevolitem,
/*4.034*/ 'NFE' tipdocto,
/*4.035*/ nvl( b.nrorepresentante, nvl( x.nroreppadrao, 0 ) ) nrorepresentante,
/*4.036*/ decode( nvl( b.nrorepresentante, nvl( x.nroreppadrao, 0 ) ),
                    0, nvl( b.nrosegitem, e.nrosegmentoprinc ),
                    nvl( b.nrosegitem, ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( max( r.nrosegmento ), e.nrosegmentoprinc )
                                         from mad_representante r
                                         where r.nrorepresentante = nvl( b.nrorepresentante, nvl( x.nroreppadrao, 0 ) ) ) )
          ) nrosegmento,
/*4.037*/ nvl( a.nroformapagto, x.formapagtopadrao ) nroformapagto,
/*4.038*/ a.dtaentrada dtavencimento,
/*4.039*/ a.pzomediopagamento nrodiasprazomedio,
/*4.040*/ 'S' acmcompravenda,
/*4.041*/ e.perpis,
/*4.042*/ e.percofins,
/*4.043*/ e.percpmf,
/*4.044*/ e.perir,
/*4.045*/ e.pericmsestimativa,
/*4.046*/ e.peroutroimposto,
/*4.047*/ 0 vlrtotcomissaoitem,
/*4.048*/ nvl( b.vlrtotcomissao, 0 ) vlrtotcomissaoitemdevol,
/*4.049*/ to_number( null ) nrocarga,
/*4.050*/ to_number( null ) nrocondicaopagto,
/*4.051*/ a.codgeraloper,
/*4.052*/ 'R' origempedido,
/*4.053*/ s.indprecoembalagem,
/*4.054*/ rowidtochar( a.rowid ) rowiddocto,
/*4.055*/ to_number( null ) seqprodutovda,
/*4.056*/ b.seqproduto seqprodutodevol,
/*4.057*/ to_number( null ) seqpessoavda,
/*4.058*/ a.seqpessoa seqpessoadevol,
/*4.059*/ null rowiddoctovda,
/*4.060*/ rowidtochar( a.rowid ) rowiddoctodevol,
/*4.061*/ b.seqloteestoque seqloteestoque,
/*4.062*/ to_number( null ) seqpromocpdv,
/*4.063*/ b.classifabcfamseg,
/*4.064*/ 0 vlrdescforanf,
/*4.065*/ nvl(B.OCORRENCIADEVITEM,A.OCORRENCIADEV ) ocorrenciadev,
/*4.066*/ ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( max( z.descricao ), '*** N?O ENCONTRADO: ' || nvl( b.ocorrenciadevitem, a.ocorrenciadev ) || ' ***' )
            from max_atributofixo z
            where z.tipatributofixo = 'OCORRENCIA DEVOL'
            and z.lista = nvl( b.ocorrenciadevitem, a.ocorrenciadev )
          ) descocorrenciadev,
/*4.067*/ to_number( null ) vlrdespoperacionalitem,
/*4.068*/ nvl( b.vlrdespoperacionalitem, 0 ) vlrdespoperacionalitemdevol,
/*4.069*/ 0 vlritemsemst,
/*4.070*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrdescitem, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
            + nvl( b.vlricmsst, 0 )
            + nvl( b.vlrfcpst, 0 )
          ) vlrdevolitemsemst,
/*4.071*/ 0 vlricmsst,
/*4.072*/ nvl( b.vlricmsst, 0 ) ,
/*4.073*/ 0 vlrfrete,
/*4.074*/ null nroserieecf,
/*4.075*/ 'S' tiptabela,
/*4.076*/ d.acmcompravenda cgoacmcompravenda,
/*4.077*/ a.seqauxnotafiscal,
/*4.078*/ 0 vlritemsemdesc,
/*4.079*/ 0 vlrdescitem,
/*4.080*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
            + nvl( b.vlricmsst, 0 )
            + nvl( b.vlrfcpst, 0 )
          ) vlrdevolitemsemdesc,
/*4.081*/ b.vlrdescitem vlrdescdevolitem,
/*4.082*/ ( b.vlrtotcomissaotele * -1 ) vlrtotcomissaotele,
/*4.083*/ null nrotelevenda,
/*4.084*/ b.vlrcompror,
/*4.085*/ 0 vlrembdescressarcst,
/*4.086*/ nvl( b.vlrembdescressarcst, 0 ) vlrembdescressarcstdevol,
/*4.087*/ a.nropromotor,
/*4.088*/ a.tipnotafiscal,
/*4.089*/ 0 vlricmsstemporig,
/*4.090*/ 0 vlrcustobrutoemporig,
/*4.091*/ nvl( b.vlrfreteabc, 0 ) vlrfreteabc,
/*4.092*/ e.nrodivisao,
/*4.093*/ null nroequipe,
/*4.094*/ case when nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) < 0 then
               0
          else
              nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 )
          end custofiscalunit,
/*4.095*/ case when ( nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) ) * nvl( m.estqempresa, 0 ) < 0 then
               0
          else
               ( nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) ) * nvl( m.estqempresa, 0 )
          end custofiscaltotal,
/*4.096*/ PE.UF ufpessoa,
/*4.097*/ null codareageograficavda,
/*4.098*/ null codsubareageograficavda,
/*4.099*/ 0 vlrvendapromoc,
/*4.100*/ a.seqtransportador,
/*4.101*/ null nrotabvenda,
/*4.102*/ a.seqnf,
/*4.103*/ 0 vlrverbacompra,
/*4.104*/ 0 vlrverbabonifincid,
/*4.105*/ 0 vlrverbabonifsemincid,
/*4.106*/ nvl( b.vlrverbacompra, 0 ) vlrverbacompradev,
/*4.107*/ nvl( b.vlrverbabonifincid, 0 ) vlrverbabonifinciddev,
/*4.108*/ nvl( b.vlrverbabonifsemincid, 0 ) vlrverbabonifseminciddev,
/*4.109*/ nvl( b.seqprodutofinal, b.seqproduto ) seqprodutofinal,
/*4.110*/ 0 qtditemprodfinal,
/*4.111*/ nvl( b.quantidadeprodfinal, b.quantidade ) qtditemdevprodfinal,
/*4.112*/ m.cmultvlrdespfixa,
/*4.113*/ m.cmultvlrdescfixo,
/*4.114*/ b.vlrdescverbatransf,
/*4.115*/ b.vlrdesclucrotransf,
/*4.116*/ null dtanfref,
/*4.117*/ 0 vlrverbavda,
/*4.118*/ 0 qtdverbavda,
/*4.119*/ nvl( b.vlrverbavda, 0 ) vlrverbavdadevol,
/*4.120*/ nvl( b.qtdverbavda, 0 ) qtdverbavdadevol,
/*4.121*/ null seqpromocao,
/*4.122*/ 0 qtdverbapdv,
/*4.123*/ 0 vlrverbapdv,
/*4.124*/ nvl( b.qtdverbapdv, 0 ) qtdverbapdvdevol,
/*4.125*/ nvl( b.vlrverbapdv, 0 ) vlrverbapdvdevol,
/*4.126*/ 0 vlrpiscofinsverbapdv,
/*4.127*/ nvl( b.vlrpiscofinsverbapdv, 0 ) vlrpiscofinsverbapdvdevol,
/*4.128*/ 0 vlrdescmedalha,
/*4.129*/ m.vlrgmroi,
/*4.130*/ m.indposicaocateg,
/*4.131*/ 0 vlrdescfornec,
/*4.132*/ nvl( b.vlrdescfornec, 0 ) vlrdescfornecdevol,
/*4.133*/ null tipopromocpdv,
/*4.134*/ 0 vlrfreteitemrateio,
/*4.135*/ nvl( b.vlrfreteitemrateio, 0 ) vlrfreteitemrateiodev,
/*4.136*/ 0 vlricmsstembutprod,
/*4.137*/ nvl( b.vlricmsstembutprod, 0 ) vlricmsstembutproddev,
/*4.138*/ b.seqcluster,
/*4.139*/ nvl( b.nfreferencianro, a.nfreferencianro ) nfreferencianro,
/*4.140*/ nvl( b.nfreferenciaserie, a.nfreferenciaserie ) nfreferenciaserie,
/*4.141*/ 'N' indpromocao,
/*4.142*/ 0 vlrdescacordoverbapdv,
/*4.143*/ 0 vlrdifcampanhapreco,
/*4.144*/ 0 vlrdifcampanhaprecodevol,
/*4.145*/ 0 vlrcustonfprecocamp,
/*4.146*/ null seqcampanha,
/*4.147*/ b.vlrprecomargemzero,
/*4.148*/ 0 qtddotznormal,
/*4.149*/ 0 vlrvendadotznormal,
/*4.150*/ 0 qtddotzextra,
/*4.151*/ 0 vlrvendadotzextra,
/*4.152*/ 0 qtddotztotal,
/*4.153*/ 0 vlrvendadotztotal,
/*4.154*/ 0 seqzonavenda,
/*4.155*/ 0 vlrdesccomercial,
/*4.156*/ pe.grupo grupocliente,
/*4.157*/ 0 vlritemrateiocte,
/*4.158*/ null ctenro,
/*4.159*/ null cteserie,
/*4.160*/ 0 vlrverbavdasemicus,
/*4.161*/ 0 vlrfcpst,
/*4.162*/ 0 vlrfcpicms,
/*4.163*/ 0 vlrfcpdistrib,
/*4.164*/ 0 vlrfcpstsubst,
/*4.165*/ nvl(b.vlrfcpst, 0) dvlrfcpst,
/*4.166*/ nvl(b.vlrfcpicms, 0) dvlrfcpicms,
/*4.167*/ nvl(b.vlrfcpdistrib, 0) dvlrfcpdistrib,
/*4.168*/ nvl(b.vlrfcpstsubst, 0) dvlrfcpstsubst,
/*4.169*/ 0 icmsefetivoitem,
/*4.170*/ nvl(b.vlricmsefet, 0) icmsefetivodevolitem,
/*4.171*/ pe.indcontribicms,
/*4.172*/ pe.fisicajuridica,
/*4.173*/ nvl(d.indconsumidorfinal, 'N'),
/*4.174*/ d.tipdocfiscal tipdocfiscalcgo,
/*4.175*/ null nropedidovenda,
/*4.176*/ d.tipcgo tipcgo,
/*4.177*/ 0 vlripiprecovda,
/*4.178*/ 0 vlripiprecodevol,
/*4.179*/ nvl(b.vlrdescmedalha, 0) vlrdescmedalhadevol
/* Quando implementar nova coluna, tratar tambem na view "MAXV_ABCFORMAPAGTO". Manter comentario apos a ultima coluna. */
from mlf_notafiscal     a,
     mlf_nfitem         b,
     max_codgeraloper   d,
     max_empresa        e,
     mad_segmento       s,
     mad_parametro      x,
     mrl_produtoempresa m,
     ge_pessoa          pe,
     max_divisao        v
where b.numeronf         = a.numeronf
and   b.seqpessoa        = a.seqpessoa
and   b.serienf          = a.serienf
and   b.tipnotafiscal    = a.tipnotafiscal
and   b.nroempresa       = a.nroempresa
and   nvl( a.seqnf, 0 )  = nvl( b.seqnf, nvl( a.seqnf, 0 ) )
and   a.codgeraloper     = d.codgeraloper
and   s.nrosegmento      = nvl( b.nrosegitem, e.nrosegmentoprinc )
and   x.nroempresa       = e.nroempresa
and   a.nroempresa       = e.nroempresa
and   m.seqproduto       = nvl( b.seqprodutobase, b.seqproduto )
and   m.nroempresa       = nvl( e.nroempcustoabc, e.nroempresa )
and   a.tipnotafiscal    = 'E'
and   b.tipitem          = 'R'
and   d.tipcgo           = 'E'
and   b.quantidade       != 0
and   a.statusnf         = 'V'
and   d.tipdocfiscal     = 'D'
and   nvl( x.utilrefdoctodevol, 'S' ) = 'N'
and   ( coalesce( a.geralteracaoestq, d.geralteracaoestq )= 'S'
        or d.acmcompravenda in ( 'S', 'I' ) )
and   a.seqpessoa         = pe.seqpessoa
and   e.nrodivisao        = v.nrodivisao
and   nvl( b.indtipodescbonif, 'I' ) != 'T'
AND nvl( a.dtahorlancto, a.dtaentrada ) >= SYSDATE - 150
AND EXISTS (SELECT 1 FROM CONSINCO.NAGT_DEPARA_VESTRH ZZ WHERE ZZ.SEQPRODUTO = B.SEQPRODUTO)
AND A.CODGERALOPER IN (60,923,914,64,102,949,210,57,948,10,941,1,927,211,814,802,801,944,811,850,942,95,261,931,240)


union all
-- DEVOLUCOES DE VENDAS COLIGADA (COM NF DE REFERENCIA)
select
/*5.000*/ 5 idsql,
/*5.001*/ nvl( a.dtahorlancto, a.dtaentrada ) dtahorlancto,
/*5.002*/ a.dtaentrada dtavda,
/*5.003*/ a.nroempresa,
/*5.004*/ a.numeronf nrodocto,
/*5.005*/ a.serienf seriedocto,
/*5.006*/ a.seqpessoa,
/*5.007*/ nvl( a.enderecoentrega, 0 ) seqpessoaend,
/*5.008*/ a.versaopessoa,
/*5.009*/ a.usulancto operador,
/*5.010*/ ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( min( g.sequsuario ), 0 )
            from ge_usuario g
            where g.codusuario = a.usulancto
          ) seqoperador,
/*5.011*/ 0 checkout,
/*5.012*/ b.seqproduto,
/*5.013*/ nvl( b.seqprodutobase, b.seqproduto ) seqprodutocusto,
/*5.014*/ b.seqitemnf seqitem,
/*5.015*/ b.qtdembalagem qtdembalitem,
/*5.016*/ 0 qtditem,
/*5.017*/ b.quantidade qtddevolitem,
/*5.018*/ 0 vlritem,
/*5.019*/ 0 vlripiitem,
/*5.020*/ 0 vlrdesconto,
/*5.021*/ 0 vlracrescimo,
/*5.022*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrdescitem, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
            + nvl( b.vlricmsst, 0 )
            + nvl( b.vlrfcpst, 0 )
          ) vlrdevolitem,
/*5.023*/ nvl( b.vlripi, 0 ) vlripidevolitem,
/*5.024*/ 0 icmsitem,
/*5.025*/ case when ( ( substr(b.situacaonf, -2) = '90' or b.tipocalcicmsfisci = 26 ) and e.uf = 'CE' ) then
             0
          else
            nvl( b.vlricmscalc, b.bascalcicms * b.peraliquotaicms / 100 )
            + nvl( b.vlricmsvpe, 0 )
            -
            ( case when b.tipocalcicmsfisci = 25 then
                  round( ( b.bascalcicms * b.peraliquotaicms / 100 * nvl( b.peraliqicmsdif, 0 ) / 100 ), 2 )
              else
                  0
              end
            ) end
          icmsdevolitem,
/*5.026*/ 0 pisitem,
/*5.027*/ nvl( b.vlrpis, 0 ) pisdevolitem,
/*5.028*/ 0 cofinsitem,
/*5.029*/ nvl( b.vlrcofins, 0 ) cofinsdevolitem,
/*5.030*/ 0 vlrrestornoitem,
/*5.031*/ 0 vlrrestornodevolitem,
/*5.032*/ 0 issitem,
/*5.033*/ nvl( b.vlrtotiss, 0 ) issdevolitem,
/*5.034*/ 'NFE' tipdocto,
/*5.035*/ nvl( b.nrorepresentante, nvl( x.nroreppadrao, 0 ) ) nrorepresentante,
/*5.036*/ decode( nvl( b.nrorepresentante, nvl( x.nroreppadrao, 0 ) ), 0,
                    nvl( b.nrosegitem, e.nrosegmentoprinc ),
                    coalesce( b.nrosegitem, ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( max( r.nrosegmento ), e.nrosegmentoprinc )
                                              from mad_representante r
                                              where r.nrorepresentante = nvl( b.nrorepresentante, nvl( x.nroreppadrao, 0 ) ) ) )
          ) nrosegmento,
/*5.037*/ nvl( a.nroformapagto, x.formapagtopadrao ) nroformapagto,
/*5.038*/ a.dtaentrada dtavencimento,
/*5.039*/ a.pzomediopagamento nrodiasprazomedio,
/*5.040*/ 'S' acmcompravenda,
/*5.041*/ e.perpis,
/*5.042*/ e.percofins,
/*5.043*/ e.percpmf,
/*5.044*/ e.perir,
/*5.045*/ e.pericmsestimativa,
/*5.046*/ e.peroutroimposto,
/*5.047*/ 0 vlrtotcomissaoitem,
/*5.048*/ nvl( b.vlrtotcomissao, 0 ) vlrtotcomissaoitemdevol,
/*5.049*/ to_number( null ) nrocarga,
/*5.050*/ to_number( null ) nrocondicaopagto,
/*5.051*/ a.codgeraloper,
/*5.052*/ 'R' origempedido,
/*5.053*/ s.indprecoembalagem,
/*5.054*/ rowidtochar( a.rowid ) rowiddocto,
/*5.055*/ to_number( null ) seqprodutovda,
/*5.056*/ b.seqproduto seqprodutodevol,
/*5.057*/ to_number( null ) seqpessoavda,
/*5.058*/ a.seqpessoa seqpessoadevol,
/*5.059*/ null rowiddoctovda,
/*5.060*/ rowidtochar( a.rowid ) rowiddoctodevol,
/*5.061*/ b.seqloteestoque,
/*5.062*/ to_number( null ) seqpromocpdv,
/*5.063*/ b.classifabcfamseg,
/*5.064*/ 0 vlrdescforanf,
/*5.065*/ nvl( b.ocorrenciadevitem,a.ocorrenciadev ) ocorrenciadev,
/*5.066*/ ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( max( z.descricao ), '*** N?O ENCONTRADO: ' || nvl( b.ocorrenciadevitem, a.ocorrenciadev ) || ' ***' )
            from max_atributofixo z
            where z.tipatributofixo = 'OCORRENCIA DEVOL'
            and z.lista = nvl( b.ocorrenciadevitem, a.ocorrenciadev )
          ) descocorrenciadev,
/*5,067*/ to_number( null ) vlrdespoperacionalitem,
/*5.068*/ nvl( b.vlrdespoperacionalitem, 0 ) vlrdespoperacionalitemdevol,
/*5.069*/ 0 vlritemsemst,
/*5.070*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrdescitem, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
            + nvl( b.vlricmsst, 0 )
            + nvl( b.vlrfcpst, 0 )
          ) vlrdevolitemsemst,
/*5.071*/ 0 vlricmsst,
/*5.072*/ nvl( b.vlricmsst, 0 ) vlrdevolicmsst,
/*5.073*/ 0 vlrfrete,
/*5.074*/ null nroserieecf,
/*5.075*/ 'R' tiptabela,
/*5.076*/ d.acmcompravenda cgoacmcompravenda,
/*5.077*/ a.seqauxnotafiscal,
/*5.078*/ 0 vlritemsemdesc,
/*5.079*/ 0 vlrdescitem,
/*5.080*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
            + nvl( b.vlricmsst, 0 )
            + nvl( b.vlrfcpst, 0 )
          ) vlrdevolitemsemdesc,
/*5.081*/ b.vlrdescitem vlrdescdevolitem,
/*5.082*/ ( b.vlrtotcomissaotele * -1 ) vlrtotcomissaotele,
/*5.083*/ null nrotelevenda,
/*5.084*/ b.vlrcompror,
/*5.085*/ 0 vlrembdescressarcst,
/*5.086*/ nvl( b.vlrembdescressarcst, 0 ) vlrembdescressarcstdevol,
/*5.087*/ a.nropromotor,
/*5.088*/ a.tipnotafiscal,
/*5.089*/ 0 vlricmsstemporig,
/*5.090*/ 0 vlrcustobrutoemporig,
/*5.091*/ nvl( b.vlrfreteabc, 0 ) vlrfreteabc,
/*5.092*/ e.nrodivisao,
/*5.093*/ null nroequipe,
/*5.094*/ case when nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) < 0 then
               0
          else
              nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 )
          end custofiscalunit,
/*5.095*/ case when ( nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) ) * nvl( m.estqempresa, 0 ) < 0 then
               0
          else
               ( nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) ) * nvl( m.estqempresa, 0 )
          end custofiscaltotal,
/*5.096*/ pe.uf ufpessoa,
/*5.097*/ null codareageograficavda,
/*5.098*/ null codsubareageograficavda,
/*5.099*/ 0 vlrvendapromoc,
/*5.100*/ a.seqtransportador,
/*5.101*/ null nrotabvenda,
/*5.102*/ a.seqnf,
/*5.103*/ 0 vlrverbacompra,
/*5.104*/ 0 vlrverbabonifincid,
/*5.105*/ 0 vlrverbabonifsemincid,
/*5.106*/ nvl( b.vlrverbacompra, 0 ) vlrverbacompradev,
/*5.107*/ nvl( b.vlrverbabonifincid, 0 ) vlrverbabonifinciddev,
/*5.108*/ nvl( b.vlrverbabonifsemincid, 0 ) vlrverbabonifseminciddev,
/*5.109*/ nvl( b.seqprodutofinal, b.seqproduto ) seqprodutofinal,
/*5.110*/ 0 qtditemprodfinal,
/*5.111*/ nvl( b.quantidadeprodfinal, b.quantidade ) qtditemdevprodfinal,
/*5.112*/ m.cmultvlrdespfixa,
/*5.113*/ m.cmultvlrdescfixo,
/*5.114*/ b.vlrdescverbatransf,
/*5.115*/ b.vlrdesclucrotransf,
/*5.116*/ null dtanfref,
/*5.117*/ 0 vlrverbavda,
/*5.118*/ 0 qtdverbavda,
/*5.119*/ nvl( b.vlrverbavda, 0 ) vlrverbavdadevol,
/*5.120*/ nvl( b.qtdverbavda, 0 ) qtdverbavdadevol,
/*5.121*/ null seqpromocao,
/*5.122*/ 0 qtdverbapdv,
/*5.123*/ 0 vlrverbapdv,
/*5.124*/ nvl( b.qtdverbapdv, 0 ) qtdverbapdvdevol,
/*5.125*/ nvl( b.vlrverbapdv, 0 ) vlrverbapdvdevol,
/*5.126*/ 0 vlrpiscofinsverbapdv,
/*5.127*/ nvl( b.vlrpiscofinsverbapdv, 0 ) vlrpiscofinsverbapdvdevol,
/*5.128*/ 0 vlrdescmedalha,
/*5.129*/ m.vlrgmroi,
/*5.130*/ m.indposicaocateg,
/*5.131*/ 0 vlrdescfornec,
/*5.132*/ nvl( b.vlrdescfornec, 0 ) vlrdescfornecdevol,
/*5.133*/ null tipopromocpdv,
/*5.134*/ 0 vlrfreteitemrateio,
/*5.135*/ nvl( b.vlrfreteitemrateio, 0 ) vlrfreteitemrateiodev,
/*5.136*/ 0 vlricmsstembutprod,
/*5.137*/ nvl( b.vlricmsstembutprod, 0 ) vlricmsstembutproddev,
/*5.138*/ b.seqcluster,
/*5.139*/ nvl( b.nfreferencianro, a.nfreferencianro ) nfreferencianro,
/*5.140*/ nvl( b.nfreferenciaserie, a.nfreferenciaserie ) nfreferenciaserie,
/*5.141*/ 'N' indpromocao,
/*5.142*/ 0 vlrdescacordoverbapdv,
/*5.143*/ 0 vlrdifcampanhapreco,
/*5.144*/ 0 vlrdifcampanhaprecodevol,
/*5.145*/ 0 vlrcustonfprecocamp,
/*5.146*/ null seqcampanha,
/*5.147*/ b.vlrprecomargemzero,
/*5.148*/ 0 qtddotznormal,
/*5.149*/ 0 vlrvendadotznormal,
/*5.150*/ 0 qtddotzextra,
/*5.151*/ 0 vlrvendadotzextra,
/*5.152*/ 0 qtddotztotal,
/*5.153*/ 0 vlrvendadotztotal,
/*5.154*/ 0 seqzonavenda,
/*5.155*/ 0 vlrdesccomercial,
/*5.156*/ pe.grupo grupocliente,
/*5.157*/ 0 vlritemrateiocte,
/*5.158*/ null ctenro,
/*5.159*/ null cteserie,
/*5.160*/ 0 vlrverbavdasemicus,
/*5.161*/ 0 vlrfcpst,
/*5.162*/ 0 vlrfcpicms,
/*5.163*/ 0 vlrfcpdistrib,
/*5.164*/ 0 vlrfcpstsubst,
/*5.165*/ nvl(b.vlrfcpst, 0) dvlrfcpst,
/*5.166*/ nvl(b.vlrfcpicms, 0) dvlrfcpicms,
/*5.167*/ nvl(b.vlrfcpdistrib, 0) dvlrfcpdistrib,
/*5.168*/ nvl(b.vlrfcpstsubst, 0) dvlrfcpstsubst,
/*5.169*/ 0 icmsefetivoitem,
/*5.170*/ nvl(b.vlricmsefet, 0) icmsefetivodevolitem,
/*5.171*/ pe.indcontribicms,
/*5.172*/ pe.fisicajuridica,
/*5.173*/ nvl(d.indconsumidorfinal, 'N'),
/*5.174*/ d.tipdocfiscal tipdocfiscalcgo,
/*5.175*/ null nropedidovenda,
/*5.176*/ d.tipcgo tipcgo,
/*5.177*/ 0 vlripiprecovda,
/*5.178*/ 0 vlripiprecodevol,
/*5.179*/ nvl(b.vlrdescmedalha, 0) vlrdescmedalhadevol
/* Quando implementar nova coluna, tratar tambem na view "MAXV_ABCFORMAPAGTO". Manter comentario apos a ultima coluna. */
from mlf_notafiscal     a,
     mlf_nfitem         b,
     max_codgeraloper   d,
     max_empresa        e,
     mad_segmento       s,
     mad_parametro      x,
     mlf_notafiscal     t,
     mrl_produtoempresa m,
     ge_pessoa          pe,
     max_divisao        v
where b.numeronf         = a.numeronf
and   b.seqpessoa        = a.seqpessoa
and   b.serienf          = a.serienf
and   b.tipnotafiscal    = a.tipnotafiscal
and   b.nroempresa       = a.nroempresa
and   nvl( a.seqnf, 0 )  = nvl( b.seqnf, nvl( a.seqnf, 0 ) )
and   a.codgeraloper     = d.codgeraloper
and   s.nrosegmento      = nvl( b.nrosegitem, e.nrosegmentoprinc )
and   x.nroempresa       = e.nroempresa
and   a.nroempresa       = e.nroempresa
and   t.numeronf         = nvl( b.nfreferencianro, a.nfreferencianro )
and   t.serienf          = nvl( b.nfreferenciaserie, a.nfreferenciaserie )
and   m.seqproduto       = nvl( b.seqprodutobase, b.seqproduto )
and   m.nroempresa       = nvl( e.nroempcustoabc, e.nroempresa )
and   t.tipnotafiscal    = 'E'
and   a.tipnotafiscal    = 'E'
and   b.tipitem          = 'R'
and   d.tipcgo           = 'E'
and   b.quantidade      != 0
and   a.statusnf         = 'V'
and   d.tipdocfiscal     = 'D'
and   t.seqpessoa        = e.seqpessoaemp
and   nvl( x.utilrefdoctodevol, 'S' ) in ( 'S', 'A' )
and   ( coalesce( a.geralteracaoestq, d.geralteracaoestq ) = 'S'
        or d.acmcompravenda in ( 'S', 'I' ) )
and   a.seqpessoa        = pe.seqpessoa
and   a.apporigem        = 9
and   e.nrodivisao       = v.nrodivisao
and   nvl( b.indtipodescbonif, 'I' ) != 'T'
AND nvl( a.dtahorlancto, a.dtaentrada ) >= SYSDATE - 150
AND EXISTS (SELECT 1 FROM CONSINCO.NAGT_DEPARA_VESTRH ZZ WHERE ZZ.SEQPRODUTO = B.SEQPRODUTO)
AND A.CODGERALOPER IN (60,923,914,64,102,949,210,57,948,10,941,1,927,211,814,802,801,944,811,850,942,95,261,931,240)

union all
-- DEVOLUCOES DE VENDAS COLIGADA (COM NF DE REFERENCIA GERADAS PELA DEVOLUC?O AUTOMATICA MFL_DOCTOFISCAL RC 129297)
select
/*6.000*/ 6 idsql,
/*6.001*/ nvl( a.dtahorlancto, a.dtaentrada ) dtahorlancto,
/*6.002*/ a.dtaentrada dtavda,
/*6.003*/ a.nroempresa,
/*6.004*/ a.numeronf nrodocto,
/*6.005*/ a.serienf seriedocto,
/*6.006*/ a.seqpessoa,
/*6.007*/ nvl( a.enderecoentrega, 0 ) seqpessoaend,
/*6.008*/ a.versaopessoa,
/*6.009*/ a.usulancto operador,
/*6.010*/ ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( min( g.sequsuario ), 0 )
            from ge_usuario g
            where g.codusuario = a.usulancto
          ) seqoperador,
/*6.011*/ 0 checkout,
/*6.012*/ b.seqproduto,
/*6.013*/ nvl( b.seqprodutobase, b.seqproduto ) seqprodutocusto,
/*6.014*/ b.seqitemnf seqitem,
/*6.015*/ b.qtdembalagem qtdembalitem,
/*6.016*/ 0 qtditem,
/*6.017*/ b.quantidade qtddevolitem,
/*6.018*/ 0 vlritem,
/*6.019*/ 0 vlripiitem,
/*6.020*/ 0 vlrdesconto,
/*6.021*/ 0 vlracrescimo,
/*6.022*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrdescitem, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
            + nvl( b.vlricmsst, 0 )
            + nvl( b.vlrfcpst, 0 )
          ) vlrdevolitem,
/*6.023*/ nvl( b.vlripi, 0 ) vlripidevolitem,
/*6.024*/ 0 icmsitem,
/*6.025*/ case when ( ( substr(b.situacaonf, -2) = '90' or b.tipocalcicmsfisci = 26 ) and e.uf = 'CE' ) then
            0
          else
            nvl( b.vlricmscalc, b.bascalcicms * b.peraliquotaicms / 100 )
            + nvl( b.vlricmsvpe, 0 )
            -
            ( case when b.tipocalcicmsfisci = 25 then
                  round( ( b.bascalcicms * b.peraliquotaicms / 100 * nvl( b.peraliqicmsdif, 0 ) / 100 ), 2 )
              else
                  0
              end
            ) end
            icmsdevolitem,
/*6.026*/ 0 pisitem,
/*6.027*/ nvl( b.vlrpis, 0 ) pisdevolitem,
/*6.028*/ 0 cofinsitem,
/*6.029*/ nvl( b.vlrcofins, 0 ) cofinsdevolitem,
/*6.030*/ 0 vlrrestornoitem,
/*6.031*/ 0 vlrrestornodevolitem,
/*6.032*/ 0 issitem,
/*6.033*/ nvl( b.vlrtotiss, 0 ) issdevolitem,
/*6.034*/ 'NFE' tipdocto,
/*6.035*/ nvl( b.nrorepresentante, nvl( x.nroreppadrao, 0 ) ) nrorepresentante,
/*6.036*/ decode( nvl( b.nrorepresentante, nvl( x.nroreppadrao, 0 ) ),
                  0, nvl( b.nrosegitem, e.nrosegmentoprinc ),
                  nvl( b.nrosegitem, ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( max( r.nrosegmento ), e.nrosegmentoprinc )
                                       from mad_representante r
                                       where r.nrorepresentante = nvl( b.nrorepresentante, nvl( x.nroreppadrao, 0 ) ) ) )
          ) nrosegmento,
/*6.037*/ nvl( a.nroformapagto, x.formapagtopadrao) nroformapagto,
/*6.038*/ a.dtaentrada dtavencimento,
/*6.039*/ a.pzomediopagamento nrodiasprazomedio,
/*6.040*/ 'S' acmcompravenda,
/*6.041*/ e.perpis,
/*6.042*/ e.percofins,
/*6.043*/ e.percpmf,
/*6.044*/ e.perir,
/*6.045*/ e.pericmsestimativa,
/*6.046*/ e.peroutroimposto,
/*6.047*/ 0 vlrtotcomissaoitem,
/*6.048*/ nvl( b.vlrtotcomissao, 0 ) vlrtotcomissaoitemdevol,
/*6.049*/ to_number( null ) nrocarga,
/*6.050*/ to_number( null ) nrocondicaopagto,
/*6.051*/ a.codgeraloper,
/*6.052*/ 'R' origempedido,
/*6.053*/ s.indprecoembalagem,
/*6.054*/ rowidtochar( a.rowid ) rowiddocto,
/*6.055*/ to_number( null ) seqprodutovda,
/*6.056*/ b.seqproduto seqprodutodevol,
/*6.057*/ to_number( null ) seqpessoavda,
/*6.058*/ a.seqpessoa seqpessoadevol,
/*6.059*/ null rowiddoctovda,
/*6.060*/ rowidtochar( a.rowid ) rowiddoctodevol,
/*6.061*/ b.seqloteestoque,
/*6.062*/ to_number( null ) seqpromocpdv,
/*6.063*/ b.classifabcfamseg,
/*6.064*/ 0 vlrdescforanf,
/*6.065*/ nvl( b.ocorrenciadevitem, a.ocorrenciadev ) ocorrenciadev,
/*6.066*/ ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( max( z.descricao ), '*** N?O ENCONTRADO: ' || nvl( b.ocorrenciadevitem, a.ocorrenciadev ) || ' ***' )
            from max_atributofixo z
            where z.tipatributofixo = 'OCORRENCIA DEVOL'
            and z.lista = nvl( b.ocorrenciadevitem, a.ocorrenciadev )
          ) descocorrenciadev,
/*6.067*/ to_number( null ) vlrdespoperacionalitem,
/*6.068*/ nvl( b.vlrdespoperacionalitem, 0 ) vlrdespoperacionalitemdevol,
/*6.069*/ 0 vlritemsemst,
/*6.070*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrdescitem, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
            + nvl( b.vlricmsst, 0 )
            + nvl( b.vlrfcpst, 0 )
          ) vlrdevolitemsemst,
/*6.071*/ 0 vlricmsst,
/*6.072*/ nvl( b.vlricmsst, 0 ) vlrdevolicmsst,
/*6.073*/ 0 vlrfrete,
/*6.074*/ null nroserieecf,
/*6.075*/ 'R' tiptabela,
/*6.076*/ d.acmcompravenda cgoacmcompravenda,
/*6.077*/ a.seqauxnotafiscal,
/*6.078*/ 0 vlritemsemdesc,
/*6.079*/ 0 vlrdescitem,
/*6.080*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
            + nvl( b.vlricmsst, 0 )
            + nvl( b.vlrfcpst, 0 )
          ) vlrdevolitemsemdesc,
/*6.081*/ b.vlrdescitem vlrdescdevolitem,
/*6.082*/ ( b.vlrtotcomissaotele * -1 ) vlrtotcomissaotele,
/*6.083*/ null nrotelevenda,
/*6.084*/ b.vlrcompror,
/*6.085*/ 0 vlrembdescressarcst,
/*6.086*/ nvl( b.vlrembdescressarcst, 0 ) vlrembdescressarcstdevol,
/*6.087*/ a.nropromotor,
/*6.088*/ a.tipnotafiscal,
/*6.089*/ 0 vlricmsstemporig,
/*6.090*/ 0 vlrcustobrutoemporig,
/*6.091*/ nvl( b.vlrfreteabc, 0 ) vlrfreteabc,
/*6.092*/ e.nrodivisao,
/*6.093*/ null nroequipe,
/*6.094*/ case when nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) < 0 then
               0
          else
              nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 )
          end custofiscalunit,
/*6.095*/ case when ( nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) ) * nvl( m.estqempresa, 0 ) < 0 then
               0
          else
               ( nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) ) * nvl( m.estqempresa, 0 )
          end custofiscaltotal,
/*6.096*/ pe.uf ufpessoa,
/*6.097*/ null codareageograficavda,
/*6.098*/ null codsubareageograficavda,
/*6.099*/ 0 vlrvendapromoc,
/*6.100*/ a.seqtransportador,
/*6.101*/ null nrotabvenda,
/*6.102*/ a.seqnf,
/*6.103*/ 0 vlrverbacompra,
/*6.104*/ 0 vlrverbabonifincid,
/*6.105*/ 0 vlrverbabonifsemincid,
/*6.106*/ nvl( b.vlrverbacompra, 0 ) vlrverbacompradev,
/*6.107*/ nvl( b.vlrverbabonifincid, 0 ) vlrverbabonifinciddev,
/*6.108*/ nvl( b.vlrverbabonifsemincid, 0 ) vlrverbabonifseminciddev,
/*6.109*/ nvl( b.seqprodutofinal, b.seqproduto ) seqprodutofinal,
/*6.110*/ 0 qtditemprodfinal,
/*6.111*/ nvl( b.quantidadeprodfinal, b.quantidade ) qtditemdevprodfinal,
/*6.112*/ m.cmultvlrdespfixa,
/*6.113*/ m.cmultvlrdescfixo,
/*6.114*/ b.vlrdescverbatransf,
/*6.115*/ b.vlrdesclucrotransf,
/*6.116*/ null dtanfref,
/*6.117*/ 0 vlrverbavda,
/*6.118*/ 0 qtdverbavda,
/*6.119*/ nvl( b.vlrverbavda, 0 ) vlrverbavdadevol,
/*6.120*/ nvl( b.qtdverbavda, 0 ) qtdverbavdadevol,
/*6.121*/ null seqpromocao,
/*6.122*/ 0 qtdverbapdv,
/*6.123*/ 0 vlrverbapdv,
/*6.124*/ nvl( b.qtdverbapdv, 0 ) qtdverbapdvdevol,
/*6.125*/ nvl( b.vlrverbapdv, 0 ) vlrverbapdvdevol,
/*6.126*/ 0 vlrpiscofinsverbapdv,
/*6.127*/ nvl( b.vlrpiscofinsverbapdv, 0 ) vlrpiscofinsverbapdvdevol,
/*6.128*/ 0 vlrdescmedalha,
/*6.129*/ m.vlrgmroi,
/*6.130*/ m.indposicaocateg,
/*6.131*/ 0 vlrdescfornec,
/*6.132*/ nvl( b.vlrdescfornec, 0 ) vlrdescfornecdevol,
/*6.133*/ null tipopromocpdv,
/*6.134*/ 0 vlrfreteitemrateio,
/*6.135*/ nvl( b.vlrfreteitemrateio, 0 ) vlrfreteitemrateiodev,
/*6.136*/ 0 vlricmsstembutprod,
/*6.137*/ nvl( b.vlricmsstembutprod, 0 ) vlricmsstembutproddev,
/*6.138*/ b.seqcluster,
/*6.139*/ nvl( b.nfreferencianro, a.nfreferencianro ) nfreferencianro,
/*6.140*/ nvl( b.nfreferenciaserie, a.nfreferenciaserie ) nfreferenciaserie,
/*6.141*/ 'N' indpromocao,
/*6.142*/ 0 vlrdescacordoverbapdv,
/*6.143*/ 0 vlrdifcampanhapreco,
/*6.144*/ 0 vlrdifcampanhaprecodevol,
/*6.145*/ 0 vlrcustonfprecocamp,
/*6.146*/ null seqcampanha,
/*6.147*/ b.vlrprecomargemzero,
/*6.148*/ 0 qtddotznormal,
/*6.149*/ 0 vlrvendadotznormal,
/*6.150*/ 0 qtddotzextra,
/*6.151*/ 0 vlrvendadotzextra,
/*6.152*/ 0 qtddotztotal,
/*6.153*/ 0 vlrvendadotztotal,
/*6.154*/ 0 seqzonavenda,
/*6.155*/ 0 vlrdesccomercial,
/*6.156*/ nvl( t.grupocliente, pe.grupo ) grupocliente,
/*6.157*/ 0 vlritemrateiocte,
/*6.158*/ null ctenro,
/*6.159*/ null cteserie,
/*6.160*/ 0 vlrverbavdasemicus,
/*6.161*/ 0 vlrfcpst,
/*6.162*/ 0 vlrfcpicms,
/*6.163*/ 0 vlrfcpdistrib,
/*6.164*/ 0 vlrfcpstsubst,
/*6.165*/ nvl(b.vlrfcpst, 0) dvlrfcpst,
/*6.166*/ nvl(b.vlrfcpicms, 0) dvlrfcpicms,
/*6.167*/ nvl(b.vlrfcpdistrib, 0) dvlrfcpdistrib,
/*6.168*/ nvl(b.vlrfcpstsubst, 0) dvlrfcpstsubst,
/*6.169*/ 0 icmsefetivoitem,
/*6.170*/ nvl(b.vlricmsefet, 0) icmsefetivodevolitem,
/*6.171*/ pe.indcontribicms,
/*6.172*/ pe.fisicajuridica,
/*6.173*/ nvl(d.indconsumidorfinal, 'N'),
/*6.174*/ d.tipdocfiscal tipdocfiscalcgo,
/*6.175*/ null nropedidovenda,
/*6.176*/ d.tipcgo tipcgo,
/*6.177*/ 0 vlripiprecovda,
/*6.178*/ 0 vlripiprecodevol,
/*6.179*/ nvl(b.vlrdescmedalha, 0) vlrdescmedalhadevol
/* Quando implementar nova coluna, tratar tambem na view "maxv_abcformapagto". Manter comentario apos a ultima coluna. */
from mlf_notafiscal     a,
     mlf_nfitem         b,
     max_codgeraloper   d,
     max_empresa        e,
     mad_segmento       s,
     mad_parametro      x,
     mfl_doctofiscal    t,
     mrl_produtoempresa m,
     ge_pessoa          pe,
     max_divisao        v
where b.numeronf         = a.numeronf
and   b.seqpessoa        = a.seqpessoa
and   b.serienf          = a.serienf
and   b.tipnotafiscal    = a.tipnotafiscal
and   b.nroempresa       = a.nroempresa
and   nvl( a.seqnf, 0 )  = nvl( b.seqnf, nvl( a.seqnf, 0 ) )
and   a.codgeraloper     = d.codgeraloper
and   s.nrosegmento      = nvl( b.nrosegitem, e.nrosegmentoprinc )
and   x.nroempresa       = e.nroempresa
and   a.nroempresa       = e.nroempresa
and   t.numerodf         = nvl( b.nfreferencianro, a.nfreferencianro )
and   t.seriedf          = nvl( b.nfreferenciaserie, a.nfreferenciaserie )
and   nvl( t.seqnf,0 )   = nvl( b.seqnfref, nvl( a.seqnfref, 0 ) )
and   m.seqproduto       = nvl( b.seqprodutobase, b.seqproduto )
and   m.nroempresa       = nvl( e.nroempcustoabc, e.nroempresa )
and   a.tipnotafiscal    = 'E'
and   b.tipitem          = 'R'
and   d.tipcgo           = 'E'
and   b.quantidade       != 0
and   a.statusnf         = 'V'
and   d.tipdocfiscal     = 'D'
and   t.seqpessoa        = e.seqpessoaemp
and   nvl( x.utilrefdoctodevol, 'S' ) in ( 'S', 'A' )
and   ( coalesce ( a.geralteracaoestq, d.geralteracaoestq ) = 'S'
        or d.acmcompravenda in ( 'S', 'I' ) )
and   a.seqpessoa         = pe.seqpessoa
and   a.apporigem         = 9
and   e.nrodivisao        = v.nrodivisao
and   nvl( b.indtipodescbonif, 'I' ) != 'T'
AND nvl( a.dtahorlancto, a.dtaentrada ) >= SYSDATE - 150
AND EXISTS (SELECT 1 FROM CONSINCO.NAGT_DEPARA_VESTRH ZZ WHERE ZZ.SEQPRODUTO = B.SEQPRODUTO)
AND A.CODGERALOPER IN (60,923,914,64,102,949,210,57,948,10,941,1,927,211,814,802,801,944,811,850,942,95,261,931,240)

union all
-- DEVOLUCOES DE VENDAS (COM REFERENCIA NULAS E QUANDO O TIPO 'A')
select
/*7.000*/ 7 idsql,
/*7.001*/ nvl( a.dtahorlancto, a.dtaentrada ) dtahorlancto,
/*7.002*/ a.dtaentrada dtavda,
/*7.003*/ a.nroempresa,
/*7.004*/ a.numeronf nrodocto,
/*7.005*/ a.serienf seriedocto,
/*7.006*/ a.seqpessoa,
/*7.007*/ nvl( a.enderecoentrega, 0 ) seqpessoaend,
/*7.008*/ a.versaopessoa,
/*7.009*/ a.usulancto operador,
/*7.010*/ ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( min( g.sequsuario ), 0 )
            from ge_usuario g
            where g.codusuario = a.usulancto
          ) seqoperador,
/*7.011*/ 0 checkout,
/*7.012*/ b.seqproduto,
/*7.013*/ nvl( b.seqprodutobase, b.seqproduto ) seqprodutocusto,
/*7.014*/ b.seqitemnf seqitem,
/*7.015*/ b.qtdembalagem qtdembalitem,
/*7.016*/ 0 qtditem,
/*7.017*/ b.quantidade qtddevolitem,
/*7.018*/ 0 vlritem,
/*7.019*/ 0 vlripiitem,
/*7.020*/ 0 vlrdesconto,
/*7.021*/ 0 vlracrescimo,
/*7.022*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrdescitem, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
            + nvl( b.vlricmsst, 0 )
            + nvl( b.vlrfcpst, 0)
          ) vlrdevolitem,
/*7.023*/ nvl( b.vlripi, 0 ) vlripidevolitem,
/*7.024*/ 0 icmsitem,
/*7.025*/ case when ( ( substr(b.situacaonf, -2) = '90' or b.tipocalcicmsfisci = 26 ) and e.uf = 'CE' ) then
            0
          else
            decode( nvl( nvl( b.vlricmscalc, b.bascalcicms * b.peraliquotaicms / 100 ), 0 ),
                      0, nvl( b.vlricmsvpe, 0 ),
                          nvl( b.vlricmscalc, b.bascalcicms * b.peraliquotaicms / 100 )
            )
            -
            ( case when b.tipocalcicmsfisci = 25 then
                  round( ( b.bascalcicms * b.peraliquotaicms / 100 * nvl( b.peraliqicmsdif, 0 ) / 100 ), 2 )
              else
                  0
              end
            ) end
          icmsdevolitem,
/*7.026*/ 0 pisitem,
/*7.027*/ nvl( b.vlrpis, 0 ) pisdevolitem,
/*7.028*/ 0 cofinsitem,
/*7.029*/ nvl( b.vlrcofins, 0 ) cofinsdevolitem,
/*7.030*/ 0 vlrrestornoitem,
/*7.031*/ 0 vlrrestornodevolitem,
/*7.032*/ 0 issitem,
/*7.033*/ nvl( b.vlrtotiss, 0 ) issdevolitem,
/*7.034*/ 'NFE' tipdocto,
/*7.035*/ nvl( b.nrorepresentante, nvl( x.nroreppadrao, 0 ) ) nrorepresentante,
/*7.036*/ decode( nvl( b.nrorepresentante, nvl( x.nroreppadrao, 0 ) ),
                    0, nvl( b.nrosegitem, e.nrosegmentoprinc ),
                    coalesce( b.nrosegitem, ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( max( r.nrosegmento ), e.nrosegmentoprinc )
                                              from mad_representante r
                                              where r.nrorepresentante = nvl( b.nrorepresentante, nvl( x.nroreppadrao, 0 ) ) ) )
          ) nrosegmento,
/*7.037*/ nvl( a.nroformapagto, x.formapagtopadrao ) nroformapagto,
/*7.038*/ a.dtaentrada dtavencimento,
/*7.039*/ a.pzomediopagamento nrodiasprazomedio,
/*7.040*/ 'S' acmcompravenda,
/*7.041*/ e.perpis,
/*7.042*/ e.percofins,
/*7.043*/ e.percpmf,
/*7.044*/ e.perir,
/*7.045*/ e.pericmsestimativa,
/*7.046*/ e.peroutroimposto,
/*7.047*/ 0 A,
/*7.048*/ nvl( b.vlrtotcomissao, 0 ) vlrtotcomissaoitemdevol,
/*7.049*/ to_number( null ) nrocarga,
/*7.050*/ to_number( null ) nrocondicaopagto,
/*7.051*/ a.codgeraloper,
/*7.052*/ 'R' origempedido,
/*7.053*/ s.indprecoembalagem,
/*7.054*/ rowidtochar( a.rowid ) rowiddocto,
/*7.055*/ to_number( null ) seqprodutovda,
/*7.056*/ b.seqproduto seqprodutodevol,
/*7.057*/ to_number( null ) seqpessoavda,
/*7.058*/ a.seqpessoa seqpessoadevol,
/*7.059*/ null rowiddoctovda,
/*7.060*/ rowidtochar( a.rowid ) rowiddoctodevol,
/*7.061*/ b.seqloteestoque,
/*7.062*/ to_number( null ) seqpromocpdv,
/*7.063*/ b.classifabcfamseg,
/*7.064*/ 0 vlrdescforanf,
/*7.065*/ nvl( b.ocorrenciadevitem, a.ocorrenciadev ) ocorrenciadev,
/*7.066*/ ( SELECT /*+OPTIMIZER_FEATURES_ENABLE('19.1.0')*/ nvl( max( z.descricao ), '*** N?O ENCONTRADO: ' || nvl( b.ocorrenciadevitem, a.ocorrenciadev ) || ' ***' )
            from max_atributofixo z
            where z.tipatributofixo = 'OCORRENCIA DEVOL'
            and z.lista = nvl( b.ocorrenciadevitem, a.ocorrenciadev )
          ) descocorrenciadev,
/*7.067*/ to_number( null ) vlrdespoperacionalitem,
/*7.068*/ nvl( b.vlrdespoperacionalitem, 0 ) vlrdespoperacionalitemdevol,
/*7.069*/ 0 vlritemsemst,
/*7.070*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrdescitem, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
          ) vlrdevolitemsemst,
/*7.071*/ 0 vlricmsst,
/*7.072*/ nvl( b.vlricmsst, 0 ) vlrdevolicmsst,
/*7.073*/ 0 vlrfrete,
/*7.074*/ null nroserieecf,
/*7.075*/ 'A' tiptabela,
/*7.076*/ d.acmcompravenda cgoacmcompravenda,
/*7.077*/ a.seqauxnotafiscal,
/*7.078*/ 0 vlritemsemdesc,
/*7.079*/ 0 vlrdescitem,
/*7.080*/ ( b.vlritem
            + nvl( b.vlrdescsf, 0 )
            - nvl( b.vlrfunruralitem, 0 )
            + case when a.indconsidfretedesptrib = 'N' then
                   nvl( b.vlrdesptributitem, 0 ) + nvl( b.vlrfretenanf, 0 )
              else
                   nvl( b.vlrdesptributitem, 0 )
              end
            + nvl( b.vlrdespntributitem, 0 )
            - nvl( b.vlrdescsuframa, 0 )
            + nvl( b.vlripi, 0 )
          ) vlrdevolitemsemdesc,
/*7.081*/ b.vlrdescitem vlrdescdevolitem,
/*7.082*/ ( b.vlrtotcomissaotele * -1 ) vlrtotcomissaotele,
/*7.083*/ null nrotelevenda,
/*7.084*/ b.vlrcompror,
/*7.085*/ 0 vlrembdescressarcst,
/*7.086*/ nvl( b.vlrembdescressarcst, 0 ) vlrembdescressarcstdevol,
/*7.087*/ a.nropromotor,
/*7.088*/ a.tipnotafiscal,
/*7.089*/ 0 vlricmsstemporig,
/*7.090*/ 0 vlrcustobrutoemporig,
/*7.091*/ nvl( b.vlrfreteabc, 0 ) vlrfreteabc,
/*7.092*/ e.nrodivisao,
/*7.093*/ null nroequipe,
/*7.094*/ case when nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) < 0 then
               0
          else
              nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 )
          end custofiscalunit,
/*7.095*/ case when ( nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) ) * nvl( m.estqempresa, 0 ) < 0 then
               0
          else
               ( nvl( m.cmultcusliquidoemp, 0 ) - nvl( m.cmultdctoforanfemp, 0 ) ) * nvl( m.estqempresa, 0 )
          end custofiscaltotal,
/*7.096*/ pe.uf ufpessoa,
/*7.097*/ null codareageograficavda,
/*7.098*/ null codsubareageograficavda,
/*7.099*/ 0 vlrvendapromoc,
/*7.100*/ a.seqtransportador,
/*7.101*/ null nrotabvenda,
/*7.102*/ a.seqnf,
/*7.103*/ 0 vlrverbacompra,
/*7.104*/ 0 vlrverbabonifincid,
/*7.105*/ 0 vlrverbabonifsemincid,
/*7.106*/ nvl( b.vlrverbacompra, 0 ) vlrverbacompradev,
/*7.107*/ nvl( b.vlrverbabonifincid, 0 ) vlrverbabonifinciddev,
/*7.108*/ nvl( b.vlrverbabonifsemincid, 0 ) vlrverbabonifseminciddev,
/*7.109*/ nvl( b.seqprodutofinal, b.seqproduto ) seqprodutofinal,
/*7.110*/ 0 qtditemprodfinal,
/*7.111*/ nvl( b.quantidadeprodfinal, b.quantidade ) qtditemdevprodfinal,
/*7.112*/ m.cmultvlrdespfixa,
/*7.113*/ m.cmultvlrdescfixo,
/*7.114*/ b.vlrdescverbatransf,
/*7.115*/ b.vlrdesclucrotransf,
/*7.116*/ null dtanfref,
/*7.117*/ 0 vlrverbavda,
/*7.118*/ 0 qtdverbavda,
/*7.119*/ nvl( b.vlrverbavda, 0 ) vlrverbavdadevol,
/*7.120*/ nvl( b.qtdverbavda, 0 ) qtdverbavdadevol,
/*7.121*/ null seqpromocao,
/*7.122*/ 0 qtdverbapdv,
/*7.123*/ 0 vlrverbapdv,
/*7.124*/ nvl( b.qtdverbapdv, 0 ) qtdverbapdvdevol,
/*7.125*/ nvl( b.vlrverbapdv, 0 ) vlrverbapdvdevol,
/*7.126*/ 0 vlrpiscofinsverbapdv,
/*7.127*/ nvl( b.vlrpiscofinsverbapdv, 0 ) vlrpiscofinsverbapdvdevol,
/*7.128*/ 0 vlrdescmedalha,
/*7.129*/ m.vlrgmroi,
/*7.130*/ m.indposicaocateg,
/*7.131*/ 0 vlrdescfornec,
/*7.132*/ nvl( b.vlrdescfornec, 0 ) vlrdescfornecdevol,
/*7.133*/ null tipopromocpdv,
/*7.134*/ 0 vlrfreteitemrateio,
/*7.135*/ nvl( b.vlrfreteitemrateio, 0 ) vlrfreteitemrateiodev,
/*7.136*/ 0 vlricmsstembutprod,
/*7.137*/ nvl( b.vlricmsstembutprod, 0 ) vlricmsstembutproddev,
/*7.138*/ b.seqcluster,
/*7.139*/ nvl( b.nfreferencianro, a.nfreferencianro ) nfreferencianro,
/*7.140*/ nvl( b.nfreferenciaserie, a.nfreferenciaserie ) nfreferenciaserie,
/*7.141*/ 'N' indpromocao,
/*7.142*/ 0 vlrdescacordoverbapdv,
/*7.143*/ 0 vlrdifcampanhapreco,
/*7.144*/ 0 vlrdifcampanhaprecodevol,
/*7.145*/ 0 vlrcustonfprecocamp,
/*7.146*/ null seqcampanha,
/*7.147*/ b.vlrprecomargemzero,
/*7.148*/ 0 qtddotznormal,
/*7.149*/ 0 vlrvendadotznormal,
/*7.150*/ 0 qtddotzextra,
/*7.151*/ 0 vlrvendadotzextra,
/*7.152*/ 0 qtddotztotal,
/*7.153*/ 0 vlrvendadotztotal,
/*7.154*/ 0 seqzonavenda,
/*7.155*/ 0 vlrdesccomercial,
/*7.156*/ pe.grupo grupocliente,
/*7.157*/ 0 vlritemrateiocte,
/*7.158*/ null ctenro,
/*7.159*/ null cteserie,
/*7.160*/ 0 vlrverbavdasemicus,
/*7.161*/ 0 vlrfcpst,
/*7.162*/ 0 vlrfcpicms,
/*7.163*/ 0 vlrfcpdistrib,
/*7.164*/ 0 vlrfcpstsubst,
/*7.165*/ nvl(b.vlrfcpst, 0) dvlrfcpst,
/*7.166*/ nvl(b.vlrfcpicms, 0) dvlrfcpicms,
/*7.167*/ nvl(b.vlrfcpdistrib, 0) dvlrfcpdistrib,
/*7.168*/ nvl(b.vlrfcpstsubst, 0) dvlrfcpstsubst,
/*7.169*/ 0 icmsefetivoitem,
/*7.170*/ nvl(b.vlricmsefet, 0) icmsefetivodevolitem,
/*7.171*/ pe.indcontribicms,
/*7.172*/ pe.fisicajuridica,
/*7.173*/ nvl(d.indconsumidorfinal, 'N'),
/*7.174*/ d.tipdocfiscal tipdocfiscalcgo,
/*7.175*/ null nropedidovenda,
/*7.176*/ d.tipcgo tipcgo,
/*7.177*/ 0 vlripiprecovda,
/*7.178*/ 0 vlripiprecodevol,
/*7.179*/ nvl(b.vlrdescmedalha, 0) vlrdescmedalhadevol
/* quando implementar nova coluna, tratar tambem na view "maxv_abcformapagto". manter comentario apos a ultima coluna. */
from mlf_notafiscal     a,
     mlf_nfitem         b,
     max_codgeraloper   d,
     max_empresa        e,
     mad_segmento       s,
     mad_parametro      x,
     mrl_produtoempresa m,
     ge_pessoa          pe,
     max_divisao        v
where b.numeronf         = a.numeronf
and   b.seqpessoa        = a.seqpessoa
and   b.serienf          = a.serienf
and   b.tipnotafiscal    = a.tipnotafiscal
and   b.nroempresa       = a.nroempresa
and   nvl( b.seqnf, nvl( a.seqnf, 0 ) ) = nvl( a.seqnf, 0 )
and   a.codgeraloper     = d.codgeraloper
and   x.nroempresa       = e.nroempresa
and   a.nroempresa       = e.nroempresa
and   s.nrosegmento      = nvl( b.nrosegitem, e.nrosegmentoprinc )
and   m.seqproduto       = nvl( b.seqprodutobase, b.seqproduto )
and   m.nroempresa       = nvl( e.nroempcustoabc, e.nroempresa )
and   a.tipnotafiscal    = 'E'
and   b.tipitem          = 'R'
and   d.tipcgo           = 'E'
and   b.quantidade      != 0
and   a.statusnf         = 'V'
and   d.tipdocfiscal     = 'D'
and   ( coalesce( a.geralteracaoestq, d.geralteracaoestq ) = 'S'
        or d.acmcompravenda in ( 'S', 'I' ) )
and   nvl( x.utilrefdoctodevol, 'S' ) = 'A'
and   nvl( b.nfreferencianro, a.nfreferencianro ) is null
and   a.seqpessoa        = pe.seqpessoa
and   e.nrodivisao       = v.nrodivisao
and   nvl( b.indtipodescbonif, 'I' ) != 'T'
AND nvl( a.dtahorlancto, a.dtaentrada ) >= SYSDATE - 150
AND EXISTS (SELECT 1 FROM CONSINCO.NAGT_DEPARA_VESTRH ZZ WHERE ZZ.SEQPRODUTO = B.SEQPRODUTO)
AND A.CODGERALOPER IN (60,923,914,64,102,949,210,57,948,10,941,1,927,211,814,802,801,944,811,850,942,95,261,931,240)

;
