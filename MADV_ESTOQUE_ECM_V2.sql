create or replace view consinco.madv_estoque_ecm_v2 as
select /*+optimizer_features_enable('11.2.0.4') */
         nroempresa,
       seqproduto,
       decode(sign(qtdestoque),
              -1,
              0,
              qtdestoque) qtdestoque,
       qtdestoquemin,
       dtahorultmovtoestq
from   (select b.nroempresa,
               b.seqproduto,
               case
                   when a.seqprodutobase > 0 then
                    (select CONSINCO.festoquediasecommerce(b2.nroempresa,
                                                  b2.estqdeposito,
                                                  b2.estqloja,
                                                  b2.qtdreservadavda,
                                                  b2.qtdreservadareceb,
                                                  b2.qtdreservadafixa,
                                                  b2.medvdiapromoc,
                                                  b2.medvdiaforapromoc,
                                                  b2.medvdiageral,
                                                  b2.estqsegurancaecommerce,
                                                  CONSINCO.fnroestqdiasecommercecateg(e.nrodivisao,
                                                                             a.seqfamilia))
                     from   map_produto        a2,
                            CONSINCO.mrl_produtoempresa b2
                     where  a2.seqproduto = b2.seqproduto
                     and    a2.seqproduto = a.seqprodutobase
                     and    b2.nroempresa = b.nroempresa)
                   else
                    CONSINCO.festoquediasecommerce(b.nroempresa,
                                          b.estqdeposito,
                                          b.estqloja,
                                          b.qtdreservadavda,
                                          b.qtdreservadareceb,
                                          b.qtdreservadafixa,
                                          b.medvdiapromoc,
                                          b.medvdiaforapromoc,
                                          b.medvdiageral,
                                          b.estqsegurancaecommerce,
                                          CONSINCO.fnroestqdiasecommercecateg(e.nrodivisao,
                                                                     a.seqfamilia))
               end qtdestoque,
               b.estqminimoloja qtdestoquemin,
               b.dtahorultmovtoestq
        from   CONSINCO.map_produto            a,
               CONSINCO.mrl_produtoempresa     b,
               CONSINCO.max_empresa            e
             --  CONSINCO.mad_parametroecommerce pe -- *** status da empresa ***
        where  a.seqproduto = b.seqproduto
        and    a.indintegraecommerce = 'S'
      --  and    b.nroempresa = 26
        and    b.nroempresa = e.nroempresa)
     --   and    pe.nroempresa = e.nroempresa)
;
