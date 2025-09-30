CREATE OR REPLACE VIEW NAGV_TAE_ACORDOS_V2 AS
SELECT X.NROACORDO NRO_ACORDO,
        X.NROEMPRESA NRO_EMPRESA,
        X.SEQFORNECEDOR COD_FORNECEDOR,
        Z.NOMERAZAO FORNECEDOR,
        X.DTAEMISSAO DATA_EMISSAO,
        X.VLRACORDO VLR_ACORDO,
        X.NROPEDIDOSUPRIM NRO_PEDIDO,
        X.SEQCOMPRADOR COD_COMPRADOR,
        C.COMPRADOR COMPRADOR,
        X.SEQPROCESSO PROCESSO,
        X.SEQENVELOPE SEQ_ENVELOPE,
        NVL(( SELECT CASE Z.STATUS WHEN 1 THEN 'Aguardando upload do envelope'
                                   WHEN 2  THEN 'Aguardando publicação do envelope'
                                   WHEN 3 THEN 'Aguardando assinatura do envelope'
                                   WHEN 4 THEN 'Envelope finalizado'
                                   WHEN 5 THEN 'Envelope rejeitado'
                                   WHEN 6 THEN 'Envelope cancelado'  END FROM TAE_ENVELOPE Z WHERE X.SEQENVELOPE = Z.SEQENVELOPE),'Fornecedor sem e-mail cadastrado.') STATUS,
        NVL(D.EMAIL,X.EMAIL) EMAIL,
        X.DTAVENCIMENTO VENCIMENTO, A.DESCRICAO TIPO_ACORDO,
        X.USUINCLUSAO USUARIO_INCLUSAO,
        U.NOME NOME_INCLUSAO,
        CASE WHEN NVL(D.EMAIL,X.EMAIL) IS NULL THEN NULL ELSE 'https://totvssign.totvs.app/webapptotvssign/documents/'||e.Iddocumento END URL_ACO,
        CASE WHEN NVL(D.EMAIL,X.EMAIL) IS NULL THEN NULL ELSE
          'https://api.whatsapp.com/send?text=Olá%2C%20te%20enviei%20um%20documento%20publicado%20por%20assinaturaeletronica%40nagumo.com.br%20para%20Assinar%20no%20TOTVS%20Assinatura%20Eletrônica%2C%20segue%20o%20link%3A%20https%3A%2F%2Ftotvssign.totvs.app%2Fwebapptotvssign%2F%23%2Fdocuments%2F'||e.Iddocumento END URL_WTS

   FROM MSU_ACORDOPROMOC X INNER JOIN GE_PESSOA Z ON (Z.SEQPESSOA = X.SEQFORNECEDOR)
                           INNER JOIN MAX_COMPRADOR C ON (C.SEQCOMPRADOR = X.SEQCOMPRADOR)
                           INNER JOIN MAC_TIPOACORDO A ON A.CODTIPOACORDO = X.CODTIPOACORDO
                           INNER JOIN GE_USUARIO U ON (U.CODUSUARIO = X.USUINCLUSAO)
                            LEFT JOIN TAE_ENVELOPE E ON E.SEQENVELOPE = X.SEQENVELOPE
                            LEFT JOIN TAE_ENVELOPEDESTINATARIO D ON D. SEQENVELOPE = E.SEQENVELOPE

  WHERE X.INDENVIAAUTOASSELETRONICA IN ('S','P')
    AND (X.SITUACAOACORDO != 'C' OR SITUACAOACORDO = 'C' AND X.SEQENVELOPE IS NOT NULL)
    AND C.COMPRADOR NOT IN ('CIPOLLA','CONSINCO')
    AND X.NROACORDO NOT IN (624985, 624978) -- Exc Solic Falconi
    AND X.DTAEMISSAO >= '22-sep-2025'
;
