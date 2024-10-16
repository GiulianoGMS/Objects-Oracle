-- Pkg alterada por Giuliano, linha 402 - para considerar o produto da familia no exists

create or replace package body consinco.pkg_EncarteProduto is
    procedure Ordenacao_OnDelete(pnSeqEncarte mrl_encarteproduto.seqencarte%type,
                                 pnSeqProduto mrl_encarteproduto.seqproduto%type,
                                 pnQtdEmbalagem mrl_encarteproduto.qtdembalagem%type,
                                 pnNroPagina  mrl_encarteproduto.nropagina%type,
                                 pnSeqOrdem   mrl_encarteproduto.seqordem%type) is
      vnProd number;
    begin
        if pnSeqOrdem is not null then
            --verificar se já existe este produto em outra embalagem
            select count(1)
              into vnProd
              from mrl_encarteproduto a
             where a.seqEncarte = pnSeqEncarte
               and a.nropagina  = pnNroPagina
               and a.SeqProduto = pnSeqProduto
               and a.qtdembalagem != pnqtdEmbalagem;
            if vnProd < 1 then
                 for t in (select a.seqencarte, a.seqproduto
                             from mrl_encarteproduto a
                            where a.seqencarte = pnSeqEncarte
                              and nvl(a.nropagina, 0) = nvl(pnNroPagina, 0)
                              and a.seqordem > pnSeqOrdem
                            group by a.Seqencarte, a.Seqproduto)
                  LOOP
                      update mrl_encarteproduto a
                         set a.seqOrdem = a.seqOrdem - 1
                       where a.seqencarte = t.Seqencarte
                         and a.seqproduto = t.seqproduto;
                         --and a.qtdembalagem = t.qtdembalagem;
                  END LOOP;
             end if;
        end if;
        SalvaUltimaAlteracao(pnSeqEncarte, pnNroPagina);
    end;
    procedure Ordenacao_OnUpdate(pnSeqEncarte mrl_encarteproduto.seqencarte%type,
                                 pnNroPagina  mrl_encarteproduto.nropagina%type,
                                 pnSeqProduto mrl_encarteproduto.seqproduto%type,
                                 pnSeqOrdemAntiga mrl_encarteproduto.seqordem%type,
                                 pnSeqOrdemNova mrl_encarteproduto.seqordem%type) is
    begin
        if (pnSeqOrdemNova - pnSeqOrdemAntiga) < 0 then
             for t in (select a.seqencarte, a.seqproduto
                         from mrl_encarteproduto a
                        where a.seqencarte = pnSeqEncarte
                          and nvl(a.nropagina, 0) = nvl(pnNroPagina, 0)
                          and a.seqordem between pnSeqOrdemNova and pnSeqOrdemAntiga -1
                        group by a.Seqencarte, a.Seqproduto)
              LOOP
                  update mrl_encarteproduto a
                     set a.seqOrdem = a.seqOrdem + 1
                   where a.seqencarte = t.Seqencarte
                     and a.seqproduto = t.seqproduto;
                     --and a.qtdembalagem = t.qtdembalagem;
              END LOOP;
        elsif (pnSeqOrdemNova - pnSeqOrdemAntiga) > 0 then
             for t in (select a.seqencarte, a.seqproduto
                         from mrl_encarteproduto a
                        where a.seqencarte = pnSeqEncarte
                          and nvl(a.nropagina, 0) = nvl(pnNroPagina, 0)
                          and a.seqordem between pnSeqOrdemAntiga +1 and pnSeqOrdemNova
                        group by a.Seqencarte, a.Seqproduto)
              LOOP
                  update mrl_encarteproduto a
                     set a.seqOrdem = a.seqOrdem - 1
                   where a.seqencarte = t.Seqencarte
                     and a.seqproduto = t.seqproduto;
                     --and a.qtdembalagem = t.qtdembalagem;
              END LOOP;
        end if;
        UPDATE MRL_ENCARTEPRODUTO
             SET SEQORDEM = pnSeqOrdemNova
           WHERE SEQENCARTE = pnSeqEncarte
             AND SEQPRODUTO = pnSeqProduto;
        SalvaUltimaAlteracao(pnSeqEncarte, pnNroPagina);
    end;
    procedure Ordenacao_OnInsert(pnSeqEncarte mrl_encarteproduto.seqencarte%type,
                                 pnNroPagina  mrl_encarteproduto.nropagina%type,
                                 pnSeqProduto mrl_encarteproduto.seqproduto%type,
                                 pnQtdEmbalagem mrl_encarteproduto.qtdembalagem%type,
                                 pnSeqOrdem   mrl_encarteproduto.seqordem%type) is
       vnExistente number;
       vnOrdem  number;
       vnNovaOrdem number;
    begin
        IF pnSeqOrdem is null or pnSeqOrdem = 0 THEN
            --verificar se já existe este produto em outra embalagem
            select max(a.seqordem)
              into vnExistente
              from mrl_encarteproduto a
             where a.seqEncarte = pnSeqEncarte
               and a.nropagina  = pnNroPagina
               and a.SeqProduto = pnSeqProduto
               and a.qtdembalagem != pnqtdEmbalagem;
            if vnExistente is not null then
                vnOrdem:= vnExistente;
            else
                select max(a.seqordem)
                  into vnNovaOrdem
                  from Mrl_Encarteproduto a
                 where a.seqencarte = pnSeqEncarte
                   and a.nropagina  = pnNroPagina;
                 if vnNovaOrdem is null then
                    vnNovaOrdem := 1;
                 else
                    vnNovaOrdem := vnNovaOrdem + 1;
                 end if;
                 vnOrdem:= vnNovaOrdem;
            end if;
            update mrl_encarteproduto
               set seqOrdem     = vnOrdem
             where seqencarte   = pnSeqEncarte
               and seqproduto   = pnSeqproduto
               and qtdEmbalagem = pnqtdEmbalagem
               and nropagina    = pnNroPagina;
        end if;
        SalvaUltimaAlteracao(pnSeqEncarte, pnNroPagina);
    end;
    Procedure Ordenacao_AlteraPagina(pnSeqEncarte mrl_encarteproduto.seqencarte%type,
                                     pnSeqProduto mrl_encarteproduto.seqproduto%type,
                                     pnqtdEmbalagem mrl_encarteproduto.qtdembalagem%type,
                                     pnNroPaginaNova mrl_encarteproduto.nropagina%type) is
        vnExistente number;
        vnNovaOrdem number;
        vnOrdemAtual number;
        vnPaginaAtual number;
    begin
        SELECT Nropagina, Seqordem
          INTO vnPaginaAtual, vnOrdemAtual
          FROM Mrl_Encarteproduto
         WHERE Seqencarte   = Pnseqencarte
           AND Seqproduto   = Pnseqproduto
           AND Qtdembalagem = Pnqtdembalagem;
        if nvl(vnPaginaAtual, 0) !=  nvl(pnNroPaginaNova, 0) then
          --verificar se já existe este produto em outra embalagem
            select max(a.seqordem)
              into vnExistente
              from mrl_encarteproduto a
             where a.seqEncarte = pnSeqEncarte
               and a.nropagina  = pnNroPaginaNova
               and a.SeqProduto = pnSeqProduto
               and a.qtdembalagem != pnqtdEmbalagem;
            if vnExistente is not null then
               vnNovaOrdem := vnExistente;
            else
                select max(a.seqordem)
                  into vnNovaOrdem
                  from Mrl_Encarteproduto a
                 where a.seqencarte = pnSeqEncarte
                   and nvl(a.nropagina, 0) = nvl(pnNroPaginaNova, 0);
                 if vnNovaOrdem is null then
                    vnNovaOrdem := 1;
                 else
                    vnNovaOrdem := vnNovaOrdem + 1;
                 end if;
             end if;
             update mrl_encarteproduto
                set nroPagina    = pnNroPaginaNova,
                    seqOrdem     = vnNovaOrdem
              where seqencarte   = pnSeqEncarte
                and seqproduto   = pnSeqproduto;
                --and qtdEmbalagem = pnqtdEmbalagem;
             Ordenacao_OnDelete(pnseqencarte,  pnSeqProduto, pnqtdEmbalagem, nvl(vnPaginaAtual, 0), vnOrdemAtual);
         end if;
         SalvaUltimaAlteracao(pnSeqEncarte, nvl(pnNroPaginaNova, 0));
    end;
    Procedure Gerar_Promocao(pnSeqEncarte mrl_encarteproduto.seqencarte%type,
                             psGeraProdFam varchar2) is
       vsDiferenciaPreco Mrl_Encarte.Indprecodif%Type;
       vnSeqPromocao     mrl_promocao.seqpromocao%type;
       vsCentralLoja     max_paramgeral.centralloja%Type;
    begin
       SELECT NVL(a.indprecodif, 'N')
         INTO vsDiferenciaPreco
         FROM MRL_ENCARTE A
        WHERE A.SEQENCARTE = pnSeqEncarte;
       SELECT max(a.centralloja)
         INTO vsCentralLoja
         FROM max_paramgeral A;
        if vsDiferenciaPreco != 'N' then
            --diferencia por segmento
            if vsDiferenciaPreco = 'S' then
                   --promocões para a rede
                   for x in (SELECT DISTINCT Coalesce(a.Dtavigenciaini, g.Dtainicio) AS Data_Ini,
                                             Coalesce(a.Dtavigenciafim, g.Dtafim) AS Data_Fim
                               FROM Mrl_Encarte g, Mrl_Encarteproduto a
                              WHERE g.Seqencarte = a.Seqencarte
                                AND a.Seqencarte = pnSeqEncarte
                                and NOT exists (select 1
                                                  from mrl_encarteseg x
                                                 where x.seqencarte = g.seqencarte
                                                   and x.nrosegmento in (select distinct y.nroagrupamento
                                                                           from mrl_encarteprodutopreco y
                                                                          where y.seqencarte = x.seqencarte)))
                   LOOP
                        vnSeqPromocao:= S_SEQPROMOCAO.NEXTVAL;
                        Promoc_Inserir(pnSeqEncarte, vnSeqPromocao, x.data_ini, x.data_fim,
                                       psGeraProdFam, null, null, null, vsCentralLoja);
                   END LOOP;
                   --promocões para o segmento
                   for x in (SELECT DISTINCT Coalesce(a.Dtavigenciaini, g.Dtainicio) AS Data_Ini,
                                             Coalesce(a.Dtavigenciafim, g.Dtafim) AS Data_Fim,
                                             c.nroagrupamento
                               FROM Mrl_Encarte g, Mrl_Encarteproduto a,
                                    mrl_encarteseg B, mrl_encarteprodutopreco C
                              WHERE g.Seqencarte = a.Seqencarte
                                and b.seqencarte = a.seqencarte
                                and c.seqencarte = b.seqencarte
                                AND a.Seqencarte = pnSeqEncarte
                                and ((c.precopromoc > 0 and c.precopromoc is not null) or
                                     (a.precopromocional > 0 and a.precopromocional is not null)
                                    )
                             )
                   LOOP
                        vnSeqPromocao:= S_SEQPROMOCAO.NEXTVAL;
                        Promoc_Inserir(pnSeqEncarte, vnSeqPromocao, x.data_ini, x.data_fim,
                                       psGeraProdFam, x.nroagrupamento, null, null, vsCentralLoja);
                   END LOOP;
            end if;
            --diferencia por segmento
            if vsDiferenciaPreco = 'E' then
                   --promocões para a rede
                   for x in (SELECT DISTINCT Coalesce(a.Dtavigenciaini, g.Dtainicio) AS Data_Ini,
                                             Coalesce(a.Dtavigenciafim, g.Dtafim) AS Data_Fim
                               FROM Mrl_Encarte g, Mrl_Encarteproduto a
                              WHERE g.Seqencarte = a.Seqencarte
                                AND a.Seqencarte = pnSeqEncarte
                                AND NOT EXISTS (SELECT 1
                                                  FROM Mrl_Encarteemp  x
                                                 WHERE x.Seqencarte = a.seqencarte
                                                   AND x.Nroempresa IN (select k.nroempresa
                                                                          from max_empresaagrupamento k,
                                                                               Mrl_Encarteprodutopreco L
                                                                          where K.nroagrupamento = L.nroagrupamento
                                                                            and L.Seqencarte = x.seqencarte)))
                   LOOP
                        vnSeqPromocao:= S_SEQPROMOCAO.NEXTVAL;
                        Promoc_Inserir(pnSeqEncarte, vnSeqPromocao, x.data_ini, x.data_fim,
                                       psGeraProdFam, null, null, null, vsCentralLoja);
                   END LOOP;
                   --promocões para a empresa
                   for x in (SELECT DISTINCT Coalesce(a.Dtavigenciaini, g.Dtainicio) AS Data_Ini,
                                             Coalesce(a.Dtavigenciafim, g.Dtafim) AS Data_Fim,
                                             c.nroempresa, d.nroagrupamento
                               FROM Mrl_Encarte g, Mrl_Encarteproduto a, Mrl_Encarteemp C,
                                    mrl_encarteprodutopreco D, max_empresaagrupamento E
                              WHERE g.Seqencarte = a.Seqencarte
                                and c.seqencarte = a.seqencarte
                                and d.seqencarte = c.seqencarte
                                and d.nroagrupamento = e.nroagrupamento
                                and c.nroempresa = e.nroempresa
                                AND a.Seqencarte = pnSeqEncarte
                                and ((d.precopromoc > 0 and d.precopromoc is not null) or
                                     (a.precopromocional > 0 and a.precopromocional is not null)
                                    )
                              )
                   LOOP
                        vnSeqPromocao:= S_SEQPROMOCAO.NEXTVAL;
                        Promoc_Inserir(pnSeqEncarte, vnSeqPromocao, x.data_ini, x.data_fim,
                                       psGeraProdFam, null, x.nroempresa, x.nroagrupamento, vsCentralLoja);
                   END LOOP;
            end if;
        ELSE
        --promocao normal
           for x in (select distinct COALESCE(a.dtavigenciaini, G.dtainicio) as data_ini,
                          COALESCE(a.dtavigenciafim, G.dtafim) as Data_fim
                       from mrl_encarte g, mrl_encarteproduto a
                      where g.seqencarte = a.seqencarte
                        and a.seqencarte = pnseqEncarte)
           LOOP
                vnSeqPromocao:= S_SEQPROMOCAO.NEXTVAL;
                Promoc_Inserir(pnSeqEncarte, vnSeqPromocao, x.data_ini, x.data_fim,
                               psGeraProdFam, null, null, null, vsCentralLoja);
           END LOOP;
        end if;
    end;
    Procedure Promoc_Inserir(pnSeqEncarte mrl_encarteproduto.seqencarte%type,
                             pnSeqPromocao mrl_promocao.seqpromocao%type,
                             pdDtaIni      mrl_promocao.dtainicio%type,
                             pdDtaFim      mrl_promocao.dtafim%type,
                             psGeraProdFam varchar2,
                             pnNroSegmento mrl_promocao.nroSegmento%type,
                             pnNroEmpresa  mrl_promocao.nroEmpresa%Type,
                             pnNroAgrupamenteo mrl_encarteprodutopreco.nroagrupamento%type,
                             psCentralLoja      max_paramgeral.centralloja%type) is
       vSQL              varchar2(4000);
        tObjTP_PROMOC_INSERIR      TP_PROMOC_INSERIR;
    begin
        for t in (
            SELECT A.NROEMPRESA, C.NROSEGMENTO, NVL(psCentralLoja, b.indcentralloja) as indcentralloja, d.descricao, pdDtaIni as data_ini,
                   pdDtaFim as data_fim, d.nrodivisao, d.seqgrupopromoc, d.tipomediavda, d.seqencarte
              FROM MRL_ENCARTEEMP A, MAX_EMPRESA B, MRL_ENCARTESEG C, mrl_encarte D
             WHERE A.SEQENCARTE = pnSeqEncarte
               AND A.NROEMPRESA = B.NROEMPRESA
               AND A.SEQENCARTE = C.SEQENCARTE
               AND A.SEQENCARTE = D.SEQENCARTE
               and c.nrosegmento = case when pnNroSegmento is not null then pnNroSegmento else c.nrosegmento end
               and a.nroempresa = case when pnNroEmpresa is not null then pnNroEmpresa else a.nroEmpresa end)
        LOOP
            Insert Into Mrl_Promocao (SEQPROMOCAO,NROEMPRESA,CENTRALLOJA,NROSEGMENTO,PROMOCAO,DTAINICIO,DTAFIM,TIPOEMBPROMOCAO,
                                           INDREPLICACAO,FAIXAACRFINANCEIRO,NRODIVISAO,TIPOPROMOC,SEQGRUPOPROMOC,DTAGERACAOPROMOC,
                                           TIPOMEDIAVDA,INDSEGMENTOPRINC,SEQENCARTE, INDPREVALECEPRECO)
            Values
                                          (pnSeqPromocao,
                                           t.nroEmpresa,
                                           t.indcentralloja,
                                           t.nroSegmento,
                                           t.descricao,
                                           t.data_ini,
                                           t.data_fim,
                                           'P',
                                           'S',
                                           'A',
                                           t.NroDivisao,
                                           'N',
                                           t.seqGrupoPromoc,
                                           SYSDATE,
                                           t.tipoMediaVda,
                                           Null,
                                           t.SeqEncarte,
                                           'S');
            vSQL:=
            'INSERT INTO MRL_PROMOCAOITEM
                (SEQPRODUTO, QTDEMBALAGEM, SEQPROMOCAO,
                 NROEMPRESA, NROSEGMENTO, CENTRALLOJA,
                 PRECOPROMOCIONAL, STATUS, INDREPLICACAO,
                 USUARIO, DTAINCLUSAO, DTAGERACAO,
                 DTAINICIOPROM, DTAFIMPROM, SEQVERBA)
            SELECT  DISTINCT E.SEQPRODUTO, A.QTDEMBALAGEM, '|| pnSeqPromocao ||',
                    C.NROEMPRESA, F.NROSEGMENTO, NVL(''' || psCentralLoja || ''', H.indcentralloja),';
            if pnNroSegmento is not null then
                vSQL:= vSQL || chr(13)|| chr(10) ||
                ' COALESCE(pkg_encarteproduto.fPrecodif(a.seqEncarte,
                                               a.seqProduto,
                                               a.QtdEmbalagem, '|| pnNroSegmento ||'),
                                               A.PRECOPROMOCIONAL) ';
            elsif pnNroEmpresa is not null then
                vSQL:= vSQL || chr(13)|| chr(10) ||
                ' COALESCE(pkg_encarteproduto.fPrecodif(a.seqEncarte,
                                               a.seqProduto,
                                               a.QtdEmbalagem, '|| pnNroAgrupamenteo ||'),
                                               A.PRECOPROMOCIONAL) ';
            else
                vSQL:= vSQL || chr(13)|| chr(10) || ' A.PRECOPROMOCIONAL ';
            end if;
            vSQL:= vSQL || chr(13)|| chr(10) || '
                    , ''A'',''S'',
                    fc5_usuariosessao, SYSDATE, SYSDATE,
                    COALESCE(a.dtavigenciaini, G.dtainicio), COALESCE(a.dtavigenciafim, G.dtafim),
                    I.SEQVERBA
              FROM  MRL_ENCARTEPRODUTO A
              INNER JOIN MRL_ENCARTEEMP C ON
                    C.SEQENCARTE = A.SEQENCARTE
              INNER JOIN MAP_PRODUTO D ON
                    D.SEQPRODUTO = A.SEQPRODUTO
              INNER JOIN MAP_PRODUTO E ON
              ' ||
              case when psGeraProdFam = 'S'
                then 'E.SEQFAMILIA = D.SEQFAMILIA'
                ELSE 'E.SEQPRODUTO = D.SEQPRODUTO'
              end
              || '
              INNER JOIN MRL_ENCARTESEG F ON
                    F.SEQENCARTE = A.SEQENCARTE
              INNER JOIN MAX_EMPRESASEG B ON
                    B.NROEMPRESA = C.NROEMPRESA AND
                    B.NROSEGMENTO = F.NROSEGMENTO
              INNER JOIN MRL_ENCARTE G ON
                    G.SEQENCARTE = A.SEQENCARTE
              INNER JOIN MAX_EMPRESA H ON
                    H.NROEMPRESA = C.NROEMPRESA
              LEFT JOIN MRL_CUSTOVERBA I ON
                   I.NROEMPRESA = C.NROEMPRESA AND
                   I.SEQPRODUTO = A.SEQPRODUTO AND
                   I.SEQLOTE    = A.SEQLOTE
             WHERE  C.SEQENCARTE = '|| pnseqencarte ||'
               AND  C.NROEMPRESA = '|| t.nroempresa ||'
               AND  F.NROSEGMENTO = '|| t.nrosegmento ||'
               AND  COALESCE(a.dtavigenciaini, G.dtainicio) = :1
               AND  COALESCE(a.dtavigenciafim, G.dtafim)    = :2
               ' ||
               case when pnNroSegmento is not null
                 then 'AND B.NROSEGMENTO = '||pnNroSegmento
                 else ''
               end
               || chr(13)|| chr(10) ||
               case when pnNroEmpresa is not null
                 then 'AND C.NROEMPRESA = '||pnNroEmpresa
                 else ''
               end;
            if psGeraProdFam = 'S' then
                vSQL:= vSQL || chr(13)|| chr(10) ||
               'AND ( NOT EXISTS (  SELECT  1
                                    FROM  MRL_ENCARTEPRODUTO X
                                    WHERE X.SEQENCARTE = A.SEQENCARTE
                                    AND X.SEQPRODUTO = E.SEQPRODUTO )
                                    OR D.SEQPRODUTO = E.SEQPRODUTO ) ';
            end if;
           vSQL:= vSQL || chr(13)|| chr(10) ||
                'AND     EXISTS (SELECT 1
                                   FROM MRL_PRODEMPSEG
                                  where SEQPRODUTO = '|| -- D.SEQPRODUTO
                                  --====================================--
                                  -- Alterado por Giuliano em 01/08/2024 
                                  -- Valida se o produto da familia existe caso o flag GeraProdFam esteja marcado 
                                  CASE WHEN psGeraProdFam = 'S'
                                    THEN 'E.SEQPRODUTO '
                                      ELSE 'D.SEQPRODUTO ' END ||
                                   'AND QTDEMBALAGEM = A.QTDEMBALAGEM
                                    AND NROSEGMENTO  = F.NROSEGMENTO
                                    AND NROEMPRESA   = C.NROEMPRESA)';
           if pnNroSegmento is not null then
               vSQL:= vSQL || chr(13)|| chr(10) ||
               'AND COALESCE(pkg_encarteproduto.fPrecodif(a.seqEncarte,
                                              a.seqProduto,
                                              a.QtdEmbalagem, '|| pnNroSegmento ||'),
                                              A.PRECOPROMOCIONAL) > 0';
           elsif pnNroEmpresa is not null then
               vSQL:= vSQL || chr(13)|| chr(10) ||
               'AND COALESCE(pkg_encarteproduto.fPrecodif(a.seqEncarte,
                                              a.seqProduto,
                                              a.QtdEmbalagem, '|| pnNroAgrupamenteo ||'),
                                              A.PRECOPROMOCIONAL) > 0';
           end if;
          Execute immediate vSQL using t.data_ini, t.data_fim;
        end loop;
        tObjTP_PROMOC_INSERIR := TP_PROMOC_INSERIR(pnSeqPromocao, pnSeqEncarte); -- FSWSUP
        SP_PROMOC_INSERIRCUSTOM(tObjTP_PROMOC_INSERIR); -- FSWSUP
    end;
    function fPrecoDif(pnSeqEncarte mrl_encarteproduto.seqencarte%type,
                       pnSeqproduto mrl_encarteproduto.seqproduto%type,
                       pnQtdEmbalagem mrl_encarteproduto.qtdembalagem%type,
                       pnNroAgrupamento mrl_encarteprodutopreco.nroagrupamento%type)
     return number is
       vnPreco number;
     begin
        select a.precopromoc
          INTO vnPreco
        from mrl_encarteProdutoPreco a
        where a.seqEncarte = pnSeqEncarte
          and a.seqProduto = pnSeqproduto
          and a.qtdembalagem = pnQtdEmbalagem
          and a.nroAgrupamento = pnNroAgrupamento;
        return vnPreco;
     end;
    Procedure Gerar_RegraIncentivo(pnSeqEncarte mrl_encarteproduto.seqencarte%type,
                                   psListaNroFormaPagto varchar2,
                                   psGeraProdFam varchar2) is
      vsDiferenciaPreco Mrl_Encarte.Indprecodif%Type;
      vnSeqRegra        Mfl_Regraincentivo.Seqregra%type;
    begin
       SELECT NVL(a.indprecodif, 'N')
         INTO vsDiferenciaPreco
         FROM MRL_ENCARTE A
        WHERE A.SEQENCARTE = pnSeqEncarte;
       if vsDiferenciaPreco != 'N' then
           --regras para a rede (geral)
           for x in (SELECT DISTINCT Coalesce(a.Dtavigenciaini, g.Dtainicio) AS Data_Ini,
                                     Coalesce(a.Dtavigenciafim, g.Dtafim) AS Data_Fim
                       FROM Mrl_Encarte g, Mrl_Encarteproduto a
                      WHERE g.Seqencarte = a.Seqencarte
                        AND a.Seqencarte = pnSeqEncarte
                        and nvl(a.precocartaoproprio, 0) > 0
                        AND (NOT EXISTS (SELECT DISTINCT 1
                                           FROM Mrl_Encarteprodutopreco y
                                          WHERE y.Seqencarte = a.Seqencarte
                                            AND Nvl(y.Precocartao, 0) > 0)
                             or
                             EXISTS (SELECT DISTINCT 1
                                       FROM Mrl_Encarteprodutopreco y
                                      WHERE y.Seqencarte = a.Seqencarte
                                        AND Nvl(y.Precocartao, 0) = 0)
                             ))
           LOOP
                vnSeqRegra:= FC5SEQUENCIA('MFL_REGRAINCENTIVO');
                Regra_Inserir(pnSeqEncarte, vnSeqRegra, x.data_ini, x.data_fim,
                               psListaNroFormaPagto, vsDiferenciaPreco, 'S', null, psGeraProdFam);
           END LOOP;
            --diferencia por segmento
            if vsDiferenciaPreco = 'S' then
                   --regras para o segmento
                   for x in (SELECT DISTINCT Coalesce(a.Dtavigenciaini, g.Dtainicio) AS Data_Ini,
                                             Coalesce(a.Dtavigenciafim, g.Dtafim) AS Data_Fim,
                                             c.nroagrupamento
                               FROM Mrl_Encarte g, Mrl_Encarteproduto a,
                                    mrl_encarteseg B, mrl_encarteprodutopreco C
                              WHERE g.Seqencarte = a.Seqencarte
                                and b.seqencarte = a.seqencarte
                                and c.seqencarte = b.seqencarte
                                AND a.Seqencarte = pnSeqEncarte
                                and nvl(c.precocartao, 0) > 0)
                   LOOP
                        vnSeqRegra:= FC5SEQUENCIA('MFL_REGRAINCENTIVO');
                        Regra_Inserir(pnSeqEncarte, vnSeqRegra, x.data_ini, x.data_fim,
                                       psListaNroFormaPagto, vsDiferenciaPreco,
                                       'N', x.nroagrupamento, psGeraProdFam);
                   END LOOP;
            --diferencia por empresa
            elsif vsDiferenciaPreco = 'E' then
                   --regras para a empresa
                   for x in (SELECT DISTINCT Coalesce(a.Dtavigenciaini, g.Dtainicio) AS Data_Ini,
                                             Coalesce(a.Dtavigenciafim, g.Dtafim) AS Data_Fim,
                                             d.nroagrupamento
                               FROM Mrl_Encarte g, Mrl_Encarteproduto a, Mrl_Encarteemp C,
                                    mrl_encarteprodutopreco D, max_empresaagrupamento E
                              WHERE g.Seqencarte = a.Seqencarte
                                and c.seqencarte = a.seqencarte
                                and d.seqencarte = c.seqencarte
                                and d.nroagrupamento = e.nroagrupamento
                                and c.nroempresa = e.nroempresa
                                AND a.Seqencarte = pnSeqEncarte
                                and NVL(d.precocartao, 0) > 0)
                   LOOP
                        vnSeqRegra:= FC5SEQUENCIA('MFL_REGRAINCENTIVO');
                        Regra_Inserir(pnSeqEncarte, vnSeqRegra, x.data_ini, x.data_fim,
                                       psListaNroFormaPagto, vsDiferenciaPreco,
                                       'N', x.nroagrupamento, psGeraProdFam);
                   END LOOP;
            end if;
          ELSE
          --regra normal (geral)
             for x in (select distinct COALESCE(a.dtavigenciaini, G.dtainicio) as data_ini,
                            COALESCE(a.dtavigenciafim, G.dtafim) as Data_fim
                         from mrl_encarte g, mrl_encarteproduto a
                        where g.seqencarte = a.seqencarte
                          and a.seqencarte = pnseqEncarte
                          and NVL(a.precocartaoproprio, 0) > 0)
             LOOP
                  vnSeqRegra:= FC5SEQUENCIA('MFL_REGRAINCENTIVO');
                  Regra_Inserir(pnSeqEncarte, vnSeqRegra, x.data_ini, x.data_fim,
                                         psListaNroFormaPagto, vsDiferenciaPreco, 'S', null, psGeraProdFam);
             END LOOP;
          end if;
    end;
    Procedure Regra_Inserir(pnSeqEncarte   mrl_encarteproduto.seqencarte%type,
                             pnSeqRegra    Mfl_Regraincentivo.Seqregra%type,
                             pdDtaIni      Mfl_Regraincentivo.dtainicio%type,
                             pdDtaFim      Mfl_Regraincentivo.Dtafim%type,
                             psListaNroFormaPagto varchar2,
                             psTipoAgrupamento varchar2,
                             psRegraGeral      varchar2,
                             pnNroAgrupamento mrl_encarteprodutopreco.nroagrupamento%type,
                             psGeraProdFam varchar2) is
      vnInseriuCabecalho integer;
      vsSQL varchar2(4000);
    begin
      -- psTipoAgrupamento = N - Não Agrupa / S - Segmento / E - Grupo de empresas
      -- psRegraGeral = S - Aplicável a todas empresas/segmentos do encarte (que nao tenham preço especifico no agrupamento)
      --                N - apenas ao agrupamento selecionado
        for t in (
            SELECT d.descricao, d.nroempresabase, fc5_usuariosessao as usualteracao
              FROM mrl_encarte D
             WHERE D.SEQENCARTE = pnSeqEncarte)
        LOOP
            --cabeçalho da regra
            INSERT INTO Mfl_Regraincentivo
              (Mfl_Regraincentivo.Descricao, Mfl_Regraincentivo.Seqregra,
               Mfl_Regraincentivo.Dtainicio, Mfl_Regraincentivo.Dtafim,
               Mfl_Regraincentivo.Vlrminimo, Mfl_Regraincentivo.Vlrmaximo,
               Mfl_Regraincentivo.Qtdminproduto, Mfl_Regraincentivo.Indqtdeconsiderar,
               Mfl_Regraincentivo.Percincentivo, Mfl_Regraincentivo.Prazoadicional,
               Mfl_Regraincentivo.Usualteracao, Mfl_Regraincentivo.Dttalteracao,
               Mfl_Regraincentivo.Acumulaponto, Mfl_Regraincentivo.Indverificalista,
               Mfl_Regraincentivo.Indapenasmarca, Mfl_Regraincentivo.Indprazomaxcli,
               Mfl_Regraincentivo.Tiporegra, Mfl_Regraincentivo.Tipoaplicacao,
               Mfl_Regraincentivo.Tipoverificacao, Mfl_Regraincentivo.Indreplicacao,
               Mfl_Regraincentivo.Indgeroureplicacao, Mfl_Regraincentivo.Status,
               Mfl_Regraincentivo.Tipofaturamento, Mfl_Regraincentivo.Geradesconto,
               Mfl_Regraincentivo.Tipoverifqtde, Mfl_Regraincentivo.Indaplicasugere,
               Mfl_Regraincentivo.Tipoverifprod, Mfl_Regraincentivo.Tipoverifcli,
               Mfl_Regraincentivo.Tipodescproduto, Mfl_Regraincentivo.Nroacordo,
               Mfl_Regraincentivo.Nroempresaacordo,
               Mfl_Regraincentivo.Indutilcssemacordo, Mfl_Regraincentivo.Nroempresa,
               Mfl_Regraincentivo.Seqencarte)
            VALUES
              (t.descricao, pnSeqRegra, pdDtaIni, pdDtaFim,
               '0', '0', '0', 'A', '0', '0', t.usualteracao, sysdate, 'N', 'N',
               'N', 'N', 'F', 'V', 'E', 'S', NULL, 'A', 'T', 'S', 'I', NULL, 'T', NULL,
               'N', NULL, NULL, 'S', t.nroempresabase, pnSeqEncarte);
            vnInseriuCabecalho:= sql%rowcount;
            if vnInseriuCabecalho > 0 then
                --forma de pagamento
                vsSQL := '
                INSERT INTO Mad_Regraformapagto
                  (Mad_Regraformapagto.Seqregra, Mad_Regraformapagto.Nroformapagto,
                   Mad_Regraformapagto.Status, Mad_Regraformapagto.Usualteracao,
                   Mad_Regraformapagto.Dtaalteracao, Mad_Regraformapagto.Indreplicacao)
                SELECT :1, A.NROFORMAPAGTO, ''A'', :2, SYSDATE, ''S''
                FROM   MRL_FORMAPAGTO A
                WHERE  A.NROFORMAPAGTO in ('|| psListaNroFormaPagto || ')';
                Execute immediate vsSQL using pnSeqRegra, T.USUALTERACAO;
            end if;
        end loop;
        if vnInseriuCabecalho > 0 then
            --Segmentos
            if psTipoAgrupamento = 'S' then
                if psRegraGeral = 'S' then
                    for t in (
                      SELECT c.nrosegmento, fc5_usuariosessao as usualteracao
                        FROM MRL_ENCARTE A, MRL_ENCARTESEG C
                      WHERE A.SEQENCARTE = pnSeqEncarte
                        and a.seqencarte = c.seqencarte
                        and c.nrosegmento not in (select distinct y.nroagrupamento
  			                                            from mrl_encarteprodutopreco y
			                                             where y.seqencarte = a.seqencarte
                                                     and NVL(y.precocartao, 0) > 0))
                    LOOP
                        INSERT INTO Mad_Regrasegmento
                          (Seqregra, Nrosegmento, Status, Usualteracao, Dtaalteracao, Indreplicacao)
                        VALUES
                           (pnSeqRegra, t.nrosegmento, 'A', t.usualteracao, sysdate, 'S');
                    END loop;
                else
                    INSERT INTO Mad_Regrasegmento
                      (Seqregra, Nrosegmento, Status, Usualteracao, Dtaalteracao, Indreplicacao)
                    VALUES
                       (pnSeqRegra, pnNroAgrupamento, 'A', fc5_usuariosessao, sysdate, 'S');
                end if;
            else
                for s in (
                  SELECT c.nrosegmento, fc5_usuariosessao as usualteracao
                    FROM MRL_ENCARTE A, MRL_ENCARTESEG C
                  WHERE A.SEQENCARTE = pnSeqEncarte
                    and a.seqencarte = c.seqencarte)
                LOOP
                    INSERT INTO Mad_Regrasegmento
                      (Seqregra, Nrosegmento, Status, Usualteracao, Dtaalteracao, Indreplicacao)
                    VALUES
                       (pnSeqRegra, s.nrosegmento, 'A', s.usualteracao, sysdate, 'S');
                END loop;
            end if;
            --empresas
            if psTipoAgrupamento = 'E' then
                if psRegraGeral = 'S' then
                    for e in (
                      SELECT c.nroEmpresa, fc5_usuariosessao as usualteracao
                        FROM MRL_ENCARTE A, MRL_ENCARTEEMP C
                      WHERE A.SEQENCARTE = pnSeqEncarte
                        and a.seqencarte = c.seqencarte
                        and c.nroempresa not in (select k.nroempresa
                                               from max_empresaagrupamento k
                                              where K.nroagrupamento = (select distinct y.nroagrupamento
  			                                                                  from mrl_encarteprodutopreco y
			                                                                   where y.seqencarte = a.seqencarte
                                                                           and NVL(y.precocartao, 0) > 0)))
                    LOOP
                        INSERT INTO Mad_Regraempresa
                          (Seqregra, Nroempresa,
                           Status, Usualteracao,
                           Dtaalteracao, Indreplicacao)
                        VALUES
                          (pnSeqRegra, e.nroempresa, 'A', e.usualteracao, sysdate, 'S');
                    END loop;
                else
                    for e in (
                      SELECT c.nroEmpresa, fc5_usuariosessao as usualteracao
                        FROM MRL_ENCARTE A, MRL_ENCARTEEMP C
                      WHERE A.SEQENCARTE = pnSeqEncarte
                        and a.seqencarte = c.seqencarte
                        and c.nroempresa in (select k.nroempresa
                                               from max_empresaagrupamento k
                                              where K.nroagrupamento = pnNroAgrupamento))
                    LOOP
                        INSERT INTO Mad_Regraempresa
                          (Seqregra, Nroempresa,
                           Status, Usualteracao,
                           Dtaalteracao, Indreplicacao)
                        VALUES
                          (pnSeqRegra, e.nroempresa, 'A', e.usualteracao, sysdate, 'S');
                    END loop;
                end if;
            else
                for e in (
                  SELECT c.nroEmpresa, fc5_usuariosessao as usualteracao
                    FROM MRL_ENCARTE A, MRL_ENCARTEEMP C
                  WHERE A.SEQENCARTE = pnSeqEncarte
                    and a.seqencarte = c.seqencarte)
                LOOP
                    INSERT INTO Mad_Regraempresa
                      (Seqregra, Nroempresa,
                       Status, Usualteracao,
                       Dtaalteracao, Indreplicacao)
                    VALUES
                      (pnSeqRegra, e.nroempresa, 'A', e.usualteracao, sysdate, 'S');
                END loop;
            end if;
            --Produtos
            if psTipoAgrupamento in ('S', 'E') then
                if psRegraGeral = 'S' then
                    INSERT INTO Mfl_Regraprodutopdv
                      (Seqproduto, Seqregra, Qtdembalagem,
                       Precobase, Indreplicacao, Status,
                       Usualtprecobase, Dtaaltprecobase)
                    Select b.seqproduto, pnSeqRegra, b.qtdembalagem,
                           b.precocartaoproprio, 'S', 'A', fc5_usuariosessao, sysdate
                      from mrl_encarte a,
                           mrl_encarteproduto b
                     where a.seqencarte = b.seqencarte
                       and a.seqencarte = pnSeqEncarte
                       and nvl(b.precocartaoproprio, 0) > 0
                       AND (NOT EXISTS (SELECT DISTINCT 1
                                                     FROM Mrl_Encarteprodutopreco y
                                                    WHERE y.Seqencarte = a.Seqencarte
                                                      AND Nvl(y.Precocartao, 0) > 0)
                            or
                            EXISTS (SELECT DISTINCT 1
                                      FROM Mrl_Encarteprodutopreco y
                                     WHERE y.Seqencarte = a.Seqencarte
                                       AND Nvl(y.Precocartao, 0) = 0)
                            );
                    --produtos da familia
                    if psGeraProdFam = 'S' then
                        INSERT INTO Mfl_Regraprodutopdv
                          (Seqproduto, Seqregra, Qtdembalagem,
                           Precobase, Indreplicacao, Status,
                           Usualtprecobase, Dtaaltprecobase)
                        Select DISTINCT d.seqproduto, pnSeqRegra, b.qtdembalagem,
                               b.precocartaoproprio, 'S', 'A', fc5_usuariosessao, sysdate
                          from mrl_encarte        a,
                               mrl_encarteproduto b,
                               map_produto        c,
                               map_produto        d
                         where a.seqencarte = b.seqencarte
                           and a.seqencarte = pnSeqEncarte
                           and b.seqproduto = c.seqproduto
                           and c.seqfamilia = d.seqfamilia
                           and nvl(b.precocartaoproprio, 0) > 0
                           and (NOT EXISTS (SELECT DISTINCT 1
                                                     FROM Mrl_Encarteprodutopreco y
                                                    WHERE y.Seqencarte = a.Seqencarte
                                                      AND Nvl(y.Precocartao, 0) > 0)
                                or
                                EXISTS (SELECT DISTINCT 1
                                          FROM Mrl_Encarteprodutopreco y
                                         WHERE y.Seqencarte = a.Seqencarte
                                           AND Nvl(y.Precocartao, 0) = 0))
                           and not exists (select 1
                                             from Mfl_Regraprodutopdv r
                                            where r.seqregra = pnSeqRegra
                                              and r.seqproduto = d.seqproduto
                                              and r.qtdembalagem = b.qtdembalagem)
                           and EXISTS (select 1
                                         from mrl_prodempseg f
                                        where f.seqproduto = d.seqproduto
                                          and f.qtdembalagem = b.qtdembalagem
                                          and f.nroempresa in (select ee.nroempresa
                                                                 from Mad_Regraempresa ee
                                                                where ee.seqregra = pnSeqRegra)
                                          and f.nrosegmento in (select ss.nrosegmento
                                                                  from Mad_Regrasegmento ss
                                                                 where ss.seqregra = pnSeqRegra));
                    end if;
                else
                    INSERT INTO Mfl_Regraprodutopdv
                      (Seqproduto, Seqregra, Qtdembalagem,
                       Precobase, Indreplicacao, Status,
                       Usualtprecobase, Dtaaltprecobase)
                    Select b.seqproduto, pnSeqRegra, b.qtdembalagem,
                           c.precocartao, 'S', 'A', fc5_usuariosessao, sysdate
                      from mrl_encarte a,
                           mrl_encarteproduto b,
                           mrl_encarteprodutopreco c
                     where a.seqencarte = b.seqencarte
                       and b.seqencarte = c.seqencarte
                       and b.seqproduto = c.seqproduto
                       and b.qtdembalagem = c.qtdembalagem
                       and a.seqencarte = pnSeqEncarte
                       and c.nroagrupamento = pnNroAgrupamento
                       and nvl(c.precocartao, 0) > 0;
                    --produtos da familia
                    if psGeraProdFam = 'S' then
                        INSERT INTO Mfl_Regraprodutopdv
                          (Seqproduto, Seqregra, Qtdembalagem,
                           Precobase, Indreplicacao, Status,
                           Usualtprecobase, Dtaaltprecobase)
                        Select distinct e.seqproduto, pnSeqRegra, b.qtdembalagem,
                               c.precocartao, 'S', 'A', fc5_usuariosessao, sysdate
                          from mrl_encarte a,
                               mrl_encarteproduto b,
                               mrl_encarteprodutopreco c,
                               map_produto d,
                               map_produto e
                         where a.seqencarte = b.seqencarte
                           and b.seqencarte = c.seqencarte
                           and b.seqproduto = c.seqproduto
                           and b.qtdembalagem = c.qtdembalagem
                           and d.seqproduto = c.seqproduto
                           and e.seqfamilia = d.seqfamilia
                           and a.seqencarte = pnSeqEncarte
                           and c.nroagrupamento = pnNroAgrupamento
                           and nvl(c.precocartao, 0) > 0
                           and not exists (select 1
                                             from Mfl_Regraprodutopdv r
                                            where r.seqregra = pnSeqRegra
                                              and r.seqproduto = e.seqproduto
                                              and r.qtdembalagem = b.qtdembalagem)
                           and EXISTS (select 1
                                         from mrl_prodempseg f
                                        where f.seqproduto = e.seqproduto
                                          and f.qtdembalagem = b.qtdembalagem
                                          and f.nroempresa in (select ee.nroempresa
                                                                 from Mad_Regraempresa ee
                                                                where ee.seqregra = pnSeqRegra)
                                          and f.nrosegmento in (select ss.nrosegmento
                                                                  from Mad_Regrasegmento ss
                                                                 where ss.seqregra = pnSeqRegra));
                    end if;
                end if;
            else
                INSERT INTO Mfl_Regraprodutopdv
                  (Seqproduto, Seqregra, Qtdembalagem,
                   Precobase, Indreplicacao, Status,
                   Usualtprecobase, Dtaaltprecobase)
                Select b.seqproduto, pnSeqRegra, b.qtdembalagem,
                       b.precocartaoproprio, 'S', 'A', fc5_usuariosessao, sysdate
                  from mrl_encarte a,
                       mrl_encarteproduto b
                 where a.seqencarte = b.seqencarte
                   and a.seqencarte = pnSeqEncarte
                   and nvl(b.precocartaoproprio, 0) > 0;
                --produtos da familia
                if psGeraProdFam = 'S' then
                    INSERT INTO Mfl_Regraprodutopdv
                      (Seqproduto, Seqregra, Qtdembalagem,
                       Precobase, Indreplicacao, Status,
                       Usualtprecobase, Dtaaltprecobase)
                    Select DISTINCT d.seqproduto, pnSeqRegra, b.qtdembalagem,
                           b.precocartaoproprio, 'S', 'A', fc5_usuariosessao, sysdate
                      from mrl_encarte        a,
                           mrl_encarteproduto b,
                           map_produto        c,
                           map_produto        d
                     where a.seqencarte = b.seqencarte
                       and a.seqencarte = pnSeqEncarte
                       and b.seqproduto = c.seqproduto
                       and c.seqfamilia = d.seqfamilia
                       and nvl(b.precocartaoproprio, 0) > 0
                       and not exists (select 1
                                         from Mfl_Regraprodutopdv r
                                        where r.seqregra = pnSeqRegra
                                          and r.seqproduto = d.seqproduto
                                          and r.qtdembalagem = b.qtdembalagem)
                       and EXISTS (select 1
                                     from mrl_prodempseg f
                                    where f.seqproduto = d.seqproduto
                                      and f.qtdembalagem = b.qtdembalagem
                                      and f.nroempresa in (select ee.nroempresa
                                                             from Mad_Regraempresa ee
                                                            where ee.seqregra = pnSeqRegra)
                                      and f.nrosegmento in (select ss.nrosegmento
                                                              from Mad_Regrasegmento ss
                                                             where ss.seqregra = pnSeqRegra));
                end if;
            end if;
            Regra_InsereLixo(pnSeqRegra);
        end if;
    end;
    procedure Regra_InsereLixo(pnSeqRegra Mfl_Regraincentivo.Seqregra%type) is
      vsUsuario varchar2(12);
    begin
      -- tem a finalidade de inserir os dados necessários para a correta exibição da regra na aplicação de cadastro da regra de incentivo
      vsUsuario:= fc5_usuariosessao;
      INSERT INTO Mad_Regraformapagto
        (Mad_Regraformapagto.Seqregra, Mad_Regraformapagto.Nroformapagto,
        Mad_Regraformapagto.Status, Mad_Regraformapagto.Usualteracao,
        Mad_Regraformapagto.Dtaalteracao, Mad_Regraformapagto.Indreplicacao)
      SELECT pnSeqRegra, a.nroformapagto, 'I', vsUsuario, sysdate, 'S'
        FROM MRL_FORMAPAGTO a
       where NOT EXISTS (select 1
                           from Mad_Regraformapagto b
                          where b.seqregra = pnSeqRegra
                            and b.nroformapagto = a.nroformapagto);
      INSERT INTO Mad_Regrasegmento
        (Mad_Regrasegmento.Seqregra, Mad_Regrasegmento.Nrosegmento,
         Mad_Regrasegmento.Status, Mad_Regrasegmento.Usualteracao,
         Mad_Regrasegmento.Dtaalteracao, Mad_Regrasegmento.Indreplicacao)
      SELECT pnSeqRegra, a.nrosegmento, 'I', vsUsuario, sysdate, 'S'
        FROM mad_segmento a
       where NOT EXISTS (select 1
                           from Mad_Regrasegmento b
                          where b.seqregra = pnSeqRegra
                            and b.nrosegmento = a.nrosegmento);
      INSERT INTO Mad_Regraempresa
        (Mad_Regraempresa.Seqregra, Mad_Regraempresa.Nroempresa,
         Mad_Regraempresa.Status, Mad_Regraempresa.Usualteracao,
         Mad_Regraempresa.Dtaalteracao, Mad_Regraempresa.Indreplicacao)
      SELECT pnSeqRegra, a.nroempresa, 'I', vsUsuario, sysdate, 'S'
        FROM max_empresa a
       where NOT EXISTS (select 1
                           from Mad_Regraempresa b
                          where b.nroempresa = a.nroempresa
                            and b.seqregra = pnSeqRegra);
    end;
    procedure Gerar_CotacaoConc( pnSeqEncarte in integer,
                                           psCotacaoOk  out varchar2) is
    vsPD_ListaPorEmpresa   MAX_PARAMETRO.VALOR%TYPE;
    vnLista                mrl_cotlista.seqlista%type;
    vnConcorrente          integer;
    begin
         vnLista := null;
         sp_buscaparamdinamico( 'COT_LISTA', 0,'LISTA_POR_EMPRESA','S','S',
                                'UTILIZA CONCEITO DE LISTA DE COTAÇÃO CONCORRENTE POR EMPRESA.' || CHR(13) || CHR(10) ||
                                'S-SIM' || CHR(13) || CHR(10) ||
                                'N-NÃO (PADRÃO)', vsPD_ListaPorEmpresa);
        for VT1 in (SELECT a.nroempresa,
                           b.indcentralloja
                    FROM   mrl_encarteemp a, max_empresa b
                    WHERE  a.nroempresa = b.nroempresa
                    AND    a.seqencarte = pnSeqEncarte)
        loop
          --Verifica se a empresa tem concorrente cadastrado
          SELECT COUNT(1)
          into   vnConcorrente
          FROM   mrl_concorrenteempresa a
          WHERE  a.nroempresa = vt1.nroempresa;
          if vnConcorrente > 0 then
              if vsPD_ListaPorEmpresa = 'S' or vnLista is null then
                Select NVL(MAX( SEQLISTA ),0)  + 1
                Into   vnLista
                from   MRL_COTLISTA;
                psCotacaoOk := 'OK';
              end if;
              --Cria a lista
              insert into mrl_cotlista (seqlista, seqencarte, nroempresa, centralloja,
                                        listacotconcor, status,
                                        eventoconcorrente, indreplicacao, indgeroureplicacao)
              values (vnLista, pnSeqEncarte, VT1.nroempresa, VT1.indcentralloja,
                      'Gerado pelo Encarte: ' || TO_CHAR(pnSeqEncarte) , 'A',
                      null,'S',null);
               --Concorrentes da empresa
               insert into mrl_cotconcorrente (seqlista, nroempresa, centralloja, seqconcorrente, status)
               select vnLista, vt1.nroempresa, vt1.indcentralloja, a.seqconcorrente, 'A'
               from   mrl_concorrenteempresa a
               where  a.nroempresa = vt1.nroempresa;
               --Itens do Encarte
               insert into mrl_cotlistaitem (seqfamilia, nroempresa, centralloja, seqlista,
                                               status, indreplicacao, indgeroureplicacao)
               select  distinct b.seqfamilia, vt1.nroempresa, vt1.indcentralloja, vnlista,
                      'A', 'S', null
               from   mrl_encarteproduto a, map_produto b
               where  a.seqproduto = b.seqproduto
               and    a.seqencarte = pnSeqEncarte;
            end if;
        end loop;
    exception
        when others then
             psCotacaoOk := NULL;
             RAISE_APPLICATION_ERROR(-20200, sqlerrm);
    end Gerar_CotacaoConc;
    procedure CotacaoConc_Importar(pnSeqEncarte mrl_encarte.seqencarte%type) is
        vnPrecoConc number;
        vnExisteProd number;
        vsDiferenciaPreco Mrl_Encarte.Indprecodif%Type;
    begin
       SELECT NVL(a.indprecodif, 'N')
         INTO vsDiferenciaPreco
         FROM MRL_ENCARTE A
        WHERE A.SEQENCARTE = pnSeqEncarte;
        if vsDiferenciaPreco = 'E' then
            FOR t in (select a.seqencarte, a.seqproduto,
                             b.seqfamilia, a.qtdembalagem,
                             d.nroagrupamento
                        from mrl_encarteproduto a,
                             map_produto        b,
                             mrl_encarteemp     c,
                             max_empresaagrupamento d
                       where a.seqproduto = b.seqproduto
                         and a.seqencarte = c.seqencarte
                         and c.nroempresa = d.nroempresa
                         and a.seqencarte = pnSeqEncarte
                       group by a.seqencarte,
                                a.seqproduto,
                                b.seqfamilia,
                                a.qtdembalagem,
                                d.nroagrupamento
                       order by a.seqencarte, a.seqproduto, a.qtdembalagem, d.nroagrupamento)
            LOOP
                --antes de iniciar, limpa valores importados anteriormente
                UPDATE Mrl_Encarteprodutopreco a
                   SET a.Precoconcorrente = null
                 WHERE a.Seqencarte       = t.Seqencarte
                   AND a.Seqproduto       = t.Seqproduto
                   AND a.Qtdembalagem     = t.Qtdembalagem
                   AND a.Nroagrupamento   = t.Nroagrupamento;
                --busca valor do concorrente para este produto
                begin
                    select MIN(NVL(a.vlrprecopraticado, 0))
                      INTO vnPrecoConc
                      from mrl_cotacao a,
                           mrl_cotlista b
                     where a.seqlista = b.seqlista
                       and b.seqencarte = t.seqencarte
                       and a.seqfamilia = t.seqfamilia
                       and a.qtdembpreco = t.qtdembalagem
                       and b.status = 'A'
                       and a.dtavalidade >= trunc(sysdate)
                       and a.nroempresa in (select x.nroempresa
                                              from max_empresaagrupamento x
                                             where x.nroagrupamento = t.nroagrupamento);
                exception
                  when no_data_found then
                    vnPrecoConc:= 0;
                end;
                if vnPrecoConc > 0 then
                    --verifica se ja existe o registro na tabela de preços
                    begin
                      select MAX(1)
                        into vnExisteProd
                        from mrl_encarteprodutopreco a
                       where a.seqencarte = t.seqEncarte
                         and a.seqproduto = t.seqproduto
                         and a.qtdembalagem = t.qtdembalagem
                         and a.nroagrupamento = t.nroagrupamento;
                    exception
                      when no_data_found then
                        vnExisteProd:= 0;
                    end;
                    if vnExisteProd > 0 then
                      UPDATE Mrl_Encarteprodutopreco a
                         SET a.Precoconcorrente = Vnprecoconc
                       WHERE a.Seqencarte       = t.Seqencarte
                         AND a.Seqproduto       = t.Seqproduto
                         AND a.Qtdembalagem     = t.Qtdembalagem
                         AND a.Nroagrupamento   = t.Nroagrupamento;
                    else
                      INSERT into mrl_encarteprodutopreco (seqencarte,
                                                           seqproduto,
                                                           qtdembalagem,
                                                           nroagrupamento,
                                                           precoconcorrente)
                      VALUES(                              t.seqencarte,
                                                           t.seqproduto,
                                                           t.qtdembalagem,
                                                           t.nroagrupamento,
                                                           vnPrecoConc);
                    end if;
                end if;
            END LOOP;
        else
            FOR t in (select a.seqencarte, a.seqproduto,
                             b.seqfamilia, a.qtdembalagem
                        from mrl_encarteproduto a,
                             map_produto        b
                       where a.seqproduto = b.seqproduto
                         and a.seqencarte = pnSeqEncarte
                       group by a.seqencarte,
                                a.seqproduto,
                                b.seqfamilia,
                                a.qtdembalagem
                       order by a.seqencarte, a.seqproduto, a.qtdembalagem)
            LOOP
                --antes de iniciar, limpa valores importados anteriormente
                UPDATE Mrl_Encarteproduto a
                   SET a.Precoconcorrente = null
                 WHERE a.Seqencarte       = t.Seqencarte
                   AND a.Seqproduto       = t.Seqproduto
                   AND a.Qtdembalagem     = t.Qtdembalagem;
                --busca valor do concorrente para este produto
                begin
                    select MIN(NVL(a.vlrprecopraticado, 0))
                      INTO vnPrecoConc
                      from mrl_cotacao a,
                           mrl_cotlista b
                     where a.seqlista = b.seqlista
                       and b.seqencarte = t.seqencarte
                       and a.seqfamilia = t.seqfamilia
                       and a.qtdembpreco = t.qtdembalagem
                       and b.status = 'A'
                       and a.dtavalidade >= trunc(sysdate);
                exception
                  when no_data_found then
                    vnPrecoConc:= 0;
                end;
                if vnPrecoConc > 0 then
                    UPDATE Mrl_EncarteProduto a
                       SET a.Precoconcorrente = Vnprecoconc
                     WHERE a.Seqencarte       = t.Seqencarte
                       AND a.Seqproduto       = t.Seqproduto
                       AND a.Qtdembalagem     = t.Qtdembalagem;
                end if;
            END LOOP;
        end if;
        --ATUALIZA HORA DE IMPORTACAO
        UPDATE MRL_ENCARTE
           SET DTAHORIMPORTCOTACAO = SYSDATE,
               USUIMPORTCOTACAO    = fc5_usuariosessao
         WHERE SEQENCARTE          = pnSeqEncarte;
    end CotacaoConc_Importar;
    procedure CotacaoConc_AcatarPrecoConc(pnSeqEncarte mrl_encarte.seqEncarte%Type,
                                          pnNroPagina mrl_encarteproduto.nropagina%type default null) is
        vsDiferenciaPreco Mrl_Encarte.Indprecodif%Type;
    begin
       SELECT NVL(a.indprecodif, 'N')
         INTO vsDiferenciaPreco
         FROM MRL_ENCARTE A
        WHERE A.SEQENCARTE = pnSeqEncarte;
       if vsDiferenciaPreco = 'E' then
          for t in (SELECT a.SEQENCARTE,
                           C.SEQPRODUTO,
                           C.QTDEMBALAGEM,
                           C.NROAGRUPAMENTO,
                           C.PRECOCONCORRENTE,
                           B.PRECOPROMOCIONAL
                      FROM MRL_ENCARTE A,
                           MRL_ENCARTEPRODUTO B,
                           MRL_ENCARTEPRODUTOPRECO C
                     WHERE A.SEQENCARTE    = B.SEQENCARTE
                        AND B.SEQENCARTE   = C.SEQENCARTE
                        AND B.SEQPRODUTO   = C.SEQPRODUTO
                        AND B.QTDEMBALAGEM = C.QTDEMBALAGEM
                        and C.PRECOCONCORRENTE is not null
                        AND A.SEQENCARTE   = pnSeqEncarte
                        AND b.nropagina = NVL(pnNroPagina, b.nropagina))
          LOOP
            if t.precoconcorrente < t.precopromocional or t.precopromocional = 0 then
                update MRL_ENCARTEPRODUTOPRECO a
                   set a.precopromoc = t.precoconcorrente
                 where a.seqencarte = t.seqencarte
                   and a.seqproduto = t.seqproduto
                   and a.qtdembalagem = t.qtdembalagem
                   and a.nroagrupamento = t.nroagrupamento;
            end if;
          END LOOP;
       else
          for t in (SELECT a.SEQENCARTE,
                           B.SEQPRODUTO,
                           B.QTDEMBALAGEM,
                           B.PRECOCONCORRENTE,
                           B.PRECOPROMOCIONAL
                      FROM MRL_ENCARTE A,
                           MRL_ENCARTEPRODUTO B
                     WHERE A.SEQENCARTE    = B.SEQENCARTE
                        and b.precoconcorrente is not null
                        AND A.SEQENCARTE   = pnSeqEncarte
                        AND b.nropagina = NVL(pnNroPagina, b.nropagina))
          LOOP
            if t.precoconcorrente < t.PRECOPROMOCIONAL or t.precopromocional = 0 then
                update MRL_ENCARTEPRODUTO a
                   set a.PRECOPROMOCIONAL = t.precoconcorrente
                 where a.seqencarte = t.seqencarte
                   and a.seqproduto = t.seqproduto
                   and a.qtdembalagem = t.qtdembalagem;
            end if;
          END LOOP;
       end if;
    end CotacaoConc_AcatarPrecoConc;
    procedure SalvaUltimaAlteracao( pnSeqEncarte mrl_encartenomepag.seqencarte%type,
                                    pnNroPagina  mrl_encartenomepag.nropagina%type ) is
    begin
       UPDATE MRL_ENCARTENOMEPAG A
          SET A.DTAHORAALTORDEM = SYSDATE,
              A.USUALTORDEM = fc5_usuariosessao
        WHERE A.SEQENCARTE = pnSeqEncarte
          AND A.NROPAGINA = pnNroPagina;
    end SalvaUltimaAlteracao;
end pkg_EncarteProduto;
