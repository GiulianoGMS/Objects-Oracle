create or replace procedure sp_msu_atuprecofornec_Nag(psUsuario ge_usuario.codusuario%type,
                                                  pnNroEmpresa max_empresa.nroempresa%type)
  
-- Essa Proc permite atualizar custo dos pedidos mesmo que ja estejam amarrados na segunda tela do recebimento
  -- Giuliano 17/06/2025
  
  is
  vnVlrEmbItem                         msu_psitemreceber.vlrembitem%type;
  vnVlrEmbIPI                          msu_psitemreceber.vlrembipi%type;
  vnVlrEmbICMSST                       msu_psitemreceber.vlrembicmsst%type;
  vnVlrEmbDespesa                      msu_psitemreceber.vlrembdespesa%type;
  vnVlrEmbDesconto                     msu_psitemreceber.vlrembdesconto%type;
  vnVlrEmbVerbaCompra                  msu_psitemreceber.vlrembverbacompra%type;
  vnVlrEmbFCPST                        msu_psitemreceber.vlrembfcpst%type;
  vnPercDescFinanc                     msu_psitemreceber.percdescfinancitem%type;
  vnPercAcordoCom1                     msu_psitemreceber.percacordocom1%type;
  vnPercAcordoCom2                     msu_psitemreceber.percacordocom2%type;
  vnPercAcordoCom3                     msu_psitemreceber.percacordocom3%type;
  vnPercAcordoCom4                     msu_psitemreceber.percacordocom4%type;
  vnPercAcordoCom5                     msu_psitemreceber.percacordocom5%type;
  vnPercAcordoCom6                     msu_psitemreceber.percacordocom6%type;
  vbEncontrou                          boolean;
  vbAtualizou                          boolean;
  vnQtdEmbalagem                       msu_psitemreceber.qtdembalagem%Type;
  vnSeqFornecedor                      Msu_Pedidosuprim.seqfornecedor%Type;
  vnSeqFamilia                         map_produto.seqfamilia%Type;
  vnNrodivisao                         max_empresa.nrodivisao%Type;
  vsUf                                 max_empresa.uf%Type;
  vsPDUtilCustoPorEmpresa              MAX_PARAMETRO.VALOR%TYPE;
  vnVlrEmbVerbaCompraAcr               msu_psitemreceber.vlrembverbacompracr%type;
  vsPD_AtuVerbaBonifCompraCentr        MAX_PARAMETRO.VALOR%TYPE;
  vnNroEmpresaVerba                    MAX_EMPRESA.NROEMPRESA%TYPE;
  vnAchouCustoVerba                    NUMBER;
  vnSeqCustoFornecVerbaAtu             MSU_PSITEMRECEBER.SEQCUSTOFORNECVERBAATU%TYPE;
  vsPDUtilPercAcordoCom                MAX_PARAMETRO.VALOR%TYPE;
  vtpVerificaControleOrcaCompras       PKG_LIMCOMPRA.TP_VerificaControleOrcaCompras;
  vnProdutoRecebido                    NUMBER;
  vbCancela                            BOOLEAN;
  vnVlrBaseIBSMun                      MSU_PSITEMRECEBER.VLRBASEIBSMUN%type;
  vnPerAliqIBSMun                      MSU_PSITEMRECEBER.PERALIQIBSMUN%type;
  vnVlrImpostoIBSMun                   MSU_PSITEMRECEBER.VLRIMPOSTOIBSMUN%type;
  vnPerAliqRedIBSMun                   MSU_PSITEMRECEBER.PERALIQREDIBSMUN%type;
  vsFormulaIBSMun                      MSU_PSITEMRECEBER.FORMULAIBSMUN%type;
  vnCenarioIBSMun                      MSU_PSITEMRECEBER.CENARIOIBSMUN%type;
  vnVlrBaseIBSUF                       MSU_PSITEMRECEBER.VLRBASEIBSUF%type;
  vnPerAliqIBSUF                       MSU_PSITEMRECEBER.PERALIQIBSUF%type;
  vnVlrImpostoIBSUF                    MSU_PSITEMRECEBER.VLRIMPOSTOIBSUF%type;
  vnPerAliqRedIBSUF                    MSU_PSITEMRECEBER.PERALIQREDIBSUF%type;
  vsFormulaIBSUF                       MSU_PSITEMRECEBER.FORMULAIBSUF%type;
  vnCenarioIBSUF                       MSU_PSITEMRECEBER.CENARIOIBSUF%type;
  vnVlrBaseCBS                         MSU_PSITEMRECEBER.VLRBASECBS%type;
  vnPerAliqCBS                         MSU_PSITEMRECEBER.PERALIQCBS%type;
  vnVlrImpostoCBS                      MSU_PSITEMRECEBER.VLRIMPOSTOCBS%type;
  vnPerAliqRedCBS                      MSU_PSITEMRECEBER.PERALIQREDCBS%type;
  vsFormulaCBS                         MSU_PSITEMRECEBER.FORMULACBS%type;
  vnCenarioCBS                         MSU_PSITEMRECEBER.CENARIOCBS%type;
  vnVlrBaseIS                          MSU_PSITEMRECEBER.VLRBASEIS%type;
  vnPerAliqIS                          MSU_PSITEMRECEBER.PERALIQIS%type;
  vnVlrImpostoIS                       MSU_PSITEMRECEBER.VLRIMPOSTOIS%type;
  vnPerAliqRedIS                       MSU_PSITEMRECEBER.PERALIQREDIS%type;
  vsFormulaIS                          MSU_PSITEMRECEBER.FORMULAIS%type;
  vnCenarioIS                          MSU_PSITEMRECEBER.CENARIOIS%type;
  vnVlrTributos                        MSU_PSITEMRECEBER.VLRTRIBUTOS%type;
  vnVlrImpostoCompra                   MSU_PSITEMRECEBER.VLRIMPOSTOCOMPRA%type;
  vtpLimiteCompradorFonecedorCategoria PKG_LIMCOMPRA.TP_LimiteCompradorFonecedorCategoria;
  vsPDUtilControleOrcaCompras          MAX_PARAMETRO.VALOR%type;
  TYPE tpPedidos IS RECORD (
    NroPedidoSuprim MSUX_ATU_PSITEMRECEBER.NROPEDIDOSUPRIM%TYPE,
    NroEmpresa      MSUX_ATU_PSITEMRECEBER.NROEMPRESA%TYPE,
    CentralLoja     MSUX_ATU_PSITEMRECEBER.CENTRALLOJA%TYPE,
    TipoSelecao     MSUX_ATU_PSITEMRECEBER.TIPOSELECAO%TYPE
  );
  TYPE tbPedidos IS TABLE OF tpPedidos;
  vtpPedidos tbPedidos;
  TYPE tpItens IS RECORD (
    SeqProduto MSUX_ATU_PSITEMRECEBER.SEQPRODUTO%TYPE
  );
  TYPE tbItens IS TABLE OF tpItens;
  vtpItens tbItens;
