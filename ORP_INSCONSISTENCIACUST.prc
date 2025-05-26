CREATE OR REPLACE PROCEDURE ORP_INSCONSISTENCIACUST(pnSeqNota IN OR_NFDESPESA.SEQNOTA%TYPE,
                                                             pnOk      IN OUT NUMBER) IS

    vnEmpresa or_nfdespesa.nroempresa%type;
    vnPessoa or_nfdespesa.seqpessoa%type;
    vnNcmFamilia map_familia.codnbmsh%type;
    vsParamFornecedor maf_fornecdivisao.indconsistencmxml%type;
    vsInconsistenciaProduto or_inconsist_import_xml.motivo%type;
    vsCodProdutoFiscal map_produto.codprodfiscal%type;
    vnSeqRequisicao    OR_REQUISICAO.SEQREQUISICAO%TYPE;
    vsMsgRetorno       varchar2(2000);
    vsCodProduto NUMBER(20);
BEGIN
    pnOk := 0;

    -- Busca empresa e pessoa
    select a.nroempresa, a.seqpessoa
    into vnEmpresa, vnPessoa
    from or_nfdespesa a
    where a.seqnota = pnSeqNota;

    -- Buscar parâmetro do fornecedor que indica se consiste NCM XML
    select nvl(max(a.indconsistencmxml), 'N')
    into vsParamFornecedor
    from maf_fornecdivisao a,
      max_empresa       b
    where a.nrodivisao = b.nrodivisao
      and b.nroempresa = vnEmpresa
      and a.seqfornecedor = vnPessoa;

    if vsParamFornecedor = 'S' then

        for ncmNota in (
            select itemxml.codncm,
              itemxml.codproduto,
              itemxml.nroitem,
              itemxml.idnf,
              itemxml.iditem,
              itemxml.tipoimp,
              itemxml.cfop,
              nfdespesa.codhistorico,
              parametro.nroempresaorc,
              empresa.matriz,
              nfdespesa.seqpessoa,
              nfdespesa.nroempresa,
              nfdespesa.indnotatransf
            from ge_pessoa pessoa,
              orv_importacao_nf_xml nfxml,
              orv_importacao_item_xml itemxml,
              or_nfdespesa nfdespesa,
              or_parametro parametro,
              ge_empresa empresa
            where nfdespesa.seqpessoa = pessoa.seqpessoa
              and lpad(pessoa.nrocgccpf, 12, 0) || lpad(pessoa.digcgccpf, 2, 0) = nfxml.cnpjemitente
              and nfdespesa.nronota = nfxml.numeronf
              and nfdespesa.serie = nfxml.serie
              and nfdespesa.codmodelo = nfxml.modelo
              and itemxml.idnf = nfxml.idnf
              and parametro.nroempresa = nfdespesa.nroempresa
              and empresa.nroempresa = nfdespesa.nroempresa
              and nvl(nfxml.tipoimp, 'X') = 'X'
              and nfdespesa.codhistorico not in (184) --- Solicitação Lucinéia - Ticket 411891 em 24/06 por Cipolla
              and nfdespesa.nroempresa = vnEmpresa
              and nfdespesa.seqnota = pnSeqNota
        )
        loop

            -- Verifica se o produto possui inconsistência
            vsCodProdutoFiscal := espf_or_obtemcodproduto(ncmNota.codproduto,
                                                                 ncmNota.nroempresa,
                                                                 ncmNota.idnf,
                                                                 ncmNota.iditem,
                                                                 ncmNota.tipoimp,
                                                                 ncmNota.cfop,
                                                                 ncmNota.codhistorico,
                                                                 ncmNota.nroempresaorc,
                                                                 ncmNota.matriz,
                                                                 ncmNota.indnotatransf,
                                                                 ncmNota.seqpessoa,
                                                                 vsInconsistenciaProduto);

            if vsCodProdutoFiscal IS NOT NULL then

                -- Busca NCM do produto
                select a.codnbmsh
                into vnNcmFamilia
                from map_familia a, map_produto b
                where a.seqfamilia = b.seqfamilia
                  and b.codprodfiscal = vsCodProdutoFiscal;

                -- Se o código NCM do produto da nota for diferente do NCM do produto cadastrado na base, então faz um insert na tabela orx_nfdespesaincosistcust com os detalhes da inconsistência
                if substr(ncmNota.Codncm, 0, 4) <> substr(vnNcmFamilia, 0, 4) then

                    insert into orx_nfdespesaincosistcust
                        (seqinconsist,
                         motivo,
                         situacao)
                    values
                        (500,
                         'Produto ' || ncmNota.codproduto || ' no item ' || ncmNota.nroitem || ': NCM ' ||
                         vnNcmFamilia || ' cadastrado na família, diferente do NCM ' || ncmNota.codncm ||
                         ' informado no XML.',
                         'P');

                    if pnOk = 0 then
                       pnOk := 1;
                    end if;
                end if;
            end if;
        end loop;
    end if;
    --busca a requisicao da nota
    select max(a.seqrequisicao)
    into   vnSeqRequisicao
    from   or_nfdespesareq a
    where  a.seqnota = pnSeqNota;
    ---inconsistencia da issue 4870
    For t in (select a.nroparcela, nvl(a.dtaprogramada, a.dtavencto) dtavencto,
                     a.valor
              from   OR_NFVENCIMENTO a
              where  a.seqnota = pnSeqNota)
    loop
          ESP_VALIDAREQUISICAO(vnSeqRequisicao, pnSeqNota, t.dtavencto, t.valor, vsMsgRetorno);
          --inserir inconsistencia se retorno diferente de null
          If vsMsgRetorno is not null then
              /*select max(a.seqinconsist)
                      into vnSeqInconsist
                      from or_nfdespesainconsist a;*/

                      --vnSeqInconsist := vnSeqInconsist + 1;
              insert into orx_nfdespesaincosistcust
                          (seqinconsist,
                           motivo,
                           situacao)
                      values
                          (501,
                           substr('NroParcela: ' || t.nroparcela || ' Venc: ' || to_char(t.dtavencto, 'dd/MM/yyyy') || ' Rejeicao: ' || vsMsgRetorno, 1, 250),
                           'P');
              pnOk := 1;
        end if;
    end loop;
    -- Ticket 411292 | Adicionado por Giuliano em 10/07/2024
    FOR g IN (SELECT n.codproduto FROM OR_NFDESPESA N INNER JOIN GE_PESSOA G ON G.SEQPESSOA = N.SEQPESSOA
                                           INNER JOIN MAX_EMPRESA M ON M.NROEMPRESA = N.NROEMPRESA
                                           INNER JOIN OR_NFITENSDESPESA P ON P.SEQNOTA = N.SEQNOTA

            WHERE 1=1

              AND G.UF != M.UF
              AND P.CODPRODUTO IN (262443, 262445)

              AND N.NROEMPRESA = vnEmpresa
              AND N.SEQNOTA    = pnSeqnota)

    LOOP
      vsCodProduto := g.codproduto;

      INSERT INTO ORX_NFDESPESAINCOSISTCUST(SEQINCONSIST, MOTIVO, SITUACAO)
          VALUES (802,'Lançamento não permitido para fornecedor Interestadual! Item: '||vsCodProduto||' - Dúvidas: Depto Fiscal.', 'P');
          pnOk := 1;

    END LOOP;
 -- Ticket 522853 | Adicionado por Giuliano em 24/01/2025
    FOR h IN (SELECT I.CODPRODUTO FROM OR_NFDESPESA X INNER JOIN GE_PESSOA FORNEC    ON FORNEC.SEQPESSOA = X.SEQPESSOA
                               INNER JOIN GE_PESSOA LJ        ON LJ.SEQPESSOA     = X.NROEMPRESA
                               INNER JOIN OR_NFITENSDESPESA I ON I.SEQNOTA        = X.SEQNOTA
                             
               WHERE 1=1
                 AND (FORNEC.UF != LJ.UF AND SUBSTR(I.CFOP,0,1) = 1
                  OR  FORNEC.UF  = LJ.UF AND SUBSTR(I.CFOP,0,1) = 2)
                  
                 AND X.NROEMPRESA = vnEmpresa
                 AND X.SEQNOTA    = pnSeqnota)
                 
    LOOP
      vsCodProduto := h.CODPRODUTO;

      INSERT INTO ORX_NFDESPESAINCOSISTCUST(SEQINCONSIST, MOTIVO, SITUACAO)
          VALUES (803,'CFOP incorreto na operação com este fornecedor! Item: '||vsCodProduto||' - Dúvidas: Depto Fiscal.', 'P');
          pnOk := 1;

    END LOOP;
    -- Consiste Serie Nula
    -- Solicitacao via Teams 17/03/2025 - Giuliano
    FOR i IN (SELECT *
                FROM OR_NFDESPESA N
               WHERE 1 = 1
                 AND N.SERIE IS NULL
                 AND N.NROEMPRESA = vnEmpresa
                 AND N.SEQNOTA    = pnSeqnota)

    LOOP

      INSERT INTO ORX_NFDESPESAINCOSISTCUST(SEQINCONSIST, MOTIVO, SITUACAO)
          VALUES (804,'Não é permitido lançamento de NF sem série informada, Verifique!', 'P');
          pnOk := 1;

    END LOOP;
    -- Consiste Ano de Emissao - Nao permite lancto com emissao (ano) menor que o ano atual -1
    -- Solicitacao via Teams 17/03/2025 - Giuliano
    FOR a IN (SELECT *
                FROM OR_NFDESPESA N
               WHERE 1 = 1
                 AND EXTRACT(YEAR FROM DTAEMISSAO) < EXTRACT(YEAR FROM SYSDATE)  - 1
                 AND N.NROEMPRESA = vnEmpresa
                 AND N.SEQNOTA    = pnSeqnota)

    LOOP

      INSERT INTO ORX_NFDESPESAINCOSISTCUST(SEQINCONSIST, MOTIVO, SITUACAO)
          VALUES (805,'Data de emissão incorreta, Verifique!', 'P');
          pnOk := 1;

    END LOOP;
    
    -- Consiste se a NF ja existe lançada em outra empresa - NroNota, Fornecedor, Serie e Subserie
    -- Giuliano 26/05/25
    
    FOR t IN (SELECT NROEMPRESA
                FROM OR_NFDESPESA N
               WHERE 1 = 1
                 AND EXISTS (SELECT 1 FROM OR_NFDESPESA X
                               WHERE 2=2 
                                 AND X.NROEMPRESA = vnEmpresa
                                 AND X.SEQNOTA    = pnSeqnota
                                 -- Valida duplicidade
                                 AND X.NRONOTA     = N.NRONOTA
                                 AND X.NROEMPRESA != N.NROEMPRESA
                                 AND X.SEQPESSOA   = N.SEQPESSOA
                                 AND X.SERIE       = N.SERIE
                                 AND NVL(X.SUBSERIE,0) = NVL(N.SUBSERIE,0)))

    LOOP

      INSERT INTO ORX_NFDESPESAINCOSISTCUST(SEQINCONSIST, MOTIVO, SITUACAO)
          VALUES (806,'NF ja lançada na empresa '||t.NROEMPRESA|| ', Verifique!', 'P');
          pnOk := 1;

    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        pnOk := 0;

END ORP_INSCONSISTENCIACUST;
