create or replace procedure consinco.NAGP_spMac_GeraLoteCompra(
            pdDtaInclusao              in   mac_gercompra.dtahorinclusao%type,
            psPermDuplicar             Varchar2 Default 'N',
            pnSeqGerCompraLote         in   mac_gercompra.seqgercompra%type default null
            )
is
     vsPdConsideraSoDiaUtil            max_parametro.valor%type;
     vsPdContaAbastDiaUtil             max_parametro.valor%type;
     vsPdContaAbastSabado              max_parametro.valor%type;
     vsPdContaAbastDomingo             max_parametro.valor%type;
     vsPdContaAbastFeriado             max_parametro.valor%type;
     vsPDAtualItemLoteStProd           max_parametro.valor%type;
     vnSeqGerCompra                    mac_gercompra.seqgercompra%type;
     vnNroDivisao                      max_empresa.nrodivisao%type;
     vnSeqFornecedor                   mac_gercompraforn.seqfornecedor%type;
     vnQtdDiaUtilAbastecAux            mac_gercompraitem.qtddiaabastec%type;
     vsSQL                             long;
     vsWhere                           Mac_Gercomprafiltro.Filtro_Where%TYPE;
     vsWhereAgenda                     Mac_Gercomprafiltro.Filtro_Where%TYPE;
     vnContConsist                     number;
     vnQtdAbastecAte                   MAC_GERCOMPRA.QTDABASTECATE%TYPE;
     vsPdGeraReservaLotePend           max_parametro.valor%type;
     vdDtaAbastecAte                   mac_gercompra.dtaabastecate%type;
     vsConsdApenasEmpAgenda            varchar2(1);
     vsPDMobLiberaLote                 varchar2(1);
     vsPdConsideraAtrasoFornec         MAX_PARAMETRO.VALOR%TYPE;
     vsPDItensEmpNaoAbastInatComp      MAX_PARAMETRO.VALOR%TYPE;
     vsPD_PermProdSecundario           MAX_PARAMETRO.VALOR%type;
     vsPD_UtilConceitoProdSec          MAX_PARAMETRO.VALOR%type;
     vsPD_DataBaseAbastec              MAX_PARAMETRO.VALOR%TYPE;
     vsPD_EqParamLoteModelo            MAX_PARAMETRO.VALOR%TYPE;
     vsPDConsisteStatusForn            MAX_PARAMETRO.VALOR%TYPE;
     vsPDBloqPedMinCadFornec           MAX_PARAMETRO.VALOR%TYPE;
     vsPDDefTipoPedBloqPedMin          MAX_PARAMETRO.VALOR%TYPE;
     vdDtaBase                         mac_gercompra.dtaabastecate%type;
     vsDiasAbastec                     varchar2(150);
     vsPDEqDtaLimRecebRecebEm          MAX_PARAMETRO.VALOR%type;
     vdDtaLimiteRec                    mac_gercompra.dtalimiterecebto%type;
     vdDtaRecebi                       mac_gercompraforn.dtarecebimento%type;
     vnDiasRec                         mac_gercompraforn.qtddiasreceb%type;
     vnDiasLimRec                         mac_gercompraforn.qtddiaslimreceb%type;
     vnCalcQtdAbastec                  MAC_GERCOMPRA.QTDABASTECATE%TYPE;
     vsPD_PermQtdAbastecFrac           MAX_PARAMETRO.VALOR%TYPE;
     vnQtdAbastecAteAux                MAC_GERCOMPRA.QTDABASTECATE%TYPE;
     vsPDUtilConcDepFechado            MAX_PARAMETRO.VALOR%TYPE;
     vsAcataSugeridoFinalAuto          VARCHAR2(1);
     vsPDFinalizaLotePedidosG          max_parametro.valor%type;
     vbRetorno                         INTEGER;
