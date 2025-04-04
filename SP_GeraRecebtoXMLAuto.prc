create or replace procedure SP_GeraRecebtoXMLAuto (pNroEmpresa max_empresa.nroempresa%type default null)
 is
    vnCGO                       MRL_NFEIMPORTACAO.CODGERALOPER%type;
    vnOK                        NUMBER;
    vsPD_AssocPedNFXML          VARCHAR2(1);
    vnSeqPessoa                 GE_PESSOA.SEQPESSOA%TYPE;
    vsCGCInicial                NUMBER;
    vsCGCFinal                  NUMBER;
    vsCGC                       VARCHAR2(14);
    vnNroCGCCPF                 GE_PESSOA.NROCGCCPF%TYPE;
    vsFisicaJuridica            GE_PESSOA.Fisicajuridica%type;
    vsIndUsaAprovQtCompra       VARCHAR2(1);
    vnNroDivisao                MAX_EMPRESA.Nrodivisao%type;
    vsCGOs                      VARCHAR2(100);
    vnPD_QtdDiasProcXML         MAX_PARAMETRO.VALOR%TYPE;
    vsIndAssumeEmbQtdEmbXml     maf_fornecdivisao.indassumeembqtdembxml%type;
    vsPD_IndAssocPedidoXML      MAX_PARAMETRO.VALOR%TYPE;
    vsIndTagNroPedidoXML        maf_fornecdivisao.indassumeembqtdembxml%type;
    vnCount                     integer;
    vsPedido                    TMP_M000_NF.M000_DS_PEDIDO%TYPE;
    vnPedidoCGO                 MRL_NFEIMPORTACAO.CODGERALOPER%type;
    vsPD_vsPDConvEmbPedXml      MAX_PARAMETRO.VALOR%TYPE;
    vnEmbPadraoImpXml           MAP_FAMFORNEC.EMBPADRAOIMPXML%TYPE;
    vnPadraoEmbCompra           MAP_FAMDIVISAO.PADRAOEMBCOMPRA%TYPE;
    vsPD_PmtVisualPedFornRel    Max_Parametro.Valor%Type;
 BEGIN
    sp_buscaparamdinamico('RECEBTO_NFE', 0, 'ASSOC_PED_NF_XML', 'S', 'N',
                          'ASSOCIAR O PEDIDO NA NOTA FISCAL E GERAR O RECEBIMENTO AUTOMATICAMENTE '  || CHR(13) || CHR(10)  ||
                          'CASO NÃO HAJA INCONSISTÊNCIA NA NOTA ENVIADO VIA XML? VALORES:(S-SIM/N-NÃO(VALOR PADRÃO))', vsPD_AssocPedNFXML);
    sp_buscaparamdinamico('RECEBTO_NFE', 0, 'QTDE_DIAS_PROC_XML', 'N', '7',
                          'INFORMA A QUANTIDADE DE DIAS PARA PROCESSAMENTO DOS DOCUMENTOS DE XML AUTOMÁTICO' || CHR(13) || CHR(10) ||
                          'PADRÃO: 7 DIAS', vnPD_QtdDiasProcXML);
    sp_buscaparamdinamico('RECEBTO_NFE', 0, 'CONV_EMB_PED_XML', 'S', 'N',
                          'CONVERTE A QUANTIDADE RECEBIDA AO VINCULAR UM PEDIDO DE COMPRA À NOTA DE ACORDO COM A EMBALAGEM DA FAMILIA/FORNECEDOR QUANDO A EMBALAGEM DO XML FOR DIFERENTE DO PEDIDO?' || chr(13) || chr(10) ||
                          'VALORES:(S-SIM/N-NÃO(VALOR PADRÃO))', vsPD_vsPDConvEmbPedXml);
    -- RC 155595
    SP_BUSCAPARAMDINAMICO( 'RECEBTO_NFE', 0, 'IND_ASSOC_PEDIDO_XML', 'S', 'P',
            'INDICA SE O NÚMERO DO PEDIDO DO XML SERÁ ASSOCIADO PELA TAG PRODUTO OU COMPRA.' || CHR(13) || CHR(10) ||
            'VALORES:' || CHR(13) || CHR(10) ||
            'C - COMPRA' || CHR(13) || CHR(10) ||
            'P - PRODUTO (PADRÃO)' || CHR(13) || CHR(10) ||
            'F - CONFORME DIVISÃO DO FORNECEDOR' || CHR(13) || CHR(10) ||
            'T - TODAS OPÇÕES',
            vsPD_IndAssocPedidoXML );
    SP_BUSCAPARAMDINAMICO( 'RECEBTO_NF', 0, 'PMT_VISUAL_PED_FORN_REL', 'S', 'N',
                           'PERMITE VISUALIZAR APENAS PEDIDOS DE OUTROS FORNECEDORES CASO ESTES ESTEJAM RELACIONADOS? VALORES:S - SIM; N- NÃO - (TAMBÉM SERÁ CONSIDERADO O CNPJ BASE PARA FAZER O RELACIONAMENTO(PADRÃO))', vsPD_PmtVisualPedFornRel);
    IF vsPD_AssocPedNFXML = 'S' THEN
      FOR emp IN (  SELECT  A.NROEMPRESA, NVL(B.VALOR, 'T') VALOR_PD_PADRAO_FILTRO_TPO_NF
                    FROM    MAX_EMPRESA A,
                            MAX_PARAMETRO B
                    WHERE   A.NROEMPRESA = B.NROEMPRESA (+)
                    AND     A.NROEMPRESA = NVL(pNroEmpresa, A.NROEMPRESA)
                    AND     B.PARAMETRO  = 'PADRAO_FILTRO_TPO_NF'
                    AND     B.GRUPO      = 'RECEBTO_NFE')
      LOOP
        FOR nfi IN (  SELECT A.SEQNOTAFISCAL,
                             A.CHAVEACESSO,
                             A.SEQPESSOA,
                             G.NROEMPRESA,
                             A.PEDIDO
                      FROM (
                            SELECT A.M000_NR_DOCUMENTO NUMERONF,
                                   NVL(D.SEQPESSOA,0) SEQPESSOA,
                                   TO_CHAR(A.M000_NR_SERIE) SERIENF, -- TO_CHAR ADD ERRO INVALID NUMBER
                                   A.M000_NR_CHAVE_ACESSO CHAVEACESSO,
                                   A.M000_ID_NF SEQNOTAFISCAL,
                                   MIN(F.SEQPESSOA) SEQPESSOAEMP,
                                   A.M000_DS_PEDIDO PEDIDO
                            FROM   TMP_M000_NF A, TMP_M001_EMITENTE B,
                                     GE_PESSOA D, TMP_M002_DESTINATARIO E, GE_PESSOA F, MAX_EMPRESA G
                            WHERE  A.m000_dm_tipo = 1
                            AND    NVL(A.CODOPERMANIFESTDEST, '0') NOT IN ('210220', '210240')
                            AND NOT EXISTS ( SELECT 1 FROM  MFL_NFELOG
                                            WHERE MFL_NFELOG.DESCRICAO LIKE '%OPERAÇÃO NÃO REALIZADA%' AND
                                            MFL_NFELOG.NFECHAVEACESSO = A.M000_NR_CHAVE_ACESSO
                                            )
                            AND    A.M000_ID_NF = B.M000_ID_NF
                            AND    D.NROCGCCPF(+)      = TO_NUMBER(SUBSTR(B.M001_NR_CNPJ, 1, Length(B.M001_NR_CNPJ)-2))
                            And    D.DIGCGCCPF(+)      = TO_NUMBER(SUBSTR(B.M001_NR_CNPJ, -2))
                            AND    e.m000_id_nf = A.M000_ID_NF
                            AND    F.fisicajuridica = 'J'
                            and    F.nrocgccpf      = to_number(substr(e.m002_nr_cnpj_cpf, 1, length(e.m002_nr_cnpj_cpf)-2))
                            and    F.digcgccpf      = to_number(substr(e.m002_nr_cnpj_cpf, -2))
                            AND    F.status         = 'A'
                            AND    G.SEQPESSOAEMP   = F.SEQPESSOA
                            AND    G.STATUS         = 'A'
                            AND    A.DTAHORINCLUSAO >= TRUNC(SYSDATE) - vnPD_QtdDiasProcXML
                                    AND    A.M000_ID_NF IN ( SELECT MAX(Z.M000_ID_NF)
                                                     FROM TMP_M000_NF Z
                                                     WHERE Z.M000_NR_CHAVE_ACESSO = A.M000_NR_CHAVE_ACESSO)
                            AND    EXISTS (SELECT 1 FROM MAF_FORNECEDOR H
                                            WHERE H.SEQFORNECEDOR = D.SEQPESSOA
                                            AND   H.STATUSGERAL = 'A')
                              AND   (( emp.valor_pd_padrao_filtro_tpo_nf = 'C'
                                      AND EXISTS (SELECT 1
                                                  FROM   TMP_M014_ITEM H
                                                  WHERE  H.M000_ID_NF = A.M000_ID_NF
                                                  AND    (MOD(H.M014_CD_CFOP, 1000) BETWEEN 100 AND 122
                                                          OR
                                                          MOD(H.M014_CD_CFOP, 1000) BETWEEN 126 AND 128
                                                          OR
                                                          MOD(H.M014_CD_CFOP, 1000) BETWEEN 250 AND 257
                                                          OR
                                                          MOD(H.M014_CD_CFOP, 1000) BETWEEN 401 AND 407
                                                          OR
                                                          MOD(H.M014_CD_CFOP, 1000) BETWEEN 651 AND 653
                                                          OR
                                                          MOD(H.M014_CD_CFOP, 1000) in (551, 556, 910)
                                                         )
                                                  )
                                   )
                                   OR
                                     (emp.valor_pd_padrao_filtro_tpo_nf = 'D'
                                     AND
                                    EXISTS (SELECT 1
                                            FROM   TMP_M014_ITEM H
                                            WHERE  H.M000_ID_NF = A.M000_ID_NF
                                            AND    (MOD(H.M014_CD_CFOP, 1000) BETWEEN 200 AND 211
                                                     OR
                                                    MOD(H.M014_CD_CFOP, 1000) BETWEEN 660 AND 662
                                                     OR
                                                    MOD(H.M014_CD_CFOP, 1000) BETWEEN 410 AND 411
                                                     OR
                                                    MOD(H.M014_CD_CFOP, 1000) = 553
                                                   )
                                           )
                                   )
                                   OR
                                     emp.valor_pd_padrao_filtro_tpo_nf = 'T'
                                  )
                              AND    G.NROEMPRESA = emp.nroempresa
                            GROUP BY A.M000_NR_DOCUMENTO,
                                     NVL(D.SEQPESSOA,0),
                                     TO_CHAR(A.M000_NR_SERIE),
                                     A.M000_NR_CHAVE_ACESSO,
                                     A.M000_ID_NF,
                                     A.M000_DS_PEDIDO
                           ) A,
                           MAX_EMPRESA G
                      WHERE A.SEQPESSOAEMP = G.SEQPESSOAEMP
                      AND   NOT EXISTS (
                                         SELECT X.SEQNOTAFISCAL
                                         FROM   MLF_AUXNOTAFISCAL X
                                         WHERE  X.NUMERONF           = A.NUMERONF
                                         AND    X.SEQPESSOA          = A.SEQPESSOA
                                         AND    TRIM(X.SERIENF)      = A.SERIENF
                                         AND    X.NROEMPRESA         = G.NROEMPRESA
                                         AND    ISNUMERIC(X.SERIENF) = 'S'
                                        )
                      AND    NOT EXISTS (
                                         SELECT Y.SEQNOTAFISCAL
                                         FROM   MLF_NOTAFISCAL Y
                                         WHERE  Y.NUMERONF           = A.NUMERONF
                                         AND    Y.SEQPESSOA          = A.SEQPESSOA
                                         AND    TRIM(Y.SERIENF)      = A.SERIENF
                                         AND    Y.NROEMPRESA         = G.NROEMPRESA
                                         AND    ISNUMERIC(Y.SERIENF) = 'S'
                                         UNION
                                         SELECT YY.SEQNOTAFISCAL
                                         FROM   MLF_NOTAFISCAL YY, MAX_CODGERALOPER PP
                                         WHERE  YY.NFREFERENCIANRO                    =  A.NUMERONF
                                         AND    TRIM(YY.NFREFERENCIASERIE)            =  A.SERIENF
                                         AND    YY.SEQPESSOA                          =  A.SEQPESSOA
                                         AND    YY.NROEMPRESA                         =  G.NROEMPRESA
                                         AND    YY.TIPNOTAFISCAL                      =  'E'
                                         AND    ISNUMERIC(YY.NFREFERENCIASERIE)       =  'S'
                                         AND    PP.CODGERALOPER                       =  YY.CODGERALOPER
                                         AND    PP.TIPUSO                             =  'E'
                                         AND    PP.INDNFREFPRODRURAL                  =  'S'
                                        )
                        AND    G.NROEMPRESA = emp.nroempresa
                        -- Giuliano 04/04/2025
                        -- Nao reimportar a nota caso ela ja tenha sido importada anteirormente e excluida manualmente
                        AND    NOT EXISTS (
                                           SELECT 1 FROM MLF_AUXNOTAFISCAL_LOG LOG
                                            WHERE LOG.NUMERONF   = A.NUMERONF
                                              AND LOG.NROEMPRESA = G.NROEMPRESA
                                              AND LOG.SEQPESSOA  = A.SEQPESSOA
                                              AND TRIM(LOG.SERIENF) = A.SERIENF
                                              AND OPERACAO = 'DEL'
                                              AND ISNUMERIC(LOG.SERIENF) = 'S'
                                          )
                        
                        )
        LOOP
            -- RC 127471
            BEGIN
              SELECT NVL(B.INDASSUMEEMBQTDEMBXML, 'N'), NVL(B.IndTagNroPedidoXML, 'P')
                INTO vsIndAssumeEmbQtdEmbXml, vsIndTagNroPedidoXML
                FROM MAF_FORNECEDOR A,
                     MAF_FORNECDIVISAO B,
                     MAX_EMPRESA C
               WHERE A.SEQFORNECEDOR = B.SEQFORNECEDOR
                 AND B.NRODIVISAO = C.NRODIVISAO
                 AND C.NROEMPRESA = nfi.nroempresa
                 AND A.SEQFORNECEDOR = nfi.seqpessoa;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  vsIndAssumeEmbQtdEmbXml := 'N';
                  vsIndTagNroPedidoXML := 'P';
            END;
            SELECT 	INDUSAAPROVQTDCOMPRA,
                    NRODIVISAO
            INTO 	  vsIndUsaAprovQtCompra,
                    vnNroDivisao
            FROM 	  MAX_EMPRESA
            WHERE 	NROEMPRESA = nfi.nroempresa;
            -- Limpa Variáveis
            vnCGO := 0;
            vnSeqPessoa := -1;
            vsCGCInicial := '-1';
            vsCGCFinal := '-1';
            vnOK := 1;
            -- BUSCA CGO
            SELECT NVL(MAX(CODGERALOPER), 0), count(1)
            INTO   vnCGO, vnCount
            FROM   MRL_NFEIMPORTACAO
            WHERE  SEQNOTAFISCAL = nfi.seqnotafiscal;
            IF vnCGO = 0 THEN
              SELECT NVL(MIN(D.CODGERALOPER),0)
              INTO	 vnCgo
              FROM	 MAF_FORNECDIVISAOCGO D
              WHERE	 D.SEQFORNECEDOR = nfi.seqpessoa
              AND	   D.NRODIVISAO = vnNroDivisao
              AND	   NVL(D.INDUTILCFOP, 'S') = 'N';
              IF vnCGO = 0 THEN
                SELECT C5_Complexin.C5instring(Cast(Collect(to_char(CODGERALOPER)) As C5instrtable), ', ') CODGERALOPER
                INTO	 vsCGOs
                FROM (
                      SELECT DISTINCT A.CODGERALOPER
                      FROM   MAF_FORNECDIVISAOCGOCFOP A
                      WHERE  A.NRODIVISAO    = vnNroDivisao
                      AND    A.SEQFORNECEDOR = nfi.seqpessoa
                      AND    A.CFOP          IN  (SELECT DISTINCT B.CFOP
                                                 FROM   MRLV_NFEIMPORTACAOITEM B
                                                 WHERE  B.SEQNOTAFISCAL = nfi.seqnotafiscal)
                     ) B;
                IF LENGTH( vsCGOs ) IS NULL THEN
                   SELECT NVL(MIN(A.CODGERALOPER),0)
                   INTO	  vnCgo
                   FROM	  MAX_DIVISAOCGO A
                   WHERE  A.NRODIVISAO = vnNroDivisao
                   AND	  NVL(A.INDUTILCFOP, 'S') = 'N';
                   IF vnCGO = 0 THEN
                      SELECT C5_Complexin.C5instring(Cast(Collect(to_char(CODGERALOPER)) As C5instrtable), ', ') CODGERALOPER
                      INTO	 vsCGOs
                      FROM (
                            SELECT DISTINCT A.CODGERALOPER
                            FROM   MAX_DIVISAOCGOCFOP A
                            WHERE  A.NRODIVISAO    = vnNroDivisao
                            AND    A.CFOP          IN  (SELECT DISTINCT B.CFOP
                                                       FROM   MRLV_NFEIMPORTACAOITEM B
                                                       WHERE  B.SEQNOTAFISCAL = nfi.seqnotafiscal)
                           ) B;
                      IF INSTR(vsCGOs, ',') > 0 THEN
                         vnCGO := 0;
                      ELSE
                         vnCGO := NVL(TO_NUMBER(vsCGOs),0) ;
                      END IF;
                   END IF;
                ELSIF INSTR(vsCGOs, ',') > 0 THEN
                   vnCGO := 0;
                ELSE
                   vnCGO := NVL(TO_NUMBER(vsCGOs),0) ;
                END IF;
              END IF;
            END IF;
            -- RC 160824
            if vnCount = 0 then
               SELECT MAX(A.PEDIDO)
               INTO   vsPedido
               FROM  MRLV_NFEIMPORTACAO A
               WHERE A.SEQNOTAFISCAL = nfi.seqnotafiscal;
               INSERT INTO MRL_NFEIMPORTACAO(SEQNOTAFISCAL,PEDIDO,SEQFORNECEDOR,NROEMPRESA,CODGERALOPER)
               VALUES(nfi.seqnotafiscal,vsPedido,nfi.seqpessoa,nfi.nroempresa, vnCGO);
            else
               UPDATE MRL_NFEIMPORTACAO A
               SET A.CODGERALOPER = vnCGO,
                   A.SEQFORNECEDOR = nfi.seqpessoa
               WHERE A.SEQNOTAFISCAL = nfi.seqnotafiscal;
            end if;
            --- BUSCA SEQFORNECEDORES FORNECEDORES
            vnOK := 1;
            BEGIN
              SELECT A.NROCGCCPF,
                     A.FISICAJURIDICA
              INTO   vnNroCGCCPF,
                     vsFisicaJuridica
              FROM   GE_PESSOA A
              WHERE  A.SEQPESSOA = nfi.seqpessoa;
            EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                       vnOK := 0;
            END;
            IF vnOK = 1 THEN
                IF vsFisicaJuridica = 'J' THEN
                    vsCGC :=  SUBSTR ( to_char(vnNroCGCCPF), 1,  LENGTH(vnNroCGCCPF) - 4 );
                    vsCGCInicial := vsCGC || '0000';
                    vsCGCFinal := vsCGC || '9999';
                ELSE
                    vnSeqPessoa := nfi.seqpessoa;
                END IF;
                -- DELETA MRL_NFEITEMPEDIDO CASO NRO PEDIDO FOR ZERADO, PARA POSSIBILITAR NOVA ASSOCIAÇÃO DE PEDIDO VÁLIDO
                DELETE FROM MRL_NFEITEMPEDIDO
                WHERE SEQNOTAFISCAL = nfi.seqnotafiscal
                AND   NVL(NROPEDIDOSUPRIM,0) = 0;
                -- ASSOCIA NRO. PEDIDO À NF
                for vtItemPedido in(
                   SELECT   A.SEQNOTAFISCAL,
                            A.NROEMPRESA,
                            A.SEQNFITEM,
                            A.SEQPRODUTO,
                            A.QUANTIDADE,
                            A.CODACESSO,
                            A.SEQFAMILIA,
                            nvl(vnCGO,0) CGO,
                            (CASE WHEN (vsIndAssumeEmbQtdEmbXml = 'S' AND A.QTDUN > 0) THEN
                              A.QTDUN
                            else
                              A.QTDEMBALAGEM
                            end) QTDEMBALAGEM,
                            A.QTDUN,
                            fmsu_RetornaPedidoSaldo(A.NROEMPRESA,
                                                    REGEXP_REPLACE(DECODE(vsPD_IndAssocPedidoXML,
                                                                          'F',
                                                                          DECODE(vsIndTagNroPedidoXML, 'C',
                                                                                                       nfi.Pedido,
                                                                                                       A.PEDIDO),
                                                                          'T',
                                                                          DECODE(NVL(REGEXP_REPLACE(nfi.pedido, '[^[:digit:]]'), 0), 0,
                                                                                                     NVL(a.pedido, 0),
                                                                                                     nfi.pedido),
                                                                          'C',
                                                                          nfi.Pedido,
                                                                          A.PEDIDO ), '[^[:digit:]]'),
                                                    A.QUANTIDADE,
                                                    vnSeqPessoa,
                                                    nfi.SeqPessoa,
                                                    A.SEQPRODUTO,
                                                    nvl(vnCGO,0),
                                                    vsCGCInicial,
                                                    vsCGCFinal,
                                                    vsPD_PmtVisualPedFornRel) PEDIDO
                   FROM     MRLV_NFEIMPORTACAOITEM A,
                            MRL_NFEITEMPEDIDO      B,
                            MSU_PSITEMRECEBER      C
                   WHERE    A.SEQNOTAFISCAL  = B.SEQNOTAFISCAL (+)
                   AND      A.SEQNFITEM      = B.SEQNFITEM (+)
                   AND      C.NROPEDIDOSUPRIM (+) = decode(Isnumeric(A.PEDIDO), 'S', A.PEDIDO, 0)
                   AND      C.NROEMPRESA      (+) = A.NROEMPRESA
                   AND      C.SEQPRODUTO      (+) = A.SEQPRODUTO
                   AND      A.SEQNOTAFISCAL  = nfi.seqnotafiscal
                   AND      A.NROEMPRESA = nfi.nroempresa
                   AND      B.SEQNFITEM IS NULL
                   GROUP BY A.SEQNOTAFISCAL,
                            A.NROEMPRESA,
                            A.SEQNFITEM,
                            A.SEQPRODUTO,
                            A.PEDIDO,
                            A.QUANTIDADE,
                            A.CODACESSO,
                            A.SEQFAMILIA,
                            (CASE WHEN (vsIndAssumeEmbQtdEmbXml = 'S' AND A.QTDUN > 0) THEN
                              A.QTDUN
                            else
                              A.QTDEMBALAGEM
                            end),
                            A.QTDUN,
                            B.SEQNFITEM,
                           fmsu_RetornaPedidoSaldo(A.NROEMPRESA,
                                                   REGEXP_REPLACE(DECODE(vsPD_IndAssocPedidoXML,
                                                                         'F',
                                                                         DECODE(vsIndTagNroPedidoXML, 'C',
                                                                                                      nfi.Pedido,
                                                                                                      A.PEDIDO),
                                                                         'T',
                                                                         DECODE(NVL(REGEXP_REPLACE(nfi.pedido, '[^[:digit:]]'), 0), 0,
                                                                                                    NVL(a.pedido, 0),
                                                                                                    nfi.pedido),
                                                                         'C',
                                                                         nfi.Pedido,
                                                                         A.PEDIDO ), '[^[:digit:]]'),
                                                   A.QUANTIDADE,
                                                   vnSeqPessoa,
                                                   nfi.SeqPessoa,
                                                   A.SeqProduto,
                                                   nvl(vnCGO,0),
                                                   vsCGCInicial,
                                                   vsCGCFinal,
                                                   vsPD_PmtVisualPedFornRel)
                )
                loop
                   if nvl(vtItemPedido.PEDIDO, 0) > 0 then
                      select max(a.qtdembalagem)
                      into   vtItemPedido.QTDEMBALAGEM
                      from   msu_psitemreceber a
                      where  a.nropedidosuprim = vtItemPedido.PEDIDO
                      and    a.nroempresa      = vtItemPedido.NROEMPRESA
                      and    a.seqproduto      = vtItemPedido.SEQPRODUTO;
                      select max(a.embpadraoimpxml)
                      into   vnEmbPadraoImpXml
                      from   map_famfornec a,
                             map_produto b
                      where  a.seqfamilia = b.seqfamilia
                      and    b.seqproduto = vtItemPedido.SEQPRODUTO
                      and    a.seqfornecedor = nfi.SeqPessoa;
                      if vsPD_vsPDConvEmbPedXml = 'S' and nvl(vtItemPedido.QTDEMBALAGEM, 0) != nvl(vnEmbPadraoImpXml, 0) then
                         select max(b.padraoembcompra)
                         into   vnPadraoEmbCompra
                         from   map_produto a, map_famdivisao b, max_empresa c
                         where  a.seqfamilia= b.seqfamilia
                         and    b.nrodivisao = c.nrodivisao
                         and    c.nroempresa = vtItemPedido.NROEMPRESA
                         and    a.seqproduto = vtItemPedido.SEQPRODUTO;
                         if vnEmbPadraoImpXml is not null then
                            vnPadraoEmbCompra := vnEmbPadraoImpXml;
                         else
                            select max(a.QTDEMBALAGEM)
                            into   vnEmbPadraoImpXml
                            from   MAP_PRODCODIGO a
                             where  a.SEQPRODUTO = vtItemPedido.SEQPRODUTO
                             and    a.CODACESSO = vtItemPedido.CODACESSO
                             and    a.SEQFAMILIA = vtItemPedido.SEQFAMILIA;
                             if vnEmbPadraoImpXml is not null then
                               if vnEmbPadraoImpXml > 1 then
                                 vnPadraoEmbCompra := vnEmbPadraoImpXml;
                               end if;
                             end if;
                         end if;
                         select count(1)
                         into   vnCount
                         from   MAP_PRODUTO P,MAP_FAMILIA F, MAP_FAMEMBALAGEM E
                         where  F.SEQFAMILIA = P.SEQFAMILIA
                         and    E.SEQFAMILIA = F.SEQFAMILIA
                         and    E.QTDEMBALAGEM = vtItemPedido.QTDUN
                         and    P.SEQPRODUTO = vtItemPedido.SEQPRODUTO;
                         if vsIndAssumeEmbQtdEmbXml = 'S' and vnCount > 0 then
                           vnPadraoEmbCompra := vtItemPedido.QTDUN;
                           vtItemPedido.QTDEMBALAGEM := vtItemPedido.QTDUN;
                         end if;
                         if vnPadraoEmbCompra > 0 then
                           vtItemPedido.QUANTIDADE   := vtItemPedido.QUANTIDADE * vnPadraoEmbCompra;
                         end if;
                         vtItemPedido.QUANTIDADE := vtItemPedido.QUANTIDADE / vtItemPedido.QTDEMBALAGEM;
                      end if;
                   end if;
                   INSERT INTO MRL_NFEITEMPEDIDO
                        (SEQNOTAFISCAL,
                         NROITEM,
                         SEQNFITEM,
                         SEQPRODUTO,
                         QUANTIDADE,
                         CODGERALOPER,
                         QTDEMBALAGEM,
                         NROPEDIDOSUPRIM)
                   VALUES(
                         vtItemPedido.SEQNOTAFISCAL,
                         vtItemPedido.SEQNFITEM,
                         vtItemPedido.SEQNFITEM,
                         vtItemPedido.SEQPRODUTO,
                         vtItemPedido.QUANTIDADE,
                         vtItemPedido.CGO,
                         vtItemPedido.QTDEMBALAGEM,
                         vtItemPedido.PEDIDO);
                end loop;
                /*
                Verifica se há CGOs diferente entre os pedidos e, caso encontre apenas um,
                atribui o valor do CGO
                */
                BEGIN
                  SELECT MAX(PS.CODGERALOPER)
                  into vnPedidoCGO
                  FROM MRL_NFEITEMPEDIDO I, MSU_PEDIDOSUPRIM PS
                  WHERE I.SEQNOTAFISCAL  = nfi.seqnotafiscal
                    AND I.NROPEDIDOSUPRIM = PS.NROPEDIDOSUPRIM
                    AND PS.CODGERALOPER IS NOT NULL
                  GROUP BY I.SEQNOTAFISCAL
                  HAVING COUNT(DISTINCT PS.CODGERALOPER) = 1;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    vnPedidoCGO := vnCGO;
                END;
                -- Atualiza o CGO da nota com o CGO do pedido caso exista senão mantém o encontrado no processo
                if nvl(vnPedidoCGO,0) != nvl(vnCGO,0) then
                   vnCGO := vnPedidoCGO;
                   UPDATE MRL_NFEITEMPEDIDO SET codgeraloper = vnCGO
                   WHERE SEQNOTAFISCAL = nfi.seqnotafiscal;
                end if;
                if vnCGO > 0 then
                    -- 0 = NF com Inconsistência 1 = NF Sem Inconsistência
                    if fverificainconsistencia(nfi.seqnotafiscal) = 1 then
                       -- Consiste NF
                       PKG_MLF_IMPNFERECEBIMENTO.SP_CONSISTEIMPNFE(nfi.seqnotafiscal, nfi.nroempresa, 1);
                    end if;
                    -- 0 = NF com Inconsistência 1 = NF Sem Inconsistência
                    if fverificainconsistencia(nfi.seqnotafiscal) = 1 then
                       -- Importa Recebimento
                       PKG_MLF_IMPNFERECEBIMENTO.SP_IMPORTA_TMP ( nfi.seqnotafiscal, vnCGO, nfi.nroempresa, SYSDATE, 'CONSINCO', 0, vnOK, nfi.Chaveacesso );
                    end if;
                else
                    DELETE FROM MRL_NFEITEMPEDIDO WHERE SEQNOTAFISCAL = nfi.seqnotafiscal;
                end if;
            END IF;
        --RC 200964
        COMMIT;
        END LOOP;
      END LOOP;
   END IF;
 END SP_GeraRecebtoXMLAuto;