BEGIN
  PKG_GE_PDMEMORIA.SP_HABILITAPDMEMORIA();
  SELECT SUBSTR( NVL( FC5MAXPARAMETRO( 'TAB_CUSTO_FORNEC', 0, 'UTIL_CUSTO_POR_EMPRESA' ), 'N' ), 1, 1 ),
         SUBSTR(FC5MAXPARAMETRO('GER_COMPRAS', 0, 'ATU_VERBABONIF_COMPRACENTR'),1,1),
         SUBSTR( NVL( FC5MAXPARAMETRO( 'TAB_CUSTO_FORNEC', 0, 'UTIL_PERC_ACORDO_COM' ), 'S' ), 1, 1 ),
         SUBSTR(NVL(FC5MAXPARAMETRO('PED_COMPRA', 0, 'UTIL_CONTROLE_ORCA_COMPRAS'), 'S'), 1, 1)
  INTO   vsPDUtilCustoPorEmpresa,
         vsPD_AtuVerbaBonifCompraCentr,
         vsPDUtilPercAcordoCom,
         vsPDUtilControleOrcaCompras
  FROM   DUAL;
  vbAtualizou := FALSE;
  SELECT X.NROPEDIDOSUPRIM,
         X.NROEMPRESA,
         X.CENTRALLOJA,
         X.TIPOSELECAO
  BULK COLLECT INTO vtpPedidos
    FROM MSUX_ATU_PSITEMRECEBER X
   WHERE (X.INDATUALIZADO != 'S' OR X.INDATUALIZADO IS NULL OR X.INDATUALIZADO != 'X')
   GROUP BY X.NROPEDIDOSUPRIM, X.NROEMPRESA, X.CENTRALLOJA, X.TIPOSELECAO
   ORDER BY X.NROPEDIDOSUPRIM, X.NROEMPRESA, X.CENTRALLOJA, X.TIPOSELECAO;
  IF vtpPedidos.Count > 0 THEN
    FOR I IN vtpPedidos.first .. vtpPedidos.last
    LOOP
      BEGIN
        vtpVerificaControleOrcaCompras.pnNroPedido := vtpPedidos(i).NroPedidoSuprim;
        vtpVerificaControleOrcaCompras.psCentralLoja := vtpPedidos(i).CentralLoja;
        vtpVerificaControleOrcaCompras.pnNroEmpresa := vtpPedidos(i).NroEmpresa;
        vtpVerificaControleOrcaCompras.pbReplicaPedido := FALSE;
        vtpVerificaControleOrcaCompras.pnNroEmpresaApp := pnNroEmpresa;
        DELETE FROM GEX_DADOSTEMPORARIOS WHERE STRING1 = 'SP_MSU_ATUPRECOFORNEC';
        SELECT X.SEQPRODUTO
          BULK COLLECT INTO vtpItens
          FROM MSUX_ATU_PSITEMRECEBER X
         WHERE (X.INDATUALIZADO != 'S' OR X.INDATUALIZADO IS NULL OR X.INDATUALIZADO != 'X')
           AND X.NROPEDIDOSUPRIM = vtpPedidos(i).NroPedidoSuprim
           AND X.NROEMPRESA = vtpPedidos(i).NroEmpresa
           AND X.CENTRALLOJA = vtpPedidos(i).CentralLoja
         ORDER BY X.NROPEDIDOSUPRIM, X.NROEMPRESA, X.CENTRALLOJA, X.SEQPRODUTO;
        IF vtpItens.Count > 0 THEN
          FOR t IN vtpItens.first .. vtpItens.last
          LOOP
            BEGIN
              SELECT COUNT(*)
                INTO vnProdutoRecebido
                FROM MSUV_PSITEMRECEBER R
               INNER JOIN MAP_PRODUTO P
                  ON P.SEQPRODUTO = R.SEQPRODUTO
               WHERE P.SEQPRODUTO = vtpItens(t).SeqProduto
                 AND NROPEDIDOSUPRIM = vtpPedidos(i).NroPedidoSuprim
                 AND NROEMPRESA = vtpPedidos(i).NroEmpresa
                 AND CENTRALLOJA = vtpPedidos(i).CentralLoja
                 AND R.QTDSALDO > 0
                 --AND R.QTDTOTTRANSITO = 0
                 AND R.QTDCANCELADA = 0;
                 --AND R.QTDRECEBIDA = 0;
              IF (vtpPedidos(i).TipoSelecao = 'P') AND (vnProdutoRecebido = 0) THEN
                UPDATE MSUX_ATU_PSITEMRECEBER A
                   SET A.OBSERVACAO = 'Produto já recebido.',
                       A.INDATUALIZADO = 'X'
                 WHERE A.NROPEDIDOSUPRIM = vtpPedidos(i).NroPedidoSuprim
                   AND A.NROEMPRESA = vtpPedidos(i).NroEmpresa
                   AND A.CENTRALLOJA = vtpPedidos(i).CentralLoja
                   AND A.SEQPRODUTO = vtpItens(t).SeqProduto;
                CONTINUE;
              END IF;
              -- busca valores atualizados (empresa excessao ou geral)
              vbEncontrou := TRUE;
              -- busca dados do pedido
              Select c.qtdembalagem, c.seqfornecedor, d.seqfamilia, e.nrodivisao, e.uf
              Into   vnQtdEmbalagem, vnSeqFornecedor, vnSeqFamilia, vnNrodivisao, vsUf
              From   msuv_psitemreceber c, map_produto d, max_empresa e
              Where  c.nropedidosuprim = vtpPedidos(i).NroPedidoSuprim
              and    c.centralloja = vtpPedidos(i).CentralLoja
              and    c.nroempresa = vtpPedidos(i).NroEmpresa
              and    c.seqproduto = vtpItens(t).SeqProduto
              And    d.seqproduto = c.seqproduto
              And    e.nroempresa = c.nroempresa;
              -- busca valores de custo
              -- 139228 Por Empresa
              IF vsPDUtilCustoPorEmpresa = 'S' THEN
                BEGIN
                  SELECT  nvl(f.VLRCOMDESCTO  * vnQtdEmbalagem, 0),
                          nvl(f.VLRIPI        * vnQtdEmbalagem, 0),
                          nvl(f.VLRICMSST     * vnQtdEmbalagem, 0),
                          nvl((NVL(F.VLRVENDOR,0) + NVL(F.VLRFRETE,0) + NVL(F.VLRDESPESAS,0)) * vnQtdEmbalagem, 0),
                          nvl(f.VLRDESCONTO   * vnQtdEmbalagem, 0),
                          nvl(f.VLRVERBABONIF * vnQtdEmbalagem, 0),
                          nvl(f.VLRFCPST      * vnQtdEmbalagem, 0),
                          NVL(FMSU_PERCDESCFINANCFORNEC(vnSeqFornecedor, vtpItens(t).seqproduto, vtpPedidos(i).nroempresa),0),
                          nvl(f.VLRVERBABONIFACR * vnQtdEmbalagem, 0),
                          nvl(f.PERCACORDOCOM1,0),
                          nvl(f.PERCACORDOCOM2,0),
                          nvl(f.PERCACORDOCOM3,0),
                          nvl(f.PERCACORDOCOM4,0),
                          nvl(f.PERCACORDOCOM5,0),
                          nvl(f.PERCACORDOCOM6,0),
                          nvl(f.VLRBASEIBSMUN, 0),
                          nvl(f.PERALIQIBSMUN, 0),
                          nvl(f.PERALIQREDIBSMUN, 0),
                          nvl(f.VLRIMPOSTOIBSMUN, 0),
                          nvl(f.FORMULAIBSMUN, ''),
                          nvl(f.CENARIOIBSMUN, 0),
                          nvl(f.VLRBASEIBSUF, 0),
                          nvl(f.PERALIQIBSUF, 0),
                          nvl(f.VLRIMPOSTOIBSUF, 0),
                          nvl(f.PERALIQREDIBSUF, 0),
                          nvl(f.FORMULAIBSUF, ''),
                          nvl(f.CENARIOIBSUF, 0),
                          nvl(f.VLRBASECBS, 0),
                          nvl(f.PERALIQCBS, 0),
                          nvl(f.VLRIMPOSTOCBS, 0),
                          nvl(f.PERALIQREDCBS, 0),
                          nvl(f.FORMULACBS, ''),
                          nvl(f.CENARIOCBS, 0),
                          nvl(f.VLRBASEIS, 0),
                          nvl(f.PERALIQIS, 0),
                          nvl(f.VLRIMPOSTOIS, 0),
                          nvl(f.PERALIQREDIS, 0),
                          nvl(f.FORMULAIS, ''),
                          nvl(f.CENARIOIS, 0),
                          nvl(f.VLRTRIBUTOS, 0),
                          nvl(f.VLRIMPOSTOCOMPRA, 0)
                  into    vnVlrEmbItem,
                          vnVlrEmbIPI,
                          vnVlrEmbICMSST,
                          vnVlrEmbDespesa,
                          vnVlrEmbDesconto,
                          vnVlrEmbVerbaCompra,
                          vnVlrEmbFCPST,
                          vnPercDescFinanc,
                          vnVlrEmbVerbaCompraAcr,
                          vnPercAcordoCom1,
                          vnPercAcordoCom2,
                          vnPercAcordoCom3,
                          vnPercAcordoCom4,
                          vnPercAcordoCom5,
                          vnPercAcordoCom6,
                          vnVlrBaseIBSMun,
                          vnPerAliqIBSMun,
                          vnVlrImpostoIBSMun,
                          vnPerAliqRedIBSMun,
                          vsFormulaIBSMun,
                          vnCenarioIBSMun,
                          vnVlrBaseIBSUF,
                          vnPerAliqIBSUF,
                          vnVlrImpostoIBSUF,
                          vnPerAliqRedIBSUF,
                          vsFormulaIBSUF,
                          vnCenarioIBSUF,
                          vnVlrBaseCBS,
                          vnPerAliqCBS,
                          vnVlrImpostoCBS,
                          vnPerAliqRedCBS,
                          vsFormulaCBS,
                          vnCenarioCBS,
                          vnVlrBaseIS,
                          vnPerAliqIS,
                          vnVlrImpostoIS,
                          vnPerAliqRedIS,
                          vsFormulaIS,
                          vnCenarioIS,
                          vnVlrTributos,
                          vnVlrImpostoCompra
                  from   macv_custocompraufvalida f
                  where  f.Seqfamilia      = vnSeqFamilia
                  And    f.Nroempresa      = vtpPedidos(i).NroEmpresa
                  And    f.Seqfornecedor   = vnSeqFornecedor
                  And    f.Nrodivisao      = vnNrodivisao
                  and    f.UFEMPRESA       = vsUf;
                  IF vnVlrEmbItem = 0 THEN
                    vbEncontrou := FALSE;
                  END IF;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    vbEncontrou := FALSE;
                END;
              END IF;
              -- 139228 Empresa Geral
              IF vsPDUtilCustoPorEmpresa != 'S' OR NOT vbEncontrou THEN
                BEGIN
                  vbEncontrou := TRUE;
                  SELECT nvl(f.VLRCOMDESCTO  * vnQtdEmbalagem, 0),
                         nvl(f.VLRIPI        * vnQtdEmbalagem, 0),
                         nvl(f.VLRICMSST     * vnQtdEmbalagem, 0),
                         nvl((NVL(F.VLRVENDOR,0) + NVL(F.VLRFRETE,0) + NVL(F.VLRDESPESAS,0)) * vnQtdEmbalagem, 0),
                         nvl(f.VLRDESCONTO   * vnQtdEmbalagem, 0),
                         nvl(f.VLRVERBABONIF * vnQtdEmbalagem, 0),
                         nvl(f.VLRFCPST      * vnQtdEmbalagem, 0),
                         NVL(FMSU_PERCDESCFINANCFORNEC(vnSeqFornecedor, vtpItens(t).seqproduto, vtpPedidos(i).nroempresa),0),
                         nvl(f.VLRVERBABONIFACR * vnQtdEmbalagem, 0),
                         nvl(f.PERCACORDOCOM1,0),
                         nvl(f.PERCACORDOCOM2,0),
                         nvl(f.PERCACORDOCOM3,0),
                         nvl(f.PERCACORDOCOM4,0),
                         nvl(f.PERCACORDOCOM5,0),
                         nvl(f.PERCACORDOCOM6,0),
                         nvl(f.VLRBASEIBSMUN, 0),
                         nvl(f.PERALIQIBSMUN, 0),
                         nvl(f.VLRIMPOSTOIBSMUN, 0),
                         nvl(f.PERALIQREDIBSMUN, 0),
                         nvl(f.FORMULAIBSMUN, ''),
                         nvl(f.CENARIOIBSMUN, 0),
                         nvl(f.VLRBASEIBSUF, 0),
                         nvl(f.PERALIQIBSUF, 0),
                         nvl(f.VLRIMPOSTOIBSUF, 0),
                         nvl(f.PERALIQREDIBSUF, 0),
                         nvl(f.FORMULAIBSUF, ''),
                         nvl(f.CENARIOIBSUF, 0),
                         nvl(f.VLRBASECBS, 0),
                         nvl(f.PERALIQCBS, 0),
                         nvl(f.VLRIMPOSTOCBS, 0),
                         nvl(f.PERALIQREDCBS, 0),
                         nvl(f.FORMULACBS, ''),
                         nvl(f.CENARIOCBS, 0),
                         nvl(f.VLRBASEIS, 0),
                         nvl(f.PERALIQIS, 0),
                         nvl(f.VLRIMPOSTOIS, 0),
                         nvl(f.PERALIQREDIS, 0),
                         nvl(f.FORMULAIS, ''),
                         nvl(f.CENARIOIS, 0),
                         nvl(f.VLRTRIBUTOS, 0),
                         nvl(f.VLRIMPOSTOCOMPRA, 0)
                  into   vnVlrEmbItem,
                         vnVlrEmbIPI,
                         vnVlrEmbICMSST,
                         vnVlrEmbDespesa,
                         vnVlrEmbDesconto,
                         vnVlrEmbVerbaCompra,
                         vnVlrEmbFCPST,
                         vnPercDescFinanc,
                         vnVlrEmbVerbaCompraAcr,
                         vnPercAcordoCom1,
                         vnPercAcordoCom2,
                         vnPercAcordoCom3,
                         vnPercAcordoCom4,
                         vnPercAcordoCom5,
                         vnPercAcordoCom6,
                         vnVlrBaseIBSMun,
                         vnPerAliqIBSMun,
                         vnVlrImpostoIBSMun,
                         vnPerAliqRedIBSMun,
                         vsFormulaIBSMun,
                         vnCenarioIBSMun,
                         vnVlrBaseIBSUF,
                         vnPerAliqIBSUF,
                         vnVlrImpostoIBSUF,
                         vnPerAliqRedIBSUF,
                         vsFormulaIBSUF,
                         vnCenarioIBSUF,
                         vnVlrBaseCBS,
                         vnPerAliqCBS,
                         vnVlrImpostoCBS,
                         vnPerAliqRedCBS,
                         vsFormulaCBS,
                         vnCenarioCBS,
                         vnVlrBaseIS,
                         vnPerAliqIS,
                         vnVlrImpostoIS,
                         vnPerAliqRedIS,
                         vsFormulaIS,
                         vnCenarioIS,
                         vnVlrTributos,
                         vnVlrImpostoCompra
                  from   macv_custocompraufvalida f
                  where  f.Seqfamilia      = vnSeqFamilia
                  And    f.Nroempresa      = 0
                  And    f.Seqfornecedor   = vnSeqFornecedor
                  And    f.Nrodivisao      = vnNrodivisao
                  and    f.UFEMPRESA       = vsUf;
                  IF vnVlrEmbItem = 0 THEN
                    -- Grava nao atualizacao
                    vbEncontrou := FALSE;
                    update msux_atu_psitemreceber a
                    set    a.indatualizado   = 'X'
                    where  a.nropedidosuprim = vtpPedidos(i).NroPedidoSuprim
                    and    a.nroempresa      = vtpPedidos(i).NroEmpresa
                    and    a.centralloja     = vtpPedidos(i).CentralLoja
                    and    a.seqproduto      = vtpItens(t).SeqProduto;
                  END IF;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                  -- grava "não-atualização"
                  vbEncontrou := FALSE;
                  update msux_atu_psitemreceber a
                  set    a.indatualizado   = 'X'
                  where  a.nropedidosuprim = vtpPedidos(i).NroPedidoSuprim
                  and    a.nroempresa      = vtpPedidos(i).NroEmpresa
                  and    a.centralloja     = vtpPedidos(i).CentralLoja
                  and    a.seqproduto      = vtpItens(t).SeqProduto;
                END;
              END IF;
              IF vsPD_AtuVerbaBonifCompraCentr = 'N' THEN
                vnAchouCustoVerba := 0;
                SELECT MAX(A.SEQCUSTOFORNECVERBAATU)
                  INTO vnSeqCustoFornecVerbaAtu
                  FROM MSU_PSITEMRECEBER A
                 WHERE A.NROPEDIDOSUPRIM = vtpPedidos(i).NroPedidoSuprim
                   AND A.SEQPRODUTO      = vtpItens(t).SeqProduto
                   AND A.CENTRALLOJA     = vtpPedidos(i).CentralLoja
                   AND A.NROEMPRESA      = vtpPedidos(i).NroEmpresa;
                IF vnSeqCustoFornecVerbaAtu IS NOT NULL THEN
                  SELECT A.NROEMPRESA,
                         A.SEQFORNECEDOR,
                         A.NRODIVISAO,
                         A.UFEMPRESA
                    INTO vnNroEmpresaVerba,
                         vnSeqFornecedor,
                         vnNrodivisao,
                         vsUf
                    FROM MAC_CUSTOFORNECLOG A
                   WHERE A.SEQCUSTOFORNEC = vnSeqCustoFornecVerbaAtu;
                  SELECT COUNT(1)
                    INTO vnAchouCustoVerba
                    FROM MACV_CUSTOCOMPRAUFVALIDA A
                   WHERE A.NROEMPRESA    = vnNroEmpresaVerba
                     AND A.SEQFORNECEDOR = vnSeqFornecedor
                     AND A.NRODIVISAO    = vnNrodivisao
                     AND A.UFEMPRESA     = vsUf
                     AND A.SEQFAMILIA    = vnSeqFamilia;
                  BEGIN
                    SELECT NVL(A.VLRVERBABONIF * vnQtdEmbalagem, 0),
                           A.PERCACORDOCOM1,
                           A.PERCACORDOCOM2,
                           A.PERCACORDOCOM3,
                           A.PERCACORDOCOM4,
                           A.PERCACORDOCOM5,
                           A.PERCACORDOCOM6
                      INTO vnVlrEmbVerbaCompra,
                           vnPercAcordoCom1,
                           vnPercAcordoCom2,
                           vnPercAcordoCom3,
                           vnPercAcordoCom4,
                           vnPercAcordoCom5,
                           vnPercAcordoCom6
                      FROM MACV_CUSTOCOMPRAUFVALIDA A
                     WHERE A.NROEMPRESA    = DECODE(vnAchouCustoVerba,1 , vnNroEmpresaVerba,0)
                       AND A.SEQFORNECEDOR = vnSeqFornecedor
                       AND A.NRODIVISAO    = vnNrodivisao
                       AND A.UFEMPRESA     = vsUf
                       AND A.SEQFAMILIA    = vnSeqFamilia;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      vnAchouCustoVerba := 0;
                  END;
                END IF;
              END IF;
              if vbEncontrou then
                if vsPDUtilPercAcordoCom = 'N' then
                  if vnVlrEmbVerbaCompra != 0
                     and NVL(vnPercAcordoCom1,0) = 0 and NVL(vnPercAcordoCom2,0) = 0
                     and NVL(vnPercAcordoCom3,0) = 0 and NVL(vnPercAcordoCom4,0) = 0
                     and NVL(vnPercAcordoCom5,0) = 0 and NVL(vnPercAcordoCom6,0) = 0
                  then
                    if NVL(vnVlrEmbItem, 0) > 0 and vnVlrEmbVerbaCompra > 0 then
                      -- Calcula o percentual correspondente ao valor de Verba
                      vnPercAcordoCom1 := (vnVlrEmbVerbaCompra * 100) / vnVlrEmbItem;
                    else
                      vnPercAcordoCom1 := NULL;
                    end if;
                  elsif vnVlrEmbVerbaCompra = 0 then
                    vnPercAcordoCom1 := 0;
                    vnPercAcordoCom2 := 0;
                    vnPercAcordoCom3 := 0;
                    vnPercAcordoCom4 := 0;
                    vnPercAcordoCom5 := 0;
                    vnPercAcordoCom6 := 0;
                  end if;
                end if;
                -- Guarda valores antes da atualização pro limite
                INSERT INTO GEX_DADOSTEMPORARIOS(
                       STRING1,
                       STRING2,
                       NUMBER1,
                       NUMBER2,
                       NUMBER3,
                       NUMBER4,
                       NUMBER5,
                       NUMBER6,
                       NUMBER7,
                       NUMBER8,
                       NUMBER9)
                SELECT 'SP_MSU_ATUPRECOFORNEC',
                       A.CENTRALLOJA,
                       A.NROPEDIDOSUPRIM,
                       A.NROEMPRESA,
                       A.SEQPRODUTO,
                       A.QTDEMBALAGEM,
                       A.QTDSOLICITADA,
                       A.QTDTOTCANCELADA,
                       A.SEQSLDLIMCOMPRACOMPRADOR,
                       A.SEQSLDLIMCOMPRAFORNECEDOR,
                       A.SEQSLDLIMCOMPRACATEGORIA
                  FROM MSU_PSITEMRECEBER A
                 WHERE A.NROPEDIDOSUPRIM = vtpPedidos(i).NroPedidoSuprim
                   AND A.NROEMPRESA = vtpPedidos(i).NroEmpresa
                   AND A.CENTRALLOJA = vtpPedidos(i).CentralLoja
                   AND A.SEQPRODUTO = vtpItens(t).SeqProduto;
                -- atualiza valores
                update msu_psitemreceber a
                set -- registra valores antigos e usuário alteração
                       a.vlrembitem_ant        = a.vlrembitem,
                       a.vlrembipi_ant         = a.vlrembipi,
                       a.vlrembicmsst_ant      = a.vlrembicmsst,
                       a.vlrembdespesa_ant     = a.vlrembdespesa,
                       a.vlrembverbacompra_ant = a.vlrembverbacompra,
                       a.vlrembdesconto_ant    = a.vlrembdesconto,
                       a.vlrbaseibsmun_ant     = a.vlrbaseibsmun,
                       a.peraliqibsmun_ant     = a.peraliqibsmun,
                       a.vlrimpostoibsmun_ant  = a.vlrimpostoibsmun,
                       a.peraliqredibsmun_ant  = a.peraliqredibsmun,
                       a.formulaibsmun_ant     = a.formulaibsmun,
                       a.cenarioibsmun_ant     = a.cenarioibsmun,
                       a.vlrbaseibsuf_ant      = a.vlrbaseibsuf,
                       a.peraliqibsuf_ant      = a.peraliqibsuf,
                       a.vlrimpostoibsuf_ant   = a.vlrimpostoibsuf,
                       a.peraliqredibsuf_ant   = a.peraliqredibsuf,
                       a.formulaibsuf_ant      = a.formulaibsuf,
                       a.cenarioibsuf_ant      = a.cenarioibsuf,
                       a.vlrbasecbs_ant        = a.vlrbasecbs,
                       a.peraliqcbs_ant        = a.peraliqcbs,
                       a.vlrimpostocbs_ant     = a.vlrimpostocbs,
                       a.peraliqredcbs_ant     = a.peraliqredcbs,
                       a.formulacbs_ant        = a.formulacbs,
                       a.cenariocbs_ant        = a.cenariocbs,
                       a.vlrbaseis_ant         = a.vlrbaseis,
                       a.peraliqis_ant         = a.peraliqis,
                       a.vlrimpostois_ant      = a.vlrimpostois,
                       a.peraliqredis_ant      = a.peraliqredis,
                       a.formulais_ant         = a.formulais,
                       a.cenariois_ant         = a.cenariois,
                       a.vlrtributos_ant       = a.vlrtributos,
                       a.vlrimpostocompra_ant  = a.vlrimpostocompra,
                       -- atualiza valores
                       a.vlrunitario           = (vnVlrEmbItem / vnQtdEmbalagem),
                       a.usualteracao          = psUsuario,
                       a.dtaalteracao          = sysdate,
                       a.vlrembitem            = vnVlrEmbItem,
                       a.vlrembipi             = vnVlrEmbIPI,
                       a.vlrembicmsst          = vnVlrEmbICMSST,
                       a.vlrembdespesa         = vnVlrEmbDespesa,
                       a.vlrembverbacompra     = vnVlrEmbVerbaCompra,
                       a.vlrembdesconto        = vnVlrEmbDesconto,
                       a.vlrembfcpst           = vnVlrEmbFCPST,
                       a.percdescfinancitem    = vnPercDescFinanc,
                       a.vlrembverbacompracr   = vnVlrEmbVerbaCompraAcr,
                       a.percacordocom1        = vnPercAcordoCom1,
                       a.percacordocom2        = vnPercAcordoCom2,
                       a.percacordocom3        = vnPercAcordoCom3,
                       a.percacordocom4        = vnPercAcordoCom4,
                       a.percacordocom5        = vnPercAcordoCom5,
                       a.percacordocom6        = vnPercAcordoCom6,
                       a.vlrbaseibsmun         = vnVlrBaseIBSMun,
                       a.peraliqibsmun         = vnPerAliqIBSMun,
                       a.vlrimpostoibsmun      = vnVlrImpostoIBSMun,
                       a.peraliqredibsmun      = vnPerAliqRedIBSMun,
                       a.formulaibsmun         = vsFormulaIBSMun,
                       a.cenarioibsmun         = vnCenarioIBSMun,
                       a.vlrbaseibsuf          = vnVlrBaseIBSUF,
                       a.peraliqibsuf          = vnPerAliqIBSUF,
                       a.vlrimpostoibsuf       = vnVlrImpostoIBSUF,
                       a.peraliqredibsuf       = vnPerAliqRedIBSUF,
                       a.formulaibsuf          = vsFormulaIBSUF,
                       a.cenarioibsuf          = vnCenarioIBSUF,
                       a.vlrbasecbs            = vnVlrBaseCBS,
                       a.peraliqcbs            = vnPerAliqCBS,
                       a.vlrimpostocbs         = vnVlrImpostoCBS,
                       a.peraliqredcbs         = vnPerAliqRedCBS,
                       a.formulacbs            = vsFormulaCBS,
                       a.cenariocbs            = vnCenarioCBS,
                       a.vlrbaseis             = vnVlrBaseIS,
                       a.peraliqis             = vnPerAliqIS,
                       a.vlrimpostois          = vnVlrImpostoIS,
                       a.peraliqredis          = vnPerAliqRedIS,
                       a.formulais             = vsFormulaIS,
                       a.cenariois             = vnCenarioIS,
                       a.vlrtributos           = vnVlrTributos,
                       a.vlrimpostocompra      = vnVlrImpostoCompra
                 where a.nropedidosuprim = vtpPedidos(i).NroPedidoSuprim
                   and a.nroempresa = vtpPedidos(i).NroEmpresa
                   and a.centralloja = vtpPedidos(i).CentralLoja
                   and a.seqproduto = vtpItens(t).SeqProduto;
                -- grava informações já atualizadas
                update msux_atu_psitemreceber a
                   set a.indatualizado = 'S'
                 where a.nropedidosuprim = vtpPedidos(i).NroPedidoSuprim
                   and a.nroempresa = vtpPedidos(i).NroEmpresa
                   and a.centralloja = vtpPedidos(i).CentralLoja
                   and a.seqproduto = vtpItens(t).SeqProduto;
                -- atualiza a variavel indicando que algum foi atualizado
                vbAtualizou := TRUE;
              end if;
              IF vbAtualizou THEN
                SELECT A.TIPPEDIDOSUPRIM,
                       A.SEQCOMPRADOR,
                       A.DTAEMISSAO,
                       A.DTARECEBTO,
                       A.DTALIMITERECEBTO,
                       A.PZOPAGAMENTO,
                       A.SEQCONDCONDPRAZOPAGTO,
                       A.VLRTOTPEDIDO,
                       (SELECT D.NRODIVISAO
                          FROM MAX_EMPRESA D
                         WHERE D.NROEMPRESA = A.NROEMPRESA) AS NRODIVISAO
                  INTO vtpVerificaControleOrcaCompras.psTipoPedido,
                       vtpVerificaControleOrcaCompras.pnSeqComprador,
                       vtpVerificaControleOrcaCompras.pdDtaEmissao,
                       vtpVerificaControleOrcaCompras.pdDtaRecebto,
                       vtpVerificaControleOrcaCompras.pdDtaLimRecebto,
                       vtpVerificaControleOrcaCompras.psPrazoPgto,
                       vtpVerificaControleOrcaCompras.pnCondPrazoPagto,
                       vtpVerificaControleOrcaCompras.pnTotalPedido,
                       vtpVerificaControleOrcaCompras.pnNroDivisao
                  FROM MSUX_ATU_PSITEMRECEBER Z, MSU_PEDIDOSUPRIM A
                 WHERE (Z.INDATUALIZADO != 'S' OR Z.INDATUALIZADO IS NULL OR Z.INDATUALIZADO != 'X')
                   AND Z.NROPEDIDOSUPRIM = vtpPedidos(i).NroPedidoSuprim
                   AND Z.CENTRALLOJA = vtpPedidos(i).CentralLoja
                   AND Z.NROEMPRESA = vtpPedidos(i).NroEmpresa
                   AND Z.NROPEDIDOSUPRIM = A.NROPEDIDOSUPRIM
                   AND Z.CENTRALLOJA = A.CENTRALLOJA
                   AND Z.NROEMPRESA = A.NROEMPRESA
                   AND Z.SEQPRODUTO = vtpItens(t).SeqProduto;
              END IF;
              IF (vtpPedidos(i).TipoSelecao = 'I') AND vbAtualizou THEN
                IF vnProdutoRecebido = 0 THEN
                  vbCancela := TRUE;
                  vtpVerificaControleOrcaCompras.psMensagem := 'Produto já recebido.';
                ELSIF (NOT PKG_LIMCOMPRA.F_VERIFICACONTROLEORCACOMPRAS(vtpVerificaControleOrcaCompras)) THEN
                  vbCancela := TRUE;
                ELSE
                  vbCancela := FALSE;
                END IF;
                IF vbCancela THEN
                  ROLLBACK;
                  UPDATE MSUX_ATU_PSITEMRECEBER A
                     SET A.OBSERVACAO = vtpVerificaControleOrcaCompras.psMensagem,
                         A.INDATUALIZADO = 'X'
                   WHERE A.NROPEDIDOSUPRIM = vtpPedidos(i).NroPedidoSuprim
                     AND A.NROEMPRESA = vtpPedidos(i).NroEmpresa
                     AND A.CENTRALLOJA = vtpPedidos(i).CentralLoja
                     AND A.SEQPRODUTO = vtpItens(t).SeqProduto;
                  COMMIT;
                ELSE
                  COMMIT;
                END IF;
              ELSIF (vtpPedidos(i).TipoSelecao = 'I') AND NOT vbAtualizou THEN
                COMMIT;
              END IF;
            EXCEPTION WHEN OTHERS THEN
              ROLLBACK;
              UPDATE MSUX_ATU_PSITEMRECEBER A
                 SET A.INDATUALIZADO = 'X'
               WHERE A.NROPEDIDOSUPRIM = vtpPedidos(i).NroPedidoSuprim
                 AND A.NROEMPRESA = vtpPedidos(i).NroEmpresa
                 AND A.CENTRALLOJA = vtpPedidos(i).CentralLoja
                 AND A.SEQPRODUTO = vtpItens(t).SeqProduto;
              COMMIT;
            END;
          END LOOP;
        END IF;
        IF (vtpPedidos(i).TipoSelecao = 'P') AND vbAtualizou THEN
          IF (NOT PKG_LIMCOMPRA.F_VERIFICACONTROLEORCACOMPRAS(vtpVerificaControleOrcaCompras)) THEN
            ROLLBACK;
            UPDATE MSUX_ATU_PSITEMRECEBER A
               SET A.OBSERVACAO = vtpVerificaControleOrcaCompras.psMensagem,
                   A.INDATUALIZADO = 'X'
             WHERE A.NROPEDIDOSUPRIM = vtpPedidos(i).NroPedidoSuprim
               AND A.NROEMPRESA = vtpPedidos(i).NroEmpresa
               AND A.CENTRALLOJA = vtpPedidos(i).CentralLoja;
            COMMIT;
          ELSE
            COMMIT;
          END IF;
        ELSIF (vtpPedidos(i).TipoSelecao = 'P') AND NOT vbAtualizou THEN
          COMMIT;
        END IF;
        IF vsPDUtilControleOrcaCompras = 'S' THEN
          IF vbAtualizou THEN
            FOR PROD IN (SELECT A.*,
                                G.NUMBER4, --QtdEmbalagemOld
                                G.NUMBER5, --QtdSolicitadaOld
                                G.NUMBER6, --QtdTotCanceladaOld
                                G.NUMBER7, --SeqSldLimCompraCompradorOld
                                G.NUMBER8, --SeqSldLimCompraFornecedorOld
                                G.NUMBER9  --SeqSldLimCompraCategoriaOld
                           FROM MSU_PSITEMRECEBER A
                          INNER JOIN MSUX_ATU_PSITEMRECEBER Z
                             ON A.NROPEDIDOSUPRIM = Z.NROPEDIDOSUPRIM
                            AND A.CENTRALLOJA = Z.CENTRALLOJA
                            AND A.NROEMPRESA = Z.NROEMPRESA
                            AND A.SEQPRODUTO = Z.SEQPRODUTO
                          INNER JOIN GEX_DADOSTEMPORARIOS G
                             ON A.NROPEDIDOSUPRIM = G.NUMBER1
                            AND A.CENTRALLOJA = G.STRING2
                            AND A.NROEMPRESA = G.NUMBER2
                            AND A.SEQPRODUTO = G.NUMBER3
                          WHERE (Z.INDATUALIZADO != 'S' OR Z.INDATUALIZADO IS NULL OR Z.INDATUALIZADO != 'X')
                            AND A.NROPEDIDOSUPRIM = vtpPedidos(i).NroPedidoSuprim
                            AND A.CENTRALLOJA = vtpPedidos(i).CentralLoja
                            AND A.NROEMPRESA = vtpPedidos(i).NroEmpresa)
            LOOP
              BEGIN
                vtpLimiteCompradorFonecedorCategoria.pnNroPedido := PROD.NROPEDIDOSUPRIM;
                vtpLimiteCompradorFonecedorCategoria.psCentralLoja := PROD.CENTRALLOJA;
                vtpLimiteCompradorFonecedorCategoria.pnNroEmpresa := PROD.NROEMPRESA;
                vtpLimiteCompradorFonecedorCategoria.pnSeqProduto := PROD.SEQPRODUTO;
                vtpLimiteCompradorFonecedorCategoria.psOperacao := 'U';
                vtpLimiteCompradorFonecedorCategoria.pbExecutaUpdate := TRUE;
                vtpLimiteCompradorFonecedorCategoria.pnVlrEmbItemNew := PROD.VLREMBITEM;
                vtpLimiteCompradorFonecedorCategoria.pnVlrEmbDespesaNew := PROD.VLREMBDESPESA;
                vtpLimiteCompradorFonecedorCategoria.pnVlrEmbICMSSTNew := PROD.VLREMBICMSST;
                vtpLimiteCompradorFonecedorCategoria.pnVlrEmbIPINew := PROD.VLREMBIPI;
                vtpLimiteCompradorFonecedorCategoria.pnQtdEmbalagemNew := PROD.QTDEMBALAGEM;
                vtpLimiteCompradorFonecedorCategoria.pnQtdSolicitadaNew := PROD.QTDSOLICITADA;
                vtpLimiteCompradorFonecedorCategoria.pnVlrImpostoCompraNew := PROD.VLRIMPOSTOCOMPRA;
                vtpLimiteCompradorFonecedorCategoria.pnVlrEmbItemOld := PROD.VLREMBITEM_ANT;
                vtpLimiteCompradorFonecedorCategoria.pnVlrEmbDespesaOld := PROD.VLREMBDESPESA_ANT;
                vtpLimiteCompradorFonecedorCategoria.pnVlrEmbICMSSTOld := PROD.VLREMBICMSST_ANT;
                vtpLimiteCompradorFonecedorCategoria.pnVlrEmbIPIOld := PROD.VLREMBIPI_ANT;
                vtpLimiteCompradorFonecedorCategoria.pnQtdEmbalagemOld := PROD.NUMBER4;
                vtpLimiteCompradorFonecedorCategoria.pnQtdSolicitadaOld := PROD.NUMBER5;
                vtpLimiteCompradorFonecedorCategoria.pnQtdTotCanceladaOld := PROD.NUMBER6;
                vtpLimiteCompradorFonecedorCategoria.pnSeqSldLimCompraCompradorOld := PROD.NUMBER7;
                vtpLimiteCompradorFonecedorCategoria.pnSeqSldLimCompraFornecedorOld := PROD.NUMBER8;
                vtpLimiteCompradorFonecedorCategoria.pnSeqSldLimCompraCategoriaOld := PROD.NUMBER9;
                vtpLimiteCompradorFonecedorCategoria.pnVlrImpostoCompraOld := PROD.VLRIMPOSTOCOMPRA_ANT;
                PKG_LIMCOMPRA.SP_LimiteCompradorFonecedorCategoria(vtpLimiteCompradorFonecedorCategoria);
              END;
            END LOOP;
          END IF;
        END IF;
      EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        UPDATE MSUX_ATU_PSITEMRECEBER A
           SET A.INDATUALIZADO = 'X'
         WHERE A.NROPEDIDOSUPRIM = vtpPedidos(i).NroPedidoSuprim
           AND A.NROEMPRESA = vtpPedidos(i).NroEmpresa
           AND A.CENTRALLOJA = vtpPedidos(i).CentralLoja;
        COMMIT;
      END;
    END LOOP;
  END IF;
  if vbAtualizou then
    -- atualiza valores de acordos já gerados
    update msu_pedidosuprim a
       set a.situacaoped = a.situacaoped,
           a.UsuAlteracao = psUsuario,
           a.DtaAlteracao = sysdate
     where exists (select 1 from msux_atu_psitemreceber x
                    where x.nropedidosuprim = a.nropedidosuprim
                      and x.nroempresa = a.nroempresa
                      and x.centralloja = a.centralloja
                      and x.indatualizado = 'S');
    commit;
  end if;
  PKG_GE_PDMEMORIA.SP_DESABILITAPDMEMORIA();
exception
  when others then
    pkg_ge_pdmemoria.sp_desabilitapdmemoria();
    raise_application_error(-20200, sqlerrm);
end sp_msu_atuprecofornec_nag;