begin
       sp_checaparamdinamico( 'GER_COMPRAS', 0, 'CONSISTE_STATUS_FORN', 'S', 'S',
                               'CONSISTE STATUS DO FORNECEDOR PARA A GERAÇÃO DE LOTES/PEDIDOS. ESTES SERÃO GERADOS APENAS PARA FORNECEDORES ATIVOS. VALORES:
N - NÃO CONSISTE
S - CONS. STATUS GERAL(PADRÃO)
D - CONS. STATUS DA DIVISÃO');
       sp_checaparamdinamico( 'GER_COMPRAS_SUG', 0, 'CONSIDERA_SO_DIA_UTIL', 'S', 'S',
                               'CONSIDERA SOMENTE DIAS UTEIS NA MÉDIA DE VENDA ? (S/N)');
       sp_checaparamdinamico( 'GER_COMPRAS', 0, 'CONTA_ABAST_DIA_UTIL', 'S', 'S',
                               'CONSIDERA DIA UTIL (SEGUNDA A SEXTA) P/SUGERIR QUANTIDADE DE DIAS DE ABASTECIMENTO ? (S/N)');
       sp_checaparamdinamico( 'GER_COMPRAS', 0, 'CONTA_ABAST_SABADO', 'S', 'S',
                               'CONSIDERA SABADO P/SUGERIR QUANTIDADE DE DIAS DE ABASTECIMENTO ? (S/N)');
       sp_checaparamdinamico( 'GER_COMPRAS', 0, 'CONTA_ABAST_DOMINGO', 'S', 'S',
                               'CONSIDERA DOMINGO P/SUGERIR QUANTIDADE DE DIAS DE ABASTECIMENTO ? (S/N)');
       sp_checaparamdinamico( 'GER_COMPRAS', 0, 'CONTA_ABAST_FERIADO', 'S', 'S',
                               'CONSIDERA FERIADO P/SUGERIR QUANTIDADE DE DIAS DE ABASTECIMENTO ? (S/N)');
       sp_checaparamdinamico( 'GER_COMPRAS', 0, 'GERA_RESERVA_LOTE_PENDENTE', 'S', 'S',
                               'GERA SALDO DE QTD PENDENTE DE LOTE DE COMPRAS (COLUNA QTDPENDPEDCOMPRA DA MRL_PRODUTOEMPRESA) ?
VALORES: (S=SIM/N=NÃO), PADRÃO = S');
       sp_checaparamdinamico('GER_COMPRAS', 0,'ATUAL_ITEM_LOTE_STATUS_PROD','S','N','ATUALIZA OS ITENS DO LOTE DE ACORDO COM O STATUS DO PRODUTO? (S-SIM/N-NÃO(PADRÃO))
S - OS ITENS DO LOTE SERÃO ATIVADOS/INATIVADOS APÓS ATUALIZAÇÃO (REFRESH) DE ACORDO COM O STATUS DO PRODUTO.
N - NÃO ATUALIZA LOTE (TRATAMENTO PADRÃO DO SISTEMA)');
       sp_buscaparamdinamico('GER_COMPRAS',0,'CONSID_APENAS_EMP_AGENDA','S','S','NA GERAÇÃO DO LOTE DE COMPRA A PARTIR DO LOTE MODELO CONSIDERAR APENAS AS EMPRESAS ONDE A DIVISÃO HÁ AGENDA ?
           VALORES: (S=SIM(PADRÃO)/N=NÃO)',vsConsdApenasEmpAgenda);
       sp_buscaparamdinamico('GER_COMPRAS',0,'IND_MOB_LIBERA_LOTE','S','N','INDIQUE SE O LOTE GERADO AUTOMÁTICAMENTE SERÁ LIBERADO PARA APLICAÇÃO COMPRAS FLV MOBILE:  VALORES:(S-SIM/N-NÃO(PADRÃO))',vsPDMobLiberaLote);
       SP_BUSCAPARAMDINAMICO('GER_COMPRAS', 0, 'PERM_PROD_SECUNDARIO', 'S', 'S',
    'INDICA SE PERMITE INSERIR PRODUTO SECUNDÁRIO NO LOTE.'  || CHR(13) || CHR(10) ||
    'VALORES:'  || CHR(13) || CHR(10) ||
    'S-SIM(PADRÃO)'  || CHR(13) || CHR(10) ||
    'N-NÃO', vsPD_PermProdSecundario);
       SP_BUSCAPARAMDINAMICO('PRODUTO', 0, 'UTIL_CONCEITO_PROD_SEC', 'S', 'N',
    'INDICA SE UTILIZA CONCEITO DE PRODUTO SECUNDÁRIO' || CHR(13) || CHR(10) ||
    'VALORES:' || CHR(13) || CHR(10) ||
    'S-SIM' || CHR(13) || CHR(10) ||
    'N-NÃO(PADRÃO)', vsPD_UtilConceitoProdSec);
       SP_BUSCAPARAMDINAMICO('GER_COMPRAS', 0, 'EXIBE_ITENS_EMPNAOABAST_INA_C', 'S', 'S',
    'EXIBER ITENS QUANDO A(S) EMPRESA(S) DO LOTE DIFENTE(S) DA EMPRESA ABASTECEDORA, ESTEJA INATIVA PARA COMPRA.
    VALORES: (S - SIM(VALOR PADRÃO) /N - NÃO )', vsPDItensEmpNaoAbastInatComp);
    sp_buscaparamdinamico('GER_COMPRAS', 0, 'DATA_BASE_ABASTECIMENTO', 'S', 'N',
            'EXIBE DATA BASE DE ABASTECIMENTO COM BASE NA DATA DE RECEBIMENTO.
      VALORES: (S - SIM /N - NÃO(VALOR PADRÃO) )', vsPD_DataBaseAbastec);
    SP_BUSCAPARAMDINAMICO('GER_COMPRAS', 0, 'EQ_PARAM_LOTE_MODELO', 'S', 'N',
  'EQUALIZA QUANDO POSSÍVEL A PARAMETRIZAÇÃO DO LOTE MODELO ANTES DE GERAR O LOTE DE COMPRA CONFORME CADASTRO DE FORNECEDOR?
  VALORES: (S - SIM /N - NÃO (VALOR PADRÃO) )' , vsPD_EqParamLoteModelo);
    SP_BUSCAPARAMDINAMICO( 'GER_COMPRAS_SUG', 0, 'PERM_QTD_ABASTEC_FRAC', 'S', 'N',
               'PERMITE UTILIZAR QUANTIDADE DE DIAS DE ABASTECIMENTO FRACIONADA. VALORES:' || CHR(13) || CHR(10) ||
               'N-NÃO(PADRÃO)' || CHR(13) || CHR(10) ||
               'S-SIM', vsPD_PermQtdAbastecFrac );
    SP_BUSCAPARAMDINAMICO('GER_COMPRAS_SUG', 0, 'UTIL_CONC_DEP_FECHADO', 'S', 'N',
                          'UTILIZA CONCEITO DE DEPÓSITO FECHADO NA SUGESTÃO DE COMPRAS.' || CHR(13) || CHR(10) ||
                          'VALORES:' || CHR(13) || CHR(10) ||
                          'S - SIM' || CHR(13) || CHR(10) ||
                          'N - NÃO(PADRÃO)',
                          vsPDUtilConcDepFechado);
    IF vsPDUtilConcDepFechado = 'S' THEN
       vsAcataSugeridoFinalAuto := 'N';
    ELSE
       vsAcataSugeridoFinalAuto := 'S';
    END IF;
        select fc5maxparametro('GER_COMPRAS_SUG', 0, 'CONSIDERA_ATRASO_FORNEC'),
               fc5maxparametro('GER_COMPRAS_SUG', 0, 'CONSIDERA_SO_DIA_UTIL'),
               fc5maxparametro('GER_COMPRAS', 0, 'CONTA_ABAST_DIA_UTIL'),
               fc5maxparametro('GER_COMPRAS', 0, 'CONTA_ABAST_SABADO'),
               fc5maxparametro('GER_COMPRAS', 0, 'CONTA_ABAST_DOMINGO'),
               fc5maxparametro('GER_COMPRAS', 0, 'CONTA_ABAST_FERIADO'),
               fc5maxparametro('GER_COMPRAS', 0, 'GERA_RESERVA_LOTE_PENDENTE'),
               fc5maxparametro('GER_COMPRAS', 0, 'ATUAL_ITEM_LOTE_STATUS_PROD'),
               fc5maxparametro('GER_COMPRAS', 0, 'CONSISTE_STATUS_FORN'),
               fc5maxparametro('GER_COMPRAS', 0, 'BLOQ_PED_MIN_CADASTRO_FORNEC'),
               fc5maxparametro('GER_COMPRAS', 0, 'DEF_TIPO_PED_BLOQ_PED_MIN')
        into   vsPdConsideraAtrasoFornec,
               vsPdConsideraSoDiaUtil,
               vsPdContaAbastDiaUtil,
               vsPdContaAbastSabado,
               vsPdContaAbastDomingo,
               vsPdContaAbastFeriado,
               vsPdGeraReservaLotePend,
               vsPDAtualItemLoteStProd,
               vsPDConsisteStatusForn,
               vsPDBloqPedMinCadFornec,
               vsPDDefTipoPedBloqPedMin
        from   dual;
  -- Equaliza o lote conforme parametros do fornecedor
  if vsPD_EqParamLoteModelo = 'S' then
      FOR vtLoteModelo in (
                                 SELECT *
                                   FROM(
                                             select        GC.SEQGERCOMPRA,
                                                           GC.TIPORECEBTOEM,
                                                           GF.SEQFORNECEDOR,
                                                           DECODE( pd.pdRecConsidAtraso , 'S',
                                                                          case pd.pdConsidAtraso
                                                                               when 'A' then
                                                                                  case GC.TIPORECEBTOEM when 'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura' then
                                                                                        case when gc.tipopzoadiccobertura = 'D' then
                                                                                            nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0) + gc.pzoadicobertura
                                                                                        else
                                                                                            (nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0) )* 2
                                                                                        end
                                                                                  else
                                                                                    nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0)
                                                                                  end
                                                                               when 'S' then
                                                                                  case GC.TIPORECEBTOEM when 'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura' then
                                                                                        case when gc.tipopzoadiccobertura = 'D' then
                                                                                            nvl(v.pzomedatraso, 0) + gc.pzoadicobertura
                                                                                        else
                                                                                            (nvl(v.pzomedatraso, 0) )* 2
                                                                                        end
                                                                                  else
                                                                                      nvl(v.pzomedatraso, 0)
                                                                                  end
                                                                               when 'E' then
                                                                                  case GC.TIPORECEBTOEM when 'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura' then
                                                                                        case when gc.tipopzoadiccobertura = 'D' then
                                                                                            nvl(v.pzomedentrega, 0)+ gc.pzoadicobertura
                                                                                        else
                                                                                            (nvl(v.pzomedentrega, 0) )* 2
                                                                                        end
                                                                                  else
                                                                                      nvl(v.pzomedentrega, 0)
                                                                                  end
                                                                           else
                                                                                 case GC.TIPORECEBTOEM
                                                                                     when 'Pzo Med. Visita + Entr. + Atraso' then
                                                                                         nvl(v.pzomedvisitarep, 0) + nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0)
                                                                                     when 'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura' then
                                                                                        case when gc.tipopzoadiccobertura = 'D' then
                                                                                            nvl(v.pzomedvisitarep, 0) + nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0) + gc.pzoadicobertura
                                                                                        else
                                                                                            (nvl(v.pzomedvisitarep, 0) + nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0) )* 2
                                                                                        end
                                                                                     when 'Pzo Med. Visita + Entr. + Atraso + Pzo Acres Emp.Região' then
                                                                                         nvl(v.pzomedvisitarep, 0) + nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0)
                                                                                     when 'Pzo Med. Entrega' then
                                                                                         nvl(v.pzomedentrega, 0)
                                                                                  else
                                                                                     0
                                                                                  end
                                                                           end ,
                                                                   case GC.TIPORECEBTOEM
                                                                                     when 'Pzo Med. Visita + Entr. + Atraso' then
                                                                                         nvl(v.pzomedvisitarep, 0) + nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0)
                                                                                     when 'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura' then
                                                                                        case when gc.tipopzoadiccobertura = 'D' then
                                                                                            nvl(v.pzomedvisitarep, 0) + nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0) + gc.pzoadicobertura
                                                                                        else
                                                                                            (nvl(v.pzomedvisitarep, 0) + nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0) )* 2
                                                                                        end
                                                                                     when 'Pzo Med. Visita + Entr. + Atraso + Pzo Acres Emp.Região' then
                                                                                         nvl(v.pzomedvisitarep, 0) + nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0)
                                                                                     when 'Pzo Med. Entrega' then
                                                                                         nvl(v.pzomedentrega, 0)
                                                                                  else
                                                                                     0
                                                                                  end
                                                                  ) QtdDiasRecebCadastro   ,
                                                                  GF.QTDDIASRECEB QtdDiasRecebLote ,
                                                                  GC.TIPOABASTECATE,
                                                                  case pd.pdConsidAtraso
                                                                       when 'A' then
                                                                              case GC.TIPOABASTECATE when 'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura' then
                                                                                  case when gc.tipopzoadiccobertura = 'D' then
                                                                                       nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0) + gc.pzoadicobertura
                                                                                  else
                                                                                      ( nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0) )* 2
                                                                                  end
                                                                              else
                                                                                  nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0)
                                                                              end
                                                                       when 'S' then
                                                                            case GC.TIPOABASTECATE  when 'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura' then
                                                                                  case when gc.tipopzoadiccobertura = 'D' then
                                                                                       nvl(v.pzomedatraso, 0) + gc.pzoadicobertura
                                                                                  else
                                                                                      ( nvl(v.pzomedatraso, 0) )* 2
                                                                                  end
                                                                            else
                                                                              nvl(v.pzomedatraso, 0)
                                                                            end
                                                                       when 'E' then
                                                                            case GC.TIPOABASTECATE when 'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura' then
                                                                                      case when gc.tipopzoadiccobertura = 'D' then
                                                                                          nvl(v.pzomedentrega, 0)
                                                                                      else
                                                                                          ( nvl(v.pzomedentrega, 0) )* 2
                                                                                      end
                                                                            else
                                                                                  nvl(v.pzomedentrega, 0)
                                                                            end
                                                                   else
                                                                         case GC.TIPOABASTECATE
                                                                             when 'Pzo Med. Visita + Entr. + Atraso' then
                                                                                 nvl(v.pzomedvisitarep, 0) + nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0)
                                                                             when 'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura' then
                                                                                case when gc.tipopzoadiccobertura = 'D' then
                                                                                    nvl(v.pzomedvisitarep, 0) + nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0) + gc.pzoadicobertura
                                                                                else
                                                                                    (nvl(v.pzomedvisitarep, 0) + nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0) )* 2
                                                                                end
                                                                             when 'Pzo Med. Visita + Entr. + Atraso + Pzo Acres Emp.Região' then
                                                                                 nvl(v.pzomedvisitarep, 0) + nvl(v.pzomedentrega, 0) + nvl(v.pzomedatraso, 0)
                                                                             when 'Pzo Med. Entrega' then
                                                                                 nvl(v.pzomedentrega, 0)
                                                                             when 'Pzo Med. Visita + Estq. Segurança' then
                                                                                 nvl(v.pzomedvisitarep, 0) +  nvl(v.pzoestqseguranca, 0)
                                                                             when 'Pzo Med. Visita + Atraso' then
                                                                                 nvl(v.pzomedvisitarep, 0) +  nvl(v.pzomedatraso, 0)
                                                                          else
                                                                             0
                                                                          end
                                                                   end QtdDiasAbastecCadastro,
                                                                   GC.QTDABASTECATE  QtdDiasAbastecLote,
                                                                   CASE WHEN
                                                                       GC.TIPOABASTECATE IN ('Pzo Med. Visita + Entr. + Atraso',
                                                                            'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura' ,
                                                                            'Pzo Med. Visita + Entr. + Atraso + Pzo Acres Emp.Região',
                                                                            'Pzo Med. Entrega',
                                                                            'Pzo Med. Visita + Estq. Segurança',
                                                                            'Pzo Med. Visita + Atraso' ) THEN 'S'
                                                                        ELSE
                                                                          'N'
                                                                    END ABASTECPZO,
                                                                     CASE WHEN
                                                                          GC.TIPORECEBTOEM IN ('Pzo Med. Visita + Entr. + Atraso',
                                                                                               'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura',
                                                                                               'Pzo Med. Visita + Entr. + Atraso + Pzo Acres Emp.Região',
                                                                                               'Pzo Med. Entrega'
                                                                                               )  THEN 'S'
                                                                      ELSE  'N'
                                                                    END RECEBPZO
                                             from
                                                  (
                                                     select
                                                       NVL((select p.valor
                                                              from max_parametro p
                                                             where p.parametro LIKE 'REC_CONSIDERA_ATRASO_FORNEC'
                                                               and p.grupo = 'GER_COMPRAS_SUG'
                                                               and p.nroempresa = e.nroempresa),'S') pdRecConsidAtraso,
                                                       NVL((select p.valor
                                                              from max_parametro p
                                                             where p.parametro LIKE 'CONSIDERA_ATRASO_FORNEC'
                                                               and p.grupo = 'GER_COMPRAS_SUG'
                                                               and p.nroempresa = e.nroempresa),'N') pdConsidAtraso,
                                                           e.nroempresa,
                                                           e.nrodivisao
                                                      from max_empresa e
                                                  ) PD,
                                              MAFV_FORNECDIVISAOCOMPR v ,
                                              MAC_GERCOMPRA GC,
                                              MAC_GERCOMPRAFORN GF
                                          WHERE GC.SEQCOMPRADOR = V.seqcomprador
                                            AND GC.NROEMPRESAGERALOTE = PD.NROEMPRESA
                                            and PD.NRODIVISAO = V.nrodivisao
                                            AND GF.SEQGERCOMPRA = GC.SEQGERCOMPRA
                                            AND GF.SEQFORNECEDOR = V.seqfornecedor
                                            AND GC.TIPOLOTE = 'M'
                                            AND ( GC.TIPOABASTECATE IN ('Pzo Med. Visita + Entr. + Atraso',
                                                                        'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura' ,
                                                                        'Pzo Med. Visita + Entr. + Atraso + Pzo Acres Emp.Região',
                                                                        'Pzo Med. Entrega',
                                                                        'Pzo Med. Visita + Estq. Segurança',
                                                                        'Pzo Med. Visita + Atraso' )or
                                                  GC.TIPORECEBTOEM IN ('Pzo Med. Visita + Entr. + Atraso',
                                                                       'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura',
                                                                       'Pzo Med. Visita + Entr. + Atraso + Pzo Acres Emp.Região',
                                                                       'Pzo Med. Entrega'
                                                                       )
                                                 )
                                            AND GC.SEQGERCOMPRA = NVL(pnSeqGerCompraLote, GC.SEQGERCOMPRA)
                                   ) SELECAO
                              WHERE ((SELECAO.QTDDIASABASTECLOTE != SELECAO.QTDDIASABASTECCADASTRO AND SELECAO.ABASTECPZO = 'S' ) OR
                                    (SELECAO.QTDDIASRECEBCADASTRO != SELECAO.QTDDIASRECEBLOTE AND SELECAO.RECEBPZO = 'S' ))
                          )loop
              IF vtLoteModelo.Abastecpzo = 'S' then
                  UPDATE MAC_GERCOMPRA GC
                    SET GC.QTDABASTECATE = vtLoteModelo.Qtddiasabasteccadastro,
                        GC.DTAABASTECATE = TRUNC(pdDtaInclusao) + vtLoteModelo.Qtddiasabasteccadastro
                   WHERE GC.SEQGERCOMPRA =  vtLoteModelo.Seqgercompra;
              end if;
              IF vtLoteModelo.Recebpzo = 'S' then
                  UPDATE MAC_GERCOMPRAFORN GF
                    SET GF.QTDDIASRECEB = vtLoteModelo.Qtddiasrecebcadastro,
                        GF.DTARECEBIMENTO = TRUNC(pdDtaInclusao) + vtLoteModelo.Qtddiasrecebcadastro
                   WHERE GF.SEQGERCOMPRA =  vtLoteModelo.Seqgercompra
                     AND GF.SEQFORNECEDOR = vtLoteModelo.Seqfornecedor;
              end if;
       end loop;
  end if;
  for t in (
      select trunc(case when x.periodomedvda = 'Últimos N Dias'     or
                         x.periodomedvda = 'Últimas N Semanas'      or
                         x.periodomedvda = 'Últimos N Meses'        or
                         x.periodomedvda = 'Período Personalizado'        then
                         sysdate - 1
                    when x.periodomedvda = 'Próximos N meses do ano anterior'   or
                         x.periodomedvda = 'Próximas N semanas do ano anterior' or
                         x.periodomedvda = 'Próximos N dias do ano anterior'    then
                         x.dtainiciomedvdacalc + (x.qtdmedvda * case when x.periodomedvda = 'Próximos N meses do ano anterior' then
                                                                         30
                                                                    when x.periodomedvda = 'Próximas N semanas do ano anterior' then
                                                                         7
                                                                    else
                                                                         1
                                                               end)
                    when x.periodomedvda = 'Mês em curso do ano anterior' then
                         add_months(x.dtainiciomedvdacalc, 1) - 1
                    when x.periodomedvda = 'Média Geral Atual' then
                         (x.dtainiciomedvdacalc + x.qtdmedvda )-1
               end) dtafinalmedvdacalc,
         x.*
  from (
        select trunc(case when a.periodomedvda = 'Últimos N Dias' then
                                 sysdate - a.qtdmedvda
                            when a.periodomedvda = 'Últimas N Semanas' then
                                 sysdate - (a.qtdmedvda * 7)
                            when a.periodomedvda = 'Últimos N Meses' then
                                 sysdate - (a.qtdmedvda * 30)
                            when a.periodomedvda = 'Próximos N meses do ano anterior'   or
                                 a.periodomedvda = 'Próximas N semanas do ano anterior' or
                                 a.periodomedvda = 'Próximos N dias do ano anterior'    then
                                 to_date(
                                          to_char(to_date(sysdate), 'YYYY') - 1
                                          ||
                                          to_char(to_date(sysdate), 'mm')
                                          ||
                                          to_char(to_date(sysdate), 'DD') + 1
                                 , 'YYYY-mm-DD')
                            when a.periodomedvda = 'Mês em curso do ano anterior' then
                                 to_date(
                                         to_char(to_date(sysdate), 'YYYY') - 1
                                         ||
                                         to_char(to_date(sysdate), 'mm')
                                         ||
                                         to_char('01')
                                 , 'YYYY-mm-DD')
                            when a.periodomedvda = 'Período Personalizado' then
                                 sysdate - (1 + (a.dtafinalmedvda - a.dtainiciomedvda))
                            when a.periodomedvda = 'Média Geral Atual' then
                                (sysdate  - a.qtdmedvda)
                     end) dtainiciomedvdacalc,
               a.*
        from mac_gercompra a
        where a.tipolote = 'M'
        and nvl(a.status,'A') = 'A'
        and nvl(a.situacaolote,'A') != 'C'
        and a.seqgercompra = nvl( pnSeqGerCompraLote, a.seqgercompra)
        --caso consiste o status do fornecedor, será gerado lotes apenas para fornecedores ativos
        and ( ( (vsPDConsisteStatusForn = 'S' or vsPDConsisteStatusForn = 'D') and
                exists ( select 1
                           from mac_gercompraforn cf, maf_fornecedor f
                          where cf.seqgercompra = a.seqgercompra
                            and f.seqfornecedor = cf.seqfornecedor
                            and f.statusgeral = 'A' ) ) or
                ( vsPDConsisteStatusForn = 'N' ) or
                ( vsPDConsisteStatusForn = 'D' and
                  exists ( SELECT 1
                            FROM Mac_Gercompraforn Cf, Maf_Fornecdivisao f, Max_Empresa e,
                                 Mac_Gercompraemp Ge
                           WHERE Cf.Seqgercompra = a.seqgercompra
                             AND f.Nrodivisao = e.Nrodivisao
                             AND Cf.Seqfornecedor = f.Seqfornecedor
                             AND e.Nroempresa = Ge.Nroempresa
                             AND Ge.Seqgercompra = Cf.Seqgercompra
                             AND f.Statusgeral = 'A'
                             AND e.Status = 'A' ) ))
         -- trata interrupcao do job devido ao commit RC 123376
        And (psPermDuplicar = 'S' Or
             Not Exists (Select 1
                         From   mac_gercompra x
                         Where  x.Seqgermodelocompra = a.Seqgercompra
                         And    trunc(x.Dtahorinclusao) = trunc(pdDtaInclusao)
                         AND X.SITUACAOLOTE != 'C'))
        --
       /* and exists (select 1
            from maf_fornecagenda b, mac_gercompraforn c, mac_gercompraemp d, max_empresa e
            where b.seqfornecedor = c.seqfornecedor
            and   c.seqgercompra = a.seqgercompra
            and   b.dtavisita = trunc(pdDtaInclusao)
            and   b.seqcomprador = a.seqcomprador
            and   d.seqgercompra = a.seqgercompra
            and   d.nroempresa = e.nroempresa
            and   e.nrodivisao = b.nrodivisao
            and   nvl(b.nroempresa,d.nroempresa) = d.nroempresa
            and   a.tipomodelocompra = 'A'
            and   e.status = 'A'
            union
            select 1
            from dual
            where a.tipomodelocompra = 'D'
            and (decode(to_char(pdDtaInclusao,'D'),1,a.agendadomingo,2,a.agendasegunda,3,a.agendaterca,4,a.agendaquarta,5,
                a.agendaquinta,6,a.agendasexta,a.agendasabado) = 'S') )*/
   ) x
  )
  loop
      sp_checaparamdinamico( 'GER_COMPRAS_SUG', t.nroempresageralote, 'CONSIDERA_ATRASO_FORNEC', 'S', 'N',
                            'CONSIDERA ATRASO E/OU PZO DE ENTREGA E/OU PZO MÉDIO DE VISITA DO FORNEC. P/SUGERIR ABASTECIMENTO ?' || CHR(13)||CHR(10)||
                            'S=ATRASO SOMENTE' || CHR(13)||CHR(10)||
                            'E=PZO ENTREGA SOMENTE' || CHR(13)||CHR(10)||
                            'V=PZO MÉDIO VISITA SOMENTE' || CHR(13)||CHR(10)||
                            'A=ATRASO E PRAZO ENTREGA' || CHR(13)||CHR(10)||
                            'T=ATRASO + PZO ENTREGA + PZO MÉDIO VISITA' ||CHR(13)||CHR(10)||
                            'N=NENHUM');
      select fc5maxparametro('GER_COMPRAS_SUG', t.nroempresageralote, 'CONSIDERA_ATRASO_FORNEC')
      into   vsPdConsideraAtrasoFornec
      from   dual;
       SP_BUSCAPARAMDINAMICO('GER_COMPRAS', t.nroempresageralote, 'EQ_DTA_LIMRECEB_RECEBEM', 'S', 'N',
    'EQUALIZA DTA "LIMITE DE RECEBIMENTO" CONFORME DTA "RECEBIMENTO EM" DOS LOTES GERADOS A PARTIR DE UM LOTE MODELO ?
    VALORES: (S - SIM /N - NÃO (VALOR PADRÃO) )
    OBS: SERÁ APENAS EQUALIZADO SE O LOTE MODELO ESTIVER COM DTA LIMITE.', vsPDEqDtaLimRecebRecebEm);
      select S_MAC_GERCOMPRA.nextval
      into vnSeqGerCompra
      from dual;
      select nrodivisao
      into vnNroDivisao
      from max_empresa
      where nroempresa = t.nroempresageralote;
      -- Variavel qtd dias recebimento
      vnDiasRec := null;
      if t.tiporecebtoem in ('Até o Fim da Semana',
                             'Até o Fim da Quinzena',
                             'Até o Fim do Mês',
                             'Até o Fim do Semestre') then
            if t.tiporecebtoem = 'Até o Fim da Semana' then
                 select (7 - to_char(pdDtaInclusao - 1, 'd'))
                   into vnDiasRec
                   FROM DUAL;
            elsif t.tiporecebtoem = 'Até o Fim da Quinzena' then
                 select  case
                           when ( to_char(pdDtaInclusao, 'DD')) <= 15 then
                             15 - to_char(pdDtaInclusao, 'DD')
                         else
                             to_char(LAST_DAY(pdDtaInclusao),'DD') -  to_char(pdDtaInclusao, 'DD')
                         end
                   into vnDiasRec
                   FROM DUAL;
            elsif t.tiporecebtoem = 'Até o Fim do Mês' then
                 select   to_char(LAST_DAY(pdDtaInclusao),'DD') -  to_char(pdDtaInclusao, 'DD')
                   into vnDiasRec
                   FROM DUAL;
            elsif t.tiporecebtoem = 'Até o Fim do Semestre' then
                 select   case
                            when to_char(pdDtaInclusao,'MM') <= 6 then
                                to_date('30/jun/'||to_char(pdDtaInclusao,'yyyy')  ,'DD/MM/yyyy') -  trunc(pdDtaInclusao)
                          else
                                to_date('31/dec/'||to_char(pdDtaInclusao,'yyyy')  ,'DD/MM/yyyy') -  trunc(pdDtaInclusao)
                          end
                   into vnDiasRec
                   FROM DUAL;
            end if;
      end if;
      ---------
      -- Variavel qtd dias limite recebimento
      vnDiasLimRec := null;
      if t.tipolimrecebtoem in ('Até o Fim da Semana',
                             'Até o Fim da Quinzena',
                             'Até o Fim do Mês',
                             'Até o Fim do Semestre') then
            if t.tipolimrecebtoem = 'Até o Fim da Semana' then
                 select (7 - to_char(pdDtaInclusao - 1, 'd'))
                   into vnDiasLimRec
                   FROM DUAL;
            elsif t.tipolimrecebtoem = 'Até o Fim da Quinzena' then
                 select  case
                           when ( to_char(pdDtaInclusao, 'DD')) <= 15 then
                             15 - to_char(pdDtaInclusao, 'DD')
                         else
                             to_char(LAST_DAY(pdDtaInclusao),'DD') -  to_char(pdDtaInclusao, 'DD')
                         end
                   into vnDiasLimRec
                   FROM DUAL;
            elsif t.tipolimrecebtoem = 'Até o Fim do Mês' then
                 select   to_char(LAST_DAY(pdDtaInclusao),'DD') -  to_char(pdDtaInclusao, 'DD')
                   into vnDiasLimRec
                   FROM DUAL;
            elsif t.tipolimrecebtoem = 'Até o Fim do Semestre' then
                 select   case
                            when to_char(pdDtaInclusao,'MM') <= 6 then
                                to_date('30/jun/'||to_char(pdDtaInclusao,'yyyy')  ,'DD/MM/yyyy') -  trunc(pdDtaInclusao)
                          else
                                to_date('31/dec/'||to_char(pdDtaInclusao,'yyyy')  ,'DD/MM/yyyy') -  trunc(pdDtaInclusao)
                          end
                   into vnDiasLimRec
                   FROM DUAL;
            end if;
      end if;
      ---------
      -- verifica parametros de recebimento  e limite recebimento
      select max(seqfornecedor), trunc(sysdate) +  nvl(vnDiasRec, max(qtddiasreceb) ),
             nvl(vnDiasRec, max(qtddiasreceb) ),
             max(dtarecebimento),
             nvl(vnDiasLimRec, max(qtddiaslimreceb) ),
             trunc(sysdate) +  nvl(vnDiasLimRec, max(qtddiaslimreceb) )
      into vnSeqFornecedor, vdDtaBase,
           vnDiasRec,
           vdDtaRecebi,
           vnDiasLimRec,
           vdDtaLimiteRec
      from mac_gercompraforn
      where seqgercompra = t.seqgercompra;
      -- tratamento para buscar o pzo de visita direto da fornecdivisao (Bidio - Giga)
      if t.tipoabastecate in ('Pzo Med. Visita + Entr. + Atraso',
                              'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura',
                              'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Emp.Região',
                              'Pzo Med. Visita + Atraso',
                              'Pzo Med. Visita + Estq. Segurança'
                              ) then
         -- caso o pd vsPdConsideraAtrasoFornec for N e a opção escolhida estiver entre as duas
         if (nvl(vsPdConsideraAtrasoFornec, 'N') not in ('A', 'S', 'E', 'V', 'T')) and
            ( t.tipoabastecate = 'Pzo Med. Visita + Atraso' or  t.tipoabastecate =  'Pzo Med. Visita + Estq. Segurança') then
             Select  case t.tipoabastecate
                       when 'Pzo Med. Visita + Atraso' then
                            nvl(a.pzomedvisitarep, 0) + nvl(a.pzomedatraso, 0)
                       when 'Pzo Med. Visita + Estq. Segurança' then
                            nvl(a.pzomedvisitarep, 0) + nvl(a.pzoestqseguranca, 0)
                     end
              Into vnQtdAbastecAte
              From maf_fornecdivisao a
             Where a.nrodivisao    = vnNroDivisao
               And a.seqfornecedor = vnSeqFornecedor;
         else
         -- Senão olha o pd para considerar apenas o parametrizado.
         Select   decode(nvl(vsPdConsideraAtrasoFornec, 'N'),
              'A', nvl(a.pzomedentrega, 0) + nvl(a.pzomedatraso, 0),
              'S', nvl(a.pzomedatraso, 0),
              'E', nvl(a.pzomedentrega, 0),
              'V', nvl(a.pzomedvisitarep, 0),
              nvl(a.pzomedvisitarep, 0) + nvl(a.pzomedentrega, 0) + nvl(a.pzomedatraso, 0) )
         Into vnQtdAbastecAte
         From     maf_fornecdivisao a
         Where    a.nrodivisao  = vnNroDivisao
         And      a.seqfornecedor   = vnSeqFornecedor;
         if t.tipoabastecate = 'Pzo Med. Visita + Entr. + Atraso + Pzo Adic Cobertura' then
            vnQtdAbastecAte := vnQtdAbastecAte + t.pzoadicobertura;
             end if;
         end if;
      else
         vnQtdAbastecAte := t.qtdabastecate;
      end if;
      -- caso não considera a data base de recebimento para calculo da data de abastecimento.
      if vsPD_DataBaseAbastec != 'S' then
         vdDtaBase := trunc(sysdate);
      end if;
      if vnQtdAbastecAte is null then
        vdDtaAbastecAte := nvl(t.dtaabastecate,vdDtaBase);
      else
        vdDtaAbastecAte := vdDtaBase + nvl(vnQtdAbastecAte,0);
      end if;
      if vsPDEqDtaLimRecebRecebEm = 'S' and t.dtalimiterecebto is not null then
        if t.dtalimiterecebto > vdDtaRecebi then
           vdDtaLimiteRec := nvl(trunc(pdDtaInclusao)+vnDiasRec,vdDtaRecebi);
           vdDtaLimiteRec := vdDtaLimiteRec + (t.dtalimiterecebto - vdDtaRecebi);
        else
           vdDtaLimiteRec := nvl(trunc(pdDtaInclusao)+vnDiasRec,vdDtaRecebi);
        end if;
      end if;
      -- inserindo cabeçalho do novo lote
      insert into MAC_GERCOMPRA
      ( SEQGERCOMPRA, SEQCOMPRADOR,
        DESCRITIVO, SITUACAOLOTE,
        DTAHORINCLUSAO, USUINCLUSAO,
        DTAHORALTERACAO, USUALTERACAO,
        INDREPLICACAO, INDGEROUREPLICACAO,
        TIPOABASTECATE, QTDABASTECATE,
        DTAABASTECATE, PERIODOMEDVDA,
        QTDMEDVDA, DTAINICIOMEDVDA,
        DTAFINALMEDVDA, INDTIPOMEDVDA,
        TOTALPESOOBJETIVO, TOTALVOLUMEOBJETIVO,
        TOTALVALOROBJETIVO, TOTALQTDVOLUMEOBJETIVO,
        TFDTABASECUSTO, TFPERCNEGOC,
        OBSERVACAO, ADVRECEBIMENTO,
        CRITERIOEMISSAOVENDAS, INCREMENTOMEDIAVENDA,
        TIPOSUGCOMPRA, TIPOEMBALAGEM,
        DTAINICIALHISTVENDA, DTAFINALHISTVENDA,
        TFPZOPAGAMENTO, DTALIMITERECEBTO,
        PZOADICOBERTURA, TIPOPZOADICCOBERTURA,
        NROEMPRESAGERALOTE, TIPOLOTE, CODGERALOPER, PERCDESCSF,
        INDRESTRINGELOJA, SEQGERMODELOCOMPRA,
        INDCONSIDERASLDPENDARECEBER, INDCONSIDERASLDPENDAEXPEDIR,
        INDCONSIDERAQTDACOMPRAR, TIPORECEBTOEM, INDGERLOTEABASTEC, INDCALCFAIXAMEDIA,
        INDCALCSUGCOMPRAFORMULA, INDCONSESTOQUECENTRALSUG, INDTIPOCALCFORMULA, INDSUGLASTROPALETE,
        NROEMPRESAVISUALESTOQUE, INDMAIORSUGCOMPRA,
        INDCONSSLDPENDARECEBERLOJA, INDCONSSLDPENDAEXPEDIRLOJA, INDCONSQTDACOMPRARLOJA, INDCONSESTQDISPLOJA,
        CONSIDERASLDPENDARECEBERPEXTRA, CONSIDERASLDPENDAEXPEDIRPEXTRA, CONSIDERAQTDACOMPRARPEXTRA,
        INDESTTROCA,
        UTILNATIMORTO, INCSUGCOMPRALOJA,
        SEQCONDCONDPRAZOPAGTO, INTEGRACOMPRASMOBILE,
        INDUSAREGIAOCOMPRA, SEQFORNECLOTEMOBILE ,
        INDQUEBRARECBTO, INDQTDDTARECEBDIFITEM, INDGEREDIAUT, INDTIPDTARECEBDIF, TIPOMODELOCOMPRA,
        AGENDAHSDOMINGO, AGENDAHSSEGUNDA, AGENDAHSTERCA, AGENDAHSQUARTA, AGENDAHSQUINTA,
        AGENDAHSSEXTA,   AGENDAHSSABADO,  AGENDADOMINGO, AGENDASEGUNDA,  AGENDATERCA,
        AGENDAQUARTA,    AGENDAQUINTA,    AGENDASEXTA,   AGENDASABADO,
    INDEMPPEDIDOFORMAABASTEC, SEQFORNECPRINCIPAL, UTILADICSUGESTPROMOC ,
      NROCONDPAGTOTRANSF, INDDIASESPECIFMEDVDA, TIPOLIMRECEBTOEM, INDCOTACAOFLV )
        values( vnSeqGerCompra, t.seqcomprador,
                t.descritivo, 'G',
                sysdate, 'JOBGERALOTE',
                sysdate, 'JOBGERALOTE',
                'S', null,
                t.tipoabastecate, vnQtdAbastecAte,
                vdDtaAbastecAte, t.periodomedvda,
                t.qtdmedvda, t.dtainiciomedvdacalc,
                t.dtafinalmedvdacalc, nvl(t.indtipomedvda,'N'),
                null, null,
                null, null,
                t.tfdtabasecusto, t.tfpercnegoc,
                t.observacao, t.advrecebimento,
                t.criterioemissaovendas, t.incrementomediavenda,
                t.tiposugcompra, t.tipoembalagem,
                t.dtainicialhistvenda, t.dtafinalhistvenda,
                t.tfpzopagamento,
                nvl(vdDtaLimiteRec,t.dtalimiterecebto),
                t.pzoadicobertura, t.tipopzoadiccobertura,
                t.nroempresageralote, 'C', t.codgeraloper, t.percdescsf,
                t.indrestringeloja, t.seqgercompra,
                t.indconsiderasldpendareceber, t.indconsiderasldpendaexpedir,
                t.indconsideraqtdacomprar, t.tiporecebtoem, t.indgerloteabastec, t.indcalcfaixamedia,
                t.indcalcsugcompraformula, t.indconsestoquecentralsug , t.indtipocalcformula, t.indsuglastropalete,
                t.nroempresavisualestoque, t.indmaiorsugcompra,
                t.indconssldpendareceberloja, t.indconssldpendaexpedirloja, t.indconsqtdacomprarloja, t.INDCONSESTQDISPLOJA,
                t.considerasldpendareceberpextra, t.considerasldpendaexpedirpextra, t.consideraqtdacomprarpextra,
                pkg_adm_compra.fVerifEstoqueTrocaFornec((select min(xp.seqfornecedor)
                                                           from MAC_GERCOMPRAFORN xp
                                                          where xp.seqgercompra = t.seqgercompra),t.nroempresageralote),
                nvl( t.utilnatimorto,'N'), t.incsugcompraloja, T.SEQCONDCONDPRAZOPAGTO, t.INTEGRACOMPRASMOBILE,
                t.INDUSAREGIAOCOMPRA, (
                                      case NVL(t.integracomprasmobile,'N')
                                        when 'S' Then
                                          (select min(xe.seqfornecedor)
                                             from MAC_GERCOMPRAFORN xe
                                            where xe.seqgercompra = t.seqgercompra)
                                        else null
                                      end
                                      ),
                t.INDQUEBRARECBTO, t.INDQTDDTARECEBDIFITEM, t.INDGEREDIAUT, t.INDTIPDTARECEBDIF,t.TIPOMODELOCOMPRA,
                t.AGENDAHSDOMINGO, t.AGENDAHSSEGUNDA, t.AGENDAHSTERCA, t.AGENDAHSQUARTA, t.AGENDAHSQUINTA,
                t.AGENDAHSSEXTA,   t.AGENDAHSSABADO,  t.AGENDADOMINGO, t.AGENDASEGUNDA,  t.AGENDATERCA,
                t.AGENDAQUARTA,    t.AGENDAQUINTA,    t.AGENDASEXTA,   t.AGENDASABADO,
                t.INDEMPPEDIDOFORMAABASTEC, t.SEQFORNECPRINCIPAL, t.utiladicsugestpromoc,
                t.NROCONDPAGTOTRANSF, t.INDDIASESPECIFMEDVDA, t.TIPOLIMRECEBTOEM, t.INDCOTACAOFLV );
        -- Gera as datas fixas de recebimento
        IF t.INDQTDDTARECEBDIFITEM = 'S' AND t.INDTIPDTARECEBDIF IN ('S','I') THEN
          INSERT INTO MAC_GERCOMPRAPED (
                 SEQGERCOMPRAPED,
                 SEQGERCOMPRA,
                 NROPEDIDO,
                 DTARECEBIMENTO,
                 DTAHRINCLUSAO,
                 USUINCLUSAO,
                 INTERVALO,
                 DIASEMANA,
                 SEMANA)
          SELECT S_SEQGERCOMPRAPED.NEXTVAL,
                 vnSeqGerCompra,
                 NROPEDIDO,
                 TRUNC(DECODE(t.INDTIPDTARECEBDIF,
                       'S', (SYSDATE + NVL(SEMANA,0)) - (to_char((SYSDATE + NVL(SEMANA,0)), 'D') - NVL(DIASEMANA,1)),
                       'I', (SYSDATE + NVL(INTERVALO,0)))),
                 SYSDATE,
                 'GERALOTEAUTO',
                 INTERVALO,
                 DIASEMANA,
                 SEMANA
          FROM   MAC_GERCOMPRAPED
          WHERE  SEQGERCOMPRA = t.SEQGERCOMPRA;
        END IF;
        -- inserindo as empresas do novo lote
        -- RC 122764
        if t.tipomodelocompra = 'A' and vsConsdApenasEmpAgenda = 'S' then
            insert into MAC_GERCOMPRAEMP
            ( SEQGERCOMPRA, NROEMPRESA, NROEMPFATUR )
              select vnSeqGerCompra, a.nroempresa, a.nroempresa
              from mac_gercompraemp a, max_empresa b
              where a.seqgercompra = t.seqgercompra
              and   a.nroempresa = b.nroempresa
              and   b.status = 'A'
              and   exists (select 1
                            from maf_fornecagenda b, mac_gercompraforn c, max_empresa e
                            where b.seqfornecedor = c.seqfornecedor
                            and   c.seqgercompra = a.seqgercompra
                            and   b.dtavisita = trunc(pdDtaInclusao)
                            and   b.seqcomprador = t.seqcomprador
                            and   a.nroempresa = e.nroempresa
                            and   e.nrodivisao = b.nrodivisao
                            and   nvl(b.nroempresa,a.nroempresa) = a.nroempresa
                           )
              and (vsPDConsisteStatusForn != 'D' or
              (vsPDConsisteStatusForn = 'D' and
               not exists (SELECT 1
                              FROM Mac_Gercompraforn Cf, Maf_Fornecdivisao f,
                                   Max_Empresa e
                              WHERE Cf.Seqgercompra = a.Seqgercompra
                              AND f.Nrodivisao = e.Nrodivisao
                              AND Cf.Seqfornecedor = f.Seqfornecedor
                              AND e.Nroempresa = a.Nroempresa
                              AND a.Seqgercompra = Cf.Seqgercompra
                              AND f.Statusgeral != 'A'
                              UNION
                              SELECT DISTINCT b.nroempresa
                              FROM Max_Empresa b
                              WHERE b.Nroempresa = a.Nroempresa
                              AND NOT EXISTS (SELECT 1
                                              FROM Maf_Fornecdivisao c, Mac_Gercompraforn y
                                              WHERE y.Seqgercompra = a.Seqgercompra
                                              AND y.Seqfornecedor = c.Seqfornecedor
                                              AND c.Nrodivisao = b.Nrodivisao))));
        else
            insert into MAC_GERCOMPRAEMP
            ( SEQGERCOMPRA, NROEMPRESA, NROEMPFATUR )
              select vnSeqGerCompra, a.nroempresa, a.nroempresa
              from mac_gercompraemp a, max_empresa b
              where a.seqgercompra = t.seqgercompra
              and   a.nroempresa = b.nroempresa
              and   b.status = 'A'
              and (vsPDConsisteStatusForn != 'D' or
              (vsPDConsisteStatusForn = 'D' and
               not exists (SELECT 1
                              FROM Mac_Gercompraforn Cf, Maf_Fornecdivisao f,
                                   Max_Empresa e
                              WHERE Cf.Seqgercompra = a.Seqgercompra
                              AND f.Nrodivisao = e.Nrodivisao
                              AND Cf.Seqfornecedor = f.Seqfornecedor
                              AND e.Nroempresa = a.Nroempresa
                              AND a.Seqgercompra = Cf.Seqgercompra
                              AND f.Statusgeral != 'A'
                              UNION
                              SELECT DISTINCT b.nroempresa
                              FROM Max_Empresa b
                              WHERE b.Nroempresa = a.Nroempresa
                              AND NOT EXISTS (SELECT 1
                                              FROM Maf_Fornecdivisao c, Mac_Gercompraforn y
                                              WHERE y.Seqgercompra = a.Seqgercompra
                                              AND y.Seqfornecedor = c.Seqfornecedor
                                              AND c.Nrodivisao = b.Nrodivisao))));
        end if;
        INSERT INTO MAC_GERCOMPRAREGIAO
        ( SEQGERCOMPRA, SEQREGIAO )
        SELECT VNSEQGERCOMPRA, A.SEQREGIAO
        FROM MAC_GERCOMPRAREGIAO A
        WHERE A.SEQGERCOMPRA = t.seqgercompra;
        UPDATE MAC_GERCOMPRAEMP
        SET INDRESTRINGELOJA = (SELECT B.VALOR FROM MAX_PARAMETRO B
                         WHERE B.GRUPO = 'GER_COMPRAS'
                         AND B.PARAMETRO = 'RESTRINGE_MANUT_LOTE_EMP_LOJA'
                         AND B.NROEMPRESA = MAC_GERCOMPRAEMP.NROEMPRESA)
        WHERE SEQGERCOMPRA = vnSeqGerCompra;
        -- inserindo os fornecedores do novo lote
        INSERT INTO MAC_GERCOMPRAFORN
        ( SEQGERCOMPRA, SEQFORNECEDOR,
          DTARECEBIMENTO,
          QTDDIASRECEB,
          QTDDIASLIMRECEB )
        SELECT vnSeqGerCompra,  seqfornecedor,
               nvl(trunc(pdDtaInclusao)+nvl(vnDiasRec, qtddiasreceb),dtarecebimento),
               nvl(vnDiasRec,qtddiasreceb), nvl(vnDiasLimRec,qtddiaslimreceb)
        FROM mac_gercompraforn
        WHERE seqgercompra = t.seqgercompra;
        IF vsPD_PermQtdAbastecFrac = 'S' THEN
            vnQtdAbastecAteAux := trunc( vnQtdAbastecAte );
        ELSE
            vnQtdAbastecAteAux := vnQtdAbastecAte;
        END IF;
        select fc5_diferencaemdias(sysdate,trunc (sysdate) + vnQtdAbastecAteAux,vsPdContaAbastDiaUtil,vsPdContaAbastSabado,
                            vsPdContaAbastDomingo,vsPdContaAbastFeriado)
        into vnQtdDiaUtilAbastecAux
        from dual;
         SELECT MOD( vnQtdAbastecAte, 1 )
          INTO vnCalcQtdAbastec
          FROM DUAL;
        IF vsPD_PermQtdAbastecFrac = 'S' THEN
            vnQtdDiaUtilAbastecAux := vnQtdDiaUtilAbastecAux + NVL(vnCalcQtdAbastec, 0);
        END IF;
        begin
          select A.FILTRO_WHERE
          into   vsWhere
          from   MAC_GERCOMPRAFILTRO A
          where  A.SEQGERCOMPRA = t.seqgercompra;
       exception
       when no_data_found
       then vsWhere := null;
       end;
       if vsWhere is not null then
          vsWhere := ' and ' || vsWhere;
       end if;
       if vsPDItensEmpNaoAbastInatComp = 'N' then
              vsWhere := vsWhere||' AND MACV_INSCOMPRAITEM.statuscompra = '||chr(39) || 'A' || chr(39);
       end if;
       vsWhereAgenda := null;
       if t.tipomodelocompra = 'A' and vsConsdApenasEmpAgenda = 'S' then
          vsWhereAgenda := ' and   exists (select 1
                                from maf_fornecagenda b, max_empresa e
                                where b.seqfornecedor = MAC_GERCOMPRAFORN.seqfornecedor
                                and   b.dtavisita =  ' || chr(39) || trunc(pdDtaInclusao) || chr(39) || '
                                and   b.seqcomprador = ' || t.seqcomprador || '
                                and   e.nroempresa = MAC_GERCOMPRAEMP.nroempresa
                                and   e.nrodivisao = b.nrodivisao
                                and   nvl(b.nroempresa,MAC_GERCOMPRAEMP.nroempresa) = MAC_GERCOMPRAEMP.nroempresa ) ';
       end if;
       if t.tipoabastecate = 'Conforme Classificação de Abastecimento' then
         vsDiasAbastec := '( select nvl(max(ca.QTDDIACOMPRA),0) '||chr(13)||
                             ' from MAP_CLASSIFABASTEC ca '||chr(13)||
                            ' where ca.CODCLASSIFABASTEC = MACV_INSCOMPRAITEM.CODCLASSIFABASTEC ) ';
       else
         vsDiasAbastec := vnQtdDiaUtilAbastecAux;
       end if;
       if vsPD_UtilConceitoProdSec = 'S' and vsPD_PermProdSecundario = 'N' then
          vsSQL := 'insert into MAC_GERCOMPRAITEM(
                          SEQGERCOMPRA, SEQPRODUTO, NROEMPRESA,
                          SEQFORNECEDOR, SITUACAOITEM, TFDTABASECUSTO,
                          TFPERCNEGOC, QTDDIAABASTEC, DTAINICIOMEDVDA,
                          DTAFINALMEDVDA, CONSIDERAATRASOFORNEC, CONSIDERASODIAUTIL,
                          TIPOSUGCOMPRA, GERARESERVALOTEPENDENTE, INDINATIVO, UTILNATIMORTO )
                    select DISTINCT ' ||
                             vnSeqGerCompra || ', NVL(PROD.SEQPRODUTO, MACV_INSCOMPRAITEM.SEQPRODUTO), MACV_INSCOMPRAITEM.NROEMPRESA,
                             MAP_FAMFORNEC.SEQFORNECEDOR, ' || chr(39) || 'R' || chr(39) || ', ' || nvl(to_char(t.tfdtabasecusto), 'NULL') || ', '
                             || nvl(to_char(t.tfpercnegoc), 'NULL') || ', ' || vsDiasAbastec || ', ' || chr(39) || t.dtainiciomedvdacalc || chr(39) || ', '
                             || chr(39) || t.dtafinalmedvdacalc || chr(39) || ', ' || chr(39) || vsPdConsideraAtrasoFornec || chr(39) ||', ' || chr(39) || vsPdConsideraSoDiaUtil || chr(39) || ', '
                             || chr(39) || t.tiposugcompra || chr(39) || ',' || chr(39) || vsPdGeraReservaLotePend || chr(39)||','
                             || 'decode(''' || vsPDAtualItemLoteStProd || ''',''' || 'S' || ''',decode(MACV_INSCOMPRAITEM.STATUSCOMPRA,''' || 'A' || ''','''
                             || 'N' || ''',''' || 'S' ||'''),null),NVL( MAC_GERCOMPRA.UTILNATIMORTO,''N'')'
                     || ' from MACV_INSCOMPRAITEM, MAP_FAMFORNEC, MAC_GERCOMPRAFORN, MAC_GERCOMPRAEMP, MAC_GERCOMPRA,
                               MAP_PRODUTO PROD,
                               (SELECT NVL(VALOR, ''N'') VALOR,
                                       PM.NROEMPRESA
                                FROM   MAX_PARAMETRO PM
                                WHERE  PM.PARAMETRO = ''VERIF_TIT_VENC_GERA_PEDIDO''
                                AND    PM.GRUPO     = ''PED_COMPRA''
                               ) P
                       where MACV_INSCOMPRAITEM.NROEMPRESA   = MAC_GERCOMPRAEMP.Nroempresa
                         AND MAC_GERCOMPRAEMP.SEQGERCOMPRA   = MAC_GERCOMPRAFORN.SEQGERCOMPRA
                         AND MAC_GERCOMPRA.SEQGERCOMPRA      = MAC_GERCOMPRAEMP.SEQGERCOMPRA
                         AND MAP_FAMFORNEC.SEQFAMILIA        = MACV_INSCOMPRAITEM.SEQFAMILIA
                         AND P.NROEMPRESA                    = MACV_INSCOMPRAITEM.NROEMPRESA
                         AND P.VALOR                        != ''B''
                         AND PROD.SEQPRODUTOSECUNDARIO(+)    = MACV_INSCOMPRAITEM.SEQPRODUTO
                         and MAC_GERCOMPRAFORN.SEQGERCOMPRA  = ' || t.seqgercompra
                    || ' and MAC_GERCOMPRAFORN.SEQFORNECEDOR = MAP_FAMFORNEC.SEQFORNECEDOR
                         and not exists
                                 (select 1
                                    from MAC_GERCOMPRAITEM X
                                   where X.SEQGERCOMPRA = MAC_GERCOMPRAFORN.SEQGERCOMPRA
                                     and X.NROEMPRESA = MACV_INSCOMPRAITEM.NROEMPRESA
                                     and X.SEQPRODUTO = NVL(PROD.SEQPRODUTO, MACV_INSCOMPRAITEM.SEQPRODUTO)
                                     and X.SEQFORNECEDOR = MAC_GERCOMPRAFORN.SEQFORNECEDOR)
                                     ' || vsWhere || vsWhereAgenda;
       else
          vsSQL := 'insert into MAC_GERCOMPRAITEM(
                          SEQGERCOMPRA, SEQPRODUTO, NROEMPRESA,
                          SEQFORNECEDOR, SITUACAOITEM, TFDTABASECUSTO,
                          TFPERCNEGOC, QTDDIAABASTEC, DTAINICIOMEDVDA,
                          DTAFINALMEDVDA, CONSIDERAATRASOFORNEC, CONSIDERASODIAUTIL,
                          TIPOSUGCOMPRA, GERARESERVALOTEPENDENTE, INDINATIVO, UTILNATIMORTO )
                    select DISTINCT ' ||
                             vnSeqGerCompra || ', SEQPRODUTO, MACV_INSCOMPRAITEM.NROEMPRESA,
                             MAP_FAMFORNEC.SEQFORNECEDOR, ' || chr(39) || 'R' || chr(39) || ', ' || nvl(to_char(t.tfdtabasecusto), 'NULL') || ', '
                             || nvl(to_char(t.tfpercnegoc), 'NULL') || ', ' || vsDiasAbastec || ', ' || chr(39) || t.dtainiciomedvdacalc || chr(39) || ', '
                             || chr(39) || t.dtafinalmedvdacalc || chr(39) || ', ' || chr(39) || vsPdConsideraAtrasoFornec || chr(39) ||', ' || chr(39) || vsPdConsideraSoDiaUtil || chr(39) || ', '
                             || chr(39) || t.tiposugcompra || chr(39) || ',' || chr(39) || vsPdGeraReservaLotePend || chr(39)||','
                             || 'decode(''' || vsPDAtualItemLoteStProd || ''',''' || 'S' || ''',decode(MACV_INSCOMPRAITEM.STATUSCOMPRA,''' || 'A' || ''','''
                             || 'N' || ''',''' || 'S' ||'''),null),NVL( MAC_GERCOMPRA.UTILNATIMORTO,''N'')'
                     || ' from MACV_INSCOMPRAITEM, MAP_FAMFORNEC, MAC_GERCOMPRAFORN, MAC_GERCOMPRAEMP, MAC_GERCOMPRA,
                               (SELECT NVL(VALOR, ''N'') VALOR,
                                       PM.NROEMPRESA
                                FROM   MAX_PARAMETRO PM
                                WHERE  PM.PARAMETRO = ''VERIF_TIT_VENC_GERA_PEDIDO''
                                AND    PM.GRUPO     = ''PED_COMPRA''
                               ) P
                       where MACV_INSCOMPRAITEM.NROEMPRESA   = MAC_GERCOMPRAEMP.Nroempresa
                         AND MAC_GERCOMPRAEMP.SEQGERCOMPRA   = MAC_GERCOMPRAFORN.SEQGERCOMPRA
                         AND MAC_GERCOMPRA.SEQGERCOMPRA      = MAC_GERCOMPRAEMP.SEQGERCOMPRA
                         AND P.NROEMPRESA                    = MACV_INSCOMPRAITEM.NROEMPRESA
                         AND (P.VALOR                        != ''B''
                               OR
                              (P.VALOR = ''B''
                                AND
                               EXISTS  (SELECT  COUNT(1)
                                        FROM  FI_TITULO
                                        WHERE ABERTOQUITADO = ''A''
                                        AND OBRIGDIREITO = ''D''
                                        AND DTAVENCIMENTO < TRUNC(SYSDATE)
                                        AND NROEMPRESA = MACV_INSCOMPRAITEM.NROEMPRESA
                                        AND SEQPESSOA = MAC_GERCOMPRAFORN.SEQFORNECEDOR
                                       )
                               )
                              )
                         AND MAP_FAMFORNEC.SEQFAMILIA        = MACV_INSCOMPRAITEM.SEQFAMILIA
                         and MAC_GERCOMPRAFORN.SEQGERCOMPRA  = ' || t.seqgercompra
                    || ' and MAC_GERCOMPRAFORN.SEQFORNECEDOR = MAP_FAMFORNEC.SEQFORNECEDOR
                         and not exists
                                 (select 1
                                    from MAC_GERCOMPRAITEM X
                                   where X.SEQGERCOMPRA = MAC_GERCOMPRAFORN.SEQGERCOMPRA
                                     and X.NROEMPRESA = MACV_INSCOMPRAITEM.NROEMPRESA
                                     and X.SEQPRODUTO = MACV_INSCOMPRAITEM.SEQPRODUTO
                                     and X.SEQFORNECEDOR = MAC_GERCOMPRAFORN.SEQFORNECEDOR)
                                     ' || vsWhere || vsWhereAgenda;
        end if;
        EXECUTE IMMEDIATE vsSQL;
       UPDATE MAC_GERCOMPRAITEM A
       SET    A.TIPORECALCULO = 'TF',
              A.SITUACAOITEM = 'R'
       WHERE  A.SEQGERCOMPRA = vnSeqGerCompra;
        IF t.INDUSAREGIAOCOMPRA = 1 THEN
          INSERT INTO MAC_GERCOMPRAEMPREGIAO
                  (
                   SEQGERCOMPRA,
                   NROEMPRESA,
                   SEQREGIAO,
                   SEQPRODUTO
                  )
          SELECT  vnSeqGerCompra,
                  RG.NROEMPRESACOMPRA,
                  RE.SEQREGIAO,
                  A.SEQPRODUTO
          FROM    MAC_GERCOMPRAITEM   A,
                  MSU_REGIAOCOMPRAEMP RE,
                  MSU_REGIAOCOMPRA RG
          WHERE   A.NROEMPRESA   = RE.NROEMPRESA
          AND     RE.SEQREGIAO   = RG.SEQREGIAO
          AND     A.SEQGERCOMPRA = vnSeqGerCompra
          GROUP BY RE.SEQREGIAO,
                   RG.NROEMPRESACOMPRA,
                   A.SEQPRODUTO;
        END IF;
        if vsPDMobLiberaLote = 'S' and nvl(t.integracomprasmobile,'N') = 'S' then
          spmac_acatasugestaoCompra(vnseqgercompra);
          IF t.INDUSAREGIAOCOMPRA = 1 THEN
             SPMAC_ACATASUGESTAOREGIAO(vnseqgercompra, 1);
          END IF;
          --Libera o lote para Compras FLV Mobile
          update MAC_GERCOMPRA
             set USUALTERACAO    = 'AUTOMATICO',
                 DTAHORALTERACAO = sysdate,
                 SITUACAOLOTE    = 'M'
           where SEQGERCOMPRA = vnSeqGerCompra;
        End if;
        Commit;
  end loop;
  -- busca lotes que foram gerados (tratamento p/ eventual interrupção)
   for  t in (
           select a.seqgercompra,
                  A.INDUSAREGIAOCOMPRA,
                  A.NROEMPRESAGERALOTE,
                  B.FINALIZAAUTO,
                  A.TIPOLOTE
             from mac_gercompra a, mac_gercompra b
            where a.seqgermodelocompra = b.seqgercompra
              and a.Dtahorinclusao >= trunc(pdDtaInclusao)
              and a.Dtahorinclusao <= trunc(pdDtaInclusao) + 0.99999
              and nvl(a.situacaolote, 'A') Not In ('F', 'C')
              and nvl(b.INDACATASUGAUTO, nvl(b.FINALIZAAUTO, 'N')) = 'S'
              and a.seqgermodelocompra = nvl(pnSeqGerCompraLote, a.seqgermodelocompra)
            )
  loop
    SP_BUSCAPARAMDINAMICO('GER_COMPRAS', T.NROEMPRESAGERALOTE, 'FINALIZA_LOTE_COMPRAS_PEDIDOS', 'S', 'A',
    'QUAL EMPRESA SERÁ CONSIDERADA PARA GERAÇÃO DOS PEDIDOS : (A-EMPRESA LOGADA /B-UM PEDIDO PARA CADA EMPRESA DO LOTE)', vsPDFinalizaLotePedidosG);
      /*Atualiza Quantidade Pedida do item*/
      if vsAcataSugeridoFinalAuto = 'S' then
        spmac_acatasugestaocompra(t.seqgercompra);
        vsAcataSugeridoFinalAuto := 'N';
      end if;
    --
    IF vsPDBloqPedMinCadFornec != 'N' AND vsPDBloqPedMinCadFornec != 'D' AND INSTR(vsPDDefTipoPedBloqPedMin, t.tipolote) = 0 THEN
       SPMAC_AGRUPAEMPRESAVLRMIN (t.seqgercompra, vsPDBloqPedMinCadFornec, vbRetorno);
    ELSE
       /*Atualiza empresa Faturamento para geração dos pedidos*/
       IF nvl(t.INDUSAREGIAOCOMPRA,0) = 0 THEN
          UPDATE MAC_GERCOMPRAEMP E
          SET E.NROEMPFATUR = DECODE(vsPDFinalizaLotePedidosG,
                                      'B',
                                      E.NROEMPRESA,
                                      T.NROEMPRESAGERALOTE)
          WHERE E.SEQGERCOMPRA = t.seqgercompra;
       END IF;
    END IF;
    if nvl(t.FINALIZAAUTO, 'N') = 'S' then
      delete from mac_gercompraconsistencia c
      where c.seqgercompra = t.seqgercompra;
      spmac_consisteLoteCompra(t.seqgercompra, t.nroempresageralote, '', 'A', 0, 0, 'J');
      select COUNT(1)
        into vnContConsist
        from MAC_GERCOMPRACONSISTENCIA c
       where C.SEQGERCOMPRA = t.seqgercompra;
      if vnContConsist = 0 then
        spmac_finalizaLoteCompraAuto(t.seqgercompra, vsAcataSugeridoFinalAuto, null, 'J');
      end if;
    end if;
    Commit;
    IF vsPDUtilConcDepFechado = 'S' THEN
       vsAcataSugeridoFinalAuto := 'N';
    ELSE
       vsAcataSugeridoFinalAuto := 'S';
    END IF;
    IF vsPDUtilConcDepFechado = 'S' THEN
       vsAcataSugeridoFinalAuto := 'N';
    ELSE
       vsAcataSugeridoFinalAuto := 'S';
    END IF;
  end loop;
end NAGP_spMac_GeraLoteCompra;
