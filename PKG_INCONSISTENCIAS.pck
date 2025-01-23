create or replace package PKG_INCONSISTENCIAS is
    procedure sp_IniciaProcesso_Geral(-- Gerais
                                      psTipoGeracao           in varchar2,
                                      pdDtaBase               in date,
                                      psUsuAlteracao          in ge_usuario.codusuario%type,
                                      psEnviaEmail            in varchar2,
                                      pnNroEmpresaConfigEmail in max_empresa.nroempresa%type,
                                      pnSeqGrupoEmail         in ge_grupoemail.seqgrupo%type,
                                      psDirectorieOracle      in varchar2,
                                      -- Específico - Tributação
                                      psStatusTrib            in varchar2,
                                      -- Específico - Família
                                      pnDiasValidadeNCMFam    in integer);
    procedure sp_EnviaEmail_Inconsist(pnNroEmpresaConfigEmail in max_empresa.nroempresa%type,
                                      pnSeqGrupoEmail         in ge_grupoemail.seqgrupo%type,
                                      psDirectorieOracle      in varchar2,
                                      pnInseriuInconsistProd  in integer,
                                      pnInseriuInconsistFam   in integer,
                                      pnInseriuInconsistTrib  in integer);
    procedure sp_IniciaProcesso_Prod(psTipoGeracao      in varchar2,
                                     psListaSeqProduto  in varchar2,
                                     pdDtaBase          in date,
                                     psUsuAlteracao     in ge_usuario.codusuario%type,
                                     pnInseriuInconsist in out integer);
    procedure sp_Valida_Prod(pnSeqProduto       in map_produto.seqproduto%type,
                             psUsuAlteracao     in ge_usuario.codusuario%type,
                             pnInseriuInconsist in out number);
    procedure sp_Inconsist_Prod_300(pnSeqInconsist     in map_incons_produto.seqinconsist%type,
                                    psMotivo           in map_incons_produto.motivo%type,
                                    psUsuAlteracao     in ge_usuario.codusuario%type,
                                    psTipoBloqueio     in map_incons_produto.tipobloqueio%type,
                                    pnInseriuInconsist in out number);
    procedure sp_Inconsist_Prod_301(pnSeqInconsist     in map_incons_produto.seqinconsist%type,
                                    psMotivo           in map_incons_produto.motivo%type,
                                    psUsuAlteracao     in ge_usuario.codusuario%type,
                                    psTipoBloqueio     in map_incons_produto.tipobloqueio%type,
                                    pnInseriuInconsist in out number);
    procedure sp_Inconsist_Prod_302(pnSeqInconsist     in map_incons_produto.seqinconsist%type,
                                    psMotivo           in map_incons_produto.motivo%type,
                                    psUsuAlteracao     in ge_usuario.codusuario%type,
                                    psTipoBloqueio     in map_incons_produto.tipobloqueio%type,
                                    pnInseriuInconsist in out number);
    procedure sp_IniciaProcesso_Fam(psTipoGeracao      in varchar2,
                                    psListaSeqFamilia  in varchar2,
                                    pdDtaBase          in date,
                                    psUsuAlteracao     in ge_usuario.codusuario%type,
                                    pnDiasValidadeNCM  in integer,
                                    pnInseriuInconsist in out integer);
    procedure sp_Valida_Fam(pnSeqFamilia       in map_familia.seqfamilia%type,
                            psUsuAlteracao     in ge_usuario.codusuario%type,
                            pnDiasValidadeNCM  in integer,
                            pnInseriuInconsist in out number);
    procedure sp_Inconsist_Fam_100(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number);
    procedure sp_Inconsist_Fam_101(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number);
    procedure sp_Inconsist_Fam_102(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number);
    procedure sp_Inconsist_Fam_103(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number);
    procedure sp_Inconsist_Fam_104(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number);
    procedure sp_Inconsist_Fam_105(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number);
    procedure sp_Inconsist_Fam_106(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number);
    procedure sp_Inconsist_Fam_107(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number);
    procedure sp_Inconsist_Fam_108(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number);
    procedure sp_Inconsist_Fam_109(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number);
    procedure sp_Inconsist_Fam_110(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number);
    procedure sp_IniciaProcesso_Tribut(psTipoGeracao      in varchar2,
                                       psListaCodTribut   in varchar2,
                                       pdDtaBase          in date,
                                       psStatus           in varchar2,
                                       psUsuAlteracao     in ge_usuario.codusuario%type,
                                       pnInseriuInconsist in out integer);
    procedure sp_Valida_Tribut(pnNroTributacao    in map_tributacao.nrotributacao%type,
                               psUsuAlteracao     in ge_usuario.codusuario%type,
                               pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_600(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_601(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_602(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_603(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_604(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_605(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_606(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_607(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_608(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_609(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_610(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_611(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_612(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_613(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_614(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_615(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_616(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_617(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_618(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_Inconsist_Tribut_619(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number);
    procedure sp_GeraDadosCFOP_Tribut;
    function fc_VerifTempCFOP_Tribut
    return integer;
    
    /* Customizações Nagumo */
    PROCEDURE NAGP_INC_FAM_01     (pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number);
                                   
    PROCEDURE NAGP_INC_FAM_02     (pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number);
    
end PKG_INCONSISTENCIAS;
/
create or replace package body PKG_INCONSISTENCIAS is
    procedure sp_IniciaProcesso_Geral(-- Gerais
                                      psTipoGeracao           in varchar2,
                                      pdDtaBase               in date,
                                      psUsuAlteracao          in ge_usuario.codusuario%type,
                                      psEnviaEmail            in varchar2,
                                      pnNroEmpresaConfigEmail in max_empresa.nroempresa%type,
                                      pnSeqGrupoEmail         in ge_grupoemail.seqgrupo%type,
                                      psDirectorieOracle      in varchar2,
                                      -- Específico - Tributação
                                      psStatusTrib            in varchar2,
                                      -- Específico - Família
                                      pnDiasValidadeNCMFam    in integer)
    /*
    Parâmetros
    psTipoGeracao = L: lista de codigos
                         utilizando esta opção é obrigatório informar a lista no Parametro psListaCodTribut.
                  = D: data de alteracao, serão gerados todas as tributações alteradas a partir da data informada,
                         utilizando esta opção é obrigatório informar a data base no Parametro pdDtaBase.
                  = T: valida todas as tributações
    psListaCodTribut = quando o parametro psTipoGeracao for informado a opcao L, informar a lista com os codigos
                       neste parametro, podendo ser informado um ou mais codigos, exemplo: 10,20,30.
    pdDtaBase = quando o parametro psTipoGeracao for informado a opcao D, informar neste parametro a data base para
                exportacao dos registros, serao exportado todos os registros com data de alteracao maior ou igual a
                data informada neste parametros
    psUsuAlteracao = informar o usuario de execução do processo, qdo via job: C5JOB.
    psEnviaEmail = indica se envia a tabela de inconsistencia por e-mail no final do processo, informar S/N
    pnNroEmpresaConfigEmail = numero da empresa para bsucar as configurações de envio de e-mail
                              obrigatório qdo parametro psEnviaEmail for igual a S
    pnSeqGrupoEmail = informar o seqgrupo do grupo q deverá receber o e-mail com as inconsistencias,
                      obrigatório qdo parametro psEnviaEmail for igual a S.
    psDirectorieOracle = informar o diretorio do PLSQL
    psStatusTrib = permite filtrar o status das tributações, opções:
                   A - verifica somente tributacoes ativas
                   I - verifica somente tributacoes inativas
                   Null - verifica todas as tributacoes
    pnDiasValidadeNCMFam = Numero de dias que a data de alteração do NCM é considerada válida, obrigatório.
    */
    is
        vnInseriuInconsistProd integer;
        vnInseriuInconsistFam  integer;
        vnInseriuInconsistTrib integer;
    begin
        if psEnviaEmail = 'S' and
           (pnNroEmpresaConfigEmail is null or pnSeqGrupoEmail is null or psDirectorieOracle is null) then
             raise_application_error(-20100, 'Para utilizar a opção de envio de e-mail é necessário informar os parâmetros: pnNroEmpresaConfigEmail, pnSeqGrupoEmail, psDirectorieOracle.' || sqlerrm);
        end if;
        sp_IniciaProcesso_Tribut(psTipoGeracao,
                                 null,
                                 pdDtaBase,
                                 psStatusTrib,
                                 psUsuAlteracao,
                                 vnInseriuInconsistTrib);
        sp_IniciaProcesso_Fam(psTipoGeracao,
                              null,
                              pdDtaBase,
                              psUsuAlteracao,
                              pnDiasValidadeNCMFam,
                              vnInseriuInconsistFam);
        sp_IniciaProcesso_Prod(psTipoGeracao,
                               null,
                               pdDtaBase,
                               psUsuAlteracao,
                               vnInseriuInconsistProd);
        if psEnviaEmail = 'S' then
            PKG_INCONSISTENCIAS.sp_EnviaEmail_Inconsist(pnNroEmpresaConfigEmail,
                                                        pnSeqGrupoEmail,
                                                        psDirectorieOracle,
                                                        vnInseriuInconsistProd,
                                                        vnInseriuInconsistFam,
                                                        vnInseriuInconsistTrib);
        end if;
    exception
       when others then
           raise_application_error(-20200, sqlerrm);
    end sp_IniciaProcesso_Geral;
    procedure sp_EnviaEmail_Inconsist(pnNroEmpresaConfigEmail in max_empresa.nroempresa%type,
                                      pnSeqGrupoEmail         in ge_grupoemail.seqgrupo%type,
                                      psDirectorieOracle      in varchar2,
                                      pnInseriuInconsistProd  in integer,
                                      pnInseriuInconsistFam   in integer,
                                      pnInseriuInconsistTrib  in integer)
    is
        vhArquivo        UTL_FILE.file_type;
        vsNomeArquivo    varchar2(200);
        vsCabecalho      varchar2(4000);
        obj_param_smtp   c5_tp_param_smtp;
        vbAbriuArquivo   boolean;
        vbGerouInfAquivo boolean;
        vsArquivo        varchar2(2000);
        vsMensagem       varchar2(250);
        vsNomeArquivoZip varchar2(2000);
        vsRetorno        varchar2(2000);
        vsCaminhoArquivo varchar2(2000);
    begin
        vbAbriuArquivo := FALSE;
        vbGerouInfAquivo := FALSE;
        -- Busca as informações do servidor SMTP de acordo com a empresa
        obj_param_smtp := c5_tp_param_smtp(pnNroEmpresaConfigEmail);
        -- Gera o arquivo texto com as inconsistencias
        if psDirectorieOracle is not null then
           begin
               vsNomeArquivo := 'INCONSIST' || TO_CHAR(SYSDATE, 'yyyyMMddHH24MISS') || '.csv';
               vsNomeArquivoZip := 'INCONSIST' || TO_CHAR(SYSDATE, 'yyyyMMddHH24MISS') || '.zip';
               -- Abre o arquivo
               vhArquivo := UTL_FILE.fopen(psDirectorieOracle, vsNomeArquivo, 'W');
               vbAbriuArquivo := TRUE;
               if pnInseriuInconsistProd = 1 then
                   -- Insere o nome do grupo
                   UTL_FILE.put_line(vhArquivo, 'PRODUTOS');
                   -- Insere o cabeçalho no arquivo
                   vsCabecalho := 'SEQ;SEQINCONSIST;MOTIVO;DTAHORGERACAO;USUALTERACAO;DTAULTALTERACAO';
                   -- Insere a linha no arquivo
                   UTL_FILE.put_line(vhArquivo, vsCabecalho);
                   -- Salva o arquivo
                   UTL_FILE.fflush(vhArquivo);
                   -- Conteúdo do arquivo
                   For t in (select a.seqproduto || ';' ||
                                    a.seqinconsist || ';' ||
                                    a.motivo || ';' ||
                                    to_char(a.dtahorgeracao, 'dd/MM/yyyy HH24:MI:SS') || ';' ||
                                    a.usualteracao || ';' ||
                                    to_char(a.dtaultalteracao, 'dd/MM/yyyy') linha
                               from map_incons_produto a)
                   loop
                       -- Insere a linha no arquivo
                       UTL_FILE.put_line(vhArquivo, t.linha);
                       -- Salva o arquivo
                       UTL_FILE.fflush(vhArquivo);
                       vbGerouInfAquivo := TRUE;
                   end loop;
               end if;
               if pnInseriuInconsistFam = 1 then
                   -- Insere o nome do grupo
                   UTL_FILE.put_line(vhArquivo, 'FAMILIAS');
                   -- Insere o cabeçalho no arquivo
                   vsCabecalho := 'SEQ;SEQINCONSIST;MOTIVO;DTAHORGERACAO;USUALTERACAO;DTAULTALTERACAO';
                   -- Insere a linha no arquivo
                   UTL_FILE.put_line(vhArquivo, vsCabecalho);
                   -- Salva o arquivo
                   UTL_FILE.fflush(vhArquivo);
                   -- Conteúdo do arquivo
                   For t in (select b.seqfamilia || ';' ||
                                    b.seqinconsist || ';' ||
                                    b.motivo || ';' ||
                                    to_char(b.dtahorgeracao, 'dd/MM/yyyy HH24:MI:SS') || ';' ||
                                    b.usualteracao || ';' ||  to_char(b.dtaultalteracao, 'dd/MM/yyyy') linha
                               from map_incons_familia b)
                   loop
                       -- Insere a linha no arquivo
                       UTL_FILE.put_line(vhArquivo, t.linha);
                       -- Salva o arquivo
                       UTL_FILE.fflush(vhArquivo);
                       vbGerouInfAquivo := TRUE;
                   end loop;
               end if;
               if pnInseriuInconsistTrib = 1 then
                   -- Insere o nome do grupo
                   UTL_FILE.put_line(vhArquivo, 'TRIBUTACOES');
                   -- Insere o cabeçalho no arquivo
                   vsCabecalho := 'NROTRIBUTACAO;UFCLIENTEFORNEC;NROREGTRIBUTACAO;TIPTRIBUTACAO;UFEMPRESA;SEQINCONSIST;MOTIVO;DTAHORGERACAO;USUALTERACAO;DTAULTALTERACAO';
                   -- Insere a linha no arquivo
                   UTL_FILE.put_line(vhArquivo, vsCabecalho);
                   -- Salva o arquivo
                   UTL_FILE.fflush(vhArquivo);
                   -- Conteúdo do arquivo
                   For t in (select a.nrotributacao || ';' ||
                                    a.ufclientefornec  || ';' ||
                                    a.nroregtributacao  || ';' ||
                                    a.tiptributacao  || ';' ||
                                    a.ufempresa || ';' ||
                                    a.seqinconsist || ';' ||
                                    a.motivo || ';' ||
                                    to_char(a.dtahorgeracao, 'dd/MM/yyyy HH24:MI:SS') || ';' ||
                                    a.usualteracao || ';' ||
                                    to_char(a.dtaultalteracao, 'dd/MM/yyyy') linha
                             from   map_incons_tribut a)
                   loop
                       -- Insere a linha no arquivo
                       UTL_FILE.put_line(vhArquivo, t.linha);
                       -- Salva o arquivo
                       UTL_FILE.fflush(vhArquivo);
                       vbGerouInfAquivo := TRUE;
                   end loop;
               end if;
               -- Fecha o arquivo
               UTL_FILE.fclose_all;
            exception
                when utl_file.invalid_path then
                    raise_application_error(-20001, 'UTL_FILE.invalid_path');
                when utl_file.invalid_mode then
                    raise_application_error(-20001, 'UTL_FILE.invalid_mode');
                when utl_file.invalid_filehandle then
                    raise_application_error(-20001, 'UTL_FILE.invalid_filehandle');
                when utl_file.invalid_operation then
                    raise_application_error(-20001, 'UTL_FILE.invalid_operation');
                when utl_file.read_error then
                    raise_application_error(-20001, 'UTL_FILE.read_error');
                when utl_file.write_error then
                    raise_application_error(-20001, 'UTL_FILE.write_error');
                when utl_file.internal_error then
                    raise_application_error(-20001, 'UTL_FILE.internal_error');
                when others then
                    raise_application_error(-20001, 'UTL_FILE.other_error');
            end;
        end if;
        -- Compacta o arquivo
        sp_Compacta_Arquivo(psDirectorieOracle, vsNomeArquivo, vsNomeArquivoZip, 5, 'N', vsRetorno);
        -- Envia o e-mail para o grupo informado
         if vbAbriuArquivo and vbGerouInfAquivo then
               -- Busca o caminho do diretório do PLSQL
               select nvl(max(a.directory_path), '.')
                 into vsCaminhoArquivo
                 from all_directories a
                where a.directory_name = psDirectorieOracle;
               if vsCaminhoArquivo != '.' then
                   vsArquivo := vsCaminhoArquivo || '/' || vsNomeArquivoZip;
                   vsMensagem := '<h3>Arquivo compactado em anexo, ao descompatar acrescente a extensão CSV no arquivo.</h3>
                                  <br>
                                  <h4>Resumo:</h4>';
               end if;
         else
              vsArquivo := null;
              vsMensagem := '<h4>Nao houve inconsistências nesta data.</h4>';
         end if;
         sp_EnviaEmailTabela(pnNroEmpresa => pnNroEmpresaConfigEmail,
                             pnSeqGrupo   => pnSeqGrupoEmail,
                             psEmail      => null,
                             psAssunto    => 'Inconsistências - ' || to_char(sysdate, 'dd/MM/yyyy'),
                             psTabelas    => 'MAPV_INCONS_PROD,'  ||
                                             'MAPV_INCONS_FAM,'   ||
                                             'MAPV_INCONS_TRIBUT',
                             psTitulosTab => 'Inconsistências de Produto,' ||
                                             'Inconsistências de Família,' ||
                                             'Inconsistências de Tributação',
                             psCoresTab   => '#CEE3F6,' ||
                                             '#CEE3F6,' ||
                                             '#CEE3F6',
                             psAnexoBanco => vsArquivo,
                             pObj_param_smtp => obj_param_smtp,
                             psMensagem   => vsMensagem,
                             psEnviaMsg   => 'S');
        -- Exclui o arquivo gerado
        if vbAbriuArquivo then
           UTL_FILE.fremove(psDirectorieOracle, vsNomeArquivo);
           UTL_FILE.fremove(psDirectorieOracle, vsNomeArquivoZip);
        end if;
    exception
       when others then
           raise_application_error(-20200, sqlerrm);
    end sp_EnviaEmail_Inconsist;
    procedure sp_IniciaProcesso_Prod(psTipoGeracao      in varchar2,
                                     psListaSeqProduto  in varchar2,
                                     pdDtaBase          in date,
                                     psUsuAlteracao     in ge_usuario.codusuario%type,
                                     pnInseriuInconsist in out integer)
    /*
    Parâmetros:
    psTipoGeracao = L: Por lista de seq do produto. Utilizando esta opção, é obrigatório
                       informar a lista no parâmetro psListaSeqProduto.
                  = D: Por data de alteração. Serão gerados todas os produtos alterados
                       a partir da data informada, utilizando esta opção é obrigatório
                       informar a data base no parâmetro pdDtaBase.
                  = T: Todos os produtos
    psListaSeqProduto = quando no parâmetro psTipoGeracao for informada a opção L,
                      passar a lista com os seqs dos produtos, podendo ser um ou mais
                      codigos, exemplo: 10,20,30.
    pdDtaBase = quando o pârametro psTipoGeracao for informado a opção D, informar
                a data base para exportação dos registros. Serão exportados todos os
                registros com data de alteração maior ou igual a data informada.
    psUsuAlteracao = informar o usuario de execução do processo, quando via job: C5JOB.
    pnInseriuInconsist = se inseriu inconsistências retorna 1, caso contrário, retorna 0
    */
    is
         vsWhere            varchar2(4000);
         vsInsert           varchar2(4000);
         vsSql              varchar2(4000);
         vnInseriuInconsist integer;
         vbInseriu          boolean;
    begin
         -- Validação dos parâmetros do objeto
         if psTipoGeracao = 'L' and psListaSeqProduto is null then
             raise_application_error(-20100, 'Para utilizar a opção L no parâmetro psTipoGeracao é necessário informar a lista de produtos no parâmetro psListaSeqProdutos.' || sqlerrm);
         elsif psTipoGeracao = 'D' and pdDtaBase is null then
             raise_application_error(-20100, 'Para utilizar a opção D no parâmetro psTipoGeracao é necessário informar a data dase no parâmetro pdDtaBase.' || sqlerrm);
         elsif psTipoGeracao not in ('D', 'L', 'T') then
             raise_application_error(-20100, 'O valor informado no parâmetro psTipoGeracao está incorreto. Informe L, D ou T.' || sqlerrm);
         end if;
         -- Remove os registros anteriores
         execute immediate 'truncate table mapx_seqproduto';
         -- Monta o where do insert da tabela temporária mapx_seqproduto
         if psTipoGeracao = 'L' then
            vsWhere := ' where a.seqproduto in (select column_value from table(cast(c5_complexin.c5intable(' || chr(39) || psListaSeqProduto || chr(39) || ') as c5instrtable))) ';
         elsif psTipoGeracao = 'D' then
            vsWhere := ' where exists (select 1 from map_produto b where b.seqproduto = a.seqproduto and trunc(a.dtahoralteracao) >= to_date(' || chr(39) || to_char(pdDtaBase) || chr(39) || ')) ';
         elsif psTipoGeracao = 'T' then
            vsWhere := ' where 1 = 1 ';
         end if;
         vsInsert := 'insert into mapx_seqproduto(seqproduto)
                                           select a.seqproduto
                                             from map_produto a ';
         execute immediate vsInsert || vsWhere;
         -- Remove as inconsistências anteriores dos produtos que serão re-avaliados
         execute immediate 'delete map_incons_produto a
                             where exists (select 1
                                             from mapx_seqproduto b
                                            where a.seqproduto = b.seqproduto)';
         vbInseriu := false;
         -- Após inserir as tributações na tabela temporária, roda as procedures de inconsistência
         for vtObj in (select a.*
                         from map_cadinconsistenc a
                        where a.origem = 'PRODUTO'
                          and a.status = 'A')
         loop
             vsSql := 'BEGIN
                           PKG_INCONSISTENCIAS.' || vtObj.User_Procedure || '(:pnSeqInconsist, :psMotivo, :psUsuAlteracao, :psTipoBloqueio, :pnInseriuInconsist);
                       END;';
             execute immediate vsSql
                         using vtObj.Seqinconsist,
                               vtObj.Desccompleta,
                               psUsuAlteracao,
                               vtObj.Tipobloqueio,
                        in out vnInseriuInconsist;
             if vnInseriuInconsist > 0 then
                 vbInseriu := true;
             end if;
         end loop;
         -- Retorna o indicador informando se inseriu inconsistência
         if vbInseriu then
            pnInseriuInconsist := 1;
         else
            pnInseriuInconsist := 0;
         end if;
    end sp_IniciaProcesso_Prod;
    procedure sp_Valida_Prod(pnSeqProduto       in map_produto.seqproduto%type,
                             psUsuAlteracao     in ge_usuario.codusuario%type,
                             pnInseriuInconsist in out number)
    /*
    Utilizada pra validar um produto em específico, podendo ser chamada no formulário da app por exemplo
    */
    is
    begin
        sp_IniciaProcesso_Prod('L',                   -- psTipoGeracao (L- Lista)
                               to_char(pnSeqProduto), -- psListaSeqProduto (Seq do produto)
                               null,                  -- pdDtaBase
                               psUsuAlteracao,        -- psUsuAlteracao
                               pnInseriuInconsist);   -- pnInseriuInconsist
    end sp_Valida_Prod;
    procedure sp_Inconsist_Prod_300(pnSeqInconsist     in map_incons_produto.seqinconsist%type,
                                    psMotivo           in map_incons_produto.motivo%type,
                                    psUsuAlteracao     in ge_usuario.codusuario%type,
                                    psTipoBloqueio     in map_incons_produto.tipobloqueio%type,
                                    pnInseriuInconsist in out number)
    /*
    Inconsistência 300 - Produtos com Código ANP informado, mas sem informação
    na Descrição ANP, ou vice-versa.
    */
    is
    begin
        insert into map_incons_produto
              (seqproduto,
               seqinconsist,
               motivo,
               dtahorgeracao,
               dtaultalteracao,
               usualteracao,
               tipobloqueio)
        select distinct
               a.seqproduto,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               a.dtahoralteracao,
               psUsuAlteracao,
               psTipoBloqueio
          from map_produto     a,
               mapx_seqproduto x
         where x.seqproduto = a.seqproduto
           and ((a.codigoanp is not null and a.descricaoanp is null) or
                (a.codigoanp is null and a.descricaoanp is not null));
        pnInseriuInconsist := sql%rowcount;
    exception
        when others then
            raise_application_error(-20200, sqlerrm);
    end sp_Inconsist_Prod_300;
    procedure sp_Inconsist_Prod_301(pnSeqInconsist     in map_incons_produto.seqinconsist%type,
                                    psMotivo           in map_incons_produto.motivo%type,
                                    psUsuAlteracao     in ge_usuario.codusuario%type,
                                    psTipoBloqueio     in map_incons_produto.tipobloqueio%type,
                                    pnInseriuInconsist in out number)
    /*
    Inconsistência 301 - Produtos com Código ANP, vinculados a uma tributação em que
    o CFOP no CGO não é de uma operação com combustíveis.
    */
    is
    begin
       insert into map_incons_produto
             (seqproduto,
              seqinconsist,
              motivo,
              dtahorgeracao,
              dtaultalteracao,
              usualteracao,
              tipobloqueio)
       select distinct
              a.seqproduto,
              pnSeqInconsist,
              psMotivo,
              sysdate,
              a.dtahoralteracao,
              psUsuAlteracao,
              psTipoBloqueio
         from map_produto        a,
              map_famdivisao     b,
              mapx_seqproduto    x
        where a.seqfamilia = b.seqfamilia
          and a.seqproduto = x.seqproduto
          and a.codigoanp is not null
          and (-- Verifica CFOPs da Tributação por UF
               exists (select 1
                         from max_codgeralcfopuf d
                        where b.nrotributacao = d.nrotributacao
                              -- CFOPs de operações com combustíveis dentro do estado
                          and (d.cfopestado not in (1651, 1652, 1653, 1658, 1659, 1660, 1661, 1662, 1663, 1664,
                                                    5651, 5652, 5653, 5654, 5655, 5656, 5657, 5658, 5659, 5660,
                                                    5661, 5662, 5663, 5664, 5665, 5666, 5667)
                              -- CFOPs de operações com combustíveis fora do estado
                              or d.cfopforaestado not in (2651, 2652, 2653, 2658, 2659, 2660, 2661, 2662, 2663, 2664,
                                                          6651, 6652, 6653, 6654, 6655, 6656, 6657, 6658, 6659, 6660,
                                                          6661, 6662, 6663, 6664, 6665, 6666, 6667)
                              -- CFOPs de operações com combustíveis fora do país
                              or d.cfopexterior not in (3651, 3652, 3653, 7651, 7654, 7667)))
               or
               -- Verifica CFOPs da Tributação
               exists (select 1
                         from max_codgeralcfop c
                        where b.nrotributacao = c.nrotributacao
                              -- CFOPs de operações com combustíveis dentro do estado
                          and (c.cfopestado not in (1651, 1652, 1653, 1658, 1659, 1660, 1661, 1662, 1663, 1664,
                                                    5651, 5652, 5653, 5654, 5655, 5656, 5657, 5658, 5659, 5660,
                                                    5661, 5662, 5663, 5664, 5665, 5666, 5667)
                              -- CFOPs de operações com combustíveis fora do estado
                              or c.cfopforaestado not in (2651, 2652, 2653, 2658, 2659, 2660, 2661, 2662, 2663, 2664,
                                                          6651, 6652, 6653, 6654, 6655, 6656, 6657, 6658, 6659, 6660,
                                                          6661, 6662, 6663, 6664, 6665, 6666, 6667)
                              -- CFOPs de operações com combustíveis fora do país
                              or c.cfopexterior not in (3651, 3652, 3653, 7651, 7654, 7667)))
               or
               -- Verifica no CFOP do CGO
               exists (select 1
                         from max_codgeralcfop e,
                              max_codgeraloper f
                        where b.nrotributacao = e.nrotributacao
                          and e.codgeraloper = f.codgeraloper
                              -- CFOPs de operações com combustíveis no estado
                          and (f.cfopestado not in (1651, 1652, 1653, 1658, 1659, 1660, 1661, 1662, 1663, 1664,
                                                5651, 5652, 5653, 5654, 5655, 5656, 5657, 5658, 5659, 5660,
                                                5661, 5662, 5663, 5664, 5665, 5666, 5667)
                               -- CFOPs de operações com combustíveis fora do estado
                               or f.cfopforaestado not in (2651, 2652, 2653, 2658, 2659, 2660, 2661, 2662, 2663, 2664,
                                                       6651, 6652, 6653, 6654, 6655, 6656, 6657, 6658, 6659, 6660,
                                                       6661, 6662, 6663, 6664, 6665, 6666, 6667)
                               -- CFOPs de operações com combustíveis fora do país
                               or f.cfopexterior not in (3651, 3652, 3653, 7651, 7654, 7667))));
        pnInseriuInconsist := sql%rowcount;
        exception when others then
            raise_application_error(-20200, sqlerrm);
    end sp_Inconsist_Prod_301;
    procedure sp_Inconsist_Prod_302(pnSeqInconsist     in map_incons_produto.seqinconsist%type,
                                    psMotivo           in map_incons_produto.motivo%type,
                                    psUsuAlteracao     in ge_usuario.codusuario%type,
                                    psTipoBloqueio     in map_incons_produto.tipobloqueio%type,
                                    pnInseriuInconsist in out number)
    is
    begin
       /*
       Inconsistência 302 - Produtos com Código GTIN inválido e permitido para uso
       na integração NF-e / NFC-e.
       */
       insert into map_incons_produto
             (seqproduto,
              seqinconsist,
              motivo,
              dtahorgeracao,
              dtaultalteracao,
              usualteracao,
              tipobloqueio)
       select distinct
              a.seqproduto,
              pnSeqInconsist,
              psMotivo,
              sysdate,
              b.dtahoralteracao,
              psUsuAlteracao,
              psTipoBloqueio
         from map_prodcodigo  a,
              map_produto     b,
              mapx_seqproduto x
        where b.seqproduto = a.seqproduto
          and x.seqproduto = a.seqproduto
          and a.indutilnfe = 'S'
          and (((select fValidaGTIN(a.codacessonum) from dual) != 'S')
              -- Verifica se o código possui 14 dígitos e se inicia com '0'
              or (length(a.codacessonum) = 14 and
              lpad(a.codacessonum, 1, 1) = '0'));
        pnInseriuInconsist := sql%rowcount;
        exception when others then
            raise_application_error(-20200, sqlerrm);
    end sp_Inconsist_Prod_302;
    procedure sp_IniciaProcesso_Fam(psTipoGeracao      in varchar2,
                                    psListaSeqFamilia  in varchar2,
                                    pdDtaBase          in date,
                                    psUsuAlteracao     in ge_usuario.codusuario%type,
                                    pnDiasValidadeNCM  in integer,
                                    pnInseriuInconsist in out integer)
    /*
    Parâmetros:
    psTipoGeracao = L: Por lista de seq da família. Utilizando esta opção, é obrigatório
                       informar a lista no parâmetro psListaSeqFamilia.
                  = D: Por data de alteração. Serão gerados todas as famílias alteradas
                       a partir da data informada, utilizando esta opção é obrigatório
                       informar a data base no parâmetro pdDtaBase.
                  = T: Todas as famílias
    psListaSeqFamilia = quando no parâmetro psTipoGeracao for informada a opção L,
                      passar a lista com os seqs das famílias, podendo ser um ou mais
                      codigos, exemplo: 10,20,30.
    pdDtaBase = quando o pârametro psTipoGeracao for informado a opção D, informar
                a data base para exportação dos registros. Serão exportados todos os
                registros com data de alteração maior ou igual a data informada.
    psUsuAlteracao = informar o usuario de execução do processo, qdo via job: C5JOB.
    pnDiasValidadeNCM = Numero de dias que a data de alteração do NCM é considerada válida, obrigatório.
    pnInseriuInconsist = se inseriu inconsistencias retorna 1, senao inseriu nada retorna 0
    */
    is
        vsWhere            varchar2(4000);
        vsInsert           varchar2(4000);
        vsSql              varchar2(4000);
        vnInseriuInconsist integer;
        vbInseriu          boolean;
    begin
         -- Validação dos parâmetros do objeto
         if psTipoGeracao = 'L' and psListaSeqFamilia is null then
             raise_application_error(-20100, 'Para utilizar a opção L no parâmetro psTipoGeracao é necessário informar a lista de famílias no parâmetro psListaSeqFamilia.' || sqlerrm);
         elsif psTipoGeracao = 'D' and pdDtaBase is null then
             raise_application_error(-20100, 'Para utilizar a opção D no parâmetro psTipoGeracao é necessário informar a data base no parâmetro pdDtaBase.' || sqlerrm);
         elsif psTipoGeracao not in ('D', 'L', 'T') then
             raise_application_error(-20100, 'O valor informado no parâmetro psTipoGeracao está incorreto. Informe L, D ou T.' || sqlerrm);
         end if;
         -- Remove os registros anteriores
         execute immediate 'truncate table mapx_seqfamilia';
         -- Monta o where do insert da tabela temporaria mapx_seqfamilia
         if psTipoGeracao = 'L' then
            vsWhere := ' where a.seqfamilia in (select column_value from table(cast(c5_complexin.c5intable( ' || chr(39) || psListaSeqFamilia || chr(39) || ') as c5instrtable))) ';
         elsif psTipoGeracao = 'D' then
            vsWhere := ' where exists (select 1 from map_familia b where b.seqfamilia = a.seqfamilia and trunc(a.dtahoralteracao) >= to_date(' || chr(39) || to_char(pdDtaBase) || chr(39) || ')) ';
         elsif psTipoGeracao = 'T' then
            vsWhere := ' where 1 = 1 ';
         end if;
         vsInsert := 'insert into mapx_seqfamilia(seqfamilia)
                                           select a.seqfamilia
                                             from map_familia a ';
         execute immediate vsInsert || vsWhere;
         -- Remove as inconsistências anteriores das famílias que serão re-avaliadas
         execute immediate 'delete map_incons_familia a
                             where exists (select 1
                                             from mapx_seqfamilia b
                                            where a.seqfamilia = b.seqfamilia)';
         vbInseriu := false;
         -- Após inserir as tributações na tabela temporária, roda as procedures de inconsistência
         for vtObj in (select a.*
                         from map_cadinconsistenc a
                        where a.origem = 'FAMILIA'
                          and a.status = 'A')
         loop
             vsSql := 'BEGIN
                           PKG_INCONSISTENCIAS.' || vtObj.User_Procedure || '(:pnSeqInconsist, :psMotivo, :psUsuAlteracao, :psTipoBloqueio, :pnDiasValidadeNCM, :pnInseriuInconsist);
                       END;';
             execute immediate vsSql
                         using vtObj.Seqinconsist,
                               vtObj.Desccompleta,
                               psUsuAlteracao,
                               vtObj.
                               Tipobloqueio,
                               pnDiasValidadeNCM,
                        in out vnInseriuInconsist;
             if vnInseriuInconsist > 0 then
                 vbInseriu := true;
             end if;
         end loop;
         -- Retorna o indicador informando se inseriu inconsistência
         if vbInseriu then
            pnInseriuInconsist := 1;
         else
            pnInseriuInconsist := 0;
         end if;
    end sp_IniciaProcesso_Fam;
    procedure sp_Valida_Fam(pnSeqFamilia       in map_familia.seqfamilia%type,
                            psUsuAlteracao     in ge_usuario.codusuario%type,
                            pnDiasValidadeNCM  in integer,
                            pnInseriuInconsist in out number)
    /*
    Utilizada pra validar uma família em específico, podendo ser chamada no formulário da app por exemplo
    */
    is
    begin
        sp_IniciaProcesso_Fam('L',                   -- psTipoGeracao (L- Lista)
                              TO_CHAR(pnSeqFamilia), -- psListaSeqFamilia (Seq da Família)
                              NULL,                  -- pdDtaBase
                              psUsuAlteracao,        -- psUsuAlteracao
                              pnDiasValidadeNCM,     -- pnDiasValidadeNCM
                              pnInseriuInconsist);   -- pnInseriuInconsist
    end sp_Valida_Fam;
    procedure sp_Inconsist_Fam_100(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number)
    /*
    Inconsistência 100 - Família sem Cód NCM Configurado
    */
    is
    begin
        insert into map_incons_familia
              (seqfamilia,
               seqinconsist,
               motivo,
               dtahorgeracao,
               dtaultalteracao,
               usualteracao,
               tipobloqueio)
        select distinct
               a.seqfamilia,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               a.dtahoralteracao,
               psUsuAlteracao,
               psTipoBloqueio
          from map_familia     a,
               mapx_seqfamilia x
         where x.seqfamilia = a.seqfamilia
           and a.codnbmsh is null;
        pnInseriuInconsist := sql%rowcount;
    exception
        when others then
            raise_application_error(-20200, sqlerrm);
    end sp_Inconsist_Fam_100;
    procedure sp_Inconsist_Fam_101(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number)
    /*
    Inconsistência 101 - Família Sem Tributação Configurada na divisão
    */
    is
    begin
        insert into map_incons_familia
              (seqfamilia,
               seqinconsist,
               motivo,
               dtahorgeracao,
               dtaultalteracao,
               usualteracao,
               tipobloqueio)
        select distinct
               a.seqfamilia,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               a.dtahoralteracao,
               psUsuAlteracao,
               psTipoBloqueio
          from map_famdivisao  a,
               mapx_seqfamilia x
         where x.seqfamilia = a.seqfamilia
           and a.nrotributacao is null;
        pnInseriuInconsist := sql%rowcount;
    exception
        when others then
            raise_application_error(-20200, sqlerrm);
    end sp_Inconsist_Fam_101;
    procedure sp_Inconsist_Fam_102(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number)
    /*
    Inconsistência 102 - CST de Saída de PIS diferente do CST de Saída de COFINS
    */
    is
    begin
        insert into map_incons_familia
              (seqfamilia,
               seqinconsist,
               motivo,
               dtahorgeracao,
               dtaultalteracao,
               usualteracao,
               tipobloqueio)
        select distinct
               a.seqfamilia,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               a.dtahoralteracao,
               psUsuAlteracao,
               psTipoBloqueio
          from map_familia     a,
               mapx_seqfamilia x
         where x.seqfamilia = a.seqfamilia
           and a.situacaonfpissai != a.situacaonfcofinssai;
        pnInseriuInconsist := sql%rowcount;
    exception
        when others then
            raise_application_error(-20200, sqlerrm);
    end sp_Inconsist_Fam_102;
    procedure sp_Inconsist_Fam_103(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number)
    /*
    Inconsistência 103 - CST de Entrada de PIS diferente do CST de Entrada de COFINS
    */
    is
    begin
        insert into map_incons_familia
              (seqfamilia,
               seqinconsist,
               motivo,
               dtahorgeracao,
               dtaultalteracao,
               usualteracao,
               tipobloqueio)
          select distinct
                 a.seqfamilia,
                 pnSeqInconsist,
                 psMotivo,
                 sysdate,
                 a.dtahoralteracao,
                 psUsuAlteracao,
                 psTipoBloqueio
            from map_familia     a,
                 mapx_seqfamilia x
           where x.seqfamilia = a.seqfamilia
             and a.situacaonfpis != a.situacaonfcofins;
        pnInseriuInconsist := sql%rowcount;
    exception
        when others then
            raise_application_error(-20200, sqlerrm);
    end sp_Inconsist_Fam_103;
    procedure sp_Inconsist_Fam_104(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number)
    /*
    Inconsistência 104 - Configuração de CST não configurado na família e na tributação
    */
    is
    begin
        insert into map_incons_familia
              (seqfamilia,
               seqinconsist,
               motivo,
               dtahorgeracao,
               dtaultalteracao,
               usualteracao,
               tipobloqueio)
        select distinct
               a.seqfamilia,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               a.dtahoralteracao,
               psUsuAlteracao,
               psTipoBloqueio
          from map_familia      a,
               map_famdivisao   b,
               map_tributacaouf c,
               mapx_seqfamilia  x
         where x.seqfamilia = a.seqfamilia
           and b.seqfamilia = a.seqfamilia
           and c.nrotributacao = b.nrotributacao
           and (a.situacaonfpis is null and c.situacaonfpis is null)
           and (a.situacaonfcofins is null and
               c.situacaonfcofins is null);
        pnInseriuInconsist := sql%rowcount;
    exception
        when others then
            raise_application_error(-20200, sqlerrm);
    end sp_Inconsist_Fam_104;
    procedure sp_Inconsist_Fam_105(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number)
    /*
    Inconsistência 105 - Famílias com Código CEST não vinculado ao NCM
    */
    is
    begin
        insert into map_incons_familia
              (seqfamilia,
               seqinconsist,
               motivo,
               dtahorgeracao,
               dtaultalteracao,
               usualteracao,
               tipobloqueio)
        select distinct
               a.seqfamilia,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               a.dtahoralteracao,
               psUsuAlteracao,
               psTipoBloqueio
          from map_familia     a,
               map_ncmcest     b,
               mapx_seqfamilia x
         where x.seqfamilia = a.seqfamilia
           and b.codncm = a.codnbmsh
           and b.codcest is null;
        pnInseriuInconsist := sql%rowcount;
    exception
        when others then
            raise_application_error(-20200, sqlerrm);
    end sp_Inconsist_Fam_105;
    procedure sp_Inconsist_Fam_106(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number)
    /*
    Inconsistência 106 - CST de PIS/COFINS sem natureza de Receita informado quando a situação for diferente de 01,49,99
    */
    is
    begin
        insert into map_incons_familia
              (seqfamilia,
               seqinconsist,
               motivo,
               dtahorgeracao,
               dtaultalteracao,
               usualteracao,
               tipobloqueio)
        select distinct
               a.seqfamilia,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               a.dtahoralteracao,
               psUsuAlteracao,
               psTipoBloqueio
          from map_familia     a,
               mapx_seqfamilia x
         where x.seqfamilia = a.seqfamilia
           and (a.codnatrec is null
                and (a.situacaonfpissai not in (01, 49, 99)
                     or a.situacaonfcofinssai not in (01, 49, 99)));
        pnInseriuInconsist := sql%rowcount;
    exception
        when others then
            raise_application_error(-20200, sqlerrm);
    end sp_Inconsist_Fam_106;
    procedure sp_Inconsist_Fam_107(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number)
    /*
    Inconsistência 107 - Famílias com Código CEST inválidos de acordo com a tabela 'map_cest'
    */
    is
    begin
        insert into map_incons_familia
              (seqfamilia,
               seqinconsist,
               motivo,
               dtahorgeracao,
               dtaultalteracao,
               usualteracao,
               tipobloqueio)
        select distinct
               a.seqfamilia,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               a.dtahoralteracao,
               psUsuAlteracao,
               psTipoBloqueio
          from map_familia     a,
               map_cest        b,
               mapx_seqfamilia x
        -- CEST informado na família, mas não existe na tabela 'map_cest'
         where x.seqfamilia = a.seqfamilia
           and a.codcest = b.codcest(+)
           and a.codcest is not null
           and b.codcest is null;
        pnInseriuInconsist := sql%rowcount;
    exception
        when others then
            raise_application_error(-20200, sqlerrm);
    end sp_Inconsist_Fam_107;
    procedure sp_Inconsist_Fam_108(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number)
    /*
    Inconsistência 108 - Famílias de finalidade Revenda sem configuração de Situação Tributária (CST) de Pis e Cofins
    */
    is
    begin
        insert into map_incons_familia
              (seqfamilia,
               seqinconsist,
               motivo,
               dtahorgeracao,
               dtaultalteracao,
               usualteracao,
               tipobloqueio)
        select distinct
               a.seqfamilia,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               a.dtahoralteracao,
               psUsuAlteracao,
               psTipoBloqueio
          from map_familia     a,
               mapx_seqfamilia x
         where x.seqfamilia = a.seqfamilia
           and a.tiporeceita = 1 -- Tipo de Receita: Revenda de Mercadoria
           and a.situacaonfpis is null
           and a.situacaonfpissai is null
           and a.situacaonfcofins is null
           and a.situacaonfcofinssai is null;
        pnInseriuInconsist := sql%rowcount;
    exception
        when others then
            raise_application_error(-20200, sqlerrm);
    end sp_Inconsist_Fam_108;
    procedure sp_Inconsist_Fam_109(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number)
    /*
    Inconsistência 109 - Família com Cód NCM inválido
    */
    is
    begin
        insert into map_incons_familia
              (seqfamilia,
               seqinconsist,
               motivo,
               dtahorgeracao,
               dtaultalteracao,
               usualteracao,
               tipobloqueio)
        select distinct
               a.seqfamilia,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               a.dtahoralteracao,
               psUsuAlteracao,
               psTipoBloqueio
          from map_familia     a,
               mapx_seqfamilia x
         where x.seqfamilia = a.seqfamilia
           and a.codnbmsh is not null
           and a.codnbmsh not in (select c.codncm from map_ncm c); --Verifica tabela de cadastros de NCM
        pnInseriuInconsist := sql%rowcount;
    exception
        when others then
            raise_application_error(-20200, sqlerrm);
    end sp_Inconsist_Fam_109;
    procedure sp_Inconsist_Fam_110(pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number)
    /*
    Inconsistência 110 - NCM da família com data muito antiga (> 180 DIAS)
    */
    is
    begin
        insert into map_incons_familia
              (seqfamilia,
               seqinconsist,
               motivo,
               dtahorgeracao,
               dtaultalteracao,
               usualteracao,
               tipobloqueio)
        select distinct
               a.seqfamilia,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               a.dtahoralteracao,
               psUsuAlteracao,
               psTipoBloqueio
          from map_familia     a,
               map_ncm         b,
               mapx_seqfamilia x
         where x.seqfamilia = a.seqfamilia
           and a.codnbmsh = b.codncm(+)
           and trunc(b.dtaalteracao) < trunc(sysdate) - 50000; --pnDiasValidadeNCM;
        pnInseriuInconsist := sql%rowcount;
    exception
        when others then
            raise_application_error(-20200, sqlerrm);
    end sp_Inconsist_Fam_110;
    procedure sp_IniciaProcesso_Tribut(psTipoGeracao      in varchar2,
                                       psListaCodTribut   in varchar2,
                                       pdDtaBase          in date,
                                       psStatus           in varchar2,
                                       psUsuAlteracao     in ge_usuario.codusuario%type,
                                       pnInseriuInconsist in out integer)
    /*
    Parametros:
    psTipoGeracao = L: lista de codigos
                       utilizando esta opção é obrigatório informar a lista no Parametro psListaCodTribut.
                  = D: data de alteracao, serão gerados todas as tributações alteradas a partir da data informada,
                       utilizando esta opção é obrigatório informar a data base no Parametro pdDtaBase.
                  = T: valida todas as tributações
    psListaCodTribut = quando o parametro psTipoGeracao for informado a opcao L, informar a lista com os codigos
                       neste parametro, podendo ser informado um ou mais codigos, exemplo: 10,20,30.
    pdDtaBase = quando o parametro psTipoGeracao for informado a opcao D, informar neste parametro a data base para
                exportacao dos registros, serao exportado todos os registros com data de alteracao maior ou igual a
                data informada neste parametros
    psStatus = permite filtrar o status das tributações, opções:
               A - verifica somente tributacoes ativas
               I - verifica somente tributacoes inativas
               Null - verifica todas as tributacoes
    psUsuAlteracao = informar o usuario de execução do processo, qdo via job: C5JOB.
    pnInseriuInconsist = se inseriu inconsistencias retorna 1, senao inseriu nada retorna 0
    */
    is
         vsWhere            varchar2(4000);
         vsInsert           varchar2(4000);
         vsSql              varchar2(4000);
         vnInseriuInconsist integer;
         vbInseriu          boolean;
    BEGIN
         -- Faz as validacoes dos parametros do objeto
         if psTipoGeracao = 'L' and psListaCodTribut is null then
             raise_application_error(-20100, 'Para utilizar a opção L no parâmetro psTipoGeracao é necessário informar a lista de tributações no parâmetro psListaCodTribut.' || sqlerrm);
         elsif psTipoGeracao = 'D' and pddtabase is null then
             raise_application_error(-20100, 'Para utilizar a opção D no parâmetro psTipoGeracao é necessário informar a data base no parâmetro pdDtaBase.' || sqlerrm);
         elsif psTipoGeracao not in ('D', 'L', 'T') then
             raise_application_error(-20100, 'O valor informado no parâmetro psTipoGeracao está incorreto. Informe L, D ou T.' || sqlerrm);
         end if;
         execute immediate 'truncate table mapx_codtribut';
         -- Monta o where do insert da tabela temporária
         if psTipoGeracao = 'L' then
            vsWhere := ' where a.nrotributacao in (select column_value from table(cast(c5_complexin.c5intable(' || chr(39) || psListaCodTribut || chr(39) || ') as c5instrtable))) ';
         elsif psTipoGeracao = 'D' then
            vsWhere := ' where exists (select 1 from map_tributacaouf b where b.nrotributacao = a.nrotributacao and b.dtaalteracao >= ' || 'to_date(' || chr(39) || to_char(pdDtaBase) || chr(39) || ')) ';
         elsif psTipoGeracao = 'T' then
            vsWhere := ' where 1 = 1 ';
         end if;
         -- Status
         if psStatus = 'A' then
            vsWhere := vsWhere || ' and a.status =  ' || chr(39) || 'A' || chr(39);
         elsif psStatus = 'I' then
            vsWhere := vsWhere || ' and a.status =  ' || chr(39) || 'I' || chr(39);
         end if;
         vsInsert := 'insert into mapx_codtribut(nrotributacao)
                                          select a.nrotributacao
                                            from map_tributacao a ';
         execute immediate vsInsert || vsWhere;
         -- Remove as inconsistências anteriores das tributações que serão re-avaliadas
         execute immediate 'delete map_incons_tribut a
                             where exists (select 1
                                             from mapx_codtribut b
                                            where a.nrotributacao = b.nrotributacao)';
         vbInseriu := FALSE;
         -- Após inserir as tributações na tabela temporária, roda as procedures de inconsistência
         for vtObj in (select a.*
                         from map_cadinconsistenc a
                        where a.origem = 'TRIBUTACAO'
                          and a.status = 'A')
         loop
             vsSql := 'BEGIN
                           PKG_INCONSISTENCIAS.' || vtObj.User_Procedure || '(:pnSeqInconsist, :psMotivo, :psUsuAlteracao, :psTipoBloqueio, :pnInseriuInconsist);
                       END;';
             execute immediate vsSql
                         using vtObj.Seqinconsist,
                               vtObj.Desccompleta,
                               psUsuAlteracao,
                               vtObj.Tipobloqueio,
                        in out vnInseriuInconsist;
             If vnInseriuInconsist > 0 then
                 vbInseriu := TRUE;
             end if;
         end loop;
         -- Retorna o indicador informando se inseriu inconsistência
         If vbInseriu then
            pnInseriuInconsist := 1;
         else
            pnInseriuInconsist := 0;
         end if;
    end sp_IniciaProcesso_Tribut;
    procedure sp_Valida_Tribut(pnNroTributacao    in map_tributacao.nrotributacao%type,
                               psUsuAlteracao     in ge_usuario.codusuario%type,
                               pnInseriuInconsist in out number)
    /*
    Utilizada pra validar uma tributação em específico, podendo ser chamada no formulário da app por exemplo
    */
    is
    begin
        sp_IniciaProcesso_Tribut('L',                      -- psTipoGeracao
                                 to_char(pnNroTributacao), -- psListaCodTribut,
                                 null,                     -- pdDtaBase
                                 null,                     -- psStatus
                                 psUsuAlteracao,           -- psUsuAlteracao
                                 pnInseriuInconsist);      -- pnInseriuInconsist
    end sp_Valida_Tribut;
    procedure sp_Inconsist_Tribut_600(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
    begin
        /*
        CST 00 ¿ Nacional Tributado: Só permitido quando 100% de Tributado ICMS, sem configurações de ICMS ST
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               psUsuAlteracao,
               a.dtaalteracao,
               psTipoBloqueio
          from map_tributacaouf     a,
               mapx_codtribut       x,
               map_regimetributacao b
         where a.nrotributacao = x.nrotributacao
           and a.nroregtributacao = b.nroregtributacao
           and nvl(b.indsimplesnac, 'N') = 'N'
           and a.situacaonf = '000'
           and a.pertributado != 100
           and a.peraliquotast != 0;
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_600;
    procedure sp_Inconsist_Tribut_601(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number) is
    begin
        /*
        CST 10 ¿ Substituição Tributária: Inconsistente se não informar Acréscimo de ST e Alíquota de ST;
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               psUsuAlteracao,
               a.dtaalteracao,
               psTipoBloqueio
          from map_tributacaouf     a,
               mapx_codtribut       x,
               map_regimetributacao b
         where a.nrotributacao = x.nrotributacao
           and a.nroregtributacao = b.nroregtributacao
           and nvl(b.indsimplesnac, 'N') = 'N'
           and a.situacaonf = '010'
           and a.peraliquotast = 0
           and a.peracrescst = 0;
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_601;
    procedure sp_Inconsist_Tribut_602(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
    begin
        /*
        CST 20 ¿ Redução Base de Cálculo: Somente para redução da Base de ICMS. Tributado
        ICMS deve ser menor que 100 e sem configurações de ICMS ST;
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               psUsuAlteracao,
               a.dtaalteracao,
               psTipoBloqueio
          from map_tributacaouf     a,
               mapx_codtribut       x,
               map_regimetributacao b
         where a.nrotributacao = x.nrotributacao
           and a.nroregtributacao = b.nroregtributacao
           and nvl(b.indsimplesnac, 'N') = 'N'
           and a.situacaonf = '020'
           and a.pertributado = 100
           and a.peraliquotast = 0;
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_602;
    procedure sp_Inconsist_Tribut_603(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number) is
    begin
        /*
        CST 30 ¿ Isento ou Não Tributado com ICMS ST: Somente para informação de Percentual
        Isento, com configurações de ICMS ST;
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               psUsuAlteracao,
               a.dtaalteracao,
               psTipoBloqueio
          from map_tributacaouf     a,
               mapx_codtribut       x,
               map_regimetributacao b
         where a.nrotributacao = x.nrotributacao
           and a.nroregtributacao = b.nroregtributacao
           and nvl(b.indsimplesnac, 'N') = 'N'
           and a.situacaonf = '030'
           and not exists (select *
                             from map_tributacaouf aa
                            where aa.situacaonf = '030'
                              and aa.peraliquotast != 0
                              and (aa.perisento = 100 or aa.peroutro = 100)
                              and aa.nrotributacao = a.nrotributacao
                              and aa.ufclientefornec = a.ufclientefornec
                              and aa.nroregtributacao = a.nroregtributacao
                              and aa.tiptributacao = tiptributacao
                              and aa.ufempresa = a.ufempresa);
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_603;
    procedure sp_Inconsist_Tribut_604(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
    begin
        /*
        CST 40 ¿ Isento ou Não Tributado: Somente 100% em Percentual Isento;
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               psUsuAlteracao,
               a.dtaalteracao,
               psTipoBloqueio
          from map_tributacaouf     a,
               mapx_codtribut       x,
               map_regimetributacao b
         where a.nrotributacao = x.nrotributacao
           and a.nroregtributacao = b.nroregtributacao
           and nvl(b.indsimplesnac, 'N') = 'N'
           and a.situacaonf = '040'
           and a.perisento != 100;
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_604;
    procedure sp_Inconsist_Tribut_605(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
    begin
        /*
        CST 41 ¿ Não Tributado: Somente 100% em Percentual Isento ou em Percentual Outros;
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               psUsuAlteracao,
               a.dtaalteracao,
               psTipoBloqueio
          from map_tributacaouf     a,
               mapx_codtribut       x,
               map_regimetributacao b
         where a.nrotributacao = x.nrotributacao
           and a.nroregtributacao = b.nroregtributacao
           and nvl(b.indsimplesnac, 'N') = 'N'
           and a.situacaonf = '041'
           and a.perisento != 100
           and a.peroutro != 100;
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_605;
    procedure sp_Inconsist_Tribut_606(
                pnSeqInconsist         in       map_incons_tribut.seqinconsist%type,
                psMotivo               in       map_incons_tribut.motivo%type,
                psUsuAlteracao         in       ge_usuario.codusuario%type,
                psTipoBloqueio         in       map_incons_tribut.tipobloqueio%type,
                pnInseriuInconsist     in out   number)
    is
    begin
         /*
         CST 50 ¿ Suspensão: Somente 100% em Percentual Isento ou em Percentual Outros;
         */
         insert into map_incons_tribut
               (nrotributacao,
                ufclientefornec,
                nroregtributacao,
                tiptributacao,
                ufempresa,
                seqinconsist,
                motivo,
                dtahorgeracao,
                usualteracao,
                dtaultalteracao,
                tipobloqueio)
         select a.nrotributacao,
                a.ufclientefornec,
                a.nroregtributacao,
                a.tiptributacao,
                a.ufempresa,
                pnSeqInconsist,
                psMotivo,
                sysdate,
                psUsuAlteracao,
                a.dtaalteracao,
                psTipoBloqueio
           from map_tributacaouf     a,
                mapx_codtribut       x,
                map_regimetributacao b
          where a.nrotributacao = x.nrotributacao
            and a.nroregtributacao = b.nroregtributacao
            and nvl(b.indsimplesnac, 'N') = 'N'
            and a.situacaonf = '050'
            and a.perisento != 100
            and a.peroutro != 100;
         pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_606;
    procedure sp_Inconsist_Tribut_607(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
    begin
        /*
        CST 51 ¿ Diferimento: Somente se houver configurações de Percentual ICMS Diferido;
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               psUsuAlteracao,
               a.dtaalteracao,
               psTipoBloqueio
          from map_tributacaouf     a,
               mapx_codtribut       x,
               map_regimetributacao b
         where a.nrotributacao = x.nrotributacao
           and a.nroregtributacao = b.nroregtributacao
           and nvl(b.indsimplesnac, 'N') = 'N'
           and a.situacaonf = '051'
           and ((a.ufempresa != 'RJ' and nvl(a.peraliqicmsdif, 0) = 0) or
                (a.ufempresa  = 'RJ' and nvl(a.perdiferido, 0) = 0)
               );
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_607;
    procedure sp_Inconsist_Tribut_608(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
    begin
        /*
        CST 60 ¿ ICMS Cobrado Anteriormente Por ST: Não permitido 100% Tributado, sem
        configurações de ICMS ST. Deve ter configurações de ICMS ST ou 100% em Percentual
        Outros;
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               psUsuAlteracao,
               a.dtaalteracao,
               psTipoBloqueio
          from map_tributacaouf     a,
               mapx_codtribut       x,
               map_regimetributacao b
         where a.nrotributacao = x.nrotributacao
           and a.nroregtributacao = b.nroregtributacao
           and nvl(b.indsimplesnac, 'N') = 'N'
           and a.situacaonf = '060'
           and not exists (select 1
                             from map_tributacaouf aa
                            where aa.nrotributacao = a.nrotributacao
                              and aa.ufclientefornec = a.ufclientefornec
                              and aa.nroregtributacao = a.nroregtributacao
                              and aa.tiptributacao = a.tiptributacao
                              and aa.ufempresa = a.ufempresa
                              and aa.situacaonf = '060'
                              and (aa.peroutro = 100 or nvl(aa.peraliquotast, 0) > 0));
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_608;
    procedure sp_Inconsist_Tribut_609(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
    begin
        /*
        CST 70 ¿ Com Redução da Base de Cálculo e Cobrança de ICMS ST: Somente para redução
        da Base de ICMS e incidência de ICMS ST. Tributado ICMS deve ser menor que 100 e com
        configurações de ICMS ST;
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               psUsuAlteracao,
               a.dtaalteracao,
               psTipoBloqueio
          from map_tributacaouf     a,
               mapx_codtribut       x,
               map_regimetributacao b
         where a.nrotributacao = x.nrotributacao
           and a.nroregtributacao = b.nroregtributacao
           and nvl(b.indsimplesnac, 'N') = 'N'
           and a.situacaonf = '070'
           and a.pertributado = 100
           and a.peraliquotast > 0;
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_609;
    procedure sp_Inconsist_Tribut_610(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number) is
    begin
        /*
        CST 90 ¿ Somente 100% em Percentual Outros.
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               psUsuAlteracao,
               a.dtaalteracao,
               psTipoBloqueio
          from map_tributacaouf     a,
               mapx_codtribut       x,
               map_regimetributacao b
         where a.nrotributacao = x.nrotributacao
           and a.nroregtributacao = b.nroregtributacao
           and nvl(b.indsimplesnac, 'N') = 'N'
           and a.situacaonf = '090'
           and a.peroutro != 100
           and a.pertributado != 100
           and a.pertributado + a.perisento != 100
        minus
        select A.NROTRIBUTACAO, A.UFCLIENTEFORNEC, A.NROREGTRIBUTACAO,
               A.TIPTRIBUTACAO, A.UFEMPRESA, pnSeqInconsist, psMotivo,
               sysdate, psUsuAlteracao, A.DTAALTERACAO, psTipoBloqueio
        from   MAP_TRIBUTACAOUF A, MAPX_CODTRIBUT X, MAP_REGIMETRIBUTACAO B
        where  A.NROTRIBUTACAO = X.NROTRIBUTACAO
        and    A.NROREGTRIBUTACAO = B.NROREGTRIBUTACAO
        and    nvl(B.INDSIMPLESNAC, 'N') = 'N'
        and    A.SITUACAONF = '090'
        and    A.PEROUTRO != 100
        and    A.PERTRIBUTADO != 100
        and    A.PERTRIBUTADO + A.PERISENTO != 100
        and    A.UFEMPRESA = 'CE'
        and    A.TIPTRIBUTACAO in ('SN', 'SC');
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_610;
    procedure sp_Inconsist_Tribut_611(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number) is
    begin
        /*
        Se a última posição do CST de ICMS é diferente de 0 ou 1.
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               psUsuAlteracao,
               a.dtaalteracao,
               psTipoBloqueio
          from map_tributacaouf     a,
               mapx_codtribut       x,
               map_regimetributacao b
         where a.nrotributacao = x.nrotributacao
           and a.nroregtributacao = b.nroregtributacao
           and nvl(b.indsimplesnac, 'N') = 'N'
           and substr(a.situacaonf, length(a.situacaonf), 1) not in ('0', '1');
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_611;
    procedure sp_Inconsist_Tribut_612(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
    begin
        /*
        Críticas para FCP:
        Informações para cálculo de FCP ICMS, sem existir Percentual Tributado ICMS;
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               psUsuAlteracao,
               a.dtaalteracao,
               psTipoBloqueio
          from map_tributacaouf a,
               mapx_codtribut   x
         where a.nrotributacao = x.nrotributacao
           and a.peraliqfcpicms is not null
           and a.pertributado = 0
           and a.tiptributacao not in ('EM', 'SM');
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_612;
    procedure sp_Inconsist_Tribut_613(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
    begin
        /*
        Críticas para FCP:
        Informações para cálculo de FCP ST, sem existir configurações para cálculo de ICMS ST.
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               psMotivo,
               sysdate,
               psUsuAlteracao,
               a.dtaalteracao,
               psTipoBloqueio
          from map_tributacaouf a,
               mapx_codtribut   x
         where a.nrotributacao = x.nrotributacao
           and a.peraliqfcpst is not null
           and a.peraliquotast = 0;
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_613;
    procedure sp_Inconsist_Tribut_614(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
    begin
        /*
        Verifica se tem alguma tributação que não está associada a nenhum CGO
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               'TD',
               0,
               'TD',
               'TD',
               pnSeqInconsist,
               psMotivo,
               sysdate,
               psUsuAlteracao,
               max(a.dtaalteracao),
               psTipoBloqueio
          from map_tributacaouf a,
               mapx_codtribut   x
         where a.nrotributacao = x.nrotributacao
           and not exists (select 1
                             from max_codgeralcfopuf b
                            where b.nrotributacao = a.nrotributacao
                            union all
                           select 1
                             from max_codgeralcfop c
                            where c.nrotributacao = a.nrotributacao)
         group by a.nrotributacao;
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_614;
    procedure sp_Inconsist_Tribut_615(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
    begin
        /*
        Verifica se todos os CGOs que devem ser consistidos se possuem tributacao associada
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select 0,
               'TD',
               0,
               'TD',
               'TD',
               pnSeqInconsist,
               replace(replace(psMotivo, '#CGO', upper(to_char(a.cgo) || '-' || b.descricao)), '#PROCESSO', upper(a.descricao)),
               sysdate,
               psUsuAlteracao,
               null,
               psTipoBloqueio
          from mapv_cgosverificacaotribut a,
               max_codgeraloper           b
         where a.cgo = b.codgeraloper
           and not exists (select 1
                             from max_codgeralcfopuf b
                            where b.codgeraloper = a.cgo
                            union all
                           select 1
                             from max_codgeralcfop c
                            where c.codgeraloper = a.cgo);
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_615;
    procedure sp_Inconsist_Tribut_616(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
    begin
        /*
        Se não carregou a temporária, chama o objeto que carrega,
        A chamada desse objeto foi colocada aqui pois se não tiver nenhum registro ativo
        para estas consistências não popula a temporária sem necessidade
        */
/*        vnPossuiTempPopulada := fc_VerifTempCFOP_Tribut;
        if vnPossuiTempPopulada = 0
        then
            sp_GeraDadosCFOP_Tribut;
        end if;*/
        sp_GeraDadosCFOP_Tribut;
        /*
        Grupo do CFOP é de Substituição Tributária: Permitido apenas para tributações que
        tenham configurações para cálculo de ICMS ST, ou Tributação em Outros com CST 60.
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               replace(replace(psMotivo, '#CGO', a.codgeraloper), '#CFOP', case when a.ufclientefornec = a.ufempresa then
                                                                             a.cfopestado
                                                                           else
                                                                             a.cfopforaestado
                                                                           end),
               sysdate,
               psUsuAlteracao,
               a.dtaultalteracao,
               psTipoBloqueio
          from mapx_dadoscfop_tribut a,
               mapx_codtribut        x,
               ge_cfop               b,
               max_codgeraloper      c
         where a.nrotributacao = x.nrotributacao
           and ((a.cfopestado = b.cfop and a.ufclientefornec = a.ufempresa) or
                (a.cfopforaestado = b.cfop and a.ufclientefornec != a.ufempresa))
           and a.codgeraloper = c.codgeraloper
           and c.tipcgo = 'S'
           and c.tipdocfiscal = 'C'
           and b.grupocfop = 7
           and not exists (select 1
                             from mapx_dadoscfop_tribut z
                            where z.nrotributacao = a.nrotributacao
                              and z.ufclientefornec = a.ufclientefornec
                              and z.nroregtributacao = a.nroregtributacao
                              and z.tiptributacao = a.tiptributacao
                              and z.ufempresa = a.ufempresa
                              and (nvl(z.peracrescst, 0) > 0 or (z.peroutro = 100 and z.situacaonf = '060')));
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_616;
    PROCEDURE sp_Inconsist_Tribut_617(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
    begin
        /*
        Se não carregou a temporária, chama o objeto que carrega,
        A chamada desse objeto foi colocada aqui pois se não tiver nenhum registro ativo
        para estas consistências não popula a temporária sem necessidade
        */
/*        vnPossuiTempPopulada := fc_VerifTempCFOP_Tribut;
        if vnPossuiTempPopulada = 0
        then
            sp_GeraDadosCFOP_Tribut;
        end if;*/
        sp_GeraDadosCFOP_Tribut;
        /*
        Grupo do CFOP Não é de Substituição Tributária: Permitido para demais tributações, sem
        configuração de ICMS ST, e CST diferente de 60.
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               replace(replace(psMotivo, '#CGO', a.codgeraloper), '#CFOP', case when a.ufclientefornec = a.ufempresa then
                                                                             a.cfopestado
                                                                           else
                                                                             a.cfopforaestado
                                                                           end),
               sysdate,
               psUsuAlteracao,
               a.dtaultalteracao,
               psTipoBloqueio
          from mapx_dadoscfop_tribut a,
               mapx_codtribut        x,
               ge_cfop               b,
               max_codgeraloper      c
         where a.nrotributacao = x.nrotributacao
           and ((a.cfopestado = b.cfop and a.ufclientefornec = a.ufempresa) or
                (a.cfopforaestado = b.cfop and a.ufclientefornec != a.ufempresa))
           and a.codgeraloper = c.codgeraloper
           and c.tipcgo = 'S'
           and c.tipdocfiscal = 'C'
           and b.grupocfop != 7
           and (nvl(a.peracrescst, 0) > 0 or
               (a.peroutro = 100 and a.situacaonf = '060'));
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_617;
    procedure sp_Inconsist_Tribut_618(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
    begin
        /*
        Se não carregou a temporária, chama o objeto que carrega,
        A chamada desse objeto foi colocada aqui pois se não tiver nenhum registro ativo
        para estas consistências não popula a temporária sem necessidade
        */
        /*vnPossuiTempPopulada := fc_VerifTempCFOP_Tribut;
        if vnPossuiTempPopulada = 0
        then
            sp_GeraDadosCFOP_Tribut;
        end if;*/
        sp_GeraDadosCFOP_Tribut;
        /*
        Grupo de CFOP para Combustíveis: Verificar se existem produtos vinculados à tributação,
        sem o código ANP informado no cadastro. Baseado na Rejeição 660: ¿CFOP de
        Combustível e não informado grupo de combustível da NF-e¿. Regra: ¿Obrigatória a
        informação do grupo de combustível para os CFOPs: 1.651, 1.652, 1.653, 1.658, 1.659,
        1.660, 1.661, 1.662, 1.663, 1.664, 2.651, 2.652, 2.653, 2.658, 2.659, 2.660, 2.661,
        2.662, 2.663, 2.664, 3.651, 3.652, 3.653, 5.651, 5.652, 5.653, 5.654, 5.655, 5.656,
        5.657, 5.658, 5.659, 5.660, 5.661, 5.662, 5.663, 5.664, 5.665, 5.666, 5.667, 6.651,
        6.652, 6.653, 6.654, 6.655, 6.656, 6.657, 6.658, 6.659, 6.660, 6.661, 6.662, 6.663,
        6.664, 6.665, 6.666, 6.667, 7.651, 7.654, 7.667. (NT 2012.003)¿
        */
        insert into map_incons_tribut
              (nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               seqinconsist,
               motivo,
               dtahorgeracao,
               usualteracao,
               dtaultalteracao,
               tipobloqueio)
        select a.nrotributacao,
               a.ufclientefornec,
               a.nroregtributacao,
               a.tiptributacao,
               a.ufempresa,
               pnSeqInconsist,
               replace(replace(psMotivo, '#CGO', a.codgeraloper), '#CFOP', case when a.ufclientefornec = a.ufempresa then
                                                                             a.cfopestado
                                                                           else
                                                                             a.cfopforaestado
                                                                           end),
               sysdate,
               psUsuAlteracao,
               a.dtaultalteracao,
               psTipoBloqueio
          from mapx_dadoscfop_tribut a,
               mapx_codtribut        x,
               ge_cfop               b
         where a.nrotributacao = x.nrotributacao
           and ((a.cfopestado = b.cfop and a.ufclientefornec = a.ufempresa) or
                (a.cfopforaestado = b.cfop and a.ufclientefornec != a.ufempresa))
           and b.cfop in (1651, 1652, 1653, 1658, 1659, 1660, 1661, 1662, 1663, 1664,
                          2651, 2652, 2653, 2658, 2659, 2660, 2661, 2662, 2663, 2664,
                          3651, 3652, 3653, 5651, 5652, 5653, 5654, 5655, 5656, 5657,
                          5658, 5659, 5660, 5661, 5662, 5663, 5664, 5665, 5666, 5667,
                          6651, 6652, 6653, 6654, 6655, 6656, 6657, 6658, 6659, 6660,
                          6661, 6662, 6663, 6664, 6665, 6666, 6667, 7651, 7654, 7667)
           and exists (select 1
                         from map_famdivisao c,
                              map_produto    d
                        where c.seqfamilia = d.seqfamilia
                          and c.nrotributacao = a.nrotributacao
                          and d.codigoanp is null);
        pnInseriuInconsist := sql%rowcount;
    end sp_Inconsist_Tribut_618;
    PROCEDURE sp_Inconsist_Tribut_619(pnSeqInconsist     in map_incons_tribut.seqinconsist%type,
                                      psMotivo           in map_incons_tribut.motivo%type,
                                      psUsuAlteracao     in ge_usuario.codusuario%type,
                                      psTipoBloqueio     in map_incons_tribut.tipobloqueio%type,
                                      pnInseriuInconsist in out number)
    is
        vsPDVerifAliqEfetivoCadFam    max_parametro.valor%type;
    begin
        /*
        CST 60 ICMS Cobrado Anteriormente Por ST: Não existe alíquiota de efetivo cadastrada para a UF do RS
        na família.
        */
        SP_BUSCAPARAMDINAMICO('TRIBUTACAO_UF', 0, 'VERIF_ALIQ_EFETIVO_CAD_FAM', 'S', 'N',
        'VERIFICA ALÍQUOTA DE EFETIVO NO CADASTRO DA FAMÍLIA PARA PROCESSO DO RIO GRANDE DO SUL?' || chr(13) || chr(10) ||
        'S-SIM' || chr(13) || chr(10) ||
        'N-NÃO(VALOR PADRÃO)', vsPDVerifAliqEfetivoCadFam);
        If vsPDVerifAliqEfetivoCadFam = 'S' Then
           insert into map_incons_tribut
                 (nrotributacao,
                  ufclientefornec,
                  nroregtributacao,
                  tiptributacao,
                  ufempresa,
                  seqinconsist,
                  motivo,
                  dtahorgeracao,
                  usualteracao,
                  dtaultalteracao,
                  tipobloqueio)
           select a.nrotributacao,
                  a.ufclientefornec,
                  a.nroregtributacao,
                  a.tiptributacao,
                  a.ufempresa,
                  pnSeqInconsist,
                  REPLACE(psMotivo, '#FAMILIA', f.seqfamilia),
                  sysdate,
                  psUsuAlteracao,
                  a.dtaalteracao,
                  psTipoBloqueio
             from map_tributacaouf     a,
                  mapx_codtribut       x,
                  map_regimetributacao b,
                  map_famdivisao f
            where a.nrotributacao    = x.nrotributacao
              and a.nroregtributacao = b.nroregtributacao
              and f.nrotributacao    = x.nrotributacao
              and nvl(b.indsimplesnac, 'N')  = 'N'
              and a.ufempresa        = 'RS'
              and a.tiptributacao    = 'SN'
              and a.ufclientefornec  = 'RS'
              and SUBSTR(a.situacaonf, 2, 2) = '60'
              and not exists(select 1
                               from map_famaliqpadraouf uf
                              where f.seqfamilia = uf.seqfamilia
                                and a.ufempresa  = uf.uf
                                and nvl(uf.aliqpadraoicms, 0) > 0)
            group by f.seqfamilia,
                     a.nrotributacao,
                     a.ufclientefornec,
                     a.nroregtributacao,
                     a.tiptributacao,
                     a.ufempresa,
                     a.dtaalteracao
            order by f.seqfamilia;
           pnInseriuInconsist := sql%rowcount;
        End If;
    end sp_Inconsist_Tribut_619;
procedure sp_GeraDadosCFOP_Tribut
    is
        vsSql varchar2(4000);
    begin
        -- Limpa a tabela temporária
        vsSql := 'truncate table mapx_DADOSCFOP_TRIBUT';
        execute immediate vsSql;
        -- Insere dados tabela temporária
        insert into mapx_dadoscfop_tribut
              (cfopestado,
               cfopforaestado,
               codgeraloper,
               nrotributacao,
               ufclientefornec,
               nroregtributacao,
               tiptributacao,
               ufempresa,
               peracrescst,
               peroutro,
               situacaonf,
               dtaultalteracao)
        select nvl(a.cfopestado, nvl(e.cfopestado, d.cfopestado)) cfopestado,
               nvl(a.cfopforaestado, nvl(e.cfopforaestado, d.cfopforaestado)) cfopforaestado,
               d.codgeraloper,
               b.nrotributacao,
               b.ufclientefornec,
               b.nroregtributacao,
               b.tiptributacao,
               b.ufempresa,
               b.peracrescst,
               b.peroutro,
               b.situacaonf,
               b.dtaalteracao
          from max_codgeralcfopuf a,
               map_tributacaouf   b,
               mapx_codtribut     x,
               ge_cfop            c,
               max_codgeraloper   d,
               max_codgeralcfop   e
         where a.nrotributacao = b.nrotributacao
           and a.ufempresa = b.ufempresa
           and a.uf = b.ufclientefornec
           and a.nroregtributacao = b.nroregtributacao
           and a.codgeraloper = d.codgeraloper
           and d.codgeraloper = e.codgeraloper
           and a.nrotributacao = e.nrotributacao
           and a.indcontribicms = e.indcontribicms
           and ((nvl(a.cfopestado, d.cfopestado) = c.cfop and b.ufclientefornec = b.ufempresa) or
                (nvl(a.cfopforaestado, d.cfopforaestado) = c.cfop and b.ufclientefornec != b.ufempresa))
           and a.nrotributacao = x.nrotributacao
           and decode(a.indcontribicms, 'S', 'SC', 'SN') = b.tiptributacao
           and a.status = 'A'
         union all
        select nvl(e.cfopestado, d.cfopestado),
               nvl(e.cfopforaestado, d.cfopforaestado),
               d.codgeraloper,
               b.nrotributacao,
               b.ufclientefornec,
               b.nroregtributacao,
               b.tiptributacao,
               b.ufempresa,
               b.peracrescst,
               b.peroutro,
               b.situacaonf,
               b.dtaalteracao
          from map_tributacaouf b,
               mapx_codtribut   x,
               ge_cfop          c,
               max_codgeraloper d,
               max_codgeralcfop e
         where e.nrotributacao = b.nrotributacao
           and e.codgeraloper = d.codgeraloper
           and d.codgeraloper = e.codgeraloper
           and ((nvl(e.cfopestado, d.cfopestado) = c.cfop and b.ufclientefornec = b.ufempresa) or
                (nvl(e.cfopforaestado, d.cfopforaestado) = c.cfop and b.ufclientefornec != b.ufempresa))
           and e.nrotributacao = x.nrotributacao
           and decode(e.indcontribicms, 'S', 'SC', 'SN') = b.tiptributacao
           and not exists (select 1
                             from max_codgeralcfopuf a
                            where a.nrotributacao = b.nrotributacao
                              and a.ufempresa = b.ufempresa
                              and decode(a.uf, 'ZZ', b.ufclientefornec, a.uf) = b.ufclientefornec
                              and decode(a.nroregtributacao, null, b.nroregtributacao, a.nroregtributacao)  = b.nroregtributacao
                              and a.nrotributacao = e.nrotributacao
                              and a.indcontribicms = e.indcontribicms
                              and a.codgeraloper = d.codgeraloper)
         group by nvl(e.cfopestado, d.cfopestado),
                  nvl(e.cfopforaestado, d.cfopforaestado),
                  d.codgeraloper,
                  b.nrotributacao,
                  b.ufclientefornec,
                  b.nroregtributacao,
                  b.tiptributacao,
                  b.ufempresa,
                  b.peracrescst,
                  b.peroutro,
                  b.situacaonf,
                  b.dtaalteracao;
    end sp_GeraDadosCFOP_Tribut;
    function fc_VerifTempCFOP_Tribut return integer
    is
        vnCount integer;
    begin
        select count(1)
          into vnCount
          from mapx_dadoscfop_tribut;
        return vnCount;
    end fc_VerifTempCFOP_Tribut;
    
    /* Customizações Nagumo */
   -- Ticket 522719
   -- Validações de CFOP + CGO + Tributação
    /* Primeira Regra
   CST 060 e existe CFOP */
    /* Segunda Regra
   CST diferente de 060 e CFOP nao existe ou diferente*/
   
    PROCEDURE NAGP_INC_FAM_01     (pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number) AS
   
  BEGIN
        INSERT INTO MAP_INCONS_FAMILIA
              (SEQFAMILIA,
               SEQINCONSIST,
               MOTIVO,
               DTAHORGERACAO,
               DTAULTALTERACAO,
               USUALTERACAO,
               TIPOBLOQUEIO)
        SELECT DISTINCT
               A.SEQFAMILIA,
               PNSEQINCONSIST,
               v.MSG,
               SYSDATE,
               A.DTAHORALTERACAO,
               PSUSUALTERACAO,
               PSTIPOBLOQUEIO
          FROM MAP_FAMILIA     A INNER JOIN MAPX_SEQFAMILIA X ON X.SEQFAMILIA = A.SEQFAMILIA
                                 INNER JOIN NAGV_VALIDCFOPCGOTRIB_CADFAM V ON V.SEQFAMILIA = A.SEQFAMILIA;
                                 
        PNINSERIUINCONSIST := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20200, SQLERRM);
      
  END NAGP_INC_FAM_01;
                                   
  PROCEDURE NAGP_INC_FAM_02       (pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number) AS
   
  BEGIN
        INSERT INTO MAP_INCONS_FAMILIA
              (SEQFAMILIA,
               SEQINCONSIST,
               MOTIVO,
               DTAHORGERACAO,
               DTAULTALTERACAO,
               USUALTERACAO,
               TIPOBLOQUEIO)
        SELECT DISTINCT
               A.SEQFAMILIA,
               PNSEQINCONSIST,
               PSMOTIVO,
               SYSDATE,
               A.DTAHORALTERACAO,
               PSUSUALTERACAO,
               PSTIPOBLOQUEIO
          FROM MAP_FAMILIA     A,
               MAPX_SEQFAMILIA X
         WHERE X.SEQFAMILIA = A.SEQFAMILIA
           AND A.SEQFAMILIA = 123456789;
        PNINSERIUINCONSIST := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20200, SQLERRM);
      
   END NAGP_INC_FAM_02;
    
end PKG_INCONSISTENCIAS;
/
